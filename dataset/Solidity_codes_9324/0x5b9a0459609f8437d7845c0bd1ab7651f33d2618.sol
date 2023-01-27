
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
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function decimals() external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

        return (a & b) + (a ^ b) / 2;
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
}//MIT

pragma solidity ^0.8.0;


contract MultiRewardsStake is ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public stakingToken;
    uint256 public periodFinish;
    uint256 public rewardsDuration;
    uint256 public lastUpdateTime;
    
    mapping(address => mapping (address => uint256)) private _userRewardPerTokenPaid;
    mapping(address => mapping (address => uint256)) private _rewards;

    uint256 private _totalRewardTokens;
    mapping (uint => RewardToken) private _rewardTokens;
    mapping (address => uint) private _rewardTokenToIndex;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    struct RewardToken {
        address token;
        uint256 rewardRate;
        uint256 rewardPerTokenStored;
    }

    constructor(
        address[] memory rewardTokens_,
        address stakingToken_
    ) {
        stakingToken = IERC20(stakingToken_);
        _totalRewardTokens = rewardTokens_.length;

        for (uint i; i < rewardTokens_.length; i++) {
            _rewardTokens[i + 1] = RewardToken({
                token: rewardTokens_[i],
                rewardRate: 0,
                rewardPerTokenStored: 0
            });
            _rewardTokenToIndex[rewardTokens_[i]] = i + 1;
        }

        rewardsDuration = 14 days;
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

    function totalRewardTokens() external view returns (uint256) {

        return _totalRewardTokens;
    }

    function rewardPerToken() public view returns (uint256[] memory) {

        uint256[] memory tokens = new uint256[](_totalRewardTokens);
        if (_totalSupply == 0) {
            for (uint i = 0; i < _totalRewardTokens; i++) {
                tokens[i] = _rewardTokens[i + 1].rewardPerTokenStored;
            }
        } else {
            for (uint i = 0; i < _totalRewardTokens; i++) {
                RewardToken storage rewardToken = _rewardTokens[i + 1];
                tokens[i] = rewardToken.rewardPerTokenStored.add(
                    lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardToken.rewardRate)
                    .mul(1e18)
                    .div(_totalSupply)
                );
            }
        }

        return tokens;
    }

    function rewardForToken(address token) public view returns (uint256) {

        uint256 index = _rewardTokenToIndex[token];
        if (_totalSupply == 0) {
            return _rewardTokens[index].rewardPerTokenStored;
        } else {
            return _rewardTokens[index].rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                .sub(lastUpdateTime)
                .mul(_rewardTokens[index].rewardRate)
                .mul(1e18)
                .div(_totalSupply)
            );
        }
    }

    function getRewardTokens() public view returns (RewardToken[] memory) {

        RewardToken[] memory tokens = new RewardToken[](_totalRewardTokens);
        for (uint i = 0; i < _totalRewardTokens; i++) {
            tokens[i] = _rewardTokens[i + 1];
        }

        return tokens;
    }

    function earned(address account) public view returns (uint256[] memory) {

        uint256[] memory earnings = new uint256[](_totalRewardTokens);
        uint256[] memory tokenRewards = rewardPerToken();
        for (uint i = 0; i < _totalRewardTokens; i++) {
            address token = _rewardTokens[i + 1].token;
            earnings[i] = _balances[account]
                .mul(tokenRewards[i]
                    .sub(_userRewardPerTokenPaid[account][token])
                )
                .div(1e18)
                .add(_rewards[account][token]
            );
        }

        return earnings;
    }

    function getRewardForDuration() external view returns (uint256[] memory) {

        uint256[] memory currentRewards = new uint256[](_totalRewardTokens);
        for (uint i = 0; i < _totalRewardTokens; i++) {
            currentRewards[i] = _rewardTokens[i + 1].rewardRate.mul(rewardsDuration);
        }

        return currentRewards;
    }


    function stake(uint256 amount) external nonReentrant updateReward(msg.sender) {

        require(amount > 0, "Cannot stake 0");
        uint256 currentBalance = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        uint256 newBalance = stakingToken.balanceOf(address(this));
        uint256 supplyDiff = newBalance.sub(currentBalance);
        _totalSupply = _totalSupply.add(supplyDiff);
        _balances[msg.sender] = _balances[msg.sender].add(supplyDiff);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {

        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant updateReward(msg.sender) {

        for (uint i = 0; i < _totalRewardTokens; i++) {
            uint256 currentReward = _rewards[msg.sender][_rewardTokens[i + 1].token];
            if (currentReward > 0) {
                _rewards[msg.sender][_rewardTokens[i + 1].token] = 0;
                IERC20(_rewardTokens[i + 1].token).safeTransfer(msg.sender, currentReward);
                emit RewardPaid(msg.sender, currentReward);
            }
        }
    }

    function exit() external {

        withdraw(_balances[msg.sender]);
        getReward();
    }


    function depositRewardTokens(uint256[] memory amount) external onlyOwner {

        require(amount.length == _totalRewardTokens, "Wrong amounts");

        for (uint i = 0; i < _totalRewardTokens; i++) {
            RewardToken storage rewardToken = _rewardTokens[i + 1];
            uint256 prevBalance = IERC20(rewardToken.token).balanceOf(address(this));
            IERC20(rewardToken.token).safeTransferFrom(msg.sender, address(this), amount[i]);
            uint reward = IERC20(rewardToken.token).balanceOf(address(this)).sub(prevBalance);
            if (block.timestamp >= periodFinish) {
                rewardToken.rewardRate = reward.div(rewardsDuration);
            } else {
                uint256 remaining = periodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardToken.rewardRate);
                rewardToken.rewardRate = reward.add(leftover).div(rewardsDuration);
            }

            uint256 balance = IERC20(rewardToken.token).balanceOf(address(this));
            require(rewardToken.rewardRate <= balance.div(rewardsDuration), "Reward too high");
            emit RewardAdded(reward);
        }

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);

    }

    function notifyRewardAmount(uint256[] memory reward) public onlyOwner updateReward(address(0)) {

        require(reward.length == _totalRewardTokens, "Wrong reward amounts");
        for (uint i = 0; i < _totalRewardTokens; i++) {
            RewardToken storage rewardToken = _rewardTokens[i + 1];
            if (block.timestamp >= periodFinish) {
                rewardToken.rewardRate = reward[i].div(rewardsDuration);
            } else {
                uint256 remaining = periodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardToken.rewardRate);
                rewardToken.rewardRate = reward[i].add(leftover).div(rewardsDuration);
            }

            uint256 balance = IERC20(rewardToken.token).balanceOf(address(this));
            require(rewardToken.rewardRate <= balance.div(rewardsDuration), "Reward too high");
            emit RewardAdded(reward[i]);
        }

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
    }

    function addRewardToken(address token) external onlyOwner {

        require(_totalRewardTokens < 6, "Too many tokens");
        require(IERC20(token).balanceOf(address(this)) > 0, "Must prefund contract");

        _totalRewardTokens += 1;

        _rewardTokens[_totalRewardTokens] = RewardToken({
            token: token,
            rewardRate: 0,
            rewardPerTokenStored: 0
        });

        _rewardTokenToIndex[token] = _totalRewardTokens;

        uint256[] memory rewardAmounts = new uint256[](_totalRewardTokens);

        for (uint i = 0; i < _totalRewardTokens; i++) {
            if (i == _totalRewardTokens - 1) {
                rewardAmounts[i] = IERC20(token).balanceOf(address(this));
            }
        }

        notifyRewardAmount(rewardAmounts);
    }

    function removeRewardToken(address token) public onlyOwner updateReward(address(0)) {

        require(_totalRewardTokens > 1, "Cannot have 0 reward tokens");
        uint indexToDelete = _rewardTokenToIndex[token];

        for (uint i = indexToDelete; i <= _totalRewardTokens; i++) {
            RewardToken storage rewardToken = _rewardTokens[i + 1];

            _rewardTokens[i] = rewardToken;

            delete _rewardTokens[i + 1];

            _rewardTokenToIndex[rewardToken.token] = i;
        }

        _totalRewardTokens -= 1;
    }

    function emergencyWithdrawal(address token) external onlyOwner updateReward(address(0)) {

        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "Contract holds no tokens");
        IERC20(token).transfer(owner(), balance);
        removeRewardToken(token);
    }


    modifier updateReward(address account) {

        uint256[] memory rewardsPerToken = rewardPerToken();
        uint256[] memory currentEarnings = earned(account);
        lastUpdateTime = lastTimeRewardApplicable();
        for (uint i = 0; i < _totalRewardTokens; i++) {
            RewardToken storage rewardToken = _rewardTokens[i + 1];
            rewardToken.rewardPerTokenStored = rewardsPerToken[i];
            if (account != address(0)) {
                _rewards[account][rewardToken.token] = currentEarnings[i];
                _userRewardPerTokenPaid[account][rewardToken.token] = rewardsPerToken[i];                
            }
        }
        _;
    }


    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
}