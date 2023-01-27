

pragma solidity >=0.4.24;

interface ENS {


    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external;

    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external;

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external returns(bytes32);

    function setResolver(bytes32 node, address resolver) external;

    function setOwner(bytes32 node, address owner) external;

    function setTTL(bytes32 node, uint64 ttl) external;

    function setApprovalForAll(address operator, bool approved) external;

    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

    function ttl(bytes32 node) external view returns (uint64);

    function recordExists(bytes32 node) external view returns (bool);

    function isApprovedForAll(address owner, address operator) external view returns (bool);

}


pragma solidity ^0.5.0;


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

    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external {

        setOwner(node, owner);
        _setResolverAndTTL(node, resolver, ttl);
    }

    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external {

        bytes32 subnode = setSubnodeOwner(node, label, owner);
        _setResolverAndTTL(subnode, resolver, ttl);
    }

    function setOwner(bytes32 node, address owner) public authorised(node) {

        _setOwner(node, owner);
        emit Transfer(node, owner);
    }

    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) public authorised(node) returns(bytes32) {

        bytes32 subnode = keccak256(abi.encodePacked(node, label));
        _setOwner(subnode, owner);
        emit NewOwner(node, label, owner);
        return subnode;
    }

    function setResolver(bytes32 node, address resolver) public authorised(node) {

        emit NewResolver(node, resolver);
        records[node].resolver = resolver;
    }

    function setTTL(bytes32 node, uint64 ttl) public authorised(node) {

        emit NewTTL(node, ttl);
        records[node].ttl = ttl;
    }

    function setApprovalForAll(address operator, bool approved) external {

        operators[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function owner(bytes32 node) public view returns (address) {

        address addr = records[node].owner;
        if (addr == address(this)) {
            return address(0x0);
        }

        return addr;
    }

    function resolver(bytes32 node) public view returns (address) {

        return records[node].resolver;
    }

    function ttl(bytes32 node) public view returns (uint64) {

        return records[node].ttl;
    }

    function recordExists(bytes32 node) public view returns (bool) {

        return records[node].owner != address(0x0);
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {

        return operators[owner][operator];
    }

    function _setOwner(bytes32 node, address owner) internal {

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
}


pragma solidity ^0.5.0;

interface DNSSEC {


    event AlgorithmUpdated(uint8 id, address addr);
    event DigestUpdated(uint8 id, address addr);
    event NSEC3DigestUpdated(uint8 id, address addr);
    event RRSetUpdated(bytes name, bytes rrset);

    function submitRRSets(bytes calldata data, bytes calldata proof) external returns (bytes memory);

    function submitRRSet(bytes calldata input, bytes calldata sig, bytes calldata proof) external returns (bytes memory);

    function deleteRRSet(uint16 deleteType, bytes calldata deleteName, bytes calldata nsec, bytes calldata sig, bytes calldata proof) external;

    function rrdata(uint16 dnstype, bytes calldata name) external view returns (uint32, uint64, bytes20);


}


pragma solidity >0.4.23;

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
                    mask = uint256(- 1); // aka 0xffffff....
                } else {
                    mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                }
                uint diff = (a & mask) - (b & mask);
                if (diff != 0)
                return int(diff);
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

        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
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
}


pragma solidity >0.4.18;

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

        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
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

        uint mask = 256 ** len - 1;
        data = data >> (8 * (32 - len));
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

        uint mask = 256 ** len - 1;
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
}





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

    function checkTypeBitmap(bytes memory self, uint offset, uint16 rrtype) internal pure returns (bool) {

        uint8 typeWindow = uint8(rrtype >> 8);
        uint8 windowByte = uint8((rrtype & 0xff) / 8);
        uint8 windowBitmask = uint8(uint8(1) << (uint8(7) - uint8(rrtype & 0x7)));
        for (uint off = offset; off < self.length;) {
            uint8 window = self.readUint8(off);
            uint8 len = self.readUint8(off + 1);
            if (typeWindow < window) {
                return false;
            } else if (typeWindow == window) {
                if (len * 8 <= windowByte) {
                    return false;
                }
                return (self.readUint8(off + windowByte + 2) & windowBitmask) != 0;
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

    function progress(bytes memory body, uint off) internal pure returns(uint) {

        return off + 1 + body.readUint8(off);
    }
}


pragma solidity ^0.5.0;





library DNSClaimChecker {


    using BytesUtils for bytes;
    using RRUtils for *;
    using Buffer for Buffer.buffer;

    uint16 constant CLASS_INET = 1;
    uint16 constant TYPE_TXT = 16;

    function getLabels(bytes memory name) internal view returns (bytes32, bytes32) {

        uint len = name.readUint8(0);
        uint second = name.readUint8(len + 1);

        require(name.readUint8(len + second + 2) == 0);

        return (name.keccak(1, len), keccak256(abi.encodePacked(bytes32(0), name.keccak(2 + len, second))));
    }

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
        uint64 inserted;
        (, inserted, hash) = oracle.rrdata(TYPE_TXT, buf.buf);
        if (hash == bytes20(0) && proof.length == 0) return (address(0x0), false);

        require(hash == bytes20(keccak256(proof)));

        for (RRUtils.RRIterator memory iter = proof.iterateRRs(0); !iter.done(); iter.next()) {
            require(inserted + iter.ttl >= now, "DNS record is stale; refresh or delete it before proceeding.");

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
        return (address(ret), true);
    }

}


pragma solidity ^0.5.0;




contract DNSRegistrar {


    DNSSEC public oracle;
    ENS public ens;

    bytes4 constant private INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));
    bytes4 constant private DNSSEC_CLAIM_ID = bytes4(
        keccak256("claim(bytes,bytes)") ^
        keccak256("proveAndClaim(bytes,bytes,bytes)") ^
        keccak256("oracle()")
    );

    event Claim(bytes32 indexed node, address indexed owner, bytes dnsname);

    constructor(DNSSEC _dnssec, ENS _ens) public {
        oracle = _dnssec;
        ens = _ens;
    }

    function claim(bytes memory name, bytes memory proof) public {

        address addr;
        (addr,) = DNSClaimChecker.getOwnerAddress(oracle, name, proof);

        bytes32 labelHash;
        bytes32 rootNode;
        (labelHash, rootNode) = DNSClaimChecker.getLabels(name);

        ens.setSubnodeOwner(rootNode, labelHash, addr);
        emit Claim(keccak256(abi.encodePacked(rootNode, labelHash)), addr, name);
    }

    function proveAndClaim(bytes memory name, bytes memory input, bytes memory proof) public {

        proof = oracle.submitRRSets(input, proof);
        claim(name, proof);
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {

        return interfaceID == INTERFACE_META_ID ||
               interfaceID == DNSSEC_CLAIM_ID;
    }
}