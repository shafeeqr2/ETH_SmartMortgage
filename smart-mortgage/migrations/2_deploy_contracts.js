var Adoptions = artifacts.require("Adoption");

module.exports = function(deployer) {
  deployer.deploy(Adoptions);
};
