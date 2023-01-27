
pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(address implementation, bytes32 salt, address deployer) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt) internal view returns (address predicted) {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}// MIT

pragma solidity ^0.8.0;

interface ISmartInvoiceFactory {

    function create(
        address _client,
        address _provider,
        uint8 _resolverType,
        address _resolver,
        address _token,
        uint256[] calldata _amounts,
        uint256 _terminationTime,
        bytes32 _details
    ) external returns (address);


    function createDeterministic(
        address _client,
        address _provider,
        uint8 _resolverType,
        address _resolver,
        address _token,
        uint256[] calldata _amounts,
        uint256 _terminationTime,
        bytes32 _details,
        bytes32 _salt
    ) external returns (address);


    function predictDeterministicAddress(bytes32 _salt)
        external
        returns (address);

}// MIT

pragma solidity ^0.8.0;

interface ISmartInvoice {

    function init(
        address _client,
        address _provider,
        uint8 _resolverType,
        address _resolver,
        address _token,
        uint256[] calldata _amounts,
        uint256 _terminationTime, // exact termination date in seconds since epoch
        uint256 _resolutionRate,
        bytes32 _details,
        address _wrappedNativeToken
    ) external;


    function release() external;


    function release(uint256 _milestone) external;


    function releaseTokens(address _token) external;


    function withdraw() external;


    function withdrawTokens(address _token) external;


    function lock(bytes32 _details) external payable;


    function resolve(
        uint256 _clientAward,
        uint256 _providerAward,
        bytes32 _details
    ) external;

}// MIT

pragma solidity ^0.8.0;


contract SmartInvoiceFactory is ISmartInvoiceFactory {

    uint256 public invoiceCount = 0;
    mapping(uint256 => address) internal _invoices;
    mapping(address => uint256) public resolutionRates;

    event LogNewInvoice(
        uint256 indexed index,
        address invoice,
        uint256[] amounts
    );
    event UpdateResolutionRate(
        address indexed resolver,
        uint256 indexed resolutionRate,
        bytes32 details
    );

    address public immutable implementation;
    address public immutable wrappedNativeToken;

    constructor(address _implementation, address _wrappedNativeToken) {
        require(_implementation != address(0), "invalid implementation");
        require(
            _wrappedNativeToken != address(0),
            "invalid wrappedNativeToken"
        );
        implementation = _implementation;
        wrappedNativeToken = _wrappedNativeToken;
    }

    function _init(
        address _invoiceAddress,
        address _client,
        address _provider,
        uint8 _resolverType,
        address _resolver,
        address _token,
        uint256[] calldata _amounts,
        uint256 _terminationTime,
        bytes32 _details
    ) internal {

        uint256 resolutionRate = resolutionRates[_resolver];
        if (resolutionRate == 0) {
            resolutionRate = 20;
        }

        ISmartInvoice(_invoiceAddress).init(
            _client,
            _provider,
            _resolverType,
            _resolver,
            _token,
            _amounts,
            _terminationTime,
            resolutionRate,
            _details,
            wrappedNativeToken
        );

        uint256 invoiceId = invoiceCount;
        _invoices[invoiceId] = _invoiceAddress;
        invoiceCount = invoiceCount + 1;

        emit LogNewInvoice(invoiceId, _invoiceAddress, _amounts);
    }

    function create(
        address _client,
        address _provider,
        uint8 _resolverType,
        address _resolver,
        address _token,
        uint256[] calldata _amounts,
        uint256 _terminationTime,
        bytes32 _details
    ) external override returns (address) {

        address invoiceAddress = Clones.clone(implementation);

        _init(
            invoiceAddress,
            _client,
            _provider,
            _resolverType,
            _resolver,
            _token,
            _amounts,
            _terminationTime,
            _details
        );

        return invoiceAddress;
    }

    function predictDeterministicAddress(bytes32 _salt)
        external
        view
        override
        returns (address)
    {

        return Clones.predictDeterministicAddress(implementation, _salt);
    }

    function createDeterministic(
        address _client,
        address _provider,
        uint8 _resolverType,
        address _resolver,
        address _token,
        uint256[] calldata _amounts,
        uint256 _terminationTime,
        bytes32 _details,
        bytes32 _salt
    ) external override returns (address) {

        address invoiceAddress =
            Clones.cloneDeterministic(implementation, _salt);

        _init(
            invoiceAddress,
            _client,
            _provider,
            _resolverType,
            _resolver,
            _token,
            _amounts,
            _terminationTime,
            _details
        );

        return invoiceAddress;
    }

    function getInvoiceAddress(uint256 _index) public view returns (address) {

        return _invoices[_index];
    }

    function updateResolutionRate(uint256 _resolutionRate, bytes32 _details)
        external
    {

        resolutionRates[msg.sender] = _resolutionRate;
        emit UpdateResolutionRate(msg.sender, _resolutionRate, _details);
    }
}