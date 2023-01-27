

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;




struct PoolInfo {
    IERC20 lpToken;           // Address of LP token contract.
    uint256 allocPoint;       // How many allocation points assigned to this pool. TOKENs to distribute per block.
    uint256 lastRewardBlock;  // Last block number that TOKENs distribution occurs.
    uint256 accPerShare;      // Accumulated TOKENs per share, times 1e12. See below.
    uint256 lockPeriod;       // Lock period of LP pool
}


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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


interface VaultWithdrawAPI {

    function withdraw(uint256 maxShares, address recipient) external returns (uint256);

}


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}


contract Staking is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;       // How many LP tokens the user has provided.
        uint256 rewardDebt;   // Reward debt. See explanation below.
        uint256 depositTime;  // Last time of deposit/withdraw operation.
    }

    IERC20 public token;
    uint256 public tokenPerBlock;
    uint256 public tokenDistributed;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IERC20 _token,
        uint256 _tokenPerBlock,
        uint256 _startBlock
    ) public {
        token = _token;
        tokenPerBlock = _tokenPerBlock;
        startBlock = _startBlock;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function checkPoolDuplicate(IERC20 _lpToken) internal {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            require(poolInfo[pid].lpToken != _lpToken, "add: existing pool");
        }
    }

    function add(uint256 _allocPoint, IERC20 _lpToken) external onlyOwner {

        checkPoolDuplicate(_lpToken);
        massUpdatePools();

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accPerShare: 0,
            lockPeriod: 0
        }));
    }

    function setLockPeriod(uint256 _pid, uint256 _lockPeriod) external onlyOwner {

        poolInfo[_pid].lockPeriod = _lockPeriod;
    }

    function remainingLockPeriod(uint256 _pid, address _user) external view returns (uint256) {

        return _remainingLockPeriod(_pid, _user);
    }

    function _remainingLockPeriod(uint256 _pid, address _user) internal view returns (uint256) {

        uint256 lockPeriod = poolInfo[_pid].lockPeriod;
        UserInfo storage user= userInfo[_pid][_user];
        uint256 timeElapsed = block.timestamp.sub(user.depositTime);
        
        if (user.amount > 0 && timeElapsed < lockPeriod) {
            return lockPeriod.sub(timeElapsed);
        } else {
            return 0;
        }
    }

    function set(uint256 _pid, uint256 _allocPoint) external onlyOwner {

        massUpdatePools();
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setTokenPerBlock(uint256 _tokenPerBlock) external onlyOwner {

        massUpdatePools();
        tokenPerBlock = _tokenPerBlock;
    }

    function sweep(uint256 _amount) external onlyOwner {

        token.safeTransfer(owner(), _amount);
    }

    function getMultiplier(uint256 _from, uint256 _to) internal pure returns (uint256) {

        return _to.sub(_from);
    }

    function rewardForPoolPerBlock(uint256 _pid) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        return tokenPerBlock.mul(pool.allocPoint).div(totalAllocPoint);
    }

    function tokenOfUser(uint256 _pid, address _user) external view returns (uint256) {

        UserInfo storage user = userInfo[_pid][_user];
        return user.amount;
    }

    function pendingToken(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accPerShare = pool.accPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 tokenReward = multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accPerShare = accPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        }

        uint256 pending = user.amount.mul(accPerShare).div(1e12).sub(user.rewardDebt);
        uint256 remaining = token.balanceOf(address(this));
        return Math.min(pending, remaining);
    }

    function massUpdatePools() internal {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) internal {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 tokenReward = multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accPerShare = pool.accPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount, address _recipient) public returns (uint256) {


        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_recipient];
        uint256 rewards = _harvest(_recipient, _pid);

        uint256 newAmount = user.amount.add(_amount);
        user.rewardDebt = newAmount.mul(pool.accPerShare).div(1e12);
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
            user.amount = newAmount;
            user.depositTime = block.timestamp;
        }

        emit Deposit(_recipient, _pid, _amount);
        return rewards;
    }

    function unstakeAndWithdraw(uint256 _pid, uint256 _amount, VaultWithdrawAPI vault) external returns (uint256) {

        address sender = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][sender];

        require(user.amount >= _amount, "withdraw: not good");
        require(_remainingLockPeriod(_pid, sender) == 0, "withdraw: still in lockPeriod");

        uint256 rewards = _harvest(sender, _pid);

        uint256 newAmount = user.amount.sub(_amount);
        user.rewardDebt = newAmount.mul(pool.accPerShare).div(1e12);
        if(_amount > 0) {
            user.amount = newAmount;
            user.depositTime = block.timestamp;

            IERC20 sVault = IERC20(address(vault));
            uint256 beforeBalance = sVault.balanceOf(address(this));

            vault.withdraw(_amount, sender);

            uint256 delta = beforeBalance.sub(sVault.balanceOf(address(this)));
            assert(delta <= _amount);

            if(delta < _amount) {
                user.amount = user.amount.add(_amount).sub(delta);
                user.rewardDebt = user.amount.mul(pool.accPerShare).div(1e12);
            }
        }

        emit Withdraw(sender, _pid, _amount);
        return rewards;
    }

    function withdraw(uint256 _pid, uint256 _amount) external returns (uint256) {

        address sender = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][sender];

        require(user.amount >= _amount, "withdraw: not good");
        require(_remainingLockPeriod(_pid, sender) == 0, "withdraw: still in lockPeriod");

        uint256 rewards = _harvest(sender, _pid);

        uint256 newAmount = user.amount.sub(_amount);
        user.rewardDebt = newAmount.mul(pool.accPerShare).div(1e12);
        if(_amount > 0) {
            user.amount = newAmount;
            user.depositTime = block.timestamp;
            pool.lpToken.safeTransfer(address(sender), _amount);
        }

        emit Withdraw(sender, _pid, _amount);
        return rewards;
    }

    function harvest(uint256 _pid) external returns (uint256) {

        address sender = msg.sender;
        uint256 rewards = _harvest(sender, _pid);
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][sender];
        user.rewardDebt = user.amount.mul(pool.accPerShare).div(1e12);
        return rewards;
    }

    function _harvest(address _user, uint256 _pid) internal returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        updatePool(_pid);
        if (user.amount == 0) {
            return 0;
        }

        uint256 pending = user.amount.mul(pool.accPerShare).div(1e12).sub(user.rewardDebt);
        uint256 remaining = token.balanceOf(address(this));
        pending = Math.min(pending, remaining);
        if(pending > 0) {
            tokenDistributed = tokenDistributed.add(pending);
            token.safeTransfer(_user, pending);
        }
        emit Harvest(_user, _pid, pending);
        return pending;
    }

}