// migrations/2_deploy_nft.js
const MyCollectible = artifacts.require('MyCollectible');
 
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
 
module.exports = async function (deployer) {
  await deployProxy(MyCollectible, [], { deployer, initializer: 'initialize' });
};