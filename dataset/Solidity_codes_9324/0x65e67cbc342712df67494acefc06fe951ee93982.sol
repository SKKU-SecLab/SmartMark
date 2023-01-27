

pragma solidity ^0.5.0;

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
}


pragma solidity ^0.5.0;

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
}


pragma solidity ^0.5.0;


interface IBalancerRegistry {

    event PoolAdded(
        address indexed pool
    );
    event PoolTokenPairAdded(
        address indexed pool,
        address indexed fromToken,
        address indexed destToken
    );
    event IndicesUpdated(
        address indexed fromToken,
        address indexed destToken,
        bytes32 oldIndices,
        bytes32 newIndices
    );

    function getPairInfo(address pool, address fromToken, address destToken)
        external view returns(uint256 weight1, uint256 weight2, uint256 swapFee);


    function checkAddedPools(address pool)
        external view returns(bool);

    function getAddedPoolsLength()
        external view returns(uint256);

    function getAddedPools()
        external view returns(address[] memory);

    function getAddedPoolsWithLimit(uint256 offset, uint256 limit)
        external view returns(address[] memory result);


    function getAllTokensLength()
        external view returns(uint256);

    function getAllTokens()
        external view returns(address[] memory);

    function getAllTokensWithLimit(uint256 offset, uint256 limit)
        external view returns(address[] memory result);


    function getPoolsLength(address fromToken, address destToken)
        external view returns(uint256);

    function getPools(address fromToken, address destToken)
        external view returns(address[] memory);

    function getPoolsWithLimit(address fromToken, address destToken, uint256 offset, uint256 limit)
        external view returns(address[] memory result);

    function getBestPools(address fromToken, address destToken)
        external view returns(address[] memory pools);

    function getBestPoolsWithLimit(address fromToken, address destToken, uint256 limit)
        external view returns(address[] memory pools);


    function getPoolReturn(address pool, address fromToken, address destToken, uint256 amount)
        external view returns(uint256);

    function getPoolReturns(address pool, address fromToken, address destToken, uint256[] calldata amounts)
        external view returns(uint256[] memory result);


    function addPool(address pool) external returns(uint256 listed);

    function addPools(address[] calldata pools) external returns(uint256[] memory listed);

    function updatedIndices(address[] calldata tokens, uint256 lengthLimit) external;

}


pragma solidity ^0.5.0;


interface IBalancerPool {

    function getFinalTokens() external view returns(address[] memory tokens);

    function getDenormalizedWeight(address token) external view returns(uint256);

    function getTotalDenormalizedWeight() external view returns(uint256);

    function getBalance(address token) external view returns(uint256);

    function getSwapFee() external view returns(uint256);

}


pragma solidity ^0.5.0;


library BalancerLib {

    uint public constant BONE              = 10**18;

    uint public constant MIN_BOUND_TOKENS  = 2;
    uint public constant MAX_BOUND_TOKENS  = 8;

    uint public constant MIN_FEE           = BONE / 10**6;
    uint public constant MAX_FEE           = BONE / 10;
    uint public constant EXIT_FEE          = 0;

    uint public constant MIN_WEIGHT        = BONE;
    uint public constant MAX_WEIGHT        = BONE * 50;
    uint public constant MAX_TOTAL_WEIGHT  = BONE * 50;
    uint public constant MIN_BALANCE       = BONE / 10**12;

    uint public constant INIT_POOL_SUPPLY  = BONE * 100;

    uint public constant MIN_BPOW_BASE     = 1 wei;
    uint public constant MAX_BPOW_BASE     = (2 * BONE) - 1 wei;
    uint public constant BPOW_PRECISION    = BONE / 10**10;

    uint public constant MAX_IN_RATIO      = BONE / 2;
    uint public constant MAX_OUT_RATIO     = (BONE / 3) + 1 wei;

    function btoi(uint a)
        internal pure
        returns (uint)
    {

        return a / BONE;
    }

    function bfloor(uint a)
        internal pure
        returns (uint)
    {

        return btoi(a) * BONE;
    }

    function badd(uint a, uint b)
        internal pure
        returns (uint)
    {

        uint c = a + b;
        require(c >= a, "ERR_ADD_OVERFLOW");
        return c;
    }

    function bsub(uint a, uint b)
        internal pure
        returns (uint)
    {

        (uint c, bool flag) = bsubSign(a, b);
        require(!flag, "ERR_SUB_UNDERFLOW");
        return c;
    }

    function bsubSign(uint a, uint b)
        internal pure
        returns (uint, bool)
    {

        if (a >= b) {
            return (a - b, false);
        } else {
            return (b - a, true);
        }
    }

    function bmul(uint a, uint b)
        internal pure
        returns (uint)
    {

        uint c0 = a * b;
        require(a == 0 || c0 / a == b, "ERR_MUL_OVERFLOW");
        uint c1 = c0 + (BONE / 2);
        require(c1 >= c0, "ERR_MUL_OVERFLOW");
        uint c2 = c1 / BONE;
        return c2;
    }

    function bdiv(uint a, uint b)
        internal pure
        returns (uint)
    {

        require(b != 0, "ERR_DIV_ZERO");
        uint c0 = a * BONE;
        require(a == 0 || c0 / a == BONE, "ERR_DIV_INTERNAL"); // bmul overflow
        uint c1 = c0 + (b / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL"); //  badd require
        uint c2 = c1 / b;
        return c2;
    }

    function bpowi(uint a, uint n)
        internal pure
        returns (uint)
    {

        uint z = n % 2 != 0 ? a : BONE;

        for (n /= 2; n != 0; n /= 2) {
            a = bmul(a, a);

            if (n % 2 != 0) {
                z = bmul(z, a);
            }
        }
        return z;
    }

    function bpow(uint base, uint exp)
        internal pure
        returns (uint)
    {

        require(base >= MIN_BPOW_BASE, "ERR_BPOW_BASE_TOO_LOW");
        require(base <= MAX_BPOW_BASE, "ERR_BPOW_BASE_TOO_HIGH");

        uint whole  = bfloor(exp);
        uint remain = bsub(exp, whole);

        uint wholePow = bpowi(base, btoi(whole));

        if (remain == 0) {
            return wholePow;
        }

        uint partialResult = bpowApprox(base, remain, BPOW_PRECISION);
        return bmul(wholePow, partialResult);
    }

    function bpowApprox(uint base, uint exp, uint precision)
        internal pure
        returns (uint)
    {

        uint a     = exp;
        (uint x, bool xneg)  = bsubSign(base, BONE);
        uint term = BONE;
        uint sum   = term;
        bool negative = false;


        for (uint i = 1; term >= precision; i++) {
            uint bigK = i * BONE;
            (uint c, bool cneg) = bsubSign(a, bsub(bigK, BONE));
            term = bmul(term, bmul(c, x));
            term = bdiv(term, bigK);
            if (term == 0) break;

            if (xneg) negative = !negative;
            if (cneg) negative = !negative;
            if (negative) {
                sum = bsub(sum, term);
            } else {
                sum = badd(sum, term);
            }
        }

        return sum;
    }

    function calcSpotPrice(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint swapFee
    )
        internal pure
        returns (uint spotPrice)
    {

        uint numer = bdiv(tokenBalanceIn, tokenWeightIn);
        uint denom = bdiv(tokenBalanceOut, tokenWeightOut);
        uint ratio = bdiv(numer, denom);
        uint scale = bdiv(BONE, bsub(BONE, swapFee));
        return  (spotPrice = bmul(ratio, scale));
    }

    function calcOutGivenIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint tokenAmountIn,
        uint swapFee
    )
        internal pure
        returns (uint tokenAmountOut)
    {

        uint weightRatio = bdiv(tokenWeightIn, tokenWeightOut);
        uint adjustedIn = bsub(BONE, swapFee);
        adjustedIn = bmul(tokenAmountIn, adjustedIn);
        uint y = bdiv(tokenBalanceIn, badd(tokenBalanceIn, adjustedIn));
        uint foo = bpow(y, weightRatio);
        uint bar = bsub(BONE, foo);
        tokenAmountOut = bmul(tokenBalanceOut, bar);
        return tokenAmountOut;
    }

    function calcInGivenOut(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint tokenAmountOut,
        uint swapFee
    )
        internal pure
        returns (uint tokenAmountIn)
    {

        uint weightRatio = bdiv(tokenWeightOut, tokenWeightIn);
        uint diff = bsub(tokenBalanceOut, tokenAmountOut);
        uint y = bdiv(tokenBalanceOut, diff);
        uint foo = bpow(y, weightRatio);
        foo = bsub(foo, BONE);
        tokenAmountIn = bsub(BONE, swapFee);
        tokenAmountIn = bdiv(bmul(tokenBalanceIn, foo), tokenAmountIn);
        return tokenAmountIn;
    }

    function calcPoolOutGivenSingleIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountIn,
        uint swapFee
    )
        internal pure
        returns (uint poolAmountOut)
    {

        uint normalizedWeight = bdiv(tokenWeightIn, totalWeight);
        uint zaz = bmul(bsub(BONE, normalizedWeight), swapFee);
        uint tokenAmountInAfterFee = bmul(tokenAmountIn, bsub(BONE, zaz));

        uint newTokenBalanceIn = badd(tokenBalanceIn, tokenAmountInAfterFee);
        uint tokenInRatio = bdiv(newTokenBalanceIn, tokenBalanceIn);

        uint poolRatio = bpow(tokenInRatio, normalizedWeight);
        uint newPoolSupply = bmul(poolRatio, poolSupply);
        poolAmountOut = bsub(newPoolSupply, poolSupply);
        return poolAmountOut;
    }

    function calcSingleInGivenPoolOut(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint poolAmountOut,
        uint swapFee
    )
        internal pure
        returns (uint tokenAmountIn)
    {

        uint normalizedWeight = bdiv(tokenWeightIn, totalWeight);
        uint newPoolSupply = badd(poolSupply, poolAmountOut);
        uint poolRatio = bdiv(newPoolSupply, poolSupply);

        uint boo = bdiv(BONE, normalizedWeight);
        uint tokenInRatio = bpow(poolRatio, boo);
        uint newTokenBalanceIn = bmul(tokenInRatio, tokenBalanceIn);
        uint tokenAmountInAfterFee = bsub(newTokenBalanceIn, tokenBalanceIn);
        uint zar = bmul(bsub(BONE, normalizedWeight), swapFee);
        tokenAmountIn = bdiv(tokenAmountInAfterFee, bsub(BONE, zar));
        return tokenAmountIn;
    }

    function calcSingleOutGivenPoolIn(
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint poolSupply,
        uint totalWeight,
        uint poolAmountIn,
        uint swapFee
    )
        internal pure
        returns (uint tokenAmountOut)
    {

        uint normalizedWeight = bdiv(tokenWeightOut, totalWeight);
        uint poolAmountInAfterExitFee = bmul(poolAmountIn, bsub(BONE, EXIT_FEE));
        uint newPoolSupply = bsub(poolSupply, poolAmountInAfterExitFee);
        uint poolRatio = bdiv(newPoolSupply, poolSupply);

        uint tokenOutRatio = bpow(poolRatio, bdiv(BONE, normalizedWeight));
        uint newTokenBalanceOut = bmul(tokenOutRatio, tokenBalanceOut);

        uint tokenAmountOutBeforeSwapFee = bsub(tokenBalanceOut, newTokenBalanceOut);

        uint zaz = bmul(bsub(BONE, normalizedWeight), swapFee);
        tokenAmountOut = bmul(tokenAmountOutBeforeSwapFee, bsub(BONE, zaz));
        return tokenAmountOut;
    }

    function calcPoolInGivenSingleOut(
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountOut,
        uint swapFee
    )
        internal pure
        returns (uint poolAmountIn)
    {


        uint normalizedWeight = bdiv(tokenWeightOut, totalWeight);
        uint zoo = bsub(BONE, normalizedWeight);
        uint zar = bmul(zoo, swapFee);
        uint tokenAmountOutBeforeSwapFee = bdiv(tokenAmountOut, bsub(BONE, zar));

        uint newTokenBalanceOut = bsub(tokenBalanceOut, tokenAmountOutBeforeSwapFee);
        uint tokenOutRatio = bdiv(newTokenBalanceOut, tokenBalanceOut);

        uint poolRatio = bpow(tokenOutRatio, normalizedWeight);
        uint newPoolSupply = bmul(poolRatio, poolSupply);
        uint poolAmountInAfterExitFee = bsub(poolSupply, newPoolSupply);

        poolAmountIn = bdiv(poolAmountInAfterExitFee, bsub(BONE, EXIT_FEE));
        return poolAmountIn;
    }
}


pragma solidity ^0.5.0;


library AddressSet {

    struct Data {
        address[] items;
        mapping(address => uint) lookup;
    }

    function length(Data storage s) internal view returns(uint) {

        return s.items.length;
    }

    function at(Data storage s, uint index) internal view returns(address) {

        return s.items[index];
    }

    function contains(Data storage s, address item) internal view returns(bool) {

        return s.lookup[item] != 0;
    }

    function add(Data storage s, address item) internal returns(bool) {

        if (s.lookup[item] == 0) {
            s.lookup[item] = s.items.push(item);
            return true;
        }
    }

    function remove(Data storage s, address item) internal returns(bool) {

        uint index = s.lookup[item];
        if (index > 0) {
            if (index < s.items.length) {
                address lastItem = s.items[s.items.length - 1];
                s.items[index - 1] = lastItem;
                s.lookup[lastItem] = index;
            }
            s.items.length -= 1;
            delete s.lookup[item];
            return true;
        }
    }
}


pragma solidity ^0.5.0;








contract BalancerRegistry is IBalancerRegistry {

    using SafeMath for uint256;
    using AddressSet for AddressSet.Data;

    struct PoolPairInfo {
        uint80 weight1;
        uint80 weight2;
        uint80 swapFee;
    }

    struct SortedPools {
        AddressSet.Data pools;
        bytes32 indices;
    }

    AddressSet.Data private _allTokens;
    AddressSet.Data private _addedPools;
    mapping(bytes32 => SortedPools) private _pools;
    mapping(address => mapping(bytes32 => PoolPairInfo)) private _infos;

    function checkAddedPools(address pool)
        external view returns(bool)
    {

        return _addedPools.contains(pool);
    }

    function getAddedPoolsLength()
        external view returns(uint256)
    {

        return _addedPools.items.length;
    }

    function getAddedPools()
        external view returns(address[] memory)
    {

        return _addedPools.items;
    }

    function getAddedPoolsWithLimit(uint256 offset, uint256 limit)
        external view returns(address[] memory result)
    {

        result = new address[](Math.min(limit, _addedPools.items.length - offset));
        for (uint i = 0; i < result.length; i++) {
            result[i] = _addedPools.items[offset + i];
        }
    }

    function getAllTokensLength()
        external view returns(uint256)
    {

        return _allTokens.items.length;
    }

    function getAllTokens()
        external view returns(address[] memory)
    {

        return _allTokens.items;
    }

    function getAllTokensWithLimit(uint256 offset, uint256 limit)
        external view returns(address[] memory result)
    {

        result = new address[](Math.min(limit, _allTokens.items.length - offset));
        for (uint i = 0; i < result.length; i++) {
            result[i] = _allTokens.items[offset + i];
        }
    }

    function getPairInfo(address pool, address fromToken, address destToken)
        external view returns(uint256 weight1, uint256 weight2, uint256 swapFee)
    {

        bytes32 key = _createKey(fromToken, destToken);
        PoolPairInfo memory info = _infos[pool][key];
        return (info.weight1, info.weight2, info.swapFee);
    }

    function getPoolsLength(address fromToken, address destToken)
        external view returns(uint256)
    {

        bytes32 key = _createKey(fromToken, destToken);
        return _pools[key].pools.items.length;
    }

    function getPools(address fromToken, address destToken)
        external view returns(address[] memory)
    {

        bytes32 key = _createKey(fromToken, destToken);
        return _pools[key].pools.items;
    }

    function getPoolsWithLimit(address fromToken, address destToken, uint256 offset, uint256 limit)
        public view returns(address[] memory result)
    {

        bytes32 key = _createKey(fromToken, destToken);
        result = new address[](Math.min(limit, _pools[key].pools.items.length - offset));
        for (uint i = 0; i < result.length; i++) {
            result[i] = _pools[key].pools.items[offset + i];
        }
    }

    function getBestPools(address fromToken, address destToken)
        external view returns(address[] memory pools)
    {

        return getBestPoolsWithLimit(fromToken, destToken, 32);
    }

    function getBestPoolsWithLimit(address fromToken, address destToken, uint256 limit)
        public view returns(address[] memory pools)
    {

        bytes32 key = _createKey(fromToken, destToken);
        bytes32 indices = _pools[key].indices;
        uint256 len = 0;
        while (indices[len] > 0 && len < Math.min(limit, indices.length)) {
            len++;
        }

        pools = new address[](len);
        for (uint i = 0; i < len; i++) {
            uint256 index = uint256(uint8(indices[i])).sub(1);
            pools[i] = _pools[key].pools.items[index];
        }
    }


    function getPoolReturn(address pool, address fromToken, address destToken, uint256 amount)
        external view returns(uint256)
    {

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        return getPoolReturns(pool, fromToken, destToken, amounts)[0];
    }

    function getPoolReturns(address pool, address fromToken, address destToken, uint256[] memory amounts)
        public view returns(uint256[] memory result)
    {

        bytes32 key = _createKey(fromToken, destToken);
        PoolPairInfo memory info = _infos[pool][key];
        result = new uint256[](amounts.length);
        for (uint i = 0; i < amounts.length; i++) {
            result[i] = BalancerLib.calcOutGivenIn(
                IBalancerPool(pool).getBalance(fromToken),
                uint256(fromToken < destToken ? info.weight1 : info.weight2),
                IBalancerPool(pool).getBalance(destToken),
                uint256(fromToken < destToken ? info.weight2 : info.weight1),
                amounts[i],
                info.swapFee
            );
        }
    }


    function addPool(address pool) public returns(uint256 listed) {

        if (!_addedPools.add(pool)) {
            return 0;
        }
        emit PoolAdded(pool);

        address[] memory tokens = IBalancerPool(pool).getFinalTokens();
        uint256[] memory weights = new uint256[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            weights[i] = IBalancerPool(pool).getDenormalizedWeight(tokens[i]);
        }

        uint256 swapFee = IBalancerPool(pool).getSwapFee();

        for (uint i = 0; i < tokens.length; i++) {
            _allTokens.add(tokens[i]);
            for (uint j = i + 1; j < tokens.length; j++) {
                bytes32 key = _createKey(tokens[i], tokens[j]);
                if (_pools[key].pools.add(pool)) {
                    _infos[pool][key] = PoolPairInfo({
                        weight1: uint80(weights[tokens[i] < tokens[j] ? i : j]),
                        weight2: uint80(weights[tokens[i] < tokens[j] ? j : i]),
                        swapFee: uint80(swapFee)
                    });

                    emit PoolTokenPairAdded(
                        pool,
                        tokens[i] < tokens[j] ? tokens[i] : tokens[j],
                        tokens[i] < tokens[j] ? tokens[j] : tokens[i]
                    );
                    listed++;
                }
            }
        }
    }

    function addPools(address[] calldata pools) external returns(uint256[] memory listed) {

        listed = new uint256[](pools.length);
        for (uint i = 0; i < pools.length; i++) {
            listed[i] = addPool(pools[i]);
        }
    }

    function updatedIndices(address[] calldata tokens, uint256 lengthLimit) external {

        for (uint i = 0; i < tokens.length; i++) {
            for (uint j = i + 1; j < tokens.length; j++) {
                bytes32 key = _createKey(tokens[i], tokens[j]);
                address[] memory pools = getPoolsWithLimit(tokens[i], tokens[j], 0, Math.min(256, lengthLimit));
                uint256[] memory invs = _getInvsForPools(tokens[i], tokens[j], pools);
                bytes32 indices = _buildSortIndices(invs);

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


    function _createKey(address token1, address token2)
        internal pure returns(bytes32)
    {

        return bytes32(
            (uint256(uint128((token1 < token2) ? token1 : token2)) << 128) |
            (uint256(uint128((token1 < token2) ? token2 : token1)))
        );
    }

    function _getInvsForPools(address fromToken, address destToken, address[] memory pools)
        internal view returns(uint256[] memory invs)
    {

        invs = new uint256[](pools.length);
        for (uint i = 0; i < pools.length; i++) {
            bytes32 key = _createKey(fromToken, destToken);
            PoolPairInfo memory info = _infos[pools[i]][key];
            invs[i] = IBalancerPool(pools[i]).getBalance(fromToken)
                .mul(IBalancerPool(pools[i]).getBalance(destToken));
            invs[i] = invs[i]
                .mul(info.weight1 + info.weight2).div(info.weight1)
                .mul(info.weight1 + info.weight2).div(info.weight2);
        }
    }

    function _buildSortIndices(uint256[] memory invs)
        internal pure returns(bytes32)
    {

        uint256 result = 0;
        uint256 prevInv = uint256(-1);
        for (uint i = 0; i < Math.min(invs.length, 32); i++) {
            uint256 bestIndex = 0;
            for (uint j = 0; j < invs.length; j++) {
                if ((invs[j] > invs[bestIndex] && invs[j] < prevInv) || invs[bestIndex] >= prevInv) {
                    bestIndex = j;
                }
            }
            prevInv = invs[bestIndex];
            result |= (bestIndex + 1) << (248 - i * 8);
        }
        return bytes32(result);
    }
}