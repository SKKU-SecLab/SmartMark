pragma solidity ^0.7.0;

abstract contract AdminStorage {
    address public admin;
}
pragma solidity ^0.7.0;


abstract contract AdminInterface is AdminStorage {
    function _renounceAdmin() external virtual;

    function _transferAdmin(address newAdmin) external virtual;

    event TransferAdmin(address indexed oldAdmin, address indexed newAdmin);
}
pragma solidity ^0.7.0;


abstract contract Admin is AdminInterface {
    modifier onlyAdmin() {
        require(admin == msg.sender, "ERR_NOT_ADMIN");
        _;
    }

    constructor() {
        address msgSender = msg.sender;
        admin = msgSender;
        emit TransferAdmin(address(0x00), msgSender);
    }

    function _renounceAdmin() external virtual override onlyAdmin {
        emit TransferAdmin(admin, address(0x00));
        admin = address(0x00);
    }

    function _transferAdmin(address newAdmin) external virtual override onlyAdmin {
        require(newAdmin != address(0x00), "ERR_SET_ADMIN_ZERO_ADDRESS");
        emit TransferAdmin(admin, newAdmin);
        admin = newAdmin;
    }
}
pragma solidity ^0.7.0;

abstract contract Erc20Storage {
    uint8 public decimals;

    string public name;

    string public symbol;

    uint256 public totalSupply;

    mapping(address => mapping(address => uint256)) internal allowances;

    mapping(address => uint256) internal balances;
}
pragma solidity ^0.7.0;


abstract contract Erc20Interface is Erc20Storage {
    function allowance(address owner, address spender) external view virtual returns (uint256);

    function balanceOf(address account) external view virtual returns (uint256);

    function approve(address spender, uint256 amount) external virtual returns (bool);

    function transfer(address recipient, uint256 amount) external virtual returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    event Burn(address indexed holder, uint256 burnAmount);

    event Mint(address indexed beneficiary, uint256 mintAmount);

    event Transfer(address indexed from, address indexed to, uint256 amount);
}
pragma solidity ^0.7.0;

enum MathError { NO_ERROR, DIVISION_BY_ZERO, INTEGER_OVERFLOW, INTEGER_UNDERFLOW, MODULO_BY_ZERO }

abstract contract CarefulMath {
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

    function divUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    function modUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
        if (b == 0) {
            return (MathError.MODULO_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a % b);
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

    function subUInt(uint256 a, uint256 b) internal pure returns (MathError, uint256) {
        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }
}
pragma solidity ^0.7.0;

abstract contract ExponentialStorage {
    struct Exp {
        uint256 mantissa;
    }

    uint256 internal constant expScale = 1e18;
    uint256 internal constant halfExpScale = expScale / 2;
    uint256 internal constant mantissaOne = expScale;
}
pragma solidity ^0.7.0;


abstract contract Exponential is
    CarefulMath, /* no dependency */
    ExponentialStorage /* no dependency */
{
    function addExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
        (MathError error, uint256 result) = addUInt(a.mantissa, b.mantissa);

        return (error, Exp({ mantissa: result }));
    }

    function divExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint256 scaledNumerator) = mulUInt(a.mantissa, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({ mantissa: 0 }));
        }

        (MathError err1, uint256 rational) = divUInt(scaledNumerator, b.mantissa);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({ mantissa: 0 }));
        }

        return (MathError.NO_ERROR, Exp({ mantissa: rational }));
    }

    function mulExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
        (MathError err0, uint256 doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({ mantissa: 0 }));
        }

        (MathError err1, uint256 doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({ mantissa: 0 }));
        }

        (MathError err2, uint256 product) = divUInt(doubleScaledProductWithHalfScale, expScale);
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({ mantissa: product }));
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

    function subExp(Exp memory a, Exp memory b) internal pure returns (MathError, Exp memory) {
        (MathError error, uint256 result) = subUInt(a.mantissa, b.mantissa);

        return (error, Exp({ mantissa: result }));
    }
}
pragma solidity ^0.7.0;

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
pragma solidity ^0.7.0;



abstract contract ChainlinkOperatorStorage {
    struct Feed {
        Erc20Interface asset;
        AggregatorV3Interface id;
        bool isSet;
    }

    mapping(string => Feed) internal feeds;

    uint256 public constant pricePrecision = 8;

    uint256 public constant pricePrecisionScalar = 1.0e10;
}
pragma solidity ^0.7.0;



abstract contract ChainlinkOperatorInterface is ChainlinkOperatorStorage {
    event DeleteFeed(Erc20Interface indexed asset, AggregatorV3Interface indexed feed);

    event SetFeed(Erc20Interface indexed asset, AggregatorV3Interface indexed feed);

    function getAdjustedPrice(string memory symbol) external view virtual returns (uint256);

    function getFeed(string memory symbol)
        external
        view
        virtual
        returns (
            Erc20Interface,
            AggregatorV3Interface,
            bool
        );

    function getPrice(string memory symbol) public view virtual returns (uint256);

    function deleteFeed(string memory symbol) external virtual returns (bool);

    function setFeed(Erc20Interface asset, AggregatorV3Interface feed) external virtual returns (bool);
}
pragma solidity ^0.7.0;



abstract contract FintrollerStorage is Exponential {
    struct Bond {
        Exp collateralizationRatio;
        uint256 debtCeiling;
        bool isBorrowAllowed;
        bool isDepositCollateralAllowed;
        bool isLiquidateBorrowAllowed;
        bool isListed;
        bool isRedeemFyTokenAllowed;
        bool isRepayBorrowAllowed;
        bool isSupplyUnderlyingAllowed;
    }

    mapping(FyTokenInterface => Bond) internal bonds;

    ChainlinkOperatorInterface public oracle;

    uint256 public liquidationIncentiveMantissa;

    uint256 internal constant collateralizationRatioLowerBoundMantissa = 1.0e18;

    uint256 internal constant collateralizationRatioUpperBoundMantissa = 1.0e20;

    uint256 internal constant defaultCollateralizationRatioMantissa = 1.5e18;

    uint256 internal constant liquidationIncentiveLowerBoundMantissa = 1.0e18;

    uint256 internal constant liquidationIncentiveUpperBoundMantissa = 1.5e18;

    bool public constant isFintroller = true;
}
pragma solidity ^0.7.0;


abstract contract FintrollerInterface is FintrollerStorage {

    function getBond(FyTokenInterface fyToken)
        external
        view
        virtual
        returns (
            uint256 debtCeiling,
            uint256 collateralizationRatioMantissa,
            bool isBorrowAllowed,
            bool isDepositCollateralAllowed,
            bool isLiquidateBorrowAllowed,
            bool isListed,
            bool isRedeemFyTokenAllowed,
            bool isRepayBorrowAllowed,
            bool isSupplyUnderlyingAllowed
        );

    function getBorrowAllowed(FyTokenInterface fyToken) external view virtual returns (bool);

    function getBondCollateralizationRatio(FyTokenInterface fyToken) external view virtual returns (uint256);

    function getBondDebtCeiling(FyTokenInterface fyToken) external view virtual returns (uint256);

    function getDepositCollateralAllowed(FyTokenInterface fyToken) external view virtual returns (bool);

    function getLiquidateBorrowAllowed(FyTokenInterface fyToken) external view virtual returns (bool);

    function getRedeemFyTokensAllowed(FyTokenInterface fyToken) external view virtual returns (bool);

    function getRepayBorrowAllowed(FyTokenInterface fyToken) external view virtual returns (bool);

    function getSupplyUnderlyingAllowed(FyTokenInterface fyToken) external view virtual returns (bool);


    function listBond(FyTokenInterface fyToken) external virtual returns (bool);

    function setBondCollateralizationRatio(FyTokenInterface fyToken, uint256 newCollateralizationRatioMantissa)
        external
        virtual
        returns (bool);

    function setBondDebtCeiling(FyTokenInterface fyToken, uint256 newDebtCeiling) external virtual returns (bool);

    function setBorrowAllowed(FyTokenInterface fyToken, bool state) external virtual returns (bool);

    function setDepositCollateralAllowed(FyTokenInterface fyToken, bool state) external virtual returns (bool);

    function setLiquidateBorrowAllowed(FyTokenInterface fyToken, bool state) external virtual returns (bool);

    function setLiquidationIncentive(uint256 newLiquidationIncentiveMantissa) external virtual returns (bool);

    function setOracle(ChainlinkOperatorInterface newOracle) external virtual returns (bool);

    function setRedeemFyTokensAllowed(FyTokenInterface fyToken, bool state) external virtual returns (bool);

    function setRepayBorrowAllowed(FyTokenInterface fyToken, bool state) external virtual returns (bool);

    function setSupplyUnderlyingAllowed(FyTokenInterface fyToken, bool state) external virtual returns (bool);

    event ListBond(address indexed admin, FyTokenInterface indexed fyToken);

    event SetBorrowAllowed(address indexed admin, FyTokenInterface indexed fyToken, bool state);

    event SetBondCollateralizationRatio(
        address indexed admin,
        FyTokenInterface indexed fyToken,
        uint256 oldCollateralizationRatio,
        uint256 newCollateralizationRatio
    );

    event SetBondDebtCeiling(
        address indexed admin,
        FyTokenInterface indexed fyToken,
        uint256 oldDebtCeiling,
        uint256 newDebtCeiling
    );

    event SetDepositCollateralAllowed(address indexed admin, FyTokenInterface indexed fyToken, bool state);

    event SetLiquidateBorrowAllowed(address indexed admin, FyTokenInterface indexed fyToken, bool state);

    event SetLiquidationIncentive(
        address indexed admin,
        uint256 oldLiquidationIncentive,
        uint256 newLiquidationIncentive
    );

    event SetRedeemFyTokensAllowed(address indexed admin, FyTokenInterface indexed fyToken, bool state);

    event SetRepayBorrowAllowed(address indexed admin, FyTokenInterface indexed fyToken, bool state);

    event SetOracle(address indexed admin, address oldOracle, address newOracle);

    event SetSupplyUnderlyingAllowed(address indexed admin, FyTokenInterface indexed fyToken, bool state);
}
pragma solidity ^0.7.0;


abstract contract RedemptionPoolStorage {
    FintrollerInterface public fintroller;

    uint256 public totalUnderlyingSupply;

    FyTokenInterface public fyToken;

    bool public constant isRedemptionPool = true;
}
pragma solidity ^0.7.0;


abstract contract RedemptionPoolInterface is RedemptionPoolStorage {
    function redeemFyTokens(uint256 fyTokenAmount) external virtual returns (bool);

    function supplyUnderlying(uint256 underlyingAmount) external virtual returns (bool);

    event RedeemFyTokens(address indexed account, uint256 fyTokenAmount, uint256 underlyingAmount);

    event SupplyUnderlying(address indexed account, uint256 underlyingAmount, uint256 fyTokenAmount);
}
pragma solidity ^0.7.0;


abstract contract FyTokenStorage {

    BalanceSheetInterface public balanceSheet;

    Erc20Interface public collateral;

    uint256 public collateralPrecisionScalar;

    uint256 public expirationTime;

    FintrollerInterface public fintroller;

    RedemptionPoolInterface public redemptionPool;

    Erc20Interface public underlying;

    uint256 public underlyingPrecisionScalar;

    bool public constant isFyToken = true;
}
pragma solidity ^0.7.0;


abstract contract FyTokenInterface is
    FyTokenStorage, /* no dependency */
    Erc20Interface /* one dependency */
{
    function isMatured() public view virtual returns (bool);

    function borrow(uint256 borrowAmount) external virtual returns (bool);

    function burn(address holder, uint256 burnAmount) external virtual returns (bool);

    function liquidateBorrow(address borrower, uint256 repayAmount) external virtual returns (bool);

    function mint(address beneficiary, uint256 mintAmount) external virtual returns (bool);

    function repayBorrow(uint256 repayAmount) external virtual returns (bool);

    function repayBorrowBehalf(address borrower, uint256 repayAmount) external virtual returns (bool);

    function _setFintroller(FintrollerInterface newFintroller) external virtual returns (bool);

    event Borrow(address indexed borrower, uint256 borrowAmount);

    event LiquidateBorrow(
        address indexed liquidator,
        address indexed borrower,
        uint256 repayAmount,
        uint256 clutchedCollateralAmount
    );

    event RepayBorrow(address indexed payer, address indexed borrower, uint256 repayAmount, uint256 newDebt);

    event SetFintroller(address indexed admin, FintrollerInterface oldFintroller, FintrollerInterface newFintroller);
}
pragma solidity ^0.7.0;


abstract contract BalanceSheetStorage {
    struct Vault {
        uint256 debt;
        uint256 freeCollateral;
        uint256 lockedCollateral;
        bool isOpen;
    }

    FintrollerInterface public fintroller;

    mapping(address => mapping(address => Vault)) internal vaults;

    bool public constant isBalanceSheet = true;
}
pragma solidity ^0.7.0;


abstract contract BalanceSheetInterface is BalanceSheetStorage {
    function getClutchableCollateral(FyTokenInterface fyToken, uint256 repayAmount)
        external
        view
        virtual
        returns (uint256);

    function getCurrentCollateralizationRatio(FyTokenInterface fyToken, address borrower)
        public
        view
        virtual
        returns (uint256);

    function getHypotheticalCollateralizationRatio(
        FyTokenInterface fyToken,
        address borrower,
        uint256 lockedCollateral,
        uint256 debt
    ) public view virtual returns (uint256);

    function getVault(FyTokenInterface fyToken, address borrower)
        external
        view
        virtual
        returns (
            uint256,
            uint256,
            uint256,
            bool
        );

    function getVaultDebt(FyTokenInterface fyToken, address borrower) external view virtual returns (uint256);

    function getVaultLockedCollateral(FyTokenInterface fyToken, address borrower)
        external
        view
        virtual
        returns (uint256);

    function isAccountUnderwater(FyTokenInterface fyToken, address borrower) external view virtual returns (bool);

    function isVaultOpen(FyTokenInterface fyToken, address borrower) external view virtual returns (bool);


    function clutchCollateral(
        FyTokenInterface fyToken,
        address liquidator,
        address borrower,
        uint256 clutchedCollateralAmount
    ) external virtual returns (bool);

    function depositCollateral(FyTokenInterface fyToken, uint256 collateralAmount) external virtual returns (bool);

    function freeCollateral(FyTokenInterface fyToken, uint256 collateralAmount) external virtual returns (bool);

    function lockCollateral(FyTokenInterface fyToken, uint256 collateralAmount) external virtual returns (bool);

    function openVault(FyTokenInterface fyToken) external virtual returns (bool);

    function setVaultDebt(
        FyTokenInterface fyToken,
        address borrower,
        uint256 newVaultDebt
    ) external virtual returns (bool);

    function withdrawCollateral(FyTokenInterface fyToken, uint256 collateralAmount) external virtual returns (bool);


    event ClutchCollateral(
        FyTokenInterface indexed fyToken,
        address indexed liquidator,
        address indexed borrower,
        uint256 clutchedCollateralAmount
    );

    event DepositCollateral(FyTokenInterface indexed fyToken, address indexed borrower, uint256 collateralAmount);

    event FreeCollateral(FyTokenInterface indexed fyToken, address indexed borrower, uint256 collateralAmount);

    event LockCollateral(FyTokenInterface indexed fyToken, address indexed borrower, uint256 collateralAmount);

    event OpenVault(FyTokenInterface indexed fyToken, address indexed borrower);

    event SetVaultDebt(FyTokenInterface indexed fyToken, address indexed borrower, uint256 oldDebt, uint256 newDebt);

    event WithdrawCollateral(FyTokenInterface indexed fyToken, address indexed borrower, uint256 collateralAmount);
}
pragma solidity ^0.7.0;

interface UniswapV2PairLike {

    function token0() external view returns (address);


    function token1() external view returns (address);


    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

}
pragma solidity ^0.7.0;



abstract contract HifiFlashSwapStorage {
    BalanceSheetInterface public balanceSheet;
    UniswapV2PairLike public pair;
    Erc20Interface public usdc;
    Erc20Interface public wbtc;
}
pragma solidity ^0.7.0;

interface UniswapV2CalleeLike {

    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

}
pragma solidity ^0.7.0;


abstract contract HifiFlashSwapInterface is
    HifiFlashSwapStorage, // no dependency
    UniswapV2CalleeLike // no dependency
{
    event FlashLiquidate(
        address indexed liquidator,
        address indexed borrower,
        address indexed fyToken,
        uint256 flashBorrowedUsdcAmount,
        uint256 mintedFyUsdcAmount,
        uint256 clutchedWbtcAmount,
        uint256 wbtcProfit
    );
}
pragma solidity ^0.7.0;



contract HifiFlashSwap is
    HifiFlashSwapInterface, // one dependency
    Admin // two dependencies
{

    constructor(address balanceSheet_, address pair_) Admin() {
        balanceSheet = BalanceSheetInterface(balanceSheet_);
        pair = UniswapV2PairLike(pair_);
        wbtc = Erc20Interface(pair.token0());
        usdc = Erc20Interface(pair.token1());
    }

    function getRepayWbtcAmount(uint256 usdcAmount) public view returns (uint256) {

        (uint112 wbtcReserves, uint112 usdcReserves, ) = pair.getReserves();

        uint256 numerator = wbtcReserves * usdcAmount * 1000;
        uint256 denominator = (usdcReserves - usdcAmount) * 997;
        uint256 wbtcRepaymentAmount = numerator / denominator + 1;

        return wbtcRepaymentAmount;
    }

    function uniswapV2Call(
        address sender,
        uint256 wbtcAmount,
        uint256 usdcAmount,
        bytes calldata data
    ) external override {

        (address fyTokenAddress, address borrower, uint256 minProfit) = abi.decode(data, (address, address, uint256));
        FyTokenInterface fyToken = FyTokenInterface(fyTokenAddress);
        require(balanceSheet.isAccountUnderwater(fyToken, borrower), "ERR_ACCOUNT_NOT_UNDERWATER");
        require(fyToken.isFyToken(), "ERR_FYTOKEN_INSPECTION");

        require(msg.sender == address(pair), "ERR_UNISWAP_V2_CALL_NOT_AUTHORIZED");
        require(wbtcAmount == 0, "ERR_WBTC_AMOUNT_ZERO");

        uint256 mintedFyUsdcAmount = mintFyUsdc(fyToken, usdcAmount);
        uint256 clutchedWbtcAmount = liquidateBorrow(fyToken, borrower, mintedFyUsdcAmount);

        uint256 repayWbtcAmount = getRepayWbtcAmount(usdcAmount);
        require(clutchedWbtcAmount > repayWbtcAmount + minProfit, "ERR_INSUFFICIENT_PROFIT");

        require(wbtc.transfer(address(pair), repayWbtcAmount), "ERR_WBTC_TRANSFER");

        uint256 profit = clutchedWbtcAmount - repayWbtcAmount;
        wbtc.transfer(sender, profit);

        emit FlashLiquidate(
            sender,
            borrower,
            fyTokenAddress,
            usdcAmount,
            mintedFyUsdcAmount,
            clutchedWbtcAmount,
            profit
        );
    }

    function mintFyUsdc(FyTokenInterface fyToken, uint256 usdcAmount) internal returns (uint256) {

        RedemptionPoolInterface redemptionPool = fyToken.redemptionPool();

        uint256 allowance = usdc.allowance(address(this), address(redemptionPool));
        if (allowance < usdcAmount) {
            usdc.approve(address(redemptionPool), type(uint256).max);
        }

        uint256 oldFyTokenBalance = fyToken.balanceOf(address(this));
        redemptionPool.supplyUnderlying(usdcAmount);
        uint256 newFyTokenBalance = fyToken.balanceOf(address(this));
        uint256 mintedFyUsdcAmount = newFyTokenBalance - oldFyTokenBalance;
        return mintedFyUsdcAmount;
    }

    function liquidateBorrow(
        FyTokenInterface fyToken,
        address borrower,
        uint256 mintedFyUsdcAmount
    ) internal returns (uint256) {

        uint256 oldWbtcBalance = wbtc.balanceOf(address(this));
        fyToken.liquidateBorrow(borrower, mintedFyUsdcAmount);
        uint256 newWbtcBalance = wbtc.balanceOf(address(this));
        uint256 clutchedWbtcAmount = newWbtcBalance - oldWbtcBalance;
        return clutchedWbtcAmount;
    }
}
