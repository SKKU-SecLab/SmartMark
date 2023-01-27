pragma solidity ^0.8.0;

interface AggregatorV3Interface {


  function decimals()
    external
    view
    returns (
      uint8
    );


  function description()
    external
    view
    returns (
      string memory
    );


  function version()
    external
    view
    returns (
      uint256
    );


  function getRoundData(
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


}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

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
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolImmutables {

    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function fee() external view returns (uint24);


    function tickSpacing() external view returns (int24);


    function maxLiquidityPerTick() external view returns (uint128);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolState {

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );


    function feeGrowthGlobal0X128() external view returns (uint256);


    function feeGrowthGlobal1X128() external view returns (uint256);


    function protocolFees() external view returns (uint128 token0, uint128 token1);


    function liquidity() external view returns (uint128);


    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );


    function tickBitmap(int16 wordPosition) external view returns (uint256);


    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );


    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolDerivedState {

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);


    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolActions {

    function initialize(uint160 sqrtPriceX96) external;


    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);


    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);


    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);


    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);


    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;


    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolOwnerActions {

    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;


    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolEvents {

    event Initialize(uint160 sqrtPriceX96, int24 tick);

    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}// GPL-2.0-or-later
pragma solidity >=0.5.0;


interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{


}// GPL-3.0

pragma solidity ^0.8.7;

interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// GPL-3.0

pragma solidity ^0.8.7;



abstract contract AccessControl is Context, IAccessControl {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
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
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) external override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) external override {
        require(account == _msgSender(), "71");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) internal {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// GPL-3.0

pragma solidity >=0.4.0;

abstract contract FullMath {
    function _mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        require(denominator > prod1);


        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        uint256 twos = denominator & (~denominator + 1);
        assembly {
            denominator := div(denominator, twos)
        }

        assembly {
            prod0 := div(prod0, twos)
        }
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        uint256 inv = (3 * denominator) ^ 2;
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        result = prod0 * inv;
        return result;
    }
}// GPL-3.0

pragma solidity ^0.8.7;

interface IOracle {

    function read() external view returns (uint256);


    function readAll() external view returns (uint256 lowerRate, uint256 upperRate);


    function readLower() external view returns (uint256);


    function readUpper() external view returns (uint256);


    function readQuote(uint256 baseAmount) external view returns (uint256);


    function readQuoteLower(uint256 baseAmount) external view returns (uint256);


    function inBase() external view returns (uint256);

}// GPL-3.0

pragma solidity ^0.8.7;


abstract contract OracleAbstract is IOracle {
    uint256 public constant BASE = 10**18;
    uint256 public override inBase;
    bytes32 public description;

    function read() external view virtual override returns (uint256 rate);

    function readAll() external view override returns (uint256, uint256) {
        return _readAll(inBase);
    }

    function readLower() external view override returns (uint256 rate) {
        (rate, ) = _readAll(inBase);
    }

    function readUpper() external view override returns (uint256 rate) {
        (, rate) = _readAll(inBase);
    }

    function readQuote(uint256 quoteAmount) external view virtual override returns (uint256);

    function readQuoteLower(uint256 quoteAmount) external view override returns (uint256) {
        (uint256 quoteSmall, ) = _readAll(quoteAmount);
        return quoteSmall;
    }

    function _readAll(uint256 quoteAmount) internal view virtual returns (uint256, uint256) {}
}// GPL-3.0

pragma solidity ^0.8.7;


abstract contract ChainlinkUtils is AccessControl {
    uint32 public stalePeriod;

    bytes32 public constant GUARDIAN_ROLE_CHAINLINK = keccak256("GUARDIAN_ROLE");

    function _readChainlinkFeed(
        uint256 quoteAmount,
        AggregatorV3Interface feed,
        uint8 multiplied,
        uint256 decimals,
        uint256 castedRatio
    ) internal view returns (uint256, uint256) {
        if (castedRatio == 0) {
            (uint80 roundId, int256 ratio, , uint256 updatedAt, uint80 answeredInRound) = feed.latestRoundData();
            require(ratio > 0 && roundId <= answeredInRound && block.timestamp - updatedAt <= stalePeriod, "100");
            castedRatio = uint256(ratio);
        }
        if (multiplied == 1) quoteAmount = (quoteAmount * castedRatio) / (10**decimals);
        else quoteAmount = (quoteAmount * (10**decimals)) / castedRatio;
        return (quoteAmount, castedRatio);
    }

    function changeStalePeriod(uint32 _stalePeriod) external onlyRole(GUARDIAN_ROLE_CHAINLINK) {
        stalePeriod = _stalePeriod;
    }
}// GPL-3.0

pragma solidity ^0.8.7;


abstract contract ModuleChainlinkMulti is ChainlinkUtils {
    AggregatorV3Interface[] public circuitChainlink;
    uint8[] public circuitChainIsMultiplied;
    uint8[] public chainlinkDecimals;

    constructor(
        address[] memory _circuitChainlink,
        uint8[] memory _circuitChainIsMultiplied,
        uint32 _stalePeriod,
        address[] memory guardians
    ) {
        uint256 circuitLength = _circuitChainlink.length;
        require(circuitLength > 0, "106");
        require(circuitLength == _circuitChainIsMultiplied.length, "104");
        require(guardians.length > 0, "101");
        for (uint256 i = 0; i < guardians.length; i++) {
            require(guardians[i] != address(0), "0");
            _setupRole(GUARDIAN_ROLE_CHAINLINK, guardians[i]);
        }
        _setRoleAdmin(GUARDIAN_ROLE_CHAINLINK, GUARDIAN_ROLE_CHAINLINK);

        for (uint256 i = 0; i < circuitLength; i++) {
            AggregatorV3Interface _pool = AggregatorV3Interface(_circuitChainlink[i]);
            circuitChainlink.push(_pool);
            chainlinkDecimals.push(_pool.decimals());
        }

        stalePeriod = _stalePeriod;
        circuitChainIsMultiplied = _circuitChainIsMultiplied;
    }

    function _quoteChainlink(uint256 quoteAmount) internal view returns (uint256, uint256) {
        uint256 castedRatio;
        for (uint256 i = 0; i < circuitChainlink.length; i++) {
            (quoteAmount, castedRatio) = _readChainlinkFeed(
                quoteAmount,
                circuitChainlink[i],
                circuitChainIsMultiplied[i],
                chainlinkDecimals[i],
                0
            );
        }
        return (quoteAmount, castedRatio);
    }
}// GPL-3.0

pragma solidity ^0.8.7;


contract OracleMath is FullMath {

    int24 internal constant _MAX_TICK = 887272;

    function _getQuoteAtTick(
        int24 tick,
        uint256 baseAmount,
        uint256 multiply
    ) internal pure returns (uint256 quoteAmount) {

        uint256 ratio = _getRatioAtTick(tick);

        quoteAmount = (multiply == 1) ? _mulDiv(ratio, baseAmount, 1e18) : _mulDiv(1e18, baseAmount, ratio);
    }

    function _getRatioAtTick(int24 tick) internal pure returns (uint256 rate) {

        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(int256(_MAX_TICK)), "T");

        uint256 ratio = absTick & 0x1 != 0 ? 0xfff97272373d413259a46990580e213a : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x149b34ee7ac262) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;


        uint256 price = uint256((ratio >> 69) + (ratio % (1 << 69) == 0 ? 0 : 1));
        rate = ((price * 1e18) >> 59);
    }
}// GPL-3.0

pragma solidity ^0.8.7;




abstract contract UniswapUtils is AccessControl, OracleMath {

    uint32 public twapPeriod;

    bytes32 public constant GUARDIAN_ROLE_UNISWAP = keccak256("GUARDIAN_ROLE");

    function _readUniswapPool(
        uint256 quoteAmount,
        IUniswapV3Pool pool,
        uint8 isUniMultiplied
    ) internal view returns (uint256) {
        uint32[] memory secondAgos = new uint32[](2);

        secondAgos[0] = twapPeriod;
        secondAgos[1] = 0;

        (int56[] memory tickCumulatives, ) = pool.observe(secondAgos);
        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        int24 timeWeightedAverageTick = int24(tickCumulativesDelta / int32(twapPeriod));

        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % int56(int32(twapPeriod)) != 0))
            timeWeightedAverageTick--;

        return _getQuoteAtTick(timeWeightedAverageTick, quoteAmount, isUniMultiplied);
    }

    function changeTwapPeriod(uint32 _twapPeriod) external onlyRole(GUARDIAN_ROLE_UNISWAP) {
        require(int32(_twapPeriod) > 0, "99");
        twapPeriod = _twapPeriod;
    }
}// GPL-3.0

pragma solidity ^0.8.7;


abstract contract ModuleUniswapMulti is UniswapUtils {
    IUniswapV3Pool[] public circuitUniswap;
    uint8[] public circuitUniIsMultiplied;

    constructor(
        IUniswapV3Pool[] memory _circuitUniswap,
        uint8[] memory _circuitUniIsMultiplied,
        uint32 _twapPeriod,
        uint16 observationLength,
        address[] memory guardians
    ) {
        require(guardians.length > 0, "101");
        for (uint256 i = 0; i < guardians.length; i++) {
            require(guardians[i] != address(0), "0");
            _setupRole(GUARDIAN_ROLE_UNISWAP, guardians[i]);
        }
        _setRoleAdmin(GUARDIAN_ROLE_UNISWAP, GUARDIAN_ROLE_UNISWAP);

        require(int32(_twapPeriod) > 0, "102");
        uint256 circuitUniLength = _circuitUniswap.length;
        require(circuitUniLength > 0, "103");
        require(circuitUniLength == _circuitUniIsMultiplied.length, "104");

        twapPeriod = _twapPeriod;

        circuitUniswap = _circuitUniswap;
        circuitUniIsMultiplied = _circuitUniIsMultiplied;

        for (uint256 i = 0; i < circuitUniLength; i++) {
            circuitUniswap[i].increaseObservationCardinalityNext(observationLength);
        }
    }

    function _quoteUniswap(uint256 quoteAmount) internal view returns (uint256) {
        for (uint256 i = 0; i < circuitUniswap.length; i++) {
            quoteAmount = _readUniswapPool(quoteAmount, circuitUniswap[i], circuitUniIsMultiplied[i]);
        }
        return quoteAmount;
    }

    function increaseTWAPStore(uint16 newLengthStored) external {
        for (uint256 i = 0; i < circuitUniswap.length; i++) {
            circuitUniswap[i].increaseObservationCardinalityNext(newLengthStored);
        }
    }
}// GPL-3.0

pragma solidity ^0.8.7;




contract OracleDAI is OracleAbstract, ModuleChainlinkMulti, ModuleUniswapMulti {

    uint8 public immutable uniFinalCurrency;

    uint256 public immutable outBase;

    constructor(
        address[] memory addressInAndOutUni,
        IUniswapV3Pool[] memory _circuitUniswap,
        uint8[] memory _circuitUniIsMultiplied,
        uint32 _twapPeriod,
        uint16 observationLength,
        uint8 _uniFinalCurrency,
        address[] memory _circuitChainlink,
        uint8[] memory _circuitChainIsMultiplied,
        uint32 stalePeriod,
        address[] memory guardians,
        bytes32 _description
    )
        ModuleUniswapMulti(_circuitUniswap, _circuitUniIsMultiplied, _twapPeriod, observationLength, guardians)
        ModuleChainlinkMulti(_circuitChainlink, _circuitChainIsMultiplied, stalePeriod, guardians)
    {
        require(addressInAndOutUni.length == 2, "107");
        IERC20Metadata inCur = IERC20Metadata(addressInAndOutUni[0]);
        IERC20Metadata outCur = IERC20Metadata(addressInAndOutUni[1]);
        inBase = 10**(inCur.decimals());
        outBase = 10**(outCur.decimals());

        uniFinalCurrency = _uniFinalCurrency;
        description = _description;
    }

    function read() external view override returns (uint256) {

        return _readUniswapQuote(inBase);
    }

    function readQuote(uint256 quoteAmount) external view override returns (uint256) {

        return _readUniswapQuote(quoteAmount);
    }

    function _readAll(uint256 quoteAmount) internal view override returns (uint256, uint256) {

        uint256 quoteAmountUni = _quoteUniswap(quoteAmount);

        quoteAmountUni = (quoteAmountUni * BASE) / outBase;
        uint256 quoteAmountCL = (quoteAmount * BASE) / inBase;
        uint256 ratio;

        (quoteAmountCL, ratio) = _quoteChainlink(quoteAmountCL);

        if (uniFinalCurrency > 0) {
            quoteAmountUni = _changeUniswapNotFinal(ratio, quoteAmountUni);
        }

        ratio = _changeUniswapNotFinal(ratio, (quoteAmount * BASE) / inBase);

        if (quoteAmountCL <= quoteAmountUni) {
            if (ratio <= quoteAmountCL) {
                return (ratio, quoteAmountUni);
            } else if (quoteAmountUni <= ratio) {
                return (quoteAmountCL, ratio);
            }
            return (quoteAmountCL, quoteAmountUni);
        } else {
            if (ratio <= quoteAmountUni) {
                return (ratio, quoteAmountCL);
            } else if (quoteAmountCL <= ratio) {
                return (quoteAmountUni, ratio);
            }
            return (quoteAmountUni, quoteAmountCL);
        }
    }

    function _changeUniswapNotFinal(uint256 ratio, uint256 quoteAmountUni) internal view returns (uint256) {

        uint256 idxLastPoolCL = circuitChainlink.length - 1;
        (quoteAmountUni, ) = _readChainlinkFeed(
            quoteAmountUni,
            circuitChainlink[idxLastPoolCL],
            circuitChainIsMultiplied[idxLastPoolCL],
            chainlinkDecimals[idxLastPoolCL],
            ratio
        );
        return quoteAmountUni;
    }

    function _readUniswapQuote(uint256 quoteAmount) internal view returns (uint256 uniAmount) {

        uniAmount = _quoteUniswap(quoteAmount);
        uniAmount = (uniAmount * BASE) / outBase;
        if (uniFinalCurrency > 0) {
            uniAmount = _changeUniswapNotFinal(0, uniAmount);
        }
    }
}