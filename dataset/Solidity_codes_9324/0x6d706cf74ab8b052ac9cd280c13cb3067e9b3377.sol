
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

pragma solidity ^0.7.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity ^0.7.0;


abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}// UNLICENSED
pragma solidity 0.7.6;


contract DARTToken is Context, Ownable, ERC20Burnable {
    string public constant NAME = "dART Token";
    string public constant SYMBOL = "dART";
    uint8 public constant DECIMALS = 18;
    uint256 public constant TOTAL_SUPPLY = 142090000 * (10**uint256(DECIMALS));

    address public SeedInvestmentAddr;
    address public PrivateSaleAddr;
    address public StakingRewardsAddr;
    address public LiquidityPoolAddr;
    address public MarketingAddr;
    address public TreasuryAddr;
    address public TeamAllocationAddr;
    address public AdvisorsAddr;
    address public ReserveAddr;

    uint256 public constant SEED_INVESTMENT = 3000000 * (10**uint256(DECIMALS)); // 2.1% for Seed investment
    uint256 public constant PRIVATE_SALE = 15000000 * (10**uint256(DECIMALS)); // 10.6% for Private Sale

    uint256 public constant STAKING_REWARDS = 24500000 * (10**uint256(DECIMALS)); // 17.2% for Staking rewards
    
    uint256 public constant LIQUIDITY_POOL = 9000000 * (10**uint256(DECIMALS)); // 6.3% for Liquidity pool

    uint256 public constant MARKETING = 14000000 * (10**uint256(DECIMALS)); // 9.9% for Marketing/Listings
    uint256 public constant TREASURY = 19600000 * (10**uint256(DECIMALS)); // 13.8% for Treasury

    uint256 public constant TEAM_ALLOCATION = 17000000 * (10**uint256(DECIMALS)); // 12% for Team allocation
    uint256 public constant ADVISORS = 5000000 * (10**uint256(DECIMALS)); // 3.5% for Advisors

    uint256 public constant RESERVE = 34990000 * (10**uint256(DECIMALS)); // 24.6% for Bridge consumption

    bool private _isDistributionComplete = false;

    constructor()
        ERC20(NAME, SYMBOL)
    {
        _mint(address(this), TOTAL_SUPPLY);
    }

    function setDistributionTeamsAddresses(
        address _SeedInvestmentAddr,
        address _PrivateSaleAddr,
        address _StakingRewardsAddr,
        address _LiquidityPoolAddr,
        address _MarketingAddr,
        address _TreasuryAddr,
        address _TeamAllocationAddr,
        address _AdvisorsAddr,
        address _ReserveAddr
    ) external onlyOwner {
        require(!_isDistributionComplete, "Already distributed");

        SeedInvestmentAddr = _SeedInvestmentAddr;
        PrivateSaleAddr = _PrivateSaleAddr;
        StakingRewardsAddr = _StakingRewardsAddr;
        LiquidityPoolAddr = _LiquidityPoolAddr;
        MarketingAddr = _MarketingAddr;
        TreasuryAddr = _TreasuryAddr;
        TeamAllocationAddr = _TeamAllocationAddr;
        AdvisorsAddr = _AdvisorsAddr;
        ReserveAddr = _ReserveAddr;
    }

    function distributeTokens() external onlyOwner {
        require(!_isDistributionComplete, "Already distributed");

        _transfer(address(this), SeedInvestmentAddr, SEED_INVESTMENT);
        _transfer(address(this), PrivateSaleAddr, PRIVATE_SALE);
        _transfer(address(this), StakingRewardsAddr, STAKING_REWARDS);
        _transfer(address(this), LiquidityPoolAddr, LIQUIDITY_POOL);
        _transfer(address(this), MarketingAddr, MARKETING);
        _transfer(address(this), TreasuryAddr, TREASURY);
        _transfer(address(this), TeamAllocationAddr, TEAM_ALLOCATION);
        _transfer(address(this), AdvisorsAddr, ADVISORS);
        _transfer(address(this), ReserveAddr, RESERVE);

        _isDistributionComplete = true;
    }
}// UNLICENSED
pragma solidity 0.7.6;


contract DARTVesting is Context, Ownable {
    using SafeMath for uint256;

    struct VestingSchedule {
        uint256 totalAmount; // Total amount of tokens to be vested.
        uint256 amountWithdrawn; // The amount that has been withdrawn.
    }

    mapping(address => VestingSchedule) public recipients;
    address[] recipientAddresses;

    uint256 public startTime;
    bool public isStartTimeSet;
    uint256 public withdrawInterval = 1 days; // Amount of time in seconds between withdrawal periods.
    uint256 public releasePeriods; // Number of periods from start release until done.
    uint256 public lockPeriods; // Number of periods before start release.

    uint256 public unlockTGEPercent;

    uint256 public totalAmount; // Total amount of tokens to be vested.
    uint256 public unallocatedAmount; // The amount of tokens that are not allocated yet.

    bool initialDistributed = false;

    DARTToken public dARTToken;

    event VestingScheduleRegistered(
        address[] registeredAddresses,
        uint256[] allocations
    );
    event Withdraw(address registeredAddress, uint256 amountWithdrawn);
    event StartTimeSet(uint256 startTime);

    constructor(
        DARTToken _dARTToken,
        uint256 _totalAmount,
        uint256 _releasePeriods,
        uint256 _lockPeriods,
        uint256 _unlockTGEPercent
    ) {
        require(_totalAmount > 0, "Total amount should not be zero");
        require(_releasePeriods > 0, "Release periods should not be zero");

        dARTToken = _dARTToken;

        totalAmount = _totalAmount;
        unallocatedAmount = _totalAmount;
        releasePeriods = _releasePeriods;
        lockPeriods = _lockPeriods;
        unlockTGEPercent = _unlockTGEPercent;
    }

    function addRecipients(address[] memory _newRecipients, uint256[] memory _allocations)
        external
        onlyOwner
    {
        require(!isStartTimeSet || startTime > block.timestamp, "Start time is passed");
        require(_newRecipients.length == _allocations.length, "Recipients length should match allocations length");

        uint256 length = _allocations.length;

        for (uint256 i = 0; i < length; i ++) {
            require(_newRecipients[i] != address(0), "Recipient cannot be zero address");
            require(recipients[_newRecipients[i]].totalAmount == 0, "Recipient already added");
            require(_allocations[i] > 0 && _allocations[i] <= unallocatedAmount, "Allocation cannot be zero and cannot override unallocated amount");

            recipientAddresses.push(_newRecipients[i]);

            recipients[_newRecipients[i]] = VestingSchedule({
                totalAmount: _allocations[i],
                amountWithdrawn: 0
            });

            unallocatedAmount = unallocatedAmount.sub(_allocations[i]);
        }

        emit VestingScheduleRegistered(_newRecipients, _allocations);
    }

    function setStartTime(uint256 _newStartTime) external onlyOwner {
        require(!isStartTimeSet || startTime > block.timestamp, "Start time already passed");
        require(_newStartTime > block.timestamp, "Start time should be later than now");

        startTime = _newStartTime;
        isStartTimeSet = true;

        emit StartTimeSet(_newStartTime);
    }

    function vested(address beneficiary)
        public
        view
        virtual
        returns (uint256 _amountVested)
    {
        VestingSchedule memory _vestingSchedule = recipients[beneficiary];
        if (
            !isStartTimeSet ||
            (_vestingSchedule.totalAmount == 0) ||
            (lockPeriods == 0 && releasePeriods == 0) ||
            (block.timestamp < startTime)
        ) {
            return 0;
        }

        uint256 period =
            block.timestamp.sub(startTime).div(withdrawInterval);
        if (period <= lockPeriods) {
            return 0;
        }
        if (period >= lockPeriods.add(releasePeriods)) {
            return _vestingSchedule.totalAmount;
        }

        uint256 vestedAmount = _vestingSchedule.totalAmount.mul(period.sub(lockPeriods)).div(releasePeriods);
        return vestedAmount;
    }

    function withdrawable(address beneficiary)
        public
        view
        returns (uint256 amount)
    {
        return vested(beneficiary).sub(recipients[beneficiary].amountWithdrawn);
    }

    function withdraw() external {
        VestingSchedule storage vestingSchedule = recipients[_msgSender()];
        require(vestingSchedule.totalAmount > 0, "No Tokens to withdraw");

        uint256 _vested = vested(msg.sender);
        uint256 _withdrawable = withdrawable(msg.sender);
        vestingSchedule.amountWithdrawn = _vested;

        if (_withdrawable > 0) {
            require(dARTToken.transfer(_msgSender(), _withdrawable), "Transfer failed for some reason");
            emit Withdraw(_msgSender(), _withdrawable);
        }
    }

    function distributeInitials() external onlyOwner() {
        require(!initialDistributed, "Already distributed");

        initialDistributed = true;

        uint256 recipientLength = recipientAddresses.length;
        
        for (uint i = 0; i < recipientLength; i ++) {
            address recipientAddr = recipientAddresses[i];
            if (recipients[recipientAddr].totalAmount > 0) {
                uint256 amount = recipients[recipientAddr].totalAmount.mul(unlockTGEPercent).div(100);
                recipients[recipientAddr].totalAmount = recipients[recipientAddr].totalAmount.sub(amount);
                dARTToken.transfer(recipientAddr, amount);
            }
        }
    }
}// UNLICENSED
pragma solidity 0.7.6;


contract TreasuryVesting is DARTVesting {
    uint256 public constant TOTAL_AMOUNT = 19600000 * (10**18);
    uint256 public constant RELEASE_PERIODS = 270;
    uint256 public constant LOCK_PERIODS = 0;
    uint256 public constant UNLOCK_TGE_PERCENT = 7;

    constructor(DARTToken _dARTToken)
        DARTVesting(
            _dARTToken,
            TOTAL_AMOUNT,
            RELEASE_PERIODS,
            LOCK_PERIODS,
            UNLOCK_TGE_PERCENT
        )
    {}
}