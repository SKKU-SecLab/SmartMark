


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}



pragma solidity ^0.8.4;


contract MotionSettings is AccessControl {

    event MotionDurationChanged(uint256 _motionDuration);
    event MotionsCountLimitChanged(uint256 _newMotionsCountLimit);
    event ObjectionsThresholdChanged(uint256 _newThreshold);


    string private constant ERROR_VALUE_TOO_SMALL = "VALUE_TOO_SMALL";
    string private constant ERROR_VALUE_TOO_LARGE = "VALUE_TOO_LARGE";

    uint256 public constant MAX_MOTIONS_LIMIT = 24;

    uint256 public constant MAX_OBJECTIONS_THRESHOLD = 500;

    uint256 public constant MIN_MOTION_DURATION = 48 hours;


    uint256 public objectionsThreshold;

    uint256 public motionsCountLimit;

    uint256 public motionDuration;

    constructor(
        address _admin,
        uint256 _motionDuration,
        uint256 _motionsCountLimit,
        uint256 _objectionsThreshold
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setMotionDuration(_motionDuration);
        _setMotionsCountLimit(_motionsCountLimit);
        _setObjectionsThreshold(_objectionsThreshold);
    }


    function setMotionDuration(uint256 _motionDuration) external onlyRole(DEFAULT_ADMIN_ROLE) {

        _setMotionDuration(_motionDuration);
    }

    function setObjectionsThreshold(uint256 _objectionsThreshold)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        _setObjectionsThreshold(_objectionsThreshold);
    }

    function setMotionsCountLimit(uint256 _motionsCountLimit)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        _setMotionsCountLimit(_motionsCountLimit);
    }

    function _setMotionDuration(uint256 _motionDuration) internal {

        require(_motionDuration >= MIN_MOTION_DURATION, ERROR_VALUE_TOO_SMALL);
        motionDuration = _motionDuration;
        emit MotionDurationChanged(_motionDuration);
    }

    function _setObjectionsThreshold(uint256 _objectionsThreshold) internal {

        require(_objectionsThreshold <= MAX_OBJECTIONS_THRESHOLD, ERROR_VALUE_TOO_LARGE);
        objectionsThreshold = _objectionsThreshold;
        emit ObjectionsThresholdChanged(_objectionsThreshold);
    }

    function _setMotionsCountLimit(uint256 _motionsCountLimit) internal {

        require(_motionsCountLimit <= MAX_MOTIONS_LIMIT, ERROR_VALUE_TOO_LARGE);
        motionsCountLimit = _motionsCountLimit;
        emit MotionsCountLimitChanged(_motionsCountLimit);
    }
}



pragma solidity ^0.8.4;

interface IEVMScriptFactory {

    function createEVMScript(address _creator, bytes memory _evmScriptCallData)
        external
        returns (bytes memory);

}



pragma solidity ^0.8.4;

library BytesUtils {

    function bytes24At(bytes memory data, uint256 location) internal pure returns (bytes24 result) {

        uint256 word = uint256At(data, location);
        assembly {
            result := word
        }
    }

    function addressAt(bytes memory data, uint256 location) internal pure returns (address result) {

        uint256 word = uint256At(data, location);
        assembly {
            result := shr(
                96,
                and(word, 0xffffffffffffffffffffffffffffffffffffffff000000000000000000000000)
            )
        }
    }

    function uint32At(bytes memory _data, uint256 _location) internal pure returns (uint32 result) {

        uint256 word = uint256At(_data, _location);

        assembly {
            result := shr(
                224,
                and(word, 0xffffffff00000000000000000000000000000000000000000000000000000000)
            )
        }
    }

    function uint256At(bytes memory data, uint256 location) internal pure returns (uint256 result) {

        assembly {
            result := mload(add(data, add(0x20, location)))
        }
    }
}



pragma solidity ^0.8.4;


library EVMScriptPermissions {

    using BytesUtils for bytes;


    uint256 private constant SPEC_ID_SIZE = 4;

    uint256 private constant ADDRESS_SIZE = 20;

    uint256 private constant CALLDATA_LENGTH_SIZE = 4;

    uint256 private constant METHOD_SELECTOR_SIZE = 4;

    uint256 private constant PERMISSION_SIZE = ADDRESS_SIZE + METHOD_SELECTOR_SIZE;


    function canExecuteEVMScript(bytes memory _permissions, bytes memory _evmScript)
        internal
        pure
        returns (bool)
    {

        uint256 location = SPEC_ID_SIZE; // first 4 bytes reserved for SPEC_ID
        if (!isValidPermissions(_permissions) || _evmScript.length <= location) {
            return false;
        }

        while (location < _evmScript.length) {
            (bytes24 methodToCall, uint32 callDataLength) = _getNextMethodId(_evmScript, location);
            if (!_hasPermission(_permissions, methodToCall)) {
                return false;
            }
            location += ADDRESS_SIZE + CALLDATA_LENGTH_SIZE + callDataLength;
        }
        return true;
    }

    function isValidPermissions(bytes memory _permissions) internal pure returns (bool) {

        return _permissions.length > 0 && _permissions.length % PERMISSION_SIZE == 0;
    }

    function _getNextMethodId(bytes memory _evmScript, uint256 _location)
        private
        pure
        returns (bytes24, uint32)
    {

        address recipient = _evmScript.addressAt(_location);
        uint32 callDataLength = _evmScript.uint32At(_location + ADDRESS_SIZE);
        uint32 functionSelector =
            _evmScript.uint32At(_location + ADDRESS_SIZE + CALLDATA_LENGTH_SIZE);
        return (bytes24(uint192(functionSelector)) | bytes20(recipient), callDataLength);
    }

    function _hasPermission(bytes memory _permissions, bytes24 _methodToCall)
        private
        pure
        returns (bool)
    {

        uint256 location = 0;
        while (location < _permissions.length) {
            bytes24 permission = _permissions.bytes24At(location);
            if (permission == _methodToCall) {
                return true;
            }
            location += PERMISSION_SIZE;
        }
        return false;
    }
}



pragma solidity ^0.8.4;




contract EVMScriptFactoriesRegistry is AccessControl {

    using EVMScriptPermissions for bytes;


    event EVMScriptFactoryAdded(address indexed _evmScriptFactory, bytes _permissions);
    event EVMScriptFactoryRemoved(address indexed _evmScriptFactory);


    address[] public evmScriptFactories;

    mapping(address => uint256) internal evmScriptFactoryIndices;

    mapping(address => bytes) public evmScriptFactoryPermissions;

    constructor(address _admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }


    function addEVMScriptFactory(address _evmScriptFactory, bytes memory _permissions)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(_permissions.isValidPermissions(), "INVALID_PERMISSIONS");
        require(!_isEVMScriptFactory(_evmScriptFactory), "EVM_SCRIPT_FACTORY_ALREADY_ADDED");
        evmScriptFactories.push(_evmScriptFactory);
        evmScriptFactoryIndices[_evmScriptFactory] = evmScriptFactories.length;
        evmScriptFactoryPermissions[_evmScriptFactory] = _permissions;
        emit EVMScriptFactoryAdded(_evmScriptFactory, _permissions);
    }

    function removeEVMScriptFactory(address _evmScriptFactory)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        uint256 index = _getEVMScriptFactoryIndex(_evmScriptFactory);
        uint256 lastIndex = evmScriptFactories.length - 1;

        if (index != lastIndex) {
            address lastEVMScriptFactory = evmScriptFactories[lastIndex];
            evmScriptFactories[index] = lastEVMScriptFactory;
            evmScriptFactoryIndices[lastEVMScriptFactory] = index + 1;
        }

        evmScriptFactories.pop();
        delete evmScriptFactoryIndices[_evmScriptFactory];
        delete evmScriptFactoryPermissions[_evmScriptFactory];
        emit EVMScriptFactoryRemoved(_evmScriptFactory);
    }

    function getEVMScriptFactories() external view returns (address[] memory) {

        return evmScriptFactories;
    }

    function isEVMScriptFactory(address _maybeEVMScriptFactory) external view returns (bool) {

        return _isEVMScriptFactory(_maybeEVMScriptFactory);
    }


    function _createEVMScript(
        address _evmScriptFactory,
        address _creator,
        bytes memory _evmScriptCallData
    ) internal returns (bytes memory _evmScript) {

        require(_isEVMScriptFactory(_evmScriptFactory), "EVM_SCRIPT_FACTORY_NOT_FOUND");
        _evmScript = IEVMScriptFactory(_evmScriptFactory).createEVMScript(
            _creator,
            _evmScriptCallData
        );
        bytes memory permissions = evmScriptFactoryPermissions[_evmScriptFactory];
        require(permissions.canExecuteEVMScript(_evmScript), "HAS_NO_PERMISSIONS");
    }


    function _getEVMScriptFactoryIndex(address _evmScriptFactory)
        private
        view
        returns (uint256 _index)
    {

        _index = evmScriptFactoryIndices[_evmScriptFactory];
        require(_index > 0, "EVM_SCRIPT_FACTORY_NOT_FOUND");
        _index -= 1;
    }

    function _isEVMScriptFactory(address _maybeEVMScriptFactory) private view returns (bool) {

        return evmScriptFactoryIndices[_maybeEVMScriptFactory] > 0;
    }
}



pragma solidity ^0.8.4;

interface IEVMScriptExecutor {

    function executeEVMScript(bytes memory _evmScript) external returns (bytes memory);

}



pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
}



pragma solidity ^0.8.4;






interface IMiniMeToken {

    function balanceOfAt(address _owner, uint256 _blockNumber) external pure returns (uint256);


    function totalSupplyAt(uint256 _blockNumber) external view returns (uint256);

}

contract EasyTrack is Pausable, AccessControl, MotionSettings, EVMScriptFactoriesRegistry {

    struct Motion {
        uint256 id;
        address evmScriptFactory;
        address creator;
        uint256 duration;
        uint256 startDate;
        uint256 snapshotBlock;
        uint256 objectionsThreshold;
        uint256 objectionsAmount;
        bytes32 evmScriptHash;
    }

    event MotionCreated(
        uint256 indexed _motionId,
        address _creator,
        address indexed _evmScriptFactory,
        bytes _evmScriptCallData,
        bytes _evmScript
    );
    event MotionObjected(
        uint256 indexed _motionId,
        address indexed _objector,
        uint256 _weight,
        uint256 _newObjectionsAmount,
        uint256 _newObjectionsAmountPct
    );
    event MotionRejected(uint256 indexed _motionId);
    event MotionCanceled(uint256 indexed _motionId);
    event MotionEnacted(uint256 indexed _motionId);
    event EVMScriptExecutorChanged(address indexed _evmScriptExecutor);

    string private constant ERROR_ALREADY_OBJECTED = "ALREADY_OBJECTED";
    string private constant ERROR_NOT_ENOUGH_BALANCE = "NOT_ENOUGH_BALANCE";
    string private constant ERROR_NOT_CREATOR = "NOT_CREATOR";
    string private constant ERROR_MOTION_NOT_PASSED = "MOTION_NOT_PASSED";
    string private constant ERROR_UNEXPECTED_EVM_SCRIPT = "UNEXPECTED_EVM_SCRIPT";
    string private constant ERROR_MOTION_NOT_FOUND = "MOTION_NOT_FOUND";
    string private constant ERROR_MOTIONS_LIMIT_REACHED = "MOTIONS_LIMIT_REACHED";

    bytes32 public constant PAUSE_ROLE = keccak256("PAUSE_ROLE");
    bytes32 public constant UNPAUSE_ROLE = keccak256("UNPAUSE_ROLE");
    bytes32 public constant CANCEL_ROLE = keccak256("CANCEL_ROLE");


    uint256 internal constant HUNDRED_PERCENT = 10000;


    Motion[] public motions;

    uint256 internal lastMotionId;

    IMiniMeToken public governanceToken;

    IEVMScriptExecutor public evmScriptExecutor;

    mapping(uint256 => uint256) internal motionIndicesByMotionId;

    mapping(uint256 => mapping(address => bool)) public objections;

    constructor(
        address _governanceToken,
        address _admin,
        uint256 _motionDuration,
        uint256 _motionsCountLimit,
        uint256 _objectionsThreshold
    )
        EVMScriptFactoriesRegistry(_admin)
        MotionSettings(_admin, _motionDuration, _motionsCountLimit, _objectionsThreshold)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(PAUSE_ROLE, _admin);
        _setupRole(UNPAUSE_ROLE, _admin);
        _setupRole(CANCEL_ROLE, _admin);

        governanceToken = IMiniMeToken(_governanceToken);
    }


    function createMotion(address _evmScriptFactory, bytes memory _evmScriptCallData)
        external
        whenNotPaused
        returns (uint256 _newMotionId)
    {

        require(motions.length < motionsCountLimit, ERROR_MOTIONS_LIMIT_REACHED);

        Motion storage newMotion = motions.push();
        _newMotionId = ++lastMotionId;

        newMotion.id = _newMotionId;
        newMotion.creator = msg.sender;
        newMotion.startDate = block.timestamp;
        newMotion.snapshotBlock = block.number;
        newMotion.duration = motionDuration;
        newMotion.objectionsThreshold = objectionsThreshold;
        newMotion.evmScriptFactory = _evmScriptFactory;
        motionIndicesByMotionId[_newMotionId] = motions.length;

        bytes memory evmScript =
            _createEVMScript(_evmScriptFactory, msg.sender, _evmScriptCallData);
        newMotion.evmScriptHash = keccak256(evmScript);

        emit MotionCreated(
            _newMotionId,
            msg.sender,
            _evmScriptFactory,
            _evmScriptCallData,
            evmScript
        );
    }

    function enactMotion(uint256 _motionId, bytes memory _evmScriptCallData)
        external
        whenNotPaused
    {

        Motion storage motion = _getMotion(_motionId);
        require(motion.startDate + motion.duration <= block.timestamp, ERROR_MOTION_NOT_PASSED);

        address creator = motion.creator;
        bytes32 evmScriptHash = motion.evmScriptHash;
        address evmScriptFactory = motion.evmScriptFactory;

        _deleteMotion(_motionId);
        emit MotionEnacted(_motionId);

        bytes memory evmScript = _createEVMScript(evmScriptFactory, creator, _evmScriptCallData);
        require(evmScriptHash == keccak256(evmScript), ERROR_UNEXPECTED_EVM_SCRIPT);

        evmScriptExecutor.executeEVMScript(evmScript);
    }

    function objectToMotion(uint256 _motionId) external {

        Motion storage motion = _getMotion(_motionId);
        require(!objections[_motionId][msg.sender], ERROR_ALREADY_OBJECTED);
        objections[_motionId][msg.sender] = true;

        uint256 snapshotBlock = motion.snapshotBlock;
        uint256 objectorBalance = governanceToken.balanceOfAt(msg.sender, snapshotBlock);
        require(objectorBalance > 0, ERROR_NOT_ENOUGH_BALANCE);

        uint256 totalSupply = governanceToken.totalSupplyAt(snapshotBlock);
        uint256 newObjectionsAmount = motion.objectionsAmount + objectorBalance;
        uint256 newObjectionsAmountPct = (HUNDRED_PERCENT * newObjectionsAmount) / totalSupply;

        emit MotionObjected(
            _motionId,
            msg.sender,
            objectorBalance,
            newObjectionsAmount,
            newObjectionsAmountPct
        );

        if (newObjectionsAmountPct < motion.objectionsThreshold) {
            motion.objectionsAmount = newObjectionsAmount;
        } else {
            _deleteMotion(_motionId);
            emit MotionRejected(_motionId);
        }
    }

    function cancelMotion(uint256 _motionId) external {

        Motion storage motion = _getMotion(_motionId);
        require(motion.creator == msg.sender, ERROR_NOT_CREATOR);
        _deleteMotion(_motionId);
        emit MotionCanceled(_motionId);
    }

    function cancelMotions(uint256[] memory _motionIds) external onlyRole(CANCEL_ROLE) {

        for (uint256 i = 0; i < _motionIds.length; ++i) {
            if (motionIndicesByMotionId[_motionIds[i]] > 0) {
                _deleteMotion(_motionIds[i]);
                emit MotionCanceled(_motionIds[i]);
            }
        }
    }

    function cancelAllMotions() external onlyRole(CANCEL_ROLE) {

        uint256 motionsCount = motions.length;
        while (motionsCount > 0) {
            motionsCount -= 1;
            uint256 motionId = motions[motionsCount].id;
            _deleteMotion(motionId);
            emit MotionCanceled(motionId);
        }
    }

    function setEVMScriptExecutor(address _evmScriptExecutor)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        evmScriptExecutor = IEVMScriptExecutor(_evmScriptExecutor);
        emit EVMScriptExecutorChanged(_evmScriptExecutor);
    }

    function pause() external whenNotPaused onlyRole(PAUSE_ROLE) {

        _pause();
    }

    function unpause() external whenPaused onlyRole(UNPAUSE_ROLE) {

        _unpause();
    }

    function canObjectToMotion(uint256 _motionId, address _objector) external view returns (bool) {

        Motion storage motion = _getMotion(_motionId);
        uint256 balance = governanceToken.balanceOfAt(_objector, motion.snapshotBlock);
        return balance > 0 && !objections[_motionId][_objector];
    }

    function getMotions() external view returns (Motion[] memory) {

        return motions;
    }

    function getMotion(uint256 _motionId) external view returns (Motion memory) {

        return _getMotion(_motionId);
    }


    function _deleteMotion(uint256 _motionId) private {

        uint256 index = motionIndicesByMotionId[_motionId] - 1;
        uint256 lastIndex = motions.length - 1;

        if (index != lastIndex) {
            Motion storage lastMotion = motions[lastIndex];
            motions[index] = lastMotion;
            motionIndicesByMotionId[lastMotion.id] = index + 1;
        }

        motions.pop();
        delete motionIndicesByMotionId[_motionId];
    }

    function _getMotion(uint256 _motionId) private view returns (Motion storage) {

        uint256 _motionIndex = motionIndicesByMotionId[_motionId];
        require(_motionIndex > 0, ERROR_MOTION_NOT_FOUND);
        return motions[_motionIndex - 1];
    }
}