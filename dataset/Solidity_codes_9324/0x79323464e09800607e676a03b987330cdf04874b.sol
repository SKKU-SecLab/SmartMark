
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// BUSL-1.1

pragma solidity 0.8.4;

interface IVaultFactory {
    event VaultCreated(address vault);

    event VaultFactorySetTreasuryAddress(address treasuryAddress);

    event VaultFactorySetFeeToPublishVault(uint256 fee);
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
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
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Pausable is ERC20, Pausable {
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
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
}// MIT

pragma solidity ^0.8.0;

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
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
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
}// MIT

pragma solidity ^0.8.0;


interface IAccessControlEnumerable {
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20PresetMinterPauser is Context, AccessControlEnumerable, ERC20Burnable, ERC20Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function mint(address to, uint256 amount) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have minter role to mint");
        _mint(to, amount);
    }

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to pause");
        _pause();
    }

    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }
}// BUSL-1.1

pragma solidity 0.8.4;


contract ERC20EToken is ERC20PresetMinterPauser {
    constructor(string memory name, string memory symbol) ERC20PresetMinterPauser(name, symbol) {}
}// BUSL-1.1

pragma solidity 0.8.4;

abstract contract CoreConstants {
    uint256 internal constant RATIO_MULTIPLY_FACTOR = 10**6;
}// BUSL-1.1

pragma solidity 0.8.4;

interface IFlashLoanFeeProvider {
    event SetFee(uint256 feePercentage, uint256 feeAmountDivider);

    event SetTreasuryFeePercentage(uint256 treasuryFeePercentage);

    function setFee(uint256 _flashFeePercentage, uint256 _flashFeeAmountDivider) external;
}// BUSL-1.1

pragma solidity 0.8.4;


abstract contract Moderable is Context {
    address private _moderator;

    event ModeratorTransferred(address indexed previousModerator, address indexed newModerator);

    constructor() {
        address msgSender = _msgSender();
        _moderator = msgSender;
        emit ModeratorTransferred(address(0), msgSender);
    }

    function moderator() public view virtual returns (address) {
        return _moderator;
    }

    modifier onlyModerator() {
        require(moderator() == _msgSender(), 'Moderator: caller is not the moderator');
        _;
    }

    function renounceModeratorship() public virtual onlyModerator {
        emit ModeratorTransferred(_moderator, address(0));
        _moderator = address(0);
    }

    function transferModeratorship(address newModerator) public virtual onlyModerator {
        require(newModerator != address(0), 'Moderable: new moderator is the zero address');
        emit ModeratorTransferred(_moderator, newModerator);
        _moderator = newModerator;
    }
}// BUSL-1.1

pragma solidity 0.8.4;


contract FlashLoanFeeProvider is IFlashLoanFeeProvider, Moderable {
    uint256 public treasuryFeePercentage = 10;
    uint256 public flashFeePercentage = 5;
    uint256 public flashFeeAmountDivider = 10000;

    function setFee(uint256 _flashFeePercentage, uint256 _flashFeeAmountDivider)
        external
        override
        onlyModerator
    {
        require(_flashFeeAmountDivider > 0, 'AMOUNT_DIVIDER_CANNOT_BE_ZERO');
        require(_flashFeePercentage <= 100, 'FEE_PERCENTAGE_WRONG_VALUE');
        flashFeePercentage = _flashFeePercentage;
        flashFeeAmountDivider = _flashFeeAmountDivider;

        emit SetFee(_flashFeePercentage, _flashFeeAmountDivider);
    }

    function getTreasuryAmountToSend(uint256 amount) internal view returns (uint256) {
        return (amount * treasuryFeePercentage) / 100;
    }

    function setTreasuryFeePercentage(uint256 _treasuryFeePercentage) external onlyModerator {
        require(_treasuryFeePercentage <= 100, 'TREASURY_FEE_PERCENTAGE_WRONG_VALUE');
        treasuryFeePercentage = _treasuryFeePercentage;
        emit SetTreasuryFeePercentage(treasuryFeePercentage);
    }

    function calculateFeeForAmount(uint256 amount) external view returns (uint256) {
        return (amount * flashFeePercentage) / flashFeeAmountDivider;
    }
}// BUSL-1.1

pragma solidity 0.8.4;

interface IVault {
    event Deposit(
        address indexed sender,
        uint256 amount,
        uint256 tokensToMint,
        uint256 previousDepositBlockNr
    );

    event Withdraw(address indexed sender, uint256 amount, uint256 stakedTokensToTransfer);

    function initialize(
        address treasuryAddress,
        address flashLoanProvider,
        uint256 maxCapacity
    ) external;
}// BUSL-1.1

pragma solidity 0.8.4;



contract Vault is
    Moderable,
    IVault,
    CoreConstants,
    ERC20EToken,
    FlashLoanFeeProvider,
    ReentrancyGuard
{
    ERC20 public stakedToken;
    address public treasuryAddress;
    address public flashLoanProviderAddress;

    uint256 public totalAmountDeposited = 0;
    uint256 public minAmountForFlash = 0;
    uint256 public maxCapacity = 0;

    bool public isPaused = true;
    bool public isInitialized = false;

    address public factory;

    mapping(address => uint256) public lastDepositBlockNr;

    modifier onlyNotPaused {
        require(isPaused == false, 'ONLY_NOT_PAUSED');
        _;
    }

    modifier onlyNotInitialized {
        require(isInitialized == false, 'ONLY_NOT_INITIALIZED');
        _;
    }

    modifier onlyFlashLoanProvider {
        require(flashLoanProviderAddress == msg.sender, 'ONLY_FLASH_LOAN_PROVIDER');
        _;
    }

    constructor(ERC20 _stakedToken)
        ERC20EToken(
            string(abi.encodePacked(_stakedToken.symbol(), ' eVault LP')),
            string(abi.encodePacked('e', _stakedToken.symbol()))
        )
    {
        factory = msg.sender;
        stakedToken = _stakedToken;
    }

    function initialize(
        address _treasuryAddress,
        address _flashLoanProviderAddress,
        uint256 _maxCapacity
    ) external override onlyModerator onlyNotInitialized {
        treasuryAddress = _treasuryAddress;
        flashLoanProviderAddress = _flashLoanProviderAddress;
        maxCapacity = _maxCapacity;
        isPaused = false;
        isInitialized = true;
    }

    function decimals() public view virtual override returns (uint8) {
        return stakedToken.decimals();
    }

    function setMaxCapacity(uint256 _maxCapacity) external onlyModerator {
        maxCapacity = _maxCapacity;
    }

    function setMinAmountForFlash(uint256 _minAmountForFlash) external onlyModerator {
        minAmountForFlash = _minAmountForFlash;
    }

    function getNrOfETokensToMint(uint256 amount) internal view returns (uint256) {
        return (amount * getRatioForOneToken()) / RATIO_MULTIPLY_FACTOR;
    }

    function provideLiquidity(uint256 amount) external onlyNotPaused nonReentrant {
        require(amount > 0, 'CANNOT_STAKE_ZERO_TOKENS');
        require(amount + totalAmountDeposited <= maxCapacity, 'AMOUNT_IS_BIGGER_THAN_CAPACITY');

        uint256 receivedETokens = getNrOfETokensToMint(amount);

        totalAmountDeposited = amount + totalAmountDeposited;

        _mint(msg.sender, receivedETokens);
        require(
            stakedToken.transferFrom(msg.sender, address(this), amount),
            'TRANSFER_STAKED_FAIL'
        );

        emit Deposit(msg.sender, amount, receivedETokens, lastDepositBlockNr[msg.sender]);

        lastDepositBlockNr[msg.sender] = block.number;
    }

    function removeLiquidity(uint256 amount) external nonReentrant {
        require(amount <= balanceOf(msg.sender), 'AMOUNT_BIGGER_THAN_BALANCE');

        uint256 stakedTokensToTransfer = getStakedTokensFromAmount(amount);
        totalAmountDeposited =
            totalAmountDeposited -
            (amount * totalAmountDeposited) /
            totalSupply();

        _burn(msg.sender, amount);
        require(stakedToken.transfer(msg.sender, stakedTokensToTransfer), 'TRANSFER_STAKED_FAIL');

        emit Withdraw(msg.sender, amount, stakedTokensToTransfer);
    }

    function getRatioForOneEToken() public view returns (uint256) {
        if (totalSupply() > 0 && stakedToken.balanceOf(address(this)) > 0) {
            return (stakedToken.balanceOf(address(this)) * RATIO_MULTIPLY_FACTOR) / totalSupply();
        }
        return 1 * RATIO_MULTIPLY_FACTOR;
    }

    function getRatioForOneToken() public view returns (uint256) {
        if (totalSupply() > 0 && stakedToken.balanceOf(address(this)) > 0) {
            return (totalSupply() * RATIO_MULTIPLY_FACTOR) / stakedToken.balanceOf(address(this));
        }
        return 1 * RATIO_MULTIPLY_FACTOR;
    }

    function pauseVault() external onlyModerator {
        require(isPaused == false, 'VAULT_ALREADY_PAUSED');
        isPaused = true;
    }

    function unpauseVault() external onlyModerator {
        require(isPaused == true, 'VAULT_ALREADY_RESUMED');
        isPaused = false;
    }

    function transferFromAccount(address sender, uint256 amount)
        external
        onlyFlashLoanProvider
        onlyNotPaused
        returns (bool)
    {
        return stakedToken.transferFrom(sender, address(this), amount);
    }

    function transferToAccount(address recipient, uint256 amount)
        external
        onlyFlashLoanProvider
        onlyNotPaused
        returns (bool)
    {
        return stakedToken.transfer(recipient, amount);
    }

    function getStakedTokensFromAmount(uint256 amount) internal view returns (uint256) {
        return (amount * getRatioForOneEToken()) / RATIO_MULTIPLY_FACTOR;
    }

    function splitFees(uint256 fee)
        external
        onlyFlashLoanProvider
        returns (uint256 treasuryAmount)
    {
        treasuryAmount = getTreasuryAmountToSend(fee);
        require(stakedToken.transfer(treasuryAddress, treasuryAmount), 'TRANSFER_SPLIT_FAIL');
    }
}// BUSL-1.1

pragma solidity 0.8.4;


contract VaultFactory is IVaultFactory, Moderable, ReentrancyGuard {
    address[] public vaults;
    mapping(address => bool) public vaultExists;
    mapping(address => address) public tokenToVault;
    address public flashLoanProviderAddress;
    bool public isInitialized = false;
    ERC20 public tokenToPayInFee;
    uint256 public feeToPublishVault;
    address public treasuryAddress = 0xA49174859aA91E139b586F08BbB69BceE847d8a7;

    modifier onlyNotInitialized {
        require(isInitialized == false, 'ONLY_NOT_INITIALIZED');
        _;
    }

    modifier onlyInitialized {
        require(isInitialized, 'ONLY_INITIALIZED');
        _;
    }

    function setTreasuryAddress(address _treasuryAddress) external onlyModerator {
        treasuryAddress = _treasuryAddress;
        emit VaultFactorySetTreasuryAddress(treasuryAddress);
    }

    function initialize(address _flashLoanProviderAddress, address _tokenToPayInFee)
        external
        onlyModerator
        onlyNotInitialized
    {
        tokenToPayInFee = ERC20(_tokenToPayInFee);
        feeToPublishVault = 100000 * 10**tokenToPayInFee.decimals();
        flashLoanProviderAddress = _flashLoanProviderAddress;
        isInitialized = true;
    }

    function setFeeToPublishVault(uint256 _feeToPublishVault) external onlyModerator {
        feeToPublishVault = _feeToPublishVault;
        emit VaultFactorySetFeeToPublishVault(feeToPublishVault);
    }

    function createVault(address stakedToken, uint256 maxCapacity)
        external
        onlyModerator
        onlyInitialized
    {
        _createVault(stakedToken, maxCapacity);
    }

    function createVault(address stakedToken) external onlyInitialized nonReentrant {
        IERC20 token = IERC20(stakedToken);
        require(
            tokenToPayInFee.transferFrom(msg.sender, address(this), feeToPublishVault),
            'FEE_TRANSFER_FAILED'
        );
        require(token.totalSupply() > 0, 'TOTAL_SUPPLY_LESS_THAN_ZERO');
        _createVault(stakedToken, token.totalSupply() / 2);
    }

    function _createVault(address stakedToken, uint256 maxCapacity) internal {
        require(tokenToVault[stakedToken] == address(0), 'VAULT_ALREADY_EXISTS');
        bytes32 salt = keccak256(abi.encodePacked(stakedToken));

        Vault vault = new Vault{salt: salt}(ERC20(stakedToken));

        vaults.push(address(vault));
        vaultExists[address(vault)] = true;
        tokenToVault[stakedToken] = address(vault);

        vault.initialize(treasuryAddress, flashLoanProviderAddress, maxCapacity);

        vault.transferModeratorship(moderator()); //Moderator of VaultFactory is moderator of Vault. Otherwise moderator would be the VaultFactory

        emit VaultCreated(address(vault));
    }

    function withdraw() external onlyModerator {
        require(
            tokenToPayInFee.transfer(msg.sender, tokenToPayInFee.balanceOf(address(this))),
            'WITHDRAW_TRANSFER_ERROR'
        );
    }

    function countVaults() external view returns (uint256) {
        return vaults.length;
    }

    function precomputeAddress(address stakedToken) external view returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(stakedToken));
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                address(this),
                                salt,
                                keccak256(
                                    abi.encodePacked(
                                        type(Vault).creationCode,
                                        abi.encode(ERC20(stakedToken))
                                    )
                                )
                            )
                        )
                    )
                )
            );
    }
}