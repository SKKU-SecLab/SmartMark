
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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

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
}pragma solidity ^0.8.8;





abstract contract ERC721 is IERC721Metadata, IERC721Enumerable, Context {
  using Address for address;

  mapping(uint256 => address) internal _owners;
  mapping (uint256 => address) internal _idToApproval;
  mapping (address => mapping (address => bool)) internal _ownerToOperators;

  uint256 internal _maxTokenId;

  string constant ZERO_ADDRESS = "003001";
  string constant NOT_VALID_NFT = "003002";
  string constant NOT_OWNER_OR_OPERATOR = "003003";
  string constant NOT_OWNER_APPROVED_OR_OPERATOR = "003004";
  string constant NOT_ABLE_TO_RECEIVE_NFT = "003005";
  string constant NFT_ALREADY_EXISTS = "003006";
  string constant NOT_OWNER = "003007";
  string constant IS_OWNER = "003008";

  bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

  constructor() {}


  modifier canOperate(uint256 tokenId) {
    address tokenOwner = _owners[tokenId];
    require(
      tokenOwner == _msgSender() || _ownerToOperators[tokenOwner][_msgSender()],
      NOT_OWNER_OR_OPERATOR
    );
    _;
  }

  modifier canTransfer(uint256 tokenId) {
    address tokenOwner = _owners[tokenId];

    require(
      tokenOwner == _msgSender()
      || _idToApproval[tokenId] == _msgSender()
      || _ownerToOperators[tokenOwner][_msgSender()],
      NOT_OWNER_APPROVED_OR_OPERATOR
    );
    _;
  }

  modifier validNFToken(uint256 tokenId) {
    require(_exists(tokenId), NOT_VALID_NFT);
    _;
  }

  function decimals() public pure virtual returns (uint256) {
    return 0;
  }


  function balanceOf(address owner) public view virtual returns (uint256 balance) {
    require(owner != address(0),  ZERO_ADDRESS);

    for (uint256 i; i <= _maxTokenId; i++) {
      if (_owners[i] == owner) {
        balance++;
      }
    }

    return balance;
  }

  function ownerOf(uint256 tokenId) external view returns (address owner) {
    owner = _owners[tokenId];
    require(owner != address(0), NOT_VALID_NFT);
  }

  function approve(address approved, uint256 tokenId) external canOperate(tokenId) validNFToken(tokenId) {
    address tokenOwner = _owners[tokenId];
    require(approved != tokenOwner, IS_OWNER);

    _idToApproval[tokenId] = approved;
    emit Approval(tokenOwner, approved, tokenId);
  }

  function getApproved(uint256 tokenId) external view validNFToken(tokenId) returns (address) {
    return _idToApproval[tokenId];
  }

  function setApprovalForAll(address operator, bool approved) external {
    _ownerToOperators[_msgSender()][operator] = approved;
    emit ApprovalForAll(_msgSender(), operator, approved);
  }

  function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
    return _ownerToOperators[owner][operator];
  }

  function safeTransferFrom(address from, address to, uint256 tokenId) external virtual {
    _safeTransferFrom(from, to, tokenId, '');
  }

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external canTransfer(tokenId) validNFToken(tokenId) {
    _safeTransferFrom(from, to, tokenId, data);
  }

  function transferFrom(address from, address to, uint256 tokenId) external canTransfer(tokenId) validNFToken(tokenId) {
    address tokenOwner = _owners[tokenId];
    require(tokenOwner == from, NOT_OWNER);
    require(to != address(0), ZERO_ADDRESS);

    _transfer(to, tokenId);
  }


  function totalSupply() public view returns (uint256 total) {
    for (uint256 i; i <= _maxTokenId; i++) {
      if (_owners[i] != address(0)) {
        total++;
      }
    }

    return total;
  }

  function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256) {
    uint256 balance = balanceOf(owner);

    uint256[] memory tokens = new uint256[](balance);
    uint256 idx;

    for (uint256 i; i <= _maxTokenId; i++) {
      if (_owners[i] == owner) {
        tokens[idx] = i;
        idx++;
      }
    }

    return tokens[index];
  }

  function tokenByIndex(uint256 index) external view returns (uint256) {
    uint256 supply = totalSupply();

    uint256[] memory tokens = new uint256[](supply);
    uint256 idx;
    for (uint256 i; i <= _maxTokenId; i++) {
      if (_owners[i] != address(0)) {
        tokens[idx] = i;
        idx++;
      }
    }

    return tokens[index];
  }


  function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
    if (interfaceId == 0xffffffff) {
      return false;
    }

    return
      interfaceId == type(IERC721).interfaceId ||
      interfaceId == type(IERC721Receiver).interfaceId ||
      interfaceId == type(IERC721Metadata).interfaceId ||
      interfaceId == type(IERC721Enumerable).interfaceId;
  }

  function _mint(address to, uint256 tokenId) internal {
    require(to != address(0), ZERO_ADDRESS);
    require(!_exists(tokenId), NFT_ALREADY_EXISTS);

    _owners[tokenId] = to;

    if (tokenId > _maxTokenId) {
      _maxTokenId = tokenId;
    }

    emit Transfer(address(0), to, tokenId);

    if (to.isContract()) {
      bytes4 retval = IERC721Receiver(to).onERC721Received(address(this), address(0), tokenId, "");
      require(retval == MAGIC_ON_ERC721_RECEIVED, NOT_ABLE_TO_RECEIVE_NFT);
    }
  }

  function _burn(uint256 tokenId) internal virtual validNFToken(tokenId) canTransfer(tokenId) {
    address tokenOwner = _owners[tokenId];

    _clearApproval(tokenId);
    delete _owners[tokenId];

    emit Transfer(tokenOwner, address(0), tokenId);
  }

  function _exists(uint256 tokenId) internal view returns (bool) {
    return _owners[tokenId] != address(0);
  }

  function _clearApproval(uint256 tokenId) private {
    delete _idToApproval[tokenId];
  }

  function _safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
  private
  canTransfer(_tokenId)
  validNFToken(_tokenId)
  {
    address tokenOwner = _owners[_tokenId];
    require(tokenOwner == _from, NOT_OWNER);
    require(_to != address(0), ZERO_ADDRESS);

    _transfer(_to, _tokenId);

    if (_to.isContract()) {
      bytes4 retval = IERC721Receiver(_to).onERC721Received(_msgSender(), _from, _tokenId, _data);
      require(retval == MAGIC_ON_ERC721_RECEIVED, NOT_ABLE_TO_RECEIVE_NFT);
    }
  }

  function _transfer(address to, uint256 tokenId) internal virtual {
    address from = _owners[tokenId];

    _beforeTransfer(from, to, tokenId);

    _clearApproval(tokenId);
    _owners[tokenId] = to;

    emit Transfer(from, to, tokenId);
  }

  function _beforeTransfer(address from, address to, uint256 tokenId) internal virtual {}
}pragma solidity ^0.8.0;



abstract contract Hybrid {
  string constant INVALID_STATUS = "004002";

  enum  TokenStatus { Vaulted, Redeemed, Lost }
  mapping(uint256 => TokenStatus) private _tokenStatus;

  function _setStatus(uint256 tokenId, TokenStatus status) internal {
    _tokenStatus[tokenId] = status;
  }

  modifier notStatus(uint256 tokenId, TokenStatus status) {
    require(_tokenStatus[tokenId] != status, INVALID_STATUS);
    _;
  }
}pragma solidity ^0.8.0;




abstract contract AccessControl is Context {
  bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
  bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');
  bytes32 public constant STATUS_CHANGER_ROLE = keccak256('STATUS_CHANGER_ROLE');

  string constant INVALID_PERMISSION = "005001";

  address private _admin;

  mapping(address => mapping(bytes32 => bool)) private _roles;

  modifier onlyRole(bytes32 role) {
    require(_roles[_msgSender()][role] == true, INVALID_PERMISSION);
    _;
  }

  modifier onlyAdmin() {
    require(_msgSender() == _admin, INVALID_PERMISSION);
    _;
  }

  function _grantRole(address to, bytes32 role) internal {
    require(to != address(0), INVALID_PERMISSION);
    _roles[to][role] = true;
  }

  function _revokeRole(address from, bytes32 role) internal {
    _roles[from][role] = false;
  }

  function _setAdmin(address to) internal {
    require(to != address(0), INVALID_PERMISSION);
    _admin = to;
  }
}pragma solidity ^0.8.8;




contract OneOfNoneHybrid is ERC721, Hybrid, AccessControl, Pausable {

  using Strings for uint256;

  string constant METADATA_FROZEN = "006001";
  string constant LIMIT_REACHED = "006002";

  mapping(uint256 => string) private _freezeMetadata;
  string private _baseURI;

  uint256 public constant LIMIT = 1;

  constructor() {
    _setAdmin(msg.sender);
  }

  function name() public pure returns (string memory) {

    return "Custom Game Time Pro";
  }

  function symbol() public pure returns (string memory) {

    return "1XIXK";
  }

  function mint(address to, TokenStatus status) external virtual whenNotPaused onlyRole(MINTER_ROLE) {

    require(_maxTokenId + 1 <= LIMIT, LIMIT_REACHED);

    uint256 tokenId = _maxTokenId + 1;

    _mint(to, tokenId);
    _setStatus(tokenId, status);
  }

  function tokenURI(uint256 tokenId) external view returns (string memory) {

    require(_exists(tokenId), NOT_VALID_NFT);

    if (bytes(_freezeMetadata[tokenId]).length > 0) {
      return _freezeMetadata[tokenId];
    }

    return bytes(_baseURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenId.toString())) : '';
  }

  function freezeMetadataURI(uint256 tokenId, string calldata uri) external onlyAdmin {

    require(_exists(tokenId), NOT_VALID_NFT);
    require(bytes(_freezeMetadata[tokenId]).length == 0, METADATA_FROZEN);

    _freezeMetadata[tokenId] = uri;
  }

  function setMetadataBaseURI(string calldata uri) external onlyAdmin {

    _baseURI = uri;
  }

  function pause() public onlyRole(PAUSER_ROLE) {

    _pause();
  }

  function unpause() public onlyAdmin {

    _unpause();
  }

  function setStatus(uint256 tokenId, TokenStatus status) public onlyRole(STATUS_CHANGER_ROLE) {

    require(_exists(tokenId), NOT_VALID_NFT);
    _setStatus(tokenId, status);
  }

  function _beforeTransfer(address from, address to, uint256 tokenId)
    internal override whenNotPaused notStatus(tokenId, TokenStatus.Redeemed) {}


  function setRole(address to, bytes32 role) public onlyAdmin {

    _grantRole(to, role);
  }

  function revokeRole(address to, bytes32 role) public onlyAdmin {

    _revokeRole(to, role);
  }

  function transferAdmin(address to) public onlyAdmin {

    _setAdmin(to);
  }
}