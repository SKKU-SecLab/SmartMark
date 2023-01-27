

pragma solidity ^0.5.13;

interface SyscoinSuperblocksI {


    enum Status { Uninitialized, New, InBattle, SemiApproved, Approved, Invalid }
    struct SuperblockInfo {
        bytes32 blocksMerkleRoot;
        uint timestamp;
        uint mtpTimestamp;
        bytes32 lastHash;
        bytes32 parentId;
        address submitter;
        uint32 lastBits;
        uint32 height;
        Status status;
    }
    function propose(
        bytes32 _blocksMerkleRoot,
        uint _timestamp,
        uint _mtpTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        address submitter
    ) external returns (uint, bytes32);


    function getSuperblock(bytes32 superblockHash) external view returns (
        bytes32 _blocksMerkleRoot,
        uint _timestamp,
        uint _mtpTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        address _submitter,
        Status _status,
        uint32 _height
    );


    function relayTx(
        bytes calldata _txBytes,
        uint _txIndex,
        uint[] calldata _txSiblings,
        bytes calldata _syscoinBlockHeader,
        uint _syscoinBlockIndex,
        uint[] calldata _syscoinBlockSiblings,
        bytes32 _superblockHash
    ) external returns (uint);


    function confirm(bytes32 _superblockHash, address _validator) external returns (uint);

    function challenge(bytes32 _superblockHash, address _challenger) external returns (uint);

    function semiApprove(bytes32 _superblockHash, address _validator) external returns (uint);

    function invalidate(bytes32 _superblockHash, address _validator) external returns (uint);

    function getBestSuperblock() external view returns (bytes32);

    function getChainHeight() external view returns (uint);

    function getSuperblockHeight(bytes32 superblockHash) external view returns (uint32);

    function getSuperblockParentId(bytes32 _superblockHash) external view returns (bytes32);

    function getSuperblockStatus(bytes32 _superblockHash) external view returns (Status);

    function getSuperblockAt(uint _height) external view returns (bytes32);

    function getSuperblockTimestamp(bytes32 _superblockHash) external view returns (uint);

    function getSuperblockMedianTimestamp(bytes32 _superblockHash) external view returns (uint);


    function relayAssetTx(
        bytes calldata _txBytes,
        uint _txIndex,
        uint[] calldata _txSiblings,
        bytes calldata _syscoinBlockHeader,
        uint _syscoinBlockIndex,
        uint[] calldata _syscoinBlockSiblings,
        bytes32 _superblockHash
    ) external returns (uint);

}


pragma solidity ^0.5.13;

contract SyscoinErrorCodes {

    uint constant ERR_INVALID_HEADER = 10050;
    uint constant ERR_COINBASE_INDEX = 10060; // coinbase tx index within Bitcoin merkle isn't 0
    uint constant ERR_NOT_MERGE_MINED = 10070; // trying to check AuxPoW on a block that wasn't merge mined
    uint constant ERR_FOUND_TWICE = 10080; // 0xfabe6d6d found twice
    uint constant ERR_NO_MERGE_HEADER = 10090; // 0xfabe6d6d not found
    uint constant ERR_CHAIN_MERKLE = 10110;
    uint constant ERR_PARENT_MERKLE = 10120;
    uint constant ERR_PROOF_OF_WORK = 10130;
    uint constant ERR_INVALID_HEADER_HASH = 10140;
    uint constant ERR_PROOF_OF_WORK_AUXPOW = 10150;
    uint constant ERR_PARSE_TX_OUTPUT_LENGTH = 10160;


    uint constant ERR_SUPERBLOCK_OK = 0;
    uint constant ERR_SUPERBLOCK_MISSING_BLOCKS = 1;
    uint constant ERR_SUPERBLOCK_BAD_STATUS = 50020;
    uint constant ERR_SUPERBLOCK_BAD_SYSCOIN_STATUS = 50025;
    uint constant ERR_SUPERBLOCK_TIMEOUT = 50026;
    uint constant ERR_SUPERBLOCK_NO_TIMEOUT = 50030;
    uint constant ERR_SUPERBLOCK_BAD_TIMESTAMP = 50035;
    uint constant ERR_SUPERBLOCK_INVALID_TIMESTAMP = 50036;
    uint constant ERR_SUPERBLOCK_INVALID_MERKLE = 50038;

    uint constant ERR_SUPERBLOCK_BAD_PARENT = 50040;
    uint constant ERR_SUPERBLOCK_BAD_PARENT_UNINITIALIZED = 50040;
    uint constant ERR_SUPERBLOCK_BAD_PARENT_NEW = 50041;
    uint constant ERR_SUPERBLOCK_BAD_PARENT_INBATTLE = 50042;
    uint constant ERR_SUPERBLOCK_BAD_PARENT_INVALID = 50045;

    uint constant ERR_SUPERBLOCK_OWN_CHALLENGE = 50055;
    uint constant ERR_SUPERBLOCK_BAD_PREV_TIMESTAMP = 50056;
    uint constant ERR_SUPERBLOCK_BITS_SUPERBLOCK = 50057;
    uint constant ERR_SUPERBLOCK_BITS_PREVBLOCK = 50058;
    uint constant ERR_SUPERBLOCK_HASH_SUPERBLOCK = 50059;
    uint constant ERR_SUPERBLOCK_HASH_PREVBLOCK = 50060;
    uint constant ERR_SUPERBLOCK_HASH_PREVSUPERBLOCK = 50061;
    uint constant ERR_SUPERBLOCK_MAX_INPROGRESS = 50062;
    uint constant ERR_SUPERBLOCK_BITS_LASTBLOCK = 50064;
    uint constant ERR_SUPERBLOCK_MIN_DEPOSIT = 50065;
    uint constant ERR_SUPERBLOCK_BITS_INTERIM_PREVBLOCK = 50066;
    uint constant ERR_SUPERBLOCK_HASH_INTERIM_PREVBLOCK = 50067;
    uint constant ERR_SUPERBLOCK_BAD_TIMESTAMP_AVERAGE = 50068;
    uint constant ERR_SUPERBLOCK_BAD_TIMESTAMP_MTP = 50069;

    uint constant ERR_SUPERBLOCK_NOT_CLAIMMANAGER = 50070;
    uint constant ERR_SUPERBLOCK_MISMATCH_TIMESTAMP_MTP = 50071;
    uint constant ERR_SUPERBLOCK_TOOSMALL_TIMESTAMP_MTP = 50072;

    uint constant ERR_SUPERBLOCK_BAD_CLAIM = 50080;
    uint constant ERR_SUPERBLOCK_VERIFICATION_PENDING = 50090;
    uint constant ERR_SUPERBLOCK_CLAIM_DECIDED = 50100;
    uint constant ERR_SUPERBLOCK_CHALLENGE_EXISTS = 50110;

    uint constant ERR_SUPERBLOCK_BAD_ACCUMULATED_WORK = 50120;
    uint constant ERR_SUPERBLOCK_BAD_BITS = 50130;
    uint constant ERR_SUPERBLOCK_MISSING_CONFIRMATIONS = 50140;
    uint constant ERR_SUPERBLOCK_BAD_LASTBLOCK = 50150;
    uint constant ERR_SUPERBLOCK_BAD_LASTBLOCK_STATUS = 50160;
    uint constant ERR_SUPERBLOCK_BAD_BLOCKHEIGHT = 50170;
    uint constant ERR_SUPERBLOCK_BAD_PREVBLOCK = 50190;
    uint constant ERR_SUPERBLOCK_CLAIM_ALREADY_DEFENDED = 50200;
    uint constant ERR_SUPERBLOCK_BAD_MISMATCH = 50210;
    uint constant ERR_SUPERBLOCK_INTERIMBLOCK_MISSING = 50220;
    uint constant ERR_SUPERBLOCK_BAD_INTERIM_PREVHASH = 50230;
    uint constant ERR_SUPERBLOCK_BAD_INTERIM_BLOCKINDEX = 50240;


    uint constant ERR_BAD_FEE = 20010;
    uint constant ERR_CONFIRMATIONS = 20020;
    uint constant ERR_CHAIN = 20030;
    uint constant ERR_SUPERBLOCK = 20040;
    uint constant ERR_MERKLE_ROOT = 20050;
    uint constant ERR_TX_64BYTE = 20060;
    uint constant ERR_SUPERBLOCK_MERKLE_ROOT = 20070;
    uint constant ERR_RELAY_VERIFY = 30010;
    uint constant ERR_CANCEL_TRANSFER_VERIFY = 30020;
    uint constant public minProposalDeposit = 3000000000000000000;
}


pragma solidity ^0.5.13;

interface SyscoinTransactionProcessor {

    function processTransaction(uint txHash, uint value, address destinationAddress, address superblockSubmitterAddress, address erc20ContractAddress, uint32 assetGUID, uint8 precision) external;

    function freezeBurnERC20(uint value, uint32 assetGUID, address erc20ContractAddress, uint8 precision, bytes calldata syscoinAddress) external returns (bool);

    function cancelTransferRequest(uint32 bridgeTransferId) external;

    function cancelTransferSuccess(uint32 bridgeTransferId, address challengerAddress) external;

    function processCancelTransferFail(uint32 bridgeTransferId, address payable challengerAddress) external;

    function processAsset(uint txHash, uint32 assetGUID, uint32 height, address erc20ContractAddress) external;

}


pragma solidity >=0.4.24 <0.6.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

library RLPReader {

    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START  = 0xb8;
    uint8 constant LIST_SHORT_START   = 0xc0;
    uint8 constant LIST_LONG_START    = 0xf8;
    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint len;
        uint memPtr;
    }

    struct Iterator {
        RLPItem item;   // Item that's being iterated over.
        uint nextPtr;   // Position of the next item in the list.
    }

    function next(Iterator memory self) internal pure returns (RLPItem memory) {

        require(hasNext(self));

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

        return RLPItem(item.length, memPtr);
    }

    function iterator(RLPItem memory self) internal pure returns (Iterator memory) {

        require(isList(self));

        uint ptr = self.memPtr + _payloadOffset(self.memPtr);
        return Iterator(self, ptr);
    }

    function rlpLen(RLPItem memory item) internal pure returns (uint) {

        return item.len;
    }

    function payloadLen(RLPItem memory item) internal pure returns (uint) {

        return item.len - _payloadOffset(item.memPtr);
    }

    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory) {

        require(isList(item));

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

    function isList(RLPItem memory item) internal pure returns (bool) {

        if (item.len == 0) return false;

        uint8 byte0;
        uint memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START)
            return false;
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

        require(item.len == 1);
        uint result;
        uint memPtr = item.memPtr;
        assembly {
            result := byte(0, mload(memPtr))
        }

        return result == 0 ? false : true;
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {

        require(item.len == 21);

        return address(toUint(item));
    }

    function toUint(RLPItem memory item) internal pure returns (uint) {

        require(item.len > 0 && item.len <= 33);

        uint offset = _payloadOffset(item.memPtr);
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

        require(item.len == 33);

        uint result;
        uint memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {

        require(item.len > 0);

        uint offset = _payloadOffset(item.memPtr);
        uint len = item.len - offset; // data length
        bytes memory result = new bytes(len);

        uint destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(item.memPtr + offset, destPtr, len);
        return result;
    }


    function numItems(RLPItem memory item) private pure returns (uint) {

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

        if (byte0 < STRING_SHORT_START)
            itemLen = 1;
        
        else if (byte0 < STRING_LONG_START)
            itemLen = byte0 - STRING_SHORT_START + 1;

        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte
                
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } 

        else {
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

        if (byte0 < STRING_SHORT_START) 
            return 0;
        else if (byte0 < STRING_LONG_START || (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START))
            return 1;
        else if (byte0 < LIST_SHORT_START)  // being explicit
            return byte0 - (STRING_LONG_START - 1) + 1;
        else
            return byte0 - (LIST_LONG_START - 1) + 1;
    }

    function copy(uint src, uint dest, uint len) private pure {

        if (len == 0) return;

        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        uint mask = 256 ** (WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }
}


pragma solidity ^0.5.13;


contract SyscoinMessageLibrary {


    using RLPReader for RLPReader.RLPItem;
    using RLPReader for bytes;

    uint constant ERR_PARSE_TX_SYS = 10170;
    enum Network { MAINNET, TESTNET, REGTEST }
    uint32 constant SYSCOIN_TX_VERSION_ALLOCATION_BURN_TO_ETHEREUM = 0x7407;

    function parseVarInt(bytes memory txBytes, uint pos) public pure returns (uint, uint) {

        uint8 ibit = uint8(txBytes[pos]);
        pos += 1;  // skip ibit

        if (ibit < 0xfd) {
            return (ibit, pos);
        } else if (ibit == 0xfd) {
            return (getBytesLE(txBytes, pos, 16), pos + 2);
        } else if (ibit == 0xfe) {
            return (getBytesLE(txBytes, pos, 32), pos + 4);
        } else if (ibit == 0xff) {
            return (getBytesLE(txBytes, pos, 64), pos + 8);
        }
    }

    function getBytesLE(bytes memory data, uint pos, uint bits)
        public
        pure
        returns (uint256 result)
    {

        for (uint256 i = 0; i < bits / 8; i++) {
            result += uint256(uint8(data[pos + i])) * 2 ** (i * 8);
        }
    }

    function bytesToUint32Flipped(bytes memory input, uint pos)
        public
        pure
        returns (uint32 result)
    {

        assembly {
            let data := mload(add(add(input, 0x20), pos))
            let flip := mload(0x40)
            mstore8(add(flip, 0), byte(3, data))
            mstore8(add(flip, 1), byte(2, data))
            mstore8(add(flip, 2), byte(1, data))
            mstore8(add(flip, 3), byte(0, data))
            result := shr(mul(8, 28), mload(flip))
        }
    }

    function flip32Bytes(uint _input) public pure returns (uint result) {

        assembly {
            let pos := mload(0x40)
            mstore8(add(pos, 0), byte(31, _input))
            mstore8(add(pos, 1), byte(30, _input))
            mstore8(add(pos, 2), byte(29, _input))
            mstore8(add(pos, 3), byte(28, _input))
            mstore8(add(pos, 4), byte(27, _input))
            mstore8(add(pos, 5), byte(26, _input))
            mstore8(add(pos, 6), byte(25, _input))
            mstore8(add(pos, 7), byte(24, _input))
            mstore8(add(pos, 8), byte(23, _input))
            mstore8(add(pos, 9), byte(22, _input))
            mstore8(add(pos, 10), byte(21, _input))
            mstore8(add(pos, 11), byte(20, _input))
            mstore8(add(pos, 12), byte(19, _input))
            mstore8(add(pos, 13), byte(18, _input))
            mstore8(add(pos, 14), byte(17, _input))
            mstore8(add(pos, 15), byte(16, _input))
            mstore8(add(pos, 16), byte(15, _input))
            mstore8(add(pos, 17), byte(14, _input))
            mstore8(add(pos, 18), byte(13, _input))
            mstore8(add(pos, 19), byte(12, _input))
            mstore8(add(pos, 20), byte(11, _input))
            mstore8(add(pos, 21), byte(10, _input))
            mstore8(add(pos, 22), byte(9, _input))
            mstore8(add(pos, 23), byte(8, _input))
            mstore8(add(pos, 24), byte(7, _input))
            mstore8(add(pos, 25), byte(6, _input))
            mstore8(add(pos, 26), byte(5, _input))
            mstore8(add(pos, 27), byte(4, _input))
            mstore8(add(pos, 28), byte(3, _input))
            mstore8(add(pos, 29), byte(2, _input))
            mstore8(add(pos, 30), byte(1, _input))
            mstore8(add(pos, 31), byte(0, _input))
            result := mload(pos)
        }
    }
    
    function computeMerkle(uint _txHash, uint _txIndex, uint[] memory _siblings)
        public
        pure
        returns (uint)
    {

        uint length = _siblings.length;
        uint i;
        for (i = 0; i < length; i++) {
            _siblings[i] = flip32Bytes(_siblings[i]);
        }

        i = 0;
        uint resultHash = flip32Bytes(_txHash);        

        while (i < length) {
            uint proofHex = _siblings[i];

            uint left;
            uint right;
            if (_txIndex % 2 == 1) { // 0 means _siblings is on the right; 1 means left
                left = proofHex;
                right = resultHash;
            } else {
                left = resultHash;
                right = proofHex;
            }
            resultHash = uint(sha256(abi.encodePacked(sha256(abi.encodePacked(left, right)))));

            _txIndex /= 2;
            i += 1;
        }

        return flip32Bytes(resultHash);
    }

    function sliceArray(bytes memory _rawBytes, uint offset, uint _endIndex) public view returns (bytes memory) {

        uint len = _endIndex - offset;
        bytes memory result = new bytes(len);
        assembly {
            if iszero(staticcall(gas, 0x04, add(add(_rawBytes, 0x20), offset), len, add(result, 0x20), len)) {
                revert(0, 0)
            }
        }
        return result;
    }
}


pragma solidity ^0.5.13;






contract SyscoinSuperblocks is Initializable, SyscoinSuperblocksI, SyscoinErrorCodes, SyscoinMessageLibrary {


    uint constant ERR_PARSE_TX_SYS = 10170;

    uint32 constant SYSCOIN_TX_VERSION_ALLOCATION_BURN_TO_ETHEREUM = 0x7407;
    uint32 constant SYSCOIN_TX_VERSION_ALLOCATION_MINT = 0x7406;
    
    mapping (bytes32 => SuperblockInfo) internal superblocks;

    bytes32 internal bestSuperblock;

    SyscoinTransactionProcessor public syscoinERC20Manager;

    event NewSuperblock(bytes32 superblockHash, address who);
    event ApprovedSuperblock(bytes32 superblockHash, address who);
    event ChallengeSuperblock(bytes32 superblockHash, address who);
    event SemiApprovedSuperblock(bytes32 superblockHash, address who);
    event InvalidSuperblock(bytes32 superblockHash, address who);

    event ErrorSuperblock(bytes32 superblockHash, uint err);

    event VerifyTransaction(bytes32 txHash, uint returnCode);
    event RelayTransaction(bytes32 txHash, uint returnCode);
    event ChallengeCancelTransferRequest(uint returnCode);
    address public trustedClaimManager;

    uint32 constant SYSCOIN_TX_VERSION_ASSET_ACTIVATE = 0x7402;
    uint32 constant SYSCOIN_TX_VERSION_ASSET_UPDATE = 0x7403;
    modifier onlyClaimManager() {

        require(msg.sender == trustedClaimManager);
        _;
    }

    function init(address _syscoinERC20Manager, address _claimManager) public initializer {

        require(address(syscoinERC20Manager) == address(0) && _syscoinERC20Manager != address(0));
        syscoinERC20Manager = SyscoinTransactionProcessor(_syscoinERC20Manager);

        require(address(trustedClaimManager) == address(0) && _claimManager != address(0));
        trustedClaimManager = _claimManager;
    }

    function isOpReturn(bytes memory txBytes, uint pos) internal pure returns (bool) {

        return txBytes[pos] == byte(0x6a);
    }

    function bytesToUint64(bytes memory input, uint pos) public pure returns (uint64 result) {

        result = uint64(uint8(input[pos+7])) + uint64(uint8(input[pos + 6]))*(2**8) + uint64(uint8(input[pos + 5]))*(2**16) + uint64(uint8(input[pos + 4]))*(2**24) + uint64(uint8(input[pos + 3]))*(2**32) + uint64(uint8(input[pos + 2]))*(2**40) + uint64(uint8(input[pos + 1]))*(2**48) + uint64(uint8(input[pos]))*(2**56);
    }

    function bytesToUint32(bytes memory input, uint pos) public pure returns (uint32 result) {

        result = uint32(uint8(input[pos+3])) + uint32(uint8(input[pos + 2]))*(2**8) + uint32(uint8(input[pos + 1]))*(2**16) + uint32(uint8(input[pos]))*(2**24);
    }

    function scanAssetDetails(bytes memory txBytes, uint pos)
        internal
        pure
        returns (uint, address, uint32, uint8, address)
    {

        uint32 assetGUID;
        address destinationAddress;
        address erc20Address;
        uint output_value;
        uint8 precision;
        uint8 op;
        (op, pos) = getOpcode(txBytes, pos);
        require(op == 0x04);
        assetGUID = bytesToUint32(txBytes, pos);
        pos += op;
        (op, pos) = getOpcode(txBytes, pos);
        require(op == 0x08);
        output_value = bytesToUint64(txBytes, pos);
        pos += op;
        (op, pos) = getOpcode(txBytes, pos);
        require(op == 0x14);
        destinationAddress = readEthereumAddress(txBytes, pos);
        pos += op;
        (op, pos) = getOpcode(txBytes, pos);
        require(op == 0x01);
        precision = uint8(txBytes[pos]);
        pos += op;
        (op, pos) = getOpcode(txBytes, pos);
        require(op == 0x14);
        erc20Address = readEthereumAddress(txBytes, pos);
        return (output_value, destinationAddress, assetGUID, precision, erc20Address);
    }

    function readEthereumAddress(bytes memory txBytes, uint pos) internal pure returns (address) {

        uint256 data;
        assembly {
            data := mload(add(add(txBytes, 20), pos))
        }
        return address(uint160(data));
    }

    function getOpcode(bytes memory txBytes, uint pos) private pure returns (uint8, uint) {

        require(pos < txBytes.length);
        return (uint8(txBytes[pos]), pos + 1);
    }

    function getOpReturnPos(bytes memory txBytes, uint pos) public pure returns (uint) {

        uint n_inputs;
        uint script_len;
        uint output_value;
        uint n_outputs;

        (n_inputs, pos) = parseVarInt(txBytes, pos);
        if(n_inputs == 0x00){
            (n_inputs, pos) = parseVarInt(txBytes, pos); // flag
            require(n_inputs != 0x00, "#SyscoinSuperblocks getOpReturnPos(): Unexpected dummy/flag");
            (n_inputs, pos) = parseVarInt(txBytes, pos);
        }
        require(n_inputs < 100, "#SyscoinSuperblocks getOpReturnPos(): Incorrect size of n_inputs");

        for (uint i = 0; i < n_inputs; i++) {
            pos += 36;  // skip outpoint
            (script_len, pos) = parseVarInt(txBytes, pos);
            pos += script_len + 4;  // skip sig_script, seq
        }
        
        (n_outputs, pos) = parseVarInt(txBytes, pos);
        require(n_outputs < 10, "#SyscoinSuperblocks getOpReturnPos(): Incorrect size of n_outputs");
        for (uint i = 0; i < n_outputs; i++) {
            pos += 8;
            (script_len, pos) = parseVarInt(txBytes, pos);
            if(!isOpReturn(txBytes, pos)){
                pos += script_len;
                output_value = 0;
                continue;
            }
            pos += 1;
            return pos;
        }
        revert("#SyscoinSuperblocks getOpReturnPos(): No OpReturn found");
    }

    function parseMintTx(bytes memory txBytes)
        public
        view
        returns (uint errorCode, uint32 bridgeTransferId)
    {

        uint32 version;
        uint pos = 0;
        version = bytesToUint32Flipped(txBytes, pos);
        if(version != SYSCOIN_TX_VERSION_ALLOCATION_MINT){
            return (ERR_PARSE_TX_SYS, bridgeTransferId);
        }
        pos = getOpReturnPos(txBytes, 4);
        pos += 3; // skip pushdata2 + 2 bytes for opreturn varint

        bytes32 tokenFreezeTopic = 0xaabab1db49e504b5156edf3f99042aeecb9607a08f392589571cd49743aaba8d;
        bridgeTransferId = uint32(
            getBridgeTransactionId(
                getLogValuesForTopic(
                    getEthReceipt(txBytes, pos), tokenFreezeTopic
                )
            )
        );
    }


    function parseAssetTx(bytes memory txBytes)
        public
        view
        returns (uint errorCode, uint32 assetGuid, address erc20Address)
    {

        uint32 version;
        uint pos = 0;
        version = bytesToUint32Flipped(txBytes, pos);
        if(version != SYSCOIN_TX_VERSION_ASSET_ACTIVATE && version != SYSCOIN_TX_VERSION_ASSET_UPDATE){
            return (ERR_PARSE_TX_SYS, 0, address(0));
        }
        pos = getOpReturnPos(txBytes, 4);
        byte pushDataOp = txBytes[pos+1];
        pos += 2; // we will have to skip pushdata op as well as atleast 1 byte
        if(pushDataOp == 0x4d){
            pos++; // skip pushdata2 + 2 bytes for opreturn varint
        }

        (assetGuid, erc20Address) = scanAssetTx(txBytes, pos);
        require(erc20Address != address(0),
        "parseAssetTx(): erc20Address cannot be empty");
    }

    function bytesToUint16(bytes memory input, uint pos) public pure returns (uint16 result) {

        result = uint16(uint8(input[pos+1])) + uint16(uint8(input[pos]))*(2**8);
    }

    function getEthReceipt(bytes memory txBytes, uint pos)
        public
        view
        returns (bytes memory)
    {

        bytes memory ethTxReceipt = new bytes(0);
        uint bytesToRead;
        (bytesToRead, pos) = parseVarInt(txBytes, pos);
        pos += bytesToRead;
        (bytesToRead, pos) = parseVarInt(txBytes, pos);
        pos += bytesToRead;
        (bytesToRead, pos) = parseVarInt(txBytes, pos);
        pos += bytesToRead;
        (bytesToRead, pos) = parseVarInt(txBytes, pos);
        pos += bytesToRead;
        (bytesToRead, pos) = parseVarInt(txBytes, pos);
        if(bytesToRead == 2){
            uint16 positionOfValue = bytesToUint16(txBytes, pos);
            pos += bytesToRead;
            (bytesToRead, pos) = parseVarInt(txBytes, pos);
            pos += positionOfValue;
            ethTxReceipt = sliceArray(txBytes, pos, pos+(bytesToRead-positionOfValue));
        }
        else{
            ethTxReceipt = sliceArray(txBytes, pos, pos+bytesToRead);      
        }
        return ethTxReceipt;
    }

    function scanAssetTx(bytes memory txBytes, uint pos)
        public
        view
        returns (uint32, address)
    {

        uint32 assetGUID;
        address erc20Address;
        uint bytesToRead;
        (bytesToRead, pos) = parseVarInt(txBytes, pos);
        pos += bytesToRead;
        pos += 32;
        assetGUID = bytesToUint32Flipped(txBytes, pos);
        pos += 4;
        (bytesToRead, pos) = parseVarInt(txBytes, pos);
        pos += bytesToRead;
        pos += 1;
        (bytesToRead, pos) = parseVarInt(txBytes, pos);
        pos += bytesToRead;
        pos += 1;
        (bytesToRead, pos) = parseVarInt(txBytes, pos);
        pos += bytesToRead;
        pos += 8;
        pos += 8;
        pos += 8;
        pos += 4;
        pos += 1;
        pos += 1;
        (bytesToRead, pos) = parseVarInt(txBytes, pos);
        require(bytesToRead == 0x14,
        "scanAssetTx(): Invalid number of bytes read for contract field");
        erc20Address = readEthereumAddress(txBytes, pos);
        return (assetGUID, erc20Address);
    }

    function bytesToBytes32(bytes memory _rawBytes, uint pos) public pure returns (bytes32) {

        bytes32 out;
        assembly {
            out := mload(add(add(_rawBytes, 0x20), pos))
        }
        return out;
    }

    function getLogValuesForTopic(bytes memory ethTxReceipt, bytes32 expectedTopic)
        public
        pure
        returns (bytes memory)
    {

        RLPReader.RLPItem[] memory ethTxReceiptList = ethTxReceipt.toRlpItem().toList();
        RLPReader.RLPItem[] memory logsList = ethTxReceiptList[3].toList();
        for (uint256 i = 0; i < logsList.length; i++) {
            RLPReader.RLPItem[] memory log = logsList[i].toList();
            bytes memory rawTopic = log[1].toBytes();
            bytes32 topic = bytesToBytes32(rawTopic, 1); // need to remove first byte "a0"
            if (topic == expectedTopic) {
                return log[2].toBytes();
            }
        }
        revert("Topic not found");
    }

    function getBridgeTransactionId(bytes memory logValues) public pure returns (uint256 value) {

        uint8 index = 3; // log's third value
        assembly {
            value := mload(add(logValues, mul(32, index)))
        }
    }

    function initialize(
        bytes32 _blocksMerkleRoot,
        uint _timestamp,
        uint _mtpTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId
    ) external returns (uint, bytes32) {

        require(bestSuperblock == 0);
        require(_parentId == 0);

        bytes32 superblockHash = calcSuperblockHash(_blocksMerkleRoot, _timestamp, _mtpTimestamp, _lastHash, _lastBits, _parentId);
        SuperblockInfo storage superblock = superblocks[superblockHash];

        require(superblock.status == Status.Uninitialized);

        superblock.blocksMerkleRoot = _blocksMerkleRoot;
        superblock.timestamp = _timestamp;
        superblock.mtpTimestamp = _mtpTimestamp;
        superblock.lastHash = _lastHash;
        superblock.parentId = _parentId;
        superblock.submitter = msg.sender;
        superblock.height = 1;
        superblock.lastBits = _lastBits;
        superblock.status = Status.Approved;

        emit NewSuperblock(superblockHash, msg.sender);

        bestSuperblock = superblockHash;
        emit ApprovedSuperblock(superblockHash, msg.sender);

        return (ERR_SUPERBLOCK_OK, superblockHash);
    }

    function propose(
        bytes32 _blocksMerkleRoot,
        uint _timestamp,
        uint _mtpTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        address submitter
    ) external returns (uint, bytes32) {

        if (msg.sender != trustedClaimManager) {
            emit ErrorSuperblock(0, ERR_SUPERBLOCK_NOT_CLAIMMANAGER);
            return (ERR_SUPERBLOCK_NOT_CLAIMMANAGER, 0);
        }

        SuperblockInfo storage parent = superblocks[_parentId];
        if (parent.status != Status.SemiApproved && parent.status != Status.Approved) {
            emit ErrorSuperblock(_parentId, ERR_SUPERBLOCK_BAD_PARENT + uint(parent.status));
            return (ERR_SUPERBLOCK_BAD_PARENT + uint(parent.status), 0);
        }

        if (parent.height < getChainHeight()) {
            emit ErrorSuperblock(_parentId, ERR_SUPERBLOCK_BAD_BLOCKHEIGHT);
            return (ERR_SUPERBLOCK_BAD_BLOCKHEIGHT, 0);
        }

        bytes32 superblockHash = calcSuperblockHash(_blocksMerkleRoot, _timestamp, _mtpTimestamp, _lastHash, _lastBits, _parentId);
        SuperblockInfo storage superblock = superblocks[superblockHash];
        if (superblock.status == Status.Uninitialized) {
            superblock.blocksMerkleRoot = _blocksMerkleRoot;
            superblock.timestamp = _timestamp;
            superblock.mtpTimestamp = _mtpTimestamp;
            superblock.lastHash = _lastHash;
            superblock.parentId = _parentId;
            superblock.height = parent.height + 1;
            superblock.lastBits = _lastBits;
        }
        superblock.status = Status.New;
        superblock.submitter = submitter;
        emit NewSuperblock(superblockHash, submitter);
        return (ERR_SUPERBLOCK_OK, superblockHash);
    }

    function confirm(bytes32 _superblockHash, address _validator) external returns (uint) {

        if (msg.sender != trustedClaimManager) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_NOT_CLAIMMANAGER);
            return ERR_SUPERBLOCK_NOT_CLAIMMANAGER;
        }
        SuperblockInfo storage superblock = superblocks[_superblockHash];
        if (superblock.status != Status.New && superblock.status != Status.SemiApproved) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
            return ERR_SUPERBLOCK_BAD_STATUS;
        }

        if (superblock.height <= getChainHeight()) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_BAD_BLOCKHEIGHT);
            return ERR_SUPERBLOCK_BAD_BLOCKHEIGHT;
        }

        SuperblockInfo storage parent = superblocks[superblock.parentId];
        if (parent.status != Status.Approved) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_BAD_PARENT);
            return ERR_SUPERBLOCK_BAD_PARENT;
        }

        superblock.status = Status.Approved;
        bestSuperblock = _superblockHash;

        emit ApprovedSuperblock(_superblockHash, _validator);
        return ERR_SUPERBLOCK_OK;
    }

    function challenge(bytes32 _superblockHash, address _challenger) external returns (uint) {

        if (msg.sender != trustedClaimManager) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_NOT_CLAIMMANAGER);
            return ERR_SUPERBLOCK_NOT_CLAIMMANAGER;
        }
        SuperblockInfo storage superblock = superblocks[_superblockHash];
        if (superblock.status != Status.New && superblock.status != Status.InBattle) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
            return ERR_SUPERBLOCK_BAD_STATUS;
        }
        if(superblock.submitter == _challenger){
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_OWN_CHALLENGE);
            return ERR_SUPERBLOCK_OWN_CHALLENGE;
        }
        superblock.status = Status.InBattle;
        emit ChallengeSuperblock(_superblockHash, _challenger);
        return ERR_SUPERBLOCK_OK;
    }

    function semiApprove(bytes32 _superblockHash, address _validator) external returns (uint) {

        if (msg.sender != trustedClaimManager) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_NOT_CLAIMMANAGER);
            return ERR_SUPERBLOCK_NOT_CLAIMMANAGER;
        }
        SuperblockInfo storage superblock = superblocks[_superblockHash];

        if (superblock.status != Status.InBattle && superblock.status != Status.New) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
            return ERR_SUPERBLOCK_BAD_STATUS;
        }
        superblock.status = Status.SemiApproved;

        emit SemiApprovedSuperblock(_superblockHash, _validator);
        return ERR_SUPERBLOCK_OK;
    }

    function invalidate(bytes32 _superblockHash, address _validator) external returns (uint) {

        if (msg.sender != trustedClaimManager) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_NOT_CLAIMMANAGER);
            return ERR_SUPERBLOCK_NOT_CLAIMMANAGER;
        }
        SuperblockInfo storage superblock = superblocks[_superblockHash];
        if (superblock.status != Status.InBattle && superblock.status != Status.SemiApproved) {
            emit ErrorSuperblock(_superblockHash, ERR_SUPERBLOCK_BAD_STATUS);
            return ERR_SUPERBLOCK_BAD_STATUS;
        }
        superblock.status = Status.Invalid;
        emit InvalidSuperblock(_superblockHash, _validator);
        return ERR_SUPERBLOCK_OK;
    }

    function verifySPVProofs(
        bytes memory _syscoinBlockHeader,
        uint _syscoinBlockIndex,
        uint[] memory _syscoinBlockSiblings,
        bytes32 _superblockHash,
        bytes memory _txBytes,
        uint _txIndex,
        uint[] memory _txSiblings
    ) private returns (uint) {

        if (bytes32(computeMerkle(dblShaFlip(_syscoinBlockHeader), _syscoinBlockIndex, _syscoinBlockSiblings))
            != superblocks[_superblockHash].blocksMerkleRoot) {
            emit VerifyTransaction(bytes32(0), ERR_SUPERBLOCK_MERKLE_ROOT);
            return 0;
        }
        return verifyTx(_txBytes, _txIndex, _txSiblings, _syscoinBlockHeader, _superblockHash);
    }

    function relayTx(
        bytes memory _txBytes,
        uint _txIndex,
        uint[] memory _txSiblings,
        bytes memory _syscoinBlockHeader,
        uint _syscoinBlockIndex,
        uint[] memory _syscoinBlockSiblings,
        bytes32 _superblockHash
    ) public returns (uint) {

        uint txHash = verifySPVProofs(_syscoinBlockHeader, _syscoinBlockIndex, _syscoinBlockSiblings, _superblockHash, _txBytes, _txIndex, _txSiblings);
        if (txHash != 0) {
            uint value;
            address destinationAddress;
            uint ret;
            uint32 assetGUID;
            address erc20ContractAddress;
            uint8 precision;
            (ret, value, destinationAddress, assetGUID, precision, erc20ContractAddress) = parseBurnTx(_txBytes);
            if(ret != 0){
                emit RelayTransaction(bytes32(txHash), ret);
                return ret;
            }
            syscoinERC20Manager.processTransaction(txHash, value, destinationAddress, superblocks[_superblockHash].submitter, erc20ContractAddress, assetGUID, precision);
            return value;
        }
        emit RelayTransaction(bytes32(0), ERR_RELAY_VERIFY);
        return(ERR_RELAY_VERIFY);
    }

    function relayAssetTx(
        bytes memory _txBytes,
        uint _txIndex,
        uint[] memory _txSiblings,
        bytes memory _syscoinBlockHeader,
        uint _syscoinBlockIndex,
        uint[] memory _syscoinBlockSiblings,
        bytes32 _superblockHash
    ) public returns (uint) {

        uint txHash = verifySPVProofs(_syscoinBlockHeader, _syscoinBlockIndex, _syscoinBlockSiblings, _superblockHash, _txBytes, _txIndex, _txSiblings);
        if (txHash != 0) {
            uint ret;
            uint32 assetGUID;
            address erc20ContractAddress;
            (ret, assetGUID, erc20ContractAddress) = parseAssetTx(_txBytes);
            if(ret != 0){
                emit RelayTransaction(bytes32(txHash), ret);
                return ret;
            }
            uint32 height = superblocks[_superblockHash].height*60;
            height += uint32(_syscoinBlockIndex);
            syscoinERC20Manager.processAsset(txHash, assetGUID, height, erc20ContractAddress);
            return 0;
        }
        emit RelayTransaction(bytes32(0), ERR_RELAY_VERIFY);
        return(ERR_RELAY_VERIFY);
    }

    function challengeCancelTransfer(
        bytes memory _txBytes,
        uint _txIndex,
        uint[] memory _txSiblings,
        bytes memory _syscoinBlockHeader,
        uint _syscoinBlockIndex,
        uint[] memory _syscoinBlockSiblings,
        bytes32 _superblockHash
    ) public returns (uint) {

        uint txHash = verifySPVProofs(_syscoinBlockHeader, _syscoinBlockIndex, _syscoinBlockSiblings, _superblockHash, _txBytes, _txIndex, _txSiblings);
        if (txHash != 0) {
            uint32 bridgeTransferId;
            uint ret;
            (ret, bridgeTransferId) = parseMintTx(_txBytes);
            if(ret != 0){
                emit RelayTransaction(bytes32(txHash), ret);
                return ret;
            }
            syscoinERC20Manager.processCancelTransferFail(bridgeTransferId, msg.sender);
            return 0;
        }
        emit ChallengeCancelTransferRequest(ERR_CANCEL_TRANSFER_VERIFY);
        return(ERR_CANCEL_TRANSFER_VERIFY);
    }

    function parseBurnTx(bytes memory txBytes)
        public
        pure
        returns (uint, uint, address, uint32, uint8, address)
    {

        uint output_value;
        uint32 assetGUID;
        address destinationAddress;
        uint32 version;
        address erc20Address;
        uint8 precision;
        uint pos = 0;
        version = bytesToUint32Flipped(txBytes, pos);
        if(version != SYSCOIN_TX_VERSION_ALLOCATION_BURN_TO_ETHEREUM){
            return (ERR_PARSE_TX_SYS, output_value, destinationAddress, assetGUID, precision, erc20Address);
        }
        pos = getOpReturnPos(txBytes, 4);
        (output_value, destinationAddress, assetGUID, precision, erc20Address) = scanAssetDetails(txBytes, pos);
        return (0, output_value, destinationAddress, assetGUID, precision, erc20Address);
    }

    function skipInputs(bytes memory txBytes, uint pos)
        private
        pure
        returns (uint)
    {

        uint n_inputs;
        uint script_len;
        (n_inputs, pos) = parseVarInt(txBytes, pos);
        if(n_inputs == 0x00){
            (n_inputs, pos) = parseVarInt(txBytes, pos); // flag
            require(n_inputs != 0x00, "#SyscoinSuperblocks skipInputs(): Unexpected dummy/flag");
            (n_inputs, pos) = parseVarInt(txBytes, pos);
        }
        require(n_inputs < 100, "#SyscoinSuperblocks skipInputs(): Incorrect size of n_inputs");

        for (uint i = 0; i < n_inputs; i++) {
            pos += 36;  // skip outpoint
            (script_len, pos) = parseVarInt(txBytes, pos);
            pos += script_len + 4;  // skip sig_script, seq
        }

        return pos;
    }

    function verifyTx(
        bytes memory _txBytes,
        uint _txIndex,
        uint[] memory _siblings,
        bytes memory _txBlockHeaderBytes,
        bytes32 _txsuperblockHash
    ) private returns (uint) {

        uint txHash = dblShaFlip(_txBytes);

        if (_txBytes.length == 64) {  // todo: is check 32 also needed?
            emit VerifyTransaction(bytes32(txHash), ERR_TX_64BYTE);
            return 0;
        }

        if (helperVerifyHash(txHash, _txIndex, _siblings, _txBlockHeaderBytes, _txsuperblockHash) == 1) {
            return txHash;
        } else {
            return 0;
        }
    }

    function dblShaFlip(bytes memory _dataBytes) public pure returns (uint) {

        return flip32Bytes(uint(sha256(abi.encodePacked(sha256(abi.encodePacked(_dataBytes))))));
    }

    function getHeaderMerkleRoot(bytes memory _blockHeader) public pure returns (uint) {

        uint merkle;
        assembly {
            merkle := mload(add(add(_blockHeader, 32), 0x24))
        }
        return flip32Bytes(merkle);
    }

    function helperVerifyHash(
        uint256 _txHash,
        uint _txIndex,
        uint[] memory _siblings,
        bytes memory _blockHeaderBytes,
        bytes32 _txsuperblockHash
    ) private returns (uint) {


        if (!isApproved(_txsuperblockHash)) {
            emit VerifyTransaction(bytes32(_txHash), ERR_CHAIN);
            return (ERR_CHAIN);
        }

        uint merkle = getHeaderMerkleRoot(_blockHeaderBytes);
        if (computeMerkle(_txHash, _txIndex, _siblings) != merkle) {
            emit VerifyTransaction(bytes32(_txHash), ERR_MERKLE_ROOT);
            return (ERR_MERKLE_ROOT);
        }
        return (1);
    }

    function calcSuperblockHash(
        bytes32 _blocksMerkleRoot,
        uint _timestamp,
        uint _mtpTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(
            _blocksMerkleRoot,
            _timestamp,
            _mtpTimestamp,
            _lastHash,
            _lastBits,
            _parentId
        ));
    }

    function getBestSuperblock() external view returns (bytes32) {

        return bestSuperblock;
    }

    function getSuperblock(bytes32 superblockHash) external view returns (
        bytes32 _blocksMerkleRoot,
        uint _timestamp,
        uint _mtpTimestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        address _submitter,
        Status _status,
        uint32 _height
    ) {

        SuperblockInfo storage superblock = superblocks[superblockHash];
        return (
            superblock.blocksMerkleRoot,
            superblock.timestamp,
            superblock.mtpTimestamp,
            superblock.lastHash,
            superblock.lastBits,
            superblock.parentId,
            superblock.submitter,
            superblock.status,
            superblock.height
        );
    }

    function getSuperblockHeight(bytes32 superblockHash) public view returns (uint32) {

        return superblocks[superblockHash].height;
    }

    function getSuperblockTimestamp(bytes32 _superblockHash) external view returns (uint) {

        return superblocks[_superblockHash].timestamp;
    }

    function getSuperblockMedianTimestamp(bytes32 _superblockHash) external view returns (uint) {

        return superblocks[_superblockHash].mtpTimestamp;
    }

    function getSuperblockParentId(bytes32 _superblockHash) external view returns (bytes32) {

        return superblocks[_superblockHash].parentId;
    }


    function getSuperblockStatus(bytes32 _superblockHash) public view returns (Status) {

        return superblocks[_superblockHash].status;
    }

    function isApproved(bytes32 _superblockHash) private view returns (bool) {

        return (getSuperblockStatus(_superblockHash) == Status.Approved);
    }
    function getChainHeight() public view returns (uint) {

        return superblocks[bestSuperblock].height;
    }

    function getSuperblockAt(uint _height) external view returns (bytes32) {

        bytes32 superblockHash = bestSuperblock;

        while (getSuperblockHeight(superblockHash) > _height) {
            superblockHash = superblocks[superblockHash].parentId;
        }

        return superblockHash;
    }
}