

pragma solidity =0.6.6;

contract StabilizePoolRebalancer {

    
    mapping(address => uint256) public poolTokens;

    address public owner;
    
    constructor() public {
        owner = msg.sender;
        insertInitialTokens();
    }
    
    modifier onlyGovernance() {

        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function insertInitialTokens() internal {

        poolTokens[address(0x8e769EAA31375D13a1247dE1e64987c28Bed987E)] = 1e18;
        poolTokens[address(0x739D93f2b116E6aD754e173655c635Bd5D8d664c)] = 1e18;
        poolTokens[address(0x93B97BBb3F65EC39ea6041bF92FA998e5434E858)] = 1e18;
        poolTokens[address(0xD469BB16116443F389EfEF407D73EF7Ab0Ad96Ce)] = 1e18;
        poolTokens[address(0x27E8d93D27f55130B1870d8EF2BCE847C08A8191)] = 1e18;
    }
    
    function addNewPoolToken(address _address, uint256 _startPrice) external onlyGovernance {

        poolTokens[_address] = _startPrice;
    }
    
    function removePoolToken(address _address) external onlyGovernance {

        poolTokens[_address] = 0;
    }
    
    function updatePoolTokens(address[] calldata _addresses, uint256[] calldata _prices) external onlyGovernance {

        uint256 length = _addresses.length;
        for(uint256 i = 0; i < length; i++){
            poolTokens[_addresses[i]] = _prices[i];
        }
    }
    
    function governanceChange(address _address) external onlyGovernance {

        owner = _address;
    }
    
    function getPrice(address _address) public view returns (uint256) {

        uint256 _price = poolTokens[_address];
        if(_price == 0){ return 1e18; } // It returns a neutral price if pool token not found
        return _price;
    }

}