


pragma solidity 0.5.15;

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


pragma solidity 0.5.15;

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


pragma solidity 0.5.15;

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


pragma solidity 0.5.15;

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


pragma solidity 0.5.15;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);

    function mint(address account, uint amount) external;


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity 0.5.15;

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


pragma solidity 0.5.15;




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


pragma solidity 0.5.15;



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


pragma solidity 0.5.15;



interface MasterChef {

    function deposit(uint256, uint256) external;

    function withdraw(uint256, uint256) external;

    function emergencyWithdraw(uint256) external;

}

interface SushiBar {

    function enter(uint256) external;

    function leave(uint256) external;

}

contract LPTokenWrapper is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public slp = IERC20(0x0F82E57804D0B1F6FAb2370A43dcFAd3c7cB239c);
    IERC20 public yam = IERC20(0x0AaCfbeC6a24756c20D41914F2caba817C0d8521);
    address public reserves = address(0x97990B693835da58A281636296D2Bf02787DEa17);

    IERC20 public sushi = IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    SushiBar public sushibar = SushiBar(0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272);
    MasterChef public masterchef = MasterChef(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);
    uint256 public pid = 44; // YAM/ETH pool id
    bool public chefEmergency;

    constructor () internal {
        slp.approve(address(masterchef), uint256(-1));
    }

    uint256 public minBlockBeforeVoting;
    bool public minBlockSet;

    uint256 private _totalSupply;

    uint256 public constant BASE = 10**18;

    mapping(address => uint256) private _balances;


    mapping(address => address) public delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 lpStake;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    mapping (uint32 => Checkpoint) public totalSupplyCheckpoints;

    uint32 public numSupplyCheckpoints;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function delegate(address delegatee) public {

        _delegate(msg.sender, delegatee);
    }

    function _delegate(address delegator, address delegatee)
        internal
    {

        address currentDelegate = delegates[msg.sender];
        uint256 delegatorBalance = _balances[msg.sender];
        delegates[msg.sender] = delegatee;

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {

        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].lpStake : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].lpStake : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepNew);
            }
        }
    }


    function stake(uint256 amount) public {

        _totalSupply = _totalSupply.add(amount);
        uint256 new_bal = _balances[msg.sender].add(amount);
        _balances[msg.sender] = new_bal;
        address delegate = delegates[msg.sender];
        if (delegate == address(0)) {
          delegates[msg.sender] = msg.sender;
          delegate = msg.sender;
        }
        _moveDelegates(address(0), delegate, amount);
        _writeSupplyCheckpoint();
        slp.safeTransferFrom(msg.sender, address(this), amount);
        depositToMasterChef(amount);
    }

    function withdraw(uint256 amount) public {

        _totalSupply = _totalSupply.sub(amount);
        uint256 new_bal = _balances[msg.sender].sub(amount);
        _balances[msg.sender] = new_bal;
        _moveDelegates(delegates[msg.sender], address(0), amount);
        _writeSupplyCheckpoint();
        withdrawFromMasterChef(amount);
        slp.safeTransfer(msg.sender, amount);
    }

    function depositToMasterChef(uint256 amount) internal {

        if (!chefEmergency) {
            masterchef.deposit(pid, amount);
        }
    }

    function withdrawFromMasterChef(uint256 amount) internal {

        if (!chefEmergency) {
            masterchef.withdraw(pid, amount);
        }
    }

    function sweepToXSushi() public {

        masterchef.withdraw(pid, 0);
        uint256 sushi_bal = sushi.balanceOf(address(this));
        if (sushi.allowance(address(this), address(sushibar)) < sushi_bal) {
            sushi.approve(address(sushibar), uint256(-1));
        }
        sushibar.enter(sushi_bal);
    }

    function sushiToReserves(uint256 xsushi_amt) public {

        require(owner() == msg.sender, "!owner");

        if (xsushi_amt == uint256(-1)) {
          xsushi_amt = IERC20(address(sushibar)).balanceOf(address(this));
        }

        sushibar.leave(xsushi_amt);
        sushi.transfer(reserves, sushi.balanceOf(address(this)));
    }

    function setReserves(address newReserves) public {

        require(owner() == msg.sender, "!owner");
        reserves = newReserves;
    }

    function emergencyMasterChefWithdraw() public {

        require(owner() == msg.sender, "!owner");
        masterchef.emergencyWithdraw(pid);
        chefEmergency = true;
    }

    function reenableChef() public {

        require(owner() == msg.sender, "!owner");
        require(chefEmergency, "!emergency");
        masterchef.deposit(pid, slp.balanceOf(address(this)));
        chefEmergency = false;
    }

    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {

        if (!minBlockSet || block.number < minBlockBeforeVoting) {
            return 0;
        }
        uint256 poolVotes = YAM(address(yam)).getCurrentVotes(address(slp));
        uint32 nCheckpoints = numCheckpoints[account];
        uint256 lpStake = nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].lpStake : 0;
        uint256 percOfVotes = lpStake.mul(BASE).div(_totalSupply);
        return poolVotes.mul(percOfVotes).div(BASE);
    }

    function getPriorVotes(address account, uint256 blockNumber)
        public
        view
        returns (uint256)
    {

        require(blockNumber < block.number, "Incentivizer::getPriorVotes: not yet determined");
        if (!minBlockSet || blockNumber < minBlockBeforeVoting) {
            return 0;
        }
        uint256 poolVotes = YAM(address(yam)).getPriorVotes(address(slp), blockNumber);

        if (poolVotes == 0) {
            return 0;
        }

        uint256 priorStake = _getPriorLPStake(account, blockNumber);

        if (priorStake == 0) {
            return 0;
        }

        uint256 lpTotalSupply = getPriorSupply(blockNumber);

        if (lpTotalSupply == 0) {
            return 0;
        }

        uint256 percentOfVote = priorStake.mul(BASE).div(lpTotalSupply);

        return poolVotes.mul(percentOfVote).div(BASE);
    }

    function getPriorLPStake(address account, uint256 blockNumber)
        public
        view
        returns (uint256)
    {

        require(blockNumber < block.number, "Incentivizer::_getPriorLPStake: not yet determined");
        return _getPriorLPStake(account, blockNumber);
    }

    function _getPriorLPStake(address account, uint256 blockNumber)
        internal
        view
        returns (uint256)
    {

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].lpStake;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.lpStake;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].lpStake;
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 newStake
    )
        internal
    {

        uint32 blockNumber = safe32(block.number, "Incentivizer::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].lpStake = newStake;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newStake);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }
    }

    function _writeSupplyCheckpoint()
        internal
    {

        uint32 blockNumber = safe32(block.number, "Incentivizer::_writeSupplyCheckpoint: block number exceeds 32 bits");

        if (numSupplyCheckpoints > 0 && totalSupplyCheckpoints[numSupplyCheckpoints - 1].fromBlock == blockNumber) {
            totalSupplyCheckpoints[numSupplyCheckpoints - 1].lpStake = _totalSupply;
        } else {
            totalSupplyCheckpoints[numSupplyCheckpoints] = Checkpoint(blockNumber, _totalSupply);
            numSupplyCheckpoints += 1;
        }
    }

    function getPriorSupply(uint256 blockNumber)
        public
        view
        returns (uint256)
    {

        if (numSupplyCheckpoints == 0) {
            return 0;
        }

        if (totalSupplyCheckpoints[numSupplyCheckpoints - 1].fromBlock <= blockNumber) {
            return totalSupplyCheckpoints[numSupplyCheckpoints - 1].lpStake;
        }

        if (totalSupplyCheckpoints[0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = numSupplyCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = totalSupplyCheckpoints[center];
            if (cp.fromBlock == blockNumber) {
                return cp.lpStake;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return totalSupplyCheckpoints[lower].lpStake;
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function setMinBlockBeforeVoting(uint256 blockNum)
        external
    {

        require(msg.sender == owner(), "!governance");
        require(!minBlockSet, "minBlockSet");
        minBlockBeforeVoting = blockNum;
        minBlockSet = true;
    }
}

interface YAM {

    function yamsScalingFactor() external returns (uint256);

    function mint(address to, uint256 amount) external;

    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256);

    function getCurrentVotes(address account) external view returns (uint256);

}

contract YAMIncentivizerWithVoting is LPTokenWrapper, IRewardDistributionRecipient {

    uint256 public constant DURATION = 7 days;

    uint256 public initreward = 5000 * 10**18; // 5000 yams
    uint256 public starttime = 1605204000; //  Thursday, November 12, 2020 18:00:00 GMT

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    bool public initialized = false;
    bool public breaker;


    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;


    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

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

        return Math.max(starttime, Math.min(block.timestamp, periodFinish));
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

    function stake(uint256 amount) public updateReward(msg.sender) checkhalve {

        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {

        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {

        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkhalve {

        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            uint256 scalingFactor = YAM(address(yam)).yamsScalingFactor();
            uint256 trueReward = reward.mul(scalingFactor).div(10**18);
            yam.safeTransfer(msg.sender, trueReward);
            emit RewardPaid(msg.sender, trueReward);
        }
    }

    modifier checkhalve() {

        if (breaker) {
        } else if (block.timestamp >= periodFinish && initialized) {
            uint256 scalingFactor = YAM(address(yam)).yamsScalingFactor();
            uint256 newRewards = initreward.mul(scalingFactor).div(10**18);
            yam.mint(address(this), newRewards);
            lastUpdateTime = block.timestamp;
            rewardRate = initreward.div(DURATION);
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(newRewards);
        }
        _;
    }

    function notifyRewardAmount(uint256 reward)
        external
        onlyRewardDistribution
        updateReward(address(0))
    {

        require(reward < uint256(-1) / 10**22, "rewards too large, would lock");
        if (block.timestamp > starttime && initialized) {
          if (block.timestamp >= periodFinish) {
              rewardRate = reward.div(DURATION);
          } else {
              uint256 remaining = periodFinish.sub(block.timestamp);
              uint256 leftover = remaining.mul(rewardRate);
              rewardRate = reward.add(leftover).div(DURATION);
          }
          lastUpdateTime = block.timestamp;
          periodFinish = block.timestamp.add(DURATION);
          uint256 scalingFactor = YAM(address(yam)).yamsScalingFactor();
          uint256 newRewards = reward.mul(scalingFactor).div(10**18);
          emit RewardAdded(newRewards);
        } else {
          require(initreward < uint256(-1) / 10**22, "rewards too large, would lock");
          require(!initialized, "already initialized");
          initialized = true;
          uint256 scalingFactor = YAM(address(yam)).yamsScalingFactor();
          uint256 newRewards = initreward.mul(scalingFactor).div(10**18);
          yam.mint(address(this), newRewards);
          rewardRate = initreward.div(DURATION);
          lastUpdateTime = starttime;
          periodFinish = starttime.add(DURATION);
          emit RewardAdded(newRewards);
        }
    }


    function rescueTokens(IERC20 _token, uint256 amount, address to)
        external
    {

        require(msg.sender == owner(), "!governance");
        require(_token != slp, "slp");
        require(_token != yam, "yam");

        _token.safeTransfer(to, amount);
    }

    function setBreaker(bool breaker_)
        external
    {

        require(msg.sender == owner(), "!governance");
        breaker = breaker_;
    }
}