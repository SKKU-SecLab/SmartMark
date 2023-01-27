
pragma solidity ^0.8.0;

interface IBalancer {

    function isBound(address t) external view returns (bool);


    function getDenormalizedWeight(address token)
        external
        view
        returns (uint256);


    function getBalance(address token) external view returns (uint256);


    function getSwapFee() external view returns (uint256);


    function calcOutGivenIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountIn,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountOut);


    function calcInGivenOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountOut,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountIn);

}// Apache-2.0

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


contract BalancerSampler {

    uint256 private constant BALANCER_CALL_GAS = 300e3; // 300k

    uint256 private constant BONE = 10**18;
    uint256 private constant MAX_IN_RATIO = BONE / 2;
    uint256 private constant MAX_OUT_RATIO = (BONE / 3) + 1 wei;

    struct BalancerState {
        uint256 takerTokenBalance;
        uint256 makerTokenBalance;
        uint256 takerTokenWeight;
        uint256 makerTokenWeight;
        uint256 swapFee;
    }

    function sampleSellsFromBalancer(
        address poolAddress,
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    ) public view returns (uint256[] memory makerTokenAmounts) {

        IBalancer pool = IBalancer(poolAddress);
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        if (!pool.isBound(takerToken) || !pool.isBound(makerToken)) {
            return makerTokenAmounts;
        }

        BalancerState memory poolState;
        poolState.takerTokenBalance = pool.getBalance(takerToken);
        poolState.makerTokenBalance = pool.getBalance(makerToken);
        poolState.takerTokenWeight = pool.getDenormalizedWeight(takerToken);
        poolState.makerTokenWeight = pool.getDenormalizedWeight(makerToken);
        poolState.swapFee = pool.getSwapFee();

        for (uint256 i = 0; i < numSamples; i++) {
            if (
                takerTokenAmounts[i] >
                _bmul(poolState.takerTokenBalance, MAX_IN_RATIO)
            ) {
                break;
            }
            try
                pool.calcOutGivenIn{gas: BALANCER_CALL_GAS}(
                    poolState.takerTokenBalance,
                    poolState.takerTokenWeight,
                    poolState.makerTokenBalance,
                    poolState.makerTokenWeight,
                    takerTokenAmounts[i],
                    poolState.swapFee
                )
            returns (uint256 amount) {
                makerTokenAmounts[i] = amount;
                if (makerTokenAmounts[i] == 0) {
                    break;
                }
            } catch (bytes memory) {
                break;
            }
        }
    }

    function _bmul(uint256 a, uint256 b) private pure returns (uint256 c) {

        uint256 c0 = a * b;
        if (a != 0 && c0 / a != b) {
            return 0;
        }
        uint256 c1 = c0 + (BONE / 2);
        if (c1 < c0) {
            return 0;
        }
        uint256 c2 = c1 / BONE;
        return c2;
    }
}// Apache-2.0

pragma solidity ^0.8.0;

interface IBalancerV2Vault {

    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }

    struct BatchSwapStep {
        bytes32 poolId;
        uint256 assetInIndex;
        uint256 assetOutIndex;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function queryBatchSwap(
        SwapKind kind,
        BatchSwapStep[] calldata swaps,
        IAsset[] calldata assets,
        FundManagement calldata funds
    ) external returns (int256[] memory assetDeltas);

}

interface IAsset {

}

interface IPool {

    function getPoolId() external view returns (bytes32);

}

contract BalancerV2Sampler {

    struct BalancerV2PoolInfo {
        address pool;
        address vault;
    }

    function sampleSellsFromBalancerV2(
        BalancerV2PoolInfo memory poolInfo,
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    ) public returns (uint256[] memory makerTokenAmounts) {

        IBalancerV2Vault vault = IBalancerV2Vault(poolInfo.vault);
        IAsset[] memory swapAssets = new IAsset[](2);
        swapAssets[0] = IAsset(takerToken);
        swapAssets[1] = IAsset(makerToken);

        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        IBalancerV2Vault.FundManagement memory swapFunds = createSwapFunds();

        for (uint256 i = 0; i < numSamples; i++) {
            IBalancerV2Vault.BatchSwapStep[] memory swapSteps = createSwapSteps(
                poolInfo,
                takerTokenAmounts[i]
            );

            try
                vault.queryBatchSwap(
                    IBalancerV2Vault.SwapKind.GIVEN_IN,
                    swapSteps,
                    swapAssets,
                    swapFunds
                )
            returns (
                int256[] memory amounts
            ) {
                int256 amountOutFromPool = amounts[1] * -1;
                if (amountOutFromPool <= 0) {
                    break;
                }
                makerTokenAmounts[i] = uint256(amountOutFromPool);
            } catch (bytes memory) {
                break;
            }
        }
    }

    function createSwapSteps(BalancerV2PoolInfo memory poolInfo, uint256 amount)
        private
        view
        returns (IBalancerV2Vault.BatchSwapStep[] memory)
    {

        IBalancerV2Vault.BatchSwapStep[]
            memory swapSteps = new IBalancerV2Vault.BatchSwapStep[](1);

        bytes32 poolId = IPool(poolInfo.pool).getPoolId();
        swapSteps[0] = IBalancerV2Vault.BatchSwapStep({
            poolId: poolId,
            assetInIndex: 0,
            assetOutIndex: 1,
            amount: amount,
            userData: ""
        });

        return swapSteps;
    }

    function createSwapFunds()
        private
        view
        returns (IBalancerV2Vault.FundManagement memory)
    {

        return
            IBalancerV2Vault.FundManagement({
                sender: address(this),
                fromInternalBalance: false,
                recipient: payable(address(this)),
                toInternalBalance: false
            });
    }
}// Apache-2.0

pragma solidity ^0.8.0;

interface ICurve {

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 sellAmount,
        uint256 minBuyAmount
    ) external;


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 sellAmount
    ) external returns (uint256 dy);


    function get_dx_underlying(
        int128 i,
        int128 j,
        uint256 buyAmount
    ) external returns (uint256 dx);


    function underlying_coins(int128 i) external returns (address tokenAddress);

}// Apache-2.0

pragma solidity ^0.8.0;


interface CurvePool {

    function get_dy_underlying(
        int128,
        int128,
        uint256
    ) external view returns (uint256);


    function get_dy(
        int128,
        int128,
        uint256
    ) external view returns (uint256);

}

interface CryptoPool {

    function get_dy_underlying(
        uint256,
        uint256,
        uint256
    ) external view returns (uint256);


    function get_dy(
        uint256,
        uint256,
        uint256
    ) external view returns (uint256);

}

interface CryptoRegistry {

    function get_coin_indices(
        address pool,
        address from,
        address to
    ) external view returns (uint256, uint256);

}

interface CurveRegistry {

    function get_coin_indices(
        address pool,
        address from,
        address to
    )
        external
        view
        returns (
            int128,
            int128,
            bool
        );

}

contract CurveSampler {


    uint256 private constant CURVE_CALL_GAS = 2000e3; // Was 600k for Curve but SnowSwap is using 1500k+
    address private constant CURVE_REGISTRY =
        0x90E00ACe148ca3b23Ac1bC8C240C2a7Dd9c2d7f5;
    address private constant CURVE_FACTORY =
        0xB9fC157394Af804a3578134A6585C0dc9cc990d4;
    address private constant CRYPTO_REGISTRY =
        0x8F942C20D02bEfc377D41445793068908E2250D0;
    address private constant CRYPTO_FACTORY =
        0xF18056Bbd320E96A48e3Fbf8bC061322531aac99;

    function sampleSellsFromCurve(
        address poolAddress,
        address fromToken,
        address toToken,
        uint256[] memory takerTokenAmounts
    ) public view returns (uint256[] memory makerTokenAmounts) {

        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (
                uint256 fromTokenIdx,
                uint256 toTokenIdx,
                bool useUnderlying
            ) = getCoinIndices(poolAddress, fromToken, toToken);
            bytes4 selector;
            bytes4 selectorV2;
            if (useUnderlying) {
                selector = CurvePool.get_dy_underlying.selector;
                selectorV2 = CryptoPool.get_dy_underlying.selector;
            } else {
                selector = CurvePool.get_dy.selector;
                selectorV2 = CryptoPool.get_dy.selector;
            }
            uint256 buyAmount = 0;
            if (useUnderlying) {
                buyAmount = getBuyAmountUnderlying(
                    poolAddress,
                    fromTokenIdx,
                    toTokenIdx,
                    takerTokenAmounts[i]
                );
            } else {
                buyAmount = getBuyAmount(
                    poolAddress,
                    fromTokenIdx,
                    toTokenIdx,
                    takerTokenAmounts[i]
                );
            }

            makerTokenAmounts[i] = buyAmount;
            if (makerTokenAmounts[i] == 0) {
                break;
            }
        }
    }

    function getCoinIndices(
        address poolAddress,
        address fromToken,
        address toToken
    )
        internal
        view
        returns (
            uint256 fromTokenIdx,
            uint256 toTokenIdx,
            bool useUnderlying
        )
    {

        useUnderlying = false;
        (bool success0, bytes memory resultDatas0) = CURVE_REGISTRY.staticcall(
            abi.encodeWithSelector(
                CurveRegistry.get_coin_indices.selector,
                poolAddress,
                fromToken,
                toToken
            )
        );
        (bool success1, bytes memory resultDatas1) = CURVE_FACTORY.staticcall(
            abi.encodeWithSelector(
                CurveRegistry.get_coin_indices.selector,
                poolAddress,
                fromToken,
                toToken
            )
        );
        (bool success2, bytes memory resultDatas2) = CRYPTO_REGISTRY.staticcall(
            abi.encodeWithSelector(
                CryptoRegistry.get_coin_indices.selector,
                poolAddress,
                fromToken,
                toToken
            )
        );
        (bool success3, bytes memory resultDatas3) = CRYPTO_FACTORY.staticcall(
            abi.encodeWithSelector(
                CryptoRegistry.get_coin_indices.selector,
                poolAddress,
                fromToken,
                toToken
            )
        );
        if (success0) {
            (
                int128 _fromTokenIdx,
                int128 _toTokenIdx,
                bool _useUnderlying
            ) = abi.decode(resultDatas0, (int128, int128, bool));
            fromTokenIdx = uint256(int256(_fromTokenIdx));
            toTokenIdx = uint256(int256(_toTokenIdx));
            useUnderlying = _useUnderlying;
        } else if (success1) {
            (
                int128 _fromTokenIdx,
                int128 _toTokenIdx,
                bool _useUnderlying
            ) = abi.decode(resultDatas1, (int128, int128, bool));
            fromTokenIdx = uint256(int256(_fromTokenIdx));
            toTokenIdx = uint256(int256(_toTokenIdx));
            useUnderlying = _useUnderlying;
        } else if (success2) {
            (fromTokenIdx, toTokenIdx) = abi.decode(
                resultDatas2,
                (uint256, uint256)
            );
        } else {
            require(success3, "getCoinIndices Error");
            (fromTokenIdx, toTokenIdx) = abi.decode(
                resultDatas3,
                (uint256, uint256)
            );
        }
    }

    function getBuyAmount(
        address poolAddress,
        uint256 fromTokenIdx,
        uint256 toTokenIdx,
        uint256 sellAmount
    ) internal view returns (uint256 buyAmount) {

        try
            CryptoPool(poolAddress).get_dy(fromTokenIdx, toTokenIdx, sellAmount)
        returns (uint256 _buyAmount) {
            buyAmount = _buyAmount;
        } catch {
            int128 _fromTokenIdx = int128(int256(fromTokenIdx));
            int128 _toTokenIdx = int128(int256(toTokenIdx));
            try
                CurvePool(poolAddress).get_dy(
                    _fromTokenIdx,
                    _toTokenIdx,
                    sellAmount
                )
            returns (uint256 amount) {
                buyAmount = amount;
            } catch (bytes memory) {
                buyAmount = 0;
            }
        }
    }

    function getBuyAmountUnderlying(
        address poolAddress,
        uint256 fromTokenIdx,
        uint256 toTokenIdx,
        uint256 sellAmount
    ) internal view returns (uint256 buyAmount) {

        try
            CryptoPool(poolAddress).get_dy_underlying(
                fromTokenIdx,
                toTokenIdx,
                sellAmount
            )
        returns (uint256 _buyAmount) {
            buyAmount = _buyAmount;
        } catch {
            int128 _fromTokenIdx = int128(int256(fromTokenIdx));
            int128 _toTokenIdx = int128(int256(toTokenIdx));
            try
                CurvePool(poolAddress).get_dy_underlying(
                    _fromTokenIdx,
                    _toTokenIdx,
                    sellAmount
                )
            returns (uint256 amount) {
                buyAmount = amount;
            } catch (bytes memory) {
                buyAmount = 0;
            }
        }
    }
}// Apache-2.0

pragma solidity ^0.8.0;

interface IDODOZoo {

    function getDODO(address baseToken, address quoteToken)
        external
        view
        returns (address);

}

interface IDODOHelper {

    function querySellQuoteToken(address dodo, uint256 amount)
        external
        view
        returns (uint256);

}

interface IDODO {

    function querySellBaseToken(uint256 amount) external view returns (uint256);


    function _TRADE_ALLOWED_() external view returns (bool);


    function _BASE_TOKEN_() external view returns (address);


    function _QUOTE_TOKEN_() external view returns (address);

}

contract DODOSampler {

    uint256 private constant DODO_CALL_GAS = 300e3; // 300k
    struct DODOSamplerOpts {
        address pool;
        address helper;
    }

    function sampleSellsFromDODO(
        DODOSamplerOpts memory opts,
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    ) public view returns (uint256[] memory makerTokenAmounts) {

        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);

        if (!IDODO(opts.pool)._TRADE_ALLOWED_()) {
            return makerTokenAmounts;
        }

        bool sellBase;
        if (IDODO(opts.pool)._BASE_TOKEN_() == takerToken) {
            require(
                IDODO(opts.pool)._QUOTE_TOKEN_() == makerToken,
                "trade condition check failed"
            );
            sellBase = true;
        } else {
            require(
                IDODO(opts.pool)._QUOTE_TOKEN_() == takerToken,
                "trade condition check failed"
            );
            require(
                IDODO(opts.pool)._BASE_TOKEN_() == makerToken,
                "trade condition check failed"
            );
            sellBase = false;
        }

        for (uint256 i = 0; i < numSamples; i++) {
            if (sellBase) {
                try
                    IDODO(opts.pool).querySellBaseToken{gas: DODO_CALL_GAS}(
                        takerTokenAmounts[i]
                    )
                returns (uint256 amount) {
                    makerTokenAmounts[i] = amount;
                } catch (bytes memory) {}
            } else {
                try
                    IDODOHelper(opts.helper).querySellQuoteToken{
                        gas: DODO_CALL_GAS
                    }(opts.pool, takerTokenAmounts[i])
                returns (uint256 amount) {
                    makerTokenAmounts[i] = amount;
                } catch (bytes memory) {}
            }
            if (makerTokenAmounts[i] == 0) {
                break;
            }
        }
    }
}// Apache-2.0

pragma solidity ^0.8.0;

interface IDODOV2Registry {
    function getDODOPool(address baseToken, address quoteToken)
        external
        view
        returns (address[] memory machines);
}

interface IDODOV2Pool {
    function querySellBase(address trader, uint256 payBaseAmount)
        external
        view
        returns (uint256 receiveQuoteAmount, uint256 mtFee);

    function querySellQuote(address trader, uint256 payQuoteAmount)
        external
        view
        returns (uint256 receiveBaseAmount, uint256 mtFee);

    function _BASE_TOKEN_() external view returns (address);

    function _QUOTE_TOKEN_() external view returns (address);
}

contract DODOV2Sampler {
    uint256 private constant DODO_V2_CALL_GAS = 300e3; // 300k
    struct DODOV2SamplerOpts {
        address pool;
    }

    function sampleSellsFromDODOV2(
        DODOV2SamplerOpts memory opts,
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    ) public view returns (uint256[] memory makerTokenAmounts) {
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);

        bool sellBase;
        if (IDODOV2Pool(opts.pool)._BASE_TOKEN_() == takerToken) {
            require(
                IDODOV2Pool(opts.pool)._QUOTE_TOKEN_() == makerToken,
                "trade condition check failed"
            );
            sellBase = true;
        } else {
            require(
                IDODOV2Pool(opts.pool)._QUOTE_TOKEN_() == takerToken,
                "trade condition check failed"
            );
            require(
                IDODOV2Pool(opts.pool)._BASE_TOKEN_() == makerToken,
                "trade condition check failed"
            );
            sellBase = false;
        }

        for (uint256 i = 0; i < numSamples; i++) {
            if (sellBase) {
                try
                    IDODOV2Pool(opts.pool).querySellBase{gas: DODO_V2_CALL_GAS}(
                        address(0),
                        takerTokenAmounts[i]
                    )
                returns (uint256 amount, uint256) {
                    makerTokenAmounts[i] = amount;
                } catch (bytes memory) {}
            } else {
                try
                    IDODOV2Pool(opts.pool).querySellQuote{
                        gas: DODO_V2_CALL_GAS
                    }(address(0), takerTokenAmounts[i])
                returns (uint256 amount, uint256) {
                    makerTokenAmounts[i] = amount;
                } catch (bytes memory) {}
            }
            if (makerTokenAmounts[i] == 0) {
                break;
            }
        }
    }
}// Apache-2.0

pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}// Apache-2.0

pragma solidity ^0.8.0;


contract UniswapV2Sampler {
    uint256 private constant UNISWAPV2_CALL_GAS = 150e3; // 150k

    function sampleSellsFromUniswapV2(
        address router,
        address[] memory path,
        uint256[] memory takerTokenAmounts
    ) public view returns (uint256[] memory makerTokenAmounts) {
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            try
                IUniswapV2Router01(router).getAmountsOut{
                    gas: UNISWAPV2_CALL_GAS
                }(takerTokenAmounts[i], path)
            returns (uint256[] memory amounts) {
                makerTokenAmounts[i] = amounts[path.length - 1];
                if (makerTokenAmounts[i] == 0) {
                    break;
                }
            } catch (bytes memory) {
                break;
            }
        }
    }
}// Apache-2.0

pragma solidity ^0.8.0;

interface IUniswapV3Quoter {
    struct QuoteExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    function quoteExactInputSingle(QuoteExactInputSingleParams memory params)
        external
        returns (
            uint256 amountOut,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        );
}

interface IUniswapV3Pool {
    function fee() external view returns (uint24);
}

contract UniswapV3Sampler {
    uint256 private constant QUOTE_GAS = 300e3;
    struct UniswapV3SamplerOpts {
        IUniswapV3Quoter quoter;
        IUniswapV3Pool pool;
    }

    function sampleSellsFromUniswapV3(
        UniswapV3SamplerOpts memory opts,
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    ) public returns (uint256[] memory makerTokenAmounts) {
        makerTokenAmounts = new uint256[](takerTokenAmounts.length);

        uint24 fee = opts.pool.fee();
        for (uint256 i = 0; i < takerTokenAmounts.length; ++i) {
            try
                opts.quoter.quoteExactInputSingle{gas: QUOTE_GAS}(
                    IUniswapV3Quoter.QuoteExactInputSingleParams({
                        tokenIn: takerToken,
                        tokenOut: makerToken,
                        fee: fee,
                        amountIn: takerTokenAmounts[i],
                        sqrtPriceLimitX96: 0
                    })
                )
            returns (uint256 amount, uint160, uint32, uint256) {
                makerTokenAmounts[i] = amount;
            } catch (bytes memory) {}
            if (makerTokenAmounts[i] == 0) {
                break;
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// Apache-2.0

pragma solidity ^0.8.0;


interface IPSM {
    function tin() external view returns (uint256);

    function tout() external view returns (uint256);

    function vat() external view returns (address);

    function gemJoin() external view returns (address);

    function dai() external view returns (address);

    function sellGem(address usr, uint256 gemAmt) external;

    function buyGem(address usr, uint256 gemAmt) external;
}

interface IVAT {
    function ilks(bytes32 ilkIdentifier)
        external
        view
        returns (
            uint256 Art,
            uint256 rate,
            uint256 spot,
            uint256 line,
            uint256 dust
        );
}

contract MakerPSMSampler {
    using SafeMath for uint256;

    struct MakerPsmInfo {
        address psmAddress;
        bytes32 ilkIdentifier;
        address gemTokenAddress;
    }

    uint256 private constant MAKER_PSM_CALL_GAS = 300e3; // 300k

    uint256 private constant WAD = 10**18;
    uint256 private constant RAY = 10**27;
    uint256 private constant RAD = 10**45;


    function sampleSellsFromMakerPsm(
        MakerPsmInfo memory psmInfo,
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    ) public view returns (uint256[] memory makerTokenAmounts) {
        IPSM psm = IPSM(psmInfo.psmAddress);
        IVAT vat = IVAT(psm.vat());

        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);

        if (makerToken != psm.dai() && takerToken != psm.dai()) {
            return makerTokenAmounts;
        }

        for (uint256 i = 0; i < numSamples; i++) {
            uint256 buyAmount = _samplePSMSell(
                psmInfo,
                makerToken,
                takerToken,
                takerTokenAmounts[i],
                psm,
                vat
            );

            if (buyAmount == 0) {
                break;
            }
            makerTokenAmounts[i] = buyAmount;
        }
    }

    function _samplePSMSell(
        MakerPsmInfo memory psmInfo,
        address makerToken,
        address takerToken,
        uint256 takerTokenAmount,
        IPSM psm,
        IVAT vat
    ) private view returns (uint256) {
        (
            uint256 totalDebtInWad,
            ,
            ,
            uint256 debtCeilingInRad,
            uint256 debtFloorInRad
        ) = vat.ilks(psmInfo.ilkIdentifier);
        uint256 gemTokenBaseUnit = uint256(1e6);

        if (takerToken == psmInfo.gemTokenAddress) {
            uint256 takerTokenAmountInWad = takerTokenAmount.mul(1e12);

            uint256 newTotalDebtInRad = totalDebtInWad
                .add(takerTokenAmountInWad)
                .mul(RAY);

            if (newTotalDebtInRad >= debtCeilingInRad) {
                return 0;
            }

            uint256 feeInWad = takerTokenAmountInWad.mul(psm.tin()).div(WAD);
            uint256 makerTokenAmountInWad = takerTokenAmountInWad.sub(feeInWad);

            return makerTokenAmountInWad;
        } else if (makerToken == psmInfo.gemTokenAddress) {
            uint256 takerTokenAmountInWad = takerTokenAmount;
            if (takerTokenAmountInWad > totalDebtInWad) {
                return 0;
            }
            uint256 newTotalDebtInRad = totalDebtInWad
                .sub(takerTokenAmountInWad)
                .mul(RAY);

            if (newTotalDebtInRad <= debtFloorInRad) {
                return 0;
            }

            uint256 feeDivisorInWad = WAD.add(psm.tout()); // eg. 1.001 * 10 ** 18 with 0.1% tout;
            uint256 makerTokenAmountInGemTokenBaseUnits = takerTokenAmountInWad
                .mul(gemTokenBaseUnit)
                .div(feeDivisorInWad);

            return makerTokenAmountInGemTokenBaseUnits;
        }

        return 0;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}// MIT

pragma solidity ^0.8.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b + (a % b == 0 ? 0 : 1);
    }
}// Apache-2.0

pragma solidity ^0.8.0;


interface IExchange {
    enum OrderStatus {
        INVALID,
        FILLABLE,
        FILLED,
        CANCELLED,
        EXPIRED
    }

    struct LimitOrder {
        IERC20 makerToken;
        IERC20 takerToken;
        uint128 makerAmount;
        uint128 takerAmount;
        uint128 takerTokenFeeAmount;
        address maker;
        address taker;
        address sender;
        address feeRecipient;
        bytes32 pool;
        uint64 expiry;
        uint256 salt;
    }

    struct OrderInfo {
        bytes32 orderHash;
        OrderStatus status;
        uint128 takerTokenFilledAmount;
    }

    enum SignatureType {
        ILLEGAL,
        INVALID,
        EIP712,
        ETHSIGN
    }

    struct Signature {
        SignatureType signatureType;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function getLimitOrderRelevantState(
        LimitOrder memory order,
        Signature calldata signature
    )
        external
        view
        returns (
            OrderInfo memory orderInfo,
            uint128 actualFillableTakerTokenAmount,
            bool isSignatureValid
        );
}

contract NativeOrderSampler {
    using SafeMath for uint256;
    using Math for uint256;

    uint256 internal constant DEFAULT_CALL_GAS = 200e3; // 200k

    function getLimitOrderFillableTakerAssetAmounts(
        IExchange.LimitOrder[] memory orders,
        IExchange.Signature[] memory orderSignatures,
        IExchange exchange
    ) public view returns (uint256[] memory orderFillableTakerAssetAmounts) {
        orderFillableTakerAssetAmounts = new uint256[](orders.length);
        for (uint256 i = 0; i != orders.length; i++) {
            try
                this.getLimitOrderFillableTakerAmount{gas: DEFAULT_CALL_GAS}(
                    orders[i],
                    orderSignatures[i],
                    exchange
                )
            returns (uint256 amount) {
                orderFillableTakerAssetAmounts[i] = amount;
            } catch (bytes memory) {
                orderFillableTakerAssetAmounts[i] = 0;
            }
        }
    }

    function getLimitOrderFillableMakerAssetAmounts(
        IExchange.LimitOrder[] memory orders,
        IExchange.Signature[] memory orderSignatures,
        IExchange exchange
    ) public view returns (uint256[] memory orderFillableMakerAssetAmounts) {
        orderFillableMakerAssetAmounts = getLimitOrderFillableTakerAssetAmounts(
            orders,
            orderSignatures,
            exchange
        );
        for (uint256 i = 0; i < orders.length; ++i) {
            if (orderFillableMakerAssetAmounts[i] != 0) {
                orderFillableMakerAssetAmounts[
                    i
                ] = orderFillableMakerAssetAmounts[i]
                    .mul(orders[i].makerAmount)
                    .ceilDiv(orders[i].takerAmount);
            }
        }
    }

    function getLimitOrderFillableTakerAmount(
        IExchange.LimitOrder memory order,
        IExchange.Signature memory signature,
        IExchange exchange
    ) public view virtual returns (uint256 fillableTakerAmount) {
        if (
            signature.signatureType == IExchange.SignatureType.ILLEGAL ||
            signature.signatureType == IExchange.SignatureType.INVALID ||
            order.makerAmount == 0 ||
            order.takerAmount == 0
        ) {
            return 0;
        }

        (
            IExchange.OrderInfo memory orderInfo,
            uint128 remainingFillableTakerAmount,
            bool isSignatureValid
        ) = exchange.getLimitOrderRelevantState(order, signature);

        if (
            orderInfo.status != IExchange.OrderStatus.FILLABLE ||
            !isSignatureValid ||
            order.makerToken == IERC20(address(0))
        ) {
            return 0;
        }

        fillableTakerAmount = uint256(remainingFillableTakerAmount);
    }
}// Apache-2.0

pragma solidity ^0.8.0;

interface IKyberDmmRouter {
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata pools,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

contract KyberDmmSampler {
    uint256 private constant KYBER_DMM_CALL_GAS = 150e3; // 150k
    struct KyberDmmSamplerOpts {
        address pool;
        IKyberDmmRouter router;
    }

    function sampleSellsFromKyberDmm(
        KyberDmmSamplerOpts memory opts,
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    ) public view returns (uint256[] memory makerTokenAmounts) {
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        address[] memory pools = new address[](1);
        address[] memory path = new address[](2);
        pools[0] = opts.pool;
        path[0] = takerToken;
        path[1] = makerToken;
        for (uint256 i = 0; i < numSamples; i++) {
            try
                opts.router.getAmountsOut{gas: KYBER_DMM_CALL_GAS}(
                    takerTokenAmounts[i],
                    pools,
                    path
                )
            returns (uint256[] memory amounts) {
                makerTokenAmounts[i] = amounts[1];
            } catch (bytes memory) {}
            if (makerTokenAmounts[i] == 0) {
                break;
            }
        }
    }
}// Apache-2.0

pragma solidity ^0.8.0;


contract ERC20BridgeSampler is
    BalancerSampler,
    BalancerV2Sampler,
    CurveSampler,
    DODOSampler,
    DODOV2Sampler,
    UniswapV2Sampler,
    UniswapV3Sampler,
    MakerPSMSampler,
    KyberDmmSampler,
    NativeOrderSampler
{
    struct CallResults {
        bytes data;
        bool success;
    }

    function batchCall(bytes[] calldata callDatas)
        external
        returns (CallResults[] memory callResults)
    {
        callResults = new CallResults[](callDatas.length);
        for (uint256 i = 0; i != callDatas.length; ++i) {
            callResults[i].success = true;
            if (callDatas[i].length == 0) {
                continue;
            }
            (callResults[i].success, callResults[i].data) = address(this).call(
                callDatas[i]
            );
        }
    }
}