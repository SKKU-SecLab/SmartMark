

pragma solidity ^0.6.2;


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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

contract YieldDelegatingVaultEvent2 {
    event NewTreasury(address oldTreasury, address newTreasury);
    
    event NewDelegatePercent(uint256 oldDelegatePercent, uint256 newDelegatePercent);
    
    event NewRewardPerToken(uint256 oldRewardPerToken, uint256 newRewardPerToken);
}

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

abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

contract YDVRewardsDistributor is AccessControl, Ownable {
    using SafeERC20 for IERC20;
    using Address for address;

    IERC20 public rewardToken;
    address[] public ydvs;
    bytes32 public constant YDV_REWARDS = keccak256("YDV_REWARDS");
    
    constructor(address _rally) public {
        rewardToken = IERC20(_rally);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function transferReward(uint256 _amount) external {
        require (hasRole(YDV_REWARDS, msg.sender), "only ydv rewards");
        rewardToken.safeTransfer(msg.sender, _amount);
    }

    function addYDV(address _ydv) external onlyOwner {
        grantRole(YDV_REWARDS, _ydv);
        ydvs.push(_ydv);
    }

    function ydvsLength() external view returns (uint256) {
        return ydvs.length;
    }
}

interface Vault {
    function balanceOf(address) external view returns (uint256);
    function token() external view returns (address);
    function claimInsurance() external;
    function getPricePerFullShare() external view returns (uint256);
    function deposit(uint) external;
    function withdraw(uint) external;
}

contract YDVErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        BAD_INPUT,
        REJECTION
    }

    enum FailureInfo {
        SET_INDIVIDUAL_SOFT_CAP_CHECK,
        SET_GLOBAL_SOFT_CAP_CHECK
    }

    event Failure(uint error, uint info, uint detail);

    function fail(Error err, FailureInfo info) internal returns (uint) {
        emit Failure(uint(err), uint(info), 0);

        return uint(err);
    }

    function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {
        emit Failure(uint(err), uint(info), opaqueError);

        return uint(err);
    }
}

contract RallyToken is ERC20 {

    uint256 public constant TOKEN_SUPPLY = 15 * 10**9 * 10**18;

    constructor (
        address _escrow
    ) public ERC20(
	"Rally",
	"RLY"
    ) {
        _mint(_escrow, TOKEN_SUPPLY);	
    }
}

contract NoMintLiquidityRewardPools is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. RLYs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that RLYs distribution occurs.
        uint256 accRallyPerShare; // Accumulated RLYs per share, times 1e12. See below.
    }

    RallyToken public rally;
    uint256 public rallyPerBlock;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        RallyToken _rally,
        uint256 _rallyPerBlock,
        uint256 _startBlock
    ) public {
        rally = _rally;
        rallyPerBlock = _rallyPerBlock;
        startBlock = _startBlock;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accRallyPerShare: 0
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setRallyPerBlock(uint256 _rallyPerBlock) public onlyOwner {
        massUpdatePools();
        rallyPerBlock = _rallyPerBlock;
    }

    function pendingRally(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRallyPerShare = pool.accRallyPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = block.number.sub(pool.lastRewardBlock);
            uint256 rallyReward = multiplier.mul(rallyPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accRallyPerShare = accRallyPerShare.add(rallyReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accRallyPerShare).div(1e12).sub(user.rewardDebt);
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
        uint256 multiplier = block.number.sub(pool.lastRewardBlock);
        uint256 rallyReward = multiplier.mul(rallyPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accRallyPerShare = pool.accRallyPerShare.add(rallyReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accRallyPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeRallyTransfer(msg.sender, pending);
            }
        }
        if(_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRallyPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accRallyPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeRallyTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRallyPerShare).div(1e12);
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

    function safeRallyTransfer(address _to, uint256 _amount) internal {
        uint256 rallyBal = rally.balanceOf(address(this));
        if (_amount > rallyBal) {
            rally.transfer(_to, rallyBal);
        } else {
            rally.transfer(_to, _amount);
        }
    }
}

contract YieldDelegatingVaultStorage2 {
    address public vault;
    YDVRewardsDistributor rewards;
    IERC20 public rally;
    address public treasury;
    IERC20 public token;
    uint256 public delegatePercent;
    
    mapping(address => uint256) public rewardDebt;
    uint256 public totalDeposits;

    uint256 public rewardPerToken;
    uint256 public accRallyPerShare;

    bool public lrEnabled;
    uint256 public pid;
    NoMintLiquidityRewardPools lrPools;
}

contract YieldDelegatingVault2 is ERC20, YieldDelegatingVaultStorage2, YieldDelegatingVaultEvent2, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    constructor (
        address _vault,
        address _rewards,
        address _treasury,
        uint256 _delegatePercent,
        uint256 _rewardPerToken
    ) public ERC20(
        string(abi.encodePacked("rally delegating ", ERC20(Vault(_vault).token()).name())),
        string(abi.encodePacked("rd", ERC20(Vault(_vault).token()).symbol()))
    ) {
        _setupDecimals(ERC20(Vault(_vault).token()).decimals());
        token = IERC20(Vault(_vault).token()); //token being deposited in the referenced vault
        vault = _vault; //address of the vault we're proxying
        rewards = YDVRewardsDistributor(_rewards);
        rally = rewards.rewardToken();
	treasury = _treasury;
        delegatePercent = _delegatePercent;
        rewardPerToken = _rewardPerToken;
	totalDeposits = 0;
        accRallyPerShare = 0;
        lrEnabled = false;
    }

    function setTreasury(address newTreasury) public onlyOwner {
        require(newTreasury != address(0), "treasure should be valid address");

        address oldTreasury = treasury;
        treasury = newTreasury;

        emit NewTreasury(oldTreasury, newTreasury);
    }

    function setNewRewardPerToken(uint256 newRewardPerToken) public onlyOwner {
        uint256 oldRewardPerToken = rewardPerToken;
        rewardPerToken = newRewardPerToken;

        emit NewRewardPerToken(oldRewardPerToken, newRewardPerToken);
    }

    function earned(address account) public view returns (uint256) {
        return balanceForRewardsCalc(account).mul(accRallyPerShare).div(1e12).sub(rewardDebt[account]);
    }

    function balance() public view returns (uint256) {
        return (IERC20(vault)).balanceOf(address(this)); //how many shares do we have in the vault we are delegating to
    }

    function balanceForRewardsCalc(address account) internal view returns (uint256) {
        if (lrEnabled) {
          (uint256 amount, ) = lrPools.userInfo(pid, account);
          return balanceOf(account).add(amount); 
        }
        return balanceOf(account);
    }

    function depositAll() external {
        deposit(token.balanceOf(msg.sender));
    }

    function deposit(uint256 _amount) public nonReentrant {
        uint256 pending = earned(msg.sender);
        if (pending > 0) {
            safeRallyTransfer(msg.sender, pending);
        }
        uint256 _pool = balance();

        uint256 _before = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _after = token.balanceOf(address(this));
        _amount = _after.sub(_before);

        totalDeposits = totalDeposits.add(_amount);

        token.approve(vault, _amount);
        Vault(vault).deposit(_amount);
        uint256 _after_pool = balance();
		
        uint256 _new_shares = _after_pool.sub(_pool); //new vault tokens representing my added vault shares

        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = _new_shares;
        } else {
            shares = (_new_shares.mul(totalSupply())).div(_pool);
        }
        _mint(msg.sender, shares);
        rewardDebt[msg.sender] = balanceForRewardsCalc(msg.sender).mul(accRallyPerShare).div(1e12);
    }

    function deposityToken(uint256 _yamount) public nonReentrant {
        uint256 pending = earned(msg.sender);
        if (pending > 0) {
            safeRallyTransfer(msg.sender, pending);
        }

        uint256 _before = IERC20(vault).balanceOf(address(this));
        IERC20(vault).safeTransferFrom(msg.sender, address(this), _yamount);
        uint256 _after = IERC20(vault).balanceOf(address(this));
        _yamount = _after.sub(_before);

        uint _underlyingAmount = _yamount.mul(Vault(vault).getPricePerFullShare()).div(1e18);
        totalDeposits = totalDeposits.add(_underlyingAmount);
		
        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = _yamount;
        } else {
            shares = (_yamount.mul(totalSupply())).div(_before);
        }
        _mint(msg.sender, shares);
        rewardDebt[msg.sender] = balanceForRewardsCalc(msg.sender).mul(accRallyPerShare).div(1e12);
    }

    function withdrawAll() external {
        withdraw(balanceOf(msg.sender));
    }

    function withdraw(uint256 _shares) public nonReentrant {
        uint256 pending = earned(msg.sender);
        if (pending > 0) {
            safeRallyTransfer(msg.sender, pending);
        }

        uint256 r = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);
        safeReduceTotalDeposits(r.mul(Vault(vault).getPricePerFullShare()).div(1e18));

        rewardDebt[msg.sender] = balanceForRewardsCalc(msg.sender).mul(accRallyPerShare).div(1e12);
        
        uint256 _before = token.balanceOf(address(this));
        Vault(vault).withdraw(r);
        uint256 _after = token.balanceOf(address(this));

        uint256 toTransfer = _after.sub(_before);
        token.safeTransfer(msg.sender, toTransfer);
    }

    function safeReduceTotalDeposits(uint256 _amount) internal {
        if (_amount > totalDeposits) {
          totalDeposits = 0;
        } else {
          totalDeposits = totalDeposits.sub(_amount);
        }
    }

    function withdrawyToken(uint256 _shares) public nonReentrant {
        uint256 pending = earned(msg.sender);
        if (pending > 0) {
            safeRallyTransfer(msg.sender, pending);
        }
        uint256 r = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);
        rewardDebt[msg.sender] = balanceForRewardsCalc(msg.sender).mul(accRallyPerShare).div(1e12);
        uint256 _amount = r.mul(Vault(vault).getPricePerFullShare()).div(1e18);

        safeReduceTotalDeposits(_amount);

        IERC20(vault).safeTransfer(msg.sender, r);
    }

    function safeRallyTransfer(address _to, uint256 _amount) internal {
        uint256 rallyBal = rally.balanceOf(address(this));
        if (_amount > rallyBal) {
            rally.transfer(_to, rallyBal);
        } else {
            rally.transfer(_to, _amount);
        }
    }

    function availableYield() public view returns (uint256) {
        uint256 totalValue = balance().mul(Vault(vault).getPricePerFullShare()).div(1e18);
        if (totalValue > totalDeposits) {
            uint256 earnings = totalValue.sub(totalDeposits);
            return earnings.mul(1e18).div(Vault(vault).getPricePerFullShare());
        }
        return 0;
    }

    function harvest() public onlyOwner {
        uint256 _availableYield = availableYield();
        if (_availableYield > 0) {
            uint256 rallyReward = _availableYield.mul(delegatePercent).div(10000).mul(rewardPerToken).div(1e18);
            rewards.transferReward(rallyReward);
            IERC20(vault).safeTransfer(treasury, _availableYield.mul(delegatePercent).div(10000));
            accRallyPerShare = accRallyPerShare.add(rallyReward.mul(1e12).div(totalSupply()));
            totalDeposits = balance().mul(Vault(vault).getPricePerFullShare()).div(1e18);
        }
    }

    function enableLiquidityRewards(address _lrPools, uint256 _pid) public onlyOwner {
      (IERC20 lpToken,,,) =  NoMintLiquidityRewardPools(_lrPools).poolInfo(_pid);
      require(address(lpToken) == address(this), "invalid liquidity rewards setup");
      require(lrEnabled == false, "liquidity rewards already enabled");
      lrEnabled = true;
      lrPools = NoMintLiquidityRewardPools(_lrPools);
      pid = _pid;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
      require(lrEnabled, "transfer rejected");
      require(sender == address(lrPools) || recipient == address(lrPools), "transfer rejected");
      super._transfer(sender, recipient, amount);
    }
}