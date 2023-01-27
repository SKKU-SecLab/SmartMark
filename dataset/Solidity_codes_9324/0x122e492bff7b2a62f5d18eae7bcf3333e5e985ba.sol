
pragma solidity ^0.4.24;

contract ERC721 {

    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) public view returns (uint256 _balance);

    function ownerOf(uint256 _tokenId) public view returns (address _owner);

    function exists(uint256 _tokenId) public view returns (bool _exists);


    function approve(address _to, uint256 _tokenId) public;

    function getApproved(uint256 _tokenId) public view returns (address _operator);


    function setApprovalForAll(address _operator, bool _approved) public;

    function isApprovedForAll(address _owner, address _operator) public view returns (bool);


    function transferFrom(address _from, address _to, uint256 _tokenId) public;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
    public;

}
contract ERC721Receiver {

    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

    function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);


}



library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}
library SafeMath128 {


    function mul(uint128 a, uint128 b) internal pure returns (uint128 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint128 a, uint128 b) internal pure returns (uint128) {

        return a / b;
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128) {

        assert(b <= a);
        return a - b;
    }

    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}
library SafeMath64 {


    function mul(uint64 a, uint64 b) internal pure returns (uint64 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint64 a, uint64 b) internal pure returns (uint64) {

        return a / b;
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64) {

        assert(b <= a);
        return a - b;
    }

    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}
library SafeMath32 {


    function mul(uint32 a, uint32 b) internal pure returns (uint32 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {

        return a / b;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {

        assert(b <= a);
        return a - b;
    }

    function add(uint32 a, uint32 b) internal pure returns (uint32 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}
library SafeMath16 {


    function mul(uint16 a, uint16 b) internal pure returns (uint16 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint16 a, uint16 b) internal pure returns (uint16) {

        return a / b;
    }

    function sub(uint16 a, uint16 b) internal pure returns (uint16) {

        assert(b <= a);
        return a - b;
    }

    function add(uint16 a, uint16 b) internal pure returns (uint16 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}
library SafeMath8 {


    function mul(uint8 a, uint8 b) internal pure returns (uint8 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint8 a, uint8 b) internal pure returns (uint8) {

        return a / b;
    }

    function sub(uint8 a, uint8 b) internal pure returns (uint8) {

        assert(b <= a);
        return a - b;
    }

    function add(uint8 a, uint8 b) internal pure returns (uint8 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}



contract Ownable {

    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}


library AddressUtils {


    function isContract(address addr) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(addr) }  // solium-disable-line security/no-inline-assembly
        return size > 0;
    }

}



library ECRecovery {


    function recover(bytes32 hash, bytes sig) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (sig.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

}

contract MintibleUtility is Ownable {

    using SafeMath     for uint256;
    using SafeMath128  for uint128;
    using SafeMath64   for uint64;
    using SafeMath32   for uint32;
    using SafeMath16   for uint16;
    using SafeMath8    for uint8;
    using AddressUtils for address;
    using ECRecovery   for bytes32;

    uint256 private nonce;

    bool public paused;

    modifier notPaused() {

        require(!paused);
        _;
    }

    function getIndexFromOdd(uint32 _odd, uint32[] _odds) internal pure returns (uint) {

        uint256 low = 0;
        uint256 high = _odds.length.sub(1);

        while (low < high) {
            uint256 mid = (low.add(high)) / 2;
            if (_odd >= _odds[mid]) {
                low = mid.add(1);
            } else {
                high = mid;
            }
        }

        return low;
    }

    function rand(uint32 min, uint32 max) internal returns (uint32) {

        nonce++;
        return uint32(keccak256(abi.encodePacked(nonce, uint(blockhash(block.number.sub(1)))))) % (min.add(max)).sub(min);
    }



    function getUintSubArray(uint256[] _arr, uint256 _start, uint256 _end) internal pure returns (uint256[]) {

        uint256[] memory ret = new uint256[](_end.sub(_start));
        for (uint256 i = _start; i < _end; i++) {
            ret[i - _start] = _arr[i];
        }

        return ret;
    }

    function getUint32SubArray(uint256[] _arr, uint256 _start, uint256 _end) internal pure returns (uint32[]) {

        uint32[] memory ret = new uint32[](_end.sub(_start));
        for (uint256 i = _start; i < _end; i++) {
            ret[i - _start] = uint32(_arr[i]);
        }

        return ret;
    }

    function getUint64SubArray(uint256[] _arr, uint256 _start, uint256 _end) internal pure returns (uint64[]) {

        uint64[] memory ret = new uint64[](_end.sub(_start));
        for (uint256 i = _start; i < _end; i++) {
            ret[i - _start] = uint64(_arr[i]);
        }

        return ret;
    }
}


contract MintibleOwnership is ERC721, MintibleUtility {


    struct AccountItem {
        uint64  categoryId;
        uint128 latestActionTime;
        uint64  lastModifiedNonce;
        address owner;
    }

    struct ShopItem {
        uint128  cooldown;
        uint128  price;
        uint64   supply;
        uint16   numberOfOutputs;
        uint8    isDestroyable;
        uint32[] odds;
        uint64[] categoryIds;
    }

    mapping(address => uint) public marketplaceToValidBlockNumber;

    uint256 public id;
    mapping(uint256 => AccountItem) public idToAccountItem;

    mapping(address => uint256) public numberOfItemsOwned;
    mapping(address => uint)    public balances;

    uint64 public categoryId;
    mapping(uint64 => ShopItem) public categoryIdToItem;
    mapping(uint64 => address)  public categoryIdCreator;

    bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

    mapping(uint256 => address) internal tokenApprovals;

    mapping(address => mapping(address => bool)) internal operatorApprovals;

    modifier onlyOwnerOf(uint256 _tokenId) {

        require(ownerOf(_tokenId) == msg.sender);
        _;
    }

    modifier canTransfer(uint256 _tokenId) {

        require(isApprovedOrOwner(msg.sender, _tokenId));
        _;
    }

    function balanceOf(address _owner) public view returns (uint256) {

        require(_owner != address(0));
        return numberOfItemsOwned[owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {

        address owner = idToAccountItem[_tokenId].owner;
        require(owner != address(0));
        return owner;
    }

    function exists(uint256 _tokenId) public view returns (bool) {

        address owner = idToAccountItem[_tokenId].owner;
        return owner != address(0);
    }

    function approve(address _to, uint256 _tokenId) public {

        address owner = ownerOf(_tokenId);
        require(_to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        if (getApproved(_tokenId) != address(0) || _to != address(0)) {
            tokenApprovals[_tokenId] = _to;
            emit Approval(owner, _to, _tokenId);
        }
    }

    function getApproved(uint256 _tokenId) public view returns (address) {

        return tokenApprovals[_tokenId];
    }

    function setApprovalForAll(address _to, bool _approved) public {

        require(_to != msg.sender);
        operatorApprovals[msg.sender][_to] = _approved;
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {

        return operatorApprovals[_owner][_operator];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) notPaused {

        require(_from != address(0));
        require(_to != address(0));

        idToAccountItem[_tokenId].lastModifiedNonce = idToAccountItem[_tokenId].lastModifiedNonce.add(1);

        clearApproval(_from, _tokenId);
        removeTokenFrom(_from, _tokenId);
        addTokenTo(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    public
    canTransfer(_tokenId)
    notPaused
    {

        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
    public
    canTransfer(_tokenId)
    notPaused
    {

        transferFrom(_from, _to, _tokenId);
        require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
    }

    function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {

        address owner = ownerOf(_tokenId);
        bool isApproved = block.number > marketplaceToValidBlockNumber[_spender] && marketplaceToValidBlockNumber[_spender] > 0;
        return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender) || isApproved;
    }

    function _mint(address _to, uint256 _tokenId) internal {

        require(_to != address(0));
        addTokenTo(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }

    function _burn(address _owner, uint256 _tokenId) internal {

        clearApproval(_owner, _tokenId);
        removeTokenFrom(_owner, _tokenId);
        emit Transfer(_owner, address(0), _tokenId);
    }

    function clearApproval(address _owner, uint256 _tokenId) internal {

        require(ownerOf(_tokenId) == _owner);
        if (tokenApprovals[_tokenId] != address(0)) {
            tokenApprovals[_tokenId] = address(0);
            emit Approval(_owner, address(0), _tokenId);
        }
    }

    function addTokenTo(address _to, uint256 _tokenId) internal {

        require(idToAccountItem[_tokenId].owner == address(0));
        idToAccountItem[_tokenId].owner = _to;
        numberOfItemsOwned[_to] = numberOfItemsOwned[_to].add(1);
    }

    function removeTokenFrom(address _from, uint256 _tokenId) internal {

        require(ownerOf(_tokenId) == _from);
        numberOfItemsOwned[_from] = numberOfItemsOwned[_from].sub(1);
        idToAccountItem[_tokenId].owner = address(0);
    }

    function checkAndCallSafeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
    internal
    returns (bool)
    {

        if (!_to.isContract()) {
            return true;
        }
        bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
        return (retval == ERC721_RECEIVED);
    }
}

contract Mintible is MintibleOwnership {


    event Create(uint256[] flattenedMetadata, uint128[] prices, uint64[] supplies, uint64 firstCategoryId, uint128[] localShopItemIds);
    event Buy(uint64 categoryId, uint256[] itemIds, address buyerAddress, uint256 totalPaid, uint256 fee);
    event Withdraw(address user, uint256 amount);
    event ActionResult(uint256 id, uint256[] newIds, uint64[] newCategoryIds, uint256 lastActionTime);

    constructor(address _marketplace) public {
        marketplaceToValidBlockNumber[_marketplace] = block.number;
        categoryId++;
        id++;
    }

    function setPaused(bool _isPaused) public onlyOwner {

        paused = _isPaused;
    }

    function setMarketplace(address _marketplace, uint _blockNumber) public onlyOwner {

        marketplaceToValidBlockNumber[_marketplace] = _blockNumber;
    }

    function create(uint256[] _creationData, uint128[] _prices, uint64[] _supplies, uint128[] _localShopItemIds) external notPaused {


        require(_prices.length > 0 && _prices.length == _supplies.length);

        uint64 indexOffset = categoryId;

        uint256 j = 0;
        for (uint64 i = indexOffset; i < indexOffset.add(uint64(_prices.length)); i++) {

            _create(i, _prices[i.sub(indexOffset)], _supplies[i.sub(indexOffset)]);

            if (_creationData[j] > 0) {
                _handleData(_creationData, i, j, indexOffset, _prices.length);
                j = j.add(4).add(_creationData[j].mul(2));
            } else {
                j = j.add(1);
            }
        }

        emit Create(_creationData, _prices, _supplies, indexOffset, _localShopItemIds);
    }

    function _create(uint64 _categoryId, uint128 _price, uint64 _supply) private {


        categoryIdCreator[_categoryId] = msg.sender;

        if (_supply != 0) {
            categoryIdToItem[_categoryId].supply = _supply;
            categoryIdToItem[_categoryId].price = _price;
        }

        categoryId++;
    }

    function _handleData(uint256[] _creationData, uint64 _i, uint256 _j, uint64 _indexOffset, uint256 _length) private {

        uint32[] memory odds        = getUint32SubArray(_creationData, _j.add(1), _j.add(1).add(_creationData[_j]));
        uint64[] memory categoryIds = getUint64SubArray(_creationData, _j.add(1).add(_creationData[_j]), _j.add(1).add(_creationData[_j].mul(2)));

        _validateData(odds, categoryIds, _length);

        for (uint256 k = 0; k < categoryIds.length; k++) {
            categoryIds[k] = categoryIds[k].add(_indexOffset);
        }

        categoryIdToItem[_i].cooldown        = uint128(_creationData[_j.add(3).add(_creationData[_j].mul(2))]);
        categoryIdToItem[_i].numberOfOutputs = uint16(_creationData[_j.add(2).add(_creationData[_j].mul(2))]);
        categoryIdToItem[_i].isDestroyable   = uint8(_creationData[_j.add(1).add(_creationData[_j].mul(2))]);
        categoryIdToItem[_i].odds            = odds;
        categoryIdToItem[_i].categoryIds     = categoryIds;
    }

    function _validateData(uint32[] _odds, uint64[] _categoryIds, uint256 _length) private pure {


        require(_odds.length == _categoryIds.length);

        for (uint256 i = 0; i < _categoryIds.length; i++) {
            require(_categoryIds[i] <= _length);
        }

        require(_odds[0] > 0);
        for (uint256 j = 0; j < _odds.length.sub(1); j++) {
            require(_odds[j] < _odds[j + 1]);
        }
    }

    function buy(uint64 _categoryId, uint64 _amount) external payable notPaused {

        require(_categoryId > 0 && _categoryId < categoryId);
        require(_amount > 0);

        require(categoryIdToItem[_categoryId].supply >= _amount);
        require(categoryIdToItem[_categoryId].price.mul(uint128(_amount)) == msg.value);

        categoryIdToItem[_categoryId].supply = categoryIdToItem[_categoryId].supply.sub(_amount);

        uint256[] memory itemIds = new uint[](_amount);
        for (uint64 i = 0; i < _amount; i++) {
            idToAccountItem[id].categoryId = _categoryId;
            _mint(msg.sender, id);

            itemIds[i] = id;
            id++;
        }

        uint256 totalPaid = msg.value;

        uint256 fee = totalPaid.mul(35 finney) / 1 ether;

        uint256 netPaid = totalPaid.sub(fee);

        balances[categoryIdCreator[_categoryId]] = balances[categoryIdCreator[_categoryId]].add(netPaid);
        balances[owner] = balances[owner].add(fee);

        emit Buy(_categoryId, itemIds, msg.sender, totalPaid, fee);
    }

    function action(uint256 _id) external notPaused {

        AccountItem storage accountItem = idToAccountItem[_id];

        require(accountItem.owner == msg.sender);

        ShopItem storage shopItem = categoryIdToItem[accountItem.categoryId];

        require(shopItem.odds.length > 0);

        require(accountItem.latestActionTime == 0 || now.sub(accountItem.latestActionTime) > shopItem.cooldown);
        accountItem.latestActionTime = uint128(now);
        accountItem.lastModifiedNonce = accountItem.lastModifiedNonce.add(1);

        uint32[] memory odds = shopItem.odds;
        uint64[] memory categoryIds = shopItem.categoryIds;

        uint256[] memory newIds = new uint256[](shopItem.numberOfOutputs);
        uint64[] memory newCategoryIds = new uint64[](shopItem.numberOfOutputs);

        for (uint256 i = 0; i < shopItem.numberOfOutputs; i++) {
            uint32 randomValue = rand(0, odds[odds.length.sub(1)]);

            uint256 index = getIndexFromOdd(randomValue, odds);

            idToAccountItem[id].categoryId = categoryIds[index];
            _mint(msg.sender, id);

            newIds[i] = id;
            newCategoryIds[i] = categoryIds[index];

            id++;
        }

        if (shopItem.isDestroyable == 1) {
            _burn(msg.sender, _id);
        }

        emit ActionResult(_id, newIds, newCategoryIds, accountItem.latestActionTime);
    }

    function withdraw(uint256 _amount) public {

        require(balances[msg.sender] >= _amount);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        msg.sender.transfer(_amount);

        emit Withdraw(msg.sender, _amount);
    }



    function payFee(uint256 _id) public payable {

        address creator = categoryIdCreator[idToAccountItem[_id].categoryId];
        balances[creator] = balances[creator].add(msg.value);
    }

    function getLastModifiedNonce(uint256 _id) public view returns (uint) {

        return idToAccountItem[_id].lastModifiedNonce;
    }

    function getCategoryId() public view returns (uint) {

        return categoryId;
    }

    function getNumberOfOdds(uint64 _categoryId) public view returns (uint) {

        return categoryIdToItem[_categoryId].odds.length;
    }

    function getOddValue(uint64 _categoryId, uint256 _i) public view returns (uint) {

        return categoryIdToItem[_categoryId].odds[_i];
    }

    function getNumberOfCategoryIds(uint64 _categoryId) public view returns (uint) {

        return categoryIdToItem[_categoryId].categoryIds.length;
    }

    function getCategoryIdsValue(uint64 _categoryId, uint256 _i) public view returns (uint) {

        return categoryIdToItem[_categoryId].categoryIds[_i];
    }
}