




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}





pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}





pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}





pragma solidity ^0.8.0;



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}





pragma solidity ^0.8.1;

library Address {
    function isContract(address account) internal view returns (bool) {

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}





pragma solidity ^0.8.0;

interface IAccessControl {
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}





pragma solidity ^0.8.0;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}





pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}





pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}





pragma solidity ^0.8.0;




abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}





pragma solidity ^0.8.0;


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}



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
}



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
}





pragma solidity ^0.8.0;






contract KOMPETE is ERC20, AccessControl {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    uint8 private constant DECIMALS = 10;

    uint256 public liquidityFee = 200; // 2%
    uint256 public marketingFee = 1000; // 10%
    uint16 public constant MAX_FEE = 2000; // 20%
    uint256 public constant MAX_TOKEN_PER_WALLET = 10000000 * 10**DECIMALS; // Max holding limit, 1.00% of supply

    bytes32 public constant EXCLUDED_FROM_FEE_ROLE = keccak256("EXCLUDED_FROM_FEE_ROLE");
    bytes32 public constant EXCLUDED_FROM_ANTIWHALE_ROLE = keccak256("EXCLUDED_FROM_ANTIWHALE_ROLE");
    bytes32 public constant DENIED_ROLE = keccak256("DENIED_ROLE");

    address public marketingAddress = 0xFEF90843630d43869877769DE31fC9Aa8D6252F8;
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router02 public swapRouter;
    address public swapPair;
    address public liquidityOwner;

    bool public processFeesEnabled = true;
    bool private _processingFees;

    uint256 public numTokensToSwap = 4000000 * 10**DECIMALS;

    mapping(address => bool) private _lpPools;

    event SwapRouterUpdated(address indexed router, address indexed pair);
    event AddLiquidity(uint256 amountToken, uint256 amountETH);
    event SendToMarketing(address indexed recipient, uint256 amountToken);

    modifier notDenied(address account) {
        require(!hasRole(DENIED_ROLE, account), "Address denied");
        _;
    }

    modifier lockTheSwap() {
        _processingFees = true;
        _;
        _processingFees = false;
    }

    modifier antiWhale(
        address sender,
        address recipient,
        uint256 amount
    ) {
        if (!hasRole(EXCLUDED_FROM_ANTIWHALE_ROLE, recipient)) {
            require(balanceOf(recipient).add(amount) <= MAX_TOKEN_PER_WALLET, "Wallet exceeds max");
        }
        _;
    }

    constructor() ERC20("KOMPETE Token", "KOMPETE") {
        liquidityOwner = _msgSender();

        swapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        swapPair = IUniswapV2Factory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());

        _lpPools[address(swapPair)] = true;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(EXCLUDED_FROM_FEE_ROLE, _msgSender());
        _setupRole(EXCLUDED_FROM_FEE_ROLE, address(this));
        _setupRole(EXCLUDED_FROM_FEE_ROLE, marketingAddress);
        _setupRole(EXCLUDED_FROM_FEE_ROLE, 0xFd7d7a2175706E5555aAB0aAAF2251C6BC691ffC);
        _setupRole(EXCLUDED_FROM_FEE_ROLE, 0x30Ea798cB8Aa2392F3016F4962e69365E50CD001);
        _setupRole(EXCLUDED_FROM_FEE_ROLE, 0x5D2c31eEAc483000Dd6120233AfAAA0535e9C6Ed);
        _setupRole(EXCLUDED_FROM_FEE_ROLE, 0x5623225F296BE00Ec9dB43f3DeD96804f24b062d);
        _setupRole(EXCLUDED_FROM_FEE_ROLE, 0x99B3208625e252eA0fBBe9B63e6004B06489D094);
        _setupRole(EXCLUDED_FROM_FEE_ROLE, 0x596e5556cF23b30e6c2C4c60dE216F66551c0220);
        _setupRole(EXCLUDED_FROM_FEE_ROLE, 0x9406609b3057053573f8d5418C1cbfaAc5161f21);
        _setupRole(EXCLUDED_FROM_FEE_ROLE, 0x71FC956eee0C97B095B70f6B1B263147a6d6799A);

        _setupRole(EXCLUDED_FROM_ANTIWHALE_ROLE, _msgSender());
        _setupRole(EXCLUDED_FROM_ANTIWHALE_ROLE, address(this));
        _setupRole(EXCLUDED_FROM_ANTIWHALE_ROLE, swapPair);
        _setupRole(EXCLUDED_FROM_ANTIWHALE_ROLE, marketingAddress);
        _setupRole(EXCLUDED_FROM_ANTIWHALE_ROLE, BURN_ADDRESS);
        _setupRole(EXCLUDED_FROM_ANTIWHALE_ROLE, 0xFd7d7a2175706E5555aAB0aAAF2251C6BC691ffC);
        _setupRole(EXCLUDED_FROM_ANTIWHALE_ROLE, 0x30Ea798cB8Aa2392F3016F4962e69365E50CD001);
        _setupRole(EXCLUDED_FROM_ANTIWHALE_ROLE, 0x5D2c31eEAc483000Dd6120233AfAAA0535e9C6Ed);
        _setupRole(EXCLUDED_FROM_ANTIWHALE_ROLE, 0x5623225F296BE00Ec9dB43f3DeD96804f24b062d);
        _setupRole(EXCLUDED_FROM_ANTIWHALE_ROLE, 0x99B3208625e252eA0fBBe9B63e6004B06489D094);
        _setupRole(EXCLUDED_FROM_ANTIWHALE_ROLE, 0x596e5556cF23b30e6c2C4c60dE216F66551c0220);
        _setupRole(EXCLUDED_FROM_ANTIWHALE_ROLE, 0x9406609b3057053573f8d5418C1cbfaAc5161f21);
        _setupRole(EXCLUDED_FROM_ANTIWHALE_ROLE, 0x71FC956eee0C97B095B70f6B1B263147a6d6799A);

        _mint(_msgSender(), 1000000000 * 10**DECIMALS);
    }

    receive() external payable {}

    function decimals() public view virtual override returns (uint8) {
        return DECIMALS;
    }

    function totalFees() public view returns (uint256) {
        return liquidityFee + marketingFee;
    }

    function setLiquidityFee(uint256 _liquidityFee) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(totalFees() - liquidityFee + _liquidityFee <= MAX_FEE, "Tax too high");
        liquidityFee = _liquidityFee;
    }

    function setMarketingFee(uint256 _marketingFee) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(totalFees() - marketingFee + _marketingFee <= MAX_FEE, "Tax too high");
        marketingFee = _marketingFee;
    }

    function setMarketingAddress(address newAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        marketingAddress = newAddress;
    }

    function setLiquidityOwner(address newOwner) external onlyRole(DEFAULT_ADMIN_ROLE) {
        liquidityOwner = newOwner;
    }

    function updateSwapRouter(address _newRouter) external onlyRole(DEFAULT_ADMIN_ROLE) {
        swapRouter = IUniswapV2Router02(_newRouter);
        swapPair = IUniswapV2Factory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());

        require(swapPair != address(0), "Invalid pair address.");
        emit SwapRouterUpdated(address(swapRouter), swapPair);
    }

    function setProcessFeesEnabled(bool _enabled) external onlyRole(DEFAULT_ADMIN_ROLE) {
        processFeesEnabled = _enabled;
    }

    function processFees(uint256 amount, uint256 minAmountOut) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(amount <= balanceOf(address(this)), "Amount too high");
        _processFees(amount, minAmountOut);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return hasRole(EXCLUDED_FROM_FEE_ROLE, account);
    }

    function isExcludedAntiWhale(address account) public view returns (bool) {
        return hasRole(EXCLUDED_FROM_ANTIWHALE_ROLE, account);
    }

    function isLpPool(address pairAddress) public view returns (bool) {
        return _lpPools[pairAddress];
    }

    function setIsLpPool(address pairAddress, bool isLp) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _lpPools[pairAddress] = isLp;
    }

    function setNumTokensToSwap(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        numTokensToSwap = amount;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override notDenied(from) notDenied(to) antiWhale(from, to, amount) {
        require(amount > 0, "Transfer <= 0");

        uint256 taxFee = 0;
        bool sendFee = false;

        if (!_processingFees) {
            if (_lpPools[to] && !isExcludedFromFee(from) && !isExcludedFromFee(to)) {
                taxFee = totalFees();
                sendFee = processFeesEnabled;
            } else if (_lpPools[from] && !isExcludedFromFee(to) && to != address(swapRouter)) {
                taxFee = totalFees();
            }
        }

        if (sendFee) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance >= numTokensToSwap) {
                _processFees(numTokensToSwap, 0);
            }
        }

        bool takeFee = !_processingFees && taxFee > 0;
        if (takeFee) {
            uint256 taxAmount = amount.mul(taxFee).div(10000);
            if (taxAmount > 0) {
                super._transfer(from, address(this), taxAmount);
            }

            uint256 sendAmount = amount.sub(taxAmount);
            if (sendAmount > 0) {
                super._transfer(from, to, sendAmount);
            }
        } else {
            super._transfer(from, to, amount);
        }
    }

    function _processFees(uint256 tokenAmount, uint256 minAmountOut) private lockTheSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 totalTax = totalFees();
        if (contractTokenBalance >= tokenAmount && totalTax > 0) {
            uint256 liquidityAmount = tokenAmount.mul(liquidityFee).div(totalTax);
            uint256 liquidityTokens = liquidityAmount.div(2);
            uint256 marketingAmount = tokenAmount.sub(liquidityAmount);
            uint256 liquifyAmount = liquidityAmount.sub(liquidityTokens).add(marketingAmount);

            uint256 initialBalance = address(this).balance;

            swapTokensForEth(liquifyAmount, minAmountOut);

            uint256 newBalance = address(this).balance.sub(initialBalance);

            uint256 liquidityETH = newBalance.mul(liquidityTokens).div(liquifyAmount);
            addLiquidity(liquidityTokens, liquidityETH);

            sendToMarketing(address(this).balance);
        }
    }

    function swapTokensForEth(uint256 tokenAmount, uint256 minAmountOut) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();

        _approve(address(this), address(swapRouter), tokenAmount);

        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            minAmountOut,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(swapRouter), tokenAmount);

        swapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityOwner,
            block.timestamp
        );

        emit AddLiquidity(tokenAmount, ethAmount);
    }

    function sendToMarketing(uint256 amount) private {
        payable(marketingAddress).transfer(amount);
        emit SendToMarketing(marketingAddress, amount);
    }
}