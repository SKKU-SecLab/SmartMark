
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
}// MIT

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

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
}// MIT

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
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

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}// MIT

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}// MIT

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}pragma solidity ^0.7.0;

library Strings {

  function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory) {

      bytes memory _ba = bytes(_a);
      bytes memory _bb = bytes(_b);
      bytes memory _bc = bytes(_c);
      bytes memory _bd = bytes(_d);
      bytes memory _be = bytes(_e);
      string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
      bytes memory babcde = bytes(abcde);
      uint k = 0;
      for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
      for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
      for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
      for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
      for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
      return string(babcde);
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {

        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using SafeMath for uint256;
    using Address for address;

    mapping (uint256 => mapping(address => uint256)) private _balances;

    mapping (address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    constructor (string memory uri_) public {
        _setURI(uri_);

        _registerInterface(_INTERFACE_ID_ERC1155);

        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    function uri(uint256 _id) external view virtual override returns (string memory) {

      return Strings.strConcat(_uri, Strings.uint2str(_id));
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {

        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {

        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] = _balances[id][account].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(address account, uint256 id, uint256 amount) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        virtual
    { }


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        private
    {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC1155Pausable is ERC1155, Pausable {
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        virtual
        override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(!paused(), "ERC1155Pausable: token transfer while paused");
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}//Unlicense
pragma solidity ^0.7.0;


contract AniftyERC20 is ERC20, Ownable {
  using SafeMath for uint256;
  mapping(address => bool) public whitelist;

  constructor(uint256 initialSupply) public ERC20("Anifty", "ANI") { 
    _mint(msg.sender, initialSupply*10**decimals());
  }

  function burn(uint256 _amount) public {
    _burn(msg.sender, _amount);
  }

  function burn(address _account, uint256 _amount) public onlyWhitelist {
    _burn(_account, _amount);
  }

  function removeWhitelistAddress(address[] memory _whitelistAddresses) public onlyOwner {
    for (uint256 i = 0; i < _whitelistAddresses.length; i++) {
    whitelist[_whitelistAddresses[i]] = false;
    }
  }

  function addWhitelistAddress(address[] memory _whitelistAddresses) public onlyOwner {
    for (uint256 i = 0; i < _whitelistAddresses.length; i++) {
    whitelist[_whitelistAddresses[i]] = true;
    }
  }

  modifier onlyWhitelist() {
    require(whitelist[msg.sender] == true, "Caller is not from a whitelist address");
    _;
  }
}//Unlicense
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;


contract AniftyERC1155 is AccessControl, ERC1155Pausable {
    using Counters for Counters.Counter;
    Counters.Counter private _adminTokenIds;
    Counters.Counter private _tokenIds;

    mapping(address => bool) public whitelist;
    mapping (uint256 => address) public creators;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    event TokenERC1155Mint(
        address account,
        uint256 id,
        uint256 amount,
        uint256 timestamp,
        string name,
        string creatorName,
        string description,
        string mediaUri
    );
    event TokenERC1155MintBatch(
        address to,
        uint256[] ids,
        uint256[] amounts,
        uint256 timestamp,
        string[] name,
        string[] creatorName,
        string[] description,
        string[] mediaUri
    );

    constructor(address _admin,
        string memory _uri)
        public
        ERC1155(_uri)
    {
        _tokenIds._value = 1000000;
        _setRoleAdmin(DEFAULT_ADMIN_ROLE, ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, _admin);
        _setupRole(PAUSER_ROLE, _admin);
    }

    modifier onlyWhitelist() {
        require(
            whitelist[msg.sender] == true,
            "Caller is not from a whitelist address"
        );
        _;
    }

    modifier onlyAdmin() {
        require(
            hasRole(ADMIN_ROLE, _msgSender()),
            "Caller must be admin"
        );
        _;
    }

    function pause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "AniftyERC1155: must have pauser role to pause"
        );
        _pause();
    }

    function unpause() public {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "AniftyERC1155: must have pauser role to unpause"
        );
        _unpause();
    }

    function mint(
        uint256 amount,
        string memory name,
        string memory creatorName,
        string memory description,
        string memory mediaUri,
        bytes calldata data
    ) external whenNotPaused returns(uint256) {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        creators[tokenId] = msg.sender;
        _mint(msg.sender, tokenId, amount, data);
        emit TokenERC1155Mint(
            msg.sender,
            tokenId,
            amount,
            block.timestamp,
            name,
            creatorName,
            description,
            mediaUri
        );
        return tokenId;
    }

    function mintBatch(
        uint256[] memory amounts,
        string[] memory names,
        string[] memory creatorNames,
        string[] memory descriptions,
        string[] memory mediaUris,
        bytes calldata data
    ) external whenNotPaused returns(uint256[] memory) {
        require(amounts.length == names.length && amounts.length == creatorNames.length && amounts.length == descriptions.length && amounts.length == mediaUris.length, "AniftyERC1155: Incorrect parameter length");
        uint256[] memory tokenIds = new uint256[](amounts.length);
        for (uint256 j = 0; j < amounts.length; j++) {
            _tokenIds.increment();
            tokenIds[j] = _tokenIds.current();
            creators[tokenIds[j]] = msg.sender;
        }
        _mintBatch(msg.sender, tokenIds, amounts, data);
        emit TokenERC1155MintBatch(
            msg.sender,
            tokenIds,
            amounts,
            block.timestamp,
            names,
            creatorNames,
            descriptions,
            mediaUris
        );
        return tokenIds;
    }

    function whitelistMint(
        uint256 amount,
        string memory name,
        string memory creatorName,
        string memory description,
        string memory mediaUri,
        bytes calldata data
    ) external whenNotPaused onlyWhitelist returns(uint256) {
        _adminTokenIds.increment();
        uint256 tokenId = _adminTokenIds.current();
        creators[tokenId] = msg.sender;
        _mint(msg.sender, tokenId, amount, data);
        emit TokenERC1155Mint(
            msg.sender,
            tokenId,
            amount,
            block.timestamp,
            name,
            creatorName,
            description,
            mediaUri
        );
        return tokenId;
    }

    function whitelistMintBatch(
        uint256[] memory amounts,
        string[] memory names,
        string[] memory creatorNames,
        string[] memory descriptions,
        string[] memory mediaUris,
        bytes calldata data
    ) external whenNotPaused onlyWhitelist returns(uint256[] memory) {
        require(amounts.length == names.length && amounts.length == creatorNames.length && amounts.length == descriptions.length && amounts.length == mediaUris.length, "AniftyERC1155: Incorrect parameter length");
        uint256[] memory tokenIds = new uint256[](amounts.length);
        for (uint256 j = 0; j < amounts.length; j++) {
            _adminTokenIds.increment();
            tokenIds[j] = _adminTokenIds.current();
            creators[tokenIds[j]] = msg.sender;
        }
        _mintBatch(msg.sender, tokenIds, amounts, data);
        emit TokenERC1155MintBatch(
            msg.sender,
            tokenIds,
            amounts,
            block.timestamp,
            names,
            creatorNames,
            descriptions,
            mediaUris
        );
        return tokenIds;
    }

    function burn(uint256 _id, uint256 _amount) external whenNotPaused {
        _burn(msg.sender, _id, _amount);
    }

    function burnBatch(uint256[] memory _ids, uint256[] memory _amounts) external whenNotPaused {
        _burnBatch(msg.sender, _ids, _amounts);
    }

    function setURI(string memory newuri) external onlyAdmin {
        _setURI(newuri);
    }

    function removeWhitelistAddress(address[] memory _whitelistAddresses)
        external
        onlyAdmin
    {
        for (uint256 i = 0; i < _whitelistAddresses.length; i++) {
            whitelist[_whitelistAddresses[i]] = false;
        }
    }

    function addWhitelistAddress(address[] memory _whitelistAddresses)
        external
        onlyAdmin
    {
        for (uint256 i = 0; i < _whitelistAddresses.length; i++) {
            whitelist[_whitelistAddresses[i]] = true;
        }
    }
}//Unlicense
pragma solidity ^0.7.0;


contract AniftyCollection is Ownable, Pausable, ERC1155Holder {
  using SafeMath for uint256;

  struct CollectionInfo {
    uint256 tokenId;
    uint256 totalTokenAmount;
    uint256 availableTokenAmount;
    uint256 price;
    address ERC20Token;
  }

  uint256 public roundId;
  address[] public paymentERC20Tokens;
  mapping(address => bool) public existingERC20Token;
  mapping(uint256 => uint256) public roundEndTimestamp;
  mapping(uint256 => CollectionInfo[]) public roundCollection;
  AniftyERC1155 public aniftyERC1155;

  constructor(address _aniftyERC1155) public {
      aniftyERC1155 = AniftyERC1155(_aniftyERC1155);
  }


  function totalPaymentERC20Tokens() external view returns (uint256) {
    return paymentERC20Tokens.length;
  }

  function totalCollection(uint256 _roundId) external view returns (uint256) {
    return roundCollection[_roundId].length;
  }

  function getCollectionInfo(uint256 _roundId, uint256[] memory _indexes) external view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, address[] memory) {
    uint256[] memory tokenId = new uint256[](_indexes.length);
    uint256[] memory totalTokenAmount = new uint256[](_indexes.length);
    uint256[] memory availableTokenAmount = new uint256[](_indexes.length);
    uint256[] memory price = new uint256[](_indexes.length);
    address[] memory ERC20Token = new address[](_indexes.length);

    for (uint256 i = 0; i < _indexes.length; i++) {
      CollectionInfo storage collectables = roundCollection[_roundId][_indexes[i]];
      tokenId[i] = collectables.tokenId;
      totalTokenAmount[i] = collectables.totalTokenAmount;
      availableTokenAmount[i] = collectables.availableTokenAmount;
      price[i] = collectables.price;
      ERC20Token[i] = collectables.ERC20Token;
    }

    return (tokenId, totalTokenAmount, availableTokenAmount, price, ERC20Token);
  }


  function buyCollectable(uint256 _collectableIndex, uint256 _amount) payable external whenNotPaused {
    CollectionInfo storage collectable = roundCollection[roundId][_collectableIndex];
    require(collectable.availableTokenAmount >= _amount, 'AniftyCollection: Not enough tokens available');
    require(_amount > 0, 'AniftyCollection: Purchase amount must be greater than 0');
    require(block.timestamp < roundEndTimestamp[roundId], 'AniftyCollection: Cannot buy after roundEndTimestamp');
    if (collectable.ERC20Token == address(0)) {
      require(msg.value >= collectable.price, 'AniftyCollection: Insufficient fund to buy collectable');
    } else {
      IERC20(collectable.ERC20Token).transferFrom(msg.sender, address(this), collectable.price);
    }
    collectable.availableTokenAmount = collectable.availableTokenAmount.sub(_amount);
    aniftyERC1155.safeTransferFrom(address(this), msg.sender, collectable.tokenId, _amount, "");
  }


  function addToCollection(
    uint256[] memory _tokenIds,
    uint256[] memory _amounts,
    address[] memory _ERC20Tokens,
    uint256[] memory _prices,
    uint256 _roundEndTimestamp) external onlyOwner {
      require(_amounts.length == _ERC20Tokens.length && _amounts.length == _prices.length, "AniftyCollection: Incorrect parameter length");
      aniftyERC1155.safeBatchTransferFrom(msg.sender, address(this), _tokenIds, _amounts, "");
      roundId = roundId.add(1);
      roundEndTimestamp[roundId] = _roundEndTimestamp;
      for (uint256 i = 0; i < _tokenIds.length; i++) {
        uint256 tokenId = _tokenIds[i];
        address ERC20Token = _ERC20Tokens[i];
        uint256 price = _prices[i];
        uint256 amount = _amounts[i];
        roundCollection[roundId].push(CollectionInfo(tokenId, amount, amount, price, ERC20Token));
        if (!existingERC20Token[ERC20Token] && ERC20Token != address(0)) {
          paymentERC20Tokens.push(ERC20Token);
        }
      }
  }

  function addToRound(
    uint256 addRoundId,
    uint256[] memory _tokenIds,
    uint256[] memory _amounts,
    address[] memory _ERC20Tokens,
    uint256[] memory _prices) external onlyOwner {
      require(_amounts.length == _ERC20Tokens.length && _amounts.length == _prices.length, "AniftyCollection: Incorrect parameter length");
      aniftyERC1155.safeBatchTransferFrom(msg.sender, address(this), _tokenIds, _amounts, "");
      for (uint256 i = 0; i < _tokenIds.length; i++) {
        uint256 tokenId = _tokenIds[i];
        address ERC20Token = _ERC20Tokens[i];
        uint256 price = _prices[i];
        roundCollection[addRoundId].push(CollectionInfo(tokenId, _tokenIds.length, _tokenIds.length, price, ERC20Token));
        if (!existingERC20Token[ERC20Token] && ERC20Token != address(0)) {
          paymentERC20Tokens.push(ERC20Token);
        }
      }
    }

  function withdrawETH() public onlyOwner {
    msg.sender.transfer(address(this).balance);
  }

  function withdrawERC20(address _ERC20Token) public onlyOwner {
    IERC20 withdrawToken = IERC20(_ERC20Token);
    withdrawToken.transfer(msg.sender, withdrawToken.balanceOf(address(this)));
  }

  function withdrawAllERC20() public onlyOwner {
    for (uint256 i = 0; i < paymentERC20Tokens.length; i++) {
      withdrawERC20(paymentERC20Tokens[i]);
    }
  }

  function withdrawAllTokens() external onlyOwner {
    withdrawETH();
    withdrawAllERC20();
  }

  function withdrawERC1155(uint256 _roundId, uint256 _collectableIndex, uint256 _amount) public onlyOwner {
    CollectionInfo storage collectable = roundCollection[_roundId][_collectableIndex];
    require(collectable.availableTokenAmount >= _amount, 'AniftyCollection: Not enough tokens available');
    require(block.timestamp >= roundEndTimestamp[_roundId], 'AniftyCollection: Can only withdraw after roundEndTimestamp');
    collectable.availableTokenAmount = collectable.availableTokenAmount.sub(_amount);
    aniftyERC1155.safeTransferFrom(address(this), msg.sender, collectable.tokenId, _amount, "");
  }

  function withdrawAllERC1155(uint256 _roundId) external onlyOwner {
    for (uint256 i = 0; i < roundCollection[_roundId].length; i++) {
      CollectionInfo memory collectable = roundCollection[_roundId][i];
      uint256 ERC1155Balance = aniftyERC1155.balanceOf(address(this), collectable.tokenId);
      if (ERC1155Balance > 0) {
        withdrawERC1155(_roundId, i, ERC1155Balance);
      }
    }
  }

  function sweepERC1155(uint256 _tokenId, uint256 _amount) external onlyOwner {
    aniftyERC1155.safeTransferFrom(address(this), msg.sender, _tokenId, _amount, "");
  }

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }
}