
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

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
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

    function reset(Counter storage counter) internal {

        counter._value = 0;
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


abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

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


contract MACNFT is AccessControl, ERC721Enumerable, ERC721URIStorage {
    using Counters for Counters.Counter;
    string baseURI;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");

    Counters.Counter private _tokenIdTracker;

    constructor(string memory _name, string memory _symbol, string memory baseURI_) ERC721(_name, _symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(TOKEN_ADMIN_ROLE, _msgSender());
        baseURI = baseURI_; // https://ipfs.io/ipfs/   Seamammon series,   MAMON
    }
    

    function mint(
        address owner, string memory metadataURI
    ) external returns (uint256){
        require(hasRole(MINTER_ROLE, _msgSender()), "Must have minter role to mint");
        _safeMint(owner, _tokenIdTracker.current());
        _setTokenURI(_tokenIdTracker.current(), metadataURI);
        _tokenIdTracker.increment();
        return _tokenIdTracker.current()-1;
    }

    function setTokenURI(
        uint256 tokenId,
        string memory newTokenURI
    ) external {
        _setTokenURI(tokenId, newTokenURI);
    }

    function setBaseURI(string memory baseURI_) external {
        baseURI = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");
        return super.tokenURI(tokenId);
    }

}// MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;



contract Marketplace is AccessControl {

    struct AddOn {
        address nftAddress;
        string hash;
        uint256 price;
        uint256 level;
    }
    
    struct PlayerInfo {
        address nft;
        uint256 nftId;
        uint256 [] addOns;
        uint256 [] oldNFTs;
        bool isUpgrade;
    }

    struct Collection {
        string name;
        string description;
        string hash;
        address nftAddress;
    }

    struct NFTProd {
        address owner;
        address nft;
        uint256 tokenID;
        uint256 price;
        uint8 flag;
        uint256 time;
    }

    address [] public arrPlayers;
    address [] public arrCollections;
    mapping (address => string[])public arrAddOns;

    mapping (address => PlayerInfo) public playerInfo;
    mapping (string => AddOn) public addOnInfo;
    mapping (address => Collection) public collectionInfo;
    mapping (address => mapping(string => bool)) public addOnAvailable;
    mapping (address => uint256) public interestOfPlayers;

    bytes32 public constant PRODUCE_ROLE = keccak256("PRODUCE_ROLE");

    mapping(address => mapping (uint256 => NFTProd)) public playerProds;
    mapping(address => mapping (address => uint256[])) public playerProdsIDs; // player_addrss => (nft_addrss => [nftIDs])
    mapping(address => uint256 []) public saleNFTIDs;

    address payable public addOnMaker;
    address public feeAddress;

    uint public feePercent;
    uint public interestAddonFee;
    uint public totalPercent = 10000;

    event AddCollection(string _name, string _description, address _nft);
    event DeleteCollection(address _nft);
    event NewPlayer(address _nft, address _player, uint256 _nftId);
    event UpdatePlayer(address _nft, address _player, uint256 _nftId);
    event RemovePlayer(address _player);
    event AddAddOn(address _nft, string _hash, uint256 _price);
    event DeleteAddOn(address _nft, string _hash);
    event AddSale(address _nft, uint256 _nftId, uint256 _price, address _owner);
    event Sale(address to, address _nft, uint256 _nftId, uint256 _amount );
    event CancelSale(address _nft, uint256 _nftId);
    
    constructor(uint _fee, uint _addonFee) {
        _setupRole(PRODUCE_ROLE, _msgSender());
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        feePercent = _fee;
        interestAddonFee = _addonFee;
        feeAddress = _msgSender();
    }

    function addCollection(string memory _name, string memory _description, string memory _hash, address _nft) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin only can add this.");
        require(collectionInfo[_nft].nftAddress != _nft, "can't register double collection");
        
        Collection memory newCollection = Collection(_name, _description, _hash, _nft);
        collectionInfo[_nft] = newCollection;
        arrCollections.push(_nft);
        emit AddCollection(_name, _description, _nft);
    }

    function udpateCollection(string memory _name, string memory _description, string memory _hash, address _nft) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin only can add this.");

        collectionInfo[_nft].name = _name;
        collectionInfo[_nft].description = _description;
        collectionInfo[_nft].hash = _hash;
    }

    function deleteCollection(address _nft) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin only can delete this.");
    
        uint arrIndex; 
        bool isExist = false;
        for (uint256 index = 0; index < arrCollections.length; index++){
            if (_nft == arrCollections[index]){
                arrIndex = index;
                isExist = true;
            }
        }
        
        if(isExist){
            arrCollections[arrIndex] = arrCollections[arrCollections.length-1];
            arrCollections.pop(); 
        }
        delete collectionInfo[_nft];

        emit DeleteCollection(_nft);
    }

    function registerPlayer(address _nft, address _player, uint256 _nftId, uint16[] memory _addons, uint256[] memory _oldNfts) external {
        require(_nft == collectionInfo[_nft].nftAddress, "there is no collection for this player");
        require(playerInfo[_player].nft != _nft, "can't register double player");

        PlayerInfo storage newPlayer = playerInfo[_player];
        newPlayer.nft = _nft;
        newPlayer.nftId = _nftId;
        newPlayer.addOns = _addons;
        newPlayer.oldNFTs = _oldNfts;
        newPlayer.isUpgrade = true;
        arrPlayers.push(_player);
        interestOfPlayers[_player] = 0;

        emit NewPlayer(_nft, _player, _nftId);
    }

    function registerPlayerWithNew(address _nft, address _player, string memory _hash, uint16[] memory _addons, uint256[] memory _oldNfts) external {
        require(_nft == collectionInfo[_nft].nftAddress, "there is no collection for this player");
        require(playerInfo[_player].nft != _nft, "can't register double player");

        uint256 newNftId = MACNFT(_nft).mint(_player, _hash);

        PlayerInfo storage newPlayer = playerInfo[_player];
        newPlayer.nft = _nft;
        newPlayer.nftId = newNftId;
        newPlayer.addOns = _addons;
        newPlayer.oldNFTs = _oldNfts;
        newPlayer.isUpgrade = true;
        arrPlayers.push(_player);
        interestOfPlayers[_player] = 0;

        emit NewPlayer(_nft, _player, newNftId);
    }

    function updatePlayer(address _nft, address _player, uint256 _nftId, uint16[] memory _addons, uint256[] memory _oldNfts, bool _isUpgrade) external {
        require(_nft == collectionInfo[_nft].nftAddress, "there is no collection for this player");
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin owner only can update this.");
        playerInfo[_player].nft = _nft;
        playerInfo[_player].nftId = _nftId;
        playerInfo[_player].addOns = _addons;
        playerInfo[_player].oldNFTs = _oldNfts;
        playerInfo[_player].isUpgrade = _isUpgrade;

        emit UpdatePlayer(_nft, _player, _nftId);
    }

    function upgradePlayer(address _nft, address _player, string memory _hash) external {
        require(_nft == collectionInfo[_nft].nftAddress, "there is no collection for this player");
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin owner only can update this.");
        
        uint256 newNftId = MACNFT(_nft).mint(_player, _hash);
        
        playerInfo[_player].oldNFTs.push(playerInfo[_player].nftId);
        playerInfo[_player].nftId = newNftId;
        playerInfo[_player].isUpgrade = true;

        emit UpdatePlayer(_nft, _player, newNftId);
    }

    function deletePlayer(address _player) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) || (_player == _msgSender()), "Admin or product owner only can delete this.");
        
        uint arrIndex; 
        bool isExist = false;
        for (uint256 index = 0; index < arrPlayers.length; index++){
            if (_player == arrPlayers[index]){
                arrIndex = index;
                isExist = true;
            }
        }
        
        if(isExist){
            arrPlayers[arrIndex] = arrPlayers[arrPlayers.length-1];
            arrPlayers.pop(); 
        }

        delete playerInfo[_player];

        emit RemovePlayer(_player);
    }

    function addAddOn(address _nft, string memory _hash, uint256 _price, uint256 _level) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin only can add this.");
        require(addOnInfo[_hash].nftAddress != _nft, "can't regsiter double addon");

        AddOn memory newAddOn = AddOn(_nft, _hash, _price, _level);
        addOnInfo[_hash] = newAddOn;
        arrAddOns[_nft].push(_hash);

        emit AddAddOn(_nft, _hash, _price);
    }

    function updateAddOn(address _nft, string memory _hash, uint256 _price, uint256 _level) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin only can add this.");

        addOnInfo[_hash].nftAddress = _nft;
        addOnInfo[_hash].price = _price;
        addOnInfo[_hash].level = _level;
    }

    function deleteAddOn(address _nft, string memory _hash) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin only can delete this.");
        
        uint arrIndex; 
        bool isExist = false;
        for (uint256 index = 0; index < arrAddOns[_nft].length; index++){
            if ((keccak256(abi.encodePacked(_hash))) == (keccak256(abi.encodePacked(arrAddOns[_nft][index])))){
                arrIndex = index;
                isExist = true;
            }
        }
        
        if(isExist){
            arrAddOns[_nft][arrIndex] = arrAddOns[_nft][arrAddOns[_nft].length-1];
            arrAddOns[_nft].pop(); 
        }

        delete addOnInfo[_hash];
        emit DeleteAddOn(_nft, _hash);
    }

    function buyAddOn(address _nft, string memory _hash, address _to) public payable {

        require( addOnAvailable[_to][_hash] == true, "Player can't buy it yet." );
        require( msg.value == addOnInfo[_hash].price, "Same price" );
        
        uint256 addOnId = MACNFT(_nft).mint(_to, addOnInfo[_hash].hash);
        playerInfo[_to].addOns.push(addOnId);
        playerInfo[_to].isUpgrade = false;
        
        uint256 interestingFee = msg.value * interestAddonFee / totalPercent;
        payable(addOnMaker).transfer(msg.value - interestingFee);
        interestOfPlayers[_to] = interestOfPlayers[_to] + interestAddonFee;
    }


    function allowAddOn(string memory _hash, address _player) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Must have admin role to mint");
        addOnAvailable[_player][_hash] = true;
    }


    function addNewProduction(address _nft, uint256 _nftId, uint256 _price) public returns (bool) {
        playerProds[_nft][_nftId] = NFTProd(_msgSender(), _nft, _nftId, _price, 1, block.timestamp);
        saleNFTIDs[_nft].push(_nftId);
        playerProdsIDs[_msgSender()][_nft].push(_nftId);
        MACNFT(_nft).transferFrom(_msgSender(), address(this), _nftId);
        emit AddSale(_nft, _nftId, _price, _msgSender());
        return true;
    }

    function getPlayerSaleNFTs(address _player, address _nft) public view returns(uint256[] memory) {
        return playerProdsIDs[_player][_nft];
    }
    
    function getProdList(address _nft) public view returns(uint256[] memory){
        return saleNFTIDs[_nft];
    }
    
    function getProdById(address _nft, uint256 _nftId) public view returns(NFTProd memory){
        return playerProds[_nft][_nftId];
    }
    
    function getCollections() public view returns (address[] memory){
        return arrCollections;
    }

    function getPlayers() public view returns (address[] memory){
        return arrPlayers;
    }

    function getAddOns(address _nft) public view returns (string[] memory){
        return arrAddOns[_nft];
    }

    function getPlayerInfo(address _player) public view returns (PlayerInfo memory, uint256[] memory, uint256[] memory, bool){
        return (playerInfo[_player], playerInfo[_player].addOns, playerInfo[_player].oldNFTs, playerInfo[_player].isUpgrade);
    } 
    
    function deleteProdByID(address _nft, uint256 _nftId, address _owner) internal returns (bool) {
        uint arrIndex; 
        bool isExist = false;
        for (uint256 index = 0; index < saleNFTIDs[_nft].length; index++){
            if (_nftId == saleNFTIDs[_nft][index]){
                arrIndex = index;
                isExist = true;
            }
        }
        
        if(isExist){
            saleNFTIDs[_nft][arrIndex] = saleNFTIDs[_nft][saleNFTIDs[_nft].length-1];
            saleNFTIDs[_nft].pop(); 
        }

        uint playerMarketIndex; 
        isExist = false;
        for (uint256 index = 0; index < playerProdsIDs[_owner][_nft].length; index++){
            if (_nftId == playerProdsIDs[_owner][_nft][index]){
                playerMarketIndex = index;
                isExist = true;
            }
        }
        
        if(isExist){
            playerProdsIDs[_owner][_nft][playerMarketIndex] = playerProdsIDs[_owner][_nft][playerProdsIDs[_owner][_nft].length-1];
            playerProdsIDs[_owner][_nft].pop(); 
        }
        
        delete playerProds[_nft][_nftId];
        return true;
    }
    
    
    function buy(address to, address _nft, uint256 _nftId, uint256 _amount ) public payable {
        require(msg.value == playerProds[_nft][_nftId].price, "Amount should be same with price");
        
        MACNFT(_nft).transferFrom(address(this), to, _nftId);
        uint256 feeAmount = msg.value * feePercent / totalPercent;
        payable(playerProds[_nft][_nftId].owner).transfer(msg.value - feeAmount);
        payable(feeAddress).transfer(feeAmount);
        deleteProdByID(_nft, _nftId, playerProds[_nft][_nftId].owner);

        emit Sale(to, _nft, _nftId, _amount);
    }


    function cancelForSale(address _nft, uint256 _nftId) external returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) || (playerProds[_nft][_nftId].owner == _msgSender()), "Admin or product owner only can delete this.");
        MACNFT(_nft).transferFrom(address(this), playerProds[_nft][_nftId].owner, _nftId);
        deleteProdByID(_nft, _nftId, playerProds[_nft][_nftId].owner);
        emit CancelSale(_nft, _nftId);
        return true;
    }

    function recoverEmergency(address recipient) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin only can do this.");
        uint256 amount = address(this).balance;
        (bool success,) = payable(recipient).call{value: amount}("");
    }
    
    function setFeeAmount(uint _feeAmount) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin only can do this.");
        feePercent = _feeAmount;
    }

    function setInterestingFeeAmount(uint _feeAmount) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin only can do this.");
        interestAddonFee = _feeAmount;
    }


    
    function setFeeAddress(address _feeAddress) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin only can do this.");
        feeAddress = _feeAddress;
    }

    function setAddonMakerAddress(address payable _makerAddress) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Admin only can do this.");
        addOnMaker = _makerAddress;
    }
}