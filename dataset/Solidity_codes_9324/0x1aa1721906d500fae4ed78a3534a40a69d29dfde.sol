
pragma solidity ^0.8.0;

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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

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
}//MIT
pragma solidity ^0.8.0;


abstract contract CardBase is Ownable, Pausable {
  mapping(address => bool) internal _authorizedAddressList;

  event EventGrantAuthorized(address auth_);
  event EventRevokeAuthorized(address auth_);

  modifier isOwner() {
    require(_msgSender() == owner(), "CardBase: not owner");
    _;
  }

  modifier isAuthorized() {
    require(
      _msgSender() == owner() || _authorizedAddressList[_msgSender()] == true,
      "CardBase: unauthorized"
    );
    _;
  }

  function grantAuthorized(address auth_) external isOwner {
    require(auth_ != address(0), "CardBase: invalid auth_ address ");

    _authorizedAddressList[auth_] = true;

    emit EventGrantAuthorized(auth_);
  }

  function revokeAuthorized(address auth_) external isOwner {
    require(auth_ != address(0), "CardBase: invalid auth_ address ");

    _authorizedAddressList[auth_] = false;

    emit EventRevokeAuthorized(auth_);
  }

  function pause() external isOwner {
    _pause();
  }

  function unpause() external isOwner {
    _unpause();
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

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


contract CardNft is ERC721Enumerable, CardBase {
  uint256 public _tokenId;

  uint256 public _burnCount; // count the number of burnt tokens

  string public _baseTokenURI;

  bool public _tokenTransferPaused;

  event EventMintCard(
    uint256 _tokenId,
    address _tokenOwner,
    uint256 _timestamp
  );

  event EventMintCardMany(
    uint256[] _tokenIdList,
    address _tokenOwner,
    uint256 _timestamp
  );

  event EventAirdrop(uint256 receiverListLength_);

  event EventBurnCard(address _tokenOwner, uint256 tokenId_);
  event EventAdminBurnCard(address _adminAddress, uint256 tokenId_);

  event EventSetTokenTransferPaused(bool tokenTransferPaused_);
  event EventSetBaseURI(string baseURI);
  event EventAdminTransferToken(uint256 tokenId_, address receiver_);

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _baseTokenLink
  ) ERC721(_name, _symbol) {
    _baseTokenURI = _baseTokenLink;
    _tokenTransferPaused = false;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId);

    require(_tokenTransferPaused == false, "CardNft: token transfer paused");
  }

  function setTokenTransferPaused(bool tokenTransferPaused_) external isOwner {
    _tokenTransferPaused = tokenTransferPaused_;

    emit EventSetTokenTransferPaused(tokenTransferPaused_);
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string memory baseURI) external isOwner {
    _baseTokenURI = baseURI;

    emit EventSetBaseURI(baseURI);
  }

  function tokenExists(uint256 tokenId_) external view returns (bool) {
    return _exists(tokenId_);
  }

  function getTokenIdsOfUserAddress(address _userAddr)
    external
    view
    returns (uint256[] memory)
  {
    uint256 tokenCount = balanceOf(_userAddr);

    uint256[] memory tokenIds = new uint256[](tokenCount);
    for (uint256 i = 0; i < tokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_userAddr, i);
    }
    return tokenIds;
  }

  function burnCard(uint256 tokenId_) external whenNotPaused {
    require(ownerOf(tokenId_) == _msgSender(), "CardNft: Not token owner");
    _burn(tokenId_);
    _burnCount += 1;
    emit EventBurnCard(_msgSender(), tokenId_);
  }

  function adminBurnCard(uint256 tokenId_) external whenNotPaused isOwner {
    _burn(tokenId_);
    _burnCount += 1;
    emit EventAdminBurnCard(_msgSender(), tokenId_);
  }

  function mintCard(address owner_)
    external
    whenNotPaused
    isAuthorized
    returns (uint256)
  {
    _tokenId = _tokenId + 1;
    _safeMint(owner_, _tokenId, "");

    emit EventMintCard(_tokenId, owner_, block.timestamp);

    return _tokenId;
  }

  function mintCardMany(address owner_, uint256 cardAmount_)
    external
    whenNotPaused
    isAuthorized
    returns (uint256[] memory)
  {
    uint256[] memory tokenIds = new uint256[](cardAmount_);

    for (uint256 i = 0; i < cardAmount_; i++) {
      _tokenId = _tokenId + 1;
      _safeMint(owner_, _tokenId, "");

      tokenIds[i] = _tokenId;
    }

    emit EventMintCardMany(tokenIds, owner_, block.timestamp);

    return tokenIds;
  }

  function airdrop(address[] calldata receiverList_)
    external
    whenNotPaused
    isAuthorized
  {
    for (uint256 i = 0; i < receiverList_.length; i++) {
      _tokenId = _tokenId + 1;
      _safeMint(receiverList_[i], _tokenId, "");
    }

    emit EventAirdrop(receiverList_.length);
  }

  function adminTransferToken(uint256 tokenId_, address receiver_)
    external
    isOwner
  {
    require(_exists(tokenId_), "CardNft: Token not exist");

    address tokenOwner = ownerOf(tokenId_);
    _safeTransfer(tokenOwner, receiver_, tokenId_, "");

    emit EventAdminTransferToken(tokenId_, receiver_);
  }

  function transfer(uint256 tokenId_, address receiver_) external {
    require(ownerOf(tokenId_) == _msgSender(), "CardNft: Not token owner");

    _safeTransfer(_msgSender(), receiver_, tokenId_, "");
  }
}// MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}// MIT
pragma solidity ^0.8.0;


abstract contract PriceConsumerV3 {
  AggregatorV3Interface public priceFeed;

  int256 private constant fakePrice = 2000 * 10**8; // remember to multiply by 10 ** 8

  constructor() {
    if (block.chainid == 1) {
      priceFeed = AggregatorV3Interface(
        0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
      );
    } else if (block.chainid == 4) {
      priceFeed = AggregatorV3Interface(
        0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
      );
    } else if (block.chainid == 56) {
      priceFeed = AggregatorV3Interface(
        0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
      );
    } else if (block.chainid == 97) {
      priceFeed = AggregatorV3Interface(
        0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
      );
    } else {
    }
  }

  function getThePrice() public view returns (int256) {
    if (
      block.chainid == 1 ||
      block.chainid == 4 ||
      block.chainid == 56 ||
      block.chainid == 97
    ) {
      (, int256 price, , , ) = priceFeed.latestRoundData();
      require(price > 0, "PriceConsumerV3: invalid price returned");
      return price;
    } else {
      return fakePrice;
    }
  }
}// MIT
pragma solidity ^0.8.0;


contract CardManager is PriceConsumerV3, CardBase, ReentrancyGuard {
  using SafeERC20 for IERC20;

  address payable public _beneficiary;

  uint256 public _totalAvaTokensCollected;
  uint256 public _totalNativeTokensCollected;

  IERC20 public immutable _avaToken;

  CardNft public immutable _cardNft;

  uint256 constant E18 = 10**18;

  uint256 public _cardPriceUsdCent;
  uint256 public _maxSupplyForSale = 900;

  bool public _purchaseInAvaEnabled = false;

  uint256 public _cardNumForSaleMinted;

  uint256 public _giveBackToCommunityPercent = 0;
  address payable public _communityPoolWallet;

  uint256 public _discountWhenBuyInAvaPercent = 5;

  uint256 public _avaTokenPriceInUsdCent; // 300 == 3 USD (i.e. 1 AVA costs 3 USD)

  mapping(address => uint256) public _maxAllowableCardsForPrivateSale;
  bool public _privateSaleEnabled = true;
  uint256 public _maxAllowableCardsForPublicSale = 1;
  mapping(address => uint256) public _cardNumPerWalletMinted;

  event EventBuyInAva(
    address buyer_,
    uint256[] mintedTokenIdList_,
    uint256 cardAmount_,
    uint256 totalAvaTokensToPay_
  );
  event EventBuyInNative(
    address buyer_,
    uint256[] mintedTokenIdList_,
    uint256 cardAmount_,
    uint256 totalToPay_
  );

  event EventMintAfterPayment(
    address buyer_,
    address minter_,
    uint256[] mintedTokenIdList_,
    uint256 cardAmount_
  );

  event EventSetCardPriceUsdCent(uint256 cardPriceUsdCent_);
  event EventSetPurchaseInAvaEnabled(bool purchaseInAvaEnabled_);
  event EventSetMaxSupplyForSale(uint256 maxSupplyForSale_);
  event EventSetGiveBackToCommunityPercent(uint256 giveBackToCommunityPercent_);
  event EventSetCommunityPoolWallet(address communityPoolWallet_);
  event EventSetDiscountWhenBuyInAvaPercent(
    uint256 discountWhenBuyInAvaPercent_
  );
  event EventSetAvaTokenPriceInUsdCent(uint256 avaTokenPriceInUsdCent_);
  event EventSetBeneficiary(address beneficiary_);
  event EventSetPrivateSaleEnabled(bool privateSaleEnabled_);
  event EventSetMaxAllowableCardsForPrivateSale(
    address wallet_,
    uint256 maxCards_
  );
  event EventBatchSetMaxAllowableCardsForPrivateSale(
    uint256 walletListLength,
    uint256 maxCardsListLength
  );
  event EventSetMaxAllowableCardsForPublicSale(
    uint256 maxAllowableCardsForPublicSale_
  );

  constructor(
    address avaTokenAddress_,
    address cardNftAddress_,
    address beneficiary_
  ) {
    require(
      avaTokenAddress_ != address(0),
      "CardManager: Invalid avaTokenAddress_ address"
    );

    require(
      cardNftAddress_ != address(0),
      "CardManager: Invalid cardNftAddress_ address"
    );

    require(
      beneficiary_ != address(0),
      "CardManager: Invalid beneficiary_ address"
    );

    _avaToken = IERC20(avaTokenAddress_);
    _cardNft = CardNft(cardNftAddress_);
    _beneficiary = payable(beneficiary_);
  }

  function checkIfCanBuy(address wallet_, uint256 cardAmount_)
    public
    view
    returns (bool)
  {
    require(
      (_cardNumForSaleMinted + cardAmount_) <= _maxSupplyForSale,
      "CardManager: Max supply for sale exceed"
    );

    if (_privateSaleEnabled) {
      require(
        _maxAllowableCardsForPrivateSale[wallet_] > 0,
        "CardManager: Not whitelisted wallet for private sale"
      );

      require(
        (_cardNumPerWalletMinted[wallet_] + cardAmount_) <=
          _maxAllowableCardsForPrivateSale[wallet_],
        "CardManager: max allowable cards per wallet for private sale exceed"
      );
    } else {
      require(
        (_cardNumPerWalletMinted[wallet_] + cardAmount_) <=
          _maxAllowableCardsForPublicSale,
        "CardManager: max allowable cards per wallet for public sale exceed"
      );
    }

    return true;
  }


  function setCardSaleInfo(
    uint256 cardPriceUsdCent_,
    uint256 maxSupplyForSale_,
    uint256 giveBackToCommunityPercent_,
    uint256 avaTokenPriceInUsdCent_,
    uint256 discountWhenBuyInAvaPercent_,
    address communityPoolWallet_
  ) external isOwner {
    setCardPriceUsdCent(cardPriceUsdCent_);
    setMaxSupplyForSale(maxSupplyForSale_);
    setGiveBackToCommunityPercent(giveBackToCommunityPercent_);
    setAvaTokenPriceInUsdCent(avaTokenPriceInUsdCent_);
    setDiscountWhenBuyInAvaPercent(discountWhenBuyInAvaPercent_);
    setCommunityPoolWallet(communityPoolWallet_);
  }

  function setCardPriceUsdCent(uint256 cardPriceUsdCent_) public isOwner {
    require(cardPriceUsdCent_ > 0, "CardManager: Invalid cardPriceUsdCent_");

    _cardPriceUsdCent = cardPriceUsdCent_;

    emit EventSetCardPriceUsdCent(cardPriceUsdCent_);
  }

  function setPurchaseInAvaEnabled(bool purchaseInAvaEnabled_)
    external
    isOwner
  {
    _purchaseInAvaEnabled = purchaseInAvaEnabled_;

    emit EventSetPurchaseInAvaEnabled(purchaseInAvaEnabled_);
  }

  function setMaxSupplyForSale(uint256 maxSupplyForSale_) public isOwner {
    require(
      maxSupplyForSale_ >= _cardNumForSaleMinted,
      "CardManager: Invalid maxSupplyForSale_"
    );

    _maxSupplyForSale = maxSupplyForSale_;

    emit EventSetMaxSupplyForSale(maxSupplyForSale_);
  }

  function setGiveBackToCommunityPercent(uint256 giveBackToCommunityPercent_)
    public
    isOwner
  {
    require(
      giveBackToCommunityPercent_ <= 100,
      "CardManager: Invalid giveBackToCommunityPercent_"
    );

    _giveBackToCommunityPercent = giveBackToCommunityPercent_;

    emit EventSetGiveBackToCommunityPercent(giveBackToCommunityPercent_);
  }

  function setCommunityPoolWallet(address communityPoolWallet_) public isOwner {
    _communityPoolWallet = payable(communityPoolWallet_);

    emit EventSetCommunityPoolWallet(communityPoolWallet_);
  }

  function setDiscountWhenBuyInAvaPercent(uint256 discountWhenBuyInAvaPercent_)
    public
    isOwner
  {
    require(
      discountWhenBuyInAvaPercent_ <= 100,
      "CardManager: Invalid discountWhenBuyInAvaPercent_"
    );

    _discountWhenBuyInAvaPercent = discountWhenBuyInAvaPercent_;

    emit EventSetDiscountWhenBuyInAvaPercent(discountWhenBuyInAvaPercent_);
  }

  function setAvaTokenPriceInUsdCent(uint256 avaTokenPriceInUsdCent_)
    public
    isAuthorized
  {
    _avaTokenPriceInUsdCent = avaTokenPriceInUsdCent_;

    emit EventSetAvaTokenPriceInUsdCent(avaTokenPriceInUsdCent_);
  }

  function setBeneficiary(address beneficiary_) external isOwner {
    require(
      beneficiary_ != address(0),
      "CardManager: Invalid beneficiary_ address"
    );
    _beneficiary = payable(beneficiary_);

    emit EventSetBeneficiary(beneficiary_);
  }

  function setPrivateSaleEnabled(bool privateSaleEnabled_) external isOwner {
    _privateSaleEnabled = privateSaleEnabled_;

    emit EventSetPrivateSaleEnabled(privateSaleEnabled_);
  }

  function setMaxAllowableCardsForPrivateSale(
    address wallet_,
    uint256 maxCards_
  ) public isAuthorized {
    require(wallet_ != address(0), "CardManager: Invalid wallet_ address");
    _maxAllowableCardsForPrivateSale[wallet_] = maxCards_;

    emit EventSetMaxAllowableCardsForPrivateSale(wallet_, maxCards_);
  }

  function batchSetMaxAllowableCardsForPrivateSale(
    address[] memory walletList_,
    uint256[] memory maxCardsList_
  ) external isAuthorized {
    require(
      walletList_.length == maxCardsList_.length,
      "CardManager: walletList_ and maxCardsList_ do not have same length"
    );

    for (uint256 i = 0; i < walletList_.length; i++) {
      setMaxAllowableCardsForPrivateSale(walletList_[i], maxCardsList_[i]);
    }

    emit EventBatchSetMaxAllowableCardsForPrivateSale(
      walletList_.length,
      maxCardsList_.length
    );
  }

  function setMaxAllowableCardsForPublicSale(
    uint256 maxAllowableCardsForPublicSale_
  ) external isOwner {
    require(
      maxAllowableCardsForPublicSale_ > 0,
      "CardManager: Invalid maxAllowableCardsForPublicSale_"
    );

    _maxAllowableCardsForPublicSale = maxAllowableCardsForPublicSale_;

    emit EventSetMaxAllowableCardsForPublicSale(
      maxAllowableCardsForPublicSale_
    );
  }


  function getCardSaleInfo()
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      address
    )
  {
    return (
      _cardPriceUsdCent,
      _maxSupplyForSale,
      _giveBackToCommunityPercent,
      _avaTokenPriceInUsdCent,
      _discountWhenBuyInAvaPercent,
      _communityPoolWallet
    );
  }

  function getNativeCoinPriceInUsdCent() public view returns (uint256) {
    uint256 nativeCoinPriceInUsdCent = uint256(getThePrice() / 10**6);
    return nativeCoinPriceInUsdCent;
  }

  function getCardPriceInAvaTokens() public view returns (uint256) {
    uint256 cardPriceInAvaTokens = (_cardPriceUsdCent * E18) /
      _avaTokenPriceInUsdCent;

    return cardPriceInAvaTokens;
  }

  function buyInAva(uint256 cardAmount_)
    external
    whenNotPaused
    nonReentrant
    returns (uint256[] memory)
  {
    require(_purchaseInAvaEnabled, "CardManager: buy in AVA disabled");

    require(cardAmount_ > 0, "CardManager: invalid cardAmount_");

    require(
      _avaTokenPriceInUsdCent > 0,
      "CardManager: AVA token price not set"
    );

    require(_cardPriceUsdCent > 0, "CardManager: invalid card price");

    uint256 cardPriceInAvaTokens = getCardPriceInAvaTokens();
    uint256 totalAvaTokensToPay = cardPriceInAvaTokens * cardAmount_;

    if (_discountWhenBuyInAvaPercent > 0) {
      totalAvaTokensToPay =
        totalAvaTokensToPay -
        ((totalAvaTokensToPay * _discountWhenBuyInAvaPercent) / 100);
    }

    require(
      totalAvaTokensToPay <= _avaToken.balanceOf(_msgSender()),
      "CardManager: user balance does not have enough AVA tokens"
    );

    checkIfCanBuy(_msgSender(), cardAmount_);

    uint256 giveBack = (totalAvaTokensToPay * _giveBackToCommunityPercent) /
      100;
    _avaToken.safeTransferFrom(
      _msgSender(),
      _beneficiary,
      totalAvaTokensToPay - giveBack
    );
    if (giveBack > 0 && _communityPoolWallet != address(0)) {
      _avaToken.safeTransferFrom(_msgSender(), _communityPoolWallet, giveBack);
    }

    _totalAvaTokensCollected += totalAvaTokensToPay;

    _cardNumPerWalletMinted[_msgSender()] += cardAmount_;
    _cardNumForSaleMinted += cardAmount_;

    uint256[] memory mintedTokenIdList = new uint256[](cardAmount_);

    if (cardAmount_ > 1) {
      mintedTokenIdList = _cardNft.mintCardMany(_msgSender(), cardAmount_);
    } else {
      uint256 mintedTokenId = _cardNft.mintCard(_msgSender());
      mintedTokenIdList[0] = mintedTokenId;
    }

    emit EventBuyInAva(
      _msgSender(),
      mintedTokenIdList,
      cardAmount_,
      totalAvaTokensToPay
    );

    return mintedTokenIdList;
  }

  function getCardPriceInNative() public view returns (uint256) {
    uint256 nativeCoinPriceInUsdCent = getNativeCoinPriceInUsdCent();

    uint256 cardPriceInNative = (_cardPriceUsdCent * E18) /
      nativeCoinPriceInUsdCent;

    return cardPriceInNative;
  }

  function buyInNative(uint256 cardAmount_)
    external
    payable
    whenNotPaused
    nonReentrant
    returns (uint256[] memory)
  {
    require(cardAmount_ > 0, "CardManager: invalid cardAmount_");

    require(_cardPriceUsdCent > 0, "CardManager: invalid card price");

    uint256 cardPriceInNative = getCardPriceInNative();
    uint256 totalToPay = cardPriceInNative * cardAmount_;

    require(
      msg.value >= totalToPay,
      "CardManager: user-transferred amount not enough"
    );

    checkIfCanBuy(_msgSender(), cardAmount_);

    uint256 giveBack = (msg.value * _giveBackToCommunityPercent) / 100;
    (bool success, ) = _beneficiary.call{ value: (msg.value - giveBack) }("");
    require(success, "CardManager: ETH transfer to beneficiary failed");

    if (giveBack > 0 && _communityPoolWallet != address(0)) {
      (bool success2, ) = _communityPoolWallet.call{ value: giveBack }("");
      require(
        success2,
        "CardManager: ETH transfer to communityPoolWallet failed"
      );
    }

    _totalNativeTokensCollected += msg.value;

    _cardNumPerWalletMinted[_msgSender()] += cardAmount_;
    _cardNumForSaleMinted += cardAmount_;

    uint256[] memory mintedTokenIdList = new uint256[](cardAmount_);

    if (cardAmount_ > 1) {
      mintedTokenIdList = _cardNft.mintCardMany(_msgSender(), cardAmount_);
    } else {
      uint256 mintedTokenId = _cardNft.mintCard(_msgSender());
      mintedTokenIdList[0] = mintedTokenId;
    }

    emit EventBuyInNative(
      _msgSender(),
      mintedTokenIdList,
      cardAmount_,
      msg.value
    );

    return mintedTokenIdList;
  }

  function mintAfterPayment(address buyer_, uint256 cardAmount_)
    external
    whenNotPaused
    nonReentrant
    isAuthorized
    returns (uint256[] memory)
  {
    require(cardAmount_ > 0, "CardManager: invalid cardAmount_");
    require(buyer_ != address(0), "CardManager: invalid buyer_");

    checkIfCanBuy(buyer_, cardAmount_);

    _cardNumPerWalletMinted[buyer_] += cardAmount_;
    _cardNumForSaleMinted += cardAmount_;

    uint256[] memory mintedTokenIdList = new uint256[](cardAmount_);

    if (cardAmount_ > 1) {
      mintedTokenIdList = _cardNft.mintCardMany(buyer_, cardAmount_);
    } else {
      uint256 mintedTokenId = _cardNft.mintCard(buyer_);
      mintedTokenIdList[0] = mintedTokenId;
    }

    emit EventMintAfterPayment(
      buyer_,
      _msgSender(),
      mintedTokenIdList,
      cardAmount_
    );

    return mintedTokenIdList;
  }

  function getCurrentPrice() public view returns (int256) {
    return getThePrice() / 10**8;
  }
}