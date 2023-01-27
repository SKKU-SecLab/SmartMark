
pragma solidity ^0.8.13;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint256);


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

pragma solidity ^0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.13;


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

pragma solidity ^0.8.13;


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

pragma solidity ^0.8.13;

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

pragma solidity ^0.8.13;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.8.13;

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
pragma solidity ^0.8.13;

contract PawtocolStake is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 poolBal;
        uint40 pool_deposit_time;
        uint256 total_deposits;
        uint256 pool_payouts;
        uint256 rewardEarned;
        uint256 penaltyGiven;
    }

    struct PoolInfo {
        IERC20 stakeToken;
        IERC20 rewardToken;
        uint256 poolRewardPercent;
        uint256 poolPenaltyPercent;
        uint256 poolDays;
        uint256 fullMaturityTime;
        uint256 poolLimit;
        uint256 poolStaked;
        uint256 minStake;
        uint256 maxStake;
        bool active;
    }

    uint256 public totalStaked;
    uint256 private _poolId = 0;
    address public penaltyFeeAddress;

    PoolInfo[] public poolInfo;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event PrincipalClaimed(address beneficiary, uint256 amount);
    event PoolStaked(address beneficiary, uint256 amount);
    event RewardClaimed(address beneficiary, uint256 amount);

    constructor(
        IERC20 _stakeToken,
        uint256 _poolRewardPercentAPY,
        uint256 _poolPenaltyPercent,
        uint256 _poolDays,
        uint256 _poolLimit,
        uint256 _minStake,
        uint256 _maxStake, 
        address _penaltyFeeAddress
    ) {
        require(
            isContract(address(_stakeToken)),
            "Enter a Valid Token contract address"
        );
        poolInfo.push(
            PoolInfo({
                stakeToken: _stakeToken,
                rewardToken: _stakeToken,
                poolRewardPercent: _poolRewardPercentAPY,
                poolPenaltyPercent: _poolPenaltyPercent,
                poolDays: _poolDays,
                fullMaturityTime: _poolDays.mul(86400),
                poolLimit: _poolLimit * 10**_stakeToken.decimals(),
                poolStaked: 0,
                minStake: _minStake * 10**_stakeToken.decimals(),
                maxStake: _maxStake * 10**_stakeToken.decimals(),
                active: true
            })
        );

        penaltyFeeAddress = _penaltyFeeAddress;
    }

    receive() external payable {}

    function poolActivation(bool status) external onlyOwner {

        PoolInfo storage pool = poolInfo[_poolId];
        pool.active = status;
    }

    function changePoolLimit(uint256 amount) external onlyOwner {

        PoolInfo storage pool = poolInfo[_poolId];
        pool.poolLimit = amount* 10 ** (pool.stakeToken).decimals();
    }

    function changeFeeWallet(address _newAddress) external onlyOwner {

        penaltyFeeAddress = _newAddress;
    }

    function PoolStake(uint256 _amount) external nonReentrant returns (bool) {

        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];
        require(pool.active, "Pool not Active");
        require(
            _amount <= IERC20(pool.stakeToken).balanceOf(msg.sender),
            "Token Balance of user is less"
        );
        require(
            pool.poolLimit >= pool.poolStaked + _amount,
            "Pool Limit Exceeded"
        );
        require(
            _amount >= pool.minStake ,
            "Minimum Stake Condition should be Satisfied"
        );
        require(
            _amount <= pool.maxStake ,
            "Maximum Stake Condition should be Satisfied"
        );
        require(user.poolBal == 0, "Already Staked in this Pool");

        pool.stakeToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        pool.poolStaked += _amount;
        totalStaked += _amount;
        user.poolBal = _amount;
        user.total_deposits += _amount;
        user.pool_deposit_time = uint40(block.timestamp);
        emit PoolStaked(msg.sender, _amount);
        return true;
    }

    function claimPool() external nonReentrant returns (bool) {

        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][msg.sender];

        require(
            user.poolBal > 0,
            "There is no deposit for this address in Pool"
        );
        uint256 calculatedRewards = (((user.poolBal * pool.poolRewardPercent) / 1000) / 360) * pool.poolDays;
        uint256 amount = user.poolBal;
        uint256 penaltyAmount;

        if (
            block.timestamp < (user.pool_deposit_time + pool.fullMaturityTime)
        ) {
            calculatedRewards = 0;
            penaltyAmount = ((amount) * pool.poolPenaltyPercent) / 1000;
            if(penaltyAmount>0){
                pool.rewardToken.safeTransfer(penaltyFeeAddress, penaltyAmount);
                user.penaltyGiven += penaltyAmount;
            }
            amount = amount.sub(penaltyAmount);
        }
        
        user.rewardEarned += calculatedRewards;
        user.pool_payouts += amount;

        user.poolBal = 0;
        user.pool_deposit_time = 0;

        pool.stakeToken.safeTransfer(address(msg.sender), amount);
        if(calculatedRewards>0){
            pool.rewardToken.safeTransfer(address(msg.sender), calculatedRewards);
        }

        emit RewardClaimed(msg.sender, calculatedRewards);
        emit PrincipalClaimed(msg.sender, amount);
        return true;
    }

    function calculateRewards(uint256 _amount, address userAdd)
        internal
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][userAdd];
        return
            (((_amount * pool.poolRewardPercent) / 1000) / 360) *
            ((block.timestamp - user.pool_deposit_time) / 1 days);
    }

    function rewardsCalculate(address userAddress)
        public
        view
        returns (uint256)
    {

        uint256 rewards;
        UserInfo storage user = userInfo[_poolId][userAddress];

        uint256 max_payout = this.maxPayoutOf(user.poolBal);
        uint256 calculatedRewards = calculateRewards(user.poolBal, userAddress);
        if (user.poolBal > 0) {
            if (calculatedRewards > max_payout) {
                rewards = max_payout;
            } else {
                rewards = calculatedRewards;
            }
        }
        return rewards;
    }

    function maxPayoutOf(uint256 _amount) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_poolId];
        return
            (((_amount * pool.poolRewardPercent) / 1000) / 360) * pool.poolDays;
    }

    function tokenBalance(address tokenAddr) public view returns (uint256) {

        return IERC20(tokenAddr).balanceOf(address(this));
    }

    function ethBalance() public view returns (uint256) {

        return address(this).balance;
    }

    function retrieveEthStuck()
        external
        nonReentrant
        onlyOwner
        returns (bool)
    {

        payable(owner()).transfer(address(this).balance);
        return true;
    }

    function retrieveERC20TokenStuck(
        address _tokenAddr,
        uint256 amount
    ) external nonReentrant onlyOwner returns (bool) {

        IERC20(_tokenAddr).transfer(owner(), amount);
        return true;
    }

    function maturityDate(address userAdd) public view returns (uint256) {

        UserInfo storage user = userInfo[_poolId][userAdd];
        PoolInfo storage pool = poolInfo[_poolId];

        return (user.pool_deposit_time + pool.fullMaturityTime);
    }

    function fullMaturityReward(address _userAdd)
        public
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfo[_poolId][_userAdd];
        uint256 fullReward = (((user.poolBal * pool.poolRewardPercent) / 1000) /
            360) * pool.poolDays;
        return fullReward;
    }



    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
