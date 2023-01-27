



pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.5;

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

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;




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


pragma solidity ^0.5.0;



contract IRewardDistributionRecipient is Ownable {

    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward) external;


    modifier onlyRewardDistribution() {

        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
        external
        onlyOwner
    {

        rewardDistribution = _rewardDistribution;
    }
}


pragma solidity ^0.5.0;

contract LPTokenWrapper {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public lpt;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function stake(uint256 amount) public {

        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        lpt.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lpt.safeTransfer(msg.sender, amount);
    }
}

contract OVENPool is LPTokenWrapper, IRewardDistributionRecipient {

    IERC20 public degenPizza;
    uint256 public DURATION;

    uint256 public starttime;
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

    constructor(address _degenPizza, address _lptoken, uint _duration, uint _starttime) public {
        degenPizza  = IERC20(_degenPizza);
        lpt = IERC20(_lptoken);
        DURATION = _duration;
        starttime = _starttime;
    }

    modifier checkStart() {

        require(block.timestamp >= starttime,"not start");
        _;
    }

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
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

    function stake(uint256 amount) public updateReward(msg.sender) checkStart {

        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) checkStart {

        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {

        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkStart {

        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            degenPizza.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function notifyRewardAmount(uint256 reward)
        external
        onlyRewardDistribution
        updateReward(address(0))
    {

        if (block.timestamp > starttime) {
          if (block.timestamp >= periodFinish) {
              rewardRate = reward.div(DURATION);
          } else {
              uint256 remaining = periodFinish.sub(block.timestamp);
              uint256 leftover = remaining.mul(rewardRate);
              rewardRate = reward.add(leftover).div(DURATION);
          }
          lastUpdateTime = block.timestamp;
          periodFinish = block.timestamp.add(DURATION);
          emit RewardAdded(reward);
        } else {
          rewardRate = reward.div(DURATION);
          lastUpdateTime = starttime;
          periodFinish = starttime.add(DURATION);
          emit RewardAdded(reward);
        }
    }
}

contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

interface IUniswapV2Factory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

}






contract DegenPizzaToken is DSMath {

    uint256                                           public  totalSupply;
    mapping (address => uint256)                      public  balanceOf;
    mapping (address => mapping (address => uint256)) public  allowance;
    bytes32                                           public  symbol = "DGP";
    uint256                                           public  decimals = 18;
    bytes32                                           public  name = "DegenPizza";

    constructor(address chef) public {
        totalSupply = 10000000000000000000000000;
        balanceOf[chef] = 10000000000000000000000000;
    }

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event Burn(uint wad);

    function approve(address guy) external returns (bool) {

        return approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public returns (bool) {

        allowance[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }

    function transfer(address dst, uint wad) external returns (bool) {

        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad) public returns (bool) {

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "ds-token-insufficient-approval");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }

        require(balanceOf[src] >= wad, "ds-token-insufficient-balance");
        balanceOf[src] = sub(balanceOf[src], wad);
        uint one = wad / 100;
        uint ninetynine = sub(wad, one);
        balanceOf[dst] = add(balanceOf[dst], ninetynine);
        burn(one);

        emit Transfer(src, dst, wad);

        return true;
    }

    function burn(uint wad) internal {

        totalSupply = sub(totalSupply, wad);
        emit Burn(wad);
    }

    function retrieve(address chef) external view returns (uint256){

        return balanceOf[chef];
    }

}

contract DegenPizzaFactory {

    DegenPizzaToken public degenPizza;
    OVENPool public usdcSeedPool;
    OVENPool public wbtcPool; 
    OVENPool public wethPool; 
    OVENPool public yfvPool; 
    OVENPool public mbnPool;
    OVENPool public usdcPool;
    OVENPool public uniswapPool;
    address public uniswap;
    address owner;
    IUniswapV2Factory public uniswapFactory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    bool public sended;

    constructor() public {
        degenPizza = new DegenPizzaToken(address(this));
        owner = msg.sender;
    }

    function initSEED() public {

        require(address(usdcSeedPool) == address(0), "Already initialized");
        usdcSeedPool = new OVENPool(address(degenPizza), 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 60 hours, now);
        usdcSeedPool.setRewardDistribution(address(this));
        degenPizza.transfer(address(usdcSeedPool), 1000000000000000000000000);
        usdcSeedPool.notifyRewardAmount(degenPizza.balanceOf(address(usdcSeedPool)));
        usdcSeedPool.setRewardDistribution(address(0));
        usdcSeedPool.renounceOwnership();
    }

    function initWBTC() public {

        require(address(wbtcPool) == address(0), "Already initialized");
        wbtcPool = new OVENPool(address(degenPizza), 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, 120 days, now + 48 hours);
        wbtcPool.setRewardDistribution(address(this));
        degenPizza.transfer(address(wbtcPool), 600000000000000000000000);
        wbtcPool.notifyRewardAmount(degenPizza.balanceOf(address(wbtcPool)));
        wbtcPool.setRewardDistribution(address(0));
        wbtcPool.renounceOwnership();
    }

    function initWETH() public {

        require(address(wethPool) == address(0), "Already initialized");
        wethPool = new OVENPool(address(degenPizza), 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, 120 days, now + 48 hours);
        wethPool.setRewardDistribution(address(this));
        degenPizza.transfer(address(wethPool), 600000000000000000000000);
        wethPool.notifyRewardAmount(degenPizza.balanceOf(address(wethPool)));
        wethPool.setRewardDistribution(address(0));
        wethPool.renounceOwnership();
    }

    function initYFV() public {

        require(address(yfvPool) == address(0), "Already initialized");
        yfvPool = new OVENPool(address(degenPizza), 0x45f24BaEef268BB6d63AEe5129015d69702BCDfa, 120 days, now + 48 hours);
        yfvPool.setRewardDistribution(address(this));
        degenPizza.transfer(address(yfvPool), 800000000000000000000000);
        yfvPool.notifyRewardAmount(degenPizza.balanceOf(address(yfvPool)));
        yfvPool.setRewardDistribution(address(0));
        yfvPool.renounceOwnership();
    }

    function initMBN() public {

        require(address(mbnPool) == address(0), "Already initialized");
        mbnPool = new OVENPool(address(degenPizza), 0x4Eeea7B48b9C3ac8F70a9c932A8B1E8a5CB624c7, 120 days, now + 48 hours);
        mbnPool.setRewardDistribution(address(this));
        degenPizza.transfer(address(mbnPool), 400000000000000000000000);
        mbnPool.notifyRewardAmount(degenPizza.balanceOf(address(mbnPool)));
        mbnPool.setRewardDistribution(address(0));
        mbnPool.renounceOwnership();
    }

    function initUSDC() public {

        require(address(usdcPool) == address(0), "Already initialized");
        usdcPool = new OVENPool(address(degenPizza), 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 120 days, now + 48 hours);
        usdcPool.setRewardDistribution(address(this));
        degenPizza.transfer(address(usdcPool), 400000000000000000000000);
        usdcPool.notifyRewardAmount(degenPizza.balanceOf(address(usdcPool)));
        usdcPool.setRewardDistribution(address(0));
        usdcPool.renounceOwnership();
    }

   
    function initUNI() public {

        require(address(uniswapPool) == address(0), "Already initialized");
        uniswap = uniswapFactory.createPair(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, address(degenPizza));
        uniswapPool = new OVENPool(address(degenPizza), uniswap, 120 days, now + 48 hours);
        uniswapPool.setRewardDistribution(address(this));
        degenPizza.transfer(address(uniswapPool), 400000000000000000000000);
        uniswapPool.notifyRewardAmount(degenPizza.balanceOf(address(uniswapPool)));
        uniswapPool.setRewardDistribution(address(0));
        uniswapPool.renounceOwnership();
    }

    function transferToDegenDevs() public {

        require(address(msg.sender) == owner, "You are not allowed to do that!");
        require(sended == false, "Cannot send multiple times");
        sended = true;
        degenPizza.transfer(0x315045A5eA1192d517D89E0880Dd45eEB051e45C, 100000000000000000000000);
    }
    
    function transferRestToForPhase2() public {

        require(address(msg.sender) == owner, "You are not allowed to do that!");
        degenPizza.transfer(msg.sender, degenPizza.retrieve(address(this)));
    }
}