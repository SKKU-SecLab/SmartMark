pragma solidity ^0.8.0;





interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}


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

interface IWETH {


    function deposit() external payable;


    function withdraw(uint) external;


    function approve(address, uint) external returns(bool);


    function transfer(address, uint) external returns(bool);


    function transferFrom(address, address, uint) external returns(bool);


    function balanceOf(address) external view returns(uint);


}

interface ISettings {

    function feeReceiver() external view returns(address);

}


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}

interface IFERC1155 is IERC1155 {

  function burn(
    address,
    uint256,
    uint256
  ) external;


  function totalSupply(uint256) external view returns (uint256);

}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


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



interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}


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

contract Vault is ERC721Holder, ERC1155Holder {

  using EnumerableSet for EnumerableSet.UintSet;
  string public version = "2.0";

  address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;


  uint256 public auctionEnd;
  uint256 public constant LENGTH = 2 days;
  uint256 public livePrice;
  address public winning;

  enum State {
    inactive,
    live,
    ended,
    redeemed
  }
  State public auctionState;


  bool initialized = false;
  address public immutable settings;
  address public immutable curator;
  address public immutable fractions;
  uint256 public immutable fractionsID;
  address public immutable underlying;
  uint256 public immutable underlyingID;

  EnumerableSet.UintSet prices;
  mapping(uint256 => uint256) public priceToCount;
  mapping(address => uint256) public userPrices;


  event Redeem(address indexed redeemer);
  event Bid(address indexed buyer, uint256 price);
  event Won(address indexed buyer, uint256 price);
  event Start(address indexed buyer, uint256 price);
  event Cash(address indexed owner, uint256 shares);
  event PriceUpdate(address indexed user, uint256 price);
  event WithdrawETH(address indexed to);
  event WithdrawERC20(address indexed token, address indexed to);
  event WithdrawERC721(
    address indexed token,
    uint256 tokenId,
    address indexed to
  );
  event WithdrawERC1155(
    address indexed token,
    uint256 tokenId,
    uint256 amount,
    address indexed to
  );

  constructor(
    address _fractions,
    uint256 _fractionsID,
    address _underlying,
    uint256 _underlyingID,
    address _curator
  ) {
    settings = msg.sender;
    fractions = _fractions;
    fractionsID = _fractionsID;
    underlying = _underlying;
    underlyingID = _underlyingID;
    curator = _curator;
  }

  function token() external view returns (address) {

    return underlying;
  }

  function id() external view returns (uint256) {

    return underlyingID;
  }

  function isLivePrice(uint256 _price) external view returns (bool) {

    return prices.contains(_price);
  }

  function updateUserPrice(uint256 _new) external {

    uint256 balance = IFERC1155(fractions).balanceOf(msg.sender, fractionsID);

    _addToPrice(balance, _new);
    _removeFromPrice(balance, userPrices[msg.sender]);

    userPrices[msg.sender] = _new;

    emit PriceUpdate(msg.sender, _new);
  }

  function onTransfer(
    address _from,
    address _to,
    uint256 _amount
  ) external {

    require(msg.sender == fractions, "not allowed");

    if (_to == address(0)) {
      _removeFromPrice(_amount, userPrices[_from]);
    } else if (_from == address(0)) {
      _addToPrice(_amount, userPrices[_to]);
    } else {
      _removeFromPrice(_amount, userPrices[_from]);
      _addToPrice(_amount, userPrices[_to]);
    }
  }

  function _addToPrice(uint256 _amount, uint256 _price) internal {

    priceToCount[_price] += _amount;
    if (
      priceToCount[_price] * 100 >=
      IFERC1155(fractions).totalSupply(fractionsID) &&
      !prices.contains(_price)
    ) {
      prices.add(_price);
    }
  }

  function _removeFromPrice(uint256 _amount, uint256 _price) internal {

    priceToCount[_price] -= _amount;
    if (
      priceToCount[_price] * 100 <
      IFERC1155(fractions).totalSupply(fractionsID) &&
      prices.contains(_price)
    ) {
      prices.remove(_price);
    }
  }

  function swap(
    uint256[] memory array,
    uint256 i,
    uint256 j
  ) internal pure {

    (array[i], array[j]) = (array[j], array[i]);
  }

  function sort(
    uint256[] memory array,
    uint256 begin,
    uint256 last
  ) internal pure {

    if (begin < last) {
      uint256 j = begin;
      uint256 pivot = array[j];
      for (uint256 i = begin + 1; i < last; ++i) {
        if (array[i] < pivot) {
          swap(array, i, ++j);
        }
      }
      swap(array, begin, j);
      sort(array, begin, j);
      sort(array, j + 1, last);
    }
  }

  function reservePrice()
    public
    view
    returns (uint256 voting, uint256 reserve)
  {

    uint256[] memory tempPrices = prices.values();
    sort(tempPrices, 0, tempPrices.length);
    voting = 0;
    for (uint256 x = 0; x < tempPrices.length; x++) {
      if (tempPrices[x] != 0) {
        voting += priceToCount[tempPrices[x]];
      }
    }

    uint256 count = 0;
    for (uint256 y = 0; y < tempPrices.length; y++) {
      if (tempPrices[y] != 0) {
        count += priceToCount[tempPrices[y]];
      }
      if (count * 2 >= voting) {
        reserve = tempPrices[y];
        break;
      }
    }
  }

  function start() external payable {

    require(auctionState == State.inactive, "start:no auction starts");
    (uint256 voting, uint256 reserve) = reservePrice();
    require(msg.value >= reserve, "start:too low bid");
    require(
      voting * 2 >= IFERC1155(fractions).totalSupply(fractionsID),
      "start:not enough voters"
    );

    auctionEnd = block.timestamp + LENGTH;
    auctionState = State.live;
    livePrice = msg.value;
    winning = msg.sender;
    emit Start(msg.sender, msg.value);
  }

  function bid() external payable {

    require(auctionState == State.live, "bid:auction is not live");
    require(msg.value * 100 >= livePrice * 105, "bid:too low bid");
    require(block.timestamp < auctionEnd, "bid:auction ended");

    if (auctionEnd - block.timestamp <= 15 minutes) {
      auctionEnd += 15 minutes;
    }
    _sendETHOrWETH(winning, livePrice);
    livePrice = msg.value;
    winning = msg.sender;
    emit Bid(msg.sender, msg.value);
  }

  function end() external {

    require(auctionState == State.live, "end:vault has already closed");
    require(block.timestamp >= auctionEnd, "end:auction live");

    IERC721(underlying).transferFrom(address(this), winning, underlyingID);
    auctionState = State.ended;

    if (ISettings(settings).feeReceiver() != address(0)) {
      _sendETHOrWETH(ISettings(settings).feeReceiver(), livePrice / 40);
    }

    emit Won(winning, livePrice);
  }

  function redeem() external {

    require(auctionState == State.inactive, "redeem:no redeeming");

    IFERC1155(fractions).burn(
      msg.sender,
      fractionsID,
      IFERC1155(fractions).totalSupply(fractionsID)
    );
    IERC721(underlying).transferFrom(address(this), msg.sender, underlyingID);

    auctionState = State.redeemed;
    winning = msg.sender;
    emit Redeem(msg.sender);
  }

  function cash() external {

    require(auctionState == State.ended, "cash:vault not closed yet");
    uint256 bal = IFERC1155(fractions).balanceOf(msg.sender, fractionsID);
    require(bal > 0, "cash:no tokens to cash out");
    uint256 share = (bal * address(this).balance) /
      IFERC1155(fractions).totalSupply(fractionsID);

    IFERC1155(fractions).burn(msg.sender, fractionsID, bal);
    _sendETHOrWETH(msg.sender, share);
    emit Cash(msg.sender, share);
  }

  function _sendETHOrWETH(address to, uint256 value) internal {

    if (!_attemptETHTransfer(to, value)) {
      IWETH(weth).deposit{ value: value }();
      IWETH(weth).transfer(to, value);
    }
  }

  function _attemptETHTransfer(address to, uint256 value)
    internal
    returns (bool)
  {

    (bool success, ) = to.call{ value: value, gas: 30000 }("");
    return success;
  }

  function withdrawERC721(address _token, uint256 _tokenId) external {

    require(
      auctionState == State.ended || auctionState == State.redeemed,
      "vault not closed yet"
    );
    require(msg.sender == winning, "withdraw:not allowed");
    IERC721(_token).transferFrom(address(this), msg.sender, _tokenId);
    emit WithdrawERC721(_token, _tokenId, msg.sender);
  }

  function withdrawERC1155(
    address _token,
    uint256 _tokenId,
    uint256 _amount
  ) external {

    require(
      auctionState == State.ended || auctionState == State.redeemed,
      "vault not closed yet"
    );
    require(msg.sender == winning, "withdraw:not allowed");
    IERC1155(_token).safeTransferFrom(
      address(this),
      msg.sender,
      _tokenId,
      _amount,
      "0"
    );
    emit WithdrawERC1155(_token, _tokenId, _amount, msg.sender);
  }

  function withdrawETH() external {

    require(auctionState == State.redeemed, "vault not closed yet");
    require(msg.sender == winning, "withdraw:not allowed");
    payable(msg.sender).transfer(address(this).balance);
    emit WithdrawETH(msg.sender);
  }

  function withdrawERC20(address _token) external {

    require(
      auctionState == State.ended || auctionState == State.redeemed,
      "vault not closed yet"
    );
    require(msg.sender == winning, "withdraw:not allowed");
    IERC20(_token).transfer(
      msg.sender,
      IERC20(_token).balanceOf(address(this))
    );
    emit WithdrawERC20(_token, msg.sender);
  }

  receive() external payable {}
}



interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}


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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using Address for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
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
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
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

interface IVault {

  function onTransfer(
    address,
    address,
    uint256
  ) external;

}

contract FERC1155 is ERC1155, Ownable {

  using Strings for uint256;

  string private baseURI;
  mapping(address => bool) public minters;
  mapping(uint256 => uint256) private _totalSupply;

  uint256 public count = 0;

  mapping(uint256 => address) public idToVault;

  constructor() ERC1155("") {}

  modifier onlyMinter() {

    require(minters[msg.sender]);
    _;
  }


  function addMinter(address minter) external onlyOwner {

    minters[minter] = true;
  }

  function removeMinter(address minter) external onlyOwner {

    minters[minter] = false;
  }

  function updateBaseUri(string calldata base) external onlyOwner {

    baseURI = base;
  }


  function mint(address vault, uint256 amount)
    external
    onlyMinter
    returns (uint256)
  {

    count++;
    idToVault[count] = vault;
    _mint(msg.sender, count, amount, "0");
    _totalSupply[count] = amount;
    return count;
  }

  function mint(uint256 amount, uint256 id) external onlyMinter {

    require(id <= count, "doesn't exist");
    _mint(msg.sender, id, amount, "0");
    _totalSupply[count] += amount;
  }

  function burn(
    address account,
    uint256 id,
    uint256 value
  ) public virtual {

    require(
      account == _msgSender() || isApprovedForAll(account, _msgSender()),
      "ERC1155: caller is not owner nor approved"
    );
    _burn(account, id, value);
    _totalSupply[id] -= value;
  }


  function totalSupply(uint256 id) public view virtual returns (uint256) {

    return _totalSupply[id];
  }

  function uri(uint256 id) public view override returns (string memory) {

    return
      bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, id.toString()))
        : baseURI;
  }

  function _beforeTokenTransfer(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) internal virtual override {

    require(ids.length == 1, "too long");
    super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

    IVault(idToVault[ids[0]]).onTransfer(from, to, amounts[0]);
  }
}

contract FERC1155Seller is ERC1155Holder, ReentrancyGuard {

    FERC1155 public immutable fnft;

    struct List {
        uint256 price;
        uint256 start;
        uint256 end;
    }
    mapping(uint256 => List) public fIdToListing;

    event Listing(
        address indexed fnft,
        uint256 indexed fId,
        address indexed seller,
        uint256 amount,
        uint256 start,
        uint256 end,
        uint256 price
    );
    event Purchase(
        address indexed buyer,
        address indexed fnft,
        uint256 indexed fId,
        uint256 amount,
        uint256 price
    );
    event End(address indexed fnft, uint256 indexed fId);
    event UpdatePrice(address indexed fnft, uint256 indexed fId, uint256 price);

    constructor(address _fractions) {
        fnft = FERC1155(_fractions);
    }

    function safeTransferETH(address to, uint256 amount) internal {

        bool success;

        assembly {
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    function getCurator(uint256 fId) internal returns (address) {

        return Vault(payable(fnft.idToVault(fId))).curator();
    }

    function getPrice(uint256 fId) public view returns (uint256) {

        return fIdToListing[fId].price;
    }

    function getStartEnd(uint256 fId) public view returns (uint256, uint256) {

        return (fIdToListing[fId].start, fIdToListing[fId].end);
    }

    modifier onlyCurator(uint256 fId) {

        require(msg.sender == getCurator(fId));
        _;
    }
    modifier whileActive(uint256 fId) {

        (uint256 start, uint256 end) = getStartEnd(fId);
        require(block.timestamp > start && block.timestamp < end, "inactive");
        _;
    }

    function list(
        uint256 _fId,
        uint256 _price,
        uint256 _amount,
        uint256 _start,
        uint256 _end
    ) public onlyCurator(_fId) {

        require(fnft.balanceOf(address(this), _fId) == 0, "already listed");
        fIdToListing[_fId].price = _price;
        fIdToListing[_fId].start = _start;
        fIdToListing[_fId].end = _end;
        fnft.safeTransferFrom(msg.sender, address(this), _fId, _amount, "0");
        emit Listing(
            address(fnft),
            _fId,
            msg.sender,
            _amount,
            _start,
            _end,
            _price
        );
    }

    function buy(uint256 _fId, uint256 _amount)
        external
        payable
        nonReentrant
        whileActive(_fId)
    {

        uint256 price = fIdToListing[_fId].price;
        require(msg.value == price * _amount, "wrong price");
        payable(getCurator(_fId)).transfer(msg.value);

        fnft.safeTransferFrom(address(this), msg.sender, _fId, _amount, "0");
        emit Purchase(msg.sender, address(fnft), _fId, _amount, price);
        if (fnft.balanceOf(address(this), _fId) == 0)
            emit End(address(fnft), _fId);
    }

    function end(uint256 _fId) external onlyCurator(_fId) {

        uint256 bal = fnft.balanceOf(address(this), _fId);
        fnft.safeTransferFrom(address(this), msg.sender, _fId, bal, "0");
        emit End(address(fnft), _fId);
    }

    function update(uint256 _fId, uint256 _price) external onlyCurator(_fId) {

        fIdToListing[_fId].price = _price;
        emit UpdatePrice(address(fnft), _fId, _price);
    }
}