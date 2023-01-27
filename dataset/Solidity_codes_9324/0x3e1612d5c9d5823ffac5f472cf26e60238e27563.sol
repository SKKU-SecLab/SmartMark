
pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


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


pragma solidity >=0.6.0 <0.8.0;

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


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
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


pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
pragma solidity >=0.6.0 <0.8.0;

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

contract BitberrySwap is ERC20("Bitberryswap", "BBS"), Ownable {
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}

pragma solidity 0.6.12;


contract BBSLevel is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct LevelInfo {
        uint256 level;
        uint256 amount;
    }

    BBSPoolV2 pool;
    IERC20 public token;

    LevelInfo[] public info;
    mapping(address => LevelInfo) public users;
    
    event LevelUp(address indexed user, uint256 amount);
    event LevelDown(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(BBSPoolV2 _pool, IERC20 _token) public {
        pool = _pool;
        token = _token;
    }

    function infoLength() public view returns (uint256) {
        return info.length;
    }

    function getLevel(address _addr) public view returns (uint256) {
        return users[_addr].level;
    }

    function getAmount(address _addr) public view returns (uint256) {
        return users[_addr].amount;
    }

    function setPoolContract(BBSPoolV2 _pool) public onlyOwner {
        pool = _pool;
    }
    
    function add(uint256 _level, uint256 _amount) public onlyOwner {
        info.push(LevelInfo({level: _level, amount: _amount}));
    }

    function set(uint256 id, uint256 _level, uint256 _amount) public onlyOwner {
        info[id].level = _level;
        info[id].amount = _amount;
    }

    function levelUp(uint256 _amount) public {
        require(_amount > 0, "levelUp: amount 0");

        LevelInfo storage user = users[msg.sender];
        user.amount = user.amount.add(_amount);

        uint256 length = info.length;
        for (uint256 i = 0; i < length; i++) {
            if (info[i].amount <= user.amount && user.level < info[i].level) {
                user.level = info[i].level;
            }
        }
        token.safeTransferFrom(address(msg.sender), address(this), _amount);
        emit LevelUp(msg.sender, _amount);
    }

    function levelDown(uint256 _amount) public {
        require(_amount > 0, "levelDown: amount 0");
        require(users[msg.sender].amount >= _amount, "levelDown: not good");
        require(!pool.userMining(msg.sender, true), "levelDown: mining ture");
        
        LevelInfo storage user = users[msg.sender];
        user.amount = user.amount.sub(_amount);
        user.level = 0;

        uint256 length = info.length;
        for (uint256 i = 0; i < length; i++) {
            if (info[i].amount <= user.amount && user.level < info[i].level) {
                user.level = info[i].level;
            }
        }

        token.safeTransfer(address(msg.sender), _amount);
        emit LevelDown(msg.sender, _amount);
    }

    function emergencyWithdraw(address _addr) public onlyOwner {
        LevelInfo storage user = users[_addr];

        token.safeTransfer(address(_addr), user.amount);
        emit EmergencyWithdraw(_addr, user.amount);
        user.level = 0;
        user.amount = 0;
    }
}

pragma solidity 0.6.12;


contract BBSReferral is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token;

    uint256 public fee;

    struct User {
        address parent;
        address[] children;
        uint256 grade;
    }

    mapping(address => User) public users;

    event AddReferral(address indexed user, address _addr);
    event Register(address indexed user, address _addr);

    constructor(IERC20 _token, uint256 _fee) public {
        token = _token;
        fee = _fee;
    }

    function getParent(address _addr) public view returns (address) {
        return users[_addr].parent;
    }

    function getChildren(address _addr) public view returns (address[] memory) {
        return users[_addr].children;
    }

    function getGrade(address _addr) public view returns (uint256) {
        return users[_addr].grade;
    }

    function setFee(IERC20 _token, uint256 _amount) public onlyOwner {
        token = _token;
        fee = _amount;
    }

    function withdraw(uint256 _amount) public onlyOwner {
        require(
            token.balanceOf(address(this)) >= _amount,
            "withdraw: not good"
        );
        token.safeTransfer(address(msg.sender), _amount);
    }

    function addMaster(address _addr) public onlyOwner {
        require(users[_addr].grade < 1, "addMaster: used address");
        User storage user = users[_addr];
        user.grade = 1;
        users[_addr] = user;
    }

    function addReferral(address _addr) public {
        require(users[_addr].grade == 1, "addReferral: not address");

        require(users[msg.sender].grade < 1, "addReferral: used address");

        User storage user = users[msg.sender];
        user.grade = 2;
        user.parent = _addr;
        users[msg.sender] = user;

        User storage master = users[_addr];
        master.children.push(msg.sender);

        token.safeTransferFrom(address(msg.sender), address(this), fee);
        emit AddReferral(msg.sender, _addr);
    }

    function register(address _addr) public {
        require(msg.sender != _addr, "register: error address");

        require(users[msg.sender].grade < 1, "register: used address");

        require(users[_addr].grade == 2, "register: not referral address");

        User storage parent = users[_addr];
        parent.children.push(msg.sender);

        User storage user = users[msg.sender];
        user.parent = _addr;
        user.grade = 3;
        emit Register(msg.sender, _addr);
    }
}
pragma solidity 0.6.12;

interface IMigratorPool {
    function migrate(IERC20 token) external returns (IERC20);
}


contract BBSPoolV2 is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accTokenPerShare;
        uint256 level;
    }

    BitberrySwap public token;
    address public teamAddr;
    uint256 public tokenPerBlock;
    uint256 public BONUS_MULTIPLIER = 1;
    IMigratorPool public migrator;
    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint;
    uint256 public startBlock;

    uint256 public endBlock;

    BBSLevel public levelContract;
    BBSReferral public referralContract;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        BitberrySwap _token,
        address _teamAddr,
        uint256 _tokenPerBlock,
        uint256 _startBlock,
        uint256 _endBlock
    ) public {
        token = _token;
        teamAddr = _teamAddr;
        tokenPerBlock = _tokenPerBlock;
        startBlock = _startBlock;
        endBlock = _endBlock;
    }

    function setLevelContract(BBSLevel _levelContract) public onlyOwner {
        levelContract = _levelContract;
    }

    function setReferralContract(BBSReferral _referralContract) public onlyOwner {
        referralContract = _referralContract;
    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function userMining(address _addr, bool _levelPool) external view returns (bool) {
        for (uint256 pid = 0; pid < poolInfo.length; pid++) {
            PoolInfo storage pool = poolInfo[pid];
            UserInfo storage user = userInfo[pid][_addr];

            if(_levelPool && pool.level > 0 && user.amount > 0)
                return true;
            else if (!_levelPool && user.amount > 0)
                return true;
        }
        return false;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate, uint256 _level) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accTokenPerShare: 0,
            level: _level
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setMigrator(IMigratorPool _migrator) public onlyOwner {
        migrator = _migrator;
    }

    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    function pendingToken(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));

        uint256 blockNumber = 0;
        if(block.number > endBlock)
            blockNumber = endBlock;
        else
            blockNumber = block.number;
        
        if (blockNumber > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, blockNumber);
            uint256 tokenReward = multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accTokenPerShare = accTokenPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt);
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
            if (block.number > endBlock)
                pool.lastRewardBlock = endBlock;
            else
                pool.lastRewardBlock = block.number;
            return;
        }
        if (pool.lastRewardBlock == endBlock){
            return;
        }

        if (block.number > endBlock){
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, endBlock);
            uint256 tokenReward = multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            pool.accTokenPerShare = pool.accTokenPerShare.add(tokenReward.mul(1e12).div(lpSupply));
            pool.lastRewardBlock = endBlock;
            return;
        }

        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 tokenReward = multiplier.mul(tokenPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accTokenPerShare = pool.accTokenPerShare.add(tokenReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
        
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(levelContract.getLevel(msg.sender) >= pool.level, "deposit : user level");
        if(pool.level > 0)
            require(referralContract.getGrade(msg.sender) > 0, "deposit : user referral");


        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
            safeTokenTransfer(msg.sender, pending, pool.level);
        }
        if(_amount > 0) { //kevin
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }
    
    function depositFor(address _beneficiary, uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_beneficiary];

        require(levelContract.getLevel(_beneficiary) >= pool.level, "depositFor : user level");
        if(pool.level > 0)
            require(referralContract.getGrade(_beneficiary) > 0, "depositFor : user referral");

        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
            safeTokenTransfer(_beneficiary, pending, pool.level);
        }
        if(_amount > 0) { //kevin
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Deposit(_beneficiary, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
        safeTokenTransfer(msg.sender, pending, pool.level);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
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

    function safeTokenTransfer(address _to, uint256 _amount, uint256 poolLevel) internal {
        uint256 tokenBal = token.balanceOf(address(this));

        if (_amount > tokenBal) {
            if( poolLevel > 0 && referralContract.getGrade(_to) == 2 ){
                address master = referralContract.getParent(_to);
                uint256 masterFee = tokenBal.mul(10).div(500); //2%
                token.transfer(master, masterFee);
                token.transfer(_to, tokenBal.sub(masterFee));
            } else if ( poolLevel > 0 && referralContract.getGrade(_to) == 3 ){
                address parent = referralContract.getParent(_to);
                address master = referralContract.getParent(parent);
                uint256 parentFee = tokenBal.mul(10).div(125); //8%
                uint256 masterFee = tokenBal.mul(10).div(500); //2%
                token.transfer(parent, parentFee);
                token.transfer(master, masterFee);
                token.transfer(_to, tokenBal.sub(parentFee).sub(masterFee));
            } else
                token.transfer(_to, tokenBal);

        } else {
            if( poolLevel > 0 && referralContract.getGrade(_to) == 2 ){
                address master = referralContract.getParent(_to);
                uint256 masterFee = _amount.mul(10).div(500); //2%
                token.transfer(master, masterFee);
                token.transfer(_to, _amount.sub(masterFee));
            } else if ( poolLevel > 0 && referralContract.getGrade(_to) == 3 ){
                address parent = referralContract.getParent(_to);
                address master = referralContract.getParent(parent);
                uint256 parentFee = _amount.mul(10).div(125); //8%
                uint256 masterFee = _amount.mul(10).div(500); //2%
                token.transfer(parent, parentFee);
                token.transfer(master, masterFee);
                token.transfer(_to, _amount.sub(parentFee).sub(masterFee));
            } else
                token.transfer(_to, _amount);
        }
    }

    function team(address _teamAddr) public {
        require(msg.sender == teamAddr, "dev: wut?");
        teamAddr = _teamAddr;
    }

    function setEndBlock(uint256 _block) public onlyOwner {
        require(block.number < _block, "setEndBlock: err _block");
        endBlock = _block;
    }

}