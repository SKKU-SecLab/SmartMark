
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


library RLPReader {

    uint8 constant STRING_SHORT_START = 0x80;
    uint8 constant STRING_LONG_START = 0xb8;
    uint8 constant LIST_SHORT_START = 0xc0;
    uint8 constant LIST_LONG_START = 0xf8;
    uint8 constant WORD_SIZE = 32;

    struct RLPItem {
        uint256 len;
        uint256 memPtr;
    }

    function toRlpItem(bytes memory item)
        internal
        pure
        returns (RLPItem memory)
    {

        require(item.length > 0, "RLPReader: INVALID_BYTES_LENGTH");
        uint256 memPtr;
        assembly {
            memPtr := add(item, 0x20)
        }

        return RLPItem(item.length, memPtr);
    }

    function toList(RLPItem memory item)
        internal
        pure
        returns (RLPItem[] memory)
    {

        require(isList(item), "RLPReader: ITEM_NOT_LIST");

        uint256 items = numItems(item);
        RLPItem[] memory result = new RLPItem[](items);
        uint256 listLength = _itemLength(item.memPtr);
        require(listLength == item.len, "RLPReader: LIST_DECODED_LENGTH_MISMATCH");

        uint256 memPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 dataLen;
        for (uint256 i = 0; i < items; i++) {
            dataLen = _itemLength(memPtr);
            result[i] = RLPItem(dataLen, memPtr);
            memPtr = memPtr + dataLen;
        }

        return result;
    }

    function isList(RLPItem memory item) internal pure returns (bool) {

        uint8 byte0;
        uint256 memPtr = item.memPtr;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < LIST_SHORT_START) return false;
        return true;
    }


    function toRlpBytes(RLPItem memory item)
        internal
        pure
        returns (bytes memory)
    {

        bytes memory result = new bytes(item.len);

        uint256 ptr;
        assembly {
            ptr := add(0x20, result)
        }

        copy(item.memPtr, ptr, item.len);
        return result;
    }

    function toAddress(RLPItem memory item) internal pure returns (address) {

        require(!isList(item), "RLPReader: DECODING_LIST_AS_ADDRESS");
        require(item.len == 21, "RLPReader: INVALID_ADDRESS_LENGTH");

        return address(toUint(item));
    }

    function toUint(RLPItem memory item) internal pure returns (uint256) {

        require(!isList(item), "RLPReader: DECODING_LIST_AS_UINT");
        require(item.len <= 33, "RLPReader: INVALID_UINT_LENGTH");

        uint256 itemLength = _itemLength(item.memPtr);
        require(itemLength == item.len, "RLPReader: UINT_DECODED_LENGTH_MISMATCH");

        uint256 offset = _payloadOffset(item.memPtr);
        uint256 len = item.len - offset;
        uint256 result;
        uint256 memPtr = item.memPtr + offset;
        assembly {
            result := mload(memPtr)

            if lt(len, 32) {
                result := div(result, exp(256, sub(32, len)))
            }
        }

        return result;
    }

    function toUintStrict(RLPItem memory item) internal pure returns (uint256) {

        uint256 itemLength = _itemLength(item.memPtr);
        require(itemLength == item.len, "RLPReader: UINT_STRICT_DECODED_LENGTH_MISMATCH");
        require(item.len == 33, "RLPReader: INVALID_UINT_STRICT_LENGTH");

        uint256 result;
        uint256 memPtr = item.memPtr + 1;
        assembly {
            result := mload(memPtr)
        }

        return result;
    }

    function toBytes(RLPItem memory item) internal pure returns (bytes memory) {

        uint256 listLength = _itemLength(item.memPtr);
        require(listLength == item.len, "RLPReader: BYTES_DECODED_LENGTH_MISMATCH");
        uint256 offset = _payloadOffset(item.memPtr);

        uint256 len = item.len - offset; // data length
        bytes memory result = new bytes(len);

        uint256 destPtr;
        assembly {
            destPtr := add(0x20, result)
        }

        copy(item.memPtr + offset, destPtr, len);
        return result;
    }


    function numItems(RLPItem memory item) private pure returns (uint256) {


        uint256 count = 0;
        uint256 currPtr = item.memPtr + _payloadOffset(item.memPtr);
        uint256 endPtr = item.memPtr + item.len;
        while (currPtr < endPtr) {
            currPtr = currPtr + _itemLength(currPtr); // skip over an item
            require(currPtr <= endPtr, "RLPReader: NUM_ITEMS_DECODED_LENGTH_MISMATCH");
            count++;
        }

        return count;
    }

    function _itemLength(uint256 memPtr) private pure returns (uint256) {

        uint256 itemLen;
        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) itemLen = 1;
        else if (byte0 < STRING_LONG_START)
            itemLen = byte0 - STRING_SHORT_START + 1;
        else if (byte0 < LIST_SHORT_START) {
            assembly {
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is
                memPtr := add(memPtr, 1) // skip over the first byte

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len
                itemLen := add(dataLen, add(byteLen, 1))
            }
        } else if (byte0 < LIST_LONG_START) {
            itemLen = byte0 - LIST_SHORT_START + 1;
        } else {
            assembly {
                let byteLen := sub(byte0, 0xf7)
                memPtr := add(memPtr, 1)

                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length
                itemLen := add(dataLen, add(byteLen, 1))
            }
        }

        return itemLen;
    }

    function _payloadOffset(uint256 memPtr) private pure returns (uint256) {

        uint256 byte0;
        assembly {
            byte0 := byte(0, mload(memPtr))
        }

        if (byte0 < STRING_SHORT_START) return 0;
        else if (
            byte0 < STRING_LONG_START ||
            (byte0 >= LIST_SHORT_START && byte0 < LIST_LONG_START)
        ) return 1;
        else if (byte0 < LIST_SHORT_START)
            return byte0 - (STRING_LONG_START - 1) + 1;
        else return byte0 - (LIST_LONG_START - 1) + 1;
    }

    function copy(
        uint256 src,
        uint256 dest,
        uint256 len
    ) private pure {

        if (len == 0) return;

        for (; len >= WORD_SIZE; len -= WORD_SIZE) {
            assembly {
                mstore(dest, mload(src))
            }

            src += WORD_SIZE;
            dest += WORD_SIZE;
        }

        uint256 mask = 256**(WORD_SIZE - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask)) // zero out src
            let destpart := and(mload(dest), mask) // retrieve the bytes
            mstore(dest, or(destpart, srcpart))
        }
    }
}

library MerklePatriciaProof {

    function verify(
        bytes memory value,
        bytes memory encodedPath,
        bytes memory rlpParentNodes,
        bytes32 root
    ) internal pure returns (bool) {

        RLPReader.RLPItem memory item = RLPReader.toRlpItem(rlpParentNodes);
        RLPReader.RLPItem[] memory parentNodes = RLPReader.toList(item);

        bytes memory currentNode;
        RLPReader.RLPItem[] memory currentNodeList;

        bytes32 nodeKey = root;
        uint256 pathPtr = 0;

        bytes memory path = _getNibbleArray(encodedPath);
        if (path.length == 0) {
            return false;
        }

        for (uint256 i = 0; i < parentNodes.length; i++) {
            if (pathPtr > path.length) {
                return false;
            }

            currentNode = RLPReader.toRlpBytes(parentNodes[i]);
            if (nodeKey != keccak256(currentNode)) {
                return false;
            }
            currentNodeList = RLPReader.toList(parentNodes[i]);

            if (currentNodeList.length == 17) {
                if (pathPtr == path.length) {
                    if (
                        keccak256(RLPReader.toBytes(currentNodeList[16])) ==
                        keccak256(value)
                    ) {
                        return true;
                    } else {
                        return false;
                    }
                }

                uint8 nextPathNibble = uint8(path[pathPtr]);
                if (nextPathNibble > 16) {
                    return false;
                }
                nodeKey = bytes32(
                    RLPReader.toUintStrict(currentNodeList[nextPathNibble])
                );
                pathPtr += 1;
            } else if (currentNodeList.length == 2) {
                uint256 traversed = _nibblesToTraverse(
                    RLPReader.toBytes(currentNodeList[0]),
                    path,
                    pathPtr
                );
                if (pathPtr + traversed == path.length) {
                    if (
                        keccak256(RLPReader.toBytes(currentNodeList[1])) ==
                        keccak256(value)
                    ) {
                        return true;
                    } else {
                        return false;
                    }
                }

                if (traversed == 0) {
                    return false;
                }

                pathPtr += traversed;
                nodeKey = bytes32(RLPReader.toUintStrict(currentNodeList[1]));
            } else {
                return false;
            }
        }
    }

    function _nibblesToTraverse(
        bytes memory encodedPartialPath,
        bytes memory path,
        uint256 pathPtr
    ) private pure returns (uint256) {

        uint256 len = 0;
        bytes memory partialPath = _getNibbleArray(encodedPartialPath);
        bytes memory slicedPath = new bytes(partialPath.length);

        for (uint256 i = pathPtr; i < pathPtr + partialPath.length; i++) {
            bytes1 pathNibble = path[i];
            slicedPath[i - pathPtr] = pathNibble;
        }

        if (keccak256(partialPath) == keccak256(slicedPath)) {
            len = partialPath.length;
        } else {
            len = 0;
        }
        return len;
    }

    function _getNibbleArray(bytes memory b)
        internal
        pure
        returns (bytes memory)
    {

        bytes memory nibbles = "";
        if (b.length > 0) {
            uint8 offset;
            uint8 hpNibble = uint8(_getNthNibbleOfBytes(0, b));
            if (hpNibble == 1 || hpNibble == 3) {
                nibbles = new bytes(b.length * 2 - 1);
                bytes1 oddNibble = _getNthNibbleOfBytes(1, b);
                nibbles[0] = oddNibble;
                offset = 1;
            } else {
                nibbles = new bytes(b.length * 2 - 2);
                offset = 0;
            }

            for (uint256 i = offset; i < nibbles.length; i++) {
                nibbles[i] = _getNthNibbleOfBytes(i - offset + 2, b);
            }
        }
        return nibbles;
    }

    function _getNthNibbleOfBytes(uint256 n, bytes memory str)
        private
        pure
        returns (bytes1)
    {

        return
            bytes1(
                n % 2 == 0 ? uint8(str[n / 2]) / 0x10 : uint8(str[n / 2]) % 0x10
            );
    }
}

library Merkle {

    function checkMembership(
        bytes32 leaf,
        uint256 index,
        bytes32 rootHash,
        bytes memory proof
    ) internal pure returns (bool) {

        require(proof.length % 32 == 0, "Invalid proof length");
        uint256 proofHeight = proof.length / 32;
        require(index < 2 ** proofHeight, "Leaf index is too big");

        bytes32 proofElement;
        bytes32 computedHash = leaf;
        for (uint256 i = 32; i <= proof.length; i += 32) {
            assembly {
                proofElement := mload(add(proof, i))
            }

            if (index % 2 == 0) {
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }

            index = index / 2;
        }
        return computedHash == rootHash;
    }
}


interface IFxStateSender {

    function sendMessageToChild(address _receiver, bytes calldata _data) external;

}

contract ICheckpointManager {

    struct HeaderBlock {
        bytes32 root;
        uint256 start;
        uint256 end;
        uint256 createdAt;
        address proposer;
    }

    mapping(uint256 => HeaderBlock) public headerBlocks;
}

abstract contract FxBaseRootTunnel {
    using RLPReader for bytes;
    using RLPReader for RLPReader.RLPItem;
    using Merkle for bytes32;

    bytes32 public constant SEND_MESSAGE_EVENT_SIG = 0x8c5261668696ce22758910d05bab8f186d6eb247ceac2af2e82c7dc17669b036;

    IFxStateSender public fxRoot;
    ICheckpointManager public checkpointManager;
    address public fxChildTunnel;

    mapping(bytes32 => bool) public processedExits;

    constructor(address _checkpointManager, address _fxRoot) public {
        checkpointManager = ICheckpointManager(_checkpointManager);
        fxRoot = IFxStateSender(_fxRoot);
    }

    function setFxChildTunnel(address _fxChildTunnel) public {
        require(fxChildTunnel == address(0x0), "FxBaseRootTunnel: CHILD_TUNNEL_ALREADY_SET");
        fxChildTunnel = _fxChildTunnel;
    }

    function _sendMessageToChild(bytes memory message) internal {
        fxRoot.sendMessageToChild(fxChildTunnel, message);
    }

    function _validateAndExtractMessage(bytes memory inputData) internal returns (bytes memory) {
        RLPReader.RLPItem[] memory inputDataRLPList = inputData
        .toRlpItem()
        .toList();

        bytes32 exitHash = keccak256(
            abi.encodePacked(
                inputDataRLPList[2].toUint(), // blockNumber
                MerklePatriciaProof._getNibbleArray(inputDataRLPList[8].toBytes()), // branchMask
                inputDataRLPList[9].toUint() // receiptLogIndex
            )
        );
        require(
            processedExits[exitHash] == false,
            "FxRootTunnel: EXIT_ALREADY_PROCESSED"
        );
        processedExits[exitHash] = true;

        RLPReader.RLPItem[] memory receiptRLPList = inputDataRLPList[6]
        .toBytes()
        .toRlpItem()
        .toList();
        RLPReader.RLPItem memory logRLP = receiptRLPList[3]
        .toList()[
        inputDataRLPList[9].toUint() // receiptLogIndex
        ];

        RLPReader.RLPItem[] memory logRLPList = logRLP.toList();

        require(fxChildTunnel == RLPReader.toAddress(logRLPList[0]), "FxRootTunnel: INVALID_FX_CHILD_TUNNEL");

        require(
            MerklePatriciaProof.verify(
                inputDataRLPList[6].toBytes(), // receipt
                inputDataRLPList[8].toBytes(), // branchMask
                inputDataRLPList[7].toBytes(), // receiptProof
                bytes32(inputDataRLPList[5].toUint()) // receiptRoot
            ),
            "FxRootTunnel: INVALID_RECEIPT_PROOF"
        );

        _checkBlockMembershipInCheckpoint(
            inputDataRLPList[2].toUint(), // blockNumber
            inputDataRLPList[3].toUint(), // blockTime
            bytes32(inputDataRLPList[4].toUint()), // txRoot
            bytes32(inputDataRLPList[5].toUint()), // receiptRoot
            inputDataRLPList[0].toUint(), // headerNumber
            inputDataRLPList[1].toBytes() // blockProof
        );

        RLPReader.RLPItem[] memory logTopicRLPList = logRLPList[1].toList(); // topics

        require(
            bytes32(logTopicRLPList[0].toUint()) == SEND_MESSAGE_EVENT_SIG, // topic0 is event sig
            "FxRootTunnel: INVALID_SIGNATURE"
        );

        bytes memory receivedData = logRLPList[2].toBytes();
        (bytes memory message) = abi.decode(receivedData, (bytes)); // event decodes params again, so decoding bytes to get message
        return message;
    }

    function _checkBlockMembershipInCheckpoint(
        uint256 blockNumber,
        uint256 blockTime,
        bytes32 txRoot,
        bytes32 receiptRoot,
        uint256 headerNumber,
        bytes memory blockProof
    ) private view returns (uint256) {
        (
        bytes32 headerRoot,
        uint256 startBlock,
        ,
        uint256 createdAt,

        ) = checkpointManager.headerBlocks(headerNumber);

        require(
            keccak256(
                abi.encodePacked(blockNumber, blockTime, txRoot, receiptRoot)
            )
            .checkMembership(
                blockNumber-startBlock,
                headerRoot,
                blockProof
            ),
            "FxRootTunnel: INVALID_HEADER"
        );
        return createdAt;
    }

    function receiveMessage(bytes memory inputData) public virtual {
        bytes memory message = _validateAndExtractMessage(inputData);
        _processMessageFromChild(message);
    }

    function _processMessageFromChild(bytes memory message) virtual internal;
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}


interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}


library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}


library EnumerableMap {


    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;

        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;


            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {

        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {

        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {

        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}


library Strings {

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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping (uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function baseURI() public view virtual returns (string memory) {

        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {

        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
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

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId); // internal owner

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own"); // internal owner
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {

        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId); // internal owner
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}


interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}


interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}




contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using SafeMath for uint256;
    using Address for address;

    mapping (uint256 => mapping(address => uint256)) private _balances;

    mapping (address => mapping(address => bool)) private _operatorApprovals;

    mapping (uint256 => string) internal tokenUris;

    mapping(uint256 => uint256) public tokenTotalSupply;

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC1155);

        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    function uri(uint256 tokenId) external view override returns (string memory) {
        return tokenUris[tokenId];
    }

    function balanceOf(address account, uint256 id) public view override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
    public
    view
    override
    returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            require(accounts[i] != address(0), "ERC1155: batch balance query for the zero address");
            batchBalances[i] = _balances[ids[i]][accounts[i]];
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) external virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
    external
    virtual
    override
    {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
    external
    virtual
    override
    {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(uint256 tokenId, string memory newuri) internal virtual {
        tokenUris[tokenId] = newuri;
        emit URI(newuri, tokenId);
    }

    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] = _balances[id][account].add(amount);
        tokenTotalSupply[id] = tokenTotalSupply[id].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            _balances[id][to] = amount.add(_balances[id][to]);
            tokenTotalSupply[id] = tokenTotalSupply[id].add(amount);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(address account, uint256 id, uint256 amount) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        tokenTotalSupply[id] = tokenTotalSupply[id].sub(amount);

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            _balances[id][account] = _balances[id][account].sub(
                amount,
                "ERC1155: burn amount exceeds balance"
            );

            tokenTotalSupply[id] = tokenTotalSupply[id].sub(amount);
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
    internal virtual
    { }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
    private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
    private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}


interface IERC998ERC1155TopDown is IERC1155Receiver {

    event ReceivedChild(address indexed from, uint256 indexed toTokenId, address indexed childContract, uint256 childTokenId, uint256 amount);
    event TransferBatchChild(uint256 indexed fromTokenId, address indexed to, address indexed childContract, uint256[] childTokenIds, uint256[] amounts);

    function childContractsFor(uint256 tokenId) external view returns (address[] memory childContracts);
    function childIdsForOn(uint256 tokenId, address childContract) external view returns (uint256[] memory childIds);
    function childBalance(uint256 tokenId, address childContract, uint256 childTokenId) external view returns (uint256);
}

abstract contract BaseChildTunnel {

    modifier onlyStateSyncer() {
        require(
            msg.sender == 0x0000000000000000000000000000000000001001,
            "Child tunnel: caller is not the state syncer"
        );
        _;
    }

    event MessageSent(bytes message);

    function onStateReceive(uint256, bytes memory message) public onlyStateSyncer{
        _processMessageFromRoot(message);
    }

    function _sendMessageToRoot(bytes memory message) internal {
        emit MessageSent(message);
    }

    function _processMessageFromRoot(bytes memory message) virtual internal;
}


abstract contract IRelayRecipient {

    function isTrustedForwarder(address forwarder) public virtual view returns(bool);

    function msgSender() internal virtual view returns (address payable);

    function versionRecipient() external virtual view returns (string memory);
}


abstract contract BaseRelayRecipient is IRelayRecipient {

    address public trustedForwarder;

    modifier trustedForwarderOnly() {
        require(msg.sender == address(trustedForwarder), "Function can only be called through the trusted Forwarder");
        _;
    }

    function isTrustedForwarder(address forwarder) public override view returns(bool) {
        return forwarder == trustedForwarder;
    }

    function msgSender() internal override view returns (address payable ret) {
        if (msg.data.length >= 24 && isTrustedForwarder(msg.sender)) {
            assembly {
                ret := shr(96,calldataload(sub(calldatasize(),20)))
            }
        } else {
            return msg.sender;
        }
    }
}


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


contract DigitalaxAccessControls is AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant SMART_CONTRACT_ROLE = keccak256("SMART_CONTRACT_ROLE");
    bytes32 public constant VERIFIED_MINTER_ROLE = keccak256("VERIFIED_MINTER_ROLE");

    event AdminRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event AdminRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    event MinterRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event MinterRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    event SmartContractRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event SmartContractRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    event VerifiedMinterRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );

    event VerifiedMinterRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );

    constructor() public {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }


    function hasAdminRole(address _address) external view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    function hasMinterRole(address _address) external view returns (bool) {
        return hasRole(MINTER_ROLE, _address);
    }

    function hasVerifiedMinterRole(address _address)
        external
        view
        returns (bool)
    {
        return hasRole(VERIFIED_MINTER_ROLE, _address);
    }

    function hasSmartContractRole(address _address) external view returns (bool) {
        return hasRole(SMART_CONTRACT_ROLE, _address);
    }


    function addAdminRole(address _address) external {
        grantRole(DEFAULT_ADMIN_ROLE, _address);
        emit AdminRoleGranted(_address, _msgSender());
    }

    function removeAdminRole(address _address) external {
        revokeRole(DEFAULT_ADMIN_ROLE, _address);
        emit AdminRoleRemoved(_address, _msgSender());
    }

    function addMinterRole(address _address) external {
        grantRole(MINTER_ROLE, _address);
        emit MinterRoleGranted(_address, _msgSender());
    }

    function removeMinterRole(address _address) external {
        revokeRole(MINTER_ROLE, _address);
        emit MinterRoleRemoved(_address, _msgSender());
    }

    function addVerifiedMinterRole(address _address) external {
        grantRole(VERIFIED_MINTER_ROLE, _address);
        emit VerifiedMinterRoleGranted(_address, _msgSender());
    }

    function removeVerifiedMinterRole(address _address) external {
        revokeRole(VERIFIED_MINTER_ROLE, _address);
        emit VerifiedMinterRoleRemoved(_address, _msgSender());
    }

    function addSmartContractRole(address _address) external {
        grantRole(SMART_CONTRACT_ROLE, _address);
        emit SmartContractRoleGranted(_address, _msgSender());
    }

    function removeSmartContractRole(address _address) external {
        revokeRole(SMART_CONTRACT_ROLE, _address);
        emit SmartContractRoleRemoved(_address, _msgSender());
    }
}


contract DigitalaxGarmentNFT is ERC721("DigitalaxNFT", "DTX"), ERC1155Receiver, IERC998ERC1155TopDown, BaseChildTunnel, BaseRelayRecipient {

    event DigitalaxGarmentNFTContractDeployed();

    event DigitalaxGarmentTokenUriUpdate(
        uint256 indexed _tokenId,
        string _tokenUri
    );

    event TokenPrimarySalePriceSet(
        uint256 indexed _tokenId,
        uint256 _salePrice
    );

    event WithdrawnBatch(
        address indexed user,
        uint256[] tokenIds
    );

    ERC1155 public childContract;

    uint256 public tokenIdPointer;

    mapping(uint256 => address) public garmentDesigners;

    mapping(uint256 => uint256) public primarySalePrice;

    mapping(uint256 => mapping(uint256 => uint256)) private balances;

    mapping(uint256 => EnumerableSet.UintSet) private childToParentMapping;

    mapping(uint256 => EnumerableSet.UintSet) private parentToChildMapping;

    uint256 public maxChildrenPerToken = 10;

    uint256 public constant BATCH_LIMIT = 20;

    mapping (uint256 => bool) public withdrawnTokens;

    address public childChain;

    modifier onlyChildChain() {
        require(
            _msgSender() == childChain,
            "Child token: caller is not the child chain contract"
        );
        _;
    }
    DigitalaxAccessControls public accessControls;

    constructor(DigitalaxAccessControls _accessControls, ERC1155 _childContract, address _childChain, address _trustedForwarder) public {
        accessControls = _accessControls;
        childContract = _childContract;
        childChain = _childChain;
        trustedForwarder = _trustedForwarder;
        emit DigitalaxGarmentNFTContractDeployed();
    }

    function versionRecipient() external view override returns (string memory) {
        return "1";
    }

    function setTrustedForwarder(address _trustedForwarder) external  {
        require(
            accessControls.hasAdminRole(_msgSender()),
            "DigitalaxGarmentNFT.setTrustedForwarder: Sender must be admin"
        );
        trustedForwarder = _trustedForwarder;
    }

    function _msgSender()
    internal
    override
    view
    returns (address payable sender)
    {
        return BaseRelayRecipient.msgSender();
    }

    function mint(address _beneficiary, string calldata _tokenUri, address _designer) external returns (uint256) {
        require(
            accessControls.hasSmartContractRole(_msgSender()) || accessControls.hasMinterRole(_msgSender()),
            "DigitalaxGarmentNFT.mint: Sender must have the minter or contract role"
        );

        _assertMintingParamsValid(_tokenUri, _designer);

        tokenIdPointer = tokenIdPointer.add(1);
        uint256 tokenId = tokenIdPointer;

        require(!withdrawnTokens[tokenId], "ChildMintableERC721: TOKEN_EXISTS_ON_ROOT_CHAIN");

        _safeMint(_beneficiary, tokenId);
        _setTokenURI(tokenId, _tokenUri);

        garmentDesigners[tokenId] = _designer;

        return tokenId;
    }

    function burn(uint256 _tokenId) public {
        address operator = _msgSender();
        require(
            ownerOf(_tokenId) == operator || isApproved(_tokenId, operator),
            "DigitalaxGarmentNFT.burn: Only garment owner or approved"
        );

        if (parentToChildMapping[_tokenId].length() > 0) {
            _extractAndTransferChildrenFromParent(_tokenId, _msgSender());
        }

        _burn(_tokenId);

        delete garmentDesigners[_tokenId];
        delete primarySalePrice[_tokenId];
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes memory _data)
    virtual
    external
    override
    returns (bytes4) {
        require(_data.length == 32, "ERC998: data must contain the unique uint256 tokenId to transfer the child token to");

        uint256 _receiverTokenId = _extractIncomingTokenId();
        _validateReceiverParams(_receiverTokenId, _operator, _from);

        _receiveChild(_receiverTokenId, _msgSender(), _id, _amount);

        emit ReceivedChild(_from, _receiverTokenId, _msgSender(), _id, _amount);

        require(
            parentToChildMapping[_receiverTokenId].length() <= maxChildrenPerToken,
            "Cannot exceed max child token allocation"
        );

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] memory _ids, uint256[] memory _values, bytes memory _data)
    virtual
    external
    override
    returns (bytes4) {
        require(_data.length == 32, "ERC998: data must contain the unique uint256 tokenId to transfer the child token to");

        uint256 _receiverTokenId = _extractIncomingTokenId();
        _validateReceiverParams(_receiverTokenId, _operator, _from);

        for (uint256 i = 0; i < _ids.length; i++) {
            _receiveChild(_receiverTokenId, _msgSender(), _ids[i], _values[i]);
            emit ReceivedChild(_from, _receiverTokenId, _msgSender(), _ids[i], _values[i]);
        }

        require(
            parentToChildMapping[_receiverTokenId].length() <= maxChildrenPerToken,
            "Cannot exceed max child token allocation"
        );

        return this.onERC1155BatchReceived.selector;
    }

    function _extractIncomingTokenId() internal pure returns (uint256) {
        uint256 _receiverTokenId;
        uint256 _index = msg.data.length - 32;
        assembly {_receiverTokenId := calldataload(_index)}
        return _receiverTokenId;
    }

    function _validateReceiverParams(uint256 _receiverTokenId, address _operator, address _from) internal view {
        require(_exists(_receiverTokenId), "Token does not exist");

        require(_msgSender() == address(childContract), "Invalid child token contract");

        if (_from != address(0)) {
            require(
                ownerOf(_receiverTokenId) == _from,
                "Cannot add children to tokens you dont own"
            );

            require(_operator == _from, "Operator is not owner");
        }
    }


    function setTokenURI(uint256 _tokenId, string calldata _tokenUri) external {
        require(
            accessControls.hasSmartContractRole(_msgSender()) || accessControls.hasAdminRole(_msgSender()),
            "DigitalaxGarmentNFT.setTokenURI: Sender must be an authorised contract or admin"
        );
        _setTokenURI(_tokenId, _tokenUri);
        emit DigitalaxGarmentTokenUriUpdate(_tokenId, _tokenUri);
    }

    function setPrimarySalePrice(uint256 _tokenId, uint256 _salePrice) external {
        require(
            accessControls.hasSmartContractRole(_msgSender()) || accessControls.hasAdminRole(_msgSender()),
            "DigitalaxGarmentNFT.setPrimarySalePrice: Sender must be an authorised contract or admin"
        );
        require(_exists(_tokenId), "DigitalaxGarmentNFT.setPrimarySalePrice: Token does not exist");
        require(_salePrice > 0, "DigitalaxGarmentNFT.setPrimarySalePrice: Invalid sale price");

        if (primarySalePrice[_tokenId] == 0) {
            primarySalePrice[_tokenId] = _salePrice;
            emit TokenPrimarySalePriceSet(_tokenId, _salePrice);
        }
    }

    function updateAccessControls(DigitalaxAccessControls _accessControls) external {
        require(accessControls.hasAdminRole(_msgSender()), "DigitalaxGarmentNFT.updateAccessControls: Sender must be admin");
        accessControls = _accessControls;
    }

    function updateMaxChildrenPerToken(uint256 _maxChildrenPerToken) external {
        require(accessControls.hasAdminRole(_msgSender()), "DigitalaxGarmentNFT.updateMaxChildrenPerToken: Sender must be admin");
        maxChildrenPerToken = _maxChildrenPerToken;
    }


    function exists(uint256 _tokenId) external view returns (bool) {
        return _exists(_tokenId);
    }

    function childBalance(uint256 _tokenId, address _childContract, uint256 _childTokenId)
    public
    view
    override
    returns (uint256) {
        return _childContract == address(childContract) ? balances[_tokenId][_childTokenId] : 0;
    }

    function childContractsFor(uint256 _tokenId) override external view returns (address[] memory) {
        if (!_exists(_tokenId)) {
            return new address[](0);
        }

        address[] memory childContracts = new address[](1);
        childContracts[0] = address(childContract);
        return childContracts;
    }

    function childIdsForOn(uint256 _tokenId, address _childContract) override public view returns (uint256[] memory) {
        if (!_exists(_tokenId) || _childContract != address(childContract)) {
            return new uint256[](0);
        }

        uint256[] memory childTokenIds = new uint256[](parentToChildMapping[_tokenId].length());

        for (uint256 i = 0; i < parentToChildMapping[_tokenId].length(); i++) {
            childTokenIds[i] = parentToChildMapping[_tokenId].at(i);
        }

        return childTokenIds;
    }

    function totalChildrenMapped(uint256 _tokenId) external view returns (uint256) {
        return parentToChildMapping[_tokenId].length();
    }

    function isApproved(uint256 _tokenId, address _operator) public view returns (bool) {
        return isApprovedForAll(ownerOf(_tokenId), _operator) || getApproved(_tokenId) == _operator;
    }


    function _extractAndTransferChildrenFromParent(uint256 _fromTokenId, address _to) internal {
        uint256[] memory _childTokenIds = childIdsForOn(_fromTokenId, address(childContract));
        uint256[] memory _amounts = new uint256[](_childTokenIds.length);

        for (uint256 i = 0; i < _childTokenIds.length; ++i) {
            uint256 _childTokenId = _childTokenIds[i];
            uint256 amount = childBalance(_fromTokenId, address(childContract), _childTokenId);

            _amounts[i] = amount;

            _removeChild(_fromTokenId, address(childContract), _childTokenId, amount);
        }

        childContract.safeBatchTransferFrom(address(this), _to, _childTokenIds, _amounts, abi.encodePacked(""));

        emit TransferBatchChild(_fromTokenId, _to, address(childContract), _childTokenIds, _amounts);
    }

    function _receiveChild(uint256 _tokenId, address, uint256 _childTokenId, uint256 _amount) private {
        if (balances[_tokenId][_childTokenId] == 0) {
           parentToChildMapping[_tokenId].add(_childTokenId);
        }
        balances[_tokenId][_childTokenId] = balances[_tokenId][_childTokenId].add(_amount);
    }

    function _removeChild(uint256 _tokenId, address, uint256 _childTokenId, uint256 _amount) private {
        require(_amount != 0 || balances[_tokenId][_childTokenId] >= _amount, "ERC998: insufficient child balance for transfer");
        balances[_tokenId][_childTokenId] = balances[_tokenId][_childTokenId].sub(_amount);
        if (balances[_tokenId][_childTokenId] == 0) {
            childToParentMapping[_childTokenId].remove(_tokenId);
            parentToChildMapping[_tokenId].remove(_childTokenId);
        }
    }

    function _assertMintingParamsValid(string calldata _tokenUri, address _designer) pure internal {
        require(bytes(_tokenUri).length > 0, "DigitalaxGarmentNFT._assertMintingParamsValid: Token URI is empty");
        require(_designer != address(0), "DigitalaxGarmentNFT._assertMintingParamsValid: Designer is zero address");
    }


    function deposit(address user, bytes calldata depositData)
    external
    onlyChildChain
    {
        if (depositData.length == 32) {
            uint256 tokenId = abi.decode(depositData, (uint256));
            withdrawnTokens[tokenId] = false;
            _safeMint(user, tokenId);

        } else {
            uint256[] memory tokenIds = abi.decode(depositData, (uint256[]));
            uint256 length = tokenIds.length;
            for (uint256 i; i < length; i++) {

                withdrawnTokens[tokenIds[i]] = false;
                _safeMint(user, tokenIds[i]);
            }
        }
    }

    function withdraw(uint256 tokenId) external {
        withdrawnTokens[tokenId] = true;
        burn(tokenId);
    }

    function withdrawBatch(uint256[] calldata tokenIds) external {
        uint256 length = tokenIds.length;
        require(length <= BATCH_LIMIT, "ChildERC721: EXCEEDS_BATCH_LIMIT");
        for (uint256 i; i < length; i++) {
            uint256 tokenId = tokenIds[i];
            withdrawnTokens[tokenIds[i]] = true;
            burn(tokenId);
        }
        emit WithdrawnBatch(_msgSender(), tokenIds);
    }

    function _processMessageFromRoot(bytes memory message) internal override {
        uint256 _tokenId;
        uint256 _primarySalePrice;
        address _garmentDesigner;
        string memory _tokenUri;
        uint256[] memory _children;
        uint256[] memory _childrenBalances;
        (_tokenId, _primarySalePrice, _garmentDesigner, _tokenUri, _children, _childrenBalances) = abi.decode(message, (uint256, uint256, address, string, uint256[], uint256[]));

        primarySalePrice[_tokenId] = _primarySalePrice;
        garmentDesigners[_tokenId] = _garmentDesigner;
        _setTokenURI(_tokenId, _tokenUri);
        for (uint256 i = 0; i< _children.length; i++) {
            _receiveChild(_tokenId, _msgSender(), _children[i], _childrenBalances[i]);
        }
    }

    function sendNFTToRoot(uint256 tokenId) external {
        uint256 _primarySalePrice = primarySalePrice[tokenId];
        address _garmentDesigner= garmentDesigners[tokenId];
        string memory _tokenUri = tokenURI(tokenId);
        uint256[] memory _children = childIdsForOn(tokenId, address(childContract));
        uint256 len = _children.length;
        uint256[] memory childBalances = new uint256[](len);
        for( uint256 i; i< _children.length; i++){
            childBalances[i] = childBalance(tokenId, address(childContract), _children[i]);
        }

        _sendMessageToRoot(abi.encode(tokenId, ownerOf(tokenId), _primarySalePrice, _garmentDesigner, _tokenUri, _children, childBalances));
    }
}


abstract contract ERC1155Burnable is ERC1155 {
    function burn(address account, uint256 id, uint256 amount) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burn(account, id, amount);
    }

    function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) public virtual {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _burnBatch(account, ids, amounts);
    }
}


contract DigitalaxMaterials is ERC1155Burnable, BaseRelayRecipient {

    event DigitalaxMaterialsDeployed();

    event ChildCreated(
        uint256 indexed childId
    );

    event ChildrenCreated(
        uint256[] childIds
    );

    string public name;
    string public symbol;

    uint256 public tokenIdPointer;

    DigitalaxAccessControls public accessControls;

    address public childChain;

    modifier onlyChildChain() {
        require(
            _msgSender() == childChain,
            "Child token: caller is not the child chain contract"
        );
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        DigitalaxAccessControls _accessControls,
        address _childChain,
        address _trustedForwarder
    ) public {
        name = _name;
        symbol = _symbol;
        accessControls = _accessControls;
        trustedForwarder = _trustedForwarder;
        childChain = _childChain;
        emit DigitalaxMaterialsDeployed();
    }

    function versionRecipient() external view override returns (string memory) {
        return "1";
    }

    function setTrustedForwarder(address _trustedForwarder) external  {
        require(
            accessControls.hasAdminRole(_msgSender()),
            "DigitalaxMaterials.setTrustedForwarder: Sender must be admin"
        );
        trustedForwarder = _trustedForwarder;
    }

    function _msgSender()
    internal
    override
    view
    returns (address payable sender)
    {
        return BaseRelayRecipient.msgSender();
    }


    function createChild(string calldata _uri) external returns (uint256 id) {
        require(
            accessControls.hasSmartContractRole(_msgSender()),
            "DigitalaxMaterials.createChild: Sender must be smart contract"
        );

        require(bytes(_uri).length > 0, "DigitalaxMaterials.createChild: URI is a blank string");

        tokenIdPointer = tokenIdPointer.add(1);

        id = tokenIdPointer;
        _setURI(id, _uri);

        emit ChildCreated(id);
    }

    function batchCreateChildren(string[] calldata _uris) external returns (uint256[] memory tokenIds) {
        require(
            accessControls.hasSmartContractRole(_msgSender()),
            "DigitalaxMaterials.batchCreateChildren: Sender must be smart contract"
        );

        require(_uris.length > 0, "DigitalaxMaterials.batchCreateChildren: No data supplied in array");

        uint256 urisLength = _uris.length;
        tokenIds = new uint256[](urisLength);
        for (uint256 i = 0; i < urisLength; i++) {
            string memory uri = _uris[i];
            require(bytes(uri).length > 0, "DigitalaxMaterials.batchCreateChildren: URI is a blank string");
            tokenIdPointer = tokenIdPointer.add(1);

            _setURI(tokenIdPointer, uri);
            tokenIds[i] = tokenIdPointer;
        }

        emit ChildrenCreated(tokenIds);
    }


    function mintChild(uint256 _childTokenId, uint256 _amount, address _beneficiary, bytes calldata _data) external {
        require(
            accessControls.hasSmartContractRole(_msgSender()),
            "DigitalaxMaterials.mintChild: Sender must be smart contract"
        );

        require(bytes(tokenUris[_childTokenId]).length > 0, "DigitalaxMaterials.mintChild: Strand does not exist");
        require(_amount > 0, "DigitalaxMaterials.mintChild: No amount specified");

        _mint(_beneficiary, _childTokenId, _amount, _data);
    }

    function batchMintChildren(
        uint256[] calldata _childTokenIds,
        uint256[] calldata _amounts,
        address _beneficiary,
        bytes calldata _data
    ) external {
        require(
            accessControls.hasSmartContractRole(_msgSender()),
            "DigitalaxMaterials.batchMintChildren: Sender must be smart contract"
        );

        require(_childTokenIds.length == _amounts.length, "DigitalaxMaterials.batchMintChildren: Array lengths are invalid");
        require(_childTokenIds.length > 0, "DigitalaxMaterials.batchMintChildren: No data supplied in arrays");

        for (uint256 i = 0; i < _childTokenIds.length; i++) {
            uint256 strandId = _childTokenIds[i];
            require(bytes(tokenUris[strandId]).length > 0, "DigitalaxMaterials.batchMintChildren: Strand does not exist");

            uint256 amount = _amounts[i];
            require(amount > 0, "DigitalaxMaterials.batchMintChildren: Invalid amount");
        }

        _mintBatch(_beneficiary, _childTokenIds, _amounts, _data);
    }

    function updateAccessControls(DigitalaxAccessControls _accessControls) external {
        require(
            accessControls.hasAdminRole(_msgSender()),
            "DigitalaxMaterials.updateAccessControls: Sender must be admin"
        );

        require(
            address(_accessControls) != address(0),
            "DigitalaxMaterials.updateAccessControls: New access controls cannot be ZERO address"
        );

        accessControls = _accessControls;
    }

    function deposit(address user, bytes calldata depositData)
    external
    onlyChildChain
    {
        (
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
        ) = abi.decode(depositData, (uint256[], uint256[], bytes));
        require(user != address(0x0), "DigitalaxMaterials: INVALID_DEPOSIT_USER");
        _mintBatch(user, ids, amounts, data);
    }

    function withdrawSingle(uint256 id, uint256 amount) external {
        _burn(_msgSender(), id, amount);
    }

    function withdrawBatch(uint256[] calldata ids, uint256[] calldata amounts)
    external
    {
        _burnBatch(_msgSender(), ids, amounts);
    }
}


contract FxStateRootTunnel is FxBaseRootTunnel {
    bytes public latestData;
    DigitalaxGarmentNFT public nft;
    DigitalaxMaterials public child;
    mapping (uint256 => bool) public withdrawnTokens;
    event RootMessageSent(bytes message);

    event NFTSentToChild(uint256[] tokenIds, address[] owners, uint256[] primarySalePrices, address[] designers, string[] tokenUris);
    event NFTReceivedFromChild(uint256[] tokenIds, address[] owners, uint256[] primarySalePrices, address[] designers, string[] tokenUris);


    constructor(address _checkpointManager, address _fxRoot, DigitalaxGarmentNFT _nft, DigitalaxMaterials _child)  FxBaseRootTunnel(_checkpointManager, _fxRoot) public {
        nft = _nft;
        child = _child;
    }

    function _processMessageFromChild(bytes memory data) internal override {
        latestData = data;
        address[] memory _owners;
        uint256[] memory _tokenIds;
        uint256[] memory _primarySalePrices;
        address[] memory _garmentDesigners;
        string[] memory _tokenUris;
        uint256[][] memory _children;
        string[][] memory _childrenURIs;
        uint256[][] memory _childrenBalances;
        ( _tokenIds, _owners, _primarySalePrices, _garmentDesigners, _tokenUris, _children, _childrenURIs, _childrenBalances) = abi.decode(data, (uint256[], address[], uint256[], address[], string[], uint256[][], string[][], uint256[][]));
        for( uint256 i; i< _tokenIds.length; i++){

            if(!nft.exists(_tokenIds[i])){
                uint256 newTokenId = nft.mint(_owners[i], _tokenUris[i], _garmentDesigners[i]);
                if(_primarySalePrices[i] > 0) {
                    nft.setPrimarySalePrice(newTokenId, _primarySalePrices[i]);
                }
                if(_children[i].length > 0){
                    for( uint256 j; j< _children[i].length; j++){
                        uint256 newChildId = child.createChild(_childrenURIs[i][j]);
                        child.mintChild(newChildId, _childrenBalances[i][j], address(nft), abi.encodePacked(newTokenId));
                    }
                }
            }
        }

        emit NFTReceivedFromChild(_tokenIds, _owners, _primarySalePrices, _garmentDesigners, _tokenUris);
    }

    function sendNFTsToChild(uint256[] memory _tokenIds) public {
        uint256 length = _tokenIds.length;
        uint256[] memory _salePrices = new uint256[](length);
        address[] memory _designers = new address[](length);
        string[] memory _tokenUris = new string[](length);
        address[] memory _owners = new address[](length);
        uint256[][] memory childNftIdArray = new uint256[][](length);
        string[][] memory childNftURIArray = new string[][](length);
        uint256[][] memory childNftBalanceArray = new uint256[][](length);

        for( uint256 i; i< _tokenIds.length; i++){
            _owners[i] = nft.ownerOf(_tokenIds[i]);
            require(_owners[i] == msg.sender, "FxStateRootTunnel.sendNFTsToChild: can only be sent by the same user");
            require(nft.exists(_tokenIds[i]), "FxStateRootTunnel.sendNFTsToChild: token does not exist");
            nft.transferFrom(msg.sender, address(this), _tokenIds[i]);
            _salePrices[i] = nft.primarySalePrice(_tokenIds[i]);
            _designers[i] = nft.garmentDesigners(_tokenIds[i]);
            _tokenUris[i] = nft.tokenURI(_tokenIds[i]);

            childNftIdArray[i] = nft.childIdsForOn(_tokenIds[i], address(child));
            childNftURIArray[i] = childURIsForOn(childNftIdArray[i]);
            uint256 len = childNftIdArray[i].length;
            uint256[] memory garmentAmounts = new uint256[](len);
            for( uint256 j; j< len; j++){
                garmentAmounts[j] = nft.childBalance(_tokenIds[i], address(child), childNftIdArray[i][j]);
            }
            childNftBalanceArray[i] = garmentAmounts;
            nft.burn(_tokenIds[i]);
            withdrawnTokens[_tokenIds[i]] = true;

            child.burnBatch(address(this), childNftIdArray[i], childNftBalanceArray[i]);
        }
        bytes memory message = abi.encode(_tokenIds, _owners, _salePrices, _designers, _tokenUris, childNftIdArray, childNftURIArray, childNftBalanceArray);
        _sendMessageToChild(message);
        emit RootMessageSent(message);
        emit NFTSentToChild(_tokenIds, _owners, _salePrices, _designers, _tokenUris);

    }

    function childURIsForOn(uint256[] memory childNftIdArray) public view returns (string[] memory) {
        uint256 mappingLength = childNftIdArray.length;
        string[] memory childTokenURIs = new string[](mappingLength);

        for (uint256 i = 0; i < mappingLength; i++) {
            childTokenURIs[i] = child.uri(childNftIdArray[i]);
        }

        return childTokenURIs;
    }


    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public
    returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes memory _data)
    external
    returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] memory _ids, uint256[] memory _values, bytes memory _data)
    external
    returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}