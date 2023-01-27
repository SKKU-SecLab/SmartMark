pragma solidity >=0.7.0 <0.9.0;

contract Enum {

    enum Operation {Call, DelegateCall}
}
pragma solidity >=0.7.0 <0.9.0;

contract Executor {

    function execute(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 txGas
    ) internal returns (bool success) {

        if (operation == Enum.Operation.DelegateCall) {
            assembly {
                success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)
            }
        } else {
            assembly {
                success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)
            }
        }
    }
}
pragma solidity >=0.7.0 <0.9.0;


contract WalliroSimulateTxAccessor is Executor {

    address private immutable accessorSingleton;

    constructor() {
        accessorSingleton = address(this);
    }

    modifier onlyDelegateCall() {

        require(address(this) != accessorSingleton, "SimulateTxAccessor should only be called via delegatecall");
        _;
    }

    function simulate(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    )
        external
        onlyDelegateCall()
        returns (
            uint256 estimate,
            bool success,
            bytes memory returnData
        )
    {

        uint256 startGas = gasleft();
        success = execute(to, value, data, operation, gasleft());
        estimate = startGas - gasleft();
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, add(returndatasize(), 0x20)))
            mstore(ptr, returndatasize())
            returndatacopy(add(ptr, 0x20), 0, returndatasize())
            returnData := ptr
        }
    }
}
