import Foundation

struct Token : Codable {
    let name : String
    let symbol : String
    let id : String
    let derivedETH : String
    let decimals : String
    
    func usdMarketPrice(withEtherPrice etherPrice: Double) -> Double {
        return (Double(self.derivedETH) ?? 0) * etherPrice
    }    
}
