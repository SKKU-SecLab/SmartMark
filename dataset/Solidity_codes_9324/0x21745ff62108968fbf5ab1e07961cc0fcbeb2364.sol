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

contract Owned {

    address public owner;
    
    modifier owner_only() {

        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setOwner(address newOwner) public owner_only {

        owner = newOwner;
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

    function computeKeytag(bytes memory data) internal pure returns (uint16) {

        unchecked {
            require(data.length <= 8192, "Long keys not permitted");
            uint ac1;
            uint ac2;
            for(uint i = 0; i < data.length + 31; i += 32) {
                uint word;
                assembly {
                    word := mload(add(add(data, 32), i))
                }
                if(i + 32 > data.length) {
                    uint unused = 256 - (data.length - i) * 8;
                    word = (word >> unused) << unused;
                }
                ac1 += (word & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00) >> 8;
                ac2 += (word & 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF);
            }
            ac1 = (ac1 & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF)
                + ((ac1 & 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000) >> 16);
            ac2 = (ac2 & 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF)
                + ((ac2 & 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000) >> 16);
            ac1 = (ac1 << 8) + ac2;
            ac1 = (ac1 & 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF)
                + ((ac1 & 0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000) >> 32);
            ac1 = (ac1 & 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF)
                + ((ac1 & 0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000) >> 64);
            ac1 = (ac1 & 0x00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
                + (ac1 >> 128);
            ac1 += (ac1 >> 16) & 0xFFFF;
            return uint16(ac1);
        }
    }
}pragma solidity ^0.8.4;

interface Algorithm {

    function verify(bytes calldata key, bytes calldata data, bytes calldata signature) external virtual view returns (bool);

}pragma solidity ^0.8.4;

interface Digest {

    function verify(bytes calldata data, bytes calldata hash) external virtual pure returns (bool);

}pragma solidity ^0.8.4;

interface NSEC3Digest {

     function hash(bytes calldata salt, bytes calldata data, uint iterations) external virtual pure returns (bytes32);

}pragma solidity ^0.8.4;


contract DNSSECImpl is DNSSEC, Owned {

    using Buffer for Buffer.buffer;
    using BytesUtils for bytes;
    using RRUtils for *;

    uint16 constant DNSCLASS_IN = 1;

    uint16 constant DNSTYPE_NS = 2;
    uint16 constant DNSTYPE_SOA = 6;
    uint16 constant DNSTYPE_DNAME = 39;
    uint16 constant DNSTYPE_DS = 43;
    uint16 constant DNSTYPE_RRSIG = 46;
    uint16 constant DNSTYPE_NSEC = 47;
    uint16 constant DNSTYPE_DNSKEY = 48;
    uint16 constant DNSTYPE_NSEC3 = 50;

    uint constant DNSKEY_FLAG_ZONEKEY = 0x100;

    uint8 constant ALGORITHM_RSASHA256 = 8;

    uint8 constant DIGEST_ALGORITHM_SHA256 = 2;

    struct RRSet {
        uint32 inception;
        uint32 expiration;
        bytes20 hash;
    }

    mapping (bytes32 => mapping(uint16 => RRSet)) rrsets;

    mapping (uint8 => Algorithm) public algorithms;
    mapping (uint8 => Digest) public digests;
    mapping (uint8 => NSEC3Digest) public nsec3Digests;

    event Test(uint t);
    event Marker();

    constructor(bytes memory _anchors) {
        anchors = _anchors;
        rrsets[keccak256(hex"00")][DNSTYPE_DS] = RRSet({
            inception: uint32(0),
            expiration: uint32(3767581600), // May 22 2089 - the latest date we can encode as of writing this
            hash: bytes20(keccak256(anchors))
        });
        emit RRSetUpdated(hex"00", anchors);
    }

    function setAlgorithm(uint8 id, Algorithm algo) public owner_only {

        algorithms[id] = algo;
        emit AlgorithmUpdated(id, address(algo));
    }

    function setDigest(uint8 id, Digest digest) public owner_only {

        digests[id] = digest;
        emit DigestUpdated(id, address(digest));
    }

    function setNSEC3Digest(uint8 id, NSEC3Digest digest) public owner_only {

        nsec3Digests[id] = digest;
        emit NSEC3DigestUpdated(id, address(digest));
    }

    function submitRRSets(RRSetWithSignature[] memory input, bytes calldata _proof) public override returns (bytes memory) {

        bytes memory proof = _proof;
        for(uint i = 0; i < input.length; i++) {
            proof = _submitRRSet(input[i], proof);
        }
        return proof;
    }

    function submitRRSet(RRSetWithSignature memory input, bytes memory proof)
        public override
        returns (bytes memory)
    {

        return _submitRRSet(input, proof);
    }

    function deleteRRSet(uint16 deleteType, bytes memory deleteName, RRSetWithSignature memory nsec, bytes memory proof)
        public override
    {

        RRUtils.SignedSet memory rrset;
        rrset = validateSignedSet(nsec, proof);
        require(rrset.typeCovered == DNSTYPE_NSEC);

        require(RRUtils.serialNumberGte(rrset.inception, rrsets[keccak256(deleteName)][deleteType].inception));

        for (RRUtils.RRIterator memory iter = rrset.rrs(); !iter.done(); iter.next()) {
            checkNsecName(iter, rrset.name, deleteName, deleteType);
            delete rrsets[keccak256(deleteName)][deleteType];
            return;
        }
        revert();
    }

    function checkNsecName(RRUtils.RRIterator memory iter, bytes memory nsecName, bytes memory deleteName, uint16 deleteType) private pure {

        uint rdataOffset = iter.rdataOffset;
        uint nextNameLength = iter.data.nameLength(rdataOffset);
        uint rDataLength = iter.nextOffset - iter.rdataOffset;

        require(rDataLength > nextNameLength);

        int compareResult = deleteName.compareNames(nsecName);
        if(compareResult == 0) {
            require(!iter.data.checkTypeBitmap(rdataOffset + nextNameLength, deleteType));
        } else {
            bytes memory nextName = iter.data.substring(rdataOffset,nextNameLength);
            require(compareResult > 0);
            if(nsecName.compareNames(nextName) < 0) {
                require(deleteName.compareNames(nextName) < 0);
            }
        }
    }

    function deleteRRSetNSEC3(uint16 deleteType, bytes memory deleteName, RRSetWithSignature memory closestEncloser, RRSetWithSignature memory nextClosest, bytes memory dnskey)
        public override
    {

        uint32 originalInception = rrsets[keccak256(deleteName)][deleteType].inception;

        RRUtils.SignedSet memory ce = validateSignedSet(closestEncloser, dnskey);
        checkNSEC3Validity(ce, deleteName, originalInception);

        RRUtils.SignedSet memory nc;
        if(nextClosest.rrset.length > 0) {
            nc = validateSignedSet(nextClosest, dnskey);
            checkNSEC3Validity(nc, deleteName, originalInception);
        }

        RRUtils.NSEC3 memory ceNSEC3 = readNSEC3(ce);
        require(ceNSEC3.flags & 0xfe == 0);
        require(!ceNSEC3.checkTypeBitmap(DNSTYPE_DNAME) && (!ceNSEC3.checkTypeBitmap(DNSTYPE_NS) || ceNSEC3.checkTypeBitmap(DNSTYPE_SOA)));

        if(isMatchingNSEC3Record(deleteType, deleteName, ce.name, ceNSEC3)) {
            delete rrsets[keccak256(deleteName)][deleteType];
        } else if(isCoveringNSEC3Record(deleteName, ce.name, ceNSEC3, nc.name, readNSEC3(nc))) {
            delete rrsets[keccak256(deleteName)][deleteType];
        } else {
            revert();
        }
    }

    function checkNSEC3Validity(RRUtils.SignedSet memory nsec, bytes memory deleteName, uint32 originalInception) private pure {

        require(RRUtils.serialNumberGte(nsec.inception, originalInception));

        require(nsec.typeCovered == DNSTYPE_NSEC3);

        require(checkNSEC3OwnerName(nsec.name, deleteName));
    }

    function isMatchingNSEC3Record(uint16 deleteType, bytes memory deleteName, bytes memory closestEncloserName, RRUtils.NSEC3 memory closestEncloser) private view returns(bool) {

        if(checkNSEC3Name(closestEncloser, closestEncloserName, deleteName)) {
            return !closestEncloser.checkTypeBitmap(deleteType);
        }

        return false;
    }

    function isCoveringNSEC3Record(bytes memory deleteName, bytes memory ceName, RRUtils.NSEC3 memory ce, bytes memory ncName, RRUtils.NSEC3 memory nc) private view returns(bool) {

        require(nc.flags & 0xfe == 0);

        bytes32 ceNameHash = decodeOwnerNameHash(ceName);
        bytes32 ncNameHash = decodeOwnerNameHash(ncName);

        uint lastOffset = 0;
        for(uint offset = deleteName.readUint8(0) + 1; offset < deleteName.length; offset += deleteName.readUint8(offset) + 1) {
            if(hashName(ce, deleteName.substring(offset, deleteName.length - offset)) == ceNameHash) {
                bytes32 checkHash = hashName(nc, deleteName.substring(lastOffset, deleteName.length - lastOffset));
                if(ncNameHash < nc.nextHashedOwnerName) {
                    return checkHash > ncNameHash && checkHash < nc.nextHashedOwnerName;
                } else {
                    return checkHash > ncNameHash || checkHash < nc.nextHashedOwnerName;
                }
            }
            lastOffset = offset;
        }
        return false;
    }

    function readNSEC3(RRUtils.SignedSet memory ss) private pure returns(RRUtils.NSEC3 memory) {

        RRUtils.RRIterator memory iter = ss.rrs();
        return iter.data.readNSEC3(iter.rdataOffset, iter.nextOffset - iter.rdataOffset);
    }

    function checkNSEC3Name(RRUtils.NSEC3 memory nsec, bytes memory ownerName, bytes memory deleteName) private view returns(bool) {

        bytes32 deleteNameHash = hashName(nsec, deleteName);

        bytes32 nsecNameHash = decodeOwnerNameHash(ownerName);

        return deleteNameHash == nsecNameHash;
    }

    function hashName(RRUtils.NSEC3 memory nsec, bytes memory name) private view returns(bytes32) {

        return nsec3Digests[nsec.hashAlgorithm].hash(nsec.salt, name, nsec.iterations);
    }

    function decodeOwnerNameHash(bytes memory name) private pure returns(bytes32) {

        return name.base32HexDecodeWord(1, uint(name.readUint8(0)));
    }

    function checkNSEC3OwnerName(bytes memory nsecName, bytes memory deleteName) private pure returns(bool) {

        uint nsecNameOffset = nsecName.readUint8(0) + 1;
        uint deleteNameOffset = 0;
        while(deleteNameOffset < deleteName.length) {
            if(deleteName.equals(deleteNameOffset, nsecName, nsecNameOffset)) {
                return true;
            }
            deleteNameOffset += deleteName.readUint8(deleteNameOffset) + 1;
        }
        return false;
    }

    function rrdata(uint16 dnstype, bytes calldata name) external override view returns (uint32, uint32, bytes20) {

        RRSet storage result = rrsets[keccak256(name)][dnstype];
        return (result.inception, result.expiration, result.hash);
    }

    function _submitRRSet(RRSetWithSignature memory input, bytes memory proof) internal returns (bytes memory) {

        RRUtils.SignedSet memory rrset;
        rrset = validateSignedSet(input, proof);

        RRSet storage storedSet = rrsets[keccak256(rrset.name)][rrset.typeCovered];
        if (storedSet.hash != bytes20(0)) {
            require(RRUtils.serialNumberGte(rrset.inception, storedSet.inception));
        }
        rrsets[keccak256(rrset.name)][rrset.typeCovered] = RRSet({
            inception: rrset.inception,
            expiration: rrset.expiration,
            hash: bytes20(keccak256(rrset.data))
        });

        emit RRSetUpdated(rrset.name, rrset.data);

        return rrset.data;
    }

    function validateSignedSet(RRSetWithSignature memory input, bytes memory proof) internal view returns(RRUtils.SignedSet memory rrset) {

        rrset = input.rrset.readSignedSet();
        require(validProof(rrset.signerName, proof));

        bytes memory name = validateRRs(rrset, rrset.typeCovered);
        require(name.labelCount(0) == rrset.labels);
        rrset.name = name;


        require(RRUtils.serialNumberGte(rrset.expiration, uint32(block.timestamp)));

        require(RRUtils.serialNumberGte(uint32(block.timestamp), rrset.inception));

        verifySignature(name, rrset, input, proof);

        return rrset;
    }

    function validProof(bytes memory name, bytes memory proof) internal view returns(bool) {

        uint16 dnstype = proof.readUint16(proof.nameLength(0));
        return rrsets[keccak256(name)][dnstype].hash == bytes20(keccak256(proof));
    }

    function validateRRs(RRUtils.SignedSet memory rrset, uint16 typecovered) internal pure returns (bytes memory name) {

        for (RRUtils.RRIterator memory iter = rrset.rrs(); !iter.done(); iter.next()) {
            require(iter.class == DNSCLASS_IN);

            if(name.length == 0) {
                name = iter.name();
            } else {
                require(name.length == iter.data.nameLength(iter.offset));
                require(name.equals(0, iter.data, iter.offset, name.length));
            }

            require(iter.dnstype == typecovered);
        }
    }

    function verifySignature(bytes memory name, RRUtils.SignedSet memory rrset, RRSetWithSignature memory data, bytes memory proof) internal view {

        require(rrset.signerName.length <= name.length);
        require(rrset.signerName.equals(0, name, name.length - rrset.signerName.length));

        RRUtils.RRIterator memory proofRR = proof.iterateRRs(0);
        if (proofRR.dnstype == DNSTYPE_DS) {
            require(verifyWithDS(rrset, data, proofRR));
        } else if (proofRR.dnstype == DNSTYPE_DNSKEY) {
            require(verifyWithKnownKey(rrset, data, proofRR));
        } else {
            revert("No valid proof found");
        }
    }

    function verifyWithKnownKey(RRUtils.SignedSet memory rrset, RRSetWithSignature memory data, RRUtils.RRIterator memory proof) internal view returns(bool) {

        require(proof.name().equals(rrset.signerName));
        for(; !proof.done(); proof.next()) {
            require(proof.name().equals(rrset.signerName));
            bytes memory keyrdata = proof.rdata();
            RRUtils.DNSKEY memory dnskey = keyrdata.readDNSKEY(0, keyrdata.length);
            if(verifySignatureWithKey(dnskey, keyrdata, rrset, data)) {
                return true;
            }
        }
        return false;
    }

    function verifySignatureWithKey(RRUtils.DNSKEY memory dnskey, bytes memory keyrdata, RRUtils.SignedSet memory rrset, RRSetWithSignature memory data)
        internal
        view
        returns (bool)
    {


        if(dnskey.protocol != 3) {
            return false;
        }

        if(dnskey.algorithm != rrset.algorithm) {
            return false;
        }
        uint16 computedkeytag = keyrdata.computeKeytag();
        if (computedkeytag != rrset.keytag) {
            return false;
        }

        if (dnskey.flags & DNSKEY_FLAG_ZONEKEY == 0) {
            return false;
        }

        return algorithms[dnskey.algorithm].verify(keyrdata, data.rrset, data.sig);
    }

    function verifyWithDS(RRUtils.SignedSet memory rrset, RRSetWithSignature memory data, RRUtils.RRIterator memory proof) internal view returns(bool) {

        for(RRUtils.RRIterator memory iter = rrset.rrs(); !iter.done(); iter.next()) {
            require(iter.dnstype == DNSTYPE_DNSKEY);
            bytes memory keyrdata = iter.rdata();
            RRUtils.DNSKEY memory dnskey = keyrdata.readDNSKEY(0, keyrdata.length);
            if (verifySignatureWithKey(dnskey, keyrdata, rrset, data)) {
                return verifyKeyWithDS(iter.name(), proof, dnskey, keyrdata);
            }
        }
        return false;
    }

    function verifyKeyWithDS(bytes memory keyname, RRUtils.RRIterator memory dsrrs, RRUtils.DNSKEY memory dnskey, bytes memory keyrdata)
        internal view returns (bool)
    {

        uint16 keytag = keyrdata.computeKeytag();
        for (; !dsrrs.done(); dsrrs.next()) {
            RRUtils.DS memory ds = dsrrs.data.readDS(dsrrs.rdataOffset, dsrrs.nextOffset - dsrrs.rdataOffset);
            if(ds.keytag != keytag) {
                continue;
            }
            if (ds.algorithm != dnskey.algorithm) {
                continue;
            }

            Buffer.buffer memory buf;
            buf.init(keyname.length + keyrdata.length);
            buf.append(keyname);
            buf.append(keyrdata);
            if (verifyDSHash(ds.digestType, buf.buf, ds.digest)) {
                return true;
            }
        }
        return false;
    }

    function verifyDSHash(uint8 digesttype, bytes memory data, bytes memory digest) internal view returns (bool) {

        if (address(digests[digesttype]) == address(0)) {
            return false;
        }
        return digests[digesttype].verify(data, digest);
    }
}