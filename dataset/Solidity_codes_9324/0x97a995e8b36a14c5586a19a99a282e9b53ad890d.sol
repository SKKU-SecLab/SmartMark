
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
}// MIT

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


abstract contract Pausable is Context {
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
}/// AGPL-3.0-or-later
pragma solidity 0.6.12;




interface WFILToken {

  function wrap(address to, uint256 amount) external returns (bool);

  function unwrapFrom(address account, uint256 amount) external returns (bool);

}

contract WFILFactory is AccessControl, Pausable {


    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    enum RequestStatus {PENDING, CANCELED, APPROVED, REJECTED}

    struct Request {
      address requester; // sender of the request.
      address custodian; // custodian associated to sender
      uint256 amount; // amount of fil to mint/burn.
      string deposit; // custodian's fil address in mint, merchant's fil address in burn.
      string txId; // filcoin txId for sending/redeeming fil in the mint/burn process.
      uint256 nonce; // serial number allocated for each request.
      uint256 timestamp; // time of the request creation.
      RequestStatus status; // status of the request.
    }

    WFILToken internal immutable wfil;

    Counters.Counter private _mintsIdTracker;
    Counters.Counter private _burnsIdTracker;

    mapping(address => string) public custodianDeposit;
    mapping(address => string) public merchantDeposit;
    mapping(bytes32 => uint256) public mintNonce;
    mapping(bytes32 => uint256) public burnNonce;
    mapping(uint256 => Request) public mints;
    mapping(uint256 => Request) public burns;

    bytes32 public constant CUSTODIAN_ROLE = keccak256("CUSTODIAN_ROLE");
    bytes32 public constant MERCHANT_ROLE = keccak256("MERCHANT_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    event CustodianDepositSet(address indexed merchant, address indexed custodian, string deposit);
    event MerchantDepositSet(address indexed merchant, string deposit);
    event MintRequestAdd(
        uint256 indexed nonce,
        address indexed requester,
        address indexed custodian,
        uint256 amount,
        string deposit,
        string txId,
        uint256 timestamp,
        bytes32 requestHash
    );
    event MintRequestCancel(uint256 indexed nonce, address indexed requester, bytes32 requestHash);
    event MintConfirmed(
        uint256 indexed nonce,
        address indexed requester,
        address indexed custodian,
        uint256 amount,
        string deposit,
        string txId,
        uint256 timestamp,
        bytes32 requestHash
    );
    event MintRejected(
        uint256 indexed nonce,
        address indexed requester,
        address indexed custodian,
        uint256 amount,
        string deposit,
        string txId,
        uint256 timestamp,
        bytes32 requestHash
    );
    event Burned(
        uint256 indexed nonce,
        address indexed requester,
        address indexed custodian,
        uint256 amount,
        string deposit,
        uint256 timestamp,
        bytes32 requestHash
    );
    event BurnConfirmed(
        uint256 indexed nonce,
        address indexed requester,
        address indexed custodian,
        uint256 amount,
        string deposit,
        string txId,
        uint256 timestamp,
        bytes32 inputRequestHash
    );
    event BurnRejected(
        uint256 indexed nonce,
        address indexed requester,
        address indexed custodian,
        uint256 amount,
        string deposit,
        string txId,
        uint256 timestamp,
        bytes32 inputRequestHash
    );
    event TokenClaimed(IERC20 indexed token, address indexed recipient, uint256 amount);

    constructor(address wfil_, address dao_)
        public
    {
        require(wfil_ != address(0), "WFILFactory: wfil token set to zero address");
        require(dao_ != address(0), "WFILFactory: dao set to zero address");

        _setupRole(DEFAULT_ADMIN_ROLE, dao_);
        _setupRole(PAUSER_ROLE, dao_);

        wfil = WFILToken(wfil_);

    }

    fallback() external {
        revert("WFILFactory: function not matching any other");
    }

    function setCustodianDeposit(address merchant, string calldata deposit)
      external
      whenNotPaused
    {

        require(hasRole(CUSTODIAN_ROLE, msg.sender), "WFILFactory: caller is not a custodian");
        require(merchant != address(0), "WFILFactory: invalid merchant address");
        require(hasRole(MERCHANT_ROLE, merchant), "WFILFactory: merchant address does not have merchant role");
        require(!_isEmpty(deposit), "WFILFactory: invalid asset deposit address");
        require(!_compareStrings(deposit, custodianDeposit[merchant]), "WFILFactory: custodian deposit address already set");

        custodianDeposit[merchant] = deposit;
        emit CustodianDepositSet(merchant, msg.sender, deposit);
    }

    function setMerchantDeposit(string calldata deposit)
        external
        whenNotPaused
    {

        require(hasRole(MERCHANT_ROLE, msg.sender), "WFILFactory: caller is not a merchant");
        require(!_isEmpty(deposit), "WFILFactory: invalid asset deposit address");
        require(!_compareStrings(deposit, merchantDeposit[msg.sender]), "WFILFactory: merchant deposit address already set");

        merchantDeposit[msg.sender] = deposit;
        emit MerchantDepositSet(msg.sender, deposit);
    }

    function addMintRequest(uint256 amount, string calldata txId, address custodian)
        external
        whenNotPaused
    {

        require(hasRole(MERCHANT_ROLE, msg.sender), "WFILFactory: caller is not a merchant");
        require(amount > 0, "WFILFactory: amount is zero");
        require(!_isEmpty(txId), "WFILFactory: invalid filecoin txId");
        require(hasRole(CUSTODIAN_ROLE, custodian), "WFILFactory: custodian has not the custodian role");

        string memory deposit = custodianDeposit[msg.sender];
        require(!_isEmpty(deposit), "WFILFactory: custodian filecoin deposit address was not set");

        uint256 nonce = _mintsIdTracker.current();
        uint256 timestamp = _timestamp();

        mints[nonce].requester = msg.sender;
        mints[nonce].custodian = custodian;
        mints[nonce].amount = amount;
        mints[nonce].deposit = deposit;
        mints[nonce].txId = txId;
        mints[nonce].nonce = nonce;
        mints[nonce].timestamp = timestamp;
        mints[nonce].status = RequestStatus.PENDING;

        bytes32 requestHash = _hash(mints[nonce]);
        mintNonce[requestHash] = nonce;
        _mintsIdTracker.increment();

        emit MintRequestAdd(nonce, msg.sender, custodian, amount, deposit, txId, timestamp, requestHash);
    }

    function cancelMintRequest(bytes32 requestHash) external whenNotPaused {

        require(hasRole(MERCHANT_ROLE, msg.sender), "WFILFactory: caller is not a merchant");

        (uint256 nonce, Request memory request) = _getPendingMintRequest(requestHash);

        require(msg.sender == request.requester, "WFILFactory: cancel caller is different than pending request initiator");
        mints[nonce].status = RequestStatus.CANCELED;

        emit MintRequestCancel(nonce, msg.sender, requestHash);
    }

    function confirmMintRequest(bytes32 requestHash) external whenNotPaused {

        require(hasRole(CUSTODIAN_ROLE, msg.sender), "WFILFactory: caller is not a custodian");

        (uint256 nonce, Request memory request) = _getPendingMintRequest(requestHash);

        require(msg.sender == request.custodian, "WFILFactory: confirm caller is different than pending request custodian");

        mints[nonce].status = RequestStatus.APPROVED;

        emit MintConfirmed(
            request.nonce,
            request.requester,
            request.custodian,
            request.amount,
            request.deposit,
            request.txId,
            request.timestamp,
            requestHash
        );

        require(wfil.wrap(request.requester, request.amount), "WFILFactory: mint failed");
    }

    function rejectMintRequest(bytes32 requestHash) external whenNotPaused {

        require(hasRole(CUSTODIAN_ROLE, msg.sender), "WFILFactory: caller is not a custodian");

        (uint256 nonce, Request memory request) = _getPendingMintRequest(requestHash);

        require(msg.sender == request.custodian, "WFILFactory: reject caller is different than pending request custodian");

        mints[nonce].status = RequestStatus.REJECTED;

        emit MintRejected(
            request.nonce,
            request.requester,
            request.custodian,
            request.amount,
            request.deposit,
            request.txId,
            request.timestamp,
            requestHash
        );
    }

    function addBurnRequest(uint256 amount, address custodian) external whenNotPaused {

        require(hasRole(MERCHANT_ROLE, msg.sender), "WFILFactory: caller is not a merchant");
        require(amount > 0, "WFILFactory: amount is zero");
        require(hasRole(CUSTODIAN_ROLE, custodian), "WFILFactory: custodian has not the custodian role");

        string memory deposit = merchantDeposit[msg.sender];
        require(!_isEmpty(deposit), "WFILFactory: merchant filecoin deposit address was not set");

        uint256 nonce = _burnsIdTracker.current();
        uint256 timestamp = _timestamp();

        string memory txId = "";

        burns[nonce].requester = msg.sender;
        burns[nonce].custodian = custodian;
        burns[nonce].amount = amount;
        burns[nonce].deposit = deposit;
        burns[nonce].txId = txId;
        burns[nonce].nonce = nonce;
        burns[nonce].timestamp = timestamp;
        burns[nonce].status = RequestStatus.PENDING;

        bytes32 requestHash = _hash(burns[nonce]);
        burnNonce[requestHash] = nonce;
        _burnsIdTracker.increment();

        emit Burned(nonce, msg.sender, custodian, amount, deposit, timestamp, requestHash);

        require(wfil.unwrapFrom(msg.sender, amount), "WFILFactory: burn failed");
    }

    function confirmBurnRequest(bytes32 requestHash, string calldata txId) external whenNotPaused {

        require(hasRole(CUSTODIAN_ROLE, msg.sender), "WFILFactory: caller is not a custodian");
        require(!_isEmpty(txId), "WFILFactory: invalid filecoin txId");

        (uint256 nonce, Request memory request) = _getPendingBurnRequest(requestHash);

        require(msg.sender == request.custodian, "WFILFactory: confirm caller is different than pending request custodian");

        burns[nonce].txId = txId;
        burns[nonce].status = RequestStatus.APPROVED;
        burnNonce[_hash(burns[nonce])] = nonce;

        emit BurnConfirmed(
            request.nonce,
            request.requester,
            request.custodian,
            request.amount,
            request.deposit,
            txId,
            request.timestamp,
            requestHash
        );
    }

    function rejectBurnRequest(bytes32 requestHash) external whenNotPaused {

        require(hasRole(CUSTODIAN_ROLE, msg.sender), "WFILFactory: caller is not a custodian");

        (uint256 nonce, Request memory request) = _getPendingBurnRequest(requestHash);

        require(msg.sender == request.custodian, "WFILFactory: reject caller is different than pending request custodian");

        burns[nonce].status = RequestStatus.REJECTED;

        emit BurnRejected(
            request.nonce,
            request.requester,
            request.custodian,
            request.amount,
            request.deposit,
            request.txId,
            request.timestamp,
            requestHash
        );

        require(wfil.wrap(request.requester, request.amount), "WFILFactory: mint failed");
    }

    function getMintRequest(uint256 nonce)
        external
        view
        returns (
            uint256 requestNonce,
            address requester,
            address custodian,
            uint256 amount,
            string memory deposit,
            string memory txId,
            uint256 timestamp,
            string memory status,
            bytes32 requestHash
        )
    {

        require(_mintsIdTracker.current() > nonce, "WFILFactory: invalid mint request nonce");
        Request memory request = mints[nonce];
        string memory statusString = _getStatusString(request.status);

        requestNonce = request.nonce;
        requester = request.requester;
        custodian = request.custodian;
        amount = request.amount;
        deposit = request.deposit;
        txId = request.txId;
        timestamp = request.timestamp;
        status = statusString;
        requestHash = _hash(request);
    }

    function getMintRequestsCount() external view returns (uint256 count) {

        return _mintsIdTracker.current();
    }

    function getBurnRequest(uint256 nonce)
        external
        view
        returns (
            uint256 requestNonce,
            address requester,
            address custodian,
            uint256 amount,
            string memory deposit,
            string memory txId,
            uint256 timestamp,
            string memory status,
            bytes32 requestHash
        )
    {

        require(_burnsIdTracker.current() > nonce, "WFILFactory: invalid burn request nonce");
        Request memory request = burns[nonce];
        string memory statusString = _getStatusString(request.status);

        requestNonce = request.nonce;
        requester = request.requester;
        custodian = request.custodian;
        amount = request.amount;
        deposit = request.deposit;
        txId = request.txId;
        timestamp = request.timestamp;
        status = statusString;
        requestHash = _hash(request);
    }

    function getBurnRequestsCount() external view returns (uint256 count) {

        return _burnsIdTracker.current();
    }


    function reclaimToken(IERC20 token, address recipient) external {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "WFILFactory: caller is not the default admin");
        require(recipient != address(0), "WFILFactory: recipient is the zero address");
        uint256 balance = token.balanceOf(address(this));
        token.safeTransfer(recipient, balance);
        emit TokenClaimed(token, recipient, balance);
    }


    function addCustodian(address account) external returns (bool) {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "WFILFactory: caller is not the default admin");
        require(account != address(0), "WFILFactory: account is the zero address");
        require(!hasRole(CUSTODIAN_ROLE, account), "WFILFactory: account is already a custodian");
        grantRole(CUSTODIAN_ROLE, account);
        return true;
    }

    function removeCustodian(address account) external returns (bool) {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "WFILFactory: caller is not the default admin");
        require(hasRole(CUSTODIAN_ROLE, account), "WFILFactory: account is not a custodian");
        revokeRole(CUSTODIAN_ROLE, account);
        return true;
    }

    function addMerchant(address account) external returns (bool) {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "WFILFactory: caller is not the default admin");
        require(account != address(0), "WFILFactory: account is the zero address");
        require(!hasRole(MERCHANT_ROLE, account), "WFILFactory: account is already a merchant");
        grantRole(MERCHANT_ROLE, account);
        return true;
    }

    function removeMerchant(address account) external returns (bool) {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "WFILFactory: caller is not the default admin");
        require(hasRole(MERCHANT_ROLE, account), "WFILFactory: account is not a merchant");
        revokeRole(MERCHANT_ROLE, account);
        return true;
    }

    function pause() external {

        require(hasRole(PAUSER_ROLE, msg.sender), "WFILFactory: must have pauser role to pause");
        _pause();
    }

    function unpause() external {

        require(hasRole(PAUSER_ROLE, msg.sender), "WFILFactory: must have pauser role to unpause");
        _unpause();
    }

    function _compareStrings(string memory a, string memory b) internal pure returns (bool) {

        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function _isEmpty(string memory a) internal pure returns (bool) {

       return bytes(a).length == 0;
    }

    function _timestamp() internal view returns (uint256) {

      return block.timestamp;
    }

    function _hash(Request memory request) internal pure returns (bytes32 hash) {

        return keccak256(abi.encode(
            request.requester,
            request.custodian,
            request.amount,
            request.deposit,
            request.txId,
            request.nonce,
            request.timestamp
        ));
    }

    function _getPendingMintRequest(bytes32 requestHash) internal view returns (uint256 nonce, Request memory request) {

        require(requestHash != 0, "WFILFactory: request hash is 0");
        nonce = mintNonce[requestHash];
        request = mints[nonce];
        _check(request, requestHash);
    }

    function _getPendingBurnRequest(bytes32 requestHash) internal view returns (uint256 nonce, Request memory request) {

        require(requestHash != 0, "WFILFactory: request hash is 0");
            nonce = burnNonce[requestHash];
            request = burns[nonce];
            _check(request, requestHash);
    }

    function _check(Request memory request, bytes32 requestHash) internal pure {

        require(request.status == RequestStatus.PENDING, "WFILFactory: request is not pending");
        require(requestHash == _hash(request), "WFILFactory: given request hash does not match a pending request");
    }

    function _getStatusString(RequestStatus status) internal pure returns (string memory) {

        if (status == RequestStatus.PENDING) return "pending";
        else if (status == RequestStatus.CANCELED) return "canceled";
        else if (status == RequestStatus.APPROVED) return "approved";
        else if (status == RequestStatus.REJECTED) return "rejected";
        else revert("WFILFactory: unknown status");
    }
}