import Foundation
import ArgumentParser

import Web3
import Web3ContractABI
import Web3PromiseKit

struct TxnWatch: ParsableCommand {
    static let configuration = CommandConfiguration(
    	commandName: "txnwatch",
        abstract: "Realtime Ether Transactions"
    )

    @Argument(help: "Ethereum address")
    var address: String

	func run() {
        print("Address: \(self.address)")

        let web3 = Web3(rpcURL: "https://mainnet.infura.io/3a0b2cf4434943908b81e54735c1013f")

        do {
            let contractAddress = try EthereumAddress(hex: "0x6f87d756daf0503d08eb8993686c7fc01dc44fb1", eip55: false)
            let contract = web3.eth.Contract(type: GenericERC20Contract.self, address: contractAddress)
            
            contract.symbol().call { (response, error) in
                print(response ?? [:])
            }
        } catch {
            print("error caught")
        }

        
        
        //  let socketManager = SocketManager()
        //  DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        //      socketManager.getTxns(forAddress: self.address)
        //  }

        
        
        // Run GCD main dispatcher, this function never returns, call exit() elsewhere to quit the program or it will hang
        dispatchMain()
    }
        
}

TxnWatch.main()
