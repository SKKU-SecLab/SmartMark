

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


interface SyscoinClaimManagerI {

    function bondDeposit(bytes32 superblockHash, address account, uint amount) external returns (uint);

    function getDeposit(address account) external view returns (uint);

    function checkClaimFinished(bytes32 superblockHash) external returns (bool);

    function sessionDecided(bytes32 superblockHash, address winner, address loser) external;

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






contract SyscoinBattleManager is Initializable, SyscoinErrorCodes, SyscoinMessageLibrary {


    uint constant TARGET_TIMESPAN =  21600;
    uint constant TARGET_TIMESPAN_MIN = 17280; // TARGET_TIMESPAN * (8/10);
    uint constant TARGET_TIMESPAN_MAX = 27000; // TARGET_TIMESPAN * (10/8);
    uint constant TARGET_TIMESPAN_ADJUSTMENT =  360;  // 6 hour
    uint constant POW_LIMIT =    0x00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    struct BattleSession {
        address submitter;
        address challenger;
        uint lastActionTimestamp;         // Last action timestamp
        bytes32 prevSubmitBlockhash;
        bytes32[] merkleRoots;            // interim merkle roots to recreate final root hash on last set of headers
    }
    struct AuxPoW {
        uint blockHash;

        uint txHash;

        uint coinbaseMerkleRoot; // Merkle root of auxiliary block hash tree; stored in coinbase tx field
        uint[] chainMerkleProof; // proves that a given Syscoin block hash belongs to a tree with the above root
        uint syscoinHashIndex; // index of Syscoin block hash within block hash tree
        uint coinbaseMerkleRootCode; // encodes whether or not the root was found properly

        uint parentMerkleRoot; // Merkle root of transaction tree from parent Bitcoin block header
        uint[] parentMerkleProof; // proves that coinbase tx belongs to a tree with the above root
        uint coinbaseTxIndex; // index of coinbase tx within Bitcoin tx tree

        uint parentNonce;
        uint pos;
    }
    struct BlockHeader {
        uint32 bits;
        bytes32 prevBlock;
        uint32 timestamp;
        bytes32 blockHash;
    }
    mapping (bytes32 => BattleSession) sessions;

    uint public superblockDuration;         // Superblock duration (in blocks)
    uint public superblockTimeout;          // Timeout action (in seconds)

    Network private net;


    SyscoinClaimManagerI trustedSyscoinClaimManager;

    SyscoinSuperblocksI trustedSuperblocks;

    event NewBattle(bytes32 superblockHash,address submitter, address challenger);
    event ChallengerConvicted(bytes32 superblockHash, uint err, address challenger);
    event SubmitterConvicted(bytes32 superblockHash, uint err, address submitter);
    event RespondBlockHeaders(bytes32 superblockHash, uint merkleHashCount, address submitter);
    modifier onlyFrom(address sender) {

        require(msg.sender == sender);
        _;
    }

    modifier onlyChallenger(bytes32 superblockHash) {

        require(msg.sender == sessions[superblockHash].challenger);
        _;
    }

    function init(
        Network _network,
        SyscoinSuperblocksI _superblocks,
        uint _superblockDuration,
        uint _superblockTimeout
    ) external initializer {

        net = _network;
        trustedSuperblocks = _superblocks;
        superblockDuration = _superblockDuration;
        superblockTimeout = _superblockTimeout;
    }

    function setSyscoinClaimManager(SyscoinClaimManagerI _syscoinClaimManager) external {

        require(address(trustedSyscoinClaimManager) == address(0) && address(_syscoinClaimManager) != address(0));
        trustedSyscoinClaimManager = _syscoinClaimManager;
    }

    function beginBattleSession(bytes32 superblockHash, address submitter, address challenger)
        external onlyFrom(address(trustedSyscoinClaimManager)) {

        BattleSession storage session = sessions[superblockHash];

        require(session.submitter == address(0));

        session.submitter = submitter;
        session.challenger = challenger;
        session.merkleRoots.length = 0;
        session.lastActionTimestamp = block.timestamp;

        emit NewBattle(superblockHash, submitter, challenger);
    }


    function getHashPrevBlock(bytes memory _blockHeader, uint pos) private pure returns (uint) {

        uint hashPrevBlock;
        uint index = 0x04+pos;
        assembly {
            hashPrevBlock := mload(add(add(_blockHeader, 32), index))
        }
        return flip32Bytes(hashPrevBlock);
    }


    function getTimestamp(bytes memory _blockHeader, uint pos) private pure returns (uint32 time) {

        return bytesToUint32Flipped(_blockHeader, 0x44+pos);
    }

    function getBits(bytes memory _blockHeader, uint pos) private pure returns (uint32 bits) {

        return bytesToUint32Flipped(_blockHeader, 0x48+pos);
    }

    function parseHeaderBytes(bytes memory _rawBytes, uint pos) private view returns (BlockHeader memory bh) {

        bh.bits = getBits(_rawBytes, pos);
        bh.blockHash = bytes32(dblShaFlipMem(_rawBytes, pos, 80));
        bh.timestamp = getTimestamp(_rawBytes, pos);
        bh.prevBlock = bytes32(getHashPrevBlock(_rawBytes, pos));
    }

    function parseAuxPoW(bytes memory rawBytes, uint pos)
        private
        view
        returns (AuxPoW memory auxpow)
    {

        bytes memory coinbaseScript;
        uint slicePos;
        pos += 80; // skip non-AuxPoW header

        (slicePos, coinbaseScript) = getSlicePos(rawBytes, pos);
        auxpow.txHash = dblShaFlipMem(rawBytes, pos, slicePos - pos);
        pos = slicePos;
        pos += 32;
        (auxpow.parentMerkleProof, pos) = scanMerkleBranch(rawBytes, pos, 0);
        auxpow.coinbaseTxIndex = getBytesLE(rawBytes, pos, 32);
        pos += 4;
        (auxpow.chainMerkleProof, pos) = scanMerkleBranch(rawBytes, pos, 0);
        auxpow.syscoinHashIndex = getBytesLE(rawBytes, pos, 32);
        pos += 4;
        auxpow.blockHash = dblShaFlipMem(rawBytes, pos, 80);
        pos += 36; // skip parent version and prev block
        auxpow.parentMerkleRoot = sliceBytes32Int(rawBytes, pos);
        pos += 40; // skip root that was just read, parent block timestamp and bits
        auxpow.parentNonce = getBytesLE(rawBytes, pos, 32);
        auxpow.pos = pos+4;
        uint coinbaseMerkleRootPosition;
        (auxpow.coinbaseMerkleRoot, coinbaseMerkleRootPosition, auxpow.coinbaseMerkleRootCode) = findCoinbaseMerkleRoot(coinbaseScript);
    }

    function sha256mem(bytes memory _rawBytes, uint offset, uint len)
        public
        view
        returns (bytes32 result)
    {

        assembly {
            let ptr := mload(0x40)
            if iszero(staticcall(gas, 0x02, add(add(_rawBytes, 0x20), offset), len, ptr, 0x20)) {
                revert(0, 0)
            }
            result := mload(ptr)
        }
    }

    function dblShaFlipMem(bytes memory _rawBytes, uint offset, uint len)
        public
        view
        returns (uint)
    {

        return flip32Bytes(uint(sha256(abi.encodePacked(sha256mem(_rawBytes, offset, len)))));
    }

    function skipOutputs(bytes memory txBytes, uint pos) private pure returns (uint) {

        uint n_outputs;
        uint script_len;

        (n_outputs, pos) = parseVarInt(txBytes, pos);

        require(n_outputs < 10);

        for (uint i = 0; i < n_outputs; i++) {
            pos += 8;
            (script_len, pos) = parseVarInt(txBytes, pos);
            pos += script_len;
        }

        return pos;
    }

    function getSlicePos(bytes memory txBytes, uint pos)
        private
        view
        returns (uint slicePos, bytes memory coinbaseScript)
    {


        (slicePos, coinbaseScript) = skipInputsCoinbase(txBytes, pos + 4);
        slicePos = skipOutputs(txBytes, slicePos);
        slicePos += 4; // skip lock time
    }

    function scanMerkleBranch(bytes memory txBytes, uint pos, uint stop)
        private
        pure
        returns (uint[] memory, uint)
    {

        uint n_siblings;
        uint halt;

        (n_siblings, pos) = parseVarInt(txBytes, pos);

        if (stop == 0 || stop > n_siblings) {
            halt = n_siblings;
        } else {
            halt = stop;
        }

        uint[] memory sibling_values = new uint[](halt);

        for (uint i = 0; i < halt; i++) {
            sibling_values[i] = flip32Bytes(sliceBytes32Int(txBytes, pos));
            pos += 32;
        }

        return (sibling_values, pos);
    }

    function sliceBytes32Int(bytes memory data, uint start) private pure returns (uint slice) {

        assembly {
            slice := mload(add(data, add(0x20, start)))
        }
    }

    function skipInputsCoinbase(bytes memory txBytes, uint pos)
        private
        view
        returns (uint, bytes memory)
    {

        uint n_inputs;
        uint script_len;
        (n_inputs, pos) = parseVarInt(txBytes, pos);
        if(n_inputs == 0x00){
            (n_inputs, pos) = parseVarInt(txBytes, pos); // flag
            require(n_inputs != 0x00);
            (n_inputs, pos) = parseVarInt(txBytes, pos);
        }
        require(n_inputs == 1);

        pos += 36;  // skip outpoint
        (script_len, pos) = parseVarInt(txBytes, pos);
        bytes memory coinbaseScript;
        coinbaseScript = sliceArray(txBytes, pos, pos+script_len);
        pos += script_len + 4;  // skip sig_script, seq

        return (pos, coinbaseScript);
    }

    function findCoinbaseMerkleRoot(bytes memory rawBytes)
        private
        pure
        returns (uint, uint, uint)
    {

        uint position;
        uint found = 0;
        uint target = 0xfabe6d6d00000000000000000000000000000000000000000000000000000000;
        uint mask = 0xffffffff00000000000000000000000000000000000000000000000000000000;
        assembly {
            let len := mload(rawBytes)
            let data := add(rawBytes, 0x20)
            let end := add(data, len)

            for { } lt(data, end) { } {     // while(i < end)
                if eq(and(mload(data), mask), target) {
                    if eq(found, 0x0) {
                        position := add(sub(len, sub(end, data)), 4)
                    }
                    found := add(found, 1)
                }
                data := add(data, 0x1)
            }
        }

        if (found >= 2) {
            return (0, position - 4, ERR_FOUND_TWICE);
        } else if (found == 1) {
            return (sliceBytes32Int(rawBytes, position), position - 4, 1);
        } else { // no merge mining header
            return (0, position - 4, ERR_NO_MERGE_HEADER);
        }
    }

    function computeParentMerkle(AuxPoW memory _ap) private pure returns (uint) {
        return flip32Bytes(computeMerkle(_ap.txHash,
                                         _ap.coinbaseTxIndex,
                                         _ap.parentMerkleProof));
    }

    function computeChainMerkle(uint _blockHash, AuxPoW memory _ap) private pure returns (uint) {
        return computeMerkle(_blockHash,
                             _ap.syscoinHashIndex,
                             _ap.chainMerkleProof);
    }    

    function checkAuxPoW(uint _blockHash, AuxPoW memory _ap) private pure returns (uint) {
        if (_ap.coinbaseTxIndex != 0) {
            return ERR_COINBASE_INDEX;
        }

        if (_ap.coinbaseMerkleRootCode != 1) {
            return _ap.coinbaseMerkleRootCode;
        }

        if (computeChainMerkle(_blockHash, _ap) != _ap.coinbaseMerkleRoot) {
            return ERR_CHAIN_MERKLE;
        }

        if (computeParentMerkle(_ap) != _ap.parentMerkleRoot) {
            return ERR_PARENT_MERKLE;
        }

        return 1;
    }

    function targetFromBits(uint32 _bits) public pure returns (uint) {
        uint exp = _bits / 0x1000000;  // 2**24
        uint mant = _bits & 0xffffff;
        return mant * 256**(exp - 3);
    }
    
    function calculateDifficulty(uint _actualTimespan, uint32 _bits) private pure returns (uint32 result) {
        uint actualTimespan = _actualTimespan;
        if (actualTimespan < TARGET_TIMESPAN_MIN) {
            actualTimespan = TARGET_TIMESPAN_MIN;
        } else if (actualTimespan > TARGET_TIMESPAN_MAX) {
            actualTimespan = TARGET_TIMESPAN_MAX;
        }

        uint bnNew = targetFromBits(_bits);
        bnNew = bnNew * actualTimespan;
        bnNew = bnNew / TARGET_TIMESPAN;

        if (bnNew > POW_LIMIT) {
            bnNew = POW_LIMIT;
        }

        return toCompactBits(bnNew);
    }

    function shiftRight(uint _val, uint _shift) private pure returns (uint) {
        return _val / uint(2)**_shift;
    }

    function shiftLeft(uint _val, uint _shift) private pure returns (uint) {
        return _val * uint(2)**_shift;
    }

    function bitLen(uint _val) private pure returns (uint length) {
        uint int_type = _val;
        while (int_type > 0) {
            int_type = shiftRight(int_type, 1);
            length += 1;
        }
    }

    function toCompactBits(uint _val) private pure returns (uint32) {
        uint nbytes = uint (shiftRight((bitLen(_val) + 7), 3));
        uint32 compact = 0;
        if (nbytes <= 3) {
            compact = uint32 (shiftLeft((_val & 0xFFFFFF), 8 * (3 - nbytes)));
        } else {
            compact = uint32 (shiftRight(_val, 8 * (nbytes - 3)));
            compact = uint32 (compact & 0xFFFFFF);
        }

        if ((compact & 0x00800000) > 0) {
            compact = uint32(shiftRight(compact, 8));
            nbytes += 1;
        }

        return compact | uint32(shiftLeft(nbytes, 24));
    }

    function makeMerkle(bytes32[] memory hashes) public pure returns (bytes32) {
        uint length = hashes.length;

        if (length == 1) return hashes[0];
        require(length > 0, "Must provide hashes");

        uint i;
        for (i = 0; i < length; i++) {
            hashes[i] = bytes32(flip32Bytes(uint(hashes[i])));
        }

        uint j;
        uint k;

        while (length > 1) {
            k = 0;
            for (i = 0; i < length; i += 2) {
                j = (i + 1 < length) ? i + 1 : length - 1;
                hashes[k] = sha256(abi.encodePacked(sha256(abi.encodePacked(hashes[i], hashes[j]))));
                k += 1;
            }
            length = k;
        }
        return bytes32(flip32Bytes(uint(hashes[0])));
    }

    function doRespondBlockHeaders(
        BattleSession storage session,
        SyscoinSuperblocksI.SuperblockInfo memory superblockInfo,
        bytes32 merkleRoot,
        BlockHeader memory lastHeader
    ) private returns (uint) {
        if (session.merkleRoots.length == 3 || net == Network.REGTEST) {
            bytes32[] memory merkleRoots = new bytes32[](net != Network.REGTEST ? 4 : 1);
            uint i;
            for (i = 0; i < session.merkleRoots.length; i++) {
                merkleRoots[i] = session.merkleRoots[i];
            }
            merkleRoots[i] = merkleRoot;
            if (superblockInfo.blocksMerkleRoot != makeMerkle(merkleRoots)) {
                return ERR_SUPERBLOCK_INVALID_MERKLE;
            }

            if (superblockInfo.timestamp != lastHeader.timestamp) {
                return ERR_SUPERBLOCK_INVALID_TIMESTAMP;
            }
            if (lastHeader.blockHash != superblockInfo.lastHash) {
                return ERR_SUPERBLOCK_HASH_SUPERBLOCK;
            }
        } else {
            session.merkleRoots.push(merkleRoot);
        }

        return ERR_SUPERBLOCK_OK;
    }

    function respondBlockHeaders (
        bytes32 superblockHash,
        bytes memory blockHeaders,
        uint numHeaders
    ) public {
        BattleSession storage session = sessions[superblockHash];
        address submitter = session.submitter;

        require(msg.sender == submitter);

        uint merkleRootsLen = session.merkleRoots.length;

        if (net != Network.REGTEST) {
            if ((merkleRootsLen <= 2 && numHeaders != 16) || (merkleRootsLen == 3 && numHeaders != 12)) {
                revert();
            }
        }

        SyscoinSuperblocksI.SuperblockInfo memory superblockInfo;
        (superblockInfo.blocksMerkleRoot, superblockInfo.timestamp,superblockInfo.mtpTimestamp,superblockInfo.lastHash,superblockInfo.lastBits,superblockInfo.parentId,,,superblockInfo.height) =
            trustedSuperblocks.getSuperblock(superblockHash);

        uint pos = 0;
        bytes32[] memory blockHashes = new bytes32[](numHeaders);
        BlockHeader[] memory parsedBlockHeaders = new BlockHeader[](numHeaders);

        uint err = ERR_SUPERBLOCK_OK;

        for (uint i = 0; i < parsedBlockHeaders.length; i++){
            parsedBlockHeaders[i] = parseHeaderBytes(blockHeaders, pos);
            uint target = targetFromBits(parsedBlockHeaders[i].bits);

            if (isMergeMined(blockHeaders, pos)) {
                AuxPoW memory ap = parseAuxPoW(blockHeaders, pos);
                if (ap.blockHash > target) {
                    err = ERR_PROOF_OF_WORK_AUXPOW;
                    break;
                }

                uint auxPoWCode = checkAuxPoW(uint(parsedBlockHeaders[i].blockHash), ap);
                if (auxPoWCode != 1) {
                    err = auxPoWCode;
                    break;
                }

                pos = ap.pos;
            } else {
                if (uint(parsedBlockHeaders[i].blockHash) > target) {
                    err = ERR_PROOF_OF_WORK;
                    break;
                }

                pos = pos+80;
            }

            blockHashes[i] = parsedBlockHeaders[i].blockHash;
        }

        if (err != ERR_SUPERBLOCK_OK) {
            convictSubmitter(superblockHash, submitter, session.challenger, err);
            return;
        }

        err = doRespondBlockHeaders(
            session,
            superblockInfo,
            makeMerkle(blockHashes),
            parsedBlockHeaders[parsedBlockHeaders.length-1]
        );
        if (err != ERR_SUPERBLOCK_OK) {
            convictSubmitter(superblockHash, submitter, session.challenger, err);
        } else {
            session.lastActionTimestamp = block.timestamp;
            err = validateHeaders(session, superblockInfo, parsedBlockHeaders);
            if (err != ERR_SUPERBLOCK_OK) {
                convictSubmitter(superblockHash, submitter, session.challenger, err);
                return;
            }
            if(numHeaders == 12 || net == Network.REGTEST){
                convictChallenger(superblockHash, submitter, session.challenger, err);
                return;
            }
            emit RespondBlockHeaders(superblockHash, merkleRootsLen + 1, submitter);
        }
    }

    uint32 constant VERSION_AUXPOW = (1 << 8);
    function isMergeMined(bytes memory _rawBytes, uint pos) private pure returns (bool) {
        return bytesToUint32Flipped(_rawBytes, pos) & VERSION_AUXPOW != 0;
    }

    function checkBlocks(BattleSession storage session, BlockHeader[] memory blockHeadersParsed, uint32 prevBits) private view returns (uint) {
        for(uint i = blockHeadersParsed.length-1;i>0;i--){
            BlockHeader memory thisHeader = blockHeadersParsed[i];
            BlockHeader memory prevHeader = blockHeadersParsed[i-1];
            if (blockHeadersParsed.length != 12 || i < (blockHeadersParsed.length-1)){
                if (prevBits != thisHeader.bits)
                    return ERR_SUPERBLOCK_BITS_PREVBLOCK;
            }
            if(prevHeader.blockHash != thisHeader.prevBlock)
                return ERR_SUPERBLOCK_HASH_PREVBLOCK;
        }

        if (prevBits != blockHeadersParsed[0].bits) {
            return ERR_SUPERBLOCK_BITS_PREVBLOCK;
        }

        if (session.merkleRoots.length >= 2) {
            if (session.prevSubmitBlockhash != blockHeadersParsed[0].prevBlock)
                return ERR_SUPERBLOCK_HASH_INTERIM_PREVBLOCK;
        }
        return ERR_SUPERBLOCK_OK;
    }
    function sort_array(uint[11] memory arr) private pure {
        for(uint i = 0; i < 11; i++) {
            for(uint j = i+1; j < 11 ;j++) {
                if(arr[i] > arr[j]) {
                    uint temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
        }
    }

    function getMedianTimestamp(BlockHeader[] memory blockHeadersParsed) private pure returns (uint){
        uint[11] memory timestamps;
        for(uint i=0;i<11;i++){
            timestamps[i] = blockHeadersParsed[i+1].timestamp;
        }
        sort_array(timestamps);
        return timestamps[5];
    }
    function validateHeaders(BattleSession storage session, SyscoinSuperblocksI.SuperblockInfo memory superblockInfo, BlockHeader[] memory blockHeadersParsed) private returns (uint) {
        SyscoinSuperblocksI.SuperblockInfo memory prevSuperblockInfo;
        BlockHeader memory lastHeader = blockHeadersParsed[blockHeadersParsed.length-1];
        (,,prevSuperblockInfo.mtpTimestamp,prevSuperblockInfo.lastHash,prevSuperblockInfo.lastBits,,,,) =
            trustedSuperblocks.getSuperblock(superblockInfo.parentId);
        if(session.merkleRoots.length <= 1){
            if(blockHeadersParsed[0].prevBlock != prevSuperblockInfo.lastHash)
                return ERR_SUPERBLOCK_HASH_PREVSUPERBLOCK;

        }
        uint err = checkBlocks(session, blockHeadersParsed, prevSuperblockInfo.lastBits);
        if(err != ERR_SUPERBLOCK_OK)
            return err;
        if(blockHeadersParsed.length != 12){
            session.prevSubmitBlockhash = lastHeader.blockHash;
        }
        else{
            uint mtpTimestamp = getMedianTimestamp(blockHeadersParsed);

            if(mtpTimestamp != superblockInfo.mtpTimestamp)
                 return ERR_SUPERBLOCK_MISMATCH_TIMESTAMP_MTP;

            if(mtpTimestamp <= prevSuperblockInfo.mtpTimestamp)
                return ERR_SUPERBLOCK_TOOSMALL_TIMESTAMP_MTP;


            if (net != Network.REGTEST) {
                if (((superblockInfo.height-1) % 6) == 0) {
                    BlockHeader memory prevToLastHeader = blockHeadersParsed[blockHeadersParsed.length-2];

                    superblockInfo.timestamp = trustedSuperblocks.getSuperblockTimestamp(trustedSuperblocks.getSuperblockAt(superblockInfo.height - 6));
                    uint32 newBits = calculateDifficulty(prevToLastHeader.timestamp - superblockInfo.timestamp, prevSuperblockInfo.lastBits);

                    if (superblockInfo.lastBits != newBits) {
                        return ERR_SUPERBLOCK_BITS_SUPERBLOCK;
                    }
                } else {
                    if (superblockInfo.lastBits != prevSuperblockInfo.lastBits) {
                        return ERR_SUPERBLOCK_BITS_LASTBLOCK;
                    }
                }

                if (superblockInfo.lastBits != lastHeader.bits)
                    return ERR_SUPERBLOCK_BITS_LASTBLOCK;
            }
        }

        return ERR_SUPERBLOCK_OK;
    }


    function timeout(bytes32 superblockHash) external returns (uint) {
        BattleSession storage session = sessions[superblockHash];
        require(session.submitter != address(0));

        if (block.timestamp > session.lastActionTimestamp + superblockTimeout) {
            convictSubmitter(superblockHash, session.submitter, session.challenger, ERR_SUPERBLOCK_TIMEOUT);
            trustedSyscoinClaimManager.checkClaimFinished(superblockHash);
            return ERR_SUPERBLOCK_TIMEOUT;
        }
        return ERR_SUPERBLOCK_NO_TIMEOUT;
    }

    function convictChallenger(bytes32 superblockHash, address submitter, address challenger, uint err) private {
        trustedSyscoinClaimManager.sessionDecided(superblockHash, submitter, challenger);
        emit ChallengerConvicted(superblockHash, err, challenger);
        disable(superblockHash);
    }

    function convictSubmitter(bytes32 superblockHash, address submitter, address challenger, uint err) private {
        trustedSyscoinClaimManager.sessionDecided(superblockHash, challenger, submitter);
        emit SubmitterConvicted(superblockHash, err, submitter);
        disable(superblockHash);
    }

    function disable(bytes32 superblockHash) private {
        delete sessions[superblockHash];
    }

    function getSubmitterHitTimeout(bytes32 superblockHash) external view returns (bool) {
        BattleSession storage session = sessions[superblockHash];
        return (block.timestamp > session.lastActionTimestamp + superblockTimeout);
    }
    function getNumMerkleHashesBySession(bytes32 superblockHash) external view returns (uint) {
        BattleSession memory session = sessions[superblockHash];
        if (session.submitter == address(0))
            return 0;
        return sessions[superblockHash].merkleRoots.length;
    }
    function sessionExists(bytes32 superblockHash) external view returns (bool) {
        return sessions[superblockHash].submitter != address(0);
    }
}