// migrations/7_deploy_NFTCollection.js
const NFTCollection = artifacts.require('NFTCollection');
const fs = require('fs');
const address = fs.readFileSync("./../.address").toString().trim();

module.exports = async function (deployer) {
  await deployer.deploy(NFTCollection);
};