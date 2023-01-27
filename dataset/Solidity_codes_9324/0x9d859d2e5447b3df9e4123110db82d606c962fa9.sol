
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


interface IAccessControlEnumerable {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}

abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
                return retval == IERC721Receiver(to).onERC721Received.selector;
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


abstract contract ERC721Burnable is Context, ERC721 {
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Pausable is ERC721, Pausable {
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
}// UNLICENSED
pragma solidity 0.8.4;
pragma abicoder v2;


struct RoyaltySplit {
    address payable royaltyReceiver;
    uint8 royaltyPercentage;
}

contract Ainsoph3 is
    Context,
    AccessControlEnumerable,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant MARKETPLACE_ROLE = keccak256("MARKETPLACE_ROLE");

    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    uint8 public constant MARKETPLACE_FEE_PERCENTAGE = 5;

    address payable public marketplaceFeeAddress;

    string private _baseTokenURI;

    struct Piece {
        address payable royaltyReceiver;
        bool openTradingAllowed;
        RoyaltySplit[] royaltySplits;
    }

    mapping(uint256 => Piece) public pieceList;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        address payable initialMarketplaceFeeAddress
    ) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());

        marketplaceFeeAddress = initialMarketplaceFeeAddress;
    }

    function mintAsset(
        uint256 tokenId,
        address owner,
        address payable publicRoyaltyReceiver,
        RoyaltySplit[] memory royaltySplits
    ) public virtual whenNotPaused {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "must have minter role to mint"
        );

        pieceList[tokenId].royaltyReceiver = publicRoyaltyReceiver;
        pieceList[tokenId].openTradingAllowed = false;

        uint8 totalRoyaltyPercentage = 0;

        for (uint256 i = 0; i < royaltySplits.length; i++) {
            totalRoyaltyPercentage += royaltySplits[i].royaltyPercentage;

            pieceList[tokenId].royaltySplits.push(royaltySplits[i]);
        }

        require(totalRoyaltyPercentage <= 100, "royalties cannot be > 100%");

        _mint(owner, tokenId);
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        Piece storage piece = pieceList[tokenId];

        uint8 totalRoyaltyPercentage = _totalRoyaltyPercentage(
            piece.royaltySplits
        );

        return (
            piece.royaltyReceiver,
            (salePrice * totalRoyaltyPercentage) / 100
        );
    }

    function verifyRoyalties(
        uint256 tokenId,
        uint8 marketplaceFeePercentage,
        RoyaltySplit[] calldata royaltySplitsToVerify
    ) external view {
        Piece storage piece = pieceList[tokenId];

        require(
            marketplaceFeePercentage >= MARKETPLACE_FEE_PERCENTAGE,
            "marketplace fee is too low"
        );

        bool receiverFound;

        for (
            uint256 royaltyIndex = 0;
            royaltyIndex < piece.royaltySplits.length;
            royaltyIndex++
        ) {
            receiverFound = false;

            for (
                uint256 verifyIndex = 0;
                verifyIndex < royaltySplitsToVerify.length;
                verifyIndex++
            ) {
                if (
                    piece.royaltySplits[royaltyIndex].royaltyReceiver ==
                    royaltySplitsToVerify[verifyIndex].royaltyReceiver
                ) {
                    require(
                        piece.royaltySplits[royaltyIndex].royaltyPercentage <=
                            royaltySplitsToVerify[verifyIndex]
                            .royaltyPercentage,
                        "royalty percentage is too low"
                    );
                    receiverFound = true;
                }
            }

            require(receiverFound, "missing royalty receiver");
        }
    }

    function distributeRoyalties(uint256 tokenId)
        external
        payable
        whenNotPaused
    {
        Piece storage piece = pieceList[tokenId];

        uint256 marketplaceFee = msg.value;
        uint256 royaltyValue;

        uint256 totalPrice = (msg.value * 100) /
            _totalRoyaltyPercentage(piece.royaltySplits);

        for (uint256 i = 0; i < piece.royaltySplits.length; i++) {
            royaltyValue =
                (totalPrice * piece.royaltySplits[i].royaltyPercentage) /
                100;

            marketplaceFee -= royaltyValue;

            payable(piece.royaltySplits[i].royaltyReceiver).transfer(
                royaltyValue
            );
        }

        marketplaceFeeAddress.transfer(marketplaceFee);
    }

    function royaltyReceiverCount(uint256 tokenId)
        external
        view
        returns (uint256)
    {
        return pieceList[tokenId].royaltySplits.length + 1;
    }

    function royaltyReceiver(uint256 tokenId, uint256 index)
        external
        view
        returns (address, uint8)
    {
        if (index == pieceList[tokenId].royaltySplits.length) {
            return (marketplaceFeeAddress, MARKETPLACE_FEE_PERCENTAGE);
        } else {
            RoyaltySplit storage royaltySplit = pieceList[tokenId]
            .royaltySplits[index];
            return (
                royaltySplit.royaltyReceiver,
                royaltySplit.royaltyPercentage
            );
        }
    }

    function setOpenTrading(uint256 tokenId, bool openTradingAllowed)
        public
        whenNotPaused
    {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role"
        );

        pieceList[tokenId].openTradingAllowed = openTradingAllowed;
    }

    function pause() public virtual {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role to pause"
        );
        _pause();
    }

    function unpause() public virtual {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role to unpause"
        );
        _unpause();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return
            interfaceId == _INTERFACE_ID_ERC2981 ||
            super.supportsInterface(interfaceId);
    }

    function changeBaseURI(string memory baseTokenURI) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role"
        );

        _baseTokenURI = baseTokenURI;
    }

    function changeMarketplaceFeeRecipient(
        address payable newMarketplaceFeeAddress
    ) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role"
        );

        marketplaceFeeAddress = newMarketplaceFeeAddress;
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        override
        returns (bool)
    {
        return
            (hasRole(MARKETPLACE_ROLE, spender) ||
                pieceList[tokenId].openTradingAllowed) &&
            super._isApprovedOrOwner(spender, tokenId);
    }

    function _totalRoyaltyPercentage(RoyaltySplit[] memory royaltySplits)
        internal
        pure
        returns (uint8)
    {
        uint8 totalRoyaltyPercentage = MARKETPLACE_FEE_PERCENTAGE;

        for (uint256 i = 0; i < royaltySplits.length; i++) {
            totalRoyaltyPercentage += royaltySplits[i].royaltyPercentage;
        }

        return totalRoyaltyPercentage;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}// UNLICENSED
pragma solidity 0.8.4;



contract IllustMarketplace3 is Context, AccessControlEnumerable, Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PRIMARY_SALE_ROLE = keccak256("PRIMARY_SALE_ROLE");

    struct WinningBid {
        bool enabled;
        address payable winner;
        uint256 price;
        bool complete;
    }

    struct PrimarySaleRoyalties {
        bool firstSale;
        uint8 marketplaceFee;
        RoyaltySplit[] royaltySplits;
    }

    struct OpenEdition {
        bool wasOpen;
        bool isOpen;
        address artist;
        uint256 index;
        uint256 price;
        uint256 max;
        RoyaltySplit[] primaryRoyaltySplits;
        RoyaltySplit[] secondaryRoyaltySplits;
    }

    address public tokenContract;

    address payable public marketplaceFeeAddress;

    mapping(uint256 => PrimarySaleRoyalties) public primarySaleRoyaltyList;
    mapping(uint256 => WinningBid) public winningBids;

    mapping(uint256 => OpenEdition) public openEditions;

    constructor(
        address initialTokenContract,
        address payable initialMarketplaceFeeAddress
    ) {
        tokenContract = initialTokenContract;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PRIMARY_SALE_ROLE, _msgSender());

        marketplaceFeeAddress = initialMarketplaceFeeAddress;
    }

    function createOpenEdition(
        uint256 tokenId,
        address artist,
        uint256 price,
        uint256 max,
        RoyaltySplit[] calldata primaryRoyaltySplits,
        RoyaltySplit[] calldata secondaryRoyaltySplits
    ) public whenNotPaused {
        require(hasRole(MINTER_ROLE, _msgSender()), "must have minter role");

        OpenEdition storage openEdition = openEditions[tokenId];

        openEdition.wasOpen = true;
        openEdition.isOpen = true;
        openEdition.artist = artist;
        openEdition.price = price;
        openEdition.max = max;

        delete openEdition.primaryRoyaltySplits;
        delete openEdition.secondaryRoyaltySplits;

        for (uint256 i = 0; i < primaryRoyaltySplits.length; i++) {
            openEdition.primaryRoyaltySplits.push(primaryRoyaltySplits[i]);
        }

        for (uint256 i = 0; i < secondaryRoyaltySplits.length; i++) {
            openEdition.secondaryRoyaltySplits.push(secondaryRoyaltySplits[i]);
        }
    }

    function closeOpenEdition(uint256 tokenId) public whenNotPaused {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role"
        );

        openEditions[tokenId].isOpen = false;
    }

    function mintOpenEdition(uint256 tokenId) public payable whenNotPaused {
        OpenEdition storage openEdition = openEditions[tokenId];

        Ainsoph3 AinsophContract = Ainsoph3(tokenContract);

        require(openEdition.isOpen == true, "minting is closed");

        require(
            AinsophContract.isApprovedForAll(openEdition.artist, address(this)),
            "Artist must approve transfers"
        );

        require(msg.value == openEdition.price, "Please send more eth");

        require(
            openEdition.index < openEdition.max || openEdition.max == 0,
            "no more pieces available"
        );

        openEdition.index += 1;

        uint256 openTokenId = tokenId + openEdition.index;

        AinsophContract.mintAsset(
            openTokenId,
            openEdition.artist,
            marketplaceFeeAddress,
            openEdition.secondaryRoyaltySplits
        );

        AinsophContract.transferFrom(
            openEdition.artist,
            _msgSender(),
            openTokenId
        );

        uint256 royaltyPayment;
        uint256 marketplaceFee = msg.value;
        for (uint8 i = 0; i < openEdition.primaryRoyaltySplits.length; i++) {
            royaltyPayment =
                (msg.value *
                    openEdition.primaryRoyaltySplits[i].royaltyPercentage) /
                100;

            marketplaceFee -= royaltyPayment;

            openEdition.primaryRoyaltySplits[i].royaltyReceiver.transfer(
                royaltyPayment
            );
        }

        marketplaceFeeAddress.transfer(marketplaceFee);
    }

    function acceptBid(
        uint256 asset,
        uint256 price,
        address payable winner
    ) public whenNotPaused {
        Ainsoph3 AinsophContract = Ainsoph3(tokenContract);

        require(
            _msgSender() == AinsophContract.ownerOf(asset),
            "Sender must own asset"
        );
        require(
            AinsophContract.isApprovedForAll(_msgSender(), address(this)),
            "Seller must approve transfers"
        );

        winningBids[asset] = WinningBid(true, winner, price, false);
    }

    function pay(uint256 tokenId) public payable whenNotPaused {
        WinningBid storage winningBid = winningBids[tokenId];

        require(winningBid.enabled == true, "Seller has not accepted a bid.");
        require(winningBid.complete == false, "This auction has ended");
        require(
            winningBid.winner == _msgSender(),
            "This is not the winning address"
        );
        require(msg.value == winningBid.price, "Please send more eth");
        Ainsoph3 AinsophContract = Ainsoph3(tokenContract);

        address owner = AinsophContract.ownerOf(tokenId);

        require(owner != winningBid.winner, "Owner can not be winner");

        PrimarySaleRoyalties storage asset = primarySaleRoyaltyList[tokenId];

        uint256 sellerPayment = msg.value;
        uint256 royaltyAmount;

        uint256 royaltyLength = asset.royaltySplits.length;

        uint256[] memory royaltyPayments;

        uint256 marketplaceFee;

        if (asset.firstSale) {

            royaltyLength = asset.royaltySplits.length;
            royaltyPayments = new uint256[](royaltyLength);

            uint256 royaltyPayment;

            marketplaceFee = (msg.value * asset.marketplaceFee) / 100;
            sellerPayment -= marketplaceFee;

            for (uint8 i = 0; i < royaltyLength; i++) {
                royaltyPayment =
                    (msg.value * asset.royaltySplits[i].royaltyPercentage) /
                    100;

                sellerPayment -= royaltyPayment;

                royaltyPayments[i] = royaltyPayment;
            }
        } else {
            (, royaltyAmount) = AinsophContract.royaltyInfo(tokenId, msg.value);

            sellerPayment -= royaltyAmount;
        }

        AinsophContract.safeTransferFrom(
            AinsophContract.ownerOf(tokenId),
            _msgSender(),
            tokenId
        );

        winningBid.complete = true;

        if (asset.firstSale) {
            asset.firstSale = false;

            marketplaceFeeAddress.transfer(marketplaceFee);

            for (uint8 i = 0; i < royaltyLength; i++) {
                asset.royaltySplits[i].royaltyReceiver.transfer(
                    royaltyPayments[i]
                );
            }
        } else {
            AinsophContract.distributeRoyalties{value: royaltyAmount}(tokenId);
        }

        payable(owner).transfer(sellerPayment);
    }

    function setRoyalties(
        uint256 tokenId,
        uint8 marketplaceFeePercentage,
        RoyaltySplit[] calldata primaryRoyaltySplits
    ) public payable {
        require(
            hasRole(PRIMARY_SALE_ROLE, _msgSender()),
            "must have primary sale role"
        );

        Ainsoph3 AinsophContract = Ainsoph3(tokenContract);
        AinsophContract.verifyRoyalties(
            tokenId,
            marketplaceFeePercentage,
            primaryRoyaltySplits
        );

        PrimarySaleRoyalties storage primarySale = primarySaleRoyaltyList[
            tokenId
        ];

        primarySale.firstSale = true;
        primarySale.marketplaceFee = marketplaceFeePercentage;
        delete primarySale.royaltySplits;

        uint8 totalRoyaltyPercentage = 0;

        for (uint256 i = 0; i < primaryRoyaltySplits.length; i++) {
            totalRoyaltyPercentage += primaryRoyaltySplits[i].royaltyPercentage;

            primarySaleRoyaltyList[tokenId].royaltySplits.push(
                primaryRoyaltySplits[i]
            );
        }

        require(totalRoyaltyPercentage <= 100, "royalties cannot be > 100%");
    }

    function setAinsophContract(address payable newTokenContractAddress)
        public
    {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role"
        );

        tokenContract = newTokenContractAddress;
    }

    function changeMarketplaceFeeRecipient(
        address payable newMarketplaceFeeAddress
    ) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role"
        );

        marketplaceFeeAddress = newMarketplaceFeeAddress;
    }

    function pause() public virtual {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role to pause"
        );
        _pause();
    }

    function unpause() public virtual {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "must have admin role to unpause"
        );
        _unpause();
    }
}