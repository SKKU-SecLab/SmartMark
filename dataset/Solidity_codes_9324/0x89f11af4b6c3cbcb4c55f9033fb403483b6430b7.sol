pragma solidity ^0.6.0;

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
}// AGPL-3.0-only


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



contract Bounty is Permissions {


    uint public constant STAGE_LENGTH = 31558150; // 1 year
    uint public constant YEAR1_BOUNTY = 3850e5 * 1e18;
    uint public constant YEAR2_BOUNTY = 3465e5 * 1e18;
    uint public constant YEAR3_BOUNTY = 3080e5 * 1e18;
    uint public constant YEAR4_BOUNTY = 2695e5 * 1e18;
    uint public constant YEAR5_BOUNTY = 2310e5 * 1e18;
    uint public constant YEAR6_BOUNTY = 1925e5 * 1e18;
    uint public constant BOUNTY = 96250000 * 1e18;

    uint private _nextStage;
    uint private _stagePool;
    bool public bountyReduction;

    uint private _nodesPerRewardPeriod;
    uint private _nodesRemainingPerRewardPeriod;
    uint private _rewardPeriodFinished;

    function getBounty(
        uint nodeIndex,
        uint downtime,
        uint latency
    )
        external
        allow("SkaleManager")
        returns (uint)
    {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));

        _refillStagePool(constantsHolder);

        if (_rewardPeriodFinished <= now) {
            _updateNodesPerRewardPeriod(constantsHolder, nodes);
        }

        uint bounty = _calculateMaximumBountyAmount(_stagePool, _nextStage, nodeIndex, constantsHolder, nodes);

        bounty = _reduceBounty(
            bounty,
            nodeIndex,
            downtime,
            latency,
            nodes,
            constantsHolder
        );

        _stagePool = _stagePool.sub(bounty);
        _nodesRemainingPerRewardPeriod = _nodesRemainingPerRewardPeriod.sub(1);

        return bounty;
    }

    function enableBountyReduction() external onlyOwner {

        bountyReduction = true;
    }

    function disableBountyReduction() external onlyOwner {

        bountyReduction = false;
    }

    function calculateNormalBounty(uint nodeIndex) external view returns (uint) {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));

        uint stagePoolSize;
        uint nextStage;
        (stagePoolSize, nextStage) = _getStagePoolSize(constantsHolder);

        return _calculateMaximumBountyAmount(
            stagePoolSize,
            nextStage,
            nodeIndex,
            constantsHolder,
            nodes
        );
    }

    function initialize(address contractManagerAddress) public override initializer {

        Permissions.initialize(contractManagerAddress);
        _nextStage = 0;
        _stagePool = 0;
        _rewardPeriodFinished = 0;
        bountyReduction = false;
    }


    function _calculateMaximumBountyAmount(
        uint stagePoolSize,
        uint nextStage,
        uint nodeIndex,
        ConstantsHolder constantsHolder,
        Nodes nodes
    )
        private
        view
        returns (uint)
    {

        if (nodes.isNodeLeft(nodeIndex)) {
            return 0;
        }

        if (now < constantsHolder.launchTimestamp()) {
            return 0;
        }

        uint numberOfRewards = _getStageBeginningTimestamp(nextStage, constantsHolder)
            .sub(now)
            .div(constantsHolder.rewardPeriod());

        uint numberOfRewardsPerAllNodes = numberOfRewards.mul(_nodesPerRewardPeriod);

        return stagePoolSize.div(
            numberOfRewardsPerAllNodes.add(_nodesRemainingPerRewardPeriod)
        );
    }

    function _getStageBeginningTimestamp(uint stage, ConstantsHolder constantsHolder) private view returns (uint) {

        return constantsHolder.launchTimestamp().add(stage.mul(STAGE_LENGTH));
    }

    function _getStagePoolSize(ConstantsHolder constantsHolder) private view returns (uint stagePool, uint nextStage) {

        stagePool = _stagePool;
        for (nextStage = _nextStage; now >= _getStageBeginningTimestamp(nextStage, constantsHolder); ++nextStage) {
            stagePool += _getStageReward(_nextStage);
        }
    }

    function _refillStagePool(ConstantsHolder constantsHolder) private {

        (_stagePool, _nextStage) = _getStagePoolSize(constantsHolder);
    }

    function _updateNodesPerRewardPeriod(ConstantsHolder constantsHolder, Nodes nodes) private {

        _nodesPerRewardPeriod = nodes.getNumberOnlineNodes();
        _nodesRemainingPerRewardPeriod = _nodesPerRewardPeriod;
        _rewardPeriodFinished = now.add(uint(constantsHolder.rewardPeriod()));
    }

    function _getStageReward(uint stage) private pure returns (uint) {

        if (stage >= 6) {
            return BOUNTY.div(2 ** stage.sub(6).div(3));
        } else {
            if (stage == 0) {
                return YEAR1_BOUNTY;
            } else if (stage == 1) {
                return YEAR2_BOUNTY;
            } else if (stage == 2) {
                return YEAR3_BOUNTY;
            } else if (stage == 3) {
                return YEAR4_BOUNTY;
            } else if (stage == 4) {
                return YEAR5_BOUNTY;
            } else {
                return YEAR6_BOUNTY;
            }
        }
    }

    function _reduceBounty(
        uint bounty,
        uint nodeIndex,
        uint downtime,
        uint latency,
        Nodes nodes,
        ConstantsHolder constants
    )
        private
        returns (uint reducedBounty)
    {

        if (!bountyReduction) {
            return bounty;
        }

        reducedBounty = _reduceBountyByDowntime(bounty, nodeIndex, downtime, nodes, constants);

        if (latency > constants.allowableLatency()) {
            reducedBounty = reducedBounty.mul(constants.allowableLatency()).div(latency);
        }

        if (!nodes.checkPossibilityToMaintainNode(nodes.getValidatorId(nodeIndex), nodeIndex)) {
            reducedBounty = reducedBounty.div(constants.MSR_REDUCING_COEFFICIENT());
        }
    }

    function _reduceBountyByDowntime(
        uint bounty,
        uint nodeIndex,
        uint downtime,
        Nodes nodes,
        ConstantsHolder constants
    )
        private
        view
        returns (uint reducedBounty)
    {

        reducedBounty = bounty;
        uint getBountyDeadline = uint(nodes.getNodeLastRewardDate(nodeIndex))
            .add(constants.rewardPeriod())
            .add(constants.deltaPeriod());
        uint numberOfExpiredIntervals;
        if (now > getBountyDeadline) {
            numberOfExpiredIntervals = now.sub(getBountyDeadline).div(constants.checkTime());
        } else {
            numberOfExpiredIntervals = 0;
        }
        uint normalDowntime = uint(constants.rewardPeriod())
            .sub(constants.deltaPeriod())
            .div(constants.checkTime())
            .div(constants.DOWNTIME_THRESHOLD_PART());
        uint totalDowntime = downtime.add(numberOfExpiredIntervals);
        if (totalDowntime > normalDowntime) {
            uint penalty = bounty
                .mul(totalDowntime)
                .div(
                    uint(constants.rewardPeriod()).sub(constants.deltaPeriod())
                        .div(constants.checkTime())
                );
            if (bounty > penalty) {
                reducedBounty = bounty.sub(penalty);
            } else {
                reducedBounty = 0;
            }
        }
    }
}// AGPL-3.0-only


pragma solidity 0.6.10;


contract Decryption {


    function encrypt(uint256 secretNumber, bytes32 key) external pure returns (bytes32 ciphertext) {

        return bytes32(secretNumber) ^ key;
    }

    function decrypt(bytes32 ciphertext, bytes32 key) external pure returns (uint256 secretNumber) {

        return uint256(ciphertext ^ key);
    }
}
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


pragma solidity 0.6.10;


contract ECDH {

    using SafeMath for uint256;

    uint256 constant private _GX = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    uint256 constant private _GY = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
    uint256 constant private _N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
    uint256 constant private _A = 0;

    function publicKey(uint256 privKey) external pure returns (uint256 qx, uint256 qy) {

        uint256 x;
        uint256 y;
        uint256 z;
        (x, y, z) = ecMul(
            privKey,
            _GX,
            _GY,
            1
        );
        z = inverse(z);
        qx = mulmod(x, z, _N);
        qy = mulmod(y, z, _N);
    }

    function deriveKey(
        uint256 privKey,
        uint256 pubX,
        uint256 pubY
    )
        external
        pure
        returns (uint256 qx, uint256 qy)
    {

        uint256 x;
        uint256 y;
        uint256 z;
        (x, y, z) = ecMul(
            privKey,
            pubX,
            pubY,
            1
        );
        z = inverse(z);
        qx = mulmod(x, z, _N);
        qy = mulmod(y, z, _N);
    }

    function jAdd(
        uint256 x1,
        uint256 z1,
        uint256 x2,
        uint256 z2
    )
        public
        pure
        returns (uint256 x3, uint256 z3)
    {

        (x3, z3) = (addmod(mulmod(z2, x1, _N), mulmod(x2, z1, _N), _N), mulmod(z1, z2, _N));
    }

    function jSub(
        uint256 x1,
        uint256 z1,
        uint256 x2,
        uint256 z2
    )
        public
        pure
        returns (uint256 x3, uint256 z3)
    {

        (x3, z3) = (addmod(mulmod(z2, x1, _N), mulmod(_N.sub(x2), z1, _N), _N), mulmod(z1, z2, _N));
    }

    function jMul(
        uint256 x1,
        uint256 z1,
        uint256 x2,
        uint256 z2
    )
        public
        pure
        returns (uint256 x3, uint256 z3)
    {

        (x3, z3) = (mulmod(x1, x2, _N), mulmod(z1, z2, _N));
    }

    function jDiv(
        uint256 x1,
        uint256 z1,
        uint256 x2,
        uint256 z2
    )
        public
        pure
        returns (uint256 x3, uint256 z3)
    {

        (x3, z3) = (mulmod(x1, z2, _N), mulmod(z1, x2, _N));
    }

    function inverse(uint256 a) public pure returns (uint256 invA) {

        uint256 t = 0;
        uint256 newT = 1;
        uint256 r = _N;
        uint256 newR = a;
        uint256 q;
        while (newR != 0) {
            q = r.div(newR);
            (t, newT) = (newT, addmod(t, (_N.sub(mulmod(q, newT, _N))), _N));
            (r, newR) = (newR, r % newR);
        }
        return t;
    }

    function ecAdd(
        uint256 x1,
        uint256 y1,
        uint256 z1,
        uint256 x2,
        uint256 y2,
        uint256 z2
    )
        public
        pure
        returns (uint256 x3, uint256 y3, uint256 z3)
    {

        uint256 ln;
        uint256 lz;
        uint256 da;
        uint256 db;

        if ((x1 == 0) && (y1 == 0)) {
            return (x2, y2, z2);
        }

        if ((x2 == 0) && (y2 == 0)) {
            return (x1, y1, z1);
        }

        if ((x1 == x2) && (y1 == y2)) {
            (ln, lz) = jMul(x1, z1, x1, z1);
            (ln, lz) = jMul(ln,lz,3,1);
            (ln, lz) = jAdd(ln,lz,_A,1);
            (da, db) = jMul(y1,z1,2,1);
        } else {
            (ln, lz) = jSub(y2,z2,y1,z1);
            (da, db) = jSub(x2,z2,x1,z1);
        }
        (ln, lz) = jDiv(ln,lz,da,db);

        (x3, da) = jMul(ln,lz,ln,lz);
        (x3, da) = jSub(x3,da,x1,z1);
        (x3, da) = jSub(x3,da,x2,z2);

        (y3, db) = jSub(x1,z1,x3,da);
        (y3, db) = jMul(y3,db,ln,lz);
        (y3, db) = jSub(y3,db,y1,z1);

        if (da != db) {
            x3 = mulmod(x3, db, _N);
            y3 = mulmod(y3, da, _N);
            z3 = mulmod(da, db, _N);
        } else {
            z3 = da;
        }
    }

    function ecDouble(
        uint256 x1,
        uint256 y1,
        uint256 z1
    )
        public
        pure
        returns (uint256 x3, uint256 y3, uint256 z3)
    {

        (x3, y3, z3) = ecAdd(
            x1,
            y1,
            z1,
            x1,
            y1,
            z1
        );
    }

    function ecMul(
        uint256 d,
        uint256 x1,
        uint256 y1,
        uint256 z1
    )
        public
        pure
        returns (uint256 x3, uint256 y3, uint256 z3)
    {

        uint256 remaining = d;
        uint256 px = x1;
        uint256 py = y1;
        uint256 pz = z1;
        uint256 acx = 0;
        uint256 acy = 0;
        uint256 acz = 1;

        if (d == 0) {
            return (0, 0, 1);
        }

        while (remaining != 0) {
            if ((remaining & 1) != 0) {
                (acx, acy, acz) = ecAdd(
                    acx,
                    acy,
                    acz,
                    px,
                    py,
                    pz
                );
            }
            remaining = remaining.div(2);
            (px, py, pz) = ecDouble(px, py, pz);
        }

        (x3, y3, z3) = (acx, acy, acz);
    }
}


pragma solidity 0.6.10;


library Precompiled {


    function bigModExp(uint base, uint power, uint modulus) internal view returns (uint) {

        uint[6] memory inputToBigModExp;
        inputToBigModExp[0] = 32;
        inputToBigModExp[1] = 32;
        inputToBigModExp[2] = 32;
        inputToBigModExp[3] = base;
        inputToBigModExp[4] = power;
        inputToBigModExp[5] = modulus;
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(not(0), 5, inputToBigModExp, mul(6, 0x20), out, 0x20)
        }
        require(success, "BigModExp failed");
        return out[0];
    }

    function bn256ScalarMul(uint x, uint y, uint k) internal view returns (uint , uint ) {

        uint[3] memory inputToMul;
        uint[2] memory output;
        inputToMul[0] = x;
        inputToMul[1] = y;
        inputToMul[2] = k;
        bool success;
        assembly {
            success := staticcall(not(0), 7, inputToMul, 0x60, output, 0x40)
        }
        require(success, "Multiplication failed");
        return (output[0], output[1]);
    }

    function bn256Pairing(
        uint x1,
        uint y1,
        uint a1,
        uint b1,
        uint c1,
        uint d1,
        uint x2,
        uint y2,
        uint a2,
        uint b2,
        uint c2,
        uint d2)
        internal view returns (bool)
    {

        bool success;
        uint[12] memory inputToPairing;
        inputToPairing[0] = x1;
        inputToPairing[1] = y1;
        inputToPairing[2] = a1;
        inputToPairing[3] = b1;
        inputToPairing[4] = c1;
        inputToPairing[5] = d1;
        inputToPairing[6] = x2;
        inputToPairing[7] = y2;
        inputToPairing[8] = a2;
        inputToPairing[9] = b2;
        inputToPairing[10] = c2;
        inputToPairing[11] = d2;
        uint[1] memory out;
        assembly {
            success := staticcall(not(0), 8, inputToPairing, mul(12, 0x20), out, 0x20)
        }
        require(success, "Pairing check failed");
        return out[0] != 0;
    }
}// AGPL-3.0-only


pragma solidity 0.6.10;




library Fp2Operations {

    using SafeMath for uint;

    struct Fp2Point {
        uint a;
        uint b;
    }

    uint constant public P = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    function addFp2(Fp2Point memory value1, Fp2Point memory value2) internal pure returns (Fp2Point memory) {

        return Fp2Point({ a: addmod(value1.a, value2.a, P), b: addmod(value1.b, value2.b, P) });
    }

    function scalarMulFp2(Fp2Point memory value, uint scalar) internal pure returns (Fp2Point memory) {

        return Fp2Point({ a: mulmod(scalar, value.a, P), b: mulmod(scalar, value.b, P) });
    }

    function minusFp2(Fp2Point memory diminished, Fp2Point memory subtracted) internal pure
        returns (Fp2Point memory difference)
    {

        uint p = P;
        if (diminished.a >= subtracted.a) {
            difference.a = addmod(diminished.a, p - (subtracted.a), p);
        } else {
            difference.a = p - (addmod(subtracted.a, p - (diminished.a), p));
        }
        if (diminished.b >= subtracted.b) {
            difference.b = addmod(diminished.b, p - (subtracted.b), p);
        } else {
            difference.b = p - (addmod(subtracted.b, p - (diminished.b), p));
        }
    }

    function mulFp2(
        Fp2Point memory value1,
        Fp2Point memory value2
    )
        internal
        pure
        returns (Fp2Point memory result)
    {

        uint p = P;
        Fp2Point memory point = Fp2Point({
            a: mulmod(value1.a, value2.a, p),
            b: mulmod(value1.b, value2.b, p)});
        result.a = addmod(
            point.a,
            mulmod(p - 1, point.b, p),
            p);
        result.b = addmod(
            mulmod(
                addmod(value1.a, value1.b, p),
                addmod(value2.a, value2.b, p),
                p),
            p - addmod(point.a, point.b, p),
            p);
    }

    function squaredFp2(Fp2Point memory value) internal pure returns (Fp2Point memory) {

        uint p = P;
        uint ab = mulmod(value.a, value.b, p);
        uint mult = mulmod(addmod(value.a, value.b, p), addmod(value.a, mulmod(p - 1, value.b, p), p), p);
        return Fp2Point({ a: mult, b: addmod(ab, ab, p) });
    }

    function inverseFp2(Fp2Point memory value) internal view returns (Fp2Point memory result) {

        uint p = P;
        uint t0 = mulmod(value.a, value.a, p);
        uint t1 = mulmod(value.b, value.b, p);
        uint t2 = mulmod(p - 1, t1, p);
        if (t0 >= t2) {
            t2 = addmod(t0, p - t2, p);
        } else {
            t2 = p - addmod(t2, p - t0, p);
        }
        uint t3 = Precompiled.bigModExp(t2, p - 2, p);
        result.a = mulmod(value.a, t3, p);
        result.b = p - mulmod(value.b, t3, p);
    }

    function isEqual(
        Fp2Point memory value1,
        Fp2Point memory value2
    )
        internal
        pure
        returns (bool)
    {

        return value1.a == value2.a && value1.b == value2.b;
    }
}


library G2Operations {

    using SafeMath for uint;
    using Fp2Operations for Fp2Operations.Fp2Point;

    struct G2Point {
        Fp2Operations.Fp2Point x;
        Fp2Operations.Fp2Point y;
    }

    function getTWISTB() internal pure returns (Fp2Operations.Fp2Point memory) {

        return Fp2Operations.Fp2Point({
            a: 19485874751759354771024239261021720505790618469301721065564631296452457478373,
            b: 266929791119991161246907387137283842545076965332900288569378510910307636690
        });
    }

    function getG2() internal pure returns (G2Point memory) {

        return G2Point({
            x: Fp2Operations.Fp2Point({
                a: 10857046999023057135944570762232829481370756359578518086990519993285655852781,
                b: 11559732032986387107991004021392285783925812861821192530917403151452391805634
            }),
            y: Fp2Operations.Fp2Point({
                a: 8495653923123431417604973247489272438418190587263600148770280649306958101930,
                b: 4082367875863433681332203403145435568316851327593401208105741076214120093531
            })
        });
    }

    function getG1() internal pure returns (Fp2Operations.Fp2Point memory) {

        return Fp2Operations.Fp2Point({
            a: 1,
            b: 2
        });
    }

    function getG2Zero() internal pure returns (G2Point memory) {

        return G2Point({
            x: Fp2Operations.Fp2Point({
                a: 0,
                b: 0
            }),
            y: Fp2Operations.Fp2Point({
                a: 1,
                b: 0
            })
        });
    }

    function isG1Point(uint x, uint y) internal pure returns (bool) {

        uint p = Fp2Operations.P;
        return mulmod(y, y, p) == 
            addmod(mulmod(mulmod(x, x, p), x, p), 3, p);
    }
    function isG1(Fp2Operations.Fp2Point memory point) internal pure returns (bool) {

        return isG1Point(point.a, point.b);
    }

    function isG2Point(Fp2Operations.Fp2Point memory x, Fp2Operations.Fp2Point memory y) internal pure returns (bool) {

        if (isG2ZeroPoint(x, y)) {
            return true;
        }
        Fp2Operations.Fp2Point memory squaredY = y.squaredFp2();
        Fp2Operations.Fp2Point memory res = squaredY.minusFp2(
                x.squaredFp2().mulFp2(x)
            ).minusFp2(getTWISTB());
        return res.a == 0 && res.b == 0;
    }

    function isG2(G2Point memory value) internal pure returns (bool) {

        return isG2Point(value.x, value.y);
    }

    function isG2ZeroPoint(
        Fp2Operations.Fp2Point memory x,
        Fp2Operations.Fp2Point memory y
    )
        internal
        pure
        returns (bool)
    {

        return x.a == 0 && x.b == 0 && y.a == 1 && y.b == 0;
    }

    function isG2Zero(G2Point memory value) internal pure returns (bool) {

        return value.x.a == 0 && value.x.b == 0 && value.y.a == 1 && value.y.b == 0;
    }

    function addG2(
        G2Point memory value1,
        G2Point memory value2
    )
        internal
        view
        returns (G2Point memory sum)
    {

        if (isG2Zero(value1)) {
            return value2;
        }
        if (isG2Zero(value2)) {
            return value1;
        }
        if (isEqual(value1, value2)) {
            return doubleG2(value1);
        }

        Fp2Operations.Fp2Point memory s = value2.y.minusFp2(value1.y).mulFp2(value2.x.minusFp2(value1.x).inverseFp2());
        sum.x = s.squaredFp2().minusFp2(value1.x.addFp2(value2.x));
        sum.y = value1.y.addFp2(s.mulFp2(sum.x.minusFp2(value1.x)));
        uint p = Fp2Operations.P;
        sum.y.a = p - sum.y.a;
        sum.y.b = p - sum.y.b;
    }

    function toUS(G2Point memory value) internal pure returns (G2Point memory) {

        return G2Point({
            x: value.x.mulFp2(Fp2Operations.Fp2Point({ a: 1, b: 0 }).squaredFp2()),
            y: value.y.mulFp2(
                Fp2Operations.Fp2Point({ a: 1, b: 0 }).mulFp2(Fp2Operations.Fp2Point({ a: 1, b: 0 }).squaredFp2())
            )
        });
    }

    function isEqual(
        G2Point memory value1,
        G2Point memory value2
    )
        internal
        pure
        returns (bool)
    {

        return value1.x.isEqual(value2.x) && value1.y.isEqual(value2.y);
    }

    function doubleG2(G2Point memory value)
        internal
        view
        returns (G2Point memory result)
    {

        if (isG2Zero(value)) {
            return value;
        } else {
            Fp2Operations.Fp2Point memory s =
                value.x.squaredFp2().scalarMulFp2(3).mulFp2(value.y.scalarMulFp2(2).inverseFp2());
            result.x = s.squaredFp2().minusFp2(value.x.addFp2(value.x));
            result.y = value.y.addFp2(s.mulFp2(result.x.minusFp2(value.x)));
            uint p = Fp2Operations.P;
            result.y.a = p - result.y.a;
            result.y.b = p - result.y.b;
        }
    }

    function mulG2(
        G2Point memory value,
        uint scalar
    )
        internal
        view
        returns (G2Point memory result)
    {

        uint step = scalar;
        result = G2Point({
            x: Fp2Operations.Fp2Point({
                a: 0,
                b: 0
            }),
            y: Fp2Operations.Fp2Point({
                a: 1,
                b: 0
            })
        });
        G2Point memory tmp = value;
        uint gs = gasleft();
        while (step > 0) {
            if (step % 2 == 1) {
                result = addG2(result, tmp);
            }
            gs = gasleft();
            tmp = doubleG2(tmp);
            step >>= 1;
        }
    }
}// AGPL-3.0-only


pragma solidity 0.6.10;

interface ISkaleDKG {

    function openChannel(bytes32 schainId) external;

    function deleteChannel(bytes32 schainId) external;

    function isLastDKGSuccesful(bytes32 groupIndex) external view returns (bool);

    function isChannelOpened(bytes32 schainId) external view returns (bool);

}// AGPL-3.0-only


pragma solidity 0.6.10;


contract SchainsInternal is Permissions {


    struct Schain {
        string name;
        address owner;
        uint indexInOwnerList;
        uint8 partOfNode;
        uint lifetime;
        uint startDate;
        uint startBlock;
        uint deposit;
        uint64 index;
    }


    mapping (bytes32 => Schain) public schains;

    mapping (bytes32 => bool) public isSchainActive;

    mapping (bytes32 => uint[]) public schainsGroups;

    mapping (bytes32 => mapping (uint => bool)) private _exceptionsForGroups;
    mapping (address => bytes32[]) public schainIndexes;
    mapping (uint => bytes32[]) public schainsForNodes;

    mapping (uint => uint[]) public holesForNodes;

    mapping (bytes32 => uint[]) public holesForSchains;



    bytes32[] public schainsAtSystem;

    uint64 public numberOfSchains;
    uint public sumOfSchainsResources;

    function initializeSchain(
        string calldata name,
        address from,
        uint lifetime,
        uint deposit) external allow("Schains")
    {

        bytes32 schainId = keccak256(abi.encodePacked(name));
        schains[schainId].name = name;
        schains[schainId].owner = from;
        schains[schainId].startDate = block.timestamp;
        schains[schainId].startBlock = block.number;
        schains[schainId].lifetime = lifetime;
        schains[schainId].deposit = deposit;
        schains[schainId].index = numberOfSchains;
        isSchainActive[schainId] = true;
        numberOfSchains++;
        schainsAtSystem.push(schainId);
    }

    function createGroupForSchain(
        bytes32 schainId,
        uint numberOfNodes,
        uint8 partOfNode
    )
        external
        allow("Schains")
        returns (uint[] memory)
    {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        schains[schainId].partOfNode = partOfNode;
        if (partOfNode > 0) {
            sumOfSchainsResources = sumOfSchainsResources.add(
                numberOfNodes.mul(constantsHolder.TOTAL_SPACE_ON_NODE()).div(partOfNode)
            );
        }
        return _generateGroup(schainId, numberOfNodes);
    }

    function setSchainIndex(bytes32 schainId, address from) external allow("Schains") {

        schains[schainId].indexInOwnerList = schainIndexes[from].length;
        schainIndexes[from].push(schainId);
    }

    function changeLifetime(bytes32 schainId, uint lifetime, uint deposit) external allow("Schains") {

        schains[schainId].deposit = schains[schainId].deposit.add(deposit);
        schains[schainId].lifetime = schains[schainId].lifetime.add(lifetime);
    }

    function removeSchain(bytes32 schainId, address from) external allow("Schains") {

        isSchainActive[schainId] = false;
        uint length = schainIndexes[from].length;
        uint index = schains[schainId].indexInOwnerList;
        if (index != length.sub(1)) {
            bytes32 lastSchainId = schainIndexes[from][length.sub(1)];
            schains[lastSchainId].indexInOwnerList = index;
            schainIndexes[from][index] = lastSchainId;
        }
        schainIndexes[from].pop();

        for (uint i = 0; i + 1 < schainsAtSystem.length; i++) {
            if (schainsAtSystem[i] == schainId) {
                schainsAtSystem[i] = schainsAtSystem[schainsAtSystem.length.sub(1)];
                break;
            }
        }
        schainsAtSystem.pop();

        delete schains[schainId];
        numberOfSchains--;
    }

    function removeNodeFromSchain(
        uint nodeIndex,
        bytes32 schainHash
    )
        external
        allowThree("NodeRotation", "SkaleDKG", "Schains")
    {

        uint indexOfNode = _findNode(schainHash, nodeIndex);
        uint indexOfLastNode = schainsGroups[schainHash].length.sub(1);

        if (indexOfNode == indexOfLastNode) {
            schainsGroups[schainHash].pop();
        } else {
            delete schainsGroups[schainHash][indexOfNode];
            if (holesForSchains[schainHash].length > 0 && holesForSchains[schainHash][0] > indexOfNode) {
                uint hole = holesForSchains[schainHash][0];
                holesForSchains[schainHash][0] = indexOfNode;
                holesForSchains[schainHash].push(hole);
            } else {
                holesForSchains[schainHash].push(indexOfNode);
            }
        }

        uint schainId = findSchainAtSchainsForNode(nodeIndex, schainHash);
        removeSchainForNode(nodeIndex, schainId);
    }

    function removeNodeFromExceptions(bytes32 schainHash, uint nodeIndex) external allow("Schains") {

        _exceptionsForGroups[schainHash][nodeIndex] = false;
    }

    function deleteGroup(bytes32 schainId) external allow("Schains") {

        ISkaleDKG skaleDKG = ISkaleDKG(contractManager.getContract("SkaleDKG"));

        delete schainsGroups[schainId];
        if (skaleDKG.isChannelOpened(schainId)) {
            skaleDKG.deleteChannel(schainId);
        }
    }

    function setException(bytes32 schainId, uint nodeIndex) external allowTwo("Schains", "NodeRotation") {

        _exceptionsForGroups[schainId][nodeIndex] = true;
    }

    function setNodeInGroup(bytes32 schainId, uint nodeIndex) external allowTwo("Schains", "NodeRotation") {

        if (holesForSchains[schainId].length == 0) {
            schainsGroups[schainId].push(nodeIndex);
        } else {
            schainsGroups[schainId][holesForSchains[schainId][0]] = nodeIndex;
            uint min = uint(-1);
            uint index = 0;
            for (uint i = 1; i < holesForSchains[schainId].length; i++) {
                if (min > holesForSchains[schainId][i]) {
                    min = holesForSchains[schainId][i];
                    index = i;
                }
            }
            if (min == uint(-1)) {
                delete holesForSchains[schainId];
            } else {
                holesForSchains[schainId][0] = min;
                holesForSchains[schainId][index] =
                    holesForSchains[schainId][holesForSchains[schainId].length - 1];
                holesForSchains[schainId].pop();
            }
        }
    }

    function removeHolesForSchain(bytes32 schainHash) external allow("Schains") {

        delete holesForSchains[schainHash];
    }

    function getSchains() external view returns (bytes32[] memory) {

        return schainsAtSystem;
    }

    function getSchainsPartOfNode(bytes32 schainId) external view returns (uint8) {

        return schains[schainId].partOfNode;
    }

    function getSchainListSize(address from) external view returns (uint) {

        return schainIndexes[from].length;
    }

    function getSchainIdsByAddress(address from) external view returns (bytes32[] memory) {

        return schainIndexes[from];
    }

    function getSchainIdsForNode(uint nodeIndex) external view returns (bytes32[] memory) {

        return schainsForNodes[nodeIndex];
    }

    function getSchainOwner(bytes32 schainId) external view returns (address) {

        return schains[schainId].owner;
    }

    function isSchainNameAvailable(string calldata name) external view returns (bool) {

        bytes32 schainId = keccak256(abi.encodePacked(name));
        return schains[schainId].owner == address(0);
    }

    function isTimeExpired(bytes32 schainId) external view returns (bool) {

        return uint(schains[schainId].startDate).add(schains[schainId].lifetime) < block.timestamp;
    }

    function isOwnerAddress(address from, bytes32 schainId) external view returns (bool) {

        return schains[schainId].owner == from;
    }

    function isSchainExist(bytes32 schainId) external view returns (bool) {

        return keccak256(abi.encodePacked(schains[schainId].name)) != keccak256(abi.encodePacked(""));
    }

    function getSchainName(bytes32 schainId) external view returns (string memory) {

        return schains[schainId].name;
    }

    function getActiveSchain(uint nodeIndex) external view returns (bytes32) {

        for (uint i = schainsForNodes[nodeIndex].length; i > 0; i--) {
            if (schainsForNodes[nodeIndex][i - 1] != bytes32(0)) {
                return schainsForNodes[nodeIndex][i - 1];
            }
        }
        return bytes32(0);
    }

    function getActiveSchains(uint nodeIndex) external view returns (bytes32[] memory activeSchains) {

        uint activeAmount = 0;
        for (uint i = 0; i < schainsForNodes[nodeIndex].length; i++) {
            if (schainsForNodes[nodeIndex][i] != bytes32(0)) {
                activeAmount++;
            }
        }

        uint cursor = 0;
        activeSchains = new bytes32[](activeAmount);
        for (uint i = schainsForNodes[nodeIndex].length; i > 0; i--) {
            if (schainsForNodes[nodeIndex][i - 1] != bytes32(0)) {
                activeSchains[cursor++] = schainsForNodes[nodeIndex][i - 1];
            }
        }
    }

    function getNumberOfNodesInGroup(bytes32 schainId) external view returns (uint) {

        return schainsGroups[schainId].length;
    }

    function getNodesInGroup(bytes32 schainId) external view returns (uint[] memory) {

        return schainsGroups[schainId];
    }

    function getNodeIndexInGroup(bytes32 schainId, uint nodeId) external view returns (uint) {

        for (uint index = 0; index < schainsGroups[schainId].length; index++) {
            if (schainsGroups[schainId][index] == nodeId) {
                return index;
            }
        }
        return schainsGroups[schainId].length;
    }

    function isAnyFreeNode(bytes32 schainId) external view returns (bool) {

        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        uint8 space = schains[schainId].partOfNode;
        uint[] memory nodesWithFreeSpace = nodes.getNodesWithFreeSpace(space);
        for (uint i = 0; i < nodesWithFreeSpace.length; i++) {
            if (_isCorrespond(schainId, nodesWithFreeSpace[i])) {
                return true;
            }
        }
        return false;
    }

    function checkException(bytes32 schainId, uint nodeIndex) external view returns (bool) {

        return _exceptionsForGroups[schainId][nodeIndex];
    }

    function checkHoleForSchain(bytes32 schainHash, uint indexOfNode) external view returns (bool) {

        for (uint i = 0; i < holesForSchains[schainHash].length; i++) {
            if (holesForSchains[schainHash][i] == indexOfNode) {
                return true;
            }
        }
        return false;
    }

    function initialize(address newContractsAddress) public override initializer {

        Permissions.initialize(newContractsAddress);

        numberOfSchains = 0;
        sumOfSchainsResources = 0;
    }

    function addSchainForNode(uint nodeIndex, bytes32 schainId) public allowTwo("Schains", "NodeRotation") {

        if (holesForNodes[nodeIndex].length == 0) {
            schainsForNodes[nodeIndex].push(schainId);
        } else {
            schainsForNodes[nodeIndex][holesForNodes[nodeIndex][0]] = schainId;
            uint min = uint(-1);
            uint index = 0;
            for (uint i = 1; i < holesForNodes[nodeIndex].length; i++) {
                if (min > holesForNodes[nodeIndex][i]) {
                    min = holesForNodes[nodeIndex][i];
                    index = i;
                }
            }
            if (min == uint(-1)) {
                delete holesForNodes[nodeIndex];
            } else {
                holesForNodes[nodeIndex][0] = min;
                holesForNodes[nodeIndex][index] = holesForNodes[nodeIndex][holesForNodes[nodeIndex].length - 1];
                holesForNodes[nodeIndex].pop();
            }
        }
    }

    function removeSchainForNode(uint nodeIndex, uint schainIndex)
        public
        allowThree("NodeRotation", "SkaleDKG", "Schains")
    {

        uint length = schainsForNodes[nodeIndex].length;
        if (schainIndex == length.sub(1)) {
            schainsForNodes[nodeIndex].pop();
        } else {
            schainsForNodes[nodeIndex][schainIndex] = bytes32(0);
            if (holesForNodes[nodeIndex].length > 0 && holesForNodes[nodeIndex][0] > schainIndex) {
                uint hole = holesForNodes[nodeIndex][0];
                holesForNodes[nodeIndex][0] = schainIndex;
                holesForNodes[nodeIndex].push(hole);
            } else {
                holesForNodes[nodeIndex].push(schainIndex);
            }
        }
    }

    function getLengthOfSchainsForNode(uint nodeIndex) public view returns (uint) {

        return schainsForNodes[nodeIndex].length;
    }

    function findSchainAtSchainsForNode(uint nodeIndex, bytes32 schainId) public view returns (uint) {

        uint length = getLengthOfSchainsForNode(nodeIndex);
        for (uint i = 0; i < length; i++) {
            if (schainsForNodes[nodeIndex][i] == schainId) {
                return i;
            }
        }
        return length;
    }

    function isEnoughNodes(bytes32 schainId) public view returns (uint[] memory result) {

        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        uint8 space = schains[schainId].partOfNode;
        uint[] memory nodesWithFreeSpace = nodes.getNodesWithFreeSpace(space);
        uint counter = 0;
        for (uint i = 0; i < nodesWithFreeSpace.length; i++) {
            if (!_isCorrespond(schainId, nodesWithFreeSpace[i])) {
                counter++;
            }
        }
        if (counter < nodesWithFreeSpace.length) {
            result = new uint[](nodesWithFreeSpace.length.sub(counter));
            counter = 0;
            for (uint i = 0; i < nodesWithFreeSpace.length; i++) {
                if (_isCorrespond(schainId, nodesWithFreeSpace[i])) {
                    result[counter] = nodesWithFreeSpace[i];
                    counter++;
                }
            }
        }
    }

    function _generateGroup(bytes32 schainId, uint numberOfNodes) private returns (uint[] memory nodesInGroup) {

        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        uint8 space = schains[schainId].partOfNode;
        nodesInGroup = new uint[](numberOfNodes);

        uint[] memory possibleNodes = isEnoughNodes(schainId);
        require(possibleNodes.length >= nodesInGroup.length, "Not enough nodes to create Schain");
        uint ignoringTail = 0;
        uint random = uint(keccak256(abi.encodePacked(uint(blockhash(block.number.sub(1))), schainId)));
        for (uint i = 0; i < nodesInGroup.length; ++i) {
            uint index = random % (possibleNodes.length.sub(ignoringTail));
            uint node = possibleNodes[index];
            nodesInGroup[i] = node;
            _swap(possibleNodes, index, possibleNodes.length.sub(ignoringTail).sub(1));
            ++ignoringTail;

            _exceptionsForGroups[schainId][node] = true;
            addSchainForNode(node, schainId);
            require(nodes.removeSpaceFromNode(node, space), "Could not remove space from Node");
        }

        schainsGroups[schainId] = nodesInGroup;
    }

    function _isCorrespond(bytes32 schainId, uint nodeIndex) private view returns (bool) {

        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        return !_exceptionsForGroups[schainId][nodeIndex] && nodes.isNodeActive(nodeIndex);
    }

    function _swap(uint[] memory array, uint index1, uint index2) private pure {

        uint buffer = array[index1];
        array[index1] = array[index2];
        array[index2] = buffer;
    }

    function _findNode(bytes32 schainId, uint nodeIndex) private view returns (uint) {

        uint[] memory nodesInGroup = schainsGroups[schainId];
        uint index;
        for (index = 0; index < nodesInGroup.length; index++) {
            if (nodesInGroup[index] == nodeIndex) {
                return index;
            }
        }
        return index;
    }

}


pragma solidity 0.6.10;

contract KeyStorage is Permissions {

    using Fp2Operations for Fp2Operations.Fp2Point;
    using G2Operations for G2Operations.G2Point;

    struct BroadcastedData {
        KeyShare[] secretKeyContribution;
        G2Operations.G2Point[] verificationVector;
    }

    struct KeyShare {
        bytes32[2] publicKey;
        bytes32 share;
    }

    mapping(bytes32 => mapping(uint => BroadcastedData)) private _data;
    mapping(bytes32 => G2Operations.G2Point) private _publicKeysInProgress;
    mapping(bytes32 => G2Operations.G2Point) private _schainsPublicKeys;
    mapping(bytes32 => G2Operations.G2Point[]) private _schainsNodesPublicKeys;
    mapping(bytes32 => G2Operations.G2Point[]) private _previousSchainsPublicKeys;

    function addBroadcastedData(
        bytes32 groupIndex,
        uint indexInSchain,
        KeyShare[] memory secretKeyContribution,
        G2Operations.G2Point[] memory verificationVector
    )
        external
        allow("SkaleDKG")
    {

        for (uint i = 0; i < secretKeyContribution.length; ++i) {
            if (i < _data[groupIndex][indexInSchain].secretKeyContribution.length) {
                _data[groupIndex][indexInSchain].secretKeyContribution[i] = secretKeyContribution[i];
            } else {
                _data[groupIndex][indexInSchain].secretKeyContribution.push(secretKeyContribution[i]);
            }
        }
        while (_data[groupIndex][indexInSchain].secretKeyContribution.length > secretKeyContribution.length) {
            _data[groupIndex][indexInSchain].secretKeyContribution.pop();
        }

        for (uint i = 0; i < verificationVector.length; ++i) {
            if (i < _data[groupIndex][indexInSchain].verificationVector.length) {
                _data[groupIndex][indexInSchain].verificationVector[i] = verificationVector[i];
            } else {
                _data[groupIndex][indexInSchain].verificationVector.push(verificationVector[i]);
            }
        }
        while (_data[groupIndex][indexInSchain].verificationVector.length > verificationVector.length) {
            _data[groupIndex][indexInSchain].verificationVector.pop();
        }
    }

    function deleteKey(bytes32 groupIndex) external allow("SkaleDKG") {

        _previousSchainsPublicKeys[groupIndex].push(_schainsPublicKeys[groupIndex]);
        delete _schainsPublicKeys[groupIndex];
    }

    function initPublicKeyInProgress(bytes32 groupIndex) external allow("SkaleDKG") {

        _publicKeysInProgress[groupIndex] = G2Operations.getG2Zero();
        delete _schainsNodesPublicKeys[groupIndex];
    }

    function adding(bytes32 groupIndex, G2Operations.G2Point memory value) external allow("SkaleDKG") {

        require(value.isG2(), "Incorrect g2 point");
        _publicKeysInProgress[groupIndex] = value.addG2(_publicKeysInProgress[groupIndex]);
    }

    function finalizePublicKey(bytes32 groupIndex) external allow("SkaleDKG") {

        if (!_isSchainsPublicKeyZero(groupIndex)) {
            _previousSchainsPublicKeys[groupIndex].push(_schainsPublicKeys[groupIndex]);
        }
        _schainsPublicKeys[groupIndex] = _publicKeysInProgress[groupIndex];
        delete _publicKeysInProgress[groupIndex];
    }

    function computePublicValues(bytes32 groupIndex, G2Operations.G2Point[] calldata verificationVector)
        external
        allow("SkaleDKG")
    {

        if (_schainsNodesPublicKeys[groupIndex].length == 0) {

            for (uint i = 0; i < verificationVector.length; ++i) {
                require(verificationVector[i].isG2(), "Incorrect g2 point verVec 1");

                G2Operations.G2Point memory tmp = verificationVector[i];
                _schainsNodesPublicKeys[groupIndex].push(tmp);

                require(_schainsNodesPublicKeys[groupIndex][i].isG2(), "Incorrect g2 point schainNodesPubKey 1");
            }

            while (_schainsNodesPublicKeys[groupIndex].length > verificationVector.length) {
                _schainsNodesPublicKeys[groupIndex].pop();
            }
        } else {
            require(_schainsNodesPublicKeys[groupIndex].length == verificationVector.length, "Incorrect length");

            for (uint i = 0; i < _schainsNodesPublicKeys[groupIndex].length; ++i) {
                require(verificationVector[i].isG2(), "Incorrect g2 point verVec 2");
                require(_schainsNodesPublicKeys[groupIndex][i].isG2(), "Incorrect g2 point schainNodesPubKey 2");

                _schainsNodesPublicKeys[groupIndex][i] = verificationVector[i].addG2(
                    _schainsNodesPublicKeys[groupIndex][i]
                );

                require(_schainsNodesPublicKeys[groupIndex][i].isG2(), "Incorrect g2 point addition");
            }

        }
    }

    function verify(
        bytes32 groupIndex,
        uint nodeToComplaint,
        uint fromNodeToComplaint,
        uint secretNumber,
        G2Operations.G2Point memory multipliedShare
    )
        external
        view
        returns (bool)
    {

        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        uint index = schainsInternal.getNodeIndexInGroup(groupIndex, nodeToComplaint);
        uint secret = _decryptMessage(groupIndex, secretNumber, nodeToComplaint, fromNodeToComplaint);

        G2Operations.G2Point[] memory verificationVector = _data[groupIndex][index].verificationVector;
        G2Operations.G2Point memory value = G2Operations.getG2Zero();
        G2Operations.G2Point memory tmp = G2Operations.getG2Zero();

        if (multipliedShare.isG2()) {
            for (uint i = 0; i < verificationVector.length; i++) {
                tmp = verificationVector[i].mulG2(index.add(1) ** i);
                value = tmp.addG2(value);
            }
            return value.isEqual(multipliedShare) &&
                _checkCorrectMultipliedShare(multipliedShare, secret);
        }
        return false;
    }

    function getBroadcastedData(bytes32 groupIndex, uint nodeIndex)
        external
        view
        returns (KeyShare[] memory, G2Operations.G2Point[] memory)
    {

        uint indexInSchain = SchainsInternal(contractManager.getContract("SchainsInternal")).getNodeIndexInGroup(
            groupIndex,
            nodeIndex
        );
        if (
            _data[groupIndex][indexInSchain].secretKeyContribution.length == 0 &&
            _data[groupIndex][indexInSchain].verificationVector.length == 0
        ) {
            KeyShare[] memory keyShare = new KeyShare[](0);
            G2Operations.G2Point[] memory g2Point = new G2Operations.G2Point[](0);
            return (keyShare, g2Point);
        }
        return (
            _data[groupIndex][indexInSchain].secretKeyContribution,
            _data[groupIndex][indexInSchain].verificationVector
        );
    }

    function getSecretKeyShare(bytes32 groupIndex, uint nodeIndex, uint index)
        external
        view
        returns (bytes32)
    {

        uint indexInSchain = SchainsInternal(contractManager.getContract("SchainsInternal")).getNodeIndexInGroup(
            groupIndex,
            nodeIndex
        );
        return (_data[groupIndex][indexInSchain].secretKeyContribution[index].share);
    }

    function getVerificationVector(bytes32 groupIndex, uint nodeIndex)
        external
        view
        returns (G2Operations.G2Point[] memory)
    {

        uint indexInSchain = SchainsInternal(contractManager.getContract("SchainsInternal")).getNodeIndexInGroup(
            groupIndex,
            nodeIndex
        );
        return (_data[groupIndex][indexInSchain].verificationVector);
    }

    function getCommonPublicKey(bytes32 groupIndex) external view returns (G2Operations.G2Point memory) {

        return _schainsPublicKeys[groupIndex];
    }

    function getPreviousPublicKey(bytes32 groupIndex) external view returns (G2Operations.G2Point memory) {

        uint length = _previousSchainsPublicKeys[groupIndex].length;
        if (length == 0) {
            return G2Operations.getG2Zero();
        }
        return _previousSchainsPublicKeys[groupIndex][length - 1];
    }

    function getAllPreviousPublicKeys(bytes32 groupIndex) external view returns (G2Operations.G2Point[] memory) {

        return _previousSchainsPublicKeys[groupIndex];
    }

    function getBLSPublicKey(bytes32 groupIndex, uint nodeIndex) external view returns (G2Operations.G2Point memory) {

        uint index = SchainsInternal(contractManager.getContract("SchainsInternal")).getNodeIndexInGroup(
            groupIndex,
            nodeIndex
        );
        return _calculateBlsPublicKey(groupIndex, index);
    }

    function initialize(address contractsAddress) public override initializer {

        Permissions.initialize(contractsAddress);
    }

    function _calculateBlsPublicKey(bytes32 groupIndex, uint index)
        private
        view
        returns (G2Operations.G2Point memory)
    {

        G2Operations.G2Point memory publicKey = G2Operations.getG2Zero();
        G2Operations.G2Point memory tmp = G2Operations.getG2Zero();
        G2Operations.G2Point[] memory publicValues = _schainsNodesPublicKeys[groupIndex];
        for (uint i = 0; i < publicValues.length; ++i) {
            require(publicValues[i].isG2(), "Incorrect g2 point publicValuesComponent");
            tmp = publicValues[i].mulG2(Precompiled.bigModExp(index.add(1), i, Fp2Operations.P));
            require(tmp.isG2(), "Incorrect g2 point tmp");
            publicKey = tmp.addG2(publicKey);
            require(publicKey.isG2(), "Incorrect g2 point publicKey");
        }
        return publicKey;
    }

    function _isSchainsPublicKeyZero(bytes32 schainId) private view returns (bool) {

        return _schainsPublicKeys[schainId].x.a == 0 &&
            _schainsPublicKeys[schainId].x.b == 0 &&
            _schainsPublicKeys[schainId].y.a == 0 &&
            _schainsPublicKeys[schainId].y.b == 0;
    }

    function _getCommonPublicKey(
        uint256 secretNumber,
        uint fromNodeToComplaint
    )
        private
        view
        returns (bytes32)
    {

        bytes32[2] memory publicKey = Nodes(contractManager.getContract("Nodes")).getNodePublicKey(fromNodeToComplaint);
        uint256 pkX = uint(publicKey[0]);

        (pkX, ) = ECDH(contractManager.getContract("ECDH")).deriveKey(secretNumber, pkX, uint(publicKey[1]));

        return bytes32(pkX);
    }

    function _decryptMessage(
        bytes32 groupIndex,
        uint secretNumber,
        uint nodeToComplaint,
        uint fromNodeToComplaint
    )
        private
        view
        returns (uint)
    {


        bytes32 key = _getCommonPublicKey(secretNumber, fromNodeToComplaint);

        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        uint index = schainsInternal.getNodeIndexInGroup(groupIndex, fromNodeToComplaint);
        uint indexOfNode = schainsInternal.getNodeIndexInGroup(groupIndex, nodeToComplaint);
        uint secret = Decryption(contractManager.getContract("Decryption")).decrypt(
            _data[groupIndex][indexOfNode].secretKeyContribution[index].share,
            key
        );
        return secret;
    }

    function _checkCorrectMultipliedShare(G2Operations.G2Point memory multipliedShare, uint secret)
        private view returns (bool)
    {

        G2Operations.G2Point memory tmp = multipliedShare;
        Fp2Operations.Fp2Point memory g1 = G2Operations.getG1();
        Fp2Operations.Fp2Point memory share = Fp2Operations.Fp2Point({
            a: 0,
            b: 0
        });
        (share.a, share.b) = Precompiled.bn256ScalarMul(g1.a, g1.b, secret);
        if (!(share.a == 0 && share.b == 0)) {
            share.b = Fp2Operations.P.sub((share.b % Fp2Operations.P));
        }

        require(G2Operations.isG1(share), "mulShare not in G1");

        G2Operations.G2Point memory g2 = G2Operations.getG2();
        require(G2Operations.isG2(tmp), "tmp not in g2");

        return Precompiled.bn256Pairing(
            share.a, share.b,
            g2.x.b, g2.x.a, g2.y.b, g2.y.a,
            g1.a, g1.b,
            tmp.x.b, tmp.x.a, tmp.y.b, tmp.y.a);
    }

}// AGPL-3.0-only


pragma solidity 0.6.10;



contract Monitors is Permissions {


    using StringUtils for string;
    using SafeCast for uint;

    struct Verdict {
        uint toNodeIndex;
        uint32 downtime;
        uint32 latency;
    }

    struct CheckedNode {
        uint nodeIndex;
        uint time;
    }

    struct CheckedNodeWithIp {
        uint nodeIndex;
        uint time;
        bytes4 ip;
    }

    mapping (bytes32 => CheckedNode[]) public checkedNodes;
    mapping (bytes32 => uint[][]) public verdicts;

    mapping (bytes32 => uint[]) public groupsForMonitors;

    mapping (bytes32 => uint) public lastVerdictBlocks;
    mapping (bytes32 => uint) public lastBountyBlocks;


    event MonitorCreated(
        uint nodeIndex,
        bytes32 monitorIndex,
        uint numberOfMonitors,
        uint[] nodesInGroup,
        uint time,
        uint gasSpend
    );

    event VerdictWasSent(
        uint indexed fromMonitorIndex,
        uint indexed toNodeIndex,
        uint32 downtime,
        uint32 latency,
        bool status,
        uint previousBlockEvent,
        uint time,
        uint gasSpend
    );

    event MetricsWereCalculated(
        uint forNodeIndex,
        uint32 averageDowntime,
        uint32 averageLatency,
        uint time,
        uint gasSpend
    );

    event PeriodsWereSet(
        uint rewardPeriod,
        uint deltaPeriod,
        uint time,
        uint gasSpend
    );


    event MonitorRotated(
        bytes32 monitorIndex,
        uint newNode
    );

    function addMonitor(uint nodeIndex) external allow("SkaleManager") {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        bytes32 monitorIndex = keccak256(abi.encodePacked(nodeIndex));
        _generateGroup(monitorIndex, nodeIndex, constantsHolder.NUMBER_OF_MONITORS());
        CheckedNode memory checkedNode = _getCheckedNodeData(nodeIndex);
        for (uint i = 0; i < groupsForMonitors[monitorIndex].length; i++) {
            bytes32 index = keccak256(abi.encodePacked(groupsForMonitors[monitorIndex][i]));
            addCheckedNode(index, checkedNode);
        }

        emit MonitorCreated(
            nodeIndex,
            monitorIndex,
            groupsForMonitors[monitorIndex].length,
            groupsForMonitors[monitorIndex],
            block.timestamp,
            gasleft()
        );
    }

    function deleteMonitor(uint nodeIndex) external allow("SkaleManager") {

        bytes32 monitorIndex = keccak256(abi.encodePacked(nodeIndex));
        while (verdicts[keccak256(abi.encodePacked(nodeIndex))].length > 0) {
            verdicts[keccak256(abi.encodePacked(nodeIndex))].pop();
        }
        uint[] memory nodesInGroup = groupsForMonitors[monitorIndex];
        uint index;
        bytes32 monitoringIndex;
        for (uint i = 0; i < nodesInGroup.length; i++) {
            monitoringIndex = keccak256(abi.encodePacked(nodesInGroup[i]));
            (index, ) = _find(monitoringIndex, nodeIndex);
            if (index < checkedNodes[monitoringIndex].length) {
                if (index != checkedNodes[monitoringIndex].length.sub(1)) {
                    checkedNodes[monitoringIndex][index] =
                        checkedNodes[monitoringIndex][checkedNodes[monitoringIndex].length.sub(1)];
                }
                checkedNodes[monitoringIndex].pop();
            }
        }
        delete groupsForMonitors[monitorIndex];
    }

    function removeCheckedNodes(uint nodeIndex) external allow("SkaleManager") {

        bytes32 monitorIndex = keccak256(abi.encodePacked(nodeIndex));
        delete checkedNodes[monitorIndex];
    }

    function sendVerdict(uint fromMonitorIndex, Verdict calldata verdict) external allow("SkaleManager") {

        uint index;
        uint time;
        bytes32 monitorIndex = keccak256(abi.encodePacked(fromMonitorIndex));
        (index, time) = _find(monitorIndex, verdict.toNodeIndex);
        require(time > 0, "Checked Node does not exist in MonitorsArray");
        if (time <= block.timestamp) {
            if (index != checkedNodes[monitorIndex].length.sub(1)) {
                checkedNodes[monitorIndex][index] = 
                    checkedNodes[monitorIndex][checkedNodes[monitorIndex].length.sub(1)];
            }
            delete checkedNodes[monitorIndex][checkedNodes[monitorIndex].length.sub(1)];
            checkedNodes[monitorIndex].pop();
            ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
            bool receiveVerdict = time.add(constantsHolder.deltaPeriod()) > block.timestamp;
            if (receiveVerdict) {
                verdicts[keccak256(abi.encodePacked(verdict.toNodeIndex))].push(
                    [uint(verdict.downtime), uint(verdict.latency)]
                );
            }
            _emitVerdictsEvent(fromMonitorIndex, verdict, receiveVerdict);
        }
    }

    function calculateMetrics(uint nodeIndex)
        external
        allow("SkaleManager")
        returns (uint averageDowntime, uint averageLatency)
    {

        bytes32 monitorIndex = keccak256(abi.encodePacked(nodeIndex));
        uint lengthOfArray = getLengthOfMetrics(monitorIndex);
        uint[] memory downtimeArray = new uint[](lengthOfArray);
        uint[] memory latencyArray = new uint[](lengthOfArray);
        for (uint i = 0; i < lengthOfArray; i++) {
            downtimeArray[i] = verdicts[monitorIndex][i][0];
            latencyArray[i] = verdicts[monitorIndex][i][1];
        }
        if (lengthOfArray > 0) {
            averageDowntime = _median(downtimeArray);
            averageLatency = _median(latencyArray);
        }
        delete verdicts[monitorIndex];
    }

    function setLastBountyBlock(uint nodeIndex) external allow("SkaleManager") {

        lastBountyBlocks[keccak256(abi.encodePacked(nodeIndex))] = block.number;
    }

    function getCheckedArray(bytes32 monitorIndex)
        external
        view
        returns (CheckedNodeWithIp[] memory checkedNodesWithIp)
    {

        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        checkedNodesWithIp = new CheckedNodeWithIp[](checkedNodes[monitorIndex].length);
        for (uint i = 0; i < checkedNodes[monitorIndex].length; ++i) {
            checkedNodesWithIp[i].nodeIndex = checkedNodes[monitorIndex][i].nodeIndex;
            checkedNodesWithIp[i].time = checkedNodes[monitorIndex][i].time;
            checkedNodesWithIp[i].ip = nodes.getNodeIP(checkedNodes[monitorIndex][i].nodeIndex);
        }
    }

    function getLastBountyBlock(uint nodeIndex) external view returns (uint) {

        return lastBountyBlocks[keccak256(abi.encodePacked(nodeIndex))];
    }

    function getNodesInGroup(bytes32 monitorIndex) external view returns (uint[] memory) {

        return groupsForMonitors[monitorIndex];
    }

    function getNumberOfNodesInGroup(bytes32 monitorIndex) external view returns (uint) {

        return groupsForMonitors[monitorIndex].length;
    }

    function initialize(address newContractsAddress) public override initializer {

        Permissions.initialize(newContractsAddress);
    }

    function addCheckedNode(bytes32 monitorIndex, CheckedNode memory checkedNode) public allow("SkaleManager") {

        for (uint i = 0; i < checkedNodes[monitorIndex].length; ++i) {
            if (checkedNodes[monitorIndex][i].nodeIndex == checkedNode.nodeIndex) {
                checkedNodes[monitorIndex][i] = checkedNode;
                return;
            }
        }
        checkedNodes[monitorIndex].push(checkedNode);
    }

    function getLastReceivedVerdictBlock(uint nodeIndex) public view returns (uint) {

        return lastVerdictBlocks[keccak256(abi.encodePacked(nodeIndex))];
    }

    function getLengthOfMetrics(bytes32 monitorIndex) public view returns (uint) {

        return verdicts[monitorIndex].length;
    }

    function _generateGroup(bytes32 monitorIndex, uint nodeIndex, uint numberOfNodes)
        private
    {

        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        uint[] memory activeNodes = nodes.getActiveNodeIds();
        uint numberOfNodesInGroup;
        uint availableAmount = activeNodes.length.sub((nodes.isNodeActive(nodeIndex)) ? 1 : 0);
        if (numberOfNodes > availableAmount) {
            numberOfNodesInGroup = availableAmount;
        } else {
            numberOfNodesInGroup = numberOfNodes;
        }
        uint ignoringTail = 0;
        uint random = uint(keccak256(abi.encodePacked(uint(blockhash(block.number.sub(1))), monitorIndex)));
        for (uint i = 0; i < numberOfNodesInGroup; ++i) {
            uint index = random % (activeNodes.length.sub(ignoringTail));
            if (activeNodes[index] == nodeIndex) {
                _swap(activeNodes, index, activeNodes.length.sub(ignoringTail).sub(1));
                ++ignoringTail;
                index = random % (activeNodes.length.sub(ignoringTail));
            }
            groupsForMonitors[monitorIndex].push(activeNodes[index]);
            _swap(activeNodes, index, activeNodes.length.sub(ignoringTail).sub(1));
            ++ignoringTail;
        }
    }

    function _median(uint[] memory values) private pure returns (uint) {

        if (values.length < 1) {
            revert("Can't calculate _median of empty array");
        }
        _quickSort(values, 0, values.length.sub(1));
        return values[values.length.div(2)];
    }

    function _swap(uint[] memory array, uint index1, uint index2) private pure {

        uint buffer = array[index1];
        array[index1] = array[index2];
        array[index2] = buffer;
    }

    function _find(bytes32 monitorIndex, uint nodeIndex) private view returns (uint index, uint time) {

        index = checkedNodes[monitorIndex].length;
        time = 0;
        for (uint i = 0; i < checkedNodes[monitorIndex].length; i++) {
            uint checkedNodeNodeIndex;
            uint checkedNodeTime;
            checkedNodeNodeIndex = checkedNodes[monitorIndex][i].nodeIndex;
            checkedNodeTime = checkedNodes[monitorIndex][i].time;
            if (checkedNodeNodeIndex == nodeIndex && (time == 0 || checkedNodeTime < time))
            {
                index = i;
                time = checkedNodeTime;
            }
        }
    }

    function _quickSort(uint[] memory array, uint left, uint right) private pure {

        uint leftIndex = left;
        uint rightIndex = right;
        uint middle = array[right.add(left).div(2)];
        while (leftIndex <= rightIndex) {
            while (array[leftIndex] < middle) {
                leftIndex++;
                }
            while (middle < array[rightIndex]) {
                rightIndex--;
                }
            if (leftIndex <= rightIndex) {
                (array[leftIndex], array[rightIndex]) = (array[rightIndex], array[leftIndex]);
                leftIndex++;
                rightIndex = (rightIndex > 0 ? rightIndex.sub(1) : 0);
            }
        }
        if (left < rightIndex)
            _quickSort(array, left, rightIndex);
        if (leftIndex < right)
            _quickSort(array, leftIndex, right);
    }

    function _getCheckedNodeData(uint nodeIndex) private view returns (CheckedNode memory checkedNode) {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));

        checkedNode.nodeIndex = nodeIndex;
        checkedNode.time = nodes.getNodeNextRewardDate(nodeIndex).sub(constantsHolder.deltaPeriod());
    }

    function _emitVerdictsEvent(
        uint fromMonitorIndex,
        Verdict memory verdict,
        bool receiveVerdict
    )
        private
    {

        uint previousBlockEvent = getLastReceivedVerdictBlock(verdict.toNodeIndex);
        lastVerdictBlocks[keccak256(abi.encodePacked(verdict.toNodeIndex))] = block.number;

        emit VerdictWasSent(
                fromMonitorIndex,
                verdict.toNodeIndex,
                verdict.downtime,
                verdict.latency,
                receiveVerdict,
                previousBlockEvent,
                block.timestamp,
                gasleft()
            );
    }
}


pragma solidity 0.6.10;



contract NodeRotation is Permissions {

    using StringUtils for string;
    using StringUtils for uint;

    struct Rotation {
        uint nodeIndex;
        uint newNodeIndex;
        uint freezeUntil;
        uint rotationCounter;
    }

    struct LeavingHistory {
        bytes32 schainIndex;
        uint finishedRotation;
    }

    mapping (bytes32 => Rotation) public rotations;

    mapping (uint => LeavingHistory[]) public leavingHistory;


    function exitFromSchain(uint nodeIndex) external allow("SkaleManager") returns (bool) {

        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        bytes32 schainId = schainsInternal.getActiveSchain(nodeIndex);
        require(_checkRotation(schainId), "No any free Nodes for rotating");
        rotateNode(nodeIndex, schainId, true);
        return schainsInternal.getActiveSchain(nodeIndex) == bytes32(0) ? true : false;
    }

    function freezeSchains(uint nodeIndex) external allow("SkaleManager") {

        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        bytes32[] memory schains = schainsInternal.getActiveSchains(nodeIndex);
        for (uint i = 0; i < schains.length; i++) {
            Rotation memory rotation = rotations[schains[i]];
            if (rotation.nodeIndex == nodeIndex && now < rotation.freezeUntil) {
                continue;
            }
            string memory schainName = schainsInternal.getSchainName(schains[i]);
            string memory revertMessage = "Node cannot rotate on Schain ";
            revertMessage = revertMessage.strConcat(schainName);
            revertMessage = revertMessage.strConcat(", occupied by Node ");
            revertMessage = revertMessage.strConcat(rotation.nodeIndex.uint2str());
            string memory dkgRevert = "DKG proccess did not finish on schain ";
            ISkaleDKG skaleDKG = ISkaleDKG(contractManager.getContract("SkaleDKG"));
            require(
                skaleDKG.isLastDKGSuccesful(keccak256(abi.encodePacked(schainName))),
                dkgRevert.strConcat(schainName));
            require(rotation.freezeUntil < now, revertMessage);
            _startRotation(schains[i], nodeIndex);
        }
    }


    function removeRotation(bytes32 schainIndex) external allow("Schains") {

        delete rotations[schainIndex];
    }

    function skipRotationDelay(bytes32 schainIndex) external onlyOwner {

        rotations[schainIndex].freezeUntil = now;
    }

    function getRotation(bytes32 schainIndex) external view returns (Rotation memory) {

        if (rotations[schainIndex].nodeIndex != rotations[schainIndex].newNodeIndex) {
            return rotations[schainIndex];
        }
        return Rotation(0, 0, 0, 0);
    }

    function getLeavingHistory(uint nodeIndex) external view returns (LeavingHistory[] memory) {

        return leavingHistory[nodeIndex];
    }

    function initialize(address newContractsAddress) public override initializer {

        Permissions.initialize(newContractsAddress);
    }

    function rotateNode(
        uint nodeIndex,
        bytes32 schainId,
        bool shouldDelay
    )
        public
        allowTwo("SkaleDKG", "SkaleManager")
        returns (uint newNode)
    {

        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        schainsInternal.removeNodeFromSchain(nodeIndex, schainId);
        newNode = selectNodeToGroup(schainId);
        _finishRotation(schainId, nodeIndex, newNode, shouldDelay);
    }

    function selectNodeToGroup(bytes32 schainId)
        public
        allowThree("SkaleManager", "Schains", "SkaleDKG")
        returns (uint)
    {

        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        require(schainsInternal.isSchainActive(schainId), "Group is not active");
        uint8 space = schainsInternal.getSchainsPartOfNode(schainId);
        uint[] memory possibleNodes = schainsInternal.isEnoughNodes(schainId);
        require(possibleNodes.length > 0, "No any free Nodes for rotation");
        uint nodeIndex;
        uint random = uint(keccak256(abi.encodePacked(uint(blockhash(block.number - 1)), schainId)));
        do {
            uint index = random % possibleNodes.length;
            nodeIndex = possibleNodes[index];
            random = uint(keccak256(abi.encodePacked(random, nodeIndex)));
        } while (schainsInternal.checkException(schainId, nodeIndex));
        require(nodes.removeSpaceFromNode(nodeIndex, space), "Could not remove space from nodeIndex");
        schainsInternal.addSchainForNode(nodeIndex, schainId);
        schainsInternal.setException(schainId, nodeIndex);
        schainsInternal.setNodeInGroup(schainId, nodeIndex);
        return nodeIndex;
    }


    function _startRotation(bytes32 schainIndex, uint nodeIndex) private {

        ConstantsHolder constants = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        rotations[schainIndex].nodeIndex = nodeIndex;
        rotations[schainIndex].newNodeIndex = nodeIndex;
        rotations[schainIndex].freezeUntil = now.add(constants.rotationDelay());
    }

    function _finishRotation(
        bytes32 schainIndex,
        uint nodeIndex,
        uint newNodeIndex,
        bool shouldDelay)
        private
    {

        ConstantsHolder constants = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        leavingHistory[nodeIndex].push(
            LeavingHistory(schainIndex, shouldDelay ? now.add(constants.rotationDelay()) : now)
        );
        rotations[schainIndex].newNodeIndex = newNodeIndex;
        rotations[schainIndex].rotationCounter++;
        ISkaleDKG(contractManager.getContract("SkaleDKG")).openChannel(schainIndex);
    }

    function _checkRotation(bytes32 schainId ) private view returns (bool) {

        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        require(schainsInternal.isSchainExist(schainId), "Schain does not exist for rotation");
        return schainsInternal.isAnyFreeNode(schainId);
    }


}// AGPL-3.0-only


pragma solidity 0.6.10;



contract Pricing is Permissions {


    uint public constant INITIAL_PRICE = 5 * 10**6;

    uint public price;
    uint public totalNodes;
    uint public lastUpdated;

    function initNodes() external {

        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        totalNodes = nodes.getNumberOnlineNodes();
    }

    function adjustPrice() external {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        require(now > lastUpdated.add(constantsHolder.COOLDOWN_TIME()), "It's not a time to update a price");
        checkAllNodes();
        uint load = _getTotalLoad();
        uint capacity = _getTotalCapacity();

        bool networkIsOverloaded = load.mul(100) > constantsHolder.OPTIMAL_LOAD_PERCENTAGE().mul(capacity);
        uint loadDiff;
        if (networkIsOverloaded) {
            loadDiff = load.mul(100).sub(constantsHolder.OPTIMAL_LOAD_PERCENTAGE().mul(capacity));
        } else {
            loadDiff = constantsHolder.OPTIMAL_LOAD_PERCENTAGE().mul(capacity).sub(load.mul(100));
        }

        uint priceChangeSpeedMultipliedByCapacityAndMinPrice =
            constantsHolder.ADJUSTMENT_SPEED().mul(loadDiff).mul(price);
        
        uint timeSkipped = now.sub(lastUpdated);
        
        uint priceChange = priceChangeSpeedMultipliedByCapacityAndMinPrice
            .mul(timeSkipped)
            .div(constantsHolder.COOLDOWN_TIME())
            .div(capacity)
            .div(constantsHolder.MIN_PRICE());

        if (networkIsOverloaded) {
            assert(priceChange > 0);
            price = price.add(priceChange);
        } else {
            if (priceChange > price) {
                price = constantsHolder.MIN_PRICE();
            } else {
                price = price.sub(priceChange);
                if (price < constantsHolder.MIN_PRICE()) {
                    price = constantsHolder.MIN_PRICE();
                }
            }
        }
        lastUpdated = now;
    }

    function getTotalLoadPercentage() external view returns (uint) {

        return _getTotalLoad().mul(100).div(_getTotalCapacity());
    }

    function initialize(address newContractsAddress) public override initializer {

        Permissions.initialize(newContractsAddress);
        lastUpdated = now;
        price = INITIAL_PRICE;
    }

    function checkAllNodes() public {

        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        uint numberOfActiveNodes = nodes.getNumberOnlineNodes();

        require(totalNodes != numberOfActiveNodes, "No any changes on nodes");
        totalNodes = numberOfActiveNodes;
    }

    function _getTotalLoad() private view returns (uint) {

        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));

        uint load = 0;
        uint numberOfSchains = schainsInternal.numberOfSchains();
        for (uint i = 0; i < numberOfSchains; i++) {
            bytes32 schain = schainsInternal.schainsAtSystem(i);
            uint numberOfNodesInSchain = schainsInternal.getNumberOfNodesInGroup(schain);
            uint part = schainsInternal.getSchainsPartOfNode(schain);
            load = load.add(
                numberOfNodesInSchain.mul(part)
            );
        }
        return load;
    }

    function _getTotalCapacity() private view returns (uint) {

        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));

        return nodes.getNumberOnlineNodes().mul(constantsHolder.TOTAL_SPACE_ON_NODE());
    }
}


pragma solidity 0.6.10;



contract SkaleVerifier is Permissions {  

    using Fp2Operations for Fp2Operations.Fp2Point;

    function verify(
        Fp2Operations.Fp2Point calldata signature,
        bytes32 hash,
        uint counter,
        uint hashA,
        uint hashB,
        G2Operations.G2Point calldata publicKey
    )
        external
        view
        returns (bool)
    {

        if (!_checkHashToGroupWithHelper(
            hash,
            counter,
            hashA,
            hashB
            )
        )
        {
            return false;
        }

        uint newSignB;
        if (!(signature.a == 0 && signature.b == 0)) {
            newSignB = Fp2Operations.P.sub((signature.b % Fp2Operations.P));
        } else {
            newSignB = signature.b;
        }

        require(G2Operations.isG1Point(signature.a, newSignB), "Sign not in G1");
        require(G2Operations.isG1Point(hashA, hashB), "Hash not in G1");

        G2Operations.G2Point memory g2 = G2Operations.getG2();
        require(
            G2Operations.isG2(publicKey),
            "Public Key not in G2"
        );

        return Precompiled.bn256Pairing(
            signature.a, newSignB,
            g2.x.b, g2.x.a, g2.y.b, g2.y.a,
            hashA, hashB,
            publicKey.x.b, publicKey.x.a, publicKey.y.b, publicKey.y.a
        );
    }

    function initialize(address newContractsAddress) public override initializer {

        Permissions.initialize(newContractsAddress);
    }

    function _checkHashToGroupWithHelper(
        bytes32 hash,
        uint counter,
        uint hashA,
        uint hashB
    )
        private
        pure
        returns (bool)
    {

        uint xCoord = uint(hash) % Fp2Operations.P;
        xCoord = (xCoord.add(counter)) % Fp2Operations.P;

        uint ySquared = addmod(
            mulmod(mulmod(xCoord, xCoord, Fp2Operations.P), xCoord, Fp2Operations.P),
            3,
            Fp2Operations.P
        );
        if (hashB < Fp2Operations.P.div(2) || mulmod(hashB, hashB, Fp2Operations.P) != ySquared || xCoord != hashA) {
            return false;
        }

        return true;
    }
}


pragma solidity 0.6.10;



contract Schains is Permissions {

    using StringUtils for string;
    using StringUtils for uint;

    struct SchainParameters {
        uint lifetime;
        uint8 typeOfSchain;
        uint16 nonce;
        string name;
    }

    event SchainCreated(
        string name,
        address owner,
        uint partOfNode,
        uint lifetime,
        uint numberOfNodes,
        uint deposit,
        uint16 nonce,
        bytes32 schainId,
        uint time,
        uint gasSpend
    );

    event SchainDeleted(
        address owner,
        string name,
        bytes32 indexed schainId
    );

    event NodeRotated(
        bytes32 schainId,
        uint oldNode,
        uint newNode
    );

    event NodeAdded(
        bytes32 schainId,
        uint newNode
    );

    event SchainNodes(
        string name,
        bytes32 schainId,
        uint[] nodesInGroup,
        uint time,
        uint gasSpend
    );

    bytes32 public constant SCHAIN_CREATOR_ROLE = keccak256("SCHAIN_CREATOR_ROLE");

    function addSchain(address from, uint deposit, bytes calldata data) external allow("SkaleManager") {

        SchainParameters memory schainParameters = _fallbackSchainParametersDataConverter(data);
        
        require(
            getSchainPrice(schainParameters.typeOfSchain, schainParameters.lifetime) <= deposit,
            "Not enough money to create Schain");

        _addSchain(from, deposit, schainParameters);
    }

    function addSchainByFoundation(
        uint lifetime,
        uint8 typeOfSchain,
        uint16 nonce,
        string calldata name
    )
        external
    {

        require(hasRole(SCHAIN_CREATOR_ROLE, msg.sender), "Sender is not authorized to create schian");

        SchainParameters memory schainParameters = SchainParameters({
            lifetime: lifetime,
            typeOfSchain: typeOfSchain,
            nonce: nonce,
            name: name
        });

        _addSchain(msg.sender, 0, schainParameters);
    }

    function deleteSchain(address from, string calldata name) external allow("SkaleManager") {

        NodeRotation nodeRotation = NodeRotation(contractManager.getContract("NodeRotation"));
        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        bytes32 schainId = keccak256(abi.encodePacked(name));
        require(
            schainsInternal.isOwnerAddress(from, schainId),
            "Message sender is not an owner of Schain"
        );
        address nodesAddress = contractManager.getContract("Nodes");

        uint[] memory nodesInGroup = schainsInternal.getNodesInGroup(schainId);
        uint8 partOfNode = schainsInternal.getSchainsPartOfNode(schainId);
        for (uint i = 0; i < nodesInGroup.length; i++) {
            uint schainIndex = schainsInternal.findSchainAtSchainsForNode(
                nodesInGroup[i],
                schainId
            );
            if (schainsInternal.checkHoleForSchain(schainId, nodesInGroup[i])) {
                schainsInternal.removeNodeFromExceptions(schainId, nodesInGroup[i]);
                _addSpace(nodesInGroup[i], partOfNode);
                continue;
            }
            require(
                schainIndex < schainsInternal.getLengthOfSchainsForNode(nodesInGroup[i]),
                "Some Node does not contain given Schain");
            schainsInternal.removeNodeFromSchain(nodesInGroup[i], schainId);
            schainsInternal.removeNodeFromExceptions(schainId, nodesInGroup[i]);
            if (!Nodes(nodesAddress).isNodeLeft(nodesInGroup[i])) {
                _addSpace(nodesInGroup[i], partOfNode);
            }
        }
        schainsInternal.deleteGroup(schainId);
        schainsInternal.removeSchain(schainId, from);
        schainsInternal.removeHolesForSchain(schainId);
        nodeRotation.removeRotation(schainId);
        emit SchainDeleted(from, name, schainId);
    }

    function deleteSchainByRoot(string calldata name) external allow("SkaleManager") {

        NodeRotation nodeRotation = NodeRotation(contractManager.getContract("NodeRotation"));
        bytes32 schainId = keccak256(abi.encodePacked(name));
        SchainsInternal schainsInternal = SchainsInternal(
            contractManager.getContract("SchainsInternal"));
        require(schainsInternal.isSchainExist(schainId), "Schain does not exist");

        uint[] memory nodesInGroup = schainsInternal.getNodesInGroup(schainId);
        uint8 partOfNode = schainsInternal.getSchainsPartOfNode(schainId);
        for (uint i = 0; i < nodesInGroup.length; i++) {
            uint schainIndex = schainsInternal.findSchainAtSchainsForNode(
                nodesInGroup[i],
                schainId
            );
            if (schainsInternal.checkHoleForSchain(schainId, nodesInGroup[i])) {
                schainsInternal.removeNodeFromExceptions(schainId, nodesInGroup[i]);
                _addSpace(nodesInGroup[i], partOfNode);
                continue;
            }
            require(
                schainIndex < schainsInternal.getLengthOfSchainsForNode(nodesInGroup[i]),
                "Some Node does not contain given Schain");
            schainsInternal.removeNodeFromSchain(nodesInGroup[i], schainId);
            schainsInternal.removeNodeFromExceptions(schainId, nodesInGroup[i]);
            _addSpace(nodesInGroup[i], partOfNode);
        }
        schainsInternal.deleteGroup(schainId);
        address from = schainsInternal.getSchainOwner(schainId);
        schainsInternal.removeSchain(schainId, from);
        schainsInternal.removeHolesForSchain(schainId);
        nodeRotation.removeRotation(schainId);
        emit SchainDeleted(from, name, schainId);
    }

    function restartSchainCreation(string calldata name) external allow("SkaleManager") {

        NodeRotation nodeRotation = NodeRotation(contractManager.getContract("NodeRotation"));
        bytes32 schainId = keccak256(abi.encodePacked(name));
        ISkaleDKG skaleDKG = ISkaleDKG(contractManager.getContract("SkaleDKG"));
        require(!skaleDKG.isLastDKGSuccesful(schainId), "DKG success");
        SchainsInternal schainsInternal = SchainsInternal(
            contractManager.getContract("SchainsInternal"));
        require(schainsInternal.isAnyFreeNode(schainId), "No any free Nodes for rotation");
        uint newNodeIndex = nodeRotation.selectNodeToGroup(schainId);
        skaleDKG.openChannel(schainId);
        emit NodeAdded(schainId, newNodeIndex);
    }

    function verifySchainSignature(
        uint signatureA,
        uint signatureB,
        bytes32 hash,
        uint counter,
        uint hashA,
        uint hashB,
        string calldata schainName
    )
        external
        view
        returns (bool)
    {

        SkaleVerifier skaleVerifier = SkaleVerifier(contractManager.getContract("SkaleVerifier"));

        G2Operations.G2Point memory publicKey = KeyStorage(
            contractManager.getContract("KeyStorage")
        ).getCommonPublicKey(
            keccak256(abi.encodePacked(schainName))
        );
        return skaleVerifier.verify(
            Fp2Operations.Fp2Point({
                a: signatureA,
                b: signatureB
            }),
            hash, counter,
            hashA, hashB,
            publicKey
        );
    }

    function initialize(address newContractsAddress) public override initializer {

        Permissions.initialize(newContractsAddress);
    }


    function getSchainPrice(uint typeOfSchain, uint lifetime) public view returns (uint) {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        uint nodeDeposit = constantsHolder.NODE_DEPOSIT();
        uint numberOfNodes;
        uint8 divisor;
        (numberOfNodes, divisor) = getNodesDataFromTypeOfSchain(typeOfSchain);
        if (divisor == 0) {
            return 1e18;
        } else {
            uint up = nodeDeposit.mul(numberOfNodes.mul(lifetime.mul(2)));
            uint down = uint(
                uint(constantsHolder.SMALL_DIVISOR())
                    .mul(uint(constantsHolder.SECONDS_TO_YEAR()))
                    .div(divisor)
            );
            return up.div(down);
        }
    }

    function getNodesDataFromTypeOfSchain(uint typeOfSchain)
        public
        view
        returns (uint numberOfNodes, uint8 partOfNode)
    {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        numberOfNodes = constantsHolder.NUMBER_OF_NODES_FOR_SCHAIN();
        if (typeOfSchain == 1) {
            partOfNode = constantsHolder.SMALL_DIVISOR() / constantsHolder.SMALL_DIVISOR();
        } else if (typeOfSchain == 2) {
            partOfNode = constantsHolder.SMALL_DIVISOR() / constantsHolder.MEDIUM_DIVISOR();
        } else if (typeOfSchain == 3) {
            partOfNode = constantsHolder.SMALL_DIVISOR() / constantsHolder.LARGE_DIVISOR();
        } else if (typeOfSchain == 4) {
            partOfNode = 0;
            numberOfNodes = constantsHolder.NUMBER_OF_NODES_FOR_TEST_SCHAIN();
        } else if (typeOfSchain == 5) {
            partOfNode = constantsHolder.SMALL_DIVISOR() / constantsHolder.MEDIUM_TEST_DIVISOR();
            numberOfNodes = constantsHolder.NUMBER_OF_NODES_FOR_MEDIUM_TEST_SCHAIN();
        } else {
            revert("Bad schain type");
        }
    }

    function _initializeSchainInSchainsInternal(
        string memory name,
        address from,
        uint deposit,
        uint lifetime) private
    {

        address dataAddress = contractManager.getContract("SchainsInternal");
        require(SchainsInternal(dataAddress).isSchainNameAvailable(name), "Schain name is not available");

        SchainsInternal(dataAddress).initializeSchain(
            name,
            from,
            lifetime,
            deposit);
        SchainsInternal(dataAddress).setSchainIndex(keccak256(abi.encodePacked(name)), from);
    }

    function _fallbackSchainParametersDataConverter(bytes memory data)
        private
        pure
        returns (SchainParameters memory schainParameters)
    {

        (schainParameters.lifetime,
        schainParameters.typeOfSchain,
        schainParameters.nonce,
        schainParameters.name) = abi.decode(data, (uint, uint8, uint16, string));
    }

    function _addSpace(uint nodeIndex, uint8 partOfNode) private {

        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        nodes.addSpaceToNode(nodeIndex, partOfNode);
    }

    function _createGroupForSchain(
        string memory schainName,
        bytes32 schainId,
        uint numberOfNodes,
        uint8 partOfNode
    )
        private
    {

        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        uint[] memory nodesInGroup = schainsInternal.createGroupForSchain(schainId, numberOfNodes, partOfNode);
        ISkaleDKG(contractManager.getContract("SkaleDKG")).openChannel(schainId);

        emit SchainNodes(
            schainName,
            schainId,
            nodesInGroup,
            block.timestamp,
            gasleft());
    }

    function _addSchain(address from, uint deposit, SchainParameters memory schainParameters) private {

        uint numberOfNodes;
        uint8 partOfNode;

        require(schainParameters.typeOfSchain <= 5, "Invalid type of Schain");

        _initializeSchainInSchainsInternal(
            schainParameters.name,
            from,
            deposit,
            schainParameters.lifetime);

        (numberOfNodes, partOfNode) = getNodesDataFromTypeOfSchain(schainParameters.typeOfSchain);

        _createGroupForSchain(
            schainParameters.name,
            keccak256(abi.encodePacked(schainParameters.name)),
            numberOfNodes,
            partOfNode
        );

        emit SchainCreated(
            schainParameters.name,
            from,
            partOfNode,
            schainParameters.lifetime,
            numberOfNodes,
            deposit,
            schainParameters.nonce,
            keccak256(abi.encodePacked(schainParameters.name)),
            block.timestamp,
            gasleft());
    }
}


pragma solidity 0.6.10;


contract SlashingTable is Permissions {

    mapping (uint => uint) private _penalties;

    function setPenalty(string calldata offense, uint penalty) external onlyOwner {

        _penalties[uint(keccak256(abi.encodePacked(offense)))] = penalty;
    }

    function getPenalty(string calldata offense) external view returns (uint) {

        uint penalty = _penalties[uint(keccak256(abi.encodePacked(offense)))];
        return penalty;
    }

    function initialize(address contractManagerAddress) public override initializer {

        Permissions.initialize(contractManagerAddress);
    }
}


pragma solidity 0.6.10;

contract SkaleDKG is Permissions, ISkaleDKG {


    struct Channel {
        bool active;
        uint n;
        uint startedBlockTimestamp;
    }

    struct ProcessDKG {
        uint numberOfBroadcasted;
        uint numberOfCompleted;
        bool[] broadcasted;
        bool[] completed;
        uint startAlrightTimestamp;
    }

    struct ComplaintData {
        uint nodeToComplaint;
        uint fromNodeToComplaint;
        uint startComplaintBlockTimestamp;
    }

    uint public constant COMPLAINT_TIMELIMIT = 1800;

    mapping(bytes32 => Channel) public channels;

    mapping(bytes32 => uint) public lastSuccesfulDKG;

    mapping(bytes32 => ProcessDKG) public dkgProcess;

    mapping(bytes32 => ComplaintData) public complaints;

    mapping(bytes32 => uint) public startAlrightTimestamp;

    event ChannelOpened(bytes32 groupIndex);

    event ChannelClosed(bytes32 groupIndex);

    event BroadcastAndKeyShare(
        bytes32 indexed groupIndex,
        uint indexed fromNode,
        G2Operations.G2Point[] verificationVector,
        KeyStorage.KeyShare[] secretKeyContribution
    );

    event AllDataReceived(bytes32 indexed groupIndex, uint nodeIndex);
    event SuccessfulDKG(bytes32 indexed groupIndex);
    event BadGuy(uint nodeIndex);
    event FailedDKG(bytes32 indexed groupIndex);
    event ComplaintSent(bytes32 indexed groupIndex, uint indexed fromNodeIndex, uint indexed toNodeIndex);
    event NewGuy(uint nodeIndex);
    event ComplaintError(string error);

    modifier correctGroup(bytes32 groupIndex) {

        require(channels[groupIndex].active, "Group is not created");
        _;
    }

    modifier correctGroupWithoutRevert(bytes32 groupIndex) {

        if (!channels[groupIndex].active) {
            emit ComplaintError("Group is not created");
        } else {
            _;
        }
    }

    modifier correctNode(bytes32 groupIndex, uint nodeIndex) {

        uint index = _nodeIndexInSchain(groupIndex, nodeIndex);
        require(
            index < channels[groupIndex].n,
            "Node is not in this group");
        _;
    }

    function openChannel(bytes32 groupIndex) external override allowTwo("Schains","NodeRotation") {

        _openChannel(groupIndex);
    }

    function deleteChannel(bytes32 groupIndex) external override allow("SchainsInternal") {

        require(channels[groupIndex].active, "Channel is not created");
        delete channels[groupIndex];
        delete dkgProcess[groupIndex];
        delete complaints[groupIndex];
        KeyStorage(contractManager.getContract("KeyStorage")).deleteKey(groupIndex);
    }

    function broadcast(
        bytes32 groupIndex,
        uint nodeIndex,
        G2Operations.G2Point[] calldata verificationVector,
        KeyStorage.KeyShare[] calldata secretKeyContribution
    )
        external
        correctGroup(groupIndex)
        correctNode(groupIndex, nodeIndex)
    {

        require(_isNodeByMessageSender(nodeIndex, msg.sender), "Node does not exist for message sender");
        uint n = channels[groupIndex].n;
        require(verificationVector.length == getT(n), "Incorrect number of verification vectors");
        require(
            secretKeyContribution.length == n,
            "Incorrect number of secret key shares"
        );

        _isBroadcast(
            groupIndex,
            nodeIndex,
            secretKeyContribution,
            verificationVector
        );
        KeyStorage keyStorage = KeyStorage(contractManager.getContract("KeyStorage"));
        keyStorage.adding(groupIndex, verificationVector[0]);
        keyStorage.computePublicValues(groupIndex, verificationVector);
        emit BroadcastAndKeyShare(
            groupIndex,
            nodeIndex,
            verificationVector,
            secretKeyContribution
        );
    }

    function complaint(bytes32 groupIndex, uint fromNodeIndex, uint toNodeIndex)
        external
        correctGroupWithoutRevert(groupIndex)
        correctNode(groupIndex, fromNodeIndex)
        correctNode(groupIndex, toNodeIndex)
    {

        require(_isNodeByMessageSender(fromNodeIndex, msg.sender), "Node does not exist for message sender");
        bool broadcasted = _isBroadcasted(groupIndex, toNodeIndex);
        if (broadcasted && complaints[groupIndex].nodeToComplaint == uint(-1)) {
            if (
                isEveryoneBroadcasted(groupIndex) &&
                startAlrightTimestamp[groupIndex].add(COMPLAINT_TIMELIMIT) <= block.timestamp &&
                !isAllDataReceived(groupIndex, toNodeIndex)
            ) {
                _finalizeSlashing(groupIndex, toNodeIndex);
            } else {
                complaints[groupIndex].nodeToComplaint = toNodeIndex;
                complaints[groupIndex].fromNodeToComplaint = fromNodeIndex;
                complaints[groupIndex].startComplaintBlockTimestamp = block.timestamp;
                emit ComplaintSent(groupIndex, fromNodeIndex, toNodeIndex);
            }
        } else if (broadcasted && complaints[groupIndex].nodeToComplaint == toNodeIndex) {
            if (complaints[groupIndex].startComplaintBlockTimestamp.add(COMPLAINT_TIMELIMIT) <= block.timestamp) {
                _finalizeSlashing(groupIndex, complaints[groupIndex].nodeToComplaint);
            } else {
                emit ComplaintError("The same complaint rejected");
            }
        } else if (!broadcasted) {
            if (channels[groupIndex].startedBlockTimestamp.add(COMPLAINT_TIMELIMIT) <= block.timestamp) {
                _finalizeSlashing(groupIndex, toNodeIndex);
            } else {
                emit ComplaintError("Complaint sent too early");
            }
        } else {
            emit ComplaintError("One complaint is already sent");
        }
    }

    function response(
        bytes32 groupIndex,
        uint fromNodeIndex,
        uint secretNumber,
        G2Operations.G2Point calldata multipliedShare
    )
        external
        correctGroup(groupIndex)
        correctNode(groupIndex, fromNodeIndex)
    {

        require(complaints[groupIndex].nodeToComplaint == fromNodeIndex, "Not this Node");
        require(_isNodeByMessageSender(fromNodeIndex, msg.sender), "Node does not exist for message sender");
        bool verificationResult = KeyStorage(contractManager.getContract("KeyStorage")).verify(
            groupIndex,
            complaints[groupIndex].nodeToComplaint,
            complaints[groupIndex].fromNodeToComplaint,
            secretNumber,
            multipliedShare
        );
        uint badNode = (verificationResult ?
            complaints[groupIndex].fromNodeToComplaint : complaints[groupIndex].nodeToComplaint);
        _finalizeSlashing(groupIndex, badNode);
    }

    function alright(bytes32 groupIndex, uint fromNodeIndex)
        external
        correctGroup(groupIndex)
        correctNode(groupIndex, fromNodeIndex)
    {

        require(_isNodeByMessageSender(fromNodeIndex, msg.sender), "Node does not exist for message sender");
        uint index = _nodeIndexInSchain(groupIndex, fromNodeIndex);
        uint numberOfParticipant = channels[groupIndex].n;
        require(numberOfParticipant == dkgProcess[groupIndex].numberOfBroadcasted, "Still Broadcasting phase");
        require(!dkgProcess[groupIndex].completed[index], "Node is already alright");
        dkgProcess[groupIndex].completed[index] = true;
        dkgProcess[groupIndex].numberOfCompleted++;
        emit AllDataReceived(groupIndex, fromNodeIndex);
        if (dkgProcess[groupIndex].numberOfCompleted == numberOfParticipant) {
            _setSuccesfulDKG(groupIndex);
        }
    }

    function getChannelStartedTime(bytes32 groupIndex) external view returns (uint) {

        return channels[groupIndex].startedBlockTimestamp;
    }

    function getNumberOfBroadcasted(bytes32 groupIndex) external view returns (uint) {

        return dkgProcess[groupIndex].numberOfBroadcasted;
    }

    function getNumberOfCompleted(bytes32 groupIndex) external view returns (uint) {

        return dkgProcess[groupIndex].numberOfCompleted;
    }

    function getTimeOfLastSuccesfulDKG(bytes32 groupIndex) external view returns (uint) {

        return lastSuccesfulDKG[groupIndex];
    }

    function getComplaintData(bytes32 groupIndex) external view returns (uint, uint) {

        return (complaints[groupIndex].fromNodeToComplaint, complaints[groupIndex].nodeToComplaint);
    }

    function getComplaintStartedTime(bytes32 groupIndex) external view returns (uint) {

        return complaints[groupIndex].startComplaintBlockTimestamp;
    }

    function getAlrightStartedTime(bytes32 groupIndex) external view returns (uint) {

        return startAlrightTimestamp[groupIndex];
    }

    function isChannelOpened(bytes32 groupIndex) external override view returns (bool) {

        return channels[groupIndex].active;
    }

    function isLastDKGSuccesful(bytes32 groupIndex) external override view returns (bool) {

        return channels[groupIndex].startedBlockTimestamp <= lastSuccesfulDKG[groupIndex];
    }

    function isBroadcastPossible(bytes32 groupIndex, uint nodeIndex) external view returns (bool) {

        uint index = _nodeIndexInSchain(groupIndex, nodeIndex);
        return channels[groupIndex].active &&
            index <  channels[groupIndex].n &&
            _isNodeByMessageSender(nodeIndex, msg.sender) &&
            !dkgProcess[groupIndex].broadcasted[index];
    }

    function isComplaintPossible(
        bytes32 groupIndex,
        uint fromNodeIndex,
        uint toNodeIndex
    )
        external
        view
        returns (bool)
    {

        uint indexFrom = _nodeIndexInSchain(groupIndex, fromNodeIndex);
        uint indexTo = _nodeIndexInSchain(groupIndex, toNodeIndex);
        bool complaintSending = (
                complaints[groupIndex].nodeToComplaint == uint(-1) &&
                dkgProcess[groupIndex].broadcasted[indexTo]
            ) ||
            (
                dkgProcess[groupIndex].broadcasted[indexTo] &&
                complaints[groupIndex].startComplaintBlockTimestamp.add(COMPLAINT_TIMELIMIT) <= block.timestamp &&
                complaints[groupIndex].nodeToComplaint == toNodeIndex
            ) ||
            (
                !dkgProcess[groupIndex].broadcasted[indexTo] &&
                complaints[groupIndex].nodeToComplaint == uint(-1) &&
                channels[groupIndex].startedBlockTimestamp.add(COMPLAINT_TIMELIMIT) <= block.timestamp
            );
        return channels[groupIndex].active &&
            indexFrom < channels[groupIndex].n &&
            indexTo < channels[groupIndex].n &&
            _isNodeByMessageSender(fromNodeIndex, msg.sender) &&
            complaintSending;
    }

    function isAlrightPossible(bytes32 groupIndex, uint nodeIndex) external view returns (bool) {

        uint index = _nodeIndexInSchain(groupIndex, nodeIndex);
        return channels[groupIndex].active &&
            index < channels[groupIndex].n &&
            _isNodeByMessageSender(nodeIndex, msg.sender) &&
            channels[groupIndex].n == dkgProcess[groupIndex].numberOfBroadcasted &&
            !dkgProcess[groupIndex].completed[index];
    }

    function isResponsePossible(bytes32 groupIndex, uint nodeIndex) external view returns (bool) {

        uint index = _nodeIndexInSchain(groupIndex, nodeIndex);
        return channels[groupIndex].active &&
            index < channels[groupIndex].n &&
            _isNodeByMessageSender(nodeIndex, msg.sender) &&
            complaints[groupIndex].nodeToComplaint == nodeIndex;
    }

    function isNodeBroadcasted(bytes32 groupIndex, uint nodeIndex) external view returns (bool) {

        uint index = _nodeIndexInSchain(groupIndex, nodeIndex);
        return index < channels[groupIndex].n && dkgProcess[groupIndex].broadcasted[index];
    }

    function initialize(address contractsAddress) public override initializer {

        Permissions.initialize(contractsAddress);
    }

    function isEveryoneBroadcasted(bytes32 groupIndex) public view returns (bool) {

        return channels[groupIndex].n == dkgProcess[groupIndex].numberOfBroadcasted;
    }

    function isAllDataReceived(bytes32 groupIndex, uint nodeIndex) public view returns (bool) {

        uint index = _nodeIndexInSchain(groupIndex, nodeIndex);
        return dkgProcess[groupIndex].completed[index];
    }

    function getT(uint n) public pure returns (uint) {

        return n.mul(2).add(1).div(3);
    }

    function _setSuccesfulDKG(bytes32 groupIndex) internal {

        lastSuccesfulDKG[groupIndex] = now;
        channels[groupIndex].active = false;
        KeyStorage(contractManager.getContract("KeyStorage")).finalizePublicKey(groupIndex);
        emit SuccessfulDKG(groupIndex);
    }

    function _openChannel(bytes32 groupIndex) private {

        SchainsInternal schainsInternal = SchainsInternal(
            contractManager.getContract("SchainsInternal")
        );

        uint len = schainsInternal.getNumberOfNodesInGroup(groupIndex);
        channels[groupIndex].active = true;
        channels[groupIndex].n = len;
        delete dkgProcess[groupIndex].completed;
        delete dkgProcess[groupIndex].broadcasted;
        dkgProcess[groupIndex].broadcasted = new bool[](len);
        dkgProcess[groupIndex].completed = new bool[](len);
        complaints[groupIndex].fromNodeToComplaint = uint(-1);
        complaints[groupIndex].nodeToComplaint = uint(-1);
        delete complaints[groupIndex].startComplaintBlockTimestamp;
        delete dkgProcess[groupIndex].numberOfBroadcasted;
        delete dkgProcess[groupIndex].numberOfCompleted;
        channels[groupIndex].startedBlockTimestamp = now;
        KeyStorage(contractManager.getContract("KeyStorage")).initPublicKeyInProgress(groupIndex);

        emit ChannelOpened(groupIndex);
    }

    function _finalizeSlashing(bytes32 groupIndex, uint badNode) private {

        NodeRotation nodeRotation = NodeRotation(contractManager.getContract("NodeRotation"));
        SchainsInternal schainsInternal = SchainsInternal(
            contractManager.getContract("SchainsInternal")
        );
        emit BadGuy(badNode);
        emit FailedDKG(groupIndex);

        if (schainsInternal.isAnyFreeNode(groupIndex)) {
            uint newNode = nodeRotation.rotateNode(
                badNode,
                groupIndex,
                false
            );
            emit NewGuy(newNode);
        } else {
            _openChannel(groupIndex);
            schainsInternal.removeNodeFromSchain(
                badNode,
                groupIndex
            );
            channels[groupIndex].active = false;
        }
        Punisher(contractManager.getContract("Punisher")).slash(
            Nodes(contractManager.getContract("Nodes")).getValidatorId(badNode),
            SlashingTable(contractManager.getContract("SlashingTable")).getPenalty("FailedDKG")
        );
    }

    function _isBroadcast(
        bytes32 groupIndex,
        uint nodeIndex,
        KeyStorage.KeyShare[] memory secretKeyContribution,
        G2Operations.G2Point[] memory verificationVector
    )
        private
    {

        uint index = _nodeIndexInSchain(groupIndex, nodeIndex);
        require(!dkgProcess[groupIndex].broadcasted[index], "This node is already broadcasted");
        dkgProcess[groupIndex].broadcasted[index] = true;
        dkgProcess[groupIndex].numberOfBroadcasted++;
        if (dkgProcess[groupIndex].numberOfBroadcasted == channels[groupIndex].n) {
            startAlrightTimestamp[groupIndex] = now;
        }
        KeyStorage(contractManager.getContract("KeyStorage")).addBroadcastedData(
            groupIndex,
            index,
            secretKeyContribution,
            verificationVector
        );
    }

    function _isBroadcasted(bytes32 groupIndex, uint nodeIndex) private view returns (bool) {

        uint index = _nodeIndexInSchain(groupIndex, nodeIndex);
        return dkgProcess[groupIndex].broadcasted[index];
    }

    function _nodeIndexInSchain(bytes32 schainId, uint nodeIndex) private view returns (uint) {

        return SchainsInternal(contractManager.getContract("SchainsInternal"))
            .getNodeIndexInGroup(schainId, nodeIndex);
    }

    function _isNodeByMessageSender(uint nodeIndex, address from) private view returns (bool) {

        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        return nodes.isNodeExist(from, nodeIndex);
    }
}// AGPL-3.0-only


pragma solidity 0.6.10;




contract SkaleManager is IERC777Recipient, Permissions {

    IERC1820Registry private _erc1820;

    bytes32 constant private _TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    bytes32 constant public ADMIN_ROLE = keccak256("ADMIN_ROLE");

    event BountyGot(
        uint indexed nodeIndex,
        address owner,
        uint averageDowntime,
        uint averageLatency,
        uint bounty,
        uint previousBlockEvent,
        uint time,
        uint gasSpend
    );

    function tokensReceived(
        address, // operator
        address from,
        address to,
        uint256 value,
        bytes calldata userData,
        bytes calldata // operator data
    )
        external override
        allow("SkaleToken")
    {

        require(to == address(this), "Receiver is incorrect");
        if (userData.length > 0) {
            Schains schains = Schains(
                contractManager.getContract("Schains"));
            schains.addSchain(from, value, userData);
        }
    }

    function createNode(
        uint16 port,
        uint16 nonce,
        bytes4 ip,
        bytes4 publicIp,
        bytes32[2] calldata publicKey,
        string calldata name)
        external
    {

        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        nodes.checkPossibilityCreatingNode(msg.sender);

        Nodes.NodeCreationParams memory params = Nodes.NodeCreationParams({
            name: name,
            ip: ip,
            publicIp: publicIp,
            port: port,
            publicKey: publicKey,
            nonce: nonce});
        nodes.createNode(msg.sender, params);
    }

    function nodeExit(uint nodeIndex) external {

        NodeRotation nodeRotation = NodeRotation(contractManager.getContract("NodeRotation"));
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        uint validatorId = nodes.getValidatorId(nodeIndex);
        bool permitted = (_isOwner() || nodes.isNodeExist(msg.sender, nodeIndex));
        if (!permitted) {
            permitted = validatorService.getValidatorId(msg.sender) == validatorId;
        }
        require(permitted, "Sender is not permitted to call this function");
        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        ConstantsHolder constants = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        nodeRotation.freezeSchains(nodeIndex);
        if (nodes.isNodeActive(nodeIndex)) {
            require(nodes.initExit(nodeIndex), "Initialization of node exit is failed");
        }
        bool completed;
        bool isSchains = false;
        if (schainsInternal.getActiveSchain(nodeIndex) != bytes32(0)) {
            completed = nodeRotation.exitFromSchain(nodeIndex);
            isSchains = true;
        } else {
            completed = true;
        }
        if (completed) {
            require(nodes.completeExit(nodeIndex), "Finishing of node exit is failed");
            nodes.changeNodeFinishTime(nodeIndex, now.add(isSchains ? constants.rotationDelay() : 0));
            nodes.deleteNodeForValidator(validatorId, nodeIndex);
        }
    }

    function deleteSchain(string calldata name) external {

        Schains schains = Schains(contractManager.getContract("Schains"));
        schains.deleteSchain(msg.sender, name);
    }

    function deleteSchainByRoot(string calldata name) external onlyAdmin {

        Schains schains = Schains(contractManager.getContract("Schains"));
        schains.deleteSchainByRoot(name);
    }





    function getBounty(uint nodeIndex) external {

        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        require(nodes.isNodeExist(msg.sender, nodeIndex), "Node does not exist for Message sender");
        require(nodes.isTimeForReward(nodeIndex), "Not time for bounty");
        require(
            nodes.isNodeActive(nodeIndex) || nodes.isNodeLeaving(nodeIndex), "Node is not Active and is not Leaving"
        );
        Bounty bountyContract = Bounty(contractManager.getContract("Bounty"));
        uint averageDowntime;
        uint averageLatency;
        Monitors monitors = Monitors(contractManager.getContract("Monitors"));
        (averageDowntime, averageLatency) = monitors.calculateMetrics(nodeIndex);

        uint bounty = bountyContract.getBounty(
            nodeIndex,
            averageDowntime,
            averageLatency);

        nodes.changeNodeLastRewardDate(nodeIndex);

        if (bounty > 0) {
            _payBounty(bounty, nodes.getValidatorId(nodeIndex));
        }

        _emitBountyEvent(nodeIndex, msg.sender, averageDowntime, averageLatency, bounty);
    }

    function initialize(address newContractsAddress) public override initializer {

        Permissions.initialize(newContractsAddress);
        _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
        _erc1820.setInterfaceImplementer(address(this), _TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
    }

    function _payBounty(uint bounty, uint validatorId) private returns (bool) {        

        IERC777 skaleToken = IERC777(contractManager.getContract("SkaleToken"));
        Distributor distributor = Distributor(contractManager.getContract("Distributor"));
        
        skaleToken.send(address(distributor), bounty, abi.encode(validatorId));
    }

    function _emitBountyEvent(
        uint nodeIndex,
        address from,
        uint averageDowntime,
        uint averageLatency,
        uint bounty
    )
        private
    {

        Monitors monitors = Monitors(contractManager.getContract("Monitors"));
        uint previousBlockEvent = monitors.getLastBountyBlock(nodeIndex);
        monitors.setLastBountyBlock(nodeIndex);

        emit BountyGot(
            nodeIndex,
            from,
            averageDowntime,
            averageLatency,
            bounty,
            previousBlockEvent,
            block.timestamp,
            gasleft());
    }
}


pragma solidity 0.6.10;



contract TokenLaunchManager is Permissions, IERC777Recipient {

    event Approved(
        address holder,
        uint amount
    );

    event TokensRetrieved(
        address holder,
        uint amount
    );

    event TokenLaunchIsCompleted(
        uint timestamp
    );

    bytes32 public constant SELLER_ROLE = keccak256("SELLER_ROLE");

    IERC1820Registry private _erc1820;

    mapping (address => uint) public approved;
    bool public tokenLaunchIsCompleted;
    uint private _totalApproved;

    modifier onlySeller() {

        require(_isOwner() || hasRole(SELLER_ROLE, _msgSender()), "Not authorized");
        _;
    }

    function approveTransfer(address walletAddress, uint value) external onlySeller {

        require(!tokenLaunchIsCompleted, "Can't approve because token launch is completed");
        _approveTransfer(walletAddress, value);
        require(_totalApproved <= _getBalance(), "Balance is too low");
    }

    function approveBatchOfTransfers(address[] calldata walletAddress, uint[] calldata value) external onlySeller {

        require(!tokenLaunchIsCompleted, "Can't approve because token launch is completed");
        require(walletAddress.length == value.length, "Wrong input arrays length");
        for (uint i = 0; i < walletAddress.length; ++i) {
            _approveTransfer(walletAddress[i], value[i]);
        }
        require(_totalApproved <= _getBalance(), "Balance is too low");
    }

    function completeTokenLaunch() external onlySeller {

        require(!tokenLaunchIsCompleted, "Can't complete launch because it's already completed");
        tokenLaunchIsCompleted = true;
        emit TokenLaunchIsCompleted(now);
    }

    function changeApprovalAddress(address oldAddress, address newAddress) external onlySeller {

        require(!tokenLaunchIsCompleted, "Can't change approval because token launch is completed");
        require(approved[newAddress] == 0, "New address is already used");
        uint oldValue = approved[oldAddress];
        if (oldValue > 0) {
            _setApprovedAmount(oldAddress, 0);
            _approveTransfer(newAddress, oldValue);
        }
    }

    function changeApprovalValue(address wallet, uint newValue) external onlySeller {

        require(!tokenLaunchIsCompleted, "Can't change approval because token launch is completed");
        _setApprovedAmount(wallet, newValue);
    }

    function retrieve() external {

        require(tokenLaunchIsCompleted, "Can't retrive tokens because token launch is not completed");
        require(approved[_msgSender()] > 0, "Transfer is not approved");
        uint value = approved[_msgSender()];
        _setApprovedAmount(_msgSender(), 0);
        require(
            IERC20(contractManager.getContract("SkaleToken")).transfer(_msgSender(), value),
            "Error in transfer call to SkaleToken");
        TokenLaunchLocker(contractManager.getContract("TokenLaunchLocker")).lock(_msgSender(), value);
        emit TokensRetrieved(_msgSender(), value);
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    )
        external override
        allow("SkaleToken")
    {


    }

    function initialize(address contractManagerAddress) public override initializer {

        Permissions.initialize(contractManagerAddress);
        tokenLaunchIsCompleted = false;
        _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }    


    function _approveTransfer(address walletAddress, uint value) internal onlySeller {

        require(value > 0, "Value must be greater than zero");
        _setApprovedAmount(walletAddress, approved[walletAddress].add(value));
        emit Approved(walletAddress, value);
    }

    function _getBalance() private view returns(uint balance) {

        return IERC20(contractManager.getContract("SkaleToken")).balanceOf(address(this));
    }

    function _setApprovedAmount(address wallet, uint value) private {

        require(wallet != address(0), "Wallet address must be non zero");
        uint oldValue = approved[wallet];
        if (oldValue != value) {
            approved[wallet] = value;
            if (value > oldValue) {
                _totalApproved = _totalApproved.add(value.sub(oldValue));
            } else {
                _totalApproved = _totalApproved.sub(oldValue.sub(value));
            }
        }
    }
}