
pragma solidity ^0.6.0;

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

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.2;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.6.0;


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
}pragma solidity >=0.6.0 <0.8.0;


library SafeAmount {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount) internal returns (uint256)  {

        uint256 preBalance = IERC20(token).balanceOf(to);
        IERC20(token).transferFrom(from, to, amount);
        uint256 postBalance = IERC20(token).balanceOf(to);
        return postBalance.sub(preBalance);
    }
}pragma solidity >=0.6.0 <0.8.0;

library FestakedLib {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    event Staked(address indexed token, address indexed staker_, uint256 requestedAmount_, uint256 stakedAmount_);
    event PaidOut(address indexed token, address indexed rewardToken, address indexed staker_, uint256 amount_, uint256 reward_);

    struct FestakeState {
        uint256 stakedTotal;
        uint256 stakingCap;
        uint256 stakedBalance;
        uint256 withdrawnEarly;
        mapping(address => uint256) _stakes;
    }

    struct FestakeRewardState {
        uint256 rewardBalance;
        uint256 rewardsTotal;
        uint256 earlyWithdrawReward;
    }

    function VERSION() external pure returns(uint) {

        return 1001;
    }

    function tryStake(address payer, address staker, uint256 amount,
        uint256 stakingStarts,
        uint256 stakingEnds,
        uint256 stakingCap,
        address tokenAddress,
        FestakeState storage state
        )
    public
    _after(stakingStarts)
    _before(stakingEnds)
    _positive(amount)
    returns (uint256) {

        uint256 remaining = amount;
        {
        uint256 stakedBalance = state.stakedBalance;
        if (stakingCap > 0 && remaining > (stakingCap.sub(stakedBalance))) {
            remaining = stakingCap.sub(stakedBalance);
        }
        }
        require(remaining > 0, "Festaking: Staking cap is filled");
        remaining = _payMe(payer, remaining, tokenAddress);
        emit Staked(tokenAddress, staker, amount, remaining);

        return remaining;
    }

    function stake(address payer, address staker, uint256 amount,
        uint256 stakingStarts,
        uint256 stakingEnds,
        uint256 stakingCap,
        address tokenAddress,
        FestakeState storage state
        )
    external
    returns (bool) {

        uint256 remaining = tryStake(payer, staker, amount,
            stakingStarts, stakingEnds, stakingCap, tokenAddress, state);

        state.stakedBalance = state.stakedBalance.add(remaining);
        state.stakedTotal = state.stakedTotal.add(remaining);
        state._stakes[staker] = state._stakes[staker].add(remaining);
        return true;
    }

    function addReward(
        uint256 rewardAmount,
        uint256 withdrawableAmount,
        address rewardTokenAddress,
        FestakeRewardState storage state
    )
    external
    returns (bool) {

        require(rewardAmount > 0, "Festaking: reward must be positive");
        require(withdrawableAmount >= 0, "Festaking: withdrawable amount cannot be negative");
        require(withdrawableAmount <= rewardAmount, "Festaking: withdrawable amount must be less than or equal to the reward amount");
        address from = msg.sender;
        rewardAmount = _payMe(from, rewardAmount, rewardTokenAddress);
        state.rewardsTotal = state.rewardsTotal.add(rewardAmount);
        state.rewardBalance = state.rewardBalance.add(rewardAmount);
        state.earlyWithdrawReward = state.earlyWithdrawReward.add(withdrawableAmount);
        return true;
    }

    function addMarginalReward(
        address rewardTokenAddress,
        address tokenAddress,
        address me,
        uint256 stakedBalance,
        FestakeRewardState storage state)
        external
        returns (bool) {

        uint256 amount = IERC20(rewardTokenAddress).balanceOf(me).sub(state.rewardsTotal);
        if (rewardTokenAddress == tokenAddress) {
            amount = amount.sub(stakedBalance);
        }
        if (amount == 0) {
            return true; // No reward to add. Its ok. No need to fail callers.
        }
        state.rewardsTotal = state.rewardsTotal.add(amount);
        state.rewardBalance = state.rewardBalance.add(amount);
        return true;
    }

    function tryWithdraw(
        address from,
        address tokenAddress,
        address rewardTokenAddress,
        uint256 amount,
        uint256 withdrawStarts,
        uint256 withdrawEnds,
        uint256 stakingEnds,
        FestakeState storage state,
        FestakeRewardState storage rewardState
    )
    public
    _after(withdrawStarts)
    _positive(amount)
    _realAddress(msg.sender)
    returns (uint256) {

        require(amount <= state._stakes[from], "Festaking: not enough balance");
        if (now < withdrawEnds) {
            return _withdrawEarly(tokenAddress, rewardTokenAddress, from, amount, withdrawEnds,
                stakingEnds, state, rewardState);
        } else {
            return _withdrawAfterClose(tokenAddress, rewardTokenAddress, from, amount, state, rewardState);
        }
    }

    function withdraw(
        address from,
        address tokenAddress,
        address rewardTokenAddress,
        uint256 amount,
        uint256 withdrawStarts,
        uint256 withdrawEnds,
        uint256 stakingEnds,
        FestakeState storage state,
        FestakeRewardState storage rewardState
    )
    public
    returns (bool) {

        uint256 wdAmount = tryWithdraw(from, tokenAddress, rewardTokenAddress, amount, withdrawStarts,
            withdrawEnds, stakingEnds, state, rewardState);
        state.stakedBalance = state.stakedBalance.sub(wdAmount);
        state._stakes[from] = state._stakes[from].sub(wdAmount);
        return true;
    }

    function _withdrawEarly(
        address tokenAddress,
        address rewardTokenAddress,
        address from,
        uint256 amount,
        uint256 withdrawEnds,
        uint256 stakingEnds,
        FestakeState storage state,
        FestakeRewardState storage rewardState
    )
    private
    _realAddress(from)
    returns (uint256) {

        uint256 denom = (withdrawEnds.sub(stakingEnds)).mul(state.stakedTotal);
        uint256 reward = (
        ( (now.sub(stakingEnds)).mul(rewardState.earlyWithdrawReward) ).mul(amount)
        ).div(denom);
        rewardState.rewardBalance = rewardState.rewardBalance.sub(reward);
        bool principalPaid = _payDirect(from, amount, tokenAddress);
        bool rewardPaid = _payDirect(from, reward, rewardTokenAddress);
        require(principalPaid && rewardPaid, "Festaking: error paying");
        emit PaidOut(tokenAddress, rewardTokenAddress, from, amount, reward);
        return amount;
    }

    function _withdrawAfterClose(
        address tokenAddress,
        address rewardTokenAddress,
        address from,
        uint256 amount,
        FestakeState storage state,
        FestakeRewardState storage rewardState
    ) private
    _realAddress(from)
    returns (uint256) {

        uint256 rewBal = rewardState.rewardBalance;
        uint256 reward = (rewBal.mul(amount)).div(state.stakedBalance);
        rewardState.rewardBalance = rewBal.sub(reward);
        bool principalPaid = _payDirect(from, amount, tokenAddress);
        bool rewardPaid = _payDirect(from, reward, rewardTokenAddress);
        require(principalPaid && rewardPaid, "Festaking: error paying");
        emit PaidOut(tokenAddress, rewardTokenAddress, from, amount, reward);
        return amount;
    }

    function _payMe(address payer, uint256 amount, address token)
    internal
    returns (uint256) {

        return _payTo(payer, address(this), amount, token);
    }

    function _payTo(address allower, address receiver, uint256 amount, address token)
    internal
    returns (uint256) {

        return SafeAmount.safeTransferFrom(token, allower, receiver, amount);
    }

    function _payDirect(address to, uint256 amount, address token)
    private
    returns (bool) {

        if (amount == 0) {
            return true;
        }
        IERC20(token).safeTransfer(to, amount);
        return true;
    }

    modifier _realAddress(address addr) {

        require(addr != address(0), "Festaking: zero address");
        _;
    }

    modifier _positive(uint256 amount) {

        require(amount != 0, "Festaking: negative amount");
        _;
    }

    modifier _after(uint eventTime) {

        require(now >= eventTime, "Festaking: bad timing for the request");
        _;
    }

    modifier _before(uint eventTime) {

        require(now < eventTime, "Festaking: bad timing for the request");
        _;
    }
}pragma solidity >=0.6.0 <0.8.0;

interface IFestaked {

    
    event Staked(address indexed token, address indexed staker_, uint256 requestedAmount_, uint256 stakedAmount_);
    event PaidOut(address indexed token, address indexed rewardToken, address indexed staker_, uint256 amount_, uint256 reward_);

    function stake (uint256 amount) external returns (bool);

    function stakeFor (address staker, uint256 amount) external returns (bool);

    function stakeOf(address account) external view returns (uint256);


    function tokenAddress() external view returns (address);


    function stakedTotal() external view returns (uint256);


    function stakedBalance() external view returns (uint256);


    function stakingStarts() external view returns (uint256);


    function stakingEnds() external view returns (uint256);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract FestakedOptimized is IFestaked {

    mapping (address => uint256) internal _stakes;

    string private _name;
    address  public override tokenAddress;
    uint public override stakingStarts;
    uint public override stakingEnds;
    uint public withdrawStarts;
    uint public withdrawEnds;
    uint public stakingCap;
    FestakedLib.FestakeState public stakeState;
    uint constant LIB_VERSION = 1001;

    constructor (
        string memory name_,
        address tokenAddress_,
        uint stakingStarts_,
        uint stakingEnds_,
        uint withdrawStarts_,
        uint withdrawEnds_,
        uint256 stakingCap_) public {
        require(FestakedLib.VERSION() == LIB_VERSION, "Bad linked library version");
        _name = name_;
        require(tokenAddress_ != address(0), "Festaking: 0 address");
        tokenAddress = tokenAddress_;

        require(stakingStarts_ > 0, "Festaking: zero staking start time");
        if (stakingStarts_ < now) {
            stakingStarts = now;
        } else {
            stakingStarts = stakingStarts_;
        }

        require(stakingEnds_ >= stakingStarts, "Festaking: staking end must be after staking starts");
        stakingEnds = stakingEnds_;

        require(withdrawStarts_ >= stakingEnds, "Festaking: withdrawStarts must be after staking ends");
        withdrawStarts = withdrawStarts_;

        require(withdrawEnds_ >= withdrawStarts, "Festaking: withdrawEnds must be after withdraw starts");
        withdrawEnds = withdrawEnds_;

        require(stakingCap_ >= 0, "Festaking: stakingCap cannot be negative");
        stakingCap = stakingCap_;
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function stakedTotal() external override view returns (uint256) {

        return stakeState.stakedTotal;
    }

    function stakedBalance() public override view returns (uint256) {

        return stakeState.stakedBalance;
    }

    function stakeOf(address account) external override view returns (uint256) {

        return stakeState._stakes[account];
    }

    function stakeFor(address staker, uint256 amount)
    external
    override
    returns (bool) {

        return _stake(msg.sender, staker, amount);
    }

    function stake(uint256 amount)
    external
    override
    returns (bool) {

        address from = msg.sender;
        return _stake(from, from, amount);
    }

    function _stake(address payer, address staker, uint256 amount) internal virtual returns (bool) {

        return FestakedLib.stake(payer, staker, amount,
            stakingStarts, stakingEnds, stakingCap, tokenAddress,
            stakeState);
    }
}pragma solidity >=0.6.0 <0.8.0;


abstract contract RewardAdder is IFestaked {
    address  public rewardTokenAddress;
    FestakedLib.FestakeRewardState public rewardState;
    address public rewardSetter; // Not using Ownable to save on deployment gas

    function rewardsTotal() external view returns (uint256) {
        return rewardState.rewardsTotal;
    }

    function earlyWithdrawReward() external view returns (uint256) {
        return rewardState.earlyWithdrawReward;
    }

    function rewardBalance() external view returns (uint256) {
        return rewardState.rewardBalance;
    }

    function addReward(uint256 rewardAmount, uint256 withdrawableAmount)
    external returns (bool) {
        return FestakedLib.addReward(rewardAmount, withdrawableAmount,
            rewardTokenAddress, rewardState);
    }
}

contract FestakedWithReward is FestakedOptimized, RewardAdder {

    constructor (string memory name_,
        address tokenAddress_,
        address rewardTokenAddress_,
        uint stakingStarts_,
        uint stakingEnds_,
        uint withdrawStarts_,
        uint withdrawEnds_,
        uint256 stakingCap_) FestakedOptimized (
            name_,
            tokenAddress_,
            stakingStarts_,
            stakingEnds_,
            withdrawStarts_,
            withdrawEnds_,
            stakingCap_
        ) public {
        require(rewardTokenAddress_ != address(0), "Festaking: 0 reward address");
        rewardTokenAddress = rewardTokenAddress_;
        rewardSetter = msg.sender;
    }

    function addMarginalReward(uint256 withdrawableAmount)
    external {

        require(msg.sender == rewardSetter, "Festaking: Not allowed");
        rewardState.earlyWithdrawReward = withdrawableAmount;
        FestakedLib.addMarginalReward(rewardTokenAddress, tokenAddress,
            address(this), stakedBalance(), rewardState);
    }

    function withdraw(uint256 amount) virtual
    public
    returns (bool) {

        return FestakedLib.withdraw(
            msg.sender,
            tokenAddress,
            rewardTokenAddress,
            amount,
            withdrawStarts,
            withdrawEnds,
            stakingEnds,
            stakeState,
            rewardState);
    }
}