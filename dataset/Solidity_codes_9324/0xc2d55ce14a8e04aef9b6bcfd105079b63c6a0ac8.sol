


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

    constructor () internal {}

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this;
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


    function mint(address account, uint amount) external;


    function burn(uint amount) external;


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

        if (returndata.length > 0) {// Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.5.0;


contract IRewardDistributionRecipient is Ownable {

    address rewardDistribution;
    address public rewardVote;
    address public rewardReferral;

    function notifyRewardAmount(uint256 reward) external;


    modifier onlyRewardDistribution() {

        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution) external onlyOwner {

        rewardDistribution = _rewardDistribution;
    }

    function setRewardVote(address _rewardVote) external onlyOwner {

        rewardVote = _rewardVote;
    }

    function setRewardReferral(address _rewardReferral) external onlyOwner {

        rewardReferral = _rewardReferral;
    }
}


pragma solidity ^0.5.0;


contract LPTokenWrapper {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    mapping(address => uint256) private _totalSupply; // token_address -> total_supply
    mapping(address => mapping(address => uint256)) private _balances; // token_address -> map(account -> balance)

    function totalSupply(address tokenAddress) public view returns (uint256) {

        return _totalSupply[tokenAddress];
    }

    function balanceOf(address tokenAddress, address account) public view returns (uint256) {

        return _balances[tokenAddress][account];
    }

    function tokenStake(address tokenAddress, uint256 amount) internal {

        address sender = msg.sender;
        require(!address(sender).isContract(), "Andre, we are farming in peace, go harvest somewhere else sir.");
        require(tx.origin == sender, "Andre, stahp.");
        _totalSupply[tokenAddress] = _totalSupply[tokenAddress].add(amount);
        _balances[tokenAddress][sender] = _balances[tokenAddress][sender].add(amount);
        IERC20(tokenAddress).safeTransferFrom(sender, address(this), amount);
    }

    function tokenWithdraw(address tokenAddress, uint256 amount) internal {

        _totalSupply[tokenAddress] = _totalSupply[tokenAddress].sub(amount);
        _balances[tokenAddress][msg.sender] = _balances[tokenAddress][msg.sender].sub(amount);
        IERC20(tokenAddress).safeTransfer(msg.sender, amount);
    }
}

interface IYFVReferral {

    function setReferrer(address farmer, address referrer) external;

    function getReferrer(address farmer) external view returns (address);

}

interface IYFVVote {

    function averageVotingValue(address poolAddress, uint256 votingItem) external view returns (uint16);

}

contract YFVRewards is LPTokenWrapper, IRewardDistributionRecipient {

    IERC20 public yfv = IERC20(0x45f24BaEef268BB6d63AEe5129015d69702BCDfa);
    IERC20 public vUSD = IERC20(0x1B8E12F839BD4e73A47adDF76cF7F0097d74c14C);
    IERC20 public vETH = IERC20(0x76A034e76Aa835363056dd418611E4f81870f16e);

    uint256 public vUSD_REWARD_FRACTION_RATE = 21000000000; // 21 * 1e9 (vUSD decimals = 9)
    uint256 public vETH_REWARD_FRACTION_RATE = 21000000000000; // 21000 * 1e9 (vETH decimals = 9)

    uint256 public constant DURATION = 7 days;
    uint8 public constant NUMBER_EPOCHS = 10;

    uint256 public constant REFERRAL_COMMISSION_PERCENT = 1;

    uint256 public constant EPOCH_REWARD = 63000 ether;
    uint256 public constant TOTAL_REWARD = EPOCH_REWARD * NUMBER_EPOCHS;

    uint256 public initreward = EPOCH_REWARD;
    uint256 public currentEpochReward = initreward;
    uint256 public totalAccumulatedReward = 0;
    uint8 public currentEpoch = 0;
    uint256 public starttime = 1597759200; // Tuesday, August 18, 2020 2:00:00 PM (GMT+0)
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => bool) public claimedVETHRewards; // account -> has claimed vETH?

    mapping(address => uint256) public accumulatedStakingPower; // will accumulate every time staker does getReward()

    address public constant USDT_TOKEN_ADDRESS = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant USDC_TOKEN_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant TUSD_TOKEN_ADDRESS = 0x0000000000085d4780B73119b644AE5ecd22b376;
    address public constant DAI_TOKEN_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    address[4] public SUPPORTED_STAKING_COIN_ADDRESSES = [USDT_TOKEN_ADDRESS, USDC_TOKEN_ADDRESS, TUSD_TOKEN_ADDRESS, DAI_TOKEN_ADDRESS];
    uint256[4] public SUPPORTED_STAKING_COIN_WEI_MULTIPLE = [1000000000000, 1000000000000, 1, 1];

    mapping(address => uint256) public supportedStakingCoinWeiMultiple; // token_address -> wei_multiple (because USDT and USDC have decimals = 6 only. Need to multiply by 1e12)

    mapping(address => address) public affiliate; // account_address -> referrer_address
    mapping(address => uint256) public referredCount; // referrer_address -> num_of_referred

    event RewardAdded(uint256 reward);
    event Burned(uint256 reward);
    event Staked(address indexed user, address indexed tokenAddress, uint256 amount);
    event Withdrawn(address indexed user, address indexed tokenAddress, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event CommissionPaid(address indexed user, uint256 reward);

    constructor () public {
        for (uint8 i = 0; i < 4; i++) {
            supportedStakingCoinWeiMultiple[SUPPORTED_STAKING_COIN_ADDRESSES[i]] = SUPPORTED_STAKING_COIN_WEI_MULTIPLE[i];
        }
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

    function weiTotalSupply() public view returns (uint256) {

        uint256 __weiTotalSupply = 0;
        for (uint8 i = 0; i < 4; i++) {
            __weiTotalSupply = __weiTotalSupply.add(super.totalSupply(SUPPORTED_STAKING_COIN_ADDRESSES[i]).mul(SUPPORTED_STAKING_COIN_WEI_MULTIPLE[i]));
        }
        return __weiTotalSupply;
    }

    function rewardPerToken() public view returns (uint256) {

        if (weiTotalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable()
            .sub(lastUpdateTime)
            .mul(rewardRate)
            .mul(1e18)
            .div(weiTotalSupply())
        );
    }

    function weiBalanceOf(address account) public view returns (uint256) {

        uint256 __weiBalance = 0;
        for (uint8 i = 0; i < 4; i++) {
            uint256 __balance = super.balanceOf(SUPPORTED_STAKING_COIN_ADDRESSES[i], account);
            if (__balance > 0) {
                __weiBalance = __weiBalance.add(__balance.mul(SUPPORTED_STAKING_COIN_WEI_MULTIPLE[i]));
            }
        }
        return __weiBalance;
    }

    function earned(address account) public view returns (uint256) {

        return
        weiBalanceOf(account)
        .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
        .div(1e18)
        .add(rewards[account]);
    }

    function stakingPower(address account) public view returns (uint256) {

        return accumulatedStakingPower[account].add(earned(account));
    }

    function vUSDBalance(address account) public view returns (uint256) {

        return earned(account).div(vUSD_REWARD_FRACTION_RATE);
    }

    function vETHBalance(address account) public view returns (uint256) {

        return stakingPower(account).div(vETH_REWARD_FRACTION_RATE);
    }

    function claimVETHReward() public {

        require(rewardRate == 0, "vETH could be claimed only after the pool ends.");
        uint256 claimAmount = vETHBalance(msg.sender);
        require(claimAmount > 0, "You have no vETH to claim");
        require(!claimedVETHRewards[msg.sender], "You have claimed all pending vETH.");
        claimedVETHRewards[msg.sender] = true;
        vETH.safeTransfer(msg.sender, claimAmount);
    }

    function stake(address tokenAddress, uint256 amount, address referrer) public updateReward(msg.sender) checkNextEpoch checkStart {

        require(amount > 0, "Cannot stake 0");
        require(supportedStakingCoinWeiMultiple[tokenAddress] > 0, "Not supported coin");
        require(referrer != msg.sender, "You cannot refer yourself.");
        super.tokenStake(tokenAddress, amount);
        emit Staked(msg.sender, tokenAddress, amount);
        if (rewardReferral != address(0) && referrer != address(0)) {
            IYFVReferral(rewardReferral).setReferrer(msg.sender, referrer);
        }
    }

    function withdraw(address tokenAddress, uint256 amount) public updateReward(msg.sender) checkNextEpoch checkStart {

        require(amount > 0, "Cannot withdraw 0");
        require(supportedStakingCoinWeiMultiple[tokenAddress] > 0, "Not supported coin");
        super.tokenWithdraw(tokenAddress, amount);
        emit Withdrawn(msg.sender, tokenAddress, amount);
    }

    function exit() external {

        for (uint8 i = 0; i < 4; i++) {
            uint256 __balance = balanceOf(SUPPORTED_STAKING_COIN_ADDRESSES[i], msg.sender);
            if (__balance > 0) {
                withdraw(SUPPORTED_STAKING_COIN_ADDRESSES[i], __balance);
            }
        }
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkNextEpoch checkStart {

        uint256 reward = earned(msg.sender);
        if (reward > 1) {
            accumulatedStakingPower[msg.sender] = accumulatedStakingPower[msg.sender].add(rewards[msg.sender]);
            rewards[msg.sender] = 0;

            uint256 actualPaid = reward.mul(100 - REFERRAL_COMMISSION_PERCENT).div(100); // 99%
            uint256 commission = reward - actualPaid; // 1%

            yfv.safeTransfer(msg.sender, actualPaid);
            emit RewardPaid(msg.sender, actualPaid);

            address referrer = address(0);
            if (rewardReferral != address(0)) {
                referrer = IYFVReferral(rewardReferral).getReferrer(msg.sender);
            }
            if (referrer != address(0)) { // send commission to referrer
                yfv.safeTransfer(referrer, commission);
                emit RewardPaid(msg.sender, commission);
            } else {// or burn
                yfv.burn(commission);
                emit Burned(commission);
            }

            vUSD.safeTransfer(msg.sender, reward.div(vUSD_REWARD_FRACTION_RATE));
        }
    }

    function nextRewardMultiplier() public view returns (uint16) {

        if (rewardVote != address(0)) {
            uint16 votingValue = IYFVVote(rewardVote).averageVotingValue(address(this), periodFinish);
            if (votingValue > 0) return votingValue;
        }
        return 100;
    }

    modifier checkNextEpoch() {

        if (block.timestamp >= periodFinish) {
            initreward = EPOCH_REWARD; // (by consensus)

            uint16 rewardMultiplier = nextRewardMultiplier(); // 50% -> 200% (by vote)
            currentEpochReward = initreward.mul(rewardMultiplier).div(100); // x0.50 -> x2.00 (by vote)

            if (totalAccumulatedReward.add(currentEpochReward) > TOTAL_REWARD) {
                currentEpochReward = TOTAL_REWARD.sub(totalAccumulatedReward); // limit total reward
            }

            if (currentEpochReward > 0) {
                yfv.mint(address(this), currentEpochReward);
                vUSD.mint(address(this), currentEpochReward.div(vUSD_REWARD_FRACTION_RATE));
                vETH.mint(address(this), currentEpochReward.div(vETH_REWARD_FRACTION_RATE));
                totalAccumulatedReward = totalAccumulatedReward.add(currentEpochReward);
                currentEpoch++;
            }

            rewardRate = currentEpochReward.div(DURATION);
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(currentEpochReward);
        }
        _;
    }

    modifier checkStart() {

        require(block.timestamp > starttime, "not start");
        _;
    }

    function notifyRewardAmount(uint256 reward) external onlyRewardDistribution updateReward(address(0)) {

        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(DURATION);
        }
        yfv.mint(address(this), reward);
        vUSD.mint(address(this), reward.div(vUSD_REWARD_FRACTION_RATE));
        vETH.mint(address(this), reward.div(vETH_REWARD_FRACTION_RATE));
        totalAccumulatedReward = totalAccumulatedReward.add(reward);
        currentEpoch++;
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(DURATION);
        emit RewardAdded(reward);
    }
}