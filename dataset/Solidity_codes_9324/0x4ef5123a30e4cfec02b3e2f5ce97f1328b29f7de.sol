

pragma solidity ^0.5.2;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.2;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}


pragma solidity ^0.5.2;



contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 value) internal {

        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}


pragma solidity ^0.5.2;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.5.2;


contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view returns (address owner);


    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function transferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId) public;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}


pragma solidity ^0.5.2;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}


pragma solidity ^0.5.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


pragma solidity ^0.5.2;


library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}


pragma solidity ^0.5.2;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}


pragma solidity ^0.5.2;







contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => Counters.Counter) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0));
        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId));

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0));
        require(!_exists(tokenId));

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner);

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from);
        require(to != address(0));

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}


pragma solidity ^0.5.2;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
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


pragma solidity ^0.5.2;

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


pragma solidity ^0.5.2;


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

        uint256 len;
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
        private
        pure
        returns (bytes memory)
    {

        bytes memory nibbles;
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


pragma solidity ^0.5.2;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.2;



contract PriorityQueue is Ownable {

    using SafeMath for uint256;

    uint256[] heapList;
    uint256 public currentSize;

    constructor() public {
        heapList = [0];
    }

    function insert(uint256 _priority, uint256 _value) public onlyOwner {

        uint256 element = (_priority << 128) | _value;
        heapList.push(element);
        currentSize = currentSize.add(1);
        _percUp(currentSize);
    }

    function getMin() public view returns (uint256, uint256) {

        return _splitElement(heapList[1]);
    }

    function delMin() public onlyOwner returns (uint256, uint256) {

        uint256 retVal = heapList[1];
        heapList[1] = heapList[currentSize];
        delete heapList[currentSize];
        currentSize = currentSize.sub(1);
        _percDown(1);
        heapList.length = heapList.length.sub(1);
        return _splitElement(retVal);
    }

    function _minChild(uint256 _index) private view returns (uint256) {

        if (_index.mul(2).add(1) > currentSize) {
            return _index.mul(2);
        } else {
            if (heapList[_index.mul(2)] < heapList[_index.mul(2).add(1)]) {
                return _index.mul(2);
            } else {
                return _index.mul(2).add(1);
            }
        }
    }

    function _percUp(uint256 _index) private {

        uint256 index = _index;
        uint256 j = index;
        uint256 newVal = heapList[index];

        while (newVal < heapList[index.div(2)]) {
            heapList[index] = heapList[index.div(2)];
            index = index.div(2);
        }

        if (index != j) {
            heapList[index] = newVal;
        }
    }

    function _percDown(uint256 _index) private {

        uint256 index = _index;
        uint256 j = index;
        uint256 newVal = heapList[index];
        uint256 mc = _minChild(index);
        while (mc <= currentSize && newVal > heapList[mc]) {
            heapList[index] = heapList[mc];
            index = mc;
            mc = _minChild(index);
        }

        if (index != j) {
            heapList[index] = newVal;
        }
    }

    function _splitElement(uint256 _element)
        private
        pure
        returns (uint256, uint256)
    {

        uint256 priority = _element >> 128;
        uint256 value = uint256(uint128(_element));
        return (priority, value);
    }
}


pragma solidity ^0.5.2;


library BytesLib {

    function concat(bytes memory _preBytes, bytes memory _postBytes)
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

            mstore(
                0x40,
                and(
                    add(add(end, iszero(add(length, mload(_preBytes)))), 31),
                    not(31) // Round down to the nearest 32 bytes.
                )
            )
        }
        return tempBytes;
    }

    function slice(bytes memory _bytes, uint256 _start, uint256 _length)
        internal
        pure
        returns (bytes memory)
    {

        require(_bytes.length >= (_start + _length));
        bytes memory tempBytes;
        assembly {
            switch iszero(_length)
                case 0 {
                    tempBytes := mload(0x40)

                    let lengthmod := and(_length, 31)

                    let mc := add(
                        add(tempBytes, lengthmod),
                        mul(0x20, iszero(lengthmod))
                    )
                    let end := add(mc, _length)

                    for {
                        let cc := add(
                            add(
                                add(_bytes, lengthmod),
                                mul(0x20, iszero(lengthmod))
                            ),
                            _start
                        )
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
                    mstore(0x40, add(tempBytes, 0x20))
                }
        }

        return tempBytes;
    }

    function leftPad(bytes memory _bytes) internal pure returns (bytes memory) {

        bytes memory newBytes = new bytes(SafeMath.sub(32, _bytes.length));
        return concat(newBytes, _bytes);
    }

    function toBytes32(bytes memory b) internal pure returns (bytes32) {

        require(b.length >= 32, "Bytes array should atleast be 32 bytes");
        bytes32 out;
        for (uint256 i = 0; i < 32; i++) {
            out |= bytes32(b[i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function toBytes4(bytes memory b) internal pure returns (bytes4 result) {

        assembly {
            result := mload(add(b, 32))
        }
    }

    function fromBytes32(bytes32 x) internal pure returns (bytes memory) {

        bytes memory b = new bytes(32);
        for (uint256 i = 0; i < 32; i++) {
            b[i] = bytes1(uint8(uint256(x) / (2**(8 * (31 - i)))));
        }
        return b;
    }

    function fromUint(uint256 _num) internal pure returns (bytes memory _ret) {

        _ret = new bytes(32);
        assembly {
            mstore(add(_ret, 32), _num)
        }
    }

    function toUint(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (uint256)
    {

        require(_bytes.length >= (_start + 32));
        uint256 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }
        return tempUint;
    }

    function toAddress(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (address)
    {

        require(_bytes.length >= (_start + 20));
        address tempAddress;
        assembly {
            tempAddress := div(
                mload(add(add(_bytes, 0x20), _start)),
                0x1000000000000000000000000
            )
        }

        return tempAddress;
    }
}


pragma solidity 0.5.17;



library ExitPayloadReader {

  using RLPReader for bytes;
  using RLPReader for RLPReader.RLPItem;

  uint8 constant WORD_SIZE = 32;

  struct ExitPayload {
    RLPReader.RLPItem[] data;
  }

  struct Receipt {
    RLPReader.RLPItem[] data;
    bytes raw;
    uint256 logIndex;
  }

  struct Log {
    RLPReader.RLPItem data;
    RLPReader.RLPItem[] list;
  }

  struct LogTopics {
    RLPReader.RLPItem[] data;
  }

  function toExitPayload(bytes memory data)
        internal
        pure
        returns (ExitPayload memory)
    {

        RLPReader.RLPItem[] memory payloadData = data
            .toRlpItem()
            .toList();

        return ExitPayload(payloadData);
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

    function getHeaderNumber(ExitPayload memory payload) internal pure returns(uint256) {

      return payload.data[0].toUint();
    }

    function getBlockProof(ExitPayload memory payload) internal pure returns(bytes memory) {

      return payload.data[1].toBytes();
    }

    function getBlockNumber(ExitPayload memory payload) internal pure returns(uint256) {

      return payload.data[2].toUint();
    }

    function getBlockTime(ExitPayload memory payload) internal pure returns(uint256) {

      return payload.data[3].toUint();
    }

    function getTxRoot(ExitPayload memory payload) internal pure returns(bytes32) {

      return bytes32(payload.data[4].toUint());
    }

    function getReceiptRoot(ExitPayload memory payload) internal pure returns(bytes32) {

      return bytes32(payload.data[5].toUint());
    }

    function getReceipt(ExitPayload memory payload) internal pure returns(Receipt memory receipt) {

      receipt.raw = payload.data[6].toBytes();
      RLPReader.RLPItem memory receiptItem = receipt.raw.toRlpItem();

      if (receiptItem.isList()) {
          receipt.data = receiptItem.toList();
      } else {
          bytes memory typedBytes = receipt.raw;
          bytes memory result = new bytes(typedBytes.length - 1);
          uint256 srcPtr;
          uint256 destPtr;
          assembly {
              srcPtr := add(33, typedBytes)
              destPtr := add(0x20, result)
          }

          copy(srcPtr, destPtr, result.length);
          receipt.data = result.toRlpItem().toList();
      }

      receipt.logIndex = getReceiptLogIndex(payload);
      return receipt;
    }

    function getReceiptProof(ExitPayload memory payload) internal pure returns(bytes memory) {

      return payload.data[7].toBytes();
    }

    function getBranchMaskAsBytes(ExitPayload memory payload) internal pure returns(bytes memory) {

      return payload.data[8].toBytes();
    }

    function getBranchMaskAsUint(ExitPayload memory payload) internal pure returns(uint256) {

      return payload.data[8].toUint();
    }

    function getReceiptLogIndex(ExitPayload memory payload) internal pure returns(uint256) {

      return payload.data[9].toUint();
    }

    function getTx(ExitPayload memory payload) internal pure returns(bytes memory) {

      return payload.data[10].toBytes();
    }

    function getTxProof(ExitPayload memory payload) internal pure returns(bytes memory) {

      return payload.data[11].toBytes();
    }
    
    function toBytes(Receipt memory receipt) internal pure returns(bytes memory) {

        return receipt.raw;
    }

    function getLog(Receipt memory receipt) internal pure returns(Log memory) {

        RLPReader.RLPItem memory logData = receipt.data[3].toList()[receipt.logIndex];
        return Log(logData, logData.toList());
    }

    function getEmitter(Log memory log) internal pure returns(address) {

      return RLPReader.toAddress(log.list[0]);
    }

    function getTopics(Log memory log) internal pure returns(LogTopics memory) {

        return LogTopics(log.list[1].toList());
    }

    function getData(Log memory log) internal pure returns(bytes memory) {

        return log.list[2].toBytes();
    }

    function toRlpBytes(Log memory log) internal pure returns(bytes memory) {

      return log.data.toRlpBytes();
    }

    function getField(LogTopics memory topics, uint256 index) internal pure returns(RLPReader.RLPItem memory) {

      return topics.data[index];
    }
}


pragma solidity ^0.5.2;

interface IGovernance {

    function update(address target, bytes calldata data) external;

}


pragma solidity ^0.5.2;


contract Governable {

    IGovernance public governance;

    constructor(address _governance) public {
        governance = IGovernance(_governance);
    }

    modifier onlyGovernance() {

        _assertGovernance();
        _;
    }

    function _assertGovernance() private view {

        require(
            msg.sender == address(governance),
            "Only governance contract is authorized"
        );
    }
}


pragma solidity ^0.5.2;

contract IWithdrawManager {

    function createExitQueue(address token) external;


    function verifyInclusion(
        bytes calldata data,
        uint8 offset,
        bool verifyTxInclusion
    ) external view returns (uint256 age);


    function addExitToQueue(
        address exitor,
        address childToken,
        address rootToken,
        uint256 exitAmountOrTokenId,
        bytes32 txHash,
        bool isRegularExit,
        uint256 priority
    ) external;


    function addInput(
        uint256 exitId,
        uint256 age,
        address utxoOwner,
        address token
    ) external;


    function challengeExit(
        uint256 exitId,
        uint256 inputId,
        bytes calldata challengeData,
        address adjudicatorPredicate
    ) external;

}


pragma solidity ^0.5.2;




contract Registry is Governable {

    bytes32 private constant WETH_TOKEN = keccak256("wethToken");
    bytes32 private constant DEPOSIT_MANAGER = keccak256("depositManager");
    bytes32 private constant STAKE_MANAGER = keccak256("stakeManager");
    bytes32 private constant VALIDATOR_SHARE = keccak256("validatorShare");
    bytes32 private constant WITHDRAW_MANAGER = keccak256("withdrawManager");
    bytes32 private constant CHILD_CHAIN = keccak256("childChain");
    bytes32 private constant STATE_SENDER = keccak256("stateSender");
    bytes32 private constant SLASHING_MANAGER = keccak256("slashingManager");

    address public erc20Predicate;
    address public erc721Predicate;

    mapping(bytes32 => address) public contractMap;
    mapping(address => address) public rootToChildToken;
    mapping(address => address) public childToRootToken;
    mapping(address => bool) public proofValidatorContracts;
    mapping(address => bool) public isERC721;

    enum Type {Invalid, ERC20, ERC721, Custom}
    struct Predicate {
        Type _type;
    }
    mapping(address => Predicate) public predicates;

    event TokenMapped(address indexed rootToken, address indexed childToken);
    event ProofValidatorAdded(address indexed validator, address indexed from);
    event ProofValidatorRemoved(address indexed validator, address indexed from);
    event PredicateAdded(address indexed predicate, address indexed from);
    event PredicateRemoved(address indexed predicate, address indexed from);
    event ContractMapUpdated(bytes32 indexed key, address indexed previousContract, address indexed newContract);

    constructor(address _governance) public Governable(_governance) {}

    function updateContractMap(bytes32 _key, address _address) external onlyGovernance {

        emit ContractMapUpdated(_key, contractMap[_key], _address);
        contractMap[_key] = _address;
    }

    function mapToken(
        address _rootToken,
        address _childToken,
        bool _isERC721
    ) external onlyGovernance {

        require(_rootToken != address(0x0) && _childToken != address(0x0), "INVALID_TOKEN_ADDRESS");
        rootToChildToken[_rootToken] = _childToken;
        childToRootToken[_childToken] = _rootToken;
        isERC721[_rootToken] = _isERC721;
        IWithdrawManager(contractMap[WITHDRAW_MANAGER]).createExitQueue(_rootToken);
        emit TokenMapped(_rootToken, _childToken);
    }

    function addErc20Predicate(address predicate) public onlyGovernance {

        require(predicate != address(0x0), "Can not add null address as predicate");
        erc20Predicate = predicate;
        addPredicate(predicate, Type.ERC20);
    }

    function addErc721Predicate(address predicate) public onlyGovernance {

        erc721Predicate = predicate;
        addPredicate(predicate, Type.ERC721);
    }

    function addPredicate(address predicate, Type _type) public onlyGovernance {

        require(predicates[predicate]._type == Type.Invalid, "Predicate already added");
        predicates[predicate]._type = _type;
        emit PredicateAdded(predicate, msg.sender);
    }

    function removePredicate(address predicate) public onlyGovernance {

        require(predicates[predicate]._type != Type.Invalid, "Predicate does not exist");
        delete predicates[predicate];
        emit PredicateRemoved(predicate, msg.sender);
    }

    function getValidatorShareAddress() public view returns (address) {

        return contractMap[VALIDATOR_SHARE];
    }

    function getWethTokenAddress() public view returns (address) {

        return contractMap[WETH_TOKEN];
    }

    function getDepositManagerAddress() public view returns (address) {

        return contractMap[DEPOSIT_MANAGER];
    }

    function getStakeManagerAddress() public view returns (address) {

        return contractMap[STAKE_MANAGER];
    }

    function getSlashingManagerAddress() public view returns (address) {

        return contractMap[SLASHING_MANAGER];
    }

    function getWithdrawManagerAddress() public view returns (address) {

        return contractMap[WITHDRAW_MANAGER];
    }

    function getChildChainAndStateSender() public view returns (address, address) {

        return (contractMap[CHILD_CHAIN], contractMap[STATE_SENDER]);
    }

    function isTokenMapped(address _token) public view returns (bool) {

        return rootToChildToken[_token] != address(0x0);
    }

    function isTokenMappedAndIsErc721(address _token) public view returns (bool) {

        require(isTokenMapped(_token), "TOKEN_NOT_MAPPED");
        return isERC721[_token];
    }

    function isTokenMappedAndGetPredicate(address _token) public view returns (address) {

        if (isTokenMappedAndIsErc721(_token)) {
            return erc721Predicate;
        }
        return erc20Predicate;
    }

    function isChildTokenErc721(address childToken) public view returns (bool) {

        address rootToken = childToRootToken[childToken];
        require(rootToken != address(0x0), "Child token is not mapped");
        return isERC721[rootToken];
    }
}


pragma solidity ^0.5.2;



contract ExitNFT is ERC721 {

    Registry internal registry;

    modifier onlyWithdrawManager() {

        require(
            msg.sender == registry.getWithdrawManagerAddress(),
            "UNAUTHORIZED_WITHDRAW_MANAGER_ONLY"
        );
        _;
    }

    constructor(address _registry) public {
        registry = Registry(_registry);
    }

    function mint(address _owner, uint256 _tokenId)
        external
        onlyWithdrawManager
    {

        _mint(_owner, _tokenId);
    }

    function burn(uint256 _tokenId) external onlyWithdrawManager {

        _burn(_tokenId);
    }

    function exists(uint256 tokenId) public view returns (bool) {

        return _exists(tokenId);
    }
}


pragma solidity ^0.5.2;


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(address, address, uint256, bytes memory) public returns (bytes4) {

        return this.onERC721Received.selector;
    }
}


pragma solidity ^0.5.2;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {



        require(address(token).isContract());

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)));
        }
    }
}


pragma solidity ^0.5.2;


contract WETH is ERC20 {

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    function deposit() public payable;


    function withdraw(uint256 wad) public;


    function withdraw(uint256 wad, address user) public;

}


pragma solidity ^0.5.2;

interface IDepositManager {

    function depositEther() external payable;

    function transferAssets(
        address _token,
        address _user,
        uint256 _amountOrNFTId
    ) external;

    function depositERC20(address _token, uint256 _amount) external;

    function depositERC721(address _token, uint256 _tokenId) external;

}


pragma solidity ^0.5.2;


contract ProxyStorage is Ownable {

    address internal proxyTo;
}


pragma solidity ^0.5.2;

contract ChainIdMixin {

  bytes constant public networkId = hex"89";
  uint256 constant public CHAINID = 137;
}


pragma solidity ^0.5.2;





contract RootChainHeader {

    event NewHeaderBlock(
        address indexed proposer,
        uint256 indexed headerBlockId,
        uint256 indexed reward,
        uint256 start,
        uint256 end,
        bytes32 root
    );
    event ResetHeaderBlock(address indexed proposer, uint256 indexed headerBlockId);
    struct HeaderBlock {
        bytes32 root;
        uint256 start;
        uint256 end;
        uint256 createdAt;
        address proposer;
    }
}


contract RootChainStorage is ProxyStorage, RootChainHeader, ChainIdMixin {

    bytes32 public heimdallId;
    uint8 public constant VOTE_TYPE = 2;

    uint16 internal constant MAX_DEPOSITS = 10000;
    uint256 public _nextHeaderBlock = MAX_DEPOSITS;
    uint256 internal _blockDepositId = 1;
    mapping(uint256 => HeaderBlock) public headerBlocks;
    Registry internal registry;
}


pragma solidity 0.5.17;

contract IStakeManager {

    function startAuction(
        uint256 validatorId,
        uint256 amount,
        bool acceptDelegation,
        bytes calldata signerPubkey
    ) external;


    function confirmAuctionBid(uint256 validatorId, uint256 heimdallFee) external;


    function transferFunds(
        uint256 validatorId,
        uint256 amount,
        address delegator
    ) external returns (bool);


    function delegationDeposit(
        uint256 validatorId,
        uint256 amount,
        address delegator
    ) external returns (bool);


    function unstake(uint256 validatorId) external;


    function totalStakedFor(address addr) external view returns (uint256);


    function stakeFor(
        address user,
        uint256 amount,
        uint256 heimdallFee,
        bool acceptDelegation,
        bytes memory signerPubkey
    ) public;


    function checkSignatures(
        uint256 blockInterval,
        bytes32 voteHash,
        bytes32 stateRoot,
        address proposer,
        uint[3][] calldata sigs
    ) external returns (uint256);


    function updateValidatorState(uint256 validatorId, int256 amount) public;


    function ownerOf(uint256 tokenId) public view returns (address);


    function slash(bytes calldata slashingInfoList) external returns (uint256);


    function validatorStake(uint256 validatorId) public view returns (uint256);


    function epoch() public view returns (uint256);


    function getRegistry() public view returns (address);


    function withdrawalDelay() public view returns (uint256);


    function delegatedAmount(uint256 validatorId) public view returns(uint256);


    function decreaseValidatorDelegatedAmount(uint256 validatorId, uint256 amount) public;


    function withdrawDelegatorsReward(uint256 validatorId) public returns(uint256);


    function delegatorsReward(uint256 validatorId) public view returns(uint256);


    function dethroneAndStake(
        address auctionUser,
        uint256 heimdallFee,
        uint256 validatorId,
        uint256 auctionAmount,
        bool acceptDelegation,
        bytes calldata signerPubkey
    ) external;

}


pragma solidity ^0.5.2;


interface IRootChain {

    function slash() external;


    function submitHeaderBlock(bytes calldata data, bytes calldata sigs)
        external;

    
    function submitCheckpoint(bytes calldata data, uint[3][] calldata sigs)
        external;


    function getLastChildBlock() external view returns (uint256);


    function currentHeaderBlock() external view returns (uint256);

}


pragma solidity ^0.5.2;








contract RootChain is RootChainStorage, IRootChain {

    using SafeMath for uint256;
    using RLPReader for bytes;
    using RLPReader for RLPReader.RLPItem;

    modifier onlyDepositManager() {

        require(msg.sender == registry.getDepositManagerAddress(), "UNAUTHORIZED_DEPOSIT_MANAGER_ONLY");
        _;
    }

    function submitHeaderBlock(bytes calldata data, bytes calldata sigs) external {

        revert();
    }

    function submitCheckpoint(bytes calldata data, uint[3][] calldata sigs) external {

        (address proposer, uint256 start, uint256 end, bytes32 rootHash, bytes32 accountHash, uint256 _borChainID) = abi
            .decode(data, (address, uint256, uint256, bytes32, bytes32, uint256));
        require(CHAINID == _borChainID, "Invalid bor chain id");

        require(_buildHeaderBlock(proposer, start, end, rootHash), "INCORRECT_HEADER_DATA");

        IStakeManager stakeManager = IStakeManager(registry.getStakeManagerAddress());
        uint256 _reward = stakeManager.checkSignatures(
            end.sub(start).add(1),
            keccak256(abi.encodePacked(bytes(hex"01"), data)),
            accountHash,
            proposer,
            sigs
        );

        require(_reward != 0, "Invalid checkpoint");
        emit NewHeaderBlock(proposer, _nextHeaderBlock, _reward, start, end, rootHash);
        _nextHeaderBlock = _nextHeaderBlock.add(MAX_DEPOSITS);
        _blockDepositId = 1;
    }

    function updateDepositId(uint256 numDeposits) external onlyDepositManager returns (uint256 depositId) {

        depositId = currentHeaderBlock().add(_blockDepositId);
        _blockDepositId = _blockDepositId.add(numDeposits);
        require(
            _blockDepositId <= MAX_DEPOSITS,
            "TOO_MANY_DEPOSITS"
        );
    }

    function getLastChildBlock() external view returns (uint256) {

        return headerBlocks[currentHeaderBlock()].end;
    }

    function slash() external {

    }

    function currentHeaderBlock() public view returns (uint256) {

        return _nextHeaderBlock.sub(MAX_DEPOSITS);
    }

    function _buildHeaderBlock(
        address proposer,
        uint256 start,
        uint256 end,
        bytes32 rootHash
    ) private returns (bool) {

        uint256 nextChildBlock;
        if (_nextHeaderBlock > MAX_DEPOSITS) {
            nextChildBlock = headerBlocks[currentHeaderBlock()].end + 1;
        }
        if (nextChildBlock != start) {
            return false;
        }

        HeaderBlock memory headerBlock = HeaderBlock({
            root: rootHash,
            start: nextChildBlock,
            end: end,
            createdAt: now,
            proposer: proposer
        });

        headerBlocks[_nextHeaderBlock] = headerBlock;
        return true;
    }

    function setNextHeaderBlock(uint256 _value) public onlyOwner {

        require(_value % MAX_DEPOSITS == 0, "Invalid value");
        for (uint256 i = _value; i < _nextHeaderBlock; i += MAX_DEPOSITS) {
            delete headerBlocks[i];
        }
        _nextHeaderBlock = _value;
        _blockDepositId = 1;
        emit ResetHeaderBlock(msg.sender, _nextHeaderBlock);
    }

    function setHeimdallId(string memory _heimdallId) public onlyOwner {

        heimdallId = keccak256(abi.encodePacked(_heimdallId));
    }
}


pragma solidity ^0.5.2;



contract StateSender is Ownable {

    using SafeMath for uint256;

    uint256 public counter;
    mapping(address => address) public registrations;

    event NewRegistration(
        address indexed user,
        address indexed sender,
        address indexed receiver
    );
    event RegistrationUpdated(
        address indexed user,
        address indexed sender,
        address indexed receiver
    );
    event StateSynced(
        uint256 indexed id,
        address indexed contractAddress,
        bytes data
    );

    modifier onlyRegistered(address receiver) {

        require(registrations[receiver] == msg.sender, "Invalid sender");
        _;
    }

    function syncState(address receiver, bytes calldata data)
        external
        onlyRegistered(receiver)
    {

        counter = counter.add(1);
        emit StateSynced(counter, receiver, data);
    }

    function register(address sender, address receiver) public {

        require(
            isOwner() || registrations[receiver] == msg.sender,
            "StateSender.register: Not authorized to register"
        );
        registrations[receiver] = sender;
        if (registrations[receiver] == address(0)) {
            emit NewRegistration(msg.sender, sender, receiver);
        } else {
            emit RegistrationUpdated(msg.sender, sender, receiver);
        }
    }
}


pragma solidity ^0.5.2;

contract Lockable {

    bool public locked;

    modifier onlyWhenUnlocked() {

        _assertUnlocked();
        _;
    }

    function _assertUnlocked() private view {

        require(!locked, "locked");
    }

    function lock() public {

        locked = true;
    }

    function unlock() public {

        locked = false;
    }
}


pragma solidity ^0.5.2;



contract GovernanceLockable is Lockable, Governable {

    constructor(address governance) public Governable(governance) {}

    function lock() public onlyGovernance {

        super.lock();
    }

    function unlock() public onlyGovernance {

        super.unlock();
    }
}


pragma solidity ^0.5.2;







contract DepositManagerHeader {

    event NewDepositBlock(address indexed owner, address indexed token, uint256 amountOrNFTId, uint256 depositBlockId);
    event MaxErc20DepositUpdate(uint256 indexed oldLimit, uint256 indexed newLimit);

    struct DepositBlock {
        bytes32 depositHash;
        uint256 createdAt;
    }
}


contract DepositManagerStorage is ProxyStorage, GovernanceLockable, DepositManagerHeader {

    Registry public registry;
    RootChain public rootChain;
    StateSender public stateSender;

    mapping(uint256 => DepositBlock) public deposits;

    address public childChain;
    uint256 public maxErc20Deposit = 100 * (10**18);
}


pragma solidity ^0.5.2;














contract DepositManager is DepositManagerStorage, IDepositManager, ERC721Holder {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    modifier isTokenMapped(address _token) {

        require(registry.isTokenMapped(_token), "TOKEN_NOT_SUPPORTED");
        _;
    }

    modifier isPredicateAuthorized() {

        require(uint8(registry.predicates(msg.sender)) != 0, "Not a valid predicate");
        _;
    }

    constructor() public GovernanceLockable(address(0x0)) {}

    function() external payable {
        depositEther();
    }

    function updateMaxErc20Deposit(uint256 maxDepositAmount) public onlyGovernance {

        require(maxDepositAmount != 0);
        emit MaxErc20DepositUpdate(maxErc20Deposit, maxDepositAmount);
        maxErc20Deposit = maxDepositAmount;
    }

    function transferAssets(
        address _token,
        address _user,
        uint256 _amountOrNFTId
    ) external isPredicateAuthorized {

        address wethToken = registry.getWethTokenAddress();
        if (registry.isERC721(_token)) {
            IERC721(_token).transferFrom(address(this), _user, _amountOrNFTId);
        } else if (_token == wethToken) {
            WETH t = WETH(_token);
            t.withdraw(_amountOrNFTId, _user);
        } else {
            require(IERC20(_token).transfer(_user, _amountOrNFTId), "TRANSFER_FAILED");
        }
    }

    function depositERC20(address _token, uint256 _amount) external {

        depositERC20ForUser(_token, msg.sender, _amount);
    }

    function depositERC721(address _token, uint256 _tokenId) external {

        depositERC721ForUser(_token, msg.sender, _tokenId);
    }

    function depositBulk(
        address[] calldata _tokens,
        uint256[] calldata _amountOrTokens,
        address _user
    )
        external
        onlyWhenUnlocked // unlike other deposit functions, depositBulk doesn't invoke _safeCreateDepositBlock
    {

        require(_tokens.length == _amountOrTokens.length, "Invalid Input");
        uint256 depositId = rootChain.updateDepositId(_tokens.length);
        Registry _registry = registry;

        for (uint256 i = 0; i < _tokens.length; i++) {
            if (_registry.isTokenMappedAndIsErc721(_tokens[i])) {
                _safeTransferERC721(msg.sender, _tokens[i], _amountOrTokens[i]);
            } else {
                IERC20(_tokens[i]).safeTransferFrom(msg.sender, address(this), _amountOrTokens[i]);
            }

            _createDepositBlock(_user, _tokens[i], _amountOrTokens[i], depositId);
            depositId = depositId.add(1);
        }
    }

    function updateChildChainAndStateSender() public {

        (address _childChain, address _stateSender) = registry.getChildChainAndStateSender();
        require(
            _stateSender != address(stateSender) || _childChain != childChain,
            "Atleast one of stateSender or childChain address should change"
        );
        childChain = _childChain;
        stateSender = StateSender(_stateSender);
    }

    function depositERC20ForUser(
        address _token,
        address _user,
        uint256 _amount
    ) public {

        require(_amount <= maxErc20Deposit, "exceed maximum deposit amount");
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        _safeCreateDepositBlock(_user, _token, _amount);
    }

    function depositERC721ForUser(
        address _token,
        address _user,
        uint256 _tokenId
    ) public {

        require(registry.isTokenMappedAndIsErc721(_token), "not erc721");

        _safeTransferERC721(msg.sender, _token, _tokenId);
        _safeCreateDepositBlock(_user, _token, _tokenId);
    }

    function depositEther() public payable {

        address wethToken = registry.getWethTokenAddress();
        WETH t = WETH(wethToken);
        t.deposit.value(msg.value)();
        _safeCreateDepositBlock(msg.sender, wethToken, msg.value);
    }

    function _safeCreateDepositBlock(
        address _user,
        address _token,
        uint256 _amountOrToken
    ) internal onlyWhenUnlocked isTokenMapped(_token) {

        _createDepositBlock(
            _user,
            _token,
            _amountOrToken,
            rootChain.updateDepositId(1) /* returns _depositId */
        );
    }

    function _createDepositBlock(
        address _user,
        address _token,
        uint256 _amountOrToken,
        uint256 _depositId
    ) internal {

        deposits[_depositId] = DepositBlock(keccak256(abi.encodePacked(_user, _token, _amountOrToken)), now);
        stateSender.syncState(childChain, abi.encode(_user, _token, _amountOrToken, _depositId));
        emit NewDepositBlock(_user, _token, _amountOrToken, _depositId);
    }

    function updateRootChain(address _rootChain) public onlyOwner {

        rootChain = RootChain(_rootChain);
    }

    function _safeTransferERC721(address _user, address _token, uint256 _tokenId) private {

        IERC721(_token).safeTransferFrom(_user, address(this), _tokenId);
    }
}


pragma solidity ^0.5.2;


library Common {

    function getV(bytes memory v, uint16 chainId) public pure returns (uint8) {

        if (chainId > 0) {
            return
                uint8(
                    BytesLib.toUint(BytesLib.leftPad(v), 0) - (chainId * 2) - 8
                );
        } else {
            return uint8(BytesLib.toUint(BytesLib.leftPad(v), 0));
        }
    }

    function isContract(address _addr) public view returns (bool) {

        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length > 0);
    }

    function toUint8(bytes memory _arg) public pure returns (uint8) {

        return uint8(_arg[0]);
    }

    function toUint16(bytes memory _arg) public pure returns (uint16) {

        return (uint16(uint8(_arg[0])) << 8) | uint16(uint8(_arg[1]));
    }
}


pragma solidity ^0.5.2;


library RLPEncode {

    function encodeItem(bytes memory self)
        internal
        pure
        returns (bytes memory)
    {

        bytes memory encoded;
        if (self.length == 1 && uint8(self[0] & 0xFF) < 0x80) {
            encoded = new bytes(1);
            encoded = self;
        } else {
            encoded = BytesLib.concat(encodeLength(self.length, 128), self);
        }
        return encoded;
    }

    function encodeList(bytes[] memory self)
        internal
        pure
        returns (bytes memory)
    {

        bytes memory encoded;
        for (uint256 i = 0; i < self.length; i++) {
            encoded = BytesLib.concat(encoded, encodeItem(self[i]));
        }
        return BytesLib.concat(encodeLength(encoded.length, 192), encoded);
    }


    function encodeLength(uint256 L, uint256 offset)
        internal
        pure
        returns (bytes memory)
    {

        if (L < 56) {
            bytes memory prefix = new bytes(1);
            prefix[0] = bytes1(uint8(L + offset));
            return prefix;
        } else {
            uint256 lenLen;
            uint256 i = 0x1;

            while (L / i != 0) {
                lenLen++;
                i *= 0x100;
            }

            bytes memory prefix0 = getLengthBytes(offset + 55 + lenLen);
            bytes memory prefix1 = getLengthBytes(L);
            return BytesLib.concat(prefix0, prefix1);
        }
    }

    function getLengthBytes(uint256 x) internal pure returns (bytes memory b) {

        uint256 nBytes = 1;
        if (x > 255) {
            nBytes = 2;
        }

        b = new bytes(nBytes);
        for (uint256 i = 0; i < nBytes; i++) {
            b[i] = bytes1(uint8(x / (2**(8 * (nBytes - 1 - i)))));
        }
    }
}


pragma solidity ^0.5.2;






contract ExitsDataStructure {

    struct Input {
        address utxoOwner;
        address predicate;
        address token;
    }

    struct PlasmaExit {
        uint256 receiptAmountOrNFTId;
        bytes32 txHash;
        address owner;
        address token;
        bool isRegularExit;
        address predicate;
        mapping(uint256 => Input) inputs;
    }
}


contract WithdrawManagerHeader is ExitsDataStructure {

    event Withdraw(uint256 indexed exitId, address indexed user, address indexed token, uint256 amount);

    event ExitStarted(
        address indexed exitor,
        uint256 indexed exitId,
        address indexed token,
        uint256 amount,
        bool isRegularExit
    );

    event ExitUpdated(uint256 indexed exitId, uint256 indexed age, address signer);
    event ExitPeriodUpdate(uint256 indexed oldExitPeriod, uint256 indexed newExitPeriod);

    event ExitCancelled(uint256 indexed exitId);
}


contract WithdrawManagerStorage is ProxyStorage, WithdrawManagerHeader {

    uint256 public HALF_EXIT_PERIOD = 302400;

    uint256 internal constant BOND_AMOUNT = 10**17;

    Registry internal registry;
    RootChain internal rootChain;

    mapping(uint128 => bool) isKnownExit;
    mapping(uint256 => PlasmaExit) public exits;
    mapping(bytes32 => uint256) public ownerExits;
    mapping(address => address) public exitsQueues;
    ExitNFT public exitNft;


    uint32 public ON_FINALIZE_GAS_LIMIT = 300000;

    uint256 public exitWindow;
}


pragma solidity ^0.5.2;








interface IPredicate {

    function verifyDeprecation(
        bytes calldata exit,
        bytes calldata inputUtxo,
        bytes calldata challengeData
    ) external returns (bool);


    function interpretStateUpdate(bytes calldata state)
        external
        view
        returns (bytes memory);

    function onFinalizeExit(bytes calldata data) external;

}

contract PredicateUtils is ExitsDataStructure, ChainIdMixin {

    using RLPReader for RLPReader.RLPItem;

    uint256 private constant BOND_AMOUNT = 10**17;

    IWithdrawManager internal withdrawManager;
    IDepositManager internal depositManager;

    modifier onlyWithdrawManager() {

        require(
            msg.sender == address(withdrawManager),
            "ONLY_WITHDRAW_MANAGER"
        );
        _;
    }

    modifier isBondProvided() {

        require(msg.value == BOND_AMOUNT, "Invalid Bond amount");
        _;
    }

    function onFinalizeExit(bytes calldata data) external onlyWithdrawManager {

        (, address token, address exitor, uint256 tokenId) = decodeExitForProcessExit(
            data
        );
        depositManager.transferAssets(token, exitor, tokenId);
    }

    function sendBond() internal {

        address(uint160(address(withdrawManager))).transfer(BOND_AMOUNT);
    }

    function getAddressFromTx(RLPReader.RLPItem[] memory txList)
        internal
        pure
        returns (address signer, bytes32 txHash)
    {

        bytes[] memory rawTx = new bytes[](9);
        for (uint8 i = 0; i <= 5; i++) {
            rawTx[i] = txList[i].toBytes();
        }
        rawTx[6] = networkId;
        rawTx[7] = hex""; // [7] and [8] have something to do with v, r, s values
        rawTx[8] = hex"";

        txHash = keccak256(RLPEncode.encodeList(rawTx));
        signer = ecrecover(
            txHash,
            Common.getV(txList[6].toBytes(), Common.toUint16(networkId)),
            bytes32(txList[7].toUint()),
            bytes32(txList[8].toUint())
        );
    }

    function decodeExit(bytes memory data)
        internal
        pure
        returns (PlasmaExit memory)
    {

        (address owner, address token, uint256 amountOrTokenId, bytes32 txHash, bool isRegularExit) = abi
            .decode(data, (address, address, uint256, bytes32, bool));
        return
            PlasmaExit(
                amountOrTokenId,
                txHash,
                owner,
                token,
                isRegularExit,
                address(0) /* predicate value is not required */
            );
    }

    function decodeExitForProcessExit(bytes memory data)
        internal
        pure
        returns (uint256 exitId, address token, address exitor, uint256 tokenId)
    {

        (exitId, token, exitor, tokenId) = abi.decode(
            data,
            (uint256, address, address, uint256)
        );
    }

    function decodeInputUtxo(bytes memory data)
        internal
        pure
        returns (uint256 age, address signer, address predicate, address token)
    {

        (age, signer, predicate, token) = abi.decode(
            data,
            (uint256, address, address, address)
        );
    }

}

contract IErcPredicate is IPredicate, PredicateUtils {

    enum ExitType {Invalid, OutgoingTransfer, IncomingTransfer, Burnt}

    struct ExitTxData {
        uint256 amountOrToken;
        bytes32 txHash;
        address childToken;
        address signer;
        ExitType exitType;
    }

    struct ReferenceTxData {
        uint256 closingBalance;
        uint256 age;
        address childToken;
        address rootToken;
    }

    uint256 internal constant MAX_LOGS = 10;

    constructor(address _withdrawManager, address _depositManager) public {
        withdrawManager = IWithdrawManager(_withdrawManager);
        depositManager = IDepositManager(_depositManager);
    }
}


pragma solidity ^0.5.2;

















contract WithdrawManager is WithdrawManagerStorage, IWithdrawManager {

    using RLPReader for bytes;
    using RLPReader for RLPReader.RLPItem;
    using Merkle for bytes32;

    using ExitPayloadReader for bytes;
    using ExitPayloadReader for ExitPayloadReader.ExitPayload;
    using ExitPayloadReader for ExitPayloadReader.Receipt;
    using ExitPayloadReader for ExitPayloadReader.Log;
    using ExitPayloadReader for ExitPayloadReader.LogTopics;

    modifier isBondProvided() {

        require(msg.value == BOND_AMOUNT, "Invalid Bond amount");
        _;
    }

    modifier isPredicateAuthorized() {

        require(registry.predicates(msg.sender) != Registry.Type.Invalid, "PREDICATE_NOT_AUTHORIZED");
        _;
    }

    modifier checkPredicateAndTokenMapping(address rootToken) {

        Registry.Type _type = registry.predicates(msg.sender);
        require(registry.rootToChildToken(rootToken) != address(0x0), "rootToken not supported");
        if (_type == Registry.Type.ERC20) {
            require(registry.isERC721(rootToken) == false, "Predicate supports only ERC20 tokens");
        } else if (_type == Registry.Type.ERC721) {
            require(registry.isERC721(rootToken) == true, "Predicate supports only ERC721 tokens");
        } else if (_type == Registry.Type.Custom) {} else {
            revert("PREDICATE_NOT_AUTHORIZED");
        }
        _;
    }

    function() external payable {}

    function createExitQueue(address token) external {

        require(msg.sender == address(registry), "UNAUTHORIZED_REGISTRY_ONLY");
        exitsQueues[token] = address(new PriorityQueue());
    }

    struct VerifyInclusionVars {
        uint256 headerNumber;
        uint256 blockNumber;
        uint256 createdAt;
        uint256 branchMask;
        bytes32 txRoot;
        bytes32 receiptRoot;
        bytes branchMaskBytes;
    }

    function verifyInclusion(
        bytes calldata data,
        uint8 offset,
        bool verifyTxInclusion
    )
        external
        view
        returns (
            uint256 /* ageOfInput */
        )
    {

        ExitPayloadReader.ExitPayload memory payload = data.toExitPayload();
        VerifyInclusionVars memory vars;

        vars.headerNumber = payload.getHeaderNumber();
        vars.branchMaskBytes = payload.getBranchMaskAsBytes();
        require(vars.branchMaskBytes[0] == 0, "incorrect mask");
        vars.txRoot = payload.getTxRoot();
        vars.receiptRoot = payload.getReceiptRoot();
        require(
            MerklePatriciaProof.verify(
                payload.getReceipt().toBytes(),
                vars.branchMaskBytes,
                payload.getReceiptProof(),
                vars.receiptRoot
            ),
            "INVALID_RECEIPT_MERKLE_PROOF"
        );

        if (verifyTxInclusion) {
            require(
                MerklePatriciaProof.verify(
                    payload.getTx(),
                    vars.branchMaskBytes,
                    payload.getTxProof(), 
                    vars.txRoot
                ),
                "INVALID_TX_MERKLE_PROOF"
            );
        }

        vars.blockNumber = payload.getBlockNumber();
        vars.createdAt = checkBlockMembershipInCheckpoint(
            vars.blockNumber,
            payload.getBlockTime(),
            vars.txRoot,
            vars.receiptRoot,
            vars.headerNumber,
            payload.getBlockProof()
        );

        vars.branchMask = payload.getBranchMaskAsUint();
        require(
            vars.branchMask & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000 == 0,
            "Branch mask should be 32 bits"
        );
        return (getExitableAt(vars.createdAt) << 127) | (vars.blockNumber << 32) | vars.branchMask;
    }

    function startExitWithDepositedTokens(
        uint256 depositId,
        address token,
        uint256 amountOrToken
    ) external payable isBondProvided {

    }

    function addExitToQueue(
        address exitor,
        address childToken,
        address rootToken,
        uint256 exitAmountOrTokenId,
        bytes32 txHash,
        bool isRegularExit,
        uint256 priority
    ) external checkPredicateAndTokenMapping(rootToken) {

        require(registry.rootToChildToken(rootToken) == childToken, "INVALID_ROOT_TO_CHILD_TOKEN_MAPPING");
        _addExitToQueue(exitor, rootToken, exitAmountOrTokenId, txHash, isRegularExit, priority, msg.sender);
    }

    function challengeExit(
        uint256 exitId,
        uint256 inputId,
        bytes calldata challengeData,
        address adjudicatorPredicate
    ) external {

        PlasmaExit storage exit = exits[exitId];
        Input storage input = exit.inputs[inputId];
        require(exit.owner != address(0x0) && input.utxoOwner != address(0x0), "Invalid exit or input id");
        require(registry.predicates(adjudicatorPredicate) != Registry.Type.Invalid, "INVALID_PREDICATE");
        require(
            IPredicate(adjudicatorPredicate).verifyDeprecation(
                encodeExit(exit),
                encodeInputUtxo(inputId, input),
                challengeData
            ),
            "Challenge failed"
        );
        ExitNFT(exitNft).burn(exitId);

        msg.sender.send(BOND_AMOUNT);

        emit ExitCancelled(exitId);
    }

    function processExits(address _token) public {

        uint256 exitableAt;
        uint256 exitId;

        PriorityQueue exitQueue = PriorityQueue(exitsQueues[_token]);

        while (exitQueue.currentSize() > 0 && gasleft() > ON_FINALIZE_GAS_LIMIT) {
            (exitableAt, exitId) = exitQueue.getMin();
            exitId = (exitableAt << 128) | exitId;
            PlasmaExit memory currentExit = exits[exitId];

            if (exitableAt > block.timestamp) return;

            exitQueue.delMin();
            if (!exitNft.exists(exitId)) continue;
            address exitor = exitNft.ownerOf(exitId);
            exits[exitId].owner = exitor;
            exitNft.burn(exitId);
            currentExit.predicate.call(
                abi.encodeWithSignature("onFinalizeExit(bytes)", encodeExitForProcessExit(exitId))
            );

            emit Withdraw(exitId, exitor, _token, currentExit.receiptAmountOrNFTId);

            if (!currentExit.isRegularExit) {
                address(uint160(exitor)).send(BOND_AMOUNT);
            }
        }
    }

    function processExitsBatch(address[] calldata _tokens) external {

        for (uint256 i = 0; i < _tokens.length; i++) {
            processExits(_tokens[i]);
        }
    }

    function addInput(
        uint256 exitId,
        uint256 age,
        address utxoOwner,
        address token
    ) external isPredicateAuthorized {

        PlasmaExit storage exitObject = exits[exitId];
        require(exitObject.owner != address(0x0), "INVALID_EXIT_ID");
        _addInput(
            exitId,
            age,
            utxoOwner,
            msg.sender,
            token
        );
    }

    function _addInput(
        uint256 exitId,
        uint256 age,
        address utxoOwner,
        address predicate,
        address token
    ) internal {

        exits[exitId].inputs[age] = Input(utxoOwner, predicate, token);
        emit ExitUpdated(exitId, age, utxoOwner);
    }

    function encodeExit(PlasmaExit storage exit) internal view returns (bytes memory) {

        return
            abi.encode(
                exit.owner,
                registry.rootToChildToken(exit.token),
                exit.receiptAmountOrNFTId,
                exit.txHash,
                exit.isRegularExit
            );
    }

    function encodeExitForProcessExit(uint256 exitId) internal view returns (bytes memory) {

        PlasmaExit storage exit = exits[exitId];
        return abi.encode(exitId, exit.token, exit.owner, exit.receiptAmountOrNFTId);
    }

    function encodeInputUtxo(uint256 age, Input storage input) internal view returns (bytes memory) {

        return abi.encode(age, input.utxoOwner, input.predicate, registry.rootToChildToken(input.token));
    }

    function _addExitToQueue(
        address exitor,
        address rootToken,
        uint256 exitAmountOrTokenId,
        bytes32 txHash,
        bool isRegularExit,
        uint256 exitId,
        address predicate
    ) internal {

        require(exits[exitId].token == address(0x0), "EXIT_ALREADY_EXISTS");
        exits[exitId] = PlasmaExit(
            exitAmountOrTokenId,
            txHash,
            exitor,
            rootToken,
            isRegularExit,
            predicate
        );
        PlasmaExit storage _exitObject = exits[exitId];

        bytes32 key = getKey(_exitObject.token, _exitObject.owner, _exitObject.receiptAmountOrNFTId);

        if (isRegularExit) {
            require(!isKnownExit[uint128(exitId)], "KNOWN_EXIT");
            isKnownExit[uint128(exitId)] = true;
        } else {
            require(ownerExits[key] == 0, "EXIT_ALREADY_IN_PROGRESS");
            ownerExits[key] = exitId;
        }

        PriorityQueue queue = PriorityQueue(exitsQueues[_exitObject.token]);

        queue.insert(exitId >> 128, uint256(uint128(exitId)));

        exitNft.mint(_exitObject.owner, exitId);
        emit ExitStarted(exitor, exitId, rootToken, exitAmountOrTokenId, isRegularExit);
    }

    function checkBlockMembershipInCheckpoint(
        uint256 blockNumber,
        uint256 blockTime,
        bytes32 txRoot,
        bytes32 receiptRoot,
        uint256 headerNumber,
        bytes memory blockProof
    )
        internal
        view
        returns (
            uint256 /* createdAt */
        )
    {

        (bytes32 headerRoot, uint256 startBlock, , uint256 createdAt, ) = rootChain.headerBlocks(headerNumber);
        require(
            keccak256(abi.encodePacked(blockNumber, blockTime, txRoot, receiptRoot)).checkMembership(
                blockNumber - startBlock,
                headerRoot,
                blockProof
            ),
            "WITHDRAW_BLOCK_NOT_A_PART_OF_SUBMITTED_HEADER"
        );
        return createdAt;
    }

    function getKey(
        address token,
        address exitor,
        uint256 amountOrToken
    ) internal view returns (bytes32 key) {

        if (registry.isERC721(token)) {
            key = keccak256(abi.encodePacked(token, exitor, amountOrToken));
        } else {
            require(amountOrToken > 0, "CANNOT_EXIT_ZERO_AMOUNTS");
            key = keccak256(abi.encodePacked(token, exitor));
        }
    }

    function getDepositManager() internal view returns (DepositManager) {

        return DepositManager(address(uint160(registry.getDepositManagerAddress())));
    }

    function getExitableAt(uint256 createdAt) internal view returns (uint256) {

        return Math.max(createdAt + 2 * HALF_EXIT_PERIOD, now + HALF_EXIT_PERIOD);
    }

    function updateExitPeriod(uint256 halfExitPeriod) public onlyOwner {

        emit ExitPeriodUpdate(HALF_EXIT_PERIOD, halfExitPeriod);
        HALF_EXIT_PERIOD = halfExitPeriod;
    }
}