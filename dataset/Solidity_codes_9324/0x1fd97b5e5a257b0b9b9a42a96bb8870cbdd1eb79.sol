
pragma solidity 0.6.12;


library MathUtil {

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }
}

contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

interface ICurveGauge {

    function deposit(uint256) external;

    function balanceOf(address) external view returns (uint256);

    function withdraw(uint256) external;

    function claim_rewards() external;

    function reward_tokens(uint256) external view returns(address);//v2

    function rewarded_token() external view returns(address);//v1

}

interface ICurveVoteEscrow {

    function create_lock(uint256, uint256) external;

    function increase_amount(uint256) external;

    function increase_unlock_time(uint256) external;

    function withdraw() external;

    function smart_wallet_checker() external view returns (address);

}

interface IWalletChecker {

    function check(address) external view returns (bool);

}

interface IVoting{

    function vote(uint256, bool, bool) external; //voteId, support, executeIfDecided

    function getVote(uint256) external view returns(bool,bool,uint64,uint64,uint64,uint64,uint256,uint256,uint256,bytes memory); 

    function vote_for_gauge_weights(address,uint256) external;

}

interface IMinter{

    function mint(address) external;

}

interface IRegistry{

    function get_registry() external view returns(address);

    function get_address(uint256 _id) external view returns(address);

    function gauge_controller() external view returns(address);

    function get_lp_token(address) external view returns(address);

    function get_gauges(address) external view returns(address[10] memory,uint128[10] memory);

}

interface IStaker{

    function deposit(address, address) external;

    function withdraw(address) external;

    function withdraw(address, address, uint256) external;

    function withdrawAll(address, address) external;

    function createLock(uint256, uint256) external;

    function increaseAmount(uint256) external;

    function increaseTime(uint256) external;

    function release() external;

    function claimCrv(address) external returns (uint256);

    function claimRewards(address) external;

    function claimFees(address,address) external;

    function setStashAccess(address, bool) external;

    function vote(uint256,address,bool) external;

    function voteGaugeWeight(address,uint256) external;

    function balanceOfPool(address) external view returns (uint256);

    function operator() external view returns (address);

    function execute(address _to, uint256 _value, bytes calldata _data) external returns (bool, bytes memory);

}

interface IRewards{

    function stake(address, uint256) external;

    function stakeFor(address, uint256) external;

    function withdraw(address, uint256) external;

    function exit(address) external;

    function getReward(address) external;

    function queueNewRewards(uint256) external;

    function notifyRewardAmount(uint256) external;

    function addExtraReward(address) external;

    function stakingToken() external view returns (address);

    function rewardToken() external view returns(address);

    function earned(address account) external view returns (uint256);

}

interface IStash{

    function stashRewards() external returns (bool);

    function processStash() external returns (bool);

    function claimRewards() external returns (bool);

}

interface IFeeDistro{

    function claim() external;

    function token() external view returns(address);

}

interface ITokenMinter{

    function mint(address,uint256) external;

    function burn(address,uint256) external;

}

interface IDeposit{

    function isShutdown() external view returns(bool);

    function balanceOf(address _account) external view returns(uint256);

    function totalSupply() external view returns(uint256);

    function poolInfo(uint256) external view returns(address,address,address,address,address, bool);

    function rewardClaimed(uint256,address,uint256) external;

    function withdrawTo(uint256,uint256,address) external;

    function claimRewards(uint256,address) external returns(bool);

    function rewardArbitrator() external returns(address);

    function setGaugeRedirect(uint256 _pid) external returns(bool);

}

interface ICrvDeposit{

    function deposit(uint256, bool) external;

    function lockIncentive() external view returns(uint256);

}

interface IRewardFactory{

    function setAccess(address,bool) external;

    function CreateCrvRewards(uint256,address) external returns(address);

    function CreateTokenRewards(address,address,address) external returns(address);

    function activeRewardCount(address) external view returns(uint256);

    function addActiveReward(address,uint256) external returns(bool);

    function removeActiveReward(address,uint256) external returns(bool);

}

interface IStashFactory{

    function CreateStash(uint256,address,address,uint256) external returns(address);

}

interface ITokenFactory{

    function CreateDepositToken(address) external returns(address);

}

interface IPools{

    function addPool(address _lptoken, address _gauge, uint256 _stashVersion) external returns(bool);

    function shutdownPool(uint256 _pid) external returns(bool);

    function poolInfo(uint256) external view returns(address,address,address,address,address,bool);

    function poolLength() external view returns (uint256);

    function gaugeMap(address) external view returns(bool);

    function setPoolManager(address _poolM) external;

}

interface IVestedEscrow{

    function fund(address[] calldata _recipient, uint256[] calldata _amount) external returns(bool);

}

pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}


pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity 0.6.12;

interface ISushiRewarder {

    using SafeERC20 for IERC20;
    function onSushiReward(uint256 pid, address user, address recipient, uint256 sushiAmount, uint256 newLpAmount) external;

    function pendingTokens(uint256 pid, address user, uint256 sushiAmount) external view returns (IERC20[] memory, uint256[] memory);

}



pragma solidity 0.6.12;




interface IMasterChefV2 {

    function lpToken(uint i) external view returns (IERC20);

}

interface IConvexChef{

    function userInfo(uint256 _pid, address _account) external view returns(uint256,uint256);

    function claim(uint256 _pid, address _account) external;

    function deposit(uint256 _pid, uint256 _amount) external;

}


contract ConvexRewarder is ISushiRewarder{

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public immutable rewardToken;
    IERC20 public immutable stakingToken;
    uint256 public constant duration = 5 days;

    address public immutable rewardManager;
    address public immutable sushiMasterChef;
    address public immutable convexMasterChef;
    uint256 public immutable chefPid;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public currentRewards = 0;
    uint256 private _totalSupply;
    uint256 public sushiPid;
    uint256 public previousRewardDebt = 0;
    bool public isInit = false;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _sushiBalances;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    address[] public extraRewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(
        address stakingToken_,
        address rewardToken_,
        address rewardManager_,
        address sushiMasterChef_,
        address convexMasterChef_,
        uint256 chefPid_
    ) public {
        stakingToken = IERC20(stakingToken_);
        rewardToken = IERC20(rewardToken_);
        rewardManager = rewardManager_;
        sushiMasterChef = sushiMasterChef_;
        convexMasterChef = convexMasterChef_;
        chefPid = chefPid_;
    }

    function init(IERC20 dummyToken) external {

        require(!isInit,"already init");
        isInit = true;
        uint256 balance = dummyToken.balanceOf(msg.sender);
        require(balance != 0, "Balance must exceed 0");
        dummyToken.safeTransferFrom(msg.sender, address(this), balance);
        dummyToken.approve(convexMasterChef, balance);
        IConvexChef(convexMasterChef).deposit(chefPid, balance);
        initRewards();
    }

    function harvestFromMasterChef() public {

        IConvexChef(convexMasterChef).claim(chefPid, address(this));
        notifyRewardAmount();
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account].add(_sushiBalances[account]);
    }

    function localBalanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function sushiBalanceOf(address account) public view returns (uint256) {

        return _sushiBalances[account];
    }

    function extraRewardsLength() external view returns (uint256) {

        return extraRewards.length;
    }

    function addExtraReward(address _reward) external {

        require(msg.sender == rewardManager, "!authorized");
        require(_reward != address(0),"!reward setting");

        extraRewards.push(_reward);
    }
    function clearExtraRewards() external{

        require(msg.sender == rewardManager, "!authorized");
        delete extraRewards;
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

        return MathUtil.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {

        uint256 supply = totalSupply();
        if (supply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(supply)
            );
    }

    function earned(address account) public view returns (uint256) {

        return
            _balances[account].add(_sushiBalances[account])
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function stake(uint256 _amount)
        public
        updateReward(msg.sender)
    {

        require(_amount > 0, 'RewardPool : Cannot stake 0');

        checkHarvest();

        uint256 length = extraRewards.length;
        for(uint i=0; i < length; i++){
            IRewards(extraRewards[i]).stake(msg.sender, _amount);
        }

        _totalSupply = _totalSupply.add(_amount);
        _balances[msg.sender] = _balances[msg.sender].add(_amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, _amount);
    }

    function stakeAll() external{

        uint256 balance = stakingToken.balanceOf(msg.sender);
        stake(balance);
    }

    function stakeFor(address _for, uint256 _amount)
        public
        updateReward(_for)
    {

        require(_amount > 0, 'RewardPool : Cannot stake 0');

        checkHarvest();

        uint256 length = extraRewards.length;
        for(uint i=0; i < length; i++){
            IRewards(extraRewards[i]).stake(_for, _amount);
        }

        _totalSupply = _totalSupply.add(_amount);
        _balances[_for] = _balances[_for].add(_amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, _amount);
    }

    function withdraw(uint256 _amount, bool claim)
        public
        updateReward(msg.sender)
    {

        require(_amount > 0, 'RewardPool : Cannot withdraw 0');

        uint256 length = extraRewards.length;
        for(uint i=0; i < length; i++){
            IRewards(extraRewards[i]).withdraw(msg.sender, _amount);
        }

        _totalSupply = _totalSupply.sub(_amount);
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
        stakingToken.safeTransfer(msg.sender, _amount);
        emit Withdrawn(msg.sender, _amount);

        if(claim){
            getReward(msg.sender,true);
        }
    }

    function withdrawAll(bool claim) external{

        withdraw(_balances[msg.sender],claim);
    }

    function getReward(address _account, bool _claimExtras) public updateReward(_account){


        uint256 reward = earned(_account);
        if (reward > 0) {
            rewards[_account] = 0;
            rewardToken.safeTransfer(_account, reward);
            emit RewardPaid(_account, reward);
        }

        if(_claimExtras){
            uint256 length = extraRewards.length;
            for(uint i=0; i < length; i++){
                IRewards(extraRewards[i]).getReward(_account);
            }
        }

        checkHarvest();
    }

    function getReward() external{

        getReward(msg.sender,true);
    }

    function checkHarvest() internal{

        if (periodFinish > 0 && block.timestamp >= periodFinish.sub(1 days)  ) {
            harvestFromMasterChef();
        }
    }

    function initRewards() internal updateReward(address(0)){

        uint256 reward = rewardToken.balanceOf(address(this));
        
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(duration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            reward = reward.add(leftover);
            rewardRate = reward.div(duration);
        }
        currentRewards = reward;
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(duration);
        emit RewardAdded(reward);
    }

    function notifyRewardAmount()
        internal
        updateReward(address(0))
    {

        if(!isInit){
            return;
        }
        (,uint256 rewardDebt) = IConvexChef(convexMasterChef).userInfo(chefPid, address(this));
        uint256 reward = rewardDebt.sub(previousRewardDebt);
        previousRewardDebt = rewardDebt;
        if(reward == 0) return;
        
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(duration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            reward = reward.add(leftover);
            rewardRate = reward.div(duration);
        }
        currentRewards = reward;
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(duration);
        emit RewardAdded(reward);
    }

    function onSushiReward(
        uint256 pid,
        address user,
        address recipient,
        uint256 sushiAmount,
        uint256 newLpAmount
    )
        override
        external
        updateReward(user)
    {

        require(msg.sender == sushiMasterChef);
      
        uint256 _sushiPid = sushiPid;
        if (_sushiPid == 0) {
            require(IMasterChefV2(msg.sender).lpToken(pid) == stakingToken);
            sushiPid = pid;
        } else {
            require(pid == _sushiPid);
        }

        if (sushiAmount > 0) {

            getReward(user,true);
        }

        uint256 userBalance = _sushiBalances[user];
        if (newLpAmount > userBalance) {
            uint256 amount = newLpAmount.sub(userBalance);
            uint256 length = extraRewards.length;
            for(uint i=0; i < length; i++){
                IRewards(extraRewards[i]).stake(user, amount);
            }
            _totalSupply = _totalSupply.add(amount);
            _sushiBalances[user] = newLpAmount;

        } else if (newLpAmount < userBalance) {
            uint256 amount = userBalance.sub(newLpAmount);
            uint256 length = extraRewards.length;
            for(uint i=0; i < length; i++){
                IRewards(extraRewards[i]).withdraw(msg.sender, amount);
            }
            _totalSupply = _totalSupply.sub(amount);
            _sushiBalances[user] = newLpAmount;
        }
    }

    function pendingTokens(
        uint256 pid,
        address user,
        uint256 sushiAmount
    )
        override
        external
        view
        returns (IERC20[] memory, uint256[] memory)
    {

        uint256 length = extraRewards.length;

        IERC20[] memory rewardTokens = new IERC20[](1+length);
        rewardTokens[0] = rewardToken;
        for(uint i=0; i < length; i++){
           rewardTokens[1+i] = IERC20(IRewards(extraRewards[i]).rewardToken());
        }
        uint256[] memory earnedAmounts = new uint256[](1+length);
        earnedAmounts[0] = earned(user);
        for(uint i=0; i < length; i++){
            earnedAmounts[1+i] = IRewards(extraRewards[i]).earned(user);
        }
        return (rewardTokens,earnedAmounts);
    }
}