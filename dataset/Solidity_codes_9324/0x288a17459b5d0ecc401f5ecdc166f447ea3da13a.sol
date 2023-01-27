pragma solidity ^0.7.0;

abstract contract Proxy {

    event ProxyImplementationUpdated(
        address indexed previousImplementation,
        address indexed newImplementation
    );


    receive() external payable virtual {
        revert("ETHER_REJECTED"); // explicit reject by default
    }

    fallback() external payable {
        _fallback();
    }


    function _fallback() internal {
        assembly {
            let implementationAddress := sload(
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
            )
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(
                gas(),
                implementationAddress,
                0x0,
                calldatasize(),
                0,
                0
            )
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
                case 0 {
                    revert(0, retSz)
                }
                default {
                    return(0, retSz)
                }
        }
    }

    function _setImplementation(address newImplementation, bytes memory data)
        internal
    {
        address previousImplementation;
        assembly {
            previousImplementation := sload(
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
            )
        }

        assembly {
            sstore(
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc,
                newImplementation
            )
        }

        emit ProxyImplementationUpdated(
            previousImplementation,
            newImplementation
        );

        if (data.length > 0) {
            (bool success, ) = newImplementation.delegatecall(data);
            if (!success) {
                assembly {
                    let returnDataSize := returndatasize()
                    returndatacopy(0, 0, returnDataSize)
                    revert(0, returnDataSize)
                }
            }
        }
    }
}// GPL-3.0
pragma solidity ^0.7.0;


interface ERC165 {

    function supportsInterface(bytes4 id) external view returns (bool);

}

contract EIP173Proxy is Proxy {


    event ProxyAdminTransferred(
        address indexed previousAdmin,
        address indexed newAdmin
    );


    constructor(
        address implementationAddress,
        address adminAddress,
        bytes memory data
    ) payable {
        _setImplementation(implementationAddress, data);
        _setProxyAdmin(adminAddress);
    }


    function proxyAdmin() external view returns (address) {

        return _proxyAdmin();
    }

    function supportsInterface(bytes4 id) external view returns (bool) {

        if (id == 0x01ffc9a7 || id == 0x7f5828d0) {
            return true;
        }
        if (id == 0xFFFFFFFF) {
            return false;
        }

        ERC165 implementation;
        assembly {
            implementation := sload(
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
            )
        }

        try implementation.supportsInterface(id) returns (bool support) {
            return support;
        } catch {
            return false;
        }
    }

    function transferProxyAdmin(address newAdmin) external onlyProxyAdmin {

        _setProxyAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external onlyProxyAdmin {

        _setImplementation(newImplementation, "");
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data)
        external
        payable
        onlyProxyAdmin
    {

        _setImplementation(newImplementation, data);
    }


    modifier onlyProxyAdmin() {

        require(msg.sender == _proxyAdmin(), "NOT_AUTHORIZED");
        _;
    }


    function _proxyAdmin() internal view returns (address adminAddress) {

        assembly {
            adminAddress := sload(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103
            )
        }
    }

    function _setProxyAdmin(address newAdmin) internal {

        address previousAdmin = _proxyAdmin();
        assembly {
            sstore(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
                newAdmin
            )
        }
        emit ProxyAdminTransferred(previousAdmin, newAdmin);
    }
}// GPL-3.0
pragma solidity ^0.7.0;


contract EIP173ProxyWithReceive is EIP173Proxy {

    constructor(
        address implementationAddress,
        address ownerAddress,
        bytes memory data
    ) payable EIP173Proxy(implementationAddress, ownerAddress, data) {}

    receive() external payable override {}
}