import Foundation
import Starscream



class SocketManager : WebSocketDelegate {
    
    var socket : WebSocket?
    var debug = false
    var token : Token?
    
    init() {
        var request = URLRequest(url: URL(string: "wss://mainnet.infura.io/ws/v3/\(Secrets().infuraProjectId)")!)
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        self.socket?.delegate = self
        self.socket?.connect()
    }
    
    func getTxns(forAddress address: String) {
                // debugging
        //        let txnHash = "0xf4e646e0b7951dc7fdfc570b3d4ce734b9969914099692833516409d36e37b6a"
        //        self.printTransactionHash(txnHash)

        let uniswapDataSource = UniswapDataSource()
        uniswapDataSource.getToken(tokenId: address, withSuccess: { (token) in
            self.token = token
            if let token = token {
                print("\nWatching transactions for \(token.name) (\(token.symbol))\n")
                print("\("Date".white.bold)\t\t\t\("Type".white.bold)\t\("Price (USD)".white.bold)\t\("Price (ETH)".white.bold)\t\("Amount \(token.symbol)".white.bold)\t\("Total ETH".white.bold)\t\("Maker".white.bold)")
                
                let socketString = "{\"jsonrpc\":\"2.0\",\"method\":\"eth_subscribe\",\"id\":1,\"params\":[\"logs\", {\"address\":[\"\(address)\"]}]}"
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
        if (self.debug) {
            print("--> printTransactionHash()   \(txnHash)")
        }
        let datasource = InfuraDataSource()
        datasource.getTxnHash(txnHash: txnHash, withSuccess: { (transaction) in
            let coinGeckoDataSource = CoinGeckoDataSource()
            coinGeckoDataSource.getETHPrice(withSuccess: { (ethPrice) in
                if let valueDecimal = transaction?.value?.hexaToDecimal, valueDecimal > 0 {
                    let decimals = self.token?.decimals ?? "0"
                    let doubleValue = Double("1e-\(decimals)") ?? 0
                    let totalEth = Double(valueDecimal) * (doubleValue)
                    let priceUSD = self.token?.usdMarketPrice(withEtherPrice: ethPrice) ?? 0.0
                    let priceETH = self.token?.derivedETH
                    var amountToken = 0.0
                    if let priceETH = priceETH, let priceETHDouble = Double(priceETH) {
                        amountToken = totalEth / priceETHDouble
                        print(String(format: "<somedate>\t\t\("buy".green)\t%.8f\t%.8f\t%.8f\t%.8f\t\(transaction?.from ?? "???")",priceUSD,priceETHDouble,amountToken,totalEth))
                    }
                } else {
                    print(String(format: "<somedate>\t\t\("sell?".red)\t%.8f\t%.8f\t%.8f\t%.8f\t\(transaction?.from ?? "???")",0.0,0.0,0.0,0.0))
                }
            }) { (error) in
                print("Coin Gecko Error: \(error?.localizedDescription ?? "Unknown Error")")
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
                self.printTransactionHash(txnHash)
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
