


pragma solidity >=0.6.2 <0.8.0;

interface IHashmask {

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


    function tokenNameByIndex(uint256 index) external view returns (string memory);


    function toLower(string calldata str) external pure returns (string memory);


    function changeName(uint256 tokenId, string calldata newName) external;

}



pragma solidity >=0.6.0 <0.8.0;

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



pragma solidity >=0.6.0 <0.8.0;

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
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}



pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;






contract HashmaskSwapper is ReentrancyGuard {


  using EnumerableMap for EnumerableMap.UintToAddressMap;
  using SafeMath for uint256;

  struct NameSwap {
    string name1;
    string name2;
    address token;
    uint256 price;
    uint256 escrowedNCTAmount;
  }

  IHashmask public hashmask;
  IERC20 public nct;

  uint256 public constant MODIFIED_NAME_CHANGE_PRICE = 2745 * (10 ** 18);

  uint256 public constant NAME_CHANGE_PRICE = 1830 * (10**18);

  address public constant XMON_DEPLOYER =  0x75d4bdBf6593ed463e9625694272a0FF9a6D346F;
  uint256 public constant BASE = 100;
  uint256 public constant PAID_AMOUNT = 99;
  uint256 public constant FEE_AMOUNT = 1;

  EnumerableMap.UintToAddressMap private originalOwner;
  mapping(uint256 => NameSwap) public swapRecords;

  constructor(address mask, address token) public {
    hashmask = IHashmask(mask);
    nct = IERC20(token);

    nct.approve(address(hashmask), uint256(-1));
  }

  function createSwap(uint256 id, string memory desiredName, address token, uint256 price, uint256 transferAmount) private nonReentrant {

    require(hashmask.ownerOf(id) == msg.sender, "Not owner");

    swapRecords[id] = NameSwap(
      hashmask.tokenNameByIndex(id),
      desiredName,
      token,
      price,
      transferAmount
    );

    originalOwner.set(id, msg.sender);

    hashmask.transferFrom(msg.sender, address(this), id);

    nct.transferFrom(msg.sender, address(this), transferAmount);
  }

  function setNameSwap(uint256 id, string calldata desiredName) external {


    createSwap(id, desiredName, address(0), 0, MODIFIED_NAME_CHANGE_PRICE);
  }

  function setNameSale(uint256 id, address token, uint256 price) external {

    createSwap(id, "", token, price, NAME_CHANGE_PRICE);
  }

  function removeSwap(uint256 id) external nonReentrant {


    require(msg.sender == originalOwner.get(id), "Not owner");

    uint256 transferAmount = swapRecords[id].escrowedNCTAmount;

    originalOwner.remove(id);
    delete swapRecords[id];

    hashmask.transferFrom(address(this), msg.sender, id);

    nct.transfer(msg.sender, transferAmount);
  }

  function takeSell(uint256 swapId, uint256 takerId, string calldata placeholder1) external nonReentrant {

    NameSwap memory nameSwapPair = swapRecords[swapId];

    require((bytes(nameSwapPair.name2).length == 0), "Not sell swap");

    IERC20 token = IERC20(nameSwapPair.token);
    (, address swapProposer) = originalOwner.at(swapId);
    uint256 tokensToSeller = nameSwapPair.price.mul(PAID_AMOUNT).div(BASE);
    token.transferFrom(msg.sender, swapProposer, tokensToSeller);

    uint256 tokenFee = nameSwapPair.price.mul(FEE_AMOUNT).div(BASE);
    token.transferFrom(msg.sender, XMON_DEPLOYER, tokenFee);

    hashmask.transferFrom(msg.sender, address(this), takerId);

    nct.transferFrom(msg.sender, address(this), NAME_CHANGE_PRICE);

    hashmask.changeName(swapId, placeholder1);

    hashmask.changeName(takerId, nameSwapPair.name1);

    address otherOwner = originalOwner.get(swapId);

    originalOwner.remove(swapId);
    delete swapRecords[swapId];

    hashmask.transferFrom(address(this), msg.sender, takerId);
    hashmask.transferFrom(address(this), otherOwner, swapId);
  }

  function takeSwap(uint256 swapId, uint256 takerId, string calldata placeholder1) external nonReentrant {

    NameSwap memory nameSwapPair = swapRecords[swapId];

    require(sha256(bytes(hashmask.toLower(hashmask.tokenNameByIndex(takerId)))) ==
    sha256(bytes(hashmask.toLower(nameSwapPair.name2))), "Not desired name");

    hashmask.transferFrom(msg.sender, address(this), takerId);

    nct.transferFrom(msg.sender, address(this), MODIFIED_NAME_CHANGE_PRICE);

    hashmask.changeName(swapId, placeholder1);

    hashmask.changeName(takerId, nameSwapPair.name1);

    hashmask.changeName(swapId, nameSwapPair.name2);

    address otherOwner = originalOwner.get(swapId);

    originalOwner.remove(swapId);
    delete swapRecords[swapId];

    hashmask.transferFrom(address(this), msg.sender, takerId);
    hashmask.transferFrom(address(this), otherOwner, swapId);
  }

  function doubleNameSwap(uint256 id, string calldata tempName, string calldata finalName) external nonReentrant {


    hashmask.transferFrom(msg.sender, address(this), id);

    nct.transferFrom(msg.sender, address(this), NAME_CHANGE_PRICE.mul(2));

    hashmask.changeName(id, tempName);

    hashmask.changeName(id, finalName);

    hashmask.transferFrom(address(this), msg.sender, id);
  }

  function getAllOpenSwaps(bool getSwap) public view returns(int128[] memory) {

    uint256 len = originalOwner.length();
    int128[] memory swapList = new int128[](len);
    for (uint256 i = 0; i < len; i++) {
      (uint256 id, ) = originalOwner.at(i);
      NameSwap memory currSwap = swapRecords[id];

      if (getSwap) {
        if (currSwap.token == address(0)) {
          swapList[i] = int128(id);
        }
        else {
          swapList[i] = -1;
        }
      }

      else {
        if (currSwap.token != address(0)) {
          swapList[i] = int128(id);
        }
        else {
          swapList[i] = -1;
        }
      }
    }
    return(swapList);
  }

  function getAllOpenSalesAndSwaps() public view returns(uint256[] memory) {

    uint256 len = originalOwner.length();
    uint256[] memory swapList = new uint256[](len);
    for (uint256 i = 0; i < len; i++) {
      (uint256 id, ) = originalOwner.at(i);
      swapList[i] = id;
    }
    return(swapList);
  }
}