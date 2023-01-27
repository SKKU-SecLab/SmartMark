
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

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
}// MIT

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
}// MIT

pragma solidity ^0.6.2;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
}// WTFPL
pragma solidity ^0.6.0;

contract OwnableDelegateProxy {}


contract IProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}// MIT

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
}// MIT
pragma solidity =0.6.12;

interface IERC1155TokenReceiver {

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        bytes calldata _data
    ) external returns (bytes4);

}// MIT
pragma solidity =0.6.12;

interface IERC1155 {


    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _amount
    );

    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _amounts
    );

    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    event URI(string _amount, uint256 indexed _id);


    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    ) external;


    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        bytes calldata _data
    ) external;


    function balanceOf(address _owner, uint256 _id)
        external
        view
        returns (uint256);


    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address _operator, bool _approved) external;


    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool isOperator);

}// MIT
pragma solidity =0.6.12;

abstract contract ERC165 {
    function supportsInterface(bytes4 _interfaceID)
        public
        pure
        virtual
        returns (bool)
    {
        return _interfaceID == this.supportsInterface.selector;
    }
}// MIT
pragma solidity =0.6.12;


contract ERC1155 is IERC1155, ERC165 {

    using Address for address;
    using SafeMath for uint256;

    bytes4 internal constant ERC1155_RECEIVED_VALUE = 0xf23a6e61;
    bytes4 internal constant ERC1155_BATCH_RECEIVED_VALUE = 0xbc197c81;

    mapping(address => mapping(uint256 => uint256)) internal balances;

    mapping(address => mapping(address => bool)) internal operators;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) public override {

        require(
            (msg.sender == _from) || isApprovedForAll(_from, msg.sender),
            "ERC1155#safeTransferFrom: INVALID_OPERATOR"
        );
        require(
            _to != address(0),
            "ERC1155#safeTransferFrom: INVALID_RECIPIENT"
        );

        _safeTransferFrom(_from, _to, _id, _amount);
        _callonERC1155Received(_from, _to, _id, _amount, gasleft(), _data);
    }

    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) public override {

        require(
            (msg.sender == _from) || isApprovedForAll(_from, msg.sender),
            "ERC1155#safeBatchTransferFrom: INVALID_OPERATOR"
        );
        require(
            _to != address(0),
            "ERC1155#safeBatchTransferFrom: INVALID_RECIPIENT"
        );

        _safeBatchTransferFrom(_from, _to, _ids, _amounts);
        _callonERC1155BatchReceived(
            _from,
            _to,
            _ids,
            _amounts,
            gasleft(),
            _data
        );
    }


    function _safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    ) internal {

        balances[_from][_id] = balances[_from][_id].sub(_amount); // Subtract amount
        balances[_to][_id] = balances[_to][_id].add(_amount); // Add amount

        emit TransferSingle(msg.sender, _from, _to, _id, _amount);
    }

    function _callonERC1155Received(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        uint256 _gasLimit,
        bytes memory _data
    ) internal {

        if (_to.isContract()) {
            bytes4 retval =
                IERC1155TokenReceiver(_to).onERC1155Received{gas: _gasLimit}(
                    msg.sender,
                    _from,
                    _id,
                    _amount,
                    _data
                );
            require(
                retval == ERC1155_RECEIVED_VALUE,
                "ERC1155#_callonERC1155Received: INVALID_ON_RECEIVE_MESSAGE"
            );
        }
    }

    function _safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) internal {

        require(
            _ids.length == _amounts.length,
            "ERC1155#_safeBatchTransferFrom: INVALID_ARRAYS_LENGTH"
        );

        uint256 nTransfer = _ids.length;

        for (uint256 i = 0; i < nTransfer; i++) {
            balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(
                _amounts[i]
            );
            balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
        }

        emit TransferBatch(msg.sender, _from, _to, _ids, _amounts);
    }

    function _callonERC1155BatchReceived(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        uint256 _gasLimit,
        bytes memory _data
    ) internal {

        if (_to.isContract()) {
            bytes4 retval =
                IERC1155TokenReceiver(_to).onERC1155BatchReceived{
                    gas: _gasLimit
                }(msg.sender, _from, _ids, _amounts, _data);
            require(
                retval == ERC1155_BATCH_RECEIVED_VALUE,
                "ERC1155#_callonERC1155BatchReceived: INVALID_ON_RECEIVE_MESSAGE"
            );
        }
    }


    function setApprovalForAll(address _operator, bool _approved)
        external
        override
    {

        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        virtual
        override
        returns (bool isOperator)
    {

        return operators[_owner][_operator];
    }


    function balanceOf(address _owner, uint256 _id)
        public
        view
        override
        returns (uint256)
    {

        return balances[_owner][_id];
    }

    function balanceOfBatch(address[] memory _owners, uint256[] memory _ids)
        public
        view
        override
        returns (uint256[] memory)
    {

        require(
            _owners.length == _ids.length,
            "ERC1155#balanceOfBatch: INVALID_ARRAY_LENGTH"
        );

        uint256[] memory batchBalances = new uint256[](_owners.length);

        for (uint256 i = 0; i < _owners.length; i++) {
            batchBalances[i] = balances[_owners[i]][_ids[i]];
        }

        return batchBalances;
    }


    function supportsInterface(bytes4 _interfaceID)
        public
        pure
        virtual
        override
        returns (bool)
    {

        if (_interfaceID == type(IERC1155).interfaceId) {
            return true;
        }
        return super.supportsInterface(_interfaceID);
    }
}// MIT
pragma solidity =0.6.12;

contract ERC1155MintBurn is ERC1155 {


    function _mint(
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) internal {

        balances[_to][_id] = balances[_to][_id].add(_amount);

        emit TransferSingle(msg.sender, address(0x0), _to, _id, _amount);

        _callonERC1155Received(
            address(0x0),
            _to,
            _id,
            _amount,
            gasleft(),
            _data
        );
    }

    function _batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) internal {

        require(
            _ids.length == _amounts.length,
            "ERC1155MintBurn#batchMint: INVALID_ARRAYS_LENGTH"
        );

        uint256 nMint = _ids.length;

        for (uint256 i = 0; i < nMint; i++) {
            balances[_to][_ids[i]] = balances[_to][_ids[i]].add(_amounts[i]);
        }

        emit TransferBatch(msg.sender, address(0x0), _to, _ids, _amounts);

        _callonERC1155BatchReceived(
            address(0x0),
            _to,
            _ids,
            _amounts,
            gasleft(),
            _data
        );
    }


    function _burn(
        address _from,
        uint256 _id,
        uint256 _amount
    ) internal {

        balances[_from][_id] = balances[_from][_id].sub(_amount);

        emit TransferSingle(msg.sender, _from, address(0x0), _id, _amount);
    }

    function _batchBurn(
        address _from,
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) internal {

        uint256 nBurn = _ids.length;
        require(
            nBurn == _amounts.length,
            "ERC1155MintBurn#batchBurn: INVALID_ARRAYS_LENGTH"
        );

        for (uint256 i = 0; i < nBurn; i++) {
            balances[_from][_ids[i]] = balances[_from][_ids[i]].sub(
                _amounts[i]
            );
        }

        emit TransferBatch(msg.sender, _from, address(0x0), _ids, _amounts);
    }
}// MIT
pragma solidity =0.6.12;

interface IERC1155Metadata {


    function uri(uint256 _id) external view returns (string memory);

}// MIT
pragma solidity =0.6.12;


contract ERC1155Metadata is ERC165 {

    string public baseMetadataURI;
    event URI(string _uri, uint256 indexed _id);


    function _uri(uint256 _id) internal view returns (string memory) {

        return
            string(abi.encodePacked(baseMetadataURI, _uint2str(_id), ".json"));
    }


    function _logURIs(uint256[] memory _tokenIDs) internal {

        string memory baseURL = baseMetadataURI;
        string memory tokenURI;

        for (uint256 i = 0; i < _tokenIDs.length; i++) {
            tokenURI = string(
                abi.encodePacked(baseURL, _uint2str(_tokenIDs[i]), ".json")
            );
            emit URI(tokenURI, _tokenIDs[i]);
        }
    }

    function _setBaseMetadataURI(string memory _newBaseMetadataURI) internal {

        baseMetadataURI = _newBaseMetadataURI;
    }

    function supportsInterface(bytes4 _interfaceID)
        public
        pure
        virtual
        override
        returns (bool)
    {

        if (_interfaceID == type(IERC1155Metadata).interfaceId) {
            return true;
        }
        return super.supportsInterface(_interfaceID);
    }


    function _uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {

        if (_i == 0) {
            return "0";
        }

        uint256 j = _i;
        uint256 ii = _i;
        uint256 len;

        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;

        while (ii != 0) {
            bstr[k--] = bytes1(uint8(48 + (ii % 10)));
            ii /= 10;
        }

        return string(bstr);
    }
}// MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;




contract ERC1155Tradable is
    ERC1155,
    ERC1155MintBurn,
    ERC1155Metadata,
    AccessControl
{

    string public name;
    string public symbol;

    bytes32 public constant CONTROLLER_ROLE = keccak256("CONTROLLER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 internal _currentTokenID = 0;

    mapping(uint256 => address) public creators;
    mapping(uint256 => uint256) public tokenSupply;
    mapping(uint256 => uint256) public tokenMaxSupply;

    bool public ipfsURIs = false;
    mapping(uint256 => string) public ipfs;

    address proxyRegistryAddress;

    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress
    ) public {
        name = _name;
        symbol = _symbol;
        proxyRegistryAddress = _proxyRegistryAddress;

        _setRoleAdmin(CONTROLLER_ROLE, CONTROLLER_ROLE);
        _setRoleAdmin(MINTER_ROLE, CONTROLLER_ROLE);

        _setupRole(CONTROLLER_ROLE, msg.sender);
    }

    event ItemCreated(
        uint256 id,
        uint256 tokenInitialSupply,
        uint256 tokenMaxSupply,
        string ipfs
    );

    event ItemUpdated(uint256 id, string ipfs);


    function totalSupply(uint256 _id) public view returns (uint256) {

        return tokenSupply[_id];
    }

    function maxSupply(uint256 _id) public view returns (uint256) {

        return tokenMaxSupply[_id];
    }

    function create(
        uint256 _initialSupply,
        uint256 _maxSupply,
        string calldata _uri,
        bytes calldata _data,
        string calldata _ipfs
    ) public returns (uint256 _id) {

        require(hasRole(MINTER_ROLE, msg.sender), "Unauthorized");

        require(0 < _maxSupply, "Insufficient Max Supply");
        require(_initialSupply <= _maxSupply, "Invalid Initial Supply");

        _id = _getNextTokenID();
        _incrementTokenTypeId();

        if (bytes(_uri).length > 0) {
            emit URI(_uri, _id);
        }

        if (_initialSupply != 0) {
            super._mint(msg.sender, _id, _initialSupply, _data);
        }

        creators[_id] = msg.sender;
        tokenMaxSupply[_id] = _maxSupply;
        tokenSupply[_id] = _initialSupply;

        ipfs[_id] = _ipfs;

        emit ItemCreated(_id, _initialSupply, _maxSupply, _ipfs);
        return _id;
    }

    function createBatch(
        uint256[] calldata _initialSupply,
        uint256[] calldata _maxSupply,
        string[] calldata _uri,
        bytes[] calldata _data,
        string[] calldata _ipfs
    ) external returns (bool) {

        require(hasRole(MINTER_ROLE, msg.sender), "Unauthorized");

        for (uint256 index = 0; index < _initialSupply.length; index++) {
            create(
                _initialSupply[index],
                _maxSupply[index],
                _uri[index],
                _data[index],
                _ipfs[index]
            );
        }

        return true;
    }

    function mint(
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) public returns (bool) {

        require(hasRole(MINTER_ROLE, msg.sender), "Unauthorized");

        require(
            tokenSupply[_id].add(_amount) <= tokenMaxSupply[_id],
            "Max Supply Reached"
        );

        tokenSupply[_id] = tokenSupply[_id].add(_amount);

        super._mint(_to, _id, _amount, _data);

        return true;
    }


    function uri(uint256 _id) public view returns (string memory) {

        require(_exists(_id), "ERC1155Tradable#uri: NONEXISTENT_TOKEN");
        return
            ipfsURIs
                ? string(abi.encodePacked("ipfs://", ipfs[_id]))
                : super._uri(_id);
    }

    function toggleIPFS() external returns (bool) {

        require(hasRole(CONTROLLER_ROLE, msg.sender));
        ipfsURIs = ipfsURIs ? false : true;
        return ipfsURIs;
    }

    function updateItemsURI(
        uint256[] calldata _ids,
        string memory _newBaseMetadataURI
    ) external returns (bool) {

        require(hasRole(CONTROLLER_ROLE, msg.sender));
        if (bytes(_newBaseMetadataURI).length > 0) {
            super._setBaseMetadataURI(_newBaseMetadataURI);
        }
        super._logURIs(_ids);
    }

    function setBaseMetadataURI(string memory _newBaseMetadataURI) external {

        require(hasRole(CONTROLLER_ROLE, msg.sender));
        super._setBaseMetadataURI(_newBaseMetadataURI);
    }


    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool isOperator)
    {

        IProxyRegistry proxyRegistry = IProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == _operator) {
            return true;
        }

        return ERC1155.isApprovedForAll(_owner, _operator);
    }


    function _exists(uint256 _id) internal view returns (bool) {

        return creators[_id] != address(0);
    }

    function _getNextTokenID() internal view returns (uint256) {

        return _currentTokenID.add(1);
    }

    function _incrementTokenTypeId() internal {

        _currentTokenID++;
    }

    bytes4 private constant INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;
    bytes4 private constant INTERFACE_SIGNATURE_ERC1155 = 0xd9b67a26;

    function supportsInterface(bytes4 _interfaceID)
        public
        pure
        override(ERC1155, ERC1155Metadata)
        returns (bool)
    {

        if (
            _interfaceID == INTERFACE_SIGNATURE_ERC165 ||
            _interfaceID == INTERFACE_SIGNATURE_ERC1155
        ) {
            return true;
        }
        return false;
    }
}// MIT
pragma solidity =0.6.12;


contract LootItems is ERC1155Tradable {

    constructor(string memory baseURI, address proxyRegistryAddress)
        public
        ERC1155Tradable("Loot", "ITEMS", proxyRegistryAddress)
    {
        super._setBaseMetadataURI(baseURI);
    }
}