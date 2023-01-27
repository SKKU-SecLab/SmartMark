pragma solidity ^0.8.0;

interface IERC677Receiver {

    function onTokenTransfer(
        address sender,
        uint256 value,
        bytes memory data
    ) external;

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

pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}// MIT
pragma solidity ^0.8.0;


interface IERC677 is IERC20 {
    function transferAndCall(
        address recipient,
        uint256 amount,
        bytes memory data
    ) external returns (bool success);

    event TransferAndCall(
        address indexed from,
        address indexed to,
        uint256 value,
        bytes data
    );
}// MIT
pragma solidity ^0.8.0;


abstract contract ERC677 is IERC677, ERC20 {
    function transferAndCall(
        address recipient,
        uint256 amount,
        bytes memory data
    ) public virtual override returns (bool success) {
        super.transfer(recipient, amount);

        emit TransferAndCall(msg.sender, recipient, amount, data);

        if (isContract(recipient)) {
            IERC677Receiver receiver = IERC677Receiver(recipient);
            receiver.onTokenTransfer(msg.sender, amount, data);
        }

        return true;
    }

    function isContract(address addr) private view returns (bool hasCode) {
        uint256 length;
        assembly {
            length := extcodesize(addr)
        }
        return length > 0;
    }
}// MIT
pragma solidity ^0.8.2;



contract CrunchToken is ERC677, ERC20Burnable {
    constructor() ERC20("Crunch Token", "CRUNCH") {
        _mint(msg.sender, 10765163 * 10**decimals());
    }
}// MIT
pragma solidity ^0.8.2;



contract HasCrunchParent is Ownable {
    event ParentUpdated(address from, address to);

    CrunchToken public crunch;

    constructor(CrunchToken _crunch) {
        crunch = _crunch;

        emit ParentUpdated(address(0), address(crunch));
    }

    modifier onlyCrunchParent() {
        require(
            address(crunch) == _msgSender(),
            "HasCrunchParent: caller is not the crunch token"
        );
        _;
    }

    function setCrunch(CrunchToken _crunch) public onlyOwner {
        require(address(crunch) != address(_crunch), "useless to update to same crunch token");

        emit ParentUpdated(address(crunch), address(_crunch));

        crunch = _crunch;
    }
}// MIT
pragma solidity ^0.8.2;


contract CrunchStaking is HasCrunchParent, IERC677Receiver {
    event Withdrawed(
        address indexed to,
        uint256 reward,
        uint256 staked,
        uint256 totalAmount
    );

    event EmergencyWithdrawed(address indexed to, uint256 staked);
    event Deposited(address indexed sender, uint256 amount);
    event RewardPerDayUpdated(uint256 rewardPerDay, uint256 totalDebt);

    struct Holder {
        uint256 index;
        uint256 start;
        uint256 totalStaked;
        uint256 rewardDebt;
        Stake[] stakes;
    }

    struct Stake {
        uint256 amount;
        uint256 start;
    }

    uint256 public rewardPerDay;

    address[] public addresses;

    mapping(address => Holder) public holders;

    uint256 public totalStaked;

    constructor(CrunchToken crunch, uint256 _rewardPerDay)
        HasCrunchParent(crunch)
    {
        rewardPerDay = _rewardPerDay;
    }

    function deposit(uint256 amount) external {
        crunch.transferFrom(_msgSender(), address(this), amount);

        _deposit(_msgSender(), amount);
    }

    function withdraw() external {
        _withdraw(_msgSender());
    }

    function reserve() public view returns (uint256) {
        uint256 balance = contractBalance();

        if (totalStaked > balance) {
            revert(
                "Staking: the balance has less CRUNCH than the total staked"
            );
        }

        return balance - totalStaked;
    }

    function isCallerStaking() external view returns (bool) {
        return isStaking(_msgSender());
    }

    function isStaking(address addr) public view returns (bool) {
        return _isStaking(holders[addr]);
    }

    function contractBalance() public view returns (uint256) {
        return crunch.balanceOf(address(this));
    }

    function totalStakedOf(address addr) external view returns (uint256) {
        return holders[addr].totalStaked;
    }

    function totalReward() public view returns (uint256 total) {
        uint256 length = addresses.length;
        for (uint256 index = 0; index < length; index++) {
            address addr = addresses[index];

            total += totalRewardOf(addr);
        }
    }

    function totalRewardOf(address addr) public view returns (uint256) {
        Holder storage holder = holders[addr];

        return _computeRewardOf(holder);
    }

    function totalRewardDebt() external view returns (uint256 total) {
        uint256 length = addresses.length;
        for (uint256 index = 0; index < length; index++) {
            address addr = addresses[index];

            total += rewardDebtOf(addr);
        }
    }

    function rewardDebtOf(address addr) public view returns (uint256) {
        return holders[addr].rewardDebt;
    }

    function isReserveSufficient() external view returns (bool) {
        return _isReserveSufficient(totalReward());
    }

    function isReserveSufficientFor(address addr) external view returns (bool) {
        return _isReserveSufficient(totalRewardOf(addr));
    }

    function stakerCount() external view returns (uint256) {
        return addresses.length;
    }

    function stakesOf(address addr) external view returns (Stake[] memory) {
        return holders[addr].stakes;
    }

    function stakesCountOf(address addr) external view returns (uint256) {
        return holders[addr].stakes.length;
    }

    function forceWithdraw(address addr) external onlyOwner {
        _withdraw(addr);
    }

    function emergencyWithdraw() external {
        _emergencyWithdraw(_msgSender());
    }

    function forceEmergencyWithdraw(address addr) external onlyOwner {
        _emergencyWithdraw(addr);
    }

    function setRewardPerDay(uint256 to) external onlyOwner {
        require(
            rewardPerDay != to,
            "Staking: reward per day value must be different"
        );
        require(
            to <= 15000,
            "Staking: reward per day must be below 15000/1M token/day"
        );

        uint256 debt = _updateDebts();
        rewardPerDay = to;

        emit RewardPerDayUpdated(rewardPerDay, debt);
    }

    function emptyReserve() external onlyOwner {
        uint256 amount = reserve();

        require(amount != 0, "Staking: reserve is empty");

        crunch.transfer(owner(), amount);
    }

    function destroy() external onlyOwner {
        uint256 usable = reserve();

        uint256 length = addresses.length;
        for (uint256 index = 0; index < length; index++) {
            address addr = addresses[index];
            Holder storage holder = holders[addr];

            uint256 reward = _computeRewardOf(holder);

            require(usable >= reward, "Staking: reserve does not have enough");

            uint256 total = holder.totalStaked + reward;
            crunch.transfer(addr, total);
        }

        _transferRemainingAndSelfDestruct();
    }

    function emergencyDestroy() external onlyOwner {
        uint256 length = addresses.length;
        for (uint256 index = 0; index < length; index++) {
            address addr = addresses[index];
            Holder storage holder = holders[addr];

            crunch.transfer(addr, holder.totalStaked);
        }

        _transferRemainingAndSelfDestruct();
    }

    function criticalDestroy() external onlyOwner {
        _transferRemainingAndSelfDestruct();
    }

    function onTokenTransfer(
        address sender,
        uint256 value,
        bytes memory data
    ) external override onlyCrunchParent {
        data; /* silence unused */

        _deposit(sender, value);
    }

    function _deposit(address from, uint256 amount) internal {
        require(amount != 0, "cannot deposit zero");

        Holder storage holder = holders[from];

        if (!_isStaking(holder)) {
            holder.start = block.timestamp;
            holder.index = addresses.length;
            addresses.push(from);
        }

        holder.totalStaked += amount;
        holder.stakes.push(Stake({amount: amount, start: block.timestamp}));

        totalStaked += amount;

        emit Deposited(from, amount);
    }

    function _withdraw(address addr) internal {
        Holder storage holder = holders[addr];

        require(_isStaking(holder), "Staking: no stakes");

        uint256 reward = _computeRewardOf(holder);

        require(
            _isReserveSufficient(reward),
            "Staking: the reserve does not have enough token"
        );

        uint256 staked = holder.totalStaked;
        uint256 total = staked + reward;
        crunch.transfer(addr, total);

        totalStaked -= staked;

        _deleteAddress(holder.index);
        delete holders[addr];

        emit Withdrawed(addr, reward, staked, total);
    }

    function _emergencyWithdraw(address addr) internal {
        Holder storage holder = holders[addr];

        require(_isStaking(holder), "Staking: no stakes");

        uint256 staked = holder.totalStaked;
        crunch.transfer(addr, staked);

        totalStaked -= staked;

        _deleteAddress(holder.index);
        delete holders[addr];

        emit EmergencyWithdrawed(addr, staked);
    }

    function _isReserveSufficient(uint256 reward) private view returns (bool) {
        return reserve() >= reward;
    }

    function _isStaking(Holder storage holder) internal view returns (bool) {
        return holder.stakes.length != 0;
    }

    function _updateDebts() internal returns (uint256 total) {
        uint256 length = addresses.length;
        for (uint256 index = 0; index < length; index++) {
            address addr = addresses[index];
            Holder storage holder = holders[addr];

            uint256 debt = _updateDebtsOf(holder);

            holder.rewardDebt += debt;

            total += debt;
        }
    }

    function _updateDebtsOf(Holder storage holder)
        internal
        returns (uint256 total)
    {
        uint256 length = holder.stakes.length;
        for (uint256 index = 0; index < length; index++) {
            Stake storage stake = holder.stakes[index];

            total += _computeStakeReward(stake);

            stake.start = block.timestamp;
        }
    }

    function _computeTotalReward() internal view returns (uint256 total) {
        uint256 length = addresses.length;
        for (uint256 index = 0; index < length; index++) {
            address addr = addresses[index];
            Holder storage holder = holders[addr];

            total += _computeRewardOf(holder);
        }
    }

    function _computeRewardOf(Holder storage holder)
        internal
        view
        returns (uint256 total)
    {
        uint256 length = holder.stakes.length;
        for (uint256 index = 0; index < length; index++) {
            Stake storage stake = holder.stakes[index];

            total += _computeStakeReward(stake);
        }

        total += holder.rewardDebt;
    }

    function _computeStakeReward(Stake storage stake)
        internal
        view
        returns (uint256)
    {
        uint256 numberOfDays = ((block.timestamp - stake.start) / 1 days);

        return (stake.amount * numberOfDays * rewardPerDay) / 1_000_000;
    }

    function _deleteAddress(uint256 index) internal {
        uint256 length = addresses.length;
        require(
            length != 0,
            "Staking: cannot remove address if array length is zero"
        );

        uint256 last = length - 1;
        if (last != index) {
            address addr = addresses[last];
            addresses[index] = addr;
            holders[addr].index = index;
        }

        addresses.pop();
    }

    function _transferRemainingAndSelfDestruct() internal {
        uint256 remaining = contractBalance();
        if (remaining != 0) {
            crunch.transfer(owner(), remaining);
        }

        selfdestruct(payable(owner()));
    }
}