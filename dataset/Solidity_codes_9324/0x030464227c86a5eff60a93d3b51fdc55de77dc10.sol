
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
}

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => mapping(uint256 => uint256)) private _vote;

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
        require(currentAllowance >= amount, "BINU: transfer amount exceeds allowance");
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
        require(currentAllowance >= subtractedValue, "BINU: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "BINU: transfer from the zero address");
        require(recipient != address(0), "BINU: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BINU: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "BINU: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "BINU: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BINU: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "BINU: approve from the zero address");
        require(spender != address(0), "BINU: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

pragma solidity ^0.8.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

pragma solidity ^0.8.0;


library Arrays {
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}

pragma solidity ^0.8.0;

library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

pragma solidity ^0.8.0;



abstract contract ERC20Snapshot is ERC20 {

    using Arrays for uint256[];
    using Counters for Counters.Counter;

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping (address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    Counters.Counter private _currentSnapshotId;

    event Snapshot(uint256 id);

    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }

    function _getCurrentSnapshotId() internal view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }

    function balanceOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    function totalSupplyAt(uint256 snapshotId) public view virtual returns(uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
      super._beforeTokenTransfer(from, to, amount);

      if (from == address(0)) {
        _updateAccountSnapshot(to);
        _updateTotalSupplySnapshot();
      } else if (to == address(0)) {
        _updateAccountSnapshot(from);
        _updateTotalSupplySnapshot();
      } else {
        _updateAccountSnapshot(from);
        _updateAccountSnapshot(to);
      }
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private view returns (bool, uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _getCurrentSnapshotId(), "ERC20Snapshot: nonexistent id");


        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity 0.8.4;

interface IWERC20 is IERC20 {
    event _deposit(address user, uint256 amount);

    event withdrawal(address user, uint256 amount);

    function tokenContract() external view returns (IERC20);

    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;
}
pragma solidity 0.8.4;

interface ILockableERC20 is IWERC20 {
    struct _lock {
        uint256 amount;
        uint256 endDate;
    }

    event unlock(address user, uint256 amount);

    function lock(address user) external view returns (_lock memory);

    function lockLength() external view returns (uint256);
}
pragma solidity 0.8.4;

interface IRiskFreeBetting {
    event betCreated(
        uint256 index,
        string metadataURI,
        uint256 reward,
        uint256 end
    );

    event betFinalized(uint256 index, uint256 choice);

    event _bet(uint256 index, uint256 amount, address sender, uint256 choice);

    event rewardCollected(address user, uint256 index, uint256 rewardAmount);

    struct bet__ {
        uint256 totalReward;
        uint256 choices;
        uint256 end;
        uint256 winningChoice;
        string metadataURI;
    }

    struct _bet_ {
        uint256 choice;
        uint256 amount;
    }

    function betOf(address user, uint256 index)
        external
        view
        returns (_bet_ memory);

    function bets() external view returns (bet__[] memory);

    function betByIndex(uint256 index) external view returns (bet__ memory);

    function createBet(
        string memory metadataURI,
        uint256 end,
        uint256 choices
    ) external payable;

    function bet(
        uint256 index,
        uint256 amount,
        uint256 __bet
    ) external;

    function unclaimedReward(address user, uint256 index)
        external
        view
        returns (uint256);

    function claimReward(uint256 index) external;

    function finalizeBet(uint256 index, uint256 winningChoice) external;

     function totalBetted(uint256 index, uint256 choice) external view returns (uint256);
}
pragma solidity ^0.8.4;

contract bettingInu is
    IRiskFreeBetting,
    ERC20("Leglock", "LEG"),
    ILockableERC20,
    ERC20Snapshot,
    Ownable
{
    modifier exists(uint256 index) {
        require(
            index < _bets.length && index != 0,
            "LEG: That bet does not exist"
        );
        _;
    }

    bet__[] private _bets;
    IERC20 private _tokenContract;
    uint256 private _lockLength;
    mapping(address => _lock) private _locks;
    mapping(address => mapping(uint256 => _bet_)) private bets_;
    mapping(uint256 => mapping(uint256 => uint256)) private _totalBetted;

    constructor(IERC20 __tokenContract) {
        _tokenContract = __tokenContract;
        _lockLength = 600;
        bet__ memory bet_;
        _bets.push(bet_);
    }

    function tokenContract() external view override returns (IERC20) {
        return _tokenContract;
    }

    function lockLength() external view override returns (uint256) {
        return _lockLength;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function bets() external view override returns (bet__[] memory) {
        return _bets;
    }

    function totalBetted(uint256 index, uint256 choice)
        external
        view
        override
        returns (uint256)
    {
        require(
            choice <= _bets[index].choices && choice != 0,
            "LEG: That is not a valid bet"
        );
        return _totalBetted[index][choice];
    }

    function betByIndex(uint256 index)
        external
        view
        override
        returns (bet__ memory)
    {
        return _bets[index];
    }

    function lock(address user) external view override returns (_lock memory) {
        return _locks[user];
    }

    function betOf(address user, uint256 index)
        external
        view
        override
        returns (_bet_ memory)
    {
        return bets_[user][index];
    }

    function checkForUnlock(address user) internal {
        _lock memory lock_ = _locks[user];
        if (lock_.endDate <= block.timestamp && lock_.endDate != 0) {
            delete _locks[user];
            emit unlock(user, lock_.amount);
            return;
        }
    }

    function checkForLock(address user, uint256 amount) internal {
        checkForUnlock(user);
        if (_locks[user].amount != 0) {
            require(
                balanceOf(user) - _locks[user].amount >= amount,
                "LEG: You can only transfer unlocked or available LEG"
            );
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Snapshot) {
        checkForLock(from, amount);
        super._beforeTokenTransfer(from, to, amount);
    }

    function createBet(
        string memory metadataURI,
        uint256 end,
        uint256 choices
    ) external payable override onlyOwner {
        uint256 index = _bets.length;
        _snapshot();
        uint256 _end = block.timestamp + end;
        bet__ memory __bet;
        __bet.totalReward = msg.value;
        __bet.metadataURI = metadataURI;
        __bet.end = _end;
        __bet.choices = choices;
        _bets.push(__bet);
        emit betCreated(index, metadataURI, msg.value, _end);
    }

    function bet(
        uint256 index,
        uint256 amount,
        uint256 __bet
    ) external override exists(index) {
        address sender = _msgSender();
        bet__ memory bet_ = _bets[index];
        _bet_ memory amountAndChoice = bets_[sender][index];
        require(
            block.timestamp < bet_.end,
            "LEG: The betting period has ended"
        );
        require(
            __bet <= bet_.choices && __bet != 0,
            "LEG: That is not a valid bet"
        );
        require(
            balanceOfAt(sender, index) - amountAndChoice.amount >= amount,
            "LEG: You do not have enough LEG"
        );
        if (
            __bet != amountAndChoice.choice && amountAndChoice.choice != 0
        ) {
            _totalBetted[index][amountAndChoice.choice] -= amountAndChoice.amount;
            _totalBetted[index][__bet] += (amountAndChoice.amount + amount);
        } else {
            _totalBetted[index][__bet] += amount;
        }
        bets_[sender][index].amount += amount;
        bets_[sender][index].choice = __bet;
        emit _bet(index, amount, sender, __bet);
    }

    function deposit(uint256 amount) external override {
        address sender = _msgSender();
        checkForUnlock(sender);
        _tokenContract.transferFrom(sender, address(this), amount);
        _locks[sender] = _lock(
            _locks[sender].amount + amount,
            (block.timestamp + _lockLength)
        );
        _mint(sender, amount);
        emit _deposit(sender, amount);
    }

    function withdraw(uint256 amount) external override {
        address sender = _msgSender();
        _burn(sender, amount);
        _tokenContract.transfer(sender, amount);
        emit withdrawal(sender, amount);
    }

    function unclaimedReward(address user, uint256 index)
        public
        view
        override
        exists(index)
        returns (uint256)
    {
        bet__ memory bet_ = _bets[index];
        require(
            block.timestamp >= bet_.end,
            "LEG: The betting period has not ended"
        );
        require(
            bets_[user][index].amount != 0,
            "LEG: You have not betted on that or you have already collected the reward"
        );
        require(
            bet_.winningChoice != 0,
            "LEG: Please wait until the results of this bet have been published"
        );
        require(
            bet_.winningChoice == bets_[user][index].choice,
            "LEG: You chose the wrong choice"
        );
        return
            (bet_.totalReward * bets_[user][index].amount) /
            _totalBetted[index][bet_.winningChoice];
    }

    function claimReward(uint256 index) external override exists(index) {
        address sender = _msgSender();
        uint256 amountToReward = unclaimedReward(sender, index);
        delete bets_[sender][index];
        payable(sender).transfer(amountToReward);
        emit rewardCollected(sender, index, amountToReward);
    }

    function finalizeBet(uint256 index, uint256 winningChoice)
        external
        override
        onlyOwner
        exists(index)
    {
        require(
            _bets[index].end <= block.timestamp,
            "LEG: This bet has not ended yet"
        );
        require(
            winningChoice <= _bets[index].choices,
            "LEG: That is not a valid winning bet"
        );
        require(
            _bets[index].winningChoice == 0,
            "LEG: You have already finalized this bet"
        );
        _bets[index].winningChoice = winningChoice;
        emit betFinalized(index, winningChoice);
    }

    function setLockLength(uint256 newLockLength) external onlyOwner {
        _lockLength = newLockLength;
    }

    function setTokenContract(IERC20 newContract) external onlyOwner {
        _tokenContract = newContract;
    }
}
