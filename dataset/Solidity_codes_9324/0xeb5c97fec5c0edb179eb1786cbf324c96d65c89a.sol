
pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}/*
 * Blake2b library in Solidity using EIP-152
 *
 * Copyright (C) 2019 Alex Beregszaszi
 *
 * License: Apache 2.0
 */


pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

library Blake2b {

    struct Instance {
        bytes state;
        uint out_len;
        uint input_counter;
    }

    function init(bytes memory key, uint out_len)
        internal
        view
        returns (Instance memory instance)
    {


        reset(instance, key, out_len);
    }

    function reset(Instance memory instance, bytes memory key, uint out_len)
        internal
        view
    {

        instance.out_len = out_len;
        instance.input_counter = 0;

        instance.state = hex"0000000c08c9bdf267e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e1319cde05b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        bytes memory state = instance.state;

        uint key_len = key.length;
        assembly {
            let ptr := add(state, 36)
            let tmp := mload(ptr)
            let p0 := or(shl(240, key_len), shl(248, out_len))
            tmp := xor(tmp, p0)
            mstore(ptr, tmp)
        }


        if (key_len > 0) {
            require(key_len == 64);
            assert(key.length == 128);
            update(instance, key, key_len);
        }
    }

    function call_function_f(Instance memory instance)
        private
        view
    {

        bytes memory state = instance.state;
        assembly {
            let state_ptr := add(state, 32)
            if iszero(staticcall(not(0), 0x09, state_ptr, 0xd5, add(state_ptr, 4), 0x40)) {
                revert(0, 0)
            }
        }
    }

    function update_loop(Instance memory instance, bytes memory data, uint data_len, bool last_block)
        private
        view
    {

        bytes memory state = instance.state;
        uint input_counter = instance.input_counter;

        uint state_ptr;
        assembly {
            state_ptr := add(state, 100)
        }

        uint data_ptr;
        assembly {
            data_ptr := add(data, 32)
        }

        uint len = data.length;
        while (len > 0) {
            if (len >= 128) {
                assembly {
                    mstore(state_ptr, mload(data_ptr))
                    data_ptr := add(data_ptr, 32)

                    mstore(add(state_ptr, 32), mload(data_ptr))
                    data_ptr := add(data_ptr, 32)

                    mstore(add(state_ptr, 64), mload(data_ptr))
                    data_ptr := add(data_ptr, 32)

                    mstore(add(state_ptr, 96), mload(data_ptr))
                    data_ptr := add(data_ptr, 32)
                }

                len -= 128;
                if (data_len < 128) {
                    input_counter += data_len;
                } else {
                    data_len -= 128;
                    input_counter += 128;
                }
            } else {
                revert();
            }

            assembly {
                mstore8(add(state, 228), and(input_counter, 0xff))
                mstore8(add(state, 229), and(shr(8, input_counter), 0xff))
                mstore8(add(state, 230), and(shr(16, input_counter), 0xff))
            }

            if (len == 0) {
                assembly {
                    mstore8(add(state, 244), last_block)
                }
            }

            call_function_f(instance);
        }

        instance.input_counter = input_counter;
    }

    function update(Instance memory instance, bytes memory data, uint data_len)
        internal
        view
    {

        require((data.length % 128) == 0);
        update_loop(instance, data, data_len, false);
    }

    function finalize(Instance memory instance, bytes memory data)
        internal
        view
        returns (bytes memory output)
    {

        uint input_length = data.length;
        if (input_length == 0 || (input_length % 128) != 0) {
            data = concat(data, new bytes(128 - (input_length % 128)));
        }
        assert((data.length % 128) == 0);
        update_loop(instance, data, input_length, true);


        bytes memory state = instance.state;
        output = new bytes(instance.out_len);
        if(instance.out_len == 32) {
            assembly {
                mstore(add(output, 32), mload(add(state, 36)))
            }
        } else {
            assembly {
                mstore(add(output, 32), mload(add(state, 36)))
                mstore(add(output, 64), mload(add(state, 68)))
            }
        }
    }

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

}// MIT

pragma solidity >=0.6.0 <0.7.0;

contract Context {

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.7.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function ownableConstructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.7.0;


contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function pausableConstructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity >=0.6.0 <0.7.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}// MIT

pragma solidity >=0.6.0 <0.7.0;


library Hash {


    using Blake2b for Blake2b.Instance;


    function blake2bHash(bytes memory src) internal view returns (bytes32 des) {

        Blake2b.Instance memory instance = Blake2b.init(hex"", 32);
        return abi.decode(instance.finalize(src), (bytes32));
    }
}// MIT

pragma solidity >=0.6.0 <0.7.0;

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
}// MIT

pragma solidity >=0.6.0 <0.7.0;

library Memory {


    uint internal constant WORD_SIZE = 32;

    function equals(uint addr, uint addr2, uint len) internal pure returns (bool equal) {

        assembly {
            equal := eq(keccak256(addr, len), keccak256(addr2, len))
        }
    }


    function equals(uint addr, uint len, bytes memory bts) internal pure returns (bool equal) {

        require(bts.length >= len);
        uint addr2;
        assembly {
            addr2 := add(bts, /*BYTES_HEADER_SIZE*/32)
        }
        return equals(addr, addr2, len);
    }
	function dataPtr(bytes memory bts) internal pure returns (uint addr) {

		assembly {
			addr := add(bts, /*BYTES_HEADER_SIZE*/32)
		}
	}

	function toBytes(uint addr, uint len) internal pure returns (bytes memory bts) {

		bts = new bytes(len);
		uint btsptr;
		assembly {
			btsptr := add(bts, /*BYTES_HEADER_SIZE*/32)
		}
		copy(addr, btsptr, len);
	}
	
	function toBytes(bytes32 self) internal pure returns (bytes memory bts) {

		bts = new bytes(32);
		assembly {
			mstore(add(bts, /*BYTES_HEADER_SIZE*/32), self)
		}
	}

	function copy(uint src, uint dest, uint len) internal pure {

		for (; len >= WORD_SIZE; len -= WORD_SIZE) {
			assembly {
				mstore(dest, mload(src))
			}
			dest += WORD_SIZE;
			src += WORD_SIZE;
		}

		uint mask = 256 ** (WORD_SIZE - len) - 1;
		assembly {
			let srcpart := and(mload(src), not(mask))
			let destpart := and(mload(dest), mask)
			mstore(dest, or(destpart, srcpart))
		}
	}

	function fromBytes(bytes memory bts) internal pure returns (uint addr, uint len) {

		len = bts.length;
		assembly {
			addr := add(bts, /*BYTES_HEADER_SIZE*/32)
		}
	}
}// MIT

pragma solidity >=0.6.0 <0.7.0;


library Bytes {

    uint256 internal constant BYTES_HEADER_SIZE = 32;

    function equals(bytes memory self, bytes memory other) internal pure returns (bool equal) {

        if (self.length != other.length) {
            return false;
        }
        uint addr;
        uint addr2;
        assembly {
            addr := add(self, /*BYTES_HEADER_SIZE*/32)
            addr2 := add(other, /*BYTES_HEADER_SIZE*/32)
        }
        equal = Memory.equals(addr, addr2, self.length);
    }

    function substr(bytes memory self, uint256 startIndex)
        internal
        pure
        returns (bytes memory)
    {

        require(startIndex <= self.length);
        uint256 len = self.length - startIndex;
        uint256 addr = Memory.dataPtr(self);
        return Memory.toBytes(addr + startIndex, len);
    }

    function substr(
        bytes memory self,
        uint256 startIndex,
        uint256 len
    ) internal pure returns (bytes memory) {

        require(startIndex + len <= self.length);
        if (len == 0) {
            return "";
        }
        uint256 addr = Memory.dataPtr(self);
        return Memory.toBytes(addr + startIndex, len);
    }

    function concat(bytes memory self, bytes memory other)
        internal
        pure
        returns (bytes memory)
    {

        bytes memory ret = new bytes(self.length + other.length);
        uint256 src;
        uint256 srcLen;
        (src, srcLen) = Memory.fromBytes(self);
        uint256 src2;
        uint256 src2Len;
        (src2, src2Len) = Memory.fromBytes(other);
        uint256 dest;
        (dest, ) = Memory.fromBytes(ret);
        uint256 dest2 = dest + srcLen;
        Memory.copy(src, dest, srcLen);
        Memory.copy(src2, dest2, src2Len);
        return ret;
    }

    function toBytes32(bytes memory self)
        internal
        pure
        returns (bytes32 out)
    {

        require(self.length >= 32, "Bytes:: toBytes32: data is to short.");
        assembly {
            out := mload(add(self, 32))
        }
    }

    function toBytes16(bytes memory self, uint256 offset)
        internal
        pure
        returns (bytes16 out)
    {

        for (uint i = 0; i < 16; i++) {
            out |= bytes16(byte(self[offset + i]) & 0xFF) >> (i * 8);
        }
    }

    function toBytes4(bytes memory self, uint256 offset)
        internal
        pure
        returns (bytes4)
    {

        bytes4 out;

        for (uint256 i = 0; i < 4; i++) {
            out |= bytes4(self[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function toBytes2(bytes memory self, uint256 offset)
        internal
        pure
        returns (bytes2)
    {

        bytes2 out;

        for (uint256 i = 0; i < 2; i++) {
            out |= bytes2(self[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }
}// MIT

pragma solidity >=0.6.0 <0.7.0;


library Input {

    using Bytes for bytes;

    struct Data {
        uint256 offset;
        bytes raw;
    }

    function from(bytes memory data) internal pure returns (Data memory) {

        return Data({offset: 0, raw: data});
    }

    modifier shift(Data memory data, uint256 size) {

        require(data.raw.length >= data.offset + size, "Input: Out of range");
        _;
        data.offset += size;
    }

    function shiftBytes(Data memory data, uint256 size) internal pure {

        require(data.raw.length >= data.offset + size, "Input: Out of range");
        data.offset += size;
    }

    function finished(Data memory data) internal pure returns (bool) {

        return data.offset == data.raw.length;
    }

    function peekU8(Data memory data) internal pure returns (uint8 v) {

        return uint8(data.raw[data.offset]);
    }

    function decodeU8(Data memory data)
        internal
        pure
        shift(data, 1)
        returns (uint8 value)
    {

        value = uint8(data.raw[data.offset]);
    }

    function decodeU16(Data memory data) internal pure returns (uint16 value) {

        value = uint16(decodeU8(data));
        value |= (uint16(decodeU8(data)) << 8);
    }

    function decodeU32(Data memory data) internal pure returns (uint32 value) {

        value = uint32(decodeU16(data));
        value |= (uint32(decodeU16(data)) << 16);
    }

    function decodeBytesN(Data memory data, uint256 N)
        internal
        pure
        shift(data, N)
        returns (bytes memory value)
    {

        value = data.raw.substr(data.offset, N);
    }

    function decodeBytes4(Data memory data) internal pure shift(data, 4) returns(bytes4 value) {

        bytes memory raw = data.raw;
        uint256 offset = data.offset;

        assembly {
            value := mload(add(add(raw, 32), offset))
        }
    }

    function decodeBytes32(Data memory data) internal pure shift(data, 32) returns(bytes32 value) {

        bytes memory raw = data.raw;
        uint256 offset = data.offset;

        assembly {
            value := mload(add(add(raw, 32), offset))
        }
    }
}