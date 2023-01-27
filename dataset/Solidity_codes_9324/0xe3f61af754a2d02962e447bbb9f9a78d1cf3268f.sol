
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

pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
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
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal onlyInitializing {

    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {

    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
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

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

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

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

}// MIT
pragma solidity 0.8.13;


contract CyanVaultTokenV1 is AccessControl, ERC20 {
    bytes32 public constant CYAN_VAULT_ROLE = keccak256("CYAN_VAULT_ROLE");
    event BurnedAdminToken(uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        address cyanSuperAdmin
    ) ERC20(_name, _symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, cyanSuperAdmin);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount)
        external
        onlyRole(CYAN_VAULT_ROLE)
    {
        require(to != address(0), "Mint to the zero address");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount)
        external
        onlyRole(CYAN_VAULT_ROLE)
    {
        require(balanceOf(from) >= amount, "Balance not enough");
        _burn(from, amount);
    }

    function burnAdminToken(uint256 amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(balanceOf(msg.sender) >= amount, "Balance not enough");
        _burn(msg.sender, amount);

        emit BurnedAdminToken(amount);
    }
}// MIT
pragma solidity 0.8.13;

interface IStableSwapSTETH {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external payable returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
}// MIT
pragma solidity 0.8.13;



contract CyanVaultV1 is
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    ERC721HolderUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant CYAN_ROLE = keccak256("CYAN_ROLE");
    bytes32 public constant CYAN_PAYMENT_PLAN_ROLE =
        keccak256("CYAN_PAYMENT_PLAN_ROLE");
    bytes32 public constant CYAN_BALANCER_ROLE =
        keccak256("CYAN_BALANCER_ROLE");

    event DepositETH(
        address indexed from,
        uint256 ethAmount,
        uint256 tokenAmount
    );
    event Lend(address indexed to, uint256 amount);
    event Earn(uint256 paymentAmount, uint256 profitAmount);
    event NftDefaulted(uint256 unpaidAmount, uint256 estimatedPriceOfNFT);
    event NftLiquidated(uint256 defaultedAssetsAmount, uint256 soldAmount);
    event WithdrawETH(
        address indexed from,
        uint256 ethAmount,
        uint256 tokenAmount
    );
    event GetDefaultedNFT(
        address indexed to,
        address indexed contractAddress,
        uint256 indexed tokenId
    );
    event UpdatedDefaultedNFTAssetAmount(uint256 amount);
    event UpdatedServiceFeePercent(uint256 from, uint256 to);
    event UpdatedSafetyFundPercent(uint256 from, uint256 to);
    event InitializedServiceFeePercent(uint256 to);
    event InitializedSafetyFundPercent(uint256 to);
    event ExchangedEthToStEth(uint256 ethAmount, uint256 receivedStEthAmount);
    event ExchangedStEthToEth(uint256 stEthAmount, uint256 receivedEthAmount);
    event ReceivedETH(uint256 amount, address indexed from);
    event WithdrewERC20(address indexed token, address to, uint256 amount);
    event CollectedServiceFee(uint256 collectedAmount, uint256 remainingAmount);

    address public _cyanVaultTokenAddress;
    CyanVaultTokenV1 private _cyanVaultTokenContract;

    IERC20 private _stEthTokenContract;
    IStableSwapSTETH private _stableSwapSTETHContract;

    uint256 public _safetyFundPercent;

    uint256 public _serviceFeePercent;

    uint256 private REMAINING_AMOUNT;

    uint256 private LOANED_AMOUNT;

    uint256 private DEFAULTED_NFT_ASSET_AMOUNT;

    uint256 private COLLECTED_SERVICE_FEE_AMOUNT;

    function initialize(
        address cyanVaultTokenAddress,
        address cyanPaymentPlanAddress,
        address stEthTokenAddress,
        address curveStableSwapStEthAddress,
        address cyanSuperAdmin,
        uint256 safetyFundPercent,
        uint256 serviceFeePercent
    ) external initializer {
        require(
            cyanVaultTokenAddress != address(0),
            "Cyan Vault Token address cannot be zero"
        );
        require(
            safetyFundPercent <= 10000,
            "Safety fund percent must be equal or less than 100 percent"
        );
        require(
            serviceFeePercent <= 200,
            "Service fee percent must not be greater than 2 percent"
        );

        __AccessControl_init();
        __ReentrancyGuard_init();
        __ERC721Holder_init();
        __Pausable_init();

        _cyanVaultTokenAddress = cyanVaultTokenAddress;
        _cyanVaultTokenContract = CyanVaultTokenV1(_cyanVaultTokenAddress);
        _safetyFundPercent = safetyFundPercent;
        _serviceFeePercent = serviceFeePercent;

        LOANED_AMOUNT = 0;
        DEFAULTED_NFT_ASSET_AMOUNT = 0;
        REMAINING_AMOUNT = 0;

        _stEthTokenContract = IERC20(stEthTokenAddress);
        _stableSwapSTETHContract = IStableSwapSTETH(
            curveStableSwapStEthAddress
        );

        _setupRole(DEFAULT_ADMIN_ROLE, cyanSuperAdmin);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CYAN_PAYMENT_PLAN_ROLE, cyanPaymentPlanAddress);

        emit InitializedServiceFeePercent(serviceFeePercent);
        emit InitializedSafetyFundPercent(safetyFundPercent);
    }

    function depositETH() external payable nonReentrant whenNotPaused {
        require(msg.value > 0, "Must deposit more than 0 ETH");

        uint256 cyanServiceFee = (msg.value * _serviceFeePercent) / 10000;

        uint256 depositedAmount = msg.value - cyanServiceFee;
        uint256 mintAmount = calculateTokenByETH(depositedAmount);

        REMAINING_AMOUNT += depositedAmount;
        COLLECTED_SERVICE_FEE_AMOUNT += cyanServiceFee;
        _cyanVaultTokenContract.mint(msg.sender, mintAmount);

        emit DepositETH(msg.sender, depositedAmount, mintAmount);
    }

    function lend(address to, uint256 amount)
        external
        nonReentrant
        whenNotPaused
        onlyRole(CYAN_PAYMENT_PLAN_ROLE)
    {
        require(to != address(0), "to address cannot be zero");

        uint256 maxWithdrableAmount = getMaxWithdrawableAmount();
        require(amount <= maxWithdrableAmount, "Not enough ETH in the Vault");

        LOANED_AMOUNT += amount;
        REMAINING_AMOUNT -= amount;
        payable(to).transfer(amount);

        emit Lend(to, amount);
    }

    function earn(uint256 amount, uint256 profit)
        external
        payable
        nonReentrant
        onlyRole(CYAN_PAYMENT_PLAN_ROLE)
    {
        require(msg.value == amount + profit, "Wrong tranfer amount");

        REMAINING_AMOUNT += msg.value;
        if (LOANED_AMOUNT >= amount) {
            LOANED_AMOUNT -= amount;
        } else {
            LOANED_AMOUNT = 0;
        }

        emit Earn(amount, profit);
    }

    function nftDefaulted(uint256 unpaidAmount, uint256 estimatedPriceOfNFT)
        external
        nonReentrant
        onlyRole(CYAN_PAYMENT_PLAN_ROLE)
    {
        DEFAULTED_NFT_ASSET_AMOUNT += estimatedPriceOfNFT;

        if (LOANED_AMOUNT >= unpaidAmount) {
            LOANED_AMOUNT -= unpaidAmount;
        } else {
            LOANED_AMOUNT = 0;
        }

        emit NftDefaulted(unpaidAmount, estimatedPriceOfNFT);
    }

    function liquidateNFT(uint256 totalDefaultedNFTAmount)
        external
        payable
        whenNotPaused
        onlyRole(CYAN_ROLE)
    {
        REMAINING_AMOUNT += msg.value;
        DEFAULTED_NFT_ASSET_AMOUNT = totalDefaultedNFTAmount;

        emit NftLiquidated(msg.value, totalDefaultedNFTAmount);
    }

    function withdraw(uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0, "Non-positive token amount");

        uint256 balance = _cyanVaultTokenContract.balanceOf(msg.sender);
        require(balance >= amount, "Check the token balance");

        uint256 withdrawableTokenBalance = getWithdrawableBalance(msg.sender);
        require(
            amount <= withdrawableTokenBalance,
            "Not enough active balance in Cyan Vault"
        );

        uint256 withdrawETHAmount = calculateETHByToken(amount);

        REMAINING_AMOUNT -= withdrawETHAmount;
        _cyanVaultTokenContract.burn(msg.sender, amount);
        payable(msg.sender).transfer(withdrawETHAmount);

        emit WithdrawETH(msg.sender, withdrawETHAmount, amount);
    }

    function updateDefaultedNFTAssetAmount(uint256 amount)
        external
        whenNotPaused
        onlyRole(CYAN_ROLE)
    {
        DEFAULTED_NFT_ASSET_AMOUNT = amount;
        emit UpdatedDefaultedNFTAssetAmount(amount);
    }

    function getDefaultedNFT(address contractAddress, uint256 tokenId)
        external
        nonReentrant
        whenNotPaused
        onlyRole(CYAN_ROLE)
    {
        require(contractAddress != address(0), "Zero contract address");

        IERC721 originalContract = IERC721(contractAddress);

        require(
            originalContract.ownerOf(tokenId) == address(this),
            "Vault is not the owner of the token"
        );

        originalContract.safeTransferFrom(address(this), msg.sender, tokenId);

        emit GetDefaultedNFT(msg.sender, contractAddress, tokenId);
    }

    function getWithdrawableBalance(address user)
        public
        view
        returns (uint256)
    {
        uint256 tokenBalance = _cyanVaultTokenContract.balanceOf(user);
        uint256 ethAmountForToken = calculateETHByToken(tokenBalance);
        uint256 maxWithdrawableAmount = getMaxWithdrawableAmount();

        if (ethAmountForToken <= maxWithdrawableAmount) {
            return tokenBalance;
        }
        return calculateTokenByETH(maxWithdrawableAmount);
    }

    function getMaxWithdrawableAmount() public view returns (uint256) {
        uint256 util = ((LOANED_AMOUNT + DEFAULTED_NFT_ASSET_AMOUNT) *
            _safetyFundPercent) / 10000;
        if (REMAINING_AMOUNT > util) {
            return REMAINING_AMOUNT - util;
        }
        return 0;
    }

    function getCurrentAssetAmounts()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            REMAINING_AMOUNT,
            LOANED_AMOUNT,
            DEFAULTED_NFT_ASSET_AMOUNT,
            COLLECTED_SERVICE_FEE_AMOUNT,
            _stEthTokenContract.balanceOf(address(this))
        );
    }

    function calculateTokenByETH(uint256 amount) public view returns (uint256) {
        (uint256 totalETH, uint256 totalToken) = getTotalEthAndToken();
        if (totalETH == 0 || totalToken == 0) return amount;
        return (amount * totalToken) / totalETH;
    }

    function calculateETHByToken(uint256 amount) public view returns (uint256) {
        (uint256 totalETH, uint256 totalToken) = getTotalEthAndToken();
        if (totalETH == 0 || totalToken == 0) return amount;
        return (amount * totalETH) / totalToken;
    }

    function getTotalEthAndToken() private view returns (uint256, uint256) {
        uint256 vaultStEthBalance = _stEthTokenContract.balanceOf(
            address(this)
        );
        uint256 stEthInEth = vaultStEthBalance == 0
            ? 0
            : _stableSwapSTETHContract.get_dy(1, 0, vaultStEthBalance);
        uint256 totalETH = REMAINING_AMOUNT +
            LOANED_AMOUNT +
            DEFAULTED_NFT_ASSET_AMOUNT +
            stEthInEth;
        uint256 totalToken = _cyanVaultTokenContract.totalSupply();

        return (totalETH, totalToken);
    }

    function exchangeEthToStEth(uint256 ethAmount, uint256 minStEthAmount)
        external
        nonReentrant
        onlyRole(CYAN_BALANCER_ROLE)
    {
        require(ethAmount > 0, "Exchanging ETH amount is zero");
        require(
            ethAmount <= REMAINING_AMOUNT,
            "Cannot exchange more than REMAINING_AMOUNT"
        );
        REMAINING_AMOUNT -= ethAmount;
        uint256 receivedStEthAmount = _stableSwapSTETHContract.exchange{
            value: ethAmount
        }(0, 1, ethAmount, minStEthAmount);
        emit ExchangedEthToStEth(ethAmount, receivedStEthAmount);
    }

    function exchangeStEthToEth(uint256 stEthAmount, uint256 minEthAmount)
        external
        nonReentrant
        onlyRole(CYAN_BALANCER_ROLE)
    {
        require(stEthAmount > 0, "Exchanging stETH amount is zero");
        bool isApproved = _stEthTokenContract.approve(
            address(_stableSwapSTETHContract),
            stEthAmount
        );
        require(
            isApproved,
            "stETH approval to stableSwapSTETH contract failed"
        );
        uint256 receivedEthAmount = _stableSwapSTETHContract.exchange(
            1,
            0,
            stEthAmount,
            minEthAmount
        );
        emit ExchangedStEthToEth(stEthAmount, receivedEthAmount);
    }

    function updateSafetyFundPercent(uint256 safetyFundPercent)
        external
        nonReentrant
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            safetyFundPercent <= 10000,
            "Safety fund percent must be equal or less than 100 percent"
        );
        emit UpdatedSafetyFundPercent(_safetyFundPercent, safetyFundPercent);
        _safetyFundPercent = safetyFundPercent;
    }

    function updateServiceFeePercent(uint256 serviceFeePercent)
        external
        nonReentrant
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            serviceFeePercent <= 200,
            "Service fee percent must not be greater than 2 percent"
        );
        emit UpdatedServiceFeePercent(_serviceFeePercent, serviceFeePercent);
        _serviceFeePercent = serviceFeePercent;
    }

    function collectServiceFee(uint256 amount)
        external
        nonReentrant
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            amount <= COLLECTED_SERVICE_FEE_AMOUNT,
            "Not enough collected service fee"
        );
        COLLECTED_SERVICE_FEE_AMOUNT -= amount;
        payable(msg.sender).transfer(amount);

        emit CollectedServiceFee(amount, COLLECTED_SERVICE_FEE_AMOUNT);
    }

    function withdrawAirDroppedERC20(address contractAddress, uint256 amount)
        external
        nonReentrant
        onlyRole(CYAN_ROLE)
    {
        require(
            contractAddress != address(_stEthTokenContract),
            "Cannot withdraw stETH"
        );
        IERC20Upgradeable erc20Contract = IERC20Upgradeable(contractAddress);
        require(
            erc20Contract.balanceOf(address(this)) >= amount,
            "ERC20 balance not enough"
        );
        erc20Contract.safeTransfer(msg.sender, amount);

        emit WithdrewERC20(contractAddress, msg.sender, amount);
    }

    function withdrawApprovedERC20(
        address contractAddress,
        address from,
        uint256 amount
    ) external nonReentrant onlyRole(CYAN_ROLE) {
        require(
            contractAddress != address(_stEthTokenContract),
            "Cannot withdraw stETH"
        );
        IERC20Upgradeable erc20Contract = IERC20Upgradeable(contractAddress);
        require(
            erc20Contract.allowance(from, address(this)) >= amount,
            "ERC20 allowance not enough"
        );
        erc20Contract.safeTransferFrom(from, msg.sender, amount);

        emit WithdrewERC20(contractAddress, msg.sender, amount);
    }

    receive() external payable {
        REMAINING_AMOUNT += msg.value;
        emit ReceivedETH(msg.value, msg.sender);
    }

    fallback() external payable {
        REMAINING_AMOUNT += msg.value;
        emit ReceivedETH(msg.value, msg.sender);
    }

    function pause() external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}