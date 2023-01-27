



pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity >=0.6.0 <0.8.0;

abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}




pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}




pragma solidity >=0.6.2 <0.8.0;

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

}




pragma solidity >=0.6.2 <0.8.0;

interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}




pragma solidity >=0.6.2 <0.8.0;

interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}




pragma solidity >=0.6.0 <0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}



pragma solidity =0.6.2;

library CountedMap {

    uint256 constant COUNTER_MASK = (1 << 128) - 1;

    struct Map {
        mapping(address => uint256) dict;
        address[] data;
    }

    function add(Map storage _map, address _who) internal {

        uint256 value = _map.dict[_who];
        if (value == 0) {
            _map.data.push(_who);
            _map.dict[_who] = _map.data.length << 128;
        } else {
            _map.dict[_who] = value + 1;
        }
    }

    function remove(Map storage _map, address _who) internal {

        uint256 value = _map.dict[_who];
        if ((value & COUNTER_MASK) == 0) {
            uint256 index = (value >> 128) - 1;
            uint256 last = _map.data.length - 1;
            address moved = _map.data[index] = _map.data[last];
            _map.dict[moved] = (_map.dict[moved] & COUNTER_MASK) | ((index + 1) << 128);
            _map.data.pop();
            delete _map.dict[_who];
        } else {
            _map.dict[_who] = value - 1;
        }
    }

    function length(Map storage _map) internal view returns(uint256) {

        return _map.data.length;
    }

    function at(Map storage _map, uint256 index) internal view returns(address) {

        return _map.data[index];
    }
}




pragma solidity >=0.6.0 <0.8.0;

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
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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
}




pragma solidity >=0.6.2 <0.8.0;

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
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity >=0.6.0 <0.8.0;



abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}



pragma solidity =0.6.2;

contract GravisCollectionMintable is Context, AccessControl {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() public {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    modifier onlyAdmin() {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "GravisCollectible: must have admin role");
        _;
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}



pragma solidity =0.6.2;

contract Whitelist is Ownable {

    event MemberAdded(address member);
    event MemberRemoved(address member);

    mapping(address => bool) private members;
    uint256 public whitelisted;

    function isMember(address _member) public view returns (bool) {

        return members[_member];
    }

    function addMember(address _member) public onlyOwner {

        address[] memory mem = new address[](1);
        mem[0] = _member;
        _addMembers(mem);
    }

    function addMembers(address[] memory _members) public onlyOwner {

        _addMembers(_members);
    }

    function removeMember(address _member) public onlyOwner {

        require(isMember(_member), "Whitelist: Not member of whitelist");

        delete members[_member];
        --whitelisted;
        emit MemberRemoved(_member);
    }

    function _addMembers(address[] memory _members) internal {

        uint256 l = _members.length;
        for (uint256 i = 0; i < l; i++) {
            require(!isMember(_members[i]), "Whitelist: Address is member already");

            members[_members[i]] = true;
            emit MemberAdded(_members[i]);
        }
        whitelisted += _members.length;
    }

    modifier canParticipate() {

        require(whitelisted == 0 || isMember(msg.sender), "Seller: not from private list");
        _;
    }
}



pragma solidity =0.6.2;









contract GravisCollectible is GravisCollectionMintable, Whitelist, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;
    using CountedMap for CountedMap.Map;

    uint256 internal constant VAULT_SIZE_SLOTS = 79;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    struct TokenVault {
        uint256[VAULT_SIZE_SLOTS] data;
    }
    struct TypeData {
        address minterOnly;
        string info;
        uint256 nominalPrice;
        uint256 totalSupply;
        uint256 maxSupply;
        TokenVault vault;
        string uri;
    }

    TypeData[] private typeData;
    mapping(address => TokenVault) private tokens;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    uint256 public last = 0;
    string public baseURI;
    CountedMap.Map owners;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor() public {
        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function name() external view override returns (string memory) {

        return "Gravis Finance Captains Collection";
    }

    function symbol() external view override returns (string memory) {

        return "GRVSCAPS";
    }

    function decimals() public pure virtual returns (uint8) {

        return 0;
    }

    function transfer(address, uint256) public pure virtual returns (bool) {

        require(false, "This type of token cannot be transferred from this type of wallet");
    }

    function tokenURI(uint256 _tokenId) external view override returns (string memory) {

        uint256 typ = getTokenType(_tokenId);
        require(typ != uint256(-1), "ERC721Metadata: URI query for nonexistent token");

        return string(abi.encodePacked(baseURI, typeData[typ].uri));
    }

    function balanceOf(address _who) public view override returns (uint256 res) {

        TokenVault storage cur = tokens[_who];
        for (uint256 index = 0; index < VAULT_SIZE_SLOTS; ++index) {
            uint256 val = cur.data[index];
            while (val != 0) {
                val &= val - 1;
                ++res;
            }
        }
    }

    function tokenOfOwnerByIndex(address _who, uint256 _index) public view virtual override returns (uint256) {

        TokenVault storage vault = tokens[_who];
        uint256 index = 0;
        uint256 bit = 0;
        uint256 cnt = 0;
        while (true) {
            uint256 val = vault.data[index];
            if (val != 0) {
                while (bit < 256 && (val & (1 << bit) == 0)) ++bit;
            }
            if (val == 0 || bit == 256) {
                bit = 0;
                ++index;
                require(index < VAULT_SIZE_SLOTS, "GravisCollectible: not enough tokens");
                continue;
            }
            if (cnt == _index) break;
            ++cnt;
            ++bit;
        }
        return index * 256 + bit;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return last;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {

        return index;
    }

    function getTypeInfo(uint256 _typeId)
        public
        view
        returns (
            uint256 nominalPrice,
            uint256 capSupply,
            uint256 maxSupply,
            string memory info,
            address minterOnly,
            string memory uri
        )
    {

        TypeData memory t = typeData[_typeId];

        return (t.nominalPrice, t.totalSupply, t.maxSupply, t.info, t.minterOnly, t.uri);
    }

    function getTokenType(uint256 _tokenId) public view returns (uint256) {

        if (_tokenId < last) {
            (uint256 index, uint256 mask) = _position(_tokenId);
            for (uint256 i = 0; i < typeData.length; ++i) {
                if (typeData[i].vault.data[index] & mask != 0) return i;
            }
        }
        return uint256(-1);
    }

    function approve(address _to, uint256 _tokenId) public virtual override {

        require(_to != _msgSender(), "ERC721: approval to current owner");
        require(isOwner(_msgSender(), _tokenId), "ERC721: approve caller is not owner");

        _approve(_to, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view virtual override returns (address) {

        require(exists(_tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) public virtual override {

        require(_operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][_operator] = _approved;
        emit ApprovalForAll(_msgSender(), _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view virtual override returns (bool) {

        return _operatorApprovals[_owner][_operator];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public virtual override {

        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721: transfer caller is not owner nor approved");

        _safeTransfer(_from, _to, _tokenId, _data);
    }

    function exists(uint256 _tokenId) public view returns (bool) {

        return getTokenType(_tokenId) != uint256(-1);
    }

    function setBaseURI(string memory _baseURI) public onlyAdmin {

        baseURI = _baseURI;
    }

    function createNewTokenType(
        uint256 _nominalPrice,
        uint256 _maxTotal,
        string memory _info,
        string memory _uri
    ) public onlyAdmin {

        require(_nominalPrice != 0, "GravisCollectible: nominal price is zero");

        TypeData memory t;
        t.nominalPrice = _nominalPrice;
        t.maxSupply = _maxTotal;
        t.info = _info;
        t.uri = _uri;

        typeData.push(t);
    }

    function setMinterOnly(address _minter, uint256 _type) external onlyAdmin {

        require(typeData[_type].minterOnly == address(0), "GravisCollectible: minter locked already");

        typeData[_type].minterOnly = _minter;
    }

    function addMinter(address _newMinter) public onlyAdmin {

        _setupRole(MINTER_ROLE, _newMinter);
    }

    function mint(
        address _to,
        uint256 _type,
        uint256 _amount
    ) public returns (uint256) {

        require(hasRole(MINTER_ROLE, _msgSender()), "GravisCollectible: must have minter role to mint");
        require(_type < typeData.length, "GravisCollectible: type not exist");
        TypeData storage currentType = typeData[_type];
        if (currentType.minterOnly != address(0)) {
            require(typeData[_type].minterOnly == _msgSender(), "GravisCollectible: minting locked by another account");
        }

        return _mint(_to, _type, _amount);
    }

    function mintFor(address[] calldata _to, uint256[] calldata _amount, uint256 _type) external {

        require(hasRole(MINTER_ROLE, _msgSender()), "GravisCollectible: must have minter role to mint");
        require(_to.length == _amount.length, "GravisCollectible: input arrays don't match");
        require(_type < typeData.length, "GravisCollectible: type not exist");
        TypeData storage currentType = typeData[_type];
        if (currentType.minterOnly != address(0)) {
            require(typeData[_type].minterOnly == _msgSender(), "GravisCollectible: minting locked by another account");
        }

        for (uint256 i = 0; i < _to.length; ++i) {
            _mint(_to[i], _type, _amount[i]);
        }
    }

    function _mint(
        address _to,
        uint256 _type,
        uint256 _amount
    ) internal returns (uint256) {

        require(_to != address(0), "GravisCollectible: mint to the zero address");

        TokenVault storage vaultUser = tokens[_to];
        TokenVault storage vaultType = typeData[_type].vault;
        uint256 tokenId = last;
        (uint256 index, uint256 mask) = _position(tokenId);
        uint256 userBuf = vaultUser.data[index];
        uint256 typeBuf = vaultType.data[index];
        while (tokenId < last.add(_amount)) {
            userBuf |= mask;
            typeBuf |= mask;
            mask <<= 1;
            if (mask == 0) {
                mask = 1;
                vaultUser.data[index] = userBuf;
                vaultType.data[index] = typeBuf;
                ++index;
                userBuf = vaultUser.data[index];
                typeBuf = vaultType.data[index];
            }
            emit Transfer(address(0), _to, tokenId);
            ++tokenId;
        }
        last = tokenId;
        vaultUser.data[index] = userBuf;
        vaultType.data[index] = typeBuf;
        typeData[_type].totalSupply = typeData[_type].totalSupply.add(_amount);
        owners.add(_to);
        require(typeData[_type].totalSupply <= typeData[_type].maxSupply, "GravisCollectible: max supply reached");

        return last;
    }

    function transferFromContract(address _to, uint256 _tokenId) public onlyAdmin returns (bool) {

        _transfer(address(this), _to, _tokenId);

        return true;
    }

    function ownerOf(uint256 _tokenId) public view override returns (address) {

        (uint256 index, uint256 mask) = _position(_tokenId);
        if (tokens[_msgSender()].data[index] & mask != 0) return _msgSender();
        for (uint256 i = 0; i < owners.length(); ++i) {
            address candidate = owners.at(i);
            if (tokens[candidate].data[index] & mask != 0) return candidate;
        }
        return address(0);
    }

    function isOwner(address _who, uint256 _tokenId) public view returns (bool) {

        (uint256 index, uint256 mask) = _position(_tokenId);
        return tokens[_who].data[index] & mask != 0;
    }

    function ownersLength() public view returns (uint256) {

        return owners.length();
    }

    function ownerAt(uint256 _index) public view returns (address) {

        return owners.at(_index);
    }

    function burn(uint256 _tokenId) public {

        _burnFor(_msgSender(), _tokenId);
    }

    function burnFor(
        address _who,
        uint256 _type,
        uint256 _amount
    ) public {

        require(_who == _msgSender() || isApprovedForAll(_who, _msgSender()), "GravisCollectible: must have approval");
        require(_type < typeData.length, "GravisCollectible: type not exist");

        TokenVault storage vaultUser = tokens[_who];
        TokenVault storage vaultType = typeData[_type].vault;
        uint256 index = 0;
        uint256 burned = 0;
        uint256 userBuf;
        uint256 typeBuf;
        while (burned < _amount) {
            while (index < VAULT_SIZE_SLOTS && vaultUser.data[index] == 0) ++index;
            require(index < VAULT_SIZE_SLOTS, "GravisCollectible: not enough tokens");
            userBuf = vaultUser.data[index];
            typeBuf = vaultType.data[index];
            uint256 bit = 0;
            while (burned < _amount) {
                while (bit < 256) {
                    uint256 mask = 1 << bit;
                    if (userBuf & mask != 0 && typeBuf & mask != 0) break;
                    ++bit;
                }
                if (bit == 256) {
                    vaultUser.data[index] = userBuf;
                    vaultType.data[index] = typeBuf;
                    ++index;
                    break;
                }
                uint256 tokenId = index * 256 + bit;
                _approve(address(0), tokenId);
                uint256 mask = ~(1 << bit);
                userBuf &= mask;
                typeBuf &= mask;
                emit Transfer(_who, address(0), tokenId);
                ++burned;
            }
        }
        vaultUser.data[index] = userBuf;
        vaultType.data[index] = typeBuf;
        owners.remove(_who);
    }

    function transferFor(
        address _from,
        address _to,
        uint256 _type,
        uint256 _amount
    ) public {

        require(_from == _msgSender() || isApprovedForAll(_from, _msgSender()), "GravisCollectible: must have approval");
        require(_type < typeData.length, "GravisCollectible: type not exist");

        TokenVault storage vaultFrom = tokens[_from];
        TokenVault storage vaultTo = tokens[_to];
        TokenVault storage vaultType = typeData[_type].vault;
        uint256 index = 0;
        uint256 transfered = 0;
        uint256 fromBuf;
        uint256 toBuf;
        while (transfered < _amount) {
            while (index < VAULT_SIZE_SLOTS && vaultFrom.data[index] == 0) ++index;
            require(index < VAULT_SIZE_SLOTS, "GravisCollectible: not enough tokens");
            fromBuf = vaultFrom.data[index];
            toBuf = vaultTo.data[index];
            uint256 bit = 0;
            while (transfered < _amount) {
                while (bit < 256) {
                    uint256 mask = 1 << bit;
                    if (fromBuf & mask != 0 && vaultType.data[index] & mask != 0) break;
                    ++bit;
                }
                if (bit == 256) {
                    vaultFrom.data[index] = fromBuf;
                    vaultTo.data[index] = toBuf;
                    ++index;
                    break;
                }
                uint256 tokenId = index * 256 + bit;
                _approve(address(0), tokenId);
                uint256 mask = 1 << bit;
                toBuf |= mask;
                fromBuf &= ~mask;
                emit Transfer(_from, _to, tokenId);
                ++transfered;
            }
        }
        vaultFrom.data[index] = fromBuf;
        vaultTo.data[index] = toBuf;
        owners.add(_to);
        owners.remove(_from);
    }

    function _approve(address _to, uint256 _tokenId) internal virtual {

        if (_tokenApprovals[_tokenId] != _to) {
            _tokenApprovals[_tokenId] = _to;
            emit Approval(_msgSender(), _to, _tokenId); // internal owner
        }
    }

    function _burnFor(address _who, uint256 _tokenId) internal virtual {

        (uint256 index, uint256 mask) = _position(_tokenId);
        require(tokens[_who].data[index] & mask != 0, "not owner");

        _approve(address(0), _tokenId);

        mask = ~mask;
        tokens[_who].data[index] &= mask;
        for (uint256 i = 0; i < typeData.length; ++i) {
            typeData[i].vault.data[index] &= mask;
        }
        owners.remove(_who);

        emit Transfer(_who, address(0), _tokenId);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual {

        require(isOwner(_from, _tokenId), "ERC721: transfer of token that is not own"); // internal owner
        require(_to != address(0), "ERC721: transfer to the zero address");

        _approve(address(0), _tokenId);

        (uint256 index, uint256 mask) = _position(_tokenId);
        tokens[_from].data[index] &= ~mask;
        tokens[_to].data[index] |= mask;
        owners.add(_to);
        owners.remove(_from);

        emit Transfer(_from, _to, _tokenId);
    }

    function _safeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(_from, _to, _tokenId);
        require(
            _checkOnERC721Received(_from, _to, _tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _checkOnERC721Received(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (!_to.isContract()) {
            return true;
        }
        bytes memory returndata =
            _to.functionCall(
                abi.encodeWithSelector(
                    IERC721Receiver(_to).onERC721Received.selector,
                    _msgSender(),
                    _from,
                    _tokenId,
                    _data
                ),
                "ERC721: transfer to non ERC721Receiver implementer"
            );
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view virtual returns (bool) {

        if (isOwner(_spender, _tokenId)) return true;
        return (getApproved(_tokenId) == _spender || isApprovedForAll(ownerOf(_tokenId), _spender));
    }

    function _position(uint256 _tokenId) internal pure returns (uint256 index, uint256 mask) {

        index = _tokenId / 256;
        require(index < VAULT_SIZE_SLOTS, "GravisCollectible: OOB");
        mask = uint256(1 << (_tokenId % 256));
    }
}