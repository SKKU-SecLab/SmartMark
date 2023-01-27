
pragma solidity ^0.8.0;

library AddressUpgradeable {

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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
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


interface IAccessControlUpgradeable {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");

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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
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
}//MIT
pragma solidity ^0.8.0;


contract CheckAndSend {

    function _check32BytesMulti(
        address[] calldata _targets,
        bytes[] calldata _payloads,
        bytes32[] calldata _resultMatches
    ) internal view {

        require(_targets.length == _payloads.length);
        require(_targets.length == _resultMatches.length);
        for (uint256 i = 0; i < _targets.length; i++) {
            _check32Bytes(_targets[i], _payloads[i], _resultMatches[i]);
        }
    }

    function _checkBytesMulti(
        address[] calldata _targets,
        bytes[] calldata _payloads,
        bytes[] calldata _resultMatches
    ) internal view {

        require(_targets.length == _payloads.length);
        require(_targets.length == _resultMatches.length);
        for (uint256 i = 0; i < _targets.length; i++) {
            _checkBytes(_targets[i], _payloads[i], _resultMatches[i]);
        }
    }

    function _check32Bytes(
        address _target,
        bytes memory _payload,
        bytes32 _resultMatch
    ) internal view {

        (bool _success, bytes memory _response) = _target.staticcall(_payload);
        require(_success, "!success");
        require(_response.length >= 32, "response less than 32 bytes");
        bytes32 _responseScalar;
        assembly {
            _responseScalar := mload(add(_response, 0x20))
        }
        require(_responseScalar == _resultMatch, "response mismatch");
    }

    function _checkBytes(
        address _target,
        bytes memory _payload,
        bytes memory _resultMatch
    ) internal view {

        (bool _success, bytes memory _response) = _target.staticcall(_payload);
        require(_success, "!success");
        require(
            keccak256(_resultMatch) == keccak256(_response),
            "response bytes mismatch"
        );
    }
}// MIT
pragma solidity ^0.8.0;



contract TipJar is AccessControlUpgradeable, CheckAndSend {


    bytes32 public constant TIP_JAR_ADMIN_ROLE = keccak256("TIP_JAR_ADMIN_ROLE");

    bytes32 public constant FEE_SETTER_ROLE = keccak256("FEE_SETTER_ROLE");

    uint32 public networkFee;

    address public networkFeeCollector;

    struct Split {
        address splitTo;
        uint32 splitPct;
    }

    mapping (address => Split) public minerSplits;

    event FeeSet(uint32 indexed newFee, uint32 indexed oldFee);

    event FeeCollectorSet(address indexed newCollector, address indexed oldCollector);

    event MinerSplitUpdated(address indexed miner, address indexed newSplitTo, address indexed oldSplitTo, uint32 newSplit, uint32 oldSplit);

    event Tip(address indexed miner, address indexed tipper, uint256 tipAmount, uint256 splitAmount, uint256 feeAmount, address feeCollector);

    modifier onlyAdmin() {

        require(hasRole(TIP_JAR_ADMIN_ROLE, msg.sender), "Caller must have TIP_JAR_ADMIN_ROLE role");
        _;
    }

    modifier onlyMinerOrAdmin(address miner) {

        require(msg.sender == miner || hasRole(TIP_JAR_ADMIN_ROLE, msg.sender), "Caller must be miner or have TIP_JAR_ADMIN_ROLE role");
        _;
    }

    modifier onlyFeeSetter() {

        require(hasRole(FEE_SETTER_ROLE, msg.sender), "Caller must have FEE_SETTER_ROLE role");
        _;
    }

    function initialize(
        address _tipJarAdmin,
        address _feeSetter,
        address _networkFeeCollector,
        uint32 _networkFee
    ) public initializer {

        _setRoleAdmin(TIP_JAR_ADMIN_ROLE, TIP_JAR_ADMIN_ROLE);
        _setRoleAdmin(FEE_SETTER_ROLE, TIP_JAR_ADMIN_ROLE);
        _setupRole(TIP_JAR_ADMIN_ROLE, _tipJarAdmin);
        _setupRole(FEE_SETTER_ROLE, _feeSetter);
        networkFeeCollector = _networkFeeCollector;
        emit FeeCollectorSet(_networkFeeCollector, address(0));
        networkFee = _networkFee;
        emit FeeSet(_networkFee, 0);
    }

    receive() external payable {}

    fallback() external payable {}

    function check32BytesAndSend(
        address _target,
        bytes calldata _payload,
        bytes32 _resultMatch
    ) external payable {

        _check32Bytes(_target, _payload, _resultMatch);
    }

    function check32BytesAndTip(
        address _target,
        bytes calldata _payload,
        bytes32 _resultMatch
    ) external payable {

        _check32Bytes(_target, _payload, _resultMatch);
        tip();
    }

    function check32BytesAndSendMulti(
        address[] calldata _targets,
        bytes[] calldata _payloads,
        bytes32[] calldata _resultMatches
    ) external payable {

        _check32BytesMulti(_targets, _payloads, _resultMatches);
    }

    function check32BytesAndTipMulti(
        address[] calldata _targets,
        bytes[] calldata _payloads,
        bytes32[] calldata _resultMatches
    ) external payable {

        _check32BytesMulti(_targets, _payloads, _resultMatches);
        tip();
    }

    function checkBytesAndSend(
        address _target,
        bytes calldata _payload,
        bytes calldata _resultMatch
    ) external payable {

        _checkBytes(_target, _payload, _resultMatch);
    }

    function checkBytesAndTip(
        address _target,
        bytes calldata _payload,
        bytes calldata _resultMatch
    ) external payable {

        _checkBytes(_target, _payload, _resultMatch);
        tip();
    }

    function checkBytesAndSendMulti(
        address[] calldata _targets,
        bytes[] calldata _payloads,
        bytes[] calldata _resultMatches
    ) external payable {

        _checkBytesMulti(_targets, _payloads, _resultMatches);
    }

    function checkBytesAndTipMulti(
        address[] calldata _targets,
        bytes[] calldata _payloads,
        bytes[] calldata _resultMatches
    ) external payable {

        _checkBytesMulti(_targets, _payloads, _resultMatches);
        tip();
    }

    function tip() public payable {

        uint256 tipAmount;
        uint256 feeAmount;
        uint256 splitAmount;
        if (networkFee > 0) {
            feeAmount = (address(this).balance * networkFee) / 1000000;
            (bool feeSuccess, ) = networkFeeCollector.call{value: feeAmount}("");
            require(feeSuccess, "Could not collect fee");
        }

        if(minerSplits[block.coinbase].splitPct > 0) {
            splitAmount = (address(this).balance * minerSplits[block.coinbase].splitPct) / 1000000;
            (bool splitSuccess, ) = minerSplits[block.coinbase].splitTo.call{value: splitAmount}("");
            require(splitSuccess, "Could not split");
        }

        if (address(this).balance > 0) {
            tipAmount = address(this).balance;
            (bool success, ) = block.coinbase.call{value: tipAmount}("");
            require(success, "Could not collect ETH");
        }
        
        emit Tip(block.coinbase, msg.sender, tipAmount, splitAmount, feeAmount, networkFeeCollector);
    }

    function setFee(uint32 newFee) external onlyFeeSetter {

        require(newFee <= 1000000, ">100%");
        emit FeeSet(newFee, networkFee);
        networkFee = newFee;
    }

    function setFeeCollector(address newCollector) external onlyAdmin {

        emit FeeCollectorSet(newCollector, networkFeeCollector);
        networkFeeCollector = newCollector;
    }

    function updateMinerSplit(
        address minerAddress, 
        address splitTo, 
        uint32 splitPct
    ) external onlyMinerOrAdmin(minerAddress) {

        Split memory oldSplit = minerSplits[minerAddress];
        address oldSplitTo = oldSplit.splitTo;
        uint32 oldSplitPct = oldSplit.splitPct;
        minerSplits[minerAddress] = Split({
            splitTo: splitTo,
            splitPct: splitPct
        });
        emit MinerSplitUpdated(minerAddress, splitTo, oldSplitTo, splitPct, oldSplitPct);
    }
}