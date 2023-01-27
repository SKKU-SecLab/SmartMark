




pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



interface IBancorConverterRegistry {

    function getLiquidityPools() external view returns (address[] memory);

}

interface IOwned {

    function owner() external view returns (IConverter);

}

abstract contract ISmartToken is IOwned, IERC20 {
}


interface IConverter {

    function connectorTokens(uint) external view returns (IERC20);

    function conversionsEnabled() external view returns (bool);

    function connectorTokenCount() external view returns (uint);

}

contract BancorHelper {

    
    address constant private eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    IBancorConverterRegistry public registry = IBancorConverterRegistry(0xC0205e203F423Bcd8B2a4d6f8C8A154b0Aa60F19);

    function getConverters() public view returns (IConverter[] memory goodPools) {


        address[] memory smartTokens = registry.getLiquidityPools();

        IConverter[] memory converters = new IConverter[](smartTokens.length);
        uint goodPoolsCount;
        
        for (uint i = 0; i < smartTokens.length; i++) {
            IConverter converter = ISmartToken(smartTokens[i]).owner();
            if (isGoodPool(converter)) {
                goodPoolsCount++;
                converters[i] = converter;
            }
        }
        
        goodPools = new IConverter[](goodPoolsCount);
        uint counter;
          for (uint i = 0; i < smartTokens.length; i++) {
            if (converters[i] == IConverter(address(0))) {
                continue;
            }
            goodPools[counter] = converters[i];
            counter++;
        }
    }
    
    function getTokensForConverter(IConverter converter) public view returns (IERC20[] memory tokens) {

        uint tokenCount = converter.connectorTokenCount();
        tokens = new IERC20[](tokenCount);
        for (uint i = 0; i < tokenCount; i++) {
            tokens[i] = converter.connectorTokens(i);
        }
    }
    
    function isGoodPool(IConverter converter) private view returns (bool) {

       (bool ok, bytes memory data) = address(converter).staticcall(abi.encodeWithSelector(
            IConverter(address(0)).conversionsEnabled.selector
        ));
        if (!ok || data.length == 0) {
            return false;
        }
        if (!abi.decode(data, (bool))) {
            return false;
        }
        
        return true;
    }
}