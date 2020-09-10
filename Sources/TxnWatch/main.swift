import Foundation
import ArgumentParser
import Rainbow

struct TxnWatch: ParsableCommand {
    static let configuration = CommandConfiguration(
    	commandName: "txnwatch",
        abstract: "Realtime Ether Transactions"
    )

    @Argument(help: "Ethereum token address")
    var address: String

	func run() {
        let socketManager = SocketManager()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            socketManager.getTxns(forAddress: self.address)
        }

        // Run GCD main dispatcher, this function never returns, call exit() elsewhere to quit the program or it will hang
        dispatchMain()
    }
        
}

TxnWatch.main()
