
pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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

pragma solidity >=0.6.0 <0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
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

    uint256[44] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) {
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

}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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
}pragma solidity >=0.6.2;

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
}pragma solidity >=0.6.2;


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

pragma solidity ^0.7.0;

library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}/*
    Copyright 2020 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Apache License, Version 2.0
*/

pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;


library PreciseUnitMath {
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    uint256 internal constant PRECISE_UNIT = 10**18;
    int256 internal constant PRECISE_UNIT_INT = 10**18;

    uint256 internal constant MAX_UINT_256 = type(uint256).max;
    int256 internal constant MAX_INT_256 = type(int256).max;
    int256 internal constant MIN_INT_256 = type(int256).min;

    function preciseUnit() internal pure returns (uint256) {
        return PRECISE_UNIT;
    }

    function preciseUnitInt() internal pure returns (int256) {
        return PRECISE_UNIT_INT;
    }

    function maxUint256() internal pure returns (uint256) {
        return MAX_UINT_256;
    }

    function maxInt256() internal pure returns (int256) {
        return MAX_INT_256;
    }

    function minInt256() internal pure returns (int256) {
        return MIN_INT_256;
    }

    function preciseMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a.mul(b).div(PRECISE_UNIT);
    }

    function preciseMul(int256 a, int256 b) internal pure returns (int256) {
        return a.mul(b).div(PRECISE_UNIT_INT);
    }

    function preciseMulCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        return a.mul(b).sub(1).div(PRECISE_UNIT).add(1);
    }

    function preciseDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a.mul(PRECISE_UNIT).div(b);
    }

    function preciseDiv(int256 a, int256 b) internal pure returns (int256) {
        return a.mul(PRECISE_UNIT_INT).div(b);
    }

    function preciseDivCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "Cant divide by 0");

        return a > 0 ? a.mul(PRECISE_UNIT).sub(1).div(b).add(1) : 0;
    }

    function divDown(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "Cant divide by 0");
        require(a != MIN_INT_256 || b != -1, "Invalid input");

        int256 result = a.div(b);
        if (a ^ b < 0 && a % b != 0) {
            result -= 1;
        }

        return result;
    }

    function conservativePreciseMul(int256 a, int256 b) internal pure returns (int256) {
        return divDown(a.mul(b), PRECISE_UNIT_INT);
    }

    function conservativePreciseDiv(int256 a, int256 b) internal pure returns (int256) {
        return divDown(a.mul(PRECISE_UNIT_INT), b);
    }

    function safePower(uint256 a, uint256 pow) internal pure returns (uint256) {
        require(a > 0, "Value must be positive");

        uint256 result = 1;
        for (uint256 i = 0; i < pow; i++) {
            uint256 previousResult = result;

            result = previousResult.mul(a);
        }

        return result;
    }

    function approximatelyEquals(
        uint256 a,
        uint256 b,
        uint256 range
    ) internal pure returns (bool) {
        return a <= b.add(range) && a >= b.sub(range);
    }
}// MIT
pragma solidity ^0.7.4;

interface IPositionController {
    enum StakingState {
        IDLE,
        STAKING,
        WITHDRAWING_REWARDS,
        UNSTAKING
    }

    struct FeeInfo {
        address feeRecipient; // Address to accrue fees to
        uint256 successFeePercentage; // Percent of rewards accruing to manager
    }

    function canStake() external view returns (bool);

    function canCallUnstake() external view returns (bool);

    function canUnstake() external view returns (bool);

    function stake(uint256 _amount) external;

    function setDependencies() external;

    function setSwapVia(address _swapVia) external;

    function setSwapRewardsVia(address _swapRewardsVia) external;

    function callUnstake() external returns (uint256);

    function unstake() external returns (uint256);

    function maxUnstake() external view returns (uint256);

    function withdrawRewards() external;

    function outstandingRewards() external view returns (uint256);

    function netWorth() external view returns (uint256);

    function apy() external view returns (uint256);

    function description() external view returns (string memory);

    function productList() external view returns (address[] memory _products);

    function unstakingInfo() external view returns (uint256 _amount, uint256 _unstakeAvailable);
}// MIT
pragma solidity ^0.7.4;

interface IBrightRiskToken {
    struct DepositorInfo {
        uint256 depositAmount;
        bool readyToStake;
        uint256 minting;
    }

    function getBase() external view returns (address);

    function getPriceFeed() external view returns (address);

    function countPositions() external view returns (uint256);

    function listPositions(uint256 offset, uint256 limit) external view returns (address[] memory);

    function deposit(uint256 _maxAmount) external;

    function depositInternal(uint256 _amount) external;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Internal {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

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
pragma solidity ^0.7.4;

interface IPriceFeed {
    function getUniswapRouter() external view returns (address);

    function howManyTokensAinB(
        address tokenA,
        address tokenB,
        address via,
        uint256 amount,
        bool AMM
    ) external view returns (uint256);
}// MIT
pragma solidity ^0.7.4;




abstract contract AbstractController is OwnableUpgradeable, IPositionController {
    using SafeERC20 for ERC20;
    using SafeMathUpgradeable for uint256;

    uint256 constant PRECISION = 10**25;
    uint256 constant PRECISION_5_DEC = 1 * 10**5;
    uint256 constant PERCENTAGE_100 = 100 * PRECISION;
    uint256 constant PRECISION_5_PERCENTAGE_100 = 100 * PRECISION_5_DEC;
    uint256 constant SECONDS_IN_THE_YEAR = 365 * 24 * 60 * 60;

    StakingState public currentState;
    string public override description;
    IBrightRiskToken public index;
    ERC20 public base;
    FeeInfo public feeInfo;
    address public swapVia;
    address public swapRewardsVia;

    IUniswapV2Router02 internal _uniswapRouter;
    IPriceFeed internal _priceFeed;

    modifier onlyIndex() {
        require(_msgSender() == address(index), "AbstractController: No access");
        _;
    }

    modifier ownerOrIndex() {
        require(
            _msgSender() == address(index) || _msgSender() == owner(),
            "AbstractController: No access"
        );
        _;
    }

    function __AbstractController_init(
        string calldata _description,
        address _indexAddress,
        address _swapVia,
        address _swapRewardsVia,
        FeeInfo memory _feeInfo
    ) internal initializer {
        description = _description;
        index = IBrightRiskToken(_indexAddress);
        swapVia = _swapVia;
        swapRewardsVia = _swapRewardsVia;
        feeInfo = _feeInfo;
        setDependencies();
    }

    function setDependencies() public override ownerOrIndex {
        _priceFeed = IPriceFeed(index.getPriceFeed());
        _uniswapRouter = IUniswapV2Router02(_priceFeed.getUniswapRouter());
        base = ERC20(index.getBase());
    }

    function setFeeInfo(FeeInfo memory _feeInfo) public onlyOwner {
        feeInfo = _feeInfo;
    }

    function setSwapVia(address _swapVia) public override onlyIndex {
        swapVia = _swapVia;
    }

    function setSwapRewardsVia(address _swapRewardsVia) public override onlyIndex {
        swapRewardsVia = _swapRewardsVia;
    }

    function canStake() public view virtual override returns (bool) {
        return currentState != StakingState.UNSTAKING;
    }

    function canCallUnstake() public view virtual override returns (bool) {
        return currentState != StakingState.UNSTAKING;
    }

    function canUnstake() public view virtual override returns (bool) {
        return currentState == StakingState.UNSTAKING;
    }

    function _calculateRewards() internal view returns (uint256, uint256) {
        uint256 _rewards = outstandingRewards();
        if (_rewards == 0) {
            return (0, 0);
        }
        return _applyFees(_rewards);
    }

    function _applyFees(uint256 _rewards)
        internal
        view
        returns (uint256 _rewardsNoFee, uint256 _feeAmount)
    {
        if (_rewards == 0) {
            return (0, 0);
        }
        uint256 _feeAmountScale = _rewards.mul(feeInfo.successFeePercentage);
        uint256 b = PreciseUnitMath.preciseUnit().sub(feeInfo.successFeePercentage);

        _feeAmount = _feeAmountScale.div(b);
        _rewardsNoFee = _rewards.sub(_feeAmount);
    }

    function outstandingRewards() public view virtual override returns (uint256);

    function setStakingState() internal {
        currentState = StakingState.STAKING;
    }

    function staking() internal view returns (bool) {
        return currentState == StakingState.STAKING;
    }

    function setUnstakingState() internal {
        currentState = StakingState.UNSTAKING;
    }

    function setIdleState() internal {
        currentState = StakingState.IDLE;
    }

    function setWithdrawRewardsState() internal {
        currentState = StakingState.WITHDRAWING_REWARDS;
    }

    function _checkApprovals(
        IERC20 _asset,
        address _router,
        uint256 _amount
    ) internal {
        if (_asset.allowance(address(this), _router) < _amount) {
            _asset.approve(_router, PreciseUnitMath.MAX_UINT_256);
        }
    }

    function _checkTetherApprovals(
        address _token,
        address _spender,
        uint256 _amount
    ) internal {
        string memory _symbol = IERC20Internal(_token).symbol();
        if (
            keccak256(bytes(_symbol)) == keccak256(bytes("USDT")) ||
            keccak256(bytes(_symbol)) == keccak256(bytes("TUSDT"))
        ) {
            ERC20(_token).safeApprove(_spender, 0);
            ERC20(_token).safeApprove(_spender, _amount);
        } else {
            ERC20(_token).safeApprove(address(_spender), _amount);
        }
    }

    function _swapTokenForToken(
        uint256 _amountIn,
        address _from,
        address _to,
        address _via
    ) internal returns (uint256) {
        if (_amountIn == 0) {
            return 0;
        }

        address[] memory pairs;

        if (_via == address(0)) {
            pairs = new address[](2);
            pairs[0] = _from;
            pairs[1] = _to;
        } else {
            pairs = new address[](3);
            pairs[0] = _from;
            pairs[1] = _via;
            pairs[2] = _to;
        }

        uint256 _expectedOut = _priceFeed.howManyTokensAinB(_to, _from, _via, _amountIn, false);
        uint256 _amountOutMin = _expectedOut.mul(99).div(100);

        return
            _uniswapRouter.swapExactTokensForTokens(
                _amountIn,
                _amountOutMin,
                pairs,
                address(this),
                block.timestamp.add(600)
            )[pairs.length.sub(1)];
    }
}/*
    Copyright (C) 2020 InsurAce.io

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
*/


pragma solidity ^0.7.3;

interface IStakersPoolV2 {
    function addStkAmount(address _token, uint256 _amount) external payable;

    function rewardPerBlock() external view returns (uint256 _rewardPB);

    function totalPoolWeight() external view returns (uint256 _totalPoolWeight);

    function stakedAmountPT(address _token) external view returns (uint256);

    function poolWeightPT(address _token) external view returns (uint256 _poolWeight);

    function stkRewardsPerAPerLPT(address _lpToken, address _account)
        external
        view
        returns (uint256 _stkRewards);

    function harvestedRewardsPerAPerLPT(address _lpToken, address _account)
        external
        view
        returns (uint256 _harvestedRewards);

    function withdrawTokens(
        address payable _to,
        uint256 _amount,
        address _token,
        address _feePool,
        uint256 _fee
    ) external;

    function reCalcPoolPT(address _lpToken) external;

    function settlePendingRewards(address _account, address _lpToken) external;

    function harvestRewards(
        address _account,
        address _lpToken,
        address _to
    ) external returns (uint256);

    function getPoolRewardPerLPToken(address _lpToken) external view returns (uint256);

    function getStakedAmountPT(address _token) external view returns (uint256);

    function showPendingRewards(address _account, address _lpToken)
        external
        view
        returns (uint256);

    function showHarvestRewards(address _account, address _lpToken)
        external
        view
        returns (uint256);

    function claimPayout(
        address _fromToken,
        address _paymentToken,
        uint256 _settleAmtPT,
        address _claimToSettlementPool,
        uint256 _claimId,
        uint256 _fromRate,
        uint256 _toRate
    ) external;
}/*
    Copyright (C) 2020 InsurAce.io

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
*/


pragma solidity ^0.7.3;

interface IStakingV2Controller {
    function stakeTokens(uint256 _amount, address _token) external payable;

    function tokenToLPTokenMap(address _token) external view returns (address);

    function proposeUnstake(uint256 _amount, address _token) external;

    function withdrawTokens(uint256 _amount, address _token) external;

    function showRewardsFromPools(address[] memory _tokenList) external view returns (uint256);

    function minStakeAmtPT(address _token) external view returns (uint256);

    function minUnstakeAmtPT(address _token) external view returns (uint256);

    function maxUnstakeAmtPT(address _token) external view returns (uint256);

    function totalStakedCapPT(address _token) external view returns (uint256);

    function withdrawFeePT(address _token) external view returns (uint256);

    function G_WITHDRAW_FEE_BASE() external view returns (uint256);

    function unstakeLockBlkPT(address _token) external view returns (uint256);

    function perAccountCapPT(address _token) external view returns (uint256);

    function stakersPoolV2() external view returns (address);
}/*
    Copyright (C) 2020 InsurAce.io

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
*/


pragma solidity ^0.7.3;

interface ILPToken {
    function proposeToBurn(
        address _account,
        uint256 _amount,
        uint256 _blockWeight
    ) external;

    function mint(
        address _account,
        uint256 _amount,
        uint256 _poolRewardPerLPToken
    ) external;

    function rewardDebtOf(address _account) external view returns (uint256);

    function burnWeightPH(address _account) external view returns (uint256);

    function pendingBurnAmtPH(address _account) external view returns (uint256);

    function burnableAmtPH(address _account) external view returns (uint256);

    function burnableAmtOf(address _account) external view returns (uint256);

    function burn(
        address _account,
        uint256 _amount,
        uint256 _poolRewardPerLPToken
    ) external;
}/*
    Copyright (C) 2020 InsurAce.io

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/
*/


pragma solidity ^0.7.3;

interface IRewardController {
    function insur() external returns (address);

    function stakingController() external returns (address);

    function vestingDuration() external view returns (uint256);

    function vestingVestingAmountPerAccount(address _account) external view returns (uint256);

    function vestingStartBlockPerAccount(address _account) external view returns (uint256);

    function vestingEndBlockPerAccount(address _account) external view returns (uint256);

    function vestingWithdrawableAmountPerAccount(address _account) external view returns (uint256);

    function vestingWithdrawedAmountPerAccount(address _account) external view returns (uint256);

    function unlockReward(
        address[] memory _tokenList,
        bool _bBuyCoverUnlockedAmt,
        bool _bClaimUnlockedAmt,
        bool _bReferralUnlockedAmt
    ) external;

    function getRewardInfo() external view returns (uint256, uint256);

    function withdrawReward(uint256 _amount) external;
}// MIT
pragma solidity ^0.7.4;



contract InsuracePositionController is AbstractController {
    using Math for uint256;
    using SafeERC20 for ERC20;
    using SafeMathUpgradeable for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    IStakersPoolV2 private _stakersPool;
    IStakingV2Controller private _stakingController;
    IRewardController private _rewardController;
    address constant ETHER = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public insurToken;
    address public stakingAsset;
    address public lpToken;

    function __InsuracePositionController_init(
        string calldata _description,
        address _indexAddress,
        address _rewardControllerAddress,
        address _stkingAssetsAddress,
        address _swapVia,
        address _swapRewardsVia,
        FeeInfo memory _feeInfo
    ) external initializer {
        __Ownable_init();
        __AbstractController_init(
            _description,
            _indexAddress,
            _swapVia,
            _swapRewardsVia,
            _feeInfo
        );

        _rewardController = IRewardController(_rewardControllerAddress);
        _stakingController = IStakingV2Controller(_rewardController.stakingController());
        _stakersPool = IStakersPoolV2(_stakingController.stakersPoolV2());

        insurToken = _rewardController.insur();
        stakingAsset = _stkingAssetsAddress;
        lpToken = _stakingController.tokenToLPTokenMap(stakingAsset);

        base.safeApprove(address(_indexAddress), PreciseUnitMath.MAX_UINT_256);
        _checkTetherApprovals(
            _stkingAssetsAddress,
            address(_stakingController),
            PreciseUnitMath.MAX_UINT_256
        );
        ERC20(lpToken).safeApprove(address(address(_stakersPool)), PreciseUnitMath.MAX_UINT_256);
    }

    function canCallUnstake() public view override returns (bool) {
        uint256 _collateral = positionSupply();
        return
            _stakingController.minUnstakeAmtPT(stakingAsset) <= _collateral &&
            _stakingController.maxUnstakeAmtPT(stakingAsset) >= _collateral &&
            super.canCallUnstake();
    }

    function stake(uint256 _amount) external override onlyIndex {
        require(canStake(), "InsuracePositionController: IPC0");
        require(
            _amount >= _stakingController.minStakeAmtPT(stakingAsset),
            "InsuracePositionController: IPC1"
        );
        base.safeTransferFrom(_msgSender(), address(this), _amount);

        if (address(base) != stakingAsset) {
            _checkApprovals(IERC20(base), address(_uniswapRouter), _amount);
            _swapTokenForToken(_amount, address(base), stakingAsset, swapVia);
        }

        uint256 investmentAmount = ERC20(stakingAsset).balanceOf(address(this));
        require(investmentAmount != 0, "InsuracePositionController: IPC3");
        _stakingController.stakeTokens(investmentAmount, stakingAsset);
        uint256 _lptokenBalance = ERC20(lpToken).balanceOf(address(this));
        require(_lptokenBalance >= 0, "InsuracePositionController: IPC4");

        setStakingState();
    }

    function callUnstake() external override onlyIndex returns (uint256) {
        require(canCallUnstake(), "InsuracePositionController: IPC5");
        uint256 _collateral = positionSupply();

        _stakingController.proposeUnstake(_collateral, stakingAsset);
        setUnstakingState();
        return _collateral;
    }

    function unstake() external override onlyIndex returns (uint256) {
        require(canUnstake(), "InsuracePositionController: IPC7");
        _stakingController.withdrawTokens(positionSupply(), stakingAsset);

        uint256 _unstakedAmount = ERC20(stakingAsset).balanceOf(address(this));
        require(_unstakedAmount > 0, "InsuracePositionController: IPC8");

        _checkTetherApprovals(address(stakingAsset), address(_uniswapRouter), _unstakedAmount);
        uint256 _baseTokenAmount;
        if (address(base) != stakingAsset) {
            _baseTokenAmount = _swapTokenForToken(
                _unstakedAmount,
                stakingAsset,
                address(base),
                swapVia
            );
        } else {
            _baseTokenAmount = _unstakedAmount;
        }

        index.depositInternal(_baseTokenAmount);

        setIdleState();

        return _baseTokenAmount;
    }

    function unlockRewards() external {
        address[] memory stakingAssetAddresses = new address[](1);
        stakingAssetAddresses[0] = stakingAsset;
        _rewardController.unlockReward(
            stakingAssetAddresses, // _tokenList
            false, // _bBuyCoverUnlockedAmt,
            false, // _bClaimUnlockedAmt,
            false // _bReferralUnlockedAmt
        );
    }

    function withdrawRewards() external override {
        (uint256 _withdrawableNow, ) = rewardsInVesting();

        (uint256 _rewards, uint256 _fee) = _applyFees(_withdrawableNow);

        _rewardController.withdrawReward(_withdrawableNow);

        require(
            ERC20(insurToken).balanceOf(address(this)) == _withdrawableNow,
            "InsuracePositionController IPC10"
        );

        ERC20(insurToken).transfer(feeInfo.feeRecipient, _fee);

        _checkApprovals(IERC20(insurToken), address(_uniswapRouter), _rewards);
        uint256 _baseTokenAmount = _swapTokenForToken(
            _rewards,
            address(insurToken),
            address(base),
            swapRewardsVia
        );

        require(_baseTokenAmount != 0, "InsuracePositionController: IPC11");
        index.depositInternal(_baseTokenAmount);
    }

    function _getStakingToLPRatio(uint256 currentLiquidity) internal view returns (uint256) {
        uint256 _currentTotalSupply = ERC20Upgradeable(lpToken).totalSupply();

        if (_currentTotalSupply == 0) {
            return PERCENTAGE_100;
        }

        return currentLiquidity.mul(PERCENTAGE_100).div(_currentTotalSupply);
    }

    function convertLPToStaking(uint256 _amount) public view returns (uint256) {
        uint256 _currentLiquidity = IStakersPoolV2(_stakersPool).getStakedAmountPT(stakingAsset);

        return _amount.mul(_getStakingToLPRatio(_currentLiquidity)).div(PERCENTAGE_100);
    }

    function convertStakingToLP(uint256 _amount) public view returns (uint256) {
        uint256 _currentLiquidity = IStakersPoolV2(_stakersPool).getStakedAmountPT(stakingAsset);

        return _amount.mul(PERCENTAGE_100).div(_getStakingToLPRatio(_currentLiquidity));
    }

    function outstandingRewards() public view override returns (uint256) {
        (uint256 _withdrawableNow, uint256 _lockedInVesting) = rewardsInVesting();
        return rewardsInEarnings().add(_lockedInVesting).add(_withdrawableNow);
    }

    function rewardsInEarnings() public view returns (uint256 _rewards) {
        _rewards = _stakersPool.showPendingRewards(address(this), lpToken);
    }

    function rewardsInVesting()
        public
        view
        returns (uint256 _withdrawableNow, uint256 _lockedInVesting)
    {
        (_withdrawableNow, _lockedInVesting) = _rewardController.getRewardInfo();
    }

    function positionSupply() public view returns (uint256) {
        uint256 _lptokenBalance = ERC20(lpToken).balanceOf(address(this));
        if (_lptokenBalance == 0) {
            return 0;
        }
        return convertLPToStaking(_lptokenBalance);
    }

    function netWorth() external view override returns (uint256) {
        (uint256 _rewards, ) = _calculateRewards();

        uint256 _rewardsBase;
        if (_rewards != 0) {
            _rewardsBase = _priceFeed.howManyTokensAinB(
                address(base),
                insurToken,
                swapRewardsVia,
                _rewards,
                true
            );
        }

        uint256 _stakedBase;
        if (address(base) != stakingAsset) {
            _stakedBase = _priceFeed.howManyTokensAinB(
                address(base),
                stakingAsset,
                swapVia,
                positionSupply(),
                true
            );
        } else {
            _stakedBase = positionSupply();
        }

        return _stakedBase.add(_rewardsBase);
    }

    function productList() external view override returns (address[] memory _products) {
        _products = new address[](1);
        _products[0] = stakingAsset;
    }

    function apy() external view override returns (uint256 _apy) {
        uint256 _blocksYear = SECONDS_IN_THE_YEAR.div(15);
        uint256 _rewardsPerYear = _rewardsPerBlockPerPool().mul(_blocksYear);

        uint256 _poolTVLInStakingAsset = _stakersPool.getStakedAmountPT(stakingAsset);
        uint256 _stakingDecimals = ERC20(stakingAsset).decimals();
        uint256 _insurInOneStaking = _priceFeed.howManyTokensAinB(
            insurToken,
            stakingAsset,
            address(0),
            1 * 10**_stakingDecimals,
            true
        );
        uint256 _poolTVLInRewardsAsset = _poolTVLInStakingAsset.mul(_insurInOneStaking).div(
            10**_stakingDecimals
        );

        _apy = _rewardsPerYear.mul(PRECISION_5_PERCENTAGE_100).div(_poolTVLInRewardsAsset);
    }

    function _rewardsPerBlockPerPool() internal view returns (uint256 _rewards) {
        uint256 _rewardsPB = _stakersPool.rewardPerBlock();
        uint256 _poolWeight = _stakersPool.poolWeightPT(lpToken);
        uint256 _totalPoolWeight = _stakersPool.totalPoolWeight();

        return _poolWeight.mul(_rewardsPB).div(_totalPoolWeight);
    }

    function maxUnstake() external view override returns (uint256 _maxUnstake) {
        return ERC20(lpToken).balanceOf(address(this));
    }

    function unstakingInfo()
        public
        view
        override
        returns (uint256 _amount, uint256 _unstakeAvailable)
    {
        _unstakeAvailable = ILPToken(lpToken).burnWeightPH(address(this));

        uint256 _amountLocked = ILPToken(lpToken).pendingBurnAmtPH(address(this));
        uint256 _amountAvailable = ILPToken(lpToken).burnableAmtOf(address(this));
        _amount = _amountLocked.max(_amountAvailable);
    }

    function rewardsVestingInfo()
        public
        view
        returns (
            uint256 vestingEndBlockPerAccount,
            uint256 vestingStartBlockPerAccount,
            uint256 vestingWithdrawableAmountPerAccount,
            uint256 vestingWithdrawedAmountPerAccount,
            uint256 vestingDuration,
            uint256 vestingAmountPerAccount
        )
    {
        vestingStartBlockPerAccount = _rewardController.vestingStartBlockPerAccount(address(this));
        vestingEndBlockPerAccount = _rewardController.vestingEndBlockPerAccount(address(this));
        vestingWithdrawableAmountPerAccount = _rewardController
            .vestingWithdrawableAmountPerAccount(address(this));
        vestingWithdrawedAmountPerAccount = _rewardController.vestingWithdrawedAmountPerAccount(
            address(this)
        );
        vestingDuration = _rewardController.vestingDuration();
        vestingAmountPerAccount = _rewardController.vestingVestingAmountPerAccount(address(this));
    }
}