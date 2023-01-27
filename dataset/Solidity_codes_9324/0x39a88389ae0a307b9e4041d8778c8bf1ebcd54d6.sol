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
}// MIT
pragma solidity ^0.7.0;

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
}// GPL-2.0-or-later
pragma solidity >=0.4.0;

library FullMath {

    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        require(denominator > prod1);


        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        uint256 twos = -denominator & denominator;
        assembly {
            denominator := div(denominator, twos)
        }

        assembly {
            prod0 := div(prod0, twos)
        }
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        uint256 inv = (3 * denominator) ^ 2;
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        result = prod0 * inv;
        return result;
    }

    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}// GPL-2.0-or-later
pragma solidity >=0.4.0;

library FixedPoint96 {

    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
}// MIT
pragma solidity >=0.6.0 <0.8.0;

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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT
pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
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

}// GPL-2.0-or-later
pragma solidity >=0.5.0;


interface IUniswapV3Pool {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function fee() external view returns (uint24);

    function tickSpacing() external view returns (int24);

    function maxLiquidityPerTick() external view returns (uint128);

    function slot0()
    external
    view
    returns (
        uint160 sqrtPriceX96,
        int24 tick,
        uint16 observationIndex,
        uint16 observationCardinality,
        uint16 observationCardinalityNext,
        uint8 feeProtocol,
        bool unlocked
    );

    function feeGrowthGlobal0X128() external view returns (uint256);

    function feeGrowthGlobal1X128() external view returns (uint256);

    function protocolFees() external view returns (uint128, uint128);

    function liquidity() external view returns (uint128);

    function ticks(int24 tick)
    external
    view
    returns (
        uint128 liquidityGross,
        int128 liquidityNet,
        uint256 feeGrowthOutside0X128,
        uint256 feeGrowthOutside1X128,
        int56 tickCumulativeOutside,
        uint160 secondsPerLiquidityOutsideX128,
        uint32 secondsOutside,
        bool initialized
    );

    function tickBitmap(int16 wordPosition) external view returns (uint256);

    function positions(bytes32 key)
    external
    view
    returns (
        uint128 _liquidity,
        uint256 feeGrowthInside0LastX128,
        uint256 feeGrowthInside1LastX128,
        uint128 tokensOwed0,
        uint128 tokensOwed1
    );

    function observations(uint256 index)
    external
    view
    returns (
        uint32 blockTimestamp,
        int56 tickCumulative,
        uint160 secondsPerLiquidityCumulativeX128,
        bool initialized
    );

    function observe(uint32[] calldata secondsAgos)
    external
    view
    returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
    external
    view
    returns (
        int56 tickCumulativeInside,
        uint160 secondsPerLiquidityInsideX128,
        uint32 secondsInside
    );

    function initialize(uint160 sqrtPriceX96) external;

    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;

    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    event Initialize(uint160 sqrtPriceX96, int24 tick);

    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}// MIT
pragma solidity ^0.7.0;


interface IStrategy {

    function addConfig(bytes calldata data) external;

    function changeConfig(bytes calldata data) external;

    function changeDirection(uint8) external;

    function getTotalAmounts() external view returns(uint128, uint256, uint256);

    function checkReBalanceStatus() external view returns (bool);

    function updateCommission(IUniswapV3Pool) external;

    function collectCommission(IUniswapV3Pool, address) external returns(uint256, uint256);

    function mining() external;

    function stopMining(uint128, address) external returns(uint256, uint256);

    function reBalance() external returns (bool, uint256, uint256, int24, int24);

}// MIT
pragma solidity ^0.7.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// BUSL-1.1
pragma solidity 0.7.6;
pragma abicoder v2;




contract GeneralVault is Ownable, ERC20, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IUniswapV3Pool public immutable pool;
    IERC20 public immutable token0;
    IERC20 public immutable token1;
    IStrategy public strategy;
    address operator;

    bool canDeposit = true;
    address dev; // fee collected address
    uint256 reinvestMin0;
    uint256 reinvestMin1;
    uint256 withdrawFee;

    constructor(
        address _pool,
        address _strategy,
        address _dev,
        address _operator
    ) ERC20("UNIVERSE-LP", "ULP") {
        pool = IUniswapV3Pool(_pool);
        token0 = IERC20(IUniswapV3Pool(_pool).token0());
        token1 = IERC20(IUniswapV3Pool(_pool).token1());
        strategy = IStrategy(_strategy);
        dev = _dev;
        operator = _operator;
    }


    modifier onlyOperator {
        require(msg.sender == operator, "operator only!");
        _;
    }

    modifier onlyEOA {
        require(msg.sender == tx.origin, "only EOA!");
        _;
    }


    function changeDev(address _dev) external onlyOwner {
        require(_dev != address(0), "invalid address");
        emit ChangeDev(msg.sender, dev, _dev);
        dev = _dev;
    }

    function changeOperator(address _operator) external onlyOwner {
        require(_operator != address(0), "invalid address");
        emit ChangeOperator(msg.sender, operator, _operator);
        operator = _operator;
    }

    function register(
        int24 boundaryThreshold,
        int24 reBalanceThreshold,
        uint8 direction,
        uint8 protocolFee,
        bool isSwap
    ) external onlyOwner {
        require(boundaryThreshold > reBalanceThreshold, "invalid params!");
        require(protocolFee == 0 || protocolFee >= 4, "invalid fee param");
        bytes memory data = abi.encode(
                address(pool),
                boundaryThreshold,
                reBalanceThreshold,
                direction,
                protocolFee,
                isSwap
        );
        strategy.addConfig(data);
    }


    function setCoreParams(
        bool _canDeposit,
        uint256 _withdrawFee,
        uint256 _reinvestMin0,
        uint256 _reinvestMin1
    ) external onlyOperator {
        require(_withdrawFee == 0 || _withdrawFee >= 4, "invalid fee param");
        canDeposit = _canDeposit;
        withdrawFee = _withdrawFee;
        reinvestMin0 = _reinvestMin0;
        reinvestMin1 = _reinvestMin1;
    }

    function changeConfig(
        int24 boundaryThreshold,
        int24 reBalanceThreshold,
        uint8 direction,
        uint8 protocolFee,
        bool isSwap
    ) external onlyOperator {
        require(boundaryThreshold > reBalanceThreshold, "invalid params!");
        require(protocolFee == 0 || protocolFee >= 4, "invalid fee param");
        bytes memory data = abi.encode(
            boundaryThreshold,
            reBalanceThreshold,
            direction,
            protocolFee,
            isSwap
        );
        strategy.changeConfig(data);
    }

    function changeDirection(uint8 direction) external onlyOperator {
        strategy.changeDirection(direction);
    }

    function reBalance() external onlyOperator {
        (
        bool status,
        uint256 feesFromPool0,
        uint256 feesFromPool1,
        int24 lowerTick,
        int24 upperTick
        ) = strategy.reBalance();
        if (status) {
            _transferToStrategy();
            strategy.mining();
            ( , uint256 total0, uint256 total1) = getTotalAmounts();
            emit ReBalance(msg.sender, lowerTick, upperTick, total0, total1);
            emit CollectFees(msg.sender, feesFromPool0, feesFromPool1, total0, total1, _currentTick());
        }
    }


    function _toUint128(uint256 x) internal pure returns (uint128) {
        assert(x <= type(uint128).max);
        return uint128(x);
    }

    function combineAmount(
        uint256 total0,
        uint256 total1,
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 priceX96
    ) internal pure returns (uint256) {
        if (amount1Desired.mul(total0) > amount0Desired.mul(total1)) {
            uint256 diff = (amount1Desired.mul(total0) - amount0Desired.mul(total1)).mul(3).div(total0).div(1000);
            amount1Desired = amount1Desired.sub(diff);
        } else if (amount1Desired.mul(total0) < amount0Desired.mul(total1)) {
            uint256 diff = (amount0Desired.mul(total1) - amount1Desired.mul(total0)).mul(3).div(total1).div(1000);
            amount0Desired = amount0Desired.sub(diff);
        }
        return FullMath.mulDiv(amount0Desired, priceX96, FixedPoint96.Q96).add(amount1Desired);
    }


    function _balance0() internal view returns (uint256) {
        return token0.balanceOf(address(this));
    }

    function _balance1() internal view returns (uint256) {
        return token1.balanceOf(address(this));
    }

    function _price() internal view returns (uint256) {
        (uint160 sqrtRatioX96, , , , , , ) = pool.slot0();
        return FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, FixedPoint96.Q96);
    }

    function _calcShare(
        uint256 amount0Desired,
        uint256 amount1Desired
    ) internal view returns (uint256) {
        uint256 totalShare = totalSupply();
        if (totalShare == 0) {
            return Math.max(amount0Desired, amount1Desired);
        }
        ( , uint256 total0, uint256 total1) = getTotalAmounts();
        require(total0 != 0 && total1 != 0, "total0 or total1 equals ZERO!");
        uint256 priceX96 = _price();
        uint256 addTotal = combineAmount(total0, total1, amount0Desired, amount1Desired, priceX96);
        uint256 total = FullMath.mulDiv(total0, priceX96, FixedPoint96.Q96).add(total1);
        return addTotal.mul(totalShare).div(total);
    }

    function getTotalAmounts() public view returns (uint128, uint256, uint256) {
        (uint128 liquidity, uint256 baseAmount0, uint256 baseAmount1) = strategy.getTotalAmounts();
        uint256 total0 = _balance0().add(baseAmount0);
        uint256 total1 = _balance1().add(baseAmount1);
        return (liquidity, total0, total1);
    }

    function getReBalanceStatus() public view returns (bool) {
        return strategy.checkReBalanceStatus();
    }

    function getPrice(uint256 decimal0, uint256 decimal1, bool normal) public view returns (uint256) {
        uint256 priceX96 = _price();
        if (decimal1 >= decimal0) {
            priceX96 = priceX96.div(10 ** (decimal1 - decimal0));
        } else {
            priceX96 = priceX96.mul(10 ** (decimal0 - decimal1));
        }
        if (normal) {
            return priceX96.mul(1E5).div(FixedPoint96.Q96);
        } else {
            return FixedPoint96.Q96.mul(1E5).div(priceX96);
        }
    }

    function calBalance(uint256 share) public view returns (uint256, uint256) {
        uint256 totalSupply = totalSupply();
        if (share == 0 || totalSupply == 0) {return (0, 0);}
        ( ,uint256 total0, uint256 total1) = getTotalAmounts();
        uint256 amount0 = total0.mul(share).div(totalSupply);
        uint256 amount1 = total1.mul(share).div(totalSupply);
        return (amount0, amount1);
    }

    function getUserBalance(address user) external view returns (uint256, uint256) {
        uint256 bal = balanceOf(user);
        return calBalance(bal);
    }

    function getBalancedAmount(
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external view returns (uint256, uint256, uint256) {
        uint256 share = _calcShare(amount0Desired, amount1Desired);
        uint256 totalSupply = totalSupply();
        if (totalSupply == 0) {return (share, amount0Desired, amount1Desired);}
        (uint256 amount0, uint256 amount1) = calBalance(share);
        return (share, amount0, amount1);
    }


    function _currentTick() internal view returns (int24 tick) {
        ( , tick, , , , , ) = pool.slot0();
    }

    function _transferToStrategy() internal {
        if (_balance0() > reinvestMin0) {
            token0.safeTransfer(address(strategy), _balance0());
        }
        if (_balance1() > reinvestMin1) {
            token1.safeTransfer(address(strategy), _balance1());
        }
    }

    function _collectAll() internal {
        updateCommission();
        (uint256 feesFromPool0, uint256 feesFromPool1) = strategy.collectCommission(pool, address(this));
        ( , uint256 total0, uint256 total1) = getTotalAmounts();
        emit CollectFees(msg.sender, feesFromPool0, feesFromPool1, total0, total1, _currentTick());
    }


    function updateCommission() public {
        strategy.updateCommission(pool);
    }


    function deposit(
        uint256 amount0,
        uint256 amount1,
        uint256 amount0Min,
        uint256 amount1Min
    ) external onlyEOA nonReentrant {
        require(canDeposit, "CAN NOT DEPOSIT!");
        require(amount0 >= amount0Min, "amount0Min");
        require(amount1 >= amount1Min, "amount1Min");
        require(amount0 > 0 || amount1 > 0, "amount0Desired or amount1Desired");
        updateCommission();
        uint256 share = _calcShare(amount0, amount1);
        require(share > 0, "share equal to zero!");
        (uint256 feesFromPool0, uint256 feesFromPool1) = strategy.collectCommission(pool, address(0));
        if (amount0 > 0) token0.safeTransferFrom(msg.sender, address(strategy), amount0);
        if (amount1 > 0) token1.safeTransferFrom(msg.sender, address(strategy), amount1);
        _transferToStrategy();
        _mint(msg.sender, share);
        strategy.mining();
        (uint256 actual0, uint256 actual1) = calBalance(share);
        emit Deposit(msg.sender, address(this), share, amount0, amount1, actual0, actual1, _currentTick());
        ( , uint256 total0, uint256 total1) = getTotalAmounts();
        emit CollectFees(msg.sender, feesFromPool0, feesFromPool1, total0, total1, _currentTick());
    }

    function withdraw(uint256 share) external onlyEOA nonReentrant returns (uint256 amount0, uint256 amount1) {
        require(share > 0, "zero Share");
        uint256 totalShare = totalSupply();
        _burn(msg.sender, share);
        uint256 reserveShare;
        if (withdrawFee > 0 && msg.sender != dev) {
            reserveShare = share.div(withdrawFee);
            share = share.sub(reserveShare);
            _mint(dev, reserveShare);
        }
        if (share == totalShare) {
            _collectAll();
        }
        (uint128 liquidity, , ) = strategy.getTotalAmounts();
        uint256 liq = uint256(liquidity).mul(share).div(totalShare);
        (uint256 baseAmount0, uint256 baseAmount1) = strategy.stopMining(_toUint128(liq), msg.sender);
        uint256 unusedAmount0 = _balance0().mul(share).div(totalShare);
        uint256 unusedAmount1 = _balance1().mul(share).div(totalShare);
        if (unusedAmount0 > 0) {token0.safeTransfer(msg.sender, unusedAmount0);}
        if (unusedAmount1 > 0) {token1.safeTransfer(msg.sender, unusedAmount1);}
        amount0 = baseAmount0.add(unusedAmount0);
        amount1 = baseAmount1.add(unusedAmount1);
        emit Withdraw(msg.sender, address(this), share, amount0, amount1, reserveShare, _currentTick());
    }

    function reInvest() external {
        updateCommission();
        (uint256 feesFromPool0, uint256 feesFromPool1) = strategy.collectCommission(pool, address(0));
        _transferToStrategy();
        strategy.mining();
        ( , uint256 total0, uint256 total1) = getTotalAmounts();
        emit CollectFees(msg.sender, feesFromPool0, feesFromPool1, total0, total1, _currentTick());
        emit ReInvest(msg.sender, 0, 0, total0, total1);
    }


    event ChangeDev(
        address indexed sender,
        address oldDev,
        address newDev
    );

    event ChangeOperator(
        address indexed sender,
        address oldOperator,
        address newOperator
    );

    event Deposit(
        address indexed user,
        address vault,
        uint256 share,
        uint256 amount0,
        uint256 amount1,
        uint256 actual0,
        uint256 actual1,
        int24 currentTick
    );

    event Withdraw(
        address indexed user,
        address vault,
        uint256 share,
        uint256 amount0,
        uint256 amount1,
        uint256 reserveShare,
        int24 currentTick
    );

    event CollectFees(
        address indexed sender,
        uint256 feesFromPool0,
        uint256 feesFromPool1,
        uint256 total0,
        uint256 total1,
        int24 currentTick
    );

    event ReBalance(
        address indexed sender,
        int24 lowerTick,
        int24 upperTick,
        uint256 total0,
        uint256 total1
    );

    event ReInvest(
        address indexed sender,
        int24 lowerTick,
        int24 upperTick,
        uint256 amount0,
        uint256 amount1
    );

}