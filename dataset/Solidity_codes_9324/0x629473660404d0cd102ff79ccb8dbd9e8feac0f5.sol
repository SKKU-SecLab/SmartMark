
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT
pragma solidity >=0.8.0;

contract BondtrollerErrorReporter {

    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        BONDTROLLER_MISMATCH,
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
        ACCRUE_INTEREST_ACCUMULATED_INTEREST_CALCULATION_FAILED,
        ACCRUE_INTEREST_BORROW_RATE_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_BORROWS_CALCULATION_FAILED,
        ACCRUE_INTEREST_NEW_TOTAL_RESERVES_CALCULATION_FAILED,
        ACCRUE_INTEREST_SIMPLE_INTEREST_FACTOR_CALCULATION_FAILED,
        BORROW_ACCUMULATED_BALANCE_CALCULATION_FAILED,
        BORROW_ACCRUE_INTEREST_FAILED,
        BORROW_CASH_NOT_AVAILABLE,
        BORROW_FRESHNESS_CHECK,
        BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
        BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
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
        LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED,
        LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED,
        LIQUIDATE_SEIZE_COMPTROLLER_REJECTION,
        LIQUIDATE_SEIZE_LIQUIDATOR_IS_BORROWER,
        LIQUIDATE_SEIZE_TOO_MUCH,
        MINT_ACCRUE_INTEREST_FAILED,
        MINT_COMPTROLLER_REJECTION,
        MINT_EXCHANGE_CALCULATION_FAILED,
        MINT_EXCHANGE_RATE_READ_FAILED,
        MINT_FRESHNESS_CHECK,
        MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED,
        MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED,
        MINT_TRANSFER_IN_FAILED,
        MINT_TRANSFER_IN_NOT_POSSIBLE,
        REDEEM_ACCRUE_INTEREST_FAILED,
        REDEEM_COMPTROLLER_REJECTION,
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
        REPAY_BORROW_COMPTROLLER_REJECTION,
        REPAY_BORROW_FRESHNESS_CHECK,
        REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED,
        REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED,
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
        TRANSFER_NOT_ENOUGH,
        TRANSFER_TOO_MUCH,
        ADD_RESERVES_ACCRUE_INTEREST_FAILED,
        ADD_RESERVES_FRESH_CHECK,
        ADD_RESERVES_TRANSFER_IN_NOT_POSSIBLE
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
}// MIT
pragma solidity >=0.8.0;

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
}// MIT
pragma solidity >=0.8.0;



contract BondtrollerV1Storage {

    bool public constant isBondtroller = true;

    address public admin;

    address public oracle;

    uint public closeFactorMantissa;

    uint public liquidationIncentiveMantissa;

    uint public maxAssets;

    mapping(address => BToken[]) public accountAssets;

}

contract BondtrollerV2Storage is BondtrollerV1Storage {

    struct Market {
        bool isListed;

        uint collateralFactorMantissa;

       
        bool isComped;
    }

    mapping(address => mapping( address => bool)) public accountMembership;//user address => BToken address => isListed

    mapping(address => Market) public markets;

   

    address public pauseGuardian;
    bool public _mintGuardianPaused;
    bool public _borrowGuardianPaused;
    bool public transferGuardianPaused;
    bool public seizeGuardianPaused;
    mapping(address => bool) public mintGuardianPaused;
    mapping(address => bool) public borrowGuardianPaused;
}

contract BondtrollerV3Storage is BondtrollerV2Storage {

    struct CompMarketState {
        uint224 index;

        uint32 block;
    }

    BToken[] public allMarkets;

    uint public compRate;

    mapping(address => uint) public compSpeeds;

    mapping(address => CompMarketState) public compSupplyState;

    mapping(address => CompMarketState) public compBorrowState;

    mapping(address => mapping(address => uint)) public compSupplierIndex;

    mapping(address => mapping(address => uint)) public compBorrowerIndex;

    mapping(address => uint) public compAccrued;
}

contract BondtrollerV4Storage is BondtrollerV3Storage {

    address public borrowCapGuardian;

    mapping(address => uint) public borrowCaps;
}

contract BondtrollerV5Storage is BondtrollerV4Storage {

    mapping(address => uint) public compContributorSpeeds;

    mapping(address => uint) public lastContributorBlock;

}//MIT
pragma solidity >=0.8.0;

interface IPriceProviderAggregator {

    
    function MODERATOR_ROLE() external view returns(bytes32);

    
    function usdDecimals() external view returns(uint8);


    function tokenPriceProvider(address projectToken) external view returns(address priceProvider, bool hasSignedFunction);


    event GrandModeratorRole(address indexed who, address indexed newModerator);
    event RevokeModeratorRole(address indexed who, address indexed moderator);
    event SetTokenAndPriceProvider(address indexed who, address indexed token, address indexed priceProvider);
    event ChangeActive(address indexed who, address indexed priceProvider, address indexed token, bool active);

    function initialize() external;



    function grandModerator(address newModerator) external;


    function revokeModerator(address moderator) external;




    function setTokenAndPriceProvider(address token, address priceProvider, bool hasFunctionWithSign) external;


    function changeActive(address priceProvider, address token, bool active) external;



    function getPrice(address token) external view returns(uint256 priceMantissa, uint8 priceDecimals);


    function getPriceSigned(address token, uint256 _priceMantissa, uint8 _priceDecimals, uint256 validTo, bytes memory signature) external view returns(uint256 priceMantissa, uint8 priceDecimals);


    function getEvaluation(address token, uint256 tokenAmount) external view returns(uint256 evaluation);

    
    function getEvaluationSigned(address token, uint256 tokenAmount, uint256 priceMantissa, uint8 priceDecimals, uint256 validTo, bytes memory signature) external view returns(uint256 evaluation);


}// MIT
pragma solidity >=0.8.0;



contract Bondtroller is BondtrollerV5Storage, BondtrollerErrorReporter, ExponentialNoError, Initializable {

   
    event MarketListed(BToken bToken);

    event MarketEntered(BToken bToken, address account);

    event MarketExited(BToken bToken, address account);

    event NewPriceOracle(address oldPriceOracle, address newPriceOracle);

    event NewPauseGuardian(address oldPauseGuardian, address newPauseGuardian);

    event ActionPaused(string action, bool pauseState);

    event ActionPaused(BToken bToken, string action, bool pauseState);

    event NewBorrowCap(BToken indexed bToken, uint newBorrowCap);

    event NewBorrowCapGuardian(address oldBorrowCapGuardian, address newBorrowCapGuardian);

    event CompGranted(address recipient, uint amount);

    event NewPrimaryIndexToken(address oldPrimaryIndexToken, address newPrimaryIndexToken);

    address public primaryIndexToken;

    function init() public initializer{

        admin = msg.sender;
        setPauseGuardian(admin);
    }

    modifier onlyPrimaryIndexToken(){

        require(msg.sender == primaryIndexToken);
        _;
    }

    function getPrimaryIndexTokenAddress() external view returns(address){

        return primaryIndexToken;
    }


    function getAssetsIn(address account) external view returns (BToken[] memory) {

        BToken[] memory assetsIn = accountAssets[account];

        return assetsIn;
    }

    function checkMembership(address account, BToken bToken) external view returns (bool) {

        return accountMembership[account][address(bToken)];
    }

    function enterMarkets(address[] memory bTokens) public onlyPrimaryIndexToken returns (uint[] memory) {

        uint len = bTokens.length;

        uint[] memory results = new uint[](len);
        for (uint i = 0; i < len; i++) {
            BToken bToken = BToken(bTokens[i]);

            results[i] = uint(addToMarketInternal(bToken, msg.sender));
        }

        return results;
    }

    function enterMarket(address bToken, address borrower) public onlyPrimaryIndexToken returns(Error) {

        return addToMarketInternal(BToken(bToken), borrower);
    }

    function addToMarketInternal(BToken bToken, address borrower) internal returns (Error) {

        Market storage marketToJoin = markets[address(bToken)];

        if (!marketToJoin.isListed) {
            return Error.MARKET_NOT_LISTED;
        }

        if (accountMembership[borrower][address(bToken)] == true) {
            return Error.NO_ERROR;
        }

        accountMembership[borrower][address(bToken)] = true;
        accountAssets[borrower].push(bToken);

        emit MarketEntered(bToken, borrower);

        return Error.NO_ERROR;
    }

    function exitMarket(address cTokenAddress) external onlyPrimaryIndexToken returns (uint) {

        BToken bToken = BToken(cTokenAddress);
        (uint oErr, uint tokensHeld, uint amountOwed, ) = bToken.getAccountSnapshot(msg.sender);
        require(oErr == 0, "exitMarket: getAccountSnapshot failed"); // semi-opaque error code

        if (amountOwed != 0) {
            return fail(Error.NONZERO_BORROW_BALANCE, FailureInfo.EXIT_MARKET_BALANCE_OWED);
        }

        uint allowed = redeemAllowedInternal(cTokenAddress, msg.sender, tokensHeld);
        if (allowed != 0) {
            return failOpaque(Error.REJECTION, FailureInfo.EXIT_MARKET_REJECTION, allowed);
        }


        if (!accountMembership[msg.sender][address(bToken)]) {
            return uint(Error.NO_ERROR);
        }

        delete accountMembership[msg.sender][address(bToken)];

        BToken[] memory userAssetList = accountAssets[msg.sender];
        uint len = userAssetList.length;
        uint assetIndex = len;
        for (uint i = 0; i < len; i++) {
            if (userAssetList[i] == bToken) {
                assetIndex = i;
                break;
            }
        }

        assert(assetIndex < len);

        BToken[] storage storedList = accountAssets[msg.sender];
        storedList[assetIndex] = storedList[storedList.length - 1];
        storedList.pop();

        emit MarketExited(bToken, msg.sender);

        return uint(Error.NO_ERROR);
    }


    function mintAllowed(address bToken, address minter, uint mintAmount) external view returns (uint) {

        bToken;
        minter;
        mintAmount;

        require(!mintGuardianPaused[bToken], "mint is paused");

        minter;
        mintAmount;

        if (!markets[bToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }


        return uint(Error.NO_ERROR);
    }

    function mintVerify(address bToken, address minter, uint actualMintAmount, uint mintTokens) external {

        bToken;
        minter;
        actualMintAmount;
        mintTokens;

        if (false) {
            maxAssets = maxAssets;
        }
    }

    function redeemAllowed(address bToken, address redeemer, uint redeemTokens) external view returns (uint) {

        bToken; 
        redeemer; 
        redeemTokens;

        uint allowed = redeemAllowedInternal(bToken, redeemer, redeemTokens);
        if (allowed != uint(Error.NO_ERROR)){
            return allowed;
        }

        return uint(Error.NO_ERROR);
    }

    function redeemAllowedInternal(address bToken, address redeemer, uint redeemTokens) internal view returns (uint) {

        redeemTokens;
        
        if (!markets[bToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }

        if (!accountMembership[redeemer][address(bToken)]) {
            return uint(Error.NO_ERROR);
        }

        return uint(Error.NO_ERROR);
    }

    function redeemVerify(address bToken, address redeemer, uint redeemAmount, uint redeemTokens) external pure {

        bToken;
        redeemer;

        if (redeemTokens == 0 && redeemAmount > 0) {
            revert("redeemTokens zero");
        }
    }

    function borrowAllowed(address bToken, address borrower, uint borrowAmount) external returns (uint) {

        require(!borrowGuardianPaused[bToken], "borrow is paused");

        if (!markets[bToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }

        if (!accountMembership[borrower][address(bToken)]) {

            Error errAddMarketInternal = addToMarketInternal(BToken(msg.sender), borrower);
            if (errAddMarketInternal != Error.NO_ERROR) {
                return uint(errAddMarketInternal);
            }

            assert(accountMembership[borrower][address(bToken)]);
        }



        uint borrowCap = borrowCaps[bToken];
        if (borrowCap != 0) {
            uint totalBorrows = BToken(bToken).totalBorrows();
            uint nextTotalBorrows = add_(totalBorrows, borrowAmount);
            require(nextTotalBorrows < borrowCap, "market borrow cap reached");
        }
        return uint(Error.NO_ERROR);
    }

    function borrowVerify(address bToken, address borrower, uint borrowAmount) external {

        bToken;
        borrower;
        borrowAmount;

        if (false) {
            maxAssets = maxAssets;
        }
    }

    function repayBorrowAllowed(
        address bToken,
        address payer,
        address borrower,
        uint repayAmount) external view returns (uint) {

        payer;
        borrower;
        repayAmount;

        if (!markets[bToken].isListed) {
            return uint(Error.MARKET_NOT_LISTED);
        }


        return uint(Error.NO_ERROR);
    }

    function repayBorrowVerify(
        address bToken,
        address payer,
        address borrower,
        uint actualRepayAmount,
        uint borrowerIndex) external {

        bToken;
        payer;
        borrower;
        actualRepayAmount;
        borrowerIndex;

        if (false) {
            maxAssets = maxAssets;
        }
    }

    function transferAllowed(address bToken, address src, address dst, uint transferTokens) external returns (uint) {

        bToken;src;dst;transferTokens;
        
        require(!transferGuardianPaused, "transfer is paused");


        if (false) {
            maxAssets = maxAssets;
        }

        return uint(Error.NO_ERROR);
    }

    function transferVerify(address bToken, address src, address dst, uint transferTokens) external onlyPrimaryIndexToken {

        bToken;
        src;
        dst;
        transferTokens;

        if (false) {
            maxAssets = maxAssets;
        }
    }


    function setPriceOracle(address newOracle) public returns (uint) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PRICE_ORACLE_OWNER_CHECK);
        }

        address oldOracle = oracle;

        oracle = newOracle;

        emit NewPriceOracle(oldOracle, newOracle);

        return uint(Error.NO_ERROR);
    }

    function setPrimaryIndexTokenAddress(address _newPrimaryIndexToken) external returns(uint){

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_LIQUIDATION_INCENTIVE_OWNER_CHECK);
        }

        address oldPrimaryIndexToken = primaryIndexToken;

        primaryIndexToken = _newPrimaryIndexToken;

        emit NewPrimaryIndexToken(oldPrimaryIndexToken, _newPrimaryIndexToken);
        
        return uint(Error.NO_ERROR);
    }

    function supportMarket(BToken bToken) external returns (uint) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SUPPORT_MARKET_OWNER_CHECK);
        }

        if (markets[address(bToken)].isListed) {
            return fail(Error.MARKET_ALREADY_LISTED, FailureInfo.SUPPORT_MARKET_EXISTS);
        }

        bToken.isCToken(); // Sanity check to make sure its really a BToken

        markets[address(bToken)] = Market({isListed: true, isComped: false, collateralFactorMantissa: 0});

        _addMarketInternal(address(bToken));

        emit MarketListed(bToken);

        return uint(Error.NO_ERROR);
    }

    function _addMarketInternal(address bToken) internal {

        for (uint i = 0; i < allMarkets.length; i ++) {
            require(allMarkets[i] != BToken(bToken), "market already added");
        }
        allMarkets.push(BToken(bToken));
    }

    function setMarketBorrowCaps(BToken[] calldata bTokens, uint[] calldata newBorrowCaps) external {

    	require(msg.sender == admin || msg.sender == borrowCapGuardian, "only admin or borrow cap guardian can set borrow caps"); 

        uint numMarkets = bTokens.length;
        uint numBorrowCaps = newBorrowCaps.length;

        require(numMarkets != 0 && numMarkets == numBorrowCaps, "invalid input");

        for(uint i = 0; i < numMarkets; i++) {
            borrowCaps[address(bTokens[i])] = newBorrowCaps[i];
            emit NewBorrowCap(bTokens[i], newBorrowCaps[i]);
        }
    }

    function setBorrowCapGuardian(address newBorrowCapGuardian) external {

        require(msg.sender == admin, "only admin can set borrow cap guardian");

        address oldBorrowCapGuardian = borrowCapGuardian;

        borrowCapGuardian = newBorrowCapGuardian;

        emit NewBorrowCapGuardian(oldBorrowCapGuardian, newBorrowCapGuardian);
    }

    function setPauseGuardian(address newPauseGuardian) public returns (uint) {

        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_PAUSE_GUARDIAN_OWNER_CHECK);
        }

        address oldPauseGuardian = pauseGuardian;

        pauseGuardian = newPauseGuardian;

        emit NewPauseGuardian(oldPauseGuardian, pauseGuardian);

        return uint(Error.NO_ERROR);
    }

    function setMintPaused(BToken bToken, bool state) public returns (bool) {

        require(markets[address(bToken)].isListed, "cannot pause a market that is not listed");
        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause");
        require(msg.sender == admin || state == true, "only admin can unpause");

        mintGuardianPaused[address(bToken)] = state;
        emit ActionPaused(bToken, "Mint", state);
        return state;
    }

    function setBorrowPaused(BToken bToken, bool state) public returns (bool) {

        require(markets[address(bToken)].isListed, "cannot pause a market that is not listed");
        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause");
        require(msg.sender == admin || state == true, "only admin can unpause");

        borrowGuardianPaused[address(bToken)] = state;
        emit ActionPaused(bToken, "Borrow", state);
        return state;
    }

    function setTransferPaused(bool state) public returns (bool) {

        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause");
        require(msg.sender == admin || state == true, "only admin can unpause");

        transferGuardianPaused = state;
        emit ActionPaused("Transfer", state);
        return state;
    }

    function setSeizePaused(bool state) public returns (bool) {

        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause");
        require(msg.sender == admin || state == true, "only admin can unpause");

        seizeGuardianPaused = state;
        emit ActionPaused("Seize", state);
        return state;
    }

    function adminOrInitializing() internal view returns (bool) {

        return msg.sender == admin;
    }

    function getAllMarkets() public view returns (BToken[] memory) {

        return allMarkets;
    }

    function isDeprecated(BToken bToken) public view returns (bool) {

        return
            markets[address(bToken)].collateralFactorMantissa == 0 && 
            borrowGuardianPaused[address(bToken)] == true && 
            bToken.reserveFactorMantissa() == 1e18
        ;
    }

    function getBlockNumber() public view returns (uint) {

        return block.number;
    }

}// MIT
pragma solidity >=0.8.0;

abstract contract InterestRateModel {
    bool public constant isInterestRateModel = true;

    function getBorrowRate(uint cash, uint borrows, uint reserves) external virtual view returns (uint);

    function getSupplyRate(uint cash, uint borrows, uint reserves, uint reserveFactorMantissa) external virtual view returns (uint);

}// MIT
pragma solidity >=0.8.0;

interface EIP20NonStandardInterface {


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256 balance);



    function transfer(address dst, uint256 amount) external;



    function transferFrom(address src, address dst, uint256 amount) external;


    function approve(address spender, uint256 amount) external returns (bool success);


    function allowance(address owner, address spender) external view returns (uint256 remaining);


    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}// MIT
pragma solidity >=0.8.0;


contract BTokenStorage {

    bool internal _notEntered;

    string public name;

    string public symbol;

    uint8 public decimals;


    uint internal constant borrowRateMaxMantissa = 0.0005e16;

    uint internal constant reserveFactorMaxMantissa = 1e18;

    address payable public admin;

    address payable public pendingAdmin;

    Bondtroller public bondtroller;

    InterestRateModel public interestRateModel;

    uint internal initialExchangeRateMantissa;

    uint public reserveFactorMantissa;

    uint public accrualBlockNumber;

    uint public borrowIndex;

    uint public totalBorrows;

    uint public totalReserves;

    uint public totalSupply;

    mapping (address => uint) public accountTokens;

    mapping (address => mapping (address => uint)) internal transferAllowances;

    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }

    mapping(address => BorrowSnapshot) internal accountBorrows;

    uint public constant protocolSeizeShareMantissa = 2.8e16; //2.8%

}

abstract contract BTokenInterface is BTokenStorage {
    bool public constant isCToken = true;



    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);

    event Mint(address minter, uint mintAmount, uint mintTokens);

    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens);

    event Borrow(address borrower, uint borrowAmount, uint accountBorrows, uint totalBorrows);

    event RepayBorrow(address payer, address borrower, uint repayAmount, uint accountBorrows, uint totalBorrows);

    event LiquidateBorrow(address liquidator, address borrower, uint repayAmount, address cTokenCollateral, uint seizeTokens);



    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);

    event NewBondtroller(Bondtroller oldBondtroller, Bondtroller newBondtroller);

    event NewMarketInterestRateModel(InterestRateModel oldInterestRateModel, InterestRateModel newInterestRateModel);

    event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);

    event ReservesAdded(address benefactor, uint addAmount, uint newTotalReserves);

    event ReservesReduced(address admin, uint reduceAmount, uint newTotalReserves);

    event Transfer(address indexed from, address indexed to, uint amount);

    event Approval(address indexed owner, address indexed spender, uint amount);




    function transfer(address dst, uint amount) external virtual returns (bool);
    function transferFrom(address src, address dst, uint amount) external virtual returns (bool);
    function approve(address spender, uint amount) external  virtual returns (bool);
    function allowance(address owner, address spender) external  virtual view returns (uint);
    function balanceOf(address owner) external  virtual view returns (uint);
    function balanceOfUnderlying(address owner) external virtual  returns (uint);
    function getAccountSnapshot(address account) external  virtual  view returns (uint, uint, uint, uint);
    function borrowRatePerBlock() external virtual  view returns (uint);
    function supplyRatePerBlock() external virtual  view returns (uint);
    function totalBorrowsCurrent() external virtual  returns (uint);
    function borrowBalanceCurrent(address account) external virtual  returns (uint);
    function borrowBalanceStored(address account) public virtual  view returns (uint);
    function exchangeRateCurrent() public virtual  returns (uint);
    function exchangeRateStored() public virtual  view returns (uint);
    function getCash() external virtual  view returns (uint);
    function accrueInterest() public virtual  returns (uint);


    function _setBondtroller(Bondtroller newBondtroller) public virtual  returns (uint);
    function _setReserveFactor(uint newReserveFactorMantissa) external virtual  returns (uint);
    function _reduceReserves(uint reduceAmount) external virtual  returns (uint);
    function _setInterestRateModel(InterestRateModel newInterestRateModel) public virtual  returns (uint);
}

contract BErc20Storage {

    address public underlying;
}

abstract contract BErc20Interface is BErc20Storage {


   function sweepToken(EIP20NonStandardInterface token) external virtual ;



    function _addReserves(uint addAmount) external virtual  returns (uint);
}// MIT
pragma solidity >=0.8.0;

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
}// MIT
pragma solidity >=0.8.0;


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
}// MIT
pragma solidity >=0.8.0;


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
}// MIT
pragma solidity >=0.8.0;


abstract contract BToken is BTokenInterface, Exponential, TokenErrorReporter {
    function initialize(Bondtroller bondtroller_,
                        InterestRateModel interestRateModel_,
                        uint initialExchangeRateMantissa_,
                        string memory name_,
                        string memory symbol_,
                        uint8 decimals_) public {
        require(msg.sender == admin, "only admin may initialize the market");
        require(accrualBlockNumber == 0 && borrowIndex == 0, "market may only be initialized once");

        initialExchangeRateMantissa = initialExchangeRateMantissa_;
        require(initialExchangeRateMantissa > 0, "initial exchange rate must be greater than zero.");

        uint err = _setBondtroller(bondtroller_);
        require(err == uint(Error.NO_ERROR), "setting bondtroller failed");

        accrualBlockNumber = getBlockNumber();
        borrowIndex = mantissaOne;

        err = _setInterestRateModelFresh(interestRateModel_);
        require(err == uint(Error.NO_ERROR), "setting interest rate model failed");

        name = name_;
        symbol = symbol_;
        decimals = decimals_;

        _notEntered = true;
    }


    function transferTokens(address spender, address src, address dst, uint tokens) internal returns (uint) {
        uint allowed = bondtroller.transferAllowed(address(this), src, dst, tokens);
        if (allowed != 0) {
            return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.TRANSFER_COMPTROLLER_REJECTION, allowed);
        }

        if (src == dst) {
            return fail(Error.BAD_INPUT, FailureInfo.TRANSFER_NOT_ALLOWED);
        }

        uint startingAllowance = 0;
        if (spender == src) {
            startingAllowance = ((2**256) - 1);
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

        if (startingAllowance != ((2**256) - 1)) {
            transferAllowances[src][spender] = allowanceNew;
        }

        emit Transfer(src, dst, tokens);


        return uint(Error.NO_ERROR);
    }

    function transfer(address dst, uint256 amount) external override nonReentrant returns (bool) {
        return transferTokens(msg.sender, msg.sender, dst, amount) == uint(Error.NO_ERROR);
    }

    function transferFrom(address src, address dst, uint256 amount) external override  nonReentrant returns (bool) {
        return transferTokens(msg.sender, src, dst, amount) == uint(Error.NO_ERROR);
    }

    function approve(address spender, uint256 amount) external override  returns (bool) {
        address src = msg.sender;
        transferAllowances[src][spender] = amount;
        emit Approval(src, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external override  view returns (uint256) {
        return transferAllowances[owner][spender];
    }

    function balanceOf(address owner) external override  view returns (uint256) {
        return accountTokens[owner];
    }

    function balanceOfUnderlying(address owner) external override  returns (uint) {
        Exp memory exchangeRate = Exp({mantissa: exchangeRateCurrent()});
        (MathError mErr, uint balance) = mulScalarTruncate(exchangeRate, accountTokens[owner]);
        require(mErr == MathError.NO_ERROR, "balance could not be calculated");
        return balance;
    }

    function balanceOfUnderlyingView(address owner) external view returns(uint){
        Exp memory exchangeRate = Exp({mantissa: exchangeRateStored()});
        (MathError mErr, uint balance) = mulScalarTruncate(exchangeRate, accountTokens[owner]);
        require(mErr == MathError.NO_ERROR, "balance could not be calculated");
        return balance;
    }

    function getAccountSnapshot(address account) external override  view returns (uint, uint, uint, uint) {
        uint cTokenBalance = accountTokens[account];
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

        return (uint(Error.NO_ERROR), cTokenBalance, borrowBalance, exchangeRateMantissa);
    }

    function getBlockNumber() internal view returns (uint) {
        return block.number;
    }

    function borrowRatePerBlock() external override  view returns (uint) {
        return interestRateModel.getBorrowRate(getCashPrior(), totalBorrows, totalReserves);
    }

    function supplyRatePerBlock() external override  view returns (uint) {
        return interestRateModel.getSupplyRate(getCashPrior(), totalBorrows, totalReserves, reserveFactorMantissa);
    }

    function totalBorrowsCurrent() external override  nonReentrant returns (uint) {
        require(accrueInterest() == uint(Error.NO_ERROR), "accrue interest failed");
        return totalBorrows;
    }

    function borrowBalanceCurrent(address account) external override  nonReentrant returns (uint) {
        require(accrueInterest() == uint(Error.NO_ERROR), "accrue interest failed");
        return borrowBalanceStored(account);
    }

    function borrowBalanceStored(address account) public override  view returns (uint) {
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

    function exchangeRateCurrent() public override  nonReentrant returns (uint) {
        require(accrueInterest() == uint(Error.NO_ERROR), "accrue interest failed");
        return exchangeRateStored();
    }

    function exchangeRateStored() public override  view returns (uint) {
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

    function getCash() external  override view returns (uint) {
        return getCashPrior();
    }

    function accrueInterest() public  override returns (uint) {
        uint currentBlockNumber = getBlockNumber();
        uint accrualBlockNumberPrior = accrualBlockNumber;

        if (accrualBlockNumberPrior == currentBlockNumber) {
            return uint(Error.NO_ERROR);
        }

        uint cashPrior = getCashPrior();
        uint borrowsPrior = totalBorrows;
        uint reservesPrior = totalReserves;
        uint borrowIndexPrior = borrowIndex;

        uint borrowRateMantissa = interestRateModel.getBorrowRate(cashPrior, borrowsPrior, reservesPrior);
        require(borrowRateMantissa <= borrowRateMaxMantissa, "borrow rate is absurdly high");

        (MathError mathErr, uint blockDelta) = subUInt(currentBlockNumber, accrualBlockNumberPrior);
        require(mathErr == MathError.NO_ERROR, "could not calculate block delta");


        Exp memory simpleInterestFactor;
        uint interestAccumulated;
        uint totalBorrowsNew;
        uint totalReservesNew;
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

        (mathErr, borrowIndexNew) = mulScalarTruncateAddUInt(simpleInterestFactor, borrowIndexPrior, borrowIndexPrior);
        if (mathErr != MathError.NO_ERROR) {
            return failOpaque(Error.MATH_ERROR, FailureInfo.ACCRUE_INTEREST_NEW_BORROW_INDEX_CALCULATION_FAILED, uint(mathErr));
        }


        accrualBlockNumber = currentBlockNumber;
        borrowIndex = borrowIndexNew;
        totalBorrows = totalBorrowsNew;
        totalReserves = totalReservesNew;

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
        uint allowed = bondtroller.mintAllowed(address(this), minter, mintAmount);
        if (allowed != 0) {
            return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.MINT_COMPTROLLER_REJECTION, allowed), 0);
        }

        if (accrualBlockNumber != getBlockNumber()) {
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

        (vars.mathErr, vars.totalSupplyNew) = addUInt(totalSupply, vars.mintTokens);
        require(vars.mathErr == MathError.NO_ERROR, "MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED");

        (vars.mathErr, vars.accountTokensNew) = addUInt(accountTokens[minter], vars.mintTokens);
        require(vars.mathErr == MathError.NO_ERROR, "MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED");

        totalSupply = vars.totalSupplyNew;
        accountTokens[minter] = vars.accountTokensNew;

        emit Mint(minter, vars.actualMintAmount, vars.mintTokens);
        emit Transfer(address(this), minter, vars.mintTokens);


        return (uint(Error.NO_ERROR), vars.actualMintAmount);
    }

    function redeemInternal(uint redeemTokens) internal nonReentrant returns (uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
        }
        return redeemFresh(payable(msg.sender), redeemTokens, 0);
    }

    function redeemUnderlyingInternal(uint redeemAmount) internal nonReentrant returns (uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
        }
        return redeemFresh(payable(msg.sender), 0, redeemAmount);
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

        uint allowed = bondtroller.redeemAllowed(address(this), redeemer, vars.redeemTokens);
        if (allowed != 0) {
            return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.REDEEM_COMPTROLLER_REJECTION, allowed);
        }

        if (accrualBlockNumber != getBlockNumber()) {
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

        bondtroller.redeemVerify(address(this), redeemer, vars.redeemAmount, vars.redeemTokens);

        return uint(Error.NO_ERROR);
    }

    function borrowInternal(uint borrowAmount) internal nonReentrant returns (uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.BORROW_ACCRUE_INTEREST_FAILED);
        }
        return borrowFresh(payable(msg.sender), borrowAmount);
    }

    struct BorrowLocalVars {
        MathError mathErr;
        uint accountBorrows;
        uint accountBorrowsNew;
        uint totalBorrowsNew;
    }

   

    function borrowFresh(address payable borrower, uint borrowAmount) internal returns (uint) {
        uint allowed = bondtroller.borrowAllowed(address(this), borrower, borrowAmount);
        if (allowed != 0) {
            return failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.BORROW_COMPTROLLER_REJECTION, allowed);
        }

        if (accrualBlockNumber != getBlockNumber()) {
            return fail(Error.MARKET_NOT_FRESH, FailureInfo.BORROW_FRESHNESS_CHECK);
        }

        if (getCashPrior() < borrowAmount) {
            revert("Insufficient cash");
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
        uint allowed = bondtroller.repayBorrowAllowed(address(this), payer, borrower, repayAmount);
        if (allowed != 0) {
            return (failOpaque(Error.COMPTROLLER_REJECTION, FailureInfo.REPAY_BORROW_COMPTROLLER_REJECTION, allowed), 0);
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

        if (repayAmount == ((2**256) - 1)) {
            vars.repayAmount = vars.accountBorrows;
        } else {
            vars.repayAmount = repayAmount;
        }


        vars.actualRepayAmount = doTransferIn(payer, vars.repayAmount);

        (vars.mathErr, vars.accountBorrowsNew) = subUInt(vars.accountBorrows, vars.actualRepayAmount);
        require(vars.mathErr == MathError.NO_ERROR, "REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED");

        (vars.mathErr, vars.totalBorrowsNew) = subUInt(totalBorrows, vars.actualRepayAmount);
        if(vars.mathErr == MathError.INTEGER_UNDERFLOW) {
            vars.totalBorrowsNew = 0; // Repaid all borrows to platform
        }

        accountBorrows[borrower].principal = vars.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = vars.totalBorrowsNew;

        emit RepayBorrow(payer, borrower, vars.actualRepayAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);


        return (uint(Error.NO_ERROR), vars.actualRepayAmount);
    }



    function _setBondtroller(Bondtroller newBondtroller) public override  returns (uint) {
        if (msg.sender != admin) {
            return fail(Error.UNAUTHORIZED, FailureInfo.SET_COMPTROLLER_OWNER_CHECK);
        }

        Bondtroller oldBondtroller = bondtroller;
        require(newBondtroller.isBondtroller(), "marker method returned false");

        bondtroller = newBondtroller;

        emit NewBondtroller(oldBondtroller, newBondtroller);

        return uint(Error.NO_ERROR);
    }

    function _setReserveFactor(uint newReserveFactorMantissa) external override  nonReentrant returns (uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.SET_RESERVE_FACTOR_ACCRUE_INTEREST_FAILED);
        }
        return _setReserveFactorFresh(newReserveFactorMantissa);
    }

    function _setReserveFactorFresh(uint newReserveFactorMantissa) internal returns (uint) {
        if (msg.sender != admin) {
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


    function _reduceReserves(uint reduceAmount) external override  nonReentrant returns (uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDUCE_RESERVES_ACCRUE_INTEREST_FAILED);
        }
        return _reduceReservesFresh(reduceAmount);
    }

    function _reduceReservesFresh(uint reduceAmount) internal returns (uint) {
        uint totalReservesNew;

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


        totalReservesNew = totalReserves - reduceAmount;
        require(totalReservesNew <= totalReserves, "reduce reserves unexpected underflow");

        totalReserves = totalReservesNew;

        doTransferOut(admin, reduceAmount);

        emit ReservesReduced(admin, reduceAmount, totalReservesNew);

        return uint(Error.NO_ERROR);
    }

    function _setInterestRateModel(InterestRateModel newInterestRateModel) public override  returns (uint) {
        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.SET_INTEREST_RATE_MODEL_ACCRUE_INTEREST_FAILED);
        }
        return _setInterestRateModelFresh(newInterestRateModel);
    }

    function _setInterestRateModelFresh(InterestRateModel newInterestRateModel) internal returns (uint) {

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

        return uint(Error.NO_ERROR);
    }


    function getCashPrior() internal virtual view returns (uint);

    function doTransferIn(address from, uint amount) internal virtual returns (uint){}

    function doTransferOut(address payable to, uint amount) internal virtual{}



    modifier nonReentrant() {
        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true; // get a gas-refund post-Istanbul
    }

   
}// MIT
pragma solidity >=0.8.0;


abstract contract BErc20 is BToken, BErc20Interface {
    function initialize(address underlying_,
                        Bondtroller comptroller_,
                        InterestRateModel interestRateModel_,
                        uint initialExchangeRateMantissa_,
                        string memory name_,
                        string memory symbol_,
                        uint8 decimals_) public {
        super.initialize(comptroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_);

        underlying = underlying_;
        EIP20Interface(underlying).totalSupply();
    }


    function sweepToken(EIP20NonStandardInterface token) external override  {
    	require(address(token) != underlying, "CErc20::sweepToken: can not sweep underlying token");
    	uint256 balance = token.balanceOf(address(this));
    	token.transfer(admin, balance);
    }

    function _addReserves(uint addAmount) external  override returns (uint) {
        return _addReservesInternal(addAmount);
    }


    function getCashPrior() internal override  view returns (uint) {
        EIP20Interface token = EIP20Interface(underlying);
        return token.balanceOf(address(this));
    }

    function doTransferIn(address from, uint amount) internal override  returns (uint) {
        EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
        uint balanceBefore = EIP20Interface(underlying).balanceOf(address(this));
        token.transferFrom(from, address(this), amount);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {                       // This is a non-standard ERC-20
                    success := not(0)          // set success to true
                }
                case 32 {                      // This is a compliant ERC-20
                    returndatacopy(0, 0, 32)
                    success := mload(0)        // Set `success = returndata` of external call
                }
                default {                      // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_IN_FAILED");

        uint balanceAfter = EIP20Interface(underlying).balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "TOKEN_TRANSFER_IN_OVERFLOW");
        return balanceAfter - balanceBefore;   // underflow already checked above, just subtract
    }

    function doTransferOut(address payable to, uint amount) internal override  {
        EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
        token.transfer(to, amount);

        bool success;
        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    success := not(0)          // set success to true
                }
                case 32 {                     // This is a compliant ERC-20
                    returndatacopy(0, 0, 32)
                    success := mload(0)        // Set `success = returndata` of external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_OUT_FAILED");
    }

    
    
}// MIT

pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
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

library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}// MIT
pragma solidity >=0.8.0;



contract BLendingToken is Initializable, BErc20, AccessControlUpgradeable {


    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

    address public primaryIndexToken;

    event SetPrimaryIndexToken(address indexed oldPrimaryIndexToken, address indexed newPrimaryIndexToken);

    function init(  
        address underlying_,
        Bondtroller bondtroller_,
        InterestRateModel interestRateModel_,
        uint initialExchangeRateMantissa_,
        string memory name_, 
        string memory symbol_,
        uint8 decimals_,
        address admin_
    ) public initializer{

        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, admin_);
        _setupRole(MODERATOR_ROLE, admin_);
        admin = payable(msg.sender);
        super.initialize(underlying_, bondtroller_, interestRateModel_, initialExchangeRateMantissa_, name_, symbol_, decimals_);
        admin = payable(admin_);
       
    }
    
    modifier onlyAdmin(){

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender),"msg.sender not admin!");
        _;
    }

    modifier onlyPrimaryIndexToken {

        require(msg.sender == primaryIndexToken);
        _;
    }

    modifier onlyModerator {

        require(hasRole(MODERATOR_ROLE, msg.sender), "msg.sender not moderator");
        _;
    }
    

    function setPrimaryIndexToken(address _primaryIndexToken) public onlyAdmin {

        require(primaryIndexToken == address(0), "BLendingToken: primary index token is set");
        emit SetPrimaryIndexToken(primaryIndexToken, _primaryIndexToken);
        primaryIndexToken = _primaryIndexToken;
    }

    function grandModerator(address newModerator) public onlyAdmin {

        grantRole(MODERATOR_ROLE, newModerator);
    }

    function revokeModerator(address moderator) public onlyAdmin {

        revokeRole(MODERATOR_ROLE, moderator);
    }

    function transferAdminship(address payable newAdmin) public onlyAdmin {

        require(newAdmin != address(0), "BLendingToken: newAdmin==0");
        grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
        admin = newAdmin;
    }



    function setReserveFactor(uint256 reserveFactorMantissa) public onlyModerator{

        _setReserveFactorFresh(reserveFactorMantissa);
    }



    function mintTo(address minter, uint256 mintAmount) external onlyPrimaryIndexToken returns(uint err, uint mintedAmount){

        uint error = accrueInterest();
        
        if (error != uint(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.MINT_ACCRUE_INTEREST_FAILED), 0);
        }
       
        (err, mintedAmount) = mintFresh(minter, mintAmount);
        require(err == 0,"BLendingToken: err is not zero!");
        require(mintedAmount > 0, "BLendingToken: minted amount is zero!");
        
    }

     function redeemTo(address redeemer,uint256 redeemTokens) external onlyPrimaryIndexToken returns(uint redeemErr){

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
        }
        redeemErr = redeemFresh(payable(redeemer), redeemTokens, 0);
    }

    function redeemUnderlyingTo(address redeemer, uint256 redeemAmount) external onlyPrimaryIndexToken returns(uint redeemUnderlyingError){

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.REDEEM_ACCRUE_INTEREST_FAILED);
        }
        redeemUnderlyingError = redeemFresh(payable(redeemer), 0, redeemAmount);
    }

    function borrowTo(address borrower, uint256 borrowAmount) external onlyPrimaryIndexToken returns (uint borrowError) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return fail(Error(error), FailureInfo.BORROW_ACCRUE_INTEREST_FAILED);
        }
        borrowError = borrowFresh(payable(borrower), borrowAmount);
    }

    function repayTo(address payer, address borrower, uint256 repayAmount) external onlyPrimaryIndexToken returns (uint repayBorrowError, uint amountRepayed) {

        uint error = accrueInterest();
        if (error != uint(Error.NO_ERROR)) {
            return (fail(Error(error), FailureInfo.REPAY_BORROW_ACCRUE_INTEREST_FAILED), 0);
        }
        (repayBorrowError,amountRepayed) = repayBorrowFresh(payer, borrower, repayAmount);
    }

    function getEstimatedBorrowIndex() public view returns (uint256) {

        uint currentBlockNumber = getBlockNumber();
        uint accrualBlockNumberPrior = accrualBlockNumber;

        if (accrualBlockNumberPrior == currentBlockNumber) {
            return uint(Error.NO_ERROR);
        }

        uint cashPrior = getCashPrior();
        uint borrowsPrior = totalBorrows;
        uint reservesPrior = totalReserves;
        uint borrowIndexPrior = borrowIndex;

        uint borrowRateMantissa = interestRateModel.getBorrowRate(cashPrior, borrowsPrior, reservesPrior);
        require(borrowRateMantissa <= borrowRateMaxMantissa, "borrow rate is absurdly high");

        (MathError mathErr, uint blockDelta) = subUInt(currentBlockNumber, accrualBlockNumberPrior);
        require(mathErr == MathError.NO_ERROR, "could not calculate block delta");


        Exp memory simpleInterestFactor;
        uint borrowIndexNew;

        (mathErr, simpleInterestFactor) = mulScalar(Exp({mantissa: borrowRateMantissa}), blockDelta);
        if (mathErr != MathError.NO_ERROR) {
            return 0;
        }




        (mathErr, borrowIndexNew) = mulScalarTruncateAddUInt(simpleInterestFactor, borrowIndexPrior, borrowIndexPrior);
        if (mathErr != MathError.NO_ERROR) {
            return 0;
        }

        return borrowIndexNew;
    }

    function getEstimatedBorrowBalanceStored(address account) public view returns(uint accrual) {

        
        uint256 borrowIndexNew = getEstimatedBorrowIndex();
        MathError mathErr;
        uint principalTimesIndex;
        uint result;

        BorrowSnapshot memory borrowSnapshot = accountBorrows[account];

        if (borrowSnapshot.principal == 0) {
            return 0;
        }

        (mathErr, principalTimesIndex) = mulUInt(borrowSnapshot.principal, borrowIndexNew);
        if (mathErr != MathError.NO_ERROR) {
            return 0;
        }

        (mathErr, result) = divUInt(principalTimesIndex, borrowSnapshot.interestIndex);
        if (mathErr != MathError.NO_ERROR) {
            return 0;
        }

        return result;
    } 
    


}