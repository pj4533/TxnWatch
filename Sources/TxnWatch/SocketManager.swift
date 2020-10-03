import Foundation
import Starscream
import UInt256

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
    
    func getTxns(forQueryString queryString: String, includeTransaction:Bool?) {
        self.includeTransactionHash = includeTransaction
        let uniswapDataSource = UniswapDataSource()
        uniswapDataSource.getToken(queryString: queryString, withSuccess: { (token) in
            self.token = token
            if let token = token {
                print("\nWatching transactions for \(token.name) (\(token.symbol))\n")
                if self.includeTransactionHash ?? false {
                    print("\("Date".white.bold)\t\t\t\("Type".white.bold)\t\("Price (USD)".white.bold)\t\("Price (ETH)".white.bold)\t\("Amount \(token.symbol)".white.bold)\t\("Total ETH".white.bold)\t\("TXN".white.bold)")
                } else {
                    print("\("Date".white.bold)\t\t\t\("Type".white.bold)\t\("Price (USD)".white.bold)\t\("Price (ETH)".white.bold)\t\("Amount \(token.symbol)".white.bold)\t\("Total ETH".white.bold)")
                }

                let socketString = "{\"jsonrpc\":\"2.0\",\"method\":\"eth_subscribe\",\"id\":1,\"params\":[\"logs\", {\"address\":[\"\(token.id)\"]}]}"
                if self.debug {
                    print("--> \(socketString)")
                }
                self.socket?.write(string: socketString, completion: nil)
            } else {
                print("Token returned nil")
            }
        }) { (error) in
            print("Uniswap error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    func printTransactionHash(_ txnHash: String) {
        let uniswapDataSource = UniswapDataSource()
        uniswapDataSource.getToken(queryString: self.token?.id ?? "", withSuccess: { (token) in
            self.token = token
            if (self.debug) {
                print("--> printTransactionHash()   \(txnHash)")
            }
            enum TransactionType : String {
                case buy, sell, addLiquidity = "add", removeLiquidity = "remove", getReward = "reward", exit, deposit, withdraw, approve, transfer, unknown
            }
            var transactionType : TransactionType = .unknown
            var inAmount = 0.0
            var outAmount = 0.0
            let decimals = self.token?.decimals ?? "0"
            let decimalMultiplier = Double("1e-\(decimals)") ?? 0
            var foundSwap = false
            var shouldReverse = true
            if let tokenId = self.token?.id.lowercased() {
                let datasource = InfuraDataSource()
                datasource.getTxnHash(txnHash: txnHash) { (transaction) in
                    if let inputData = transaction?.input {
                        let inputDataMethodSig = inputData.prefix(10)
                        let inputDataParams = inputData.dropFirst(10)

                        if (inputDataMethodSig == "0x18cbafe5") || (inputDataMethodSig == "0x4a25d94a") {
                            // swapExactTokensForETH or swapTokensForExactETH
//                            print("---> swapExactTokensForETH or swapTokensForExactETH (\(txnHash))")
                            transactionType = .sell
                        } else if inputDataMethodSig == "0x49c082cd" {
                            // zapOut
//                            print("---> zapOut (\(txnHash))")
                            transactionType = .sell
                        } else if (inputDataMethodSig == "0x7ff36ab5") || (inputDataMethodSig == "0xfb3bdb41") {
                            // swapExactETHForTokens and swapETHForExactTokens
//                            print("---> swapExactETHForTokens (\(txnHash))")
                            transactionType = .buy
                        } else if (inputDataMethodSig == "0x38ed1739") || (inputDataMethodSig == "0x8803dbee") {
                            // swapExactTokensForTokens and swapTokensForExactTokens
//                            print("---> swapExactTokensForTokens or swapTokensForExactToken (\(txnHash))")
                            // could be buy or sell, depending on where the token in question is, need to look at input data params (See below)
                            
                            let dataStringArray = inputDataParams.replacingOccurrences(of: "0x", with: "").components(withLength: 64)

                            if let firstTokenInSwap = dataStringArray.last {
                                print("tokenId: \(tokenId)    firstTokenInSwap: \(firstTokenInSwap)")
                                if tokenId.contains(firstTokenInSwap) {
                                    shouldReverse = false
                                    transactionType = .sell
                                } else {
                                    transactionType = .buy
                                }
                            }

                        } else if (inputDataMethodSig == "0xe2bbb158") {
                            // deposit
//                            print("---> deposit (\(txnHash))")
                            transactionType = .deposit
                        } else if (inputDataMethodSig == "0x441a3e70") {
                            // withdraw
//                            print("---> withdraw (\(txnHash))")
                            transactionType = .withdraw
                        } else if (inputDataMethodSig == "0xf305d719") {
                            // addLiquidityETH
//                            print("---> addLiquidityETH (\(txnHash))")
                            transactionType = .addLiquidity
                        } else if (inputDataMethodSig == "0x2195995c") || (inputDataMethodSig == "0xded9382a") {
                            // removeLiquidityWithPermit
//                            print("---> removeLiquidityWithPermit (\(txnHash))")
                            transactionType = .removeLiquidity
                        } else if (inputDataMethodSig == "0x095ea7b3") {
                            // approve
//                            print("---> approve (\(txnHash))")
                            transactionType = .approve
                        } else if (inputDataMethodSig == "0x1c4b774b") {
                            // getReward
//                            print("---> getReward (\(txnHash))")
                            transactionType = .getReward
                        } else if inputDataMethodSig == "0x2af9cc41" {
                            // exit
//                            print("---> exit (\(txnHash))")
                            transactionType = .exit
                        } else if inputDataMethodSig == "0xa9059cbb" {
                            transactionType = .transfer
                        } else {
                            print("---> Unknown: \(inputDataMethodSig) (\(txnHash))")
                        }
                    }
                    
                    datasource.getTxnReceipt(txnHash: txnHash) { (receipt) in
                        let logs = shouldReverse ? receipt?.logs?.reversed() : receipt?.logs
                        for log in logs ?? [] {
                            if self.debug {
                                print("Log #\(log.logIndex ?? "-") Address: \(log.address ?? "-")")
                                print("Log #\(log.logIndex ?? "-") Data: \(log.data ?? "-")")
                            }

                            // 0xd78... is the ERC20 Sig for Swap
                            if (log.topics?.first?.lowercased() == "0xd78ad95fa46c994b6551d0da85fc275fe613ce37657fb8d5e3d130840159d822") {
                                foundSwap = true
                                let dataStringArray = log.data?.replacingOccurrences(of: "0x", with: "").components(withLength: 64)
                                
                                // couldnt figure this out with a map, not sure why
                                var amounts : [UInt256] = []
                                for str in dataStringArray ?? [] {
                                    amounts.append(UInt256(str, radix: 16) ?? 0)
                                }
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

                                // if we found a swap, there might be another if it is a swapTokensForTokens, but we just care about the first one
                                if foundSwap {
                                    break
                                }
                            }
                        }
                        
                        let coinGeckoDataSource = CoinGeckoDataSource()
                        coinGeckoDataSource.getETHPrice(withSuccess: { (ethPrice) in
                            let priceUSD = self.token?.usdMarketPrice(withEtherPrice: ethPrice) ?? 0.0
                            let priceETH = self.token?.derivedETH
                            let formatter = DateFormatter()
                            formatter.dateFormat = "MM/dd/yyyy h:mm:ss"
                            let dateString = formatter.string(from: Date())


                            if foundSwap {
                                let totalEth = (transactionType == .sell) || (transactionType == .unknown) ? outAmount : inAmount
                                let amountToken = transactionType == .buy ? outAmount : inAmount
                                let colorizedTransactionType = transactionType == .buy ? transactionType.rawValue.green : transactionType.rawValue.red

                                if self.includeTransactionHash ?? false {
                                    print(String(format: "\(dateString)\t\(colorizedTransactionType)\t%.8f\t%.8f\t%.8f\t%.8f\t\(txnHash)",priceUSD,Double(priceETH ?? "0.0") ?? 0.0,amountToken,totalEth))
                                } else {
                                    print(String(format: "\(dateString)\t\(colorizedTransactionType)\t%.8f\t%.8f\t%.8f\t%.8f",priceUSD,Double(priceETH ?? "0.0") ?? 0.0,amountToken,totalEth))
                                }
                            } else {
                                if self.includeTransactionHash ?? false {
                                    print(String(format: "\(dateString)\t\(transactionType.rawValue)\t%.8f\t%.8f\t-\t\t-\t\t\(txnHash)",priceUSD,Double(priceETH ?? "0.0") ?? 0.0))
                                } else {
                                    print(String(format: "\(dateString)\t\(transactionType.rawValue)\t%.8f\t%.8f",priceUSD,Double(priceETH ?? "0.0") ?? 0.0))
                                }
                            }
                        }) { (error) in
                            print("Coin Gecko Error: \(error?.localizedDescription ?? "Unknown Error")")
                        }
                    } failure: { (error) in
                        print(error?.localizedDescription ?? "unknown error")
                    }
                } failure: { (error) in
                    print(error?.localizedDescription ?? "unknown error")
                }

            }
        }) { (error) in
            print(error?.localizedDescription ?? "Unknown Error")
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
            } else {
                if debug {
                    print("ERROR: unknown text received: \(text)")
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
            print("websocket is disconnected: \(reason) with code: \(code)")
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
            print("********** reconnectSuggested ****************")
            break
        case .cancelled:
            print("Cancelled")
        case .error(let error):
            print(error?.localizedDescription ?? "Unknown error")
        }
    }

}
