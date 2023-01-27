


pragma solidity ^0.8.0;

interface FinderInterface {

    function changeImplementationAddress(bytes32 interfaceName, address implementationAddress) external;


    function getImplementationAddress(bytes32 interfaceName) external view returns (address);

}



pragma solidity ^0.8.0;

interface IBridge {

    function _chainID() external returns (uint8);


    function deposit(
        uint8 destinationChainID,
        bytes32 resourceID,
        bytes calldata data
    ) external;

}



pragma solidity ^0.8.0;

library OracleInterfaces {

    bytes32 public constant Oracle = "Oracle";
    bytes32 public constant IdentifierWhitelist = "IdentifierWhitelist";
    bytes32 public constant Store = "Store";
    bytes32 public constant FinancialContractsAdmin = "FinancialContractsAdmin";
    bytes32 public constant Registry = "Registry";
    bytes32 public constant CollateralWhitelist = "CollateralWhitelist";
    bytes32 public constant OptimisticOracle = "OptimisticOracle";
    bytes32 public constant Bridge = "Bridge";
    bytes32 public constant GenericHandler = "GenericHandler";
}



pragma solidity ^0.8.0;



abstract contract BeaconOracle {
    enum RequestState { NeverRequested, PendingRequest, Requested, PendingResolve, Resolved }

    struct Price {
        RequestState state;
        int256 price;
    }

    uint8 public currentChainID;

    mapping(bytes32 => Price) internal prices;

    FinderInterface public finder;

    event PriceRequestAdded(
        address indexed requester,
        uint8 indexed chainID,
        bytes32 indexed identifier,
        uint256 time,
        bytes ancillaryData
    );
    event PushedPrice(
        address indexed pusher,
        uint8 indexed chainID,
        bytes32 indexed identifier,
        uint256 time,
        bytes ancillaryData,
        int256 price
    );

    constructor(address _finderAddress, uint8 _chainID) {
        finder = FinderInterface(_finderAddress);
        currentChainID = _chainID;
    }

    modifier onlyGenericHandlerContract() {
        require(
            msg.sender == finder.getImplementationAddress(OracleInterfaces.GenericHandler),
            "Caller must be GenericHandler"
        );
        _;
    }

    function _requestPrice(
        uint8 chainID,
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData
    ) internal {
        bytes32 priceRequestId = _encodePriceRequest(chainID, identifier, time, ancillaryData);
        Price storage lookup = prices[priceRequestId];
        if (lookup.state == RequestState.NeverRequested) {
            lookup.state = RequestState.PendingRequest;
            emit PriceRequestAdded(msg.sender, chainID, identifier, time, ancillaryData);
        }
    }

    function _finalizeRequest(
        uint8 chainID,
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData
    ) internal {
        bytes32 priceRequestId = _encodePriceRequest(chainID, identifier, time, ancillaryData);
        Price storage lookup = prices[priceRequestId];
        require(lookup.state == RequestState.PendingRequest, "Price has not been requested");
        lookup.state = RequestState.Requested;
    }

    function _publishPrice(
        uint8 chainID,
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData,
        int256 price
    ) internal {
        bytes32 priceRequestId = _encodePriceRequest(chainID, identifier, time, ancillaryData);
        Price storage lookup = prices[priceRequestId];
        require(lookup.state == RequestState.Requested, "Price request is not currently pending");
        lookup.price = price;
        lookup.state = RequestState.PendingResolve;
        emit PushedPrice(msg.sender, chainID, identifier, time, ancillaryData, lookup.price);
    }

    function _finalizePublish(
        uint8 chainID,
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData
    ) internal {
        bytes32 priceRequestId = _encodePriceRequest(chainID, identifier, time, ancillaryData);
        Price storage lookup = prices[priceRequestId];
        require(lookup.state == RequestState.PendingResolve, "Price has not been published");
        lookup.state = RequestState.Resolved;
    }

    function _getBridge() internal view returns (IBridge) {
        return IBridge(finder.getImplementationAddress(OracleInterfaces.Bridge));
    }

    function _encodePriceRequest(
        uint8 chainID,
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(chainID, identifier, time, ancillaryData));
    }
}



pragma solidity ^0.8.0;

abstract contract OracleAncillaryInterface {

    function requestPrice(
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData
    ) public virtual;

    function hasPrice(
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData
    ) public view virtual returns (bool);


    function getPrice(
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData
    ) public view virtual returns (int256);
}



pragma solidity ^0.8.0;


contract SourceOracle is BeaconOracle {

    constructor(address _finderAddress, uint8 _chainID) BeaconOracle(_finderAddress, _chainID) {}


    function publishPrice(
        uint8 sinkChainID,
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData
    ) public {

        require(_getOracle().hasPrice(identifier, time, ancillaryData), "DVM has not resolved price");
        int256 price = _getOracle().getPrice(identifier, time, ancillaryData);
        _publishPrice(sinkChainID, identifier, time, ancillaryData, price);

        _getBridge().deposit(
            sinkChainID,
            getResourceId(),
            formatMetadata(sinkChainID, identifier, time, ancillaryData, price)
        );
    }

    function validateDeposit(
        uint8 sinkChainID,
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData,
        int256 price
    ) public {

        bytes32 priceRequestId = _encodePriceRequest(sinkChainID, identifier, time, ancillaryData);
        Price storage lookup = prices[priceRequestId];
        require(lookup.price == price, "Unexpected price published");
        _finalizePublish(sinkChainID, identifier, time, ancillaryData);
    }



    function executeRequestPrice(
        uint8 sinkChainID,
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData
    ) public onlyGenericHandlerContract() {

        _requestPrice(sinkChainID, identifier, time, ancillaryData);
        _finalizeRequest(sinkChainID, identifier, time, ancillaryData);
        _getOracle().requestPrice(identifier, time, ancillaryData);
    }

    function getResourceId() public view returns (bytes32) {

        return keccak256(abi.encode("Oracle", currentChainID));
    }

    function _getOracle() internal view returns (OracleAncillaryInterface) {

        return OracleAncillaryInterface(finder.getImplementationAddress(OracleInterfaces.Oracle));
    }

    function formatMetadata(
        uint8 chainID,
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData,
        int256 price
    ) public pure returns (bytes memory) {

        bytes memory metadata = abi.encode(chainID, identifier, time, ancillaryData, price);
        return abi.encodePacked(metadata.length, metadata);
    }
}