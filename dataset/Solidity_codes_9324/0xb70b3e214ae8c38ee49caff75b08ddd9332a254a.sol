
pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;


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

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() public {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "REENTRANCY_ERROR");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

interface IUniswapRouter {

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}

interface IUniswapFactory {

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);


    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

}

interface IMasterChef {

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. SUSHIs to distribute per block.
        uint256 lastRewardBlock; // Last block number that SUSHIs distribution occurs.
        uint256 accSushiPerShare; // Accumulated SUSHIs per share, times 1e12.
    }

    function deposit(uint256 _pid, uint256 _amount) external;


    function withdraw(uint256 _pid, uint256 _amount) external;


    function poolInfo(uint256 _pid) external view returns (PoolInfo memory);


    function pendingSushi(uint256 _pid, address _user)
        external
        view
        returns (uint256);


    function updatePool(uint256 _pid) external;


    function sushiPerBlock() external view returns (uint256);


    function totalAllocPoint() external view returns (uint256);


    function getMultiplier(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);

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

contract ReceiptToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor()
        public
        ERC20("pAT", "Parachain Auction Token")
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public {
        require(
            hasRole(MINTER_ROLE, msg.sender),
            "ReceiptToken: Caller is not a minter"
        );
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        require(
            hasRole(BURNER_ROLE, msg.sender),
            "ReceiptToken: Caller is not a burner"
        );
        _burn(from, amount);
    }
}

contract SushiETHSLP is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    ReceiptToken public receiptToken;
    address public token;
    address public weth;
    address public sushi;
    address payable public treasuryAddress;

    IUniswapRouter public sushiswapRouter;
    IUniswapFactory public sushiswapFactory;
    IMasterChef public masterChef;

    struct UserInfo {
        uint256 amountEth; //amount of eth user invested
        uint256 amount; // How many SLP tokens the user has provided.
        uint256 sushiRewardDebt; // Reward debt for Sushi rewards. See explanation below.
        uint256 userTreasuryEth; //how much eth the user sent to treasury
        uint256 userCollectedFees; //how much eth the user sent to fee address
        uint256 userAccumulatedSushi; //how many rewards this user has
        uint256 amountReceiptToken; //receipt tokens printed for user; should be equal to amountfDai
        bool wasUserBlacklisted; //if user was blacklist at deposit time, he is not receiving receipt tokens
        uint256 timestamp; //first deposit timestamp; used for withdrawal lock time check
        uint256 earnedRewards; //before fees
    }

    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public blacklisted; //blacklisted users do not receive a receipt token

    uint256 public masterChefPoolId = 0;

    uint256 public ethDust;
    uint256 public tokenDust;
    uint256 public treasueryEthDust;
    uint256 public treasuryTokenDust;

    uint256 public cap = uint256(1000); //eth cap
    uint256 public totalEth; //total invested eth
    uint256 public ethPrice; //for UI; to be updated from a script
    uint256 public lockTime = 10368000; //120 days

    address payable public feeAddress;
    uint256 public fee = uint256(50);
    uint256 constant feeFactor = uint256(10000);

    event RewardsExchanged(
        address indexed user,
        uint256 rewardsAmount,
        uint256 obtainedEth
    );
    event RewardsEarned(address indexed user, uint256 amount);
    event FeeSet(address indexed sender, uint256 feeAmount);
    event FeeAddressSet(address indexed sender, address indexed feeAddress);

    event BlacklistChanged(
        string actionType,
        address indexed user,
        bool oldVal,
        bool newVal
    );
    event ReceiptMinted(address indexed user, uint256 amount);
    event ReceiptBurned(address indexed user, uint256 amount);

    event PoolIdChanged(address indexed sender, uint256 oldPid, uint256 newPid);

    event Deposit(
        address indexed user,
        address indexed origin,
        uint256 pid,
        uint256 amount
    );

    event Withdraw(
        address indexed user,
        address indexed origin,
        uint256 pid,
        uint256 amount,
        uint256 auctionedAmount
    );

    event ChangedAddress(
        string indexed addressType,
        address indexed oldAddress,
        address indexed newAddress
    );

    event RescuedDust(string indexed dustType, uint256 amount);

    mapping(address => bool) public approved; //to defend against non whitelisted contracts

    struct DepositData {
        uint256 toSwapAmount;
        address[] swapPath;
        uint256[] swapAmounts;
        uint256 obtainedToken;
        uint256 liquidityTokenAmount;
        uint256 liquidityEthAmount;
        uint256 liquidity;
        address pair;
        uint256 pendingSushiTokens;
    }

    struct WithdrawData {
        uint256 prevSushiAmount;
        uint256 prevTokenAmount;
        uint256 prevSlpAmount;
        uint256 sushiAmount;
        uint256 tokenAmount;
        uint256 slpAmount;
        address pair;
        uint256 tokenLiquidityAmount;
        uint256 ethLiquidityAmount;
        uint256 totalToken;
        uint256 totalSushi;
        uint256 totalEth;
        uint256 feeableEth;
        uint256 auctionedEth;
        uint256 prevDustEthBalance;
        uint256 prevDustTokenBalance;
    }

    constructor(
        address _token,
        address _weth,
        address _sushi,
        address _sushiswapRouter,
        address _sushiswapFactory,
        address _masterChef,
        address payable _treasuryAddress,
        uint256 _poolId,
        address _receiptToken,
        address payable _feeAddress
    ) public {
        require(_token != address(0), "token_0x0");
        require(_weth != address(0), "WETH_0x0");
        require(_sushi != address(0), "SUSHI_0x0");
        require(_sushiswapRouter != address(0), "ROUTER_0x0");
        require(_sushiswapFactory != address(0), "FACTORY_0x0");
        require(_masterChef != address(0), "CHEF_0x0");
        require(_treasuryAddress != address(0), "TREASURY_0x0");
        require(_receiptToken != address(0), "RECEIPT_0x0");
        require(_feeAddress != address(0), "FEE_0x0");

        token = _token;
        weth = _weth;
        sushi = _sushi;
        sushiswapRouter = IUniswapRouter(_sushiswapRouter);
        sushiswapFactory = IUniswapFactory(_sushiswapFactory);
        masterChef = IMasterChef(_masterChef);
        treasuryAddress = _treasuryAddress;
        masterChefPoolId = _poolId;
        receiptToken = ReceiptToken(_receiptToken);
        feeAddress = _feeAddress;
    }


    function setTokenAddress(address _token) public onlyOwner {
        require(_token != address(0), "0x0");
        emit ChangedAddress("TOKEN", address(token), address(_token));
        token = _token;
    }

    function setWethAddress(address _weth) public onlyOwner {
        require(_weth != address(0), "0x0");
        emit ChangedAddress("WETH", address(weth), address(_weth));
        weth = _weth;
    }

    function setSushiAddress(address _sushi) public onlyOwner {
        require(_sushi != address(0), "0x0");
        emit ChangedAddress("SUSHI", address(sushi), address(_sushi));
        sushi = _sushi;
    }

    function setSushiswapRouter(address _sushiswapRouter) public onlyOwner {
        require(_sushiswapRouter != address(0), "0x0");
        emit ChangedAddress(
            "SUSHISWAP_ROUTER",
            address(sushiswapRouter),
            address(_sushiswapRouter)
        );
        sushiswapRouter = IUniswapRouter(_sushiswapRouter);
    }

    function setSushiswapFactory(address _sushiswapFactory) public onlyOwner {
        require(_sushiswapFactory != address(0), "0x0");
        emit ChangedAddress(
            "SUSHISWAP_FACTORY",
            address(sushiswapFactory),
            address(_sushiswapFactory)
        );
        sushiswapFactory = IUniswapFactory(_sushiswapFactory);
    }

    function setMasterChef(address _masterChef) public onlyOwner {
        require(_masterChef != address(0), "0x0");
        emit ChangedAddress(
            "MASTER_CHEF",
            address(masterChef),
            address(_masterChef)
        );
        masterChef = IMasterChef(_masterChef);
    }

    function setTreasury(address payable _feeAddress) public onlyOwner {
        require(_feeAddress != address(0), "0x0");
        emit ChangedAddress(
            "TREASURY",
            address(treasuryAddress),
            address(_feeAddress)
        );
        treasuryAddress = _feeAddress;
    }

    function approveContractAccess(address account) external onlyOwner {
        require(account != address(0), "0x0");
        approved[account] = true;
    }

    function revokeContractAccess(address account) external onlyOwner {
        require(account != address(0), "0x0");
        approved[account] = false;
    }

    function blacklistAddress(address account) external onlyOwner {
        require(account != address(0), "0x0");
        emit BlacklistChanged("BLACKLIST", account, blacklisted[account], true);
        blacklisted[account] = true;
    }

    function removeFromBlacklist(address account) external onlyOwner {
        require(account != address(0), "0x0");
        emit BlacklistChanged("REMOVE", account, blacklisted[account], false);
        blacklisted[account] = false;
    }

    function setCap(uint256 _cap) external onlyOwner {
        cap = _cap;
    }

    function setEthPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "PRICE_0");
        ethPrice = _price;
    }

    function setLockTime(uint256 _lockTime) external onlyOwner {
        require(_lockTime > 0, "TIME_0");
        lockTime = _lockTime;
    }

    function setPoolId(uint256 _pid) public onlyOwner {
        uint256 old = masterChefPoolId;
        masterChefPoolId = _pid;
        emit PoolIdChanged(msg.sender, old, _pid);
    }

    function setFeeAddress(address payable _feeAddress) public onlyOwner {
        feeAddress = _feeAddress;
        emit FeeAddressSet(msg.sender, _feeAddress);
    }

    function setFee(uint256 _fee) public onlyOwner {
        require(_fee <= uint256(9000), "FEE_TOO_HIGH");
        fee = _fee;
        emit FeeSet(msg.sender, _fee);
    }

    function rescueDust() public onlyOwner {
        if (ethDust > 0) {
            treasuryAddress.transfer(ethDust);
            treasueryEthDust = treasueryEthDust.add(ethDust);
            emit RescuedDust("ETH", ethDust);
            ethDust = 0;
        }
        if (tokenDust > 0) {
            IERC20(token).safeTransfer(treasuryAddress, tokenDust);
            treasuryTokenDust = treasuryTokenDust.add(tokenDust);
            emit RescuedDust("TOKEN", tokenDust);
            tokenDust = 0;
        }
    }

    function rescueAirdroppedTokens(address _token, address to)
        public
        onlyOwner
    {
        require(_token != address(0), "token_0x0");
        require(to != address(0), "to_0x0");
        require(_token != sushi, "rescue_reward_error");

        uint256 balanceOfToken = IERC20(_token).balanceOf(address(this));
        require(balanceOfToken > 0, "balance_0");

        require(IERC20(_token).transfer(to, balanceOfToken), "rescue_failed");
    }

    function isWithdrawalAvailable(address user) public view returns (bool) {
        if (lockTime > 0) {
            return userInfo[user].timestamp.add(lockTime) <= block.timestamp;
        }
        return true;
    }

    function deposit(uint256 deadline)
        public
        payable
        nonReentrant
        returns (uint256)
    {
        _defend();
        require(msg.value > 0, "ETH_0");
        require(deadline >= block.timestamp, "DEADLINE_ERROR");
        require(totalEth.add(msg.value) <= cap, "CAP_REACHED");

        uint256 prevEthBalance = address(this).balance.sub(msg.value);
        uint256 prevTokenBalance = IERC20(token).balanceOf(address(this));

        DepositData memory results;
        UserInfo storage user = userInfo[msg.sender];

        if (user.amount == 0) {
            user.wasUserBlacklisted = blacklisted[msg.sender];
        }
        if (user.timestamp == 0) {
            user.timestamp = block.timestamp;
        }
        totalEth = totalEth.add(msg.value);
        user.amountEth = user.amountEth.add(msg.value);

        results.toSwapAmount = msg.value.div(2);
        results.swapPath = new address[](2);
        results.swapPath[0] = weth;
        results.swapPath[1] = token;

        results.swapAmounts = sushiswapRouter.swapExactETHForTokens{
            value: results.toSwapAmount
        }(uint256(0), results.swapPath, address(this), deadline);

        results.obtainedToken = results.swapAmounts[
            results.swapAmounts.length - 1
        ];

        IERC20(token).safeIncreaseAllowance(
            address(sushiswapRouter),
            results.obtainedToken
        );
        (
            results.liquidityTokenAmount,
            results.liquidityEthAmount,
            results.liquidity
        ) = sushiswapRouter.addLiquidityETH{value: results.toSwapAmount}(
            token,
            results.obtainedToken,
            uint256(0),
            uint256(0),
            address(this),
            deadline
        );

        results.pair = sushiswapFactory.getPair(token, weth);

        IERC20(results.pair).safeIncreaseAllowance(
            address(masterChef),
            results.liquidity
        );

        masterChef.updatePool(masterChefPoolId);
        results.pendingSushiTokens = user
            .amount
            .mul(masterChef.poolInfo(masterChefPoolId).accSushiPerShare)
            .div(1e12)
            .sub(user.sushiRewardDebt);

        user.amount = user.amount.add(results.liquidity);
        if (!user.wasUserBlacklisted) {
            user.amountReceiptToken = user.amountReceiptToken.add(
                results.liquidity
            );
            receiptToken.mint(msg.sender, results.liquidity);
            emit ReceiptMinted(msg.sender, results.liquidity);
        }

        masterChef.updatePool(masterChefPoolId);
        user.sushiRewardDebt = user
            .amount
            .mul(masterChef.poolInfo(masterChefPoolId).accSushiPerShare)
            .div(1e12);

        uint256 prevSushiBalance = IERC20(sushi).balanceOf(address(this));

        masterChef.deposit(masterChefPoolId, results.liquidity);

        if (results.pendingSushiTokens > 0) {
            uint256 sushiBalance = IERC20(sushi).balanceOf(address(this));
            uint256 actualSushiTokens = sushiBalance.sub(prevSushiBalance);

            if (results.pendingSushiTokens > actualSushiTokens) {
                user.userAccumulatedSushi = user.userAccumulatedSushi.add(
                    actualSushiTokens
                );
            } else {
                user.userAccumulatedSushi = user.userAccumulatedSushi.add(
                    results.pendingSushiTokens
                );
            }
        }

        emit Deposit(
            msg.sender,
            tx.origin,
            masterChefPoolId,
            results.liquidity
        );

        ethDust = ethDust.add(address(this).balance.sub(prevEthBalance));
        tokenDust = tokenDust.add(
            (IERC20(token).balanceOf(address(this))).sub(prevTokenBalance)
        );

        return results.liquidity;
    }

    function withdraw(uint256 amount, uint256 deadline)
        public
        nonReentrant
        returns (uint256)
    {
        uint256 receiptBalance = receiptToken.balanceOf(msg.sender);

        _defend();
        require(deadline >= block.timestamp, "DEADLINE_ERROR");
        require(amount > 0, "AMOUNT_0");
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= amount, "AMOUNT_GREATER_THAN_BALANCE");
        if (!user.wasUserBlacklisted) {
            require(receiptBalance >= user.amount, "RECEIPT_AMOUNT");
        }

        if (lockTime > 0) {
            require(
                user.timestamp.add(lockTime) <= block.timestamp,
                "LOCK_TIME"
            );
        }

        WithdrawData memory results;

        results.prevDustEthBalance = address(this).balance;
        results.prevDustTokenBalance = IERC20(token).balanceOf(address(this));

        masterChef.updatePool(masterChefPoolId);
        uint256 pendingSushiTokens =
            user
                .amount
                .mul(masterChef.poolInfo(masterChefPoolId).accSushiPerShare)
                .div(1e12)
                .sub(user.sushiRewardDebt);

        (
            results.pair,
            results.tokenAmount,
            results.sushiAmount,
            results.slpAmount
        ) = _witdraw(amount);
        require(results.slpAmount > 0, "SLP_AMOUNT_0");

        user.amount = user.amount.sub(amount);
        if (!user.wasUserBlacklisted) {
            user.amountReceiptToken = user.amountReceiptToken.sub(amount);
            receiptToken.burn(msg.sender, amount);
            emit ReceiptBurned(msg.sender, amount);
        }

        user.sushiRewardDebt = user
            .amount
            .mul(masterChef.poolInfo(masterChefPoolId).accSushiPerShare)
            .div(1e12);

        uint256 sushiBalance = IERC20(sushi).balanceOf(address(this));
        if (pendingSushiTokens > 0) {
            if (pendingSushiTokens > sushiBalance) {
                user.userAccumulatedSushi = user.userAccumulatedSushi.add(
                    sushiBalance
                );
            } else {
                user.userAccumulatedSushi = user.userAccumulatedSushi.add(
                    pendingSushiTokens
                );
            }
        }

        IERC20(results.pair).safeIncreaseAllowance(
            address(sushiswapRouter),
            results.slpAmount
        );
        (
            results.tokenLiquidityAmount,
            results.ethLiquidityAmount
        ) = sushiswapRouter.removeLiquidityETH(
            token,
            results.slpAmount,
            uint256(0),
            uint256(0),
            address(this),
            deadline
        );

        require(results.tokenLiquidityAmount > 0, "TOKEN_LIQUIDITY_0");
        require(results.ethLiquidityAmount > 0, "ETH_LIQUIDITY_0");

        results.totalSushi = user.userAccumulatedSushi;
        results.totalToken = results.totalToken.add(
            results.tokenLiquidityAmount
        );
        results.totalEth = results.ethLiquidityAmount;

        address[] memory swapPath = new address[](2);
        swapPath[0] = sushi;
        swapPath[1] = weth;

        if (results.totalSushi > 0) {
            emit RewardsEarned(msg.sender, results.totalSushi);
            user.earnedRewards = user.earnedRewards.add(results.totalSushi);

            IERC20(sushi).safeIncreaseAllowance(
                address(sushiswapRouter),
                results.totalSushi
            );

            uint256[] memory sushiSwapAmounts =
                sushiswapRouter.swapExactTokensForETH(
                    results.totalSushi,
                    uint256(0),
                    swapPath,
                    address(this),
                    deadline
                );

            emit RewardsExchanged(
                msg.sender,
                results.totalSushi,
                sushiSwapAmounts[sushiSwapAmounts.length - 1]
            );
            results.feeableEth = results.feeableEth.add(
                sushiSwapAmounts[sushiSwapAmounts.length - 1]
            );
        }

        if (results.totalToken > 0) {
            IERC20(token).safeIncreaseAllowance(
                address(sushiswapRouter),
                results.totalToken
            );
            swapPath[0] = token;

            uint256[] memory tokenSwapAmounts =
                sushiswapRouter.swapExactTokensForETH(
                    results.totalToken,
                    uint256(0),
                    swapPath,
                    address(this),
                    deadline
                );

            results.totalEth = results.totalEth.add(
                tokenSwapAmounts[tokenSwapAmounts.length - 1]
            );
        }

        results.auctionedEth = results.feeableEth.div(2);
        results.feeableEth = results.feeableEth.sub(results.auctionedEth);
        results.totalEth = results.totalEth.add(results.feeableEth);

        if (user.amountEth > results.totalEth) {
            user.amountEth = user.amountEth.sub(results.totalEth);
        } else {
            user.amountEth = 0;
        }

        if (results.totalEth < totalEth) {
            totalEth = totalEth.sub(results.totalEth);
        } else {
            totalEth = 0;
        }

        if (fee > 0) {
            uint256 feeEth = _calculateFee(results.totalEth);
            results.totalEth = results.totalEth.sub(feeEth);

            feeAddress.transfer(feeEth);
            user.userCollectedFees = user.userCollectedFees.add(feeEth);
        }

        msg.sender.transfer(results.totalEth);

        treasuryAddress.transfer(results.auctionedEth);
        user.userTreasuryEth = user.userTreasuryEth.add(results.auctionedEth);

        emit Withdraw(
            msg.sender,
            tx.origin,
            masterChefPoolId,
            results.totalEth,
            results.auctionedEth
        );
        user.userAccumulatedSushi = 0;

        ethDust = ethDust.add(
            address(this).balance.sub(results.prevDustEthBalance)
        );
        tokenDust = tokenDust.add(
            (IERC20(token).balanceOf(address(this))).sub(
                results.prevDustTokenBalance
            )
        );

        return results.totalEth;
    }

    function _witdraw(uint256 amount)
        private
        returns (
            address,
            uint256,
            uint256,
            uint256
        )
    {
        WithdrawData memory results;
        results.pair = sushiswapFactory.getPair(token, weth);

        results.prevTokenAmount = IERC20(token).balanceOf(address(this));
        results.prevSushiAmount = IERC20(sushi).balanceOf(address(this));
        results.prevSlpAmount = IERC20(results.pair).balanceOf(address(this));

        masterChef.updatePool(masterChefPoolId);
        masterChef.withdraw(masterChefPoolId, amount);

        results.tokenAmount = (IERC20(token).balanceOf(address(this))).sub(
            results.prevTokenAmount
        );
        results.sushiAmount = (IERC20(sushi).balanceOf(address(this))).sub(
            results.prevSushiAmount
        );
        results.slpAmount = (IERC20(results.pair).balanceOf(address(this))).sub(
            results.prevSlpAmount
        );

        return (
            results.pair,
            results.tokenAmount,
            results.sushiAmount,
            results.slpAmount
        );
    }

    function getPendingRewards(address account) public view returns (uint256) {
        UserInfo storage user = userInfo[account];
        IMasterChef.PoolInfo memory sushiPool =
            masterChef.poolInfo(masterChefPoolId);
        uint256 sushiPerBlock = masterChef.sushiPerBlock();
        uint256 totalSushiAllocPoint = masterChef.totalAllocPoint();
        uint256 accSushiPerShare = sushiPool.accSushiPerShare;
        uint256 lpSupply = sushiPool.lpToken.balanceOf(address(masterChef));

        if (block.number > sushiPool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                masterChef.getMultiplier(
                    sushiPool.lastRewardBlock,
                    block.number
                );
            uint256 sushiReward =
                multiplier.mul(sushiPerBlock).mul(sushiPool.allocPoint).div(
                    totalSushiAllocPoint
                );
            accSushiPerShare = accSushiPerShare.add(
                sushiReward.mul(1e12).div(lpSupply)
            );
        }

        uint256 accumulatedSushi = user.amount.mul(accSushiPerShare).div(1e12);

        if (accumulatedSushi < user.sushiRewardDebt) {
            return 0;
        }

        return accumulatedSushi.sub(user.sushiRewardDebt);
    }

    function _calculateFee(uint256 amount) private view returns (uint256) {
        return (amount.mul(fee)).div(feeFactor);
    }

    function _defend() private view returns (bool) {
        require(
            approved[msg.sender] || msg.sender == tx.origin,
            "access_denied"
        );
    }

    receive() external payable {}
}