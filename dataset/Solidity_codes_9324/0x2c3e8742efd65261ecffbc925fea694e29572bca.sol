pragma solidity 0.7.6;


abstract contract LPoolStorage {

    bool internal _notEntered;

    string public name;

    string public symbol;

    uint8 public decimals;

    uint public totalSupply;


    mapping(address => uint) internal accountTokens;

    mapping(address => mapping(address => uint)) internal transferAllowances;


    uint internal constant borrowRateMaxMantissa = 0.0005e16;

    uint public  borrowCapFactorMantissa;
    address public controller;


    uint internal initialExchangeRateMantissa;

    uint public accrualBlockNumber;

    uint public borrowIndex;

    uint public totalBorrows;

    uint internal totalCash;

    uint public reserveFactorMantissa;

    uint public totalReserves;

    address public underlying;

    bool public isWethPool;

    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }

    uint256 public baseRatePerBlock;
    uint256 public multiplierPerBlock;
    uint256 public jumpMultiplierPerBlock;
    uint256 public kink;


    mapping(address => BorrowSnapshot) internal accountBorrows;





    event Mint(address minter, uint mintAmount, uint mintTokens);

    event Transfer(address indexed from, address indexed to, uint amount);

    event Approval(address indexed owner, address indexed spender, uint amount);


    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);

    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);

    event Borrow(address borrower, address payee, uint borrowAmount, uint accountBorrows, uint totalBorrows);

    event RepayBorrow(address payer, address borrower, uint repayAmount, uint badDebtsAmount, uint accountBorrows, uint totalBorrows);


    event NewController(address oldController, address newController);

    event NewInterestParam(uint baseRatePerBlock, uint multiplierPerBlock, uint jumpMultiplierPerBlock, uint kink);

    event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);

    event ReservesAdded(address benefactor, uint addAmount, uint newTotalReserves);

    event ReservesReduced(address to, uint reduceAmount, uint newTotalReserves);

    event NewBorrowCapFactorMantissa(uint oldBorrowCapFactorMantissa, uint newBorrowCapFactorMantissa);

}

abstract contract LPoolInterface is LPoolStorage {



    function transfer(address dst, uint amount) external virtual returns (bool);

    function transferFrom(address src, address dst, uint amount) external virtual returns (bool);

    function approve(address spender, uint amount) external virtual returns (bool);

    function allowance(address owner, address spender) external virtual view returns (uint);

    function balanceOf(address owner) external virtual view returns (uint);

    function balanceOfUnderlying(address owner) external virtual returns (uint);


    function mint(uint mintAmount) external virtual;

    function mintTo(address to) external payable virtual;

    function mintEth() external payable virtual;

    function redeem(uint redeemTokens) external virtual;

    function redeemUnderlying(uint redeemAmount) external virtual;

    function borrowBehalf(address borrower, uint borrowAmount) external virtual;

    function repayBorrowBehalf(address borrower, uint repayAmount) external virtual;

    function repayBorrowEndByOpenLev(address borrower, uint repayAmount) external virtual;

    function availableForBorrow() external view virtual returns (uint);

    function getAccountSnapshot(address account) external virtual view returns (uint, uint, uint);

    function borrowRatePerBlock() external virtual view returns (uint);

    function supplyRatePerBlock() external virtual view returns (uint);

    function totalBorrowsCurrent() external virtual view returns (uint);

    function borrowBalanceCurrent(address account) external virtual view returns (uint);

    function borrowBalanceStored(address account) external virtual view returns (uint);

    function exchangeRateCurrent() public virtual returns (uint);

    function exchangeRateStored() public virtual view returns (uint);

    function getCash() external view virtual returns (uint);

    function accrueInterest() public virtual;

    function sync() public virtual;


    function setController(address newController) external virtual;

    function setBorrowCapFactorMantissa(uint newBorrowCapFactorMantissa) external virtual;

    function setInterestParams(uint baseRatePerBlock_, uint multiplierPerBlock_, uint jumpMultiplierPerBlock_, uint kink_) external virtual;

    function setReserveFactor(uint newReserveFactorMantissa) external virtual;

    function addReserves(uint addAmount) external virtual;

    function reduceReserves(address payable to, uint reduceAmount) external virtual;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// BUSL-1.1
pragma solidity >=0.6.0 <0.8.0;

contract CarefulMath {


    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }

    function mulUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    function divUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    function subUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    function addUInt(uint a, uint b) internal pure returns (MathError, uint) {

        uint c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    function addThenSubUInt(uint a, uint b, uint c) internal pure returns (MathError, uint) {

        (MathError err0, uint sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}// BUSL-1.1

pragma solidity >=0.6.0 <0.8.0;


contract Exponential is CarefulMath {

    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale/2;
    uint constant mantissaOne = expScale;

    struct Exp {
        uint mantissa;
    }

    struct Double {
        uint mantissa;
    }

    function getExp(uint num, uint denom) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint scaledNumerator) = mulUInt(num, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint rational) = divUInt(scaledNumerator, denom);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    function addExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {

        (MathError error, uint result) = addUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    function subExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {

        (MathError error, uint result) = subUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    function mulScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint scaledMantissa) = mulUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    function mulScalarTruncate(Exp memory a, uint scalar) pure internal returns (MathError, uint) {

        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(product));
    }

    function mulScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (MathError, uint) {

        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return addUInt(truncate(product), addend);
    }

    function divScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint descaledMantissa) = divUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }

    function divScalarByExp(uint scalar, Exp memory divisor) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint numerator) = mulUInt(expScale, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    function divScalarByExpTruncate(uint scalar, Exp memory divisor) pure internal returns (MathError, uint) {

        (MathError err, Exp memory fra) = divScalarByExp(scalar, divisor);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(fra));
    }

    function mulExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {


        (MathError err0, uint doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (MathError err2, uint product) = divUInt(doubleScaledProductWithHalfScale, expScale);
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({mantissa: product}));
    }

    function mulExp(uint a, uint b) pure internal returns (MathError, Exp memory) {

        return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
    }

    function mulExp3(Exp memory a, Exp memory b, Exp memory c) pure internal returns (MathError, Exp memory) {

        (MathError err, Exp memory ab) = mulExp(a, b);
        if (err != MathError.NO_ERROR) {
            return (err, ab);
        }
        return mulExp(ab, c);
    }

    function divExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {

        return getExp(a.mantissa, b.mantissa);
    }

    function truncate(Exp memory exp) pure internal returns (uint) {

        return exp.mantissa / expScale;
    }

    function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {

        return left.mantissa < right.mantissa;
    }

    function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {

        return left.mantissa <= right.mantissa;
    }

    function greaterThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {

        return left.mantissa > right.mantissa;
    }

    function isZeroExp(Exp memory value) pure internal returns (bool) {

        return value.mantissa == 0;
    }

    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {

        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint n, string memory errorMessage) pure internal returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {

        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {

        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {

        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) pure internal returns (uint) {

        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {

        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {

        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {

        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {

        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) pure internal returns (uint) {

        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {

        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {

        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {

        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {

        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}// BUSL-1.1


pragma solidity 0.7.6;

abstract contract Adminable {
    address payable public admin;
    address payable public pendingAdmin;
    address payable public developer;

    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);
    constructor () {
        developer = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "caller must be admin");
        _;
    }
    modifier onlyAdminOrDeveloper() {
        require(msg.sender == admin || msg.sender == developer, "caller must be admin or developer");
        _;
    }

    function setPendingAdmin(address payable newPendingAdmin) external virtual onlyAdmin {
        address oldPendingAdmin = pendingAdmin;
        pendingAdmin = newPendingAdmin;
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    function acceptAdmin() external virtual {
        require(msg.sender == pendingAdmin, "only pendingAdmin can accept admin");
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        admin = pendingAdmin;
        pendingAdmin = address(0);
        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


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

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

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
}// BUSL-1.1
pragma solidity 0.7.6;


contract DelegateInterface {

    address public implementation;

}// BUSL-1.1

pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

interface DexAggregatorInterface {


    function sell(address buyToken, address sellToken, uint sellAmount, uint minBuyAmount, bytes memory data) external returns (uint buyAmount);


    function sellMul(uint sellAmount, uint minBuyAmount, bytes memory data) external returns (uint buyAmount);


    function buy(address buyToken, address sellToken, uint buyAmount, uint maxSellAmount, bytes memory data) external returns (uint sellAmount);


    function calBuyAmount(address buyToken, address sellToken, uint sellAmount, bytes memory data) external view returns (uint);


    function calSellAmount(address buyToken, address sellToken, uint buyAmount, bytes memory data) external view returns (uint);


    function getPrice(address desToken, address quoteToken, bytes memory data) external view returns (uint256 price, uint8 decimals);


    function getAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, bytes memory data) external view returns (uint256 price, uint8 decimals, uint256 timestamp);


    function getPriceCAvgPriceHAvgPrice(address desToken, address quoteToken, uint32 secondsAgo, bytes memory dexData) external view returns (uint price, uint cAvgPrice, uint256 hAvgPrice, uint8 decimals, uint256 timestamp);


    function updatePriceOracle(address desToken, address quoteToken, uint32 timeWindow, bytes memory data) external returns(bool);


    function updateV3Observation(address desToken, address quoteToken, bytes memory data) external;

}// BUSL-1.1
pragma solidity 0.7.6;



contract ControllerStorage {


    struct LPoolPair {
        address lpool0;
        address lpool1;
    }
    struct LPoolDistribution {
        uint64 startTime;
        uint64 endTime;
        uint64 duration;
        uint64 lastUpdateTime;
        uint256 totalRewardAmount;
        uint256 rewardRate;
        uint256 rewardPerTokenStored;
        uint256 extraTotalToken;
    }
    struct LPoolRewardByAccount {
        uint rewardPerTokenStored;
        uint rewards;
        uint extraToken;
    }

    struct OLETokenDistribution {
        uint supplyBorrowBalance;
        uint extraBalance;
        uint128 updatePricePer;
        uint128 liquidatorMaxPer;
        uint16 liquidatorOLERatio;//300=>300%
        uint16 xoleRaiseRatio;//150=>150%
        uint128 xoleRaiseMinAmount;
    }

    IERC20 public oleToken;

    address public xoleToken;

    address public wETH;

    address public lpoolImplementation;

    uint256 public baseRatePerBlock;
    uint256 public multiplierPerBlock;
    uint256 public jumpMultiplierPerBlock;
    uint256 public kink;

    bytes public oleWethDexData;

    address public openLev;

    DexAggregatorInterface public dexAggregator;

    bool public suspend;

    OLETokenDistribution public oleTokenDistribution;
    mapping(address => mapping(address => LPoolPair)) public lpoolPairs;
    mapping(uint => bool) public marketExtraDistribution;
    mapping(uint => bool) public marketSuspend;
    mapping(address => bool) public lpoolUnAlloweds;
    mapping(LPoolInterface => mapping(bool => LPoolDistribution)) public lpoolDistributions;
    mapping(LPoolInterface => mapping(bool => mapping(address => LPoolRewardByAccount))) public lPoolRewardByAccounts;

    event LPoolPairCreated(address token0, address pool0, address token1, address pool1, uint16 marketId, uint16 marginLimit, bytes dexData);

    event Distribution2Pool(address pool, uint supplyAmount, uint borrowerAmount, uint64 startTime, uint64 duration, uint newSupplyBorrowBalance);

    event UpdatePriceReward(uint marketId, address updator, uint reward, uint newExtraBalance);

    event LiquidateReward(uint marketId, address liquidator, uint reward, uint newExtraBalance);

    event PoolReward(address pool, address rewarder, bool isBorrow, uint reward);

    event NewOLETokenDistribution(uint moreSupplyBorrowBalance, uint moreExtraBalance, uint128 updatePricePer, uint128 liquidatorMaxPer, uint16 liquidatorOLERatio, uint16 xoleRaiseRatio, uint128 xoleRaiseMinAmount);


}
interface ControllerInterface {


    function createLPoolPair(address tokenA, address tokenB, uint16 marginLimit, bytes memory dexData) external;



    function mintAllowed(address minter, uint lTokenAmount) external;


    function transferAllowed(address from, address to, uint lTokenAmount) external;


    function redeemAllowed(address redeemer, uint lTokenAmount) external;


    function borrowAllowed(address borrower, address payee, uint borrowAmount) external;


    function repayBorrowAllowed(address payer, address borrower, uint repayAmount, bool isEnd) external;


    function liquidateAllowed(uint marketId, address liquidator, uint liquidateAmount, bytes memory dexData) external;


    function marginTradeAllowed(uint marketId) external view returns (bool);


    function updatePriceAllowed(uint marketId) external;



    function setLPoolImplementation(address _lpoolImplementation) external;


    function setOpenLev(address _openlev) external;


    function setDexAggregator(DexAggregatorInterface _dexAggregator) external;


    function setInterestParam(uint256 _baseRatePerBlock, uint256 _multiplierPerBlock, uint256 _jumpMultiplierPerBlock, uint256 _kink) external;


    function setLPoolUnAllowed(address lpool, bool unAllowed) external;


    function setSuspend(bool suspend) external;


    function setMarketSuspend(uint marketId, bool suspend) external;


    function setOleWethDexData(bytes memory _oleWethDexData) external;


    function setOLETokenDistribution(uint moreSupplyBorrowBalance, uint moreExtraBalance, uint128 updatePricePer, uint128 liquidatorMaxPer, uint16 liquidatorOLERatio, uint16 xoleRaiseRatio, uint128 xoleRaiseMinAmount) external;


    function distributeRewards2Pool(address pool, uint supplyAmount, uint borrowAmount, uint64 startTime, uint64 duration) external;


    function distributeRewards2PoolMore(address pool, uint supplyAmount, uint borrowAmount) external;


    function distributeExtraRewards2Markets(uint[] memory marketIds, bool isDistribution) external;



    function earned(LPoolInterface lpool, address account, bool isBorrow) external view returns (uint256);


    function getSupplyRewards(LPoolInterface[] calldata lpools, address account) external;


}// BUSL-1.1
pragma solidity 0.7.6;

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256) external;

}// BUSL-1.1
pragma solidity 0.7.6;




contract LPool is DelegateInterface, Adminable, LPoolInterface, Exponential, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeMath for uint;

    constructor() {

    }
    function initialize(
        address underlying_,
        bool isWethPool_,
        address controller_,
        uint256 baseRatePerBlock_,
        uint256 multiplierPerBlock_,
        uint256 jumpMultiplierPerBlock_,
        uint256 kink_,
        uint initialExchangeRateMantissa_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_) public {

        require(underlying_ != address(0), "underlying_ address cannot be 0");
        require(controller_ != address(0), "controller_ address cannot be 0");
        require(msg.sender == admin, "Only allow to be called by admin");
        require(accrualBlockNumber == 0 && borrowIndex == 0, "inited once");

        initialExchangeRateMantissa = initialExchangeRateMantissa_;
        require(initialExchangeRateMantissa > 0, "Initial Exchange Rate Mantissa should be greater zero");
        controller = controller_;
        isWethPool = isWethPool_;
        baseRatePerBlock = baseRatePerBlock_;
        multiplierPerBlock = multiplierPerBlock_;
        jumpMultiplierPerBlock = jumpMultiplierPerBlock_;
        kink = kink_;

        accrualBlockNumber = getBlockNumber();
        borrowIndex = 1e25;
        borrowCapFactorMantissa = 0.8e18;
        reserveFactorMantissa = 0.1e18;


        name = name_;
        symbol = symbol_;
        decimals = decimals_;

        _notEntered = true;

        underlying = underlying_;
        IERC20(underlying).totalSupply();
        emit Transfer(address(0), msg.sender, 0);
    }

    function transferTokens(address spender, address src, address dst, uint tokens) internal returns (bool) {

        require(dst != address(0), "dst address cannot be 0");
        require(src != dst, "src = dst");
        (ControllerInterface(controller)).transferAllowed(src, dst, tokens);

        uint startingAllowance = 0;
        if (spender == src) {
            startingAllowance = uint(- 1);
        } else {
            startingAllowance = transferAllowances[src][spender];
        }

        MathError mathErr;
        uint allowanceNew;
        uint srcTokensNew;
        uint dstTokensNew;

        (mathErr, allowanceNew) = subUInt(startingAllowance, tokens);
        require(mathErr == MathError.NO_ERROR, 'not allowed');

        (mathErr, srcTokensNew) = subUInt(accountTokens[src], tokens);
        require(mathErr == MathError.NO_ERROR, 'not enough');

        (mathErr, dstTokensNew) = addUInt(accountTokens[dst], tokens);
        require(mathErr == MathError.NO_ERROR, 'too much');

        accountTokens[src] = srcTokensNew;
        accountTokens[dst] = dstTokensNew;

        if (startingAllowance != uint(- 1)) {
            transferAllowances[src][spender] = allowanceNew;
        }
        emit Transfer(src, dst, tokens);
        return true;
    }

    function transfer(address dst, uint256 amount) external override nonReentrant returns (bool) {

        return transferTokens(msg.sender, msg.sender, dst, amount);
    }

    function transferFrom(address src, address dst, uint256 amount) external override nonReentrant returns (bool) {

        return transferTokens(msg.sender, src, dst, amount);
    }

    function approve(address spender, uint256 amount) external override returns (bool) {

        address src = msg.sender;
        transferAllowances[src][spender] = amount;
        emit Approval(src, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external override view returns (uint256) {

        return transferAllowances[owner][spender];
    }

    function balanceOf(address owner) external override view returns (uint256) {

        return accountTokens[owner];
    }

    function balanceOfUnderlying(address owner) external override returns (uint) {

        Exp memory exchangeRate = Exp({mantissa : exchangeRateCurrent()});
        (MathError mErr, uint balance) = mulScalarTruncate(exchangeRate, accountTokens[owner]);
        require(mErr == MathError.NO_ERROR, "calc failed");
        return balance;
    }


    function mint(uint mintAmount) external override nonReentrant {

        accrueInterest();
        mintFresh(msg.sender, mintAmount, false);
    }

    function mintTo(address to) external payable override nonReentrant {

        accrueInterest();
        if (isWethPool) {
            mintFresh(to, msg.value, false);
        } else {
            mintFresh(to, 0, true);
        }
    }

    function mintEth() external payable override nonReentrant {

        require(isWethPool, "not eth pool");
        accrueInterest();
        mintFresh(msg.sender, msg.value, false);
    }

    function redeem(uint redeemTokens) external override nonReentrant {

        accrueInterest();
        redeemFresh(msg.sender, redeemTokens, 0);
    }

    function redeemUnderlying(uint redeemAmount) external override nonReentrant {

        accrueInterest();
        redeemFresh(msg.sender, 0, redeemAmount);
    }

    function borrowBehalf(address borrower, uint borrowAmount) external override nonReentrant {

        accrueInterest();
        borrowFresh(payable(borrower), msg.sender, borrowAmount);
    }

    function repayBorrowBehalf(address borrower, uint repayAmount) external override nonReentrant {

        accrueInterest();
        repayBorrowFresh(msg.sender, borrower, repayAmount, false);
    }

    function repayBorrowEndByOpenLev(address borrower, uint repayAmount) external override nonReentrant {

        accrueInterest();
        repayBorrowFresh(msg.sender, borrower, repayAmount, true);
    }

    function sync() public override {

        totalCash = IERC20(underlying).balanceOf(address(this));
    }


    function getCashPrior() internal view returns (uint) {

        return totalCash;
    }


    function doTransferIn(address from, uint amount, bool convertWeth) internal returns (uint actualAmount) {

        if (isWethPool && convertWeth) {
            actualAmount = msg.value;
            IWETH(underlying).deposit{value : actualAmount}();
        } else {
            actualAmount = amount;
            IERC20(underlying).safeTransferFrom(from, address(this), amount);
        }
        sync();
    }

    function doTransferOut(address payable to, uint amount, bool convertWeth) internal {

        if (isWethPool && convertWeth) {
            IWETH(underlying).withdraw(amount);
            to.transfer(amount);
        } else {
            IERC20(underlying).safeTransfer(to, amount);
        }
        sync();
    }

    function availableForBorrow() external view override returns (uint){

        uint cash = getCashPrior();
        (MathError err0, uint sum) = addThenSubUInt(cash, totalBorrows, totalReserves);
        if (err0 != MathError.NO_ERROR) {
            return 0;
        }
        (MathError err1, uint maxAvailable) = mulScalarTruncate(Exp({mantissa : sum}), borrowCapFactorMantissa);
        if (err1 != MathError.NO_ERROR) {
            return 0;
        }
        if (totalBorrows > maxAvailable) {
            return 0;
        }
        return maxAvailable - totalBorrows;
    }


    function getAccountSnapshot(address account) external override view returns (uint, uint, uint) {

        uint cTokenBalance = accountTokens[account];
        uint borrowBalance;
        uint exchangeRateMantissa;

        MathError mErr;

        (mErr, borrowBalance) = borrowBalanceStoredInternal(account);
        if (mErr != MathError.NO_ERROR) {
            return (0, 0, 0);
        }

        (mErr, exchangeRateMantissa) = exchangeRateStoredInternal();
        if (mErr != MathError.NO_ERROR) {
            return (0, 0, 0);
        }

        return (cTokenBalance, borrowBalance, exchangeRateMantissa);
    }

    function getBlockNumber() internal view returns (uint) {

        return block.number;
    }

    function borrowRatePerBlock() external override view returns (uint) {

        return getBorrowRateInternal(getCashPrior(), totalBorrows, totalReserves);
    }

    function supplyRatePerBlock() external override view returns (uint) {

        return getSupplyRateInternal(getCashPrior(), totalBorrows, totalReserves, reserveFactorMantissa);
    }

    function utilizationRate(uint cash, uint borrows, uint reserves) internal pure returns (uint) {

        if (borrows == 0) {
            return 0;
        }
        return borrows.mul(1e18).div(cash.add(borrows).sub(reserves));
    }

    function getBorrowRateInternal(uint cash, uint borrows, uint reserves) internal view returns (uint) {

        uint util = utilizationRate(cash, borrows, reserves);
        if (util <= kink) {
            return util.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);
        } else {
            uint normalRate = kink.mul(multiplierPerBlock).div(1e18).add(baseRatePerBlock);
            uint excessUtil = util.sub(kink);
            return excessUtil.mul(jumpMultiplierPerBlock).div(1e18).add(normalRate);
        }
    }

    function getSupplyRateInternal(uint cash, uint borrows, uint reserves, uint reserveFactor) internal view returns (uint) {

        uint oneMinusReserveFactor = uint(1e18).sub(reserveFactor);
        uint borrowRate = getBorrowRateInternal(cash, borrows, reserves);
        uint rateToPool = borrowRate.mul(oneMinusReserveFactor).div(1e18);
        return utilizationRate(cash, borrows, reserves).mul(rateToPool).div(1e18);
    }
    function totalBorrowsCurrent() external override view returns (uint) {

        uint currentBlockNumber = getBlockNumber();
        uint accrualBlockNumberPrior = accrualBlockNumber;

        if (accrualBlockNumberPrior == currentBlockNumber) {
            return totalBorrows;
        }

        uint cashPrior = getCashPrior();
        uint borrowsPrior = totalBorrows;
        uint reservesPrior = totalReserves;

        uint borrowRateMantissa = getBorrowRateInternal(cashPrior, borrowsPrior, reservesPrior);
        require(borrowRateMantissa <= borrowRateMaxMantissa, "borrower rate higher");

        (MathError mathErr, uint blockDelta) = subUInt(currentBlockNumber, accrualBlockNumberPrior);
        require(mathErr == MathError.NO_ERROR, "calc block delta erro");

        Exp memory simpleInterestFactor;
        uint interestAccumulated;
        uint totalBorrowsNew;

        (mathErr, simpleInterestFactor) = mulScalar(Exp({mantissa : borrowRateMantissa}), blockDelta);
        require(mathErr == MathError.NO_ERROR, 'calc interest factor error');

        (mathErr, interestAccumulated) = mulScalarTruncate(simpleInterestFactor, borrowsPrior);
        require(mathErr == MathError.NO_ERROR, 'calc interest acc error');

        (mathErr, totalBorrowsNew) = addUInt(interestAccumulated, borrowsPrior);
        require(mathErr == MathError.NO_ERROR, 'calc total borrows error');

        return totalBorrowsNew;
    }
    function borrowBalanceCurrent(address account) external view override returns (uint) {

        (MathError err0, uint borrowIndex) = calCurrentBorrowIndex();
        require(err0 == MathError.NO_ERROR, "calc borrow index fail");
        (MathError err1, uint result) = borrowBalanceStoredInternalWithBorrowerIndex(account, borrowIndex);
        require(err1 == MathError.NO_ERROR, "calc fail");
        return result;
    }

    function borrowBalanceStored(address account) external override view returns (uint){

        return accountBorrows[account].principal;
    }


    function borrowBalanceStoredInternal(address account) internal view returns (MathError, uint) {

        return borrowBalanceStoredInternalWithBorrowerIndex(account, borrowIndex);
    }
    function borrowBalanceStoredInternalWithBorrowerIndex(address account, uint borrowIndex) internal view returns (MathError, uint) {

        MathError mathErr;
        uint principalTimesIndex;
        uint result;

        BorrowSnapshot storage borrowSnapshot = accountBorrows[account];

        if (borrowSnapshot.principal == 0) {
            return (MathError.NO_ERROR, 0);
        }

        (mathErr, principalTimesIndex) = mulUInt(borrowSnapshot.principal, borrowIndex);
        if (mathErr != MathError.NO_ERROR) {
            return (mathErr, 0);
        }

        (mathErr, result) = divUInt(principalTimesIndex, borrowSnapshot.interestIndex);
        if (mathErr != MathError.NO_ERROR) {
            return (mathErr, 0);
        }

        return (MathError.NO_ERROR, result);
    }
    function exchangeRateCurrent() public override nonReentrant returns (uint) {

        accrueInterest();
        return exchangeRateStored();
    }

    function exchangeRateStored() public override view returns (uint) {

        (MathError err, uint result) = exchangeRateStoredInternal();
        require(err == MathError.NO_ERROR, "calc fail");
        return result;
    }

    function exchangeRateStoredInternal() internal view returns (MathError, uint) {

        uint _totalSupply = totalSupply;
        if (_totalSupply == 0) {
            return (MathError.NO_ERROR, initialExchangeRateMantissa);
        } else {
            uint totalCash = getCashPrior();
            uint cashPlusBorrowsMinusReserves;
            Exp memory exchangeRate;
            MathError mathErr;

            (mathErr, cashPlusBorrowsMinusReserves) = addThenSubUInt(totalCash, totalBorrows, totalReserves);
            if (mathErr != MathError.NO_ERROR) {
                return (mathErr, 0);
            }

            (mathErr, exchangeRate) = getExp(cashPlusBorrowsMinusReserves, _totalSupply);
            if (mathErr != MathError.NO_ERROR) {
                return (mathErr, 0);
            }

            return (MathError.NO_ERROR, exchangeRate.mantissa);
        }
    }

    function getCash() external override view returns (uint) {

        return totalCash;
    }

    function calCurrentBorrowIndex() internal view returns (MathError, uint) {

        uint currentBlockNumber = getBlockNumber();
        uint accrualBlockNumberPrior = accrualBlockNumber;
        uint borrowIndexNew;
        if (accrualBlockNumberPrior == currentBlockNumber) {
            return (MathError.NO_ERROR, borrowIndex);
        }
        uint borrowRateMantissa = getBorrowRateInternal(getCashPrior(), totalBorrows, totalReserves);
        (MathError mathErr, uint blockDelta) = subUInt(currentBlockNumber, accrualBlockNumberPrior);

        Exp memory simpleInterestFactor;
        (mathErr, simpleInterestFactor) = mulScalar(Exp({mantissa : borrowRateMantissa}), blockDelta);
        if (mathErr != MathError.NO_ERROR) {
            return (mathErr, 0);
        }
        (mathErr, borrowIndexNew) = mulScalarTruncateAddUInt(simpleInterestFactor, borrowIndex, borrowIndex);
        return (mathErr, borrowIndexNew);
    }

    function accrueInterest() public override {

        uint currentBlockNumber = getBlockNumber();
        uint accrualBlockNumberPrior = accrualBlockNumber;

        if (accrualBlockNumberPrior == currentBlockNumber) {
            return;
        }

        uint cashPrior = getCashPrior();
        uint borrowsPrior = totalBorrows;
        uint borrowIndexPrior = borrowIndex;
        uint reservesPrior = totalReserves;

        uint borrowRateMantissa = getBorrowRateInternal(cashPrior, borrowsPrior, reservesPrior);
        require(borrowRateMantissa <= borrowRateMaxMantissa, "borrower rate higher");

        (MathError mathErr, uint blockDelta) = subUInt(currentBlockNumber, accrualBlockNumberPrior);
        require(mathErr == MathError.NO_ERROR, "calc block delta erro");



        Exp memory simpleInterestFactor;
        uint interestAccumulated;
        uint totalBorrowsNew;
        uint borrowIndexNew;
        uint totalReservesNew;

        (mathErr, simpleInterestFactor) = mulScalar(Exp({mantissa : borrowRateMantissa}), blockDelta);
        require(mathErr == MathError.NO_ERROR, 'calc interest factor error');

        (mathErr, interestAccumulated) = mulScalarTruncate(simpleInterestFactor, borrowsPrior);
        require(mathErr == MathError.NO_ERROR, 'calc interest acc error');

        (mathErr, totalBorrowsNew) = addUInt(interestAccumulated, borrowsPrior);
        require(mathErr == MathError.NO_ERROR, 'calc total borrows error');

        (mathErr, totalReservesNew) = mulScalarTruncateAddUInt(Exp({mantissa : reserveFactorMantissa}), interestAccumulated, reservesPrior);
        require(mathErr == MathError.NO_ERROR, 'calc total reserves error');

        (mathErr, borrowIndexNew) = mulScalarTruncateAddUInt(simpleInterestFactor, borrowIndexPrior, borrowIndexPrior);
        require(mathErr == MathError.NO_ERROR, 'calc borrows index error');


        accrualBlockNumber = currentBlockNumber;
        borrowIndex = borrowIndexNew;
        totalBorrows = totalBorrowsNew;
        totalReserves = totalReservesNew;

        emit AccrueInterest(cashPrior, interestAccumulated, borrowIndexNew, totalBorrowsNew);

    }

    struct MintLocalVars {
        MathError mathErr;
        uint exchangeRateMantissa;
        uint mintTokens;
        uint totalSupplyNew;
        uint accountTokensNew;
        uint actualMintAmount;
    }

    function mintFresh(address minter, uint mintAmount, bool isDelegete) internal sameBlock returns (uint) {

        MintLocalVars memory vars;
        (vars.mathErr, vars.exchangeRateMantissa) = exchangeRateStoredInternal();
        require(vars.mathErr == MathError.NO_ERROR, 'calc exchangerate error');

        if (isDelegete) {
            uint priorCash = getCashPrior();
            sync();
            require(totalCash > priorCash, 'mint 0');
            vars.actualMintAmount = totalCash - priorCash;
        } else {
            vars.actualMintAmount = doTransferIn(minter, mintAmount, true);
        }

        (vars.mathErr, vars.mintTokens) = divScalarByExpTruncate(vars.actualMintAmount, Exp({mantissa : vars.exchangeRateMantissa}));
        require(vars.mathErr == MathError.NO_ERROR, "calc mint token error");

        (ControllerInterface(controller)).mintAllowed(minter, vars.mintTokens);
        (vars.mathErr, vars.totalSupplyNew) = addUInt(totalSupply, vars.mintTokens);
        require(vars.mathErr == MathError.NO_ERROR, "calc supply new failed");

        (vars.mathErr, vars.accountTokensNew) = addUInt(accountTokens[minter], vars.mintTokens);
        require(vars.mathErr == MathError.NO_ERROR, "calc tokens new ailed");

        totalSupply = vars.totalSupplyNew;
        accountTokens[minter] = vars.accountTokensNew;

        emit Mint(minter, vars.actualMintAmount, vars.mintTokens);
        emit Transfer(address(this), minter, vars.mintTokens);


        return vars.actualMintAmount;
    }


    struct RedeemLocalVars {
        MathError mathErr;
        uint exchangeRateMantissa;
        uint redeemTokens;
        uint redeemAmount;
        uint totalSupplyNew;
        uint accountTokensNew;
    }

    function redeemFresh(address payable redeemer, uint redeemTokensIn, uint redeemAmountIn) internal sameBlock {

        require(redeemTokensIn == 0 || redeemAmountIn == 0, "one be zero");

        RedeemLocalVars memory vars;

        (vars.mathErr, vars.exchangeRateMantissa) = exchangeRateStoredInternal();
        require(vars.mathErr == MathError.NO_ERROR, 'calc exchangerate error');

        if (redeemTokensIn > 0) {
            vars.redeemTokens = redeemTokensIn;

            (vars.mathErr, vars.redeemAmount) = mulScalarTruncate(Exp({mantissa : vars.exchangeRateMantissa}), redeemTokensIn);
            require(vars.mathErr == MathError.NO_ERROR, 'calc redeem amount error');
        } else {

            (vars.mathErr, vars.redeemTokens) = divScalarByExpTruncate(redeemAmountIn, Exp({mantissa : vars.exchangeRateMantissa}));
            require(vars.mathErr == MathError.NO_ERROR, 'calc redeem tokens error');
            vars.redeemAmount = redeemAmountIn;
        }

        (ControllerInterface(controller)).redeemAllowed(redeemer, vars.redeemTokens);

        (vars.mathErr, vars.totalSupplyNew) = subUInt(totalSupply, vars.redeemTokens);
        require(vars.mathErr == MathError.NO_ERROR, 'calc supply new error');

        (vars.mathErr, vars.accountTokensNew) = subUInt(accountTokens[redeemer], vars.redeemTokens);
        require(vars.mathErr == MathError.NO_ERROR, 'calc token new error');
        require(getCashPrior() >= vars.redeemAmount, 'cash < redeem');

        totalSupply = vars.totalSupplyNew;
        accountTokens[redeemer] = vars.accountTokensNew;
        doTransferOut(redeemer, vars.redeemAmount, true);


        emit Transfer(redeemer, address(this), vars.redeemTokens);
        emit Redeem(redeemer, vars.redeemAmount, vars.redeemTokens);

    }

    struct BorrowLocalVars {
        MathError mathErr;
        uint accountBorrows;
        uint accountBorrowsNew;
        uint totalBorrowsNew;
    }

    function borrowFresh(address payable borrower, address payable payee, uint borrowAmount) internal sameBlock {

        (ControllerInterface(controller)).borrowAllowed(borrower, payee, borrowAmount);

        require(getCashPrior() >= borrowAmount, 'cash<borrow');

        BorrowLocalVars memory vars;

        (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(borrower);
        require(vars.mathErr == MathError.NO_ERROR, 'calc acc borrows error');

        (vars.mathErr, vars.accountBorrowsNew) = addUInt(vars.accountBorrows, borrowAmount);
        require(vars.mathErr == MathError.NO_ERROR, 'calc acc borrows error');

        (vars.mathErr, vars.totalBorrowsNew) = addUInt(totalBorrows, borrowAmount);
        require(vars.mathErr == MathError.NO_ERROR, 'calc total borrows error');

        accountBorrows[borrower].principal = vars.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;

        doTransferOut(payee, borrowAmount, false);

        emit Borrow(borrower, payee, borrowAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);

    }

    struct RepayBorrowLocalVars {
        MathError mathErr;
        uint repayAmount;
        uint borrowerIndex;
        uint accountBorrows;
        uint accountBorrowsNew;
        uint totalBorrowsNew;
        uint actualRepayAmount;
        uint subBorrowsAmount;
        uint outstandingAmount;
        uint badDebtsAmount;
    }

    function repayBorrowFresh(address payer, address borrower, uint repayAmount, bool isEnd) internal sameBlock returns (uint) {

        (ControllerInterface(controller)).repayBorrowAllowed(payer, borrower, repayAmount, isEnd);

        RepayBorrowLocalVars memory vars;

        vars.borrowerIndex = accountBorrows[borrower].interestIndex;

        (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(borrower);
        require(vars.mathErr == MathError.NO_ERROR, 'calc acc borrow error');

        if (repayAmount == uint(- 1)) {
            vars.repayAmount = vars.accountBorrows;
        } else {
            vars.repayAmount = repayAmount;
        }

        vars.subBorrowsAmount = isEnd ? vars.accountBorrows : vars.repayAmount;
        (vars.mathErr, vars.outstandingAmount) = subUInt(vars.accountBorrows, vars.repayAmount);
        require(vars.mathErr == MathError.NO_ERROR, 'calc osamount error');
        vars.badDebtsAmount = isEnd ? vars.outstandingAmount : 0;
        (vars.mathErr, vars.accountBorrowsNew) = subUInt(vars.accountBorrows, vars.subBorrowsAmount);

        require(vars.mathErr == MathError.NO_ERROR, "calc acc borrows error");
        if (vars.subBorrowsAmount > totalBorrows) {
            vars.totalBorrowsNew = 0;
        } else {
            vars.totalBorrowsNew = totalBorrows - vars.subBorrowsAmount;
        }

        accountBorrows[borrower].principal = vars.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;

        vars.actualRepayAmount = doTransferIn(payer, vars.repayAmount, false);
        require(vars.actualRepayAmount == vars.repayAmount, 'repay amount incorrect');


        emit RepayBorrow(payer, borrower, vars.repayAmount, vars.badDebtsAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);


        return vars.repayAmount;
    }


    function setController(address newController) external override onlyAdmin {

        require(address(0) != newController, "0x");
        address oldController = controller;
        controller = newController;
        emit NewController(oldController, newController);
    }

    function setBorrowCapFactorMantissa(uint newBorrowCapFactorMantissa) external override onlyAdmin {

        require(newBorrowCapFactorMantissa <= 1e18, 'Factor too large');
        uint oldBorrowCapFactorMantissa = borrowCapFactorMantissa;
        borrowCapFactorMantissa = newBorrowCapFactorMantissa;
        emit NewBorrowCapFactorMantissa(oldBorrowCapFactorMantissa, borrowCapFactorMantissa);
    }

    function setInterestParams(uint baseRatePerBlock_, uint multiplierPerBlock_, uint jumpMultiplierPerBlock_, uint kink_) external override onlyAdmin {

        if (baseRatePerBlock != 0) {
            accrueInterest();
        }
        require(baseRatePerBlock_ < 1e13, 'Base rate too large');
        baseRatePerBlock = baseRatePerBlock_;
        require(multiplierPerBlock_ < 1e13, 'Mul rate too large');
        multiplierPerBlock = multiplierPerBlock_;
        require(jumpMultiplierPerBlock_ < 1e13, 'Jump rate too large');
        jumpMultiplierPerBlock = jumpMultiplierPerBlock_;
        require(kink_ <= 1e18, 'Kline too large');
        kink = kink_;
        emit NewInterestParam(baseRatePerBlock_, multiplierPerBlock_, jumpMultiplierPerBlock_, kink_);
    }

    function setReserveFactor(uint newReserveFactorMantissa) external override onlyAdmin {

        require(newReserveFactorMantissa <= 1e18, 'Factor too large');
        accrueInterest();
        uint oldReserveFactorMantissa = reserveFactorMantissa;
        reserveFactorMantissa = newReserveFactorMantissa;
        emit NewReserveFactor(oldReserveFactorMantissa, newReserveFactorMantissa);
    }

    function addReserves(uint addAmount) external override nonReentrant {

        accrueInterest();
        uint totalReservesNew;
        uint actualAddAmount = doTransferIn(msg.sender, addAmount, true);
        totalReservesNew = totalReserves.add(actualAddAmount);
        totalReserves = totalReservesNew;
        emit ReservesAdded(msg.sender, actualAddAmount, totalReservesNew);
    }

    function reduceReserves(address payable to, uint reduceAmount) external override nonReentrant onlyAdmin {

        accrueInterest();
        uint totalReservesNew;
        totalReservesNew = totalReserves.sub(reduceAmount);
        totalReserves = totalReservesNew;
        doTransferOut(to, reduceAmount, true);
        emit ReservesReduced(to, reduceAmount, totalReservesNew);
    }

    modifier sameBlock() {

        require(accrualBlockNumber == getBlockNumber(), 'not same block');
        _;
    }

}