

pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
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
}


pragma solidity ^0.6.0;

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


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.6.0;




abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

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


pragma solidity ^0.6.6;


contract MinterRole is AccessControl {


    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    constructor () internal {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        emit MinterAdded(_msgSender());
    }

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function addMinter(address account) public onlyMinter {

        grantRole(DEFAULT_ADMIN_ROLE, account);
        emit MinterAdded(account);
    }

    function renounceMinter() public {

        renounceRole(DEFAULT_ADMIN_ROLE, _msgSender());
        emit MinterRemoved(_msgSender());
    }

}


pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.6.6;

abstract contract IERC721Receiver {

    bytes4 constant internal ERC721_RECEIVED = 0x150b7a02;

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data
    ) external virtual returns (bytes4);
}


pragma solidity ^0.6.6;

interface IERC721 {

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address owner,address operator) external view returns (bool);


    function transferFrom(address from, address to, uint256 tokenId) external;


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}


pragma solidity ^0.6.6;

interface IERC721Metadata {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}


pragma solidity ^0.6.6;

interface IERC1155 {


    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _value
    );

    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _values
    );

    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    event URI(
        string _value,
        uint256 indexed _id
    );

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;


    function balanceOf(address owner, uint256 id) external view returns (uint256);


    function balanceOfBatch(
        address[] calldata owners,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}


pragma solidity ^0.6.6;

interface IERC1155MetadataURI {

    function uri(uint256 id) external view returns (string memory);

}


pragma solidity ^0.6.6;

interface IERC1155AssetCollections {


    function collectionOf(uint256 id) external view returns (uint256);


    function isFungible(uint256 id) external view returns (bool);


    function ownerOf(uint256 tokenId) external view returns (address owner);

}


pragma solidity ^0.6.6;

abstract contract IERC1155TokenReceiver {

    bytes4 constant internal ERC1155_RECEIVED = 0xf23a6e61;

    bytes4 constant internal ERC1155_BATCH_RECEIVED = 0xbc197c81;

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external virtual returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external virtual returns (bytes4);
}


pragma solidity ^0.6.6;












abstract contract AssetsInventory is IERC165, IERC721, IERC721Metadata, IERC1155, IERC1155MetadataURI, IERC1155AssetCollections, Context
{
    bytes4 constant internal ERC721_RECEIVED = 0x150b7a02;

    bytes4 constant internal ERC1155_RECEIVED = 0xf23a6e61;

    bytes4 constant internal ERC1155_BATCH_RECEIVED = 0xbc197c81;

    bytes4 constant internal ERC165_InterfaceId = 0x01ffc9a7;

    bytes4 constant internal ERC1155TokenReceiver_InterfaceId = 0x4e2312e0;

    mapping(uint256 => mapping(address => uint256)) internal _balances;

    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    mapping(uint256 => address) internal _tokenApprovals;

    mapping(uint256 => address) internal _owners;

    mapping(address => uint256) internal _nftBalances;

    uint256 internal constant NF_BIT_MASK = 1 << 255;

    uint256 internal NF_COLLECTION_MASK;

    constructor(uint256 nfMaskLength) internal {
        require(nfMaskLength > 0 && nfMaskLength < 256);
        uint256 mask = (1 << nfMaskLength) - 1;
        mask = mask << (256 - nfMaskLength);
        NF_COLLECTION_MASK = mask;
    }

    function _uri(uint256 id) internal virtual view returns(string memory);


    function supportsInterface(bytes4 interfaceId) external virtual override view returns (bool) {
        return (
            interfaceId == 0x01ffc9a7 ||
            interfaceId == 0x80ac58cd ||
            interfaceId == 0x5b5e139f ||
            interfaceId == 0x4f558e79 ||
            interfaceId == 0xd9b67a26 ||
            interfaceId == 0x0e89341c ||
            interfaceId == 0x09ce5c46
        );
    }

    function balanceOf(address tokenOwner) public virtual override view returns (uint256) {
        require(tokenOwner != address(0x0));
        return _nftBalances[tokenOwner];
    }

    function ownerOf(uint256 tokenId) public virtual override(IERC1155AssetCollections, IERC721) view returns (address) {
        require(isNFT(tokenId));
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0x0));
        return tokenOwner;
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address tokenOwner = ownerOf(tokenId);
        require(to != tokenOwner); // solium-disable-line error-reason

        address sender = _msgSender();
        require(sender == tokenOwner || _operatorApprovals[tokenOwner][sender]); // solium-disable-line error-reason

        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public virtual override view returns (address) {
        require(isNFT(tokenId) && exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public virtual override(IERC1155, IERC721) {
        address sender = _msgSender();
        require(to != sender);
        _setApprovalForAll(sender, to, approved);
    }

    function _setApprovalForAll(address sender, address operator, bool approved) internal virtual {
        _operatorApprovals[sender][operator] = approved;
        emit ApprovalForAll(sender, operator, approved);
    }

    function isApprovedForAll(address tokenOwner, address operator) public virtual override(IERC1155, IERC721) view returns (bool) {
        return _operatorApprovals[tokenOwner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        _transferFrom(from, to, tokenId, "", false);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        _transferFrom(from, to, tokenId, "", true);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        _transferFrom(from, to, tokenId, data, true);
    }

    function tokenURI(uint256 tokenId) external virtual override view returns (string memory) {
        require(exists(tokenId));
        return _uri(tokenId);
    }


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public virtual override
    {
        address sender = _msgSender();
        bool operatable = (from == sender || _operatorApprovals[from][sender] == true);

        if (isFungible(id) && value > 0) {
            require(operatable);
            _transferFungible(from, to, id, value);
        } else if (isNFT(id) && value == 1) {
            _transferNonFungible(from, to, id, operatable);
            emit Transfer(from, to, id);
        } else {
            revert();
        }

        emit TransferSingle(sender, from, to, id, value);
        require(_checkERC1155AndCallSafeTransfer(sender, from, to, id, value, data, false, false));
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual override
    {
        require(ids.length == values.length);

        address sender = _msgSender();
        require(from == sender || _operatorApprovals[from][sender] == true);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 value = values[i];

            if (isFungible(id) && value > 0) {
                _transferFungible(from, to, id, value);
            } else if (isNFT(id) && value == 1) {
                _transferNonFungible(from, to, id, true);
                emit Transfer(from, to, id);
            } else {
                revert();
            }
        }

        emit TransferBatch(sender, from, to, ids, values);
        require(_checkERC1155AndCallSafeBatchTransfer(sender, from, to, ids, values, data));
    }

    function balanceOf(address tokenOwner, uint256 id) public virtual override view returns (uint256) {
        require(tokenOwner != address(0x0));

        if (isNFT(id)) {
            return _owners[id] == tokenOwner ? 1 : 0;
        }

        return _balances[id][tokenOwner];
    }

    function balanceOfBatch(
        address[] memory tokenOwners,
        uint256[] memory ids
    ) public virtual override view returns (uint256[] memory)
    {
        require(tokenOwners.length == ids.length);

        uint256[] memory balances = new uint256[](tokenOwners.length);

        for (uint256 i = 0; i < tokenOwners.length; ++i) {
            require(tokenOwners[i] != address(0x0));

            uint256 id = ids[i];

            if (isNFT(id)) {
                balances[i] = _owners[id] == tokenOwners[i] ? 1 : 0;
            } else {
                balances[i] = _balances[id][tokenOwners[i]];
            }
        }

        return balances;
    }

    function uri(uint256 id) external virtual override view returns (string memory) {
        return _uri(id);
    }


    function collectionOf(uint256 id) public virtual override view returns (uint256) {
        require(isNFT(id));
        return id & NF_COLLECTION_MASK;
    }

    function isFungible(uint256 id) public virtual override view returns (bool) {
        return id & (NF_BIT_MASK) == 0;
    }

    function isNFT(uint256 id) internal virtual view returns (bool) {
        return (id & (NF_BIT_MASK) != 0) && (id & (~NF_COLLECTION_MASK) != 0);
    }

    function exists(uint256 id) public virtual view returns (bool) {
        address tokenOwner = _owners[id];
        return tokenOwner != address(0x0);
    }


    function _transferFrom(address from, address to, uint256 tokenId, bytes memory data, bool safe) internal virtual {
        require(isNFT(tokenId));

        address sender = _msgSender();
        bool operatable = (from == sender || _operatorApprovals[from][sender] == true);

        _transferNonFungible(from, to, tokenId, operatable);

        emit Transfer(from, to, tokenId);
        emit TransferSingle(sender, from, to, tokenId, 1);

        require(_checkERC1155AndCallSafeTransfer(sender, from, to, tokenId, 1, data, true, safe));
    }

    function _transferNonFungible(address from, address to, uint256 id, bool operatable) internal virtual {
        require(from == _owners[id]);

        address sender = _msgSender();
        require(operatable || ownerOf(id) == sender || getApproved(id) == sender);

        if (_tokenApprovals[id] != address(0x0)) {
            _tokenApprovals[id] = address(0x0);
        }

        uint256 nfCollection = id & NF_COLLECTION_MASK;
        _balances[nfCollection][from] = SafeMath.sub(_balances[nfCollection][from], 1);
        _nftBalances[from] = SafeMath.sub(_nftBalances[from], 1);

        _owners[id] = to;

        if (to != address(0x0)) {
            _balances[nfCollection][to] = SafeMath.add(_balances[nfCollection][to], 1);
            _nftBalances[to] = SafeMath.add(_nftBalances[to], 1);
        }
    }

    function _transferFungible(address from, address to, uint256 collectionId, uint256 value) internal virtual {
        _balances[collectionId][from] = SafeMath.sub(_balances[collectionId][from], value);

        if (to != address(0x0)) {
            _balances[collectionId][to] = SafeMath.add(_balances[collectionId][to], value);
        }
    }


    function _mintNonFungible(address to, uint256 id, bool typeChecked) internal virtual {
        require(to != address(0x0));
        if (!typeChecked) {
            require(isNFT(id));
        }
        require(!exists(id));

        uint256 collection = id & NF_COLLECTION_MASK;

        _owners[id] = to;
        _nftBalances[to] = SafeMath.add(_nftBalances[to], 1);
        _balances[collection][to] = SafeMath.add(_balances[collection][to], 1);

        emit Transfer(address(0x0), to, id);
        emit TransferSingle(_msgSender(), address(0x0), to, id, 1);

        emit URI(_uri(id), id);

        require(
            _checkERC1155AndCallSafeTransfer(_msgSender(), address(0x0), to, id, 1, "", false, false), "failCheck"
        );
    }

    function _mintFungible(address to, uint256 collection, uint256 value, bool typeChecked) internal virtual {
        require(to != address(0x0));
        if (!typeChecked) {
            require(isFungible(collection));
        }
        require(value > 0);

        _balances[collection][to] = SafeMath.add(_balances[collection][to], value);

        emit TransferSingle(_msgSender(), address(0x0), to, collection, value);

        require(
            _checkERC1155AndCallSafeTransfer(_msgSender(), address(0x0), to, collection, value, "", false, false), "failCheck"
        );
    }


    function _checkERC721AndCallSafeTransfer(
        address operator,
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal returns(bool)
    {
        if (!Address.isContract(to)) {
            return true;
        }
        return IERC721Receiver(to).onERC721Received(operator, from, tokenId, data) == ERC721_RECEIVED;
    }

    function _checkERC1155AndCallSafeTransfer(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data,
        bool erc721,
        bool erc721Safe
    ) internal returns (bool)
    {
        if (!Address.isContract(to)) {
            return true;
        }
        if (erc721) {
            if (!_checkIsERC1155Receiver(to)) {
                if (erc721Safe) {
                    return _checkERC721AndCallSafeTransfer(operator, from, to, id, data);
                } else {
                    return true;
                }
            }
        }
        return IERC1155TokenReceiver(to).onERC1155Received(operator, from, id, value, data) == ERC1155_RECEIVED;
    }

    function _checkERC1155AndCallSafeBatchTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal returns (bool)
    {
        if (!Address.isContract(to)) {
            return true;
        }
        return IERC1155TokenReceiver(to).onERC1155BatchReceived(operator, from, ids, values, data) == ERC1155_BATCH_RECEIVED;
    }

    function _checkIsERC1155Receiver(address _contract) internal view returns(bool) {
        bool success;
        uint256 result;
        assembly {
            let x:= mload(0x40)               // Find empty storage location using "free memory pointer"
            mstore(x, ERC165_InterfaceId)                // Place signature at beginning of empty storage
            mstore(add(x, 0x04), ERC1155TokenReceiver_InterfaceId) // Place first argument directly next to signature

            success:= staticcall(
                10000,          // 10k gas
                _contract,     // To addr
                x,             // Inputs are stored at location x
                0x24,          // Inputs are 36 bytes long
                x,             // Store output over input (saves space)
                0x20)          // Outputs are 32 bytes long

            result:= mload(x)                 // Load the result
        }
        assert(gasleft() > 158);
        return success && result == 1;
    }
}


pragma solidity ^0.6.6;


abstract contract NonBurnableInventory is AssetsInventory
{

    constructor(uint256 nfMaskLength) internal AssetsInventory(nfMaskLength)  {}

    modifier notZero(address addr) {
        require(addr != address(0x0));
        _;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public virtual override notZero(to) {
        super.safeTransferFrom(from, to, id, value, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual override notZero(to) {
        super.safeBatchTransferFrom(from, to, ids, values, data);
    }

    function _transferFrom(address from, address to, uint256 tokenId, bytes memory data, bool safe
    ) internal virtual override notZero(to) {
        super._transferFrom(from, to, tokenId, data, safe);
    }
}


pragma solidity ^0.6.6;

library RichUInt256 {


    function toString(uint256 i) internal pure returns (string memory) {

        return toString(i, 10);
    }

    function toString(uint256 i, uint8 base) internal pure returns (string memory) {

        if (base == 10) {
            return toDecimalString(i);
        } else if (base == 16) {
            return toHexString(i);
        } else {
            revert("Base must be either 10 or 16");
        }
    }

    function toDecimalString(uint256 i) internal pure returns (string memory) {

        if (i == 0) {
            return "0";
        }

        uint256 j = i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (i != 0) {
            bstr[k--] = bytes1(uint8(48 + (i % 10)));
            i /= 10;
        }

        return string(bstr);
    }

    function toHexString(uint256 i) internal pure returns (string memory) {

        uint length = 64;
        uint mask = 15;
        bytes memory bstr = new bytes(length);
        int k = int(length - 1);
        while (i != 0) {
            uint curr = (i & mask);
            bstr[uint(k--)] = curr > 9 ? byte(uint8(87 + curr)) : byte(uint8(48 + curr)); // 87 = 97 - 10
            i = i >> 4;
        }
        while (k >= 0) {
            bstr[uint(k--)] = byte(uint8(48));
        }
        return string(bstr);
    }
}


pragma solidity ^0.6.6;


contract URI {


    using RichUInt256 for uint256;

    function _fullUriFromId(uint256 id) internal pure returns (string memory) {

        return string(abi.encodePacked("https://prefix/json/", id.toString()));
    }

}


pragma solidity ^0.6.6;





contract NonBurnableInventoryMock is NonBurnableInventory, Ownable, MinterRole, URI {


    string public override constant name = "NonBurnableInventoryMock";
    string public override constant symbol = "NBIM";

    constructor(uint256 nfMaskLength) public NonBurnableInventory(nfMaskLength) {}

    function createCollection(uint256 collectionId) onlyOwner external {

        require(!isNFT(collectionId));
        emit URI(_uri(collectionId), collectionId);
    }

    function batchMint(address[] calldata to, uint256[] calldata ids, uint256[] calldata values) external onlyMinter {

        require(ids.length == to.length &&
            ids.length == values.length,
            "parameter length inconsistent");

        for (uint i = 0; i < ids.length; i++) {
            if (isNFT(ids[i]) && values[i] == 1) {
                _mintNonFungible(to[i], ids[i], true);
            } else if (isFungible(ids[i])) {
                _mintFungible(to[i], ids[i], values[i], true);
            } else {
                revert("Incorrect id");
            }
        }
    }

    function mintNonFungible(address to, uint256 tokenId) onlyMinter external {

        _mintNonFungible(to, tokenId, false);
    }

    function mintFungible(address to, uint256 collection, uint256 value) onlyMinter external {

        _mintFungible(to, collection, value, false);
    }

    function _uri(uint256 id) internal override view returns (string memory) {

        return _fullUriFromId(id);
    }
}



pragma solidity ^0.6.6;

interface IERC20 {


    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}


pragma solidity ^0.6.6;


contract PayoutWallet is Ownable
{

    event PayoutWalletSet(address payoutWallet);

    address payable public _payoutWallet;

    constructor(address payoutWallet) internal {
        setPayoutWallet(payoutWallet);
    }

    function setPayoutWallet(address payoutWallet) public onlyOwner {

        require(payoutWallet != address(0), "The payout wallet must not be the zero address");
        require(payoutWallet != address(this), "The payout wallet must not be the contract itself");
        require(payoutWallet != _payoutWallet, "The payout wallet must be different");
        _payoutWallet = payable(payoutWallet);
        emit PayoutWalletSet(_payoutWallet);
    }
}


pragma solidity ^0.6.0;


contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
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



pragma solidity ^0.6.6;

interface IERC20Detailed {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


pragma solidity ^0.6.6;



interface IKyber {

    function getExpectedRate(IERC20 src, IERC20 dest, uint srcQty) external view
        returns (uint expectedRate, uint slippageRate);


    function trade(
        IERC20 src,
        uint srcAmount,
        IERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    )
    external
    payable
        returns(uint);

}


pragma solidity ^0.6.6;





contract KyberAdapter {

    using SafeMath for uint256;

    IKyber public kyber;

    IERC20 public ETH_ADDRESS = IERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    constructor(address _kyberProxy) public {
        kyber = IKyber(_kyberProxy);
    }

    fallback () external payable {}

    receive () external payable {}

    function _getTokenDecimals(IERC20 _token) internal view returns (uint8 _decimals) {

        return _token != ETH_ADDRESS ? IERC20Detailed(address(_token)).decimals() : 18;
    }

    function _getTokenBalance(IERC20 _token, address _account) internal view returns (uint256 _balance) {

        return _token != ETH_ADDRESS ? _token.balanceOf(_account) : _account.balance;
    }

    function ceilingDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {

        return a.div(b).add(a.mod(b) > 0 ? 1 : 0);
    }

    function _fixTokenDecimals(
        IERC20 _src,
        IERC20 _dest,
        uint256 _unfixedDestAmount,
        bool _ceiling
    )
    internal
    view
    returns (uint256 _destTokenAmount)
    {

        uint256 _unfixedDecimals = _getTokenDecimals(_src) + 18; // Kyber by default returns rates with 18 decimals.
        uint256 _decimals = _getTokenDecimals(_dest);

        if (_unfixedDecimals > _decimals) {
            if (_ceiling) {
                return ceilingDiv(_unfixedDestAmount, (10 ** (_unfixedDecimals - _decimals)));
            } else {
                return _unfixedDestAmount.div(10 ** (_unfixedDecimals - _decimals));
            }
        } else {
            return _unfixedDestAmount.mul(10 ** (_decimals - _unfixedDecimals));
        }
    }

    function _convertToken(
        IERC20 _src,
        uint256 _srcAmount,
        IERC20 _dest
    )
    internal
    view
    returns (
        uint256 _expectedAmount,
        uint256 _slippageAmount
    )
    {

        (uint256 _expectedRate, uint256 _slippageRate) = kyber.getExpectedRate(_src, _dest, _srcAmount);

        return (
            _fixTokenDecimals(_src, _dest, _srcAmount.mul(_expectedRate), false),
            _fixTokenDecimals(_src, _dest, _srcAmount.mul(_slippageRate), false)
        );
    }

    function _swapTokenAndHandleChange(
        IERC20 _src,
        uint256 _maxSrcAmount,
        IERC20 _dest,
        uint256 _maxDestAmount,
        uint256 _minConversionRate,
        address payable _initiator,
        address payable _receiver
    )
    internal
    returns (
        uint256 _srcAmount,
        uint256 _destAmount
    )
    {

        if (_src == _dest) {
            require(_maxSrcAmount >= _maxDestAmount);
            _destAmount = _srcAmount = _maxDestAmount;
            require(_src.transferFrom(_initiator, address(this), _destAmount));
        } else {
            require(_src == ETH_ADDRESS ? msg.value >= _maxSrcAmount : msg.value == 0);

            uint256 _balanceBefore = _getTokenBalance(_src, address(this));

            if (_src != ETH_ADDRESS) {
                require(_src.transferFrom(_initiator, address(this), _maxSrcAmount));
                require(_src.approve(address(kyber), _maxSrcAmount));
            } else {
                _balanceBefore = _balanceBefore.sub(_maxSrcAmount);
            }

            _destAmount = kyber.trade{ value: _src == ETH_ADDRESS ? _maxSrcAmount : 0 } (
                _src,
                _maxSrcAmount,
                _dest,
                _receiver,
                _maxDestAmount,
                _minConversionRate,
                address(0)
            );

            uint256 _balanceAfter = _getTokenBalance(_src, address(this));
            _srcAmount = _maxSrcAmount;

            if (_balanceAfter > _balanceBefore) {
                uint256 _change = _balanceAfter - _balanceBefore;
                _srcAmount = _srcAmount.sub(_change);

                if (_src != ETH_ADDRESS) {
                    require(_src.transfer(_initiator, _change));
                } else {
                    _initiator.transfer(_change);
                }
            }
        }
    }
}


pragma solidity ^0.6.6;






abstract contract FixedSupplyLotSale is Pausable, KyberAdapter, PayoutWallet {
    using SafeMath for uint256;

    struct Lot {
        bool exists; // state flag to indicate that the Lot item exists.
        uint256[] nonFungibleSupply; // supply of non-fungible tokens for sale.
        uint256 fungibleAmount; // fungible token amount bundled with each NFT.
        uint256 price; // Lot item price, in payout currency tokens.
        uint256 numAvailable; // number of Lot items available for purchase.
    }

    struct PurchaseForVars {
        address payable recipient;
        uint256 lotId;
        uint256 quantity;
        IERC20 tokenAddress;
        uint256 maxTokenAmount;
        uint256 minConversionRate;
        string extData;
        address payable operator;
        Lot lot;
        uint256[] nonFungibleTokens;
        uint256 totalFungibleAmount;
        uint256 totalPrice;
        uint256 totalDiscounts;
        uint256 tokensSent;
        uint256 tokensReceived;
    }

    event Purchased (
        address indexed recipient, // destination account receiving the purchased Lot items.
        address operator, // account that executed the purchase operation.
        uint256 indexed lotId, // Lot id of the purchased items.
        uint256 indexed quantity, // quantity of Lot items purchased.
        uint256[] nonFungibleTokens, // list of Lot item non-fungible tokens in the purchase.
        uint256 totalFungibleAmount, // total amount of Lot item fungible tokens in the purchase.
        uint256 totalPrice, // total price (excluding any discounts) of the purchase, in payout currency tokens.
        uint256 totalDiscounts, // total discounts applied to the total price, in payout currency tokens.
        address tokenAddress, // purchase currency token contract address.
        uint256 tokensSent, // amount of actual purchase tokens spent (to convert to payout tokens) for the purchase.
        uint256 tokensReceived, // amount of actual payout tokens received (converted from purchase tokens) for the purchase.
        string extData // string encoded context-specific data blob.
    );

    event LotCreated (
        uint256 lotId, // id of the created Lot.
        uint256[] nonFungibleTokens, // initial Lot supply of non-fungible tokens.
        uint256 fungibleAmount, // initial fungible token amount bundled with each NFT.
        uint256 price // initial Lot item price.
    );

    event LotNonFungibleSupplyUpdated (
        uint256 lotId, // id of the Lot whose supply of non-fungible tokens was updated.
        uint256[] nonFungibleTokens // the non-fungible tokens that updated the supply.
    );

    event LotFungibleAmountUpdated (
        uint256 lotId, // id of the Lot whose fungible token amount was updated.
        uint256 fungibleAmount // updated fungible token amount.
    );

    event LotPriceUpdated (
        uint256 lotId, // id of the Lot whose item price was updated.
        uint256 price // updated item price.
    );

    IERC20 public _payoutTokenAddress; // payout currency token contract address.

    uint256 public _fungibleTokenId; // inventory token id of the fungible tokens bundled in a Lot item.

    address public _inventoryContract; // inventory contract address.

    mapping (uint256 => Lot) public _lots; // mapping of lotId => Lot.

    uint256 public _startedAt; // starting timestamp of the Lot sale.

    modifier whenStarted() {
        require(_startedAt != 0);
        _;
    }

    modifier whenNotStarted() {
        require(_startedAt == 0);
        _;
    }

    constructor(
        address kyberProxy,
        address payable payoutWallet,
        IERC20 payoutTokenAddress,
        uint256 fungibleTokenId,
        address inventoryContract
    )
        KyberAdapter(kyberProxy)
        PayoutWallet(payoutWallet)
        public
    {
        pause();

        setPayoutTokenAddress(payoutTokenAddress);
        setFungibleTokenId(fungibleTokenId);
        setInventoryContract(inventoryContract);
    }

    function setPayoutTokenAddress(
        IERC20 payoutTokenAddress
    )
        public
        onlyOwner
        whenPaused
    {
        require(payoutTokenAddress != IERC20(0));
        require(payoutTokenAddress != _payoutTokenAddress);

        _payoutTokenAddress = payoutTokenAddress;
    }

    function setFungibleTokenId(
        uint256 fungibleTokenId
    )
        public
        onlyOwner
        whenNotStarted
    {
        require(fungibleTokenId != 0);
        require(fungibleTokenId != _fungibleTokenId);

        _fungibleTokenId = fungibleTokenId;
    }

    function setInventoryContract(
        address inventoryContract
    )
        public
        onlyOwner
        whenNotStarted
    {
        require(inventoryContract != address(0));
        require(inventoryContract != _inventoryContract);

        _inventoryContract = inventoryContract;
    }

    function start()
        public
        onlyOwner
        whenNotStarted
    {
        _startedAt = now;

        unpause();
    }

    function pause()
        public
        onlyOwner
    {
        _pause();
    }

    function unpause()
        public onlyOwner
    {
        _unpause();
    }

    function createLot(
        uint256 lotId,
        uint256[] memory nonFungibleSupply,
        uint256 fungibleAmount,
        uint256 price
    )
        public
        onlyOwner
        whenNotStarted
    {
        require(!_lots[lotId].exists);

        Lot memory lot;
        lot.exists = true;
        lot.nonFungibleSupply = nonFungibleSupply;
        lot.fungibleAmount = fungibleAmount;
        lot.price = price;
        lot.numAvailable = nonFungibleSupply.length;

        _lots[lotId] = lot;

        emit LotCreated(lotId, nonFungibleSupply, fungibleAmount, price);
    }

    function updateLotNonFungibleSupply(
        uint256 lotId,
        uint256[] calldata nonFungibleTokens
    )
        external
        onlyOwner
        whenNotStarted
    {
        require(nonFungibleTokens.length != 0);

        Lot memory lot = _lots[lotId];

        require(lot.exists);

        uint256 newSupplySize = lot.nonFungibleSupply.length.add(nonFungibleTokens.length);
        uint256[] memory newNonFungibleSupply = new uint256[](newSupplySize);

        for (uint256 index = 0; index < lot.nonFungibleSupply.length; index++) {
            newNonFungibleSupply[index] = lot.nonFungibleSupply[index];
        }

        for (uint256 index = 0; index < nonFungibleTokens.length; index++) {
            uint256 offset = index.add(lot.nonFungibleSupply.length);
            newNonFungibleSupply[offset] = nonFungibleTokens[index];
        }

        lot.nonFungibleSupply = newNonFungibleSupply;
        lot.numAvailable = lot.numAvailable.add(nonFungibleTokens.length);

        _lots[lotId] = lot;

        emit LotNonFungibleSupplyUpdated(lotId, nonFungibleTokens);
    }

    function updateLotFungibleAmount(
        uint256 lotId,
        uint256 fungibleAmount
    )
        external
        onlyOwner
        whenPaused
    {
        require(_lots[lotId].exists);
        require(_lots[lotId].fungibleAmount != fungibleAmount);

        _lots[lotId].fungibleAmount = fungibleAmount;

        emit LotFungibleAmountUpdated(lotId, fungibleAmount);
    }

    function updateLotPrice(
        uint256 lotId,
        uint256 price
    )
        external
        onlyOwner
        whenPaused
    {
        require(_lots[lotId].exists);
        require(_lots[lotId].price != price);

        _lots[lotId].price = price;

        emit LotPriceUpdated(lotId, price);
    }

    function peekLotAvailableNonFungibleSupply(
        uint256 lotId,
        uint256 count
    )
        external
        view
        returns
    (
        uint256[] memory
    )
    {
        Lot memory lot = _lots[lotId];

        require(lot.exists);

        if (count > lot.numAvailable) {
            count = lot.numAvailable;
        }

        uint256[] memory nonFungibleTokens = new uint256[](count);

        uint256 nonFungibleSupplyOffset = lot.nonFungibleSupply.length.sub(lot.numAvailable);

        for (uint256 index = 0; index < count; index++) {
            uint256 position = nonFungibleSupplyOffset.add(index);
            nonFungibleTokens[index] = lot.nonFungibleSupply[position];
        }

        return nonFungibleTokens;
    }

    function purchaseFor(
        address payable recipient,
        uint256 lotId,
        uint256 quantity,
        IERC20 tokenAddress,
        uint256 maxTokenAmount,
        uint256 minConversionRate,
        string calldata extData
    )
        external
        payable
        whenNotPaused
        whenStarted
    {
        require(recipient != address(0));
        require(recipient != address(uint160(address(this))));
        require (quantity > 0);
        require(tokenAddress != IERC20(0));

        PurchaseForVars memory purchaseForVars;
        purchaseForVars.recipient = recipient;
        purchaseForVars.lotId = lotId;
        purchaseForVars.quantity = quantity;
        purchaseForVars.tokenAddress = tokenAddress;
        purchaseForVars.maxTokenAmount = maxTokenAmount;
        purchaseForVars.minConversionRate = minConversionRate;
        purchaseForVars.extData = extData;
        purchaseForVars.operator = msg.sender;
        purchaseForVars.lot = _lots[lotId];

        require(purchaseForVars.lot.exists);
        require(quantity <= purchaseForVars.lot.numAvailable);

        purchaseForVars.nonFungibleTokens = new uint256[](quantity);

        uint256 nonFungibleSupplyOffset = purchaseForVars.lot.nonFungibleSupply.length.sub(purchaseForVars.lot.numAvailable);

        for (uint256 index = 0; index < quantity; index++) {
            uint256 position = nonFungibleSupplyOffset.add(index);
            purchaseForVars.nonFungibleTokens[index] = purchaseForVars.lot.nonFungibleSupply[position];
        }

        purchaseForVars.totalFungibleAmount = purchaseForVars.lot.fungibleAmount.mul(quantity);

        _purchaseFor(purchaseForVars);

        _lots[lotId].numAvailable = purchaseForVars.lot.numAvailable.sub(quantity);
    }

    function getPrice(
        address payable recipient,
        uint256 lotId,
        uint256 quantity,
        IERC20 tokenAddress
    )
        external
        view
        returns
    (
        uint256 minConversionRate,
        uint256 totalPrice,
        uint256 totalDiscounts
    )
    {
        Lot memory lot = _lots[lotId];

        require(lot.exists);
        require(tokenAddress != IERC20(0));

        (totalPrice, totalDiscounts) = _getPrice(recipient, lot, quantity);

        if (tokenAddress == _payoutTokenAddress) {
            minConversionRate = 1000000000000000000;
        } else {
            (, uint tokenAmount) = _convertToken(_payoutTokenAddress, totalPrice, tokenAddress);
            (, minConversionRate) = kyber.getExpectedRate(tokenAddress, _payoutTokenAddress, tokenAmount);

            if (totalPrice > 0) {
                totalPrice = ceilingDiv(totalPrice.mul(10**36), minConversionRate);
                totalPrice = _fixTokenDecimals(_payoutTokenAddress, tokenAddress, totalPrice, true);
            }

            if (totalDiscounts > 0) {
                totalDiscounts = ceilingDiv(totalDiscounts.mul(10**36), minConversionRate);
                totalDiscounts = _fixTokenDecimals(_payoutTokenAddress, tokenAddress, totalDiscounts, true);
            }
        }
    }

    function _purchaseFor(
        PurchaseForVars memory purchaseForVars
    )
        internal
        virtual
    {
        (purchaseForVars.totalPrice, purchaseForVars.totalDiscounts) =
            _purchaseForPricing(purchaseForVars);

        (purchaseForVars.tokensSent, purchaseForVars.tokensReceived) =
            _purchaseForPayment(purchaseForVars);

        _purchaseForDelivery(purchaseForVars);
        _purchaseForNotify(purchaseForVars);
    }

    function _purchaseForPricing(
        PurchaseForVars memory purchaseForVars
    )
        internal
        virtual
        returns
    (
        uint256 totalPrice,
        uint256 totalDiscounts
    )
    {
        (totalPrice, totalDiscounts) =
            _getPrice(
                purchaseForVars.recipient,
                purchaseForVars.lot,
                purchaseForVars.quantity);

        require(totalDiscounts <= totalPrice);
    }

    function _purchaseForPayment(
        PurchaseForVars memory purchaseForVars
    )
        internal
        virtual
        returns
    (
        uint256 purchaseTokensSent,
        uint256 payoutTokensReceived
    )
    {
        uint256 totalDiscountedPrice = purchaseForVars.totalPrice.sub(purchaseForVars.totalDiscounts);

        (purchaseTokensSent, payoutTokensReceived) =
            _swapTokenAndHandleChange(
                purchaseForVars.tokenAddress,
                purchaseForVars.maxTokenAmount,
                _payoutTokenAddress,
                totalDiscountedPrice,
                purchaseForVars.minConversionRate,
                purchaseForVars.operator,
                address(uint160(address(this))));

        require(payoutTokensReceived >= totalDiscountedPrice);
        require(_payoutTokenAddress.transfer(_payoutWallet, payoutTokensReceived));
    }

    function _purchaseForDelivery(PurchaseForVars memory purchaseForVars) internal virtual;

    function _purchaseForNotify(
        PurchaseForVars memory purchaseForVars
    )
        internal
        virtual
    {
        emit Purchased(
            purchaseForVars.recipient,
            purchaseForVars.operator,
            purchaseForVars.lotId,
            purchaseForVars.quantity,
            purchaseForVars.nonFungibleTokens,
            purchaseForVars.totalFungibleAmount,
            purchaseForVars.totalPrice,
            purchaseForVars.totalDiscounts,
            address(purchaseForVars.tokenAddress),
            purchaseForVars.tokensSent,
            purchaseForVars.tokensReceived,
            purchaseForVars.extData);
    }

    function _getPrice(
        address payable /* recipient */,
        Lot memory lot,
        uint256 quantity
    )
        internal
        virtual
        pure
        returns
    (
        uint256 totalPrice,
        uint256 totalDiscounts
    )
    {
        totalPrice = lot.price.mul(quantity);
        totalDiscounts = 0;
    }
}


pragma solidity ^0.6.6;



contract CDHSale is FixedSupplyLotSale {


    struct DeliverPurchaseVars {
        uint256 numNonFungibleTokens;
        uint256 numTokens;
        address[] to;
        uint256[] ids;
        uint256[] values;
    }

    constructor(
        address kyberProxy,
        address payable payoutWallet,
        IERC20 payoutTokenAddress,
        uint256 fungibleTokenId,
        address inventoryContract
    )
        FixedSupplyLotSale(
            kyberProxy,
            payoutWallet,
            payoutTokenAddress,
            fungibleTokenId,
            inventoryContract
        )
        public
    {}

    function _purchaseForDelivery(
        PurchaseForVars memory purchaseForVars
    )
        internal
        override
    {

        require(purchaseForVars.recipient != address(0));
        require(purchaseForVars.recipient != address(uint160(address(this))));

        DeliverPurchaseVars memory vars;
        vars.numNonFungibleTokens = purchaseForVars.nonFungibleTokens.length;
        vars.numTokens = vars.numNonFungibleTokens + 1;
        vars.to = new address[](vars.numTokens);
        vars.ids = new uint256[](vars.numTokens);
        vars.values = new uint256[](vars.numTokens);

        for (uint256 index = 0; index < vars.numNonFungibleTokens; index++) {
            vars.to[index] = purchaseForVars.recipient;
            vars.ids[index] = purchaseForVars.nonFungibleTokens[index];
            vars.values[index] = 1;
        }

        vars.to[vars.numNonFungibleTokens] = purchaseForVars.recipient;
        vars.ids[vars.numNonFungibleTokens] = _fungibleTokenId;
        vars.values[vars.numNonFungibleTokens] = purchaseForVars.totalFungibleAmount;

        NonBurnableInventoryMock(_inventoryContract).batchMint(vars.to, vars.ids, vars.values);
    }

}