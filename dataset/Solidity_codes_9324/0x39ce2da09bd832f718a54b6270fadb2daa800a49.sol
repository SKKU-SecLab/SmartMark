
pragma solidity 0.6.6;


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

interface IHarvestVault {

    function deposit(uint256 amount) external;


    function withdraw(uint256 numberOfShares) external;

}

interface IMintNoRewardPool {

    function stake(uint256 amount) external;


    function withdraw(uint256 amount) external;


    function earned(address account) external view returns (uint256);


    function lastTimeRewardApplicable() external view returns (uint256);


    function rewardPerToken() external view returns (uint256);


    function rewards(address account) external view returns (uint256);


    function userRewardPerTokenPaid(address account)
        external
        view
        returns (uint256);


    function lastUpdateTime() external view returns (uint256);


    function rewardRate() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function rewardPerTokenStored() external view returns (uint256);


    function periodFinish() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);

    function getReward() external;

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

contract HarvestDAIStableCoin is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct UserDeposits {
        uint256 timestamp;
        uint256 amountfDai;
    }

    struct UserInfo {
        uint256 amountDai; //how much DAI the user entered with
        uint256 amountfDai; //how much fDAI was obtained after deposit to vault
        uint256 amountReceiptToken; //receipt tokens printed for user; should be equal to amountfDai
        uint256 underlyingRatio; //ratio between obtained fDai and dai
        uint256 userTreasuryEth; //how much eth the user sent to treasury
        uint256 userCollectedFees; //how much eth the user sent to fee address
        uint256 joinTimestamp; //first deposit timestamp; taken into account for lock time
        bool wasUserBlacklisted; //if user was blacklist at deposit time, he is not receiving receipt tokens
        uint256 timestamp; //first deposit timestamp; used for withdrawal lock time check
        UserDeposits[] deposits;
        uint256 earnedTokens; //before fees
        uint256 earnedRewards; //before fees
    }
    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public blacklisted; //blacklisted users do not receive a receipt token

    uint256 public firstDepositTimestamp; //used to calculate reward per block
    uint256 public totalDeposits;

    uint256 public cap = uint256(1000000); //eth cap
    uint256 public totalDai; //total invested eth
    uint256 public lockTime = 10368000; //120 days

    address payable public feeAddress;
    uint256 public fee = uint256(50);
    uint256 constant feeFactor = uint256(10000);

    ReceiptToken public receiptToken;
    address public dai;
    address public weth;
    address public farmToken;
    address public harvestPoolToken;
    address payable public treasuryAddress;
    IMintNoRewardPool public harvestRewardPool; //deposit fDai
    IHarvestVault public harvestRewardVault; //get fDai
    IUniswapRouter public sushiswapRouter;

    uint256 public ethDust;
    uint256 public treasueryEthDust;

    event RewardsExchanged(
        address indexed user,
        string exchangeType, //ETH or DAI
        uint256 rewardsAmount,
        uint256 obtainedAmount
    );
    event ExtraTokensExchanged(
        address indexed user,
        uint256 tokensAmount,
        uint256 obtainedEth
    );
    event ObtainedInfo(
        address indexed user,
        uint256 underlying,
        uint256 underlyingReceipt
    );
    event RewardsEarned(address indexed user, uint256 amount);
    event ExtraTokens(address indexed user, uint256 amount);
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

    event Deposit(
        address indexed user,
        address indexed origin,
        uint256 amountDai,
        uint256 amountfDai
    );

    event Withdraw(
        address indexed user,
        address indexed origin,
        uint256 amountDai,
        uint256 amountfDai,
        uint256 treasuryAmountEth
    );

    event RescuedDust(string indexed dustType, uint256 amount);

    event ChangedAddress(
        string indexed addressType,
        address indexed oldAddress,
        address indexed newAddress
    );

    mapping(address => bool) public approved; //to defend against non whitelisted contracts

    struct DepositData {
        address[] swapPath;
        uint256[] swapAmounts;
        uint256 obtainedDai;
        uint256 obtainedfDai;
        uint256 prevfDaiBalance;
    }

    struct WithdrawData {
        uint256 prevDustEthBalance;
        uint256 prevfDaiBalance;
        uint256 prevDaiBalance;
        uint256 obtainedfDai;
        uint256 obtainedDai;
        uint256 feeableDai;
        uint256 auctionedEth;
        uint256 auctionedDai;
        uint256 totalDai;
        uint256 rewards;
        uint256 farmBalance;
    }

    constructor(
        address _harvestRewardVault,
        address _harvestRewardPool,
        address _sushiswapRouter,
        address _harvestPoolToken,
        address _farmToken,
        address _dai,
        address _weth,
        address payable _treasuryAddress,
        address _receiptToken,
        address payable _feeAddress
    ) public {
        require(_harvestRewardVault != address(0), "VAULT_0x0");
        require(_harvestRewardPool != address(0), "POOL_0x0");
        require(_sushiswapRouter != address(0), "ROUTER_0x0");
        require(_harvestPoolToken != address(0), "TOKEN_0x0");
        require(_farmToken != address(0), "FARM_0x0");
        require(_dai != address(0), "DAI_0x0");
        require(_weth != address(0), "WETH_0x0");
        require(_treasuryAddress != address(0), "TREASURY_0x0");
        require(_receiptToken != address(0), "RECEIPT_0x0");
        require(_feeAddress != address(0), "FEE_0x0");

        harvestRewardVault = IHarvestVault(_harvestRewardVault);
        harvestRewardPool = IMintNoRewardPool(_harvestRewardPool);
        sushiswapRouter = IUniswapRouter(_sushiswapRouter);
        harvestPoolToken = _harvestPoolToken;
        farmToken = _farmToken;
        dai = _dai;
        weth = _weth;
        treasuryAddress = _treasuryAddress;
        receiptToken = ReceiptToken(_receiptToken);
        feeAddress = _feeAddress;
    }

    function setHarvestRewardVault(address _harvestRewardVault)
        public
        onlyOwner
    {
        require(_harvestRewardVault != address(0), "VAULT_0x0");
        emit ChangedAddress(
            "VAULT",
            address(harvestRewardVault),
            _harvestRewardVault
        );
        harvestRewardVault = IHarvestVault(_harvestRewardVault);
    }

    function setHarvestRewardPool(address _harvestRewardPool) public onlyOwner {
        require(_harvestRewardPool != address(0), "POOL_0x0");
        emit ChangedAddress(
            "POOL",
            address(harvestRewardPool),
            _harvestRewardPool
        );
        harvestRewardPool = IMintNoRewardPool(_harvestRewardPool);
    }

    function setSushiswapRouter(address _sushiswapRouter) public onlyOwner {
        require(_sushiswapRouter != address(0), "0x0");
        emit ChangedAddress(
            "SUSHISWAP_ROUTER",
            address(sushiswapRouter),
            _sushiswapRouter
        );
        sushiswapRouter = IUniswapRouter(_sushiswapRouter);
    }

    function setHarvestPoolToken(address _harvestPoolToken) public onlyOwner {
        require(_harvestPoolToken != address(0), "TOKEN_0x0");
        emit ChangedAddress("TOKEN", harvestPoolToken, _harvestPoolToken);
        harvestPoolToken = _harvestPoolToken;
    }

    function setFarmToken(address _farmToken) public onlyOwner {
        require(_farmToken != address(0), "FARM_0x0");
        emit ChangedAddress("FARM", farmToken, _farmToken);
        farmToken = _farmToken;
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

    function setLockTime(uint256 _lockTime) external onlyOwner {
        require(_lockTime > 0, "TIME_0");
        lockTime = _lockTime;
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
    }

    function rescueAirdroppedTokens(address _token, address to)
        public
        onlyOwner
    {
        require(_token != address(0), "token_0x0");
        require(to != address(0), "to_0x0");
        require(_token != farmToken, "rescue_reward_error");

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

    function deposit(uint256 daiAmount, uint256 deadline)
        public
        nonReentrant
        returns (uint256)
    {
        _defend();
        require(daiAmount > 0, "DAI_0");
        require(deadline >= block.timestamp, "DEADLINE_ERROR");
        require(totalDai.add(daiAmount) <= cap, "CAP_REACHED");

        DepositData memory results;
        UserInfo storage user = userInfo[msg.sender];

        if (user.amountfDai == 0) {
            user.wasUserBlacklisted = blacklisted[msg.sender];
        }
        if (user.timestamp == 0) {
            user.timestamp = block.timestamp;
        }

        IERC20(dai).safeTransferFrom(msg.sender, address(this), daiAmount);

        totalDai = totalDai.add(daiAmount);
        user.amountDai = user.amountDai.add(daiAmount);

        results.obtainedDai = daiAmount;

        IERC20(dai).safeIncreaseAllowance(
            address(harvestRewardVault),
            results.obtainedDai
        );

        results.prevfDaiBalance = IERC20(harvestPoolToken).balanceOf(
            address(this)
        );
        harvestRewardVault.deposit(results.obtainedDai);
        results.obtainedfDai = (
            IERC20(harvestPoolToken).balanceOf(address(this))
        )
            .sub(results.prevfDaiBalance);

        IERC20(harvestPoolToken).safeIncreaseAllowance(
            address(harvestRewardPool),
            results.obtainedfDai
        );
        user.amountfDai = user.amountfDai.add(results.obtainedfDai);
        if (!user.wasUserBlacklisted) {
            user.amountReceiptToken = user.amountReceiptToken.add(
                results.obtainedfDai
            );
            receiptToken.mint(msg.sender, results.obtainedfDai);
            emit ReceiptMinted(msg.sender, results.obtainedfDai);
        }

        harvestRewardPool.stake(results.obtainedfDai);

        emit Deposit(
            msg.sender,
            tx.origin,
            results.obtainedDai,
            results.obtainedfDai
        );

        if (firstDepositTimestamp == 0) {
            firstDepositTimestamp = block.timestamp;
        }
        if (user.joinTimestamp == 0) {
            user.joinTimestamp = block.timestamp;
        }
        totalDeposits = totalDeposits.add(results.obtainedfDai);
        harvestRewardPool.getReward(); //transfers FARM to this contract

        user.deposits.push(
            UserDeposits({
                timestamp: block.timestamp,
                amountfDai: results.obtainedfDai
            })
        );

        user.underlyingRatio = _getRatio(user.amountfDai, user.amountDai, 18);
        return results.obtainedfDai;
    }

    function _updateDeposits(
        bool removeAll,
        uint256 remainingAmountfDai,
        address account
    ) private {
        UserInfo storage user = userInfo[account];
        if (removeAll) {
            delete user.deposits;
            return;
        }

        for (uint256 i = user.deposits.length; i > 0; i--) {
            if (remainingAmountfDai >= user.deposits[i - 1].amountfDai) {
                remainingAmountfDai = remainingAmountfDai.sub(
                    user.deposits[i - 1].amountfDai
                );
                user.deposits[i - 1].amountfDai = 0;
            } else {
                user.deposits[i - 1].amountfDai = user.deposits[i - 1]
                    .amountfDai
                    .sub(remainingAmountfDai);
                remainingAmountfDai = 0;
            }

            if (remainingAmountfDai == 0) {
                break;
            }
        }
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
        require(user.amountfDai >= amount, "AMOUNT_GREATER_THAN_BALANCE");
        if (!user.wasUserBlacklisted) {
            require(
                receiptBalance >= user.amountReceiptToken,
                "RECEIPT_AMOUNT"
            );
        }
        if (lockTime > 0) {
            require(
                user.timestamp.add(lockTime) <= block.timestamp,
                "LOCK_TIME"
            );
        }
        WithdrawData memory results;
        results.prevDustEthBalance = address(this).balance;

        results.prevfDaiBalance = IERC20(harvestPoolToken).balanceOf(
            address(this)
        );
        IERC20(harvestPoolToken).safeIncreaseAllowance(
            address(harvestRewardPool),
            amount
        );

        harvestRewardPool.getReward(); //transfers FARM to this contract
        results.farmBalance = IERC20(farmToken).balanceOf(address(this));
        results.rewards = getPendingRewards(msg.sender, amount);

        _updateDeposits(amount == user.amountfDai, amount, msg.sender);

        harvestRewardPool.withdraw(amount);

        results.obtainedfDai = (
            IERC20(harvestPoolToken).balanceOf(address(this))
        )
            .sub(results.prevfDaiBalance);

        if (results.obtainedfDai < user.amountfDai) {
            user.amountfDai = user.amountfDai.sub(results.obtainedfDai);
            if (!user.wasUserBlacklisted) {
                user.amountReceiptToken = user.amountReceiptToken.sub(
                    results.obtainedfDai
                );
                receiptToken.burn(msg.sender, results.obtainedfDai);
                emit ReceiptBurned(msg.sender, results.obtainedfDai);
            }
        } else {
            user.amountfDai = 0;
            if (!user.wasUserBlacklisted) {
                receiptToken.burn(msg.sender, user.amountReceiptToken);
                emit ReceiptBurned(msg.sender, user.amountReceiptToken);
                user.amountReceiptToken = 0;
            }
        }

        IERC20(harvestPoolToken).safeIncreaseAllowance(
            address(harvestRewardVault),
            results.obtainedfDai
        );

        results.prevDaiBalance = IERC20(dai).balanceOf(address(this));
        harvestRewardVault.withdraw(results.obtainedfDai);
        results.obtainedDai = (IERC20(dai).balanceOf(address(this))).sub(
            results.prevDaiBalance
        );

        emit ObtainedInfo(
            msg.sender,
            results.obtainedDai,
            results.obtainedfDai
        );

        if (amount == user.amountfDai) {
            if (results.obtainedDai > user.amountDai) {
                results.feeableDai = results.obtainedDai.sub(user.amountDai);
            }
        } else {
            uint256 currentRatio =
                _getRatio(results.obtainedfDai, results.obtainedDai, 18);
            results.feeableDai = 0;

            if (currentRatio < user.underlyingRatio) {
                uint256 noOfOriginalTokensForCurrentAmount =
                    (amount.mul(10**18)).div(user.underlyingRatio);
                if (noOfOriginalTokensForCurrentAmount < results.obtainedDai) {
                    results.feeableDai = results.obtainedDai.sub(
                        noOfOriginalTokensForCurrentAmount
                    );
                }
            }
        }
        if (results.feeableDai > 0) {
            uint256 extraTokensFee = _calculateFee(results.feeableDai);
            emit ExtraTokens(
                msg.sender,
                results.feeableDai.sub(extraTokensFee)
            );
            user.earnedTokens = user.earnedTokens.add(
                results.feeableDai.sub(extraTokensFee)
            );
        }

        if (results.obtainedDai <= user.amountDai) {
            user.amountDai = user.amountDai.sub(results.obtainedDai);
        } else {
            user.amountDai = 0;
        }
        results.obtainedDai = results.obtainedDai.sub(results.feeableDai);

        results.auctionedDai = 0;
        if (results.feeableDai > 0) {
            results.auctionedDai = results.feeableDai.div(2);
        }
        results.feeableDai = results.feeableDai.sub(results.auctionedDai);

        results.totalDai = results.obtainedDai.add(results.feeableDai);

        address[] memory swapPath = new address[](2);
        swapPath[0] = dai;
        swapPath[1] = weth;

        if (results.auctionedDai > 0) {
            uint256[] memory daiFeeableSwapAmounts =
                sushiswapRouter.swapExactTokensForETH(
                    results.auctionedDai,
                    uint256(0),
                    swapPath,
                    address(this),
                    deadline
                );

            emit ExtraTokensExchanged(
                msg.sender,
                results.auctionedDai,
                daiFeeableSwapAmounts[daiFeeableSwapAmounts.length - 1]
            );

            results.auctionedEth = results.auctionedEth.add(
                daiFeeableSwapAmounts[daiFeeableSwapAmounts.length - 1]
            );
        }
        uint256 transferableRewards = results.rewards;
        if (transferableRewards > results.farmBalance) {
            transferableRewards = results.farmBalance;
        }
        if (transferableRewards > 0) {
            emit RewardsEarned(msg.sender, transferableRewards);
            user.earnedRewards = user.earnedRewards.add(transferableRewards);

            uint256 auctionedRewards = transferableRewards.div(2);
            uint256 userRewards = transferableRewards.sub(auctionedRewards);

            swapPath[0] = farmToken;

            IERC20(farmToken).safeIncreaseAllowance(
                address(sushiswapRouter),
                transferableRewards
            );

            uint256[] memory farmSwapAmounts =
                sushiswapRouter.swapExactTokensForETH(
                    auctionedRewards,
                    uint256(0),
                    swapPath,
                    address(this),
                    deadline
                );

            emit RewardsExchanged(
                msg.sender,
                "ETH",
                auctionedRewards,
                farmSwapAmounts[farmSwapAmounts.length - 1]
            );

            results.auctionedEth = results.auctionedEth.add(
                farmSwapAmounts[farmSwapAmounts.length - 1]
            );

            if (userRewards > 0) {
                farmSwapAmounts = sushiswapRouter.swapExactTokensForETH(
                    userRewards,
                    uint256(0),
                    swapPath,
                    address(this),
                    deadline
                );

                swapPath[0] = weth;
                swapPath[1] = dai;

                farmSwapAmounts = sushiswapRouter.swapExactETHForTokens{
                    value: farmSwapAmounts[farmSwapAmounts.length - 1]
                }(uint256(0), swapPath, address(this), deadline);

                emit RewardsExchanged(
                    msg.sender,
                    "DAI",
                    userRewards,
                    farmSwapAmounts[farmSwapAmounts.length - 1]
                );

                results.totalDai = results.totalDai.add(
                    farmSwapAmounts[farmSwapAmounts.length - 1]
                );
            }
        }

        totalDeposits = totalDeposits.sub(results.obtainedfDai);
        if (user.amountfDai == 0) //full exit
        {
            user.amountDai = 0;
        } else {
            if (user.amountDai > results.totalDai) {
                user.amountDai = user.amountDai.sub(results.totalDai);
            } else {
                user.amountDai = 0;
            }
        }

        if (results.totalDai < totalDai) {
            totalDai = totalDai.sub(results.totalDai);
        } else {
            totalDai = 0;
        }

        if (fee > 0) {
            uint256 feeDai = _calculateFee(results.totalDai);
            results.totalDai = results.totalDai.sub(feeDai);

            swapPath[0] = dai;
            swapPath[1] = weth;

            IERC20(dai).safeIncreaseAllowance(address(sushiswapRouter), feeDai);

            uint256[] memory feeSwapAmount =
                sushiswapRouter.swapExactTokensForETH(
                    feeDai,
                    uint256(0),
                    swapPath,
                    address(this),
                    deadline
                );

            feeAddress.transfer(feeSwapAmount[feeSwapAmount.length - 1]);
            user.userCollectedFees = user.userCollectedFees.add(
                feeSwapAmount[feeSwapAmount.length - 1]
            );
        }

        IERC20(dai).safeTransfer(msg.sender, results.totalDai);
        treasuryAddress.transfer(results.auctionedEth);
        user.userTreasuryEth = user.userTreasuryEth.add(results.auctionedEth);

        emit Withdraw(
            msg.sender,
            tx.origin,
            results.obtainedDai,
            results.obtainedfDai,
            results.auctionedEth
        );

        ethDust = ethDust.add(
            address(this).balance.sub(results.prevDustEthBalance)
        );

        if (user.amountfDai == 0 || user.amountDai == 0) {
            user.underlyingRatio = 0;
        } else {
            user.underlyingRatio = _getRatio(
                user.amountfDai,
                user.amountDai,
                18
            );
        }

        return results.totalDai;
    }

    function updateReward() public onlyOwner {
        harvestRewardPool.getReward();
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

    function getPendingRewards(address account, uint256 amount)
        public
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[account];

        if (amount == 0) {
            amount = user.amountfDai;
        }
        if (user.deposits.length == 0 || user.amountfDai == 0) {
            return 0;
        }

        uint256 rewards = 0;
        uint256 remaingAmount = amount;

        uint256 i = user.deposits.length - 1;
        while (remaingAmount > 0) {
            uint256 depositRewards =
                _getPendingRewards(user.deposits[i], remaingAmount);

            rewards = rewards.add(depositRewards);

            if (remaingAmount >= user.deposits[i].amountfDai) {
                remaingAmount = remaingAmount.sub(user.deposits[i].amountfDai);
            } else {
                remaingAmount = 0;
            }

            if (i == 0) {
                break;
            }
            i = i.sub(1);
        }

        return rewards;
    }

    function _getPendingRewards(
        UserDeposits memory user,
        uint256 remainingAmount
    ) private view returns (uint256) {
        if (user.amountfDai == 0) {
            return 0;
        }
        uint256 toCalculateForAmount = 0;
        if (user.amountfDai <= remainingAmount) {
            toCalculateForAmount = user.amountfDai;
        } else {
            toCalculateForAmount = remainingAmount;
        }

        uint256 rewardPerBlock = 0;
        uint256 balance = IERC20(farmToken).balanceOf(address(this));
        if (balance == 0) {
            return 0;
        }
        uint256 diff = block.timestamp.sub(firstDepositTimestamp);
        if (diff == 0) {
            rewardPerBlock = balance;
        } else {
            rewardPerBlock = balance.div(diff);
        }
        uint256 rewardPerBlockUser =
            rewardPerBlock.mul(block.timestamp.sub(user.timestamp));
        uint256 ratio = _getRatio(toCalculateForAmount, totalDeposits, 18);
        return (rewardPerBlockUser.mul(ratio)).div(10**18);
    }

    function _getRatio(
        uint256 numerator,
        uint256 denominator,
        uint256 precision
    ) private pure returns (uint256) {
        uint256 _numerator = numerator * 10**(precision + 1);
        uint256 _quotient = ((_numerator / denominator) + 5) / 10;
        return (_quotient);
    }

    receive() external payable {}
}