const XloopTokenTmp = artifacts.require("XloopTokenTmp");
const XloopFactory = artifacts.require("XloopFactory");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(XloopTokenTmp, { from: accounts[1] });
  deployer.deploy(XloopFactory, { from: accounts[0] });
};
