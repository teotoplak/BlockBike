pragma solidity ^0.4.0;

contract Rentals {

    struct Bike {
        uint price;
        address owner;
        bytes32 name;
    }

    struct Rental {
        uint deadline;
        uint bikeId;
        address renter;
    }

    mapping (address => uint) balances;


    address owner;

    Bike[] public registered;
    Rental[] public rentals;

    function Rentals() public {
        owner = msg.sender;
    }

    function giveMoney(uint amount, address receiver) public {
        require(owner == msg.sender);
        balances[receiver] += amount;
    }

    function register(uint price, bytes32 name) public {
        registered.push(Bike({
            price: price,
            owner: msg.sender,
            name: name
        }));
    }

    function rent(uint id, uint time) public returns (bool) {
        require(id + 1 >= registered.length);
        var bike = registered[id];
        // todo consider time here
        var totalPrice = bike.price;
        // approx. enough money on sender
        require( totalPrice < balances[msg.sender]);
        // bike must be free for rental
        for (uint i = 0; i < rentals.length; i++) {
            if(rentals[i].bikeId == id) {
                return false;
            }
        }
        var futureDeadline = now + time;
        rentals.push(Rental({
            deadline: futureDeadline,
            bikeId: id,
            renter: msg.sender
        }));
        balances[msg.sender] -= totalPrice;
        balances[bike.owner] += totalPrice;
        return true;
    }



    function priceForBike(uint id) public view returns (uint) {
        require(id + 1 >= registered.length);
        return registered[id].price;
    }

    function checkBalance(address addr) public view returns (uint) {
        return balances[addr];
    }

}
