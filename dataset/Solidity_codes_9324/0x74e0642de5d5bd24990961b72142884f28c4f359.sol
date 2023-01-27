
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

interface IERC20Permit {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

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
}// MIT
pragma solidity 0.8.10;


struct Rewards {
    uint128 userRewardPerTokenPaid; // reward per token already paid
    uint128 rewardToPay; // stored amount of reward torken to pay
}

struct RewardToken {
    uint16 index; // index in rewardsTokensArray
    uint32 periodFinish; // time in seconds rewards will end
    uint32 lastUpdateTime; // last time reward info was updated
    uint128 rewardPerTokenStored; // reward per token
    uint128 rewardRate; // how many reward tokens to give out per second
    mapping(address => Rewards) rewards;
}

struct AppStorage {
    address rewardsDistribution;
    IERC20 stakingToken;
    address[] rewardTokensArray;
    uint256 totalSupply;
    mapping(address => uint256) balances;
    mapping(address => RewardToken) rewardTokens;
}

contract MegaPool {

    AppStorage internal s;

    constructor(address _rewardsDistribution, address _stakingToken) {
        s.stakingToken = IERC20(_stakingToken);
        s.rewardsDistribution = _rewardsDistribution;
    }

    function rewardsDistribution() external view returns (address) {

        return s.rewardsDistribution;
    }

    function transferRewardsDistribution(address _newRewardsDistribution)
        external
    {

        require(
            s.rewardsDistribution == msg.sender,
            "Transfer rewards distribution not authorized"
        );
        emit RewardsDistributionTransferred(
            s.rewardsDistribution,
            _newRewardsDistribution
        );
        s.rewardsDistribution = _newRewardsDistribution;
    }

    function totalSupply() external view returns (uint256 totalSupply_) {

        totalSupply_ = s.totalSupply;
    }

    function stakingToken() external view returns (address) {

        return address(s.stakingToken);
    }

    function rewardTokensArray()
        external
        view
        returns (address[] memory rewardTokens_)
    {

        return s.rewardTokensArray;
    }

    function balanceOf(address _account) external view returns (uint256) {

        return s.balances[_account];
    }

    struct RewardTokenInfo {
        uint256 index; // index in rewardsTokensArray
        uint256 periodFinish; // rewards end at this time in seconds
        uint256 rewardRate; // how many reward tokens per second
        uint256 rewardPerTokenStored; // how many reward tokens per staked token stored
        uint256 lastUpdateTime; // last time tht rewar
    }

    function rewardTokenInfo(address _rewardToken)
        external
        view
        returns (RewardTokenInfo memory)
    {

        return
            RewardTokenInfo({
                index: s.rewardTokens[_rewardToken].index,
                periodFinish: s.rewardTokens[_rewardToken].periodFinish,
                rewardRate: s.rewardTokens[_rewardToken].rewardRate,
                rewardPerTokenStored: s
                    .rewardTokens[_rewardToken]
                    .rewardPerTokenStored,
                lastUpdateTime: s.rewardTokens[_rewardToken].lastUpdateTime
            });
    }

    function lastTimeRewardApplicable(address _rewardToken)
        internal
        view
        returns (uint256)
    {

        uint256 periodFinish = s.rewardTokens[_rewardToken].periodFinish;
        return block.timestamp > periodFinish ? periodFinish : block.timestamp;
    }

    function rewardPerToken(address _rewardToken)
        internal
        view
        returns (uint256 rewardPerToken_, uint256 lastTimeRewardApplicable_)
    {

        RewardToken storage rewardToken = s.rewardTokens[_rewardToken];
        uint256 l_totalSupply = s.totalSupply;
        uint256 lastUpdateTime = rewardToken.lastUpdateTime;
        lastTimeRewardApplicable_ = lastTimeRewardApplicable(_rewardToken);
        if (lastUpdateTime == 0 || l_totalSupply == 0) {
            rewardPerToken_ = rewardToken.rewardPerTokenStored;
        } else {
            rewardPerToken_ =
                rewardToken.rewardPerTokenStored +
                ((lastTimeRewardApplicable_ - lastUpdateTime) *
                    rewardToken.rewardRate *
                    1e18) /
                l_totalSupply;
        }
    }

    function earned(address _rewardToken, address _account)
        external
        view
        returns (uint256)
    {

        (uint256 l_rewardPerToken, ) = rewardPerToken(_rewardToken);
        return internalEarned(l_rewardPerToken, _rewardToken, _account);
    }

    function internalEarned(
        uint256 _rewardPerToken,
        address _rewardToken,
        address _account
    ) internal view returns (uint256) {

        RewardToken storage rewardToken = s.rewardTokens[_rewardToken];
        return
            (s.balances[_account] *
                (_rewardPerToken -
                    rewardToken.rewards[_account].userRewardPerTokenPaid)) /
            1e18 +
            rewardToken.rewards[_account].rewardToPay;
    }

    struct Earned {
        address rewardToken;
        uint256 earned;
    }

    function earned(address _account)
        external
        view
        returns (Earned[] memory earned_)
    {

        earned_ = new Earned[](s.rewardTokensArray.length);
        for (uint256 i; i < earned_.length; i++) {
            address rewardTokenAddress = s.rewardTokensArray[i];
            earned_[i].rewardToken = rewardTokenAddress;
            (uint256 l_rewardPerToken, ) = rewardPerToken(rewardTokenAddress);
            earned_[i].earned = internalEarned(
                l_rewardPerToken,
                rewardTokenAddress,
                _account
            );
        }
    }

    function stakeWithPermit(
        uint256 _amount,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {

        require(_amount > 0, "Cannot stake 0");
        updateRewardAll(msg.sender);
        IERC20 l_stakingToken = s.stakingToken;
        s.totalSupply += _amount;
        s.balances[msg.sender] += _amount;
        emit Staked(msg.sender, _amount);
        IERC20Permit(address(l_stakingToken)).permit(
            msg.sender,
            address(this),
            _amount,
            _deadline,
            _v,
            _r,
            _s
        );

        SafeERC20.safeTransferFrom(
            l_stakingToken,
            msg.sender,
            address(this),
            _amount
        );
    }

    function stake(uint256 _amount) external {

        require(_amount > 0, "Cannot stake 0");
        updateRewardAll(msg.sender);
        s.totalSupply += _amount;
        s.balances[msg.sender] += _amount;
        emit Staked(msg.sender, _amount);
        SafeERC20.safeTransferFrom(
            s.stakingToken,
            msg.sender,
            address(this),
            _amount
        );
    }

    function getRewards() public {

        uint256 length = s.rewardTokensArray.length;
        for (uint256 i; i < length; ) {
            address rewardTokenAddress = s.rewardTokensArray[i];
            uint256 rewardToPay = updateReward(rewardTokenAddress, msg.sender);
            RewardToken storage rewardToken = s.rewardTokens[
                rewardTokenAddress
            ];
            if (rewardToPay > 0) {
                rewardToken.rewards[msg.sender].rewardToPay = 0;
                emit RewardPaid(rewardTokenAddress, msg.sender, rewardToPay);
                SafeERC20.safeTransfer(
                    IERC20(rewardTokenAddress),
                    msg.sender,
                    rewardToPay
                );
            }
            unchecked {
                i++;
            }
        }
    }

    function getSpecificRewards(address[] calldata _rewardTokensArray)
        external
    {

        for (uint256 i; i < _rewardTokensArray.length; ) {
            address rewardTokenAddress = _rewardTokensArray[i];
            RewardToken storage rewardToken = s.rewardTokens[
                rewardTokenAddress
            ];
            uint256 index = rewardToken.index;
            require(
                s.rewardTokensArray[index] == rewardTokenAddress,
                "Reward token address does not exist"
            );
            uint256 rewardToPay = updateReward(rewardTokenAddress, msg.sender);
            if (rewardToPay > 0) {
                rewardToken.rewards[msg.sender].rewardToPay = 0;
                emit RewardPaid(rewardTokenAddress, msg.sender, rewardToPay);
                SafeERC20.safeTransfer(
                    IERC20(rewardTokenAddress),
                    msg.sender,
                    rewardToPay
                );
            }
            unchecked {
                i++;
            }
        }
    }

    function withdraw(uint256 _amount) public {

        require(_amount > 0, "Cannot withdraw 0");
        uint256 balance = s.balances[msg.sender];
        require(_amount <= balance, "Can't withdraw more than staked");
        updateRewardAll(msg.sender);
        s.totalSupply -= _amount;
        s.balances[msg.sender] = balance - _amount;
        emit Withdrawn(msg.sender, _amount);
        SafeERC20.safeTransfer(s.stakingToken, msg.sender, _amount);
    }

    function withdrawAll() external {

        withdraw(s.balances[msg.sender]);
    }

    function exit() external {

        getRewards();
        uint256 amount = s.balances[msg.sender];
        s.totalSupply -= amount;
        s.balances[msg.sender] = 0;
        emit Withdrawn(msg.sender, amount);
        SafeERC20.safeTransfer(s.stakingToken, msg.sender, amount);
    }

    function updateRewardAll(address _account) internal {

        uint256 length = s.rewardTokensArray.length;
        for (uint256 i; i < length; ) {
            address rewardTokenAddress = s.rewardTokensArray[i];
            updateReward(rewardTokenAddress, _account);
            unchecked {
                i++;
            }
        }
    }

    function updateReward(address _rewardToken, address _account)
        internal
        returns (uint256 rewardToPay_)
    {

        RewardToken storage rewardToken = s.rewardTokens[_rewardToken];
        (uint256 l_rewardPerToken, uint256 lastUpdateTime) = rewardPerToken(
            _rewardToken
        );
        rewardToken.rewardPerTokenStored = uint128(l_rewardPerToken);
        rewardToken.lastUpdateTime = uint32(lastUpdateTime);
        rewardToPay_ = internalEarned(l_rewardPerToken, _rewardToken, _account);
        rewardToken.rewards[_account].rewardToPay = uint128(rewardToPay_);
        rewardToken.rewards[_account].userRewardPerTokenPaid = uint128(
            l_rewardPerToken
        );
    }

    struct RewardTokenArgs {
        address rewardToken; // ERC20 address
        uint256 reward; // total reward amount
        uint256 rewardDuration; // how many seconds rewards are distributed
    }

    function notifyRewardAmount(RewardTokenArgs[] calldata _args) external {

        require(
            msg.sender == s.rewardsDistribution,
            "Caller is not RewardsDistribution"
        );
        require(
            s.rewardTokensArray.length + _args.length <= 200,
            "Too many reward tokens"
        );
        for (uint256 i; i < _args.length; ) {
            RewardTokenArgs calldata args = _args[i];
            RewardToken storage rewardToken = s.rewardTokens[args.rewardToken];
            uint256 oldPeriodFinish = rewardToken.periodFinish;
            require(
                block.timestamp + args.rewardDuration >= oldPeriodFinish,
                "Cannot reduce existing period"
            );
            uint256 rewardRate;
            if (block.timestamp >= oldPeriodFinish) {
                require(
                    args.reward <= type(uint128).max,
                    "Reward is too large"
                );
                rewardRate = args.reward / args.rewardDuration;
            } else {
                uint256 remaining = oldPeriodFinish - block.timestamp;
                uint256 leftover = remaining * rewardToken.rewardRate;
                uint256 reward = args.reward + leftover;
                require(reward <= type(uint128).max, "Reward is too large");
                rewardRate = reward / args.rewardDuration;
            }
            (uint256 l_rewardPerToken, ) = rewardPerToken(args.rewardToken);
            rewardToken.rewardPerTokenStored = uint128(l_rewardPerToken);
            uint256 periodFinish = block.timestamp + args.rewardDuration;
            if (oldPeriodFinish == 0) {
                rewardToken.index = uint16(s.rewardTokensArray.length);
                s.rewardTokensArray.push(args.rewardToken);
            }
            rewardToken.periodFinish = uint32(periodFinish);
            rewardToken.lastUpdateTime = uint32(block.timestamp);
            rewardToken.rewardRate = uint128(rewardRate);
            emit RewardAdded(args.rewardToken, args.reward, periodFinish);

            uint256 balance = IERC20(args.rewardToken).balanceOf(address(this));
            require(
                rewardRate <= balance / args.rewardDuration,
                "Provided reward not in contract"
            );
            unchecked {
                i++;
            }
        }
    }

    event RewardAdded(
        address indexed rewardToken,
        uint256 reward,
        uint256 periodFinish
    );
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(
        address indexed rewardToken,
        address indexed user,
        uint256 reward
    );
    event RewardsDistributionTransferred(
        address indexed oldRewardsDistribution,
        address indexed newRewardsDistribution
    );
}