// migrations/7_deploy_NFTCollection.js
const NFTCollection = artifacts.require('NFTCollection');
const NFTMarketplace = artifacts.require('NFTMarketplace');

module.exports = async function (deployer) {
  await deployer.deploy(NFTCollection);
  const nftCollection = await NFTCollection.deployed();

  await deployer.deploy(NFTMarketplace, nftCollection.address, '0x5aa1a18432aa60bad7f3057d71d3774f56cd34b8');
};