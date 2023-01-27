
pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC20Burnable_init_unchained();
    }

    function __ERC20Burnable_init_unchained() internal initializer {
    }
    using SafeMathUpgradeable for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


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

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20PausableUpgradeable is Initializable, ERC20Upgradeable, PausableUpgradeable {
    function __ERC20Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
    }

    function __ERC20Pausable_init_unchained() internal initializer {
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
    uint256[50] private __gap;
}// UNLICENSED
pragma solidity 0.6.12;

interface IManagementContract {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function whitelist(address addr) external view;


    function unWhitelist(address addr) external view;


    function isWhitelisted(address addr) external view returns (bool);


    function freeze(address addr) external;


    function unFreeze(address addr) external;


    function isFrozen(address addr) external view returns (bool);


    function addSuperWhitelisted(address addr) external;


    function removeSuperWhitelisted(address addr) external;


    function isSuperWhitelisted(address addr) external view returns (bool);


    function nonWhitelistedDelay() external view returns (uint256);


    function nonWhitelistedDepositLimit() external view returns (uint256);


    function setNonWhitelistedDelay(uint256 _nonWhitelistedDelay) external view;


    function setNonWhitelistedDepositLimit(uint256 _nonWhitelistedDepositLimit) external view;


    function paused() external view returns (bool);

}// UNLICENSED

pragma solidity 0.6.12;


contract ERC20PresetMinterPauserUpgradeableModified is Initializable, ContextUpgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable { // MODIFIED

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00; // ADDED
    bytes32 private constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    IManagementContract public managementContract; // ADDED


    function initialize(string memory name, string memory symbol, address managementContractAddress) public virtual {

        managementContract = IManagementContract(managementContractAddress); // ADDED
        __ERC20PresetMinterPauser_init(name, symbol);
    }

    function __ERC20PresetMinterPauser_init(string memory name, string memory symbol) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
        __ERC20Burnable_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
    }

    function __ERC20PresetMinterPauser_init_unchained(string memory name, string memory symbol) internal initializer {

    }

    function pause() public virtual {

        require(managementContract.hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to pause"); // MODIFIED
        _pause();
    }

    function unpause() public virtual {

        require(managementContract.hasRole(PAUSER_ROLE, _msgSender()), "ERC20PresetMinterPauser: must have pauser role to unpause"); // MODIFIED
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20Upgradeable, ERC20PausableUpgradeable) {

        super._beforeTokenTransfer(from, to, amount);
    }

    uint256[50] private __gap;
}// UNLICENSED
pragma solidity 0.6.12;

interface IERC1404 {

    function detectTransferRestriction (address from, address to, uint256 value) external view returns (uint8);

    function messageForTransferRestriction (uint8 restrictionCode) external view returns (string memory);
}// UNLICENSED
pragma solidity 0.6.12;

interface IERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}// UNLICENSED
pragma solidity 0.6.12;


contract HHH is ERC20PresetMinterPauserUpgradeableModified, IERC1404, IERC165 {

    bytes32 private constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");

    mapping(address => Deposit[]) public pendingDeposits;

    uint256 public nonWhitelistedDustThreshold; // This is to prevent attacker making multiple small deposits and preventing legitimate user from receiving deposits

    event RecoverFrozen(address from, address to, uint256 amount);

    struct Deposit {
        uint256 time;
        uint256 amount;
    }

    modifier onlyAdmin virtual {

        require(managementContract.hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "must have ADMIN ROLE");
        _;
    }

    modifier onlyManagementContract virtual {

        require(_msgSender() == address(managementContract), "only management contract can call this function");
        _;
    }

    function initialize(string memory name, string memory symbol, address managementContractAddress) public virtual override initializer {

        require(managementContractAddress != address(0), "Management contract address cannot be zero.");
        ERC20PresetMinterPauserUpgradeableModified.initialize(name, symbol, managementContractAddress);

        nonWhitelistedDustThreshold = 10**17; // 0.1 of the coin
    }

    function setNonWhitelistedDustThreshold(uint256 _nonWhitelistedDustThreshold) external virtual onlyAdmin {

        nonWhitelistedDustThreshold = _nonWhitelistedDustThreshold;
    }

    function recoverFrozenFunds(address from, address to, uint256 amount) external virtual onlyAdmin {

        require(to != address(0), "Address 'to' cannot be zero.");
        require(managementContract.isFrozen(from), "Need to be frozen first");

        managementContract.unFreeze(from); // Make sure this contract has WHITELIST_ROLE on management contract
        if (!managementContract.isWhitelisted(from)) {
            removeAllPendingDeposits(from);
        }
        _transfer(from, to, amount);
        managementContract.freeze(from);

        emit RecoverFrozen(from, to, amount);
    }

    string public constant SUCCESS_MESSAGE = "SUCCESS";
    string public constant ERROR_REASON_GLOBAL_PAUSE = "Global pause is active";
    string public constant ERROR_REASON_TO_FROZEN = "`to` address is frozen";
    string public constant ERROR_REASON_FROM_FROZEN = "`from` address is frozen";
    string public constant ERROR_REASON_NOT_ENOUGH_UNLOCKED = "User's unlocked balance is less than transfer amount";
    string public constant ERROR_REASON_BELOW_THRESHOLD = "Deposit for non-whitelisted user is below threshold";
    string public constant ERROR_REASON_PENDING_DEPOSITS_LENGTH = "Too many pending deposits for non-whitelisted user";
    string public constant ERROR_DEFAULT = "Generic error message";

    uint8 public constant SUCCESS_CODE = 0;
    uint8 public constant ERROR_CODE_GLOBAL_PAUSE = 1;
    uint8 public constant ERROR_CODE_TO_FROZEN = 2;
    uint8 public constant ERROR_CODE_FROM_FROZEN = 3;
    uint8 public constant ERROR_CODE_NOT_ENOUGH_UNLOCKED = 4;
    uint8 public constant ERROR_CODE_BELOW_THRESHOLD = 5;
    uint8 public constant ERROR_CODE_PENDING_DEPOSITS_LENGTH = 6;

    
    modifier notRestricted (address from, address to, uint256 value) virtual {

        uint8 restrictionCode = detectTransferRestriction(from, to, value);
        require(restrictionCode == SUCCESS_CODE, messageForTransferRestriction(restrictionCode));
        _;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override notRestricted(from, to, amount) {

        super._beforeTokenTransfer(from, to, amount);

        if (managementContract.isSuperWhitelisted(to)) {
            uint256 ub = unlockedBalance(from);

            if (ub < amount) {
                uint256 amountToUnlock = amount.sub(ub);
                releaseDepositsForSuperWhitelisted(from, amountToUnlock);
            }
        } else {
            if (!managementContract.isWhitelisted(to)) {
                Deposit memory deposit = Deposit({time: now, amount: amount}); // solium-disable-line security/no-block-members
                pendingDeposits[to].push(deposit);
            }
        }
    }

    function detectTransferRestriction (address from, address to, uint256 value) public virtual override view returns (uint8) {

        if (managementContract.paused()) {
            return ERROR_CODE_GLOBAL_PAUSE;
        }
        
        if (managementContract.isFrozen(to)) {
            return ERROR_CODE_TO_FROZEN;
        }

        if (managementContract.isFrozen(from)) {
            return ERROR_CODE_FROM_FROZEN;
        }

        if (!managementContract.isSuperWhitelisted(to)) {
            
            if (!managementContract.isWhitelisted(from)) {
                if (! (unlockedBalance(from) >= value)) {
                    return ERROR_CODE_NOT_ENOUGH_UNLOCKED;
                }
            }

            if (!managementContract.isWhitelisted(to)) {
                uint256 nonWhitelistedDelay = managementContract.nonWhitelistedDelay();
                uint256 nonWhitelistedDepositLimit = managementContract.nonWhitelistedDepositLimit();
                uint256 pendingDepositsLength = pendingDeposits[to].length;

                if (! (pendingDepositsLength < nonWhitelistedDepositLimit || (now > pendingDeposits[to][pendingDepositsLength - nonWhitelistedDepositLimit].time + nonWhitelistedDelay))) { // solium-disable-line security/no-block-members
                    return ERROR_CODE_PENDING_DEPOSITS_LENGTH;
                }

                if (! (value >= nonWhitelistedDustThreshold)) {
                    return ERROR_CODE_BELOW_THRESHOLD;
                }
            }
        }
    }

    function messageForTransferRestriction (uint8 restrictionCode) public virtual override view returns (string memory) {
        if (restrictionCode == SUCCESS_CODE) {
            return SUCCESS_MESSAGE;
        } else if (restrictionCode == ERROR_CODE_GLOBAL_PAUSE) {
            return ERROR_REASON_GLOBAL_PAUSE;
        } else if (restrictionCode == ERROR_CODE_TO_FROZEN) {
            return ERROR_REASON_TO_FROZEN;
        } else if (restrictionCode == ERROR_CODE_FROM_FROZEN) {
            return ERROR_REASON_FROM_FROZEN;
        } else if (restrictionCode == ERROR_CODE_NOT_ENOUGH_UNLOCKED) {
            return ERROR_REASON_NOT_ENOUGH_UNLOCKED;
        } else if (restrictionCode == ERROR_CODE_BELOW_THRESHOLD) {
            return ERROR_REASON_BELOW_THRESHOLD;
        } else if (restrictionCode == ERROR_CODE_PENDING_DEPOSITS_LENGTH) {
            return ERROR_REASON_PENDING_DEPOSITS_LENGTH;
        } else {
            return ERROR_DEFAULT;
        }
    }

    function supportsInterface(bytes4 interfaceId) external virtual override view returns (bool) {

        return interfaceId == 0x01ffc9a7 || interfaceId == 0xab84a5c8;
    }

    function releaseDepositsForSuperWhitelisted(address from, uint256 amount) internal virtual {

        uint256 nonWhitelistedDelay = managementContract.nonWhitelistedDelay();

        uint256 pendingDepositsLength = pendingDeposits[from].length;

        for (uint256 i = pendingDepositsLength - 1; i != uint256(-1) && pendingDeposits[from][i].time > now - nonWhitelistedDelay; i--) { // solium-disable-line security/no-block-members
            if (amount < pendingDeposits[from][i].amount) {
                pendingDeposits[from][i].amount = pendingDeposits[from][i].amount.sub(amount);
                break;
            } else {
                amount = amount.sub(pendingDeposits[from][i].amount);
                pendingDeposits[from].pop();
            }
        }
    }

    function removeAllPendingDeposits(address from) internal virtual {

        delete pendingDeposits[from];
    }

    function removeAllPendingDepositsExternal(address addr) external virtual onlyManagementContract {

        delete pendingDeposits[addr];
    }

    function putTotalBalanceToLock(address addr) external virtual onlyManagementContract {

        pendingDeposits[addr].push(Deposit({time: now, amount: balanceOf(addr)})); // solium-disable-line security/no-block-members
    }

    function lockedBalance(address user) public virtual view returns (uint256) {

        uint256 balanceLocked = 0;
        uint256 pendingDepositsLength = pendingDeposits[user].length;
        uint256 nonWhitelistedDelay = managementContract.nonWhitelistedDelay();

        for (uint256 i = pendingDepositsLength - 1; i != uint256(-1) && pendingDeposits[user][i].time > now - nonWhitelistedDelay; i--) { // solium-disable-line security/no-block-members
            balanceLocked = balanceLocked.add(pendingDeposits[user][i].amount);
        }
        return balanceLocked;
    }

    function unlockedBalance(address user) public virtual view returns (uint256) {

        return balanceOf(user).sub(lockedBalance(user));
    }
}// UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract HHHmainnet is HHH {

    function initialize(string memory name, string memory symbol, address managementContractAddress, address newMintingAddress) public virtual initializer {

        require(managementContractAddress != address(0), "Management contract address cannot be zero.");
        require(newMintingAddress != address(0), "New minting address cannot be zero.");
        HHH.initialize(name, symbol, managementContractAddress);
        mintingAddress = newMintingAddress;
    }

    address private mintingAddress;

    function changeMintingAddress(address newMintingAddress) external virtual onlyAdmin {

        require(newMintingAddress != address(0), "New minting address cannot be zero.");
        mintingAddress = newMintingAddress;
    }

    function mint(uint256 amount) public virtual onlyAdmin {

        _mint(mintingAddress, amount);
    }

    function burn(uint256 amount) public virtual override onlyAdmin {

        _burn(mintingAddress, amount);
    }
}