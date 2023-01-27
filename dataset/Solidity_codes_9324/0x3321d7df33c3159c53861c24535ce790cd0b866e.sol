


pragma solidity ^0.6.0;

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
}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.2;

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
}



pragma solidity ^0.6.0;




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
}



pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.6.2;


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



pragma solidity ^0.6.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}



pragma solidity ^0.6.0;


contract ERC721Holder is IERC721Receiver {


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}



pragma solidity ^0.6.0;


contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
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
}



pragma solidity ^0.6.0;

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
}



pragma solidity >=0.6.0;

library EnumerableMap {

    struct MapEntry {
        uint256 _key;
        uint256 _value;
    }

    struct Map {
        MapEntry[] _entries;
        mapping(uint256 => uint256) _indexes;
    }

    function _set(
        Map storage map,
        uint256 key,
        uint256 value
    ) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) {
            map._entries.push(MapEntry({_key: key, _value: value}));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, uint256 key) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) {

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

    function _contains(Map storage map, uint256 key) private view returns (bool) {

        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (uint256, uint256) {

        require(map._entries.length > index, 'EnumerableMap: index out of bounds');

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _get(Map storage map, uint256 key) private view returns (uint256) {

        return _get(map, key, 'EnumerableMap: nonexistent key');
    }

    function _get(
        Map storage map,
        uint256 key,
        string memory errorMessage
    ) private view returns (uint256) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToUintMap {
        Map _inner;
    }

    function set(
        UintToUintMap storage map,
        uint256 key,
        uint256 value
    ) internal returns (bool) {

        return _set(map._inner, key, value);
    }

    function remove(UintToUintMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, key);
    }

    function contains(UintToUintMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, key);
    }

    function length(UintToUintMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToUintMap storage map, uint256 index) internal view returns (uint256, uint256) {

        return _at(map._inner, index);
    }

    function get(UintToUintMap storage map, uint256 key) internal view returns (uint256) {

        return _get(map._inner, key);
    }

    function get(
        UintToUintMap storage map,
        uint256 key,
        string memory errorMessage
    ) internal view returns (uint256) {

        return _get(map._inner, key, errorMessage);
    }
}


pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;











contract ExchangeNFT is ERC721Holder, Ownable, Pausable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    using EnumerableMap for EnumerableMap.UintToUintMap;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public MAX_TRADABLE_TOKEN_ID = 100000000;
    uint256 public DIVIDER = 1000;
    uint256 private fee_rate = 25;
    IERC721 public nft;
    IERC20 public quoteErc20;
    address payable public operator;
    address payable public admin_fee;
    EnumerableSet.AddressSet private _operators;
    EnumerableMap.UintToUintMap private _asksMap;
    EnumerableMap.UintToUintMap private _asksMapErc20;
    mapping(uint256 => address) private _tokenSellers;
    mapping(address => EnumerableSet.UintSet) private _userSellingTokens;
    EnumerableMap.UintToUintMap private _initialPricesMap; //作品起拍价
    EnumerableMap.UintToUintMap private _deadlineMap; //作品竞价时间
    EnumerableMap.UintToUintMap private _initialPricesMapErc20; //作品起拍价
    EnumerableMap.UintToUintMap private _deadlineMapErc20; //作品竞价时间
    mapping(uint256 => mapping(address=>uint256)) private _tokenBidOffers;//竞价Map
    mapping(uint256 => EnumerableSet.AddressSet) private _tokenAddressOfferSet; //竞价的地址集合;

    event OneTimeOfferTrade(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 price);
    event OneTimeOfferTradeERC20(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 price);
    event DueTrade(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 price);
    event DueTradeERC20(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 price);
    event AskETH(address indexed seller, uint256 indexed tokenId, uint256 price);
    event AskERC20(address indexed seller, uint256 indexed tokenId, uint256 price);
    event CancelSellTokenETH(address indexed seller, uint256 indexed tokenId);
    event CancelSellTokenERC20(address indexed seller, uint256 indexed tokenId);
    event NewAuctionETH(address indexed seller, uint256 indexed tokenId, uint256 price);
    event NewAuctionERC20(address indexed seller, uint256 indexed tokenId, uint256 price);
    event NewOfferETH(address indexed buyer, uint256 indexed tokenId, uint256 price);
    event NewOfferERC20(address indexed buyer, uint256 indexed tokenId, uint256 price);
    event DistributeNFT(address indexed buyer, uint256 indexed tokenId, uint256 price);
    event DistributeNFTERC20(address indexed buyer, uint256 indexed tokenId, uint256 price);
    event UpdateMaxTradableTokenId(uint256 indexed oldId, uint256 newId);

    constructor(address _nftAddress, address _quoteErc20Address) public {
        require(_nftAddress != address(0) && _nftAddress != address(this));
        require(_quoteErc20Address != address(0) && _quoteErc20Address != address(this));
        nft = IERC721(_nftAddress);
        quoteErc20 = IERC20(_quoteErc20Address);
	operator = msg.sender;
	admin_fee = msg.sender;
	EnumerableSet.add(_operators, operator);
    }

    function buyTokenByETH(uint256 _tokenId) public payable whenNotPaused {

        require(msg.sender != address(0) && msg.sender != address(this), 'Wrong msg sender');
        require(_asksMap.contains(_tokenId), 'Token not in sell book');
        uint256 price = _asksMap.get(_tokenId);
	require(msg.value >= price, "Bigger than price");

	admin_fee.transfer(price.mul(fee_rate).div(DIVIDER));
	payable(_tokenSellers[_tokenId]).transfer(price.mul(DIVIDER.sub(fee_rate)).div(DIVIDER));

        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        _asksMap.remove(_tokenId);
        _userSellingTokens[_tokenSellers[_tokenId]].remove(_tokenId);
        emit OneTimeOfferTrade(_tokenSellers[_tokenId], msg.sender, _tokenId, price);
        delete _tokenSellers[_tokenId];
    }
    function buyTokenByErc20(uint256 _tokenId) public whenNotPaused {

        require(msg.sender != address(0) && msg.sender != address(this), 'Wrong msg sender');
        require(_asksMapErc20.contains(_tokenId), 'Token not in sell book');
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        uint256 price = _asksMap.get(_tokenId);

        quoteErc20.safeTransferFrom(msg.sender, admin_fee, price.mul(fee_rate.div(DIVIDER)));
        quoteErc20.safeTransferFrom(msg.sender, _tokenSellers[_tokenId], price.mul(DIVIDER.sub(fee_rate).div(DIVIDER)));

        _asksMapErc20.remove(_tokenId);
        _userSellingTokens[_tokenSellers[_tokenId]].remove(_tokenId);
        emit OneTimeOfferTradeERC20(_tokenSellers[_tokenId], msg.sender, _tokenId, price);
        delete _tokenSellers[_tokenId];
    }

    function setCurrentPriceETH(uint256 _tokenId, uint256 _price) public whenNotPaused {

        require(_userSellingTokens[msg.sender].contains(_tokenId), 'Only Seller can update price');
        require(_price > 0, 'Price must be granter than zero');
        _asksMap.set(_tokenId, _price);
        emit AskETH(msg.sender, _tokenId, _price);
    }
    function setCurrentPriceErc20(uint256 _tokenId, uint256 _price) public whenNotPaused {

        require(_userSellingTokens[msg.sender].contains(_tokenId), 'Only Seller can update price');
        require(_price > 0, 'Price must be granter than zero');
        _asksMapErc20.set(_tokenId, _price);
        emit AskERC20(msg.sender, _tokenId, _price);
    }

    function readyToSellTokenETH(uint256 _tokenId, uint256 _price) public whenNotPaused {

        require(msg.sender == nft.ownerOf(_tokenId), 'Only Token Owner can sell token');
        require(_price > 0, 'Price must be granter than zero');
        require(_tokenId <= MAX_TRADABLE_TOKEN_ID, 'TokenId must be less than MAX_TRADABLE_TOKEN_ID');
        nft.safeTransferFrom(address(msg.sender), address(this), _tokenId);
        _asksMap.set(_tokenId, _price);
        _tokenSellers[_tokenId] = address(msg.sender);
        _userSellingTokens[msg.sender].add(_tokenId);
        emit AskETH(msg.sender, _tokenId, _price);
    }
    function readyToSellTokenERC20(uint256 _tokenId, uint256 _price) public whenNotPaused {

        require(msg.sender == nft.ownerOf(_tokenId), 'Only Token Owner can sell token');
        require(_price > 0, 'Price must be granter than zero');
        require(_tokenId <= MAX_TRADABLE_TOKEN_ID, 'TokenId must be less than MAX_TRADABLE_TOKEN_ID');
        nft.safeTransferFrom(address(msg.sender), address(this), _tokenId);
        _asksMapErc20.set(_tokenId, _price);
        _tokenSellers[_tokenId] = address(msg.sender);
        _userSellingTokens[msg.sender].add(_tokenId);
        emit AskERC20(msg.sender, _tokenId, _price);
    }

    function cancelSellTokenETH(uint256 _tokenId) public whenNotPaused {

        require(_userSellingTokens[msg.sender].contains(_tokenId), 'Only Seller can cancel sell token');
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        _asksMap.remove(_tokenId);
        _userSellingTokens[_tokenSellers[_tokenId]].remove(_tokenId);
        delete _tokenSellers[_tokenId];
        emit CancelSellTokenETH(msg.sender, _tokenId);
    }
    function cancelSellTokenERC20(uint256 _tokenId) public whenNotPaused {

        require(_userSellingTokens[msg.sender].contains(_tokenId), 'Only Seller can cancel sell token');
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        _asksMapErc20.remove(_tokenId);
        _userSellingTokens[_tokenSellers[_tokenId]].remove(_tokenId);
        delete _tokenSellers[_tokenId];
        emit CancelSellTokenERC20(msg.sender, _tokenId);
    }

    function getAskEthLength() public view returns (uint256) {

        return _asksMap.length();
    }
    function getAskERC20Length() public view returns (uint256) {

        return _asksMapErc20.length();
    }

    function readyToAuctionTokenETH(uint256 _tokenId, uint256 _price, uint256 deadline) public payable whenNotPaused {

        require(msg.sender == nft.ownerOf(_tokenId), 'Only Token Owner can sell token');
        require(_price > 0, 'Price must be granter than zero');
        require(_tokenId <= MAX_TRADABLE_TOKEN_ID, 'TokenId must be less than MAX_TRADABLE_TOKEN_ID');
        require(msg.value>1e15, "Gas fee for operator.");
	operator.transfer(msg.value);
        nft.safeTransferFrom(address(msg.sender), address(this), _tokenId);
        _initialPricesMap.set(_tokenId, _price);
	uint256 ts = block.timestamp.add(deadline);
	_deadlineMap.set(_tokenId, ts);
        _tokenSellers[_tokenId] = address(msg.sender);
        _userSellingTokens[msg.sender].add(_tokenId);
        emit NewAuctionETH(msg.sender, _tokenId, _price);
    }
    function readyToAuctionTokenERC20(uint256 _tokenId, uint256 _price, uint256 deadline) public payable whenNotPaused {

        require(msg.sender == nft.ownerOf(_tokenId), 'Only Token Owner can sell token');
        require(_price > 0, 'Price must be granter than zero');
        require(_tokenId <= MAX_TRADABLE_TOKEN_ID, 'TokenId must be less than MAX_TRADABLE_TOKEN_ID');
        require(msg.value>1e15, "Gas fee for operator.");
	operator.transfer(msg.value);
        nft.safeTransferFrom(address(msg.sender), address(this), _tokenId);
        _initialPricesMapErc20.set(_tokenId, _price);
	uint256 ts = block.timestamp.add(deadline);
	_deadlineMapErc20.set(_tokenId, ts);
        _tokenSellers[_tokenId] = address(msg.sender);
        _userSellingTokens[msg.sender].add(_tokenId);
        emit NewAuctionETH(msg.sender, _tokenId, _price);
    }
   
     function makeOfferETH(uint256 _tokenId) external payable  returns (bool){

 
         require(_initialPricesMap.contains(_tokenId), 'Token not in sell book');

	 require(block.timestamp < getDeadlineETH(_tokenId), 'Auction is out-dated');
 
	 _tokenBidOffers[_tokenId][msg.sender] = _tokenBidOffers[_tokenId][msg.sender].add(msg.value); 

	 if(!_tokenAddressOfferSet[_tokenId].contains(msg.sender))
		_tokenAddressOfferSet[_tokenId].add(msg.sender);

         emit NewOfferETH(msg.sender, _tokenId, msg.value);
 
         return true;
     }
     function makeOfferERC20(uint256 _tokenId) external payable  returns (bool){

 
         require(_initialPricesMapErc20.contains(_tokenId), 'Token not in sell book');

	 require(block.timestamp < getDeadlineErc20(_tokenId), 'Auction is out-dated');
 
	 _tokenBidOffers[_tokenId][msg.sender] = _tokenBidOffers[_tokenId][msg.sender].add(msg.value); 

	 if(!_tokenAddressOfferSet[_tokenId].contains(msg.sender))
		_tokenAddressOfferSet[_tokenId].add(msg.sender);

         emit NewOfferERC20(msg.sender, _tokenId, msg.value);
 
         return true;
     }
     function getMyOfferPrice(uint256 _tokenId, address account) public view returns (uint256) {

         return _tokenBidOffers[_tokenId][account];
     }

    function pause() public onlyOwner whenNotPaused {

        _pause();
    }

    function unpause() public onlyOwner whenPaused {

        _unpause();
    }
     function getInitialPriceETH(uint256 _tokenId) public view returns (uint256)
    {

	return _initialPricesMap.get(_tokenId);
    }
     function getInitialPriceERC20(uint256 _tokenId) public view returns (uint256)
    {

	return _initialPricesMapErc20.get(_tokenId);
    }
     function getDeadlineETH(uint256 _tokenId) public view returns (uint256)
    {

	return _deadlineMap.get(_tokenId);
    }
     function getDeadlineErc20(uint256 _tokenId) public view returns (uint256)
    {

	return _deadlineMapErc20.get(_tokenId);
    }
	
    function updateMaxTradableTokenId(uint256 _max_tradable_token_id) public onlyOwner {

        emit UpdateMaxTradableTokenId(MAX_TRADABLE_TOKEN_ID, _max_tradable_token_id);
        MAX_TRADABLE_TOKEN_ID = _max_tradable_token_id;
    }

    function updateNFTContract(address _nftAddress) public onlyOwner {

	require(_nftAddress != address(0) && _nftAddress != address(this));
        nft = IERC721(_nftAddress);
    }
    function updateQuoteErc20(address _quoteErc20Address) public onlyOwner {

	require(_quoteErc20Address != address(0) && _quoteErc20Address != address(this));
        quoteErc20 = IERC20(_quoteErc20Address);
    }
    function updateOperator(address payable _operatorAddress) public onlyOwner {

	require(_operatorAddress!= address(0) && _operatorAddress != address(this));
        operator = _operatorAddress;
    }
    function updateAdminFee(address payable _adminFeeAddress) public onlyOwner {

	require(_adminFeeAddress!= address(0) && _adminFeeAddress != address(this));
	admin_fee = _adminFeeAddress;
    }
    function updateFeeRate(uint256 _feeRate) public onlyOwner {

	fee_rate = _feeRate;
    }

     function emergencyWithdraw() onlyOwner public {

         uint256 eth_amount = address(this).balance;
         uint256 erc20_amount = quoteErc20.balanceOf(address(this));
         if(eth_amount > 0)
                 msg.sender.transfer(eth_amount);
         if(erc20_amount > 0)
                 quoteErc20.transfer(msg.sender, erc20_amount);
     }

     function distributeNFT(address _receiver, uint256 _tokenId, uint256 _price) external onlyOperator returns (bool){

 
         require(_receiver != address(0), "Invalid receiver address");
         require(_initialPricesMap.contains(_tokenId), 'Token not in sell book');
         require(_price>0, "Invalid price");
 
         nft.safeTransferFrom(address(this), _receiver, _tokenId);

	 address payable seller = payable(_tokenSellers[_tokenId]);
	admin_fee.transfer(_price.mul(fee_rate).div(DIVIDER));
	seller.transfer(_price.mul(DIVIDER.sub(fee_rate)).div(DIVIDER));
 
        for (uint256 i = 0; i < _tokenAddressOfferSet[_tokenId].length(); ++i) {
            address payable account = payable(_tokenAddressOfferSet[_tokenId].at(i));
	    if(address(account) == _receiver)
		continue;
            uint256 price = _tokenBidOffers[_tokenId][account];
	    account.transfer(price); //退款
	    delete _tokenBidOffers[_tokenId][account];
        }

        _userSellingTokens[_tokenSellers[_tokenId]].remove(_tokenId);
        emit DistributeNFT(_receiver, _tokenId, _price);
        emit DueTrade(_tokenSellers[_tokenId], _receiver, _tokenId, _price);
        delete _tokenSellers[_tokenId];
        _initialPricesMap.remove(_tokenId);
        _deadlineMap.remove(_tokenId);
        delete _tokenAddressOfferSet[_tokenId];
 
        return true;
     }
     function distributeNFTERC20(address _receiver, uint256 _tokenId, uint256 _price) external onlyOperator returns (bool){

 
         require(_receiver != address(0), "Invalid receiver address");
         require(_initialPricesMapErc20.contains(_tokenId), 'Token not in sell book');
         require(_price>0, "Invalid price");
 
         nft.safeTransferFrom(address(this), _receiver, _tokenId);

         quoteErc20.safeTransferFrom(address(this), admin_fee, _price.mul(fee_rate.div(DIVIDER)));
         quoteErc20.safeTransferFrom(address(this), _tokenSellers[_tokenId], _price.mul(DIVIDER.sub(fee_rate).div(DIVIDER)));
 
        for (uint256 i = 0; i < _tokenAddressOfferSet[_tokenId].length(); ++i) {
            address account = _tokenAddressOfferSet[_tokenId].at(i);
	    if(account == _receiver)
		continue;
            uint256 price = _tokenBidOffers[_tokenId][account];
	    quoteErc20.safeTransferFrom(address(this), account, price);
	    delete _tokenBidOffers[_tokenId][account];
        }

        _userSellingTokens[_tokenSellers[_tokenId]].remove(_tokenId);
        emit DistributeNFTERC20(_receiver, _tokenId, _price);
        emit DueTradeERC20(_tokenSellers[_tokenId], _receiver, _tokenId, _price);
        delete _tokenSellers[_tokenId];
        _initialPricesMapErc20.remove(_tokenId);
        _deadlineMapErc20.remove(_tokenId);
        delete _tokenAddressOfferSet[_tokenId];
 
        return true;
     }


     function addOperator(address payable _addOperator) public onlyOwner returns (bool) {

         require(_addOperator != address(0), "_addOperator is the zero address");
	 operator = _addOperator;
         return EnumerableSet.add(_operators, _addOperator);
     }
 
     function delOperator(address _delOperator) public onlyOwner returns (bool) {

         require(_delOperator != address(0), "_delOperator is the zero address");
         return EnumerableSet.remove(_operators, _delOperator);
     }
 
     function getOperatorLength() public view returns (uint256) {

         return EnumerableSet.length(_operators);
     }
 
     function isOperator(address account) public view returns (bool) {

         return EnumerableSet.contains(_operators, account);
     }
 
     function getOperator(uint256 _index) public view onlyOwner returns (address){

         require(_index <= getOperatorLength() - 1, "index out of bounds");
         return EnumerableSet.at(_operators, _index);
     }
 
     modifier onlyOperator() {

         require(isOperator(msg.sender), "caller is not the operator");
         _;
     }
}