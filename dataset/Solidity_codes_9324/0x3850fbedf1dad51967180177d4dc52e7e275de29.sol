

contract StablePoolProxy  {


    address public owner;
    address public implementation;
        
    constructor(address _impl) public {
        owner = msg.sender;
        implementation = _impl;
    }

    function setImplementation(address _newImpl) public {

        require(msg.sender == owner);

        implementation = _newImpl;
    }
   
    fallback() external {
        address impl = implementation;
        assembly {
            let ptr := mload(0x40)
 
            calldatacopy(ptr, 0, calldatasize())
 
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
 
            returndatacopy(ptr, 0, size)
 
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }   
    }
}





pragma solidity ^0.6.0;



library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


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


pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.6.5;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value:amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.6.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.6.0;



abstract contract IRewardDistributionRecipient {
    address public rewardDistribution;

    constructor(address _rewardDistribution) public {
        rewardDistribution = _rewardDistribution;
    }

    function notifyRewardAmount(uint256 reward) virtual external;

    modifier onlyRewardDistribution() {
        require(msg.sender == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
        external
        onlyRewardDistribution
    {
        rewardDistribution = _rewardDistribution;
    }
}


pragma solidity ^0.6.0;





contract LPTokenWrapper {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public lpToken;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function stake(uint256 amount) virtual public {

        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        lpToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) virtual public {

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lpToken.safeTransfer(msg.sender, amount);
    }
}


contract NoMintRewardPool is StablePoolProxy, LPTokenWrapper, IRewardDistributionRecipient {


    using Address for address;

    IERC20 public rewardToken;
    uint256 public duration; // making it not a constant is less gas efficient, but portable

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardDenied(address indexed user, uint256 reward);

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
    
    constructor() public 
        IRewardDistributionRecipient(address(0))
        StablePoolProxy(address(0)) {
        
    }

    function setReward(address _rewardToken,
        address _lpToken,
        uint256 _duration,
        address _rewardDistribution) public
    {

        require(address(lpToken) == address(0));
        rewardToken = IERC20(_rewardToken);
        lpToken = IERC20(_lpToken);
        duration = _duration;
        rewardDistribution = _rewardDistribution;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {

        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {

        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function stake(uint256 amount) override public updateReward(msg.sender) {

        require(amount > 0, "Cannot stake 0");
        super.stake(amount);

        initStorage(msg.sender, amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) override public updateReward(msg.sender) {

        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {

        withdrawUni(msg.sender);
        withdraw(balanceOf(msg.sender));
        getReward(false);
    }

    function getReward(bool isUni) public updateReward(msg.sender) {

        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            if (tx.origin == msg.sender) {
                rewardToken.safeTransfer(msg.sender, reward);
                emit RewardPaid(msg.sender, reward);
            } else {
                emit RewardDenied(msg.sender, reward);
            }
        }

        if (isUni) {
            claimUni(msg.sender);
        }
    }

    function notifyRewardAmount(uint256 reward)
        override
        external
        onlyRewardDistribution
        updateReward(address(0))
    {

        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(duration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(duration);
        }
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(duration);
        emit RewardAdded(reward);
    }

    address constant uniEthDaiLpToken  = 0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11;
    address constant uniEthUSDCLpToken = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;
    address constant uniEthUsdtLpToken = 0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852;
    address constant uniEthWBTCLpToken = 0xBb2b8038a1640196FbE3e38816F3e67Cba72D940;

    address constant uniEthDaiPool  = 0xa1484C3aa22a66C62b77E0AE78E15258bd0cB711;
    address constant uniEthUSDCPool = 0x7FBa4B8Dc5E7616e59622806932DBea72537A56b;
    address constant uniEthUsdtPool = 0x6C3e4cb2E96B01F4b866965A91ed4437839A121a;
    address constant uniEthWBTCPool = 0xCA35e32e7926b96A9988f61d510E038108d8068e;

    mapping(address => address) public userStorage;

    modifier onlyActiveStorage(address userAdddress) { 

        if(userStorage[userAdddress] == address(0)) {
            return;
        } 
        _; 
    }
    
    function initStorage(address userAdddress, uint lpTokenAmount) internal {

        if(userStorage[userAdddress] == address(0)) {
            bool res = createStorage(userAdddress);
            if (!res) {
                return;
            }
        }

        stakeLpToUni(userAdddress, lpTokenAmount);
    }

    function createStorage(address userAdddress) internal returns(bool) {

        address _poolAddress = findUniPool(address(lpToken));
        if (_poolAddress == address(0)) {
            return false;
        }
        
        PoolStorage str = new PoolStorage(userAdddress, address(lpToken), _poolAddress);
        userStorage[userAdddress] = address(str);
        
        return true;
    }

    function stakeLpToUni(address userAdddress, uint amount) internal onlyActiveStorage(userAdddress) {

        lpToken.transfer(userStorage[userAdddress], amount);
        PoolStorage(userStorage[userAdddress]).stake(amount);
    }

    function claimUni(address userAdddress) internal onlyActiveStorage(userAdddress) {

        PoolStorage(userStorage[userAdddress]).claim();
    }

    function withdrawUni(address userAdddress) internal onlyActiveStorage(userAdddress) {

        PoolStorage(userStorage[userAdddress]).exit();
    }


    function findUniPool(address _lpTokenAddress) public pure returns(address) {

        if (_lpTokenAddress == uniEthDaiLpToken) {
            return uniEthDaiPool;
        }
        
        if (_lpTokenAddress == uniEthUSDCLpToken) {
            return uniEthUSDCPool;
        }
        
        if (_lpTokenAddress == uniEthUsdtLpToken) {
            return uniEthUsdtPool;
        }
        
        if (_lpTokenAddress == uniEthWBTCLpToken) {
            return uniEthWBTCPool;
        }
    }
}

abstract contract IUNI {
    function stake(uint256 amount) virtual external;
    function getReward() virtual public;
    function withdraw(uint256 amount) virtual public;
    function exit() virtual public;
}

contract PoolStorage {


    uint public constant MAX_UINT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    address public userAddress;
    address public poolAddress;

    IERC20 public lpToken;
    IERC20 public uniToken = IERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
    
    IUNI public uni;

    modifier onlyPool() { 

        require(msg.sender == poolAddress); 
        _; 
    }

    constructor(address _userAddress, address _lpToken, address _uniDepositAddress) public {
        userAddress = _userAddress;
        poolAddress = msg.sender;
        lpToken = IERC20(_lpToken);
        uni = IUNI(_uniDepositAddress);

        lpToken.approve(address(uni), MAX_UINT);
    }

    function stake(uint amount) public onlyPool {

        uni.stake(amount);
    }

    function claim() public onlyPool {

        uni.getReward();
        transferUNI();
    }

    function exit() public onlyPool {

        uni.exit();
        transferUNI();

        uint lpBalance = lpToken.balanceOf(address(this));

        if (lpBalance > 0) {
            lpToken.transfer(poolAddress, lpBalance);
        }
    }

    function transferUNI() private {

        uint balance = uniToken.balanceOf(address(this));

        if (balance > 0) {
            uniToken.transfer(userAddress, balance);
        }
    }
}