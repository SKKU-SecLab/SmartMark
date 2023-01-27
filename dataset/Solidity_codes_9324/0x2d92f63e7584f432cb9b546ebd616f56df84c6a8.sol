
pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

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
}// MIT

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
}// MIT

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
}pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity >=0.6.6;


interface IRandomNumberConsumer {

    function getRandomNumber(uint256 userProvidedSeed) external;


    function fee() external view returns (uint256);

}

contract LPTokenWrapper {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public y;

    function setStakeToken(address _y) internal {

        y = IERC20(_y);
    }

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function stake(uint256 amount) public virtual {

        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        y.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public virtual {

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        y.safeTransfer(msg.sender, amount);
    }
}

contract RandomizedCounter is
    Ownable,
    Initializable,
    LPTokenWrapper,
    ReentrancyGuard
{

    using Address for address;

    event LogEmergencyWithdraw(uint256 timestamp);
    event LogSetCountThreshold(uint256 countThreshold_);
    event LogSetBeforePeriodFinish(bool beforePeriodFinish_);
    event LogSetCountInSequence(bool countInSequence_);
    event LogSetRewardPercentage(uint256 rewardPercentage_);
    event LogSetRevokeReward(bool revokeReward_);
    event LogSetRevokeRewardPrecentage(uint256 revokeRewardPrecentage_);
    event LogSetNormalDistribution(
        uint256 noramlDistributionMean_,
        uint256 normalDistributionDeviation_,
        uint256[100] normalDistribution_
    );
    event LogSetRandomNumberConsumer(
        IRandomNumberConsumer randomNumberConsumer_
    );
    event LogSetMultiSigAddress(address multiSigAddress_);
    event LogSetMultiSigRewardPercentage(uint256 multiSigRewardPercentage_);
    event LogRevokeRewardDuration(uint256 revokeRewardDuration_);
    event LogLastRandomThreshold(uint256 lastRandomThreshold_);
    event LogSetBlockDuration(uint256 blockDuration_);
    event LogStartNewDistributionCycle(
        uint256 poolShareAdded_,
        uint256 rewardRate_,
        uint256 periodFinish_,
        uint256 count_
    );
    event LogRandomThresold(uint256 randomNumber);
    event LogSetPoolEnabled(bool poolEnabled_);
    event LogSetEnableUserLpLimit(bool enableUserLpLimit_);
    event LogSetEnablePoolLpLimit(bool enablePoolLpLimit_);
    event LogSetUserLpLimit(uint256 userLpLimit_);
    event LogSetPoolLpLimit(uint256 poolLpLimit_);
    event LogRewardsClaimed(uint256 rewardAmount_);
    event LogRewardAdded(uint256 reward);
    event LogRewardRevoked(
        uint256 revokeDuratoin,
        uint256 precentageRevoked,
        uint256 amountRevoked
    );
    event LogClaimRevoked(uint256 claimAmountRevoked_);
    event LogStaked(address indexed user, uint256 amount);
    event LogWithdrawn(address indexed user, uint256 amount);
    event LogRewardPaid(address indexed user, uint256 reward);
    event LogManualPoolStarted(uint256 startedAt);

    IERC20 public debase;
    address public policy;
    bool public poolEnabled;

    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public lastUpdateBlock;
    uint256 public rewardPerTokenStored;
    uint256 public rewardPercentage;
    uint256 public rewardDistributed;

    uint256 public blockDuration;

    bool public enableUserLpLimit;
    uint256 public userLpLimit;

    bool public enablePoolLpLimit;
    uint256 public poolLpLimit;

    uint256 public revokeRewardDuration;

    bool public revokeReward;

    uint256 public lastRewardPercentage;

    uint256 public count;

    bool public countInSequence;

    bool public newBufferFunds;

    IRandomNumberConsumer public randomNumberConsumer;

    IERC20 public link;

    bool public beforePeriodFinish;

    uint256 public normalDistributionMean;

    uint256 public normalDistributionDeviation;

    uint256[100] public normalDistribution;

    address public multiSigAddress;
    uint256 public multiSigRewardPercentage;
    uint256 public multiSigRewardToClaimShare;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    modifier enabled() {

        require(poolEnabled, "Pool isn't enabled");
        _;
    }

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateBlock = lastBlockRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function setRewardPercentage(uint256 rewardPercentage_) external onlyOwner {

        rewardPercentage = rewardPercentage_;
        emit LogSetRewardPercentage(rewardPercentage);
    }

    function setCountInSequence(bool countInSequence_) external onlyOwner {

        countInSequence = countInSequence_;
        count = 0;
        emit LogSetCountInSequence(!countInSequence);
    }

    function setRevokeReward(bool revokeReward_) external onlyOwner {

        revokeReward = revokeReward_;
        emit LogSetRevokeReward(revokeReward);
    }

    function setRevokeRewardDuration(uint256 revokeRewardDuration_)
        external
        onlyOwner
    {

        revokeRewardDuration = revokeRewardDuration_;
        emit LogRevokeRewardDuration(revokeRewardDuration);
    }

    function setBeforePeriodFinish(bool beforePeriodFinish_)
        external
        onlyOwner
    {

        beforePeriodFinish = beforePeriodFinish_;
        emit LogSetBeforePeriodFinish(beforePeriodFinish);
    }

    function setBlockDuration(uint256 blockDuration_) external onlyOwner {

        require(blockDuration >= 1);
        blockDuration = blockDuration_;
        emit LogSetBlockDuration(blockDuration);
    }

    function setPoolEnabled(bool poolEnabled_) external onlyOwner {

        poolEnabled = poolEnabled_;
        count = 0;
        emit LogSetPoolEnabled(poolEnabled);
    }

    function setEnableUserLpLimit(bool enableUserLpLimit_) external onlyOwner {

        enableUserLpLimit = enableUserLpLimit_;
        emit LogSetEnableUserLpLimit(enableUserLpLimit);
    }

    function setUserLpLimit(uint256 userLpLimit_) external onlyOwner {

        require(
            userLpLimit_ <= poolLpLimit,
            "User lp limit cant be more than pool limit"
        );
        userLpLimit = userLpLimit_;
        emit LogSetUserLpLimit(userLpLimit);
    }

    function setEnablePoolLpLimit(bool enablePoolLpLimit_) external onlyOwner {

        enablePoolLpLimit = enablePoolLpLimit_;
        emit LogSetEnablePoolLpLimit(enablePoolLpLimit);
    }

    function setPoolLpLimit(uint256 poolLpLimit_) external onlyOwner {

        require(
            poolLpLimit_ >= userLpLimit,
            "Pool lp limit cant be less than user lp limit"
        );
        poolLpLimit = poolLpLimit_;
        emit LogSetPoolLpLimit(poolLpLimit);
    }

    function setRandomNumberConsumer(
        IRandomNumberConsumer randomNumberConsumer_
    ) external onlyOwner {

        randomNumberConsumer = IRandomNumberConsumer(randomNumberConsumer_);
        emit LogSetRandomNumberConsumer(randomNumberConsumer);
    }

    function setMultiSigRewardPercentage(uint256 multiSigRewardPercentage_)
        external
        onlyOwner
    {

        multiSigRewardPercentage = multiSigRewardPercentage_;
        emit LogSetMultiSigRewardPercentage(multiSigRewardPercentage);
    }

    function setMultiSigAddress(address multiSigAddress_) external onlyOwner {

        multiSigAddress = multiSigAddress_;
        emit LogSetMultiSigAddress(multiSigAddress);
    }

    function setNormalDistribution(
        uint256 normalDistributionMean_,
        uint256 normalDistributionDeviation_,
        uint256[100] calldata normalDistribution_
    ) external onlyOwner {

        normalDistributionMean = normalDistributionMean_;
        normalDistributionDeviation = normalDistributionDeviation_;
        normalDistribution = normalDistribution_;
        emit LogSetNormalDistribution(
            normalDistributionMean,
            normalDistributionDeviation,
            normalDistribution
        );
    }

    function initialize(
        address debase_,
        address pairToken_,
        address policy_,
        address randomNumberConsumer_,
        address link_,
        uint256 rewardPercentage_,
        uint256 blockDuration_,
        bool enableUserLpLimit_,
        uint256 userLpLimit_,
        bool enablePoolLpLimit_,
        uint256 poolLpLimit_,
        uint256 revokeRewardDuration_,
        uint256 normalDistributionMean_,
        uint256 normalDistributionDeviation_,
        uint256[100] memory normalDistribution_
    ) public initializer {

        setStakeToken(pairToken_);
        debase = IERC20(debase_);
        link = IERC20(link_);
        randomNumberConsumer = IRandomNumberConsumer(randomNumberConsumer_);
        policy = policy_;
        count = 0;

        blockDuration = blockDuration_;
        enableUserLpLimit = enableUserLpLimit_;
        userLpLimit = userLpLimit_;
        enablePoolLpLimit = enablePoolLpLimit_;
        poolLpLimit = poolLpLimit_;
        rewardPercentage = rewardPercentage_;
        revokeRewardDuration = revokeRewardDuration_;
        countInSequence = true;
        normalDistribution = normalDistribution_;
        normalDistributionMean = normalDistributionMean_;
        normalDistributionDeviation = normalDistributionDeviation_;
    }

    function checkStabilizerAndGetReward(
        int256 supplyDelta_,
        int256 rebaseLag_,
        uint256 exchangeRate_,
        uint256 debasePolicyBalance
    ) external returns (uint256 rewardAmount_) {

        require(
            msg.sender == policy,
            "Only debase policy contract can call this"
        );

        if (newBufferFunds) {
            uint256 previousUnusedRewardToClaim =
                debase.totalSupply().mul(lastRewardPercentage).div(10**18);

            if (
                debase.balanceOf(address(this)) >= previousUnusedRewardToClaim
            ) {
                debase.safeTransfer(policy, previousUnusedRewardToClaim);
                emit LogRewardsClaimed(previousUnusedRewardToClaim);
            }
            newBufferFunds = false;
        }

        if (supplyDelta_ > 0) {
            count = count.add(1);

            if (
                link.balanceOf(address(randomNumberConsumer)) >=
                randomNumberConsumer.fee() &&
                (beforePeriodFinish || block.number >= periodFinish)
            ) {
                uint256 rewardToClaim =
                    debasePolicyBalance.mul(rewardPercentage).div(10**18);

                uint256 multiSigRewardAmount =
                    rewardToClaim.mul(multiSigRewardPercentage).div(10**18);

                lastRewardPercentage = rewardToClaim.mul(10**18).div(
                    debase.totalSupply()
                );

                multiSigRewardToClaimShare = multiSigRewardAmount
                    .mul(10**18)
                    .div(debase.totalSupply());

                uint256 totalRewardToClaim =
                    rewardToClaim.add(multiSigRewardAmount);

                if (totalRewardToClaim <= debasePolicyBalance) {
                    newBufferFunds = true;
                    randomNumberConsumer.getRandomNumber(block.number);
                    emit LogRewardsClaimed(totalRewardToClaim);
                    return totalRewardToClaim;
                }
            }
        } else if (countInSequence) {
            count = 0;

            if (revokeReward && block.number < periodFinish) {
                uint256 timeRemaining = periodFinish.sub(block.number);
                if (timeRemaining >= revokeRewardDuration) {
                    periodFinish = periodFinish.sub(revokeRewardDuration);
                    uint256 rewardToRevokeShare =
                        rewardRate.mul(revokeRewardDuration);

                    uint256 rewardToRevokeAmount =
                        debase.totalSupply().mul(rewardToRevokeShare).div(
                            10**18
                        );

                    lastUpdateBlock = block.number;

                    debase.safeTransfer(policy, rewardToRevokeAmount);
                    emit LogRewardRevoked(
                        revokeRewardDuration,
                        rewardToRevokeShare,
                        rewardToRevokeAmount
                    );
                }
            }
        }
        return 0;
    }

    function claimer(uint256 randomNumber) external {

        require(
            msg.sender == address(randomNumberConsumer),
            "Only debase policy contract can call this"
        );
        newBufferFunds = false;

        uint256 lastRandomThreshold = normalDistribution[randomNumber.mod(100)];
        emit LogLastRandomThreshold(lastRandomThreshold);

        if (count >= lastRandomThreshold) {
            startNewDistributionCycle();
            count = 0;

            if (multiSigRewardToClaimShare != 0) {
                uint256 amountToClaim =
                    debase.totalSupply().mul(multiSigRewardToClaimShare).div(
                        10**18
                    );

                debase.transfer(multiSigAddress, amountToClaim);
            }
        } else {
            uint256 rewardToClaim =
                debase.totalSupply().mul(lastRewardPercentage).div(10**18);

            debase.safeTransfer(policy, rewardToClaim);
            emit LogClaimRevoked(rewardToClaim);
        }
    }

    function emergencyWithdraw() external onlyOwner {

        debase.safeTransfer(policy, debase.balanceOf(address(this)));
        emit LogEmergencyWithdraw(block.number);
    }

    function lastBlockRewardApplicable() internal view returns (uint256) {

        return Math.min(block.number, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {

        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastBlockRewardApplicable()
                    .sub(lastUpdateBlock)
                    .mul(rewardRate)
                    .mul(10**18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {

        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(10**18)
                .add(rewards[account]);
    }

    function stake(uint256 amount)
        public
        override
        nonReentrant
        updateReward(msg.sender)
        enabled
    {

        require(
            !address(msg.sender).isContract(),
            "Caller must not be a contract"
        );
        require(amount > 0, "Cannot stake 0");

        if (enablePoolLpLimit) {
            uint256 lpBalance = totalSupply();
            require(
                amount.add(lpBalance) <= poolLpLimit,
                "Cant stake pool lp limit reached"
            );
        }
        if (enableUserLpLimit) {
            uint256 userLpBalance = balanceOf(msg.sender);
            require(
                userLpBalance.add(amount) <= userLpLimit,
                "Cant stake more than lp limit"
            );
        }

        super.stake(amount);
        emit LogStaked(msg.sender, amount);
    }

    function withdraw(uint256 amount)
        public
        override
        nonReentrant
        updateReward(msg.sender)
    {

        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit LogWithdrawn(msg.sender, amount);
    }

    function exit() external {

        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public nonReentrant updateReward(msg.sender) enabled {

        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;

            uint256 rewardToClaim =
                debase.totalSupply().mul(reward).div(10**18);

            debase.safeTransfer(msg.sender, rewardToClaim);

            emit LogRewardPaid(msg.sender, rewardToClaim);
            rewardDistributed = rewardDistributed.add(reward);
        }
    }

    function startNewDistributionCycle() internal updateReward(address(0)) {

        require(
            debase.balanceOf(address(this)) < uint256(-1) / 10**18,
            "Rewards: rewards too large, would lock"
        );

        if (block.number >= periodFinish) {
            rewardRate = lastRewardPercentage.div(blockDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.number);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = lastRewardPercentage.add(leftover).div(blockDuration);
        }
        lastUpdateBlock = block.number;
        periodFinish = block.number.add(blockDuration);

        emit LogStartNewDistributionCycle(
            lastRewardPercentage,
            rewardRate,
            periodFinish,
            count
        );
    }
}