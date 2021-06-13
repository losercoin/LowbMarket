# LowbMarket
A smart contract support to trade NFT using LOWB

### Compiling and running the code
- Before running this project, install truffle first: `npm install -g truffle`.

- Run `npm install` to install required modules.

- Compile the smart contracts: `truffle compile`.

- Deploy to local network: `truffle migrate`. (You may need to start [Ganache](https://www.trufflesuite.com/ganache) before migrating.)

- Now you can start to play with this contract: `truffle console`. For example, you can sell and buy tokens by (you may need to interact with the other two contract first):

  ```javascript
  truffle(development)> let market = await LowbMarket.deployed()
  truffle(development)> const accounts = await web3.eth.getAccounts()
  truffle(development)> market.offerItemForSale(1, '100000')
  truffle(development)> market.buyItem(1, '100000', {from: accounts[1]})
  ```
### Depolying to the live network

- Change the token address in `2_deploy_contracts.js` before deploying to live work.
- Create a new .secret file in root directory and enter your 12 word mnemonic seed phrase. Then just run `truffle migrate --network testnet`. You will deploy contracts to the Binance testnet.
- To verify the contract, create a new .apikey file in root directory and enter the [API Key](https://bscscan.com/myapikey). Then just run `truffle run verify LowbMarket@{contract-address} --network testnet`. 
