



pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.3;


contract PKNPremium {


    uint256 constant LOCK_PERIOD = 365 days;

    mapping(address => uint256) _pknStakedBy;
    mapping(address => uint256) _unlockTimeOf;

    IERC20 public immutable PKN;

    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);
    event Renew(address user, uint256 amount);

    constructor(IERC20 _PKN) {
        PKN = _PKN;
    }

    function pknStackedBy(address user) public view returns(uint256) {

        return _pknStakedBy[user];
    }

    function unlockTimeOf(address user) public view returns(uint256) {

        return _unlockTimeOf[user];
    }

    function isSubscriptionActive(address user) public view returns(bool) {

        return block.timestamp < unlockTimeOf(user);
    }

    function deposit(uint256 _amount) public {

        _unlockTimeOf[msg.sender] = _getUnlockTime(block.timestamp);
        _pknStakedBy[msg.sender] += _amount;
        PKN.transferFrom(msg.sender, address(this), _amount);

        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) public {

        require(pknStackedBy(msg.sender) >= _amount, "PKNPremium: Amount too high!");
        require(!isSubscriptionActive(msg.sender), "PKNPremium: PKN not unlocked yet!");

        _pknStakedBy[msg.sender] -= _amount;
        PKN.transfer(msg.sender, _amount);

        emit Withdraw(msg.sender, _amount);
    }

    function renew() public {

        require(pknStackedBy(msg.sender) > 0, "PKNPremium: No PKN stacked!");

        _unlockTimeOf[msg.sender] = _getUnlockTime(block.timestamp);

        emit Renew(msg.sender, _pknStakedBy[msg.sender]);
    }

    function _getUnlockTime(uint256 startTime) internal pure returns(uint256) {

        return startTime + LOCK_PERIOD;
    }
}