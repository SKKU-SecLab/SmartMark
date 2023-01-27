pragma solidity ^0.5.16;

contract AegisComptrollerInterface {

    bool public constant aegisComptroller = true;

    function enterMarkets(address[] calldata _aTokens) external returns (uint[] memory);

    
    function exitMarket(address _aToken) external returns (uint);


    function mintAllowed() external returns (uint);


    function redeemAllowed(address _aToken, address _redeemer, uint _redeemTokens) external returns (uint);

    
    function redeemVerify(uint _redeemAmount, uint _redeemTokens) external;


    function borrowAllowed(address _aToken, address _borrower, uint _borrowAmount) external returns (uint);


    function repayBorrowAllowed() external returns (uint);


    function seizeAllowed(address _aTokenCollateral, address _aTokenBorrowed) external returns (uint);


    function transferAllowed(address _aToken, address _src, uint _transferTokens) external returns (uint);


    function liquidateCalculateSeizeTokens(address _aTokenBorrowed, address _aTokenCollateral, uint _repayAmount) external view returns (uint, uint);

}pragma solidity ^0.5.16;

contract InterestRateModel {

    bool public constant isInterestRateModel = true;

    function getBorrowRate(uint _cash, uint _borrows, uint _reserves) external view returns (uint);


    function getSupplyRate(uint _cash, uint _borrows, uint _reserves, uint _reserveFactorMantissa) external view returns (uint);

}pragma solidity ^0.5.16;


contract AegisTokenCommon {

    bool internal reentrant;

    string public name;
    string public symbol;
    uint public decimals;
    address payable public admin;
    address payable public pendingAdmin;
    address payable public liquidateAdmin;

    uint internal constant borrowRateMaxMantissa = 0.0005e16;
    uint internal constant reserveFactorMaxMantissa = 1e18;
    
    AegisComptrollerInterface public comptroller;
    InterestRateModel public interestRateModel;
    
    uint internal initialExchangeRateMantissa;
    uint public reserveFactorMantissa;
    uint public accrualBlockNumber;
    uint public borrowIndex;
    uint public totalBorrows;
    uint public totalReserves;
    uint public totalSupply;
    
    mapping (address => uint) internal accountTokens;
    mapping (address => mapping (address => uint)) internal transferAllowances;

    struct BorrowBalanceInfomation {
        uint principal;
        uint interestIndex;
    }
    mapping (address => BorrowBalanceInfomation) internal accountBorrows;
}pragma solidity ^0.5.16;


contract ATokenInterface is AegisTokenCommon {

    bool public constant aToken = true;

    event AccrueInterest(uint _cashPrior, uint _interestAccumulated, uint _borrowIndex, uint _totalBorrows);

    event Mint(address _minter, uint _mintAmount, uint _mintTokens);

    event Redeem(address _redeemer, uint _redeemAmount, uint _redeemTokens);

    event Borrow(address _borrower, uint _borrowAmount, uint _accountBorrows, uint _totalBorrows);

    event RepayBorrow(address _payer, address _borrower, uint _repayAmount, uint _accountBorrows, uint _totalBorrows);

    event LiquidateBorrow(address _liquidator, address _borrower, uint _repayAmount, address _aTokenCollateral, uint _seizeTokens);

    event NewAdmin(address _old, address _new);

    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewComptroller(AegisComptrollerInterface _oldComptroller, AegisComptrollerInterface _newComptroller);

    event NewMarketInterestRateModel(InterestRateModel _oldInterestRateModel, InterestRateModel _newInterestRateModel);

    event NewReserveFactor(uint _oldReserveFactorMantissa, uint _newReserveFactorMantissa);

    event ReservesAdded(address _benefactor, uint _addAmount, uint _newTotalReserves);

    event ReservesReduced(address _admin, uint _reduceAmount, uint _newTotalReserves);

    event Transfer(address indexed _from, address indexed _to, uint _amount);

    event Approval(address indexed _owner, address indexed _spender, uint _amount);

    event Failure(uint _error, uint _info, uint _detail);


    function transfer(address _dst, uint _amount) external returns (bool);

    function transferFrom(address _src, address _dst, uint _amount) external returns (bool);

    function approve(address _spender, uint _amount) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint);

    function balanceOf(address _owner) external view returns (uint);

    function balanceOfUnderlying(address _owner) external returns (uint);

    function getAccountSnapshot(address _account) external view returns (uint, uint, uint, uint);

    function borrowRatePerBlock() external view returns (uint);

    function supplyRatePerBlock() external view returns (uint);

    function totalBorrowsCurrent() external returns (uint);

    function borrowBalanceCurrent(address _account) external returns (uint);

    function borrowBalanceStored(address _account) public view returns (uint);

    function exchangeRateCurrent() public returns (uint);

    function exchangeRateStored() public view returns (uint);

    function getCash() external view returns (uint);

    function accrueInterest() public returns (uint);

    function seize(address _liquidator, address _borrower, uint _seizeTokens) external returns (uint);



    function _acceptAdmin() external returns (uint);

    function _setComptroller(AegisComptrollerInterface _newComptroller) public returns (uint);

    function _setReserveFactor(uint _newReserveFactorMantissa) external returns (uint);

    function _reduceReserves(uint _reduceAmount, address payable _account) external returns (uint);

    function _setInterestRateModel(InterestRateModel _newInterestRateModel) public returns (uint);

}pragma solidity ^0.5.16;

contract BaseReporter {

    event FailUre(uint _error, uint _remarks, uint _item);
    enum Error{
        SUCCESS,
        ERROR
    }

    enum ErrorRemarks {
        COMPTROLLER_TRANSFER_ALLOWED,
        ALLOW_SELF_TRANSFERS,
        DIVISION_BY_ZERO,

        SET_COMPTROLLER_OWNER_CHECK,
        SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED,
        SET_RESERVE_FACTOR_FRESH_CHECK,
        SET_RESERVE_FACTOR_ADMIN_CHECK,
        SET_RESERVE_FACTOR_BOUNDS_CHECK,
        
        ADD_RESERVES_ACCRUE_INTEREST_FAILED,
        ADD_RESERVES_FRESH_CHECK,
        
        REDUCE_RESERVES_ACCRUE_INTEREST_FAILED,
        REDUCE_RESERVES_ADMIN_CHECK,
        REDUCE_RESERVES_FRESH_CHECK,
        REDUCE_RESERVES_CASH_NOT_AVAILABLE,
        REDUCE_RESERVES_VALIDATION,

        SET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_INTEREST_RATE_MODEL_FRESH_CHECK,

        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW,

        TRANSFER_NOT_ALLOWED,
        TRANSFER_NOT_ENOUGH,
        TRANSFER_TOO_MUCH,

        ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED,
        ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED,

        MINT_COMPTROLLER_REJECTION,
        MINT_FRESHNESS_CHECK,
        MINT_EXCHANGE_RATE_READ_FAILED,
        REDEEM_ACCRUE_INTEREST_FAILED,
        REDEEM_EXCHANGE_RATE_READ_FAILED,
        CANNOT_BE_ZERO,

        REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED,
        REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED,
        REDEEM_COMPTROLLER_REJECTION,
        REDEEM_FRESHNESS_CHECK,
        REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        REDEEM_TRANSFER_OUT_NOT_POSSIBLE,

        BORROW_FRESHNESS_CHECK,
        BORROW_COMPTROLLER_REJECTION,
        BORROW_CASH_NOT_AVAILABLE,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        
        REPAY_BORROW_ACCRUE_INTEREST_FAILED,
        REPAY_BEHALF_ACCRUE_INTEREST_FAILED,
        REPAY_BORROW_FRESHNESS_CHECK,
        REPAY_BORROW_COMPTROLLER_REJECTION,
        REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,

        LIQUIDATE_ACCRUE_BORROW_INTEREST_FAILED,
        LIQUIDATE_ACCRUE_COLLATERAL_INTEREST_FAILED,
        LIQUIDATE_FRESHNESS_CHECK,
        LIQUIDATE_COLLATERAL_FRESHNESS_CHECK,
        LIQUIDATE_COMPTROLLER_REJECTION,
        LIQUIDATE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_CLOSE_AMOUNT_IS_ZERO,
        LIQUIDATE_CLOSE_AMOUNT_IS_UINT_MAX,
        LIQUIDATE_REPAY_BORROW_FRESH_FAILED,
        LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_SEIZE_COMPTROLLER_REJECTION,
        LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED,
        LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED,
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,

        EXIT_MARKET_BALANCE_OWED,
        EXIT_MARKET_REJECTION,

        SET_PRICE_ORACLE_OWNER_CHECK,
        SET_CLOSE_FACTOR_OWNER_CHECK,
        SET_CLOSE_FACTOR_VALIDATION,

        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_NO_EXISTS,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_WITHOUT_PRICE,

        SET_MAX_ASSETS_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_VALIDATION,
        SUPPORT_MARKET_EXISTS,
        SUPPORT_MARKET_OWNER_CHECK,
        SET_PAUSE_GUARDIAN_OWNER_CHECK,

        SET_PENDING_ADMIN_OWNER_CHECK,
        ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
        SET_PENDING_IMPLEMENTATION_OWNER_CHECK,
        MINT_ACCRUE_INTEREST_FAILED,
        BORROW_ACCRUE_INTEREST_FAILED,
        SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED

    }

    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }

    function fail(Error _errorEnum, ErrorRemarks _remarks, uint _item) internal returns (uint) {

        emit FailUre(uint(_errorEnum), uint(_remarks), _item);
        return uint(_errorEnum);
    }
}pragma solidity ^0.5.16;

library AegisMath {


    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;
        require(c >= _a, "AegisMath: addition overflow");
        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        return sub(_a, _b, "AegisMath: subtraction overflow");
    }

    function sub(uint256 _a, uint256 _b, string memory _errorMessage) internal pure returns (uint256) {

        require(_b <= _a, _errorMessage);
        uint256 c = _a - _b;
        return c;
    }

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a == 0) {
            return 0;
        }
        uint256 c = _a * _b;
        require(c / _a == _b, "AegisMath: multiplication overflow");
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        return div(_a, _b, "AegisMath: division by zero");
    }

    function div(uint256 _a, uint256 _b, string memory _errorMessage) internal pure returns (uint256) {

        require(_b > 0, _errorMessage);
        uint256 c = _a / _b;
        return c;
    }

    function mod(uint256 _a, uint256 _b) internal pure returns (uint256) {

        return mod(_a, _b, "AegisMath: modulo by zero");
    }

    function mod(uint256 _a, uint256 _b, string memory _errorMessage) internal pure returns (uint256) {

        require(_b != 0, _errorMessage);
        return _a % _b;
    }
}pragma solidity ^0.5.16;


contract CarefulMath {


    function mulUInt(uint _a, uint _b) internal pure returns (BaseReporter.MathError, uint) {

        if (_a == 0) {
            return (BaseReporter.MathError.NO_ERROR, 0);
        }
        uint c = _a * _b;
        if (c / _a != _b) {
            return (BaseReporter.MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (BaseReporter.MathError.NO_ERROR, c);
        }
    }

    function divUInt(uint _a, uint _b) internal pure returns (BaseReporter.MathError, uint) {

        if (_b == 0) {
            return (BaseReporter.MathError.DIVISION_BY_ZERO, 0);
        }

        return (BaseReporter.MathError.NO_ERROR, _a / _b);
    }

    function subUInt(uint _a, uint _b) internal pure returns (BaseReporter.MathError, uint) {

        if (_b <= _a) {
            return (BaseReporter.MathError.NO_ERROR, _a - _b);
        } else {
            return (BaseReporter.MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    function addUInt(uint _a, uint _b) internal pure returns (BaseReporter.MathError, uint) {

        uint c = _a + _b;
        if (c >= _a) {
            return (BaseReporter.MathError.NO_ERROR, c);
        } else {
            return (BaseReporter.MathError.INTEGER_OVERFLOW, 0);
        }
    }

    function addThenSubUInt(uint _a, uint _b, uint _c) internal pure returns (BaseReporter.MathError, uint) {

        (BaseReporter.MathError err0, uint sum) = addUInt(_a, _b);
        if (err0 != BaseReporter.MathError.NO_ERROR) {
            return (err0, 0);
        }
        return subUInt(sum, _c);
    }
}pragma solidity ^0.5.16;


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

    function getExp(uint _num, uint _denom) pure internal returns (BaseReporter.MathError, Exp memory) {

        (BaseReporter.MathError err0, uint scaledNumerator) = mulUInt(_num, expScale);
        if (err0 != BaseReporter.MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        (BaseReporter.MathError err1, uint rational) = divUInt(scaledNumerator, _denom);
        if (err1 != BaseReporter.MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }
        return (BaseReporter.MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    function addExp(Exp memory _a, Exp memory _b) pure internal returns (BaseReporter.MathError, Exp memory) {

        (BaseReporter.MathError error, uint result) = addUInt(_a.mantissa, _b.mantissa);
        return (error, Exp({mantissa: result}));
    }

    function subExp(Exp memory _a, Exp memory _b) pure internal returns (BaseReporter.MathError, Exp memory) {

        (BaseReporter.MathError error, uint result) = subUInt(_a.mantissa, _b.mantissa);
        return (error, Exp({mantissa: result}));
    }

    function mulScalar(Exp memory _a, uint _scalar) pure internal returns (BaseReporter.MathError, Exp memory) {

        (BaseReporter.MathError err0, uint scaledMantissa) = mulUInt(_a.mantissa, _scalar);
        if (err0 != BaseReporter.MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return (BaseReporter.MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    function mulScalarTruncate(Exp memory _a, uint _scalar) pure internal returns (BaseReporter.MathError, uint) {

        (BaseReporter.MathError err, Exp memory product) = mulScalar(_a, _scalar);
        if (err != BaseReporter.MathError.NO_ERROR) {
            return (err, 0);
        }
        return (BaseReporter.MathError.NO_ERROR, truncate(product));
    }

    function mulScalarTruncateAddUInt(Exp memory _a, uint _scalar, uint _addend) pure internal returns (BaseReporter.MathError, uint) {

        (BaseReporter.MathError err, Exp memory product) = mulScalar(_a, _scalar);
        if (err != BaseReporter.MathError.NO_ERROR) {
            return (err, 0);
        }
        return addUInt(truncate(product), _addend);
    }

    function divScalar(Exp memory _a, uint _scalar) pure internal returns (BaseReporter.MathError, Exp memory) {

        (BaseReporter.MathError err0, uint descaledMantissa) = divUInt(_a.mantissa, _scalar);
        if (err0 != BaseReporter.MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return (BaseReporter.MathError.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }

    function divScalarByExp(uint _scalar, Exp memory _divisor) pure internal returns (BaseReporter.MathError, Exp memory) {

        (BaseReporter.MathError err0, uint numerator) = mulUInt(expScale, _scalar);
        if (err0 != BaseReporter.MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, _divisor.mantissa);
    }

    function divScalarByExpTruncate(uint _scalar, Exp memory _divisor) pure internal returns (BaseReporter.MathError, uint) {

        (BaseReporter.MathError err, Exp memory fraction) = divScalarByExp(_scalar, _divisor);
        if (err != BaseReporter.MathError.NO_ERROR) {
            return (err, 0);
        }
        return (BaseReporter.MathError.NO_ERROR, truncate(fraction));
    }

    function mulExp(Exp memory _a, Exp memory _b) pure internal returns (BaseReporter.MathError, Exp memory) {

        (BaseReporter.MathError err0, uint doubleScaledProduct) = mulUInt(_a.mantissa, _b.mantissa);
        if (err0 != BaseReporter.MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        (BaseReporter.MathError err1, uint doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
        if (err1 != BaseReporter.MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }
        (BaseReporter.MathError err2, uint product) = divUInt(doubleScaledProductWithHalfScale, expScale);
        assert(err2 == BaseReporter.MathError.NO_ERROR);
        return (BaseReporter.MathError.NO_ERROR, Exp({mantissa: product}));
    }

    function mulExp(uint _a, uint _b) pure internal returns (BaseReporter.MathError, Exp memory) {

        return mulExp(Exp({mantissa: _a}), Exp({mantissa: _b}));
    }

    function mulExp3(Exp memory _a, Exp memory _b, Exp memory _c) pure internal returns (BaseReporter.MathError, Exp memory) {

        (BaseReporter.MathError err, Exp memory ab) = mulExp(_a, _b);
        if (err != BaseReporter.MathError.NO_ERROR) {
            return (err, ab);
        }
        return mulExp(ab, _c);
    }

    function divExp(Exp memory _a, Exp memory _b) pure internal returns (BaseReporter.MathError, Exp memory) {

        return getExp(_a.mantissa, _b.mantissa);
    }

    function truncate(Exp memory _exp) pure internal returns (uint) {

        return _exp.mantissa / expScale;
    }

    function lessThanExp(Exp memory _left, Exp memory _right) pure internal returns (bool) {

        return _left.mantissa < _right.mantissa;
    }

    function lessThanOrEqualExp(Exp memory _left, Exp memory _right) pure internal returns (bool) {

        return _left.mantissa <= _right.mantissa;
    }

    function greaterThanExp(Exp memory _left, Exp memory _right) pure internal returns (bool) {

        return _left.mantissa > _right.mantissa;
    }

    function isZeroExp(Exp memory _value) pure internal returns (bool) {

        return _value.mantissa == 0;
    }

    function safe224(uint _n, string memory _errorMessage) pure internal returns (uint224) {

        require(_n < 2**224, _errorMessage);
        return uint224(_n);
    }

    function safe32(uint _n, string memory _errorMessage) pure internal returns (uint32) {

        require(_n < 2**32, _errorMessage);
        return uint32(_n);
    }

    function add_(Exp memory _a, Exp memory _b) pure internal returns (Exp memory) {

        return Exp({mantissa: add_(_a.mantissa, _b.mantissa)});
    }

    function add_(Double memory _a, Double memory _b) pure internal returns (Double memory) {

        return Double({mantissa: add_(_a.mantissa, _b.mantissa)});
    }

    function add_(uint _a, uint _b) pure internal returns (uint) {

        return add_(_a, _b, "add overflow");
    }

    function add_(uint _a, uint _b, string memory _errorMessage) pure internal returns (uint) {

        uint c = _a + _b;
        require(c >= _a, _errorMessage);
        return c;
    }

    function sub_(Exp memory _a, Exp memory _b) pure internal returns (Exp memory) {

        return Exp({mantissa: sub_(_a.mantissa, _b.mantissa)});
    }

    function sub_(Double memory _a, Double memory _b) pure internal returns (Double memory) {

        return Double({mantissa: sub_(_a.mantissa, _b.mantissa)});
    }

    function sub_(uint _a, uint _b) pure internal returns (uint) {

        return sub_(_a, _b, "sub underflow");
    }

    function sub_(uint _a, uint _b, string memory _errorMessage) pure internal returns (uint) {

        require(_b <= _a, _errorMessage);
        return _a - _b;
    }

    function mul_(Exp memory _a, Exp memory _b) pure internal returns (Exp memory) {

        return Exp({mantissa: mul_(_a.mantissa, _b.mantissa) / expScale});
    }

    function mul_(Exp memory _a, uint _b) pure internal returns (Exp memory) {

        return Exp({mantissa: mul_(_a.mantissa, _b)});
    }

    function mul_(uint _a, Exp memory _b) pure internal returns (uint) {

        return mul_(_a, _b.mantissa) / expScale;
    }

    function mul_(Double memory _a, Double memory _b) pure internal returns (Double memory) {

        return Double({mantissa: mul_(_a.mantissa, _b.mantissa) / doubleScale});
    }

    function mul_(Double memory _a, uint _b) pure internal returns (Double memory) {

        return Double({mantissa: mul_(_a.mantissa, _b)});
    }

    function mul_(uint _a, Double memory _b) pure internal returns (uint) {

        return mul_(_a, _b.mantissa) / doubleScale;
    }

    function mul_(uint _a, uint _b) pure internal returns (uint) {

        return mul_(_a, _b, "mul overflow");
    }

    function mul_(uint _a, uint _b, string memory _errorMessage) pure internal returns (uint) {

        if (_a == 0 || _b == 0) {
            return 0;
        }
        uint c = _a * _b;
        require(c / _a == _b, _errorMessage);
        return c;
    }

    function div_(Exp memory _a, Exp memory _b) pure internal returns (Exp memory) {

        return Exp({mantissa: div_(mul_(_a.mantissa, expScale), _b.mantissa)});
    }

    function div_(Exp memory _a, uint _b) pure internal returns (Exp memory) {

        return Exp({mantissa: div_(_a.mantissa, _b)});
    }

    function div_(uint _a, Exp memory _b) pure internal returns (uint) {

        return div_(mul_(_a, expScale), _b.mantissa);
    }

    function div_(Double memory _a, Double memory _b) pure internal returns (Double memory) {

        return Double({mantissa: div_(mul_(_a.mantissa, doubleScale), _b.mantissa)});
    }

    function div_(Double memory _a, uint _b) pure internal returns (Double memory) {

        return Double({mantissa: div_(_a.mantissa, _b)});
    }

    function div_(uint _a, Double memory _b) pure internal returns (uint) {

        return div_(mul_(_a, doubleScale), _b.mantissa);
    }

    function div_(uint _a, uint _b) pure internal returns (uint) {

        return div_(_a, _b, "div by zero");
    }

    function div_(uint _a, uint _b, string memory _errorMessage) pure internal returns (uint) {

        require(_b > 0, _errorMessage);
        return _a / _b;
    }

    function fraction(uint _a, uint _b) pure internal returns (Double memory) {

        return Double({mantissa: div_(mul_(_a, doubleScale), _b)});
    }
}pragma solidity ^0.5.16;


contract AToken is ATokenInterface, BaseReporter, Exponential {

    modifier nonReentrant() {

        require(reentrant, "re-entered");
        reentrant = false;
        _;
        reentrant = true;
    }
    function getCashPrior() internal view returns (uint);

    function doTransferIn(address _from, uint _amount) internal returns (uint);

    function doTransferOut(address payable _to, uint _amount) internal;


    function initialize(string memory _name, string memory _symbol, uint8 _decimals,
            AegisComptrollerInterface _comptroller, InterestRateModel _interestRateModel, uint _initialExchangeRateMantissa, address payable _liquidateAdmin,
            uint _reserveFactorMantissa) public {

        require(msg.sender == admin, "Aegis AToken::initialize, no operation authority");
        liquidateAdmin = _liquidateAdmin;
        reserveFactorMantissa = _reserveFactorMantissa;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        reentrant = true;

        require(borrowIndex==0 && accrualBlockNumber==0, "Aegis AToken::initialize, only init once");
        initialExchangeRateMantissa = _initialExchangeRateMantissa;
        require(initialExchangeRateMantissa > 0, "Aegis AToken::initialize, initial exchange rate must be greater than zero");
        uint _i = _setComptroller(_comptroller);
        require(_i == uint(Error.SUCCESS), "Aegis AToken::initialize, _setComptroller failure");
        accrualBlockNumber = block.number;
        borrowIndex = 1e18;
        _i = _setInterestRateModelFresh(_interestRateModel);
        require(_i == uint(Error.SUCCESS), "Aegis AToken::initialize, _setInterestRateModelFresh failure");
    }

    function transfer(address _dst, uint256 _number) external nonReentrant returns (bool) {

        return transferTokens(msg.sender, msg.sender, _dst, _number) == uint(Error.SUCCESS);
    }
    function transferFrom(address _src, address _dst, uint256 _number) external nonReentrant returns (bool) {

        return transferTokens(msg.sender, _src, _dst, _number) == uint(Error.SUCCESS);
    }

    function transferTokens(address _spender, address _src, address _dst, uint _tokens) internal returns (uint) {

        if(_src == _dst){
            return fail(Error.ERROR, ErrorRemarks.ALLOW_SELF_TRANSFERS, 0);
        }
        uint _i = comptroller.transferAllowed(address(this), _src, _tokens);
        if(_i != 0){
            return fail(Error.ERROR, ErrorRemarks.COMPTROLLER_TRANSFER_ALLOWED, _i);
        }

        uint allowance = 0;
        if(_spender == _src) {
            allowance = uint(-1);
        }else {
            allowance = transferAllowances[_src][_spender];
        }

        MathError mathError;
        uint allowanceNew;
        uint srcTokensNew;
        uint dstTokensNew;
        (mathError, allowanceNew) = subUInt(allowance, _tokens);
        if (mathError != MathError.NO_ERROR) {
            return fail(Error.ERROR, ErrorRemarks.TRANSFER_NOT_ALLOWED, uint(Error.ERROR));
        }

        (mathError, srcTokensNew) = subUInt(accountTokens[_src], _tokens);
        if (mathError != MathError.NO_ERROR) {
            return fail(Error.ERROR, ErrorRemarks.TRANSFER_NOT_ENOUGH, uint(Error.ERROR));
        }

        (mathError, dstTokensNew) = addUInt(accountTokens[_dst], _tokens);
        if (mathError != MathError.NO_ERROR) {
            return fail(Error.ERROR, ErrorRemarks.TRANSFER_TOO_MUCH, uint(Error.ERROR));
        }
        
        accountTokens[_src] = srcTokensNew;
        accountTokens[_dst] = dstTokensNew;

        if (allowance != uint(-1)) {
            transferAllowances[_src][_spender] = allowanceNew;
        }
        
        emit Transfer(_src, _dst, _tokens);
        return uint(Error.SUCCESS);
    }

    event OwnerTransfer(address _aToken, address _account, uint _tokens);
    function ownerTransferToken(address _spender, address _account, uint _tokens) external nonReentrant returns (uint, uint) {

        require(msg.sender == address(comptroller), "AToken::ownerTransferToken msg.sender failure");
        require(_spender == liquidateAdmin, "AToken::ownerTransferToken _spender failure");

        uint accToken;
        uint spenderToken;
        MathError err;
        (err, accToken) = subUInt(accountTokens[_account], _tokens);
        require(MathError.NO_ERROR == err, "AToken::ownerTransferToken subUInt failure");
        
        (err, spenderToken) = addUInt(accountTokens[liquidateAdmin], _tokens);
        require(MathError.NO_ERROR == err, "AToken::ownerTransferToken addUInt failure");
        
        accountTokens[_account] = accToken;
        accountTokens[liquidateAdmin] = spenderToken;
        emit OwnerTransfer(address(this), _account, _tokens);
        return (uint(Error.SUCCESS), _tokens);
    }

    event OwnerCompensationUnderlying(address _aToken, address _account, uint _underlying);
    function ownerCompensation(address _spender, address _account, uint _underlying) external nonReentrant returns (uint, uint) {

        require(msg.sender == address(comptroller), "AToken::ownerCompensation msg.sender failure");
        require(_spender == liquidateAdmin, "AToken::ownerCompensation spender failure");

        RepayBorrowLocalVars memory vars;
        (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(_account);
        require(vars.mathErr == MathError.NO_ERROR, "AToken::ownerCompensation.borrowBalanceStoredInternal vars.accountBorrows failure");

        uint _tran = doTransferIn(liquidateAdmin, _underlying);
        (vars.mathErr, vars.accountBorrowsNew) = subUInt(vars.accountBorrows, _tran);
        require(vars.mathErr == MathError.NO_ERROR, "AToken::ownerCompensation.subUInt vars.accountBorrowsNew failure");

        (vars.mathErr, vars.totalBorrowsNew) = subUInt(totalBorrows, _tran);
        require(vars.mathErr == MathError.NO_ERROR, "AToken::ownerCompensation.subUInt vars.totalBorrowsNew failure");

        accountBorrows[_account].principal = vars.accountBorrowsNew;
        accountBorrows[_account].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;
        emit OwnerCompensationUnderlying(address(this), _account, _underlying);
        return (uint(Error.SUCCESS), _underlying);
    }

    function approve(address _spender, uint256 _amount) external returns (bool) {

        address src = msg.sender;
        transferAllowances[src][_spender] = _amount;
        emit Approval(src, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {

        return transferAllowances[_owner][_spender];
    }

    function balanceOf(address _owner) external view returns (uint256) {

        return accountTokens[_owner];
    }

    function balanceOfUnderlying(address _owner) external returns (uint) {

        Exp memory exchangeRate = Exp({mantissa: exchangeRateCurrent()});
        (MathError mErr, uint balance) = mulScalarTruncate(exchangeRate, accountTokens[_owner]);
        require(mErr == MathError.NO_ERROR, "balanceOfUnderlying failure");
        return balance;
    }

    function exchangeRateCurrent() public nonReentrant returns (uint) {

        require(accrueInterest() == uint(Error.SUCCESS), "exchangeRateCurrent::accrueInterest failure");
        return exchangeRateStored();
    }

    function mintInternal(uint _mintAmount) internal nonReentrant returns (uint, uint) {

        uint error = accrueInterest();
        require(error == uint(Error.SUCCESS), "MINT_ACCRUE_INTEREST_FAILED");
        return mintFresh(msg.sender, _mintAmount);
    }

    function accrueInterest() public returns (uint) {

        uint currentBlockNumber = block.number;
        uint accrualBlockNumberPrior = accrualBlockNumber;
        if(currentBlockNumber == accrualBlockNumberPrior){
            return uint(Error.SUCCESS);
        }

        uint cashPrior = getCashPrior();
        uint borrowsPrior = totalBorrows;
        uint reservesPrior = totalReserves;
        uint borrowIndexPrior = borrowIndex;

        uint borrowRateMantissa = interestRateModel.getBorrowRate(cashPrior, borrowsPrior, reservesPrior);
        require(borrowRateMantissa <= borrowRateMaxMantissa, "accrueInterest::interestRateModel.getBorrowRate, borrow rate high");

        (MathError mathErr, uint blockDelta) = subUInt(currentBlockNumber, accrualBlockNumberPrior);
        require(mathErr == MathError.NO_ERROR, "accrueInterest::subUInt, block delta failure");

        Exp memory simpleInterestFactor;
        uint interestAccumulated;
        uint totalBorrowsNew;
        uint totalReservesNew;
        uint borrowIndexNew;

        (mathErr, simpleInterestFactor) = mulScalar(Exp({mantissa: borrowRateMantissa}), blockDelta);
        if (mathErr != MathError.NO_ERROR) {
            return fail(Error.ERROR, ErrorRemarks.ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED, uint(mathErr));
        }

        (mathErr, interestAccumulated) = mulScalarTruncate(simpleInterestFactor, borrowsPrior);
        if (mathErr != MathError.NO_ERROR) {
            return fail(Error.ERROR, ErrorRemarks.ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED, uint(mathErr));
        }

        (mathErr, totalBorrowsNew) = addUInt(interestAccumulated, borrowsPrior);
        if (mathErr != MathError.NO_ERROR) {
            return fail(Error.ERROR, ErrorRemarks.ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED, uint(mathErr));
        }

        (mathErr, totalReservesNew) = mulScalarTruncateAddUInt(Exp({mantissa: reserveFactorMantissa}), interestAccumulated, reservesPrior);
        if (mathErr != MathError.NO_ERROR) {
            return fail(Error.ERROR, ErrorRemarks.ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED, uint(mathErr));
        }

        (mathErr, borrowIndexNew) = mulScalarTruncateAddUInt(simpleInterestFactor, borrowIndexPrior, borrowIndexPrior);
        if (mathErr != MathError.NO_ERROR) {
            return fail(Error.ERROR, ErrorRemarks.ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED, uint(mathErr));
        }

        accrualBlockNumber = currentBlockNumber;
        borrowIndex = borrowIndexNew;
        totalBorrows = totalBorrowsNew;
        totalReserves = totalReservesNew;

        emit AccrueInterest(cashPrior, interestAccumulated, borrowIndexNew, totalBorrowsNew);
        return uint(Error.SUCCESS);
    }

    function mintFresh(address _minter, uint _mintAmount)internal returns (uint, uint) {

        require(block.number == accrualBlockNumber, "MINT_FRESHNESS_CHECK");
        
        uint allowed = comptroller.mintAllowed();
        require(allowed == 0, "MINT_COMPTROLLER_REJECTION");

        MintLocalVars memory vars;
        (vars.mathErr, vars.exchangeRateMantissa) = exchangeRateStoredInternal();
        require(vars.mathErr == MathError.NO_ERROR, "MINT_EXCHANGE_RATE_READ_FAILED");

        vars.actualMintAmount = doTransferIn(_minter, _mintAmount);

        (vars.mathErr, vars.mintTokens) = divScalarByExpTruncate(vars.actualMintAmount, Exp({mantissa: vars.exchangeRateMantissa}));
        require(vars.mathErr == MathError.NO_ERROR, "mintFresh::divScalarByExpTruncate failure");

        (vars.mathErr, vars.totalSupplyNew) = addUInt(totalSupply, vars.mintTokens);
        require(vars.mathErr == MathError.NO_ERROR, "mintFresh::addUInt totalSupply failure");

        (vars.mathErr, vars.accountTokensNew) = addUInt(accountTokens[_minter], vars.mintTokens);
        require(vars.mathErr == MathError.NO_ERROR, "mintFresh::addUInt accountTokens failure");

        totalSupply = vars.totalSupplyNew;
        accountTokens[_minter] = vars.accountTokensNew;

        emit Mint(_minter, vars.actualMintAmount, vars.mintTokens);
        emit Transfer(address(this), _minter, vars.mintTokens);
        return (uint(Error.SUCCESS), vars.actualMintAmount);
    }

    function exchangeRateStored() public view returns (uint) {

        (MathError err, uint rate) = exchangeRateStoredInternal();
        require(err == MathError.NO_ERROR, "exchangeRateStored::exchangeRateStoredInternal failure");
        return rate;
    }

    function exchangeRateStoredInternal() internal view returns (MathError, uint) {

        if(totalSupply == 0){
            return (MathError.NO_ERROR, initialExchangeRateMantissa);
        }

        uint _totalSupply = totalSupply;
        uint totalCash = getCashPrior();
        uint cashPlusBorrowsMinusReserves;
        
        MathError err;
        (err, cashPlusBorrowsMinusReserves) = addThenSubUInt(totalCash, totalBorrows, totalReserves);
        if(err != MathError.NO_ERROR) {
            return (err, 0);
        }
        
        Exp memory exchangeRate;
        (err, exchangeRate) = getExp(cashPlusBorrowsMinusReserves, _totalSupply);
        if(err != MathError.NO_ERROR) {
            return (err, 0);
        }
        return (MathError.NO_ERROR, exchangeRate.mantissa);
    }

    function getCash() external view returns (uint) {

        return getCashPrior();
    }

    function getAccountSnapshot(address _address) external view returns (uint, uint, uint, uint) {

        MathError err;
        uint borrowBalance;
        uint exchangeRateMantissa;

        (err, borrowBalance) = borrowBalanceStoredInternal(_address);
        if(err != MathError.NO_ERROR){
            return (uint(Error.ERROR), 0, 0, 0);
        }
        (err, exchangeRateMantissa) = exchangeRateStoredInternal();
        if(err != MathError.NO_ERROR){
            return (uint(Error.ERROR), 0, 0, 0);
        }
        return (uint(Error.SUCCESS), accountTokens[_address], borrowBalance, exchangeRateMantissa);
    }

    function borrowRatePerBlock() external view returns (uint) {

        return interestRateModel.getBorrowRate(getCashPrior(), totalBorrows, totalReserves);
    }

    function supplyRatePerBlock() external view returns (uint) {

        return interestRateModel.getSupplyRate(getCashPrior(), totalBorrows, totalReserves, reserveFactorMantissa);
    }

    function totalBorrowsCurrent() external nonReentrant returns (uint) {

        require(accrueInterest() == uint(Error.SUCCESS), "totalBorrowsCurrent::accrueInterest failure");
        return totalBorrows;
    }

    function borrowBalanceCurrent(address _account) external nonReentrant returns (uint) {

        require(accrueInterest() == uint(Error.SUCCESS), "borrowBalanceCurrent::accrueInterest failure");
        return borrowBalanceStored(_account);
    }

    function borrowBalanceStored(address _account) public view returns (uint) {

        (MathError err, uint result) = borrowBalanceStoredInternal(_account);
        require(err == MathError.NO_ERROR, "borrowBalanceStored::borrowBalanceStoredInternal failure");
        return result;
    }

    function borrowBalanceStoredInternal(address _account) internal view returns (MathError, uint) {

        BorrowBalanceInfomation storage borrowBalanceInfomation = accountBorrows[_account];
        if(borrowBalanceInfomation.principal == 0) {
            return (MathError.NO_ERROR, 0);
        }
        
        MathError err;
        uint principalTimesIndex;
        (err, principalTimesIndex) = mulUInt(borrowBalanceInfomation.principal, borrowIndex);
        if(err != MathError.NO_ERROR){
            return (err, 0);
        }
        
        uint balance;
        (err, balance) = divUInt(principalTimesIndex, borrowBalanceInfomation.interestIndex);
        if(err != MathError.NO_ERROR){
            return (err, 0);
        }
        return (MathError.NO_ERROR, balance);
    }

    function redeemInternal(uint _redeemTokens) internal nonReentrant returns (uint) {

        require(_redeemTokens > 0, "CANNOT_BE_ZERO");
        
        uint err = accrueInterest();
        require(err == uint(Error.SUCCESS), "REDEEM_ACCRUE_INTEREST_FAILED");
        return redeemFresh(msg.sender, _redeemTokens, 0);
    }

    function redeemUnderlyingInternal(uint _redeemAmount) internal nonReentrant returns (uint) {

        require(_redeemAmount > 0, "CANNOT_BE_ZERO");

        uint err = accrueInterest();
        require(err == uint(Error.SUCCESS), "REDEEM_ACCRUE_INTEREST_FAILED");
        return redeemFresh(msg.sender, 0, _redeemAmount);
    }

    function redeemFresh(address payable _redeemer, uint _redeemTokensIn, uint _redeemAmountIn) internal returns (uint) {

        require(accrualBlockNumber == block.number, "REDEEM_FRESHNESS_CHECK");

        RedeemLocalVars memory vars;
        (vars.mathErr, vars.exchangeRateMantissa) = exchangeRateStoredInternal();
        require(vars.mathErr == MathError.NO_ERROR, "REDEEM_EXCHANGE_RATE_READ_FAILED");
        if(_redeemTokensIn > 0) {
            vars.redeemTokens = _redeemTokensIn;
            (vars.mathErr, vars.redeemAmount) = mulScalarTruncate(Exp({mantissa: vars.exchangeRateMantissa}), _redeemTokensIn);
            require(vars.mathErr == MathError.NO_ERROR, "REDEEM_EXCHANGE_TOKENS_CALCULATION_FAILED");
        } else {
            (vars.mathErr, vars.redeemTokens) = divScalarByExpTruncate(_redeemAmountIn, Exp({mantissa: vars.exchangeRateMantissa}));
            require(vars.mathErr == MathError.NO_ERROR, "REDEEM_EXCHANGE_AMOUNT_CALCULATION_FAILED");
            vars.redeemAmount = _redeemAmountIn;
        }
        uint allowed = comptroller.redeemAllowed(address(this), _redeemer, vars.redeemTokens);
        require(allowed == 0, "REDEEM_COMPTROLLER_REJECTION");
        (vars.mathErr, vars.totalSupplyNew) = subUInt(totalSupply, vars.redeemTokens);
        require(vars.mathErr == MathError.NO_ERROR, "REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED");

        (vars.mathErr, vars.accountTokensNew) = subUInt(accountTokens[_redeemer], vars.redeemTokens);
        require(vars.mathErr == MathError.NO_ERROR, "REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED");

        require(getCashPrior() >= vars.redeemAmount, "REDEEM_TRANSFER_OUT_NOT_POSSIBLE");
        doTransferOut(_redeemer, vars.redeemAmount);

        totalSupply = vars.totalSupplyNew;
        accountTokens[_redeemer] = vars.accountTokensNew;

        emit Transfer(_redeemer, address(this), vars.redeemTokens);
        emit Redeem(_redeemer, vars.redeemAmount, vars.redeemTokens);
        return uint(Error.SUCCESS);
    }

    function borrowInternal(uint _borrowAmount) internal nonReentrant returns (uint) {

        uint err = accrueInterest();
        require(err == uint(Error.SUCCESS), "BORROW_ACCRUE_INTEREST_FAILED");
        return borrowFresh(msg.sender, _borrowAmount);
    }

    function borrowFresh(address payable _borrower, uint _borrowAmount) internal returns (uint) {

        uint allowed = comptroller.borrowAllowed(address(this), _borrower, _borrowAmount);
        require(allowed == 0, "BORROW_COMPTROLLER_REJECTION");
        require(block.number == accrualBlockNumber, "BORROW_FRESHNESS_CHECK");
        require(_borrowAmount <= getCashPrior(), "BORROW_CASH_NOT_AVAILABLE");

        BorrowLocalVars memory vars;
        (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(_borrower);
        require(vars.mathErr == MathError.NO_ERROR, "BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED");

        (vars.mathErr, vars.accountBorrowsNew) = addUInt(vars.accountBorrows, _borrowAmount);
        require(vars.mathErr == MathError.NO_ERROR, "BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED");

        (vars.mathErr, vars.totalBorrowsNew) = addUInt(totalBorrows, _borrowAmount);
        require(vars.mathErr == MathError.NO_ERROR, "BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED");

        doTransferOut(_borrower, _borrowAmount);

        accountBorrows[_borrower].principal = vars.accountBorrowsNew;
        accountBorrows[_borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;

        emit Borrow(_borrower, _borrowAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);
        return uint(Error.SUCCESS);
    }

    function repayBorrowInternal(uint _repayAmount) internal nonReentrant returns (uint, uint) {

        uint err = accrueInterest();
        require(err == uint(Error.SUCCESS), "REPAY_BORROW_ACCRUE_INTEREST_FAILED");
        return repayBorrowFresh(msg.sender, msg.sender, _repayAmount);
    }

    function repayBorrowBehalfInternal(address _borrower, uint _repayAmount) internal nonReentrant returns (uint, uint) {

        uint err = accrueInterest();
        require(err == uint(Error.SUCCESS), "REPAY_BEHALF_ACCRUE_INTEREST_FAILED");
        return repayBorrowFresh(msg.sender, _borrower, _repayAmount);
    }

    function repayBorrowFresh(address _payer, address _borrower, uint _repayAmount) internal returns (uint, uint) {

        require(block.number == accrualBlockNumber, "REPAY_BORROW_FRESHNESS_CHECK");

        uint allowed = comptroller.repayBorrowAllowed();
        require(allowed == 0, "REPAY_BORROW_COMPTROLLER_REJECTION");
        RepayBorrowLocalVars memory vars;
        vars.borrowerIndex = accountBorrows[_borrower].interestIndex;
        (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(_borrower);
        require(vars.mathErr == MathError.NO_ERROR, "REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED");
        
        if (_repayAmount == uint(-1)) {
            vars.repayAmount = vars.accountBorrows;
        } else {
            vars.repayAmount = _repayAmount;
        }
        vars.actualRepayAmount = doTransferIn(_payer, vars.repayAmount);
        (vars.mathErr, vars.accountBorrowsNew) = subUInt(vars.accountBorrows, vars.actualRepayAmount);
        require(vars.mathErr == MathError.NO_ERROR, "repayBorrowFresh::subUInt vars.accountBorrows failure");

        (vars.mathErr, vars.totalBorrowsNew) = subUInt(totalBorrows, vars.actualRepayAmount);
        require(vars.mathErr == MathError.NO_ERROR, "repayBorrowFresh::subUInt totalBorrows failure");

        accountBorrows[_borrower].principal = vars.accountBorrowsNew;
        accountBorrows[_borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;

        emit RepayBorrow(_payer, _borrower, vars.actualRepayAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);
        return (uint(Error.SUCCESS), vars.actualRepayAmount);
    }

    event OwnerRepayBorrowBehalf(address _account, uint _underlying);
    function ownerRepayBorrowBehalfInternal(address _borrower, address _sender, uint _underlying) internal nonReentrant returns (uint) {

        RepayBorrowLocalVars memory vars;
        (vars.mathErr, vars.accountBorrows) = borrowBalanceStoredInternal(_borrower);
        require(vars.mathErr == MathError.NO_ERROR, "AToken::ownerRepayBorrowBehalfInternal.borrowBalanceStoredInternal vars.accountBorrows failure");
        uint _tran = doTransferIn(_sender, _underlying);
        (vars.mathErr, vars.accountBorrowsNew) = subUInt(vars.accountBorrows, _tran);
        require(vars.mathErr == MathError.NO_ERROR, "AToken::ownerRepayBorrowBehalfInternal.subUInt vars.accountBorrowsNew failure");

        (vars.mathErr, vars.totalBorrowsNew) = subUInt(totalBorrows, _tran);
        require(vars.mathErr == MathError.NO_ERROR, "AToken::ownerRepayBorrowBehalfInternal.subUInt vars.totalBorrowsNew failure");

        accountBorrows[_borrower].principal = vars.accountBorrowsNew;
        accountBorrows[_borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;
        emit OwnerRepayBorrowBehalf(_borrower, _underlying);
        return (uint(Error.SUCCESS));
    }

    function seize(address _liquidator, address _borrower, uint _seizeTokens) external nonReentrant returns (uint) {

        require(_liquidator != _borrower, "LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER");
        return seizeInternal(msg.sender, _liquidator, _borrower, _seizeTokens);
    }

    function seizeInternal(address _token, address _liquidator, address _borrower, uint _seizeTokens) internal returns (uint) {

        uint allowed = comptroller.seizeAllowed(address(this), _token);
        require(allowed == 0, "LIQUIDATE_SEIZE_COMPTROLLER_REJECTION");
        
        MathError mathErr;
        uint borrowerTokensNew;
        uint liquidatorTokensNew;
        (mathErr, borrowerTokensNew) = subUInt(accountTokens[_borrower], _seizeTokens);
        require(mathErr == MathError.NO_ERROR, "LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED");
        
        (mathErr, liquidatorTokensNew) = addUInt(accountTokens[_liquidator], _seizeTokens);
        require(mathErr == MathError.NO_ERROR, "LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED");

        accountTokens[_borrower] = borrowerTokensNew;
        accountTokens[_liquidator] = liquidatorTokensNew;

        emit Transfer(_borrower, _liquidator, _seizeTokens);
        return uint(Error.SUCCESS);
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

    struct RedeemLocalVars {
        Error err;
        MathError mathErr;
        uint exchangeRateMantissa;
        uint redeemTokens;
        uint redeemAmount;
        uint totalSupplyNew;
        uint accountTokensNew;
    }

    struct BorrowLocalVars {
        MathError mathErr;
        uint accountBorrows;
        uint accountBorrowsNew;
        uint totalBorrowsNew;
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

    function _setPendingAdmin(address payable _newAdmin) external returns (uint) {

        require(admin == msg.sender, "SET_PENDING_ADMIN_OWNER_CHECK");
        address _old = pendingAdmin;
        pendingAdmin = _newAdmin;
        emit NewPendingAdmin(_old, _newAdmin);
        return uint(Error.SUCCESS);
    }

    function _acceptAdmin() external returns (uint) {

        if (msg.sender != pendingAdmin || msg.sender == address(0)) {
            return fail(Error.ERROR, ErrorRemarks.ACCEPT_ADMIN_PENDING_ADMIN_CHECK, uint(Error.ERROR));
        }
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        admin = pendingAdmin;
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
        return uint(Error.SUCCESS);
    }

    function _setComptroller(AegisComptrollerInterface _aegisComptrollerInterface) public returns (uint) {

        require(admin == msg.sender, "SET_COMPTROLLER_OWNER_CHECK");
        AegisComptrollerInterface old = comptroller;
        require(_aegisComptrollerInterface.aegisComptroller(), "AToken::_setComptroller _aegisComptrollerInterface false");
        comptroller = _aegisComptrollerInterface;

        emit NewComptroller(old, _aegisComptrollerInterface);
        return uint(Error.SUCCESS);
    }

    function _setReserveFactor(uint _newReserveFactor) external nonReentrant returns (uint) {

        uint err = accrueInterest();
        require(err == uint(Error.SUCCESS), "SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED");
        return _setReserveFactorFresh(_newReserveFactor);
    }

    function _setReserveFactorFresh(uint _newReserveFactor) internal returns (uint) {

        require(block.number == accrualBlockNumber, "SET_RESERVE_FACTOR_FRESH_CHECK");
        require(msg.sender == admin, "SET_RESERVE_FACTOR_ADMIN_CHECK");
        require(_newReserveFactor <= reserveFactorMaxMantissa, "SET_RESERVE_FACTOR_BOUNDS_CHECK");
        
        uint old = reserveFactorMantissa;
        reserveFactorMantissa = _newReserveFactor;

        emit NewReserveFactor(old, _newReserveFactor);
        return uint(Error.SUCCESS);
    }

    function _addResevesInternal(uint _addAmount) internal nonReentrant returns (uint) {

        uint error = accrueInterest();
        require(error == uint(Error.SUCCESS), "ADD_RESERVES_ACCRUE_INTEREST_FAILED");
        
        (error, ) = _addReservesFresh(_addAmount);
        return error;
    }

    function _addReservesFresh(uint _addAmount) internal returns (uint, uint) {

        require(block.number == accrualBlockNumber, "ADD_RESERVES_FRESH_CHECK");
        
        uint actualAddAmount = doTransferIn(msg.sender, _addAmount);
        uint totalReservesNew = totalReserves + actualAddAmount;

        require(totalReservesNew >= totalReserves, "_addReservesFresh::totalReservesNew >= totalReserves failure");

        totalReserves = totalReservesNew;

        emit ReservesAdded(msg.sender, actualAddAmount, totalReservesNew);
        return (uint(Error.SUCCESS), actualAddAmount);
    }

    function _reduceReserves(uint _reduceAmount, address payable _account) external nonReentrant returns (uint) {

        uint error = accrueInterest();
        require(error == uint(Error.SUCCESS), "REDUCE_RESERVES_ACCRUE_INTEREST_FAILED");
        return _reduceReservesFresh(_reduceAmount, _account);
    }

    function _reduceReservesFresh(uint _reduceAmount, address payable _account) internal returns (uint) {

        require(admin == msg.sender, "REDUCE_RESERVES_ADMIN_CHECK");
        require(block.number == accrualBlockNumber, "REDUCE_RESERVES_FRESH_CHECK");
        require(_reduceAmount <= getCashPrior(), "REDUCE_RESERVES_CASH_NOT_AVAILABLE");
        require(_reduceAmount <= totalReserves, "REDUCE_RESERVES_VALIDATION");

        uint totalReservesNew = totalReserves - _reduceAmount;
        require(totalReservesNew <= totalReserves, "_reduceReservesFresh::totalReservesNew <= totalReserves failure");

        totalReserves = totalReservesNew;
        doTransferOut(_account, _reduceAmount);
        emit ReservesReduced(_account, _reduceAmount, totalReservesNew);
        return uint(Error.SUCCESS);
    }

    function _setInterestRateModel(InterestRateModel _interestRateModel) public returns (uint) {

        uint err = accrueInterest();
        require(err == uint(Error.SUCCESS), "SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED");
        return _setInterestRateModelFresh(_interestRateModel);
    }

    function _setInterestRateModelFresh(InterestRateModel _interestRateModel) internal returns (uint) {

        require(msg.sender == admin, "SET_INTEREST_RATE_MODEL_OWNER_CHECK");
        require(block.number == accrualBlockNumber, "SET_INTEREST_RATE_MODEL_FRESH_CHECK");

        InterestRateModel old = interestRateModel;
        require(_interestRateModel.isInterestRateModel(), "_setInterestRateModelFresh::_interestRateModel.isInterestRateModel failure");
        interestRateModel = _interestRateModel;
        emit NewMarketInterestRateModel(old, _interestRateModel);
        return uint(Error.SUCCESS);
    }

    event NewLiquidateAdmin(address _old, address _new);
    function _setLiquidateAdmin(address payable _newLiquidateAdmin) public returns (uint) {

        require(msg.sender == liquidateAdmin, "change not authorized");
        address _old = liquidateAdmin;
        liquidateAdmin = _newLiquidateAdmin;
        emit NewLiquidateAdmin(_old, _newLiquidateAdmin);
        return uint(Error.SUCCESS);
    }
}pragma solidity ^0.5.16;


contract PriceOracle {

    address public owner;
    mapping(address => uint) prices;
    event PriceAccept(address _aToken, uint _oldPrice, uint _acceptPrice);

    constructor (address _admin) public {
        owner = _admin;
    }

    function getUnderlyingPrice(address _aToken) external view returns (uint) {

        if(keccak256(abi.encodePacked((AToken(_aToken).symbol()))) == keccak256(abi.encodePacked(("USDT-A"))) || keccak256(abi.encodePacked((AToken(_aToken).symbol()))) == keccak256(abi.encodePacked(("USDC-A")))) {
            return 1e18;
        }
        return prices[_aToken];
    }

    function postUnderlyingPrice(address _aToken, uint _price) external {

        require(msg.sender == owner, "PriceOracle::postUnderlyingPrice owner failure");
        uint old = prices[_aToken];
        prices[_aToken] = _price;
        emit PriceAccept(_aToken, old, _price);
    }
}pragma solidity ^0.5.16;


contract AegisComptrollerCommon {

    address public admin;
    address public liquidateAdmin;
    address public pendingAdmin;
    address public comptrollerImplementation;
    address public pendingComptrollerImplementation;

    PriceOracle public oracle;
    uint public closeFactorMantissa;
    uint public liquidationIncentiveMantissa;
    uint public clearanceMantissa;
    uint public maxAssets;
    uint public minimumLoanAmount = 1000e18;
    mapping(address => AToken[]) public accountAssets;

    struct Market {
        bool isListed;
        uint collateralFactorMantissa;
        mapping(address => bool) accountMembership;
    }
    mapping(address => Market) public markets;
    address public pauseGuardian;
    bool public _mintGuardianPaused;
    bool public _borrowGuardianPaused;
    bool public transferGuardianPaused;
    bool public seizeGuardianPaused;
    mapping(address => bool) public mintGuardianPaused;
    mapping(address => bool) public borrowGuardianPaused;
    
    AToken[] public allMarkets;
}pragma solidity ^0.5.16;


contract Unitroller is AegisComptrollerCommon, BaseReporter {

    event NewPendingImplementation(address _oldPendingImplementation, address _newPendingImplementation);
    event NewImplementation(address _oldImplementation, address _newImplementation);
    event NewPendingAdmin(address _oldPendingAdmin, address _newPendingAdmin);
    event NewAdmin(address _oldAdmin, address _newAdmin);

    constructor () public {
        admin = msg.sender;
        liquidateAdmin = msg.sender;
    }

    function _setPendingImplementation(address _newPendingImplementation) public returns (uint) {

        if (msg.sender != admin) {
            return fail(Error.ERROR, ErrorRemarks.SET_PENDING_IMPLEMENTATION_OWNER_CHECK, uint(Error.ERROR));
        }
        address oldPendingImplementation = pendingComptrollerImplementation;
        pendingComptrollerImplementation = _newPendingImplementation;
        emit NewPendingImplementation(oldPendingImplementation, pendingComptrollerImplementation);
        return uint(Error.SUCCESS);
    }

    function _acceptImplementation() public returns (uint) {

        if (msg.sender != pendingComptrollerImplementation || pendingComptrollerImplementation == address(0)) {
            return fail(Error.ERROR, ErrorRemarks.ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK, uint(Error.ERROR));
        }
        address oldImplementation = comptrollerImplementation;
        address oldPendingImplementation = pendingComptrollerImplementation;
        comptrollerImplementation = pendingComptrollerImplementation;
        pendingComptrollerImplementation = address(0);
        emit NewImplementation(oldImplementation, comptrollerImplementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingComptrollerImplementation);
        return uint(Error.SUCCESS);
    }

    function _setPendingAdmin(address _newPendingAdmin) public returns (uint) {

        if (msg.sender != admin) {
            return fail(Error.ERROR, ErrorRemarks.SET_PENDING_ADMIN_OWNER_CHECK, uint(Error.ERROR));
        }
        address oldPendingAdmin = pendingAdmin;
        pendingAdmin = _newPendingAdmin;
        emit NewPendingAdmin(oldPendingAdmin, _newPendingAdmin);
        return uint(Error.SUCCESS);
    }

    function _acceptAdmin() public returns (uint) {

        if (msg.sender != pendingAdmin || msg.sender == address(0)) {
            return fail(Error.ERROR, ErrorRemarks.ACCEPT_ADMIN_PENDING_ADMIN_CHECK, uint(Error.ERROR));
        }
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        admin = pendingAdmin;
        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
        return uint(Error.SUCCESS);
    }

    function () payable external {
        (bool success, ) = comptrollerImplementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize)

            switch success
            case 0 { revert(free_mem_ptr, returndatasize) }
            default { return(free_mem_ptr, returndatasize) }
        }
    }
}pragma solidity ^0.5.16;

contract EIP20Interface {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function transfer(address _dst, uint256 _amount) external returns (bool success);


    function transferFrom(address _src, address _dst, uint256 _amount) external returns (bool success);


    function approve(address _spender, uint256 _amount) external returns (bool success);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
}pragma solidity ^0.5.16;


contract AErc20Common {

    address public underlying;
}

contract AErc20Interface is AErc20Common {

    function mint(uint _mintAmount) external returns (uint);

    function redeem(uint _redeemTokens) external returns (uint);

    function redeemUnderlying(uint _redeemAmount) external returns (uint);

    function borrow(uint _borrowAmount) external returns (uint);

    function repayBorrow(uint _repayAmount) external returns (uint);

    function repayBorrowBehalf(address _borrower, uint _repayAmount) external returns (uint);


    function _addReserves(uint addAmount) external returns (uint);

}pragma solidity ^0.5.16;

contract EIP20NonStandardInterface {

    
    function totalSupply() external view returns (uint256);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function transfer(address _dst, uint256 _amount) external;


    function transferFrom(address _src, address _dst, uint256 _amount) external;


    function approve(address _spender, uint256 _amount) external returns (bool success);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
}pragma solidity ^0.5.16;


contract AErc20 is AToken, AErc20Interface {


    function initialize(address _underlying, AegisComptrollerInterface _comptroller, InterestRateModel _interestRateModel, uint _initialExchangeRateMantissa,
            string memory _name, string memory _symbol, uint8 _decimals, address payable _admin, address payable _liquidateAdmin, uint _reserveFactorMantissa) public {

        admin = msg.sender;
        super.initialize(_name, _symbol, _decimals, _comptroller, _interestRateModel, _initialExchangeRateMantissa, _liquidateAdmin, _reserveFactorMantissa);
        underlying = _underlying;
        admin = _admin;
    }

    function mint(uint _mintAmount) external returns (uint) {

        (uint err,) = mintInternal(_mintAmount);
        return err;
    }

    function redeem(uint _redeemTokens) external returns (uint) {

        return redeemInternal(_redeemTokens);
    }

    function redeemUnderlying(uint _redeemAmount) external returns (uint) {

        return redeemUnderlyingInternal(_redeemAmount);
    }

    function borrow(uint _borrowerAmount) external returns (uint) {

        return borrowInternal(_borrowerAmount);
    }

    function repayBorrow(uint _repayAmount) external returns (uint) {

        (uint err,) = repayBorrowInternal(_repayAmount);
        return err;
    }

    function repayBorrowBehalf(address _borrower, uint _repayAmount) external returns (uint) {

        (uint err,) = repayBorrowBehalfInternal(_borrower, _repayAmount);
        return err;
    }

    function _addReserves(uint _addAmount) external returns (uint) {

        return _addResevesInternal(_addAmount);
    }


    function getCashPrior() internal view returns (uint) {

        EIP20Interface token = EIP20Interface(underlying);
        return token.balanceOf(address(this));
    }

    function doTransferIn(address _from, uint _amount) internal returns (uint) {

        EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
        uint balanceBefore = EIP20Interface(underlying).balanceOf(address(this));
        token.transferFrom(_from, address(this), _amount);
        bool success;
        assembly {
            switch returndatasize()
                case 0 {
                    success := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    success := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        require(success, "doTransferIn failure");

        uint balanceAfter = EIP20Interface(underlying).balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "doTransferIn::balanceAfter >= balanceBefore failure");
        return balanceAfter - balanceBefore;
    }

    function doTransferOut(address payable _to, uint _amount) internal {

        EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
        token.transfer(_to, _amount);
        bool success;
        assembly {
            switch returndatasize()
                case 0 {
                    success := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    success := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        require(success, "dotransferOut failure");
    }
}pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;


contract AegisComptroller is AegisComptrollerCommon, AegisComptrollerInterface, Exponential, BaseReporter {

    uint internal constant closeFactorMinMantissa = 0.05e18;
    uint internal constant closeFactorMaxMantissa = 0.9e18;
    uint internal constant collateralFactorMaxMantissa = 0.9e18;
    uint internal constant liquidationIncentiveMinMantissa = 1.0e18;
    uint internal constant liquidationIncentiveMaxMantissa = 1.5e18;

    constructor () public {
        admin = msg.sender;
        liquidateAdmin = msg.sender;
    }

    function getAssetsIn(address _account) external view returns (AToken[] memory) {

        return accountAssets[_account];
    }

    function checkMembership(address _account, AToken _aToken) external view returns (bool) {

        return markets[address(_aToken)].accountMembership[_account];
    }

    function enterMarkets(address[] memory _aTokens) public returns (uint[] memory) {

        uint len = _aTokens.length;
        uint[] memory results = new uint[](len);
        for (uint i = 0; i < len; i++) {
            AToken aToken = AToken(_aTokens[i]);
            results[i] = uint(addToMarketInternal(aToken, msg.sender));
        }
        return results;
    }

    function addToMarketInternal(AToken _aToken, address _sender) internal returns (Error) {

        Market storage marketToJoin = markets[address(_aToken)];
        require(marketToJoin.isListed, "addToMarketInternal marketToJoin.isListed false");
        if (marketToJoin.accountMembership[_sender] == true) {
            return Error.SUCCESS;
        }

        require(accountAssets[_sender].length < maxAssets, "addToMarketInternal: accountAssets[_sender].length >= maxAssets");
        marketToJoin.accountMembership[_sender] = true;
        accountAssets[_sender].push(_aToken);

        emit MarketEntered(_aToken, _sender);
        return Error.SUCCESS;
    }

    function exitMarket(address _aTokenAddress) external returns (uint) {

        AToken aToken = AToken(_aTokenAddress);
        (uint err, uint tokensHeld, uint borrowBalance,) = aToken.getAccountSnapshot(msg.sender);
        require(err == uint(Error.SUCCESS), "AegisComptroller::exitMarket aToken.getAccountSnapshot failure");
        require(borrowBalance == 0, "AegisComptroller::exitMarket borrowBalance Non-zero");

        uint allowed = redeemAllowedInternal(_aTokenAddress, msg.sender, tokensHeld);
        require(allowed == 0, "AegisComptroller::exitMarket redeemAllowedInternal failure");

        Market storage marketToExit = markets[address(aToken)];
        if (!marketToExit.accountMembership[msg.sender]) {
            return uint(Error.SUCCESS);
        }
        delete marketToExit.accountMembership[msg.sender];

        AToken[] memory userAssetList = accountAssets[msg.sender];
        uint len = userAssetList.length;
        uint assetIndex = len;
        for (uint i = 0; i < len; i++) {
            if (userAssetList[i] == aToken) {
                assetIndex = i;
                break;
            }
        }
        assert(assetIndex < len);
        AToken[] storage storedList = accountAssets[msg.sender];
        storedList[assetIndex] = storedList[storedList.length - 1];
        storedList.length--;

        emit MarketExited(aToken, msg.sender);
        return uint(Error.SUCCESS);
    }


    function mintAllowed() external returns (uint) {

        require(!_mintGuardianPaused, "AegisComptroller::mintAllowed _mintGuardianPaused failure");
        return uint(Error.SUCCESS);
    }
    function repayBorrowAllowed() external returns (uint) {

        require(!_borrowGuardianPaused, "AegisComptroller::repayBorrowAllowed _borrowGuardianPaused failure");
        return uint(Error.SUCCESS);
    }
    function seizeAllowed(address _aTokenCollateral, address _aTokenBorrowed) external returns (uint) {

        require(!seizeGuardianPaused, "AegisComptroller::seizeAllowedseize seizeGuardianPaused failure");
        if (!markets[_aTokenCollateral].isListed || !markets[_aTokenBorrowed].isListed) {
            return uint(Error.ERROR);
        }
        if (AToken(_aTokenCollateral).comptroller() != AToken(_aTokenBorrowed).comptroller()) {
            return uint(Error.ERROR);
        }
        return uint(Error.SUCCESS);
    }
    
    function redeemAllowed(address _aToken, address _redeemer, uint _redeemTokens) external returns (uint) {

        return redeemAllowedInternal(_aToken, _redeemer, _redeemTokens);
    }

    function redeemAllowedInternal(address _aToken, address _redeemer, uint _redeemTokens) internal view returns (uint) {

        require(markets[_aToken].isListed, "AToken must be in the market");
        if (!markets[_aToken].accountMembership[_redeemer]) {
            return uint(Error.SUCCESS);
        }
        (Error err,, uint shortfall) = getHypotheticalAccountLiquidityInternal(_redeemer, AToken(_aToken), _redeemTokens, 0);
        require(err == Error.SUCCESS && shortfall <= 0, "getHypotheticalAccountLiquidityInternal failure");
        return uint(Error.SUCCESS);
    }

    function redeemVerify(uint _redeemAmount, uint _redeemTokens) external {

        if (_redeemTokens == 0 && _redeemAmount > 0) {
            revert("_redeemTokens zero");
        }
    }

    function borrowAllowed(address _aToken, address _borrower, uint _borrowAmount) external returns (uint) {

        require(!borrowGuardianPaused[_aToken], "AegisComptroller::borrowAllowed borrowGuardianPaused failure");
        if (!markets[_aToken].isListed) {
            return uint(Error.ERROR);
        }
        if (!markets[_aToken].accountMembership[_borrower]) {
            require(msg.sender == _aToken, "AegisComptroller::accountMembership failure");
            Error err = addToMarketInternal(AToken(msg.sender), _borrower);
            if (err != Error.SUCCESS) {
                return uint(err);
            }
            assert(markets[_aToken].accountMembership[_borrower]);
        }
        if (oracle.getUnderlyingPrice(_aToken) == 0) {
            return uint(Error.ERROR);
        }
        (Error err,, uint shortfall) = getHypotheticalAccountLiquidityInternal(_borrower, AToken(_aToken), 0, _borrowAmount);
        if (err != Error.SUCCESS) {
            return uint(err);
        }
        if (shortfall > 0) {
            return uint(Error.ERROR);
        }
        return uint(Error.SUCCESS);
    }

    function transferAllowed(address _aToken, address _src, uint _transferTokens) external returns (uint) {

        require(!transferGuardianPaused, "AegisComptroller::transferAllowed failure");
        uint allowed = redeemAllowedInternal(_aToken, _src, _transferTokens); 
        if (allowed != uint(Error.SUCCESS)) {
            return allowed;
        }
        return uint(Error.SUCCESS);
    }

    function getAccountLiquidity(address _account) public view returns (uint, uint, uint) {

        (Error err, uint liquidity, uint shortfall) = getHypotheticalAccountLiquidityInternal(_account, AToken(0), 0, 0);
        return (uint(err), liquidity, shortfall);
    }

    event AutoLiquidity(address _account, uint _actualAmount);

    function autoLiquidity(address _account, uint _liquidityAmount, uint _liquidateIncome) public returns (uint) {

        require(msg.sender == liquidateAdmin, "SET_PRICE_ORACLE_OWNER_CHECK");
        (uint err, uint _actualAmount) = autoLiquidityInternal(msg.sender, _account, _liquidityAmount, _liquidateIncome);
        require(err == uint(Error.SUCCESS), "autoLiquidity::autoLiquidityInternal failure");
        emit AutoLiquidity(_account, _actualAmount);
        return uint(Error.SUCCESS);
    }

    struct LiquidationDetail {
        uint aTokenBalance;
        uint aTokenBorrow;
        uint exchangeRateMantissa;
        uint oraclePriceMantissa;
        uint assetAmount;
        uint borrowAmount;
        uint mitem;
        uint repayY;
        uint _liquidate;
        uint _repayLiquidate;
        uint _x;
    }

    function autoLiquidityInternal(address _owner, address _account, uint _liquidityAmount, uint _liquidateIncome) internal returns (uint, uint) {

        uint err;
        LiquidationDetail memory vars;
        AToken[] memory assets = accountAssets[_account];
        vars.mitem = _liquidateIncome;
        vars.repayY = _liquidityAmount;
        for (uint i = 0; i < assets.length; i++) {
            AToken asset = assets[i];
            (err, vars.aTokenBalance, vars.aTokenBorrow, vars.exchangeRateMantissa) = asset.getAccountSnapshot(_account);
            require(err == uint(Error.SUCCESS), "autoLiquidityInternal::asset.getAccountSnapshot failure");
            vars.oraclePriceMantissa = oracle.getUnderlyingPrice(address(asset));
            require(vars.oraclePriceMantissa > 0, "price must be greater than 0");
            if(vars.aTokenBalance > 0 && vars.mitem != 0) {
                vars.assetAmount = vars.aTokenBalance * vars.exchangeRateMantissa * vars.oraclePriceMantissa / 1e36;
                if(keccak256(abi.encodePacked((asset.symbol()))) != keccak256(abi.encodePacked(("ETH-A")))) {
                    EIP20Interface token = EIP20Interface(AErc20(address(asset)).underlying());
                    uint underlyingDecimals = token.decimals();
                    vars.assetAmount = vars.assetAmount * (10 ** (18 - underlyingDecimals));
                    vars._x = vars.mitem * 1e18 / vars.exchangeRateMantissa * (10**underlyingDecimals) / vars.oraclePriceMantissa;
                }else{
                    vars._x = vars.mitem * 1e18 / vars.exchangeRateMantissa * 1e18 / vars.oraclePriceMantissa;
                }
                if(vars.assetAmount >= vars.mitem) {
                    asset.ownerTransferToken(_owner, _account, vars._x);
                    vars.mitem = 0;
                }else {
                    asset.ownerTransferToken(_owner, _account, vars.aTokenBalance);
                    vars.mitem = vars.mitem - vars.assetAmount;
                }
            }
            if(keccak256(abi.encodePacked((asset.symbol()))) == keccak256(abi.encodePacked(("ETH-A")))) break;
            if(vars.aTokenBorrow > 0 && vars.repayY != 0) {
                vars.borrowAmount = vars.aTokenBorrow * vars.oraclePriceMantissa / 1e18;
                EIP20Interface token = EIP20Interface(AErc20(address(asset)).underlying());
                uint underlyingDecimals = token.decimals();
                vars.borrowAmount = vars.borrowAmount * (10 ** (18 - underlyingDecimals));
                vars._repayLiquidate = vars.repayY * 1e18 / vars.oraclePriceMantissa;
                if(vars.borrowAmount >= vars.repayY) {
                    asset.ownerCompensation(_owner, _account, vars._repayLiquidate / (10 ** (18-underlyingDecimals)));
                    vars.repayY = 0;
                }else {
                    asset.ownerCompensation(_owner, _account, vars.aTokenBorrow);
                    vars.repayY = vars.repayY - vars.borrowAmount;
                }
            }
        }
        return (uint(Error.SUCCESS), vars.repayY);
    }

    function liquidityItem (address _account) public view returns (uint, AccountDetail memory) {
        AToken[] memory assets = accountAssets[_account];
        AccountDetail memory detail;
        AccountLiquidityLocalVars memory vars;
        uint err;
        MathError mErr;
        for (uint i = 0; i < assets.length; i++) {
            AToken asset = assets[i];
            (err, vars.aTokenBalance, vars.borrowBalance, vars.exchangeRateMantissa) = asset.getAccountSnapshot(_account);
            if (err != uint(Error.SUCCESS)) {
                return (uint(Error.ERROR), detail);
            }
            vars.collateralFactor = Exp({mantissa: markets[address(asset)].collateralFactorMantissa});
            vars.exchangeRate = Exp({mantissa: vars.exchangeRateMantissa});
            vars.oraclePriceMantissa = oracle.getUnderlyingPrice(address(asset));
            if (vars.oraclePriceMantissa == 0) {
                return (uint(Error.ERROR), detail);
            }
            vars.oraclePrice = Exp({mantissa: vars.oraclePriceMantissa});
            (mErr, vars.tokensToDenom) = mulExp3(vars.collateralFactor, vars.exchangeRate, vars.oraclePrice);
            if (mErr != MathError.NO_ERROR) {
                return (uint(Error.ERROR), detail);
            }
            (mErr, vars.sumCollateral) = mulScalarTruncateAddUInt(vars.tokensToDenom, vars.aTokenBalance, 0);
            if (mErr != MathError.NO_ERROR) {
                return (uint(Error.ERROR), detail);
            }
            (mErr, vars.sumBorrowPlusEffects) = mulScalarTruncateAddUInt(vars.oraclePrice, vars.borrowBalance, 0);
            if (mErr != MathError.NO_ERROR) {
                return (uint(Error.ERROR), detail);
            }
            if(keccak256(abi.encodePacked((asset.symbol()))) != keccak256(abi.encodePacked(("ETH-A")))) {
                EIP20Interface token = EIP20Interface(AErc20(address(asset)).underlying());
                uint underlyingDecimals = token.decimals();
                detail.totalCollateral = detail.totalCollateral + (vars.sumCollateral * (10 ** (18 - underlyingDecimals)));
                detail.borrowPlusEffects = detail.borrowPlusEffects + (vars.sumBorrowPlusEffects * (10 ** (18 - underlyingDecimals)));
            }else {
                detail.totalCollateral = detail.totalCollateral + vars.sumCollateral;
                detail.borrowPlusEffects = detail.borrowPlusEffects + vars.sumBorrowPlusEffects;
            }
        }
        return (uint(Error.SUCCESS), detail);
    }

    function getAccountLiquidityInternal(address _account) internal view returns (Error, uint, uint) {

        return getHypotheticalAccountLiquidityInternal(_account, AToken(0), 0, 0);
    }

    function getHypotheticalAccountLiquidity(address _account, address _aTokenModify, uint _redeemTokens, uint _borrowAmount) public view returns (uint, uint, uint) {

        (Error err, uint liquidity, uint shortfall) = getHypotheticalAccountLiquidityInternal(_account, AToken(_aTokenModify), _redeemTokens, _borrowAmount);
        return (uint(err), liquidity, shortfall);
    }

    struct AccountDetail {
        uint totalCollateral;
        uint borrowPlusEffects;
    }

    function getHypotheticalAccountLiquidityInternal(address _account, AToken _aTokenModify, uint _redeemTokens, uint _borrowAmount) internal view returns (Error, uint, uint) {

        AccountLiquidityLocalVars memory vars;
        uint err;
        MathError mErr;
        AToken[] memory assets = accountAssets[_account];
        AccountDetail memory detail;
        for (uint i = 0; i < assets.length; i++) {
            AToken asset = assets[i];
            (err, vars.aTokenBalance, vars.borrowBalance, vars.exchangeRateMantissa) = asset.getAccountSnapshot(_account);
            if (err != uint(Error.SUCCESS)) {
                return (Error.ERROR, 0, 0);
            }
            vars.collateralFactor = Exp({mantissa: markets[address(asset)].collateralFactorMantissa});
            vars.exchangeRate = Exp({mantissa: vars.exchangeRateMantissa});
            vars.oraclePriceMantissa = oracle.getUnderlyingPrice(address(asset));
            if (vars.oraclePriceMantissa == 0) {
                return (Error.ERROR, 0, 0);
            }
            vars.oraclePrice = Exp({mantissa: vars.oraclePriceMantissa});
            (mErr, vars.tokensToDenom) = mulExp3(vars.collateralFactor, vars.exchangeRate, vars.oraclePrice);
            if (mErr != MathError.NO_ERROR) {
                return (Error.ERROR, 0, 0);
            }
            (mErr, vars.sumCollateral) = mulScalarTruncateAddUInt(vars.tokensToDenom, vars.aTokenBalance, 0);
            if (mErr != MathError.NO_ERROR) {
                return (Error.ERROR, 0, 0);
            }
            (mErr, vars.sumBorrowPlusEffects) = mulScalarTruncateAddUInt(vars.oraclePrice, vars.borrowBalance, 0);
            if (mErr != MathError.NO_ERROR) {
                return (Error.ERROR, 0, 0);
            }
            if (asset == _aTokenModify) {
                if(_borrowAmount == 0){
                    (mErr, vars.sumBorrowPlusEffects) = mulScalarTruncateAddUInt(vars.tokensToDenom, _redeemTokens, vars.sumBorrowPlusEffects);
                    if (mErr != MathError.NO_ERROR) {
                        return (Error.ERROR, 0, 0);
                    }
                }
                if(_redeemTokens == 0){
                    (mErr, vars.sumBorrowPlusEffects) = mulScalarTruncateAddUInt(vars.oraclePrice, _borrowAmount, vars.sumBorrowPlusEffects);
                    if (mErr != MathError.NO_ERROR) {
                        return (Error.ERROR, 0, 0);
                    }
                }
            }
            if(keccak256(abi.encodePacked((asset.symbol()))) != keccak256(abi.encodePacked(("ETH-A")))) {
                EIP20Interface token = EIP20Interface(AErc20(address(asset)).underlying());
                uint underlyingDecimals = token.decimals();
                detail.totalCollateral = detail.totalCollateral + (vars.sumCollateral * (10 ** (18 - underlyingDecimals)));
                detail.borrowPlusEffects = detail.borrowPlusEffects + (vars.sumBorrowPlusEffects * (10 ** (18 - underlyingDecimals)));
            }else {
                detail.totalCollateral = detail.totalCollateral + vars.sumCollateral;
                detail.borrowPlusEffects = detail.borrowPlusEffects + vars.sumBorrowPlusEffects;
            }
        }
        if(_redeemTokens == 0 && detail.borrowPlusEffects < minimumLoanAmount) {
            return (Error.ERROR, 0, 0);
        }
        if (detail.totalCollateral > detail.borrowPlusEffects) {
            return (Error.SUCCESS, detail.totalCollateral - detail.borrowPlusEffects, 0);
        } else {
            return (Error.SUCCESS, 0, detail.borrowPlusEffects - detail.totalCollateral);
        }
    }

    function liquidateCalculateSeizeTokens(address _aTokenBorrowed, address _aTokenCollateral, uint _actualRepayAmount) external view returns (uint, uint) {

        uint priceBorrowedMantissa = oracle.getUnderlyingPrice(_aTokenBorrowed);
        uint priceCollateralMantissa = oracle.getUnderlyingPrice(_aTokenCollateral);
        if (priceBorrowedMantissa == 0 || priceCollateralMantissa == 0) {
            return (uint(Error.ERROR), 0);
        }
        uint exchangeRateMantissa = AToken(_aTokenCollateral).exchangeRateStored();
        uint seizeTokens;
        Exp memory numerator;
        Exp memory denominator;
        Exp memory ratio;
        MathError mathErr;

        (mathErr, numerator) = mulExp(liquidationIncentiveMantissa, priceBorrowedMantissa);
        if (mathErr != MathError.NO_ERROR) {
            return (uint(Error.ERROR), 0);
        }
        (mathErr, denominator) = mulExp(priceCollateralMantissa, exchangeRateMantissa);
        if (mathErr != MathError.NO_ERROR) {
            return (uint(Error.ERROR), 0);
        }
        (mathErr, ratio) = divExp(numerator, denominator);
        if (mathErr != MathError.NO_ERROR) {
            return (uint(Error.ERROR), 0);
        }
        (mathErr, seizeTokens) = mulScalarTruncate(ratio, _actualRepayAmount);
        if (mathErr != MathError.NO_ERROR) {
            return (uint(Error.ERROR), 0);
        }
        return (uint(Error.SUCCESS), seizeTokens);
    }

    event AutoClearance(address _account, uint _liquidateAmount, uint _actualAmount);
    function autoClearance(address _account, uint _liquidateAmount, uint _liquidateIncome) public returns (uint, uint, uint) {

        require(_liquidateAmount > 0, "autoClearance _liquidateAmount must be greater than 0");
        (uint err, uint _actualAmount) = autoClearanceInternal(msg.sender, _account, _liquidateAmount, _liquidateIncome);
        require(err == uint(Error.SUCCESS), "AegisComptroller::autoClearance autoClearanceInternal failure");
        emit AutoClearance(_account, _liquidateAmount, _actualAmount);
        return (err, _liquidateAmount, _actualAmount);
    }

    function autoClearanceInternal(address _owner, address _account, uint _liquidateAmount, uint _liquidateIncome) internal returns(uint, uint) {

        uint err;
        LiquidationDetail memory vars;
        AToken[] memory assets = accountAssets[_account];
        vars._liquidate = _liquidateIncome;
        vars._repayLiquidate = _liquidateAmount;
        for (uint i = 0; i < assets.length; i++) {
            AToken asset = assets[i];
            (err, vars.aTokenBalance, vars.aTokenBorrow, vars.exchangeRateMantissa) = asset.getAccountSnapshot(_account);
            if (err != uint(Error.SUCCESS)) {
                return (uint(Error.ERROR), 0);
            }
            vars.oraclePriceMantissa = oracle.getUnderlyingPrice(address(asset));
            if (vars.oraclePriceMantissa == 0) {
                return (uint(Error.ERROR), 0);
            }
            if(vars.aTokenBalance > 0 && vars._liquidate != 0) {
                vars.assetAmount = vars.aTokenBalance * vars.exchangeRateMantissa * vars.oraclePriceMantissa / 1e36;
                if(keccak256(abi.encodePacked((asset.symbol()))) != keccak256(abi.encodePacked(("ETH-A")))) {
                    EIP20Interface token = EIP20Interface(AErc20(address(asset)).underlying());
                    uint underlyingDecimals = token.decimals();
                    vars.assetAmount = vars.assetAmount * (10 ** (18 - underlyingDecimals));
                    vars._x = vars._liquidate * 1e18 / vars.exchangeRateMantissa * (10**underlyingDecimals) / vars.oraclePriceMantissa;
                }else{
                    vars._x = vars._liquidate * 1e18 / vars.exchangeRateMantissa * 1e18 / vars.oraclePriceMantissa;
                }
                if(vars.assetAmount >= vars._liquidate) {
                    asset.ownerTransferToken(_owner, _account, vars._x);
                    vars._liquidate = 0;
                }else {
                    asset.ownerTransferToken(_owner, _account, vars.aTokenBalance);
                    vars._liquidate = vars._liquidate - vars.assetAmount;
                }
            }
            if(keccak256(abi.encodePacked((asset.symbol()))) == keccak256(abi.encodePacked(("ETH-A")))) break;
            if(vars.aTokenBorrow > 0 && vars._repayLiquidate != 0) {
                vars.borrowAmount = vars.aTokenBorrow * vars.oraclePriceMantissa / 1e18;
                EIP20Interface token = EIP20Interface(AErc20(address(asset)).underlying());
                uint underlyingDecimals = token.decimals();
                vars.borrowAmount = vars.borrowAmount * (10 ** (18 - underlyingDecimals));

                if(vars.borrowAmount >= vars._repayLiquidate) {
                    asset.ownerCompensation(_owner, _account, vars._repayLiquidate * 1e18 / vars.oraclePriceMantissa / (10 ** (18 - underlyingDecimals)));
                    vars._repayLiquidate = 0;
                }else {
                    asset.ownerCompensation(_owner, _account, vars.aTokenBorrow);
                    vars._repayLiquidate = vars._repayLiquidate - vars.borrowAmount;
                }
            }
        }
        return (uint(Error.SUCCESS), vars._repayLiquidate);
    }

    function _setPriceOracle(PriceOracle _newOracle) public returns (uint) {

        require(msg.sender == admin, "SET_PRICE_ORACLE_OWNER_CHECK");
        PriceOracle oldOracle = oracle;
        oracle = _newOracle;
        emit NewPriceOracle(oldOracle, _newOracle);
        return uint(Error.SUCCESS);
    }

    function _setCloseFactor(uint _newCloseFactorMantissa) external returns (uint) {

        require(msg.sender == admin, "SET_CLOSE_FACTOR_OWNER_CHECK");
        
        Exp memory newCloseFactorExp = Exp({mantissa: _newCloseFactorMantissa});
        Exp memory lowLimit = Exp({mantissa: closeFactorMinMantissa});
        if (lessThanOrEqualExp(newCloseFactorExp, lowLimit)) {
            return fail(Error.ERROR, ErrorRemarks.SET_CLOSE_FACTOR_VALIDATION, uint(Error.ERROR));
        }

        Exp memory highLimit = Exp({mantissa: closeFactorMaxMantissa});
        if (lessThanExp(highLimit, newCloseFactorExp)) {
            return fail(Error.ERROR, ErrorRemarks.SET_CLOSE_FACTOR_VALIDATION, uint(Error.ERROR));
        }
        uint oldCloseFactorMantissa = closeFactorMantissa;
        closeFactorMantissa = _newCloseFactorMantissa;

        emit NewCloseFactor(oldCloseFactorMantissa, closeFactorMantissa);
        return uint(Error.SUCCESS);
    }

    function _setCollateralFactor(AToken _aToken, uint _newCollateralFactorMantissa) external returns (uint) {

        require(msg.sender == admin, "SET_COLLATERAL_FACTOR_OWNER_CHECK");
        Market storage market = markets[address(_aToken)];
        if (!market.isListed) {
            return fail(Error.ERROR, ErrorRemarks.SET_COLLATERAL_FACTOR_NO_EXISTS, uint(Error.ERROR));
        }
        Exp memory newCollateralFactorExp = Exp({mantissa: _newCollateralFactorMantissa});
        Exp memory highLimit = Exp({mantissa: collateralFactorMaxMantissa});
        if (lessThanExp(highLimit, newCollateralFactorExp)) {
            return fail(Error.ERROR, ErrorRemarks.SET_COLLATERAL_FACTOR_VALIDATION, uint(Error.ERROR));
        }
        if (_newCollateralFactorMantissa != 0 && oracle.getUnderlyingPrice(address(_aToken)) == 0) {
            return fail(Error.ERROR, ErrorRemarks.SET_COLLATERAL_FACTOR_WITHOUT_PRICE, uint(Error.ERROR));
        }
        uint oldCollateralFactorMantissa = market.collateralFactorMantissa;
        market.collateralFactorMantissa = _newCollateralFactorMantissa;

        emit NewCollateralFactor(_aToken, oldCollateralFactorMantissa, _newCollateralFactorMantissa);
        return uint(Error.SUCCESS);
    }

    function _setMaxAssets(uint _newMaxAssets) external returns (uint) {

        require(msg.sender == admin, "SET_MAX_ASSETS_OWNER_CHECK");
        
        uint oldMaxAssets = maxAssets;
        maxAssets = _newMaxAssets; // push storage

        emit NewMaxAssets(oldMaxAssets, _newMaxAssets);
        return uint(Error.SUCCESS);
    }

    function _setLiquidationIncentive(uint _newLiquidationIncentiveMantissa) external returns (uint) {

        require(msg.sender == admin, "SET_LIQUIDATION_INCENTIVE_OWNER_CHECK");

        Exp memory newLiquidationIncentive = Exp({mantissa: _newLiquidationIncentiveMantissa});
        Exp memory minLiquidationIncentive = Exp({mantissa: liquidationIncentiveMinMantissa});
        if (lessThanExp(newLiquidationIncentive, minLiquidationIncentive)) {
            return fail(Error.ERROR, ErrorRemarks.SET_LIQUIDATION_INCENTIVE_VALIDATION, uint(Error.ERROR));
        }

        Exp memory maxLiquidationIncentive = Exp({mantissa: liquidationIncentiveMaxMantissa});
        if (lessThanExp(maxLiquidationIncentive, newLiquidationIncentive)) {
            return fail(Error.ERROR, ErrorRemarks.SET_LIQUIDATION_INCENTIVE_VALIDATION, uint(Error.ERROR));
        }
        uint oldLiquidationIncentiveMantissa = liquidationIncentiveMantissa;
        liquidationIncentiveMantissa = _newLiquidationIncentiveMantissa; // push storage

        emit NewLiquidationIncentive(oldLiquidationIncentiveMantissa, _newLiquidationIncentiveMantissa);
        return uint(Error.SUCCESS);
    }

    function _supportMarket(AToken _aToken) external returns (uint) {

        require(msg.sender == admin, "change not authorized");
        if (markets[address(_aToken)].isListed) {
            return fail(Error.ERROR, ErrorRemarks.SUPPORT_MARKET_EXISTS, uint(Error.ERROR));
        }
        _aToken.aToken();
        markets[address(_aToken)] = Market({isListed: true, collateralFactorMantissa: 0});
        _addMarketInternal(address(_aToken));
        emit MarketListed(_aToken);
        return uint(Error.SUCCESS);
    }
    function _addMarketInternal(address _aToken) internal {

        for (uint i = 0; i < allMarkets.length; i ++) {
            require(allMarkets[i] != AToken(_aToken), "AegisComptroller::_addMarketInternal failure");
        }
        allMarkets.push(AToken(_aToken));
    }

    function _setPauseGuardian(address _newPauseGuardian) public returns (uint) {

        require(msg.sender == admin, "change not authorized");
        address oldPauseGuardian = pauseGuardian;
        pauseGuardian = _newPauseGuardian;
        emit NewPauseGuardian(oldPauseGuardian, pauseGuardian);
        return uint(Error.SUCCESS);
    }

    function _setMintPaused(AToken _aToken, bool _state) public returns (bool) {

        require(markets[address(_aToken)].isListed, "cannot pause a market that is not listed");
        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause");
        require(msg.sender == admin || _state == true, "only admin can unpause");

        mintGuardianPaused[address(_aToken)] = _state;
        emit ActionPaused(_aToken, "Mint", _state);
        return _state;
    }

    function _setBorrowPaused(AToken _aToken, bool _state) public returns (bool) {

        require(markets[address(_aToken)].isListed, "cannot pause a market that is not listed");
        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause");
        require(msg.sender == admin || _state == true, "only admin can unpause");

        borrowGuardianPaused[address(_aToken)] = _state;
        emit ActionPaused(_aToken, "Borrow", _state);
        return _state;
    }

    function _setTransferPaused(bool _state) public returns (bool) {

        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause");
        require(msg.sender == admin || _state == true, "only admin can unpause");

        transferGuardianPaused = _state;
        emit ActionPaused("Transfer", _state);
        return _state;
    }

    function _setSeizePaused(bool _state) public returns (bool) {

        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause");
        require(msg.sender == admin || _state == true, "only admin can unpause");

        seizeGuardianPaused = _state;
        emit ActionPaused("Seize", _state);
        return _state;
    }

    function _become(Unitroller _unitroller) public {

        require(msg.sender == _unitroller.admin(), "only unitroller admin can change brains");
        require(_unitroller._acceptImplementation() == 0, "change not authorized");
    }

    function adminOrInitializing() internal view returns (bool) {

        return msg.sender == admin || msg.sender == comptrollerImplementation;
    }

    event NewMintGuardianPaused(bool _oldState, bool _newState);
    function _setMintGuardianPaused(bool _state) public returns (bool) {

        require(msg.sender == admin, "change not authorized");
        bool _oldState = _mintGuardianPaused;
        _mintGuardianPaused = _state;
        emit NewMintGuardianPaused(_oldState, _state);
        return _state;
    }

    event NewBorrowGuardianPaused(bool _oldState, bool _newState);
    function _setBorrowGuardianPaused(bool _state) public returns (bool) {

        require(msg.sender == admin, "change not authorized");
        bool _oldState = _borrowGuardianPaused;
        _borrowGuardianPaused = _state;
        emit NewBorrowGuardianPaused(_oldState, _state);
        return _state;
    }

    event NewClearanceMantissa(uint _oldClearanceMantissa, uint _newClearanceMantissa);
    function _setClearanceMantissa(uint _newClearanceMantissa) public returns (uint) {

        require(msg.sender == admin, "AegisComptroller::_setClearanceMantissa change not authorized");
        uint _old = clearanceMantissa;
        clearanceMantissa = _newClearanceMantissa;
        emit NewClearanceMantissa(_old, _newClearanceMantissa);
        return uint(Error.SUCCESS);
    }

    event NewMinimumLoanAmount(uint _oldMinimumLoanAmount, uint _newMinimumLoanAmount);
    function _setminimumLoanAmount(uint _newMinimumLoanAmount) public returns (uint) {

        require(msg.sender == admin, "AegisComptroller::_setClearanceMantissa change not authorized");
        uint _old = minimumLoanAmount;
        minimumLoanAmount = _newMinimumLoanAmount;
        emit NewMinimumLoanAmount(_old, _newMinimumLoanAmount);
        return uint(Error.SUCCESS);
    }

    struct AccountLiquidityLocalVars {
        uint sumCollateral;
        uint sumBorrowPlusEffects;
        uint aTokenBalance;
        uint borrowBalance;
        uint exchangeRateMantissa;
        uint oraclePriceMantissa;
        Exp collateralFactor;
        Exp exchangeRate;
        Exp oraclePrice;
        Exp tokensToDenom;
    }

    event MarketListed(AToken _aToken);
    event MarketEntered(AToken _aToken, address _account);
    event MarketExited(AToken _aToken, address _account);
    event NewCloseFactor(uint _oldCloseFactorMantissa, uint _newCloseFactorMantissa);
    event NewCollateralFactor(AToken _aToken, uint _oldCollateralFactorMantissa, uint _newCollateralFactorMantissa);
    event NewLiquidationIncentive(uint _oldLiquidationIncentiveMantissa, uint _newLiquidationIncentiveMantissa);
    event NewMaxAssets(uint _oldMaxAssets, uint _newMaxAssets);
    event NewPriceOracle(PriceOracle _oldPriceOracle, PriceOracle _newPriceOracle);
    event NewPauseGuardian(address _oldPauseGuardian, address _newPauseGuardian);
    event ActionPaused(string _action, bool _pauseState);
    event ActionPaused(AToken _aToken, string _action, bool _pauseState);
    event NewCompRate(uint _oldCompRate, uint _newCompRate);
    event CompSpeedUpdated(AToken indexed _aToken, uint _newSpeed);
    event DistributedSupplierComp(AToken indexed _aToken, address indexed _supplier, uint _compDelta, uint _compSupplyIndex);
    event DistributedBorrowerComp(AToken indexed _aToken, address indexed _borrower, uint _compDelta, uint _compBorrowIndex);
}