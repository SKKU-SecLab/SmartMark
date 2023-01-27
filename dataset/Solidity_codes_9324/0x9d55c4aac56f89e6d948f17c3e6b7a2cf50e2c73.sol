
 
 

pragma solidity 0.5.10;


contract AddressListInterface {

    
    enum AddressStatus {
        Absent, // The address is not in the registry.
        Registered, // The address is in the registry.
        RegistrationRequested, // The address has a request to be added to the registry.
        ClearingRequested // The address has a request to be removed from the registry.
    }
    
    enum Party {
        None,      // Party per default when there is no challenger or requester. Also used for unconclusive ruling.
        Requester, // Party that made the request to change an address status.
        Challenger // Party that challenges the request to change an address status.
    }
    
    struct Address {
        AddressStatus status; // The status of the address.
        Request[] requests; // List of status change requests made for the address.
    }
    
    struct Request {
        bool disputed; // True if a dispute was raised.
        uint disputeID; // ID of the dispute, if any.
        uint submissionTime; // Time when the request was made. Used to track when the challenge period ends.
        bool resolved; // True if the request was executed and/or any disputes raised were resolved.
        address[3] parties; // Address of requester and challenger, if any.
        Round[] rounds; // Tracks each round of a dispute.
        Party ruling; // The final ruling given, if any.
        address arbitrator; // The arbitrator trusted to solve disputes for this request.
        bytes arbitratorExtraData; // The extra data for the trusted arbitrator of this request.
    }
    
    struct Round {
        uint[3] paidFees; // Tracks the fees paid by each side on this round.
        bool[3] hasPaid; // True when the side has fully paid its fee. False otherwise.
        uint feeRewards; // Sum of reimbursable fees and stake rewards available to the parties that made contributions to the side that ultimately wins a dispute.
        mapping(address => uint[3]) contributions; // Maps contributors to their contributions for each side.
    }
    
    function queryAddresses(address _cursor, uint _count, bool[8] calldata _filter, bool _oldestFirst) external view returns (address[] memory values, bool hasMore);

    
    function addressCount() external view returns (uint count);

    
    function addressList(uint _index) external view returns (address);

    
    function getAddressInfo(address _address)
        external
        view
        returns (
            AddressStatus status,
            uint numberOfRequests
        );

    
    function getRequestInfo(address _address, uint _request)
        external
        view
        returns (
            bool disputed,
            uint disputeID,
            uint submissionTime,
            bool resolved,
            address[3] memory parties,
            uint numberOfRounds,
            Party ruling,
            address arbitrator,
            bytes memory arbitratorExtraData
        );

}

contract AddressCount {

    
    function countByStatus(address _tcr, address _cursor, bool[8] calldata _filter, uint _count) external view returns (uint count, bool hasMore, address lastAddress) {

        uint cursorIndex;
        uint index = 0;
        bool oldestFirst = true;
        AddressListInterface addressTCR = AddressListInterface(_tcr);
        uint addressListLength = addressTCR.addressCount();

        if (_cursor == 0x0000000000000000000000000000000000000000)
            cursorIndex = 0;
        else {
            for (uint j = 0; j < addressTCR.addressCount(); j++) {
                if (addressTCR.addressList(j) == _cursor) {
                    cursorIndex = j;
                    break;
                }
            }
            require(cursorIndex != 0, "The cursor is invalid.");
        }

        for (
                uint i = cursorIndex == 0 ? (oldestFirst ? 0 : 1) : (oldestFirst ? cursorIndex + 1 : addressListLength - cursorIndex + 1);
                oldestFirst ? i < addressListLength : i <= addressListLength;
                i++
            ) { // Oldest or newest first.
            address addr = addressTCR.addressList(oldestFirst ? i : addressListLength - i);
            (AddressListInterface.AddressStatus status, uint numberOfRequests) = addressTCR.getAddressInfo(addr);
            (bool disputed,,,,,,,,) = addressTCR.getRequestInfo(addr, numberOfRequests-1);
            if (
                (_filter[0] && status == AddressListInterface.AddressStatus.Absent) ||
                (_filter[1] && status == AddressListInterface.AddressStatus.Registered) ||
                (_filter[2] && status == AddressListInterface.AddressStatus.RegistrationRequested && !disputed) ||
                (_filter[3] && status == AddressListInterface.AddressStatus.ClearingRequested && !disputed) ||
                (_filter[4] && status == AddressListInterface.AddressStatus.RegistrationRequested && disputed) ||
                (_filter[5] && status == AddressListInterface.AddressStatus.ClearingRequested && disputed)
            ) {
                if (index < _count) {
                    count++;
                    index++;
                } else {
                    hasMore = true;
                    lastAddress = addressTCR.addressList(oldestFirst ? i : addressListLength - i);
                    break;
                }
            }
        }
    }

}