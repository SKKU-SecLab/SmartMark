
pragma solidity 0.6.12;

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
}

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

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

contract SafeTransfer is AccessControl {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bytes32 public constant ACTIVATOR_ROLE = 0xec5aad7bdface20c35bc02d6d2d5760df981277427368525d634f4e2603ea192;

    bytes32 public constant HIDDEN_COLLECT_TYPEHASH = 0x0506afef36f3613836f98ef019cb76a3e6112be8f9dc8d8fa77275d64f418234;

    bytes32 public constant HIDDEN_ERC20_COLLECT_TYPEHASH = 0x9e6214229b9fba1927010d30b22a3a5d9fd5e856bb29f056416ff2ad52e8de44;

    bytes32 public constant HIDDEN_ERC721_COLLECT_TYPEHASH = 0xa14a2dc51c26e451800897aa798120e7d6c35039caf5eb29b8ac35d1e914c591;

    bytes32 public DOMAIN_SEPARATOR;
    uint256 public CHAIN_ID;
    bytes32 s_uid;
    uint256 s_fees;

    struct TokenInfo {
        bytes32 id;
        bytes32 id1;
        uint256 tr;
    }

    mapping(bytes32 => uint256) s_transfers;
    mapping(bytes32 => uint256) s_erc20Transfers;
    mapping(bytes32 => uint256) s_erc721Transfers;
    mapping(bytes32 => uint256) s_htransfers;

    string public constant NAME = "Kirobo Safe Transfer";
    string public constant VERSION = "1";
    uint8 public constant VERSION_NUMBER = 0x1;

    event Deposited(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash
    );

    event TimedDeposited(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash,
        uint64 availableAt,
        uint64 expiresAt,
        uint128 autoRetrieveFees
    );

    event Retrieved(
        address indexed from,
        address indexed to,
        bytes32 indexed id,
        uint256 value
    );

    event Collected(
        address indexed from,
        address indexed to,
        bytes32 indexed id,
        uint256 value
    );

    event ERC20Deposited(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash
    );

    event ERC20TimedDeposited(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash,
        uint64 availableAt,
        uint64 expiresAt,
        uint128 autoRetrieveFees
    );

    event ERC20Retrieved(
        address indexed token,
        address indexed from,
        address indexed to,
        bytes32 id,
        uint256 value
    );

    event ERC20Collected(
        address indexed token,
        address indexed from,
        address indexed to,
        bytes32 id,
        uint256 value
    );

    event ERC721Deposited(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 tokenId,
        uint256 fees,
        bytes32 secretHash
    );

    event ERC721TimedDeposited(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 tokenId,
        uint256 fees,
        bytes32 secretHash,
        uint64 availableAt,
        uint64 expiresAt,
        uint128 autoRetrieveFees
    );

    event ERC721Retrieved(
        address indexed token,
        address indexed from,
        address indexed to,
        bytes32 id,
        uint256 tokenId
    );

    event ERC721Collected(
        address indexed token,
        address indexed from,
        address indexed to,
        bytes32 id,
        uint256 tokenId
    );

    event HDeposited(
        address indexed from,
        uint256 value,
        bytes32 indexed id1
    );

    event HTimedDeposited(
        address indexed from,
        uint256 value,
        bytes32 indexed id1,
        uint64 availableAt,
        uint64 expiresAt,
        uint128 autoRetrieveFees
    );

    event HRetrieved(
        address indexed from,
        bytes32 indexed id1,
        uint256 value
    );

    event HCollected(
        address indexed from,
        address indexed to,
        bytes32 indexed id1,
        uint256 value
    );

    event HERC20Collected(
        address indexed token,
        address indexed from,
        address indexed to,
        bytes32 id1,
        uint256 value
    );

    event HERC721Collected(
        address indexed token,
        address indexed from,
        address indexed to,
        bytes32 id1,
        uint256 tokenId
    );

    modifier onlyActivator() {

        require(hasRole(ACTIVATOR_ROLE, msg.sender), "SafeTransfer: not an activator");
        _;
    }

    constructor (address activator) public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ACTIVATOR_ROLE, msg.sender);
        _setupRole(ACTIVATOR_ROLE, activator);

        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        CHAIN_ID = chainId;

        s_uid = bytes32(
          uint256(VERSION_NUMBER) << 248 |
          uint256(blockhash(block.number-1)) << 192 >> 16 |
          uint256(address(this))
        );

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"),
                keccak256(bytes(NAME)),
                keccak256(bytes(VERSION)),
                chainId,
                address(this),
                s_uid
            )
        );

    }

    receive () external payable {
        require(false, "SafeTransfer: not accepting ether directly");
    }

    function transferERC20(address token, address wallet, uint256 value) external onlyActivator() {

        IERC20(token).safeTransfer(wallet, value);
    }

    function transferERC721(address token, address wallet, uint256 tokenId, bytes calldata data) external onlyActivator() {

        IERC721(token).safeTransferFrom(address(this), wallet, tokenId, data);
    }

    function transferFees(address payable wallet, uint256 value) external onlyActivator() {

        s_fees = s_fees.sub(value);
        wallet.transfer(value);
    }

    function totalFees() external view returns (uint256) {

        return s_fees;
    }

    function uid() view external returns (bytes32) {

        return s_uid;
    }


    function deposit(
        address payable to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash
    )
        payable external
    {

        require(msg.value == value.add(fees), "SafeTransfer: value mismatch");
        require(to != msg.sender, "SafeTransfer: sender==recipient");
        bytes32 id = keccak256(abi.encode(msg.sender, to, value, fees, secretHash));
        require(s_transfers[id] == 0, "SafeTransfer: request exist");
        s_transfers[id] = 0xffffffffffffffff; // expiresAt: max, AvailableAt: 0, autoRetrieveFees: 0
        emit Deposited(msg.sender, to, value, fees, secretHash);
    }

    function timedDeposit(
        address payable to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash,
        uint64 availableAt,
        uint64 expiresAt,
        uint128 autoRetrieveFees
    )
        payable external
    {

        require(msg.value == value.add(fees), "SafeTransfer: value mismatch");
        require(fees >= autoRetrieveFees, "SafeTransfer: autoRetrieveFees exeed fees");
        require(to != msg.sender, "SafeTransfer: sender==recipient");
        require(expiresAt > now, "SafeTransfer: already expired");
        bytes32 id = keccak256(abi.encode(msg.sender, to, value, fees, secretHash));
        require(s_transfers[id] == 0, "SafeTransfer: request exist");
        s_transfers[id] = uint256(expiresAt) + uint256(availableAt << 64) + (uint256(autoRetrieveFees) << 128);
        emit TimedDeposited(msg.sender, to, value, fees, secretHash, availableAt, expiresAt, autoRetrieveFees);
    }

    function retrieve(
        address payable to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash
    )
        external
    {

        bytes32 id = keccak256(abi.encode(msg.sender, to, value, fees, secretHash));
        require(s_transfers[id]  > 0, "SafeTransfer: request not exist");
        delete s_transfers[id];
        uint256 valueToSend = value.add(fees);
        msg.sender.transfer(valueToSend);
        emit Retrieved(msg.sender, to, id, valueToSend);
    }

    function collect(
        address from,
        address payable to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash,
        bytes calldata secret
    )
        external
        onlyActivator()
    {

        bytes32 id = keccak256(abi.encode(from, to, value, fees, secretHash));
        uint256 tr = s_transfers[id];
        require(tr > 0, "SafeTransfer: request not exist");
        require(uint64(tr) > now, "SafeTranfer: expired");
        require(uint64(tr>>64) <= now, "SafeTranfer: not available yet");
        require(keccak256(secret) == secretHash, "SafeTransfer: wrong secret");
        delete s_transfers[id];
        s_fees = s_fees.add(fees);
        to.transfer(value);
        emit Collected(from, to, id, value);
    }

   function autoRetrieve(
        address payable from,
        address to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash
    )
        external
        onlyActivator()
    {

        bytes32 id = keccak256(abi.encode(from, to, value, fees, secretHash));
        uint256 tr = s_transfers[id];
        require(tr > 0, "SafeTransfer: request not exist");
        require(uint64(tr) <= now, "SafeTranfer: not expired");
        delete  s_transfers[id];
        s_fees = s_fees + (tr>>128); // autoRetreive fees
        uint256 valueToRetrieve = value.add(fees).sub(tr>>128);
        from.transfer(valueToRetrieve);
        emit Retrieved(from, to, id, valueToRetrieve);
    }


    function depositERC20(
        address token,
        string calldata tokenSymbol,
        address to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash
    )
        payable external
    {

        require(msg.value == fees, "SafeTransfer: msg.value must match fees");
        require(to != msg.sender, "SafeTransfer: sender==recipient");
        bytes32 id = keccak256(abi.encode(token, tokenSymbol, msg.sender, to, value, fees, secretHash));
        require(s_erc20Transfers[id] == 0, "SafeTransfer: request exist");
        s_erc20Transfers[id] = 0xffffffffffffffff;
        emit ERC20Deposited(token, msg.sender, to, value, fees, secretHash);
    }

    function timedDepositERC20(
        address token,
        string calldata tokenSymbol,
        address to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash,
        uint64 availableAt,
        uint64 expiresAt,
        uint128 autoRetrieveFees
    )
        payable external
    {

        require(msg.value == fees, "SafeTransfer: msg.value must match fees");
        require(fees >= autoRetrieveFees, "SafeTransfer: autoRetrieveFees exeed fees");
        require(to != msg.sender, "SafeTransfer: sender==recipient");
        require(expiresAt > now, "SafeTransfer: already expired");
        bytes32 id = keccak256(abi.encode(token, tokenSymbol, msg.sender, to, value, fees, secretHash));
        require(s_erc20Transfers[id] == 0, "SafeTransfer: request exist");
        s_erc20Transfers[id] = uint256(expiresAt) + (uint256(availableAt) << 64) + (uint256(autoRetrieveFees) << 128);
        emit ERC20TimedDeposited(token, msg.sender, to, value, fees, secretHash, availableAt, expiresAt, autoRetrieveFees);
    }

    function retrieveERC20(
        address token,
        string calldata tokenSymbol,
        address to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash
    )
        external
    {

        bytes32 id = keccak256(abi.encode(token, tokenSymbol, msg.sender, to, value, fees, secretHash));
        require(s_erc20Transfers[id]  > 0, "SafeTransfer: request not exist");
        delete s_erc20Transfers[id];
        msg.sender.transfer(fees);
        emit ERC20Retrieved(token, msg.sender, to, id, value);
    }

    function collectERC20(
        address token,
        string calldata tokenSymbol,
        address from,
        address payable to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash,
        bytes calldata secret
    )
        external
        onlyActivator()
    {

        bytes32 id = keccak256(abi.encode(token, tokenSymbol, from, to, value, fees, secretHash));
        uint256 tr = s_erc20Transfers[id];
        require(tr > 0, "SafeTransfer: request not exist");
        require(uint64(tr) > now, "SafeTranfer: expired");
        require(uint64(tr>>64) <= now, "SafeTranfer: not available yet");
        require(keccak256(secret) == secretHash, "SafeTransfer: wrong secret");
        delete s_erc20Transfers[id];
        s_fees = s_fees.add(fees);
        IERC20(token).safeTransferFrom(from, to, value);
        emit ERC20Collected(token, from, to, id, value);
    }

   function autoRetrieveERC20(
        address token,
        string calldata tokenSymbol,
        address payable from,
        address to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash
    )
        external
        onlyActivator()
    {

        bytes32 id = keccak256(abi.encode(token, tokenSymbol, from, to, value, fees, secretHash));
        uint256 tr = s_erc20Transfers[id];
        require(tr > 0, "SafeTransfer: request not exist");
        require(uint64(tr) <= now, "SafeTranfer: not expired");
        delete  s_erc20Transfers[id];
        s_fees = s_fees + (tr>>128); // autoRetreive fees
        from.transfer(fees.sub(tr>>128));
        emit ERC20Retrieved(token, from, to, id, value);
    }


    function depositERC721(
        address token,
        string calldata tokenSymbol,
        address to,
        uint256 tokenId,
        bytes calldata tokenData,
        uint256 fees,
        bytes32 secretHash
    )
        payable external
    {

        require(msg.value == fees, "SafeTransfer: msg.value must match fees");
        require(tokenId > 0, "SafeTransfer: no token id");
        require(to != msg.sender, "SafeTransfer: sender==recipient");
        bytes32 id = keccak256(abi.encode(token, tokenSymbol, msg.sender, to, tokenId, tokenData, fees, secretHash));
        require(s_erc721Transfers[id] == 0, "SafeTransfer: request exist");
        s_erc721Transfers[id] = 0xffffffffffffffff;
        emit ERC721Deposited(token, msg.sender, to, tokenId, fees, secretHash);
    }

    function timedDepositERC721(
        address token,
        string calldata tokenSymbol,
        address to,
        uint256 tokenId,
        bytes calldata tokenData,
        uint256 fees,
        bytes32 secretHash,
        uint64 availableAt,
        uint64 expiresAt,
        uint128 autoRetrieveFees
    )
        payable external
    {

        require(msg.value == fees, "SafeTransfer: msg.value must match fees");
        require(fees >= autoRetrieveFees, "SafeTransfer: autoRetrieveFees exeed fees");
        require(tokenId > 0, "SafeTransfer: no token id");
        require(to != msg.sender, "SafeTransfer: sender==recipient");
        require(expiresAt > now, "SafeTransfer: already expired");
        bytes32 id = keccak256(abi.encode(token, tokenSymbol, msg.sender, to, tokenId, tokenData, fees, secretHash));
        require(s_erc721Transfers[id] == 0, "SafeTransfer: request exist");
        s_erc721Transfers[id] = uint256(expiresAt) + (uint256(availableAt) << 64) + (uint256(autoRetrieveFees) << 128);
        emit ERC721TimedDeposited(token, msg.sender, to, tokenId, fees, secretHash, availableAt, expiresAt, autoRetrieveFees);
    }

    function retrieveERC721(
        address token,
        string calldata tokenSymbol,
        address to,
        uint256 tokenId,
        bytes calldata tokenData,
        uint256 fees,
        bytes32 secretHash
    )
        external
    {

        bytes32 id = keccak256(abi.encode(token, tokenSymbol, msg.sender, to, tokenId, tokenData, fees, secretHash));
        require(s_erc721Transfers[id]  > 0, "SafeTransfer: request not exist");
        delete s_erc721Transfers[id];
        msg.sender.transfer(fees);
        emit ERC721Retrieved(token, msg.sender, to, id, tokenId);
    }

    function collectERC721(
        address token,
        string calldata tokenSymbol,
        address from,
        address payable to,
        uint256 tokenId,
        bytes calldata tokenData,
        uint256 fees,
        bytes32 secretHash,
        bytes calldata secret
    )
        external
        onlyActivator()
    {

        bytes32 id = keccak256(abi.encode(token, tokenSymbol, from, to, tokenId, tokenData, fees, secretHash));
        uint256 tr = s_erc721Transfers[id];
        require(tr > 0, "SafeTransfer: request not exist");
        require(uint64(tr) > now, "SafeTranfer: expired");
        require(uint64(tr>>64) <= now, "SafeTranfer: not available yet");
        require(keccak256(secret) == secretHash, "SafeTransfer: wrong secret");
        delete s_erc721Transfers[id];
        s_fees = s_fees.add(fees);
        IERC721(token).safeTransferFrom(from, to, tokenId, tokenData);
        emit ERC721Collected(token, from, to, id, tokenId);
    }

   function autoRetrieveERC721(
        address token,
        string calldata tokenSymbol,
        address payable from,
        address to,
        uint256 tokenId,
        bytes calldata tokenData,
        uint256 fees,
        bytes32 secretHash
    )
        external
        onlyActivator()
    {

        bytes32 id = keccak256(abi.encode(token, tokenSymbol, from, to, tokenId, tokenData, fees, secretHash));
        uint256 tr = s_erc721Transfers[id];
        require(tr > 0, "SafeTransfer: request not exist");
        require(uint64(tr) <= now, "SafeTranfer: not expired");
        delete  s_erc721Transfers[id];
        s_fees = s_fees + (tr>>128); // autoRetreive fees
        from.transfer(fees.sub(tr>>128));
        emit ERC721Retrieved(token, from, to, id, tokenId);
    }


    function hiddenDeposit(bytes32 id1)
        payable external
    {

        bytes32 id = keccak256(abi.encode(msg.sender, msg.value, id1));
        require(s_htransfers[id] == 0, "SafeTransfer: request exist");
        s_htransfers[id] = 0xffffffffffffffff;
        emit HDeposited(msg.sender, msg.value, id1);
    }

    function hiddenTimedDeposit(
        bytes32 id1,
        uint64 availableAt,
        uint64 expiresAt,
        uint128 autoRetrieveFees
    )
        payable external
    {

        require(msg.value >= autoRetrieveFees, "SafeTransfers: autoRetrieveFees exeed value");
        bytes32 id = keccak256(abi.encode(msg.sender, msg.value, id1));
        require(s_htransfers[id] == 0, "SafeTransfer: request exist");
        require(expiresAt > now, "SafeTransfer: already expired");
        s_htransfers[id] = uint256(expiresAt) + (uint256(availableAt) << 64) + (uint256(autoRetrieveFees) << 128);
        emit HTimedDeposited(msg.sender, msg.value, id1, availableAt, expiresAt, autoRetrieveFees);
    }

    function hiddenRetrieve(
        bytes32 id1,
        uint256 value
    )
        external
    {

        bytes32 id = keccak256(abi.encode(msg.sender, value, id1));
        require(s_htransfers[id]  > 0, "SafeTransfer: request not exist");
        delete s_htransfers[id];
        msg.sender.transfer(value);
        emit HRetrieved(msg.sender, id1, value);
    }

    function hiddenCollect(
        address from,
        address payable to,
        uint256 value,
        uint256 fees,
        bytes32 secretHash,
        bytes calldata secret,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        onlyActivator()
    {

        bytes32 id1 = keccak256(abi.encode(HIDDEN_COLLECT_TYPEHASH, from, to, value, fees, secretHash));
        require(ecrecover(keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, id1)), v, r, s) == from, "SafeTransfer: wrong signature");
        bytes32 id = keccak256(abi.encode(from, value.add(fees), id1));
        uint256 tr = s_htransfers[id];
        require(tr > 0, "SafeTransfer: request not exist");
        require(uint64(tr) > now, "SafeTranfer: expired");
        require(uint64(tr>>64) <= now, "SafeTranfer: not available yet");
        require(keccak256(secret) == secretHash, "SafeTransfer: wrong secret");
        delete s_htransfers[id];
        s_fees = s_fees.add(fees);
        to.transfer(value);
        emit HCollected(from, to, id1, value);
    }

    function hiddenCollectERC20(
        address from,
        address to,
        address token,
        string memory tokenSymbol,
        uint256 value,
        uint256 fees,
        bytes32 secretHash,
        bytes calldata secret,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        onlyActivator()
    {

        TokenInfo memory tinfo;
        tinfo.id1 = keccak256(abi.encode(HIDDEN_ERC20_COLLECT_TYPEHASH, from, to, token, tokenSymbol, value, fees, secretHash));
        require(ecrecover(keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, tinfo.id1)), v, r, s) == from, "SafeTransfer: wrong signature");
        tinfo.id = keccak256(abi.encode(from, fees, tinfo.id1));
        uint256 tr = s_htransfers[tinfo.id];
        require(tr > 0, "SafeTransfer: request not exist");
        require(uint64(tr) > now, "SafeTranfer: expired");
        require(uint64(tr>>64) <= now, "SafeTranfer: not available yet");
        require(keccak256(secret) == secretHash, "SafeTransfer: wrong secret");
        delete s_htransfers[tinfo.id];
        s_fees = s_fees.add(fees);
        IERC20(token).safeTransferFrom(from, to, value);
        emit HERC20Collected(token, from, to, tinfo.id1, value);
    }

    function hiddenCollectERC721(
        address from,
        address to,
        address token,
        string memory tokenSymbol,
        uint256 tokenId,
        bytes memory tokenData,
        uint256 fees,
        bytes32 secretHash,
        bytes calldata secret,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        onlyActivator()
    {

        TokenInfo memory tinfo;
        tinfo.id1 = keccak256(abi.encode(HIDDEN_ERC721_COLLECT_TYPEHASH, from, to, token, tokenSymbol, tokenId, tokenData, fees, secretHash));
        require(ecrecover(keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, tinfo.id1)), v, r, s) == from, "SafeTransfer: wrong signature");
        tinfo.id = keccak256(abi.encode(from, fees, tinfo.id1));
        tinfo.tr = s_htransfers[tinfo.id];
        require(tinfo.tr > 0, "SafeTransfer: request not exist");
        require(uint64(tinfo.tr) > now, "SafeTranfer: expired");
        require(uint64(tinfo.tr>>64) <= now, "SafeTranfer: not available yet");
        require(keccak256(secret) == secretHash, "SafeTransfer: wrong secret");
        delete s_htransfers[tinfo.id];
        s_fees = s_fees.add(fees);
        IERC721(token).safeTransferFrom(from, to, tokenId, tokenData);
        emit HERC721Collected(token, from, to, tinfo.id1, tokenId);
    }

   function hiddenAutoRetrieve(
        address payable from,
        bytes32 id1,
        uint256 value
    )
        external
        onlyActivator()
    {

        bytes32 id = keccak256(abi.encode(from, value, id1));
        uint256 tr = s_htransfers[id];
        require(tr > 0, "SafeTransfer: request not exist");
        require(uint64(tr) <= now, "SafeTranfer: not expired");
        delete  s_htransfers[id];
        s_fees = s_fees + (tr>>128);
        uint256 toRetrieve = value.sub(tr>>128);
        from.transfer(toRetrieve);
        emit HRetrieved(from, id1, toRetrieve);
    }

}