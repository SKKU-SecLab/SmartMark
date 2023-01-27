
pragma solidity ^0.7.0;

library Buffer {

    struct buffer {
        bytes buf;
        uint capacity;
    }

    function init(buffer memory buf, uint capacity) internal pure returns (buffer memory) {

        if (capacity % 32 != 0) {
            capacity += 32 - (capacity % 32);
        }
        buf.capacity = capacity;
        assembly {
            let ptr := mload(0x40)
            mstore(buf, ptr)
            mstore(ptr, 0)
            mstore(0x40, add(32, add(ptr, capacity)))
        }
        return buf;
    }


    function writeRawBytes(
        buffer memory buf,
        uint off,
        bytes memory rawData,
        uint offData,
        uint len
    ) internal pure returns (buffer memory) {

        if (off + len > buf.capacity) {
            resize(buf, max(buf.capacity, len + off) * 2);
        }

        uint dest;
        uint src;
        assembly {
            let bufptr := mload(buf)
            let buflen := mload(bufptr)
            dest := add(add(bufptr, 32), off)
            if gt(add(len, off), buflen) {
                mstore(bufptr, add(len, off))
            }
            src := add(rawData, offData)
        }

        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint mask = 256**(32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }

        return buf;
    }

    function write(buffer memory buf, uint off, bytes memory data, uint len) internal pure returns (buffer memory) {

        require(len <= data.length);

        if (off + len > buf.capacity) {
            resize(buf, max(buf.capacity, len + off) * 2);
        }

        uint dest;
        uint src;
        assembly {
            let bufptr := mload(buf)
            let buflen := mload(bufptr)
            dest := add(add(bufptr, 32), off)
            if gt(add(len, off), buflen) {
                mstore(bufptr, add(len, off))
            }
            src := add(data, 32)
        }

        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint mask = 256**(32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }

        return buf;
    }

    function append(buffer memory buf, bytes memory data) internal pure returns (buffer memory) {

        return write(buf, buf.buf.length, data, data.length);
    }

    function resize(buffer memory buf, uint capacity) private pure {

        bytes memory oldbuf = buf.buf;
        init(buf, capacity);
        append(buf, oldbuf);
    }

    function max(uint a, uint b) private pure returns (uint) {

        if (a > b) {
            return a;
        }
        return b;
    }
}// MIT

pragma solidity ^0.7.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// BUSL-1.1

pragma solidity 0.7.6;


library LayerZeroPacket {

    using Buffer for Buffer.buffer;
    using SafeMath for uint;

    struct Packet {
        uint16 srcChainId;
        uint16 dstChainId;
        uint64 nonce;
        address dstAddress;
        bytes srcAddress;
        bytes32 ulnAddress;
        bytes payload;
    }

    function getPacket(
        bytes memory data,
        uint16 srcChain,
        uint sizeOfSrcAddress,
        bytes32 ulnAddress
    ) internal pure returns (LayerZeroPacket.Packet memory) {

        uint16 dstChainId;
        address dstAddress;
        uint size;
        uint64 nonce;

        assembly {
            dstChainId := mload(add(data, 32))
            size := mload(add(data, 96)) /// size of the byte array
            nonce := mload(add(data, 104)) // offset to convert to uint64  128  is index -24
            dstAddress := mload(add(data, sub(add(128, sizeOfSrcAddress), 4))) // offset to convert to address 12 -8
        }

        Buffer.buffer memory srcAddressBuffer;
        srcAddressBuffer.init(sizeOfSrcAddress);
        srcAddressBuffer.writeRawBytes(0, data, 136, sizeOfSrcAddress); // 128 + 8

        uint payloadSize = size.sub(28).sub(sizeOfSrcAddress);
        Buffer.buffer memory payloadBuffer;
        payloadBuffer.init(payloadSize);
        payloadBuffer.writeRawBytes(0, data, sizeOfSrcAddress.add(156), payloadSize); // 148 + 8
        return LayerZeroPacket.Packet(srcChain, dstChainId, nonce, dstAddress, srcAddressBuffer.buf, ulnAddress, payloadBuffer.buf);
    }
}// BUSL-1.1

pragma solidity >=0.7.0;
pragma abicoder v2;


interface ILayerZeroValidationLibrary {

    function validateProof(bytes32 blockData, bytes calldata _data, uint _remoteAddressSize) external returns (LayerZeroPacket.Packet memory packet);

}// BUSL-1.1

pragma solidity >=0.7.0;


interface IValidationLibraryHelper {

    struct ULNLog{
        bytes32 contractAddress;
        bytes32 topicZeroSig;
        bytes data;
    }

    function getVerifyLog(bytes32 hashRoot, uint[] memory receiptSlotIndex, uint logIndex, bytes[] memory proof) external pure returns(ULNLog memory);

    function getPacket(bytes memory data, uint16 srcChain, uint sizeOfSrcAddress, bytes32 ulnAddress) external pure returns(LayerZeroPacket.Packet memory);

    function getUtilsVersion() external view returns(uint8);

}// BUSL-1.1

pragma solidity 0.7.6;


library PacketDecoder {

    using Buffer for Buffer.buffer;
    using SafeMath for uint;

    function getPacket(
        bytes memory data,
        uint16 srcChain,
        uint sizeOfSrcAddress,
        bytes32 ulnAddress
    ) internal pure returns (LayerZeroPacket.Packet memory) {

        uint16 dstChainId;
        address dstAddress;
        uint size;
        uint64 nonce;

        assembly {
            dstChainId := mload(add(data, 32))
            size := mload(add(data, 96)) /// size of the byte array
            nonce := mload(add(data, 104)) // offset to convert to uint64  128  is index -24
            dstAddress := mload(add(data, sub(add(128, sizeOfSrcAddress), 4))) // offset to convert to address 12 -8
        }

        Buffer.buffer memory srcAddressBuffer;
        srcAddressBuffer.init(sizeOfSrcAddress);
        srcAddressBuffer.writeRawBytes(0, data, 136, sizeOfSrcAddress); // 128 + 8

        uint payloadSize = size.sub(28).sub(sizeOfSrcAddress);
        Buffer.buffer memory payloadBuffer;
        payloadBuffer.init(payloadSize);
        payloadBuffer.writeRawBytes(0, data, sizeOfSrcAddress.add(156), payloadSize); // 148 + 8
        return LayerZeroPacket.Packet(srcChain, dstChainId, nonce, dstAddress, srcAddressBuffer.buf, ulnAddress, payloadBuffer.buf);
    }
}// Apache-2.0

pragma solidity ^0.7.0;

library RLPDecode {

    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START = 0xb8;
    uint8 constant LIST_SHORT_START = 0xc0;
    uint8 constant LIST_LONG_START = 0xf8;
    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint len;
        uint memPtr;
    }

    struct Iterator {
        RLPItem item; // Item that's being iterated over.
        uint nextPtr; // Position of the next item in the list.
    }

    function next(Iterator memory self) internal pure returns (RLPItem memory) {

        require(hasNext(self), "RLPDecoder iterator has no next");

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

        uint8 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }
        uint len = item.length;
        if (len > 0 && byte0 < LIST_SHORT_START) {
            assembly {
                memPtr := add(memPtr, 0x01)
            }
            len -= 1;
        }
        return RLPItem(len, memPtr);
    }

    function iterator(RLPItem memory self) internal pure returns (Iterator memory) {

        require(isList(self), "RLPDecoder iterator is not list");

        uint ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    function rlpLen(RLPItem memory item) internal pure returns (uint) {

        return item.len;
    }

    function payloadLen(RLPItem memory item) internal pure returns (uint) {

        uint offset = _payloadOffset(item.memPtr);
        require(item.len >= offset, "RLPDecoder: invalid uint RLP item offset size");
        return item.len - offset;
    }

    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {

        require(isList(item), "RLPDecoder iterator is not a list");

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

    function getItemByIndex(RLPItem memory item, uint idx) internal pure returns (RLPItem memory) {

        require(isList(item), "RLPDecoder iterator is not a list");

        uint memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint dataLen;
        for (uint i = 0; i < idx; i++) {
            dataLen = _itemLength(memPtr);
            memPtr = memPtr + dataLen;
        }
        dataLen = _itemLength(memPtr);
        return RLPItem(dataLen, memPtr);
    }


    function safeGetItemByIndex(RLPItem memory item, uint idx) internal pure returns (RLPItem memory) {

        require(isList(item), "RLPDecoder iterator is not a list");
        require(idx < numItems(item), "RLP item out of bounds");
        uint endPtr = item.memPtr + item.len;

        uint memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint dataLen;
        for (uint i = 0; i < idx; i++) {
            dataLen = _itemLength(memPtr);
            memPtr = memPtr + dataLen;
        }
        dataLen = _itemLength(memPtr);

        require(memPtr + dataLen <= endPtr, "RLP item overflow");
        return RLPItem(dataLen, memPtr);
    }

    function typeOffset(RLPItem memory item) internal pure returns (RLPItem memory) {

        uint offset = _payloadOffset(item.memPtr);
        uint8 byte0;
        uint memPtr = item.memPtr;
        uint len = item.len;
        assembly {
            memPtr := add(memPtr, offset)
            byte0 := byte(0, mload(memPtr))
        }
        if (len >0 && byte0 < LIST_SHORT_START) {
            assembly {
                memPtr := add(memPtr, 0x01)
            }
            len -= 1;
        }
        return RLPItem(len, memPtr);
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

        require(item.len == 1, "RLPDecoder toBoolean invalid length");
        uint result;
        uint memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        if (result == 0 || result == STRING_SHORT_START) {
            return false;
        } else {
            return true;
        }
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {

        require(item.len == 21, "RLPDecoder toAddress invalid length");

        return address(toUint(item));
    }

    function toUint(RLPItem memory item) internal pure returns (uint) {

        require(item.len > 0 && item.len <= 33, "RLPDecoder toUint invalid length");

        uint offset = _payloadOffset(item.memPtr);
        require(item.len >= offset, "RLPDecoder: invalid RLP item offset size");
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

        require(item.len == 33, "RLPDecoder toUintStrict invalid length");

        uint result;
        uint memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {

        require(item.len > 0, "RLPDecoder toBytes invalid length");

        uint offset = _payloadOffset(item.memPtr);
        require(item.len >= offset, "RLPDecoder: invalid RLP item offset size");
        uint len = item.len - offset; // data length
        bytes memory result = new bytes(len);

        uint destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(item.memPtr + offset, destPtr, len);
        return result;
    }


    function numItems(RLPItem memory item) internal pure returns (uint) {

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

        if (byte0 < STRING_SHORT_START) itemLen = 1;
        else if (byte0 < STRING_LONG_START) itemLen = byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                itemLen := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } else {
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

        if (byte0 < STRING_SHORT_START) return 0;
        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)) return 1;
        else if (byte0 < LIST_SHORT_START)
            return byte0 - (STRING_LONG_START - 1) + 1;
        else return byte0 - (LIST_LONG_START - 1) + 1;
    }

    function copy(
        uint src,
        uint dest,
        uint len
    ) private pure {

        if (len == 0) return;

        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        uint mask = 256**(WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }
}// BUSL-1.1

pragma solidity ^0.7.0;


library UltraLightNodeEVMDecoder {

    using RLPDecode for RLPDecode.RLPItem;
    using RLPDecode for RLPDecode.Iterator;

    struct Log {
        address contractAddress;
        bytes32 topicZero;
        bytes data;
    }

    function getReceiptLog(bytes memory data, uint logIndex) internal pure returns (Log memory) {

        RLPDecode.Iterator memory it = RLPDecode.toRlpItem(data).iterator();
        uint idx;
        while (it.hasNext()) {
            if (idx == 3) {
                return toReceiptLog(it.next().getItemByIndex(logIndex).toRlpBytes());
            } else it.next();
            idx++;
        }
        revert("no log index in receipt");
    }

    function toReceiptLog(bytes memory data) internal pure returns (Log memory) {

        RLPDecode.Iterator memory it = RLPDecode.toRlpItem(data).iterator();
        Log memory log;

        uint idx;
        while (it.hasNext()) {
            if (idx == 0) {
                log.contractAddress = it.next().toAddress();
            } else if (idx == 1) {
                RLPDecode.RLPItem memory item = it.next().getItemByIndex(0);
                log.topicZero = bytes32(item.toUint());
            } else if (idx == 2) log.data = it.next().toBytes();
            else it.next();
            idx++;
        }
        return log;
    }
}// BUSL-1.1

pragma solidity 0.7.6;


interface IUltraLightNode {

    struct BlockData {
        uint confirmations;
        bytes32 data;
    }

    struct ApplicationConfiguration {
        uint16 inboundProofLibraryVersion;
        uint64 inboundBlockConfirmations;
        address relayer;
        uint16 outboundProofType;
        uint64 outboundBlockConfirmations;
        address oracle;
    }

    function getAppConfig(uint16 _chainId, address userApplicationAddress) external view returns (ApplicationConfiguration memory);

    function getBlockHeaderData(address _oracle, uint16 _remoteChainId, bytes32 _lookupHash) external view returns (BlockData memory blockData);

}

interface IStargate {

    struct SwapObj {
        uint256 amount;
        uint256 eqFee;
        uint256 eqReward;
        uint256 lpFee;
        uint256 protocolFee;
        uint256 lkbRemove;
    }

    struct CreditObj {
        uint256 credits;
        uint256 idealBalance;
    }
}

contract MPTValidatorV5 is ILayerZeroValidationLibrary, IValidationLibraryHelper {

    using RLPDecode for RLPDecode.RLPItem;
    using RLPDecode for RLPDecode.Iterator;
    using PacketDecoder for bytes;

    uint8 public utilsVersion = 3;
    bytes32 public constant PACKET_SIGNATURE = 0xe8d23d927749ec8e512eb885679c2977d57068839d8cca1a85685dbbea0648f6;

    address immutable public stargateBridgeAddress;
    address immutable public stgTokenAddress;
    address immutable public relayerAddress;
    uint16 immutable public localChainId;
    IUltraLightNode immutable public uln;

    constructor (address _stargateBridgeAddress, address _stgTokenAddress, uint16 _localChainId, address _ulnAddress, address _relayerAddress) {
        stargateBridgeAddress = _stargateBridgeAddress;
        stgTokenAddress = _stgTokenAddress;
        localChainId = _localChainId;
        uln = IUltraLightNode(_ulnAddress);
        relayerAddress = _relayerAddress;
    }

    function validateProof(bytes32 _receiptsRoot, bytes calldata _transactionProof, uint _remoteAddressSize) external view override returns (LayerZeroPacket.Packet memory) {

        require(_remoteAddressSize > 0, "ProofLib: invalid address size");

        (uint16 remoteChainId, bytes32 blockHash, bytes[] memory proof, uint[] memory receiptSlotIndex, uint logIndex) = abi.decode(_transactionProof, (uint16, bytes32, bytes[], uint[], uint));

        ULNLog memory log = _getVerifiedLog(_receiptsRoot, receiptSlotIndex, logIndex, proof);
        require(log.topicZeroSig == PACKET_SIGNATURE, "ProofLib: packet not recognized"); //data

        LayerZeroPacket.Packet memory packet = log.data.getPacket(remoteChainId, _remoteAddressSize, log.contractAddress);

        _assertMessagePath(packet, blockHash, _receiptsRoot);

        if (packet.dstAddress == stargateBridgeAddress) packet.payload = _secureStgPayload(packet.payload);

        if (packet.dstAddress == stgTokenAddress) packet.payload = _secureStgTokenPayload(packet.payload);

        return packet;
    }

    function _assertMessagePath(LayerZeroPacket.Packet memory packet, bytes32 blockHash, bytes32 receiptsRoot) internal view {

        require(packet.dstChainId == localChainId, "ProofLib: invalid destination chain ID");

        IUltraLightNode.ApplicationConfiguration memory appConfig = uln.getAppConfig(packet.srcChainId, packet.dstAddress);
        IUltraLightNode.BlockData memory blockData = uln.getBlockHeaderData(appConfig.oracle, packet.srcChainId, blockHash);
        require(appConfig.relayer == relayerAddress, "ProofLib: invalid relayer");

        require(blockData.data == receiptsRoot, "ProofLib: invalid receipt root");

        require(blockData.confirmations >= appConfig.inboundBlockConfirmations, "ProofLib: not enough block confirmations");
    }

    function _secureStgTokenPayload(bytes memory _payload) internal pure returns (bytes memory) {

        (bytes memory toAddressBytes, uint256 qty) = abi.decode(_payload, (bytes, uint256));

        address toAddress = address(0);
        if (toAddressBytes.length > 0) {
            assembly { toAddress := mload(add(toAddressBytes, 20))}
        }

        if (toAddress == address(0)) {
            address deadAddress = address(0x000000000000000000000000000000000000dEaD);
            bytes memory newToAddressBytes = abi.encodePacked(deadAddress);
            return abi.encode(newToAddressBytes, qty);
        }

        return _payload;
    }

    function _secureStgPayload(bytes memory _payload) internal view returns (bytes memory) {

        uint8 functionType;
        assembly { functionType := mload(add(_payload, 32)) }

        if (functionType == 1) {
            (
                ,
                uint256 srcPoolId,
                uint256 dstPoolId,
                uint256 dstGasForCall,
                IStargate.CreditObj memory c,
                IStargate.SwapObj memory s,
                bytes memory toAddressBytes,
                bytes memory contractCallPayload
            ) = abi.decode(_payload, (uint8, uint256, uint256, uint256, IStargate.CreditObj, IStargate.SwapObj, bytes, bytes));

            if (contractCallPayload.length > 0) {
                address toAddress = address(0);
                if (toAddressBytes.length > 0) {
                    assembly { toAddress := mload(add(toAddressBytes, 20)) }
                }

                uint size;
                assembly { size := extcodesize(toAddress) }

                if (size == 0) {
                    bytes memory newToAddressBytes = abi.encodePacked(toAddress);
                    bytes memory securePayload = abi.encode(functionType, srcPoolId, dstPoolId, dstGasForCall, c, s, newToAddressBytes, bytes(""));
                    return securePayload;
                }
            }
        }

        return _payload;
    }

    function secureStgTokenPayload(bytes memory _payload) external pure returns(bytes memory) {

        return _secureStgTokenPayload(_payload);
    }

    function secureStgPayload(bytes memory _payload) external view returns(bytes memory) {

        return _secureStgPayload(_payload);
    }

    function _getVerifiedLog(bytes32 hashRoot, uint[] memory paths, uint logIndex, bytes[] memory proof) internal pure returns(ULNLog memory) {

        require(paths.length == proof.length, "ProofLib: invalid proof size");
        require(proof.length >0, "ProofLib: proof size must > 0");
        RLPDecode.RLPItem memory item;
        bytes memory proofBytes;

        for (uint i = 0; i < proof.length; i++) {
            proofBytes = proof[i];
            require(hashRoot == keccak256(proofBytes), "ProofLib: invalid hashlink");
            item = RLPDecode.toRlpItem(proofBytes).safeGetItemByIndex(paths[i]);
            if (i < proof.length - 1) hashRoot = bytes32(item.toUint());
        }

        RLPDecode.RLPItem memory logItem = item.typeOffset().safeGetItemByIndex(3);
        RLPDecode.Iterator memory it =  logItem.safeGetItemByIndex(logIndex).iterator();
        ULNLog memory log;
        log.contractAddress = bytes32(it.next().toUint());
        log.topicZeroSig = bytes32(it.next().safeGetItemByIndex(0).toUint());
        log.data = it.next().toBytes();

        return log;
    }

    function getUtilsVersion() external override view returns(uint8) {

        return utilsVersion;
    }

    function getVerifyLog(bytes32 hashRoot, uint[] memory receiptSlotIndex, uint logIndex, bytes[] memory proof) external override pure returns(ULNLog memory){

        return _getVerifiedLog(hashRoot, receiptSlotIndex, logIndex, proof);
    }

    function getPacket(bytes memory data, uint16 srcChain, uint sizeOfSrcAddress, bytes32 ulnAddress) external override pure returns(LayerZeroPacket.Packet memory){

        return data.getPacket(srcChain, sizeOfSrcAddress, ulnAddress);
    }

    function assertMessagePath(LayerZeroPacket.Packet memory packet, bytes32 blockHash, bytes32 receiptsRoot) external view {

        _assertMessagePath(packet, blockHash, receiptsRoot);
    }
}