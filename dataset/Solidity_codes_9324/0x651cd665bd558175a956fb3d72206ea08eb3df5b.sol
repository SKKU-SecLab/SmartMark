



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}




pragma solidity ^0.8.0;

interface IBEP20 {

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




pragma solidity ^0.8.0;

interface IBEP20Metadata is IBEP20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;

abstract contract Pausable is Ownable {
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

    function pause() public onlyOwner whenNotPaused returns (bool) {
        _paused = true;
        emit Paused(msg.sender);
        return true;
    }

    function unpause() public onlyOwner whenPaused returns (bool) {
        _paused = false;
        emit Unpaused(msg.sender);
        return true;
    }
}




pragma solidity ^0.8.0;




contract BEP20 is Context, IBEP20, IBEP20Metadata, Pausable {

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

    function transfer(address recipient, uint256 amount) public virtual override whenNotPaused returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override whenNotPaused returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override whenNotPaused returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual whenNotPaused returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual whenNotPaused returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "BEP20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}



pragma solidity ^0.8.0;

contract LGEWhitelisted is Context {
    struct WhitelistRound {
        uint256 duration;
        uint256 amountMax;
        mapping(address => bool) addresses;
        mapping(address => uint256) purchased;
    }

    WhitelistRound[] public _lgeWhitelistRounds;

    uint256 public _lgeTimestamp;
    address public _lgePairAddress;

    address public _whitelister;

    event WhitelisterTransferred(address indexed previousWhitelister, address indexed newWhitelister);

    constructor() {
        _whitelister = _msgSender();
    }

    modifier onlyWhitelister() {
        require(_whitelister == _msgSender(), "Caller is not the whitelister");
        _;
    }

    function renounceWhitelister() external onlyWhitelister {
        emit WhitelisterTransferred(_whitelister, address(0));
        _whitelister = address(0);
    }

    function transferWhitelister(address newWhitelister) external onlyWhitelister {
        _transferWhitelister(newWhitelister);
    }

    function _transferWhitelister(address newWhitelister) internal {
        require(newWhitelister != address(0), "New whitelister is the zero address");
        emit WhitelisterTransferred(_whitelister, newWhitelister);
        _whitelister = newWhitelister;
    }


    function createLGEWhitelist(
        address pairAddress,
        uint256[] calldata durations,
        uint256[] calldata amountsMax
    ) external onlyWhitelister() {
        require(durations.length == amountsMax.length, "Invalid whitelist(s)");

        _lgePairAddress = pairAddress;

        if (durations.length > 0) {
            delete _lgeWhitelistRounds;

            for (uint256 i = 0; i < durations.length; i++) {
                WhitelistRound storage whitelistRound = _lgeWhitelistRounds.push();
                whitelistRound.duration = durations[i];
                whitelistRound.amountMax = amountsMax[i];
            }
        }
    }


    function modifyLGEWhitelist(
        uint256 index,
        uint256 duration,
        uint256 amountMax,
        address[] calldata addresses,
        bool enabled
    ) external onlyWhitelister() {
        require(index < _lgeWhitelistRounds.length, "Invalid index");
        require(amountMax > 0, "Invalid amountMax");

        if (duration != _lgeWhitelistRounds[index].duration) _lgeWhitelistRounds[index].duration = duration;

        if (amountMax != _lgeWhitelistRounds[index].amountMax) _lgeWhitelistRounds[index].amountMax = amountMax;

        for (uint256 i = 0; i < addresses.length; i++) {
            _lgeWhitelistRounds[index].addresses[addresses[i]] = enabled;
        }
    }


    function getLGEWhitelistRound()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            uint256
        )
    {
        if (_lgeTimestamp > 0) {
            uint256 wlCloseTimestampLast = _lgeTimestamp;

            for (uint256 i = 0; i < _lgeWhitelistRounds.length; i++) {
                WhitelistRound storage wlRound = _lgeWhitelistRounds[i];

                wlCloseTimestampLast = wlCloseTimestampLast + wlRound.duration;
                if (block.timestamp <= wlCloseTimestampLast)
                    return (
                        i + 1,
                        wlRound.duration,
                        wlCloseTimestampLast,
                        wlRound.amountMax,
                        wlRound.addresses[_msgSender()],
                        wlRound.purchased[_msgSender()]
                    );
            }
        }

        return (0, 0, 0, 0, false, 0);
    }


    function _applyLGEWhitelist(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        if (_lgePairAddress == address(0) || _lgeWhitelistRounds.length == 0) return;

        if (_lgeTimestamp == 0 && sender != _lgePairAddress && recipient == _lgePairAddress && amount > 0)
            _lgeTimestamp = block.timestamp;

        if (sender == _lgePairAddress && recipient != _lgePairAddress) {

            (uint256 wlRoundNumber, , , , , ) = getLGEWhitelistRound();

            if (wlRoundNumber > 0) {
                WhitelistRound storage wlRound = _lgeWhitelistRounds[wlRoundNumber - 1];

                require(wlRound.addresses[recipient], "LGE - Buyer is not whitelisted");

                uint256 amountRemaining = 0;

                if (wlRound.purchased[recipient] < wlRound.amountMax)
                    amountRemaining = wlRound.amountMax - wlRound.purchased[recipient];

                require(amount <= amountRemaining, "LGE - Amount exceeds whitelist maximum");
                wlRound.purchased[recipient] = wlRound.purchased[recipient] + amount;
            }
        }
    }
}



pragma solidity ^0.8.0;


contract LockCoin is BEP20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 totalSupply
    ) BEP20(name, symbol) {
        _mint(_msgSender(), totalSupply);
        _locker = _msgSender();
    }

    event Unlock(address indexed addressLock, uint256 amount);
    event AddAddressLock(address indexed addressLock, uint256 amount);
    event LockerTransferred(address indexed previousLocker, address indexed newLocker);

    address public _locker;
    struct ScheduleLock {
        uint256 unlockTime;
        uint256 amount;
    }
    struct TimeLockByAddress {
        uint256 nextIndexTimeLock;
        uint256 totalLock;
        ScheduleLock[] arrTimeLock;
    }

    mapping(address => TimeLockByAddress) mappingAddressToLock;

    modifier onlyLocker() {
        require(_locker == _msgSender(), "Caller is not the locker");
        _;
    }

    function renounceLocker() external onlyLocker {
        emit LockerTransferred(_locker, address(0));
        _locker = address(0);
    }

    function transferLocker(address newLocker) external onlyLocker {
        _transferLocker(newLocker);
    }

    function _transferLocker(address newLocker) internal {
        require(newLocker != address(0), "New locker is the zero address");
        emit LockerTransferred(_locker, newLocker);
        _locker = newLocker;
    }

    function _addScheduleLockByAddress(
        address _addressLock,
        uint256 _unlockTime,
        uint256 _amount
    ) internal {
        mappingAddressToLock[_addressLock].arrTimeLock.push(ScheduleLock(_unlockTime, _amount));
    }

    function _updateTotalLockByAddress(
        address _addressLock,
        uint256 _totalLock,
        uint256 _nextIndexLock
    ) internal {
        mappingAddressToLock[_addressLock].nextIndexTimeLock = _nextIndexLock;
        mappingAddressToLock[_addressLock].totalLock = _totalLock;
        emit AddAddressLock(_addressLock, _totalLock);
    }

    function _unLock(address _addressLock) internal {
        if (mappingAddressToLock[_addressLock].totalLock == 0) {
            return;
        }
        TimeLockByAddress memory timeLockByAddress = mappingAddressToLock[_addressLock];
        uint256 totalUnlock = 0;
        while (
            timeLockByAddress.nextIndexTimeLock < timeLockByAddress.arrTimeLock.length &&
            block.timestamp >= timeLockByAddress.arrTimeLock[timeLockByAddress.nextIndexTimeLock].unlockTime
        ) {
            emit Unlock(_addressLock, timeLockByAddress.arrTimeLock[timeLockByAddress.nextIndexTimeLock].amount);
            totalUnlock += timeLockByAddress.arrTimeLock[timeLockByAddress.nextIndexTimeLock].amount;
            timeLockByAddress.nextIndexTimeLock += 1;
        }
        if (totalUnlock > 0) {
            _updateTotalLockByAddress(
                _addressLock,
                timeLockByAddress.totalLock - totalUnlock,
                timeLockByAddress.nextIndexTimeLock
            );
        }
    }

    function getLockedAmount(address _addressLock) public view returns (uint256 amount) {
        return mappingAddressToLock[_addressLock].totalLock;
    }

    function getNextScheduleUnlock(address _addressLock)
        public
        view
        returns (
            uint256 index,
            uint256 unlockTime,
            uint256 amount
        )
    {
        TimeLockByAddress memory timeLockByAddress = mappingAddressToLock[_addressLock];
        return (
            timeLockByAddress.nextIndexTimeLock,
            timeLockByAddress.arrTimeLock[timeLockByAddress.nextIndexTimeLock].unlockTime,
            timeLockByAddress.arrTimeLock[timeLockByAddress.nextIndexTimeLock].amount
        );
    }

    function overwriteScheduleLock(
        address _addressLock,
        uint256[] memory _arrAmount,
        uint256[] memory _arrUnlockTime
    ) public onlyLocker {
        require(_arrAmount.length > 0 && _arrAmount.length == _arrUnlockTime.length, "The parameter passed was wrong");
        require(mappingAddressToLock[_addressLock].totalLock > 0, "Address must in list lock");
        _overwriteTimeLockByAddress(_addressLock, _arrAmount, _arrUnlockTime);
    }

    function getScheduleLock(address _addressLock, uint256 _index) public view returns (uint256, uint256) {
        return (
            mappingAddressToLock[_addressLock].arrTimeLock[_index].amount,
            mappingAddressToLock[_addressLock].arrTimeLock[_index].unlockTime
        );
    }

    function addScheduleLockByAddress(
        address _addressLock,
        uint256[] memory _arrAmount,
        uint256[] memory _arrUnlockTime
    ) public onlyLocker {
        require(_arrAmount.length > 0 && _arrAmount.length == _arrUnlockTime.length, "The parameter passed was wrong");
        require(mappingAddressToLock[_addressLock].totalLock == 0, "Address must not in list lock");
        _overwriteTimeLockByAddress(_addressLock, _arrAmount, _arrUnlockTime);
    }

    function unlockRoseon() public whenNotPaused {
        _unLock(_msgSender());
    }

    function _overwriteTimeLockByAddress(
        address _addressLock,
        uint256[] memory _arrAmount,
        uint256[] memory _arrUnlockTime
    ) internal returns (uint256) {
        uint256 totalLock = 0;
        delete mappingAddressToLock[_addressLock].arrTimeLock;
        for (uint256 i = 0; i < _arrAmount.length; i++) {
            require(_arrUnlockTime[i] > 0, "The timeline must be greater than 0");
            if (i != _arrAmount.length - 1) {
                require(
                    _arrUnlockTime[i + 1] > _arrUnlockTime[i],
                    "The next timeline must be greater than the previous"
                );
            }
            _addScheduleLockByAddress(_addressLock, _arrUnlockTime[i], _arrAmount[i]);
            totalLock += _arrAmount[i];
        }
        _updateTotalLockByAddress(_addressLock, totalLock, 0);
        return totalLock;
    }
}

contract RoseonToken is LockCoin, LGEWhitelisted {
    constructor() LockCoin("Roseon token", "ROSN", 100000000 * 10**18) {}

    function transfer(address _receiver, uint256 _amount) public override returns (bool success) {
        _unLock(_msgSender());
        require(_amount <= getAvailableBalance(_msgSender()), "Balance is insufficient");
        return BEP20.transfer(_receiver, _amount);
    }

    function transferFrom(
        address _from,
        address _receiver,
        uint256 _amount
    ) public override returns (bool) {
        _unLock(_from);
        require(_amount <= getAvailableBalance(_from), "Balance is insufficient");
        return BEP20.transferFrom(_from, _receiver, _amount);
    }

    function getAvailableBalance(address _lockedAddress) public view returns (uint256 amount) {
        uint256 balance = balanceOf(_lockedAddress);
        uint256 lockedAmount = getLockedAmount(_lockedAddress);
        if (balance <= lockedAmount) return 0;
        return balance - lockedAmount;
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override {
        super._beforeTokenTransfer(_from, _to, _amount);
        _applyLGEWhitelist(_from, _to, _amount);
    }
}