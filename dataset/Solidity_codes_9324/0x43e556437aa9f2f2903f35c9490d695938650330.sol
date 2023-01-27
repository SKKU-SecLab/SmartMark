pragma solidity >=0.6.6;

interface IApePair {

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

}pragma solidity >=0.5.0;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}// MIT
pragma solidity =0.6.6;



library ApeOnlyPriceGetter {

    address public constant FACTORY = 0xBAe5dc9B19004883d0377419FeF3c2C8832d7d7B; //ApeFactory
    bytes32 public constant INITCODEHASH = hex'e2200989b6f9506f3beca7e9c844741b3ad1a88ad978b6b0973e96d3ca4707aa'; // for pairs created by ApeFactory

    uint private constant PRECISION = 10**DECIMALS; //1e18 == $1
    uint public constant DECIMALS = 18;

    address constant NATIVE = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    uint private constant USDC_RAW_PRICE = 1e18;

    address constant USDC_NATIVE_PAIR = 0x6B0cc136F7BABd971B5dECd21690BE65718990E2; // usdc is token1

    function getPrice(address token, uint _decimals) external view returns (uint) {

        return normalize(getRawPrice(token), token, _decimals);
    }

    function getLPPrice(address token, uint _decimals) external view returns (uint) {

        return normalize(getRawLPPrice(token), token, _decimals);
    }

    function getPrices(address[] calldata tokens, uint _decimals) external view returns (uint[] memory prices) {

        prices = getRawPrices(tokens);

        for (uint i; i < prices.length; i++) {
            prices[i] = normalize(prices[i], tokens[i], _decimals);
        }
    }

    function getLPPrices(address[] calldata tokens, uint _decimals) external view returns (uint[] memory prices) {

        prices = getRawLPPrices(tokens);

        for (uint i; i < prices.length; i++) {
            prices[i] = normalize(prices[i], tokens[i], _decimals);
        }
    }

    function getRawPrice(address token) public view returns (uint) {

        uint pegPrice = pegTokenPrice(token);
        if (pegPrice != 0) return pegPrice;

        return getRawPrice(token, getNativePrice());
    }

    function getRawPrices(address[] memory tokens) public view returns (uint[] memory prices) {

        prices = new uint[](tokens.length);
        uint nativePrice = getNativePrice();

        for (uint i; i < prices.length; i++) {
            address token = tokens[i];

            uint pegPrice = pegTokenPrice(token, nativePrice);
            if (pegPrice != 0) prices[i] = pegPrice;
            else prices[i] = getRawPrice(token, nativePrice);
        }
    }

    function getRawLPPrice(address token) internal view returns (uint) {

        uint pegPrice = pegTokenPrice(token);
        if (pegPrice != 0) return pegPrice;

        return getRawLPPrice(token, getNativePrice());
    }

    function getRawLPPrices(address[] memory tokens) internal view returns (uint[] memory prices) {

        prices = new uint[](tokens.length);
        uint nativePrice = getNativePrice();

        for (uint i; i < prices.length; i++) {
            address token = tokens[i];

            uint pegPrice = pegTokenPrice(token, nativePrice);
            if (pegPrice != 0) prices[i] = pegPrice;
            else prices[i] = getRawLPPrice(token, nativePrice);
        }
    }

    function getNativePrice() public view returns (uint) {

        (uint nativeReserve1, uint usdcReserve,) = IApePair(USDC_NATIVE_PAIR).getReserves();
        uint nativeTotal = nativeReserve1;
        uint usdTotal = usdcReserve;
    
        return usdTotal * PRECISION / nativeTotal; 
    }

    function getRawLPPrice(address lp, uint nativePrice) internal view returns (uint) {

        try IApePair(lp).getReserves() returns (uint112 reserve0, uint112 reserve1, uint32) {
            address token0 = IApePair(lp).token0();
            address token1 = IApePair(lp).token1();
            uint totalSupply = IApePair(lp).totalSupply();

            uint totalValue = getRawPrice(token0, nativePrice) * reserve0 + getRawPrice(token1, nativePrice) * reserve1;

            return totalValue / totalSupply;

        } catch {
            return getRawPrice(lp, nativePrice);
        }
    }

    function getRawPrice(address token, uint nativePrice) internal view returns (uint rawPrice) {

        uint pegPrice = pegTokenPrice(token, nativePrice);
        if (pegPrice != 0) return pegPrice;

        uint numTokens;
        uint pairedValue;
        uint lpTokens;
        uint lpValue;

        (lpTokens, lpValue) = pairTokensAndValue(token, NATIVE);
        numTokens += lpTokens;
        pairedValue += lpValue;

        (lpTokens, lpValue) = pairTokensAndValue(token, USDC);
        numTokens += lpTokens;
        pairedValue += lpValue;

        if (numTokens > 0) return pairedValue / numTokens;
    }


    function pegTokenPrice(address token, uint nativePrice) private pure returns (uint) {

        if (token == USDC) return PRECISION;
        if (token == NATIVE) return nativePrice;
        return 0;
    }

    function pegTokenPrice(address token) private view returns (uint) {

        if (token == USDC) return PRECISION;
        if (token == NATIVE) return getNativePrice();
        return 0;
    }

    function pairTokensAndValue(address token, address peg) private view returns (uint tokenNum, uint pegValue) {

        address tokenPegPair = pairFor(token, peg);

        uint256 size;
        assembly { size := extcodesize(tokenPegPair) }
        if (size == 0) return (0,0);

        try IApePair(tokenPegPair).getReserves() returns (uint112 reserve0, uint112 reserve1, uint32) {
            uint reservePeg;
            (tokenNum, reservePeg) = token < peg ? (reserve0, reserve1) : (reserve1, reserve0);
            pegValue = reservePeg * pegTokenPrice(peg);
        } catch {
            return (0,0);
        }
    }

    function normalize(uint price, address token, uint _decimals) private view returns (uint) {

        uint tokenDecimals;

        try IERC20(token).decimals() returns (uint8 dec) {
            tokenDecimals = dec;
        } catch {
            tokenDecimals = 18;
        }

        if (tokenDecimals + _decimals <= 2*DECIMALS) return price / 10**(2*DECIMALS - tokenDecimals - _decimals);
        else return price * 10**(_decimals + tokenDecimals - 2*DECIMALS);
    }

    function pairFor(address tokenA, address tokenB) private pure returns (address pair) {

        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                FACTORY,
                keccak256(abi.encodePacked(token0, token1)),
                INITCODEHASH
        )))));
    }
}