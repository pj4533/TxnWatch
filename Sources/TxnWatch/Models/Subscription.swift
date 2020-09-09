import Foundation

struct Subscription : Codable {
    let jsonrpc : String?
    let method : String?
    let params : Parameters?
}
