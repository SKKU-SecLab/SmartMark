

pragma solidity 0.8.6;




library Error {

    string constant ADDRESS_WHITELISTED = "address already whitelisted";
    string constant ADMIN_ALREADY_SET = "admin has already been set once";
    string constant ADDRESS_NOT_WHITELISTED = "address not whitelisted";
    string constant ADDRESS_NOT_FOUND = "address not found";
    string constant CONTRACT_INITIALIZED = "contract can only be initialized once";
    string constant CONTRACT_PAUSED = "contract is paused";
    string constant INVALID_AMOUNT = "invalid amount";
    string constant INVALID_INDEX = "invalid index";
    string constant INVALID_VALUE = "invalid msg.value";
    string constant INVALID_SENDER = "invalid msg.sender";
    string constant INVALID_TOKEN = "token address does not match pool's LP token address";
    string constant INVALID_DECIMALS = "incorrect number of decimals";
    string constant INVALID_ARGUMENT = "invalid argument";
    string constant INVALID_IMPLEMENTATION = "invalid pool implementation for given coin";
    string constant INSUFFICIENT_BALANCE = "insufficient balance";
    string constant INSUFFICIENT_STRATEGY_BALANCE = "insufficient strategy balance";
    string constant ROLE_EXISTS = "role already exists";
    string constant UNAUTHORIZED_ACCESS = "unauthorized access";
    string constant SAME_ADDRESS_NOT_ALLOWED = "same address not allowed";
    string constant SELF_TRANSFER_NOT_ALLOWED = "self-transfer not allowed";
    string constant ZERO_ADDRESS_NOT_ALLOWED = "zero address not allowed";
    string constant ZERO_TRANSFER_NOT_ALLOWED = "zero transfer not allowed";
    string constant INSUFFICIENT_THRESHOLD = "insufficient threshold";
    string constant NO_POSITION_EXISTS = "no position exists";
    string constant POSITION_ALREADY_EXISTS = "position already exists";
    string constant PROTOCOL_NOT_FOUND = "protocol not found";
    string constant TOP_UP_FAILED = "top up failed";
    string constant SWAP_PATH_NOT_FOUND = "swap path not found";
    string constant UNDERLYING_NOT_SUPPORTED = "underlying token not supported";
    string constant NOT_ENOUGH_FUNDS_WITHDRAWN = "not enough funds were withdrawn from the pool";
    string constant FAILED_TRANSFER = "transfer failed";
    string constant FAILED_MINT = "mint failed";
    string constant FAILED_REPAY_BORROW = "repay borrow failed";
    string constant FAILED_METHOD_CALL = "method call failed";
    string constant NOTHING_TO_CLAIM = "there is no claimable balance";
    string constant ERC20_BALANCE_EXCEEDED = "ERC20: transfer amount exceeds balance";
    string constant INVALID_MINTER =
        "the minter address of the LP token and the pool address do not match";
    string constant STAKER_VAULT_EXISTS = "a staker vault already exists for the token";
    string constant DEADLINE_NOT_ZERO = "deadline must be 0";
    string constant INSUFFICIENT_UPDATE_BALANCE = "insufficient funds for updating the position";
    string constant SAME_AS_CURRENT = "value must be different to existing value";
    string constant NOT_CAPPED = "the pool is not currently capped";
    string constant ALREADY_CAPPED = "the pool is already capped";
    string constant EXCEEDS_DEPOSIT_CAP = "deposit exceeds deposit cap";
    string constant INVALID_TOKEN_TO_REMOVE = "token can not be removed";
}


interface IAdmin {

    event NewAdminAdded(address newAdmin);
    event AdminRenounced(address oldAdmin);

    function addAdmin(address newAdmin) external returns (bool);


    function renounceAdmin() external returns (bool);


    function isAdmin(address account) external view returns (bool);

}


interface IBooster {

    function poolInfo(uint256 pid)
        external
        returns (
            address lpToken,
            address token,
            address gauge,
            address crvRewards,
            address stash,
            bool shutdown
        );


    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) external returns (bool);


    function withdraw(uint256 _pid, uint256 _amount) external returns (bool);


    function withdrawAll(uint256 _pid) external returns (bool);

}


interface ICrvDepositor {

    function deposit(
        uint256 _amount,
        bool _lock,
        address _stakeAddress
    ) external;


    function depositAll(bool _lock, address _stakeAddress) external;

}


interface ICurveSwap {

    function get_virtual_price() external view returns (uint256);


    function add_liquidity(uint256[3] calldata amounts, uint256 min_mint_amount) external;


    function remove_liquidity_imbalance(uint256[3] calldata amounts, uint256 max_burn_amount)
        external;


    function remove_liquidity(uint256 _amount, uint256[3] calldata min_amounts) external;


    function exchange(
        int128 from,
        int128 to,
        uint256 _from_amount,
        uint256 _min_to_amount
    ) external;


    function coins(uint256 i) external view returns (address);


    function calc_token_amount(uint256[4] calldata amounts, bool deposit)
        external
        view
        returns (uint256);


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i)
        external
        view
        returns (uint256);


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount
    ) external;

}


interface IRewardStaking {

    function stakeFor(address, uint256) external;


    function stake(uint256) external;


    function stakeAll() external returns (bool);


    function withdraw(uint256 amount, bool claim) external returns (bool);


    function withdrawAndUnwrap(uint256 amount, bool claim) external;


    function earned(address account) external view returns (uint256);


    function getReward() external;


    function getReward(address _account, bool _claimExtras) external;


    function extraRewardsLength() external returns (uint256);


    function extraRewards(uint256 _pid) external returns (address);


    function rewardToken() external returns (address);


    function balanceOf(address account) external view returns (uint256);

}


interface IStrategy {

    function deposit() external payable returns (bool);


    function balance() external view returns (uint256);


    function withdraw(uint256 amount) external returns (bool);


    function withdrawAll() external returns (bool);


    function harvest() external returns (uint256);


    function strategist() external view returns (address);


    function shutdown() external returns (bool);


    function hasPendingFunds() external view returns (bool);

}


library MathFuncs {

    int256 internal constant LN2 = 693147180559945309;
    uint256 internal constant DECIMAL_SCALE = 1e18;
    uint256 internal constant ONE = DECIMAL_SCALE;

    function exp(int256 x) internal pure returns (uint256) {

        unchecked {
            if (x >= int256(ONE) * -5 && x <= int256(ONE) * 10) {
                return exp(x, 30);
            }
            return exp(x, 80);
        }
    }

    function exp(int256 x, uint256 n) internal pure returns (uint256) {

        unchecked {
            require(x <= int256(ONE) * 20, "exponent too large");
            require(x >= int256(ONE) * -10, "exponent too small");

            uint256 factorial = 1;
            int256 numerator = int256(ONE);
            int256 result = 0;
            for (uint256 k = 1; k <= n; k++) {
                int256 term = numerator / int256(factorial);
                result += term;
                factorial *= k;
                numerator = (numerator * x) / int256(DECIMAL_SCALE);
            }
            return uint256(result);
        }
    }

    function lnSmall(uint256 x) internal pure returns (int256) {

        unchecked {
            if (x <= ONE / 2 || x >= ONE + ONE / 2) {
                return lnSmall(x, 50);
            }
            return lnSmall(x, 30);
        }
    }

    function lnSmall(uint256 x, uint256 n) internal pure returns (int256) {

        unchecked {
            require(x < 3 * ONE, "x too large for lnSmall, use ln instead");
            require(x >= ONE / 10, "x too small for lnSmall");

            int256 result = 0;
            int256 x_min_1 = int256(x) - int256(ONE);
            int256 numerator = x_min_1;
            for (int256 k = 1; k <= int256(n); k++) {
                int256 term = numerator / k;
                if (k % 2 == 0) {
                    result -= term;
                } else {
                    result += term;
                }
                numerator = (numerator * x_min_1) / int256(DECIMAL_SCALE);
            }
            return result;
        }
    }

    function logBase2(uint256 x) internal pure returns (int256) {

        unchecked {
            if (x <= ONE / 2) {
                return logBase2(x, 50);
            }
            return logBase2(x, 30);
        }
    }

    function logBase2(uint256 x, uint256 n) internal pure returns (int256) {

        unchecked {
            uint256 number = x;
            uint256 y = ONE;
            uint256 integerPart = 0;
            while (number > ONE) {
                number /= 2;
                y /= 2;
                integerPart += ONE;
            }
            int256 decimalPart = (lnSmall((y * x) / DECIMAL_SCALE, n) * int256(DECIMAL_SCALE)) /
                LN2;
            return int256(integerPart) + decimalPart;
        }
    }

    function ln(uint256 x) internal pure returns (int256) {

        unchecked {
            if (x <= ONE / 2) {
                return ln(x, 50);
            }
            return ln(x, 30);
        }
    }

    function ln(uint256 x, uint256 n) internal pure returns (int256) {

        unchecked {
            return (logBase2(x, n) * LN2) / int256(DECIMAL_SCALE);
        }
    }


    function pow(uint256 base, int256 exponent) internal pure returns (uint256) {

        unchecked {
            if (base >= ONE / 2 && base < 2 * ONE) {
                return pow(base, exponent, 30);
            }
            return pow(base, exponent, 80);
        }
    }

    function pow(
        uint256 base,
        int256 exponent,
        uint256 n
    ) internal pure returns (uint256) {

        unchecked {
            if (base == 0) {
                return 0;
            }
            return exp((exponent * ln(base, n)) / int256(DECIMAL_SCALE), n);
        }
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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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


library SaferMath {

    uint256 internal constant decimalScale = 1e18;

    function scaledMul(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a * b) / decimalScale;
    }

    function scaledDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a * decimalScale) / b;
    }

    function scaledDivRoundUp(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a * decimalScale + b - 1) / b;
    }
}


interface UniswapRouter02 {

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
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


    function swapETHForExactTokens(
        uint256 amountOut,
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


    function WETH() external pure returns (address);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

}


interface UniswapV2Pair {

    function getReserves()
        external
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        );

}


abstract contract AdminBase is IAdmin {
    mapping(address => bool) admins;

    modifier onlyAdmin() {
        require(isAdmin(msg.sender), Error.UNAUTHORIZED_ACCESS);
        _;
    }

    function addAdmin(address newAdmin) public override onlyAdmin returns (bool) {
        require(!admins[newAdmin], Error.ROLE_EXISTS);
        admins[newAdmin] = true;
        emit NewAdminAdded(newAdmin);
        return true;
    }

    function renounceAdmin() external override onlyAdmin returns (bool) {
        admins[msg.sender] = false;
        emit AdminRenounced(msg.sender);
        return true;
    }

    function isAdmin(address account) public view override returns (bool) {
        return admins[account];
    }
}


contract ERC20 is Context, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return 18;
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


library SafeERC20 {
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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract Admin is AdminBase {
    constructor(address _admin) {
        admins[_admin] = true;
        emit NewAdminAdded(_admin);
    }
}



contract bkd3CrvCvx is IStrategy, Admin {
    using SaferMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for ERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    event DexUpdated(address token, address newDex);
    event RewardTokenAdded(address token);
    event RewardTokenRemoved(address token);
    event StashedReward(uint256 startTime, uint256 endTime, uint256 stashedAmount);

    uint256 public constant DAI_TARGET = 0;
    uint256 public constant USDC_TARGET = 1;

    modifier onlyVault() {
        require(msg.sender == vault, Error.UNAUTHORIZED_ACCESS);
        _;
    }

    struct RewardStash {
        uint64 startTime;
        uint64 endTime;
        uint128 unvested;
    }

    address public immutable vault;

    address public constant uniswap = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public constant sushiSwap = address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    address public constant cvx = address(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
    address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant cvxCrv = address(0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7);
    address public constant cvxCrvCrvSushiLpToken =
        address(0x33F6DDAEa2a8a54062E021873bCaEE006CdF4007);
    address public constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address public constant usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public constant usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    address public constant curvePool = address(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);

    address public constant booster = address(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);
    address public constant crvDepositor = address(0x8014595F2AB54cD7c604B00E9fb932176fDc86Ae);
    IRewardStaking public constant cvxCrvStaking =
        IRewardStaking(address(0x3Fe65692bfCD0e6CF84cB1E7d24108E434A7587e));
    IRewardStaking public immutable crvRewards; // Staking contract for Convex-3CRV deposit token

    uint256 public constant CONVEX_3CRV_PID = 9; // 3Curve pool id on Convex
    address public constant underlying = address(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490); // 3CRV

    address public communityReserve;
    uint256 public crvDumpShare;
    uint256 public cvxGovFee;

    bool public isShutdown;

    uint256 constant REWARDS_VESTING = 7 * 86400; // 1 week

    EnumerableSet.AddressSet private rewardTokens;

    mapping(address => address) public tokenDex;

    RewardStash[] public stashedRewards;
    uint256 public totalStashed; // rewards stashed after being liquidated

    mapping(address => address) public pathTarget; // swap target paths

    address public override strategist;

    constructor(address _vault, address _strategist) Admin(msg.sender) {
        (address lp, , , address _crvRewards, , ) = IBooster(booster).poolInfo(CONVEX_3CRV_PID);
        require(lp == address(underlying), "Incorrect Curve LP token");
        crvRewards = IRewardStaking(_crvRewards);
        strategist = _strategist;
        vault = _vault;

        IERC20(underlying).safeApprove(booster, type(uint256).max);

        IERC20(crv).safeApprove(crvDepositor, type(uint256).max);

        IERC20(dai).safeApprove(curvePool, type(uint256).max);
        IERC20(usdc).safeApprove(curvePool, type(uint256).max);
        IERC20(usdt).safeApprove(curvePool, type(uint256).max);

        tokenDex[crv] = sushiSwap; // CRV
        tokenDex[cvx] = sushiSwap; // CXV

        IERC20(crv).safeApprove(sushiSwap, type(uint256).max);
        IERC20(cvx).safeApprove(sushiSwap, type(uint256).max);

        IERC20(cvxCrv).safeApprove(sushiSwap, type(uint256).max);

        IERC20(cvxCrv).safeApprove(address(cvxCrvStaking), type(uint256).max);

        setPathTarget(crv, DAI_TARGET);
        setPathTarget(cvx, DAI_TARGET);
    }

    function deposit() external payable override onlyAdmin returns (bool) {
        require(msg.value == 0, Error.INVALID_VALUE);
        require(!isShutdown, "Strategy is shut down");

        uint256 currentBalance = _underlyingBalance();
        if (currentBalance == 0) return false;
        IBooster(booster).deposit(CONVEX_3CRV_PID, currentBalance, true); // deposit Curve LP into Convex pool and stake Convex LP
        return true;
    }

    function harvest() external override onlyVault returns (uint256) {
        uint256 oldBalance = _underlyingBalance();
        _claimStashedRewards();

        uint256 stakedCvxCrv = _stakedBalance();
        if (stakedCvxCrv > 0) cvxCrvStaking.getReward();

        crvRewards.getReward();

        _swapForToken(crv, crvDumpShare);

        uint256 crvBalance = IERC20(crv).balanceOf(address(this));
        if (crvBalance > 0) {
            (uint256 reserves0, uint256 reserves1, ) = UniswapV2Pair(cvxCrvCrvSushiLpToken)
                .getReserves();
            uint256 amountOut = UniswapRouter02(sushiSwap).getAmountOut(
                crvBalance,
                reserves1,
                reserves0
            );
            if (amountOut > crvBalance) {
                address[] memory path = new address[](2);
                path[0] = crv;
                path[1] = cvxCrv;
                UniswapRouter02(sushiSwap).swapExactTokensForTokens(
                    crvBalance,
                    uint256(0),
                    path,
                    address(this),
                    block.timestamp
                );
                cvxCrvStaking.stakeAll();
            } else {
                ICrvDepositor(crvDepositor).deposit(crvBalance, true, address(cvxCrvStaking)); // Swap CRV for cxvCRV and stake
            }
        }

        uint256 cvxBalance = IERC20(cvx).balanceOf(address(this));
        if (cvxBalance > 0 && cvxGovFee > 0 && communityReserve != address(0)) {
            uint256 govShare = cvxBalance.scaledMul(cvxGovFee);
            IERC20(cvx).safeTransfer(communityReserve, govShare);
        }

        _swapForToken(cvx, MathFuncs.ONE);

        _depositForUnderlying();

        uint256 newBalance = _underlyingBalance();
        return newBalance - oldBalance;
    }

    function _swapForToken(address token, uint256 dump) internal {
        uint256 currentBalance = IERC20(token).balanceOf(address(this));
        uint256 sellAmount = currentBalance;

        sellAmount = currentBalance.scaledMul(dump);

        if (sellAmount == 0) return;

        address[] memory path = new address[](3);
        path[0] = token;
        path[1] = weth;
        path[2] = pathTarget[token];

        UniswapRouter02(tokenDex[token]).swapExactTokensForTokens(
            sellAmount,
            uint256(0),
            path,
            address(this),
            block.timestamp
        );
    }

    function _depositForUnderlying() internal {
        uint256 daiBalance = IERC20(dai).balanceOf(address(this));
        uint256 usdcBalance = IERC20(usdc).balanceOf(address(this));
        uint256 usdtBalance = IERC20(usdt).balanceOf(address(this));
        if (daiBalance > 0 || usdcBalance > 0 || usdtBalance > 0) {
            ICurveSwap(curvePool).add_liquidity([daiBalance, usdcBalance, usdtBalance], 0);
        }
    }

    function _unstakeCvxCrv(uint256 amount) internal returns (bool) {
        require(_stakedBalance() >= amount, Error.INSUFFICIENT_BALANCE);
        cvxCrvStaking.withdraw(amount, false);
        return true;
    }

    function liquidate(address token, uint256 amount) external onlyAdmin returns (uint256) {
        return _liquidate(token, amount);
    }

    function _liquidate(address token, uint256 amount) internal returns (uint256) {
        if (amount == 0) return 0;
        uint256 oldBal = _underlyingBalance();

        if (token == cvxCrv) {
            _unstakeCvxCrv(amount);
            uint256 cvxCrvBalance = IERC20(cvxCrv).balanceOf(address(this));
            if (cvxCrvBalance > 0) {
                address[] memory path = new address[](2);
                path[0] = cvxCrv;
                path[1] = crv;
                UniswapRouter02(sushiSwap).swapExactTokensForTokens(
                    cvxCrvBalance,
                    uint256(0),
                    path,
                    address(this),
                    block.timestamp
                );
                _swapForToken(crv, MathFuncs.ONE);
                _depositForUnderlying();
            }
        } else {
            if (rewardTokens.contains(token)) {
                uint256 rewardTokenBalance = IERC20(token).balanceOf(address(this));
                if (rewardTokenBalance < amount) return 0;
                address[] memory path = new address[](3);
                address target = pathTarget[token];
                path[0] = token;
                path[1] = weth;
                path[2] = target;
                UniswapRouter02(tokenDex[token]).swapExactTokensForTokens(
                    rewardTokenBalance,
                    uint256(0),
                    path,
                    address(this),
                    block.timestamp
                );

                uint256 daiBalance = target == dai ? IERC20(target).balanceOf(address(this)) : 0;
                uint256 usdcBalance = target == usdc ? IERC20(target).balanceOf(address(this)) : 0;
                uint256 usdtBalance = target == usdt ? IERC20(target).balanceOf(address(this)) : 0;
                if (daiBalance > 0 || usdcBalance > 0 || usdtBalance > 0) {
                    ICurveSwap(curvePool).add_liquidity([daiBalance, usdcBalance, usdtBalance], 0);
                }
            }
        }

        uint256 newBal = _underlyingBalance();
        uint256 liquidated = newBal - oldBal;
        if (liquidated == 0) return 0;

        if (msg.sender == vault) {
            IERC20(underlying).safeTransfer(vault, liquidated);
        } else {
            uint256 endTime = block.timestamp + REWARDS_VESTING;
            _stashReward(block.timestamp, endTime, liquidated);
        }
        return liquidated;
    }

    function _stashReward(
        uint256 startTime,
        uint256 endTime,
        uint256 amount
    ) internal {
        stashedRewards.push(RewardStash(uint64(startTime), uint64(endTime), uint128(amount)));
        totalStashed += amount;
        emit StashedReward(startTime, endTime, amount);
    }

    function liquidateAll() external onlyAdmin returns (bool) {
        _liquidateAll();
        return true;
    }

    function _liquidateAll() internal {
        uint256 oldBal = _underlyingBalance();
        uint256 cvxCrvBalance = _stakedBalance();
        if (cvxCrvBalance > 0) {
            _liquidate(cvxCrv, cvxCrvBalance); // unstake and liquidate
        }

        for (uint256 i = 0; i < rewardTokens.length(); i++) {
            address rewardToken = rewardTokens.at(i);
            uint256 rewardTokenBalance = IERC20(rewardToken).balanceOf(address(this));
            if (rewardTokenBalance == 0) continue;
            _liquidate(rewardToken, rewardTokenBalance);
        }

        uint256 newBal = _underlyingBalance();
        uint256 liquidated = newBal - oldBal;
        if (liquidated == 0) return;

        if (msg.sender == vault) {
            IERC20(underlying).safeTransfer(vault, liquidated);
        } else {
            uint256 endTime = block.timestamp + REWARDS_VESTING;
            _stashReward(block.timestamp, endTime, liquidated);
        }
    }

    function _claimStashedRewards() internal {
        uint256 length = stashedRewards.length;
        if (length == 0) return;
        uint256 totalVested;
        uint256 count;
        uint256[] memory indexesToRemove = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            RewardStash storage stash = stashedRewards[i];
            uint256 endTime = stash.endTime;
            uint256 startTime = stash.startTime;
            if (block.timestamp >= endTime) {
                totalVested += stash.unvested;
                indexesToRemove[count] = i;
                count += 1;
                continue;
            }

            uint256 timeElapsed = block.timestamp - startTime;
            uint256 totalTime = endTime - startTime;
            uint256 claimed = uint256(stash.unvested).scaledMul(timeElapsed.scaledDiv(totalTime));
            totalVested += claimed;
            stash.unvested -= uint128(claimed);
            stash.startTime = uint64(block.timestamp);
        }

        totalStashed -= totalVested;

        if (count > 0) {
            for (uint256 i = count; i > 0; i--) {
                uint256 j = indexesToRemove[i - 1];
                stashedRewards[j] = stashedRewards[stashedRewards.length - 1];
                stashedRewards.pop();
            }
        }
    }

    function _underlyingBalance() internal view returns (uint256) {
        uint256 currentBalance = IERC20(underlying).balanceOf(address(this));
        return currentBalance - totalStashed;
    }

    function _stakedBalance() internal view returns (uint256) {
        return cvxCrvStaking.balanceOf(address(this));
    }

    function withdraw(uint256 amount) external override onlyVault returns (bool) {
        _withdraw(amount);
        return true;
    }

    function _withdraw(uint256 amount) internal {
        uint256 idleBalance = _underlyingBalance();
        if (idleBalance >= amount) {
            IERC20(underlying).safeTransfer(vault, amount);
            return;
        }
        uint256 requiredUnderlyingAmount = amount - idleBalance;
        require(
            crvRewards.balanceOf(address(this)) >= requiredUnderlyingAmount,
            Error.INSUFFICIENT_STRATEGY_BALANCE
        );
        crvRewards.withdraw(requiredUnderlyingAmount, false); // withdraw Convex pool LP tokens
        IBooster(booster).withdraw(CONVEX_3CRV_PID, requiredUnderlyingAmount); // burn Convex LP tokens for underlying
        uint256 currentBalance = IERC20(underlying).balanceOf(address(this));
        require(currentBalance >= amount, Error.INSUFFICIENT_STRATEGY_BALANCE);
        IERC20(underlying).safeTransfer(vault, amount);
    }

    function withdrawAll() external override onlyAdmin returns (bool) {
        uint256 totalBalance = balance();
        _withdraw(totalBalance);
        return true;
    }

    function swapDex(address token) external onlyAdmin returns (bool) {
        address currentDex = tokenDex[token];
        require(currentDex != address(0), "no dex has been set for token");
        address newDex = currentDex == sushiSwap ? uniswap : sushiSwap;
        setDex(token, newDex);
        IERC20(token).safeApprove(currentDex, 0);
        IERC20(token).safeApprove(newDex, type(uint256).max);
        return true;
    }

    function setDex(address token, address dex) internal {
        tokenDex[token] = dex;
        emit DexUpdated(token, dex);
    }

    function addRewardToken(address token, uint256 id) external onlyAdmin returns (bool) {
        require(
            token != cvx && token != cvxCrv && token != underlying && token != crv,
            "Invalid token to add"
        );
        require(id <= 2, "Invalid target path id");
        if (rewardTokens.contains(token)) return false;
        rewardTokens.add(token);
        setPathTarget(token, id);
        setDex(token, sushiSwap);

        IERC20(token).safeApprove(sushiSwap, 0);
        IERC20(token).safeApprove(sushiSwap, type(uint256).max);

        emit RewardTokenAdded(token);
        return true;
    }

    function withdrawAllToVault() external onlyAdmin returns (bool) {
        if (!isShutdown) return false;
        _claimStashedRewards();
        _liquidateAll();
        uint256 currentBalance = _underlyingBalance();
        if (currentBalance == 0) return false;
        IERC20(underlying).safeTransfer(vault, currentBalance);
        return true;
    }

    function removeRewardToken(address token) external onlyAdmin returns (bool) {
        if (rewardTokens.remove(token)) {
            emit RewardTokenRemoved(token);
            return true;
        }
        return false;
    }

    function balance() public view override returns (uint256) {
        uint256 currentBalance = _underlyingBalance();
        return crvRewards.balanceOf(address(this)) + currentBalance;
    }

    function hasPendingFunds() external view override returns (bool) {
        return totalStashed > 0;
    }

    function name() external pure returns (string memory) {
        return "Strategy3CRV-CVX";
    }


    function setCommunityReserve(address _communityReserve) external onlyAdmin returns (bool) {
        require(communityReserve == address(0), Error.ROLE_EXISTS);
        communityReserve = _communityReserve;
        return true;
    }

    function setCrvDumpShare(uint256 _crvDumpShare) external onlyAdmin returns (bool) {
        require(_crvDumpShare <= MathFuncs.ONE, Error.INVALID_AMOUNT);
        crvDumpShare = _crvDumpShare;
        return true;
    }

    function setCvxGovFee(uint256 _cvxGovFee) external onlyAdmin returns (bool) {
        require(_cvxGovFee <= MathFuncs.ONE, Error.INVALID_AMOUNT);
        require(communityReserve != address(0), "Community reserve must be set");
        cvxGovFee = _cvxGovFee;
        return true;
    }

    function setStrategist(address _strategist) external returns (bool) {
        require(msg.sender == strategist, Error.UNAUTHORIZED_ACCESS);
        strategist = _strategist;
        return true;
    }

    function shutdown() external override onlyVault returns (bool) {
        if (!isShutdown) {
            isShutdown = true;
            return true;
        }
        return false;
    }

    function setPathTarget(address token, uint256 id) public onlyAdmin returns (bool) {
        require(id <= 2, "unknown id");
        if (id == DAI_TARGET) {
            pathTarget[token] = dai;
        } else if (id == USDC_TARGET) {
            pathTarget[token] = usdc;
        } else {
            pathTarget[token] = usdt;
        }
        return true;
    }
}