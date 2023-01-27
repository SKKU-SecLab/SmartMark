


pragma solidity 0.5.17;

library CappedMath {

    uint constant private UINT_MAX = 2**256 - 1;

    function addCap(uint _a, uint _b) internal pure returns (uint) {

        uint c = _a + _b;
        return c >= _a ? c : UINT_MAX;
    }

    function subCap(uint _a, uint _b) internal pure returns (uint) {

        if (_b > _a)
            return 0;
        else
            return _a - _b;
    }

    function mulCap(uint _a, uint _b) internal pure returns (uint) {

        if (_a == 0)
            return 0;

        uint c = _a * _b;
        return c / _a == _b ? c : UINT_MAX;
    }
}


interface IArbitrator {


    enum DisputeStatus {Waiting, Appealable, Solved}


    event DisputeCreation(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    event AppealPossible(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    event AppealDecision(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    function createDispute(uint _choices, bytes calldata _extraData) external payable returns(uint disputeID);


    function arbitrationCost(bytes calldata _extraData) external view returns(uint cost);


    function appeal(uint _disputeID, bytes calldata _extraData) external payable;


    function appealCost(uint _disputeID, bytes calldata _extraData) external view returns(uint cost);


    function appealPeriod(uint _disputeID) external view returns(uint start, uint end);


    function disputeStatus(uint _disputeID) external view returns(DisputeStatus status);


    function currentRuling(uint _disputeID) external view returns(uint ruling);


}


interface IArbitrable {


    event Ruling(IArbitrator indexed _arbitrator, uint indexed _disputeID, uint _ruling);

    function rule(uint _disputeID, uint _ruling) external;

}


interface IEvidence {


    event MetaEvidence(uint indexed _metaEvidenceID, string _evidence);

    event Evidence(IArbitrator indexed _arbitrator, uint indexed _evidenceGroupID, address indexed _party, string _evidence);

    event Dispute(IArbitrator indexed _arbitrator, uint indexed _disputeID, uint _metaEvidenceID, uint _evidenceGroupID);

}



pragma solidity 0.5.17;


library BytesLib {

    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {

        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                sstore(
                    _preBytes_slot,
                    add(
                        fslot,
                        add(
                            mul(
                                div(
                                    mload(add(_postBytes, 0x20)),
                                    exp(0x100, sub(32, mlength))
                                ),
                                exp(0x100, sub(32, newlength))
                            ),
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))


                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))
                
                for { 
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint _start,
        uint _length
    )
        internal
        pure
        returns (bytes memory)
    {

        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {

        require(_bytes.length >= (_start + 20));
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {

        require(_bytes.length >= (_start + 1));
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {

        require(_bytes.length >= (_start + 2));
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {

        require(_bytes.length >= (_start + 4));
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint _start) internal  pure returns (uint64) {

        require(_bytes.length >= (_start + 8));
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint _start) internal  pure returns (uint96) {

        require(_bytes.length >= (_start + 12));
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint _start) internal  pure returns (uint128) {

        require(_bytes.length >= (_start + 16));
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {

        require(_bytes.length >= (_start + 32));
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {

        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {

        bool success = true;

        assembly {
            let length := mload(_preBytes)

            switch eq(length, mload(_postBytes))
            case 1 {
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    if iszero(eq(mload(mc), mload(cc))) {
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {

        bool success = true;

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            switch eq(slength, mlength)
            case 1 {
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            success := 0
                        }
                    }
                    default {
                        let cb := 1

                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }
}


pragma solidity 0.5.17;

library RLPReader {

    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START  = 0xb8;
    uint8 constant LIST_SHORT_START   = 0xc0;
    uint8 constant LIST_LONG_START    = 0xf8;
    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint len;
        uint memPtr;
    }

    struct Iterator {
        RLPItem item;   // Item that's being iterated over.
        uint nextPtr;   // Position of the next item in the list.
    }

    function next(Iterator memory self) internal pure returns (RLPItem memory) {

        require(hasNext(self));

        uint ptr = self.nextPtr;
        uint itemLength = _itemLength(ptr);
        self.nextPtr = ptr + itemLength;

        return RLPItem(itemLength, ptr);
    }

    function hasNext(Iterator memory self) internal pure returns (bool) {

        RLPItem memory item = self.item;
        return self.nextPtr < item.memPtr + item.len;
    }

    function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {

        uint memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    function iterator(RLPItem memory self) internal pure returns (Iterator memory) {

        require(isList(self));

        uint ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    function rlpLen(RLPItem memory item) internal pure returns (uint) {

        return item.len;
    }

    function payloadLen(RLPItem memory item) internal pure returns (uint) {

        return item.len - _payloadOffset(item.memPtr);
    }

    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {

        require(isList(item));

        uint items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);

        uint memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint dataLen;
        for (uint i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr); 
            memPtr = memPtr + dataLen;
        }

        return result;
    }

    function isList(RLPItem memory item) internal pure returns (bool) {

        if (item.len == 0) return false;

        uint8 byte0;
        uint memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START)
            return false;
        return true;
    }


    function toRlpBytes(RLPItem memory item) internal pure returns (bytes memory) {

        bytes memory result = new bytes(item.len);
        if (result.length == 0) return result;
        
        uint ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    function toBoolean(RLPItem memory item) internal pure returns (bool) {

        require(item.len == 1);
        uint result;
        uint memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        return result == 0 ? false : true;
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {

        require(item.len == 21);

        return address(toUint(item));
    }

    function toUint(RLPItem memory item) internal pure returns (uint) {

        require(item.len > 0 && item.len <= 33);

        uint offset = _payloadOffset(item.memPtr);
        uint len = item.len - offset;

        uint result;
        uint memPtr = item.memPtr + offset;
        assembly {
            result := mload(memPtr)

            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

    function toUintStrict(RLPItem memory item) internal pure returns (uint) {

        require(item.len == 33);

        uint result;
        uint memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {

        require(item.len > 0);

        uint offset = _payloadOffset(item.memPtr);
        uint len = item.len - offset; // data length
        bytes memory result = new bytes(len);

        uint destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(item.memPtr + offset, destPtr, len);
        return result;
    }


    function numItems(RLPItem memory item) private pure returns (uint) {

        if (item.len == 0) return 0;

        uint count = 0;
        uint currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
           currPtr = currPtr + _itemLength(currPtr); // skip over an item
           count++;
        }

        return count;
    }

    function _itemLength(uint memPtr) private pure returns (uint) {

        uint itemLen;
        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START)
            itemLen = 1;
        
        else if (byte0 < STRING_LONG_START)
            itemLen = byte0 - STRING_SHORT_START + 1;

        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte
                
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } 

        else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    function _payloadOffset(uint memPtr) private pure returns (uint) {

        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) 
            return 0;
        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START))
            return 1;
        else if (byte0 < LIST_SHORT_START)  // being explicit
            return byte0 - (STRING_LONG_START - 1) + 1;
        else
            return byte0 - (LIST_LONG_START - 1) + 1;
    }

    function copy(uint src, uint dest, uint len) private pure {

        if (len == 0) return;

        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        uint mask = 256 ** (WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }
}

interface GeneralizedTCR {

    enum Status {
        Absent, // The item is not in the registry.
        Registered, // The item is in the registry.
        RegistrationRequested, // The item has a request to be added to the registry.
        ClearingRequested // The item has a request to be removed from the registry.
    }

    enum Party {
        None, // Party per default when there is no challenger or requester. Also used for unconclusive ruling.
        Requester, // Party that made the request to change a status.
        Challenger // Party that challenges the request to change a status.
    }


    struct Item {
        bytes data; // The data describing the item.
        Status status; // The status of the item.
        Request[] requests; // List of status change requests made for the item.
    }

    struct Request {
        bool disputed; // True if a dispute was raised.
        uint disputeID; // ID of the dispute, if any.
        uint submissionTime; // Time when the request was made. Used to track when the challenge period ends.
        bool resolved; // True if the request was executed and/or any raised disputes were resolved.
        address payable[3] parties; // Address of requester and challenger, if any.
        Round[] rounds; // Tracks each round of a dispute.
        Party ruling; // The final ruling given, if any.
        IArbitrator arbitrator; // The arbitrator trusted to solve disputes for this request.
        bytes arbitratorExtraData; // The extra data for the trusted arbitrator of this request.
        uint metaEvidenceID;
    }

    struct Round {
        uint[3] amountPaid; // Tracks the fees paid by each side in this round.
        bool[3] hasPaid; // True when the side has fully paid its fee. False otherwise.
        uint feeRewards; // Sum of reimbursable fees and stake rewards available to the parties that made contributions to the side that ultimately wins a dispute.
        mapping(address => uint[3]) contributions; // Maps contributors to their contributions for each side.
    }
    
    function governor() external view returns(address);

    function arbitrator() external view returns(address);

    function arbitratorExtraData() external view returns(bytes memory);

    function submissionBaseDeposit() external view returns(uint);

    function removalBaseDeposit() external view returns(uint);

    function submissionChallengeBaseDeposit() external view returns(uint);

    function removalChallengeBaseDeposit() external view returns(uint);

    function challengePeriodDuration() external view returns(uint);

    function metaEvidenceUpdates() external view returns(uint);

    function winnerStakeMultiplier() external view returns(uint);

    function loserStakeMultiplier() external view returns(uint);

    function sharedStakeMultiplier() external view returns(uint);

    function MULTIPLIER_DIVISOR() external view returns(uint);

    function itemCount() external view returns(uint);

    function itemList(uint index) external view returns(bytes32);

    function getItemInfo(bytes32 item) external view returns(bytes memory, Status,uint);

    function getRequestInfo(bytes32 item, uint request) external view returns (
        bool disputed,
        uint disputeID,
        uint submissionTime,
        bool resolved,
        address payable[3] memory parties,
        uint numberOfRounds,
        Party ruling,
        IArbitrator arbitrator,
        bytes memory arbitratorExtraData,
        uint metaEvidenceID
    );

    function getRoundInfo(bytes32 _itemID, uint _request, uint _round)
        external
        view
        returns (
            bool appealed,
            uint[3] memory amountPaid,
            bool[3] memory hasPaid,
            uint feeRewards
        );

    function getContributions(
        bytes32 _itemID,
        uint _request,
        uint _round,
        address _contributor
    ) external view returns(uint[3] memory contributions);

}


pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


contract GeneralizedTCRView {

    using RLPReader for RLPReader.RLPItem;
    using RLPReader for bytes;
    using BytesLib for bytes;

    struct QueryResult {
        bytes32 ID;
        bytes data;
        GeneralizedTCR.Status status;
        bool disputed;
        bool resolved;
        uint disputeID;
        uint appealCost;
        bool appealed;
        uint appealStart;
        uint appealEnd;
        GeneralizedTCR.Party ruling;
        address requester;
        address challenger;
        address arbitrator;
        bytes arbitratorExtraData;
        GeneralizedTCR.Party currentRuling;
        bool[3] hasPaid;
        uint feeRewards;
        uint submissionTime;
        uint[3] amountPaid;
        IArbitrator.DisputeStatus disputeStatus;
        uint numberOfRequests;
    }

    struct ArbitrableData {
        address governor;
        address arbitrator;
        bytes arbitratorExtraData;
        uint submissionBaseDeposit;
        uint removalBaseDeposit;
        uint submissionChallengeBaseDeposit;
        uint removalChallengeBaseDeposit;
        uint challengePeriodDuration;
        uint metaEvidenceUpdates;
        uint winnerStakeMultiplier;
        uint loserStakeMultiplier;
        uint sharedStakeMultiplier;
        uint MULTIPLIER_DIVISOR;
        uint arbitrationCost;
    }

    function fetchArbitrable(address _address) external view returns (ArbitrableData memory result) {

        GeneralizedTCR tcr = GeneralizedTCR(_address);
        result.governor = tcr.governor();
        result.arbitrator = address(tcr.arbitrator());
        result.arbitratorExtraData = tcr.arbitratorExtraData();
        result.submissionBaseDeposit = tcr.submissionBaseDeposit();
        result.removalBaseDeposit = tcr.removalBaseDeposit();
        result.submissionChallengeBaseDeposit = tcr.submissionChallengeBaseDeposit();
        result.removalChallengeBaseDeposit = tcr.removalChallengeBaseDeposit();
        result.challengePeriodDuration = tcr.challengePeriodDuration();
        result.metaEvidenceUpdates = tcr.metaEvidenceUpdates();
        result.winnerStakeMultiplier = tcr.winnerStakeMultiplier();
        result.loserStakeMultiplier = tcr.loserStakeMultiplier();
        result.sharedStakeMultiplier = tcr.sharedStakeMultiplier();
        result.MULTIPLIER_DIVISOR = tcr.MULTIPLIER_DIVISOR();
        result.arbitrationCost = IArbitrator(result.arbitrator).arbitrationCost(result.arbitratorExtraData);
    }

    function getItem(address _address, bytes32 _itemID) public view returns (QueryResult memory result) {

        RoundData memory round = getLatestRoundRequestData(_address, _itemID);
        result = QueryResult({
            ID: _itemID,
            data: round.request.item.data,
            status: round.request.item.status,
            disputed: round.request.disputed,
            resolved: round.request.resolved,
            disputeID: round.request.disputeID,
            appealCost: 0,
            appealed: round.appealed,
            appealStart: 0,
            appealEnd: 0,
            ruling: round.request.ruling,
            requester: round.request.parties[uint(GeneralizedTCR.Party.Requester)],
            challenger: round.request.parties[uint(GeneralizedTCR.Party.Challenger)],
            arbitrator: address(round.request.arbitrator),
            arbitratorExtraData: round.request.arbitratorExtraData,
            currentRuling: GeneralizedTCR.Party.None,
            hasPaid: round.hasPaid,
            feeRewards: round.feeRewards,
            submissionTime: round.request.submissionTime,
            amountPaid: round.amountPaid,
            disputeStatus: IArbitrator.DisputeStatus.Waiting,
            numberOfRequests: round.request.item.numberOfRequests
        });
        if (round.request.disputed && round.request.arbitrator.disputeStatus(result.disputeID) == IArbitrator.DisputeStatus.Appealable) {
            result.currentRuling = GeneralizedTCR.Party(round.request.arbitrator.currentRuling(result.disputeID));
            result.disputeStatus = round.request.arbitrator.disputeStatus(result.disputeID);
            (result.appealStart, result.appealEnd) = round.request.arbitrator.appealPeriod(result.disputeID);
            result.appealCost = round.request.arbitrator.appealCost(result.disputeID, result.arbitratorExtraData);
        }
    }

    struct ItemRequest {
        bool disputed;
        uint disputeID;
        uint submissionTime;
        bool resolved;
        address requester;
        address challenger;
        address arbitrator;
        bytes arbitratorExtraData;
        uint metaEvidenceID;
    }

    function getItemRequests(address _address, bytes32 _itemID) external view returns (ItemRequest[] memory requests) {

        GeneralizedTCR gtcr = GeneralizedTCR(_address);
        ItemData memory itemData = getItemData(_address, _itemID);
        requests = new ItemRequest[](itemData.numberOfRequests);
        for (uint i = 0; i < itemData.numberOfRequests; i++) {
            (
                bool disputed,
                uint disputeID,
                uint submissionTime,
                bool resolved,
                address payable[3] memory parties,
                ,
                ,
                IArbitrator arbitrator,
                bytes memory arbitratorExtraData,
                uint metaEvidenceID
            ) = gtcr.getRequestInfo(_itemID, i);

            requests[itemData.numberOfRequests - i - 1] = ItemRequest({
                disputed: disputed,
                disputeID: disputeID,
                submissionTime: submissionTime,
                resolved: resolved,
                requester: parties[uint(GeneralizedTCR.Party.Requester)],
                challenger: parties[uint(GeneralizedTCR.Party.Challenger)],
                arbitrator: address(arbitrator),
                arbitratorExtraData: arbitratorExtraData,
                metaEvidenceID: metaEvidenceID
            });
        }
    }

    function findItem(
        address _address,
        bytes memory _rlpEncodedMatch,
        uint _cursor,
        uint _count,
        bool[4] memory _skipState,
        bool[] memory _ignoreColumns
    )
        public
        view
        returns (QueryResult[] memory results)
    {

        GeneralizedTCR gtcr = GeneralizedTCR(_address);
        RLPReader.RLPItem[] memory matchItem = _rlpEncodedMatch.toRlpItem().toList();
        results = new QueryResult[](_count == 0 ? gtcr.itemCount() : _count);
        uint itemsFound;

        for(uint i = _cursor; i < (_count == 0 ? gtcr.itemCount() : _count); i++) { // Iterate over every item in storage.
            QueryResult memory item = getItem(_address, gtcr.itemList(i));
            if (_skipState[uint(item.status)])
                continue;

            RLPReader.RLPItem[] memory itemData = item.data.toRlpItem().toList();
            bool itemFound = true;
            for (uint j = 0; j < matchItem.length; j++) { // Iterate over every column.
                if (!_ignoreColumns[j] && !itemData[j].toBytes().equal(matchItem[j].toBytes())) {
                    itemFound = false;
                    break;
                }
            }

            if (itemFound) {
                results[itemsFound] = item;
                itemsFound++;
            }
        }

        return results;
    }

    function findIndexForPage(
        address _address,
        uint[4] calldata _targets,
        bool[9] calldata _filter,
        address _party
    )
        external
        view
        returns (uint index, bool hasMore, bool indexFound)
    {

        GeneralizedTCR gtcr = GeneralizedTCR(_address);
        uint count = _targets[2];
        uint currPage = 1;
        uint itemsMatched = 0;

        if (gtcr.itemCount() == 0) return (0, false, true);

        uint i = _filter[8] ? _targets[3] : _targets[3] == 0 ? gtcr.itemCount() - 1 : _targets[3];

        for(; _filter[8] ? i < gtcr.itemCount() && count > 0 : i >= 0 && count > 0; ) {
            bytes32 itemID = gtcr.itemList(i);
            QueryResult memory item = getItem(_address, itemID);
            hasMore = true;
            if (
                (_filter[0] && item.status == GeneralizedTCR.Status.Absent) ||
                (_filter[1] && item.status == GeneralizedTCR.Status.Registered) ||
                (_filter[2] && item.status == GeneralizedTCR.Status.RegistrationRequested && !item.disputed) ||
                (_filter[3] && item.status == GeneralizedTCR.Status.ClearingRequested && !item.disputed) ||
                (_filter[4] && item.status == GeneralizedTCR.Status.RegistrationRequested && item.disputed) ||
                (_filter[5] && item.status == GeneralizedTCR.Status.ClearingRequested && item.disputed) ||
                (_filter[6] && item.requester == _party) ||
                (_filter[7] && item.challenger == _party)
            ) {
                itemsMatched++;
                if (itemsMatched % _targets[1] == 0) {
                    currPage++;
                    if (currPage == _targets[0]){
                        if ((i == 0 && !_filter[8]) || (i == gtcr.itemCount() - 1 && _filter[8])) hasMore = false;
                        return (_filter[8] ? i + 1 : i - 1, hasMore, true);
                    }
                }
            }
            count--;
            if (count == 0 || (i == 0 && !_filter[8]) || (i == gtcr.itemCount() - 1 && _filter[8])) {
                hasMore = _filter[8] ? i < gtcr.itemCount() : i > 0;
                break;
            }
            i = _filter[8] ? i + 1 : i == 0 ? 0 : i - 1;
        }

        if (_filter[8] && _targets[3] + _targets[1] > _targets[3] + i) {
            i = _targets[3];
        }
        return (i, hasMore, false);
    }

    function countWithFilter(address _address, uint _cursorIndex, uint _count, bool[8] calldata _filter, address _party)
        external
        view
        returns (uint count, bool hasMore, uint)
    {

        GeneralizedTCR gtcr = GeneralizedTCR(_address);
        if (gtcr.itemCount() == 0) return (0, false, 0);

        uint iterations = 0;
        for (uint i = _cursorIndex; iterations <= _count && i < gtcr.itemCount(); i++) {
            bytes32 itemID = gtcr.itemList(i);
            QueryResult memory item = getItem(_address, itemID);
            if (
                (_filter[0] && item.status == GeneralizedTCR.Status.Absent) ||
                (_filter[1] && item.status == GeneralizedTCR.Status.Registered) ||
                (_filter[2] && item.status == GeneralizedTCR.Status.RegistrationRequested && !item.disputed) ||
                (_filter[3] && item.status == GeneralizedTCR.Status.ClearingRequested && !item.disputed) ||
                (_filter[4] && item.status == GeneralizedTCR.Status.RegistrationRequested && item.disputed) ||
                (_filter[5] && item.status == GeneralizedTCR.Status.ClearingRequested && item.disputed) ||
                (_filter[6] && item.requester == _party) ||
                (_filter[7] && item.challenger == _party)
            ) {
                count++;
                if (iterations >= _count) {
                    return (count, true, i);
                }
            }
            iterations++;
        }
    }

    function queryItems(
        address _address,
        uint _cursorIndex,
        uint _count,
        bool[8] calldata _filter,
        bool _oldestFirst,
        address _party,
        uint _limit
    )
        external
        view
        returns (QueryResult[] memory results, bool hasMore)
    {

        GeneralizedTCR gtcr = GeneralizedTCR(_address);
        results = new QueryResult[](_count);
        uint index = 0;
        uint count = _count;
        if (_limit == 0) _limit = count;

        if (gtcr.itemCount() == 0) return (results, false);

        uint i = _oldestFirst ? _cursorIndex : _cursorIndex == 0 ? gtcr.itemCount() - 1 : _cursorIndex;

        for(; _oldestFirst ? i < gtcr.itemCount() && count > 0 : i >= 0 && count > 0; ) {
            bytes32 itemID = gtcr.itemList(i);
            QueryResult memory item = getItem(_address, itemID);
            hasMore = true;
            if (
                (_filter[0] && item.status == GeneralizedTCR.Status.Absent) ||
                (_filter[1] && item.status == GeneralizedTCR.Status.Registered) ||
                (_filter[2] && item.status == GeneralizedTCR.Status.RegistrationRequested && !item.disputed) ||
                (_filter[3] && item.status == GeneralizedTCR.Status.ClearingRequested && !item.disputed) ||
                (_filter[4] && item.status == GeneralizedTCR.Status.RegistrationRequested && item.disputed) ||
                (_filter[5] && item.status == GeneralizedTCR.Status.ClearingRequested && item.disputed) ||
                (_filter[6] && item.requester == _party) ||
                (_filter[7] && item.challenger == _party)
            ) {
                results[index] = item;
                index++;
                if (index == _limit) break;
            }
            count--;
            if (count == 0 || (i == 0 && !_oldestFirst) || (i == gtcr.itemCount() - 1 && _oldestFirst)) {
                hasMore = _oldestFirst ? i < gtcr.itemCount() - 1 : i > 0;
                break;
            }
            i = _oldestFirst ? i + 1 : i == 0 ? 0 : i - 1;
        }
    }

    function availableRewards(address _address, bytes32 _itemID, address _contributor) external view returns (uint rewards) {

        GeneralizedTCR gtcr = GeneralizedTCR(_address);

        uint[2] memory requestRoundCount = [uint(0), uint(0)];
        uint[2] memory indexes = [uint(0), uint(0)]; // Request index and round index.

        (,,requestRoundCount[0]) = gtcr.getItemInfo(_itemID);
        for (indexes[0]; indexes[0] < requestRoundCount[0]; indexes[0]++) {
            GeneralizedTCR.Party ruling;
            bool resolved;
            (,,, resolved,, requestRoundCount[1], ruling,,,) = gtcr.getRequestInfo(_itemID, indexes[0]);
            if (!resolved) continue;
            for (indexes[1]; indexes[1] < requestRoundCount[1]; indexes[1]++) {
                (
                    ,
                    uint[3] memory amountPaid,
                    bool[3] memory hasPaid,
                    uint feeRewards
                ) = gtcr.getRoundInfo(_itemID, indexes[0], indexes[1]);

                uint[3] memory roundContributions = gtcr.getContributions(_itemID, indexes[0], indexes[1], _contributor);
                if (!hasPaid[uint(GeneralizedTCR.Party.Requester)] || !hasPaid[uint(GeneralizedTCR.Party.Challenger)]) {
                    rewards += roundContributions[uint(GeneralizedTCR.Party.Requester)] + roundContributions[uint(GeneralizedTCR.Party.Challenger)];
                } else if (ruling == GeneralizedTCR.Party.None) {
                    rewards += amountPaid[uint(GeneralizedTCR.Party.Requester)] > 0
                        ? (roundContributions[uint(GeneralizedTCR.Party.Requester)] * feeRewards) / (amountPaid[uint(GeneralizedTCR.Party.Challenger)] + amountPaid[uint(GeneralizedTCR.Party.Requester)])
                        : 0;
                    rewards += amountPaid[uint(GeneralizedTCR.Party.Challenger)] > 0
                        ? (roundContributions[uint(GeneralizedTCR.Party.Challenger)] * feeRewards) / (amountPaid[uint(GeneralizedTCR.Party.Challenger)] + amountPaid[uint(GeneralizedTCR.Party.Requester)])
                        : 0;
                } else {
                    rewards += amountPaid[uint(ruling)] > 0
                        ? (roundContributions[uint(ruling)] * feeRewards) / amountPaid[uint(ruling)]
                        : 0;
                }
            }
            indexes[1] = 0;
        }
    }


    struct ItemData {
        bytes data;
        GeneralizedTCR.Status status;
        uint numberOfRequests;
    }

    struct RequestData {
        ItemData item;
        bool disputed;
        uint disputeID;
        uint submissionTime;
        bool resolved;
        address payable[3] parties;
        uint numberOfRounds;
        GeneralizedTCR.Party ruling;
        IArbitrator arbitrator;
        bytes arbitratorExtraData;
    }

    struct RoundData {
        RequestData request;
        bool appealed;
        uint[3] amountPaid;
        bool[3] hasPaid;
        uint feeRewards;
    }

    function getItemData(address _address, bytes32 _itemID) public view returns(ItemData memory item) {

        GeneralizedTCR gtcr = GeneralizedTCR(_address);
        (
            bytes memory data,
            GeneralizedTCR.Status status,
            uint numberOfRequests
        ) = gtcr.getItemInfo(_itemID);
        item = ItemData(data, status, numberOfRequests);
    }

    function getLatestRequestData(address _address, bytes32 _itemID) public view returns (RequestData memory request)  {

        GeneralizedTCR gtcr = GeneralizedTCR(_address);
        ItemData memory item = getItemData(_address, _itemID);
        (
            bool disputed,
            uint disputeID,
            uint submissionTime,
            bool resolved,
            address payable[3] memory parties,
            uint numberOfRounds,
            GeneralizedTCR.Party ruling,
            IArbitrator arbitrator,
            bytes memory arbitratorExtraData,
        ) = gtcr.getRequestInfo(_itemID, item.numberOfRequests - 1);
        request = RequestData(
            item,
            disputed,
            disputeID,
            submissionTime,
            resolved,
            parties,
            numberOfRounds,
            ruling,
            arbitrator,
            arbitratorExtraData
        );
    }

    function getLatestRoundRequestData(address _address, bytes32 _itemID) public view returns (RoundData memory round)  {

        GeneralizedTCR gtcr = GeneralizedTCR(_address);
        RequestData memory request = getLatestRequestData(_address, _itemID);
        (
            bool appealed,
            uint[3] memory amountPaid,
            bool[3] memory hasPaid,
            uint feeRewards
        ) = gtcr.getRoundInfo(_itemID, request.item.numberOfRequests - 1, request.numberOfRounds - 1);
        round = RoundData(
            request,
            appealed,
            amountPaid,
            hasPaid,
            feeRewards
        );
    }
}