


pragma solidity ^0.6.6;

interface IPriceOracleGetter {

    function getAssetPrice(address _asset) external view returns (uint256);

    function getAssetsPrices(address[] calldata _assets) external view returns(uint256[] memory);

    function getSourceOfAsset(address _asset) external view returns(address);

    function getFallbackOracle() external view returns(address);

}

interface LendingPoolAddressesProvider {

    function getPriceOracle() external view returns (address);

}

interface AggregatorV3Interface {

  function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

}

interface zaToken {

    function underlyingAsset() external view returns (address);

}

contract StabilizePriceOracle {

    
    address[] public zTokenList;
    address public owner;
    
    constructor() public {
        owner = msg.sender;
        insertCustomTokens(); // zTokens have underlying asset
    }
    
    modifier onlyGovernance() {

        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function insertCustomTokens() internal {

        zTokenList.push(address(0x1D107B258a2BA3a87B301e635dDc336cfDDe153b));
        
    }
    
    function addNewCustomToken(address _address) external onlyGovernance {

        zTokenList.push(address(_address));
    }
    
    function removeCustomToken(address _address) external onlyGovernance {

        uint256 length = zTokenList.length;
        for(uint256 i = 0; i < length; i++){
            if(zTokenList[i] == _address){
                for(uint256 i2 = i; i2 < length-1; i2++){
                    zTokenList[i2] = zTokenList[i2 + 1]; // Shift the data down one
                }
                zTokenList.pop(); //Remove last element
                break;
            }
        }
    }
    
    function isZToken(address _address) internal view returns (bool) {

        uint256 length = zTokenList.length;
        for(uint256 i = 0; i < length; i++){
            if(_address == zTokenList[i]){
                return true;
            }
        }
        return false;
    }
    
    function getPrice(address _address) public view returns (uint256) {

        
        AggregatorV3Interface ethOracle = AggregatorV3Interface(address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419));
        ( , int intEthPrice, , , ) = ethOracle.latestRoundData(); // We only want the answer 
        uint256 ethPrice = uint256(intEthPrice);
        
        address underlyingAsset = _address;
        if(isZToken(_address) == true){
            underlyingAsset = zaToken(_address).underlyingAsset();
        }
        
        LendingPoolAddressesProvider provider = LendingPoolAddressesProvider(address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8));
        address priceOracleAddress = provider.getPriceOracle();
        IPriceOracleGetter priceOracle = IPriceOracleGetter(priceOracleAddress);

        uint256 price = priceOracle.getAssetPrice(underlyingAsset); // This is relative to Ethereum, need to convert to USD
        ethPrice = ethPrice / 10000; // We only care about 4 decimal places from Chainlink priceOracleAddress
        price = price * ethPrice / 10000; // Convert to Wei format
        return price;
    }

}