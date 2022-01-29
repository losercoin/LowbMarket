const { expectRevert } = require('@openzeppelin/test-helpers');

const NFTCollection = artifacts.require('./NFTCollection.sol');

contract('NFTCollection', (accounts) => {
  let contract;

  before(async () => {
    contract = await NFTCollection.new();
  });

  describe('deployment', () => {
    it('deploys successfully', async () => {
      const address = contract.address;
      assert.notEqual(address, 0x0);
      assert.notEqual(address, '');
      assert.notEqual(address, null);
      assert.notEqual(address, undefined);
    });

    it('has a name', async() => {
      const name = await contract.name();
      assert.equal(name, 'Lowb Collection');
    });

    it('has a symbol', async() => {
      const symbol = await contract.symbol();
      assert.equal(symbol, 'Lowb');
    });
  });

  describe('minting', () => {
    it('success minting', async() => {
      let tokenId = '0x50f795e30cf64123e37f9fb94e9b502329171dab801aa49efa88d1ad3b2a6b7d';
      let uri = 'QmYUhZHM4ZcWF13q1gCd6steet6xFrcDa8QzDR6uoY8aXe';
      let name = "My NFT";
      let description = "My NFT is Testing";
      const result = await contract.safeMint(tokenId, uri, name, description);
      const totalSupply = await contract.totalSupply();

      assert.equal(totalSupply, 1);
      const event = result.logs[0].args;
      assert.equal(event.tokenId, Number(tokenId), 'id is correct');
      assert.equal(event.from, '0x0000000000000000000000000000000000000000', 'from is correct');
      assert.equal(event.to, accounts[0], 'to is correct');
    });
  });
})