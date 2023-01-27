
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
}// MIT
pragma solidity 0.7.6;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);


    function factory() external view returns (address);


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


    function price0CumulativeLast() external view returns (uint256);


    function price1CumulativeLast() external view returns (uint256);


    function kLast() external view returns (uint256);


    function mint(address to) external returns (uint256 liquidity);


    function burn(address to) external returns (uint256 amount0, uint256 amount1);


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


    function skim(address to) external;


    function sync() external;


    function initialize(address, address) external;

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
pragma solidity 0.7.6;


interface IWETH is IERC20 {

    function deposit() external payable;


    function withdraw(uint256 wad) external;

}// MIT

pragma solidity 0.7.6;


interface IPendleBaseToken is IERC20 {

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function start() external view returns (uint256);


    function expiry() external view returns (uint256);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decimals() external view returns (uint8);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}// MIT

pragma solidity 0.7.6;


interface IPendleYieldToken is IERC20, IPendleBaseToken {

    event Burn(address indexed user, uint256 amount);

    event Mint(address indexed user, uint256 amount);

    function burn(address user, uint256 amount) external;


    function mint(address user, uint256 amount) external;


    function forge() external view returns (IPendleForge);


    function underlyingAsset() external view returns (address);


    function underlyingYieldToken() external view returns (address);


    function approveRouter(address user) external;

}// MIT
pragma solidity 0.7.6;

interface IPendlePausingManager {

    event AddPausingAdmin(address admin);
    event RemovePausingAdmin(address admin);
    event PendingForgeEmergencyHandler(address _pendingForgeHandler);
    event PendingMarketEmergencyHandler(address _pendingMarketHandler);
    event PendingLiqMiningEmergencyHandler(address _pendingLiqMiningHandler);
    event ForgeEmergencyHandlerSet(address forgeEmergencyHandler);
    event MarketEmergencyHandlerSet(address marketEmergencyHandler);
    event LiqMiningEmergencyHandlerSet(address liqMiningEmergencyHandler);

    event PausingManagerLocked();
    event ForgeHandlerLocked();
    event MarketHandlerLocked();
    event LiqMiningHandlerLocked();

    event SetForgePaused(bytes32 forgeId, bool settingToPaused);
    event SetForgeAssetPaused(bytes32 forgeId, address underlyingAsset, bool settingToPaused);
    event SetForgeAssetExpiryPaused(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry,
        bool settingToPaused
    );

    event SetForgeLocked(bytes32 forgeId);
    event SetForgeAssetLocked(bytes32 forgeId, address underlyingAsset);
    event SetForgeAssetExpiryLocked(bytes32 forgeId, address underlyingAsset, uint256 expiry);

    event SetMarketFactoryPaused(bytes32 marketFactoryId, bool settingToPaused);
    event SetMarketPaused(bytes32 marketFactoryId, address market, bool settingToPaused);

    event SetMarketFactoryLocked(bytes32 marketFactoryId);
    event SetMarketLocked(bytes32 marketFactoryId, address market);

    event SetLiqMiningPaused(address liqMiningContract, bool settingToPaused);
    event SetLiqMiningLocked(address liqMiningContract);

    function forgeEmergencyHandler()
        external
        view
        returns (
            address handler,
            address pendingHandler,
            uint256 timelockDeadline
        );


    function marketEmergencyHandler()
        external
        view
        returns (
            address handler,
            address pendingHandler,
            uint256 timelockDeadline
        );


    function liqMiningEmergencyHandler()
        external
        view
        returns (
            address handler,
            address pendingHandler,
            uint256 timelockDeadline
        );


    function permLocked() external view returns (bool);


    function permForgeHandlerLocked() external view returns (bool);


    function permMarketHandlerLocked() external view returns (bool);


    function permLiqMiningHandlerLocked() external view returns (bool);


    function isPausingAdmin(address) external view returns (bool);


    function setPausingAdmin(address admin, bool isAdmin) external;


    function requestForgeHandlerChange(address _pendingForgeHandler) external;


    function requestMarketHandlerChange(address _pendingMarketHandler) external;


    function requestLiqMiningHandlerChange(address _pendingLiqMiningHandler) external;


    function applyForgeHandlerChange() external;


    function applyMarketHandlerChange() external;


    function applyLiqMiningHandlerChange() external;


    function lockPausingManagerPermanently() external;


    function lockForgeHandlerPermanently() external;


    function lockMarketHandlerPermanently() external;


    function lockLiqMiningHandlerPermanently() external;


    function setForgePaused(bytes32 forgeId, bool paused) external;


    function setForgeAssetPaused(
        bytes32 forgeId,
        address underlyingAsset,
        bool paused
    ) external;


    function setForgeAssetExpiryPaused(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry,
        bool paused
    ) external;


    function setForgeLocked(bytes32 forgeId) external;


    function setForgeAssetLocked(bytes32 forgeId, address underlyingAsset) external;


    function setForgeAssetExpiryLocked(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external;


    function checkYieldContractStatus(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external returns (bool _paused, bool _locked);


    function setMarketFactoryPaused(bytes32 marketFactoryId, bool paused) external;


    function setMarketPaused(
        bytes32 marketFactoryId,
        address market,
        bool paused
    ) external;


    function setMarketFactoryLocked(bytes32 marketFactoryId) external;


    function setMarketLocked(bytes32 marketFactoryId, address market) external;


    function checkMarketStatus(bytes32 marketFactoryId, address market)
        external
        returns (bool _paused, bool _locked);


    function setLiqMiningPaused(address liqMiningContract, bool settingToPaused) external;


    function setLiqMiningLocked(address liqMiningContract) external;


    function checkLiqMiningStatus(address liqMiningContract)
        external
        returns (bool _paused, bool _locked);

}// GPL-2.0-or-later
pragma solidity 0.7.6;

struct TokenReserve {
    uint256 weight;
    uint256 balance;
}

struct PendingTransfer {
    uint256 amount;
    bool isOut;
}// MIT

pragma solidity 0.7.6;
pragma abicoder v2;


interface IPendleMarket is IERC20 {

    event Sync(uint256 reserve0, uint256 weight0, uint256 reserve1);

    function setUpEmergencyMode(address spender) external;


    function bootstrap(
        address user,
        uint256 initialXytLiquidity,
        uint256 initialTokenLiquidity
    ) external returns (PendingTransfer[2] memory transfers, uint256 exactOutLp);


    function addMarketLiquiditySingle(
        address user,
        address inToken,
        uint256 inAmount,
        uint256 minOutLp
    ) external returns (PendingTransfer[2] memory transfers, uint256 exactOutLp);


    function addMarketLiquidityDual(
        address user,
        uint256 _desiredXytAmount,
        uint256 _desiredTokenAmount,
        uint256 _xytMinAmount,
        uint256 _tokenMinAmount
    ) external returns (PendingTransfer[2] memory transfers, uint256 lpOut);


    function removeMarketLiquidityDual(
        address user,
        uint256 inLp,
        uint256 minOutXyt,
        uint256 minOutToken
    ) external returns (PendingTransfer[2] memory transfers);


    function removeMarketLiquiditySingle(
        address user,
        address outToken,
        uint256 exactInLp,
        uint256 minOutToken
    ) external returns (PendingTransfer[2] memory transfers);


    function swapExactIn(
        address inToken,
        uint256 inAmount,
        address outToken,
        uint256 minOutAmount
    ) external returns (uint256 outAmount, PendingTransfer[2] memory transfers);


    function swapExactOut(
        address inToken,
        uint256 maxInAmount,
        address outToken,
        uint256 outAmount
    ) external returns (uint256 inAmount, PendingTransfer[2] memory transfers);


    function redeemLpInterests(address user) external returns (uint256 interests);


    function getReserves()
        external
        view
        returns (
            uint256 xytBalance,
            uint256 xytWeight,
            uint256 tokenBalance,
            uint256 tokenWeight,
            uint256 currentBlock
        );


    function factoryId() external view returns (bytes32);


    function token() external view returns (address);


    function xyt() external view returns (address);

}// MIT

pragma solidity 0.7.6;


interface IPendleData {

    event ForgeFactoryValiditySet(bytes32 _forgeId, bytes32 _marketFactoryId, bool _valid);

    event TreasurySet(address treasury);

    event LockParamsSet(uint256 lockNumerator, uint256 lockDenominator);

    event ExpiryDivisorSet(uint256 expiryDivisor);

    event ForgeFeeSet(uint256 forgeFee);

    event InterestUpdateRateDeltaForMarketSet(uint256 interestUpdateRateDeltaForMarket);

    event MarketFeesSet(uint256 _swapFee, uint256 _protocolSwapFee);

    event CurveShiftBlockDeltaSet(uint256 _blockDelta);

    event NewMarketFactory(bytes32 indexed marketFactoryId, address indexed marketFactoryAddress);

    function setForgeFactoryValidity(
        bytes32 _forgeId,
        bytes32 _marketFactoryId,
        bool _valid
    ) external;


    function setTreasury(address newTreasury) external;


    function router() external view returns (IPendleRouter);


    function pausingManager() external view returns (IPendlePausingManager);


    function treasury() external view returns (address);



    event ForgeAdded(bytes32 indexed forgeId, address indexed forgeAddress);

    function addForge(bytes32 forgeId, address forgeAddress) external;


    function storeTokens(
        bytes32 forgeId,
        address ot,
        address xyt,
        address underlyingAsset,
        uint256 expiry
    ) external;


    function setForgeFee(uint256 _forgeFee) external;


    function getPendleYieldTokens(
        bytes32 forgeId,
        address underlyingYieldToken,
        uint256 expiry
    ) external view returns (IPendleYieldToken ot, IPendleYieldToken xyt);


    function getForgeAddress(bytes32 forgeId) external view returns (address forgeAddress);


    function isValidXYT(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external view returns (bool);


    function isValidOT(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external view returns (bool);


    function validForgeFactoryPair(bytes32 _forgeId, bytes32 _marketFactoryId)
        external
        view
        returns (bool);


    function otTokens(
        bytes32 forgeId,
        address underlyingYieldToken,
        uint256 expiry
    ) external view returns (IPendleYieldToken ot);


    function xytTokens(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external view returns (IPendleYieldToken xyt);



    event MarketPairAdded(address indexed market, address indexed xyt, address indexed token);

    function addMarketFactory(bytes32 marketFactoryId, address marketFactoryAddress) external;


    function isMarket(address _addr) external view returns (bool result);


    function isXyt(address _addr) external view returns (bool result);


    function addMarket(
        bytes32 marketFactoryId,
        address xyt,
        address token,
        address market
    ) external;


    function setMarketFees(uint256 _swapFee, uint256 _protocolSwapFee) external;


    function setInterestUpdateRateDeltaForMarket(uint256 _interestUpdateRateDeltaForMarket)
        external;


    function setLockParams(uint256 _lockNumerator, uint256 _lockDenominator) external;


    function setExpiryDivisor(uint256 _expiryDivisor) external;


    function setCurveShiftBlockDelta(uint256 _blockDelta) external;


    function allMarketsLength() external view returns (uint256);


    function forgeFee() external view returns (uint256);


    function interestUpdateRateDeltaForMarket() external view returns (uint256);


    function expiryDivisor() external view returns (uint256);


    function lockNumerator() external view returns (uint256);


    function lockDenominator() external view returns (uint256);


    function swapFee() external view returns (uint256);


    function protocolSwapFee() external view returns (uint256);


    function curveShiftBlockDelta() external view returns (uint256);


    function getMarketByIndex(uint256 index) external view returns (address market);


    function getMarket(
        bytes32 marketFactoryId,
        address xyt,
        address token
    ) external view returns (address market);


    function getMarketFactoryAddress(bytes32 marketFactoryId)
        external
        view
        returns (address marketFactoryAddress);


    function getMarketFromKey(
        address xyt,
        address token,
        bytes32 marketFactoryId
    ) external view returns (address market);

}// MIT

pragma solidity 0.7.6;


interface IPendleMarketFactory {

    function createMarket(address xyt, address token) external returns (address market);


    function router() external view returns (IPendleRouter);


    function marketFactoryId() external view returns (bytes32);

}// MIT

pragma solidity 0.7.6;


interface IPendleRouter {

    event MarketCreated(
        bytes32 marketFactoryId,
        address indexed xyt,
        address indexed token,
        address indexed market
    );

    event SwapEvent(
        address indexed trader,
        address inToken,
        address outToken,
        uint256 exactIn,
        uint256 exactOut,
        address market
    );

    event Join(
        address indexed sender,
        uint256 token0Amount,
        uint256 token1Amount,
        address market,
        uint256 exactOutLp
    );

    event Exit(
        address indexed sender,
        uint256 token0Amount,
        uint256 token1Amount,
        address market,
        uint256 exactInLp
    );

    function data() external view returns (IPendleData);


    function weth() external view returns (IWETH);



    function newYieldContracts(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external returns (address ot, address xyt);


    function redeemAfterExpiry(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry
    ) external returns (uint256 redeemedAmount);


    function redeemDueInterests(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry,
        address user
    ) external returns (uint256 interests);


    function redeemUnderlying(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry,
        uint256 amountToRedeem
    ) external returns (uint256 redeemedAmount);


    function renewYield(
        bytes32 forgeId,
        uint256 oldExpiry,
        address underlyingAsset,
        uint256 newExpiry,
        uint256 renewalRate
    )
        external
        returns (
            uint256 redeemedAmount,
            uint256 amountRenewed,
            address ot,
            address xyt,
            uint256 amountTokenMinted
        );


    function tokenizeYield(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry,
        uint256 amountToTokenize,
        address to
    )
        external
        returns (
            address ot,
            address xyt,
            uint256 amountTokenMinted
        );



    function addMarketLiquidityDual(
        bytes32 _marketFactoryId,
        address _xyt,
        address _token,
        uint256 _desiredXytAmount,
        uint256 _desiredTokenAmount,
        uint256 _xytMinAmount,
        uint256 _tokenMinAmount
    )
        external
        payable
        returns (
            uint256 amountXytUsed,
            uint256 amountTokenUsed,
            uint256 lpOut
        );


    function addMarketLiquiditySingle(
        bytes32 marketFactoryId,
        address xyt,
        address token,
        bool forXyt,
        uint256 exactInAsset,
        uint256 minOutLp
    ) external payable returns (uint256 exactOutLp);


    function removeMarketLiquidityDual(
        bytes32 marketFactoryId,
        address xyt,
        address token,
        uint256 exactInLp,
        uint256 minOutXyt,
        uint256 minOutToken
    ) external returns (uint256 exactOutXyt, uint256 exactOutToken);


    function removeMarketLiquiditySingle(
        bytes32 marketFactoryId,
        address xyt,
        address token,
        bool forXyt,
        uint256 exactInLp,
        uint256 minOutAsset
    ) external returns (uint256 exactOutXyt, uint256 exactOutToken);


    function createMarket(
        bytes32 marketFactoryId,
        address xyt,
        address token
    ) external returns (address market);


    function bootstrapMarket(
        bytes32 marketFactoryId,
        address xyt,
        address token,
        uint256 initialXytLiquidity,
        uint256 initialTokenLiquidity
    ) external payable;


    function swapExactIn(
        address tokenIn,
        address tokenOut,
        uint256 inTotalAmount,
        uint256 minOutTotalAmount,
        bytes32 marketFactoryId
    ) external payable returns (uint256 outTotalAmount);


    function swapExactOut(
        address tokenIn,
        address tokenOut,
        uint256 outTotalAmount,
        uint256 maxInTotalAmount,
        bytes32 marketFactoryId
    ) external payable returns (uint256 inTotalAmount);


    function redeemLpInterests(address market, address user) external returns (uint256 interests);

}// MIT
pragma solidity 0.7.6;

interface IPendleRewardManager {

    event UpdateFrequencySet(address[], uint256[]);
    event SkippingRewardsSet(bool);

    event DueRewardsSettled(
        bytes32 forgeId,
        address underlyingAsset,
        uint256 expiry,
        uint256 amountOut,
        address user
    );

    function redeemRewards(
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) external returns (uint256 dueRewards);


    function updatePendingRewards(
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) external;


    function updateParamLManual(address _underlyingAsset, uint256 _expiry) external;


    function setUpdateFrequency(
        address[] calldata underlyingAssets,
        uint256[] calldata frequencies
    ) external;


    function setSkippingRewards(bool skippingRewards) external;


    function forgeId() external returns (bytes32);

}// MIT
pragma solidity 0.7.6;

interface IPendleYieldContractDeployer {

    function forgeId() external returns (bytes32);


    function forgeOwnershipToken(
        address _underlyingAsset,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _expiry
    ) external returns (address ot);


    function forgeFutureYieldToken(
        address _underlyingAsset,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _expiry
    ) external returns (address xyt);


    function deployYieldTokenHolder(address yieldToken, uint256 expiry)
        external
        returns (address yieldTokenHolder);

}// MIT

pragma solidity 0.7.6;


interface IPendleForge {

    event MintYieldTokens(
        bytes32 forgeId,
        address indexed underlyingAsset,
        uint256 indexed expiry,
        uint256 amountToTokenize,
        uint256 amountTokenMinted,
        address indexed user
    );

    event NewYieldContracts(
        bytes32 forgeId,
        address indexed underlyingAsset,
        uint256 indexed expiry,
        address ot,
        address xyt,
        address yieldBearingAsset
    );

    event RedeemYieldToken(
        bytes32 forgeId,
        address indexed underlyingAsset,
        uint256 indexed expiry,
        uint256 amountToRedeem,
        uint256 redeemedAmount,
        address indexed user
    );

    event DueInterestsSettled(
        bytes32 forgeId,
        address indexed underlyingAsset,
        uint256 indexed expiry,
        uint256 amount,
        uint256 forgeFeeAmount,
        address indexed user
    );

    event ForgeFeeWithdrawn(
        bytes32 forgeId,
        address indexed underlyingAsset,
        uint256 indexed expiry,
        uint256 amount
    );

    function setUpEmergencyMode(
        address _underlyingAsset,
        uint256 _expiry,
        address spender
    ) external;


    function newYieldContracts(address underlyingAsset, uint256 expiry)
        external
        returns (address ot, address xyt);


    function redeemAfterExpiry(
        address user,
        address underlyingAsset,
        uint256 expiry
    ) external returns (uint256 redeemedAmount);


    function redeemDueInterests(
        address user,
        address underlyingAsset,
        uint256 expiry
    ) external returns (uint256 interests);


    function updateDueInterests(
        address underlyingAsset,
        uint256 expiry,
        address user
    ) external;


    function updatePendingRewards(
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) external;


    function redeemUnderlying(
        address user,
        address underlyingAsset,
        uint256 expiry,
        uint256 amountToRedeem
    ) external returns (uint256 redeemedAmount);


    function mintOtAndXyt(
        address underlyingAsset,
        uint256 expiry,
        uint256 amountToTokenize,
        address to
    )
        external
        returns (
            address ot,
            address xyt,
            uint256 amountTokenMinted
        );


    function withdrawForgeFee(address underlyingAsset, uint256 expiry) external;


    function getYieldBearingToken(address underlyingAsset) external returns (address);


    function router() external view returns (IPendleRouter);


    function data() external view returns (IPendleData);


    function rewardManager() external view returns (IPendleRewardManager);


    function yieldContractDeployer() external view returns (IPendleYieldContractDeployer);


    function rewardToken() external view returns (IERC20);


    function forgeId() external view returns (bytes32);


    function dueInterests(
        address _underlyingAsset,
        uint256 expiry,
        address _user
    ) external view returns (uint256);


    function yieldTokenHolders(address _underlyingAsset, uint256 _expiry)
        external
        view
        returns (address yieldTokenHolder);

}// MIT

pragma solidity 0.7.6;


interface IPendleCompoundForge is IPendleForge {

    function getExchangeRate(address _underlyingAsset) external returns (uint256);

}// MIT

pragma solidity 0.7.6;


interface IPendleGenericForge is IPendleCompoundForge {


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
}// GPL-2.0-or-later
pragma solidity 0.7.6;


library ExpiryUtils {

    struct Date {
        uint16 year;
        uint8 month;
        uint8 day;
    }

    uint256 private constant DAY_IN_SECONDS = 86400;
    uint256 private constant YEAR_IN_SECONDS = 31536000;
    uint256 private constant LEAP_YEAR_IN_SECONDS = 31622400;
    uint16 private constant ORIGIN_YEAR = 1970;

    function concat(
        string memory _bt,
        string memory _yt,
        uint256 _expiry,
        string memory _delimiter
    ) internal pure returns (string memory result) {

        result = string(
            abi.encodePacked(_bt, _delimiter, _yt, _delimiter, toRFC2822String(_expiry))
        );
    }

    function toRFC2822String(uint256 _timestamp) internal pure returns (string memory s) {

        Date memory d = parseTimestamp(_timestamp);
        string memory day = uintToString(d.day);
        string memory month = monthName(d);
        string memory year = uintToString(d.year);
        s = string(abi.encodePacked(day, month, year));
    }

    function getDaysInMonth(uint8 _month, uint16 _year) private pure returns (uint8) {

        if (
            _month == 1 ||
            _month == 3 ||
            _month == 5 ||
            _month == 7 ||
            _month == 8 ||
            _month == 10 ||
            _month == 12
        ) {
            return 31;
        } else if (_month == 4 || _month == 6 || _month == 9 || _month == 11) {
            return 30;
        } else if (isLeapYear(_year)) {
            return 29;
        } else {
            return 28;
        }
    }

    function getYear(uint256 _timestamp) private pure returns (uint16) {

        uint256 secondsAccountedFor = 0;
        uint16 year;
        uint256 numLeapYears;

        year = uint16(ORIGIN_YEAR + _timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > _timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            } else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function isLeapYear(uint16 _year) private pure returns (bool) {

        return ((_year % 4 == 0) && (_year % 100 != 0)) || (_year % 400 == 0);
    }

    function leapYearsBefore(uint256 _year) private pure returns (uint256) {

        _year -= 1;
        return _year / 4 - _year / 100 + _year / 400;
    }

    function monthName(Date memory d) private pure returns (string memory) {

        string[12] memory months =
            ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        return months[d.month - 1];
    }

    function parseTimestamp(uint256 _timestamp) private pure returns (Date memory d) {

        uint256 secondsAccountedFor = 0;
        uint256 buf;
        uint8 i;

        d.year = getYear(_timestamp);
        buf = leapYearsBefore(d.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (d.year - ORIGIN_YEAR - buf);

        uint256 secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, d.year);
            if (secondsInMonth + secondsAccountedFor > _timestamp) {
                d.month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }

        for (i = 1; i <= getDaysInMonth(d.month, d.year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > _timestamp) {
                d.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }
    }

    function uintToString(uint256 _i) private pure returns (string memory) {

        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}// MIT

pragma solidity 0.7.6;


interface IPendleForgeV2 is IPendleForge {

    function setUpEmergencyModeV2(
        address _underlyingAsset,
        uint256 _expiry,
        address spender,
        bool extraFlag
    ) external;

}// MIT
pragma solidity 0.7.6;

interface IPendleYieldContractDeployerV2 {

    function forgeId() external returns (bytes32);


    function forgeOwnershipToken(
        address underlyingAsset,
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 expiry
    ) external returns (address ot);


    function forgeFutureYieldToken(
        address underlyingAsset,
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 expiry
    ) external returns (address xyt);


    function deployYieldTokenHolder(
        address yieldToken,
        uint256 expiry,
        uint256[] calldata container
    ) external returns (address yieldTokenHolder);

}// MIT
pragma solidity 0.7.6;

interface IPendleYieldTokenHolder {

    function redeemRewards() external;


    function setUpEmergencyMode(address spender) external;


    function yieldToken() external returns (address);


    function forge() external returns (address);


    function rewardToken() external returns (address);


    function expiry() external returns (uint256);

}// MIT
pragma solidity 0.7.6;


interface IPendleYieldTokenHolderV2 is IPendleYieldTokenHolder {

    function setUpEmergencyModeV2(address spender, bool extraFlag) external;


    function pushYieldTokens(
        address to,
        uint256 amount,
        uint256 minNYieldAfterPush
    ) external;


    function afterReceiveTokens(uint256 amount) external;

}// BUSL-1.1
pragma solidity 0.7.6;

contract PendleGovernanceManager {

    address public governance;
    address public pendingGovernance;

    event GovernanceClaimed(address newGovernance, address previousGovernance);

    event TransferGovernancePending(address pendingGovernance);

    constructor(address _governance) {
        require(_governance != address(0), "ZERO_ADDRESS");
        governance = _governance;
    }

    modifier onlyGovernance() {

        require(msg.sender == governance, "ONLY_GOVERNANCE");
        _;
    }

    function claimGovernance() external {

        require(pendingGovernance == msg.sender, "WRONG_GOVERNANCE");
        emit GovernanceClaimed(pendingGovernance, governance);
        governance = pendingGovernance;
        pendingGovernance = address(0);
    }

    function transferGovernance(address _governance) external onlyGovernance {

        require(_governance != address(0), "ZERO_ADDRESS");
        pendingGovernance = _governance;

        emit TransferGovernancePending(pendingGovernance);
    }
}// MIT

pragma solidity 0.7.6;


interface IPermissionsV2 {

    function governanceManager() external returns (PendleGovernanceManager);

}// BUSL-1.1
pragma solidity 0.7.6;


abstract contract PermissionsV2 is IPermissionsV2 {
    PendleGovernanceManager public immutable override governanceManager;
    address internal initializer;

    constructor(address _governanceManager) {
        require(_governanceManager != address(0), "ZERO_ADDRESS");
        initializer = msg.sender;
        governanceManager = PendleGovernanceManager(_governanceManager);
    }

    modifier initialized() {
        require(initializer == address(0), "NOT_INITIALIZED");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == _governance(), "ONLY_GOVERNANCE");
        _;
    }

    function _governance() internal view returns (address) {
        return governanceManager.governance();
    }
}// BUSL-1.1
pragma solidity 0.7.6;


abstract contract WithdrawableV2 is PermissionsV2 {
    using SafeERC20 for IERC20;

    event EtherWithdraw(uint256 amount, address sendTo);
    event TokenWithdraw(IERC20 token, uint256 amount, address sendTo);

    function withdrawEther(uint256 amount, address payable sendTo) external onlyGovernance {
        (bool success, ) = sendTo.call{value: amount}("");
        require(success, "WITHDRAW_FAILED");
        emit EtherWithdraw(amount, sendTo);
    }

    function withdrawToken(
        IERC20 token,
        uint256 amount,
        address sendTo
    ) external onlyGovernance {
        require(_allowedToWithdraw(address(token)), "TOKEN_NOT_ALLOWED");
        token.safeTransfer(sendTo, amount);
        emit TokenWithdraw(token, amount, sendTo);
    }

    function _allowedToWithdraw(address) internal view virtual returns (bool allowed);
}// GPL-2.0-or-later
pragma solidity ^0.7.0;


library Math {

    using SafeMath for uint256;

    uint256 internal constant BIG_NUMBER = (uint256(1) << uint256(200));
    uint256 internal constant PRECISION_BITS = 40;
    uint256 internal constant RONE = uint256(1) << PRECISION_BITS;
    uint256 internal constant PI = (314 * RONE) / 10**2;
    uint256 internal constant PI_PLUSONE = (414 * RONE) / 10**2;
    uint256 internal constant PRECISION_POW = 1e2;

    function checkMultOverflow(uint256 _x, uint256 _y) internal pure returns (bool) {

        if (_y == 0) return false;
        return (((_x * _y) / _y) != _x);
    }

    function log2Int(uint256 _p, uint256 _q) internal pure returns (uint256) {

        uint256 res = 0;
        uint256 remain = _p / _q;
        while (remain > 0) {
            res++;
            remain /= 2;
        }
        return res - 1;
    }

    function log2ForSmallNumber(uint256 _x) internal pure returns (uint256) {

        uint256 res = 0;
        uint256 one = (uint256(1) << PRECISION_BITS);
        uint256 two = 2 * one;
        uint256 addition = one;

        require((_x >= one) && (_x < two), "MATH_ERROR");
        require(PRECISION_BITS < 125, "MATH_ERROR");

        for (uint256 i = PRECISION_BITS; i > 0; i--) {
            _x = (_x * _x) / one;
            addition = addition / 2;
            if (_x >= two) {
                _x = _x / 2;
                res += addition;
            }
        }

        return res;
    }

    function logBase2(uint256 _p, uint256 _q) internal pure returns (uint256) {

        uint256 n = 0;

        if (_p > _q) {
            n = log2Int(_p, _q);
        }

        require(n * RONE <= BIG_NUMBER, "MATH_ERROR");
        require(!checkMultOverflow(_p, RONE), "MATH_ERROR");
        require(!checkMultOverflow(n, RONE), "MATH_ERROR");
        require(!checkMultOverflow(uint256(1) << n, _q), "MATH_ERROR");

        uint256 y = (_p * RONE) / (_q * (uint256(1) << n));
        uint256 log2Small = log2ForSmallNumber(y);

        assert(log2Small <= BIG_NUMBER);

        return n * RONE + log2Small;
    }

    function ln(uint256 p, uint256 q) internal pure returns (uint256) {

        uint256 ln2Numerator = 6931471805599453094172;
        uint256 ln2Denomerator = 10000000000000000000000;

        uint256 log2x = logBase2(p, q);

        require(!checkMultOverflow(ln2Numerator, log2x), "MATH_ERROR");

        return (ln2Numerator * log2x) / ln2Denomerator;
    }

    function fpart(uint256 value) internal pure returns (uint256) {

        return value % RONE;
    }

    function toInt(uint256 value) internal pure returns (uint256) {

        return value / RONE;
    }

    function toFP(uint256 value) internal pure returns (uint256) {

        return value * RONE;
    }

    function rpowe(uint256 exp) internal pure returns (uint256) {

        uint256 res = 0;

        uint256 curTerm = RONE;

        for (uint256 n = 0; ; n++) {
            res += curTerm;
            curTerm = rmul(curTerm, rdiv(exp, toFP(n + 1)));
            if (curTerm == 0) {
                break;
            }
            if (n == 500) {
                revert("RPOWE_SLOW_CONVERGE");
            }
        }

        return res;
    }

    function rpow(uint256 base, uint256 exp) internal pure returns (uint256) {

        if (exp == 0) {
            return RONE;
        }
        if (base == 0) {
            return 0;
        }

        uint256 frac = fpart(exp); // get the fractional part
        uint256 whole = exp - frac;

        uint256 wholePow = rpowi(base, toInt(whole)); // whole is a FP, convert to Int
        uint256 fracPow;

        if (base < RONE) {
            uint256 newExp = rmul(frac, ln(rdiv(RONE, base), RONE));
            fracPow = rdiv(RONE, rpowe(newExp));
        } else {
            uint256 newExp = rmul(frac, ln(base, RONE));
            fracPow = rpowe(newExp);
        }
        return rmul(wholePow, fracPow);
    }

    function rpowi(uint256 base, uint256 exp) internal pure returns (uint256) {

        uint256 res = exp % 2 != 0 ? base : RONE;

        for (exp /= 2; exp != 0; exp /= 2) {
            base = rmul(base, base);

            if (exp % 2 != 0) {
                res = rmul(res, base);
            }
        }
        return res;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {

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

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256) {

        return (y / 2).add(x.mul(RONE)).div(y);
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256) {

        return (RONE / 2).add(x.mul(y)).div(RONE);
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function subMax0(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a - b : 0;
    }
}// GPL-2.0-or-later
pragma solidity ^0.7.0;

library TokenUtils {

    function requireERC20(address tokenAddr) internal view {

        require(IERC20(tokenAddr).totalSupply() > 0, "INVALID_ERC20");
    }

    function requireERC20(IERC20 token) internal view {

        require(token.totalSupply() > 0, "INVALID_ERC20");
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


abstract contract PendleForgeBaseV2 is IPendleForgeV2, WithdrawableV2, ReentrancyGuard {
    using ExpiryUtils for string;
    using SafeMath for uint256;
    using Math for uint256;
    using SafeERC20 for IERC20;

    struct PendleTokens {
        IPendleYieldToken xyt;
        IPendleYieldToken ot;
    }

    struct TokenInfo {
        bool registered;
        uint256[] container;
    }

    IPendleRouter public immutable override router;
    IPendleData public immutable override data;
    bytes32 public immutable override forgeId;
    IERC20 public immutable override rewardToken;
    IPendleRewardManager public immutable override rewardManager;
    IPendleYieldContractDeployer public immutable override yieldContractDeployer;
    IPendlePausingManager public immutable pausingManager;

    mapping(address => mapping(uint256 => mapping(address => uint256)))
        public
        override dueInterests;

    mapping(address => mapping(uint256 => uint256)) public totalFee;
    mapping(address => mapping(uint256 => address)) public override yieldTokenHolders; // yieldTokenHolders[underlyingAsset][expiry]
    mapping(address => TokenInfo) public tokenInfo;

    string private constant OT = "OT";
    string private constant XYT = "YT";

    event RegisterTokens(bytes32 forgeId, address underlyingAsset, uint256[] container);

    modifier onlyXYT(address _underlyingAsset, uint256 _expiry) {
        require(
            msg.sender == address(data.xytTokens(forgeId, _underlyingAsset, _expiry)),
            "ONLY_YT"
        );
        _;
    }

    modifier onlyOT(address _underlyingAsset, uint256 _expiry) {
        require(
            msg.sender == address(data.otTokens(forgeId, _underlyingAsset, _expiry)),
            "ONLY_OT"
        );
        _;
    }

    modifier onlyRouter() {
        require(msg.sender == address(router), "ONLY_ROUTER");
        _;
    }

    constructor(
        address _governanceManager,
        IPendleRouter _router,
        bytes32 _forgeId,
        address _rewardToken,
        address _rewardManager,
        address _yieldContractDeployer
    ) PermissionsV2(_governanceManager) {
        require(address(_router) != address(0), "ZERO_ADDRESS");
        require(_forgeId != 0x0, "ZERO_BYTES");
        TokenUtils.requireERC20(_rewardToken);
        router = _router;
        forgeId = _forgeId;
        IPendleData _dataTemp = IPendleRouter(_router).data();
        data = _dataTemp;
        rewardToken = IERC20(_rewardToken);
        rewardManager = IPendleRewardManager(_rewardManager);
        yieldContractDeployer = IPendleYieldContractDeployer(_yieldContractDeployer);
        pausingManager = _dataTemp.pausingManager();
    }

    function checkNotPaused(address _underlyingAsset, uint256 _expiry) internal virtual {
        (bool paused, ) = pausingManager.checkYieldContractStatus(
            forgeId,
            _underlyingAsset,
            _expiry
        );
        require(!paused, "YIELD_CONTRACT_PAUSED");
    }

    function setUpEmergencyMode(
        address,
        uint256,
        address
    ) external pure override {
        revert("FUNCTION_DEPRECIATED");
    }

    function setUpEmergencyModeV2(
        address _underlyingAsset,
        uint256 _expiry,
        address spender,
        bool extraFlag
    ) external virtual override {
        (, bool emergencyMode) = pausingManager.checkYieldContractStatus(
            forgeId,
            _underlyingAsset,
            _expiry
        );
        require(emergencyMode, "NOT_EMERGENCY");
        (address forgeEmergencyHandler, , ) = pausingManager.forgeEmergencyHandler();
        require(msg.sender == forgeEmergencyHandler, "NOT_EMERGENCY_HANDLER");
        IPendleYieldTokenHolderV2(yieldTokenHolders[_underlyingAsset][_expiry])
            .setUpEmergencyModeV2(spender, extraFlag);
    }

    function registerTokens(address[] calldata _underlyingAssets, uint256[][] calldata _tokenInfos)
        external
        virtual
        onlyGovernance
    {
        require(_underlyingAssets.length == _tokenInfos.length, "LENGTH_MISMATCH");
        for (uint256 i = 0; i < _underlyingAssets.length; ++i) {
            TokenInfo storage info = tokenInfo[_underlyingAssets[i]];
            require(!info.registered, "EXISTED_TOKENS");
            verifyToken(_underlyingAssets[i], _tokenInfos[i]);
            info.registered = true;
            info.container = _tokenInfos[i];
            emit RegisterTokens(forgeId, _underlyingAssets[i], _tokenInfos[i]);
        }
    }

    function verifyToken(address _underlyingAsset, uint256[] calldata _tokenInfo) public virtual;

    function newYieldContracts(address _underlyingAsset, uint256 _expiry)
        external
        virtual
        override
        onlyRouter
        returns (address ot, address xyt)
    {
        checkNotPaused(_underlyingAsset, _expiry);
        address yieldToken = getYieldBearingToken(_underlyingAsset);

        uint8 underlyingAssetDecimals = IPendleYieldToken(_underlyingAsset).decimals();

        ot = yieldContractDeployer.forgeOwnershipToken(
            _underlyingAsset,
            OT.concat(IPendleBaseToken(yieldToken).name(), _expiry, " "),
            OT.concat(IPendleBaseToken(yieldToken).symbol(), _expiry, "-"),
            underlyingAssetDecimals,
            _expiry
        );

        xyt = yieldContractDeployer.forgeFutureYieldToken(
            _underlyingAsset,
            XYT.concat(IPendleBaseToken(yieldToken).name(), _expiry, " "),
            XYT.concat(IPendleBaseToken(yieldToken).symbol(), _expiry, "-"),
            underlyingAssetDecimals,
            _expiry
        );

        yieldTokenHolders[_underlyingAsset][_expiry] = IPendleYieldContractDeployerV2(
            address(yieldContractDeployer)
        ).deployYieldTokenHolder(yieldToken, _expiry, tokenInfo[_underlyingAsset].container);

        data.storeTokens(forgeId, ot, xyt, _underlyingAsset, _expiry);

        emit NewYieldContracts(forgeId, _underlyingAsset, _expiry, ot, xyt, yieldToken);
    }

    function redeemAfterExpiry(
        address _user,
        address _underlyingAsset,
        uint256 _expiry
    ) external virtual override onlyRouter returns (uint256 redeemedAmount) {
        checkNotPaused(_underlyingAsset, _expiry);
        PendleTokens memory tokens = _getTokens(_underlyingAsset, _expiry);
        uint256 expiredOTamount = tokens.ot.balanceOf(_user);
        require(expiredOTamount > 0, "NOTHING_TO_REDEEM");

        tokens.ot.burn(_user, expiredOTamount);

        redeemedAmount = _calcTotalAfterExpiry(_underlyingAsset, _expiry, expiredOTamount);

        redeemedAmount = redeemedAmount.add(
            _beforeTransferDueInterests(tokens, _underlyingAsset, _expiry, _user, false)
        );

        _pushYieldToken(_underlyingAsset, _expiry, _user, redeemedAmount);

        emit RedeemYieldToken(
            forgeId,
            _underlyingAsset,
            _expiry,
            expiredOTamount,
            redeemedAmount,
            _user
        );
    }

    function redeemUnderlying(
        address _user,
        address _underlyingAsset,
        uint256 _expiry,
        uint256 _amountToRedeem
    ) external virtual override onlyRouter returns (uint256 redeemedAmount) {
        checkNotPaused(_underlyingAsset, _expiry);
        PendleTokens memory tokens = _getTokens(_underlyingAsset, _expiry);

        tokens.ot.burn(_user, _amountToRedeem);
        tokens.xyt.burn(_user, _amountToRedeem);

        redeemedAmount = _calcUnderlyingToRedeem(_underlyingAsset, _amountToRedeem).add(
            _beforeTransferDueInterests(tokens, _underlyingAsset, _expiry, _user, true)
        );

        _pushYieldToken(_underlyingAsset, _expiry, _user, redeemedAmount);

        emit RedeemYieldToken(
            forgeId,
            _underlyingAsset,
            _expiry,
            _amountToRedeem,
            redeemedAmount,
            _user
        );

        return redeemedAmount;
    }

    function redeemDueInterests(
        address _user,
        address _underlyingAsset,
        uint256 _expiry
    ) external virtual override onlyRouter returns (uint256 amountOut) {
        checkNotPaused(_underlyingAsset, _expiry);
        PendleTokens memory tokens = _getTokens(_underlyingAsset, _expiry);

        amountOut = _beforeTransferDueInterests(tokens, _underlyingAsset, _expiry, _user, false);

        _pushYieldToken(_underlyingAsset, _expiry, _user, amountOut);
    }

    function updateDueInterests(
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) external virtual override onlyXYT(_underlyingAsset, _expiry) nonReentrant {
        checkNotPaused(_underlyingAsset, _expiry);
        PendleTokens memory tokens = _getTokens(_underlyingAsset, _expiry);
        uint256 principal = tokens.xyt.balanceOf(_user);
        _updateDueInterests(principal, _underlyingAsset, _expiry, _user);
    }

    function updatePendingRewards(
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) external virtual override onlyOT(_underlyingAsset, _expiry) nonReentrant {
        checkNotPaused(_underlyingAsset, _expiry);
        rewardManager.updatePendingRewards(_underlyingAsset, _expiry, _user);
    }

    function mintOtAndXyt(
        address _underlyingAsset,
        uint256 _expiry,
        uint256 _amountToTokenize,
        address _to
    )
        external
        virtual
        override
        onlyRouter
        returns (
            address ot,
            address xyt,
            uint256 amountTokenMinted
        )
    {
        checkNotPaused(_underlyingAsset, _expiry);

        IPendleYieldTokenHolderV2(yieldTokenHolders[_underlyingAsset][_expiry]).afterReceiveTokens(
            _amountToTokenize
        );

        PendleTokens memory tokens = _getTokens(_underlyingAsset, _expiry);

        amountTokenMinted = _calcAmountToMint(_underlyingAsset, _amountToTokenize);

        tokens.ot.mint(_to, amountTokenMinted);

        tokens.xyt.mint(_to, amountTokenMinted);

        emit MintYieldTokens(
            forgeId,
            _underlyingAsset,
            _expiry,
            _amountToTokenize,
            amountTokenMinted,
            _to
        );
        return (address(tokens.ot), address(tokens.xyt), amountTokenMinted);
    }

    function withdrawForgeFee(address _underlyingAsset, uint256 _expiry)
        external
        virtual
        override
        onlyGovernance
    {
        checkNotPaused(_underlyingAsset, _expiry);
        _updateForgeFee(_underlyingAsset, _expiry, 0);
        uint256 _totalFee = totalFee[_underlyingAsset][_expiry];
        totalFee[_underlyingAsset][_expiry] = 0;

        address treasuryAddress = data.treasury();
        _pushYieldToken(_underlyingAsset, _expiry, treasuryAddress, _totalFee);
        emit ForgeFeeWithdrawn(forgeId, _underlyingAsset, _expiry, _totalFee);
    }

    function getYieldBearingToken(address _underlyingAsset)
        public
        virtual
        override
        returns (address);

    function _beforeTransferDueInterests(
        PendleTokens memory _tokens,
        address _underlyingAsset,
        uint256 _expiry,
        address _user,
        bool _skipUpdateDueInterests
    ) internal virtual returns (uint256 amountOut) {
        uint256 principal = _tokens.xyt.balanceOf(_user);

        if (!_skipUpdateDueInterests) {
            _updateDueInterests(principal, _underlyingAsset, _expiry, _user);
        }

        amountOut = dueInterests[_underlyingAsset][_expiry][_user];
        dueInterests[_underlyingAsset][_expiry][_user] = 0;

        uint256 forgeFee = data.forgeFee();
        uint256 forgeFeeAmount;
        if (forgeFee > 0) {
            forgeFeeAmount = amountOut.rmul(forgeFee);
            amountOut = amountOut.sub(forgeFeeAmount);
            _updateForgeFee(_underlyingAsset, _expiry, forgeFeeAmount);
        }

        emit DueInterestsSettled(
            forgeId,
            _underlyingAsset,
            _expiry,
            amountOut,
            forgeFeeAmount,
            _user
        );
    }

    function _pushYieldToken(
        address _underlyingAsset,
        uint256 _expiry,
        address _user,
        uint256 _amount
    ) internal virtual {
        if (_amount == 0) return;
        PendleTokens memory tokens = _getTokens(_underlyingAsset, _expiry);
        uint256 otBalance = tokens.ot.totalSupply();
        uint256 minNYieldAfterPush = block.timestamp < _expiry
            ? _calcUnderlyingToRedeem(_underlyingAsset, otBalance)
            : _calcTotalAfterExpiry(_underlyingAsset, _expiry, otBalance);
        IPendleYieldTokenHolderV2(yieldTokenHolders[_underlyingAsset][_expiry]).pushYieldTokens(
            _user,
            _amount,
            minNYieldAfterPush
        );
    }

    function _getTokens(address _underlyingAsset, uint256 _expiry)
        internal
        view
        virtual
        returns (PendleTokens memory _tokens)
    {
        (_tokens.ot, _tokens.xyt) = data.getPendleYieldTokens(forgeId, _underlyingAsset, _expiry);
    }

    function _allowedToWithdraw(address) internal pure virtual override returns (bool allowed) {
        allowed = true;
    }

    function _updateDueInterests(
        uint256 _principal,
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) internal virtual;

    function _updateForgeFee(
        address _underlyingAsset,
        uint256 _expiry,
        uint256 _feeAmount
    ) internal virtual;

    function _calcTotalAfterExpiry(
        address _underlyingAsset,
        uint256 _expiry,
        uint256 redeemedAmount
    ) internal virtual returns (uint256 totalAfterExpiry);

    function _calcUnderlyingToRedeem(address, uint256 _amountToRedeem)
        internal
        virtual
        returns (uint256 underlyingToRedeem);

    function _calcAmountToMint(address, uint256 _amountToTokenize)
        internal
        virtual
        returns (uint256 amountToMint);
}// GPL-2.0-or-later
pragma solidity 0.7.6;

library UniswapV2Library {

    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {

        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    function pairFor(
        address factory,
        address tokenA,
        address tokenB,
        bytes32 codeHash
    ) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex"ff",
                        factory,
                        keccak256(abi.encodePacked(token0, token1)),
                        codeHash
                    )
                )
            )
        );
    }
}// BUSL-1.1
pragma solidity 0.7.6;


contract PendleUniswapV2Forge is PendleForgeBaseV2, IPendleGenericForge {

    using SafeMath for uint256;
    using Math for uint256;

    mapping(address => uint256) public lastRateForUnderlyingAsset;
    mapping(address => mapping(uint256 => uint256)) public lastRateBeforeExpiry;
    mapping(address => mapping(uint256 => mapping(address => uint256))) public lastRate;
    bytes32 public immutable codeHash;
    address public immutable pairFactory;

    constructor(
        address _governanceManager,
        IPendleRouter _router,
        bytes32 _forgeId,
        address _rewardToken,
        address _rewardManager,
        address _yieldContractDeployer,
        bytes32 _codeHash,
        address _pairFactory
    )
        PendleForgeBaseV2(
            _governanceManager,
            _router,
            _forgeId,
            _rewardToken,
            _rewardManager,
            _yieldContractDeployer
        )
    {
        codeHash = _codeHash;
        pairFactory = _pairFactory;
    }

    function verifyToken(address _underlyingAsset, uint256[] calldata _tokenInfo)
        public
        virtual
        override
    {

        require(
            _tokenInfo.length == 1 && address(_tokenInfo[0]) == _underlyingAsset,
            "INVALID_TOKEN_INFO"
        );

        IUniswapV2Pair pair = IUniswapV2Pair(_underlyingAsset);
        address poolAddr = UniswapV2Library.pairFor(
            pairFactory,
            pair.token0(),
            pair.token1(),
            codeHash
        );
        require(poolAddr == _underlyingAsset, "INVALID_TOKEN_ADDR");
    }

    function getExchangeRate(address _underlyingAsset) public override returns (uint256 rate) {

        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(_underlyingAsset).getReserves();

        uint256 currentK = Math.sqrt(reserve0.mul(reserve1));
        uint256 totalSupply = IUniswapV2Pair(_underlyingAsset).totalSupply();
        rate = Math.max(currentK.rdiv(totalSupply), lastRateForUnderlyingAsset[_underlyingAsset]);
        lastRateForUnderlyingAsset[_underlyingAsset] = rate;
    }

    function getYieldBearingToken(address _underlyingAsset)
        public
        view
        override(IPendleForge, PendleForgeBaseV2)
        returns (address yieldBearingToken)
    {

        require(tokenInfo[_underlyingAsset].registered, "INVALID_UNDERLYING_ASSET");
        return _underlyingAsset;
    }

    function _calcTotalAfterExpiry(
        address _underlyingAsset,
        uint256 _expiry,
        uint256 _redeemedAmount
    ) internal view override returns (uint256 totalAfterExpiry) {

        totalAfterExpiry = _redeemedAmount.rdiv(lastRateBeforeExpiry[_underlyingAsset][_expiry]);
    }

    function getExchangeRateBeforeExpiry(address _underlyingAsset, uint256 _expiry)
        internal
        returns (uint256 exchangeRate)
    {

        if (block.timestamp > _expiry) {
            return lastRateBeforeExpiry[_underlyingAsset][_expiry];
        }
        exchangeRate = getExchangeRate(_underlyingAsset);

        lastRateBeforeExpiry[_underlyingAsset][_expiry] = exchangeRate;
    }

    function _calcUnderlyingToRedeem(address _underlyingAsset, uint256 _amountToRedeem)
        internal
        override
        returns (uint256 underlyingToRedeem)
    {

        underlyingToRedeem = _amountToRedeem.rdiv(getExchangeRate(_underlyingAsset));
    }

    function _calcAmountToMint(address _underlyingAsset, uint256 _amountToTokenize)
        internal
        override
        returns (uint256 amountToMint)
    {

        amountToMint = _amountToTokenize.rmul(getExchangeRate(_underlyingAsset));
    }

    function _updateDueInterests(
        uint256 _principal,
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) internal override {

        uint256 prevRate = lastRate[_underlyingAsset][_expiry][_user];
        uint256 currentRate = getExchangeRateBeforeExpiry(_underlyingAsset, _expiry);

        lastRate[_underlyingAsset][_expiry][_user] = currentRate;
        if (prevRate == 0 || prevRate == currentRate) {
            return;
        }

        uint256 interestFromXyt = _principal.mul(currentRate.sub(prevRate)).rdiv(
            prevRate.mul(currentRate)
        );

        dueInterests[_underlyingAsset][_expiry][_user] = dueInterests[_underlyingAsset][_expiry][
            _user
        ]
        .add(interestFromXyt);
    }

    function _updateForgeFee(
        address _underlyingAsset,
        uint256 _expiry,
        uint256 _feeAmount
    ) internal override {

        totalFee[_underlyingAsset][_expiry] = totalFee[_underlyingAsset][_expiry].add(_feeAmount);
    }
}// MIT
pragma solidity 0.7.6;

interface IMasterChef {

    struct UserInfo {
        uint256 amount;
        int256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accSushiPerShare;
    }

    function userInfo(uint256 pid, address user) external view returns (UserInfo calldata);


    function poolInfo(uint256 pid) external view returns (PoolInfo calldata);


    function deposit(uint256 pid, uint256 amount) external;


    function withdraw(uint256 pid, uint256 amount) external;


    function emergencyWithdraw(uint256 pid) external;

}// BUSL-1.1
pragma solidity 0.7.6;


contract PendleSushiswapComplexForge is PendleUniswapV2Forge {

    IMasterChef public immutable masterChef;

    constructor(
        address _governanceManager,
        IPendleRouter _router,
        bytes32 _forgeId,
        address _rewardToken,
        address _rewardManager,
        address _yieldContractDeployer,
        bytes32 _codeHash,
        address _pairFactory,
        address _masterChef
    )
        PendleUniswapV2Forge(
            _governanceManager,
            _router,
            _forgeId,
            _rewardToken,
            _rewardManager,
            _yieldContractDeployer,
            _codeHash,
            _pairFactory
        )
    {
        masterChef = IMasterChef(_masterChef);
    }

    function verifyToken(address _underlyingAsset, uint256[] calldata _tokenInfo)
        public
        virtual
        override
    {

        require(_tokenInfo.length == 1, "INVALID_TOKEN_INFO");
        uint256 pid = _tokenInfo[0];
        require(
            address(masterChef.poolInfo(pid).lpToken) == _underlyingAsset,
            "INVALID_TOKEN_INFO"
        );

        IUniswapV2Pair pair = IUniswapV2Pair(_underlyingAsset);
        address poolAddr = UniswapV2Library.pairFor(
            pairFactory,
            pair.token0(),
            pair.token1(),
            codeHash
        );
        require(poolAddr == _underlyingAsset, "INVALID_TOKEN_ADDR");
    }
}