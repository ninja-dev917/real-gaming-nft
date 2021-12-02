const TheNewResistance = artifacts.require("TheNewResistance");

module.exports = function (deployer) {
  deployer.deploy(TheNewResistance, "The New Resistance" , "TNR", "https://gateway.pinata.cloud/ipfs/QmdGsRvYvN3RQ6wLc75aYpQv1njkXWSqwEhpLs2Cg4MZ6b/");
};
