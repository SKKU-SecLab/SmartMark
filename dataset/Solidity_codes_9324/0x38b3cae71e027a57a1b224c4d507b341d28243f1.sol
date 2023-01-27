
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


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

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

interface AggregatorV3Interface {


  function decimals()
    external
    view
    returns (
      uint8
    );


  function description()
    external
    view
    returns (
      string memory
    );


  function version()
    external
    view
    returns (
      uint256
    );


  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}// MIT

pragma solidity ^0.8.0;

abstract contract ERC1404 {
    function detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) public view virtual returns (uint8);

    function messageForTransferRestriction(uint8 restrictionCode)
        public
        view
        virtual
        returns (string memory);
}// MIT

pragma solidity ^0.8.0;

contract OwnerRole {

    event OwnerAdded(address indexed addedOwner, address indexed addedBy);
    event OwnerRemoved(address indexed removedOwner, address indexed removedBy);

    struct Role {
        mapping(address => bool) members;
    }

    Role private _owners;

    modifier onlyOwner() {

        require(
            isOwner(msg.sender),
            "OwnerRole: caller does not have the Owner role"
        );
        _;
    }

    function isOwner(address account) public view returns (bool) {

        return _has(_owners, account);
    }

    function addOwner(address account) external onlyOwner {

        _addOwner(account);
    }

    function removeOwner(address account) external onlyOwner {

        _removeOwner(account);
    }

    function _addOwner(address account) internal {

        _add(_owners, account);
        emit OwnerAdded(account, msg.sender);
    }

    function _removeOwner(address account) internal {

        _remove(_owners, account);
        emit OwnerRemoved(account, msg.sender);
    }

    function _add(Role storage role, address account) internal {

        require(account != address(0x0), "Invalid 0x0 address");
        require(!_has(role, account), "Roles: account already has role");
        role.members[account] = true;
    }

    function _remove(Role storage role, address account) internal {

        require(_has(role, account), "Roles: account does not have role");
        role.members[account] = false;
    }

    function _has(Role storage role, address account)
        internal
        view
        returns (bool)
    {

        require(account != address(0), "Roles: account is the zero address");
        return role.members[account];
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

contract Proxiable {

    uint256 constant PROXIABLE_MEM_SLOT =
        0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;

    event CodeAddressUpdated(address newAddress);

    function _updateCodeAddress(address newAddress) internal {

        require(
            bytes32(PROXIABLE_MEM_SLOT) ==
                Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly {
            sstore(PROXIABLE_MEM_SLOT, newAddress)
        }

        emit CodeAddressUpdated(newAddress);
    }

    function getLogicAddress() external view returns (address logicAddress) {

        assembly {
            logicAddress := sload(PROXIABLE_MEM_SLOT)
        }
    }

    function proxiableUUID() external pure returns (bytes32) {

        return bytes32(PROXIABLE_MEM_SLOT);
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract BurnerRole is OwnerRole {

    event BurnerAdded(address indexed addedBurner, address indexed addedBy);
    event BurnerRemoved(
        address indexed removedBurner,
        address indexed removedBy
    );

    Role private _burners;

    modifier onlyBurner() {

        require(
            isBurner(msg.sender),
            "BurnerRole: caller does not have the Burner role"
        );
        _;
    }

    function isBurner(address account) public view returns (bool) {

        return _has(_burners, account);
    }

    function _addBurner(address account) internal {

        _add(_burners, account);
        emit BurnerAdded(account, msg.sender);
    }

    function _removeBurner(address account) internal {

        _remove(_burners, account);
        emit BurnerRemoved(account, msg.sender);
    }

    function addBurner(address account) external onlyOwner {

        _addBurner(account);
    }

    function removeBurner(address account) external onlyOwner {

        _removeBurner(account);
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;



contract Burnable is ERC20Upgradeable, BurnerRole {

    event Burn(address indexed burner, address indexed from, uint256 amount);

    function _burn(
        address burner,
        address from,
        uint256 amount
    ) internal returns (bool) {

        ERC20Upgradeable._burn(from, amount);
        emit Burn(burner, from, amount);
        return true;
    }

    function burn(address account, uint256 amount)
        external
        onlyBurner
        returns (bool)
    {

        return _burn(msg.sender, account, amount);
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
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

interface IERC3156FlashBorrowerUpgradeable {

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);

}// MIT

pragma solidity ^0.8.0;


interface IERC3156FlashLenderUpgradeable {

    function maxFlashLoan(address token) external view returns (uint256);


    function flashFee(address token, uint256 amount) external view returns (uint256);


    function flashLoan(
        IERC3156FlashBorrowerUpgradeable receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.0;


pragma solidity ^0.8.0;


abstract contract ERC20FlashMintUpgradeable is Initializable, ERC20Upgradeable, IERC3156FlashLenderUpgradeable {
    function __ERC20FlashMint_init() internal initializer {
        __Context_init_unchained();
        __ERC20FlashMint_init_unchained();
    }

    function __ERC20FlashMint_init_unchained() internal initializer {
    }
    bytes32 private constant _RETURN_VALUE = keccak256("ERC3156FlashBorrower.onFlashLoan");

    function maxFlashLoan(address token) public view override returns (uint256) {
        return token == address(this) ? type(uint256).max - ERC20Upgradeable.totalSupply() : 0;
    }

    function flashFee(address token, uint256 amount) public view virtual override returns (uint256) {
        require(token == address(this), "ERC20FlashMint: wrong token");
        amount;
        return 0;
    }

    function flashLoan(
        IERC3156FlashBorrowerUpgradeable receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) public virtual override returns (bool) {
        uint256 fee = flashFee(token, amount);
        _mint(address(receiver), amount);
        require(
            receiver.onFlashLoan(msg.sender, token, amount, fee, data) == _RETURN_VALUE,
            "ERC20FlashMint: invalid return value"
        );
        uint256 currentAllowance = allowance(address(receiver), address(this));
        require(currentAllowance >= amount + fee, "ERC20FlashMint: allowance does not allow refund");
        _approve(address(receiver), address(this), currentAllowance - amount - fee);
        _burn(address(receiver), amount + fee);
        return true;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract MinterRole is OwnerRole {

    event MinterAdded(address indexed addedMinter, address indexed addedBy);
    event MinterRemoved(
        address indexed removedMinter,
        address indexed removedBy
    );

    Role private _minters;

    modifier onlyMinter() {

        require(
            isMinter(msg.sender),
            "MinterRole: caller does not have the Minter role"
        );
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _has(_minters, account);
    }

    function _addMinter(address account) internal {

        _add(_minters, account);
        emit MinterAdded(account, msg.sender);
    }

    function _removeMinter(address account) internal {

        _remove(_minters, account);
        emit MinterRemoved(account, msg.sender);
    }

    function addMinter(address account) external onlyOwner {

        _addMinter(account);
    }

    function removeMinter(address account) external onlyOwner {

        _removeMinter(account);
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;



contract Mintable is
    ERC20FlashMintUpgradeable,
    MinterRole,
    ReentrancyGuardUpgradeable
{

    event Mint(address indexed minter, address indexed to, uint256 amount);

    uint256 public flashMintFee = 0;
    address public flashMintFeeReceiver;

    bool public isFlashMintEnabled = false;

    bytes32 public constant _RETURN_VALUE =
        keccak256("ERC3156FlashBorrower.onFlashLoan");

    function _mint(
        address minter,
        address to,
        uint256 amount
    ) internal returns (bool) {

        ERC20Upgradeable._mint(to, amount);
        emit Mint(minter, to, amount);
        return true;
    }

    function _setFlashMintEnabled(bool enabled) internal {

        isFlashMintEnabled = enabled;
    }

    function _setFlashMintFeeReceiver(address receiver) internal {

        flashMintFeeReceiver = receiver;
    }

    function mint(address account, uint256 amount)
        public
        virtual
        onlyMinter
        returns (bool)
    {

        return Mintable._mint(msg.sender, account, amount);
    }

    function setFlashMintFee(uint256 fee) external onlyMinter {

        flashMintFee = fee;
    }

    function setFlashMintEnabled(bool enabled) external onlyMinter {

        _setFlashMintEnabled(enabled);
    }

    function setFlashMintFeeReceiver(address receiver) external onlyMinter {

        _setFlashMintFeeReceiver(receiver);
    }

    function flashFee(address token, uint256)
        public
        view
        override
        returns (uint256)
    {

        require(token == address(this), "ERC20FlashMint: wrong token");

        return flashMintFee;
    }

    function flashLoan(
        IERC3156FlashBorrowerUpgradeable receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) public override nonReentrant returns (bool) {

        require(isFlashMintEnabled, "flash mint is disabled");

        uint256 fee = flashFee(token, amount);
        _mint(address(receiver), amount);

        require(
            receiver.onFlashLoan(msg.sender, token, amount, fee, data) ==
                _RETURN_VALUE,
            "ERC20FlashMint: invalid return value"
        );
        uint256 currentAllowance = allowance(address(receiver), address(this));
        require(
            currentAllowance >= amount + fee,
            "ERC20FlashMint: allowance does not allow refund"
        );

        _transfer(address(receiver), flashMintFeeReceiver, fee);
        _approve(
            address(receiver),
            address(this),
            currentAllowance - amount - fee
        );
        _burn(address(receiver), amount);

        return true;
    }

    uint256[47] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract PauserRole is OwnerRole {

    event PauserAdded(address indexed addedPauser, address indexed addedBy);
    event PauserRemoved(
        address indexed removedPauser,
        address indexed removedBy
    );

    Role private _pausers;

    modifier onlyPauser() {

        require(
            isPauser(msg.sender),
            "PauserRole: caller does not have the Pauser role"
        );
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _has(_pausers, account);
    }

    function _addPauser(address account) internal {

        _add(_pausers, account);
        emit PauserAdded(account, msg.sender);
    }

    function _removePauser(address account) internal {

        _remove(_pausers, account);
        emit PauserRemoved(account, msg.sender);
    }

    function addPauser(address account) external onlyOwner {

        _addPauser(account);
    }

    function removePauser(address account) external onlyOwner {

        _removePauser(account);
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract Pausable is PauserRole {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal {

        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal {

        _paused = false;
        emit Unpaused(msg.sender);
    }

    function pause() external onlyPauser whenNotPaused {

        Pausable._pause();
    }

    function unpause() external onlyPauser whenPaused {

        Pausable._unpause();
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract RevokerRole is OwnerRole {

    event RevokerAdded(address indexed addedRevoker, address indexed addedBy);
    event RevokerRemoved(
        address indexed removedRevoker,
        address indexed removedBy
    );

    Role private _revokers;

    modifier onlyRevoker() {

        require(
            isRevoker(msg.sender),
            "RevokerRole: caller does not have the Revoker role"
        );
        _;
    }

    function isRevoker(address account) public view returns (bool) {

        return _has(_revokers, account);
    }

    function _addRevoker(address account) internal {

        _add(_revokers, account);
        emit RevokerAdded(account, msg.sender);
    }

    function _removeRevoker(address account) internal {

        _remove(_revokers, account);
        emit RevokerRemoved(account, msg.sender);
    }

    function addRevoker(address account) external onlyOwner {

        _addRevoker(account);
    }

    function removeRevoker(address account) external onlyOwner {

        _removeRevoker(account);
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;



contract Revocable is ERC20Upgradeable, RevokerRole {

    event Revoke(address indexed revoker, address indexed from, uint256 amount);

    function _revoke(address from, uint256 amount) internal returns (bool) {

        ERC20Upgradeable._transfer(from, msg.sender, amount);
        emit Revoke(msg.sender, from, amount);
        return true;
    }

    function revoke(address from, uint256 amount)
        external
        onlyRevoker
        returns (bool)
    {

        return _revoke(from, amount);
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract BlacklisterRole is OwnerRole {

    event BlacklisterAdded(
        address indexed addedBlacklister,
        address indexed addedBy
    );
    event BlacklisterRemoved(
        address indexed removedBlacklister,
        address indexed removedBy
    );

    Role private _Blacklisters;

    modifier onlyBlacklister() {

        require(isBlacklister(msg.sender), "BlacklisterRole missing");
        _;
    }

    function isBlacklister(address account) public view returns (bool) {

        return _has(_Blacklisters, account);
    }

    function _addBlacklister(address account) internal {

        _add(_Blacklisters, account);
        emit BlacklisterAdded(account, msg.sender);
    }

    function _removeBlacklister(address account) internal {

        _remove(_Blacklisters, account);
        emit BlacklisterRemoved(account, msg.sender);
    }

    function addBlacklister(address account) external onlyOwner {

        _addBlacklister(account);
    }

    function removeBlacklister(address account) external onlyOwner {

        _removeBlacklister(account);
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract Blacklistable is BlacklisterRole {

    mapping(address => bool) public addressBlacklists;

    bool public isBlacklistEnabled;

    event AddressAddedToBlacklist(
        address indexed addedAddress,
        address indexed addedBy
    );
    event AddressRemovedFromBlacklist(
        address indexed removedAddress,
        address indexed removedBy
    );
    event BlacklistEnabledUpdated(
        address indexed updatedBy,
        bool indexed enabled
    );

    function _setBlacklistEnabled(bool enabled) internal {

        isBlacklistEnabled = enabled;
        emit BlacklistEnabledUpdated(msg.sender, enabled);
    }

    function _addToBlacklist(address addressToAdd) internal {

        require(addressToAdd != address(0), "Cannot add 0x0");

        require(!addressBlacklists[addressToAdd], "Already on list");

        addressBlacklists[addressToAdd] = true;

        emit AddressAddedToBlacklist(addressToAdd, msg.sender);
    }

    function _removeFromBlacklist(address addressToRemove) internal {

        require(addressToRemove != address(0), "Cannot remove 0x0");

        require(addressBlacklists[addressToRemove], "Not on list");

        addressBlacklists[addressToRemove] = false;

        emit AddressRemovedFromBlacklist(addressToRemove, msg.sender);
    }

    function checkBlacklistAllowed(address sender, address receiver)
        public
        view
        returns (bool)
    {

        if (!isBlacklistEnabled) {
            return true;
        }

        return !addressBlacklists[sender] && !addressBlacklists[receiver];
    }

    function setBlacklistEnabled(bool enabled) external onlyOwner {

        _setBlacklistEnabled(enabled);
    }

    function addToBlacklist(address addressToAdd) external onlyBlacklister {

        _addToBlacklist(addressToAdd);
    }

    function removeFromBlacklist(address addressToRemove)
        external
        onlyBlacklister
    {

        _removeFromBlacklist(addressToRemove);
    }

    uint256[48] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract WhitelisterRole is OwnerRole {

    event WhitelisterAdded(
        address indexed addedWhitelister,
        address indexed addedBy
    );
    event WhitelisterRemoved(
        address indexed removedWhitelister,
        address indexed removedBy
    );

    Role private _whitelisters;

    modifier onlyWhitelister() {

        require(
            isWhitelister(msg.sender),
            "WhitelisterRole: caller does not have the Whitelister role"
        );
        _;
    }

    function isWhitelister(address account) public view returns (bool) {

        return _has(_whitelisters, account);
    }

    function _addWhitelister(address account) internal {

        _add(_whitelisters, account);
        emit WhitelisterAdded(account, msg.sender);
    }

    function _removeWhitelister(address account) internal {

        _remove(_whitelisters, account);
        emit WhitelisterRemoved(account, msg.sender);
    }

    function addWhitelister(address account) external onlyOwner {

        _addWhitelister(account);
    }

    function removeWhitelister(address account) external onlyOwner {

        _removeWhitelister(account);
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract Whitelistable is WhitelisterRole {

    mapping(address => uint8) public addressWhitelists;

    mapping(uint8 => mapping(uint8 => bool)) public outboundWhitelistsEnabled;

    bool public isWhitelistEnabled;

    uint8 constant NO_WHITELIST = 0;

    event AddressAddedToWhitelist(
        address indexed addedAddress,
        uint8 indexed whitelist,
        address indexed addedBy
    );
    event AddressRemovedFromWhitelist(
        address indexed removedAddress,
        uint8 indexed whitelist,
        address indexed removedBy
    );
    event OutboundWhitelistUpdated(
        address indexed updatedBy,
        uint8 indexed sourceWhitelist,
        uint8 indexed destinationWhitelist,
        bool from,
        bool to
    );
    event WhitelistEnabledUpdated(
        address indexed updatedBy,
        bool indexed enabled
    );

    function _setWhitelistEnabled(bool enabled) internal {

        isWhitelistEnabled = enabled;
        emit WhitelistEnabledUpdated(msg.sender, enabled);
    }

    function _addToWhitelist(address addressToAdd, uint8 whitelist) internal {

        require(
            addressToAdd != address(0),
            "Cannot add address 0x0 to a whitelist."
        );

        require(whitelist != NO_WHITELIST, "Invalid whitelist ID supplied");

        uint8 previousWhitelist = addressWhitelists[addressToAdd];

        addressWhitelists[addressToAdd] = whitelist;

        if (previousWhitelist != NO_WHITELIST) {
            emit AddressRemovedFromWhitelist(
                addressToAdd,
                previousWhitelist,
                msg.sender
            );
        }

        emit AddressAddedToWhitelist(addressToAdd, whitelist, msg.sender);
    }

    function _removeFromWhitelist(address addressToRemove) internal {

        require(
            addressToRemove != address(0),
            "Cannot remove address 0x0 from a whitelist."
        );

        uint8 previousWhitelist = addressWhitelists[addressToRemove];

        require(
            previousWhitelist != NO_WHITELIST,
            "Address cannot be removed from invalid whitelist."
        );

        addressWhitelists[addressToRemove] = NO_WHITELIST;

        emit AddressRemovedFromWhitelist(
            addressToRemove,
            previousWhitelist,
            msg.sender
        );
    }

    function _updateOutboundWhitelistEnabled(
        uint8 sourceWhitelist,
        uint8 destinationWhitelist,
        bool newEnabledValue
    ) internal {

        bool oldEnabledValue = outboundWhitelistsEnabled[sourceWhitelist][
            destinationWhitelist
        ];

        outboundWhitelistsEnabled[sourceWhitelist][
            destinationWhitelist
        ] = newEnabledValue;

        emit OutboundWhitelistUpdated(
            msg.sender,
            sourceWhitelist,
            destinationWhitelist,
            oldEnabledValue,
            newEnabledValue
        );
    }

    function checkWhitelistAllowed(address sender, address receiver)
        public
        view
        returns (bool)
    {

        if (!isWhitelistEnabled) {
            return true;
        }

        uint8 senderWhiteList = addressWhitelists[sender];
        uint8 receiverWhiteList = addressWhitelists[receiver];

        if (
            senderWhiteList == NO_WHITELIST || receiverWhiteList == NO_WHITELIST
        ) {
            return false;
        }

        return outboundWhitelistsEnabled[senderWhiteList][receiverWhiteList];
    }

    function setWhitelistEnabled(bool enabled) external onlyOwner {

        _setWhitelistEnabled(enabled);
    }

    function addToWhitelist(address addressToAdd, uint8 whitelist)
        external
        onlyWhitelister
    {

        _addToWhitelist(addressToAdd, whitelist);
    }

    function removeFromWhitelist(address addressToRemove)
        external
        onlyWhitelister
    {

        _removeFromWhitelist(addressToRemove);
    }

    function updateOutboundWhitelistEnabled(
        uint8 sourceWhitelist,
        uint8 destinationWhitelist,
        bool newEnabledValue
    ) external onlyWhitelister {

        _updateOutboundWhitelistEnabled(
            sourceWhitelist,
            destinationWhitelist,
            newEnabledValue
        );
    }

    uint256[47] private __gap;
}// MIT

pragma solidity ^0.8.0;



contract RevocableToAddress is ERC20Upgradeable, RevokerRole {

    event RevokeToAddress(
        address indexed revoker,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    function _revokeToAddress(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {

        ERC20Upgradeable._transfer(from, to, amount);
        emit RevokeToAddress(msg.sender, from, to, amount);
        return true;
    }


    function revokeToAddress(
        address from,
        address to,
        uint256 amount
    ) external onlyRevoker returns (bool) {

        return _revokeToAddress(from, to, amount);
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;









contract WrappedTokenV1 is
    Proxiable,
    ERC20Upgradeable,
    ERC1404,
    OwnerRole,
    Whitelistable,
    Mintable,
    Burnable,
    Revocable,
    Pausable,
    Blacklistable,
    RevocableToAddress
{

    AggregatorV3Interface public reserveFeed;

    uint8 public constant SUCCESS_CODE = 0;
    uint8 public constant FAILURE_NON_WHITELIST = 1;
    uint8 public constant FAILURE_PAUSED = 2;
    string public constant SUCCESS_MESSAGE = "SUCCESS";
    string public constant FAILURE_NON_WHITELIST_MESSAGE =
        "The transfer was restricted due to white list configuration.";
    string public constant FAILURE_PAUSED_MESSAGE =
        "The transfer was restricted due to the contract being paused.";
    string public constant UNKNOWN_ERROR = "Unknown Error Code";

    uint8 public constant FAILURE_BLACKLIST = 3;
    string public constant FAILURE_BLACKLIST_MESSAGE =
        "Restricted due to blacklist";

    event OracleAddressUpdated(address newAddress);

    constructor(
        string memory name,
        string memory symbol,
        AggregatorV3Interface resFeed
    ) {
        initialize(msg.sender, name, symbol, 0, resFeed, true, false);
    }

    function initialize(
        address owner,
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        AggregatorV3Interface resFeed,
        bool whitelistEnabled,
        bool flashMintEnabled
    ) public initializer {

        reserveFeed = resFeed;

        ERC20Upgradeable.__ERC20_init(name, symbol);
        Mintable._mint(msg.sender, owner, initialSupply);
        OwnerRole._addOwner(owner);

        Mintable._setFlashMintEnabled(flashMintEnabled);
        Whitelistable._setWhitelistEnabled(whitelistEnabled);

        Mintable._setFlashMintFeeReceiver(owner);
    }

    function updateCodeAddress(address newAddress) external onlyOwner {

        Proxiable._updateCodeAddress(newAddress);
    }

    function updateOracleAddress(AggregatorV3Interface resFeed)
        external
        onlyOwner
    {

        reserveFeed = resFeed;

        mint(msg.sender, 0);
        emit OracleAddressUpdated(address(reserveFeed));
    }

    function detectTransferRestriction(
        address from,
        address to,
        uint256
    ) public view override returns (uint8) {

        if (!checkBlacklistAllowed(from, to)) {
            return FAILURE_BLACKLIST;
        }

        if (Pausable.paused()) {
            return FAILURE_PAUSED;
        }

        if (OwnerRole.isOwner(from)) {
            return SUCCESS_CODE;
        }

        if (!checkWhitelistAllowed(from, to)) {
            return FAILURE_NON_WHITELIST;
        }

        return SUCCESS_CODE;
    }

    function messageForTransferRestriction(uint8 restrictionCode)
        public
        pure
        override
        returns (string memory)
    {

        if (restrictionCode == FAILURE_BLACKLIST) {
            return FAILURE_BLACKLIST_MESSAGE;
        }

        if (restrictionCode == SUCCESS_CODE) {
            return SUCCESS_MESSAGE;
        }

        if (restrictionCode == FAILURE_NON_WHITELIST) {
            return FAILURE_NON_WHITELIST_MESSAGE;
        }

        if (restrictionCode == FAILURE_PAUSED) {
            return FAILURE_PAUSED_MESSAGE;
        }

        return UNKNOWN_ERROR;
    }

    modifier notRestricted(
        address from,
        address to,
        uint256 value
    ) {

        uint8 restrictionCode = detectTransferRestriction(from, to, value);
        require(
            restrictionCode == SUCCESS_CODE,
            messageForTransferRestriction(restrictionCode)
        );
        _;
    }

    function transfer(address to, uint256 value)
        public
        override
        notRestricted(msg.sender, to, value)
        returns (bool success)
    {

        success = ERC20Upgradeable.transfer(to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override notRestricted(from, to, value) returns (bool success) {

        success = ERC20Upgradeable.transferFrom(from, to, value);
    }

    function withdraw() external onlyOwner {

        payable(msg.sender).transfer(address(this).balance);
    }

    function recover(IERC20Upgradeable token)
        external
        onlyOwner
        returns (bool success)
    {

        success = token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function mint(address account, uint256 amount)
        public
        override
        onlyMinter
        returns (bool)
    {

        uint256 total = amount + ERC20Upgradeable.totalSupply();
        (, int256 answer, , , ) = reserveFeed.latestRoundData();

        uint256 decimals = ERC20Upgradeable.decimals();
        uint256 reserveFeedDecimals = reserveFeed.decimals();

        require(decimals >= reserveFeedDecimals, "invalid price feed decimals");

        require(
            (answer > 0) &&
                (uint256(answer) * 10**uint256(decimals - reserveFeedDecimals) >
                    total),
            "reserve must exceed the total supply"
        );

        return Mintable.mint(account, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address,
        uint256 amount
    ) internal view override {

        if (from != address(0)) {
            return;
        }

        require(
            ERC20FlashMintUpgradeable.maxFlashLoan(address(this)) > amount,
            "mint exceeds max allowed"
        );
    }

    uint256[49] private __gap;
}