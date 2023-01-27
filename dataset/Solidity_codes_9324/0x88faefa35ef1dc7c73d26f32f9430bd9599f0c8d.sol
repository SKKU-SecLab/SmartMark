


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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


pragma solidity ^0.8.7;

interface ITokenFactory {

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event BridgeChanged(address indexed oldBridge, address indexed newBridge);

    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    event TokenCreated(
        string name,
        string indexed symbol,
        uint256 amount,
        uint8 decimal,
        uint256 cap,
        address indexed token
    );

    event TokenRemoved(address indexed token);

    event TokenDecimalChanged(
        address indexed token,
        uint8 oldDecimal,
        uint8 newDecimal
    );

    function owner() external view returns (address);


    function tokens() external view returns (address[] memory);


    function tokenExist(address token) external view returns (bool);


    function bridge() external view returns (address);


    function admin() external view returns (address);


    function setBridge(address bridge) external;


    function setAdmin(address admin) external;


    function createToken(
        string memory name,
        string memory symbol,
        uint256 amount,
        uint8 decimal,
        uint256 cap
    ) external returns (address token);


    function removeToken(address token) external;


    function setTokenDecimal(address token, uint8 decimal) external;

}



pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity ^0.8.7;

interface ITokenMintable is IERC20Upgradeable {

    function initialize(
        address factory,
        string memory name,
        string memory symbol,
        uint256 amount,
        uint8 decimal,
        uint256 cap
    ) external;


    function factory() external view returns (address);


    function decimals() external view returns (uint8);


    function cap() external view returns (uint256);


    function mint(address to, uint256 amount) external;


    function burn(uint256 amount) external;


    function increaseCap(uint256 cap) external;


    function setupDecimal(uint8 decimal) external;

}



pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot)
        internal
        pure
        returns (AddressSlot storage r)
    {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot)
        internal
        pure
        returns (BooleanSlot storage r)
    {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot)
        internal
        pure
        returns (Bytes32Slot storage r)
    {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot)
        internal
        pure
        returns (Uint256Slot storage r)
    {

        assembly {
            r.slot := slot
        }
    }
}



pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}



pragma solidity ^0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
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

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}



pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}



pragma solidity ^0.8.0;

contract UpgradeableBeacon is IBeacon, Ownable {

    address private _implementation;

    event Upgraded(address indexed implementation);

    constructor(address implementation_) {
        _setImplementation(implementation_);
    }

    function implementation() public view virtual override returns (address) {

        return _implementation;
    }

    function upgradeTo(address newImplementation) public virtual onlyOwner {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(
            Address.isContract(newImplementation),
            "UpgradeableBeacon: implementation is not a contract"
        );
        _implementation = newImplementation;
    }
}


pragma solidity ^0.8.7;

contract TokenBeacon is UpgradeableBeacon {

    UpgradeableBeacon immutable _beacon;

    constructor(address impl) Ownable() UpgradeableBeacon(impl) {
        _beacon = new UpgradeableBeacon(impl);
        transferOwnership(tx.origin);
    }

    function beacon() external view returns (address) {

        return address(_beacon);
    }
}



pragma solidity ^0.8.2;

abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT =
        0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(
            Address.isContract(newImplementation),
            "ERC1967: new implementation is not a contract"
        );
        StorageSlot
            .getAddressSlot(_IMPLEMENTATION_SLOT)
            .value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot
            .getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(
                oldImplementation == _getImplementation(),
                "ERC1967Upgrade: upgrade breaks further upgrades"
            );
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(
            newAdmin != address(0),
            "ERC1967: new admin is the zero address"
        );
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT =
        0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(
            Address.isContract(newBeacon),
            "ERC1967: new beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(
                IBeacon(newBeacon).implementation(),
                data
            );
        }
    }
}



pragma solidity ^0.8.0;

contract BeaconProxy is Proxy, ERC1967Upgrade {

    constructor(address beacon, bytes memory data) payable {
        assert(
            _BEACON_SLOT ==
                bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1)
        );
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    function _beacon() internal view virtual returns (address) {

        return _getBeacon();
    }

    function _implementation()
        internal
        view
        virtual
        override
        returns (address)
    {

        return IBeacon(_getBeacon()).implementation();
    }

    function _setBeacon(address beacon, bytes memory data) internal virtual {

        _upgradeBeaconToAndCall(beacon, data, false);
    }
}



pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(
            _initializing || !_initialized,
            "Initializable: contract is already initialized"
        );

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
}


pragma solidity ^0.8.7;

contract TokenMintableUpgradeable is Initializable, ITokenMintable {

    address private _factory;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint256 private _cap;
    uint8 private _decimal;

    function factory() public view virtual override returns (address) {

        return _factory;
    }

    modifier onlyBridgeOwner() {

        require(ITokenFactory(factory()).bridge() == msg.sender, "OAO");
        _;
    }

    modifier onlyBridgeAdminOwner() {

        require(ITokenFactory(factory()).admin() == msg.sender, "OAO");
        _;
    }

    function initialize(
        address factory_,
        string memory name_,
        string memory symbol_,
        uint256 amount,
        uint8 decimal_,
        uint256 cap_
    ) external override initializer {

        __Token_init(factory_, name_, symbol_, amount, decimal_, cap_);
    }

    function __Token_init(
        address factory_,
        string memory name_,
        string memory symbol_,
        uint256 amount,
        uint8 decimal_,
        uint256 cap_
    ) private initializer {

        require(cap_ > 0, "ERC20Capped: cap is 0");
        _factory = factory_;
        _name = name_;
        _symbol = symbol_;
        _decimal = decimal_;
        _cap = cap_;
        _mint(ITokenFactory(factory()).owner(), amount);
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return _decimal > 0 ? _decimal : 18;
    }

    function cap() public view virtual override returns (uint256) {

        return _cap;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {

        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function increaseCap(uint256 cap_) external override onlyBridgeAdminOwner {

        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap += cap_;
    }

    function mint(address to, uint256 amount)
        external
        override
        onlyBridgeOwner
    {

        require(_cap > amount, "Daily cap limit reached");
        _mint(to, amount);
    }

    function burn(uint256 amount) external override {

        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {

        uint256 currentAllowance = allowance(account, msg.sender);
        require(
            currentAllowance >= amount,
            "ERC20: burn amount exceeds allowance"
        );
        unchecked {
            _approve(account, msg.sender, currentAllowance - amount);
        }
        _burn(account, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        _cap -= amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(
            ITokenFactory(factory()).bridge() != address(0),
            "Bridge is zero address"
        );
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, ITokenFactory(factory()).bridge(), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function setupDecimal(uint8 decimal_) external virtual {

        require(msg.sender == _factory, "OF");
        require(decimal_ > 0, "ERC20: Invalid decimal");
        _decimal = decimal_;
    }
}



pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}



pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}


pragma solidity ^0.8.7;

contract TokenFactoryUpgradeable is
    Initializable,
    OwnableUpgradeable,
    ITokenFactory
{

    TokenBeacon private _beacon;
    uint8 private _activeTokenCount;
    address private _bridge;
    address[] private _tokens;
    mapping(address => bool) private _mapTokens;
    address private _admin;

    function __TokenFactory_init(address impl) internal initializer {

        __Ownable_init();
        _beacon = new TokenBeacon(impl);
    }

    function beacon() external view returns (address) {

        return address(_beacon);
    }

    function owner()
        public
        view
        virtual
        override(OwnableUpgradeable, ITokenFactory)
        returns (address)
    {

        return OwnableUpgradeable.owner();
    }

    function tokens() external view override returns (address[] memory) {

        address[] memory tokens_ = new address[](_activeTokenCount);
        uint64 k = 0;
        for (uint64 i = 0; i < _tokens.length; i++) {
            if (_mapTokens[_tokens[i]]) {
                tokens_[k++] = _tokens[i];
            }
        }
        return tokens_;
    }

    function tokenExist(address token_)
        external
        view
        virtual
        override
        returns (bool)
    {

        return _mapTokens[token_];
    }

    function bridge() external view override returns (address) {

        return _bridge;
    }

    function admin() external view override returns (address) {

        return _admin;
    }

    function createToken(
        string memory name,
        string memory symbol,
        uint256 amount,
        uint8 decimal,
        uint256 cap
    ) external virtual override onlyOwner returns (address token) {

        BeaconProxy _proxy = new BeaconProxy(
            address(_beacon),
            abi.encodeWithSelector(
                TokenMintableUpgradeable(address(0)).initialize.selector,
                address(this),
                name,
                symbol,
                amount,
                decimal,
                cap
            )
        );
        token = address(_proxy);
        _activeTokenCount++;
        _mapTokens[token] = true;
        _tokens.push(token);
        emit TokenCreated(name, symbol, amount, decimal, cap, token);
    }

    function removeToken(address token) external virtual override onlyOwner {

        require(_mapTokens[token], "TXE");
        _activeTokenCount--;
        _mapTokens[token] = false;
        emit TokenRemoved(token);
    }

    function setBridge(address bridge_) external virtual override onlyOwner {

        emit BridgeChanged(_bridge, bridge_);
        _bridge = bridge_;
    }

    function setAdmin(address admin_) external virtual override onlyOwner {

        emit AdminChanged(_admin, admin_);
        _admin = admin_;
    }

    function setTokenDecimal(address token, uint8 decimal)
        external
        virtual
        override
        onlyOwner
    {

        require(_mapTokens[token], "TXE");
        require(decimal > 0, "ERC20: Invalid decimal");
        emit TokenDecimalChanged(
            token,
            ITokenMintable(token).decimals(),
            decimal
        );
        ITokenMintable(token).setupDecimal(decimal);
    }
}


pragma solidity ^0.8.7;

contract EthereumTokenFactory is TokenFactoryUpgradeable {

    function initialize(address impl) public initializer {

        __TokenFactory_init(impl);
    }
}