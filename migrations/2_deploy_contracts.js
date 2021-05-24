const LowbMarket = artifacts.require("LowbMarket");

module.exports = function(deployer) {
  const lowbAddress = '0xE0802Bb01bfF99ED5f627979EABAb10f0317Fa1E';
  const nftAddress = '0xa4efDb406f771DEf3f4f1F651F8BDaa39C526ea1'; // Contract address for 'TransparentUpgradeableProxy'
  deployer.deploy(LowbMarket, lowbAddress, nftAddress);
};
