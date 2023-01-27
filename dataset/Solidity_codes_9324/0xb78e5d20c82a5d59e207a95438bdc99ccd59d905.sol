
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

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
}// MIT

pragma solidity ^0.6.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// GPL-3.0
pragma solidity 0.6.12;


interface IMigratorConsole {

    function migrate(IERC20 token) external returns (IERC20);

}

contract GameConsole is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. Joys to distribute per block.
        uint256 lastRewardBlock;  // Last block number that Joys distribution occurs.
        uint256 accJoysPerShare; // Accumulated Joys per share, times 1e12. See below.
    }

    IERC20 public joys;

    IERC20 public weth;

    address public wethLp;

    address public joysVesting;

    uint256 public bonusBeginBlock;
    uint256 public bonusEndBlock;

    uint256 public constant BLOCK_PER_DAY = 6100;

    uint256 public constant BONUS_MULTIPLIER_16 = 160;
    uint256 public constant BONUS_MULTIPLIER_8 = 80;
    uint256 public constant BONUS_MULTIPLIER_4 = 40;
    uint256 public constant BONUS_MULTIPLIER_2 = 20;

    uint256 public constant MINED_DAYS = 48;

    uint256 public constant CONTINUE_DAYS_PER_STAGE = 12;

    struct PeriodInfo {
        uint256 begin;
        uint256 end;
        uint256 multiplier;
    }
    PeriodInfo[] public periodInfo;

    IMigratorConsole public migrator;

    PoolInfo[] public poolInfo;

    mapping(address => bool) public lpTokenExistsInPool;

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    uint256 public totalAllocPoint = 0;

    uint256 public constant DEFAULT_WETH = 100;
    uint256 public constant MAX_WETH = 1000;
    uint256 public constant JOYS_PER_BLOCK_STEP = 80;
    uint256 public constant MAX_JOYS_PER_BLOCK = 800;
    uint256 public lastWETHAmount;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor (
        IERC20 _joys,
        IERC20 _weth,
        address _vesting
    ) public {
        joys = _joys;
        weth = _weth;
        joysVesting = _vesting;
        bonusBeginBlock = block.number;
        bonusEndBlock = bonusBeginBlock + BLOCK_PER_DAY * MINED_DAYS;
        lastWETHAmount = 0;

        uint256 multiplier = BONUS_MULTIPLIER_16;
        uint256 currentBlock = bonusBeginBlock;
        uint256 lastBlock = currentBlock;
        for (; currentBlock < bonusEndBlock; currentBlock += CONTINUE_DAYS_PER_STAGE*BLOCK_PER_DAY) {
            periodInfo.push(PeriodInfo({
                begin: lastBlock,
                end: currentBlock + CONTINUE_DAYS_PER_STAGE*BLOCK_PER_DAY,
                multiplier: multiplier
            }));

            lastBlock = currentBlock + CONTINUE_DAYS_PER_STAGE*BLOCK_PER_DAY + 1;
            multiplier = multiplier.div(2);
        }
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate, bool _withWethLp) public onlyOwner {

        require(!lpTokenExistsInPool[address(_lpToken)], "GameConsole: LP Token Address already exists in pool");
        if (_withUpdate) {
            massUpdatePools();
        }
        if (_withWethLp) {
            wethLp = address(_lpToken);
        }
        uint256 lastRewardBlock = block.number > bonusBeginBlock? block.number : bonusBeginBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accJoysPerShare: 0
        }));
        lpTokenExistsInPool[address(_lpToken)] = true;
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setWethLp(address _wethLp) public onlyOwner {

        require(_wethLp != address(0), "GameConsole: Invalid address.");
        wethLp = _wethLp;
    }

    function setMigrator(IMigratorConsole _migrator) public onlyOwner {

        migrator = _migrator;
    }

    function migrate(uint256 _pid) public {

        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(!lpTokenExistsInPool[address(newLpToken)],"MasterChef: New LP Token Address already exists in pool");
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
        lpTokenExistsInPool[address(newLpToken)] = true;
    }

    function getReward(uint256 _from, uint256 _to) public view returns (uint256) {

        if (_to > bonusEndBlock) {
            _to = bonusEndBlock;
        }
        uint256 totalReward;
        for (uint256 i = 0; i < periodInfo.length; ++i) {
            if (_to <= periodInfo[i].end) {
                if (i == 0) {
                    totalReward = totalReward.add(_to.sub(_from).mul(periodInfo[i].multiplier));
                    break;
                } else {
                    uint256 dest = periodInfo[i].begin;
                    if (_from > periodInfo[i].begin) {
                        dest = _from;
                    }
                    totalReward = totalReward.add(_to.sub(dest).mul(periodInfo[i].multiplier));
                    break;
                }
            } else if (_from >= periodInfo[i].end) {
                continue;
            } else {
                totalReward = totalReward.add(periodInfo[i].end.sub(_from).mul(periodInfo[i].multiplier));
                _from = periodInfo[i].end;
            }
        }

        return totalReward.mul(1e17);
    }

    function pendingJoys(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accJoysPerShare = pool.accJoysPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 joysReward = getReward(pool.lastRewardBlock, block.number).mul(pool.allocPoint).div(totalAllocPoint);
            accJoysPerShare = accJoysPerShare.add(joysReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accJoysPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 joysReward = getReward(pool.lastRewardBlock, block.number).mul(pool.allocPoint).div(totalAllocPoint);
        joys.transfer(joysVesting, joysReward.div(10));
        joys.transfer(address(this), joysReward);
        pool.accJoysPerShare= pool.accJoysPerShare.add(joysReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function updatePeriod() public {

        if (lastWETHAmount >= MAX_WETH) {
            return;
        }

        uint256 amount = weth.balanceOf(wethLp).div(1e18);
        if (amount < lastWETHAmount || amount < lastWETHAmount.add(DEFAULT_WETH)) {
            return;
        }

        uint256 delt = amount.sub(lastWETHAmount).div(DEFAULT_WETH);

        lastWETHAmount = amount;

        for (uint256 i = 0; i < periodInfo.length; ++i) {
            periodInfo[i].multiplier = periodInfo[i].multiplier.add(delt.mul(JOYS_PER_BLOCK_STEP));
            if (periodInfo[i].multiplier > MAX_JOYS_PER_BLOCK) {
                periodInfo[i].multiplier = MAX_JOYS_PER_BLOCK;
            }
        }
    }

    function deposit(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePool(_pid);

        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accJoysPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeJoysTransfer(msg.sender, pending);
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            updatePeriod();
        }
        user.rewardDebt = user.amount.mul(pool.accJoysPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accJoysPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeJoysTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accJoysPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function safeJoysTransfer(address _to, uint256 _amount) internal {

        uint256 joysBal = joys.balanceOf(address(this));
        if (_amount > joysBal) {
            joys.transfer(_to, joysBal);
        } else {
            joys.transfer(_to, _amount);
        }
    }

    function recycleJoysToken(address _address) public onlyOwner {

        require(_address != address(0), "JoysLottery:Invalid address");
        require(joys.balanceOf(address(this)) > 0, "JoysLottery:no JOYS");
        joys.transfer(_address, joys.balanceOf(address(this)));
    }
}