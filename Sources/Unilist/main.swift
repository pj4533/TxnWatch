import Foundation
import ArgumentParser

struct TxnWatch: ParsableCommand {
    static let configuration = CommandConfiguration(
    	commandName: "txnwatch",
        abstract: "Realtime Ether Transactions"
    )

    @Argument(help: "Ethereum address")
    var address: String

	func run() {
        print("Address: \(self.address)")
    }
        
}

TxnWatch.main()
