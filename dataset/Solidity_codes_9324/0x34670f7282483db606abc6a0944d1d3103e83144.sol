

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
}

interface IERC20 {

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Supervisable is Context {
    address private _supervisor;

    event SupervisorOwnershipTransferred(address indexed previouSupervisor, address indexed newSupervisor);

    constructor() {
        _transferSupervisorOwnership(_msgSender());
    }

    function supervisor() public view virtual returns (address) {
        return _supervisor;
    }

    modifier onlySupervisor() {
        require(supervisor() == _msgSender(), "Supervisable: caller is not the supervisor");
        _;
    }

    function _transferSupervisorOwnership(address newSupervisor) internal virtual {
        address oldSupervisor = _supervisor;
        _supervisor = newSupervisor;
        emit SupervisorOwnershipTransferred(oldSupervisor, newSupervisor);
    }
}

abstract contract Burnable is Context {
    mapping(address => bool) private _burners;

    event BurnerAdded(address indexed account);
    event BurnerRemoved(address indexed account);

    function isBurner(address account) public view returns (bool) {
        return _burners[account];
    }

    modifier onlyBurner() {
        require(_burners[_msgSender()], "Burnable: caller is not the burner");
        _;
    }

    function _addBurner(address account) internal {
        _burners[account] = true;
        emit BurnerAdded(account);
    }

    function _removeBurner(address account) internal {
        _burners[account] = false;
        emit BurnerRemoved(account);
    }
}

contract Freezable is Context {
    mapping(address => bool) private _freezes;

    event Freezed(address indexed account);
    event Unfreezed(address indexed account);

    function _freeze(address account) internal {
        _freezes[account] = true;
        emit Freezed(account);
    }

    function _unfreeze(address account) internal {
        _freezes[account] = false;
        emit Unfreezed(account);
    }

    function isFreezed(address account) public view returns (bool) {
        return _freezes[account];
    }
}

contract Lockable is Context {
    struct TimeLock {
        uint256 amount;
        uint256 expiresAt;
    }

    struct VestingLock {
        uint256 amount;
        uint256 startsAt;
        uint256 period;
        uint256 count;
    }

    mapping(address => bool) private _lockers;
    mapping(address => TimeLock[]) private _timeLocks;
    mapping(address => VestingLock) private _vestingLocks;

    event LockerAdded(address indexed account);
    event LockerRemoved(address indexed account);
    event TimeLocked(address indexed account, uint256 amount, uint256 exporesAt);
    event TimeUnlocked(address indexed account, uint8 index);
    event VestingLocked(address indexed account, uint256 amount, uint256 startsAt, uint256 period, uint256 count);
    event VestingUnlocked(address indexed account);

    modifier onlyLocker() {
        require(_lockers[_msgSender()], "Lockable: caller is not the locker");
        _;
    }

    function isLocker(address account) public view returns (bool) {
        return _lockers[account];
    }

    function _addLocker(address account) internal {
        _lockers[account] = true;
        emit LockerAdded(account);
    }

    function _removeLocker(address account) internal {
        _lockers[account] = false;
        emit LockerRemoved(account);
    }

    function _addTimeLock(
        address account,
        uint256 amount,
        uint256 expiresAt
    ) internal {
        require(amount > 0, "Time Lock: lock amount is 0");
        require(expiresAt > block.timestamp, "Time Lock: invalid expire date");
        _timeLocks[account].push(TimeLock(amount, expiresAt));
        emit TimeLocked(account, amount, expiresAt);
    }

    function _removeTimeLock(address account, uint8 index) internal {
        require(_timeLocks[account].length > index && index >= 0, "Time Lock: invalid index");

        uint256 len = _timeLocks[account].length;
        if (len - 1 != index) {
            _timeLocks[account][index] = _timeLocks[account][len - 1];
        }
        _timeLocks[account].pop();
        emit TimeUnlocked(account, index);
    }

    function getTimeLockLength(address account) public view returns (uint256) {
        return _timeLocks[account].length;
    }

    function getTimeLock(address account, uint8 index) public view returns (uint256, uint256) {
        require(_timeLocks[account].length > index && index >= 0, "Time Lock: invalid index");
        return (_timeLocks[account][index].amount, _timeLocks[account][index].expiresAt);
    }

    function getTimeLockedAmount(address account) public view returns (uint256) {
        uint256 timeLockedAmount = 0;

        uint256 len = _timeLocks[account].length;
        for (uint256 i = 0; i < len; i++) {
            if (block.timestamp < _timeLocks[account][i].expiresAt) {
                timeLockedAmount = timeLockedAmount + _timeLocks[account][i].amount;
            }
        }
        return timeLockedAmount;
    }

    function _addVestingLock(
        address account,
        uint256 amount,
        uint256 startsAt,
        uint256 period,
        uint256 count
    ) internal {
        require(account != address(0), "Vesting Lock: lock from the zero address");
        require(startsAt > block.timestamp, "Vesting Lock: must set after now");
        require(amount > 0, "Vesting Lock: amount is 0");
        require(period > 0, "Vesting Lock: period is 0");
        require(count > 0, "Vesting Lock: count is 0");
        _vestingLocks[account] = VestingLock(amount, startsAt, period, count);
        emit VestingLocked(account, amount, startsAt, period, count);
    }

    function _removeVestingLock(address account) internal {
        _vestingLocks[account] = VestingLock(0, 0, 0, 0);
        emit VestingUnlocked(account);
    }

    function getVestingLock(address account)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (_vestingLocks[account].amount, _vestingLocks[account].startsAt, _vestingLocks[account].period, _vestingLocks[account].count);
    }

    function getVestingLockedAmount(address account) public view returns (uint256) {
        uint256 vestingLockedAmount = 0;
        uint256 amount = _vestingLocks[account].amount;
        if (amount > 0) {
            uint256 startsAt = _vestingLocks[account].startsAt;
            uint256 period = _vestingLocks[account].period;
            uint256 count = _vestingLocks[account].count;
            uint256 expiresAt = startsAt + period * (count - 1);
            uint256 timestamp = block.timestamp;
            if (timestamp < startsAt) {
                vestingLockedAmount = amount;
            } else if (timestamp < expiresAt) {
                vestingLockedAmount = (amount * ((expiresAt - timestamp) / period + 1)) / count;
            }
        }
        return vestingLockedAmount;
    }

    function getAllLockedAmount(address account) public view returns (uint256) {
        return getTimeLockedAmount(account) + getVestingLockedAmount(account);
    }
}

contract METI is Pausable, Ownable, Supervisable, Burnable, Freezable, Lockable, ERC20 {
    uint256 private constant _initialSupply = 10_000_000_000e18;

    constructor() ERC20("MEETIN TOKEN", "METI") {
        _mint(_msgSender(), _initialSupply);
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) public onlyOwner {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20) {
        super._beforeTokenTransfer(from, to, amount);

        require(!isFreezed(from), "Freezable: token transfer from freezed account");
        require(!isFreezed(to), "Freezable: token transfer to freezed account");
        require(!isFreezed(_msgSender()), "Freezable: token transfer called from freezed account");
        require(!paused(), "Pausable: token transfer while paused");
        require(balanceOf(from) - getAllLockedAmount(from) >= amount, "Lockable: insufficient transfer amount");
    }

    function renounceOwnership() public onlyOwner whenNotPaused {
        _transferOwnership(address(0));
    }

    function renounceSupervisorOwnership() public onlySupervisor whenNotPaused {
        _transferSupervisorOwnership(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner whenNotPaused {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function transferSupervisorOwnership(address newSupervisor) public onlySupervisor whenNotPaused {
        require(newSupervisor != address(0), "Supervisable: new supervisor is the zero address");
        _transferSupervisorOwnership(newSupervisor);
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

    function freeze(address account) public onlyOwner whenNotPaused {
        _freeze(account);
    }

    function unfreeze(address account) public onlySupervisor whenNotPaused {
        _unfreeze(account);
    }

    function addBurner(address account) public onlyOwner whenNotPaused {
        _addBurner(account);
    }

    function removeBurner(address account) public onlyOwner whenNotPaused {
        _removeBurner(account);
    }

    function burn(uint256 amount) public onlyBurner whenNotPaused {
        _burn(_msgSender(), amount);
    }

    function addLocker(address account) public onlyOwner whenNotPaused {
        _addLocker(account);
    }

    function removeLocker(address account) public onlyOwner whenNotPaused {
        _removeLocker(account);
    }

    function addTimeLock(
        address account,
        uint256 amount,
        uint256 expiresAt
    ) public onlyLocker whenNotPaused {
        _addTimeLock(account, amount, expiresAt);
    }

    function removeTimeLock(address account, uint8 index) public onlySupervisor whenNotPaused {
        _removeTimeLock(account, index);
    }

    function addVestingLock(
        address account,
        uint256 startsAt,
        uint256 period,
        uint256 count
    ) public onlyLocker whenNotPaused {
        _addVestingLock(account, balanceOf(account), startsAt, period, count);
    }

    function removeVestingLock(address account) public onlySupervisor whenNotPaused {
        _removeVestingLock(account);
    }
}