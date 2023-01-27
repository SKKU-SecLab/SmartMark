
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

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
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
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
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
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
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
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
    uint256[49] private __gap;
}// MIT
pragma solidity 0.8.7;

interface IAggregatorBase {


    struct OracleInfo {
        bool exist; // exist oracle
        bool isValid; // is valid oracle
        bool required; // without this oracle (DSRM), the transfer will not be confirmed
    }


    event AddOracle(address oracle, bool required); // add oracle by admin
    event UpdateOracle(address oracle, bool required, bool isValid); // update oracle by admin
    event DeployApproved(bytes32 deployId); // emitted once the submission is confirmed by min required aount of oracles
    event SubmissionApproved(bytes32 submissionId); // emitted once the submission is confirmed by min required aount of oracles
}// BUSL-1.1
pragma solidity 0.8.7;


contract AggregatorBase is Initializable, AccessControlUpgradeable, IAggregatorBase {


    uint8 public minConfirmations; // minimal required confirmations
    uint8 public excessConfirmations; // minimal required confirmations in case of too many confirmations
    uint8 public requiredOraclesCount; // count of required oracles

    address[] public oracleAddresses;
    mapping(address => OracleInfo) public getOracleInfo; // oracle address => oracle details


    error AdminBadRole();
    error OracleBadRole();
    error DeBridgeGateBadRole();


    error OracleAlreadyExist();
    error OracleNotFound();

    error WrongArgument();
    error LowMinConfirmations();

    error SubmittedAlready();



    modifier onlyAdmin() {

        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert AdminBadRole();
        _;
    }
    modifier onlyOracle() {

        if (!getOracleInfo[msg.sender].isValid) revert OracleBadRole();
        _;
    }


    function initializeBase(uint8 _minConfirmations, uint8 _excessConfirmations) internal {

        if (_minConfirmations == 0 || _excessConfirmations < _minConfirmations) revert LowMinConfirmations();
        minConfirmations = _minConfirmations;
        excessConfirmations = _excessConfirmations;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }


    function setMinConfirmations(uint8 _minConfirmations) external onlyAdmin {

        if (_minConfirmations < oracleAddresses.length / 2 + 1) revert LowMinConfirmations();
        minConfirmations = _minConfirmations;
    }

    function setExcessConfirmations(uint8 _excessConfirmations) external onlyAdmin {

        if (_excessConfirmations < minConfirmations) revert LowMinConfirmations();
        excessConfirmations = _excessConfirmations;
    }

    function addOracles(
        address[] memory _oracles,
        bool[] memory _required
    ) external onlyAdmin {

        if (_oracles.length != _required.length) revert WrongArgument();
        if (minConfirmations < (oracleAddresses.length +  _oracles.length) / 2 + 1) revert LowMinConfirmations();

        for (uint256 i = 0; i < _oracles.length; i++) {
            OracleInfo storage oracleInfo = getOracleInfo[_oracles[i]];
            if (oracleInfo.exist) revert OracleAlreadyExist();

            oracleAddresses.push(_oracles[i]);

            if (_required[i]) {
                requiredOraclesCount += 1;
            }

            oracleInfo.exist = true;
            oracleInfo.isValid = true;
            oracleInfo.required = _required[i];

            emit AddOracle(_oracles[i], _required[i]);
        }
    }

    function updateOracle(
        address _oracle,
        bool _isValid,
        bool _required
    ) external onlyAdmin {

        if (!_isValid && _required) revert WrongArgument();

        OracleInfo storage oracleInfo = getOracleInfo[_oracle];
        if (!oracleInfo.exist) revert OracleNotFound();

        if (oracleInfo.required && !_required) {
            requiredOraclesCount -= 1;
        } else if (!oracleInfo.required && _required) {
            requiredOraclesCount += 1;
        }
        if (oracleInfo.isValid && !_isValid) {
            for (uint256 i = 0; i < oracleAddresses.length; i++) {
                if (oracleAddresses[i] == _oracle) {
                    oracleAddresses[i] = oracleAddresses[oracleAddresses.length - 1];
                    oracleAddresses.pop();
                    break;
                }
            }
        } else if (!oracleInfo.isValid && _isValid) {
            if (minConfirmations < (oracleAddresses.length + 1) / 2 + 1) revert LowMinConfirmations();
            oracleAddresses.push(_oracle);
        }
        oracleInfo.isValid = _isValid;
        oracleInfo.required = _required;
        emit UpdateOracle(_oracle, _required, _isValid);
    }



    function getDeployId(
        bytes32 _debridgeId,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(_debridgeId, _name, _symbol, _decimals));
    }

    function getDebridgeId(uint256 _chainId, bytes memory _tokenAddress)
        public
        pure
        returns (bytes32)
    {

        return keccak256(abi.encodePacked(_chainId, _tokenAddress));
    }
}// MIT
pragma solidity 0.8.7;

interface ISignatureVerifier {



    event Confirmed(bytes32 submissionId, address operator);
    event DeployConfirmed(bytes32 deployId, address operator);


    function submit(
        bytes32 _submissionId,
        bytes memory _signatures,
        uint8 _excessConfirmations
    ) external;


}// BUSL-1.1
pragma solidity 0.8.7;

library SignatureUtil {


    error WrongArgumentLength();
    error SignatureInvalidLength();
    error SignatureInvalidV();

    function getUnsignedMsg(bytes32 _submissionId) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _submissionId));
    }

    function splitSignature(bytes memory _signature)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {

        if (_signature.length != 65) revert SignatureInvalidLength();
        return parseSignature(_signature, 0);
    }

    function parseSignature(bytes memory _signatures, uint256 offset)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {

        assembly {
            r := mload(add(_signatures, add(32, offset)))
            s := mload(add(_signatures, add(64, offset)))
            v := and(mload(add(_signatures, add(65, offset))), 0xff)
        }

        if (v < 27) v += 27;
        if (v != 27 && v != 28) revert SignatureInvalidV();
    }

    function toUint256(bytes memory _bytes, uint256 _offset)
        internal
        pure
        returns (uint256 result)
    {

        if (_bytes.length < _offset + 32) revert WrongArgumentLength();

        assembly {
            result := mload(add(add(_bytes, 0x20), _offset))
        }
    }
}// BUSL-1.1
pragma solidity 0.8.7;


contract SignatureVerifier is AggregatorBase, ISignatureVerifier {

    using SignatureUtil for bytes;
    using SignatureUtil for bytes32;

    uint8 public confirmationThreshold;
    uint40 public submissionsInBlock;
    uint40 public currentBlock;

    address public debridgeAddress;


    error NotConfirmedByRequiredOracles();
    error NotConfirmedThreshold();
    error SubmissionNotConfirmed();
    error DuplicateSignatures();


    modifier onlyDeBridgeGate() {

        if (msg.sender != debridgeAddress) revert DeBridgeGateBadRole();
        _;
    }


    function initialize(
        uint8 _minConfirmations,
        uint8 _confirmationThreshold,
        uint8 _excessConfirmations,
        address _debridgeAddress
    ) public initializer {

        AggregatorBase.initializeBase(_minConfirmations, _excessConfirmations);
        confirmationThreshold = _confirmationThreshold;
        debridgeAddress = _debridgeAddress;
    }


    function submit(
        bytes32 _submissionId,
        bytes memory _signatures,
        uint8 _excessConfirmations
    ) external override onlyDeBridgeGate {

        uint8 needConfirmations = _excessConfirmations > minConfirmations
        ? _excessConfirmations
        : minConfirmations;
        uint256 currentRequiredOraclesCount;
        uint8 confirmations;
        uint256 signaturesCount = _countSignatures(_signatures);
        address[] memory validators = new address[](signaturesCount);
        for (uint256 i = 0; i < signaturesCount; i++) {
            (bytes32 r, bytes32 s, uint8 v) = _signatures.parseSignature(i * 65);
            address oracle = ecrecover(_submissionId.getUnsignedMsg(), v, r, s);
            if (getOracleInfo[oracle].isValid) {
                for (uint256 k = 0; k < i; k++) {
                    if (validators[k] == oracle) revert DuplicateSignatures();
                }
                validators[i] = oracle;

                confirmations += 1;
                emit Confirmed(_submissionId, oracle);
                if (getOracleInfo[oracle].required) {
                    currentRequiredOraclesCount += 1;
                }
                if (
                    confirmations >= needConfirmations &&
                    currentRequiredOraclesCount >= requiredOraclesCount
                ) {
                    break;
                }
            }
        }

        if (currentRequiredOraclesCount != requiredOraclesCount)
            revert NotConfirmedByRequiredOracles();

        if (confirmations >= minConfirmations) {
            if (currentBlock == uint40(block.number)) {
                submissionsInBlock += 1;
            } else {
                currentBlock = uint40(block.number);
                submissionsInBlock = 1;
            }
            emit SubmissionApproved(_submissionId);
        }

        if (submissionsInBlock > confirmationThreshold) {
            if (confirmations < excessConfirmations) revert NotConfirmedThreshold();
        }

        if (confirmations < needConfirmations) revert SubmissionNotConfirmed();
    }


    function setThreshold(uint8 _confirmationThreshold) external onlyAdmin {

        if (_confirmationThreshold == 0) revert WrongArgument();
        confirmationThreshold = _confirmationThreshold;
    }

    function setDebridgeAddress(address _debridgeAddress) external onlyAdmin {

        debridgeAddress = _debridgeAddress;
    }


    function isValidSignature(bytes32 _submissionId, bytes memory _signature)
    external
    view
    returns (bool)
    {

        (bytes32 r, bytes32 s, uint8 v) = _signature.splitSignature();
        address oracle = ecrecover(_submissionId.getUnsignedMsg(), v, r, s);
        return getOracleInfo[oracle].isValid;
    }


    function _countSignatures(bytes memory _signatures) internal pure returns (uint256) {

        return _signatures.length % 65 == 0 ? _signatures.length / 65 : 0;
    }

    function version() external pure returns (uint256) {

        return 101; // 1.0.1
    }
}