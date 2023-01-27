

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
}




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
}




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
}




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
}




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
}




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
}




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
}




pragma solidity >=0.6.0 <0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}



pragma solidity 0.6.11;




contract AuthorizeableUpgradeable is
    Initializable,
    ContextUpgradeable,
    OwnableUpgradeable
{

    address[] private _authorizedAddresses;

    function __Authorizeable_init() internal initializer {

        __Context_init_unchained();
    }

    function addAuthorizedAddress(address address_) external onlyOwner {

        require(address_ != address(0), "Add authorize address is zero");
        for (uint256 i = 0; i < _authorizedAddresses.length; i++) {
            require(
                _authorizedAddresses[i] != address_,
                "address_ already exists"
            );
        }
        _authorizedAddresses.push(address_);
    }

    function removeAuthorizedAddress(address address_) external onlyOwner {

        require(address_ != address(0), "Remove authorize address is zero");
        for (uint256 i = 0; i < _authorizedAddresses.length; i++) {
            if (_authorizedAddresses[i] == address_) {
                _authorizedAddresses[i] = _authorizedAddresses[
                    _authorizedAddresses.length - 1
                ];
                _authorizedAddresses.pop();
                return;
            }
        }
    }

    function authorizedAddresses()
        external
        view
        onlyOwner
        returns (address[] memory)
    {

        return _authorizedAddresses;
    }

    modifier onlyAuthorized() {

        address msgSender = _msgSender();
        bool isAuthorized = false;

        for (uint256 i = 0; i < _authorizedAddresses.length; i++) {
            if (_authorizedAddresses[i] == msgSender) {
                isAuthorized = true;
                break;
            }
        }

        require(isAuthorized, "Sender not authorized");

        _;
    }
}



pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;





struct FrozenWallet {
    address wallet;
    uint256 totalAmount;
    uint256 monthlyAmount;
    uint256 initialAmount;
    uint256 startDay;
    bool immediately;
    bool scheduled;
}

struct VestingType {
    uint256 monthlyRate;
    uint256 initialRate;
    uint256 afterDays;
    bool immediately;
    bool vesting;
}

contract ShadowsToken is
    Initializable,
    OwnableUpgradeable,
    AuthorizeableUpgradeable,
    ERC20PausableUpgradeable
{

    event AddFrozenWallet(address indexed _address);
    event Pause();
    event Unpause();

    mapping(address => FrozenWallet) public frozenWallets;
    VestingType[] public vestingTypes;
    uint256 constant maxTotalSupply = 1e8 ether;
    uint256 constant releaseTime = 1614697200;

    function initialize() external initializer {

        __Ownable_init();
        __Authorizeable_init();
        __ERC20_init("Shadows Network", "DOWS");
        __ERC20Pausable_init();

        _mint(address(0x24F6e9860b05B21bcfB9d4f56D09aa6Aefb589e3), 2000000 ether);
        _mint(address(0xF2faAC2a134381124ee0Be7Ec76258e8a4c11C7b), 2000000 ether);

        vestingTypes.push(
            VestingType(
                1e19,
                2e19,
                0,
                true,
                true
            )
        ); // 20% unlock immediately on TGE, rest unlocked over 8 months
        vestingTypes.push(
            VestingType(
                9375e15,
                25e18,
                0,
                true,
                true
            )
        ); // 25% unlock immediately on TGE, rest unlocked over 8 months
        vestingTypes.push(
            VestingType(416e16, 0, 270 days, false, true)
        ); // First unlock at month 10, rest unlock over 24 months
    }

    function addAllocations(
        address[] memory addresses,
        uint256[] memory totalAmounts,
        uint256 vestingTypeIndex
    ) external onlyOwner returns (bool) {

        require(
            addresses.length == totalAmounts.length,
            "Address and totalAmounts length must be same"
        );
        require(
            vestingTypes[vestingTypeIndex].vesting,
            "Vesting type isn't found"
        );

        VestingType memory vestingType = vestingTypes[vestingTypeIndex];
        uint256 addressesLength = addresses.length;

        for (uint256 i = 0; i < addressesLength; i++) {
            address address_ = addresses[i];
            uint256 totalAmount = totalAmounts[i];
            uint256 monthlyAmount =
                totalAmounts[i].mul(vestingType.monthlyRate).div(
                    100000000000000000000
                );
            uint256 initialAmount =
                totalAmounts[i].mul(vestingType.initialRate).div(
                    100000000000000000000
                );
            uint256 afterDay = vestingType.afterDays;
            bool immediately = vestingType.immediately;

            addFrozenWallet(
                address_,
                totalAmount,
                monthlyAmount,
                initialAmount,
                afterDay,
                immediately
            );
        }

        return true;
    }

    function addFrozenWallet(
        address wallet,
        uint256 totalAmount,
        uint256 monthlyAmount,
        uint256 initialAmount,
        uint256 afterDays,
        bool immediately
    ) internal {

        if (!frozenWallets[wallet].scheduled) {
            _mint(wallet, totalAmount);

            frozenWallets[wallet] = FrozenWallet(
                wallet,
                totalAmount,
                monthlyAmount,
                initialAmount,
                releaseTime.add(afterDays),
                immediately,
                true
            );

            emit AddFrozenWallet(wallet);
        }
    }

    function mint(address account, uint256 amount) external onlyAuthorized {

        _mint(account, amount);
    }

    function _mint(address account, uint256 amount) internal override {

        uint256 totalSupply = super.totalSupply();
        require(
            maxTotalSupply >= totalSupply.add(amount),
            "Max total supply over"
        );

        super._mint(account, amount);
    }

    function _beforeTokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {

        require(canTransfer(sender, amount), "Wait for the vesting day!");
        super._beforeTokenTransfer(sender, recipient, amount);
    }

    function getTransferableAmount(address sender)
        public
        view
        returns (uint256)
    {

        FrozenWallet memory frozenWallet = frozenWallets[sender];
        uint256 months =
            getMonths(frozenWallet.immediately, frozenWallet.startDay);
        uint256 monthlyTransferableAmount =
            frozenWallet.monthlyAmount.mul(months);
        uint256 transferableAmount =
            monthlyTransferableAmount.add(frozenWallet.initialAmount);

        return
            transferableAmount > frozenWallet.totalAmount
                ? frozenWallet.totalAmount
                : transferableAmount;
    }

    function getRequiredAmount(address sender) public view returns (uint256) {

        uint256 transferableAmount = getTransferableAmount(sender);
        return frozenWallets[sender].totalAmount.sub(transferableAmount);
    }

    function canTransfer(address sender, uint256 amount)
        public
        view
        returns (bool)
    {

        if (!frozenWallets[sender].scheduled) {
            return true;
        }

        uint256 balance = balanceOf(sender);
        uint256 requiredAmount = getRequiredAmount(sender);

        if (
            !isStarted(frozenWallets[sender].startDay) ||
            balance.sub(amount) < requiredAmount
        ) {
            return false;
        }

        return true;
    }

    function getMonths(bool immediately, uint256 startDay)
        public
        view
        returns (uint256)
    {

        uint256 delay = immediately ? 0 : 1;

        if (block.timestamp < startDay) {
            return 0;
        }

        uint256 diff = block.timestamp.sub(startDay);
        uint256 months = diff.div(30 days).add(delay);

        return months;
    }

    function isStarted(uint256 startDay) public view returns (bool) {

        if (block.timestamp < releaseTime || block.timestamp < startDay) {
            return false;
        }

        return true;
    }

    function pause(bool status) external onlyOwner {

        if (status) {
            _pause();
            emit Pause();
        } else {
            _unpause();
            emit Unpause();
        }
    }
}