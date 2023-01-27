
pragma solidity ^0.7.0;

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
}// MIT

pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// Copyright 2020 Cartesi Pte. Ltd.



pragma solidity ^0.7.0;

interface Staking {


    function getStakedBalance(
        address _userAddress) external view returns (uint256);


    function getMaturingTimestamp(address _userAddress) external view returns (uint256);


    function getReleasingTimestamp(address _userAddress) external view returns (uint256);



    function getMaturingBalance(address _userAddress) external view  returns (uint256);


    function getReleasingBalance(address _userAddress) external view  returns (uint256);



    function stake(uint256 _amount) external;


    function unstake(uint256 _amount) external;


    function withdraw(uint256 _amount) external;


    event Stake(
        address indexed user,
        uint256 amount,
        uint256 maturationDate
    );

    event Unstake(
        address indexed user,
        uint256 amount,
        uint256 maturationDate
    );

    event Withdraw(
        address indexed user,
        uint256 amount
    );
}// Copyright 2020 Cartesi Pte. Ltd.



pragma solidity ^0.7.0;



contract StakingImpl is Staking {

    using SafeMath for uint256;
    IERC20 private ctsi;

    uint256 timeToStake; // time it takes for deposited tokens to become staked.
    uint256 timeToRelease; // time it takes from witdraw signal to tokens to be unlocked.

    mapping(address => uint256) staked; // amount of money being staked.
    mapping(address => MaturationStruct) maturing; // deposits waiting to be staked.
    mapping(address => MaturationStruct) releasing; // money waiting for withdraw.

    struct MaturationStruct {
        uint256 amount;
        uint256 timestamp;
    }

    constructor(
        address _ctsiAddress,
        uint256 _timeToStake,
        uint256 _timeToRelease
    ) {
        ctsi = IERC20(_ctsiAddress);
        timeToStake = _timeToStake;
        timeToRelease = _timeToRelease;
    }

    function stake(uint256 _amount) public override {

        require(_amount > 0, "amount cant be zero");

        MaturationStruct storage r = releasing[msg.sender];
        MaturationStruct storage m = maturing[msg.sender];

        if (m.timestamp.add(timeToStake) <= block.timestamp) {
            staked[msg.sender] = staked[msg.sender].add(m.amount);
            m.amount = 0;
        }

        if (r.amount >= _amount) {
            r.amount = (r.amount).sub(_amount);
        } else {
            ctsi.transferFrom(msg.sender, address(this), _amount.sub(r.amount));
            r.amount = 0;

        }

        m.amount = (m.amount).add(_amount);
        m.timestamp = block.timestamp;

        emit Stake(
            msg.sender,
            m.amount,
            block.timestamp.add(timeToStake)
        );
    }

    function unstake(uint256 _amount) public override {

        require(_amount > 0, "amount cant be zero");

        MaturationStruct storage r = releasing[msg.sender];
        MaturationStruct storage m = maturing[msg.sender];

        if (m.amount >= _amount) {
            m.amount = (m.amount).sub(_amount);
        } else {
            staked[msg.sender] = staked[msg.sender].sub(_amount.sub(m.amount));
            m.amount = 0;
        }
        r.amount = (r.amount).add(_amount);
        r.timestamp = block.timestamp;

        emit Unstake(
            msg.sender,
            r.amount,
            block.timestamp.add(timeToRelease)
        );
    }

    function withdraw(uint256 _amount) public override {

        MaturationStruct storage r = releasing[msg.sender];

        require(_amount > 0, "amount cant be zero");
        require(
            r.timestamp.add(timeToRelease) <= block.timestamp,
            "tokens are not yet ready to be released"
        );

        r.amount = (r.amount).sub(_amount, "not enough tokens waiting to be released;");

        ctsi.transfer(msg.sender, _amount);
        emit Withdraw(msg.sender, _amount);
    }

    function getMaturingTimestamp(
        address _userAddress
    )
    public
    view override
    returns (uint256)
    {

        return maturing[_userAddress].timestamp.add(timeToStake);
    }

    function getMaturingBalance(
        address _userAddress
    )
    public
    view override
    returns (uint256)
    {

        MaturationStruct storage m = maturing[_userAddress];

        if (m.timestamp.add(timeToStake) <= block.timestamp) {
            return 0;
        }

        return m.amount;
    }

    function getReleasingBalance(
        address _userAddress
    )
    public
    view override
    returns (uint256)
    {

        return releasing[_userAddress].amount;
    }

    function getReleasingTimestamp(
        address _userAddress
    )
    public
    view override
    returns (uint256)
    {

        return releasing[_userAddress].timestamp.add(timeToRelease);
    }

    function getStakedBalance(address _userAddress)
    public
    view override
    returns (uint256)
    {

        MaturationStruct storage m = maturing[_userAddress];

        if (m.timestamp.add(timeToStake) <= block.timestamp) {
            return staked[_userAddress].add(m.amount);
        }

        return staked[_userAddress];
    }
}