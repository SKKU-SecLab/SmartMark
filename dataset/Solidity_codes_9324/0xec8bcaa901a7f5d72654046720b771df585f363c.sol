pragma solidity >0.6.0;

library Lib {


    struct ProductCount {
        uint256 buyCount;
        uint256 miningCount;
        uint256 withdrawSum;
        uint256 withdrawCount;
        uint256 redeemedCount;
    }

    struct ProductMintItem {
        address minter;
        uint256 beginTime;
        uint256 withdrawTime;
        uint256 endTime;
        uint256 totalValue;
    }

    struct ProductTokenDetail {
        uint256 id;
        bool mining;
        uint256 totalTime;
        uint256 totalValue;
        uint256 propA;
        uint256 propB;
        uint256 propC;
        ProductMintItem currMining;
    }

    function random(uint256 min, uint256 max) internal view returns (uint256) {

        uint256 gl = gasleft();
        uint256 seed = uint256(keccak256(abi.encodePacked(
                block.timestamp + block.difficulty +
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
                block.gaslimit + gl +
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
                block.number
            )));
        return min + (seed - ((seed / (max - min)) * (max - min)));
    }

}// MIT

pragma solidity ^0.7.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity ^0.7.0;


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
}// MIT

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.7.0;

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


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
}// MIT

pragma solidity ^0.7.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.7.0;


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

}// MIT
pragma experimental ABIEncoderV2;


interface IDNFTProduct is IERC721 {


    function name() external view returns (string memory);


    function owner() external view returns (address);


    function mainAddr() external view returns (address);


    function pid() external view returns (uint16);


    function maxMintTime() external view returns (uint256);


    function maxTokenSize() external view returns (uint256);


    function costTokenAddr() external view returns (address);


    function cost() external view returns (uint256);


    function totalReturnRate() external view returns (uint32);


    function getDNFTPrice() external view returns (uint256);


    function mintTimeInterval() external view returns (uint256);


    function mintPerTimeValue() external view returns (uint256);


    function tokensOfOwner(address ownerAddr) external view returns (Lib.ProductTokenDetail[] memory);


    function tokenDetailOf(uint256 tid) external view returns (Lib.ProductTokenDetail memory);


    function tokenMintHistoryOf(uint256 tid) external view returns (Lib.ProductMintItem[] memory);


    function withdrawToken(address to, address token, uint256 value) external;


    function buy(address to) external returns (uint256);


    function mintBegin(address from, uint256 tokenId) external;


    function mintWithdraw(address from, uint256 tokenId) external returns (uint256, uint256);


    function redeem(address from, uint256 tokenId) external returns (uint256, uint256);


}// MIT

pragma solidity ^0.7.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.7.0;


library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT


contract DNFTMain is Pausable, Ownable {


    struct Player {
        address addr;
        address parent;
        address[] children;
        uint256 buyCount;
        uint256 rewardCount;
        uint256 withdrawTotalValue;
    }
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeMath for uint32;

    address public mainCreator;
    address payable public withdrawTo;
    IERC20 public dnftToken;

    mapping(string => address) private _products;
    mapping(string => Lib.ProductCount) private _productsCount;
    string[] private _productNames;
    string public rewardProductName;

    mapping(address => Player) private _players;

    mapping(address => address) public _playerParents;

    mapping(address => address[]) public _playerChildren;

    uint256 public playerCount;

    event AddPlayer(address indexed player);
    event ProductBuy(address indexed player, string product, uint256 tokenId);
    event ProductReward(address indexed to, address indexed from, string fromProduct, string toProduct, uint256 cost, uint256 fromTokenId, uint256 toTokenId);
    event ProductMintBegin(address indexed player, string product, uint256 indexed tokenId);
    event ProductMintWithdraw(address indexed player, string product, uint256 indexed tokenId, uint256 value, uint256 timeNum);
    event ProductMintRedeem(address indexed player, string product, uint256 indexed tokenId, uint256 value, uint256 timeNum);


    constructor(address _dnftAddr, address payable _withdrawTo) {
        mainCreator = msg.sender;
        withdrawTo = _withdrawTo;
        dnftToken = IERC20(_dnftAddr);
    }

    function _getPlayer(address addr) private returns (Player storage){

        if (_players[addr].addr == address(0)) {
            Player memory player;
            player.addr = addr;
            _players[addr] = player;
            playerCount++;
            emit AddPlayer(addr);
        }
        return _players[addr];
    }

    function _getProduct(string memory name) private view returns (IDNFTProduct){

        require(_products[name] != address(0), "Product not exists.");
        return IDNFTProduct(_products[name]);
    }


    function getPlayer(address addr) external view returns (Player memory){

        return _players[addr];
    }

    function getProductAddress(string calldata name) external view returns (address){

        require(_products[name] != address(0), "Product not exists.");
        return _products[name];
    }

    function getProductCount(string calldata name) external view returns (Lib.ProductCount memory){

        require(_products[name] != address(0), "Product not exists.");
        return _productsCount[name];
    }

    function getProductNames() external view returns (string[] memory){

        return _productNames;
    }

    function setWithdrawTo(address payable addr) external {

        require(msg.sender == withdrawTo, "Must be withdraw account.");
        withdrawTo = addr;
    }

    function withdrawToken(address token, uint256 value) external {

        require(msg.sender == withdrawTo, "Must be withdraw account.");
        if (token == address(0))
            withdrawTo.transfer(value);
        else
            IERC20(token).safeTransfer(withdrawTo, value);
    }

    function withdrawProductToken(string calldata name, address token, uint256 value) external {

        require(msg.sender == withdrawTo, "Must be withdraw account.");
        IDNFTProduct p = _getProduct(name);
        p.withdrawToken(withdrawTo, token, value);
    }

    function setRewardProductName(string calldata name) onlyOwner external {

        require(_products[name] != address(0), "Product not exists.");
        rewardProductName = name;
    }

    function addProduct(address paddr, uint256 dnftValue) onlyOwner external {

        IDNFTProduct p = IDNFTProduct(paddr);
        string memory name = p.name();
        require(_products[name] == address(0), "Product already exists.");
        require(p.mainAddr() == address(this), "Product main addr not this.");
        _products[name] = paddr;
        _productNames.push(name);
        dnftToken.safeTransfer(paddr, dnftValue);
    }

    function buyProduct(string calldata name, address playerParent) external payable {

        require(playerParent != msg.sender, "Pay parent wrong.");
        IDNFTProduct p = _getProduct(name);
        if (bytes(rewardProductName).length != 0)
            require(address(p) != _products[rewardProductName], "This product cannot be purchased.");
        address costTokenAddr = p.costTokenAddr();
        uint256 cost = p.cost();
        if (costTokenAddr == address(0))
            require(msg.value == cost, "Pay value wrong.");
        else {
            require(msg.value == 0, "Pay value must be zero.");
            IERC20(costTokenAddr).safeTransferFrom(msg.sender, address(this), cost);
        }
        Player storage player = _getPlayer(msg.sender);
        if (playerParent != address(0)) {
            Player storage parentPlayer = _getPlayer(playerParent);
            player.parent = playerParent;
            parentPlayer.children.push(player.addr);
        }
        _productsCount[name].buyCount++;
        player.buyCount++;
        uint256 tokenId = p.buy(msg.sender);
        emit ProductBuy(msg.sender, name, tokenId);
        if (player.buyCount == 1 && player.parent != address(0) && bytes(rewardProductName).length != 0) {
            IDNFTProduct rp = IDNFTProduct(_products[rewardProductName]);
            if (_productsCount[rewardProductName].buyCount < rp.maxTokenSize()) {
                _getPlayer(player.parent).rewardCount++;
                _productsCount[rewardProductName].buyCount++;
                uint256 toTokenId = rp.buy(player.parent);
                emit ProductReward(player.parent, msg.sender, name, rewardProductName, msg.value, tokenId, toTokenId);
            }
        }
    }

    function mintBegin(string calldata name, uint256 tokenId) external {

        IDNFTProduct p = _getProduct(name);
        p.mintBegin(msg.sender, tokenId);
        _productsCount[name].miningCount++;
        emit ProductMintBegin(msg.sender, name, tokenId);
    }

    function mintWithdraw(string calldata name, uint256 tokenId) external {

        IDNFTProduct p = _getProduct(name);
        Player storage player = _getPlayer(msg.sender);
        (uint256 withdrawNum,uint256 timeNum) = p.mintWithdraw(msg.sender, tokenId);
        player.withdrawTotalValue += withdrawNum;
        _productsCount[name].withdrawCount++;
        _productsCount[name].withdrawSum += withdrawNum;
        emit ProductMintWithdraw(msg.sender, name, tokenId, withdrawNum, timeNum);
    }

    function redeemProduct(string calldata name, uint256 tokenId) external {

        IDNFTProduct p = _getProduct(name);
        Player storage player = _getPlayer(msg.sender);
        (uint256 withdrawNum,uint256 timeNum) = p.redeem(msg.sender, tokenId);
        player.withdrawTotalValue += withdrawNum;
        _productsCount[name].miningCount--;
        _productsCount[name].withdrawSum += withdrawNum;
        _productsCount[name].redeemedCount++;
        emit ProductMintRedeem(msg.sender, name, tokenId, withdrawNum, timeNum);
    }

}// MIT

pragma solidity ^0.7.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.7.0;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.7.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}// MIT

pragma solidity ^0.7.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity ^0.7.0;

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

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        return _get(map, key, "EnumerableMap: nonexistent key");
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

        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
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
        return (uint256(key), address(uint256(value)));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}// MIT

pragma solidity ^0.7.0;

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
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}// MIT

pragma solidity ^0.7.0;


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

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    function baseURI() public view returns (string memory) {

        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {

        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view override returns (uint256) {

        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {

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

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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

        address owner = ownerOf(tokenId);

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

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
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

    function _approve(address to, uint256 tokenId) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}// MIT

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}// MIT

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}// MIT

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}// MIT


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}// MIT


interface IERC20Token is IERC20 {

    function decimals() external view returns (uint8);

}// MIT


contract DNFTProduct is ERC721, Ownable {

    using SafeMath for uint256;
    using SafeMath for uint32;
    using SafeERC20 for IERC20;

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    mapping(uint256 => Lib.ProductTokenDetail) private _tokenDetails;
    mapping(uint256 => Lib.ProductMintItem[]) private _tokenMintHistories;
    mapping(address => EnumerableSet.UintSet) private _tokenMints;

    address public dnftTokenAddr;
    address public uniswapAddr;
    address public mainAddr;

    uint256 public mintPerTimeValue;

    uint16 public pid;
    uint256 public maxMintTime;
    uint256 public maxTokenSize;
    address public costTokenAddr;
    uint256 public cost;
    uint32 public totalReturnRate;
    uint256 public mintTimeInterval;
    uint8 public costTokenDecimals;

    Counters.Counter private _tokenIds;
    bool private _init;

    modifier onlyMain() {
        require(mainAddr == msg.sender, "caller is not the main");
        _;
    }
    constructor (
        string memory _name,
        string memory _symbol,
        string memory baseURI
    )  ERC721(_name, _symbol) {
        _setBaseURI(string(abi.encodePacked(baseURI, _name, "/")));
    }

    function initProduct(
        address _mainAddr,
        address _dnftTokenAddr,
        address _uniswapAddr,
        uint16 _id,
        address _costTokenAddr,
        uint256 _cost,
        uint32 _totalReturnRate,
        uint256 _maxMintTime,
        uint256 _maxTokenSize
    ) external onlyOwner {
        require(!_init, "repeat init");
        require(_maxTokenSize < 1E6, "product total supply must be < 1E6");
        mainAddr = _mainAddr;
        pid = _id;
        costTokenAddr = _costTokenAddr;
        cost = _cost;
        maxTokenSize = _maxTokenSize;
        maxMintTime = _maxMintTime;
        totalReturnRate = _totalReturnRate;
        dnftTokenAddr = _dnftTokenAddr;
        uniswapAddr = _uniswapAddr;
        if (_costTokenAddr != address(0)) {
            costTokenDecimals = IERC20Token(_costTokenAddr).decimals();
        } else {
            costTokenDecimals = 18;
        }
        mintTimeInterval = 1 minutes;
        mintPerTimeValue = totalReturnRate.mul(cost).div(100).div(maxMintTime.div(mintTimeInterval));
    }


    function _onlyMinter(address from, uint256 tokenId) private view {
        require(_isApprovedOrOwner(address(this), tokenId), "ERC721: transfer caller is not owner nor approved");
        require(_tokenDetails[tokenId].mining == true, "Token no mining.");
        require(_tokenDetails[tokenId].currMining.minter == from, "Token mine is not owner.");
    }

    function _getUniswapPrice(IUniswapV2Router02 r02, uint256 _tv1, address token1, address token2) private view returns (uint256){
        uint256 tv1 = _tv1;
        IUniswapV2Factory f = IUniswapV2Factory(r02.factory());
        address pairAddr = f.getPair(token1, token2);
        require(pairAddr != address(0), "DNFT uniswap pair not exists.");
        IERC20Token t1 = IERC20Token(token1);
        IERC20Token t2 = IERC20Token(token2);
        uint256 tb1 = t1.balanceOf(pairAddr);
        uint256 tb2 = t2.balanceOf(pairAddr);
        require(tb1 > 0 && tb2 > 0, "Pair token balance < 0");
        uint256 td1 = 10 ** t1.decimals();
        return td1.mul(tv1).div(tb1).mul(tb2).div(td1);
    }

    function _getDNFTPrice() private view returns (uint256){
        if (costTokenAddr == address(dnftTokenAddr))
            return 1E8;
        if (uniswapAddr == address(0)) {
            return 1000 * 1E8;
        }
        IUniswapV2Router02 r02 = IUniswapV2Router02(uniswapAddr);
        address wethAddr = r02.WETH();
        uint256 oneEthDnftPrice = _getUniswapPrice(r02, 1E18, wethAddr, address(dnftTokenAddr));
        if (costTokenAddr == address(0)) {
            return oneEthDnftPrice;
        } else {
            uint256 oneEthTokenPrice = _getUniswapPrice(r02, 1E18, wethAddr, costTokenAddr);
            if (costTokenDecimals == 8)
                return (oneEthDnftPrice * 1E8 / oneEthTokenPrice);
            if (costTokenDecimals < 8)
                return (oneEthDnftPrice * 1E8 / oneEthTokenPrice / (10 ** (8 - uint256(costTokenDecimals))));
            return (oneEthDnftPrice * 1E8 / oneEthTokenPrice) * (10 ** (uint256(costTokenDecimals) - 8));
        }
    }

    function _canWithdrawValue(uint256 tokenId) private view returns (uint256 timeNum, uint256 dnftNum){
        uint256 price = _getDNFTPrice();
        Lib.ProductTokenDetail storage detail = _tokenDetails[tokenId];
        uint256 freeTimeNum = (maxMintTime.sub(detail.totalTime)).div(mintTimeInterval);
        if (freeTimeNum <= 0) {
            return (0, 0);
        }
        timeNum = block.timestamp.sub(detail.currMining.withdrawTime).div(mintTimeInterval);
        if (timeNum > freeTimeNum) {
            timeNum = freeTimeNum;
        }
        if (timeNum <= 0) {
            return (0, 0);
        }
        uint256 decimal = 18;
        if (costTokenAddr != address(0))
            decimal = uint256(costTokenDecimals);
        dnftNum = mintPerTimeValue.mul(price).mul(timeNum).div(10 ** decimal);
        if (dnftNum <= 0) {
            return (0, 0);
        }
    }

    function _mintWithdraw(address player, uint256 tokenId) private returns (uint256, uint256){
        (uint256 timeNum, uint256 dnftNum) = _canWithdrawValue(tokenId);
        if (dnftNum <= 0)
            return (dnftNum, timeNum);
        Lib.ProductTokenDetail storage detail = _tokenDetails[tokenId];
        detail.totalValue = detail.totalValue.add(dnftNum);
        detail.currMining.totalValue = detail.currMining.totalValue.add(dnftNum);
        uint256 useTime = timeNum.mul(mintTimeInterval);
        detail.currMining.withdrawTime = detail.currMining.withdrawTime.add(useTime);
        detail.totalTime = detail.totalTime.add(useTime);
        IERC20Token(dnftTokenAddr).transfer(player, dnftNum);
        return (dnftNum, timeNum);
    }


    function getDNFTPrice() external view returns (uint256){
        return _getDNFTPrice();
    }

    function tokensOfOwner(address owner) external view returns (Lib.ProductTokenDetail[] memory){
        EnumerableSet.UintSet storage mintTokens = _tokenMints[owner];
        uint holdLength = balanceOf(owner);
        uint tokenLengthSize = mintTokens.length() + holdLength;
        if (tokenLengthSize == 0) {
            Lib.ProductTokenDetail[] memory zt = new Lib.ProductTokenDetail[](0);
            return zt;
        }
        Lib.ProductTokenDetail[] memory tokens = new Lib.ProductTokenDetail[](tokenLengthSize);
        uint i = 0;
        while (i < mintTokens.length()) {
            tokens[i] = _tokenDetails[mintTokens.at(i)];
            i++;
        }
        uint j = 0;
        while (j < holdLength) {
            tokens[i] = _tokenDetails[tokenOfOwnerByIndex(owner, j)];
            i++;
            j++;
        }
        return tokens;
    }

    function tokenDetailOf(uint256 tid) external view returns (Lib.ProductTokenDetail memory){
        return _tokenDetails[tid];
    }

    function tokenMintHistoryOf(uint256 tid) external view returns (Lib.ProductMintItem[] memory){
        return _tokenMintHistories[tid];
    }


    function withdrawToken(address payable to, address token, uint256 value) onlyMain external {
        if (token == address(0))
            to.transfer(value);
        else
            IERC20(token).safeTransfer(to, value);
    }

    function buy(address to) external onlyMain returns (uint256) {
        require(_tokenIds.current() < maxTokenSize, "product not enough");
        _tokenIds.increment();
        uint256 tid = pid * 1E6 + _tokenIds.current();
        Lib.ProductTokenDetail memory detail;
        detail.id = tid;
        detail.propA = Lib.random(0, 10000);
        detail.propB = Lib.random(0, 10000);
        detail.propC = Lib.random(0, 10000);
        _tokenDetails[tid] = detail;
        _safeMint(to, tid);
        _setTokenURI(tid, Strings.toString(tid));
        return tid;
    }


    function mintBegin(address from, uint256 tokenId) external onlyMain {
        require(_isApprovedOrOwner(from, tokenId), "ERC721: transfer caller is not owner nor approved");
        Lib.ProductTokenDetail storage detail = _tokenDetails[tokenId];
        require(detail.mining == false, "Token already mining.");
        require(detail.totalTime < maxMintTime, "Token already dead.");
        detail.mining = true;
        detail.currMining.minter = from;
        detail.currMining.beginTime = block.timestamp;
        detail.currMining.endTime = 0;
        detail.currMining.withdrawTime = detail.currMining.beginTime;
        _tokenMints[from].add(tokenId);
        _transfer(from, address(this), tokenId);
    }


    function canWithdrawValue(uint256 tokenId) external view returns (uint256 timeNum, uint256 dnftNum){
        return _canWithdrawValue(tokenId);
    }

    function mintWithdraw(address from, uint256 tokenId) external onlyMain returns (uint256, uint256) {
        _onlyMinter(from, tokenId);
        return _mintWithdraw(from, tokenId);
    }

    function redeem(address from, uint256 tokenId) external onlyMain returns (uint256, uint256){
        _onlyMinter(from, tokenId);
        (uint256 withdrawNum,uint256 timeNum) = _mintWithdraw(from, tokenId);

        Lib.ProductTokenDetail storage detail = _tokenDetails[tokenId];
        detail.mining = false;
        detail.currMining.endTime = block.timestamp;
        _tokenMintHistories[tokenId].push(detail.currMining);

        _tokenMints[from].remove(tokenId);
        Lib.ProductMintItem memory currItem;
        detail.currMining = currItem;

        _safeTransfer(address(this), from, tokenId, "");
        return (withdrawNum, timeNum);
    }

}// MIT

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}// MIT




contract ERC20Token is ERC20 {
    constructor(string memory name, string memory symbol, uint8 decimal, uint256 initialBalance) ERC20(name, symbol) {
        _setupDecimals(decimal);
        _mint(msg.sender, initialBalance);
    }
}