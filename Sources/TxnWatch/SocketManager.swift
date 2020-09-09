import Foundation
import Starscream

class SocketManager : WebSocketDelegate {
    
    var socket : WebSocket?
    var debug = false
    
    init() {
        var request = URLRequest(url: URL(string: "wss://mainnet.infura.io/ws/v3/\(Secrets().infuraProjectId)")!)
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        self.socket?.delegate = self
        self.socket?.connect()
    }
    
    func getTxns(forAddress address: String) {
        let socketString = "{\"jsonrpc\":\"2.0\",\"method\":\"eth_subscribe\",\"id\":1,\"params\":[\"logs\", {\"address\":[\"\(address)\"]}]}"
        self.socket?.write(string: socketString, completion: nil)
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
                let datasource = InfuraDataSource()
                datasource.getTxnHash(txnHash: txnHash, withSuccess: { (transaction) in
                    print("TXN: \(transaction?.hash ?? "???")\n\(transaction?.input ?? "???")\n")
                }) { (error) in
                    print(error?.localizedDescription ?? "Unknown Error")
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
