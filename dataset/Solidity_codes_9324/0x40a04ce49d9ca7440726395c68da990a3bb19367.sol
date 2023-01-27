
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


contract WhitelistChecker is InteractiveNotificationReceiver {

    error TakerIsNotWhitelisted();

    IWhitelistRegistry public immutable whitelistRegistry;

    constructor(IWhitelistRegistry _whitelistRegistry) {
        whitelistRegistry = _whitelistRegistry;
    }

    function notifyFillOrder(address taker, address, address, uint256, uint256, bytes memory) external view {

        if (whitelistRegistry.status(taker) != 1) revert TakerIsNotWhitelisted();
    }
}