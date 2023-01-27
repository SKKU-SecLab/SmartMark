



pragma solidity ^0.6.0;


library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
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




pragma solidity 0.6.10;

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
}



pragma solidity 0.6.10;


library UniswapV2Library {
    using SafeMath for uint;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        bytes32 initCodeHash = hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f"; // default Uniswap V2
        if (factory == 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac) { // if Sushiswap
            initCodeHash = hex"e18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303";
        }
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex"ff",
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                initCodeHash
            ))));
    }

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
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



pragma solidity 0.6.10;

interface IFlashLoanReceiver {
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool);
}



pragma solidity 0.6.10;

interface ILendingPoolAddressesProvider {
  event LendingPoolUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingPoolCollateralManagerUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function setAddress(bytes32 id, address newAddress) external;

  function setAddressAsProxy(bytes32 id, address impl) external;

  function getAddress(bytes32 id) external view returns (address);

  function getLendingPool() external view returns (address);

  function setLendingPoolImpl(address pool) external;

  function getLendingPoolConfigurator() external view returns (address);

  function setLendingPoolConfiguratorImpl(address configurator) external;

  function getLendingPoolCollateralManager() external view returns (address);

  function setLendingPoolCollateralManager(address manager) external;

  function getPoolAdmin() external view returns (address);

  function setPoolAdmin(address admin) external;

  function getEmergencyAdmin() external view returns (address);

  function setEmergencyAdmin(address admin) external;

  function getPriceOracle() external view returns (address);

  function setPriceOracle(address priceOracle) external;

  function getLendingRateOracle() external view returns (address);

  function setLendingRateOracle(address lendingRateOracle) external;
}



pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

library DataTypes {
  struct ReserveData {
    ReserveConfigurationMap configuration;
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 currentLiquidityRate;
    uint128 currentVariableBorrowRate;
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    address interestRateStrategyAddress;
    uint8 id;
  }

  struct ReserveConfigurationMap {
    uint256 data;
  }

  struct UserConfigurationMap {
    uint256 data;
  }

  enum InterestRateMode {NONE, STABLE, VARIABLE}
}



pragma solidity 0.6.10;


interface ILendingPool {
  event Deposit(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint16 indexed referral
  );

  event Withdraw(address indexed reserve, address indexed user, address indexed to, uint256 amount);

  event Borrow(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint256 borrowRateMode,
    uint256 borrowRate,
    uint16 indexed referral
  );

  event Repay(
    address indexed reserve,
    address indexed user,
    address indexed repayer,
    uint256 amount
  );

  event Swap(address indexed reserve, address indexed user, uint256 rateMode);

  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);

  event RebalanceStableBorrowRate(address indexed reserve, address indexed user);

  event FlashLoan(
    address indexed target,
    address indexed initiator,
    address indexed asset,
    uint256 amount,
    uint256 premium,
    uint16 referralCode
  );

  event Paused();

  event Unpaused();

  event LiquidationCall(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    address liquidator,
    bool receiveAToken
  );

  event ReserveDataUpdated(
    address indexed reserve,
    uint256 liquidityRate,
    uint256 stableBorrowRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex
  );

  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external;

  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode,
    address onBehalfOf
  ) external;

  function repay(
    address asset,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external;

  function swapBorrowRateMode(address asset, uint256 rateMode) external;

  function rebalanceStableBorrowRate(address asset, address user) external;

  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;

  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveAToken
  ) external;

  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;

  function getUserAccountData(address user)
    external
    view
    returns (
      uint256 totalCollateralETH,
      uint256 totalDebtETH,
      uint256 availableBorrowsETH,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor
    );

  function initReserve(
    address reserve,
    address aTokenAddress,
    address stableDebtAddress,
    address variableDebtAddress,
    address interestRateStrategyAddress
  ) external;

  function setReserveInterestRateStrategyAddress(address reserve, address rateStrategyAddress)
    external;

  function setConfiguration(address reserve, uint256 configuration) external;

  function getConfiguration(address asset) external view returns (DataTypes.ReserveConfigurationMap memory);

  function getUserConfiguration(address user) external view returns (DataTypes.UserConfigurationMap memory);

  function getReserveNormalizedIncome(address asset) external view returns (uint256);

  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);

  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);

  function finalizeTransfer(
    address asset,
    address from,
    address to,
    uint256 amount,
    uint256 balanceFromAfter,
    uint256 balanceToBefore
  ) external;

  function getReservesList() external view returns (address[] memory);

  function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);

  function setPause(bool val) external;

  function paused() external view returns (bool);
}



pragma solidity 0.6.10;





abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    ILendingPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
    ILendingPool public immutable LENDING_POOL;

    constructor(ILendingPoolAddressesProvider provider) public {
        ADDRESSES_PROVIDER = provider;
        LENDING_POOL = ILendingPool(provider.getLendingPool());
    }
}



pragma solidity 0.6.10;

interface ICKToken is IERC20 {


    enum ModuleState {
        NONE,
        PENDING,
        INITIALIZED
    }

    struct Position {
        address component;
        address module;
        int256 unit;
        uint8 positionState;
        bytes data;
    }

    struct ComponentPosition {
      int256 virtualUnit;
      address[] externalPositionModules;
      mapping(address => ExternalPosition) externalPositions;
    }

    struct ExternalPosition {
      int256 virtualUnit;
      bytes data;
    }


    
    function addComponent(address _component) external;
    function removeComponent(address _component) external;
    function editDefaultPositionUnit(address _component, int256 _realUnit) external;
    function addExternalPositionModule(address _component, address _positionModule) external;
    function removeExternalPositionModule(address _component, address _positionModule) external;
    function editExternalPositionUnit(address _component, address _positionModule, int256 _realUnit) external;
    function editExternalPositionData(address _component, address _positionModule, bytes calldata _data) external;

    function invoke(address _target, uint256 _value, bytes calldata _data) external returns(bytes memory);

    function editPositionMultiplier(int256 _newMultiplier) external;

    function mint(address _account, uint256 _quantity) external;
    function burn(address _account, uint256 _quantity) external;

    function lock() external;
    function unlock() external;

    function addModule(address _module) external;
    function removeModule(address _module) external;
    function initializeModule() external;

    function setManager(address _manager) external;

    function manager() external view returns (address);
    function moduleStates(address _module) external view returns (ModuleState);
    function getModules() external view returns (address[] memory);
    
    function getDefaultPositionRealUnit(address _component) external view returns(int256);
    function getExternalPositionRealUnit(address _component, address _positionModule) external view returns(int256);
    function getComponents() external view returns(address[] memory);
    function getExternalPositionModules(address _component) external view returns(address[] memory);
    function getExternalPositionData(address _component, address _positionModule) external view returns(bytes memory);
    function isExternalPositionModule(address _component, address _module) external view returns(bool);
    function isComponent(address _component) external view returns(bool);
    
    function positionMultiplier() external view returns (int256);
    function getPositions() external view returns (Position[] memory);
    function getTotalComponentRealUnits(address _component) external view returns(int256);

    function isInitializedModule(address _module) external view returns(bool);
    function isPendingModule(address _module) external view returns(bool);
    function isLocked() external view returns (bool);
}



pragma solidity 0.6.10;

interface IBasicIssuanceModule {
    function getRequiredComponentUnitsForIssue(
        ICKToken _ckToken,
        uint256 _quantity
    ) external view returns(address[] memory, uint256[] memory);

    function issue(ICKToken _ckToken, uint256 _quantity, address _to) external;
    function redeem(ICKToken _ckToken, uint256 _quantity, address _to) external;
}




pragma solidity 0.6.10;









contract CKArbitrage is Ownable, FlashLoanReceiverBase {
    using SafeCast for int256;


    struct AssetExchange {
        address dealer;                 // For Uniswap v2 or Sushiswap, dealer is the pair address
        uint256 id;                     // 0: Uniswap V2, 1: Sushiswap
    }


    address public constant UNI_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public constant SUSHI_FACTORY = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 internal constant PRECISE_UNIT = 10 ** 18;


    mapping(address => AssetExchange) private assetExchanges_;
    address public feeRecipient_;


    constructor(
        address _feeRecipient,
        ILendingPoolAddressesProvider _addressProvider
    )
        public
        FlashLoanReceiverBase(_addressProvider)
    {
        require(_feeRecipient != address(0), "invalid address");
        feeRecipient_ = _feeRecipient;
    }


    function setFeeRecipient(
        address _feeRecipient
    )
        external
        onlyOwner
    {
        require(_feeRecipient != address(0), "invalid address");
        feeRecipient_ = _feeRecipient;
    }

    function setAssetExchanges(
        address[] memory _assets,
        address[] memory _dealers,
        uint256[] memory _ids
    )
        external
        onlyOwner
    {
        require(_assets.length == _dealers.length, "array not match");
        require(_dealers.length == _ids.length, "array not match");
        for (uint256 i = 0; i < _assets.length; i++) {
            address asset = _assets[i];
            require(asset != WETH_ADDRESS, "WETH don't require an exchange");

            uint256 id = _ids[i];
            require(id == 0 || id == 1, "only support UniswapV2 or Sushiswap now");

            address dealer = _dealers[i];
            IUniswapV2Pair pair = IUniswapV2Pair(dealer);
            require(asset == pair.token0() || asset == pair.token1(), "should be valid pair");

            assetExchanges_[asset].dealer = dealer;
            assetExchanges_[asset].id = id;
        }
    }

    function liquidateNavToDex(address _ckToken, address _issuanceModule, uint256 _coverAmount) external {
        require(_coverAmount > 0, "coverAmount should be greater than 0");
        require(ICKToken(_ckToken).isInitializedModule(_issuanceModule), "BasicIssuanceModule must be initialized");

        (uint256 ckAmountToIssue, uint256 wethAmountToLoan) = _calcIssueAndLoanAmounts(_ckToken, _issuanceModule);

        _flashLoan(_ckToken, _issuanceModule, _coverAmount, wethAmountToLoan, ckAmountToIssue, true);
    }

    function liquidateDexToNav(address _ckToken, address _issuanceModule, uint256 _coverAmount) external {
        require(_coverAmount > 0, "coverAmount should be greater than 0");
        require(ICKToken(_ckToken).isInitializedModule(_issuanceModule), "BasicIssuanceModule must be initialized");

        (uint256 ckAmountToRedeem, uint256 wethAmountToLoan) = _calcRedeemAndLoanAmounts(_ckToken);

        _flashLoan(_ckToken, _issuanceModule, _coverAmount, wethAmountToLoan, ckAmountToRedeem, false);
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    )
        external
        override
        returns (bool)
    {
        require(initiator == address(this), "should be valid initiator");
        require(assets[0] == WETH_ADDRESS, "should loan only WETH");

        uint256 wethAmountOwing = amounts[0].add(premiums[0]);
        _executeArbitrage(params, wethAmountOwing);

        IERC20(assets[0]).safeIncreaseAllowance(address(LENDING_POOL), wethAmountOwing);

        return true;
    }


    function getCKNavPrice(address _ckToken) external view returns (uint256) {
        return _calcCKNavPrice(ICKToken(_ckToken));
    }

    function getCKDexPrice(address _ckToken) external view returns (uint256) {
        return _getPriceFromUniswapV2Like(_ckToken);
    }


    function _sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _flashLoan(
        address _ckToken,
        address _issuanceModule,
        uint256 _coverAmount,
        uint256 _wethAmountToLoan,
        uint256 _ckAmountToProcess,
        bool _isIssue
    ) internal {
        address receiverAddress = address(this);

        address[] memory assets = new address[](1);
        assets[0] = WETH_ADDRESS;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _wethAmountToLoan;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        address onBehalfOf = address(this);
        bytes memory params = abi.encode(
            _ckToken,
            _issuanceModule,
            _coverAmount,
            _ckAmountToProcess,
            _isIssue
        );
        uint16 referralCode = 0;

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    function _executeArbitrage(bytes calldata params, uint256 wethAmountOwing) internal {
        (
            address _ckToken,
            address _issuanceModule,
            uint256 _coverAmount,
            uint256 _ckAmountToProcess,
            bool _isIssue
        ) = abi.decode(params, (address, address, uint256, uint256, bool));

        if (_isIssue) {
            _issueCKAndSell(_ckToken, _issuanceModule, _ckAmountToProcess);
        } else {
            _buyCKAndRedeem(_ckToken, _issuanceModule, _ckAmountToProcess);
        }
        uint256 wethOut = IERC20(WETH_ADDRESS).balanceOf(address(this));
        require(wethOut - wethAmountOwing >= _coverAmount, "should cover");
        IERC20(WETH_ADDRESS).safeTransfer(feeRecipient_, wethOut - wethAmountOwing);
    }

    function _issueCKAndSell(address _ckToken, address _issuanceModule, uint256 _amountToIssue) internal {
        (
            address[] memory components,
            uint256[] memory componentQuantities
        ) = IBasicIssuanceModule(_issuanceModule).getRequiredComponentUnitsForIssue(
            ICKToken(_ckToken),
            _amountToIssue
        );
        for (uint256 i = 0; i < components.length; i++) {
            IERC20 component = IERC20(components[i]);
            uint256 quantity = componentQuantities[i];
            if (address(component) != WETH_ADDRESS) {
                _swapTokenUniswapV2Like(address(component), quantity, true);
            }

            if (component.allowance(address(this), _issuanceModule) < quantity) {
                component.safeIncreaseAllowance(_issuanceModule, quantity);
            }
        }
        IBasicIssuanceModule(_issuanceModule).issue(ICKToken(_ckToken), _amountToIssue, address(this));

        _swapTokenUniswapV2Like(_ckToken, _amountToIssue, false);
    }

    function _buyCKAndRedeem(address _ckToken, address _issuanceModule, uint256 _amountToRedeem) internal {
        _swapTokenUniswapV2Like(_ckToken, _amountToRedeem, true);
        IERC20(_ckToken).safeIncreaseAllowance(_issuanceModule, _amountToRedeem);
        IBasicIssuanceModule(_issuanceModule).redeem(ICKToken(_ckToken), _amountToRedeem, address(this));
        address[] memory components = ICKToken(_ckToken).getComponents();
        for (uint256 i = 0; i < components.length; i++) {
            IERC20 component = IERC20(components[i]);
            uint256 quantity = component.balanceOf(address(this));
            if (address(component) != WETH_ADDRESS) {
                _swapTokenUniswapV2Like(address(component), quantity, false);
            }
        }
    }

    function _swapTokenUniswapV2Like(
        address _asset,
        uint256 _amount,
        bool _isForOut
    )
        internal
        returns (uint256 resultAmount)
    {
        address factory = _getFactoryForUniswapV2Like(_asset);

        (
            uint256[] memory amounts,
            address[] memory path
        ) = _getAmountsAndPathsUniswapV2Like(_asset, _amount, _isForOut);
        if(_isForOut) {
            resultAmount = amounts[0];
        } else {
            resultAmount = amounts[amounts.length - 1];
        }

        IERC20(path[0]).safeTransfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]);
        _swapUniswapV2Like(factory, amounts, path);
    }

    function _calcIssueAndLoanAmounts(
        address _ckToken,
        address _issuanceModule
    )
        internal
        view
        returns (uint256, uint256)
    {
        uint256 ckTargetPrice = _calcTargetPrice(_ckToken, true);

        (uint256 reserveCK, uint256 reserveWETH) =
            UniswapV2Library.getReserves(_getFactoryForUniswapV2Like(_ckToken), _ckToken, WETH_ADDRESS);
        require(reserveCK > 0 && reserveWETH > 0, "Pair has no reserve");

        uint256 sqrReserve = reserveCK
            .mul(reserveWETH)
            .mul(
                10 ** (
                uint256(18)
                    .add(ERC20(_ckToken).decimals())
                    .sub(ERC20(WETH_ADDRESS).decimals())
                )
            )
            .div(ckTargetPrice);
        uint256 ckAmountToIssue = _sqrt(sqrReserve).sub(reserveCK);

        uint256 ethAmountToLoan;
        (
            address[] memory components,
            uint256[] memory componentQuantities
        ) = IBasicIssuanceModule(_issuanceModule).getRequiredComponentUnitsForIssue(ICKToken(_ckToken), ckAmountToIssue);
        for (uint256 i = 0; i < components.length; i++) {
            if (components[i] != WETH_ADDRESS) {
                (
                    uint256[] memory amounts,
                ) = _getAmountsAndPathsUniswapV2Like(components[i], componentQuantities[i], true);
                ethAmountToLoan = ethAmountToLoan.add(amounts[0]);
            } else {
                ethAmountToLoan = ethAmountToLoan.add(componentQuantities[i]);
            }
        }

        return (ckAmountToIssue, ethAmountToLoan);
    }

    function _calcTargetPrice(address _ckToken, bool _isIssue) internal view returns (uint256 ckTargetPrice) {
        require(assetExchanges_[_ckToken].dealer != address(0), "ckToken should have valid exchange");
        IUniswapV2Pair pair = IUniswapV2Pair(assetExchanges_[_ckToken].dealer);
        address token0 = pair.token0();
        address token1 = pair.token1();
        require(
            (token0 ==  _ckToken && token1 == WETH_ADDRESS)
            || (token1 ==  _ckToken && token0 == WETH_ADDRESS),
            "only support ckToken/WETH or WETH/ckToken pair"
        );

        uint256 ckNavPrice = _calcCKNavPrice(ICKToken(_ckToken));
        uint256 ckDexPrice = _getPriceFromUniswapV2Like(_ckToken);
        if (_isIssue) {
            require(ckDexPrice > ckNavPrice.mul(101).div(100), "DEX price should be greater than NAV price over 1%");
            ckTargetPrice = ckNavPrice.add(ckDexPrice.sub(ckNavPrice).div(10));
        } else {
            require(ckNavPrice > ckDexPrice.mul(101).div(100), "NAV price should be greater than DEX price over 1%");
            ckTargetPrice = ckNavPrice.sub(ckNavPrice.sub(ckDexPrice).div(10));
        }
    }

    function _calcRedeemAndLoanAmounts(
        address _ckToken
    )
        internal
        view
        returns (uint256, uint256)
    {
        uint256 ckTargetPrice = _calcTargetPrice(_ckToken, false);

        address factory = _getFactoryForUniswapV2Like(_ckToken);
        (uint256 reserveCK, uint256 reserveWETH) =
            UniswapV2Library.getReserves(factory, _ckToken, WETH_ADDRESS);
        require(reserveCK > 0 && reserveWETH > 0, "Pair has no reserve");

        uint256 sqrReserve = reserveCK
            .mul(reserveWETH)
            .mul(ckTargetPrice)
            .div(
                10 ** (
                uint256(18)
                    .add(ERC20(_ckToken).decimals())
                    .sub(ERC20(WETH_ADDRESS).decimals())
                )
            );
        uint256 ethAmountToLoan = _sqrt(sqrReserve).sub(reserveWETH);

        address[] memory path = new address[](2);
        path[0] = WETH_ADDRESS;
        path[1] = _ckToken;
        uint256[] memory amounts = UniswapV2Library.getAmountsOut(factory, ethAmountToLoan, path);

        return (amounts[1], ethAmountToLoan);
    }

    function _calcCKNavPrice(ICKToken _ckToken) internal view returns (uint256) {
        address[] memory components = _ckToken.getComponents();
        uint256 valuation;

        for (uint256 i = 0; i < components.length; i++) {
            address component = components[i];
            uint256 componentPrice = uint256(10) ** ERC20(WETH_ADDRESS).decimals();
            if (component != WETH_ADDRESS) {
                componentPrice = _getPriceFromUniswapV2Like(component);
            }

            uint256 aggregateUnits = _ckToken.getTotalComponentRealUnits(component).toUint256();

            uint256 unitDecimals = ERC20(component).decimals();
            uint256 baseUnits = 10 ** unitDecimals;
            uint256 normalizedUnits = aggregateUnits.mul(PRECISE_UNIT).div(baseUnits);

            valuation = normalizedUnits.mul(componentPrice).div(PRECISE_UNIT).add(valuation);
        }

        return valuation;
    }

    function _getPriceFromUniswapV2Like(address _asset) internal view returns (uint256) {
        require(assetExchanges_[_asset].dealer != address(0), "should have valid exchange");
        IUniswapV2Pair pair = IUniswapV2Pair(assetExchanges_[_asset].dealer);
        address token0 = pair.token0();
        address token1 = pair.token1();
        address baseAsset = _asset;
        address quoteAsset;
        if (baseAsset == token0) {
            quoteAsset = token1;
        } else {
            quoteAsset = token0;
        }

        address factory = _getFactoryForUniswapV2Like(_asset);
        (uint256 reserveBase, uint256 reserveQuote) = UniswapV2Library.getReserves(factory, baseAsset, quoteAsset);
        require(reserveBase > 0 && reserveQuote > 0, "Pair has no reserve");
        uint256 price = reserveQuote
            .mul(10 ** (uint256(18).add(ERC20(baseAsset).decimals()).sub(ERC20(quoteAsset).decimals())))
            .div(reserveBase);

        if (quoteAsset != WETH_ADDRESS) {
            (uint256 reserveSecond, uint256 reserveWETH) = UniswapV2Library.getReserves(factory, quoteAsset, WETH_ADDRESS);
            require(reserveSecond > 0 && reserveWETH > 0, "Pair(WETH) has no reserve");
            uint256 priceSecond = reserveWETH
                .mul(10 ** (uint256(18).add(ERC20(quoteAsset).decimals()).sub(ERC20(WETH_ADDRESS).decimals())))
                .div(reserveSecond);
            price = price.mul(priceSecond).div(PRECISE_UNIT);
        }

        return price;
    }

    function _getFactoryForUniswapV2Like(address _asset) internal view returns (address) {
        address factory;
        if (assetExchanges_[_asset].id == 0) {
            factory = UNI_V2_FACTORY;
        } else if (assetExchanges_[_asset].id == 1) {
            factory = SUSHI_FACTORY;
        }

        return factory;
    }

    function _getAmountsAndPathsUniswapV2Like(
        address _asset,
        uint256 _amount,
        bool _isForOut
    )
        internal
        view
        returns (uint256[] memory amounts, address[] memory path)
    {
        address factory = _getFactoryForUniswapV2Like(_asset);
        IUniswapV2Pair pair = IUniswapV2Pair(assetExchanges_[_asset].dealer);
        address token0 = pair.token0();
        address token1 = pair.token1();
        address assetMiddle = _asset == token0 ? token1 : token0;

        uint8 pathLength = assetMiddle == WETH_ADDRESS ? 2 : 3;
        path = new address[](pathLength);
        path[0] = _asset;
        path[1] = assetMiddle;
        if (assetMiddle != WETH_ADDRESS) {
            path[2] = WETH_ADDRESS;
        }
        if (_isForOut) {
            address t;
            for (uint i = 0; i < pathLength / 2; i++) {
                t = path[i];
                path[i] = path[pathLength - i - 1];
                path[pathLength - i - 1] = t;
            }
        }

        amounts = _isForOut ?
            UniswapV2Library.getAmountsIn(factory, _amount, path)
            :
            UniswapV2Library.getAmountsOut(factory, _amount, path);
    }

    function _swapUniswapV2Like(address factory, uint[] memory amounts, address[] memory path) internal {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : address(this);
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }
}