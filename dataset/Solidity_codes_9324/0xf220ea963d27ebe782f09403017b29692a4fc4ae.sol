





pragma solidity >=0.5.0;

interface IElkERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

}




pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




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
}




pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



pragma solidity >=0.8.0;








contract FarmingRewards is ReentrancyGuard, Ownable, Pausable {

    using SafeERC20 for IERC20;


    IERC20 public immutable rewardsToken;
    IERC20 public immutable stakingToken;
    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public rewardsDuration;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    IERC20 public boosterToken;
    uint256 public boosterRewardRate;
    uint256 public boosterRewardPerTokenStored;

    mapping(address => uint256) public userBoosterRewardPerTokenPaid;
    mapping(address => uint256) public boosterRewards;

    mapping(address => uint256) public coverages;
    uint256 public totalCoverage;

    uint256[] public feeSchedule;
    uint256[] public withdrawalFeesPct;
    uint256 public withdrawalFeesUnit = 10000; // unit for fees
    uint256 public maxWithdrawalFee = 1000;    // max withdrawal fee (here, 10%)
    mapping(address => uint256) public lastStakedTime;
    uint256 public totalFees;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;


    constructor(
        address _rewardsToken,
        address _stakingToken,
        address _boosterToken,
        uint256 _rewardsDuration,
        uint256[] memory _feeSchedule,       // assumes a sorted array
        uint256[] memory _withdrawalFeesPct  // aligned to fee schedule
    ) {
        require(_boosterToken != _rewardsToken, "The booster token must be different from the reward token");
        require(_boosterToken != _stakingToken, "The booster token must be different from the staking token");
        require(_rewardsDuration > 0, "Rewards duration cannot be zero");
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        boosterToken = IERC20(_boosterToken);
        rewardsDuration = _rewardsDuration;
        _setWithdrawalFees(_feeSchedule, _withdrawalFeesPct);
        _pause();
    }


    function totalSupply() external view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {

        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {

        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored + (lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18 / _totalSupply;
    }

    function earned(address account) public view returns (uint256) {

        return _balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18 + rewards[account];
    }

    function getRewardForDuration() external view returns (uint256) {

        return rewardRate * rewardsDuration;
    }

    function boosterRewardPerToken() public view returns (uint256) {

        if (_totalSupply == 0) {
            return boosterRewardPerTokenStored;
        }
        return boosterRewardPerTokenStored + (lastTimeRewardApplicable() - lastUpdateTime) * boosterRewardRate * 1e18 / _totalSupply;
    }

    function boosterEarned(address account) public view returns (uint256) {

        return _balances[account] * (boosterRewardPerToken() - userBoosterRewardPerTokenPaid[account]) / 1e18 + boosterRewards[account];
    }

    function getBoosterRewardForDuration() external view returns (uint256) {

        return boosterRewardRate * rewardsDuration;
    }

    function exitFee(address account) external view returns (uint256) {

        return fee(account, _balances[account]);
    }

    function fee(address account, uint256 withdrawalAmount) public view returns (uint256) {

        for (uint i=0; i < feeSchedule.length; ++i) {
            if (block.timestamp - lastStakedTime[account] < feeSchedule[i]) {
                return withdrawalAmount * withdrawalFeesPct[i] / withdrawalFeesUnit;
            }
        }
        return 0;
    }


    function stake(uint256 amount) external nonReentrant whenNotPaused updateReward(msg.sender) {

        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply + amount;
        _balances[msg.sender] = _balances[msg.sender] + amount;
        lastStakedTime[msg.sender] = block.timestamp;
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function stakeWithPermit(uint256 amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external nonReentrant whenNotPaused updateReward(msg.sender) {

        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply + amount;
        _balances[msg.sender] = _balances[msg.sender] + amount;

        IElkERC20(address(stakingToken)).permit(msg.sender, address(this), amount, deadline, v, r, s);

        lastStakedTime[msg.sender] = block.timestamp;

        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {

        _withdraw(amount);
    }

    function emergencyWithdraw(uint256 amount) external nonReentrant {

        _withdraw(amount);
    }

    function _withdraw(uint256 amount) private {

        require(amount > 0, "Cannot withdraw 0");
        uint256 balance = _balances[msg.sender];
        require(amount <= balance, "Cannot withdraw more than account balance");
        _totalSupply = _totalSupply - amount;
        uint256 collectedFee = fee(msg.sender, amount);
        _balances[msg.sender] = balance - amount;
        uint256 withdrawableBalance = amount - collectedFee;
        stakingToken.safeTransfer(msg.sender, withdrawableBalance);
        emit Withdrawn(msg.sender, withdrawableBalance);
        if (collectedFee > 0) {
            emit FeesCollected(msg.sender, collectedFee);
            totalFees = totalFees + collectedFee;
        }
    }

    function getReward() public nonReentrant updateReward(msg.sender) {

        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function getBoosterReward() public nonReentrant updateReward(msg.sender) {

        if (address(boosterToken) != address(0)) {
            uint256 reward = boosterRewards[msg.sender];
            if (reward > 0) {
                boosterRewards[msg.sender] = 0;
                boosterToken.safeTransfer(msg.sender, reward);
                emit BoosterRewardPaid(msg.sender, reward);
            }
        }
    }

    function getCoverage() public nonReentrant {

        uint256 coverageAmount = coverages[msg.sender];
        if (coverageAmount > 0) {
            totalCoverage = totalCoverage - coverages[msg.sender];
            coverages[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, coverageAmount);
            emit CoveragePaid(msg.sender, coverageAmount);
        }
    }

    function exit() external {

        withdraw(_balances[msg.sender]);
        getReward();
        getBoosterReward();
        getCoverage();
    }


    function sendRewardsAndStartEmission(uint256 reward, uint256 boosterReward, uint256 duration) external onlyOwner {

        rewardsToken.safeTransferFrom(msg.sender, address(this), reward);
        if (address(boosterToken) != address(0) && boosterReward > 0) {
            boosterToken.safeTransferFrom(owner(), address(this), boosterReward);
        }
        _startEmission(reward, boosterReward, duration);
    }

    function startEmission(uint256 reward, uint256 boosterReward, uint256 duration) external onlyOwner {

        _startEmission(reward, boosterReward, duration);
    }

    function stopEmission() external onlyOwner {

        require(block.timestamp < periodFinish, "Cannot stop rewards emissions if not started or already finished");

        uint256 tokensToBurn;
        uint256 boosterTokensToBurn;

        if (_totalSupply == 0) {
            tokensToBurn = rewardsToken.balanceOf(address(this));
            if (address(boosterToken) != address(0)) {
                boosterTokensToBurn = boosterToken.balanceOf(address(this));
            } else {
                boosterTokensToBurn = 0;
            }
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            tokensToBurn = rewardRate * remaining;
            boosterTokensToBurn = boosterRewardRate * remaining;
        }

        periodFinish = block.timestamp;
        if (tokensToBurn > 0) {
            rewardsToken.safeTransfer(owner(), tokensToBurn);
        }
        if (address(boosterToken) != address(0) && boosterTokensToBurn > 0) {
            boosterToken.safeTransfer(owner(), boosterTokensToBurn);
        }

        emit RewardsEmissionEnded(tokensToBurn);
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {

        require(tokenAddress != address(stakingToken), "Cannot withdraw the staking token");
        IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function recoverLeftoverReward() external onlyOwner {

        require(_totalSupply == 0 && rewardsToken == stakingToken, "Cannot recover leftover reward if it is not the staking token or there are still staked tokens");
        uint256 tokensToBurn = rewardsToken.balanceOf(address(this));
        if (tokensToBurn > 0) {
            rewardsToken.safeTransfer(msg.sender, tokensToBurn);
        }
        emit LeftoverRewardRecovered(tokensToBurn);
    }

    function recoverLeftoverBooster() external onlyOwner {

        require(address(boosterToken) != address(0), "Cannot recover leftover booster if there was no booster token set");
        require(_totalSupply == 0, "Cannot recover leftover booster if there are still staked tokens");
        uint256 tokensToBurn = boosterToken.balanceOf(address(this));
        if (tokensToBurn > 0) {
            boosterToken.safeTransfer(msg.sender, tokensToBurn);
        }
        emit LeftoverBoosterRecovered(tokensToBurn);
    }

    function recoverFees() external onlyOwner {

        uint256 previousFees = totalFees;
        totalFees = 0;
        stakingToken.safeTransfer(owner(), previousFees);
        emit FeesRecovered(previousFees);
    }

    function setRewardsDuration(uint256 duration) external onlyOwner {

        require(
            block.timestamp > periodFinish,
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        _setRewardsDuration(duration);
    }


    function setBoosterToken(address _boosterToken) external onlyOwner {

        require(_boosterToken != address(rewardsToken), "The booster token must be different from the reward token");
        require(_boosterToken != address(stakingToken), "The booster token must be different from the staking token");
        boosterToken = IERC20(_boosterToken);
        emit BoosterRewardSet(_boosterToken);
    }


    function setCoverageAmount(address addr, uint256 amount) public onlyOwner {

        totalCoverage = totalCoverage - coverages[addr];
        coverages[addr] = amount;
        totalCoverage = totalCoverage + coverages[addr];
    }

    function setCoverageAmounts(address[] memory addresses, uint256[] memory amounts) external onlyOwner {

        require(addresses.length == amounts.length, "The same number of addresses and amounts must be provided");
        for (uint i=0; i < addresses.length; ++i) {
            setCoverageAmount(addresses[i], amounts[i]);
        }
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }


    function setWithdrawalFees(uint256[] memory _feeSchedule, uint256[] memory _withdrawalFees) external onlyOwner {

        _setWithdrawalFees(_feeSchedule, _withdrawalFees);
    }


    function _setRewardsDuration(uint256 duration) private {

        rewardsDuration = duration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    function _setWithdrawalFees(uint256[] memory _feeSchedule, uint256[] memory _withdrawalFeesPct) private {

        require(_feeSchedule.length == _withdrawalFeesPct.length, "Fee schedule and withdrawal fees arrays must be the same length!");
        require(_feeSchedule.length <= 10, "Fee schedule and withdrawal fees arrays lengths cannot be larger than 10!");
        uint256 lastFeeSchedule = 0;
        uint256 lastWithdrawalFee = maxWithdrawalFee + 1;
        for(uint256 i = 0; i < _feeSchedule.length; ++i) {
           require(_feeSchedule[i] > lastFeeSchedule, "Fee schedule must be ascending!");
           require(_withdrawalFeesPct[i] < lastWithdrawalFee, "Withdrawal fees must be descending and lower than maximum!");
           lastFeeSchedule = _feeSchedule[i];
           lastWithdrawalFee = _withdrawalFeesPct[i];
        }
        feeSchedule = _feeSchedule;
        withdrawalFeesPct = _withdrawalFeesPct;
        emit WithdrawalFeesSet(_feeSchedule, _withdrawalFeesPct);
    }

    function _startEmission(uint256 reward, uint256 boosterReward, uint256 duration) private updateReward(address(0)) {

        if (duration > 0) {
            _setRewardsDuration(duration);
        }

        if (block.timestamp >= periodFinish) {
            rewardRate = reward / rewardsDuration;
            boosterRewardRate = boosterReward / rewardsDuration;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / rewardsDuration;
            uint256 boosterLeftover = remaining * boosterRewardRate;
            boosterRewardRate = (boosterReward + boosterLeftover) / rewardsDuration;
        }

        uint balance = rewardsToken.balanceOf(address(this));
        if (rewardsToken != stakingToken) {
            require(rewardRate <= balance / rewardsDuration, "Provided reward too high");
        } else { // Handle care where rewardsToken is the same as stakingToken (need to subtract total supply)
            require(rewardRate <= (balance - _totalSupply) / rewardsDuration, "Provided reward too high");
        }

        if (address(boosterToken) != address(0)) {
            uint boosterBalance = boosterToken.balanceOf(address(this));
            require(boosterRewardRate <= boosterBalance / rewardsDuration, "Provided booster reward too high");
        }

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;

        emit RewardsEmissionStarted(reward, boosterReward, duration);
    }


    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        boosterRewardPerTokenStored = boosterRewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
            boosterRewards[account] = boosterEarned(account);
            userBoosterRewardPerTokenPaid[account] = boosterRewardPerTokenStored;
        }
        _;
    }


    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event CoveragePaid(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event BoosterRewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);
    event LeftoverRewardRecovered(uint256 amount);
    event LeftoverBoosterRecovered(uint256 amount);
    event RewardsEmissionStarted(uint256 reward, uint256 boosterReward, uint256 duration);
    event RewardsEmissionEnded(uint256 amount);
    event BoosterRewardSet(address token);
    event WithdrawalFeesSet(uint256[] _feeSchedule, uint256[] _withdrawalFees);
    event FeesCollected(address indexed user, uint256 amount);
    event FeesRecovered(uint256 amount);
}