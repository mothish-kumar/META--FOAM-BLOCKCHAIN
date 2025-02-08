const DesignSupportStorage = artifacts.require("DesignerSupport");

module.exports = function (deployer) {
  deployer.deploy(DesignSupportStorage);
};