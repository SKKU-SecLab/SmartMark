


pragma solidity ^0.8.0;

interface IStakingRewards {

    function lastTimeRewardApplicable() external view returns (uint256);


    function rewardPerToken() external view returns (uint256);


    function earned(address nftContract, uint256 tokenId) external view returns (uint256);


    function getRewardForDuration() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address nftContract, uint256 tokenId) external view returns (uint256);



    function stake(
        uint256 amount,
        address nftContract,
        uint256 tokenId,
        address sender
    ) external;


    function exit(address nftContract, uint256 tokenId) external;

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
}




pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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


pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;








abstract contract RewardsDistributionRecipient {
    address public rewardsDistribution;

    function notifyRewardAmount(uint256 reward) external virtual;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, 'Caller is not RewardsDistribution contract');
        _;
    }
}

contract StakingRewards is IStakingRewards, RewardsDistributionRecipient, ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    IERC20 public rewardsToken;
    IERC20 public stakingToken;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    uint256 public stakingTill;

    address public nftStaking;

    struct StakedData {
        uint256 nftRewardPerTokenPaid;
        uint256 rewards;
        uint256 _balances;
        address owner;
    }

    mapping(address => mapping(uint256 => StakedData)) public stakedData;

    uint256 private _totalSupply;
    address public sweeper;
    uint256 public stakingCap;

    uint256 public lastRewardAddedTime;


    constructor(
        address _rewardsDistribution,
        address _rewardsToken,
        address _stakingToken,
        uint256 _rewardsDuration,
        address _sweeper,
        uint256 _stakingCap
    ) {
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        rewardsDistribution = _rewardsDistribution;
        rewardsDuration = _rewardsDuration;
        sweeper = _sweeper;
        stakingCap = _stakingCap;

        transferOwnership(sweeper);
    }


    function totalSupply() external view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address nftContract, uint256 tokenId) external view override returns (uint256) {

        return stakedData[nftContract][tokenId]._balances;
    }

    function lastTimeRewardApplicable() public view override returns (uint256) {

        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view override returns (uint256) {

        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
            );
    }

    function earned(address nftContract, uint256 tokenId) public view override returns (uint256) {

        StakedData memory staked = stakedData[nftContract][tokenId];
        return staked._balances.mul(rewardPerToken().sub(staked.nftRewardPerTokenPaid)).div(1e18).add(staked.rewards);
    }

    function getRewardForDuration() external view override returns (uint256) {

        return rewardRate.mul(rewardsDuration);
    }


    function sweep(address token, uint256 amount) external onlyOwner {

        IERC20(token).transfer(msg.sender, amount);
    }

    function setNftStaking(address _nftStaking) external onlyOwner {

        nftStaking = _nftStaking;
        emit UpdateNftStakingAddress(nftStaking);
    }

    function stake(
        uint256 amount,
        address nftContract,
        uint256 tokenId,
        address sender
    ) external override nonReentrant onlyNFTStakingContract updateReward(nftContract, tokenId) {

        require(amount > 0, 'Cannot stake 0');
        require(_totalSupply.add(amount) < stakingCap, 'Cannot stake more than cap');
        _totalSupply = _totalSupply.add(amount);

        StakedData memory staked = stakedData[nftContract][tokenId];
        staked._balances = staked._balances.add(amount);
        staked.owner = sender;

        stakedData[nftContract][tokenId] = staked;
        emit Staked(staked.owner, amount);
    }

    function withdraw(
        uint256 amount,
        address nftContract,
        uint256 tokenId
    ) internal nonReentrant updateReward(nftContract, tokenId) {

        require(amount > 0, 'Cannot withdraw 0');


        StakedData memory staked = stakedData[nftContract][tokenId];

        _totalSupply = _totalSupply.sub(amount);
        staked._balances = staked._balances.sub(amount);
        stakedData[nftContract][tokenId] = staked;
        emit Withdrawn(staked.owner, amount);
    }

    enum StakingFee {
        BurnFee,
        RewardFee,
        LiquidityFee,
        DaoFee
    }

    struct StakingFeeData {
        uint256 percentage;
        address to;
    }

    mapping(StakingFee => StakingFeeData) public stakingFeesData;

    event SetStakingFeeData(StakingFee fee, uint256 percentage, address to);

    function setStakingFeeBatch(
        StakingFee[] memory fees,
        uint256[] memory percentages,
        address[] memory tos
    ) external onlyOwner {

        require(fees.length == percentages.length && percentages.length == tos.length, 'Length mismatch');
        for (uint256 i = 0; i < fees.length; i++) {
            (uint256 percentage, address to) = (percentages[i], tos[i]);
            require(percentage > 0, 'Percentage must be greater than 0');
            stakingFeesData[fees[i]] = StakingFeeData(percentage, to);
            emit SetStakingFeeData(fees[i], percentage, to);
        }
    }

    function setStakingFee(
        StakingFee fee,
        uint256 percentage,
        address to
    ) external onlyOwner {

        require(percentage > 0, 'Cannot set 0 fee');
        stakingFeesData[fee].percentage = percentage;
        stakingFeesData[fee].to = to;

        uint256 totalFee = 0;
        for (uint256 index = 0; index < uint256(StakingFee.DaoFee); index++) {
            totalFee += stakingFeesData[StakingRewards.StakingFee(index)].percentage;
        }
        require(totalFee <= 100, 'Total fee cannot be more than 100%');

        emit SetStakingFeeData(fee, percentage, to);
    }

    function transferFees(uint256 amount) internal returns (uint256 leftOverAmount) {

        uint256 totalFee = 0;
        for (uint256 index = 0; index < uint256(StakingFee.DaoFee); index++) {
            StakingFeeData memory feeData = stakingFeesData[StakingRewards.StakingFee(index)];
            if (feeData.percentage > 0 && feeData.to != address(0)) {
                uint256 fees = amount.mul(feeData.percentage).div(100);

                rewardsToken.safeTransfer(feeData.to, fees);

                totalFee += fees;
            }
        }
        leftOverAmount = amount.sub(totalFee);
        require(leftOverAmount >= 0, 'Left over amount cannot be negative');
        return leftOverAmount;
    }

    function getReward(address nftContract, uint256 tokenId) internal nonReentrant updateReward(nftContract, tokenId) {

        StakedData memory staked = stakedData[nftContract][tokenId];
        uint256 reward = staked.rewards;
        if (reward > 0) {
            staked.rewards = 0;
            uint256 leftOverReward = transferFees(reward);
            rewardsToken.safeTransfer(staked.owner, leftOverReward);
            emit RewardPaid(staked.owner, reward);
            stakedData[nftContract][tokenId] = staked;
        }
    }

    function exit(address nftContract, uint256 tokenId) external override onlyNFTStakingContract {

        StakedData memory staked = stakedData[nftContract][tokenId];

        getReward(nftContract, tokenId);
        withdraw(staked._balances, nftContract, tokenId);
    }


    function notifyRewardAmount(uint256 reward) external override onlyRewardsDistribution updateReward(address(0), 0) {

        lastRewardAddedTime = block.timestamp;

        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        uint256 balance = rewardsToken.balanceOf(address(this));

        require(rewardRate <= balance.div(rewardsDuration), 'Provided reward too high');

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }


    modifier updateReward(address nftContract, uint256 tokenId) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (nftContract != address(0)) {
            StakedData storage staked = stakedData[nftContract][tokenId];
            staked.rewards = earned(nftContract, tokenId);
            staked.nftRewardPerTokenPaid = rewardPerTokenStored;
            stakedData[nftContract][tokenId] = staked;
        }
        _;
    }

    modifier onlyNFTStakingContract() {

        require(_msgSender() == nftStaking, 'Not NFT staking contract is allowed');
        _;
    }


    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event UpdateNftStakingAddress(address indexed stakingAddress);

    function withdrawETH() external onlyOwner {

        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawFunds(
        address tokenAddress,
        uint256 amount,
        address wallet
    ) external onlyOwner {

        IERC20(tokenAddress).transfer(wallet, amount);
    }
}