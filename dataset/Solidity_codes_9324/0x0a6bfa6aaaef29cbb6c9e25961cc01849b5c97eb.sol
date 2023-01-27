


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity ^0.8.0;

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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



pragma solidity ^0.8.0;





interface IStakingRewardVault {


    function transfer(address _receiver, uint256 _amount) external;


}

contract MasterChef is Ownable, ReentrancyGuard {


    using SafeERC20 for IERC20;

    uint256 internal constant REWARD_PER_SHARE_MULTIPLIER = 1e12;

    uint256 internal constant BLOCK_PER_MONTH = 172800; // 5760 blocks/day * 30 days

    struct User {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct Pool {
        IERC20 token;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 rewardPerShare;
    }

    IStakingRewardVault public vault;

    IERC20 public cpdtToken;

    Pool[] public pools;

    mapping(uint256 => mapping(address => User)) public users;

    uint256 public totalAllocPoint;

    uint256 public startBlock;

    mapping(address => bool) public tokenExisted;

    event PoolAdded(address token, uint256 allocPoint);
    event PoolUpdated(uint256 pid, uint256 allocPoint);

    event Staked(address user, uint256 pid, uint256 amount);
    event Unstaked(address user, uint256 pid, uint256 amount);

    event EmergencyWithdraw(address user, uint256 pid, uint256 amount);

    event RewardWithdraw(address receiver, uint256 amount);

    modifier poolExist(uint256 _pid) {

        require(_pid < pools.length, "MasterChef: pool has not existed");
        _;
    }

    constructor(IStakingRewardVault _vault, IERC20 _cpdtToken, uint256 _startBlock)
    {
        vault = _vault;
        cpdtToken = _cpdtToken;
        startBlock = _startBlock;
    }

    function getTotalPools() public view returns (uint256) {

        return pools.length;
    }

    function add(address _token, uint256 _allocPoint, bool _withUpdate)
        public
        onlyOwner
    {

        require(_token != address(0) && !tokenExisted[_token], "MasterChef: token is invalid");

        tokenExisted[_token] = true;

        if (_withUpdate) {
            massUpdatePools();
        }

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;

        pools.push(Pool({
            token: IERC20(_token),
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            rewardPerShare: 0
        }));

        totalAllocPoint += _allocPoint;

        emit PoolAdded(_token, _allocPoint);
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate)
        public
        onlyOwner
        poolExist(_pid)
    {

        if (_withUpdate) {
            massUpdatePools();
        }

        totalAllocPoint = totalAllocPoint - pools[_pid].allocPoint + _allocPoint;

        pools[_pid].allocPoint = _allocPoint;

        emit PoolUpdated(_pid, _allocPoint);
    }

    function rewardToShare(uint256 _reward, uint256 _rewardPerShare) public pure returns (uint256) {

        return (_reward * REWARD_PER_SHARE_MULTIPLIER) / _rewardPerShare;
    }

    function shareToReward(uint256 _share, uint256 _rewardPerShare) public pure returns (uint256) {

        return (_share * _rewardPerShare) / REWARD_PER_SHARE_MULTIPLIER;
    }

    function pendingReward(uint256 _pid, address _account) public view returns (uint256) {

        if (_pid >= pools.length) {
            return 0;
        }

        Pool memory pool = pools[_pid];

        User memory user = users[_pid][_account];

        uint256 rewardPerShare = pool.rewardPerShare;

        uint256 supply = pool.token.balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && supply != 0) {
            uint256 reward = getRewardManyBlock(pool.lastRewardBlock, block.number) * pool.allocPoint / totalAllocPoint;

            uint256 remaining = cpdtToken.balanceOf(address(vault));

            if (reward > remaining) {
                reward = remaining;
            }

            if (reward > 0) {
                rewardPerShare += rewardToShare(reward, supply);
            }
        }

        return shareToReward(user.amount, rewardPerShare) - user.rewardDebt;
    }

    function massUpdatePools() public {

        uint256 length = pools.length;

        for (uint256 pid = 0; pid < length; pid++) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid)
        public
        poolExist(_pid)
        nonReentrant
    {

        Pool storage pool = pools[_pid];

        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        uint256 supply = pool.token.balanceOf(address(this));

        if (supply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 reward = getRewardManyBlock(pool.lastRewardBlock, block.number) * pool.allocPoint / totalAllocPoint;

        uint256 remaining = cpdtToken.balanceOf(address(vault));

        if (reward > remaining) {
            reward = remaining;
        }

        if (reward > 0) {
            vault.transfer(address(this), reward);

            pool.rewardPerShare += rewardToShare(reward, supply);
        }

        pool.lastRewardBlock = block.number;
    }

    function stake(uint256 _pid, uint256 _amount)
        public
    {

        address msgSender = _msgSender();

        Pool storage pool = pools[_pid];

        User storage user = users[_pid][msgSender];

        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pending = shareToReward(user.amount, pool.rewardPerShare) - user.rewardDebt;

            if (pending > 0) {
                cpdtToken.safeTransfer(msgSender, pending);
            }
        }

        if (_amount > 0) {
            pool.token.safeTransferFrom(msgSender, address(this), _amount);

            user.amount += _amount;
        }

        user.rewardDebt = shareToReward(user.amount, pool.rewardPerShare);

        emit Staked(msgSender, _pid, _amount);
    }

    function unstake(uint256 _pid, uint256 _amount)
        public
    {

        address msgSender = _msgSender();

        Pool storage pool = pools[_pid];

        User storage user = users[_pid][msgSender];

        require(user.amount >= _amount, "MasterChef: amount exceeds stake");

        updatePool(_pid);

        uint256 pending = shareToReward(user.amount, pool.rewardPerShare) - user.rewardDebt;

        if (pending > 0) {
            cpdtToken.safeTransfer(msgSender, pending);
        }

        if (_amount > 0) {
            user.amount -= _amount;

            pool.token.safeTransfer(msgSender, _amount);
        }

        user.rewardDebt = shareToReward(user.amount, pool.rewardPerShare);

        emit Unstaked(msgSender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid)
        public
        poolExist(_pid)
        nonReentrant
    {

        address msgSender = _msgSender();

        Pool storage pool = pools[_pid];

        User storage user = users[_pid][msgSender];

        pool.token.safeTransfer(msgSender, user.amount);

        emit EmergencyWithdraw(msgSender, _pid, user.amount);

        user.amount = 0;
        user.rewardDebt = 0;
    }

    function getRate(uint256 month)
        public
        pure
        returns(uint256)
    {

        if (month == 1) {
            return 200;

        } else if (month == 2) {
            return 180;

        } else if (month == 3) {
            return 160;

        } else if (month == 4) {
            return 140;

        } else if (month == 5) {
            return 120;

        } else if (month >= 6 && month <= 12) {
            return 100;

        } else if (month >= 13 && month <= 24) {
            return 50;

        } else {
            return 0;
        }
    }

    function getRewardPerBlock(uint256 currentBlock)
        public
        view
        returns(uint256)
    {

        uint256 month = (currentBlock - startBlock) / BLOCK_PER_MONTH + 1;

        uint256 rewardPerMonth = 276000000 * 1e18 * getRate(month) / 2100;

        return rewardPerMonth / BLOCK_PER_MONTH;
    }

    function getRewardManyBlock(uint256 blockFrom, uint256 blockTo)
        public
        view
        returns(uint256)
    {

        uint256 reward = 0;

        uint256 start = startBlock;

        if (blockFrom < start || blockFrom >= blockTo) {
            return reward;
        }

        uint256 month = (blockFrom - start) / BLOCK_PER_MONTH + 1;

        for (uint256 i = month; i <= 24; i++) {
            uint256 milestone = start + (BLOCK_PER_MONTH * i);

            if (blockFrom >= milestone) {
                continue;
            }

            uint256 rewardPerBlock = (276000000 * 1e18 * getRate(i) / 2100) / BLOCK_PER_MONTH;

            if (blockTo <= milestone) {
                reward += (blockTo - blockFrom) * rewardPerBlock;
                break;
            }

            reward += (milestone - blockFrom) * rewardPerBlock;

            blockFrom = milestone;
        }

        return reward;
    }

    function withdrawReward()
        public
        onlyOwner
    {

        address msgSender = _msgSender();

        uint256 rewardPerBlock = getRewardPerBlock(block.number);

        require(rewardPerBlock == 0, "MasterChef: can not withdraw");

        massUpdatePools();

        uint256 remaining = cpdtToken.balanceOf(address(vault));

        require(remaining > 0, "MasterChef: no reward");

        vault.transfer(msgSender, remaining);

        emit RewardWithdraw(msgSender, remaining);
    }

}