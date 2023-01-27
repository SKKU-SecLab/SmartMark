
pragma solidity ^0.8.0;

interface INamelessTemplateLibrary {

  function getTemplate(uint256 templateIndex) external view returns (bytes32[] memory dataSection, bytes32[] memory codeSection);

  function getContentApis() external view returns (string memory arweaveContentApi, string memory ipfsContentApi);

}// MIT

pragma solidity ^0.8.0;
interface INamelessToken {

  function initialize(string memory name, string memory symbol, address tokenDataContract, address initialAdmin) external;

}// MIT

pragma solidity ^0.8.0;
interface INamelessTokenData {

  function initialize ( address templateLibrary, address clonableTokenAddress, address initialAdmin, uint256 maxGenerationSize ) external;
  function getTokenURI(uint256 tokenId, address owner) external view returns (string memory);

  function beforeTokenTransfer(address from, address, uint256 tokenId) external returns (bool);

  function redeem(uint256 tokenId) external;

  function getFeeRecipients(uint256) external view returns (address payable[] memory);

  function getFeeBps(uint256) external view returns (uint256[] memory);

}// MIT
pragma solidity ^0.8.0;

library BinaryDecoder {

    function increment(uint bufferIdx, uint offset, uint amount) internal pure returns (uint, uint) {

      offset+=amount;
      return (bufferIdx + (offset / 32), offset % 32);
    }

    function decodeUint8(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint8, uint, uint) {

      uint8 result = 0;
      result |= uint8(buffers[bufferIdx][offset]);
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      return (result, bufferIdx, offset);
    }

    function decodeUint16(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint16, uint, uint) {

      uint result = 0;
      if (offset % 32 < 31) {
        return decodeUint16Aligned(buffers, bufferIdx, offset);
      }

      result |= uint(uint8(buffers[bufferIdx][offset])) << 8;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset]));
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      return (uint16(result), bufferIdx, offset);
    }

    function decodeUint16Aligned(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint16, uint, uint) {

      uint result = 0;
      result |= uint(uint8(buffers[bufferIdx][offset])) << 8;
      result |= uint(uint8(buffers[bufferIdx][offset + 1]));
      (bufferIdx, offset) = increment(bufferIdx, offset, 2);
      return (uint16(result), bufferIdx, offset);
    }

    function decodeUint32(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint32, uint, uint) {

      if (offset % 32 < 29) {
        return decodeUint32Aligned(buffers, bufferIdx, offset);
      }

      uint result = 0;
      result |= uint(uint8(buffers[bufferIdx][offset])) << 24;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 16;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 8;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset]));
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      return (uint32(result), bufferIdx, offset);
    }

    function decodeUint32Aligned(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint32, uint, uint) {

      uint result = 0;
      result |= uint(uint8(buffers[bufferIdx][offset])) << 24;
      result |= uint(uint8(buffers[bufferIdx][offset + 1])) << 16;
      result |= uint(uint8(buffers[bufferIdx][offset + 2])) << 8;
      result |= uint(uint8(buffers[bufferIdx][offset + 3]));
      (bufferIdx, offset) = increment(bufferIdx, offset, 4);
      return (uint32(result), bufferIdx, offset);
    }

    function decodeUint64(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint64, uint, uint) {

      if (offset % 32 < 25) {
        return decodeUint64Aligned(buffers, bufferIdx, offset);
      }

      uint result = 0;
      result |= uint(uint8(buffers[bufferIdx][offset])) << 56;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 48;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 40;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 32;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 24;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 16;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 8;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset]));
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      return (uint64(result), bufferIdx, offset);
    }

    function decodeUint64Aligned(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint64, uint, uint) {

      uint result = 0;
      result |= uint(uint8(buffers[bufferIdx][offset])) << 56;
      result |= uint(uint8(buffers[bufferIdx][offset + 1])) << 48;
      result |= uint(uint8(buffers[bufferIdx][offset + 2])) << 40;
      result |= uint(uint8(buffers[bufferIdx][offset + 3])) << 32;
      result |= uint(uint8(buffers[bufferIdx][offset + 4])) << 24;
      result |= uint(uint8(buffers[bufferIdx][offset + 5])) << 16;
      result |= uint(uint8(buffers[bufferIdx][offset + 6])) << 8;
      result |= uint(uint8(buffers[bufferIdx][offset + 7]));
      (bufferIdx, offset) = increment(bufferIdx, offset, 8);
      return (uint64(result), bufferIdx, offset);
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}// MIT
pragma solidity ^0.8.0;


library PackedVarArray {

  function getString(bytes32[0xFFFF] storage buffers, uint offset, uint len) internal view returns (string memory) {

    bytes memory result = new bytes(len);

    uint bufferIdx = offset / 32;
    uint bufferOffset = offset % 32;
    uint outIdx = 0;
    uint remaining = len;
    uint bufferCap = 32 - bufferOffset;


    while (outIdx < len) {
      uint copyCount = remaining > bufferCap ? bufferCap : remaining;
      uint lastOffset = bufferOffset + copyCount;
      bytes32 buffer = bytes32(buffers[bufferIdx]);
      while( bufferOffset < lastOffset) {
        result[outIdx++] = buffer[bufferOffset++];
      }
      remaining -= copyCount;
      bufferCap = 32;
      bufferOffset = 0;
      bufferIdx++;
    }

    return string(result);
  }

  function getString(bytes32[0xFFFF] storage buffers, uint index) internal view returns (string memory) {

    uint offsetLoc = uint(index) * 4;
    uint stringOffsetLen;
    (stringOffsetLen,,) = BinaryDecoder.decodeUint32Aligned(buffers, offsetLoc / 32, offsetLoc % 32);
    uint stringOffset = stringOffsetLen & 0xFFFF;
    uint stringLen = stringOffsetLen >> 16;

    return getString(buffers, stringOffset, stringLen);
  }

  function getStringInfo(bytes32[0xFFFF] storage buffers, uint index) internal view returns ( bytes32 firstSlot, uint offset, uint length ) {

    uint offsetLoc = uint(index) * 4;
    uint stringOffsetLen;
    (stringOffsetLen,,) = BinaryDecoder.decodeUint32Aligned(buffers, offsetLoc / 32, offsetLoc % 32);
    uint stringOffset = stringOffsetLen & 0xFFFF;
    uint stringLen = stringOffsetLen >> 16;
    uint bufferIdx = stringOffset / 32;
    uint bufferOffset = stringOffset % 32;
    bytes32 bufferSlot;

    assembly {
      bufferSlot := buffers.slot
    }

    bufferSlot = bytes32(uint(bufferSlot) +  bufferIdx);


    return (bufferSlot, bufferOffset, stringLen);
  }

  function getStringLength(bytes32[0xFFFF] storage buffers, uint index) internal view returns (uint) {

    uint offsetLoc = uint(index) * 4;
    uint stringOffsetLen;
    (stringOffsetLen,,) = BinaryDecoder.decodeUint32Aligned(buffers, offsetLoc / 32, offsetLoc % 32);
    return stringOffsetLen >> 24;
  }

  function getUint16Array(bytes32[0xFFFF] storage buffers, uint offset, uint len) internal view returns (uint16[] memory) {

    uint16[] memory result = new uint16[](len);

    uint bufferIdx = offset / 32;
    uint bufferOffset = offset % 32;
    uint outIdx = 0;
    uint remaining = len * 2;
    uint bufferCap = 32 - bufferOffset;


    while (outIdx < len) {
      uint copyCount = remaining > bufferCap ? bufferCap : remaining;
      uint lastOffset = bufferOffset + copyCount;
      bytes32 buffer = bytes32(buffers[bufferIdx]);
      while (bufferOffset < lastOffset) {
        result[outIdx]  = uint16(uint8(buffer[bufferOffset++])) << 8;
        result[outIdx] |= uint16(uint8(buffer[bufferOffset++]));
        outIdx++;
      }
      remaining -= copyCount;
      bufferCap = 32;
      bufferOffset = 0;
      bufferIdx++;
    }

    return result;
  }

  function getUint16Array(bytes32[0xFFFF] storage buffers, uint index) internal view returns (uint16[] memory) {

    uint offsetLoc = uint(index) * 4;
    uint arrOffsetLen;
    (arrOffsetLen, ,) = BinaryDecoder.decodeUint32Aligned(buffers, offsetLoc / 32, offsetLoc % 32);
    uint arrOffset = arrOffsetLen & 0xFFFFFF;
    uint arrLen = arrOffsetLen >> 24;

    return getUint16Array(buffers, arrOffset, arrLen);
  }

  function getUint16ArrayInfo(bytes32[0xFFFF] storage buffers, uint index) internal view returns ( uint, uint, uint ) {

    uint offsetLoc = uint(index) * 4;
    uint arrOffsetLen;
    (arrOffsetLen, ,) = BinaryDecoder.decodeUint32Aligned(buffers, offsetLoc / 32, offsetLoc % 32);
    uint arrOffset = arrOffsetLen & 0xFFFFFF;
    uint arrLen = arrOffsetLen >> 24;
    uint bufferIdx = arrOffset / 32;
    uint bufferOffset = arrOffset % 32;

    return (bufferIdx, bufferOffset, arrLen);
  }
}// MIT
pragma solidity ^0.8.0;



library NamelessDataV1 {

  function getGenerationalSlot(uint256 columnName, uint32 generation) internal pure returns (uint256) {

    uint256 finalSlot =
      (columnName & 0x000000007FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) |
      (uint(generation) << 224);

    return finalSlot;
  }


  uint256 private constant MAX_COLUMN_WORDS = 65535;
  uint256 private constant MAX_CONTENT_LIBRARIES_PER_COLUMN = 256;
  uint256 private constant CONTENT_LIBRARY_SECTION_SIZE = 32 * MAX_CONTENT_LIBRARIES_PER_COLUMN;

  uint256 public constant COLUMN_TYPE_STRING = 1;
  uint256 public constant COLUMN_TYPE_UINT256 = 2;
  uint256 public constant COLUMN_TYPE_UINT128 = 3;
  uint256 public constant COLUMN_TYPE_UINT64 = 4;
  uint256 public constant COLUMN_TYPE_UINT32 = 5;
  uint256 public constant COLUMN_TYPE_UINT16 = 6;
  uint256 public constant COLUMN_TYPE_UINT8  = 7;
  uint256 public constant COLUMN_TYPE_NATIVE_STRING = 8;

  function getColumn(bytes32 slot) internal pure returns (bytes32[MAX_COLUMN_WORDS] storage r) {

      assembly {
          r.slot := slot
      }
  }

  function getBufferIndexAndOffset(uint index, uint stride) internal pure returns (uint, uint) {

    uint offset = index * stride;
    return (offset / 32, offset % 32);
  }

  function getBufferIndexAndOffset(uint index, uint stride, uint baseOffset) internal pure returns (uint, uint) {

    uint offset = (index * stride) + baseOffset;
    return (offset / 32, offset % 32);
  }

  function readContentLibraryColumn(bytes32 columnSlot, uint ordinal) public view returns (
    uint contentLibraryHash,
    uint contentIndex
  ) {

    bytes32[MAX_COLUMN_WORDS] storage column = getColumn(columnSlot);
    (uint bufferIndex, uint offset) = getBufferIndexAndOffset(ordinal, 2, CONTENT_LIBRARY_SECTION_SIZE);
    uint row = 0;
    (row, , ) = BinaryDecoder.decodeUint16Aligned(column, bufferIndex, offset);

    uint contentLibraryIndex = row >> 8;
    contentIndex = row & 0xFF;
    contentLibraryHash = uint256(column[contentLibraryIndex]);
  }

  function readDictionaryString(bytes32 dictionarySlot, uint ordinal) public view returns ( string memory ) {

    return PackedVarArray.getString(getColumn(dictionarySlot), ordinal);
  }

  function getDictionaryStringInfo(bytes32 dictionarySlot, uint ordinal) internal view returns ( bytes32 firstSlot, uint offset, uint length ) {

    return PackedVarArray.getStringInfo(getColumn(dictionarySlot), ordinal);
  }

  function readDictionaryStringLength(bytes32 dictionarySlot, uint ordinal) public view returns ( uint ) {

    return PackedVarArray.getStringLength(getColumn(dictionarySlot), ordinal);
  }

  function readUint256Column(bytes32 columnSlot, uint ordinal) public view returns (
    uint
  ) {

    bytes32[MAX_COLUMN_WORDS] storage column = getColumn(columnSlot);
    return uint256(column[ordinal]);
  }

  function readUint128Column(bytes32 columnSlot, uint ordinal) public view returns (
    uint
  ) {

    bytes32[MAX_COLUMN_WORDS] storage column = getColumn(columnSlot);
    uint bufferIndex = ordinal / 2;
    uint shift = (1 - (ordinal % 2)) * 128;
    return (uint256(column[bufferIndex]) >> shift) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
  }

  function readUint64Column(bytes32 columnSlot, uint ordinal) public view returns (
    uint
  ) {

    bytes32[MAX_COLUMN_WORDS] storage column = getColumn(columnSlot);
    uint bufferIndex = ordinal / 4;
    uint shift = (3 - (ordinal % 4)) * 64;
    return (uint256(column[bufferIndex]) >> shift) & 0xFFFFFFFFFFFFFFFF;
  }

  function readUint32Column(bytes32 columnSlot, uint ordinal) public view returns (
    uint
  ) {

    bytes32[MAX_COLUMN_WORDS] storage column = getColumn(columnSlot);
    uint bufferIndex = ordinal / 8;
    uint shift = (7 - (ordinal % 8)) * 32;
    return (uint256(column[bufferIndex]) >> shift) & 0xFFFFFFFF;
  }

  function readUint16Column(bytes32 columnSlot, uint ordinal) public view returns (
    uint
  ) {

    bytes32[MAX_COLUMN_WORDS] storage column = getColumn(columnSlot);
    uint bufferIndex = ordinal / 16;
    uint shift = (15 - (ordinal % 16)) * 16;
    return (uint256(column[bufferIndex]) >> shift) & 0xFFFF;
  }

  function readUint8Column(bytes32 columnSlot, uint ordinal) public view returns (
    uint
  ) {

    bytes32[MAX_COLUMN_WORDS] storage column = getColumn(columnSlot);
    uint bufferIndex = ordinal / 32;
    uint shift = (31 - (ordinal % 32)) * 8;
    return (uint256(column[bufferIndex]) >> shift) & 0xFF;
  }

}// MIT

pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT
pragma solidity ^0.8.0;

library Base64 {


    bytes constant private BASE_64_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory buffer, bytes memory output, uint outOffset) public pure returns (uint) {

      uint outLen = (buffer.length + 2) / 3 * 4;

      uint256 i = 0;
      uint256 j = outOffset;

      for (; i + 3 <= buffer.length; i += 3) {
          (output[j], output[j+1], output[j+2], output[j+3]) = encode3(
              uint8(buffer[i]),
              uint8(buffer[i+1]),
              uint8(buffer[i+2])
          );

          j += 4;
      }

      if (i + 2 == buffer.length) {
        (output[j], output[j+1], output[j+2], ) = encode3(
            uint8(buffer[i]),
            uint8(buffer[i+1]),
            0
        );
        output[j+3] = '=';
      } else if (i + 1 == buffer.length) {
        (output[j], output[j+1], , ) = encode3(
            uint8(buffer[i]),
            0,
            0
        );
        output[j+2] = '=';
        output[j+3] = '=';
      }

      return outOffset + outLen;
    }

    function encode(bytes memory buffer) public pure returns (bytes memory) {

      uint outLen = (buffer.length + 2) / 3 * 4;
      bytes memory result = new bytes(outLen);

      uint256 i = 0;
      uint256 j = 0;

      for (; i + 3 <= buffer.length; i += 3) {
          (result[j], result[j+1], result[j+2], result[j+3]) = encode3(
              uint8(buffer[i]),
              uint8(buffer[i+1]),
              uint8(buffer[i+2])
          );

          j += 4;
      }

      if (i + 2 == buffer.length) {
        (result[j], result[j+1], result[j+2], ) = encode3(
            uint8(buffer[i]),
            uint8(buffer[i+1]),
            0
        );
        result[j+3] = '=';
      } else if (i + 1 == buffer.length) {
        (result[j], result[j+1], , ) = encode3(
            uint8(buffer[i]),
            0,
            0
        );
        result[j+2] = '=';
        result[j+3] = '=';
      }

      return result;
    }

    function encode(uint256 bigint, bytes memory output, uint outOffset) external pure returns (uint) {

        bytes32 buffer = bytes32(bigint);

        uint256 i = 0;
        uint256 j = outOffset;

        for (; i + 3 <= 32; i += 3) {
            (output[j], output[j+1], output[j+2], output[j+3]) = encode3(
                uint8(buffer[i]),
                uint8(buffer[i+1]),
                uint8(buffer[i+2])
            );

            j += 4;
        }
        (output[j], output[j+1], output[j+2], ) = encode3(uint8(buffer[30]), uint8(buffer[31]), 0);
        return outOffset + 43;
    }

    function encode(uint256 bigint) external pure returns (string memory) {

        bytes32 buffer = bytes32(bigint);
        bytes memory res = new bytes(43);

        uint256 i = 0;
        uint256 j = 0;

        for (; i + 3 <= 32; i += 3) {
            (res[j], res[j+1], res[j+2], res[j+3]) = encode3(
                uint8(buffer[i]),
                uint8(buffer[i+1]),
                uint8(buffer[i+2])
            );

            j += 4;
        }
        (res[j], res[j+1], res[j+2], ) = encode3(uint8(buffer[30]), uint8(buffer[31]), 0);
        return string(res);
    }

    function encode3(uint256 a0, uint256 a1, uint256 a2)
        private
        pure
        returns (bytes1 b0, bytes1 b1, bytes1 b2, bytes1 b3)
    {


        uint256 n = (a0 << 16) | (a1 << 8) | a2;

        uint256 c0 = (n >> 18) & 63;
        uint256 c1 = (n >> 12) & 63;
        uint256 c2 = (n >>  6) & 63;
        uint256 c3 = (n      ) & 63;

        b0 = BASE_64_CHARS[c0];
        b1 = BASE_64_CHARS[c1];
        b2 = BASE_64_CHARS[c2];
        b3 = BASE_64_CHARS[c3];
    }

}// MIT

pragma solidity ^0.8.0;



library NamelessMetadataURIV1 {

  bytes constant private BASE_64_URL_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

  function base64EncodeBuffer(bytes memory buffer, bytes memory output, uint outOffset) internal pure returns (uint) {

    uint outLen = (buffer.length + 2) / 3 * 4 - ((3 - ( buffer.length % 3 )) % 3);

    uint256 i = 0;
    uint256 j = outOffset;

    for (; i + 3 <= buffer.length; i += 3) {
        (output[j], output[j+1], output[j+2], output[j+3]) = base64Encode3(
            uint8(buffer[i]),
            uint8(buffer[i+1]),
            uint8(buffer[i+2])
        );

        j += 4;
    }

    if ((i + 2) == buffer.length) {
      (output[j], output[j+1], output[j+2], ) = base64Encode3(
          uint8(buffer[i]),
          uint8(buffer[i+1]),
          0
      );
    } else if ((i + 1) == buffer.length) {
      (output[j], output[j+1], , ) = base64Encode3(
          uint8(buffer[i]),
          0,
          0
      );
    }

    return outOffset + outLen;
  }

  function base64Encode(uint256 bigint, bytes memory output, uint outOffset) internal pure returns (uint) {

      bytes32 buffer = bytes32(bigint);

      uint256 i = 0;
      uint256 j = outOffset;

      for (; i + 3 <= 32; i += 3) {
          (output[j], output[j+1], output[j+2], output[j+3]) = base64Encode3(
              uint8(buffer[i]),
              uint8(buffer[i+1]),
              uint8(buffer[i+2])
          );

          j += 4;
      }
      (output[j], output[j+1], output[j+2], ) = base64Encode3(uint8(buffer[30]), uint8(buffer[31]), 0);
      return outOffset + 43;
  }

  function base64Encode3(uint256 a0, uint256 a1, uint256 a2)
      internal
      pure
      returns (bytes1 b0, bytes1 b1, bytes1 b2, bytes1 b3)
  {


      uint256 n = (a0 << 16) | (a1 << 8) | a2;

      uint256 c0 = (n >> 18) & 63;
      uint256 c1 = (n >> 12) & 63;
      uint256 c2 = (n >>  6) & 63;
      uint256 c3 = (n      ) & 63;

      b0 = BASE_64_URL_CHARS[c0];
      b1 = BASE_64_URL_CHARS[c1];
      b2 = BASE_64_URL_CHARS[c2];
      b3 = BASE_64_URL_CHARS[c3];
  }

  bytes constant private BASE_58_CHARS = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

  function ipfsCidEncode(bytes32 value, bytes memory output, uint outOffset) internal pure returns (uint) {

    uint encodedLen = 0;
    for (uint idx = 0; idx < 34; idx++)
    {
      uint carry = 0;
      if (idx >= 2) {
        carry = uint8(value[idx - 2]);
      } else if (idx == 1) {
        carry = 0x20;
      } else if (idx == 0) {
        carry = 0x12;
      }

      for (uint jdx = 0; jdx < encodedLen; jdx++)
      {
        carry = carry + (uint(uint8(output[outOffset + 45 - jdx])) << 8);
        output[outOffset + 45 - jdx] = bytes1(uint8(carry % 58));
        carry /= 58;
      }
      while (carry > 0) {
        output[outOffset + 45 - encodedLen++] = bytes1(uint8(carry % 58));
        carry /= 58;
      }
    }

    for (uint idx = 0; idx < 46; idx++) {
      output[outOffset + idx] = BASE_58_CHARS[uint8(output[outOffset + idx])];
    }

    return outOffset + 46;
  }

  function base10Encode(uint256 bigint, bytes memory output, uint outOffset) internal pure returns (uint) {

    bytes memory alphabet = '0123456789';
    if (bigint == 0) {
      output[outOffset] = alphabet[0];
      return outOffset + 1;
    }

    uint digits = 0;
    uint value = bigint;
    while (value > 0) {
      digits++;
      value = value / 10;
    }

    value = bigint;
    uint currentOffset = outOffset + digits - 1;
    while (value > 0) {
      output[currentOffset] = alphabet[value % 10];
      currentOffset--;
      value = value / 10;
    }

    return outOffset + digits;
  }



  function writeAddressToString(address addr, bytes memory output, uint outOffset) internal pure returns(uint) {

    bytes32 value = bytes32(uint256(uint160(addr)));
    bytes memory alphabet = '0123456789abcdef';

    output[outOffset++] = '0';
    output[outOffset++] = 'x';
    for (uint256 i = 0; i < 20; i++) {
      output[outOffset + (i*2) ]    = alphabet[uint8(value[i + 12] >> 4)];
      output[outOffset + (i*2) + 1] = alphabet[uint8(value[i + 12] & 0x0f)];
    }
    outOffset += 40;
    return outOffset;
  }

  function copyDictionaryString(Context memory context, bytes32 columnSlot, uint256 ordinal) internal view returns (uint) {

    bytes32 curSlot;
    uint offset;
    uint length;
    (curSlot, offset, length) = NamelessDataV1.getDictionaryStringInfo(columnSlot, ordinal);

    bytes32 curBuffer;
    uint remaining = length;
    uint bufferCap = 32 - offset;
    uint outIdx = 0;

    while (outIdx < length) {
      uint copyCount = remaining > bufferCap ? bufferCap : remaining;
      uint lastOffset = offset + copyCount;
      curBuffer = StorageSlot.getBytes32Slot(curSlot).value;

      while( offset < lastOffset) {
        context.output[context.outOffset + outIdx++] = curBuffer[offset++];
      }
      remaining -= copyCount;
      bufferCap = 32;
      offset = 0;
      curSlot = bytes32(uint(curSlot) + 1);
    }

    return context.outOffset + outIdx;
  }

  function copyString(Context memory context, string memory value) internal pure returns (uint) {

    for (uint idx = 0; idx < bytes(value).length; idx++) {
      context.output[context.outOffset + idx] = bytes(value)[idx];
    }

    return context.outOffset + bytes(value).length;
  }

  function copyNativeString(Context memory context, bytes32 columnSlot, uint256 ordinal) internal view returns (uint) {

    string[] storage nativeStrings;
    assembly {
      nativeStrings.slot := columnSlot
    }

    bytes storage buffer = bytes(nativeStrings[ordinal]);
    uint length = buffer.length;

    for (uint idx = 0; idx < length; idx++) {
      context.output[context.outOffset + idx] = buffer[idx];
    }

    return context.outOffset + length;
  }


  struct Context {
    uint codeBufferIndex;
    uint codeBufferOffset;
    uint256 tokenId;
    uint32 generation;
    uint   index;
    address owner;
    string arweaveContentApi;
    string ipfsContentApi;

    uint opsRetired;

    uint outOffset;
    bytes output;
    bool done;
    uint8  stackLength;
    bytes32[0xFF] stack;
  }

  function execWrite(Context memory context, bytes32[] memory, bytes32[] memory codeSegment) internal pure {

    require(context.stackLength > 0, 'stack underflow');
    uint format = uint8(codeSegment[context.codeBufferIndex][context.codeBufferOffset]);
    incrementCodeOffset(context);

    uint start = uint8(codeSegment[context.codeBufferIndex][context.codeBufferOffset]);
    incrementCodeOffset(context);

    uint end = uint8(codeSegment[context.codeBufferIndex][context.codeBufferOffset]);
    incrementCodeOffset(context);

    if (format == 0) {
      bytes32 stackTop = bytes32(context.stack[context.stackLength - 1]);
      for (uint idx = start; idx < end; idx++) {
        context.output[ context.outOffset ++ ] = stackTop[idx];
      }
    } else if (format == 1) {
      uint256 stackTop = uint256(context.stack[context.stackLength - 1]);
      bytes memory alphabet = '0123456789abcdef';
      uint startNibble = start * 2;
      uint endNibble = end * 2;

      stackTop >>= (64 - endNibble) * 4;

      context.output[context.outOffset++] = '0';
      context.output[context.outOffset++] = 'x';
      for (uint256 i = endNibble-1; i >= startNibble; i--) {
        uint nibble = stackTop & 0xf;
        stackTop >>= 4;
        context.output[context.outOffset + i - startNibble ] = alphabet[nibble];
      }
      context.outOffset += endNibble - startNibble;
    } else if (format == 2) {
      uint256 stackTop = uint256(context.stack[context.stackLength - 1]);
      if (start == 0 && end == 32) {
        context.outOffset = base64Encode(stackTop, context.output, context.outOffset);
      } else {
        uint length = end - start;
        bytes memory temp = new bytes(length);
        for (uint idx = 0; idx < length; idx++) {
          temp[idx] = bytes32(stackTop)[start + idx];
        }
        context.outOffset = base64EncodeBuffer(temp, context.output, context.outOffset);
      }
    } else if (format == 3) {
      require(start == 0 && end == 32, 'invalid cid length');
      context.outOffset = ipfsCidEncode(context.stack[context.stackLength - 1], context.output, context.outOffset);
    } else if (format == 4) {
      uint mask = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF >> (start * 8);
      uint shift = (32 - end) * 8;
      uint value = (uint256(context.stack[context.stackLength - 1]) & mask) >> shift;
      context.outOffset = base10Encode(value, context.output, context.outOffset);
    }


    context.stackLength--;
  }
  function execWriteContext(Context memory context, bytes32[] memory, bytes32[] memory codeSegment) internal view {

    require(context.stack.length > 0, 'stack underflow');
    uint contextId = uint(context.stack[context.stackLength - 1]);
    context.stackLength--;

    uint format = uint8(codeSegment[context.codeBufferIndex][context.codeBufferOffset]);
    incrementCodeOffset(context);

    if (contextId == CONTEXT_TOKEN_ID || contextId == CONTEXT_TOKEN_OWNER || contextId == CONTEXT_BLOCK_TIMESTAMP || contextId == CONTEXT_GENERATION || contextId == CONTEXT_INDEX ) {
      require(format != 0, 'invalid format for uint256');
      uint value = 0;
      if (contextId == CONTEXT_TOKEN_ID) {
        value = context.tokenId;
      } else if (contextId == CONTEXT_TOKEN_OWNER ) {
        value = uint256(uint160(context.owner));
      } else if (contextId == CONTEXT_BLOCK_TIMESTAMP ) {
        value = uint256(block.timestamp);
      } else if (contextId == CONTEXT_GENERATION ) {
        value = context.generation;
      } else if (contextId == CONTEXT_INDEX ) {
        value = context.index;
      }

      if (format == 1) {
        bytes memory alphabet = '0123456789abcdef';
        context.output[context.outOffset++] = '0';
        context.output[context.outOffset++] = 'x';
        for (uint256 i = 63; i >= 0; i--) {
          uint nibble = value & 0xf;
          value >>= 4;
          context.output[context.outOffset + i] = alphabet[nibble];
        }
        context.outOffset += 64;
      } else if (format == 2) {
        context.outOffset = base64Encode(value, context.output, context.outOffset);
      } else if (format == 4) {
        context.outOffset = base10Encode(value, context.output, context.outOffset);
      }

    } else if (contextId == CONTEXT_ARWEAVE_CONTENT_API || contextId == CONTEXT_IPFS_CONTENT_API ) {
      require(format == 0, 'invalid format for string');
      string memory value;
      if (contextId == CONTEXT_ARWEAVE_CONTENT_API) {
        value = context.arweaveContentApi;
      } else if ( contextId == CONTEXT_IPFS_CONTENT_API) {
        value = context.ipfsContentApi;
      }

      context.outOffset = copyString(context, value);
    } else {
      revert(string(abi.encodePacked('Unknown/unsupported context ID', Strings.toString(contextId))));
    }
  }

  function execWriteColumnar(Context memory context, bytes32[] memory, bytes32[] memory codeSegment) internal view {

    require(context.stack.length > 1, 'stack underflow');
    bytes32 rawColumnSlot = context.stack[context.stackLength - 2];
    bytes32 columnSlot = bytes32(NamelessDataV1.getGenerationalSlot(uint(rawColumnSlot), context.generation));
    uint columnIndex = uint(context.stack[context.stackLength - 1]);
    context.stackLength -= 2;

    uint format = uint8(codeSegment[context.codeBufferIndex][context.codeBufferOffset]);
    incrementCodeOffset(context);

    uint256 columnMetadata = StorageSlot.getUint256Slot(columnSlot).value;
    uint columnType = (columnMetadata >> 248) & 0xFF;

    if (columnType == NamelessDataV1.COLUMN_TYPE_NATIVE_STRING) {
      require(format == 0, 'invalid format for string');
      context.outOffset = copyNativeString(context, bytes32(uint256(columnSlot) + 1), columnIndex);
    } else if (columnType == NamelessDataV1.COLUMN_TYPE_STRING) {
      require(format == 0, 'invalid format for string');
      context.outOffset = copyDictionaryString(context, bytes32(uint256(columnSlot) + 1), columnIndex);
    } else if (columnType >= NamelessDataV1.COLUMN_TYPE_UINT256 && columnType <= NamelessDataV1.COLUMN_TYPE_UINT8) {
      require(format != 0, 'invalid format for uint');
      uint value = 0;

      if (columnType == NamelessDataV1.COLUMN_TYPE_UINT256) {
        value = NamelessDataV1.readUint256Column(bytes32(uint256(columnSlot) + 1), columnIndex);
      } else if (columnType == NamelessDataV1.COLUMN_TYPE_UINT128) {
        value = NamelessDataV1.readUint128Column(bytes32(uint256(columnSlot) + 1), columnIndex);
      } else if (columnType == NamelessDataV1.COLUMN_TYPE_UINT64) {
        value = NamelessDataV1.readUint64Column(bytes32(uint256(columnSlot) + 1), columnIndex);
      } else if (columnType == NamelessDataV1.COLUMN_TYPE_UINT32) {
        value = NamelessDataV1.readUint32Column(bytes32(uint256(columnSlot) + 1), columnIndex);
      } else if (columnType == NamelessDataV1.COLUMN_TYPE_UINT16) {
        value = NamelessDataV1.readUint16Column(bytes32(uint256(columnSlot) + 1), columnIndex);
      } else if (columnType == NamelessDataV1.COLUMN_TYPE_UINT8) {
        value = NamelessDataV1.readUint8Column(bytes32(uint256(columnSlot) + 1), columnIndex);
      }

      if (format == 1) {
        bytes memory alphabet = '0123456789abcdef';
        context.output[context.outOffset++] = '0';
        context.output[context.outOffset++] = 'x';
        for (uint256 i = 63; i >= 0; i--) {
          uint nibble = value & 0xf;
          value >>= 4;
          context.output[context.outOffset + i] = alphabet[nibble];
        }
        context.outOffset += 64;
      } else if (format == 2) {
        context.outOffset = base64Encode(value, context.output, context.outOffset);
      } else if (format == 3) {
        context.outOffset = ipfsCidEncode(bytes32(value), context.output, context.outOffset);
      } else if (format == 4) {
        context.outOffset = base10Encode(value, context.output, context.outOffset);
      }
    } else {
      revert('unknown column type');
    }
  }

  function execPushData(Context memory context, bytes32[] memory dataSegment, bytes32[] memory) internal pure {

    context.stack[context.stackLength-1] = dataSegment[uint256(context.stack[context.stackLength-1])];
  }

  function execPushImmediate(Context memory context, bytes32[] memory, bytes32[] memory codeSegment) internal pure {

    uint startShiftByte = 31 - uint8(codeSegment[context.codeBufferIndex][context.codeBufferOffset]);
    incrementCodeOffset(context);

    uint length = uint8(codeSegment[context.codeBufferIndex][context.codeBufferOffset]);
    incrementCodeOffset(context);

    uint256 value = 0;
    for (uint idx = 0; idx < length; idx++) {
      uint byteVal = uint8(codeSegment[context.codeBufferIndex][context.codeBufferOffset]);
      incrementCodeOffset(context);
      value |= byteVal << ((startShiftByte - idx) * 8);
    }

    context.stack[context.stackLength++] = bytes32(value);
  }

  uint private constant CONTEXT_TOKEN_ID = 0;
  uint private constant CONTEXT_TOKEN_OWNER = 1;
  uint private constant CONTEXT_BLOCK_TIMESTAMP = 2;
  uint private constant CONTEXT_ARWEAVE_CONTENT_API = 3;
  uint private constant CONTEXT_IPFS_CONTENT_API = 4;
  uint private constant CONTEXT_GENERATION = 5;
  uint private constant CONTEXT_INDEX = 6;


  function execPushContext(Context memory context, bytes32[] memory, bytes32[] memory) internal view {

    uint contextId = uint256(context.stack[context.stackLength-1]);

    if (contextId == CONTEXT_TOKEN_ID) {
      context.stack[context.stackLength-1] = bytes32(context.tokenId);
    } else if (contextId == CONTEXT_TOKEN_OWNER ) {
      context.stack[context.stackLength-1] = bytes32(uint256(uint160(context.owner)));
    } else if (contextId == CONTEXT_BLOCK_TIMESTAMP ) {
      context.stack[context.stackLength-1] = bytes32(uint256(block.timestamp));
    } else if (contextId == CONTEXT_GENERATION) {
      context.stack[context.stackLength-1] = bytes32(uint(context.generation));
    } else if (contextId == CONTEXT_INDEX) {
      context.stack[context.stackLength-1] = bytes32(context.index);
    } else {
      revert('Unknown/unsupported context ID in push');
    }
  }

  function execPushStorage(Context memory context, bytes32[] memory, bytes32[] memory) internal view {

    bytes32 stackTop = context.stack[context.stackLength - 1];
    context.stack[context.stackLength - 1] = StorageSlot.getBytes32Slot(stackTop).value;
  }

  function execPushColumnar(Context memory context, bytes32[] memory, bytes32[] memory) internal view {

    require(context.stack.length > 1, 'stack underflow');
    bytes32 rawColumnSlot = context.stack[context.stackLength - 2];
    bytes32 columnSlot = bytes32(NamelessDataV1.getGenerationalSlot(uint(rawColumnSlot), context.generation));
    uint columnIndex = uint(context.stack[context.stackLength - 1]);
    context.stackLength -= 1;

    uint256 columnMetadata = StorageSlot.getUint256Slot(columnSlot).value;
    uint columnType = (columnMetadata >> 248) & 0xFF;

    if (columnType == NamelessDataV1.COLUMN_TYPE_UINT256) {
      uint value = NamelessDataV1.readUint256Column(bytes32(uint256(columnSlot) + 1), columnIndex);
      context.stack[context.stackLength - 1] = bytes32(value);
    } else if (columnType == NamelessDataV1.COLUMN_TYPE_UINT128) {
      uint value = NamelessDataV1.readUint128Column(bytes32(uint256(columnSlot) + 1), columnIndex);
      context.stack[context.stackLength - 1] = bytes32(value);
    } else if (columnType == NamelessDataV1.COLUMN_TYPE_UINT64) {
      uint value = NamelessDataV1.readUint64Column(bytes32(uint256(columnSlot) + 1), columnIndex);
      context.stack[context.stackLength - 1] = bytes32(value);
    } else if (columnType == NamelessDataV1.COLUMN_TYPE_UINT32) {
      uint value = NamelessDataV1.readUint32Column(bytes32(uint256(columnSlot) + 1), columnIndex);
      context.stack[context.stackLength - 1] = bytes32(value);
    } else if (columnType == NamelessDataV1.COLUMN_TYPE_UINT16) {
      uint value = NamelessDataV1.readUint16Column(bytes32(uint256(columnSlot) + 1), columnIndex);
      context.stack[context.stackLength - 1] = bytes32(value);
    } else if (columnType == NamelessDataV1.COLUMN_TYPE_UINT8) {
      uint value = NamelessDataV1.readUint8Column(bytes32(uint256(columnSlot) + 1), columnIndex);
      context.stack[context.stackLength - 1] = bytes32(value);
    } else {
      revert('unknown or bad column type');
    }
  }

  function execPop(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    context.stackLength--;
  }

  function execDup(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    context.stack[context.stackLength] = context.stack[context.stackLength - 1];
    context.stackLength++;
  }

  function execSwap(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    (context.stack[context.stackLength - 1], context.stack[context.stackLength - 2]) = (context.stack[context.stackLength - 2], context.stack[context.stackLength - 1]);
  }

  function execAdd(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    uint256 a = uint256(context.stack[context.stackLength - 2]);
    uint256 b = uint256(context.stack[context.stackLength - 1]);
    context.stack[context.stackLength - 2] = bytes32(a + b);
    context.stackLength--;
  }

  function execSub(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    uint256 a = uint256(context.stack[context.stackLength - 2]);
    uint256 b = uint256(context.stack[context.stackLength - 1]);
    context.stack[context.stackLength - 2] = bytes32(a - b);
    context.stackLength--;
  }

  function execMul(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    uint256 a = uint256(context.stack[context.stackLength - 2]);
    uint256 b = uint256(context.stack[context.stackLength - 1]);
    context.stack[context.stackLength - 2] = bytes32(a * b);
    context.stackLength--;
  }

  function execDiv(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    uint256 a = uint256(context.stack[context.stackLength - 2]);
    uint256 b = uint256(context.stack[context.stackLength - 1]);
    context.stack[context.stackLength - 2] = bytes32(a / b);
    context.stackLength--;
  }

  function execMod(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    uint256 a = uint256(context.stack[context.stackLength - 2]);
    uint256 b = uint256(context.stack[context.stackLength - 1]);
    context.stack[context.stackLength - 2] = bytes32(a % b);
    context.stackLength--;
  }

  function execJumpPos(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    uint256 offset = uint256(context.stack[context.stackLength - 1]);
    context.stackLength--;

    addCodeOffset(context, offset);
  }

  function execJumpNeg(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    uint256 offset = uint256(context.stack[context.stackLength - 1]);
    context.stackLength--;

    subCodeOffset(context, offset);
  }

  function execBrEZPos(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    uint256 value = uint256(context.stack[context.stackLength - 2]);
    uint256 offset = uint256(context.stack[context.stackLength - 1]);
    context.stackLength-=2;

    if (value == 0) {
      addCodeOffset(context, offset);
    }
  }

  function execBrEZNeg(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    uint256 value = uint256(context.stack[context.stackLength - 2]);
    uint256 offset = uint256(context.stack[context.stackLength - 1]);
    context.stackLength-=2;

    if (value == 0) {
      subCodeOffset(context, offset);
    }
  }

  function execSha3(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    bytes32 a = context.stack[context.stackLength - 1];
    context.stack[context.stackLength - 1] = keccak256(abi.encodePacked(a));
  }

  function execXor(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    bytes32 a = context.stack[context.stackLength - 2];
    bytes32 b = context.stack[context.stackLength - 1];
    context.stack[context.stackLength - 2] = a ^ b;
    context.stackLength--;
  }

  function execOr(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    bytes32 a = context.stack[context.stackLength - 2];
    bytes32 b = context.stack[context.stackLength - 1];
    context.stack[context.stackLength - 2] = a | b;
    context.stackLength--;
  }

  function execAnd(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    bytes32 a = context.stack[context.stackLength - 2];
    bytes32 b = context.stack[context.stackLength - 1];
    context.stack[context.stackLength - 2] = a & b;
    context.stackLength--;
  }

  function execGt(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    uint256 a = uint256(context.stack[context.stackLength - 2]);
    uint256 b = uint256(context.stack[context.stackLength - 1]);
    context.stack[context.stackLength - 2] = bytes32(uint256(a > b ? 1 : 0));
    context.stackLength--;
  }

  function execGte(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    uint256 a = uint256(context.stack[context.stackLength - 2]);
    uint256 b = uint256(context.stack[context.stackLength - 1]);
    context.stack[context.stackLength - 2] = bytes32(uint256(a >= b ? 1 : 0));
    context.stackLength--;
  }

  function execLt(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    uint256 a = uint256(context.stack[context.stackLength - 2]);
    uint256 b = uint256(context.stack[context.stackLength - 1]);
    context.stack[context.stackLength - 2] = bytes32(uint256(a < b ? 1 : 0));
    context.stackLength--;
  }

  function execLte(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    uint256 a = uint256(context.stack[context.stackLength - 2]);
    uint256 b = uint256(context.stack[context.stackLength - 1]);
    context.stack[context.stackLength - 2] = bytes32(uint256(a <= b ? 1 : 0));
    context.stackLength--;
  }

  function execEq(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    bytes32 a = context.stack[context.stackLength - 2];
    bytes32 b = context.stack[context.stackLength - 1];
    context.stack[context.stackLength - 2] = bytes32(uint256(a == b ? 1 : 0));
    context.stackLength--;
  }

  function execNeq(Context memory context, bytes32[] memory, bytes32[] memory) internal pure {

    bytes32 a = context.stack[context.stackLength - 2];
    bytes32 b = context.stack[context.stackLength - 1];
    context.stack[context.stackLength - 2] = bytes32(uint256(a != b ? 1 : 0));
    context.stackLength--;
  }

  uint private constant OP_NOOP                = 0x00;
  uint private constant OP_WRITE               = 0x01;
  uint private constant OP_WRITE_CONTEXT       = 0x02;
  uint private constant OP_WRITE_COLUMNAR      = 0x04;
  uint private constant OP_PUSH_DATA           = 0x05;
  uint private constant OP_PUSH_STORAGE        = 0x06;
  uint private constant OP_PUSH_IMMEDIATE      = 0x07;
  uint private constant OP_PUSH_CONTEXT        = 0x08;
  uint private constant OP_PUSH_COLUMNAR       = 0x09;
  uint private constant OP_POP                 = 0x0a;
  uint private constant OP_DUP                 = 0x0b;
  uint private constant OP_SWAP                = 0x0c;
  uint private constant OP_ADD                 = 0x0d;
  uint private constant OP_SUB                 = 0x0e;
  uint private constant OP_MUL                 = 0x0f;
  uint private constant OP_DIV                 = 0x10;
  uint private constant OP_MOD                 = 0x11;
  uint private constant OP_JUMP_POS            = 0x12;
  uint private constant OP_JUMP_NEG            = 0x13;
  uint private constant OP_BRANCH_POS_EQ_ZERO  = 0x14;
  uint private constant OP_BRANCH_NEG_EQ_ZERO  = 0x15;
  uint private constant OP_SHA3                = 0x16;
  uint private constant OP_XOR                 = 0x17;
  uint private constant OP_OR                  = 0x18;
  uint private constant OP_AND                 = 0x19;
  uint private constant OP_GT                  = 0x1a;
  uint private constant OP_GTE                 = 0x1b;
  uint private constant OP_LT                  = 0x1c;
  uint private constant OP_LTE                 = 0x1d;
  uint private constant OP_EQ                  = 0x1e;
  uint private constant OP_NEQ                 = 0x1f;

  function incrementCodeOffset(Context memory context) internal pure {

    context.codeBufferOffset++;
    if (context.codeBufferOffset == 32) {
      context.codeBufferOffset = 0;
      context.codeBufferIndex++;
    }
  }

  function addCodeOffset(Context memory context, uint offset) internal pure {

    uint pc = (context.codeBufferIndex * 32) + context.codeBufferOffset;
    pc += offset;
    context.codeBufferOffset = pc % 32;
    context.codeBufferIndex = pc / 32;
  }

  function subCodeOffset(Context memory context, uint offset) internal pure {

    uint pc = (context.codeBufferIndex * 32) + context.codeBufferOffset;
    pc -= offset;
    context.codeBufferOffset = pc % 32;
    context.codeBufferIndex = pc / 32;
  }

  function execOne(Context memory context, bytes32[] memory dataSegment, bytes32[] memory codeSegment) internal view {

    uint nextOp = uint8(codeSegment[context.codeBufferIndex][context.codeBufferOffset]);

    incrementCodeOffset(context);

    if (nextOp == OP_NOOP) {
    } else if (nextOp == OP_WRITE) {
      execWrite(context, dataSegment, codeSegment);
    } else if (nextOp == OP_WRITE_CONTEXT) {
      execWriteContext(context, dataSegment, codeSegment);
    } else if (nextOp == OP_WRITE_COLUMNAR) {
      execWriteColumnar(context, dataSegment, codeSegment);
    } else if (nextOp == OP_PUSH_DATA) {
      execPushData(context, dataSegment, codeSegment);
    } else if (nextOp == OP_PUSH_STORAGE) {
      execPushStorage(context, dataSegment, codeSegment);
    } else if (nextOp == OP_PUSH_IMMEDIATE) {
      execPushImmediate(context, dataSegment, codeSegment);
    } else if (nextOp == OP_PUSH_CONTEXT) {
      execPushContext(context, dataSegment, codeSegment);
    } else if (nextOp == OP_PUSH_COLUMNAR) {
      execPushColumnar(context, dataSegment, codeSegment);
    } else if (nextOp == OP_POP) {
      execPop(context, dataSegment, codeSegment);
    } else if (nextOp == OP_DUP) {
      execDup(context, dataSegment, codeSegment);
    } else if (nextOp == OP_SWAP) {
      execSwap(context, dataSegment, codeSegment);
    } else if (nextOp == OP_ADD) {
      execAdd(context, dataSegment, codeSegment);
    } else if (nextOp == OP_SUB) {
      execSub(context, dataSegment, codeSegment);
    } else if (nextOp == OP_MUL) {
      execMul(context, dataSegment, codeSegment);
    } else if (nextOp == OP_DIV) {
      execDiv(context, dataSegment, codeSegment);
    } else if (nextOp == OP_MOD) {
      execMod(context, dataSegment, codeSegment);
    } else if (nextOp == OP_JUMP_POS) {
      execJumpPos(context, dataSegment, codeSegment);
    } else if (nextOp == OP_JUMP_NEG) {
      execJumpNeg(context, dataSegment, codeSegment);
    } else if (nextOp == OP_BRANCH_POS_EQ_ZERO) {
      execBrEZPos(context, dataSegment, codeSegment);
    } else if (nextOp == OP_BRANCH_NEG_EQ_ZERO) {
      execBrEZNeg(context, dataSegment, codeSegment);
    } else if (nextOp == OP_SHA3) {
      execSha3(context, dataSegment, codeSegment);
    } else if (nextOp == OP_XOR) {
      execXor(context, dataSegment, codeSegment);
    } else if (nextOp == OP_OR) {
      execOr(context, dataSegment, codeSegment);
    } else if (nextOp == OP_AND) {
      execAnd(context, dataSegment, codeSegment);
    } else if (nextOp == OP_GT) {
      execGt(context, dataSegment, codeSegment);
    } else if (nextOp == OP_GTE) {
      execGte(context, dataSegment, codeSegment);
    } else if (nextOp == OP_LT) {
      execLt(context, dataSegment, codeSegment);
    } else if (nextOp == OP_LTE) {
      execLte(context, dataSegment, codeSegment);
    } else if (nextOp == OP_EQ) {
      execEq(context, dataSegment, codeSegment);
    } else if (nextOp == OP_NEQ) {
      execNeq(context, dataSegment, codeSegment);
    } else {
      revert(string(abi.encodePacked('bad op code: ', Strings.toString(nextOp), ' next_pc: ', Strings.toString(context.codeBufferIndex), ',',  Strings.toString(context.codeBufferOffset))));
    }

    context.opsRetired++;

    if (/*context.opsRetired > 7 || */context.codeBufferIndex >= codeSegment.length) {
      context.done = true;
    }
  }

  function interpolateTemplate(uint256 tokenId, uint32 generation, uint index, address owner, string memory arweaveContentApi, string memory ipfsContentApi, bytes32[] memory dataSegment, bytes32[] memory codeSegment) internal view returns (bytes memory) {

    Context memory context;
    context.output = new bytes(0xFFFF);
    context.tokenId = tokenId;
    context.generation = generation;
    context.index = index;
    context.owner = owner;
    context.arweaveContentApi = arweaveContentApi;
    context.ipfsContentApi = ipfsContentApi;
    context.outOffset = 0;

    while (!context.done) {
      execOne(context, dataSegment, codeSegment);
    }

    bytes memory result = context.output;
    uint resultLen = context.outOffset;

    assembly {
      mstore(result, resultLen)
    }

    return result;
  }

  function makeJson( uint256 tokenId, uint32 generation, uint index, address owner, string memory arweaveContentApi, string memory ipfsContentApi, bytes32[] memory dataSegment, bytes32[] memory codeSegment ) public view returns (string memory) {

    bytes memory metadata = interpolateTemplate(tokenId, generation, index, owner, arweaveContentApi, ipfsContentApi, dataSegment, codeSegment);
    return string(metadata);
  }

  function makeDataURI( string memory uriBase, uint256 tokenId, uint32 generation, uint index, address owner, string memory arweaveContentApi, string memory ipfsContentApi, bytes32[] memory dataSegment, bytes32[] memory codeSegment ) public view returns (string memory) {

    bytes memory metadata = interpolateTemplate(tokenId, generation, index, owner, arweaveContentApi, ipfsContentApi, dataSegment, codeSegment);
    return string(abi.encodePacked(uriBase,Base64.encode(metadata)));
  }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(address implementation, bytes32 salt, address deployer) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt) internal view returns (address predicted) {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}// MIT

pragma solidity ^0.8.0;


contract NamelessTokenData is INamelessTokenData, AccessControl, Initializable {

  bytes32 public constant INFRA_ROLE = keccak256('INFRA_ROLE');
  bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');

  address private _templateLibrary;
  string private _uriBase;
  address public clonableTokenAddress;
  address public frontendAddress;
  address payable public royaltyAddress;
  uint256 public royaltyBps;
  uint256 public maxGenerationSize;

  function initialize (
    address templateLibrary_,
    address clonableTokenAddress_,
    address initialAdmin,
    uint256 maxGenerationSize_
  ) public override initializer {
    _templateLibrary = templateLibrary_;
    _uriBase = 'data:application/json;base64,';
    clonableTokenAddress = clonableTokenAddress_;
    maxGenerationSize = maxGenerationSize_;
    _setupRole(DEFAULT_ADMIN_ROLE, initialAdmin);
  }

  constructor(
    address templateLibrary_,
    address clonableTokenAddress_,
    uint256 maxGenerationSize_
  ) {
    initialize(templateLibrary_, clonableTokenAddress_, msg.sender, maxGenerationSize_);
  }

  mapping (uint32 => bool) public generationSealed;

  modifier onlyUnsealed(uint32 generation) {

    require(!generationSealed[generation], 'genration is sealed');
    _;
  }

  modifier onlyFrontend() {

    require(msg.sender == frontendAddress, 'caller not frontend');
    _;
  }

  function sealGeneration(uint32 generation) public onlyRole(DEFAULT_ADMIN_ROLE) onlyUnsealed(generation){

    generationSealed[generation] = true;
  }

  function _setColumnData(uint256 columnHash, bytes32[] memory data, uint offset ) internal  {

    bytes32[0xFFFF] storage storageData;
    uint256 columnDataHash = columnHash + 1;
    assembly {
      storageData.slot := columnDataHash
    }

    for( uint idx = 0; idx < data.length; idx++) {
      storageData[idx + offset] = data[idx];
    }
  }

  function _setColumnMetadata(uint256 columnHash, uint columnType ) internal {

    uint256[1] storage columnMetadata;
    assembly {
      columnMetadata.slot := columnHash
    }

    columnMetadata[0] = columnMetadata[0] | ((columnType & 0xFF) << 248);
  }

  struct ColumnConfiguration {
    uint256 columnHash;
    uint256 columnType;
    uint256 dataOffset;
    bytes32[] data;
  }

  function configureData( uint32 generation, ColumnConfiguration[] calldata configs) public onlyRole(DEFAULT_ADMIN_ROLE) onlyUnsealed(generation) {

    for(uint idx = 0; idx < configs.length; idx++) {
      uint256 generationSlot = NamelessDataV1.getGenerationalSlot(configs[idx].columnHash, generation);
      _setColumnMetadata(generationSlot, configs[idx].columnType);
      _setColumnData(generationSlot, configs[idx].data, configs[idx].dataOffset);
    }
  }

  function idToGenerationIndex(uint256 tokenId) internal view returns (uint32 generation, uint index) {

    generation = uint32(tokenId / maxGenerationSize);
    index = tokenId % maxGenerationSize;
  }

  uint256 public constant TOKEN_TRANSFER_COUNT_EXTENSION = 0x1;
  uint256 public constant TOKEN_TRANSFER_TIME_EXTENSION  = 0x2;
  uint256 public constant TOKEN_REDEEMABLE_EXTENSION     = 0x4;

  mapping (uint => uint256) public extensions;
  function enableExtensions(uint32 generation, uint256 newExtensions) public onlyRole(DEFAULT_ADMIN_ROLE) onlyUnsealed(generation) {

    extensions[generation] = extensions[generation] | newExtensions;

    if (newExtensions & TOKEN_TRANSFER_COUNT_EXTENSION != 0) {
      initializeTokenTransferCountExtension(generation);
    }

    if (newExtensions & TOKEN_TRANSFER_TIME_EXTENSION != 0) {
      initializeTokenTransferTimeExtension(generation);
    }

    if (newExtensions & TOKEN_REDEEMABLE_EXTENSION != 0) {
      initializeTokenRedeemableExtension(generation);
    }
  }

  uint256 public constant TOKEN_TRANSFER_COUNT_EXTENSION_SLOT = uint256(keccak256('TOKEN_TRANSFER_COUNT_EXTENSION_SLOT'));
  function initializeTokenTransferCountExtension(uint32 generation) internal {

    uint256[1] storage storageMetadata;
    uint generationalSlot = NamelessDataV1.getGenerationalSlot(TOKEN_TRANSFER_COUNT_EXTENSION_SLOT, generation);
    assembly {
      storageMetadata.slot := generationalSlot
    }

    storageMetadata[0] = 0x2 << 248;
  }

  function processTokenTransferCountExtension(uint32 generation, uint index) internal {

    uint256[0xFFFF] storage storageData;
    uint generationalSlot = NamelessDataV1.getGenerationalSlot(TOKEN_TRANSFER_COUNT_EXTENSION_SLOT, generation);
    uint256 dataSlot = generationalSlot + 1;
    assembly {
      storageData.slot := dataSlot
    }

    storageData[index] = storageData[index] + 1;
  }

  uint256 public constant TOKEN_TRANSFER_TIME_EXTENSION_SLOT = uint256(keccak256('TOKEN_TRANSFER_TIME_EXTENSION_SLOT'));
  function initializeTokenTransferTimeExtension(uint32 generation) internal {

    uint256[1] storage storageMetadata;
    uint generationalSlot = NamelessDataV1.getGenerationalSlot(TOKEN_TRANSFER_TIME_EXTENSION_SLOT, generation);
    assembly {
      storageMetadata.slot := generationalSlot
    }

    storageMetadata[0] = 0x2 << 248;
  }

  function processTokenTransferTimeExtension(uint32 generation, uint index) internal {

    uint256[0xFFFF] storage storageData;
    uint generationalSlot = NamelessDataV1.getGenerationalSlot(TOKEN_TRANSFER_COUNT_EXTENSION_SLOT, generation);
    uint256 dataSlot = generationalSlot + 1;
    assembly {
      storageData.slot := dataSlot
    }

    storageData[index] = block.timestamp;
  }

  uint256 public constant TOKEN_REDEMPTION_EXTENSION_COUNT_SLOT = uint256(keccak256('TOKEN_REDEMPTION_EXTENSION_COUNT_SLOT'));

  function initializeTokenRedeemableExtension(uint32 generation) internal {

    uint256[1] storage storageMetadata;
    uint generationalSlot = NamelessDataV1.getGenerationalSlot(TOKEN_REDEMPTION_EXTENSION_COUNT_SLOT, generation);
    assembly {
      storageMetadata.slot := generationalSlot
    }

    storageMetadata[0] = 0x2 << 248;  // uint256
  }


  function beforeTokenTransfer(address from, address, uint256 tokenId) public onlyFrontend override returns (bool) {

    (uint32 generation, uint index) = idToGenerationIndex(tokenId);
    if (extensions[generation] & TOKEN_TRANSFER_COUNT_EXTENSION != 0) {
      if (from != address(0)) {
        processTokenTransferCountExtension(generation, index);
      }
    }

    if (extensions[generation] & TOKEN_TRANSFER_TIME_EXTENSION != 0) {
      processTokenTransferTimeExtension(generation, index);
    }

    return extensions[generation] & (TOKEN_TRANSFER_COUNT_EXTENSION | TOKEN_TRANSFER_TIME_EXTENSION) != 0;
  }

  function redeem(uint256 tokenId) public onlyFrontend override {

    (uint32 generation, uint index) = idToGenerationIndex(tokenId);
    require(extensions[generation] & TOKEN_REDEEMABLE_EXTENSION != 0, 'Token is not redeemable' );

    uint256[65535] storage redemptionCount;
    uint generationalSlot = NamelessDataV1.getGenerationalSlot(TOKEN_REDEMPTION_EXTENSION_COUNT_SLOT, generation);
    uint256 redemptionCountSlot = generationalSlot + 1;

    assembly {
      redemptionCount.slot := redemptionCountSlot
    }

    redemptionCount[index] = redemptionCount[index] + 1;
  }

  function setRoyalties( address payable newRoyaltyAddress, uint256 newRoyaltyBps ) public onlyRole(DEFAULT_ADMIN_ROLE) {

    royaltyAddress = newRoyaltyAddress;
    royaltyBps = newRoyaltyBps;
  }

  function getFeeRecipients(uint256) public view override returns (address payable[] memory) {

    address payable[] memory result = new address payable[](1);
    result[0] = royaltyAddress;
    return result;
  }

  function getFeeBps(uint256) public view override returns (uint256[] memory) {

    uint256[] memory result = new uint256[](1);
    result[0] = royaltyBps;
    return result;
  }

  function setURIBase(string calldata uriBase_) public onlyRole(INFRA_ROLE) {

    _uriBase = uriBase_;
  }

  mapping (uint32 => uint256) public templateIndex;
  mapping (uint32 => bytes32[]) public templateData;
  mapping (uint32 => bytes32[]) public templateCode;

  function setLibraryTemplate(uint32 generation, uint256 which) public onlyRole(DEFAULT_ADMIN_ROLE) {

    templateIndex[generation] = which;
    delete(templateData[generation]);
    delete(templateCode[generation]);
  }

  function setCustomTemplate(uint32 generation, bytes32[] calldata _data, bytes32[] calldata _code) public onlyRole(DEFAULT_ADMIN_ROLE) {

    delete(templateIndex[generation]);
    templateData[generation] = _data;
    templateCode[generation] = _code;
  }

  function getTokenURI(uint256 tokenId, address owner) public view override returns (string memory) {

    string memory arweaveContentApi;
    string memory ipfsContentApi;
    (arweaveContentApi, ipfsContentApi) = INamelessTemplateLibrary(_templateLibrary).getContentApis();
    (uint32 generation, uint index) = idToGenerationIndex(tokenId);

    if (templateCode[generation].length > 0) {
      return NamelessMetadataURIV1.makeDataURI(_uriBase, tokenId, generation, index, owner, arweaveContentApi, ipfsContentApi, templateData[generation], templateCode[generation]);
    } else {
      bytes32[] memory libraryTemplateData;
      bytes32[] memory libraryTemplateCode;
      (libraryTemplateData, libraryTemplateCode) = INamelessTemplateLibrary(_templateLibrary).getTemplate(templateIndex[generation]);
      return NamelessMetadataURIV1.makeDataURI(_uriBase, tokenId, generation, index, owner, arweaveContentApi, ipfsContentApi, libraryTemplateData, libraryTemplateCode);
    }
  }

  function getTokenMetadata(uint256 tokenId, address owner) public view returns (string memory) {

    string memory arweaveContentApi;
    string memory ipfsContentApi;
    (arweaveContentApi, ipfsContentApi) = INamelessTemplateLibrary(_templateLibrary).getContentApis();
    (uint32 generation, uint index) = idToGenerationIndex(tokenId);

    if (templateCode[generation].length > 0) {
      return NamelessMetadataURIV1.makeJson(tokenId, generation, index, owner, arweaveContentApi, ipfsContentApi, templateData[generation], templateCode[generation]);
    } else {
      bytes32[] memory libraryTemplateData;
      bytes32[] memory libraryTemplateCode;
      (libraryTemplateData, libraryTemplateCode) = INamelessTemplateLibrary(_templateLibrary).getTemplate(templateIndex[generation]);
      return NamelessMetadataURIV1.makeJson(tokenId, generation, index, owner, arweaveContentApi, ipfsContentApi, libraryTemplateData, libraryTemplateCode);
    }
  }

  function createFrontend(string calldata name, string calldata symbol) public onlyRole(MINTER_ROLE) returns (address) {

    require(frontendAddress == address(0), 'frontend already created');
    frontendAddress = Clones.clone(clonableTokenAddress);

    INamelessToken frontend = INamelessToken(frontendAddress);
    frontend.initialize(name, symbol, address(this), msg.sender);

    return frontendAddress;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override( AccessControl) returns (bool) {

    return AccessControl.supportsInterface(interfaceId);
  }

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping (uint256 => address) private _owners;

    mapping (address => uint256) private _balances;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}// MIT

pragma solidity ^0.8.0;


contract NamelessToken is INamelessToken, ERC721Enumerable, AccessControl, Initializable {
  event TokenMetadataChanged(uint256 tokenId);
  event TokenRedeemed(uint256 tokenId, uint256 timestamp, string memo);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');
  bytes32 public constant REDEEM_ROLE = keccak256('REDEEM_ROLE');

  string private _name;
  string private _symbol;
  address private _legacyOwner;

  address public tokenDataContract;

  function initialize (
    string memory name_,
    string memory symbol_,
    address tokenDataContract_,
    address initialAdmin
  ) public initializer override {
    _name = name_;
    _symbol = symbol_;
    _legacyOwner = initialAdmin;
    tokenDataContract = tokenDataContract_;
    _setupRole(DEFAULT_ADMIN_ROLE, initialAdmin);
    emit OwnershipTransferred(address(0), initialAdmin);
  }

  constructor(
    string memory name_,
    string memory symbol_,
    address tokenDataContract_
  ) ERC721(name_, symbol_) {
    initialize(name_, symbol_, tokenDataContract_, msg.sender);
  }

  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  function owner() public view returns (address) {
    return _legacyOwner;
  }

  function transferLegacyOwnership(address newOwner) public onlyRole(DEFAULT_ADMIN_ROLE) {
      require(newOwner != address(0), 'new owner is null');
      _legacyOwner = newOwner;
      emit OwnershipTransferred(_legacyOwner, newOwner);
  }

  bytes4 private constant _INTERFACE_ID_FEES = 0xb7799584;

  function getFeeRecipients(uint256 tokenId) public view returns (address payable[] memory) {
    return INamelessTokenData(tokenDataContract).getFeeRecipients(tokenId);
  }

  function getFeeBps(uint256 tokenId) public view returns (uint256[] memory) {
    return INamelessTokenData(tokenDataContract).getFeeBps(tokenId);
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    require(_exists(tokenId), 'no such token');
    return INamelessTokenData(tokenDataContract).getTokenURI(tokenId, ownerOf(tokenId));
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId);
    if (INamelessTokenData(tokenDataContract).beforeTokenTransfer(from, to, tokenId)) {
      emit TokenMetadataChanged(tokenId);
    }
  }

  function redeem(uint256 tokenId, uint256 timestamp, string calldata memo) public onlyRole(REDEEM_ROLE) {
    INamelessTokenData(tokenDataContract).redeem(tokenId);
    emit TokenRedeemed(tokenId, timestamp, memo);
  }

  function mint(address to, uint256 tokenId) public onlyRole(MINTER_ROLE) {
    _safeMint(to, tokenId);
  }

  function mint(address creator, address recipient, uint256 tokenId) public onlyRole(MINTER_ROLE) {
    _safeMint(creator, tokenId);
    _safeTransfer(creator, recipient, tokenId, '');
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
    return interfaceId == _INTERFACE_ID_FEES
      || ERC721Enumerable.supportsInterface(interfaceId)
      || AccessControl.supportsInterface(interfaceId);
  }
}// MIT

pragma solidity ^0.8.0;


contract NamelessMintingQueue is AccessControl {
  constructor( ) {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  struct MintingInfo {
    address minter;
    address tokenContract;
    address recipient;
    uint[]  tokenIds;
    string name;
    string symbol;
  }

  mapping (address => MintingInfo ) public mintingInfoByData;

  function addMintingInfo(address minter, address recipient, address tokenDataContract, string calldata name, string calldata symbol, uint256[] calldata tokenIds) public onlyRole(DEFAULT_ADMIN_ROLE) {
    if (mintingInfoByData[tokenDataContract].minter == address(0)) {
      mintingInfoByData[tokenDataContract].minter = minter;
      mintingInfoByData[tokenDataContract].recipient = recipient;
      mintingInfoByData[tokenDataContract].name = name;
      mintingInfoByData[tokenDataContract].symbol = symbol;
    } else {
      require(
        mintingInfoByData[tokenDataContract].minter == address(0) && mintingInfoByData[tokenDataContract].recipient == address(0),
        'cannot update actors'
      );

      require(
        bytes(name).length == 0 && bytes(symbol).length == 0,
        'cannot update token params'
      );
    }

    for(uint idx; idx < tokenIds.length; idx++) {
      mintingInfoByData[tokenDataContract].tokenIds.push(tokenIds[idx]);
    }
  }

  function dropMintingInfo(address tokenDataContract) public onlyRole(DEFAULT_ADMIN_ROLE) {
    delete mintingInfoByData[tokenDataContract];
  }

  function processMintingQueue(address tokenDataContract, uint maxTokens) public {
    MintingInfo storage info = mintingInfoByData[tokenDataContract];
    require(info.minter != address(0), 'no such data contract');
    require(info.tokenContract == address(0) || info.tokenIds.length > 0, 'nothing to do');
    require(msg.sender == info.minter, 'not authorized');

    if (info.tokenContract == address(0)) {
      info.tokenContract = NamelessTokenData(tokenDataContract).createFrontend(info.name, info.symbol);
      require(info.tokenContract != address(0), 'failed to create frontend');

      NamelessToken token = NamelessToken(info.tokenContract);
      token.grantRole(token.MINTER_ROLE(), address(this));
      token.grantRole(token.DEFAULT_ADMIN_ROLE(), info.minter);
      token.grantRole(token.REDEEM_ROLE(), info.minter);
      token.transferLegacyOwnership(info.minter);
      token.renounceRole(token.DEFAULT_ADMIN_ROLE(), address(this));
    }

    uint numToMint = maxTokens < info.tokenIds.length ? maxTokens : info.tokenIds.length;
    for (uint idx = 0; idx < numToMint; idx++) {
      NamelessToken(info.tokenContract).mint(msg.sender,info.recipient, info.tokenIds[idx]);
    }

    if (numToMint == info.tokenIds.length) {
      delete info.tokenIds;
    } else {
      uint remaining = info.tokenIds.length - numToMint;
      for (uint idx = 0; idx < remaining; idx++) {
        info.tokenIds[idx] = info.tokenIds[numToMint + idx];
      }

      while (info.tokenIds.length > remaining) {
        info.tokenIds.pop();
      }
    }
  }
}