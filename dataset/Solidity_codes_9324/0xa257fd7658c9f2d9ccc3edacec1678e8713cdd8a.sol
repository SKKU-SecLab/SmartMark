

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


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;




abstract contract GSNRecipient is IRelayRecipient, Context {
    address private _relayHub = 0xD216153c06E857cD7f72665E0aF1d7D82172F494;

    uint256 constant private _RELAYED_CALL_ACCEPTED = 0;
    uint256 constant private _RELAYED_CALL_REJECTED = 11;

    uint256 constant internal _POST_RELAYED_CALL_MAX_GAS = 100000;

    event RelayHubChanged(address indexed oldRelayHub, address indexed newRelayHub);

    function getHubAddr() public view override returns (address) {
        return _relayHub;
    }

    function _upgradeRelayHub(address newRelayHub) internal virtual {
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

    function _withdrawDeposits(uint256 amount, address payable payee) internal virtual {
        IRelayHub(_relayHub).withdraw(amount, payee);
    }


    function _msgSender() internal view virtual override returns (address payable) {
        if (msg.sender != _relayHub) {
            return msg.sender;
        } else {
            return _getRelayedCallSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes memory) {
        if (msg.sender != _relayHub) {
            return msg.data;
        } else {
            return _getRelayedCallData();
        }
    }


    function preRelayedCall(bytes memory context) public virtual override returns (bytes32) {
        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        return _preRelayedCall(context);
    }

    function _preRelayedCall(bytes memory context) internal virtual returns (bytes32);

    function postRelayedCall(bytes memory context, bool success, uint256 actualCharge, bytes32 preRetVal) public virtual override {
        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        _postRelayedCall(context, success, actualCharge, preRetVal);
    }

    function _postRelayedCall(bytes memory context, bool success, uint256 actualCharge, bytes32 preRetVal) internal virtual;

    function _approveRelayedCall() internal pure returns (uint256, bytes memory) {
        return _approveRelayedCall("");
    }

    function _approveRelayedCall(bytes memory context) internal pure returns (uint256, bytes memory) {
        return (_RELAYED_CALL_ACCEPTED, context);
    }

    function _rejectRelayedCall(uint256 errorCode) internal pure returns (uint256, bytes memory) {
        return (_RELAYED_CALL_REJECTED + errorCode, "");
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





abstract contract ERC20Fees is GSNRecipient, PayoutWallet
{
    enum ErrorCodes {
        INSUFFICIENT_BALANCE,
        RESTRICTED_METHOD
    }

    IERC20 public _gasToken;
    uint public _gasPriceScaling = GAS_PRICE_SCALING_SCALE;

    uint constant internal GAS_PRICE_SCALING_SCALE = 1000;

    constructor(address gasTokenAddress, address payoutWallet) internal PayoutWallet(payoutWallet) {
        setGasToken(gasTokenAddress);
    }

    function setGasToken(address gasTokenAddress) public onlyOwner {
        _gasToken = IERC20(gasTokenAddress);
    }

    function setGasPrice(uint gasPriceScaling) public onlyOwner {
        _gasPriceScaling = gasPriceScaling;
    }

    function withdrawDeposits(uint256 amount, address payable payee) external onlyOwner {
        _withdrawDeposits(amount, payee);
    }

    function acceptRelayedCall(
        address,
        address from,
        bytes memory,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256,
        uint256,
        bytes memory,
        uint256 maxPossibleCharge
    )
        public
        virtual
        override
        view
        returns (uint256, bytes memory)
    {
        if (_gasToken.balanceOf(from) < (maxPossibleCharge * _gasPriceScaling / GAS_PRICE_SCALING_SCALE)) {
            return _rejectRelayedCall(uint256(ErrorCodes.INSUFFICIENT_BALANCE));
        }

        return _approveRelayedCall(abi.encode(from, maxPossibleCharge, transactionFee, gasPrice));
    }

    function _preRelayedCall(bytes memory context) internal override returns (bytes32) {
        (address from, uint256 maxPossibleCharge) = abi.decode(context, (address, uint256));

        require(_gasToken.transferFrom(from, _payoutWallet, maxPossibleCharge * _gasPriceScaling / GAS_PRICE_SCALING_SCALE));
    }

    function _postRelayedCall(bytes memory context, bool, uint256 actualCharge, bytes32) internal override {
        (address from, uint256 maxPossibleCharge, uint256 transactionFee, uint256 gasPrice) =
            abi.decode(context, (address, uint256, uint256, uint256));

        uint256 overestimation = _computeCharge(SafeMath.sub(_POST_RELAYED_CALL_MAX_GAS, 10000), gasPrice, transactionFee);
        actualCharge = SafeMath.sub(actualCharge, overestimation);

        require(_gasToken.transferFrom(_payoutWallet, from, SafeMath.sub(maxPossibleCharge, actualCharge) * _gasPriceScaling / GAS_PRICE_SCALING_SCALE));
    }

    function _msgSender() internal virtual override(Context, GSNRecipient) view returns (address payable) {
        return super._msgSender();
    }

    function _msgData() internal virtual override(Context, GSNRecipient) view returns (bytes memory) {
        return super._msgData();
    }
}


pragma solidity ^0.6.6;


contract PauserRole is AccessControl {


    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    constructor () internal {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        emit PauserAdded(_msgSender());
    }

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function addPauser(address account) public onlyPauser {

        grantRole(DEFAULT_ADMIN_ROLE, account);
        emit PauserAdded(account);
    }

    function renouncePauser() public {

        renounceRole(DEFAULT_ADMIN_ROLE, _msgSender());
        emit PauserRemoved(_msgSender());
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


abstract contract ERC1155PausableCollections is Pausable {
    event CollectionsPaused(uint256[] collectionIds, address pauser);
    event CollectionsUnpaused(uint256[] collectionIds, address pauser);

    mapping(uint256 => bool) internal _pausedCollections;

    function pauseCollections(uint256[] memory collectionIds) public virtual;

    function unpauseCollections(uint256[] memory collectionIds) public virtual;

    function pause() public virtual;

    function unpause() public virtual;
}


pragma solidity ^0.6.6;




abstract contract PausableInventory is AssetsInventory, ERC1155PausableCollections, PauserRole
{

    constructor(uint256 nfMaskLength) internal AssetsInventory(nfMaskLength)  {}


    modifier whenIdPaused(uint256 id) {
        require(idPaused(id));
        _;
    }

    modifier whenIdNotPaused(uint256 id) {
        require(!idPaused(id)                                                                                            );
        _;
    }

    function idPaused(uint256 id) public virtual view returns (bool) {
        if (isNFT(id)) {
            return _pausedCollections[collectionOf(id)];
        } else {
            return _pausedCollections[id];
        }
    }

    function pauseCollections(uint256[] memory collectionIds) public virtual override onlyPauser {
        for (uint256 i=0; i<collectionIds.length; i++) {
            uint256 collectionId = collectionIds[i];
            require(!isNFT(collectionId)); // only works on collections
            _pausedCollections[collectionId] = true;
        }
        emit CollectionsPaused(collectionIds, _msgSender());
    }

    function unpauseCollections(uint256[] memory collectionIds) public virtual override onlyPauser {
        for (uint256 i=0; i<collectionIds.length; i++) {
            uint256 collectionId = collectionIds[i];
            require(!isNFT(collectionId)); // only works on collections
            _pausedCollections[collectionId] = false;
        }
        emit CollectionsUnpaused(collectionIds, _msgSender());
    }

    function pause() public virtual override onlyPauser {
        _pause();
    }

    function unpause() public virtual override onlyPauser {
        _unpause();
    }



    function approve(address to, uint256 tokenId
    ) public virtual override whenNotPaused whenIdNotPaused(tokenId) {
        super.approve(to, tokenId);
    }

    function setApprovalForAll(address to, bool approved
    ) public virtual override whenNotPaused {
        super.setApprovalForAll(to, approved);
    }

    function transferFrom(address from, address to, uint256 tokenId
    ) public virtual override whenNotPaused whenIdNotPaused(tokenId) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId
    ) public virtual override whenNotPaused whenIdNotPaused(tokenId) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data
    ) public virtual override whenNotPaused whenIdNotPaused(tokenId) {
        super.safeTransferFrom(from, to, tokenId, data);
    }


    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data
    ) public virtual override whenNotPaused whenIdNotPaused(id) {
        super.safeTransferFrom(from, to, id, value, data);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory values, bytes memory data
    ) public virtual override whenNotPaused {
        for (uint256 i = 0; i < ids.length; ++i) {
            require(!idPaused(ids[i]));
        }
        super.safeBatchTransferFrom(from, to, ids, values, data);
    }
}


pragma solidity ^0.6.6;






contract QuiddInventory is PausableInventory, Ownable, MinterRole {


    string public override constant name = "Quidd Inventory";
    string public override constant symbol = "QUIDD";

    using RichUInt256 for uint256;

    uint256 internal constant _nfMaskLength = 32;

    string private _uriPrefix = "https://quidd-nft.animocabrands.com/json/";

    mapping(uint256 => bytes32) private _uris;

    mapping(uint256 => bool) private _collections;

    constructor() public PausableInventory(_nfMaskLength) {}

    function createCollection(uint256 collectionId) external onlyOwner {

        require(!isNFT(collectionId));
        _collections[collectionId] = true;
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

    function mintNonFungible(address to, uint256 tokenId) external onlyMinter {

        _mintNonFungible(to, tokenId, false);
    }

    function _mintNonFungible(address to, uint256 id, bool typeChecked) internal virtual override {

        require(_collections[collectionOf(id)], "Non-fungible collection has not been created");
        super._mintNonFungible(to, id, typeChecked);
    }

    function mintFungible(address to, uint256 collection, uint256 value) external onlyMinter {

        _mintFungible(to, collection, value, false);
    }

    function _mintFungible(address to, uint256 collection, uint256 value, bool typeChecked) internal virtual override {

        require(_collections[collection], "Fungible collection has not been created");
        super._mintFungible(to, collection, value, typeChecked);
    }



    function _uri(uint256 id) internal override view returns (string memory) {

        return _fullUriFromId(id);
    }

    function setUriPrefix(string calldata uriPrefix) external onlyOwner {

        _uriPrefix = uriPrefix;
    }

    function _fullUriFromId(uint256 id) private view returns(string memory) {

        return string(abi.encodePacked(abi.encodePacked(_uriPrefix, id.toString(10))));
    }
}