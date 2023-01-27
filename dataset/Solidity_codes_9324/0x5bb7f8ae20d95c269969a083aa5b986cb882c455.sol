

pragma solidity 0.8.0;




contract BusStation {


    mapping(address => uint256) public _seats;
    bool public _hasBusLeft;
    uint256 public _ticketTotalValue;
    uint256 public _minTicketValue = 0;
    uint256 public _maxTicketValue;
    uint256 public _minWeiToLeave;
    address payable private _destination;

    uint256 public _timelockDuration;
    uint256 public _endOfTimelock;




    constructor(
        address payable destination,
        uint256 minWeiToLeave,
        uint256 timelockSeconds,
        uint256 maxTicketValue
    ) {
        _hasBusLeft = false;
        _minWeiToLeave = minWeiToLeave;
        _maxTicketValue = maxTicketValue;
        _destination = destination;
        _timelockDuration = timelockSeconds;
        _endOfTimelock = block.timestamp + _timelockDuration;
    }


    function buyBusTicket() external payable canPurchaseTicket {

        uint256 seatvalue = _seats[msg.sender];
        require(
            msg.value + seatvalue <= _maxTicketValue,
            "Cannot exceed max ticket value."
        );
        _seats[msg.sender] = msg.value + seatvalue;
        _ticketTotalValue += msg.value;
    }

    function triggerBusRide() external isReadyToRide {

        uint256 amount = _ticketTotalValue;
        _ticketTotalValue = 0;
        _hasBusLeft = true;
        _destination.transfer(amount);
    }

    function withdraw() external {

        require(_hasBusLeft == false, "Bus has already left.");

        uint256 amount = _seats[msg.sender];
        require(amount > 0, "Address does not have a ticket.");

        _seats[msg.sender] = 0;
        _ticketTotalValue -= amount;
        payable(msg.sender).transfer(amount);
    }


    modifier canPurchaseTicket() {

        require(_hasBusLeft == false, "The bus already left.");
        require(msg.value > _minTicketValue, "Need to pay more for ticket.");
        _;
    }

    modifier isReadyToRide() {

        require(_endOfTimelock <= block.timestamp, "Function is timelocked.");
        require(_hasBusLeft == false, "Bus is already gone.");
        require(_ticketTotalValue >= _minWeiToLeave, "Not enough wei to leave.");
        _;
    }
}