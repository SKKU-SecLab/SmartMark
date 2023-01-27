pragma solidity ^0.5.10;



library SafeMath {


    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

        if (_a == 0) {
            return 0;
        }

        c = _a * _b;
        require(c / _a == _b, "Overflow during multiplication.");
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        return _a / _b;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a, "Underflow during subtraction.");
        return _a - _b;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

        c = _a + _b;
        require(c >= _a, "Overflow during addition.");
        return c;
    }
}pragma solidity ^0.5.10;




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

        if (_length == 0) {
            return hex"";
        }
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
}pragma solidity ^0.5.10;



library BTCUtils {

    using BytesLib for bytes;
    using SafeMath for uint256;

    uint256 public constant DIFF1_TARGET = 0xffff0000000000000000000000000000000000000000000000000000;

    uint256 public constant RETARGET_PERIOD = 2 * 7 * 24 * 60 * 60;  // 2 weeks in seconds
    uint256 public constant RETARGET_PERIOD_BLOCKS = 2016;  // 2 weeks in blocks

    uint256 public constant ERR_BAD_ARG = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;


    function determineVarIntDataLength(bytes memory _flag) internal pure returns (uint8) {

        if (uint8(_flag[0]) == 0xff) {
            return 8;  // one-byte flag, 8 bytes data
        }
        if (uint8(_flag[0]) == 0xfe) {
            return 4;  // one-byte flag, 4 bytes data
        }
        if (uint8(_flag[0]) == 0xfd) {
            return 2;  // one-byte flag, 2 bytes data
        }

        return 0;  // flag is data
    }

    function parseVarInt(bytes memory _b) internal pure returns (uint256, uint256) {

        uint8 _dataLen = determineVarIntDataLength(_b);

        if (_dataLen == 0) {
            return (0, uint8(_b[0]));
        }
        if (_b.length < 1 + _dataLen) {
            return (ERR_BAD_ARG, 0);
        }
        uint256 _number = bytesToUint(reverseEndianness(_b.slice(1, _dataLen)));
        return (_dataLen, _number);
    }

    function reverseEndianness(bytes memory _b) internal pure returns (bytes memory) {

        bytes memory _newValue = new bytes(_b.length);

        for (uint i = 0; i < _b.length; i++) {
            _newValue[_b.length - i - 1] = _b[i];
        }

        return _newValue;
    }

    function reverseUint256(uint256 _b) internal pure returns (uint256 v) {

        v = _b;

        v = ((v >> 8) & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) |
            ((v & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF) << 8);
        v = ((v >> 16) & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) |
            ((v & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF) << 16);
        v = ((v >> 32) & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) |
            ((v & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF) << 32);
        v = ((v >> 64) & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) |
            ((v & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF) << 64);
        v = (v >> 128) | (v << 128);
    }

    function bytesToUint(bytes memory _b) internal pure returns (uint256) {

        uint256 _number;

        for (uint i = 0; i < _b.length; i++) {
            _number = _number + uint8(_b[i]) * (2 ** (8 * (_b.length - (i + 1))));
        }

        return _number;
    }

    function lastBytes(bytes memory _b, uint256 _num) internal pure returns (bytes memory) {

        uint256 _start = _b.length.sub(_num);

        return _b.slice(_start, _num);
    }

    function hash160(bytes memory _b) internal pure returns (bytes memory) {

        return abi.encodePacked(ripemd160(abi.encodePacked(sha256(_b))));
    }

    function hash256(bytes memory _b) internal pure returns (bytes32) {

        return sha256(abi.encodePacked(sha256(_b)));
    }

    function hash256View(bytes memory _b) internal view returns (bytes32 res) {

        assembly {
            let ptr := mload(0x40)
            pop(staticcall(gas, 2, add(_b, 32), mload(_b), ptr, 32))
            pop(staticcall(gas, 2, ptr, 32, ptr, 32))
            res := mload(ptr)
        }
    }


    function extractInputAtIndex(bytes memory _vin, uint256 _index) internal pure returns (bytes memory) {

        uint256 _varIntDataLen;
        uint256 _nIns;

        (_varIntDataLen, _nIns) = parseVarInt(_vin);
        require(_varIntDataLen != ERR_BAD_ARG, "Read overrun during VarInt parsing");
        require(_index < _nIns, "Vin read overrun");

        bytes memory _remaining;

        uint256 _len = 0;
        uint256 _offset = 1 + _varIntDataLen;

        for (uint256 _i = 0; _i < _index; _i ++) {
            _remaining = _vin.slice(_offset, _vin.length - _offset);
            _len = determineInputLength(_remaining);
            require(_len != ERR_BAD_ARG, "Bad VarInt in scriptSig");
            _offset = _offset + _len;
        }

        _remaining = _vin.slice(_offset, _vin.length - _offset);
        _len = determineInputLength(_remaining);
        require(_len != ERR_BAD_ARG, "Bad VarInt in scriptSig");
        return _vin.slice(_offset, _len);
    }

    function isLegacyInput(bytes memory _input) internal pure returns (bool) {

        return _input.keccak256Slice(36, 1) != keccak256(hex"00");
    }

    function extractScriptSigLen(bytes memory _input) internal pure returns (uint256, uint256) {

        if (_input.length < 37) {
            return (ERR_BAD_ARG, 0);
        }
        bytes memory _afterOutpoint = _input.slice(36, _input.length - 36);

        uint256 _varIntDataLen;
        uint256 _scriptSigLen;
        (_varIntDataLen, _scriptSigLen) = parseVarInt(_afterOutpoint);

        return (_varIntDataLen, _scriptSigLen);
    }

    function determineInputLength(bytes memory _input) internal pure returns (uint256) {

        uint256 _varIntDataLen;
        uint256 _scriptSigLen;
        (_varIntDataLen, _scriptSigLen) = extractScriptSigLen(_input);
        if (_varIntDataLen == ERR_BAD_ARG) {
            return ERR_BAD_ARG;
        }

        return 36 + 1 + _varIntDataLen + _scriptSigLen + 4;
    }

    function extractSequenceLELegacy(bytes memory _input) internal pure returns (bytes memory) {

        uint256 _varIntDataLen;
        uint256 _scriptSigLen;
        (_varIntDataLen, _scriptSigLen) = extractScriptSigLen(_input);
        require(_varIntDataLen != ERR_BAD_ARG, "Bad VarInt in scriptSig");
        return _input.slice(36 + 1 + _varIntDataLen + _scriptSigLen, 4);
    }

    function extractSequenceLegacy(bytes memory _input) internal pure returns (uint32) {

        bytes memory _leSeqence = extractSequenceLELegacy(_input);
        bytes memory _beSequence = reverseEndianness(_leSeqence);
        return uint32(bytesToUint(_beSequence));
    }
    function extractScriptSig(bytes memory _input) internal pure returns (bytes memory) {

        uint256 _varIntDataLen;
        uint256 _scriptSigLen;
        (_varIntDataLen, _scriptSigLen) = extractScriptSigLen(_input);
        require(_varIntDataLen != ERR_BAD_ARG, "Bad VarInt in scriptSig");
        return _input.slice(36, 1 + _varIntDataLen + _scriptSigLen);
    }



    function extractSequenceLEWitness(bytes memory _input) internal pure returns (bytes memory) {

        return _input.slice(37, 4);
    }

    function extractSequenceWitness(bytes memory _input) internal pure returns (uint32) {

        bytes memory _leSeqence = extractSequenceLEWitness(_input);
        bytes memory _inputeSequence = reverseEndianness(_leSeqence);
        return uint32(bytesToUint(_inputeSequence));
    }

    function extractOutpoint(bytes memory _input) internal pure returns (bytes memory) {

        return _input.slice(0, 36);
    }

    function extractInputTxIdLE(bytes memory _input) internal pure returns (bytes32) {

        return _input.slice(0, 32).toBytes32();
    }

    function extractTxIndexLE(bytes memory _input) internal pure returns (bytes memory) {

        return _input.slice(32, 4);
    }


    function determineOutputLength(bytes memory _output) internal pure returns (uint256) {

        if (_output.length < 9) {
            return ERR_BAD_ARG;
        }
        bytes memory _afterValue = _output.slice(8, _output.length - 8);

        uint256 _varIntDataLen;
        uint256 _scriptPubkeyLength;
        (_varIntDataLen, _scriptPubkeyLength) = parseVarInt(_afterValue);

        if (_varIntDataLen == ERR_BAD_ARG) {
            return ERR_BAD_ARG;
        }

        return 8 + 1 + _varIntDataLen + _scriptPubkeyLength;
    }

    function extractOutputAtIndex(bytes memory _vout, uint256 _index) internal pure returns (bytes memory) {

        uint256 _varIntDataLen;
        uint256 _nOuts;

        (_varIntDataLen, _nOuts) = parseVarInt(_vout);
        require(_varIntDataLen != ERR_BAD_ARG, "Read overrun during VarInt parsing");
        require(_index < _nOuts, "Vout read overrun");

        bytes memory _remaining;

        uint256 _len = 0;
        uint256 _offset = 1 + _varIntDataLen;

        for (uint256 _i = 0; _i < _index; _i ++) {
            _remaining = _vout.slice(_offset, _vout.length - _offset);
            _len = determineOutputLength(_remaining);
            require(_len != ERR_BAD_ARG, "Bad VarInt in scriptPubkey");
            _offset += _len;
        }

        _remaining = _vout.slice(_offset, _vout.length - _offset);
        _len = determineOutputLength(_remaining);
        require(_len != ERR_BAD_ARG, "Bad VarInt in scriptPubkey");
        return _vout.slice(_offset, _len);
    }

    function extractValueLE(bytes memory _output) internal pure returns (bytes memory) {

        return _output.slice(0, 8);
    }

    function extractValue(bytes memory _output) internal pure returns (uint64) {

        bytes memory _leValue = extractValueLE(_output);
        bytes memory _beValue = reverseEndianness(_leValue);
        return uint64(bytesToUint(_beValue));
    }

    function extractOpReturnData(bytes memory _output) internal pure returns (bytes memory) {

        if (_output.keccak256Slice(9, 1) != keccak256(hex"6a")) {
            return hex"";
        }
        bytes memory _dataLen = _output.slice(10, 1);
        return _output.slice(11, bytesToUint(_dataLen));
    }

    function extractHash(bytes memory _output) internal pure returns (bytes memory) {

        uint8 _scriptLen = uint8(_output[8]);

        if (_scriptLen + 9 != _output.length) {
            return hex"";
        }

        if (uint8(_output[9]) == 0) {
            if (_scriptLen < 2) {
                return hex"";
            }
            uint256 _payloadLen = uint8(_output[10]);
            if (_payloadLen != _scriptLen - 2 || (_payloadLen != 0x20 && _payloadLen != 0x14)) {
                return hex"";
            }
            return _output.slice(11, _payloadLen);
        } else {
            bytes32 _tag = _output.keccak256Slice(8, 3);
            if (_tag == keccak256(hex"1976a9")) {
                if (uint8(_output[11]) != 0x14 ||
                    _output.keccak256Slice(_output.length - 2, 2) != keccak256(hex"88ac")) {
                    return hex"";
                }
                return _output.slice(12, 20);
            } else if (_tag == keccak256(hex"17a914")) {
                if (uint8(_output[_output.length - 1]) != 0x87) {
                    return hex"";
                }
                return _output.slice(11, 20);
            }
        }
        return hex"";  /* NB: will trigger on OPRETURN and any non-standard that doesn't overrun */
    }



    function validateVin(bytes memory _vin) internal pure returns (bool) {

        uint256 _varIntDataLen;
        uint256 _nIns;

        (_varIntDataLen, _nIns) = parseVarInt(_vin);

        if (_nIns == 0 || _varIntDataLen == ERR_BAD_ARG) {
            return false;
        }

        uint256 _offset = 1 + _varIntDataLen;

        for (uint256 i = 0; i < _nIns; i++) {
            if (_offset >= _vin.length) {
                return false;
            }

            bytes memory _next = _vin.slice(_offset, _vin.length - _offset);
            uint256 _nextLen = determineInputLength(_next);
            if (_nextLen == ERR_BAD_ARG) {
                return false;
            }

            _offset += _nextLen;
        }

        return _offset == _vin.length;
    }

    function validateVout(bytes memory _vout) internal pure returns (bool) {

        uint256 _varIntDataLen;
        uint256 _nOuts;

        (_varIntDataLen, _nOuts) = parseVarInt(_vout);

        if (_nOuts == 0 || _varIntDataLen == ERR_BAD_ARG) {
            return false;
        }

        uint256 _offset = 1 + _varIntDataLen;

        for (uint256 i = 0; i < _nOuts; i++) {
            if (_offset >= _vout.length) {
                return false;
            }

            bytes memory _next = _vout.slice(_offset, _vout.length - _offset);
            uint256 _nextLen = determineOutputLength(_next);
            if (_nextLen == ERR_BAD_ARG) {
                return false;
            }

            _offset += _nextLen;
        }

        return _offset == _vout.length;
    }




    function extractMerkleRootLE(bytes memory _header) internal pure returns (bytes memory) {

        return _header.slice(36, 32);
    }

    function extractTarget(bytes memory _header) internal pure returns (uint256) {

        bytes memory _m = _header.slice(72, 3);
        uint8 _e = uint8(_header[75]);
        uint256 _mantissa = bytesToUint(reverseEndianness(_m));
        uint _exponent = _e - 3;

        return _mantissa * (256 ** _exponent);
    }

    function calculateDifficulty(uint256 _target) internal pure returns (uint256) {

        return DIFF1_TARGET.div(_target);
    }

    function extractPrevBlockLE(bytes memory _header) internal pure returns (bytes memory) {

        return _header.slice(4, 32);
    }

    function extractTimestampLE(bytes memory _header) internal pure returns (bytes memory) {

        return _header.slice(68, 4);
    }

    function extractTimestamp(bytes memory _header) internal pure returns (uint32) {

        return uint32(bytesToUint(reverseEndianness(extractTimestampLE(_header))));
    }

    function extractDifficulty(bytes memory _header) internal pure returns (uint256) {

        return calculateDifficulty(extractTarget(_header));
    }

    function _hash256MerkleStep(bytes memory _a, bytes memory _b) internal pure returns (bytes32) {

        return hash256(abi.encodePacked(_a, _b));
    }

    function verifyHash256Merkle(bytes memory _proof, uint _index) internal pure returns (bool) {

        if (_proof.length % 32 != 0) {
            return false;
        }

        if (_proof.length == 32) {
            return true;
        }

        if (_proof.length == 64) {
            return false;
        }

        uint _idx = _index;
        bytes32 _root = _proof.slice(_proof.length - 32, 32).toBytes32();
        bytes32 _current = _proof.slice(0, 32).toBytes32();

        for (uint i = 1; i < (_proof.length.div(32)) - 1; i++) {
            if (_idx % 2 == 1) {
                _current = _hash256MerkleStep(_proof.slice(i * 32, 32), abi.encodePacked(_current));
            } else {
                _current = _hash256MerkleStep(abi.encodePacked(_current), _proof.slice(i * 32, 32));
            }
            _idx = _idx >> 1;
        }
        return _current == _root;
    }

    function retargetAlgorithm(
        uint256 _previousTarget,
        uint256 _firstTimestamp,
        uint256 _secondTimestamp
    ) internal pure returns (uint256) {

        uint256 _elapsedTime = _secondTimestamp.sub(_firstTimestamp);

        if (_elapsedTime < RETARGET_PERIOD.div(4)) {
            _elapsedTime = RETARGET_PERIOD.div(4);
        }
        if (_elapsedTime > RETARGET_PERIOD.mul(4)) {
            _elapsedTime = RETARGET_PERIOD.mul(4);
        }


        uint256 _adjusted = _previousTarget.div(65536).mul(_elapsedTime);
        return _adjusted.div(RETARGET_PERIOD).mul(65536);
    }
}pragma solidity ^0.5.10;




library ValidateSPV {


    using BTCUtils for bytes;
    using BTCUtils for uint256;
    using BytesLib for bytes;
    using SafeMath for uint256;

    enum InputTypes { NONE, LEGACY, COMPATIBILITY, WITNESS }
    enum OutputTypes { NONE, WPKH, WSH, OP_RETURN, PKH, SH, NONSTANDARD }

    uint256 constant ERR_BAD_LENGTH = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 constant ERR_INVALID_CHAIN = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe;
    uint256 constant ERR_LOW_WORK = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd;

    function getErrBadLength() internal pure returns (uint256) {

        return ERR_BAD_LENGTH;
    }

    function getErrInvalidChain() internal pure returns (uint256) {

        return ERR_INVALID_CHAIN;
    }

    function getErrLowWork() internal pure returns (uint256) {

        return ERR_LOW_WORK;
    }

    function prove(
        bytes32 _txid,
        bytes32 _merkleRoot,
        bytes memory _intermediateNodes,
        uint _index
    ) internal pure returns (bool) {

        if (_txid == _merkleRoot && _index == 0 && _intermediateNodes.length == 0) {
            return true;
        }

        bytes memory _proof = abi.encodePacked(_txid, _intermediateNodes, _merkleRoot);
        return _proof.verifyHash256Merkle(_index);
    }

    function calculateTxId(
        bytes memory _version,
        bytes memory _vin,
        bytes memory _vout,
        bytes memory _locktime
    ) internal pure returns (bytes32) {

        return abi.encodePacked(_version, _vin, _vout, _locktime).hash256();
    }

    function validateHeaderChain(bytes memory _headers) internal view returns (uint256 _totalDifficulty) {


        if (_headers.length % 80 != 0) {return ERR_BAD_LENGTH;}

        bytes32 _digest;

        _totalDifficulty = 0;

        for (uint256 _start = 0; _start < _headers.length; _start += 80) {

            bytes memory _header = _headers.slice(_start, 80);

            if (_start != 0) {
                if (!validateHeaderPrevHash(_header, _digest)) {return ERR_INVALID_CHAIN;}
            }

            uint256 _target = _header.extractTarget();

            _digest = _header.hash256View();
            if(uint256(_digest).reverseUint256() > _target) {
                return ERR_LOW_WORK;
            }

            _totalDifficulty = _totalDifficulty.add(_target.calculateDifficulty());
        }
    }

    function validateHeaderWork(bytes32 _digest, uint256 _target) internal pure returns (bool) {

        if (_digest == bytes32(0)) {return false;}
        return (abi.encodePacked(_digest).reverseEndianness().bytesToUint() < _target);
    }

    function validateHeaderPrevHash(bytes memory _header, bytes32 _prevHeaderDigest) internal pure returns (bool) {


        bytes32 _prevHash = _header.extractPrevBlockLE().toBytes32();

        if (_prevHash != _prevHeaderDigest) {return false;}

        return true;
    }
}