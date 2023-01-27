pragma solidity ^0.5.16;


contract PriceOracle {

    function getUnderlyingPrice(CToken cToken) external view returns (uint256);

}pragma solidity ^0.5.16;


contract UnitrollerAdminStorage {

    address public admin;

    address public pendingAdmin;

    address public comptrollerImplementation;

    address public pendingComptrollerImplementation;
}

contract ComptrollerV1Storage is UnitrollerAdminStorage {

    PriceOracle public oracle;

    uint256 public closeFactorMantissa;

    uint256 public liquidationIncentiveMantissa;

    mapping(address => CToken[]) public accountAssets;

    enum Version {
        VANILLA,
        COLLATERALCAP,
        WRAPPEDNATIVE
    }

    struct Market {
        bool isListed;
        uint256 collateralFactorMantissa;
        mapping(address => bool) accountMembership;
        Version version;
    }

    mapping(address => Market) public markets;

    address public pauseGuardian;
    bool public _mintGuardianPaused;
    bool public _borrowGuardianPaused;
    bool public transferGuardianPaused;
    bool public seizeGuardianPaused;
    mapping(address => bool) public mintGuardianPaused;
    mapping(address => bool) public borrowGuardianPaused;

    struct CompMarketState {
        uint224 index;
        uint32 block;
    }

    CToken[] public allMarkets;

    mapping(address => uint256) public compSpeeds;

    mapping(address => CompMarketState) public compSupplyState;

    mapping(address => CompMarketState) public compBorrowState;

    mapping(address => mapping(address => uint256)) public compSupplierIndex;

    mapping(address => mapping(address => uint256)) public compBorrowerIndex;

    mapping(address => uint256) public compAccrued;

    address public borrowCapGuardian;

    mapping(address => uint256) public borrowCaps;

    address public supplyCapGuardian;

    mapping(address => uint256) public supplyCaps;

    mapping(address => uint256) public creditLimits;

    mapping(address => bool) public flashloanGuardianPaused;

    address public liquidityMining;
}pragma solidity ^0.5.16;


contract ComptrollerInterface {

    bool public constant isComptroller = true;


    function enterMarkets(address[] calldata cTokens) external returns (uint256[] memory);


    function exitMarket(address cToken) external returns (uint256);



    function mintAllowed(
        address cToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256);


    function mintVerify(
        address cToken,
        address minter,
        uint256 mintAmount,
        uint256 mintTokens
    ) external;


    function redeemAllowed(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256);


    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external;


    function borrowAllowed(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);


    function borrowVerify(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external;


    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);


    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 borrowerIndex
    ) external;


    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);


    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount,
        uint256 seizeTokens
    ) external;


    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);


    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external;


    function transferAllowed(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external returns (uint256);


    function transferVerify(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;



    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 repayAmount
    ) external view returns (uint256, uint256);

}

interface ComptrollerInterfaceExtension {

    function checkMembership(address account, CToken cToken) external view returns (bool);


    function updateCTokenVersion(address cToken, ComptrollerV1Storage.Version version) external;


    function flashloanAllowed(
        address cToken,
        address receiver,
        uint256 amount,
        bytes calldata params
    ) external view returns (bool);

}pragma solidity ^0.5.16;

contract InterestRateModel {

    bool public constant isInterestRateModel = true;

    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256);


    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) external view returns (uint256);

}pragma solidity ^0.5.16;

interface ERC3156FlashBorrowerInterface {

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);

}pragma solidity ^0.5.16;


contract CTokenStorage {

    bool internal _notEntered;

    string public name;

    string public symbol;

    uint8 public decimals;


    uint256 internal constant borrowRateMaxMantissa = 0.0005e16;

    uint256 internal constant reserveFactorMaxMantissa = 1e18;

    address payable public admin;

    address payable public pendingAdmin;

    ComptrollerInterface public comptroller;

    InterestRateModel public interestRateModel;

    uint256 internal initialExchangeRateMantissa;

    uint256 public reserveFactorMantissa;

    uint256 public accrualBlockNumber;

    uint256 public borrowIndex;

    uint256 public totalBorrows;

    uint256 public totalReserves;

    uint256 public totalSupply;

    mapping(address => uint256) internal accountTokens;

    mapping(address => mapping(address => uint256)) internal transferAllowances;

    struct BorrowSnapshot {
        uint256 principal;
        uint256 interestIndex;
    }

    mapping(address => BorrowSnapshot) internal accountBorrows;
}

contract CErc20Storage {

    address public underlying;

    address public implementation;
}

contract CSupplyCapStorage {

    uint256 public internalCash;
}

contract CCollateralCapStorage {

    uint256 public totalCollateralTokens;

    mapping(address => uint256) public accountCollateralTokens;

    mapping(address => bool) public isCollateralTokenInit;

    uint256 public collateralCap;
}


contract CTokenInterface is CTokenStorage {

    bool public constant isCToken = true;


    event AccrueInterest(uint256 cashPrior, uint256 interestAccumulated, uint256 borrowIndex, uint256 totalBorrows);

    event Mint(address minter, uint256 mintAmount, uint256 mintTokens);

    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

    event Borrow(address borrower, uint256 borrowAmount, uint256 accountBorrows, uint256 totalBorrows);

    event RepayBorrow(
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );

    event LiquidateBorrow(
        address liquidator,
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral,
        uint256 seizeTokens
    );


    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);

    event NewComptroller(ComptrollerInterface oldComptroller, ComptrollerInterface newComptroller);

    event NewMarketInterestRateModel(InterestRateModel oldInterestRateModel, InterestRateModel newInterestRateModel);

    event NewReserveFactor(uint256 oldReserveFactorMantissa, uint256 newReserveFactorMantissa);

    event ReservesAdded(address benefactor, uint256 addAmount, uint256 newTotalReserves);

    event ReservesReduced(address admin, uint256 reduceAmount, uint256 newTotalReserves);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event Failure(uint256 error, uint256 info, uint256 detail);


    function transfer(address dst, uint256 amount) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function balanceOfUnderlying(address owner) external returns (uint256);


    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function borrowRatePerBlock() external view returns (uint256);


    function supplyRatePerBlock() external view returns (uint256);


    function totalBorrowsCurrent() external returns (uint256);


    function borrowBalanceCurrent(address account) external returns (uint256);


    function borrowBalanceStored(address account) public view returns (uint256);


    function exchangeRateCurrent() public returns (uint256);


    function exchangeRateStored() public view returns (uint256);


    function getCash() external view returns (uint256);


    function accrueInterest() public returns (uint256);


    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);



    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint256);


    function _acceptAdmin() external returns (uint256);


    function _setComptroller(ComptrollerInterface newComptroller) public returns (uint256);


    function _setReserveFactor(uint256 newReserveFactorMantissa) external returns (uint256);


    function _reduceReserves(uint256 reduceAmount) external returns (uint256);


    function _setInterestRateModel(InterestRateModel newInterestRateModel) public returns (uint256);

}

contract CErc20Interface is CErc20Storage {


    function mint(uint256 mintAmount) external returns (uint256);


    function redeem(uint256 redeemTokens) external returns (uint256);


    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);


    function borrow(uint256 borrowAmount) external returns (uint256);


    function repayBorrow(uint256 repayAmount) external returns (uint256);


    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        CTokenInterface cTokenCollateral
    ) external returns (uint256);


    function _addReserves(uint256 addAmount) external returns (uint256);

}

contract CWrappedNativeInterface is CErc20Interface {

    uint256 public constant flashFeeBips = 3;


    event Flashloan(address indexed receiver, uint256 amount, uint256 totalFee, uint256 reservesFee);


    function mintNative() external payable returns (uint256);


    function redeemNative(uint256 redeemTokens) external returns (uint256);


    function redeemUnderlyingNative(uint256 redeemAmount) external returns (uint256);


    function borrowNative(uint256 borrowAmount) external returns (uint256);


    function repayBorrowNative() external payable returns (uint256);


    function liquidateBorrowNative(address borrower, CTokenInterface cTokenCollateral)
        external
        payable
        returns (uint256);


    function flashLoan(
        ERC3156FlashBorrowerInterface receiver,
        address initiator,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);


    function _addReservesNative() external payable returns (uint256);

}

contract CCapableErc20Interface is CErc20Interface, CSupplyCapStorage {

    uint256 public constant flashFeeBips = 3;


    event Flashloan(address indexed receiver, uint256 amount, uint256 totalFee, uint256 reservesFee);


    function gulp() external;

}

contract CCollateralCapErc20Interface is CCapableErc20Interface, CCollateralCapStorage {


    event NewCollateralCap(address token, uint256 newCap);

    event UserCollateralChanged(address account, uint256 newCollateralTokens);


    function registerCollateral(address account) external returns (uint256);


    function unregisterCollateral(address account) external;


    function flashLoan(
        ERC3156FlashBorrowerInterface receiver,
        address initiator,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);



    function _setCollateralCap(uint256 newCollateralCap) external;

}

contract CDelegatorInterface {

    event NewImplementation(address oldImplementation, address newImplementation);

    function _setImplementation(
        address implementation_,
        bool allowResign,
        bytes memory becomeImplementationData
    ) public;

}

contract CDelegateInterface {

    function _becomeImplementation(bytes memory data) public;


    function _resignImplementation() public;

}


interface IFlashloanReceiver {

    function executeOperation(
        address sender,
        address underlying,
        uint256 amount,
        uint256 fee,
        bytes calldata params
    ) external;

}pragma solidity ^0.5.16;

contract ComptrollerErrorReporter {

    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        COMPTROLLER_MISMATCH,
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

    event Failure(uint256 error, uint256 info, uint256 detail);

    function fail(Error err, FailureInfo info) internal returns (uint256) {

        emit Failure(uint256(err), uint256(info), 0);

        return uint256(err);
    }

    function failOpaque(
        Error err,
        FailureInfo info,
        uint256 opaqueError
    ) internal returns (uint256) {

        emit Failure(uint256(err), uint256(info), opaqueError);

        return uint256(err);
    }
}

contract TokenErrorReporter {

    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        BAD_INPUT,
        COMPTROLLER_REJECTION,
        COMPTROLLER_CALCULATION_ERROR,
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
        ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED,
        BORROW_ACCRUE_INTEREST_FAILED,
        BORROW_CASH_NOT_AVAILABLE,
        BORROW_FRESHNESS_CHECK,
        BORROW_MARKET_NOT_LISTED,
        BORROW_COMPTROLLER_REJECTION,
        LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED,
        LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED,
        LIQUIDATE_COLLATERAL_FRESHNESS_CHECK,
        LIQUIDATE_COMPTROLLER_REJECTION,
        LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED,
        LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX,
        LIQUIDATE_CLOSE_AMOUNT_IS_ZERO,
        LIQUIDATE_FRESHNESS_CHECK,
        LIQUIDATE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_REPAY_BORROW_FRESH_FAILED,
        LIQUIDATE_SEIZE_COMPTROLLER_REJECTION,
        LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_SEIZE_TOO_MUCH,
        MINT_ACCRUE_INTEREST_FAILED,
        MINT_COMPTROLLER_REJECTION,
        MINT_FRESHNESS_CHECK,
        MINT_TRANSFER_IN_FAILED,
        MINT_TRANSFER_IN_NOT_POSSIBLE,
        REDEEM_ACCRUE_INTEREST_FAILED,
        REDEEM_COMPTROLLER_REJECTION,
        REDEEM_FRESHNESS_CHECK,
        REDEEM_TRANSFER_OUT_NOT_POSSIBLE,
        REDUCE_RESERVES_ACCRUE_INTEREST_FAILED,
        REDUCE_RESERVES_ADMIN_CHECK,
        REDUCE_RESERVES_CASH_NOT_AVAILABLE,
        REDUCE_RESERVES_FRESH_CHECK,
        REDUCE_RESERVES_VALIDATION,
        REPAY_BORROW_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_COMPTROLLER_REJECTION,
        REPAY_BORROW_FRESHNESS_CHECK,
        REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COMPTROLLER_OWNER_CHECK,
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
        TRANSFER_COMPTROLLER_REJECTION,
        TRANSFER_NOT_ALLOWED,
        ADD_RESERVES_ACCRUE_INTEREST_FAILED,
        ADD_RESERVES_FRESH_CHECK,
        ADD_RESERVES_TRANSFER_IN_NOT_POSSIBLE
    }

    event Failure(uint256 error, uint256 info, uint256 detail);

    function fail(Error err, FailureInfo info) internal returns (uint256) {

        emit Failure(uint256(err), uint256(info), 0);

        return uint256(err);
    }

    function failOpaque(
        Error err,
        FailureInfo info,
        uint256 opaqueError
    ) internal returns (uint256) {

        emit Failure(uint256(err), uint256(info), opaqueError);

        return uint256(err);
    }
}pragma solidity ^0.5.16;

contract CarefulMath {

    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }

    function mulUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {

        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint256 c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    function divUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {

        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    function subUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {

        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    function addUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {

        uint256 c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    function addThenSubUInt(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (MathError, uint256) {

        (MathError err0, uint256 sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}pragma solidity ^0.5.16;


contract Exponential is CarefulMath {

    uint256 constant expScale = 1e18;
    uint256 constant doubleScale = 1e36;
    uint256 constant halfExpScale = expScale / 2;
    uint256 constant mantissaOne = expScale;

    struct Exp {
        uint256 mantissa;
    }

    struct Double {
        uint256 mantissa;
    }

    function getExp(uint256 num, uint256 denom) internal pure returns (MathError, Exp memory) {

        (MathError err0, uint256 scaledNumerator) = mulUInt(num, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint256 rational) = divUInt(scaledNumerator, denom);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    function addExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {

        (MathError error, uint256 result) = addUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    function subExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {

        (MathError error, uint256 result) = subUInt(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    function mulScalar(Exp memory a, uint256 scalar) internal pure returns (MathError, Exp memory) {

        (MathError err0, uint256 scaledMantissa) = mulUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    function mulScalarTruncate(Exp memory a, uint256 scalar) internal pure returns (MathError, uint256) {

        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(product));
    }

    function mulScalarTruncateAddUInt(
        Exp memory a,
        uint256 scalar,
        uint256 addend
    ) internal pure returns (MathError, uint256) {

        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return addUInt(truncate(product), addend);
    }

    function mul_ScalarTruncate(Exp memory a, uint256 scalar) internal pure returns (uint256) {

        Exp memory product = mul_(a, scalar);
        return truncate(product);
    }

    function mul_ScalarTruncateAddUInt(
        Exp memory a,
        uint256 scalar,
        uint256 addend
    ) internal pure returns (uint256) {

        Exp memory product = mul_(a, scalar);
        return add_(truncate(product), addend);
    }

    function divScalar(Exp memory a, uint256 scalar) internal pure returns (MathError, Exp memory) {

        (MathError err0, uint256 descaledMantissa) = divUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }

    function divScalarByExp(uint256 scalar, Exp memory divisor) internal pure returns (MathError, Exp memory) {

        (MathError err0, uint256 numerator) = mulUInt(expScale, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    function divScalarByExpTruncate(uint256 scalar, Exp memory divisor) internal pure returns (MathError, uint256) {

        (MathError err, Exp memory fraction) = divScalarByExp(scalar, divisor);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(fraction));
    }

    function div_ScalarByExp(uint256 scalar, Exp memory divisor) internal pure returns (Exp memory) {

        uint256 numerator = mul_(expScale, scalar);
        return Exp({mantissa: div_(numerator, divisor)});
    }

    function div_ScalarByExpTruncate(uint256 scalar, Exp memory divisor) internal pure returns (uint256) {

        Exp memory fraction = div_ScalarByExp(scalar, divisor);
        return truncate(fraction);
    }

    function mulExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {

        (MathError err0, uint256 doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint256 doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (MathError err2, uint256 product) = divUInt(doubleScaledProductWithHalfScale, expScale);
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({mantissa: product}));
    }

    function mulExp(uint256 a, uint256 b) internal pure returns (MathError, Exp memory) {

        return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
    }

    function mulExp3(
        Exp memory a,
        Exp memory b,
        Exp memory c
    ) internal pure returns (MathError, Exp memory) {

        (MathError err, Exp memory ab) = mulExp(a, b);
        if (err != MathError.NO_ERROR) {
            return (err, ab);
        }
        return mulExp(ab, c);
    }

    function divExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {

        return getExp(a.mantissa, b.mantissa);
    }

    function truncate(Exp memory exp) internal pure returns (uint256) {

        return exp.mantissa / expScale;
    }

    function lessThanExp(Exp memory left, Exp memory right) internal pure returns (bool) {

        return left.mantissa < right.mantissa;
    }

    function lessThanOrEqualExp(Exp memory left, Exp memory right) internal pure returns (bool) {

        return left.mantissa <= right.mantissa;
    }

    function isZeroExp(Exp memory value) internal pure returns (bool) {

        return value.mantissa == 0;
    }

    function safe224(uint256 n, string memory errorMessage) internal pure returns (uint224) {

        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {

        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) internal pure returns (Double memory) {

        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint256 a, uint256 b) internal pure returns (uint256) {

        return add_(a, b, "addition overflow");
    }

    function add_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {

        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) internal pure returns (Double memory) {

        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub_(a, b, "subtraction underflow");
    }

    function sub_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {

        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint256 b) internal pure returns (Exp memory) {

        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint256 a, Exp memory b) internal pure returns (uint256) {

        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) internal pure returns (Double memory) {

        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint256 b) internal pure returns (Double memory) {

        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint256 a, Double memory b) internal pure returns (uint256) {

        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint256 a, uint256 b) internal pure returns (uint256) {

        return mul_(a, b, "multiplication overflow");
    }

    function mul_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) internal pure returns (Exp memory) {

        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint256 b) internal pure returns (Exp memory) {

        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint256 a, Exp memory b) internal pure returns (uint256) {

        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) internal pure returns (Double memory) {

        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint256 b) internal pure returns (Double memory) {

        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint256 a, Double memory b) internal pure returns (uint256) {

        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint256 a, uint256 b) internal pure returns (uint256) {

        return div_(a, b, "divide by zero");
    }

    function div_(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint256 a, uint256 b) internal pure returns (Double memory) {

        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }

    function sqrt(uint256 x) internal pure returns (uint256) {

        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;

        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }

        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}pragma solidity ^0.5.16;

interface EIP20Interface {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256 balance);


    function transfer(address dst, uint256 amount) external returns (bool success);


    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool success);


    function approve(address spender, uint256 amount) external returns (bool success);


    function allowance(address owner, address spender) external view returns (uint256 remaining);


    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}pragma solidity ^0.5.16;

interface EIP20NonStandardInterface {

    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256 balance);



    function transfer(address dst, uint256 amount) external;



    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external;


    function approve(address spender, uint256 amount) external returns (bool success);


    function allowance(address owner, address spender) external view returns (uint256 remaining);


    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}pragma solidity ^0.5.16;


contract CToken is CTokenInterface, Exponential, TokenErrorReporter {

    function initialize(
        ComptrollerInterface comptroller_,
        InterestRateModel interestRateModel_,
        uint256 initialExchangeRateMantissa_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) public {

        require(msg.sender == admin, "only admin may initialize the market");
        require(accrualBlockNumber == 0 && borrowIndex == 0, "market may only be initialized once");

        initialExchangeRateMantissa = initialExchangeRateMantissa_;
        require(initialExchangeRateMantissa > 0, "initial exchange rate must be greater than zero.");

        uint256 err = _setComptroller(comptroller_);
        require(err == uint256(Error.NO_ERROR), "setting comptroller failed");

        accrualBlockNumber = getBlockNumber();
        borrowIndex = mantissaOne;

        err = _setInterestRateModelFresh(interestRateModel_);
        require(err == uint256(Error.NO_ERROR), "setting interest rate model failed");

        name = name_;
        symbol = symbol_;
        decimals = decimals_;

        _notEntered = true;
    }

    function transfer(address dst, uint256 amount) external nonReentrant returns (bool) {

        return transferTokens(msg.sender, msg.sender, dst, amount) == uint256(Error.NO_ERROR);
    }

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external nonReentrant returns (bool) {

        return transferTokens(msg.sender, src, dst, amount) == uint256(Error.NO_ERROR);
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

    function balanceOfUnderlying(address owner) external returns (uint256) {

        Exp memory exchangeRate = Exp({mantissa: exchangeRateCurrent()});
        return mul_ScalarTruncate(exchangeRate, accountTokens[owner]);
    }

    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        uint256 cTokenBalance = getCTokenBalanceInternal(account);
        uint256 borrowBalance = borrowBalanceStoredInternal(account);
        uint256 exchangeRateMantissa = exchangeRateStoredInternal();

        return (uint256(Error.NO_ERROR), cTokenBalance, borrowBalance, exchangeRateMantissa);
    }

    function getBlockNumber() internal view returns (uint256) {

        return block.number;
    }

    function borrowRatePerBlock() external view returns (uint256) {

        return interestRateModel.getBorrowRate(getCashPrior(), totalBorrows, totalReserves);
    }

    function supplyRatePerBlock() external view returns (uint256) {

        return interestRateModel.getSupplyRate(getCashPrior(), totalBorrows, totalReserves, reserveFactorMantissa);
    }

    function estimateBorrowRatePerBlockAfterChange(uint256 change, bool repay) external view returns (uint256) {

        uint256 cashPriorNew;
        uint256 totalBorrowsNew;

        if (repay) {
            cashPriorNew = add_(getCashPrior(), change);
            totalBorrowsNew = sub_(totalBorrows, change);
        } else {
            cashPriorNew = sub_(getCashPrior(), change);
            totalBorrowsNew = add_(totalBorrows, change);
        }
        return interestRateModel.getBorrowRate(cashPriorNew, totalBorrowsNew, totalReserves);
    }

    function estimateSupplyRatePerBlockAfterChange(uint256 change, bool repay) external view returns (uint256) {

        uint256 cashPriorNew;
        uint256 totalBorrowsNew;

        if (repay) {
            cashPriorNew = add_(getCashPrior(), change);
            totalBorrowsNew = sub_(totalBorrows, change);
        } else {
            cashPriorNew = sub_(getCashPrior(), change);
            totalBorrowsNew = add_(totalBorrows, change);
        }

        return interestRateModel.getSupplyRate(cashPriorNew, totalBorrowsNew, totalReserves, reserveFactorMantissa);
    }

    function totalBorrowsCurrent() external nonReentrant returns (uint256) {

        require(accrueInterest() == uint256(Error.NO_ERROR), "accrue interest failed");
        return totalBorrows;
    }

    function borrowBalanceCurrent(address account) external nonReentrant returns (uint256) {

        require(accrueInterest() == uint256(Error.NO_ERROR), "accrue interest failed");
        return borrowBalanceStored(account);
    }

    function borrowBalanceStored(address account) public view returns (uint256) {

        return borrowBalanceStoredInternal(account);
    }

    function borrowBalanceStoredInternal(address account) internal view returns (uint256) {

        BorrowSnapshot storage borrowSnapshot = accountBorrows[account];

        if (borrowSnapshot.principal == 0) {
            return 0;
        }

        uint256 principalTimesIndex = mul_(borrowSnapshot.principal, borrowIndex);
        uint256 result = div_(principalTimesIndex, borrowSnapshot.interestIndex);
        return result;
    }

    function exchangeRateCurrent() public nonReentrant returns (uint256) {

        require(accrueInterest() == uint256(Error.NO_ERROR), "accrue interest failed");
        return exchangeRateStored();
    }

    function exchangeRateStored() public view returns (uint256) {

        return exchangeRateStoredInternal();
    }

    function exchangeRateStoredInternal() internal view returns (uint256) {

        uint256 _totalSupply = totalSupply;
        if (_totalSupply == 0) {
            return initialExchangeRateMantissa;
        } else {
            uint256 totalCash = getCashPrior();
            uint256 cashPlusBorrowsMinusReserves = sub_(add_(totalCash, totalBorrows), totalReserves);
            uint256 exchangeRate = div_(cashPlusBorrowsMinusReserves, Exp({mantissa: _totalSupply}));
            return exchangeRate;
        }
    }

    function getCash() external view returns (uint256) {

        return getCashPrior();
    }

    function accrueInterest() public returns (uint256) {

        uint256 currentBlockNumber = getBlockNumber();
        uint256 accrualBlockNumberPrior = accrualBlockNumber;

        if (accrualBlockNumberPrior == currentBlockNumber) {
            return uint256(Error.NO_ERROR);
        }

        uint256 cashPrior = getCashPrior();
        uint256 borrowsPrior = totalBorrows;
        uint256 reservesPrior = totalReserves;
        uint256 borrowIndexPrior = borrowIndex;

        uint256 borrowRateMantissa = interestRateModel.getBorrowRate(cashPrior, borrowsPrior, reservesPrior);
        require(borrowRateMantissa <= borrowRateMaxMantissa, "borrow rate is absurdly high");

        uint256 blockDelta = sub_(currentBlockNumber, accrualBlockNumberPrior);


        Exp memory simpleInterestFactor = mul_(Exp({mantissa: borrowRateMantissa}), blockDelta);
        uint256 interestAccumulated = mul_ScalarTruncate(simpleInterestFactor, borrowsPrior);
        uint256 totalBorrowsNew = add_(interestAccumulated, borrowsPrior);
        uint256 totalReservesNew = mul_ScalarTruncateAddUInt(
            Exp({mantissa: reserveFactorMantissa}),
            interestAccumulated,
            reservesPrior
        );
        uint256 borrowIndexNew = mul_ScalarTruncateAddUInt(simpleInterestFactor, borrowIndexPrior, borrowIndexPrior);


        accrualBlockNumber = currentBlockNumber;
        borrowIndex = borrowIndexNew;
        totalBorrows = totalBorrowsNew;
        totalReserves = totalReservesNew;

        emit AccrueInterest(cashPrior, interestAccumulated, borrowIndexNew, totalBorrowsNew);

        return uint256(Error.NO_ERROR);
    }

    function mintInternal(uint256 mintAmount, bool isNative) internal nonReentrant returns (uint256, uint256) {

        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.MINT_ACCRUE_INTEREST_FAILED), 0);
        }
        return mintFresh(msg.sender, mintAmount, isNative);
    }

    function redeemInternal(uint256 redeemTokens, bool isNative) internal nonReentrant returns (uint256) {

        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
        }
        return redeemFresh(msg.sender, redeemTokens, 0, isNative);
    }

    function redeemUnderlyingInternal(uint256 redeemAmount, bool isNative) internal nonReentrant returns (uint256) {

        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
        }
        return redeemFresh(msg.sender, 0, redeemAmount, isNative);
    }

    function borrowInternal(uint256 borrowAmount, bool isNative) internal nonReentrant returns (uint256) {

        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.BORROW_ACCRUE_INTEREST_FAILED);
        }
        return borrowFresh(msg.sender, borrowAmount, isNative);
    }

    struct BorrowLocalVars {
        MathError mathErr;
        uint256 accountBorrows;
        uint256 accountBorrowsNew;
        uint256 totalBorrowsNew;
    }

    function borrowFresh(
        address payable borrower,
        uint256 borrowAmount,
        bool isNative
    ) internal returns (uint256) {

        uint256 allowed = comptroller.borrowAllowed(address(this), borrower, borrowAmount);
        if (allowed != 0) {
            return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.BORROW_COMPTROLLER_REJECTION, allowed);
        }

        if (borrowAmount == 0) {
            accountBorrows[borrower].interestIndex = borrowIndex;
            return uint256(Error.NO_ERROR);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.BORROW_FRESHNESS_CHECK);
        }

        if (getCashPrior() < borrowAmount) {
            return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.BORROW_CASH_NOT_AVAILABLE);
        }

        BorrowLocalVars memory vars;

        vars.accountBorrows = borrowBalanceStoredInternal(borrower);
        vars.accountBorrowsNew = add_(vars.accountBorrows, borrowAmount);
        vars.totalBorrowsNew = add_(totalBorrows, borrowAmount);


        doTransferOut(borrower, borrowAmount, isNative);

        accountBorrows[borrower].principal = vars.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;

        emit Borrow(borrower, borrowAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);


        return uint256(Error.NO_ERROR);
    }

    function repayBorrowInternal(uint256 repayAmount, bool isNative) internal nonReentrant returns (uint256, uint256) {

        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.REPAY_BORROW_ACCRUE_INTEREST_FAILED), 0);
        }
        return repayBorrowFresh(msg.sender, msg.sender, repayAmount, isNative);
    }

    struct RepayBorrowLocalVars {
        Error err;
        MathError mathErr;
        uint256 repayAmount;
        uint256 borrowerIndex;
        uint256 accountBorrows;
        uint256 accountBorrowsNew;
        uint256 totalBorrowsNew;
        uint256 actualRepayAmount;
    }

    function repayBorrowFresh(
        address payer,
        address borrower,
        uint256 repayAmount,
        bool isNative
    ) internal returns (uint256, uint256) {

        uint256 allowed = comptroller.repayBorrowAllowed(address(this), payer, borrower, repayAmount);
        if (allowed != 0) {
            return (
                failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.REPAY_BORROW_COMPTROLLER_REJECTION, allowed),
                0
            );
        }

        if (repayAmount == 0) {
            accountBorrows[borrower].interestIndex = borrowIndex;
            return (uint256(Error.NO_ERROR), 0);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.REPAY_BORROW_FRESHNESS_CHECK), 0);
        }

        RepayBorrowLocalVars memory vars;

        vars.borrowerIndex = accountBorrows[borrower].interestIndex;

        vars.accountBorrows = borrowBalanceStoredInternal(borrower);

        if (repayAmount == uint256(-1)) {
            vars.repayAmount = vars.accountBorrows;
        } else {
            vars.repayAmount = repayAmount;
        }


        vars.actualRepayAmount = doTransferIn(payer, vars.repayAmount, isNative);

        vars.accountBorrowsNew = sub_(vars.accountBorrows, vars.actualRepayAmount);
        vars.totalBorrowsNew = sub_(totalBorrows, vars.actualRepayAmount);

        accountBorrows[borrower].principal = vars.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;

        emit RepayBorrow(payer, borrower, vars.actualRepayAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);


        return (uint256(Error.NO_ERROR), vars.actualRepayAmount);
    }

    function liquidateBorrowInternal(
        address borrower,
        uint256 repayAmount,
        CTokenInterface cTokenCollateral,
        bool isNative
    ) internal nonReentrant returns (uint256, uint256) {

        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED), 0);
        }

        error = cTokenCollateral.accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED), 0);
        }

        return liquidateBorrowFresh(msg.sender, borrower, repayAmount, cTokenCollateral, isNative);
    }

    function liquidateBorrowFresh(
        address liquidator,
        address borrower,
        uint256 repayAmount,
        CTokenInterface cTokenCollateral,
        bool isNative
    ) internal returns (uint256, uint256) {

        uint256 allowed = comptroller.liquidateBorrowAllowed(
            address(this),
            address(cTokenCollateral),
            liquidator,
            borrower,
            repayAmount
        );
        if (allowed != 0) {
            return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.LIQUIDATE_COMPTROLLER_REJECTION, allowed), 0);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.LIQUIDATE_FRESHNESS_CHECK), 0);
        }

        if (cTokenCollateral.accrualBlockNumber() != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.LIQUIDATE_COLLATERAL_FRESHNESS_CHECK), 0);
        }

        if (borrower == liquidator) {
            return (fail(Error.INVALID_ACCOUNT_PAIR, FailureInfo.LIQUIDATE_LIQUIDATOR_IS_BORROWER), 0);
        }

        if (repayAmount == 0) {
            return (fail(Error.INVALID_CLOSE_AMOUNT_REQUESTED, FailureInfo.LIQUIDATE_CLOSE_AMOUNT_IS_ZERO), 0);
        }

        if (repayAmount == uint256(-1)) {
            return (fail(Error.INVALID_CLOSE_AMOUNT_REQUESTED, FailureInfo.LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX), 0);
        }

        (uint256 repayBorrowError, uint256 actualRepayAmount) = repayBorrowFresh(
            liquidator,
            borrower,
            repayAmount,
            isNative
        );
        if (repayBorrowError != uint256(Error.NO_ERROR)) {
            return (fail(Error(repayBorrowError), FailureInfo.LIQUIDATE_REPAY_BORROW_FRESH_FAILED), 0);
        }


        (uint256 amountSeizeError, uint256 seizeTokens) = comptroller.liquidateCalculateSeizeTokens(
            address(this),
            address(cTokenCollateral),
            actualRepayAmount
        );
        require(amountSeizeError == uint256(Error.NO_ERROR), "LIQUIDATE_COMPTROLLER_CALCULATE_AMOUNT_SEIZE_FAILED");

        require(cTokenCollateral.balanceOf(borrower) >= seizeTokens, "LIQUIDATE_SEIZE_TOO_MUCH");

        uint256 seizeError;
        if (address(cTokenCollateral) == address(this)) {
            seizeError = seizeInternal(address(this), liquidator, borrower, seizeTokens);
        } else {
            seizeError = cTokenCollateral.seize(liquidator, borrower, seizeTokens);
        }

        require(seizeError == uint256(Error.NO_ERROR), "token seizure failed");

        emit LiquidateBorrow(liquidator, borrower, actualRepayAmount, address(cTokenCollateral), seizeTokens);


        return (uint256(Error.NO_ERROR), actualRepayAmount);
    }

    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external nonReentrant returns (uint256) {

        return seizeInternal(msg.sender, liquidator, borrower, seizeTokens);
    }


    function _setPendingAdmin(address payable newPendingAdmin) external returns (uint256) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_ADMIN_OWNER_CHECK);
        }

        address oldPendingAdmin = pendingAdmin;

        pendingAdmin = newPendingAdmin;

        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);

        return uint256(Error.NO_ERROR);
    }

    function _acceptAdmin() external returns (uint256) {

        if (msg.sender != pendingAdmin || msg.sender == address(0)) {
            return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_ADMIN_PENDING_ADMIN_CHECK);
        }

        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        admin = pendingAdmin;

        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);

        return uint256(Error.NO_ERROR);
    }

    function _setComptroller(ComptrollerInterface newComptroller) public returns (uint256) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_COMPTROLLER_OWNER_CHECK);
        }

        ComptrollerInterface oldComptroller = comptroller;
        require(newComptroller.isComptroller(), "marker method returned false");

        comptroller = newComptroller;

        emit NewComptroller(oldComptroller, newComptroller);

        return uint256(Error.NO_ERROR);
    }

    function _setReserveFactor(uint256 newReserveFactorMantissa) external nonReentrant returns (uint256) {

        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED);
        }
        return _setReserveFactorFresh(newReserveFactorMantissa);
    }

    function _setReserveFactorFresh(uint256 newReserveFactorMantissa) internal returns (uint256) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_RESERVE_FACTOR_ADMIN_CHECK);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.SET_RESERVE_FACTOR_FRESH_CHECK);
        }

        if (newReserveFactorMantissa > reserveFactorMaxMantissa) {
            return fail(Error.BAD_INPUT, FailureInfo.SET_RESERVE_FACTOR_BOUNDS_CHECK);
        }

        uint256 oldReserveFactorMantissa = reserveFactorMantissa;
        reserveFactorMantissa = newReserveFactorMantissa;

        emit NewReserveFactor(oldReserveFactorMantissa, newReserveFactorMantissa);

        return uint256(Error.NO_ERROR);
    }

    function _addReservesInternal(uint256 addAmount, bool isNative) internal nonReentrant returns (uint256) {

        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.ADD_RESERVES_ACCRUE_INTEREST_FAILED);
        }

        (error, ) = _addReservesFresh(addAmount, isNative);
        return error;
    }

    function _addReservesFresh(uint256 addAmount, bool isNative) internal returns (uint256, uint256) {

        uint256 totalReservesNew;
        uint256 actualAddAmount;

        if (accrualBlockNumber != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.ADD_RESERVES_FRESH_CHECK), actualAddAmount);
        }



        actualAddAmount = doTransferIn(msg.sender, addAmount, isNative);

        totalReservesNew = add_(totalReserves, actualAddAmount);

        totalReserves = totalReservesNew;

        emit ReservesAdded(msg.sender, actualAddAmount, totalReservesNew);

        return (uint256(Error.NO_ERROR), actualAddAmount);
    }

    function _reduceReserves(uint256 reduceAmount) external nonReentrant returns (uint256) {

        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDUCE_RESERVES_ACCRUE_INTEREST_FAILED);
        }
        return _reduceReservesFresh(reduceAmount);
    }

    function _reduceReservesFresh(uint256 reduceAmount) internal returns (uint256) {

        uint256 totalReservesNew;

        if (msg.sender != admin) {
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


        totalReservesNew = sub_(totalReserves, reduceAmount);

        totalReserves = totalReservesNew;

        doTransferOut(admin, reduceAmount, true);

        emit ReservesReduced(admin, reduceAmount, totalReservesNew);

        return uint256(Error.NO_ERROR);
    }

    function _setInterestRateModel(InterestRateModel newInterestRateModel) public returns (uint256) {

        uint256 error = accrueInterest();
        if (error != uint256(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED);
        }
        return _setInterestRateModelFresh(newInterestRateModel);
    }

    function _setInterestRateModelFresh(InterestRateModel newInterestRateModel) internal returns (uint256) {

        InterestRateModel oldInterestRateModel;

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_INTEREST_RATE_MODEL_OWNER_CHECK);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.SET_INTEREST_RATE_MODEL_FRESH_CHECK);
        }

        oldInterestRateModel = interestRateModel;

        require(newInterestRateModel.isInterestRateModel(), "marker method returned false");

        interestRateModel = newInterestRateModel;

        emit NewMarketInterestRateModel(oldInterestRateModel, newInterestRateModel);

        return uint256(Error.NO_ERROR);
    }


    function getCashPrior() internal view returns (uint256);


    function doTransferIn(
        address from,
        uint256 amount,
        bool isNative
    ) internal returns (uint256);


    function doTransferOut(
        address payable to,
        uint256 amount,
        bool isNative
    ) internal;


    function transferTokens(
        address spender,
        address src,
        address dst,
        uint256 tokens
    ) internal returns (uint256);


    function getCTokenBalanceInternal(address account) internal view returns (uint256);


    function mintFresh(
        address minter,
        uint256 mintAmount,
        bool isNative
    ) internal returns (uint256, uint256);


    function redeemFresh(
        address payable redeemer,
        uint256 redeemTokensIn,
        uint256 redeemAmountIn,
        bool isNative
    ) internal returns (uint256);


    function seizeInternal(
        address seizerToken,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) internal returns (uint256);



    modifier nonReentrant() {

        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true; // get a gas-refund post-Istanbul
    }
}pragma solidity ^0.5.16;

interface ERC3156FlashLenderInterface {

    function maxFlashLoan(address token) external view returns (uint256);


    function flashFee(address token, uint256 amount) external view returns (uint256);


    function flashLoan(
        ERC3156FlashBorrowerInterface receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

}pragma solidity ^0.5.16;


contract CCollateralCapErc20 is CToken, CCollateralCapErc20Interface {

    function initialize(
        address underlying_,
        ComptrollerInterface comptroller_,
        InterestRateModel interestRateModel_,
        uint256 initialExchangeRateMantissa_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) public {

        super.initialize(comptroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_);

        underlying = underlying_;
        EIP20Interface(underlying).totalSupply();
    }


    function mint(uint256 mintAmount) external returns (uint256) {

        (uint256 err, ) = mintInternal(mintAmount, false);
        return err;
    }

    function redeem(uint256 redeemTokens) external returns (uint256) {

        return redeemInternal(redeemTokens, false);
    }

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256) {

        return redeemUnderlyingInternal(redeemAmount, false);
    }

    function borrow(uint256 borrowAmount) external returns (uint256) {

        return borrowInternal(borrowAmount, false);
    }

    function repayBorrow(uint256 repayAmount) external returns (uint256) {

        (uint256 err, ) = repayBorrowInternal(repayAmount, false);
        return err;
    }

    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        CTokenInterface cTokenCollateral
    ) external returns (uint256) {

        (uint256 err, ) = liquidateBorrowInternal(borrower, repayAmount, cTokenCollateral, false);
        return err;
    }

    function _addReserves(uint256 addAmount) external returns (uint256) {

        return _addReservesInternal(addAmount, false);
    }

    function _setCollateralCap(uint256 newCollateralCap) external {

        require(msg.sender == admin, "only admin can set collateral cap");

        collateralCap = newCollateralCap;
        emit NewCollateralCap(address(this), newCollateralCap);
    }

    function gulp() external nonReentrant {

        uint256 cashOnChain = getCashOnChain();
        uint256 cashPrior = getCashPrior();

        uint256 excessCash = sub_(cashOnChain, cashPrior);
        totalReserves = add_(totalReserves, excessCash);
        internalCash = cashOnChain;
    }

    function maxFlashLoan() external view returns (uint256) {

        uint256 amount = 0;
        if (
            ComptrollerInterfaceExtension(address(comptroller)).flashloanAllowed(address(this), address(0), amount, "")
        ) {
            amount = getCashPrior();
        }
        return amount;
    }

    function flashFee(uint256 amount) external view returns (uint256) {

        require(
            ComptrollerInterfaceExtension(address(comptroller)).flashloanAllowed(address(this), address(0), amount, ""),
            "flashloan is paused"
        );
        return div_(mul_(amount, flashFeeBips), 10000);
    }

    function flashLoan(
        ERC3156FlashBorrowerInterface receiver,
        address initiator,
        uint256 amount,
        bytes calldata data
    ) external nonReentrant returns (bool) {

        require(amount > 0, "flashLoan amount should be greater than zero");
        require(accrueInterest() == uint256(Error.NO_ERROR), "accrue interest failed");
        require(
            ComptrollerInterfaceExtension(address(comptroller)).flashloanAllowed(
                address(this),
                address(receiver),
                amount,
                data
            ),
            "flashloan is paused"
        );
        uint256 cashOnChainBefore = getCashOnChain();
        uint256 cashBefore = getCashPrior();
        require(cashBefore >= amount, "INSUFFICIENT_LIQUIDITY");

        uint256 totalFee = this.flashFee(amount);

        doTransferOut(address(uint160(address(receiver))), amount, false);

        totalBorrows = add_(totalBorrows, amount);


        require(
            receiver.onFlashLoan(initiator, underlying, amount, totalFee, data) ==
                keccak256("ERC3156FlashBorrowerInterface.onFlashLoan"),
            "IERC3156: Callback failed"
        );

        uint256 repaymentAmount = add_(amount, totalFee);
        doTransferIn(address(receiver), repaymentAmount, false);

        uint256 cashOnChainAfter = getCashOnChain();

        require(cashOnChainAfter == add_(cashOnChainBefore, totalFee), "BALANCE_INCONSISTENT");

        uint256 reservesFee = mul_ScalarTruncate(Exp({mantissa: reserveFactorMantissa}), totalFee);
        totalReserves = add_(totalReserves, reservesFee);
        internalCash = add_(cashBefore, totalFee);
        totalBorrows = sub_(totalBorrows, amount);

        emit Flashloan(address(receiver), amount, totalFee, reservesFee);
        return true;
    }

    function registerCollateral(address account) external returns (uint256) {

        initializeAccountCollateralTokens(account);

        require(msg.sender == address(comptroller), "only comptroller may register collateral for user");

        uint256 amount = sub_(accountTokens[account], accountCollateralTokens[account]);
        return increaseUserCollateralInternal(account, amount);
    }

    function unregisterCollateral(address account) external {

        initializeAccountCollateralTokens(account);

        require(msg.sender == address(comptroller), "only comptroller may unregister collateral for user");

        decreaseUserCollateralInternal(account, accountCollateralTokens[account]);
    }


    function getCashPrior() internal view returns (uint256) {

        return internalCash;
    }

    function getCashOnChain() internal view returns (uint256) {

        EIP20Interface token = EIP20Interface(underlying);
        return token.balanceOf(address(this));
    }

    function initializeAccountCollateralTokens(address account) internal {

        if (!isCollateralTokenInit[account]) {
            if (ComptrollerInterfaceExtension(address(comptroller)).checkMembership(account, CToken(this))) {
                accountCollateralTokens[account] = accountTokens[account];
                totalCollateralTokens = add_(totalCollateralTokens, accountTokens[account]);

                emit UserCollateralChanged(account, accountCollateralTokens[account]);
            }
            isCollateralTokenInit[account] = true;
        }
    }

    function doTransferIn(
        address from,
        uint256 amount,
        bool isNative
    ) internal returns (uint256) {

        isNative; // unused

        EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
        uint256 balanceBefore = EIP20Interface(underlying).balanceOf(address(this));
        token.transferFrom(from, address(this), amount);

        bool success;
        assembly {
            switch returndatasize()
            case 0 {
                success := not(0) // set success to true
            }
            case 32 {
                returndatacopy(0, 0, 32)
                success := mload(0) // Set `success = returndata` of external call
            }
            default {
                revert(0, 0)
            }
        }
        require(success, "TOKEN_TRANSFER_IN_FAILED");

        uint256 balanceAfter = EIP20Interface(underlying).balanceOf(address(this));
        uint256 transferredIn = sub_(balanceAfter, balanceBefore);
        internalCash = add_(internalCash, transferredIn);
        return transferredIn;
    }

    function doTransferOut(
        address payable to,
        uint256 amount,
        bool isNative
    ) internal {

        isNative; // unused

        EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
        token.transfer(to, amount);

        bool success;
        assembly {
            switch returndatasize()
            case 0 {
                success := not(0) // set success to true
            }
            case 32 {
                returndatacopy(0, 0, 32)
                success := mload(0) // Set `success = returndata` of external call
            }
            default {
                revert(0, 0)
            }
        }
        require(success, "TOKEN_TRANSFER_OUT_FAILED");
        internalCash = sub_(internalCash, amount);
    }

    function transferTokens(
        address spender,
        address src,
        address dst,
        uint256 tokens
    ) internal returns (uint256) {

        initializeAccountCollateralTokens(src);
        initializeAccountCollateralTokens(dst);

        uint256 bufferTokens = sub_(accountTokens[src], accountCollateralTokens[src]);
        uint256 collateralTokens = 0;
        if (tokens > bufferTokens) {
            collateralTokens = tokens - bufferTokens;
        }

        uint256 allowed = comptroller.transferAllowed(address(this), src, dst, collateralTokens);
        if (allowed != 0) {
            return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.TRANSFER_COMPTROLLER_REJECTION, allowed);
        }

        if (src == dst) {
            return fail(Error.BAD_INPUT, FailureInfo.TRANSFER_NOT_ALLOWED);
        }

        uint256 startingAllowance = 0;
        if (spender == src) {
            startingAllowance = uint256(-1);
        } else {
            startingAllowance = transferAllowances[src][spender];
        }

        accountTokens[src] = sub_(accountTokens[src], tokens);
        accountTokens[dst] = add_(accountTokens[dst], tokens);
        if (collateralTokens > 0) {
            accountCollateralTokens[src] = sub_(accountCollateralTokens[src], collateralTokens);
            accountCollateralTokens[dst] = add_(accountCollateralTokens[dst], collateralTokens);

            emit UserCollateralChanged(src, accountCollateralTokens[src]);
            emit UserCollateralChanged(dst, accountCollateralTokens[dst]);
        }

        if (startingAllowance != uint256(-1)) {
            transferAllowances[src][spender] = sub_(startingAllowance, tokens);
        }

        emit Transfer(src, dst, tokens);


        return uint256(Error.NO_ERROR);
    }

    function getCTokenBalanceInternal(address account) internal view returns (uint256) {

        if (isCollateralTokenInit[account]) {
            return accountCollateralTokens[account];
        } else {
            return accountTokens[account];
        }
    }

    function increaseUserCollateralInternal(address account, uint256 amount) internal returns (uint256) {

        uint256 totalCollateralTokensNew = add_(totalCollateralTokens, amount);
        if (collateralCap == 0 || (collateralCap != 0 && totalCollateralTokensNew <= collateralCap)) {
            totalCollateralTokens = totalCollateralTokensNew;
            accountCollateralTokens[account] = add_(accountCollateralTokens[account], amount);

            emit UserCollateralChanged(account, accountCollateralTokens[account]);
            return amount;
        } else if (collateralCap > totalCollateralTokens) {
            uint256 gap = sub_(collateralCap, totalCollateralTokens);
            totalCollateralTokens = add_(totalCollateralTokens, gap);
            accountCollateralTokens[account] = add_(accountCollateralTokens[account], gap);

            emit UserCollateralChanged(account, accountCollateralTokens[account]);
            return gap;
        }
        return 0;
    }

    function decreaseUserCollateralInternal(address account, uint256 amount) internal {

        require(comptroller.redeemAllowed(address(this), account, amount) == 0, "comptroller rejection");

        if (amount == 0) {
            return;
        }

        totalCollateralTokens = sub_(totalCollateralTokens, amount);
        accountCollateralTokens[account] = sub_(accountCollateralTokens[account], amount);

        emit UserCollateralChanged(account, accountCollateralTokens[account]);
    }

    struct MintLocalVars {
        uint256 exchangeRateMantissa;
        uint256 mintTokens;
        uint256 actualMintAmount;
    }

    function mintFresh(
        address minter,
        uint256 mintAmount,
        bool isNative
    ) internal returns (uint256, uint256) {

        initializeAccountCollateralTokens(minter);

        uint256 allowed = comptroller.mintAllowed(address(this), minter, mintAmount);
        if (allowed != 0) {
            return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.MINT_COMPTROLLER_REJECTION, allowed), 0);
        }

        if (mintAmount == 0) {
            return (uint256(Error.NO_ERROR), 0);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.MINT_FRESHNESS_CHECK), 0);
        }

        MintLocalVars memory vars;

        vars.exchangeRateMantissa = exchangeRateStoredInternal();


        vars.actualMintAmount = doTransferIn(minter, mintAmount, isNative);

        vars.mintTokens = div_ScalarByExpTruncate(vars.actualMintAmount, Exp({mantissa: vars.exchangeRateMantissa}));

        totalSupply = add_(totalSupply, vars.mintTokens);
        accountTokens[minter] = add_(accountTokens[minter], vars.mintTokens);

        if (ComptrollerInterfaceExtension(address(comptroller)).checkMembership(minter, CToken(this))) {
            increaseUserCollateralInternal(minter, vars.mintTokens);
        }

        emit Mint(minter, vars.actualMintAmount, vars.mintTokens);
        emit Transfer(address(this), minter, vars.mintTokens);


        return (uint256(Error.NO_ERROR), vars.actualMintAmount);
    }

    struct RedeemLocalVars {
        uint256 exchangeRateMantissa;
        uint256 redeemTokens;
        uint256 redeemAmount;
    }

    function redeemFresh(
        address payable redeemer,
        uint256 redeemTokensIn,
        uint256 redeemAmountIn,
        bool isNative
    ) internal returns (uint256) {

        initializeAccountCollateralTokens(redeemer);

        require(redeemTokensIn == 0 || redeemAmountIn == 0, "one of redeemTokensIn or redeemAmountIn must be zero");

        RedeemLocalVars memory vars;

        vars.exchangeRateMantissa = exchangeRateStoredInternal();

        if (redeemTokensIn > 0) {
            vars.redeemTokens = redeemTokensIn;
            vars.redeemAmount = mul_ScalarTruncate(Exp({mantissa: vars.exchangeRateMantissa}), redeemTokensIn);
        } else {
            vars.redeemTokens = div_ScalarByExpTruncate(redeemAmountIn, Exp({mantissa: vars.exchangeRateMantissa}));
            vars.redeemAmount = redeemAmountIn;
        }

        uint256 bufferTokens = sub_(accountTokens[redeemer], accountCollateralTokens[redeemer]);
        uint256 collateralTokens = 0;
        if (vars.redeemTokens > bufferTokens) {
            collateralTokens = vars.redeemTokens - bufferTokens;
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.REDEEM_FRESHNESS_CHECK);
        }

        if (getCashPrior() < vars.redeemAmount) {
            return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.REDEEM_TRANSFER_OUT_NOT_POSSIBLE);
        }


        doTransferOut(redeemer, vars.redeemAmount, isNative);

        totalSupply = sub_(totalSupply, vars.redeemTokens);
        accountTokens[redeemer] = sub_(accountTokens[redeemer], vars.redeemTokens);

        if (collateralTokens > 0) {
            decreaseUserCollateralInternal(redeemer, collateralTokens);
        }

        emit Transfer(redeemer, address(this), vars.redeemTokens);
        emit Redeem(redeemer, vars.redeemAmount, vars.redeemTokens);

        comptroller.redeemVerify(address(this), redeemer, vars.redeemAmount, vars.redeemTokens);

        return uint256(Error.NO_ERROR);
    }

    function seizeInternal(
        address seizerToken,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) internal returns (uint256) {

        initializeAccountCollateralTokens(liquidator);
        initializeAccountCollateralTokens(borrower);

        uint256 allowed = comptroller.seizeAllowed(address(this), seizerToken, liquidator, borrower, seizeTokens);
        if (allowed != 0) {
            return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.LIQUIDATE_SEIZE_COMPTROLLER_REJECTION, allowed);
        }

        if (seizeTokens == 0) {
            return uint256(Error.NO_ERROR);
        }

        if (borrower == liquidator) {
            return fail(Error.INVALID_ACCOUNT_PAIR, FailureInfo.LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER);
        }

        accountTokens[borrower] = sub_(accountTokens[borrower], seizeTokens);
        accountTokens[liquidator] = add_(accountTokens[liquidator], seizeTokens);
        accountCollateralTokens[borrower] = sub_(accountCollateralTokens[borrower], seizeTokens);
        accountCollateralTokens[liquidator] = add_(accountCollateralTokens[liquidator], seizeTokens);

        emit Transfer(borrower, liquidator, seizeTokens);
        emit UserCollateralChanged(borrower, accountCollateralTokens[borrower]);
        emit UserCollateralChanged(liquidator, accountCollateralTokens[liquidator]);


        return uint256(Error.NO_ERROR);
    }
}pragma solidity ^0.5.16;


contract CErc20 is CToken, CErc20Interface {

    function initialize(
        address underlying_,
        ComptrollerInterface comptroller_,
        InterestRateModel interestRateModel_,
        uint256 initialExchangeRateMantissa_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) public {

        super.initialize(comptroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_);

        underlying = underlying_;
        EIP20Interface(underlying).totalSupply();
    }


    function mint(uint256 mintAmount) external returns (uint256) {

        (uint256 err, ) = mintInternal(mintAmount, false);
        return err;
    }

    function redeem(uint256 redeemTokens) external returns (uint256) {

        return redeemInternal(redeemTokens, false);
    }

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256) {

        return redeemUnderlyingInternal(redeemAmount, false);
    }

    function borrow(uint256 borrowAmount) external returns (uint256) {

        return borrowInternal(borrowAmount, false);
    }

    function repayBorrow(uint256 repayAmount) external returns (uint256) {

        (uint256 err, ) = repayBorrowInternal(repayAmount, false);
        return err;
    }

    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        CTokenInterface cTokenCollateral
    ) external returns (uint256) {

        (uint256 err, ) = liquidateBorrowInternal(borrower, repayAmount, cTokenCollateral, false);
        return err;
    }

    function _addReserves(uint256 addAmount) external returns (uint256) {

        return _addReservesInternal(addAmount, false);
    }


    function getCashPrior() internal view returns (uint256) {

        EIP20Interface token = EIP20Interface(underlying);
        return token.balanceOf(address(this));
    }

    function doTransferIn(
        address from,
        uint256 amount,
        bool isNative
    ) internal returns (uint256) {

        isNative; // unused

        EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
        uint256 balanceBefore = EIP20Interface(underlying).balanceOf(address(this));
        token.transferFrom(from, address(this), amount);

        bool success;
        assembly {
            switch returndatasize()
            case 0 {
                success := not(0) // set success to true
            }
            case 32 {
                returndatacopy(0, 0, 32)
                success := mload(0) // Set `success = returndata` of external call
            }
            default {
                revert(0, 0)
            }
        }
        require(success, "TOKEN_TRANSFER_IN_FAILED");

        uint256 balanceAfter = EIP20Interface(underlying).balanceOf(address(this));
        return sub_(balanceAfter, balanceBefore);
    }

    function doTransferOut(
        address payable to,
        uint256 amount,
        bool isNative
    ) internal {

        isNative; // unused

        EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
        token.transfer(to, amount);

        bool success;
        assembly {
            switch returndatasize()
            case 0 {
                success := not(0) // set success to true
            }
            case 32 {
                returndatacopy(0, 0, 32)
                success := mload(0) // Set `success = returndata` of external call
            }
            default {
                revert(0, 0)
            }
        }
        require(success, "TOKEN_TRANSFER_OUT_FAILED");
    }

    function transferTokens(
        address spender,
        address src,
        address dst,
        uint256 tokens
    ) internal returns (uint256) {

        uint256 allowed = comptroller.transferAllowed(address(this), src, dst, tokens);
        if (allowed != 0) {
            return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.TRANSFER_COMPTROLLER_REJECTION, allowed);
        }

        if (src == dst) {
            return fail(Error.BAD_INPUT, FailureInfo.TRANSFER_NOT_ALLOWED);
        }

        uint256 startingAllowance = 0;
        if (spender == src) {
            startingAllowance = uint256(-1);
        } else {
            startingAllowance = transferAllowances[src][spender];
        }

        accountTokens[src] = sub_(accountTokens[src], tokens);
        accountTokens[dst] = add_(accountTokens[dst], tokens);

        if (startingAllowance != uint256(-1)) {
            transferAllowances[src][spender] = sub_(startingAllowance, tokens);
        }

        emit Transfer(src, dst, tokens);


        return uint256(Error.NO_ERROR);
    }

    function getCTokenBalanceInternal(address account) internal view returns (uint256) {

        return accountTokens[account];
    }

    struct MintLocalVars {
        uint256 exchangeRateMantissa;
        uint256 mintTokens;
        uint256 actualMintAmount;
    }

    function mintFresh(
        address minter,
        uint256 mintAmount,
        bool isNative
    ) internal returns (uint256, uint256) {

        uint256 allowed = comptroller.mintAllowed(address(this), minter, mintAmount);
        if (allowed != 0) {
            return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.MINT_COMPTROLLER_REJECTION, allowed), 0);
        }

        if (mintAmount == 0) {
            return (uint256(Error.NO_ERROR), 0);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return (fail(Error.MARKET_NOT_FRESH, FailureInfo.MINT_FRESHNESS_CHECK), 0);
        }

        MintLocalVars memory vars;

        vars.exchangeRateMantissa = exchangeRateStoredInternal();


        vars.actualMintAmount = doTransferIn(minter, mintAmount, isNative);

        vars.mintTokens = div_ScalarByExpTruncate(vars.actualMintAmount, Exp({mantissa: vars.exchangeRateMantissa}));

        totalSupply = add_(totalSupply, vars.mintTokens);
        accountTokens[minter] = add_(accountTokens[minter], vars.mintTokens);

        emit Mint(minter, vars.actualMintAmount, vars.mintTokens);
        emit Transfer(address(this), minter, vars.mintTokens);


        return (uint256(Error.NO_ERROR), vars.actualMintAmount);
    }

    struct RedeemLocalVars {
        uint256 exchangeRateMantissa;
        uint256 redeemTokens;
        uint256 redeemAmount;
        uint256 totalSupplyNew;
        uint256 accountTokensNew;
    }

    function redeemFresh(
        address payable redeemer,
        uint256 redeemTokensIn,
        uint256 redeemAmountIn,
        bool isNative
    ) internal returns (uint256) {

        require(redeemTokensIn == 0 || redeemAmountIn == 0, "one of redeemTokensIn or redeemAmountIn must be zero");

        RedeemLocalVars memory vars;

        vars.exchangeRateMantissa = exchangeRateStoredInternal();

        if (redeemTokensIn > 0) {
            vars.redeemTokens = redeemTokensIn;
            vars.redeemAmount = mul_ScalarTruncate(Exp({mantissa: vars.exchangeRateMantissa}), redeemTokensIn);
        } else {
            vars.redeemTokens = div_ScalarByExpTruncate(redeemAmountIn, Exp({mantissa: vars.exchangeRateMantissa}));
            vars.redeemAmount = redeemAmountIn;
        }

        uint256 allowed = comptroller.redeemAllowed(address(this), redeemer, vars.redeemTokens);
        if (allowed != 0) {
            return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.REDEEM_COMPTROLLER_REJECTION, allowed);
        }

        if (redeemTokensIn == 0 && redeemAmountIn == 0) {
            return uint256(Error.NO_ERROR);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.REDEEM_FRESHNESS_CHECK);
        }

        vars.totalSupplyNew = sub_(totalSupply, vars.redeemTokens);
        vars.accountTokensNew = sub_(accountTokens[redeemer], vars.redeemTokens);

        if (getCashPrior() < vars.redeemAmount) {
            return fail(Error.TOKEN_INSUFFICIENT_CASH, FailureInfo.REDEEM_TRANSFER_OUT_NOT_POSSIBLE);
        }


        doTransferOut(redeemer, vars.redeemAmount, isNative);

        totalSupply = vars.totalSupplyNew;
        accountTokens[redeemer] = vars.accountTokensNew;

        emit Transfer(redeemer, address(this), vars.redeemTokens);
        emit Redeem(redeemer, vars.redeemAmount, vars.redeemTokens);

        comptroller.redeemVerify(address(this), redeemer, vars.redeemAmount, vars.redeemTokens);

        return uint256(Error.NO_ERROR);
    }

    function seizeInternal(
        address seizerToken,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) internal returns (uint256) {

        uint256 allowed = comptroller.seizeAllowed(address(this), seizerToken, liquidator, borrower, seizeTokens);
        if (allowed != 0) {
            return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.LIQUIDATE_SEIZE_COMPTROLLER_REJECTION, allowed);
        }

        if (seizeTokens == 0) {
            return uint256(Error.NO_ERROR);
        }

        if (borrower == liquidator) {
            return fail(Error.INVALID_ACCOUNT_PAIR, FailureInfo.LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER);
        }

        accountTokens[borrower] = sub_(accountTokens[borrower], seizeTokens);
        accountTokens[liquidator] = add_(accountTokens[liquidator], seizeTokens);

        emit Transfer(borrower, liquidator, seizeTokens);


        return uint256(Error.NO_ERROR);
    }
}pragma solidity ^0.5.16;

contract LiquidityMiningInterface {

    function comptroller() external view returns (address);


    function updateSupplyIndex(address cToken, address[] calldata accounts) external;


    function updateBorrowIndex(address cToken, address[] calldata accounts) external;

}pragma solidity ^0.5.16;


contract Unitroller is UnitrollerAdminStorage, ComptrollerErrorReporter {

    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

    event NewImplementation(address oldImplementation, address newImplementation);

    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);

    constructor() public {
        admin = msg.sender;
    }

    function _setPendingImplementation(address newPendingImplementation) public returns (uint256) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_IMPLEMENTATION_OWNER_CHECK);
        }

        address oldPendingImplementation = pendingComptrollerImplementation;

        pendingComptrollerImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, pendingComptrollerImplementation);

        return uint256(Error.NO_ERROR);
    }

    function _acceptImplementation() public returns (uint256) {

        if (msg.sender != pendingComptrollerImplementation || pendingComptrollerImplementation == address(0)) {
            return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK);
        }

        address oldImplementation = comptrollerImplementation;
        address oldPendingImplementation = pendingComptrollerImplementation;

        comptrollerImplementation = pendingComptrollerImplementation;

        pendingComptrollerImplementation = address(0);

        emit NewImplementation(oldImplementation, comptrollerImplementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingComptrollerImplementation);

        return uint256(Error.NO_ERROR);
    }

    function _setPendingAdmin(address newPendingAdmin) public returns (uint256) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PENDING_ADMIN_OWNER_CHECK);
        }

        address oldPendingAdmin = pendingAdmin;

        pendingAdmin = newPendingAdmin;

        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);

        return uint256(Error.NO_ERROR);
    }

    function _acceptAdmin() public returns (uint256) {

        if (msg.sender != pendingAdmin || msg.sender == address(0)) {
            return fail(Error.UNAUTHORIZED, FailureInfo.ACCEPT_ADMIN_PENDING_ADMIN_CHECK);
        }

        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        admin = pendingAdmin;

        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);

        return uint256(Error.NO_ERROR);
    }

    function() external payable {
        (bool success, ) = comptrollerImplementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize)

            switch success
            case 0 {
                revert(free_mem_ptr, returndatasize)
            }
            default {
                return(free_mem_ptr, returndatasize)
            }
        }
    }
}pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

contract Comp {

    string public constant name = "Cream";

    string public constant symbol = "CREAM";

    uint8 public constant decimals = 18;

    uint256 public constant totalSupply = 9000000e18; // 9 million Comp

    mapping(address => mapping(address => uint96)) internal allowances;

    mapping(address => uint96) internal balances;

    mapping(address => address) public delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    mapping(address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address => uint256) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    constructor(address account) public {
        balances[account] = uint96(totalSupply);
        emit Transfer(address(0), account, totalSupply);
    }

    function allowance(address account, address spender) external view returns (uint256) {

        return allowances[account][spender];
    }

    function approve(address spender, uint256 rawAmount) external returns (bool) {

        uint96 amount;
        if (rawAmount == uint256(-1)) {
            amount = uint96(-1);
        } else {
            amount = safe96(rawAmount, "Comp::approve: amount exceeds 96 bits");
        }

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address account) external view returns (uint256) {

        return balances[account];
    }

    function transfer(address dst, uint256 rawAmount) external returns (bool) {

        uint96 amount = safe96(rawAmount, "Comp::transfer: amount exceeds 96 bits");
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    function transferFrom(
        address src,
        address dst,
        uint256 rawAmount
    ) external returns (bool) {

        address spender = msg.sender;
        uint96 spenderAllowance = allowances[src][spender];
        uint96 amount = safe96(rawAmount, "Comp::approve: amount exceeds 96 bits");

        if (spender != src && spenderAllowance != uint96(-1)) {
            uint96 newAllowance = sub96(
                spenderAllowance,
                amount,
                "Comp::transferFrom: transfer amount exceeds spender allowance"
            );
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function delegate(address delegatee) public {

        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {

        bytes32 domainSeparator = keccak256(
            abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), getChainId(), address(this))
        );
        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "Comp::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "Comp::delegateBySig: invalid nonce");
        require(now <= expiry, "Comp::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account) external view returns (uint96) {

        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber) public view returns (uint96) {

        require(blockNumber < block.number, "Comp::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee) internal {

        address currentDelegate = delegates[delegator];
        uint96 delegatorBalance = balances[delegator];
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _transferTokens(
        address src,
        address dst,
        uint96 amount
    ) internal {

        require(src != address(0), "Comp::_transferTokens: cannot transfer from the zero address");
        require(dst != address(0), "Comp::_transferTokens: cannot transfer to the zero address");

        balances[src] = sub96(balances[src], amount, "Comp::_transferTokens: transfer amount exceeds balance");
        balances[dst] = add96(balances[dst], amount, "Comp::_transferTokens: transfer amount overflows");
        emit Transfer(src, dst, amount);

        _moveDelegates(delegates[src], delegates[dst], amount);
    }

    function _moveDelegates(
        address srcRep,
        address dstRep,
        uint96 amount
    ) internal {

        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint96 srcRepNew = sub96(srcRepOld, amount, "Comp::_moveVotes: vote amount underflows");
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint96 dstRepNew = add96(dstRepOld, amount, "Comp::_moveVotes: vote amount overflows");
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint96 oldVotes,
        uint96 newVotes
    ) internal {

        uint32 blockNumber = safe32(block.number, "Comp::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {

        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {

        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function getChainId() internal pure returns (uint256) {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
}pragma solidity ^0.5.16;


contract Comptroller is ComptrollerV1Storage, ComptrollerInterface, ComptrollerErrorReporter, Exponential {

    event MarketListed(CToken cToken);

    event MarketDelisted(CToken cToken);

    event MarketEntered(CToken cToken, address account);

    event MarketExited(CToken cToken, address account);

    event NewCloseFactor(uint256 oldCloseFactorMantissa, uint256 newCloseFactorMantissa);

    event NewCollateralFactor(CToken cToken, uint256 oldCollateralFactorMantissa, uint256 newCollateralFactorMantissa);

    event NewLiquidationIncentive(uint256 oldLiquidationIncentiveMantissa, uint256 newLiquidationIncentiveMantissa);

    event NewPriceOracle(PriceOracle oldPriceOracle, PriceOracle newPriceOracle);

    event NewPauseGuardian(address oldPauseGuardian, address newPauseGuardian);

    event NewLiquidityMining(address oldLiquidityMining, address newLiquidityMining);

    event ActionPaused(string action, bool pauseState);

    event ActionPaused(CToken cToken, string action, bool pauseState);

    event NewBorrowCap(CToken indexed cToken, uint256 newBorrowCap);

    event NewBorrowCapGuardian(address oldBorrowCapGuardian, address newBorrowCapGuardian);

    event NewSupplyCap(CToken indexed cToken, uint256 newSupplyCap);

    event NewSupplyCapGuardian(address oldSupplyCapGuardian, address newSupplyCapGuardian);

    event CreditLimitChanged(address protocol, uint256 creditLimit);

    event NewCTokenVersion(CToken cToken, Version oldVersion, Version newVersion);

    uint256 internal constant collateralFactorMaxMantissa = 0.9e18; // 0.9

    constructor() public {
        admin = msg.sender;
    }


    function getAssetsIn(address account) external view returns (CToken[] memory) {

        CToken[] memory assetsIn = accountAssets[account];

        return assetsIn;
    }

    function checkMembership(address account, CToken cToken) external view returns (bool) {

        return markets[address(cToken)].accountMembership[account];
    }

    function enterMarkets(address[] memory cTokens) public returns (uint256[] memory) {

        uint256 len = cTokens.length;

        uint256[] memory results = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            CToken cToken = CToken(cTokens[i]);

            results[i] = uint256(addToMarketInternal(cToken, msg.sender));
        }

        return results;
    }

    function addToMarketInternal(CToken cToken, address borrower) internal returns (Error) {

        Market storage marketToJoin = markets[address(cToken)];

        if (!marketToJoin.isListed) {
            return Error.MARKET_NOT_LISTED;
        }

        if (marketToJoin.version == Version.COLLATERALCAP) {
            CCollateralCapErc20Interface(address(cToken)).registerCollateral(borrower);
        }

        if (marketToJoin.accountMembership[borrower] == true) {
            return Error.NO_ERROR;
        }

        marketToJoin.accountMembership[borrower] = true;
        accountAssets[borrower].push(cToken);

        emit MarketEntered(cToken, borrower);

        return Error.NO_ERROR;
    }

    function exitMarket(address cTokenAddress) external returns (uint256) {

        CToken cToken = CToken(cTokenAddress);
        (uint256 oErr, uint256 tokensHeld, uint256 amountOwed, ) = cToken.getAccountSnapshot(msg.sender);
        require(oErr == 0, "exitMarket: getAccountSnapshot failed"); // semi-opaque error code

        if (amountOwed != 0) {
            return fail(Error.NONZERO_BORROW_BALANCE, FailureInfo.EXIT_MARKET_BALANCE_OWED);
        }

        uint256 allowed = redeemAllowedInternal(cTokenAddress, msg.sender, tokensHeld);
        if (allowed != 0) {
            return failOpaque(Error.REJECTION, FailureInfo.EXIT_MARKET_REJECTION, allowed);
        }

        Market storage marketToExit = markets[cTokenAddress];

        if (marketToExit.version == Version.COLLATERALCAP) {
            CCollateralCapErc20Interface(cTokenAddress).unregisterCollateral(msg.sender);
        }

        if (!marketToExit.accountMembership[msg.sender]) {
            return uint256(Error.NO_ERROR);
        }

        delete marketToExit.accountMembership[msg.sender];

        CToken[] memory userAssetList = accountAssets[msg.sender];
        uint256 len = userAssetList.length;
        uint256 assetIndex = len;
        for (uint256 i = 0; i < len; i++) {
            if (userAssetList[i] == cToken) {
                assetIndex = i;
                break;
            }
        }

        assert(assetIndex < len);

        CToken[] storage storedList = accountAssets[msg.sender];
        if (assetIndex != storedList.length - 1) {
            storedList[assetIndex] = storedList[storedList.length - 1];
        }
        storedList.length--;

        emit MarketExited(cToken, msg.sender);

        return uint256(Error.NO_ERROR);
    }

    function isMarketListed(address cTokenAddress) public view returns (bool) {

        return markets[cTokenAddress].isListed;
    }


    function mintAllowed(
        address cToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256) {

        require(!mintGuardianPaused[cToken], "mint is paused");
        require(!isCreditAccount(minter), "credit account cannot mint");

        if (!isMarketListed(cToken)) {
            return uint256(Error.MARKET_NOT_LISTED);
        }

        uint256 supplyCap = supplyCaps[cToken];
        if (supplyCap != 0) {
            uint256 totalCash = CToken(cToken).getCash();
            uint256 totalBorrows = CToken(cToken).totalBorrows();
            uint256 totalReserves = CToken(cToken).totalReserves();
            (MathError mathErr, uint256 totalSupplies) = addThenSubUInt(totalCash, totalBorrows, totalReserves);
            require(mathErr == MathError.NO_ERROR, "totalSupplies failed");

            uint256 nextTotalSupplies = add_(totalSupplies, mintAmount);
            require(nextTotalSupplies < supplyCap, "market supply cap reached");
        }

        return uint256(Error.NO_ERROR);
    }

    function mintVerify(
        address cToken,
        address minter,
        uint256 actualMintAmount,
        uint256 mintTokens
    ) external {

        cToken;
        minter;
        actualMintAmount;
        mintTokens;

        if (false) {
            closeFactorMantissa = closeFactorMantissa;
        }
    }

    function redeemAllowed(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256) {

        return redeemAllowedInternal(cToken, redeemer, redeemTokens);
    }

    function redeemAllowedInternal(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) internal view returns (uint256) {

        if (!isMarketListed(cToken)) {
            return uint256(Error.MARKET_NOT_LISTED);
        }

        if (!markets[cToken].accountMembership[redeemer]) {
            return uint256(Error.NO_ERROR);
        }

        (Error err, , uint256 shortfall) = getHypotheticalAccountLiquidityInternal(
            redeemer,
            CToken(cToken),
            redeemTokens,
            0
        );
        if (err != Error.NO_ERROR) {
            return uint256(err);
        }
        if (shortfall > 0) {
            return uint256(Error.INSUFFICIENT_LIQUIDITY);
        }

        return uint256(Error.NO_ERROR);
    }

    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external {

        cToken;
        redeemer;

        if (redeemTokens == 0 && redeemAmount > 0) {
            revert("redeemTokens zero");
        }
    }

    function borrowAllowed(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256) {

        require(!borrowGuardianPaused[cToken], "borrow is paused");

        if (!isMarketListed(cToken)) {
            return uint256(Error.MARKET_NOT_LISTED);
        }

        if (!markets[cToken].accountMembership[borrower]) {
            require(msg.sender == cToken, "sender must be cToken");

            Error err = addToMarketInternal(CToken(cToken), borrower);
            if (err != Error.NO_ERROR) {
                return uint256(err);
            }

            assert(markets[cToken].accountMembership[borrower]);
        }

        if (oracle.getUnderlyingPrice(CToken(cToken)) == 0) {
            return uint256(Error.PRICE_ERROR);
        }

        uint256 borrowCap = borrowCaps[cToken];
        if (borrowCap != 0) {
            uint256 totalBorrows = CToken(cToken).totalBorrows();
            uint256 nextTotalBorrows = add_(totalBorrows, borrowAmount);
            require(nextTotalBorrows < borrowCap, "market borrow cap reached");
        }

        (Error err, , uint256 shortfall) = getHypotheticalAccountLiquidityInternal(
            borrower,
            CToken(cToken),
            0,
            borrowAmount
        );
        if (err != Error.NO_ERROR) {
            return uint256(err);
        }
        if (shortfall > 0) {
            return uint256(Error.INSUFFICIENT_LIQUIDITY);
        }

        return uint256(Error.NO_ERROR);
    }

    function borrowVerify(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external {

        cToken;
        borrower;
        borrowAmount;

        if (false) {
            closeFactorMantissa = closeFactorMantissa;
        }
    }

    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256) {

        payer;
        borrower;
        repayAmount;

        if (!isMarketListed(cToken)) {
            return uint256(Error.MARKET_NOT_LISTED);
        }

        return uint256(Error.NO_ERROR);
    }

    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint256 actualRepayAmount,
        uint256 borrowerIndex
    ) external {

        cToken;
        payer;
        borrower;
        actualRepayAmount;
        borrowerIndex;

        if (false) {
            closeFactorMantissa = closeFactorMantissa;
        }
    }

    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256) {

        require(!isCreditAccount(borrower), "cannot liquidate credit account");

        liquidator;

        if (!isMarketListed(cTokenBorrowed) || !isMarketListed(cTokenCollateral)) {
            return uint256(Error.MARKET_NOT_LISTED);
        }

        (Error err, , uint256 shortfall) = getAccountLiquidityInternal(borrower);
        if (err != Error.NO_ERROR) {
            return uint256(err);
        }
        if (shortfall == 0) {
            return uint256(Error.INSUFFICIENT_SHORTFALL);
        }

        uint256 borrowBalance = CToken(cTokenBorrowed).borrowBalanceStored(borrower);
        uint256 maxClose = mul_ScalarTruncate(Exp({mantissa: closeFactorMantissa}), borrowBalance);
        if (repayAmount > maxClose) {
            return uint256(Error.TOO_MUCH_REPAY);
        }

        return uint256(Error.NO_ERROR);
    }

    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 actualRepayAmount,
        uint256 seizeTokens
    ) external {

        cTokenBorrowed;
        cTokenCollateral;
        liquidator;
        borrower;
        actualRepayAmount;
        seizeTokens;

        if (false) {
            closeFactorMantissa = closeFactorMantissa;
        }
    }

    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256) {

        require(!seizeGuardianPaused, "seize is paused");
        require(!isCreditAccount(borrower), "cannot sieze from credit account");

        liquidator;
        seizeTokens;

        if (!isMarketListed(cTokenCollateral) || !isMarketListed(cTokenBorrowed)) {
            return uint256(Error.MARKET_NOT_LISTED);
        }

        if (CToken(cTokenCollateral).comptroller() != CToken(cTokenBorrowed).comptroller()) {
            return uint256(Error.COMPTROLLER_MISMATCH);
        }

        return uint256(Error.NO_ERROR);
    }

    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external {

        cTokenCollateral;
        cTokenBorrowed;
        liquidator;
        borrower;
        seizeTokens;

        if (false) {
            closeFactorMantissa = closeFactorMantissa;
        }
    }

    function transferAllowed(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external returns (uint256) {

        require(!transferGuardianPaused, "transfer is paused");
        require(!isCreditAccount(dst), "cannot transfer to a credit account");

        dst;

        return redeemAllowedInternal(cToken, src, transferTokens);
    }

    function transferVerify(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external {

        cToken;
        src;
        dst;
        transferTokens;

        if (false) {
            closeFactorMantissa = closeFactorMantissa;
        }
    }


    function flashloanAllowed(
        address cToken,
        address receiver,
        uint256 amount,
        bytes calldata params
    ) external view returns (bool) {

        return !flashloanGuardianPaused[cToken];
    }

    function updateCTokenVersion(address cToken, Version newVersion) external {

        require(msg.sender == cToken, "only cToken could update its version");

        if (isMarketListed(cToken)) {
            Version oldVersion = markets[cToken].version;
            markets[cToken].version = newVersion;

            emit NewCTokenVersion(CToken(cToken), oldVersion, newVersion);
        }
    }

    function isCreditAccount(address account) public view returns (bool) {

        return creditLimits[account] > 0;
    }


    struct AccountLiquidityLocalVars {
        uint256 sumCollateral;
        uint256 sumBorrowPlusEffects;
        uint256 cTokenBalance;
        uint256 borrowBalance;
        uint256 exchangeRateMantissa;
        uint256 oraclePriceMantissa;
        Exp collateralFactor;
        Exp exchangeRate;
        Exp oraclePrice;
        Exp tokensToDenom;
    }

    function getAccountLiquidity(address account)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        (Error err, uint256 liquidity, uint256 shortfall) = getHypotheticalAccountLiquidityInternal(
            account,
            CToken(0),
            0,
            0
        );

        return (uint256(err), liquidity, shortfall);
    }

    function getAccountLiquidityInternal(address account)
        internal
        view
        returns (
            Error,
            uint256,
            uint256
        )
    {

        return getHypotheticalAccountLiquidityInternal(account, CToken(0), 0, 0);
    }

    function getHypotheticalAccountLiquidity(
        address account,
        address cTokenModify,
        uint256 redeemTokens,
        uint256 borrowAmount
    )
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        (Error err, uint256 liquidity, uint256 shortfall) = getHypotheticalAccountLiquidityInternal(
            account,
            CToken(cTokenModify),
            redeemTokens,
            borrowAmount
        );
        return (uint256(err), liquidity, shortfall);
    }

    function getHypotheticalAccountLiquidityInternal(
        address account,
        CToken cTokenModify,
        uint256 redeemTokens,
        uint256 borrowAmount
    )
        internal
        view
        returns (
            Error,
            uint256,
            uint256
        )
    {

        if (creditLimits[account] == uint256(-1)) {
            return (Error.NO_ERROR, uint256(-1), 0);
        }

        AccountLiquidityLocalVars memory vars; // Holds all our calculation results
        uint256 oErr;

        CToken[] memory assets = accountAssets[account];
        for (uint256 i = 0; i < assets.length; i++) {
            CToken asset = assets[i];

            (oErr, vars.cTokenBalance, vars.borrowBalance, vars.exchangeRateMantissa) = asset.getAccountSnapshot(
                account
            );
            if (oErr != 0) {
                return (Error.SNAPSHOT_ERROR, 0, 0);
            }

            if (vars.cTokenBalance == 0 && vars.borrowBalance == 0 && asset != cTokenModify) {
                continue;
            }

            vars.collateralFactor = Exp({mantissa: markets[address(asset)].collateralFactorMantissa});
            vars.exchangeRate = Exp({mantissa: vars.exchangeRateMantissa});

            vars.oraclePriceMantissa = oracle.getUnderlyingPrice(asset);
            if (vars.oraclePriceMantissa == 0) {
                return (Error.PRICE_ERROR, 0, 0);
            }
            vars.oraclePrice = Exp({mantissa: vars.oraclePriceMantissa});

            vars.tokensToDenom = mul_(mul_(vars.collateralFactor, vars.exchangeRate), vars.oraclePrice);

            vars.sumCollateral = mul_ScalarTruncateAddUInt(vars.tokensToDenom, vars.cTokenBalance, vars.sumCollateral);

            vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(
                vars.oraclePrice,
                vars.borrowBalance,
                vars.sumBorrowPlusEffects
            );

            if (asset == cTokenModify) {
                vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(
                    vars.tokensToDenom,
                    redeemTokens,
                    vars.sumBorrowPlusEffects
                );

                vars.sumBorrowPlusEffects = mul_ScalarTruncateAddUInt(
                    vars.oraclePrice,
                    borrowAmount,
                    vars.sumBorrowPlusEffects
                );
            }
        }

        if (creditLimits[account] > 0) {
            vars.sumCollateral = creditLimits[account];
        }

        if (vars.sumCollateral > vars.sumBorrowPlusEffects) {
            return (Error.NO_ERROR, vars.sumCollateral - vars.sumBorrowPlusEffects, 0);
        } else {
            return (Error.NO_ERROR, 0, vars.sumBorrowPlusEffects - vars.sumCollateral);
        }
    }

    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 actualRepayAmount
    ) external view returns (uint256, uint256) {

        uint256 priceBorrowedMantissa = oracle.getUnderlyingPrice(CToken(cTokenBorrowed));
        uint256 priceCollateralMantissa = oracle.getUnderlyingPrice(CToken(cTokenCollateral));
        if (priceBorrowedMantissa == 0 || priceCollateralMantissa == 0) {
            return (uint256(Error.PRICE_ERROR), 0);
        }

        uint256 exchangeRateMantissa = CToken(cTokenCollateral).exchangeRateStored(); // Note: reverts on error
        Exp memory numerator = mul_(
            Exp({mantissa: liquidationIncentiveMantissa}),
            Exp({mantissa: priceBorrowedMantissa})
        );
        Exp memory denominator = mul_(Exp({mantissa: priceCollateralMantissa}), Exp({mantissa: exchangeRateMantissa}));
        Exp memory ratio = div_(numerator, denominator);
        uint256 seizeTokens = mul_ScalarTruncate(ratio, actualRepayAmount);

        return (uint256(Error.NO_ERROR), seizeTokens);
    }


    function _setPriceOracle(PriceOracle newOracle) public returns (uint256) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PRICE_ORACLE_OWNER_CHECK);
        }

        PriceOracle oldOracle = oracle;

        oracle = newOracle;

        emit NewPriceOracle(oldOracle, newOracle);

        return uint256(Error.NO_ERROR);
    }

    function _setCloseFactor(uint256 newCloseFactorMantissa) external returns (uint256) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_CLOSE_FACTOR_OWNER_CHECK);
        }

        uint256 oldCloseFactorMantissa = closeFactorMantissa;
        closeFactorMantissa = newCloseFactorMantissa;
        emit NewCloseFactor(oldCloseFactorMantissa, closeFactorMantissa);

        return uint256(Error.NO_ERROR);
    }

    function _setCollateralFactor(CToken cToken, uint256 newCollateralFactorMantissa) external returns (uint256) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_COLLATERAL_FACTOR_OWNER_CHECK);
        }

        Market storage market = markets[address(cToken)];
        if (!market.isListed) {
            return fail(Error.MARKET_NOT_LISTED, FailureInfo.SET_COLLATERAL_FACTOR_NO_EXISTS);
        }

        Exp memory newCollateralFactorExp = Exp({mantissa: newCollateralFactorMantissa});

        Exp memory highLimit = Exp({mantissa: collateralFactorMaxMantissa});
        if (lessThanExp(highLimit, newCollateralFactorExp)) {
            return fail(Error.INVALID_COLLATERAL_FACTOR, FailureInfo.SET_COLLATERAL_FACTOR_VALIDATION);
        }

        if (newCollateralFactorMantissa != 0 && oracle.getUnderlyingPrice(cToken) == 0) {
            return fail(Error.PRICE_ERROR, FailureInfo.SET_COLLATERAL_FACTOR_WITHOUT_PRICE);
        }

        uint256 oldCollateralFactorMantissa = market.collateralFactorMantissa;
        market.collateralFactorMantissa = newCollateralFactorMantissa;

        emit NewCollateralFactor(cToken, oldCollateralFactorMantissa, newCollateralFactorMantissa);

        return uint256(Error.NO_ERROR);
    }

    function _setLiquidationIncentive(uint256 newLiquidationIncentiveMantissa) external returns (uint256) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_LIQUIDATION_INCENTIVE_OWNER_CHECK);
        }

        uint256 oldLiquidationIncentiveMantissa = liquidationIncentiveMantissa;

        liquidationIncentiveMantissa = newLiquidationIncentiveMantissa;

        emit NewLiquidationIncentive(oldLiquidationIncentiveMantissa, newLiquidationIncentiveMantissa);

        return uint256(Error.NO_ERROR);
    }

    function _supportMarket(CToken cToken, Version version) external returns (uint256) {

        require(msg.sender == admin, "only admin may support market");
        require(!isMarketListed(address(cToken)), "market already listed");

        cToken.isCToken(); // Sanity check to make sure its really a CToken

        markets[address(cToken)] = Market({isListed: true, collateralFactorMantissa: 0, version: version});

        _addMarketInternal(address(cToken));

        emit MarketListed(cToken);

        return uint256(Error.NO_ERROR);
    }

    function _delistMarket(CToken cToken) external {

        require(msg.sender == admin, "only admin may delist market");
        require(isMarketListed(address(cToken)), "market not listed");
        require(cToken.totalSupply() == 0, "market not empty");

        cToken.isCToken(); // Sanity check to make sure its really a CToken

        delete markets[address(cToken)];

        for (uint256 i = 0; i < allMarkets.length; i++) {
            if (allMarkets[i] == cToken) {
                allMarkets[i] = allMarkets[allMarkets.length - 1];
                delete allMarkets[allMarkets.length - 1];
                allMarkets.length--;
                break;
            }
        }

        emit MarketDelisted(cToken);
    }

    function _addMarketInternal(address cToken) internal {

        for (uint256 i = 0; i < allMarkets.length; i++) {
            require(allMarkets[i] != CToken(cToken), "market already added");
        }
        allMarkets.push(CToken(cToken));
    }

    function _setSupplyCapGuardian(address newSupplyCapGuardian) external {

        require(msg.sender == admin, "only admin can set supply cap guardian");

        address oldSupplyCapGuardian = supplyCapGuardian;

        supplyCapGuardian = newSupplyCapGuardian;

        emit NewSupplyCapGuardian(oldSupplyCapGuardian, newSupplyCapGuardian);
    }

    function _setMarketSupplyCaps(CToken[] calldata cTokens, uint256[] calldata newSupplyCaps) external {

        require(
            msg.sender == admin || msg.sender == supplyCapGuardian,
            "only admin or supply cap guardian can set supply caps"
        );

        uint256 numMarkets = cTokens.length;
        uint256 numSupplyCaps = newSupplyCaps.length;

        require(numMarkets != 0 && numMarkets == numSupplyCaps, "invalid input");

        for (uint256 i = 0; i < numMarkets; i++) {
            supplyCaps[address(cTokens[i])] = newSupplyCaps[i];
            emit NewSupplyCap(cTokens[i], newSupplyCaps[i]);
        }
    }

    function _setMarketBorrowCaps(CToken[] calldata cTokens, uint256[] calldata newBorrowCaps) external {

        require(
            msg.sender == admin || msg.sender == borrowCapGuardian,
            "only admin or borrow cap guardian can set borrow caps"
        );

        uint256 numMarkets = cTokens.length;
        uint256 numBorrowCaps = newBorrowCaps.length;

        require(numMarkets != 0 && numMarkets == numBorrowCaps, "invalid input");

        for (uint256 i = 0; i < numMarkets; i++) {
            borrowCaps[address(cTokens[i])] = newBorrowCaps[i];
            emit NewBorrowCap(cTokens[i], newBorrowCaps[i]);
        }
    }

    function _setBorrowCapGuardian(address newBorrowCapGuardian) external {

        require(msg.sender == admin, "only admin can set borrow cap guardian");

        address oldBorrowCapGuardian = borrowCapGuardian;

        borrowCapGuardian = newBorrowCapGuardian;

        emit NewBorrowCapGuardian(oldBorrowCapGuardian, newBorrowCapGuardian);
    }

    function _setPauseGuardian(address newPauseGuardian) public returns (uint256) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PAUSE_GUARDIAN_OWNER_CHECK);
        }

        address oldPauseGuardian = pauseGuardian;

        pauseGuardian = newPauseGuardian;

        emit NewPauseGuardian(oldPauseGuardian, pauseGuardian);

        return uint256(Error.NO_ERROR);
    }

    function _setLiquidityMining(address newLiquidityMining) external {

        require(msg.sender == admin, "only admin can set liquidity mining module");
        require(LiquidityMiningInterface(newLiquidityMining).comptroller() == address(this), "mismatch comptroller");

        address oldLiquidityMining = liquidityMining;

        liquidityMining = newLiquidityMining;

        emit NewLiquidityMining(oldLiquidityMining, liquidityMining);
    }

    function _setMintPaused(CToken cToken, bool state) public returns (bool) {

        require(isMarketListed(address(cToken)), "cannot pause a market that is not listed");
        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause");
        require(msg.sender == admin || state == true, "only admin can unpause");

        mintGuardianPaused[address(cToken)] = state;
        emit ActionPaused(cToken, "Mint", state);
        return state;
    }

    function _setBorrowPaused(CToken cToken, bool state) public returns (bool) {

        require(isMarketListed(address(cToken)), "cannot pause a market that is not listed");
        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause");
        require(msg.sender == admin || state == true, "only admin can unpause");

        borrowGuardianPaused[address(cToken)] = state;
        emit ActionPaused(cToken, "Borrow", state);
        return state;
    }

    function _setFlashloanPaused(CToken cToken, bool state) public returns (bool) {

        require(isMarketListed(address(cToken)), "cannot pause a market that is not listed");
        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause");
        require(msg.sender == admin || state == true, "only admin can unpause");

        flashloanGuardianPaused[address(cToken)] = state;
        emit ActionPaused(cToken, "Flashloan", state);
        return state;
    }

    function _setTransferPaused(bool state) public returns (bool) {

        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause");
        require(msg.sender == admin || state == true, "only admin can unpause");

        transferGuardianPaused = state;
        emit ActionPaused("Transfer", state);
        return state;
    }

    function _setSeizePaused(bool state) public returns (bool) {

        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause");
        require(msg.sender == admin || state == true, "only admin can unpause");

        seizeGuardianPaused = state;
        emit ActionPaused("Seize", state);
        return state;
    }

    function _become(Unitroller unitroller) public {

        require(msg.sender == unitroller.admin(), "only unitroller admin can change brains");
        require(unitroller._acceptImplementation() == 0, "change not authorized");
    }

    function _setCreditLimit(address protocol, uint256 creditLimit) public {

        require(msg.sender == admin, "only admin can set protocol credit limit");

        creditLimits[protocol] = creditLimit;
        emit CreditLimitChanged(protocol, creditLimit);
    }

    function getAllMarkets() public view returns (CToken[] memory) {

        return allMarkets;
    }

    function getBlockNumber() public view returns (uint256) {

        return block.number;
    }
}pragma solidity ^0.5.16;

interface CERC20Interface {

    function underlying() external view returns (address);

}

contract FlashloanLender is ERC3156FlashLenderInterface {

    mapping(address => address) public underlyingToCToken;

    address public comptroller;

    address public owner;

    modifier onlyOwner() {

        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(address _comptroller, address _owner) public {
        comptroller = _comptroller;
        owner = _owner;
        initialiseUnderlyingMapping();
    }

    function maxFlashLoan(address token) external view returns (uint256) {

        address cToken = underlyingToCToken[token];
        uint256 amount = 0;
        if (cToken != address(0)) {
            amount = CCollateralCapErc20(cToken).maxFlashLoan();
        }
        return amount;
    }

    function flashFee(address token, uint256 amount) external view returns (uint256) {

        address cToken = underlyingToCToken[token];
        require(cToken != address(0), "cannot find cToken of this underlying in the mapping");
        return CCollateralCapErc20(cToken).flashFee(amount);
    }

    function flashLoan(
        ERC3156FlashBorrowerInterface receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool) {

        address cToken = underlyingToCToken[token];
        require(cToken != address(0), "cannot find cToken of this underlying in the mapping");
        return CCollateralCapErc20(cToken).flashLoan(receiver, msg.sender, amount, data);
    }

    function updateUnderlyingMapping(CToken[] calldata cTokens) external onlyOwner returns (bool) {

        uint256 cTokenLength = cTokens.length;
        for (uint256 i = 0; i < cTokenLength; i++) {
            CToken cToken = cTokens[i];
            address underlying = CErc20(address(cToken)).underlying();
            underlyingToCToken[underlying] = address(cToken);
        }
        return true;
    }

    function removeUnderlyingMapping(CToken[] calldata cTokens) external onlyOwner returns (bool) {

        uint256 cTokenLength = cTokens.length;
        for (uint256 i = 0; i < cTokenLength; i++) {
            CToken cToken = cTokens[i];
            address underlying = CErc20(address(cToken)).underlying();
            underlyingToCToken[underlying] = address(0);
        }
        return true;
    }


    function compareStrings(string memory a, string memory b) private pure returns (bool) {

        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function initialiseUnderlyingMapping() internal {

        CToken[] memory cTokens = Comptroller(comptroller).getAllMarkets();
        uint256 cTokenLength = cTokens.length;
        for (uint256 i = 0; i < cTokenLength; i++) {
            CToken cToken = cTokens[i];
            if (compareStrings(cToken.symbol(), "crETH")) {
                continue;
            }
            address underlying = CErc20(address(cToken)).underlying();
            underlyingToCToken[underlying] = address(cToken);
        }
    }
}