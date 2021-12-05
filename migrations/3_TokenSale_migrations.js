const ERC20Token = artifacts.require("DappTokenSale.sol");
const Token = artifacts.require("DappToken.sol");

module.exports = function (deployer) {
  deployer.deploy(ERC20Token);
};
