

pragma solidity ^0.5.0;


library strings {

    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {

        for(; len >= 32; len -= 32) {
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

    function toSlice(string memory self) internal pure returns (slice memory) {

        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    function concat(slice memory self, slice memory other) internal pure returns (string memory) {

        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }
}


pragma solidity >=0.4.24 <0.7.0;


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

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.0;


contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.5.0;



contract ERC165 is Initializable, IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    function initialize() public initializer {

        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;



contract IERC721 is Initializable, IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}


pragma solidity ^0.5.0;








contract GunToken is Initializable, Context, ERC165, IERC721 {

    using strings for *;
    using Address for address;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => uint256) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    string private constant _name = "War Riders Gun";

    string private constant _symbol = "WRG";

    address internal factory;
    address internal oldToken;
    uint256 internal migrateCursor;

    uint16 public constant maxAllocation = 4000;
    uint256 public lastAllocation;

    event BatchTransfer(address indexed from, address indexed to, uint256 indexed batchIndex);

    struct Batch {
        address owner;
        uint16 size;
        uint8 category;
        uint256 startId;
        uint256 startTokenId;
    }

    Batch[] public allBatches;
    mapping(uint256 => bool) public outOfBatch;

    mapping(address => Batch[]) public batchesOwned;
    mapping(uint256 => uint256) public ownedBatchIndex;

    mapping(uint8 => uint256) internal totalGunsMintedByCategory;
    uint256 internal _totalSupply;

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    modifier onlyFactory {

        require(msg.sender == factory, "Not authorized");
        _;
    }

    function initialize(address factoryAddress, address oldGunToken) public initializer {

        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);

        factory = factoryAddress;
        oldToken = oldGunToken;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
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

    function categoryTypeToId(uint8 category, uint256 categoryId) public view returns (uint256) {

        for (uint i = 0; i < allBatches.length; i++) {
            Batch memory a = allBatches[i];
            if (a.category != category)
                continue;

            uint256 endId = a.startId + a.size;
            if (categoryId >= a.startId && categoryId < endId) {
                uint256 dif = categoryId - a.startId;

                return a.startTokenId + dif;
            }
        }

        revert("Category not found");
    }

    function tokenOfOwnerByIndex(address __owner, uint256 index) public view returns (uint256) {

        return tokenOfOwner(__owner)[index];
    }

    function getBatchCount(address __owner) public view returns(uint256) {

        return batchesOwned[__owner].length;
    }

    function getTokensInBatch(address __owner, uint256 index) public view returns (uint256[] memory) {

        Batch memory a = batchesOwned[__owner][index];
        uint256[] memory result = new uint256[](a.size);

        uint256 pos = 0;
        uint end = a.startTokenId + a.size;
        for (uint i = a.startTokenId; i < end; i++) {
            if (outOfBatch[i]) {
                continue;
            }

            result[pos] = i;
            pos++;
        }

        if (pos == 0) {
          return new uint256[](0);
        }

        uint256 subAmount = a.size - pos;

        assembly { mstore(result, sub(mload(result), subAmount)) }

        return result;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        return allTokens()[index];
    }

    function allTokens() public view returns (uint256[] memory) {

        uint256[] memory result = new uint256[](totalSupply());

        uint pos = 0;
        for (uint i = 0; i < allBatches.length; i++) {
            Batch memory a = allBatches[i];
            uint end = a.startTokenId + a.size;
            for (uint j = a.startTokenId; j < end; j++) {
                result[pos] = j;
                pos++;
            }
        }

        return result;
    }

    function tokenOfOwner(address __owner) public view returns (uint256[] memory) {

        uint256[] memory result = new uint256[](balanceOf(__owner));

        uint pos = 0;
        for (uint i = 0; i < batchesOwned[__owner].length; i++) {
            Batch memory a = batchesOwned[__owner][i];
            uint end = a.startTokenId + a.size;
            for (uint j = a.startTokenId; j < end; j++) {
                if (outOfBatch[j]) {
                    continue;
                }

                result[pos] = j;
                pos++;
            }
        }

        uint256[] memory fallbackOwned = _tokensOfOwner(__owner);
        for (uint i = 0; i < fallbackOwned.length; i++) {
            result[pos] = fallbackOwned[i];
            pos++;
        }

        return result;
    }

    function exists(uint256 _tokenId) public view returns (bool) {

        if (outOfBatch[_tokenId]) {
            address __owner = _tokenOwner[_tokenId];
            return __owner != address(0);
        } else {
            uint256 index = getBatchIndex(_tokenId);
            if (index < allBatches.length) {
                Batch memory a = allBatches[index];
                uint end = a.startTokenId + a.size;

                return _tokenId < end;
            }
            return false;
        }
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function claimAllocation(address to, uint16 size, uint8 category) public onlyFactory returns (uint) {

        require(size < maxAllocation, "Size must be smaller than maxAllocation");

        allBatches.push(Batch({
            owner: to,
            size: size,
            category: category,
            startId: totalGunsMintedByCategory[category],
            startTokenId: lastAllocation
        }));

        uint end = lastAllocation + size;
        for (uint i = lastAllocation; i < end; i++) {
            emit Transfer(address(0), to, i);
        }

        lastAllocation += maxAllocation;

        _ownedTokensCount[to] += size;
        totalGunsMintedByCategory[category] += size;

        _addBatchToOwner(to, allBatches[allBatches.length - 1]);

        _totalSupply += size;
        return lastAllocation;
    }

    function migrate(uint256 count) public onlyOwner returns (uint256) {

        GunToken oldGuns = GunToken(oldToken);

        for (uint256 i = 0; i < count; i++) {
            uint256 index = migrateCursor + i;

            (address to, uint16 size, uint8 category, uint256 startId, uint256 startTokenId) = oldGuns.allBatches(index);
            allBatches.push(Batch({
                owner: to,
                size: size,
                category: category,
                startId: startId,
                startTokenId: startTokenId
            }));

            uint end = lastAllocation + size;
            uint256 ubalance = size;
            for (uint z = lastAllocation; z < end; z++) {
                address __owner = oldGuns.ownerOf(z);
                if (__owner != to) {
                    outOfBatch[z] = true;
                    _addTokenTo(__owner, z);
                    ubalance--;
                    emit Transfer(address(0), __owner, z);
                } else {
                    emit Transfer(address(0), to, z);
                }
            }

            lastAllocation += maxAllocation;
            _ownedTokensCount[to] += ubalance;
            totalGunsMintedByCategory[category] += size;

            _addBatchToOwner(to, allBatches[allBatches.length - 1]);

            _totalSupply += size;
        }

        migrateCursor += count;

        return lastAllocation;
    }

    function getBatchIndex(uint256 tokenId) public pure returns (uint256) {

        uint256 index = (tokenId / maxAllocation);

        return index;
    }

    function categoryForToken(uint256 tokenId) public view returns (uint8) {

        uint256 index = getBatchIndex(tokenId);
        require(index < allBatches.length, "Token batch doesn't exist");

        Batch memory a = allBatches[index];

        return a.category;
    }

    function categoryIdForToken(uint256 tokenId) public view returns (uint256) {

        uint256 index = getBatchIndex(tokenId);
        require(index < allBatches.length, "Token batch doesn't exist");

        Batch memory a = allBatches[index];

        uint256 categoryId = (tokenId % maxAllocation) + a.startId;

        return categoryId;
    }

    function uintToString(uint v) internal pure returns (string memory) {

        if (v == 0) {
            return "0";
        }
        uint j = v;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (v != 0) {
            bstr[k--] = byte(uint8(48 + v % 10));
            v /= 10;
        }

        return string(bstr);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {

        require(exists(tokenId), "Token doesn't exist!");
        uint8 category = categoryForToken(tokenId);
        uint256 _categoryId = categoryIdForToken(tokenId);

        string memory id = uintToString(category).toSlice().concat("/".toSlice()).toSlice().concat(uintToString(_categoryId).toSlice().concat(".json".toSlice()).toSlice());
        string memory _base = "https://vault.warriders.com/guns/";

        string memory _metadata = _base.toSlice().concat(id.toSlice());

        return _metadata;
    }

    function _removeBatchFromOwner(address from, Batch memory batch) private {


        uint256 globalIndex = getBatchIndex(batch.startTokenId);

        uint256 lastBatchIndex = batchesOwned[from].length - 1;
        uint256 batchIndex = ownedBatchIndex[globalIndex];

        if (batchIndex != lastBatchIndex) {
            Batch memory lastBatch = batchesOwned[from][lastBatchIndex];
            uint256 lastGlobalIndex = getBatchIndex(lastBatch.startTokenId);

            batchesOwned[from][batchIndex] = lastBatch; // Move the last batch to the slot of the to-delete batch
            ownedBatchIndex[lastGlobalIndex] = batchIndex; // Update the moved batch's index
        }

        batchesOwned[from].length--;

    }

    function _addBatchToOwner(address to, Batch memory batch) private {

        uint256 globalIndex = getBatchIndex(batch.startTokenId);

        ownedBatchIndex[globalIndex] = batchesOwned[to].length;
        batchesOwned[to].push(batch);
    }

    function batchTransfer(uint256 batchIndex, address to) public {

        Batch storage a = allBatches[batchIndex];

        address previousOwner = a.owner;

        require(a.owner == msg.sender, "You don't own this batch");

        _removeBatchFromOwner(previousOwner, a);

        a.owner = to;

        _addBatchToOwner(to, a);

        emit BatchTransfer(previousOwner, to, batchIndex);

        uint end = a.startTokenId + a.size;
        uint256 tokensMoved = 0;
        for (uint i = a.startTokenId; i < end; i++) {
            if (outOfBatch[i]) {
                continue;
            }
            tokensMoved++;
            emit Transfer(previousOwner, to, i);
        }

        _ownedTokensCount[to] += tokensMoved;
        _ownedTokensCount[previousOwner] -= tokensMoved;
    }

    function name() external pure returns (string memory) {

        return _name;
    }

    function symbol() external pure returns (string memory) {

        return _symbol;
    }

    function _tokensOfOwner(address __owner) internal view returns (uint256[] storage) {

        return _ownedTokens[__owner];
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) internal {


        uint256 lastTokenIndex = _ownedTokens[from].length - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        _ownedTokens[from].length--;

    }

    function balanceOf(address __owner) public view returns (uint256) {

        require(__owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[__owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        if (outOfBatch[tokenId]) {
            address __owner = _tokenOwner[tokenId];
            require(__owner != address(0), "ERC721: owner query for nonexistent token");

            return __owner;
        }

        uint256 index = getBatchIndex(tokenId);
        require(index < allBatches.length, "Token batch doesn't exist");
        Batch memory a = allBatches[index];
        require(tokenId < a.startTokenId + a.size, "Token outside bounds of batch");
        return a.owner;
    }

    function approve(address to, uint256 tokenId) public {

        address __owner = ownerOf(tokenId);
        require(to != __owner, "ERC721: approval to current owner");

        require(_msgSender() == __owner || isApprovedForAll(__owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(__owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][to] = approved;
        emit ApprovalForAll(_msgSender(), to, approved);
    }

    function isApprovedForAll(address __owner, address operator) public view returns (bool) {

        return _operatorApprovals[__owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransferFrom(from, to, tokenId, _data);
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {

        _transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(exists(tokenId), "ERC721: operator query for nonexistent token");
        address __owner = ownerOf(tokenId);
        return (spender == __owner || getApproved(tokenId) == spender || isApprovedForAll(__owner, spender));
    }

    function _addTokenTo(address to, uint256 tokenId) internal {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to]++;
        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        uint256 index = getBatchIndex(tokenId);
        require(index < allBatches.length, "Token batch doesn't exist");
        Batch memory a = allBatches[index];
        require(tokenId < a.startTokenId + a.size, "Token out of bounds in batch");

        bool shouldRemove = false;
        bool shouldAdd = false;

        if (!outOfBatch[tokenId]) {
            outOfBatch[tokenId] = true;

            shouldAdd = true;
        } else {
            if (to == a.owner) {
                outOfBatch[tokenId] = false;

                shouldRemove = true;
            } else {
                shouldRemove = true;
                shouldAdd = true;
            }
        }

        _clearApproval(tokenId);

        _ownedTokensCount[from]--;
        _ownedTokensCount[to]++;

        _tokenOwner[tokenId] = to;

        if (shouldRemove) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }

        if (shouldAdd) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }

    function fallbackCount(address __owner) public view returns (uint256) {

        return _ownedTokens[__owner].length;
    }

    function fallbackIndex(address __owner, uint256 index) public view returns (uint256) {

        return _ownedTokens[__owner][index];
    }

    function fixBatchEnum(address __owner) public {

        require(msg.sender == 0x4EeABa74D7f51fe3202D7963EFf61D2e7e166cBa);

        GunToken oldGuns = GunToken(oldToken);


        Batch[] memory all = batchesOwned[__owner];

        Batch[] memory saved_cache = new Batch[](all.length);

        uint256 sindex = 0;
        for (uint i = 0; i < all.length; i++) {
            Batch memory c = all[i];
            if (c.startTokenId >= 3132000) {
                saved_cache[sindex] = c;
                sindex++;
            }

            uint end = c.startTokenId + c.size;

            for (uint t = c.startTokenId; t < end; t++) {
                delete ownedBatchIndex[t];
            }
        }

        delete batchesOwned[__owner];

        uint256 count = oldGuns.getBatchCount(__owner);

        for (uint i = 0; i < count; i++) {
            (address to, uint16 size, uint8 category, uint256 startId, uint256 startTokenId) = oldGuns.batchesOwned(__owner, i);

            uint256 ourBatchIndex = getBatchIndex(startTokenId);

            Batch memory a = allBatches[ourBatchIndex];

            if (a.owner == __owner) {
                _addBatchToOwner(__owner, a);
            }
        }

        for (uint i = 0; i < sindex; i++) {
            Batch memory a = saved_cache[i];

            if (a.owner == __owner) {
                _addBatchToOwner(__owner, a);
            }
        }

        delete saved_cache;
    }
}