

pragma solidity ^0.8.0;

contract PonderwareTransferOfAuthority {





    address immutable oldPonderwareAddress;
    address payable immutable newPonderwareAddress;

    bool confirmedByOld = false;
    bool confirmedByNew = false;
    bool transferVoid = false;

    modifier addressIsAuthorized {

        require((msg.sender == oldPonderwareAddress) || (msg.sender == newPonderwareAddress), "Unauthorized");
        _;
    }

    modifier transferIsNotVoid {

        require(!transferVoid, "Transfer Of Authority Void");
        _;
    }

    modifier transferIsConfirmed {

        require((confirmedByOld && confirmedByNew), "Not Confirmed");
        _;
    }

    constructor(address payable newPonderwareAddress_) {
        oldPonderwareAddress = msg.sender;
        newPonderwareAddress = newPonderwareAddress_;
    }

    receive() external payable {
        newPonderwareAddress.transfer(msg.value);
    }

    function voidTransfer () public transferIsNotVoid addressIsAuthorized {
        require(!confirmedByOld, "Already Confirmed");
        transferVoid = true;
    }

    function confirm () public transferIsNotVoid addressIsAuthorized {
        if (msg.sender == newPonderwareAddress){
            confirmedByNew = true;
        } else {
            require(confirmedByNew, "New Not Confirmed");
            confirmedByOld = true;
        }
    }

    function whereIsPonderware() public view transferIsNotVoid transferIsConfirmed returns (address) {

        return newPonderwareAddress;
    }

}