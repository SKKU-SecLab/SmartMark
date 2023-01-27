
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
}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

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
}//Unlicense
pragma solidity ^0.8.0;



contract TilesBlocksCore is ERC721Enumerable, AccessControl, Ownable {

    using SafeMath for uint256;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public scriptArweave;
    string public scriptIPFS;  

    mapping(uint256 => uint256) public tokenHash;

    uint32 public genesisMintLimit = 10000;
    uint256 public totalMints = 0;
    string internal _currentBaseURI = "";

    event Mint(uint256 tokenId);
    
    constructor(address adminAddress, address ownerAddress, string memory baseURI) ERC721("Tiles Blocks", "TILB")  {
        _currentBaseURI = baseURI;
        _setupRole(DEFAULT_ADMIN_ROLE, adminAddress);
        transferOwnership(ownerAddress);
    }
    
    function setGenesisMintLimit(uint32 _mintLimit) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        genesisMintLimit = _mintLimit;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _currentBaseURI;
    }

    function setBaseURI(string memory baseURI) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        _currentBaseURI = baseURI;
    }

    function setScriptIPFS(string memory _scriptIPFS) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        scriptIPFS = _scriptIPFS;
    }

    function setScriptArweave(string memory _scriptArweave) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        scriptArweave = _scriptArweave;
    }

    function _generateRandomHash() internal view returns (bytes32) {
        return keccak256(abi.encode(blockhash(block.number-1), block.coinbase, totalMints));
    }

    function _generateNewSeed() internal view returns (uint256) {
        bytes32 hashRandom = _generateRandomHash();
        uint256 value = uint8(hashRandom[20]);
        value = value << 8;
        value = value + uint8(hashRandom[21]);
        value = value << 24;
        value = value.add(totalMints);
        return uint256(value);
    }
    
    function mintGenesis(address _receiver, uint256 qty) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        require(totalMints + qty <= genesisMintLimit, "Total genesis mint limit reached");
        
        for (uint256 i = 0; i<qty; i++) {
           _mint(_receiver);
        }
    }

    function _mint(address _receiver) internal {
        totalMints = totalMints + 1;
        uint256 token = totalMints;
        tokenHash[token] = _generateNewSeed();
        _safeMint(_receiver, token);
        emit Mint(token);
    }

    function burnToMint(uint256[] memory tokenIds, address _owner) public  {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        require(tokenIds.length < 10, "Total burn limit is 9");
        for (uint8 i = 0; i < tokenIds.length; i++) {
            require(_owner == ownerOf(tokenIds[i]), "Only the owner can burn pieces");
            _burn(tokenIds[i]);
        }
        for (uint8 i = 0; i < tokenIds.length - 1; i++) {
            _mint(_owner);
        }
        
    }

    function burn(uint256 tokenId) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        _burn(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }
 
    function withdrawEther() public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}//Unlicense
pragma solidity ^0.8.0;


contract TilesPanelsCore is ERC721Enumerable, AccessControl, Ownable {
    struct Panel {
        string name;
        string description;
        uint16 size;
        uint16 degradationLevel;
        bool isEmpty;
    }

    uint256 constant TOTAL_MAX_2 = 50;
    uint256 constant TOTAL_MAX_4 = 500;
    uint256 constant TOTAL_MAX_6 = 200;
    uint256 constant TOTAL_MAX_9 = 250;
    uint256 constant TOTAL_MAX_16 = 80;
    uint256 constant TOTAL_MAX_25 = 20;
    uint256 constant TOTAL_MAX_36 = 5;

    using SafeMath for uint256;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public scriptArweave;
    string public scriptIPFS;  

    address internal BLOCKS_CONTRACT;

    mapping  (uint256 => uint256[]) public tokenBlocks;
    mapping (uint256 => Panel) public tokens;

    mapping  (uint256 => uint256) public totalMints;
    uint256 public totalGlobalMints = 0;
    string internal _currentBaseURI = "";

    event PanelCreated (uint _tokenId, uint256[] _blocksTokenIds);
    event PanelDeconstructed (uint _tokenId);
    
    constructor(address adminAddress, address ownerAddress, string memory baseURI, address blocks_contract) ERC721("Tiles Panels", "TILP")  {
        _currentBaseURI = baseURI;
        _setupRole(DEFAULT_ADMIN_ROLE, adminAddress);
        BLOCKS_CONTRACT = blocks_contract;
        transferOwnership(ownerAddress);
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return _currentBaseURI;
    }

    function setBaseURI(string memory baseURI) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        _currentBaseURI = baseURI;
    }

    function setScriptIPFS(string memory _scriptIPFS) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        scriptIPFS = _scriptIPFS;
    }

    function setScriptArweave(string memory _scriptArweave) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        scriptArweave = _scriptArweave;
    }
    
    function _isValidLength(uint256 len) internal pure returns(bool) {
        return (len == 2 ||
                len == 4 ||
                len == 6 ||
                len == 9 ||
                len == 16 ||
                len == 25 ||
                len == 36);
    }

    function _checkTotalMints(uint256 size) internal view returns(bool) {
        if(size == 2) {
            return totalMints[size] < TOTAL_MAX_2;
        }
        if(size == 4) {
            return totalMints[size] < TOTAL_MAX_4;
        }
        else if(size == 6) {
            return totalMints[size] < TOTAL_MAX_6;
        }
        else if(size == 9) {
            return totalMints[size] < TOTAL_MAX_9;
        }
        else if(size == 16) {
            return totalMints[size] < TOTAL_MAX_16;
        }
        else if(size == 25) {
            return totalMints[size] < TOTAL_MAX_25;
        }
        else if(size == 36) {
            return totalMints[size] < TOTAL_MAX_36;
        }
        return false;
        
    }

    function deconstruct(uint256 _tokenId) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        require(tokenBlocks[_tokenId].length > 0, "Panel is empty");
        delete tokenBlocks[_tokenId];
        if (tokens[_tokenId].degradationLevel < 4)
            tokens[_tokenId].degradationLevel++;
        tokens[_tokenId].name = '';
        tokens[_tokenId].description = '';
        tokens[_tokenId].isEmpty = true;

        emit PanelDeconstructed(_tokenId);
    }

    function fillEmptyToken(uint256 _tokenId, string memory _name, string memory _desc, uint256[] memory _blocksTokenIds) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        require(tokens[_tokenId].isEmpty, "Panel is not empty");
        uint256 aLength = _blocksTokenIds.length;
        require(tokens[_tokenId].size == aLength, "Size differs from blocks count. Partial Panels not allowed");

        for(uint i=0; i < aLength; i++) {
            uint bTid = _blocksTokenIds[i];
            require(TilesBlocksCore(BLOCKS_CONTRACT).ownerOf(bTid) == ownerOf(_tokenId), "Receiver needs to own all tokens"); //also checks if token exists
            TilesBlocksCore(BLOCKS_CONTRACT).burn(bTid);
        }

        tokenBlocks[_tokenId] = _blocksTokenIds;
        tokens[_tokenId].name = _name;
        tokens[_tokenId].description = _desc;
        tokens[_tokenId].isEmpty = false;

        emit PanelCreated (_tokenId, _blocksTokenIds);
    }

    function mintGenesis(address _receiver, string memory _name, string memory _desc, uint16 _size, uint256[] memory _blocksTokenIds) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        require(_isValidLength(_size), "Invalid size");
        require(_checkTotalMints(_size), "Exceeds total mints for this size");

        bool isEmpty = false;
        uint256 aLength = _blocksTokenIds.length;
        if (aLength > 0) { //not empty
            require(_size == aLength, "Size differs from blocks count. Partial Panels not allowed");
            for(uint i=0; i < aLength; i++) {
                uint bTid = _blocksTokenIds[i];
                require(TilesBlocksCore(BLOCKS_CONTRACT).ownerOf(bTid) == _receiver, "Receiver needs to own all tokens"); //also checks if token exists
                TilesBlocksCore(BLOCKS_CONTRACT).burn(bTid);
            }
        }
        else {
            isEmpty = true;
        }
        
        totalGlobalMints++;
        uint256 token = totalGlobalMints;

        totalMints[_size] = totalMints[_size] + 1;
        tokenBlocks[token] = _blocksTokenIds;


        tokens[token] = Panel({name: _name, description: _desc, size: _size, degradationLevel: 0, isEmpty: isEmpty});
        _safeMint(_receiver, token);
        
        emit PanelCreated (token, _blocksTokenIds);
    }

    function burn(uint256 tokenId) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        _burn(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }
 
    function withdrawEther() public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}//Unlicense
pragma solidity ^0.8.0;


contract TilesMinter is Pausable {
    
    uint256 public constant BLOCK_PRICE = 5*10**16; //price 0.05 eth
    uint256 public constant EMPTY_PANEL_PRICE_2 = 0;
    uint256 public constant EMPTY_PANEL_PRICE_6 = 0;
    uint256 public constant EMPTY_PANEL_PRICE_4 = 1*10**18;
    uint256 public constant EMPTY_PANEL_PRICE_9 = 15*10**17;
    uint256 public constant EMPTY_PANEL_PRICE_16 = 2*10**18;
    uint256 public constant EMPTY_PANEL_PRICE_25 = 4*10**18;
    uint256 public constant EMPTY_PANEL_PRICE_36 = 8*10**18;

    address internal coreBlocksAddress;
    address internal corePanelsAddress;
    address public adminAddress;
    address internal framAddress;
    address internal pulsAddress;
    bool public panelMintStarted = false;
    uint256 public panelMintStartBlock;
    uint256 public panelBlockLimit = 5*60*24*365; //12 months
    using SafeMath for uint256;

    modifier whenNotPausedOrIsAdmin() {
        require(!paused() || _msgSender() == adminAddress, "Pausable: paused");
        _;
    }

    modifier onlyAdmin() {
        require(_msgSender() == adminAddress, "Only the admin can do this");
        _;
    }

    constructor(address _coreBlocksAddress, address _corePanelsAddress, address _admin, address _framAddress, address _pulsAddress)  {
        coreBlocksAddress = _coreBlocksAddress;
        corePanelsAddress = _corePanelsAddress;
        framAddress = _framAddress;
        pulsAddress = _pulsAddress;
        adminAddress = _admin;

        _pause();

    }

    function pause() public onlyAdmin {
        _pause();
    }

    function unpause() public onlyAdmin {
        _unpause();
    }

    function startPanelMint() public onlyAdmin {
        panelMintStarted = true;
        panelMintStartBlock = block.number;
    }

    function setPanelBlockLimit(uint256 _value) public onlyAdmin {
        panelBlockLimit = _value;
    }

    function _isValidLength(uint256 len) internal pure returns(bool) {
        return (len == 2 ||
                len == 4 ||
                len == 6 ||
                len == 9 ||
                len == 16 ||
                len == 25 ||
                len == 36);
    }

    function getEmptyPanelPrice(uint _size) public pure returns(uint256) {
        if (_size == 2)
            return EMPTY_PANEL_PRICE_2;
        if (_size == 4)
            return EMPTY_PANEL_PRICE_4;
        if (_size == 6)
            return EMPTY_PANEL_PRICE_6;
        if (_size == 9)
            return EMPTY_PANEL_PRICE_9;
        if (_size == 16)
            return EMPTY_PANEL_PRICE_16;
        if (_size == 25)
            return EMPTY_PANEL_PRICE_25;
        if (_size == 36)
            return EMPTY_PANEL_PRICE_36;
        return 0;
    }

    function mintBlocks(uint256 n) payable external whenNotPausedOrIsAdmin {
        require(n<=20, "You can only mint up to 20 in the same transaction");
        uint256 totalMaxBlocks =  TilesBlocksCore(coreBlocksAddress).genesisMintLimit();
        uint256 totalMints = TilesBlocksCore(coreBlocksAddress).totalMints();
        require(totalMints < totalMaxBlocks, "All Blocks were already minted");
        if (totalMaxBlocks -  totalMints < 20)
            n = totalMaxBlocks - totalMints;

        uint price = BLOCK_PRICE.mul(n);
        require (msg.value >= price, "Insuficient ether sent");

        uint returnAmount = msg.value.sub(price);
        TilesBlocksCore(coreBlocksAddress).mintGenesis(msg.sender, n);

        if (returnAmount > 0)
            payable(msg.sender).transfer(returnAmount);
    }

    function burnToMintBlocks(uint256[] memory tokenIds) external whenNotPausedOrIsAdmin {
        uint256 totalMaxBlocks =  TilesBlocksCore(coreBlocksAddress).genesisMintLimit();
        uint256 totalMints = TilesBlocksCore(coreBlocksAddress).totalMints();
        require(totalMints >= totalMaxBlocks, "Burns can only start after all Blocks are minted");
        
        TilesBlocksCore(coreBlocksAddress).burnToMint(tokenIds, msg.sender);
    }

    function isEmergence(address user) public view returns (bool) {
        return IERC721(pulsAddress).balanceOf(user) > 0 ||
                        IERC721(framAddress).balanceOf(user) > 0;
    }

    function mintPanel(string memory _name, string memory _desc, uint16 _size, uint256[] memory _blocksTokenIds) payable external whenNotPausedOrIsAdmin {
        require(block.number > panelMintStartBlock + 10 || _blocksTokenIds.length == 0, " In the first 10 blocks, you can only mint empty panels");
        require(_isValidLength(_size), "Invalid size");
        require(panelMintStarted, "Panel mint hasn't started");
        require(block.number < panelMintStartBlock+panelBlockLimit, "Mint period is over");
        require(validateString(_name, 36), "Name is invalid");
        require(validateString(_desc, 255), "Description is invalid");

        if (_size == _blocksTokenIds.length) {
            if(_size == 2) 
                require(msg.sender == adminAddress, "Only the owner can mint 2x1 Panels");
            if(_size == 6)
                require(isEmergence(msg.sender) || msg.sender == adminAddress, "Only Emergence holders can mint 3x2 Panels");
                
            TilesPanelsCore(corePanelsAddress).mintGenesis(msg.sender, _name, _desc, _size, _blocksTokenIds);
            require (msg.value == 0, "no payment needed");
        }
        else if (_blocksTokenIds.length == 0) {
            require(_size != 6 && _size != 2, "2x1 and 3x2 Panels cannot be empty");
            uint price = getEmptyPanelPrice(_size);

            require (msg.value == price, "Wrong ether ammout");

            TilesPanelsCore(corePanelsAddress).mintGenesis(msg.sender,  _name, _desc, _size, _blocksTokenIds);
            
        }
        else
            require (_size == _blocksTokenIds.length, "Size differs from blocks count. Partial Panels not allowed");
    }

    function deconstructPanel(uint256 _tokenId) external whenNotPausedOrIsAdmin {
        require(msg.sender == TilesPanelsCore(corePanelsAddress).ownerOf(_tokenId), "Caller is not the owner");
        require(block.number < panelMintStartBlock+panelBlockLimit, "Deconstruct period is over");
        TilesPanelsCore(corePanelsAddress).deconstruct(_tokenId);
    }

    function fillEmptyToken(uint256 _tokenId, string memory _name, string memory _desc, uint256[] memory _blocksTokenIds) external whenNotPausedOrIsAdmin {
        require(block.number < panelMintStartBlock+panelBlockLimit, "Fill period is over");
        require(msg.sender == TilesPanelsCore(corePanelsAddress).ownerOf(_tokenId), "Caller is not the owner");
        require(validateString(_name, 36), "Name is invalid");
        require(validateString(_desc, 255), "Description is invalid");
        TilesPanelsCore(corePanelsAddress).fillEmptyToken(_tokenId,  _name,  _desc, _blocksTokenIds);
    }

    function withdrawEther() external onlyAdmin {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }       

    function validateString(string memory str, uint16 maxChars) public pure returns (bool){
        bytes memory b = bytes(str);
        if(b.length == 0) return true;
        if(b.length > maxChars) return false; // Cannot be longer than maxChars characters
        if(b[0] == 0x20) return false; // Leading space
        if (b[b.length - 1] == 0x20) return false; // Trailing space
        
        bytes1 lastChar = b[0];

        for(uint i; i<b.length; i++){
            bytes1 char = b[i];

            if (char == 0x20 && lastChar == 0x20) return false; // Cannot contain continous spaces

            if(char == 0x3E || char == 0x3C)
                return false;

            lastChar = char;
        }

        return true;
    }
}