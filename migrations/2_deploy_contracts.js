const LowbMarket = artifacts.require("LowbMarket");

module.exports = function(deployer) {
  const lowbAddress = '0x5aa1a18432aa60bad7f3057d71d3774f56cd34b8';
  const nftAddress = '0xdeaC04eff4d484A94D9caABf8AefcC6380296dB0'; // Contract address for 'TransparentUpgradeableProxy'
  deployer.deploy(LowbMarket, lowbAddress, nftAddress);
};
