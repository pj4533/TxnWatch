//
//  InfuraDataSource.swift
//  TxnWatch
//
//  Created by PJ Gray on 9/8/20.
//

import Foundation

class InfuraDataSource {
    func getTxnReceipt(txnHash: String, withSuccess success: ((_ receipt: TransactionReceipt? ) -> Void)?, failure: ((_ error: Error?) -> Void)? ) {
        
        let parameters : [String:Any] = [
            "jsonrpc" : "2.0",
            "method" : "eth_getTransactionReceipt",
            "params" : [
                txnHash
            ],
            "id" : 1
        ]
        
        let url = URL(string: "https://mainnet.infura.io/v3/\(Secrets().infuraProjectId)?ids=ethereum&vs_currencies=usd")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        struct InfuraResponse : Codable {
            let result: TransactionReceipt?
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(InfuraResponse.self, from: data)
                    
                    success?(response.result)
                } catch let error {
                    print(error)
                }
            }
        }
        task.resume()
    }

    
    func getTxnHash(txnHash: String, withSuccess success: ((_ transaction: Transaction? ) -> Void)?, failure: ((_ error: Error?) -> Void)? ) {
        
        let parameters : [String:Any] = [
            "jsonrpc" : "2.0",
            "method" : "eth_getTransactionByHash",
            "params" : [
                txnHash
            ],
            "id" : 1
        ]
        
        let url = URL(string: "https://mainnet.infura.io/v3/\(Secrets().infuraProjectId)?ids=ethereum&vs_currencies=usd")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        struct InfuraResponse : Codable {
            let result: Transaction?
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(InfuraResponse.self, from: data)
                    
                    success?(response.result)
                } catch let error {
                    print(error)
                }
            }
        }
        task.resume()
    }
}
