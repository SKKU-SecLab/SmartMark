



pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}




pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}




pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}




pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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




pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}




pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}




pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}




pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;









contract ERC721A is
  Context,
  ERC165,
  IERC721,
  IERC721Metadata,
  IERC721Enumerable
{

  using Address for address;
  using Strings for uint256;

  struct TokenOwnership {
    address addr;
    uint64 startTimestamp;
  }

  struct AddressData {
    uint128 balance;
    uint128 numberMinted;
  }

  uint256 private currentIndex = 0;

  uint256 internal immutable maxBatchSize;

  string private _name;

  string private _symbol;

  mapping(uint256 => TokenOwnership) private _ownerships;

  mapping(address => AddressData) private _addressData;

  mapping(uint256 => address) private _tokenApprovals;

  mapping(address => mapping(address => bool)) private _operatorApprovals;

  constructor(
    string memory name_,
    string memory symbol_,
    uint256 maxBatchSize_
  ) {
    require(maxBatchSize_ > 0, "ERC721A: max batch size must be nonzero");
    _name = name_;
    _symbol = symbol_;
    maxBatchSize = maxBatchSize_;
  }

  function totalSupply() public view override returns (uint256) {

    return currentIndex;
  }

  function tokenByIndex(uint256 index) public view override returns (uint256) {

    require(index < totalSupply(), "ERC721A: global index out of bounds");
    return index;
  }

  function tokenOfOwnerByIndex(address owner, uint256 index)
    public
    view
    override
    returns (uint256)
  {

    require(index < balanceOf(owner), "ERC721A: owner index out of bounds");
    uint256 numMintedSoFar = totalSupply();
    uint256 tokenIdsIdx = 0;
    address currOwnershipAddr = address(0);
    for (uint256 i = 0; i < numMintedSoFar; i++) {
      TokenOwnership memory ownership = _ownerships[i];
      if (ownership.addr != address(0)) {
        currOwnershipAddr = ownership.addr;
      }
      if (currOwnershipAddr == owner) {
        if (tokenIdsIdx == index) {
          return i;
        }
        tokenIdsIdx++;
      }
    }
    revert("ERC721A: unable to get token of owner by index");
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC165, IERC165)
    returns (bool)
  {

    return
      interfaceId == type(IERC721).interfaceId ||
      interfaceId == type(IERC721Metadata).interfaceId ||
      interfaceId == type(IERC721Enumerable).interfaceId ||
      super.supportsInterface(interfaceId);
  }

  function balanceOf(address owner) public view override returns (uint256) {

    require(owner != address(0), "ERC721A: balance query for the zero address");
    return uint256(_addressData[owner].balance);
  }

  function _numberMinted(address owner) internal view returns (uint256) {

    require(
      owner != address(0),
      "ERC721A: number minted query for the zero address"
    );
    return uint256(_addressData[owner].numberMinted);
  }

  function ownershipOf(uint256 tokenId)
    internal
    view
    returns (TokenOwnership memory)
  {

    require(_exists(tokenId), "ERC721A: owner query for nonexistent token");

    uint256 lowestTokenToCheck;
    if (tokenId >= maxBatchSize) {
      lowestTokenToCheck = tokenId - maxBatchSize + 1;
    }

    for (uint256 curr = tokenId; curr >= lowestTokenToCheck; curr--) {
      TokenOwnership memory ownership = _ownerships[curr];
      if (ownership.addr != address(0)) {
        return ownership;
      }
    }

    revert("ERC721A: unable to determine the owner of token");
  }

  function ownerOf(uint256 tokenId) public view override returns (address) {

    return ownershipOf(tokenId).addr;
  }

  function name() public view virtual override returns (string memory) {

    return _name;
  }

  function symbol() public view virtual override returns (string memory) {

    return _symbol;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {

    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory baseURI = _baseURI();
    return
      bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString()))
        : "";
  }

  function _baseURI() internal view virtual returns (string memory) {

    return "";
  }

  function approve(address to, uint256 tokenId) public override {

    address owner = ERC721A.ownerOf(tokenId);
    require(to != owner, "ERC721A: approval to current owner");

    require(
      _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
      "ERC721A: approve caller is not owner nor approved for all"
    );

    _approve(to, tokenId, owner);
  }

  function getApproved(uint256 tokenId) public view override returns (address) {

    require(_exists(tokenId), "ERC721A: approved query for nonexistent token");

    return _tokenApprovals[tokenId];
  }

  function setApprovalForAll(address operator, bool approved) public override {

    require(operator != _msgSender(), "ERC721A: approve to caller");

    _operatorApprovals[_msgSender()][operator] = approved;
    emit ApprovalForAll(_msgSender(), operator, approved);
  }

  function isApprovedForAll(address owner, address operator)
    public
    view
    virtual
    override
    returns (bool)
  {

    return _operatorApprovals[owner][operator];
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override {

    _transfer(from, to, tokenId);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public virtual override {

    safeTransferFrom(from, to, tokenId, "");
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) public virtual override {

    _transfer(from, to, tokenId);
    require(
      _checkOnERC721Received(from, to, tokenId, _data),
      "ERC721A: transfer to non ERC721Receiver implementer"
    );
  }

  function _exists(uint256 tokenId) internal view returns (bool) {

    return tokenId < currentIndex;
  }

  function _safeMint(address to, uint256 quantity) internal {

    _safeMint(to, quantity, "");
  }

  function _safeMint(
    address to,
    uint256 quantity,
    bytes memory _data
  ) internal virtual {

    uint256 startTokenId = currentIndex;
    require(to != address(0), "ERC721A: mint to the zero address");
    require(!_exists(startTokenId), "ERC721A: token already minted");
    require(quantity <= maxBatchSize, "ERC721A: quantity to mint too high");

    _beforeTokenTransfers(address(0), to, startTokenId, quantity);

    AddressData memory addressData = _addressData[to];
    _addressData[to] = AddressData(
      addressData.balance + uint128(quantity),
      addressData.numberMinted + uint128(quantity)
    );
    _ownerships[startTokenId] = TokenOwnership(to, uint64(block.timestamp));

    uint256 updatedIndex = startTokenId;

    for (uint256 i = 0; i < quantity; i++) {
      emit Transfer(address(0), to, updatedIndex);
      require(
        _checkOnERC721Received(address(0), to, updatedIndex, _data),
        "ERC721A: transfer to non ERC721Receiver implementer"
      );
      updatedIndex++;
    }

    currentIndex = updatedIndex;
    _afterTokenTransfers(address(0), to, startTokenId, quantity);
  }

  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) private {

    TokenOwnership memory prevOwnership = ownershipOf(tokenId);

    bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
      getApproved(tokenId) == _msgSender() ||
      isApprovedForAll(prevOwnership.addr, _msgSender()));

    require(
      isApprovedOrOwner,
      "ERC721A: transfer caller is not owner nor approved"
    );

    require(
      prevOwnership.addr == from,
      "ERC721A: transfer from incorrect owner"
    );
    require(to != address(0), "ERC721A: transfer to the zero address");

    _beforeTokenTransfers(from, to, tokenId, 1);

    _approve(address(0), tokenId, prevOwnership.addr);

    _addressData[from].balance -= 1;
    _addressData[to].balance += 1;
    _ownerships[tokenId] = TokenOwnership(to, uint64(block.timestamp));

    uint256 nextTokenId = tokenId + 1;
    if (_ownerships[nextTokenId].addr == address(0)) {
      if (_exists(nextTokenId)) {
        _ownerships[nextTokenId] = TokenOwnership(
          prevOwnership.addr,
          prevOwnership.startTimestamp
        );
      }
    }

    emit Transfer(from, to, tokenId);
    _afterTokenTransfers(from, to, tokenId, 1);
  }

  function _approve(
    address to,
    uint256 tokenId,
    address owner
  ) private {

    _tokenApprovals[tokenId] = to;
    emit Approval(owner, to, tokenId);
  }

  uint256 public nextOwnerToExplicitlySet = 0;

  function _setOwnersExplicit(uint256 quantity) internal {

    uint256 oldNextOwnerToSet = nextOwnerToExplicitlySet;
    require(quantity > 0, "quantity must be nonzero");
    uint256 endIndex = oldNextOwnerToSet + quantity - 1;
    if (endIndex > currentIndex - 1) {
      endIndex = currentIndex - 1;
    }
    require(_exists(endIndex), "not enough minted yet for this cleanup");
    for (uint256 i = oldNextOwnerToSet; i <= endIndex; i++) {
      if (_ownerships[i].addr == address(0)) {
        TokenOwnership memory ownership = ownershipOf(i);
        _ownerships[i] = TokenOwnership(
          ownership.addr,
          ownership.startTimestamp
        );
      }
    }
    nextOwnerToExplicitlySet = endIndex + 1;
  }

  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) private returns (bool) {

    if (to.isContract()) {
      try
        IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data)
      returns (bytes4 retval) {
        return retval == IERC721Receiver(to).onERC721Received.selector;
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("ERC721A: transfer to non ERC721Receiver implementer");
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    } else {
      return true;
    }
  }

  function _beforeTokenTransfers(
    address from,
    address to,
    uint256 startTokenId,
    uint256 quantity
  ) internal virtual {}


  function _afterTokenTransfers(
    address from,
    address to,
    uint256 startTokenId,
    uint256 quantity
  ) internal virtual {}

}




pragma solidity ^0.8.0;




contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


pragma solidity 0.8.7;



interface IDuck {
	function balanceOG(address _user) external view returns(uint256);
}

contract CosmicToken is ERC20("CosmicUtilityToken", "CUT") 
{
   
    using SafeMath for uint256;
   
    uint256 public totalTokensBurned = 0;
    address[] internal stakeholders;
    address  payable private owner;
    

    uint256 constant public GENESIS_RATE = 20 ether; 
    
    uint256 constant public DUCK_RATE = 5 ether; 
    
	uint256 constant public GENESIS_ISSUANCE = 280 ether;
	
	uint256 constant public DUCK_ISSUANCE = 70 ether;
	
	
	
	uint256 constant public END = 1931622407;

	mapping(address => uint256) public rewards;
	mapping(address => uint256) public lastUpdate;
	
	
    IDuck public ducksContract;
   
    constructor(address initDuckContract) 
    {
        owner = payable(msg.sender);
        ducksContract = IDuck(initDuckContract);
    }
   

    function WhoOwns() public view returns (address) {
        return owner;
    }
   
    modifier Owned {
         require(msg.sender == owner);
         _;
 }
   
    function getContractAddress() public view returns (address) {
        return address(this);
    }

	function min(uint256 a, uint256 b) internal pure returns (uint256) {
		return a < b ? a : b;
	}    
	
	modifier contractAddressOnly
    {
         require(msg.sender == address(ducksContract));
         _;
    }
    
	function updateRewardOnMint(address _user, uint256 _tokenId) external contractAddressOnly
	{
	    if(_tokenId <= 1000)
		{
            _mint(_user,GENESIS_ISSUANCE);	  	        
		}
		else if(_tokenId >= 1001)
		{
            _mint(_user,DUCK_ISSUANCE);	  	        	        
		}
	}
	

	function getReward(address _to, uint256 totalPayout) external contractAddressOnly
	{
		_mint(_to, (totalPayout * 10 ** 18));
		
	}
	
	function burn(address _from, uint256 _amount) external 
	{
	    require(msg.sender == _from, "You do not own these tokens");
		_burn(_from, _amount);
		totalTokensBurned += _amount;
	}


  
   
}



pragma solidity ^0.8.0;








contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}




pragma solidity ^0.8.0;



abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


pragma solidity 0.8.7;



contract CosmicLabs is ERC721Enumerable, IERC721Receiver, Ownable {
   
   using Strings for uint256;
   using EnumerableSet for EnumerableSet.UintSet;
   
    CosmicToken public cosmictoken;
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    
    string public baseURI;
    string public baseExtension = ".json";

    
    uint public maxGenesisTx = 4;
    uint public maxDuckTx = 20;
    
    
    uint public maxSupply = 9000;
    uint public genesisSupply = 1000;
    
    uint256 public price = 0.05 ether;
   

    bool public GensisSaleOpen = true;
    bool public GenesisFreeMintOpen = false;
    bool public DuckMintOpen = false;
    
    
    
    modifier isSaleOpen
    {
         require(GensisSaleOpen == true);
         _;
    }
    
    modifier isFreeMintOpen
    {
         require(GenesisFreeMintOpen == true);
         _;
    }
    
    modifier isDuckMintOpen
    {
         require(DuckMintOpen == true);
         _;
    }
    

    
    function switchFromFreeToDuckMint() public onlyOwner
    {
        GenesisFreeMintOpen = false;
        DuckMintOpen = true;
    }
    
    
    
    event mint(address to, uint total);
    event withdraw(uint total);
    event giveawayNft(address to, uint tokenID);
    
    mapping(address => uint256) public balanceOG;
    
    mapping(address => uint256) public maxWalletGenesisTX;
    mapping(address => uint256) public maxWalletDuckTX;
    
    mapping(address => EnumerableSet.UintSet) private _deposits;
    
    
    mapping(uint256 => uint256) public _deposit_blocks;
    
    mapping(address => bool) public addressStaked;
    
    mapping(uint256 => uint256) public IDvsDaysStaked;
    mapping (address => uint256) public whitelistMintAmount;
    

   address internal communityWallet = 0xea25545d846ecF4999C2875bC77dE5B5151Fa633;
   
    constructor(string memory _initBaseURI) ERC721("Cosmic Labs", "CLABS")
    {
        setBaseURI(_initBaseURI);
    }
   
   
    function setPrice(uint256 newPrice) external onlyOwner {
        price = newPrice;
    }
   
    
    function setYieldToken(address _yield) external onlyOwner {
		cosmictoken = CosmicToken(_yield);
	}
	
	function totalToken() public view returns (uint256) {
            return _tokenIdTracker.current();
    }
    
    modifier communityWalletOnly
    {
         require(msg.sender == communityWallet);
         _;
    }
    	
	function communityDuckMint(uint256 amountForAirdrops) public onlyOwner
	{
        for(uint256 i; i<amountForAirdrops; i++)
        {
             _tokenIdTracker.increment();
            _safeMint(communityWallet, totalToken());
        }
	}

    function GenesisSale(uint8 mintTotal) public payable isSaleOpen
    {
        uint256 totalMinted = maxWalletGenesisTX[msg.sender];
        totalMinted = totalMinted + mintTotal;
        
        require(mintTotal >= 1 && mintTotal <= maxGenesisTx, "Mint Amount Incorrect");
        require(totalToken() < genesisSupply, "SOLD OUT!");
        require(maxWalletGenesisTX[msg.sender] <= maxGenesisTx, "You've maxed your limit!");
        require(msg.value >= price * mintTotal, "Minting a Genesis Costs 0.05 Ether Each!");
        require(totalMinted <= maxGenesisTx, "You'll surpass your limit!");
        
        
        for(uint8 i=0;i<mintTotal;i++)
        {
            whitelistMintAmount[msg.sender] += 1;
            maxWalletGenesisTX[msg.sender] += 1;
            _tokenIdTracker.increment();
            _safeMint(msg.sender, totalToken());
            cosmictoken.updateRewardOnMint(msg.sender, totalToken());
            emit mint(msg.sender, totalToken());
        }
        
        if(totalToken() == genesisSupply)
        {
            GensisSaleOpen = false;
            GenesisFreeMintOpen = true;
        }
       
    }	

    function GenesisFreeMint(uint8 mintTotal)public payable isFreeMintOpen
    {
        require(whitelistMintAmount[msg.sender] > 0, "You don't have any free mints!");
        require(totalToken() < maxSupply, "SOLD OUT!");
        require(mintTotal <= whitelistMintAmount[msg.sender], "You are passing your limit!");
        
        for(uint8 i=0;i<mintTotal;i++)
        {
            whitelistMintAmount[msg.sender] -= 1;
            _tokenIdTracker.increment();
            _safeMint(msg.sender, totalToken());
            cosmictoken.updateRewardOnMint(msg.sender, totalToken());
            emit mint(msg.sender, totalToken());
        }
    }
	

    function DuckSale(uint8 mintTotal)public payable isDuckMintOpen
    {
        uint256 totalMinted = maxWalletDuckTX[msg.sender];
        totalMinted = totalMinted + mintTotal;        
    
        require(mintTotal >= 1 && mintTotal <= maxDuckTx, "Mint Amount Incorrect");
        require(msg.value >= price * mintTotal, "Minting a Duck Costs 0.05 Ether Each!");
        require(totalToken() < maxSupply, "SOLD OUT!");
        require(maxWalletDuckTX[msg.sender] <= maxDuckTx, "You've maxed your limit!");
        require(totalMinted <= maxDuckTx, "You'll surpass your limit!");
        
        for(uint8 i=0;i<mintTotal;i++)
        {
            maxWalletDuckTX[msg.sender] += 1;
            _tokenIdTracker.increment();
            _safeMint(msg.sender, totalToken());
            cosmictoken.updateRewardOnMint(msg.sender, totalToken());
            emit mint(msg.sender, totalToken());
        }
        
        if(totalToken() == maxSupply)
        {
            DuckMintOpen = false;
        }
    }
   
   
    function airdropNft(address airdropPatricipent, uint16 tokenID) public payable communityWalletOnly
    {
        _transfer(msg.sender, airdropPatricipent, tokenID);
        emit giveawayNft(airdropPatricipent, tokenID);
    }
    
    function airdropMany(address[] memory airdropPatricipents) public payable communityWalletOnly
    {
        uint256[] memory tempWalletOfUser = this.walletOfOwner(msg.sender);
        
        require(tempWalletOfUser.length >= airdropPatricipents.length, "You dont have enough tokens to airdrop all!");
        
       for(uint256 i=0; i<airdropPatricipents.length; i++)
       {
            _transfer(msg.sender, airdropPatricipents[i], tempWalletOfUser[i]);
            emit giveawayNft(airdropPatricipents[i], tempWalletOfUser[i]);
       }

    }    
    
    function withdrawContractEther(address payable recipient) external onlyOwner
    {
        emit withdraw(getBalance());
        recipient.transfer(getBalance());
    }
    function getBalance() public view returns(uint)
    {
        return address(this).balance;
    }
   
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
   
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
   
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) : "";
    }
    
	function getReward(uint256 CalculatedPayout) internal
	{
		cosmictoken.getReward(msg.sender, CalculatedPayout);
	}    
    
    function depositStake(uint256[] calldata tokenIds) external {
        
        require(isApprovedForAll(msg.sender, address(this)), "You are not Approved!");
        
        
        for (uint256 i; i < tokenIds.length; i++) {
            safeTransferFrom(
                msg.sender,
                address(this),
                tokenIds[i],
                ''
            );
            
            _deposits[msg.sender].add(tokenIds[i]);
            addressStaked[msg.sender] = true;
            
            
            _deposit_blocks[tokenIds[i]] = block.timestamp;
            

            IDvsDaysStaked[tokenIds[i]] = block.timestamp;
        }
        
    }
    function withdrawStake(uint256[] calldata tokenIds) external {
        
        require(isApprovedForAll(msg.sender, address(this)), "You are not Approved!");
        
        for (uint256 i; i < tokenIds.length; i++) {
            require(
                _deposits[msg.sender].contains(tokenIds[i]),
                'Token not deposited'
            );
            
            cosmictoken.getReward(msg.sender,totalRewardsToPay(tokenIds[i]));
            
            _deposits[msg.sender].remove(tokenIds[i]);
             _deposit_blocks[tokenIds[i]] = 0;
            addressStaked[msg.sender] = false;
            IDvsDaysStaked[tokenIds[i]] = block.timestamp;
            
            this.safeTransferFrom(
                address(this),
                msg.sender,
                tokenIds[i],
                ''
            );
        }
    }

    
    function viewRewards() external view returns (uint256)
    {
        uint256 payout = 0;
        
        for(uint256 i = 0; i < _deposits[msg.sender].length(); i++)
        {
            payout = payout + totalRewardsToPay(_deposits[msg.sender].at(i));
        }
        return payout;
    }
    
    function claimRewards() external
    {
        for(uint256 i = 0; i < _deposits[msg.sender].length(); i++)
        {
            cosmictoken.getReward(msg.sender, totalRewardsToPay(_deposits[msg.sender].at(i)));
            IDvsDaysStaked[_deposits[msg.sender].at(i)] = block.timestamp;
        }
    }   
    
    function totalRewardsToPay(uint256 tokenId) internal view returns(uint256)
    {
        uint256 payout = 0;
        
        if(tokenId > 0 && tokenId <= genesisSupply)
        {
            payout = howManyDaysStaked(tokenId) * 20;
        }
        else if (tokenId > genesisSupply && tokenId <= maxSupply)
        {
            payout = howManyDaysStaked(tokenId) * 5;
        }
        
        return payout;
    }
    
    function howManyDaysStaked(uint256 tokenId) public view returns(uint256)
    {
        
        require(
            _deposits[msg.sender].contains(tokenId),
            'Token not deposited'
        );
        
        uint256 returndays;
        uint256 timeCalc = block.timestamp - IDvsDaysStaked[tokenId];
        returndays = timeCalc / 86400;
       
        return returndays;
    }
    
    function walletOfOwner(address _owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }
    
    function returnStakedTokens() public view returns (uint256[] memory)
    {
        return _deposits[msg.sender].values();
    }
    
    function totalTokensInWallet() public view returns(uint256)
    {
        return cosmictoken.balanceOf(msg.sender);
    }
    
   
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}


pragma solidity 0.8.7;







contract CosmicFusion is ERC721A, Ownable, ReentrancyGuard
{
    using Address for address;
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    string public baseURI;
    string public baseExtension = ".json";

    mapping (uint256 => address) public fusionIndexToAddress;
    mapping (uint256 => bool) public hasFused;

    CosmicLabs public cosmicLabs;

    constructor() ERC721A("Cosmic Fusion", "CFUSION", 100) 
    {
        
    }

    function setCosmicLabsAddress(address clabsAddress) public onlyOwner
    {
        cosmicLabs = CosmicLabs(clabsAddress);
    }

    modifier onlySender {
        require(msg.sender == tx.origin);
        _;
    }

    function teamMint(uint256 amount) public onlyOwner nonReentrant
    {
        for(uint i=0;i<amount;i++)
        {
            fusionIndexToAddress[_tokenIdTracker.current()] = msg.sender;
            _tokenIdTracker.increment();
        }
        _safeMint(msg.sender, amount);
    }

    function FuseDucks(uint256[] memory tokenIds) public payable nonReentrant
    {
        require(tokenIds.length % 2 == 0, "Odd amount of Ducks Selected");

        for(uint256 i=0; i<tokenIds.length; i++)
        {
            require(tokenIds[i] >= 1001 , "You selected a Genesis");
            require(!hasFused[tokenIds[i]], "These ducks have already fused!");
            cosmicLabs.transferFrom(msg.sender, 0x000000000000000000000000000000000000dEaD ,tokenIds[i]);
            hasFused[tokenIds[i]] = true;
        }

        uint256 fuseAmount = tokenIds.length / 2;
        
        for(uint256 i=0; i<fuseAmount; i++)
        {
            fusionIndexToAddress[_tokenIdTracker.current()] = msg.sender;
            _tokenIdTracker.increment();
        }
        _safeMint(msg.sender, fuseAmount);
        
    }


    function _withdraw(address payable address_, uint256 amount_) internal {
        (bool success, ) = payable(address_).call{value: amount_}("");
        require(success, "Transfer failed");
    }

    function withdrawEther() external onlyOwner {
        _withdraw(payable(msg.sender), address(this).balance);
    }

    function withdrawEtherTo(address payable to_) external onlyOwner {
        _withdraw(to_, address(this).balance);
    }
    
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }   
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) : "";
    }

    function walletOfOwner(address address_) public virtual view returns (uint256[] memory) {
        uint256 _balance = balanceOf(address_);
        uint256[] memory _tokens = new uint256[] (_balance);
        uint256 _index;
        uint256 _loopThrough = totalSupply();
        for (uint256 i = 0; i < _loopThrough; i++) {
            bool _exists = _exists(i);
            if (_exists) {
                if (ownerOf(i) == address_) { _tokens[_index] = i; _index++; }
            }
            else if (!_exists && _tokens[_balance - 1] == 0) { _loopThrough++; }
        }
        return _tokens;
    }

    function transferFrom(address from, address to, uint256 tokenId) public  override {
        fusionIndexToAddress[tokenId] = to;
		ERC721A.transferFrom(from, to, tokenId);
	}

	function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public  override {
        fusionIndexToAddress[tokenId] = to;
		ERC721A.safeTransferFrom(from, to, tokenId, _data);
	}


    
}


pragma solidity ^0.8.0;


contract ERC20I {
    string public name;
    string public symbol;
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    uint8 public constant decimals = 18;

    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _mint(address to_, uint256 amount_) internal virtual {
        totalSupply += amount_;
        balanceOf[to_] += amount_;
        emit Transfer(address(0x0), to_, amount_);
    }
    function _burn(address from_, uint256 amount_) internal virtual {
        balanceOf[from_] -= amount_;
        totalSupply -= amount_;
        emit Transfer(from_, address(0x0), amount_);
    }
    function _approve(address owner_, address spender_, uint256 amount_) internal virtual {
        allowance[owner_][spender_] = amount_;
        emit Approval(owner_, spender_, amount_);
    }

    function approve(address spender_, uint256 amount_) public virtual returns (bool) {
        _approve(msg.sender, spender_, amount_);
        return true;
    }
    function transfer(address to_, uint256 amount_) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount_;
        balanceOf[to_] += amount_;
        emit Transfer(msg.sender, to_, amount_);
        return true;
    }
    function transferFrom(address from_, address to_, uint256 amount_) public virtual returns (bool) {
        if (allowance[from_][msg.sender] != type(uint256).max) {
            allowance[from_][msg.sender] -= amount_; }
        balanceOf[from_] -= amount_;
        balanceOf[to_] += amount_;
        emit Transfer(from_, to_, amount_);
        return true;
    }

    function multiTransfer(address[] memory to_, uint256[] memory amounts_) public virtual {
        require(to_.length == amounts_.length, "ERC20I: To and Amounts length Mismatch!");
        for (uint256 i = 0; i < to_.length; i++) {
            transfer(to_[i], amounts_[i]);
        }
    }
    function multiTransferFrom(address[] memory from_, address[] memory to_, uint256[] memory amounts_) public virtual {
        require(from_.length == to_.length && from_.length == amounts_.length, "ERC20I: From, To, and Amounts length Mismatch!");
        for (uint256 i = 0; i < from_.length; i++) {
            transferFrom(from_[i], to_[i], amounts_[i]);
        }
    }

    function burn(uint256 amount_) external virtual {
        _burn(msg.sender, amount_);
    }
    function burnFrom(address from_, uint256 amount_) public virtual {
        uint256 _currentAllowance = allowance[from_][msg.sender];
        require(_currentAllowance >= amount_, "ERC20IBurnable: Burn amount requested exceeds allowance!");

        if (allowance[from_][msg.sender] != type(uint256).max) {
            allowance[from_][msg.sender] -= amount_; }

        _burn(from_, amount_);
    }
}

pragma solidity 0.8.7;









contract CosmicUtilityToken is ERC20I, Ownable, ReentrancyGuard {


    mapping (uint256 => uint256) public tokenIdEarned;
    mapping (uint256 => uint256) public fusionEarned;

    uint256 public GENESIS_RATE = 0.02777777777 ether;
    uint256 public FUSION_RATE = 12 ether;

    uint256 public startTime = 1645506000;

    uint256 public constant endTimeFusion = 1740200400;
    
    uint256 public totalTokensBurned = 0;

    mapping (address => bool) public firstClaim;

    mapping(uint256 => uint256) public fusionToTimestamp;

    CosmicLabs public cosmicLabs;
    CosmicToken public cosmicToken;
    CosmicFusion public cosmicFusion;

    constructor(address CLABS, address CUT) ERC20I("Cosmic Utility Token", "CUT")
    {
        cosmicLabs = CosmicLabs(CLABS);
        cosmicToken = CosmicToken(CUT);
    }

    function setFusionContract(address fusionContract) public onlyOwner
    {
        cosmicFusion = CosmicFusion(fusionContract);
    }
    function setCosmicLabsContract(address clabsContract) public onlyOwner
    {
        cosmicLabs = CosmicLabs(clabsContract);
    }
    function changeGenesis_Rate(uint256 _incoming) public onlyOwner
    {
        GENESIS_RATE = _incoming;
    }

    function changeFusion_Rate(uint256 _incoming) public onlyOwner
    {
        FUSION_RATE = _incoming;
    }

    function teamMint(uint256 totalAmount) public onlyOwner stakingEnded
    {
        _mint(msg.sender, (totalAmount * 10 ** 18));
    }
    
    modifier hasMigrated
    {
        require(firstClaim[msg.sender] == false);
        _;
    }
    modifier stakingEnded
    {
        require(block.timestamp < endTimeFusion);
        _;
    }
    function migrateCut() public nonReentrant hasMigrated stakingEnded
    {
        uint256 howManyTokens = cosmicToken.balanceOf(msg.sender);
        uint256 extraCommision = (howManyTokens * 10) / 100;

        cosmicToken.transferFrom(msg.sender, address(this), howManyTokens);

        firstClaim[msg.sender] = true;
        _mint(msg.sender, (howManyTokens + extraCommision));
    }


    function claimRewards(uint256[] memory nftsToClaim) public nonReentrant stakingEnded
    {
        for(uint256 i=0;i<nftsToClaim.length;i++)
        {
            require(cosmicLabs.ownerOf(nftsToClaim[i]) == msg.sender, "You are not the owner of these tokens");
        }

        _mint(msg.sender, tokensAccumulated(nftsToClaim));
        
        for(uint256 i=0; i<nftsToClaim.length;i++)
        {
            tokenIdEarned[nftsToClaim[i]] = block.timestamp;
        }
    }

    function tokensAccumulated(uint256[] memory nftsToCheck) public view returns(uint256)
    {
        uint256 totalTokensEarned;

        for(uint256 i=0; i<nftsToCheck.length;i++)
        {
            if(nftsToCheck[i] <= 1000)
            {
                totalTokensEarned += (howManyMinStaked(nftsToCheck[i]) * GENESIS_RATE);
            }
        }

        return totalTokensEarned;

    }

    function howManyMinStaked(uint256 tokenId) public view returns(uint256)
    {
        uint256 timeCalc;

        if(tokenIdEarned[tokenId] == 0)
        {
            timeCalc = block.timestamp - startTime;
        }
        else
        {
            timeCalc = block.timestamp - tokenIdEarned[tokenId];
        }
        
        uint256 returnMins = timeCalc / 60;
       
        return returnMins;
    }

    function getPendingTokensFusion(uint256 tokenId_) public view returns (uint256) {
        uint256 _timestamp = fusionToTimestamp[tokenId_] == 0 ?
            startTime : fusionToTimestamp[tokenId_] > endTimeFusion ? 
            endTimeFusion : fusionToTimestamp[tokenId_];
        uint256 _currentTimeOrEnd = block.timestamp > endTimeFusion ?
            endTimeFusion : block.timestamp;
        uint256 _timeElapsed = _currentTimeOrEnd - _timestamp;

        return (_timeElapsed * FUSION_RATE) / 1 days;
    }
    function getPendingTokensManyFusion(uint256[] memory tokenIds_) public view 
    returns (uint256) {
        uint256 _pendingTokens;
        for (uint256 i = 0; i < tokenIds_.length; i++) {
            _pendingTokens += getPendingTokensFusion(tokenIds_[i]);
        }
        return _pendingTokens;
    }

    function claimFusion(address to_, uint256[] memory tokenIds_) external {
        require(tokenIds_.length > 0, 
            "You must claim at least 1 Fusion!");

        uint256 _pendingTokens = tokenIds_.length > 1 ?
            getPendingTokensManyFusion(tokenIds_) :
            getPendingTokensFusion(tokenIds_[0]);
        
        for (uint256 i = 0; i < tokenIds_.length; i++) {
            require(to_ == cosmicFusion.fusionIndexToAddress(tokenIds_[i]),
                "claim(): to_ is not owner of Cosmic Fusion!");

            fusionToTimestamp[tokenIds_[i]] = block.timestamp;
        }
        
        _mint(to_, _pendingTokens);
    }

    function getPendingTokensOfAddress(address address_) public view returns (uint256) {
        uint256[] memory _tokensOfAddress = cosmicFusion.walletOfOwner(address_);
        return getPendingTokensManyFusion(_tokensOfAddress);
    }
  

    function burn(address _from, uint256 _amount) external 
	{
	    require(msg.sender == _from, "You do not own these tokens");
		_burn(_from, _amount);
		totalTokensBurned += _amount;
	}

    function burnFrom(address _from, uint256 _amount) public override
    {
        ERC20I.burnFrom(_from, _amount);
    }

    
}