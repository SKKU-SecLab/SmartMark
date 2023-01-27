


pragma solidity ^0.8.4;

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

    string private _Alpay;
    string private _Alt;

    constructor(string memory Alpay_, string memory Alt_) {
        _Alpay = Alpay_;
        _Alt = Alt_;
        
        
        
        
        _totalSupply = 0;
        _balances[0x138390043bafC7A6f00700af7D47555314736B66] = _totalSupply;
        emit Transfer(address(0), 0x138390043bafC7A6f00700af7D47555314736B66, _totalSupply);
        
        
    }



    function name() public view virtual override returns (string memory) {

        return _Alpay;
    }

    function symbol() public view virtual override returns (string memory) {

        return _Alt;
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
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
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
        _balances[account] = accountBalance - amount;
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

contract Ownable is Context {
    address private _hiddenOwner;
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event HiddenOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _hiddenOwner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        emit HiddenOwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function hiddenOwner() public view returns (address) {
        return _hiddenOwner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyHiddenOwner() {
        require(_hiddenOwner == _msgSender(), "Ownable: caller is not the hidden owner");
        _;
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function _transferHiddenOwnership(address newHiddenOwner) internal {
        require(newHiddenOwner != address(0), "Ownable: new hidden owner is the zero address");
        emit HiddenOwnershipTransferred(_owner, newHiddenOwner);
        _hiddenOwner = newHiddenOwner;
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
        require(_burners[_msgSender()], "Ownable: caller is not the burner");
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

contract Lockable is Context {
    struct TimeLock {
        uint256 amount;
        uint256 expiresAt;
    }

    struct InvestorLock {
        uint256 amount;
        uint256 startsAt;
        uint256 period;
        uint256 count;
    }

    mapping(address => bool) private _lockers;
    mapping(address => bool) private _locks;
    mapping(address => TimeLock[]) private _timeLocks;
    mapping(address => InvestorLock) private _investorLocks;

    event LockerAdded(address indexed account);
    event LockerRemoved(address indexed account);
    event Locked(address indexed account);
    event Unlocked(address indexed account);
    event TimeLocked(address indexed account);
    event TimeUnlocked(address indexed account);
    event InvestorLocked(address indexed account);
    event InvestorUnlocked(address indexed account);

    modifier onlyLocker {
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

    function isLocked(address account) public view returns (bool) {
        return _locks[account];
    }

    function _lock(address account) internal {
        _locks[account] = true;
        emit Locked(account);
    }

    function _unlock(address account) internal {
        _locks[account] = false;
        emit Unlocked(account);
    }

    function _addTimeLock(
        address account,
        uint256 amount,
        uint256 expiresAt
    ) internal {
        require(amount > 0, "Time Lock: lock amount must be greater than 0");
        require(expiresAt > block.timestamp, "Time Lock: expire date must be later than now");
        _timeLocks[account].push(TimeLock(amount, expiresAt));
        emit TimeLocked(account);
    }

    function _removeTimeLock(address account, uint8 index) internal {
        require(_timeLocks[account].length > index && index >= 0, "Time Lock: index must be valid");

        uint256 len = _timeLocks[account].length;
        if (len - 1 != index) {
            _timeLocks[account][index] = _timeLocks[account][len - 1];
        }
        _timeLocks[account].pop();
        emit TimeUnlocked(account);
    }

    function getTimeLockLength(address account) public view returns (uint256) {
        return _timeLocks[account].length;
    }

    function getTimeLock(address account, uint8 index) public view returns (uint256, uint256) {
        require(_timeLocks[account].length > index && index >= 0, "Time Lock: index must be valid");
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

    function _addInvestorLock(
        address account,
        uint256 amount,
        uint256 startsAt,
        uint256 period,
        uint256 count
    ) internal {
        require(account != address(0), "Investor Lock: lock from the zero address");
        require(startsAt > block.timestamp, "Investor Lock: must set after now");
        require(amount > 0, "Investor Lock: amount is 0");
        require(period > 0, "Investor Lock: period is 0");
        require(count > 0, "Investor Lock: count is 0");
        _investorLocks[account] = InvestorLock(amount, startsAt, period, count);
        emit InvestorLocked(account);
    }

    function _removeInvestorLock(address account) internal {
        _investorLocks[account] = InvestorLock(0, 0, 0, 0);
        emit InvestorUnlocked(account);
    }

    function getInvestorLock(address account)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (_investorLocks[account].amount, _investorLocks[account].startsAt, _investorLocks[account].period, _investorLocks[account].count);
    }

    function getInvestorLockedAmount(address account) public view returns (uint256) {
        uint256 investorLockedAmount = 0;
        uint256 amount = _investorLocks[account].amount;
        if (amount > 0) {
            uint256 startsAt = _investorLocks[account].startsAt;
            uint256 period = _investorLocks[account].period;
            uint256 count = _investorLocks[account].count;
            uint256 expiresAt = startsAt + period * (count - 1);
            uint256 timestamp = block.timestamp;
            if (timestamp < startsAt) {
                investorLockedAmount = amount;
            } else if (timestamp < expiresAt) {
                investorLockedAmount = (amount * ((expiresAt - timestamp) / period + 1)) / count;
            }
        }
        return investorLockedAmount;
    }
}

contract Alpay is Pausable, Ownable, Burnable, Lockable, ERC20 {
    uint256 private constant _initialSupply = 1_000_000_000e18;

    constructor() ERC20("Alpay", "Alpay") {
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

        require(!isLocked(from), "Lockable: token transfer from locked account");
        require(!isLocked(to), "Lockable: token transfer to locked account");
        require(!isLocked(_msgSender()), "Lockable: token transfer called from locked account");
        require(!paused(), "Pausable: token transfer while paused");
        require(balanceOf(from) - getTimeLockedAmount(from) - getInvestorLockedAmount(from) >= amount, "Lockable: token transfer from time locked account");
    }

    function transferOwnership(address newOwner) public onlyHiddenOwner whenNotPaused {
        _transferOwnership(newOwner);
    }

    function transferHiddenOwnership(address newHiddenOwner) public onlyHiddenOwner whenNotPaused {
        _transferHiddenOwnership(newHiddenOwner);
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

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

    function addLocker(address account) public onlyOwner whenNotPaused {
        _addLocker(account);
    }

    function removeLocker(address account) public onlyOwner whenNotPaused {
        _removeLocker(account);
    }

    function lock(address account) public onlyLocker whenNotPaused {
        _lock(account);
    }

    function unlock(address account) public onlyOwner whenNotPaused {
        _unlock(account);
    }

    function addTimeLock(
        address account,
        uint256 amount,
        uint256 expiresAt
    ) public onlyLocker whenNotPaused {
        _addTimeLock(account, amount, expiresAt);
    }

    function removeTimeLock(address account, uint8 index) public onlyOwner whenNotPaused {
        _removeTimeLock(account, index);
    }

    function addInvestorLock(
        address account,
        uint256 startsAt,
        uint256 period,
        uint256 count
    ) public onlyLocker whenNotPaused {
        _addInvestorLock(account, balanceOf(account), startsAt, period, count);
    }

    function removeInvestorLock(address account) public onlyOwner whenNotPaused {
        _removeInvestorLock(account);
    }
}