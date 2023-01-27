pragma solidity ^0.6.0;

abstract contract Proxy {

    event ProxyImplementationUpdated(
        address indexed previousImplementation,
        address indexed newImplementation
    );


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


    receive() external payable {
        _fallback();
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
}// MIT
pragma solidity ^0.6.0;


contract TransparentProxy is Proxy {


    constructor(
        address implementationAddress,
        bytes memory data,
        address adminAddress
    ) public {
        _setImplementation(implementationAddress, data);
        _setAdmin(adminAddress);
    }


    function changeImplementation(
        address newImplementation,
        bytes calldata data
    ) external ifAdmin {

        _setImplementation(newImplementation, data);
    }

    function proxyAdmin() external ifAdmin returns (address) {

        return _admin();
    }

    function changeProxyAdmin(address newAdmin) external ifAdmin {

        uint256 disabled;
        assembly {
            disabled := sload(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6102
            )
        }
        require(disabled == 0, "changeAdmin has been disabled");

        _setAdmin(newAdmin);
    }

    function disableChangeProxyAdmin() external ifAdmin {

        assembly {
            sstore(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6102,
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            )
        }
    }


    modifier ifAdmin() {

        if (msg.sender == _admin()) {
            _;
        } else {
            _fallback();
        }
    }


    function _admin() internal view returns (address adminAddress) {

        assembly {
            adminAddress := sload(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103
            )
        }
    }

    function _setAdmin(address newAdmin) internal {

        assembly {
            sstore(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
                newAdmin
            )
        }
    }
}