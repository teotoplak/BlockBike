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

    // return id of new bike
    function register(uint price, bytes32 name) public returns (uint) {
        require(price > 0);
        registered.push(Bike({
            price: price,
            owner: msg.sender,
            name: name
        }));
        registered.length - 1;
    }

    // returns price paid. If request is wrong returns 0;
    function rent(uint id, uint timeInHours) public returns (uint) {
        require(id + 1 <= registered.length);
        // user can have only one bike rented at time
        require(checkDeadline() == 0);
        var bike = registered[id];
        var totalPrice = bike.price * timeInHours;
        // approx. enough money on sender (case where returning late included)
        require( totalPrice * 2 < balances[msg.sender]);
        // bike must be free for rental
        for (uint i = 0; i < rentals.length; i++) {
            if(rentals[i].bikeId == id) {
                return 0;
            }
        }
        var futureDeadline = now + (timeInHours * 60);
        rentals.push(Rental({
            deadline: futureDeadline,
            bikeId: id,
            renter: msg.sender
        }));
        balances[msg.sender] -= totalPrice;
        balances[bike.owner] += totalPrice;
        return totalPrice;
    }

    // returns false if there was no bike to return
    function returnBike(uint bikeId) public returns (bool) {
        // find the bike by id
        Rental rental;
        uint rentalIndex;
        bool found = false;
        for (uint i = 0; i < rentals.length; i++) {
            if(rentals[i].bikeId == bikeId) {
                rental = rentals[i];
                rentalIndex = i;
                found = true;
                break;
            }
        }
        if(found == false) return false;
        require(rental.renter == msg.sender);
        if ( now < rental.deadline) {
            removeRental(rentalIndex);
        } else {
            // todo pay late fee
            removeRental(rentalIndex);
        }
        return true;

    }

    function removeRental(uint index) private returns (bool) {
        if (index >= rentals.length) return false;
        for (uint i = index; i<rentals.length-1; i++){
            rentals[i] = rentals[i+1];
        }
        delete rentals[rentals.length-1];
        rentals.length--;
        return true;
    }

    function priceForBike(uint id) public view returns (uint) {
        require(id + 1 >= registered.length);
        return registered[id].price;
    }

    function checkBalance(address addr) public view returns (uint) {
        return balances[addr];
    }

    // returns deadline for calling user rental. if there is none like it returns 0
    function checkDeadline() public view returns (uint) {
        for(uint i = 0; i < rentals.length; i++) {
            if(rentals[i].renter == msg.sender) {
                return rentals[i].deadline;
            }
        }
        return 0;
    }
}
