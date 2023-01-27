

pragma solidity ^0.8.0;

interface IERC721 {

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

}
interface IERC20Token {

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function transfer(address recipient, uint256 amount) external returns (bool);

}
interface FeesContract {

    function calcByToken(address _seller, address _token, uint256 _amount) external view returns (uint256 fee);

    function calcByEth(address _seller, uint256 _amount) external view returns (uint256 fee);

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


    struct UintToB32Map {
        Map _inner;
    }

    function set(UintToB32Map storage map, uint256 key, bytes32 value) internal returns (bool) {

        return _set(map._inner, bytes32(key), value);
    }

    function remove(UintToB32Map storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToB32Map storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));
    }

    function length(UintToB32Map storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToB32Map storage map, uint256 index) internal view returns (uint256, bytes32) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), value);
    }

    function tryGet(UintToB32Map storage map, uint256 key) internal view returns (bool, bytes32) {

        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, value);
    }

    function get(UintToB32Map storage map, uint256 key) internal view returns (bytes32) {

        return _get(map._inner, bytes32(key));
    }

    function get(UintToB32Map storage map, uint256 key, string memory errorMessage) internal view returns (bytes32) {

        return _get(map._inner, bytes32(key), errorMessage);
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


contract Ownable {


    address private owner;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    modifier onlyOwner() {

        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }


    function changeOwner(address newOwner) public onlyOwner {

        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() external view returns (address) {

        return owner;
    }
}

contract Market is Ownable {

    using EnumerableSet for EnumerableSet.Bytes32Set ;
    using EnumerableMap for EnumerableMap.UintToB32Map;
    
    struct Coin {
        address tokenAddress;
        string symbol;
        string name;
        bool active;
    }
    mapping (uint256 => Coin) public tradeCoins;
    
    struct Trade {
        uint256 indexedBy;
        address nftAddress;
        address seller;
        address buyer;
        uint256 assetId;
        uint256 start;
        uint256 end;
        uint256 stime;
        uint256 price;
        uint256 coinIndex;
        bool active; 
    }
    
    mapping (address => bool) public authorizedERC721;
    mapping (uint256 => bytes32) public tradeIndex;
    mapping (bytes32 => Trade) public trades;

    EnumerableMap.UintToB32Map private tradesMap;
    mapping (address => EnumerableSet.Bytes32Set) private userTrades;
    
    uint256 nextTrade;
    FeesContract feesContract;
    address payable walletAddress;
    
    constructor() {
        tradeCoins[1].tokenAddress = address(0x0);
        tradeCoins[1].symbol = "ETH";
        tradeCoins[1].name = "Ethereum";
        tradeCoins[1].active = true;
        
        tradeCoins[2].tokenAddress = 0xaA8330FB2B4D5D07ABFE7A72262752a8505C6B37;
        tradeCoins[2].symbol = "POLC";
        tradeCoins[2].name = "Polka City Token";
        tradeCoins[2].active = true;
        
        authorizedERC721[0xB20217bf3d89667Fa15907971866acD6CcD570C8] = true;
        authorizedERC721[0x57E9a39aE8eC404C08f88740A9e6E306f50c937f] = true;
        
        walletAddress = payable(0xAD334543437EF71642Ee59285bAf2F4DAcBA613F);
        

    }
    
    function createTrade(address _nftAddress, uint256 _assetId, uint256 _price, uint256 _coinIndex, uint256 _end) public {

        require(authorizedERC721[_nftAddress] == true, "Unauthorized asset");
        require(tradeCoins[_coinIndex].active == true, "Invalid payment coin");
        require(_end == 0 || _end > block.timestamp, "Invalid end time");
        IERC721 nftContract = IERC721(_nftAddress);
        require(nftContract.ownerOf(_assetId) == msg.sender, "Only asset owner can sell");
        require(nftContract.isApprovedForAll(msg.sender, address(this)), "Market needs operator approval");
        insertTrade(_nftAddress, _assetId, _price, _coinIndex, _end);
    }
    
    function insertTrade(address _nftAddress, uint256 _assetId, uint256 _price, uint256 _coinIndex, uint256 _end) private {

        Trade memory trade = Trade(nextTrade, _nftAddress, msg.sender, address(0x0), _assetId, block.timestamp, _end, 0, _price, _coinIndex, true);
        bytes32 tradeHash = keccak256(abi.encode(_nftAddress, _assetId, nextTrade));
        tradeIndex[nextTrade] = tradeHash;
        trades[tradeHash] = trade;
        tradesMap.set(nextTrade, tradeHash);
        userTrades[msg.sender].add(tradeHash);
        nextTrade += 1;
    }
    
    function allTradesCount() public view returns (uint256 count) {

        return (nextTrade);
    }

    function tradesCount() public view returns (uint256 count) {

        return (tradesMap.length());
    }
    
    function _getTrade(bytes32 _tradeId) private view returns (uint256 indexedBy, address nftToken, address seller, address buyer, uint256 assetId, uint256 start, uint256 end, uint256 soldDate, uint256 price, uint256 coinIndex, bool active) {

        Trade memory _trade = trades[_tradeId];
        return (
        _trade.indexedBy,
        _trade.nftAddress,
        _trade.seller,
        _trade.buyer,
        _trade.assetId,
        _trade.start,
        _trade.end,
        _trade.stime,
        _trade.price,
        _trade.coinIndex,
        _trade.active
        );

    }

    function getTrade(bytes32 _tradeId) public view returns (uint256 indexedBy, address nftToken, address seller, address buyer, uint256 assetId, uint256 start, uint256 end, uint256 soldDate, uint256 price, uint256 coinIndex, bool active) {

        return _getTrade(_tradeId);
    }
    
    function getTradeByIndex(uint256 _index) public view returns (uint256 indexedBy, address nftToken, address seller, address buyer, uint256 assetId, uint256 start, uint256 end, uint256 soldDate, uint256 price, uint256 coinIndex, bool active) {

        (, bytes32 tradeId) = tradesMap.at(_index);
        return _getTrade(tradeId);
    }

    function parseBytes(bytes memory data) private pure returns (bytes32){

        bytes32 parsed;
        assembly {parsed := mload(add(data, 32))}
        return parsed;
    }
    
    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public returns (bool success) {

        bytes32 _tradeId = parseBytes(_extraData);
        Trade memory trade = trades[_tradeId];
        require(tradeCoins[trade.coinIndex].tokenAddress == _token, "Invalid coin");
        require(trade.active == true, "Trade not available");
        require(_value == trade.price, "Invalid price");
        if (verifyTrade(_tradeId, trade.seller, trade.nftAddress, trade.assetId, trade.end)) {
            uint256 tradeFee = feesContract.calcByToken(trade.seller, tradeCoins[trade.coinIndex].tokenAddress , _value);
            IERC20Token erc20Token = IERC20Token(_token);  
            if (tradeFee > 0) {
                require(erc20Token.transferFrom(_from, trade.seller, (trade.price-tradeFee)), "ERC20 transfer fail");
                require(erc20Token.transferFrom(_from, walletAddress, (tradeFee)), "ERC20 transfer fail");
            } else {
                require(erc20Token.transferFrom(_from, trade.seller, (trade.price)), "ERC20 transfer fail");
            }
            executeTrade(_tradeId, _from, trade.seller, trade.nftAddress, trade.assetId);
            return (true);
        } else {
            return (false);
        }

    }
    
    function buyWithEth(bytes32 _tradeId) public payable returns (bool success) {

        Trade memory trade = trades[_tradeId];
        require(trade.coinIndex == 1, "Invalid coin");
        require(trade.active == true, "Trade not available");
        require(msg.value == trade.price, "Invalid price");
        if (verifyTrade(_tradeId, trade.seller, trade.nftAddress, trade.assetId, trade.end)) {
            uint256 tradeFee = feesContract.calcByEth(trade.seller, msg.value);
            if (tradeFee > 0) {
                walletAddress.transfer(msg.value);
            }
            payable(trade.seller).transfer(msg.value-tradeFee);
            executeTrade(_tradeId, msg.sender, trade.seller, trade.nftAddress, trade.assetId);
            return (true);
        } else {
            return (false);
        }

    }
    
    function executeTrade(bytes32 _tradeId, address _buyer, address _seller, address _contract, uint256 _assetId) private {

        IERC721 nftToken = IERC721(_contract);
        nftToken.safeTransferFrom(_seller, _buyer, _assetId);
        trades[_tradeId].buyer = _buyer;
        trades[_tradeId].active = false;
        trades[_tradeId].stime = block.timestamp;
        userTrades[_seller].remove(_tradeId);
        tradesMap.remove(trades[_tradeId].indexedBy);
    }
    
    function verifyTrade(bytes32 _tradeId, address _seller, address _contract, uint256 _assetId, uint256 _endTime) private returns (bool _valid) {

        IERC721 nftToken = IERC721(_contract);
        address assetOwner = nftToken.ownerOf(_assetId);
        if (assetOwner != _seller || (_endTime > 0 && _endTime < block.timestamp)) {
            trades[_tradeId].active = false;
            userTrades[_seller].remove(_tradeId);
            tradesMap.remove(trades[_tradeId].indexedBy);
            return false;
        } else {
            return true;
        }
    }

    function cancelTrade(bytes32 _tradeId) public returns (bool success) {

        Trade memory trade = trades[_tradeId];
        require(trade.seller == msg.sender, "Only asset seller can cancel the trade");
        trades[_tradeId].active = false;
        userTrades[trade.seller].remove(_tradeId);
        tradesMap.remove(trade.indexedBy);
        return true;
    }

    function adminCancelTrade(bytes32 _tradeId) public onlyOwner {

        Trade memory trade = trades[_tradeId];
        trades[_tradeId].active = false;
        userTrades[trade.seller].remove(_tradeId);
        tradesMap.remove(trade.indexedBy);
    }
    
    function tradesCountOf(address _from) public view returns (uint256 _count) {

        return (userTrades[_from].length());
    }
    
    function tradeOfByIndex(address _from, uint256 _index) public view returns (bytes32 _trade) {

        return (userTrades[_from].at(_index));
    }
    
    function addCoin(uint256 _coinIndex, address _tokenAddress, string memory _tokenSymbol, string memory _tokenName, bool _active) public onlyOwner {

        tradeCoins[_coinIndex].tokenAddress = _tokenAddress;
        tradeCoins[_coinIndex].symbol = _tokenSymbol;
        tradeCoins[_coinIndex].name = _tokenName;
        tradeCoins[_coinIndex].active = _active;
    }

    function autorizenft(address _nftAddress) public onlyOwner {

        authorizedERC721[_nftAddress] = true;
    }
    
    function deautorizenft(address _nftAddress) public onlyOwner {

        authorizedERC721[_nftAddress] = false;
    }
    
    function setFeesContract(address _contract) public onlyOwner {

        feesContract = FeesContract(_contract);
    }
    
    function setWallet(address _wallet) public onlyOwner {

        walletAddress = payable(_wallet);
    }
    
}