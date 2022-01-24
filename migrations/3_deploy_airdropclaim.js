const LowbMarket = artifacts.require("AirdropClaim");
const fs = require('fs');
const address = fs.readFileSync("./../.address").toString().trim();

module.exports = function(deployer) {
  deployer.deploy(LowbMarket, address);
};
