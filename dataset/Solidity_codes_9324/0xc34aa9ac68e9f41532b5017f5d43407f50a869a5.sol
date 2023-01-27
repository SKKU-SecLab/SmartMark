
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

abstract contract PendleRouterNonReentrant {
    uint8 internal _guardCounter;

    modifier nonReentrant() {
        _checkNonReentrancy(); // use functions to reduce bytecode size
        _;
        _guardCounter--;
    }

    constructor() {
        _guardCounter = 1;
    }

    function _checkNonReentrancy() internal {
        if (_getData().isMarket(msg.sender)) {
            require(_guardCounter <= 2, "REENTRANT_CALL");
        } else {
            require(_guardCounter == 1, "REENTRANT_CALL");
        }
        _guardCounter++;
    }

    function _getData() internal view virtual returns (IPendleData);
}// BUSL-1.1
pragma solidity 0.7.6;


contract PendleRouter is IPendleRouter, WithdrawableV2, PendleRouterNonReentrant {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Math for uint256;

    IWETH public immutable override weth;
    IPendleData public immutable override data;
    address private constant ETH_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    uint256 private constant REASONABLE_ALLOWANCE_AMOUNT = type(uint256).max / 2;

    constructor(
        address _governanceManager,
        IWETH _weth,
        IPendleData _data
    ) PermissionsV2(_governanceManager) PendleRouterNonReentrant() {
        weth = _weth;
        data = _data;
    }

    receive() external payable {
        require(msg.sender == address(weth), "ETH_NOT_FROM_WETH");
    }

    function newYieldContracts(
        bytes32 _forgeId,
        address _underlyingAsset,
        uint256 _expiry
    ) external override nonReentrant returns (address ot, address xyt) {

        require(_underlyingAsset != address(0), "ZERO_ADDRESS");
        require(_expiry > block.timestamp, "INVALID_EXPIRY");
        require(_expiry % data.expiryDivisor() == 0, "INVALID_EXPIRY");
        IPendleForge forge = IPendleForge(data.getForgeAddress(_forgeId));
        require(address(forge) != address(0), "FORGE_NOT_EXISTS");

        ot = address(data.otTokens(_forgeId, _underlyingAsset, _expiry));
        xyt = address(data.xytTokens(_forgeId, _underlyingAsset, _expiry));
        require(ot == address(0) && xyt == address(0), "DUPLICATE_YIELD_CONTRACT");

        (ot, xyt) = forge.newYieldContracts(_underlyingAsset, _expiry);
    }

    function redeemAfterExpiry(
        bytes32 _forgeId,
        address _underlyingAsset,
        uint256 _expiry
    ) public override nonReentrant returns (uint256 redeemedAmount) {

        require(data.isValidXYT(_forgeId, _underlyingAsset, _expiry), "INVALID_YT");
        require(_expiry < block.timestamp, "MUST_BE_AFTER_EXPIRY");

        IPendleForge forge = IPendleForge(data.getForgeAddress(_forgeId));

        redeemedAmount = forge.redeemAfterExpiry(msg.sender, _underlyingAsset, _expiry);
    }

    function redeemDueInterests(
        bytes32 _forgeId,
        address _underlyingAsset,
        uint256 _expiry,
        address _user
    ) external override nonReentrant returns (uint256 interests) {

        require(data.isValidXYT(_forgeId, _underlyingAsset, _expiry), "INVALID_YT");
        require(_user != address(0), "ZERO_ADDRESS");
        IPendleForge forge = IPendleForge(data.getForgeAddress(_forgeId));
        interests = forge.redeemDueInterests(_user, _underlyingAsset, _expiry);
    }

    function redeemUnderlying(
        bytes32 _forgeId,
        address _underlyingAsset,
        uint256 _expiry,
        uint256 _amountToRedeem
    ) external override nonReentrant returns (uint256 redeemedAmount) {

        require(data.isValidXYT(_forgeId, _underlyingAsset, _expiry), "INVALID_YT");
        require(block.timestamp < _expiry, "YIELD_CONTRACT_EXPIRED");
        require(_amountToRedeem != 0, "ZERO_AMOUNT");

        IPendleForge forge = IPendleForge(data.getForgeAddress(_forgeId));

        redeemedAmount = forge.redeemUnderlying(
            msg.sender,
            _underlyingAsset,
            _expiry,
            _amountToRedeem
        );
    }

    function renewYield(
        bytes32 _forgeId,
        uint256 _oldExpiry,
        address _underlyingAsset,
        uint256 _newExpiry,
        uint256 _renewalRate
    )
        external
        override
        returns (
            uint256 redeemedAmount,
            uint256 amountRenewed,
            address ot,
            address xyt,
            uint256 amountTokenMinted
        )
    {

        require(0 < _renewalRate, "INVALID_RENEWAL_RATE");
        redeemedAmount = redeemAfterExpiry(_forgeId, _underlyingAsset, _oldExpiry);
        amountRenewed = redeemedAmount.rmul(_renewalRate);
        (ot, xyt, amountTokenMinted) = tokenizeYield(
            _forgeId,
            _underlyingAsset,
            _newExpiry,
            amountRenewed,
            msg.sender
        );
    }

    function tokenizeYield(
        bytes32 _forgeId,
        address _underlyingAsset,
        uint256 _expiry,
        uint256 _amountToTokenize,
        address _to
    )
        public
        override
        nonReentrant
        returns (
            address ot,
            address xyt,
            uint256 amountTokenMinted
        )
    {

        require(data.isValidXYT(_forgeId, _underlyingAsset, _expiry), "INVALID_YT");
        require(block.timestamp < _expiry, "YIELD_CONTRACT_EXPIRED");
        require(_to != address(0), "ZERO_ADDRESS");
        require(_amountToTokenize != 0, "ZERO_AMOUNT");

        IPendleForge forge = IPendleForge(data.getForgeAddress(_forgeId));

        IERC20 yieldToken = IERC20(forge.getYieldBearingToken(_underlyingAsset));

        yieldToken.safeTransferFrom(
            msg.sender,
            forge.yieldTokenHolders(_underlyingAsset, _expiry),
            _amountToTokenize
        );

        (ot, xyt, amountTokenMinted) = forge.mintOtAndXyt(
            _underlyingAsset,
            _expiry,
            _amountToTokenize,
            _to
        );
    }

    function addMarketLiquidityDual(
        bytes32 _marketFactoryId,
        address _xyt,
        address _token,
        uint256 _desiredXytAmount,
        uint256 _desiredTokenAmount,
        uint256 _xytMinAmount,
        uint256 _tokenMinAmount
    )
        public
        payable
        override
        nonReentrant
        returns (
            uint256 amountXytUsed,
            uint256 amountTokenUsed,
            uint256 lpOut
        )
    {

        require(
            _desiredXytAmount != 0 && _desiredXytAmount >= _xytMinAmount,
            "INVALID_YT_AMOUNTS"
        );
        require(
            _desiredTokenAmount != 0 && _desiredTokenAmount >= _tokenMinAmount,
            "INVALID_TOKEN_AMOUNTS"
        );

        address originalToken = _token;
        _token = _isETH(_token) ? address(weth) : _token;

        IPendleMarket market = IPendleMarket(data.getMarket(_marketFactoryId, _xyt, _token));
        require(address(market) != address(0), "MARKET_NOT_FOUND");

        PendingTransfer[2] memory transfers;
        (transfers, lpOut) = market.addMarketLiquidityDual(
            msg.sender,
            _desiredXytAmount,
            _desiredTokenAmount,
            _xytMinAmount,
            _tokenMinAmount
        );
        _settlePendingTransfers(transfers, _xyt, originalToken, address(market));

        amountXytUsed = transfers[0].amount;
        amountTokenUsed = transfers[1].amount;
        emit Join(msg.sender, amountXytUsed, amountTokenUsed, address(market), lpOut);
    }

    function addMarketLiquiditySingle(
        bytes32 _marketFactoryId,
        address _xyt,
        address _token,
        bool _forXyt,
        uint256 _exactIn,
        uint256 _minOutLp
    ) external payable override nonReentrant returns (uint256 exactOutLp) {

        require(_exactIn != 0, "ZERO_AMOUNTS");

        address originalToken = _token;
        _token = _isETH(_token) ? address(weth) : _token;

        IPendleMarket market = IPendleMarket(data.getMarket(_marketFactoryId, _xyt, _token));
        require(address(market) != address(0), "MARKET_NOT_FOUND");

        address assetToTransferIn = _forXyt ? _xyt : originalToken;
        address assetForMarket = _forXyt ? _xyt : _token;

        PendingTransfer[2] memory transfers;
        (transfers, exactOutLp) = market.addMarketLiquiditySingle(
            msg.sender,
            assetForMarket,
            _exactIn,
            _minOutLp
        );

        if (_forXyt) {
            emit Join(msg.sender, _exactIn, 0, address(market), exactOutLp);
        } else {
            emit Join(msg.sender, 0, _exactIn, address(market), exactOutLp);
        }
        _settleTokenTransfer(assetToTransferIn, transfers[0], address(market));
    }

    function removeMarketLiquidityDual(
        bytes32 _marketFactoryId,
        address _xyt,
        address _token,
        uint256 _exactInLp,
        uint256 _minOutXyt,
        uint256 _minOutToken
    ) external override nonReentrant returns (uint256 exactOutXyt, uint256 exactOutToken) {

        require(_exactInLp != 0, "ZERO_LP_IN");

        address originalToken = _token;
        _token = _isETH(_token) ? address(weth) : _token;

        IPendleMarket market = IPendleMarket(data.getMarket(_marketFactoryId, _xyt, _token));
        require(address(market) != address(0), "MARKET_NOT_FOUND");

        PendingTransfer[2] memory transfers =
            market.removeMarketLiquidityDual(msg.sender, _exactInLp, _minOutXyt, _minOutToken);

        _settlePendingTransfers(transfers, _xyt, originalToken, address(market));
        exactOutXyt = transfers[0].amount;
        exactOutToken = transfers[1].amount;
        emit Exit(msg.sender, exactOutXyt, exactOutToken, address(market), _exactInLp);
    }

    function removeMarketLiquiditySingle(
        bytes32 _marketFactoryId,
        address _xyt,
        address _token,
        bool _forXyt,
        uint256 _exactInLp,
        uint256 _minOutAsset
    ) external override nonReentrant returns (uint256 exactOutXyt, uint256 exactOutToken) {

        require(_exactInLp != 0, "ZERO_LP_IN");

        address originalToken = _token;
        _token = _isETH(_token) ? address(weth) : _token;

        IPendleMarket market = IPendleMarket(data.getMarket(_marketFactoryId, _xyt, _token));
        require(address(market) != address(0), "MARKET_NOT_FOUND");

        address assetForMarket = _forXyt ? _xyt : _token;

        PendingTransfer[2] memory transfers =
            market.removeMarketLiquiditySingle(
                msg.sender,
                assetForMarket,
                _exactInLp,
                _minOutAsset
            );

        address assetToTransferOut = _forXyt ? _xyt : originalToken;
        _settleTokenTransfer(assetToTransferOut, transfers[0], address(market));

        if (_forXyt) {
            emit Exit(msg.sender, transfers[0].amount, 0, address(market), _exactInLp);
            return (transfers[0].amount, 0);
        } else {
            emit Exit(msg.sender, 0, transfers[0].amount, address(market), _exactInLp);
            return (0, transfers[0].amount);
        }
    }

    function createMarket(
        bytes32 _marketFactoryId,
        address _xyt,
        address _token
    ) external override nonReentrant returns (address market) {

        require(_xyt != address(0), "ZERO_ADDRESS");
        require(_token != address(0), "ZERO_ADDRESS");
        require(data.isXyt(_xyt), "INVALID_YT");
        require(!data.isXyt(_token), "YT_QUOTE_PAIR_FORBIDDEN");
        require(data.getMarket(_marketFactoryId, _xyt, _token) == address(0), "EXISTED_MARKET");

        IPendleMarketFactory factory =
            IPendleMarketFactory(data.getMarketFactoryAddress(_marketFactoryId));
        require(address(factory) != address(0), "ZERO_ADDRESS");

        bytes32 forgeId = IPendleForge(IPendleYieldToken(_xyt).forge()).forgeId();
        require(data.validForgeFactoryPair(forgeId, _marketFactoryId), "INVALID_FORGE_FACTORY");

        market = factory.createMarket(_xyt, _token);

        emit MarketCreated(_marketFactoryId, _xyt, _token, market);
    }

    function bootstrapMarket(
        bytes32 _marketFactoryId,
        address _xyt,
        address _token,
        uint256 _initialXytLiquidity,
        uint256 _initialTokenLiquidity
    ) external payable override nonReentrant {

        require(_initialXytLiquidity > 0, "INVALID_YT_AMOUNT");
        require(_initialTokenLiquidity > 0, "INVALID_TOKEN_AMOUNT");

        address originalToken = _token;
        _token = _isETH(_token) ? address(weth) : _token;

        IPendleMarket market = IPendleMarket(data.getMarket(_marketFactoryId, _xyt, _token));
        require(address(market) != address(0), "MARKET_NOT_FOUND");

        PendingTransfer[2] memory transfers;
        uint256 exactOutLp;
        (transfers, exactOutLp) = market.bootstrap(
            msg.sender,
            _initialXytLiquidity,
            _initialTokenLiquidity
        );

        _settlePendingTransfers(transfers, _xyt, originalToken, address(market));
        emit Join(
            msg.sender,
            _initialXytLiquidity,
            _initialTokenLiquidity,
            address(market),
            exactOutLp
        );
    }

    function swapExactIn(
        address _tokenIn,
        address _tokenOut,
        uint256 _inAmount,
        uint256 _minOutAmount,
        bytes32 _marketFactoryId
    ) external payable override nonReentrant returns (uint256 outSwapAmount) {

        require(_inAmount != 0, "ZERO_IN_AMOUNT");

        address originalTokenIn = _tokenIn;
        address originalTokenOut = _tokenOut;
        _tokenIn = _isETH(_tokenIn) ? address(weth) : _tokenIn;
        _tokenOut = _isETH(_tokenOut) ? address(weth) : _tokenOut;

        IPendleMarket market =
            IPendleMarket(data.getMarketFromKey(_tokenIn, _tokenOut, _marketFactoryId));
        require(address(market) != address(0), "MARKET_NOT_FOUND");

        PendingTransfer[2] memory transfers;
        (outSwapAmount, transfers) = market.swapExactIn(
            _tokenIn,
            _inAmount,
            _tokenOut,
            _minOutAmount
        );

        _settlePendingTransfers(transfers, originalTokenIn, originalTokenOut, address(market));

        emit SwapEvent(msg.sender, _tokenIn, _tokenOut, _inAmount, outSwapAmount, address(market));
    }

    function swapExactOut(
        address _tokenIn,
        address _tokenOut,
        uint256 _outAmount,
        uint256 _maxInAmount,
        bytes32 _marketFactoryId
    ) external payable override nonReentrant returns (uint256 inSwapAmount) {

        require(_outAmount != 0, "ZERO_OUT_AMOUNT");

        address originalTokenIn = _tokenIn;
        address originalTokenOut = _tokenOut;
        _tokenIn = _isETH(_tokenIn) ? address(weth) : _tokenIn;
        _tokenOut = _isETH(_tokenOut) ? address(weth) : _tokenOut;

        IPendleMarket market =
            IPendleMarket(data.getMarketFromKey(_tokenIn, _tokenOut, _marketFactoryId));
        require(address(market) != address(0), "MARKET_NOT_FOUND");

        PendingTransfer[2] memory transfers;
        (inSwapAmount, transfers) = market.swapExactOut(
            _tokenIn,
            _maxInAmount,
            _tokenOut,
            _outAmount
        );

        _settlePendingTransfers(transfers, originalTokenIn, originalTokenOut, address(market));

        emit SwapEvent(msg.sender, _tokenIn, _tokenOut, inSwapAmount, _outAmount, address(market));
    }

    function redeemLpInterests(address market, address user)
        external
        override
        nonReentrant
        returns (uint256 interests)
    {

        require(data.isMarket(market), "INVALID_MARKET");
        require(user != address(0), "ZERO_ADDRESS");
        interests = IPendleMarket(market).redeemLpInterests(user);
    }

    function _getData() internal view override returns (IPendleData) {

        return data;
    }

    function _isETH(address token) internal pure returns (bool) {

        return (token == ETH_ADDRESS);
    }

    function _settlePendingTransfers(
        PendingTransfer[2] memory transfers,
        address firstToken,
        address secondToken,
        address market
    ) internal {

        _settleTokenTransfer(firstToken, transfers[0], market);
        _settleTokenTransfer(secondToken, transfers[1], market);
    }

    function _settleTokenTransfer(
        address token,
        PendingTransfer memory transfer,
        address market
    ) internal {

        if (transfer.amount == 0) {
            return;
        }
        if (transfer.isOut) {
            if (_isETH(token)) {
                weth.transferFrom(market, address(this), transfer.amount);
                weth.withdraw(transfer.amount);
                (bool success, ) = msg.sender.call{value: transfer.amount}("");
                require(success, "TRANSFER_FAILED");
            } else {
                IERC20(token).safeTransferFrom(market, msg.sender, transfer.amount);
            }
        } else {
            if (_isETH(token)) {
                require(msg.value >= transfer.amount, "INSUFFICENT_ETH_AMOUNT");
                uint256 excess = msg.value.sub(transfer.amount);
                if (excess != 0) {
                    (bool success, ) = msg.sender.call{value: excess}("");
                    require(success, "TRANSFER_FAILED");
                }

                weth.deposit{value: transfer.amount}();
                weth.transfer(market, transfer.amount);
            } else {
                if (data.isXyt(token)) {
                    _checkApproveRouter(token);
                }
                IERC20(token).safeTransferFrom(msg.sender, market, transfer.amount);
            }
        }
    }

    function _checkApproveRouter(address token) internal {

        uint256 allowance = IPendleBaseToken(token).allowance(msg.sender, address(this));
        if (allowance >= REASONABLE_ALLOWANCE_AMOUNT) return;
        IPendleYieldToken(token).approveRouter(msg.sender);
    }

    function _allowedToWithdraw(address) internal pure override returns (bool allowed) {

        allowed = true;
    }
}