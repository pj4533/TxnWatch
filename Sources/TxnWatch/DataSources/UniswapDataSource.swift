import Foundation

class UniswapDataSource {
    func getToken(queryString: String, withSuccess success: ((_ token: Token?) -> Void)?, failure: ((_ error: Error?) -> Void)? ) {
        let parameters : [String:Any] = [
            "query" : "query tokens($value: String, $id: String) {  asSymbol: tokens(where: {symbol_contains: $value}, orderBy: totalLiquidity, orderDirection: desc) {id name symbol derivedETH totalSupply totalLiquidity decimals} asName: tokens(where: {name_contains: $value}, orderBy: totalLiquidity, orderDirection: desc) {id name symbol derivedETH totalSupply totalLiquidity decimals}  asAddress: tokens(where: {id: $id}, orderBy: totalLiquidity, orderDirection: desc) {id name symbol derivedETH totalSupply totalLiquidity decimals}}",
            "variables" : [
                "value" : queryString.uppercased(),
                "id" : queryString.lowercased()
            ]
        ]
        
        let url = URL(string: "https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v2")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        struct DataResponse : Codable {
            let asAddress : [Token]
            let asName : [Token]
            let asSymbol : [Token]
        }
        
        struct GraphQLResponse : Codable {
            let data: DataResponse?
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let graphQLResponse = try decoder.decode(GraphQLResponse.self, from: data)
                    
                    let tokens = (graphQLResponse.data?.asSymbol ?? []) + ((graphQLResponse.data?.asName ?? []) + (graphQLResponse.data?.asAddress ?? [])).unique {$0.id}

                    let exactMatchSymbol = tokens.filter({$0.symbol.lowercased() == queryString.lowercased()})
                    if exactMatchSymbol.count > 0 {
                        success?(exactMatchSymbol.first)
                    } else {
                        success?(tokens.first)
                    }
                } catch let error {
                    print(error)
                }
            }
        }
        task.resume()
    }
}
