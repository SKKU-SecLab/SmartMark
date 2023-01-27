pragma solidity >=0.6.0;

library Bytes32AddressLib {

    function fromLast20Bytes(bytes32 bytesValue)
        internal
        pure
        returns (address)
    {

        return address(uint160(uint256(bytesValue)));
    }

    function fillLast12Bytes(address addressValue)
        internal
        pure
        returns (bytes32)
    {

        return bytes32(bytes20(addressValue));
    }
}// AGPL-3.0-only
pragma solidity >=0.6.0;


library CREATE3 {

    using Bytes32AddressLib for bytes32;

    bytes internal constant PROXY_BYTECODE =
        hex"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3";

    bytes32 internal constant PROXY_BYTECODE_HASH = keccak256(PROXY_BYTECODE);

    function deploy(
        bytes32 salt,
        bytes memory creationCode,
        uint256 value
    ) internal returns (address deployed) {

        bytes memory proxyChildBytecode = PROXY_BYTECODE;

        address proxy;
        assembly {
            proxy := create2(
                0,
                add(proxyChildBytecode, 32),
                mload(proxyChildBytecode),
                salt
            )
        }
        require(proxy != address(0), "DEPLOYMENT_FAILED");

        deployed = getDeployed(salt);
        (bool success, ) = proxy.call{value: value}(creationCode);
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(deployed)
        }
        require(success && codeSize != 0, "INITIALIZATION_FAILED");
    }

    function getDeployed(bytes32 salt) internal view returns (address) {

        address proxy = keccak256(
            abi.encodePacked(
                bytes1(0xFF),
                address(this),
                salt,
                PROXY_BYTECODE_HASH
            )
        ).fromLast20Bytes();

        return
            keccak256(
                abi.encodePacked(
                    hex"d6_94",
                    proxy,
                    hex"01" // Nonce of the proxy contract (1)
                )
            ).fromLast20Bytes();
    }
}/**
 *Submitted for verification at Etherscan.io on 2020-10-09
 */


pragma solidity 0.6.12;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

abstract contract Proxy {
    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    function _implementation() internal view virtual returns (address);

    function _delegate(address implementation) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _willFallback() internal virtual {}

    function _fallback() internal {
        _willFallback();
        _delegate(_implementation());
    }
}

contract UpgradeabilityProxy is Proxy {

    constructor(address _logic, bytes memory _data) public payable {
        assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        if (_data.length > 0) {
            (bool success, ) = _logic.delegatecall(_data);
            require(success);
        }
    }

    event Upgraded(address indexed implementation);

    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _implementation() internal view override returns (address impl) {

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) internal {

        require(Address.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}

contract AdminUpgradeabilityProxy is UpgradeabilityProxy {

    constructor(
        address _logic,
        address _admin,
        bytes memory _data
    ) public payable UpgradeabilityProxy(_logic, _data) {
        assert(ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _setAdmin(_admin);
    }

    event AdminChanged(address previousAdmin, address newAdmin);


    bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier ifAdmin() {

        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address) {

        return _admin();
    }

    function implementation() external ifAdmin returns (address) {

        return _implementation();
    }

    function changeAdmin(address newAdmin) external ifAdmin {

        require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeTo(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {

        _upgradeTo(newImplementation);
        (bool success, ) = newImplementation.delegatecall(data);
        require(success);
    }

    function _admin() internal view returns (address adm) {

        bytes32 slot = ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    function _setAdmin(address newAdmin) internal {

        bytes32 slot = ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

    function _willFallback() internal virtual override {

        require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
        super._willFallback();
    }
}// GPL-3.0
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



contract DeterministicFactory {

    event NewContractDeployed(address proxy, address logic, address admin);

    function deploy(
        bytes32 salt,
        uint256 value,
        address _logic,
        address _admin,
        bytes memory _data
    ) public returns (address proxy) {

        proxy = CREATE3.deploy(
            salt,
            abi.encodePacked(
                type(AdminUpgradeabilityProxy).creationCode,
                abi.encode(_logic, _admin, _data)
            ),
            value
        );
        emit NewContractDeployed(proxy, _logic, _admin);
    }

    function getDeployed(bytes32 salt) public view returns (address) {

        return CREATE3.getDeployed(salt);
    }
}