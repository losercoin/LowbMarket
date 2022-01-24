const LowbMarketHelper = artifacts.require("LowbMarketHelper");
const fs = require('fs');
const address = fs.readFileSync("./../.address").toString().trim();

module.exports = function(deployer) {
  deployer.deploy(LowbMarketHelper, address);
};
