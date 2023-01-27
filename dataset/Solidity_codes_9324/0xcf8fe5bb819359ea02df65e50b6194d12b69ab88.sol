

pragma solidity 0.4.24;

contract ErrorReporter {

    event Failure(uint256 error, uint256 info, uint256 detail);

    enum Error {
        NO_ERROR,
        OPAQUE_ERROR, // To be used when reporting errors from upgradeable contracts; the opaque code should be given as `detail` in the `Failure` event
        UNAUTHORIZED,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW,
        DIVISION_BY_ZERO,
        BAD_INPUT,
        TOKEN_INSUFFICIENT_ALLOWANCE,
        TOKEN_INSUFFICIENT_BALANCE,
        TOKEN_TRANSFER_FAILED,
        MARKET_NOT_SUPPORTED,
        SUPPLY_RATE_CALCULATION_FAILED,
        BORROW_RATE_CALCULATION_FAILED,
        TOKEN_INSUFFICIENT_CASH,
        TOKEN_TRANSFER_OUT_FAILED,
        INSUFFICIENT_LIQUIDITY,
        INSUFFICIENT_BALANCE,
        INVALID_COLLATERAL_RATIO,
        MISSING_ASSET_PRICE,
        EQUITY_INSUFFICIENT_BALANCE,
        INVALID_CLOSE_AMOUNT_REQUESTED,
        ASSET_NOT_PRICED,
        INVALID_LIQUIDATION_DISCOUNT,
        INVALID_COMBINED_RISK_PARAMETERS,
        ZERO_ORACLE_ADDRESS,
        CONTRACT_PAUSED,
        KYC_ADMIN_CHECK_FAILED,
        KYC_ADMIN_ADD_OR_DELETE_ADMIN_CHECK_FAILED,
        KYC_CUSTOMER_VERIFICATION_CHECK_FAILED,
        LIQUIDATOR_CHECK_FAILED,
        LIQUIDATOR_ADD_OR_DELETE_ADMIN_CHECK_FAILED,
        SET_WETH_ADDRESS_ADMIN_CHECK_FAILED,
        WETH_ADDRESS_NOT_SET_ERROR,
        ETHER_AMOUNT_MISMATCH_ERROR
    }

    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        BORROW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED,
        BORROW_ACCOUNT_SHORTFALL_PRESENT,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_AMOUNT_LIQUIDITY_SHORTFALL,
        BORROW_AMOUNT_VALUE_CALCULATION_FAILED,
        BORROW_CONTRACT_PAUSED,
        BORROW_MARKET_NOT_SUPPORTED,
        BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
        BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED,
        BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED,
        BORROW_ORIGINATION_FEE_CALCULATION_FAILED,
        BORROW_TRANSFER_OUT_FAILED,
        EQUITY_WITHDRAWAL_AMOUNT_VALIDATION,
        EQUITY_WITHDRAWAL_CALCULATE_EQUITY,
        EQUITY_WITHDRAWAL_MODEL_OWNER_CHECK,
        EQUITY_WITHDRAWAL_TRANSFER_OUT_FAILED,
        LIQUIDATE_ACCUMULATED_BORROW_BALANCE_CALCULATION_FAILED,
        LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET,
        LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET,
        LIQUIDATE_AMOUNT_SEIZE_CALCULATION_FAILED,
        LIQUIDATE_BORROW_DENOMINATED_COLLATERAL_CALCULATION_FAILED,
        LIQUIDATE_CLOSE_AMOUNT_TOO_HIGH,
        LIQUIDATE_CONTRACT_PAUSED,
        LIQUIDATE_DISCOUNTED_REPAY_TO_EVEN_AMOUNT_CALCULATION_FAILED,
        LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET,
        LIQUIDATE_NEW_BORROW_RATE_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET,
        LIQUIDATE_NEW_SUPPLY_RATE_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_BORROW_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_CASH_CALCULATION_FAILED_BORROWED_ASSET,
        LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET,
        LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET,
        LIQUIDATE_FETCH_ASSET_PRICE_FAILED,
        LIQUIDATE_TRANSFER_IN_FAILED,
        LIQUIDATE_TRANSFER_IN_NOT_POSSIBLE,
        REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_CONTRACT_PAUSED,
        REPAY_BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        REPAY_BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        REPAY_BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED,
        REPAY_BORROW_TRANSFER_IN_FAILED,
        REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE,
        SET_ASSET_PRICE_CHECK_ORACLE,
        SET_MARKET_INTEREST_RATE_MODEL_OWNER_CHECK,
        SET_ORACLE_OWNER_CHECK,
        SET_ORIGINATION_FEE_OWNER_CHECK,
        SET_PAUSED_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_RISK_PARAMETERS_OWNER_CHECK,
        SET_RISK_PARAMETERS_VALIDATION,
        SUPPLY_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        SUPPLY_CONTRACT_PAUSED,
        SUPPLY_MARKET_NOT_SUPPORTED,
        SUPPLY_NEW_BORROW_INDEX_CALCULATION_FAILED,
        SUPPLY_NEW_BORROW_RATE_CALCULATION_FAILED,
        SUPPLY_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        SUPPLY_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_CASH_CALCULATION_FAILED,
        SUPPLY_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        SUPPLY_TRANSFER_IN_FAILED,
        SUPPLY_TRANSFER_IN_NOT_POSSIBLE,
        SUPPORT_MARKET_FETCH_PRICE_FAILED,
        SUPPORT_MARKET_OWNER_CHECK,
        SUPPORT_MARKET_PRICE_CHECK,
        SUSPEND_MARKET_OWNER_CHECK,
        WITHDRAW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED,
        WITHDRAW_ACCOUNT_SHORTFALL_PRESENT,
        WITHDRAW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        WITHDRAW_AMOUNT_LIQUIDITY_SHORTFALL,
        WITHDRAW_AMOUNT_VALUE_CALCULATION_FAILED,
        WITHDRAW_CAPACITY_CALCULATION_FAILED,
        WITHDRAW_CONTRACT_PAUSED,
        WITHDRAW_NEW_BORROW_INDEX_CALCULATION_FAILED,
        WITHDRAW_NEW_BORROW_RATE_CALCULATION_FAILED,
        WITHDRAW_NEW_SUPPLY_INDEX_CALCULATION_FAILED,
        WITHDRAW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
        WITHDRAW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        WITHDRAW_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        WITHDRAW_TRANSFER_OUT_FAILED,
        WITHDRAW_TRANSFER_OUT_NOT_POSSIBLE,
        KYC_ADMIN_CHECK_FAILED,
        KYC_ADMIN_ADD_OR_DELETE_ADMIN_CHECK_FAILED,
        KYC_CUSTOMER_VERIFICATION_CHECK_FAILED,
        LIQUIDATOR_CHECK_FAILED,
        LIQUIDATOR_ADD_OR_DELETE_ADMIN_CHECK_FAILED,
        SET_WETH_ADDRESS_ADMIN_CHECK_FAILED,
        WETH_ADDRESS_NOT_SET_ERROR,
        SEND_ETHER_ADMIN_CHECK_FAILED,
        ETHER_AMOUNT_MISMATCH_ERROR
    }

    function fail(Error err, FailureInfo info) internal returns (uint256) {

        emit Failure(uint256(err), uint256(info), 0);

        return uint256(err);
    }

    function failOpaque(FailureInfo info, uint256 opaqueError)
        internal
        returns (uint256)
    {

        emit Failure(uint256(Error.OPAQUE_ERROR), uint256(info), opaqueError);

        return uint256(Error.OPAQUE_ERROR);
    }
}


pragma solidity 0.4.24;


contract CarefulMath is ErrorReporter {

    function mul(uint256 a, uint256 b) internal pure returns (Error, uint256) {

        if (a == 0) {
            return (Error.NO_ERROR, 0);
        }

        uint256 c = a * b;

        if (c / a != b) {
            return (Error.INTEGER_OVERFLOW, 0);
        } else {
            return (Error.NO_ERROR, c);
        }
    }

    function div(uint256 a, uint256 b) internal pure returns (Error, uint256) {

        if (b == 0) {
            return (Error.DIVISION_BY_ZERO, 0);
        }

        return (Error.NO_ERROR, a / b);
    }

    function sub(uint256 a, uint256 b) internal pure returns (Error, uint256) {

        if (b <= a) {
            return (Error.NO_ERROR, a - b);
        } else {
            return (Error.INTEGER_UNDERFLOW, 0);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (Error, uint256) {

        uint256 c = a + b;

        if (c >= a) {
            return (Error.NO_ERROR, c);
        } else {
            return (Error.INTEGER_OVERFLOW, 0);
        }
    }

    function addThenSub(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (Error, uint256) {

        (Error err0, uint256 sum) = add(a, b);

        if (err0 != Error.NO_ERROR) {
            return (err0, 0);
        }

        return sub(sum, c);
    }
}


pragma solidity 0.4.24;



contract Exponential is ErrorReporter, CarefulMath {

    uint256 constant expScale = 10**18;

    uint256 constant halfExpScale = expScale / 2;

    struct Exp {
        uint256 mantissa;
    }

    uint256 constant mantissaOne = 10**18;
    uint256 constant mantissaOneTenth = 10**17;

    function getExp(uint256 num, uint256 denom)
        internal
        pure
        returns (Error, Exp memory)
    {

        (Error err0, uint256 scaledNumerator) = mul(num, expScale);
        if (err0 != Error.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (Error err1, uint256 rational) = div(scaledNumerator, denom);
        if (err1 != Error.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (Error.NO_ERROR, Exp({mantissa: rational}));
    }

    function addExp(Exp memory a, Exp memory b)
        internal
        pure
        returns (Error, Exp memory)
    {

        (Error error, uint256 result) = add(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    function subExp(Exp memory a, Exp memory b)
        internal
        pure
        returns (Error, Exp memory)
    {

        (Error error, uint256 result) = sub(a.mantissa, b.mantissa);

        return (error, Exp({mantissa: result}));
    }

    function mulScalar(Exp memory a, uint256 scalar)
        internal
        pure
        returns (Error, Exp memory)
    {

        (Error err0, uint256 scaledMantissa) = mul(a.mantissa, scalar);
        if (err0 != Error.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (Error.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    function divScalar(Exp memory a, uint256 scalar)
        internal
        pure
        returns (Error, Exp memory)
    {

        (Error err0, uint256 descaledMantissa) = div(a.mantissa, scalar);
        if (err0 != Error.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (Error.NO_ERROR, Exp({mantissa: descaledMantissa}));
    }

    function divScalarByExp(uint256 scalar, Exp divisor)
        internal
        pure
        returns (Error, Exp memory)
    {

        (Error err0, uint256 numerator) = mul(expScale, scalar);
        if (err0 != Error.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    function mulExp(Exp memory a, Exp memory b)
        internal
        pure
        returns (Error, Exp memory)
    {

        (Error err0, uint256 doubleScaledProduct) = mul(a.mantissa, b.mantissa);
        if (err0 != Error.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (Error err1, uint256 doubleScaledProductWithHalfScale) = add(
            halfExpScale,
            doubleScaledProduct
        );
        if (err1 != Error.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (Error err2, uint256 product) = div(
            doubleScaledProductWithHalfScale,
            expScale
        );
        assert(err2 == Error.NO_ERROR);

        return (Error.NO_ERROR, Exp({mantissa: product}));
    }

    function divExp(Exp memory a, Exp memory b)
        internal
        pure
        returns (Error, Exp memory)
    {

        return getExp(a.mantissa, b.mantissa);
    }

    function truncate(Exp memory exp) internal pure returns (uint256) {

        return exp.mantissa / expScale;
    }

    function lessThanExp(Exp memory left, Exp memory right)
        internal
        pure
        returns (bool)
    {

        return left.mantissa < right.mantissa;
    }

    function lessThanOrEqualExp(Exp memory left, Exp memory right)
        internal
        pure
        returns (bool)
    {

        return left.mantissa <= right.mantissa;
    }

    function greaterThanExp(Exp memory left, Exp memory right)
        internal
        pure
        returns (bool)
    {

        return left.mantissa > right.mantissa;
    }

    function isZeroExp(Exp memory value) internal pure returns (bool) {

        return value.mantissa == 0;
    }
}


pragma solidity 0.4.24;

contract InterestRateModel {

    function getSupplyRate(
        address asset,
        uint256 cash,
        uint256 borrows
    ) public view returns (uint256, uint256);


    function getBorrowRate(
        address asset,
        uint256 cash,
        uint256 borrows
    ) public view returns (uint256, uint256);

}


pragma solidity 0.4.24;

contract EIP20Interface {

    uint256 public totalSupply;
    uint8 public decimals; // maximum is 18 decimals

    function balanceOf(address _owner) public view returns (uint256 balance);


    function transfer(address _to, uint256 _value)
        public
        returns (bool success);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success);


    function approve(address _spender, uint256 _value)
        public
        returns (bool success);


    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}


pragma solidity 0.4.24;

contract EIP20NonStandardInterface {

    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);


    function transfer(address _to, uint256 _value) public;


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public;


    function approve(address _spender, uint256 _value)
        public
        returns (bool success);


    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}


pragma solidity 0.4.24;




contract SafeToken is ErrorReporter {

    function checkTransferIn(
        address asset,
        address from,
        uint256 amount
    ) internal view returns (Error) {

        EIP20Interface token = EIP20Interface(asset);

        if (token.allowance(from, address(this)) < amount) {
            return Error.TOKEN_INSUFFICIENT_ALLOWANCE;
        }

        if (token.balanceOf(from) < amount) {
            return Error.TOKEN_INSUFFICIENT_BALANCE;
        }

        return Error.NO_ERROR;
    }

    function doTransferIn(
        address asset,
        address from,
        uint256 amount
    ) internal returns (Error) {

        EIP20NonStandardInterface token = EIP20NonStandardInterface(asset);

        bool result;

        token.transferFrom(from, address(this), amount);

        assembly {
            switch returndatasize()
            case 0 {
                result := not(0) // set result to true
            }
            case 32 {
                returndatacopy(0, 0, 32)
                result := mload(0) // Set `result = returndata` of external call
            }
            default {
                revert(0, 0)
            }
        }

        if (!result) {
            return Error.TOKEN_TRANSFER_FAILED;
        }

        return Error.NO_ERROR;
    }

    function getCash(address asset) internal view returns (uint256) {

        EIP20Interface token = EIP20Interface(asset);

        return token.balanceOf(address(this));
    }

    function getBalanceOf(address asset, address from)
        internal
        view
        returns (uint256)
    {

        EIP20Interface token = EIP20Interface(asset);

        return token.balanceOf(from);
    }

    function doTransferOut(
        address asset,
        address to,
        uint256 amount
    ) internal returns (Error) {

        EIP20NonStandardInterface token = EIP20NonStandardInterface(asset);

        bool result;

        token.transfer(to, amount);

        assembly {
            switch returndatasize()
            case 0 {
                result := not(0) // set result to true
            }
            case 32 {
                returndatacopy(0, 0, 32)
                result := mload(0) // Set `result = returndata` of external call
            }
            default {
                revert(0, 0)
            }
        }

        if (!result) {
            return Error.TOKEN_TRANSFER_OUT_FAILED;
        }

        return Error.NO_ERROR;
    }

    function doApprove(
        address asset,
        address to,
        uint256 amount
    ) internal returns (Error) {

        EIP20NonStandardInterface token = EIP20NonStandardInterface(asset);
        bool result;
        token.approve(to, amount);
        assembly {
            switch returndatasize()
            case 0 {
                result := not(0) // set result to true
            }
            case 32 {
                returndatacopy(0, 0, 32)
                result := mload(0) // Set `result = returndata` of external call
            }
            default {
                revert(0, 0)
            }
        }
        if (!result) {
            return Error.TOKEN_TRANSFER_OUT_FAILED;
        }
        return Error.NO_ERROR;
    }
}


pragma solidity 0.4.24;

interface AggregatorV3Interface {

    function decimals() external view returns (uint8);


    function description() external view returns (string memory);


    function version() external view returns (uint256);


    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );


    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

}


pragma solidity 0.4.24;



contract ChainLink {

    mapping(address => AggregatorV3Interface) internal priceContractMapping;
    address public admin;
    bool public paused = false;
    address public wethAddressVerified;
    address public wethAddressPublic;
    AggregatorV3Interface public USDETHPriceFeed;
    uint256 constant expScale = 10**18;
    uint8 constant eighteen = 18;

    constructor() public {
        admin = msg.sender;
    }

    modifier onlyAdmin() {

        require(
            msg.sender == admin,
            "Only the Admin can perform this operation"
        );
        _;
    }

    event assetAdded(
        address indexed assetAddress,
        address indexed priceFeedContract
    );
    event assetRemoved(address indexed assetAddress);
    event adminChanged(address indexed oldAdmin, address indexed newAdmin);
    event verifiedWethAddressSet(address indexed wethAddressVerified);
    event publicWethAddressSet(address indexed wethAddressPublic);
    event contractPausedOrUnpaused(bool currentStatus);

    function addAsset(address assetAddress, address priceFeedContract)
        public
        onlyAdmin
    {

        require(
            assetAddress != address(0) && priceFeedContract != address(0),
            "Asset or Price Feed address cannot be 0x00"
        );
        priceContractMapping[assetAddress] = AggregatorV3Interface(
            priceFeedContract
        );
        emit assetAdded(assetAddress, priceFeedContract);
    }

    function removeAsset(address assetAddress) public onlyAdmin {

        require(
            assetAddress != address(0),
            "Asset or Price Feed address cannot be 0x00"
        );
        priceContractMapping[assetAddress] = AggregatorV3Interface(address(0));
        emit assetRemoved(assetAddress);
    }

    function changeAdmin(address newAdmin) public onlyAdmin {

        require(
            newAdmin != address(0),
            "Asset or Price Feed address cannot be 0x00"
        );
        emit adminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    function setWethAddressVerified(address _wethAddressVerified) public onlyAdmin {

        require(_wethAddressVerified != address(0), "WETH address cannot be 0x00");
        wethAddressVerified = _wethAddressVerified;
        emit verifiedWethAddressSet(_wethAddressVerified);
    }

    function setWethAddressPublic(address _wethAddressPublic) public onlyAdmin {

        require(_wethAddressPublic != address(0), "WETH address cannot be 0x00");
        wethAddressPublic = _wethAddressPublic;
        emit publicWethAddressSet(_wethAddressPublic);
    }

    function togglePause() public onlyAdmin {

        if (paused) {
            paused = false;
            emit contractPausedOrUnpaused(false);
        } else {
            paused = true;
            emit contractPausedOrUnpaused(true);
        }
    }

    function getAssetPrice(address asset) public view returns (uint256, uint8) {

        if (!paused) {
            if ( asset == wethAddressVerified || asset == wethAddressPublic ){
                return (expScale, eighteen);
            }
        }
        uint8 assetDecimals = EIP20Interface(asset).decimals();
        if (!paused && priceContractMapping[asset] != address(0)) {
            (
                uint80 roundID,
                int256 price,
                uint256 startedAt,
                uint256 timeStamp,
                uint80 answeredInRound
            ) = priceContractMapping[asset].latestRoundData();
            startedAt; // To avoid compiler warnings for unused local variable
            require(timeStamp > (now - 5 hours), "Stale data");
            require(answeredInRound >= roundID, "Stale Data");
            if (price > 0) {
                return (uint256(price), assetDecimals);
            } else {
                return (0, assetDecimals);
            }
        } else {
            return (0, assetDecimals);
        }
    }

    function() public payable {
        require(
            msg.sender.send(msg.value),
            "Fallback function initiated but refund failed"
        );
    }
}


pragma solidity 0.4.24;

contract AlkemiWETH {

    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function() public payable {
        deposit();
    }

    function deposit() public payable {

        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
        emit Transfer(address(0), msg.sender, msg.value);
    }

    function withdraw(address user, uint256 wad) public {

        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        user.transfer(wad);
        emit Withdrawal(msg.sender, wad);
        emit Transfer(msg.sender, address(0), wad);
    }

    function totalSupply() public view returns (uint256) {

        return address(this).balance;
    }

    function approve(address guy, uint256 wad) public returns (bool) {

        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint256 wad) public returns (bool) {

        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) public returns (bool) {

        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint256(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }
}


pragma solidity 0.4.24;

contract RewardControlInterface {

    function refreshAlkSupplyIndex(
        address market,
        address supplier,
        bool isVerified
    ) external;


    function refreshAlkBorrowIndex(
        address market,
        address borrower,
        bool isVerified
    ) external;


    function claimAlk(address holder) external;


    function claimAlk(
        address holder,
        address market,
        bool isVerified
    ) external;

}


pragma solidity 0.4.24;







contract AlkemiEarnVerified is Exponential, SafeToken {

    uint256 internal initialInterestIndex;
    uint256 internal defaultOriginationFee;
    uint256 internal defaultCollateralRatio;
    uint256 internal defaultLiquidationDiscount;
    uint256 public minimumCollateralRatioMantissa;
    uint256 public maximumLiquidationDiscountMantissa;
    bool private initializationDone; // To make sure initializer is called only once

    function initializer() public {

        if (initializationDone == false) {
            initializationDone = true;
            admin = msg.sender;
            initialInterestIndex = 10**18;
            minimumCollateralRatioMantissa = 11 * (10**17); // 1.1
            maximumLiquidationDiscountMantissa = (10**17); // 0.1
            collateralRatio = Exp({mantissa: 125 * (10**16)});
            originationFee = Exp({mantissa: (10**15)});
            liquidationDiscount = Exp({mantissa: (10**17)});
        }
    }

    function() public payable {
        revert();
    }

    address public pendingAdmin;

    address public admin;

    mapping(address => bool) public managers;

    address private oracle;

    modifier onlyOwner() {

        require(msg.sender == admin, "Owner check failed");
        _;
    }

    modifier onlyCustomerWithKYC() {

        require(
            customersWithKYC[msg.sender],
            "KYC_CUSTOMER_VERIFICATION_CHECK_FAILED"
        );
        _;
    }
    ChainLink public priceOracle;

    struct Balance {
        uint256 principal;
        uint256 interestIndex;
    }

    mapping(address => mapping(address => Balance)) public supplyBalances;

    mapping(address => mapping(address => Balance)) public borrowBalances;

    struct Market {
        bool isSupported;
        uint256 blockNumber;
        InterestRateModel interestRateModel;
        uint256 totalSupply;
        uint256 supplyRateMantissa;
        uint256 supplyIndex;
        uint256 totalBorrows;
        uint256 borrowRateMantissa;
        uint256 borrowIndex;
    }

    address private wethAddress;

    AlkemiWETH public WETHContract;

    mapping(address => Market) public markets;

    address[] public collateralMarkets;

    Exp public collateralRatio;

    Exp public originationFee;

    Exp public liquidationDiscount;

    bool public paused;

    mapping(address => bool) public KYCAdmins;
    mapping(address => bool) public customersWithKYC;

    mapping(address => bool) public liquidators;

    struct SupplyLocalVars {
        uint256 startingBalance;
        uint256 newSupplyIndex;
        uint256 userSupplyCurrent;
        uint256 userSupplyUpdated;
        uint256 newTotalSupply;
        uint256 currentCash;
        uint256 updatedCash;
        uint256 newSupplyRateMantissa;
        uint256 newBorrowIndex;
        uint256 newBorrowRateMantissa;
    }


    struct WithdrawLocalVars {
        uint256 withdrawAmount;
        uint256 startingBalance;
        uint256 newSupplyIndex;
        uint256 userSupplyCurrent;
        uint256 userSupplyUpdated;
        uint256 newTotalSupply;
        uint256 currentCash;
        uint256 updatedCash;
        uint256 newSupplyRateMantissa;
        uint256 newBorrowIndex;
        uint256 newBorrowRateMantissa;
        uint256 withdrawCapacity;
        Exp accountLiquidity;
        Exp accountShortfall;
        Exp ethValueOfWithdrawal;
    }

    struct AccountValueLocalVars {
        address assetAddress;
        uint256 collateralMarketsLength;
        uint256 newSupplyIndex;
        uint256 userSupplyCurrent;
        uint256 newBorrowIndex;
        uint256 userBorrowCurrent;
        Exp borrowTotalValue;
        Exp sumBorrows;
        Exp supplyTotalValue;
        Exp sumSupplies;
    }

    struct PayBorrowLocalVars {
        uint256 newBorrowIndex;
        uint256 userBorrowCurrent;
        uint256 repayAmount;
        uint256 userBorrowUpdated;
        uint256 newTotalBorrows;
        uint256 currentCash;
        uint256 updatedCash;
        uint256 newSupplyIndex;
        uint256 newSupplyRateMantissa;
        uint256 newBorrowRateMantissa;
        uint256 startingBalance;
    }

    struct BorrowLocalVars {
        uint256 newBorrowIndex;
        uint256 userBorrowCurrent;
        uint256 borrowAmountWithFee;
        uint256 userBorrowUpdated;
        uint256 newTotalBorrows;
        uint256 currentCash;
        uint256 updatedCash;
        uint256 newSupplyIndex;
        uint256 newSupplyRateMantissa;
        uint256 newBorrowRateMantissa;
        uint256 startingBalance;
        Exp accountLiquidity;
        Exp accountShortfall;
        Exp ethValueOfBorrowAmountWithFee;
    }

    struct LiquidateLocalVars {
        address targetAccount;
        address assetBorrow;
        address liquidator;
        address assetCollateral;
        uint256 newBorrowIndex_UnderwaterAsset;
        uint256 newSupplyIndex_UnderwaterAsset;
        uint256 newBorrowIndex_CollateralAsset;
        uint256 newSupplyIndex_CollateralAsset;
        uint256 currentBorrowBalance_TargetUnderwaterAsset;
        uint256 updatedBorrowBalance_TargetUnderwaterAsset;
        uint256 newTotalBorrows_ProtocolUnderwaterAsset;
        uint256 startingBorrowBalance_TargetUnderwaterAsset;
        uint256 startingSupplyBalance_TargetCollateralAsset;
        uint256 startingSupplyBalance_LiquidatorCollateralAsset;
        uint256 currentSupplyBalance_TargetCollateralAsset;
        uint256 updatedSupplyBalance_TargetCollateralAsset;
        uint256 currentSupplyBalance_LiquidatorCollateralAsset;
        uint256 updatedSupplyBalance_LiquidatorCollateralAsset;
        uint256 newTotalSupply_ProtocolCollateralAsset;
        uint256 currentCash_ProtocolUnderwaterAsset;
        uint256 updatedCash_ProtocolUnderwaterAsset;

        uint256 newSupplyRateMantissa_ProtocolUnderwaterAsset;
        uint256 newBorrowRateMantissa_ProtocolUnderwaterAsset;

        uint256 discountedRepayToEvenAmount;
        uint256 discountedBorrowDenominatedCollateral;
        uint256 maxCloseableBorrowAmount_TargetUnderwaterAsset;
        uint256 closeBorrowAmount_TargetUnderwaterAsset;
        uint256 seizeSupplyAmount_TargetCollateralAsset;
        uint256 reimburseAmount;
        Exp collateralPrice;
        Exp underwaterAssetPrice;
    }

    mapping(address => mapping(address => uint256))
        public originationFeeBalance;

    RewardControlInterface public rewardControl;

    uint256 public closeFactorMantissa;

    uint256 public _guardCounter;

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }

    event LiquidatorChanged(address indexed Liquidator, bool newStatus);

    event SupplyReceived(
        address account,
        address asset,
        uint256 amount,
        uint256 startingBalance,
        uint256 newBalance
    );

    event SupplyWithdrawn(
        address account,
        address asset,
        uint256 amount,
        uint256 startingBalance,
        uint256 newBalance
    );

    event BorrowTaken(
        address account,
        address asset,
        uint256 amount,
        uint256 startingBalance,
        uint256 borrowAmountWithFee,
        uint256 newBalance
    );

    event BorrowRepaid(
        address account,
        address asset,
        uint256 amount,
        uint256 startingBalance,
        uint256 newBalance
    );

    event BorrowLiquidated(
        address indexed targetAccount,
        address assetBorrow,
        uint256 borrowBalanceAccumulated,
        uint256 amountRepaid,
        address indexed liquidator,
        address assetCollateral,
        uint256 amountSeized
    );

    event EquityWithdrawn(
        address indexed asset,
        uint256 equityAvailableBefore,
        uint256 amount,
        address indexed owner
    );


    event KYCAdminChanged(address indexed KYCAdmin, bool newStatus);
    event KYCCustomerChanged(address indexed KYCCustomer, bool newStatus);

    function _changeKYCAdmin(address KYCAdmin, bool newStatus)
        public
        onlyOwner
    {

        KYCAdmins[KYCAdmin] = newStatus;
        emit KYCAdminChanged(KYCAdmin, newStatus);
    }

    function _changeCustomerKYC(address customer, bool newStatus) public {

        require(KYCAdmins[msg.sender], "KYC_ADMIN_CHECK_FAILED");
        customersWithKYC[customer] = newStatus;
        emit KYCCustomerChanged(customer, newStatus);
    }


    function _changeLiquidator(address liquidator, bool newStatus)
        public
        onlyOwner
    {

        liquidators[liquidator] = newStatus;
        emit LiquidatorChanged(liquidator, newStatus);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a < b) {
            return a;
        } else {
            return b;
        }
    }

    function addCollateralMarket(address asset) internal {

        for (uint256 i = 0; i < collateralMarkets.length; i++) {
            if (collateralMarkets[i] == asset) {
                return;
            }
        }

        collateralMarkets.push(asset);
    }

    function calculateInterestIndex(
        uint256 startingInterestIndex,
        uint256 interestRateMantissa,
        uint256 blockStart,
        uint256 blockEnd
    ) internal pure returns (Error, uint256) {

        (Error err0, uint256 blockDelta) = sub(blockEnd, blockStart);
        if (err0 != Error.NO_ERROR) {
            return (err0, 0);
        }

        (Error err1, Exp memory blocksTimesRate) = mulScalar(
            Exp({mantissa: interestRateMantissa}),
            blockDelta
        );
        if (err1 != Error.NO_ERROR) {
            return (err1, 0);
        }

        (Error err2, Exp memory onePlusBlocksTimesRate) = addExp(
            blocksTimesRate,
            Exp({mantissa: mantissaOne})
        );
        if (err2 != Error.NO_ERROR) {
            return (err2, 0);
        }

        (Error err3, Exp memory newInterestIndexExp) = mulScalar(
            onePlusBlocksTimesRate,
            startingInterestIndex
        );
        if (err3 != Error.NO_ERROR) {
            return (err3, 0);
        }

        return (Error.NO_ERROR, truncate(newInterestIndexExp));
    }

    function calculateBalance(
        uint256 startingBalance,
        uint256 interestIndexStart,
        uint256 interestIndexEnd
    ) internal pure returns (Error, uint256) {

        if (startingBalance == 0) {
            return (Error.NO_ERROR, 0);
        }
        (Error err0, uint256 balanceTimesIndex) = mul(
            startingBalance,
            interestIndexEnd
        );
        if (err0 != Error.NO_ERROR) {
            return (err0, 0);
        }

        return div(balanceTimesIndex, interestIndexStart);
    }

    function getPriceForAssetAmount(
        address asset,
        uint256 assetAmount,
        bool mulCollatRatio
    ) internal view returns (Error, Exp memory) {

        (Error err, Exp memory assetPrice) = fetchAssetPrice(asset);
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}));
        }
        if (isZeroExp(assetPrice)) {
            return (Error.MISSING_ASSET_PRICE, Exp({mantissa: 0}));
        }
        if (mulCollatRatio) {
            Exp memory scaledPrice;
            (err, scaledPrice) = mulExp(collateralRatio, assetPrice);
            if (err != Error.NO_ERROR) {
                return (err, Exp({mantissa: 0}));
            }
            return mulScalar(scaledPrice, assetAmount);
        }
        return mulScalar(assetPrice, assetAmount); // assetAmountWei * oraclePrice = assetValueInEth
    }

    function calculateBorrowAmountWithFee(uint256 borrowAmount)
        internal
        view
        returns (Error, uint256)
    {

        if (isZeroExp(originationFee)) {
            return (Error.NO_ERROR, borrowAmount);
        }

        (Error err0, Exp memory originationFeeFactor) = addExp(
            originationFee,
            Exp({mantissa: mantissaOne})
        );
        if (err0 != Error.NO_ERROR) {
            return (err0, 0);
        }

        (Error err1, Exp memory borrowAmountWithFee) = mulScalar(
            originationFeeFactor,
            borrowAmount
        );
        if (err1 != Error.NO_ERROR) {
            return (err1, 0);
        }

        return (Error.NO_ERROR, truncate(borrowAmountWithFee));
    }

    function fetchAssetPrice(address asset)
        internal
        view
        returns (Error, Exp memory)
    {

        if (priceOracle == address(0)) {
            return (Error.ZERO_ORACLE_ADDRESS, Exp({mantissa: 0}));
        }

        if (priceOracle.paused()) {
            return (Error.MISSING_ASSET_PRICE, Exp({mantissa: 0}));
        }

        (uint256 priceMantissa, uint8 assetDecimals) = priceOracle
        .getAssetPrice(asset);
        (Error err, uint256 magnification) = sub(18, uint256(assetDecimals));
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}));
        }
        (err, priceMantissa) = mul(priceMantissa, 10**magnification);
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}));
        }
        return (Error.NO_ERROR, Exp({mantissa: priceMantissa}));
    }

    function assetPrices(address asset) public view returns (uint256) {

        (Error err, Exp memory result) = fetchAssetPrice(asset);
        if (err != Error.NO_ERROR) {
            return 0;
        }
        return result.mantissa;
    }

    function getAssetAmountForValue(address asset, Exp ethValue)
        internal
        view
        returns (Error, uint256)
    {

        Error err;
        Exp memory assetPrice;
        Exp memory assetAmount;

        (err, assetPrice) = fetchAssetPrice(asset);
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, assetAmount) = divExp(ethValue, assetPrice);
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        return (Error.NO_ERROR, truncate(assetAmount));
    }

    function _adminFunctions(
        address newPendingAdmin,
        address newOracle,
        bool requestedState,
        uint256 originationFeeMantissa,
        uint256 newCloseFactorMantissa,
        address wethContractAddress,
        address _rewardControl
    ) public onlyOwner returns (uint256) {

        require(newOracle != address(0), "Cannot set weth address to 0x00");
        require(
            originationFeeMantissa < 10**18 && newCloseFactorMantissa < 10**18,
            "Invalid Origination Fee or Close Factor Mantissa"
        );
        pendingAdmin = newPendingAdmin;

        priceOracle = ChainLink(newOracle);

        paused = requestedState;

        originationFee = Exp({mantissa: originationFeeMantissa});

        closeFactorMantissa = newCloseFactorMantissa;

        require(
            wethContractAddress != address(0),
            "Cannot set weth address to 0x00"
        );
        wethAddress = wethContractAddress;
        WETHContract = AlkemiWETH(wethAddress);

        rewardControl = RewardControlInterface(_rewardControl);

        return uint256(Error.NO_ERROR);
    }

    function _acceptAdmin() public {

        require(msg.sender == pendingAdmin, "ACCEPT_ADMIN_PENDING_ADMIN_CHECK");
        admin = pendingAdmin;
        pendingAdmin = 0;
    }

    function getAccountLiquidity(address account) public view returns (int256) {

        (
            Error err,
            Exp memory accountLiquidity,
            Exp memory accountShortfall
        ) = calculateAccountLiquidity(account);
        revertIfError(err);

        if (isZeroExp(accountLiquidity)) {
            return -1 * int256(truncate(accountShortfall));
        } else {
            return int256(truncate(accountLiquidity));
        }
    }

    function getSupplyBalance(address account, address asset)
        public
        view
        returns (uint256)
    {

        Error err;
        uint256 newSupplyIndex;
        uint256 userSupplyCurrent;

        Market storage market = markets[asset];
        Balance storage supplyBalance = supplyBalances[account][asset];

        (err, newSupplyIndex) = calculateInterestIndex(
            market.supplyIndex,
            market.supplyRateMantissa,
            market.blockNumber,
            block.number
        );
        revertIfError(err);

        (err, userSupplyCurrent) = calculateBalance(
            supplyBalance.principal,
            supplyBalance.interestIndex,
            newSupplyIndex
        );
        revertIfError(err);

        return userSupplyCurrent;
    }

    function getBorrowBalance(address account, address asset)
        public
        view
        returns (uint256)
    {

        Error err;
        uint256 newBorrowIndex;
        uint256 userBorrowCurrent;

        Market storage market = markets[asset];
        Balance storage borrowBalance = borrowBalances[account][asset];

        (err, newBorrowIndex) = calculateInterestIndex(
            market.borrowIndex,
            market.borrowRateMantissa,
            market.blockNumber,
            block.number
        );
        revertIfError(err);

        (err, userBorrowCurrent) = calculateBalance(
            borrowBalance.principal,
            borrowBalance.interestIndex,
            newBorrowIndex
        );
        revertIfError(err);

        return userBorrowCurrent;
    }

    function _supportMarket(address asset, InterestRateModel interestRateModel)
        public
        onlyOwner
        returns (uint256)
    {

        require(
            interestRateModel != address(0) &&
                collateralMarkets.length < 16, // 16 = MAXIMUM_NUMBER_OF_MARKETS_ALLOWED
            "INPUT_VALIDATION_FAILED"
        );

        (Error err, Exp memory assetPrice) = fetchAssetPrice(asset);
        if (err != Error.NO_ERROR) {
            return fail(err, FailureInfo.SUPPORT_MARKET_FETCH_PRICE_FAILED);
        }

        if (isZeroExp(assetPrice)) {
            return
                fail(
                    Error.ASSET_NOT_PRICED,
                    FailureInfo.SUPPORT_MARKET_PRICE_CHECK
                );
        }

        markets[asset].interestRateModel = interestRateModel;

        addCollateralMarket(asset);

        markets[asset].isSupported = true;

        if (markets[asset].supplyIndex == 0) {
            markets[asset].supplyIndex = initialInterestIndex;
        }

        if (markets[asset].borrowIndex == 0) {
            markets[asset].borrowIndex = initialInterestIndex;
        }

        return uint256(Error.NO_ERROR);
    }

    function _suspendMarket(address asset) public onlyOwner returns (uint256) {

        if (!markets[asset].isSupported) {
            return uint256(Error.NO_ERROR);
        }

        markets[asset].isSupported = false;

        return uint256(Error.NO_ERROR);
    }

    function _setRiskParameters(
        uint256 collateralRatioMantissa,
        uint256 liquidationDiscountMantissa
    ) public onlyOwner returns (uint256) {

        require(
            collateralRatioMantissa >= minimumCollateralRatioMantissa &&
                liquidationDiscountMantissa <=
                maximumLiquidationDiscountMantissa,
            "Liquidation discount is more than max discount or collateral ratio is less than min ratio"
        );

        Exp memory newCollateralRatio = Exp({
            mantissa: collateralRatioMantissa
        });
        Exp memory newLiquidationDiscount = Exp({
            mantissa: liquidationDiscountMantissa
        });
        Exp memory minimumCollateralRatio = Exp({
            mantissa: minimumCollateralRatioMantissa
        });
        Exp memory maximumLiquidationDiscount = Exp({
            mantissa: maximumLiquidationDiscountMantissa
        });

        Error err;
        Exp memory newLiquidationDiscountPlusOne;

        if (lessThanExp(newCollateralRatio, minimumCollateralRatio)) {
            return
                fail(
                    Error.INVALID_COLLATERAL_RATIO,
                    FailureInfo.SET_RISK_PARAMETERS_VALIDATION
                );
        }

        if (lessThanExp(maximumLiquidationDiscount, newLiquidationDiscount)) {
            return
                fail(
                    Error.INVALID_LIQUIDATION_DISCOUNT,
                    FailureInfo.SET_RISK_PARAMETERS_VALIDATION
                );
        }

        (err, newLiquidationDiscountPlusOne) = addExp(
            newLiquidationDiscount,
            Exp({mantissa: mantissaOne})
        );
        revertIfError(err); // We already validated that newLiquidationDiscount does not approach overflow size

        if (
            lessThanOrEqualExp(
                newCollateralRatio,
                newLiquidationDiscountPlusOne
            )
        ) {
            return
                fail(
                    Error.INVALID_COMBINED_RISK_PARAMETERS,
                    FailureInfo.SET_RISK_PARAMETERS_VALIDATION
                );
        }

        collateralRatio = newCollateralRatio;
        liquidationDiscount = newLiquidationDiscount;

        return uint256(Error.NO_ERROR);
    }

    function _setMarketInterestRateModel(
        address asset,
        InterestRateModel interestRateModel
    ) public onlyOwner returns (uint256) {

        require(interestRateModel != address(0), "Rate Model cannot be 0x00");

        markets[asset].interestRateModel = interestRateModel;

        return uint256(Error.NO_ERROR);
    }

    function _withdrawEquity(address asset, uint256 amount)
        public
        onlyOwner
        returns (uint256)
    {

        uint256 cash = getCash(asset);
        (
            uint256 supplyWithInterest,
            uint256 borrowWithInterest
        ) = getMarketBalances(asset);
        (Error err0, uint256 equity) = addThenSub(
            getCash(asset),
            borrowWithInterest,
            supplyWithInterest
        );
        if (err0 != Error.NO_ERROR) {
            return fail(err0, FailureInfo.EQUITY_WITHDRAWAL_CALCULATE_EQUITY);
        }

        if (amount > equity) {
            return
                fail(
                    Error.EQUITY_INSUFFICIENT_BALANCE,
                    FailureInfo.EQUITY_WITHDRAWAL_AMOUNT_VALIDATION
                );
        }


        if (asset != wethAddress) {
            Error err2 = doTransferOut(asset, admin, amount);
            if (err2 != Error.NO_ERROR) {
                return
                    fail(
                        err2,
                        FailureInfo.EQUITY_WITHDRAWAL_TRANSFER_OUT_FAILED
                    );
            }
        } else {
            withdrawEther(admin, amount); // send Ether to user
        }

        (, markets[asset].supplyRateMantissa) = markets[asset]
        .interestRateModel
        .getSupplyRate(asset, cash - amount, markets[asset].totalSupply);

        (, markets[asset].borrowRateMantissa) = markets[asset]
        .interestRateModel
        .getBorrowRate(asset, cash - amount, markets[asset].totalBorrows);

        emit EquityWithdrawn(asset, equity, amount, admin);

        return uint256(Error.NO_ERROR); // success
    }

    function supplyEther(uint256 etherAmount) internal returns (uint256) {

        require(wethAddress != address(0), "WETH_ADDRESS_NOT_SET_ERROR");
        WETHContract.deposit.value(etherAmount)();
        return uint256(Error.NO_ERROR);
    }

    function revertEtherToUser(address user, uint256 etherAmount) internal {

        if (etherAmount > 0) {
            user.transfer(etherAmount);
        }
    }

    function supply(address asset, uint256 amount)
        public
        payable
        nonReentrant
        onlyCustomerWithKYC
        returns (uint256)
    {

        if (paused) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(Error.CONTRACT_PAUSED, FailureInfo.SUPPLY_CONTRACT_PAUSED);
        }

        refreshAlkIndex(asset, msg.sender, true, true);

        Market storage market = markets[asset];
        Balance storage balance = supplyBalances[msg.sender][asset];

        SupplyLocalVars memory localResults; // Holds all our uint calculation results
        Error err; // Re-used for every function call that includes an Error in its return value(s).
        uint256 rateCalculationResultCode; // Used for 2 interest rate calculation calls

        if (!market.isSupported) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    Error.MARKET_NOT_SUPPORTED,
                    FailureInfo.SUPPLY_MARKET_NOT_SUPPORTED
                );
        }
        if (asset != wethAddress) {
            revertEtherToUser(msg.sender, msg.value);
            err = checkTransferIn(asset, msg.sender, amount);
            if (err != Error.NO_ERROR) {
                return fail(err, FailureInfo.SUPPLY_TRANSFER_IN_NOT_POSSIBLE);
            }
        }

        (err, localResults.newSupplyIndex) = calculateInterestIndex(
            market.supplyIndex,
            market.supplyRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.SUPPLY_NEW_SUPPLY_INDEX_CALCULATION_FAILED
                );
        }

        (err, localResults.userSupplyCurrent) = calculateBalance(
            balance.principal,
            balance.interestIndex,
            localResults.newSupplyIndex
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.SUPPLY_ACCUMULATED_BALANCE_CALCULATION_FAILED
                );
        }

        (err, localResults.userSupplyUpdated) = add(
            localResults.userSupplyCurrent,
            amount
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.SUPPLY_NEW_TOTAL_BALANCE_CALCULATION_FAILED
                );
        }

        (err, localResults.newTotalSupply) = addThenSub(
            market.totalSupply,
            localResults.userSupplyUpdated,
            balance.principal
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.SUPPLY_NEW_TOTAL_SUPPLY_CALCULATION_FAILED
                );
        }

        localResults.currentCash = getCash(asset);

        (err, localResults.updatedCash) = add(localResults.currentCash, amount);
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(err, FailureInfo.SUPPLY_NEW_TOTAL_CASH_CALCULATION_FAILED);
        }

        (rateCalculationResultCode, localResults.newSupplyRateMantissa) = market
        .interestRateModel
        .getSupplyRate(asset, localResults.updatedCash, market.totalBorrows);
        if (rateCalculationResultCode != 0) {
            revertEtherToUser(msg.sender, msg.value);
            return
                failOpaque(
                    FailureInfo.SUPPLY_NEW_SUPPLY_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }

        (err, localResults.newBorrowIndex) = calculateInterestIndex(
            market.borrowIndex,
            market.borrowRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.SUPPLY_NEW_BORROW_INDEX_CALCULATION_FAILED
                );
        }

        (rateCalculationResultCode, localResults.newBorrowRateMantissa) = market
        .interestRateModel
        .getBorrowRate(asset, localResults.updatedCash, market.totalBorrows);
        if (rateCalculationResultCode != 0) {
            revertEtherToUser(msg.sender, msg.value);
            return
                failOpaque(
                    FailureInfo.SUPPLY_NEW_BORROW_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }

        market.blockNumber = block.number;
        market.totalSupply = localResults.newTotalSupply;
        market.supplyRateMantissa = localResults.newSupplyRateMantissa;
        market.supplyIndex = localResults.newSupplyIndex;
        market.borrowRateMantissa = localResults.newBorrowRateMantissa;
        market.borrowIndex = localResults.newBorrowIndex;

        localResults.startingBalance = balance.principal; // save for use in `SupplyReceived` event
        balance.principal = localResults.userSupplyUpdated;
        balance.interestIndex = localResults.newSupplyIndex;

        if (asset != wethAddress) {
            revertEtherToUser(msg.sender, msg.value);
            err = doTransferIn(asset, msg.sender, amount);
            if (err != Error.NO_ERROR) {
                return fail(err, FailureInfo.SUPPLY_TRANSFER_IN_FAILED);
            }
        } else {
            if (msg.value == amount) {
                uint256 supplyError = supplyEther(msg.value);
                if (supplyError != 0) {
                    revertEtherToUser(msg.sender, msg.value);
                    return
                        fail(
                            Error.WETH_ADDRESS_NOT_SET_ERROR,
                            FailureInfo.WETH_ADDRESS_NOT_SET_ERROR
                        );
                }
            } else {
                revertEtherToUser(msg.sender, msg.value);
                return
                    fail(
                        Error.ETHER_AMOUNT_MISMATCH_ERROR,
                        FailureInfo.ETHER_AMOUNT_MISMATCH_ERROR
                    );
            }
        }

        emit SupplyReceived(
            msg.sender,
            asset,
            amount,
            localResults.startingBalance,
            balance.principal
        );

        return uint256(Error.NO_ERROR); // success
    }

    function withdrawEther(address user, uint256 etherAmount)
        internal
        returns (uint256)
    {

        WETHContract.withdraw(user, etherAmount);
        return uint256(Error.NO_ERROR);
    }

    function withdraw(address asset, uint256 requestedAmount)
        public
        nonReentrant
        returns (uint256)
    {

        if (paused) {
            return
                fail(
                    Error.CONTRACT_PAUSED,
                    FailureInfo.WITHDRAW_CONTRACT_PAUSED
                );
        }

        refreshAlkIndex(asset, msg.sender, true, true);

        Market storage market = markets[asset];
        Balance storage supplyBalance = supplyBalances[msg.sender][asset];

        WithdrawLocalVars memory localResults; // Holds all our calculation results
        Error err; // Re-used for every function call that includes an Error in its return value(s).
        uint256 rateCalculationResultCode; // Used for 2 interest rate calculation calls

        (
            err,
            localResults.accountLiquidity,
            localResults.accountShortfall
        ) = calculateAccountLiquidity(msg.sender);
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.WITHDRAW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED
                );
        }

        (err, localResults.newSupplyIndex) = calculateInterestIndex(
            market.supplyIndex,
            market.supplyRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.WITHDRAW_NEW_SUPPLY_INDEX_CALCULATION_FAILED
                );
        }

        (err, localResults.userSupplyCurrent) = calculateBalance(
            supplyBalance.principal,
            supplyBalance.interestIndex,
            localResults.newSupplyIndex
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.WITHDRAW_ACCUMULATED_BALANCE_CALCULATION_FAILED
                );
        }

        if (requestedAmount == uint256(-1)) {
            (err, localResults.withdrawCapacity) = getAssetAmountForValue(
                asset,
                localResults.accountLiquidity
            );
            if (err != Error.NO_ERROR) {
                return
                    fail(err, FailureInfo.WITHDRAW_CAPACITY_CALCULATION_FAILED);
            }
            localResults.withdrawAmount = min(
                localResults.withdrawCapacity,
                localResults.userSupplyCurrent
            );
        } else {
            localResults.withdrawAmount = requestedAmount;
        }


        localResults.currentCash = getCash(asset);
        (err, localResults.updatedCash) = sub(
            localResults.currentCash,
            localResults.withdrawAmount
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    Error.TOKEN_INSUFFICIENT_CASH,
                    FailureInfo.WITHDRAW_TRANSFER_OUT_NOT_POSSIBLE
                );
        }

        (err, localResults.userSupplyUpdated) = sub(
            localResults.userSupplyCurrent,
            localResults.withdrawAmount
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    Error.INSUFFICIENT_BALANCE,
                    FailureInfo.WITHDRAW_NEW_TOTAL_BALANCE_CALCULATION_FAILED
                );
        }

        if (!isZeroExp(localResults.accountShortfall)) {
            return
                fail(
                    Error.INSUFFICIENT_LIQUIDITY,
                    FailureInfo.WITHDRAW_ACCOUNT_SHORTFALL_PRESENT
                );
        }

        (err, localResults.ethValueOfWithdrawal) = getPriceForAssetAmount(
            asset,
            localResults.withdrawAmount,
            false
        ); // amount * oraclePrice = ethValueOfWithdrawal
        if (err != Error.NO_ERROR) {
            return
                fail(err, FailureInfo.WITHDRAW_AMOUNT_VALUE_CALCULATION_FAILED);
        }

        if (
            lessThanExp(
                localResults.accountLiquidity,
                localResults.ethValueOfWithdrawal
            )
        ) {
            return
                fail(
                    Error.INSUFFICIENT_LIQUIDITY,
                    FailureInfo.WITHDRAW_AMOUNT_LIQUIDITY_SHORTFALL
                );
        }

        (err, localResults.newTotalSupply) = addThenSub(
            market.totalSupply,
            localResults.userSupplyUpdated,
            supplyBalance.principal
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.WITHDRAW_NEW_TOTAL_SUPPLY_CALCULATION_FAILED
                );
        }

        (rateCalculationResultCode, localResults.newSupplyRateMantissa) = market
        .interestRateModel
        .getSupplyRate(asset, localResults.updatedCash, market.totalBorrows);
        if (rateCalculationResultCode != 0) {
            return
                failOpaque(
                    FailureInfo.WITHDRAW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }

        (err, localResults.newBorrowIndex) = calculateInterestIndex(
            market.borrowIndex,
            market.borrowRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.WITHDRAW_NEW_BORROW_INDEX_CALCULATION_FAILED
                );
        }

        (rateCalculationResultCode, localResults.newBorrowRateMantissa) = market
        .interestRateModel
        .getBorrowRate(asset, localResults.updatedCash, market.totalBorrows);
        if (rateCalculationResultCode != 0) {
            return
                failOpaque(
                    FailureInfo.WITHDRAW_NEW_BORROW_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }

        market.blockNumber = block.number;
        market.totalSupply = localResults.newTotalSupply;
        market.supplyRateMantissa = localResults.newSupplyRateMantissa;
        market.supplyIndex = localResults.newSupplyIndex;
        market.borrowRateMantissa = localResults.newBorrowRateMantissa;
        market.borrowIndex = localResults.newBorrowIndex;

        localResults.startingBalance = supplyBalance.principal; // save for use in `SupplyWithdrawn` event
        supplyBalance.principal = localResults.userSupplyUpdated;
        supplyBalance.interestIndex = localResults.newSupplyIndex;

        if (asset != wethAddress) {
            err = doTransferOut(asset, msg.sender, localResults.withdrawAmount);
            if (err != Error.NO_ERROR) {
                return fail(err, FailureInfo.WITHDRAW_TRANSFER_OUT_FAILED);
            }
        } else {
            withdrawEther(msg.sender, localResults.withdrawAmount); // send Ether to user
        }

        emit SupplyWithdrawn(
            msg.sender,
            asset,
            localResults.withdrawAmount,
            localResults.startingBalance,
            supplyBalance.principal
        );

        return uint256(Error.NO_ERROR); // success
    }

    function calculateAccountLiquidity(address userAddress)
        internal
        view
        returns (
            Error,
            Exp memory,
            Exp memory
        )
    {

        Error err;
        Exp memory sumSupplyValuesMantissa;
        Exp memory sumBorrowValuesMantissa;
        (
            err,
            sumSupplyValuesMantissa,
            sumBorrowValuesMantissa
        ) = calculateAccountValuesInternal(userAddress);
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
        }

        Exp memory result;

        Exp memory sumSupplyValuesFinal = Exp({
            mantissa: sumSupplyValuesMantissa.mantissa
        });
        Exp memory sumBorrowValuesFinal; // need to apply collateral ratio

        (err, sumBorrowValuesFinal) = mulExp(
            collateralRatio,
            Exp({mantissa: sumBorrowValuesMantissa.mantissa})
        );
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
        }

        if (lessThanExp(sumSupplyValuesFinal, sumBorrowValuesFinal)) {
            (err, result) = subExp(sumBorrowValuesFinal, sumSupplyValuesFinal);
            revertIfError(err); // Note: we have checked that sumBorrows is greater than sumSupplies directly above, therefore `subExp` cannot fail.

            return (Error.NO_ERROR, Exp({mantissa: 0}), result);
        } else {
            (err, result) = subExp(sumSupplyValuesFinal, sumBorrowValuesFinal);
            revertIfError(err); // Note: we have checked that sumSupplies is greater than sumBorrows directly above, therefore `subExp` cannot fail.

            return (Error.NO_ERROR, result, Exp({mantissa: 0}));
        }
    }

    function calculateAccountValuesInternal(address userAddress)
        internal
        view
        returns (
            Error,
            Exp memory,
            Exp memory
        )
    {


        AccountValueLocalVars memory localResults; // Re-used for all intermediate results
        localResults.sumSupplies = Exp({mantissa: 0});
        localResults.sumBorrows = Exp({mantissa: 0});
        Error err; // Re-used for all intermediate errors
        localResults.collateralMarketsLength = collateralMarkets.length;

        for (uint256 i = 0; i < localResults.collateralMarketsLength; i++) {
            localResults.assetAddress = collateralMarkets[i];
            Market storage currentMarket = markets[localResults.assetAddress];
            Balance storage supplyBalance = supplyBalances[userAddress][
                localResults.assetAddress
            ];
            Balance storage borrowBalance = borrowBalances[userAddress][
                localResults.assetAddress
            ];

            if (supplyBalance.principal > 0) {
                (err, localResults.newSupplyIndex) = calculateInterestIndex(
                    currentMarket.supplyIndex,
                    currentMarket.supplyRateMantissa,
                    currentMarket.blockNumber,
                    block.number
                );
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }

                (err, localResults.userSupplyCurrent) = calculateBalance(
                    supplyBalance.principal,
                    supplyBalance.interestIndex,
                    localResults.newSupplyIndex
                );
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }

                (err, localResults.supplyTotalValue) = getPriceForAssetAmount(
                    localResults.assetAddress,
                    localResults.userSupplyCurrent,
                    false
                ); // supplyCurrent * oraclePrice = supplyValueInEth
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }

                (err, localResults.sumSupplies) = addExp(
                    localResults.supplyTotalValue,
                    localResults.sumSupplies
                );
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }
            }

            if (borrowBalance.principal > 0) {
                (err, localResults.newBorrowIndex) = calculateInterestIndex(
                    currentMarket.borrowIndex,
                    currentMarket.borrowRateMantissa,
                    currentMarket.blockNumber,
                    block.number
                );
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }

                (err, localResults.userBorrowCurrent) = calculateBalance(
                    borrowBalance.principal,
                    borrowBalance.interestIndex,
                    localResults.newBorrowIndex
                );
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }

                (err, localResults.borrowTotalValue) = getPriceForAssetAmount(
                    localResults.assetAddress,
                    localResults.userBorrowCurrent,
                    false
                ); // borrowCurrent * oraclePrice = borrowValueInEth
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }

                (err, localResults.sumBorrows) = addExp(
                    localResults.borrowTotalValue,
                    localResults.sumBorrows
                );
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }
            }
        }

        return (
            Error.NO_ERROR,
            localResults.sumSupplies,
            localResults.sumBorrows
        );
    }

    function calculateAccountValues(address userAddress)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        (
            Error err,
            Exp memory supplyValue,
            Exp memory borrowValue
        ) = calculateAccountValuesInternal(userAddress);
        if (err != Error.NO_ERROR) {
            return (uint256(err), 0, 0);
        }

        return (0, supplyValue.mantissa, borrowValue.mantissa);
    }

    function repayBorrow(address asset, uint256 amount)
        public
        payable
        nonReentrant
        returns (uint256)
    {

        if (paused) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    Error.CONTRACT_PAUSED,
                    FailureInfo.REPAY_BORROW_CONTRACT_PAUSED
                );
        }
        refreshAlkIndex(asset, msg.sender, false, true);
        PayBorrowLocalVars memory localResults;
        Market storage market = markets[asset];
        Balance storage borrowBalance = borrowBalances[msg.sender][asset];
        Error err;
        uint256 rateCalculationResultCode;

        (err, localResults.newBorrowIndex) = calculateInterestIndex(
            market.borrowIndex,
            market.borrowRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.REPAY_BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED
                );
        }

        (err, localResults.userBorrowCurrent) = calculateBalance(
            borrowBalance.principal,
            borrowBalance.interestIndex,
            localResults.newBorrowIndex
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo
                        .REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED
                );
        }

        uint256 reimburseAmount;
        if (asset != wethAddress) {
            if (amount == uint256(-1)) {
                localResults.repayAmount = min(
                    getBalanceOf(asset, msg.sender),
                    localResults.userBorrowCurrent
                );
            } else {
                localResults.repayAmount = amount;
            }
        } else {
            if (amount > localResults.userBorrowCurrent) {
                localResults.repayAmount = localResults.userBorrowCurrent;
                (err, reimburseAmount) = sub(
                    amount,
                    localResults.userBorrowCurrent
                ); // reimbursement called at the end to make sure function does not have any other errors
                if (err != Error.NO_ERROR) {
                    revertEtherToUser(msg.sender, msg.value);
                    return
                        fail(
                            err,
                            FailureInfo
                                .REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED
                        );
                }
            } else {
                localResults.repayAmount = amount;
            }
        }

        (err, localResults.userBorrowUpdated) = sub(
            localResults.userBorrowCurrent,
            localResults.repayAmount
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo
                        .REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED
                );
        }

        if (asset != wethAddress) {
            revertEtherToUser(msg.sender, msg.value);
            err = checkTransferIn(asset, msg.sender, localResults.repayAmount);
            if (err != Error.NO_ERROR) {
                return
                    fail(
                        err,
                        FailureInfo.REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE
                    );
            }
        }

        (err, localResults.newTotalBorrows) = addThenSub(
            market.totalBorrows,
            localResults.userBorrowUpdated,
            borrowBalance.principal
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.REPAY_BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED
                );
        }

        localResults.currentCash = getCash(asset);

        (err, localResults.updatedCash) = add(
            localResults.currentCash,
            localResults.repayAmount
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.REPAY_BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED
                );
        }


        (err, localResults.newSupplyIndex) = calculateInterestIndex(
            market.supplyIndex,
            market.supplyRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.REPAY_BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED
                );
        }

        (rateCalculationResultCode, localResults.newSupplyRateMantissa) = market
        .interestRateModel
        .getSupplyRate(
            asset,
            localResults.updatedCash,
            localResults.newTotalBorrows
        );
        if (rateCalculationResultCode != 0) {
            revertEtherToUser(msg.sender, msg.value);
            return
                failOpaque(
                    FailureInfo.REPAY_BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }

        (rateCalculationResultCode, localResults.newBorrowRateMantissa) = market
        .interestRateModel
        .getBorrowRate(
            asset,
            localResults.updatedCash,
            localResults.newTotalBorrows
        );
        if (rateCalculationResultCode != 0) {
            revertEtherToUser(msg.sender, msg.value);
            return
                failOpaque(
                    FailureInfo.REPAY_BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }

        market.blockNumber = block.number;
        market.totalBorrows = localResults.newTotalBorrows;
        market.supplyRateMantissa = localResults.newSupplyRateMantissa;
        market.supplyIndex = localResults.newSupplyIndex;
        market.borrowRateMantissa = localResults.newBorrowRateMantissa;
        market.borrowIndex = localResults.newBorrowIndex;

        localResults.startingBalance = borrowBalance.principal; // save for use in `BorrowRepaid` event
        borrowBalance.principal = localResults.userBorrowUpdated;
        borrowBalance.interestIndex = localResults.newBorrowIndex;

        if (asset != wethAddress) {
            revertEtherToUser(msg.sender, msg.value);
            err = doTransferIn(asset, msg.sender, localResults.repayAmount);
            if (err != Error.NO_ERROR) {
                return fail(err, FailureInfo.REPAY_BORROW_TRANSFER_IN_FAILED);
            }
        } else {
            if (msg.value == amount) {
                uint256 supplyError = supplyEther(localResults.repayAmount);
                if (reimburseAmount > 0) {
                    revertEtherToUser(msg.sender, reimburseAmount);
                }
                if (supplyError != 0) {
                    revertEtherToUser(msg.sender, msg.value);
                    return
                        fail(
                            Error.WETH_ADDRESS_NOT_SET_ERROR,
                            FailureInfo.WETH_ADDRESS_NOT_SET_ERROR
                        );
                }
            } else {
                revertEtherToUser(msg.sender, msg.value);
                return
                    fail(
                        Error.ETHER_AMOUNT_MISMATCH_ERROR,
                        FailureInfo.ETHER_AMOUNT_MISMATCH_ERROR
                    );
            }
        }

        supplyOriginationFeeAsAdmin(
            asset,
            msg.sender,
            localResults.repayAmount,
            market.supplyIndex
        );

        emit BorrowRepaid(
            msg.sender,
            asset,
            localResults.repayAmount,
            localResults.startingBalance,
            borrowBalance.principal
        );

        return uint256(Error.NO_ERROR); // success
    }

    function liquidateBorrow(
        address targetAccount,
        address assetBorrow,
        address assetCollateral,
        uint256 requestedAmountClose
    ) public payable returns (uint256) {

        if (paused) {
            return
                fail(
                    Error.CONTRACT_PAUSED,
                    FailureInfo.LIQUIDATE_CONTRACT_PAUSED
                );
        }
        require(liquidators[msg.sender], "LIQUIDATOR_CHECK_FAILED");
        refreshAlkIndex(assetCollateral, targetAccount, true, true);
        refreshAlkIndex(assetCollateral, msg.sender, true, true);
        refreshAlkIndex(assetBorrow, targetAccount, false, true);
        LiquidateLocalVars memory localResults;
        localResults.targetAccount = targetAccount;
        localResults.assetBorrow = assetBorrow;
        localResults.liquidator = msg.sender;
        localResults.assetCollateral = assetCollateral;

        Market storage borrowMarket = markets[assetBorrow];
        Market storage collateralMarket = markets[assetCollateral];
        Balance storage borrowBalance_TargeUnderwaterAsset = borrowBalances[
            targetAccount
        ][assetBorrow];
        Balance storage supplyBalance_TargetCollateralAsset = supplyBalances[
            targetAccount
        ][assetCollateral];



            Balance storage supplyBalance_LiquidatorCollateralAsset
         = supplyBalances[localResults.liquidator][assetCollateral];

        uint256 rateCalculationResultCode; // Used for multiple interest rate calculation calls
        Error err; // re-used for all intermediate errors

        (err, localResults.collateralPrice) = fetchAssetPrice(assetCollateral);
        if (err != Error.NO_ERROR) {
            return fail(err, FailureInfo.LIQUIDATE_FETCH_ASSET_PRICE_FAILED);
        }

        (err, localResults.underwaterAssetPrice) = fetchAssetPrice(assetBorrow);
        revertIfError(err);

        (
            err,
            localResults.newBorrowIndex_UnderwaterAsset
        ) = calculateInterestIndex(
            borrowMarket.borrowIndex,
            borrowMarket.borrowRateMantissa,
            borrowMarket.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_BORROWED_ASSET
                );
        }

        (
            err,
            localResults.currentBorrowBalance_TargetUnderwaterAsset
        ) = calculateBalance(
            borrowBalance_TargeUnderwaterAsset.principal,
            borrowBalance_TargeUnderwaterAsset.interestIndex,
            localResults.newBorrowIndex_UnderwaterAsset
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_ACCUMULATED_BORROW_BALANCE_CALCULATION_FAILED
                );
        }

        (
            err,
            localResults.newSupplyIndex_CollateralAsset
        ) = calculateInterestIndex(
            collateralMarket.supplyIndex,
            collateralMarket.supplyRateMantissa,
            collateralMarket.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET
                );
        }

        (
            err,
            localResults.currentSupplyBalance_TargetCollateralAsset
        ) = calculateBalance(
            supplyBalance_TargetCollateralAsset.principal,
            supplyBalance_TargetCollateralAsset.interestIndex,
            localResults.newSupplyIndex_CollateralAsset
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET
                );
        }

        (
            err,
            localResults.currentSupplyBalance_LiquidatorCollateralAsset
        ) = calculateBalance(
            supplyBalance_LiquidatorCollateralAsset.principal,
            supplyBalance_LiquidatorCollateralAsset.interestIndex,
            localResults.newSupplyIndex_CollateralAsset
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET
                );
        }


        (err, localResults.newTotalSupply_ProtocolCollateralAsset) = addThenSub(
            collateralMarket.totalSupply,
            localResults.currentSupplyBalance_TargetCollateralAsset,
            supplyBalance_TargetCollateralAsset.principal
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET
                );
        }

        (err, localResults.newTotalSupply_ProtocolCollateralAsset) = addThenSub(
            localResults.newTotalSupply_ProtocolCollateralAsset,
            localResults.currentSupplyBalance_LiquidatorCollateralAsset,
            supplyBalance_LiquidatorCollateralAsset.principal
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET
                );
        }


        (
            err,
            localResults.discountedBorrowDenominatedCollateral
        ) = calculateDiscountedBorrowDenominatedCollateral(
            localResults.underwaterAssetPrice,
            localResults.collateralPrice,
            localResults.currentSupplyBalance_TargetCollateralAsset
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_BORROW_DENOMINATED_COLLATERAL_CALCULATION_FAILED
                );
        }

        if (borrowMarket.isSupported) {
            (
                err,
                localResults.discountedRepayToEvenAmount
            ) = calculateDiscountedRepayToEvenAmount(
                targetAccount,
                localResults.underwaterAssetPrice,
                assetBorrow
            );
            if (err != Error.NO_ERROR) {
                return
                    fail(
                        err,
                        FailureInfo
                            .LIQUIDATE_DISCOUNTED_REPAY_TO_EVEN_AMOUNT_CALCULATION_FAILED
                    );
            }

            localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset = min(
                localResults.currentBorrowBalance_TargetUnderwaterAsset,
                localResults.discountedBorrowDenominatedCollateral
            );

            localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset = min(
                localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset,
                localResults.discountedRepayToEvenAmount
            );
        } else {
            localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset = min(
                localResults.currentBorrowBalance_TargetUnderwaterAsset,
                localResults.discountedBorrowDenominatedCollateral
            );
        }

        if (assetBorrow != wethAddress) {
            if (requestedAmountClose == uint256(-1)) {
                localResults
                .closeBorrowAmount_TargetUnderwaterAsset = localResults
                .maxCloseableBorrowAmount_TargetUnderwaterAsset;
            } else {
                localResults
                .closeBorrowAmount_TargetUnderwaterAsset = requestedAmountClose;
            }
        } else {
            if (
                requestedAmountClose >
                localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset
            ) {
                localResults
                .closeBorrowAmount_TargetUnderwaterAsset = localResults
                .maxCloseableBorrowAmount_TargetUnderwaterAsset;
                (err, localResults.reimburseAmount) = sub(
                    requestedAmountClose,
                    localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset
                ); // reimbursement called at the end to make sure function does not have any other errors
                if (err != Error.NO_ERROR) {
                    return
                        fail(
                            err,
                            FailureInfo
                                .REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED
                        );
                }
            } else {
                localResults
                .closeBorrowAmount_TargetUnderwaterAsset = requestedAmountClose;
            }
        }


        if (
            localResults.closeBorrowAmount_TargetUnderwaterAsset >
            localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset
        ) {
            return
                fail(
                    Error.INVALID_CLOSE_AMOUNT_REQUESTED,
                    FailureInfo.LIQUIDATE_CLOSE_AMOUNT_TOO_HIGH
                );
        }

        (
            err,
            localResults.seizeSupplyAmount_TargetCollateralAsset
        ) = calculateAmountSeize(
            localResults.underwaterAssetPrice,
            localResults.collateralPrice,
            localResults.closeBorrowAmount_TargetUnderwaterAsset
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.LIQUIDATE_AMOUNT_SEIZE_CALCULATION_FAILED
                );
        }

        if (assetBorrow != wethAddress) {
            err = checkTransferIn(
                assetBorrow,
                localResults.liquidator,
                localResults.closeBorrowAmount_TargetUnderwaterAsset
            );
            if (err != Error.NO_ERROR) {
                return
                    fail(err, FailureInfo.LIQUIDATE_TRANSFER_IN_NOT_POSSIBLE);
            }
        }


        (err, localResults.updatedBorrowBalance_TargetUnderwaterAsset) = sub(
            localResults.currentBorrowBalance_TargetUnderwaterAsset,
            localResults.closeBorrowAmount_TargetUnderwaterAsset
        );
        revertIfError(err);

        (
            err,
            localResults.newTotalBorrows_ProtocolUnderwaterAsset
        ) = addThenSub(
            borrowMarket.totalBorrows,
            localResults.updatedBorrowBalance_TargetUnderwaterAsset,
            borrowBalance_TargeUnderwaterAsset.principal
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_TOTAL_BORROW_CALCULATION_FAILED_BORROWED_ASSET
                );
        }

        localResults.currentCash_ProtocolUnderwaterAsset = getCash(assetBorrow);
        (err, localResults.updatedCash_ProtocolUnderwaterAsset) = add(
            localResults.currentCash_ProtocolUnderwaterAsset,
            localResults.closeBorrowAmount_TargetUnderwaterAsset
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_TOTAL_CASH_CALCULATION_FAILED_BORROWED_ASSET
                );
        }


        (
            err,
            localResults.newSupplyIndex_UnderwaterAsset
        ) = calculateInterestIndex(
            borrowMarket.supplyIndex,
            borrowMarket.supplyRateMantissa,
            borrowMarket.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_BORROWED_ASSET
                );
        }

        (
            rateCalculationResultCode,
            localResults.newSupplyRateMantissa_ProtocolUnderwaterAsset
        ) = borrowMarket.interestRateModel.getSupplyRate(
            assetBorrow,
            localResults.updatedCash_ProtocolUnderwaterAsset,
            localResults.newTotalBorrows_ProtocolUnderwaterAsset
        );
        if (rateCalculationResultCode != 0) {
            return
                failOpaque(
                    FailureInfo
                        .LIQUIDATE_NEW_SUPPLY_RATE_CALCULATION_FAILED_BORROWED_ASSET,
                    rateCalculationResultCode
                );
        }

        (
            rateCalculationResultCode,
            localResults.newBorrowRateMantissa_ProtocolUnderwaterAsset
        ) = borrowMarket.interestRateModel.getBorrowRate(
            assetBorrow,
            localResults.updatedCash_ProtocolUnderwaterAsset,
            localResults.newTotalBorrows_ProtocolUnderwaterAsset
        );
        if (rateCalculationResultCode != 0) {
            return
                failOpaque(
                    FailureInfo
                        .LIQUIDATE_NEW_BORROW_RATE_CALCULATION_FAILED_BORROWED_ASSET,
                    rateCalculationResultCode
                );
        }

        (
            err,
            localResults.newBorrowIndex_CollateralAsset
        ) = calculateInterestIndex(
            collateralMarket.borrowIndex,
            collateralMarket.borrowRateMantissa,
            collateralMarket.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET
                );
        }

        (err, localResults.updatedSupplyBalance_TargetCollateralAsset) = sub(
            localResults.currentSupplyBalance_TargetCollateralAsset,
            localResults.seizeSupplyAmount_TargetCollateralAsset
        );
        revertIfError(err);

        (
            err,
            localResults.updatedSupplyBalance_LiquidatorCollateralAsset
        ) = add(
            localResults.currentSupplyBalance_LiquidatorCollateralAsset,
            localResults.seizeSupplyAmount_TargetCollateralAsset
        );
        revertIfError(err);

        borrowMarket.blockNumber = block.number;
        borrowMarket.totalBorrows = localResults
        .newTotalBorrows_ProtocolUnderwaterAsset;
        borrowMarket.supplyRateMantissa = localResults
        .newSupplyRateMantissa_ProtocolUnderwaterAsset;
        borrowMarket.supplyIndex = localResults.newSupplyIndex_UnderwaterAsset;
        borrowMarket.borrowRateMantissa = localResults
        .newBorrowRateMantissa_ProtocolUnderwaterAsset;
        borrowMarket.borrowIndex = localResults.newBorrowIndex_UnderwaterAsset;

        collateralMarket.blockNumber = block.number;
        collateralMarket.totalSupply = localResults
        .newTotalSupply_ProtocolCollateralAsset;
        collateralMarket.supplyIndex = localResults
        .newSupplyIndex_CollateralAsset;
        collateralMarket.borrowIndex = localResults
        .newBorrowIndex_CollateralAsset;


        localResults
        .startingBorrowBalance_TargetUnderwaterAsset = borrowBalance_TargeUnderwaterAsset
        .principal; // save for use in event
        borrowBalance_TargeUnderwaterAsset.principal = localResults
        .updatedBorrowBalance_TargetUnderwaterAsset;
        borrowBalance_TargeUnderwaterAsset.interestIndex = localResults
        .newBorrowIndex_UnderwaterAsset;

        localResults
        .startingSupplyBalance_TargetCollateralAsset = supplyBalance_TargetCollateralAsset
        .principal; // save for use in event
        supplyBalance_TargetCollateralAsset.principal = localResults
        .updatedSupplyBalance_TargetCollateralAsset;
        supplyBalance_TargetCollateralAsset.interestIndex = localResults
        .newSupplyIndex_CollateralAsset;

        localResults
        .startingSupplyBalance_LiquidatorCollateralAsset = supplyBalance_LiquidatorCollateralAsset
        .principal; // save for use in event
        supplyBalance_LiquidatorCollateralAsset.principal = localResults
        .updatedSupplyBalance_LiquidatorCollateralAsset;
        supplyBalance_LiquidatorCollateralAsset.interestIndex = localResults
        .newSupplyIndex_CollateralAsset;

        if (assetBorrow != wethAddress) {
            revertEtherToUser(msg.sender, msg.value);
            err = doTransferIn(
                assetBorrow,
                localResults.liquidator,
                localResults.closeBorrowAmount_TargetUnderwaterAsset
            );
            if (err != Error.NO_ERROR) {
                return fail(err, FailureInfo.LIQUIDATE_TRANSFER_IN_FAILED);
            }
        } else {
            if (msg.value == requestedAmountClose) {
                uint256 supplyError = supplyEther(
                    localResults.closeBorrowAmount_TargetUnderwaterAsset
                );
                if (localResults.reimburseAmount > 0) {
                    revertEtherToUser(
                        localResults.liquidator,
                        localResults.reimburseAmount
                    );
                }
                if (supplyError != 0) {
                    revertEtherToUser(msg.sender, msg.value);
                    return
                        fail(
                            Error.WETH_ADDRESS_NOT_SET_ERROR,
                            FailureInfo.WETH_ADDRESS_NOT_SET_ERROR
                        );
                }
            } else {
                revertEtherToUser(msg.sender, msg.value);
                return
                    fail(
                        Error.ETHER_AMOUNT_MISMATCH_ERROR,
                        FailureInfo.ETHER_AMOUNT_MISMATCH_ERROR
                    );
            }
        }

        supplyOriginationFeeAsAdmin(
            assetBorrow,
            localResults.liquidator,
            localResults.closeBorrowAmount_TargetUnderwaterAsset,
            localResults.newSupplyIndex_UnderwaterAsset
        );

        emit BorrowLiquidated(
            localResults.targetAccount,
            localResults.assetBorrow,
            localResults.currentBorrowBalance_TargetUnderwaterAsset,
            localResults.closeBorrowAmount_TargetUnderwaterAsset,
            localResults.liquidator,
            localResults.assetCollateral,
            localResults.seizeSupplyAmount_TargetCollateralAsset
        );

        return uint256(Error.NO_ERROR); // success
    }

    function calculateDiscountedRepayToEvenAmount(
        address targetAccount,
        Exp memory underwaterAssetPrice,
        address assetBorrow
    ) internal view returns (Error, uint256) {

        Error err;
        Exp memory _accountLiquidity; // unused return value from calculateAccountLiquidity
        Exp memory accountShortfall_TargetUser;
        Exp memory collateralRatioMinusLiquidationDiscount; // collateralRatio - liquidationDiscount
        Exp memory discountedCollateralRatioMinusOne; // collateralRatioMinusLiquidationDiscount - 1, aka collateralRatio - liquidationDiscount - 1
        Exp memory discountedPrice_UnderwaterAsset;
        Exp memory rawResult;

        (
            err,
            _accountLiquidity,
            accountShortfall_TargetUser
        ) = calculateAccountLiquidity(targetAccount);
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, collateralRatioMinusLiquidationDiscount) = subExp(
            collateralRatio,
            liquidationDiscount
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, discountedCollateralRatioMinusOne) = subExp(
            collateralRatioMinusLiquidationDiscount,
            Exp({mantissa: mantissaOne})
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, discountedPrice_UnderwaterAsset) = mulExp(
            underwaterAssetPrice,
            discountedCollateralRatioMinusOne
        );
        revertIfError(err);

        uint256 borrowBalance = getBorrowBalance(targetAccount, assetBorrow);
        Exp memory maxClose;
        (err, maxClose) = mulScalar(
            Exp({mantissa: closeFactorMantissa}),
            borrowBalance
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, rawResult) = divExp(maxClose, discountedPrice_UnderwaterAsset);
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        return (Error.NO_ERROR, truncate(rawResult));
    }

    function calculateDiscountedBorrowDenominatedCollateral(
        Exp memory underwaterAssetPrice,
        Exp memory collateralPrice,
        uint256 supplyCurrent_TargetCollateralAsset
    ) internal view returns (Error, uint256) {

        Error err;
        Exp memory onePlusLiquidationDiscount; // (1 + liquidationDiscount)
        Exp memory supplyCurrentTimesOracleCollateral; // supplyCurrent * Oracle price for the collateral
        Exp memory onePlusLiquidationDiscountTimesOracleBorrow; // (1 + liquidationDiscount) * Oracle price for the borrow
        Exp memory rawResult;

        (err, onePlusLiquidationDiscount) = addExp(
            Exp({mantissa: mantissaOne}),
            liquidationDiscount
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, supplyCurrentTimesOracleCollateral) = mulScalar(
            collateralPrice,
            supplyCurrent_TargetCollateralAsset
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, onePlusLiquidationDiscountTimesOracleBorrow) = mulExp(
            onePlusLiquidationDiscount,
            underwaterAssetPrice
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, rawResult) = divExp(
            supplyCurrentTimesOracleCollateral,
            onePlusLiquidationDiscountTimesOracleBorrow
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        return (Error.NO_ERROR, truncate(rawResult));
    }

    function calculateAmountSeize(
        Exp memory underwaterAssetPrice,
        Exp memory collateralPrice,
        uint256 closeBorrowAmount_TargetUnderwaterAsset
    ) internal view returns (Error, uint256) {


        Error err;

        Exp memory liquidationMultiplier;

        Exp memory priceUnderwaterAssetTimesLiquidationMultiplier;

        Exp memory finalNumerator;

        Exp memory rawResult;

        (err, liquidationMultiplier) = addExp(
            Exp({mantissa: mantissaOne}),
            liquidationDiscount
        );
        revertIfError(err);

        (err, priceUnderwaterAssetTimesLiquidationMultiplier) = mulExp(
            underwaterAssetPrice,
            liquidationMultiplier
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, finalNumerator) = mulScalar(
            priceUnderwaterAssetTimesLiquidationMultiplier,
            closeBorrowAmount_TargetUnderwaterAsset
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, rawResult) = divExp(finalNumerator, collateralPrice);
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        return (Error.NO_ERROR, truncate(rawResult));
    }

    function borrow(address asset, uint256 amount)
        public
        nonReentrant
        onlyCustomerWithKYC
        returns (uint256)
    {

        if (paused) {
            return
                fail(Error.CONTRACT_PAUSED, FailureInfo.BORROW_CONTRACT_PAUSED);
        }

        refreshAlkIndex(asset, msg.sender, false, true);
        BorrowLocalVars memory localResults;
        Market storage market = markets[asset];
        Balance storage borrowBalance = borrowBalances[msg.sender][asset];

        Error err;
        uint256 rateCalculationResultCode;

        if (!market.isSupported) {
            return
                fail(
                    Error.MARKET_NOT_SUPPORTED,
                    FailureInfo.BORROW_MARKET_NOT_SUPPORTED
                );
        }

        (err, localResults.newBorrowIndex) = calculateInterestIndex(
            market.borrowIndex,
            market.borrowRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED
                );
        }

        (err, localResults.userBorrowCurrent) = calculateBalance(
            borrowBalance.principal,
            borrowBalance.interestIndex,
            localResults.newBorrowIndex
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED
                );
        }

        (err, localResults.borrowAmountWithFee) = calculateBorrowAmountWithFee(
            amount
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_ORIGINATION_FEE_CALCULATION_FAILED
                );
        }
        uint256 orgFeeBalance = localResults.borrowAmountWithFee - amount;

        (err, localResults.userBorrowUpdated) = add(
            localResults.userBorrowCurrent,
            localResults.borrowAmountWithFee
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED
                );
        }

        (err, localResults.newTotalBorrows) = addThenSub(
            market.totalBorrows,
            localResults.userBorrowUpdated,
            borrowBalance.principal
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED
                );
        }

        (
            err,
            localResults.accountLiquidity,
            localResults.accountShortfall
        ) = calculateAccountLiquidity(msg.sender);
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED
                );
        }

        if (!isZeroExp(localResults.accountShortfall)) {
            return
                fail(
                    Error.INSUFFICIENT_LIQUIDITY,
                    FailureInfo.BORROW_ACCOUNT_SHORTFALL_PRESENT
                );
        }

        (
            err,
            localResults.ethValueOfBorrowAmountWithFee
        ) = getPriceForAssetAmount(
            asset,
            localResults.borrowAmountWithFee,
            true
        );
        if (err != Error.NO_ERROR) {
            return
                fail(err, FailureInfo.BORROW_AMOUNT_VALUE_CALCULATION_FAILED);
        }
        if (
            lessThanExp(
                localResults.accountLiquidity,
                localResults.ethValueOfBorrowAmountWithFee
            )
        ) {
            return
                fail(
                    Error.INSUFFICIENT_LIQUIDITY,
                    FailureInfo.BORROW_AMOUNT_LIQUIDITY_SHORTFALL
                );
        }

        localResults.currentCash = getCash(asset);
        (err, localResults.updatedCash) = sub(localResults.currentCash, amount);
        if (err != Error.NO_ERROR) {
            return
                fail(
                    Error.TOKEN_INSUFFICIENT_CASH,
                    FailureInfo.BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED
                );
        }


        (err, localResults.newSupplyIndex) = calculateInterestIndex(
            market.supplyIndex,
            market.supplyRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED
                );
        }

        (rateCalculationResultCode, localResults.newSupplyRateMantissa) = market
        .interestRateModel
        .getSupplyRate(
            asset,
            localResults.updatedCash,
            localResults.newTotalBorrows
        );
        if (rateCalculationResultCode != 0) {
            return
                failOpaque(
                    FailureInfo.BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }

        (rateCalculationResultCode, localResults.newBorrowRateMantissa) = market
        .interestRateModel
        .getBorrowRate(
            asset,
            localResults.updatedCash,
            localResults.newTotalBorrows
        );
        if (rateCalculationResultCode != 0) {
            return
                failOpaque(
                    FailureInfo.BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }

        market.blockNumber = block.number;
        market.totalBorrows = localResults.newTotalBorrows;
        market.supplyRateMantissa = localResults.newSupplyRateMantissa;
        market.supplyIndex = localResults.newSupplyIndex;
        market.borrowRateMantissa = localResults.newBorrowRateMantissa;
        market.borrowIndex = localResults.newBorrowIndex;

        localResults.startingBalance = borrowBalance.principal; // save for use in `BorrowTaken` event
        borrowBalance.principal = localResults.userBorrowUpdated;
        borrowBalance.interestIndex = localResults.newBorrowIndex;

        originationFeeBalance[msg.sender][asset] += orgFeeBalance;

        if (asset != wethAddress) {
            err = doTransferOut(asset, msg.sender, amount);
            if (err != Error.NO_ERROR) {
                return fail(err, FailureInfo.BORROW_TRANSFER_OUT_FAILED);
            }
        } else {
            withdrawEther(msg.sender, amount); // send Ether to user
        }

        emit BorrowTaken(
            msg.sender,
            asset,
            amount,
            localResults.startingBalance,
            localResults.borrowAmountWithFee,
            borrowBalance.principal
        );

        return uint256(Error.NO_ERROR); // success
    }

    function supplyOriginationFeeAsAdmin(
        address asset,
        address user,
        uint256 amount,
        uint256 newSupplyIndex
    ) private {

        refreshAlkIndex(asset, admin, true, true);
        uint256 originationFeeRepaid = 0;
        if (originationFeeBalance[user][asset] != 0) {
            if (amount < originationFeeBalance[user][asset]) {
                originationFeeRepaid = amount;
            } else {
                originationFeeRepaid = originationFeeBalance[user][asset];
            }
            Balance storage balance = supplyBalances[admin][asset];

            SupplyLocalVars memory localResults; // Holds all our uint calculation results
            Error err; // Re-used for every function call that includes an Error in its return value(s).

            originationFeeBalance[user][asset] -= originationFeeRepaid;

            (err, localResults.userSupplyCurrent) = calculateBalance(
                balance.principal,
                balance.interestIndex,
                newSupplyIndex
            );
            revertIfError(err);

            (err, localResults.userSupplyUpdated) = add(
                localResults.userSupplyCurrent,
                originationFeeRepaid
            );
            revertIfError(err);

            (err, localResults.newTotalSupply) = addThenSub(
                markets[asset].totalSupply,
                localResults.userSupplyUpdated,
                balance.principal
            );
            revertIfError(err);

            markets[asset].totalSupply = localResults.newTotalSupply;

            localResults.startingBalance = balance.principal;
            balance.principal = localResults.userSupplyUpdated;
            balance.interestIndex = newSupplyIndex;

            emit SupplyReceived(
                admin,
                asset,
                originationFeeRepaid,
                localResults.startingBalance,
                localResults.userSupplyUpdated
            );
        }
    }

    function refreshAlkIndex(
        address market,
        address user,
        bool isSupply,
        bool isVerified
    ) internal {

        if (address(rewardControl) == address(0)) {
            return;
        }
        if (isSupply) {
            rewardControl.refreshAlkSupplyIndex(market, user, isVerified);
        } else {
            rewardControl.refreshAlkBorrowIndex(market, user, isVerified);
        }
    }

    function getMarketBalances(address asset)
        public
        view
        returns (uint256, uint256)
    {

        Error err;
        uint256 newSupplyIndex;
        uint256 marketSupplyCurrent;
        uint256 newBorrowIndex;
        uint256 marketBorrowCurrent;

        Market storage market = markets[asset];

        (err, newSupplyIndex) = calculateInterestIndex(
            market.supplyIndex,
            market.supplyRateMantissa,
            market.blockNumber,
            block.number
        );
        revertIfError(err);

        (err, marketSupplyCurrent) = calculateBalance(
            market.totalSupply,
            market.supplyIndex,
            newSupplyIndex
        );
        revertIfError(err);

        (err, newBorrowIndex) = calculateInterestIndex(
            market.borrowIndex,
            market.borrowRateMantissa,
            market.blockNumber,
            block.number
        );
        revertIfError(err);

        (err, marketBorrowCurrent) = calculateBalance(
            market.totalBorrows,
            market.borrowIndex,
            newBorrowIndex
        );
        revertIfError(err);

        return (marketSupplyCurrent, marketBorrowCurrent);
    }

    function revertIfError(Error err) internal pure {

        require(
            err == Error.NO_ERROR,
            "Function revert due to internal exception"
        );
    }
}


pragma solidity 0.4.24;







contract AlkemiEarnPublic is Exponential, SafeToken {

    uint256 internal initialInterestIndex;
    uint256 internal defaultOriginationFee;
    uint256 internal defaultCollateralRatio;
    uint256 internal defaultLiquidationDiscount;
    uint256 public minimumCollateralRatioMantissa;
    uint256 public maximumLiquidationDiscountMantissa;
    bool private initializationDone; // To make sure initializer is called only once

    function initializer() public {

        if (initializationDone == false) {
            initializationDone = true;
            admin = msg.sender;
            initialInterestIndex = 10**18;
            defaultOriginationFee = (10**15); // default is 0.1%
            defaultCollateralRatio = 125 * (10**16); // default is 125% or 1.25
            defaultLiquidationDiscount = (10**17); // default is 10% or 0.1
            minimumCollateralRatioMantissa = 11 * (10**17); // 1.1
            maximumLiquidationDiscountMantissa = (10**17); // 0.1
            collateralRatio = Exp({mantissa: defaultCollateralRatio});
            originationFee = Exp({mantissa: defaultOriginationFee});
            liquidationDiscount = Exp({mantissa: defaultLiquidationDiscount});
            _guardCounter = 1;
        }
    }

    function() public payable {
        revert();
    }

    address public pendingAdmin;

    address public admin;

    mapping(address => bool) public managers;

    address private oracle;

    ChainLink public priceOracle;

    struct Balance {
        uint256 principal;
        uint256 interestIndex;
    }

    mapping(address => mapping(address => Balance)) public supplyBalances;

    mapping(address => mapping(address => Balance)) public borrowBalances;

    struct Market {
        bool isSupported;
        uint256 blockNumber;
        InterestRateModel interestRateModel;
        uint256 totalSupply;
        uint256 supplyRateMantissa;
        uint256 supplyIndex;
        uint256 totalBorrows;
        uint256 borrowRateMantissa;
        uint256 borrowIndex;
    }

    address private wethAddress;

    AlkemiWETH public WETHContract;

    mapping(address => Market) public markets;

    address[] public collateralMarkets;

    Exp public collateralRatio;

    Exp public originationFee;

    Exp public liquidationDiscount;

    bool public paused;

    struct SupplyLocalVars {
        uint256 startingBalance;
        uint256 newSupplyIndex;
        uint256 userSupplyCurrent;
        uint256 userSupplyUpdated;
        uint256 newTotalSupply;
        uint256 currentCash;
        uint256 updatedCash;
        uint256 newSupplyRateMantissa;
        uint256 newBorrowIndex;
        uint256 newBorrowRateMantissa;
    }


    struct WithdrawLocalVars {
        uint256 withdrawAmount;
        uint256 startingBalance;
        uint256 newSupplyIndex;
        uint256 userSupplyCurrent;
        uint256 userSupplyUpdated;
        uint256 newTotalSupply;
        uint256 currentCash;
        uint256 updatedCash;
        uint256 newSupplyRateMantissa;
        uint256 newBorrowIndex;
        uint256 newBorrowRateMantissa;
        uint256 withdrawCapacity;
        Exp accountLiquidity;
        Exp accountShortfall;
        Exp ethValueOfWithdrawal;
    }

    struct AccountValueLocalVars {
        address assetAddress;
        uint256 collateralMarketsLength;
        uint256 newSupplyIndex;
        uint256 userSupplyCurrent;
        uint256 newBorrowIndex;
        uint256 userBorrowCurrent;
        Exp supplyTotalValue;
        Exp sumSupplies;
        Exp borrowTotalValue;
        Exp sumBorrows;
    }

    struct PayBorrowLocalVars {
        uint256 newBorrowIndex;
        uint256 userBorrowCurrent;
        uint256 repayAmount;
        uint256 userBorrowUpdated;
        uint256 newTotalBorrows;
        uint256 currentCash;
        uint256 updatedCash;
        uint256 newSupplyIndex;
        uint256 newSupplyRateMantissa;
        uint256 newBorrowRateMantissa;
        uint256 startingBalance;
    }

    struct BorrowLocalVars {
        uint256 newBorrowIndex;
        uint256 userBorrowCurrent;
        uint256 borrowAmountWithFee;
        uint256 userBorrowUpdated;
        uint256 newTotalBorrows;
        uint256 currentCash;
        uint256 updatedCash;
        uint256 newSupplyIndex;
        uint256 newSupplyRateMantissa;
        uint256 newBorrowRateMantissa;
        uint256 startingBalance;
        Exp accountLiquidity;
        Exp accountShortfall;
        Exp ethValueOfBorrowAmountWithFee;
    }

    struct LiquidateLocalVars {
        address targetAccount;
        address assetBorrow;
        address liquidator;
        address assetCollateral;
        uint256 newBorrowIndex_UnderwaterAsset;
        uint256 newSupplyIndex_UnderwaterAsset;
        uint256 newBorrowIndex_CollateralAsset;
        uint256 newSupplyIndex_CollateralAsset;
        uint256 currentBorrowBalance_TargetUnderwaterAsset;
        uint256 updatedBorrowBalance_TargetUnderwaterAsset;
        uint256 newTotalBorrows_ProtocolUnderwaterAsset;
        uint256 startingBorrowBalance_TargetUnderwaterAsset;
        uint256 startingSupplyBalance_TargetCollateralAsset;
        uint256 startingSupplyBalance_LiquidatorCollateralAsset;
        uint256 currentSupplyBalance_TargetCollateralAsset;
        uint256 updatedSupplyBalance_TargetCollateralAsset;
        uint256 currentSupplyBalance_LiquidatorCollateralAsset;
        uint256 updatedSupplyBalance_LiquidatorCollateralAsset;
        uint256 newTotalSupply_ProtocolCollateralAsset;
        uint256 currentCash_ProtocolUnderwaterAsset;
        uint256 updatedCash_ProtocolUnderwaterAsset;

        uint256 newSupplyRateMantissa_ProtocolUnderwaterAsset;
        uint256 newBorrowRateMantissa_ProtocolUnderwaterAsset;

        uint256 discountedRepayToEvenAmount;
        uint256 discountedBorrowDenominatedCollateral;
        uint256 maxCloseableBorrowAmount_TargetUnderwaterAsset;
        uint256 closeBorrowAmount_TargetUnderwaterAsset;
        uint256 seizeSupplyAmount_TargetCollateralAsset;
        uint256 reimburseAmount;
        Exp collateralPrice;
        Exp underwaterAssetPrice;
    }

    mapping(address => mapping(address => uint256))
        public originationFeeBalance;

    RewardControlInterface public rewardControl;

    uint256 public closeFactorMantissa;

    uint256 public _guardCounter;

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }

    event SupplyReceived(
        address indexed account,
        address indexed asset,
        uint256 amount,
        uint256 startingBalance,
        uint256 newBalance
    );

    event SupplyOrgFeeAsAdmin(
        address indexed account,
        address indexed asset,
        uint256 amount,
        uint256 startingBalance,
        uint256 newBalance
    );
    event SupplyWithdrawn(
        address indexed account,
        address indexed asset,
        uint256 amount,
        uint256 startingBalance,
        uint256 newBalance
    );

    event BorrowTaken(
        address indexed account,
        address indexed asset,
        uint256 amount,
        uint256 startingBalance,
        uint256 borrowAmountWithFee,
        uint256 newBalance
    );

    event BorrowRepaid(
        address indexed account,
        address indexed asset,
        uint256 amount,
        uint256 startingBalance,
        uint256 newBalance
    );

    event BorrowLiquidated(
        address indexed targetAccount,
        address assetBorrow,
        uint256 borrowBalanceAccumulated,
        uint256 amountRepaid,
        address indexed liquidator,
        address assetCollateral,
        uint256 amountSeized
    );

    event NewAdmin(address indexed oldAdmin, address indexed newAdmin);

    event SupportedMarket(
        address indexed asset,
        address indexed interestRateModel
    );

    event NewRiskParameters(
        uint256 oldCollateralRatioMantissa,
        uint256 newCollateralRatioMantissa,
        uint256 oldLiquidationDiscountMantissa,
        uint256 newLiquidationDiscountMantissa
    );

    event NewOriginationFee(
        uint256 oldOriginationFeeMantissa,
        uint256 newOriginationFeeMantissa
    );

    event SetMarketInterestRateModel(
        address indexed asset,
        address indexed interestRateModel
    );

    event EquityWithdrawn(
        address indexed asset,
        uint256 equityAvailableBefore,
        uint256 amount,
        address indexed owner
    );

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a < b) {
            return a;
        } else {
            return b;
        }
    }

    function addCollateralMarket(address asset) internal {

        for (uint256 i = 0; i < collateralMarkets.length; i++) {
            if (collateralMarkets[i] == asset) {
                return;
            }
        }

        collateralMarkets.push(asset);
    }

    function getCollateralMarketsLength() public view returns (uint256) {

        return collateralMarkets.length;
    }

    function calculateInterestIndex(
        uint256 startingInterestIndex,
        uint256 interestRateMantissa,
        uint256 blockStart,
        uint256 blockEnd
    ) internal pure returns (Error, uint256) {

        (Error err0, uint256 blockDelta) = sub(blockEnd, blockStart);
        if (err0 != Error.NO_ERROR) {
            return (err0, 0);
        }

        (Error err1, Exp memory blocksTimesRate) = mulScalar(
            Exp({mantissa: interestRateMantissa}),
            blockDelta
        );
        if (err1 != Error.NO_ERROR) {
            return (err1, 0);
        }

        (Error err2, Exp memory onePlusBlocksTimesRate) = addExp(
            blocksTimesRate,
            Exp({mantissa: mantissaOne})
        );
        if (err2 != Error.NO_ERROR) {
            return (err2, 0);
        }

        (Error err3, Exp memory newInterestIndexExp) = mulScalar(
            onePlusBlocksTimesRate,
            startingInterestIndex
        );
        if (err3 != Error.NO_ERROR) {
            return (err3, 0);
        }

        return (Error.NO_ERROR, truncate(newInterestIndexExp));
    }

    function calculateBalance(
        uint256 startingBalance,
        uint256 interestIndexStart,
        uint256 interestIndexEnd
    ) internal pure returns (Error, uint256) {

        if (startingBalance == 0) {
            return (Error.NO_ERROR, 0);
        }
        (Error err0, uint256 balanceTimesIndex) = mul(
            startingBalance,
            interestIndexEnd
        );
        if (err0 != Error.NO_ERROR) {
            return (err0, 0);
        }

        return div(balanceTimesIndex, interestIndexStart);
    }

    function getPriceForAssetAmount(address asset, uint256 assetAmount)
        internal
        view
        returns (Error, Exp memory)
    {

        (Error err, Exp memory assetPrice) = fetchAssetPrice(asset);
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}));
        }

        if (isZeroExp(assetPrice)) {
            return (Error.MISSING_ASSET_PRICE, Exp({mantissa: 0}));
        }

        return mulScalar(assetPrice, assetAmount); // assetAmountWei * oraclePrice = assetValueInEth
    }

    function getPriceForAssetAmountMulCollatRatio(
        address asset,
        uint256 assetAmount
    ) internal view returns (Error, Exp memory) {

        Error err;
        Exp memory assetPrice;
        Exp memory scaledPrice;
        (err, assetPrice) = fetchAssetPrice(asset);
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}));
        }

        if (isZeroExp(assetPrice)) {
            return (Error.MISSING_ASSET_PRICE, Exp({mantissa: 0}));
        }

        (err, scaledPrice) = mulExp(collateralRatio, assetPrice);
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}));
        }

        return mulScalar(scaledPrice, assetAmount);
    }

    function calculateBorrowAmountWithFee(uint256 borrowAmount)
        internal
        view
        returns (Error, uint256)
    {

        if (isZeroExp(originationFee)) {
            return (Error.NO_ERROR, borrowAmount);
        }

        (Error err0, Exp memory originationFeeFactor) = addExp(
            originationFee,
            Exp({mantissa: mantissaOne})
        );
        if (err0 != Error.NO_ERROR) {
            return (err0, 0);
        }

        (Error err1, Exp memory borrowAmountWithFee) = mulScalar(
            originationFeeFactor,
            borrowAmount
        );
        if (err1 != Error.NO_ERROR) {
            return (err1, 0);
        }

        return (Error.NO_ERROR, truncate(borrowAmountWithFee));
    }

    function fetchAssetPrice(address asset)
        internal
        view
        returns (Error, Exp memory)
    {

        if (priceOracle == address(0)) {
            return (Error.ZERO_ORACLE_ADDRESS, Exp({mantissa: 0}));
        }
        if (priceOracle.paused()) {
            return (Error.MISSING_ASSET_PRICE, Exp({mantissa: 0}));
        }
        (uint256 priceMantissa, uint8 assetDecimals) = priceOracle
        .getAssetPrice(asset);
        (Error err, uint256 magnification) = sub(18, uint256(assetDecimals));
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}));
        }
        (err, priceMantissa) = mul(priceMantissa, 10**magnification);
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}));
        }

        return (Error.NO_ERROR, Exp({mantissa: priceMantissa}));
    }

    function assetPrices(address asset) public view returns (uint256) {

        (Error err, Exp memory result) = fetchAssetPrice(asset);
        if (err != Error.NO_ERROR) {
            return 0;
        }
        return result.mantissa;
    }

    function getAssetAmountForValue(address asset, Exp ethValue)
        internal
        view
        returns (Error, uint256)
    {

        Error err;
        Exp memory assetPrice;
        Exp memory assetAmount;

        (err, assetPrice) = fetchAssetPrice(asset);
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, assetAmount) = divExp(ethValue, assetPrice);
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        return (Error.NO_ERROR, truncate(assetAmount));
    }

    function _adminFunctions(
        address newPendingAdmin,
        address newOracle,
        bool requestedState,
        uint256 originationFeeMantissa,
        uint256 newCloseFactorMantissa
    ) public returns (uint256) {

        require(msg.sender == admin, "SET_PENDING_ADMIN_OWNER_CHECK");
        require(newOracle != address(0), "Cannot set weth address to 0x00");
        require(
            originationFeeMantissa < 10**18 && newCloseFactorMantissa < 10**18,
            "Invalid Origination Fee or Close Factor Mantissa"
        );

        pendingAdmin = newPendingAdmin;


        priceOracle = ChainLink(newOracle);

        paused = requestedState;

        Exp memory oldOriginationFee = originationFee;

        originationFee = Exp({mantissa: originationFeeMantissa});
        emit NewOriginationFee(
            oldOriginationFee.mantissa,
            originationFeeMantissa
        );

        closeFactorMantissa = newCloseFactorMantissa;

        return uint256(Error.NO_ERROR);
    }

    function _acceptAdmin() public returns (uint256) {

        require(msg.sender == pendingAdmin, "ACCEPT_ADMIN_PENDING_ADMIN_CHECK");

        address oldAdmin = admin;
        admin = pendingAdmin;
        pendingAdmin = 0;

        emit NewAdmin(oldAdmin, msg.sender);

        return uint256(Error.NO_ERROR);
    }

    function getAccountLiquidity(address account) public view returns (int256) {

        (
            Error err,
            Exp memory accountLiquidity,
            Exp memory accountShortfall
        ) = calculateAccountLiquidity(account);
        revertIfError(err);

        if (isZeroExp(accountLiquidity)) {
            return -1 * int256(truncate(accountShortfall));
        } else {
            return int256(truncate(accountLiquidity));
        }
    }

    function getSupplyBalance(address account, address asset)
        public
        view
        returns (uint256)
    {

        Error err;
        uint256 newSupplyIndex;
        uint256 userSupplyCurrent;

        Market storage market = markets[asset];
        Balance storage supplyBalance = supplyBalances[account][asset];

        (err, newSupplyIndex) = calculateInterestIndex(
            market.supplyIndex,
            market.supplyRateMantissa,
            market.blockNumber,
            block.number
        );
        revertIfError(err);

        (err, userSupplyCurrent) = calculateBalance(
            supplyBalance.principal,
            supplyBalance.interestIndex,
            newSupplyIndex
        );
        revertIfError(err);

        return userSupplyCurrent;
    }

    function getBorrowBalance(address account, address asset)
        public
        view
        returns (uint256)
    {

        Error err;
        uint256 newBorrowIndex;
        uint256 userBorrowCurrent;

        Market storage market = markets[asset];
        Balance storage borrowBalance = borrowBalances[account][asset];

        (err, newBorrowIndex) = calculateInterestIndex(
            market.borrowIndex,
            market.borrowRateMantissa,
            market.blockNumber,
            block.number
        );
        revertIfError(err);

        (err, userBorrowCurrent) = calculateBalance(
            borrowBalance.principal,
            borrowBalance.interestIndex,
            newBorrowIndex
        );
        revertIfError(err);

        return userBorrowCurrent;
    }

    function _supportMarket(address asset, InterestRateModel interestRateModel)
        public
        returns (uint256)
    {

        require(msg.sender == admin, "SUPPORT_MARKET_OWNER_CHECK");
        require(interestRateModel != address(0), "Rate Model cannot be 0x00");
        require(
            collateralMarkets.length < 16, // 16 = MAXIMUM_NUMBER_OF_MARKETS_ALLOWED
            "Exceeding the max number of markets allowed"
        );

        (Error err, Exp memory assetPrice) = fetchAssetPrice(asset);
        if (err != Error.NO_ERROR) {
            return fail(err, FailureInfo.SUPPORT_MARKET_FETCH_PRICE_FAILED);
        }

        if (isZeroExp(assetPrice)) {
            return
                fail(
                    Error.ASSET_NOT_PRICED,
                    FailureInfo.SUPPORT_MARKET_PRICE_CHECK
                );
        }

        markets[asset].interestRateModel = interestRateModel;

        addCollateralMarket(asset);

        markets[asset].isSupported = true;

        if (markets[asset].supplyIndex == 0) {
            markets[asset].supplyIndex = initialInterestIndex;
        }

        if (markets[asset].borrowIndex == 0) {
            markets[asset].borrowIndex = initialInterestIndex;
        }

        emit SupportedMarket(asset, interestRateModel);

        return uint256(Error.NO_ERROR);
    }

    function _suspendMarket(address asset) public returns (uint256) {

        require(msg.sender == admin, "SUSPEND_MARKET_OWNER_CHECK");

        if (!markets[asset].isSupported) {
            return uint256(Error.NO_ERROR);
        }

        markets[asset].isSupported = false;

        return uint256(Error.NO_ERROR);
    }

    function _setRiskParameters(
        uint256 collateralRatioMantissa,
        uint256 liquidationDiscountMantissa
    ) public returns (uint256) {

        require(msg.sender == admin, "SET_RISK_PARAMETERS_OWNER_CHECK");
        require(
            collateralRatioMantissa >= minimumCollateralRatioMantissa &&
                liquidationDiscountMantissa <=
                maximumLiquidationDiscountMantissa,
            "Liquidation discount is more than max discount or collateral ratio is less than min ratio"
        );

        Exp memory newCollateralRatio = Exp({
            mantissa: collateralRatioMantissa
        });
        Exp memory newLiquidationDiscount = Exp({
            mantissa: liquidationDiscountMantissa
        });
        Exp memory minimumCollateralRatio = Exp({
            mantissa: minimumCollateralRatioMantissa
        });
        Exp memory maximumLiquidationDiscount = Exp({
            mantissa: maximumLiquidationDiscountMantissa
        });

        Error err;
        Exp memory newLiquidationDiscountPlusOne;

        if (lessThanExp(newCollateralRatio, minimumCollateralRatio)) {
            return
                fail(
                    Error.INVALID_COLLATERAL_RATIO,
                    FailureInfo.SET_RISK_PARAMETERS_VALIDATION
                );
        }

        if (lessThanExp(maximumLiquidationDiscount, newLiquidationDiscount)) {
            return
                fail(
                    Error.INVALID_LIQUIDATION_DISCOUNT,
                    FailureInfo.SET_RISK_PARAMETERS_VALIDATION
                );
        }

        (err, newLiquidationDiscountPlusOne) = addExp(
            newLiquidationDiscount,
            Exp({mantissa: mantissaOne})
        );
        assert(err == Error.NO_ERROR); // We already validated that newLiquidationDiscount does not approach overflow size

        if (
            lessThanOrEqualExp(
                newCollateralRatio,
                newLiquidationDiscountPlusOne
            )
        ) {
            return
                fail(
                    Error.INVALID_COMBINED_RISK_PARAMETERS,
                    FailureInfo.SET_RISK_PARAMETERS_VALIDATION
                );
        }

        Exp memory oldCollateralRatio = collateralRatio;
        Exp memory oldLiquidationDiscount = liquidationDiscount;

        collateralRatio = newCollateralRatio;
        liquidationDiscount = newLiquidationDiscount;

        emit NewRiskParameters(
            oldCollateralRatio.mantissa,
            collateralRatioMantissa,
            oldLiquidationDiscount.mantissa,
            liquidationDiscountMantissa
        );

        return uint256(Error.NO_ERROR);
    }

    function _setMarketInterestRateModel(
        address asset,
        InterestRateModel interestRateModel
    ) public returns (uint256) {

        require(
            msg.sender == admin,
            "SET_MARKET_INTEREST_RATE_MODEL_OWNER_CHECK"
        );
        require(interestRateModel != address(0), "Rate Model cannot be 0x00");

        markets[asset].interestRateModel = interestRateModel;

        emit SetMarketInterestRateModel(asset, interestRateModel);

        return uint256(Error.NO_ERROR);
    }

    function _withdrawEquity(address asset, uint256 amount)
        public
        returns (uint256)
    {

        require(msg.sender == admin, "EQUITY_WITHDRAWAL_MODEL_OWNER_CHECK");

        (
            uint256 supplyWithInterest,
            uint256 borrowWithInterest
        ) = getMarketBalances(asset);
        (Error err0, uint256 equity) = addThenSub(
            getCash(asset),
            borrowWithInterest,
            supplyWithInterest
        );
        if (err0 != Error.NO_ERROR) {
            return fail(err0, FailureInfo.EQUITY_WITHDRAWAL_CALCULATE_EQUITY);
        }

        if (amount > equity) {
            return
                fail(
                    Error.EQUITY_INSUFFICIENT_BALANCE,
                    FailureInfo.EQUITY_WITHDRAWAL_AMOUNT_VALIDATION
                );
        }


        if (asset != wethAddress) {
            Error err2 = doTransferOut(asset, admin, amount);
            if (err2 != Error.NO_ERROR) {
                return
                    fail(
                        err2,
                        FailureInfo.EQUITY_WITHDRAWAL_TRANSFER_OUT_FAILED
                    );
            }
        } else {
            withdrawEther(admin, amount); // send Ether to user
        }

        (, markets[asset].supplyRateMantissa) = markets[asset]
        .interestRateModel
        .getSupplyRate(
            asset,
            getCash(asset) - amount,
            markets[asset].totalSupply
        );

        (, markets[asset].borrowRateMantissa) = markets[asset]
        .interestRateModel
        .getBorrowRate(
            asset,
            getCash(asset) - amount,
            markets[asset].totalBorrows
        );
        emit EquityWithdrawn(asset, equity, amount, admin);

        return uint256(Error.NO_ERROR); // success
    }

    function setWethAddress(address wethContractAddress)
        public
        returns (uint256)
    {

        require(msg.sender == admin, "SET_WETH_ADDRESS_ADMIN_CHECK_FAILED");
        require(
            wethContractAddress != address(0),
            "Cannot set weth address to 0x00"
        );
        wethAddress = wethContractAddress;
        WETHContract = AlkemiWETH(wethAddress);
        return uint256(Error.NO_ERROR);
    }

    function supplyEther(address user, uint256 etherAmount)
        internal
        returns (uint256)
    {

        user; // To silence the warning of unused local variable
        if (wethAddress != address(0)) {
            WETHContract.deposit.value(etherAmount)();
            return uint256(Error.NO_ERROR);
        } else {
            return uint256(Error.WETH_ADDRESS_NOT_SET_ERROR);
        }
    }

    function revertEtherToUser(address user, uint256 etherAmount) internal {

        if (etherAmount > 0) {
            user.transfer(etherAmount);
        }
    }

    function supply(address asset, uint256 amount)
        public
        payable
        nonReentrant
        returns (uint256)
    {

        if (paused) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(Error.CONTRACT_PAUSED, FailureInfo.SUPPLY_CONTRACT_PAUSED);
        }

        refreshAlkSupplyIndex(asset, msg.sender, false);

        Market storage market = markets[asset];
        Balance storage balance = supplyBalances[msg.sender][asset];

        SupplyLocalVars memory localResults; // Holds all our uint calculation results
        Error err; // Re-used for every function call that includes an Error in its return value(s).
        uint256 rateCalculationResultCode; // Used for 2 interest rate calculation calls

        if (!market.isSupported) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    Error.MARKET_NOT_SUPPORTED,
                    FailureInfo.SUPPLY_MARKET_NOT_SUPPORTED
                );
        }
        if (asset != wethAddress) {
            revertEtherToUser(msg.sender, msg.value);
            err = checkTransferIn(asset, msg.sender, amount);
            if (err != Error.NO_ERROR) {
                return fail(err, FailureInfo.SUPPLY_TRANSFER_IN_NOT_POSSIBLE);
            }
        }

        (err, localResults.newSupplyIndex) = calculateInterestIndex(
            market.supplyIndex,
            market.supplyRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.SUPPLY_NEW_SUPPLY_INDEX_CALCULATION_FAILED
                );
        }

        (err, localResults.userSupplyCurrent) = calculateBalance(
            balance.principal,
            balance.interestIndex,
            localResults.newSupplyIndex
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.SUPPLY_ACCUMULATED_BALANCE_CALCULATION_FAILED
                );
        }

        (err, localResults.userSupplyUpdated) = add(
            localResults.userSupplyCurrent,
            amount
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.SUPPLY_NEW_TOTAL_BALANCE_CALCULATION_FAILED
                );
        }

        (err, localResults.newTotalSupply) = addThenSub(
            market.totalSupply,
            localResults.userSupplyUpdated,
            balance.principal
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.SUPPLY_NEW_TOTAL_SUPPLY_CALCULATION_FAILED
                );
        }

        localResults.currentCash = getCash(asset);

        (err, localResults.updatedCash) = add(localResults.currentCash, amount);
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(err, FailureInfo.SUPPLY_NEW_TOTAL_CASH_CALCULATION_FAILED);
        }

        (rateCalculationResultCode, localResults.newSupplyRateMantissa) = market
        .interestRateModel
        .getSupplyRate(asset, localResults.updatedCash, market.totalBorrows);
        if (rateCalculationResultCode != 0) {
            revertEtherToUser(msg.sender, msg.value);
            return
                failOpaque(
                    FailureInfo.SUPPLY_NEW_SUPPLY_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }

        (err, localResults.newBorrowIndex) = calculateInterestIndex(
            market.borrowIndex,
            market.borrowRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.SUPPLY_NEW_BORROW_INDEX_CALCULATION_FAILED
                );
        }

        (rateCalculationResultCode, localResults.newBorrowRateMantissa) = market
        .interestRateModel
        .getBorrowRate(asset, localResults.updatedCash, market.totalBorrows);
        if (rateCalculationResultCode != 0) {
            revertEtherToUser(msg.sender, msg.value);
            return
                failOpaque(
                    FailureInfo.SUPPLY_NEW_BORROW_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }


        market.blockNumber = block.number;
        market.totalSupply = localResults.newTotalSupply;
        market.supplyRateMantissa = localResults.newSupplyRateMantissa;
        market.supplyIndex = localResults.newSupplyIndex;
        market.borrowRateMantissa = localResults.newBorrowRateMantissa;
        market.borrowIndex = localResults.newBorrowIndex;

        localResults.startingBalance = balance.principal; // save for use in `SupplyReceived` event
        balance.principal = localResults.userSupplyUpdated;
        balance.interestIndex = localResults.newSupplyIndex;

        if (asset != wethAddress) {
            revertEtherToUser(msg.sender, msg.value);
            err = doTransferIn(asset, msg.sender, amount);
            if (err != Error.NO_ERROR) {
                return fail(err, FailureInfo.SUPPLY_TRANSFER_IN_FAILED);
            }
        } else {
            if (msg.value == amount) {
                uint256 supplyError = supplyEther(msg.sender, msg.value);
                if (supplyError != 0) {
                    revertEtherToUser(msg.sender, msg.value);
                    return
                        fail(
                            Error.WETH_ADDRESS_NOT_SET_ERROR,
                            FailureInfo.WETH_ADDRESS_NOT_SET_ERROR
                        );
                }
            } else {
                revertEtherToUser(msg.sender, msg.value);
                return
                    fail(
                        Error.ETHER_AMOUNT_MISMATCH_ERROR,
                        FailureInfo.ETHER_AMOUNT_MISMATCH_ERROR
                    );
            }
        }

        emit SupplyReceived(
            msg.sender,
            asset,
            amount,
            localResults.startingBalance,
            balance.principal
        );

        return uint256(Error.NO_ERROR); // success
    }

    function withdrawEther(address user, uint256 etherAmount)
        internal
        returns (uint256)
    {

        WETHContract.withdraw(user, etherAmount);
        return uint256(Error.NO_ERROR);
    }

    function withdraw(address asset, uint256 requestedAmount)
        public
        nonReentrant
        returns (uint256)
    {

        if (paused) {
            return
                fail(
                    Error.CONTRACT_PAUSED,
                    FailureInfo.WITHDRAW_CONTRACT_PAUSED
                );
        }

        refreshAlkSupplyIndex(asset, msg.sender, false);

        Market storage market = markets[asset];
        Balance storage supplyBalance = supplyBalances[msg.sender][asset];

        WithdrawLocalVars memory localResults; // Holds all our calculation results
        Error err; // Re-used for every function call that includes an Error in its return value(s).
        uint256 rateCalculationResultCode; // Used for 2 interest rate calculation calls

        (
            err,
            localResults.accountLiquidity,
            localResults.accountShortfall
        ) = calculateAccountLiquidity(msg.sender);
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.WITHDRAW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED
                );
        }

        (err, localResults.newSupplyIndex) = calculateInterestIndex(
            market.supplyIndex,
            market.supplyRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.WITHDRAW_NEW_SUPPLY_INDEX_CALCULATION_FAILED
                );
        }

        (err, localResults.userSupplyCurrent) = calculateBalance(
            supplyBalance.principal,
            supplyBalance.interestIndex,
            localResults.newSupplyIndex
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.WITHDRAW_ACCUMULATED_BALANCE_CALCULATION_FAILED
                );
        }

        if (requestedAmount == uint256(-1)) {
            (err, localResults.withdrawCapacity) = getAssetAmountForValue(
                asset,
                localResults.accountLiquidity
            );
            if (err != Error.NO_ERROR) {
                return
                    fail(err, FailureInfo.WITHDRAW_CAPACITY_CALCULATION_FAILED);
            }
            localResults.withdrawAmount = min(
                localResults.withdrawCapacity,
                localResults.userSupplyCurrent
            );
        } else {
            localResults.withdrawAmount = requestedAmount;
        }


        localResults.currentCash = getCash(asset);
        (err, localResults.updatedCash) = sub(
            localResults.currentCash,
            localResults.withdrawAmount
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    Error.TOKEN_INSUFFICIENT_CASH,
                    FailureInfo.WITHDRAW_TRANSFER_OUT_NOT_POSSIBLE
                );
        }

        (err, localResults.userSupplyUpdated) = sub(
            localResults.userSupplyCurrent,
            localResults.withdrawAmount
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    Error.INSUFFICIENT_BALANCE,
                    FailureInfo.WITHDRAW_NEW_TOTAL_BALANCE_CALCULATION_FAILED
                );
        }

        if (!isZeroExp(localResults.accountShortfall)) {
            return
                fail(
                    Error.INSUFFICIENT_LIQUIDITY,
                    FailureInfo.WITHDRAW_ACCOUNT_SHORTFALL_PRESENT
                );
        }

        (err, localResults.ethValueOfWithdrawal) = getPriceForAssetAmount(
            asset,
            localResults.withdrawAmount
        ); // amount * oraclePrice = ethValueOfWithdrawal
        if (err != Error.NO_ERROR) {
            return
                fail(err, FailureInfo.WITHDRAW_AMOUNT_VALUE_CALCULATION_FAILED);
        }

        if (
            lessThanExp(
                localResults.accountLiquidity,
                localResults.ethValueOfWithdrawal
            )
        ) {
            return
                fail(
                    Error.INSUFFICIENT_LIQUIDITY,
                    FailureInfo.WITHDRAW_AMOUNT_LIQUIDITY_SHORTFALL
                );
        }

        (err, localResults.newTotalSupply) = addThenSub(
            market.totalSupply,
            localResults.userSupplyUpdated,
            supplyBalance.principal
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.WITHDRAW_NEW_TOTAL_SUPPLY_CALCULATION_FAILED
                );
        }

        (rateCalculationResultCode, localResults.newSupplyRateMantissa) = market
        .interestRateModel
        .getSupplyRate(asset, localResults.updatedCash, market.totalBorrows);
        if (rateCalculationResultCode != 0) {
            return
                failOpaque(
                    FailureInfo.WITHDRAW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }

        (err, localResults.newBorrowIndex) = calculateInterestIndex(
            market.borrowIndex,
            market.borrowRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.WITHDRAW_NEW_BORROW_INDEX_CALCULATION_FAILED
                );
        }

        (rateCalculationResultCode, localResults.newBorrowRateMantissa) = market
        .interestRateModel
        .getBorrowRate(asset, localResults.updatedCash, market.totalBorrows);
        if (rateCalculationResultCode != 0) {
            return
                failOpaque(
                    FailureInfo.WITHDRAW_NEW_BORROW_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }


        market.blockNumber = block.number;
        market.totalSupply = localResults.newTotalSupply;
        market.supplyRateMantissa = localResults.newSupplyRateMantissa;
        market.supplyIndex = localResults.newSupplyIndex;
        market.borrowRateMantissa = localResults.newBorrowRateMantissa;
        market.borrowIndex = localResults.newBorrowIndex;

        localResults.startingBalance = supplyBalance.principal; // save for use in `SupplyWithdrawn` event
        supplyBalance.principal = localResults.userSupplyUpdated;
        supplyBalance.interestIndex = localResults.newSupplyIndex;

        if (asset != wethAddress) {
            err = doTransferOut(asset, msg.sender, localResults.withdrawAmount);
            if (err != Error.NO_ERROR) {
                return fail(err, FailureInfo.WITHDRAW_TRANSFER_OUT_FAILED);
            }
        } else {
            withdrawEther(msg.sender, localResults.withdrawAmount); // send Ether to user
        }

        emit SupplyWithdrawn(
            msg.sender,
            asset,
            localResults.withdrawAmount,
            localResults.startingBalance,
            supplyBalance.principal
        );

        return uint256(Error.NO_ERROR); // success
    }

    function calculateAccountLiquidity(address userAddress)
        internal
        view
        returns (
            Error,
            Exp memory,
            Exp memory
        )
    {

        Error err;
        Exp memory sumSupplyValuesMantissa;
        Exp memory sumBorrowValuesMantissa;
        (
            err,
            sumSupplyValuesMantissa,
            sumBorrowValuesMantissa
        ) = calculateAccountValuesInternal(userAddress);
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
        }

        Exp memory result;

        Exp memory sumSupplyValuesFinal = Exp({
            mantissa: sumSupplyValuesMantissa.mantissa
        });
        Exp memory sumBorrowValuesFinal; // need to apply collateral ratio

        (err, sumBorrowValuesFinal) = mulExp(
            collateralRatio,
            Exp({mantissa: sumBorrowValuesMantissa.mantissa})
        );
        if (err != Error.NO_ERROR) {
            return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
        }

        if (lessThanExp(sumSupplyValuesFinal, sumBorrowValuesFinal)) {
            (err, result) = subExp(sumBorrowValuesFinal, sumSupplyValuesFinal);
            assert(err == Error.NO_ERROR); // Note: we have checked that sumBorrows is greater than sumSupplies directly above, therefore `subExp` cannot fail.

            return (Error.NO_ERROR, Exp({mantissa: 0}), result);
        } else {
            (err, result) = subExp(sumSupplyValuesFinal, sumBorrowValuesFinal);
            assert(err == Error.NO_ERROR); // Note: we have checked that sumSupplies is greater than sumBorrows directly above, therefore `subExp` cannot fail.

            return (Error.NO_ERROR, result, Exp({mantissa: 0}));
        }
    }

    function calculateAccountValuesInternal(address userAddress)
        internal
        view
        returns (
            Error,
            Exp memory,
            Exp memory
        )
    {


        AccountValueLocalVars memory localResults; // Re-used for all intermediate results
        localResults.sumSupplies = Exp({mantissa: 0});
        localResults.sumBorrows = Exp({mantissa: 0});
        Error err; // Re-used for all intermediate errors
        localResults.collateralMarketsLength = collateralMarkets.length;

        for (uint256 i = 0; i < localResults.collateralMarketsLength; i++) {
            localResults.assetAddress = collateralMarkets[i];
            Market storage currentMarket = markets[localResults.assetAddress];
            Balance storage supplyBalance = supplyBalances[userAddress][
                localResults.assetAddress
            ];
            Balance storage borrowBalance = borrowBalances[userAddress][
                localResults.assetAddress
            ];

            if (supplyBalance.principal > 0) {
                (err, localResults.newSupplyIndex) = calculateInterestIndex(
                    currentMarket.supplyIndex,
                    currentMarket.supplyRateMantissa,
                    currentMarket.blockNumber,
                    block.number
                );
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }

                (err, localResults.userSupplyCurrent) = calculateBalance(
                    supplyBalance.principal,
                    supplyBalance.interestIndex,
                    localResults.newSupplyIndex
                );
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }

                (err, localResults.supplyTotalValue) = getPriceForAssetAmount(
                    localResults.assetAddress,
                    localResults.userSupplyCurrent
                ); // supplyCurrent * oraclePrice = supplyValueInEth
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }

                (err, localResults.sumSupplies) = addExp(
                    localResults.supplyTotalValue,
                    localResults.sumSupplies
                );
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }
            }

            if (borrowBalance.principal > 0) {
                (err, localResults.newBorrowIndex) = calculateInterestIndex(
                    currentMarket.borrowIndex,
                    currentMarket.borrowRateMantissa,
                    currentMarket.blockNumber,
                    block.number
                );
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }

                (err, localResults.userBorrowCurrent) = calculateBalance(
                    borrowBalance.principal,
                    borrowBalance.interestIndex,
                    localResults.newBorrowIndex
                );
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }

                (err, localResults.borrowTotalValue) = getPriceForAssetAmount(
                    localResults.assetAddress,
                    localResults.userBorrowCurrent
                ); // borrowCurrent * oraclePrice = borrowValueInEth
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }

                (err, localResults.sumBorrows) = addExp(
                    localResults.borrowTotalValue,
                    localResults.sumBorrows
                );
                if (err != Error.NO_ERROR) {
                    return (err, Exp({mantissa: 0}), Exp({mantissa: 0}));
                }
            }
        }

        return (
            Error.NO_ERROR,
            localResults.sumSupplies,
            localResults.sumBorrows
        );
    }

    function calculateAccountValues(address userAddress)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        (
            Error err,
            Exp memory supplyValue,
            Exp memory borrowValue
        ) = calculateAccountValuesInternal(userAddress);
        if (err != Error.NO_ERROR) {
            return (uint256(err), 0, 0);
        }

        return (0, supplyValue.mantissa, borrowValue.mantissa);
    }

    function repayBorrow(address asset, uint256 amount)
        public
        payable
        nonReentrant
        returns (uint256)
    {

        if (paused) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    Error.CONTRACT_PAUSED,
                    FailureInfo.REPAY_BORROW_CONTRACT_PAUSED
                );
        }
        refreshAlkBorrowIndex(asset, msg.sender, false);
        PayBorrowLocalVars memory localResults;
        Market storage market = markets[asset];
        Balance storage borrowBalance = borrowBalances[msg.sender][asset];
        Error err;
        uint256 rateCalculationResultCode;

        (err, localResults.newBorrowIndex) = calculateInterestIndex(
            market.borrowIndex,
            market.borrowRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.REPAY_BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED
                );
        }

        (err, localResults.userBorrowCurrent) = calculateBalance(
            borrowBalance.principal,
            borrowBalance.interestIndex,
            localResults.newBorrowIndex
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo
                        .REPAY_BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED
                );
        }

        uint256 reimburseAmount;
        if (asset != wethAddress) {
            if (amount == uint256(-1)) {
                localResults.repayAmount = min(
                    getBalanceOf(asset, msg.sender),
                    localResults.userBorrowCurrent
                );
            } else {
                localResults.repayAmount = amount;
            }
        } else {
            if (amount > localResults.userBorrowCurrent) {
                localResults.repayAmount = localResults.userBorrowCurrent;
                (err, reimburseAmount) = sub(
                    amount,
                    localResults.userBorrowCurrent
                ); // reimbursement called at the end to make sure function does not have any other errors
                if (err != Error.NO_ERROR) {
                    revertEtherToUser(msg.sender, msg.value);
                    return
                        fail(
                            err,
                            FailureInfo
                                .REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED
                        );
                }
            } else {
                localResults.repayAmount = amount;
            }
        }

        (err, localResults.userBorrowUpdated) = sub(
            localResults.userBorrowCurrent,
            localResults.repayAmount
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo
                        .REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED
                );
        }

        if (asset != wethAddress) {
            revertEtherToUser(msg.sender, msg.value);
            err = checkTransferIn(asset, msg.sender, localResults.repayAmount);
            if (err != Error.NO_ERROR) {
                return
                    fail(
                        err,
                        FailureInfo.REPAY_BORROW_TRANSFER_IN_NOT_POSSIBLE
                    );
            }
        }

        (err, localResults.newTotalBorrows) = addThenSub(
            market.totalBorrows,
            localResults.userBorrowUpdated,
            borrowBalance.principal
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.REPAY_BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED
                );
        }

        localResults.currentCash = getCash(asset);

        (err, localResults.updatedCash) = add(
            localResults.currentCash,
            localResults.repayAmount
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.REPAY_BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED
                );
        }


        (err, localResults.newSupplyIndex) = calculateInterestIndex(
            market.supplyIndex,
            market.supplyRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            revertEtherToUser(msg.sender, msg.value);
            return
                fail(
                    err,
                    FailureInfo.REPAY_BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED
                );
        }

        (rateCalculationResultCode, localResults.newSupplyRateMantissa) = market
        .interestRateModel
        .getSupplyRate(
            asset,
            localResults.updatedCash,
            localResults.newTotalBorrows
        );
        if (rateCalculationResultCode != 0) {
            revertEtherToUser(msg.sender, msg.value);
            return
                failOpaque(
                    FailureInfo.REPAY_BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }

        (rateCalculationResultCode, localResults.newBorrowRateMantissa) = market
        .interestRateModel
        .getBorrowRate(
            asset,
            localResults.updatedCash,
            localResults.newTotalBorrows
        );
        if (rateCalculationResultCode != 0) {
            revertEtherToUser(msg.sender, msg.value);
            return
                failOpaque(
                    FailureInfo.REPAY_BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }


        market.blockNumber = block.number;
        market.totalBorrows = localResults.newTotalBorrows;
        market.supplyRateMantissa = localResults.newSupplyRateMantissa;
        market.supplyIndex = localResults.newSupplyIndex;
        market.borrowRateMantissa = localResults.newBorrowRateMantissa;
        market.borrowIndex = localResults.newBorrowIndex;

        localResults.startingBalance = borrowBalance.principal; // save for use in `BorrowRepaid` event
        borrowBalance.principal = localResults.userBorrowUpdated;
        borrowBalance.interestIndex = localResults.newBorrowIndex;

        if (asset != wethAddress) {
            revertEtherToUser(msg.sender, msg.value);
            err = doTransferIn(asset, msg.sender, localResults.repayAmount);
            if (err != Error.NO_ERROR) {
                return fail(err, FailureInfo.REPAY_BORROW_TRANSFER_IN_FAILED);
            }
        } else {
            if (msg.value == amount) {
                uint256 supplyError = supplyEther(
                    msg.sender,
                    localResults.repayAmount
                );
                if (reimburseAmount > 0) {
                    revertEtherToUser(msg.sender, reimburseAmount);
                }
                if (supplyError != 0) {
                    revertEtherToUser(msg.sender, msg.value);
                    return
                        fail(
                            Error.WETH_ADDRESS_NOT_SET_ERROR,
                            FailureInfo.WETH_ADDRESS_NOT_SET_ERROR
                        );
                }
            } else {
                revertEtherToUser(msg.sender, msg.value);
                return
                    fail(
                        Error.ETHER_AMOUNT_MISMATCH_ERROR,
                        FailureInfo.ETHER_AMOUNT_MISMATCH_ERROR
                    );
            }
        }

        supplyOriginationFeeAsAdmin(
            asset,
            msg.sender,
            localResults.repayAmount,
            market.supplyIndex
        );

        emit BorrowRepaid(
            msg.sender,
            asset,
            localResults.repayAmount,
            localResults.startingBalance,
            borrowBalance.principal
        );

        return uint256(Error.NO_ERROR); // success
    }

    function liquidateBorrow(
        address targetAccount,
        address assetBorrow,
        address assetCollateral,
        uint256 requestedAmountClose
    ) public payable returns (uint256) {

        if (paused) {
            return
                fail(
                    Error.CONTRACT_PAUSED,
                    FailureInfo.LIQUIDATE_CONTRACT_PAUSED
                );
        }
        refreshAlkSupplyIndex(assetCollateral, targetAccount, false);
        refreshAlkSupplyIndex(assetCollateral, msg.sender, false);
        refreshAlkBorrowIndex(assetBorrow, targetAccount, false);
        LiquidateLocalVars memory localResults;
        localResults.targetAccount = targetAccount;
        localResults.assetBorrow = assetBorrow;
        localResults.liquidator = msg.sender;
        localResults.assetCollateral = assetCollateral;

        Market storage borrowMarket = markets[assetBorrow];
        Market storage collateralMarket = markets[assetCollateral];
        Balance storage borrowBalance_TargeUnderwaterAsset = borrowBalances[
            targetAccount
        ][assetBorrow];
        Balance storage supplyBalance_TargetCollateralAsset = supplyBalances[
            targetAccount
        ][assetCollateral];



            Balance storage supplyBalance_LiquidatorCollateralAsset
         = supplyBalances[localResults.liquidator][assetCollateral];

        uint256 rateCalculationResultCode; // Used for multiple interest rate calculation calls
        Error err; // re-used for all intermediate errors

        (err, localResults.collateralPrice) = fetchAssetPrice(assetCollateral);
        if (err != Error.NO_ERROR) {
            return fail(err, FailureInfo.LIQUIDATE_FETCH_ASSET_PRICE_FAILED);
        }

        (err, localResults.underwaterAssetPrice) = fetchAssetPrice(assetBorrow);
        assert(err == Error.NO_ERROR);

        (
            err,
            localResults.newBorrowIndex_UnderwaterAsset
        ) = calculateInterestIndex(
            borrowMarket.borrowIndex,
            borrowMarket.borrowRateMantissa,
            borrowMarket.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_BORROWED_ASSET
                );
        }

        (
            err,
            localResults.currentBorrowBalance_TargetUnderwaterAsset
        ) = calculateBalance(
            borrowBalance_TargeUnderwaterAsset.principal,
            borrowBalance_TargeUnderwaterAsset.interestIndex,
            localResults.newBorrowIndex_UnderwaterAsset
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_ACCUMULATED_BORROW_BALANCE_CALCULATION_FAILED
                );
        }

        (
            err,
            localResults.newSupplyIndex_CollateralAsset
        ) = calculateInterestIndex(
            collateralMarket.supplyIndex,
            collateralMarket.supplyRateMantissa,
            collateralMarket.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET
                );
        }

        (
            err,
            localResults.currentSupplyBalance_TargetCollateralAsset
        ) = calculateBalance(
            supplyBalance_TargetCollateralAsset.principal,
            supplyBalance_TargetCollateralAsset.interestIndex,
            localResults.newSupplyIndex_CollateralAsset
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET
                );
        }

        (
            err,
            localResults.currentSupplyBalance_LiquidatorCollateralAsset
        ) = calculateBalance(
            supplyBalance_LiquidatorCollateralAsset.principal,
            supplyBalance_LiquidatorCollateralAsset.interestIndex,
            localResults.newSupplyIndex_CollateralAsset
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_ACCUMULATED_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET
                );
        }


        (err, localResults.newTotalSupply_ProtocolCollateralAsset) = addThenSub(
            collateralMarket.totalSupply,
            localResults.currentSupplyBalance_TargetCollateralAsset,
            supplyBalance_TargetCollateralAsset.principal
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_BORROWER_COLLATERAL_ASSET
                );
        }

        (err, localResults.newTotalSupply_ProtocolCollateralAsset) = addThenSub(
            localResults.newTotalSupply_ProtocolCollateralAsset,
            localResults.currentSupplyBalance_LiquidatorCollateralAsset,
            supplyBalance_LiquidatorCollateralAsset.principal
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_TOTAL_SUPPLY_BALANCE_CALCULATION_FAILED_LIQUIDATOR_COLLATERAL_ASSET
                );
        }


        (
            err,
            localResults.discountedBorrowDenominatedCollateral
        ) = calculateDiscountedBorrowDenominatedCollateral(
            localResults.underwaterAssetPrice,
            localResults.collateralPrice,
            localResults.currentSupplyBalance_TargetCollateralAsset
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_BORROW_DENOMINATED_COLLATERAL_CALCULATION_FAILED
                );
        }

        if (borrowMarket.isSupported) {
            (
                err,
                localResults.discountedRepayToEvenAmount
            ) = calculateDiscountedRepayToEvenAmount(
                targetAccount,
                localResults.underwaterAssetPrice,
                assetBorrow
            );
            if (err != Error.NO_ERROR) {
                return
                    fail(
                        err,
                        FailureInfo
                            .LIQUIDATE_DISCOUNTED_REPAY_TO_EVEN_AMOUNT_CALCULATION_FAILED
                    );
            }

            localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset = min(
                localResults.currentBorrowBalance_TargetUnderwaterAsset,
                localResults.discountedBorrowDenominatedCollateral
            );

            localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset = min(
                localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset,
                localResults.discountedRepayToEvenAmount
            );
        } else {
            localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset = min(
                localResults.currentBorrowBalance_TargetUnderwaterAsset,
                localResults.discountedBorrowDenominatedCollateral
            );
        }

        if (assetBorrow != wethAddress) {
            if (requestedAmountClose == uint256(-1)) {
                localResults
                .closeBorrowAmount_TargetUnderwaterAsset = localResults
                .maxCloseableBorrowAmount_TargetUnderwaterAsset;
            } else {
                localResults
                .closeBorrowAmount_TargetUnderwaterAsset = requestedAmountClose;
            }
        } else {
            if (
                requestedAmountClose >
                localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset
            ) {
                localResults
                .closeBorrowAmount_TargetUnderwaterAsset = localResults
                .maxCloseableBorrowAmount_TargetUnderwaterAsset;
                (err, localResults.reimburseAmount) = sub(
                    requestedAmountClose,
                    localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset
                ); // reimbursement called at the end to make sure function does not have any other errors
                if (err != Error.NO_ERROR) {
                    return
                        fail(
                            err,
                            FailureInfo
                                .REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED
                        );
                }
            } else {
                localResults
                .closeBorrowAmount_TargetUnderwaterAsset = requestedAmountClose;
            }
        }


        if (
            localResults.closeBorrowAmount_TargetUnderwaterAsset >
            localResults.maxCloseableBorrowAmount_TargetUnderwaterAsset
        ) {
            return
                fail(
                    Error.INVALID_CLOSE_AMOUNT_REQUESTED,
                    FailureInfo.LIQUIDATE_CLOSE_AMOUNT_TOO_HIGH
                );
        }

        (
            err,
            localResults.seizeSupplyAmount_TargetCollateralAsset
        ) = calculateAmountSeize(
            localResults.underwaterAssetPrice,
            localResults.collateralPrice,
            localResults.closeBorrowAmount_TargetUnderwaterAsset
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.LIQUIDATE_AMOUNT_SEIZE_CALCULATION_FAILED
                );
        }

        if (assetBorrow != wethAddress) {
            err = checkTransferIn(
                assetBorrow,
                localResults.liquidator,
                localResults.closeBorrowAmount_TargetUnderwaterAsset
            );
            if (err != Error.NO_ERROR) {
                return
                    fail(err, FailureInfo.LIQUIDATE_TRANSFER_IN_NOT_POSSIBLE);
            }
        }


        (err, localResults.updatedBorrowBalance_TargetUnderwaterAsset) = sub(
            localResults.currentBorrowBalance_TargetUnderwaterAsset,
            localResults.closeBorrowAmount_TargetUnderwaterAsset
        );
        assert(err == Error.NO_ERROR);

        (
            err,
            localResults.newTotalBorrows_ProtocolUnderwaterAsset
        ) = addThenSub(
            borrowMarket.totalBorrows,
            localResults.updatedBorrowBalance_TargetUnderwaterAsset,
            borrowBalance_TargeUnderwaterAsset.principal
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_TOTAL_BORROW_CALCULATION_FAILED_BORROWED_ASSET
                );
        }

        localResults.currentCash_ProtocolUnderwaterAsset = getCash(assetBorrow);
        (err, localResults.updatedCash_ProtocolUnderwaterAsset) = add(
            localResults.currentCash_ProtocolUnderwaterAsset,
            localResults.closeBorrowAmount_TargetUnderwaterAsset
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_TOTAL_CASH_CALCULATION_FAILED_BORROWED_ASSET
                );
        }


        (
            err,
            localResults.newSupplyIndex_UnderwaterAsset
        ) = calculateInterestIndex(
            borrowMarket.supplyIndex,
            borrowMarket.supplyRateMantissa,
            borrowMarket.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_SUPPLY_INDEX_CALCULATION_FAILED_BORROWED_ASSET
                );
        }

        (
            rateCalculationResultCode,
            localResults.newSupplyRateMantissa_ProtocolUnderwaterAsset
        ) = borrowMarket.interestRateModel.getSupplyRate(
            assetBorrow,
            localResults.updatedCash_ProtocolUnderwaterAsset,
            localResults.newTotalBorrows_ProtocolUnderwaterAsset
        );
        if (rateCalculationResultCode != 0) {
            return
                failOpaque(
                    FailureInfo
                        .LIQUIDATE_NEW_SUPPLY_RATE_CALCULATION_FAILED_BORROWED_ASSET,
                    rateCalculationResultCode
                );
        }

        (
            rateCalculationResultCode,
            localResults.newBorrowRateMantissa_ProtocolUnderwaterAsset
        ) = borrowMarket.interestRateModel.getBorrowRate(
            assetBorrow,
            localResults.updatedCash_ProtocolUnderwaterAsset,
            localResults.newTotalBorrows_ProtocolUnderwaterAsset
        );
        if (rateCalculationResultCode != 0) {
            return
                failOpaque(
                    FailureInfo
                        .LIQUIDATE_NEW_BORROW_RATE_CALCULATION_FAILED_BORROWED_ASSET,
                    rateCalculationResultCode
                );
        }

        (
            err,
            localResults.newBorrowIndex_CollateralAsset
        ) = calculateInterestIndex(
            collateralMarket.borrowIndex,
            collateralMarket.borrowRateMantissa,
            collateralMarket.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo
                        .LIQUIDATE_NEW_BORROW_INDEX_CALCULATION_FAILED_COLLATERAL_ASSET
                );
        }

        (err, localResults.updatedSupplyBalance_TargetCollateralAsset) = sub(
            localResults.currentSupplyBalance_TargetCollateralAsset,
            localResults.seizeSupplyAmount_TargetCollateralAsset
        );
        assert(err == Error.NO_ERROR);

        (
            err,
            localResults.updatedSupplyBalance_LiquidatorCollateralAsset
        ) = add(
            localResults.currentSupplyBalance_LiquidatorCollateralAsset,
            localResults.seizeSupplyAmount_TargetCollateralAsset
        );
        assert(err == Error.NO_ERROR);


        borrowMarket.blockNumber = block.number;
        borrowMarket.totalBorrows = localResults
        .newTotalBorrows_ProtocolUnderwaterAsset;
        borrowMarket.supplyRateMantissa = localResults
        .newSupplyRateMantissa_ProtocolUnderwaterAsset;
        borrowMarket.supplyIndex = localResults.newSupplyIndex_UnderwaterAsset;
        borrowMarket.borrowRateMantissa = localResults
        .newBorrowRateMantissa_ProtocolUnderwaterAsset;
        borrowMarket.borrowIndex = localResults.newBorrowIndex_UnderwaterAsset;

        collateralMarket.blockNumber = block.number;
        collateralMarket.totalSupply = localResults
        .newTotalSupply_ProtocolCollateralAsset;
        collateralMarket.supplyIndex = localResults
        .newSupplyIndex_CollateralAsset;
        collateralMarket.borrowIndex = localResults
        .newBorrowIndex_CollateralAsset;


        localResults
        .startingBorrowBalance_TargetUnderwaterAsset = borrowBalance_TargeUnderwaterAsset
        .principal; // save for use in event
        borrowBalance_TargeUnderwaterAsset.principal = localResults
        .updatedBorrowBalance_TargetUnderwaterAsset;
        borrowBalance_TargeUnderwaterAsset.interestIndex = localResults
        .newBorrowIndex_UnderwaterAsset;

        localResults
        .startingSupplyBalance_TargetCollateralAsset = supplyBalance_TargetCollateralAsset
        .principal; // save for use in event
        supplyBalance_TargetCollateralAsset.principal = localResults
        .updatedSupplyBalance_TargetCollateralAsset;
        supplyBalance_TargetCollateralAsset.interestIndex = localResults
        .newSupplyIndex_CollateralAsset;

        localResults
        .startingSupplyBalance_LiquidatorCollateralAsset = supplyBalance_LiquidatorCollateralAsset
        .principal; // save for use in event
        supplyBalance_LiquidatorCollateralAsset.principal = localResults
        .updatedSupplyBalance_LiquidatorCollateralAsset;
        supplyBalance_LiquidatorCollateralAsset.interestIndex = localResults
        .newSupplyIndex_CollateralAsset;

        if (assetBorrow != wethAddress) {
            revertEtherToUser(msg.sender, msg.value);
            err = doTransferIn(
                assetBorrow,
                localResults.liquidator,
                localResults.closeBorrowAmount_TargetUnderwaterAsset
            );
            if (err != Error.NO_ERROR) {
                return fail(err, FailureInfo.LIQUIDATE_TRANSFER_IN_FAILED);
            }
        } else {
            if (msg.value == requestedAmountClose) {
                uint256 supplyError = supplyEther(
                    localResults.liquidator,
                    localResults.closeBorrowAmount_TargetUnderwaterAsset
                );
                if (localResults.reimburseAmount > 0) {
                    revertEtherToUser(
                        localResults.liquidator,
                        localResults.reimburseAmount
                    );
                }
                if (supplyError != 0) {
                    revertEtherToUser(msg.sender, msg.value);
                    return
                        fail(
                            Error.WETH_ADDRESS_NOT_SET_ERROR,
                            FailureInfo.WETH_ADDRESS_NOT_SET_ERROR
                        );
                }
            } else {
                revertEtherToUser(msg.sender, msg.value);
                return
                    fail(
                        Error.ETHER_AMOUNT_MISMATCH_ERROR,
                        FailureInfo.ETHER_AMOUNT_MISMATCH_ERROR
                    );
            }
        }

        supplyOriginationFeeAsAdmin(
            assetBorrow,
            localResults.liquidator,
            localResults.closeBorrowAmount_TargetUnderwaterAsset,
            localResults.newSupplyIndex_UnderwaterAsset
        );

        emit BorrowLiquidated(
            localResults.targetAccount,
            localResults.assetBorrow,
            localResults.currentBorrowBalance_TargetUnderwaterAsset,
            localResults.closeBorrowAmount_TargetUnderwaterAsset,
            localResults.liquidator,
            localResults.assetCollateral,
            localResults.seizeSupplyAmount_TargetCollateralAsset
        );

        return uint256(Error.NO_ERROR); // success
    }

    function calculateDiscountedRepayToEvenAmount(
        address targetAccount,
        Exp memory underwaterAssetPrice,
        address assetBorrow
    ) internal view returns (Error, uint256) {

        Error err;
        Exp memory _accountLiquidity; // unused return value from calculateAccountLiquidity
        Exp memory accountShortfall_TargetUser;
        Exp memory collateralRatioMinusLiquidationDiscount; // collateralRatio - liquidationDiscount
        Exp memory discountedCollateralRatioMinusOne; // collateralRatioMinusLiquidationDiscount - 1, aka collateralRatio - liquidationDiscount - 1
        Exp memory discountedPrice_UnderwaterAsset;
        Exp memory rawResult;

        (
            err,
            _accountLiquidity,
            accountShortfall_TargetUser
        ) = calculateAccountLiquidity(targetAccount);
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, collateralRatioMinusLiquidationDiscount) = subExp(
            collateralRatio,
            liquidationDiscount
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, discountedCollateralRatioMinusOne) = subExp(
            collateralRatioMinusLiquidationDiscount,
            Exp({mantissa: mantissaOne})
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, discountedPrice_UnderwaterAsset) = mulExp(
            underwaterAssetPrice,
            discountedCollateralRatioMinusOne
        );
        assert(err == Error.NO_ERROR);

        uint256 borrowBalance = getBorrowBalance(targetAccount, assetBorrow);
        Exp memory maxClose;
        (err, maxClose) = mulScalar(
            Exp({mantissa: closeFactorMantissa}),
            borrowBalance
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, rawResult) = divExp(maxClose, discountedPrice_UnderwaterAsset);
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        return (Error.NO_ERROR, truncate(rawResult));
    }

    function calculateDiscountedBorrowDenominatedCollateral(
        Exp memory underwaterAssetPrice,
        Exp memory collateralPrice,
        uint256 supplyCurrent_TargetCollateralAsset
    ) internal view returns (Error, uint256) {

        Error err;
        Exp memory onePlusLiquidationDiscount; // (1 + liquidationDiscount)
        Exp memory supplyCurrentTimesOracleCollateral; // supplyCurrent * Oracle price for the collateral
        Exp memory onePlusLiquidationDiscountTimesOracleBorrow; // (1 + liquidationDiscount) * Oracle price for the borrow
        Exp memory rawResult;

        (err, onePlusLiquidationDiscount) = addExp(
            Exp({mantissa: mantissaOne}),
            liquidationDiscount
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, supplyCurrentTimesOracleCollateral) = mulScalar(
            collateralPrice,
            supplyCurrent_TargetCollateralAsset
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, onePlusLiquidationDiscountTimesOracleBorrow) = mulExp(
            onePlusLiquidationDiscount,
            underwaterAssetPrice
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, rawResult) = divExp(
            supplyCurrentTimesOracleCollateral,
            onePlusLiquidationDiscountTimesOracleBorrow
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        return (Error.NO_ERROR, truncate(rawResult));
    }

    function calculateAmountSeize(
        Exp memory underwaterAssetPrice,
        Exp memory collateralPrice,
        uint256 closeBorrowAmount_TargetUnderwaterAsset
    ) internal view returns (Error, uint256) {


        Error err;

        Exp memory liquidationMultiplier;

        Exp memory priceUnderwaterAssetTimesLiquidationMultiplier;

        Exp memory finalNumerator;

        Exp memory rawResult;

        (err, liquidationMultiplier) = addExp(
            Exp({mantissa: mantissaOne}),
            liquidationDiscount
        );
        assert(err == Error.NO_ERROR);

        (err, priceUnderwaterAssetTimesLiquidationMultiplier) = mulExp(
            underwaterAssetPrice,
            liquidationMultiplier
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, finalNumerator) = mulScalar(
            priceUnderwaterAssetTimesLiquidationMultiplier,
            closeBorrowAmount_TargetUnderwaterAsset
        );
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        (err, rawResult) = divExp(finalNumerator, collateralPrice);
        if (err != Error.NO_ERROR) {
            return (err, 0);
        }

        return (Error.NO_ERROR, truncate(rawResult));
    }

    function borrow(address asset, uint256 amount)
        public
        nonReentrant
        returns (uint256)
    {

        if (paused) {
            return
                fail(Error.CONTRACT_PAUSED, FailureInfo.BORROW_CONTRACT_PAUSED);
        }
        refreshAlkBorrowIndex(asset, msg.sender, false);
        BorrowLocalVars memory localResults;
        Market storage market = markets[asset];
        Balance storage borrowBalance = borrowBalances[msg.sender][asset];

        Error err;
        uint256 rateCalculationResultCode;

        if (!market.isSupported) {
            return
                fail(
                    Error.MARKET_NOT_SUPPORTED,
                    FailureInfo.BORROW_MARKET_NOT_SUPPORTED
                );
        }

        (err, localResults.newBorrowIndex) = calculateInterestIndex(
            market.borrowIndex,
            market.borrowRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_NEW_BORROW_INDEX_CALCULATION_FAILED
                );
        }

        (err, localResults.userBorrowCurrent) = calculateBalance(
            borrowBalance.principal,
            borrowBalance.interestIndex,
            localResults.newBorrowIndex
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED
                );
        }

        (err, localResults.borrowAmountWithFee) = calculateBorrowAmountWithFee(
            amount
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_ORIGINATION_FEE_CALCULATION_FAILED
                );
        }
        uint256 orgFeeBalance = localResults.borrowAmountWithFee - amount;

        (err, localResults.userBorrowUpdated) = add(
            localResults.userBorrowCurrent,
            localResults.borrowAmountWithFee
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED
                );
        }

        (err, localResults.newTotalBorrows) = addThenSub(
            market.totalBorrows,
            localResults.userBorrowUpdated,
            borrowBalance.principal
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_NEW_TOTAL_BORROW_CALCULATION_FAILED
                );
        }

        (
            err,
            localResults.accountLiquidity,
            localResults.accountShortfall
        ) = calculateAccountLiquidity(msg.sender);
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_ACCOUNT_LIQUIDITY_CALCULATION_FAILED
                );
        }

        if (!isZeroExp(localResults.accountShortfall)) {
            return
                fail(
                    Error.INSUFFICIENT_LIQUIDITY,
                    FailureInfo.BORROW_ACCOUNT_SHORTFALL_PRESENT
                );
        }

        (
            err,
            localResults.ethValueOfBorrowAmountWithFee
        ) = getPriceForAssetAmountMulCollatRatio(
            asset,
            localResults.borrowAmountWithFee
        );
        if (err != Error.NO_ERROR) {
            return
                fail(err, FailureInfo.BORROW_AMOUNT_VALUE_CALCULATION_FAILED);
        }
        if (
            lessThanExp(
                localResults.accountLiquidity,
                localResults.ethValueOfBorrowAmountWithFee
            )
        ) {
            return
                fail(
                    Error.INSUFFICIENT_LIQUIDITY,
                    FailureInfo.BORROW_AMOUNT_LIQUIDITY_SHORTFALL
                );
        }

        localResults.currentCash = getCash(asset);
        (err, localResults.updatedCash) = sub(localResults.currentCash, amount);
        if (err != Error.NO_ERROR) {
            return
                fail(
                    Error.TOKEN_INSUFFICIENT_CASH,
                    FailureInfo.BORROW_NEW_TOTAL_CASH_CALCULATION_FAILED
                );
        }


        (err, localResults.newSupplyIndex) = calculateInterestIndex(
            market.supplyIndex,
            market.supplyRateMantissa,
            market.blockNumber,
            block.number
        );
        if (err != Error.NO_ERROR) {
            return
                fail(
                    err,
                    FailureInfo.BORROW_NEW_SUPPLY_INDEX_CALCULATION_FAILED
                );
        }

        (rateCalculationResultCode, localResults.newSupplyRateMantissa) = market
        .interestRateModel
        .getSupplyRate(
            asset,
            localResults.updatedCash,
            localResults.newTotalBorrows
        );
        if (rateCalculationResultCode != 0) {
            return
                failOpaque(
                    FailureInfo.BORROW_NEW_SUPPLY_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }

        (rateCalculationResultCode, localResults.newBorrowRateMantissa) = market
        .interestRateModel
        .getBorrowRate(
            asset,
            localResults.updatedCash,
            localResults.newTotalBorrows
        );
        if (rateCalculationResultCode != 0) {
            return
                failOpaque(
                    FailureInfo.BORROW_NEW_BORROW_RATE_CALCULATION_FAILED,
                    rateCalculationResultCode
                );
        }


        market.blockNumber = block.number;
        market.totalBorrows = localResults.newTotalBorrows;
        market.supplyRateMantissa = localResults.newSupplyRateMantissa;
        market.supplyIndex = localResults.newSupplyIndex;
        market.borrowRateMantissa = localResults.newBorrowRateMantissa;
        market.borrowIndex = localResults.newBorrowIndex;

        localResults.startingBalance = borrowBalance.principal; // save for use in `BorrowTaken` event
        borrowBalance.principal = localResults.userBorrowUpdated;
        borrowBalance.interestIndex = localResults.newBorrowIndex;

        originationFeeBalance[msg.sender][asset] += orgFeeBalance;

        if (asset != wethAddress) {
            err = doTransferOut(asset, msg.sender, amount);
            if (err != Error.NO_ERROR) {
                return fail(err, FailureInfo.BORROW_TRANSFER_OUT_FAILED);
            }
        } else {
            withdrawEther(msg.sender, amount); // send Ether to user
        }

        emit BorrowTaken(
            msg.sender,
            asset,
            amount,
            localResults.startingBalance,
            localResults.borrowAmountWithFee,
            borrowBalance.principal
        );

        return uint256(Error.NO_ERROR); // success
    }

    function supplyOriginationFeeAsAdmin(
        address asset,
        address user,
        uint256 amount,
        uint256 newSupplyIndex
    ) private {

        refreshAlkSupplyIndex(asset, admin, false);
        uint256 originationFeeRepaid = 0;
        if (originationFeeBalance[user][asset] != 0) {
            if (amount < originationFeeBalance[user][asset]) {
                originationFeeRepaid = amount;
            } else {
                originationFeeRepaid = originationFeeBalance[user][asset];
            }
            Balance storage balance = supplyBalances[admin][asset];

            SupplyLocalVars memory localResults; // Holds all our uint calculation results
            Error err; // Re-used for every function call that includes an Error in its return value(s).

            originationFeeBalance[user][asset] -= originationFeeRepaid;

            (err, localResults.userSupplyCurrent) = calculateBalance(
                balance.principal,
                balance.interestIndex,
                newSupplyIndex
            );
            revertIfError(err);

            (err, localResults.userSupplyUpdated) = add(
                localResults.userSupplyCurrent,
                originationFeeRepaid
            );
            revertIfError(err);

            (err, localResults.newTotalSupply) = addThenSub(
                markets[asset].totalSupply,
                localResults.userSupplyUpdated,
                balance.principal
            );
            revertIfError(err);

            markets[asset].totalSupply = localResults.newTotalSupply;

            localResults.startingBalance = balance.principal;
            balance.principal = localResults.userSupplyUpdated;
            balance.interestIndex = newSupplyIndex;

            emit SupplyOrgFeeAsAdmin(
                admin,
                asset,
                originationFeeRepaid,
                localResults.startingBalance,
                localResults.userSupplyUpdated
            );
        }
    }

    function setRewardControlAddress(address _rewardControl)
        external
        returns (uint256)
    {

        require(
            msg.sender == admin,
            "SET_REWARD_CONTROL_ADDRESS_ADMIN_CHECK_FAILED"
        );
        require(
            address(rewardControl) != _rewardControl,
            "The same Reward Control address"
        );
        require(
            _rewardControl != address(0),
            "RewardControl address cannot be empty"
        );
        rewardControl = RewardControlInterface(_rewardControl);
        return uint256(Error.NO_ERROR); // success
    }

    function refreshAlkSupplyIndex(
        address market,
        address supplier,
        bool isVerified
    ) internal {

        if (address(rewardControl) == address(0)) {
            return;
        }
        rewardControl.refreshAlkSupplyIndex(market, supplier, isVerified);
    }

    function refreshAlkBorrowIndex(
        address market,
        address borrower,
        bool isVerified
    ) internal {

        if (address(rewardControl) == address(0)) {
            return;
        }
        rewardControl.refreshAlkBorrowIndex(market, borrower, isVerified);
    }

    function getMarketBalances(address asset)
        public
        view
        returns (uint256, uint256)
    {

        Error err;
        uint256 newSupplyIndex;
        uint256 marketSupplyCurrent;
        uint256 newBorrowIndex;
        uint256 marketBorrowCurrent;

        Market storage market = markets[asset];

        (err, newSupplyIndex) = calculateInterestIndex(
            market.supplyIndex,
            market.supplyRateMantissa,
            market.blockNumber,
            block.number
        );
        revertIfError(err);

        (err, marketSupplyCurrent) = calculateBalance(
            market.totalSupply,
            market.supplyIndex,
            newSupplyIndex
        );
        revertIfError(err);

        (err, newBorrowIndex) = calculateInterestIndex(
            market.borrowIndex,
            market.borrowRateMantissa,
            market.blockNumber,
            block.number
        );
        revertIfError(err);

        (err, marketBorrowCurrent) = calculateBalance(
            market.totalBorrows,
            market.borrowIndex,
            newBorrowIndex
        );
        revertIfError(err);

        return (marketSupplyCurrent, marketBorrowCurrent);
    }

    function revertIfError(Error err) internal pure {

        require(
            err == Error.NO_ERROR,
            "Function revert due to internal exception"
        );
    }
}


pragma solidity 0.4.24;



contract RewardControlStorage {

    struct MarketState {
        uint224 index;
        uint32 block;
    }

    mapping(bool => address[]) public allMarkets;

    mapping(bool => mapping(address => bool)) public allMarketsIndex;

    uint256 public alkRate;

    mapping(bool => mapping(address => uint256)) public alkSpeeds;

    mapping(bool => mapping(address => MarketState)) public alkSupplyState;

    mapping(bool => mapping(address => MarketState)) public alkBorrowState;

    mapping(bool => mapping(address => mapping(address => uint256)))
        public alkSupplierIndex;

    mapping(bool => mapping(address => mapping(address => uint256)))
        public alkBorrowerIndex;

    mapping(address => uint256) public alkAccrued;

    bool public initializationDone;

    address public owner;

    address public newOwner;

    AlkemiEarnVerified public alkemiEarnVerified;

    AlkemiEarnPublic public alkemiEarnPublic;

    address public alkAddress;

    uint8 public MAXIMUM_NUMBER_OF_MARKETS;
}


pragma solidity 0.4.24;

contract ExponentialNoError {

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

    function truncate(Exp memory exp) internal pure returns (uint256) {

        return exp.mantissa / expScale;
    }

    function mul_ScalarTruncate(Exp memory a, uint256 scalar)
        internal
        pure
        returns (uint256)
    {

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

    function lessThanExp(Exp memory left, Exp memory right)
        internal
        pure
        returns (bool)
    {

        return left.mantissa < right.mantissa;
    }

    function lessThanOrEqualExp(Exp memory left, Exp memory right)
        internal
        pure
        returns (bool)
    {

        return left.mantissa <= right.mantissa;
    }

    function greaterThanExp(Exp memory left, Exp memory right)
        internal
        pure
        returns (bool)
    {

        return left.mantissa > right.mantissa;
    }

    function isZeroExp(Exp memory value) internal pure returns (bool) {

        return value.mantissa == 0;
    }

    function safe224(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint224)
    {

        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint32)
    {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b)
        internal
        pure
        returns (Exp memory)
    {

        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b)
        internal
        pure
        returns (Double memory)
    {

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

    function sub_(Exp memory a, Exp memory b)
        internal
        pure
        returns (Exp memory)
    {

        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b)
        internal
        pure
        returns (Double memory)
    {

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

    function mul_(Exp memory a, Exp memory b)
        internal
        pure
        returns (Exp memory)
    {

        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint256 b) internal pure returns (Exp memory) {

        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint256 a, Exp memory b) internal pure returns (uint256) {

        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b)
        internal
        pure
        returns (Double memory)
    {

        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint256 b)
        internal
        pure
        returns (Double memory)
    {

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

    function div_(Exp memory a, Exp memory b)
        internal
        pure
        returns (Exp memory)
    {

        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint256 b) internal pure returns (Exp memory) {

        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint256 a, Exp memory b) internal pure returns (uint256) {

        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b)
        internal
        pure
        returns (Double memory)
    {

        return
            Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint256 b)
        internal
        pure
        returns (Double memory)
    {

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

    function fraction(uint256 a, uint256 b)
        internal
        pure
        returns (Double memory)
    {

        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}


pragma solidity 0.4.24;





contract RewardControl is
    RewardControlStorage,
    RewardControlInterface,
    ExponentialNoError
{


    event AlkSpeedUpdated(
        address indexed market,
        uint256 newSpeed,
        bool isVerified
    );

    event DistributedSupplierAlk(
        address indexed market,
        address indexed supplier,
        uint256 supplierDelta,
        uint256 supplierAccruedAlk,
        uint256 supplyIndexMantissa,
        bool isVerified
    );

    event DistributedBorrowerAlk(
        address indexed market,
        address indexed borrower,
        uint256 borrowerDelta,
        uint256 borrowerAccruedAlk,
        uint256 borrowIndexMantissa,
        bool isVerified
    );

    event TransferredAlk(
        address indexed participant,
        uint256 participantAccrued,
        address market,
        bool isVerified
    );

    event OwnerUpdate(address indexed owner, address indexed newOwner);

    event MarketAdded(
        address indexed market,
        uint256 numberOfMarkets,
        bool isVerified
    );

    event MarketRemoved(
        address indexed market,
        uint256 numberOfMarkets,
        bool isVerified
    );



    function initializer(
        address _owner,
        address _alkemiEarnVerified,
        address _alkemiEarnPublic,
        address _alkAddress
    ) public {

        require(
            _owner != address(0) &&
                _alkemiEarnVerified != address(0) &&
                _alkemiEarnPublic != address(0) &&
                _alkAddress != address(0),
            "Inputs cannot be 0x00"
        );
        if (initializationDone == false) {
            initializationDone = true;
            owner = _owner;
            alkemiEarnVerified = AlkemiEarnVerified(_alkemiEarnVerified);
            alkemiEarnPublic = AlkemiEarnPublic(_alkemiEarnPublic);
            alkAddress = _alkAddress;
            alkRate = 3690226761271430000;
            MAXIMUM_NUMBER_OF_MARKETS = 16;
        }
    }


    modifier onlyOwner() {

        require(msg.sender == owner, "non-owner");
        _;
    }


    function refreshAlkSupplyIndex(
        address market,
        address supplier,
        bool isVerified
    ) external {

        if (!allMarketsIndex[isVerified][market]) {
            return;
        }
        refreshAlkSpeeds();
        updateAlkSupplyIndex(market, isVerified);
        distributeSupplierAlk(market, supplier, isVerified);
    }

    function refreshAlkBorrowIndex(
        address market,
        address borrower,
        bool isVerified
    ) external {

        if (!allMarketsIndex[isVerified][market]) {
            return;
        }
        refreshAlkSpeeds();
        updateAlkBorrowIndex(market, isVerified);
        distributeBorrowerAlk(market, borrower, isVerified);
    }

    function claimAlk(address holder) external {

        claimAlk(holder, allMarkets[true], true);
        claimAlk(holder, allMarkets[false], false);
    }

    function claimAlk(
        address holder,
        address market,
        bool isVerified
    ) external {

        require(allMarketsIndex[isVerified][market], "Market does not exist");
        address[] memory markets = new address[](1);
        markets[0] = market;
        claimAlk(holder, markets, isVerified);
    }


    function refreshMarketLiquidity()
        internal
        view
        returns (Exp[] memory, Exp memory)
    {

        Exp memory totalLiquidity = Exp({mantissa: 0});
        Exp[] memory marketTotalLiquidity = new Exp[](
            add_(allMarkets[true].length, allMarkets[false].length)
        );
        address currentMarket;
        uint256 verifiedMarketsLength = allMarkets[true].length;
        for (uint256 i = 0; i < allMarkets[true].length; i++) {
            currentMarket = allMarkets[true][i];
            uint256 currentMarketTotalSupply = mul_(
                getMarketTotalSupply(currentMarket, true),
                alkemiEarnVerified.assetPrices(currentMarket)
            );
            uint256 currentMarketTotalBorrows = mul_(
                getMarketTotalBorrows(currentMarket, true),
                alkemiEarnVerified.assetPrices(currentMarket)
            );
            Exp memory currentMarketTotalLiquidity = Exp({
                mantissa: add_(
                    currentMarketTotalSupply,
                    currentMarketTotalBorrows
                )
            });
            marketTotalLiquidity[i] = currentMarketTotalLiquidity;
            totalLiquidity = add_(totalLiquidity, currentMarketTotalLiquidity);
        }

        for (uint256 j = 0; j < allMarkets[false].length; j++) {
            currentMarket = allMarkets[false][j];
            currentMarketTotalSupply = mul_(
                getMarketTotalSupply(currentMarket, false),
                alkemiEarnVerified.assetPrices(currentMarket)
            );
            currentMarketTotalBorrows = mul_(
                getMarketTotalBorrows(currentMarket, false),
                alkemiEarnVerified.assetPrices(currentMarket)
            );
            currentMarketTotalLiquidity = Exp({
                mantissa: add_(
                    currentMarketTotalSupply,
                    currentMarketTotalBorrows
                )
            });
            marketTotalLiquidity[
                verifiedMarketsLength + j
            ] = currentMarketTotalLiquidity;
            totalLiquidity = add_(totalLiquidity, currentMarketTotalLiquidity);
        }
        return (marketTotalLiquidity, totalLiquidity);
    }

    function refreshAlkSpeeds() internal {

        address currentMarket;
        (
            Exp[] memory marketTotalLiquidity,
            Exp memory totalLiquidity
        ) = refreshMarketLiquidity();
        uint256 newSpeed;
        uint256 verifiedMarketsLength = allMarkets[true].length;
        for (uint256 i = 0; i < allMarkets[true].length; i++) {
            currentMarket = allMarkets[true][i];
            newSpeed = totalLiquidity.mantissa > 0
                ? mul_(alkRate, div_(marketTotalLiquidity[i], totalLiquidity))
                : 0;
            alkSpeeds[true][currentMarket] = newSpeed;
            emit AlkSpeedUpdated(currentMarket, newSpeed, true);
        }

        for (uint256 j = 0; j < allMarkets[false].length; j++) {
            currentMarket = allMarkets[false][j];
            newSpeed = totalLiquidity.mantissa > 0
                ? mul_(
                    alkRate,
                    div_(
                        marketTotalLiquidity[verifiedMarketsLength + j],
                        totalLiquidity
                    )
                )
                : 0;
            alkSpeeds[false][currentMarket] = newSpeed;
            emit AlkSpeedUpdated(currentMarket, newSpeed, false);
        }
    }

    function updateAlkSupplyIndex(address market, bool isVerified) internal {

        MarketState storage supplyState = alkSupplyState[isVerified][market];
        uint256 marketSpeed = alkSpeeds[isVerified][market];
        uint256 blockNumber = getBlockNumber();
        uint256 deltaBlocks = sub_(blockNumber, uint256(supplyState.block));
        if (deltaBlocks > 0 && marketSpeed > 0) {
            uint256 marketTotalSupply = getMarketTotalSupply(
                market,
                isVerified
            );
            uint256 supplyAlkAccrued = mul_(deltaBlocks, marketSpeed);
            Double memory ratio = marketTotalSupply > 0
                ? fraction(supplyAlkAccrued, marketTotalSupply)
                : Double({mantissa: 0});
            Double memory index = add_(
                Double({mantissa: supplyState.index}),
                ratio
            );
            alkSupplyState[isVerified][market] = MarketState({
                index: safe224(index.mantissa, "new index exceeds 224 bits"),
                block: safe32(blockNumber, "block number exceeds 32 bits")
            });
        } else if (deltaBlocks > 0) {
            supplyState.block = safe32(
                blockNumber,
                "block number exceeds 32 bits"
            );
        }
    }

    function updateAlkBorrowIndex(address market, bool isVerified) internal {

        MarketState storage borrowState = alkBorrowState[isVerified][market];
        uint256 marketSpeed = alkSpeeds[isVerified][market];
        uint256 blockNumber = getBlockNumber();
        uint256 deltaBlocks = sub_(blockNumber, uint256(borrowState.block));
        if (deltaBlocks > 0 && marketSpeed > 0) {
            uint256 marketTotalBorrows = getMarketTotalBorrows(
                market,
                isVerified
            );
            uint256 borrowAlkAccrued = mul_(deltaBlocks, marketSpeed);
            Double memory ratio = marketTotalBorrows > 0
                ? fraction(borrowAlkAccrued, marketTotalBorrows)
                : Double({mantissa: 0});
            Double memory index = add_(
                Double({mantissa: borrowState.index}),
                ratio
            );
            alkBorrowState[isVerified][market] = MarketState({
                index: safe224(index.mantissa, "new index exceeds 224 bits"),
                block: safe32(blockNumber, "block number exceeds 32 bits")
            });
        } else if (deltaBlocks > 0) {
            borrowState.block = safe32(
                blockNumber,
                "block number exceeds 32 bits"
            );
        }
    }

    function distributeSupplierAlk(
        address market,
        address supplier,
        bool isVerified
    ) internal {

        MarketState storage supplyState = alkSupplyState[isVerified][market];
        Double memory supplyIndex = Double({mantissa: supplyState.index});
        Double memory supplierIndex = Double({
            mantissa: alkSupplierIndex[isVerified][market][supplier]
        });
        alkSupplierIndex[isVerified][market][supplier] = supplyIndex.mantissa;

        if (supplierIndex.mantissa > 0) {
            Double memory deltaIndex = sub_(supplyIndex, supplierIndex);
            uint256 supplierBalance = getSupplyBalance(
                market,
                supplier,
                isVerified
            );
            uint256 supplierDelta = mul_(supplierBalance, deltaIndex);
            alkAccrued[supplier] = add_(alkAccrued[supplier], supplierDelta);
            emit DistributedSupplierAlk(
                market,
                supplier,
                supplierDelta,
                alkAccrued[supplier],
                supplyIndex.mantissa,
                isVerified
            );
        }
    }

    function distributeBorrowerAlk(
        address market,
        address borrower,
        bool isVerified
    ) internal {

        MarketState storage borrowState = alkBorrowState[isVerified][market];
        Double memory borrowIndex = Double({mantissa: borrowState.index});
        Double memory borrowerIndex = Double({
            mantissa: alkBorrowerIndex[isVerified][market][borrower]
        });
        alkBorrowerIndex[isVerified][market][borrower] = borrowIndex.mantissa;

        if (borrowerIndex.mantissa > 0) {
            Double memory deltaIndex = sub_(borrowIndex, borrowerIndex);
            uint256 borrowerBalance = getBorrowBalance(
                market,
                borrower,
                isVerified
            );
            uint256 borrowerDelta = mul_(borrowerBalance, deltaIndex);
            alkAccrued[borrower] = add_(alkAccrued[borrower], borrowerDelta);
            emit DistributedBorrowerAlk(
                market,
                borrower,
                borrowerDelta,
                alkAccrued[borrower],
                borrowIndex.mantissa,
                isVerified
            );
        }
    }

    function claimAlk(
        address holder,
        address[] memory markets,
        bool isVerified
    ) internal {

        for (uint256 i = 0; i < markets.length; i++) {
            address market = markets[i];

            updateAlkSupplyIndex(market, isVerified);
            distributeSupplierAlk(market, holder, isVerified);

            updateAlkBorrowIndex(market, isVerified);
            distributeBorrowerAlk(market, holder, isVerified);

            alkAccrued[holder] = transferAlk(
                holder,
                alkAccrued[holder],
                market,
                isVerified
            );
        }
    }

    function transferAlk(
        address participant,
        uint256 participantAccrued,
        address market,
        bool isVerified
    ) internal returns (uint256) {

        if (participantAccrued > 0) {
            EIP20Interface alk = EIP20Interface(getAlkAddress());
            uint256 alkRemaining = alk.balanceOf(address(this));
            if (participantAccrued <= alkRemaining) {
                alk.transfer(participant, participantAccrued);
                emit TransferredAlk(
                    participant,
                    participantAccrued,
                    market,
                    isVerified
                );
                return 0;
            }
        }
        return participantAccrued;
    }


    function getBlockNumber() public view returns (uint256) {

        return block.number;
    }

    function getAlkAccrued(address participant) public view returns (uint256) {

        return alkAccrued[participant];
    }

    function getAlkAddress() public view returns (address) {

        return alkAddress;
    }

    function getAlkemiEarnAddress() public view returns (address, address) {

        return (address(alkemiEarnVerified), address(alkemiEarnPublic));
    }

    function getMarketStats(address market, bool isVerified)
        public
        view
        returns (
            bool isSupported,
            uint256 blockNumber,
            address interestRateModel,
            uint256 totalSupply,
            uint256 supplyRateMantissa,
            uint256 supplyIndex,
            uint256 totalBorrows,
            uint256 borrowRateMantissa,
            uint256 borrowIndex
        )
    {

        if (isVerified) {
            return (alkemiEarnVerified.markets(market));
        } else {
            return (alkemiEarnPublic.markets(market));
        }
    }

    function getMarketTotalSupply(address market, bool isVerified)
        public
        view
        returns (uint256)
    {

        uint256 totalSupply;
        (, , , totalSupply, , , , , ) = getMarketStats(market, isVerified);
        return totalSupply;
    }

    function getMarketTotalBorrows(address market, bool isVerified)
        public
        view
        returns (uint256)
    {

        uint256 totalBorrows;
        (, , , , , , totalBorrows, , ) = getMarketStats(market, isVerified);
        return totalBorrows;
    }

    function getSupplyBalance(
        address market,
        address supplier,
        bool isVerified
    ) public view returns (uint256) {

        if (isVerified) {
            return alkemiEarnVerified.getSupplyBalance(supplier, market);
        } else {
            return alkemiEarnPublic.getSupplyBalance(supplier, market);
        }
    }

    function getBorrowBalance(
        address market,
        address borrower,
        bool isVerified
    ) public view returns (uint256) {

        if (isVerified) {
            return alkemiEarnVerified.getBorrowBalance(borrower, market);
        } else {
            return alkemiEarnPublic.getBorrowBalance(borrower, market);
        }
    }


    function transferOwnership(address _newOwner) external onlyOwner {

        require(_newOwner != owner, "TransferOwnership: the same owner.");
        newOwner = _newOwner;
    }

    function acceptOwnership() external {

        require(
            msg.sender == newOwner,
            "AcceptOwnership: only new owner do this."
        );
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    function addMarket(address market, bool isVerified) external onlyOwner {

        require(!allMarketsIndex[isVerified][market], "Market already exists");
        require(
            allMarkets[isVerified].length < uint256(MAXIMUM_NUMBER_OF_MARKETS),
            "Exceeding the max number of markets allowed"
        );
        allMarketsIndex[isVerified][market] = true;
        allMarkets[isVerified].push(market);
        emit MarketAdded(
            market,
            add_(allMarkets[isVerified].length, allMarkets[!isVerified].length),
            isVerified
        );
    }

    function removeMarket(uint256 id, bool isVerified) external onlyOwner {

        if (id >= allMarkets[isVerified].length) {
            return;
        }
        allMarketsIndex[isVerified][allMarkets[isVerified][id]] = false;
        address removedMarket = allMarkets[isVerified][id];

        for (uint256 i = id; i < allMarkets[isVerified].length - 1; i++) {
            allMarkets[isVerified][i] = allMarkets[isVerified][i + 1];
        }
        allMarkets[isVerified].length--;
        alkSpeeds[isVerified][removedMarket] = 0;
        refreshAlkSpeeds();
        emit MarketRemoved(
            removedMarket,
            add_(allMarkets[isVerified].length, allMarkets[!isVerified].length),
            isVerified
        );
    }

    function setAlkAddress(address _alkAddress) external onlyOwner {

        require(alkAddress != _alkAddress, "The same ALK address");
        require(_alkAddress != address(0), "ALK address cannot be empty");
        alkAddress = _alkAddress;
    }

    function setAlkemiEarnVerifiedAddress(address _alkemiEarnVerified)
        external
        onlyOwner
    {

        require(
            address(alkemiEarnVerified) != _alkemiEarnVerified,
            "The same AlkemiEarnVerified address"
        );
        require(
            _alkemiEarnVerified != address(0),
            "AlkemiEarnVerified address cannot be empty"
        );
        alkemiEarnVerified = AlkemiEarnVerified(_alkemiEarnVerified);
    }

    function setAlkemiEarnPublicAddress(address _alkemiEarnPublic)
        external
        onlyOwner
    {

        require(
            address(alkemiEarnPublic) != _alkemiEarnPublic,
            "The same AlkemiEarnPublic address"
        );
        require(
            _alkemiEarnPublic != address(0),
            "AlkemiEarnPublic address cannot be empty"
        );
        alkemiEarnPublic = AlkemiEarnPublic(_alkemiEarnPublic);
    }

    function setAlkRate(uint256 _alkRate) external onlyOwner {

        alkRate = _alkRate;
    }

    function getAlkRewards(address user) external view returns (uint256) {

        uint256 alkRewards = alkAccrued[user];
        (
            Exp[] memory marketTotalLiquidity,
            Exp memory totalLiquidity
        ) = refreshMarketLiquidity();
        uint256 verifiedMarketsLength = allMarkets[true].length;
        for (uint256 i = 0; i < allMarkets[true].length; i++) {
            alkRewards = add_(
                alkRewards,
                add_(
                    getSupplyAlkRewards(
                        totalLiquidity,
                        marketTotalLiquidity,
                        user,
                        i,
                        i,
                        true
                    ),
                    getBorrowAlkRewards(
                        totalLiquidity,
                        marketTotalLiquidity,
                        user,
                        i,
                        i,
                        true
                    )
                )
            );
        }
        for (uint256 j = 0; j < allMarkets[false].length; j++) {
            uint256 index = verifiedMarketsLength + j;
            alkRewards = add_(
                alkRewards,
                add_(
                    getSupplyAlkRewards(
                        totalLiquidity,
                        marketTotalLiquidity,
                        user,
                        index,
                        j,
                        false
                    ),
                    getBorrowAlkRewards(
                        totalLiquidity,
                        marketTotalLiquidity,
                        user,
                        index,
                        j,
                        false
                    )
                )
            );
        }
        return alkRewards;
    }

    function getSupplyAlkRewards(
        Exp memory totalLiquidity,
        Exp[] memory marketTotalLiquidity,
        address user,
        uint256 i,
        uint256 j,
        bool isVerified
    ) internal view returns (uint256) {

        uint256 newSpeed = totalLiquidity.mantissa > 0
            ? mul_(alkRate, div_(marketTotalLiquidity[i], totalLiquidity))
            : 0;
        MarketState memory supplyState = alkSupplyState[isVerified][
            allMarkets[isVerified][j]
        ];
        if (
            sub_(getBlockNumber(), uint256(supplyState.block)) > 0 &&
            newSpeed > 0
        ) {
            Double memory index = add_(
                Double({mantissa: supplyState.index}),
                (
                    getMarketTotalSupply(
                        allMarkets[isVerified][j],
                        isVerified
                    ) > 0
                        ? fraction(
                            mul_(
                                sub_(
                                    getBlockNumber(),
                                    uint256(supplyState.block)
                                ),
                                newSpeed
                            ),
                            getMarketTotalSupply(
                                allMarkets[isVerified][j],
                                isVerified
                            )
                        )
                        : Double({mantissa: 0})
                )
            );
            supplyState = MarketState({
                index: safe224(index.mantissa, "new index exceeds 224 bits"),
                block: safe32(getBlockNumber(), "block number exceeds 32 bits")
            });
        } else if (sub_(getBlockNumber(), uint256(supplyState.block)) > 0) {
            supplyState.block = safe32(
                getBlockNumber(),
                "block number exceeds 32 bits"
            );
        }

        if (
            isVerified &&
            Double({
                mantissa: alkSupplierIndex[isVerified][
                    allMarkets[isVerified][j]
                ][user]
            }).mantissa >
            0
        ) {
            return
                mul_(
                    alkemiEarnVerified.getSupplyBalance(
                        user,
                        allMarkets[isVerified][j]
                    ),
                    sub_(
                        Double({mantissa: supplyState.index}),
                        Double({
                            mantissa: alkSupplierIndex[isVerified][
                                allMarkets[isVerified][j]
                            ][user]
                        })
                    )
                );
        }
        if (
            !isVerified &&
            Double({
                mantissa: alkSupplierIndex[isVerified][
                    allMarkets[isVerified][j]
                ][user]
            }).mantissa >
            0
        ) {
            return
                mul_(
                    alkemiEarnPublic.getSupplyBalance(
                        user,
                        allMarkets[isVerified][j]
                    ),
                    sub_(
                        Double({mantissa: supplyState.index}),
                        Double({
                            mantissa: alkSupplierIndex[isVerified][
                                allMarkets[isVerified][j]
                            ][user]
                        })
                    )
                );
        } else {
            return 0;
        }
    }

    function getBorrowAlkRewards(
        Exp memory totalLiquidity,
        Exp[] memory marketTotalLiquidity,
        address user,
        uint256 i,
        uint256 j,
        bool isVerified
    ) internal view returns (uint256) {

        uint256 newSpeed = totalLiquidity.mantissa > 0
            ? mul_(alkRate, div_(marketTotalLiquidity[i], totalLiquidity))
            : 0;
        MarketState memory borrowState = alkBorrowState[isVerified][
            allMarkets[isVerified][j]
        ];
        if (
            sub_(getBlockNumber(), uint256(borrowState.block)) > 0 &&
            newSpeed > 0
        ) {
            Double memory index = add_(
                Double({mantissa: borrowState.index}),
                (
                    getMarketTotalBorrows(
                        allMarkets[isVerified][j],
                        isVerified
                    ) > 0
                        ? fraction(
                            mul_(
                                sub_(
                                    getBlockNumber(),
                                    uint256(borrowState.block)
                                ),
                                newSpeed
                            ),
                            getMarketTotalBorrows(
                                allMarkets[isVerified][j],
                                isVerified
                            )
                        )
                        : Double({mantissa: 0})
                )
            );
            borrowState = MarketState({
                index: safe224(index.mantissa, "new index exceeds 224 bits"),
                block: safe32(getBlockNumber(), "block number exceeds 32 bits")
            });
        } else if (sub_(getBlockNumber(), uint256(borrowState.block)) > 0) {
            borrowState.block = safe32(
                getBlockNumber(),
                "block number exceeds 32 bits"
            );
        }

        if (
            Double({
                mantissa: alkBorrowerIndex[isVerified][
                    allMarkets[isVerified][j]
                ][user]
            }).mantissa >
            0 &&
            isVerified
        ) {
            return
                mul_(
                    alkemiEarnVerified.getBorrowBalance(
                        user,
                        allMarkets[isVerified][j]
                    ),
                    sub_(
                        Double({mantissa: borrowState.index}),
                        Double({
                            mantissa: alkBorrowerIndex[isVerified][
                                allMarkets[isVerified][j]
                            ][user]
                        })
                    )
                );
        }
        if (
            Double({
                mantissa: alkBorrowerIndex[isVerified][
                    allMarkets[isVerified][j]
                ][user]
            }).mantissa >
            0 &&
            !isVerified
        ) {
            return
                mul_(
                    alkemiEarnPublic.getBorrowBalance(
                        user,
                        allMarkets[isVerified][j]
                    ),
                    sub_(
                        Double({mantissa: borrowState.index}),
                        Double({
                            mantissa: alkBorrowerIndex[isVerified][
                                allMarkets[isVerified][j]
                            ][user]
                        })
                    )
                );
        } else {
            return 0;
        }
    }
}