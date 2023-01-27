
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
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
}//Unlicense
pragma solidity ^0.8.0;


contract NiftyKitBase is Ownable, AccessControl {

    using SafeMath for uint256;
    uint256 internal _commission; // parts per 10,000
    address internal _treasury;

    modifier onlyAdmin() {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()));
        _;
    }

    function setCommission(uint256 commission) public onlyOwner {

        _commission = commission;
    }

    function setTreasury(address treasury) public onlyOwner {

        _treasury = treasury;
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
}//Unlicense
pragma solidity ^0.8.0;


contract NiftyKitCollection is
    ERC721,
    ERC721URIStorage,
    Ownable,
    AccessControl
{
    using Counters for Counters.Counter;

    Counters.Counter private _ids;

    uint256 internal _commission = 0; // parts per 10,000

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()));
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function mint(address recipient, string memory metadata)
        public
        onlyAdmin
        returns (uint256)
    {
        _ids.increment();
        uint256 id = _ids.current();
        _mint(recipient, id);
        _setTokenURI(id, metadata);
        return id;
    }

    function burn(uint256 id) public onlyAdmin {
        _burn(id);
    }

    function transfer(
        address from,
        address to,
        uint256 tokenId
    ) public onlyAdmin {
        _transfer(from, to, tokenId);
    }

    function setCommission(uint256 commission) public onlyAdmin {
        _commission = commission;
    }

    function getCommission() public view returns (uint256) {
        return _commission;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "ipfs://";
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}//Unlicense
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


contract NiftyKitOperator is NiftyKitBase {
    event CollectionCreated(address indexed cAddress);
    event TokenMinted(
        address indexed cAddress,
        string manifest,
        uint256 indexed id
    );

    function createCollection(
        address creator,
        string calldata name,
        string calldata symbol
    ) external onlyAdmin {
        NiftyKitCollection collection = new NiftyKitCollection(name, symbol);
        collection.transferOwnership(creator);
        emit CollectionCreated(address(collection));
    }

    function batchMint(
        address[] calldata cAddresses,
        string[] calldata manifests,
        address[] calldata recipients
    ) external onlyAdmin {
        for (uint256 i = 0; i < cAddresses.length; i++) {
            NiftyKitCollection collection = NiftyKitCollection(cAddresses[i]);
            emit TokenMinted(
                cAddresses[i],
                manifests[i],
                collection.mint(recipients[i], manifests[i])
            );
        }
    }

    function transfer(
        address cAddress,
        address from,
        address to,
        uint256 tokenId
    ) external onlyAdmin {
        NiftyKitCollection collection = NiftyKitCollection(cAddress);
        collection.transfer(from, to, tokenId);
    }

    function burn(address cAddress, uint256 tokenId) external onlyAdmin {
        NiftyKitCollection collection = NiftyKitCollection(cAddress);
        collection.burn(tokenId);
    }

    function setCommission(address cAddress, uint256 commission)
        external
        onlyAdmin
    {
        NiftyKitCollection collection = NiftyKitCollection(cAddress);
        collection.setCommission(commission);
    }

    function addCollectionAdmin(address cAddress, address account)
        external
        onlyAdmin
    {
        NiftyKitCollection collection = NiftyKitCollection(cAddress);
        collection.grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    function removeCollectionAdmin(address cAddress, address account)
        external
        onlyAdmin
    {
        NiftyKitCollection collection = NiftyKitCollection(cAddress);
        collection.revokeRole(DEFAULT_ADMIN_ROLE, account);
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
}//Unlicense
pragma solidity ^0.8.0;


library ListingManager {
    using EnumerableSet for EnumerableSet.UintSet;

    struct Listing {
        EnumerableSet.UintSet _forSaleTokenIds;
        mapping(uint256 => uint256) _tokensForPrices;
    }

    function set(
        Listing storage listing,
        uint256 tokenId,
        uint256 price
    ) internal {
        if (!has(listing, tokenId)) {
            listing._forSaleTokenIds.add(tokenId);
        }
        listing._tokensForPrices[tokenId] = price;
    }

    function remove(Listing storage listing, uint256 tokenId)
        internal
        returns (bool)
    {
        if (has(listing, tokenId)) {
            listing._forSaleTokenIds.remove(tokenId);
            delete listing._tokensForPrices[tokenId];
            return true;
        }
        return false;
    }

    function has(Listing storage listing, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        return listing._forSaleTokenIds.contains(tokenId);
    }

    function get(Listing storage listing, uint256 tokenId)
        internal
        view
        returns (uint256)
    {
        return listing._tokensForPrices[tokenId];
    }
}//Unlicense
pragma solidity ^0.8.0;


contract NiftyKitListings is NiftyKitBase {
    using ListingManager for ListingManager.Listing;

    mapping(address => ListingManager.Listing) internal _collectionForListings;

    function setListing(
        address cAddress,
        uint256 tokenId,
        uint256 price
    ) public onlyAdmin {
        _collectionForListings[cAddress].set(tokenId, price);
    }

    function removeListing(address cAddress, uint256 tokenId) public onlyAdmin {
        require(_collectionForListings[cAddress].remove(tokenId));
    }

    function hasListing(address cAddress, uint256 tokenId)
        public
        view
        returns (bool)
    {
        return _collectionForListings[cAddress].has(tokenId);
    }

    function getPrice(address cAddress, uint256 tokenId)
        public
        view
        returns (uint256)
    {
        return _collectionForListings[cAddress].get(tokenId);
    }
}//Unlicense
pragma solidity ^0.8.0;


library OfferManager {
    using EnumerableSet for EnumerableSet.UintSet;

    struct Offer {
        EnumerableSet.UintSet _tokenIdsWithOffers;
        mapping(uint256 => uint256) _tokensForHighestAmount;
        mapping(uint256 => address) _tokensForHighestBidder;
    }

    function add(
        Offer storage offer,
        address bidder,
        uint256 tokenId,
        uint256 amount
    ) internal returns (bool) {
        if (!has(offer, tokenId)) {
            offer._tokenIdsWithOffers.add(tokenId);
            offer._tokensForHighestBidder[tokenId] = bidder;
            offer._tokensForHighestAmount[tokenId] = amount;
            return true;
        } else if (amount > highestAmount(offer, tokenId)) {
            offer._tokensForHighestBidder[tokenId] = bidder;
            offer._tokensForHighestAmount[tokenId] = amount;
            return true;
        }
        return false;
    }

    function remove(Offer storage offer, uint256 tokenId)
        internal
        returns (bool)
    {
        if (has(offer, tokenId)) {
            offer._tokenIdsWithOffers.remove(tokenId);
            delete offer._tokensForHighestBidder[tokenId];
            delete offer._tokensForHighestAmount[tokenId];
            return true;
        }
        return false;
    }

    function has(Offer storage offer, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        return offer._tokenIdsWithOffers.contains(tokenId);
    }

    function highestAmount(Offer storage offer, uint256 tokenId)
        internal
        view
        returns (uint256)
    {
        return offer._tokensForHighestAmount[tokenId];
    }

    function highestBidder(Offer storage offer, uint256 tokenId)
        internal
        view
        returns (address)
    {
        return offer._tokensForHighestBidder[tokenId];
    }
}//Unlicense
pragma solidity ^0.8.0;


contract NiftyKitOffers is NiftyKitBase {
    using OfferManager for OfferManager.Offer;

    mapping(address => OfferManager.Offer) internal _collectionForOffers;

    function addOffer(address cAddress, uint256 tokenId) public payable {
        bool hasBid = hasOffer(cAddress, tokenId);
        address bidder = getHighestBidder(cAddress, tokenId);
        uint256 amount = getHighestAmount(cAddress, tokenId);

        require(
            _collectionForOffers[cAddress].add(_msgSender(), tokenId, msg.value)
        );

        if (hasBid) {
            payable(bidder).transfer(amount);
        }
    }

    function removeOffer(address cAddress, uint256 tokenId, bool refund) public onlyAdmin {
        require(hasOffer(cAddress, tokenId));
        _removeOffer(cAddress, tokenId, refund);
    }

    function hasOffer(address cAddress, uint256 tokenId)
        public
        view
        returns (bool)
    {
        return _collectionForOffers[cAddress].has(tokenId);
    }

    function getHighestAmount(address cAddress, uint256 tokenId)
        public
        view
        returns (uint256)
    {
        return _collectionForOffers[cAddress].highestAmount(tokenId);
    }

    function getHighestBidder(address cAddress, uint256 tokenId)
        public
        view
        returns (address)
    {
        return _collectionForOffers[cAddress].highestBidder(tokenId);
    }

    function _removeOffer(address cAddress, uint256 tokenId, bool refund) internal {
        address bidder = getHighestBidder(cAddress, tokenId);
        uint256 amount = getHighestAmount(cAddress, tokenId);
        _collectionForOffers[cAddress].remove(tokenId);
        if (refund) {
            payable(bidder).transfer(amount);
        }
    }
}//Unlicense
pragma solidity ^0.8.0;


contract NiftyKitStorefront is NiftyKitListings, NiftyKitOffers {
    using ListingManager for ListingManager.Listing;
    using OfferManager for OfferManager.Offer;

    event ListingSold(
        address indexed cAddress,
        uint256 indexed tokenId,
        address indexed customer,
        uint256 price
    );
    event OfferAccepted(
        address indexed cAddress,
        uint256 indexed tokenId,
        address indexed bidder,
        uint256 amount
    );

    function purchaseListing(address cAddress, uint256 tokenId) public payable {
        require(hasListing(cAddress, tokenId));
        require(_collectionForListings[cAddress].get(tokenId) == msg.value);

        NiftyKitCollection collection = NiftyKitCollection(cAddress);
        address creator = collection.ownerOf(tokenId);

        uint256 commission = _commissionValue(_commission, msg.value);
        payable(_treasury).transfer(commission);

        uint256 cCommission =
            _commissionValue(collection.getCommission(), msg.value);
        if (cCommission > 0) {
            payable(collection.owner()).transfer(cCommission);
        }

        payable(creator).transfer(msg.value - commission - cCommission);

        collection.transfer(creator, _msgSender(), tokenId);

        _collectionForListings[cAddress].remove(tokenId);

        if (hasOffer(cAddress, tokenId)) {
            _removeOffer(cAddress, tokenId, true);
        }

        emit ListingSold(cAddress, tokenId, _msgSender(), msg.value);
    }

    function acceptOffer(address cAddress, uint256 tokenId) public onlyAdmin {
        require(hasOffer(cAddress, tokenId));
        address bidder = getHighestBidder(cAddress, tokenId);
        uint256 amount = getHighestAmount(cAddress, tokenId);
        NiftyKitCollection collection = NiftyKitCollection(cAddress);
        address creator = collection.ownerOf(tokenId);

        uint256 commission = _commissionValue(_commission, amount);
        payable(_treasury).transfer(commission);

        uint256 cCommission =
            _commissionValue(collection.getCommission(), amount);
        if (cCommission > 0) {
            payable(collection.owner()).transfer(cCommission);
        }

        payable(creator).transfer(amount - commission - cCommission);

        collection.transfer(creator, bidder, tokenId);

        removeOffer(cAddress, tokenId, false);

        if (hasListing(cAddress, tokenId)) {
            removeListing(cAddress, tokenId);
        }

        emit OfferAccepted(cAddress, tokenId, bidder, amount);
    }

    function _commissionValue(uint256 commission, uint256 amount)
        private
        pure
        returns (uint256)
    {
        return (commission * amount) / 10000;
    }
}//Unlicense
pragma solidity ^0.8.0;


contract NiftyKitMaster is NiftyKitOperator, NiftyKitStorefront {
    constructor(uint256 commission, address treasury) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        setCommission(commission);
        setTreasury(treasury);
    }
}