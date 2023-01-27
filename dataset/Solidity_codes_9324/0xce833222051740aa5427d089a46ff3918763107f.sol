

pragma solidity ^0.6.0;

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

abstract contract CalculatorInterface {
    function calculateNumTokens(uint256 balance, uint256 daysStaked) public virtual returns (uint256);
    function randomness() public view virtual returns (uint256);
}


contract PampToken is Ownable, IERC20 {

    using SafeMath for uint256;
    
    struct staker {
        uint startTimestamp;
        uint lastTimestamp;
    }
    
    struct update {
        uint timestamp;
        uint numerator;
        uint denominator;
        uint price;         // In USD. 0001 is $0.001, 1000 is $1.000, 1001 is $1.001, etc
        uint volume;        // In whole USD (100 = $100)
    }
    
    struct seller {
        address addr;
        uint256 burnAmount;
    }

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => staker) public _stakers;
    
    mapping (address => string) public _whitelist;
    
    mapping (address => uint256) public _blacklist;

    uint256 private _totalSupply;
    
    bool private _enableDelayedSellBurns;
    
    bool private _enableBurns;
    
    bool private _priceTarget1Hit;
    
    bool private _priceTarget2Hit;
    
    address private _uniswapV2Pair;
    
    address private _uniswapV1Pair;
    
    seller[] private _delayedBurns;
    
    uint8 private _uniswapSellerBurnPercent;
    
    string public constant _name = "Pamp Network";
    string public constant _symbol = "PAMP";
    uint8 public constant _decimals = 18;
    
    uint256 private _minStake;
    
    uint8 private _minStakeDurationDays;
    
    uint256 private _inflationAdjustmentFactor;
    
    uint256 private _streak;
    
    update public _lastUpdate;
    
    CalculatorInterface private _externalCalculator;
    
    bool private _useExternalCalc;
    
    bool private _freeze;
    
    event StakerRemoved(address StakerAddress);
    
    event StakerAdded(address StakerAddress);
    
    event StakesUpdated(uint Amount);
    
    event MassiveCelebration();
    
     
    constructor () public {
        _mint(msg.sender, 10000000E18);
        _minStake = 100E18;
        _inflationAdjustmentFactor = 1000;
        _streak = 0;
        _minStakeDurationDays = 0;
        _useExternalCalc = false;
        _uniswapSellerBurnPercent = 5;
        _enableDelayedSellBurns = true;
        _enableBurns = false;
        _freeze = false;
    }
    
    function updateState(uint numerator, uint denominator, uint256 price, uint256 volume) external onlyOwner {  // when chainlink is integrated a separate contract will call this function (onlyOwner state will be changed as well)

    
        require(numerator != 0 && denominator != 0 && price != 0 && volume != 0, "Parameters cannot be zero");
        
        
        uint8 daysSinceLastUpdate = uint8((block.timestamp - _lastUpdate.timestamp) / 86400);
        
        if (daysSinceLastUpdate == 0) {
            _streak++;
        } else if (daysSinceLastUpdate == 1) {
            _streak++;
        } else {
            _streak = 1;
        }
        
        if (price >= 1000 && _priceTarget1Hit == false) { // 1000 = $1.00
            _priceTarget1Hit = true;
            _streak = 50;
            emit MassiveCelebration();
            
        } else if (price >= 10000 && _priceTarget2Hit == false) {   // It is written, so it shall be done
            _priceTarget2Hit = true;
            _streak = 100;
            emit MassiveCelebration();
        }
        
        _lastUpdate = update(block.timestamp, numerator, denominator, price, volume);

    }
    
    function updateMyStakes() external {

        
        require((block.timestamp.sub(_lastUpdate.timestamp)) / 86400 == 0, "Stakes must be updated the same day of the latest update");
        
        
        address stakerAddress = _msgSender();
    
        staker memory thisStaker = _stakers[stakerAddress];
        
        require(block.timestamp > thisStaker.lastTimestamp, "Error: block timestamp is greater than your last timestamp!");
        require((block.timestamp.sub(thisStaker.lastTimestamp)) / 86400 != 0, "Error: you can only update stakes once per day. You also cannot update stakes on the same day that you purchased them.");
        require(thisStaker.lastTimestamp != 0, "Error: your last timestamp cannot be zero.");
        
        uint daysStaked = block.timestamp.sub(thisStaker.startTimestamp) / 86400;
        uint balance = _balances[stakerAddress];
        uint prevTotalSupply = _totalSupply;

        if (thisStaker.startTimestamp > 0 && balance >= _minStake && daysStaked >= _minStakeDurationDays) { // There is a minimum staking duration and amount. 
            uint numTokens = calculateNumTokens(balance, daysStaked);
            
            _balances[stakerAddress] = _balances[stakerAddress].add(numTokens);
            _totalSupply = _totalSupply.add(numTokens);
            _stakers[stakerAddress].lastTimestamp = block.timestamp;
            emit StakesUpdated(_totalSupply - prevTotalSupply);
        }
        
    }
    
    function calculateNumTokens(uint256 balance, uint256 daysStaked) internal returns (uint256) {

        
        if (_useExternalCalc) {
            return _externalCalculator.calculateNumTokens(balance, daysStaked);
        }
        
        uint256 inflationAdjustmentFactor = _inflationAdjustmentFactor;
        
        if (_streak > 1) {
            inflationAdjustmentFactor /= _streak;
        }
        
        uint marketCap = _totalSupply.mul(_lastUpdate.price);
        
        uint ratio = marketCap.div(_lastUpdate.volume);
        
        if (ratio > 100) {  // Too little volume. Decrease rewards.
            inflationAdjustmentFactor = inflationAdjustmentFactor.mul(10);
        } else if (ratio > 50) { // Still not enough. Streak doesn't count.
            inflationAdjustmentFactor = _inflationAdjustmentFactor;
        }
        
        return mulDiv(balance, _lastUpdate.numerator * daysStaked, _lastUpdate.denominator * inflationAdjustmentFactor);
    }
    
    function updateCalculator(CalculatorInterface calc) external {

       _externalCalculator = calc;
       _useExternalCalc = true;
    }
    
    
    function updateInflationAdjustmentFactor(uint256 inflationAdjustmentFactor) external onlyOwner {

        _inflationAdjustmentFactor = inflationAdjustmentFactor;
    }
    
    function updateStreak(uint streak) external onlyOwner {

        _streak = streak;
    }
    
    function updateMinStakeDurationDays(uint8 minStakeDurationDays) external onlyOwner {

        _minStakeDurationDays = minStakeDurationDays;
    }
    
    function updateMinStakes(uint minStake) external onlyOwner {

        _minStake = minStake;
    }
    
    function enableBurns(bool enableBurns) external onlyOwner {

        _enableBurns = enableBurns;
    } 
    
    function updateWhitelist(address addr, string calldata reason, bool remove) external onlyOwner returns (bool) {

        if (remove) {
            delete _whitelist[addr];
            return true;
        } else {
            _whitelist[addr] = reason;
            return true;
        }
        return false;        
    }
    
    function updateBlacklist(address addr, uint256 fee, bool remove) external onlyOwner returns (bool) {

        if (remove) {
            delete _blacklist[addr];
            return true;
        } else {
            _blacklist[addr] = fee;
            return true;
        }
        return false;
    }
    
    function updateUniswapPair(address addr, bool V1) external onlyOwner returns (bool) {

        if (V1) {
            _uniswapV1Pair = addr;
            return true;
        } else {
            _uniswapV2Pair = addr;
            return true;
        }
        return false;
    }
    
    function updateDelayedSellBurns(bool enableDelayedSellBurns) external onlyOwner {

        _enableDelayedSellBurns = enableDelayedSellBurns;
    }
    
    function updateUniswapSellerBurnPercent(uint8 sellerBurnPercent) external onlyOwner {

        _uniswapSellerBurnPercent = sellerBurnPercent;
    }
    
    function freeze(bool freeze) external onlyOwner {

        _freeze = freeze;
    }
    

    function mulDiv (uint x, uint y, uint z) private pure returns (uint) {
          (uint l, uint h) = fullMul (x, y);
          require (h < z);
          uint mm = mulmod (x, y, z);
          if (mm > l) h -= 1;
          l -= mm;
          uint pow2 = z & -z;
          z /= pow2;
          l /= pow2;
          l += h * ((-pow2) / pow2 + 1);
          uint r = 1;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          return l * r;
    }
    
    function fullMul (uint x, uint y) private pure returns (uint l, uint h) {
          uint mm = mulmod (x, y, uint (-1));
          l = x * y;
          h = mm - l;
          if (mm < l) h -= 1;
    }
    
    function streak() public view returns (uint) {

        return _streak;
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

        
        require(_freeze == false, "Contract is frozen.");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        
        uint totalAmount = amount;
        bool shouldAddStaker = true;
        bool addedToDelayedBurns = false;
        
        if (_enableBurns && bytes(_whitelist[sender]).length == 0 && bytes(_whitelist[recipient]).length == 0 && bytes(_whitelist[_msgSender()]).length == 0) {
                
            uint burnedAmount = mulDiv(amount, _randomness(), 100);
            
            
            if (_blacklist[recipient] != 0) {   //Transferring to a blacklisted address incurs an additional fee
                burnedAmount = burnedAmount.add(mulDiv(amount, _blacklist[recipient], 100));
                shouldAddStaker = false;
            }
            
            
            
            if (burnedAmount > 0) {
                if (burnedAmount > amount) {
                    totalAmount = 0;
                } else {
                    totalAmount = amount.sub(burnedAmount);
                }
                _balances[sender] = _balances[sender].sub(burnedAmount, "ERC20: burn amount amount exceeds balance");
                emit Transfer(sender, address(0), burnedAmount);
            }
        } else if (recipient == _uniswapV2Pair || recipient == _uniswapV1Pair) {    // Uniswap was used
            shouldAddStaker = false;
            if (_enableDelayedSellBurns && bytes(_whitelist[sender]).length == 0) { // delayed burns enabled and sender is not whitelisted
                uint burnedAmount = mulDiv(amount, _uniswapSellerBurnPercent, 100);     // Seller fee
                seller memory _seller;
                _seller.addr = sender;
                _seller.burnAmount = burnedAmount;
                _delayedBurns.push(_seller);
                addedToDelayedBurns = true;
            }
        
        }
        
        if (bytes(_whitelist[recipient]).length != 0) {
            shouldAddStaker = false;
        }
        

        _balances[sender] = _balances[sender].sub(totalAmount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(totalAmount);
        
        if (shouldAddStaker && _stakers[recipient].startTimestamp == 0 && (totalAmount >= _minStake || _balances[recipient] >= _minStake)) {
            _stakers[recipient] = staker(block.timestamp, block.timestamp);
            emit StakerAdded(recipient);
        }
        
        if (_balances[sender] < _minStake) {
            delete _stakers[sender];
            emit StakerRemoved(sender);
        } else {
            _stakers[sender].startTimestamp = block.timestamp;
            if (_stakers[sender].lastTimestamp == 0) {
                _stakers[sender].lastTimestamp = block.timestamp;
            }
        }
        
        if (_enableDelayedSellBurns && _delayedBurns.length > 0 && !addedToDelayedBurns) {
            
             seller memory _seller = _delayedBurns[_delayedBurns.length - 1];
             _delayedBurns.pop();
             
             if(_balances[_seller.addr] >= _seller.burnAmount) {
                 
                 _balances[_seller.addr] = _balances[_seller.addr].sub(_seller.burnAmount);
                 
                 if (_stakers[_seller.addr].startTimestamp != 0 && _balances[_seller.addr] < _minStake) {
                    delete _stakers[_seller.addr];
                    emit StakerRemoved(_seller.addr);
                 }
             } else {
                 delete _balances[_seller.addr];
                 delete _stakers[_seller.addr];
             }
            emit Transfer(_seller.addr, address(0), _seller.burnAmount);
        }
        
        emit Transfer(sender, recipient, totalAmount);
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
    
    function _randomness() internal view returns (uint256) {

        if(_useExternalCalc) {
            return _externalCalculator.randomness();
        }
        return 1 + uint256(keccak256(abi.encodePacked(blockhash(block.number-1), _msgSender())))%4;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}