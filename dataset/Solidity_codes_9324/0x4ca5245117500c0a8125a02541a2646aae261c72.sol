

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
}














abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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
}










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
}


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


contract StakeBoltToken is Ownable {

    using SafeERC20 for IERC20;

    struct stakingInfo {
        uint128 amount; // Amount of tokens staked by the account
        uint128 unclaimedDynReward; // Allocated but Unclaimed dynamic reward
        uint128 maxObligation; // The fixed reward obligation, assuming user holds until contract expiry.
        uint32 lastClaimTime; // used for delta time for claims
    }

    mapping(address => stakingInfo) userStakes;

    IERC20 immutable token;

    uint32 rewardStartTime;

    uint32 immutable rewardLifetime;

    uint32 immutable fixedAPR;

    uint128 immutable maxTokensStakable;

    uint128 totalTokensStaked;

    uint128 public fixedRewardsAvailable;

    uint128 public dynamicTokensToAllocate;

    uint128 fixedObligation;

    uint128 public dynamicTokensAllocated;

    constructor(address _tokenAddr, uint128 _maxStakable) {
        token = IERC20(_tokenAddr);
        maxTokensStakable = _maxStakable;
        rewardLifetime = 365 days;
        fixedAPR = 500; // 5% in Basis Points
        rewardStartTime = 0; // Rewards are not started immediately
    }

    function setRewardStartTime() external onlyOwner returns (uint256) {

        require(rewardStartTime == 0, "Rewards already started");

        rewardStartTime = uint32(block.timestamp);
        return rewardStartTime;
    }

    function stake(uint128 _amount) external {

        require(
            (rewardStartTime == 0) ||
                (block.timestamp <= rewardStartTime + rewardLifetime),
            "Staking period is over"
        );

        require(
            totalTokensStaked + _amount <= maxTokensStakable,
            "Max staking limit exceeded"
        );

        if (userStakes[msg.sender].lastClaimTime == 0) {
            userStakes[msg.sender].lastClaimTime = uint32(block.timestamp);
        }

        _claim(); //must claim before updating amount
        userStakes[msg.sender].amount += _amount;
        totalTokensStaked += _amount;

        _updateFixedObligation(msg.sender);

        token.safeTransferFrom(msg.sender, address(this), _amount);
        emit StakeTokens(msg.sender, _amount);
    }

    function unstake(uint128 _amount) external {

        require(userStakes[msg.sender].amount > 0, "Nothing to unstake");
        require(
            _amount <= userStakes[msg.sender].amount,
            "Unstake Amount greater than Stake"
        );
        _claim();
        userStakes[msg.sender].amount -= _amount;
        totalTokensStaked -= _amount;
        _updateFixedObligation(msg.sender);

        token.safeTransfer(msg.sender, _amount);
        emit UnstakeTokens(msg.sender, _amount);
    }

    function claim() external {

        require(
            rewardStartTime != 0,
            "Nothing to claim, Rewards have not yet started"
        );
        _claim();
        _updateFixedObligation(msg.sender);
    }

    function _updateFixedObligation(address _address) private {

        uint128 newMaxObligation;
        uint128 effectiveTime;

        if (rewardStartTime == 0) {
            effectiveTime = 0;
        } else if (
            uint128(block.timestamp) > rewardStartTime + rewardLifetime
        ) {
            effectiveTime = rewardStartTime + rewardLifetime;
        } else {
            effectiveTime = uint128(block.timestamp);
        }

        newMaxObligation =
            (((userStakes[_address].amount * fixedAPR) / 10000) *
                (rewardStartTime + rewardLifetime - effectiveTime)) /
            rewardLifetime;

        fixedObligation =
            fixedObligation -
            userStakes[_address].maxObligation +
            newMaxObligation;
        userStakes[_address].maxObligation = newMaxObligation;
    }

    function _claim() private {

        if (rewardStartTime == 0) {
            return;
        }

        uint32 lastClaimTime = userStakes[msg.sender].lastClaimTime;

        if (lastClaimTime < rewardStartTime) {
            lastClaimTime = rewardStartTime;
        }


        uint32 claimTime = (block.timestamp < rewardStartTime + rewardLifetime)
            ? uint32(block.timestamp)
            : rewardStartTime + rewardLifetime;

        uint128 fixedClaimAmount = (((userStakes[msg.sender].amount *
            fixedAPR) / 10000) * (claimTime - lastClaimTime)) / rewardLifetime;

        uint128 dynamicClaimAmount = userStakes[msg.sender].unclaimedDynReward;
        dynamicTokensAllocated -= dynamicClaimAmount;

        uint128 totalClaim = fixedClaimAmount + dynamicClaimAmount;

        require(
            fixedRewardsAvailable >= fixedClaimAmount,
            "Insufficient Fixed Rewards available"
        );

        if (totalClaim > 0) {
            token.safeTransfer(msg.sender, totalClaim);
        }

        if (fixedClaimAmount > 0) {
            fixedRewardsAvailable -= uint128(fixedClaimAmount); // decrease the tokens remaining to reward
        }
        userStakes[msg.sender].lastClaimTime = uint32(claimTime);

        if (dynamicClaimAmount > 0) {
            userStakes[msg.sender].unclaimedDynReward = 0;
        }

        emit ClaimReward(msg.sender, fixedClaimAmount, dynamicClaimAmount);
    }


    function depositDynamicReward(uint128 _amount) external onlyOwner {

        token.safeTransferFrom(msg.sender, address(this), _amount);

        dynamicTokensToAllocate += _amount;

        emit DepositDynamicReward(msg.sender, _amount);
    }

    function allocateDynamicReward(
        address[] memory _addresses,
        uint128[] memory _amounts,
        uint128 _totalAmount
    ) external onlyOwner {

        uint256 _calcdTotal = 0;

        require(
            _addresses.length == _amounts.length,
            "_addresses[] and _amounts[] must be the same length"
        );
        require(
            dynamicTokensToAllocate >= _totalAmount,
            "Not enough tokens available to allocate"
        );

        for (uint256 i = 0; i < _addresses.length; i++) {
            userStakes[_addresses[i]].unclaimedDynReward += _amounts[i];
            _calcdTotal += _amounts[i];
        }
        require(
            _calcdTotal == _totalAmount,
            "Sum of amounts does not equal total"
        );

        dynamicTokensToAllocate -= _totalAmount; // adjust remaining balance to allocate

        dynamicTokensAllocated += _totalAmount;
    }

    function depositFixedReward(uint128 _amount)
        external
        onlyOwner
        returns (uint128)
    {

        fixedRewardsAvailable += _amount;

        token.safeTransferFrom(msg.sender, address(this), _amount);

        emit DepositFixedReward(msg.sender, _amount);

        return fixedRewardsAvailable;
    }

    function withdrawFixedReward() external onlyOwner returns (uint256) {

        require(
            block.timestamp > rewardStartTime + rewardLifetime,
            "Staking period is not yet over"
        );
        require(
            fixedRewardsAvailable >= fixedObligation,
            "Insufficient Fixed Rewards available"
        );
        uint128 tokensToWithdraw = fixedRewardsAvailable - fixedObligation;

        fixedRewardsAvailable -= tokensToWithdraw;

        token.safeTransfer(msg.sender, tokensToWithdraw);

        emit WithdrawFixedReward(msg.sender, tokensToWithdraw);

        return tokensToWithdraw;
    }


    function getRewardStartTime() external view returns (uint256) {

        return rewardStartTime;
    }

    function getMaxStakingLimit() public view returns (uint256) {

        return maxTokensStakable;
    }

    function getRewardLifetime() public view returns (uint256) {

        return rewardLifetime;
    }

    function getTotalStaked() external view  returns (uint256) {

        return totalTokensStaked;
    }

    function getFixedObligation() public view returns (uint256) {

        return fixedObligation;
    }

    function getTokensStaked(address _addr) public view returns (uint256) {

        return userStakes[_addr].amount;
    }

    function getStakedPercentage(address _addr)
        public
        view
        returns (uint256, uint256)
    {

        return (totalTokensStaked, userStakes[_addr].amount);
    }

    function getStakeInfo(address _addr)
        public
        view
        returns (
            uint128 amount, // Amount of tokens staked by the account
            uint128 unclaimedFixedReward, // Allocated but Unclaimed fixed reward
            uint128 unclaimedDynReward, // Allocated but Unclaimed dynamic reward
            uint128 maxObligation, // The fixed reward obligation, assuming user holds until contract expiry.
            uint32 lastClaimTime, // used for delta time for claims
            uint32 claimtime // show the effective claim time
        )
    {

        uint128 fixedClaimAmount;
        uint32 claimTime;
        stakingInfo memory s = userStakes[_addr];
        if (rewardStartTime > 0) {
            claimTime = (block.timestamp < rewardStartTime + rewardLifetime)
                ? uint32(block.timestamp)
                : rewardStartTime + rewardLifetime;

            fixedClaimAmount =
                (((s.amount * fixedAPR) / 10000) *
                    (claimTime - s.lastClaimTime)) /
                rewardLifetime;
        } else {
            fixedClaimAmount = 0;
        }

        return (
            s.amount,
            fixedClaimAmount,
            s.unclaimedDynReward,
            s.maxObligation,
            s.lastClaimTime,
            claimTime
        );
    }

    function getStakeTokenAddress() public view returns (IERC20) {

        return token;
    }

    event DepositFixedReward(address indexed from, uint256 amount);
    event DepositDynamicReward(address indexed from, uint256 amount);
    event WithdrawFixedReward(address indexed to, uint256 amount);

    event StakeTokens(address indexed from, uint256 amount);
    event UnstakeTokens(address indexed to, uint256 amount);
    event ClaimReward(
        address indexed to,
        uint256 fixedAmount,
        uint256 dynamicAmount
    );
}