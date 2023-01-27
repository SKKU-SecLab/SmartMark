


pragma solidity ^0.7.0;


function _require(bool condition, uint256 errorCode) pure {
    if (!condition) _revert(errorCode);
}

function _revert(uint256 errorCode) pure {
    assembly {

        let units := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let tenths := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let hundreds := add(mod(errorCode, 10), 0x30)


        let revertReason := shl(200, add(0x42414c23000000, add(add(units, shl(8, tenths)), shl(16, hundreds))))


        mstore(0x0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
        mstore(0x04, 0x0000000000000000000000000000000000000000000000000000000000000020)
        mstore(0x24, 7)
        mstore(0x44, revertReason)

        revert(0, 100)
    }
}

library Errors {

    uint256 internal constant ADD_OVERFLOW = 0;
    uint256 internal constant SUB_OVERFLOW = 1;
    uint256 internal constant SUB_UNDERFLOW = 2;
    uint256 internal constant MUL_OVERFLOW = 3;
    uint256 internal constant ZERO_DIVISION = 4;
    uint256 internal constant DIV_INTERNAL = 5;
    uint256 internal constant X_OUT_OF_BOUNDS = 6;
    uint256 internal constant Y_OUT_OF_BOUNDS = 7;
    uint256 internal constant PRODUCT_OUT_OF_BOUNDS = 8;
    uint256 internal constant INVALID_EXPONENT = 9;

    uint256 internal constant OUT_OF_BOUNDS = 100;
    uint256 internal constant UNSORTED_ARRAY = 101;
    uint256 internal constant UNSORTED_TOKENS = 102;
    uint256 internal constant INPUT_LENGTH_MISMATCH = 103;
    uint256 internal constant ZERO_TOKEN = 104;

    uint256 internal constant MIN_TOKENS = 200;
    uint256 internal constant MAX_TOKENS = 201;
    uint256 internal constant MAX_SWAP_FEE_PERCENTAGE = 202;
    uint256 internal constant MIN_SWAP_FEE_PERCENTAGE = 203;
    uint256 internal constant MINIMUM_BPT = 204;
    uint256 internal constant CALLER_NOT_VAULT = 205;
    uint256 internal constant UNINITIALIZED = 206;
    uint256 internal constant BPT_IN_MAX_AMOUNT = 207;
    uint256 internal constant BPT_OUT_MIN_AMOUNT = 208;
    uint256 internal constant EXPIRED_PERMIT = 209;
    uint256 internal constant NOT_TWO_TOKENS = 210;
    uint256 internal constant DISABLED = 211;

    uint256 internal constant MIN_AMP = 300;
    uint256 internal constant MAX_AMP = 301;
    uint256 internal constant MIN_WEIGHT = 302;
    uint256 internal constant MAX_STABLE_TOKENS = 303;
    uint256 internal constant MAX_IN_RATIO = 304;
    uint256 internal constant MAX_OUT_RATIO = 305;
    uint256 internal constant MIN_BPT_IN_FOR_TOKEN_OUT = 306;
    uint256 internal constant MAX_OUT_BPT_FOR_TOKEN_IN = 307;
    uint256 internal constant NORMALIZED_WEIGHT_INVARIANT = 308;
    uint256 internal constant INVALID_TOKEN = 309;
    uint256 internal constant UNHANDLED_JOIN_KIND = 310;
    uint256 internal constant ZERO_INVARIANT = 311;
    uint256 internal constant ORACLE_INVALID_SECONDS_QUERY = 312;
    uint256 internal constant ORACLE_NOT_INITIALIZED = 313;
    uint256 internal constant ORACLE_QUERY_TOO_OLD = 314;
    uint256 internal constant ORACLE_INVALID_INDEX = 315;
    uint256 internal constant ORACLE_BAD_SECS = 316;
    uint256 internal constant AMP_END_TIME_TOO_CLOSE = 317;
    uint256 internal constant AMP_ONGOING_UPDATE = 318;
    uint256 internal constant AMP_RATE_TOO_HIGH = 319;
    uint256 internal constant AMP_NO_ONGOING_UPDATE = 320;
    uint256 internal constant STABLE_INVARIANT_DIDNT_CONVERGE = 321;
    uint256 internal constant STABLE_GET_BALANCE_DIDNT_CONVERGE = 322;
    uint256 internal constant RELAYER_NOT_CONTRACT = 323;
    uint256 internal constant BASE_POOL_RELAYER_NOT_CALLED = 324;
    uint256 internal constant REBALANCING_RELAYER_REENTERED = 325;
    uint256 internal constant GRADUAL_UPDATE_TIME_TRAVEL = 326;
    uint256 internal constant SWAPS_DISABLED = 327;
    uint256 internal constant CALLER_IS_NOT_LBP_OWNER = 328;
    uint256 internal constant PRICE_RATE_OVERFLOW = 329;

    uint256 internal constant REENTRANCY = 400;
    uint256 internal constant SENDER_NOT_ALLOWED = 401;
    uint256 internal constant PAUSED = 402;
    uint256 internal constant PAUSE_WINDOW_EXPIRED = 403;
    uint256 internal constant MAX_PAUSE_WINDOW_DURATION = 404;
    uint256 internal constant MAX_BUFFER_PERIOD_DURATION = 405;
    uint256 internal constant INSUFFICIENT_BALANCE = 406;
    uint256 internal constant INSUFFICIENT_ALLOWANCE = 407;
    uint256 internal constant ERC20_TRANSFER_FROM_ZERO_ADDRESS = 408;
    uint256 internal constant ERC20_TRANSFER_TO_ZERO_ADDRESS = 409;
    uint256 internal constant ERC20_MINT_TO_ZERO_ADDRESS = 410;
    uint256 internal constant ERC20_BURN_FROM_ZERO_ADDRESS = 411;
    uint256 internal constant ERC20_APPROVE_FROM_ZERO_ADDRESS = 412;
    uint256 internal constant ERC20_APPROVE_TO_ZERO_ADDRESS = 413;
    uint256 internal constant ERC20_TRANSFER_EXCEEDS_ALLOWANCE = 414;
    uint256 internal constant ERC20_DECREASED_ALLOWANCE_BELOW_ZERO = 415;
    uint256 internal constant ERC20_TRANSFER_EXCEEDS_BALANCE = 416;
    uint256 internal constant ERC20_BURN_EXCEEDS_ALLOWANCE = 417;
    uint256 internal constant SAFE_ERC20_CALL_FAILED = 418;
    uint256 internal constant ADDRESS_INSUFFICIENT_BALANCE = 419;
    uint256 internal constant ADDRESS_CANNOT_SEND_VALUE = 420;
    uint256 internal constant SAFE_CAST_VALUE_CANT_FIT_INT256 = 421;
    uint256 internal constant GRANT_SENDER_NOT_ADMIN = 422;
    uint256 internal constant REVOKE_SENDER_NOT_ADMIN = 423;
    uint256 internal constant RENOUNCE_SENDER_NOT_ALLOWED = 424;
    uint256 internal constant BUFFER_PERIOD_EXPIRED = 425;
    uint256 internal constant CALLER_IS_NOT_OWNER = 426;
    uint256 internal constant NEW_OWNER_IS_ZERO = 427;
    uint256 internal constant CODE_DEPLOYMENT_FAILED = 428;
    uint256 internal constant CALL_TO_NON_CONTRACT = 429;
    uint256 internal constant LOW_LEVEL_CALL_FAILED = 430;

    uint256 internal constant INVALID_POOL_ID = 500;
    uint256 internal constant CALLER_NOT_POOL = 501;
    uint256 internal constant SENDER_NOT_ASSET_MANAGER = 502;
    uint256 internal constant USER_DOESNT_ALLOW_RELAYER = 503;
    uint256 internal constant INVALID_SIGNATURE = 504;
    uint256 internal constant EXIT_BELOW_MIN = 505;
    uint256 internal constant JOIN_ABOVE_MAX = 506;
    uint256 internal constant SWAP_LIMIT = 507;
    uint256 internal constant SWAP_DEADLINE = 508;
    uint256 internal constant CANNOT_SWAP_SAME_TOKEN = 509;
    uint256 internal constant UNKNOWN_AMOUNT_IN_FIRST_SWAP = 510;
    uint256 internal constant MALCONSTRUCTED_MULTIHOP_SWAP = 511;
    uint256 internal constant INTERNAL_BALANCE_OVERFLOW = 512;
    uint256 internal constant INSUFFICIENT_INTERNAL_BALANCE = 513;
    uint256 internal constant INVALID_ETH_INTERNAL_BALANCE = 514;
    uint256 internal constant INVALID_POST_LOAN_BALANCE = 515;
    uint256 internal constant INSUFFICIENT_ETH = 516;
    uint256 internal constant UNALLOCATED_ETH = 517;
    uint256 internal constant ETH_TRANSFER = 518;
    uint256 internal constant CANNOT_USE_ETH_SENTINEL = 519;
    uint256 internal constant TOKENS_MISMATCH = 520;
    uint256 internal constant TOKEN_NOT_REGISTERED = 521;
    uint256 internal constant TOKEN_ALREADY_REGISTERED = 522;
    uint256 internal constant TOKENS_ALREADY_SET = 523;
    uint256 internal constant TOKENS_LENGTH_MUST_BE_2 = 524;
    uint256 internal constant NONZERO_TOKEN_BALANCE = 525;
    uint256 internal constant BALANCE_TOTAL_OVERFLOW = 526;
    uint256 internal constant POOL_NO_TOKENS = 527;
    uint256 internal constant INSUFFICIENT_FLASH_LOAN_BALANCE = 528;

    uint256 internal constant SWAP_FEE_PERCENTAGE_TOO_HIGH = 600;
    uint256 internal constant FLASH_LOAN_FEE_PERCENTAGE_TOO_HIGH = 601;
    uint256 internal constant INSUFFICIENT_FLASH_LOAN_FEE_AMOUNT = 602;
}// MIT



pragma solidity ^0.7.0;



library LogExpMath {


    int256 constant ONE_18 = 1e18;

    int256 constant ONE_20 = 1e20;
    int256 constant ONE_36 = 1e36;

    int256 constant MAX_NATURAL_EXPONENT = 130e18;
    int256 constant MIN_NATURAL_EXPONENT = -41e18;

    int256 constant LN_36_LOWER_BOUND = ONE_18 - 1e17;
    int256 constant LN_36_UPPER_BOUND = ONE_18 + 1e17;

    uint256 constant MILD_EXPONENT_BOUND = 2**254 / uint256(ONE_20);

    int256 constant x0 = 128000000000000000000; // 2ˆ7
    int256 constant a0 = 38877084059945950922200000000000000000000000000000000000; // eˆ(x0) (no decimals)
    int256 constant x1 = 64000000000000000000; // 2ˆ6
    int256 constant a1 = 6235149080811616882910000000; // eˆ(x1) (no decimals)

    int256 constant x2 = 3200000000000000000000; // 2ˆ5
    int256 constant a2 = 7896296018268069516100000000000000; // eˆ(x2)
    int256 constant x3 = 1600000000000000000000; // 2ˆ4
    int256 constant a3 = 888611052050787263676000000; // eˆ(x3)
    int256 constant x4 = 800000000000000000000; // 2ˆ3
    int256 constant a4 = 298095798704172827474000; // eˆ(x4)
    int256 constant x5 = 400000000000000000000; // 2ˆ2
    int256 constant a5 = 5459815003314423907810; // eˆ(x5)
    int256 constant x6 = 200000000000000000000; // 2ˆ1
    int256 constant a6 = 738905609893065022723; // eˆ(x6)
    int256 constant x7 = 100000000000000000000; // 2ˆ0
    int256 constant a7 = 271828182845904523536; // eˆ(x7)
    int256 constant x8 = 50000000000000000000; // 2ˆ-1
    int256 constant a8 = 164872127070012814685; // eˆ(x8)
    int256 constant x9 = 25000000000000000000; // 2ˆ-2
    int256 constant a9 = 128402541668774148407; // eˆ(x9)
    int256 constant x10 = 12500000000000000000; // 2ˆ-3
    int256 constant a10 = 113314845306682631683; // eˆ(x10)
    int256 constant x11 = 6250000000000000000; // 2ˆ-4
    int256 constant a11 = 106449445891785942956; // eˆ(x11)

    function pow(uint256 x, uint256 y) internal pure returns (uint256) {

        if (y == 0) {
            return uint256(ONE_18);
        }

        if (x == 0) {
            return 0;
        }


        _require(x < 2**255, Errors.X_OUT_OF_BOUNDS);
        int256 x_int256 = int256(x);


        _require(y < MILD_EXPONENT_BOUND, Errors.Y_OUT_OF_BOUNDS);
        int256 y_int256 = int256(y);

        int256 logx_times_y;
        if (LN_36_LOWER_BOUND < x_int256 && x_int256 < LN_36_UPPER_BOUND) {
            int256 ln_36_x = _ln_36(x_int256);

            logx_times_y = ((ln_36_x / ONE_18) * y_int256 + ((ln_36_x % ONE_18) * y_int256) / ONE_18);
        } else {
            logx_times_y = _ln(x_int256) * y_int256;
        }
        logx_times_y /= ONE_18;

        _require(
            MIN_NATURAL_EXPONENT <= logx_times_y && logx_times_y <= MAX_NATURAL_EXPONENT,
            Errors.PRODUCT_OUT_OF_BOUNDS
        );

        return uint256(exp(logx_times_y));
    }

    function exp(int256 x) internal pure returns (int256) {

        _require(x >= MIN_NATURAL_EXPONENT && x <= MAX_NATURAL_EXPONENT, Errors.INVALID_EXPONENT);

        if (x < 0) {
            return ((ONE_18 * ONE_18) / exp(-x));
        }




        int256 firstAN;
        if (x >= x0) {
            x -= x0;
            firstAN = a0;
        } else if (x >= x1) {
            x -= x1;
            firstAN = a1;
        } else {
            firstAN = 1; // One with no decimal places
        }

        x *= 100;

        int256 product = ONE_20;

        if (x >= x2) {
            x -= x2;
            product = (product * a2) / ONE_20;
        }
        if (x >= x3) {
            x -= x3;
            product = (product * a3) / ONE_20;
        }
        if (x >= x4) {
            x -= x4;
            product = (product * a4) / ONE_20;
        }
        if (x >= x5) {
            x -= x5;
            product = (product * a5) / ONE_20;
        }
        if (x >= x6) {
            x -= x6;
            product = (product * a6) / ONE_20;
        }
        if (x >= x7) {
            x -= x7;
            product = (product * a7) / ONE_20;
        }
        if (x >= x8) {
            x -= x8;
            product = (product * a8) / ONE_20;
        }
        if (x >= x9) {
            x -= x9;
            product = (product * a9) / ONE_20;
        }



        int256 seriesSum = ONE_20; // The initial one in the sum, with 20 decimal places.
        int256 term; // Each term in the sum, where the nth term is (x^n / n!).

        term = x;
        seriesSum += term;


        term = ((term * x) / ONE_20) / 2;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 3;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 4;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 5;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 6;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 7;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 8;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 9;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 10;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 11;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 12;
        seriesSum += term;



        return (((product * seriesSum) / ONE_20) * firstAN) / 100;
    }

    function log(int256 arg, int256 base) internal pure returns (int256) {



        int256 logBase;
        if (LN_36_LOWER_BOUND < base && base < LN_36_UPPER_BOUND) {
            logBase = _ln_36(base);
        } else {
            logBase = _ln(base) * ONE_18;
        }

        int256 logArg;
        if (LN_36_LOWER_BOUND < arg && arg < LN_36_UPPER_BOUND) {
            logArg = _ln_36(arg);
        } else {
            logArg = _ln(arg) * ONE_18;
        }

        return (logArg * ONE_18) / logBase;
    }

    function ln(int256 a) internal pure returns (int256) {

        _require(a > 0, Errors.OUT_OF_BOUNDS);
        if (LN_36_LOWER_BOUND < a && a < LN_36_UPPER_BOUND) {
            return _ln_36(a) / ONE_18;
        } else {
            return _ln(a);
        }
    }

    function _ln(int256 a) private pure returns (int256) {

        if (a < ONE_18) {
            return (-_ln((ONE_18 * ONE_18) / a));
        }



        int256 sum = 0;
        if (a >= a0 * ONE_18) {
            a /= a0; // Integer, not fixed point division
            sum += x0;
        }

        if (a >= a1 * ONE_18) {
            a /= a1; // Integer, not fixed point division
            sum += x1;
        }

        sum *= 100;
        a *= 100;


        if (a >= a2) {
            a = (a * ONE_20) / a2;
            sum += x2;
        }

        if (a >= a3) {
            a = (a * ONE_20) / a3;
            sum += x3;
        }

        if (a >= a4) {
            a = (a * ONE_20) / a4;
            sum += x4;
        }

        if (a >= a5) {
            a = (a * ONE_20) / a5;
            sum += x5;
        }

        if (a >= a6) {
            a = (a * ONE_20) / a6;
            sum += x6;
        }

        if (a >= a7) {
            a = (a * ONE_20) / a7;
            sum += x7;
        }

        if (a >= a8) {
            a = (a * ONE_20) / a8;
            sum += x8;
        }

        if (a >= a9) {
            a = (a * ONE_20) / a9;
            sum += x9;
        }

        if (a >= a10) {
            a = (a * ONE_20) / a10;
            sum += x10;
        }

        if (a >= a11) {
            a = (a * ONE_20) / a11;
            sum += x11;
        }


        int256 z = ((a - ONE_20) * ONE_20) / (a + ONE_20);
        int256 z_squared = (z * z) / ONE_20;

        int256 num = z;

        int256 seriesSum = num;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 3;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 5;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 7;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 9;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 11;


        seriesSum *= 2;


        return (sum + seriesSum) / 100;
    }

    function _ln_36(int256 x) private pure returns (int256) {


        x *= ONE_18;


        int256 z = ((x - ONE_36) * ONE_36) / (x + ONE_36);
        int256 z_squared = (z * z) / ONE_36;

        int256 num = z;

        int256 seriesSum = num;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 3;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 5;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 7;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 9;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 11;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 13;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 15;


        return seriesSum * 2;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



library FixedPoint {

    uint256 internal constant ONE = 1e18; // 18 decimal places
    uint256 internal constant MAX_POW_RELATIVE_ERROR = 10000; // 10^(-14)

    uint256 internal constant MIN_POW_BASE_FREE_EXPONENT = 0.7e18;

    function add(uint256 a, uint256 b) internal pure returns (uint256) {


        uint256 c = a + b;
        _require(c >= a, Errors.ADD_OVERFLOW);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {


        _require(b <= a, Errors.SUB_OVERFLOW);
        uint256 c = a - b;
        return c;
    }

    function mulDown(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 product = a * b;
        _require(a == 0 || product / a == b, Errors.MUL_OVERFLOW);

        return product / ONE;
    }

    function mulUp(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 product = a * b;
        _require(a == 0 || product / a == b, Errors.MUL_OVERFLOW);

        if (product == 0) {
            return 0;
        } else {

            return ((product - 1) / ONE) + 1;
        }
    }

    function divDown(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b != 0, Errors.ZERO_DIVISION);

        if (a == 0) {
            return 0;
        } else {
            uint256 aInflated = a * ONE;
            _require(aInflated / a == ONE, Errors.DIV_INTERNAL); // mul overflow

            return aInflated / b;
        }
    }

    function divUp(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b != 0, Errors.ZERO_DIVISION);

        if (a == 0) {
            return 0;
        } else {
            uint256 aInflated = a * ONE;
            _require(aInflated / a == ONE, Errors.DIV_INTERNAL); // mul overflow


            return ((aInflated - 1) / b) + 1;
        }
    }

    function powDown(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 raw = LogExpMath.pow(x, y);
        uint256 maxError = add(mulUp(raw, MAX_POW_RELATIVE_ERROR), 1);

        if (raw < maxError) {
            return 0;
        } else {
            return sub(raw, maxError);
        }
    }

    function powUp(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 raw = LogExpMath.pow(x, y);
        uint256 maxError = add(mulUp(raw, MAX_POW_RELATIVE_ERROR), 1);

        return add(raw, maxError);
    }

    function complement(uint256 x) internal pure returns (uint256) {

        return (x < ONE) ? (ONE - x) : 0;
    }
}// MIT

pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



library InputHelpers {

    function ensureInputLengthMatch(uint256 a, uint256 b) internal pure {

        _require(a == b, Errors.INPUT_LENGTH_MISMATCH);
    }

    function ensureInputLengthMatch(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure {

        _require(a == b && b == c, Errors.INPUT_LENGTH_MISMATCH);
    }

    function ensureArrayIsSorted(IERC20[] memory array) internal pure {

        address[] memory addressArray;
        assembly {
            addressArray := array
        }
        ensureArrayIsSorted(addressArray);
    }

    function ensureArrayIsSorted(address[] memory array) internal pure {

        if (array.length < 2) {
            return;
        }

        address previous = array[0];
        for (uint256 i = 1; i < array.length; ++i) {
            address current = array[i];
            _require(previous < current, Errors.UNSORTED_ARRAY);
            previous = current;
        }
    }
}// MIT

pragma solidity ^0.7.0;


library Math {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        _require(c >= a, Errors.ADD_OVERFLOW);
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        _require((b >= 0 && c >= a) || (b < 0 && c < a), Errors.ADD_OVERFLOW);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b <= a, Errors.SUB_OVERFLOW);
        uint256 c = a - b;
        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        _require((b >= 0 && c <= a) || (b < 0 && c > a), Errors.SUB_OVERFLOW);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;
        _require(a == 0 || c / a == b, Errors.MUL_OVERFLOW);
        return c;
    }

    function div(
        uint256 a,
        uint256 b,
        bool roundUp
    ) internal pure returns (uint256) {

        return roundUp ? divUp(a, b) : divDown(a, b);
    }

    function divDown(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b != 0, Errors.ZERO_DIVISION);
        return a / b;
    }

    function divUp(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b != 0, Errors.ZERO_DIVISION);

        if (a == 0) {
            return 0;
        } else {
            return 1 + (a - 1) / b;
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface ITemporarilyPausable {

    event PausedStateChanged(bool paused);

    function getPausedState()
        external
        view
        returns (
            bool paused,
            uint256 pauseWindowEndTime,
            uint256 bufferPeriodEndTime
        );

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


abstract contract TemporarilyPausable is ITemporarilyPausable {

    uint256 private constant _MAX_PAUSE_WINDOW_DURATION = 90 days;
    uint256 private constant _MAX_BUFFER_PERIOD_DURATION = 30 days;

    uint256 private immutable _pauseWindowEndTime;
    uint256 private immutable _bufferPeriodEndTime;

    bool private _paused;

    constructor(uint256 pauseWindowDuration, uint256 bufferPeriodDuration) {
        _require(pauseWindowDuration <= _MAX_PAUSE_WINDOW_DURATION, Errors.MAX_PAUSE_WINDOW_DURATION);
        _require(bufferPeriodDuration <= _MAX_BUFFER_PERIOD_DURATION, Errors.MAX_BUFFER_PERIOD_DURATION);

        uint256 pauseWindowEndTime = block.timestamp + pauseWindowDuration;

        _pauseWindowEndTime = pauseWindowEndTime;
        _bufferPeriodEndTime = pauseWindowEndTime + bufferPeriodDuration;
    }

    modifier whenNotPaused() {
        _ensureNotPaused();
        _;
    }

    function getPausedState()
        external
        view
        override
        returns (
            bool paused,
            uint256 pauseWindowEndTime,
            uint256 bufferPeriodEndTime
        )
    {
        paused = !_isNotPaused();
        pauseWindowEndTime = _getPauseWindowEndTime();
        bufferPeriodEndTime = _getBufferPeriodEndTime();
    }

    function _setPaused(bool paused) internal {
        if (paused) {
            _require(block.timestamp < _getPauseWindowEndTime(), Errors.PAUSE_WINDOW_EXPIRED);
        } else {
            _require(block.timestamp < _getBufferPeriodEndTime(), Errors.BUFFER_PERIOD_EXPIRED);
        }

        _paused = paused;
        emit PausedStateChanged(paused);
    }

    function _ensureNotPaused() internal view {
        _require(_isNotPaused(), Errors.PAUSED);
    }

    function _isNotPaused() internal view returns (bool) {
        return block.timestamp > _getBufferPeriodEndTime() || !_paused;
    }


    function _getPauseWindowEndTime() private view returns (uint256) {
        return _pauseWindowEndTime;
    }

    function _getBufferPeriodEndTime() private view returns (uint256) {
        return _bufferPeriodEndTime;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

library WordCodec {

    uint256 private constant _MASK_1 = 2**(1) - 1;
    uint256 private constant _MASK_10 = 2**(10) - 1;
    uint256 private constant _MASK_16 = 2**(16) - 1;
    uint256 private constant _MASK_22 = 2**(22) - 1;
    uint256 private constant _MASK_31 = 2**(31) - 1;
    uint256 private constant _MASK_32 = 2**(32) - 1;
    uint256 private constant _MASK_53 = 2**(53) - 1;
    uint256 private constant _MASK_64 = 2**(64) - 1;
    uint256 private constant _MASK_128 = 2**(128) - 1;
    uint256 private constant _MASK_192 = 2**(192) - 1;

    int256 private constant _MAX_INT_22 = 2**(21) - 1;
    int256 private constant _MAX_INT_53 = 2**(52) - 1;


    function insertBool(
        bytes32 word,
        bool value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_1 << offset));
        return clearedWord | bytes32(uint256(value ? 1 : 0) << offset);
    }


    function insertUint10(
        bytes32 word,
        uint256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_10 << offset));
        return clearedWord | bytes32(value << offset);
    }

    function insertUint16(
        bytes32 word,
        uint256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_16 << offset));
        return clearedWord | bytes32(value << offset);
    }

    function insertUint31(
        bytes32 word,
        uint256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_31 << offset));
        return clearedWord | bytes32(value << offset);
    }

    function insertUint32(
        bytes32 word,
        uint256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_32 << offset));
        return clearedWord | bytes32(value << offset);
    }

    function insertUint64(
        bytes32 word,
        uint256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_64 << offset));
        return clearedWord | bytes32(value << offset);
    }


    function insertInt22(
        bytes32 word,
        int256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_22 << offset));
        return clearedWord | bytes32((uint256(value) & _MASK_22) << offset);
    }


    function insertBits192(
        bytes32 word,
        bytes32 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_192 << offset));
        return clearedWord | bytes32((uint256(value) & _MASK_192) << offset);
    }



    function encodeUint(uint256 value, uint256 offset) internal pure returns (bytes32) {

        return bytes32(value << offset);
    }


    function encodeInt22(int256 value, uint256 offset) internal pure returns (bytes32) {

        return bytes32((uint256(value) & _MASK_22) << offset);
    }

    function encodeInt53(int256 value, uint256 offset) internal pure returns (bytes32) {

        return bytes32((uint256(value) & _MASK_53) << offset);
    }


    function decodeBool(bytes32 word, uint256 offset) internal pure returns (bool) {

        return (uint256(word >> offset) & _MASK_1) == 1;
    }


    function decodeUint10(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_10;
    }

    function decodeUint16(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_16;
    }

    function decodeUint31(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_31;
    }

    function decodeUint32(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_32;
    }

    function decodeUint64(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_64;
    }

    function decodeUint128(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_128;
    }


    function decodeInt22(bytes32 word, uint256 offset) internal pure returns (int256) {

        int256 value = int256(uint256(word >> offset) & _MASK_22);
        return value > _MAX_INT_22 ? (value | int256(~_MASK_22)) : value;
    }

    function decodeInt53(bytes32 word, uint256 offset) internal pure returns (int256) {

        int256 value = int256(uint256(word >> offset) & _MASK_53);

        return value > _MAX_INT_53 ? (value | int256(~_MASK_53)) : value;
    }
}// MIT

pragma solidity ^0.7.0;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        _require(c >= a, Errors.ADD_OVERFLOW);

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, Errors.SUB_OVERFLOW);
    }

    function sub(uint256 a, uint256 b, uint256 errorCode) internal pure returns (uint256) {

        _require(b <= a, errorCode);
        uint256 c = a - b;

        return c;
    }
}// MIT

pragma solidity ^0.7.0;



contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount, Errors.ERC20_TRANSFER_EXCEEDS_ALLOWANCE)
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue, Errors.ERC20_DECREASED_ALLOWANCE_BELOW_ZERO)
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        _require(sender != address(0), Errors.ERC20_TRANSFER_FROM_ZERO_ADDRESS);
        _require(recipient != address(0), Errors.ERC20_TRANSFER_TO_ZERO_ADDRESS);

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, Errors.ERC20_TRANSFER_EXCEEDS_BALANCE);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        _require(account != address(0), Errors.ERC20_BURN_FROM_ZERO_ADDRESS);

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, Errors.ERC20_BURN_EXCEEDS_ALLOWANCE);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface ISignaturesValidator {
    function getDomainSeparator() external view returns (bytes32);

    function getNextNonce(address user) external view returns (uint256);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface IAsset {
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface IAuthorizer {
    function canPerform(
        bytes32 actionId,
        address account,
        address where
    ) external view returns (bool);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



interface IFlashLoanRecipient {
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external;
}// GPL-3.0-or-later



pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;



interface IProtocolFeesCollector {
    event SwapFeePercentageChanged(uint256 newSwapFeePercentage);
    event FlashLoanFeePercentageChanged(uint256 newFlashLoanFeePercentage);

    function withdrawCollectedFees(
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        address recipient
    ) external;

    function setSwapFeePercentage(uint256 newSwapFeePercentage) external;

    function setFlashLoanFeePercentage(uint256 newFlashLoanFeePercentage) external;

    function getSwapFeePercentage() external view returns (uint256);

    function getFlashLoanFeePercentage() external view returns (uint256);

    function getCollectedFeeAmounts(IERC20[] memory tokens) external view returns (uint256[] memory feeAmounts);

    function getAuthorizer() external view returns (IAuthorizer);

    function vault() external view returns (IVault);
}// GPL-3.0-or-later






pragma solidity ^0.7.0;

interface IVault is ISignaturesValidator, ITemporarilyPausable {


    function getAuthorizer() external view returns (IAuthorizer);

    function setAuthorizer(IAuthorizer newAuthorizer) external;

    event AuthorizerChanged(IAuthorizer indexed newAuthorizer);


    function hasApprovedRelayer(address user, address relayer) external view returns (bool);

    function setRelayerApproval(
        address sender,
        address relayer,
        bool approved
    ) external;

    event RelayerApprovalChanged(address indexed relayer, address indexed sender, bool approved);


    function getInternalBalance(address user, IERC20[] memory tokens) external view returns (uint256[] memory);

    function manageUserBalance(UserBalanceOp[] memory ops) external payable;

    struct UserBalanceOp {
        UserBalanceOpKind kind;
        IAsset asset;
        uint256 amount;
        address sender;
        address payable recipient;
    }


    enum UserBalanceOpKind { DEPOSIT_INTERNAL, WITHDRAW_INTERNAL, TRANSFER_INTERNAL, TRANSFER_EXTERNAL }

    event InternalBalanceChanged(address indexed user, IERC20 indexed token, int256 delta);

    event ExternalBalanceTransfer(IERC20 indexed token, address indexed sender, address recipient, uint256 amount);


    enum PoolSpecialization { GENERAL, MINIMAL_SWAP_INFO, TWO_TOKEN }

    function registerPool(PoolSpecialization specialization) external returns (bytes32);

    event PoolRegistered(bytes32 indexed poolId, address indexed poolAddress, PoolSpecialization specialization);

    function getPool(bytes32 poolId) external view returns (address, PoolSpecialization);

    function registerTokens(
        bytes32 poolId,
        IERC20[] memory tokens,
        address[] memory assetManagers
    ) external;

    event TokensRegistered(bytes32 indexed poolId, IERC20[] tokens, address[] assetManagers);

    function deregisterTokens(bytes32 poolId, IERC20[] memory tokens) external;

    event TokensDeregistered(bytes32 indexed poolId, IERC20[] tokens);

    function getPoolTokenInfo(bytes32 poolId, IERC20 token)
        external
        view
        returns (
            uint256 cash,
            uint256 managed,
            uint256 lastChangeBlock,
            address assetManager
        );

    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            IERC20[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        );

    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;

    struct JoinPoolRequest {
        IAsset[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    function exitPool(
        bytes32 poolId,
        address sender,
        address payable recipient,
        ExitPoolRequest memory request
    ) external;

    struct ExitPoolRequest {
        IAsset[] assets;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

    event PoolBalanceChanged(
        bytes32 indexed poolId,
        address indexed liquidityProvider,
        IERC20[] tokens,
        int256[] deltas,
        uint256[] protocolFeeAmounts
    );

    enum PoolBalanceChangeKind { JOIN, EXIT }


    enum SwapKind { GIVEN_IN, GIVEN_OUT }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external payable returns (uint256);

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        IAsset assetIn;
        IAsset assetOut;
        uint256 amount;
        bytes userData;
    }

    function batchSwap(
        SwapKind kind,
        BatchSwapStep[] memory swaps,
        IAsset[] memory assets,
        FundManagement memory funds,
        int256[] memory limits,
        uint256 deadline
    ) external payable returns (int256[] memory);

    struct BatchSwapStep {
        bytes32 poolId;
        uint256 assetInIndex;
        uint256 assetOutIndex;
        uint256 amount;
        bytes userData;
    }

    event Swap(
        bytes32 indexed poolId,
        IERC20 indexed tokenIn,
        IERC20 indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function queryBatchSwap(
        SwapKind kind,
        BatchSwapStep[] memory swaps,
        IAsset[] memory assets,
        FundManagement memory funds
    ) external returns (int256[] memory assetDeltas);


    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;

    event FlashLoan(IFlashLoanRecipient indexed recipient, IERC20 indexed token, uint256 amount, uint256 feeAmount);


    function managePoolBalance(PoolBalanceOp[] memory ops) external;

    struct PoolBalanceOp {
        PoolBalanceOpKind kind;
        bytes32 poolId;
        IERC20 token;
        uint256 amount;
    }

    enum PoolBalanceOpKind { WITHDRAW, DEPOSIT, UPDATE }

    event PoolBalanceManaged(
        bytes32 indexed poolId,
        address indexed assetManager,
        IERC20 indexed token,
        int256 cashDelta,
        int256 managedDelta
    );


    function getProtocolFeesCollector() external view returns (IProtocolFeesCollector);

    function setPaused(bool paused) external;

    function WETH() external view returns (IWETH);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



interface IPoolSwapStructs {
    struct SwapRequest {
        IVault.SwapKind kind;
        IERC20 tokenIn;
        IERC20 tokenOut;
        uint256 amount;
        bytes32 poolId;
        uint256 lastChangeBlock;
        address from;
        address to;
        bytes userData;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IBasePool is IPoolSwapStructs {
    function onJoinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) external returns (uint256[] memory amountsIn, uint256[] memory dueProtocolFeeAmounts);

    function onExitPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) external returns (uint256[] memory amountsOut, uint256[] memory dueProtocolFeeAmounts);

    function getPoolId() external view returns (bytes32);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IAssetManager {
    event Rebalance(bytes32 poolId);

    function setConfig(bytes32 poolId, bytes calldata config) external;


    function getToken() external view returns (IERC20);

    function getAUM(bytes32 poolId) external view returns (uint256);

    function getPoolBalances(bytes32 poolId) external view returns (uint256 poolCash, uint256 poolManaged);

    function maxInvestableBalance(bytes32 poolId) external view returns (int256);

    function updateBalanceOfPool(bytes32 poolId) external;

    function shouldRebalance(uint256 cash, uint256 managed) external view returns (bool);

    function rebalance(bytes32 poolId, bool force) external;

    function capitalOut(bytes32 poolId, uint256 amount) external;
}// MIT

pragma solidity ^0.7.0;

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}// MIT

pragma solidity ^0.7.0;

abstract contract EIP712 {
    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;


    constructor(string memory name, string memory version) {
        _HASHED_NAME = keccak256(bytes(name));
        _HASHED_VERSION = keccak256(bytes(version));
        _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    }

    function _domainSeparatorV4() internal view virtual returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION, _getChainId(), address(this)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
    }

    function _getChainId() private view returns (uint256 chainId) {
        this;

        assembly {
            chainId := chainid()
        }
    }
}// MIT

pragma solidity ^0.7.0;


abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    mapping(address => uint256) private _nonces;

    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor(string memory name) EIP712(name, "1") {}

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        _require(block.timestamp <= deadline, Errors.EXPIRED_PERMIT);

        uint256 nonce = _nonces[owner];
        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ecrecover(hash, v, r, s);
        _require((signer != address(0)) && (signer == owner), Errors.INVALID_SIGNATURE);

        _nonces[owner] = nonce + 1;
        _approve(owner, spender, value);
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner];
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


contract BalancerPoolToken is ERC20, ERC20Permit {
    constructor(string memory tokenName, string memory tokenSymbol)
        ERC20(tokenName, tokenSymbol)
        ERC20Permit(tokenName)
    {
    }


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 currentAllowance = allowance(sender, msg.sender);
        _require(msg.sender == sender || currentAllowance >= amount, Errors.ERC20_TRANSFER_EXCEEDS_ALLOWANCE);

        _transfer(sender, recipient, amount);

        if (msg.sender != sender && currentAllowance != uint256(-1)) {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = allowance(msg.sender, spender);

        if (amount >= currentAllowance) {
            _approve(msg.sender, spender, 0);
        } else {
            _approve(msg.sender, spender, currentAllowance - amount);
        }

        return true;
    }


    function _mintPoolTokens(address recipient, uint256 amount) internal {
        _mint(recipient, amount);
    }

    function _burnPoolTokens(address sender, uint256 amount) internal {
        _burn(sender, amount);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface IAuthentication {
    function getActionId(bytes4 selector) external view returns (bytes32);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


abstract contract Authentication is IAuthentication {
    bytes32 private immutable _actionIdDisambiguator;

    constructor(bytes32 actionIdDisambiguator) {
        _actionIdDisambiguator = actionIdDisambiguator;
    }

    modifier authenticate() {
        _authenticateCaller();
        _;
    }

    function _authenticateCaller() internal view {
        bytes32 actionId = getActionId(msg.sig);
        _require(_canPerform(actionId, msg.sender), Errors.SENDER_NOT_ALLOWED);
    }

    function getActionId(bytes4 selector) public view override returns (bytes32) {
        return keccak256(abi.encodePacked(_actionIdDisambiguator, selector));
    }

    function _canPerform(bytes32 actionId, address user) internal view virtual returns (bool);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



abstract contract BasePoolAuthorization is Authentication {
    address private immutable _owner;

    address private constant _DELEGATE_OWNER = 0xBA1BA1ba1BA1bA1bA1Ba1BA1ba1BA1bA1ba1ba1B;

    constructor(address owner) {
        _owner = owner;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    function getAuthorizer() external view returns (IAuthorizer) {
        return _getAuthorizer();
    }

    function _canPerform(bytes32 actionId, address account) internal view override returns (bool) {
        if ((getOwner() != _DELEGATE_OWNER) && _isOwnerOnlyAction(actionId)) {
            return msg.sender == getOwner();
        } else {
            return _getAuthorizer().canPerform(actionId, account, address(this));
        }
    }

    function _isOwnerOnlyAction(bytes32 actionId) internal view virtual returns (bool);

    function _getAuthorizer() internal view virtual returns (IAuthorizer);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;






abstract contract BasePool is IBasePool, BasePoolAuthorization, BalancerPoolToken, TemporarilyPausable {
    using WordCodec for bytes32;
    using FixedPoint for uint256;

    uint256 private constant _MIN_TOKENS = 2;

    uint256 private constant _MIN_SWAP_FEE_PERCENTAGE = 1e12; // 0.0001%
    uint256 private constant _MAX_SWAP_FEE_PERCENTAGE = 1e17; // 10%

    uint256 private constant _MINIMUM_BPT = 1e6;

    bytes32 private _miscData;
    uint256 private constant _SWAP_FEE_PERCENTAGE_OFFSET = 192;

    IVault private immutable _vault;
    bytes32 private immutable _poolId;

    event SwapFeePercentageChanged(uint256 swapFeePercentage);

    constructor(
        IVault vault,
        IVault.PoolSpecialization specialization,
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        address[] memory assetManagers,
        uint256 swapFeePercentage,
        uint256 pauseWindowDuration,
        uint256 bufferPeriodDuration,
        address owner
    )
        Authentication(bytes32(uint256(msg.sender)))
        BalancerPoolToken(name, symbol)
        BasePoolAuthorization(owner)
        TemporarilyPausable(pauseWindowDuration, bufferPeriodDuration)
    {
        _require(tokens.length >= _MIN_TOKENS, Errors.MIN_TOKENS);
        _require(tokens.length <= _getMaxTokens(), Errors.MAX_TOKENS);

        InputHelpers.ensureArrayIsSorted(tokens);

        _setSwapFeePercentage(swapFeePercentage);

        bytes32 poolId = vault.registerPool(specialization);

        vault.registerTokens(poolId, tokens, assetManagers);

        _vault = vault;
        _poolId = poolId;
    }


    function getVault() public view returns (IVault) {
        return _vault;
    }

    function getPoolId() public view override returns (bytes32) {
        return _poolId;
    }

    function _getTotalTokens() internal view virtual returns (uint256);

    function _getMaxTokens() internal pure virtual returns (uint256);

    function getSwapFeePercentage() public view returns (uint256) {
        return _miscData.decodeUint64(_SWAP_FEE_PERCENTAGE_OFFSET);
    }

    function setSwapFeePercentage(uint256 swapFeePercentage) external virtual authenticate whenNotPaused {
        _setSwapFeePercentage(swapFeePercentage);
    }

    function _setSwapFeePercentage(uint256 swapFeePercentage) private {
        _require(swapFeePercentage >= _MIN_SWAP_FEE_PERCENTAGE, Errors.MIN_SWAP_FEE_PERCENTAGE);
        _require(swapFeePercentage <= _MAX_SWAP_FEE_PERCENTAGE, Errors.MAX_SWAP_FEE_PERCENTAGE);

        _miscData = _miscData.insertUint64(swapFeePercentage, _SWAP_FEE_PERCENTAGE_OFFSET);
        emit SwapFeePercentageChanged(swapFeePercentage);
    }

    function setAssetManagerPoolConfig(IERC20 token, bytes memory poolConfig)
        public
        virtual
        authenticate
        whenNotPaused
    {
        _setAssetManagerPoolConfig(token, poolConfig);
    }

    function _setAssetManagerPoolConfig(IERC20 token, bytes memory poolConfig) private {
        bytes32 poolId = getPoolId();
        (, , , address assetManager) = getVault().getPoolTokenInfo(poolId, token);

        IAssetManager(assetManager).setConfig(poolId, poolConfig);
    }

    function setPaused(bool paused) external authenticate {
        _setPaused(paused);
    }

    function _isOwnerOnlyAction(bytes32 actionId) internal view virtual override returns (bool) {
        return
            (actionId == getActionId(this.setSwapFeePercentage.selector)) ||
            (actionId == getActionId(this.setAssetManagerPoolConfig.selector));
    }

    function _getMiscData() internal view returns (bytes32) {
        return _miscData;
    }

    function _setMiscData(bytes32 newData) internal {
        _miscData = _miscData.insertBits192(newData, 0);
    }


    modifier onlyVault(bytes32 poolId) {
        _require(msg.sender == address(getVault()), Errors.CALLER_NOT_VAULT);
        _require(poolId == getPoolId(), Errors.INVALID_POOL_ID);
        _;
    }

    function onJoinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) public virtual override onlyVault(poolId) returns (uint256[] memory, uint256[] memory) {
        uint256[] memory scalingFactors = _scalingFactors();

        if (totalSupply() == 0) {
            (uint256 bptAmountOut, uint256[] memory amountsIn) = _onInitializePool(
                poolId,
                sender,
                recipient,
                scalingFactors,
                userData
            );

            _require(bptAmountOut >= _MINIMUM_BPT, Errors.MINIMUM_BPT);
            _mintPoolTokens(address(0), _MINIMUM_BPT);
            _mintPoolTokens(recipient, bptAmountOut - _MINIMUM_BPT);

            _downscaleUpArray(amountsIn, scalingFactors);

            return (amountsIn, new uint256[](_getTotalTokens()));
        } else {
            _upscaleArray(balances, scalingFactors);
            (uint256 bptAmountOut, uint256[] memory amountsIn, uint256[] memory dueProtocolFeeAmounts) = _onJoinPool(
                poolId,
                sender,
                recipient,
                balances,
                lastChangeBlock,
                protocolSwapFeePercentage,
                scalingFactors,
                userData
            );


            _mintPoolTokens(recipient, bptAmountOut);

            _downscaleUpArray(amountsIn, scalingFactors);
            _downscaleDownArray(dueProtocolFeeAmounts, scalingFactors);

            return (amountsIn, dueProtocolFeeAmounts);
        }
    }

    function onExitPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) public virtual override onlyVault(poolId) returns (uint256[] memory, uint256[] memory) {
        uint256[] memory scalingFactors = _scalingFactors();
        _upscaleArray(balances, scalingFactors);

        (uint256 bptAmountIn, uint256[] memory amountsOut, uint256[] memory dueProtocolFeeAmounts) = _onExitPool(
            poolId,
            sender,
            recipient,
            balances,
            lastChangeBlock,
            protocolSwapFeePercentage,
            scalingFactors,
            userData
        );


        _burnPoolTokens(sender, bptAmountIn);

        _downscaleDownArray(amountsOut, scalingFactors);
        _downscaleDownArray(dueProtocolFeeAmounts, scalingFactors);

        return (amountsOut, dueProtocolFeeAmounts);
    }


    function queryJoin(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) external returns (uint256 bptOut, uint256[] memory amountsIn) {
        InputHelpers.ensureInputLengthMatch(balances.length, _getTotalTokens());

        _queryAction(
            poolId,
            sender,
            recipient,
            balances,
            lastChangeBlock,
            protocolSwapFeePercentage,
            userData,
            _onJoinPool,
            _downscaleUpArray
        );

        return (bptOut, amountsIn);
    }

    function queryExit(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) external returns (uint256 bptIn, uint256[] memory amountsOut) {
        InputHelpers.ensureInputLengthMatch(balances.length, _getTotalTokens());

        _queryAction(
            poolId,
            sender,
            recipient,
            balances,
            lastChangeBlock,
            protocolSwapFeePercentage,
            userData,
            _onExitPool,
            _downscaleDownArray
        );

        return (bptIn, amountsOut);
    }


    function _onInitializePool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory scalingFactors,
        bytes memory userData
    ) internal virtual returns (uint256 bptAmountOut, uint256[] memory amountsIn);

    function _onJoinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        uint256[] memory scalingFactors,
        bytes memory userData
    )
        internal
        virtual
        returns (
            uint256 bptAmountOut,
            uint256[] memory amountsIn,
            uint256[] memory dueProtocolFeeAmounts
        );

    function _onExitPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        uint256[] memory scalingFactors,
        bytes memory userData
    )
        internal
        virtual
        returns (
            uint256 bptAmountIn,
            uint256[] memory amountsOut,
            uint256[] memory dueProtocolFeeAmounts
        );


    function _addSwapFeeAmount(uint256 amount) internal view returns (uint256) {
        return amount.divUp(FixedPoint.ONE.sub(getSwapFeePercentage()));
    }

    function _subtractSwapFeeAmount(uint256 amount) internal view returns (uint256) {
        uint256 feeAmount = amount.mulUp(getSwapFeePercentage());
        return amount.sub(feeAmount);
    }


    function _computeScalingFactor(IERC20 token) internal view returns (uint256) {
        uint256 tokenDecimals = ERC20(address(token)).decimals();

        uint256 decimalsDifference = Math.sub(18, tokenDecimals);
        return FixedPoint.ONE * 10**decimalsDifference;
    }

    function _scalingFactor(IERC20 token) internal view virtual returns (uint256);

    function _scalingFactors() internal view virtual returns (uint256[] memory);

    function getScalingFactors() external view returns (uint256[] memory) {
        return _scalingFactors();
    }

    function _upscale(uint256 amount, uint256 scalingFactor) internal pure returns (uint256) {
        return FixedPoint.mulDown(amount, scalingFactor);
    }

    function _upscaleArray(uint256[] memory amounts, uint256[] memory scalingFactors) internal view {
        for (uint256 i = 0; i < _getTotalTokens(); ++i) {
            amounts[i] = FixedPoint.mulDown(amounts[i], scalingFactors[i]);
        }
    }

    function _downscaleDown(uint256 amount, uint256 scalingFactor) internal pure returns (uint256) {
        return FixedPoint.divDown(amount, scalingFactor);
    }

    function _downscaleDownArray(uint256[] memory amounts, uint256[] memory scalingFactors) internal view {
        for (uint256 i = 0; i < _getTotalTokens(); ++i) {
            amounts[i] = FixedPoint.divDown(amounts[i], scalingFactors[i]);
        }
    }

    function _downscaleUp(uint256 amount, uint256 scalingFactor) internal pure returns (uint256) {
        return FixedPoint.divUp(amount, scalingFactor);
    }

    function _downscaleUpArray(uint256[] memory amounts, uint256[] memory scalingFactors) internal view {
        for (uint256 i = 0; i < _getTotalTokens(); ++i) {
            amounts[i] = FixedPoint.divUp(amounts[i], scalingFactors[i]);
        }
    }

    function _getAuthorizer() internal view override returns (IAuthorizer) {
        return getVault().getAuthorizer();
    }

    function _queryAction(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData,
        function(bytes32, address, address, uint256[] memory, uint256, uint256, uint256[] memory, bytes memory)
            internal
            returns (uint256, uint256[] memory, uint256[] memory) _action,
        function(uint256[] memory, uint256[] memory) internal view _downscaleArray
    ) private {

        if (msg.sender != address(this)) {

            (bool success, ) = address(this).call(msg.data);

            assembly {
                switch success
                    case 0 {

                        returndatacopy(0, 0, 0x04)
                        let error := and(mload(0), 0xffffffff00000000000000000000000000000000000000000000000000000000)

                        if eq(eq(error, 0x43adbafb00000000000000000000000000000000000000000000000000000000), 0) {
                            returndatacopy(0, 0, returndatasize())
                            revert(0, returndatasize())
                        }


                        returndatacopy(0, 0x04, 32)

                        mstore(0x20, 64)

                        returndatacopy(0x40, 0x24, sub(returndatasize(), 36))

                        return(0, add(returndatasize(), 28))
                    }
                    default {
                        invalid()
                    }
            }
        } else {
            uint256[] memory scalingFactors = _scalingFactors();
            _upscaleArray(balances, scalingFactors);

            (uint256 bptAmount, uint256[] memory tokenAmounts, ) = _action(
                poolId,
                sender,
                recipient,
                balances,
                lastChangeBlock,
                protocolSwapFeePercentage,
                scalingFactors,
                userData
            );

            _downscaleArray(tokenAmounts, scalingFactors);

            assembly {
                let size := mul(mload(tokenAmounts), 32)

                let start := sub(tokenAmounts, 0x20)
                mstore(start, bptAmount)

                mstore(sub(start, 0x20), 0x0000000000000000000000000000000000000000000000000000000043adbafb)
                start := sub(start, 0x04)

                revert(start, add(size, 68))
            }
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IMinimalSwapInfoPool is IBasePool {
    function onSwap(
        SwapRequest memory swapRequest,
        uint256 currentBalanceTokenIn,
        uint256 currentBalanceTokenOut
    ) external returns (uint256 amount);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


abstract contract BaseMinimalSwapInfoPool is IMinimalSwapInfoPool, BasePool {

    function onSwap(
        SwapRequest memory request,
        uint256 balanceTokenIn,
        uint256 balanceTokenOut
    ) public virtual override returns (uint256) {
        uint256 scalingFactorTokenIn = _scalingFactor(request.tokenIn);
        uint256 scalingFactorTokenOut = _scalingFactor(request.tokenOut);

        if (request.kind == IVault.SwapKind.GIVEN_IN) {
            request.amount = _subtractSwapFeeAmount(request.amount);

            balanceTokenIn = _upscale(balanceTokenIn, scalingFactorTokenIn);
            balanceTokenOut = _upscale(balanceTokenOut, scalingFactorTokenOut);
            request.amount = _upscale(request.amount, scalingFactorTokenIn);

            uint256 amountOut = _onSwapGivenIn(request, balanceTokenIn, balanceTokenOut);

            return _downscaleDown(amountOut, scalingFactorTokenOut);
        } else {
            balanceTokenIn = _upscale(balanceTokenIn, scalingFactorTokenIn);
            balanceTokenOut = _upscale(balanceTokenOut, scalingFactorTokenOut);
            request.amount = _upscale(request.amount, scalingFactorTokenOut);

            uint256 amountIn = _onSwapGivenOut(request, balanceTokenIn, balanceTokenOut);

            amountIn = _downscaleUp(amountIn, scalingFactorTokenIn);

            return _addSwapFeeAmount(amountIn);
        }
    }

    function _onSwapGivenIn(
        SwapRequest memory swapRequest,
        uint256 balanceTokenIn,
        uint256 balanceTokenOut
    ) internal virtual returns (uint256);

    function _onSwapGivenOut(
        SwapRequest memory swapRequest,
        uint256 balanceTokenIn,
        uint256 balanceTokenOut
    ) internal virtual returns (uint256);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



contract WeightedMath {
    using FixedPoint for uint256;
    uint256 internal constant _MIN_WEIGHT = 0.01e18;
    uint256 internal constant _MAX_WEIGHTED_TOKENS = 100;


    uint256 internal constant _MAX_IN_RATIO = 0.3e18;
    uint256 internal constant _MAX_OUT_RATIO = 0.3e18;

    uint256 internal constant _MAX_INVARIANT_RATIO = 3e18;
    uint256 internal constant _MIN_INVARIANT_RATIO = 0.7e18;

    function _calculateInvariant(uint256[] memory normalizedWeights, uint256[] memory balances)
        internal
        pure
        returns (uint256 invariant)
    {

        invariant = FixedPoint.ONE;
        for (uint256 i = 0; i < normalizedWeights.length; i++) {
            invariant = invariant.mulDown(balances[i].powDown(normalizedWeights[i]));
        }

        _require(invariant > 0, Errors.ZERO_INVARIANT);
    }

    function _calcOutGivenIn(
        uint256 balanceIn,
        uint256 weightIn,
        uint256 balanceOut,
        uint256 weightOut,
        uint256 amountIn
    ) internal pure returns (uint256) {



        _require(amountIn <= balanceIn.mulDown(_MAX_IN_RATIO), Errors.MAX_IN_RATIO);

        uint256 denominator = balanceIn.add(amountIn);
        uint256 base = balanceIn.divUp(denominator);
        uint256 exponent = weightIn.divDown(weightOut);
        uint256 power = base.powUp(exponent);

        return balanceOut.mulDown(power.complement());
    }

    function _calcInGivenOut(
        uint256 balanceIn,
        uint256 weightIn,
        uint256 balanceOut,
        uint256 weightOut,
        uint256 amountOut
    ) internal pure returns (uint256) {



        _require(amountOut <= balanceOut.mulDown(_MAX_OUT_RATIO), Errors.MAX_OUT_RATIO);

        uint256 base = balanceOut.divUp(balanceOut.sub(amountOut));
        uint256 exponent = weightOut.divUp(weightIn);
        uint256 power = base.powUp(exponent);

        uint256 ratio = power.sub(FixedPoint.ONE);

        return balanceIn.mulUp(ratio);
    }

    function _calcBptOutGivenExactTokensIn(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory amountsIn,
        uint256 bptTotalSupply,
        uint256 swapFeePercentage
    ) internal pure returns (uint256) {

        uint256[] memory balanceRatiosWithFee = new uint256[](amountsIn.length);

        uint256 invariantRatioWithFees = 0;
        for (uint256 i = 0; i < balances.length; i++) {
            balanceRatiosWithFee[i] = balances[i].add(amountsIn[i]).divDown(balances[i]);
            invariantRatioWithFees = invariantRatioWithFees.add(balanceRatiosWithFee[i].mulDown(normalizedWeights[i]));
        }

        uint256 invariantRatio = FixedPoint.ONE;
        for (uint256 i = 0; i < balances.length; i++) {
            uint256 amountInWithoutFee;

            if (balanceRatiosWithFee[i] > invariantRatioWithFees) {
                uint256 nonTaxableAmount = balances[i].mulDown(invariantRatioWithFees.sub(FixedPoint.ONE));
                uint256 taxableAmount = amountsIn[i].sub(nonTaxableAmount);
                amountInWithoutFee = nonTaxableAmount.add(taxableAmount.mulDown(FixedPoint.ONE.sub(swapFeePercentage)));
            } else {
                amountInWithoutFee = amountsIn[i];
            }

            uint256 balanceRatio = balances[i].add(amountInWithoutFee).divDown(balances[i]);

            invariantRatio = invariantRatio.mulDown(balanceRatio.powDown(normalizedWeights[i]));
        }

        if (invariantRatio > FixedPoint.ONE) {
            return bptTotalSupply.mulDown(invariantRatio.sub(FixedPoint.ONE));
        } else {
            return 0;
        }
    }

    function _calcTokenInGivenExactBptOut(
        uint256 balance,
        uint256 normalizedWeight,
        uint256 bptAmountOut,
        uint256 bptTotalSupply,
        uint256 swapFeePercentage
    ) internal pure returns (uint256) {


        uint256 invariantRatio = bptTotalSupply.add(bptAmountOut).divUp(bptTotalSupply);
        _require(invariantRatio <= _MAX_INVARIANT_RATIO, Errors.MAX_OUT_BPT_FOR_TOKEN_IN);

        uint256 balanceRatio = invariantRatio.powUp(FixedPoint.ONE.divUp(normalizedWeight));

        uint256 amountInWithoutFee = balance.mulUp(balanceRatio.sub(FixedPoint.ONE));

        uint256 taxablePercentage = normalizedWeight.complement();
        uint256 taxableAmount = amountInWithoutFee.mulUp(taxablePercentage);
        uint256 nonTaxableAmount = amountInWithoutFee.sub(taxableAmount);

        return nonTaxableAmount.add(taxableAmount.divUp(FixedPoint.ONE.sub(swapFeePercentage)));
    }

    function _calcBptInGivenExactTokensOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory amountsOut,
        uint256 bptTotalSupply,
        uint256 swapFeePercentage
    ) internal pure returns (uint256) {

        uint256[] memory balanceRatiosWithoutFee = new uint256[](amountsOut.length);
        uint256 invariantRatioWithoutFees = 0;
        for (uint256 i = 0; i < balances.length; i++) {
            balanceRatiosWithoutFee[i] = balances[i].sub(amountsOut[i]).divUp(balances[i]);
            invariantRatioWithoutFees = invariantRatioWithoutFees.add(
                balanceRatiosWithoutFee[i].mulUp(normalizedWeights[i])
            );
        }

        uint256 invariantRatio = FixedPoint.ONE;
        for (uint256 i = 0; i < balances.length; i++) {

            uint256 amountOutWithFee;
            if (invariantRatioWithoutFees > balanceRatiosWithoutFee[i]) {
                uint256 nonTaxableAmount = balances[i].mulDown(invariantRatioWithoutFees.complement());
                uint256 taxableAmount = amountsOut[i].sub(nonTaxableAmount);
                amountOutWithFee = nonTaxableAmount.add(taxableAmount.divUp(FixedPoint.ONE.sub(swapFeePercentage)));
            } else {
                amountOutWithFee = amountsOut[i];
            }

            uint256 balanceRatio = balances[i].sub(amountOutWithFee).divDown(balances[i]);

            invariantRatio = invariantRatio.mulDown(balanceRatio.powDown(normalizedWeights[i]));
        }

        return bptTotalSupply.mulUp(invariantRatio.complement());
    }

    function _calcTokenOutGivenExactBptIn(
        uint256 balance,
        uint256 normalizedWeight,
        uint256 bptAmountIn,
        uint256 bptTotalSupply,
        uint256 swapFeePercentage
    ) internal pure returns (uint256) {


        uint256 invariantRatio = bptTotalSupply.sub(bptAmountIn).divUp(bptTotalSupply);
        _require(invariantRatio >= _MIN_INVARIANT_RATIO, Errors.MIN_BPT_IN_FOR_TOKEN_OUT);

        uint256 balanceRatio = invariantRatio.powUp(FixedPoint.ONE.divDown(normalizedWeight));

        uint256 amountOutWithoutFee = balance.mulDown(balanceRatio.complement());

        uint256 taxablePercentage = normalizedWeight.complement();

        uint256 taxableAmount = amountOutWithoutFee.mulUp(taxablePercentage);
        uint256 nonTaxableAmount = amountOutWithoutFee.sub(taxableAmount);

        return nonTaxableAmount.add(taxableAmount.mulDown(FixedPoint.ONE.sub(swapFeePercentage)));
    }

    function _calcTokensOutGivenExactBptIn(
        uint256[] memory balances,
        uint256 bptAmountIn,
        uint256 totalBPT
    ) internal pure returns (uint256[] memory) {


        uint256 bptRatio = bptAmountIn.divDown(totalBPT);

        uint256[] memory amountsOut = new uint256[](balances.length);
        for (uint256 i = 0; i < balances.length; i++) {
            amountsOut[i] = balances[i].mulDown(bptRatio);
        }

        return amountsOut;
    }

    function _calcDueTokenProtocolSwapFeeAmount(
        uint256 balance,
        uint256 normalizedWeight,
        uint256 previousInvariant,
        uint256 currentInvariant,
        uint256 protocolSwapFeePercentage
    ) internal pure returns (uint256) {

        if (currentInvariant <= previousInvariant) {
            return 0;
        }



        uint256 base = previousInvariant.divUp(currentInvariant);
        uint256 exponent = FixedPoint.ONE.divDown(normalizedWeight);

        base = Math.max(base, FixedPoint.MIN_POW_BASE_FREE_EXPONENT);

        uint256 power = base.powUp(exponent);

        uint256 tokenAccruedFees = balance.mulDown(power.complement());
        return tokenAccruedFees.mulDown(protocolSwapFeePercentage);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



library WeightedPoolUserDataHelpers {
    function joinKind(bytes memory self) internal pure returns (BaseWeightedPool.JoinKind) {
        return abi.decode(self, (BaseWeightedPool.JoinKind));
    }

    function exitKind(bytes memory self) internal pure returns (BaseWeightedPool.ExitKind) {
        return abi.decode(self, (BaseWeightedPool.ExitKind));
    }


    function initialAmountsIn(bytes memory self) internal pure returns (uint256[] memory amountsIn) {
        (, amountsIn) = abi.decode(self, (BaseWeightedPool.JoinKind, uint256[]));
    }

    function exactTokensInForBptOut(bytes memory self)
        internal
        pure
        returns (uint256[] memory amountsIn, uint256 minBPTAmountOut)
    {
        (, amountsIn, minBPTAmountOut) = abi.decode(self, (BaseWeightedPool.JoinKind, uint256[], uint256));
    }

    function tokenInForExactBptOut(bytes memory self) internal pure returns (uint256 bptAmountOut, uint256 tokenIndex) {
        (, bptAmountOut, tokenIndex) = abi.decode(self, (BaseWeightedPool.JoinKind, uint256, uint256));
    }


    function exactBptInForTokenOut(bytes memory self) internal pure returns (uint256 bptAmountIn, uint256 tokenIndex) {
        (, bptAmountIn, tokenIndex) = abi.decode(self, (BaseWeightedPool.ExitKind, uint256, uint256));
    }

    function exactBptInForTokensOut(bytes memory self) internal pure returns (uint256 bptAmountIn) {
        (, bptAmountIn) = abi.decode(self, (BaseWeightedPool.ExitKind, uint256));
    }

    function bptInForExactTokensOut(bytes memory self)
        internal
        pure
        returns (uint256[] memory amountsOut, uint256 maxBPTAmountIn)
    {
        (, amountsOut, maxBPTAmountIn) = abi.decode(self, (BaseWeightedPool.ExitKind, uint256[], uint256));
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;




abstract contract BaseWeightedPool is BaseMinimalSwapInfoPool, WeightedMath {
    using FixedPoint for uint256;
    using WeightedPoolUserDataHelpers for bytes;

    uint256 private _lastInvariant;

    enum JoinKind { INIT, EXACT_TOKENS_IN_FOR_BPT_OUT, TOKEN_IN_FOR_EXACT_BPT_OUT }
    enum ExitKind { EXACT_BPT_IN_FOR_ONE_TOKEN_OUT, EXACT_BPT_IN_FOR_TOKENS_OUT, BPT_IN_FOR_EXACT_TOKENS_OUT }

    constructor(
        IVault vault,
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        address[] memory assetManagers,
        uint256 swapFeePercentage,
        uint256 pauseWindowDuration,
        uint256 bufferPeriodDuration,
        address owner
    )
        BasePool(
            vault,
            tokens.length == 2 ? IVault.PoolSpecialization.TWO_TOKEN : IVault.PoolSpecialization.MINIMAL_SWAP_INFO,
            name,
            symbol,
            tokens,
            assetManagers,
            swapFeePercentage,
            pauseWindowDuration,
            bufferPeriodDuration,
            owner
        )
    {
    }


    function _getNormalizedWeight(IERC20 token) internal view virtual returns (uint256);

    function _getNormalizedWeights() internal view virtual returns (uint256[] memory);

    function _getNormalizedWeightsAndMaxWeightIndex() internal view virtual returns (uint256[] memory, uint256);

    function getLastInvariant() external view returns (uint256) {
        return _lastInvariant;
    }

    function getInvariant() public view returns (uint256) {
        (, uint256[] memory balances, ) = getVault().getPoolTokens(getPoolId());

        _upscaleArray(balances, _scalingFactors());

        (uint256[] memory normalizedWeights, ) = _getNormalizedWeightsAndMaxWeightIndex();
        return WeightedMath._calculateInvariant(normalizedWeights, balances);
    }

    function getNormalizedWeights() external view returns (uint256[] memory) {
        return _getNormalizedWeights();
    }



    function _onSwapGivenIn(
        SwapRequest memory swapRequest,
        uint256 currentBalanceTokenIn,
        uint256 currentBalanceTokenOut
    ) internal view virtual override whenNotPaused returns (uint256) {

        return
            WeightedMath._calcOutGivenIn(
                currentBalanceTokenIn,
                _getNormalizedWeight(swapRequest.tokenIn),
                currentBalanceTokenOut,
                _getNormalizedWeight(swapRequest.tokenOut),
                swapRequest.amount
            );
    }

    function _onSwapGivenOut(
        SwapRequest memory swapRequest,
        uint256 currentBalanceTokenIn,
        uint256 currentBalanceTokenOut
    ) internal view virtual override whenNotPaused returns (uint256) {

        return
            WeightedMath._calcInGivenOut(
                currentBalanceTokenIn,
                _getNormalizedWeight(swapRequest.tokenIn),
                currentBalanceTokenOut,
                _getNormalizedWeight(swapRequest.tokenOut),
                swapRequest.amount
            );
    }


    function _onInitializePool(
        bytes32,
        address,
        address,
        uint256[] memory scalingFactors,
        bytes memory userData
    ) internal virtual override whenNotPaused returns (uint256, uint256[] memory) {

        JoinKind kind = userData.joinKind();
        _require(kind == JoinKind.INIT, Errors.UNINITIALIZED);

        uint256[] memory amountsIn = userData.initialAmountsIn();
        InputHelpers.ensureInputLengthMatch(_getTotalTokens(), amountsIn.length);
        _upscaleArray(amountsIn, scalingFactors);

        (uint256[] memory normalizedWeights, ) = _getNormalizedWeightsAndMaxWeightIndex();

        uint256 invariantAfterJoin = WeightedMath._calculateInvariant(normalizedWeights, amountsIn);

        uint256 bptAmountOut = Math.mul(invariantAfterJoin, _getTotalTokens());

        _lastInvariant = invariantAfterJoin;

        return (bptAmountOut, amountsIn);
    }


    function _onJoinPool(
        bytes32,
        address,
        address,
        uint256[] memory balances,
        uint256,
        uint256 protocolSwapFeePercentage,
        uint256[] memory scalingFactors,
        bytes memory userData
    )
        internal
        virtual
        override
        whenNotPaused
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory
        )
    {

        (uint256[] memory normalizedWeights, uint256 maxWeightTokenIndex) = _getNormalizedWeightsAndMaxWeightIndex();

        uint256 invariantBeforeJoin = WeightedMath._calculateInvariant(normalizedWeights, balances);

        uint256[] memory dueProtocolFeeAmounts = _getDueProtocolFeeAmounts(
            balances,
            normalizedWeights,
            maxWeightTokenIndex,
            _lastInvariant,
            invariantBeforeJoin,
            protocolSwapFeePercentage
        );

        _mutateAmounts(balances, dueProtocolFeeAmounts, FixedPoint.sub);
        (uint256 bptAmountOut, uint256[] memory amountsIn) = _doJoin(
            balances,
            normalizedWeights,
            scalingFactors,
            userData
        );

        _lastInvariant = _invariantAfterJoin(balances, amountsIn, normalizedWeights);

        return (bptAmountOut, amountsIn, dueProtocolFeeAmounts);
    }

    function _doJoin(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory scalingFactors,
        bytes memory userData
    ) private view returns (uint256, uint256[] memory) {
        JoinKind kind = userData.joinKind();

        if (kind == JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT) {
            return _joinExactTokensInForBPTOut(balances, normalizedWeights, scalingFactors, userData);
        } else if (kind == JoinKind.TOKEN_IN_FOR_EXACT_BPT_OUT) {
            return _joinTokenInForExactBPTOut(balances, normalizedWeights, userData);
        } else {
            _revert(Errors.UNHANDLED_JOIN_KIND);
        }
    }

    function _joinExactTokensInForBPTOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory scalingFactors,
        bytes memory userData
    ) private view returns (uint256, uint256[] memory) {
        (uint256[] memory amountsIn, uint256 minBPTAmountOut) = userData.exactTokensInForBptOut();
        InputHelpers.ensureInputLengthMatch(_getTotalTokens(), amountsIn.length);

        _upscaleArray(amountsIn, scalingFactors);

        uint256 bptAmountOut = WeightedMath._calcBptOutGivenExactTokensIn(
            balances,
            normalizedWeights,
            amountsIn,
            totalSupply(),
            getSwapFeePercentage()
        );

        _require(bptAmountOut >= minBPTAmountOut, Errors.BPT_OUT_MIN_AMOUNT);

        return (bptAmountOut, amountsIn);
    }

    function _joinTokenInForExactBPTOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        bytes memory userData
    ) private view returns (uint256, uint256[] memory) {
        (uint256 bptAmountOut, uint256 tokenIndex) = userData.tokenInForExactBptOut();

        _require(tokenIndex < _getTotalTokens(), Errors.OUT_OF_BOUNDS);

        uint256[] memory amountsIn = new uint256[](_getTotalTokens());
        amountsIn[tokenIndex] = WeightedMath._calcTokenInGivenExactBptOut(
            balances[tokenIndex],
            normalizedWeights[tokenIndex],
            bptAmountOut,
            totalSupply(),
            getSwapFeePercentage()
        );

        return (bptAmountOut, amountsIn);
    }


    function _onExitPool(
        bytes32,
        address,
        address,
        uint256[] memory balances,
        uint256,
        uint256 protocolSwapFeePercentage,
        uint256[] memory scalingFactors,
        bytes memory userData
    )
        internal
        virtual
        override
        returns (
            uint256 bptAmountIn,
            uint256[] memory amountsOut,
            uint256[] memory dueProtocolFeeAmounts
        )
    {
        (uint256[] memory normalizedWeights, uint256 maxWeightTokenIndex) = _getNormalizedWeightsAndMaxWeightIndex();


        if (_isNotPaused()) {
            uint256 invariantBeforeExit = WeightedMath._calculateInvariant(normalizedWeights, balances);
            dueProtocolFeeAmounts = _getDueProtocolFeeAmounts(
                balances,
                normalizedWeights,
                maxWeightTokenIndex,
                _lastInvariant,
                invariantBeforeExit,
                protocolSwapFeePercentage
            );

            _mutateAmounts(balances, dueProtocolFeeAmounts, FixedPoint.sub);
        } else {
            dueProtocolFeeAmounts = new uint256[](_getTotalTokens());
        }

        (bptAmountIn, amountsOut) = _doExit(balances, normalizedWeights, scalingFactors, userData);

        _lastInvariant = _invariantAfterExit(balances, amountsOut, normalizedWeights);

        return (bptAmountIn, amountsOut, dueProtocolFeeAmounts);
    }

    function _doExit(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory scalingFactors,
        bytes memory userData
    ) private view returns (uint256, uint256[] memory) {
        ExitKind kind = userData.exitKind();

        if (kind == ExitKind.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT) {
            return _exitExactBPTInForTokenOut(balances, normalizedWeights, userData);
        } else if (kind == ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT) {
            return _exitExactBPTInForTokensOut(balances, userData);
        } else {
            return _exitBPTInForExactTokensOut(balances, normalizedWeights, scalingFactors, userData);
        }
    }

    function _exitExactBPTInForTokenOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        bytes memory userData
    ) private view whenNotPaused returns (uint256, uint256[] memory) {

        (uint256 bptAmountIn, uint256 tokenIndex) = userData.exactBptInForTokenOut();

        _require(tokenIndex < _getTotalTokens(), Errors.OUT_OF_BOUNDS);

        uint256[] memory amountsOut = new uint256[](_getTotalTokens());

        amountsOut[tokenIndex] = WeightedMath._calcTokenOutGivenExactBptIn(
            balances[tokenIndex],
            normalizedWeights[tokenIndex],
            bptAmountIn,
            totalSupply(),
            getSwapFeePercentage()
        );

        return (bptAmountIn, amountsOut);
    }

    function _exitExactBPTInForTokensOut(uint256[] memory balances, bytes memory userData)
        private
        view
        returns (uint256, uint256[] memory)
    {

        uint256 bptAmountIn = userData.exactBptInForTokensOut();

        uint256[] memory amountsOut = WeightedMath._calcTokensOutGivenExactBptIn(balances, bptAmountIn, totalSupply());
        return (bptAmountIn, amountsOut);
    }

    function _exitBPTInForExactTokensOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory scalingFactors,
        bytes memory userData
    ) private view whenNotPaused returns (uint256, uint256[] memory) {

        (uint256[] memory amountsOut, uint256 maxBPTAmountIn) = userData.bptInForExactTokensOut();
        InputHelpers.ensureInputLengthMatch(amountsOut.length, _getTotalTokens());
        _upscaleArray(amountsOut, scalingFactors);

        uint256 bptAmountIn = WeightedMath._calcBptInGivenExactTokensOut(
            balances,
            normalizedWeights,
            amountsOut,
            totalSupply(),
            getSwapFeePercentage()
        );
        _require(bptAmountIn <= maxBPTAmountIn, Errors.BPT_IN_MAX_AMOUNT);

        return (bptAmountIn, amountsOut);
    }


    function _getDueProtocolFeeAmounts(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256 maxWeightTokenIndex,
        uint256 previousInvariant,
        uint256 currentInvariant,
        uint256 protocolSwapFeePercentage
    ) private view returns (uint256[] memory) {
        uint256[] memory dueProtocolFeeAmounts = new uint256[](_getTotalTokens());

        if (protocolSwapFeePercentage == 0) {
            return dueProtocolFeeAmounts;
        }

        dueProtocolFeeAmounts[maxWeightTokenIndex] = WeightedMath._calcDueTokenProtocolSwapFeeAmount(
            balances[maxWeightTokenIndex],
            normalizedWeights[maxWeightTokenIndex],
            previousInvariant,
            currentInvariant,
            protocolSwapFeePercentage
        );

        return dueProtocolFeeAmounts;
    }

    function _invariantAfterJoin(
        uint256[] memory balances,
        uint256[] memory amountsIn,
        uint256[] memory normalizedWeights
    ) private view returns (uint256) {
        _mutateAmounts(balances, amountsIn, FixedPoint.add);
        return WeightedMath._calculateInvariant(normalizedWeights, balances);
    }

    function _invariantAfterExit(
        uint256[] memory balances,
        uint256[] memory amountsOut,
        uint256[] memory normalizedWeights
    ) private view returns (uint256) {
        _mutateAmounts(balances, amountsOut, FixedPoint.sub);
        return WeightedMath._calculateInvariant(normalizedWeights, balances);
    }

    function _mutateAmounts(
        uint256[] memory toMutate,
        uint256[] memory arguments,
        function(uint256, uint256) pure returns (uint256) mutation
    ) private view {
        for (uint256 i = 0; i < _getTotalTokens(); ++i) {
            toMutate[i] = mutation(toMutate[i], arguments[i]);
        }
    }

    function getRate() public view returns (uint256) {
        return Math.mul(getInvariant(), _getTotalTokens()).divDown(totalSupply());
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


contract WeightedPool is BaseWeightedPool {
    using FixedPoint for uint256;

    uint256 private constant _MAX_TOKENS = 20;

    uint256 private immutable _totalTokens;

    IERC20 internal immutable _token0;
    IERC20 internal immutable _token1;
    IERC20 internal immutable _token2;
    IERC20 internal immutable _token3;
    IERC20 internal immutable _token4;
    IERC20 internal immutable _token5;
    IERC20 internal immutable _token6;
    IERC20 internal immutable _token7;
    IERC20 internal immutable _token8;
    IERC20 internal immutable _token9;
    IERC20 internal immutable _token10;
    IERC20 internal immutable _token11;
    IERC20 internal immutable _token12;
    IERC20 internal immutable _token13;
    IERC20 internal immutable _token14;
    IERC20 internal immutable _token15;
    IERC20 internal immutable _token16;
    IERC20 internal immutable _token17;
    IERC20 internal immutable _token18;
    IERC20 internal immutable _token19;


    uint256 internal immutable _scalingFactor0;
    uint256 internal immutable _scalingFactor1;
    uint256 internal immutable _scalingFactor2;
    uint256 internal immutable _scalingFactor3;
    uint256 internal immutable _scalingFactor4;
    uint256 internal immutable _scalingFactor5;
    uint256 internal immutable _scalingFactor6;
    uint256 internal immutable _scalingFactor7;
    uint256 internal immutable _scalingFactor8;
    uint256 internal immutable _scalingFactor9;
    uint256 internal immutable _scalingFactor10;
    uint256 internal immutable _scalingFactor11;
    uint256 internal immutable _scalingFactor12;
    uint256 internal immutable _scalingFactor13;
    uint256 internal immutable _scalingFactor14;
    uint256 internal immutable _scalingFactor15;
    uint256 internal immutable _scalingFactor16;
    uint256 internal immutable _scalingFactor17;
    uint256 internal immutable _scalingFactor18;
    uint256 internal immutable _scalingFactor19;

    uint256 internal immutable _maxWeightTokenIndex;

    uint256 internal immutable _normalizedWeight0;
    uint256 internal immutable _normalizedWeight1;
    uint256 internal immutable _normalizedWeight2;
    uint256 internal immutable _normalizedWeight3;
    uint256 internal immutable _normalizedWeight4;
    uint256 internal immutable _normalizedWeight5;
    uint256 internal immutable _normalizedWeight6;
    uint256 internal immutable _normalizedWeight7;
    uint256 internal immutable _normalizedWeight8;
    uint256 internal immutable _normalizedWeight9;
    uint256 internal immutable _normalizedWeight10;
    uint256 internal immutable _normalizedWeight11;
    uint256 internal immutable _normalizedWeight12;
    uint256 internal immutable _normalizedWeight13;
    uint256 internal immutable _normalizedWeight14;
    uint256 internal immutable _normalizedWeight15;
    uint256 internal immutable _normalizedWeight16;
    uint256 internal immutable _normalizedWeight17;
    uint256 internal immutable _normalizedWeight18;
    uint256 internal immutable _normalizedWeight19;

    constructor(
        IVault vault,
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        uint256[] memory normalizedWeights,
        address[] memory assetManagers,
        uint256 swapFeePercentage,
        uint256 pauseWindowDuration,
        uint256 bufferPeriodDuration,
        address owner
    )
        BaseWeightedPool(
            vault,
            name,
            symbol,
            tokens,
            assetManagers,
            swapFeePercentage,
            pauseWindowDuration,
            bufferPeriodDuration,
            owner
        )
    {
        uint256 numTokens = tokens.length;
        InputHelpers.ensureInputLengthMatch(numTokens, normalizedWeights.length);

        _totalTokens = numTokens;

        uint256 normalizedSum = 0;
        uint256 maxWeightTokenIndex = 0;
        uint256 maxNormalizedWeight = 0;
        for (uint8 i = 0; i < numTokens; i++) {
            uint256 normalizedWeight = normalizedWeights[i];
            _require(normalizedWeight >= _MIN_WEIGHT, Errors.MIN_WEIGHT);

            normalizedSum = normalizedSum.add(normalizedWeight);
            if (normalizedWeight > maxNormalizedWeight) {
                maxWeightTokenIndex = i;
                maxNormalizedWeight = normalizedWeight;
            }
        }
        _require(normalizedSum == FixedPoint.ONE, Errors.NORMALIZED_WEIGHT_INVARIANT);

        _maxWeightTokenIndex = maxWeightTokenIndex;

        _normalizedWeight0 = normalizedWeights[0];
        _normalizedWeight1 = normalizedWeights[1];
        _normalizedWeight2 = numTokens > 2 ? normalizedWeights[2] : 0;
        _normalizedWeight3 = numTokens > 3 ? normalizedWeights[3] : 0;
        _normalizedWeight4 = numTokens > 4 ? normalizedWeights[4] : 0;
        _normalizedWeight5 = numTokens > 5 ? normalizedWeights[5] : 0;
        _normalizedWeight6 = numTokens > 6 ? normalizedWeights[6] : 0;
        _normalizedWeight7 = numTokens > 7 ? normalizedWeights[7] : 0;
        _normalizedWeight8 = numTokens > 8 ? normalizedWeights[8] : 0;
        _normalizedWeight9 = numTokens > 9 ? normalizedWeights[9] : 0;
        _normalizedWeight10 = numTokens > 10 ? normalizedWeights[10] : 0;
        _normalizedWeight11 = numTokens > 11 ? normalizedWeights[11] : 0;
        _normalizedWeight12 = numTokens > 12 ? normalizedWeights[12] : 0;
        _normalizedWeight13 = numTokens > 13 ? normalizedWeights[13] : 0;
        _normalizedWeight14 = numTokens > 14 ? normalizedWeights[14] : 0;
        _normalizedWeight15 = numTokens > 15 ? normalizedWeights[15] : 0;
        _normalizedWeight16 = numTokens > 16 ? normalizedWeights[16] : 0;
        _normalizedWeight17 = numTokens > 17 ? normalizedWeights[17] : 0;
        _normalizedWeight18 = numTokens > 18 ? normalizedWeights[18] : 0;
        _normalizedWeight19 = numTokens > 19 ? normalizedWeights[19] : 0;

        _token0 = tokens[0];
        _token1 = tokens[1];
        _token2 = numTokens > 2 ? tokens[2] : IERC20(0);
        _token3 = numTokens > 3 ? tokens[3] : IERC20(0);
        _token4 = numTokens > 4 ? tokens[4] : IERC20(0);
        _token5 = numTokens > 5 ? tokens[5] : IERC20(0);
        _token6 = numTokens > 6 ? tokens[6] : IERC20(0);
        _token7 = numTokens > 7 ? tokens[7] : IERC20(0);
        _token8 = numTokens > 8 ? tokens[8] : IERC20(0);
        _token9 = numTokens > 9 ? tokens[9] : IERC20(0);
        _token10 = numTokens > 10 ? tokens[10] : IERC20(0);
        _token11 = numTokens > 11 ? tokens[11] : IERC20(0);
        _token12 = numTokens > 12 ? tokens[12] : IERC20(0);
        _token13 = numTokens > 13 ? tokens[13] : IERC20(0);
        _token14 = numTokens > 14 ? tokens[14] : IERC20(0);
        _token15 = numTokens > 15 ? tokens[15] : IERC20(0);
        _token16 = numTokens > 16 ? tokens[16] : IERC20(0);
        _token17 = numTokens > 17 ? tokens[17] : IERC20(0);
        _token18 = numTokens > 18 ? tokens[18] : IERC20(0);
        _token19 = numTokens > 19 ? tokens[19] : IERC20(0);

        _scalingFactor0 = _computeScalingFactor(tokens[0]);
        _scalingFactor1 = _computeScalingFactor(tokens[1]);
        _scalingFactor2 = numTokens > 2 ? _computeScalingFactor(tokens[2]) : 0;
        _scalingFactor3 = numTokens > 3 ? _computeScalingFactor(tokens[3]) : 0;
        _scalingFactor4 = numTokens > 4 ? _computeScalingFactor(tokens[4]) : 0;
        _scalingFactor5 = numTokens > 5 ? _computeScalingFactor(tokens[5]) : 0;
        _scalingFactor6 = numTokens > 6 ? _computeScalingFactor(tokens[6]) : 0;
        _scalingFactor7 = numTokens > 7 ? _computeScalingFactor(tokens[7]) : 0;
        _scalingFactor8 = numTokens > 8 ? _computeScalingFactor(tokens[8]) : 0;
        _scalingFactor9 = numTokens > 9 ? _computeScalingFactor(tokens[9]) : 0;
        _scalingFactor10 = numTokens > 10 ? _computeScalingFactor(tokens[10]) : 0;
        _scalingFactor11 = numTokens > 11 ? _computeScalingFactor(tokens[11]) : 0;
        _scalingFactor12 = numTokens > 12 ? _computeScalingFactor(tokens[12]) : 0;
        _scalingFactor13 = numTokens > 13 ? _computeScalingFactor(tokens[13]) : 0;
        _scalingFactor14 = numTokens > 14 ? _computeScalingFactor(tokens[14]) : 0;
        _scalingFactor15 = numTokens > 15 ? _computeScalingFactor(tokens[15]) : 0;
        _scalingFactor16 = numTokens > 16 ? _computeScalingFactor(tokens[16]) : 0;
        _scalingFactor17 = numTokens > 17 ? _computeScalingFactor(tokens[17]) : 0;
        _scalingFactor18 = numTokens > 18 ? _computeScalingFactor(tokens[18]) : 0;
        _scalingFactor19 = numTokens > 19 ? _computeScalingFactor(tokens[19]) : 0;
    }

    function _getNormalizedWeight(IERC20 token) internal view virtual override returns (uint256) {
        if (token == _token0) { return _normalizedWeight0; }
        else if (token == _token1) { return _normalizedWeight1; }
        else if (token == _token2) { return _normalizedWeight2; }
        else if (token == _token3) { return _normalizedWeight3; }
        else if (token == _token4) { return _normalizedWeight4; }
        else if (token == _token5) { return _normalizedWeight5; }
        else if (token == _token6) { return _normalizedWeight6; }
        else if (token == _token7) { return _normalizedWeight7; }
        else if (token == _token8) { return _normalizedWeight8; }
        else if (token == _token9) { return _normalizedWeight9; }
        else if (token == _token10) { return _normalizedWeight10; }
        else if (token == _token11) { return _normalizedWeight11; }
        else if (token == _token12) { return _normalizedWeight12; }
        else if (token == _token13) { return _normalizedWeight13; }
        else if (token == _token14) { return _normalizedWeight14; }
        else if (token == _token15) { return _normalizedWeight15; }
        else if (token == _token16) { return _normalizedWeight16; }
        else if (token == _token17) { return _normalizedWeight17; }
        else if (token == _token18) { return _normalizedWeight18; }
        else if (token == _token19) { return _normalizedWeight19; }
        else {
            _revert(Errors.INVALID_TOKEN);
        }
    }

    function _getNormalizedWeights() internal view virtual override returns (uint256[] memory) {
        uint256 totalTokens = _getTotalTokens();
        uint256[] memory normalizedWeights = new uint256[](totalTokens);

        {
            if (totalTokens > 0) { normalizedWeights[0] = _normalizedWeight0; } else { return normalizedWeights; }
            if (totalTokens > 1) { normalizedWeights[1] = _normalizedWeight1; } else { return normalizedWeights; }
            if (totalTokens > 2) { normalizedWeights[2] = _normalizedWeight2; } else { return normalizedWeights; }
            if (totalTokens > 3) { normalizedWeights[3] = _normalizedWeight3; } else { return normalizedWeights; }
            if (totalTokens > 4) { normalizedWeights[4] = _normalizedWeight4; } else { return normalizedWeights; }
            if (totalTokens > 5) { normalizedWeights[5] = _normalizedWeight5; } else { return normalizedWeights; }
            if (totalTokens > 6) { normalizedWeights[6] = _normalizedWeight6; } else { return normalizedWeights; }
            if (totalTokens > 7) { normalizedWeights[7] = _normalizedWeight7; } else { return normalizedWeights; }
            if (totalTokens > 8) { normalizedWeights[8] = _normalizedWeight8; } else { return normalizedWeights; }
            if (totalTokens > 9) { normalizedWeights[9] = _normalizedWeight9; } else { return normalizedWeights; }
            if (totalTokens > 10) { normalizedWeights[10] = _normalizedWeight10; } else { return normalizedWeights; }
            if (totalTokens > 11) { normalizedWeights[11] = _normalizedWeight11; } else { return normalizedWeights; }
            if (totalTokens > 12) { normalizedWeights[12] = _normalizedWeight12; } else { return normalizedWeights; }
            if (totalTokens > 13) { normalizedWeights[13] = _normalizedWeight13; } else { return normalizedWeights; }
            if (totalTokens > 14) { normalizedWeights[14] = _normalizedWeight14; } else { return normalizedWeights; }
            if (totalTokens > 15) { normalizedWeights[15] = _normalizedWeight15; } else { return normalizedWeights; }
            if (totalTokens > 16) { normalizedWeights[16] = _normalizedWeight16; } else { return normalizedWeights; }
            if (totalTokens > 17) { normalizedWeights[17] = _normalizedWeight17; } else { return normalizedWeights; }
            if (totalTokens > 18) { normalizedWeights[18] = _normalizedWeight18; } else { return normalizedWeights; }
            if (totalTokens > 19) { normalizedWeights[19] = _normalizedWeight19; } else { return normalizedWeights; }
        }

        return normalizedWeights;
    }

    function _getNormalizedWeightsAndMaxWeightIndex()
        internal
        view
        virtual
        override
        returns (uint256[] memory, uint256)
    {
        return (_getNormalizedWeights(), _maxWeightTokenIndex);
    }

    function _getMaxTokens() internal pure virtual override returns (uint256) {
        return _MAX_TOKENS;
    }

    function _getTotalTokens() internal view virtual override returns (uint256) {
        return _totalTokens;
    }

    function _scalingFactor(IERC20 token) internal view virtual override returns (uint256) {
        if (token == _token0) { return _scalingFactor0; }
        else if (token == _token1) { return _scalingFactor1; }
        else if (token == _token2) { return _scalingFactor2; }
        else if (token == _token3) { return _scalingFactor3; }
        else if (token == _token4) { return _scalingFactor4; }
        else if (token == _token5) { return _scalingFactor5; }
        else if (token == _token6) { return _scalingFactor6; }
        else if (token == _token7) { return _scalingFactor7; }
        else if (token == _token8) { return _scalingFactor8; }
        else if (token == _token9) { return _scalingFactor9; }
        else if (token == _token10) { return _scalingFactor10; }
        else if (token == _token11) { return _scalingFactor11; }
        else if (token == _token12) { return _scalingFactor12; }
        else if (token == _token13) { return _scalingFactor13; }
        else if (token == _token14) { return _scalingFactor14; }
        else if (token == _token15) { return _scalingFactor15; }
        else if (token == _token16) { return _scalingFactor16; }
        else if (token == _token17) { return _scalingFactor17; }
        else if (token == _token18) { return _scalingFactor18; }
        else if (token == _token19) { return _scalingFactor19; }
        else {
            _revert(Errors.INVALID_TOKEN);
        }
    }

    function _scalingFactors() internal view virtual override returns (uint256[] memory) {
        uint256 totalTokens = _getTotalTokens();
        uint256[] memory scalingFactors = new uint256[](totalTokens);

        {
            if (totalTokens > 0) { scalingFactors[0] = _scalingFactor0; } else { return scalingFactors; }
            if (totalTokens > 1) { scalingFactors[1] = _scalingFactor1; } else { return scalingFactors; }
            if (totalTokens > 2) { scalingFactors[2] = _scalingFactor2; } else { return scalingFactors; }
            if (totalTokens > 3) { scalingFactors[3] = _scalingFactor3; } else { return scalingFactors; }
            if (totalTokens > 4) { scalingFactors[4] = _scalingFactor4; } else { return scalingFactors; }
            if (totalTokens > 5) { scalingFactors[5] = _scalingFactor5; } else { return scalingFactors; }
            if (totalTokens > 6) { scalingFactors[6] = _scalingFactor6; } else { return scalingFactors; }
            if (totalTokens > 7) { scalingFactors[7] = _scalingFactor7; } else { return scalingFactors; }
            if (totalTokens > 8) { scalingFactors[8] = _scalingFactor8; } else { return scalingFactors; }
            if (totalTokens > 9) { scalingFactors[9] = _scalingFactor9; } else { return scalingFactors; }
            if (totalTokens > 10) { scalingFactors[10] = _scalingFactor10; } else { return scalingFactors; }
            if (totalTokens > 11) { scalingFactors[11] = _scalingFactor11; } else { return scalingFactors; }
            if (totalTokens > 12) { scalingFactors[12] = _scalingFactor12; } else { return scalingFactors; }
            if (totalTokens > 13) { scalingFactors[13] = _scalingFactor13; } else { return scalingFactors; }
            if (totalTokens > 14) { scalingFactors[14] = _scalingFactor14; } else { return scalingFactors; }
            if (totalTokens > 15) { scalingFactors[15] = _scalingFactor15; } else { return scalingFactors; }
            if (totalTokens > 16) { scalingFactors[16] = _scalingFactor16; } else { return scalingFactors; }
            if (totalTokens > 17) { scalingFactors[17] = _scalingFactor17; } else { return scalingFactors; }       
            if (totalTokens > 18) { scalingFactors[18] = _scalingFactor18; } else { return scalingFactors; }
            if (totalTokens > 19) { scalingFactors[19] = _scalingFactor19; } else { return scalingFactors; }       
        }

        return scalingFactors;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


library CodeDeployer {
    bytes32
        private constant _DEPLOYER_CREATION_CODE = 0x602038038060206000396000f3fefefefefefefefefefefefefefefefefefefe;

    function deploy(bytes memory code) internal returns (address destination) {
        bytes32 deployerCreationCode = _DEPLOYER_CREATION_CODE;

        assembly {
            let codeLength := mload(code)

            mstore(code, deployerCreationCode)

            destination := create(0, code, add(codeLength, 32))

            mstore(code, codeLength)
        }

        _require(destination != address(0), Errors.CODE_DEPLOYMENT_FAILED);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


abstract contract BaseSplitCodeFactory {


    address private immutable _creationCodeContractA;
    uint256 private immutable _creationCodeSizeA;

    address private immutable _creationCodeContractB;
    uint256 private immutable _creationCodeSizeB;

    constructor(bytes memory creationCode) {
        uint256 creationCodeSize = creationCode.length;

        uint256 creationCodeSizeA = creationCodeSize / 2;
        _creationCodeSizeA = creationCodeSizeA;

        uint256 creationCodeSizeB = creationCodeSize - creationCodeSizeA;
        _creationCodeSizeB = creationCodeSizeB;




        bytes memory creationCodeA;
        assembly {
            creationCodeA := creationCode
            mstore(creationCodeA, creationCodeSizeA)
        }


        _creationCodeContractA = CodeDeployer.deploy(creationCodeA);


        bytes memory creationCodeB;
        bytes32 lastByteA;

        assembly {
            creationCodeB := add(creationCode, creationCodeSizeA)
            lastByteA := mload(creationCodeB)
            mstore(creationCodeB, creationCodeSizeB)
        }


        _creationCodeContractB = CodeDeployer.deploy(creationCodeB);

        assembly {
            mstore(creationCodeA, creationCodeSize)
            mstore(creationCodeB, lastByteA)
        }
    }

    function getCreationCodeContracts() public view returns (address contractA, address contractB) {
        return (_creationCodeContractA, _creationCodeContractB);
    }

    function getCreationCode() public view returns (bytes memory) {
        return _getCreationCodeWithArgs("");
    }

    function _getCreationCodeWithArgs(bytes memory constructorArgs) private view returns (bytes memory code) {

        address creationCodeContractA = _creationCodeContractA;
        uint256 creationCodeSizeA = _creationCodeSizeA;
        address creationCodeContractB = _creationCodeContractB;
        uint256 creationCodeSizeB = _creationCodeSizeB;

        uint256 creationCodeSize = creationCodeSizeA + creationCodeSizeB;
        uint256 constructorArgsSize = constructorArgs.length;

        uint256 codeSize = creationCodeSize + constructorArgsSize;

        assembly {
            code := mload(0x40)
            mstore(0x40, add(code, add(codeSize, 32)))

            mstore(code, codeSize)

            let dataStart := add(code, 32)
            extcodecopy(creationCodeContractA, dataStart, 0, creationCodeSizeA)
            extcodecopy(creationCodeContractB, add(dataStart, creationCodeSizeA), 0, creationCodeSizeB)
        }

        uint256 constructorArgsDataPtr;
        uint256 constructorArgsCodeDataPtr;
        assembly {
            constructorArgsDataPtr := add(constructorArgs, 32)
            constructorArgsCodeDataPtr := add(add(code, 32), creationCodeSize)
        }

        _memcpy(constructorArgsCodeDataPtr, constructorArgsDataPtr, constructorArgsSize);
    }

    function _create(bytes memory constructorArgs) internal virtual returns (address) {
        bytes memory creationCode = _getCreationCodeWithArgs(constructorArgs);

        address destination;
        assembly {
            destination := create(0, add(creationCode, 32), mload(creationCode))
        }

        if (destination == address(0)) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        return destination;
    }

    function _memcpy(
        uint256 dest,
        uint256 src,
        uint256 len
    ) private pure {
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint256 mask = 256**(32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


abstract contract BasePoolSplitCodeFactory is BaseSplitCodeFactory {
    IVault private immutable _vault;
    mapping(address => bool) private _isPoolFromFactory;

    event PoolCreated(address indexed pool);

    constructor(IVault vault, bytes memory creationCode) BaseSplitCodeFactory(creationCode) {
        _vault = vault;
    }

    function getVault() public view returns (IVault) {
        return _vault;
    }

    function isPoolFromFactory(address pool) external view returns (bool) {
        return _isPoolFromFactory[pool];
    }

    function _create(bytes memory constructorArgs) internal override returns (address) {
        address pool = super._create(constructorArgs);

        _isPoolFromFactory[pool] = true;
        emit PoolCreated(pool);

        return pool;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

contract FactoryWidePauseWindow {

    uint256 private constant _INITIAL_PAUSE_WINDOW_DURATION = 90 days;
    uint256 private constant _BUFFER_PERIOD_DURATION = 30 days;

    uint256 private immutable _poolsPauseWindowEndTime;

    constructor() {
        _poolsPauseWindowEndTime = block.timestamp + _INITIAL_PAUSE_WINDOW_DURATION;
    }

    function getPauseConfiguration() public view returns (uint256 pauseWindowDuration, uint256 bufferPeriodDuration) {
        uint256 currentTime = block.timestamp;
        if (currentTime < _poolsPauseWindowEndTime) {

            pauseWindowDuration = _poolsPauseWindowEndTime - currentTime; // No need for checked arithmetic.
            bufferPeriodDuration = _BUFFER_PERIOD_DURATION;
        } else {

            pauseWindowDuration = 0;
            bufferPeriodDuration = 0;
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;




contract WeightedPoolNoAMFactory is BasePoolSplitCodeFactory, FactoryWidePauseWindow {
    constructor(IVault vault) BasePoolSplitCodeFactory(vault, type(WeightedPool).creationCode) {
    }

    function create(
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        uint256[] memory weights,
        uint256 swapFeePercentage,
        address owner
    ) external returns (address) {
        (uint256 pauseWindowDuration, uint256 bufferPeriodDuration) = getPauseConfiguration();

        return
            _create(
                abi.encode(
                    getVault(),
                    name,
                    symbol,
                    tokens,
                    weights,
                    new address[](tokens.length), // Don't allow asset managers
                    swapFeePercentage,
                    pauseWindowDuration,
                    bufferPeriodDuration,
                    owner
                )
            );
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;




contract WeightedPoolFactory is BasePoolSplitCodeFactory, FactoryWidePauseWindow {
    constructor(IVault vault) BasePoolSplitCodeFactory(vault, type(WeightedPool).creationCode) {
    }

    function create(
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        uint256[] memory weights,
        address[] memory assetManagers,
        uint256 swapFeePercentage,
        address owner
    ) external returns (address) {
        (uint256 pauseWindowDuration, uint256 bufferPeriodDuration) = getPauseConfiguration();

        return
            _create(
                abi.encode(
                    getVault(),
                    name,
                    symbol,
                    tokens,
                    weights,
                    assetManagers,
                    swapFeePercentage,
                    pauseWindowDuration,
                    bufferPeriodDuration,
                    owner
                )
            );
    }
}// MIT


pragma solidity ^0.7.0;


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _enterNonReentrant();
        _;
        _exitNonReentrant();
    }

    function _enterNonReentrant() private {
        _require(_status != _ENTERED, Errors.REENTRANCY);

        _status = _ENTERED;
    }

    function _exitNonReentrant() private {
        _status = _NOT_ENTERED;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


library WeightCompression {
    uint256 private constant _UINT31_MAX = 2**(31) - 1;

    using FixedPoint for uint256;

    function uncompress16(uint256 value) internal pure returns (uint256) {
        return value.mulUp(FixedPoint.ONE).divUp(type(uint16).max);
    }

    function compress16(uint256 value) internal pure returns (uint256) {
        return value.mulUp(type(uint16).max).divUp(FixedPoint.ONE);
    }

    function uncompress31(uint256 value) internal pure returns (uint256) {
        return value.mulUp(FixedPoint.ONE).divUp(_UINT31_MAX);
    }

    function compress31(uint256 value) internal pure returns (uint256) {
        return value.mulUp(_UINT31_MAX).divUp(FixedPoint.ONE);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



contract LiquidityBootstrappingPool is BaseWeightedPool, ReentrancyGuard {

    using FixedPoint for uint256;
    using WordCodec for bytes32;
    using WeightCompression for uint256;

    uint256 private constant _MAX_LBP_TOKENS = 4;


    uint256 private immutable _totalTokens;

    IERC20 internal immutable _token0;
    IERC20 internal immutable _token1;
    IERC20 internal immutable _token2;
    IERC20 internal immutable _token3;


    uint256 internal immutable _scalingFactor0;
    uint256 internal immutable _scalingFactor1;
    uint256 internal immutable _scalingFactor2;
    uint256 internal immutable _scalingFactor3;


    bytes32 private _poolState;

    uint256 private constant _SWAP_ENABLED_OFFSET = 0;
    uint256 private constant _START_WEIGHT_OFFSET = 4;
    uint256 private constant _END_WEIGHT_OFFSET = 128;
    uint256 private constant _START_TIME_OFFSET = 192;
    uint256 private constant _END_TIME_OFFSET = 224;


    event SwapEnabledSet(bool swapEnabled);
    event GradualWeightUpdateScheduled(
        uint256 startTime,
        uint256 endTime,
        uint256[] startWeights,
        uint256[] endWeights
    );

    constructor(
        IVault vault,
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        uint256[] memory normalizedWeights,
        uint256 swapFeePercentage,
        uint256 pauseWindowDuration,
        uint256 bufferPeriodDuration,
        address owner,
        bool swapEnabledOnStart
    )
        BaseWeightedPool(
            vault,
            name,
            symbol,
            tokens,
            new address[](tokens.length), // Pass the zero address: LBPs can't have asset managers
            swapFeePercentage,
            pauseWindowDuration,
            bufferPeriodDuration,
            owner
        )
    {
        uint256 totalTokens = tokens.length;
        InputHelpers.ensureInputLengthMatch(totalTokens, normalizedWeights.length);

        _totalTokens = totalTokens;

        _token0 = tokens[0];
        _token1 = tokens[1];
        _token2 = totalTokens > 2 ? tokens[2] : IERC20(0);
        _token3 = totalTokens > 3 ? tokens[3] : IERC20(0);

        _scalingFactor0 = _computeScalingFactor(tokens[0]);
        _scalingFactor1 = _computeScalingFactor(tokens[1]);
        _scalingFactor2 = totalTokens > 2 ? _computeScalingFactor(tokens[2]) : 0;
        _scalingFactor3 = totalTokens > 3 ? _computeScalingFactor(tokens[3]) : 0;

        uint256 currentTime = block.timestamp;

        _startGradualWeightChange(currentTime, currentTime, normalizedWeights, normalizedWeights);

        _setSwapEnabled(swapEnabledOnStart);
    }


    function getSwapEnabled() public view returns (bool) {
        return _poolState.decodeBool(_SWAP_ENABLED_OFFSET);
    }

    function getGradualWeightUpdateParams()
        external
        view
        returns (
            uint256 startTime,
            uint256 endTime,
            uint256[] memory endWeights
        )
    {
        bytes32 poolState = _poolState;

        startTime = poolState.decodeUint32(_START_TIME_OFFSET);
        endTime = poolState.decodeUint32(_END_TIME_OFFSET);
        uint256 totalTokens = _getTotalTokens();
        endWeights = new uint256[](totalTokens);

        for (uint256 i = 0; i < totalTokens; i++) {
            endWeights[i] = poolState.decodeUint16(_END_WEIGHT_OFFSET + i * 16).uncompress16();
        }
    }

    function setSwapEnabled(bool swapEnabled) external authenticate whenNotPaused nonReentrant {
        _setSwapEnabled(swapEnabled);
    }

    function updateWeightsGradually(
        uint256 startTime,
        uint256 endTime,
        uint256[] memory endWeights
    ) external authenticate whenNotPaused nonReentrant {
        InputHelpers.ensureInputLengthMatch(_getTotalTokens(), endWeights.length);

        uint256 currentTime = block.timestamp;
        startTime = Math.max(currentTime, startTime);

        _require(startTime <= endTime, Errors.GRADUAL_UPDATE_TIME_TRAVEL);

        _startGradualWeightChange(startTime, endTime, _getNormalizedWeights(), endWeights);
    }


    function _getNormalizedWeight(IERC20 token) internal view override returns (uint256) {
        uint256 i;


        if (token == _token0) { i = 0; }
        else if (token == _token1) { i = 1; }
        else if (token == _token2) { i = 2; }
        else if (token == _token3) { i = 3; }
        else {
            _revert(Errors.INVALID_TOKEN);
        }

        return _getNormalizedWeightByIndex(i, _poolState);
    }

    function _getNormalizedWeightByIndex(uint256 i, bytes32 poolState) internal view returns (uint256) {
        uint256 startWeight = poolState.decodeUint31(_START_WEIGHT_OFFSET + i * 31).uncompress31();
        uint256 endWeight = poolState.decodeUint16(_END_WEIGHT_OFFSET + i * 16).uncompress16();

        uint256 pctProgress = _calculateWeightChangeProgress(poolState);

        return _interpolateWeight(startWeight, endWeight, pctProgress);
    }

    function _getNormalizedWeights() internal view override returns (uint256[] memory) {
        uint256 totalTokens = _getTotalTokens();
        uint256[] memory normalizedWeights = new uint256[](totalTokens);

        bytes32 poolState = _poolState;

        {
            normalizedWeights[0] = _getNormalizedWeightByIndex(0, poolState);
            normalizedWeights[1] = _getNormalizedWeightByIndex(1, poolState);
            if (totalTokens == 2) return normalizedWeights;
            normalizedWeights[2] = _getNormalizedWeightByIndex(2, poolState);
            if (totalTokens == 3) return normalizedWeights;
            normalizedWeights[3] = _getNormalizedWeightByIndex(3, poolState);
        }

        return normalizedWeights;
    }

    function _getNormalizedWeightsAndMaxWeightIndex()
        internal
        view
        override
        returns (uint256[] memory normalizedWeights, uint256 maxWeightTokenIndex)
    {
        normalizedWeights = _getNormalizedWeights();

        maxWeightTokenIndex = 0;
        uint256 maxNormalizedWeight = normalizedWeights[0];

        for (uint256 i = 1; i < normalizedWeights.length; i++) {
            if (normalizedWeights[i] > maxNormalizedWeight) {
                maxWeightTokenIndex = i;
                maxNormalizedWeight = normalizedWeights[i];
            }
        }
    }



    function _onInitializePool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory scalingFactors,
        bytes memory userData
    ) internal override returns (uint256, uint256[] memory) {
        _require(sender == getOwner(), Errors.CALLER_IS_NOT_LBP_OWNER);

        return super._onInitializePool(poolId, sender, recipient, scalingFactors, userData);
    }

    function _onJoinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        uint256[] memory scalingFactors,
        bytes memory userData
    )
        internal
        override
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory
        )
    {
        _require(sender == getOwner(), Errors.CALLER_IS_NOT_LBP_OWNER);

        return
            super._onJoinPool(
                poolId,
                sender,
                recipient,
                balances,
                lastChangeBlock,
                protocolSwapFeePercentage,
                scalingFactors,
                userData
            );
    }


    function _onSwapGivenIn(
        SwapRequest memory swapRequest,
        uint256 currentBalanceTokenIn,
        uint256 currentBalanceTokenOut
    ) internal view override returns (uint256) {
        _require(getSwapEnabled(), Errors.SWAPS_DISABLED);

        return super._onSwapGivenIn(swapRequest, currentBalanceTokenIn, currentBalanceTokenOut);
    }

    function _onSwapGivenOut(
        SwapRequest memory swapRequest,
        uint256 currentBalanceTokenIn,
        uint256 currentBalanceTokenOut
    ) internal view override returns (uint256) {
        _require(getSwapEnabled(), Errors.SWAPS_DISABLED);

        return super._onSwapGivenOut(swapRequest, currentBalanceTokenIn, currentBalanceTokenOut);
    }

    function _isOwnerOnlyAction(bytes32 actionId) internal view override returns (bool) {
        return
            (actionId == getActionId(LiquidityBootstrappingPool.setSwapEnabled.selector)) ||
            (actionId == getActionId(LiquidityBootstrappingPool.updateWeightsGradually.selector)) ||
            super._isOwnerOnlyAction(actionId);
    }


    function _calculateWeightChangeProgress(bytes32 poolState) private view returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 startTime = poolState.decodeUint32(_START_TIME_OFFSET);
        uint256 endTime = poolState.decodeUint32(_END_TIME_OFFSET);

        if (currentTime > endTime) {
            return FixedPoint.ONE;
        } else if (currentTime < startTime) {
            return 0;
        }

        uint256 totalSeconds = endTime - startTime;
        uint256 secondsElapsed = currentTime - startTime;

        return totalSeconds == 0 ? FixedPoint.ONE : secondsElapsed.divDown(totalSeconds);
    }

    function _startGradualWeightChange(
        uint256 startTime,
        uint256 endTime,
        uint256[] memory startWeights,
        uint256[] memory endWeights
    ) internal virtual {
        bytes32 newPoolState = _poolState;

        uint256 normalizedSum = 0;
        for (uint256 i = 0; i < endWeights.length; i++) {
            uint256 endWeight = endWeights[i];
            _require(endWeight >= _MIN_WEIGHT, Errors.MIN_WEIGHT);

            newPoolState = newPoolState
                .insertUint31(startWeights[i].compress31(), _START_WEIGHT_OFFSET + i * 31)
                .insertUint16(endWeight.compress16(), _END_WEIGHT_OFFSET + i * 16);

            normalizedSum = normalizedSum.add(endWeight);
        }
        _require(normalizedSum == FixedPoint.ONE, Errors.NORMALIZED_WEIGHT_INVARIANT);

        _poolState = newPoolState.insertUint32(startTime, _START_TIME_OFFSET).insertUint32(endTime, _END_TIME_OFFSET);

        emit GradualWeightUpdateScheduled(startTime, endTime, startWeights, endWeights);
    }

    function _interpolateWeight(
        uint256 startWeight,
        uint256 endWeight,
        uint256 pctProgress
    ) private pure returns (uint256) {
        if (pctProgress == 0 || startWeight == endWeight) return startWeight;
        if (pctProgress >= FixedPoint.ONE) return endWeight;

        if (startWeight > endWeight) {
            uint256 weightDelta = pctProgress.mulDown(startWeight - endWeight);
            return startWeight.sub(weightDelta);
        } else {
            uint256 weightDelta = pctProgress.mulDown(endWeight - startWeight);
            return startWeight.add(weightDelta);
        }
    }

    function _setSwapEnabled(bool swapEnabled) private {
        _poolState = _poolState.insertBool(swapEnabled, _SWAP_ENABLED_OFFSET);
        emit SwapEnabledSet(swapEnabled);
    }

    function _getMaxTokens() internal pure override returns (uint256) {
        return _MAX_LBP_TOKENS;
    }

    function _getTotalTokens() internal view virtual override returns (uint256) {
        return _totalTokens;
    }

    function _scalingFactor(IERC20 token) internal view virtual override returns (uint256) {
        if (token == _token0) { return _scalingFactor0; }
        else if (token == _token1) { return _scalingFactor1; }
        else if (token == _token2) { return _scalingFactor2; }
        else if (token == _token3) { return _scalingFactor3; }
        else {
            _revert(Errors.INVALID_TOKEN);
        }
    }

    function _scalingFactors() internal view virtual override returns (uint256[] memory) {
        uint256 totalTokens = _getTotalTokens();
        uint256[] memory scalingFactors = new uint256[](totalTokens);

        {
            if (totalTokens > 0) { scalingFactors[0] = _scalingFactor0; } else { return scalingFactors; }
            if (totalTokens > 1) { scalingFactors[1] = _scalingFactor1; } else { return scalingFactors; }
            if (totalTokens > 2) { scalingFactors[2] = _scalingFactor2; } else { return scalingFactors; }
            if (totalTokens > 3) { scalingFactors[3] = _scalingFactor3; } else { return scalingFactors; }
        }

        return scalingFactors;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


contract NoProtocolFeeLiquidityBootstrappingPool is LiquidityBootstrappingPool {
    constructor(
        IVault vault,
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        uint256[] memory normalizedWeights,
        uint256 swapFeePercentage,
        uint256 pauseWindowDuration,
        uint256 bufferPeriodDuration,
        address owner,
        bool swapEnabledOnStart
    )
        LiquidityBootstrappingPool(
            vault,
            name,
            symbol,
            tokens,
            normalizedWeights,
            swapFeePercentage,
            pauseWindowDuration,
            bufferPeriodDuration,
            owner,
            swapEnabledOnStart
        )
    {
    }

    function onJoinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256,
        bytes memory userData
    ) public virtual override returns (uint256[] memory, uint256[] memory) {
        return super.onJoinPool(poolId, sender, recipient, balances, lastChangeBlock, 0, userData);
    }

    function onExitPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256,
        bytes memory userData
    ) public virtual override returns (uint256[] memory, uint256[] memory) {
        return super.onExitPool(poolId, sender, recipient, balances, lastChangeBlock, 0, userData);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;





contract NoProtocolFeeLiquidityBootstrappingPoolFactory is
    Authentication,
    BasePoolSplitCodeFactory,
    FactoryWidePauseWindow
{
    bool private _disabled;

    event FactoryDisabled();

    constructor(IVault vault)
        Authentication(bytes32(uint256(address(this))))
        BasePoolSplitCodeFactory(vault, type(NoProtocolFeeLiquidityBootstrappingPool).creationCode)
    {
    }

    function isDisabled() public view returns (bool) {
        return _disabled;
    }

    function disable() external authenticate {
        _disabled = true;
        emit FactoryDisabled();
    }

    function create(
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        uint256[] memory weights,
        uint256 swapFeePercentage,
        address owner,
        bool swapEnabledOnStart
    ) external returns (address) {
        _require(!_disabled, Errors.DISABLED);

        (uint256 pauseWindowDuration, uint256 bufferPeriodDuration) = getPauseConfiguration();

        return
            _create(
                abi.encode(
                    getVault(),
                    name,
                    symbol,
                    tokens,
                    weights,
                    swapFeePercentage,
                    pauseWindowDuration,
                    bufferPeriodDuration,
                    owner,
                    swapEnabledOnStart
                )
            );
    }

    function _canPerform(bytes32 actionId, address user) internal view override returns (bool) {
        return (getVault().getAuthorizer().canPerform(actionId, user, address(this)));
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;




contract LiquidityBootstrappingPoolFactory is BasePoolSplitCodeFactory, FactoryWidePauseWindow {
    constructor(IVault vault) BasePoolSplitCodeFactory(vault, type(LiquidityBootstrappingPool).creationCode) {
    }

    function create(
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        uint256[] memory weights,
        uint256 swapFeePercentage,
        address owner,
        bool swapEnabledOnStart
    ) external returns (address) {
        (uint256 pauseWindowDuration, uint256 bufferPeriodDuration) = getPauseConfiguration();

        return
            _create(
                abi.encode(
                    getVault(),
                    name,
                    symbol,
                    tokens,
                    weights,
                    swapFeePercentage,
                    pauseWindowDuration,
                    bufferPeriodDuration,
                    owner,
                    swapEnabledOnStart
                )
            );
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


abstract contract BasePoolFactory {
    IVault private immutable _vault;
    mapping(address => bool) private _isPoolFromFactory;

    event PoolCreated(address indexed pool);

    constructor(IVault vault) {
        _vault = vault;
    }

    function getVault() public view returns (IVault) {
        return _vault;
    }

    function isPoolFromFactory(address pool) external view returns (bool) {
        return _isPoolFromFactory[pool];
    }

    function _register(address pool) internal {
        _isPoolFromFactory[pool] = true;
        emit PoolCreated(pool);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


library LogCompression {
    int256 private constant _LOG_COMPRESSION_FACTOR = 1e14;
    int256 private constant _HALF_LOG_COMPRESSION_FACTOR = 0.5e14;

    function toLowResLog(uint256 value) internal pure returns (int256) {
        int256 ln = LogExpMath.ln(int256(value));

        int256 lnWithError = (ln > 0 ? ln + _HALF_LOG_COMPRESSION_FACTOR : ln - _HALF_LOG_COMPRESSION_FACTOR);
        return lnWithError / _LOG_COMPRESSION_FACTOR;
    }

    function fromLowResLog(int256 value) internal pure returns (uint256) {
        return uint256(LogExpMath.exp(value * _LOG_COMPRESSION_FACTOR));
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface IPriceOracle {
    enum Variable { PAIR_PRICE, BPT_PRICE, INVARIANT }

    function getTimeWeightedAverage(OracleAverageQuery[] memory queries)
        external
        view
        returns (uint256[] memory results);

    function getLatest(Variable variable) external view returns (uint256);

    struct OracleAverageQuery {
        Variable variable;
        uint256 secs;
        uint256 ago;
    }

    function getLargestSafeQueryWindow() external view returns (uint256);

    function getPastAccumulators(OracleAccumulatorQuery[] memory queries)
        external
        view
        returns (int256[] memory results);

    struct OracleAccumulatorQuery {
        Variable variable;
        uint256 ago;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface IPoolPriceOracle {
    function getSample(uint256 index)
        external
        view
        returns (
            int256 logPairPrice,
            int256 accLogPairPrice,
            int256 logBptPrice,
            int256 accLogBptPrice,
            int256 logInvariant,
            int256 accLogInvariant,
            uint256 timestamp
        );

    function getTotalSamples() external view returns (uint256);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

library Buffer {
    uint256 internal constant SIZE = 1024;

    function prev(uint256 index) internal pure returns (uint256) {
        return sub(index, 1);
    }

    function next(uint256 index) internal pure returns (uint256) {
        return add(index, 1);
    }

    function add(uint256 index, uint256 offset) internal pure returns (uint256) {
        return (index + offset) % SIZE;
    }

    function sub(uint256 index, uint256 offset) internal pure returns (uint256) {
        return (index + SIZE - offset) % SIZE;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



library Samples {
    using WordCodec for int256;
    using WordCodec for uint256;
    using WordCodec for bytes32;

    uint256 internal constant _TIMESTAMP_OFFSET = 0;
    uint256 internal constant _ACC_LOG_INVARIANT_OFFSET = 31;
    uint256 internal constant _INST_LOG_INVARIANT_OFFSET = 84;
    uint256 internal constant _ACC_LOG_BPT_PRICE_OFFSET = 106;
    uint256 internal constant _INST_LOG_BPT_PRICE_OFFSET = 159;
    uint256 internal constant _ACC_LOG_PAIR_PRICE_OFFSET = 181;
    uint256 internal constant _INST_LOG_PAIR_PRICE_OFFSET = 234;

    function update(
        bytes32 sample,
        int256 instLogPairPrice,
        int256 instLogBptPrice,
        int256 instLogInvariant,
        uint256 currentTimestamp
    ) internal pure returns (bytes32) {

        int256 elapsed = int256(currentTimestamp - timestamp(sample));
        int256 accLogPairPrice = _accLogPairPrice(sample) + instLogPairPrice * elapsed;
        int256 accLogBptPrice = _accLogBptPrice(sample) + instLogBptPrice * elapsed;
        int256 accLogInvariant = _accLogInvariant(sample) + instLogInvariant * elapsed;

        return
            pack(
                instLogPairPrice,
                accLogPairPrice,
                instLogBptPrice,
                accLogBptPrice,
                instLogInvariant,
                accLogInvariant,
                currentTimestamp
            );
    }

    function instant(bytes32 sample, IPriceOracle.Variable variable) internal pure returns (int256) {
        if (variable == IPriceOracle.Variable.PAIR_PRICE) {
            return _instLogPairPrice(sample);
        } else if (variable == IPriceOracle.Variable.BPT_PRICE) {
            return _instLogBptPrice(sample);
        } else {
            return _instLogInvariant(sample);
        }
    }

    function accumulator(bytes32 sample, IPriceOracle.Variable variable) internal pure returns (int256) {
        if (variable == IPriceOracle.Variable.PAIR_PRICE) {
            return _accLogPairPrice(sample);
        } else if (variable == IPriceOracle.Variable.BPT_PRICE) {
            return _accLogBptPrice(sample);
        } else {
            return _accLogInvariant(sample);
        }
    }

    function timestamp(bytes32 sample) internal pure returns (uint256) {
        return sample.decodeUint31(_TIMESTAMP_OFFSET);
    }

    function _instLogPairPrice(bytes32 sample) private pure returns (int256) {
        return sample.decodeInt22(_INST_LOG_PAIR_PRICE_OFFSET);
    }

    function _accLogPairPrice(bytes32 sample) private pure returns (int256) {
        return sample.decodeInt53(_ACC_LOG_PAIR_PRICE_OFFSET);
    }

    function _instLogBptPrice(bytes32 sample) private pure returns (int256) {
        return sample.decodeInt22(_INST_LOG_BPT_PRICE_OFFSET);
    }

    function _accLogBptPrice(bytes32 sample) private pure returns (int256) {
        return sample.decodeInt53(_ACC_LOG_BPT_PRICE_OFFSET);
    }

    function _instLogInvariant(bytes32 sample) private pure returns (int256) {
        return sample.decodeInt22(_INST_LOG_INVARIANT_OFFSET);
    }

    function _accLogInvariant(bytes32 sample) private pure returns (int256) {
        return sample.decodeInt53(_ACC_LOG_INVARIANT_OFFSET);
    }

    function pack(
        int256 instLogPairPrice,
        int256 accLogPairPrice,
        int256 instLogBptPrice,
        int256 accLogBptPrice,
        int256 instLogInvariant,
        int256 accLogInvariant,
        uint256 _timestamp
    ) internal pure returns (bytes32) {
        return
            instLogPairPrice.encodeInt22(_INST_LOG_PAIR_PRICE_OFFSET) |
            accLogPairPrice.encodeInt53(_ACC_LOG_PAIR_PRICE_OFFSET) |
            instLogBptPrice.encodeInt22(_INST_LOG_BPT_PRICE_OFFSET) |
            accLogBptPrice.encodeInt53(_ACC_LOG_BPT_PRICE_OFFSET) |
            instLogInvariant.encodeInt22(_INST_LOG_INVARIANT_OFFSET) |
            accLogInvariant.encodeInt53(_ACC_LOG_INVARIANT_OFFSET) |
            _timestamp.encodeUint(_TIMESTAMP_OFFSET); // Using 31 bits
    }

    function unpack(bytes32 sample)
        internal
        pure
        returns (
            int256 logPairPrice,
            int256 accLogPairPrice,
            int256 logBptPrice,
            int256 accLogBptPrice,
            int256 logInvariant,
            int256 accLogInvariant,
            uint256 _timestamp
        )
    {
        logPairPrice = _instLogPairPrice(sample);
        accLogPairPrice = _accLogPairPrice(sample);
        logBptPrice = _instLogBptPrice(sample);
        accLogBptPrice = _accLogBptPrice(sample);
        logInvariant = _instLogInvariant(sample);
        accLogInvariant = _accLogInvariant(sample);
        _timestamp = timestamp(sample);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;




contract PoolPriceOracle is IPoolPriceOracle {
    using Buffer for uint256;
    using Samples for bytes32;

    uint256 private constant _MAX_SAMPLE_DURATION = 2 minutes;

    mapping(uint256 => bytes32) internal _samples;

    function getSample(uint256 index)
        external
        view
        override
        returns (
            int256 logPairPrice,
            int256 accLogPairPrice,
            int256 logBptPrice,
            int256 accLogBptPrice,
            int256 logInvariant,
            int256 accLogInvariant,
            uint256 timestamp
        )
    {
        _require(index < Buffer.SIZE, Errors.ORACLE_INVALID_INDEX);

        bytes32 sample = _getSample(index);
        return sample.unpack();
    }

    function getTotalSamples() external pure override returns (uint256) {
        return Buffer.SIZE;
    }

    function _processPriceData(
        uint256 latestSampleCreationTimestamp,
        uint256 latestIndex,
        int256 logPairPrice,
        int256 logBptPrice,
        int256 logInvariant
    ) internal returns (uint256) {
        bytes32 sample = _getSample(latestIndex).update(logPairPrice, logBptPrice, logInvariant, block.timestamp);

        bool newSample = block.timestamp - latestSampleCreationTimestamp >= _MAX_SAMPLE_DURATION;
        latestIndex = newSample ? latestIndex.next() : latestIndex;

        _samples[latestIndex] = sample;

        return latestIndex;
    }

    function _getInstantValue(IPriceOracle.Variable variable, uint256 index) internal view returns (int256) {
        bytes32 sample = _getSample(index);
        _require(sample.timestamp() > 0, Errors.ORACLE_NOT_INITIALIZED);

        return sample.instant(variable);
    }

    function _getPastAccumulator(
        IPriceOracle.Variable variable,
        uint256 latestIndex,
        uint256 ago
    ) internal view returns (int256) {
        _require(block.timestamp >= ago, Errors.ORACLE_INVALID_SECONDS_QUERY);
        uint256 lookUpTime = block.timestamp - ago;

        bytes32 latestSample = _getSample(latestIndex);
        uint256 latestTimestamp = latestSample.timestamp();

        _require(latestTimestamp > 0, Errors.ORACLE_NOT_INITIALIZED);

        if (latestTimestamp <= lookUpTime) {

            uint256 elapsed = lookUpTime - latestTimestamp;
            return latestSample.accumulator(variable) + (latestSample.instant(variable) * int256(elapsed));
        } else {

            uint256 oldestIndex = latestIndex.next();
            {
                bytes32 oldestSample = _getSample(oldestIndex);
                uint256 oldestTimestamp = oldestSample.timestamp();

                _require(oldestTimestamp > 0, Errors.ORACLE_NOT_INITIALIZED);
                _require(oldestTimestamp <= lookUpTime, Errors.ORACLE_QUERY_TOO_OLD);
            }

            (bytes32 prev, bytes32 next) = _findNearestSample(lookUpTime, oldestIndex);

            uint256 samplesTimeDiff = next.timestamp() - prev.timestamp();

            if (samplesTimeDiff > 0) {

                int256 samplesAccDiff = next.accumulator(variable) - prev.accumulator(variable);
                uint256 elapsed = lookUpTime - prev.timestamp();
                return prev.accumulator(variable) + ((samplesAccDiff * int256(elapsed)) / int256(samplesTimeDiff));
            } else {
                return prev.accumulator(variable);
            }
        }
    }

    function _findNearestSample(uint256 lookUpDate, uint256 offset) internal view returns (bytes32 prev, bytes32 next) {

        uint256 low = 0;
        uint256 high = Buffer.SIZE - 1;
        uint256 mid;

        bytes32 sample;
        uint256 sampleTimestamp;

        while (low <= high) {
            uint256 midWithoutOffset = (high + low) / 2;

            mid = midWithoutOffset.add(offset);
            sample = _getSample(mid);
            sampleTimestamp = sample.timestamp();

            if (sampleTimestamp < lookUpDate) {
                low = midWithoutOffset + 1;
            } else if (sampleTimestamp > lookUpDate) {

                high = midWithoutOffset - 1;
            } else {
                return (sample, sample);
            }
        }

        return sampleTimestamp < lookUpDate ? (sample, _getSample(mid.next())) : (_getSample(mid.prev()), sample);
    }

    function _getSample(uint256 index) internal view returns (bytes32) {
        return _samples[index];
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


contract WeightedOracleMath {
    using FixedPoint for uint256;

    function _calcLogSpotPrice(
        uint256 normalizedWeightA,
        uint256 balanceA,
        uint256 normalizedWeightB,
        uint256 balanceB
    ) internal pure returns (int256) {

        uint256 spotPrice = balanceA.divUp(normalizedWeightA).divUp(balanceB.divUp(normalizedWeightB));
        return LogCompression.toLowResLog(spotPrice);
    }

    function _calcLogBPTPrice(
        uint256 normalizedWeight,
        uint256 balance,
        int256 logBptTotalSupply
    ) internal pure returns (int256) {

        uint256 balanceOverWeight = balance.divUp(normalizedWeight);
        int256 logBalanceOverWeight = LogCompression.toLowResLog(balanceOverWeight);

        return logBalanceOverWeight - logBptTotalSupply;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


library WeightedPool2TokensMiscData {
    using WordCodec for bytes32;
    using WordCodec for uint256;

    uint256 private constant _LOG_INVARIANT_OFFSET = 0;
    uint256 private constant _LOG_TOTAL_SUPPLY_OFFSET = 22;
    uint256 private constant _ORACLE_SAMPLE_CREATION_TIMESTAMP_OFFSET = 44;
    uint256 private constant _ORACLE_INDEX_OFFSET = 75;
    uint256 private constant _ORACLE_ENABLED_OFFSET = 85;
    uint256 private constant _SWAP_FEE_PERCENTAGE_OFFSET = 86;

    function logInvariant(bytes32 data) internal pure returns (int256) {
        return data.decodeInt22(_LOG_INVARIANT_OFFSET);
    }

    function logTotalSupply(bytes32 data) internal pure returns (int256) {
        return data.decodeInt22(_LOG_TOTAL_SUPPLY_OFFSET);
    }

    function oracleSampleCreationTimestamp(bytes32 data) internal pure returns (uint256) {
        return data.decodeUint31(_ORACLE_SAMPLE_CREATION_TIMESTAMP_OFFSET);
    }

    function oracleIndex(bytes32 data) internal pure returns (uint256) {
        return data.decodeUint10(_ORACLE_INDEX_OFFSET);
    }

    function oracleEnabled(bytes32 data) internal pure returns (bool) {
        return data.decodeBool(_ORACLE_ENABLED_OFFSET);
    }

    function swapFeePercentage(bytes32 data) internal pure returns (uint256) {
        return data.decodeUint64(_SWAP_FEE_PERCENTAGE_OFFSET);
    }

    function setLogInvariant(bytes32 data, int256 _logInvariant) internal pure returns (bytes32) {
        return data.insertInt22(_logInvariant, _LOG_INVARIANT_OFFSET);
    }

    function setLogTotalSupply(bytes32 data, int256 _logTotalSupply) internal pure returns (bytes32) {
        return data.insertInt22(_logTotalSupply, _LOG_TOTAL_SUPPLY_OFFSET);
    }

    function setOracleSampleCreationTimestamp(bytes32 data, uint256 _initialTimestamp) internal pure returns (bytes32) {
        return data.insertUint31(_initialTimestamp, _ORACLE_SAMPLE_CREATION_TIMESTAMP_OFFSET);
    }

    function setOracleIndex(bytes32 data, uint256 _oracleIndex) internal pure returns (bytes32) {
        return data.insertUint10(_oracleIndex, _ORACLE_INDEX_OFFSET);
    }

    function setOracleEnabled(bytes32 data, bool _oracleEnabled) internal pure returns (bytes32) {
        return data.insertBool(_oracleEnabled, _ORACLE_ENABLED_OFFSET);
    }

    function setSwapFeePercentage(bytes32 data, uint256 _swapFeePercentage) internal pure returns (bytes32) {
        return data.insertUint64(_swapFeePercentage, _SWAP_FEE_PERCENTAGE_OFFSET);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;





contract WeightedPool2Tokens is
    IMinimalSwapInfoPool,
    IPriceOracle,
    BasePoolAuthorization,
    BalancerPoolToken,
    TemporarilyPausable,
    PoolPriceOracle,
    WeightedMath,
    WeightedOracleMath
{
    using FixedPoint for uint256;
    using WeightedPoolUserDataHelpers for bytes;
    using WeightedPool2TokensMiscData for bytes32;

    uint256 private constant _MINIMUM_BPT = 1e6;

    uint256 private constant _MIN_SWAP_FEE_PERCENTAGE = 1e12; // 0.0001%
    uint256 private constant _MAX_SWAP_FEE_PERCENTAGE = 1e17; // 10%

    bytes32 internal _miscData;
    uint256 private _lastInvariant;

    IVault private immutable _vault;
    bytes32 private immutable _poolId;

    IERC20 internal immutable _token0;
    IERC20 internal immutable _token1;

    uint256 private immutable _normalizedWeight0;
    uint256 private immutable _normalizedWeight1;

    uint256 private immutable _maxWeightTokenIndex;

    uint256 internal immutable _scalingFactor0;
    uint256 internal immutable _scalingFactor1;

    event OracleEnabledChanged(bool enabled);
    event SwapFeePercentageChanged(uint256 swapFeePercentage);

    modifier onlyVault(bytes32 poolId) {
        _require(msg.sender == address(getVault()), Errors.CALLER_NOT_VAULT);
        _require(poolId == getPoolId(), Errors.INVALID_POOL_ID);
        _;
    }

    struct NewPoolParams {
        IVault vault;
        string name;
        string symbol;
        IERC20 token0;
        IERC20 token1;
        uint256 normalizedWeight0;
        uint256 normalizedWeight1;
        uint256 swapFeePercentage;
        uint256 pauseWindowDuration;
        uint256 bufferPeriodDuration;
        bool oracleEnabled;
        address owner;
    }

    constructor(NewPoolParams memory params)
        Authentication(bytes32(uint256(msg.sender)))
        BalancerPoolToken(params.name, params.symbol)
        BasePoolAuthorization(params.owner)
        TemporarilyPausable(params.pauseWindowDuration, params.bufferPeriodDuration)
    {
        _setOracleEnabled(params.oracleEnabled);
        _setSwapFeePercentage(params.swapFeePercentage);

        bytes32 poolId = params.vault.registerPool(IVault.PoolSpecialization.TWO_TOKEN);

        IERC20[] memory tokens = new IERC20[](2);
        tokens[0] = params.token0;
        tokens[1] = params.token1;
        params.vault.registerTokens(poolId, tokens, new address[](2));

        _vault = params.vault;
        _poolId = poolId;

        _token0 = params.token0;
        _token1 = params.token1;

        _scalingFactor0 = _computeScalingFactor(params.token0);
        _scalingFactor1 = _computeScalingFactor(params.token1);

        _require(params.normalizedWeight0 >= _MIN_WEIGHT, Errors.MIN_WEIGHT);
        _require(params.normalizedWeight1 >= _MIN_WEIGHT, Errors.MIN_WEIGHT);

        uint256 normalizedSum = params.normalizedWeight0.add(params.normalizedWeight1);
        _require(normalizedSum == FixedPoint.ONE, Errors.NORMALIZED_WEIGHT_INVARIANT);

        _normalizedWeight0 = params.normalizedWeight0;
        _normalizedWeight1 = params.normalizedWeight1;
        _maxWeightTokenIndex = params.normalizedWeight0 >= params.normalizedWeight1 ? 0 : 1;
    }


    function getVault() public view returns (IVault) {
        return _vault;
    }

    function getPoolId() public view override returns (bytes32) {
        return _poolId;
    }

    function getMiscData()
        external
        view
        returns (
            int256 logInvariant,
            int256 logTotalSupply,
            uint256 oracleSampleCreationTimestamp,
            uint256 oracleIndex,
            bool oracleEnabled,
            uint256 swapFeePercentage
        )
    {
        bytes32 miscData = _miscData;
        logInvariant = miscData.logInvariant();
        logTotalSupply = miscData.logTotalSupply();
        oracleSampleCreationTimestamp = miscData.oracleSampleCreationTimestamp();
        oracleIndex = miscData.oracleIndex();
        oracleEnabled = miscData.oracleEnabled();
        swapFeePercentage = miscData.swapFeePercentage();
    }

    function getSwapFeePercentage() public view returns (uint256) {
        return _miscData.swapFeePercentage();
    }

    function setSwapFeePercentage(uint256 swapFeePercentage) public virtual authenticate whenNotPaused {
        _setSwapFeePercentage(swapFeePercentage);
    }

    function _setSwapFeePercentage(uint256 swapFeePercentage) private {
        _require(swapFeePercentage >= _MIN_SWAP_FEE_PERCENTAGE, Errors.MIN_SWAP_FEE_PERCENTAGE);
        _require(swapFeePercentage <= _MAX_SWAP_FEE_PERCENTAGE, Errors.MAX_SWAP_FEE_PERCENTAGE);

        _miscData = _miscData.setSwapFeePercentage(swapFeePercentage);
        emit SwapFeePercentageChanged(swapFeePercentage);
    }

    function _isOwnerOnlyAction(bytes32 actionId) internal view virtual override returns (bool) {
        return
            (actionId == getActionId(BasePool.setSwapFeePercentage.selector)) ||
            (actionId == getActionId(BasePool.setAssetManagerPoolConfig.selector));
    }

    function enableOracle() external whenNotPaused authenticate {
        _setOracleEnabled(true);

        if (totalSupply() > 0) {
            _cacheInvariantAndSupply();
        }
    }

    function _setOracleEnabled(bool enabled) internal {
        _miscData = _miscData.setOracleEnabled(enabled);
        emit OracleEnabledChanged(enabled);
    }

    function setPaused(bool paused) external authenticate {
        _setPaused(paused);
    }

    function getNormalizedWeights() external view returns (uint256[] memory) {
        return _normalizedWeights();
    }

    function _normalizedWeights() internal view virtual returns (uint256[] memory) {
        uint256[] memory normalizedWeights = new uint256[](2);
        normalizedWeights[0] = _normalizedWeights(true);
        normalizedWeights[1] = _normalizedWeights(false);
        return normalizedWeights;
    }

    function _normalizedWeights(bool token0) internal view virtual returns (uint256) {
        return token0 ? _normalizedWeight0 : _normalizedWeight1;
    }

    function getLastInvariant() external view returns (uint256) {
        return _lastInvariant;
    }

    function getInvariant() public view returns (uint256) {
        (, uint256[] memory balances, ) = getVault().getPoolTokens(getPoolId());

        _upscaleArray(balances);

        uint256[] memory normalizedWeights = _normalizedWeights();
        return WeightedMath._calculateInvariant(normalizedWeights, balances);
    }


    function onSwap(
        SwapRequest memory request,
        uint256 balanceTokenIn,
        uint256 balanceTokenOut
    ) public virtual override whenNotPaused onlyVault(request.poolId) returns (uint256) {
        bool tokenInIsToken0 = request.tokenIn == _token0;

        uint256 scalingFactorTokenIn = _scalingFactor(tokenInIsToken0);
        uint256 scalingFactorTokenOut = _scalingFactor(!tokenInIsToken0);

        uint256 normalizedWeightIn = _normalizedWeights(tokenInIsToken0);
        uint256 normalizedWeightOut = _normalizedWeights(!tokenInIsToken0);

        balanceTokenIn = _upscale(balanceTokenIn, scalingFactorTokenIn);
        balanceTokenOut = _upscale(balanceTokenOut, scalingFactorTokenOut);

        _updateOracle(
            request.lastChangeBlock,
            tokenInIsToken0 ? balanceTokenIn : balanceTokenOut,
            tokenInIsToken0 ? balanceTokenOut : balanceTokenIn
        );

        if (request.kind == IVault.SwapKind.GIVEN_IN) {
            uint256 feeAmount = request.amount.mulUp(getSwapFeePercentage());
            request.amount = _upscale(request.amount.sub(feeAmount), scalingFactorTokenIn);

            uint256 amountOut = _onSwapGivenIn(
                request,
                balanceTokenIn,
                balanceTokenOut,
                normalizedWeightIn,
                normalizedWeightOut
            );

            return _downscaleDown(amountOut, scalingFactorTokenOut);
        } else {
            request.amount = _upscale(request.amount, scalingFactorTokenOut);

            uint256 amountIn = _onSwapGivenOut(
                request,
                balanceTokenIn,
                balanceTokenOut,
                normalizedWeightIn,
                normalizedWeightOut
            );

            amountIn = _downscaleUp(amountIn, scalingFactorTokenIn);

            return amountIn.divUp(getSwapFeePercentage().complement());
        }
    }

    function _onSwapGivenIn(
        SwapRequest memory swapRequest,
        uint256 currentBalanceTokenIn,
        uint256 currentBalanceTokenOut,
        uint256 normalizedWeightIn,
        uint256 normalizedWeightOut
    ) private pure returns (uint256) {
        return
            WeightedMath._calcOutGivenIn(
                currentBalanceTokenIn,
                normalizedWeightIn,
                currentBalanceTokenOut,
                normalizedWeightOut,
                swapRequest.amount
            );
    }

    function _onSwapGivenOut(
        SwapRequest memory swapRequest,
        uint256 currentBalanceTokenIn,
        uint256 currentBalanceTokenOut,
        uint256 normalizedWeightIn,
        uint256 normalizedWeightOut
    ) private pure returns (uint256) {
        return
            WeightedMath._calcInGivenOut(
                currentBalanceTokenIn,
                normalizedWeightIn,
                currentBalanceTokenOut,
                normalizedWeightOut,
                swapRequest.amount
            );
    }


    function onJoinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    )
        public
        virtual
        override
        onlyVault(poolId)
        whenNotPaused
        returns (uint256[] memory amountsIn, uint256[] memory dueProtocolFeeAmounts)
    {

        uint256 bptAmountOut;
        if (totalSupply() == 0) {
            (bptAmountOut, amountsIn) = _onInitializePool(poolId, sender, recipient, userData);

            _require(bptAmountOut >= _MINIMUM_BPT, Errors.MINIMUM_BPT);
            _mintPoolTokens(address(0), _MINIMUM_BPT);
            _mintPoolTokens(recipient, bptAmountOut - _MINIMUM_BPT);

            _downscaleUpArray(amountsIn);

            dueProtocolFeeAmounts = new uint256[](2);
        } else {
            _upscaleArray(balances);

            _updateOracle(lastChangeBlock, balances[0], balances[1]);

            (bptAmountOut, amountsIn, dueProtocolFeeAmounts) = _onJoinPool(
                poolId,
                sender,
                recipient,
                balances,
                lastChangeBlock,
                protocolSwapFeePercentage,
                userData
            );


            _mintPoolTokens(recipient, bptAmountOut);

            _downscaleUpArray(amountsIn);
            _downscaleDownArray(dueProtocolFeeAmounts);
        }

        _cacheInvariantAndSupply();
    }

    function _onInitializePool(
        bytes32,
        address,
        address,
        bytes memory userData
    ) private returns (uint256, uint256[] memory) {
        BaseWeightedPool.JoinKind kind = userData.joinKind();
        _require(kind == BaseWeightedPool.JoinKind.INIT, Errors.UNINITIALIZED);

        uint256[] memory amountsIn = userData.initialAmountsIn();
        InputHelpers.ensureInputLengthMatch(amountsIn.length, 2);
        _upscaleArray(amountsIn);

        uint256[] memory normalizedWeights = _normalizedWeights();

        uint256 invariantAfterJoin = WeightedMath._calculateInvariant(normalizedWeights, amountsIn);

        uint256 bptAmountOut = Math.mul(invariantAfterJoin, 2);

        _lastInvariant = invariantAfterJoin;

        return (bptAmountOut, amountsIn);
    }

    function _onJoinPool(
        bytes32,
        address,
        address,
        uint256[] memory balances,
        uint256,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    )
        private
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory
        )
    {
        uint256[] memory normalizedWeights = _normalizedWeights();

        uint256 invariantBeforeJoin = WeightedMath._calculateInvariant(normalizedWeights, balances);

        uint256[] memory dueProtocolFeeAmounts = _getDueProtocolFeeAmounts(
            balances,
            normalizedWeights,
            _lastInvariant,
            invariantBeforeJoin,
            protocolSwapFeePercentage
        );

        _mutateAmounts(balances, dueProtocolFeeAmounts, FixedPoint.sub);
        (uint256 bptAmountOut, uint256[] memory amountsIn) = _doJoin(balances, normalizedWeights, userData);

        _mutateAmounts(balances, amountsIn, FixedPoint.add);
        _lastInvariant = WeightedMath._calculateInvariant(normalizedWeights, balances);

        return (bptAmountOut, amountsIn, dueProtocolFeeAmounts);
    }

    function _doJoin(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        bytes memory userData
    ) private view returns (uint256, uint256[] memory) {
        BaseWeightedPool.JoinKind kind = userData.joinKind();

        if (kind == BaseWeightedPool.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT) {
            return _joinExactTokensInForBPTOut(balances, normalizedWeights, userData);
        } else if (kind == BaseWeightedPool.JoinKind.TOKEN_IN_FOR_EXACT_BPT_OUT) {
            return _joinTokenInForExactBPTOut(balances, normalizedWeights, userData);
        } else {
            _revert(Errors.UNHANDLED_JOIN_KIND);
        }
    }

    function _joinExactTokensInForBPTOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        bytes memory userData
    ) private view returns (uint256, uint256[] memory) {
        (uint256[] memory amountsIn, uint256 minBPTAmountOut) = userData.exactTokensInForBptOut();
        InputHelpers.ensureInputLengthMatch(amountsIn.length, 2);

        _upscaleArray(amountsIn);

        uint256 bptAmountOut = WeightedMath._calcBptOutGivenExactTokensIn(
            balances,
            normalizedWeights,
            amountsIn,
            totalSupply(),
            getSwapFeePercentage()
        );

        _require(bptAmountOut >= minBPTAmountOut, Errors.BPT_OUT_MIN_AMOUNT);

        return (bptAmountOut, amountsIn);
    }

    function _joinTokenInForExactBPTOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        bytes memory userData
    ) private view returns (uint256, uint256[] memory) {
        (uint256 bptAmountOut, uint256 tokenIndex) = userData.tokenInForExactBptOut();

        _require(tokenIndex < 2, Errors.OUT_OF_BOUNDS);

        uint256[] memory amountsIn = new uint256[](2);
        amountsIn[tokenIndex] = WeightedMath._calcTokenInGivenExactBptOut(
            balances[tokenIndex],
            normalizedWeights[tokenIndex],
            bptAmountOut,
            totalSupply(),
            getSwapFeePercentage()
        );

        return (bptAmountOut, amountsIn);
    }


    function onExitPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) public virtual override onlyVault(poolId) returns (uint256[] memory, uint256[] memory) {
        _upscaleArray(balances);

        (uint256 bptAmountIn, uint256[] memory amountsOut, uint256[] memory dueProtocolFeeAmounts) = _onExitPool(
            poolId,
            sender,
            recipient,
            balances,
            lastChangeBlock,
            protocolSwapFeePercentage,
            userData
        );


        _burnPoolTokens(sender, bptAmountIn);

        _downscaleDownArray(amountsOut);
        _downscaleDownArray(dueProtocolFeeAmounts);

        if (_isNotPaused()) {
            _cacheInvariantAndSupply();
        }

        return (amountsOut, dueProtocolFeeAmounts);
    }

    function _onExitPool(
        bytes32,
        address,
        address,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    )
        private
        returns (
            uint256 bptAmountIn,
            uint256[] memory amountsOut,
            uint256[] memory dueProtocolFeeAmounts
        )
    {

        uint256[] memory normalizedWeights = _normalizedWeights();

        if (_isNotPaused()) {
            _updateOracle(lastChangeBlock, balances[0], balances[1]);

            uint256 invariantBeforeExit = WeightedMath._calculateInvariant(normalizedWeights, balances);
            dueProtocolFeeAmounts = _getDueProtocolFeeAmounts(
                balances,
                normalizedWeights,
                _lastInvariant,
                invariantBeforeExit,
                protocolSwapFeePercentage
            );

            _mutateAmounts(balances, dueProtocolFeeAmounts, FixedPoint.sub);
        } else {
            dueProtocolFeeAmounts = new uint256[](2);
        }

        (bptAmountIn, amountsOut) = _doExit(balances, normalizedWeights, userData);

        _mutateAmounts(balances, amountsOut, FixedPoint.sub);
        _lastInvariant = WeightedMath._calculateInvariant(normalizedWeights, balances);

        return (bptAmountIn, amountsOut, dueProtocolFeeAmounts);
    }

    function _doExit(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        bytes memory userData
    ) private view returns (uint256, uint256[] memory) {
        BaseWeightedPool.ExitKind kind = userData.exitKind();

        if (kind == BaseWeightedPool.ExitKind.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT) {
            return _exitExactBPTInForTokenOut(balances, normalizedWeights, userData);
        } else if (kind == BaseWeightedPool.ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT) {
            return _exitExactBPTInForTokensOut(balances, userData);
        } else {
            return _exitBPTInForExactTokensOut(balances, normalizedWeights, userData);
        }
    }

    function _exitExactBPTInForTokenOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        bytes memory userData
    ) private view whenNotPaused returns (uint256, uint256[] memory) {

        (uint256 bptAmountIn, uint256 tokenIndex) = userData.exactBptInForTokenOut();

        _require(tokenIndex < 2, Errors.OUT_OF_BOUNDS);

        uint256[] memory amountsOut = new uint256[](2);

        amountsOut[tokenIndex] = WeightedMath._calcTokenOutGivenExactBptIn(
            balances[tokenIndex],
            normalizedWeights[tokenIndex],
            bptAmountIn,
            totalSupply(),
            getSwapFeePercentage()
        );

        return (bptAmountIn, amountsOut);
    }

    function _exitExactBPTInForTokensOut(uint256[] memory balances, bytes memory userData)
        private
        view
        returns (uint256, uint256[] memory)
    {

        uint256 bptAmountIn = userData.exactBptInForTokensOut();

        uint256[] memory amountsOut = WeightedMath._calcTokensOutGivenExactBptIn(balances, bptAmountIn, totalSupply());
        return (bptAmountIn, amountsOut);
    }

    function _exitBPTInForExactTokensOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        bytes memory userData
    ) private view whenNotPaused returns (uint256, uint256[] memory) {

        (uint256[] memory amountsOut, uint256 maxBPTAmountIn) = userData.bptInForExactTokensOut();
        InputHelpers.ensureInputLengthMatch(amountsOut.length, 2);
        _upscaleArray(amountsOut);

        uint256 bptAmountIn = WeightedMath._calcBptInGivenExactTokensOut(
            balances,
            normalizedWeights,
            amountsOut,
            totalSupply(),
            getSwapFeePercentage()
        );
        _require(bptAmountIn <= maxBPTAmountIn, Errors.BPT_IN_MAX_AMOUNT);

        return (bptAmountIn, amountsOut);
    }


    function getLargestSafeQueryWindow() external pure override returns (uint256) {
        return 34 hours;
    }

    function getLatest(Variable variable) external view override returns (uint256) {
        int256 instantValue = _getInstantValue(variable, _miscData.oracleIndex());
        return LogCompression.fromLowResLog(instantValue);
    }

    function getTimeWeightedAverage(OracleAverageQuery[] memory queries)
        external
        view
        override
        returns (uint256[] memory results)
    {
        results = new uint256[](queries.length);

        uint256 oracleIndex = _miscData.oracleIndex();

        OracleAverageQuery memory query;
        for (uint256 i = 0; i < queries.length; ++i) {
            query = queries[i];
            _require(query.secs != 0, Errors.ORACLE_BAD_SECS);

            int256 beginAccumulator = _getPastAccumulator(query.variable, oracleIndex, query.ago + query.secs);
            int256 endAccumulator = _getPastAccumulator(query.variable, oracleIndex, query.ago);
            results[i] = LogCompression.fromLowResLog((endAccumulator - beginAccumulator) / int256(query.secs));
        }
    }

    function getPastAccumulators(OracleAccumulatorQuery[] memory queries)
        external
        view
        override
        returns (int256[] memory results)
    {
        results = new int256[](queries.length);

        uint256 oracleIndex = _miscData.oracleIndex();

        OracleAccumulatorQuery memory query;
        for (uint256 i = 0; i < queries.length; ++i) {
            query = queries[i];
            results[i] = _getPastAccumulator(query.variable, oracleIndex, query.ago);
        }
    }

    function _updateOracle(
        uint256 lastChangeBlock,
        uint256 balanceToken0,
        uint256 balanceToken1
    ) internal {
        bytes32 miscData = _miscData;
        if (miscData.oracleEnabled() && block.number > lastChangeBlock) {
            int256 logSpotPrice = WeightedOracleMath._calcLogSpotPrice(
                _normalizedWeight0,
                balanceToken0,
                _normalizedWeight1,
                balanceToken1
            );

            int256 logBPTPrice = WeightedOracleMath._calcLogBPTPrice(
                _normalizedWeight0,
                balanceToken0,
                miscData.logTotalSupply()
            );

            uint256 oracleCurrentIndex = miscData.oracleIndex();
            uint256 oracleCurrentSampleInitialTimestamp = miscData.oracleSampleCreationTimestamp();
            uint256 oracleUpdatedIndex = _processPriceData(
                oracleCurrentSampleInitialTimestamp,
                oracleCurrentIndex,
                logSpotPrice,
                logBPTPrice,
                miscData.logInvariant()
            );

            if (oracleCurrentIndex != oracleUpdatedIndex) {
                miscData = miscData.setOracleIndex(oracleUpdatedIndex);
                miscData = miscData.setOracleSampleCreationTimestamp(block.timestamp);
                _miscData = miscData;
            }
        }
    }

    function _cacheInvariantAndSupply() internal {
        bytes32 miscData = _miscData;
        if (miscData.oracleEnabled()) {
            miscData = miscData.setLogInvariant(LogCompression.toLowResLog(_lastInvariant));
            miscData = miscData.setLogTotalSupply(LogCompression.toLowResLog(totalSupply()));
            _miscData = miscData;
        }
    }


    function queryJoin(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) external returns (uint256 bptOut, uint256[] memory amountsIn) {
        InputHelpers.ensureInputLengthMatch(balances.length, 2);

        _queryAction(
            poolId,
            sender,
            recipient,
            balances,
            lastChangeBlock,
            protocolSwapFeePercentage,
            userData,
            _onJoinPool,
            _downscaleUpArray
        );

        return (bptOut, amountsIn);
    }

    function queryExit(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) external returns (uint256 bptIn, uint256[] memory amountsOut) {
        InputHelpers.ensureInputLengthMatch(balances.length, 2);

        _queryAction(
            poolId,
            sender,
            recipient,
            balances,
            lastChangeBlock,
            protocolSwapFeePercentage,
            userData,
            _onExitPool,
            _downscaleDownArray
        );

        return (bptIn, amountsOut);
    }


    function _getDueProtocolFeeAmounts(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256 previousInvariant,
        uint256 currentInvariant,
        uint256 protocolSwapFeePercentage
    ) private view returns (uint256[] memory) {
        uint256[] memory dueProtocolFeeAmounts = new uint256[](2);

        if (protocolSwapFeePercentage == 0) {
            return dueProtocolFeeAmounts;
        }

        dueProtocolFeeAmounts[_maxWeightTokenIndex] = WeightedMath._calcDueTokenProtocolSwapFeeAmount(
            balances[_maxWeightTokenIndex],
            normalizedWeights[_maxWeightTokenIndex],
            previousInvariant,
            currentInvariant,
            protocolSwapFeePercentage
        );

        return dueProtocolFeeAmounts;
    }

    function _mutateAmounts(
        uint256[] memory toMutate,
        uint256[] memory arguments,
        function(uint256, uint256) pure returns (uint256) mutation
    ) private pure {
        toMutate[0] = mutation(toMutate[0], arguments[0]);
        toMutate[1] = mutation(toMutate[1], arguments[1]);
    }

    function getRate() public view returns (uint256) {
        return Math.mul(getInvariant(), 2).divDown(totalSupply());
    }


    function _computeScalingFactor(IERC20 token) private view returns (uint256) {
        uint256 tokenDecimals = ERC20(address(token)).decimals();

        uint256 decimalsDifference = Math.sub(18, tokenDecimals);
        return 10**decimalsDifference;
    }

    function _scalingFactor(bool token0) internal view returns (uint256) {
        return token0 ? _scalingFactor0 : _scalingFactor1;
    }

    function _upscale(uint256 amount, uint256 scalingFactor) internal pure returns (uint256) {
        return Math.mul(amount, scalingFactor);
    }

    function _upscaleArray(uint256[] memory amounts) internal view {
        amounts[0] = Math.mul(amounts[0], _scalingFactor(true));
        amounts[1] = Math.mul(amounts[1], _scalingFactor(false));
    }

    function _downscaleDown(uint256 amount, uint256 scalingFactor) internal pure returns (uint256) {
        return Math.divDown(amount, scalingFactor);
    }

    function _downscaleDownArray(uint256[] memory amounts) internal view {
        amounts[0] = Math.divDown(amounts[0], _scalingFactor(true));
        amounts[1] = Math.divDown(amounts[1], _scalingFactor(false));
    }

    function _downscaleUp(uint256 amount, uint256 scalingFactor) internal pure returns (uint256) {
        return Math.divUp(amount, scalingFactor);
    }

    function _downscaleUpArray(uint256[] memory amounts) internal view {
        amounts[0] = Math.divUp(amounts[0], _scalingFactor(true));
        amounts[1] = Math.divUp(amounts[1], _scalingFactor(false));
    }

    function _getAuthorizer() internal view override returns (IAuthorizer) {
        return getVault().getAuthorizer();
    }

    function _queryAction(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData,
        function(bytes32, address, address, uint256[] memory, uint256, uint256, bytes memory)
            internal
            returns (uint256, uint256[] memory, uint256[] memory) _action,
        function(uint256[] memory) internal view _downscaleArray
    ) private {

        if (msg.sender != address(this)) {

            (bool success, ) = address(this).call(msg.data);

            assembly {
                switch success
                    case 0 {

                        returndatacopy(0, 0, 0x04)
                        let error := and(mload(0), 0xffffffff00000000000000000000000000000000000000000000000000000000)

                        if eq(eq(error, 0x43adbafb00000000000000000000000000000000000000000000000000000000), 0) {
                            returndatacopy(0, 0, returndatasize())
                            revert(0, returndatasize())
                        }


                        returndatacopy(0, 0x04, 32)

                        mstore(0x20, 64)

                        returndatacopy(0x40, 0x24, sub(returndatasize(), 36))

                        return(0, add(returndatasize(), 28))
                    }
                    default {
                        invalid()
                    }
            }
        } else {
            _upscaleArray(balances);

            (uint256 bptAmount, uint256[] memory tokenAmounts, ) = _action(
                poolId,
                sender,
                recipient,
                balances,
                lastChangeBlock,
                protocolSwapFeePercentage,
                userData
            );

            _downscaleArray(tokenAmounts);

            assembly {
                let size := mul(mload(tokenAmounts), 32)

                let start := sub(tokenAmounts, 0x20)
                mstore(start, bptAmount)

                mstore(sub(start, 0x20), 0x0000000000000000000000000000000000000000000000000000000043adbafb)
                start := sub(start, 0x04)

                revert(start, add(size, 68))
            }
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


contract MockSamples {
    using Samples for bytes32;

    struct Sample {
        int256 logPairPrice;
        int256 accLogPairPrice;
        int256 logBptPrice;
        int256 accLogBptPrice;
        int256 logInvariant;
        int256 accLogInvariant;
        uint256 timestamp;
    }

    function encode(Sample memory sample) public pure returns (bytes32) {
        return
            Samples.pack(
                sample.logPairPrice,
                sample.accLogPairPrice,
                sample.logBptPrice,
                sample.accLogBptPrice,
                sample.logInvariant,
                sample.accLogInvariant,
                sample.timestamp
            );
    }

    function decode(bytes32 sample) public pure returns (Sample memory) {
        return
            Sample({
                logPairPrice: sample.instant(IPriceOracle.Variable.PAIR_PRICE),
                accLogPairPrice: sample.accumulator(IPriceOracle.Variable.PAIR_PRICE),
                logBptPrice: sample.instant(IPriceOracle.Variable.BPT_PRICE),
                accLogBptPrice: sample.accumulator(IPriceOracle.Variable.BPT_PRICE),
                logInvariant: sample.instant(IPriceOracle.Variable.INVARIANT),
                accLogInvariant: sample.accumulator(IPriceOracle.Variable.INVARIANT),
                timestamp: sample.timestamp()
            });
    }

    function update(
        bytes32 sample,
        int256 logPairPrice,
        int256 logBptPrice,
        int256 logInvariant,
        uint256 timestamp
    ) public pure returns (Sample memory) {
        bytes32 newSample = sample.update(logPairPrice, logBptPrice, logInvariant, timestamp);
        return decode(newSample);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



contract MockPoolPriceOracle is MockSamples, PoolPriceOracle {
    using Samples for bytes32;

    struct BinarySearchResult {
        uint256 prev;
        uint256 next;
    }

    event PriceDataProcessed(bool newSample, uint256 sampleIndex);

    function mockSample(uint256 index, Sample memory sample) public {
        _samples[index] = encode(sample);
    }

    function mockSamples(uint256[] memory indexes, Sample[] memory samples) public {
        for (uint256 i = 0; i < indexes.length; i++) {
            mockSample(indexes[i], samples[i]);
        }
    }

    function processPriceData(
        uint256 elapsed,
        uint256 currentIndex,
        int256 logPairPrice,
        int256 logBptPrice,
        int256 logInvariant
    ) public {
        uint256 currentSampleInitialTimestamp = block.timestamp - elapsed;
        uint256 sampleIndex = _processPriceData(
            currentSampleInitialTimestamp,
            currentIndex,
            logPairPrice,
            logBptPrice,
            logInvariant
        );
        emit PriceDataProcessed(sampleIndex != currentIndex, sampleIndex);
    }

    function findNearestSamplesTimestamp(uint256[] memory dates, uint256 offset)
        external
        view
        returns (BinarySearchResult[] memory results)
    {
        results = new BinarySearchResult[](dates.length);
        for (uint256 i = 0; i < dates.length; i++) {
            (bytes32 prev, bytes32 next) = _findNearestSample(dates[i], offset);
            results[i] = BinarySearchResult({ prev: prev.timestamp(), next: next.timestamp() });
        }
    }

    function getPastAccumulator(
        IPriceOracle.Variable variable,
        uint256 currentIndex,
        uint256 timestamp
    ) external view returns (int256) {
        return _getPastAccumulator(variable, currentIndex, block.timestamp - timestamp);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


contract MockWeightedMath is WeightedMath {
    function invariant(uint256[] memory normalizedWeights, uint256[] memory balances) external pure returns (uint256) {
        return _calculateInvariant(normalizedWeights, balances);
    }

    function outGivenIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountIn
    ) external pure returns (uint256) {
        return _calcOutGivenIn(tokenBalanceIn, tokenWeightIn, tokenBalanceOut, tokenWeightOut, tokenAmountIn);
    }

    function inGivenOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountOut
    ) external pure returns (uint256) {
        return _calcInGivenOut(tokenBalanceIn, tokenWeightIn, tokenBalanceOut, tokenWeightOut, tokenAmountOut);
    }

    function exactTokensInForBPTOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory amountsIn,
        uint256 bptTotalSupply,
        uint256 swapFee
    ) external pure returns (uint256) {
        return _calcBptOutGivenExactTokensIn(balances, normalizedWeights, amountsIn, bptTotalSupply, swapFee);
    }

    function tokenInForExactBPTOut(
        uint256 tokenBalance,
        uint256 tokenNormalizedWeight,
        uint256 bptAmountOut,
        uint256 bptTotalSupply,
        uint256 swapFee
    ) external pure returns (uint256) {
        return _calcTokenInGivenExactBptOut(tokenBalance, tokenNormalizedWeight, bptAmountOut, bptTotalSupply, swapFee);
    }

    function exactBPTInForTokenOut(
        uint256 tokenBalance,
        uint256 tokenNormalizedWeight,
        uint256 bptAmountIn,
        uint256 bptTotalSupply,
        uint256 swapFee
    ) external pure returns (uint256) {
        return _calcTokenOutGivenExactBptIn(tokenBalance, tokenNormalizedWeight, bptAmountIn, bptTotalSupply, swapFee);
    }

    function exactBPTInForTokensOut(
        uint256[] memory currentBalances,
        uint256 bptAmountIn,
        uint256 totalBPT
    ) external pure returns (uint256[] memory) {
        return _calcTokensOutGivenExactBptIn(currentBalances, bptAmountIn, totalBPT);
    }

    function bptInForExactTokensOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory amountsOut,
        uint256 bptTotalSupply,
        uint256 swapFee
    ) external pure returns (uint256) {
        return _calcBptInGivenExactTokensOut(balances, normalizedWeights, amountsOut, bptTotalSupply, swapFee);
    }

    function calculateDueTokenProtocolSwapFeeAmount(
        uint256 balance,
        uint256 normalizedWeight,
        uint256 previousInvariant,
        uint256 currentInvariant,
        uint256 protocolSwapFeePercentage
    ) external pure returns (uint256) {
        return
            _calcDueTokenProtocolSwapFeeAmount(
                balance,
                normalizedWeight,
                previousInvariant,
                currentInvariant,
                protocolSwapFeePercentage
            );
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


contract MockLogCompression {
    function toLowResLog(uint256 value) external pure returns (int256) {
        return LogCompression.toLowResLog(value);
    }

    function fromLowResLog(int256 value) external pure returns (uint256) {
        return LogCompression.fromLowResLog(value);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



contract MockWeightedOracleMath is WeightedOracleMath, MockLogCompression {
    function calcLogSpotPrice(
        uint256 normalizedWeightA,
        uint256 balanceA,
        uint256 normalizedWeightB,
        uint256 balanceB
    ) external pure returns (int256) {
        return WeightedOracleMath._calcLogSpotPrice(normalizedWeightA, balanceA, normalizedWeightB, balanceB);
    }

    function calcLogBPTPrice(
        uint256 normalizedWeight,
        uint256 balance,
        int256 bptTotalSupplyLn
    ) external pure returns (int256) {
        return WeightedOracleMath._calcLogBPTPrice(normalizedWeight, balance, bptTotalSupplyLn);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



contract MockWeightedPool2Tokens is WeightedPool2Tokens, MockPoolPriceOracle, MockWeightedOracleMath {
    using WeightedPool2TokensMiscData for bytes32;

    struct MiscData {
        int256 logInvariant;
        int256 logTotalSupply;
        uint256 oracleSampleCreationTimestamp;
        uint256 oracleIndex;
        bool oracleEnabled;
        uint256 swapFeePercentage;
    }

    constructor(NewPoolParams memory params) WeightedPool2Tokens(params) {}

    function mockOracleDisabled() external {
        _setOracleEnabled(false);
    }

    function mockOracleIndex(uint256 index) external {
        _miscData = _miscData.setOracleIndex(index);
    }

    function mockMiscData(MiscData memory miscData) external {
        _miscData = encode(miscData);
    }

    function encode(MiscData memory _data) private pure returns (bytes32 data) {
        data = data.setSwapFeePercentage(_data.swapFeePercentage);
        data = data.setOracleEnabled(_data.oracleEnabled);
        data = data.setOracleIndex(_data.oracleIndex);
        data = data.setOracleSampleCreationTimestamp(_data.oracleSampleCreationTimestamp);
        data = data.setLogTotalSupply(_data.logTotalSupply);
        data = data.setLogInvariant(_data.logInvariant);
    }
}