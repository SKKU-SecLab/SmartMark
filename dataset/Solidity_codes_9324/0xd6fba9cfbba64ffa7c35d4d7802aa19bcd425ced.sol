pragma solidity 0.8.9;



interface ICurveGauge {

    function deposit(uint256) external;

    function balanceOf(address) external view returns (uint256);

    function withdraw(uint256) external;

    function claim_rewards() external;

    function reward_tokens(uint256) external view returns(address);//v2

    function rewarded_token() external view returns(address);//v1

    function lp_token() external view returns(address);

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

interface IVoting {

    function vote(uint256, bool, bool) external; //voteId, support, executeIfDecided

    function getVote(uint256) external view returns(bool,bool,uint64,uint64,uint64,uint64,uint256,uint256,uint256,bytes memory);

    function vote_for_gauge_weights(address,uint256) external;

}

interface IMinter {

    function mint(address) external;

}

interface IRegistry {

    function get_registry() external view returns(address);

    function get_address(uint256 _id) external view returns(address);

    function gauge_controller() external view returns(address);

    function get_lp_token(address) external view returns(address);

    function get_gauges(address) external view returns(address[10] memory,uint128[10] memory);

}

interface IStaker {

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

interface IRewards {

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

interface IStash {

    function stashRewards() external returns (bool);

    function processStash() external returns (bool);

    function claimRewards() external returns (bool);

    function initialize(uint256 _pid, address _operator, address _staker, address _gauge, address _rewardFactory) external;

}

interface IFeeDistro {

    function claim() external;

    function token() external view returns(address);

}

interface ITokenMinter{

    function mint(address,uint256) external;

    function burn(address,uint256) external;

}

interface IDeposit {

    function isShutdown() external view returns(bool);

    function balanceOf(address _account) external view returns(uint256);

    function totalSupply() external view returns(uint256);

    function poolInfo(uint256) external view returns(address,address,address,address,address, bool);

    function rewardClaimed(uint256,address,uint256) external;

    function withdrawTo(uint256,uint256,address) external;

    function claimRewards(uint256,address) external returns(bool);

    function rewardArbitrator() external returns(address);

    function setGaugeRedirect(uint256 _pid) external returns(bool);

    function owner() external returns(address);

}

interface ICrvDeposit {

    function deposit(uint256, bool) external;

    function lockIncentive() external view returns(uint256);

}

interface IRewardFactory {

    function setAccess(address,bool) external;

    function CreateCrvRewards(uint256,address) external returns(address);

    function CreateTokenRewards(address,address,address) external returns(address);

    function CreateFeePool(address,address) external returns(address);

    function activeRewardCount(address) external view returns(uint256);

    function addActiveReward(address,uint256) external returns(bool);

    function removeActiveReward(address,uint256) external returns(bool);

}

interface IStashFactory {

    function CreateStash(uint256,address,address,uint256) external returns(address);

}

interface ITokenFactory {

    function CreateDepositToken(address) external returns(address);

}

interface IPools {

    function addPool(address _lptoken, address _gauge, uint256 _stashVersion) external returns(bool);

    function setLiquidityLimit(uint256 _pid, uint256 _limit) external;

    function shutdownPool(uint256 _pid) external returns(bool);

    function poolInfo(uint256) external view returns(address,address,address,address,address,bool);

    function poolLength() external view returns (uint256);

    function gaugeMap(address) external view returns(bool);

    function setPoolManager(address _poolM) external;

}

interface IVestedEscrow {

    function fund(address[] calldata _recipient, uint256[] calldata _amount) external returns(bool);

}

interface IProxyFactory {

    function clone(address _target) external returns(address);

}

interface ISmartWalletWhitelist {

    function approveWallet(address _wallet) external;

}

interface IGaugeController {

    function get_gauge_weight(address _gauge) external view returns(uint256);

    function gauge_relative_weight(address _gauge) external view returns(uint256);

    function vote_user_slopes(address,address) external view returns(uint256,uint256,uint256);//slope,power,end

}

interface IVault {

    function collaterals(address asset, address owner) external view returns(uint256);

}

interface IRewardHook {

    function onRewardClaim() external;

}

interface IBurner {

    function withdraw_admin_fees(address) external;

    function burn(address) external;

    function execute() external returns(bool);

}

interface IPreDepositChecker {

    function canDeposit(address, uint, uint) external view returns(bool);

}// MIT

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
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.8.9;





contract BaseRewardPool {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public rewardToken;
    IERC20 public stakingToken;
    uint256 public constant duration = 7 days;

    address public operator;
    address public rewardManager;

    uint256 public pid;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public queuedRewards = 0;
    uint256 public currentRewards = 0;
    uint256 public historicalRewards = 0;
    uint256 public constant newRewardRatio = 830;
    uint256 private _totalSupply;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) private _balances;

    address[] public extraRewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(
        uint256 pid_,
        address stakingToken_,
        address rewardToken_,
        address operator_,
        address rewardManager_
    ) {
        pid = pid_;
        stakingToken = IERC20(stakingToken_);
        rewardToken = IERC20(rewardToken_);
        operator = operator_;
        rewardManager = rewardManager_;
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function extraRewardsLength() external view returns (uint256) {

        return extraRewards.length;
    }

    function addExtraReward(address _reward) external returns(bool){

        require(msg.sender == rewardManager, "!authorized");
        require(_reward != address(0),"!reward setting");

        extraRewards.push(_reward);
        return true;
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

    function stake(uint256 _amount)
        public
        updateReward(msg.sender)
        returns(bool)
    {

        require(_amount > 0, 'RewardPool : Cannot stake 0');

        for(uint i=0; i < extraRewards.length; i++){
            IRewards(extraRewards[i]).stake(msg.sender, _amount);
        }

        _totalSupply = _totalSupply.add(_amount);
        _balances[msg.sender] = _balances[msg.sender].add(_amount);

        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit Staked(msg.sender, _amount);


        return true;
    }

    function stakeAll() external returns(bool){

        uint256 balance = stakingToken.balanceOf(msg.sender);
        stake(balance);
        return true;
    }

    function stakeFor(address _for, uint256 _amount)
        public
        updateReward(_for)
        returns(bool)
    {

        require(_amount > 0, 'RewardPool : Cannot stake 0');

        for(uint i=0; i < extraRewards.length; i++){
            IRewards(extraRewards[i]).stake(_for, _amount);
        }

        _totalSupply = _totalSupply.add(_amount);
        _balances[_for] = _balances[_for].add(_amount);

        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit Staked(_for, _amount);

        return true;
    }


    function withdraw(uint256 amount, bool claim)
        public
        updateReward(msg.sender)
        returns(bool)
    {

        require(amount > 0, 'RewardPool : Cannot withdraw 0');

        for(uint i=0; i < extraRewards.length; i++){
            IRewards(extraRewards[i]).withdraw(msg.sender, amount);
        }

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);

        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);

        if(claim){
            getReward(msg.sender,true);
        }

        return true;
    }

    function withdrawAll(bool claim) external{

        withdraw(_balances[msg.sender],claim);
    }

    function withdrawAndUnwrap(uint256 amount, bool claim) public updateReward(msg.sender) returns(bool){


        for(uint i=0; i < extraRewards.length; i++){
            IRewards(extraRewards[i]).withdraw(msg.sender, amount);
        }

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);

        IDeposit(operator).withdrawTo(pid,amount,msg.sender);
        emit Withdrawn(msg.sender, amount);

        if(claim){
            getReward(msg.sender,true);
        }
        return true;
    }

    function withdrawAllAndUnwrap(bool claim) external{

        withdrawAndUnwrap(_balances[msg.sender],claim);
    }

    function getReward(address _account, bool _claimExtras) public updateReward(_account) returns(bool){

        uint256 reward = earned(_account);
        if (reward > 0) {
            rewards[_account] = 0;
            rewardToken.safeTransfer(_account, reward);
            emit RewardPaid(_account, reward);
        }

        if(_claimExtras){
            for(uint i=0; i < extraRewards.length; i++){
                IRewards(extraRewards[i]).getReward(_account);
            }
        }
        return true;
    }

    function getReward() external returns(bool){

        getReward(msg.sender,true);
        return true;
    }

    function donate(uint256 _amount) external returns(bool){

        IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
        queuedRewards = queuedRewards.add(_amount);
    }

    function queueNewRewards(uint256 _rewards) external returns(bool){

        require(msg.sender == operator, "!authorized");

        _rewards = _rewards.add(queuedRewards);

        if (block.timestamp >= periodFinish) {
            notifyRewardAmount(_rewards);
            queuedRewards = 0;
            return true;
        }

        uint256 elapsedTime = block.timestamp.sub(periodFinish.sub(duration));
        uint256 currentAtNow = rewardRate * elapsedTime;
        uint256 queuedRatio = currentAtNow.mul(1000).div(_rewards);

        if(queuedRatio < newRewardRatio){
            notifyRewardAmount(_rewards);
            queuedRewards = 0;
        }else{
            queuedRewards = _rewards;
        }
        return true;
    }

    function notifyRewardAmount(uint256 reward)
        internal
        updateReward(address(0))
    {

        historicalRewards = historicalRewards.add(reward);
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
}// MIT
pragma solidity 0.8.9;




contract VirtualBalanceWrapper {

    using SafeERC20 for IERC20;

    IDeposit public deposits;

    function totalSupply() public view returns (uint256) {

        return deposits.totalSupply();
    }

    function balanceOf(address account) public view returns (uint256) {

        return deposits.balanceOf(account);
    }
}

contract VirtualBalanceRewardPool is VirtualBalanceWrapper {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public rewardToken;
    uint256 public constant duration = 7 days;

    address public operator;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public queuedRewards = 0;
    uint256 public currentRewards = 0;
    uint256 public historicalRewards = 0;
    uint256 public newRewardRatio = 830;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(
        address deposit_,
        address reward_,
        address op_
    ) {
        deposits = IDeposit(deposit_);
        rewardToken = IERC20(reward_);
        operator = op_;
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

    function stake(address _account, uint256 amount)
    external
    updateReward(_account)
    {

        require(msg.sender == address(deposits), "!authorized");
        emit Staked(_account, amount);
    }

    function withdraw(address _account, uint256 amount)
    public
    updateReward(_account)
    {

        require(msg.sender == address(deposits), "!authorized");

        emit Withdrawn(_account, amount);
    }

    function getReward(address _account) public updateReward(_account) {

        uint256 reward = earned(_account);
        if (reward > 0) {
            rewards[_account] = 0;
            rewardToken.safeTransfer(_account, reward);
            emit RewardPaid(_account, reward);
        }
    }

    function getReward() external {

        getReward(msg.sender);
    }

    function donate(uint256 _amount) external returns(bool) {

        IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
        queuedRewards = queuedRewards.add(_amount);
    }

    function queueNewRewards(uint256 _rewards) external {

        require(msg.sender == operator, "!authorized");

        _rewards = _rewards.add(queuedRewards);

        if (block.timestamp >= periodFinish) {
            notifyRewardAmount(_rewards);
            queuedRewards = 0;
            return;
        }

        uint256 elapsedTime = block.timestamp.sub(periodFinish.sub(duration));
        uint256 currentAtNow = rewardRate * elapsedTime;
        uint256 queuedRatio = currentAtNow.mul(1000).div(_rewards);
        if (queuedRatio < newRewardRatio) {
            notifyRewardAmount(_rewards);
            queuedRewards = 0;
        } else {
            queuedRewards = _rewards;
        }
    }

    function notifyRewardAmount(uint256 reward)
    internal
    updateReward(address(0))
    {

        historicalRewards = historicalRewards.add(reward);
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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT
pragma solidity 0.8.9;




contract TokenWrapper is ERC20 {
    using SafeERC20 for IERC20;

    IERC20 public immutable stakingToken;

    constructor(address _stakingToken) ERC20 ("Staked uveCRV", "suveCRV") {
        stakingToken = IERC20(_stakingToken);
    }

    function _stakeFor(address to, uint amount) internal {
        _mint(to, amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function _withdraw(uint amount) internal {
        _burn(msg.sender, amount);
        stakingToken.safeTransfer(msg.sender, amount);
    }
}


contract FeePool is TokenWrapper {
    using SafeERC20 for IERC20;

    IERC20 public immutable rewardToken;
    uint256 public constant duration = 7 days;

    address public immutable operator;

    address public constant unitVault = address(0xb1cFF81b9305166ff1EFc49A129ad2AfCd7BCf19);

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public queuedRewards = 0;
    uint256 public currentRewards = 0;
    uint256 public historicalRewards = 0;
    uint256 public constant newRewardRatio = 830;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint) public vaultDeposit;

    event RewardAdded(uint256 reward);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(
        address stakingToken_,
        address rewardToken_,
        address operator_
    ) TokenWrapper(stakingToken_) {
        rewardToken = IERC20(rewardToken_);
        operator = operator_;
    }

    modifier updateReward(address account) {
        _updateReward(account);
        _;
    }

    modifier updateRewardOnTransfer(address from, address to) {
        _updateReward(from);
        _updateReward(to);
        if (to == unitVault) {
            vaultDeposit[from] = IVault(unitVault).collaterals(address(this), from);
        } else if (from == unitVault) {
            vaultDeposit[to] = IVault(unitVault).collaterals(address(this), to);
        }
        _;
    }

    function _updateReward(address account) internal {
        if (account != unitVault) {
            rewardPerTokenStored = rewardPerToken();
            lastUpdateTime = lastTimeRewardApplicable();
            if (account != address(0)) {
                rewards[account] = earned(account);
                userRewardPerTokenPaid[account] = rewardPerTokenStored;
            }
        }
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored + (
            (lastTimeRewardApplicable() - lastUpdateTime)
            * rewardRate
            * 1e18
            / totalSupply()
        );
    }

    function earned(address account) public view returns (uint256) {
        return
        (balanceOf(account) + vaultDeposit[account])
        * (rewardPerToken() - userRewardPerTokenPaid[account])
        / 1e18
        + rewards[account];
    }

    function stake(uint256 _amount)
    public
    updateReward(msg.sender)
    returns(bool)
    {
        require(_amount > 0, 'RewardPool : Cannot stake 0');

        super._stakeFor(msg.sender, _amount);

        return true;
    }

    function stakeAll() external returns(bool) {
        uint256 balance = stakingToken.balanceOf(msg.sender);
        stake(balance);
        return true;
    }

    function stakeFor(address _for, uint256 _amount)
    public
    updateReward(_for)
    returns(bool)
    {
        require(_amount > 0, 'RewardPool : Cannot stake 0');

        super._stakeFor(_for, _amount);

        return true;
    }


    function withdraw(uint256 amount, bool claim)
    public
    updateReward(msg.sender)
    returns(bool)
    {
        require(amount > 0, 'RewardPool : Cannot withdraw 0');

        super._withdraw(amount);

        if (claim) {
            getReward(msg.sender);
        }

        return true;
    }

    function withdrawAll(bool claim) external {
        withdraw(balanceOf(msg.sender), claim);
    }

    function getReward(address _account) public updateReward(_account) returns(bool) {
        uint256 reward = rewards[_account];
        if (reward > 0) {
            rewards[_account] = 0;
            rewardToken.safeTransfer(_account, reward);
            emit RewardPaid(_account, reward);
        }
        return true;
    }

    function getReward() external returns(bool) {
        getReward(msg.sender);
        return true;
    }

    function donate(uint256 _amount) external {
        IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
        queuedRewards = queuedRewards + _amount;
    }

    function queueNewRewards(uint256 _rewards) external returns(bool) {
        require(msg.sender == operator, "!authorized");

        _rewards = _rewards + queuedRewards;

        if (block.timestamp >= periodFinish) {
            notifyRewardAmount(_rewards);
            queuedRewards = 0;
            return true;
        }

        uint256 elapsedTime = block.timestamp - (periodFinish - duration);
        uint256 currentAtNow = rewardRate * elapsedTime;
        uint256 queuedRatio = currentAtNow * 1000 / _rewards;

        if (queuedRatio < newRewardRatio) {
            notifyRewardAmount(_rewards);
            queuedRewards = 0;
        } else {
            queuedRewards = _rewards;
        }
        return true;
    }

    function notifyRewardAmount(uint256 reward)
    internal
    updateReward(address(0))
    {
        historicalRewards = historicalRewards + reward;
        if (block.timestamp >= periodFinish) {
            rewardRate = reward / duration;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            reward = reward + leftover;
            rewardRate = reward / duration;
        }
        currentRewards = reward;
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + duration;
        emit RewardAdded(reward);
    }

    function transfer(address to, uint amount)
    public
    override
    updateRewardOnTransfer(msg.sender, to)
    returns (bool)
    {
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint amount)
    public
    override
    updateRewardOnTransfer(from, to)
    returns (bool)
    {
        return super.transferFrom(from, to, amount);
    }
}// MIT
pragma solidity 0.8.9;



contract RewardFactory {
    using Address for address;

    address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public immutable uvecrv;

    address public operator; // booster
    mapping (address => bool) private rewardAccess;
    mapping(address => uint256[]) public rewardActiveList;

    constructor(address _operator, address _uvecrv) {
        operator = _operator;
        uvecrv = _uvecrv;
    }

    function activeRewardCount(address _reward) external view returns(uint256) {
        return rewardActiveList[_reward].length;
    }

    function addActiveReward(address _reward, uint256 _pid) external returns(bool) {
        require(rewardAccess[msg.sender] == true, "!auth");
        if (_reward == address(0)) {
            return true;
        }

        uint256[] storage activeList = rewardActiveList[_reward];
        uint256 pid = _pid+1; //offset by 1 so that we can use 0 as empty

        uint256 length = activeList.length;
        for(uint256 i = 0; i < length; i++) {
            if (activeList[i] == pid) return true;
        }
        activeList.push(pid);
        return true;
    }

    function removeActiveReward(address _reward, uint256 _pid) external returns(bool) {
        require(rewardAccess[msg.sender] == true, "!auth");
        if (_reward == address(0)) {
            return true;
        }

        uint256[] storage activeList = rewardActiveList[_reward];
        uint256 pid = _pid + 1; //offset by 1 so that we can use 0 as empty

        uint256 length = activeList.length;
        for(uint256 i = 0; i < length; i++) {
            if (activeList[i] == pid) {
                if (i != length - 1) {
                    activeList[i] = activeList[length - 1];
                }
                activeList.pop();
                break;
            }
        }
        return true;
    }

    function setAccess(address _stash, bool _status) external {
        require(msg.sender == operator, "!auth");
        rewardAccess[_stash] = _status;
    }

    function CreateCrvRewards(uint256 _pid, address _depositToken) external returns (address) {
        require(msg.sender == operator, "!auth");

        BaseRewardPool rewardPool = new BaseRewardPool(_pid, _depositToken, crv, operator, address(this));
        return address(rewardPool);
    }

    function CreateTokenRewards(address _token, address _mainRewards, address _operator) external returns (address) {
        require(msg.sender == operator || rewardAccess[msg.sender] == true, "!auth");

        VirtualBalanceRewardPool rewardPool = new VirtualBalanceRewardPool(_mainRewards, _token, _operator);
        address rAddress = address(rewardPool);
        IRewards(_mainRewards).addExtraReward(rAddress);
        return rAddress;
    }

    function CreateFeePool(address _token, address _operator) external returns (address) {
        require(msg.sender == operator);

        FeePool rewardPool = new FeePool(uvecrv, _token, _operator);
        return address(rewardPool);
    }
}