
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
pragma solidity >=0.4.22 <0.9.0;


contract PermissionManagement {

  address public founder = msg.sender;
  address payable public beneficiary = payable(msg.sender);

  mapping(address => bool) public admins;
  mapping(address => bool) public moderators;

  enum RoleChange { 
    MADE_FOUNDER, 
    MADE_BENEFICIARY, 
    PROMOTED_TO_ADMIN, 
    PROMOTED_TO_MODERATOR, 
    DEMOTED_TO_MODERATOR, 
    KICKED_FROM_TEAM
  }

  event PermissionsModified(address _address, RoleChange _roleChange);

  constructor (
    address[] memory _admins, 
    address[] memory _moderators
  ) {
    uint256 adminsLength = _admins.length;
    require(adminsLength > 0, "no admin addresses");

    admins[founder] = true;
    moderators[founder] = true;
    emit PermissionsModified(founder, RoleChange.MADE_FOUNDER);

    for (uint256 i = 0; i < adminsLength; i++) {
      admins[_admins[i]] = true;
      moderators[_admins[i]] = true;
      emit PermissionsModified(_admins[i], RoleChange.PROMOTED_TO_ADMIN);
    }

    uint256 moderatorsLength = _moderators.length;
    for (uint256 i = 0; i < moderatorsLength; i++) {
      moderators[_moderators[i]] = true;
      emit PermissionsModified(_moderators[i], RoleChange.PROMOTED_TO_MODERATOR);
    }
  }

  modifier founderOnly() {

    require(
      msg.sender == founder,
      "not a founder."
    );
    _;
  }

  modifier adminOnly() {

    require(
      admins[msg.sender] == true,
      "not an admin"
    );
    _;
  }

  modifier moderatorOnly() {

    require(
      moderators[msg.sender] == true,
      "not a moderator"
    );
    _;
  }

  modifier addressMustNotBeFounder(address _address) {

    require(
      _address != founder,
      "address is founder"
    );
    _;
  }

  modifier addressMustNotBeAdmin(address _address) {

    require(
      admins[_address] != true,
      "address is admin"
    );
    _;
  }

  modifier addressMustNotBeModerator(address _address) {

    require(
      moderators[_address] != true,
      "address is moderator"
    );
    _;
  }

  modifier addressMustNotBeBeneficiary(address _address) {

    require(
      _address != beneficiary,
      "address is beneficiary"
    );
    _;
  }

  function founderOnlyMethod(address _address) external view {

    require(
      _address == founder,
      "not a founder."
    );
  }

  function adminOnlyMethod(address _address) external view {

    require(
      admins[_address] == true,
      "not an admin"
    );
  }

  function moderatorOnlyMethod(address _address) external view {

    require(
      moderators[_address] == true,
      "not a moderator"
    );
  }

  function addressMustNotBeFounderMethod(address _address) external view {

    require(
      _address != founder,
      "address is founder"
    );
  }

  function addressMustNotBeAdminMethod(address _address) external view {

    require(
      admins[_address] != true,
      "address is admin"
    );
  }

  function addressMustNotBeModeratorMethod(address _address) external view {

    require(
      moderators[_address] != true,
      "address is moderator"
    );
  }

  function addressMustNotBeBeneficiaryMethod(address _address) external view {

    require(
      _address != beneficiary,
      "address is beneficiary"
    );
  }

  function transferFoundership(address payable _founder) 
    external 
    founderOnly
    addressMustNotBeFounder(_founder)
    returns(address)
  {

    require(_founder != msg.sender, "not yourself");
    
    founder = _founder;
    admins[_founder] = true;
    moderators[_founder] = true;

    emit PermissionsModified(_founder, RoleChange.MADE_FOUNDER);

    return founder;
  }

  function changeBeneficiary(address payable _beneficiary) 
    external
    adminOnly
    returns(address)
  {

    require(_beneficiary != msg.sender, "not yourself");
    
    beneficiary = _beneficiary;
    emit PermissionsModified(_beneficiary, RoleChange.MADE_BENEFICIARY);

    return beneficiary;
  }

  function addAdmin(address _admin) 
    external 
    adminOnly
    returns(address) 
  {

    admins[_admin] = true;
    moderators[_admin] = true;
    emit PermissionsModified(_admin, RoleChange.PROMOTED_TO_ADMIN);
    return _admin;
  }

  function removeAdmin(address _admin) 
    external 
    adminOnly
    addressMustNotBeFounder(_admin)
    returns(address) 
  {

    require(_admin != msg.sender, "not yourself");
    delete admins[_admin];
    emit PermissionsModified(_admin, RoleChange.DEMOTED_TO_MODERATOR);
    return _admin;
  }

  function addModerator(address _moderator) 
    external 
    adminOnly
    returns(address) 
  {

    moderators[_moderator] = true;
    emit PermissionsModified(_moderator, RoleChange.PROMOTED_TO_MODERATOR);
    return _moderator;
  }

  function removeModerator(address _moderator) 
    external 
    adminOnly
    addressMustNotBeFounder(_moderator)
    addressMustNotBeAdmin(_moderator)
    returns(address) 
  {

    require(_moderator != msg.sender, "not yourself");
    delete moderators[_moderator];
    emit PermissionsModified(_moderator, RoleChange.KICKED_FROM_TEAM);
    return _moderator;
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


        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {

        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
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

}// ISC
pragma solidity >=0.4.22 <0.9.0;


abstract contract AdminOps is ERC721 {
  PermissionManagement private permissionManagement;

  constructor (
    address _permissionManagementContractAddress
  ) {
    permissionManagement = PermissionManagement(_permissionManagementContractAddress);
  }


  function marketTransfer(address _from, address _to, uint256 _tokenId) 
    public 
    returns(uint256)
  {
    permissionManagement.adminOnlyMethod(msg.sender);
    _transfer(_from, _to, _tokenId);
    return _tokenId;
  }

  function godlyMint(address _to, uint256 _tokenId) 
    public
    returns(uint256)
  {
    permissionManagement.adminOnlyMethod(msg.sender);
    _safeMint(_to, _tokenId);
    return _tokenId;
  }

  function godlyBurn(uint256 _tokenId) 
    public
    returns(uint256)
  {
    permissionManagement.adminOnlyMethod(msg.sender);
    _burn(_tokenId);
    return _tokenId;
  }

  function godlyApprove(address _to, uint256 _tokenId) 
    public
    returns(uint256)
  {
    permissionManagement.adminOnlyMethod(msg.sender);
    _approve(_to, _tokenId);
    return _tokenId;
  }

  function godlyApproveForAll(address _owner, address _operator, bool _shouldApprove) 
    public
    returns(address)
  {
    permissionManagement.adminOnlyMethod(msg.sender);
    _setApprovalForAll(_owner, _operator, _shouldApprove);
    return _owner;
  }
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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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
}// ISC
pragma solidity >=0.4.22 <0.9.0;


abstract contract Payable {
  PermissionManagement internal permissionManagement;

  constructor (
    address _permissionManagementContractAddress
  ) {
    permissionManagement = PermissionManagement(_permissionManagementContractAddress);
  }

  event ReceivedFunds(
    address indexed by,
    uint256 fundsInwei,
    uint256 timestamp
  );

  event SentToBeneficiary(
    address indexed actionCalledBy,
    address indexed beneficiary,
    uint256 fundsInwei,
    uint256 timestamp
  );

  event ERC20SentToBeneficiary(
    address indexed actionCalledBy,
    address indexed beneficiary,
    address indexed erc20Token,
    uint256 tokenAmount,
    uint256 timestamp
  );

  event ERC721SentToBeneficiary(
    address indexed actionCalledBy,
    address indexed beneficiary,
    address indexed erc721ContractAddress,
    uint256 tokenId,
    uint256 timestamp
  );

  function getBalance() public view returns(uint256) {
    return address(this).balance;
  }

  function fund() external payable {
    emit ReceivedFunds(msg.sender, msg.value, block.timestamp);
  }

  fallback() external virtual payable {
    emit ReceivedFunds(msg.sender, msg.value, block.timestamp);
  }

  receive() external virtual payable {
    emit ReceivedFunds(msg.sender, msg.value, block.timestamp);
  }

  function sendToBeneficiary(uint256 _amountInWei) external returns(uint256) {
    permissionManagement.adminOnlyMethod(msg.sender);

    (bool success, ) = payable(permissionManagement.beneficiary()).call{value: _amountInWei}("");
    require(success, "Transfer to Beneficiary failed.");
    
    emit SentToBeneficiary(msg.sender, permissionManagement.beneficiary(), _amountInWei, block.timestamp);
    return _amountInWei;
  }

  function sendERC20ToBeneficiary(address _erc20address, uint256 _tokenAmount) external returns(address, uint256) {
    permissionManagement.adminOnlyMethod(msg.sender);

    IERC20 erc20Token;
    erc20Token = IERC20(_erc20address);

    erc20Token.transfer(permissionManagement.beneficiary(), _tokenAmount);

    emit ERC20SentToBeneficiary(msg.sender, permissionManagement.beneficiary(), _erc20address, _tokenAmount, block.timestamp);

    return (_erc20address, _tokenAmount);
  }

  function sendERC721ToBeneficiary(address _erc721address, uint256 _tokenId) external returns(address, uint256) {
    permissionManagement.adminOnlyMethod(msg.sender);

    IERC721 erc721Token;
    erc721Token = IERC721(_erc721address);

    erc721Token.safeTransferFrom(address(this), permissionManagement.beneficiary(), _tokenId);

    emit ERC721SentToBeneficiary(msg.sender, permissionManagement.beneficiary(), _erc721address, _tokenId, block.timestamp);

    return (_erc721address, _tokenId);
  }
}// ISC
pragma solidity >=0.4.22 <0.9.0;


abstract contract NFT is AdminOps, ERC721Enumerable, Payable {
  constructor (
    string memory name_, 
    string memory symbol_,
    address _permissionManagementContractAddress,
    string memory contractURI_
  )
  ERC721(name_, symbol_)
  AdminOps(_permissionManagementContractAddress)
  Payable(_permissionManagementContractAddress)
  {
    _contractURI = contractURI_;
  }

  string public baseURI = ""; //-> could have been "https://monument.app/artifacts/"

  function _baseURI() internal view virtual override(ERC721) returns (string memory) {
    return baseURI;
  }

  function changeBaseURI(string memory baseURI_) public returns (string memory) {
    permissionManagement.adminOnlyMethod(msg.sender);
    baseURI = baseURI_;
    return baseURI;
  }

  string _contractURI = "";

  function contractURI() public view returns (string memory) {
    return _contractURI;
  }

  function changeContractURI(string memory contractURI_) public returns (string memory) {
    permissionManagement.adminOnlyMethod(msg.sender);
    _contractURI = contractURI_;
    return contractURI_;
  }

  function exists(uint256 tokenId) public view returns (bool) {
    return _exists(tokenId);
  }

  function godlySetTokenURI(uint256 _tokenId, string memory _tokenURI) 
    public
    returns(uint256)
  {
    permissionManagement.adminOnlyMethod(msg.sender);
    _setTokenURI(_tokenId, _tokenURI);
    return _tokenId;
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  mapping(uint256 => string) private _tokenURIs;

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
      require(_exists(tokenId), "URI query for nonexistent token");

      string memory _tokenURI = _tokenURIs[tokenId];
      string memory base = _baseURI();

      if (bytes(base).length == 0) {
          return _tokenURI;
      }
      
      if (bytes(_tokenURI).length > 0) {
          return string(abi.encodePacked(base, _tokenURI));
      }

      return super.tokenURI(tokenId);
  }

  function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
      require(_exists(tokenId), "URI set of nonexistent token");
      _tokenURIs[tokenId] = _tokenURI;
  }

  function _burn(uint256 tokenId) internal virtual override {
      super._burn(tokenId);

      if (bytes(_tokenURIs[tokenId]).length != 0) {
          delete _tokenURIs[tokenId];
      }
  }
}// ISC
pragma solidity >=0.4.22 <0.9.0;


abstract contract Taxes {
  PermissionManagement private permissionManagement;

  constructor (
    address _permissionManagementContractAddress
  ) {
    permissionManagement = PermissionManagement(_permissionManagementContractAddress);
  }

  event TaxesChanged (
    uint256 newTaxOnMintingAnArtifact,
    address indexed actionedBy
  );

  uint256 public taxOnMintingAnArtifact; // `26 * (10 ** 13)` was around $1 in Oct 2021

  function setTaxes(uint256 _onMintingArtifact)
    external
    returns (uint256)
  {
    permissionManagement.adminOnlyMethod(msg.sender);

    taxOnMintingAnArtifact = _onMintingArtifact;

    emit TaxesChanged (
      _onMintingArtifact,
      msg.sender
    );

    return _onMintingArtifact;
  }

  function _chargeArtifactTax()
    internal
    returns (bool)
  {
    require(
      msg.value >= taxOnMintingAnArtifact || 
      permissionManagement.moderators(msg.sender), // moderators dont pay taxes
      "Insufficient amount sent"
    );

    if (msg.value >= taxOnMintingAnArtifact) {
      (bool success, ) = permissionManagement.beneficiary().call{value: taxOnMintingAnArtifact}("");
      require(success, "Transfer to Beneficiary failed");
    }
    
    return true;
  }
}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {
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

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}// ISC
pragma solidity ^0.8.0;


contract Splits is Initializable, ReentrancyGuardUpgradeable {
    mapping(address => uint256) public royalties;

    address[] public splitters;
    uint256[] public permyriads;

    constructor () {
    }

    function initialize(
        address[] memory _splitters,
        uint256[] memory _permyriads
    )
        public 
        payable
        initializer
    {
        require(_splitters.length == _permyriads.length);

        uint256 _totalPermyriad;

        uint256 splittersLength = _splitters.length;

        for (uint256 i = 0; i < splittersLength; i++) {
            require(_splitters[i] != address(0));
            require(_permyriads[i] > 0);
            require(_permyriads[i] <= 10000);
            _totalPermyriad += _permyriads[i];
        }

        require(_totalPermyriad == 10000, "Total permyriad must be 10000");

        for (uint256 i = 0; i < splittersLength; i++) {
            royalties[_splitters[i]] = _permyriads[i];
        }

        splitters = _splitters;
        permyriads = _permyriads;
    }

    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

    event ReceivedFunds(
        address indexed by,
        uint256 fundsInwei,
        uint256 timestamp
    );
    event SentSplit(
        address indexed from,
        address indexed to,
        uint256 fundsInwei,
        uint256 timestamp
    );
    event Withdrew (
        address indexed actionedBy,
        address indexed to,
        uint256 amount,
        uint256 timestamp
    );

    fallback() external virtual payable {
        emit ReceivedFunds(msg.sender, msg.value, block.timestamp);
        distributeFunds();
    }

    receive() external virtual payable {
        emit ReceivedFunds(msg.sender, msg.value, block.timestamp);
        distributeFunds();
    }

    function mulScale (uint256 x, uint256 y, uint128 scale)
    internal
    pure 
    returns (uint256) {
        uint256 a = x / scale;
        uint256 b = x % scale;
        uint256 c = y / scale;
        uint256 d = y % scale;

        return a * c * scale + a * d + b * c + b * d / scale;
    }

    function distributeFunds() public nonReentrant payable {
        uint256 balance = msg.value;

        require(balance > 0, "zero balance");

        emit ReceivedFunds (msg.sender, balance, block.timestamp);

        uint256 splittersLength = splitters.length;
        for (uint256 i = 0; i < splittersLength; i++) {
            uint256 value = mulScale(permyriads[i], balance, 10000);

            (bool success, ) = payable(splitters[i]).call{value: value}("");
            require(success, "Transfer failed");

            emit SentSplit (msg.sender, splitters[i], value, block.timestamp);
        }
    }

    function royaltySplitInfo(address _address) external view returns (uint256) {
        uint256 royaltyPermyriad = royalties[_address];
        return royaltyPermyriad;
    }
}// MIT

pragma solidity ^0.8.0;

library Clones {
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}// ISC
pragma solidity ^0.8.0;


contract SplitsFactory is Payable, ReentrancyGuard {
    address public splitsContractAddress;
    address[] public allProxies;

    event NewProxy (address indexed contractAddress, address indexed createdBy, uint256 timestamp);

    constructor (
        address _splitsContractAddress, 
        address _permissionManagementContractAddress
    ) 
    Payable(_permissionManagementContractAddress) 
    {
        splitsContractAddress = _splitsContractAddress;
    }

    function _clone() internal returns (address result) {
        bytes20 targetBytes = bytes20(splitsContractAddress);

        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }

        require(result != address(0), "ERC1167: clone failed");
    }

    function createProxy(
        address[] memory _splitters,
        uint256[] memory _permyriads
    ) external nonReentrant returns (address result) {
        address proxy = _clone();
        allProxies.push(proxy);
        Splits(payable(proxy)).initialize(_splitters, _permyriads);
        emit NewProxy (proxy, msg.sender, block.timestamp);
        return proxy;
    }

    function changeSplitsContractAddress(address _splitsContractAddress) 
        external
        nonReentrant
        returns(address)
    {
        permissionManagement.adminOnlyMethod(msg.sender);
        splitsContractAddress = _splitsContractAddress;
        return _splitsContractAddress;
    }
}// ISC
pragma solidity >=0.8.0 <0.9.0;


contract MonumentArtifacts is NFT, Taxes, ReentrancyGuard {
  address public splitsFactoryContractAddress;

  constructor(
    string memory name_, 
    string memory symbol_,
    address _permissionManagementContractAddress,
    address _splitsFactoryContractAddress,
    string memory contractURI_
  )
  NFT(name_, symbol_, _permissionManagementContractAddress, contractURI_)
  Taxes(_permissionManagementContractAddress)
  payable
  {
    _mintArtifact("https://monument.app/artifacts/0.json", 1, 1, block.timestamp);
    splitsFactoryContractAddress = _splitsFactoryContractAddress;
  }




  using Counters for Counters.Counter;
  Counters.Counter public totalArtifacts;
  Counters.Counter public totalTokensMinted;




  struct Artifact {
    uint256 id;
    string metadata;
    uint256 totalSupply;
    uint256 initialSupply;
    uint256 currentSupply;
    uint256 blockTimestamp;
    uint256 artifactTimestamp;
    address author;
  }
  Artifact[] public artifacts;

  mapping(address => uint256[]) public getArtifactIDsByAuthor;

  function getArtifactAuthor(uint256 artifactId) public view virtual returns (address author) {
    return artifacts[artifactId].author;
  }

  function getArtifactSupply(uint256 artifactId) 
    public
    view
    virtual
    returns (
      uint256 totalSupply,
      uint256 currentSupply,
      uint256 initialSupply
    ) {
    return (
      artifacts[artifactId].totalSupply,
      artifacts[artifactId].currentSupply,
      artifacts[artifactId].initialSupply
    );
  }

  mapping(uint256 => uint256[]) public getTokenIDsByArtifactID;
  mapping(uint256 => uint256) public getArtifactIDByTokenID;
  mapping(address => uint256[]) public getTokenIDsByAuthor;
  mapping(uint256 => address) public getAuthorByTokenID;

  mapping(string => bool) public artifactMetadataExists;
  mapping(string => uint256) public getArtifactIDByMetadata;

  mapping(uint256 => uint256) public getRoyaltyPermyriadByArtifactID;

  mapping(uint256 => uint256[]) public getForksOfArtifact;
  mapping(uint256 => uint256) public getArtifactForkedFrom;

  mapping(uint256 => address[]) public getMentionsByArtifactID;
  mapping(address => uint256[]) public getArtifactsMentionedInByAddress;




  struct RoyaltyInfo {
    address receiver;
    uint256 percent; // it's actually a permyriad (parts per ten thousand)
  }
  mapping(uint256 => RoyaltyInfo) public getRoyaltyInfoByArtifactId;

  function royaltyInfo(uint256 _tokenID, uint256 _salePrice)
  	external
  	view
  	returns (address receiver, uint256 royaltyAmount)
  {
    RoyaltyInfo memory rInfo = getRoyaltyInfoByArtifactId[getArtifactIDByTokenID[_tokenID]];
	if (rInfo.receiver == address(0)) return (address(0), 0);
	uint256 amount = _salePrice * rInfo.percent / 10000;
	return (payable(rInfo.receiver), amount);
  }

  function royaltyInfoByArtifactId(uint256 _artifactID, uint256 _salePrice)
  	external
  	view
  	returns (address receiver, uint256 royaltyAmount)
  {
    RoyaltyInfo memory rInfo = getRoyaltyInfoByArtifactId[_artifactID];
	if (rInfo.receiver == address(0)) return (address(0), 0);
	uint256 amount = _salePrice * rInfo.percent / 10000;
	return (payable(rInfo.receiver), amount);
  }




  event ArtifactMinted (
    uint256 indexed id,
    string metadata,
    uint256 totalSupply,
    uint256 initialSupply,
    address indexed author,
    uint256 paidAmount,
    uint256 timestamp
  );
  event EditionsMinted (
    uint256 indexed artifactId,
    uint256 editions,
    address indexed mintedTo,
    address indexed mintedBy,
    uint256 timestamp
  );
  event EditionsAirdropped (
    uint256 indexed artifactId,
    uint256 editions,
    address[] mintedTo,
    address indexed mintedby,
    uint256 timestamp
  );




  modifier editionChecks(uint256 artifactID, uint256 editions) {
    require(artifacts[artifactID].blockTimestamp > 0, "Invalid artifactID");

    require(
        permissionManagement.moderators(msg.sender) ||
        artifacts[artifactID].author == msg.sender,
        "unauthorized call"
    );

    require(
        editions + artifacts[artifactID].currentSupply <= artifacts[artifactID].totalSupply, 
        "totalSupply exhausted"
    );

    _;
  }





  function mintArtifact(
      string memory metadata,
      uint256 totalSupply,
      uint256 initialSupply,
      address[] memory mentions,
      uint256 forkOf,
      uint256 artifactTimestamp,
      uint256 royaltyPermyriad,
      address[] memory splitBeneficiaries,
      uint256[] memory permyriadsCorrespondingToSplitBeneficiaries
    )
    external
    payable
    nonReentrant
    returns (uint256 _artifactID)
  {
    require(royaltyPermyriad >= 0 && royaltyPermyriad <= 10000, "Invalid Royalty Permyriad value");

    uint256 splitBeneficiariesLength = splitBeneficiaries.length;
    require(splitBeneficiariesLength == permyriadsCorrespondingToSplitBeneficiaries.length, "Invalid Beneficiary Data");

    uint256 _totalPermyriad;
    for (uint256 i = 0; i < splitBeneficiariesLength; i++) {
      require(splitBeneficiaries[i] != address(0));
      require(permyriadsCorrespondingToSplitBeneficiaries[i] > 0);
      require(permyriadsCorrespondingToSplitBeneficiaries[i] <= 10000);
      _totalPermyriad += permyriadsCorrespondingToSplitBeneficiaries[i];
    }
    require(_totalPermyriad == 10000, "Total Permyriad must be 10000");

    require(bytes(metadata).length > 0, "Empty Metadata");

    require(artifactMetadataExists[metadata] != true, "Artifact already minted");

    require(artifacts[forkOf].blockTimestamp > 0, "Invalid forkOf Artifact");

    require(totalSupply != 0, "Supply must be non-zero");

    require(initialSupply <= totalSupply, "invalid initialSupply");

    _chargeArtifactTax();

	uint256 artifactID = _mintArtifact(metadata, totalSupply, initialSupply, artifactTimestamp);
	getRoyaltyPermyriadByArtifactID[artifactID] = royaltyPermyriad;

    if (royaltyPermyriad == 0) {
      getRoyaltyInfoByArtifactId[artifactID] = RoyaltyInfo(address(0), 0);
    } else {
      address splitsProxyAddress = SplitsFactory(payable(splitsFactoryContractAddress)).createProxy(splitBeneficiaries, permyriadsCorrespondingToSplitBeneficiaries);

      getRoyaltyInfoByArtifactId[artifactID] = RoyaltyInfo(splitsProxyAddress, royaltyPermyriad);
    }

    getMentionsByArtifactID[artifactID] = mentions;
    uint256 mentionsLength = mentions.length;
    for (uint256 i = 0; i < mentionsLength; i++) {
      getArtifactsMentionedInByAddress[mentions[i]].push(artifactID);
    }

    getForksOfArtifact[forkOf].push(artifactID);
    getArtifactForkedFrom[artifactID] = forkOf;

    return artifactID;
  }


  function airdropEditions(
      uint256 artifactID,
      address[] memory addresses
    )
    external
    payable
    nonReentrant
    editionChecks(artifactID, addresses.length)
    returns (
      uint256 _artifactID,
      address[] memory _addresses
    )
  {
    for (uint256 i = 0; i < addresses.length; i++) {
        _mintTokens(artifactID, 1, addresses[i]);
    }

    emit EditionsAirdropped(artifactID, addresses.length, _addresses, msg.sender, block.timestamp);

    return (artifactID, addresses);
  }


  function mintEditions(
      uint256 artifactID,
      uint256 editions,
      address mintTo
    )
    external
    payable
    nonReentrant
    editionChecks(artifactID, editions)
    returns (
      uint256 _artifactID,
      uint256 _editions,
      address _mintedTo
    )
  {
    _mintTokens(artifactID, editions, mintTo);

    emit EditionsMinted(artifactID, editions, mintTo, msg.sender, block.timestamp);

    return (artifactID, editions, mintTo);
  }





  function _mintArtifact(
    string memory metadata,
    uint256 totalSupply,
    uint256 initialSupply,
    uint256 artifactTimestamp
  )
    internal
    returns (uint256 _artifactID)
  {
    uint256 newId = totalArtifacts.current();
    totalArtifacts.increment();

    artifacts.push(
      Artifact(
        newId,
        metadata,
        totalSupply,
        initialSupply,
        0, // current supply will initially be zero, it'll increase live as this function mints
        block.timestamp,
        artifactTimestamp,
        msg.sender
      )
    );
    artifactMetadataExists[metadata] = true;
    getArtifactIDByMetadata[metadata] = newId;
    getArtifactIDsByAuthor[msg.sender].push(newId);

    _mintTokens(newId, initialSupply, msg.sender);

    emit ArtifactMinted (
      newId,
      metadata,
      totalSupply,
      initialSupply,
      msg.sender,
      msg.value,
      block.timestamp
    );

    return newId;
  }


  function _mintTokens(
    uint256 artifactID,
    uint256 amount,
    address mintTo
  )
    internal
    returns (
      uint256 _artifactID,
      uint256 _amount,
      address _mintedTo
    )
  {
    for (uint256 i = 0; i < amount; i++) {
      uint256 newTokenId = totalTokensMinted.current();
      totalTokensMinted.increment();

      _safeMint(mintTo, newTokenId);
      _setTokenURI(newTokenId, artifacts[artifactID].metadata);
      
      getTokenIDsByArtifactID[artifactID].push(newTokenId);
      getArtifactIDByTokenID[newTokenId] = artifactID;

      getTokenIDsByAuthor[artifacts[artifactID].author].push(newTokenId);
      getAuthorByTokenID[newTokenId] = artifacts[artifactID].author;

      artifacts[artifactID].currentSupply = artifacts[artifactID].currentSupply + 1;
    }

    return (artifactID, amount, mintTo);
  }
}// ISC
pragma solidity >=0.8.0 <0.9.0;


contract MonumentMarketplace is Payable, ReentrancyGuard {
  constructor (
    address _permissionManagementContractAddress,
    address payable _allowedNFTContractAddress
  )
  Payable(_permissionManagementContractAddress)
  payable
  {
    require(_allowedNFTContractAddress != address(0));
    allowedNFTContractAddress = _allowedNFTContractAddress;
    allowedNFTContract = MonumentArtifacts(_allowedNFTContractAddress);

    _enableAuction(10 ** 18, 0, 0);

    _placeOrder(0, 60);
    orders[0].tokenId = 10 ** 18;
    orders[0].price = 0;
  }




  mapping(address => uint256) public credits;

  function withdraw (
    uint256 _amount,
    address _to
  ) nonReentrant external {
      require(_amount <= credits[_to], "insufficient balance");
      require(
        msg.sender == _to ||
        permissionManagement.moderators(msg.sender) == true,
        "unauthorised withdrawal"
      );

      credits[_to] = credits[_to] - _amount;

      (bool success, ) = payable(_to).call{value: _amount}("");
      require(success, "withdrawal failed");

      emit Withdrew (msg.sender, _to, _amount, block.timestamp);
  }



  using Counters for Counters.Counter;
  Counters.Counter public totalAuctions;




  address public allowedNFTContractAddress;
  MonumentArtifacts allowedNFTContract;
  
  function changeAllowedNFTContract(address payable _nftContractAddress) 
    external
    returns(address)
  {
    permissionManagement.adminOnlyMethod(msg.sender);
    allowedNFTContractAddress = _nftContractAddress;
    allowedNFTContract = MonumentArtifacts(_nftContractAddress);
    return _nftContractAddress;
  }




  uint256 public taxOnEverySaleInPermyriad;

  function changeTaxOnEverySaleInPermyriad(uint256 _taxOnEverySaleInPermyriad) 
    external
    returns(uint256)
  {
    permissionManagement.adminOnlyMethod(msg.sender);
    require(_taxOnEverySaleInPermyriad <= 10000, "permyriad value out of bounds");
    taxOnEverySaleInPermyriad = _taxOnEverySaleInPermyriad;
    return _taxOnEverySaleInPermyriad;
  }




  event EnabledAuction(
    uint256 indexed id,
    uint256 indexed _tokenId,
    uint256 _basePrice,
    uint256 _auctionExpiryTime,
    address indexed _enabledBy,
    uint256 _timestamp
  );
  event EndedAuction(
    uint256 indexed id,
    uint256 indexed _tokenId,
    address indexed _endedBy,
    uint256 _timestamp
  );
  event ListedEditions(
    uint256 indexed _artifactId,
    uint256 _editions,
    uint256 _price,
    uint256 _timestamp,
    address indexed _listedBy
  );
  event UnlistedEditions(
    uint256 indexed _artifactId,
    uint256 _timestamp,
    address indexed _unlistedBy
  );
  event EnabledAutoSell(
    uint256 indexed _tokenId,
    uint256 _price,
    address indexed _enabledBy,
    uint256 _timestamp
  );
  event DisabledAutoSell(
    uint256 indexed _tokenId,
    address indexed _disabledBy,
    uint256 _timestamp
  );
  event OrderPlaced(
    uint256 indexed id,
    address indexed buyer,
    uint256 indexed tokenId,
    uint256 price,
    uint256 createdAt,
    uint256 expiresAt
  );
  event OrderExecuted(
    uint256 indexed id,
    uint256 indexed tokenId,
    uint256 timestamp,
    address executedBy,
    address indexed priorOwner
  );
  event OrderCancelled(
    uint256 indexed id,
    uint256 indexed tokenId,
    uint256 timestamp,
    address indexed cancelledBy
  );
  event EditionsBought(
    uint256 indexed artifactId,
    address indexed buyer,
    uint256 editions,
    uint256 pricePerEdition,
    uint256 timestamp
  );
  event Withdrew (
    address indexed actionedBy,
    address indexed to,
    uint256 amount,
    uint256 timestamp
  );





  struct Auction {
    uint256 id;
    uint256 tokenId;
    uint256 basePrice;
    uint256 highestBidOrderId;
    uint256 startTime;
    uint256 expiryTime;
  }
  Auction[] public auctions;

  mapping(uint256 => uint256) public getTokenPrice;
  mapping(uint256 => bool) public isTokenAutoSellEnabled;

  mapping(uint256 => uint256) public getEditionsPrice;
  mapping(uint256 => uint256) public howManyEditionsAutoSellEnabled;

  mapping(uint256 => bool) public isTokenAuctionEnabled;
  mapping(uint256 => uint256) public getLatestAuctionIDByTokenID;
  mapping(uint256 => uint256[]) public getAuctionIDsByTokenID;

  function listEditions(
    uint256 _artifactId,
    uint256 _editions,
    uint256 _pricePerEdition
  ) nonReentrant external returns (uint256, uint256) {
    require(
      allowedNFTContract.getArtifactAuthor(_artifactId) == msg.sender ||
      permissionManagement.moderators(msg.sender) == true, 
      "unauthorized listEditions"
    );

    (
      uint256 totalSupply, 
      uint256 currentSupply,
    ) = allowedNFTContract.getArtifactSupply(_artifactId);

    require(
      _editions <= totalSupply - currentSupply, 
      "supply out of bounds"
    );

    howManyEditionsAutoSellEnabled[_artifactId] = _editions;
    getEditionsPrice[_artifactId] = _pricePerEdition;

    emit ListedEditions(
      _artifactId,
      _editions,
      _pricePerEdition,
      block.timestamp,
      msg.sender
    );

    return (_artifactId, _pricePerEdition);
  }

  function unlistEditions(
    uint256 _artifactId
  ) nonReentrant external returns (uint256) {
    require(
      allowedNFTContract.getArtifactAuthor(_artifactId) == msg.sender ||
      permissionManagement.moderators(msg.sender) == true, 
      "unauthorized unlistEditions"
    );

    howManyEditionsAutoSellEnabled[_artifactId] = 0;

    emit UnlistedEditions(
      _artifactId,
      block.timestamp,
      msg.sender
    );

    return _artifactId;
  }

  function enableAuction(
    uint256[] memory _tokenIds,
    uint256 _basePrice,
    uint256 _auctionExpiresIn
  ) nonReentrant external returns(uint256[] memory, uint256) {
    uint256 tokensLength = _tokenIds.length;
    for (uint256 i = 0; i < tokensLength; i++) {
      uint256 _tokenId = _tokenIds[i];

      require(
        (
          allowedNFTContract.ownerOf(_tokenId) == msg.sender ||
          allowedNFTContract.getApproved(_tokenId) == msg.sender ||
          permissionManagement.moderators(msg.sender) == true
        ) && allowedNFTContract.exists(_tokenId) == true, 
        "unauthorized enableAuction"
      );

      require(isTokenAuctionEnabled[_tokenId] != true, "token already in auction");

      _enableAuction(
        _tokenId,
        _basePrice,
        _auctionExpiresIn
      );
    }

    return (_tokenIds, _basePrice);
  }

  function _enableAuction(
    uint256 _tokenId,
    uint256 _basePrice,
    uint256 _auctionExpiresIn
  ) private returns(uint256, uint256, uint256) {
    getTokenPrice[_tokenId] = _basePrice;
    isTokenAutoSellEnabled[_tokenId] = false;

    uint256 newAuctionId = totalAuctions.current();
    totalAuctions.increment();

    isTokenAuctionEnabled[_tokenId] = true;
    auctions.push(
      Auction(
        newAuctionId,
        _tokenId,
        _basePrice,
        0,
        block.timestamp,
        block.timestamp + _auctionExpiresIn
      )
    );
    getLatestAuctionIDByTokenID[_tokenId] = newAuctionId;
    getAuctionIDsByTokenID[_tokenId].push(newAuctionId);

    emit EnabledAuction(
      newAuctionId,
      _tokenId,
      _basePrice,
      block.timestamp + _auctionExpiresIn,
      msg.sender,
      block.timestamp
    );

    return (_tokenId, _basePrice, _auctionExpiresIn);
  }

  function executeAuction(
    uint256 _tokenId
  ) nonReentrant external returns(uint256, uint256) {
    require(isTokenAuctionEnabled[_tokenId] == true && allowedNFTContract.exists(_tokenId) == true, "token not auctioned");

    if (block.timestamp <= auctions[getLatestAuctionIDByTokenID[_tokenId]].expiryTime) {
      require(
        permissionManagement.moderators(msg.sender) == true || 
        allowedNFTContract.ownerOf(_tokenId) == msg.sender || 
        allowedNFTContract.getApproved(_tokenId) == msg.sender, 
        "you cant execute this auction just yet"
      );

    } else {
      require(
        permissionManagement.moderators(msg.sender) == true || 
        allowedNFTContract.ownerOf(_tokenId) == msg.sender || 
        allowedNFTContract.getApproved(_tokenId) == msg.sender ||
        orders[auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId].buyer == msg.sender,
        "you cant execute this auction"
      );
    }

    return _executeAuction(_tokenId);
  }

  function _executeAuction(
    uint256 _tokenId
  ) private returns(uint256, uint256) {
    uint256 _orderId;
    if (auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId != 0) {
        if (
          orders[
            auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId
          ].price
            >=
          auctions[getLatestAuctionIDByTokenID[_tokenId]].basePrice
        ) {
          _orderId = _executeOrder(auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId);

          allowedNFTContract.marketTransfer(
            allowedNFTContract.ownerOf(_tokenId),
            orders[auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId].buyer, 
            _tokenId
          );
        }
    }

    isTokenAutoSellEnabled[_tokenId] = false;
    isTokenAuctionEnabled[_tokenId] = false;

    emit EndedAuction(
      getLatestAuctionIDByTokenID[_tokenId],
      _tokenId,
      msg.sender,
      block.timestamp
    );
    
    return (_tokenId, _orderId);
  }

  function enableAutoSell(
    uint256[] memory _tokenIds,
    uint256 _pricePerToken
  ) nonReentrant external returns(uint256[] memory, uint256) {
    uint256 tokensLength = _tokenIds.length;
    for (uint256 i = 0; i < tokensLength; i++) {
      uint256 _tokenId = _tokenIds[i];

      require(allowedNFTContract.exists(_tokenId) == true, "invalid tokenId");

      require(
        allowedNFTContract.ownerOf(_tokenId) == msg.sender ||
        allowedNFTContract.getApproved(_tokenId) == msg.sender ||
        permissionManagement.moderators(msg.sender) == true, 
        "unauthorized enableAutoSell"
      );

      require(isTokenAuctionEnabled[_tokenId] != true, "token already in auction");

      getTokenPrice[_tokenId] = _pricePerToken;
      isTokenAutoSellEnabled[_tokenId] = true;
      isTokenAuctionEnabled[_tokenId] = false;

      emit EnabledAutoSell(
        _tokenId,
        _pricePerToken,
        msg.sender,
        block.timestamp
      );
    }

    return (_tokenIds, _pricePerToken);
  }

  function disableAutoSell(
    uint256[] memory _tokenIds
  ) nonReentrant external returns(uint256[] memory) {
    uint256 tokensLength = _tokenIds.length;
    for (uint256 i = 0; i < tokensLength; i++) {
      uint256 _tokenId = _tokenIds[i];

      require(
        allowedNFTContract.ownerOf(_tokenId) == msg.sender ||
        allowedNFTContract.getApproved(_tokenId) == msg.sender ||
        permissionManagement.moderators(msg.sender) == true, 
        "unauthorized disableAutoSell"
      );

      require(isTokenAuctionEnabled[_tokenId] != true, "token is in an auction");

      _disableAutoSell(_tokenId);
    }

    return _tokenIds;
  }

  function _disableAutoSell(
    uint256 _tokenId
  ) internal returns(uint256) {
    isTokenAutoSellEnabled[_tokenId] = false;
    isTokenAuctionEnabled[_tokenId] = false;

    emit DisabledAutoSell(
      _tokenId,
      msg.sender,
      block.timestamp
    );

    return _tokenId;
  }





  struct Order {
    uint256 id;
    address payable buyer;
    uint256 tokenId;
    uint256 price;
    uint256 createdAt;
    uint256 expiresAt;
    address payable placedBy;
    bool isDuringAuction;
  }

  enum OrderStatus { INVALID, PLACED, EXECUTED, CANCELLED }

  Order[] public orders;

  mapping (uint256 => uint256[]) public getOrderIDsByTokenID;

  mapping (uint256 => OrderStatus) public getOrderStatus;





  function _placeOrder(
    uint256 _tokenId,
    uint256 _expireInSeconds
  ) private returns(uint256) {
    require(allowedNFTContract.ownerOf(_tokenId) != msg.sender, "not on your own token");

    uint256 _orderId = orders.length;

    Order memory _order = Order({
      id: _orderId,
      buyer: payable(msg.sender),
      tokenId: _tokenId,
      price: msg.value,
      createdAt: block.timestamp,
      expiresAt: block.timestamp + _expireInSeconds,
      placedBy: payable(msg.sender),
      isDuringAuction: isTokenAuctionEnabled[_tokenId]
    });

    orders.push(_order);
    getOrderIDsByTokenID[_tokenId].push(_order.id);
    getOrderStatus[_orderId] = OrderStatus.PLACED;

    if (msg.value > orders[auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId].price) {
      auctions[getLatestAuctionIDByTokenID[_tokenId]].highestBidOrderId = _orderId;
    }

    emit OrderPlaced(
      _order.id,
      _order.buyer,
      _order.tokenId,
      _order.price,
      _order.createdAt,
      _order.expiresAt
    );

    return _orderId;
  }

  function _placeOffer(
    uint256 _tokenId,
    uint256 _expireInSeconds,
    address _buyer,
    uint256 _price
  ) private returns(uint256) {
    require(allowedNFTContract.exists(_tokenId) == true, "invalid tokenId");
    require(
      allowedNFTContract.ownerOf(_tokenId) == msg.sender || 
      allowedNFTContract.getApproved(_tokenId) == msg.sender ||
      permissionManagement.moderators(msg.sender) == true, 
      "you cant offer this token"
    );
    require(_buyer != msg.sender, "cant offer yourself");

    uint256 _orderId = orders.length;

    Order memory _order = Order({
      id: _orderId,
      buyer: payable(_buyer),
      tokenId: _tokenId,
      price: _price,
      createdAt: block.timestamp,
      expiresAt: block.timestamp + _expireInSeconds,
      placedBy: payable(msg.sender),
      isDuringAuction: isTokenAuctionEnabled[_tokenId]
    });

    orders.push(_order);
    getOrderIDsByTokenID[_tokenId].push(_order.id);
    getOrderStatus[_orderId] = OrderStatus.PLACED;

    emit OrderPlaced(
      _order.id,
      _order.buyer,
      _order.tokenId,
      _order.price,
      _order.createdAt,
      _order.expiresAt
    );

    return _orderId;
  }

  function _executeOrder(
    uint256 _orderId
  ) private returns(uint256) {
    require(getOrderStatus[_orderId] != OrderStatus.CANCELLED, "order already cancelled");
    require(getOrderStatus[_orderId] != OrderStatus.EXECUTED, "order already executed");

    require(
      block.timestamp <= orders[_orderId].expiresAt || 
      (
        orders[_orderId].isDuringAuction == true && 
        auctions[getLatestAuctionIDByTokenID[orders[_orderId].tokenId]].highestBidOrderId == _orderId
      ), 
      "order expired"
    );

    require(orders[_orderId].price <= msg.value || orders[_orderId].price <= getBalance(), "insufficient contract balance");

    if (orders[_orderId].price != 0) {
      (
        address royaltyReceiver, 
        uint256 royaltyAmount
      ) = allowedNFTContract.royaltyInfo(
        orders[_orderId].tokenId,
        orders[_orderId].price
      );

      if (royaltyAmount != 0 && royaltyReceiver != address(0)) {
        (bool success1, ) = payable(royaltyReceiver).call{value: royaltyAmount}("");
        require(success1, "transfer to splits failed");
      }

      uint256 beneficiaryPay = (orders[_orderId].price - royaltyAmount) * taxOnEverySaleInPermyriad / 10000;

      (bool success2, ) = permissionManagement.beneficiary().call{value: beneficiaryPay}("");
      require(success2, "transfer to beneficiary failed");

      credits[allowedNFTContract.ownerOf(orders[_orderId].tokenId)] = credits[allowedNFTContract.ownerOf(orders[_orderId].tokenId)] + orders[_orderId].price - beneficiaryPay - royaltyAmount;
    }

    getOrderStatus[_orderId] = OrderStatus.EXECUTED;

    _disableAutoSell(orders[_orderId].tokenId);

    emit OrderExecuted(_orderId, orders[_orderId].tokenId, block.timestamp, msg.sender, allowedNFTContract.ownerOf(orders[_orderId].tokenId));

    return _orderId;
  }

  function _cancelOrder(
    uint256 _orderId
  ) private returns(uint256) {
    require(getOrderStatus[_orderId] == OrderStatus.PLACED, "never placed");

    getOrderStatus[_orderId] = OrderStatus.CANCELLED;

    if (orders[_orderId].price != 0 && orders[_orderId].placedBy == orders[_orderId].buyer) {
      credits[orders[_orderId].buyer] = credits[orders[_orderId].buyer] + orders[_orderId].price;
    }

    emit OrderCancelled(_orderId, orders[_orderId].tokenId, block.timestamp, msg.sender);

    return _orderId;
  }





  function buyEditions(
    uint256 _artifactId,
    uint256 _editions
  ) nonReentrant external payable returns(uint256) {
    if (_editions == 0) {
      _editions = 1;
    }

    require(howManyEditionsAutoSellEnabled[_artifactId] >= _editions, "autosale editions exhausted");

    require(msg.value >= getEditionsPrice[_artifactId] * _editions, "insufficient amount");

    allowedNFTContract.mintEditions(_artifactId, _editions, msg.sender);

    howManyEditionsAutoSellEnabled[_artifactId] = howManyEditionsAutoSellEnabled[_artifactId] - _editions;

    if (msg.value > 0) {
      uint256 totalPayable = msg.value;

      (
        address royaltyReceiver, 
        uint256 royaltyAmount
      ) = allowedNFTContract.royaltyInfoByArtifactId(
          _artifactId,
          getEditionsPrice[_artifactId] * _editions
        );

      if (royaltyAmount != 0 && royaltyReceiver != address(0)) {
        (bool success1, ) = payable(royaltyReceiver).call{value: royaltyAmount}("");
        require(success1, "transfer to splits failed");
      }

      uint256 beneficiaryPay = (totalPayable - royaltyAmount) * taxOnEverySaleInPermyriad / 10000;

      (bool success2, ) = permissionManagement.beneficiary().call{value: beneficiaryPay}("");
      require(success2, "transfer to beneficiary failed");

      credits[allowedNFTContract.getArtifactAuthor(_artifactId)] = credits[allowedNFTContract.getArtifactAuthor(_artifactId)] + totalPayable - beneficiaryPay - royaltyAmount;
    }

    emit EditionsBought(
      _artifactId,
      msg.sender,
      _editions,
      getEditionsPrice[_artifactId],
      block.timestamp
    );

    return _artifactId;
  }

  function placeOrder(
    uint256 _tokenId,
    uint256 _expireInSeconds
  ) nonReentrant external payable returns(uint256) {
    require(_expireInSeconds >= 60, "not within 60 seconds");
    require(msg.value >= 1, "a non-zero value must be paid");

    uint256 _orderId = _placeOrder(_tokenId, _expireInSeconds);

    address payable tokenOwner = payable(allowedNFTContract.ownerOf(_tokenId));

    if (isTokenAutoSellEnabled[_tokenId] == true) {
      if (getTokenPrice[_tokenId] == 0) {
        _executeOrder(_orderId);
        allowedNFTContract.marketTransfer(tokenOwner, msg.sender, _tokenId);
        return _orderId;
      }

      if (msg.value >= getTokenPrice[_tokenId]) {
        _executeOrder(_orderId);
        allowedNFTContract.marketTransfer(tokenOwner, msg.sender, _tokenId);
        return _orderId;
      }
    }

    return _orderId;
  }

  function placeOffer(
    uint256 _tokenId,
    uint256 _expireInSeconds,
    address _buyer,
    uint256 _price
  ) nonReentrant external returns(uint256) {
    require(_expireInSeconds >= 60, "not within 60 seconds");

    require(isTokenAuctionEnabled[_tokenId] != true, "cant offer tokens during auction");

    uint256 _orderId = _placeOffer(_tokenId, _expireInSeconds, _buyer, _price);

    return _orderId;
  }

  function acceptOffer(
    uint256 _orderId
  ) nonReentrant external payable returns(uint256) {
    Order memory _order = orders[_orderId];
    address tokenOwner = allowedNFTContract.ownerOf(_order.tokenId);
    address tokenApprovedAddress = allowedNFTContract.getApproved(_order.tokenId);

    require(_order.placedBy != msg.sender, "you cant accept your own offer");

    require(isTokenAuctionEnabled[_order.tokenId] != true, "cant accept during auction");

    if (_order.placedBy == _order.buyer) {
      require(
        tokenOwner == msg.sender || 
        tokenApprovedAddress == msg.sender ||
        permissionManagement.moderators(msg.sender) == true, 
        "only token owner can accept this offer"
      );

      _executeOrder(_orderId);
      allowedNFTContract.marketTransfer(tokenOwner, _order.buyer, _order.tokenId);
    } else {
      require(_order.buyer == msg.sender, "you werent offered");
      require(_order.placedBy == tokenOwner, "incompatible token owner");

      require(msg.value >= _order.price, "insufficient amount sent");

      _executeOrder(_orderId);
      allowedNFTContract.marketTransfer(tokenOwner, _order.buyer, _order.tokenId);

      return _orderId;
    }

    return _orderId;
  }

  function cancelOffer(
    uint256 _orderId
  ) nonReentrant external returns(uint256) {
    Order memory _order = orders[_orderId];
    address tokenOwner = allowedNFTContract.ownerOf(_order.tokenId);
    address tokenApprovedAddress = allowedNFTContract.getApproved(_order.tokenId);

    require(_order.createdAt > 0, "invalid orderId");

    require(
      _order.placedBy == msg.sender || 
      tokenOwner == msg.sender || 
      tokenApprovedAddress == msg.sender ||
      permissionManagement.moderators(msg.sender) == true, 
      "you cant cancel this offer"
    );

    if (
        auctions[getLatestAuctionIDByTokenID[_order.tokenId]].highestBidOrderId == _orderId &&
        _order.isDuringAuction == true &&
        _order.price >= auctions[getLatestAuctionIDByTokenID[_order.tokenId]].basePrice
    ) {
      revert("highest bid cant be cancelled during an Auction");
    }

    _cancelOrder(_orderId);

    return _orderId;
  }
}