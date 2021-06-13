const LowbMarket = artifacts.require("LowbMarket");

module.exports = function(deployer) {
  const lowbAddress = '0x5aa1a18432aa60bad7f3057d71d3774f56cd34b8';
  const nftAddress = '0xe031188b0895afd3f3c32b2bf27fbd1ab9e8c9ea'; // Contract address for 'TransparentUpgradeableProxy'
  deployer.deploy(LowbMarket, lowbAddress, nftAddress);
};
