//
//  TransactionLog.swift
//  TxnWatch
//
//  Created by PJ Gray on 10/2/20.
//

import Foundation

struct TransactionLog : Codable {
    let address : String?
    let blockHash : String?
    let blockNumber : String?
    let data : String?
    let logIndex : String?
    let removed : Bool?
    let topics : [String]?
    let transactionHash : String?
    let transactionIndex : String?
}
