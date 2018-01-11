pragma solidity ^0.4.0;

contract Rentals {

    struct Bike {
        uint price;
        address owner;
        bytes32 name;
    }

    Bike[] public registered;

    function register(uint price, bytes32 name) public {
        registered.push(Bike({
            price: price,
            owner: msg.sender,
            name: name
        }));
    }

    function listNames() returns(uint) {
        return registered.length;
    }

}
