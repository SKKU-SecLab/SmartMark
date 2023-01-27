
pragma solidity ^0.5.15;
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
contract IERC20 {

    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract NMTLiquidityReward {

    using SafeMath for uint256;
    address public UNITokenAddr;
    address public PassTokenAddr;
    mapping (address => uint256) depositAmount;
    mapping (address => uint256) depositTime;
    mapping (address => uint256) rewardAmount;
    address[] public stakers;
    uint256 public rewardPercent;
    address public owner;
    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }
    event DepositUNIToken(address indexed account, uint256 amount, uint256 time);
    event WithdrawUNIToken(address indexed account, uint256 amount, uint256 time);
    event ClaimReward(address indexed account, uint256 amount, uint256 time);
    constructor(address UNITokenAddress, address _PassTokenAddr, uint256 _rewardPercent) public {
        owner = msg.sender;
        UNITokenAddr = UNITokenAddress;
        PassTokenAddr = _PassTokenAddr;
        rewardPercent = _rewardPercent;
    }
    function setOwner(address _owner) public onlyOwner {

        require(_owner != address(0x0));
        owner = _owner;
    }
    function reward(address user) public view returns (uint256 reward) {

        return rewardAmount[user];
    }
    function stakedAmount(address user) public view returns (uint256 stakedAmount) {

        return depositAmount[user];
    }
     function stakedTime(address user) public view returns (uint256 time) {

        return depositTime[user];
    }
    function depositUNIToken(uint256 _amount) public {

        require(IERC20(UNITokenAddr).allowance(msg.sender, address(this)) >= _amount, "Reward Pool:INSUFFICIENT UNI-V2 TOKEN AMOUNT");
        IERC20(UNITokenAddr).transferFrom(msg.sender, address(this), _amount);
        if (depositAmount[msg.sender] == 0 ) {
            stakers.push(msg.sender);
        }
        depositAmount[msg.sender] = depositAmount[msg.sender].add(_amount);
        depositTime[msg.sender] = now;
        emit DepositUNIToken(msg.sender, _amount, now);
    }
    function withdrawUNIToken() public {

        require(now >= depositTime[msg.sender] + 3 days, "Reward Pool: LockTime is not over");
        require(depositAmount[msg.sender] > 0, "Reward Pool: INSUFFICIENT Amount");
        rewardAmount[msg.sender] = depositAmount[msg.sender].mul(rewardPercent).div(100) * ((now - depositTime[msg.sender]).div(1 days));
        IERC20(UNITokenAddr).transfer(msg.sender, depositAmount[msg.sender]);
        depositAmount[msg.sender] = 0;
        emit WithdrawUNIToken(msg.sender,  depositAmount[msg.sender], now);
    }
    function claimReward() public {

        require(rewardAmount[msg.sender] > 0, "Reward Pool: INSUFFICIENT NMT AMOUNT");
        IERC20(PassTokenAddr).transfer(msg.sender, rewardAmount[msg.sender]);
        rewardAmount[msg.sender] = 0;
        emit ClaimReward(msg.sender, rewardAmount[msg.sender], now);
    }
}