
import Foundation

struct Swap : Codable {
    let amount0In : String?
    let amount0Out : String?
    let amount1In : String?
    let amount1Out : String?
    let amountUSD : String?
    let to : String?
    let transaction : Transaction?
    let pair : Pair?
    
    enum TransactionType : String {
        case buy, sell, unknown
    }

    func amountEth() -> Double {
        if self.pair?.token0.symbol == "WETH" {
            if (Double(self.amount0In ?? "") ?? 0.0) > 0.0 {
                return Double(self.amount0In ?? "") ?? 0.0
            } else {
                return Double(self.amount0Out ?? "") ?? 0.0
            }
        } else {
            if (Double(self.amount1In ?? "") ?? 0.0) > 0.0 {
                return Double(self.amount1In ?? "") ?? 0.0
            } else {
                return Double(self.amount1Out ?? "") ?? 0.0
            }
        }
    }
    
    func amountToken(forToken token:Token?) -> Double {
        if self.pair?.token0.id == token?.id {
            if (Double(self.amount0In ?? "") ?? 0.0) > 0.0 {
                return Double(self.amount0In ?? "") ?? 0.0
            } else {
                return Double(self.amount0Out ?? "") ?? 0.0
            }
        } else {
            if (Double(self.amount1In ?? "") ?? 0.0) > 0.0 {
                return Double(self.amount1In ?? "") ?? 0.0
            } else {
                return Double(self.amount1Out ?? "") ?? 0.0
            }
        }
    }
    
    func transactionType(forToken token:Token?) -> TransactionType {
        if self.pair?.token0.id == token?.id {
            if (Double(self.amount0In ?? "") ?? 0.0) > 0.0 {
                return .sell
            } else {
                return .buy
            }
        } else {
            if (Double(self.amount1In ?? "") ?? 0.0) > 0.0 {
                return .sell
            } else {
                return .buy
            }
        }
    }
    
}
