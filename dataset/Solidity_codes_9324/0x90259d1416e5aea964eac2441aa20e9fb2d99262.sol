
pragma solidity ^0.8.13;


interface IOwnableFeature {


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    event Migrated(address caller, address migrator, address newOwner);

    function transferOwnership(address newOwner) external;


    function owner() external view returns (address ownerAddress);


    function migrate(address target, bytes calldata data, address newOwner) external;

}// Apache-2.0

pragma solidity ^0.8.13;


interface ISimpleFunctionRegistryFeature {


    event ProxyFunctionUpdated(bytes4 indexed selector, address oldImpl, address newImpl);

    function registerMethods(address impl, bytes4[] calldata methodIDs) external;


    function rollback(bytes4 selector, address targetImpl) external;


    function extend(bytes4 selector, address impl) external;


    function getRollbackLength(bytes4 selector) external view returns (uint256);


    function getRollbackEntryAtIndex(bytes4 selector, uint256 idx)
        external
        view
        returns (address impl);

}// Apache-2.0

pragma solidity ^0.8.13;



abstract contract FixinCommon {

    address internal immutable _implementation;

    modifier onlySelf() virtual {
        if (msg.sender != address(this)) {
            revert("ONLY_CALL_BY_SELF_ERROR");
        }
        _;
    }

    modifier onlyOwner() virtual {
        {
            address owner = IOwnableFeature(address(this)).owner();
            if (msg.sender != owner) {
                revert("ONLY_OWNER_ERROR");
            }
        }
        _;
    }

    constructor() {
        _implementation = address(this);
    }

    function _registerFeatureFunction(bytes4 selector) internal {
        ISimpleFunctionRegistryFeature(address(this)).extend(selector, _implementation);
    }

    function _encodeVersion(uint32 major, uint32 minor, uint32 revision)
        internal
        pure
        returns (uint256 encodedVersion)
    {
        return (uint256(major) << 64) | (uint256(minor) << 32) | uint256(revision);
    }
}// Apache-2.0

pragma solidity ^0.8.13;


library LibStorage {


    uint256 constant STORAGE_ID_PROXY = 1 << 128;
    uint256 constant STORAGE_ID_SIMPLE_FUNCTION_REGISTRY = 2 << 128;
    uint256 constant STORAGE_ID_OWNABLE = 3 << 128;
    uint256 constant STORAGE_ID_COMMON_NFT_ORDERS = 4 << 128;
    uint256 constant STORAGE_ID_ERC721_ORDERS = 5 << 128;
    uint256 constant STORAGE_ID_ERC1155_ORDERS = 6 << 128;
}// Apache-2.0

pragma solidity ^0.8.13;



library LibProxyStorage {


    struct Storage {
        mapping(bytes4 => address) impls;
    }

    function getStorage() internal pure returns (Storage storage stor) {

        uint256 storageSlot = LibStorage.STORAGE_ID_PROXY;
        assembly { stor.slot := storageSlot }
    }
}// Apache-2.0

pragma solidity ^0.8.13;



library LibSimpleFunctionRegistryStorage {


    struct Storage {
        mapping(bytes4 => address[]) implHistory;
    }

    function getStorage() internal pure returns (Storage storage stor) {

        uint256 storageSlot = LibStorage.STORAGE_ID_SIMPLE_FUNCTION_REGISTRY;
        assembly { stor.slot := storageSlot }
    }
}// Apache-2.0

pragma solidity ^0.8.13;

library LibBootstrap {


    bytes4 internal constant BOOTSTRAP_SUCCESS = 0xd150751b;

    function delegatecallBootstrapFunction(address target, bytes memory data) internal {

        (bool success, bytes memory resultData) = target.delegatecall(data);
        if (!success ||
            resultData.length != 32 ||
            abi.decode(resultData, (bytes4)) != BOOTSTRAP_SUCCESS)
        {
            revert("BOOTSTRAP_CALL_FAILED");
        }
    }
}// Apache-2.0

pragma solidity ^0.8.13;


interface IFeature {



    function FEATURE_NAME() external view returns (string memory name);


    function FEATURE_VERSION() external view returns (uint256 version);

}// Apache-2.0

pragma solidity ^0.8.13;



contract SimpleFunctionRegistryFeature is
    IFeature,
    ISimpleFunctionRegistryFeature,
    FixinCommon
{

    string public constant override FEATURE_NAME = "SimpleFunctionRegistry";
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);

    function bootstrap() external returns (bytes4 success) {

        _extend(this.registerMethods.selector, _implementation);
        _extend(this.extend.selector, _implementation);
        _extend(this._extendSelf.selector, _implementation);
        _extend(this.rollback.selector, _implementation);
        _extend(this.getRollbackLength.selector, _implementation);
        _extend(this.getRollbackEntryAtIndex.selector, _implementation);
        return LibBootstrap.BOOTSTRAP_SUCCESS;
    }

    function registerMethods(address impl, bytes4[] calldata methodIDs)
        external
        override
        onlyOwner
    {

        (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        ) = _getStorages();

        for (uint256 i = 0; i < methodIDs.length; i++) {
            bytes4 selector = methodIDs[i];
            address oldImpl = proxyStor.impls[selector];
            address[] storage history = stor.implHistory[selector];
            history.push(oldImpl);
            proxyStor.impls[selector] = impl;
            emit ProxyFunctionUpdated(selector, oldImpl, impl);
        }
    }

    function rollback(bytes4 selector, address targetImpl) external override onlyOwner {

        (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        ) = _getStorages();

        address currentImpl = proxyStor.impls[selector];
        if (currentImpl == targetImpl) {
            return;
        }
        address[] storage history = stor.implHistory[selector];
        uint256 i = history.length;
        for (; i > 0; --i) {
            address impl = history[i - 1];
            history.pop();
            if (impl == targetImpl) {
                break;
            }
        }
        if (i == 0) {
            revert("NOT_IN_ROLLBACK_HISTORY");
        }
        proxyStor.impls[selector] = targetImpl;
        emit ProxyFunctionUpdated(selector, currentImpl, targetImpl);
    }

    function extend(bytes4 selector, address impl) external override onlyOwner {

        _extend(selector, impl);
    }

    function _extendSelf(bytes4 selector, address impl) external onlySelf {

        _extend(selector, impl);
    }

    function getRollbackLength(bytes4 selector) external override view returns (uint256) {

        return LibSimpleFunctionRegistryStorage.getStorage().implHistory[selector].length;
    }

    function getRollbackEntryAtIndex(bytes4 selector, uint256 idx)
        external
        override
        view
        returns (address impl)
    {

        return LibSimpleFunctionRegistryStorage.getStorage().implHistory[selector][idx];
    }

    function _extend(bytes4 selector, address impl) private {

        (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        ) = _getStorages();

        address oldImpl = proxyStor.impls[selector];
        address[] storage history = stor.implHistory[selector];
        history.push(oldImpl);
        proxyStor.impls[selector] = impl;
        emit ProxyFunctionUpdated(selector, oldImpl, impl);
    }

    function _getStorages()
        private
        pure
        returns (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        )
    {

        return (
            LibSimpleFunctionRegistryStorage.getStorage(),
            LibProxyStorage.getStorage()
        );
    }
}