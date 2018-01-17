// Specifically request an abstraction for MetaCoin
var Rentals = artifacts.require("Rentals");

contract('Rentals', function(accounts) {
    var instance;
    const firstUserMoney = 1000;
    const secondUserMoney = 2000;
    it("should give 1000 to second user", function() {
        return Rentals.deployed().then(function(inst) {
            instance = inst;
            return instance.giveMoney(1000,web3.eth.accounts[1])
        }).then(function(result) {
            return instance.checkBalance(web3.eth.accounts[1]);
        }).then(function(result) {
            assert.equal(result.valueOf(), 1000, "not 1000 after transfer")
        })
    });
    it("should give 2000 to owner", function() {
        return instance.giveMoney(2000,web3.eth.accounts[0])
            .then(function(result) {
                return instance.checkBalance(web3.eth.accounts[0]);
        }).then(function(result) {
            assert.equal(result.valueOf(), 2000, "not 2000 after transfer")
        })
    });
    it("should register new bike (price 50) with second account", function() {
        return instance.register(50,'HellRide', {from: web3.eth.accounts[1]})
            .then(function(result) {
                return instance.priceForBike(0);
        }).then(function(result) {
            assert.equal(result.valueOf(), 50, "not price 50 after register")
        })
    });
    it("rent registered bike", function() {
        return instance.rent(0, 5, {from: web3.eth.accounts[0]})
            .then(function(result) {
                return instance.checkBalance(web3.eth.accounts[0]);
        }).then(function(result) {
            assert.equal(result.valueOf(), 1750, "renter does not correspond!")
        }).then(function(result) {
                return instance.checkBalance(web3.eth.accounts[1]);
        }).then(function(result) {
            assert.equal(result.valueOf(), 1250, "renter does not correspond!")
        })
    });
    it("return rented bike", function() {
        return instance.returnBike(0, {from: web3.eth.accounts[0]})
            .then(function(result) {
                return instance.checkDeadline();
        }).then(function(result) {
                assert.equal(result.valueOf(), 0, "rental not removed!")
        })
    });

});