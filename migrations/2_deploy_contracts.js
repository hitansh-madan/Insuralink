const Policy = artifacts.require("Policy");

module.exports = function (deployer) {
  deployer.deploy(Policy);
};
