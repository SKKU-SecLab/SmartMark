



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

    
    mapping(address => bool) public zaTokens;
    mapping(address => bool) public neutralTokens;
    uint256 public neutralPrice = 1e18; // The price for a neutral address
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

        zaTokens[address(0x4dEaD8338cF5cb31122859b2Aec2b60416D491f0)] = true;
        zaTokens[address(0x6B2e59b8EbE61B5ee0EF30021b7740C63F597654)] = true;
        zaTokens[address(0xfa8c04d342FBe24d871ea77807b1b93eC42A57ea)] = true;
        zaTokens[address(0x89Cc19cece29acbD41F931F3dD61A10C1627E4c4)] = true;
        
        neutralTokens[address(0x8e769EAA31375D13a1247dE1e64987c28Bed987E)] = true;
        neutralTokens[address(0x739D93f2b116E6aD754e173655c635Bd5D8d664c)] = true;
        neutralTokens[address(0xfea2468C55E80aB9487f6E6189C79Ce31E1f9Ea7)] = true;
        neutralTokens[address(0x939D73E26138f4B483368F96d17D2B4dCc5bc84f)] = true;
    }
    
    function addNewCustomZaToken(address _address) external onlyGovernance {

        zaTokens[_address] = true;
    }
    
    function removeCustomZaToken(address _address) external onlyGovernance {

        zaTokens[_address] = false;
    }
    
    function isZaToken(address _address) internal view returns (bool) {

        return zaTokens[_address];
    }
    
    function setNeutralPrice(uint256 _price) external onlyGovernance {

        neutralPrice = _price;
    }
    
    function addNewNeutralToken(address _address) external onlyGovernance {

        neutralTokens[_address] = true;
    }
    
    function removeNeutralToken(address _address) external onlyGovernance {

        neutralTokens[_address] = false;
    }
    
    function isNeutralToken(address _address) internal view returns (bool) {

        return neutralTokens[_address];
    }
    
    function getPrice(address _address) public view returns (uint256) {

        
        if(isNeutralToken(_address) == true){
            return neutralPrice;
        }
        
        AggregatorV3Interface ethOracle = AggregatorV3Interface(address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419));
        ( , int intEthPrice, , , ) = ethOracle.latestRoundData(); // We only want the answer 
        uint256 ethPrice = uint256(intEthPrice);
        
        address underlyingAsset = _address;
        if(isZaToken(_address) == true){
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