const MyContract = artifacts.require("Forwarder");

module.exports = function (deployer) {
  deployer.deploy(MyContract);
};