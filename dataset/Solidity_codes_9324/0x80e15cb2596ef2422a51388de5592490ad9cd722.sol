
pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

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


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {

    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {

        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
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

        address owner = ERC721Upgradeable.ownerOf(tokenId);
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
        address owner = ERC721Upgradeable.ownerOf(tokenId);
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

        address owner = ERC721Upgradeable.ownerOf(tokenId);

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

        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
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
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable(to).onERC721Received.selector;
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

    uint256[44] private __gap;
}// MIT

pragma solidity ^0.8.0;


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721EnumerableUpgradeable is Initializable, ERC721Upgradeable, IERC721EnumerableUpgradeable {
    function __ERC721Enumerable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721Enumerable_init_unchained();
    }

    function __ERC721Enumerable_init_unchained() internal initializer {
    }
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165Upgradeable, ERC721Upgradeable) returns (bool) {
        return interfaceId == type(IERC721EnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Upgradeable.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721EnumerableUpgradeable.totalSupply(), "ERC721Enumerable: global index out of bounds");
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
        uint256 length = ERC721Upgradeable.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721Upgradeable.balanceOf(from) - 1;
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
    uint256[46] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    function __ERC721URIStorage_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721URIStorage_init_unchained();
    }

    function __ERC721URIStorage_init_unchained() internal initializer {
    }
    using StringsUpgradeable for uint256;

    mapping(uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

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
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library CountersUpgradeable {

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


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


interface IAccessControlUpgradeable {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
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
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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
    uint256[49] private __gap;
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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
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

    mapping (uint256 => address) private _owners;

    mapping (address => uint256) private _balances;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
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
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
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

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

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

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
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

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

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

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

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

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

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
        return interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
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

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
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


abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    mapping (uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

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
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
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
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity ^0.8.0;


contract Escrow is Ownable {
    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private _deposits;

    function depositsOf(address payee) public view returns (uint256) {
        return _deposits[payee];
    }

    function deposit(address payee) public payable virtual onlyOwner {
        uint256 amount = msg.value;
        _deposits[payee] = _deposits[payee] + amount;

        emit Deposited(payee, amount);
    }

    function withdraw(address payable payee) public virtual onlyOwner {
        uint256 payment = _deposits[payee];

        _deposits[payee] = 0;

        payee.sendValue(payment);

        emit Withdrawn(payee, payment);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract PullPayment {
    Escrow immutable private _escrow;

    constructor () {
        _escrow = new Escrow();
    }

    function withdrawPayments(address payable payee) public virtual {
        _escrow.withdraw(payee);
    }

    function payments(address dest) public view returns (uint256) {
        return _escrow.depositsOf(dest);
    }

    function _asyncTransfer(address dest, uint256 amount) internal virtual {
        _escrow.deposit{ value: amount }(dest);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
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


interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
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


contract SaleBase is IERC721Receiver, AccessControl {
    using Address for address payable;

    FarbeArtSale public NFTContract;

    address internal platformWalletAddress;

    modifier onlyFarbeContract() {
        require(msg.sender == address(NFTContract), "Caller is not the Farbe contract");
        _;
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) public override virtual returns (bytes4) {
        require(_owns(address(this), _tokenId), "owner is not the sender");

        return this.onERC721Received.selector;
    }

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (NFTContract.ownerOf(_tokenId) == _claimant);
    }

    function _transfer(address _receiver, uint256 _tokenId) internal {
        NFTContract.safeTransferFrom(address(this), _receiver, _tokenId);
    }

    function _payout(
        address payable _seller,
        address payable _creator,
        address payable _gallery,
        uint16 _creatorCut,
        uint16 _platformCut,
        uint16 _galleryCut,
        uint256 _amount,
        uint256 _tokenId
    ) internal {
        if (NFTContract.getSecondarySale(_tokenId)) {
            uint256 galleryAmount;
            if(_gallery != address(0)){
                galleryAmount = (_galleryCut * _amount) / 1000;
            }
            uint256 platformAmount = (25 * _amount) / 1000;
            uint256 creatorAmount = (_creatorCut * _amount) / 1000;
            uint256 sellerAmount = _amount - (platformAmount + creatorAmount + galleryAmount);

            if(_gallery != address(0)) {
                _gallery.sendValue(galleryAmount);
            }
            payable(platformWalletAddress).sendValue(platformAmount);
            _creator.sendValue(creatorAmount);
            _seller.sendValue(sellerAmount);
        }
        else {
            require(_seller == _creator, "Seller is not the creator");

            uint256 platformAmount = (_platformCut * _amount) / 1000;
            uint256 galleryAmount;
            if(_gallery != address(0)) {
                galleryAmount = (_galleryCut * _amount) / 1000;
            }
            uint256 sellerAmount = _amount - (platformAmount + galleryAmount);

            if(_gallery != address(0)) {
                _gallery.sendValue(galleryAmount);
            }
            _seller.sendValue(sellerAmount);
            payable(platformWalletAddress).sendValue(platformAmount);

            NFTContract.setSecondarySale(_tokenId);
        }
    }

    function setPlatformWalletAddress(address _address) external onlyRole(DEFAULT_ADMIN_ROLE) {
        platformWalletAddress = _address;
    }
}// MIT

pragma solidity ^0.8.0;

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
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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


library EnumerableMap {
    using EnumerableSet for EnumerableSet.Bytes32Set;


    struct Map {
        EnumerableSet.Bytes32Set _keys;
        mapping(bytes32 => bytes32) _values;
    }

    function _set(
        Map storage map,
        bytes32 key,
        bytes32 value
    ) private returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {
        return map._keys.contains(key);
    }

    function _length(Map storage map) private view returns (uint256) {
        return map._keys.length();
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {
        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {
        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (_contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    function _get(
        Map storage map,
        bytes32 key,
        string memory errorMessage
    ) private view returns (bytes32) {
        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), errorMessage);
        return value;
    }


    struct AddressToUintMap {
        Map _inner;
    }

    function set(
        AddressToUintMap storage map,
        address key,
        uint256 value
    ) internal returns (bool) {
        return _set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
    }

    function remove(AddressToUintMap storage map, address key) internal returns (bool) {
        return _remove(map._inner, bytes32(uint256(uint160(key))));
    }

    function contains(AddressToUintMap storage map, address key) internal view returns (bool) {
        return _contains(map._inner, bytes32(uint256(uint160(key))));
    }

    function length(AddressToUintMap storage map) internal view returns (uint256) {
        return _length(map._inner);
    }

    function at(AddressToUintMap storage map, uint256 index) internal view returns (address, uint256) {
        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (address(uint160(uint256(key))), uint256(value));
    }

    function tryGet(AddressToUintMap storage map, address key) internal view returns (bool, uint256) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(uint256(uint160(key))));
        return (success, uint256(value));
    }

    function get(AddressToUintMap storage map, address key) internal view returns (uint256) {
        return uint256(_get(map._inner, bytes32(uint256(uint160(key)))));
    }

    function get(
        AddressToUintMap storage map,
        address key,
        string memory errorMessage
    ) internal view returns (uint256) {
        return uint256(_get(map._inner, bytes32(uint256(uint160(key))), errorMessage));
    }
    

    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {
        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
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
        return (uint256(key), address(uint160(uint256(value))));
    }

    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {
        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {
        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}// MIT

pragma solidity ^0.8.0;


contract OpenOffersBase is PullPayment, ReentrancyGuard, SaleBase {
    using Address for address payable;

    using EnumerableMap for EnumerableMap.AddressToUintMap;

    struct OpenOffers {
        address seller;
        address creator;
        address gallery;
        uint64 startedAt;
        uint16 creatorCut;
        uint16 platformCut;
        uint16 galleryCut;
        EnumerableMap.AddressToUintMap offers;
    }

    struct OffersReference {
        address seller;
        address creator;
        address gallery;
        uint16 creatorCut;
        uint16 platformCut;
        uint16 galleryCut;
    }

    mapping(uint256 => OpenOffers) tokenIdToSale;

    event OpenOffersSaleCreated(uint256 tokenId);
    event OpenOffersSaleSuccessful(uint256 tokenId, uint256 totalPrice, address winner);

    function _isOnSale(OpenOffers storage _openSale) internal view returns (bool) {
        return (_openSale.startedAt > 0 && _openSale.startedAt <= block.timestamp);
    }

    function _removeSale(uint256 _tokenId) internal {
        delete tokenIdToSale[_tokenId];
    }

    function _makeOffer(uint _tokenId, uint _bidAmount) internal {
        OpenOffers storage openSale = tokenIdToSale[_tokenId];

        require(_isOnSale(openSale));

        uint256 returnAmount;
        bool offerExists;

        (offerExists, returnAmount) = openSale.offers.tryGet(msg.sender);

        openSale.offers.set(msg.sender, _bidAmount);

        if(offerExists){
            payable(msg.sender).sendValue(returnAmount);
        }
    }

    function _acceptOffer(uint256 _tokenId, address _buyer) internal nonReentrant {
        OpenOffers storage openSale = tokenIdToSale[_tokenId];

        if(openSale.gallery != address(0)) {
            require(openSale.gallery == msg.sender);
        } else {
            require(openSale.seller == msg.sender);
        }

        require(_isOnSale(openSale));

        require(openSale.offers.contains(_buyer));

        uint256 _payoutAmount = openSale.offers.get(_buyer);

        openSale.offers.remove(_buyer);

        address returnAddress;
        uint256 returnAmount;

        for (uint i = 0; i < openSale.offers.length(); i++) {
            (returnAddress, returnAmount) = openSale.offers.at(i);
            _asyncTransfer(returnAddress, returnAmount);
        }

        OffersReference memory openSaleReference = OffersReference(
            openSale.seller,
            openSale.creator,
            openSale.gallery,
            openSale.creatorCut,
            openSale.platformCut,
            openSale.galleryCut
        );

        _removeSale(_tokenId);

        _payout(
            payable(openSaleReference.seller),
            payable(openSaleReference.creator),
            payable(openSaleReference.gallery),
            openSaleReference.creatorCut,
            openSaleReference.platformCut,
            openSaleReference.galleryCut,
            _payoutAmount,
            _tokenId
        );

        _transfer(_buyer, _tokenId);
    }

    function _cancelOffer(uint256 _tokenId, address _buyer) internal {
        OpenOffers storage openSale = tokenIdToSale[_tokenId];

        require(_isOnSale(openSale));

        uint256 _payoutAmount = openSale.offers.get(_buyer);

        openSale.offers.remove(_buyer);

        payable(_buyer).sendValue(_payoutAmount);
    }

    function _finishSale(uint256 _tokenId) internal nonReentrant {
        OpenOffers storage openSale = tokenIdToSale[_tokenId];

        if(openSale.gallery != address(0)) {
            require(openSale.gallery == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        } else {
            require(openSale.seller == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        }

        require(_isOnSale(openSale));

        address seller = openSale.seller;

        address returnAddress;
        uint256 returnAmount;

        for (uint i = 0; i < openSale.offers.length(); i++) {
            (returnAddress, returnAmount) = openSale.offers.at(i);
            _asyncTransfer(returnAddress, returnAmount);
        }

        _removeSale(_tokenId);

        _transfer(seller, _tokenId);
    }
}

contract OpenOffersSale is OpenOffersBase {
    bool public isFarbeOpenOffersSale = true;

    function createSale(
        uint256 _tokenId,
        uint64 _startingTime,
        address _creator,
        address _seller,
        address _gallery,
        uint16 _creatorCut,
        uint16 _galleryCut,
        uint16 _platformCut
    )
    external
    onlyFarbeContract
    {
        OpenOffers storage openOffers = tokenIdToSale[_tokenId];

        openOffers.seller = _seller;
        openOffers.creator = _creator;
        openOffers.gallery = _gallery;
        openOffers.startedAt = _startingTime;
        openOffers.creatorCut = _creatorCut;
        openOffers.platformCut = _platformCut;
        openOffers.galleryCut = _galleryCut;
    }

    function makeOffer(uint256 _tokenId) external payable {
        require(tokenIdToSale[_tokenId].seller != msg.sender && tokenIdToSale[_tokenId].gallery != msg.sender,
            "Sellers and Galleries not allowed");

        _makeOffer(_tokenId, msg.value);
    }

    function acceptOffer(uint256 _tokenId, address _buyer) external {
        _acceptOffer(_tokenId, _buyer);
    }

    function rejectOffer(uint256 _tokenId, address _buyer) external {
        require(tokenIdToSale[_tokenId].seller == msg.sender || tokenIdToSale[_tokenId].gallery == msg.sender);
        _cancelOffer(_tokenId, _buyer);
    }

    function revokeOffer(uint256 _tokenId) external {
        _cancelOffer(_tokenId, msg.sender);
    }

    function finishSale(uint256 _tokenId) external {
        _finishSale(_tokenId);
    }
}// MIT

pragma solidity ^0.8.0;


contract FixedPriceBase is SaleBase {
    using Address for address payable;

    struct FixedPrice {
        address seller;
        address creator;
        address gallery;
        uint128 fixedPrice;
        uint64 startedAt;
        uint16 creatorCut;
        uint16 platformCut;
        uint16 galleryCut;
    }

    mapping(uint256 => FixedPrice) tokenIdToSale;

    event FixedSaleCreated(uint256 tokenId, uint256 fixedPrice);
    event FixedSaleSuccessful(uint256 tokenId, uint256 totalPrice, address winner);

    function _addSale(uint256 _tokenId, FixedPrice memory _fixedSale) internal {
        tokenIdToSale[_tokenId] = _fixedSale;

        emit FixedSaleCreated(
            uint256(_tokenId),
            uint256(_fixedSale.fixedPrice)
        );
    }

    function _removeSale(uint256 _tokenId) internal {
        delete tokenIdToSale[_tokenId];
    }

    function _isOnSale(FixedPrice storage _fixedSale) internal view returns (bool) {
        return (_fixedSale.startedAt > 0 && _fixedSale.startedAt <= block.timestamp);
    }

    function _buy(uint256 _tokenId, uint256 _amount) internal {
        FixedPrice storage fixedSale = tokenIdToSale[_tokenId];

        require(_isOnSale(fixedSale), "Item is not on sale");

        require(_amount >= fixedSale.fixedPrice, "Amount sent is not enough to buy the token");

        FixedPrice memory referenceFixedSale = fixedSale;

        _removeSale(_tokenId);

        _payout(
            payable(referenceFixedSale.seller),
            payable(referenceFixedSale.creator),
            payable(referenceFixedSale.gallery),
            referenceFixedSale.creatorCut,
            referenceFixedSale.platformCut,
            referenceFixedSale.galleryCut,
            _amount,
            _tokenId
        );

        _transfer(msg.sender, _tokenId);

        emit FixedSaleSuccessful(_tokenId, referenceFixedSale.fixedPrice, msg.sender);
    }

    function _finishSale(uint256 _tokenId) internal {
        FixedPrice storage fixedSale = tokenIdToSale[_tokenId];

        if(fixedSale.gallery != address(0)) {
            require(fixedSale.gallery == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        } else {
            require(fixedSale.seller == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        }

        require(_isOnSale(fixedSale));

        address seller = fixedSale.seller;

        _removeSale(_tokenId);

        _transfer(seller, _tokenId);
    }
}

contract FixedPriceSale is FixedPriceBase {
    bool public isFarbeFixedSale = true;

    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x80ac58cd);

    constructor(address _nftAddress, address _platformAddress) {
        FarbeArtSale candidateContract = FarbeArtSale(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        platformWalletAddress = _platformAddress;

        NFTContract = candidateContract;
    }

    function createSale(
        uint256 _tokenId,
        uint128 _fixedPrice,
        uint64 _startingTime,
        address _creator,
        address _seller,
        address _gallery,
        uint16 _creatorCut,
        uint16 _galleryCut,
        uint16 _platformCut
    )
    external
    onlyFarbeContract
    {
        FixedPrice memory fixedSale = FixedPrice(
            _seller,
            _creator,
            _gallery,
            _fixedPrice,
            _startingTime,
            _creatorCut,
            _platformCut,
            _galleryCut
        );
        _addSale(_tokenId, fixedSale);
    }

    function buy(uint256 _tokenId) external payable {
        require(tokenIdToSale[_tokenId].seller != msg.sender && tokenIdToSale[_tokenId].gallery != msg.sender,
            "Sellers and Galleries not allowed");

        _buy(_tokenId, msg.value);
    }

    function finishSale(uint256 _tokenId) external {
        _finishSale(_tokenId);
    }

    function getFixedSale(uint256 _tokenId)
    external
    view
    returns
    (
        address seller,
        uint256 fixedPrice,
        uint256 startedAt
    ) {
        FixedPrice storage fixedSale = tokenIdToSale[_tokenId];
        require(_isOnSale(fixedSale), "Item is not on sale");
        return (
        fixedSale.seller,
        fixedSale.fixedPrice,
        fixedSale.startedAt
        );
    }

    function getTimers(uint256 _tokenId)
    external
    view returns (
        uint256 saleStart,
        uint256 blockTimestamp
    ) {
        FixedPrice memory fixedSale = tokenIdToSale[_tokenId];
        return (fixedSale.startedAt, block.timestamp);
    }
}// MIT
pragma solidity ^0.8.0;



contract FarbeArt is ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct artworkDetails {
        address tokenCreator;
        uint16 creatorCut;
        bool isSecondarySale;
    }

    mapping(uint256 => artworkDetails) tokenIdToDetails;

    uint16 public platformCutOnPrimarySales;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    AuctionSale public auctionSale;
    FixedPriceSale public fixedPriceSale;
    OpenOffersSale public openOffersSale;

    event TokenUriChanged(uint256 tokenId, string uri);

    constructor() ERC721("FarbeArt", "FBA") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function safeMint(
        address _to,
        address _galleryAddress,
        uint8 _numberOfCopies,
        uint16 _creatorCut,
        string[] memory _tokenURI
    ) public {
        require(hasRole(MINTER_ROLE, msg.sender), "does not have minter role");

        require(_tokenURI.length == _numberOfCopies, "Metadata URIs not equal to editions");

        for(uint i = 0; i < _numberOfCopies; i++){
            _safeMint(_to, _tokenIdCounter.current());
            approve(_galleryAddress, _tokenIdCounter.current());
            _setTokenURI(_tokenIdCounter.current(), _tokenURI[i]);
            tokenIdToDetails[_tokenIdCounter.current()].tokenCreator = _to;
            tokenIdToDetails[_tokenIdCounter.current()].creatorCut = _creatorCut;
            _tokenIdCounter.increment();
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal
    override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view
    override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view
    override(ERC721, ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}


contract FarbeArtSale is FarbeArt {
    modifier onlyOwnerOrApproved(uint256 _tokenId) {
        if(getApproved(_tokenId) == address(0)){
            require(ownerOf(_tokenId) == msg.sender, "Not owner or approved");
        } else {
            require(getApproved(_tokenId) == msg.sender, "Only approved can list, revoke approval to list yourself");
        }
        _;
    }

    modifier onlyValidStartingTime(uint64 _startingTime) {
        if(_startingTime > block.timestamp) {
            require(_startingTime - block.timestamp <= 60 days, "Start time too far");
        }
        _;
    }

    constructor(uint16 _platformCut) {
        platformCutOnPrimarySales = _platformCut;
    }

    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender);
        _burn(tokenId);
    }

    function changeTokenUri(string memory _tokenURI, uint256 _tokenId) external {
        require(ownerOf(_tokenId) == msg.sender, "Not owner");
        require(tokenIdToDetails[_tokenId].tokenCreator == msg.sender, "Not creator");

        _setTokenURI(_tokenId, _tokenURI);

        emit TokenUriChanged(
            uint256(_tokenId),
            string(_tokenURI)
        );
    }

    function setAuctionContractAddress(address _address) external onlyRole(DEFAULT_ADMIN_ROLE) {
        AuctionSale auction = AuctionSale(_address);

        require(auction.isFarbeSaleAuction());

        auctionSale = auction;
    }

    function setFixedSaleContractAddress(address _address) external onlyRole(DEFAULT_ADMIN_ROLE) {
        FixedPriceSale fixedSale = FixedPriceSale(_address);

        require(fixedSale.isFarbeFixedSale());

        fixedPriceSale = fixedSale;
    }

    function setOpenOffersContractAddress(address _address) external onlyRole(DEFAULT_ADMIN_ROLE) {
        OpenOffersSale openOffers = OpenOffersSale(_address);

        require(openOffers.isFarbeOpenOffersSale());

        openOffersSale = openOffers;
    }

    function setPlatformCut(uint16 _platformCut) external onlyRole(DEFAULT_ADMIN_ROLE) {
        platformCutOnPrimarySales = _platformCut;
    }

    function setSecondarySale(uint256 _tokenId) external {
        require(msg.sender != address(0));
        require(msg.sender == address(auctionSale) || msg.sender == address(fixedPriceSale)
            || msg.sender == address(openOffersSale), "Caller is not a farbe sale contract");
        tokenIdToDetails[_tokenId].isSecondarySale = true;
    }

    function getSecondarySale(uint256 _tokenId) public view returns (bool) {
        return tokenIdToDetails[_tokenId].isSecondarySale;
    }

    function createSaleAuction(
        uint256 _tokenId,
        uint128 _startingPrice,
        uint64 _startingTime,
        uint64 _duration,
        uint16 _galleryCut
    )
    external
    onlyOwnerOrApproved(_tokenId)
    onlyValidStartingTime(_startingTime)
    {
        artworkDetails memory _details = artworkDetails(
            tokenIdToDetails[_tokenId].tokenCreator,
            tokenIdToDetails[_tokenId].creatorCut,
            false
        );

        require(_details.creatorCut + _galleryCut + platformCutOnPrimarySales < 1000, "Cuts greater than 100%");

        address _galleryAddress = ownerOf(_tokenId) == msg.sender ? address(0) : msg.sender;

        address _seller = ownerOf(_tokenId);

        safeTransferFrom(_seller, address(auctionSale), _tokenId);

        auctionSale.createSale(
            _tokenId,
            _startingPrice,
            _startingTime,
            _duration,
            _details.tokenCreator,
            _seller,
            _galleryAddress,
            _details.creatorCut,
            _galleryCut,
            platformCutOnPrimarySales
        );
    }

    function createSaleFixedPrice(
        uint256 _tokenId,
        uint128 _fixedPrice,
        uint64 _startingTime,
        uint16 _galleryCut
    )
    external
    onlyOwnerOrApproved(_tokenId)
    onlyValidStartingTime(_startingTime)
    {
        artworkDetails memory _details = artworkDetails(
            tokenIdToDetails[_tokenId].tokenCreator,
            tokenIdToDetails[_tokenId].creatorCut,
            false
        );

        require(_details.creatorCut + _galleryCut + platformCutOnPrimarySales < 1000, "Cuts greater than 100%");

        address _galleryAddress = ownerOf(_tokenId) == msg.sender ? address(0) : msg.sender;

        address _seller = ownerOf(_tokenId);

        safeTransferFrom(ownerOf(_tokenId), address(fixedPriceSale), _tokenId);

        fixedPriceSale.createSale(
            _tokenId,
            _fixedPrice,
            _startingTime,
            _details.tokenCreator,
            _seller,
            _galleryAddress,
            _details.creatorCut,
            _galleryCut,
            platformCutOnPrimarySales
        );
    }

    function createSaleOpenOffer(
        uint256 _tokenId,
        uint64 _startingTime,
        uint16 _galleryCut
    )
    external
    onlyOwnerOrApproved(_tokenId)
    onlyValidStartingTime(_startingTime)
    {
        artworkDetails memory _details = artworkDetails(
            tokenIdToDetails[_tokenId].tokenCreator,
            tokenIdToDetails[_tokenId].creatorCut,
            false
        );

        require(_details.creatorCut + _galleryCut + platformCutOnPrimarySales < 1000, "Cuts greater than 100%");

        address _seller = ownerOf(_tokenId);

        address _galleryAddress = ownerOf(_tokenId) == msg.sender ? address(0) : msg.sender;

        safeTransferFrom(ownerOf(_tokenId), address(openOffersSale), _tokenId);

        openOffersSale.createSale(
            _tokenId,
            _startingTime,
            _details.tokenCreator,
            _seller,
            _galleryAddress,
            _details.creatorCut,
            _galleryCut,
            platformCutOnPrimarySales
        );
    }
}// MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;



contract AuctionBase is SaleBase {
    using Address for address payable;

    struct Auction {
        address seller;
        address creator;
        address gallery;
        address buyer;
        uint128 currentPrice;
        uint64 duration;
        uint64 startedAt;
        uint16 creatorCut;
        uint16 platformCut;
        uint16 galleryCut;
    }

    mapping(uint256 => Auction) tokenIdToAuction;

    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 duration);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);

    function _addAuction(uint256 _tokenId, Auction memory _auction) internal {
        require(_auction.duration >= 1 hours && _auction.duration <= 30 days, "time requirement failed");

        tokenIdToAuction[_tokenId] = _auction;

        emit AuctionCreated(
            uint256(_tokenId),
            uint256(_auction.currentPrice),
            uint256(_auction.duration)
        );
    }

    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }

    function _currentPrice(Auction storage auction) internal view returns (uint128) {
        return (auction.currentPrice);
    }

    function _returnBid(address payable _destination, uint256 _amount) private {
        if (_destination != address(0)) {
            _destination.sendValue(_amount);
        }
    }

    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0 && _auction.startedAt <= block.timestamp);
    }

    function _bid(uint _tokenId, uint _bidAmount) internal {
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(auction), "Item is not on auction");

        uint256 secondsPassed = block.timestamp - auction.startedAt;
        require(secondsPassed <= auction.duration, "Auction time has ended");

        uint256 price = auction.currentPrice;
        require(_bidAmount > price, "Bid is too low");

        _returnBid(payable(auction.buyer), auction.currentPrice);

        auction.currentPrice = uint128(_bidAmount);
        auction.buyer = msg.sender;

        uint256 timeRemaining = auction.duration - secondsPassed;
        if (timeRemaining <= 15 minutes) {
            uint256 timeToAdd = 15 minutes - timeRemaining;
            auction.duration += uint64(timeToAdd);
        }
    }

    function _finishAuction(uint256 _tokenId) internal {
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(auction), "Token was not on auction");

        uint256 secondsPassed = block.timestamp - auction.startedAt;
        require(secondsPassed > auction.duration, "Auction hasn't ended");

        Auction memory referenceAuction = auction;

        _removeAuction(_tokenId);

        if (referenceAuction.buyer == address(0)) {
            _transfer(referenceAuction.seller, _tokenId);

            emit AuctionSuccessful(
                _tokenId,
                0,
                referenceAuction.seller
            );
        }
        else {
            _payout(
                payable(referenceAuction.seller),
                payable(referenceAuction.creator),
                payable(referenceAuction.gallery),
                referenceAuction.creatorCut,
                referenceAuction.platformCut,
                referenceAuction.galleryCut,
                referenceAuction.currentPrice,
                _tokenId
            );
            _transfer(referenceAuction.buyer, _tokenId);

            emit AuctionSuccessful(
                _tokenId,
                referenceAuction.currentPrice,
                referenceAuction.buyer
            );
        }
    }

    function _forceFinishAuction(
        uint256 _tokenId,
        address _nftBeneficiary,
        address _paymentBeneficiary
    )
    internal
    {
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(auction), "Token was not on auction");

        uint256 secondsPassed = block.timestamp - auction.startedAt;
        require(secondsPassed > auction.duration, "Auction hasn't ended");

        require(secondsPassed - auction.duration >= 7 days);

        Auction memory referenceAuction = auction;

        _removeAuction(_tokenId);

        payable(_paymentBeneficiary).sendValue(referenceAuction.currentPrice);

        _transfer(_nftBeneficiary, _tokenId);
    }
}


contract AuctionSale is AuctionBase {
    bool public isFarbeSaleAuction = true;

    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x80ac58cd);

    constructor(address _nftAddress, address _platformAddress) {
        FarbeArtSale candidateContract = FarbeArtSale(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        platformWalletAddress = _platformAddress;

        NFTContract = candidateContract;
    }

    function createSale(
        uint256 _tokenId,
        uint128 _startingPrice,
        uint64 _startingTime,
        uint64 _duration,
        address _creator,
        address _seller,
        address _gallery,
        uint16 _creatorCut,
        uint16 _galleryCut,
        uint16 _platformCut
    )
    external
    onlyFarbeContract
    {
        Auction memory auction = Auction(
            _seller,
            _creator,
            _gallery,
            address(0),
            uint128(_startingPrice),
            uint64(_duration),
            _startingTime,
            _creatorCut,
            _platformCut,
            _galleryCut
        );
        _addAuction(_tokenId, auction);
    }

    function bid(uint256 _tokenId) external payable {
        require(tokenIdToAuction[_tokenId].seller != msg.sender && tokenIdToAuction[_tokenId].gallery != msg.sender,
            "Sellers and Galleries not allowed");

        _bid(_tokenId, msg.value);
    }

    function finishAuction(uint256 _tokenId) external {
        _finishAuction(_tokenId);
    }

    function getAuction(uint256 _tokenId)
    external
    view
    returns
    (
        address seller,
        address buyer,
        uint256 currentPrice,
        uint256 duration,
        uint256 startedAt
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (
        auction.seller,
        auction.buyer,
        auction.currentPrice,
        auction.duration,
        auction.startedAt
        );
    }

    function getCurrentPrice(uint256 _tokenId)
    external
    view
    returns (uint128)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }

    function getTimers(uint256 _tokenId)
    external
    view returns (
        uint256 saleStart,
        uint256 blockTimestamp,
        uint256 duration
    ) {
        Auction memory auction = tokenIdToAuction[_tokenId];
        return (auction.startedAt, block.timestamp, auction.duration);
    }

    function forceFinishAuction(
        uint256 _tokenId,
        address _nftBeneficiary,
        address _paymentBeneficiary
    )
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _forceFinishAuction(_tokenId, _nftBeneficiary, _paymentBeneficiary);
    }
}// MIT
pragma solidity ^0.8.0;


interface IFarbeMarketplace {
    function assignToInstitution(address _institutionAddress, uint256 _tokenId, address _owner) external;
    function getIsFarbeMarketplace() external view returns (bool);
}


contract FarbeArtV3Upgradeable is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable, AccessControlUpgradeable {
    CountersUpgradeable.Counter internal _tokenIdCounter;

    struct artworkDetails {
        address tokenCreator;
        uint16 creatorCut;
        bool isSecondarySale;
    }

    mapping(uint256 => artworkDetails) public tokenIdToDetails;

    uint16 public platformCutOnPrimarySales;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    AuctionSale public auctionSale;
    FixedPriceSale public fixedPriceSale;
    OpenOffersSale public openOffersSale;

    event TokenUriChanged(uint256 tokenId, string uri);
    
    function initialize() public initializer {
        __ERC721_init("FarbeArt", "FBA");
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal
    override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view
    override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view
    override(ERC721Upgradeable, ERC721EnumerableUpgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    uint256[1000] private __gap;

}


contract FarbeArtSaleV3Upgradeable is FarbeArtV3Upgradeable {
    modifier onlyOwnerOrApproved(uint256 _tokenId) {
        if(getApproved(_tokenId) == address(0)){
            require(ownerOf(_tokenId) == msg.sender, "Not owner or approved");
        } else {
            require(getApproved(_tokenId) == msg.sender, "Only approved can list, revoke approval to list yourself");
        }
        _;
    }

    modifier onlyValidStartingTime(uint64 _startingTime) {
        if(_startingTime > block.timestamp) {
            require(_startingTime - block.timestamp <= 60 days, "Start time too far");
        }
        _;
    }

    using CountersUpgradeable for CountersUpgradeable.Counter;

    function safeMint(
        address _to,
        address _galleryAddress,
        uint8 _numberOfCopies,
        uint16 _creatorCut,
        string[] memory _tokenURI
    ) public {
        require(hasRole(MINTER_ROLE, msg.sender), "does not have minter role");

        require(_tokenURI.length == _numberOfCopies, "Metadata URIs not equal to editions");

        for(uint i = 0; i < _numberOfCopies; i++){
            _safeMint(_to, _tokenIdCounter.current());
            setApprovalForAll(farbeMarketplace, true);
            _setTokenURI(_tokenIdCounter.current(), _tokenURI[i]);
            tokenIdToDetails[_tokenIdCounter.current()].tokenCreator = _to;
            tokenIdToDetails[_tokenIdCounter.current()].creatorCut = _creatorCut;

            if(_galleryAddress != address(0)){
                IFarbeMarketplace(farbeMarketplace).assignToInstitution(_galleryAddress, _tokenIdCounter.current(), msg.sender);
            }
            _tokenIdCounter.increment();
        }
    }

    
    function farbeInitialize() public initializer {
        FarbeArtV3Upgradeable.initialize();
    }

    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender);
        _burn(tokenId);
    }

    function changeTokenUri(string memory _tokenURI, uint256 _tokenId) external {
        require(ownerOf(_tokenId) == msg.sender, "Not owner");
        require(tokenIdToDetails[_tokenId].tokenCreator == msg.sender, "Not creator");

        _setTokenURI(_tokenId, _tokenURI);

        emit TokenUriChanged(
            uint256(_tokenId),
            string(_tokenURI)
        );
    }
    
    function setFarbeMarketplaceAddress(address _address) external onlyRole(DEFAULT_ADMIN_ROLE) {
        farbeMarketplace = _address;
    }
    
    function getTokenCreatorAddress(uint256 _tokenId) public view returns(address) {
        return tokenIdToDetails[_tokenId].tokenCreator;
    }
    
    function getTokenCreatorCut(uint256 _tokenId) public view returns(uint16) {
        return tokenIdToDetails[_tokenId].creatorCut;
    }

    uint256[1000] private __gap;
    address public farbeMarketplace;
}// MIT

pragma solidity ^0.8.0;


contract SaleBaseV3Upgradeable is Initializable, IERC721ReceiverUpgradeable, AccessControlUpgradeable {
    using AddressUpgradeable for address payable;

    FarbeArtSaleV3Upgradeable public NFTContract;
    struct saleDetail {
        bool isSecondarySale;
    }

    mapping(uint256 => saleDetail) public tokenIdToSaleDetails;
    
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x80ac58cd);

    address internal platformWalletAddress;

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    ) public override virtual returns (bytes4) {
        require(_owns(address(this), _tokenId), "owner is not the sender");

        return this.onERC721Received.selector;
    }

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (NFTContract.ownerOf(_tokenId) == _claimant);
    }

    function _transfer(address _receiver, uint256 _tokenId) internal {
        NFTContract.safeTransferFrom(address(this), _receiver, _tokenId);
    }

    function _payout(
        address payable _seller,
        address payable _creator,
        address payable _gallery,
        uint16 _creatorCut,
        uint16 _platformCut,
        uint16 _galleryCut,
        uint256 _amount,
        uint256 _tokenId
    ) internal {
        if (getSecondarySale(_tokenId)) {
            uint256 galleryAmount;
            if(_gallery != address(0)){
                galleryAmount = (_galleryCut * _amount) / 1000;
            }
            uint256 platformAmount = (25 * _amount) / 1000;
            uint256 creatorAmount = (_creatorCut * _amount) / 1000;
            uint256 sellerAmount = _amount - (platformAmount + creatorAmount + galleryAmount);

            if(_gallery != address(0)) {
                _gallery.sendValue(galleryAmount);
            }
            payable(platformWalletAddress).sendValue(platformAmount);
            _creator.sendValue(creatorAmount);
            _seller.sendValue(sellerAmount);
        }
        else {
            require(_seller == _creator, "Seller is not the creator");

            uint256 platformAmount = (_platformCut * _amount) / 1000;
            uint256 galleryAmount;
            if(_gallery != address(0)) {
                galleryAmount = (_galleryCut * _amount) / 1000;
            }
            uint256 sellerAmount = _amount - (platformAmount + galleryAmount);

            if(_gallery != address(0)) {
                _gallery.sendValue(galleryAmount);
            }
            _seller.sendValue(sellerAmount);
            payable(platformWalletAddress).sendValue(platformAmount);

            setSecondarySale(_tokenId);
        }
    }

    function setPlatformWalletAddress(address _address) external onlyRole(DEFAULT_ADMIN_ROLE) {
        platformWalletAddress = _address;
    }
    function setSecondarySale(uint256 _tokenId) internal {
        require(msg.sender != address(0));
        tokenIdToSaleDetails[_tokenId].isSecondarySale = true;
    }

    function getSecondarySale(uint256 _tokenId) public view returns (bool) {
        return tokenIdToSaleDetails[_tokenId].isSecondarySale;
    }
    uint256[1000] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract FixedPriceBaseV3Upgradeable is SaleBaseV3Upgradeable {
    using AddressUpgradeable for address payable;

    struct FixedPrice {
        address seller;
        address creator;
        address gallery;
        uint128 fixedPrice;
        uint64 startedAt;
        uint16 creatorCut;
        uint16 platformCut;
        uint16 galleryCut;
    }

    mapping(uint256 => FixedPrice) tokenIdToSale;

    event FixedSaleCreated(uint256 tokenId, uint128 fixedPrice, uint64 startingTime, address creator, address seller, address gallery, uint16 creatorCut, uint16 platformCut, uint16 galleryCut);
    event FixedSaleSuccessful(uint256 tokenId, uint256 totalPrice, address winner, address creator, address seller, uint16 creatorCut, uint16 platformCut, uint16 galleryCut);
    event FixedSaleFinished(uint256 tokenId, address gallery, address seller);

    function _addSale(uint256 _tokenId, FixedPrice memory _fixedSale) internal {
        tokenIdToSale[_tokenId] = _fixedSale;

        emit FixedSaleCreated(
            _tokenId,
            _fixedSale.fixedPrice,
            _fixedSale.startedAt,
            _fixedSale.creator,
            _fixedSale.seller,
            _fixedSale.gallery,
            _fixedSale.creatorCut,
            _fixedSale.platformCut,
            _fixedSale.galleryCut
        );
    }

    function _removeFixedPriceSale(uint256 _tokenId) internal {
        delete tokenIdToSale[_tokenId];
    }

    function _isOnSale(FixedPrice storage _fixedSale) internal view returns (bool) {
        return (_fixedSale.startedAt > 0 && _fixedSale.startedAt <= block.timestamp);
    }

    function _buy(uint256 _tokenId, uint256 _amount) internal {
        FixedPrice storage fixedSale = tokenIdToSale[_tokenId];

        require(_isOnSale(fixedSale), "Item is not on sale");

        require(_amount >= fixedSale.fixedPrice, "Not enough amount sent");

        FixedPrice memory referenceFixedSale = fixedSale;

        _removeFixedPriceSale(_tokenId);
        
        _payout(
            payable(referenceFixedSale.seller),
            payable(referenceFixedSale.creator),
            payable(referenceFixedSale.gallery),
            referenceFixedSale.creatorCut,
            referenceFixedSale.platformCut,
            referenceFixedSale.galleryCut,
            _amount,
            _tokenId
        );

        _transfer(msg.sender, _tokenId);

        emit FixedSaleSuccessful(
            _tokenId, 
            _amount, 
            msg.sender, 
            referenceFixedSale.creator,
            referenceFixedSale.seller, 
            referenceFixedSale.creatorCut, 
            referenceFixedSale.platformCut, 
            referenceFixedSale.galleryCut
        );
    }

    function _finishFixedPriceSale(uint256 _tokenId) internal {
        FixedPrice storage fixedSale = tokenIdToSale[_tokenId];

        if(fixedSale.gallery != address(0)) {
            require(fixedSale.gallery == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        } else {
            require(fixedSale.seller == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        }

        require(_isOnSale(fixedSale), "Item is not on sale");

        address seller = fixedSale.seller;

        emit FixedSaleFinished(
            _tokenId,
            fixedSale.gallery,
            fixedSale.seller
            );

        _removeFixedPriceSale(_tokenId);

        _transfer(seller, _tokenId);
    }

    uint256[1000] private __gap;
}

contract FixedPriceSaleV3Upgradeable is FixedPriceBaseV3Upgradeable {
    bool public isFarbeFixedSale;


    function createFixedPriceSale(
        uint256 _tokenId,
        uint128 _fixedPrice,
        uint64 _startingTime,
        address _creator,
        address _seller,
        address _gallery,
        uint16 _creatorCut,
        uint16 _galleryCut,
        uint16 _platformCut
    )
    internal
    {
        FixedPrice memory fixedSale = FixedPrice(
            _seller,
            _creator,
            _gallery,
            _fixedPrice,
            _startingTime,
            _creatorCut,
            _platformCut,
            _galleryCut
        );
        _addSale(_tokenId, fixedSale);
    }

    function buy(uint256 _tokenId) external payable {
        require(tokenIdToSale[_tokenId].seller != msg.sender && tokenIdToSale[_tokenId].gallery != msg.sender,
            "Sellers and Galleries not allowed");

        _buy(_tokenId, msg.value);
    }

    function finishFixedPriceSale(uint256 _tokenId) external {
        _finishFixedPriceSale(_tokenId);
    }

    function getFixedSale(uint256 _tokenId)
    external
    view
    returns
    (
        address seller,
        uint256 fixedPrice,
        uint256 startedAt
    ) {
        FixedPrice storage fixedSale = tokenIdToSale[_tokenId];
        require(_isOnSale(fixedSale), "Item is not on sale");
        return (
        fixedSale.seller,
        fixedSale.fixedPrice,
        fixedSale.startedAt
        );
    }

}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract EscrowUpgradeable is Initializable, OwnableUpgradeable {
    function initialize() public virtual initializer {
        __Escrow_init();
    }
    function __Escrow_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __Escrow_init_unchained();
    }

    function __Escrow_init_unchained() internal initializer {
    }
    using AddressUpgradeable for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private _deposits;

    function depositsOf(address payee) public view returns (uint256) {
        return _deposits[payee];
    }

    function deposit(address payee) public payable virtual onlyOwner {
        uint256 amount = msg.value;
        _deposits[payee] += amount;
        emit Deposited(payee, amount);
    }

    function withdraw(address payable payee) public virtual onlyOwner {
        uint256 payment = _deposits[payee];

        _deposits[payee] = 0;

        payee.sendValue(payment);

        emit Withdrawn(payee, payment);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PullPaymentUpgradeable is Initializable {
    EscrowUpgradeable private _escrow;

    function __PullPayment_init() internal initializer {
        __PullPayment_init_unchained();
    }

    function __PullPayment_init_unchained() internal initializer {
        _escrow = new EscrowUpgradeable();
        _escrow.initialize();
    }

    function withdrawPayments(address payable payee) public virtual {
        _escrow.withdraw(payee);
    }

    function payments(address dest) public view returns (uint256) {
        return _escrow.depositsOf(dest);
    }

    function _asyncTransfer(address dest, uint256 amount) internal virtual {
        _escrow.deposit{value: amount}(dest);
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract OpenOffersBaseV3Upgradeable is PullPaymentUpgradeable, ReentrancyGuardUpgradeable, SaleBaseV3Upgradeable {
    using AddressUpgradeable for address payable;

    using EnumerableMap for EnumerableMap.AddressToUintMap;

    struct OpenOffers {
        address seller;
        address creator;
        address gallery;
        uint64 startedAt;
        uint16 creatorCut;
        uint16 platformCut;
        uint16 galleryCut;
        EnumerableMap.AddressToUintMap offers;
    }

    struct OffersReference {
        address seller;
        address creator;
        address gallery;
        uint16 creatorCut;
        uint16 platformCut;
        uint16 galleryCut;
    }

    mapping(uint256 => OpenOffers) tokenIdToOpenOfferSale;

    event OpenOffersSaleCreated(uint256 tokenId, uint64 startingTime, address creator, address seller, address gallery, uint16 creatorCut, uint16 platformCut, uint16 galleryCut);
    event OpenOffersSaleSuccessful(uint256 tokenId, uint256 totalPrice, address winner, address creator, address seller, address gallery, uint16 creatorCut, uint16 platformCut, uint16 galleryCut);
    event makeOpenOffer(uint256 tokenId, uint256 totalPrice, address winner, address creator, address seller, address gallery);
    event rejectOpenOffer(uint256 tokenId, uint256 totalPrice, address loser, address creator, address seller, address gallery);
    event OpenOffersSaleFinished(uint256 tokenId, address creator, address seller, address gallery);

    function _isOnSale(OpenOffers storage _openSale) internal view returns (bool) {
        return (_openSale.startedAt > 0 && _openSale.startedAt <= block.timestamp);
    }

    function _removeSale(uint256 _tokenId) internal {
        delete tokenIdToOpenOfferSale[_tokenId];
    }

    function _makeOffer(uint _tokenId, uint _bidAmount) internal {
        OpenOffers storage openSale = tokenIdToOpenOfferSale[_tokenId];

        require(_isOnSale(openSale), "Item is not on sale");

        uint256 returnAmount;
        bool offerExists;

        (offerExists, returnAmount) = openSale.offers.tryGet(msg.sender);

        if(offerExists){
            _cancelOffer(_tokenId, msg.sender);
        }

        openSale.offers.set(msg.sender, _bidAmount);

        emit makeOpenOffer(
            _tokenId,
            _bidAmount,
            msg.sender,
            openSale.creator,
            openSale.seller,
            openSale.gallery
            );
    }

    function _acceptOffer(uint256 _tokenId, address _buyer) internal nonReentrant {
        OpenOffers storage openSale = tokenIdToOpenOfferSale[_tokenId];

        if(openSale.gallery != address(0)) {
            require(openSale.gallery == msg.sender);
        } else {
            require(openSale.seller == msg.sender);
        }

        require(_isOnSale(openSale), "Item is not on sale");

        require(openSale.offers.contains(_buyer));

        uint256 _payoutAmount = openSale.offers.get(_buyer);

        openSale.offers.remove(_buyer);

        address returnAddress;
        uint256 returnAmount;

        for (uint i = 0; i < openSale.offers.length(); i++) {
            (returnAddress, returnAmount) = openSale.offers.at(i);
            openSale.offers.remove(returnAddress);
            _asyncTransfer(returnAddress, returnAmount);

            emit rejectOpenOffer(
                _tokenId,
                returnAmount,
                returnAddress,
                openSale.creator,
                openSale.seller,
                openSale.gallery
                );
        }

        OffersReference memory openSaleReference = OffersReference(
            openSale.seller,
            openSale.creator,
            openSale.gallery,
            openSale.creatorCut,
            openSale.platformCut,
            openSale.galleryCut
        );

        _removeSale(_tokenId);

        _payout(
            payable(openSaleReference.seller),
            payable(openSaleReference.creator),
            payable(openSaleReference.gallery),
            openSaleReference.creatorCut,
            openSaleReference.platformCut,
            openSaleReference.galleryCut,
            _payoutAmount,
            _tokenId
        );

        _transfer(_buyer, _tokenId);

        emit OpenOffersSaleSuccessful(
                _tokenId,
                _payoutAmount,
                _buyer,
                openSaleReference.creator,
                openSaleReference.seller,
                openSaleReference.gallery,
                openSaleReference.creatorCut,
                openSaleReference.platformCut,
                openSaleReference.galleryCut
            );
    }

    function _cancelOffer(uint256 _tokenId, address _buyer) internal {
        OpenOffers storage openSale = tokenIdToOpenOfferSale[_tokenId];

        require(_isOnSale(openSale), "Item is not on sale");

        uint256 _payoutAmount = openSale.offers.get(_buyer);

        openSale.offers.remove(_buyer);

        payable(_buyer).sendValue(_payoutAmount);

        emit rejectOpenOffer(
            _tokenId,
            _payoutAmount,
            _buyer,
            openSale.creator,
            openSale.seller,
            openSale.gallery
            );
    }

    function _finishOpenOfferSale(uint256 _tokenId) internal nonReentrant {
        OpenOffers storage openSale = tokenIdToOpenOfferSale[_tokenId];

        if(openSale.gallery != address(0)) {
            require(openSale.gallery == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        } else {
            require(openSale.seller == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        }

        require(_isOnSale(openSale), "Item is not on sale");

        address seller = openSale.seller;

        address returnAddress;
        uint256 returnAmount;

        for (uint i = 0; i < openSale.offers.length(); i++) {
            (returnAddress, returnAmount) = openSale.offers.at(i);
            openSale.offers.remove(returnAddress);
            _asyncTransfer(returnAddress, returnAmount);

            emit rejectOpenOffer(
                _tokenId,
                returnAmount,
                returnAddress,
                openSale.creator,
                openSale.seller,
                openSale.gallery
                );
        }
        
        emit OpenOffersSaleFinished(
            _tokenId,
            openSale.creator,
            openSale.seller,
            openSale.gallery
            );

        _removeSale(_tokenId);

        _transfer(seller, _tokenId);
    }

    uint256[1000] private __gap;
}

contract OpenOffersSaleV3Upgradeable is OpenOffersBaseV3Upgradeable {
    bool public isFarbeOpenOffersSale;

    function createOppenOfferSale(
        uint256 _tokenId,
        uint64 _startingTime,
        address _creator,
        address _seller,
        address _gallery,
        uint16 _creatorCut,
        uint16 _galleryCut,
        uint16 _platformCut
    )
    internal
    {
        OpenOffers storage openOffers = tokenIdToOpenOfferSale[_tokenId];

        openOffers.seller = _seller;
        openOffers.creator = _creator;
        openOffers.gallery = _gallery;
        openOffers.startedAt = _startingTime;
        openOffers.creatorCut = _creatorCut;
        openOffers.platformCut = _platformCut;
        openOffers.galleryCut = _galleryCut;

        emit OpenOffersSaleCreated(
            _tokenId,
            openOffers.startedAt,
            openOffers.creator,
            openOffers.seller,
            openOffers.gallery,
            openOffers.creatorCut,
            openOffers.platformCut,
            openOffers.galleryCut
        );
    }

    function makeOffer(uint256 _tokenId) external payable {
        require(tokenIdToOpenOfferSale[_tokenId].seller != msg.sender && tokenIdToOpenOfferSale[_tokenId].gallery != msg.sender,
            "Sellers and Galleries not allowed");

        _makeOffer(_tokenId, msg.value);
    }

    function acceptOffer(uint256 _tokenId, address _buyer) external {
        _acceptOffer(_tokenId, _buyer);
    }

    function rejectOffer(uint256 _tokenId, address _buyer) external {
        if(tokenIdToOpenOfferSale[_tokenId].gallery != address(0)) {
            require(tokenIdToOpenOfferSale[_tokenId].gallery == msg.sender);
        } else {
            require(tokenIdToOpenOfferSale[_tokenId].seller == msg.sender);
        }        _cancelOffer(_tokenId, _buyer);
    }

    function revokeOffer(uint256 _tokenId) external {
        _cancelOffer(_tokenId, msg.sender);
    }

    function finishSale(uint256 _tokenId) external {
        _finishOpenOfferSale(_tokenId);
    }
}// MIT

pragma solidity ^0.8.0;



contract AuctionBaseV3Upgradeable is SaleBaseV3Upgradeable {
    using AddressUpgradeable for address payable;

    struct Auction {
        address seller;
        address creator;
        address gallery;
        address buyer;
        uint128 currentPrice;
        uint64 duration;
        uint64 startedAt;
        uint16 creatorCut;
        uint16 platformCut;
        uint16 galleryCut;
        uint128 startPrice;
    }

    mapping(uint256 => Auction) tokenIdToAuction;

    uint8 public minBidIncrementPercentage;

    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint64 startingTime, uint256 duration, address creator, address seller, address gallery, uint16 creatorCut, uint16 platformCut, uint16 galleryCut);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, uint256 duration, address winner, address creator, address seller, address gallery, uint16 creatorCut, uint16 platformCut, uint16 galleryCut);
    event BidCreated(uint256 tokenId, uint256 totalPrice, uint256 duration, address winner, address creator, address seller, address gallery);

    function _addAuction(uint256 _tokenId, Auction memory _auction) internal {
        require(_auction.duration >= 1 hours && _auction.duration <= 30 days, "time requirement failed");

        tokenIdToAuction[_tokenId] = _auction;

        emit AuctionCreated(
            _tokenId,
            _auction.currentPrice,
            _auction.startedAt,
            _auction.duration,
            _auction.creator,
            _auction.seller,
            _auction.gallery,
            _auction.creatorCut,
            _auction.platformCut,
            _auction.galleryCut
        );
    }

    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }

    function _currentPrice(Auction storage auction) internal view returns (uint128) {
        return (auction.currentPrice);
    }

    function _returnBid(address payable _destination, uint256 _amount) private {
        if (_destination != address(0)) {
            _destination.sendValue(_amount);
        }
    }

    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0 && _auction.startedAt <= block.timestamp);
    }

    function _bid(uint _tokenId, uint _bidAmount) internal {
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(auction), "Item is not on auction");

        uint256 secondsPassed = block.timestamp - auction.startedAt;
        require(secondsPassed <= auction.duration, "Auction time has ended");

        uint256 price = auction.currentPrice;
        require(_bidAmount > price, "Bid is too low");
        
        if(price == auction.startPrice) {
            require(_bidAmount >= price);
        } else {
            require(_bidAmount >= (price + ((price * minBidIncrementPercentage) / 1000)), "increment not met");
        }

        _returnBid(payable(auction.buyer), auction.currentPrice);

        auction.currentPrice = uint128(_bidAmount);
        auction.buyer = msg.sender;

        uint256 timeRemaining = auction.duration - secondsPassed;
        if (timeRemaining <= 15 minutes) {
            uint256 timeToAdd = 15 minutes - timeRemaining;
            auction.duration += uint64(timeToAdd);
        }
        
        emit BidCreated(
            _tokenId,
            auction.currentPrice,
            auction.duration,
            auction.buyer,
            auction.creator,
            auction.seller,
            auction.gallery
            );
    }

    function _finishAuction(uint256 _tokenId) internal {
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(auction), "Token was not on auction");

        uint256 secondsPassed = block.timestamp - auction.startedAt;
        require(secondsPassed > auction.duration, "Auction hasn't ended");

        Auction memory referenceAuction = auction;

        _removeAuction(_tokenId);

        if (referenceAuction.buyer == address(0)) {
            _transfer(referenceAuction.seller, _tokenId);

            emit AuctionSuccessful(
                _tokenId,
                0,
                referenceAuction.duration,
                referenceAuction.seller,
                referenceAuction.creator,
                referenceAuction.seller,
                referenceAuction.gallery,
                referenceAuction.creatorCut,
                referenceAuction.platformCut,
                referenceAuction.galleryCut
            );
        }
        else {
        
            _payout(
                payable(referenceAuction.seller),
                payable(referenceAuction.creator),
                payable(referenceAuction.gallery),
                referenceAuction.creatorCut,
                referenceAuction.platformCut,
                referenceAuction.galleryCut,
                referenceAuction.currentPrice,
                _tokenId
            );
            _transfer(referenceAuction.buyer, _tokenId);

            emit AuctionSuccessful(
                _tokenId,
                referenceAuction.currentPrice,
                referenceAuction.duration,
                referenceAuction.buyer,
                referenceAuction.creator,
                referenceAuction.seller,
                referenceAuction.gallery,
                referenceAuction.creatorCut,
                referenceAuction.platformCut,
                referenceAuction.galleryCut
            );
        }
    }

    function _forceFinishAuction(
        uint256 _tokenId,
        address _nftBeneficiary,
        address _paymentBeneficiary
    )
    internal
    {
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(auction), "Token was not on auction");

        uint256 secondsPassed = block.timestamp - auction.startedAt;
        require(secondsPassed > auction.duration, "Auction hasn't ended");

        require(secondsPassed - auction.duration >= 7 days);

        Auction memory referenceAuction = auction;

        _removeAuction(_tokenId);

        payable(_paymentBeneficiary).sendValue(referenceAuction.currentPrice);

        _transfer(_nftBeneficiary, _tokenId);

        emit AuctionSuccessful(
            _tokenId,
            0,
            referenceAuction.duration,
            _nftBeneficiary,
            referenceAuction.creator,
            _paymentBeneficiary,
            referenceAuction.gallery,
            referenceAuction.creatorCut,
            referenceAuction.platformCut,
            referenceAuction.galleryCut
        );
    }

    uint256[1000] private __gap;
}


contract AuctionSaleV3Upgradeable is AuctionBaseV3Upgradeable {
    bool public isFarbeSaleAuction;

    function createAuctionSale(
        uint256 _tokenId,
        uint128 _startingPrice,
        uint64 _startingTime,
        uint64 _duration,
        address _creator,
        address _seller,
        address _gallery,
        uint16 _creatorCut,
        uint16 _galleryCut,
        uint16 _platformCut
    )
    internal
    {
        Auction memory auction = Auction(
            _seller,
            _creator,
            _gallery,
            address(0),
            uint128(_startingPrice),
            uint64(_duration),
            _startingTime,
            _creatorCut,
            _platformCut,
            _galleryCut,
            uint128(_startingPrice)
        );
        _addAuction(_tokenId, auction);
    }

    function bid(uint256 _tokenId) external payable {
        require(tokenIdToAuction[_tokenId].seller != msg.sender && tokenIdToAuction[_tokenId].gallery != msg.sender,
            "Sellers and Galleries not allowed");

        _bid(_tokenId, msg.value);
    }

    function finishAuction(uint256 _tokenId) external {
        _finishAuction(_tokenId);
    }

    function getAuction(uint256 _tokenId)
    external
    view
    returns
    (
        address seller,
        address buyer,
        uint256 currentPrice,
        uint256 duration,
        uint256 startedAt
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (
        auction.seller,
        auction.buyer,
        auction.currentPrice,
        auction.duration,
        auction.startedAt
        );
    }

    function getCurrentPrice(uint256 _tokenId)
    external
    view
    returns (uint128)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }

    function forceFinishAuction(
        uint256 _tokenId,
        address _nftBeneficiary,
        address _paymentBeneficiary
    )
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _forceFinishAuction(_tokenId, _nftBeneficiary, _paymentBeneficiary);
    }
}// MIT
pragma solidity ^0.8.0;



contract FarbeMarketplaceV3Upgradeable is FixedPriceSaleV3Upgradeable, AuctionSaleV3Upgradeable, OpenOffersSaleV3Upgradeable, PausableUpgradeable {
    bool public isFarbeMarketplace;

    using EnumerableMap for EnumerableMap.UintToAddressMap;
    
    mapping(address => EnumerableMap.UintToAddressMap) institutionToTokenCollection;
    
    struct tokenDetails {
        address tokenCreator;
        uint16 creatorCut;
        bool isInstitution;
    }

    event AssignedToInstitution(address institutionAddress, uint256 tokenId, address owner);
    event TakeBackFromInstitution(uint256 tokenId, address institution,address owner);

    uint16 public platformCutOnPrimarySales;
    
    function initialize(address _nftAddress, address _platformAddress, uint16 _platformCut) public initializer {
        FarbeArtSaleV3Upgradeable candidateContract = FarbeArtSaleV3Upgradeable(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));
        
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        __PullPayment_init();
        __Pausable_init();
        NFTContract = candidateContract;
        platformCutOnPrimarySales = _platformCut;
        platformWalletAddress = _platformAddress;
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function setPlatformCut(uint16 _platformCut) external onlyRole(DEFAULT_ADMIN_ROLE) {
        platformCutOnPrimarySales = _platformCut;
    }

    function setPlatformAddress(address _platformAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        platformWalletAddress = _platformAddress;
    }

    modifier onlyValidStartingTime(uint64 _startingTime) {
        if(_startingTime > block.timestamp) {
            require(_startingTime - block.timestamp <= 60 days, "Start time too far");
        }
        _;
    }
    
    modifier onlyFarbeContract() {
        require(msg.sender == address(NFTContract), "Caller is not the Farbe contract");
        _;
    }

    function assignToInstitution(address _institutionAddress, uint256 _tokenId) external {
        require(NFTContract.ownerOf(_tokenId) == msg.sender, "Sender is not the owner");
        NFTContract.safeTransferFrom(msg.sender, address(this), _tokenId);
        institutionToTokenCollection[_institutionAddress].set(_tokenId, msg.sender);
        
        emit AssignedToInstitution(_institutionAddress, _tokenId, msg.sender);
    }

    function assignToInstitution(address _institutionAddress, uint256 _tokenId, address _owner) external onlyFarbeContract {
        NFTContract.safeTransferFrom(NFTContract.ownerOf(_tokenId), address(this), _tokenId);
        institutionToTokenCollection[_institutionAddress].set(_tokenId, _owner);
        
        emit AssignedToInstitution(_institutionAddress, _tokenId, _owner);
    }

    function takeBackFromInstitution(uint256 _tokenId, address _institution) external {
        address tokenOwner;
        tokenOwner = institutionToTokenCollection[_institution].get(_tokenId);
        require(tokenOwner == msg.sender, "Not original owner");
        
        institutionToTokenCollection[_institution].remove(_tokenId);
        NFTContract.safeTransferFrom(address(this), msg.sender, _tokenId);

        emit TakeBackFromInstitution(_tokenId, _institution, tokenOwner);
    }

    function preSaleChecks(uint256 _tokenId, uint16 _galleryCut) internal returns (address, address, address, uint16) {
        address owner = NFTContract.ownerOf(_tokenId);

        if(owner == address(this)){
            require(institutionToTokenCollection[msg.sender].contains(_tokenId), "Not approved institution");
        }
        else {
            require(owner == msg.sender, "Not owner or institution");
        }

        tokenDetails memory _details = tokenDetails(
            NFTContract.getTokenCreatorAddress(_tokenId),
            NFTContract.getTokenCreatorCut(_tokenId),
            owner != msg.sender // true if sale is from an institution
        );

        if(getSecondarySale(_tokenId)){
            require(_details.creatorCut + _galleryCut + 25 < 1000, "Cuts greater than 100%");
        } else {
            require(_details.creatorCut + _galleryCut + platformCutOnPrimarySales < 1000, "Cuts greater than 100%");
        }

        address _seller = _details.isInstitution ? institutionToTokenCollection[msg.sender].get(_tokenId) : msg.sender;

        if(_details.isInstitution){
            institutionToTokenCollection[msg.sender].remove(_tokenId);
        }

        address _galleryAddress = _details.isInstitution ? msg.sender : address(0);

        if(!_details.isInstitution) {
            NFTContract.safeTransferFrom(owner, address(this), _tokenId);
        }
        
        return (_details.tokenCreator, _seller, _galleryAddress, _details.creatorCut);

    }
    
    
    function createSaleAuction(
        uint256 _tokenId,
        uint128 _startingPrice,
        uint64 _startingTime,
        uint64 _duration,
        uint16 _galleryCut
    )
    public
    onlyValidStartingTime(_startingTime)
    whenNotPaused()
    {
        address _creatorAddress;
        address _seller;
        address _galleryAddress;
        uint16 _creatorCut;
        
        (_creatorAddress, _seller, _galleryAddress, _creatorCut) = preSaleChecks(_tokenId, _galleryCut);

        createAuctionSale(
            _tokenId,
            _startingPrice,
            _startingTime,
            _duration,
            _creatorAddress,
            _seller,
            _galleryAddress,
            _creatorCut,
            _galleryCut,
            platformCutOnPrimarySales
        );
    }

    function createBulkSaleAuction(
        uint256[] memory _tokenId,
        uint128[] memory _startingPrice,
        uint64[] memory _startingTime,
        uint64[] memory _duration,
        uint16 _galleryCut
    )
    external
    whenNotPaused()
    {
        uint _numberOfTokens = _tokenId.length;

        require(_startingPrice.length == _numberOfTokens, "starting prices incorrect");
        require(_startingTime.length == _numberOfTokens, "starting times incorrect");
        require(_duration.length == _numberOfTokens, "durations incorrect");

        for(uint i = 0; i < _numberOfTokens; i++){
            createSaleAuction(_tokenId[i], _startingPrice[i], _startingTime[i], _duration[i], _galleryCut);
        }
    }

    
    function createSaleFixedPrice(
        uint256 _tokenId,
        uint128 _fixedPrice,
        uint64 _startingTime,
        uint16 _galleryCut
    )
    public
    onlyValidStartingTime(_startingTime)
    whenNotPaused()
    {
        address _creatorAddress;
        address _seller;
        address _galleryAddress;
        uint16 _creatorCut;
        
        (_creatorAddress, _seller, _galleryAddress, _creatorCut) = preSaleChecks(_tokenId, _galleryCut);

        createFixedPriceSale(
            _tokenId,
            _fixedPrice,
            _startingTime,
            _creatorAddress,
            _seller,
            _galleryAddress,
            _creatorCut,
            _galleryCut,
            platformCutOnPrimarySales
        );
    }

    
    function createBulkSaleFixedPrice(
        uint256[] memory _tokenId,
        uint128[] memory _fixedPrice,
        uint64[] memory _startingTime,
        uint16 _galleryCut
    )
    external
    whenNotPaused()
    {
        uint _numberOfTokens = _tokenId.length;

        require(_fixedPrice.length == _numberOfTokens, "fixed prices incorrect");
        require(_startingTime.length == _numberOfTokens, "starting times incorrect");

        for(uint i = 0; i < _numberOfTokens; i++){
            createSaleFixedPrice(_tokenId[i], _fixedPrice[i], _startingTime[i], _galleryCut);
        }
    }

    function createSaleOpenOffer(
        uint256 _tokenId,
        uint64 _startingTime,
        uint16 _galleryCut
    )
    public
    onlyValidStartingTime(_startingTime)
    whenNotPaused()
    {
        address _creatorAddress;
        address _seller;
        address _galleryAddress;
        uint16 _creatorCut;
        
        (_creatorAddress, _seller, _galleryAddress, _creatorCut) = preSaleChecks(_tokenId, _galleryCut);

        createOppenOfferSale(
            _tokenId,
            _startingTime,
            _creatorAddress,
            _seller,
            _galleryAddress,
            _creatorCut,
            _galleryCut,
            platformCutOnPrimarySales
        );
    }

    function createBulkSaleOpenOffer(
        uint256[] memory _tokenId,
        uint64[] memory _startingTime,
        uint16 _galleryCut
    )
    external
    whenNotPaused()
    {
        uint _numberOfTokens = _tokenId.length;

        require(_startingTime.length == _numberOfTokens, "starting times incorrect");

        for(uint i = 0; i < _numberOfTokens; i++){
            createSaleOpenOffer(_tokenId[i], _startingTime[i], _galleryCut);
        }
    }
}