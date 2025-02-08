const AnalysisStorage = artifacts.require("AnalysisStorage");

module.exports = function (deployer) {
  deployer.deploy(AnalysisStorage);
};