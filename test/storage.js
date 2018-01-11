// Specifically request an abstraction for MetaCoin
var Storage = artifacts.require("Storage");

contract('Storage', function(accounts) {
    it("should return 0 first", function() {
        return Storage.deployed().then(function(instance) {
            return instance.get.call();
        }).then(function(balance) {
            assert.equal(balance.valueOf(), 0, "didn't start with 0");
        });
    });
    it("should make a transfer of 40", function() {
        var instance;
        return Storage.deployed().then(function(insta) {
            instance = insta;
            return instance.set.sendTransaction(40);
        }).then(function(balance) {
            return instance.get.call();
        }).then(function(balance) {
            assert.equal(balance.valueOf(), 40, "not 40 after transfer")
        })
    });
});