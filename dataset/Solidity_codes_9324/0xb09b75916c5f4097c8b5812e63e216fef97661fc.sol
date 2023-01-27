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

contract Denominations {

    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant BTC = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;

    address public constant USD = address(840);
    address public constant GBP = address(826);
    address public constant EUR = address(978);
    address public constant JPY = address(392);
    address public constant KRW = address(410);
    address public constant CNY = address(156);
    address public constant AUD = address(36);
    address public constant CAD = address(124);
    address public constant CHF = address(756);
    address public constant ARS = address(32);
    address public constant PHP = address(608);
    address public constant NZD = address(554);
    address public constant SGD = address(702);
    address public constant NGN = address(566);
    address public constant ZAR = address(710);
    address public constant RUB = address(643);
    address public constant INR = address(356);
    address public constant BRL = address(986);
}pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

interface StdReferenceInterface {

    struct ReferenceData {
        uint256 rate; // base/quote exchange rate, multiplied by 1e18.
        uint256 lastUpdatedBase; // UNIX epoch of the last time when base price gets updated.
        uint256 lastUpdatedQuote; // UNIX epoch of the last time when quote price gets updated.
    }

    function getReferenceData(string calldata _base, string calldata _quote)
        external
        view
        returns (ReferenceData memory);


    function getRefenceDataBulk(string[] calldata _bases, string[] calldata _quotes)
        external
        view
        returns (ReferenceData[] memory);

}pragma solidity ^0.5.16;

interface CurveTokenV3Interface {

    function minter() external view returns (address);

}

interface CurveSwapInterface {

    function get_virtual_price() external view returns (uint256);

}pragma solidity ^0.5.16;

interface FeedRegistryInterface {

    function decimals(address base, address quote) external view returns (uint8);


    function description(address base, address quote) external view returns (string memory);


    function version(address base, address quote) external view returns (uint256);


    function getRoundData(
        address base,
        address quote,
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );


    function latestRoundData(address base, address quote)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );


    function getFeed(address base, address quote) external view returns (address aggregator);


    function isFeedEnabled(address aggregator) external view returns (bool);

}pragma solidity ^0.5.16;

interface V1PriceOracleInterface {

    function assetPrices(address asset) external view returns (uint256);

}pragma solidity ^0.5.16;

interface YVaultV1Interface {

    function token() external view returns (address);


    function getPricePerFullShare() external view returns (uint256);

}

interface YVaultV2Interface {

    function token() external view returns (address);


    function pricePerShare() external view returns (uint256);

}pragma solidity ^0.5.16;


contract PriceOracleProxyIB is PriceOracle, Exponential, Denominations {

    address public admin;

    address public guardian;

    struct AggregatorInfo {
        address base;
        address quote;
        bool isUsed;
    }

    struct ReferenceInfo {
        string symbol;
        bool isUsed;
    }

    mapping(address => AggregatorInfo) public aggregators;

    mapping(address => ReferenceInfo) public references;

    mapping(address => address) public yVaults;

    mapping(address => address) public curveSwap;

    V1PriceOracleInterface public v1PriceOracle;

    FeedRegistryInterface public reg;

    StdReferenceInterface public ref;

    address[6] public btcAddresses = [
        0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, // WBTC
        0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D, // renBTC
        0x9BE89D2a4cd102D8Fecc6BF9dA793be995C22541, // BBTC
        0x8dAEBADE922dF735c38C80C7eBD708Af50815fAa, // tBTC
        0x0316EB71485b0Ab14103307bf65a021042c6d380, // HBTC
        0xc4E15973E6fF2A35cC804c2CF9D2a1b817a8b40F // ibBTC
    ];

    string public constant QUOTE_SYMBOL = "USD";

    address public constant y3CRVAddress = 0x9cA85572E6A3EbF24dEDd195623F188735A5179f;

    constructor(
        address admin_,
        address v1PriceOracle_,
        address registry_,
        address reference_
    ) public {
        admin = admin_;
        v1PriceOracle = V1PriceOracleInterface(v1PriceOracle_);
        reg = FeedRegistryInterface(registry_);
        ref = StdReferenceInterface(reference_);

        yVaults[y3CRVAddress] = 0x9cA85572E6A3EbF24dEDd195623F188735A5179f; // y-vault 3Crv
        curveSwap[y3CRVAddress] = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7; // curve 3 pool
    }

    function getUnderlyingPrice(CToken cToken) public view returns (uint256) {

        address underlying = CErc20(address(cToken)).underlying();

        if (underlying == y3CRVAddress) {
            uint256 yVaultPrice = YVaultV1Interface(yVaults[y3CRVAddress]).getPricePerFullShare();
            uint256 virtualPrice = CurveSwapInterface(curveSwap[y3CRVAddress]).get_virtual_price();
            return mul_(yVaultPrice, Exp({mantissa: virtualPrice}));
        }

        AggregatorInfo storage aggregatorInfo = aggregators[underlying];
        if (aggregatorInfo.isUsed) {
            uint256 price = getPriceFromChainlink(aggregatorInfo.base, aggregatorInfo.quote);
            if (aggregatorInfo.quote == Denominations.ETH) {
                uint256 ethUsdPrice = getPriceFromChainlink(Denominations.ETH, Denominations.USD);
                price = mul_(price, Exp({mantissa: ethUsdPrice}));
            }
            return getNormalizedPrice(price, underlying);
        }

        ReferenceInfo storage referenceInfo = references[underlying];
        if (referenceInfo.isUsed) {
            uint256 price = getPriceFromBAND(referenceInfo.symbol);
            return getNormalizedPrice(price, underlying);
        }

        return getPriceFromV1(underlying);
    }


    function getPriceFromChainlink(address base, address quote) internal view returns (uint256) {

        (, int256 price, , , ) = reg.latestRoundData(base, quote);
        require(price > 0, "invalid price");

        return mul_(uint256(price), 10**(18 - uint256(reg.decimals(base, quote))));
    }

    function getPriceFromBAND(string memory symbol) internal view returns (uint256) {

        StdReferenceInterface.ReferenceData memory data = ref.getReferenceData(symbol, QUOTE_SYMBOL);
        require(data.rate > 0, "invalid price");

        return data.rate;
    }

    function getNormalizedPrice(uint256 price, address tokenAddress) internal view returns (uint256) {

        uint256 underlyingDecimals = EIP20Interface(tokenAddress).decimals();
        return mul_(price, 10**(18 - underlyingDecimals));
    }

    function getPriceFromV1(address token) internal view returns (uint256) {

        return v1PriceOracle.assetPrices(token);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {

        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function isBtcAddress(address token) internal returns (bool) {

        for (uint256 i = 0; i < btcAddresses.length; i++) {
            if (btcAddresses[i] == token) {
                return true;
            }
        }
        return false;
    }


    event AggregatorUpdated(address tokenAddress, address base, address quote, bool isUsed);
    event ReferenceUpdated(address tokenAddress, string symbol, bool isUsed);
    event SetGuardian(address guardian);
    event SetAdmin(address admin);

    function _setGuardian(address _guardian) external {

        require(msg.sender == admin, "only the admin may set new guardian");
        guardian = _guardian;
        emit SetGuardian(guardian);
    }

    function _setAdmin(address _admin) external {

        require(msg.sender == admin, "only the admin may set new admin");
        admin = _admin;
        emit SetAdmin(admin);
    }

    function _setAggregators(address[] calldata tokenAddresses, string[] calldata quotes) external {

        require(msg.sender == admin || msg.sender == guardian, "only the admin or guardian may set the aggregators");
        require(tokenAddresses.length == quotes.length, "mismatched data");
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            address base;
            address quote;
            bool isUsed;
            if (bytes(quotes[i]).length != 0) {
                require(msg.sender == admin, "guardian may only clear the aggregator");
                isUsed = true;

                base = tokenAddresses[i];
                if (isBtcAddress(tokenAddresses[i])) {
                    base = Denominations.BTC;
                }

                if (compareStrings(quotes[i], "ETH")) {
                    quote = Denominations.ETH;
                } else if (compareStrings(quotes[i], "USD")) {
                    quote = Denominations.USD;
                } else {
                    revert("unsupported denomination");
                }

                address aggregator = reg.getFeed(base, quote);
                require(reg.isFeedEnabled(aggregator), "aggregator not enabled");
            }
            aggregators[tokenAddresses[i]] = AggregatorInfo({base: base, quote: quote, isUsed: isUsed});
            emit AggregatorUpdated(tokenAddresses[i], base, quote, isUsed);
        }
    }

    function _setReferences(address[] calldata tokenAddresses, string[] calldata symbols) external {

        require(msg.sender == admin || msg.sender == guardian, "only the admin or guardian may set the references");
        require(tokenAddresses.length == symbols.length, "mismatched data");
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            bool isUsed;
            if (bytes(symbols[i]).length != 0) {
                require(msg.sender == admin, "guardian may only clear the reference");
                isUsed = true;

                getPriceFromBAND(symbols[i]);
            }

            references[tokenAddresses[i]] = ReferenceInfo({symbol: symbols[i], isUsed: isUsed});
            emit ReferenceUpdated(tokenAddresses[i], symbols[i], isUsed);
        }
    }
}