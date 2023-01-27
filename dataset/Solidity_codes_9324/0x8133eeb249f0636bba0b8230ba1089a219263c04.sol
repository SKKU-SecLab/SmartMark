
pragma solidity ^0.7.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity ^0.7.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}//GPL-3.0-only
pragma solidity ^0.7.0;

library EnumerableSet {

    struct AddressSet {
        mapping(address => uint256) index;
        address[] values;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        if (!contains(set, value)) {
            set.values.push(value);
            set.index[value] = set.values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        if (contains(set, value)) {
            uint256 toDeleteIndex = set.index[value] - 1;
            uint256 lastIndex = set.values.length - 1;

            if (lastIndex != toDeleteIndex) {
                address lastValue = set.values[lastIndex];

                set.values[toDeleteIndex] = lastValue;
                set.index[lastValue] = toDeleteIndex + 1; // All indexes are 1-based
            }

            delete set.index[value];

            set.values.pop();

            return true;
        } else {
            return false;
        }
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return set.index[value] != 0;
    }

    function enumerate(AddressSet storage set) internal view returns (address[] memory) {

        address[] memory output = new address[](set.values.length);
        for (uint256 i; i < set.values.length; i++) {
            output[i] = set.values[i];
        }
        return output;
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return set.values.length;
    }

    function get(AddressSet storage set, uint256 index) internal view returns (address) {

        return set.values[index];
    }
}//GPL-3.0-only
pragma solidity ^0.7.0;

interface IBPool {

    function isPublicSwap() external view returns (bool);


    function isFinalized() external view returns (bool);


    function isBound(address t) external view returns (bool);


    function getNumTokens() external view returns (uint256);


    function getCurrentTokens() external view returns (address[] memory tokens);


    function getFinalTokens() external view returns (address[] memory tokens);


    function getDenormalizedWeight(address token) external view returns (uint256);


    function getTotalDenormalizedWeight() external view returns (uint256);


    function getNormalizedWeight(address token) external view returns (uint256);


    function getBalance(address token) external view returns (uint256);


    function getSwapFee() external view returns (uint256);


    function getController() external view returns (address);


    function setSwapFee(uint256 swapFee) external;


    function setController(address manager) external;


    function setPublicSwap(bool public_) external;


    function finalize() external;


    function bind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;


    function rebind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;


    function unbind(address token) external;


    function gulp(address token) external;


    function getSpotPrice(address tokenIn, address tokenOut) external view returns (uint256 spotPrice);


    function getSpotPriceSansFee(address tokenIn, address tokenOut) external view returns (uint256 spotPrice);


    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;


    function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;


    function swapExactAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);


    function swapExactAmountOut(
        address tokenIn,
        uint256 maxAmountIn,
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);


    function joinswapExternAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external returns (uint256 poolAmountOut);


    function joinswapPoolAmountOut(
        address tokenIn,
        uint256 poolAmountOut,
        uint256 maxAmountIn
    ) external returns (uint256 tokenAmountIn);


    function exitswapPoolAmountIn(
        address tokenOut,
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external returns (uint256 tokenAmountOut);


    function exitswapExternAmountOut(
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPoolAmountIn
    ) external returns (uint256 poolAmountIn);


    function totalSupply() external view returns (uint256);


    function balanceOf(address whom) external view returns (uint256);


    function allowance(address src, address dst) external view returns (uint256);


    function approve(address dst, uint256 amt) external returns (bool);


    function transfer(address dst, uint256 amt) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 amt
    ) external returns (bool);


    function calcSpotPrice(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 swapFee
    ) external pure returns (uint256 spotPrice);


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


    function calcPoolOutGivenSingleIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 tokenAmountIn,
        uint256 swapFee
    ) external pure returns (uint256 poolAmountOut);


    function calcSingleInGivenPoolOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 poolAmountOut,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountIn);


    function calcSingleOutGivenPoolIn(
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 poolAmountIn,
        uint256 swapFee
    ) external pure returns (uint256 tokenAmountOut);


    function calcPoolInGivenSingleOut(
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 tokenAmountOut,
        uint256 swapFee
    ) external pure returns (uint256 poolAmountIn);

}//GPL-3.0-only
pragma solidity ^0.7.0;


interface IBFactory {

    event LOG_NEW_POOL(address indexed caller, address indexed pool);

    function isBPool(address b) external view returns (bool);


    function newBPool() external returns (IBPool);


    function setExchProxy(address exchProxy) external;


    function setOperationsRegistry(address operationsRegistry) external;


    function setPermissionManager(address permissionManager) external;


    function setAuthorization(address _authorization) external;

}//GPL-3.0-only
pragma solidity ^0.7.0;


contract BRegistry {

    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct PoolPairInfo {
        uint80 weight1;
        uint80 weight2;
        uint80 swapFee;
        uint256 liq;
    }

    struct SortedPools {
        EnumerableSet.AddressSet pools;
        bytes32 indices;
    }

    event PoolTokenPairAdded(address indexed pool, address indexed token1, address indexed token2);

    event IndicesUpdated(address indexed token1, address indexed token2, bytes32 oldIndices, bytes32 newIndices);

    uint256 private constant BONE = 10**18;
    uint256 private constant MAX_SWAP_FEE = (3 * BONE) / 100;

    mapping(bytes32 => SortedPools) private _pools;
    mapping(address => mapping(bytes32 => PoolPairInfo)) private _infos;

    IBFactory public bfactory;

    constructor(address _bfactory) {
        bfactory = IBFactory(_bfactory);
    }

    function getPairInfo(
        address pool,
        address fromToken,
        address destToken
    )
        external
        view
        returns (
            uint256 weight1,
            uint256 weight2,
            uint256 swapFee
        )
    {

        bytes32 key = _createKey(fromToken, destToken);
        PoolPairInfo memory info = _infos[pool][key];
        return (info.weight1, info.weight2, info.swapFee);
    }

    function getPoolsWithLimit(
        address fromToken,
        address destToken,
        uint256 offset,
        uint256 limit
    ) public view returns (address[] memory result) {

        bytes32 key = _createKey(fromToken, destToken);
        result = new address[](Math.min(limit, _pools[key].pools.values.length - offset));
        for (uint256 i = 0; i < result.length; i++) {
            result[i] = _pools[key].pools.values[offset + i];
        }
    }

    function getBestPools(address fromToken, address destToken) external view returns (address[] memory pools) {

        return getBestPoolsWithLimit(fromToken, destToken, 32);
    }

    function getBestPoolsWithLimit(
        address fromToken,
        address destToken,
        uint256 limit
    ) public view returns (address[] memory pools) {

        bytes32 key = _createKey(fromToken, destToken);
        bytes32 indices = _pools[key].indices;
        uint256 len = 0;
        while (indices[len] > 0 && len < Math.min(limit, indices.length)) {
            len++;
        }

        pools = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            uint256 index = uint256(uint8(indices[i])).sub(1);
            pools[i] = _pools[key].pools.values[index];
        }
    }


    function addPoolPair(
        address pool,
        address token1,
        address token2
    ) public returns (uint256 listed) {

        require(bfactory.isBPool(pool), "ERR_NOT_BPOOL");

        uint256 swapFee = IBPool(pool).getSwapFee();
        require(swapFee <= MAX_SWAP_FEE, "ERR_FEE_TOO_HIGH");

        bytes32 key = _createKey(token1, token2);
        _pools[key].pools.add(pool);

        if (token1 < token2) {
            _infos[pool][key] = PoolPairInfo({
                weight1: uint80(IBPool(pool).getDenormalizedWeight(token1)),
                weight2: uint80(IBPool(pool).getDenormalizedWeight(token2)),
                swapFee: uint80(swapFee),
                liq: uint256(0)
            });
        } else {
            _infos[pool][key] = PoolPairInfo({
                weight1: uint80(IBPool(pool).getDenormalizedWeight(token2)),
                weight2: uint80(IBPool(pool).getDenormalizedWeight(token1)),
                swapFee: uint80(swapFee),
                liq: uint256(0)
            });
        }

        emit PoolTokenPairAdded(pool, token1, token2);

        listed++;
    }

    function addPools(
        address[] calldata pools,
        address token1,
        address token2
    ) external returns (uint256[] memory listed) {

        listed = new uint256[](pools.length);
        for (uint256 i = 0; i < pools.length; i++) {
            listed[i] = addPoolPair(pools[i], token1, token2);
        }
    }

    function sortPools(address[] calldata tokens, uint256 lengthLimit) external {

        for (uint256 i = 0; i < tokens.length; i++) {
            for (uint256 j = i + 1; j < tokens.length; j++) {
                bytes32 key = _createKey(tokens[i], tokens[j]);
                address[] memory pools = getPoolsWithLimit(tokens[i], tokens[j], 0, Math.min(256, lengthLimit));
                uint256[] memory effectiveLiquidity = _getEffectiveLiquidityForPools(tokens[i], tokens[j], pools);

                bytes32 indices = _buildSortIndices(effectiveLiquidity);


                if (indices != _pools[key].indices) {
                    emit IndicesUpdated(
                        tokens[i] < tokens[j] ? tokens[i] : tokens[j],
                        tokens[i] < tokens[j] ? tokens[j] : tokens[i],
                        _pools[key].indices,
                        indices
                    );
                    _pools[key].indices = indices;
                }
            }
        }
    }

    function sortPoolsWithPurge(address[] calldata tokens, uint256 lengthLimit) external {

        for (uint256 i = 0; i < tokens.length; i++) {
            for (uint256 j = i + 1; j < tokens.length; j++) {
                bytes32 key = _createKey(tokens[i], tokens[j]);
                address[] memory pools = getPoolsWithLimit(tokens[i], tokens[j], 0, Math.min(256, lengthLimit));
                uint256[] memory effectiveLiquidity = _getEffectiveLiquidityForPoolsPurge(tokens[i], tokens[j], pools);
                bytes32 indices = _buildSortIndices(effectiveLiquidity);

                if (indices != _pools[key].indices) {
                    emit IndicesUpdated(
                        tokens[i] < tokens[j] ? tokens[i] : tokens[j],
                        tokens[i] < tokens[j] ? tokens[j] : tokens[i],
                        _pools[key].indices,
                        indices
                    );
                    _pools[key].indices = indices;
                }
            }
        }
    }


    function _createKey(address token1, address token2) internal pure returns (bytes32) {

        return
            bytes32(
                (uint256(uint128((token1 < token2) ? token1 : token2)) << 128) |
                    (uint256(uint128((token1 < token2) ? token2 : token1)))
            );
    }

    function _getEffectiveLiquidityForPools(
        address token1,
        address token2,
        address[] memory pools
    ) internal view returns (uint256[] memory effectiveLiquidity) {

        effectiveLiquidity = new uint256[](pools.length);
        for (uint256 i = 0; i < pools.length; i++) {
            bytes32 key = _createKey(token1, token2);
            PoolPairInfo memory info = _infos[pools[i]][key];
            if (token1 < token2) {
                effectiveLiquidity[i] = bdiv(uint256(info.weight1), uint256(info.weight1).add(uint256(info.weight2)));
                effectiveLiquidity[i] = effectiveLiquidity[i].mul(IBPool(pools[i]).getBalance(token2));
            } else {
                effectiveLiquidity[i] = bdiv(uint256(info.weight2), uint256(info.weight1).add(uint256(info.weight2)));
                effectiveLiquidity[i] = effectiveLiquidity[i].mul(IBPool(pools[i]).getBalance(token2));
            }
        }
    }

    function _getEffectiveLiquidityForPoolsPurge(
        address token1,
        address token2,
        address[] memory pools
    ) public returns (uint256[] memory effectiveLiquidity) {

        uint256 totalLiq = 0;
        bytes32 key = _createKey(token1, token2);

        for (uint256 i = 0; i < pools.length; i++) {
            PoolPairInfo memory info = _infos[pools[i]][key];
            if (token1 < token2) {
                _infos[pools[i]][key].liq = bdiv(
                    uint256(info.weight1),
                    uint256(info.weight1).add(uint256(info.weight2))
                );
                _infos[pools[i]][key].liq = _infos[pools[i]][key].liq.mul(IBPool(pools[i]).getBalance(token2));
                totalLiq = totalLiq.add(_infos[pools[i]][key].liq);
            } else {
                _infos[pools[i]][key].liq = bdiv(
                    uint256(info.weight2),
                    uint256(info.weight1).add(uint256(info.weight2))
                );
                _infos[pools[i]][key].liq = _infos[pools[i]][key].liq.mul(IBPool(pools[i]).getBalance(token2));
                totalLiq = totalLiq.add(_infos[pools[i]][key].liq);
            }
        }

        uint256 threshold = bmul(totalLiq, ((10 * BONE) / 100));

        for (uint256 i = 0; i < _pools[key].pools.length(); i++) {
            if (_infos[_pools[key].pools.values[i]][key].liq < threshold) {
                _pools[key].pools.remove(_pools[key].pools.values[i]);
            }
        }

        effectiveLiquidity = new uint256[](_pools[key].pools.length());

        for (uint256 i = 0; i < _pools[key].pools.length(); i++) {
            effectiveLiquidity[i] = _infos[_pools[key].pools.values[i]][key].liq;
        }
    }

    function bdiv(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "ERR_DIV_ZERO");
        uint256 c0 = a * BONE;
        require(a == 0 || c0 / a == BONE, "ERR_DIV_INTERNAL"); // bdiv overflow
        uint256 c1 = c0 + (b / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL"); //  badd require
        uint256 c2 = c1 / b;
        return c2;
    }

    function bmul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c0 = a * b;
        require(a == 0 || c0 / a == b, "ERR_MUL_OVERFLOW");
        uint256 c1 = c0 + (BONE / 2);
        require(c1 >= c0, "ERR_MUL_OVERFLOW");
        uint256 c2 = c1 / BONE;
        return c2;
    }

    function _buildSortIndices(uint256[] memory effectiveLiquidity) internal pure returns (bytes32) {

        uint256 result = 0;
        uint256 prevEffectiveLiquidity = uint256(-1);
        for (uint256 i = 0; i < Math.min(effectiveLiquidity.length, 32); i++) {
            uint256 bestIndex = 0;
            for (uint256 j = 0; j < effectiveLiquidity.length; j++) {
                if (
                    (effectiveLiquidity[j] > effectiveLiquidity[bestIndex] &&
                        effectiveLiquidity[j] < prevEffectiveLiquidity) ||
                    effectiveLiquidity[bestIndex] >= prevEffectiveLiquidity
                ) {
                    bestIndex = j;
                }
            }
            prevEffectiveLiquidity = effectiveLiquidity[bestIndex];
            result |= (bestIndex + 1) << (248 - i * 8);
        }
        return bytes32(result);
    }
}