pragma solidity ^0.6.0;

interface IERC1820Registry {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(address account, bytes32 interfaceHash, address implementer) external;


    function getInterfaceImplementer(address account, bytes32 interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}
pragma solidity ^0.6.0;

interface IERC777Recipient {

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

}
pragma solidity ^0.6.0;

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
pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}
pragma solidity ^0.6.0;

contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}
pragma solidity ^0.6.0;


abstract contract AccessControlUpgradeSafe is Initializable, ContextUpgradeSafe {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {


    }

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

    uint256[49] private __gap;
}
pragma solidity ^0.6.0;

contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {



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

    uint256[49] private __gap;
}


pragma solidity 0.6.10;



library StringUtils {

    using SafeMath for uint;

    function strConcat(string memory a, string memory b) internal pure returns (string memory) {

        bytes memory _ba = bytes(a);
        bytes memory _bb = bytes(b);

        string memory ab = new string(_ba.length.add(_bb.length));
        bytes memory strBytes = bytes(ab);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++) {
            strBytes[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            strBytes[k++] = _bb[i];
        }
        return string(strBytes);
    }

    function uint2str(uint i) internal pure returns (string memory) {

        if (i == 0) {
            return "0";
        }
        uint j = i;
        uint _i = i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len.sub(1);
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}// AGPL-3.0-only


pragma solidity 0.6.10;




contract ContractManager is OwnableUpgradeSafe {

    using StringUtils for string;
    using Address for address;

    mapping (bytes32 => address) public contracts;

    event ContractUpgraded(string contractsName, address contractsAddress);

    function initialize() external initializer {

        OwnableUpgradeSafe.__Ownable_init();
    }

    function setContractsAddress(string calldata contractsName, address newContractsAddress) external onlyOwner {

        require(newContractsAddress != address(0), "New address is equal zero");
        bytes32 contractId = keccak256(abi.encodePacked(contractsName));
        require(contracts[contractId] != newContractsAddress, "Contract is already added");
        require(newContractsAddress.isContract(), "Given contracts address does not contain code");
        contracts[contractId] = newContractsAddress;
        emit ContractUpgraded(contractsName, newContractsAddress);
    }

    function getContract(string calldata name) external view returns (address contractAddress) {

        contractAddress = contracts[keccak256(abi.encodePacked(name))];
        require(contractAddress != address(0), name.strConcat(" contract has not been found"));
    }
}


pragma solidity 0.6.10;




contract Permissions is AccessControlUpgradeSafe {

    using SafeMath for uint;
    using Address for address;
    
    ContractManager public contractManager;

    modifier onlyOwner() {

        require(_isOwner(), "Caller is not the owner");
        _;
    }

    modifier onlyAdmin() {

        require(_isAdmin(msg.sender), "Caller is not an admin");
        _;
    }

    modifier allow(string memory contractName) {

        require(
            contractManager.contracts(keccak256(abi.encodePacked(contractName))) == msg.sender || _isOwner(),
            "Message sender is invalid");
        _;
    }

    modifier allowTwo(string memory contractName1, string memory contractName2) {

        require(
            contractManager.contracts(keccak256(abi.encodePacked(contractName1))) == msg.sender ||
            contractManager.contracts(keccak256(abi.encodePacked(contractName2))) == msg.sender ||
            _isOwner(),
            "Message sender is invalid");
        _;
    }

    modifier allowThree(string memory contractName1, string memory contractName2, string memory contractName3) {

        require(
            contractManager.contracts(keccak256(abi.encodePacked(contractName1))) == msg.sender ||
            contractManager.contracts(keccak256(abi.encodePacked(contractName2))) == msg.sender ||
            contractManager.contracts(keccak256(abi.encodePacked(contractName3))) == msg.sender ||
            _isOwner(),
            "Message sender is invalid");
        _;
    }

    function initialize(address contractManagerAddress) public virtual initializer {

        AccessControlUpgradeSafe.__AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setContractManager(contractManagerAddress);
    }

    function _isOwner() internal view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _isAdmin(address account) internal view returns (bool) {

        address skaleManagerAddress = contractManager.contracts(keccak256(abi.encodePacked("SkaleManager")));
        if (skaleManagerAddress != address(0)) {
            AccessControlUpgradeSafe skaleManager = AccessControlUpgradeSafe(skaleManagerAddress);
            return skaleManager.hasRole(keccak256("ADMIN_ROLE"), account) || _isOwner();
        } else {
            return _isOwner();
        }
    }

    function _setContractManager(address contractManagerAddress) private {

        require(contractManagerAddress != address(0), "ContractManager address is not set");
        require(contractManagerAddress.isContract(), "Address is not contract");
        contractManager = ContractManager(contractManagerAddress);
    }
}


pragma solidity 0.6.10;



contract ConstantsHolder is Permissions {


    uint public constant NODE_DEPOSIT = 100 * 1e18;

    uint8 public constant TOTAL_SPACE_ON_NODE = 128;

    uint8 public constant SMALL_DIVISOR = 128;

    uint8 public constant MEDIUM_DIVISOR = 8;

    uint8 public constant LARGE_DIVISOR = 1;

    uint8 public constant MEDIUM_TEST_DIVISOR = 4;

    uint public constant NUMBER_OF_NODES_FOR_SCHAIN = 16;

    uint public constant NUMBER_OF_NODES_FOR_TEST_SCHAIN = 2;

    uint public constant NUMBER_OF_NODES_FOR_MEDIUM_TEST_SCHAIN = 4;    

    uint32 public constant SECONDS_TO_YEAR = 31622400;

    uint public constant NUMBER_OF_MONITORS = 24;

    uint public constant OPTIMAL_LOAD_PERCENTAGE = 80;

    uint public constant ADJUSTMENT_SPEED = 1000;

    uint public constant COOLDOWN_TIME = 60;

    uint public constant MIN_PRICE = 10**6;

    uint public constant MSR_REDUCING_COEFFICIENT = 2;

    uint public constant DOWNTIME_THRESHOLD_PART = 30;

    uint public constant BOUNTY_LOCKUP_MONTHS = 3;

    uint public msr;

    uint32 public rewardPeriod;

    uint32 public allowableLatency;

    uint32 public deltaPeriod;

    uint public checkTime;


    uint public launchTimestamp;

    uint public rotationDelay;

    uint public proofOfUseLockUpPeriodDays;

    uint public proofOfUseDelegationPercentage;

    uint public limitValidatorsPerDelegator;

    uint public firstDelegationsMonth;

    function setPeriods(uint32 newRewardPeriod, uint32 newDeltaPeriod) external onlyOwner {

        require(
            newRewardPeriod >= newDeltaPeriod && newRewardPeriod - newDeltaPeriod >= checkTime,
            "Incorrect Periods"
        );
        rewardPeriod = newRewardPeriod;
        deltaPeriod = newDeltaPeriod;
    }

    function setCheckTime(uint newCheckTime) external onlyOwner {

        require(rewardPeriod - deltaPeriod >= checkTime, "Incorrect check time");
        checkTime = newCheckTime;
    }    

    function setLatency(uint32 newAllowableLatency) external onlyOwner {

        allowableLatency = newAllowableLatency;
    }

    function setMSR(uint newMSR) external onlyOwner {

        msr = newMSR;
    }

    function setLaunchTimestamp(uint timestamp) external onlyOwner {

        require(now < launchTimestamp, "Can't set network launch timestamp because network is already launched");
        launchTimestamp = timestamp;
    }

    function setRotationDelay(uint newDelay) external onlyOwner {

        rotationDelay = newDelay;
    }

    function setProofOfUseLockUpPeriod(uint periodDays) external onlyOwner {

        proofOfUseLockUpPeriodDays = periodDays;
    }

    function setProofOfUseDelegationPercentage(uint percentage) external onlyOwner {

        require(percentage <= 100, "Percentage value is incorrect");
        proofOfUseDelegationPercentage = percentage;
    }

    function setLimitValidatorsPerDelegator(uint newLimit) external onlyOwner {

        limitValidatorsPerDelegator = newLimit;
    }

    function setFirstDelegationsMonth(uint month) external onlyOwner {

        firstDelegationsMonth = month;
    }

    function initialize(address contractsAddress) public override initializer {

        Permissions.initialize(contractsAddress);

        msr = 0;
        rewardPeriod = 2592000;
        allowableLatency = 150000;
        deltaPeriod = 3600;
        checkTime = 300;
        launchTimestamp = uint(-1);
        rotationDelay = 12 hours;
        proofOfUseLockUpPeriodDays = 90;
        proofOfUseDelegationPercentage = 50;
        limitValidatorsPerDelegator = 20;
        firstDelegationsMonth = 8;
    }
}


pragma solidity 0.6.10;


library MathUtils {

    event UnderflowError(
        uint a,
        uint b
    );

    uint constant private _EPS = 1e6;

    function boundedSub(uint256 a, uint256 b) internal returns (uint256) {

        if (a >= b) {
            return a - b;
        } else {
            emit UnderflowError(a, b);
            return 0;
        }
    }

    function boundedSubWithoutEvent(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a >= b) {
            return a - b;
        } else {
            return 0;
        }
    }

    function muchGreater(uint256 a, uint256 b) internal pure returns (bool) {

        assert(uint(-1) - _EPS > b);
        return a > b + _EPS;
    }

    function approximatelyEqual(uint256 a, uint256 b) internal pure returns (bool) {

        if (a > b) {
            return a - b < _EPS;
        } else {
            return b - a < _EPS;
        }
    }
}pragma solidity ^0.6.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
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
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}
pragma solidity ^0.6.0;

interface IERC777 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function granularity() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function send(address recipient, uint256 amount, bytes calldata data) external;


    function burn(uint256 amount, bytes calldata data) external;


    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);


    function authorizeOperator(address operator) external;


    function revokeOperator(address operator) external;


    function defaultOperators() external view returns (address[] memory);


    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}
pragma solidity ^0.6.0;


library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}


pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;




contract Nodes is Permissions {

    
    using SafeCast for uint;

    enum NodeStatus {Active, Leaving, Left, In_Maintenance}

    struct Node {
        string name;
        bytes4 ip;
        bytes4 publicIP;
        uint16 port;
        bytes32[2] publicKey;
        uint startBlock;
        uint lastRewardDate;
        uint finishTime;
        NodeStatus status;
        uint validatorId;
    }

    struct CreatedNodes {
        mapping (uint => bool) isNodeExist;
        uint numberOfNodes;
    }

    struct SpaceManaging {
        uint8 freeSpace;
        uint indexInSpaceMap;
    }

    struct NodeCreationParams {
        string name;
        bytes4 ip;
        bytes4 publicIp;
        uint16 port;
        bytes32[2] publicKey;
        uint16 nonce;
    }

    Node[] public nodes;

    SpaceManaging[] public spaceOfNodes;

    mapping (address => CreatedNodes) public nodeIndexes;
    mapping (bytes4 => bool) public nodesIPCheck;
    mapping (bytes32 => bool) public nodesNameCheck;
    mapping (bytes32 => uint) public nodesNameToIndex;
    mapping (uint8 => uint[]) public spaceToNodes;

    mapping (uint => uint[]) public validatorToNodeIndexes;

    uint public numberOfActiveNodes;
    uint public numberOfLeavingNodes;
    uint public numberOfLeftNodes;

    event NodeCreated(
        uint nodeIndex,
        address owner,
        string name,
        bytes4 ip,
        bytes4 publicIP,
        uint16 port,
        uint16 nonce,
        uint time,
        uint gasSpend
    );

    event ExitCompleted(
        uint nodeIndex,
        uint time,
        uint gasSpend
    );

    event ExitInited(
        uint nodeIndex,
        uint startLeavingPeriod,
        uint time,
        uint gasSpend
    );

    modifier checkNodeExists(uint nodeIndex) {

        require(nodeIndex < nodes.length, "Node with such index does not exist");
        _;
    }

    function removeSpaceFromNode(uint nodeIndex, uint8 space)
        external
        checkNodeExists(nodeIndex)
        allowTwo("NodeRotation", "SchainsInternal")
        returns (bool)
    {

        if (spaceOfNodes[nodeIndex].freeSpace < space) {
            return false;
        }
        if (space > 0) {
            _moveNodeToNewSpaceMap(
                nodeIndex,
                uint(spaceOfNodes[nodeIndex].freeSpace).sub(space).toUint8()
            );
        }
        return true;
    }

    function addSpaceToNode(uint nodeIndex, uint8 space)
        external
        checkNodeExists(nodeIndex)
        allow("Schains")
    {

        if (space > 0) {
            _moveNodeToNewSpaceMap(
                nodeIndex,
                uint(spaceOfNodes[nodeIndex].freeSpace).add(space).toUint8()
            );
        }
    }

    function changeNodeLastRewardDate(uint nodeIndex)
        external
        checkNodeExists(nodeIndex)
        allow("SkaleManager")
    {

        nodes[nodeIndex].lastRewardDate = block.timestamp;
    }

    function changeNodeFinishTime(uint nodeIndex, uint time)
        external
        checkNodeExists(nodeIndex)
        allow("SkaleManager")
    {

        nodes[nodeIndex].finishTime = time;
    }

    function createNode(address from, NodeCreationParams calldata params)
        external
        allow("SkaleManager")
    {

        require(params.ip != 0x0 && !nodesIPCheck[params.ip], "IP address is zero or is not available");
        require(!nodesNameCheck[keccak256(abi.encodePacked(params.name))], "Name has already registered");
        require(params.port > 0, "Port is zero");

        uint validatorId = ValidatorService(
            contractManager.getContract("ValidatorService")).getValidatorIdByNodeAddress(from);

        uint nodeIndex = _addNode(
            from,
            params.name,
            params.ip,
            params.publicIp,
            params.port,
            params.publicKey,
            validatorId);

        emit NodeCreated(
            nodeIndex,
            from,
            params.name,
            params.ip,
            params.publicIp,
            params.port,
            params.nonce,
            block.timestamp,
            gasleft());
    }

    function initExit(uint nodeIndex)
        external
        checkNodeExists(nodeIndex)
        allow("SkaleManager")
        returns (bool)
    {

        _setNodeLeaving(nodeIndex);

        emit ExitInited(
            nodeIndex,
            block.timestamp,
            block.timestamp,
            gasleft());
        return true;
    }

    function completeExit(uint nodeIndex)
        external
        checkNodeExists(nodeIndex)
        allow("SkaleManager")
        returns (bool)
    {

        require(isNodeLeaving(nodeIndex), "Node is not Leaving");

        _setNodeLeft(nodeIndex);
        _deleteNode(nodeIndex);

        emit ExitCompleted(
            nodeIndex,
            block.timestamp,
            gasleft());
        return true;
    }

    function deleteNodeForValidator(uint validatorId, uint nodeIndex)
        external
        checkNodeExists(nodeIndex)
        allow("SkaleManager")
    {

        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        require(validatorService.validatorExists(validatorId), "Validator with such ID does not exist");
        uint[] memory validatorNodes = validatorToNodeIndexes[validatorId];
        uint position = _findNode(validatorNodes, nodeIndex);
        if (position < validatorNodes.length) {
            validatorToNodeIndexes[validatorId][position] =
                validatorToNodeIndexes[validatorId][validatorNodes.length.sub(1)];
        }
        validatorToNodeIndexes[validatorId].pop();
    }

    function checkPossibilityCreatingNode(address nodeAddress) external allow("SkaleManager") {

        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController")
        );
        uint validatorId = validatorService.getValidatorIdByNodeAddress(nodeAddress);
        require(validatorService.isAuthorizedValidator(validatorId), "Validator is not authorized to create a node");
        uint[] memory validatorNodes = validatorToNodeIndexes[validatorId];
        uint delegationsTotal = delegationController.getAndUpdateDelegatedToValidatorNow(validatorId);
        uint msr = ConstantsHolder(contractManager.getContract("ConstantsHolder")).msr();
        require(
            validatorNodes.length.add(1).mul(msr) <= delegationsTotal,
            "Validator must meet the Minimum Staking Requirement");
    }

    function checkPossibilityToMaintainNode(
        uint validatorId,
        uint nodeIndex
    )
        external
        checkNodeExists(nodeIndex)
        allow("Bounty")
        returns (bool)
    {

        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController")
        );
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        require(validatorService.validatorExists(validatorId), "Validator with such ID does not exist");
        uint[] memory validatorNodes = validatorToNodeIndexes[validatorId];
        uint position = _findNode(validatorNodes, nodeIndex);
        require(position < validatorNodes.length, "Node does not exist for this Validator");
        uint delegationsTotal = delegationController.getAndUpdateDelegatedToValidatorNow(validatorId);
        uint msr = ConstantsHolder(contractManager.getContract("ConstantsHolder")).msr();
        return position.add(1).mul(msr) <= delegationsTotal;
    }

    function setNodeInMaintenance(uint nodeIndex) external {

        require(nodes[nodeIndex].status == NodeStatus.Active, "Node is not Active");
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        uint validatorId = getValidatorId(nodeIndex);
        bool permitted = (_isOwner() || isNodeExist(msg.sender, nodeIndex));
        if (!permitted) {
            permitted = validatorService.getValidatorId(msg.sender) == validatorId;
        }
        require(permitted, "Sender is not permitted to call this function");
        nodes[nodeIndex].status = NodeStatus.In_Maintenance;
    }

    function removeNodeFromInMaintenance(uint nodeIndex) external {

        require(nodes[nodeIndex].status == NodeStatus.In_Maintenance, "Node is not In Maintence");
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        uint validatorId = getValidatorId(nodeIndex);
        bool permitted = (_isOwner() || isNodeExist(msg.sender, nodeIndex));
        if (!permitted) {
            permitted = validatorService.getValidatorId(msg.sender) == validatorId;
        }
        require(permitted, "Sender is not permitted to call this function");
        nodes[nodeIndex].status = NodeStatus.Active;
    }

    function getNodesWithFreeSpace(uint8 freeSpace) external view returns (uint[] memory) {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        uint[] memory nodesWithFreeSpace = new uint[](countNodesWithFreeSpace(freeSpace));
        uint cursor = 0;
        uint totalSpace = constantsHolder.TOTAL_SPACE_ON_NODE();
        for (uint8 i = freeSpace; i <= totalSpace; ++i) {
            for (uint j = 0; j < spaceToNodes[i].length; j++) {
                nodesWithFreeSpace[cursor] = spaceToNodes[i][j];
                ++cursor;
            }
        }
        return nodesWithFreeSpace;
    }

    function isTimeForReward(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (bool)
    {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        return uint(nodes[nodeIndex].lastRewardDate).add(constantsHolder.rewardPeriod()) <= block.timestamp;
    }

    function getNodeIP(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (bytes4)
    {

        require(nodeIndex < nodes.length, "Node does not exist");
        return nodes[nodeIndex].ip;
    }

    function getNodePort(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (uint16)
    {

        return nodes[nodeIndex].port;
    }

    function getNodePublicKey(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (bytes32[2] memory)
    {

        return nodes[nodeIndex].publicKey;
    }

    function getNodeFinishTime(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (uint)
    {

        return nodes[nodeIndex].finishTime;
    }

    function isNodeLeft(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (bool)
    {

        return nodes[nodeIndex].status == NodeStatus.Left;
    }

    function isNodeInMaintenance(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (bool)
    {

        return nodes[nodeIndex].status == NodeStatus.In_Maintenance;
    }

    function getNodeLastRewardDate(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (uint)
    {

        return nodes[nodeIndex].lastRewardDate;
    }

    function getNodeNextRewardDate(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (uint)
    {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        return nodes[nodeIndex].lastRewardDate.add(constantsHolder.rewardPeriod());
    }

    function getNumberOfNodes() external view returns (uint) {

        return nodes.length;
    }

    function getNumberOnlineNodes() external view returns (uint) {

        return numberOfActiveNodes.add(numberOfLeavingNodes);
    }

    function getActiveNodeIPs() external view returns (bytes4[] memory activeNodeIPs) {

        activeNodeIPs = new bytes4[](numberOfActiveNodes);
        uint indexOfActiveNodeIPs = 0;
        for (uint indexOfNodes = 0; indexOfNodes < nodes.length; indexOfNodes++) {
            if (isNodeActive(indexOfNodes)) {
                activeNodeIPs[indexOfActiveNodeIPs] = nodes[indexOfNodes].ip;
                indexOfActiveNodeIPs++;
            }
        }
    }

    function getActiveNodesByAddress() external view returns (uint[] memory activeNodesByAddress) {

        activeNodesByAddress = new uint[](nodeIndexes[msg.sender].numberOfNodes);
        uint indexOfActiveNodesByAddress = 0;
        for (uint indexOfNodes = 0; indexOfNodes < nodes.length; indexOfNodes++) {
            if (nodeIndexes[msg.sender].isNodeExist[indexOfNodes] && isNodeActive(indexOfNodes)) {
                activeNodesByAddress[indexOfActiveNodesByAddress] = indexOfNodes;
                indexOfActiveNodesByAddress++;
            }
        }
    }

    function getActiveNodeIds() external view returns (uint[] memory activeNodeIds) {

        activeNodeIds = new uint[](numberOfActiveNodes);
        uint indexOfActiveNodeIds = 0;
        for (uint indexOfNodes = 0; indexOfNodes < nodes.length; indexOfNodes++) {
            if (isNodeActive(indexOfNodes)) {
                activeNodeIds[indexOfActiveNodeIds] = indexOfNodes;
                indexOfActiveNodeIds++;
            }
        }
    }

    function getNodeStatus(uint nodeIndex)
        external
        view
        checkNodeExists(nodeIndex)
        returns (NodeStatus)
    {

        return nodes[nodeIndex].status;
    }

    function getValidatorNodeIndexes(uint validatorId) external view returns (uint[] memory) {

        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        require(validatorService.validatorExists(validatorId), "Validator with such ID does not exist");
        return validatorToNodeIndexes[validatorId];
    }

    function initialize(address contractsAddress) public override initializer {

        Permissions.initialize(contractsAddress);

        numberOfActiveNodes = 0;
        numberOfLeavingNodes = 0;
        numberOfLeftNodes = 0;
    }

    function getValidatorId(uint nodeIndex)
        public
        view
        checkNodeExists(nodeIndex)
        returns (uint)
    {

        return nodes[nodeIndex].validatorId;
    }

    function isNodeExist(address from, uint nodeIndex)
        public
        view
        checkNodeExists(nodeIndex)
        returns (bool)
    {

        return nodeIndexes[from].isNodeExist[nodeIndex];
    }

    function isNodeActive(uint nodeIndex)
        public
        view
        checkNodeExists(nodeIndex)
        returns (bool)
    {

        return nodes[nodeIndex].status == NodeStatus.Active;
    }

    function isNodeLeaving(uint nodeIndex)
        public
        view
        checkNodeExists(nodeIndex)
        returns (bool)
    {

        return nodes[nodeIndex].status == NodeStatus.Leaving;
    }

    function countNodesWithFreeSpace(uint8 freeSpace) public view returns (uint count) {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        count = 0;
        uint totalSpace = constantsHolder.TOTAL_SPACE_ON_NODE();
        for (uint8 i = freeSpace; i <= totalSpace; ++i) {
            count = count.add(spaceToNodes[i].length);
        }
    }

    function _findNode(uint[] memory validatorNodeIndexes, uint nodeIndex) private pure returns (uint) {

        uint i;
        for (i = 0; i < validatorNodeIndexes.length; i++) {
            if (validatorNodeIndexes[i] == nodeIndex) {
                return i;
            }
        }
        return validatorNodeIndexes.length;
    }

    function _moveNodeToNewSpaceMap(uint nodeIndex, uint8 newSpace) private {

        uint8 previousSpace = spaceOfNodes[nodeIndex].freeSpace;
        uint indexInArray = spaceOfNodes[nodeIndex].indexInSpaceMap;
        if (indexInArray < spaceToNodes[previousSpace].length.sub(1)) {
            uint shiftedIndex = spaceToNodes[previousSpace][spaceToNodes[previousSpace].length.sub(1)];
            spaceToNodes[previousSpace][indexInArray] = shiftedIndex;
            spaceOfNodes[shiftedIndex].indexInSpaceMap = indexInArray;
            spaceToNodes[previousSpace].pop();
        } else {
            spaceToNodes[previousSpace].pop();
        }
        spaceToNodes[newSpace].push(nodeIndex);
        spaceOfNodes[nodeIndex].freeSpace = newSpace;
        spaceOfNodes[nodeIndex].indexInSpaceMap = spaceToNodes[newSpace].length.sub(1);
    }

    function _setNodeLeft(uint nodeIndex) private {

        nodesIPCheck[nodes[nodeIndex].ip] = false;
        nodesNameCheck[keccak256(abi.encodePacked(nodes[nodeIndex].name))] = false;
        delete nodesNameToIndex[keccak256(abi.encodePacked(nodes[nodeIndex].name))];
        if (nodes[nodeIndex].status == NodeStatus.Active) {
            numberOfActiveNodes--;
        } else {
            numberOfLeavingNodes--;
        }
        nodes[nodeIndex].status = NodeStatus.Left;
        numberOfLeftNodes++;
    }

    function _setNodeLeaving(uint nodeIndex) private {

        nodes[nodeIndex].status = NodeStatus.Leaving;
        numberOfActiveNodes--;
        numberOfLeavingNodes++;
    }

    function _addNode(
        address from,
        string memory name,
        bytes4 ip,
        bytes4 publicIP,
        uint16 port,
        bytes32[2] memory publicKey,
        uint validatorId
    )
        private
        returns (uint nodeIndex)
    {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        nodes.push(Node({
            name: name,
            ip: ip,
            publicIP: publicIP,
            port: port,
            publicKey: publicKey,
            startBlock: block.number,
            lastRewardDate: block.timestamp,
            finishTime: 0,
            status: NodeStatus.Active,
            validatorId: validatorId
        }));
        nodeIndex = nodes.length.sub(1);
        validatorToNodeIndexes[validatorId].push(nodeIndex);
        bytes32 nodeId = keccak256(abi.encodePacked(name));
        nodesIPCheck[ip] = true;
        nodesNameCheck[nodeId] = true;
        nodesNameToIndex[nodeId] = nodeIndex;
        nodeIndexes[from].isNodeExist[nodeIndex] = true;
        nodeIndexes[from].numberOfNodes++;
        spaceOfNodes.push(SpaceManaging({
            freeSpace: constantsHolder.TOTAL_SPACE_ON_NODE(),
            indexInSpaceMap: spaceToNodes[constantsHolder.TOTAL_SPACE_ON_NODE()].length
        }));
        spaceToNodes[constantsHolder.TOTAL_SPACE_ON_NODE()].push(nodeIndex);
        numberOfActiveNodes++;
    }

    function _deleteNode(uint nodeIndex) private {

        uint8 space = spaceOfNodes[nodeIndex].freeSpace;
        uint indexInArray = spaceOfNodes[nodeIndex].indexInSpaceMap;
        if (indexInArray < spaceToNodes[space].length.sub(1)) {
            uint shiftedIndex = spaceToNodes[space][spaceToNodes[space].length.sub(1)];
            spaceToNodes[space][indexInArray] = shiftedIndex;
            spaceOfNodes[shiftedIndex].indexInSpaceMap = indexInArray;
            spaceToNodes[space].pop();
        } else {
            spaceToNodes[space].pop();
        }
        delete spaceOfNodes[nodeIndex].freeSpace;
        delete spaceOfNodes[nodeIndex].indexInSpaceMap;
    }

}


pragma solidity 0.6.10;



library FractionUtils {

    using SafeMath for uint;

    struct Fraction {
        uint numerator;
        uint denominator;
    }

    function createFraction(uint numerator, uint denominator) internal pure returns (Fraction memory) {

        require(denominator > 0, "Division by zero");
        Fraction memory fraction = Fraction({numerator: numerator, denominator: denominator});
        reduceFraction(fraction);
        return fraction;
    }

    function createFraction(uint value) internal pure returns (Fraction memory) {

        return createFraction(value, 1);
    }

    function reduceFraction(Fraction memory fraction) internal pure {

        uint _gcd = gcd(fraction.numerator, fraction.denominator);
        fraction.numerator = fraction.numerator.div(_gcd);
        fraction.denominator = fraction.denominator.div(_gcd);
    }

    function multiplyFraction(Fraction memory a, Fraction memory b) internal pure returns (Fraction memory) {

        return createFraction(a.numerator.mul(b.numerator), a.denominator.mul(b.denominator));
    }

    function gcd(uint a, uint b) internal pure returns (uint) {

        uint _a = a;
        uint _b = b;
        if (_b > _a) {
            (_a, _b) = swap(_a, _b);
        }
        while (_b > 0) {
            _a = _a.mod(_b);
            (_a, _b) = swap (_a, _b);
        }
        return _a;
    }

    function swap(uint a, uint b) internal pure returns (uint, uint) {

        return (b, a);
    }
}// AGPL-3.0-only


pragma solidity 0.6.10;


contract DelegationPeriodManager is Permissions {


    event DelegationPeriodWasSet(
        uint length,
        uint stakeMultiplier
    );

    mapping (uint => uint) public stakeMultipliers;

    function setDelegationPeriod(uint monthsCount, uint stakeMultiplier) external onlyOwner {

        stakeMultipliers[monthsCount] = stakeMultiplier;

        emit DelegationPeriodWasSet(monthsCount, stakeMultiplier);
    }

    function isDelegationPeriodAllowed(uint monthsCount) external view returns (bool) {

        return stakeMultipliers[monthsCount] != 0 ? true : false;
    }

    function initialize(address contractsAddress) public override initializer {

        Permissions.initialize(contractsAddress);
        stakeMultipliers[3] = 100;  // 3 months at 100
    }
}// AGPL-3.0-only


pragma solidity 0.6.10;

interface ILocker {

    function getAndUpdateLockedAmount(address wallet) external returns (uint);


    function getAndUpdateForbiddenForDelegationAmount(address wallet) external returns (uint);

}


pragma solidity 0.6.10;



contract Punisher is Permissions, ILocker {


    event Slash(
        uint validatorId,
        uint amount
    );

    event Forgive(
        address wallet,
        uint amount
    );

    mapping (address => uint) private _locked;

    function slash(uint validatorId, uint amount) external allow("SkaleDKG") {

        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController"));

        require(validatorService.validatorExists(validatorId), "Validator does not exist");

        delegationController.confiscate(validatorId, amount);

        emit Slash(validatorId, amount);
    }

    function forgive(address holder, uint amount) external onlyAdmin {

        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController"));

        require(!delegationController.hasUnprocessedSlashes(holder), "Not all slashes were calculated");

        if (amount > _locked[holder]) {
            delete _locked[holder];
        } else {
            _locked[holder] = _locked[holder].sub(amount);
        }

        emit Forgive(holder, amount);
    }

    function getAndUpdateLockedAmount(address wallet) external override returns (uint) {

        return _getAndUpdateLockedAmount(wallet);
    }

    function getAndUpdateForbiddenForDelegationAmount(address wallet) external override returns (uint) {

        return _getAndUpdateLockedAmount(wallet);
    }

    function handleSlash(address holder, uint amount) external allow("DelegationController") {

        _locked[holder] = _locked[holder].add(amount);
    }

    function initialize(address contractManagerAddress) public override initializer {

        Permissions.initialize(contractManagerAddress);
    }


    function _getAndUpdateLockedAmount(address wallet) private returns (uint) {

        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController"));

        delegationController.processAllSlashes(wallet);
        return _locked[wallet];
    }

}pragma solidity ^0.6.0;


library BokkyPooBahsDateTimeLibrary {


    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {

        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {

        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {

        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {

        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {

        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {

        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {

        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {

        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {

        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {

        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {

        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {

        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {

        uint year;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {

        uint year;
        uint month;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {

        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {

        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {

        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {

        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {

        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {

        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {

        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {

        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {

        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {

        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {

        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {

        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {

        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}


pragma solidity 0.6.10;



contract TimeHelpers {

    using SafeMath for uint;

    uint constant private _ZERO_YEAR = 2020;
    
    uint constant private _FICTIOUS_MONTH_START = 1599523200;
    uint constant private _FICTIOUS_MONTH_NUMBER = 9;

    function calculateProofOfUseLockEndTime(uint month, uint lockUpPeriodDays) external view returns (uint timestamp) {

        timestamp = BokkyPooBahsDateTimeLibrary.addDays(monthToTimestamp(month), lockUpPeriodDays);
    }

    function addDays(uint fromTimestamp, uint n) external pure returns (uint) {

        return BokkyPooBahsDateTimeLibrary.addDays(fromTimestamp, n);
    }

    function addMonths(uint fromTimestamp, uint n) external pure returns (uint) {

        return BokkyPooBahsDateTimeLibrary.addMonths(fromTimestamp, n);
    }

    function addYears(uint fromTimestamp, uint n) external pure returns (uint) {

        return BokkyPooBahsDateTimeLibrary.addYears(fromTimestamp, n);
    }

    function getCurrentMonth() external view virtual returns (uint) {

        return timestampToMonth(now);
    }

    function timestampToDay(uint timestamp) external view returns (uint) {

        uint wholeDays = timestamp / BokkyPooBahsDateTimeLibrary.SECONDS_PER_DAY;
        uint zeroDay = BokkyPooBahsDateTimeLibrary.timestampFromDate(_ZERO_YEAR, 1, 1) /
            BokkyPooBahsDateTimeLibrary.SECONDS_PER_DAY;
        require(wholeDays >= zeroDay, "Timestamp is too far in the past");
        return wholeDays - zeroDay;
    }

    function timestampToYear(uint timestamp) external view virtual returns (uint) {

        uint year;
        (year, , ) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
        require(year >= _ZERO_YEAR, "Timestamp is too far in the past");
        return year - _ZERO_YEAR;
    }

    function timestampToMonth(uint timestamp) public view virtual returns (uint) {

        uint year;
        uint month;
        (year, month, ) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
        require(year >= _ZERO_YEAR, "Timestamp is too far in the past");
        month = month.sub(1).add(year.sub(_ZERO_YEAR).mul(12));
        require(month > 0, "Timestamp is too far in the past");
        if (timestamp >= _FICTIOUS_MONTH_START) {
            month = month.add(1);
        }
        return month;
    }

    function monthToTimestamp(uint month) public view virtual returns (uint timestamp) {

        uint year = _ZERO_YEAR;
        uint _month = month;
        if (_month > _FICTIOUS_MONTH_NUMBER) {
            _month = _month.sub(1);
        } else if (_month == _FICTIOUS_MONTH_NUMBER) {
            return _FICTIOUS_MONTH_START;
        }
        year = year.add(_month.div(12));
        _month = _month.mod(12);
        _month = _month.add(1);
        return BokkyPooBahsDateTimeLibrary.timestampFromDate(year, _month, 1);
    }
}


pragma solidity 0.6.10;


library PartialDifferences {

    using SafeMath for uint;
    using MathUtils for uint;

    struct Sequence {
        mapping (uint => uint) addDiff;
        mapping (uint => uint) subtractDiff;
        mapping (uint => uint) value;

        uint firstUnprocessedMonth;
        uint lastChangedMonth;
    }

    struct Value {
        mapping (uint => uint) addDiff;
        mapping (uint => uint) subtractDiff;

        uint value;
        uint firstUnprocessedMonth;
        uint lastChangedMonth;
    }


    function addToSequence(Sequence storage sequence, uint diff, uint month) internal {

        require(sequence.firstUnprocessedMonth <= month, "Cannot add to the past");
        if (sequence.firstUnprocessedMonth == 0) {
            sequence.firstUnprocessedMonth = month;
        }
        sequence.addDiff[month] = sequence.addDiff[month].add(diff);
        if (sequence.lastChangedMonth != month) {
            sequence.lastChangedMonth = month;
        }
    }

    function subtractFromSequence(Sequence storage sequence, uint diff, uint month) internal {

        require(sequence.firstUnprocessedMonth <= month, "Cannot subtract from the past");
        if (sequence.firstUnprocessedMonth == 0) {
            sequence.firstUnprocessedMonth = month;
        }
        sequence.subtractDiff[month] = sequence.subtractDiff[month].add(diff);
        if (sequence.lastChangedMonth != month) {
            sequence.lastChangedMonth = month;
        }
    }

    function getAndUpdateValueInSequence(Sequence storage sequence, uint month) internal returns (uint) {

        if (sequence.firstUnprocessedMonth == 0) {
            return 0;
        }

        if (sequence.firstUnprocessedMonth <= month) {
            for (uint i = sequence.firstUnprocessedMonth; i <= month; ++i) {
                uint nextValue = sequence.value[i.sub(1)].add(sequence.addDiff[i]).boundedSub(sequence.subtractDiff[i]);
                if (sequence.value[i] != nextValue) {
                    sequence.value[i] = nextValue;
                }
                if (sequence.addDiff[i] > 0) {
                    delete sequence.addDiff[i];
                }
                if (sequence.subtractDiff[i] > 0) {
                    delete sequence.subtractDiff[i];
                }
            }
            sequence.firstUnprocessedMonth = month.add(1);
        }

        return sequence.value[month];
    }

    function reduceSequence(
        Sequence storage sequence,
        FractionUtils.Fraction memory reducingCoefficient,
        uint month) internal
    {

        require(month.add(1) >= sequence.firstUnprocessedMonth, "Can't reduce value in the past");
        require(
            reducingCoefficient.numerator <= reducingCoefficient.denominator,
            "Increasing of values is not implemented");
        if (sequence.firstUnprocessedMonth == 0) {
            return;
        }
        uint value = getAndUpdateValueInSequence(sequence, month);
        if (value.approximatelyEqual(0)) {
            return;
        }

        sequence.value[month] = sequence.value[month]
            .mul(reducingCoefficient.numerator)
            .div(reducingCoefficient.denominator);

        for (uint i = month.add(1); i <= sequence.lastChangedMonth; ++i) {
            sequence.subtractDiff[i] = sequence.subtractDiff[i]
                .mul(reducingCoefficient.numerator)
                .div(reducingCoefficient.denominator);
        }
    }


    function addToValue(Value storage sequence, uint diff, uint month) internal {

        require(sequence.firstUnprocessedMonth <= month, "Cannot add to the past");
        if (sequence.firstUnprocessedMonth == 0) {
            sequence.firstUnprocessedMonth = month;
            sequence.lastChangedMonth = month;
        }
        if (month > sequence.lastChangedMonth) {
            sequence.lastChangedMonth = month;
        }

        if (month >= sequence.firstUnprocessedMonth) {
            sequence.addDiff[month] = sequence.addDiff[month].add(diff);
        } else {
            sequence.value = sequence.value.add(diff);
        }
    }

    function subtractFromValue(Value storage sequence, uint diff, uint month) internal {

        require(sequence.firstUnprocessedMonth <= month.add(1), "Cannot subtract from the past");
        if (sequence.firstUnprocessedMonth == 0) {
            sequence.firstUnprocessedMonth = month;
            sequence.lastChangedMonth = month;
        }
        if (month > sequence.lastChangedMonth) {
            sequence.lastChangedMonth = month;
        }

        if (month >= sequence.firstUnprocessedMonth) {
            sequence.subtractDiff[month] = sequence.subtractDiff[month].add(diff);
        } else {
            sequence.value = sequence.value.boundedSub(diff);
        }
    }

    function getAndUpdateValue(Value storage sequence, uint month) internal returns (uint) {

        require(
            month.add(1) >= sequence.firstUnprocessedMonth,
            "Cannot calculate value in the past");
        if (sequence.firstUnprocessedMonth == 0) {
            return 0;
        }

        if (sequence.firstUnprocessedMonth <= month) {
            for (uint i = sequence.firstUnprocessedMonth; i <= month; ++i) {
                uint newValue = sequence.value.add(sequence.addDiff[i]).boundedSub(sequence.subtractDiff[i]);
                if (sequence.value != newValue) {
                    sequence.value = newValue;
                }
                if (sequence.addDiff[i] > 0) {
                    delete sequence.addDiff[i];
                }
                if (sequence.subtractDiff[i] > 0) {
                    delete sequence.subtractDiff[i];
                }
            }
            sequence.firstUnprocessedMonth = month.add(1);
        }

        return sequence.value;
    }

    function reduceValue(
        Value storage sequence,
        uint amount,
        uint month)
        internal returns (FractionUtils.Fraction memory)
    {

        require(month.add(1) >= sequence.firstUnprocessedMonth, "Cannot reduce value in the past");
        if (sequence.firstUnprocessedMonth == 0) {
            return FractionUtils.createFraction(0);
        }
        uint value = getAndUpdateValue(sequence, month);
        if (value.approximatelyEqual(0)) {
            return FractionUtils.createFraction(0);
        }

        uint _amount = amount;
        if (value < amount) {
            _amount = value;
        }

        FractionUtils.Fraction memory reducingCoefficient =
            FractionUtils.createFraction(value.boundedSub(_amount), value);
        reduceValueByCoefficient(sequence, reducingCoefficient, month);
        return reducingCoefficient;
    }

    function reduceValueByCoefficient(
        Value storage sequence,
        FractionUtils.Fraction memory reducingCoefficient,
        uint month)
        internal
    {

        reduceValueByCoefficientAndUpdateSumIfNeeded(
            sequence,
            sequence,
            reducingCoefficient,
            month,
            false);
    }

    function reduceValueByCoefficientAndUpdateSum(
        Value storage sequence,
        Value storage sumSequence,
        FractionUtils.Fraction memory reducingCoefficient,
        uint month) internal
    {

        reduceValueByCoefficientAndUpdateSumIfNeeded(
            sequence,
            sumSequence,
            reducingCoefficient,
            month,
            true);
    }

    function reduceValueByCoefficientAndUpdateSumIfNeeded(
        Value storage sequence,
        Value storage sumSequence,
        FractionUtils.Fraction memory reducingCoefficient,
        uint month,
        bool hasSumSequence) internal
    {

        require(month.add(1) >= sequence.firstUnprocessedMonth, "Cannot reduce value in the past");
        if (hasSumSequence) {
            require(month.add(1) >= sumSequence.firstUnprocessedMonth, "Cannot reduce value in the past");
        }
        require(
            reducingCoefficient.numerator <= reducingCoefficient.denominator,
            "Increasing of values is not implemented");
        if (sequence.firstUnprocessedMonth == 0) {
            return;
        }
        uint value = getAndUpdateValue(sequence, month);
        if (value.approximatelyEqual(0)) {
            return;
        }

        uint newValue = sequence.value.mul(reducingCoefficient.numerator).div(reducingCoefficient.denominator);
        if (hasSumSequence) {
            subtractFromValue(sumSequence, sequence.value.boundedSub(newValue), month);
        }
        sequence.value = newValue;

        for (uint i = month.add(1); i <= sequence.lastChangedMonth; ++i) {
            uint newDiff = sequence.subtractDiff[i]
                .mul(reducingCoefficient.numerator)
                .div(reducingCoefficient.denominator);
            if (hasSumSequence) {
                sumSequence.subtractDiff[i] = sumSequence.subtractDiff[i]
                    .boundedSub(sequence.subtractDiff[i].boundedSub(newDiff));
            }
            sequence.subtractDiff[i] = newDiff;
        }
    }

    function clear(Value storage sequence) internal {

        for (uint i = sequence.firstUnprocessedMonth; i <= sequence.lastChangedMonth; ++i) {
            if (sequence.addDiff[i] > 0) {
                delete sequence.addDiff[i];
            }
            if (sequence.subtractDiff[i] > 0) {
                delete sequence.subtractDiff[i];
            }
        }
        if (sequence.value > 0) {
            delete sequence.value;
        }
        if (sequence.firstUnprocessedMonth > 0) {
            delete sequence.firstUnprocessedMonth;
        }
        if (sequence.lastChangedMonth > 0) {
            delete sequence.lastChangedMonth;
        }
    }
}// AGPL-3.0-only


pragma solidity 0.6.10;




contract TokenLaunchLocker is Permissions, ILocker {

    using MathUtils for uint;
    using PartialDifferences for PartialDifferences.Value;

    event Unlocked(
        address holder,
        uint amount
    );

    event Locked(
        address holder,
        uint amount
    );

    struct DelegatedAmountAndMonth {
        uint delegated;
        uint month;
    }

    mapping (address => uint) private _locked;

    mapping (address => PartialDifferences.Value) private _delegatedAmount;

    mapping (address => DelegatedAmountAndMonth) private _totalDelegatedAmount;

    mapping (uint => uint) private _delegationAmount;

    function lock(address holder, uint amount) external allow("TokenLaunchManager") {

        _locked[holder] = _locked[holder].add(amount);

        emit Locked(holder, amount);
    }

    function handleDelegationAdd(
        address holder, uint delegationId, uint amount, uint month)
        external allow("DelegationController")
    {

        if (_locked[holder] > 0) {
            TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));

            uint currentMonth = timeHelpers.getCurrentMonth();
            uint fromLocked = amount;
            uint locked = _locked[holder].boundedSub(_getAndUpdateDelegatedAmount(holder, currentMonth));
            if (fromLocked > locked) {
                fromLocked = locked;
            }
            if (fromLocked > 0) {
                require(_delegationAmount[delegationId] == 0, "Delegation was already added");
                _addToDelegatedAmount(holder, fromLocked, month);
                _addToTotalDelegatedAmount(holder, fromLocked, month);
                _delegationAmount[delegationId] = fromLocked;
            }
        }
    }

    function handleDelegationRemoving(
        address holder,
        uint delegationId,
        uint month)
        external allow("DelegationController")
    {

        if (_delegationAmount[delegationId] > 0) {
            if (_locked[holder] > 0) {
                _removeFromDelegatedAmount(holder, _delegationAmount[delegationId], month);
            }
            delete _delegationAmount[delegationId];
        }
    }

    function getAndUpdateLockedAmount(address wallet) external override returns (uint) {

        if (_locked[wallet] > 0) {
            DelegationController delegationController = DelegationController(
                contractManager.getContract("DelegationController"));
            TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));
            ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));

            uint currentMonth = timeHelpers.getCurrentMonth();
            if (_totalDelegatedSatisfiesProofOfUserCondition(wallet) &&
                timeHelpers.calculateProofOfUseLockEndTime(
                    _totalDelegatedAmount[wallet].month,
                    constantsHolder.proofOfUseLockUpPeriodDays()
                ) <= now) {
                _unlock(wallet);
                return 0;
            } else {
                uint lockedByDelegationController = _getAndUpdateDelegatedAmount(wallet, currentMonth)
                    .add(delegationController.getLockedInPendingDelegations(wallet));
                if (_locked[wallet] > lockedByDelegationController) {
                    return _locked[wallet].boundedSub(lockedByDelegationController);
                } else {
                    return 0;
                }
            }
        } else {
            return 0;
        }
    }

    function getAndUpdateForbiddenForDelegationAmount(address) external override returns (uint) {

        return 0;
    }

    function initialize(address contractManagerAddress) public override initializer {

        Permissions.initialize(contractManagerAddress);
    }


    function _getAndUpdateDelegatedAmount(address holder, uint currentMonth) private returns (uint) {

        return _delegatedAmount[holder].getAndUpdateValue(currentMonth);
    }

    function _addToDelegatedAmount(address holder, uint amount, uint month) private {

        _delegatedAmount[holder].addToValue(amount, month);
    }

    function _removeFromDelegatedAmount(address holder, uint amount, uint month) private {

        _delegatedAmount[holder].subtractFromValue(amount, month);
    }

    function _addToTotalDelegatedAmount(address holder, uint amount, uint month) private {

        require(
            _totalDelegatedAmount[holder].month == 0 || _totalDelegatedAmount[holder].month <= month,
            "Can't add to total delegated in the past");

        if (!_totalDelegatedSatisfiesProofOfUserCondition(holder)) {
            _totalDelegatedAmount[holder].delegated = _totalDelegatedAmount[holder].delegated.add(amount);
            _totalDelegatedAmount[holder].month = month;
        }
    }

    function _unlock(address holder) private {

        emit Unlocked(holder, _locked[holder]);
        delete _locked[holder];
        _deleteDelegatedAmount(holder);
        _deleteTotalDelegatedAmount(holder);
    }

    function _deleteDelegatedAmount(address holder) private {

        _delegatedAmount[holder].clear();
    }

    function _deleteTotalDelegatedAmount(address holder) private {

        delete _totalDelegatedAmount[holder].delegated;
        delete _totalDelegatedAmount[holder].month;
    }

    function _totalDelegatedSatisfiesProofOfUserCondition(address holder) private view returns (bool) {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));

        return _totalDelegatedAmount[holder].delegated.mul(100) >=
            _locked[holder].mul(constantsHolder.proofOfUseDelegationPercentage());
    }
}// AGPL-3.0-only


pragma solidity 0.6.10;



contract TokenState is Permissions, ILocker {


    event LockerWasAdded(
        string locker
    );

    event LockerWasRemoved(
        string locker
    );

    string[] private _lockers;

    function getAndUpdateLockedAmount(address holder) external override returns (uint) {

        uint locked = 0;
        for (uint i = 0; i < _lockers.length; ++i) {
            ILocker locker = ILocker(contractManager.getContract(_lockers[i]));
            locked = locked.add(locker.getAndUpdateLockedAmount(holder));
        }
        return locked;
    }

    function getAndUpdateForbiddenForDelegationAmount(address holder) external override returns (uint amount) {

        uint forbidden = 0;
        for (uint i = 0; i < _lockers.length; ++i) {
            ILocker locker = ILocker(contractManager.getContract(_lockers[i]));
            forbidden = forbidden.add(locker.getAndUpdateForbiddenForDelegationAmount(holder));
        }
        return forbidden;
    }

    function removeLocker(string calldata locker) external onlyOwner {

        uint index;
        bytes32 hash = keccak256(abi.encodePacked(locker));
        for (index = 0; index < _lockers.length; ++index) {
            if (keccak256(abi.encodePacked(_lockers[index])) == hash) {
                break;
            }
        }
        if (index < _lockers.length) {
            if (index < _lockers.length.sub(1)) {
                _lockers[index] = _lockers[_lockers.length.sub(1)];
            }
            delete _lockers[_lockers.length.sub(1)];
            _lockers.pop();
            emit LockerWasRemoved(locker);
        }
    }

    function initialize(address contractManagerAddress) public override initializer {

        Permissions.initialize(contractManagerAddress);
        addLocker("DelegationController");
        addLocker("Punisher");
        addLocker("TokenLaunchLocker");
    }

    function addLocker(string memory locker) public onlyOwner {

        _lockers.push(locker);
        emit LockerWasAdded(locker);
    }
}


pragma solidity 0.6.10;




contract DelegationController is Permissions, ILocker {

    using MathUtils for uint;
    using PartialDifferences for PartialDifferences.Sequence;
    using PartialDifferences for PartialDifferences.Value;
    using FractionUtils for FractionUtils.Fraction;

    enum State {
        PROPOSED,
        ACCEPTED,
        CANCELED,
        REJECTED,
        DELEGATED,
        UNDELEGATION_REQUESTED,
        COMPLETED
    }

    struct Delegation {
        address holder; // address of token owner
        uint validatorId;
        uint amount;
        uint delegationPeriod;
        uint created; // time of delegation creation
        uint started; // month when a delegation becomes active
        uint finished; // first month after a delegation ends
        string info;
    }

    struct SlashingLogEvent {
        FractionUtils.Fraction reducingCoefficient;
        uint nextMonth;
    }

    struct SlashingLog {
        mapping (uint => SlashingLogEvent) slashes;
        uint firstMonth;
        uint lastMonth;
    }

    struct DelegationExtras {
        uint lastSlashingMonthBeforeDelegation;
    }

    struct SlashingEvent {
        FractionUtils.Fraction reducingCoefficient;
        uint validatorId;
        uint month;
    }

    struct SlashingSignal {
        address holder;
        uint penalty;
    }

    struct LockedInPending {
        uint amount;
        uint month;
    }

    struct FirstDelegationMonth {
        uint value;
        mapping (uint => uint) byValidator;
    }

    struct ValidatorsStatistics {
        uint number;
        mapping (uint => uint) delegated;
    }

    event DelegationProposed(
        uint delegationId
    );

    event DelegationAccepted(
        uint delegationId
    );

    event DelegationRequestCanceledByUser(
        uint delegationId
    );

    event UndelegationRequested(
        uint delegationId
    );

    Delegation[] public delegations;

    mapping (uint => uint[]) public delegationsByValidator;

    mapping (address => uint[]) public delegationsByHolder;

    mapping(uint => DelegationExtras) private _delegationExtras;

    mapping (uint => PartialDifferences.Value) private _delegatedToValidator;
    mapping (uint => PartialDifferences.Sequence) private _effectiveDelegatedToValidator;

    mapping (uint => SlashingLog) private _slashesOfValidator;

    mapping (address => PartialDifferences.Value) private _delegatedByHolder;
    mapping (address => mapping (uint => PartialDifferences.Value)) private _delegatedByHolderToValidator;
    mapping (address => mapping (uint => PartialDifferences.Sequence)) private _effectiveDelegatedByHolderToValidator;

    SlashingEvent[] private _slashes;
    mapping (address => uint) private _firstUnprocessedSlashByHolder;

    mapping (address => FirstDelegationMonth) private _firstDelegationMonth;

    mapping (address => LockedInPending) private _lockedInPendingDelegations;

    mapping (address => ValidatorsStatistics) private _numberOfValidatorsPerDelegator;

    modifier checkDelegationExists(uint delegationId) {

        require(delegationId < delegations.length, "Delegation does not exist");
        _;
    }

    function getAndUpdateDelegatedToValidatorNow(uint validatorId) external returns (uint) {

        return getAndUpdateDelegatedToValidator(validatorId, _getCurrentMonth());
    }

    function getAndUpdateDelegatedAmount(address holder) external returns (uint) {

        return _getAndUpdateDelegatedByHolder(holder);
    }

    function getAndUpdateEffectiveDelegatedByHolderToValidator(address holder, uint validatorId, uint month) external
        allow("Distributor") returns (uint effectiveDelegated)
    {

        SlashingSignal[] memory slashingSignals = _processAllSlashesWithoutSignals(holder);
        effectiveDelegated = _effectiveDelegatedByHolderToValidator[holder][validatorId]
            .getAndUpdateValueInSequence(month);
        _sendSlashingSignals(slashingSignals);
    }

    function delegate(
        uint validatorId,
        uint amount,
        uint delegationPeriod,
        string calldata info
    )
        external
    {

        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        DelegationPeriodManager delegationPeriodManager = DelegationPeriodManager(
            contractManager.getContract("DelegationPeriodManager"));
        IERC777 skaleToken = IERC777(contractManager.getContract("SkaleToken"));
        TokenState tokenState = TokenState(contractManager.getContract("TokenState"));

        require(
            validatorService.checkMinimumDelegation(validatorId, amount),
            "Amount does not meet the validator's minimum delegation amount");
        require(
            validatorService.isAuthorizedValidator(validatorId),
            "Validator is not authorized to accept delegation request");
        require(
            delegationPeriodManager.isDelegationPeriodAllowed(delegationPeriod),
            "This delegation period is not allowed");
        require(
            validatorService.isAcceptingNewRequests(validatorId),
            "The validator is not currently accepting new requests");
        _checkIfDelegationIsAllowed(msg.sender, validatorId);

        SlashingSignal[] memory slashingSignals = _processAllSlashesWithoutSignals(msg.sender);

        uint delegationId = _addDelegation(
            msg.sender,
            validatorId,
            amount,
            delegationPeriod,
            info);

        uint holderBalance = skaleToken.balanceOf(msg.sender);
        uint forbiddenForDelegation = tokenState.getAndUpdateForbiddenForDelegationAmount(msg.sender);
        require(holderBalance >= forbiddenForDelegation, "Token holder does not have enough tokens to delegate");

        emit DelegationProposed(delegationId);

        _sendSlashingSignals(slashingSignals);
    }

    function getAndUpdateLockedAmount(address wallet) external override returns (uint) {

        return _getAndUpdateLockedAmount(wallet);
    }

    function getAndUpdateForbiddenForDelegationAmount(address wallet) external override returns (uint) {

        return _getAndUpdateLockedAmount(wallet);
    }

    function cancelPendingDelegation(uint delegationId) external checkDelegationExists(delegationId) {

        require(msg.sender == delegations[delegationId].holder, "Only token holders can cancel delegation request");
        require(getState(delegationId) == State.PROPOSED, "Token holders are only able to cancel PROPOSED delegations");

        delegations[delegationId].finished = _getCurrentMonth();
        _subtractFromLockedInPendingDelegations(delegations[delegationId].holder, delegations[delegationId].amount);

        emit DelegationRequestCanceledByUser(delegationId);
    }

    function acceptPendingDelegation(uint delegationId) external checkDelegationExists(delegationId) {

        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        require(
            validatorService.checkValidatorAddressToId(msg.sender, delegations[delegationId].validatorId),
            "No permissions to accept request");
        _checkIfDelegationIsAllowed(delegations[delegationId].holder, delegations[delegationId].validatorId);
        
        State currentState = getState(delegationId);
        if (currentState != State.PROPOSED) {
            if (currentState == State.ACCEPTED ||
                currentState == State.DELEGATED ||
                currentState == State.UNDELEGATION_REQUESTED ||
                currentState == State.COMPLETED)
            {
                revert("The delegation has been already accepted");
            } else if (currentState == State.CANCELED) {
                revert("The delegation has been cancelled by token holder");
            } else if (currentState == State.REJECTED) {
                revert("The delegation request is outdated");
            }
        }
        require(currentState == State.PROPOSED, "Cannot set delegation state to accepted");
        
        TokenLaunchLocker tokenLaunchLocker = TokenLaunchLocker(contractManager.getContract("TokenLaunchLocker"));

        SlashingSignal[] memory slashingSignals = _processAllSlashesWithoutSignals(delegations[delegationId].holder);

        _addToAllStatistics(delegationId);

        tokenLaunchLocker.handleDelegationAdd(
            delegations[delegationId].holder,
            delegationId,
            delegations[delegationId].amount,
            delegations[delegationId].started);

        _sendSlashingSignals(slashingSignals);

        emit DelegationAccepted(delegationId);
    }

    function requestUndelegation(uint delegationId) external checkDelegationExists(delegationId) {

        require(getState(delegationId) == State.DELEGATED, "Cannot request undelegation");
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        require(
            delegations[delegationId].holder == msg.sender ||
            (validatorService.validatorAddressExists(msg.sender) &&
            delegations[delegationId].validatorId == validatorService.getValidatorId(msg.sender)),
            "Permission denied to request undelegation");
        TokenLaunchLocker tokenLaunchLocker = TokenLaunchLocker(contractManager.getContract("TokenLaunchLocker"));
        DelegationPeriodManager delegationPeriodManager = DelegationPeriodManager(
            contractManager.getContract("DelegationPeriodManager"));
        _removeValidatorFromValidatorsPerDelegators(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId
        );
        processAllSlashes(msg.sender);
        delegations[delegationId].finished = _calculateDelegationEndMonth(delegationId);
        uint amountAfterSlashing = _calculateDelegationAmountAfterSlashing(delegationId);
        _removeFromDelegatedToValidator(
            delegations[delegationId].validatorId,
            amountAfterSlashing,
            delegations[delegationId].finished);
        _removeFromDelegatedByHolder(
            delegations[delegationId].holder,
            amountAfterSlashing,
            delegations[delegationId].finished);
        _removeFromDelegatedByHolderToValidator(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            amountAfterSlashing,
            delegations[delegationId].finished);
        uint effectiveAmount = amountAfterSlashing.mul(delegationPeriodManager.stakeMultipliers(
            delegations[delegationId].delegationPeriod));
        _removeFromEffectiveDelegatedToValidator(
            delegations[delegationId].validatorId,
            effectiveAmount,
            delegations[delegationId].finished);
        _removeFromEffectiveDelegatedByHolderToValidator(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            effectiveAmount,
            delegations[delegationId].finished);
        tokenLaunchLocker.handleDelegationRemoving(
            delegations[delegationId].holder,
            delegationId,
            delegations[delegationId].finished);
        emit UndelegationRequested(delegationId);
    }

    function confiscate(uint validatorId, uint amount) external allow("Punisher") {

        uint currentMonth = _getCurrentMonth();
        FractionUtils.Fraction memory coefficient =
            _delegatedToValidator[validatorId].reduceValue(amount, currentMonth);
        _effectiveDelegatedToValidator[validatorId].reduceSequence(coefficient, currentMonth);
        _putToSlashingLog(_slashesOfValidator[validatorId], coefficient, currentMonth);
        _slashes.push(SlashingEvent({reducingCoefficient: coefficient, validatorId: validatorId, month: currentMonth}));
    }

    function getAndUpdateEffectiveDelegatedToValidator(uint validatorId, uint month)
        external allow("Distributor") returns (uint)
    {

        return _effectiveDelegatedToValidator[validatorId].getAndUpdateValueInSequence(month);
    }

    function getAndUpdateDelegatedByHolderToValidatorNow(address holder, uint validatorId) external returns (uint) {

        return _getAndUpdateDelegatedByHolderToValidator(holder, validatorId, _getCurrentMonth());
    }

    function getDelegation(uint delegationId)
        external view checkDelegationExists(delegationId) returns (Delegation memory)
    {

        return delegations[delegationId];
    }

    function getFirstDelegationMonth(address holder, uint validatorId) external view returns(uint) {

        return _firstDelegationMonth[holder].byValidator[validatorId];
    }

    function getDelegationsByValidatorLength(uint validatorId) external view returns (uint) {

        return delegationsByValidator[validatorId].length;
    }

    function getDelegationsByHolderLength(address holder) external view returns (uint) {

        return delegationsByHolder[holder].length;
    }

    function initialize(address contractsAddress) public override initializer {

        Permissions.initialize(contractsAddress);
    }

    function getAndUpdateDelegatedToValidator(uint validatorId, uint month)
        public allow("Nodes") returns (uint)
    {

        return _delegatedToValidator[validatorId].getAndUpdateValue(month);
    }

    function processSlashes(address holder, uint limit) public {

        _sendSlashingSignals(_processSlashesWithoutSignals(holder, limit));
    }

    function processAllSlashes(address holder) public {

        processSlashes(holder, 0);
    }

    function getState(uint delegationId) public view checkDelegationExists(delegationId) returns (State state) {

        if (delegations[delegationId].started == 0) {
            if (delegations[delegationId].finished == 0) {
                TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));
                if (_getCurrentMonth() == timeHelpers.timestampToMonth(delegations[delegationId].created)) {
                    return State.PROPOSED;
                } else {
                    return State.REJECTED;
                }
            } else {
                return State.CANCELED;
            }
        } else {
            if (_getCurrentMonth() < delegations[delegationId].started) {
                return State.ACCEPTED;
            } else {
                if (delegations[delegationId].finished == 0) {
                    return State.DELEGATED;
                } else {
                    if (_getCurrentMonth() < delegations[delegationId].finished) {
                        return State.UNDELEGATION_REQUESTED;
                    } else {
                        return State.COMPLETED;
                    }
                }
            }
        }
    }

    function getLockedInPendingDelegations(address holder) public view returns (uint) {

        uint currentMonth = _getCurrentMonth();
        if (_lockedInPendingDelegations[holder].month < currentMonth) {
            return 0;
        } else {
            return _lockedInPendingDelegations[holder].amount;
        }
    }

    function hasUnprocessedSlashes(address holder) public view returns (bool) {

        return _everDelegated(holder) && _firstUnprocessedSlashByHolder[holder] < _slashes.length;
    }    


    function _addDelegation(
        address holder,
        uint validatorId,
        uint amount,
        uint delegationPeriod,
        string memory info
    )
        private
        returns (uint delegationId)
    {

        delegationId = delegations.length;
        delegations.push(Delegation(
            holder,
            validatorId,
            amount,
            delegationPeriod,
            now,
            0,
            0,
            info
        ));
        delegationsByValidator[validatorId].push(delegationId);
        delegationsByHolder[holder].push(delegationId);
        _addToLockedInPendingDelegations(delegations[delegationId].holder, delegations[delegationId].amount);
    }

    function _calculateDelegationEndMonth(uint delegationId) private view returns (uint) {

        uint currentMonth = _getCurrentMonth();
        uint started = delegations[delegationId].started;

        if (currentMonth < started) {
            return started.add(delegations[delegationId].delegationPeriod);
        } else {
            uint completedPeriods = currentMonth.sub(started).div(delegations[delegationId].delegationPeriod);
            return started.add(completedPeriods.add(1).mul(delegations[delegationId].delegationPeriod));
        }
    }

    function _addToDelegatedToValidator(uint validatorId, uint amount, uint month) private {

        _delegatedToValidator[validatorId].addToValue(amount, month);
    }

    function _addToEffectiveDelegatedToValidator(uint validatorId, uint effectiveAmount, uint month) private {

        _effectiveDelegatedToValidator[validatorId].addToSequence(effectiveAmount, month);
    }

    function _addToDelegatedByHolder(address holder, uint amount, uint month) private {

        _delegatedByHolder[holder].addToValue(amount, month);
    }

    function _addToDelegatedByHolderToValidator(
        address holder, uint validatorId, uint amount, uint month) private
    {

        _delegatedByHolderToValidator[holder][validatorId].addToValue(amount, month);
    }

    function _addValidatorToValidatorsPerDelegators(address holder, uint validatorId) private {

        if (_numberOfValidatorsPerDelegator[holder].delegated[validatorId] == 0) {
            _numberOfValidatorsPerDelegator[holder].number = _numberOfValidatorsPerDelegator[holder].number.add(1);
        }
        _numberOfValidatorsPerDelegator[holder].
            delegated[validatorId] = _numberOfValidatorsPerDelegator[holder].delegated[validatorId].add(1);
    }

    function _removeFromDelegatedByHolder(address holder, uint amount, uint month) private {

        _delegatedByHolder[holder].subtractFromValue(amount, month);
    }

    function _removeFromDelegatedByHolderToValidator(
        address holder, uint validatorId, uint amount, uint month) private
    {

        _delegatedByHolderToValidator[holder][validatorId].subtractFromValue(amount, month);
    }

    function _removeValidatorFromValidatorsPerDelegators(address holder, uint validatorId) private {

        if (_numberOfValidatorsPerDelegator[holder].delegated[validatorId] == 1) {
            _numberOfValidatorsPerDelegator[holder].number = _numberOfValidatorsPerDelegator[holder].number.sub(1);
        }
        _numberOfValidatorsPerDelegator[holder].
            delegated[validatorId] = _numberOfValidatorsPerDelegator[holder].delegated[validatorId].sub(1);
    }

    function _addToEffectiveDelegatedByHolderToValidator(
        address holder,
        uint validatorId,
        uint effectiveAmount,
        uint month)
        private
    {

        _effectiveDelegatedByHolderToValidator[holder][validatorId].addToSequence(effectiveAmount, month);
    }

    function _removeFromEffectiveDelegatedByHolderToValidator(
        address holder,
        uint validatorId,
        uint effectiveAmount,
        uint month)
        private
    {

        _effectiveDelegatedByHolderToValidator[holder][validatorId].subtractFromSequence(effectiveAmount, month);
    }

    function _getAndUpdateDelegatedByHolder(address holder) private returns (uint) {

        uint currentMonth = _getCurrentMonth();
        processAllSlashes(holder);
        return _delegatedByHolder[holder].getAndUpdateValue(currentMonth);
    }

    function _getAndUpdateDelegatedByHolderToValidator(
        address holder,
        uint validatorId,
        uint month)
        private returns (uint)
    {

        return _delegatedByHolderToValidator[holder][validatorId].getAndUpdateValue(month);
    }

    function _addToLockedInPendingDelegations(address holder, uint amount) private returns (uint) {

        uint currentMonth = _getCurrentMonth();
        if (_lockedInPendingDelegations[holder].month < currentMonth) {
            _lockedInPendingDelegations[holder].amount = amount;
            _lockedInPendingDelegations[holder].month = currentMonth;
        } else {
            assert(_lockedInPendingDelegations[holder].month == currentMonth);
            _lockedInPendingDelegations[holder].amount = _lockedInPendingDelegations[holder].amount.add(amount);
        }
    }

    function _subtractFromLockedInPendingDelegations(address holder, uint amount) private returns (uint) {

        uint currentMonth = _getCurrentMonth();
        require(
            _lockedInPendingDelegations[holder].month == currentMonth,
            "There are no delegation requests this month");
        require(_lockedInPendingDelegations[holder].amount >= amount, "Unlocking amount is too big");
        _lockedInPendingDelegations[holder].amount = _lockedInPendingDelegations[holder].amount.sub(amount);
    }

    function _getCurrentMonth() private view returns (uint) {

        TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));
        return timeHelpers.getCurrentMonth();
    }

    function _getAndUpdateLockedAmount(address wallet) private returns (uint) {

        return _getAndUpdateDelegatedByHolder(wallet).add(getLockedInPendingDelegations(wallet));
    }

    function _updateFirstDelegationMonth(address holder, uint validatorId, uint month) private {

        if (_firstDelegationMonth[holder].value == 0) {
            _firstDelegationMonth[holder].value = month;
            _firstUnprocessedSlashByHolder[holder] = _slashes.length;
        }
        if (_firstDelegationMonth[holder].byValidator[validatorId] == 0) {
            _firstDelegationMonth[holder].byValidator[validatorId] = month;
        }
    }

    function _everDelegated(address holder) private view returns (bool) {

        return _firstDelegationMonth[holder].value > 0;
    }

    function _removeFromDelegatedToValidator(uint validatorId, uint amount, uint month) private {

        _delegatedToValidator[validatorId].subtractFromValue(amount, month);
    }

    function _removeFromEffectiveDelegatedToValidator(uint validatorId, uint effectiveAmount, uint month) private {

        _effectiveDelegatedToValidator[validatorId].subtractFromSequence(effectiveAmount, month);
    }

    function _calculateDelegationAmountAfterSlashing(uint delegationId) private view returns (uint) {

        uint startMonth = _delegationExtras[delegationId].lastSlashingMonthBeforeDelegation;
        uint validatorId = delegations[delegationId].validatorId;
        uint amount = delegations[delegationId].amount;
        if (startMonth == 0) {
            startMonth = _slashesOfValidator[validatorId].firstMonth;
            if (startMonth == 0) {
                return amount;
            }
        }
        for (uint i = startMonth;
            i > 0 && i < delegations[delegationId].finished;
            i = _slashesOfValidator[validatorId].slashes[i].nextMonth) {
            if (i >= delegations[delegationId].started) {
                amount = amount
                    .mul(_slashesOfValidator[validatorId].slashes[i].reducingCoefficient.numerator)
                    .div(_slashesOfValidator[validatorId].slashes[i].reducingCoefficient.denominator);
            }
        }
        return amount;
    }

    function _putToSlashingLog(
        SlashingLog storage log,
        FractionUtils.Fraction memory coefficient,
        uint month)
        private
    {

        if (log.firstMonth == 0) {
            log.firstMonth = month;
            log.lastMonth = month;
            log.slashes[month].reducingCoefficient = coefficient;
            log.slashes[month].nextMonth = 0;
        } else {
            require(log.lastMonth <= month, "Cannot put slashing event in the past");
            if (log.lastMonth == month) {
                log.slashes[month].reducingCoefficient =
                    log.slashes[month].reducingCoefficient.multiplyFraction(coefficient);
            } else {
                log.slashes[month].reducingCoefficient = coefficient;
                log.slashes[month].nextMonth = 0;
                log.slashes[log.lastMonth].nextMonth = month;
                log.lastMonth = month;
            }
        }
    }

    function _processSlashesWithoutSignals(address holder, uint limit)
        private returns (SlashingSignal[] memory slashingSignals)
    {

        if (hasUnprocessedSlashes(holder)) {
            uint index = _firstUnprocessedSlashByHolder[holder];
            uint end = _slashes.length;
            if (limit > 0 && index.add(limit) < end) {
                end = index.add(limit);
            }
            slashingSignals = new SlashingSignal[](end.sub(index));
            uint begin = index;
            for (; index < end; ++index) {
                uint validatorId = _slashes[index].validatorId;
                uint month = _slashes[index].month;
                uint oldValue = _getAndUpdateDelegatedByHolderToValidator(holder, validatorId, month);
                if (oldValue.muchGreater(0)) {
                    _delegatedByHolderToValidator[holder][validatorId].reduceValueByCoefficientAndUpdateSum(
                        _delegatedByHolder[holder],
                        _slashes[index].reducingCoefficient,
                        month);
                    _effectiveDelegatedByHolderToValidator[holder][validatorId].reduceSequence(
                        _slashes[index].reducingCoefficient,
                        month);
                    slashingSignals[index.sub(begin)].holder = holder;
                    slashingSignals[index.sub(begin)].penalty
                        = oldValue.boundedSub(_getAndUpdateDelegatedByHolderToValidator(holder, validatorId, month));
                }
            }
            _firstUnprocessedSlashByHolder[holder] = end;
        }
    }

    function _processAllSlashesWithoutSignals(address holder)
        private returns (SlashingSignal[] memory slashingSignals)
    {

        return _processSlashesWithoutSignals(holder, 0);
    }

    function _sendSlashingSignals(SlashingSignal[] memory slashingSignals) private {

        Punisher punisher = Punisher(contractManager.getContract("Punisher"));
        address previousHolder = address(0);
        uint accumulatedPenalty = 0;
        for (uint i = 0; i < slashingSignals.length; ++i) {
            if (slashingSignals[i].holder != previousHolder) {
                if (accumulatedPenalty > 0) {
                    punisher.handleSlash(previousHolder, accumulatedPenalty);
                }
                previousHolder = slashingSignals[i].holder;
                accumulatedPenalty = slashingSignals[i].penalty;
            } else {
                accumulatedPenalty = accumulatedPenalty.add(slashingSignals[i].penalty);
            }
        }
        if (accumulatedPenalty > 0) {
            punisher.handleSlash(previousHolder, accumulatedPenalty);
        }
    }

    function _addToAllStatistics(uint delegationId) private {

        DelegationPeriodManager delegationPeriodManager = DelegationPeriodManager(
            contractManager.getContract("DelegationPeriodManager"));

        uint currentMonth = _getCurrentMonth();
        delegations[delegationId].started = currentMonth.add(1);
        if (_slashesOfValidator[delegations[delegationId].validatorId].lastMonth > 0) {
            _delegationExtras[delegationId].lastSlashingMonthBeforeDelegation =
                _slashesOfValidator[delegations[delegationId].validatorId].lastMonth;
        }

        _addToDelegatedToValidator(
            delegations[delegationId].validatorId,
            delegations[delegationId].amount,
            currentMonth.add(1));
        _addToDelegatedByHolder(
            delegations[delegationId].holder,
            delegations[delegationId].amount,
            currentMonth.add(1));
        _addToDelegatedByHolderToValidator(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            delegations[delegationId].amount,
            currentMonth.add(1));
        _updateFirstDelegationMonth(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            currentMonth.add(1));
        uint effectiveAmount = delegations[delegationId].amount.mul(delegationPeriodManager.stakeMultipliers(
            delegations[delegationId].delegationPeriod));
        _addToEffectiveDelegatedToValidator(
            delegations[delegationId].validatorId,
            effectiveAmount,
            currentMonth.add(1));
        _addToEffectiveDelegatedByHolderToValidator(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            effectiveAmount,
            currentMonth.add(1));
        _addValidatorToValidatorsPerDelegators(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId
        );
    }

    function _checkIfDelegationIsAllowed(address holder, uint validatorId) private view returns (bool) {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        require(
            _numberOfValidatorsPerDelegator[holder].delegated[validatorId] > 0 ||
                (
                    _numberOfValidatorsPerDelegator[holder].delegated[validatorId] == 0 &&
                    _numberOfValidatorsPerDelegator[holder].number < constantsHolder.limitValidatorsPerDelegator()
                ),
            "Limit of validators is reached"
        );
        require(
            _getCurrentMonth() >= constantsHolder.firstDelegationsMonth(),
            "Delegations are not allowed"
        );
    }
}// AGPL-3.0-only


pragma solidity 0.6.10;




contract ValidatorService is Permissions {


    using ECDSA for bytes32;

    struct Validator {
        string name;
        address validatorAddress;
        address requestedAddress;
        string description;
        uint feeRate;
        uint registrationTime;
        uint minimumDelegationAmount;
        bool acceptNewRequests;
    }

    event ValidatorRegistered(
        uint validatorId
    );

    event ValidatorAddressChanged(
        uint validatorId,
        address newAddress
    );

    event ValidatorWasEnabled(
        uint validatorId
    );

    event ValidatorWasDisabled(
        uint validatorId
    );

    event NodeAddressWasAdded(
        uint validatorId,
        address nodeAddress
    );

    event NodeAddressWasRemoved(
        uint validatorId,
        address nodeAddress
    );

    mapping (uint => Validator) public validators;
    mapping (uint => bool) private _trustedValidators;
    uint[] public trustedValidatorsList;
    mapping (address => uint) private _validatorAddressToId;
    mapping (address => uint) private _nodeAddressToValidatorId;
    mapping (uint => address[]) private _nodeAddresses;
    uint public numberOfValidators;
    bool public useWhitelist;

    modifier checkValidatorExists(uint validatorId) {

        require(validatorExists(validatorId), "Validator with such ID does not exist");
        _;
    }

    function registerValidator(
        string calldata name,
        string calldata description,
        uint feeRate,
        uint minimumDelegationAmount
    )
        external
        returns (uint validatorId)
    {

        require(!validatorAddressExists(msg.sender), "Validator with such address already exists");
        require(feeRate < 1000, "Fee rate of validator should be lower than 100%");
        validatorId = ++numberOfValidators;
        validators[validatorId] = Validator(
            name,
            msg.sender,
            address(0),
            description,
            feeRate,
            now,
            minimumDelegationAmount,
            true
        );
        _setValidatorAddress(validatorId, msg.sender);

        emit ValidatorRegistered(validatorId);
    }

    function enableValidator(uint validatorId) external checkValidatorExists(validatorId) onlyAdmin {

        require(!_trustedValidators[validatorId], "Validator is already enabled");
        _trustedValidators[validatorId] = true;
        trustedValidatorsList.push(validatorId);
        emit ValidatorWasEnabled(validatorId);
    }

    function disableValidator(uint validatorId) external checkValidatorExists(validatorId) onlyAdmin {

        require(_trustedValidators[validatorId], "Validator is already disabled");
        _trustedValidators[validatorId] = false;
        uint position = _find(trustedValidatorsList, validatorId);
        if (position < trustedValidatorsList.length) {
            trustedValidatorsList[position] =
                trustedValidatorsList[trustedValidatorsList.length.sub(1)];
        }
        trustedValidatorsList.pop();
        emit ValidatorWasDisabled(validatorId);
    }

    function disableWhitelist() external onlyOwner {

        useWhitelist = false;
    }

    function requestForNewAddress(address newValidatorAddress) external {

        require(newValidatorAddress != address(0), "New address cannot be null");
        require(_validatorAddressToId[newValidatorAddress] == 0, "Address already registered");
        uint validatorId = getValidatorId(msg.sender);

        validators[validatorId].requestedAddress = newValidatorAddress;
    }

    function confirmNewAddress(uint validatorId)
        external
        checkValidatorExists(validatorId)
    {

        require(
            getValidator(validatorId).requestedAddress == msg.sender,
            "The validator address cannot be changed because it is not the actual owner"
        );
        delete validators[validatorId].requestedAddress;
        _setValidatorAddress(validatorId, msg.sender);

        emit ValidatorAddressChanged(validatorId, validators[validatorId].validatorAddress);
    }

    function linkNodeAddress(address nodeAddress, bytes calldata sig) external {

        uint validatorId = getValidatorId(msg.sender);
        require(
            keccak256(abi.encodePacked(validatorId)).toEthSignedMessageHash().recover(sig) == nodeAddress,
            "Signature is not pass"
        );
        require(_validatorAddressToId[nodeAddress] == 0, "Node address is a validator");

        _addNodeAddress(validatorId, nodeAddress);
        emit NodeAddressWasAdded(validatorId, nodeAddress);
    }

    function unlinkNodeAddress(address nodeAddress) external {

        uint validatorId = getValidatorId(msg.sender);

        _removeNodeAddress(validatorId, nodeAddress);
        emit NodeAddressWasRemoved(validatorId, nodeAddress);
    }

    function setValidatorMDA(uint minimumDelegationAmount) external {

        uint validatorId = getValidatorId(msg.sender);

        validators[validatorId].minimumDelegationAmount = minimumDelegationAmount;
    }

    function setValidatorName(string calldata newName) external {

        uint validatorId = getValidatorId(msg.sender);

        validators[validatorId].name = newName;
    }

    function setValidatorDescription(string calldata newDescription) external {

        uint validatorId = getValidatorId(msg.sender);

        validators[validatorId].description = newDescription;
    }

    function startAcceptingNewRequests() external {

        uint validatorId = getValidatorId(msg.sender);
        require(!isAcceptingNewRequests(validatorId), "Accepting request is already enabled");

        validators[validatorId].acceptNewRequests = true;
    }

    function stopAcceptingNewRequests() external {

        uint validatorId = getValidatorId(msg.sender);
        require(isAcceptingNewRequests(validatorId), "Accepting request is already disabled");

        validators[validatorId].acceptNewRequests = false;
    }

    function getAndUpdateBondAmount(uint validatorId)
        external
        returns (uint)
    {

        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController")
        );
        return delegationController.getAndUpdateDelegatedByHolderToValidatorNow(
            getValidator(validatorId).validatorAddress,
            validatorId
        );
    }

    function getMyNodesAddresses() external view returns (address[] memory) {

        return getNodeAddresses(getValidatorId(msg.sender));
    }

    function getTrustedValidators() external view returns (uint[] memory) {

        return trustedValidatorsList;
    }

    function checkMinimumDelegation(uint validatorId, uint amount)
        external
        view
        checkValidatorExists(validatorId)
        allow("DelegationController")
        returns (bool)
    {

        return validators[validatorId].minimumDelegationAmount <= amount ? true : false;
    }

    function checkValidatorAddressToId(address validatorAddress, uint validatorId)
        external
        view
        returns (bool)
    {

        return getValidatorId(validatorAddress) == validatorId ? true : false;
    }

    function getValidatorIdByNodeAddress(address nodeAddress) external view returns (uint validatorId) {

        validatorId = _nodeAddressToValidatorId[nodeAddress];
        require(validatorId != 0, "Node address is not assigned to a validator");
    }


    function isAuthorizedValidator(uint validatorId) external view checkValidatorExists(validatorId) returns (bool) {

        return _trustedValidators[validatorId] || !useWhitelist;
    }

    function initialize(address contractManagerAddress) public override initializer {

        Permissions.initialize(contractManagerAddress);
        useWhitelist = true;
    }

    function getNodeAddresses(uint validatorId) public view returns (address[] memory) {

        return _nodeAddresses[validatorId];
    }

    function validatorExists(uint validatorId) public view returns (bool) {

        return validatorId <= numberOfValidators && validatorId != 0;
    }

    function validatorAddressExists(address validatorAddress) public view returns (bool) {

        return _validatorAddressToId[validatorAddress] != 0;
    }

    function checkIfValidatorAddressExists(address validatorAddress) public view {

        require(validatorAddressExists(validatorAddress), "Validator with given address does not exist");
    }

    function getValidator(uint validatorId) public view checkValidatorExists(validatorId) returns (Validator memory) {

        return validators[validatorId];
    }

    function getValidatorId(address validatorAddress) public view returns (uint) {

        checkIfValidatorAddressExists(validatorAddress);
        return _validatorAddressToId[validatorAddress];
    }

    function isAcceptingNewRequests(uint validatorId) public view checkValidatorExists(validatorId) returns (bool) {

        return validators[validatorId].acceptNewRequests;
    }

    function _setValidatorAddress(uint validatorId, address validatorAddress) private {

        if (_validatorAddressToId[validatorAddress] == validatorId) {
            return;
        }
        require(_validatorAddressToId[validatorAddress] == 0, "Address is in use by another validator");
        address oldAddress = validators[validatorId].validatorAddress;
        delete _validatorAddressToId[oldAddress];
        _nodeAddressToValidatorId[validatorAddress] = validatorId;
        validators[validatorId].validatorAddress = validatorAddress;
        _validatorAddressToId[validatorAddress] = validatorId;
    }

    function _addNodeAddress(uint validatorId, address nodeAddress) private {

        if (_nodeAddressToValidatorId[nodeAddress] == validatorId) {
            return;
        }
        require(_nodeAddressToValidatorId[nodeAddress] == 0, "Validator cannot override node address");
        _nodeAddressToValidatorId[nodeAddress] = validatorId;
        _nodeAddresses[validatorId].push(nodeAddress);
    }

    function _removeNodeAddress(uint validatorId, address nodeAddress) private {

        require(_nodeAddressToValidatorId[nodeAddress] == validatorId,
            "Validator does not have permissions to unlink node");
        delete _nodeAddressToValidatorId[nodeAddress];
        for (uint i = 0; i < _nodeAddresses[validatorId].length; ++i) {
            if (_nodeAddresses[validatorId][i] == nodeAddress) {
                if (i + 1 < _nodeAddresses[validatorId].length) {
                    _nodeAddresses[validatorId][i] =
                        _nodeAddresses[validatorId][_nodeAddresses[validatorId].length.sub(1)];
                }
                delete _nodeAddresses[validatorId][_nodeAddresses[validatorId].length.sub(1)];
                _nodeAddresses[validatorId].pop();
                break;
            }
        }
    }

    function _find(uint[] memory array, uint index) private pure returns (uint) {

        uint i;
        for (i = 0; i < array.length; i++) {
            if (array[i] == index) {
                return i;
            }
        }
        return array.length;
    }
}


pragma solidity 0.6.10;





contract Distributor is Permissions, IERC777Recipient {

    using MathUtils for uint;

    event WithdrawBounty(
        address holder,
        uint validatorId,
        address destination,
        uint amount
    );

    event WithdrawFee(
        uint validatorId,
        address destination,
        uint amount
    );

    event BountyWasPaid(
        uint validatorId,
        uint amount
    );

    IERC1820Registry private _erc1820;

    mapping (uint => mapping (uint => uint)) private _bountyPaid;
    mapping (uint => mapping (uint => uint)) private _feePaid;
    mapping (address => mapping (uint => uint)) private _firstUnwithdrawnMonth;
    mapping (uint => uint) private _firstUnwithdrawnMonthForValidator;

    function getAndUpdateEarnedBountyAmount(uint validatorId) external returns (uint earned, uint endMonth) {

        return getAndUpdateEarnedBountyAmountOf(msg.sender, validatorId);
    }

    function withdrawBounty(uint validatorId, address to) external {

        TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));

        require(now >= timeHelpers.addMonths(
                constantsHolder.launchTimestamp(),
                constantsHolder.BOUNTY_LOCKUP_MONTHS()
            ), "Bounty is locked");

        uint bounty;
        uint endMonth;
        (bounty, endMonth) = getAndUpdateEarnedBountyAmountOf(msg.sender, validatorId);

        _firstUnwithdrawnMonth[msg.sender][validatorId] = endMonth;

        IERC20 skaleToken = IERC20(contractManager.getContract("SkaleToken"));
        require(skaleToken.transfer(to, bounty), "Failed to transfer tokens");

        emit WithdrawBounty(
            msg.sender,
            validatorId,
            to,
            bounty
        );
    }

    function withdrawFee(address to) external {

        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        IERC20 skaleToken = IERC20(contractManager.getContract("SkaleToken"));
        TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));

        require(now >= timeHelpers.addMonths(
                constantsHolder.launchTimestamp(),
                constantsHolder.BOUNTY_LOCKUP_MONTHS()
            ), "Bounty is locked");
        uint validatorId = validatorService.getValidatorId(msg.sender);

        uint fee;
        uint endMonth;
        (fee, endMonth) = getEarnedFeeAmountOf(validatorId);

        _firstUnwithdrawnMonthForValidator[validatorId] = endMonth;

        require(skaleToken.transfer(to, fee), "Failed to transfer tokens");

        emit WithdrawFee(
            validatorId,
            to,
            fee
        );
    }

    function tokensReceived(
        address,
        address,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata
    )
        external override
        allow("SkaleToken")
    {

        require(to == address(this), "Receiver is incorrect");
        require(userData.length == 32, "Data length is incorrect");
        uint validatorId = abi.decode(userData, (uint));
        _distributeBounty(amount, validatorId);
    }

    function getEarnedFeeAmount() external view returns (uint earned, uint endMonth) {

        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        return getEarnedFeeAmountOf(validatorService.getValidatorId(msg.sender));
    }

    function initialize(address contractsAddress) public override initializer {

        Permissions.initialize(contractsAddress);
        _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }

    function getAndUpdateEarnedBountyAmountOf(address wallet, uint validatorId)
        public returns (uint earned, uint endMonth)
    {

        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController"));
        TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));

        uint currentMonth = timeHelpers.getCurrentMonth();

        uint startMonth = _firstUnwithdrawnMonth[wallet][validatorId];
        if (startMonth == 0) {
            startMonth = delegationController.getFirstDelegationMonth(wallet, validatorId);
            if (startMonth == 0) {
                return (0, 0);
            }
        }

        earned = 0;
        endMonth = currentMonth;
        if (endMonth > startMonth.add(12)) {
            endMonth = startMonth.add(12);
        }
        for (uint i = startMonth; i < endMonth; ++i) {
            uint effectiveDelegatedToValidator =
                delegationController.getAndUpdateEffectiveDelegatedToValidator(validatorId, i);
            if (effectiveDelegatedToValidator.muchGreater(0)) {
                earned = earned.add(
                    _bountyPaid[validatorId][i].mul(
                        delegationController.getAndUpdateEffectiveDelegatedByHolderToValidator(wallet, validatorId, i))
                            .div(effectiveDelegatedToValidator)
                    );
            }
        }
    }

    function getEarnedFeeAmountOf(uint validatorId) public view returns (uint earned, uint endMonth) {

        TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));

        uint currentMonth = timeHelpers.getCurrentMonth();

        uint startMonth = _firstUnwithdrawnMonthForValidator[validatorId];
        if (startMonth == 0) {
            return (0, 0);
        }

        earned = 0;
        endMonth = currentMonth;
        if (endMonth > startMonth.add(12)) {
            endMonth = startMonth.add(12);
        }
        for (uint i = startMonth; i < endMonth; ++i) {
            earned = earned.add(_feePaid[validatorId][i]);
        }
    }


    function _distributeBounty(uint amount, uint validatorId) private {

        TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));

        uint currentMonth = timeHelpers.getCurrentMonth();
        uint feeRate = validatorService.getValidator(validatorId).feeRate;

        uint fee = amount.mul(feeRate).div(1000);
        uint bounty = amount.sub(fee);
        _bountyPaid[validatorId][currentMonth] = _bountyPaid[validatorId][currentMonth].add(bounty);
        _feePaid[validatorId][currentMonth] = _feePaid[validatorId][currentMonth].add(fee);

        if (_firstUnwithdrawnMonthForValidator[validatorId] == 0) {
            _firstUnwithdrawnMonthForValidator[validatorId] = currentMonth;
        }

        emit BountyWasPaid(validatorId, amount);
    }
}
