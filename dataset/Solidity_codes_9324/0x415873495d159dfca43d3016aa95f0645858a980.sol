

pragma solidity 0.8.2;


interface IERC721 {

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

contract Market {

    using EnumerableSet for EnumerableSet.Bytes32Set ;
    using EnumerableMap for EnumerableMap.UintToB32Map;
    using SafeERC20 for IERC20;
    
    struct Coin {
        bool active;
        address tokenAddress;
        string symbol;
        string name;
    }
    
    mapping (uint256 => Coin) public tradeCoins;
    
    struct Trade {
        uint256 indexedBy;
        bool active; 
        address nftAddress;
        address seller;
        address buyer;
        uint256 assetId;
        uint256 end;
        uint256 stime;
        uint256 price;
        uint256 coinIndex;
        
    }
    
    mapping (uint8 => address) public managers;
    mapping (bytes32 => bool) public executedTask;
    uint16 public taskIndex;
    
    mapping (address => bool) public authorizedERC721;
    mapping (uint256 => bytes32) public tradeIndex;
    mapping (bytes32 => Trade) public trades;
    mapping (bytes32 => bool) public tradingCheck;

    EnumerableMap.UintToB32Map private tradesMap;
    mapping (address => EnumerableSet.Bytes32Set) private userTrades;
    
    uint256 nextTrade;
    FeesContract feesContract;
    address payable walletAddress;
    
    modifier isManager() {

        require(managers[0] == msg.sender || managers[1] == msg.sender || managers[2] == msg.sender, "Not manager");
        _;
    }
    
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
        
        walletAddress = payable(0xf7A9F6001ff8b499149569C54852226d719f2D76);
        
        managers[0] = msg.sender;
        managers[1] = 0xeA50CE6EBb1a5E4A8F90Bfb35A2fb3c3F0C673ec;
        managers[2] = 0xB1A951141F1b3A16824241f687C3741459E33225;
        
        feesContract = FeesContract(0xc10881fa05CE734336A153c72999eE91A287cC30);
    }
    
    function createTrade(address _nftAddress, uint256 _assetId, uint256 _price, uint256 _coinIndex, uint256 _end) public {

        require(authorizedERC721[_nftAddress] == true, "Unauthorized asset");
        require(tradeCoins[_coinIndex].active == true, "Invalid payment coin");
        require(_end == 0 || _end > block.timestamp, "Invalid end time");
        bytes32 atCheck = keccak256(abi.encode(_nftAddress, _assetId, msg.sender));
        require(tradingCheck[atCheck] == false, "This asset is already listed");
        IERC721 nftContract = IERC721(_nftAddress);
        require(nftContract.ownerOf(_assetId) == msg.sender, "Only asset owner can sell");
        require(nftContract.isApprovedForAll(msg.sender, address(this)), "Market needs operator approval");
        insertTrade(_nftAddress, _assetId, _price, _coinIndex, _end, atCheck);
    }
    
    function insertTrade(address _nftAddress, uint256 _assetId, uint256 _price, uint256 _coinIndex, uint256 _end, bytes32 _atCheck) private {

        Trade memory trade = Trade(nextTrade, true, _nftAddress, msg.sender, address(0x0), _assetId, _end, block.timestamp, _price, _coinIndex);
        bytes32 tradeHash = keccak256(abi.encode(_nftAddress, _assetId, nextTrade));
        tradeIndex[nextTrade] = tradeHash;
        trades[tradeHash] = trade;
        tradesMap.set(nextTrade, tradeHash);
        userTrades[msg.sender].add(tradeHash);
        tradingCheck[_atCheck] == true;
        nextTrade += 1;
    }
    
    function allTradesCount() public view returns (uint256) {

        return (nextTrade);
    }

    function tradesCount() public view returns (uint256) {

        return (tradesMap.length());
    }
    
    function _getTrade(bytes32 _tradeId) private view returns (uint256 indexedBy, address nftToken, address seller, address buyer, uint256 assetId, uint256 end, uint256 sTime, uint256 price, uint256 coinIndex, bool active) {

        Trade memory _trade = trades[_tradeId];
        return (
        _trade.indexedBy,
        _trade.nftAddress,
        _trade.seller,
        _trade.buyer,
        _trade.assetId,
        _trade.end,
        _trade.stime,
        _trade.price,
        _trade.coinIndex,
        _trade.active
        );

    }

    function getTrade(bytes32 _tradeId) public view returns (uint256 indexedBy, address nftToken, address seller, address buyer, uint256 assetId, uint256 end, uint256 sTime, uint256 price, uint256 coinIndex, bool active) {

        return _getTrade(_tradeId);
    }
    
    function getTradeByIndex(uint256 _index) public view returns (uint256 indexedBy, address nftToken, address seller, address buyer, uint256 assetId, uint256 end, uint256 sTime, uint256 price, uint256 coinIndex, bool active) {

        (, bytes32 tradeId) = tradesMap.at(_index);
        return _getTrade(tradeId);
    }

    function parseBytes(bytes memory data) private pure returns (bytes32){

        bytes32 parsed;
        assembly {parsed := mload(add(data, 32))}
        return parsed;
    }
    
    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) public returns (bool) {

        bytes32 _tradeId = parseBytes(_extraData);
        Trade memory trade = trades[_tradeId];
        require(tradeCoins[trade.coinIndex].tokenAddress == _token, "Invalid coin");
        require(trade.active == true, "Trade not available");
        require(_value == trade.price, "Invalid price");
        if (verifyTrade(_tradeId, trade.seller, trade.nftAddress, trade.assetId, trade.end)) {
            uint256 tradeFee = feesContract.calcByToken(trade.seller, tradeCoins[trade.coinIndex].tokenAddress , _value); 
            executeTrade(_tradeId, _from, trade.seller, trade.nftAddress, trade.assetId);
            IERC20 erc20Token = IERC20(_token); 
            if (tradeFee > 0) {
                erc20Token.safeTransferFrom(_from, walletAddress, (tradeFee));
                erc20Token.safeTransferFrom(_from, trade.seller, (trade.price-tradeFee));
            } else {
                erc20Token.safeTransferFrom(_from, trade.seller, (trade.price));
            }
            transferAsset(_from, trade.seller, trade.nftAddress, trade.assetId);
            return (true);
        } else {
            return (false);
        }

    }
    
    function buyWithEth(bytes32 _tradeId) public payable returns (bool) {

        Trade memory trade = trades[_tradeId];
        require(trade.coinIndex == 1, "Invalid coin");
        require(trade.active == true, "Trade not available");
        require(msg.value == trade.price, "Invalid price");
        if (verifyTrade(_tradeId, trade.seller, trade.nftAddress, trade.assetId, trade.end)) {
            uint256 tradeFee = feesContract.calcByEth(trade.seller, msg.value);
            executeTrade(_tradeId, msg.sender, trade.seller, trade.nftAddress, trade.assetId);
            if (tradeFee > 0) {
              Address.sendValue(payable(walletAddress), tradeFee);
              Address.sendValue(payable(trade.seller),(msg.value-tradeFee));
            } else {
              Address.sendValue(payable(trade.seller),(msg.value));
            }
            transferAsset(msg.sender, trade.seller, trade.nftAddress, trade.assetId);
            return (true);
        } else {
            return (false);
        }

    }
    
    function executeTrade(bytes32 _tradeId, address _buyer, address _seller, address _contract, uint256 _assetId) private {

        trades[_tradeId].buyer = _buyer;
        trades[_tradeId].active = false;
        trades[_tradeId].stime = block.timestamp;
        userTrades[_seller].remove(_tradeId);
        tradesMap.remove(trades[_tradeId].indexedBy);
        tradingCheck[keccak256(abi.encode(_contract, _assetId, _seller))] = false;
    }
    
    function transferAsset(address _buyer, address _seller, address _contract, uint256 _assetId) private {

        IERC721 nftToken = IERC721(_contract);
        nftToken.safeTransferFrom(_seller, _buyer, _assetId);
    }
    
    function verifyTrade(bytes32 _tradeId, address _seller, address _contract, uint256 _assetId, uint256 _endTime) private returns (bool) {

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

    function cancelTrade(bytes32 _tradeId) public returns (bool) {

        Trade memory trade = trades[_tradeId];
        require(trade.seller == msg.sender, "Only asset seller can cancel the trade");
        trades[_tradeId].active = false;
        userTrades[trade.seller].remove(_tradeId);
        tradesMap.remove(trade.indexedBy);
        tradingCheck[keccak256(abi.encode(trade.nftAddress, trade.assetId, trade.seller))] = false;
        return true;
    }

    function adminCancelTrade(bytes32 _tradeId, bytes memory _sig) public isManager {

        uint8 mId = 1;
        bytes32 taskHash = keccak256(abi.encode(_tradeId, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        Trade memory trade = trades[_tradeId];
        trades[_tradeId].active = false;
        userTrades[trade.seller].remove(_tradeId);
        tradesMap.remove(trade.indexedBy);
        tradingCheck[keccak256(abi.encode(trade.nftAddress, trade.assetId, trade.seller))] = false;
    }
    
    function tradesCountOf(address _from) public view returns (uint256) {

        return (userTrades[_from].length());
    }
    
    function tradeOfByIndex(address _from, uint256 _index) public view returns (bytes32 _trade) {

        return (userTrades[_from].at(_index));
    }
    
    function addCoin(uint256 _coinIndex, address _tokenAddress, string memory _tokenSymbol, string memory _tokenName, bool _active, bytes memory _sig) public isManager {

        uint8 mId = 2;
        bytes32 taskHash = keccak256(abi.encode(_coinIndex, _tokenAddress, _tokenSymbol, _tokenName, _active, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        tradeCoins[_coinIndex].tokenAddress = _tokenAddress;
        tradeCoins[_coinIndex].symbol = _tokenSymbol;
        tradeCoins[_coinIndex].name = _tokenName;
        tradeCoins[_coinIndex].active = _active;
    }

    function authorizeNFT(address _nftAddress, bytes memory _sig) public isManager {

        uint8 mId = 3;
        bytes32 taskHash = keccak256(abi.encode(_nftAddress, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        authorizedERC721[_nftAddress] = true;
    }
    
    function deauthorizeNFT(address _nftAddress, bytes memory _sig) public isManager {

        uint8 mId = 4;
        bytes32 taskHash = keccak256(abi.encode(_nftAddress, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        authorizedERC721[_nftAddress] = false;
    }
    
    function setFeesContract(address _contract, bytes memory _sig) public isManager {

        uint8 mId = 5;
        bytes32 taskHash = keccak256(abi.encode(_contract, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        feesContract = FeesContract(_contract);
    }
    
    function setWallet(address _wallet, bytes memory _sig) public isManager  {

        uint8 mId = 6;
        bytes32 taskHash = keccak256(abi.encode(_wallet, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        walletAddress = payable(_wallet);
    }
    
    function verifyApproval(bytes32 _taskHash, bytes memory _sig) private {

        require(executedTask[_taskHash] == false, "Task already executed");
        address mSigner = ECDSA.recover(ECDSA.toEthSignedMessageHash(_taskHash), _sig);
        require(mSigner == managers[0] || mSigner == managers[1] || mSigner == managers[2], "Invalid signature"  );
        require(mSigner != msg.sender, "Signature from different managers required");
        executedTask[_taskHash] = true;
        taskIndex += 1;
    }
    
    function changeManager(address _manager, uint8 _index, bytes memory _sig) public isManager {

        require(_index >= 0 && _index <= 2, "Invalid index");
        uint8 mId = 100;
        bytes32 taskHash = keccak256(abi.encode(_manager, taskIndex, mId));
        verifyApproval(taskHash, _sig);
        managers[_index] = _manager;
    }
    

}