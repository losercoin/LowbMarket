const LowbMarket = artifacts.require("LowbMarket");

module.exports = function(deployer) {
  const lowbAddress = '0x5aa1a18432aa60bad7f3057d71d3774f56cd34b8';
  const nftAddress = '0x33a8c50b066e74d2110d39ba4a97f20b22bb4042'; // Contract address for 'TransparentUpgradeableProxy'
  deployer.deploy(LowbMarket, lowbAddress, nftAddress);
};
