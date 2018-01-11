var Rentals = artifacts.require("./Rentals.sol");

module.exports = function(deployer, network, accounts) {

    deployer.deploy(Rentals);

};
