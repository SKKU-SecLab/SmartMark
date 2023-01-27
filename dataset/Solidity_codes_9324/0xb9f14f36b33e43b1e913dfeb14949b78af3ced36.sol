
pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


interface IWETH9 is IERC20 {

    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    function deposit() external payable;

    function withdraw(uint wad) external;

}// GPL-2.0-or-later

pragma solidity >=0.8.6;




interface IUniswapV3PoolImmutables {

    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function fee() external view returns (uint24);


    function tickSpacing() external view returns (int24);


    function maxLiquidityPerTick() external view returns (uint128);

}



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

}



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

}



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

}



interface IUniswapV3PoolOwnerActions {

    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;


    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

}



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
}








interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{


}



interface IUniswapV3FlashCallback {

    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external;

}


interface IPeripheryPayments {

    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;


    function refundETH() external payable;


    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;

}



library TransferHelper {

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}



interface IPeripheryImmutableState {

    function factory() external view returns (address);


    function WETH9() external view returns (address);

}



abstract contract PeripheryImmutableState is IPeripheryImmutableState {
    address public immutable override factory;
    address public immutable override WETH9;

    constructor(address _factory, address _WETH9) {
        factory = _factory;
        WETH9 = _WETH9;
    }
}




abstract contract PeripheryPayments is IPeripheryPayments, PeripheryImmutableState {
    receive() external payable {
        require(msg.sender == WETH9, 'Not WETH9');
    }

    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable override {
        uint256 balanceWETH9 = IWETH9(WETH9).balanceOf(address(this));
        require(balanceWETH9 >= amountMinimum, 'Insufficient WETH9');

        if (balanceWETH9 > 0) {
            IWETH9(WETH9).withdraw(balanceWETH9);
            TransferHelper.safeTransferETH(recipient, balanceWETH9);
        }
    }

    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable override {
        uint256 balanceToken = IERC20(token).balanceOf(address(this));
        require(balanceToken >= amountMinimum, 'Insufficient token');

        if (balanceToken > 0) {
            TransferHelper.safeTransfer(token, recipient, balanceToken);
        }
    }

    function refundETH() external payable override {
        if (address(this).balance > 0) TransferHelper.safeTransferETH(msg.sender, address(this).balance);
    }

    function pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == WETH9 && address(this).balance >= value) {
            IWETH9(WETH9).deposit{value: value}(); // wrap only what is needed to pay
            IWETH9(WETH9).transfer(recipient, value);
        } else if (payer == address(this)) {
            TransferHelper.safeTransfer(token, recipient, value);
        } else {
            TransferHelper.safeTransferFrom(token, payer, recipient, value);
        }
    }
}



interface IUniswapV3SwapCallback {

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;

}



// pragma abicoder v2;

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

}









library CallbackValidation {

    function verifyCallback(
        address factory,
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal view returns (IUniswapV3Pool pool) {

        return verifyCallback(factory, PoolAddress.getPoolKey(tokenA, tokenB, fee));
    }

    function verifyCallback(address factory, PoolAddress.PoolKey memory poolKey)
        internal
        view
        returns (IUniswapV3Pool pool)
    {

        pool = IUniswapV3Pool(PoolAddress.computeAddress(factory, poolKey));
        require(msg.sender == address(pool));
    }
}

library PoolAddress {

    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {

        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {

        require(key.token0 < key.token1);
        pool = address(
            uint160(uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            ))
        );
    }
}// GPL-2.0-or-later

pragma solidity >=0.8.6;


library DataTypes {

    struct Series {
        IFYToken fyToken;                                               // Redeemable token for the series.
        bytes6  baseId;                                                 // Asset received on redemption.
        uint32  maturity;                                               // Unix time at which redemption becomes possible.
    }

    struct Vault {
        address owner;
        bytes6  seriesId;                                                // Each vault is related to only one series, which also determines the underlying.
        bytes6  ilkId;                                                   // Asset accepted as collateral
    }

    struct Balances {
        uint128 art;                                                     // Debt amount
        uint128 ink;                                                     // Collateral amount
    }
}

interface IJoin { }


interface IFYToken { }


interface ILadle {

    function joins(bytes6) external view returns (IJoin);

}

interface IWitch {

    function payAll(bytes12 vaultId, uint128 min) external returns (uint256 ink);


    function ladle() external returns (ILadle);


    function cauldron() external returns (ICauldron);


    function auctions(bytes12 vaultId) external returns (address owner, uint32 start);


    function ilks(bytes6 ilkId) external returns (bool initialized, uint32 duration, uint64 initialOffer, uint128 dust);

}

interface ICauldron {

    function vaults(bytes12 vault) external view returns (DataTypes.Vault memory);


    function series(bytes6 seriesId) external view returns (DataTypes.Series memory);


    function assets(bytes6 assetsId) external view returns (address);


    function balances(bytes12 vault) external view returns (DataTypes.Balances memory);


    function spotOracles(bytes6 baseId, bytes6 ilkId) external returns (address oracle, uint32 ratio);


    function level(bytes12 vaultId) external returns (int256);


    function debtToBase(bytes6 seriesId, uint128 art) external returns (uint128 base);

}// GPL-2.0-or-later

pragma solidity >=0.8.6;



contract FlashLiquidator is IUniswapV3FlashCallback, PeripheryImmutableState, PeripheryPayments {

    using TransferHelper for address;

    ISwapRouter public immutable swapRouter;
    IWitch public immutable witch;
    ICauldron public immutable cauldron;
    address public immutable recipient;

    struct FlashCallbackData {
        bytes12 vaultId;
        address base;
        address collateral;
        uint256 baseLoan;
        address baseJoin;
        PoolAddress.PoolKey poolKey;
    }

    constructor(
        address _recipient,
        ISwapRouter _swapRouter,
        address _factory,
        address _WETH9,
        IWitch _witch
    ) PeripheryImmutableState(_factory, _WETH9) {
        swapRouter = _swapRouter;
        witch = _witch;
        cauldron = _witch.cauldron();
        recipient = _recipient;
    }

    function collateralToDebtRatio(bytes12 vaultId, bytes6 seriesId, bytes6 baseId, bytes6 ilkId, uint128 art) public 
    returns (uint256) {

        if (art == 0) {
            return 0;
        }
        int256 level = cauldron.level(vaultId);
        uint128 accrued_debt = cauldron.debtToBase(seriesId, art);
        (, uint32 ratio_u32) = cauldron.spotOracles(baseId, ilkId);

        level = (level * 1e18 / int256(int128(accrued_debt))) + int256(uint256(ratio_u32)) * 1e12;
        require(level >= 0, "level is negative");
        return uint256(level);
    }

    function isAtMinimalPrice(bytes12 vaultId, bytes6 ilkId) public returns (bool) {

        (, uint32 auction_start) = witch.auctions(vaultId);
        (, uint32 duration, , ) = witch.ilks(ilkId);
        uint256 elapsed = uint32(block.timestamp) - auction_start;
        return elapsed >= duration;
    }

    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external override {

        require(fee0 == 0 || fee1 == 0, 'fee0 == 0 || fee1 == 0');
        uint256 fee = fee0 + fee1;

        FlashCallbackData memory decoded = abi.decode(data, (FlashCallbackData));
        CallbackValidation.verifyCallback(factory, decoded.poolKey);

        decoded.base.safeApprove(decoded.baseJoin, decoded.baseLoan);
        uint256 collateralReceived = witch.payAll(decoded.vaultId, 0);     

        uint256 debtToReturn = decoded.baseLoan + fee;
        decoded.collateral.safeApprove(address(swapRouter), collateralReceived);
        uint256 debtRecovered = swapRouter.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: decoded.collateral,
                tokenOut: decoded.base,
                fee: 500,  // can't use the same fee as the flash loan
                recipient: address(this),
                deadline: block.timestamp + 180,
                amountIn: collateralReceived,
                amountOutMinimum: debtToReturn,
                sqrtPriceLimitX96: 0
            })
        );

        if (debtRecovered > debtToReturn) {
            uint256 profit = debtRecovered - debtToReturn;
            decoded.base.safeApprove(address(this), profit);
            pay(decoded.base, address(this), recipient, profit);
        }

        decoded.base.safeApprove(address(this), debtToReturn); // TODO: Does this do anything?
        pay(decoded.base, address(this), msg.sender, debtToReturn);
    }

    function liquidate(bytes12 vaultId) external {

        uint24 poolFee = 3000; // 0.3%

        DataTypes.Vault memory vault = cauldron.vaults(vaultId);
        DataTypes.Balances memory balances = cauldron.balances(vaultId);
        DataTypes.Series memory series = cauldron.series(vault.seriesId);
        address base = cauldron.assets(series.baseId);
        address collateral = cauldron.assets(vault.ilkId);
		uint128 baseLoan = cauldron.debtToBase(vault.seriesId, uint128(balances.art));

        bool ordered = (collateral < base);
        PoolAddress.PoolKey memory poolKey = PoolAddress.PoolKey({
            token0: ordered ? collateral : base,
            token1: ordered ? base : collateral,
            fee: poolFee
        });
        IUniswapV3Pool pool = IUniswapV3Pool(PoolAddress.computeAddress(factory, poolKey));

        FlashCallbackData memory args = FlashCallbackData({
            vaultId: vaultId,
            base: base,
            collateral: collateral,
            baseLoan: baseLoan,
            baseJoin: address(witch.ladle().joins(series.baseId)),
            poolKey: poolKey
        });

        pool.flash(
            address(this),
            ordered ? 0 : baseLoan,
            ordered ? baseLoan : 0,
            abi.encode(
                args
            )
        );
    }
}