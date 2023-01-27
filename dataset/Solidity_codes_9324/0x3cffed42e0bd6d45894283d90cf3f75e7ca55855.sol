
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
}// GPL-2.0-or-later
pragma solidity ^0.7.0;
pragma abicoder v2;


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

interface IPendleLpHolder {

    function underlyingYieldToken() external returns (address);


    function pendleMarket() external returns (address);


    function sendLp(address user, uint256 amount) external;


    function sendInterests(address user, uint256 amount) external;


    function redeemLpInterests() external;


    function setUpEmergencyMode(address spender) external;

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
}// BUSL-1.1
pragma solidity 0.7.6;


contract PendleLpHolder is IPendleLpHolder, WithdrawableV2 {

    using SafeERC20 for IERC20;

    address private immutable pendleLiquidityMining;
    address public immutable override underlyingYieldToken;
    address public immutable override pendleMarket;
    address private immutable router;

    modifier onlyLiquidityMining() {

        require(msg.sender == pendleLiquidityMining, "ONLY_LIQUIDITY_MINING");
        _;
    }

    constructor(
        address _governanceManager,
        address _pendleMarket,
        address _router,
        address _underlyingYieldToken
    ) PermissionsV2(_governanceManager) {
        require(
            _pendleMarket != address(0) &&
                _router != address(0) &&
                _underlyingYieldToken != address(0),
            "ZERO_ADDRESS"
        );
        pendleMarket = _pendleMarket;
        router = _router;
        pendleLiquidityMining = msg.sender;
        underlyingYieldToken = _underlyingYieldToken;
    }

    function sendLp(address user, uint256 amount) external override onlyLiquidityMining {

        IERC20(pendleMarket).safeTransfer(user, amount);
    }

    function sendInterests(address user, uint256 amount) external override onlyLiquidityMining {

        IERC20(underlyingYieldToken).safeTransfer(user, amount);
    }

    function redeemLpInterests() external override onlyLiquidityMining {

        IPendleRouter(router).redeemLpInterests(pendleMarket, address(this));
    }

    function _allowedToWithdraw(address _token) internal view override returns (bool allowed) {

        allowed = _token != underlyingYieldToken && _token != pendleMarket;
    }

    function setUpEmergencyMode(address spender) external override onlyLiquidityMining {

        IERC20(underlyingYieldToken).safeApprove(spender, type(uint256).max);
        IERC20(pendleMarket).safeApprove(spender, type(uint256).max);
    }
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

interface IPendleWhitelist {

    event AddedToWhiteList(address);
    event RemovedFromWhiteList(address);

    function whitelisted(address) external view returns (bool);


    function addToWhitelist(address[] calldata _addresses) external;


    function removeFromWhitelist(address[] calldata _addresses) external;


    function getWhitelist() external view returns (address[] memory list);

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


abstract contract PendleLiquidityMiningBase is
    IPendleLiquidityMining,
    WithdrawableV2,
    ReentrancyGuard
{
    using Math for uint256;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserExpiries {
        uint256[] expiries;
        mapping(uint256 => bool) hasExpiry;
    }

    struct EpochData {
        mapping(uint256 => uint256) stakeUnitsForExpiry;
        mapping(uint256 => uint256) lastUpdatedForExpiry;
        mapping(address => uint256) availableRewardsForUser;
        mapping(address => mapping(uint256 => uint256)) stakeUnitsForUser;
        uint256 settingId;
        uint256 totalRewards;
    }

    struct ExpiryData {
        mapping(address => uint256) lastTimeUserStakeUpdated; // map user => time
        mapping(address => uint256) lastEpochClaimed;
        uint256 totalStakeLP;
        address lpHolder;
        mapping(address => uint256) balances;
        uint256 lastNYield;
        uint256 paramL;
        mapping(address => uint256) lastParamL;
        mapping(address => uint256) dueInterests;
    }

    struct LatestSetting {
        uint256 id;
        uint256 firstEpochToApply;
    }

    IPendleWhitelist public immutable whitelist;
    IPendleRouter public immutable router;
    IPendleData public immutable data;
    address public immutable override pendleTokenAddress;
    bytes32 public immutable override forgeId;
    address public immutable override forge;
    bytes32 public immutable override marketFactoryId;
    IPendlePausingManager private immutable pausingManager;

    address public immutable override underlyingAsset;
    address public immutable override underlyingYieldToken;
    address public immutable override baseToken;
    uint256 public immutable override startTime;
    uint256 public immutable override epochDuration;
    uint256 public override numberOfEpochs;
    uint256 public immutable override vestingEpochs;
    bool public funded;

    uint256[] public allExpiries;
    uint256 private constant ALLOCATION_DENOMINATOR = 1_000_000_000;
    uint256 internal constant MULTIPLIER = 10**20;

    mapping(uint256 => mapping(uint256 => uint256)) public allocationSettings;
    LatestSetting public latestSetting;

    mapping(uint256 => ExpiryData) internal expiryData;
    mapping(uint256 => EpochData) private epochData;
    mapping(address => UserExpiries) private userExpiries;

    modifier isFunded() {
        require(funded, "NOT_FUNDED");
        _;
    }

    modifier nonContractOrWhitelisted() {
        bool isEOA = !Address.isContract(msg.sender) && tx.origin == msg.sender;
        require(isEOA || whitelist.whitelisted(msg.sender), "CONTRACT_NOT_WHITELISTED");
        _;
    }

    constructor(
        address _governanceManager,
        address _pausingManager,
        address _whitelist,
        address _pendleTokenAddress,
        address _router,
        bytes32 _marketFactoryId,
        bytes32 _forgeId,
        address _underlyingAsset,
        address _baseToken,
        uint256 _startTime,
        uint256 _epochDuration,
        uint256 _vestingEpochs
    ) PermissionsV2(_governanceManager) {
        require(_startTime > block.timestamp, "START_TIME_OVER");
        require(IERC20(_pendleTokenAddress).totalSupply() > 0, "INVALID_ERC20");
        require(IERC20(_underlyingAsset).totalSupply() > 0, "INVALID_ERC20");
        require(IERC20(_baseToken).totalSupply() > 0, "INVALID_ERC20");
        require(_vestingEpochs > 0, "INVALID_VESTING_EPOCHS");

        pendleTokenAddress = _pendleTokenAddress;
        router = IPendleRouter(_router);
        whitelist = IPendleWhitelist(_whitelist);
        IPendleData _dataTemp = IPendleRouter(_router).data();
        data = _dataTemp;
        require(
            _dataTemp.getMarketFactoryAddress(_marketFactoryId) != address(0),
            "INVALID_MARKET_FACTORY_ID"
        );
        require(_dataTemp.getForgeAddress(_forgeId) != address(0), "INVALID_FORGE_ID");

        address _forgeTemp = _dataTemp.getForgeAddress(_forgeId);
        forge = _forgeTemp;
        underlyingYieldToken = IPendleForge(_forgeTemp).getYieldBearingToken(_underlyingAsset);
        pausingManager = IPendlePausingManager(_pausingManager);
        marketFactoryId = _marketFactoryId;
        forgeId = _forgeId;
        underlyingAsset = _underlyingAsset;
        baseToken = _baseToken;
        startTime = _startTime;
        epochDuration = _epochDuration;
        vestingEpochs = _vestingEpochs;
    }

    function setUpEmergencyMode(uint256[] calldata expiries, address spender) external override {
        (, bool emergencyMode) = pausingManager.checkLiqMiningStatus(address(this));
        require(emergencyMode, "NOT_EMERGENCY");

        (address liqMiningEmergencyHandler, , ) = pausingManager.liqMiningEmergencyHandler();
        require(msg.sender == liqMiningEmergencyHandler, "NOT_EMERGENCY_HANDLER");

        for (uint256 i = 0; i < expiries.length; i++) {
            IPendleLpHolder(expiryData[expiries[i]].lpHolder).setUpEmergencyMode(spender);
        }
        IERC20(pendleTokenAddress).approve(spender, type(uint256).max);
    }

    function fund(uint256[] calldata _rewards) external override onlyGovernance {
        checkNotPaused();
        require(latestSetting.id > 0, "NO_ALLOC_SETTING");
        require(_getCurrentEpochId() <= numberOfEpochs, "LAST_EPOCH_OVER");

        uint256 nNewEpochs = _rewards.length;
        uint256 totalFunded;
        for (uint256 i = 0; i < nNewEpochs; i++) {
            totalFunded = totalFunded.add(_rewards[i]);
            epochData[numberOfEpochs + i + 1].totalRewards = _rewards[i];
        }

        require(totalFunded > 0, "ZERO_FUND");
        funded = true;
        numberOfEpochs = numberOfEpochs.add(nNewEpochs);
        IERC20(pendleTokenAddress).safeTransferFrom(msg.sender, address(this), totalFunded);
        emit Funded(_rewards, numberOfEpochs);
    }

    function topUpRewards(uint256[] calldata _epochIds, uint256[] calldata _rewards)
        external
        override
        onlyGovernance
        isFunded
    {
        checkNotPaused();
        require(latestSetting.id > 0, "NO_ALLOC_SETTING");
        require(_epochIds.length == _rewards.length, "INVALID_ARRAYS");

        uint256 curEpoch = _getCurrentEpochId();
        uint256 endEpoch = numberOfEpochs;
        uint256 totalTopUp;

        for (uint256 i = 0; i < _epochIds.length; i++) {
            require(curEpoch < _epochIds[i] && _epochIds[i] <= endEpoch, "INVALID_EPOCH_ID");
            totalTopUp = totalTopUp.add(_rewards[i]);
            epochData[_epochIds[i]].totalRewards = epochData[_epochIds[i]].totalRewards.add(
                _rewards[i]
            );
        }

        require(totalTopUp > 0, "ZERO_FUND");
        IERC20(pendleTokenAddress).safeTransferFrom(msg.sender, address(this), totalTopUp);
        emit RewardsToppedUp(_epochIds, _rewards);
    }

    function setAllocationSetting(
        uint256[] calldata _expiries,
        uint256[] calldata _allocationNumerators
    ) external onlyGovernance {
        checkNotPaused();
        require(_expiries.length == _allocationNumerators.length, "INVALID_ALLOCATION");
        if (latestSetting.id == 0) {
            require(block.timestamp < startTime, "LATE_FIRST_ALLOCATION");
        }

        uint256 curEpoch = _getCurrentEpochId();
        for (uint256 i = latestSetting.firstEpochToApply; i <= curEpoch; i++) {
            epochData[i].settingId = latestSetting.id;
        }

        latestSetting.firstEpochToApply = curEpoch + 1;
        latestSetting.id++;

        uint256 sumAllocationNumerators;
        for (uint256 _i = 0; _i < _expiries.length; _i++) {
            allocationSettings[latestSetting.id][_expiries[_i]] = _allocationNumerators[_i];
            sumAllocationNumerators = sumAllocationNumerators.add(_allocationNumerators[_i]);
        }
        require(sumAllocationNumerators == ALLOCATION_DENOMINATOR, "INVALID_ALLOCATION");
        emit AllocationSettingSet(_expiries, _allocationNumerators);
    }

    function stake(uint256 expiry, uint256 amount)
        external
        override
        isFunded
        nonReentrant
        nonContractOrWhitelisted
        returns (address newLpHoldingContractAddress)
    {
        checkNotPaused();
        newLpHoldingContractAddress = _stake(expiry, amount);
    }

    function stakeWithPermit(
        uint256 expiry,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        override
        isFunded
        nonReentrant
        nonContractOrWhitelisted
        returns (address newLpHoldingContractAddress)
    {
        checkNotPaused();
        address xyt = address(data.xytTokens(forgeId, underlyingAsset, expiry));
        address marketAddress = data.getMarket(marketFactoryId, xyt, baseToken);
        IPendleYieldToken(marketAddress).permit(
            msg.sender,
            address(this),
            amount,
            deadline,
            v,
            r,
            s
        );

        newLpHoldingContractAddress = _stake(expiry, amount);
    }

    function withdraw(uint256 expiry, uint256 amount) external override nonReentrant isFunded {
        checkNotPaused();
        uint256 curEpoch = _getCurrentEpochId();
        require(curEpoch > 0, "NOT_STARTED");
        require(amount != 0, "ZERO_AMOUNT");

        ExpiryData storage exd = expiryData[expiry];
        require(exd.balances[msg.sender] >= amount, "INSUFFICIENT_BALANCE");

        _pushLpToken(expiry, amount);
        emit Withdrawn(expiry, msg.sender, amount);
    }

    function redeemRewards(uint256 expiry, address user)
        external
        override
        isFunded
        nonReentrant
        returns (uint256 rewards)
    {
        checkNotPaused();
        uint256 curEpoch = _getCurrentEpochId();
        require(curEpoch > 0, "NOT_STARTED");
        require(user != address(0), "ZERO_ADDRESS");
        require(userExpiries[user].hasExpiry[expiry], "INVALID_EXPIRY");

        rewards = _beforeTransferPendingRewards(expiry, user);
        if (rewards != 0) {
            IERC20(pendleTokenAddress).safeTransfer(user, rewards);
        }
    }

    function redeemLpInterests(uint256 expiry, address user)
        external
        override
        nonReentrant
        returns (uint256 interests)
    {
        checkNotPaused();
        require(user != address(0), "ZERO_ADDRESS");
        require(userExpiries[user].hasExpiry[expiry], "INVALID_EXPIRY");
        interests = _beforeTransferDueInterests(expiry, user);
        _safeTransferYieldToken(expiry, user, interests);
    }

    function totalRewardsForEpoch(uint256 epochId)
        external
        view
        override
        returns (uint256 rewards)
    {
        rewards = epochData[epochId].totalRewards;
    }

    function readUserExpiries(address _user)
        external
        view
        override
        returns (uint256[] memory _expiries)
    {
        _expiries = userExpiries[_user].expiries;
    }

    function getBalances(uint256 expiry, address user) external view override returns (uint256) {
        return expiryData[expiry].balances[user];
    }

    function lpHolderForExpiry(uint256 expiry) external view override returns (address) {
        return expiryData[expiry].lpHolder;
    }

    function readExpiryData(uint256 expiry)
        external
        view
        returns (
            uint256 totalStakeLP,
            uint256 lastNYield,
            uint256 paramL,
            address lpHolder
        )
    {
        totalStakeLP = expiryData[expiry].totalStakeLP;
        lastNYield = expiryData[expiry].lastNYield;
        paramL = expiryData[expiry].paramL;
        lpHolder = expiryData[expiry].lpHolder;
    }

    function readUserSpecificExpiryData(uint256 expiry, address user)
        external
        view
        returns (
            uint256 lastTimeUserStakeUpdated,
            uint256 lastEpochClaimed,
            uint256 balances,
            uint256 lastParamL,
            uint256 dueInterests
        )
    {
        lastTimeUserStakeUpdated = expiryData[expiry].lastTimeUserStakeUpdated[user];
        lastEpochClaimed = expiryData[expiry].lastEpochClaimed[user];
        balances = expiryData[expiry].balances[user];
        lastParamL = expiryData[expiry].lastParamL[user];
        dueInterests = expiryData[expiry].dueInterests[user];
    }

    function readEpochData(uint256 epochId)
        external
        view
        returns (uint256 settingId, uint256 totalRewards)
    {
        settingId = epochData[epochId].settingId;
        totalRewards = epochData[epochId].totalRewards;
    }

    function readExpirySpecificEpochData(uint256 epochId, uint256 expiry)
        external
        view
        returns (uint256 stakeUnits, uint256 lastUpdatedForExpiry)
    {
        stakeUnits = epochData[epochId].stakeUnitsForExpiry[expiry];
        lastUpdatedForExpiry = epochData[epochId].lastUpdatedForExpiry[expiry];
    }

    function readAvailableRewardsForUser(uint256 epochId, address user)
        external
        view
        returns (uint256 availableRewardsForUser)
    {
        availableRewardsForUser = epochData[epochId].availableRewardsForUser[user];
    }

    function readStakeUnitsForUser(
        uint256 epochId,
        address user,
        uint256 expiry
    ) external view returns (uint256 stakeUnitsForUser) {
        stakeUnitsForUser = epochData[epochId].stakeUnitsForUser[user][expiry];
    }

    function readAllExpiriesLength() external view override returns (uint256 length) {
        length = allExpiries.length;
    }

    function checkNotPaused() internal {
        (bool paused, ) = pausingManager.checkLiqMiningStatus(address(this));
        require(!paused, "LIQ_MINING_PAUSED");
    }

    function _stake(uint256 expiry, uint256 amount)
        internal
        returns (address newLpHoldingContractAddress)
    {
        ExpiryData storage exd = expiryData[expiry];
        uint256 curEpoch = _getCurrentEpochId();
        require(curEpoch > 0, "NOT_STARTED");
        require(curEpoch <= numberOfEpochs, "INCENTIVES_PERIOD_OVER");
        require(amount != 0, "ZERO_AMOUNT");

        address xyt = address(data.xytTokens(forgeId, underlyingAsset, expiry));
        address marketAddress = data.getMarket(marketFactoryId, xyt, baseToken);
        require(xyt != address(0), "YT_NOT_FOUND");
        require(marketAddress != address(0), "MARKET_NOT_FOUND");

        if (exd.lpHolder == address(0)) {
            newLpHoldingContractAddress = _addNewExpiry(expiry, marketAddress);
        }

        if (!userExpiries[msg.sender].hasExpiry[expiry]) {
            userExpiries[msg.sender].expiries.push(expiry);
            userExpiries[msg.sender].hasExpiry[expiry] = true;
        }

        _pullLpToken(marketAddress, expiry, amount);
        emit Staked(expiry, msg.sender, amount);
    }

    function _updateStakeDataForExpiry(uint256 expiry) internal {
        uint256 _curEpoch = _getCurrentEpochId();

        for (uint256 i = Math.min(_curEpoch, numberOfEpochs); i > 0; i--) {
            uint256 epochEndTime = _endTimeOfEpoch(i);
            uint256 lastUpdatedForEpoch = epochData[i].lastUpdatedForExpiry[expiry];

            if (lastUpdatedForEpoch == epochEndTime) {
                break; // its already updated until this epoch, our job here is done
            }

            epochData[i].stakeUnitsForExpiry[expiry] = epochData[i].stakeUnitsForExpiry[expiry]
                .add(
                _calcUnitsStakeInEpoch(expiryData[expiry].totalStakeLP, lastUpdatedForEpoch, i)
            );
            epochData[i].lastUpdatedForExpiry[expiry] = Math.min(block.timestamp, epochEndTime);
        }
    }

    function _updatePendingRewards(uint256 expiry, address user) internal {
        _updateStakeDataForExpiry(expiry);
        ExpiryData storage exd = expiryData[expiry];

        if (exd.lastTimeUserStakeUpdated[user] == 0) {
            exd.lastTimeUserStakeUpdated[user] = block.timestamp;
            return;
        }

        uint256 _curEpoch = _getCurrentEpochId();
        uint256 _endEpoch = Math.min(numberOfEpochs, _curEpoch);

        bool _isEndEpochOver = (_curEpoch > numberOfEpochs);

        uint256 _startEpoch = _epochOfTimestamp(exd.lastTimeUserStakeUpdated[user]);

        for (uint256 epochId = _startEpoch; epochId <= _endEpoch; epochId++) {
            if (epochData[epochId].stakeUnitsForExpiry[expiry] == 0 && exd.totalStakeLP == 0) {
                break;
            }

            epochData[epochId].stakeUnitsForUser[user][expiry] = epochData[epochId]
                .stakeUnitsForUser[user][expiry]
                .add(
                _calcUnitsStakeInEpoch(
                    exd.balances[user],
                    exd.lastTimeUserStakeUpdated[user],
                    epochId
                )
            );

            if (epochId == _endEpoch && !_isEndEpochOver) {
                break;
            }


            require(epochData[epochId].stakeUnitsForExpiry[expiry] != 0, "INTERNAL_ERROR");

            uint256 rewardsPerVestingEpoch =
                _calcAmountRewardsForUserInEpoch(expiry, user, epochId);

            for (uint256 i = epochId + 1; i <= epochId + vestingEpochs; i++) {
                epochData[i].availableRewardsForUser[user] = epochData[i].availableRewardsForUser[
                    user
                ]
                    .add(rewardsPerVestingEpoch);
            }
        }

        exd.lastTimeUserStakeUpdated[user] = block.timestamp;
    }

    function _calcAmountRewardsForUserInEpoch(
        uint256 expiry,
        address user,
        uint256 epochId
    ) internal view returns (uint256 rewardsPerVestingEpoch) {
        uint256 settingId =
            epochId >= latestSetting.firstEpochToApply
                ? latestSetting.id
                : epochData[epochId].settingId;

        uint256 rewardsForThisExpiry =
            epochData[epochId].totalRewards.mul(allocationSettings[settingId][expiry]).div(
                ALLOCATION_DENOMINATOR
            );

        rewardsPerVestingEpoch = rewardsForThisExpiry
            .mul(epochData[epochId].stakeUnitsForUser[user][expiry])
            .div(epochData[epochId].stakeUnitsForExpiry[expiry])
            .div(vestingEpochs);
    }

    function _calcUnitsStakeInEpoch(
        uint256 lpAmount,
        uint256 _startTime,
        uint256 _epochId
    ) internal view returns (uint256 stakeUnitsForUser) {
        uint256 _endTime = block.timestamp;

        uint256 _l = Math.max(_startTime, _startTimeOfEpoch(_epochId));
        uint256 _r = Math.min(_endTime, _endTimeOfEpoch(_epochId));
        uint256 durationStakeThisEpoch = _r.subMax0(_l);

        return lpAmount.mul(durationStakeThisEpoch);
    }

    function _pullLpToken(
        address marketAddress,
        uint256 expiry,
        uint256 amount
    ) internal {
        _updatePendingRewards(expiry, msg.sender);
        _updateDueInterests(expiry, msg.sender);

        ExpiryData storage exd = expiryData[expiry];
        exd.balances[msg.sender] = exd.balances[msg.sender].add(amount);
        exd.totalStakeLP = exd.totalStakeLP.add(amount);

        IERC20(marketAddress).safeTransferFrom(msg.sender, expiryData[expiry].lpHolder, amount);
    }

    function _pushLpToken(uint256 expiry, uint256 amount) internal {
        _updatePendingRewards(expiry, msg.sender);
        _updateDueInterests(expiry, msg.sender);

        ExpiryData storage exd = expiryData[expiry];
        exd.balances[msg.sender] = exd.balances[msg.sender].sub(amount);
        exd.totalStakeLP = exd.totalStakeLP.sub(amount);

        IPendleLpHolder(expiryData[expiry].lpHolder).sendLp(msg.sender, amount);
    }

    function _beforeTransferDueInterests(uint256 expiry, address user)
        internal
        returns (uint256 amountOut)
    {
        ExpiryData storage exd = expiryData[expiry];

        _updateDueInterests(expiry, user);

        amountOut = exd.dueInterests[user];
        exd.dueInterests[user] = 0;

        exd.lastNYield = exd.lastNYield.subMax0(amountOut);
    }

    function _safeTransferYieldToken(
        uint256 _expiry,
        address _user,
        uint256 _amount
    ) internal {
        if (_amount == 0) return;
        _amount = Math.min(
            _amount,
            IERC20(underlyingYieldToken).balanceOf(expiryData[_expiry].lpHolder)
        );
        IPendleLpHolder(expiryData[_expiry].lpHolder).sendInterests(_user, _amount);
    }

    function _beforeTransferPendingRewards(uint256 expiry, address user)
        internal
        returns (uint256 amountOut)
    {
        _updatePendingRewards(expiry, user);

        uint256 _lastEpoch = Math.min(_getCurrentEpochId(), numberOfEpochs + vestingEpochs);
        for (uint256 i = expiryData[expiry].lastEpochClaimed[user]; i <= _lastEpoch; i++) {
            if (epochData[i].availableRewardsForUser[user] > 0) {
                amountOut = amountOut.add(epochData[i].availableRewardsForUser[user]);
                epochData[i].availableRewardsForUser[user] = 0;
            }
        }

        expiryData[expiry].lastEpochClaimed[user] = _lastEpoch;
        emit PendleRewardsSettled(expiry, user, amountOut);
        return amountOut;
    }

    function checkNeedUpdateParamL(uint256 expiry) internal returns (bool) {
        return _getIncomeIndexIncreaseRate(expiry) > data.interestUpdateRateDeltaForMarket();
    }

    function _updateParamL(uint256 expiry) internal {
        ExpiryData storage exd = expiryData[expiry];

        if (!checkNeedUpdateParamL(expiry)) return;

        IPendleLpHolder(exd.lpHolder).redeemLpInterests();

        uint256 currentNYield = IERC20(underlyingYieldToken).balanceOf(exd.lpHolder);
        (uint256 firstTerm, uint256 paramR) = _getFirstTermAndParamR(expiry, currentNYield);

        uint256 secondTerm;

        if (exd.totalStakeLP != 0) secondTerm = paramR.mul(MULTIPLIER).div(exd.totalStakeLP);

        exd.paramL = firstTerm.add(secondTerm);
        exd.lastNYield = currentNYield;
    }

    function _addNewExpiry(uint256 expiry, address marketAddress)
        internal
        returns (address newLpHoldingContractAddress)
    {
        allExpiries.push(expiry);
        newLpHoldingContractAddress = address(
            new PendleLpHolder(
                address(governanceManager),
                marketAddress,
                address(router),
                underlyingYieldToken
            )
        );
        expiryData[expiry].lpHolder = newLpHoldingContractAddress;
        _afterAddingNewExpiry(expiry);
    }

    function _getCurrentEpochId() internal view returns (uint256) {
        return _epochOfTimestamp(block.timestamp);
    }

    function _epochOfTimestamp(uint256 t) internal view returns (uint256) {
        if (t < startTime) return 0;
        return (t.sub(startTime)).div(epochDuration).add(1);
    }

    function _startTimeOfEpoch(uint256 t) internal view returns (uint256) {
        return startTime.add((t.sub(1)).mul(epochDuration));
    }

    function _endTimeOfEpoch(uint256 t) internal view returns (uint256) {
        return startTime.add(t.mul(epochDuration));
    }

    function _allowedToWithdraw(address _token) internal view override returns (bool allowed) {
        allowed = _token != pendleTokenAddress;
    }

    function _updateDueInterests(uint256 expiry, address user) internal virtual;

    function _getFirstTermAndParamR(uint256 expiry, uint256 currentNYield)
        internal
        virtual
        returns (uint256 firstTerm, uint256 paramR);

    function _afterAddingNewExpiry(uint256 expiry) internal virtual;

    function _getIncomeIndexIncreaseRate(uint256 expiry)
        internal
        virtual
        returns (uint256 increaseRate);
}// MIT

pragma solidity 0.7.6;

interface IPendleLiquidityMiningV2 {

    event Funded(uint256[] rewards, uint256 numberOfEpochs);
    event RewardsToppedUp(uint256[] epochIds, uint256[] rewards);
    event Staked(address user, uint256 amount);
    event Withdrawn(address user, uint256 amount);
    event PendleRewardsSettled(address user, uint256 amount);

    function fund(uint256[] calldata rewards) external;


    function topUpRewards(uint256[] calldata epochIds, uint256[] calldata rewards) external;


    function stake(address forAddr, uint256 amount) external;


    function withdraw(address toAddr, uint256 amount) external;


    function redeemRewards(address user) external returns (uint256 rewards);


    function redeemDueInterests(address user) external returns (uint256 amountOut);


    function setUpEmergencyMode(address spender, bool) external;


    function updateAndReadEpochData(uint256 epochId, address user)
        external
        returns (
            uint256 totalStakeUnits,
            uint256 totalRewards,
            uint256 lastUpdated,
            uint256 stakeUnitsForUser,
            uint256 availableRewardsForUser
        );


    function balances(address user) external view returns (uint256);


    function startTime() external view returns (uint256);


    function epochDuration() external view returns (uint256);


    function readEpochData(uint256 epochId, address user)
        external
        view
        returns (
            uint256 totalStakeUnits,
            uint256 totalRewards,
            uint256 lastUpdated,
            uint256 stakeUnitsForUser,
            uint256 availableRewardsForUser
        );


    function numberOfEpochs() external view returns (uint256);


    function vestingEpochs() external view returns (uint256);


    function stakeToken() external view returns (address);


    function yieldToken() external view returns (address);


    function pendleTokenAddress() external view returns (address);


    function totalStake() external view returns (uint256);


    function dueInterests(address) external view returns (uint256);


    function lastParamL(address) external view returns (uint256);


    function lastNYield() external view returns (uint256);


    function paramL() external view returns (uint256);

}// GPL-2.0-or-later
pragma solidity ^0.7.0;

library TokenUtils {

    function requireERC20(address tokenAddr) internal view {

        require(IERC20(tokenAddr).totalSupply() > 0, "INVALID_ERC20");
    }

    function requireERC20(IERC20 token) internal view {

        require(token.totalSupply() > 0, "INVALID_ERC20");
    }
}// BUSL-1.1
pragma solidity 0.7.6;


contract PendleLiquidityMiningBaseV2 is IPendleLiquidityMiningV2, WithdrawableV2, ReentrancyGuard {

    using Math for uint256;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct EpochData {
        uint256 totalStakeUnits;
        uint256 totalRewards;
        uint256 lastUpdated;
        mapping(address => uint256) stakeUnitsForUser;
        mapping(address => uint256) availableRewardsForUser;
    }

    IPendleWhitelist public immutable whitelist;
    IPendlePausingManager public immutable pausingManager;

    uint256 public override numberOfEpochs;
    uint256 public override totalStake;
    mapping(uint256 => EpochData) internal epochData;
    mapping(address => uint256) public override balances;
    mapping(address => uint256) public lastTimeUserStakeUpdated;
    mapping(address => uint256) public lastEpochClaimed;

    address public immutable override pendleTokenAddress;
    address public immutable override stakeToken;
    address public immutable override yieldToken;
    uint256 public immutable override startTime;
    uint256 public immutable override epochDuration;
    uint256 public immutable override vestingEpochs;
    uint256 public constant MULTIPLIER = 10**20;

    mapping(address => uint256) public override dueInterests;
    mapping(address => uint256) public override lastParamL;
    uint256 public override lastNYield;
    uint256 public override paramL;

    modifier hasStarted() {

        require(_getCurrentEpochId() > 0, "NOT_STARTED");
        _;
    }

    modifier nonContractOrWhitelisted() {

        bool isEOA = !Address.isContract(msg.sender) && tx.origin == msg.sender;
        require(isEOA || whitelist.whitelisted(msg.sender), "CONTRACT_NOT_WHITELISTED");
        _;
    }

    modifier isUserAllowedToUse() {

        (bool paused, ) = pausingManager.checkLiqMiningStatus(address(this));
        require(!paused, "LIQ_MINING_PAUSED");
        require(numberOfEpochs > 0, "NOT_FUNDED");
        require(_getCurrentEpochId() > 0, "NOT_STARTED");
        _;
    }

    constructor(
        address _governanceManager,
        address _pausingManager,
        address _whitelist,
        address _pendleTokenAddress,
        address _stakeToken,
        address _yieldToken,
        uint256 _startTime,
        uint256 _epochDuration,
        uint256 _vestingEpochs
    ) PermissionsV2(_governanceManager) {
        require(_startTime > block.timestamp, "INVALID_START_TIME");
        TokenUtils.requireERC20(_pendleTokenAddress);
        TokenUtils.requireERC20(_stakeToken);
        require(_vestingEpochs > 0, "INVALID_VESTING_EPOCHS");
        pausingManager = IPendlePausingManager(_pausingManager);
        whitelist = IPendleWhitelist(_whitelist);
        pendleTokenAddress = _pendleTokenAddress;

        stakeToken = _stakeToken;
        yieldToken = _yieldToken;
        startTime = _startTime;
        epochDuration = _epochDuration;
        vestingEpochs = _vestingEpochs;
        paramL = 1;
    }

    function setUpEmergencyMode(address spender, bool) external virtual override {

        (, bool emergencyMode) = pausingManager.checkLiqMiningStatus(address(this));
        require(emergencyMode, "NOT_EMERGENCY");

        (address liqMiningEmergencyHandler, , ) = pausingManager.liqMiningEmergencyHandler();
        require(msg.sender == liqMiningEmergencyHandler, "NOT_EMERGENCY_HANDLER");

        IERC20(pendleTokenAddress).safeApprove(spender, type(uint256).max);
        IERC20(stakeToken).safeApprove(spender, type(uint256).max);
        if (yieldToken != address(0)) IERC20(yieldToken).safeApprove(spender, type(uint256).max);
    }

    function fund(uint256[] calldata rewards) external virtual override onlyGovernance {

        require(_getCurrentEpochId() <= numberOfEpochs, "LAST_EPOCH_OVER");

        uint256 nNewEpochs = rewards.length;
        uint256 totalFunded;
        for (uint256 i = 0; i < nNewEpochs; i++) {
            totalFunded = totalFunded.add(rewards[i]);
            epochData[numberOfEpochs + i + 1].totalRewards = rewards[i];
        }

        numberOfEpochs = numberOfEpochs.add(nNewEpochs);
        IERC20(pendleTokenAddress).safeTransferFrom(msg.sender, address(this), totalFunded);
        emit Funded(rewards, numberOfEpochs);
    }

    function topUpRewards(uint256[] calldata epochIds, uint256[] calldata rewards)
        external
        virtual
        override
        onlyGovernance
    {

        require(epochIds.length == rewards.length, "INVALID_ARRAYS");

        uint256 curEpoch = _getCurrentEpochId();
        uint256 endEpoch = numberOfEpochs;
        uint256 totalTopUp;

        for (uint256 i = 0; i < epochIds.length; i++) {
            require(curEpoch < epochIds[i] && epochIds[i] <= endEpoch, "INVALID_EPOCH_ID");
            totalTopUp = totalTopUp.add(rewards[i]);
            epochData[epochIds[i]].totalRewards = epochData[epochIds[i]].totalRewards.add(
                rewards[i]
            );
        }

        IERC20(pendleTokenAddress).safeTransferFrom(msg.sender, address(this), totalTopUp);
        emit RewardsToppedUp(epochIds, rewards);
    }

    function stake(address forAddr, uint256 amount)
        external
        virtual
        override
        nonReentrant
        nonContractOrWhitelisted
        isUserAllowedToUse
    {

        require(forAddr != address(0), "ZERO_ADDRESS");
        require(amount != 0, "ZERO_AMOUNT");
        require(_getCurrentEpochId() <= numberOfEpochs, "INCENTIVES_PERIOD_OVER");

        _settleStake(forAddr, msg.sender, amount);
        emit Staked(forAddr, amount);
    }

    function withdraw(address toAddr, uint256 amount)
        external
        virtual
        override
        nonReentrant
        isUserAllowedToUse
    {

        require(amount != 0, "ZERO_AMOUNT");
        require(toAddr != address(0), "ZERO_ADDRESS");

        _settleWithdraw(msg.sender, toAddr, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function redeemRewards(address user)
        external
        virtual
        override
        nonReentrant
        isUserAllowedToUse
        returns (uint256 rewards)
    {

        require(user != address(0), "ZERO_ADDRESS");

        rewards = _beforeTransferPendingRewards(user);
        if (rewards != 0) IERC20(pendleTokenAddress).safeTransfer(user, rewards);
    }

    function redeemDueInterests(address user)
        external
        virtual
        override
        nonReentrant
        isUserAllowedToUse
        returns (uint256 amountOut)
    {

        if (yieldToken == address(0)) return 0;
        require(user != address(0), "ZERO_ADDRESS");

        amountOut = _beforeTransferDueInterests(user);
        amountOut = _pushYieldToken(user, amountOut);
    }

    function updateAndReadEpochData(uint256 epochId, address user)
        external
        override
        nonReentrant
        isUserAllowedToUse
        returns (
            uint256 totalStakeUnits,
            uint256 totalRewards,
            uint256 lastUpdated,
            uint256 stakeUnitsForUser,
            uint256 availableRewardsForUser
        )
    {

        _updatePendingRewards(user);
        return readEpochData(epochId, user);
    }

    function readEpochData(uint256 epochId, address user)
        public
        view
        override
        returns (
            uint256 totalStakeUnits,
            uint256 totalRewards,
            uint256 lastUpdated,
            uint256 stakeUnitsForUser,
            uint256 availableRewardsForUser
        )
    {

        totalStakeUnits = epochData[epochId].totalStakeUnits;
        totalRewards = epochData[epochId].totalRewards;
        lastUpdated = epochData[epochId].lastUpdated;
        stakeUnitsForUser = epochData[epochId].stakeUnitsForUser[user];
        availableRewardsForUser = epochData[epochId].availableRewardsForUser[user];
    }

    function _updatePendingRewards(address user) internal virtual {

        _updateStakeData();

        if (lastTimeUserStakeUpdated[user] == 0) {
            lastTimeUserStakeUpdated[user] = block.timestamp;
            return;
        }

        uint256 _curEpoch = _getCurrentEpochId();
        uint256 _endEpoch = Math.min(numberOfEpochs, _curEpoch);

        bool _isEndEpochOver = (_curEpoch > numberOfEpochs);

        uint256 _balance = balances[user];
        uint256 _lastTimeUserStakeUpdated = lastTimeUserStakeUpdated[user];
        uint256 _totalStake = totalStake;
        uint256 _startEpoch = _epochOfTimestamp(_lastTimeUserStakeUpdated);

        for (uint256 epochId = _startEpoch; epochId <= _endEpoch; epochId++) {
            if (epochData[epochId].totalStakeUnits == 0) {
                if (_totalStake == 0) break;
                continue;
            }
            epochData[epochId].stakeUnitsForUser[user] = epochData[epochId]
            .stakeUnitsForUser[user]
            .add(_calcUnitsStakeInEpoch(_balance, _lastTimeUserStakeUpdated, epochId));

            if (epochId == _endEpoch && !_isEndEpochOver) {
                break;
            }

            uint256 rewardsPerVestingEpoch = _calcAmountRewardsForUserInEpoch(user, epochId);

            for (uint256 i = epochId + 1; i <= epochId + vestingEpochs; i++) {
                epochData[i].availableRewardsForUser[user] = epochData[i]
                .availableRewardsForUser[user]
                .add(rewardsPerVestingEpoch);
            }
        }

        lastTimeUserStakeUpdated[user] = block.timestamp;
    }

    function _updateStakeData() internal virtual {

        uint256 _curEpoch = _getCurrentEpochId();

        for (uint256 i = Math.min(_curEpoch, numberOfEpochs); i > 0; i--) {
            uint256 epochEndTime = _endTimeOfEpoch(i);
            uint256 lastUpdatedForEpoch = epochData[i].lastUpdated;

            if (lastUpdatedForEpoch == epochEndTime) {
                break; // its already updated until this epoch, our job here is done
            }

            epochData[i].totalStakeUnits = epochData[i].totalStakeUnits.add(
                _calcUnitsStakeInEpoch(totalStake, lastUpdatedForEpoch, i)
            );
            epochData[i].lastUpdated = Math.min(block.timestamp, epochEndTime);
        }
    }

    function _updateDueInterests(address user) internal virtual {

        if (yieldToken == address(0)) return;

        _updateParamL();

        if (lastParamL[user] == 0) {
            lastParamL[user] = paramL;
            return;
        }

        uint256 principal = balances[user];
        uint256 interestValuePerStakeToken = paramL.sub(lastParamL[user]);

        uint256 interestFromStakeToken = principal.mul(interestValuePerStakeToken).div(MULTIPLIER);

        dueInterests[user] = dueInterests[user].add(interestFromStakeToken);
        lastParamL[user] = paramL;
    }

    function _updateParamL() internal virtual {

        if (yieldToken == address(0) || !_checkNeedUpdateParamL()) return;

        _redeemExternalInterests();

        uint256 currentNYield = IERC20(yieldToken).balanceOf(address(this));
        (uint256 firstTerm, uint256 paramR) = _getFirstTermAndParamR(currentNYield);

        uint256 secondTerm;

        if (totalStake != 0) secondTerm = paramR.mul(MULTIPLIER).div(totalStake);

        paramL = firstTerm.add(secondTerm);
        lastNYield = currentNYield;
    }

    function _getFirstTermAndParamR(uint256 currentNYield)
        internal
        virtual
        returns (uint256 firstTerm, uint256 paramR)
    {

        firstTerm = paramL;
        paramR = currentNYield.sub(lastNYield);
    }

    function _checkNeedUpdateParamL() internal virtual returns (bool) {}


    function _redeemExternalInterests() internal virtual {}


    function _beforeTransferPendingRewards(address user)
        internal
        virtual
        returns (uint256 amountOut)
    {

        _updatePendingRewards(user);

        uint256 _lastEpoch = Math.min(_getCurrentEpochId(), numberOfEpochs + vestingEpochs);
        for (uint256 i = lastEpochClaimed[user]; i <= _lastEpoch; i++) {
            if (epochData[i].availableRewardsForUser[user] > 0) {
                amountOut = amountOut.add(epochData[i].availableRewardsForUser[user]);
                epochData[i].availableRewardsForUser[user] = 0;
            }
        }

        lastEpochClaimed[user] = _lastEpoch;
        emit PendleRewardsSettled(user, amountOut);
    }

    function _beforeTransferDueInterests(address user)
        internal
        virtual
        returns (uint256 amountOut)
    {

        if (yieldToken == address(0)) return 0;

        _updateDueInterests(user);
        amountOut = Math.min(dueInterests[user], lastNYield);
        dueInterests[user] = 0;
        lastNYield = lastNYield.sub(amountOut);
    }

    function _settleStake(
        address user,
        address payer,
        uint256 amount
    ) internal virtual {

        _updatePendingRewards(user);
        _updateDueInterests(user);

        balances[user] = balances[user].add(amount);
        totalStake = totalStake.add(amount);

        _pullStakeToken(payer, amount);
    }

    function _settleWithdraw(
        address user,
        address receiver,
        uint256 amount
    ) internal virtual {

        _updatePendingRewards(user);
        _updateDueInterests(user);

        balances[user] = balances[user].sub(amount);
        totalStake = totalStake.sub(amount);

        _pushStakeToken(receiver, amount);
    }

    function _pullStakeToken(address from, uint256 amount) internal virtual {

        IERC20(stakeToken).safeTransferFrom(from, address(this), amount);
    }

    function _pushStakeToken(address to, uint256 amount) internal virtual {

        if (amount != 0) IERC20(stakeToken).safeTransfer(to, amount);
    }

    function _pushYieldToken(address to, uint256 amount)
        internal
        virtual
        returns (uint256 outAmount)
    {

        outAmount = Math.min(amount, IERC20(yieldToken).balanceOf(address(this)));
        if (outAmount != 0) IERC20(yieldToken).safeTransfer(to, outAmount);
    }

    function _calcUnitsStakeInEpoch(
        uint256 _tokenAmount,
        uint256 _startTime,
        uint256 _epochId
    ) internal view returns (uint256 stakeUnitsForUser) {

        uint256 _endTime = block.timestamp;

        uint256 _l = Math.max(_startTime, _startTimeOfEpoch(_epochId));
        uint256 _r = Math.min(_endTime, _endTimeOfEpoch(_epochId));
        uint256 durationStakeThisEpoch = _r.subMax0(_l);

        return _tokenAmount.mul(durationStakeThisEpoch);
    }

    function _calcAmountRewardsForUserInEpoch(address user, uint256 epochId)
        internal
        view
        returns (uint256 rewardsPerVestingEpoch)
    {

        rewardsPerVestingEpoch = epochData[epochId]
        .totalRewards
        .mul(epochData[epochId].stakeUnitsForUser[user])
        .div(epochData[epochId].totalStakeUnits)
        .div(vestingEpochs);
    }

    function _startTimeOfEpoch(uint256 t) internal view returns (uint256) {

        return startTime.add((t.sub(1)).mul(epochDuration));
    }

    function _getCurrentEpochId() internal view returns (uint256) {

        return _epochOfTimestamp(block.timestamp);
    }

    function _epochOfTimestamp(uint256 t) internal view returns (uint256) {

        if (t < startTime) return 0;
        return (t.sub(startTime)).div(epochDuration).add(1);
    }

    function _endTimeOfEpoch(uint256 t) internal view returns (uint256) {

        return startTime.add(t.mul(epochDuration));
    }

    function _allowedToWithdraw(address _token) internal view override returns (bool allowed) {

        allowed = _token != pendleTokenAddress && _token != stakeToken && _token != yieldToken;
    }
}// MIT
pragma solidity 0.7.6;


contract PendleStakingZerionProxy {

    struct Vars {
        uint256 startTime;
        uint256 epochDuration;
        uint256 currentEpoch;
        uint256 timeLeftInEpoch;
    }

    address public owner;
    address public pendingOwner;
    PendleLiquidityMiningBase[] public v1LMs;
    PendleLiquidityMiningBaseV2[] public v2LMs;
    uint256[] public expiries;
    uint256 private constant ALLOCATION_DENOMINATOR = 1_000_000_000;

    modifier onlyOwner() {

        require(msg.sender == owner, "ONLY_OWNER");
        _;
    }

    constructor (
        address _owner,
        PendleLiquidityMiningBase[] memory _v1LMs,
        PendleLiquidityMiningBaseV2[] memory _v2LMs,
        uint256[] memory _expiries
    ) {
        require(_owner != address(0), "ZERO_ADDRESS");
        owner = _owner;
        v1LMs = _v1LMs;
        v2LMs = _v2LMs;
        expiries = _expiries;
    }

    function claimOwnership() external {

        require(pendingOwner == msg.sender, "WRONG_OWNER");
        owner = pendingOwner;
        pendingOwner = address(0);
    }

    function transferOwnership(address _owner) external onlyOwner {

        require(_owner != address(0), "ZERO_ADDRESS");
        pendingOwner = _owner;
    }

    function addLMv1(PendleLiquidityMiningBase _lm) external onlyOwner {

        v1LMs.push(_lm);
    }

    function setLMv1(PendleLiquidityMiningBase[] calldata _lms) external onlyOwner {

        v1LMs = _lms;
    }

    function addLMv2(PendleLiquidityMiningBaseV2 _lm) external onlyOwner {

        v2LMs.push(_lm);
    }

    function setLMv2(PendleLiquidityMiningBaseV2[] calldata _lms) external onlyOwner {

        v2LMs = _lms;
    }

    function addExpiry(uint256 _expiry) external onlyOwner {

        expiries.push(_expiry);
    }

    function setExpiries(uint256[] calldata _expiries) external onlyOwner {   

        expiries = _expiries;
    }

    function earned(address user)
        external
        view
        returns (uint256)
    {

        uint256 totalEarned = 0;

        for (uint256 i = 0; i < v1LMs.length; i++) {
            for (uint256 j = 0; j < expiries.length; j++) {
                totalEarned += _calcLMAccruingV1(v1LMs[i], expiries[j], user);
            }            
        }
        for (uint256 i = 0; i < v1LMs.length; i++) {
            totalEarned += _calcLMAccruingV2(v2LMs[i], user);
        }

        return totalEarned;
    }

    function _calcLMAccruingV1(
        PendleLiquidityMiningBase liqMining,
        uint256 expiry,
        address user
    )
        internal
        view
        returns (uint256)
    {

        Vars memory vars;
        vars.startTime = liqMining.startTime();
        vars.epochDuration = liqMining.epochDuration();
        vars.currentEpoch = (block.timestamp - vars.startTime) / vars.epochDuration + 1;
        vars.timeLeftInEpoch =
            vars.epochDuration -
            ((block.timestamp - vars.startTime) % vars.epochDuration);

        (uint256 totalStakeUnits, ) = liqMining.readExpirySpecificEpochData(vars.currentEpoch, expiry);
        uint256 userStakeUnits = liqMining.readStakeUnitsForUser(vars.currentEpoch, user, expiry);
        (uint256 totalStake, , , ) = liqMining.readExpiryData(expiry);
        if (totalStake == 0) return 0;

        (, uint256 totalRewards) = liqMining.readEpochData(vars.currentEpoch);
        (uint256 latestSettingId, ) = liqMining.latestSetting();
        uint256 epochRewards = (totalRewards *
            liqMining.allocationSettings(latestSettingId, expiry)) / ALLOCATION_DENOMINATOR;

        return (epochRewards * userStakeUnits) / (totalStakeUnits + vars.timeLeftInEpoch * totalStake);
    }

    function _calcLMAccruingV2(
        PendleLiquidityMiningBaseV2 liqMiningV2,
        address user
    )
        internal
        view
        returns (uint256)
    {

        Vars memory vars;
        vars.startTime = liqMiningV2.startTime();
        vars.epochDuration = liqMiningV2.epochDuration();
        vars.currentEpoch = (block.timestamp - vars.startTime) / vars.epochDuration + 1;
        vars.timeLeftInEpoch =
            vars.epochDuration -
            ((block.timestamp - vars.startTime) % vars.epochDuration);
        (uint256 totalStakeUnits, uint256 epochRewards, , uint256 userStakeUnits, ) =
            liqMiningV2.readEpochData(vars.currentEpoch, user);
        uint256 totalStake = liqMiningV2.totalStake();

        return (epochRewards * userStakeUnits) / (totalStakeUnits + vars.timeLeftInEpoch * totalStake);
    }
}