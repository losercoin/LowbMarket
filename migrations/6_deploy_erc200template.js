const ERC20Template = artifacts.require("ERC20Template");
const fs = require('fs');
const address = fs.readFileSync("./../.address").toString().trim();

module.exports = function(deployer) {
  deployer.deploy(ERC20Template, address, address, 'loser coin', 'lowb', 18);
};
