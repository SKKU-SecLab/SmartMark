


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;


interface IBancorConverterRegistry {

    function getLiquidityPools() external view returns (address[] memory);

}

interface IOwned {

    function owner() external view returns (IConverter);

}

contract ISmartToken is IOwned, IERC20 {

}


contract IConverter {

    function connectorTokens(uint) external view returns (IERC20);

}

contract BancorHelper {


    IBancorConverterRegistry public registry = IBancorConverterRegistry(0x06915Fb082D34fF4fE5105e5Ff2829Dc5e7c3c6D);

    function getConverters() public view returns (IConverter[] memory goodPools) {


        address[] memory smartTokens = registry.getLiquidityPools();

        IConverter[] memory converters = new IConverter[](smartTokens.length);
        uint goodPoolsCount;
        
        for (uint i = 0; i < smartTokens.length; i++) {
            converters[i] = ISmartToken(smartTokens[i]).owner();
            IERC20 firstToken = converters[i].connectorTokens(0);
            if (firstToken.balanceOf(address(converters[i])) > 0) {
                goodPoolsCount++;
            } else {
                converters[i] = IConverter(address(0));
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
    
    
}