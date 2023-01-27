
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface IndexPoolI {

  function getDenormalizedWeight(address token) external view returns (uint256);

  function getBalance(address token) external view returns (uint256);

  function getUsedBalance(address token) external view returns (uint256);

  function getSpotPrice(address tokenIn, address tokenOut) external view returns (uint256);    

}

interface ERC20I {

    function totalSupply() external view returns (uint256);

}

contract SimpleMultiCall {


    struct Bundle {
        address pool;
        address[] tokens;
        uint256[] denormalizedWeights;
        uint256[] balances;
        uint256[] totalSupplies;
    }
    
    function getBundle(
        address poolAddress,
        address[] memory tokens
    )
        public
        view
        returns (Bundle memory)
    {

        (, uint256[] memory weights) = getDenormalizedWeights(poolAddress, tokens);
        (, uint256[] memory balances) = getBalances(poolAddress, tokens);
        (, uint256[] memory totalSupplies) = getTotalSupplies(tokens);
        return Bundle({
            pool: poolAddress,
            tokens: tokens,
            denormalizedWeights: weights,
            balances: balances,
            totalSupplies: totalSupplies
        });
    }

    function getBundles(
        address[] memory pools,
        address[][] memory tokens
    )
        public
        view
        returns (Bundle[] memory)
    {

        Bundle[] memory bundles = new Bundle[](pools.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            bundles[i] = getBundle(pools[i], tokens[i]);
        }
        return bundles;
    }


    function getDenormalizedWeights(
        address poolAddress,
        address[] memory tokens
    ) 
        public 
        view
        returns (address[] memory, uint256[] memory) 
    {

        uint256[] memory weights = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            weights[i] = IndexPoolI(poolAddress).getDenormalizedWeight(tokens[i]);
        }
        return (tokens, weights);
    }

    function getBalances(
        address poolAddress,
        address[] memory tokens
    ) 
        public 
        view
        returns (address[] memory, uint256[] memory) 
    {

        uint256[] memory balances = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            balances[i] = IndexPoolI(poolAddress).getBalance(tokens[i]);
        }
        return (tokens, balances);
    }

    function getUsedBalances(
        address poolAddress,
        address[] memory tokens
    ) 
        public 
        view
        returns (address[] memory, uint256[] memory) 
    {

        uint256[] memory balances = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            balances[i] = IndexPoolI(poolAddress).getUsedBalance(tokens[i]);
        }
        return (tokens, balances);
    }

    function getSpotPrices(
        address poolAddress,
        address[] memory inTokens,
        address[] memory outTokens
    )
        public
        view 
        returns (address[] memory, address[] memory, uint256[] memory)
    {

        uint256[] memory prices = new uint256[](inTokens.length);
        for (uint256 i = 0; i < inTokens.length; i++) {
            prices[i] = IndexPoolI(poolAddress).getSpotPrice(inTokens[i], outTokens[i]);
        }
        return (inTokens, outTokens, prices);
    }


    function getTotalSupplies(
        address[] memory tokens
    )
        public
        view
        returns (address[] memory, uint256[] memory)
    {

        uint256[] memory supplies = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            supplies[i] = ERC20I(tokens[i]).totalSupply();
        }
        return (tokens, supplies);
    }
}