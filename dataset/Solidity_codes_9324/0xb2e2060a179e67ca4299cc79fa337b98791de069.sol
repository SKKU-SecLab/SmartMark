



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.9;

interface iMVM_DiscountOracle{


    function setDiscount(
        uint256 _discount
    ) external;

    
    function setMinL2Gas(
        uint256 _minL2Gas
    ) external;

    
    function setWhitelistedXDomainSender(
        address _sender,
        bool _isWhitelisted
    ) external;

    
    function isXDomainSenderAllowed(
        address _sender
    ) view external returns(bool);

    
    function setAllowAllXDomainSenders(
        bool _allowAllXDomainSenders
    ) external;

    
    function getMinL2Gas() view external returns(uint256);

    function getDiscount() view external returns(uint256);

    function processL2SeqGas(address sender, uint256 _chainId) external payable;

}



pragma solidity ^0.8.9;


contract Lib_AddressManager is Ownable {


    event AddressSet(string indexed _name, address _newAddress, address _oldAddress);


    mapping(bytes32 => address) private addresses;


    function setAddress(string memory _name, address _address) external onlyOwner {

        bytes32 nameHash = _getNameHash(_name);
        address oldAddress = addresses[nameHash];
        addresses[nameHash] = _address;

        emit AddressSet(_name, _address, oldAddress);
    }

    function getAddress(string memory _name) external view returns (address) {

        return addresses[_getNameHash(_name)];
    }


    function _getNameHash(string memory _name) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_name));
    }
}



pragma solidity ^0.8.9;


abstract contract Lib_AddressResolver {

    Lib_AddressManager public libAddressManager;


    constructor(address _libAddressManager) {
        libAddressManager = Lib_AddressManager(_libAddressManager);
    }


    function resolve(string memory _name) public view returns (address) {
        return libAddressManager.getAddress(_name);
    }
}



pragma solidity ^0.8.9;

library Lib_RLPReader {


    uint256 internal constant MAX_LIST_LENGTH = 32;


    enum RLPItemType {
        DATA_ITEM,
        LIST_ITEM
    }


    struct RLPItem {
        uint256 length;
        uint256 ptr;
    }


    function toRLPItem(bytes memory _in) internal pure returns (RLPItem memory) {

        uint256 ptr;
        assembly {
            ptr := add(_in, 32)
        }

        return RLPItem({ length: _in.length, ptr: ptr });
    }

    function readList(RLPItem memory _in) internal pure returns (RLPItem[] memory) {

        (uint256 listOffset, , RLPItemType itemType) = _decodeLength(_in);

        require(itemType == RLPItemType.LIST_ITEM, "Invalid RLP list value.");

        RLPItem[] memory out = new RLPItem[](MAX_LIST_LENGTH);

        uint256 itemCount = 0;
        uint256 offset = listOffset;
        while (offset < _in.length) {
            require(itemCount < MAX_LIST_LENGTH, "Provided RLP list exceeds max list length.");

            (uint256 itemOffset, uint256 itemLength, ) = _decodeLength(
                RLPItem({ length: _in.length - offset, ptr: _in.ptr + offset })
            );

            out[itemCount] = RLPItem({ length: itemLength + itemOffset, ptr: _in.ptr + offset });

            itemCount += 1;
            offset += itemOffset + itemLength;
        }

        assembly {
            mstore(out, itemCount)
        }

        return out;
    }

    function readList(bytes memory _in) internal pure returns (RLPItem[] memory) {

        return readList(toRLPItem(_in));
    }

    function readBytes(RLPItem memory _in) internal pure returns (bytes memory) {

        (uint256 itemOffset, uint256 itemLength, RLPItemType itemType) = _decodeLength(_in);

        require(itemType == RLPItemType.DATA_ITEM, "Invalid RLP bytes value.");

        return _copy(_in.ptr, itemOffset, itemLength);
    }

    function readBytes(bytes memory _in) internal pure returns (bytes memory) {

        return readBytes(toRLPItem(_in));
    }

    function readString(RLPItem memory _in) internal pure returns (string memory) {

        return string(readBytes(_in));
    }

    function readString(bytes memory _in) internal pure returns (string memory) {

        return readString(toRLPItem(_in));
    }

    function readBytes32(RLPItem memory _in) internal pure returns (bytes32) {

        require(_in.length <= 33, "Invalid RLP bytes32 value.");

        (uint256 itemOffset, uint256 itemLength, RLPItemType itemType) = _decodeLength(_in);

        require(itemType == RLPItemType.DATA_ITEM, "Invalid RLP bytes32 value.");

        uint256 ptr = _in.ptr + itemOffset;
        bytes32 out;
        assembly {
            out := mload(ptr)

            if lt(itemLength, 32) {
                out := div(out, exp(256, sub(32, itemLength)))
            }
        }

        return out;
    }

    function readBytes32(bytes memory _in) internal pure returns (bytes32) {

        return readBytes32(toRLPItem(_in));
    }

    function readUint256(RLPItem memory _in) internal pure returns (uint256) {

        return uint256(readBytes32(_in));
    }

    function readUint256(bytes memory _in) internal pure returns (uint256) {

        return readUint256(toRLPItem(_in));
    }

    function readBool(RLPItem memory _in) internal pure returns (bool) {

        require(_in.length == 1, "Invalid RLP boolean value.");

        uint256 ptr = _in.ptr;
        uint256 out;
        assembly {
            out := byte(0, mload(ptr))
        }

        require(out == 0 || out == 1, "Lib_RLPReader: Invalid RLP boolean value, must be 0 or 1");

        return out != 0;
    }

    function readBool(bytes memory _in) internal pure returns (bool) {

        return readBool(toRLPItem(_in));
    }

    function readAddress(RLPItem memory _in) internal pure returns (address) {

        if (_in.length == 1) {
            return address(0);
        }

        require(_in.length == 21, "Invalid RLP address value.");

        return address(uint160(readUint256(_in)));
    }

    function readAddress(bytes memory _in) internal pure returns (address) {

        return readAddress(toRLPItem(_in));
    }

    function readRawBytes(RLPItem memory _in) internal pure returns (bytes memory) {

        return _copy(_in);
    }


    function _decodeLength(RLPItem memory _in)
        private
        pure
        returns (
            uint256,
            uint256,
            RLPItemType
        )
    {

        require(_in.length > 0, "RLP item cannot be null.");

        uint256 ptr = _in.ptr;
        uint256 prefix;
        assembly {
            prefix := byte(0, mload(ptr))
        }

        if (prefix <= 0x7f) {

            return (0, 1, RLPItemType.DATA_ITEM);
        } else if (prefix <= 0xb7) {

            uint256 strLen = prefix - 0x80;

            require(_in.length > strLen, "Invalid RLP short string.");

            return (1, strLen, RLPItemType.DATA_ITEM);
        } else if (prefix <= 0xbf) {
            uint256 lenOfStrLen = prefix - 0xb7;

            require(_in.length > lenOfStrLen, "Invalid RLP long string length.");

            uint256 strLen;
            assembly {
                strLen := div(mload(add(ptr, 1)), exp(256, sub(32, lenOfStrLen)))
            }

            require(_in.length > lenOfStrLen + strLen, "Invalid RLP long string.");

            return (1 + lenOfStrLen, strLen, RLPItemType.DATA_ITEM);
        } else if (prefix <= 0xf7) {
            uint256 listLen = prefix - 0xc0;

            require(_in.length > listLen, "Invalid RLP short list.");

            return (1, listLen, RLPItemType.LIST_ITEM);
        } else {
            uint256 lenOfListLen = prefix - 0xf7;

            require(_in.length > lenOfListLen, "Invalid RLP long list length.");

            uint256 listLen;
            assembly {
                listLen := div(mload(add(ptr, 1)), exp(256, sub(32, lenOfListLen)))
            }

            require(_in.length > lenOfListLen + listLen, "Invalid RLP long list.");

            return (1 + lenOfListLen, listLen, RLPItemType.LIST_ITEM);
        }
    }

    function _copy(
        uint256 _src,
        uint256 _offset,
        uint256 _length
    ) private pure returns (bytes memory) {

        bytes memory out = new bytes(_length);
        if (out.length == 0) {
            return out;
        }

        uint256 src = _src + _offset;
        uint256 dest;
        assembly {
            dest := add(out, 32)
        }

        for (uint256 i = 0; i < _length / 32; i++) {
            assembly {
                mstore(dest, mload(src))
            }

            src += 32;
            dest += 32;
        }

        uint256 mask;
        unchecked {
            mask = 256**(32 - (_length % 32)) - 1;
        }

        assembly {
            mstore(dest, or(and(mload(src), not(mask)), and(mload(dest), mask)))
        }
        return out;
    }

    function _copy(RLPItem memory _in) private pure returns (bytes memory) {

        return _copy(_in.ptr, 0, _in.length);
    }
}



pragma solidity ^0.8.9;

library Lib_RLPWriter {


    function writeBytes(bytes memory _in) internal pure returns (bytes memory) {

        bytes memory encoded;

        if (_in.length == 1 && uint8(_in[0]) < 128) {
            encoded = _in;
        } else {
            encoded = abi.encodePacked(_writeLength(_in.length, 128), _in);
        }

        return encoded;
    }

    function writeList(bytes[] memory _in) internal pure returns (bytes memory) {

        bytes memory list = _flatten(_in);
        return abi.encodePacked(_writeLength(list.length, 192), list);
    }

    function writeString(string memory _in) internal pure returns (bytes memory) {

        return writeBytes(bytes(_in));
    }

    function writeAddress(address _in) internal pure returns (bytes memory) {

        return writeBytes(abi.encodePacked(_in));
    }

    function writeUint(uint256 _in) internal pure returns (bytes memory) {

        return writeBytes(_toBinary(_in));
    }

    function writeBool(bool _in) internal pure returns (bytes memory) {

        bytes memory encoded = new bytes(1);
        encoded[0] = (_in ? bytes1(0x01) : bytes1(0x80));
        return encoded;
    }


    function _writeLength(uint256 _len, uint256 _offset) private pure returns (bytes memory) {

        bytes memory encoded;

        if (_len < 56) {
            encoded = new bytes(1);
            encoded[0] = bytes1(uint8(_len) + uint8(_offset));
        } else {
            uint256 lenLen;
            uint256 i = 1;
            while (_len / i != 0) {
                lenLen++;
                i *= 256;
            }

            encoded = new bytes(lenLen + 1);
            encoded[0] = bytes1(uint8(lenLen) + uint8(_offset) + 55);
            for (i = 1; i <= lenLen; i++) {
                encoded[i] = bytes1(uint8((_len / (256**(lenLen - i))) % 256));
            }
        }

        return encoded;
    }

    function _toBinary(uint256 _x) private pure returns (bytes memory) {

        bytes memory b = abi.encodePacked(_x);

        uint256 i = 0;
        for (; i < 32; i++) {
            if (b[i] != 0) {
                break;
            }
        }

        bytes memory res = new bytes(32 - i);
        for (uint256 j = 0; j < res.length; j++) {
            res[j] = b[i++];
        }

        return res;
    }

    function _memcpy(
        uint256 _dest,
        uint256 _src,
        uint256 _len
    ) private pure {

        uint256 dest = _dest;
        uint256 src = _src;
        uint256 len = _len;

        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint256 mask;
        unchecked {
            mask = 256**(32 - len) - 1;
        }
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function _flatten(bytes[] memory _list) private pure returns (bytes memory) {

        if (_list.length == 0) {
            return new bytes(0);
        }

        uint256 len;
        uint256 i = 0;
        for (; i < _list.length; i++) {
            len += _list[i].length;
        }

        bytes memory flattened = new bytes(len);
        uint256 flattenedPtr;
        assembly {
            flattenedPtr := add(flattened, 0x20)
        }

        for (i = 0; i < _list.length; i++) {
            bytes memory item = _list[i];

            uint256 listPtr;
            assembly {
                listPtr := add(item, 0x20)
            }

            _memcpy(flattenedPtr, listPtr, item.length);
            flattenedPtr += _list[i].length;
        }

        return flattened;
    }
}



pragma solidity ^0.8.9;

library Lib_BytesUtils {


    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {

        require(_length + 31 >= _length, "slice_overflow");
        require(_start + _length >= _start, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function slice(bytes memory _bytes, uint256 _start) internal pure returns (bytes memory) {

        if (_start >= _bytes.length) {
            return bytes("");
        }

        return slice(_bytes, _start, _bytes.length - _start);
    }

    function toBytes32(bytes memory _bytes) internal pure returns (bytes32) {

        if (_bytes.length < 32) {
            bytes32 ret;
            assembly {
                ret := mload(add(_bytes, 32))
            }
            return ret;
        }

        return abi.decode(_bytes, (bytes32)); // will truncate if input length > 32 bytes
    }

    function toUint256(bytes memory _bytes) internal pure returns (uint256) {

        return uint256(toBytes32(_bytes));
    }

    function toNibbles(bytes memory _bytes) internal pure returns (bytes memory) {

        bytes memory nibbles = new bytes(_bytes.length * 2);

        for (uint256 i = 0; i < _bytes.length; i++) {
            nibbles[i * 2] = _bytes[i] >> 4;
            nibbles[i * 2 + 1] = bytes1(uint8(_bytes[i]) % 16);
        }

        return nibbles;
    }

    function fromNibbles(bytes memory _bytes) internal pure returns (bytes memory) {

        bytes memory ret = new bytes(_bytes.length / 2);

        for (uint256 i = 0; i < ret.length; i++) {
            ret[i] = (_bytes[i * 2] << 4) | (_bytes[i * 2 + 1]);
        }

        return ret;
    }

    function equal(bytes memory _bytes, bytes memory _other) internal pure returns (bool) {

        return keccak256(_bytes) == keccak256(_other);
    }
}



pragma solidity ^0.8.9;

library Lib_Bytes32Utils {


    function toBool(bytes32 _in) internal pure returns (bool) {

        return _in != 0;
    }

    function fromBool(bool _in) internal pure returns (bytes32) {

        return bytes32(uint256(_in ? 1 : 0));
    }

    function toAddress(bytes32 _in) internal pure returns (address) {

        return address(uint160(uint256(_in)));
    }

    function fromAddress(address _in) internal pure returns (bytes32) {

        return bytes32(uint256(uint160(_in)));
    }
}



pragma solidity ^0.8.9;





library Lib_OVMCodec {


    enum QueueOrigin {
        SEQUENCER_QUEUE,
        L1TOL2_QUEUE
    }


    struct EVMAccount {
        uint256 nonce;
        uint256 balance;
        bytes32 storageRoot;
        bytes32 codeHash;
    }

    struct ChainBatchHeader {
        uint256 batchIndex;
        bytes32 batchRoot;
        uint256 batchSize;
        uint256 prevTotalElements;
        bytes extraData;
    }

    struct ChainInclusionProof {
        uint256 index;
        bytes32[] siblings;
    }

    struct Transaction {
        uint256 timestamp;
        uint256 blockNumber;
        QueueOrigin l1QueueOrigin;
        address l1TxOrigin;
        address entrypoint;
        uint256 gasLimit;
        bytes data;
    }

    struct TransactionChainElement {
        bool isSequenced;
        uint256 queueIndex; // QUEUED TX ONLY
        uint256 timestamp; // SEQUENCER TX ONLY
        uint256 blockNumber; // SEQUENCER TX ONLY
        bytes txData; // SEQUENCER TX ONLY
    }

    struct QueueElement {
        bytes32 transactionHash;
        uint40 timestamp;
        uint40 blockNumber;
    }


    function encodeTransaction(Transaction memory _transaction)
        internal
        pure
        returns (bytes memory)
    {

        return
            abi.encodePacked(
                _transaction.timestamp,
                _transaction.blockNumber,
                _transaction.l1QueueOrigin,
                _transaction.l1TxOrigin,
                _transaction.entrypoint,
                _transaction.gasLimit,
                _transaction.data
            );
    }

    function hashTransaction(Transaction memory _transaction) internal pure returns (bytes32) {

        return keccak256(encodeTransaction(_transaction));
    }

    function decodeEVMAccount(bytes memory _encoded) internal pure returns (EVMAccount memory) {

        Lib_RLPReader.RLPItem[] memory accountState = Lib_RLPReader.readList(_encoded);

        return
            EVMAccount({
                nonce: Lib_RLPReader.readUint256(accountState[0]),
                balance: Lib_RLPReader.readUint256(accountState[1]),
                storageRoot: Lib_RLPReader.readBytes32(accountState[2]),
                codeHash: Lib_RLPReader.readBytes32(accountState[3])
            });
    }

    function hashBatchHeader(Lib_OVMCodec.ChainBatchHeader memory _batchHeader)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encode(
                    _batchHeader.batchRoot,
                    _batchHeader.batchSize,
                    _batchHeader.prevTotalElements,
                    _batchHeader.extraData
                )
            );
    }
}



pragma solidity ^0.8.9;

library Lib_MerkleTree {


    function getMerkleRoot(bytes32[] memory _elements) internal pure returns (bytes32) {

        require(_elements.length > 0, "Lib_MerkleTree: Must provide at least one leaf hash.");

        if (_elements.length == 1) {
            return _elements[0];
        }

        uint256[16] memory defaults = [
            0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563,
            0x633dc4d7da7256660a892f8f1604a44b5432649cc8ec5cb3ced4c4e6ac94dd1d,
            0x890740a8eb06ce9be422cb8da5cdafc2b58c0a5e24036c578de2a433c828ff7d,
            0x3b8ec09e026fdc305365dfc94e189a81b38c7597b3d941c279f042e8206e0bd8,
            0xecd50eee38e386bd62be9bedb990706951b65fe053bd9d8a521af753d139e2da,
            0xdefff6d330bb5403f63b14f33b578274160de3a50df4efecf0e0db73bcdd3da5,
            0x617bdd11f7c0a11f49db22f629387a12da7596f9d1704d7465177c63d88ec7d7,
            0x292c23a9aa1d8bea7e2435e555a4a60e379a5a35f3f452bae60121073fb6eead,
            0xe1cea92ed99acdcb045a6726b2f87107e8a61620a232cf4d7d5b5766b3952e10,
            0x7ad66c0a68c72cb89e4fb4303841966e4062a76ab97451e3b9fb526a5ceb7f82,
            0xe026cc5a4aed3c22a58cbd3d2ac754c9352c5436f638042dca99034e83636516,
            0x3d04cffd8b46a874edf5cfae63077de85f849a660426697b06a829c70dd1409c,
            0xad676aa337a485e4728a0b240d92b3ef7b3c372d06d189322bfd5f61f1e7203e,
            0xa2fca4a49658f9fab7aa63289c91b7c7b6c832a6d0e69334ff5b0a3483d09dab,
            0x4ebfd9cd7bca2505f7bef59cc1c12ecc708fff26ae4af19abe852afe9e20c862,
            0x2def10d13dd169f550f578bda343d9717a138562e0093b380a1120789d53cf10
        ];

        bytes memory buf = new bytes(64);

        bytes32 leftSibling;
        bytes32 rightSibling;

        uint256 rowSize = _elements.length;

        uint256 depth = 0;

        uint256 halfRowSize; // rowSize / 2
        bool rowSizeIsOdd; // rowSize % 2 == 1

        while (rowSize > 1) {
            halfRowSize = rowSize / 2;
            rowSizeIsOdd = rowSize % 2 == 1;

            for (uint256 i = 0; i < halfRowSize; i++) {
                leftSibling = _elements[(2 * i)];
                rightSibling = _elements[(2 * i) + 1];
                assembly {
                    mstore(add(buf, 32), leftSibling)
                    mstore(add(buf, 64), rightSibling)
                }

                _elements[i] = keccak256(buf);
            }

            if (rowSizeIsOdd) {
                leftSibling = _elements[rowSize - 1];
                rightSibling = bytes32(defaults[depth]);
                assembly {
                    mstore(add(buf, 32), leftSibling)
                    mstore(add(buf, 64), rightSibling)
                }

                _elements[halfRowSize] = keccak256(buf);
            }

            rowSize = halfRowSize + (rowSizeIsOdd ? 1 : 0);
            depth++;
        }

        return _elements[0];
    }

    function verify(
        bytes32 _root,
        bytes32 _leaf,
        uint256 _index,
        bytes32[] memory _siblings,
        uint256 _totalLeaves
    ) internal pure returns (bool) {

        require(_totalLeaves > 0, "Lib_MerkleTree: Total leaves must be greater than zero.");

        require(_index < _totalLeaves, "Lib_MerkleTree: Index out of bounds.");

        require(
            _siblings.length == _ceilLog2(_totalLeaves),
            "Lib_MerkleTree: Total siblings does not correctly correspond to total leaves."
        );

        bytes32 computedRoot = _leaf;

        for (uint256 i = 0; i < _siblings.length; i++) {
            if ((_index & 1) == 1) {
                computedRoot = keccak256(abi.encodePacked(_siblings[i], computedRoot));
            } else {
                computedRoot = keccak256(abi.encodePacked(computedRoot, _siblings[i]));
            }

            _index >>= 1;
        }

        return _root == computedRoot;
    }


    function _ceilLog2(uint256 _in) private pure returns (uint256) {

        require(_in > 0, "Lib_MerkleTree: Cannot compute ceil(log_2) of 0.");

        if (_in == 1) {
            return 0;
        }

        uint256 val = _in;
        uint256 highest = 0;
        for (uint256 i = 128; i >= 1; i >>= 1) {
            if (val & (((uint256(1) << i) - 1) << i) != 0) {
                highest += i;
                val >>= i;
            }
        }

        if ((uint256(1) << highest) != _in) {
            highest += 1;
        }

        return highest;
    }
}



pragma solidity >0.5.0 <0.9.0;

interface IChainStorageContainer {


    function setGlobalMetadata(bytes27 _globalMetadata) external;


    function getGlobalMetadata() external view returns (bytes27);


    function length() external view returns (uint256);


    function push(bytes32 _object) external;


    function push(bytes32 _object, bytes27 _globalMetadata) external;


    function setByChainId(
        uint256 _chainId,
        uint256 _index,
        bytes32 _object
    )
        external;

        
    function get(uint256 _index) external view returns (bytes32);


    function deleteElementsAfterInclusive(uint256 _index) external;


    function deleteElementsAfterInclusive(uint256 _index, bytes27 _globalMetadata) external;


    function setGlobalMetadataByChainId(
        uint256 _chainId,
        bytes27 _globalMetadata
    )
        external;


    function getGlobalMetadataByChainId(
        uint256 _chainId
        )
        external
        view
        returns (
            bytes27
        );


    function lengthByChainId(
        uint256 _chainId
        )
        external
        view
        returns (
            uint256
        );


    function pushByChainId(
        uint256 _chainId,
        bytes32 _object
    )
        external;


    function pushByChainId(
        uint256 _chainId,
        bytes32 _object,
        bytes27 _globalMetadata
    )
        external;


    function getByChainId(
        uint256 _chainId,
        uint256 _index
    )
        external
        view
        returns (
            bytes32
        );


    function deleteElementsAfterInclusiveByChainId(
        uint256 _chainId,
        uint256 _index
    )
        external;

        
    function deleteElementsAfterInclusiveByChainId(
        uint256 _chainId,
        uint256 _index,
        bytes27 _globalMetadata
    )
        external;

        
}






interface IStateCommitmentChain {


    event StateBatchAppended(
        uint256 _chainId,
        uint256 indexed _batchIndex,
        bytes32 _batchRoot,
        uint256 _batchSize,
        uint256 _prevTotalElements,
        bytes _extraData
    );

    event StateBatchDeleted(
        uint256 _chainId,
        uint256 indexed _batchIndex,
        bytes32 _batchRoot
    );


    
    function batches() external view returns (IChainStorageContainer);

    
    function getTotalElements() external view returns (uint256 _totalElements);


    function getTotalBatches() external view returns (uint256 _totalBatches);


    function getLastSequencerTimestamp() external view returns (uint256 _lastSequencerTimestamp);


    function appendStateBatch(bytes32[] calldata _batch, uint256 _shouldStartAtElement) external;


    function deleteStateBatch(Lib_OVMCodec.ChainBatchHeader memory _batchHeader) external;


    function verifyStateCommitment(
        bytes32 _element,
        Lib_OVMCodec.ChainBatchHeader memory _batchHeader,
        Lib_OVMCodec.ChainInclusionProof memory _proof
    ) external view returns (bool _verified);


    function insideFraudProofWindow(Lib_OVMCodec.ChainBatchHeader memory _batchHeader)
        external
        view
        returns (
            bool _inside
        );

        
        
        

    function getTotalElementsByChainId(uint256 _chainId)
        external
        view
        returns (
            uint256 _totalElements
        );


    function getTotalBatchesByChainId(uint256 _chainId)
        external
        view
        returns (
            uint256 _totalBatches
        );


    function getLastSequencerTimestampByChainId(uint256 _chainId)
        external
        view
        returns (
            uint256 _lastSequencerTimestamp
        );

        
    function appendStateBatchByChainId(
        uint256 _chainId,
        bytes32[] calldata _batch,
        uint256 _shouldStartAtElement,
        string calldata proposer
    )
        external;


    function deleteStateBatchByChainId(
        uint256 _chainId,
        Lib_OVMCodec.ChainBatchHeader memory _batchHeader
    )
        external;


    function verifyStateCommitmentByChainId(
        uint256 _chainId,
        bytes32 _element,
        Lib_OVMCodec.ChainBatchHeader memory _batchHeader,
        Lib_OVMCodec.ChainInclusionProof memory _proof
    )
        external
        view
        returns (
            bool _verified
        );


    function insideFraudProofWindowByChainId(
        uint256 _chainId,
        Lib_OVMCodec.ChainBatchHeader memory _batchHeader
    )
        external
        view
        returns (
            bool _inside
        );

}



pragma solidity ^0.8.9;







contract MVM_Verifier is Lib_AddressResolver{

    address public metis;

    enum SETTLEMENT {NOT_ENOUGH_VERIFIER, SAME_ROOT, AGREE, DISAGREE, PASS}

    event NewChallenge(uint256 cIndex, uint256 chainID, Lib_OVMCodec.ChainBatchHeader header, uint256 timestamp);
    event Verify1(uint256 cIndex, address verifier);
    event Verify2(uint256 cIndex, address verifier);
    event Finalize(uint256 cIndex, address sender, SETTLEMENT result);
    event Penalize(address sender, uint256 stakeLost);
    event Reward(address target, uint256 amount);
    event Claim(address sender, uint256 amount);
    event Withdraw(address sender, uint256 amount);
    event Stake(address verifier, uint256 amount);
    event SlashSequencer(uint256 chainID, address seq);

    string constant public CONFIG_OWNER_KEY = "METIS_MANAGER";

    struct Challenge {
       address challenger;
       uint256 chainID;
       uint256 index;
       Lib_OVMCodec.ChainBatchHeader header;
       uint256 timestamp;
       uint256 numQualifiedVerifiers;
       uint256 numVerifiers;
       address[] verifiers;
       bool done;
    }

    mapping (address => uint256) public verifier_stakes;
    mapping (uint256 => mapping (address=>bytes)) private challenge_keys;
    mapping (uint256 => mapping (address=>bytes)) private challenge_key_hashes;
    mapping (uint256 => mapping (address=>bytes)) private challenge_hashes;

    mapping (address => uint256) public rewards;
    mapping (address => uint8) public absence_strikes;
    mapping (address => uint8) public consensus_strikes;

    mapping (uint256 => uint256) public chain_under_challenge;

    mapping (address => bool) public whitelist;
    bool useWhiteList;

    address[] public verifiers;
    Challenge[] public challenges;

    uint public verifyWindow = 3600 * 24; // 24 hours of window to complete the each verify phase
    uint public activeChallenges;

    uint256 public minStake;
    uint256 public seqStake;

    uint256 public numQualifiedVerifiers;

    uint FAIL_THRESHOLD = 2;  // 1 time grace
    uint ABSENCE_THRESHOLD = 4;  // 2 times grace

    modifier onlyManager {

        require(
            msg.sender == resolve(CONFIG_OWNER_KEY),
            "MVM_Verifier: Function can only be called by the METIS_MANAGER."
        );
        _;
    }

    modifier onlyWhitelisted {

        require(isWhiteListed(msg.sender), "only whitelisted verifiers can call");
        _;
    }

    modifier onlyStaked {

        require(isSufficientlyStaked(msg.sender), "insufficient stake");
        _;
    }

    constructor(
    )
      Lib_AddressResolver(address(0))
    {
    }

    function verifierStake(uint256 stake) public onlyWhitelisted{

       require(activeChallenges == 0, "stake is currently prohibited"); //ongoing challenge
       require(stake > 0, "zero stake not allowed");
       require(IERC20(metis).transferFrom(msg.sender, address(this), stake), "transfer metis failed");

       uint256 previousBalance = verifier_stakes[msg.sender];
       verifier_stakes[msg.sender] += stake;

       require(isSufficientlyStaked(msg.sender), "insufficient stake to qualify as a verifier");

       if (previousBalance == 0) {
          numQualifiedVerifiers++;
          verifiers.push(msg.sender);
       }

       emit Stake(msg.sender, stake);
    }

    function newChallenge(uint256 chainID, Lib_OVMCodec.ChainBatchHeader calldata header, bytes calldata proposedHash, bytes calldata keyhash)
       public onlyWhitelisted onlyStaked {


       uint tempIndex = chain_under_challenge[chainID] - 1;
       require(tempIndex == 0 || block.timestamp - challenges[tempIndex].timestamp > verifyWindow * 2, "there is an ongoing challenge");
       if (tempIndex > 0) {
          finalize(tempIndex);
       }
       IStateCommitmentChain stateChain = IStateCommitmentChain(resolve("StateCommitmentChain"));

       require(stateChain.insideFraudProofWindow(header), "the batch is outside of the fraud proof window");

       Challenge memory c;
       c.chainID = chainID;
       c.challenger = msg.sender;
       c.timestamp = block.timestamp;
       c.header = header;

       challenges.push(c);
       uint cIndex = challenges.length - 1;

       challenge_hashes[cIndex][msg.sender] = proposedHash;
       challenge_key_hashes[cIndex][msg.sender] = keyhash;
       challenges[cIndex].numVerifiers++; // the challenger

       activeChallenges++;

       chain_under_challenge[chainID] = cIndex + 1; // +1 because 0 means no in-progress challenge
       emit NewChallenge(cIndex, chainID, header, block.timestamp);
    }

    function verify1(uint256 cIndex, bytes calldata hash, bytes calldata keyhash) public onlyWhitelisted onlyStaked{

       require(challenge_hashes[cIndex][msg.sender].length == 0, "verify1 already completed for the sender");
       challenge_hashes[cIndex][msg.sender] = hash;
       challenge_key_hashes[cIndex][msg.sender] = keyhash;
       challenges[cIndex].numVerifiers++;
       emit Verify1(cIndex, msg.sender);
    }

    function verify2(uint256 cIndex, bytes calldata key) public onlyStaked onlyWhitelisted{

        require(challenges[cIndex].numVerifiers == numQualifiedVerifiers
               || block.timestamp - challenges[cIndex].timestamp > verifyWindow, "phase 2 not ready");
        require(challenge_hashes[cIndex][msg.sender].length > 0, "you didn't participate in phase 1");
        if (challenge_keys[cIndex][msg.sender].length > 0) {
            finalize(cIndex);
            return;
        }

        require(sha256(key) == bytes32(challenge_key_hashes[cIndex][msg.sender]), "key and keyhash don't match");

        if (msg.sender == challenges[cIndex].challenger) {
            challenges[cIndex].header.batchRoot = bytes32(decrypt(abi.encodePacked(challenges[cIndex].header.batchRoot), key));
        }
        challenge_keys[cIndex][msg.sender] = key;
        challenge_hashes[cIndex][msg.sender] = decrypt(challenge_hashes[cIndex][msg.sender], key);
        challenges[cIndex].verifiers.push(msg.sender);
        emit Verify2(cIndex, msg.sender);

        finalize(cIndex);
    }

    function finalize(uint256 cIndex) internal {


        Challenge storage challenge = challenges[cIndex];

        require(challenge.done == false, "challenge is closed");

        if (challenge.verifiers.length != challenge.numVerifiers
           && block.timestamp - challenge.timestamp < verifyWindow * 2) {
           return;
        }

        IStateCommitmentChain stateChain = IStateCommitmentChain(resolve("StateCommitmentChain"));
        bytes32 proposedHash = bytes32(challenge_hashes[cIndex][challenge.challenger]);

        uint reward = 0;

        address[] memory agrees = new address[](challenge.verifiers.length);
        uint numAgrees = 0;
        address[] memory disagrees = new address[](challenge.verifiers.length);
        uint numDisagrees = 0;

        for (uint256 i = 0; i < verifiers.length; i++) {
            if (!isSufficientlyStaked(verifiers[i]) || !isWhiteListed(verifiers[i])) {
                continue;
            }

            if (bytes32(challenge_hashes[cIndex][verifiers[i]]) == proposedHash) {
                if (absence_strikes[verifiers[i]] > 0) {
                    absence_strikes[verifiers[i]] -= 1; // slowly clear the strike
                }
                agrees[numAgrees] = verifiers[i];
                numAgrees++;
            } else if (challenge_keys[cIndex][verifiers[i]].length == 0) {
                absence_strikes[verifiers[i]] += 2;
                if (absence_strikes[verifiers[i]] > ABSENCE_THRESHOLD) {
                    reward += penalize(verifiers[i]);
                }
            } else {
                if (absence_strikes[verifiers[i]] > 0) {
                    absence_strikes[verifiers[i]] -= 1; // slowly clear the strike
                }
                disagrees[numDisagrees] = verifiers[i];
                numDisagrees++;
            }
        }

        if (Lib_OVMCodec.hashBatchHeader(challenge.header) !=
                stateChain.batches().getByChainId(challenge.chainID, challenge.header.batchIndex)) {
            reward += penalize(challenge.challenger);

            distributeReward(reward, disagrees, challenge.verifiers.length - 1);
            emit Finalize(cIndex, msg.sender, SETTLEMENT.DISAGREE);

        } else if (challenge.verifiers.length < numQualifiedVerifiers * 75 / 100) {
            emit Finalize(cIndex, msg.sender, SETTLEMENT.NOT_ENOUGH_VERIFIER);
        }
        else if (proposedHash != challenge.header.batchRoot) {
            if (numAgrees <= numDisagrees) {
               for (uint i = 0; i < numAgrees; i++) {
                    consensus_strikes[agrees[i]] += 2;
                    if (consensus_strikes[agrees[i]] > FAIL_THRESHOLD) {
                        reward += penalize(agrees[i]);
                    }
               }
               distributeReward(reward, disagrees, disagrees.length);
               emit Finalize(cIndex, msg.sender, SETTLEMENT.DISAGREE);
            } else {
               if(stateChain.insideFraudProofWindow(challenge.header)) {
                    stateChain.deleteStateBatchByChainId(challenge.chainID, challenge.header);

                    if (seqStake > 0) {
                        reward += seqStake;

                        for (uint i = 0; i < numDisagrees; i++) {
                            consensus_strikes[disagrees[i]] += 2;
                            if (consensus_strikes[disagrees[i]] > FAIL_THRESHOLD) {
                                reward += penalize(disagrees[i]);
                            }
                        }
                        distributeReward(reward, agrees, agrees.length);
                    }
                    emit Finalize(cIndex, msg.sender, SETTLEMENT.AGREE);
                } else {
                    emit Finalize(cIndex, msg.sender, SETTLEMENT.PASS);
                }
            }
        } else {
            consensus_strikes[challenge.challenger] += 2;
            if (consensus_strikes[challenge.challenger] > FAIL_THRESHOLD) {
                reward += penalize(challenge.challenger);
            }
            distributeReward(reward, challenge.verifiers, challenge.verifiers.length - 1);
            emit Finalize(cIndex, msg.sender, SETTLEMENT.SAME_ROOT);
        }

        challenge.done = true;
        activeChallenges--;
        chain_under_challenge[challenge.chainID] = 0;
    }

    function depositSeqStake(uint256 amount) public onlyManager {

        require(IERC20(metis).transferFrom(msg.sender, address(this), amount), "transfer metis failed");
        seqStake += amount;
        emit Stake(msg.sender, amount);
    }

    function withdrawSeqStake(address to) public onlyManager {

        require(seqStake > 0, "no stake");
        emit Withdraw(msg.sender, seqStake);
        uint256 amount = seqStake;
        seqStake = 0;

        require(IERC20(metis).transfer(to, amount), "transfer metis failed");
    }

    function claim() public {

       require(rewards[msg.sender] > 0, "no reward to claim");
       uint256 amount = rewards[msg.sender];
       rewards[msg.sender] = 0;

       require(IERC20(metis).transfer(msg.sender, amount), "token transfer failed");

       emit Claim(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {

       require(activeChallenges == 0, "withdraw is currently prohibited"); //ongoing challenge

       uint256 balance = verifier_stakes[msg.sender];
       require(balance >= amount, "insufficient stake to withdraw");

       if (balance - amount < minStake && balance >= minStake) {
           numQualifiedVerifiers--;
           deleteVerifier(msg.sender);
       }
       verifier_stakes[msg.sender] -= amount;

       require(IERC20(metis).transfer(msg.sender, amount), "token transfer failed");
    }

    function setMinStake(
        uint256 _minStake
    )
        public
        onlyManager
    {

        minStake = _minStake;
        uint num = 0;
        if (verifiers.length > 0) {
            address[] memory arr = new address[](verifiers.length);
            for (uint i = 0; i < verifiers.length; ++i) {
                if (verifier_stakes[verifiers[i]] >= minStake) {
                    arr[num] = verifiers[i];
                    num++;
                }
            }
            if (num < verifiers.length) {
                delete verifiers;
                for (uint i = 0; i < num; i++) {
                    verifiers.push(arr[i]);
                }
            }
        }
        numQualifiedVerifiers = num;
    }

    function isWhiteListed(address verifier) view public returns(bool){

        return !useWhiteList || whitelist[verifier];
    }
    function isSufficientlyStaked (address target) view public returns(bool) {
       return (verifier_stakes[target] >= minStake);
    }

    function setVerifyWindow (uint256 window) onlyManager public {
        verifyWindow = window;
    }

    function setWhiteList(address verifier, bool allowed) public onlyManager {

        whitelist[verifier] = allowed;
        useWhiteList = true;
    }

    function disableWhiteList() public onlyManager {

        useWhiteList = false;
    }

    function setThreshold(uint absence_threshold, uint fail_threshold) public onlyManager {

        ABSENCE_THRESHOLD = absence_threshold;
        FAIL_THRESHOLD = fail_threshold;
    }

    function getMerkleRoot(bytes32[] calldata elements) pure public returns (bytes32) {

        return Lib_MerkleTree.getMerkleRoot(elements);
    }

    function encrypt(bytes calldata data, bytes calldata key) pure public returns (bytes memory) {

      bytes memory encryptedData = data;
      uint j = 0;

      for (uint i = 0; i < encryptedData.length; i++) {
          if (j == key.length) {
             j = 0;
          }
          encryptedData[i] = encryptByte(encryptedData[i], uint8(key[j]));
          j++;
      }

      return encryptedData;
    }

    function encryptByte(bytes1 b, uint8 k) pure internal returns (bytes1) {

      uint16 temp16 = uint16(uint8(b));
      temp16 += k;

      if (temp16 > 255) {
         temp16 -= 256;
      }
      return bytes1(uint8(temp16));
    }

    function decrypt(bytes memory data, bytes memory key) pure public returns (bytes memory) {

      bytes memory decryptedData = data;
      uint j = 0;

      for (uint i = 0; i < decryptedData.length; i++) {
          if (j == key.length) {
             j = 0;
          }

          decryptedData[i] = decryptByte(decryptedData[i], uint8(key[j]));

          j++;
      }

      return decryptedData;
    }

    function decryptByte(bytes1 b, uint8 k) pure internal returns (bytes1) {

      uint16 temp16 = uint16(uint8(b));
      if (temp16 > k) {
         temp16 -= k;
      } else {
         temp16 = 256 - k;
      }

      return bytes1(uint8(temp16));
    }

    function distributeReward(uint256 amount, address[] memory list, uint num) internal {

        uint reward = amount / num;
        if (reward == 0) {
            return;
        }
        uint total = 0;
        for (uint i; i < list.length; i++) {
            if (isSufficientlyStaked(list[i])) {
               rewards[list[i]] += reward;
               total += reward;
               emit Reward(list[i], reward);
            }
        }

        if (total < amount) {
            if (isSufficientlyStaked(list[0])) {
                rewards[list[0]] += total - amount;
                emit Reward(list[0], total - amount);
            } else {
                rewards[list[1]] += total - amount;
                emit Reward(list[1], total - amount);
            }
        }
    }

    function penalize(address target) internal returns(uint256) {

        uint256 stake = verifier_stakes[target];
        verifier_stakes[target] = 0;
        numQualifiedVerifiers--;
        deleteVerifier(target);
        emit Penalize(target, stake);

        return stake;
    }

    function deleteVerifier(address target) internal {

        bool hasVerifier = false;
        uint pos = 0;
        for (uint i = 0; i < verifiers.length; i++){
            if (verifiers[i] == target) {
                hasVerifier = true;
                pos = i;
                break;
            }
        }
        if (hasVerifier) {
            for (uint i = pos; i < verifiers.length-1; i++) {
                verifiers[i] = verifiers[i+1];
            }
            verifiers.pop();
        }
    }

}