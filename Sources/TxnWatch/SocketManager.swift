import Foundation
import Starscream
import Web3
import Web3PromiseKit
import Web3ContractABI

class SocketManager : WebSocketDelegate {
    
    var socket : WebSocket?
    var debug = false
    var token : Token?
    var includeTransactionHash : Bool?
    var hashesSeen : [String] = []
    
    init() {
        var request = URLRequest(url: URL(string: "wss://mainnet.infura.io/ws/v3/\(Secrets().infuraProjectId)")!)
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        self.socket?.delegate = self
        self.socket?.connect()
    }
    
    func getTxns(forAddress address: String, includeTransaction:Bool?) {
        self.includeTransactionHash = includeTransaction
        let uniswapDataSource = UniswapDataSource()
        uniswapDataSource.getToken(tokenId: address, withSuccess: { (token) in
            self.token = token
            if let token = token {
                print("\nWatching transactions for \(token.name) (\(token.symbol))\n")
                if self.includeTransactionHash ?? false {
                    print("\("Date".white.bold)\t\t\t\("Type".white.bold)\t\("Price (USD)".white.bold)\t\("Price (ETH)".white.bold)\t\("Amount \(token.symbol)".white.bold)\t\("Total ETH".white.bold)\t\("TXN".white.bold)")
                } else {
                    print("\("Date".white.bold)\t\t\t\("Type".white.bold)\t\("Price (USD)".white.bold)\t\("Price (ETH)".white.bold)\t\("Amount \(token.symbol)".white.bold)\t\("Total ETH".white.bold)")
                }

                let socketString = "{\"jsonrpc\":\"2.0\",\"method\":\"eth_subscribe\",\"id\":1,\"params\":[\"logs\", {\"address\":[\"\(address)\"]}]}"
                if self.debug {
                    print("--> \(socketString)")
                }
                self.socket?.write(string: socketString, completion: nil)
                
                // error:   some sells are doubled
            } else {
                print("Token returned nil")
            }
        }) { (error) in
            print("Uniswap error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    func printTransactionHash(_ txnHash: String) {
        if (self.debug) {
            print("--> printTransactionHash()   \(txnHash)")
        }
        enum TransactionType : String {
            case buy, sell
        }
        var transactionType : TransactionType = .buy
        var inAmount = 0.0
        var outAmount = 0.0
        let decimals = self.token?.decimals ?? "0"
        let decimalMultiplier = Double("1e-\(decimals)") ?? 0
        var foundSwap = false
        var shouldReverse = true
        if let tokenId = self.token?.id.lowercased() {
            do {
                let web3 = Web3(rpcURL: "https://mainnet.infura.io/v3/\(Secrets().infuraProjectId)")
                let contractAddress = try EthereumAddress(hex: tokenId, eip55: false)
                let contractAddressChecksummed = try EthereumAddress(hex: contractAddress.hex(eip55: true), eip55: true)
                let contract = web3.eth.Contract(type: GenericERC20Contract.self, address: contractAddressChecksummed)
                let txn = EthereumValue(stringLiteral: txnHash)
                try contract.eth.getTransactionByHash(blockHash: EthereumData(EthereumData(ethereumValue: txn.ethereumValue())), response: { (txnObject) in

                    let inputDataMethodSig = txnObject.result??.input.hex().prefix(10)
                    let inputDataParams = String(txnObject.result??.input.hex().dropFirst(10) ?? "")
                    
                    // swapExactTokensForETH
                    if inputDataMethodSig == "0x18cbafe5" {
                        transactionType = .sell
                    }
                    
                    // swapExactETHForTokens
                    if inputDataMethodSig == "0x7ff36ab5" {
                        transactionType = .buy
                    }

                    // swapExactTokensForTokens
                    if inputDataMethodSig == "0x38ed1739" {
                        do {
                            // this is weird -- looks like it may have changed, the array decoding no longer is working here
                            let params = try ABI.decodeParameters(types: [.uint256,.uint256,.address,.address,.uint256,.uint256,.address], from: inputDataParams)
                            if let firstTokenInSwap = (params.last as? EthereumAddress)?.hex(eip55: false) {
                                if firstTokenInSwap == tokenId {
                                    shouldReverse = false
                                    transactionType = .sell
                                } else {
                                    transactionType = .buy
                                }
                            }
                        } catch let error {
                            print(error)
                        }
                    }
                    
                    do {
                        try contract.eth.getTransactionReceipt(transactionHash:
                            EthereumData(EthereumData(ethereumValue: txn.ethereumValue())), response: { (receipt) in
                                var logIndex = 1
                                let logs = shouldReverse ? receipt.result??.logs.reversed() : receipt.result??.logs
                                for log in logs ?? [] {
                                    if self.debug {
                                        print("Log #\(logIndex) Address: \(log.address.hex(eip55: false))")
                                        print("Log #\(logIndex) Data: \(log.data.ethereumValue().string ?? "???")")
                                    }

                                    // 0xd78... is the ERC20 Sig for Swap
                                    if (log.topics.first?.hex() == "0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822") {
                                        foundSwap = true
                                        do {
                                            let param = try ABI.decodeParameters(types: [.uint256,.uint256,.uint256,.uint256], from: log.data.hex())
                                            if self.debug {
                                                print("Log #\(logIndex) Decoded Data: \(param)")
                                            }

                                            if let amounts = param as? [BigUInt] {
                                                var amountIndex = 0
                                                for amount in amounts {
                                                    if amount != 0, (amountIndex == 0) || (amountIndex == 1) {
                                                        inAmount = Double(amount) * decimalMultiplier
                                                    }
                                                    if amount != 0, (amountIndex == 2) || (amountIndex == 3) {
                                                        outAmount = Double(amount) * decimalMultiplier
                                                    }
                                                    amountIndex = amountIndex + 1
                                                }
                                            }
                                        } catch let error {
                                            print(error)
                                        }
                                    }

                                    if self.debug {
                                        var topicIndex = 1
                                        for topic in log.topics {
                                            print("Log #\(logIndex) Topic #\(topicIndex): \(topic.hex())")
                                            topicIndex = topicIndex + 1
                                        }
                                    }
                                    logIndex = logIndex + 1

                                    // if we found a swap, there might be another if it is a swapTokensForTokens, but we just care about the first one
                                    if foundSwap {
                                        break
                                    }
                                }

                                if foundSwap {
                                    let coinGeckoDataSource = CoinGeckoDataSource()
                                    coinGeckoDataSource.getETHPrice(withSuccess: { (ethPrice) in
                                        let totalEth = transactionType == .sell ? outAmount : inAmount
                                        let priceUSD = self.token?.usdMarketPrice(withEtherPrice: ethPrice) ?? 0.0
                                        let priceETH = self.token?.derivedETH
                                        let amountToken = transactionType == .buy ? outAmount : inAmount
                                        let colorizedTransactionType = transactionType == .buy ? transactionType.rawValue.green : transactionType.rawValue.red
                                        
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "MM/dd/yyyy h:mm:ss"
                                        let dateString = formatter.string(from: Date())
                                        
                                        
                                        if self.includeTransactionHash ?? false {
                                            print(String(format: "\(dateString)\t\(colorizedTransactionType)\t%.8f\t%.8f\t%.8f\t%.8f\t\(txnHash)",priceUSD,Double(priceETH ?? "0.0") ?? 0.0,amountToken,totalEth))
                                        } else {
                                            print(String(format: "\(dateString)\t\(colorizedTransactionType)\t%.8f\t%.8f\t%.8f\t%.8f",priceUSD,Double(priceETH ?? "0.0") ?? 0.0,amountToken,totalEth))
                                        }
                                    }) { (error) in
                                        print("Coin Gecko Error: \(error?.localizedDescription ?? "Unknown Error")")
                                    }
                                }
                        })

                    } catch let error {
                       print(error)
                    }
                })
            } catch let error {
                print(error)
            }
        }
    }
    
    func processText(_ text:String) {
        let jsonData = text.data(using: .utf8)!
        do {
            struct Txn : Codable {
                let transactionHash : String?
            }
            struct Parameters : Codable {
                let result : Txn?
            }
            struct Subscription : Codable {
                let params : Parameters?
            }
            let sub = try JSONDecoder().decode(Subscription.self, from: jsonData)
            if let txnHash = sub.params?.result?.transactionHash {
                if !self.hashesSeen.contains(txnHash) {
                    self.hashesSeen.append(txnHash)
                    self.printTransactionHash(txnHash)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(_):
            if self.debug {
                print("websocket is connected")
            }
        case .disconnected(let reason, let code):
            if self.debug {
                print("websocket is disconnected: \(reason) with code: \(code)")
            }
        case .text(let string):
            if self.debug {
                print("Received text: \(string)")
            }
            self.processText(string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            print("Cancelled")
        case .error(let error):
            print(error?.localizedDescription ?? "Unknown error")
        }
    }

}
