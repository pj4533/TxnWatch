# txnwatch [![Donate](https://img.shields.io/badge/donate-bitcoin-blue.svg)](https://blockchair.com/bitcoin/address/1CDF8xDX33tdkEyUcHL22DBTDEmq4ukMPp) [![Donate](https://img.shields.io/badge/donate-ethereum-blue.svg)](https://blockchair.com/ethereum/address/0xde6458b369ebadba2b515ca0dd4a4d978ad2f93a)  <a href="https://www.buymeacoffee.com/pj4533" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

```
OVERVIEW: Realtime Ether Transactions

USAGE: txnwatch <address>

ARGUMENTS:
  <address>               Ethereum address

OPTIONS:
  -h, --help              Show help information.
```

TxnWatch connects via websocket to Infura and subscribes to the 
logs of a given address. When a transaction comes through, a call
is made to the Infura API `eth_getTransactionByHash` and the input data and txn hash are output to the console.

### Building Notes

As a quick hack for handling secrets (like API keys), I just put them in a file that is excluded from git. 
1. Under the `Sources` folder, create a file called `Secrets.swift`
2. In that file put this:
```
struct Secrets {
  let infuraProjectId = "<Your Infura Project ID Key>"
}
```
3. Then build normally

### Example Output

```
~/projects/TxnWatch ] swift run txnwatch 0x6f87d756daf0503d08eb8993686c7fc01dc44fb1                        
Address: 0x6f87d756daf0503d08eb8993686c7fc01dc44fb1
TXN: 0xd9511c6513ccde52851e2d187ae12473d191dada660620c5f670496ce3d54717
0x7ff36ab50000000000000000000000000000000000000000000000b0b3ada63b7eeefa1d00000000000000000000000000000000000000000000000000000000000000800000000000000000000000009175e0e8434cb6c5cc45a64f8a80f66ec81b47bf000000000000000000000000000000000000000000000000000000005f5855510000000000000000000000000000000000000000000000000000000000000002000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc20000000000000000000000006f87d756daf0503d08eb8993686c7fc01dc44fb1
```
### To do

* Figure out easiest way to decode the transaction input data. I have looked into the various swift Web3 libraries and none seemed to do exactly the right thing. Ideally, I want output similar to the "Transaction Action" on Etherscan. 

### Helpful Links

https://etid.wtd.ru

https://etherscan.io

https://www.pauric.blog/How-to-Query-and-Monitor-Ethereum-Contract-Events-with-Web3/


### Developer Commands

`swift build` Builds app to the `.build` folder

`swift build -c release` Build a release version

`swift package generate-xcodeproj` Generates an xcode project file

