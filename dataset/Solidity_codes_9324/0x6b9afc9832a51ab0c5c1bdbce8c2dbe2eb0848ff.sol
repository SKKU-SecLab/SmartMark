pragma solidity >=0.7.0 <0.9.0;

contract Enum {

    enum Operation {Call, DelegateCall}
}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// LGPL-3.0-only

pragma solidity >=0.7.0 <0.9.0;


interface IAvatar {

    function enableModule(address module) external;


    function disableModule(address prevModule, address module) external;


    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success);


    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success, bytes memory returnData);


    function isModuleEnabled(address module) external view returns (bool);


    function getModulesPaginated(address start, uint256 pageSize)
        external
        view
        returns (address[] memory array, address next);

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
}// LGPL-3.0-only

pragma solidity >=0.7.0 <0.9.0;


abstract contract FactoryFriendly is OwnableUpgradeable {
    function setUp(bytes memory initializeParams) public virtual;
}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;


interface IGuard {

    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external;


    function checkAfterExecution(bytes32 txHash, bool success) external;

}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;


abstract contract BaseGuard is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IGuard).interfaceId || // 0xe6d7a83a
            interfaceId == type(IERC165).interfaceId; // 0x01ffc9a7
    }

    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external virtual;

    function checkAfterExecution(bytes32 txHash, bool success) external virtual;
}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;


contract Guardable is OwnableUpgradeable {

    event ChangedGuard(address guard);

    address public guard;

    function setGuard(address _guard) external onlyOwner {

        if (_guard != address(0)) {
            require(
                BaseGuard(_guard).supportsInterface(type(IGuard).interfaceId),
                "Guard does not implement IERC165"
            );
        }
        guard = _guard;
        emit ChangedGuard(guard);
    }

    function getGuard() external view returns (address _guard) {

        return guard;
    }
}// LGPL-3.0-only

pragma solidity >=0.7.0 <0.9.0;


abstract contract Module is FactoryFriendly, Guardable {
    event AvatarSet(address indexed previousAvatar, address indexed newAvatar);
    event TargetSet(address indexed previousTarget, address indexed newTarget);

    address public avatar;
    address public target;

    function setAvatar(address _avatar) public onlyOwner {
        address previousAvatar = avatar;
        avatar = _avatar;
        emit AvatarSet(previousAvatar, _avatar);
    }

    function setTarget(address _target) public onlyOwner {
        address previousTarget = target;
        target = _target;
        emit TargetSet(previousTarget, _target);
    }

    function exec(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal returns (bool success) {
        if (guard != address(0)) {
            IGuard(guard).checkTransaction(
                to,
                value,
                data,
                operation,
                0,
                0,
                0,
                address(0),
                payable(0),
                bytes("0x"),
                address(0)
            );
        }
        success = IAvatar(target).execTransactionFromModule(
            to,
            value,
            data,
            operation
        );
        if (guard != address(0)) {
            IGuard(guard).checkAfterExecution(bytes32("0x"), success);
        }
        return success;
    }

    function execAndReturnData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal returns (bool success, bytes memory returnData) {
        if (guard != address(0)) {
            IGuard(guard).checkTransaction(
                to,
                value,
                data,
                operation,
                0,
                0,
                0,
                address(0),
                payable(0),
                bytes("0x"),
                address(0)
            );
        }
        (success, returnData) = IAvatar(target)
            .execTransactionFromModuleReturnData(to, value, data, operation);
        if (guard != address(0)) {
            IGuard(guard).checkAfterExecution(bytes32("0x"), success);
        }
        return (success, returnData);
    }
}// LGPL-3.0-only

pragma solidity >=0.7.0 <0.9.0;


abstract contract Modifier is Module {
    event EnabledModule(address module);
    event DisabledModule(address module);

    address internal constant SENTINEL_MODULES = address(0x1);

    mapping(address => address) internal modules;


    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) public virtual moduleOnly returns (bool success) {}

    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    )
        public
        virtual
        moduleOnly
        returns (bool success, bytes memory returnData)
    {}


    modifier moduleOnly() {
        require(modules[msg.sender] != address(0), "Module not authorized");
        _;
    }

    function disableModule(address prevModule, address module)
        public
        onlyOwner
    {
        require(
            module != address(0) && module != SENTINEL_MODULES,
            "Invalid module"
        );
        require(modules[prevModule] == module, "Module already disabled");
        modules[prevModule] = modules[module];
        modules[module] = address(0);
        emit DisabledModule(module);
    }

    function enableModule(address module) public onlyOwner {
        require(
            module != address(0) && module != SENTINEL_MODULES,
            "Invalid module"
        );
        require(modules[module] == address(0), "Module already enabled");
        modules[module] = modules[SENTINEL_MODULES];
        modules[SENTINEL_MODULES] = module;
        emit EnabledModule(module);
    }

    function isModuleEnabled(address _module) public view returns (bool) {
        return SENTINEL_MODULES != _module && modules[_module] != address(0);
    }

    function getModulesPaginated(address start, uint256 pageSize)
        external
        view
        returns (address[] memory array, address next)
    {
        array = new address[](pageSize);

        uint256 moduleCount = 0;
        address currentModule = modules[start];
        while (
            currentModule != address(0x0) &&
            currentModule != SENTINEL_MODULES &&
            moduleCount < pageSize
        ) {
            array[moduleCount] = currentModule;
            currentModule = modules[currentModule];
            moduleCount++;
        }
        next = currentModule;
        assembly {
            mstore(array, moduleCount)
        }
    }
}// LGPL-3.0-only
pragma solidity >=0.8.0;


contract Delay is Modifier {

    event DelaySetup(
        address indexed initiator,
        address indexed owner,
        address indexed avatar,
        address target
    );
    event TransactionAdded(
        uint256 indexed queueNonce,
        bytes32 indexed txHash,
        address to,
        uint256 value,
        bytes data,
        Enum.Operation operation
    );

    uint256 public txCooldown;
    uint256 public txExpiration;
    uint256 public txNonce;
    uint256 public queueNonce;
    mapping(uint256 => bytes32) public txHash;
    mapping(uint256 => uint256) public txCreatedAt;

    constructor(
        address _owner,
        address _avatar,
        address _target,
        uint256 _cooldown,
        uint256 _expiration
    ) {
        bytes memory initParams =
            abi.encode(_owner, _avatar, _target, _cooldown, _expiration);
        setUp(initParams);
    }

    function setUp(bytes memory initParams) public override {

        (
            address _owner,
            address _avatar,
            address _target,
            uint256 _cooldown,
            uint256 _expiration
        ) =
            abi.decode(
                initParams,
                (address, address, address, uint256, uint256)
            );
        __Ownable_init();
        require(_avatar != address(0), "Avatar can not be zero address");
        require(_target != address(0), "Target can not be zero address");
        require(
            _expiration == 0 || _expiration >= 60,
            "Expiratition must be 0 or at least 60 seconds"
        );

        avatar = _avatar;
        target = _target;
        txExpiration = _expiration;
        txCooldown = _cooldown;

        transferOwnership(_owner);
        setupModules();

        emit DelaySetup(msg.sender, _owner, _avatar, _target);
    }

    function setupModules() internal {

        require(
            modules[SENTINEL_MODULES] == address(0),
            "setUpModules has already been called"
        );
        modules[SENTINEL_MODULES] = SENTINEL_MODULES;
    }

    function setTxCooldown(uint256 cooldown) public onlyOwner {

        txCooldown = cooldown;
    }

    function setTxExpiration(uint256 expiration) public onlyOwner {

        require(
            expiration == 0 || expiration >= 60,
            "Expiratition must be 0 or at least 60 seconds"
        );
        txExpiration = expiration;
    }

    function setTxNonce(uint256 _nonce) public onlyOwner {

        require(
            _nonce > txNonce,
            "New nonce must be higher than current txNonce"
        );
        require(_nonce <= queueNonce, "Cannot be higher than queueNonce");
        txNonce = _nonce;
    }

    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) public override moduleOnly returns (bool success) {

        txHash[queueNonce] = getTransactionHash(to, value, data, operation);
        txCreatedAt[queueNonce] = block.timestamp;
        emit TransactionAdded(
            queueNonce,
            txHash[queueNonce],
            to,
            value,
            data,
            operation
        );
        queueNonce++;
        success = true;
    }

    function executeNextTx(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) public {

        require(txNonce < queueNonce, "Transaction queue is empty");
        require(
            block.timestamp - txCreatedAt[txNonce] >= txCooldown,
            "Transaction is still in cooldown"
        );
        if (txExpiration != 0) {
            require(
                txCreatedAt[txNonce] + txCooldown + txExpiration >=
                    block.timestamp,
                "Transaction expired"
            );
        }
        require(
            txHash[txNonce] == getTransactionHash(to, value, data, operation),
            "Transaction hashes do not match"
        );
        txNonce++;
        require(exec(to, value, data, operation), "Module transaction failed");
    }

    function skipExpired() public {

        while (
            txExpiration != 0 &&
            txCreatedAt[txNonce] + txCooldown + txExpiration <
            block.timestamp &&
            txNonce < queueNonce
        ) {
            txNonce++;
        }
    }

    function getTransactionHash(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(to, value, data, operation));
    }

    function getTxHash(uint256 _nonce) public view returns (bytes32) {

        return (txHash[_nonce]);
    }

    function getTxCreatedAt(uint256 _nonce) public view returns (uint256) {

        return (txCreatedAt[_nonce]);
    }
}