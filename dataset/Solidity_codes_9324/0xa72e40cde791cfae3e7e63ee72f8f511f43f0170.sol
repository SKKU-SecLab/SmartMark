
pragma solidity ^0.8.11;

interface FeedInterface {

    function transmitters() external view returns (address[] memory);


    function transferPayeeship(address _transmitter, address _proposed) external;


    function acceptPayeeship(address _transmitter) external;

}

contract PayeeshipTransferer {

    error DelegateCallFail(bytes data);

    function canRequestChangeOfPayeeship(FeedInterface[] memory targets, address payee)
        external
        view
        returns (bool canRequest, FeedInterface[] memory wrongPermissions)
    {

        wrongPermissions = new FeedInterface[](targets.length);
        uint256 wrongPermissionsCounter = 0;
        for (uint256 i = 0; i < targets.length; i++) {
            FeedInterface targetContract = targets[i];
            address[] memory transmitters = targetContract.transmitters();

            for (uint256 j = 0; j < transmitters.length; j++) {
                if (transmitters[j] == payee) {
                    break;
                }
                if (j == transmitters.length - 1) {
                    wrongPermissions[wrongPermissionsCounter] = targetContract;
                    wrongPermissionsCounter++;
                }
            }

            if (transmitters.length == 0) {
                wrongPermissions[wrongPermissionsCounter] = targetContract;
                wrongPermissionsCounter++;
            }
        }

        if (wrongPermissionsCounter == 0) {
            canRequest = true;
        }
        assembly {
            mstore(wrongPermissions, wrongPermissionsCounter)
        }
    }

    function requestChangeOfPayeeship(address[] memory targets, address newPayee) external {

        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, bytes memory data) = targets[i].delegatecall(abi.encodeWithSelector(FeedInterface.transferPayeeship.selector, msg.sender, newPayee));
            if (!success) revert DelegateCallFail(data);
        }
    }

    function acceptChangeOfPayeeship(address[] memory targets, address oldPayee) external {

        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, bytes memory data) = targets[i].delegatecall(abi.encodeWithSelector(FeedInterface.acceptPayeeship.selector, msg.sender, oldPayee));
            if (!success) revert DelegateCallFail(data);
        }
    }
}