

pragma solidity ^0.5.13;

contract ERC20 {

    uint256 public totalSupply;

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);


    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Ownable {

    address public owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function renounceOwnership() public onlyOwner {

        owner = address(0);
        emit OwnershipRenounced(owner);
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {

        require(_newOwner != address(0));
        owner = _newOwner;
        emit OwnershipTransferred(owner, _newOwner);
    }
}

contract KauriStaking is Ownable {


    event TokensStaked(address stakedBy, address stakedFor, uint256 time, uint256 duration, uint256 amount);
    event TokensUnstaked(address staker, uint256 time, uint256 amount, uint256 remaining);

    ERC20 public token;

    struct Staked {
        uint256 time;
        uint256 duration;
        uint256 amount;
    }

    mapping(address => Staked) private stakedTokens;

    constructor(ERC20 _token) public {
        token = _token;
    }

    function stakeTokens(uint256 _amount, uint256 _duration) public {

        require(stakedTokens[msg.sender].amount == 0, "some tokens are already staked for this address");
        token.transferFrom(msg.sender, address(this), _amount);
        stakedTokens[msg.sender] = Staked(now, _duration, _amount);
        emit TokensStaked(msg.sender, msg.sender, now, _duration, _amount);
    }

    function stakeTokensFor(address _staker, uint256 _amount, uint256 _duration) public onlyOwner {

        require(stakedTokens[_staker].amount == 0, "some tokens are already staked for this address");
        token.transferFrom(msg.sender, address(this), _amount);
        stakedTokens[_staker] = Staked(now, _duration, _amount);
        emit TokensStaked(msg.sender, _staker, now, _duration, _amount);
    }

    function withdrawTokens(uint256 _amount) public {

        Staked memory staked = stakedTokens[msg.sender];
        require(!isLocked(now, staked.time, staked.duration), "tokens are still locked");
        require(staked.amount > 0, "no staked tokens to withdraw");

        uint256 toWithdaw = _amount;
        if(toWithdaw > staked.amount){
            toWithdaw = staked.amount;
        }

        token.transfer(msg.sender, toWithdaw);
        if(staked.amount == toWithdaw){
            stakedTokens[msg.sender] = Staked(0, 0, 0);
        } else {
            stakedTokens[msg.sender] = Staked(staked.time, staked.duration, staked.amount - toWithdaw);
        }
        emit TokensUnstaked(msg.sender, now, toWithdaw, staked.amount - toWithdaw);
    }

    function isLocked(uint256 _now, uint256 _time, uint256 _duration) internal pure returns (bool) {

        return _now >= _time + _duration ? false:true;
    }

    function stakedDetails(address _staker) public view returns (uint256, uint256, uint256, bool) {

        Staked memory staked = stakedTokens[_staker];
        return (staked.time,
        staked.duration,
        staked.amount,
        isLocked(now, staked.time, staked.duration));
    }
}