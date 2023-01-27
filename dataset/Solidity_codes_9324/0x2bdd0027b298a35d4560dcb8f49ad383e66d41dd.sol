


pragma solidity >=0.7.0 <0.9.0;

pragma experimental ABIEncoderV2;

interface IWitnetRequest {

    function bytecode() external view returns (bytes memory);


    function hash() external view returns (bytes32);

}
library Witnet {


    function hash(bytes memory _bytecode) internal pure returns (bytes32) {

        return sha256(_bytecode);
    }

    struct Query {
        Request request;
        Response response;
        address from;      // Address from which the request was posted.
    }

    enum QueryStatus {
        Unknown,
        Posted,
        Reported,
        Deleted
    }

    struct Request {
        IWitnetRequest addr;    // The contract containing the Data Request which execution has been requested.
        address requester;      // Address from which the request was posted.
        bytes32 hash;           // Hash of the Data Request whose execution has been requested.
        uint256 gasprice;       // Minimum gas price the DR resolver should pay on the solving tx.
        uint256 reward;         // Escrowed reward to be paid to the DR resolver.
    }

    struct Response {
        address reporter;       // Address from which the result was reported.
        uint256 timestamp;      // Timestamp of the Witnet-provided result.
        bytes32 drTxHash;       // Hash of the Witnet transaction that solved the queried Data Request.
        bytes   cborBytes;      // Witnet-provided result CBOR-bytes to the queried Data Request.
    }

    struct Result {
        bool success;           // Flag stating whether the request could get solved successfully, or not.
        CBOR value;             // Resulting value, in CBOR-serialized bytes.
    }

    struct CBOR {
        Buffer buffer;
        uint8 initialByte;
        uint8 majorType;
        uint8 additionalInformation;
        uint64 len;
        uint64 tag;
    }

    struct Buffer {
        bytes data;
        uint32 cursor;
    }

    enum ErrorCodes {
        Unknown,
        SourceScriptNotCBOR,
        SourceScriptNotArray,
        SourceScriptNotRADON,
        ScriptFormat0x04,
        ScriptFormat0x05,
        ScriptFormat0x06,
        ScriptFormat0x07,
        ScriptFormat0x08,
        ScriptFormat0x09,
        ScriptFormat0x0A,
        ScriptFormat0x0B,
        ScriptFormat0x0C,
        ScriptFormat0x0D,
        ScriptFormat0x0E,
        ScriptFormat0x0F,
        RequestTooManySources,
        ScriptTooManyCalls,
        Complexity0x12,
        Complexity0x13,
        Complexity0x14,
        Complexity0x15,
        Complexity0x16,
        Complexity0x17,
        Complexity0x18,
        Complexity0x19,
        Complexity0x1A,
        Complexity0x1B,
        Complexity0x1C,
        Complexity0x1D,
        Complexity0x1E,
        Complexity0x1F,
        UnsupportedOperator,
        Operator0x21,
        Operator0x22,
        Operator0x23,
        Operator0x24,
        Operator0x25,
        Operator0x26,
        Operator0x27,
        Operator0x28,
        Operator0x29,
        Operator0x2A,
        Operator0x2B,
        Operator0x2C,
        Operator0x2D,
        Operator0x2E,
        Operator0x2F,
        HTTP,
        RetrievalTimeout,
        Retrieval0x32,
        Retrieval0x33,
        Retrieval0x34,
        Retrieval0x35,
        Retrieval0x36,
        Retrieval0x37,
        Retrieval0x38,
        Retrieval0x39,
        Retrieval0x3A,
        Retrieval0x3B,
        Retrieval0x3C,
        Retrieval0x3D,
        Retrieval0x3E,
        Retrieval0x3F,
        Underflow,
        Overflow,
        DivisionByZero,
        Math0x43,
        Math0x44,
        Math0x45,
        Math0x46,
        Math0x47,
        Math0x48,
        Math0x49,
        Math0x4A,
        Math0x4B,
        Math0x4C,
        Math0x4D,
        Math0x4E,
        Math0x4F,
        NoReveals,
        InsufficientConsensus,
        InsufficientCommits,
        TallyExecution,
        OtherError0x54,
        OtherError0x55,
        OtherError0x56,
        OtherError0x57,
        OtherError0x58,
        OtherError0x59,
        OtherError0x5A,
        OtherError0x5B,
        OtherError0x5C,
        OtherError0x5D,
        OtherError0x5E,
        OtherError0x5F,
        MalformedReveal,
        OtherError0x61,
        OtherError0x62,
        OtherError0x63,
        OtherError0x64,
        OtherError0x65,
        OtherError0x66,
        OtherError0x67,
        OtherError0x68,
        OtherError0x69,
        OtherError0x6A,
        OtherError0x6B,
        OtherError0x6C,
        OtherError0x6D,
        OtherError0x6E,
        OtherError0x6F,
        ArrayIndexOutOfBounds,
        MapKeyNotFound,
        OtherError0x72,
        OtherError0x73,
        OtherError0x74,
        OtherError0x75,
        OtherError0x76,
        OtherError0x77,
        OtherError0x78,
        OtherError0x79,
        OtherError0x7A,
        OtherError0x7B,
        OtherError0x7C,
        OtherError0x7D,
        OtherError0x7E,
        OtherError0x7F,
        OtherError0x80,
        OtherError0x81,
        OtherError0x82,
        OtherError0x83,
        OtherError0x84,
        OtherError0x85,
        OtherError0x86,
        OtherError0x87,
        OtherError0x88,
        OtherError0x89,
        OtherError0x8A,
        OtherError0x8B,
        OtherError0x8C,
        OtherError0x8D,
        OtherError0x8E,
        OtherError0x8F,
        OtherError0x90,
        OtherError0x91,
        OtherError0x92,
        OtherError0x93,
        OtherError0x94,
        OtherError0x95,
        OtherError0x96,
        OtherError0x97,
        OtherError0x98,
        OtherError0x99,
        OtherError0x9A,
        OtherError0x9B,
        OtherError0x9C,
        OtherError0x9D,
        OtherError0x9E,
        OtherError0x9F,
        OtherError0xA0,
        OtherError0xA1,
        OtherError0xA2,
        OtherError0xA3,
        OtherError0xA4,
        OtherError0xA5,
        OtherError0xA6,
        OtherError0xA7,
        OtherError0xA8,
        OtherError0xA9,
        OtherError0xAA,
        OtherError0xAB,
        OtherError0xAC,
        OtherError0xAD,
        OtherError0xAE,
        OtherError0xAF,
        OtherError0xB0,
        OtherError0xB1,
        OtherError0xB2,
        OtherError0xB3,
        OtherError0xB4,
        OtherError0xB5,
        OtherError0xB6,
        OtherError0xB7,
        OtherError0xB8,
        OtherError0xB9,
        OtherError0xBA,
        OtherError0xBB,
        OtherError0xBC,
        OtherError0xBD,
        OtherError0xBE,
        OtherError0xBF,
        OtherError0xC0,
        OtherError0xC1,
        OtherError0xC2,
        OtherError0xC3,
        OtherError0xC4,
        OtherError0xC5,
        OtherError0xC6,
        OtherError0xC7,
        OtherError0xC8,
        OtherError0xC9,
        OtherError0xCA,
        OtherError0xCB,
        OtherError0xCC,
        OtherError0xCD,
        OtherError0xCE,
        OtherError0xCF,
        OtherError0xD0,
        OtherError0xD1,
        OtherError0xD2,
        OtherError0xD3,
        OtherError0xD4,
        OtherError0xD5,
        OtherError0xD6,
        OtherError0xD7,
        OtherError0xD8,
        OtherError0xD9,
        OtherError0xDA,
        OtherError0xDB,
        OtherError0xDC,
        OtherError0xDD,
        OtherError0xDE,
        OtherError0xDF,
        BridgeMalformedRequest,
        BridgePoorIncentives,
        BridgeOversizedResult,
        OtherError0xE3,
        OtherError0xE4,
        OtherError0xE5,
        OtherError0xE6,
        OtherError0xE7,
        OtherError0xE8,
        OtherError0xE9,
        OtherError0xEA,
        OtherError0xEB,
        OtherError0xEC,
        OtherError0xED,
        OtherError0xEE,
        OtherError0xEF,
        OtherError0xF0,
        OtherError0xF1,
        OtherError0xF2,
        OtherError0xF3,
        OtherError0xF4,
        OtherError0xF5,
        OtherError0xF6,
        OtherError0xF7,
        OtherError0xF8,
        OtherError0xF9,
        OtherError0xFA,
        OtherError0xFB,
        OtherError0xFC,
        OtherError0xFD,
        OtherError0xFE,
        UnhandledIntercept
    }
}
library WitnetBuffer {


  modifier notOutOfBounds(uint32 index, uint256 length) {

    require(index < length, "WitnetBuffer: Tried to read from a consumed Buffer (must rewind it first)");
    _;
  }

  function read(Witnet.Buffer memory _buffer, uint32 _length) internal pure returns (bytes memory) {

    require(_buffer.cursor + _length <= _buffer.data.length, "WitnetBuffer: Not enough bytes in buffer when reading");

    bytes memory destination = new bytes(_length);

    if (_length != 0) {
      bytes memory source = _buffer.data;
      uint32 offset = _buffer.cursor;

      uint sourcePointer;
      uint destinationPointer;
      assembly {
        sourcePointer := add(add(source, 32), offset)
        destinationPointer := add(destination, 32)
      }
      memcpy(destinationPointer, sourcePointer, uint(_length));

      seek(_buffer, _length, true);
    }
    return destination;
  }

  function next(Witnet.Buffer memory _buffer) internal pure notOutOfBounds(_buffer.cursor, _buffer.data.length) returns (bytes1) {

    return _buffer.data[_buffer.cursor++];
  }

  function seek(Witnet.Buffer memory _buffer, uint32 _offset, bool _relative) internal pure returns (uint32) {

    if (_relative) {
      require(_offset + _buffer.cursor > _offset, "WitnetBuffer: Integer overflow when seeking");
      _offset += _buffer.cursor;
    }
    require(_offset <= _buffer.data.length, "WitnetBuffer: Not enough bytes in buffer when seeking");
    _buffer.cursor = _offset;
    return _buffer.cursor;
  }

  function seek(Witnet.Buffer memory _buffer, uint32 _relativeOffset) internal pure returns (uint32) {

    return seek(_buffer, _relativeOffset, true);
  }

  function rewind(Witnet.Buffer memory _buffer) internal pure {

    _buffer.cursor = 0;
  }

  function readUint8(Witnet.Buffer memory _buffer) internal pure notOutOfBounds(_buffer.cursor, _buffer.data.length) returns (uint8) {

    bytes memory bytesValue = _buffer.data;
    uint32 offset = _buffer.cursor;
    uint8 value;
    assembly {
      value := mload(add(add(bytesValue, 1), offset))
    }
    _buffer.cursor++;

    return value;
  }

  function readUint16(Witnet.Buffer memory _buffer) internal pure notOutOfBounds(_buffer.cursor + 1, _buffer.data.length) returns (uint16) {

    bytes memory bytesValue = _buffer.data;
    uint32 offset = _buffer.cursor;
    uint16 value;
    assembly {
      value := mload(add(add(bytesValue, 2), offset))
    }
    _buffer.cursor += 2;

    return value;
  }

  function readUint32(Witnet.Buffer memory _buffer) internal pure notOutOfBounds(_buffer.cursor + 3, _buffer.data.length) returns (uint32) {

    bytes memory bytesValue = _buffer.data;
    uint32 offset = _buffer.cursor;
    uint32 value;
    assembly {
      value := mload(add(add(bytesValue, 4), offset))
    }
    _buffer.cursor += 4;

    return value;
  }

  function readUint64(Witnet.Buffer memory _buffer) internal pure notOutOfBounds(_buffer.cursor + 7, _buffer.data.length) returns (uint64) {

    bytes memory bytesValue = _buffer.data;
    uint32 offset = _buffer.cursor;
    uint64 value;
    assembly {
      value := mload(add(add(bytesValue, 8), offset))
    }
    _buffer.cursor += 8;

    return value;
  }

  function readUint128(Witnet.Buffer memory _buffer) internal pure notOutOfBounds(_buffer.cursor + 15, _buffer.data.length) returns (uint128) {

    bytes memory bytesValue = _buffer.data;
    uint32 offset = _buffer.cursor;
    uint128 value;
    assembly {
      value := mload(add(add(bytesValue, 16), offset))
    }
    _buffer.cursor += 16;

    return value;
  }

  function readUint256(Witnet.Buffer memory _buffer) internal pure notOutOfBounds(_buffer.cursor + 31, _buffer.data.length) returns (uint256) {

    bytes memory bytesValue = _buffer.data;
    uint32 offset = _buffer.cursor;
    uint256 value;
    assembly {
      value := mload(add(add(bytesValue, 32), offset))
    }
    _buffer.cursor += 32;

    return value;
  }

  function readFloat16(Witnet.Buffer memory _buffer) internal pure returns (int32) {

    uint32 bytesValue = readUint16(_buffer);
    uint32 sign = bytesValue & 0x8000;
    int32 exponent = (int32(bytesValue & 0x7c00) >> 10) - 15;
    int32 significand = int32(bytesValue & 0x03ff);

    if (exponent == 15) {
      significand |= 0x400;
    }

    int32 result = 0;
    if (exponent >= 0) {
      result = int32((int256(1 << uint256(int256(exponent))) * 10000 * int256(uint256(int256(significand)) | 0x400)) >> 10);
    } else {
      result = int32(((int256(uint256(int256(significand)) | 0x400) * 10000) / int256(1 << uint256(int256(- exponent)))) >> 10);
    }

    if (sign != 0) {
      result *= - 1;
    }
    return result;
  }

  function memcpy(uint _dest, uint _src, uint _len) private pure {

    require(_len > 0, "WitnetBuffer: Cannot copy 0 bytes");

    for (; _len >= 32; _len -= 32) {
      assembly {
        mstore(_dest, mload(_src))
      }
      _dest += 32;
      _src += 32;
    }
    if (_len > 0) {
      uint mask = 256 ** (32 - _len) - 1;
      assembly {
        let srcpart := and(mload(_src), not(mask))
        let destpart := and(mload(_dest), mask)
        mstore(_dest, or(destpart, srcpart))
      }
    }
  }

}

library WitnetDecoderLib {


  using WitnetBuffer for Witnet.Buffer;

  uint32 constant internal _UINT32_MAX = type(uint32).max;
  uint64 constant internal _UINT64_MAX = type(uint64).max;

  function decodeBool(Witnet.CBOR memory _cborValue) public pure returns(bool) {

    _cborValue.len = readLength(_cborValue.buffer, _cborValue.additionalInformation);
    require(_cborValue.majorType == 7, "WitnetDecoderLib: Tried to read a `bool` value from a `Witnet.CBOR` with majorType != 7");
    if (_cborValue.len == 20) {
      return false;
    } else if (_cborValue.len == 21) {
      return true;
    } else {
      revert("WitnetDecoderLib: Tried to read `bool` from a `Witnet.CBOR` with len different than 20 or 21");
    }
  }

  function decodeBytes(Witnet.CBOR memory _cborValue) public pure returns(bytes memory) {

    _cborValue.len = readLength(_cborValue.buffer, _cborValue.additionalInformation);
    if (_cborValue.len == _UINT32_MAX) {
      bytes memory bytesData;

      uint32 itemLength = uint32(readIndefiniteStringLength(_cborValue.buffer, _cborValue.majorType));
      if (itemLength < _UINT32_MAX) {
        bytesData = abi.encodePacked(bytesData, _cborValue.buffer.read(itemLength));
        itemLength = uint32(readIndefiniteStringLength(_cborValue.buffer, _cborValue.majorType));
        if (itemLength < _UINT32_MAX) {
          bytesData = abi.encodePacked(bytesData, _cborValue.buffer.read(itemLength));
        }
      }
      return bytesData;
    } else {
      return _cborValue.buffer.read(uint32(_cborValue.len));
    }
  }

  function decodeBytes32(Witnet.CBOR memory _cborValue) public pure returns(bytes32 _bytes32) {

    bytes memory _bb = decodeBytes(_cborValue);
    uint _len = _bb.length > 32 ? 32 : _bb.length;
    for (uint _i = 0; _i < _len; _i ++) {
        _bytes32 |= bytes32(_bb[_i] & 0xff) >> (_i * 8);
    }
  }

  function decodeFixed16(Witnet.CBOR memory _cborValue) public pure returns(int32) {

    require(_cborValue.majorType == 7, "WitnetDecoderLib: Tried to read a `fixed` value from a `WT.CBOR` with majorType != 7");
    require(_cborValue.additionalInformation == 25, "WitnetDecoderLib: Tried to read `fixed16` from a `WT.CBOR` with additionalInformation != 25");
    return _cborValue.buffer.readFloat16();
  }

  function decodeFixed16Array(Witnet.CBOR memory _cborValue) external pure returns(int32[] memory) {

    require(_cborValue.majorType == 4, "WitnetDecoderLib: Tried to read `int128[]` from a `Witnet.CBOR` with majorType != 4");

    uint64 length = readLength(_cborValue.buffer, _cborValue.additionalInformation);
    require(length < _UINT64_MAX, "WitnetDecoderLib: Indefinite-length CBOR arrays are not supported");

    int32[] memory array = new int32[](length);
    for (uint64 i = 0; i < length; i++) {
      Witnet.CBOR memory item = valueFromBuffer(_cborValue.buffer);
      array[i] = decodeFixed16(item);
    }

    return array;
  }

  function decodeInt128(Witnet.CBOR memory _cborValue) public pure returns(int128) {

    if (_cborValue.majorType == 1) {
      uint64 length = readLength(_cborValue.buffer, _cborValue.additionalInformation);
      return int128(-1) - int128(uint128(length));
    } else if (_cborValue.majorType == 0) {
      return int128(uint128(decodeUint64(_cborValue)));
    }
    revert("WitnetDecoderLib: Tried to read `int128` from a `Witnet.CBOR` with majorType not 0 or 1");
  }

  function decodeInt128Array(Witnet.CBOR memory _cborValue) external pure returns(int128[] memory) {

    require(_cborValue.majorType == 4, "WitnetDecoderLib: Tried to read `int128[]` from a `Witnet.CBOR` with majorType != 4");

    uint64 length = readLength(_cborValue.buffer, _cborValue.additionalInformation);
    require(length < _UINT64_MAX, "WitnetDecoderLib: Indefinite-length CBOR arrays are not supported");

    int128[] memory array = new int128[](length);
    for (uint64 i = 0; i < length; i++) {
      Witnet.CBOR memory item = valueFromBuffer(_cborValue.buffer);
      array[i] = decodeInt128(item);
    }

    return array;
  }

  function decodeString(Witnet.CBOR memory _cborValue) public pure returns(string memory) {

    _cborValue.len = readLength(_cborValue.buffer, _cborValue.additionalInformation);
    if (_cborValue.len == _UINT64_MAX) {
      bytes memory textData;
      bool done;
      while (!done) {
        uint64 itemLength = readIndefiniteStringLength(_cborValue.buffer, _cborValue.majorType);
        if (itemLength < _UINT64_MAX) {
          textData = abi.encodePacked(textData, readText(_cborValue.buffer, itemLength / 4));
        } else {
          done = true;
        }
      }
      return string(textData);
    } else {
      return string(readText(_cborValue.buffer, _cborValue.len));
    }
  }

  function decodeStringArray(Witnet.CBOR memory _cborValue) external pure returns(string[] memory) {

    require(_cborValue.majorType == 4, "WitnetDecoderLib: Tried to read `string[]` from a `Witnet.CBOR` with majorType != 4");

    uint64 length = readLength(_cborValue.buffer, _cborValue.additionalInformation);
    require(length < _UINT64_MAX, "WitnetDecoderLib: Indefinite-length CBOR arrays are not supported");

    string[] memory array = new string[](length);
    for (uint64 i = 0; i < length; i++) {
      Witnet.CBOR memory item = valueFromBuffer(_cborValue.buffer);
      array[i] = decodeString(item);
    }

    return array;
  }

  function decodeUint64(Witnet.CBOR memory _cborValue) public pure returns(uint64) {

    require(_cborValue.majorType == 0, "WitnetDecoderLib: Tried to read `uint64` from a `Witnet.CBOR` with majorType != 0");
    return readLength(_cborValue.buffer, _cborValue.additionalInformation);
  }

  function decodeUint64Array(Witnet.CBOR memory _cborValue) external pure returns(uint64[] memory) {

    require(_cborValue.majorType == 4, "WitnetDecoderLib: Tried to read `uint64[]` from a `Witnet.CBOR` with majorType != 4");

    uint64 length = readLength(_cborValue.buffer, _cborValue.additionalInformation);
    require(length < _UINT64_MAX, "WitnetDecoderLib: Indefinite-length CBOR arrays are not supported");

    uint64[] memory array = new uint64[](length);
    for (uint64 i = 0; i < length; i++) {
      Witnet.CBOR memory item = valueFromBuffer(_cborValue.buffer);
      array[i] = decodeUint64(item);
    }

    return array;
  }

  function valueFromBytes(bytes memory _cborBytes) external pure returns(Witnet.CBOR memory) {

    Witnet.Buffer memory buffer = Witnet.Buffer(_cborBytes, 0);

    return valueFromBuffer(buffer);
  }

  function valueFromBuffer(Witnet.Buffer memory _buffer) public pure returns(Witnet.CBOR memory) {

    require(_buffer.data.length > 0, "WitnetDecoderLib: Found empty buffer when parsing CBOR value");

    uint8 initialByte;
    uint8 majorType = 255;
    uint8 additionalInformation;
    uint64 tag = _UINT64_MAX;

    bool isTagged = true;
    while (isTagged) {
      initialByte = _buffer.readUint8();
      majorType = initialByte >> 5;
      additionalInformation = initialByte & 0x1f;

      if (majorType == 6) {
        tag = readLength(_buffer, additionalInformation);
      } else {
        isTagged = false;
      }
    }

    require(majorType <= 7, "WitnetDecoderLib: Invalid CBOR major type");

    return Witnet.CBOR(
      _buffer,
      initialByte,
      majorType,
      additionalInformation,
      0,
      tag);
  }

  function readLength(Witnet.Buffer memory _buffer, uint8 additionalInformation) private pure returns(uint64) {

    if (additionalInformation < 24) {
      return additionalInformation;
    }
    if (additionalInformation == 24) {
      return _buffer.readUint8();
    }
    if (additionalInformation == 25) {
      return _buffer.readUint16();
    }
    if (additionalInformation == 26) {
      return _buffer.readUint32();
    }
    if (additionalInformation == 27) {
      return _buffer.readUint64();
    }
    if (additionalInformation == 31) {
      return _UINT64_MAX;
    }
    revert("WitnetDecoderLib: Invalid length encoding (non-existent additionalInformation value)");
  }

  function readIndefiniteStringLength(Witnet.Buffer memory _buffer, uint8 majorType) private pure returns(uint64) {

    uint8 initialByte = _buffer.readUint8();
    if (initialByte == 0xff) {
      return _UINT64_MAX;
    }
    uint64 length = readLength(_buffer, initialByte & 0x1f);
    require(length < _UINT64_MAX && (initialByte >> 5) == majorType, "WitnetDecoderLib: Invalid indefinite length");
    return length;
  }

  function readText(Witnet.Buffer memory _buffer, uint64 _length) private pure returns(bytes memory) {

    bytes memory result;
    for (uint64 index = 0; index < _length; index++) {
      uint8 value = _buffer.readUint8();
      if (value & 0x80 != 0) {
        if (value < 0xe0) {
          value = (value & 0x1f) << 6 |
            (_buffer.readUint8() & 0x3f);
          _length -= 1;
        } else if (value < 0xf0) {
          value = (value & 0x0f) << 12 |
            (_buffer.readUint8() & 0x3f) << 6 |
            (_buffer.readUint8() & 0x3f);
          _length -= 2;
        } else {
          value = (value & 0x0f) << 18 |
            (_buffer.readUint8() & 0x3f) << 12 |
            (_buffer.readUint8() & 0x3f) << 6  |
            (_buffer.readUint8() & 0x3f);
          _length -= 3;
        }
      }
      result = abi.encodePacked(result, value);
    }
    return result;
  }
}