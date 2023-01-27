pragma solidity ^0.8.4;

library Buffer {

    struct buffer {
        bytes buf;
        uint capacity;
    }

    function init(buffer memory buf, uint capacity) internal pure returns(buffer memory) {

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

    function fromBytes(bytes memory b) internal pure returns(buffer memory) {

        buffer memory buf;
        buf.buf = b;
        buf.capacity = b.length;
        return buf;
    }

    function resize(buffer memory buf, uint capacity) private pure {

        bytes memory oldbuf = buf.buf;
        init(buf, capacity);
        append(buf, oldbuf);
    }

    function max(uint a, uint b) private pure returns(uint) {

        if (a > b) {
            return a;
        }
        return b;
    }

    function truncate(buffer memory buf) internal pure returns (buffer memory) {

        assembly {
            let bufptr := mload(buf)
            mstore(bufptr, 0)
        }
        return buf;
    }

    function write(buffer memory buf, uint off, bytes memory data, uint len) internal pure returns(buffer memory) {

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

        unchecked {
            uint mask = (256 ** (32 - len)) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask))
                let destpart := and(mload(dest), mask)
                mstore(dest, or(destpart, srcpart))
            }
        }

        return buf;
    }

    function append(buffer memory buf, bytes memory data, uint len) internal pure returns (buffer memory) {

        return write(buf, buf.buf.length, data, len);
    }

    function append(buffer memory buf, bytes memory data) internal pure returns (buffer memory) {

        return write(buf, buf.buf.length, data, data.length);
    }

    function writeUint8(buffer memory buf, uint off, uint8 data) internal pure returns(buffer memory) {

        if (off >= buf.capacity) {
            resize(buf, buf.capacity * 2);
        }

        assembly {
            let bufptr := mload(buf)
            let buflen := mload(bufptr)
            let dest := add(add(bufptr, off), 32)
            mstore8(dest, data)
            if eq(off, buflen) {
                mstore(bufptr, add(buflen, 1))
            }
        }
        return buf;
    }

    function appendUint8(buffer memory buf, uint8 data) internal pure returns(buffer memory) {

        return writeUint8(buf, buf.buf.length, data);
    }

    function write(buffer memory buf, uint off, bytes32 data, uint len) private pure returns(buffer memory) {

        if (len + off > buf.capacity) {
            resize(buf, (len + off) * 2);
        }

        unchecked {
            uint mask = (256 ** len) - 1;
            data = data >> (8 * (32 - len));
            assembly {
                let bufptr := mload(buf)
                let dest := add(add(bufptr, off), len)
                mstore(dest, or(and(mload(dest), not(mask)), data))
                if gt(add(off, len), mload(bufptr)) {
                    mstore(bufptr, add(off, len))
                }
            }
        }
        return buf;
    }

    function writeBytes20(buffer memory buf, uint off, bytes20 data) internal pure returns (buffer memory) {

        return write(buf, off, bytes32(data), 20);
    }

    function appendBytes20(buffer memory buf, bytes20 data) internal pure returns (buffer memory) {

        return write(buf, buf.buf.length, bytes32(data), 20);
    }

    function appendBytes32(buffer memory buf, bytes32 data) internal pure returns (buffer memory) {

        return write(buf, buf.buf.length, data, 32);
    }

    function writeInt(buffer memory buf, uint off, uint data, uint len) private pure returns(buffer memory) {

        if (len + off > buf.capacity) {
            resize(buf, (len + off) * 2);
        }

        uint mask = (256 ** len) - 1;
        assembly {
            let bufptr := mload(buf)
            let dest := add(add(bufptr, off), len)
            mstore(dest, or(and(mload(dest), not(mask)), data))
            if gt(add(off, len), mload(bufptr)) {
                mstore(bufptr, add(off, len))
            }
        }
        return buf;
    }

    function appendInt(buffer memory buf, uint data, uint len) internal pure returns(buffer memory) {

        return writeInt(buf, buf.buf.length, data, len);
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;

abstract contract DNSSEC {

    bytes public anchors;

    struct RRSetWithSignature {
        bytes rrset;
        bytes sig;
    }

    event AlgorithmUpdated(uint8 id, address addr);
    event DigestUpdated(uint8 id, address addr);
    event NSEC3DigestUpdated(uint8 id, address addr);
    event RRSetUpdated(bytes name, bytes rrset);

    function submitRRSets(RRSetWithSignature[] memory input, bytes calldata proof) public virtual returns (bytes memory);
    function submitRRSet(RRSetWithSignature calldata input, bytes calldata proof) public virtual returns (bytes memory);
    function deleteRRSet(uint16 deleteType, bytes calldata deleteName, RRSetWithSignature calldata nsec, bytes calldata proof) public virtual;
    function deleteRRSetNSEC3(uint16 deleteType, bytes memory deleteName, RRSetWithSignature memory closestEncloser, RRSetWithSignature memory nextClosest, bytes memory dnskey) public virtual;
    function rrdata(uint16 dnstype, bytes calldata name) external virtual view returns (uint32, uint32, bytes20);
}pragma solidity ^0.8.4;

library BytesUtils {

    function keccak(bytes memory self, uint offset, uint len) internal pure returns (bytes32 ret) {

        require(offset + len <= self.length);
        assembly {
            ret := keccak256(add(add(self, 32), offset), len)
        }
    }


    function compare(bytes memory self, bytes memory other) internal pure returns (int) {

        return compare(self, 0, self.length, other, 0, other.length);
    }

    function compare(bytes memory self, uint offset, uint len, bytes memory other, uint otheroffset, uint otherlen) internal pure returns (int) {

        uint shortest = len;
        if (otherlen < len)
        shortest = otherlen;

        uint selfptr;
        uint otherptr;

        assembly {
            selfptr := add(self, add(offset, 32))
            otherptr := add(other, add(otheroffset, 32))
        }
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                uint mask;
                if (shortest > 32) {
                    mask = type(uint256).max;
                } else {
                    mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                }
                int diff = int(a & mask) - int(b & mask);
                if (diff != 0)
                return diff;
            }
            selfptr += 32;
            otherptr += 32;
        }

        return int(len) - int(otherlen);
    }

    function equals(bytes memory self, uint offset, bytes memory other, uint otherOffset, uint len) internal pure returns (bool) {

        return keccak(self, offset, len) == keccak(other, otherOffset, len);
    }

    function equals(bytes memory self, uint offset, bytes memory other, uint otherOffset) internal pure returns (bool) {

        return keccak(self, offset, self.length - offset) == keccak(other, otherOffset, other.length - otherOffset);
    }

    function equals(bytes memory self, uint offset, bytes memory other) internal pure returns (bool) {

        return self.length >= offset + other.length && equals(self, offset, other, 0, other.length);
    }

    function equals(bytes memory self, bytes memory other) internal pure returns(bool) {

        return self.length == other.length && equals(self, 0, other, 0, self.length);
    }

    function readUint8(bytes memory self, uint idx) internal pure returns (uint8 ret) {

        return uint8(self[idx]);
    }

    function readUint16(bytes memory self, uint idx) internal pure returns (uint16 ret) {

        require(idx + 2 <= self.length);
        assembly {
            ret := and(mload(add(add(self, 2), idx)), 0xFFFF)
        }
    }

    function readUint32(bytes memory self, uint idx) internal pure returns (uint32 ret) {

        require(idx + 4 <= self.length);
        assembly {
            ret := and(mload(add(add(self, 4), idx)), 0xFFFFFFFF)
        }
    }

    function readBytes32(bytes memory self, uint idx) internal pure returns (bytes32 ret) {

        require(idx + 32 <= self.length);
        assembly {
            ret := mload(add(add(self, 32), idx))
        }
    }

    function readBytes20(bytes memory self, uint idx) internal pure returns (bytes20 ret) {

        require(idx + 20 <= self.length);
        assembly {
            ret := and(mload(add(add(self, 32), idx)), 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000)
        }
    }

    function readBytesN(bytes memory self, uint idx, uint len) internal pure returns (bytes32 ret) {

        require(len <= 32);
        require(idx + len <= self.length);
        assembly {
            let mask := not(sub(exp(256, sub(32, len)), 1))
            ret := and(mload(add(add(self, 32), idx)),  mask)
        }
    }

    function memcpy(uint dest, uint src, uint len) private pure {

        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        unchecked {
            uint mask = (256 ** (32 - len)) - 1;
            assembly {
                let srcpart := and(mload(src), not(mask))
                let destpart := and(mload(dest), mask)
                mstore(dest, or(destpart, srcpart))
            }
        }
    }

    function substring(bytes memory self, uint offset, uint len) internal pure returns(bytes memory) {

        require(offset + len <= self.length);

        bytes memory ret = new bytes(len);
        uint dest;
        uint src;

        assembly {
            dest := add(ret, 32)
            src := add(add(self, 32), offset)
        }
        memcpy(dest, src, len);

        return ret;
    }

    bytes constant base32HexTable = hex'00010203040506070809FFFFFFFFFFFFFF0A0B0C0D0E0F101112131415161718191A1B1C1D1E1FFFFFFFFFFFFFFFFFFFFF0A0B0C0D0E0F101112131415161718191A1B1C1D1E1F';

    function base32HexDecodeWord(bytes memory self, uint off, uint len) internal pure returns(bytes32) {

        require(len <= 52);

        uint ret = 0;
        uint8 decoded;
        for(uint i = 0; i < len; i++) {
            bytes1 char = self[off + i];
            require(char >= 0x30 && char <= 0x7A);
            decoded = uint8(base32HexTable[uint(uint8(char)) - 0x30]);
            require(decoded <= 0x20);
            if(i == len - 1) {
                break;
            }
            ret = (ret << 5) | decoded;
        }

        uint bitlen = len * 5;
        if(len % 8 == 0) {
            ret = (ret << 5) | decoded;
        } else if(len % 8 == 2) {
            ret = (ret << 3) | (decoded >> 2);
            bitlen -= 2;
        } else if(len % 8 == 4) {
            ret = (ret << 1) | (decoded >> 4);
            bitlen -= 4;
        } else if(len % 8 == 5) {
            ret = (ret << 4) | (decoded >> 1);
            bitlen -= 1;
        } else if(len % 8 == 7) {
            ret = (ret << 2) | (decoded >> 3);
            bitlen -= 3;
        } else {
            revert();
        }

        return bytes32(ret << (256 - bitlen));
    }
}pragma solidity ^0.8.4;


library RRUtils {

    using BytesUtils for *;
    using Buffer for *;

    function nameLength(bytes memory self, uint offset) internal pure returns(uint) {

        uint idx = offset;
        while (true) {
            assert(idx < self.length);
            uint labelLen = self.readUint8(idx);
            idx += labelLen + 1;
            if (labelLen == 0) {
                break;
            }
        }
        return idx - offset;
    }

    function readName(bytes memory self, uint offset) internal pure returns(bytes memory ret) {

        uint len = nameLength(self, offset);
        return self.substring(offset, len);
    }

    function labelCount(bytes memory self, uint offset) internal pure returns(uint) {

        uint count = 0;
        while (true) {
            assert(offset < self.length);
            uint labelLen = self.readUint8(offset);
            offset += labelLen + 1;
            if (labelLen == 0) {
                break;
            }
            count += 1;
        }
        return count;
    }

    uint constant RRSIG_TYPE = 0;
    uint constant RRSIG_ALGORITHM = 2;
    uint constant RRSIG_LABELS = 3;
    uint constant RRSIG_TTL = 4;
    uint constant RRSIG_EXPIRATION = 8;
    uint constant RRSIG_INCEPTION = 12;
    uint constant RRSIG_KEY_TAG = 16;
    uint constant RRSIG_SIGNER_NAME = 18;

    struct SignedSet {
        uint16 typeCovered;
        uint8 algorithm;
        uint8 labels;
        uint32 ttl;
        uint32 expiration;
        uint32 inception;
        uint16 keytag;
        bytes signerName;
        bytes data;
        bytes name;
    }

    function readSignedSet(bytes memory data) internal pure returns(SignedSet memory self) {

        self.typeCovered = data.readUint16(RRSIG_TYPE);
        self.algorithm = data.readUint8(RRSIG_ALGORITHM);
        self.labels = data.readUint8(RRSIG_LABELS);
        self.ttl = data.readUint32(RRSIG_TTL);
        self.expiration = data.readUint32(RRSIG_EXPIRATION);
        self.inception = data.readUint32(RRSIG_INCEPTION);
        self.keytag = data.readUint16(RRSIG_KEY_TAG);
        self.signerName = readName(data, RRSIG_SIGNER_NAME);
        self.data = data.substring(RRSIG_SIGNER_NAME + self.signerName.length, data.length - RRSIG_SIGNER_NAME - self.signerName.length);
    }

    function rrs(SignedSet memory rrset) internal pure returns(RRIterator memory) {

        return iterateRRs(rrset.data, 0);
    }

    struct RRIterator {
        bytes data;
        uint offset;
        uint16 dnstype;
        uint16 class;
        uint32 ttl;
        uint rdataOffset;
        uint nextOffset;
    }

    function iterateRRs(bytes memory self, uint offset) internal pure returns (RRIterator memory ret) {

        ret.data = self;
        ret.nextOffset = offset;
        next(ret);
    }

    function done(RRIterator memory iter) internal pure returns(bool) {

        return iter.offset >= iter.data.length;
    }

    function next(RRIterator memory iter) internal pure {

        iter.offset = iter.nextOffset;
        if (iter.offset >= iter.data.length) {
            return;
        }

        uint off = iter.offset + nameLength(iter.data, iter.offset);

        iter.dnstype = iter.data.readUint16(off);
        off += 2;
        iter.class = iter.data.readUint16(off);
        off += 2;
        iter.ttl = iter.data.readUint32(off);
        off += 4;

        uint rdataLength = iter.data.readUint16(off);
        off += 2;
        iter.rdataOffset = off;
        iter.nextOffset = off + rdataLength;
    }

    function name(RRIterator memory iter) internal pure returns(bytes memory) {

        return iter.data.substring(iter.offset, nameLength(iter.data, iter.offset));
    }

    function rdata(RRIterator memory iter) internal pure returns(bytes memory) {

        return iter.data.substring(iter.rdataOffset, iter.nextOffset - iter.rdataOffset);
    }

    uint constant DNSKEY_FLAGS = 0;
    uint constant DNSKEY_PROTOCOL = 2;
    uint constant DNSKEY_ALGORITHM = 3;
    uint constant DNSKEY_PUBKEY = 4;

    struct DNSKEY {
        uint16 flags;
        uint8 protocol;
        uint8 algorithm;
        bytes publicKey;
    }

    function readDNSKEY(bytes memory data, uint offset, uint length) internal pure returns(DNSKEY memory self) {

        self.flags = data.readUint16(offset + DNSKEY_FLAGS);
        self.protocol = data.readUint8(offset + DNSKEY_PROTOCOL);
        self.algorithm = data.readUint8(offset + DNSKEY_ALGORITHM);
        self.publicKey = data.substring(offset + DNSKEY_PUBKEY, length - DNSKEY_PUBKEY);
    } 

    uint constant DS_KEY_TAG = 0;
    uint constant DS_ALGORITHM = 2;
    uint constant DS_DIGEST_TYPE = 3;
    uint constant DS_DIGEST = 4;

    struct DS {
        uint16 keytag;
        uint8 algorithm;
        uint8 digestType;
        bytes digest;
    }

    function readDS(bytes memory data, uint offset, uint length) internal pure returns(DS memory self) {

        self.keytag = data.readUint16(offset + DS_KEY_TAG);
        self.algorithm = data.readUint8(offset + DS_ALGORITHM);
        self.digestType = data.readUint8(offset + DS_DIGEST_TYPE);
        self.digest = data.substring(offset + DS_DIGEST, length - DS_DIGEST);
    }

    struct NSEC3 {
        uint8 hashAlgorithm;
        uint8 flags;
        uint16 iterations;
        bytes salt;
        bytes32 nextHashedOwnerName;
        bytes typeBitmap;
    }

    uint constant NSEC3_HASH_ALGORITHM = 0;
    uint constant NSEC3_FLAGS = 1;
    uint constant NSEC3_ITERATIONS = 2;
    uint constant NSEC3_SALT_LENGTH = 4;
    uint constant NSEC3_SALT = 5;

    function readNSEC3(bytes memory data, uint offset, uint length) internal pure returns(NSEC3 memory self) {

        uint end = offset + length;
        self.hashAlgorithm = data.readUint8(offset + NSEC3_HASH_ALGORITHM);
        self.flags = data.readUint8(offset + NSEC3_FLAGS);
        self.iterations = data.readUint16(offset + NSEC3_ITERATIONS);
        uint8 saltLength = data.readUint8(offset + NSEC3_SALT_LENGTH);
        offset = offset + NSEC3_SALT;
        self.salt = data.substring(offset, saltLength);
        offset += saltLength;
        uint8 nextLength = data.readUint8(offset);
        require(nextLength <= 32);
        offset += 1;
        self.nextHashedOwnerName = data.readBytesN(offset, nextLength);
        offset += nextLength;
        self.typeBitmap = data.substring(offset, end - offset);
    }

    function checkTypeBitmap(NSEC3 memory self, uint16 rrtype) internal pure returns(bool) {

        return checkTypeBitmap(self.typeBitmap, 0, rrtype);
    }

    function checkTypeBitmap(bytes memory bitmap, uint offset, uint16 rrtype) internal pure returns (bool) {

        uint8 typeWindow = uint8(rrtype >> 8);
        uint8 windowByte = uint8((rrtype & 0xff) / 8);
        uint8 windowBitmask = uint8(uint8(1) << (uint8(7) - uint8(rrtype & 0x7)));
        for (uint off = offset; off < bitmap.length;) {
            uint8 window = bitmap.readUint8(off);
            uint8 len = bitmap.readUint8(off + 1);
            if (typeWindow < window) {
                return false;
            } else if (typeWindow == window) {
                if (len <= windowByte) {
                    return false;
                }
                return (bitmap.readUint8(off + windowByte + 2) & windowBitmask) != 0;
            } else {
                off += len + 2;
            }
        }

        return false;
    }

    function compareNames(bytes memory self, bytes memory other) internal pure returns (int) {

        if (self.equals(other)) {
            return 0;
        }

        uint off;
        uint otheroff;
        uint prevoff;
        uint otherprevoff;
        uint counts = labelCount(self, 0);
        uint othercounts = labelCount(other, 0);

        while (counts > othercounts) {
            prevoff = off;
            off = progress(self, off);
            counts--;
        }

        while (othercounts > counts) {
            otherprevoff = otheroff;
            otheroff = progress(other, otheroff);
            othercounts--;
        }

        while (counts > 0 && !self.equals(off, other, otheroff)) {
            prevoff = off;
            off = progress(self, off);
            otherprevoff = otheroff;
            otheroff = progress(other, otheroff);
            counts -= 1;
        }

        if (off == 0) {
            return -1;
        }
        if(otheroff == 0) {
            return 1;
        }

        return self.compare(prevoff + 1, self.readUint8(prevoff), other, otherprevoff + 1, other.readUint8(otherprevoff));
    }

    function serialNumberGte(uint32 i1, uint32 i2) internal pure returns(bool) {

        return int32(i1) - int32(i2) >= 0;
    }

    function progress(bytes memory body, uint off) internal pure returns(uint) {

        return off + 1 + body.readUint8(off);
    }
}pragma solidity ^0.8.4;


library DNSClaimChecker {


    using BytesUtils for bytes;
    using RRUtils for *;
    using Buffer for Buffer.buffer;

    uint16 constant CLASS_INET = 1;
    uint16 constant TYPE_TXT = 16;

    function getOwnerAddress(DNSSEC oracle, bytes memory name, bytes memory proof)
        internal
        view
        returns (address, bool)
    {

        Buffer.buffer memory buf;
        buf.init(name.length + 5);
        buf.append("\x04_ens");
        buf.append(name);
        bytes20 hash;
        uint32 expiration;
        (, expiration, hash) = oracle.rrdata(TYPE_TXT, buf.buf);
        if (hash == bytes20(0) && proof.length == 0) return (address(0x0), false);

        require(hash == bytes20(keccak256(proof)));

        for (RRUtils.RRIterator memory iter = proof.iterateRRs(0); !iter.done(); iter.next()) {
            require(RRUtils.serialNumberGte(expiration + iter.ttl, uint32(block.timestamp)), "DNS record is stale; refresh or delete it before proceeding.");

            bool found;
            address addr;
            (addr, found) = parseRR(proof, iter.rdataOffset);
            if (found) {
                return (addr, true);
            }
        }

        return (address(0x0), false);
    }

    function parseRR(bytes memory rdata, uint idx) internal pure returns (address, bool) {

        while (idx < rdata.length) {
            uint len = rdata.readUint8(idx); idx += 1;

            bool found;
            address addr;
            (addr, found) = parseString(rdata, idx, len);

            if (found) return (addr, true);
            idx += len;
        }

        return (address(0x0), false);
    }

    function parseString(bytes memory str, uint idx, uint len) internal pure returns (address, bool) {

        if (str.readUint32(idx) != 0x613d3078) return (address(0x0), false); // 0x613d3078 == 'a=0x'
        if (len < 44) return (address(0x0), false);
        return hexToAddress(str, idx + 4);
    }

    function hexToAddress(bytes memory str, uint idx) internal pure returns (address, bool) {

        if (str.length - idx < 40) return (address(0x0), false);
        uint ret = 0;
        for (uint i = idx; i < idx + 40; i++) {
            ret <<= 4;
            uint x = str.readUint8(i);
            if (x >= 48 && x < 58) {
                ret |= x - 48;
            } else if (x >= 65 && x < 71) {
                ret |= x - 55;
            } else if (x >= 97 && x < 103) {
                ret |= x - 87;
            } else {
                return (address(0x0), false);
            }
        }
        return (address(uint160(ret)), true);
    }
}pragma solidity >=0.8.4;

interface ENS {


    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external virtual;

    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external virtual;

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external virtual returns(bytes32);

    function setResolver(bytes32 node, address resolver) external virtual;

    function setOwner(bytes32 node, address owner) external virtual;

    function setTTL(bytes32 node, uint64 ttl) external virtual;

    function setApprovalForAll(address operator, bool approved) external virtual;

    function owner(bytes32 node) external virtual view returns (address);

    function resolver(bytes32 node) external virtual view returns (address);

    function ttl(bytes32 node) external virtual view returns (uint64);

    function recordExists(bytes32 node) external virtual view returns (bool);

    function isApprovedForAll(address owner, address operator) external virtual view returns (bool);

}pragma solidity >=0.8.4;


contract ENSRegistry is ENS {


    struct Record {
        address owner;
        address resolver;
        uint64 ttl;
    }

    mapping (bytes32 => Record) records;
    mapping (address => mapping(address => bool)) operators;

    modifier authorised(bytes32 node) {

        address owner = records[node].owner;
        require(owner == msg.sender || operators[owner][msg.sender]);
        _;
    }

    constructor() public {
        records[0x0].owner = msg.sender;
    }

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external virtual override {

        setOwner(node, owner);
        _setResolverAndTTL(node, resolver, ttl);
    }

    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external virtual override {

        bytes32 subnode = setSubnodeOwner(node, label, owner);
        _setResolverAndTTL(subnode, resolver, ttl);
    }

    function setOwner(bytes32 node, address owner) public virtual override authorised(node) {

        _setOwner(node, owner);
        emit Transfer(node, owner);
    }

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) public virtual override authorised(node) returns(bytes32) {

        bytes32 subnode = keccak256(abi.encodePacked(node, label));
        _setOwner(subnode, owner);
        emit NewOwner(node, label, owner);
        return subnode;
    }

    function setResolver(bytes32 node, address resolver) public virtual override authorised(node) {

        emit NewResolver(node, resolver);
        records[node].resolver = resolver;
    }

    function setTTL(bytes32 node, uint64 ttl) public virtual override authorised(node) {

        emit NewTTL(node, ttl);
        records[node].ttl = ttl;
    }

    function setApprovalForAll(address operator, bool approved) external virtual override {

        operators[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function owner(bytes32 node) public virtual override view returns (address) {

        address addr = records[node].owner;
        if (addr == address(this)) {
            return address(0x0);
        }

        return addr;
    }

    function resolver(bytes32 node) public virtual override view returns (address) {

        return records[node].resolver;
    }

    function ttl(bytes32 node) public virtual override view returns (uint64) {

        return records[node].ttl;
    }

    function recordExists(bytes32 node) public virtual override view returns (bool) {

        return records[node].owner != address(0x0);
    }

    function isApprovedForAll(address owner, address operator) external virtual override view returns (bool) {

        return operators[owner][operator];
    }

    function _setOwner(bytes32 node, address owner) internal virtual {

        records[node].owner = owner;
    }

    function _setResolverAndTTL(bytes32 node, address resolver, uint64 ttl) internal {

        if(resolver != records[node].resolver) {
            records[node].resolver = resolver;
            emit NewResolver(node, resolver);
        }

        if(ttl != records[node].ttl) {
            records[node].ttl = ttl;
            emit NewTTL(node, ttl);
        }
    }
}pragma solidity ^0.8.4;


contract Controllable is Ownable {

    mapping(address => bool) public controllers;

    event ControllerChanged(address indexed controller, bool enabled);

    modifier onlyController {

        require(
            controllers[msg.sender],
            "Controllable: Caller is not a controller"
        );
        _;
    }

    function setController(address controller, bool enabled) public onlyOwner {

        controllers[controller] = enabled;
        emit ControllerChanged(controller, enabled);
    }
}pragma solidity ^0.8.4;


contract Root is Ownable, Controllable {

    bytes32 private constant ROOT_NODE = bytes32(0);

    bytes4 private constant INTERFACE_META_ID =
        bytes4(keccak256("supportsInterface(bytes4)"));

    event TLDLocked(bytes32 indexed label);

    ENS public ens;
    mapping(bytes32 => bool) public locked;

    constructor(ENS _ens) public {
        ens = _ens;
    }

    function setSubnodeOwner(bytes32 label, address owner)
        external
        onlyController
    {

        require(!locked[label]);
        ens.setSubnodeOwner(ROOT_NODE, label, owner);
    }

    function setResolver(address resolver) external onlyOwner {

        ens.setResolver(ROOT_NODE, resolver);
    }

    function lock(bytes32 label) external onlyOwner {

        emit TLDLocked(label);
        locked[label] = true;
    }

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        returns (bool)
    {

        return interfaceID == INTERFACE_META_ID;
    }
}pragma solidity ^0.8.4;

interface PublicSuffixList {

    function isPublicSuffix(bytes calldata name) external view returns(bool);

}pragma solidity >=0.8.4;
abstract contract ResolverBase {
    bytes4 private constant INTERFACE_META_ID = 0x01ffc9a7;

    function supportsInterface(bytes4 interfaceID) virtual public pure returns(bool) {
        return interfaceID == INTERFACE_META_ID;
    }

    function isAuthorised(bytes32 node) internal virtual view returns(bool);

    modifier authorised(bytes32 node) {
        require(isAuthorised(node));
        _;
    }
}pragma solidity >=0.8.4;

abstract contract AddrResolver is ResolverBase {
    bytes4 constant private ADDR_INTERFACE_ID = 0x3b3b57de;
    bytes4 constant private ADDRESS_INTERFACE_ID = 0xf1cb7e06;
    uint constant private COIN_TYPE_ETH = 60;

    event AddrChanged(bytes32 indexed node, address a);
    event AddressChanged(bytes32 indexed node, uint coinType, bytes newAddress);

    mapping(bytes32=>mapping(uint=>bytes)) _addresses;

    function setAddr(bytes32 node, address a) external authorised(node) {
        setAddr(node, COIN_TYPE_ETH, addressToBytes(a));
    }

    function addr(bytes32 node) public view returns (address payable) {
        bytes memory a = addr(node, COIN_TYPE_ETH);
        if(a.length == 0) {
            return payable(0);
        }
        return bytesToAddress(a);
    }

    function setAddr(bytes32 node, uint coinType, bytes memory a) public authorised(node) {
        emit AddressChanged(node, coinType, a);
        if(coinType == COIN_TYPE_ETH) {
            emit AddrChanged(node, bytesToAddress(a));
        }
        _addresses[node][coinType] = a;
    }

    function addr(bytes32 node, uint coinType) public view returns(bytes memory) {
        return _addresses[node][coinType];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == ADDR_INTERFACE_ID || interfaceID == ADDRESS_INTERFACE_ID || super.supportsInterface(interfaceID);
    }

    function bytesToAddress(bytes memory b) internal pure returns(address payable a) {
        require(b.length == 20);
        assembly {
            a := div(mload(add(b, 32)), exp(256, 12))
        }
    }

    function addressToBytes(address a) internal pure returns(bytes memory b) {
        b = new bytes(20);
        assembly {
            mstore(add(b, 32), mul(a, exp(256, 12)))
        }
    }
}pragma solidity ^0.8.4;


interface IDNSRegistrar {

    function claim(bytes memory name, bytes memory proof) external;

    function proveAndClaim(bytes memory name, DNSSEC.RRSetWithSignature[] memory input, bytes memory proof) external;

    function proveAndClaimWithResolver(bytes memory name, DNSSEC.RRSetWithSignature[] memory input, bytes memory proof, address resolver, address addr) external;

}

contract DNSRegistrar is IDNSRegistrar {

    using BytesUtils for bytes;

    DNSSEC public oracle;
    ENS public ens;
    PublicSuffixList public suffixes;

    bytes4 constant private INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));

    event Claim(bytes32 indexed node, address indexed owner, bytes dnsname);
    event NewOracle(address oracle);
    event NewPublicSuffixList(address suffixes);

    constructor(DNSSEC _dnssec, PublicSuffixList _suffixes, ENS _ens) {
        oracle = _dnssec;
        emit NewOracle(address(oracle));
        suffixes = _suffixes;
        emit NewPublicSuffixList(address(suffixes));
        ens = _ens;
    }

    modifier onlyOwner {

        Root root = Root(ens.owner(bytes32(0)));
        address owner = root.owner();
        require(msg.sender == owner);
        _;
    }

    function setOracle(DNSSEC _dnssec) public onlyOwner {

        oracle = _dnssec;
        emit NewOracle(address(oracle));
    }

    function setPublicSuffixList(PublicSuffixList _suffixes) public onlyOwner {

        suffixes = _suffixes;
        emit NewPublicSuffixList(address(suffixes));
    }

    function claim(bytes memory name, bytes memory proof) public override {

        (bytes32 rootNode, bytes32 labelHash, address addr) = _claim(name, proof);
        ens.setSubnodeOwner(rootNode, labelHash, addr);
    }

    function proveAndClaim(bytes memory name, DNSSEC.RRSetWithSignature[] memory input, bytes memory proof) public override {

        proof = oracle.submitRRSets(input, proof);
        claim(name, proof);
    }

    function proveAndClaimWithResolver(bytes memory name, DNSSEC.RRSetWithSignature[] memory input, bytes memory proof, address resolver, address addr) public override {

        proof = oracle.submitRRSets(input, proof);
        (bytes32 rootNode, bytes32 labelHash, address owner) = _claim(name, proof);
        require(msg.sender == owner, "Only owner can call proveAndClaimWithResolver");
        if(addr != address(0)) {
            require(resolver != address(0), "Cannot set addr if resolver is not set");
            ens.setSubnodeRecord(rootNode, labelHash, address(this), resolver, 0);
            bytes32 node = keccak256(abi.encodePacked(rootNode, labelHash));
            AddrResolver(resolver).setAddr(node, addr);
            ens.setOwner(node, owner);
        } else {
            ens.setSubnodeRecord(rootNode, labelHash, owner, resolver, 0);
        }
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {

        return interfaceID == INTERFACE_META_ID ||
               interfaceID == type(IDNSRegistrar).interfaceId;
    }

    function _claim(bytes memory name, bytes memory proof) internal returns(bytes32 rootNode, bytes32 labelHash, address addr) {

        uint labelLen = name.readUint8(0);
        labelHash = name.keccak(1, labelLen);

        bytes memory parentName = name.substring(labelLen + 1, name.length - labelLen - 1);
        require(suffixes.isPublicSuffix(parentName), "Parent name must be a public suffix");

        rootNode = enableNode(parentName, 0);

        (addr,) = DNSClaimChecker.getOwnerAddress(oracle, name, proof);

        emit Claim(keccak256(abi.encodePacked(rootNode, labelHash)), addr, name);
    }

    function enableNode(bytes memory domain, uint offset) internal returns(bytes32 node) {

        uint len = domain.readUint8(offset);
        if(len == 0) {
            return bytes32(0);
        }

        bytes32 parentNode = enableNode(domain, offset + len + 1);
        bytes32 label = domain.keccak(offset + 1, len);
        node = keccak256(abi.encodePacked(parentNode, label));
        address owner = ens.owner(node);
        require(owner == address(0) || owner == address(this), "Cannot enable a name owned by someone else");
        if(owner != address(this)) {
            if(parentNode == bytes32(0)) {
                Root root = Root(ens.owner(bytes32(0)));
                root.setSubnodeOwner(label, address(this));
            } else {
                ens.setSubnodeOwner(parentNode, label, address(this));
            }
        }
        return node;
    }
}