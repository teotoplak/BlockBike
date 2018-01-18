pragma solidity ^0.4.0;

contract Rentals {

    struct Bike {
        uint price;
        address owner;
        bytes32 name;
        uint bikeId;
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
    uint public latestBikeId = 0;

    event LogRegister(address indexed _owner, uint indexed _bikeId, uint _price);
    event LogReturn(uint indexed _bikeId, uint indexed _time, uint _additionalPrice);
    event LogRent(uint indexed _bikeId, address indexed _renter, uint _deadline, uint _price);


    function Rentals() public {
        owner = msg.sender;
    }

    function giveMoney(uint amount, address receiver) public {
        require(owner == msg.sender);
        balances[receiver] += amount;
    }

    // return id of new bike
    function register(uint price, bytes32 name) public {
        require(price > 0);
        registered.push(Bike({
            price: price,
            owner: msg.sender,
            name: name,
            bikeId: latestBikeId
        }));
        LogRegister(msg.sender,latestBikeId,price);
        latestBikeId++;
    }

    function rent(uint id, uint timeInSeconds) public returns (bool) {
        // user can have only one bike LogRent at time
        require(checkDeadline() == 0);
        // cause of error "Assignment necessary for type detection."
        var bike = registered[0];
        bool found = false;
        for(uint i = 0; i < registered.length; i++) {
            if(registered[i].bikeId == id) {
                bike = registered[i];
                found = true;
                break;
            }
        }
        require(found == true);
        var totalPrice = bike.price * timeInSeconds;
        // approx. enough money on sender (case where returning late included)
        require( totalPrice * 2 < balances[msg.sender]);
        // bike must be free for rental
        for (i = 0; i < rentals.length; i++) {
            if(rentals[i].bikeId == id) {
                // todo handle errors correctly
                return false;
            }
        }
        var futureDeadline = now + timeInSeconds;
        rentals.push(Rental({
            deadline: futureDeadline,
            bikeId: id,
            renter: msg.sender
        }));
        balances[msg.sender] -= totalPrice;
        balances[bike.owner] += totalPrice;
        LogRent(id,msg.sender,futureDeadline,totalPrice);
        return true;
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
        var returningTime = now;
        if ( returningTime < rental.deadline) {
            removeRental(rentalIndex);
            LogReturn(bikeId, returningTime, 0);
        } else {
            // find bike
            var bike = registered[0];
            for(i = 0; i < registered.length; i++) {
                if(registered[i].bikeId == bikeId) {
                    bike = registered[i];
                    break;
                }
            }
            var secondsLate = (returningTime - rental.deadline);
            // if late double the rental fee per hour
            var additionalPrice = secondsLate * bike.price * 2;
            balances[msg.sender] -= additionalPrice;
            balances[bike.owner] += additionalPrice;
            removeRental(rentalIndex);
            LogReturn(bikeId, returningTime, additionalPrice);
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
