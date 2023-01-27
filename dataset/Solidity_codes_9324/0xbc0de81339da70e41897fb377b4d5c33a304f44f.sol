pragma solidity >=0.6.0;

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
}// GPL-2.0-or-later
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external view returns (address);


    function WETH() external view returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external view returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}// GPL-2.0-or-later
pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external  returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external  returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external  payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function factory() external override view returns (address);

    function WETH() external override view returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external override returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external override payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external override returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external override returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external override returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external override returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external override returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external override returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external override
    payable
    returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external override
    returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external override
    returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external override
    payable
    returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external override view returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external override view returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external override view returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external override view returns (uint[] memory amounts);


    function getAmountsIn(uint amountOut, address[] calldata path) external override view returns (uint[] memory amounts);



}// GPL-2.0-or-later
pragma solidity >=0.5.0 <0.8.0;

library BytesLib {

    function concat(bytes memory _preBytes, bytes memory _postBytes)
        internal
        pure
        returns (bytes memory)
    {

        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(
                0x40,
                and(
                    add(add(end, iszero(add(length, mload(_preBytes)))), 31),
                    not(31) // Round down to the nearest 32 bytes.
                )
            )
        }

        return tempBytes;
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {

        require(_length + 31 >= _length, "slice_overflow");
        require(_start + _length >= _start, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(
                    add(tempBytes, lengthmod),
                    mul(0x20, iszero(lengthmod))
                )
                let end := add(mc, _length)

                for {
                    let cc := add(
                        add(
                            add(_bytes, lengthmod),
                            mul(0x20, iszero(lengthmod))
                        ),
                        _start
                    )
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (address)
    {

        require(_start + 20 >= _start, "toAddress_overflow");
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(
                mload(add(add(_bytes, 0x20), _start)),
                0x1000000000000000000000000
            )
        }

        return tempAddress;
    }

    function toUint24(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (uint24)
    {

        require(_start + 3 >= _start, "toUint24_overflow");
        require(_bytes.length >= _start + 3, "toUint24_outOfBounds");
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }
}// UNLICENSED
pragma solidity ^0.7.4;

interface ICurvePool {

    function coins(uint256) external view returns (address);


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function get_virtual_price() external view returns (uint256);

}// GPL-2.0-or-later
pragma solidity ^0.7.4;


library Errors {


    string public constant ZERO_ADDRESS_IS_NOT_ALLOWED = "Z0";
    string public constant NOT_IMPLEMENTED = "NI";
    string public constant INCORRECT_PATH_LENGTH = "PL";
    string public constant INCORRECT_ARRAY_LENGTH = "CR";
    string public constant REGISTERED_CREDIT_ACCOUNT_MANAGERS_ONLY = "CP";
    string public constant REGISTERED_POOLS_ONLY = "RP";
    string public constant INCORRECT_PARAMETER = "IP";


    string public constant MATH_MULTIPLICATION_OVERFLOW = "M1";
    string public constant MATH_ADDITION_OVERFLOW = "M2";
    string public constant MATH_DIVISION_BY_ZERO = "M3";


    string public constant POOL_CONNECTED_CREDIT_MANAGERS_ONLY = "PS0";
    string public constant POOL_INCOMPATIBLE_CREDIT_ACCOUNT_MANAGER = "PS1";
    string public constant POOL_MORE_THAN_EXPECTED_LIQUIDITY_LIMIT = "PS2";
    string public constant POOL_INCORRECT_WITHDRAW_FEE = "PS3";
    string public constant POOL_CANT_ADD_CREDIT_MANAGER_TWICE = "PS4";


    string public constant CM_NO_OPEN_ACCOUNT = "CM1";
    string
        public constant CM_ZERO_ADDRESS_OR_USER_HAVE_ALREADY_OPEN_CREDIT_ACCOUNT =
        "CM2";

    string public constant CM_INCORRECT_AMOUNT = "CM3";
    string public constant CM_CAN_LIQUIDATE_WITH_SUCH_HEALTH_FACTOR = "CM4";
    string public constant CM_CAN_UPDATE_WITH_SUCH_HEALTH_FACTOR = "CM5";
    string public constant CM_WETH_GATEWAY_ONLY = "CM6";
    string public constant CM_INCORRECT_PARAMS = "CM7";
    string public constant CM_INCORRECT_FEES = "CM8";
    string public constant CM_MAX_LEVERAGE_IS_TOO_HIGH = "CM9";
    string public constant CM_CANT_CLOSE_WITH_LOSS = "CMA";
    string public constant CM_TARGET_CONTRACT_iS_NOT_ALLOWED = "CMB";
    string public constant CM_TRANSFER_FAILED = "CMC";
    string public constant CM_INCORRECT_NEW_OWNER = "CME";


    string public constant AF_CANT_CLOSE_CREDIT_ACCOUNT_IN_THE_SAME_BLOCK =
        "AF1";
    string public constant AF_MINING_IS_FINISHED = "AF2";
    string public constant AF_CREDIT_ACCOUNT_NOT_IN_STOCK = "AF3";
    string public constant AF_EXTERNAL_ACCOUNTS_ARE_FORBIDDEN = "AF4";


    string public constant AS_ADDRESS_NOT_FOUND = "AP1";


    string public constant CR_POOL_ALREADY_ADDED = "CR1";
    string public constant CR_CREDIT_MANAGER_ALREADY_ADDED = "CR2";


    string public constant CF_UNDERLYING_TOKEN_FILTER_CONFLICT = "CF0";
    string public constant CF_INCORRECT_LIQUIDATION_THRESHOLD = "CF1";
    string public constant CF_TOKEN_IS_NOT_ALLOWED = "CF2";
    string public constant CF_CREDIT_MANAGERS_ONLY = "CF3";
    string public constant CF_ADAPTERS_ONLY = "CF4";
    string public constant CF_OPERATION_LOW_HEALTH_FACTOR = "CF5";
    string public constant CF_TOO_MUCH_ALLOWED_TOKENS = "CF6";
    string public constant CF_INCORRECT_CHI_THRESHOLD = "CF7";
    string public constant CF_INCORRECT_FAST_CHECK = "CF8";
    string public constant CF_NON_TOKEN_CONTRACT = "CF9";
    string public constant CF_CONTRACT_IS_NOT_IN_ALLOWED_LIST = "CFA";
    string public constant CF_FAST_CHECK_NOT_COVERED_COLLATERAL_DROP = "CFB";
    string public constant CF_SOME_LIQUIDATION_THRESHOLD_MORE_THAN_NEW_ONE =
        "CFC";
    string public constant CF_ADAPTER_CAN_BE_USED_ONLY_ONCE = "CFD";
    string public constant CF_INCORRECT_PRICEFEED = "CFE";
    string public constant CF_TRANSFER_IS_NOT_ALLOWED = "CFF";
    string public constant CF_CREDIT_MANAGER_IS_ALREADY_SET = "CFG";


    string public constant CA_CONNECTED_CREDIT_MANAGER_ONLY = "CA1";
    string public constant CA_FACTORY_ONLY = "CA2";


    string public constant PO_PRICE_FEED_DOESNT_EXIST = "PO0";
    string public constant PO_TOKENS_WITH_DECIMALS_MORE_18_ISNT_ALLOWED = "PO1";
    string public constant PO_AGGREGATOR_DECIMALS_SHOULD_BE_18 = "PO2";


    string public constant ACL_CALLER_NOT_PAUSABLE_ADMIN = "ACL1";
    string public constant ACL_CALLER_NOT_CONFIGURATOR = "ACL2";


    string public constant WG_DESTINATION_IS_NOT_WETH_COMPATIBLE = "WG1";
    string public constant WG_RECEIVE_IS_NOT_ALLOWED = "WG2";
    string public constant WG_NOT_ENOUGH_FUNDS = "WG3";


    string public constant LA_INCORRECT_VALUE = "LA1";
    string public constant LA_HAS_VALUE_WITH_TOKEN_TRANSFER = "LA2";
    string public constant LA_UNKNOWN_SWAP_INTERFACE = "LA3";
    string public constant LA_UNKNOWN_LP_INTERFACE = "LA4";
    string public constant LA_LOWER_THAN_AMOUNT_MIN = "LA5";
    string public constant LA_TOKEN_OUT_IS_NOT_COLLATERAL = "LA6";

    string public constant YPF_PRICE_PER_SHARE_OUT_OF_RANGE = "YP1";
    string public constant YPF_INCORRECT_LIMITER_PARAMETERS = "YP2";

    string public constant TD_WALLET_IS_ALREADY_CONNECTED_TO_VC = "TD1";
    string public constant TD_INCORRECT_WEIGHTS = "TD2";
    string public constant TD_NON_ZERO_BALANCE_AFTER_DISTRIBUTION = "TD3";
    string public constant TD_CONTRIBUTOR_IS_NOT_REGISTERED = "TD4";
}// agpl-3.0
pragma solidity ^0.7.4;



library PercentageMath {

    uint256 constant PERCENTAGE_FACTOR = 1e4; //percentage plus two decimals
    uint256 constant HALF_PERCENT = PERCENTAGE_FACTOR / 2;

    function percentMul(uint256 value, uint256 percentage)
        internal
        pure
        returns (uint256)
    {

        if (value == 0 || percentage == 0) {
            return 0; // T:[PM-1]
        }

        require(
            value <= (type(uint256).max - HALF_PERCENT) / percentage,
            Errors.MATH_MULTIPLICATION_OVERFLOW
        ); // T:[PM-1]

        return (value * percentage + HALF_PERCENT) / PERCENTAGE_FACTOR; // T:[PM-1]
    }

    function percentDiv(uint256 value, uint256 percentage)
        internal
        pure
        returns (uint256)
    {

        require(percentage != 0, Errors.MATH_DIVISION_BY_ZERO); // T:[PM-2]
        uint256 halfPercentage = percentage / 2; // T:[PM-2]

        require(
            value <= (type(uint256).max - halfPercentage) / PERCENTAGE_FACTOR,
            Errors.MATH_MULTIPLICATION_OVERFLOW
        ); // T:[PM-2]

        return (value * PERCENTAGE_FACTOR + halfPercentage) / percentage;
    }
}// GPL-2.0-or-later
pragma solidity ^0.7.4;


library Constants {

    uint256 constant MAX_INT =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    uint256 constant MAX_INT_4 =
        0x3fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    uint256 constant ACCOUNT_CREATION_REWARD = 1e5;
    uint256 constant DEPLOYMENT_COST = 1e17;

    uint256 constant FEE_INTEREST = 1000; // 10%

    uint256 constant FEE_LIQUIDATION = 200;

    uint256 constant LIQUIDATION_DISCOUNTED_SUM = 9500;

    uint256 constant UNDERLYING_TOKEN_LIQUIDATION_THRESHOLD =
        LIQUIDATION_DISCOUNTED_SUM - FEE_LIQUIDATION;

    uint256 constant SECONDS_PER_YEAR = 365 days;
    uint256 constant SECONDS_PER_ONE_AND_HALF_YEAR = SECONDS_PER_YEAR * 3 /2;

    uint256 constant RAY = 1e27;
    uint256 constant WAD = 1e18;

    uint8 constant OPERATION_CLOSURE = 1;
    uint8 constant OPERATION_REPAY = 2;
    uint8 constant OPERATION_LIQUIDATION = 3;

    uint8 constant LEVERAGE_DECIMALS = 100;

    uint8 constant MAX_WITHDRAW_FEE = 100;

    uint256 constant CHI_THRESHOLD = 9950;
    uint256 constant HF_CHECK_INTERVAL_DEFAULT = 4;

    uint256 constant NO_SWAP = 0;
    uint256 constant UNISWAP_V2 = 1;
    uint256 constant UNISWAP_V3 = 2;
    uint256 constant CURVE_V1 = 3;
    uint256 constant LP_YEARN = 4;

    uint256 constant EXACT_INPUT = 1;
    uint256 constant EXACT_OUTPUT = 2;
}// GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IQuoter {

    function quoteExactInput(bytes memory path, uint256 amountIn) external returns (uint256 amountOut);


    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut);


    function quoteExactOutput(bytes memory path, uint256 amountOut) external returns (uint256 amountIn);


    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountIn);

}// GPL-2.0-or-later
pragma solidity ^0.7.4;


interface IAppAddressProvider {

    function getDataCompressor() external view returns (address);


    function getGearToken() external view returns (address);


    function getWethToken() external view returns (address);


    function getWETHGateway() external view returns (address);


    function getPriceOracle() external view returns (address);


    function getLeveragedActions() external view returns (address);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// BUSL-1.1
pragma solidity ^0.7.4;



contract AddressProvider is Ownable, IAppAddressProvider {

    mapping(bytes32 => address) public addresses;

    event AddressSet(bytes32 indexed service, address indexed newAddress);

    event Claimed(uint256 user_id, address account, uint256 amount, bytes32 leaf);

    bytes32 public constant CONTRACTS_REGISTER = "CONTRACTS_REGISTER";
    bytes32 public constant ACL = "ACL";
    bytes32 public constant PRICE_ORACLE = "PRICE_ORACLE";
    bytes32 public constant ACCOUNT_FACTORY = "ACCOUNT_FACTORY";
    bytes32 public constant DATA_COMPRESSOR = "DATA_COMPRESSOR";
    bytes32 public constant TREASURY_CONTRACT = "TREASURY_CONTRACT";
    bytes32 public constant GEAR_TOKEN = "GEAR_TOKEN";
    bytes32 public constant WETH_TOKEN = "WETH_TOKEN";
    bytes32 public constant WETH_GATEWAY = "WETH_GATEWAY";
    bytes32 public constant LEVERAGED_ACTIONS = "LEVERAGED_ACTIONS";

    uint256 public constant version = 1;

    constructor() {
        emit AddressSet("ADDRESS_PROVIDER", address(this));
    }

    function getACL() external view returns (address) {

        return _getAddress(ACL); // T:[AP-3]
    }

    function setACL(address _address)
        external
        onlyOwner // T:[AP-15]
    {

        _setAddress(ACL, _address); // T:[AP-3]
    }

    function getContractsRegister() external view returns (address) {

        return _getAddress(CONTRACTS_REGISTER); // T:[AP-4]
    }

    function setContractsRegister(address _address)
        external
        onlyOwner // T:[AP-15]
    {

        _setAddress(CONTRACTS_REGISTER, _address); // T:[AP-4]
    }

    function getPriceOracle() external view override returns (address) {

        return _getAddress(PRICE_ORACLE); // T:[AP-5]
    }

    function setPriceOracle(address _address)
        external
        onlyOwner // T:[AP-15]
    {

        _setAddress(PRICE_ORACLE, _address); // T:[AP-5]
    }

    function getAccountFactory() external view returns (address) {

        return _getAddress(ACCOUNT_FACTORY); // T:[AP-6]
    }

    function setAccountFactory(address _address)
        external
        onlyOwner // T:[AP-15]
    {

        _setAddress(ACCOUNT_FACTORY, _address); // T:[AP-7]
    }

    function getDataCompressor() external view override returns (address) {

        return _getAddress(DATA_COMPRESSOR); // T:[AP-8]
    }

    function setDataCompressor(address _address)
        external
        onlyOwner // T:[AP-15]
    {

        _setAddress(DATA_COMPRESSOR, _address); // T:[AP-8]
    }

    function getTreasuryContract() external view returns (address) {

        return _getAddress(TREASURY_CONTRACT); //T:[AP-11]
    }

    function setTreasuryContract(address _address)
        external
        onlyOwner // T:[AP-15]
    {

        _setAddress(TREASURY_CONTRACT, _address); //T:[AP-11]
    }

    function getGearToken() external view override returns (address) {

        return _getAddress(GEAR_TOKEN); // T:[AP-12]
    }

    function setGearToken(address _address)
        external
        onlyOwner // T:[AP-15]
    {

        _setAddress(GEAR_TOKEN, _address); // T:[AP-12]
    }

    function getWethToken() external view override returns (address) {

        return _getAddress(WETH_TOKEN); // T:[AP-13]
    }

    function setWethToken(address _address)
        external
        onlyOwner // T:[AP-15]
    {

        _setAddress(WETH_TOKEN, _address); // T:[AP-13]
    }

    function getWETHGateway() external view override returns (address) {

        return _getAddress(WETH_GATEWAY); // T:[AP-14]
    }

    function setWETHGateway(address _address)
        external
        onlyOwner // T:[AP-15]
    {

        _setAddress(WETH_GATEWAY, _address); // T:[AP-14]
    }

    function getLeveragedActions() external view override returns (address) {

        return _getAddress(LEVERAGED_ACTIONS); // T:[AP-7]
    }

    function setLeveragedActions(address _address)
        external
        onlyOwner // T:[AP-15]
    {

        _setAddress(LEVERAGED_ACTIONS, _address); // T:[AP-7]
    }

    function _getAddress(bytes32 key) internal view returns (address) {

        address result = addresses[key];
        require(result != address(0), Errors.AS_ADDRESS_NOT_FOUND); // T:[AP-1]
        return result; // T:[AP-3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
    }

    function _setAddress(bytes32 key, address value) internal {

        addresses[key] = value; // T:[AP-3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
        emit AddressSet(key, value); // T:[AP-2]
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// BUSL-1.1
pragma solidity ^0.7.4;



contract ACL is Ownable {

    mapping(address => bool) public pausableAdminSet;
    mapping(address => bool) public unpausableAdminSet;

    uint256 public constant version = 1;

    event PausableAdminAdded(address indexed newAdmin);

    event PausableAdminRemoved(address indexed admin);

    event UnpausableAdminAdded(address indexed newAdmin);

    event UnpausableAdminRemoved(address indexed admin);

    function addPausableAdmin(address newAdmin)
        external
        onlyOwner // T:[ACL-1]
    {

        pausableAdminSet[newAdmin] = true; // T:[ACL-2]
        emit PausableAdminAdded(newAdmin); // T:[ACL-2]
    }

    function removePausableAdmin(address admin)
        external
        onlyOwner // T:[ACL-1]
    {

        pausableAdminSet[admin] = false; // T:[ACL-3]
        emit PausableAdminRemoved(admin); // T:[ACL-3]
    }

    function isPausableAdmin(address addr) external view returns (bool) {

        return pausableAdminSet[addr]; // T:[ACL-2,3]
    }

    function addUnpausableAdmin(address newAdmin)
        external
        onlyOwner // T:[ACL-1]
    {

        unpausableAdminSet[newAdmin] = true; // T:[ACL-4]
        emit UnpausableAdminAdded(newAdmin); // T:[ACL-4]
    }

    function removeUnpausableAdmin(address admin)
        external
        onlyOwner // T:[ACL-1]
    {

        unpausableAdminSet[admin] = false; // T:[ACL-5]
        emit UnpausableAdminRemoved(admin); // T:[ACL-5]
    }

    function isUnpausableAdmin(address addr) external view returns (bool) {

        return unpausableAdminSet[addr]; // T:[ACL-4,5]
    }

    function isConfigurator(address account) external view returns (bool) {

        return account == owner(); // T:[ACL-6]
    }
}// BUSL-1.1
pragma solidity ^0.7.4;



abstract contract ACLTrait is Pausable {
    ACL private _acl;

    constructor(address addressProvider) {
        require(
            addressProvider != address(0),
            Errors.ZERO_ADDRESS_IS_NOT_ALLOWED
        );

        _acl = ACL(AddressProvider(addressProvider).getACL());
    }

    modifier configuratorOnly() {
        require(
            _acl.isConfigurator(msg.sender),
            Errors.ACL_CALLER_NOT_CONFIGURATOR
        ); // T:[ACLT-8]
        _;
    }

    function pause() external {
        require(
            _acl.isPausableAdmin(msg.sender),
            Errors.ACL_CALLER_NOT_PAUSABLE_ADMIN
        ); // T:[ACLT-1]
        _pause();
    }

    function unpause() external {
        require(
            _acl.isUnpausableAdmin(msg.sender),
            Errors.ACL_CALLER_NOT_PAUSABLE_ADMIN
        ); // T:[ACLT-1],[ACLT-2]
        _unpause();
    }
}// BUSL-1.1
pragma solidity ^0.7.4;



contract ContractsRegister is ACLTrait {

    address[] public pools;
    mapping(address => bool) public isPool;

    address[] public creditManagers;
    mapping(address => bool) public isCreditManager;

    uint256 public constant version = 1;

    event NewPoolAdded(address indexed pool);

    event NewCreditManagerAdded(address indexed creditManager);

    constructor(address addressProvider) ACLTrait(addressProvider) {}

    function addPool(address newPoolAddress)
        external
        configuratorOnly // T:[CR-1]
    {

        require(
            newPoolAddress != address(0),
            Errors.ZERO_ADDRESS_IS_NOT_ALLOWED
        );
        require(!isPool[newPoolAddress], Errors.CR_POOL_ALREADY_ADDED); // T:[CR-2]
        pools.push(newPoolAddress); // T:[CR-3]
        isPool[newPoolAddress] = true; // T:[CR-3]

        emit NewPoolAdded(newPoolAddress); // T:[CR-4]
    }

    function getPools() external view returns (address[] memory) {

        return pools;
    }

    function getPoolsCount() external view returns (uint256) {

        return pools.length; // T:[CR-3]
    }

    function addCreditManager(address newCreditManager)
        external
        configuratorOnly // T:[CR-1]
    {

        require(
            newCreditManager != address(0),
            Errors.ZERO_ADDRESS_IS_NOT_ALLOWED
        );

        require(
            !isCreditManager[newCreditManager],
            Errors.CR_CREDIT_MANAGER_ALREADY_ADDED
        ); // T:[CR-5]
        creditManagers.push(newCreditManager); // T:[CR-6]
        isCreditManager[newCreditManager] = true; // T:[CR-6]

        emit NewCreditManagerAdded(newCreditManager); // T:[CR-7]
    }

    function getCreditManagers() external view returns (address[] memory) {

        return creditManagers;
    }

    function getCreditManagersCount() external view returns (uint256) {

        return creditManagers.length; // T:[CR-6]
    }
}// GPL-2.0-or-later
pragma solidity ^0.7.4;

interface ICreditFilter {

    event TokenAllowed(address indexed token, uint256 liquidityThreshold);

    event TokenForbidden(address indexed token);

    event ContractAllowed(address indexed protocol, address indexed adapter);

    event ContractForbidden(address indexed protocol);

    event NewFastCheckParameters(uint256 chiThreshold, uint256 fastCheckDelay);

    event TransferAccountAllowed(
        address indexed from,
        address indexed to,
        bool state
    );

    event TransferPluginAllowed(
        address indexed pugin,
        bool state
    );

    event PriceOracleUpdated(address indexed newPriceOracle);


    function allowToken(address token, uint256 liquidationThreshold) external;


    function allowContract(address targetContract, address adapter) external;


    function forbidContract(address targetContract) external;


    function checkCollateralChange(
        address creditAccount,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    ) external;


    function checkMultiTokenCollateral(
        address creditAccount,
        uint256[] memory amountIn,
        uint256[] memory amountOut,
        address[] memory tokenIn,
        address[] memory tokenOut
    ) external;


    function connectCreditManager(address poolService) external;


    function initEnabledTokens(address creditAccount) external;


    function checkAndEnableToken(address creditAccount, address token) external;



    function allowedContractsCount() external view returns (uint256);


    function allowedContracts(uint256 id) external view returns (address);


    function revertIfTokenNotAllowed(address token) external view;


    function isTokenAllowed(address token) external view returns (bool);


    function allowedTokensCount() external view returns (uint256);


    function allowedTokens(uint256 id) external view returns (address);


    function calcTotalValue(address creditAccount)
        external
        view
        returns (uint256 total);


    function calcThresholdWeightedValue(address creditAccount)
        external
        view
        returns (uint256 total);


    function contractToAdapter(address allowedContract)
        external
        view
        returns (address);


    function underlyingToken() external view returns (address);


    function getCreditAccountTokenById(address creditAccount, uint256 id)
        external
        view
        returns (
            address token,
            uint256 balance,
            uint256 tv,
            uint256 twv
        );


    function calcCreditAccountHealthFactor(address creditAccount)
        external
        view
        returns (uint256);


    function calcCreditAccountAccruedInterest(address creditAccount)
        external
        view
        returns (uint256);


    function enabledTokens(address creditAccount)
        external
        view
        returns (uint256);


    function liquidationThresholds(address token)
        external
        view
        returns (uint256);


    function priceOracle() external view returns (address);


    function updateUnderlyingTokenLiquidationThreshold() external;


    function revertIfCantIncreaseBorrowing(
        address creditAccount,
        uint256 minHealthFactor
    ) external view;


    function revertIfAccountTransferIsNotAllowed(
        address onwer,
        address creditAccount
    ) external view;


    function approveAccountTransfers(address from, bool state) external;


    function allowanceForAccountTransfers(address from, address to)
        external
        view
        returns (bool);

}// GPL-2.0-or-later
pragma solidity ^0.7.4;



interface IAppCreditManager {

    function openCreditAccount(
        uint256 amount,
        address onBehalfOf,
        uint256 leverageFactor,
        uint256 referralCode
    ) external;


    function closeCreditAccount(address to, DataTypes.Exchange[] calldata paths)
        external;


    function repayCreditAccount(address to) external;


    function increaseBorrowedAmount(uint256 amount) external;


    function addCollateral(
        address onBehalfOf,
        address token,
        uint256 amount
    ) external;


    function calcRepayAmount(address borrower, bool isLiquidated)
        external
        view
        returns (uint256);


    function getCreditAccountOrRevert(address borrower)
        external
        view
        returns (address);


    function hasOpenedCreditAccount(address borrower)
        external
        view
        returns (bool);


    function defaultSwapContract() external view returns (address);

}// GPL-2.0-or-later
pragma solidity ^0.7.4;



interface ICreditManager is IAppCreditManager {

    event OpenCreditAccount(
        address indexed sender,
        address indexed onBehalfOf,
        address indexed creditAccount,
        uint256 amount,
        uint256 borrowAmount,
        uint256 referralCode
    );

    event CloseCreditAccount(
        address indexed owner,
        address indexed to,
        uint256 remainingFunds
    );

    event LiquidateCreditAccount(
        address indexed owner,
        address indexed liquidator,
        uint256 remainingFunds
    );

    event IncreaseBorrowedAmount(address indexed borrower, uint256 amount);

    event AddCollateral(
        address indexed onBehalfOf,
        address indexed token,
        uint256 value
    );

    event RepayCreditAccount(address indexed owner, address indexed to);

    event ExecuteOrder(address indexed borrower, address indexed target);

    event NewParameters(
        uint256 minAmount,
        uint256 maxAmount,
        uint256 maxLeverage,
        uint256 feeInterest,
        uint256 feeLiquidation,
        uint256 liquidationDiscount
    );

    event TransferAccount(address indexed oldOwner, address indexed newOwner);


    function openCreditAccount(
        uint256 amount,
        address onBehalfOf,
        uint256 leverageFactor,
        uint256 referralCode
    ) external override;


    function closeCreditAccount(address to, DataTypes.Exchange[] calldata paths)
        external
        override;


    function liquidateCreditAccount(
        address borrower,
        address to,
        bool force
    ) external;


    function repayCreditAccount(address to) external override;


    function repayCreditAccountETH(address borrower, address to)
        external
        returns (uint256);


    function increaseBorrowedAmount(uint256 amount) external override;


    function addCollateral(
        address onBehalfOf,
        address token,
        uint256 amount
    ) external override;


    function hasOpenedCreditAccount(address borrower)
        external
        view
        override
        returns (bool);


    function calcRepayAmount(address borrower, bool isLiquidated)
        external
        view
        override
        returns (uint256);


    function minAmount() external view returns (uint256);


    function maxAmount() external view returns (uint256);


    function maxLeverageFactor() external view returns (uint256);


    function underlyingToken() external view returns (address);


    function poolService() external view returns (address);


    function creditFilter() external view returns (ICreditFilter);


    function creditAccounts(address borrower) external view returns (address);


    function executeOrder(
        address borrower,
        address target,
        bytes memory data
    ) external returns (bytes memory);


    function approve(address targetContract, address token) external;


    function provideCreditAccountAllowance(
        address creditAccount,
        address toContract,
        address token
    ) external;


    function transferAccountOwnership(address newOwner) external;


    function getCreditAccountOrRevert(address borrower)
        external
        view
        override
        returns (address);



    function feeInterest() external view returns (uint256);


    function feeLiquidation() external view returns (uint256);


    function liquidationDiscount() external view returns (uint256);


    function minHealthFactor() external view returns (uint256);


    function defaultSwapContract() external view override returns (address);

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

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// GPL-2.0-or-later
pragma solidity ^0.7.4;


interface IPriceOracle {

    event NewPriceFeed(address indexed token, address indexed priceFeed);

    function addPriceFeed(address token, address priceFeedToken) external;

    function convert(
        uint256 amount,
        address tokenFrom,
        address tokenTo
    ) external view returns (uint256);

    function getLastPrice(address tokenFrom, address tokenTo)
        external
        view
        returns (uint256);
}// BUSL-1.1
pragma solidity ^0.7.4;






contract PriceOracle is ACLTrait, IPriceOracle {
    using SafeMath for uint256;

    address public wethAddress;

    mapping(address => address) public priceFeeds;

    mapping(address => uint256) public decimalsMultipliers;
    mapping(address => uint256) public decimalsDividers;

    uint constant public version = 1;

    constructor(address addressProvider) ACLTrait(addressProvider) {
        wethAddress = AddressProvider(addressProvider).getWethToken();
        decimalsMultipliers[wethAddress] = 1;
        decimalsDividers[wethAddress] = Constants.WAD;
    }

    function addPriceFeed(address token, address priceFeed)
        external
        override
        configuratorOnly
    {
        priceFeeds[token] = priceFeed;
        uint256 decimals = ERC20(token).decimals();

        require(
            decimals <= 18,
            Errors.PO_TOKENS_WITH_DECIMALS_MORE_18_ISNT_ALLOWED
        ); // T:[PO-3]

        require(
            AggregatorV3Interface(priceFeed).decimals() == 18,
            Errors.PO_AGGREGATOR_DECIMALS_SHOULD_BE_18
        ); // T:[PO-10]

        decimalsMultipliers[token] = 10**(18 - decimals);
        decimalsDividers[token] = 10**(36 - decimals);
        emit NewPriceFeed(token, priceFeed); // T:[PO-4]
    }

    function convert(
        uint256 amount,
        address tokenFrom,
        address tokenTo
    ) external view override returns (uint256) {
        return
            amount
                .mul(decimalsMultipliers[tokenFrom])
                .mul(getLastPrice(tokenFrom, tokenTo))
                .div(decimalsDividers[tokenTo]); // T:[PO-8]
    }

    function getLastPrice(address tokenFrom, address tokenTo)
        public
        view
        override
        returns (uint256)
    {
        if (tokenFrom == tokenTo) return Constants.WAD; // T:[PO-1]

        if (tokenFrom == wethAddress) {
            return Constants.WAD.mul(Constants.WAD).div(_getPrice(tokenTo)); // T:[PO-6]
        }

        if (tokenTo == wethAddress) {
            return _getPrice(tokenFrom); // T:[PO-6]
        }

        return Constants.WAD.mul(_getPrice(tokenFrom)).div(_getPrice(tokenTo)); // T:[PO-7]
    }

    function _getPrice(address token) internal view returns (uint256) {
        require(
            priceFeeds[token] != address(0),
            Errors.PO_PRICE_FEED_DOESNT_EXIST
        ); // T:[PO-9]

        (
            ,
            int256 price, //uint startedAt, //uint timeStamp, //uint80 answeredInRound
            ,
            ,

        ) = AggregatorV3Interface(priceFeeds[token]).latestRoundData(); // T:[PO-6]
        return uint256(price);
    }
}// GPL-2.0-or-later
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;


contract PathFinder {
    using SafeMath for uint256;
    using BytesLib for bytes;
    AddressProvider public addressProvider;
    ContractsRegister public immutable contractsRegister;
    PriceOracle public priceOracle;
    address public wethToken;

        address public constant ethToUsdPriceFeed =
        0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;


    uint256 public constant version = 1;

    struct TradePath {
        address[] path;
        uint256 rate;
        uint256 expectedAmount;
    }

    modifier registeredCreditManagerOnly(address creditManager) {
        require(
            contractsRegister.isCreditManager(creditManager),
            Errors.REGISTERED_CREDIT_ACCOUNT_MANAGERS_ONLY
        ); // T:[WG-3]

        _;
    }

    constructor(address _addressProvider) {
        addressProvider = AddressProvider(_addressProvider);
        contractsRegister = ContractsRegister(
            addressProvider.getContractsRegister()
        );

        priceOracle = PriceOracle(addressProvider.getPriceOracle());
        wethToken = addressProvider.getWethToken();
    }

    function bestUniPath(
        uint256 swapInterface,
        address router,
        uint256 swapType,
        address from,
        address to,
        uint256 amount,
        address[] memory tokens
    ) public returns (TradePath memory) {
        if (amount == 0) {
            return
                TradePath({path: new address[](3), rate: 0, expectedAmount: 0});
        }

        address[] memory path = new address[](2);

        path[0] = from;
        path[1] = to;

        (uint256 bestAmount, bool best) = _getAmountsUni(
            swapInterface,
            router,
            swapType,
            path,
            amount,
            swapType == Constants.EXACT_INPUT ? 0 : Constants.MAX_INT
        );

        address[] memory bestPath;
        uint256 expectedAmount;

        if (best) {
            bestPath = path;
        }

        for (uint256 i = 0; i < tokens.length; i++) {
            path = new address[](3);
            path[0] = from;
            path[2] = to;

            if (tokens[i] != from && tokens[i] != to) {
                path[1] = tokens[i];
                (expectedAmount, best) = _getAmountsUni(
                    swapInterface,
                    router,
                    swapType,
                    path,
                    amount,
                    bestAmount
                );
                if (best) {
                    bestAmount = expectedAmount;
                    bestPath = path;
                }
            }
        }

        uint256 bestRate = 0;

        if (bestAmount == Constants.MAX_INT) {
            bestAmount = 0;
        }

        if (bestAmount != 0 && amount != 0) {
            bestRate = swapType == Constants.EXACT_INPUT
                ? Constants.WAD.mul(amount).div(bestAmount)
                : Constants.WAD.mul(bestAmount).div(amount);
        }

        return
            TradePath({
                rate: bestRate,
                path: bestPath,
                expectedAmount: bestAmount
            });
    }

    function _getAmountsUni(
        uint256 swapInterface,
        address router,
        uint256 swapType,
        address[] memory path,
        uint256 amount,
        uint256 bestAmount
    ) internal returns (uint256, bool) {
        return
            swapInterface == Constants.UNISWAP_V2
                ? _getAmountsV2(
                    IUniswapV2Router02(router),
                    swapType,
                    path,
                    amount,
                    bestAmount
                )
                : _getAmountsV3(
                    IQuoter(router),
                    swapType,
                    path,
                    amount,
                    bestAmount
                );
    }

    function _getAmountsV2(
        IUniswapV2Router02 router,
        uint256 swapType,
        address[] memory path,
        uint256 amount,
        uint256 bestAmount
    ) internal view returns (uint256, bool) {
        uint256 expectedAmount;

        if (swapType == Constants.EXACT_INPUT) {
            try router.getAmountsOut(amount, path) returns (
                uint256[] memory amountsOut
            ) {
                expectedAmount = amountsOut[path.length - 1];
            } catch {
                return (bestAmount, false);
            }
        } else if (swapType == Constants.EXACT_OUTPUT) {
            try router.getAmountsIn(amount, path) returns (
                uint256[] memory amountsIn
            ) {
                expectedAmount = amountsIn[0];
            } catch {
                return (bestAmount, false);
            }
        } else {
            revert("Unknown swap type");
        }

        if (
            (swapType == Constants.EXACT_INPUT &&
                expectedAmount > bestAmount) ||
            (swapType == Constants.EXACT_OUTPUT && expectedAmount < bestAmount)
        ) {
            return (expectedAmount, true);
        }

        return (bestAmount, false);
    }

    function _getAmountsV3(
        IQuoter quoter,
        uint256 swapType,
        address[] memory path,
        uint256 amount,
        uint256 bestAmount
    ) internal returns (uint256, bool) {
        uint256 expectedAmount;

        if (swapType == Constants.EXACT_INPUT) {
            try
                quoter.quoteExactInput(
                    convertPathToPathV3(path, swapType),
                    amount
                )
            returns (uint256 amountOut) {
                expectedAmount = amountOut;
            } catch {
                return (bestAmount, false);
            }
        } else if (swapType == Constants.EXACT_OUTPUT) {
            try
                quoter.quoteExactOutput(
                    convertPathToPathV3(path, swapType),
                    amount
                )
            returns (uint256 amountIn) {
                expectedAmount = amountIn;
            } catch {
                return (bestAmount, false);
            }
        } else {
            revert("Unknown swap type");
        }

        if (
            (swapType == Constants.EXACT_INPUT &&
                expectedAmount > bestAmount) ||
            (swapType == Constants.EXACT_OUTPUT && expectedAmount < bestAmount)
        ) {
            return (expectedAmount, true);
        }

        return (bestAmount, false);
    }

    function convertPathToPathV3(address[] memory path, uint256 swapType)
        public
        pure
        returns (bytes memory result)
    {
        uint24 fee = 3000;

        if (swapType == Constants.EXACT_INPUT) {
            for (uint256 i = 0; i < path.length.sub(1); i++) {
                result = result.concat(abi.encodePacked(path[i], fee));
            }
            result = result.concat(abi.encodePacked(path[path.length - 1]));
        } else {
            for (uint256 i = path.length.sub(1); i > 0; i--) {
                result = result.concat(abi.encodePacked(path[i], fee));
            }
            result = result.concat(abi.encodePacked(path[0]));
        }
    }

    function getClosurePaths(
        address router,
        address _creditManager,
        address borrower,
        address[] memory connectorTokens
    )
        external
        registeredCreditManagerOnly(_creditManager)
        returns (TradePath[] memory result)
    {
        ICreditFilter creditFilter = ICreditFilter(
            ICreditManager(_creditManager).creditFilter()
        );
        result = new TradePath[](creditFilter.allowedTokensCount());

        address creditAccount = ICreditManager(_creditManager)
        .getCreditAccountOrRevert(borrower);
        address underlyingToken = creditFilter.underlyingToken();

        for (uint256 i = 0; i < creditFilter.allowedTokensCount(); i++) {
            (address token, uint256 balance, , ) = creditFilter
            .getCreditAccountTokenById(creditAccount, i);

            if (i == 0) {
                result[0] = TradePath({
                    path: new address[](3),
                    rate: Constants.WAD,
                    expectedAmount: balance
                });
            } else {
                result[i] = bestUniPath(
                    Constants.UNISWAP_V2,
                    router,
                    Constants.EXACT_INPUT,
                    token,
                    underlyingToken,
                    balance,
                    connectorTokens
                );
            }
        }
    }

    function getPrices(address[] calldata tokens)
        external
        view
        returns (uint256[] memory prices)
    {
        (
            ,
            int256 ethPrice, //uint startedAt, //uint timeStamp, //uint80 answeredInRound
            ,
            ,

        ) = AggregatorV3Interface(ethToUsdPriceFeed).latestRoundData();
        prices = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 decimals = ERC20(tokens[i]).decimals();
            prices[i] = priceOracle
            .convert(10**decimals, tokens[i], wethToken)
            .mul(uint256(ethPrice))
            .div(Constants.WAD);
        }
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3SwapCallback {
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}// GPL-2.0-or-later
pragma solidity >=0.7.5;


interface ISwapRouter  {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}// GPL-2.0-or-later
pragma solidity ^0.7.4;


library DataTypes {
    struct Exchange {
        address[] path;
        uint256 amountOutMin;
    }

    struct TokenBalance {
        address token;
        uint256 balance;
        bool isAllowed;
    }

    struct ContractAdapter {
        address allowedContract;
        address adapter;
    }

    struct CreditAccountData {
        address addr;
        address borrower;
        bool inUse;
        address creditManager;
        address underlyingToken;
        uint256 borrowedAmountPlusInterest;
        uint256 totalValue;
        uint256 healthFactor;
        uint256 borrowRate;
        TokenBalance[] balances;
    }

    struct CreditAccountDataExtended {
        address addr;
        address borrower;
        bool inUse;
        address creditManager;
        address underlyingToken;
        uint256 borrowedAmountPlusInterest;
        uint256 totalValue;
        uint256 healthFactor;
        uint256 borrowRate;
        TokenBalance[] balances;
        uint256 repayAmount;
        uint256 liquidationAmount;
        bool canBeClosed;
        uint256 borrowedAmount;
        uint256 cumulativeIndexAtOpen;
        uint256 since;
    }

    struct CreditManagerData {
        address addr;
        bool hasAccount;
        address underlyingToken;
        bool isWETH;
        bool canBorrow;
        uint256 borrowRate;
        uint256 minAmount;
        uint256 maxAmount;
        uint256 maxLeverageFactor;
        uint256 availableLiquidity;
        address[] allowedTokens;
        ContractAdapter[] adapters;
    }

    struct PoolData {
        address addr;
        bool isWETH;
        address underlyingToken;
        address dieselToken;
        uint256 linearCumulativeIndex;
        uint256 availableLiquidity;
        uint256 expectedLiquidity;
        uint256 expectedLiquidityLimit;
        uint256 totalBorrowed;
        uint256 depositAPY_RAY;
        uint256 borrowAPY_RAY;
        uint256 dieselRate_RAY;
        uint256 withdrawFee;
        uint256 cumulativeIndex_RAY;
        uint256 timestampLU;
    }

    struct TokenInfo {
        address addr;
        string symbol;
        uint8 decimals;
    }

    struct AddressProviderData {
        address contractRegister;
        address acl;
        address priceOracle;
        address traderAccountFactory;
        address dataCompressor;
        address farmingFactory;
        address accountMiner;
        address treasuryContract;
        address gearToken;
        address wethToken;
        address wethGateway;
    }

    struct MiningApproval {
        address token;
        address swapContract;
    }
}