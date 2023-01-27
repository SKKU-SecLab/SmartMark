pragma solidity 0.8.6;

abstract contract RewardsRecipient {
    address public rewardsDistributor;

    modifier onlyRewardsDistributor() {
        require(msg.sender == rewardsDistributor, "!rewardsDistributor");
        _;
    }

    function notifyRewardAmount(uint256 rewardTokenIndex, uint256 amount) external virtual;
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
}pragma solidity 0.8.6;

interface ILinkswapERC20 {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}pragma solidity 0.8.6;

interface IStakingRewards {

    function stake(uint256 amount) external;


    function unstakeAndClaimRewards(uint256 unstakeAmount) external;


    function unstake(uint256 amount) external;


    function claimRewards() external;


    function lastTimeRewardApplicable() external view returns (uint256);


    function rewardPerToken(uint256 rewardTokenIndex) external view returns (uint256);


    function earned(address account, uint256 rewardTokenIndex) external view returns (uint256);


    function getRewardForDuration(uint256 rewardTokenIndex) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);

}pragma solidity 0.8.6;



contract StakingRewards is IStakingRewards, RewardsRecipient, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    event RewardAdded(address indexed rewardToken, uint256 amount);
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, address indexed rewardToken, uint256 amount);


    address public owner;
    IERC20 public stakingToken;
    uint256 public lastUpdateTime;
    uint256 public periodFinish;
    uint256 public rewardsDuration;

    IERC20[2] public rewardTokens;
    uint256[2] public rewardRate;
    uint256[2] public rewardPerTokenStored;
    mapping(address => uint256)[2] public userRewardPerTokenPaid;
    mapping(address => uint256)[2] public unclaimedRewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;


    constructor(
        address _stakingToken,
        address _rewardsDistributor,
        address _varenToken,
        address _extraRewardToken, // optional
        uint256 _rewardsDuration,
        address _owner
    ) {
        require(
            _rewardsDistributor != address(0) &&
                _varenToken != address(0) &&
                _stakingToken != address(0),
            "address(0)"
        );
        require(_rewardsDuration > 0, "rewardsDuration=0");
        rewardsDistributor = _rewardsDistributor;
        rewardTokens[0] = IERC20(_varenToken);
        rewardTokens[1] = IERC20(_extraRewardToken);
        stakingToken = IERC20(_stakingToken);
        rewardsDuration = _rewardsDuration;
        owner = _owner;
    }


    modifier updateReward(address account) {

        rewardPerTokenStored[0] = rewardPerToken(0);
        if (address(rewardTokens[1]) != address(0)) rewardPerTokenStored[1] = rewardPerToken(1);
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            unclaimedRewards[0][account] = earned(account, 0);
            unclaimedRewards[1][account] = earned(account, 1);
            userRewardPerTokenPaid[0][account] = rewardPerTokenStored[0];
            userRewardPerTokenPaid[1][account] = rewardPerTokenStored[1];
        }
        _;
    }


    function totalSupply() external view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {

        return _balances[account];
    }

    function getRewardForDuration(uint256 rewardTokenIndex) external view override returns (uint256) {

        return rewardRate[rewardTokenIndex].mul(rewardsDuration);
    }

    function lastTimeRewardApplicable() public view override returns (uint256) {

        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken(uint256 rewardTokenIndex) public view override returns (uint256) {

        if (_totalSupply == 0) {
            return rewardPerTokenStored[rewardTokenIndex];
        }
        return
            rewardPerTokenStored[rewardTokenIndex].add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate[rewardTokenIndex])
                    .mul(1e18)
                    .div(_totalSupply)
            );
    }

    function earned(address account, uint256 rewardTokenIndex) public view override returns (uint256) {

        return
            _balances[account]
                .mul(
                rewardPerToken(rewardTokenIndex).sub(
                    userRewardPerTokenPaid[rewardTokenIndex][account]
                )
            )
                .div(1e18)
                .add(unclaimedRewards[rewardTokenIndex][account]);
    }


    function stakeWithPermit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant updateReward(msg.sender) {

        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        ILinkswapERC20(address(stakingToken)).permit(
            msg.sender,
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function stake(uint256 amount) external override nonReentrant updateReward(msg.sender) {

        _stake(amount);
    }

    function unstakeAndClaimRewards(uint256 unstakeAmount)
        external override
        nonReentrant
        updateReward(msg.sender)
    {

        _unstake(unstakeAmount);
        _claimReward(0);
        _claimReward(1);
    }

    function unstake(uint256 amount) external override nonReentrant updateReward(msg.sender) {

        _unstake(amount);
    }

    function claimRewards() external override nonReentrant updateReward(msg.sender) {

        _claimReward(0);
        _claimReward(1);
    }


    function _stake(uint256 amount) private {

        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function _unstake(uint256 amount) private {

        require(amount > 0, "Cannot unstake 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    function _claimReward(uint256 rewardTokenIndex) private {

        uint256 rewardAmount = unclaimedRewards[rewardTokenIndex][msg.sender];
        if (rewardAmount > 0) {
            uint256 rewardsBal = rewardTokens[rewardTokenIndex].balanceOf(address(this));
            if (rewardsBal == 0) return;
            rewardAmount = rewardsBal < rewardAmount ? rewardsBal : rewardAmount;
            unclaimedRewards[rewardTokenIndex][msg.sender] = unclaimedRewards[rewardTokenIndex][msg
                .sender]
                .sub(rewardAmount);
            rewardTokens[rewardTokenIndex].safeTransfer(msg.sender, rewardAmount);
            emit RewardPaid(msg.sender, address(rewardTokens[rewardTokenIndex]), rewardAmount);
        }
    }


    function notifyRewardAmount(uint256 amount, uint256 extraAmount)
        external override
        onlyRewardsDistributor
        updateReward(address(0))
    {

        require(amount > 0 || extraAmount > 0, "zero amount");
        if (extraAmount > 0) {
            require(address(rewardTokens[1]) != address(0), "extraRewardToken=0x0");
        }
        if (block.timestamp >= periodFinish) {
            rewardRate[0] = amount.div(rewardsDuration);
            if (extraAmount > 0) rewardRate[1] = extraAmount.div(rewardsDuration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate[0]);
            rewardRate[0] = amount.add(leftover).div(rewardsDuration);
            if (extraAmount > 0) {
                leftover = remaining.mul(rewardRate[1]);
                rewardRate[1] = extraAmount.add(leftover).div(rewardsDuration);
            }
        }

        uint256 balance = rewardTokens[0].balanceOf(address(this));
        require(rewardRate[0] <= balance.div(rewardsDuration), "Provided reward too high");
        if (extraAmount > 0) {
            balance = rewardTokens[1].balanceOf(address(this));
            require(
                rewardRate[1] <= balance.div(rewardsDuration),
                "Provided extra reward too high"
            );
        }

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(address(rewardTokens[0]), amount);
        if (extraAmount > 0) emit RewardAdded(address(rewardTokens[1]), extraAmount);
    }
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}pragma solidity 0.8.6;



contract StakingRewardsFactory is Ownable {

    struct StakingRewardsInfo {
        address stakingRewards;
        uint256 varenRewardAmount;
        address extraRewardToken;
        uint256 extraRewardTokenAmount;
    }

    address public varenToken;
    uint256 public stakingRewardsGenesis;

    address[] public stakingTokens;

    mapping(address => StakingRewardsInfo) public stakingRewardsInfoByStakingToken;

    constructor(address _varenToken, uint256 _stakingRewardsGenesis) Ownable() {
        require(_varenToken != address(0), "varenToken=0x0");
        require(_stakingRewardsGenesis >= block.timestamp, "genesis<timestamp");
        varenToken = _varenToken;
        stakingRewardsGenesis = _stakingRewardsGenesis;
    }


    function deploy(
        address _stakingToken,
        uint256 _varenRewardAmount,
        address _extraRewardToken, // optional
        uint256 _extraRewardTokenAmount,
        uint256 _rewardsDuration
    ) external onlyOwner {

        require(_stakingToken != address(0), "stakingToken=0x0");
        require(_stakingToken != varenToken, "stakingToken=varenToken");
        require(_stakingToken != _extraRewardToken, "stakingToken=extraRewardToken");
        require(_extraRewardToken != varenToken, "extraRewardToken=varenToken");
        require(_varenRewardAmount > 0 || _extraRewardTokenAmount > 0, "amounts=0");
        if (_extraRewardToken == address(0)) {
            require(_extraRewardTokenAmount == 0, "extraRewardTokenAmount!=0");
        } else {
            require(_extraRewardTokenAmount > 0, "extraRewardTokenAmount=0");
        }
        require(_rewardsDuration > 0, "rewardsDuration=0");
        StakingRewardsInfo storage info = stakingRewardsInfoByStakingToken[_stakingToken];
        require(info.stakingRewards == address(0), "already deployed");

        info.stakingRewards = address(
            new StakingRewards(
                _stakingToken,
                address(this), // rewardsDistributor
                varenToken,
                _extraRewardToken,
                _rewardsDuration,
                owner()
            )
        );
        info.varenRewardAmount = _varenRewardAmount;
        info.extraRewardToken = _extraRewardToken;
        info.extraRewardTokenAmount = _extraRewardTokenAmount;
        stakingTokens.push(_stakingToken);
    }


    function notifyRewardAmounts() external {

        require(stakingTokens.length > 0, "no deploys yet");
        for (uint256 i = 0; i < stakingTokens.length; i++) {
            notifyRewardAmount(stakingTokens[i]);
        }
    }

    function notifyRewardAmount(address _stakingToken) public {

        require(block.timestamp >= stakingRewardsGenesis, "timestamp<genesis");

        StakingRewardsInfo storage info = stakingRewardsInfoByStakingToken[_stakingToken];
        require(info.stakingRewards != address(0), "not deployed");

        uint256 rewardAmount = info.varenRewardAmount;
        uint256 extraRewardAmount = info.extraRewardTokenAmount;
        if (rewardAmount == 0 && extraRewardAmount == 0) return;

        if (rewardAmount > 0) {
            info.varenRewardAmount = 0;
            require(
                IERC20(varenToken).transfer(info.stakingRewards, rewardAmount),
                "transfer failed"
            );
        }
        if (extraRewardAmount > 0) {
            info.extraRewardTokenAmount = 0;
            require(
                IERC20(info.extraRewardToken).transfer(info.stakingRewards, extraRewardAmount),
                "transfer failed"
            );
        }
        StakingRewards(info.stakingRewards).notifyRewardAmount(rewardAmount, extraRewardAmount);
    }
}