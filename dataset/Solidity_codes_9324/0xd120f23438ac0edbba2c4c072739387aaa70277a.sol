


pragma solidity 0.5.17;

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


pragma solidity 0.5.17;

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


pragma solidity 0.5.17;

contract Context {

    constructor () internal {}

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this;
        return msg.data;
    }
}


pragma solidity 0.5.17;

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


pragma solidity 0.5.17;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function mint(address account, uint amount) external;


    function burn(uint amount) external;


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function minters(address account) external view returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity 0.5.17;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity 0.5.17;




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

        if (returndata.length > 0) {// Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity 0.5.17;


contract IRewardDistributionRecipient is Ownable {

    address public rewardReferral;

    function notifyRewardAmount(uint256 reward) external;


    function setRewardReferral(address _rewardReferral) external onlyOwner {

        rewardReferral = _rewardReferral;
    }
}


pragma solidity 0.5.17;


contract LPTokenWrapper {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    IERC20 public yfv = IERC20(0x45f24BaEef268BB6d63AEe5129015d69702BCDfa);

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function tokenStake(uint256 amount, uint256 actualStakeAmount) internal {

        _totalSupply = _totalSupply.add(actualStakeAmount);
        _balances[msg.sender] = _balances[msg.sender].add(actualStakeAmount);
        yfv.safeTransferFrom(msg.sender, address(this), amount);
    }

    function tokenStakeOnBehalf(address stakeFor, uint256 amount, uint256 actualStakeAmount) internal {

        _totalSupply = _totalSupply.add(actualStakeAmount);
        _balances[stakeFor] = _balances[stakeFor].add(actualStakeAmount);
        yfv.safeTransferFrom(msg.sender, address(this), amount);
    }

    function tokenWithdraw(uint256 amount, uint256 actualWithdrawAmount) internal {

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        yfv.safeTransfer(msg.sender, actualWithdrawAmount);
    }
}

interface IYFVReferral {

    function setReferrer(address farmer, address referrer) external;

    function getReferrer(address farmer) external view returns (address);

}

contract YFVStakeV2 is LPTokenWrapper, IRewardDistributionRecipient {

    IERC20 public vUSD = IERC20(0x1B8E12F839BD4e73A47adDF76cF7F0097d74c14C);
    IERC20 public vETH = IERC20(0x76A034e76Aa835363056dd418611E4f81870f16e);

    uint256 public vETH_REWARD_FRACTION_RATE = 1000;

    uint256 public constant DURATION = 7 days;
    uint8 public constant NUMBER_EPOCHS = 38;

    uint256 public constant REFERRAL_COMMISSION_PERCENT = 1;

    uint256 public currentEpochReward = 0;
    uint256 public totalAccumulatedReward = 0;
    uint8 public currentEpoch = 0;
    uint256 public starttime = 1598968800; // Tuesday, September 1, 2020 2:00:00 PM (GMT+0)
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    uint256 public constant DEFAULT_EPOCH_REWARD = 230000 * (10 ** 9); // 230,000 vUSD (and 230 vETH)
    uint256 public constant TOTAL_REWARD = DEFAULT_EPOCH_REWARD * NUMBER_EPOCHS; // 8,740,000 vUSD (and 8,740 vETH)

    uint256 public epochReward = DEFAULT_EPOCH_REWARD;
    uint256 public minStakingAmount = 90 ether;
    uint256 public unstakingFrozenTime = 40 hours;

    uint256 public lowStakeDepositFee = 0; // per ten thousand (eg. 15 -> 0.15%)
    uint256 public highStakeDepositFee = 0; // per ten thousand (eg. 15 -> 0.15%)
    uint256 public unlockWithdrawFee = 0; // per ten thousand (eg. 15 -> 0.15%)

    address public yfvInsuranceFund = 0xb7b2Ea8A1198368f950834875047aA7294A2bDAa; // set to Governance Multisig at start

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastStakeTimes;

    mapping(address => uint256) public accumulatedStakingPower; // will accumulate every time staker does getReward()

    mapping(address => bool) public whitelistedPools; // for stake on behalf

    event RewardAdded(uint256 reward);
    event YfvRewardAdded(uint256 reward);
    event Burned(uint256 reward);
    event Staked(address indexed user, uint256 amount, uint256 actualStakeAmount);
    event Withdrawn(address indexed user, uint256 amount, uint256 actualWithdrawAmount);
    event RewardPaid(address indexed user, uint256 reward);
    event CommissionPaid(address indexed user, uint256 reward);

    constructor() public {
        whitelistedPools[0x62a9fE913eb596C8faC0936fd2F51064022ba22e] = true; // BAL Pool
        whitelistedPools[0x70b83A7f5E83B3698d136887253E0bf426C9A117] = true; // YFI Pool
        whitelistedPools[0x1c990fC37F399C935625b815975D0c9fAD5C31A1] = true; // BAT Pool
        whitelistedPools[0x752037bfEf024Bd2669227BF9068cb22840174B0] = true; // REN Pool
        whitelistedPools[0x9b74774f55C0351fD064CfdfFd35dB002C433092] = true; // KNC Pool
        whitelistedPools[0xFBDE07329FFc9Ec1b70f639ad388B94532b5E063] = true; // BTC Pool
        whitelistedPools[0x67FfB615EAEb8aA88fF37cCa6A32e322286a42bb] = true; // ETH Pool
        whitelistedPools[0x196CF719251579cBc850dED0e47e972b3d7810Cd] = true; // LINK Pool
        whitelistedPools[msg.sender] = true; // to be able to stakeOnBehalf farmer who have stucked fund in Pool Stake v1.
    }

    function addWhitelistedPool(address _addressPool) public onlyOwner {

        whitelistedPools[_addressPool] = true;
    }

    function removeWhitelistedPool(address _addressPool) public onlyOwner {

        whitelistedPools[_addressPool] = false;
    }

    function setYfvInsuranceFund(address _yfvInsuranceFund) public onlyOwner {

        yfvInsuranceFund = _yfvInsuranceFund;
    }

    function setEpochReward(uint256 _epochReward) public onlyOwner {

        require(_epochReward <= DEFAULT_EPOCH_REWARD * 10, "Insane big _epochReward!"); // At most 10x only
        epochReward = _epochReward;
    }

    function setMinStakingAmount(uint256 _minStakingAmount) public onlyOwner {

        minStakingAmount = _minStakingAmount;
    }

    function setUnstakingFrozenTime(uint256 _unstakingFrozenTime) public onlyOwner {

        unstakingFrozenTime = _unstakingFrozenTime;
    }

    function setStakeDepositFee(uint256 _lowStakeDepositFee, uint256 _highStakeDepositFee) public onlyOwner {

        require(_lowStakeDepositFee <= 100 || _lowStakeDepositFee == 10000, "Dont be too greedy"); // <= 1% OR set to 10000 to disable low stake fee
        require(_highStakeDepositFee <= 100, "Dont be too greedy"); // <= 1%
        lowStakeDepositFee = _lowStakeDepositFee;
        highStakeDepositFee = _highStakeDepositFee;
    }

    function setUnlockWithdrawFee(uint256 _unlockWithdrawFee) public onlyOwner {

        require(_unlockWithdrawFee <= 1000, "Dont be too greedy"); // <= 10%
        unlockWithdrawFee = _unlockWithdrawFee;
    }

    function upgradeVUSDContract(address _vUSDContract) public onlyOwner {

        vUSD = IERC20(_vUSDContract);
    }

    function upgradeVETHContract(address _vETHContract) public onlyOwner {

        vETH = IERC20(_vETHContract);
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

        uint256 calculatedEarned = balanceOf(account)
        .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
        .div(1e18)
        .add(rewards[account]);
        uint256 poolBalance = vUSD.balanceOf(address(this));
        if (calculatedEarned > poolBalance) return poolBalance;
        return calculatedEarned;
    }

    function stakingPower(address account) public view returns (uint256) {

        return accumulatedStakingPower[account].add(earned(account));
    }

    function vETHBalance(address account) public view returns (uint256) {

        return earned(account).div(vETH_REWARD_FRACTION_RATE);
    }

    function stake(uint256 amount, address referrer) public updateReward(msg.sender) checkNextEpoch {

        require(amount >= 1 szabo, "Do not stake dust");
        require(referrer != msg.sender, "You cannot refer yourself.");
        uint256 actualStakeAmount = amount;
        uint256 depositFee = 0;
        if (minStakingAmount > 0) {
            if (amount < minStakingAmount && lowStakeDepositFee < 10000) {

                if (lowStakeDepositFee == 0) require(amount >= minStakingAmount, "Cannot stake below minStakingAmount");
                else depositFee = amount.mul(lowStakeDepositFee).div(10000);
            } else if (amount > minStakingAmount && highStakeDepositFee > 0) {
                depositFee = amount.sub(minStakingAmount).mul(highStakeDepositFee).div(10000);
            }
            if (depositFee > 0) {
                actualStakeAmount = amount.sub(depositFee);
            }
        }
        super.tokenStake(amount, actualStakeAmount);
        lastStakeTimes[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount, actualStakeAmount);
        if (depositFee > 0) {
            if (yfvInsuranceFund != address(0)) { // send fee to insurance
                yfv.safeTransfer(yfvInsuranceFund, depositFee);
                emit RewardPaid(yfvInsuranceFund, depositFee);
            } else { // or burn
                yfv.burn(depositFee);
                emit Burned(depositFee);
            }
        }
        if (rewardReferral != address(0) && referrer != address(0)) {
            IYFVReferral(rewardReferral).setReferrer(msg.sender, referrer);
        }
    }

    function stakeOnBehalf(address stakeFor, uint256 amount) public updateReward(stakeFor) checkNextEpoch {

        require(amount >= 1 szabo, "Do not stake dust");
        require(whitelistedPools[msg.sender], "Sorry hackers, you should stay away from us (YFV community signed)");
        uint256 actualStakeAmount = amount;
        uint256 depositFee = 0;
        if (minStakingAmount > 0) {
            if (amount < minStakingAmount && lowStakeDepositFee < 10000) {

                if (lowStakeDepositFee == 0) require(amount >= minStakingAmount, "Cannot stake below minStakingAmount");

                else depositFee = amount.mul(lowStakeDepositFee).div(10000);
            } else if (amount > minStakingAmount && highStakeDepositFee > 0) {
                depositFee = amount.sub(minStakingAmount).mul(highStakeDepositFee).div(10000);
            }
            if (depositFee > 0) {
                actualStakeAmount = amount.sub(depositFee);
            }
        }
        super.tokenStakeOnBehalf(stakeFor, amount, actualStakeAmount);
        lastStakeTimes[stakeFor] = block.timestamp;
        emit Staked(stakeFor, amount, actualStakeAmount);
        if (depositFee > 0) {
            actualStakeAmount = amount.sub(depositFee);
            if (yfvInsuranceFund != address(0)) { // send fee to insurance
                yfv.safeTransfer(yfvInsuranceFund, depositFee);
                emit RewardPaid(yfvInsuranceFund, depositFee);
            } else { // or burn
                yfv.burn(depositFee);
                emit Burned(depositFee);
            }
        }
    }

    function unfrozenStakeTime(address account) public view returns (uint256) {

        return lastStakeTimes[account] + unstakingFrozenTime;
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) checkNextEpoch {

        require(amount > 0, "Cannot withdraw 0");
        uint256 actualWithdrawAmount = amount;
        if (block.timestamp < unfrozenStakeTime(msg.sender)) {
            if (unlockWithdrawFee == 0) revert("Coin is still frozen");

            uint256 withdrawFee = amount.mul(unlockWithdrawFee).div(10000);
            actualWithdrawAmount = amount.sub(withdrawFee);
            if (yfvInsuranceFund != address(0)) { // send fee to insurance
                yfv.safeTransfer(yfvInsuranceFund, withdrawFee);
                emit RewardPaid(yfvInsuranceFund, withdrawFee);
            } else { // or burn
                yfv.burn(withdrawFee);
                emit Burned(withdrawFee);
            }
        }
        super.tokenWithdraw(amount, actualWithdrawAmount);
        emit Withdrawn(msg.sender, amount, actualWithdrawAmount);
    }

    function exit() external {

        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkNextEpoch {

        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            accumulatedStakingPower[msg.sender] = accumulatedStakingPower[msg.sender].add(rewards[msg.sender]);
            rewards[msg.sender] = 0;

            vUSD.safeTransfer(msg.sender, reward);
            vETH.safeTransfer(msg.sender, reward.div(vETH_REWARD_FRACTION_RATE));

            emit RewardPaid(msg.sender, reward);
        }
    }

    modifier checkNextEpoch() {

        require(periodFinish > 0, "Pool has not started");
        if (block.timestamp >= periodFinish) {
            currentEpochReward = epochReward;

            if (totalAccumulatedReward.add(currentEpochReward) > TOTAL_REWARD) {
                currentEpochReward = TOTAL_REWARD.sub(totalAccumulatedReward); // limit total reward
            }

            if (currentEpochReward > 0) {
                if (!vUSD.minters(address(this)) || !vETH.minters(address(this))) {
                    currentEpochReward = 0;
                } else {
                    vUSD.mint(address(this), currentEpochReward);
                    vETH.mint(address(this), currentEpochReward.div(vETH_REWARD_FRACTION_RATE));
                    totalAccumulatedReward = totalAccumulatedReward.add(currentEpochReward);
                }
                currentEpoch++;
            }

            rewardRate = currentEpochReward.div(DURATION);
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(currentEpochReward);
        }
        _;
    }

    function notifyRewardAmount(uint256 reward) external onlyOwner updateReward(address(0)) {

        require(periodFinish == 0, "Only can call once to start staking");
        currentEpochReward = reward;
        if (totalAccumulatedReward.add(currentEpochReward) > TOTAL_REWARD) {
            currentEpochReward = TOTAL_REWARD.sub(totalAccumulatedReward); // limit total reward
        }
        lastUpdateTime = block.timestamp;
        if (block.timestamp < starttime) { // epoch zero
            periodFinish = starttime;
            rewardRate = reward.div(periodFinish.sub(block.timestamp));
        } else { // 1st epoch
            periodFinish = lastUpdateTime.add(DURATION);
            rewardRate = reward.div(DURATION);
            currentEpoch++;
        }
        vUSD.mint(address(this), reward);
        vETH.mint(address(this), reward.div(vETH_REWARD_FRACTION_RATE));
        totalAccumulatedReward = totalAccumulatedReward.add(reward);
        emit RewardAdded(reward);
    }

    function governanceRecoverUnsupported(IERC20 _token, uint256 amount, address to) external {

        require(msg.sender == owner(), "!governance");
        require(_token != yfv, "yfv");
        require(_token != vUSD, "vUSD");
        require(_token != vETH, "vETH");

        _token.safeTransfer(to, amount);
    }
}