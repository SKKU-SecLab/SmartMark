
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


abstract contract ERC165Storage is ERC165 {
    mapping(bytes4 => bool) private _supportedInterfaces;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId) || _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}pragma solidity >=0.8.0;

interface ENS {

  event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

  event Transfer(bytes32 indexed node, address owner);

  event NewResolver(bytes32 indexed node, address resolver);

  event NewTTL(bytes32 indexed node, uint64 ttl);

  event ApprovalForAll(
    address indexed owner,
    address indexed operator,
    bool approved
  );

  function setRecord(
    bytes32 node,
    address owner,
    address resolver,
    uint64 ttl
  ) external virtual;


  function setSubnodeRecord(
    bytes32 node,
    bytes32 label,
    address owner,
    address resolver,
    uint64 ttl
  ) external virtual;


  function setSubnodeOwner(
    bytes32 node,
    bytes32 label,
    address owner
  ) external virtual returns (bytes32);


  function setResolver(bytes32 node, address resolver) external virtual;


  function setOwner(bytes32 node, address owner) external virtual;


  function setTTL(bytes32 node, uint64 ttl) external virtual;


  function setApprovalForAll(address operator, bool approved) external virtual;


  function owner(bytes32 node) external view virtual returns (address);


  function resolver(bytes32 node) external view virtual returns (address);


  function ttl(bytes32 node) external view virtual returns (uint64);


  function recordExists(bytes32 node) external view virtual returns (bool);


  function isApprovedForAll(address owner, address operator)
    external
    view
    virtual
    returns (bool);

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
}pragma solidity >=0.8.4;

abstract contract ABIResolver is ResolverBase {
    bytes4 constant private ABI_INTERFACE_ID = 0x2203ab56;

    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);

    mapping(bytes32=>mapping(uint256=>bytes)) abis;

    function setABI(bytes32 node, uint256 contentType, bytes calldata data) external authorised(node) {
        require(((contentType - 1) & contentType) == 0);

        abis[node][contentType] = data;
        emit ABIChanged(node, contentType);
    }

    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory) {
        mapping(uint256=>bytes) storage abiset = abis[node];

        for (uint256 contentType = 1; contentType <= contentTypes; contentType <<= 1) {
            if ((contentType & contentTypes) != 0 && abiset[contentType].length > 0) {
                return (contentType, abiset[contentType]);
            }
        }

        return (0, bytes(""));
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == ABI_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}pragma solidity >=0.8.4;

abstract contract AddrResolver is ResolverBase {
  bytes4 private constant ADDR_INTERFACE_ID = 0x3b3b57de;
  bytes4 private constant ADDRESS_INTERFACE_ID = 0xf1cb7e06;
  uint256 constant COIN_TYPE_ETH = 60;

  event AddrChanged(bytes32 indexed node, address a);
  event AddressChanged(
    bytes32 indexed node,
    uint256 coinType,
    bytes newAddress
  );

  mapping(bytes32 => mapping(uint256 => bytes)) _addresses;

  function addr(bytes32 node) public view virtual returns (address payable) {
    bytes memory a = addr(node, COIN_TYPE_ETH);
    if (a.length == 0) {
      return payable(0);
    }
    return bytesToAddress(a);
  }

  function addr(bytes32 node, uint256 coinType)
    public
    view
    virtual
    returns (bytes memory)
  {
    return _addresses[node][coinType];
  }

  function supportsInterface(bytes4 interfaceID)
    public
    pure
    virtual
    override
    returns (bool)
  {
    return
      interfaceID == ADDR_INTERFACE_ID ||
      interfaceID == ADDRESS_INTERFACE_ID ||
      super.supportsInterface(interfaceID);
  }
}pragma solidity >=0.8.4;

abstract contract ContentHashResolver is ResolverBase {
    bytes4 constant private CONTENT_HASH_INTERFACE_ID = 0xbc1c58d1;

    event ContenthashChanged(bytes32 indexed node, bytes hash);

    mapping(bytes32=>bytes) hashes;

    function setContenthash(bytes32 node, bytes calldata hash) external authorised(node) {
        hashes[node] = hash;
        emit ContenthashChanged(node, hash);
    }

    function contenthash(bytes32 node) external view returns (bytes memory) {
        return hashes[node];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == CONTENT_HASH_INTERFACE_ID || super.supportsInterface(interfaceID);
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


library RRUtils {

  using BytesUtils for *;
  using Buffer for *;

  function nameLength(bytes memory self, uint256 offset)
    internal
    pure
    returns (uint256)
  {

    uint256 idx = offset;
    while (true) {
      assert(idx < self.length);
      uint256 labelLen = self.readUint8(idx);
      idx += labelLen + 1;
      if (labelLen == 0) {
        break;
      }
    }
    return idx - offset;
  }

  function readName(bytes memory self, uint256 offset)
    internal
    pure
    returns (bytes memory ret)
  {

    uint256 len = nameLength(self, offset);
    return self.substring(offset, len);
  }

  function labelCount(bytes memory self, uint256 offset)
    internal
    pure
    returns (uint256)
  {

    uint256 count = 0;
    while (true) {
      assert(offset < self.length);
      uint256 labelLen = self.readUint8(offset);
      offset += labelLen + 1;
      if (labelLen == 0) {
        break;
      }
      count += 1;
    }
    return count;
  }

  uint256 constant RRSIG_TYPE = 0;
  uint256 constant RRSIG_ALGORITHM = 2;
  uint256 constant RRSIG_LABELS = 3;
  uint256 constant RRSIG_TTL = 4;
  uint256 constant RRSIG_EXPIRATION = 8;
  uint256 constant RRSIG_INCEPTION = 12;
  uint256 constant RRSIG_KEY_TAG = 16;
  uint256 constant RRSIG_SIGNER_NAME = 18;

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

  function readSignedSet(bytes memory data)
    internal
    pure
    returns (SignedSet memory self)
  {

    self.typeCovered = data.readUint16(RRSIG_TYPE);
    self.algorithm = data.readUint8(RRSIG_ALGORITHM);
    self.labels = data.readUint8(RRSIG_LABELS);
    self.ttl = data.readUint32(RRSIG_TTL);
    self.expiration = data.readUint32(RRSIG_EXPIRATION);
    self.inception = data.readUint32(RRSIG_INCEPTION);
    self.keytag = data.readUint16(RRSIG_KEY_TAG);
    self.signerName = readName(data, RRSIG_SIGNER_NAME);
    self.data = data.substring(
      RRSIG_SIGNER_NAME + self.signerName.length,
      data.length - RRSIG_SIGNER_NAME - self.signerName.length
    );
  }

  function rrs(SignedSet memory rrset)
    internal
    pure
    returns (RRIterator memory)
  {

    return iterateRRs(rrset.data, 0);
  }

  struct RRIterator {
    bytes data;
    uint256 offset;
    uint16 dnstype;
    uint16 class;
    uint32 ttl;
    uint256 rdataOffset;
    uint256 nextOffset;
  }

  function iterateRRs(bytes memory self, uint256 offset)
    internal
    pure
    returns (RRIterator memory ret)
  {

    ret.data = self;
    ret.nextOffset = offset;
    next(ret);
  }

  function done(RRIterator memory iter) internal pure returns (bool) {

    return iter.offset >= iter.data.length;
  }

  function next(RRIterator memory iter) internal pure {

    iter.offset = iter.nextOffset;
    if (iter.offset >= iter.data.length) {
      return;
    }

    uint256 off = iter.offset + nameLength(iter.data, iter.offset);

    iter.dnstype = iter.data.readUint16(off);
    off += 2;
    iter.class = iter.data.readUint16(off);
    off += 2;
    iter.ttl = iter.data.readUint32(off);
    off += 4;

    uint256 rdataLength = iter.data.readUint16(off);
    off += 2;
    iter.rdataOffset = off;
    iter.nextOffset = off + rdataLength;
  }

  function name(RRIterator memory iter) internal pure returns (bytes memory) {

    return iter.data.substring(iter.offset, nameLength(iter.data, iter.offset));
  }

  function rdata(RRIterator memory iter) internal pure returns (bytes memory) {

    return
      iter.data.substring(iter.rdataOffset, iter.nextOffset - iter.rdataOffset);
  }

  uint256 constant DNSKEY_FLAGS = 0;
  uint256 constant DNSKEY_PROTOCOL = 2;
  uint256 constant DNSKEY_ALGORITHM = 3;
  uint256 constant DNSKEY_PUBKEY = 4;

  struct DNSKEY {
    uint16 flags;
    uint8 protocol;
    uint8 algorithm;
    bytes publicKey;
  }

  function readDNSKEY(
    bytes memory data,
    uint256 offset,
    uint256 length
  ) internal pure returns (DNSKEY memory self) {

    self.flags = data.readUint16(offset + DNSKEY_FLAGS);
    self.protocol = data.readUint8(offset + DNSKEY_PROTOCOL);
    self.algorithm = data.readUint8(offset + DNSKEY_ALGORITHM);
    self.publicKey = data.substring(
      offset + DNSKEY_PUBKEY,
      length - DNSKEY_PUBKEY
    );
  }

  uint256 constant DS_KEY_TAG = 0;
  uint256 constant DS_ALGORITHM = 2;
  uint256 constant DS_DIGEST_TYPE = 3;
  uint256 constant DS_DIGEST = 4;

  struct DS {
    uint16 keytag;
    uint8 algorithm;
    uint8 digestType;
    bytes digest;
  }

  function readDS(
    bytes memory data,
    uint256 offset,
    uint256 length
  ) internal pure returns (DS memory self) {

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

  uint256 constant NSEC3_HASH_ALGORITHM = 0;
  uint256 constant NSEC3_FLAGS = 1;
  uint256 constant NSEC3_ITERATIONS = 2;
  uint256 constant NSEC3_SALT_LENGTH = 4;
  uint256 constant NSEC3_SALT = 5;

  function readNSEC3(
    bytes memory data,
    uint256 offset,
    uint256 length
  ) internal pure returns (NSEC3 memory self) {

    uint256 end = offset + length;
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

  function checkTypeBitmap(NSEC3 memory self, uint16 rrtype)
    internal
    pure
    returns (bool)
  {

    return checkTypeBitmap(self.typeBitmap, 0, rrtype);
  }

  function checkTypeBitmap(
    bytes memory bitmap,
    uint256 offset,
    uint16 rrtype
  ) internal pure returns (bool) {

    uint8 typeWindow = uint8(rrtype >> 8);
    uint8 windowByte = uint8((rrtype & 0xff) / 8);
    uint8 windowBitmask = uint8(uint8(1) << (uint8(7) - uint8(rrtype & 0x7)));
    for (uint256 off = offset; off < bitmap.length; ) {
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

  function compareNames(bytes memory self, bytes memory other)
    internal
    pure
    returns (int256)
  {

    if (self.equals(other)) {
      return 0;
    }

    uint256 off;
    uint256 otheroff;
    uint256 prevoff;
    uint256 otherprevoff;
    uint256 counts = labelCount(self, 0);
    uint256 othercounts = labelCount(other, 0);

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
    if (otheroff == 0) {
      return 1;
    }

    return
      self.compare(
        prevoff + 1,
        self.readUint8(prevoff),
        other,
        otherprevoff + 1,
        other.readUint8(otherprevoff)
      );
  }

  function serialNumberGte(uint32 i1, uint32 i2) internal pure returns (bool) {

    return int32(i1) - int32(i2) >= 0;
  }

  function progress(bytes memory body, uint256 off)
    internal
    pure
    returns (uint256)
  {

    return off + 1 + body.readUint8(off);
  }
}pragma solidity >=0.8.4;

abstract contract DNSResolver is ResolverBase {
    using RRUtils for *;
    using BytesUtils for bytes;

    bytes4 constant private DNS_RECORD_INTERFACE_ID = 0xa8fa5682;
    bytes4 constant private DNS_ZONE_INTERFACE_ID = 0x5c47637c;

    event DNSRecordChanged(bytes32 indexed node, bytes name, uint16 resource, bytes record);
    event DNSRecordDeleted(bytes32 indexed node, bytes name, uint16 resource);
    event DNSZoneCleared(bytes32 indexed node);

    event DNSZonehashChanged(bytes32 indexed node, bytes lastzonehash, bytes zonehash);

    mapping(bytes32=>bytes) private zonehashes;

    mapping(bytes32=>uint256) private versions;

    mapping(bytes32=>mapping(uint256=>mapping(bytes32=>mapping(uint16=>bytes)))) private records;

    mapping(bytes32=>mapping(uint256=>mapping(bytes32=>uint16))) private nameEntriesCount;

    function setDNSRecords(bytes32 node, bytes calldata data) external authorised(node) {
        uint16 resource = 0;
        uint256 offset = 0;
        bytes memory name;
        bytes memory value;
        bytes32 nameHash;
        for (RRUtils.RRIterator memory iter = data.iterateRRs(0); !iter.done(); iter.next()) {
            if (resource == 0) {
                resource = iter.dnstype;
                name = iter.name();
                nameHash = keccak256(abi.encodePacked(name));
                value = bytes(iter.rdata());
            } else {
                bytes memory newName = iter.name();
                if (resource != iter.dnstype || !name.equals(newName)) {
                    setDNSRRSet(node, name, resource, data, offset, iter.offset - offset, value.length == 0);
                    resource = iter.dnstype;
                    offset = iter.offset;
                    name = newName;
                    nameHash = keccak256(name);
                    value = bytes(iter.rdata());
                }
            }
        }
        if (name.length > 0) {
            setDNSRRSet(node, name, resource, data, offset, data.length - offset, value.length == 0);
        }
    }

    function dnsRecord(bytes32 node, bytes32 name, uint16 resource) public view returns (bytes memory) {
        return records[node][versions[node]][name][resource];
    }

    function hasDNSRecords(bytes32 node, bytes32 name) public view returns (bool) {
        return (nameEntriesCount[node][versions[node]][name] != 0);
    }

    function clearDNSZone(bytes32 node) public authorised(node) {
        versions[node]++;
        emit DNSZoneCleared(node);
    }

    function setZonehash(bytes32 node, bytes calldata hash) external authorised(node) {
        bytes memory oldhash = zonehashes[node];
        zonehashes[node] = hash;
        emit DNSZonehashChanged(node, oldhash, hash);
    }

    function zonehash(bytes32 node) external view returns (bytes memory) {
        return zonehashes[node];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == DNS_RECORD_INTERFACE_ID ||
               interfaceID == DNS_ZONE_INTERFACE_ID ||
               super.supportsInterface(interfaceID);
    }

    function setDNSRRSet(
        bytes32 node,
        bytes memory name,
        uint16 resource,
        bytes memory data,
        uint256 offset,
        uint256 size,
        bool deleteRecord) private
    {
        uint256 version = versions[node];
        bytes32 nameHash = keccak256(name);
        bytes memory rrData = data.substring(offset, size);
        if (deleteRecord) {
            if (records[node][version][nameHash][resource].length != 0) {
                nameEntriesCount[node][version][nameHash]--;
            }
            delete(records[node][version][nameHash][resource]);
            emit DNSRecordDeleted(node, name, resource);
        } else {
            if (records[node][version][nameHash][resource].length == 0) {
                nameEntriesCount[node][version][nameHash]++;
            }
            records[node][version][nameHash][resource] = rrData;
            emit DNSRecordChanged(node, name, resource, rrData);
        }
    }
}pragma solidity >=0.8.4;

abstract contract InterfaceResolver is ResolverBase, AddrResolver {
    bytes4 constant private INTERFACE_INTERFACE_ID = bytes4(keccak256("interfaceImplementer(bytes32,bytes4)"));
    bytes4 private constant INTERFACE_META_ID = 0x01ffc9a7;

    event InterfaceChanged(bytes32 indexed node, bytes4 indexed interfaceID, address implementer);

    mapping(bytes32=>mapping(bytes4=>address)) interfaces;

    function setInterface(bytes32 node, bytes4 interfaceID, address implementer) external authorised(node) {
        interfaces[node][interfaceID] = implementer;
        emit InterfaceChanged(node, interfaceID, implementer);
    }

    function interfaceImplementer(bytes32 node, bytes4 interfaceID) external view returns (address) {
        address implementer = interfaces[node][interfaceID];
        if(implementer != address(0)) {
            return implementer;
        }

        address a = addr(node);
        if(a == address(0)) {
            return address(0);
        }

        (bool success, bytes memory returnData) = a.staticcall(abi.encodeWithSignature("supportsInterface(bytes4)", INTERFACE_META_ID));
        if(!success || returnData.length < 32 || returnData[31] == 0) {
            return address(0);
        }

        (success, returnData) = a.staticcall(abi.encodeWithSignature("supportsInterface(bytes4)", interfaceID));
        if(!success || returnData.length < 32 || returnData[31] == 0) {
            return address(0);
        }

        return a;
    }

    function supportsInterface(bytes4 interfaceID) virtual override(AddrResolver, ResolverBase) public pure returns(bool) {
        return interfaceID == INTERFACE_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}pragma solidity >=0.8.4;

abstract contract NameResolver is ResolverBase {
    bytes4 constant private NAME_INTERFACE_ID = 0x691f3431;

    event NameChanged(bytes32 indexed node, string name);

    mapping(bytes32=>string) names;

    function setName(bytes32 node, string calldata name) external authorised(node) {
        names[node] = name;
        emit NameChanged(node, name);
    }

    function name(bytes32 node) external view returns (string memory) {
        return names[node];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == NAME_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}pragma solidity >=0.8.4;

abstract contract PubkeyResolver is ResolverBase {
    bytes4 constant private PUBKEY_INTERFACE_ID = 0xc8690233;

    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);

    struct PublicKey {
        bytes32 x;
        bytes32 y;
    }

    mapping(bytes32=>PublicKey) pubkeys;

    function setPubkey(bytes32 node, bytes32 x, bytes32 y) external authorised(node) {
        pubkeys[node] = PublicKey(x, y);
        emit PubkeyChanged(node, x, y);
    }

    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y) {
        return (pubkeys[node].x, pubkeys[node].y);
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == PUBKEY_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}pragma solidity >=0.8.4;

abstract contract TextResolver is ResolverBase {
    bytes4 constant private TEXT_INTERFACE_ID = 0x59d1d43c;

    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);

    mapping(bytes32=>mapping(string=>string)) texts;

    function setText(bytes32 node, string calldata key, string calldata value) external authorised(node) {
        texts[node][key] = value;
        emit TextChanged(node, key, key);
    }

    function text(bytes32 node, string calldata key) external view returns (string memory) {
        return texts[node][key];
    }

    function supportsInterface(bytes4 interfaceID) virtual override public pure returns(bool) {
        return interfaceID == TEXT_INTERFACE_ID || super.supportsInterface(interfaceID);
    }
}pragma solidity >=0.8.4;


interface INameWrapper {

  function ownerOf(uint256 id) external view returns (address);

}

contract PublicResolver is
  ABIResolver,
  AddrResolver,
  ContentHashResolver,
  DNSResolver,
  InterfaceResolver,
  NameResolver,
  PubkeyResolver,
  TextResolver
{

  ENS ens;
  INameWrapper nameWrapper;

  mapping(address => mapping(address => bool)) private _operatorApprovals;

  event ApprovalForAll(
    address indexed owner,
    address indexed operator,
    bool approved
  );

  constructor(address _ens, address wrapperAddress) {
    ens = ENS(_ens);
    nameWrapper = INameWrapper(wrapperAddress);
  }

  function isAuthorised(bytes32 node) internal view override returns (bool) {

    return msg.sender == addr(node);
  }

  function multicall(bytes[] calldata data)
    external
    returns (bytes[] memory results)
  {

    results = new bytes[](data.length);
    for (uint256 i = 0; i < data.length; i++) {
      (bool success, bytes memory result) = address(this).delegatecall(data[i]);
      require(success);
      results[i] = result;
    }
    return results;
  }

  function supportsInterface(bytes4 interfaceID)
    public
    pure
    virtual
    override(
      ABIResolver,
      AddrResolver,
      ContentHashResolver,
      DNSResolver,
      InterfaceResolver,
      NameResolver,
      PubkeyResolver,
      TextResolver
    )
    returns (bool)
  {

    return super.supportsInterface(interfaceID);
  }
}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

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
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
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
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
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

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

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

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
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

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

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

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

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
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity >=0.4.22 <0.9.0;



contract PxgRegistrar is ERC721Enumerable, Ownable {
  string BASE_URI;
  address RESOLVER;
  bytes32 public ROOT_NODE;
  uint256 PRICE;
  bool publicRegistrationOpen = false;
  ENS ens;
  ERC721 glyphs;

  mapping(uint256 => bool) public claimedGlyphIds;
  mapping(uint256 => address) public resolvers;
  uint256 public currentResolverVersion;
  uint256 count;

  constructor(
    string memory baseUri,
    address ensAddr,
    address glyphAddr,
    bytes32 node
  ) ERC721("PXG.ETH", "PXG.ETH") {
    BASE_URI = baseUri;
    ROOT_NODE = node;
    ens = ENS(ensAddr);
    glyphs = ERC721(glyphAddr);
    admin[msg.sender] = true;
  }

  function addResolverVersion(address resolver) public onlyOwner {
    resolvers[++currentResolverVersion] = resolver;
    RESOLVER = resolver;
  }

  function setBaseUri(string memory baseUri) public onlyOwner {
    BASE_URI = baseUri;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return BASE_URI;
  }

  function openReg() public onlyOwner {
    publicRegistrationOpen = true;
  }

  function updatePrice(uint256 price) public onlyOwner {
    PRICE = price;
  }

  function getTokenIdFromNode(bytes32 node) public pure returns (uint256) {
    return uint256(node);
  }

  function getOwnerFromNode(bytes32 node) public view returns (address) {
    return _exists(uint256(node)) ? ownerOf(uint256(node)) : address(0);
  }

  function setResolver(bytes32 node, uint256 version) public {
    require(resolvers[version] != address(0), "PXG: Resolver does not exist");
    require(
      getOwnerFromNode(node) == msg.sender,
      "PXG: Only owner can set resolver"
    );
    ens.setResolver(node, resolvers[version]);
  }

  mapping(bytes32 => string) public nodeToLabel;

  function _register(string calldata subdomain) internal {
    bytes32 subdomainLabel = keccak256(bytes(subdomain));
    bytes32 node = keccak256(abi.encodePacked(ROOT_NODE, subdomainLabel));

    address currentOwner = ens.owner(node);

    require(currentOwner == address(0), "PXG: Name already claimed");
    require(
      resolvers[currentResolverVersion] != address(0),
      "PXG: No resolver set"
    );

    ens.setSubnodeOwner(ROOT_NODE, subdomainLabel, address(this));
    ens.setResolver(node, RESOLVER);
    _safeMint(msg.sender, uint256(node));
    nodeToLabel[node] = subdomain;
    count++;
  }

  function resolver(bytes32 node) external view returns (address) {
    return ens.resolver(node);
  }

  mapping(address => bool) private admin;

  modifier onlyAdmin() {
    require(admin[msg.sender], "Not admin");
    _;
  }

  event CollectionSupportAdded(address collection);

  event ModifyAdmin(address adminAddr, bool value);

  function modifyAdmin(address adminAddr, bool value) public onlyAdmin {
    admin[adminAddr] = value;
    emit ModifyAdmin(adminAddr, value);
  }

  mapping(address => bool) supportedCollections;

  function addCollectionSupport(address collection) public onlyAdmin {
    supportedCollections[collection] = true;
    emit CollectionSupportAdded(collection);
  }

  function supportsCollection(address collection) public view returns (bool) {
    return supportedCollections[collection];
  }

  event ClaimedGlyph(uint256 indexed glyphId);

  function claimGlyph(string calldata subdomain, uint256 glyphId) public {
    require(
      glyphs.ownerOf(glyphId) == msg.sender &&
        claimedGlyphIds[glyphId] == false,
      "PXG: Unauthorized"
    );

    claimedGlyphIds[glyphId] = true;
    _register(subdomain);
    emit ClaimedGlyph(glyphId);
  }

  function register(string calldata subdomain) public payable {
    require(publicRegistrationOpen || count >= 10000, "Not allowed");
    require(msg.value == PRICE, "PXG: Invalid value");
    _register(subdomain);
  }
}pragma solidity >=0.8.0;
pragma abicoder v2;


interface NFTInterface {
  function ownerOf(uint256 tokenId) external view returns (address);
}

interface Punks {
  function punkIndexToAddress(uint256 index) external view returns (address);
}

contract PxgResolverV1 is ERC165Storage, PublicResolver {
  PxgRegistrar registrar;

  mapping(address => bool) private admin;

  constructor(
    address ens,
    address registrarAddress,
    address initialAdmin
  ) PublicResolver(ens, registrarAddress) {
    registrar = PxgRegistrar(registrarAddress);
    admin[initialAdmin] = true;
  }

  event ModifyAdmin(address adminAddr, bool value);

  modifier onlyAdmin() {
    require(admin[msg.sender], "Not admin");
    _;
  }

  function modifyAdmin(address adminAddr, bool value) public onlyAdmin {
    admin[adminAddr] = value;
    emit ModifyAdmin(adminAddr, value);
  }

  function addr(bytes32 node) public view override returns (address payable) {
    try nameWrapper.ownerOf(uint256(node)) returns (address nameOwner) {
      return payable(nameOwner);
    } catch Error(string memory) {
    } catch (bytes memory) {
    }
    return payable(0);
  }

  address PUNK_ADDRESS = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;

  struct NFT {
    address collectionAddress;
    uint256 tokenId;
    bool exists;
  }

  struct Sale {
    NFT nft;
    uint256 price;
  }

  mapping(bytes32 => NFT) defaultAvatar;
  mapping(bytes32 => NFT[5]) gallery;

  event DefaultAvatarSet(
    bytes32 indexed node,
    address collection,
    uint256 tokenId
  );

  function getGalleryLength(bytes32 node) public view returns (uint256) {
    return gallery[node].length;
  }

  function getGalleryItemAtIndex(bytes32 node, uint256 idx)
    public
    view
    returns (address, uint256)
  {
    if (
      !gallery[node][idx].exists ||
      !_isValidOwner(
        node,
        gallery[node][idx].collectionAddress,
        gallery[node][idx].tokenId
      )
    ) {
      return (address(0), uint256(0));
    }

    return _validateNftData(node, gallery[node][idx]);
  }

  function setManyGalleryItems(
    bytes32 node,
    address[] memory collections,
    uint256[] memory ids,
    uint256[] memory idx
  ) public {
    require(collections.length == ids.length);
    require(collections.length == idx.length);
    require(collections.length <= 5);

    for (uint256 i; i < collections.length; i++) {
      setGalleryItem(node, collections[i], ids[i], idx[i]);
    }
  }

  function setGalleryItem(
    bytes32 node,
    address collectionAddress,
    uint256 tokenId,
    uint256 idx
  ) public {
    require(idx <= 4, "Index out of bounds");
    require(
      _isValidOwner(node, collectionAddress, tokenId),
      "Not a valid owner"
    );
    require(isAuthorised(node), "Not authorized");
    gallery[node][idx].collectionAddress = collectionAddress;
    gallery[node][idx].tokenId = tokenId;
    gallery[node][idx].exists = true;
  }

  function removeGalleryItem(
    bytes32 node,
    address collectionAddress,
    uint256 tokenId,
    uint256 idx
  ) public {
    require(idx <= 4, "Index out of bounds");
    require(
      _isValidOwner(node, collectionAddress, tokenId),
      "Not a valid owner"
    );
    require(isAuthorised(node), "Not authorized");
    require(gallery[node][idx].exists == true, "Index does not exist");
    if (idx == gallery[node].length - 1) {
      delete gallery[node][gallery[node].length - 1];
    } else {
      gallery[node][idx] = gallery[node][gallery[node].length - 1];
      delete gallery[node][gallery[node].length - 1];
    }
  }

  function _isValidOwner(
    bytes32 node,
    address collection,
    uint256 tokenId
  ) internal view returns (bool) {
    if (collection == PUNK_ADDRESS) {
      return Punks(PUNK_ADDRESS).punkIndexToAddress(tokenId) == addr(node);
    } else {
      try NFTInterface(collection).ownerOf(tokenId) returns (
        address ownerAddr
      ) {
        return ownerAddr == addr(node);
      } catch Error(
        string memory /*reason*/
      ) {
        return false;
      } catch Panic(
        uint256 /*errorCode*/
      ) {
        return false;
      } catch (
        bytes memory /*lowLevelData*/
      ) {
        return false;
      }
    }
  }

  function _validateNftData(bytes32 node, NFT memory nft)
    internal
    view
    returns (address, uint256)
  {
    if (nft.exists && _isValidOwner(node, nft.collectionAddress, nft.tokenId)) {
      return (nft.collectionAddress, nft.tokenId);
    }
    return (address(0), uint256(0));
  }

  function getDefaultAvatar(bytes32 node)
    public
    view
    returns (address, uint256)
  {
    NFT memory nft = defaultAvatar[node];
    return _validateNftData(node, nft);
  }

  function setDefaultAvatar(
    bytes32 node,
    address collection,
    uint256 tokenId
  ) public {
    require(isAuthorised(node), "Unauthorized");
    require(
      registrar.supportsCollection(collection),
      "Collection not supported"
    );
    require(_isValidOwner(node, collection, tokenId), "Not valid owner");
    defaultAvatar[node] = NFT(collection, tokenId, true);
    emit DefaultAvatarSet(node, collection, tokenId);
  }

  function supportsInterface(bytes4 interfaceID)
    public
    pure
    virtual
    override(ERC165Storage, PublicResolver)
    returns (bool)
  {
    return super.supportsInterface(interfaceID);
  }
}