
pragma solidity ^0.8.7;

interface ISharedData {

    struct Token {
        address _tokenAddress;
        uint256 _presaleRate;
    }

    struct VestingInfo {
        uint256 _time;
        uint256 _percent;
    }

    struct VestingInfoParams {
        VestingInfo[] _vestingInfo;
    }

    struct IDOParams {
        uint256 _minimumContributionLimit;
        uint256 _maximumContributionLimit;
        uint256 _softCap;
        uint256 _hardCap;
        uint256 _startDepositTime;
        uint256 _endDepositTime;
        uint256 _presaleRate;
        address _tokenAddress;
        address _admin;
        address _manager;
        Token[] _tokens;
        address[] _allowance;
        VestingInfo[] _vestingInfo;
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

pragma solidity ^0.8.7;


interface IIDO is IAccessControlUpgradeable, ISharedData {

    event Claim(address indexed user, uint256 amount);
    event Refund(address indexed user, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event DepositToken(
        address indexed currency,
        address indexed user,
        uint256 amount
    );

    function initialize(IDOParams memory params) external;


    function deposit() external payable;


    function claim() external;


    function refund() external;


    function transferBalance(uint256 tokenId) external;


    function getStatus() external view returns (string memory);


    function pause() external;


    function unpause() external;

}// MIT

pragma solidity ^0.8.7;


interface IIDOAllowance is IIDO {

    function initialize(IDOParams memory params) external override;


    function addAllowance(address _allowance) external;


    function removeAllowance(address _allowance) external;


    function deposit() external payable override;


    function claim() external override;


    function refund() external override;

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
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.7;


contract Whitelist is Initializable, OwnableUpgradeable, PausableUpgradeable {

    mapping(address => bool) whitelist;
    mapping(address => bool) managers;

    event AddedToWhitelist(address indexed account);
    event RemovedFromWhitelist(address indexed account);

    modifier onlyWhitelist(address _address) {

        require(
            isWhitelisted(_address),
            "Not a whitelist token project address"
        );
        _;
    }

    modifier onlyManager() {

        require(managers[msg.sender], "Caller is not the manager");
        _;
    }

    function managerAdd(address _manager) public onlyOwner {

        managers[_manager] = true;
    }

    function managerRemove(address _manager) public onlyOwner {

        managers[_manager] = false;
    }

    function isManager(address _manager) public view returns (bool) {

        return managers[_manager];
    }

    function __Whitelist_init(address creator) public initializer {

        __Pausable_init();
        __Ownable_init();

        transferOwnership(creator);
    }

    function whitelistAdd(address _address) public onlyManager {

        whitelist[_address] = true;
        emit AddedToWhitelist(_address);
    }

    function whitelistRemove(address _address) public onlyManager {

        whitelist[_address] = false;
        emit RemovedFromWhitelist(_address);
    }

    function isWhitelisted(address _address) public view returns (bool) {

        return whitelist[_address];
    }

    function pause() public onlyManager {

        _pause();
    }

    function unpause() public onlyManager {

        _unpause();
    }
}// MIT

pragma solidity ^0.8.7;

abstract contract Proxy {
    function _delegate(address implementation) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}// MIT

pragma solidity ^0.8.7;

contract ProxyOwnable {

    bytes32 private constant _ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    constructor(address _owner) payable {
        assert(
            _ADMIN_SLOT ==
                bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1)
        );
        _setAdmin(_owner);
    }

    modifier ifAdmin() {

        require(msg.sender == _admin(), "Ownable: caller is not the admin");
        _;
    }

    function _admin() internal view returns (address adm) {

        bytes32 slot = _ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    function changeAdmin(address newAdmin) external ifAdmin {

        require(
            newAdmin != address(0),
            "TransparentUpgradeableProxy: new admin is the zero address"
        );
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    function _setAdmin(address newAdmin) private {

        bytes32 slot = _ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }
}// MIT
pragma solidity ^0.8.7;

contract UpgradableProxy is Proxy, ProxyOwnable {

    bytes32 private constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address implementation_, address _owner) ProxyOwnable(_owner) {
        _setImplementation(implementation_);
    }

    function upgradeDelegate(address newDelegateAddress) public ifAdmin {

        _setImplementation(newDelegateAddress);
    }

    function _setImplementation(address newImplementation) private {

        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }

    function _implementation()
        internal
        view
        virtual
        override
        returns (address impl)
    {

        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }
}// MIT
pragma solidity ^0.8.7;

contract IDOProxy is UpgradableProxy {

    constructor(address _implementation, address owner)
        UpgradableProxy(_implementation, owner)
    {}
}// MIT

pragma solidity ^0.8.7;


contract IDOFactory is Whitelist, ISharedData {

    uint256 public idoId;
    uint256 public idoAllowanceId;
    address[] public IDOs;
    address[] public implementations;

    event CreateIDO(address indexed ido, uint256 id);

    modifier paramsVerification(IDOParams memory params) {

        require(
            params._minimumContributionLimit <=
                params._maximumContributionLimit,
            "Minimum Contribution Limit should be lower or equel than Maximum Contribution Limit"
        );
        require(
            params._softCap <= params._hardCap,
            "softCap should be lower or equel than hardCap"
        );
        require(
            params._startDepositTime < params._endDepositTime,
            "Start Deposit Time should be lower or equel than End Deposit Time"
        );

        require(params._vestingInfo.length > 0, "vesting Info needed");

        require(
            params._vestingInfo[0]._time >= params._endDepositTime,
            "Start Claim Time should be more than End Deposit Time"
        );

        if (params._vestingInfo.length > 1) {
            for (
                uint256 index = 0;
                index < params._vestingInfo.length - 1;
                index++
            ) {
                require(
                    params._vestingInfo[index + 1]._time >
                        params._vestingInfo[index]._time,
                    "Start Claim Time should be lower or equel than End Deposit Time"
                );
            }
        }

        require(
            params._maximumContributionLimit <= params._hardCap,
            "Maximum Contribution Limit should be lower or equel than Hard Cap"
        );
        _;
    }

    function initialize(address owner) public initializer {

        __Whitelist_init(owner);
        managerAdd(owner);
        idoId = 0;
        idoAllowanceId = 1;
    }

    function createIDOContract(IDOParams memory params)
        external
        onlyManager
        whenNotPaused
        paramsVerification(params)
        onlyWhitelist(params._tokenAddress)
    {

        address[] memory allowances = params._allowance;
        address newIDO;
        if (allowances.length > 0) {
            newIDO = address(
                new IDOProxy(implementations[idoAllowanceId], owner())
            );
            IIDOAllowance(newIDO).initialize(params);
        } else {
            newIDO = address(new IDOProxy(implementations[idoId], owner()));
            IIDO(newIDO).initialize(params);
        }
        IDOs.push(newIDO);

        emit CreateIDO(newIDO, IDOs.length - 1);
    }

    function setIdoId(uint256 id) public onlyManager {

        idoId = id;
    }

    function setIdoAllowanceId(uint256 id) public onlyManager {

        idoAllowanceId = id;
    }

    function addImplementation(address _address) public onlyManager {

        implementations.push(_address);
    }
}