// Specifically request an abstraction for MetaCoin
var Rentals = artifacts.require("Rentals");

contract('Rentals', function(accounts) {
    var instance;
    const firstUserMoney = 2000;
    const secondUserMoney = 1000;
    const bikePrice = 50;
    const bikeName = "HellRide";
    var generatedBikeId;
    const firstUserAccount = web3.eth.accounts[0];
    const secondUserAccount = web3.eth.accounts[1];
    const secondsToRent = 5;

    it("should give money to second user", function() {
        return Rentals.deployed().then(function(inst) {
            instance = inst;
            return instance.giveMoney(secondUserMoney,secondUserAccount)
        }).then(function(result) {
            return instance.checkBalance(secondUserAccount);
        }).then(function(result) {
            assert.equal(result.valueOf(), secondUserMoney, "not correct amount after transfer")
        })
    });
    it("should give money to fist user", function() {
        return instance.giveMoney(firstUserMoney,firstUserAccount)
            .then(function(result) {
                return instance.checkBalance(firstUserAccount);
        }).then(function(result) {
            assert.equal(result.valueOf(), firstUserMoney, "not correct after transfer")
        })
    });
    it("should register new bike with second account", function() {
        return instance.register(bikePrice, bikeName, {from: secondUserAccount})
            .then(function(result) {
                assert.equal(result.logs[0].args._price.valueOf(), bikePrice, "not price 50 after register");
                assert.equal(result.logs[0].args._owner.valueOf(), secondUserAccount, "not price 50 after register");
                generatedBikeId = result.logs[0].args._bikeId;
        })
    });
    it("rent registered bike", function() {
        var priceForRental = bikePrice * secondsToRent;
        return instance.rent(generatedBikeId, secondsToRent, {from: firstUserAccount})
            .then(function(result) {
                // console.log(result.logs[0].args._deadline.valueOf());
                return instance.checkBalance(firstUserAccount);
        }).then(function(result) {
            assert.equal(result.valueOf(), firstUserMoney - priceForRental, "renter does not correspond!")
        }).then(function(result) {
                return instance.checkBalance(secondUserAccount);
        }).then(function(result) {
            assert.equal(result.valueOf(), secondUserMoney + priceForRental, "renter does not correspond!")
        })
    });
    it("return rented bike", function () {
        return instance.returnBike(generatedBikeId, {from: firstUserAccount})
            .then(function (result) {
                // console.log(result.logs[0].args._time.valueOf());
                // console.log(result.logs[0].args._additionalPrice.valueOf());
                assert.equal(result.logs[0].args._additionalPrice.valueOf(), 0, "rental not removed!")
            })
    });

});