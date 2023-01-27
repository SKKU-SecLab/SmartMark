
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
}// MIT

pragma solidity ^0.6.2;

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
}// MIT

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
}// Apache-2.0-with-puul-exception
pragma solidity >=0.6.12;

contract PuulAccessControl is AccessControl {

  using SafeERC20 for IERC20;

  bytes32 constant ROLE_ADMIN = keccak256("ROLE_ADMIN");
  bytes32 constant ROLE_MEMBER = keccak256("ROLE_MEMBER");
  bytes32 constant ROLE_MINTER = keccak256("ROLE_MINTER");
  bytes32 constant ROLE_EXTRACT = keccak256("ROLE_EXTRACT");
  bytes32 constant ROLE_HARVESTER = keccak256("ROLE_HARVESTER");
  
  constructor () public {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  modifier onlyAdmin() {

    require(hasRole(ROLE_ADMIN, msg.sender), "!admin");
    _;
  }

  modifier onlyMinter() {

    require(hasRole(ROLE_MINTER, msg.sender), "!minter");
    _;
  }

  modifier onlyExtract() {

    require(hasRole(ROLE_EXTRACT, msg.sender), "!extract");
    _;
  }

  modifier onlyHarvester() {

    require(hasRole(ROLE_HARVESTER, msg.sender), "!harvester");
    _;
  }

  modifier onlyDefaultAdmin() {

    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "!default_admin");
    _;
  }

  function _setup(bytes32 role, address user) internal {

    if (msg.sender != user) {
      _setupRole(role, user);
      revokeRole(role, msg.sender);
    }
  }

  function _setupDefaultAdmin(address admin) internal {

    _setup(DEFAULT_ADMIN_ROLE, admin);
  }

  function _setupAdmin(address admin) internal {

    _setup(ROLE_ADMIN, admin);
  }

  function setupDefaultAdmin(address admin) external onlyDefaultAdmin {

    _setupDefaultAdmin(admin);
  }

  function setupAdmin(address admin) external onlyAdmin {

    _setupAdmin(admin);
  }

  function setupMinter(address admin) external onlyMinter {

    _setup(ROLE_MINTER, admin);
  }

  function setupExtract(address admin) external onlyExtract {

    _setup(ROLE_EXTRACT, admin);
  }

  function setupHarvester(address admin) external onlyHarvester {

    _setup(ROLE_HARVESTER, admin);
  }

  function _tokenInUse(address /*token*/) virtual internal view returns(bool) {

    return false;
  }

  function extractStuckTokens(address token, address to) onlyExtract external {

    require(token != address(0) && to != address(0));
    uint256 balance = IERC20(token).balanceOf(address(this));
    if (balance > 0)
      IERC20(token).safeTransfer(to, balance);
  }

}// Apache-2.0-with-puul-exception
pragma solidity >=0.6.12;


contract Whitelist is PuulAccessControl {

  using Address for address;

  bool _startWhitelist;
  mapping (address => bool) _whitelist;
  mapping (address => bool) _blacklist;

  constructor () public {}

  modifier onlyWhitelist() {

    require(!_blacklist[msg.sender] && (!_startWhitelist || _whitelist[msg.sender]), "!whitelist");
    _;
  }

  function stopWhitelist() onlyHarvester external {

    _startWhitelist = false;
  }

  function startWhitelist() onlyHarvester external {

    _startWhitelist = true;
  }

  function addWhitelist(address c) onlyHarvester external {

    require(c != address(0), '!contract');
    _whitelist[c] = true;
  }
  
  function removeWhitelist(address c) onlyHarvester external {

    require(c != address(0), '!contract');
    _whitelist[c] = false;
  }
  
  function addBlacklist(address c) onlyHarvester external {

    require(c != address(0), '!contract');
    _blacklist[c] = true;
  }
  
  function removeBlacklist(address c) onlyHarvester external {

    require(c != address(0), '!contract');
    _blacklist[c] = false;
  }
  
}// MIT

pragma solidity ^0.6.0;

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
}// Apache-2.0
pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    function totalSupply() external view returns(uint);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function balanceOf(address owner) external view returns (uint);

    function transfer(address to, uint value) external returns (bool);

    function approve(address spender, uint value) external returns (bool);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}// Apache-2.0
pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB) external view returns (address pair);

}// Apache-2.0
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}// Apache-2.0
pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}// MIT
pragma solidity >=0.6.12;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) _balances;

    mapping (address => mapping (address => uint256)) _allowances;

    uint256 _totalSupply;

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

}// Apache-2.0
pragma solidity >=0.6.12;

library Path {
  function path(address from, address to) internal view returns(string memory) {
    string memory symbol = ERC20(from).symbol();
    string memory symbolTo = ERC20(to).symbol();
    return string(abi.encodePacked(symbol, '/', symbolTo));
  }
}

library Console {
  bool constant PROD = true;

  function concat(string memory a, string memory b) internal pure returns(string memory)
  {
    return string(abi.encodePacked(a, b));
  }

  function concat(string memory a, string memory b, string memory c) internal pure returns(string memory)
  {
    return string(abi.encodePacked(a, b, c));
  }

  event LogBalance(string, uint);
  function logBalance(address token, address to) internal {
    if (PROD) return;
    emit LogBalance(ERC20(token).symbol(), ERC20(token).balanceOf(to));
  }

  function logBalance(string memory s, address token, address to) internal {
    if (PROD) return;
    emit LogBalance(string(abi.encodePacked(s, '/', ERC20(token).symbol())), ERC20(token).balanceOf(to));
  }

  event LogUint(string, uint);
  function log(string memory s, uint x) internal {
    if (PROD) return;
    emit LogUint(s, x);
  }

  function log(string memory s, string memory t, uint x) internal {
    if (PROD) return;
    emit LogUint(concat(s, t), x);
  }
    
  function log(string memory s, string memory t, string memory u, uint x) internal {
    if (PROD) return;
    emit LogUint(concat(s, t, u), x);
  }
    
  event LogInt(string, int);
  function log(string memory s, int x) internal {
    if (PROD) return;
    emit LogInt(s, x);
  }
  
  event LogBytes(string, bytes);
  function log(string memory s, bytes memory x) internal {
    if (PROD) return;
    emit LogBytes(s, x);
  }
  
  event LogBytes32(string, bytes32);
  function log(string memory s, bytes32 x) internal {
    if (PROD) return;
    emit LogBytes32(s, x);
  }

  event LogAddress(string, address);
  function log(string memory s, address x) internal {
    if (PROD) return;
    emit LogAddress(s, x);
  }

  event LogBool(string, bool);
  function log(string memory s, bool x) internal {
    if (PROD) return;
    emit LogBool(s, x);
  }
}// Apache-2.0-with-puul-exception
pragma solidity >=0.6.12;


contract UniswapHelper is Whitelist, ReentrancyGuard {
  using Address for address;
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  mapping (bytes32 => uint) _hasPath;
  mapping (bytes32 => mapping (uint => address)) _paths;

  IUniswapV2Factory public constant UNI_FACTORY = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
  IUniswapV2Router02 public constant UNI_ROUTER = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

  uint256 public constant MIN_AMOUNT = 5;
  uint256 public constant MIN_SWAP_AMOUNT = 1000; // should be ok for most coins
  uint256 public constant MIN_SLIPPAGE = 1; // .01%
  uint256 public constant MAX_SLIPPAGE = 1000; // 10%
  uint256 public constant SLIPPAGE_BASE = 10000;

   constructor () public {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(ROLE_HARVESTER, msg.sender);
  }

  function setupRoles(address admin, address harvester) onlyDefaultAdmin external {
    _setup(ROLE_HARVESTER, harvester);
    _setupDefaultAdmin(admin);
  }

  function addPath(string memory name, address[] memory path) onlyHarvester external {
    bytes32 key = keccak256(abi.encodePacked(name));
    require(_hasPath[key] == 0, 'path exists');
    require(path.length > 0, 'invalid path');

    _hasPath[key] = path.length;
    mapping (uint => address) storage spath = _paths[key];
    for (uint i = 0; i < path.length; i++) {
      spath[i] = path[i];
    }
  }

  function removePath(string memory name) onlyHarvester external {
    bytes32 key = keccak256(abi.encodePacked(name));
    uint length = _hasPath[key];
    require(length > 0, 'path not found exists');

    _hasPath[key] = 0;
    mapping (uint => address) storage spath = _paths[key];
    for (uint i = 0; i < length; i++) {
      spath[i] = address(0);
    }
  }

  function pathExists(address from, address to) external view returns(bool) {
    string memory name = Path.path(from, to);
    bytes32 key = keccak256(abi.encodePacked(name));
    uint256 length = _hasPath[key];
    if (length == 0) return false;
    address first = _paths[key][0];
    if (from != first) return false;
    address last = _paths[key][length - 1];
    if (to != last) return false;
    return true;
  }

  function _removeLiquidityDeflationary(address tokenA, address tokenB, uint256 amount, uint256 minA, uint256 minB) internal returns (uint256 amountA, uint256 amountB) {
    uint256 befA = IERC20(tokenA).balanceOf(address(this));
    uint256 befB = IERC20(tokenB).balanceOf(address(this));
    UNI_ROUTER.removeLiquidity(tokenA, tokenB, amount, minA, minB, address(this), now.add(1800));
    uint256 aftA = IERC20(tokenA).balanceOf(address(this));
    uint256 aftB = IERC20(tokenB).balanceOf(address(this));
    amountA = aftA.sub(befA, 'deflat');
    amountB = aftB.sub(befB, 'deflat');
  }

  function withdrawToToken(address token, uint256 amount, address dest, IUniswapV2Pair pair, uint256 minA, uint256 minB, uint256 slippageA, uint256 slippageB) onlyWhitelist nonReentrant external {
    address token0 = pair.token0();
    address token1 = pair.token1();
    IERC20(address(pair)).safeApprove(address(UNI_ROUTER), 0);
    IERC20(address(pair)).safeApprove(address(UNI_ROUTER), amount * 2);
    (uint amount0, uint amount1) = _removeLiquidityDeflationary(token0, token1, amount, minA, minB);
    if (token == token0) {
      IERC20(token0).safeTransfer(dest, amount0);
    } else {
      _swapWithSlippage(token0, token, amount0, slippageA, dest);
    }
    if (token == token1) {
      IERC20(token1).safeTransfer(dest, amount1);
    } else {
      _swapWithSlippage(token1, token, amount1, slippageB, dest);
    }
  }

  function _swapWithSlippage(address from, address to, uint256 amount, uint256 slippage, address dest) internal returns(uint256 swapOut) {
    string memory path = Path.path(from, to);
    uint256 out = _estimateOut(from, to, amount);
    uint256 min = amountWithSlippage(out, slippage);
    swapOut = _swap(path, amount, min, dest);
  }

  function swap(string memory name, uint256 amount, uint256 minOut, address dest) onlyWhitelist nonReentrant external returns (uint256 swapOut) {
    swapOut = _swap(name, amount, minOut, dest);
  }

  function _swap(string memory name, uint256 amount, uint256 minOut, address dest) internal returns (uint256 swapOut) {
    bytes32 key = keccak256(abi.encodePacked(name));
    uint256 length = _hasPath[key];
    require(length > 0, Console.concat('path not found ', name));

    address[] memory swapPath = new address[](length);
    for (uint i = 0; i < length; i++) {
      swapPath[i] = _paths[key][i];
    }

    IERC20 token = IERC20(swapPath[0]);
    IERC20 to = IERC20(swapPath[swapPath.length - 1]);
    token.safeApprove(address(UNI_ROUTER), 0);
    token.safeApprove(address(UNI_ROUTER), amount * 2);
    uint256 bef = to.balanceOf(dest);
    UNI_ROUTER.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, minOut, swapPath, dest, now.add(1800));
    uint256 aft = to.balanceOf(dest);
    swapOut = aft.sub(bef, '!swapOut');
  }

  function amountWithSlippage(uint256 amount, uint256 slippage) internal pure returns (uint256 out) {
    out = slippage == 0 ? 0 : amount.sub(amount.mul(slippage).div(SLIPPAGE_BASE));
  }

  function getAmountOut(IUniswapV2Pair pair, address token, uint256 amount) external view returns (uint256 optimal) {
    optimal = _getAmountOut(pair, token, amount);
  }

  function _getAmountOut(IUniswapV2Pair pair, address token, uint256 amount) internal view returns (uint256 optimal) {
    uint256 reserve0;
    uint256 reserve1;
    if (pair.token0() == token) {
      (reserve0, reserve1, ) = pair.getReserves();
    } else {
      (reserve1, reserve0, ) = pair.getReserves();
    }
    optimal = UNI_ROUTER.getAmountOut(amount, reserve0, reserve1);
  }

  function quote(IUniswapV2Pair pair, address token, uint256 amount) external view returns (uint256 optimal) {
    optimal = _quote(pair, token, amount);
  }

  function _quote(IUniswapV2Pair pair, address token, uint256 amount) internal view returns (uint256 optimal) {
    uint256 reserve0;
    uint256 reserve1;
    if (pair.token0() == token) {
      (reserve0, reserve1, ) = pair.getReserves();
    } else {
      (reserve1, reserve0, ) = pair.getReserves();
    }
    optimal = UNI_ROUTER.quote(amount, reserve0, reserve1);
  }

  function _estimateOut(address from, address to, uint256 amount) internal view returns (uint256 swapOut) {
    string memory path = Path.path(from, to);
    bytes32 key = keccak256(abi.encodePacked(path));
    uint256 length = _hasPath[key];
    require(length > 0, Console.concat('path not found ', path));

    swapOut = amount;
    for (uint i = 0; i < length - 1; i++) {
      address first = _paths[key][i];
      IUniswapV2Pair pair = IUniswapV2Pair(UNI_FACTORY.getPair(first, _paths[key][i + 1]));
      require(address(pair) != address(0), 'swap pair not found');
      swapOut = _getAmountOut(pair, first, swapOut);
    }
  }

  function estimateOut(address from, address to, uint256 amount) external view returns (uint256 swapOut) {
    require(amount > 0, '!amount');
    swapOut = _estimateOut(from, to, amount);
  }

  function estimateOuts(address[] memory pairs, uint256[] memory amounts) external view returns (uint256[] memory swapOut) {
    require(pairs.length.div(2) == amounts.length, 'pairs!=amounts');
    swapOut = new uint256[](amounts.length);
    for (uint256 i = 0; i < pairs.length; i+=2) {
      uint256 ai = i.div(2);
      swapOut[ai] = _estimateOut(pairs[i], pairs[i+1], amounts[ai]);
    }
  }

}