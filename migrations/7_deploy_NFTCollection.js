// migrations/7_deploy_NFTCollection.js
const NFTCollection = artifacts.require('NFTCollection');
const NFTMarketplace = artifacts.require('NFTMarketplace');

module.exports = async function (deployer) {
  await deployer.deploy(NFTCollection);
  const nftCollection = await NFTCollection.deployed();

  await deployer.deploy(NFTMarketplace, nftCollection.address);
};