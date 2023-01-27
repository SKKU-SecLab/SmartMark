
pragma solidity ^0.8.8;


interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}

interface IAccessControlEnumerable is IAccessControl {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
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

    function grantRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}

interface IItemFactory {


    function totalSupply(uint256 boxType) external view returns (uint256);


    function addItem(
        uint256 boxType,
        uint256 itemId,
        uint256 rarity,
        uint256 itemInitialLevel,
        uint256 itemInitialExperience
    ) external;


    function getRandomItem(uint256 randomness, uint256 boxType)
        external
        view
        returns (uint256 itemId);


    function getItemInitialLevel(uint256[] memory boxTypes, uint256[] memory itemIds)
        external
        view
        returns (uint256);


    function getItemInitialExperience(uint256[] memory boxTypes, uint256[] memory itemIds)
        external
        view
        returns (uint256);


    event ItemAdded(
        uint256 indexed boxType,
        uint256 indexed itemId,
        uint256 rarity,
        uint256 itemInitialLevel,
        uint256 itemInitialExperience
    );

    event ItemUpdated(
        uint256 indexed boxType,
        uint256 indexed itemId,
        uint256 rarity,
        uint256 itemInitialLevel,
        uint256 itemInitialExperience
    );

}

contract ItemFactoryManager {

    IItemFactory public itemFactory;

    event ItemFactoryUpdated(address itemFactory_);

    constructor(address itemFactory_) {
        _updateItemFactory(itemFactory_);
    }

    function _updateItemFactory(address itemFactory_) internal {

        itemFactory = IItemFactory(itemFactory_);
        emit ItemFactoryUpdated(itemFactory_);
    }
}

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

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

}

abstract contract Ownable is Context {
    address private _owner;
    address private _potentialOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnerNominated(address potentialOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function potentialOwner() public view returns (address) {
        return _potentialOwner;
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

    function nominatePotentialOwner(address newOwner) public virtual onlyOwner {
        _potentialOwner = newOwner;
        emit OwnerNominated(newOwner);
    }

    function acceptOwnership () public virtual {
        require(msg.sender == _potentialOwner, 'You must be nominated as potential owner before you can accept ownership');
        emit OwnershipTransferred(_owner, _potentialOwner);
        _owner = _potentialOwner;
        _potentialOwner = address(0);
    }
}

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}

abstract contract ERC721Burnable is Context, ERC721 {
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}

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
}

abstract contract ERC721Pausable is ERC721, Pausable {
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
}

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

contract ChatPuppyNFTCore is
    Ownable,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable
{
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;
    uint256 private _cap;

    struct Item {
        bytes32 dna;
        uint256 artifacts;
    }

    mapping(uint256 => Item) private _items;

    mapping(uint256 => string) private _tokenURIs;

    event CapUpdated(uint256 cap);
    event UpdateTokenURI(uint256 indexed tokenId, string tokenURI);
    event UpdateMetadata(uint256 indexed tokenId, bytes32 dna, uint256 artifacts);
    event UpdateMetadata(uint256 indexed tokenId, uint256 artifacts);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialCap_
    ) ERC721(name_, symbol_) {
        require(initialCap_ > 0, "ChatPuppyNFTCore: cap is 0");
        _updateCap(initialCap_);
        _tokenIdTracker.increment();
    }

    function _mint(address to_, uint256 tokenId_) internal virtual override {
        require(
            ERC721Enumerable.totalSupply() < cap(),
            "ChatPuppyNFTCore: cap exceeded"
        );
        super._mint(to_, tokenId_);
    }

    function _updateCap(uint256 cap_) private {
        _cap = cap_;
        emit CapUpdated(cap_);
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from_, to_, tokenId_);
    }

    function exists(uint256 tokenId_) external view returns (bool) {
        return _exists(tokenId_);
    }

    function cap() public view returns (uint256) {
        return _cap;
    }
    function increaseCap(uint256 amount_) public onlyOwner {
        require(amount_ > 0, "ChatPuppyNFTCore: amount is 0");

        uint256 newCap = cap() + amount_;
        _updateCap(newCap);
    }

    function mint(address to_) public onlyOwner returns (uint256) {
        uint256 _tokenId = _tokenIdTracker.current();
        _mint(to_, _tokenId);
        _tokenIdTracker.increment();

        return _tokenId;
    }

    function mintBatch(address to_, uint256 amount_) public onlyOwner {
        require(amount_ > 0, "ChatPuppyNFT: amount_ is 0");
        require(totalSupply() + amount_ <= cap(), "cap exceeded");

        for (uint256 i = 0; i < amount_; i++) {
            mint(to_);
        }
    }

    function pause() public virtual onlyOwner {
        _pause();
    }

    function unpause() public virtual onlyOwner {
        _unpause();
    }

    function supportsInterface(bytes4 interfaceId_) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId_);
    }

    function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {
        require(
            _exists(tokenId_),
            "ChatPuppyNFTCore: URI query for nonexistent token"
        );
        return _tokenURIs[tokenId_];
    }

    function updateTokenMetaData(uint256 tokenId_, uint256 artifacts_) external onlyOwner {
        require(_exists(tokenId_), "ChatPuppyNFTCore: tokeId not exists");

        Item storage _info = _items[tokenId_];
        _info.artifacts = artifacts_;
        emit UpdateMetadata(tokenId_, artifacts_);
    }

    function updateTokenMetaData(uint256 tokenId_, uint256 artifacts_, bytes32 dna_) external onlyOwner {
        require(_exists(tokenId_), "ChatPuppyNFTCore: tokeId not exists");

        Item storage _info = _items[tokenId_];
        _info.artifacts = artifacts_;

        if (dna_ != 0 && _info.dna == 0) {
            _info.dna = dna_;
        }
        emit UpdateMetadata(tokenId_, dna_, artifacts_);
    }

    function updateTokenURI(uint256 tokenId_, string calldata uri_) external {
        require(_exists(tokenId_), "ChatPuppyNFTCore: tokeId not exists");
        require((ownerOf(tokenId_) == _msgSender() && bytes(_tokenURIs[tokenId_]).length == 0)
            || _msgSender() == owner(), "ChatPuppyNFTCore: owner of nft can only set once, contract owner can set always");
        _tokenURIs[tokenId_] = uri_;
        emit UpdateTokenURI(tokenId_, uri_);
    }

    function tokenMetaData(uint256 tokenId_) external view returns (bytes32 _dna, uint256 _artifacts, string memory _hexArtifacts) {
        _dna = _items[tokenId_].dna;
        _artifacts = _items[tokenId_].artifacts;
        _hexArtifacts = _items[tokenId_].artifacts.toHexString();
    }
}

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);
}

interface VRFCoordinatorV2Interface {
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  function createSubscription() external returns (uint64 subId);

  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  function addConsumer(uint64 subId, address consumer) external;

  function removeConsumer(uint64 subId, address consumer) external;

  function cancelSubscription(uint64 subId, address to) external;
}

abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

contract ChatPuppyNFTManagerV2 is
	AccessControlEnumerable,
	VRFConsumerBaseV2,
	ItemFactoryManager
{
	using EnumerableSet for EnumerableSet.UintSet;

	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
	bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
	bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
	bytes32 public constant CAP_MANAGER_ROLE = keccak256("CAP_MANAGER_ROLE");
	bytes32 public constant CONTRACT_UPGRADER = keccak256("CONTRACT_UPGRADER");
	bytes32 public constant NFT_UPGRADER = keccak256("NFT_UPGRADER");

	ChatPuppyNFTCore public nftCore;
	uint256 public boxPrice = 0;

	EnumerableSet.UintSet private _supportedBoxTypes;

	mapping(uint256 => uint256[]) private _randomWords;// _randomnesses;
	mapping(uint256 => uint256) private _requestIds;
	mapping(uint256 => uint256) private _tokenIds;

	VRFCoordinatorV2Interface public COORDINATOR;
	uint256 public randomFee = 0;
	address public feeAccount;
	bytes32 private _keyHash = 0xd4bb89654db74673a187bd804519e65e3f71a52bc55f11da7601a13dcf505314;
	uint32 private _callbackGasLimit = 500000;
	uint16 private _requestConfirmations = 3; // Minimum confirmatons is 3
	uint64 private _subscriptionId;

	uint256[] public boxTypes = [2, 3, 4, 5, 6, 7]; // NFT Trait types

	bool public canBuyAndMint = true;
	bool public canUnbox = true;

	event UnboxToken(uint256 indexed tokenId, uint256 indexed requestId);
	event TokenFulfilled(uint256 indexed tokenId);

	constructor(
		address nftAddress_,
		address itemFactory_,
		uint256 boxPrice_,
		uint64  subscriptionId_,
		address vrfCoordinator_,
		bytes32 keyHash_,
		uint32  callbackGasLimit_,
		uint16  requestConfirmations_)
		VRFConsumerBaseV2(vrfCoordinator_)
		ItemFactoryManager(itemFactory_) {
		require(boxPrice_ > 0, "ChatPuppyNFTManager: box price can not be zero");
		boxPrice = boxPrice_;

		nftCore = ChatPuppyNFTCore(nftAddress_);

		_supportedBoxTypes.add(1); // Mystery Box Type#1, Dragon
		_supportedBoxTypes.add(2); // Mystery Box Type#2, Weapon

		_setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
		_setupRole(MINTER_ROLE, _msgSender());
		_setupRole(PAUSER_ROLE, _msgSender());
		_setupRole(CAP_MANAGER_ROLE, _msgSender());
		_setupRole(MANAGER_ROLE, _msgSender());
		_setupRole(CONTRACT_UPGRADER, _msgSender());
		_setupRole(NFT_UPGRADER, _msgSender());

		COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator_);

		_subscriptionId = subscriptionId_;
		_keyHash = keyHash_;
		_callbackGasLimit = callbackGasLimit_;
		_requestConfirmations = requestConfirmations_;
	}

	modifier onlyTokenOwner(uint256 tokenId_) {
		require(nftCore.ownerOf(tokenId_) == _msgSender(), "ChatPuppyNFTManager: caller is not owner");
		_;
	}

	modifier onlyMysteryBox(uint256 tokenId_) {
		(bytes32 _dna, ,) = nftCore.tokenMetaData(tokenId_);
		require(_dna == 0, "ChatPuppyNFTManager: token is already unboxed");
		_;
	}

	modifier onlyExistedToken(uint256 tokenId_) {
		require(nftCore.exists(tokenId_), "ChatPuppyNFTManager: token does not exists");
		_;
	}

	function _getBitMask(uint256 lsbIndex_, uint256 length_) private pure returns (uint256) {
		return ((1 << length_) - 1) << lsbIndex_;
	}

	function _clearBits(
		uint256 data_,
		uint256 lsbIndex_,
		uint256 length_) private pure returns (uint256) {
		return data_ & (~_getBitMask(lsbIndex_, length_));
	}

	function _addArtifactValue(
		uint256 artifacts_,
		uint256 lsbIndex_,
		uint256 length_,
		uint256 artifactValue_) private pure returns (uint256) {
		return((artifactValue_ << lsbIndex_) & _getBitMask(lsbIndex_, length_)) | _clearBits(artifacts_, lsbIndex_, length_);
	}

	function upgradeNFTCoreOwner(address newOwner_) external onlyRole(CONTRACT_UPGRADER) {
		nftCore.transferOwnership(newOwner_);
	}

	function updateNFTCoreContract(address newAddress_) external onlyRole(CONTRACT_UPGRADER) {
		nftCore = ChatPuppyNFTCore(newAddress_);
	}

	function increaseCap(uint256 amount_) external onlyRole(CAP_MANAGER_ROLE) {
		nftCore.increaseCap(amount_);
	}

	function setCanBuyAndMint(bool _status) external onlyRole(MANAGER_ROLE) {
		canBuyAndMint = _status;
	}

	function setCanUnbox(bool _status) external onlyRole(MANAGER_ROLE) {
		canUnbox = _status;
	}

	function updateBoxPrice(uint256 price_) external onlyRole(MANAGER_ROLE) {
		require(price_ > 0, "ChatPuppyNFTManager: box price can not be zero");
		boxPrice = price_;
	}

	function pause() external onlyRole(PAUSER_ROLE) {
		nftCore.pause();
	}

	function unpause() external onlyRole(PAUSER_ROLE) {
		nftCore.unpause();
	}

	function updateItemFactory(address itemFactory_) public onlyRole(CONTRACT_UPGRADER) {
		require(itemFactory_ != address(0), "ChatPuppyNFTManager: itemFactory_ is the zero address");
		_updateItemFactory(itemFactory_);
	}

	function updateVRFCoordinatorV2(address vrfCoordinator_) public onlyRole(CONTRACT_UPGRADER) {
		require(vrfCoordinator_ != address(0), "ChatPuppyNFTManager: vrfCoordinator_ is the zero address");
		COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator_);
	}

	function updateKeyHash(bytes32 keyHash_) public onlyRole(CONTRACT_UPGRADER) {
		_keyHash = keyHash_;
	}

	function updateSubscriptionId(uint64 subscriptionId_) public onlyRole(CONTRACT_UPGRADER) {
		_subscriptionId = subscriptionId_;
	}

	function updateCallbackGasLimit(uint32 callbackGasLimit_) public onlyRole(CONTRACT_UPGRADER) {
		require(callbackGasLimit_ >= 100000, "ChatPuppyNFTManager: Suggest to set 100000 mimimum");
		_callbackGasLimit = callbackGasLimit_;
	}

	function updateRequestConfirmations(uint16 requestConfirmations_) public onlyRole(CONTRACT_UPGRADER) {
		_requestConfirmations = requestConfirmations_;        
	}

	function withdraw(address to_, uint256 amount_) public onlyRole(MANAGER_ROLE) {
		require(to_ != address(0), "ChatPuppyNFTManager: withdraw address is the zero address");
		require(amount_ > uint256(0), "ChatPuppyNFTManager: withdraw amount is zero");
		uint256 balance = address(this).balance;
		require(balance >= amount_, "ChatPuppyNFTManager: withdraw amount must smaller than balance");
		(bool sent, ) = to_.call{value: amount_}("");
		require(sent, "ChatPuppyNFTManager: Failed to send Ether");
	}

	function buyAndMint() public payable {
		require(canBuyAndMint, "ChatPuppyNFTManager: not allowed to buy and mint");
		require(msg.value >= boxPrice, "ChatPuppyNFTManager: payment is not enough");
		_mint(_msgSender());
	}

	function buyAndMintBatch(uint256 amount_) public payable {
		require(canBuyAndMint, "ChatPuppyNFTManager: not allowed to buy and mint");
		require(amount_ > 0, "ChatPuppyNFTManager: amount_ is 0");
		require(msg.value >= boxPrice * amount_, "ChatPuppyNFTManager: Batch purchase payment is not enough");
		
		for (uint256 i = 0; i < amount_; i++) {
			buyAndMint();
		}
	}

	function buyMintAndUnbox() public payable {
		require(canBuyAndMint, "ChatPuppyNFTManager: not allowed to buy and mint");
		require(msg.value >= boxPrice, "ChatPuppyNFTManager: payment is not enough");
		uint256 _tokenId = _mint(_msgSender());
		unbox(_tokenId);
	}

	function mint(address to_) public onlyRole(MINTER_ROLE) {
		_mint(to_);
	}

	function mintBatch(address to_, uint256 amount_) external onlyRole(MINTER_ROLE) {
		require(amount_ > 0, "ChatPuppyNFTManager: amount_ is 0");
		require(nftCore.totalSupply() + amount_ <= nftCore.cap(), "cap exceeded");

		for (uint256 i = 0; i < amount_; i++) {
			_mint(to_);
		}
	}

	function _mint(address to_) private returns(uint256) {
		return nftCore.mint(to_);
	}

	function boxStatus(uint256 tokenId_) public view returns(uint8) {
		if(_requestIds[tokenId_] > uint256(0) && _randomWords[tokenId_].length == 0) return 2; // unboxing
		else if(_requestIds[tokenId_] > uint256(0) && _randomWords[tokenId_].length > 0) return 1; //unboxed
		else return 0; // can unbox
	}

	function unbox(uint256 tokenId_) public payable
		onlyExistedToken(tokenId_) 
		onlyTokenOwner(tokenId_) 
		onlyMysteryBox(tokenId_) 
	{
		require(canUnbox, "ChatPuppyNFTManager: unbox is forbidden");
		require(boxStatus(tokenId_) == 0, "ChatPuppyNFTManager: token is unboxing or unboxed");
		require(boxTypes.length > 0, "ChatPuppyNFTManager: boxTypes is not set");

		_takeRandomFee();

		uint256 requestId_ = COORDINATOR.requestRandomWords(
			_keyHash,
			_subscriptionId,
			_requestConfirmations,
			_callbackGasLimit,
			1
		);
		_requestIds[tokenId_] = requestId_;
		_tokenIds[requestId_] = tokenId_;

		emit UnboxToken(tokenId_, requestId_);
	}


	function _expand(uint256 randomValue, uint256 n) internal pure returns (uint256[] memory){
		uint256[] memory expandedValues = new uint256[](n);
		for(uint256 i = 0; i < n; i++) expandedValues[i] = uint256(keccak256(abi.encode(randomValue, i)));
		return expandedValues;
	}

	function randomWords(uint256 tokenId_) public view returns(uint256, uint256[] memory) {
		return (_requestIds[tokenId_], _randomWords[tokenId_]);
	}

	function fulfillRandomWords(uint256 requestId_, uint256[] memory randomWords_) internal override {
		uint256 tokenId_ = _tokenIds[requestId_];
		(bytes32 _dna, uint256 _artifacts, ) = nftCore.tokenMetaData(tokenId_);

		uint256 randomness_ = randomWords_[0];
		uint256[] memory randomWords__ = _expand(randomness_, 6); 
		_dna = bytes32(keccak256(abi.encodePacked(tokenId_, randomness_)));

		uint256[] memory _itemIds = new uint256[](boxTypes.length);
		for(uint256 i = 0; i < boxTypes.length; i++) {
			uint256 _itemId = itemFactory.getRandomItem(
				randomWords__[i],
				boxTypes[i]
			);
			_itemIds[i] = _itemId;
			_artifacts = _addArtifactValue(_artifacts, i * 8, 8, _itemId); // add itemId
		}
		_artifacts = _addArtifactValue(_artifacts, boxTypes.length * 8, 16, itemFactory.getItemInitialLevel(boxTypes, _itemIds)); // add level
		_artifacts = _addArtifactValue(_artifacts, boxTypes.length * 8 + 16, 16, itemFactory.getItemInitialExperience(boxTypes, _itemIds)); // add exeperience

		_randomWords[tokenId_] = randomWords__;

		nftCore.updateTokenMetaData(tokenId_, _artifacts, _dna);
		emit TokenFulfilled(tokenId_);
	}

	function supportedBoxTypes() external view returns (uint256[] memory) {
		return _supportedBoxTypes.values();
	}

	function upgradeNFT(uint256 tokenId_, uint256 artifacts_) external onlyRole(NFT_UPGRADER) {
		nftCore.updateTokenMetaData(tokenId_, artifacts_);
	}

	function updateRandomFee(uint256 randomFee_) public onlyRole(MANAGER_ROLE) {
		randomFee = randomFee_;
	}

	function updateFeeAccount(address feeAccount_) public onlyRole(MANAGER_ROLE) {
		require(feeAccount_ != address(0), "ChatPuppyNFTManager: feeAccount can not be zero address");
		feeAccount = feeAccount_;
	}

	function updateBoxTypes(uint256[] calldata boxTypes_) external onlyRole(MANAGER_ROLE) {
		boxTypes = boxTypes_;
	}

	function updateTokenURI(uint256 tokenId_, string calldata uri_) external onlyRole(NFT_UPGRADER) {
		nftCore.updateTokenURI(tokenId_, uri_);
	}

	function _takeRandomFee() internal {
		if (randomFee > 0) {
			require(msg.value >= randomFee, "ChatPuppyNFTManager: insufficient fee");
			require(feeAccount != address(0), "ChatPuppyNFTManager: feeAccount is the zero address");
			(bool success, ) = address(feeAccount).call{value: msg.value}(new bytes(0));
			require(success, "ChatPuppyNFTManager: fee required");
		}
	}

	function getLocalRandomness(uint256 tokenId) internal view returns(uint256) {
		uint256 time = block.timestamp;
		uint256 height = block.number;
		return uint256(keccak256(abi.encode(time, height, msg.sender, tokenId)));
	}

	function unboxV2(uint256 tokenId_) 
		onlyExistedToken(tokenId_) 
		onlyTokenOwner(tokenId_) 
		onlyMysteryBox(tokenId_) 
	public {		
		uint256 randomness_ = getLocalRandomness(tokenId_);
		bytes32 _dna = bytes32(keccak256(abi.encodePacked(tokenId_, randomness_)));
		uint256 _artifacts = 0;

		uint256[] memory randomWords__ = _expand(randomness_, boxTypes.length); 

		uint256[] memory _itemIds = new uint256[](boxTypes.length);
		for(uint256 i = 0; i < boxTypes.length; i++) {
			uint256 _itemId = itemFactory.getRandomItem(
				randomWords__[i],
				boxTypes[i]
			);
			_itemIds[i] = _itemId;
			_artifacts = _addArtifactValue(_artifacts, i * 8, 8, _itemId); // add itemId
		}
		_artifacts = _addArtifactValue(_artifacts, boxTypes.length * 8, 16, itemFactory.getItemInitialLevel(boxTypes, _itemIds)); // add level
		_artifacts = _addArtifactValue(_artifacts, boxTypes.length * 8 + 16, 16, itemFactory.getItemInitialExperience(boxTypes, _itemIds)); // add exeperience

		_requestIds[tokenId_] = uint256(keccak256(abi.encode(tokenId_)));
		_randomWords[tokenId_] = randomWords__;
		nftCore.updateTokenMetaData(tokenId_, _artifacts, _dna);
  }
}