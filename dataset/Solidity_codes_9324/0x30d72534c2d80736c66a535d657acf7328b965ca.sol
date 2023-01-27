

pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity >=0.5.7 <0.7.0;

interface ISatoshiToken{

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;


    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

}


pragma solidity ^0.5.0;

library EnumerableSet {


    struct AddressSet {
        mapping (address => uint256) index;
        address[] values;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        if (!contains(set, value)){
            set.index[value] = set.values.push(value);
            return true;
        } else {
            return false;
        }
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        if (contains(set, value)){
            uint256 toDeleteIndex = set.index[value] - 1;
            uint256 lastIndex = set.values.length - 1;

            if (lastIndex != toDeleteIndex) {
                address lastValue = set.values[lastIndex];

                set.values[toDeleteIndex] = lastValue;
                set.index[lastValue] = toDeleteIndex + 1; // All indexes are 1-based
            }

            delete set.index[value];

            set.values.pop();

            return true;
        } else {
            return false;
        }
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {

        return set.index[value] != 0;
    }

    function enumerate(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {

        address[] memory output = new address[](set.values.length);
        for (uint256 i; i < set.values.length; i++){
            output[i] = set.values[i];
        }
        return output;
    }

    function length(AddressSet storage set)
        internal
        view
        returns (uint256)
    {

        return set.values.length;
    }

    function get(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {

        return set.values[index];
    }
}


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.16;




contract AccessControl is Context {

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

        return _roles[role].members.get(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {

        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public {

        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public {

        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public {

        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal {

        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {

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


pragma solidity ^0.5.0;

interface IRelayRecipient {

    function getHubAddr() external view returns (address);


    function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256 maxPossibleCharge
    )
        external
        view
        returns (uint256, bytes memory);


    function preRelayedCall(bytes calldata context) external returns (bytes32);


    function postRelayedCall(bytes calldata context, bool success, uint256 actualCharge, bytes32 preRetVal) external;

}


pragma solidity ^0.5.0;

interface IRelayHub {


    function stake(address relayaddr, uint256 unstakeDelay) external payable;


    event Staked(address indexed relay, uint256 stake, uint256 unstakeDelay);

    function registerRelay(uint256 transactionFee, string calldata url) external;


    event RelayAdded(address indexed relay, address indexed owner, uint256 transactionFee, uint256 stake, uint256 unstakeDelay, string url);

    function removeRelayByOwner(address relay) external;


    event RelayRemoved(address indexed relay, uint256 unstakeTime);

    function unstake(address relay) external;


    event Unstaked(address indexed relay, uint256 stake);

    enum RelayState {
        Unknown, // The relay is unknown to the system: it has never been staked for
        Staked, // The relay has been staked for, but it is not yet active
        Registered, // The relay has registered itself, and is active (can relay calls)
        Removed    // The relay has been removed by its owner and can no longer relay calls. It must wait for its unstakeDelay to elapse before it can unstake
    }

    function getRelay(address relay) external view returns (uint256 totalStake, uint256 unstakeDelay, uint256 unstakeTime, address payable owner, RelayState state);



    function depositFor(address target) external payable;


    event Deposited(address indexed recipient, address indexed from, uint256 amount);

    function balanceOf(address target) external view returns (uint256);


    function withdraw(uint256 amount, address payable dest) external;


    event Withdrawn(address indexed account, address indexed dest, uint256 amount);


    function canRelay(
        address relay,
        address from,
        address to,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata signature,
        bytes calldata approvalData
    ) external view returns (uint256 status, bytes memory recipientContext);


    enum PreconditionCheck {
        OK,                         // All checks passed, the call can be relayed
        WrongSignature,             // The transaction to relay is not signed by requested sender
        WrongNonce,                 // The provided nonce has already been used by the sender
        AcceptRelayedCallReverted,  // The recipient rejected this call via acceptRelayedCall
        InvalidRecipientStatusCode  // The recipient returned an invalid (reserved) status code
    }

    function relayCall(
        address from,
        address to,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata signature,
        bytes calldata approvalData
    ) external;


    event CanRelayFailed(address indexed relay, address indexed from, address indexed to, bytes4 selector, uint256 reason);

    event TransactionRelayed(address indexed relay, address indexed from, address indexed to, bytes4 selector, RelayCallStatus status, uint256 charge);

    enum RelayCallStatus {
        OK,                      // The transaction was successfully relayed and execution successful - never included in the event
        RelayedCallFailed,       // The transaction was relayed, but the relayed call failed
        PreRelayedFailed,        // The transaction was not relayed due to preRelatedCall reverting
        PostRelayedFailed,       // The transaction was relayed and reverted due to postRelatedCall reverting
        RecipientBalanceChanged  // The transaction was relayed and reverted due to the recipient's balance changing
    }

    function requiredGas(uint256 relayedCallStipend) external view returns (uint256);


    function maxPossibleCharge(uint256 relayedCallStipend, uint256 gasPrice, uint256 transactionFee) external view returns (uint256);



    function penalizeRepeatedNonce(bytes calldata unsignedTx1, bytes calldata signature1, bytes calldata unsignedTx2, bytes calldata signature2) external;


    function penalizeIllegalTransaction(bytes calldata unsignedTx, bytes calldata signature) external;


    event Penalized(address indexed relay, address sender, uint256 amount);

    function getNonce(address from) external view returns (uint256);

}


pragma solidity ^0.5.0;




contract GSNRecipient is IRelayRecipient, Context {

    address private _relayHub = 0xD216153c06E857cD7f72665E0aF1d7D82172F494;

    uint256 constant private RELAYED_CALL_ACCEPTED = 0;
    uint256 constant private RELAYED_CALL_REJECTED = 11;

    uint256 constant internal POST_RELAYED_CALL_MAX_GAS = 100000;

    event RelayHubChanged(address indexed oldRelayHub, address indexed newRelayHub);

    function getHubAddr() public view returns (address) {

        return _relayHub;
    }

    function _upgradeRelayHub(address newRelayHub) internal {

        address currentRelayHub = _relayHub;
        require(newRelayHub != address(0), "GSNRecipient: new RelayHub is the zero address");
        require(newRelayHub != currentRelayHub, "GSNRecipient: new RelayHub is the current one");

        emit RelayHubChanged(currentRelayHub, newRelayHub);

        _relayHub = newRelayHub;
    }

    function relayHubVersion() public view returns (string memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return "1.0.0";
    }

    function _withdrawDeposits(uint256 amount, address payable payee) internal {

        IRelayHub(_relayHub).withdraw(amount, payee);
    }


    function _msgSender() internal view returns (address payable) {

        if (msg.sender != _relayHub) {
            return msg.sender;
        } else {
            return _getRelayedCallSender();
        }
    }

    function _msgData() internal view returns (bytes memory) {

        if (msg.sender != _relayHub) {
            return msg.data;
        } else {
            return _getRelayedCallData();
        }
    }


    function preRelayedCall(bytes calldata context) external returns (bytes32) {

        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        return _preRelayedCall(context);
    }

    function _preRelayedCall(bytes memory context) internal returns (bytes32);


    function postRelayedCall(bytes calldata context, bool success, uint256 actualCharge, bytes32 preRetVal) external {

        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        _postRelayedCall(context, success, actualCharge, preRetVal);
    }

    function _postRelayedCall(bytes memory context, bool success, uint256 actualCharge, bytes32 preRetVal) internal;


    function _approveRelayedCall() internal pure returns (uint256, bytes memory) {

        return _approveRelayedCall("");
    }

    function _approveRelayedCall(bytes memory context) internal pure returns (uint256, bytes memory) {

        return (RELAYED_CALL_ACCEPTED, context);
    }

    function _rejectRelayedCall(uint256 errorCode) internal pure returns (uint256, bytes memory) {

        return (RELAYED_CALL_REJECTED + errorCode, "");
    }

    function _computeCharge(uint256 gas, uint256 gasPrice, uint256 serviceFee) internal pure returns (uint256) {

        return (gas * gasPrice * (100 + serviceFee)) / 100;
    }

    function _getRelayedCallSender() private pure returns (address payable result) {



        bytes memory array = msg.data;
        uint256 index = msg.data.length;

        assembly {
            result := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    function _getRelayedCallData() private pure returns (bytes memory) {


        uint256 actualDataLength = msg.data.length - 20;
        bytes memory actualData = new bytes(actualDataLength);

        for (uint256 i = 0; i < actualDataLength; ++i) {
            actualData[i] = msg.data[i];
        }

        return actualData;
    }
}


pragma solidity ^0.5.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


pragma solidity ^0.5.16;



contract GSNRecipientSignature is GSNRecipient {

    using ECDSA for bytes32;

    address private _trustedSigner;

    enum GSNRecipientSignatureErrorCodes {
        INVALID_SIGNER
    }

    constructor(address trustedSigner) public {
        require(trustedSigner != address(0), "GSNRecipientSignature: trusted signer is the zero address");
        _trustedSigner = trustedSigner;
    }

    function setTrustedSigner(address trustedSigner) public {

        require(trustedSigner != address(0), "GSNRecipientSignature: trusted signer is the zero address");
        _trustedSigner = trustedSigner;
    }

    function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256
    )
        external
        view
        returns (uint256, bytes memory)
    {

        bytes memory blob = abi.encodePacked(
            relay,
            from,
            encodedFunction,
            transactionFee,
            gasPrice,
            gasLimit,
            nonce, // Prevents replays on RelayHub
            getHubAddr(), // Prevents replays in multiple RelayHubs
            address(this) // Prevents replays in multiple recipients
        );
        if (keccak256(blob).toEthSignedMessageHash().recover(approvalData) == _trustedSigner) {
            return _approveRelayedCall();
        } else {
            return _rejectRelayedCall(uint256(GSNRecipientSignatureErrorCodes.INVALID_SIGNER));
        }
    }

    function _preRelayedCall(bytes memory) internal returns (bytes32) {

    }

    function _postRelayedCall(bytes memory, bool, uint256, bytes32) internal {

    }
}


pragma solidity ^0.5.16;

library SafeMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64) {

        uint64 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint64 a, uint64 b, string memory errorMessage) internal pure returns (uint64) {

        require(b <= a, errorMessage);
        uint64 c = a - b;

        return c;
    }

    function mul(uint64 a, uint64 b) internal pure returns (uint64) {

        if (a == 0) {
            return 0;
        }

        uint64 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint64 a, uint64 b) internal pure returns (uint64) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint64 a, uint64 b, string memory errorMessage) internal pure returns (uint64) {

        require(b > 0, errorMessage);
        uint64 c = a / b;

        return c;
    }

    function mod(uint64 a, uint64 b) internal pure returns (uint64) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint64 a, uint64 b, string memory errorMessage) internal pure returns (uint64) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;


contract SatoshiAllotment is AccessControl, GSNRecipientSignature {

    using SafeERC20 for ISatoshiToken;
    using SafeMath for uint256;
    using SafeMath64 for uint64;

    bytes32 public constant ALLOTER_ROLE = keccak256("ALLOTER_ROLE");

    struct AllotmentRequest {
        uint64 id;
        uint64 start;
        uint64 cliff;
        uint64 duration;
        uint256 amount;
        uint256 amountReleased;
    }

    struct AllotmentResponse {
        uint64 id;
        uint64 start;
        uint64 cliff;
        uint64 duration;
        uint256 amount;
        uint256 amountReleased;
        uint256 amountAvailable;
    }

    struct AllotmentPlan {
        uint64 id;
        bool isValid;
        uint64 cliffDuration;
        uint64 duration;
    }

    struct TopUpData {
        address account;
        uint64 id;
        uint256 amount;
    }

    ISatoshiToken private _satoshiToken;

    AllotmentPlan[] private _allotmentPlans;

    mapping(address => AllotmentRequest[]) private _allotmentRequests;

    event TokenContractChanged(address indexed newAddress);
    event GrantedAllotment(address indexed account, uint256 id, uint256 amount, uint256 indexed timestamp);
    event TopUpAdded(address indexed account, uint256 indexed id, uint256 amount, uint256 indexed timestamp);
    event PlanAdded(uint256 indexed id, uint64 cliffDuration, uint64 duration);
    event PlanRemoved(uint256 indexed id);
    event ReleasedAmount(address indexed account, uint64[] ids, uint256[] amounts, uint256 indexed timestamp);

    constructor(
            address satoshiToken,
            uint64 cliffDuration,
            uint64 duration,
            address trustedSigner
        ) public GSNRecipientSignature(trustedSigner) {

        require(satoshiToken != address(0), "SatoshiAllotment: token is zero address");
        require(cliffDuration <= duration, "SatoshiAllotment: cliff is longer than duration");
        require(duration > 0, "SatoshiAllotment: duration is 0");

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ALLOTER_ROLE, _msgSender());
        _satoshiToken = ISatoshiToken(satoshiToken);

        _allotmentPlans.push(AllotmentPlan({
            id: 0,
            isValid: true,
            cliffDuration: cliffDuration,
            duration: duration
        }));

        emit PlanAdded(_allotmentPlans.length.sub(1), cliffDuration, duration);
    }

    function setTrustedSigner(address trustedSigner) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "SatoshiToken: must have admin role to change trustedSigner");
        super.setTrustedSigner(trustedSigner);
    }

    function getSatoshiTokenContract() public view returns (address) {

        return address(_satoshiToken);
    }

    function getAllotmentPlans(
        uint256 cursor,
        uint256 maxLength) public view returns (AllotmentPlan[] memory, uint256){


        uint256 length = maxLength;
        if (length > _allotmentPlans.length)
            length = _allotmentPlans.length;

        AllotmentPlan[] memory responses = new AllotmentPlan[](length);

        uint256 idCounter = 0;

        for (uint256 i = cursor; i < _allotmentPlans.length; i++) {
            AllotmentPlan memory plan = _allotmentPlans[i];

            if (true == plan.isValid) {
                responses[idCounter].id = plan.id;
                responses[idCounter].isValid = plan.isValid;
                responses[idCounter].cliffDuration = plan.cliffDuration;
                responses[idCounter].duration = plan.duration;

                idCounter++;
                if (idCounter >= length)
                    break;
            }
        }
        return (responses, idCounter);
    }

    function isAllotmentPlanValid(uint64 id) public view returns (bool) {

        return _allotmentPlans[id].isValid;
    }

    function getAllotmentPlanById(uint64 id) public view returns (AllotmentPlan memory) {

        return _allotmentPlans[id];
    }

    function _releasableAmount(AllotmentRequest memory request) private view returns (uint256) {

        return _allottedAmount(request).sub(request.amountReleased);
    }

    function _allottedAmount(AllotmentRequest memory request) private view returns (uint256) {

        uint256 totalBalance = request.amount;

        if (block.timestamp < request.cliff) {
            return 0;
        } else if (block.timestamp >= (request.start.add(request.duration))) {
            return totalBalance;
        } else {
            uint256 timeDiff = block.timestamp.sub((uint256)(request.start));

            return totalBalance.mul(timeDiff).div((uint256)(request.duration));
        }
    }

    function getAllotmentsByAccount(
        address account,
        uint256 cursor,
        uint256 maxLength,
        bool includeUpcoming,
        bool includeAll) public view returns (AllotmentResponse[] memory, uint256){


        AllotmentRequest[] memory requests = _allotmentRequests[account];
        uint256 allotmentLen = requests.length;

        uint256 length = maxLength;

        if (length > allotmentLen)
            length = allotmentLen;

        AllotmentResponse[] memory responses = new AllotmentResponse[](length);

        uint256 idCounter = 0;

        for (uint256 i = cursor; i < allotmentLen; i++) {
            uint256 releasableAmount;

            AllotmentRequest memory request = requests[i];

            if (block.timestamp >= request.cliff) {
                releasableAmount = _releasableAmount(request);
            }

            if ((releasableAmount > 0) ||
                ((true == includeUpcoming) && (block.timestamp < request.cliff)) ||
                (true == includeAll)) {
                responses[idCounter].id = request.id;
                responses[idCounter].amount = request.amount;
                responses[idCounter].start = request.start;
                responses[idCounter].cliff = request.cliff;
                responses[idCounter].duration = request.duration;
                responses[idCounter].amountReleased = request.amountReleased;
                responses[idCounter].amountAvailable = releasableAmount;

                idCounter++;
                if (idCounter >= length)
                    break;
            }
        }
        return (responses, idCounter);
    }

    function getAllotmentById(address account, uint64 id) public view returns (AllotmentResponse memory) {

        AllotmentRequest memory request = _allotmentRequests[account][id];
        uint256 releasableAmount = _releasableAmount(request);

        return (AllotmentResponse({
            id: request.id,
            amount: request.amount,
            start: request.start,
            cliff: request.cliff,
            duration: request.duration,
            amountReleased: request.amountReleased,
            amountAvailable: releasableAmount
        }));
    }

    function changeSatoshiTokenContract(address newAddress) external {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "SatoshiAllotment: must have admin role to change satoshi token contract"
        );
        _satoshiToken = ISatoshiToken(newAddress);

        emit TokenContractChanged(newAddress);
    }

    function grantAlloterRole(address account) external {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "SatoshiAllotment: sender must be an admin to grant");
        super.grantRole(ALLOTER_ROLE, account);
    }

    function addAllotmentPlan(uint64 cliffDuration, uint64 duration) external {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "SatoshiAllotment: must have admin role to add plan"
        );

        require(cliffDuration <= duration, "SatoshiAllotment: cliff is longer than duration");
        require(duration > 0, "SatoshiAllotment: duration is 0");

        uint256 length = _allotmentPlans.length;

        _allotmentPlans.push(AllotmentPlan({
            id: (uint64)(length),
            isValid: true,
            cliffDuration: cliffDuration,
            duration: duration
        }));
        emit PlanAdded(length, cliffDuration, duration);
    }

    function removeAllotmentPlan(uint256 id) external {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "SatoshiAllotment: must have admin role to remove plan"
        );
        require(_allotmentPlans[id].isValid == true, "SatoshiAllotment: deleted plan");
        delete(_allotmentPlans[id]);
        emit PlanRemoved(id);
    }

    function grantAllotment(address account,
        uint256 amount,
        uint64 start,
        uint256 planId) external returns (uint64) {


        require(hasRole(ALLOTER_ROLE, _msgSender()),
            "SatoshiAllotment: must have alloter role to allot tokens"
        );
        require(account != address(0), "SatoshiAllotment: account is zero address");
        require(start >= block.timestamp, "SatoshiAllotment: start < now");

        AllotmentPlan memory plan = _allotmentPlans[planId];
        require(plan.isValid == true, "SatoshiAllotment: deleted plan");

        uint256 id = _allotmentRequests[account].length;
        require(id < (uint256)(~uint64(0)), "SatoshiAllotment: Max allotment IDs reached");

        _allotmentRequests[account].push(AllotmentRequest({
            id: (uint64)(id),
            start: start,
            cliff: start.add(plan.cliffDuration),
            duration: plan.duration,
            amount: amount,
            amountReleased: 0
        }));

        emit GrantedAllotment(account, (uint64)(id), amount, block.timestamp);

        return (uint64)(id);
    }

    function topUp(address[] calldata accounts, uint64[] calldata ids, uint256[] calldata amounts) external {

        require(hasRole(ALLOTER_ROLE, _msgSender()),
            "SatoshiAllotment: must have alloter role to topup allotment tokens"
        );

        require(accounts.length == ids.length, "SatoshiAllotment: accounts length doesn't match with ids length");
        require(ids.length == amounts.length, "SatoshiAllotment: ids length doesn't match with amounts length");

        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "SatoshiAllotment: account is zero address");
            require(amounts[i] > 0, "SatoshiAllotment: amount is zero");

            AllotmentRequest storage requestPointer = _allotmentRequests[accounts[i]][ids[i]];

            require(requestPointer.start.add(requestPointer.duration) > block.timestamp, "SatoshiAllotment: allotment has expired");

            requestPointer.amount += amounts[i];

            emit TopUpAdded(accounts[i], ids[i], amounts[i], block.timestamp);
        }
    }

    function release(address account, uint64[] calldata ids) external {

        require(account != address(0), "SatoshiAllotment: account is zero address");
        require(ids.length > 0, "SatoshiAllotment: Ids are empty");
        uint256 amountToBeReleased = 0;
        uint256 totalAmountToBeReleased = 0;

        AllotmentRequest[] storage requests = _allotmentRequests[account];

        uint256 allotmentLen = requests.length;
        uint256 maxLength = ids.length;

        uint256[] memory amountsReleased = new uint256[](maxLength);

        if (maxLength > allotmentLen)
            maxLength = allotmentLen;

        for (uint256 i = 0; i < maxLength; i++) {
            require (ids[i] < allotmentLen, "SatoshiAllotment: invalid allotment id");

            AllotmentRequest storage requestPointer = requests[ids[i]];

            AllotmentRequest memory request = requests[ids[i]];

            if (block.timestamp >= request.cliff) {
                amountToBeReleased = _releasableAmount(request);

                totalAmountToBeReleased = totalAmountToBeReleased.add(amountToBeReleased);

                amountsReleased[i] = amountToBeReleased;

                if ((request.amountReleased.add(amountToBeReleased)) >= request.amount)
                    delete(requests[ids[i]]);
                else // Update released amount
                    requestPointer.amountReleased = request.amountReleased.add(amountToBeReleased);
            }
        }

        if (totalAmountToBeReleased > 0)
            _satoshiToken.mint(account, totalAmountToBeReleased);

        emit ReleasedAmount(account, ids, amountsReleased, block.timestamp);
    }
}