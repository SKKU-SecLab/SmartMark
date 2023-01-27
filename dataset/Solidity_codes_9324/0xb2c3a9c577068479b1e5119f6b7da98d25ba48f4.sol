
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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// GPL-3.0

pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

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
pragma abicoder v2;


interface ISwapRouter is IUniswapV3SwapCallback {

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

}// MIXED
pragma solidity 0.8.10;



contract BoringOwnableData {

    address public owner;
    address public pendingOwner;
}

contract BoringOwnable is BoringOwnableData {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function transferOwnership(
        address newOwner,
        bool direct,
        bool renounce
    ) public onlyOwner {

        if (direct) {
            require(newOwner != address(0) || renounce, "Ownable: zero address");

            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            pendingOwner = address(0);
        } else {
            pendingOwner = newOwner;
        }
    }

    function claimOwnership() public {

        address _pendingOwner = pendingOwner;

        require(msg.sender == _pendingOwner, "Ownable: caller != pending owner");

        emit OwnershipTransferred(owner, _pendingOwner);
        owner = _pendingOwner;
        pendingOwner = address(0);
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
}

interface IBentoBoxV1 {

    function balanceOf(IERC20 token, address user) external view returns (uint256 share);


    function deposit(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);


    function toAmount(
        IERC20 token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount);


    function toShare(
        IERC20 token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);


    function transfer(
        IERC20 token,
        address from,
        address to,
        uint256 share
    ) external;


    function withdraw(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);

}


interface Cauldron {

    function accrue() external;


    function withdrawFees() external;


    function accrueInfo()
        external
        view
        returns (
            uint64,
            uint128,
            uint64
        );


    function bentoBox() external returns (address);


    function setFeeTo(address newFeeTo) external;


    function feeTo() external returns (address);


    function masterContract() external returns (Cauldron);

}

interface CauldronV1 {

    function accrue() external;


    function withdrawFees() external;


    function accrueInfo() external view returns (uint64, uint128);


    function setFeeTo(address newFeeTo) external;


    function feeTo() external returns (address);


    function masterContract() external returns (CauldronV1);

}

interface AnyswapRouter {

    function anySwapOutUnderlying(
        address token,
        address to,
        uint256 amount,
        uint256 toChainID
    ) external;

}

interface CurvePool {

    function exchange(
        uint256 i,
        uint256 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address receiver
    ) external returns (uint256);

}

contract EthereumWithdrawer is BoringOwnable {

    using SafeERC20 for IERC20;

    event SwappedMimToSpell(uint256 amountSushiswap, uint256 amountUniswap, uint256 total);
    event MimWithdrawn(uint256 bentoxBoxAmount, uint256 degenBoxAmount, uint256 total);

    bytes4 private constant SIG_TRANSFER = 0xa9059cbb; // transfer(address,uint256)
    CurvePool public constant MIM3POOL = CurvePool(0x5a6A4D54456819380173272A5E8E9B9904BdF41B);
    CurvePool public constant THREECRYPTO = CurvePool(0xD51a44d3FaE010294C616388b506AcdA1bfAAE46);
    IBentoBoxV1 public constant BENTOBOX = IBentoBoxV1(0xF5BCE5077908a1b7370B9ae04AdC565EBd643966);
    IBentoBoxV1 public constant DEGENBOX = IBentoBoxV1(0xd96f48665a1410C0cd669A88898ecA36B9Fc2cce);

    IERC20 public constant MIM = IERC20(0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3);
    IERC20 public constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 public constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    address public constant SPELL = 0x090185f2135308BaD17527004364eBcC2D37e5F6;
    address public constant sSPELL = 0x26FA3fFFB6EfE8c1E69103aCb4044C26B9A106a9;

    address public constant MIM_PROVIDER = 0x5f0DeE98360d8200b20812e174d139A1a633EDd2;
    address public constant TREASURY = 0x5A7C5505f3CFB9a0D9A8493EC41bf27EE48c406D;

    IUniswapV2Pair private constant SUSHI_SPELL_WETH = IUniswapV2Pair(0xb5De0C3753b6E1B4dBA616Db82767F17513E6d4E);

    ISwapRouter private constant SWAPROUTER = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    CauldronV1[] public bentoBoxCauldronsV1;
    Cauldron[] public bentoBoxCauldronsV2;
    Cauldron[] public degenBoxCauldrons;

    uint256 public treasuryShare;

    mapping(address => bool) public verified;

    constructor(
        Cauldron[] memory bentoBoxCauldronsV2_,
        CauldronV1[] memory bentoBoxCauldronsV1_,
        Cauldron[] memory degenBoxCauldrons_
    ) {
        bentoBoxCauldronsV2 = bentoBoxCauldronsV2_;
        bentoBoxCauldronsV1 = bentoBoxCauldronsV1_;
        degenBoxCauldrons = degenBoxCauldrons_;

        MIM.approve(address(MIM3POOL), type(uint256).max);
        WETH.approve(address(SWAPROUTER), type(uint256).max);
        USDT.safeApprove(address(THREECRYPTO), type(uint256).max);
        verified[msg.sender] = true;
        treasuryShare = 25;
    }

    modifier onlyVerified() {

        require(verified[msg.sender], "Only verified operators");
        _;
    }

    function withdraw() public {

        uint256 length = bentoBoxCauldronsV2.length;
        for (uint256 i = 0; i < length; i++) {
            require(bentoBoxCauldronsV2[i].masterContract().feeTo() == address(this), "wrong feeTo");

            bentoBoxCauldronsV2[i].accrue();
            (, uint256 feesEarned, ) = bentoBoxCauldronsV2[i].accrueInfo();
            if (feesEarned > (BENTOBOX.toAmount(MIM, BENTOBOX.balanceOf(MIM, address(bentoBoxCauldronsV2[i])), false))) {
                MIM.transferFrom(MIM_PROVIDER, address(BENTOBOX), feesEarned);
                BENTOBOX.deposit(MIM, address(BENTOBOX), address(bentoBoxCauldronsV2[i]), feesEarned, 0);
            }

            bentoBoxCauldronsV2[i].withdrawFees();
        }

        length = bentoBoxCauldronsV1.length;
        for (uint256 i = 0; i < length; i++) {
            require(bentoBoxCauldronsV1[i].masterContract().feeTo() == address(this), "wrong feeTo");

            bentoBoxCauldronsV1[i].accrue();
            (, uint256 feesEarned) = bentoBoxCauldronsV1[i].accrueInfo();
            if (feesEarned > (BENTOBOX.toAmount(MIM, BENTOBOX.balanceOf(MIM, address(bentoBoxCauldronsV1[i])), false))) {
                MIM.transferFrom(MIM_PROVIDER, address(BENTOBOX), feesEarned);
                BENTOBOX.deposit(MIM, address(BENTOBOX), address(bentoBoxCauldronsV1[i]), feesEarned, 0);
            }
            bentoBoxCauldronsV1[i].withdrawFees();
        }

        length = degenBoxCauldrons.length;
        for (uint256 i = 0; i < length; i++) {
            require(degenBoxCauldrons[i].masterContract().feeTo() == address(this), "wrong feeTo");

            degenBoxCauldrons[i].accrue();
            (, uint256 feesEarned, ) = degenBoxCauldrons[i].accrueInfo();
            if (feesEarned > (DEGENBOX.toAmount(MIM, DEGENBOX.balanceOf(MIM, address(degenBoxCauldrons[i])), false))) {
                MIM.transferFrom(MIM_PROVIDER, address(DEGENBOX), feesEarned);
                DEGENBOX.deposit(MIM, address(DEGENBOX), address(degenBoxCauldrons[i]), feesEarned, 0);
            }
            degenBoxCauldrons[i].withdrawFees();
        }

        uint256 mimFromBentoBoxShare = BENTOBOX.balanceOf(MIM, address(this));
        uint256 mimFromDegenBoxShare = DEGENBOX.balanceOf(MIM, address(this));
        withdrawFromBentoBoxes(mimFromBentoBoxShare, mimFromDegenBoxShare);

        uint256 mimFromBentoBox = BENTOBOX.toAmount(MIM, mimFromBentoBoxShare, false);
        uint256 mimFromDegenBox = DEGENBOX.toAmount(MIM, mimFromDegenBoxShare, false);
        emit MimWithdrawn(mimFromBentoBox, mimFromDegenBox, mimFromBentoBox + mimFromDegenBox);
    }

    function withdrawFromBentoBoxes(uint256 amountBentoboxShare, uint256 amountDegenBoxShare) public {

        BENTOBOX.withdraw(MIM, address(this), address(this), 0, amountBentoboxShare);
        DEGENBOX.withdraw(MIM, address(this), address(this), 0, amountDegenBoxShare);
    }

    function rescueTokens(
        IERC20 token,
        address to,
        uint256 amount
    ) external onlyOwner {

        token.safeTransfer(to, amount);
    }

    function setTreasuryShare(uint256 share) external onlyOwner {

        treasuryShare = share;
    }

    function swapMimForSpell(
        uint256 amountSwapOnSushi,
        uint256 amountSwapOnUniswap,
        uint256 minAmountOutOnSushi,
        uint256 minAmountOutOnUniswap,
        bool autoDepositToSSpell
    ) external onlyVerified {

        require(amountSwapOnSushi > 0 || amountSwapOnUniswap > 0, "nothing to swap");

        address recipient = autoDepositToSSpell ? sSPELL : address(this);
        uint256 minAmountToSwap = _getAmountToSwap(amountSwapOnSushi + amountSwapOnUniswap);
        uint256 amountUSDT = MIM3POOL.exchange_underlying(0, 3, minAmountToSwap, 0, address(this));
        THREECRYPTO.exchange(0, 2, amountUSDT, 0);

        uint256 amountWETH = WETH.balanceOf(address(this));
        uint256 percentSushi = (amountSwapOnSushi * 100) / (amountSwapOnSushi + amountSwapOnUniswap);
        uint256 amountWETHSwapOnSushi = (amountWETH * percentSushi) / 100;
        uint256 amountWETHSwapOnUniswap = amountWETH - amountWETHSwapOnSushi;
        uint256 amountSpellOnSushi;
        uint256 amountSpellOnUniswap;

        if (amountSwapOnSushi > 0) {
            amountSpellOnSushi = _swapOnSushiswap(amountWETHSwapOnSushi, minAmountOutOnSushi, recipient);
        }

        if (amountSwapOnUniswap > 0) {
            amountSpellOnUniswap = _swapOnUniswap(amountWETHSwapOnUniswap, minAmountOutOnUniswap, recipient);
        }

        emit SwappedMimToSpell(amountSpellOnSushi, amountSpellOnUniswap, amountSpellOnSushi + amountSpellOnUniswap);
    }

    function swapMimForSpell1Inch(address inchrouter, bytes calldata data) external onlyOwner {

        MIM.approve(inchrouter, type(uint256).max);
        (bool success, ) = inchrouter.call(data);
        require(success, "1inch swap unsucessful");
        IERC20(SPELL).safeTransfer(address(sSPELL), IERC20(SPELL).balanceOf(address(this)));
        MIM.approve(inchrouter, 0);
    }

    function setVerified(address operator, bool status) external onlyOwner {

        verified[operator] = status;
    }

    function addPool(Cauldron pool) external onlyOwner {

        _addPool(pool);
    }

    function addPoolV1(CauldronV1 pool) external onlyOwner {

        bentoBoxCauldronsV1.push(pool);
    }

    function addPools(Cauldron[] memory pools) external onlyOwner {

        for (uint256 i = 0; i < pools.length; i++) {
            _addPool(pools[i]);
        }
    }

    function _addPool(Cauldron pool) internal onlyOwner {

        require(address(pool) != address(0), "invalid cauldron");

        if (pool.bentoBox() == address(BENTOBOX)) {
            for (uint256 i = 0; i < bentoBoxCauldronsV2.length; i++) {
                require(bentoBoxCauldronsV2[i] != pool, "already added");
            }
            bentoBoxCauldronsV2.push(pool);
        } else if (pool.bentoBox() == address(DEGENBOX)) {
            for (uint256 i = 0; i < degenBoxCauldrons.length; i++) {
                require(degenBoxCauldrons[i] != pool, "already added");
            }
            degenBoxCauldrons.push(pool);
        }
    }

    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) private pure returns (uint256 amountOut) {

        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function _swapOnSushiswap(
        uint256 amountWETH,
        uint256 minAmountSpellOut,
        address recipient
    ) private returns (uint256) {

        (uint256 reserve0, uint256 reserve1, ) = SUSHI_SPELL_WETH.getReserves();
        uint256 amountSpellOut = _getAmountOut(amountWETH, reserve1, reserve0);

        require(amountSpellOut >= minAmountSpellOut, "Too little received");

        WETH.transfer(address(SUSHI_SPELL_WETH), amountWETH);
        SUSHI_SPELL_WETH.swap(amountSpellOut, 0, recipient, "");

        return amountSpellOut;
    }

    function _swapOnUniswap(
        uint256 amountWETH,
        uint256 minAmountSpellOut,
        address recipient
    ) private returns (uint256) {

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: address(WETH),
            tokenOut: SPELL,
            fee: 3000,
            recipient: recipient,
            deadline: block.timestamp,
            amountIn: amountWETH,
            amountOutMinimum: minAmountSpellOut,
            sqrtPriceLimitX96: 0
        });

        uint256 amountOut = SWAPROUTER.exactInputSingle(params);
        return amountOut;
    }

    function _getAmountToSwap(uint256 amount) private returns (uint256) {

        uint256 treasuryShareAmount = (amount * treasuryShare) / 100;
        MIM.transfer(TREASURY, treasuryShareAmount);
        return amount - treasuryShareAmount;
    }
}