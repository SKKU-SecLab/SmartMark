
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
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

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

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

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

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
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
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
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

}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

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
}// MIT
pragma solidity ^0.8.9;



interface IMarqueeArt {
  enum Mode {
    Marquee,
    CSS
  }

  function getPalette(uint256) external view returns (string[10] memory);

  function getDogString(uint256, Mode) external view returns (string memory);

  function getDogSpeed(uint256) external view returns (uint8, uint8);

  function tokenHTML(uint256, Mode) external view returns (string memory);

  function tokenSVG(uint256, Mode) external view returns (string memory);

  function tokenURI(
    uint256,
    Mode,
    uint256
  ) external view returns (string memory);
}

contract OwnableDelegateProxy {}

contract ProxyRegistry {
  mapping(address => OwnableDelegateProxy) public proxies;
}

contract Marquee is ERC721, ReentrancyGuard, Ownable {
  enum Mode {
    Marquee,
    CSS
  }

  uint256 private _tokenSupply;
  mapping(uint256 => address) private _owners;
  mapping(uint256 => bool) private _isResurrectioned;
  mapping(uint256 => uint256) private _rescueDates;

  address proxyRegistryAddress;
  address public artAddress;
  bool public artLocked;

  uint256 public constant MAX_SUPPLY = 1_145;
  uint256 public constant OWNER_ALLOTMENT = 50;
  uint256 public constant SUPPLY = MAX_SUPPLY - OWNER_ALLOTMENT;
  uint256 public shelterSize = 3;
  uint256 public dutchBasePrice = 0.02 ether;
  uint256 public dutchStepPrice = 0.01 ether;
  uint256 public dutchStepTime = 30 * 60;
  uint256 public dutchEndTime = 12 * 60 * 60;
  uint256 public shelterStartTime;
  bool public shelterIsActive;

  constructor(address _proxyRegistryAddress, address _artAddress)
    ERC721("marquee shelter", "MQSLT")
  {
    proxyRegistryAddress = _proxyRegistryAddress;
    artAddress = _artAddress;
  }

  modifier costs() {
    require(msg.value >= price(), "Not enough ETH sent; check price!");
    _;
  }

  function price() public view returns (uint256) {
    uint256 endTime = today() + dutchEndTime;
    if (block.timestamp > endTime) {
      return dutchBasePrice;
    }
    uint256 timeElapsed = endTime - block.timestamp;
    uint256 steps = timeElapsed / dutchStepTime;
    if (block.timestamp == today()) {
      steps--;
    }
    return dutchBasePrice + dutchStepPrice * steps;
  }

  function ownerMint(uint256[] memory _tokenIds, address to)
    external
    nonReentrant
    onlyOwner
  {
    for (uint256 i; i < _tokenIds.length; i++) {
      uint256 _tokenId = _tokenIds[i];
      require(0 < _tokenId && _tokenId <= MAX_SUPPLY);
      require(SUPPLY < _tokenId);
      _tokenSupply++;
      _rescueDates[_tokenId] = today();
      _safeMint(to, _tokenId);
    }
  }


  function open() private view returns (bool) {
    return shelterStartTime != 0 && shelterStartTime <= block.timestamp;
  }

  function today() private view returns (uint256) {
    return (block.timestamp / 1 days) * 60 * 60 * 24;
  }

  function rescue(uint256 _tokenId) external payable nonReentrant costs {
    require(!_exists(_tokenId), "ERC721: token already minted");
    require(open(), "INACTIVE");
    require(shelterIsActive, "INACTIVE");
    require(0 < _tokenId && _tokenId <= SUPPLY, "INVALID");

    uint256[] memory ids = availableIds();
    bool available;
    for (uint256 i = 0; i < ids.length; i++) {
      if (_tokenId == ids[i]) {
        available = true;
      }
    }
    require(available, "NOT AVAILABLE");

    _tokenSupply++;
    _rescueDates[_tokenId] = today();
    _safeMint(_msgSender(), _tokenId);
  }

  function availableIds() public view returns (uint256[] memory) {
    require(open(), "INACTIVE");
    uint256[] memory _availableIds = new uint256[](shelterSize);

    uint256 day = ((block.timestamp - shelterStartTime) / 1 days) % 365;
    uint256 startId = day * shelterSize + 1;
    uint256 index = 0;
    for (uint256 i = 0; i < shelterSize; i++) {
      _availableIds[index] = startId + i;
      index++;
    }
    return _availableIds;
  }


  function setShelterStartTime(uint256 _shelterStartTime) external onlyOwner {
    shelterStartTime = _shelterStartTime;
  }

  function setShelterIsActive(bool _shelterIsActive) external onlyOwner {
    shelterIsActive = _shelterIsActive;
  }

  function setShelterSize(uint256 _size) external onlyOwner {
    shelterSize = _size;
  }

  function setDutchEndTime(uint256 _time) external onlyOwner {
    dutchEndTime = _time;
  }

  function setDutchStepTime(uint256 _time) external onlyOwner {
    dutchStepTime = _time;
  }

  function setDutchBasePrice(uint256 _price) external onlyOwner {
    dutchBasePrice = _price;
  }

  function setDutchStepPrice(uint256 _price) external onlyOwner {
    dutchStepPrice = _price;
  }

  function setArtLocked() external onlyOwner {
    artLocked = true;
  }

  function setArtAddress(address _address) external onlyOwner {
    require(!artLocked);
    artAddress = _address;
  }

  function resurrection(uint256 _tokenId) external {
    require(ownerOf(_tokenId) == _msgSender());
    _isResurrectioned[_tokenId] = true;
  }


  function tokenHTML(uint256 _tokenId, Mode mode)
    external
    view
    returns (string memory)
  {
    return
      IMarqueeArt(artAddress).tokenHTML(
        _tokenId,
        mode == Mode.CSS ? IMarqueeArt.Mode.CSS : IMarqueeArt.Mode.Marquee
      );
  }

  function tokenSVG(uint256 _tokenId) external view returns (string memory) {
    return
      IMarqueeArt(artAddress).tokenSVG(
        _tokenId,
        _isResurrectioned[_tokenId]
          ? IMarqueeArt.Mode.CSS
          : IMarqueeArt.Mode.Marquee
      );
  }

  function getDogString(uint256 _tokenId)
    external
    view
    returns (string memory)
  {
    return
      IMarqueeArt(artAddress).getDogString(
        _tokenId,
        _isResurrectioned[_tokenId]
          ? IMarqueeArt.Mode.CSS
          : IMarqueeArt.Mode.Marquee
      );
  }

  function getDogSpeed(uint256 _tokenId) external view returns (uint8, uint8) {
    return IMarqueeArt(artAddress).getDogSpeed(_tokenId);
  }

  function getPalette(uint256 _tokenId)
    external
    view
    returns (string[10] memory)
  {
    return IMarqueeArt(artAddress).getPalette(_tokenId);
  }


  function tokenURI(uint256 _tokenId)
    public
    view
    override
    returns (string memory)
  {
    return
      IMarqueeArt(artAddress).tokenURI(
        _tokenId,
        _isResurrectioned[_tokenId]
          ? IMarqueeArt.Mode.CSS
          : IMarqueeArt.Mode.Marquee,
        _rescueDates[_tokenId]
      );
  }

  function totalSupply() external view returns (uint256) {
    return _tokenSupply;
  }

  function withdrawBalance() external onlyOwner {
    (bool success, ) = msg.sender.call{ value: address(this).balance }("");
    require(success);
  }

  function walletOfOwner(address _owner)
    external
    view
    returns (uint256[] memory)
  {
    uint256 tokenCount = balanceOf(_owner);
    uint256[] memory tokensId = new uint256[](tokenCount);
    uint256 count;
    for (uint256 i = 1; i <= MAX_SUPPLY; i++) {
      if (_owners[i] == _owner) {
        tokensId[count] = i;
        count++;
      }
    }
    return tokensId;
  }

  function owners() external view returns (address[] memory) {
    address[] memory tokens = new address[](MAX_SUPPLY);

    for (uint256 i = 0; i < MAX_SUPPLY; i++) {
      tokens[i] = _owners[i + 1];
    }
    return tokens;
  }


  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal override(ERC721) {
    super._beforeTokenTransfer(from, to, tokenId);
    _owners[tokenId] = to;
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }

  function isApprovedForAll(address _owner, address _operator)
    public
    view
    override
    returns (bool)
  {
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (address(proxyRegistry.proxies(_owner)) == _operator) {
      return true;
    }

    return super.isApprovedForAll(_owner, _operator);
  }
}

library Base64 {
  bytes internal constant TABLE =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  function encode(bytes memory data) internal pure returns (string memory) {
    uint256 len = data.length;
    if (len == 0) return "";

    uint256 encodedLen = 4 * ((len + 2) / 3);

    bytes memory result = new bytes(encodedLen + 32);

    bytes memory table = TABLE;

    assembly {
      let tablePtr := add(table, 1)
      let resultPtr := add(result, 32)

      for {
        let i := 0
      } lt(i, len) {

      } {
        i := add(i, 3)
        let input := and(mload(add(data, i)), 0xffffff)

        let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
        out := shl(8, out)
        out := add(
          out,
          and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
        )
        out := shl(8, out)
        out := add(
          out,
          and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
        )
        out := shl(8, out)
        out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
        out := shl(224, out)

        mstore(resultPtr, out)

        resultPtr := add(resultPtr, 4)
      }

      switch mod(len, 3)
      case 1 {
        mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
      }
      case 2 {
        mstore(sub(resultPtr, 1), shl(248, 0x3d))
      }

      mstore(result, encodedLen)
    }

    return string(result);
  }
}