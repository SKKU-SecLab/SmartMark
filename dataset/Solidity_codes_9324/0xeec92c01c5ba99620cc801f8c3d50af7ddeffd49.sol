


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
}



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
}



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
}



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
}



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
}



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



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
}



pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


pragma solidity 0.6.12;



contract RoseToken is ERC20("RoseToken", "ROSE"), Ownable {
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}


pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


pragma solidity 0.6.12;








contract RoseMaster is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo1 {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. ROSEs to distribute per block.
        uint256 lastRewardBlock; // Last block number that ROSEs distribution occurs.
        uint256 accRosePerShare; // Accumulated ROSEs per share, times 1e12. See below.
        uint256 totalAmount;
    }

    struct PoolInfo2 {
        uint256 allocPoint; // How many allocation points assigned to this pool. ROSEs to distribute per block.
        uint256 lastRewardBlock; // Last block number that ROSEs distribution occurs.
        uint256 accRosePerShare; // Accumulated ROSEs per share, times 1e12. See below.
        uint256 lastUnlockedBlock; // Last block number that pool to renovate.
        uint256 lockedAmount;
        uint256 freeAmount;
        uint256 maxLockAmount;
        uint256 unlockIntervalBlock;
        uint256 feeAmount;
        uint256 sharedFeeAmount;
    }

    struct PeriodInfo {
        uint256 endBlock;
        uint256 blockReward;
    }

    RoseToken public rose;
    address public devaddr;
    address public rankAddr;
    address public communityAddr;
    address public sfr;
    IUniswapV2Pair public sfr2rose;

    PoolInfo1[] public poolInfo1;
    PoolInfo2[] public poolInfo2;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo1;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo2;
    uint256 public allocPointPool1 = 0;
    uint256 public allocPointPool2 = 0;
    uint256 public startBlock;
    mapping(address => address) public referrers;
    mapping(address => address[]) referreds1;
    mapping(address => address[]) referreds2;

    PeriodInfo[] public periodInfo;

    event Deposit1(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw1(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw1(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event Deposit2(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw2(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw2(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        RoseToken _rose,
        address _sfr,
        address _devaddr,
        address _topReferrer,
        uint256 _startBlock,
        uint256 _firstBlockReward,
        uint256 _supplyPeriod,
        uint256 _maxSupply
    ) public {
        rose = _rose;
        sfr = _sfr;
        devaddr = _devaddr;
        startBlock = _startBlock;

        uint256 _supplyPerPeriod = _maxSupply / _supplyPeriod;
        uint256 lastPeriodEndBlock = _startBlock;
        for (uint256 i = 0; i < _supplyPeriod; i++) {
            lastPeriodEndBlock = lastPeriodEndBlock.add(
                _supplyPerPeriod.div(_firstBlockReward) << i
            );
            periodInfo.push(
                PeriodInfo({
                    endBlock: lastPeriodEndBlock,
                    blockReward: _firstBlockReward >> i
                })
            );
        }

        referrers[_topReferrer] = _topReferrer;
    }

    function pool1Length() external view returns (uint256) {
        return poolInfo1.length;
    }

    function pool2Length() external view returns (uint256) {
        return poolInfo2.length;
    }

    function setStartBlock(uint256 _startBlock) public onlyOwner {
        require(block.number < startBlock);
        startBlock = _startBlock;
    }

    function setSfr2rose(address _sfr2rose) external onlyOwner {
        sfr2rose = IUniswapV2Pair(_sfr2rose);
    }

    function add1(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePool1s();
        }
        uint256 firstBlock = block.number > startBlock
            ? block.number
            : startBlock;
        allocPointPool1 = allocPointPool1.add(_allocPoint);
        poolInfo1.push(
            PoolInfo1({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: firstBlock,
                accRosePerShare: 0,
                totalAmount: 0
            })
        );
    }

    function add2(
        uint256 _allocPoint,
        bool _withUpdate,
        uint256 _maxLockAmount,
        uint256 _unlockIntervalBlock
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePool2s();
        }
        uint256 firstBlock = block.number > startBlock
            ? block.number
            : startBlock;
        allocPointPool2 = allocPointPool2.add(_allocPoint);
        poolInfo2.push(
            PoolInfo2({
                allocPoint: _allocPoint,
                lastRewardBlock: firstBlock,
                accRosePerShare: 0,
                lastUnlockedBlock: 0,
                lockedAmount: 0,
                freeAmount: 0,
                maxLockAmount: _maxLockAmount,
                unlockIntervalBlock: _unlockIntervalBlock,
                feeAmount: 0,
                sharedFeeAmount: 0
            })
        );
    }

    function set1(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePool1s();
        }
        allocPointPool1 = allocPointPool1.sub(poolInfo1[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo1[_pid].allocPoint = _allocPoint;
    }

    function set2(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePool2s();
        }
        allocPointPool2 = allocPointPool2.sub(poolInfo2[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo2[_pid].allocPoint = _allocPoint;
    }

    function setMaxLockAmount(uint256 _pid, uint256 _maxLockAmount)
        external
        onlyOwner
    {
        poolInfo2[_pid].maxLockAmount = _maxLockAmount;
    }

    function setUnlockIntervalBlock(uint256 _pid, uint256 _unlockIntervalBlock)
        external
        onlyOwner
    {
        poolInfo2[_pid].unlockIntervalBlock = _unlockIntervalBlock;
    }

    function getBlockRewardNow() public view returns (uint256) {
        return getBlockRewards(block.number, block.number + 1);
    }

    function getBlockRewards(uint256 from, uint256 to)
        public
        view
        returns (uint256 rewards)
    {
        if (from < startBlock) {
            from = startBlock;
        }
        if (from >= to) {
            return 0;
        }

        for (uint256 i = 0; i < periodInfo.length; i++) {
            if (periodInfo[i].endBlock >= to) {
                return to.sub(from).mul(periodInfo[i].blockReward).add(rewards);
            } else if (periodInfo[i].endBlock <= from) {
                continue;
            } else {
                rewards = rewards.add(
                    periodInfo[i].endBlock.sub(from).mul(
                        periodInfo[i].blockReward
                    )
                );
                from = periodInfo[i].endBlock;
            }
        }
    }

    function pendingRose1(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        PoolInfo1 storage pool = poolInfo1[_pid];
        UserInfo storage user = userInfo1[_pid][_user];
        uint256 accRosePerShare = pool.accRosePerShare;
        uint256 lpSupply = pool.totalAmount;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blockRewards = getBlockRewards(
                pool.lastRewardBlock,
                block.number
            );
            blockRewards = blockRewards.mul(7).div(10);
            uint256 roseReward = blockRewards.mul(pool.allocPoint).div(
                allocPointPool1
            );
            accRosePerShare = accRosePerShare.add(
                roseReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accRosePerShare).div(1e12).sub(user.rewardDebt);
    }

    function pendingRose2(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        PoolInfo2 storage pool = poolInfo2[_pid];
        UserInfo storage user = userInfo2[_pid][_user];
        uint256 accRosePerShare = pool.accRosePerShare;
        uint256 lpSupply = pool.lockedAmount.add(pool.freeAmount);
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blockRewards = getBlockRewards(
                pool.lastRewardBlock,
                block.number
            );
            blockRewards = blockRewards.mul(3).div(10);
            uint256 roseReward = blockRewards.mul(pool.allocPoint).div(
                allocPointPool2
            );
            accRosePerShare = accRosePerShare.add(
                roseReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accRosePerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePool1s() public {
        uint256 length = poolInfo1.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool1(pid);
        }
    }

    function massUpdatePool2s() public {
        uint256 length = poolInfo2.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool2(pid);
        }
    }

    function updatePool1(uint256 _pid) public {
        PoolInfo1 storage pool = poolInfo1[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.totalAmount;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 blockRewards = getBlockRewards(
            pool.lastRewardBlock,
            block.number
        );
        blockRewards = blockRewards.mul(7).div(10);
        uint256 roseReward = blockRewards.mul(pool.allocPoint).div(
            allocPointPool1
        );
        rose.mint(devaddr, roseReward.div(10));
        if (rankAddr != address(0)) {
            rose.mint(rankAddr, roseReward.mul(9).div(100));
        }
        if (communityAddr != address(0)) {
            rose.mint(communityAddr, roseReward.div(100));
        }
        rose.mint(address(this), roseReward);
        pool.accRosePerShare = pool.accRosePerShare.add(
            roseReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function updatePool2(uint256 _pid) public {
        PoolInfo2 storage pool = poolInfo2[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lockedAmount.add(pool.freeAmount);
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 blockRewards = getBlockRewards(
            pool.lastRewardBlock,
            block.number
        );
        blockRewards = blockRewards.mul(3).div(10);
        uint256 roseReward = blockRewards.mul(pool.allocPoint).div(
            allocPointPool2
        );
        rose.mint(devaddr, roseReward.div(10));
        if (rankAddr != address(0)) {
            rose.mint(rankAddr, roseReward.mul(9).div(100));
        }
        if (communityAddr != address(0)) {
            rose.mint(communityAddr, roseReward.div(100));
        }
        rose.mint(address(this), roseReward);
        pool.accRosePerShare = pool.accRosePerShare.add(
            roseReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function deposit1(uint256 _pid, uint256 _amount) public {
        PoolInfo1 storage pool = poolInfo1[_pid];
        UserInfo storage user = userInfo1[_pid][msg.sender];
        updatePool1(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount
                .mul(pool.accRosePerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            if (pending > 0) {
                safeRoseTransfer(msg.sender, pending);
                mintReferralReward(pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
            pool.totalAmount = pool.totalAmount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRosePerShare).div(1e12);
        emit Deposit1(msg.sender, _pid, _amount);
    }

    function deposit2(uint256 _pid, uint256 _amount) public {
        PoolInfo2 storage pool = poolInfo2[_pid];
        UserInfo storage user = userInfo2[_pid][msg.sender];
        updatePool2(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount
                .mul(pool.accRosePerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            if (pending > 0) {
                safeRoseTransfer(msg.sender, pending);
                mintReferralReward(pending);
            }
        }
        if (_amount > 0) {
            _safeTransferFrom(sfr, address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            pool.lockedAmount = pool.lockedAmount.add(_amount);
        }
        updateLockedAmount(pool);
        user.rewardDebt = user.amount.mul(pool.accRosePerShare).div(1e12);
        emit Deposit2(msg.sender, _pid, _amount);
    }

    function withdraw1(uint256 _pid, uint256 _amount) public {
        PoolInfo1 storage pool = poolInfo1[_pid];
        UserInfo storage user = userInfo1[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool1(_pid);
        uint256 pending = user.amount.mul(pool.accRosePerShare).div(1e12).sub(
            user.rewardDebt
        );
        if (pending > 0) {
            safeRoseTransfer(msg.sender, pending);
            mintReferralReward(pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.totalAmount = pool.totalAmount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRosePerShare).div(1e12);
        emit Withdraw1(msg.sender, _pid, _amount);
    }

    function withdraw2(uint256 _pid, uint256 _amount) public {
        UserInfo storage user = userInfo2[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        PoolInfo2 storage pool = poolInfo2[_pid];
        updateLockedAmount(pool);
        require(
            _amount <= pool.freeAmount,
            "withdraw: insufficient free balance in pool"
        );
        updatePool2(_pid);
        uint256 pending = user.amount.mul(pool.accRosePerShare).div(1e12).sub(
            user.rewardDebt
        );
        if (pending > 0) {
            safeRoseTransfer(msg.sender, pending);
            mintReferralReward(pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.freeAmount = pool.freeAmount.sub(_amount);
            uint256 fee = _amount.mul(3).div(1000);
            pool.feeAmount = pool.feeAmount.add(fee);
            _safeTransfer(sfr, address(msg.sender), _amount.sub(fee));
        }
        user.rewardDebt = user.amount.mul(pool.accRosePerShare).div(1e12);
        emit Withdraw2(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw1(uint256 _pid) public {
        PoolInfo1 storage pool = poolInfo1[_pid];
        UserInfo storage user = userInfo1[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw1(msg.sender, _pid, amount);
    }

    function emergencyWithdraw2(uint256 _pid) public {
        PoolInfo2 storage pool = poolInfo2[_pid];
        UserInfo storage user = userInfo2[_pid][msg.sender];
        require(user.amount <= pool.freeAmount);
        _safeTransfer(sfr, address(msg.sender), user.amount);
        emit EmergencyWithdraw2(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function safeRoseTransfer(address _to, uint256 _amount) internal {
        uint256 roseBal = rose.balanceOf(address(this));
        if (_amount > roseBal) {
            rose.transfer(_to, roseBal);
        } else {
            rose.transfer(_to, _amount);
        }
    }

    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    function rank(address _addr) public onlyOwner {
        rankAddr = _addr;
    }

    function community(address _addr) public onlyOwner {
        communityAddr = _addr;
    }

    function refer(address _user) external {
        require(_user != msg.sender && referrers[_user] != address(0));
        require(referrers[msg.sender] == address(0));
        referrers[msg.sender] = _user;
        referreds1[_user].push(msg.sender);
        address referrer2 = referrers[_user];
        if (_user != referrer2) {
            referreds2[referrer2].push(msg.sender);
        }
    }

    function getReferreds1(address addr, uint256 startPos)
        external
        view
        returns (uint256 length, address[] memory data)
    {
        address[] memory referreds = referreds1[addr];
        length = referreds.length;
        data = new address[](length);
        for (uint256 i = 0; i < 5 && i + startPos < length; i++) {
            data[i] = referreds[startPos + i];
        }
    }

    function getReferreds2(address addr, uint256 startPos)
        external
        view
        returns (uint256 length, address[] memory data)
    {
        address[] memory referreds = referreds2[addr];
        length = referreds.length;
        data = new address[](length);
        for (uint256 i = 0; i < 5 && i + startPos < length; i++) {
            data[i] = referreds[startPos + i];
        }
    }

    function allPendingRose(address _user)
        external
        view
        returns (uint256 pending)
    {
        for (uint256 i = 0; i < poolInfo1.length; i++) {
            pending = pending.add(pendingRose1(i, _user));
        }
        for (uint256 i = 0; i < poolInfo2.length; i++) {
            pending = pending.add(pendingRose2(i, _user));
        }
    }

    function mintReferralReward(uint256 _amount) internal {
        address referrer = referrers[msg.sender];
        if (address(0) == referrer) {
            return;
        }
        rose.mint(msg.sender, _amount.div(100));
        rose.mint(referrer, _amount.mul(2).div(100));

        if (referrers[referrer] == referrer) {
            return;
        }
        rose.mint(referrers[referrer], _amount.mul(2).div(100));
    }

    function updateLockedAmount(PoolInfo2 storage pool) internal {
        uint256 passedBlock = block.number - pool.lastUnlockedBlock;
        if (passedBlock >= pool.unlockIntervalBlock) {
            pool.lastUnlockedBlock = pool.lastUnlockedBlock.add(
                pool.unlockIntervalBlock.mul(
                    passedBlock.div(pool.unlockIntervalBlock)
                )
            );
            uint256 lockedAmount = pool.lockedAmount;
            pool.lockedAmount = 0;
            pool.freeAmount = pool.freeAmount.add(lockedAmount);
        } else if (pool.lockedAmount >= pool.maxLockAmount) {
            uint256 freeAmount = pool.lockedAmount.mul(75).div(100);
            pool.lockedAmount = pool.lockedAmount.sub(freeAmount);
            pool.freeAmount = pool.freeAmount.add(freeAmount);
        }
    }

    function convert(uint256 _pid) external {
        PoolInfo2 storage pool = poolInfo2[_pid];
        uint256 lpSupply = pool.freeAmount.add(pool.lockedAmount);
        if (address(sfr2rose) != address(0) && pool.feeAmount > 0) {
            uint256 amountOut = swapSFRForROSE(pool.feeAmount);
            if (amountOut > 0) {
                pool.feeAmount = 0;
                pool.sharedFeeAmount = pool.sharedFeeAmount.add(amountOut);
                pool.accRosePerShare = pool.accRosePerShare.add(
                    amountOut.mul(1e12).div(lpSupply)
                );
            }
        }
    }

    function swapSFRForROSE(uint256 _amount)
        internal
        returns (uint256 amountOut)
    {
        (uint256 reserve0, uint256 reserve1, ) = sfr2rose.getReserves();
        address token0 = sfr2rose.token0();
        (uint256 reserveIn, uint256 reserveOut) = token0 == sfr
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
        uint256 amountInWithFee = _amount.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
        if (amountOut == 0) {
            return 0;
        }
        (uint256 amount0Out, uint256 amount1Out) = token0 == sfr
            ? (uint256(0), amountOut)
            : (amountOut, uint256(0));
        _safeTransfer(sfr, address(sfr2rose), _amount);
        sfr2rose.swap(amount0Out, amount1Out, address(this), new bytes(0));
    }

    function _safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        IERC20(token).safeTransferFrom(from, to, amount);
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        IERC20(token).safeTransfer(to, amount);
    }
}