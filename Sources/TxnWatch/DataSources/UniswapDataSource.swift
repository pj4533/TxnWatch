import Foundation

class UniswapDataSource {
    internal func uniswapGraphQLTokenQuery(parameters: [String:Any], withSuccess success: ((_ token: Token?) -> Void)?, failure: ((_ error: Error?) -> Void)? ) {
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
        
        struct TokensReponse : Codable {
            let tokens : [Token]?
        }
        struct GraphQLResponse : Codable {
            let data: TokensReponse?
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let graphQLResponse = try decoder.decode(GraphQLResponse.self, from: data)
                    
                    success?(graphQLResponse.data?.tokens?.first)
                } catch let error {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func getToken(tokenId: String, withSuccess success: ((_ token: Token?) -> Void)?, failure: ((_ error: Error?) -> Void)? ) {
        let parameters : [String:Any] = [
            "query" : "query($tokenIds: [String]!) {  tokens(where: { id_in: $tokenIds } ) { id name symbol derivedETH totalSupply totalLiquidity decimals   }  }",
            "variables" : [
                "tokenIds" : [tokenId.lowercased()]
            ]
        ]
        self.uniswapGraphQLTokenQuery(parameters: parameters, withSuccess: success, failure: failure)
    }
}
