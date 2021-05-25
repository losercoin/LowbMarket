const LowbMarket = artifacts.require("LowbMarket");

module.exports = function(deployer) {
  const lowbAddress = '0x5aa1a18432aa60bad7f3057d71d3774f56cd34b8';
  const nftAddress = '0x934a36DFe9F071Fb92220Ca4238d61B726F85FB9'; // Contract address for 'TransparentUpgradeableProxy'
  deployer.deploy(LowbMarket, lowbAddress, nftAddress);
};
