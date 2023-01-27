
pragma solidity 0.6.12;


abstract contract VersionedInitializable {
    uint256 internal lastInitializedRevision = 0;

    modifier initializer() {
        uint256 revision = getRevision();
        require(revision > lastInitializedRevision, "Contract instance has already been initialized");

        lastInitializedRevision = revision;

        _;

    }

    function getRevision() internal pure virtual returns(uint256);


    uint256[50] private ______gap;
}


contract ChainlinkSourcesRegistry is VersionedInitializable {

    mapping (address => address) public aggregatorsOfAssets;
    
    event AggregatorUpdated(address token, address aggregator);
    
    uint256 public constant REVISION = 1;
    
    function getRevision() internal pure override returns (uint256) {

        return REVISION;
    }
    
    function initialize() external initializer {}

    
    function updateAggregators(address[] memory assets, address[] memory aggregators) external {

        require(isManager(msg.sender), "INVALID_MANAGER");
        
        for(uint256 i = 0; i < assets.length; i++) {
            aggregatorsOfAssets[assets[i]] = aggregators[i];
            emit AggregatorUpdated(assets[i], aggregators[i]);
        }
    }
    
    function isManager(address caller) public pure returns(bool) {

        return (caller == address(0x51F22ac850D29C879367A77D241734AcB276B815) || caller == address(0x49598E2F08D11980E06C5507070F6dd97CE8f0bb));
    }
}