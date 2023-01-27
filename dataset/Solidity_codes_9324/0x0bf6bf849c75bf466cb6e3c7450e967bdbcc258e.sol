



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
}




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




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




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

}




pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}




pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




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
}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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

}



pragma solidity ^0.8.0;



interface IERC721Factory is IAccessControl{


    event TokenContractCreated(address indexed addr);

    function createContract(string memory name, string memory symbol, address[] memory admins, address[] memory minters, address[] memory pausers) external returns(address);

}




pragma solidity ^0.8.0;





interface IExportableERC721 is IERC721, IERC721Metadata, IERC721Enumerable{


    enum State { Exporting, Exported, Imported }

    function enableExport(bool enabled) external;


    function isExportable() external view returns(bool);


    function enableImport(bool enabled) external;


    function isImportable() external view returns(bool);


    function exporting(uint256 tokenId, address escrowee) external;


    function exported(uint256 tokenId) external;


    function imported(uint256 preferredTokenId, address owner) external returns(uint256 tokenId);



    function countStatedTokens(State state) external view returns(uint256);


    function statedTokens(State state) external view returns(uint256[] memory);


    function mint(address to) external;


    function setTokenURI(uint256 tokenId, string memory uri) external;


    function pause() external;


    function unpause() external;

}



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
}




pragma solidity ^0.8.0;


interface IAccessControlEnumerable is IAccessControl {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}




pragma solidity ^0.8.0;




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

    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}



pragma solidity ^0.8.0;








struct Request {
    address owner;
    uint256 at;
    address requester;
}

contract ERC721Bridge2 is Context, AccessControlEnumerable{

    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;


    EnumerableSet.AddressSet private _localContracts;

    IERC721Factory private _contrFactory;

    Counters.Counter private _exportIdTracker;

    event TokenContractDeployed(address indexed addr, string name, string symbol);
    event Exporting(uint256 exportId, uint256 srcChainId, address indexed srcContr, uint256 indexed srcTokenId, address srcOwner, uint256 dstChainId, address dstContr, address dstOwner);
    event Imported(uint256 exportId, uint256 srcChainId, address srcContr, uint256 srcTokenId, address srcOwner, uint256 dstChainId, address indexed dstContr, uint256 indexed dstTokenId, address dstOwner);
    event Exported(uint256 exportId, uint256 srcChainId, address indexed srcContr, uint256 indexed srcTokenId, address srcOwner, uint256 dstChainId, address dstContr, uint256 dstTokenId, address dstOwner);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function beginExportToken(address srcContr, uint256 srcTokenId, address srcOwner, uint256 dstChainId, address dstContr, address dstOwner) public virtual {


        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721Bridge: Only admin can begin export");
        _validateExport(srcContr, srcTokenId, srcOwner, dstChainId, dstContr, dstOwner);

        IExportableERC721(srcContr).exporting(srcTokenId, address(this));

        emit Exporting(_exportIdTracker.current(), block.chainid, srcContr, srcTokenId, srcOwner, dstChainId, dstContr, dstOwner);
        _exportIdTracker.increment();
    }

    function _validateExport(address srcContr, uint256 srcTokenId, address srcOwner, uint256 dstChainId, address dstContr, address dstOwner) internal view virtual {

        
        require(block.chainid != dstChainId, "ERC721Bridge: Intra-chain exporting is not allowed.");
        require(_localContracts.contains(srcContr), "ERC721Bridge: Unresgistered source contract.");
        require(IExportableERC721(srcContr).ownerOf(srcTokenId) == srcOwner, "ERC721Bridge: Improper token or owner.");
        require(dstContr != address(0), "ERC721Bridge: Can't export to zero address contract.");
        require(dstOwner != address(0), "ERC721Bridge: Can't export to zero address owner.");
    }

    function importToken(uint256 exportId, uint256 srcChainId, address srcContr, uint256 srcTokenId, address srcOwner, address dstContr, address dstOwner, string memory dstTokenUri) public virtual returns(uint256 tokenId) {

 
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721Bridge: Only admin can request import.");
        _validateImport(srcChainId, dstContr, dstOwner);

        tokenId = IExportableERC721(dstContr).imported(srcTokenId, dstOwner);
        IExportableERC721(dstContr).setTokenURI(tokenId, dstTokenUri);

        emit Imported(exportId, srcChainId, srcContr, srcTokenId, srcOwner, block.chainid, dstContr, tokenId, dstOwner);
    }

    function _validateImport(uint256 srcChainId, address contr, address owner) internal view virtual {


        require(block.chainid != srcChainId, "ERC721Bridge: Intra-chain importing is not allowed.");
        require(_localContracts.contains(contr), "ERC721Bridge: Unregistered destination contract.");
        require(owner != address(0), "ERC721Bridge: Importing to zero address is not allowed.");
    }

    function completeExportToken(uint256 exportId, address srcContr, uint256 srcTokenId, address srcOwner, uint256 dstChainId, address dstContr, uint256 dstTokenId, address dstOwner) public virtual {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721Bridge: Only admin can complete export.");

        require(block.chainid != dstChainId, "ERC721Bridge: Intra-chain exporting is not allowed.");
        require(_localContracts.contains(srcContr), "ERC721Bridge: Unresgistered source contract");

        IExportableERC721(srcContr).exported(srcTokenId);
        emit Exported(exportId, block.chainid, srcContr, srcTokenId, srcOwner, dstChainId, dstContr, dstTokenId, dstOwner);
    }

    function tokenContractFactory() public view returns(address){

        return address(_contrFactory);
    }

    function setTokenContractFactory(IERC721Factory factory) public {



        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721Bridge: Must be admin to change token factory.");
        require(address(factory) != address(0), "ERC721Bridge: Zero address is not allowed.");
        require(factory.hasRole(DEFAULT_ADMIN_ROLE, address(this)), "ERC721Bridge: Factory need to be adminable.");
         _contrFactory = factory;
    }

    function localTokenContracts() public view returns(address[] memory){

        return _localContracts.values();
    }

    function localTokenContractsCount() public view returns(uint256){

        return _localContracts.length();
    }

    function hasLocalContract(address addr) public view returns(bool){

        return _localContracts.contains(addr);
    }

    function localTokenContract(uint256 index) public view returns(address){

        return _localContracts.at(index);
    }

    function addLocalTokenContracts(address[] memory contrs) public {


        for(uint256 i = 0; i < contrs.length; i++) _addLocalTokenContract(contrs[i]);
    }

    function addLocalTokenContract(address contr) public {

        _addLocalTokenContract(contr);
    }

    function _addLocalTokenContract(address contr) internal {

        require(IAccessControl(contr).hasRole(DEFAULT_ADMIN_ROLE, address(this)), "ERC721Bridge: Contract to register is not admined by this.");
        _localContracts.add(contr);
    }
 
    function deployTokenContract(string memory name, string memory symbol, 
        address[] memory admins, address[] memory minters, address[] memory pausers, bool exportable, bool importable) public virtual returns (address){

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721Bridge: Must be admin to deploy token contract.");

        address[] memory minters2 = new address[](minters.length + 1);
        for(uint256 i = 0; i < minters.length; i++){
            minters2[i] = minters[i];
        }
        minters2[minters.length] = address(this);

        address addr = _contrFactory.createContract(name, symbol, admins, minters2, pausers);
        if(exportable) IExportableERC721(addr).enableExport(true);
        if(importable) IExportableERC721(addr).enableImport(true);
        _localContracts.add(addr);

        emit TokenContractDeployed(addr, name, symbol);
        return addr;
    }


}