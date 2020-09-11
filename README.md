# txnwatch [![Donate](https://img.shields.io/badge/donate-bitcoin-blue.svg)](https://blockchair.com/bitcoin/address/1CDF8xDX33tdkEyUcHL22DBTDEmq4ukMPp) [![Donate](https://img.shields.io/badge/donate-ethereum-blue.svg)](https://blockchair.com/ethereum/address/0xde6458b369ebadba2b515ca0dd4a4d978ad2f93a)  <a href="https://www.buymeacoffee.com/pj4533" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

```
OVERVIEW: Realtime ERC20 Token Transactions

USAGE: txnwatch <address> [--include-transaction]

ARGUMENTS:
  <address>               ERC20 token address

OPTIONS:
  -i, --include-transaction
                          Include transaction hash in output
  -h, --help              Show help information.
  ```

TxnWatch connects via websocket to Infura and subscribes to the logs of a given address. When a transaction comes through, a call is made to get the transaction and the transaction receipt. Data is parsed using the [Web3.swift](https://github.com/Boilertalk/Web3.swift) library.

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
~/projects/TxnWatch ]  swift run txnwatch 0x6f87d756daf0503d08eb8993686c7fc01dc44fb1 -i

Watching transactions for UniTrade (TRADE)

Date			Type	Price (USD)	Price (ETH)	Amount TRADE	Total ETH	TXN
09/10/2020 8:55:11	buy	1.26256483	0.00340415	2965.18664325	10.20000000	0xc97ea37bb4bcaae4ba2bb3c2fcee625cc3ca3a43c0a5ec152ad98fc4dcfbef8b
09/10/2020 8:56:08	buy	1.26256483	0.00340415	5764.81445319	20.00000000	0x82b1474b4e57203f362724cbf6f11452958fcd6a7f9c3ae8a17b3aa3c832853c
09/10/2020 8:56:25	sell	1.26256483	0.00340415	2179.00000000	7.54083904	0x5ec316a8e0d8260f4a725a697fd3c6b047dcc8951d86abf8486f1c16292b7c55
09/10/2020 8:58:16	buy	1.26256483	0.00340415	3871.16973692	13.50000000	0x291d3988d8ada0530918289114c6b6094e7a905fcd18ffc3dace934de7ec1d51```

### Helpful Links

https://etid.wtd.ru

https://etherscan.io

https://www.pauric.blog/How-to-Query-and-Monitor-Ethereum-Contract-Events-with-Web3/


### Developer Commands

`swift build` Builds app to the `.build` folder

`swift build -c release` Build a release version

`swift package generate-xcodeproj` Generates an xcode project file

