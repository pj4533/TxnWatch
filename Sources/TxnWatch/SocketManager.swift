import Foundation
import Starscream

class SocketManager : WebSocketDelegate {
    
    var socket : WebSocket?
    
    init() {
        var request = URLRequest(url: URL(string: "wss://mainnet.infura.io/ws/v3/3a0b2cf4434943908b81e54735c1013f")!)
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        self.socket?.delegate = self
        self.socket?.connect()
    }
    
    func getTxns(forAddress address: String) {
        let socketString = "{\"jsonrpc\":\"2.0\",\"method\":\"eth_subscribe\",\"id\":1,\"params\":[\"logs\", {\"address\":[\"\(address)\"]}]}"
        
        print("--> \(socketString)")
        self.socket?.write(string: socketString, completion: {
            
        })
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
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
