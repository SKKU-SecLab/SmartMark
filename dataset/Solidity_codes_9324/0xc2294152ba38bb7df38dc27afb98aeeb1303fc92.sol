
pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

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

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
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

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
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
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
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
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

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

    uint256[45] private __gap;
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
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
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

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}// MIT
pragma solidity 0.8.2;
pragma experimental ABIEncoderV2;


contract ARDImplementationV1 is ERC20Upgradeable, 
                                OwnableUpgradeable, 
                                AccessControlUpgradeable,
                                PausableUpgradeable, 
                                ReentrancyGuardUpgradeable {


    using SafeMath for uint256;

    bytes32 public constant SUPER_ADMIN_ROLE = keccak256("SUPER_ADMIN_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant ASSET_PROTECTION_ROLE = keccak256("ASSET_PROTECTION_ROLE");
    bytes32 public constant SUPPLY_CONTROLLER_ROLE = keccak256("SUPPLY_CONTROLLER_ROLE");

    modifier onlySuperAdminRole() {

        require(hasRole(SUPER_ADMIN_ROLE, _msgSender()), "only super admin role");
        _;
    }

    modifier onlyAssetProtectionRole() {

        require(hasRole(ASSET_PROTECTION_ROLE, _msgSender()), "only asset protection role");
        _;
    }

    modifier onlySupplyController() {

        require(hasRole(SUPPLY_CONTROLLER_ROLE, _msgSender()), "only supply controller role");
        _;
    }

    modifier onlyMinterRole() {

        require(hasRole(MINTER_ROLE, _msgSender()), "only minter role");
        _;
    }

    modifier onlyBurnerRole() {

        require(hasRole(BURNER_ROLE, _msgSender()), "only burner role");
        _;
    }

    modifier notPaused() {

        require(!paused(), "is paused");
        _;
    }
    event AddressFrozen(address indexed addr);
    event AddressUnfrozen(address indexed addr);
    event FrozenAddressWiped(address indexed addr);
    event AssetProtectionRoleSet (
        address indexed oldAssetProtectionRole,
        address indexed newAssetProtectionRole
    );

    event SupplyIncreased(address indexed to, uint256 value);
    event SupplyDecreased(address indexed from, uint256 value);
    event SupplyControllerSet(
        address indexed oldSupplyController,
        address indexed newSupplyController
    );


    uint8 internal _decimals;

    address internal _curSuperadmin;

    mapping(address => bool) internal frozen;

    function _initialize(string memory name_, string memory symbol_, address newowner_) internal {

        __Ownable_init();
        __ERC20_init(name_, symbol_);

        address owner_ =  newowner_==address(0) ?  _msgSender() : newowner_;
        
        _setRoleAdmin(SUPER_ADMIN_ROLE, SUPER_ADMIN_ROLE);
        _curSuperadmin = owner_;
        _setRoleAdmin(ADMIN_ROLE, SUPER_ADMIN_ROLE);
        _setRoleAdmin(MINTER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(BURNER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(ASSET_PROTECTION_ROLE, ADMIN_ROLE);
        _setRoleAdmin(SUPPLY_CONTROLLER_ROLE, ADMIN_ROLE);

        _setupRole(SUPER_ADMIN_ROLE, owner_);
        _grantAllRoles(owner_);

        if (owner_!=_msgSender()) {
            _transferOwnership(owner_);
        }
        _decimals = 6;
    }

    function decimals() public view virtual override returns (uint8) {

        return _decimals;
    }

    function protocolVersion() public pure returns (bytes32) {

        return "1.0";
    }
    function transferOwnershipAndRoles(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _revokeAllRoles(owner());
        _grantAllRoles(newOwner);
        if (_curSuperadmin==owner()) {
            transferSupeAdminTo(newOwner);
        }
        _transferOwnership(newOwner);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override virtual {

        require(!paused(),"is paused");
        require(amount>0, "zero amount");
        require(!frozen[_msgSender()], "caller is frozen");
        require(!frozen[from] || from==address(0), "address from is frozen");
        require(!frozen[to] || to==address(0), "address to is frozen");
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override virtual {


        require(amount>0,"zero amount");
        if (from == address(0)) {       // is minted
            emit SupplyIncreased( to, amount);
        } else if (to == address(0)) {  // is burned
            emit SupplyDecreased( from, amount);
        }
        
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        require(!paused(),"is paused");
        require(!frozen[_msgSender()], "caller is frozen");
        require(!frozen[spender], "address spender is frozen");
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function pause() public onlySuperAdminRole {

        _pause();
    }

    function unpause() public onlySuperAdminRole {

        _unpause();
    }

    function grantRole(bytes32 role, address account) public override notPaused onlyRole(getRoleAdmin(role)) {

        require(account!=address(0),"zero account");
        require(role!=SUPER_ADMIN_ROLE,"invalid role");
        _grantRole(role, account);
    }

    function _grantAllRoles(address account) internal {

        require(account!=address(0),"zero account");
        _grantRole(ADMIN_ROLE, account);
        _grantRole(MINTER_ROLE, account);
        _grantRole(BURNER_ROLE, account);
        _grantRole(ASSET_PROTECTION_ROLE, account);
        _grantRole(SUPPLY_CONTROLLER_ROLE, account);
    }

    function revokeRole(bytes32 role, address account) public override notPaused onlyRole(getRoleAdmin(role)) {

        require(account!=address(0),"zero account");
        require(role!=SUPER_ADMIN_ROLE,"invalid role");
        _revokeRole(role, account);
    }

    function _revokeAllRoles(address account) internal {

        require(account!=address(0),"zero account");
        _revokeRole(ADMIN_ROLE, account);
        _revokeRole(MINTER_ROLE, account);
        _revokeRole(BURNER_ROLE, account);
        _revokeRole(ASSET_PROTECTION_ROLE, account);
        _revokeRole(SUPPLY_CONTROLLER_ROLE, account);
    }

    function transferSupeAdminTo(address _addr) public notPaused onlyOwner {

        _revokeRole(SUPER_ADMIN_ROLE, _curSuperadmin);
        _grantRole(SUPER_ADMIN_ROLE, _addr);
        _curSuperadmin=_addr;
    }
    function superAdmin() public view returns (address) {

        return _curSuperadmin;
    }

    function setAdminRole(address _addr) public {

        grantRole(ADMIN_ROLE, _addr);
    }
    function revokeAdminRole(address _addr) public {

        revokeRole(ADMIN_ROLE, _addr);
    }
    function isAdmin(address _addr) public view returns (bool) {

        return hasRole(ADMIN_ROLE, _addr);
    }

    function setMinterRole(address _addr) public {

        grantRole(MINTER_ROLE, _addr);
    }
    function revokeMinterRole(address _addr) public {

        revokeRole(MINTER_ROLE, _addr);
    }
    function isMinter(address _addr) public view returns (bool) {

        return hasRole(MINTER_ROLE, _addr);
    }

    function setBurnerRole(address _addr) public {

        grantRole(BURNER_ROLE, _addr);
    }
    function revokeBurnerRole(address _addr) public {

        revokeRole(BURNER_ROLE, _addr);
    }
    function isBurner(address _addr) public view returns (bool) {

        return hasRole(BURNER_ROLE, _addr);
    }

    function setAssetProtectionRole(address _addr) public {

        grantRole(ASSET_PROTECTION_ROLE, _addr);
    }
    function revokeAssetProtectionRole(address _addr) public {

        revokeRole(ASSET_PROTECTION_ROLE, _addr);
    }
    function isAssetProtection(address _addr) public view returns (bool) {

        return hasRole(ASSET_PROTECTION_ROLE, _addr);
    }

    function setSupplyControllerRole(address _addr) public {

        grantRole(SUPPLY_CONTROLLER_ROLE, _addr);
    }
    function revokeSupplyControllerRole(address _addr) public {

        revokeRole(SUPPLY_CONTROLLER_ROLE, _addr);
    }
    function isSupplyController(address _addr) public view returns (bool) {

        return hasRole(SUPPLY_CONTROLLER_ROLE, _addr);
    }

    function freeze(address _addr) public notPaused onlyAssetProtectionRole {

        require(_addr!=owner(), "can't freeze owner");
        require(_addr!=_msgSender(), "can't freeze itself");
        require(!frozen[_addr], "address already frozen");
        frozen[_addr] = true;
        emit AddressFrozen(_addr);
    }

    function unfreeze(address _addr) public notPaused onlyAssetProtectionRole {

        require(frozen[_addr], "address already unfrozen");
        frozen[_addr] = false;
        emit AddressUnfrozen(_addr);
    }

    function wipeFrozenAddress(address _addr) public notPaused onlyAssetProtectionRole {

        require(frozen[_addr], "address is not frozen");
        uint256 _balance = balanceOf(_addr);
        frozen[_addr] = false;
        _burn(_addr,_balance);
        frozen[_addr] = true;
        emit FrozenAddressWiped(_addr);
    }

    function isFrozen(address _addr) public view returns (bool) {

        return frozen[_addr];
    }



    function mint(address account, uint256 amount) public onlyMinterRole {

        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyBurnerRole {

        _burn(account, amount);
    }

    function increaseSupply(uint256 _value) public onlySupplyController returns (bool) {

        _mint(_msgSender(), _value);
        return true;
    }

    function decreaseSupply(uint256 _value) public onlySupplyController returns (bool) {

        require(_value <= balanceOf(_msgSender()), "not enough supply");
        _burn(_msgSender(), _value);
        return true;
    }

    uint256[50] private __stgap0;
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.0;

library SafeCast {

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// MIT
pragma solidity ^0.8.0;


library Checkpoints {

    struct Checkpoint {
        uint32 _blockNumber;
        uint224 _value;
    }

    struct History {
        Checkpoint[] _checkpoints;
    }

    function latest(History storage self) internal view returns (uint256) {

        uint256 pos = self._checkpoints.length;
        return pos == 0 ? 0 : self._checkpoints[pos - 1]._value;
    }

    function getAtBlock(History storage self, uint256 blockNumber) internal view returns (uint256) {

        require(blockNumber < block.number, "Checkpoints: block not yet mined");

        uint256 high = self._checkpoints.length;
        uint256 low = 0;
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (self._checkpoints[mid]._blockNumber > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high == 0 ? 0 : self._checkpoints[high - 1]._value;
    }

    function push(History storage self, uint256 value) internal returns (uint256, uint256) {

        uint256 pos = self._checkpoints.length;
        uint256 old = latest(self);
        if (pos > 0 && self._checkpoints[pos - 1]._blockNumber == block.number) {
            self._checkpoints[pos - 1]._value = SafeCast.toUint224(value);
        } else {
            self._checkpoints.push(
                Checkpoint({_blockNumber: SafeCast.toUint32(block.number), _value: SafeCast.toUint224(value)})
            );
        }
        return (old, value);
    }

    function push(
        History storage self,
        function(uint256, uint256) view returns (uint256) op,
        uint256 delta
    ) internal returns (uint256, uint256) {

        return push(self, op(latest(self), delta));
    }
}// MIT
pragma solidity 0.8.2;


contract StakingTokenV1 is ARDImplementationV1 {

    using SafeMath for uint256;
    using SafeMath for uint64;

    struct Stake {
        uint256 id;
        uint256 stakedAt; 
        uint256 value;
        uint64  lockPeriod;
    }

    struct StakeHolder {
        uint256 totalStaked;
        Stake[] stakes;
    }

    struct Rate {
        uint256 timestamp;
        uint256 rate;
    }

    struct RateHistory {
        Rate[] rates;
    }

    address internal tokenBank;

    bool internal stakingEnabled;
    
    bool internal earlyUnstakingAllowed;

    uint256 internal minStake;

    uint256 internal _lastStakeID;

    Checkpoints.History internal totalStakedHistory;

    mapping(address => StakeHolder) internal stakeholders;

    mapping(uint256 => RateHistory) internal rewardTable;
    mapping(uint256 => RateHistory) internal punishmentTable;


    modifier onlyActiveStaking() {

        require(stakingEnabled, "staking protocol stopped");
        _;
    }

    event Staked(address indexed from, uint256 amount, uint256 newStake, uint256 oldStake);
    event Unstaked(address indexed from, uint256 amount, uint256 newStake, uint256 oldStake);
    event RewardRateChanged(uint256 timestamp, uint256 newRate, uint256 oldRate);
    event PunishmentRateChanged(uint256 timestamp, uint256 newRate, uint256 oldRate);
    event StakingStatusChanged(bool _enabled);
    event earlyUnstakingAllowanceChanged(bool _isAllowed);
    constructor() {
        _pause();
    }

    function initialize(string memory name_, string memory symbol_, address newowner_) public initializer{

        _initialize(name_, symbol_, newowner_);
        
        _setupRole(MINTER_ROLE, address(this));

        _lastStakeID = 0;

        stakingEnabled=false;

        earlyUnstakingAllowed=false;

        minStake=500000000;

        tokenBank=0x2a2e06169b9BF7F611b518185CEf7c3740CdAeeE;

        _setReward(30,   25);
        _setReward(90,   100);
        _setReward(180,  250);
        _setReward(360,  600);

        _setPunishment(30,   1250);
        _setPunishment(90,   1250);
        _setPunishment(180,  1250);
        _setPunishment(360,  1250);
    }

    function setTokenBank(address _tb)
        public
        notPaused
        onlySupplyController
    {

        tokenBank=_tb;
    }

    function getTokenBank()
        public
        view
        returns(address)
    {

        return tokenBank;
    }    
    
    function enableStakingProtocol(bool _enabled)
        public
        notPaused
        onlySupplyController
    {

        require(stakingEnabled!=_enabled, "same as it is");
        stakingEnabled=_enabled;
        emit StakingStatusChanged(_enabled);
    }

    function isStakingProtocolEnabled()
        public
        view
        returns(bool)
    {

        return stakingEnabled;
    }

    function enableEarlyUnstaking(bool _enabled)
        public
        notPaused
        onlySupplyController
    {

        require(earlyUnstakingAllowed!=_enabled, "same as it is");
        earlyUnstakingAllowed=_enabled;
        emit earlyUnstakingAllowanceChanged(_enabled);
    }

    function isEarlyUnstakingAllowed()
        public
        view
        returns(bool)
    {

        return earlyUnstakingAllowed;
    }

    function setMinimumStake(uint256 _minStake)
        public
        notPaused
        onlySupplyController
    {

        minStake=_minStake;
    }

    function minimumAllowedStake()
        public
        view 
        returns (uint256)
    {

        return minStake;
    }

    function stake(uint256 _value, uint64 _lockPeriod)
        public
        returns(uint256)
    {

        return _stake(_msgSender(), _value, _lockPeriod);
    }
    function stakeFor(address _stakeholder, uint256 _value, uint64 _lockPeriod)
        public
        onlySupplyController
        returns(uint256)
    {

        return _stake(_stakeholder, _value, _lockPeriod);
    }

    function unstake(uint256 _stakedID, uint256 _value)
        public
    {

        _unstake(_msgSender(),_stakedID,_value);
    }

    function unstakeFor(address _stakeholder, uint256 _stakedID, uint256 _value)
        public
        onlySupplyController
    {

        _unstake(_stakeholder,_stakedID,_value);
    }

    function stakeOf(address _stakeholder)
        public
        view
        returns(uint256)
    {

        return stakeholders[_stakeholder].totalStaked;
    }

    function stakes(address _stakeholder)
        public
        view
        returns(Stake[] memory)
    {

        return(stakeholders[_stakeholder].stakes);
    }

    function totalStakes()
        public
        view
        returns(uint256)
    {

        return Checkpoints.latest(totalStakedHistory);
    }

    function totalValueLocked()
        public
        view
        returns(uint256)
    {

        return Checkpoints.latest(totalStakedHistory);
    }

    function latest(address _stakeholder) 
        public 
        view 
        returns (uint256) 
    {

        uint256 pos = stakeholders[_stakeholder].stakes.length;
        return pos == 0 ? 0 : stakeholders[_stakeholder].stakes[pos - 1].value;
    }

    function _stake(address _stakeholder, uint256 _value, uint64 _lockPeriod) 
        internal
        notPaused
        onlyActiveStaking
        returns(uint256)
    {

        require(_stakeholder!=address(0),"zero account");
        require(_value >= minStake, "less than minimum stake");
        require(_value<=balanceOf(_stakeholder), "not enough balance");
        require(rewardTable[_lockPeriod].rates.length > 0, "invalid period");
        require(punishmentTable[_lockPeriod].rates.length > 0, "invalid period");

        _transfer(_stakeholder, address(this), _value);
        
        uint256 pos = stakeholders[_stakeholder].stakes.length;
        uint256 old = stakeholders[_stakeholder].totalStaked;
        if (pos > 0 && stakeholders[_stakeholder].stakes[pos - 1].stakedAt == block.timestamp && 
            stakeholders[_stakeholder].stakes[pos - 1].lockPeriod == _lockPeriod) {
                stakeholders[_stakeholder].stakes[pos - 1].value = stakeholders[_stakeholder].stakes[pos - 1].value.add(_value);
        } else {
            _lastStakeID++;
            stakeholders[_stakeholder].stakes.push(Stake({
                id: _lastStakeID,
                stakedAt: block.timestamp,
                value: _value,
                lockPeriod: _lockPeriod
            }));
            pos++;
        }
        stakeholders[_stakeholder].totalStaked = stakeholders[_stakeholder].totalStaked.add(_value);
        _updateTotalStaked(_value, true);

        emit Staked(_stakeholder,_value, stakeholders[_stakeholder].totalStaked, old);
        return(stakeholders[_stakeholder].stakes[pos-1].id);
    }

    function _unstake(address _stakeholder, uint256 _stakedID, uint256 _value) 
        internal 
        notPaused
        onlyActiveStaking
    {

        require(_stakeholder!=address(0),"zero account");
        require(_value > 0, "zero unstake");
        require(_value <= stakeOf(_stakeholder) , "unstake more than staked");
        
        uint256 old = stakeholders[_stakeholder].totalStaked;
        require(stakeholders[_stakeholder].totalStaked>0,"not stake holder");
        uint256 stakeIndex;
        bool found = false;
        for (stakeIndex = 0; stakeIndex < stakeholders[_stakeholder].stakes.length; stakeIndex += 1){
            if (stakeholders[_stakeholder].stakes[stakeIndex].id == _stakedID) {
                found = true;
                break;
            }
        }
        require(found,"invalid stake id");
        require(_value<=stakeholders[_stakeholder].stakes[stakeIndex].value,"not enough stake");
        uint256 _stakedAt = stakeholders[_stakeholder].stakes[stakeIndex].stakedAt;
        require(block.timestamp>=_stakedAt,"invalid stake");
        uint256 stakingDays = (block.timestamp - _stakedAt) / (1 days);
        if (stakingDays>=stakeholders[_stakeholder].stakes[stakeIndex].lockPeriod) {
            uint256 _reward = _calculateReward(_stakedAt, block.timestamp, 
                _value, stakeholders[_stakeholder].stakes[stakeIndex].lockPeriod);
            if (_reward>0) {
                _mint(_stakeholder,_reward);
            }
            _transfer(address(this), _stakeholder, _value);
        } else {
            require (earlyUnstakingAllowed, "early unstaking disabled");
            uint256 _punishment = _calculatePunishment(_stakedAt, block.timestamp, 
                _value, stakeholders[_stakeholder].stakes[stakeIndex].lockPeriod);
            _punishment = _punishment<_value ? _punishment : _value;
            if (_punishment>0) {
                _transfer(address(this), tokenBank, _punishment); 
            }
            uint256 withdrawal = _value.sub( _punishment );
            if (withdrawal>0) {
                _transfer(address(this), _stakeholder, withdrawal);
            }
        }

        stakeholders[_stakeholder].stakes[stakeIndex].value = stakeholders[_stakeholder].stakes[stakeIndex].value.sub(_value);
        if (stakeholders[_stakeholder].stakes[stakeIndex].value==0) {
            removeStakeRecord(_stakeholder, stakeIndex);
        }
        stakeholders[_stakeholder].totalStaked = stakeholders[_stakeholder].totalStaked.sub(_value);

        _updateTotalStaked(_value, false);

        if (stakeholders[_stakeholder].totalStaked==0) {
           delete stakeholders[_stakeholder];
        }

        emit Unstaked(_stakeholder, _value, stakeholders[_stakeholder].totalStaked, old);
    }

    function removeStakeRecord(address _stakeholder, uint index) 
        internal 
    {

        for(uint i = index; i < stakeholders[_stakeholder].stakes.length-1; i++){
            stakeholders[_stakeholder].stakes[i] = stakeholders[_stakeholder].stakes[i+1];      
        }
        stakeholders[_stakeholder].stakes.pop();
    }

    function _updateTotalStaked(uint256 _by, bool _increase) 
        internal 
        onlyActiveStaking
    {

        uint256 currentStake = Checkpoints.latest(totalStakedHistory);

        uint256 newStake;
        if (_increase) {
            newStake = currentStake.add(_by);
        } else {
            newStake = currentStake.sub(_by);
        }

        Checkpoints.push(totalStakedHistory, newStake);
    }

    function lastStakeID()
        public
        view
        returns(uint256)
    {

        return _lastStakeID;
    }
    function isStakeholder(address _address)
        public
        view
        returns(bool)
    {

        return (stakeholders[_address].totalStaked>0);
    }

    function setReward(uint256 _lockPeriod, uint64 _value)
        public
        notPaused
        onlySupplyController
    {

        _setReward(_lockPeriod,_value);
    }

    function setRewardTable(uint64[][] memory _rtbl)
        public
        notPaused
        onlySupplyController
    {

        for (uint64 _rIndex = 0; _rIndex<_rtbl.length; _rIndex++) {
            _setReward(_rtbl[_rIndex][0], _rtbl[_rIndex][1]);
        }
    }

    function _setReward(uint256 _lockPeriod, uint64 _value)
        internal
    {

        require(_value>=0 && _value<=10000, "invalid rate");
        uint256 ratesCount = rewardTable[_lockPeriod].rates.length;
        uint256 oldRate = ratesCount>0 ? rewardTable[_lockPeriod].rates[ratesCount-1].rate : 0;
        require(_value!=oldRate, "duplicate rate");
        rewardTable[_lockPeriod].rates.push(Rate({
            timestamp: block.timestamp,
            rate: _value
        }));
        emit RewardRateChanged(block.timestamp,_value,oldRate);
    }

    function rewardRate(uint256 _lockPeriod)
        public
        view
        returns(uint256)
    {

        require(rewardTable[_lockPeriod].rates.length>0,"no rate");
        return _lastRate(rewardTable[_lockPeriod]);
    }

    function rewardRateHistory(uint256 _lockPeriod)
        public
        view
        returns(RateHistory memory)
    {

        require(rewardTable[_lockPeriod].rates.length>0,"no rate");
        return rewardTable[_lockPeriod];
    }

    function setPunishment(uint256 _lockPeriod, uint64 _value)
        public
        notPaused
        onlySupplyController
    {

        _setPunishment(_lockPeriod, _value);
    }

    function setPunishmentTable(uint64[][] memory _ptbl)
        public
        notPaused
        onlySupplyController
    {

        for (uint64 _pIndex = 0; _pIndex<_ptbl.length; _pIndex++) {
            _setPunishment(_ptbl[_pIndex][0], _ptbl[_pIndex][1]);
        }
    }

    function _setPunishment(uint256 _lockPeriod, uint64 _value)
        internal
    {

        require(_value>=0 && _value<=2000, "invalid rate");
        uint256 ratesCount = punishmentTable[_lockPeriod].rates.length;
        uint256 oldRate = ratesCount>0 ? punishmentTable[_lockPeriod].rates[ratesCount-1].rate : 0;
        require(_value!=oldRate, "same as it is");
        punishmentTable[_lockPeriod].rates.push(Rate({
            timestamp: block.timestamp,
            rate: _value
        }));
        emit PunishmentRateChanged(block.timestamp,_value,oldRate);
    }

    function punishmentRate(uint256 _lockPeriod)
        public
        view
        returns(uint256)
    {

        require(punishmentTable[_lockPeriod].rates.length>0,"no rate");
        return _lastRate(punishmentTable[_lockPeriod]);
    }

    function punishmentRateHistory(uint256 _lockPeriod)
        public
        view
        returns(RateHistory memory)
    {

        require(punishmentTable[_lockPeriod].rates.length>0,"no rate");
        return punishmentTable[_lockPeriod];
    }

    function rewardOf(address _stakeholder,  uint256 _stakedID)
        public
        view
        returns(uint256)
    {

        require(stakeholders[_stakeholder].totalStaked>0,"not stake holder");
        return calculateRewardFor(_stakeholder,_stakedID);
    }

    function punishmentOf(address _stakeholder,  uint256 _stakedID)
        public
        view
        returns(uint256)
    {

        require(stakeholders[_stakeholder].totalStaked>0,"not stake holder");
        return calculatePunishmentFor(_stakeholder,_stakedID);
    }

    function calculateRewardFor(address _stakeholder, uint256 _stakedID)
        internal
        view
        returns(uint256)
    {

        require(stakeholders[_stakeholder].totalStaked>0,"not stake holder");
        uint256 stakeIndex;
        bool found = false;
        for (stakeIndex = 0; stakeIndex < stakeholders[_stakeholder].stakes.length; stakeIndex += 1){
            if (stakeholders[_stakeholder].stakes[stakeIndex].id == _stakedID) {
                found = true;
                break;
            }
        }
        require(found,"invalid stake id");
        Stake storage s = stakeholders[_stakeholder].stakes[stakeIndex];
        return _calculateReward(s.stakedAt, block.timestamp, s.value, s.lockPeriod);
    }

    function _calculateReward(uint256 _from, uint256 _to, uint256 _value, uint256 _lockPeriod)
        internal
        view
        returns(uint256)
    {

        require (_to>=_from,"invalid stake time");
        uint256 durationDays = _duration(_from,_to,_lockPeriod);
        if (durationDays<_lockPeriod) return 0;

        return _calculateTotal(rewardTable[_lockPeriod],_from,_to,_value,_lockPeriod);
    }

    function calculatePunishmentFor(address _stakeholder, uint256 _stakedID)
        internal
        view
        returns(uint256)
    {

        require(stakeholders[_stakeholder].totalStaked>0,"not stake holder");
        uint256 stakeIndex;
        bool found = false;
        for (stakeIndex = 0; stakeIndex < stakeholders[_stakeholder].stakes.length; stakeIndex += 1){
            if (stakeholders[_stakeholder].stakes[stakeIndex].id == _stakedID) {
                found = true;
                break;
            }
        }
        require(found,"invalid stake id");
        Stake storage s = stakeholders[_stakeholder].stakes[stakeIndex];
        return _calculatePunishment(s.stakedAt, block.timestamp, s.value, s.lockPeriod);
    }

    function _calculatePunishment(uint256 _from, uint256 _to, uint256 _value, uint256 _lockPeriod)
        internal
        view
        returns(uint256)
    {

        require (_to>=_from,"invalid stake time");
        uint256 durationDays = _to.sub(_from).div(1 days);
        if (durationDays>=_lockPeriod) return 0;
        uint256 pos = punishmentTable[_lockPeriod].rates.length;
        require (pos>0, "invalid lock period");
        
        return _value.mul(punishmentTable[_lockPeriod].rates[pos-1].rate).div(10000); 
    }

    function _calculateTotal(RateHistory storage _history, uint256 _from, uint256 _to, uint256 _value, uint256 _lockPeriod)
        internal
        view
        returns(uint256)
    {


        require(_history.rates.length>0,"invalid period");
        uint256 rIndex;
        for (rIndex = _history.rates.length-1; rIndex>0; rIndex-- ) {
            if (_history.rates[rIndex].timestamp<=_from) break;
        }
        require(_history.rates[rIndex].timestamp<=_from, "lack of history rates");
        if (rIndex==_history.rates.length-1) {
            return _value.mul(_history.rates[rIndex].rate).div(10000);  //10000 ~ 100.00
        }

        uint256 total = 0;
        uint256 totalDuration = 0;
        uint256 prevTimestamp = _from;
        uint256 diff = 0;
        uint256 maxTotalDuration = _duration(_from,_to, _lockPeriod);
        for (rIndex++; rIndex<=_history.rates.length && totalDuration<maxTotalDuration; rIndex++) {
            
            if (rIndex<_history.rates.length){
                diff = _duration(prevTimestamp, _history.rates[rIndex].timestamp, 0);
                prevTimestamp = _history.rates[rIndex].timestamp;
            }else {
                diff = _duration(prevTimestamp, _to, 0);
                prevTimestamp = _to;
            }

            totalDuration = totalDuration.add(diff);
            if (totalDuration>maxTotalDuration) {
                diff = diff.sub(totalDuration.sub(maxTotalDuration));
                totalDuration = maxTotalDuration;
            }
            total = total.add(_history.rates[rIndex-1].rate.mul(diff));
        }
        return _value.mul(total).div(_lockPeriod.mul(10000));
    }

    function _duration(uint256 t1, uint256 t2, uint256 maxDuration)
        internal
        pure
        returns(uint256)
    {

        uint256 diffDays = t2.sub(t1).div(1 days);
        if (maxDuration==0) return diffDays;
        return Math.min(diffDays,maxDuration);
    }

    function _lastRate(RateHistory storage _history)
        internal
        view
        returns(uint256)
    {

        return _history.rates[_history.rates.length-1].rate;
    }

    uint256[50] private __gap;
}