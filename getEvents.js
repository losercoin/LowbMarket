const fs = require('fs');
const LowbMarket = artifacts.require('LowbMarket');

module.exports = async function(callback) {
  try {
    let rawdata = fs.readFileSync('events-8.json');
    let events = JSON.parse(rawdata);
    
    const blockStart = events["blockNumber"]
    
    const market = await LowbMarket.at('0x3DA004FFC68C0C8974A4A91E7fB52875bb7Ad938') //mainnet
    //const market = await LowbMarket.at('0xbB82bb854A0Ad088796ed39eB67F0F49781dc9A2') //testnet

    let block = await web3.eth.getBlockNumber()
    console.log(blockStart, block)

    //const transaction = await market.getPastEvents('ItemBought', { fromBlock: 8264441, toBlock: 8268441 })
    const transaction = await market.getPastEvents('ItemBought', { fromBlock: 9312441, toBlock: 9313441 })

    new_events = []
    for (let i=0; i<transaction.length; i++) {
      new_events.push({
        itemId: transaction[i].returnValues.itemId, 
        from: transaction[i].returnValues.fromAddress, 
        to: transaction[i].returnValues.toAddress, 
        value: transaction[i].returnValues.value/1e18, 
        block: transaction[i].blockNumber, 
        hash: transaction[i].transactionHash
      })
    }

    events["ItemBought"].push.apply(events["ItemBought"], new_events)
    events["blockNumber"] = block

    let data = JSON.stringify(events);
    fs.writeFileSync('events-9.json', data);
    

  }
  catch(error) {
    console.log(error)
  }

  callback()
}