

pragma solidity 0.4.11;


contract Ownable {

    address public owner;

    function Ownable() {

        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {

        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract Token {


    function totalSupply() constant returns (uint supply) {}


    function balanceOf(address _owner) constant returns (uint balance) {}


    function transfer(address _to, uint _value) returns (bool success) {}


    function transferFrom(address _from, address _to, uint _value) returns (bool success) {}


    function approve(address _spender, uint _value) returns (bool success) {}


    function allowance(address _owner, address _spender) constant returns (uint remaining) {}


    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract SafeMath {

    function safeMul(uint a, uint b) internal constant returns (uint) {

        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal constant returns (uint) {

        uint c = a / b;
        return c;
    }

    function safeSub(uint a, uint b) internal constant returns (uint) {

        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal constant returns (uint) {

        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {

        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {

        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {

        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {

        return a < b ? a : b;
    }
}

contract VestingWallet is Ownable, SafeMath {


    mapping(address => VestingSchedule) public schedules;        // vesting schedules for given addresses
    mapping(address => address) public addressChangeRequests;    // requested address changes

    Token vestingToken;

    event VestingScheduleRegistered(
        address indexed registeredAddress,
        address depositor,
        uint startTimeInSec,
        uint cliffTimeInSec,
        uint endTimeInSec,
        uint totalAmount
    );
    event VestingScheduleConfirmed(
        address indexed registeredAddress,
        address depositor,
        uint startTimeInSec,
        uint cliffTimeInSec,
        uint endTimeInSec,
        uint totalAmount
    );
    event Withdrawal(address indexed registeredAddress, uint amountWithdrawn);
    event VestingEndedByOwner(address indexed registeredAddress, uint amountWithdrawn, uint amountRefunded);
    event AddressChangeRequested(address indexed oldRegisteredAddress, address indexed newRegisteredAddress);
    event AddressChangeConfirmed(address indexed oldRegisteredAddress, address indexed newRegisteredAddress);

    struct VestingSchedule {
        uint startTimeInSec;
        uint cliffTimeInSec;
        uint endTimeInSec;
        uint totalAmount;
        uint totalAmountWithdrawn;
        address depositor;
        bool isConfirmed;
    }

    modifier addressRegistered(address target) {

        VestingSchedule storage vestingSchedule = schedules[target];
        require(vestingSchedule.depositor != address(0));
        _;
    }

    modifier addressNotRegistered(address target) {

        VestingSchedule storage vestingSchedule = schedules[target];
        require(vestingSchedule.depositor == address(0));
        _;
    }

    modifier vestingScheduleConfirmed(address target) {

        VestingSchedule storage vestingSchedule = schedules[target];
        require(vestingSchedule.isConfirmed);
        _;
    }

    modifier vestingScheduleNotConfirmed(address target) {

        VestingSchedule storage vestingSchedule = schedules[target];
        require(!vestingSchedule.isConfirmed);
        _;
    }

    modifier pendingAddressChangeRequest(address target) {

        require(addressChangeRequests[target] != address(0));
        _;
    }

    modifier pastCliffTime(address target) {

        VestingSchedule storage vestingSchedule = schedules[target];
        require(block.timestamp > vestingSchedule.cliffTimeInSec);
        _;
    }

    modifier validVestingScheduleTimes(uint startTimeInSec, uint cliffTimeInSec, uint endTimeInSec) {

        require(cliffTimeInSec >= startTimeInSec);
        require(endTimeInSec >= cliffTimeInSec);
        _;
    }

    modifier addressNotNull(address target) {

        require(target != address(0));
        _;
    }

    function VestingWallet(address _vestingToken) {

        vestingToken = Token(_vestingToken);
    }

    function registerVestingSchedule(
        address _addressToRegister,
        address _depositor,
        uint _startTimeInSec,
        uint _cliffTimeInSec,
        uint _endTimeInSec,
        uint _totalAmount
    )
        public
        onlyOwner
        addressNotNull(_depositor)
        vestingScheduleNotConfirmed(_addressToRegister)
        validVestingScheduleTimes(_startTimeInSec, _cliffTimeInSec, _endTimeInSec)
    {

        schedules[_addressToRegister] = VestingSchedule({
            startTimeInSec: _startTimeInSec,
            cliffTimeInSec: _cliffTimeInSec,
            endTimeInSec: _endTimeInSec,
            totalAmount: _totalAmount,
            totalAmountWithdrawn: 0,
            depositor: _depositor,
            isConfirmed: false
        });

        VestingScheduleRegistered(
            _addressToRegister,
            _depositor,
            _startTimeInSec,
            _cliffTimeInSec,
            _endTimeInSec,
            _totalAmount
        );
    }

    function confirmVestingSchedule(
        uint _startTimeInSec,
        uint _cliffTimeInSec,
        uint _endTimeInSec,
        uint _totalAmount
    )
        public
        addressRegistered(msg.sender)
        vestingScheduleNotConfirmed(msg.sender)
    {

        VestingSchedule storage vestingSchedule = schedules[msg.sender];

        require(vestingSchedule.startTimeInSec == _startTimeInSec);
        require(vestingSchedule.cliffTimeInSec == _cliffTimeInSec);
        require(vestingSchedule.endTimeInSec == _endTimeInSec);
        require(vestingSchedule.totalAmount == _totalAmount);

        vestingSchedule.isConfirmed = true;
        require(vestingToken.transferFrom(vestingSchedule.depositor, address(this), _totalAmount));

        VestingScheduleConfirmed(
            msg.sender,
            vestingSchedule.depositor,
            _startTimeInSec,
            _cliffTimeInSec,
            _endTimeInSec,
            _totalAmount
        );
    }

    function withdraw()
        public
        vestingScheduleConfirmed(msg.sender)
        pastCliffTime(msg.sender)
    {

        VestingSchedule storage vestingSchedule = schedules[msg.sender];

        uint totalAmountVested = getTotalAmountVested(vestingSchedule);
        uint amountWithdrawable = safeSub(totalAmountVested, vestingSchedule.totalAmountWithdrawn);
        vestingSchedule.totalAmountWithdrawn = totalAmountVested;

        if (amountWithdrawable > 0) {
            require(vestingToken.transfer(msg.sender, amountWithdrawable));
            Withdrawal(msg.sender, amountWithdrawable);
        }
    }

    function endVesting(address _addressToEnd, address _addressToRefund)
        public
        onlyOwner
        vestingScheduleConfirmed(_addressToEnd)
        addressNotNull(_addressToRefund)
    {

        VestingSchedule storage vestingSchedule = schedules[_addressToEnd];

        uint amountWithdrawable = 0;
        uint amountRefundable = 0;

        if (block.timestamp < vestingSchedule.cliffTimeInSec) {
            amountRefundable = vestingSchedule.totalAmount;
        } else {
            uint totalAmountVested = getTotalAmountVested(vestingSchedule);
            amountWithdrawable = safeSub(totalAmountVested, vestingSchedule.totalAmountWithdrawn);
            amountRefundable = safeSub(vestingSchedule.totalAmount, totalAmountVested);
        }

        delete schedules[_addressToEnd];
        require(amountWithdrawable == 0 || vestingToken.transfer(_addressToEnd, amountWithdrawable));
        require(amountRefundable == 0 || vestingToken.transfer(_addressToRefund, amountRefundable));

        VestingEndedByOwner(_addressToEnd, amountWithdrawable, amountRefundable);
    }

    function requestAddressChange(address _newRegisteredAddress)
        public
        vestingScheduleConfirmed(msg.sender)
        addressNotRegistered(_newRegisteredAddress)
        addressNotNull(_newRegisteredAddress)
    {

        addressChangeRequests[msg.sender] = _newRegisteredAddress;
        AddressChangeRequested(msg.sender, _newRegisteredAddress);
    }

    function confirmAddressChange(address _oldRegisteredAddress, address _newRegisteredAddress)
        public
        onlyOwner
        pendingAddressChangeRequest(_oldRegisteredAddress)
        addressNotRegistered(_newRegisteredAddress)
    {

        address newRegisteredAddress = addressChangeRequests[_oldRegisteredAddress];
        require(newRegisteredAddress == _newRegisteredAddress);    // prevents race condition

        VestingSchedule memory vestingSchedule = schedules[_oldRegisteredAddress];
        schedules[newRegisteredAddress] = vestingSchedule;

        delete schedules[_oldRegisteredAddress];
        delete addressChangeRequests[_oldRegisteredAddress];

        AddressChangeConfirmed(_oldRegisteredAddress, _newRegisteredAddress);
    }

    function getTotalAmountVested(VestingSchedule vestingSchedule)
        internal
        returns (uint)
    {

        if (block.timestamp >= vestingSchedule.endTimeInSec) return vestingSchedule.totalAmount;

        uint timeSinceStartInSec = safeSub(block.timestamp, vestingSchedule.startTimeInSec);
        uint totalVestingTimeInSec = safeSub(vestingSchedule.endTimeInSec, vestingSchedule.startTimeInSec);
        uint totalAmountVested = safeDiv(
            safeMul(timeSinceStartInSec, vestingSchedule.totalAmount),
            totalVestingTimeInSec
        );

        return totalAmountVested;
    }

    function balanceOf(address _registeredAddress) public constant returns (uint) {

        VestingSchedule memory vestingSchedule = schedules[_registeredAddress];
        return safeSub(vestingSchedule.totalAmount, vestingSchedule.totalAmountWithdrawn);
    }
}