pragma solidity ^0.5.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}pragma solidity 0.5.17;





library BytesLib {

    function concat(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bytes memory) {

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

    function slice(bytes memory _bytes, uint _start, uint _length) internal  pure returns (bytes memory res) {

        uint _end = _start + _length;
        require(_end > _start && _bytes.length >= _end, "Slice out of bounds");

        assembly {
            res := mload(0x40)
            mstore(0x40, add(add(res, 64), _length))
            mstore(res, _length)

            let diff := sub(res, add(_bytes, _start))

            for {
                let src := add(add(_bytes, 32), _start)
                let end := add(src, _length)
            } lt(src, end) {
                src := add(src, 32)
            } {
                mstore(add(src, diff), mload(src))
            }
        }
    }

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {

        uint _totalLen = _start + 20;
        require(_totalLen > _start && _bytes.length >= _totalLen, "Address conversion out of bounds.");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {

        require(_bytes.length >= (_start + 1), "Uint8 conversion out of bounds.");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {

        uint _totalLen = _start + 32;
        require(_totalLen > _start && _bytes.length >= _totalLen, "Uint conversion out of bounds.");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
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

    function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {

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

    function toBytes32(bytes memory _source) pure internal returns (bytes32 result) {
        if (_source.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(_source, 32))
        }
    }

    function keccak256Slice(bytes memory _bytes, uint _start, uint _length) pure internal returns (bytes32 result) {
        uint _end = _start + _length;
        require(_end > _start && _bytes.length >= _end, "Slice out of bounds");

        assembly {
            result := keccak256(add(add(_bytes, 32), _start), _length)
        }
    }
}pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}pragma solidity 0.5.17;


library GroupSelection {


    using SafeMath for uint256;
    using BytesLib for bytes;

    struct Storage {
        uint64[] tickets;

        mapping(uint256 => address) candidate;

        uint256 seed;

        uint256 ticketSubmissionTimeout;

        uint256 ticketSubmissionStartBlock;

        bool inProgress;

        uint256 minimumStake;

        bytes previousTicketIndices;

        uint256 tail;

        uint256 groupSize;
    }

    function start(Storage storage self, uint256 _seed) public {

        cleanupTickets(self);
        self.inProgress = true;
        self.seed = _seed;
        self.ticketSubmissionStartBlock = block.number;
    }

    function stop(Storage storage self) public {

        cleanupCandidates(self);
        cleanupTickets(self);
        self.inProgress = false;
    }

    function submitTicket(
        Storage storage self,
        bytes32 ticket,
        uint256 stakingWeight
    ) public {

        uint64 ticketValue;
        uint160 stakerValue;
        uint32 virtualStakerIndex;

        bytes memory ticketBytes = abi.encodePacked(ticket);
        assembly {
            ticketValue := mload(add(ticketBytes, 8))
            stakerValue := mload(add(ticketBytes, 28))
            virtualStakerIndex := mload(add(ticketBytes, 32))
        }

        submitTicket(
            self,
            ticketValue,
            uint256(stakerValue),
            uint256(virtualStakerIndex),
            stakingWeight
        );
    }

    function submitTicket(
        Storage storage self,
        uint64 ticketValue,
        uint256 stakerValue,
        uint256 virtualStakerIndex,
        uint256 stakingWeight
    ) public {

        if (block.number > self.ticketSubmissionStartBlock.add(self.ticketSubmissionTimeout)) {
            revert("Ticket submission is over");
        }

        if (self.candidate[ticketValue] != address(0)) {
            revert("Duplicate ticket");
        }

        if (isTicketValid(
            ticketValue,
            stakerValue,
            virtualStakerIndex,
            stakingWeight,
            self.seed
        )) {
            addTicket(self, ticketValue);
        } else {
            revert("Invalid ticket");
        }
    }

    function isTicketValid(
        uint64 ticketValue,
        uint256 stakerValue,
        uint256 virtualStakerIndex,
        uint256 stakingWeight,
        uint256 groupSelectionSeed
    ) internal view returns(bool) {

        uint64 ticketValueExpected;
        bytes memory ticketBytes = abi.encodePacked(
            keccak256(
                abi.encodePacked(
                    groupSelectionSeed,
                    stakerValue,
                    virtualStakerIndex
                )
            )
        );
        assembly {
            ticketValueExpected := mload(add(ticketBytes, 8))
        }

        bool isVirtualStakerIndexValid = virtualStakerIndex > 0 && virtualStakerIndex <= stakingWeight;
        bool isStakerValueValid = stakerValue == uint256(msg.sender);
        bool isTicketValueValid = ticketValue == ticketValueExpected;

        return isVirtualStakerIndexValid && isStakerValueValid && isTicketValueValid;
    }

    function addTicket(Storage storage self, uint64 newTicketValue) internal {

        uint256[] memory previousTicketIndex = readPreviousTicketIndices(self);
        uint256[] memory ordered = getTicketValueOrderedIndices(
            self,
            previousTicketIndex
        );

        if (self.tickets.length < self.groupSize) {
            if (self.tickets.length == 0) {
                self.tickets.push(newTicketValue);
            } else if (newTicketValue > self.tickets[self.tail]) {
                self.tickets.push(newTicketValue);
                uint256 oldTail = self.tail;
                self.tail = self.tickets.length-1;
                previousTicketIndex[self.tail] = oldTail;
            } else if (newTicketValue < self.tickets[ordered[0]]) {
                self.tickets.push(newTicketValue);
                previousTicketIndex[self.tickets.length - 1] = self.tickets.length - 1;
                previousTicketIndex[ordered[0]] = self.tickets.length - 1;
            } else {
                self.tickets.push(newTicketValue);
                uint256 j = findReplacementIndex(self, newTicketValue, ordered);
                previousTicketIndex[self.tickets.length - 1] = previousTicketIndex[j];
                previousTicketIndex[j] = self.tickets.length - 1;
            }
            self.candidate[newTicketValue] = msg.sender;
        } else if (newTicketValue < self.tickets[self.tail]) {
            uint256 ticketToRemove = self.tickets[self.tail];
            if (newTicketValue < self.tickets[ordered[0]]) {
                self.tickets[self.tail] = newTicketValue;
                uint256 newTail = previousTicketIndex[self.tail];
                previousTicketIndex[ordered[0]] = self.tail;
                previousTicketIndex[self.tail] = self.tail;
                self.tail = newTail;
            } else { // new ticket is between lowest and highest
                uint256 j = findReplacementIndex(self, newTicketValue, ordered);
                self.tickets[self.tail] = newTicketValue;
                if (j != self.tail) {
                    uint newTail = previousTicketIndex[self.tail];
                    previousTicketIndex[self.tail] = previousTicketIndex[j];
                    previousTicketIndex[j] = self.tail;
                    self.tail = newTail;
                }
            }
            delete self.candidate[ticketToRemove];
            self.candidate[newTicketValue] = msg.sender;
        }
        storePreviousTicketIndices(self, previousTicketIndex);
    }

    function findReplacementIndex(
        Storage storage self,
        uint64 newTicketValue,
        uint256[] memory ordered
    ) internal view returns (uint256) {

        uint256 lo = 0;
        uint256 hi = ordered.length - 1;
        uint256 mid = 0;
        while (lo <= hi) {
            mid = (lo + hi) >> 1;
            if (newTicketValue < self.tickets[ordered[mid]]) {
                hi = mid - 1;
            } else if (newTicketValue > self.tickets[ordered[mid]]) {
                lo = mid + 1;
            } else {
                return ordered[mid];
            }
        }

        return ordered[lo];
    }

    function readPreviousTicketIndices(Storage storage self)
        internal view returns (uint256[] memory uncompressed)
    {

        bytes memory compressed = self.previousTicketIndices;
        uncompressed = new uint256[](self.groupSize);
        for (uint256 i = 0; i < compressed.length; i++) {
            uncompressed[i] = uint256(uint8(compressed[i]));
        }
    }

    function storePreviousTicketIndices(
        Storage storage self,
        uint256[] memory uncompressed
    ) internal {

        bytes memory compressed = new bytes(uncompressed.length);
        for (uint256 i = 0; i < compressed.length; i++) {
            compressed[i] = bytes1(uint8(uncompressed[i]));
        }
        self.previousTicketIndices = compressed;
    }

    function getTicketValueOrderedIndices(
        Storage storage self,
        uint256[] memory previousIndices
    ) internal view returns (uint256[] memory) {

        uint256[] memory ordered = new uint256[](self.tickets.length);
        if (ordered.length > 0) {
            ordered[self.tickets.length-1] = self.tail;
            if (ordered.length > 1) {
                for (uint256 i = self.tickets.length - 1; i > 0; i--) {
                    ordered[i-1] = previousIndices[ordered[i]];
                }
            }
        }

        return ordered;
    }

    function selectedParticipants(Storage storage self) public view returns (address[] memory) {

        require(
            block.number >= self.ticketSubmissionStartBlock.add(self.ticketSubmissionTimeout),
            "Ticket submission in progress"
        );

        require(self.tickets.length >= self.groupSize, "Not enough tickets submitted");

        uint256[] memory previousTicketIndex = readPreviousTicketIndices(self);
        address[] memory selected = new address[](self.groupSize);
        uint256 ticketIndex = self.tail;
        selected[self.tickets.length - 1] = self.candidate[self.tickets[ticketIndex]];
        for (uint256 i = self.tickets.length - 1; i > 0; i--) {
            ticketIndex = previousTicketIndex[ticketIndex];
            selected[i-1] = self.candidate[self.tickets[ticketIndex]];
        }

        return selected;
    }

    function cleanupTickets(Storage storage self) internal {

        delete self.tickets;
        self.tail = 0;
    }

    function cleanupCandidates(Storage storage self) internal {

        for (uint i = 0; i < self.tickets.length; i++) {
            delete self.candidate[self.tickets[i]];
        }
    }
}pragma solidity 0.5.17;


library DKGResultVerification {

    using BytesLib for bytes;
    using ECDSA for bytes32;
    using GroupSelection for GroupSelection.Storage;

    struct Storage {
        uint256 timeDKG;

        uint256 resultPublicationBlockStep;

        uint256 groupSize;

        uint256 signatureThreshold;
    }

    function verify(
        Storage storage self,
        uint256 submitterMemberIndex,
        bytes memory groupPubKey,
        bytes memory misbehaved,
        bytes memory signatures,
        uint256[] memory signingMemberIndices,
        address[] memory members,
        uint256 groupSelectionEndBlock
    ) public view {

        require(submitterMemberIndex > 0, "Invalid submitter index");
        require(
            members[submitterMemberIndex - 1] == msg.sender,
            "Unexpected submitter index"
        );

        uint T_init = groupSelectionEndBlock + self.timeDKG;
        require(
            block.number >= (T_init + (submitterMemberIndex-1) * self.resultPublicationBlockStep),
            "Submitter not eligible"
        );

        require(groupPubKey.length == 128, "Malformed group public key");

        require(
            misbehaved.length <= self.groupSize - self.signatureThreshold,
            "Malformed misbehaved bytes"
        );

        uint256 signaturesCount = signatures.length / 65;
        require(signatures.length >= 65, "Too short signatures array");
        require(signatures.length % 65 == 0, "Malformed signatures array");
        require(signaturesCount == signingMemberIndices.length, "Unexpected signatures count");
        require(signaturesCount >= self.signatureThreshold, "Too few signatures");
        require(signaturesCount <= self.groupSize, "Too many signatures");

        bytes32 resultHash = keccak256(abi.encodePacked(groupPubKey, misbehaved));

        bytes memory current; // Current signature to be checked.

        for(uint i = 0; i < signaturesCount; i++){
            require(signingMemberIndices[i] > 0, "Invalid index");
            require(signingMemberIndices[i] <= members.length, "Index out of range");
            current = signatures.slice(65*i, 65);
            address recoveredAddress = resultHash.toEthSignedMessageHash().recover(current);

            require(members[signingMemberIndices[i] - 1] == recoveredAddress, "Invalid signature");
        }
    }
}