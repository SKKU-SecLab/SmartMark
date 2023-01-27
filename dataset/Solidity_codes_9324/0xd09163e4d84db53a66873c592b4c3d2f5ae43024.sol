

pragma solidity ^0.6.0;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

contract EscrowConnect {

    enum State {MIDDLEMAN_NOT_DECLARED, MIDDLEMAN_DECLARED, CONFIRMED, RELEASED}
    State public currState;

    struct Middleman {
        address middleman;
        bool alreadyDeclared;
        bool middleManConfirmed;
    }

    event Deposit(address sender, uint256 amount);
    event Received(address, uint256);
    event Withdraw(address middleman, address dev, uint256 amount);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    address payable public middleman;
    address payable public dev;
    bool public alreadyDeclared;
    bool public middlemanConfirmedWithdraw;
    uint256 private middlemanCommission = 2;
    uint256 private devPercentage = 100;

    modifier onlyMiddleman() {

        require(msg.sender == middleman, "Only Middleman can call this method");
        _;
    }

    modifier onlyDev() {

        require(msg.sender == dev, "Only Dev can call this method");
        _;
    }

    constructor(address payable _dev) public {
        dev = _dev;
    }

    function renounceMiddleman(address payable newMiddleman)
        external
        onlyMiddleman
    {

        require(
            alreadyDeclared == true,
            "This function can only be called by middleman"
        );
        currState = State.MIDDLEMAN_DECLARED;
        middleman = newMiddleman;
        middlemanConfirmedWithdraw = false;
    }

    function setMiddleman(address payable declareMiddleman) external onlyDev {

        require(alreadyDeclared == false, "Middleman already declared");
        currState = State.MIDDLEMAN_DECLARED;
        middleman = declareMiddleman;
        alreadyDeclared = true;
    }

    function confirmToRelease() external onlyMiddleman {

        require(
            currState == State.MIDDLEMAN_DECLARED,
            "This function can be only called by middleman!"
        );
        currState = State.CONFIRMED;
        middlemanConfirmedWithdraw = true;
    }

    function releaseFunds() external onlyDev {

        require(
            currState == State.CONFIRMED,
            "Middleman did not confirm to release"
        );
        middleman.transfer((address(this).balance * middlemanCommission / 100));
        dev.transfer((address(this).balance * devPercentage / 100));
        currState = State.RELEASED;
    }

    function resetState() external onlyDev {

        require(currState == State.RELEASED, "Only dev can call this method");
        currState = State.MIDDLEMAN_DECLARED;
        middlemanConfirmedWithdraw = false;
    }
}