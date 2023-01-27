
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

interface IPendleLiquidityMining {

    event Funded(uint256[] _rewards, uint256 numberOfEpochs);
    event RewardsToppedUp(uint256[] _epochIds, uint256[] _rewards);
    event AllocationSettingSet(uint256[] _expiries, uint256[] _allocationNumerators);
    event Staked(uint256 expiry, address user, uint256 amount);
    event Withdrawn(uint256 expiry, address user, uint256 amount);
    event PendleRewardsSettled(uint256 expiry, address user, uint256 amount);

    function fund(uint256[] calldata rewards) external;


    function topUpRewards(uint256[] calldata _epochIds, uint256[] calldata _rewards) external;


    function stake(uint256 expiry, uint256 amount) external returns (address);


    function stakeWithPermit(
        uint256 expiry,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (address);


    function withdraw(uint256 expiry, uint256 amount) external;


    function redeemRewards(uint256 expiry, address user) external returns (uint256 rewards);


    function redeemLpInterests(uint256 expiry, address user)
        external
        returns (uint256 dueInterests);


    function setUpEmergencyMode(uint256[] calldata expiries, address spender) external;


    function readUserExpiries(address user) external view returns (uint256[] memory expiries);


    function getBalances(uint256 expiry, address user) external view returns (uint256);


    function lpHolderForExpiry(uint256 expiry) external view returns (address);


    function startTime() external view returns (uint256);


    function epochDuration() external view returns (uint256);


    function totalRewardsForEpoch(uint256) external view returns (uint256);


    function numberOfEpochs() external view returns (uint256);


    function vestingEpochs() external view returns (uint256);


    function baseToken() external view returns (address);


    function underlyingAsset() external view returns (address);


    function underlyingYieldToken() external view returns (address);


    function pendleTokenAddress() external view returns (address);


    function marketFactoryId() external view returns (bytes32);


    function forgeId() external view returns (bytes32);


    function forge() external view returns (address);


    function readAllExpiriesLength() external view returns (uint256);

}// MIT
pragma solidity 0.7.6;


contract PendleRedeemProxy {

    IPendleRouter public immutable router;

    constructor(address _router) {
        require(_router != address(0), "ZERO_ADDRESS");
        router = IPendleRouter(_router);
    }

    function redeem(
        address[] calldata _xyts,
        address[] calldata _markets,
        address[] calldata _liqMiningContracts,
        uint256[] calldata _expiries,
        uint256 _liqMiningRewardsCount
    )
        external
        returns (
            uint256[] memory xytInterests,
            uint256[] memory marketInterests,
            uint256[] memory rewards,
            uint256[] memory liqMiningInterests
        )
    {

        xytInterests = redeemXyts(_xyts);
        marketInterests = redeemMarkets(_markets);

        (rewards, liqMiningInterests) = redeemLiqMining(
            _liqMiningContracts,
            _expiries,
            _liqMiningRewardsCount
        );
    }

    function redeemXyts(address[] calldata xyts) public returns (uint256[] memory xytInterests) {

        xytInterests = new uint256[](xyts.length);
        for (uint256 i = 0; i < xyts.length; i++) {
            IPendleYieldToken xyt = IPendleYieldToken(xyts[i]);
            bytes32 forgeId = IPendleForge(xyt.forge()).forgeId();
            address underlyingAsset = xyt.underlyingAsset();
            uint256 expiry = xyt.expiry();
            xytInterests[i] = router.redeemDueInterests(
                forgeId,
                underlyingAsset,
                expiry,
                msg.sender
            );
        }
    }

    function redeemMarkets(address[] calldata markets)
        public
        returns (uint256[] memory marketInterests)
    {

        uint256 marketCount = markets.length;
        marketInterests = new uint256[](marketCount);
        for (uint256 i = 0; i < marketCount; i++) {
            marketInterests[i] = router.redeemLpInterests(markets[i], msg.sender);
        }
    }

    function redeemLiqMining(
        address[] calldata liqMiningContracts,
        uint256[] calldata expiries,
        uint256 liqMiningRewardsCount
    ) public returns (uint256[] memory rewards, uint256[] memory liqMiningInterests) {

        require(liqMiningRewardsCount <= liqMiningContracts.length, "INVALID_REWARDS_COUNT");
        require(expiries.length == liqMiningContracts.length, "ARRAY_LENGTH_MISMATCH");

        rewards = new uint256[](liqMiningRewardsCount);
        for (uint256 i = 0; i < liqMiningRewardsCount; i++) {
            rewards[i] = IPendleLiquidityMining(liqMiningContracts[i]).redeemRewards(
                expiries[i],
                msg.sender
            );
        }

        uint256 liqMiningInterestsCount = liqMiningContracts.length - liqMiningRewardsCount;
        liqMiningInterests = new uint256[](liqMiningInterestsCount);
        for (uint256 i = 0; i < liqMiningInterestsCount; i++) {
            uint256 arrayIndex = i + liqMiningRewardsCount;
            liqMiningInterests[i] = IPendleLiquidityMining(liqMiningContracts[arrayIndex])
                .redeemLpInterests(expiries[arrayIndex], msg.sender);
        }
    }
}