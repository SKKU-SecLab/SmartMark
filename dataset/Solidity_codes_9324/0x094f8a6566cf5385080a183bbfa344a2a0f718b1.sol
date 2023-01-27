pragma solidity 0.5.17;

interface MomaMasterInterface {

    function isMomaMaster() external view returns (bool);


    function factory() external view returns (address);

    function admin() external view returns (address payable);



    function enterMarkets(address[] calldata mTokens) external returns (uint[] memory);

    function exitMarket(address mToken) external returns (uint);



    function mintAllowed(address mToken, address minter, uint mintAmount) external returns (uint);

    function mintVerify(address mToken, address minter, uint mintAmount, uint mintTokens) external;


    function redeemAllowed(address mToken, address redeemer, uint redeemTokens) external returns (uint);

    function redeemVerify(address mToken, address redeemer, uint redeemAmount, uint redeemTokens) external;


    function borrowAllowed(address mToken, address borrower, uint borrowAmount) external returns (uint);

    function borrowVerify(address mToken, address borrower, uint borrowAmount) external;


    function repayBorrowAllowed(
        address mToken,
        address payer,
        address borrower,
        uint repayAmount) external returns (uint);

    function repayBorrowVerify(
        address mToken,
        address payer,
        address borrower,
        uint repayAmount,
        uint borrowerIndex) external;


    function liquidateBorrowAllowed(
        address mTokenBorrowed,
        address mTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external returns (uint);

    function liquidateBorrowVerify(
        address mTokenBorrowed,
        address mTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external;


    function seizeAllowed(
        address mTokenCollateral,
        address mTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external returns (uint);

    function seizeVerify(
        address mTokenCollateral,
        address mTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external;


    function transferAllowed(address mToken, address src, address dst, uint transferTokens) external returns (uint);

    function transferVerify(address mToken, address src, address dst, uint transferTokens) external;



    function liquidateCalculateSeizeTokens(
        address mTokenBorrowed,
        address mTokenCollateral,
        uint repayAmount) external view returns (uint, uint);

}
pragma solidity 0.5.17;

contract InterestRateModel {

    bool public constant isInterestRateModel = true;

    function getBorrowRate(
        uint cash, 
        uint borrows, 
        uint reserves, 
        uint fees, 
        uint momaFees
    ) external view returns (uint);


    function getSupplyRate(
        uint cash, 
        uint borrows, 
        uint reserves, 
        uint reserveFactorMantissa, 
        uint fees, 
        uint feeFactorMantissa, 
        uint momaFees, 
        uint momaFeeFactorMantissa
    ) external view returns (uint);

}
pragma solidity 0.5.17;


contract MTokenStorage {

    bool internal _notEntered;

    string public name;

    string public symbol;

    uint8 public decimals;


    uint internal constant borrowRateMaxMantissa = 0.0005e16;

    uint internal constant feeFactorMaxMantissa = 0.3e18;

    uint internal constant momaFeeFactorMaxMantissa = 0.3e18;

    uint internal constant reserveFactorMaxMantissa = 0.4e18;

    address payable public feeReceiver;

    MomaMasterInterface public momaMaster;

    InterestRateModel public interestRateModel;

    uint internal initialExchangeRateMantissa;

    uint public feeFactorMantissa = 0.1e18;

    uint public reserveFactorMantissa = 0.1e18;

    uint public accrualBlockNumber;

    uint public borrowIndex;

    uint public totalBorrows;

    uint public totalFees;

    uint public totalMomaFees;

    uint public totalReserves;

    uint public totalSupply;

    mapping (address => uint) internal accountTokens;

    mapping (address => mapping (address => uint)) internal transferAllowances;

    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }

    mapping(address => BorrowSnapshot) internal accountBorrows;

    bool public constant isMToken = true;
}


contract MTokenInterface is MTokenStorage {



    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);

    event Mint(address minter, uint mintAmount, uint mintTokens);

    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);

    event Borrow(address borrower, uint borrowAmount, uint accountBorrows, uint totalBorrows);

    event RepayBorrow(address payer, address borrower, uint repayAmount, uint accountBorrows, uint totalBorrows);

    event LiquidateBorrow(address liquidator, address borrower, uint repayAmount, address mTokenCollateral, uint seizeTokens);



    event NewMomaMaster(MomaMasterInterface oldMomaMaster, MomaMasterInterface newMomaMaster);

    event NewMarketInterestRateModel(InterestRateModel oldInterestRateModel, InterestRateModel newInterestRateModel);

    event NewFeeReceiver(address oldFeeReceiver, address newFeeReceiver);

    event NewFeeFactor(uint oldFeeFactorMantissa, uint newFeeFactorMantissa);

    event FeesCollected(address feeReceiver, uint collectAmount, uint newTotalFees);

    event MomaFeesCollected(address momaFeeReceiver, uint collectAmount, uint newTotalMomaFees);

    event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);

    event ReservesAdded(address benefactor, uint addAmount, uint newTotalReserves);

    event ReservesReduced(address admin, uint reduceAmount, uint newTotalReserves);

    event Transfer(address indexed from, address indexed to, uint amount);

    event Approval(address indexed owner, address indexed spender, uint amount);

    event Failure(uint error, uint info, uint detail);



    function transfer(address dst, uint amount) external returns (bool);

    function transferFrom(address src, address dst, uint amount) external returns (bool);

    function approve(address spender, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function balanceOfUnderlying(address owner) external returns (uint);

    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);

    function borrowRatePerBlock() external view returns (uint);

    function supplyRatePerBlock() external view returns (uint);

    function totalBorrowsCurrent() external returns (uint);

    function borrowBalanceCurrent(address account) external returns (uint);

    function borrowBalanceStored(address account) public view returns (uint);

    function exchangeRateCurrent() public returns (uint);

    function exchangeRateStored() public view returns (uint);

    function getCash() external view returns (uint);

    function getMomaFeeFactor() external view returns (uint);

    function accrueInterest() public returns (uint);

    function seize(address liquidator, address borrower, uint seizeTokens) external returns (uint);




    function _setFeeReceiver(address payable newFeeReceiver) external returns (uint);

    function _setFeeFactor(uint newFeeFactorMantissa) external returns (uint);

    function _collectFees(uint collectAmount) external returns (uint);

    function _collectMomaFees(uint collectAmount) external returns (uint);

    function _setReserveFactor(uint newReserveFactorMantissa) external returns (uint);

    function _reduceReserves(uint reduceAmount) external returns (uint);

    function _setInterestRateModel(InterestRateModel newInterestRateModel) external returns (uint);

}

contract MErc20Storage {

    address public underlying;
}

contract MErc20Interface is MErc20Storage {



    function mint(uint mintAmount) external returns (uint);

    function redeem(uint redeemTokens) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function borrow(uint borrowAmount) external returns (uint);

    function repayBorrow(uint repayAmount) external returns (uint);

    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);

    function liquidateBorrow(address borrower, uint repayAmount, MTokenInterface mTokenCollateral) external returns (uint);




    function _addReserves(uint addAmount) external returns (uint);

}

contract MDelegationStorage {

    address public implementation;
}

contract MDelegatorInterface is MDelegationStorage {

    event NewImplementation(address oldImplementation, address newImplementation);

    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) public;

}

contract MDelegateInterface is MDelegationStorage {

    function _becomeImplementation(bytes memory data) public;


    function _resignImplementation() public;

}
pragma solidity 0.5.17;

contract MomaMasterErrorReporter {

    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        MOMAMASTER_MISMATCH,
        INSUFFICIENT_SHORTFALL,
        INSUFFICIENT_LIQUIDITY,
        INVALID_CLOSE_FACTOR,
        INVALID_COLLATERAL_FACTOR,
        INVALID_LIQUIDATION_INCENTIVE,
        MARKET_NOT_ENTERED, // no longer possible
        MARKET_NOT_LISTED,
        MARKET_ALREADY_LISTED,
        MATH_ERROR,
        NONZERO_BORROW_BALANCE,
        PRICE_ERROR,
        REJECTION,
        SNAPSHOT_ERROR,
        TOO_MANY_ASSETS,
        TOO_MUCH_REPAY
    }

    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
        EXIT_MARKET_BALANCE_OWED,
        EXIT_MARKET_REJECTION,
        SET_CLOSE_FACTOR_OWNER_CHECK,
        SET_CLOSE_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_NO_EXISTS,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_WITHOUT_PRICE,
        SET_IMPLEMENTATION_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_VALIDATION,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_PENDING_IMPLEMENTATION_OWNER_CHECK,
        SET_PRICE_ORACLE_OWNER_CHECK,
        SUPPORT_MARKET_EXISTS,
        SUPPORT_MARKET_OWNER_CHECK,
        SET_PAUSE_GUARDIAN_OWNER_CHECK
    }

    event Failure(uint error, uint info, uint detail);

    function fail(Error err, FailureInfo info) internal returns (uint) {

        emit Failure(uint(err), uint(info), 0);

        return uint(err);
    }

    function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {

        emit Failure(uint(err), uint(info), opaqueError);

        return uint(err);
    }
}

contract TokenErrorReporter {

    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        BAD_INPUT,
        MOMAMASTER_REJECTION,
        MOMAMASTER_CALCULATION_ERROR,
        INTEREST_RATE_MODEL_ERROR,
        INVALID_ACCOUNT_PAIR,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        INVALID_COLLATERAL_FACTOR,
        MATH_ERROR,
        MARKET_NOT_FRESH,
        MARKET_NOT_LISTED,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_IN_FAILED,
        TOKEN_TRANSFER_OUT_FAILED
    }

    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED,
        ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_FEES_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_MOMA_FEES_CALCULATION_FAILED,
        ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_ACCRUE_INTEREST_FAILED,
        BORROW_CASH_NOT_AVAILABLE,
        BORROW_FRESHNESS_CHECK,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        BORROW_MARKET_NOT_LISTED,
        BORROW_MOMAMASTER_REJECTION,
        LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED,
        LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED,
        LIQUIDATE_COLLATERAL_FRESHNESS_CHECK,
        LIQUIDATE_MOMAMASTER_REJECTION,
        LIQUIDATE_MOMAMASTER_CALCULATE_AMOUNT_SEIZE_FAILED,
        LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX,
        LIQUIDATE_CLOSE_AMOUNT_IS_ZERO,
        LIQUIDATE_FRESHNESS_CHECK,
        LIQUIDATE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_REPAY_BORROW_FRESH_FAILED,
        LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED,
        LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED,
        LIQUIDATE_SEIZE_MOMAMASTER_REJECTION,
        LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_SEIZE_TOO_MUCH,
        MINT_ACCRUE_INTEREST_FAILED,
        MINT_MOMAMASTER_REJECTION,
        MINT_EXCHANGE_CALCULATION_FAILED,
        MINT_EXCHANGE_RATE_READ_FAILED,
        MINT_FRESHNESS_CHECK,
        MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        MINT_TRANSFER_IN_FAILED,
        MINT_TRANSFER_IN_NOT_POSSIBLE,
        REDEEM_ACCRUE_INTEREST_FAILED,
        REDEEM_MOMAMASTER_REJECTION,
        REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED,
        REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED,
        REDEEM_EXCHANGE_RATE_READ_FAILED,
        REDEEM_FRESHNESS_CHECK,
        REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        REDEEM_TRANSFER_OUT_NOT_POSSIBLE,
        REDUCE_RESERVES_ACCRUE_INTEREST_FAILED,
        REDUCE_RESERVES_ADMIN_CHECK,
        REDUCE_RESERVES_CASH_NOT_AVAILABLE,
        REDUCE_RESERVES_FRESH_CHECK,
        REDUCE_RESERVES_VALIDATION,
        REPAY_BEHALF_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_MOMAMASTER_REJECTION,
        REPAY_BORROW_FRESHNESS_CHECK,
        REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_MOMAMASTER_OWNER_CHECK,
        SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED,
        SET_INTEREST_RATE_MODEL_FRESH_CHECK,
        SET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_ORACLE_MARKET_NOT_LISTED,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED,
        SET_RESERVE_FACTOR_ADMIN_CHECK,
        SET_RESERVE_FACTOR_FRESH_CHECK,
        SET_RESERVE_FACTOR_BOUNDS_CHECK,
        TRANSFER_MOMAMASTER_REJECTION,
        TRANSFER_NOT_ALLOWED,
        TRANSFER_NOT_ENOUGH,
        TRANSFER_TOO_MUCH,
        ADD_RESERVES_ACCRUE_INTEREST_FAILED,
        ADD_RESERVES_FRESH_CHECK,
        ADD_RESERVES_TRANSFER_IN_NOT_POSSIBLE,
        SET_FEE_ADMIN_OWNER_CHECK,
        SET_FEE_RECEIVER_OWNER_CHECK,
        SET_FEE_RECEIVER_ADDRESS_VALIDATION,
        SET_FEE_FACTOR_ACCRUE_INTEREST_FAILED,
        SET_FEE_FACTOR_ADMIN_CHECK,
        SET_FEE_FACTOR_FRESH_CHECK,
        SET_FEE_FACTOR_BOUNDS_CHECK,
        COLLECT_FEES_ACCRUE_INTEREST_FAILED,
        COLLECT_FEES_ADMIN_CHECK,
        COLLECT_FEES_FRESH_CHECK,
        COLLECT_FEES_CASH_NOT_AVAILABLE,
        COLLECT_FEES_VALIDATION,
        COLLECT_MOMA_FEES_ACCRUE_INTEREST_FAILED,
        COLLECT_MOMA_FEES_ADMIN_CHECK,
        COLLECT_MOMA_FEES_FRESH_CHECK,
        COLLECT_MOMA_FEES_CASH_NOT_AVAILABLE,
        COLLECT_MOMA_FEES_VALIDATION
    }

    event Failure(uint error, uint info, uint detail);

    function fail(Error err, FailureInfo info) internal returns (uint) {

        emit Failure(uint(err), uint(info), 0);

        return uint(err);
    }

    function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {

        emit Failure(uint(err), uint(info), opaqueError);

        return uint(err);
    }
}pragma solidity 0.5.17;

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
}pragma solidity 0.5.17;

contract ExponentialNoError {

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

    function truncate(Exp memory exp) pure internal returns (uint) {

        return exp.mantissa / expScale;
    }

    function mul_ScalarTruncate(Exp memory a, uint scalar) pure internal returns (uint) {

        Exp memory product = mul_(a, scalar);
        return truncate(product);
    }

    function mul_ScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (uint) {

        Exp memory product = mul_(a, scalar);
        return add_(truncate(product), addend);
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
}
pragma solidity 0.5.17;


contract Exponential is CarefulMath, ExponentialNoError {

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

        (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(fraction));
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
}
pragma solidity 0.5.17;

interface EIP20Interface {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256 balance);


    function transfer(address dst, uint256 amount) external returns (bool success);


    function transferFrom(address src, address dst, uint256 amount) external returns (bool success);


    function approve(address spender, uint256 amount) external returns (bool success);


    function allowance(address owner, address spender) external view returns (uint256 remaining);


    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}
pragma solidity 0.5.17;

interface EIP20NonStandardInterface {


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256 balance);



    function transfer(address dst, uint256 amount) external;



    function transferFrom(address src, address dst, uint256 amount) external;


    function approve(address spender, uint256 amount) external returns (bool success);


    function allowance(address owner, address spender) external view returns (uint256 remaining);


    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}
pragma solidity 0.5.17;

interface MomaFactoryInterface {


    event PoolCreated(address pool, address creator, uint poolLength);
    event NewMomaFarming(address oldMomaFarming, address newMomaFarming);
    event NewFarmingDelegate(address oldDelegate, address newDelegate);
    event NewFeeAdmin(address oldFeeAdmin, address newFeeAdmin);
    event NewDefualtFeeReceiver(address oldFeeReceiver, address newFeeReceiver);
    event NewDefualtFeeFactor(uint oldFeeFactor, uint newFeeFactor);
    event NewNoFeeTokenStatus(address token, bool oldNoFeeTokenStatus, bool newNoFeeTokenStatus);
    event NewTokenFeeFactor(address token, uint oldFeeFactor, uint newFeeFactor);
    event NewOracle(address oldOracle, address newOracle);
    event NewTimelock(address oldTimelock, address newTimelock);
    event NewMomaMaster(address oldMomaMaster, address newMomaMaster);
    event NewMEther(address oldMEther, address newMEther);
    event NewMErc20(address oldMErc20, address newMErc20);
    event NewMErc20Implementation(address oldMErc20Implementation, address newMErc20Implementation);
    event NewMEtherImplementation(address oldMEtherImplementation, address newMEtherImplementation);
    event NewLendingPool(address pool);
    event NewPoolFeeAdmin(address pool, address oldPoolFeeAdmin, address newPoolFeeAdmin);
    event NewPoolFeeReceiver(address pool, address oldPoolFeeReceiver, address newPoolFeeReceiver);
    event NewPoolFeeFactor(address pool, uint oldPoolFeeFactor, uint newPoolFeeFactor);
    event NewPoolFeeStatus(address pool, bool oldPoolFeeStatus, bool newPoolFeeStatus);

    function isMomaFactory() external view returns (bool);

    function oracle() external view returns (address);

    function momaFarming() external view returns (address);

    function farmingDelegate() external view returns (address);

    function mEtherImplementation() external view returns (address);

    function mErc20Implementation() external view returns (address);

    function admin() external view returns (address);

    function feeAdmin() external view returns (address);

    function defualtFeeReceiver() external view returns (address);

    function defualtFeeFactorMantissa() external view returns (uint);

    function feeFactorMaxMantissa() external view returns (uint);


    function tokenFeeFactors(address token) external view returns (uint);

    function allPools(uint) external view returns (address);


    function createPool() external returns (address);

    function allPoolsLength() external view returns (uint);

    function getMomaFeeAdmin(address pool) external view returns (address);

    function getMomaFeeReceiver(address pool) external view returns (address payable);

    function getMomaFeeFactorMantissa(address pool, address underlying) external view returns (uint);

    function isMomaPool(address pool) external view returns (bool);

    function isLendingPool(address pool) external view returns (bool);

    function isTimelock(address b) external view returns (bool);

    function isMomaMaster(address b) external view returns (bool);

    function isMEtherImplementation(address b) external view returns (bool);

    function isMErc20Implementation(address b) external view returns (bool);

    function isMToken(address b) external view returns (bool);

    function isCodeSame(address a, address b) external view returns (bool);


    function upgradeLendingPool() external returns (bool);

    
    function setFeeAdmin(address _newFeeAdmin) external;

    function setDefualtFeeReceiver(address payable _newFeeReceiver) external;

    function setDefualtFeeFactor(uint _newFeeFactor) external;

    function setTokenFeeFactor(address token, uint _newFeeFactor) external;


    function setPoolFeeAdmin(address pool, address _newPoolFeeAdmin) external;

    function setPoolFeeReceiver(address pool, address payable _newPoolFeeReceiver) external;

    function setPoolFeeFactor(address pool, uint _newFeeFactor) external;

    function setPoolFeeStatus(address pool, bool _noFee) external;

}
pragma solidity 0.5.17;


contract MToken is MTokenInterface, Exponential, TokenErrorReporter {

    function initialize(MomaMasterInterface momaMaster_,
                        uint initialExchangeRateMantissa_,
                        string memory name_,
                        string memory symbol_,
                        uint8 decimals_,
                        address payable feeReceiver_) public {

        require(msg.sender == momaMaster_.admin(), "only admin may initialize the market");
        require(initialExchangeRateMantissa == 0, "market may only be initialized once");
        require(feeReceiver_ != address(0), "feeReceiver is zero address");

        initialExchangeRateMantissa = initialExchangeRateMantissa_;
        require(initialExchangeRateMantissa > 0, "initial exchange rate must be greater than zero.");

        require(momaMaster_.isMomaMaster(), "marker method returned false");
        momaMaster = momaMaster_;

        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        feeReceiver = feeReceiver_;

        _notEntered = true;
    }

    function factory() public view returns (MomaFactoryInterface) {

        return MomaFactoryInterface(momaMaster.factory());
    }

    function transferTokens(address spender, address src, address dst, uint tokens) internal returns (uint) {

        uint allowed = momaMaster.transferAllowed(address(this), src, dst, tokens);
        if (allowed != 0) {
            return failOpaque(Error.MOMAMASTER_REJECTION, FailureInfo.TRANSFER_MOMAMASTER_REJECTION, allowed);
        }

        if (src == dst) {
            return fail(Error.BAD_INPUT, FailureInfo.TRANSFER_NOT_ALLOWED);
        }

        uint startingAllowance = 0;
        if (spender == src) {
            startingAllowance = uint(-1);
        } else {
            startingAllowance = transferAllowances[src][spender];
        }

        MathError mathErr;
        uint allowanceNew;
        uint srcTokensNew;
        uint dstTokensNew;

        (mathErr, allowanceNew) = subUInt(startingAllowance, tokens);
        if (mathErr != MathError.NO_ERROR) {
            return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_NOT_ALLOWED);
        }

        (mathErr, srcTokensNew) = subUInt(accountTokens[src], tokens);
        if (mathErr != MathError.NO_ERROR) {
            return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_NOT_ENOUGH);
        }

        (mathErr, dstTokensNew) = addUInt(accountTokens[dst], tokens);
        if (mathErr != MathError.NO_ERROR) {
            return fail(Error.MATH_ERROR, FailureInfo.TRANSFER_TOO_MUCH);
        }


        accountTokens[src] = srcTokensNew;
        accountTokens[dst] = dstTokensNew;

        if (startingAllowance != uint(-1)) {
            transferAllowances[src][spender] = allowanceNew;
        }

        emit Transfer(src, dst, tokens);

        momaMaster.transferVerify(address(this), src, dst, tokens);

        return uint(Error.NO_ERROR);
    }

    function transfer(address dst, uint256 amount) external nonReentrant returns (bool) {

        return transferTokens(msg.sender, msg.sender, dst, amount) == uint(Error.NO_ERROR);
    }

    function transferFrom(address src, address dst, uint256 amount) external nonReentrant returns (bool) {

        return transferTokens(msg.sender, src, dst, amount) == uint(Error.NO_ERROR);
    }

    function approve(address spender, uint256 amount) external returns (bool) {

        address src = msg.sender;
        transferAllowances[src][spender] = amount;
        emit Approval(src, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {

        return transferAllowances[owner][spender];
    }

    function balanceOf(address owner) external view returns (uint256) {

        return accountTokens[owner];
    }

    function balanceOfUnderlying(address owner) external returns (uint) {

        Exp memory exchangeRate = Exp({mantissa: exchangeRateCurrent()});
        (MathError mErr, uint balance) = mulScalarTruncate(exchangeRate, accountTokens[owner]);
        require(mErr == MathError.NO_ERROR, "balance could not be calculated");
        return balance;
    }

    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint) {

        uint mTokenBalance = accountTokens[account];
        uint borrowBalance;
        uint exchangeRateMantissa;

        MathError mErr;

        (mErr, borrowBalance) = borrowBalanceStoredInternal(account);
        if (mErr != MathError.NO_ERROR) {
            return (uint(Error.MATH_ERROR), 0, 0, 0);
        }

        (mErr, exchangeRateMantissa) = exchangeRateStoredInternal();
        if (mErr != MathError.NO_ERROR) {
            return (uint(Error.MATH_ERROR), 0, 0, 0);
        }

        return (uint(Error.NO_ERROR), mTokenBalance, borrowBalance, exchangeRateMantissa);
    }

    function getBlockNumber() internal view returns (uint) {

        return block.number;
    }

    function borrowRatePerBlock() external view returns (uint) {

        return interestRateModel.getBorrowRate(getCashPrior(), totalBorrows, totalReserves, totalFees, totalMomaFees);
    }

    function supplyRatePerBlock() external view returns (uint) {

        return interestRateModel.getSupplyRate(
            getCashPrior(), 
            totalBorrows, 
            totalReserves, 
            reserveFactorMantissa, 
            totalFees, 
            feeFactorMantissa, 
            totalMomaFees, 
            getMomaFeeFactorMantissa()
        );
    }

    function totalBorrowsCurrent() external nonReentrant returns (uint) {

        require(accrueInterest() == uint(Error.NO_ERROR), "accrue interest failed");
        return totalBorrows;
    }

    function borrowBalanceCurrent(address account) external nonReentrant returns (uint) {

        require(accrueInterest() == uint(Error.NO_ERROR), "accrue interest failed");
        return borrowBalanceStored(account);
    }

    function borrowBalanceStored(address account) public view returns (uint) {

        (MathError err, uint result) = borrowBalanceStoredInternal(account);
        require(err == MathError.NO_ERROR, "borrowBalanceStored: borrowBalanceStoredInternal failed");
        return result;
    }

    function borrowBalanceStoredInternal(address account) internal view returns (MathError, uint) {

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

    function exchangeRateCurrent() public nonReentrant returns (uint) {

        require(accrueInterest() == uint(Error.NO_ERROR), "accrue interest failed");
        return exchangeRateStored();
    }

    function exchangeRateStored() public view returns (uint) {

        (MathError err, uint result) = exchangeRateStoredInternal();
        require(err == MathError.NO_ERROR, "exchangeRateStored: exchangeRateStoredInternal failed");
        return result;
    }

    function exchangeRateStoredInternal() internal view returns (MathError, uint) {

        uint _totalSupply = totalSupply;
        if (_totalSupply == 0) {
            return (MathError.NO_ERROR, initialExchangeRateMantissa);
        } else {
            uint totalCash = getCashPrior();
            uint cashPlusBorrowsMinusReserves;
            uint minusFees;
            uint minusMomaFees;
            Exp memory exchangeRate;
            MathError mathErr;

            (mathErr, cashPlusBorrowsMinusReserves) = addThenSubUInt(totalCash, totalBorrows, totalReserves);
            if (mathErr != MathError.NO_ERROR) {
                return (mathErr, 0);
            }

            (mathErr, minusFees) = subUInt(cashPlusBorrowsMinusReserves, totalFees);
            if (mathErr != MathError.NO_ERROR) {
                return (mathErr, 0);
            }

            (mathErr, minusMomaFees) = subUInt(minusFees, totalMomaFees);
            if (mathErr != MathError.NO_ERROR) {
                return (mathErr, 0);
            }

            (mathErr, exchangeRate) = getExp(minusMomaFees, _totalSupply);
            if (mathErr != MathError.NO_ERROR) {
                return (mathErr, 0);
            }

            return (MathError.NO_ERROR, exchangeRate.mantissa);
        }
    }

    function getCash() external view returns (uint) {

        return getCashPrior();
    }

    function getMomaFeeFactor() external view returns (uint) {

        return getMomaFeeFactorMantissa();
    }

    function accrueInterest() public returns (uint) {

        if (address(interestRateModel) == address(0)) {
            return uint(Error.NO_ERROR);
        }


        if (accrualBlockNumber == getBlockNumber()) {
            return uint(Error.NO_ERROR);
        }

        uint cashPrior = getCashPrior();
        uint borrowsPrior = totalBorrows;
        uint reservesPrior = totalReserves;
        uint borrowIndexPrior = borrowIndex;

        uint momaFeeFactorMantissa = getMomaFeeFactorMantissa();
        require(momaFeeFactorMantissa <= momaFeeFactorMaxMantissa, "moma fee factor is absurdly high");

        uint borrowRateMantissa = interestRateModel.getBorrowRate(cashPrior, borrowsPrior, reservesPrior, totalFees, totalMomaFees);
        require(borrowRateMantissa <= borrowRateMaxMantissa, "borrow rate is absurdly high");

        (MathError mathErr, uint blockDelta) = subUInt(getBlockNumber(), accrualBlockNumber);
        require(mathErr == MathError.NO_ERROR, "could not calculate block delta");


        Exp memory simpleInterestFactor;
        uint interestAccumulated;
        uint totalBorrowsNew;
        uint totalReservesNew;
        uint totalFeesNew;
        uint totalMomaFeesNew;
        uint borrowIndexNew;

        (mathErr, simpleInterestFactor) = mulScalar(Exp({mantissa: borrowRateMantissa}), blockDelta);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED, uint(mathErr));
        }

        (mathErr, interestAccumulated) = mulScalarTruncate(simpleInterestFactor, borrowsPrior);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED, uint(mathErr));
        }

        (mathErr, totalBorrowsNew) = addUInt(interestAccumulated, borrowsPrior);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED, uint(mathErr));
        }

        (mathErr, totalReservesNew) = mulScalarTruncateAddUInt(Exp({mantissa: reserveFactorMantissa}), interestAccumulated, reservesPrior);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED, uint(mathErr));
        }

        (mathErr, totalFeesNew) = mulScalarTruncateAddUInt(Exp({mantissa: feeFactorMantissa}), interestAccumulated, totalFees);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_NEW_TOTAL_FEES_CALCULATION_FAILED, uint(mathErr));
        }

        (mathErr, totalMomaFeesNew) = mulScalarTruncateAddUInt(Exp({mantissa: momaFeeFactorMantissa}), interestAccumulated, totalMomaFees);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_NEW_TOTAL_MOMA_FEES_CALCULATION_FAILED, uint(mathErr));
        }

        (mathErr, borrowIndexNew) = mulScalarTruncateAddUInt(simpleInterestFactor, borrowIndexPrior, borrowIndexPrior);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED, uint(mathErr));
        }


        accrualBlockNumber = getBlockNumber();
        borrowIndex = borrowIndexNew;
        totalBorrows = totalBorrowsNew;
        totalReserves = totalReservesNew;
        totalFees = totalFeesNew;
        totalMomaFees = totalMomaFeesNew;

        emit AccrueInterest(cashPrior, interestAccumulated, borrowIndexNew, totalBorrowsNew);

        return uint(Error.NO_ERROR);
    }

    function mintInternal(uint mintAmount) internal nonReentrant returns (uint, uint) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.MINT_ACCRUE_INTEREST_FAILED), 0);
        }
        return mintFresh(msg.sender, mintAmount);
    }

    struct MintLocalVars {
        Error err;
        MathError mathErr;
        uint exchangeRateMantissa;
        uint mintTokens;
        uint totalSupplyNew;
        uint accountTokensNew;
        uint actualMintAmount;
    }

    function mintFresh(address minter, uint mintAmount) internal returns (uint, uint) {

        uint allowed = momaMaster.mintAllowed(address(this), minter, mintAmount);
        if (allowed != 0) {
            return (failOpaque(Error.MOMAMASTER_REJECTION, FailureInfo.MINT_MOMAMASTER_REJECTION, allowed), 0);
        }

        if (address(interestRateModel) != address(0) && accrualBlockNumber != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.MINT_FRESHNESS_CHECK), 0);
        }

        MintLocalVars memory vars;

        (vars.mathErr, vars.exchangeRateMantissa) = exchangeRateStoredInternal();
        if (vars.mathErr != MathError.NO_ERROR) {
            return (failOpaque(Error.MATH_ERROR, FailureInfo.MINT_EXCHANGE_RATE_READ_FAILED, uint(vars.mathErr)), 0);
        }


        vars.actualMintAmount = doTransferIn(minter, mintAmount);


        (vars.mathErr, vars.mintTokens) = divScalarByExpTruncate(vars.actualMintAmount, Exp({mantissa: vars.exchangeRateMantissa}));
        require(vars.mathErr == MathError.NO_ERROR, "MINT_EXCHANGE_CALCULATION_FAILED");
        require(vars.mintTokens > 0, "MINT_TOKENS_ZERO");

        (vars.mathErr, vars.totalSupplyNew) = addUInt(totalSupply, vars.mintTokens);
        require(vars.mathErr == MathError.NO_ERROR, "MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED");

        (vars.mathErr, vars.accountTokensNew) = addUInt(accountTokens[minter], vars.mintTokens);
        require(vars.mathErr == MathError.NO_ERROR, "MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED");

        totalSupply = vars.totalSupplyNew;
        accountTokens[minter] = vars.accountTokensNew;

        emit Mint(minter, vars.actualMintAmount, vars.mintTokens);
        emit Transfer(address(this), minter, vars.mintTokens);

        momaMaster.mintVerify(address(this), minter, vars.actualMintAmount, vars.mintTokens);

        return (uint(Error.NO_ERROR), vars.actualMintAmount);
    }

    function redeemInternal(uint redeemTokens) internal nonReentrant returns (uint) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
        }
        return redeemFresh(msg.sender, redeemTokens, 0);
    }

    function redeemUnderlyingInternal(uint redeemAmount) internal nonReentrant returns (uint) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
        }
        return redeemFresh(msg.sender, 0, redeemAmount);
    }

    struct RedeemLocalVars {
        Error err;
        MathError mathErr;
        uint exchangeRateMantissa;
        uint redeemTokens;
        uint redeemAmount;
        uint totalSupplyNew;
        uint accountTokensNew;
    }

    function redeemFresh(address payable redeemer, uint redeemTokensIn, uint redeemAmountIn) internal returns (uint) {

        require(redeemTokensIn == 0 || redeemAmountIn == 0, "one of redeemTokensIn or redeemAmountIn must be zero");

        RedeemLocalVars memory vars;

        (vars.mathErr, vars.exchangeRateMantissa) = exchangeRateStoredInternal();
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_EXCHANGE_RATE_READ_FAILED, uint(vars.mathErr));
        }

        if (redeemTokensIn > 0) {
            vars.redeemTokens = redeemTokensIn;

            (vars.mathErr, vars.redeemAmount) = mulScalarTruncate(Exp({mantissa: vars.exchangeRateMantissa}), redeemTokensIn);
            if (vars.mathErr != MathError.NO_ERROR) {
                return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED, uint(vars.mathErr));
            }
        } else {

            (vars.mathErr, vars.redeemTokens) = divScalarByExpTruncate(redeemAmountIn, Exp({mantissa: vars.exchangeRateMantissa}));
            if (vars.mathErr != MathError.NO_ERROR) {
                return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED, uint(vars.mathErr));
            }

            vars.redeemAmount = redeemAmountIn;
        }

        uint allowed = momaMaster.redeemAllowed(address(this), redeemer, vars.redeemTokens);
        if (allowed != 0) {
            return failOpaque(Error.MOMAMASTER_REJECTION, FailureInfo.REDEEM_MOMAMASTER_REJECTION, allowed);
        }

        if (address(interestRateModel) != address(0) && accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.REDEEM_FRESHNESS_CHECK);
        }

        (vars.mathErr, vars.totalSupplyNew) = subUInt(totalSupply, vars.redeemTokens);
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED, uint(vars.mathErr));
        }

        (vars.mathErr, vars.accountTokensNew) = subUInt(accountTokens[redeemer], vars.redeemTokens);
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED, uint(vars.mathErr));
        }

        if (getCashPrior() < vars.redeemAmount) {
            return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.REDEEM_TRANSFER_OUT_NOT_POSSIBLE);
        }


        doTransferOut(redeemer, vars.redeemAmount);

        totalSupply = vars.totalSupplyNew;
        accountTokens[redeemer] = vars.accountTokensNew;

        emit Transfer(redeemer, address(this), vars.redeemTokens);
        emit Redeem(redeemer, vars.redeemAmount, vars.redeemTokens);

        momaMaster.redeemVerify(address(this), redeemer, vars.redeemAmount, vars.redeemTokens);

        return uint(Error.NO_ERROR);
    }

    function borrowInternal(uint borrowAmount) internal nonReentrant returns (uint) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.BORROW_ACCRUE_INTEREST_FAILED);
        }
        return borrowFresh(msg.sender, borrowAmount);
    }

    struct BorrowLocalVars {
        MathError mathErr;
        uint accountBorrows;
        uint accountBorrowsNew;
        uint totalBorrowsNew;
    }

    function borrowFresh(address payable borrower, uint borrowAmount) internal returns (uint) {

        uint allowed = momaMaster.borrowAllowed(address(this), borrower, borrowAmount);
        if (allowed != 0) {
            return failOpaque(Error.MOMAMASTER_REJECTION, FailureInfo.BORROW_MOMAMASTER_REJECTION, allowed);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.BORROW_FRESHNESS_CHECK);
        }

        if (getCashPrior() < borrowAmount) {
            return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.BORROW_CASH_NOT_AVAILABLE);
        }

        BorrowLocalVars memory vars;

        (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(borrower);
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED, uint(vars.mathErr));
        }

        (vars.mathErr, vars.accountBorrowsNew) = addUInt(vars.accountBorrows, borrowAmount);
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED, uint(vars.mathErr));
        }

        (vars.mathErr, vars.totalBorrowsNew) = addUInt(totalBorrows, borrowAmount);
        if (vars.mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED, uint(vars.mathErr));
        }


        doTransferOut(borrower, borrowAmount);

        accountBorrows[borrower].principal = vars.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;

        emit Borrow(borrower, borrowAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);

        momaMaster.borrowVerify(address(this), borrower, borrowAmount);

        return uint(Error.NO_ERROR);
    }

    function repayBorrowInternal(uint repayAmount) internal nonReentrant returns (uint, uint) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.REPAY_BORROW_ACCRUE_INTEREST_FAILED), 0);
        }
        return repayBorrowFresh(msg.sender, msg.sender, repayAmount);
    }

    function repayBorrowBehalfInternal(address borrower, uint repayAmount) internal nonReentrant returns (uint, uint) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.REPAY_BEHALF_ACCRUE_INTEREST_FAILED), 0);
        }
        return repayBorrowFresh(msg.sender, borrower, repayAmount);
    }

    struct RepayBorrowLocalVars {
        Error err;
        MathError mathErr;
        uint repayAmount;
        uint borrowerIndex;
        uint accountBorrows;
        uint accountBorrowsNew;
        uint totalBorrowsNew;
        uint actualRepayAmount;
    }

    function repayBorrowFresh(address payer, address borrower, uint repayAmount) internal returns (uint, uint) {

        uint allowed = momaMaster.repayBorrowAllowed(address(this), payer, borrower, repayAmount);
        if (allowed != 0) {
            return (failOpaque(Error.MOMAMASTER_REJECTION, FailureInfo.REPAY_BORROW_MOMAMASTER_REJECTION, allowed), 0);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.REPAY_BORROW_FRESHNESS_CHECK), 0);
        }

        RepayBorrowLocalVars memory vars;

        vars.borrowerIndex = accountBorrows[borrower].interestIndex;

        (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(borrower);
        if (vars.mathErr != MathError.NO_ERROR) {
            return (failOpaque(Error.MATH_ERROR, FailureInfo.REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED, uint(vars.mathErr)), 0);
        }

        if (repayAmount == uint(-1)) {
            vars.repayAmount = vars.accountBorrows;
        } else {
            vars.repayAmount = repayAmount;
        }


        vars.actualRepayAmount = doTransferIn(payer, vars.repayAmount);

        (vars.mathErr, vars.accountBorrowsNew) = subUInt(vars.accountBorrows, vars.actualRepayAmount);
        require(vars.mathErr == MathError.NO_ERROR, "REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED");

        (vars.mathErr, vars.totalBorrowsNew) = subUInt(totalBorrows, vars.actualRepayAmount);
        require(vars.mathErr == MathError.NO_ERROR, "REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED");

        accountBorrows[borrower].principal = vars.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;

        emit RepayBorrow(payer, borrower, vars.actualRepayAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);

        momaMaster.repayBorrowVerify(address(this), payer, borrower, vars.actualRepayAmount, vars.borrowerIndex);

        return (uint(Error.NO_ERROR), vars.actualRepayAmount);
    }

    function liquidateBorrowInternal(address borrower, uint repayAmount, MTokenInterface mTokenCollateral) internal nonReentrant returns (uint, uint) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED), 0);
        }

        error = mTokenCollateral.accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED), 0);
        }

        return liquidateBorrowFresh(msg.sender, borrower, repayAmount, mTokenCollateral);
    }

    function liquidateBorrowFresh(address liquidator, address borrower, uint repayAmount, MTokenInterface mTokenCollateral) internal returns (uint, uint) {

        uint allowed = momaMaster.liquidateBorrowAllowed(address(this), address(mTokenCollateral), liquidator, borrower, repayAmount);
        if (allowed != 0) {
            return (failOpaque(Error.MOMAMASTER_REJECTION, FailureInfo.LIQUIDATE_MOMAMASTER_REJECTION, allowed), 0);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.LIQUIDATE_FRESHNESS_CHECK), 0);
        }

        if (mTokenCollateral.accrualBlockNumber() != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.LIQUIDATE_COLLATERAL_FRESHNESS_CHECK), 0);
        }

        if (borrower == liquidator) {
            return (fail(Error.INVALID_ACCOUNT_PAIR, FailureInfo.LIQUIDATE_LIQUIDATOR_IS_BORROWER), 0);
        }

        if (repayAmount == 0) {
            return (fail(Error.INVALID_CLOSE_AMOUNT_REQUESTED, FailureInfo.LIQUIDATE_CLOSE_AMOUNT_IS_ZERO), 0);
        }

        if (repayAmount == uint(-1)) {
            return (fail(Error.INVALID_CLOSE_AMOUNT_REQUESTED, FailureInfo.LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX), 0);
        }


        (uint repayBorrowError, uint actualRepayAmount) = repayBorrowFresh(liquidator, borrower, repayAmount);
        if (repayBorrowError != uint(Error.NO_ERROR)) {
            return (fail(Error(repayBorrowError), FailureInfo.LIQUIDATE_REPAY_BORROW_FRESH_FAILED), 0);
        }


        (uint amountSeizeError, uint seizeTokens) = momaMaster.liquidateCalculateSeizeTokens(address(this), address(mTokenCollateral), actualRepayAmount);
        require(amountSeizeError == uint(Error.NO_ERROR), "LIQUIDATE_MOMAMASTER_CALCULATE_AMOUNT_SEIZE_FAILED");

        require(mTokenCollateral.balanceOf(borrower) >= seizeTokens, "LIQUIDATE_SEIZE_TOO_MUCH");

        uint seizeError;
        if (address(mTokenCollateral) == address(this)) {
            seizeError = seizeInternal(address(this), liquidator, borrower, seizeTokens);
        } else {
            seizeError = mTokenCollateral.seize(liquidator, borrower, seizeTokens);
        }

        require(seizeError == uint(Error.NO_ERROR), "token seizure failed");

        emit LiquidateBorrow(liquidator, borrower, actualRepayAmount, address(mTokenCollateral), seizeTokens);

        momaMaster.liquidateBorrowVerify(address(this), address(mTokenCollateral), liquidator, borrower, actualRepayAmount, seizeTokens);

        return (uint(Error.NO_ERROR), actualRepayAmount);
    }

    function seize(address liquidator, address borrower, uint seizeTokens) external nonReentrant returns (uint) {

        return seizeInternal(msg.sender, liquidator, borrower, seizeTokens);
    }

    function seizeInternal(address seizerToken, address liquidator, address borrower, uint seizeTokens) internal returns (uint) {

        uint allowed = momaMaster.seizeAllowed(address(this), seizerToken, liquidator, borrower, seizeTokens);
        if (allowed != 0) {
            return failOpaque(Error.MOMAMASTER_REJECTION, FailureInfo.LIQUIDATE_SEIZE_MOMAMASTER_REJECTION, allowed);
        }

        if (borrower == liquidator) {
            return fail(Error.INVALID_ACCOUNT_PAIR, FailureInfo.LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER);
        }

        MathError mathErr;
        uint borrowerTokensNew;
        uint liquidatorTokensNew;

        (mathErr, borrowerTokensNew) = subUInt(accountTokens[borrower], seizeTokens);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED, uint(mathErr));
        }

        (mathErr, liquidatorTokensNew) = addUInt(accountTokens[liquidator], seizeTokens);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED, uint(mathErr));
        }


        accountTokens[borrower] = borrowerTokensNew;
        accountTokens[liquidator] = liquidatorTokensNew;

        emit Transfer(borrower, liquidator, seizeTokens);

        momaMaster.seizeVerify(address(this), seizerToken, liquidator, borrower, seizeTokens);

        return uint(Error.NO_ERROR);
    }



    function _setFeeReceiver(address payable newFeeReceiver) external returns (uint) {

        if (msg.sender != momaMaster.admin()) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_FEE_RECEIVER_OWNER_CHECK);
        }

        if (newFeeReceiver == address(0)) {
            return fail(Error.BAD_INPUT, FailureInfo.SET_FEE_RECEIVER_ADDRESS_VALIDATION);
        }

        address oldFeeReceiver = feeReceiver;

        feeReceiver = newFeeReceiver;

        emit NewFeeReceiver(oldFeeReceiver, newFeeReceiver);

        return uint(Error.NO_ERROR);
    }

    function _setFeeFactor(uint newFeeFactorMantissa) external nonReentrant returns (uint) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.SET_FEE_FACTOR_ACCRUE_INTEREST_FAILED);
        }
        return _setFeeFactorFresh(newFeeFactorMantissa);
    }

    function _setFeeFactorFresh(uint newFeeFactorMantissa) internal returns (uint) {

        if (msg.sender != momaMaster.admin()) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_FEE_FACTOR_ADMIN_CHECK);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.SET_FEE_FACTOR_FRESH_CHECK);
        }

        if (newFeeFactorMantissa > feeFactorMaxMantissa) {
            return fail(Error.BAD_INPUT, FailureInfo.SET_FEE_FACTOR_BOUNDS_CHECK);
        }

        uint oldFeeFactorMantissa = feeFactorMantissa;
        feeFactorMantissa = newFeeFactorMantissa;

        emit NewFeeFactor(oldFeeFactorMantissa, newFeeFactorMantissa);

        return uint(Error.NO_ERROR);
    }

    function _collectFees(uint collectAmount) external nonReentrant returns (uint) {

        if (totalFees == 0) {
            if (collectAmount == uint(-1)) {
                return uint(Error.NO_ERROR);
            }
            return fail(Error.BAD_INPUT, FailureInfo.COLLECT_FEES_VALIDATION);
        }

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.COLLECT_FEES_ACCRUE_INTEREST_FAILED);
        }
        return _collectFeesFresh(collectAmount);
    }

    function _collectFeesFresh(uint collectAmount) internal returns (uint) {

        _collectMomaFeesFresh(totalMomaFees);

        if (collectAmount == uint(-1)) {
            collectAmount = totalFees; // is this safe?
        }

        if (collectAmount == 0) {
            return uint(Error.NO_ERROR);
        }

        uint totalFeesNew;

        if (msg.sender != momaMaster.admin() && msg.sender != feeReceiver) {
            return fail(Error.UNAUTHORIZED, FailureInfo.COLLECT_FEES_ADMIN_CHECK);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.COLLECT_FEES_FRESH_CHECK);
        }

        if (getCashPrior() < collectAmount) {
            return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.COLLECT_FEES_CASH_NOT_AVAILABLE);
        }

        if (collectAmount > totalFees) {
            return fail(Error.BAD_INPUT, FailureInfo.COLLECT_FEES_VALIDATION);
        }


        totalFeesNew = totalFees - collectAmount;
        require(totalFeesNew <= totalFees, "collect fees unexpected underflow");

        totalFees = totalFeesNew;

        doTransferOut(feeReceiver, collectAmount);

        emit FeesCollected(feeReceiver, collectAmount, totalFeesNew);

        return uint(Error.NO_ERROR);
    }

    function _collectMomaFees(uint collectAmount) external nonReentrant returns (uint) {

        if (totalMomaFees == 0) {
            if (collectAmount == uint(-1)) {
                return uint(Error.NO_ERROR);
            }
            return fail(Error.BAD_INPUT, FailureInfo.COLLECT_MOMA_FEES_VALIDATION);
        }
        
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.COLLECT_MOMA_FEES_ACCRUE_INTEREST_FAILED);
        }

        MomaFactoryInterface fct = factory();
        address momaFeeAdmin = fct.getMomaFeeAdmin(address(momaMaster));
        address payable momaFeeReceiver = fct.getMomaFeeReceiver(address(momaMaster));
        if (msg.sender != momaFeeAdmin && msg.sender != momaFeeReceiver) {
            return fail(Error.UNAUTHORIZED, FailureInfo.COLLECT_MOMA_FEES_ADMIN_CHECK);
        }
        return _collectMomaFeesFresh(collectAmount);
    }

    function _collectMomaFeesFresh(uint collectAmount) internal returns (uint) {

        if (collectAmount == uint(-1)) {
            collectAmount = totalMomaFees; // is this safe?
        }

        if (collectAmount == 0) {
            return uint(Error.NO_ERROR);
        }

        uint totalMomaFeesNew;

        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.COLLECT_MOMA_FEES_FRESH_CHECK);
        }

        if (getCashPrior() < collectAmount) {
            return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.COLLECT_MOMA_FEES_CASH_NOT_AVAILABLE);
        }

        if (collectAmount > totalMomaFees) {
            return fail(Error.BAD_INPUT, FailureInfo.COLLECT_MOMA_FEES_VALIDATION);
        }

        address payable momaFeeReceiver = factory().getMomaFeeReceiver(address(momaMaster));


        totalMomaFeesNew = totalMomaFees - collectAmount;
        require(totalMomaFeesNew <= totalMomaFees, "collect moma fees unexpected underflow");

        totalMomaFees = totalMomaFeesNew;

        doTransferOut(momaFeeReceiver, collectAmount);

        emit MomaFeesCollected(momaFeeReceiver, collectAmount, totalMomaFeesNew);

        return uint(Error.NO_ERROR);
    }

    function _setReserveFactor(uint newReserveFactorMantissa) external nonReentrant returns (uint) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED);
        }
        return _setReserveFactorFresh(newReserveFactorMantissa);
    }

    function _setReserveFactorFresh(uint newReserveFactorMantissa) internal returns (uint) {

        if (msg.sender != momaMaster.admin()) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_RESERVE_FACTOR_ADMIN_CHECK);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.SET_RESERVE_FACTOR_FRESH_CHECK);
        }

        if (newReserveFactorMantissa > reserveFactorMaxMantissa) {
            return fail(Error.BAD_INPUT, FailureInfo.SET_RESERVE_FACTOR_BOUNDS_CHECK);
        }

        uint oldReserveFactorMantissa = reserveFactorMantissa;
        reserveFactorMantissa = newReserveFactorMantissa;

        emit NewReserveFactor(oldReserveFactorMantissa, newReserveFactorMantissa);

        return uint(Error.NO_ERROR);
    }

    function _addReservesInternal(uint addAmount) internal nonReentrant returns (uint) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.ADD_RESERVES_ACCRUE_INTEREST_FAILED);
        }

        (error, ) = _addReservesFresh(addAmount);
        return error;
    }

    function _addReservesFresh(uint addAmount) internal returns (uint, uint) {

        uint totalReservesNew;
        uint actualAddAmount;

        if (accrualBlockNumber != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.ADD_RESERVES_FRESH_CHECK), actualAddAmount);
        }



        actualAddAmount = doTransferIn(msg.sender, addAmount);

        totalReservesNew = totalReserves + actualAddAmount;

        require(totalReservesNew >= totalReserves, "add reserves unexpected overflow");

        totalReserves = totalReservesNew;

        emit ReservesAdded(msg.sender, actualAddAmount, totalReservesNew);

        return (uint(Error.NO_ERROR), actualAddAmount);
    }


    function _reduceReserves(uint reduceAmount) external nonReentrant returns (uint) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDUCE_RESERVES_ACCRUE_INTEREST_FAILED);
        }
        return _reduceReservesFresh(reduceAmount);
    }

    function _reduceReservesFresh(uint reduceAmount) internal returns (uint) {

        uint totalReservesNew;

        address payable momaMasterAdmin = momaMaster.admin();
        if (msg.sender != momaMasterAdmin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.REDUCE_RESERVES_ADMIN_CHECK);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.REDUCE_RESERVES_FRESH_CHECK);
        }

        if (getCashPrior() < reduceAmount) {
            return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.REDUCE_RESERVES_CASH_NOT_AVAILABLE);
        }

        if (reduceAmount > totalReserves) {
            return fail(Error.BAD_INPUT, FailureInfo.REDUCE_RESERVES_VALIDATION);
        }


        totalReservesNew = totalReserves - reduceAmount;
        require(totalReservesNew <= totalReserves, "reduce reserves unexpected underflow");

        totalReserves = totalReservesNew;

        doTransferOut(momaMasterAdmin, reduceAmount);

        emit ReservesReduced(momaMasterAdmin, reduceAmount, totalReservesNew);

        return uint(Error.NO_ERROR);
    }

    function _setInterestRateModel(InterestRateModel newInterestRateModel) external returns (uint) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED);
        }
        return _setInterestRateModelFresh(newInterestRateModel);
    }

    function _setInterestRateModelFresh(InterestRateModel newInterestRateModel) internal returns (uint) {


        InterestRateModel oldInterestRateModel;

        if (msg.sender != momaMaster.admin()) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_INTEREST_RATE_MODEL_OWNER_CHECK);
        }

        if (address(interestRateModel) != address(0) && accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.SET_INTEREST_RATE_MODEL_FRESH_CHECK);
        }

        oldInterestRateModel = interestRateModel;

        require(newInterestRateModel.isInterestRateModel(), "marker method returned false");

        interestRateModel = newInterestRateModel;

        emit NewMarketInterestRateModel(oldInterestRateModel, newInterestRateModel);

        if (accrualBlockNumber == 0 && borrowIndex == 0) {
            accrualBlockNumber = getBlockNumber();
            borrowIndex = mantissaOne;
        }

        return uint(Error.NO_ERROR);
    }


    function getCashPrior() internal view returns (uint);


    function getMomaFeeFactorMantissa() internal view returns (uint);


    function doTransferIn(address from, uint amount) internal returns (uint);


    function doTransferOut(address payable to, uint amount) internal;




    modifier nonReentrant() {

        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true; // get a gas-refund post-Istanbul
    }
}
pragma solidity 0.5.17;


contract PriceOracle {

    bool public constant isPriceOracle = true;

    function getUnderlyingPrice(MToken mToken) external view returns (uint);

}
pragma solidity 0.5.17;


contract MomaPoolAdminStorage {

    address public factory;

    address public admin;

    address public pendingAdmin;

    address public momaMasterImplementation;

    address public pendingMomaMasterImplementation;

    uint public closeFactorMantissa = 0.5e18;

    uint public liquidationIncentiveMantissa = 1.1e18;
}


contract MomaMasterV1Storage is MomaPoolAdminStorage {


    PriceOracle public oracle;

    uint public maxAssets;

    bool public isLendingPool;

    mapping(address => MToken[]) public accountAssets;


    struct Market {
        bool isListed;

        uint collateralFactorMantissa;

        mapping(address => bool) accountMembership;

    }

    mapping(address => Market) public markets;


    address public pauseGuardian;
    bool public transferGuardianPaused;
    bool public seizeGuardianPaused;
    mapping(address => bool) public mintGuardianPaused;
    mapping(address => bool) public borrowGuardianPaused;


    struct MarketState {
        uint224 index;

        uint32 block;
    }

    MToken[] public allMarkets;



    mapping(address => uint) public borrowCaps;



    struct TokenFarmState {
        uint32 startBlock;

        uint32 endBlock;

        mapping(address => uint) speeds;

        mapping(address => MarketState) supplyState;

        mapping(address => MarketState) borrowState;

        mapping(address => mapping(address => uint)) supplierIndex;

        mapping(address => mapping(address => uint)) borrowerIndex;

        mapping(address => uint) accrued;

        mapping(address => bool) isTokenMarket;

        MToken[] tokenMarkets;
    }

    mapping(address => TokenFarmState) public farmStates;

    address[] public allTokens;

}
pragma solidity 0.5.17;


 
contract FarmingDelegate is MomaMasterV1Storage, MomaMasterErrorReporter, ExponentialNoError {


    event TokenSpeedUpdated(address indexed token, MToken indexed mToken, uint oldSpeed, uint newSpeed);

    event DistributedSupplierToken(address indexed token, MToken indexed mToken, address indexed supplier, uint tokenDelta, uint tokenSupplyIndex);

    event DistributedBorrowerToken(address indexed token, MToken indexed mToken, address indexed borrower, uint tokenDelta, uint tokenBorrowIndex);

    event TokenClaimed(address indexed token, address indexed user, uint accrued, uint claimed, uint notClaimed);

     event TokenFarmUpdated(EIP20Interface token, uint oldStart, uint oldEnd, uint newStart, uint newEnd);

    event NewTokenMarket(address indexed token, MToken indexed mToken);

    event TokenGranted(address token, address recipient, uint amount);

    uint224 public constant momaInitialIndex = 1e36;

    bool public constant isFarmingDelegate = true;



    function newTokenSupplyIndexInternal(address token, address mToken) internal view returns (uint224, uint32) {

        MarketState storage supplyState = farmStates[token].supplyState[mToken];
        uint224 _index = supplyState.index;
        uint32 _block = supplyState.block;
        uint blockNumber = getBlockNumber();
        uint32 endBlock = farmStates[token].endBlock;

        if (blockNumber > uint(_block) && blockNumber > uint(farmStates[token].startBlock) && _block < endBlock) {
            uint supplySpeed = farmStates[token].speeds[mToken];
            if (blockNumber > uint(endBlock)) blockNumber = uint(endBlock);
            uint deltaBlocks = sub_(blockNumber, uint(_block)); // deltaBlocks will always > 0
            uint tokenAccrued = mul_(deltaBlocks, supplySpeed);
            uint supplyTokens = MToken(mToken).totalSupply();
            Double memory ratio = supplyTokens > 0 ? fraction(tokenAccrued, supplyTokens) : Double({mantissa: 0});
            Double memory index = add_(Double({mantissa: _index}), ratio);
            _index = safe224(index.mantissa, "new index exceeds 224 bits");
            _block = safe32(blockNumber, "block number exceeds 32 bits");
        }
        return (_index, _block);
    }

    function updateTokenSupplyIndexInternal(address token, address mToken) internal {

        if (farmStates[token].speeds[mToken] > 0) {
            (uint224 _index, uint32 _block) = newTokenSupplyIndexInternal(token, mToken);

            MarketState storage supplyState = farmStates[token].supplyState[mToken];
            supplyState.index = _index;
            supplyState.block = _block;
        }
    }

    function newTokenBorrowIndexInternal(address token, address mToken, uint marketBorrowIndex) internal view returns (uint224, uint32) {

        MarketState storage borrowState = farmStates[token].borrowState[mToken];
        uint224 _index = borrowState.index;
        uint32 _block = borrowState.block;
        uint blockNumber = getBlockNumber();
        uint32 endBlock = farmStates[token].endBlock;

        if (blockNumber > uint(_block) && blockNumber > uint(farmStates[token].startBlock) && _block < endBlock) {
            uint borrowSpeed = farmStates[token].speeds[mToken];
            if (blockNumber > uint(endBlock)) blockNumber = uint(endBlock);
            uint deltaBlocks = sub_(blockNumber, uint(_block)); // deltaBlocks will always > 0
            uint tokenAccrued = mul_(deltaBlocks, borrowSpeed);
            uint borrowAmount = div_(MToken(mToken).totalBorrows(), Exp({mantissa: marketBorrowIndex}));
            Double memory ratio = borrowAmount > 0 ? fraction(tokenAccrued, borrowAmount) : Double({mantissa: 0});
            Double memory index = add_(Double({mantissa: _index}), ratio);
            _index = safe224(index.mantissa, "new index exceeds 224 bits");
            _block = safe32(blockNumber, "block number exceeds 32 bits");
        }
        return (_index, _block);
    }

    function updateTokenBorrowIndexInternal(address token, address mToken, uint marketBorrowIndex) internal {

        if (isLendingPool == true && farmStates[token].speeds[mToken] > 0 && marketBorrowIndex > 0) {
            (uint224 _index, uint32 _block) = newTokenBorrowIndexInternal(token, mToken, marketBorrowIndex);
            
            MarketState storage borrowState = farmStates[token].borrowState[mToken];
            borrowState.index = _index;
            borrowState.block = _block;
        }
    }

    function newSupplierTokenInternal(address token, address mToken, address supplier, Double memory supplyIndex) internal view returns (uint, uint) {

        TokenFarmState storage state = farmStates[token];
        Double memory supplierIndex = Double({mantissa: state.supplierIndex[mToken][supplier]});
        uint _supplierAccrued = state.accrued[supplier];
        uint supplierDelta = 0;

        if (supplierIndex.mantissa == 0 && supplyIndex.mantissa > 0) {
            supplierIndex.mantissa = momaInitialIndex;
        }

        Double memory deltaIndex = sub_(supplyIndex, supplierIndex);
        uint supplierTokens = MToken(mToken).balanceOf(supplier);
        supplierDelta = mul_(supplierTokens, deltaIndex);
        _supplierAccrued = add_(_supplierAccrued, supplierDelta);
        return (_supplierAccrued, supplierDelta);
    }

    function distributeSupplierTokenInternal(address token, address mToken, address supplier) internal {

        TokenFarmState storage state = farmStates[token];
        if (state.supplyState[mToken].index > state.supplierIndex[mToken][supplier]) {
            Double memory supplyIndex = Double({mantissa: state.supplyState[mToken].index});
            (uint _supplierAccrued, uint supplierDelta) = newSupplierTokenInternal(token, mToken, supplier, supplyIndex);

            state.supplierIndex[mToken][supplier] = supplyIndex.mantissa;
            state.accrued[supplier] = _supplierAccrued;
            emit DistributedSupplierToken(token, MToken(mToken), supplier, supplierDelta, supplyIndex.mantissa);
        }
    }

    function newBorrowerTokenInternal(address token, address mToken, address borrower, uint marketBorrowIndex, Double memory borrowIndex) internal view returns (uint, uint) {

        TokenFarmState storage state = farmStates[token];
        Double memory borrowerIndex = Double({mantissa: state.borrowerIndex[mToken][borrower]});
        uint _borrowerAccrued = state.accrued[borrower];
        uint borrowerDelta = 0;

        if (borrowerIndex.mantissa > 0) {
            Double memory deltaIndex = sub_(borrowIndex, borrowerIndex);
            uint borrowerAmount = div_(MToken(mToken).borrowBalanceStored(borrower), Exp({mantissa: marketBorrowIndex}));
            borrowerDelta = mul_(borrowerAmount, deltaIndex);
            _borrowerAccrued = add_(_borrowerAccrued, borrowerDelta);
        }
        return (_borrowerAccrued, borrowerDelta);
    }

    function distributeBorrowerTokenInternal(address token, address mToken, address borrower, uint marketBorrowIndex) internal {

        TokenFarmState storage state = farmStates[token];
        if (isLendingPool == true && state.borrowState[mToken].index > state.borrowerIndex[mToken][borrower] && marketBorrowIndex > 0) {
            Double memory borrowIndex = Double({mantissa: state.borrowState[mToken].index});
            (uint _borrowerAccrued, uint borrowerDelta) = newBorrowerTokenInternal(token, mToken, borrower, marketBorrowIndex, borrowIndex);

            state.borrowerIndex[mToken][borrower] = borrowIndex.mantissa;
            state.accrued[borrower] = _borrowerAccrued;
            emit DistributedBorrowerToken(token, MToken(mToken), borrower, borrowerDelta, borrowIndex.mantissa);
        }
    }

    function grantTokenInternal(address token, address user, uint amount) internal returns (uint) {

        EIP20Interface erc20 = EIP20Interface(token);
        uint tokenRemaining = erc20.balanceOf(address(this));
        if (amount > 0 && amount <= tokenRemaining) {
            erc20.transfer(user, amount);
            return 0;
        }
        return amount;
    }


    function claim(address user, address token) internal {

        uint accrued = farmStates[token].accrued[user];
        uint notClaimed = grantTokenInternal(token, user, accrued);
        farmStates[token].accrued[user] = notClaimed;
        uint claimed = sub_(accrued, notClaimed);
        emit TokenClaimed(token, user, accrued, claimed, notClaimed);
    }

    function distribute(address user, address token, MToken[] memory mTokens, bool suppliers, bool borrowers) internal {

        for (uint i = 0; i < mTokens.length; i++) {
            address mToken = address(mTokens[i]);
            
            if (suppliers == true) {
                updateTokenSupplyIndexInternal(token, mToken);
                distributeSupplierTokenInternal(token, mToken, user);
            }

            if (borrowers == true && isLendingPool == true) {
                uint borrowIndex = MToken(mToken).borrowIndex();
                updateTokenBorrowIndexInternal(token, mToken, borrowIndex);
                distributeBorrowerTokenInternal(token, mToken, user, borrowIndex);
            }
        }
    }



    function updateTokenSupplyIndex(address token, address mToken) external {

        updateTokenSupplyIndexInternal(token, mToken);
    }

    function updateTokenBorrowIndex(address token, address mToken, uint marketBorrowIndex) external {

        updateTokenBorrowIndexInternal(token, mToken, marketBorrowIndex);
    }

    function distributeSupplierToken(address token, address mToken, address supplier) external {

        distributeSupplierTokenInternal(token, mToken, supplier);
    }

    function distributeBorrowerToken(address token, address mToken, address borrower, uint marketBorrowIndex) external {

        distributeBorrowerTokenInternal(token, mToken, borrower, marketBorrowIndex);
    }

    function dclaim(address token, MToken[] memory mTokens, bool suppliers, bool borrowers) public {

        distribute(msg.sender, token, mTokens, suppliers, borrowers);
        claim(msg.sender, token);
    }

    function dclaim(address token, bool suppliers, bool borrowers) public {

        distribute(msg.sender, token, farmStates[token].tokenMarkets, suppliers, borrowers);
        claim(msg.sender, token);
    }

    function dclaim(address[] memory tokens, bool suppliers, bool borrowers) public {

        for (uint i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            distribute(msg.sender, token, farmStates[token].tokenMarkets, suppliers, borrowers);
            claim(msg.sender, token);
        }
    }

    function dclaim(bool suppliers, bool borrowers) public {

        for (uint i = 0; i < allTokens.length; i++) {
            address token = allTokens[i];
            distribute(msg.sender, token, farmStates[token].tokenMarkets, suppliers, borrowers);
            claim(msg.sender, token);
        }
    }

    function claim(address token) public {

        claim(msg.sender, token);
    }

    function claim() public {

        for (uint i = 0; i < allTokens.length; i++) {
            claim(msg.sender, allTokens[i]);
        }
    }


    function undistributed(address user, address token, address mToken, bool suppliers, bool borrowers) public view returns (uint) {

        uint accrued;
        uint224 _index;
        TokenFarmState storage state = farmStates[token];
        if (suppliers == true) {
            if (state.speeds[mToken] > 0) {
                (_index, ) = newTokenSupplyIndexInternal(token, mToken);
            } else {
                _index = state.supplyState[mToken].index;
            }
            if (uint(_index) > state.supplierIndex[mToken][user]) {
                (, accrued) = newSupplierTokenInternal(token, mToken, user, Double({mantissa: _index}));
            }
        }

        if (borrowers == true && isLendingPool == true) {
            uint marketBorrowIndex = MToken(mToken).borrowIndex();
            if (marketBorrowIndex > 0) {
                if (state.speeds[mToken] > 0) {
                    (_index, ) = newTokenBorrowIndexInternal(token, mToken, marketBorrowIndex);
                } else {
                    _index = state.borrowState[mToken].index;
                }
                if (uint(_index) > state.borrowerIndex[mToken][user]) {
                    (, uint _borrowerDelta) = newBorrowerTokenInternal(token, mToken, user, marketBorrowIndex, Double({mantissa: _index}));
                    accrued = add_(accrued, _borrowerDelta);
                }
            }
        }
        return accrued;
    }

    function undistributed(address user, address token, bool suppliers, bool borrowers) public view returns (uint[] memory) {

        MToken[] memory mTokens = farmStates[token].tokenMarkets;
        uint[] memory accrued = new uint[](mTokens.length);
        for (uint i = 0; i < mTokens.length; i++) {
            accrued[i] = undistributed(user, token, address(mTokens[i]), suppliers, borrowers);
        }
        return accrued;
    }



    function _grantToken(address token, address recipient, uint amount) public {

        require(msg.sender == admin, "only admin can grant token");

        uint amountLeft = grantTokenInternal(token, recipient, amount);
        require(amountLeft == 0, "insufficient token for grant");
        emit TokenGranted(token, recipient, amount);
    }

    function _setTokenFarm(EIP20Interface token, uint start, uint end) public returns (uint) {

        require(msg.sender == admin, "only admin can add farm token");
        require(end > start, "end less than start");

        TokenFarmState storage state = farmStates[address(token)];
        uint oldStartBlock = uint(state.startBlock);
        uint oldEndBlock = uint(state.endBlock);
        uint blockNumber = getBlockNumber();
        require(blockNumber > oldEndBlock, "not first set or this round is not end");
        require(start > blockNumber, "start must largger than this block number");

        uint32 newStart = safe32(start, "start block number exceeds 32 bits");

        if (oldStartBlock == 0 && oldEndBlock == 0) {
            token.totalSupply(); // sanity check it
            allTokens.push(address(token));
        } else {
            for (uint i = 0; i < state.tokenMarkets.length; i++) {
                MToken mToken = state.tokenMarkets[i];

                uint borrowIndex = mToken.borrowIndex();
                updateTokenSupplyIndexInternal(address(token), address(mToken));
                updateTokenBorrowIndexInternal(address(token), address(mToken), borrowIndex);

                state.supplyState[address(mToken)].block = newStart;
                state.borrowState[address(mToken)].block = newStart;
            }
        }

        state.startBlock = newStart;
        state.endBlock = safe32(end, "end block number exceeds 32 bits");
        emit TokenFarmUpdated(token, oldStartBlock, oldEndBlock, start, end);

        return uint(Error.NO_ERROR);
    }

    function _setTokensSpeed(address token, MToken[] memory mTokens, uint[] memory newSpeeds) public {

        require(msg.sender == admin, "only admin can set tokens speed");

        TokenFarmState storage state = farmStates[token];
        require(state.startBlock > 0, "token not added");
        require(mTokens.length == newSpeeds.length, "param length dismatch");

        uint32 blockNumber = safe32(getBlockNumber(), "block number exceeds 32 bits");
        if (state.startBlock > blockNumber) blockNumber = state.startBlock;

        for (uint i = 0; i < mTokens.length; i++) {
            MToken mToken = mTokens[i];

            if (!state.isTokenMarket[address(mToken)]) {
                require(markets[address(mToken)].isListed == true, "market is not listed");
                state.isTokenMarket[address(mToken)] = true;
                state.tokenMarkets.push(mToken);
                emit NewTokenMarket(token, mToken);

                state.supplyState[address(mToken)].index = momaInitialIndex;
                state.borrowState[address(mToken)].index = momaInitialIndex;
            } else {
                uint borrowIndex = mToken.borrowIndex();
                updateTokenSupplyIndexInternal(token, address(mToken));
                updateTokenBorrowIndexInternal(token, address(mToken), borrowIndex);
            }

            uint oldSpeed = state.speeds[address(mToken)];
            state.supplyState[address(mToken)].block = blockNumber;
            state.borrowState[address(mToken)].block = blockNumber;
            if (oldSpeed != newSpeeds[i]) {
                state.speeds[address(mToken)] = newSpeeds[i];
                emit TokenSpeedUpdated(token, mToken, oldSpeed, newSpeeds[i]);
            }
        }
    }


    function getBlockNumber() public view returns (uint) {

        return block.number;
    }
}
pragma solidity 0.5.17;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction underflow");
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

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

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
