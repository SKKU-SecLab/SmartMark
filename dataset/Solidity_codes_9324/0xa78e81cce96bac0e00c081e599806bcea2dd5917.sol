
pragma solidity 0.7.6;

library VTable {

    bytes32 private constant _VTABLE_SLOT = 0x13f1d5ea37b1d7aca82fcc2879c3bddc731555698dfc87ad6057b416547bc657;

    struct VTableStore {
        address _owner;
        mapping(bytes4 => address) _delegates;
    }

    function instance() internal pure returns (VTableStore storage vtable) {

        bytes32 position = _VTABLE_SLOT;
        assembly {
            vtable.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function getOwner(VTableStore storage vtable) internal view returns (address) {

        return vtable._owner;
    }

    function setOwner(VTableStore storage vtable, address newOwner) internal {

        emit OwnershipTransferred(vtable._owner, newOwner);
        vtable._owner = newOwner;
    }

    event VTableUpdate(bytes4 indexed selector, address oldImplementation, address newImplementation);

    function getFunction(VTableStore storage vtable, bytes4 selector) internal view returns (address) {

        return vtable._delegates[selector];
    }

    function setFunction(
        VTableStore storage vtable,
        bytes4 selector,
        address module
    ) internal {

        emit VTableUpdate(selector, vtable._delegates[selector], module);
        vtable._delegates[selector] = module;
    }
}// MIT

pragma solidity 0.7.6;
pragma abicoder v2;


contract VTableUpdateModule {

    using VTable for VTable.VTableStore;

    event VTableUpdate(bytes4 indexed selector, address oldImplementation, address newImplementation);

    struct ModuleDefinition {
        address implementation;
        bytes4[] selectors;
    }

    function updateVTable(ModuleDefinition[] calldata modules) public {

        VTable.VTableStore storage vtable = VTable.instance();
        require(VTable.instance().getOwner() == msg.sender, 'VTableOwnership: caller is not the owner');

        for (uint256 i = 0; i < modules.length; ++i) {
            ModuleDefinition memory module = modules[i];
            for (uint256 j = 0; j < module.selectors.length; ++j) {
                vtable.setFunction(module.selectors[j], module.implementation);
            }
        }
    }
}