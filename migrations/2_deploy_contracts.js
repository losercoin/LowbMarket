const LowbMarket = artifacts.require("LowbMarket");

module.exports = function(deployer) {
  const walletAddress = '0x568903F6A2CE809ac14E189cF31dD27992A1E4Bc';
  deployer.deploy(LowbMarket, walletAddress);
};
