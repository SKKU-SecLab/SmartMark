
pragma solidity ^0.6.6;



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
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

}
contract BIOPToken is ERC20 {
    using SafeMath for uint256;
    address public binaryOptions = 0x0000000000000000000000000000000000000000;
    address public gov;
    address public owner;
    uint256 public earlyClaimsAvailable = 450000000000000000000000000000;
    uint256 public totalClaimsAvailable = 300000000000000000000000000000;
    bool public earlyClaims = true;
    bool public binaryOptionsSet = false;

    constructor(string memory name_, string memory symbol_) public ERC20(name_, symbol_) {
      owner = msg.sender;
    }
    
    modifier onlyBinaryOptions() {
        require(binaryOptions == msg.sender, "Ownable: caller is not the Binary Options Contract");
        _;
    }
    modifier onlyOwner() {
        require(binaryOptions == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function updateEarlyClaim(uint256 amount) external onlyBinaryOptions {
        require(totalClaimsAvailable.sub(amount) >= 0, "insufficent claims available");
        require (earlyClaims, "Launch has closed");
        
        earlyClaimsAvailable = earlyClaimsAvailable.sub(amount);
        _mint(tx.origin, amount);
        if (earlyClaimsAvailable <= 0) {
            earlyClaims = false;
        }
    }

     function updateClaim( uint256 amount) external onlyBinaryOptions {
        require(totalClaimsAvailable.sub(amount) >= 0, "insufficent claims available");
        totalClaimsAvailable.sub(amount);
        _mint(tx.origin, amount);
    }

    function setupBinaryOptions(address payable options_) external {
        require(binaryOptionsSet != true, "binary options is already set");
        binaryOptions = options_;
    }

    function setupGovernance(address payable gov_) external onlyOwner {
        _mint(owner, 100000000000000000000000000000);
        _mint(gov_, 450000000000000000000000000000);
        owner = 0x0000000000000000000000000000000000000000;
    }
}

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
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

}



interface IRC {
    function rate(uint256 amount, uint256 maxAvailable) external view returns (uint256);

}

contract RateCalc is IRC {
    using SafeMath for uint256;
    function rate(uint256 amount, uint256 maxAvailable) external view override returns (uint256)  {
        require(amount <= maxAvailable, "greater then pool funds available");
        uint256 oneTenth = amount.div(10);
        uint256 halfMax = maxAvailable.div(2);
        if (amount > halfMax) {
            return amount.mul(2).add(oneTenth).add(oneTenth);
        } else {
            if(oneTenth > 0) {
                return amount.mul(2).sub(oneTenth);
            } else {
                uint256 oneThird = amount.div(4);
                require(oneThird > 0, "invalid bet amount");
                return amount.mul(2).sub(oneThird);
            }
        }
        
    }
}



contract BinaryOptions is ERC20 {
    using SafeMath for uint256;
    address payable devFund;
    address payable owner;
    address public biop;
    address public rcAddress;//address of current rate calculators
    mapping(address=>uint256) public nextWithdraw;
    mapping(address=>bool) public enabledPairs;
    uint256 public minTime;
    uint256 public maxTime;
    address public defaultPair;
    uint256 public lockedAmount;
    uint256 public exerciserFee = 50;//in tenth percent
    uint256 public expirerFee = 50;//in tenth percent
    uint256 public devFundBetFee = 2;//tenth of percent
    uint256 public poolLockSeconds = 2 days;
    uint256 public contractCreated;
    uint256 public launchEnd;
    bool public open = true;
    Option[] public options;
    
    uint256 aStakeReward = 120000000000000000000;
    uint256 bStakeReward = 60000000000000000000;
    uint256 betReward = 40000000000000000000;
    uint256 exerciseReward = 2000000000000000000;


    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }


    enum OptionType {Put, Call}
    enum State {Active, Exercised, Expired}
    struct Option {
        State state;
        address payable holder;
        uint256 strikePrice;
        uint256 purchaseValue;
        uint256 lockedValue;//purchaseAmount+possible reward for correct bet
        uint256 expiration;
        OptionType optionType;
        address priceProvider;
    }

     event Create(
        uint256 indexed id,
        address payable account,
        uint256 strikePrice,
        uint256 lockedValue,
        OptionType direction
    );
    event Payout(uint256 poolLost, address winner);
    event Exercise(uint256 indexed id);
    event Expire(uint256 indexed id);


    function getMaxAvailable() public view returns(uint256) {
        uint256 balance = address(this).balance;
        if (balance > lockedAmount) {
            return balance.sub(lockedAmount);
        } else {
            return 0;
        }
    }

    constructor(string memory name_, string memory symbol_, address pp_, address biop_, address rateCalc_) public ERC20(name_, symbol_){
        devFund = msg.sender;
        owner = msg.sender;
        biop = biop_;
        rcAddress = rateCalc_;
        lockedAmount = 0;
        contractCreated = block.timestamp;
        launchEnd = block.timestamp+28 days;
        enabledPairs[pp_] = true; //default pair ETH/USD
        defaultPair = pp_;
        minTime = 900;//15 minutes
        maxTime = 60 minutes;
    }

    function defaultPriceProvider() public view returns (address) {
        return defaultPair;
    }


    function setRateCalcAddress(address newRC_) external onlyOwner {
        rcAddress = newRC_; 
    }

    function addPP(address newPP_) external onlyOwner {
        enabledPairs[newPP_] = true; 
    }

   

    function removePP(address oldPP_) external onlyOwner {
        enabledPairs[oldPP_] = false;
    }

    function setMaxTime(uint256 newMax_) external onlyOwner {
        maxTime = newMax_;
    }

    function setMinTime(uint256 newMin_) external onlyOwner {
        minTime = newMin_;
    }

    function thisAddress() public view returns (address){
        return address(this);
    }

    function updateExerciserFee(uint256 exerciserFee_) external onlyOwner {
        require(exerciserFee_ > 1 && exerciserFee_ < 500, "invalid fee");
        exerciserFee = exerciserFee_;
    }

    function updateExpirerFee(uint256 expirerFee_) external onlyOwner {
        require(expirerFee_ > 1 && expirerFee_ < 50, "invalid fee");
        expirerFee = expirerFee_;
    }

    function updateDevFundBetFee(uint256 devFundBetFee_) external onlyOwner {
        require(devFundBetFee_ >= 0 && devFundBetFee_ < 50, "invalid fee");
        devFundBetFee = devFundBetFee_;
    }

    function updatePoolLockSeconds(uint256 newLockSeconds_) external onlyOwner {
        require(newLockSeconds_ >= 0 && newLockSeconds_ < 14 days, "invalid fee");
        poolLockSeconds = newLockSeconds_;
    }

    function transferOwner(address payable newOwner_) external onlyOwner {
        owner = newOwner_;
    }
    
    function transferDevFund(address payable newDevFund) external onlyOwner {
        devFund = newDevFund;
    }


    function closeStaking() external onlyOwner {
        open = false;
    }

    function updateRewards(uint256 amount) internal {
        BIOPToken b = BIOPToken(biop);
        if (b.earlyClaims()) {
            b.updateEarlyClaim(amount.mul(4));
        } else if (b.totalClaimsAvailable() > 0){
            b.updateClaim(amount);
        }
    }


    function stake() external payable {
        require(open == true, "pool deposits has closed");
        require(msg.value >= 100, "stake to small");
        if (block.timestamp < launchEnd) {
            nextWithdraw[msg.sender] = block.timestamp + 14 days;
            _mint(msg.sender, msg.value);
        } else {
            nextWithdraw[msg.sender] = block.timestamp + poolLockSeconds;
            _mint(msg.sender, msg.value);
        }

        if (msg.value >= 2000000000000000000) {
            updateRewards(aStakeReward);
        } else {
            updateRewards(bStakeReward);
        }
    }

    function withdraw(uint256 amount) public {
       require (balanceOf(msg.sender) >= amount, "Insufficent Share Balance");

        uint256 valueToRecieve = amount.mul(address(this).balance).div(totalSupply());
        _burn(msg.sender, amount);
        if (block.timestamp <= nextWithdraw[msg.sender]) {
            uint256 penalty = valueToRecieve.div(100);
            require(devFund.send(penalty), "transfer failed");
            require(msg.sender.send(valueToRecieve.sub(penalty)), "transfer failed");
        } else {
            require(msg.sender.send(valueToRecieve), "transfer failed");
        }
    }

    function bet(OptionType type_, address pp_, uint256 time_) external payable {
        require(
            type_ == OptionType.Call || type_ == OptionType.Put,
            "Wrong option type"
        );
        require(
            time_ >= minTime && time_ <= maxTime,
            "Invalid time"
        );
        require(msg.value >= 100, "bet to small");
        require(enabledPairs[pp_], "Invalid  price provider");
        uint depositValue;
        if (devFundBetFee > 0) {
            uint256 fee = msg.value.div(devFundBetFee).div(100);
            require(devFund.send(fee), "devFund fee transfer failed");
            depositValue = msg.value.sub(fee);
            
        } else {
            depositValue = msg.value;
        }

        RateCalc rc = RateCalc(rcAddress);
        uint256 lockValue = getMaxAvailable();
        lockValue = rc.rate(depositValue, lockValue.sub(depositValue));
        


         
        AggregatorV3Interface priceProvider = AggregatorV3Interface(pp_);
        (, int256 latestPrice, , , ) = priceProvider.latestRoundData();
        uint256 optionID = options.length;
        uint256 totalLock = lockValue.add(depositValue);
        Option memory op = Option(
            State.Active,
            msg.sender,
            uint256(latestPrice),
            depositValue,
            totalLock,//purchaseAmount+possible reward for correct bet
            block.timestamp + time_,//all options 1hr to start
            type_,
            pp_
        );
        lock(totalLock);
        options.push(op);
        emit Create(optionID, msg.sender, uint256(latestPrice), totalLock, type_);
        updateRewards(betReward);
    }

    function exercise(uint256 optionID)
        external
    {
        Option memory option = options[optionID];
        require(block.timestamp <= option.expiration, "expiration date margin has passed");
        AggregatorV3Interface priceProvider = AggregatorV3Interface(option.priceProvider);
        (, int256 latestPrice, , , ) = priceProvider.latestRoundData();
        uint256 uLatestPrice = uint256(latestPrice);
        if (option.optionType == OptionType.Call) {
            require(uLatestPrice > option.strikePrice, "price is to low");
        } else {
            require(uLatestPrice < option.strikePrice, "price is to high");
        }

        payout(option.lockedValue.sub(option.purchaseValue), msg.sender, option.holder);
        
        lockedAmount = lockedAmount.sub(option.lockedValue);
        emit Exercise(optionID);
        updateRewards(exerciseReward);
    }

    function expire(uint256 optionID)
        external
    {
        Option memory option = options[optionID];
        require(block.timestamp > option.expiration, "expiration date has not passed");
        unlock(option.lockedValue.sub(option.purchaseValue), msg.sender, expirerFee);
        emit Expire(optionID);
        lockedAmount = lockedAmount.sub(option.lockedValue);

        updateRewards(exerciseReward);
    }

    function lock(uint256 amount) internal {
        lockedAmount = lockedAmount.add(amount);
    }

    function unlock(uint256 amount, address payable goodSamaritan, uint256 eFee) internal {
        require(amount <= lockedAmount, "insufficent locked pool balance to unlock");
        uint256 fee = amount.div(eFee).div(100);
        if (fee > 0) {
            require(goodSamaritan.send(fee), "good samaritan transfer failed");
        }
    }

    function payout(uint256 amount, address payable exerciser, address payable winner) internal {
        require(amount <= lockedAmount, "insufficent pool balance available to payout");
        require(amount <= address(this).balance, "insufficent balance in pool");
        if (exerciser != winner) {
            uint256 fee = amount.div(exerciserFee).div(100);
            if (fee > 0) {
                require(exerciser.send(fee), "exerciser transfer failed");
                require(winner.send(amount.sub(fee)), "winner transfer failed");
            }
        } else {  
            require(winner.send(amount), "winner transfer failed");
        }
        emit Payout(amount, winner);
    }

}