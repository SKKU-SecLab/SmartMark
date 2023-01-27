

pragma solidity >=0.6.0 <0.7.0;


library SafeMath {

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}


interface IPowerKeeper {

    function usePower(address master) external returns (uint256);

    function power(address master) external view returns (uint256);

    function totalPower() external view returns (uint256);

    event PowerGained(address indexed master, uint256 amount);
    event PowerUsed(address indexed master, uint256 amount);
}

interface IMilker {

    function bandits(uint256 percent) external returns (uint256, uint256, uint256);

    function sheriffsVaultCommission() external returns (uint256);

    function sheriffsPotDistribution() external returns (uint256);

    function isWhitelisted(address holder) external view returns (bool);

    function getPeriod() external view returns (uint256);

}


contract Milk is Ownable, IMilker {

    using SafeMath for uint256;

    string public constant name = "Cowboy.Finance";
    string public constant symbol = "MILK";
    uint256 public constant decimals = 18;

    uint256 private constant MAX_UINT256 = ~uint256(0);
    uint256 private constant MAX_TOKENS = 15 * 10**6;
    uint256 private constant MAX_SUPPLY = MAX_TOKENS * 10**decimals;
    uint256 private constant TOTAL_UNITS = MAX_UINT256 - (MAX_UINT256 % MAX_SUPPLY);

    uint256 private constant INITIAL_PRODUCTION = 25_000 * 10**decimals;
    uint256 private constant PERIOD_LENGTH = 6 hours;
    uint256 private constant REDUCING_PERIODS = 28;
    uint256 private constant REDUCING_FACTOR = 10;

    address private constant DEV_TEAM_ADDRESS = 0xFFCF83437a1Eb718933f39ebE75aD96335BC1BE4;

    IPowerKeeper private _stableCow;    // COW
    IPowerKeeper private _stableCowLP;  // UniswapV2 Pair COW:WETH
    IPowerKeeper private _stableMilkLP; // UniswapV2 Pair MILK:WETH

    address private _controller;

    mapping(address => uint256) private _balances; // in units
    mapping(address => uint256) private _vaults;   // in units
    mapping(address => mapping (address => uint256)) private _allowances;

    mapping(address => uint256) private _whitelistedBalances; // in units
    mapping(address => bool) private _whitelist;

    uint256 private _startTime = MAX_UINT256;
    uint256 private _distributed;
    uint256 private _totalSupply;

    uint256 private _supplyInBalances;
    uint256 private _supplyWhitelisted;
    uint256 private _supplyInSheriffsPot;
    uint256 private _supplyInSheriffsVault;

    uint256 private _maxBalancesSupply = MAX_SUPPLY;
    uint256 private _maxWhitelistedSupply = MAX_SUPPLY;
    uint256 private _maxSheriffsVaultSupply = MAX_SUPPLY;
    uint256 private _unitsPerTokenInBalances = TOTAL_UNITS.div(_maxBalancesSupply);
    uint256 private _unitsPerTokenWhitelisted = TOTAL_UNITS.div(_maxWhitelistedSupply);
    uint256 private _unitsPerTokenInSheriffsVault = TOTAL_UNITS.div(_maxSheriffsVaultSupply);

    event StartTimeSetUp(uint256 indexed startTime);
    event StableCowSetUp(address indexed stableCow);
    event StableCowLPSetUp(address indexed stableCowLP);
    event StableMilkLPSetUp(address indexed stableMilkLP);
    event ControllerSetUp(address indexed controller);
    event AddedToWhitelist(address indexed holder);
    event RemovedFromWhitelist(address indexed holder);

    event Mint(address indexed to, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Bandits(uint256 percent, uint256 totalAmount, uint256 arrestedAmount, uint256 burntAmount);
    event SheriffsVaultCommission(uint256 amount);
    event SheriffsPotDistribution(uint256 amount);
    event SheriffsVaultDeposit(address indexed holder, uint256 amount);
    event SheriffsVaultWithdraw(address indexed holder, uint256 amount);


    modifier validRecipient(address account) {

        require(account != address(0x0), "Milk: unable to send tokens to zero address");
        require(account != address(this), "Milk: unable to send tokens to the token contract");
        _;
    }

    modifier onlyController() {

        require(_controller == _msgSender(), "Milk: caller is not the controller");
        _;
    }


    constructor() public {
        _whitelist[DEV_TEAM_ADDRESS] = true;
        emit AddedToWhitelist(DEV_TEAM_ADDRESS);
    }

    function setStartTime(uint256 startTime) external onlyOwner {

        _startTime = startTime;
        emit StartTimeSetUp(startTime);
    }

    function setStableCow(address stableCow) external onlyOwner {

        _stableCow = IPowerKeeper(stableCow);
        emit StableCowSetUp(stableCow);
    }

    function setStableCowLP(address stableCowLP) external onlyOwner {

        _stableCowLP = IPowerKeeper(stableCowLP);
        emit StableCowLPSetUp(stableCowLP);
    }

    function setStableMilkLP(address stableMilkLP) external onlyOwner {

        _stableMilkLP = IPowerKeeper(stableMilkLP);
        emit StableMilkLPSetUp(stableMilkLP);
    }

    function setController(address controller) external onlyOwner {

        _controller = controller;
        emit ControllerSetUp(controller);
    }


    function addToWhitelist(address holder) external onlyOwner {

        require(address(_stableCow) != address(0), "Milk: StableV2 contract staking COW tokens is not set up");
        require(!_whitelist[holder], "Milk: already whitelisted");
        require(_stableCow.power(holder) == 0, "Milk: unable to whitelist COW tokens staker");
        _whitelist[holder] = true;
        uint256 tokens = _balances[holder].div(_unitsPerTokenInBalances);
        if (tokens > 0) {
            _whitelistedBalances[holder] = tokens.mul(_unitsPerTokenWhitelisted);
            _balances[holder] = 0;
            _supplyInBalances = _supplyInBalances.sub(tokens);
            _supplyWhitelisted = _supplyWhitelisted.add(tokens);
        }
        emit AddedToWhitelist(holder);
    }

    function removeFromWhitelist(address holder) external onlyOwner {

        require(address(_stableCow) != address(0), "Milk: StableV2 contract staking COW tokens is not set up");
        require(_whitelist[holder], "Milk: not whitelisted");
        _whitelist[holder] = false;
        uint256 tokens = _whitelistedBalances[holder].div(_unitsPerTokenWhitelisted);
        if (tokens > 0) {
            _balances[holder] = tokens.mul(_unitsPerTokenInBalances);
            _whitelistedBalances[holder] = 0;
            _supplyInBalances = _supplyInBalances.add(tokens);
            _supplyWhitelisted = _supplyWhitelisted.sub(tokens);
        }
        emit RemovedFromWhitelist(holder);
    }


    function bandits(uint256 percent) external override onlyController returns (
        uint256 banditsAmount,
        uint256 arrestedAmount,
        uint256 burntAmount
    ) {

        uint256 undistributedAmount = getProductedAmount().sub(_distributed);
        uint256 banditsTotalAmount = _supplyInBalances.mul(percent).div(100);
        uint256 undistributedBanditsTotalAmount = undistributedAmount.mul(percent).div(100);
        uint256 banditsToPotAmount = banditsTotalAmount.mul(90).div(100);
        uint256 undistributedBanditsToPotAmount = undistributedBanditsTotalAmount.mul(90).div(100);
        uint256 banditsBurnAmount = banditsTotalAmount.sub(banditsToPotAmount);
        uint256 undistributedBanditsBurnAmount = undistributedBanditsTotalAmount.sub(undistributedBanditsToPotAmount);

        _totalSupply = _totalSupply.sub(banditsBurnAmount);
        _supplyInSheriffsPot = _supplyInSheriffsPot.add(banditsToPotAmount).add(undistributedBanditsToPotAmount);
        _supplyInBalances = _supplyInBalances.sub(banditsTotalAmount);

        _maxBalancesSupply = _maxBalancesSupply.sub(_maxBalancesSupply.mul(percent).div(100));
        _unitsPerTokenInBalances = TOTAL_UNITS.div(_maxBalancesSupply);

        _distributed = _distributed.add(undistributedBanditsBurnAmount).add(undistributedBanditsToPotAmount);

        banditsAmount = banditsTotalAmount.add(undistributedBanditsTotalAmount);
        arrestedAmount = banditsToPotAmount.add(undistributedBanditsToPotAmount);
        burntAmount = banditsBurnAmount.add(undistributedBanditsBurnAmount);

        emit Bandits(percent, banditsAmount, arrestedAmount, burntAmount);
    }


    function sheriffsVaultCommission() external override onlyController returns (uint256 commission) {

        commission = _supplyInSheriffsVault.div(100);
        _supplyInSheriffsVault = _supplyInSheriffsVault.sub(commission);
        _supplyInSheriffsPot = _supplyInSheriffsPot.add(commission);
        _maxSheriffsVaultSupply = _maxSheriffsVaultSupply.sub(_maxSheriffsVaultSupply.div(100));
        _unitsPerTokenInSheriffsVault = TOTAL_UNITS.div(_maxSheriffsVaultSupply);
        emit SheriffsVaultCommission(commission);
    }


    function sheriffsPotDistribution() external override onlyController returns (uint256 amount) {

        amount = _supplyInSheriffsPot;
        if (amount > 0 && _supplyInBalances > 0) {
            uint256 maxBalancesSupplyDelta = _maxBalancesSupply.mul(amount).div(_supplyInBalances);
            _supplyInBalances = _supplyInBalances.add(amount);
            _supplyInSheriffsPot = 0;
            _maxBalancesSupply = _maxBalancesSupply.add(maxBalancesSupplyDelta);
            _unitsPerTokenInBalances = TOTAL_UNITS.div(_maxBalancesSupply);
        }
        emit SheriffsPotDistribution(amount);
    }


    function putToSheriffsVault(uint256 amount) external {

        address holder = msg.sender;
        require(!_whitelist[holder], "Milk: whitelisted holders cannot use Sheriff's Vault");
        _updateBalance(holder);
        uint256 unitsInBalances = amount.mul(_unitsPerTokenInBalances);
        uint256 unitsInSheriffsVault = amount.mul(_unitsPerTokenInSheriffsVault);
        _balances[holder] = _balances[holder].sub(unitsInBalances);
        _vaults[holder] = _vaults[holder].add(unitsInSheriffsVault);
        _supplyInBalances = _supplyInBalances.sub(amount);
        _supplyInSheriffsVault = _supplyInSheriffsVault.add(amount);
        emit SheriffsVaultDeposit(holder, amount);
    }

    function takeFromSheriffsVault(uint256 amount) external {

        address holder = msg.sender;
        require(!_whitelist[holder], "Milk: whitelisted holders cannot use Sheriff's Vault");
        _updateBalance(holder);
        uint256 unitsInBalances = amount.mul(_unitsPerTokenInBalances);
        uint256 unitsInSheriffsVault = amount.mul(_unitsPerTokenInSheriffsVault);
        _balances[holder] = _balances[holder].add(unitsInBalances);
        _vaults[holder] = _vaults[holder].sub(unitsInSheriffsVault);
        _supplyInBalances = _supplyInBalances.add(amount);
        _supplyInSheriffsVault = _supplyInSheriffsVault.sub(amount);
        emit SheriffsVaultWithdraw(holder, amount);
    }


    function mint(address recipient, uint256 value) public validRecipient(recipient) onlyOwner returns (bool) {

        if (isWhitelisted(recipient)) {
            uint256 wunits = value.mul(_unitsPerTokenWhitelisted);
            _whitelistedBalances[recipient] = _whitelistedBalances[recipient].add(wunits);
            _supplyWhitelisted = _supplyWhitelisted.add(value);
        } else {
            uint256 units = value.mul(_unitsPerTokenInBalances);
            _balances[recipient] = _balances[recipient].add(units);
            _supplyInBalances = _supplyInBalances.add(value);
        }
        _totalSupply = _totalSupply.add(value);
        emit Mint(recipient, value);
        emit Transfer(0x0000000000000000000000000000000000000000, recipient, value);
        return true;
    }


    function transfer(address to, uint256 value) public validRecipient(to) returns (bool) {

        address from = msg.sender;
        _updateBalance(from);
        uint256 units = value.mul(_unitsPerTokenInBalances);
        uint256 wunits = value.mul(_unitsPerTokenWhitelisted);
        if (isWhitelisted(from) && isWhitelisted(to)) {
            _whitelistedBalances[from] = _whitelistedBalances[from].sub(wunits);
            _whitelistedBalances[to] = _whitelistedBalances[to].add(wunits);
        } else if (isWhitelisted(from)) {
            _whitelistedBalances[from] = _whitelistedBalances[from].sub(wunits);
            _balances[to] = _balances[to].add(units);
            _supplyInBalances = _supplyInBalances.add(value);
            _supplyWhitelisted = _supplyWhitelisted.sub(value);
        } else if (isWhitelisted(to)) {
            _balances[from] = _balances[from].sub(units);
            _whitelistedBalances[to] = _whitelistedBalances[to].add(wunits);
            _supplyInBalances = _supplyInBalances.sub(value);
            _supplyWhitelisted = _supplyWhitelisted.add(value);
        } else {
            _balances[from] = _balances[from].sub(units);
            _balances[to] = _balances[to].add(units);
        }
        emit Transfer(from, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public validRecipient(to) returns (bool) {

        _updateBalance(from);
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);
        uint256 units = value.mul(_unitsPerTokenInBalances);
        uint256 wunits = value.mul(_unitsPerTokenWhitelisted);
        if (isWhitelisted(from) && isWhitelisted(to)) {
            _whitelistedBalances[from] = _whitelistedBalances[from].sub(wunits);
            _whitelistedBalances[to] = _whitelistedBalances[to].add(wunits);
        } else if (isWhitelisted(from)) {
            _whitelistedBalances[from] = _whitelistedBalances[from].sub(wunits);
            _balances[to] = _balances[to].add(units);
            _supplyInBalances = _supplyInBalances.add(value);
            _supplyWhitelisted = _supplyWhitelisted.sub(value);
        } else if (isWhitelisted(to)) {
            _balances[from] = _balances[from].sub(units);
            _whitelistedBalances[to] = _whitelistedBalances[to].add(wunits);
            _supplyInBalances = _supplyInBalances.sub(value);
            _supplyWhitelisted = _supplyWhitelisted.add(value);
        } else {
            _balances[from] = _balances[from].sub(units);
            _balances[to] = _balances[to].add(units);
        }
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _allowances[msg.sender][spender] = _allowances[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        uint256 oldValue = _allowances[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowances[msg.sender][spender] = 0;
        } else {
            _allowances[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }


    function isWhitelisted(address holder) public view override returns (bool) {

        return _whitelist[holder];
    }

    function getPeriod() public view override returns (uint256) {

        if (block.timestamp <= _startTime) {
            return 0;
        }
        return block.timestamp.sub(_startTime).div(PERIOD_LENGTH);
    }

    function getPeriodPart() public view returns (uint256) {

        if (block.timestamp <= _startTime) {
            return 0;
        }
        uint256 durationFromPeriodStart = block.timestamp
            .sub(_startTime.add(getPeriod().mul(PERIOD_LENGTH)));
        return durationFromPeriodStart.mul(10**18).div(PERIOD_LENGTH);
    }

    function getProductionAmount() public view returns(uint256) {

        uint256 reducings = getPeriod().div(REDUCING_PERIODS);
        uint256 production = INITIAL_PRODUCTION;
        for (uint256 i = 0; i < reducings; i++) {
            production = production.sub(production.div(REDUCING_FACTOR));
        }
        return production;
    }

    function getProductedAmount() public view returns(uint256) {

        uint256 period = getPeriod();
        uint256 reducings = period.div(REDUCING_PERIODS);
        uint256 productionAmount = INITIAL_PRODUCTION;
        uint256 productedAmount = 0;
        for (uint256 i = 0; i < reducings; i++) {
            productedAmount = productedAmount.add(productionAmount.mul(REDUCING_PERIODS));
            productionAmount = productionAmount.sub(productionAmount.div(REDUCING_FACTOR));
        }
        productedAmount = productedAmount.add(productionAmount.mul(period.sub(reducings.mul(REDUCING_PERIODS))));
        productedAmount = productedAmount.add(productionAmount.mul(getPeriodPart()).div(10**18));
        return productedAmount;
    }

    function getDistributedAmount() public view returns(uint256) {

        return _distributed;
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply.add(getProductedAmount()).sub(_distributed);
    }

    function holdersSupply() public view returns (uint256) {

        return _supplyInBalances;
    }

    function whitelistedSupply() public view returns (uint256) {

        return _supplyWhitelisted;
    }

    function sheriffsPotSupply() public view returns (uint256) {

        return _supplyInSheriffsPot;
    }

    function sheriffsVaultSupply() public view returns (uint256) {

        return _supplyInSheriffsVault;
    }

    function balanceOf(address account) public view returns (uint256) {


        uint256 undistributed = getProductedAmount().sub(_distributed);
        uint256 undistributedCow = undistributed.div(5); // 20%
        uint256 undistributedCowLP = (undistributed.sub(undistributedCow)).div(2); // 40%
        uint256 undistributedMilkLP = (undistributed.sub(undistributedCow)).sub(undistributedCowLP); // 40%

        if (address(_stableCow) != address(0)) {
            (uint256 power, uint256 totalPower) = (_stableCow.power(account), _stableCow.totalPower());
            undistributedCow = totalPower > 0 ? undistributedCow.mul(power).div(totalPower) : 0;
        } else {
            undistributedCow = 0;
        }
        if (address(_stableCowLP) != address(0)) {
            (uint256 power, uint256 totalPower) = (_stableCowLP.power(account), _stableCowLP.totalPower());
            undistributedCowLP = totalPower > 0 ? undistributedCowLP.mul(power).div(totalPower) : 0;
        } else {
            undistributedCowLP = 0;
        }
        if (address(_stableMilkLP) != address(0)) {
            (uint256 power, uint256 totalPower) = (_stableMilkLP.power(account), _stableMilkLP.totalPower());
            undistributedMilkLP = totalPower > 0 ? undistributedMilkLP.mul(power).div(totalPower) : 0;
        } else {
            undistributedMilkLP = 0;
        }

        uint256 devTeamFee = (undistributedCow.add(undistributedCowLP).add(undistributedMilkLP)).div(20);

        undistributed = (undistributedCow.add(undistributedCowLP).add(undistributedMilkLP)).sub(devTeamFee);

        uint256 whitelisted = _whitelistedBalances[account].div(_unitsPerTokenWhitelisted);

        return (_balances[account].div(_unitsPerTokenInBalances)).add(undistributed).add(whitelisted);
    }

    function vaultOf(address account) public view returns (uint256) {

        return _vaults[account].div(_unitsPerTokenInSheriffsVault);
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }


    function _updateBalance(address holder) private {


        uint256 undistributed = getProductedAmount().sub(_distributed);
        uint256 undistributedCow = undistributed.div(5); // 20%
        uint256 undistributedCowLP = (undistributed.sub(undistributedCow)).div(2); // 40%
        uint256 undistributedMilkLP = (undistributed.sub(undistributedCow)).sub(undistributedCowLP); // 40%

        if (address(_stableCow) != address(0)) {
            (uint256 power, uint256 totalPower) = (_stableCow.power(holder), _stableCow.totalPower());
            if (power > 0) {
                power = _stableCow.usePower(holder);
                undistributedCow = totalPower > 0 ? undistributedCow.mul(power).div(totalPower) : 0;
            }
        } else {
            undistributedCow = 0;
        }
        if (address(_stableCowLP) != address(0)) {
            (uint256 power, uint256 totalPower) = (_stableCowLP.power(holder), _stableCowLP.totalPower());
            if (power > 0) {
                power = _stableCowLP.usePower(holder);
                undistributedCowLP = totalPower > 0 ? undistributedCowLP.mul(power).div(totalPower) : 0;
            }
        } else {
            undistributedCowLP = 0;
        }
        if (address(_stableMilkLP) != address(0)) {
            (uint256 power, uint256 totalPower) = (_stableMilkLP.power(holder), _stableMilkLP.totalPower());
            if (power > 0) {
                power = _stableMilkLP.usePower(holder);
                undistributedMilkLP = totalPower > 0 ? undistributedMilkLP.mul(power).div(totalPower) : 0;
            }
        } else {
            undistributedMilkLP = 0;
        }

        uint256 devTeamFee = (undistributedCow.add(undistributedCowLP).add(undistributedMilkLP)).div(20);

        uint256 tokens = undistributedCow.add(undistributedCowLP).add(undistributedMilkLP).sub(devTeamFee);

        _balances[holder] = _balances[holder].add(tokens.mul(_unitsPerTokenInBalances));
        _balances[DEV_TEAM_ADDRESS] = _balances[DEV_TEAM_ADDRESS].add(devTeamFee.mul(_unitsPerTokenWhitelisted));
        _distributed = _distributed.add(tokens).add(devTeamFee);
        _totalSupply = _totalSupply.add(tokens).add(devTeamFee);
        if (isWhitelisted(holder)) {
            _supplyWhitelisted = _supplyWhitelisted.add(tokens);
        } else {
            _supplyInBalances = _supplyInBalances.add(tokens);
        }
        if (isWhitelisted(DEV_TEAM_ADDRESS)) {
            _supplyWhitelisted = _supplyWhitelisted.add(devTeamFee);
        } else {
            _supplyInBalances = _supplyInBalances.add(devTeamFee);
        }
    }
}