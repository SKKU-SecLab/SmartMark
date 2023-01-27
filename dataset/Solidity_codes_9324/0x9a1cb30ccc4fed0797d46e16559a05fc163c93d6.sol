
pragma solidity 0.8.11;
pragma abicoder v1;

interface InteractiveNotificationReceiver {

    function notifyFillOrder(
        address taker,
        address makerAsset,
        address takerAsset,
        uint256 makingAmount,
        uint256 takingAmount,
        bytes memory interactiveData
    ) external;

}// MIT

pragma solidity 0.8.11;

interface IWhitelistRegistry {

    function status(address addr) external view returns(uint256);

}// MIT

pragma solidity 0.8.11;

library ArgumentsDecoder {

    function decodeUint256(bytes memory data) internal pure returns(uint256) {

        uint256 value;
        assembly { // solhint-disable-line no-inline-assembly
            value := mload(add(data, 0x20))
        }
        return value;
    }

    function decodeBool(bytes memory data) internal pure returns(bool) {

        bool value;
        assembly { // solhint-disable-line no-inline-assembly
            value := eq(mload(add(data, 0x20)), 1)
        }
        return value;
    }

    function decodeTargetAndCalldata(bytes memory data) internal pure returns(address, bytes memory) {

        address target;
        bytes memory args;
        assembly {  // solhint-disable-line no-inline-assembly
            target := mload(add(data, 0x14))
            args := add(data, 0x14)
            mstore(args, sub(mload(data), 0x14))
        }
        return (target, args);
    }

    function decodeTargetAndData(bytes calldata data) internal pure returns(address, bytes calldata) {

        address target;
        bytes calldata args;
        assembly {  // solhint-disable-line no-inline-assembly
            target := shr(96, calldataload(data.offset))
        }
        args = data[20:];
        return (target, args);
    }
}// MIT

pragma solidity 0.8.11;


contract WhitelistChecker is InteractiveNotificationReceiver {

    using ArgumentsDecoder for bytes;

    error TakerIsNotWhitelisted();

    IWhitelistRegistry public immutable whitelistRegistry;

    constructor(IWhitelistRegistry _whitelistRegistry) {
        whitelistRegistry = _whitelistRegistry;
    }

    function notifyFillOrder(
        address taker,
        address makerAsset,
        address takerAsset,
        uint256 makingAmount,
        uint256 takingAmount,
        bytes calldata nextInteractiveData
    ) external override {

        if (whitelistRegistry.status(taker) != 1) revert TakerIsNotWhitelisted();

        if (nextInteractiveData.length != 0) {
            (address interactionTarget, bytes calldata interactionData) = nextInteractiveData.decodeTargetAndData();

            InteractiveNotificationReceiver(interactionTarget).notifyFillOrder(
                taker, makerAsset, takerAsset, makingAmount, takingAmount, interactionData
            );
        }
    }
}