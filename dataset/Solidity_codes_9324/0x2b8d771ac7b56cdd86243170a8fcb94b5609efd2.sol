
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


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

pragma solidity ^0.8.0;


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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

    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMathUpgradeable {

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
}// MIT
pragma solidity 0.8.7;

interface IScaledBalanceToken {

  function scaledBalanceOf(address user) external view returns (uint256);


  function getScaledUserBalanceAndSupply(address user) external view returns (uint256, uint256);


  function scaledTotalSupply() external view returns (uint256);

}// MIT
pragma solidity 0.8.7;

library DataTypes {

    struct ReserveData {
        bool isActive;
        uint128 liquidityIndex;
        uint128 variableBorrowIndex;
        uint128 currentLiquidityRate;
        uint128 currentVariableBorrowRate;
        uint40 lastUpdateTimestamp;
        address kTokenAddress;
        address variableDebtTokenAddress;
        address interestRateStrategyAddress;
        uint16 factor;
        uint8 decimals;
        uint8 id;
    }
}// MIT
pragma solidity 0.8.7;


interface ILendingPool {

    event Deposit(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount
    );

    event Withdraw(
        address indexed reserve,
        address indexed user,
        address indexed to,
        uint256 amount
    );

    event Borrow(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        uint256 borrowRate
    );

    event Repay(
        address indexed reserve,
        address indexed user,
        address indexed repayer,
        uint256 amount
    );

    event InitReserve(
        address asset,
        address kTokenAddress,
        address variableDebtAddress,
        address interestRateStrategyAddress,
        uint8 reserveDecimals,
        uint16 reserveFactor
    );

    event Paused();

    event Unpaused();

    event ReserveDataUpdated(
        address indexed reserve,
        uint256 liquidityRate,
        uint256 variableBorrowRate,
        uint256 liquidityIndex,
        uint256 variableBorrowIndex
    );

    event ReserveFactorChanged(address indexed asset, uint256 factor);

    event ReserveActiveChanged(address indexed asset, bool active);

    event CreditStrategyChanged(address creditContract);

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external;


    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);


    function borrow(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external;


    function repay(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external returns (uint256);


    function getUserAccountData(address user)
        external
        view
        returns (uint256 totalDebtInWEI, uint256 availableBorrowsInWEI);


    function initReserve(
        address reserve,
        address kTokenAddress,
        address variableDebtAddress,
        address interestRateStrategyAddress,
        uint8 reserveDecimals,
        uint16 reserveFactor
    ) external;


    function setReserveInterestRateStrategyAddress(
        address reserve,
        address rateStrategyAddress
    ) external;


    function getReserveNormalizedIncome(address asset)
        external
        view
        returns (uint256);


    function getReserveNormalizedVariableDebt(address asset)
        external
        view
        returns (uint256);


    function getReserveData(address asset)
        external
        view
        returns (DataTypes.ReserveData memory);


    function getReservesList() external view returns (address[] memory);


    function setPause(bool val) external;


    function paused() external view returns (bool);


    function getActive(address asset) external view returns (bool);


    function setCreditStrategy(address creditContract) external;


    function getCreditStrategy() external view returns (address);

}// MIT
pragma solidity 0.8.7;


interface IInitializableKToken {

    event Initialized(
        address indexed underlyingAsset,
        address indexed pool,
        address treasury,
        uint8 kTokenDecimals,
        string kTokenName,
        string kTokenSymbol,
        bytes params
    );

    function initialize(
        ILendingPool pool,
        address treasury,
        address underlyingAsset,
        uint8 kTokenDecimals,
        string calldata kTokenName,
        string calldata kTokenSymbol,
        bytes calldata params
    ) external;

}// MIT
pragma solidity 0.8.7;


interface IKToken is IERC20Upgradeable, IScaledBalanceToken, IInitializableKToken {

	
    event Mint(address indexed from, uint256 value, uint256 index);

    function mint(
        address user,
        uint256 amount,
        uint256 index
    ) external returns (bool);


    event Burn(address indexed from, address indexed target, uint256 value, uint256 index);

    event BalanceTransfer(address indexed from, address indexed to, uint256 value, uint256 index);

    function burn(
        address user,
        address receiverOfUnderlying,
        uint256 amount,
        uint256 index
    ) external;


    function mintToTreasury(uint256 amount, uint256 index) external;


    function transferUnderlyingTo(address user, uint256 amount) external returns (uint256);


    function handleRepayment(address user, uint256 amount) external;


    function UNDERLYING_ASSET_ADDRESS() external view returns (address);

}// MIT
pragma solidity 0.8.7;

library KyokoMath {

    uint256 internal constant WAD = 1e18;
    uint256 internal constant halfWAD = WAD / 2;

    uint256 internal constant RAY = 1e27;
    uint256 internal constant halfRAY = RAY / 2;

    uint256 internal constant WAD_RAY_RATIO = 1e9;

  function ray() internal pure returns (uint256) {

    return RAY;
  }


  function wad() internal pure returns (uint256) {

    return WAD;
  }

  function halfRay() internal pure returns (uint256) {

    return halfRAY;
  }

  function halfWad() internal pure returns (uint256) {

    return halfWAD;
  }

  function wadMul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0 || b == 0) {
      return 0;
    }

    require(a <= (type(uint256).max - halfWAD) / b, "MATH_MULTIPLICATION_OVERFLOW");

    return (a * b + halfWAD) / WAD;
  }

  function wadDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, "MATH_DIVISION_BY_ZERO");
    uint256 halfB = b / 2;

    require(a <= (type(uint256).max - halfB) / WAD, "MATH_MULTIPLICATION_OVERFLOW");

    return (a * WAD + halfB) / b;
  }

  function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0 || b == 0) {
      return 0;
    }

    require(a <= (type(uint256).max - halfRAY) / b, "MATH_MULTIPLICATION_OVERFLOW");

    return (a * b + halfRAY) / RAY;
  }

  function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, "MATH_DIVISION_BY_ZERO");
    uint256 halfB = b / 2;

    require(a <= (type(uint256).max - halfB) / RAY, "MATH_MULTIPLICATION_OVERFLOW");

    return (a * RAY + halfB) / b;
  }

  function rayToWad(uint256 a) internal pure returns (uint256) {

    uint256 halfRatio = WAD_RAY_RATIO / 2;
    uint256 result = halfRatio + a;
    require(result >= halfRatio, "MATH_ADDITION_OVERFLOW");

    return result / WAD_RAY_RATIO;
  }

  function wadToRay(uint256 a) internal pure returns (uint256) {

    uint256 result = a * WAD_RAY_RATIO;
    require(result / WAD_RAY_RATIO == a, "MATH_MULTIPLICATION_OVERFLOW");
    return result;
  }
}// MIT
pragma solidity 0.8.7;


abstract contract IncentivizedERC20 is
    ContextUpgradeable,
    IERC20Upgradeable,
    IERC20MetadataUpgradeable
{
    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        emit Transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 oldSenderBalance = _balances[sender];
        _balances[sender] = oldSenderBalance.sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        uint256 oldTotalSupply = _totalSupply;
        _totalSupply = oldTotalSupply.add(amount);

        uint256 oldAccountBalance = _balances[account];
        _balances[account] = oldAccountBalance.add(amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 oldTotalSupply = _totalSupply;
        _totalSupply = oldTotalSupply.sub(amount);

        uint256 oldAccountBalance = _balances[account];
        _balances[account] = oldAccountBalance.sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
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

    function _setName(string memory newName) internal {
        _name = newName;
    }

    function _setSymbol(string memory newSymbol) internal {
        _symbol = newSymbol;
    }

    function _setDecimals(uint8 newDecimals) internal {
        _decimals = newDecimals;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}// MIT
pragma solidity 0.8.7;


contract KToken is Initializable, IncentivizedERC20, IKToken {

    using KyokoMath for uint256;
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes public constant EIP712_REVISION = bytes("1");
    bytes32 internal constant EIP712_DOMAIN =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    uint256 public constant KTOKEN_REVISION = 0x1;

    mapping(address => uint256) public _nonces;

    bytes32 public DOMAIN_SEPARATOR;

    ILendingPool internal _pool;
    address internal _treasury;
    address internal _underlyingAsset;

    modifier onlyLendingPool() {

        require(
            _msgSender() == address(_pool),
            "CT_CALLER_MUST_BE_LENDING_POOL"
        );
        _;
    }

    function initialize(
        ILendingPool pool,
        address treasury,
        address underlyingAsset,
        uint8 kTokenDecimals,
        string calldata kTokenName,
        string calldata kTokenSymbol,
        bytes calldata params
    ) external override initializer {

        IncentivizedERC20.initialize(kTokenName, kTokenSymbol, kTokenDecimals); // Do not forget this call!

        uint256 chainId;

        assembly {
            chainId := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712_DOMAIN,
                keccak256(bytes(kTokenName)),
                keccak256(EIP712_REVISION),
                chainId,
                address(this)
            )
        );

        _setName(kTokenName);
        _setSymbol(kTokenSymbol);
        _setDecimals(kTokenDecimals);

        _pool = pool;
        _treasury = treasury;
        _underlyingAsset = underlyingAsset;

        emit Initialized(
            underlyingAsset,
            address(pool),
            treasury,
            kTokenDecimals,
            kTokenName,
            kTokenSymbol,
            params
        );
    }

    function burn(
        address user,
        address receiverOfUnderlying,
        uint256 amount,
        uint256 index
    ) external override onlyLendingPool {

        uint256 amountScaled = amount.rayDiv(index);
        require(amountScaled != 0, "CT_INVALID_BURN_AMOUNT");
        _burn(user, amountScaled);

        IERC20Upgradeable(_underlyingAsset).safeTransfer(
            receiverOfUnderlying,
            amount
        );

        emit Transfer(user, address(0), amount);
        emit Burn(user, receiverOfUnderlying, amount, index);
    }

    function mint(
        address user,
        uint256 amount,
        uint256 index
    ) external override onlyLendingPool returns (bool) {

        uint256 previousBalance = super.balanceOf(user);

        uint256 amountScaled = amount.rayDiv(index);
        require(amountScaled != 0, "CT_INVALID_MINT_AMOUNT");
        _mint(user, amountScaled);

        emit Transfer(address(0), user, amount);
        emit Mint(user, amount, index);

        return previousBalance == 0;
    }

    function mintToTreasury(uint256 amount, uint256 index)
        external
        override
        onlyLendingPool
    {

        if (amount == 0) {
            return;
        }

        address treasury = _treasury;

        _mint(treasury, amount.rayDiv(index));

        emit Transfer(address(0), treasury, amount);
        emit Mint(treasury, amount, index);
    }

    function balanceOf(address user)
        public
        view
        override(IncentivizedERC20, IERC20Upgradeable)
        returns (uint256)
    {

        return
            super.balanceOf(user).rayMul(
                _pool.getReserveNormalizedIncome(_underlyingAsset)
            );
    }

    function scaledBalanceOf(address user)
        external
        view
        override
        returns (uint256)
    {

        return super.balanceOf(user);
    }

    function getScaledUserBalanceAndSupply(address user)
        external
        view
        override
        returns (uint256, uint256)
    {

        return (super.balanceOf(user), super.totalSupply());
    }

    function totalSupply()
        public
        view
        override(IncentivizedERC20, IERC20Upgradeable)
        returns (uint256)
    {

        uint256 currentSupplyScaled = super.totalSupply();

        if (currentSupplyScaled == 0) {
            return 0;
        }

        return
            currentSupplyScaled.rayMul(
                _pool.getReserveNormalizedIncome(_underlyingAsset)
            );
    }

    function scaledTotalSupply()
        public
        view
        virtual
        override
        returns (uint256)
    {

        return super.totalSupply();
    }

    function RESERVE_TREASURY_ADDRESS() public view returns (address) {

        return _treasury;
    }

    function UNDERLYING_ASSET_ADDRESS() public view override returns (address) {

        return _underlyingAsset;
    }

    function POOL() public view returns (ILendingPool) {

        return _pool;
    }

    function transferUnderlyingTo(address target, uint256 amount)
        external
        override
        onlyLendingPool
        returns (uint256)
    {

        IERC20Upgradeable(_underlyingAsset).safeTransfer(target, amount);
        return amount;
    }

    function handleRepayment(address user, uint256 amount)
        external
        override
        onlyLendingPool
    {}


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {

        require(owner != address(0), "INVALID_OWNER");
        require(block.timestamp <= deadline, "INVALID_EXPIRATION");
        uint256 currentValidNonce = _nonces[owner];
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        currentValidNonce,
                        deadline
                    )
                )
            )
        );
        require(owner == ecrecover(digest, v, r, s), "INVALID_SIGNATURE");
        _nonces[owner] = currentValidNonce.add(1);
        _approve(owner, spender, value);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount,
        bool validate
    ) internal {

        address underlyingAsset = _underlyingAsset;
        ILendingPool pool = _pool;

        uint256 index = pool.getReserveNormalizedIncome(underlyingAsset);

        uint256 fromBalanceBefore = super.balanceOf(from).rayMul(index);
        uint256 toBalanceBefore = super.balanceOf(to).rayMul(index);

        super._transfer(from, to, amount.rayDiv(index));


        emit BalanceTransfer(from, to, amount, index);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {

        _transfer(from, to, amount, true);
    }
}