
pragma solidity ^0.5.8;


contract Ownable {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(
            msg.sender == owner,
            "The function can only be called by the owner"
        );
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}



library ECDSA {

    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }
}



pragma solidity ^0.5.8;

library RLPReader {

    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START = 0xb8;
    uint8 constant LIST_SHORT_START = 0xc0;
    uint8 constant LIST_LONG_START = 0xf8;

    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint len;
        uint memPtr;
    }

    function toRlpItem(bytes memory item)
        internal
        pure
        returns (RLPItem memory)
    {

        require(item.length > 0);

        uint memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    function rlpLen(RLPItem memory item) internal pure returns (uint) {

        return item.len;
    }

    function payloadLen(RLPItem memory item) internal pure returns (uint) {

        return item.len - _payloadOffset(item.memPtr);
    }

    function toList(RLPItem memory item)
        internal
        pure
        returns (RLPItem[] memory result)
    {

        require(isList(item));

        uint items = numItems(item);
        result = new RLPItem[](items);

        uint memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint dataLen;
        for (uint i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr);
            memPtr = memPtr + dataLen;
        }
    }

    function isList(RLPItem memory item) internal pure returns (bool) {

        if (item.len == 0) return false;

        uint8 byte0;
        uint memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START) return false;
        return true;
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

    function _itemLength(uint memPtr) private pure returns (uint len) {

        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) return 1;
        else if (byte0 < STRING_LONG_START)
            return byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                len := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            return byte0 - LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length
                len := add(dataLen, add(byteLen, 1))
            }
        }
    }

    function _payloadOffset(uint memPtr) private pure returns (uint) {

        uint byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) return 0;
        else if (
            byte0 < STRING_LONG_START ||
            (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)
        ) return 1;
        else if (byte0 < LIST_SHORT_START)
            return byte0 - (STRING_LONG_START - 1) + 1;
        else return byte0 - (LIST_LONG_START - 1) + 1;
    }


    function toRlpBytes(RLPItem memory item)
        internal
        pure
        returns (bytes memory)
    {

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

library EquivocationInspector {

    using RLPReader for RLPReader.RLPItem;
    using RLPReader for bytes;

    uint constant STEP_DURATION = 5;

    function getSignerAddress(bytes memory _data, bytes memory _signature)
        internal
        pure
        returns (address)
    {

        bytes32 hash = keccak256(_data);
        return ECDSA.recover(hash, _signature);
    }

    function verifyEquivocationProof(
        bytes memory _rlpUnsignedHeaderOne,
        bytes memory _signatureOne,
        bytes memory _rlpUnsignedHeaderTwo,
        bytes memory _signatureTwo
    ) internal pure {

        bytes32 hashOne = keccak256(_rlpUnsignedHeaderOne);
        bytes32 hashTwo = keccak256(_rlpUnsignedHeaderTwo);

        require(
            hashOne != hashTwo,
            "Equivocation can be proved for two different blocks only."
        );

        RLPReader.RLPItem[] memory blockOne = _rlpUnsignedHeaderOne
            .toRlpItem()
            .toList();
        RLPReader.RLPItem[] memory blockTwo = _rlpUnsignedHeaderTwo
            .toRlpItem()
            .toList();

        require(
            blockOne.length >= 12 && blockTwo.length >= 12,
            "The number of provided header entries are not enough."
        );

        require(
            getSignerAddress(_rlpUnsignedHeaderOne, _signatureOne) ==
                getSignerAddress(_rlpUnsignedHeaderTwo, _signatureTwo),
            "The two blocks have been signed by different identities."
        );

        uint stepOne = blockOne[11].toUint() / STEP_DURATION;
        uint stepTwo = blockTwo[11].toUint() / STEP_DURATION;

        require(stepOne == stepTwo, "The two blocks have different steps.");
    }

}

contract DepositLockerInterface {

    function slash(address _depositorToBeSlashed) public;


}

contract ValidatorSlasher is Ownable {

    bool public initialized = false;
    DepositLockerInterface public depositContract;

    function() external {}

    function init(address _depositContractAddress) external onlyOwner {

        require(!initialized, "The contract is already initialized.");

        depositContract = DepositLockerInterface(_depositContractAddress);

        initialized = true;
    }

    function reportMaliciousValidator(
        bytes calldata _rlpUnsignedHeaderOne,
        bytes calldata _signatureOne,
        bytes calldata _rlpUnsignedHeaderTwo,
        bytes calldata _signatureTwo
    ) external {

        EquivocationInspector.verifyEquivocationProof(
            _rlpUnsignedHeaderOne,
            _signatureOne,
            _rlpUnsignedHeaderTwo,
            _signatureTwo
        );

        address validator = EquivocationInspector.getSignerAddress(
            _rlpUnsignedHeaderOne,
            _signatureOne
        );

        depositContract.slash(validator);
    }
}