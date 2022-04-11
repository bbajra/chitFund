const Capitalization = artifacts.require("Capitalization");
const ChitFund = artifacts.require("ChitFund");
const ChitFundFactory = artifacts.require("ChitFundFactory");

module.exports = function (deployer) {
  deployer.deploy(Capitalization, "Capital", 10, 1, 1, "CHITFUNDREP", "CHIT");
  deployer.deploy(ChitFund, "Kiran_ChitFund", 1, 3, 3);
  deployer.deploy(ChitFundFactory);
};
