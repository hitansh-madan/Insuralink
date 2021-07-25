const Policy = artifacts.require("Policies");

module.exports = function (deployer) {
  deployer.deploy(Policies);
};
