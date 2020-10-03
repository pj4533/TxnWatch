//
//  TransactionReceipt.swift
//  TxnWatch
//
//  Created by PJ Gray on 10/2/20.
//

import Foundation

struct TransactionReceipt : Codable {
    let blockHash : String?
    let blockNumber : String?
    let contractAddress : String?
    let cumulativeGasUsed : String?
    let from : String?
    let gasUsed : String?
    let logs : [TransactionLog]?
    let logsBloom : String?
    let status : String?
    let to : String?
    let transactionHash : String?
    let transactionIndex : String?    
}
