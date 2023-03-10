
pragma solidity ^0.4.24;
pragma solidity ^0.4.24;



contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {

    return balances[_owner];
  }

}






contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {

    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  function Ownable() public {

    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract SingleLockingContract is Ownable {

    using SafeMath for uint256;


    event ReleasedTokens(address indexed _beneficiary);


    ERC20 public tokenContract;
    uint256 public unlockTime;
    address public beneficiary;


    modifier onlyWhenUnlocked() {

        require(!isLocked());
        _;
    }

    modifier onlyWhenLocked() {

        require(isLocked());
        _;
    }


    function SingleLockingContract(ERC20 _tokenContract, uint256 _unlockTime, address _beneficiary) public {

        require(_unlockTime > now);
        require(address(_tokenContract) != 0x0);
        require(_beneficiary != 0x0);

        unlockTime = _unlockTime;
        tokenContract = _tokenContract;
        beneficiary = _beneficiary;
    }


    function isLocked() public view returns(bool) {

        return now < unlockTime;
    }

    function balanceOf() public view returns (uint256 balance) {

        return tokenContract.balanceOf(address(this));
    }

    function releaseTokens() public onlyWhenUnlocked {

        require(msg.sender == owner || msg.sender == beneficiary);
        require(tokenContract.transfer(beneficiary, balanceOf())); 
        emit ReleasedTokens(beneficiary);
    }
}


contract Whitelist is Ownable {

    mapping(address => bool) whitelist;
    event AddedToWhitelist(address indexed account);
    event RemovedFromWhitelist(address indexed account);

    modifier onlyWhitelisted() {

        require(isWhitelisted(msg.sender));
        _;
    }

    function add(address _address) public onlyOwner {

        whitelist[_address] = true;
        emit AddedToWhitelist(_address);
    }

    function remove(address _address) public onlyOwner {

        whitelist[_address] = false;
        emit RemovedFromWhitelist(_address);
    }

    function isWhitelisted(address _address) public view returns(bool) {

        return whitelist[_address];
    }
}

contract LockingContract is Ownable {

    using SafeMath for uint256;

    event NotedTokens(address indexed _beneficiary, uint256 _tokenAmount);
    event ReleasedTokens(address indexed _beneficiary);
    event ReducedLockingTime(uint256 _newUnlockTime);

    ERC20 public tokenContract;
    mapping(address => uint256) public tokens;
    uint256 public totalTokens;
    uint256 public unlockTime;

    function isLocked() public view returns(bool) {

        return now < unlockTime;
    }

    modifier onlyWhenUnlocked() {

        require(!isLocked());
        _;
    }

    modifier onlyWhenLocked() {

        require(isLocked());
        _;
    }

    function LockingContract(ERC20 _tokenContract, uint256 _unlockTime) public {

        require(_unlockTime > now);
        require(address(_tokenContract) != 0x0);
        unlockTime = _unlockTime;
        tokenContract = _tokenContract;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return tokens[_owner];
    }

    function noteTokens(address _beneficiary, uint256 _tokenAmount) external onlyOwner onlyWhenLocked {

        uint256 tokenBalance = tokenContract.balanceOf(this);
        require(tokenBalance >= totalTokens.add(_tokenAmount));

        tokens[_beneficiary] = tokens[_beneficiary].add(_tokenAmount);
        totalTokens = totalTokens.add(_tokenAmount);
        emit NotedTokens(_beneficiary, _tokenAmount);
    }

    function releaseTokens(address _beneficiary) public onlyWhenUnlocked {

        require(msg.sender == owner || msg.sender == _beneficiary);
        uint256 amount = tokens[_beneficiary];
        tokens[_beneficiary] = 0;
        require(tokenContract.transfer(_beneficiary, amount)); 
        totalTokens = totalTokens.sub(amount);
        emit ReleasedTokens(_beneficiary);
    }

    function reduceLockingTime(uint256 _newUnlockTime) public onlyOwner onlyWhenLocked {

        require(_newUnlockTime >= now);
        require(_newUnlockTime < unlockTime);
        unlockTime = _newUnlockTime;
        emit ReducedLockingTime(_newUnlockTime);
    }
}




contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {

    require(!mintingFinished);
    _;
  }

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  function finishMinting() onlyOwner canMint public returns (bool) {

    mintingFinished = true;
    MintFinished();
    return true;
  }
}


contract CrowdfundableToken is MintableToken {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public cap;

    function CrowdfundableToken(uint256 _cap, string _name, string _symbol, uint8 _decimals) public {

        require(_cap > 0);
        require(bytes(_name).length > 0);
        require(bytes(_symbol).length > 0);
        cap = _cap;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

        require(totalSupply_.add(_amount) <= cap);
        return super.mint(_to, _amount);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {

        require(mintingFinished == true);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(mintingFinished == true);
        return super.transferFrom(_from, _to, _value);
    }

    function burn(uint amount) public {

        totalSupply_ = totalSupply_.sub(amount);
        balances[msg.sender] = balances[msg.sender].sub(amount);
    }
}

contract AllSporterCoin is CrowdfundableToken {

    constructor() public 
        CrowdfundableToken(260000000 * (10**18), "AllSporter Coin", "ALL", 18) {
    }
}


contract Minter is Ownable {

    using SafeMath for uint;


    event Minted(address indexed account, uint etherAmount, uint tokenAmount);
    event Reserved(uint etherAmount);
    event MintedReserved(address indexed account, uint etherAmount, uint tokenAmount);
    event Unreserved(uint etherAmount);


    CrowdfundableToken public token;
    uint public saleEtherCap;
    uint public confirmedSaleEther;
    uint public reservedSaleEther;


    modifier onlyInUpdatedState() {

        updateState();
        _;
    }

    modifier upToSaleEtherCap(uint additionalEtherAmount) {

        uint totalEtherAmount = confirmedSaleEther.add(reservedSaleEther).add(additionalEtherAmount);
        require(totalEtherAmount <= saleEtherCap);
        _;
    }

    modifier onlyApprovedMinter() {

        require(canMint(msg.sender));
        _;
    }

    modifier atLeastMinimumAmount(uint etherAmount) {

        require(etherAmount >= getMinimumContribution());
        _;
    }

    modifier onlyValidAddress(address account) {

        require(account != 0x0);
        _;
    }


    constructor(CrowdfundableToken _token, uint _saleEtherCap) public onlyValidAddress(address(_token)) {
        require(_saleEtherCap > 0);

        token = _token;
        saleEtherCap = _saleEtherCap;
    }


    function transferTokenOwnership() external onlyOwner {

        token.transferOwnership(owner);
    }

    function reserve(uint etherAmount) external
        onlyInUpdatedState
        onlyApprovedMinter
        upToSaleEtherCap(etherAmount)
        atLeastMinimumAmount(etherAmount)
    {

        reservedSaleEther = reservedSaleEther.add(etherAmount);
        updateState();
        emit Reserved(etherAmount);
    }

    function mintReserved(address account, uint etherAmount, uint tokenAmount) external
        onlyInUpdatedState
        onlyApprovedMinter
    {

        reservedSaleEther = reservedSaleEther.sub(etherAmount);
        confirmedSaleEther = confirmedSaleEther.add(etherAmount);
        require(token.mint(account, tokenAmount));
        updateState();
        emit MintedReserved(account, etherAmount, tokenAmount);
    }

    function unreserve(uint etherAmount) public
        onlyInUpdatedState
        onlyApprovedMinter
    {

        reservedSaleEther = reservedSaleEther.sub(etherAmount);
        updateState();
        emit Unreserved(etherAmount);
    }

    function mint(address account, uint etherAmount, uint tokenAmount) public
        onlyInUpdatedState
        onlyApprovedMinter
        upToSaleEtherCap(etherAmount)
    {

        confirmedSaleEther = confirmedSaleEther.add(etherAmount);
        require(token.mint(account, tokenAmount));
        updateState();
        emit Minted(account, etherAmount, tokenAmount);
    }

    function getMinimumContribution() public view returns(uint);


    function updateState() public;


    function canMint(address sender) public view returns(bool);


    function getTokensForEther(uint etherAmount) public view returns(uint);

}

contract DeferredKyc is Ownable {

    using SafeMath for uint;


    event AddedToKyc(address indexed investor, uint etherAmount, uint tokenAmount);
    event Approved(address indexed investor, uint etherAmount, uint tokenAmount);
    event Rejected(address indexed investor, uint etherAmount, uint tokenAmount);
    event RejectedWithdrawn(address indexed investor, uint etherAmount);
    event ApproverTransferred(address newApprover);
    event TreasuryUpdated(address newTreasury);


    address public treasury;
    Minter public minter;
    address public approver;
    mapping(address => uint) public etherInProgress;
    mapping(address => uint) public tokenInProgress;
    mapping(address => uint) public etherRejected;


    modifier onlyApprover() {

        require(msg.sender == approver);
        _;
    }

    modifier onlyValidAddress(address account) {

        require(account != 0x0);
        _;
    }


    constructor(Minter _minter, address _approver, address _treasury)
        public
        onlyValidAddress(address(_minter))
        onlyValidAddress(_approver)
        onlyValidAddress(_treasury)
    {
        minter = _minter;
        approver = _approver;
        treasury = _treasury;
    }


    function updateTreasury(address newTreasury) external onlyOwner {

        treasury = newTreasury;
        emit TreasuryUpdated(newTreasury);
    }

    function addToKyc(address investor) external payable onlyOwner {

        minter.reserve(msg.value);
        uint tokenAmount = minter.getTokensForEther(msg.value);
        require(tokenAmount > 0);
        emit AddedToKyc(investor, msg.value, tokenAmount);

        etherInProgress[investor] = etherInProgress[investor].add(msg.value);
        tokenInProgress[investor] = tokenInProgress[investor].add(tokenAmount);
    }

    function approve(address investor) external onlyApprover {

        minter.mintReserved(investor, etherInProgress[investor], tokenInProgress[investor]);
        emit Approved(investor, etherInProgress[investor], tokenInProgress[investor]);
        
        uint value = etherInProgress[investor];
        etherInProgress[investor] = 0;
        tokenInProgress[investor] = 0;
        treasury.transfer(value);
    }

    function reject(address investor) external onlyApprover {

        minter.unreserve(etherInProgress[investor]);
        emit Rejected(investor, etherInProgress[investor], tokenInProgress[investor]);

        etherRejected[investor] = etherRejected[investor].add(etherInProgress[investor]);
        etherInProgress[investor] = 0;
        tokenInProgress[investor] = 0;
    }

    function withdrawRejected() external {

        uint value = etherRejected[msg.sender];
        etherRejected[msg.sender] = 0;
        (msg.sender).transfer(value);
        emit RejectedWithdrawn(msg.sender, value);
    }

    function forceWithdrawRejected(address investor) external onlyApprover {

        uint value = etherRejected[investor];
        etherRejected[investor] = 0;
        (investor).transfer(value);
        emit RejectedWithdrawn(investor, value);
    }

    function transferApprover(address newApprover) external onlyApprover {

        approver = newApprover;
        emit ApproverTransferred(newApprover);
    }
}

library SafeERC20 {

  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {

    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {

    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {

    assert(token.approve(spender, value));
  }
}


contract TokenVesting is Ownable {

  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);
  event Revoked();

  address public beneficiary;

  uint256 public cliff;
  uint256 public start;
  uint256 public duration;

  bool public revocable;

  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {

    require(_beneficiary != address(0));
    require(_cliff <= _duration);

    beneficiary = _beneficiary;
    revocable = _revocable;
    duration = _duration;
    cliff = _start.add(_cliff);
    start = _start;
  }

  function release(ERC20Basic token) public {

    uint256 unreleased = releasableAmount(token);

    require(unreleased > 0);

    released[token] = released[token].add(unreleased);

    token.safeTransfer(beneficiary, unreleased);

    Released(unreleased);
  }

  function revoke(ERC20Basic token) public onlyOwner {

    require(revocable);
    require(!revoked[token]);

    uint256 balance = token.balanceOf(this);

    uint256 unreleased = releasableAmount(token);
    uint256 refund = balance.sub(unreleased);

    revoked[token] = true;

    token.safeTransfer(owner, refund);

    Revoked();
  }

  function releasableAmount(ERC20Basic token) public view returns (uint256) {

    return vestedAmount(token).sub(released[token]);
  }

  function vestedAmount(ERC20Basic token) public view returns (uint256) {

    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released[token]);

    if (now < cliff) {
      return 0;
    } else if (now >= start.add(duration) || revoked[token]) {
      return totalBalance;
    } else {
      return totalBalance.mul(now.sub(start)).div(duration);
    }
  }
}



contract Allocator is Ownable {

    using SafeMath for uint;


    uint constant public ETHER_AMOUNT = 0;

    uint constant public COMMUNITY_PERCENTAGE = 5;
    uint constant public ADVISORS_PERCENTAGE = 8;
    uint constant public CUSTOMER_PERCENTAGE = 15;
    uint constant public TEAM_PERCENTAGE = 17;
    uint constant public SALE_PERCENTAGE = 55;
    
    uint constant public LOCKING_UNLOCK_TIME = 1602324000;

    uint constant public VESTING_START_TIME = 1568109600;
    uint constant public VESTING_CLIFF_DURATION = 10000;
    uint constant public VESTING_PERIOD = 50000;
    

    event Initialized();
    event AllocatedCommunity(address indexed account, uint tokenAmount);
    event AllocatedAdvisors(address indexed account, uint tokenAmount);
    event AllocatedCustomer(address indexed account, uint tokenAmount, address contractAddress);
    event AllocatedTeam(address indexed account, uint tokenAmount, address contractAddress);
    event LockedTokensReleased(address indexed account);
    event VestedTokensReleased(address indexed account);


    Minter public minter;
    bool public isInitialized = false;
    mapping(address => TokenVesting) public vestingContracts; // one customer => one TokenVesting contract
    mapping(address => SingleLockingContract) public lockingContracts; // one team => one SingleLockingContract

    uint public communityPool;
    uint public advisorsPool;
    uint public customerPool;
    uint public teamPool;
    


    modifier initialized() {

        if (!isInitialized) {
            initialize();
        }
        _;
    }

    modifier validPercentage(uint percent) {

        require(percent >= 0 && percent <= 100);
        _;
    }

    modifier onlyValidAddress(address account) {

        require(account != 0x0);
        _;
    }


    constructor(Minter _minter)
    public
    validPercentage(COMMUNITY_PERCENTAGE)
    validPercentage(ADVISORS_PERCENTAGE)
    validPercentage(CUSTOMER_PERCENTAGE)
    validPercentage(TEAM_PERCENTAGE)
    validPercentage(SALE_PERCENTAGE)
    onlyValidAddress(_minter)
    {
        require(COMMUNITY_PERCENTAGE.add(ADVISORS_PERCENTAGE).add(CUSTOMER_PERCENTAGE).add(TEAM_PERCENTAGE).add(SALE_PERCENTAGE) == 100);
        minter = _minter;
    }


    function releaseVested(address account) external initialized {

        require(msg.sender == account || msg.sender == owner);
        TokenVesting vesting = vestingContracts[account];
        vesting.release(minter.token());
        emit VestedTokensReleased(account);
    }

    function releaseLocked(address account) external initialized {

        require(msg.sender == account || msg.sender == owner);
        SingleLockingContract locking = lockingContracts[account];
        locking.releaseTokens();
        emit LockedTokensReleased(account);
    }

    function allocateCommunity(address account, uint tokenAmount) external initialized onlyOwner {

        communityPool = communityPool.sub(tokenAmount);
        minter.mint(account, ETHER_AMOUNT, tokenAmount);
        emit AllocatedCommunity(account, tokenAmount);
    }

    function allocateAdvisors(address account, uint tokenAmount) external initialized onlyOwner {

        advisorsPool = advisorsPool.sub(tokenAmount);
        minter.mint(account, ETHER_AMOUNT, tokenAmount);
        emit AllocatedAdvisors(account, tokenAmount);
    }

    function allocateCustomer(address account, uint tokenAmount) external initialized onlyOwner {

        customerPool = customerPool.sub(tokenAmount);
        if (address(vestingContracts[account]) == 0x0) {
            vestingContracts[account] = new TokenVesting(account, VESTING_START_TIME, VESTING_CLIFF_DURATION, VESTING_PERIOD, false);
        }
        minter.mint(address(vestingContracts[account]), ETHER_AMOUNT, tokenAmount);
        emit AllocatedCustomer(account, tokenAmount, address(vestingContracts[account]));
    }

    function allocateTeam(address account, uint tokenAmount) external initialized onlyOwner {

        teamPool = teamPool.sub(tokenAmount);
        if (address(lockingContracts[account]) == 0x0) {
            lockingContracts[account] = new SingleLockingContract(minter.token(), LOCKING_UNLOCK_TIME, account);
        }
        minter.mint(lockingContracts[account], ETHER_AMOUNT, tokenAmount);
        emit AllocatedTeam(account, tokenAmount, address(lockingContracts[account]));
    }


    function initialize() internal {

        isInitialized = true;
        CrowdfundableToken token = minter.token();
        uint tokensSold = token.totalSupply();
        uint tokensPerPercent = tokensSold.div(SALE_PERCENTAGE);

        communityPool = COMMUNITY_PERCENTAGE.mul(tokensPerPercent);
        advisorsPool = ADVISORS_PERCENTAGE.mul(tokensPerPercent);
        customerPool = CUSTOMER_PERCENTAGE.mul(tokensPerPercent);
        teamPool = TEAM_PERCENTAGE.mul(tokensPerPercent);

        emit Initialized();
    }
}