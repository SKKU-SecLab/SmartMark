


pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity >=0.6.0 <0.8.0;

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



pragma solidity >=0.6.0 <0.8.0;

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
}



pragma solidity >=0.6.0 <0.8.0;




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

}



pragma solidity >=0.6.0 <0.8.0;



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
}



pragma solidity >=0.6.0 <0.8.0;

contract Moratoken is ERC20Burnable {
    constructor(uint256 _initialSupply, string memory _name, string memory _symbol)  public ERC20 (_name, _symbol) {
        _mint(msg.sender, _initialSupply * (10 ** uint256(decimals())));

    }
}


pragma solidity >=0.6.0 <0.8.0;

contract MoraStaking{
    using SafeMath for uint;
    Moratoken private token;
    uint256 private totalRewardAllocation = (1000000 * 10**18);
    uint private totalActiveStakes;
    uint256 private totalActiveStakeAmount;
    uint256 private totalDistrubutedReward;
    uint private termofacontract = (2592000 * 5); // 5 Months
    uint private deployDate;
    uint256 private startDate;
    
    

    struct StakeBox {
        address staker;
        uint256 amount;
        uint rewardRate;
        uint256 stakeDate;
        uint256 unstakeDate;
        uint256 claimedAmount;
        uint256 reward;
        bool isActive;
    }
    StakeBox[] public stakeBoxs;
    mapping (uint => address) stakeToOwner;
    mapping (address => uint []) ownerToStakes;
    mapping (address => uint) ownerStakeCount;


    modifier nonZeroAddress(address x) {
    require(x != address(0), "token-zero-address");
    deployDate = block.timestamp;
    _;
  }

    event evStake(address _staker, uint _stakeID, uint256 _amount, uint _stakeDate);
    event evUnstake(address _staker, uint _stakeID, uint _amount, uint _reward, uint256 _claimedAmount, uint _unstakeTime);

    constructor(address _token, uint256 _startDate) public
    nonZeroAddress(_token)
    {
      token = Moratoken(_token);
      deployDate = block.timestamp;
      startDate = _startDate;
    }

  function Stake(uint256 _amount) external returns(bool success) {
    require(block.timestamp >= startDate,"not-yet");
    _amount = _amount * (10**18);
    uint _rewardRate;
    uint _stakeDate = block.timestamp;
    if ( _amount < 2000 * (10**18) ) { _rewardRate = 0;}
    if ( _amount >= 2000 * (10**18) && _amount < 7000 * (10**18) ) { _rewardRate = 58;} // Multiply 10**4 - APY 50 %  - Hourly 0.0058
    if ( _amount >= 7000 * (10**18) && _amount < 16000 * (10**18) ) { _rewardRate = 81;} // Multiply 10**4 - APY 70 %  - Hourly 0.0080
    if ( _amount >= 16000 * (10**18)) { _rewardRate = 104;}                              // Multiply 10**4 - APY 90 %  - Hourly 0.0104
    stakeBoxs.push(StakeBox(msg.sender, _amount, _rewardRate, _stakeDate , 0, 0, 0, true));
    uint _stakeID = stakeBoxs.length.sub(1);
    stakeToOwner[_stakeID] = msg.sender;
    ownerStakeCount[msg.sender].add(1);
    ownerToStakes[msg.sender].push(_stakeID);
    totalActiveStakeAmount += _amount;
    totalActiveStakes += 1;
    require(block.timestamp < (deployDate + termofacontract) - 21600,"out-of-date"); // make non-stakable 6 hours before from end time. //21600
    require(token.transferFrom(msg.sender, address(this), _amount),"failed");
    emit evStake(msg.sender, _stakeID, _amount, _stakeDate);
    return true;
  }

  function UnstakeAndClaim(uint _stakeID) external returns (bool result) {
    uint _stakePeriodInHour = (block.timestamp - stakeBoxs[_stakeID].stakeDate ) / 3600; // Stake Period in Hour ****
    uint256 _amount = stakeBoxs[_stakeID].amount;
    uint256 _reward = (_stakePeriodInHour * (stakeBoxs[_stakeID].rewardRate / 10**4)) * _amount / 100; // division for 10**4
    uint256 _claimedAmount = _amount + _reward;
    require(stakeBoxs[_stakeID].unstakeDate == 0, "already-claimed-before");
    require(stakeBoxs[_stakeID].staker == msg.sender,"this-is-not-yours");
    require(_stakePeriodInHour >= 24,"cant-unstake-before-24-hours"); //Unstake not permitted in first 24 hours ****
    stakeBoxs[_stakeID].unstakeDate = block.timestamp;
    stakeBoxs[_stakeID].claimedAmount = _claimedAmount;
    stakeBoxs[_stakeID].reward = _reward;
    stakeBoxs[_stakeID].isActive = false;
    totalDistrubutedReward += _reward;
    totalActiveStakeAmount -= _amount;
    totalActiveStakes -= 1;
    require(token.transfer(msg.sender, _claimedAmount),"Failed");
    emit evUnstake(msg.sender, _stakeID, _amount, _reward, _claimedAmount, block.timestamp);
    return true;
  }
  
    function BurnRemainingTokens() external returns (bool result) {
    require(block.timestamp > (deployDate + termofacontract) + 86400,"out-of-date"); // Burnable after 24 hours from end time. //86400 ****
    token.burn(totalRewardAllocation - totalDistrubutedReward);
    return true;
  }
  

    function Stakes(address _staker) external view returns(uint[] memory) {
    return ownerToStakes[_staker];
  }
    function TotalActiveStakes() external view returns (uint256 result) {
    return totalActiveStakes;
  }
  function TotalActiveStakeAmount() external view returns (uint256 result) {
    return totalActiveStakeAmount;
  }

    function TotalDistributedReward() external view returns (uint256 result) {
    return totalDistrubutedReward;
    }
    
    function RemainingRewards() external view returns (uint256 result) {
        return totalRewardAllocation - totalDistrubutedReward;
    }
    function RemainingTimeEndOfContract() external view returns (uint result) {
    return ((deployDate + termofacontract) - block.timestamp) / 3600; // in hours
  }


  
}