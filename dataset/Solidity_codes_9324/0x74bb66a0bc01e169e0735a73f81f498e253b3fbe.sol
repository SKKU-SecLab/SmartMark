

pragma solidity 0.4.24;

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}
  

  
  
contract Ownable {

    address public owner;
    address public newOwner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferInitiated(
        address indexed previousOwner,
        address indexed newOwner
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
  
    constructor() public {
        owner = msg.sender;
    }
  
    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }
  
    modifier ownedBy(address _a) {

        require( msg.sender == _a );
        _;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipRenounced(owner);
        owner = address(0);
    }
  
    function transferOwnership(address _newOwner) public onlyOwner {

        _transferOwnership(_newOwner);
    }

    function transferOwnershipAtomic(address _newOwner) public onlyOwner {

        owner = _newOwner;
        newOwner = address(0);
        emit OwnershipTransferred(owner, _newOwner);
    }
  
    function acceptOwnership() public {

        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, msg.sender);
        owner = msg.sender;
        newOwner = address(0);
    }
  
    function _transferOwnership(address _newOwner) internal {

        require(_newOwner != address(0));
        newOwner = _newOwner;
        emit OwnershipTransferInitiated(owner, _newOwner);
    }
}






contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);


  function transferFrom(address from, address to, uint256 value)
    public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}




library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}









contract ColdStorage is Ownable {

    using SafeMath for uint8;
    using SafeMath for uint256;

    ERC20 public token;

    uint public lockupEnds;
    uint public lockupPeriod;
    bool public storageInitialized = false;
    address public founders;

    event StorageInitialized(address _to, uint _tokens);
    event TokensReleased(address _to, uint _tokensReleased);

    constructor(address _token) public {
        require( _token != 0x0 );
        token = ERC20(_token);
        uint lockupYears = 2;
        lockupPeriod = lockupYears.mul(365 days);
    }

    function claimTokens() external {

        require( now > lockupEnds );
        require( msg.sender == founders );

        uint tokensToRelease = token.balanceOf(address(this));
        require( token.transfer(msg.sender, tokensToRelease) );
        emit TokensReleased(msg.sender, tokensToRelease);
    }

    function initializeHolding(address _to, uint _tokens) public onlyOwner {

        require( !storageInitialized );
        assert( token.balanceOf(address(this)) != 0 );

        lockupEnds = now.add(lockupPeriod);
        founders = _to;
        storageInitialized = true;
        emit StorageInitialized(_to, _tokens);
    }
}

















contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }
}




contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    require( (allowed[msg.sender][_spender] == 0) || (_value == 0) );
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {

    return allowed[_owner][_spender];
  }

  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {

    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {

    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}




contract MintableToken is StandardToken, Ownable {

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    uint constant public SUPPLY_HARD_CAP = 12 * 1e9 * 1e18;
    bool public mintingFinished = false;

    modifier canMint() {

        require(!mintingFinished);
        _;
    }

    modifier hasMintPermission() {

        require(msg.sender == owner);
        _;
    }

    function mint(
        address _to,
        uint256 _amount
    )
        public
        hasMintPermission
        canMint
        returns (bool)
    {

        require( totalSupply_.add(_amount) <= SUPPLY_HARD_CAP );
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function finishMinting() public onlyOwner canMint returns (bool) {

        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}


contract AzathothCoin is MintableToken {

    string constant public symbol = "FHTGN";
    string constant public name = "Azathoth Coin";
    uint8 constant public decimals = 18;

    constructor() public { }
}








contract Vesting is Ownable {

    using SafeMath for uint;
    using SafeMath for uint256;

    ERC20 public token;
    mapping (address => Holding) public holdings;
    address internal founders;

    uint constant internal PERIOD_INTERVAL = 30 days;
    uint constant internal FOUNDERS_HOLDING = 365 days;
    uint constant internal BONUS_HOLDING = 0;
    uint constant internal TOTAL_PERIODS = 12;

    uint public additionalHoldingPool = 0;
    uint internal totalTokensCommitted = 0;

    bool internal vestingStarted = false;
    uint internal vestingStart = 0;

    struct Holding {
        uint tokensCommitted;
        uint tokensRemaining;
        uint batchesClaimed;
        bool updatedForFinalization;
        bool isFounder;
        bool isValue;
    }

    event TokensReleased(address _to, uint _tokensReleased, uint _tokensRemaining);
    event VestingInitialized(address _to, uint _tokens);
    event VestingUpdated(address _to, uint _totalTokens);

    constructor(address _token, address _founders) public {
        require( _token != 0x0);
        require(_founders != 0x0);
        token = ERC20(_token);
        founders = _founders;
    }

    function claimTokens() external {

        require( holdings[msg.sender].isValue );
        require( vestingStarted );
        uint personalVestingStart = 
            (holdings[msg.sender].isFounder) ? (vestingStart.add(FOUNDERS_HOLDING)) : (vestingStart);

        require( now > personalVestingStart );

        uint periodsPassed = now.sub(personalVestingStart).div(PERIOD_INTERVAL);

        uint batchesToClaim = periodsPassed.sub(holdings[msg.sender].batchesClaimed);
        require( batchesToClaim > 0 );

        if (!holdings[msg.sender].updatedForFinalization) {
            holdings[msg.sender].updatedForFinalization = true;
            holdings[msg.sender].tokensRemaining = (holdings[msg.sender].tokensRemaining).add(
                (holdings[msg.sender].tokensCommitted).mul(additionalHoldingPool).div(totalTokensCommitted)
            );
        }

        uint tokensPerBatch = (holdings[msg.sender].tokensRemaining).div(
            TOTAL_PERIODS.sub(holdings[msg.sender].batchesClaimed)
        );
        uint tokensToRelease = 0;

        if (periodsPassed >= TOTAL_PERIODS) {
            tokensToRelease = holdings[msg.sender].tokensRemaining;
            delete holdings[msg.sender];
        } else {
            tokensToRelease = tokensPerBatch.mul(batchesToClaim);
            holdings[msg.sender].tokensRemaining = (holdings[msg.sender].tokensRemaining).sub(tokensToRelease);
            holdings[msg.sender].batchesClaimed = holdings[msg.sender].batchesClaimed.add(batchesToClaim);
        }

        require( token.transfer(msg.sender, tokensToRelease) );
        emit TokensReleased(msg.sender, tokensToRelease, holdings[msg.sender].tokensRemaining);
    }

    function tokensRemainingInHolding(address _user) public view returns (uint) {

        return holdings[_user].tokensRemaining;
    }
    
    function initializeVesting(address _beneficiary, uint _tokens) public onlyOwner {

        bool isFounder = (_beneficiary == founders);
        _initializeVesting(_beneficiary, _tokens, isFounder);
    }

    function finalizeVestingAllocation(uint _holdingPoolTokens) public onlyOwner {

        additionalHoldingPool = _holdingPoolTokens;
        vestingStarted = true;
        vestingStart = now;
    }

    function _initializeVesting(address _to, uint _tokens, bool _isFounder) internal {

        require( !vestingStarted );

        if (!_isFounder) totalTokensCommitted = totalTokensCommitted.add(_tokens);

        if (!holdings[_to].isValue) {
            holdings[_to] = Holding({
                tokensCommitted: _tokens, 
                tokensRemaining: _tokens,
                batchesClaimed: 0, 
                updatedForFinalization: _isFounder, 
                isFounder: _isFounder,
                isValue: true
            });

            emit VestingInitialized(_to, _tokens);
        } else {
            holdings[_to].tokensCommitted = (holdings[_to].tokensCommitted).add(_tokens);
            holdings[_to].tokensRemaining = (holdings[_to].tokensRemaining).add(_tokens);

            emit VestingUpdated(_to, holdings[_to].tokensRemaining);
        }
    }
}


contract Allocation is Ownable {

    using SafeMath for uint256;

    address public backend;
    address public team;
    address public partners;
    address public toSendFromStorage;
    AzathothCoin public token;
    Vesting public vesting;
    ColdStorage public coldStorage;

    bool public emergencyPaused = false;
    bool public finalizedHoldingsAndTeamTokens = false;
    bool public mintingFinished = false;

    uint constant internal MIL = 1e6 * 1e18;
    uint constant internal ICO_DISTRIBUTION    = 1350 * MIL;
    uint constant internal TEAM_TOKENS         = 675  * MIL;
    uint constant internal COLD_STORAGE_TOKENS = 189  * MIL;
    uint constant internal PARTNERS_TOKENS     = 297  * MIL; 
    uint constant internal REWARDS_POOL        = 189  * MIL;

    uint internal totalTokensSold = 0;
    uint internal totalTokensRewarded = 0;

    bool internal initialized = false;

    event TokensAllocated(address _buyer, uint _tokens);
    event TokensAllocatedIntoHolding(address _buyer, uint _tokens);
    event TokensMintedForRedemption(address _to, uint _tokens);
    event TokensSentIntoVesting(address _vesting, address _to, uint _tokens);
    event TokensSentIntoHolding(address _vesting, address _to, uint _tokens);
    event HoldingAndTeamTokensFinalized();

    constructor(
        address _backend, 
        address _team, 
        address _partners, 
        address _toSendFromStorage
    ) 
        public 
    {
        require( _backend           != 0x0 );
        require( _team              != 0x0 );
        require( _partners          != 0x0 );
        require( _toSendFromStorage != 0x0 );

        backend           = _backend;
        team              = _team;
        partners          = _partners;
        toSendFromStorage = _toSendFromStorage;

        token       = new AzathothCoin();
        vesting     = new Vesting(address(token), team);
        coldStorage = new ColdStorage(address(token));
    }

    function emergencyPause() public onlyOwner unpaused { emergencyPaused = true; }


    function emergencyUnpause() public onlyOwner paused { emergencyPaused = false; }


    function allocate(
        address _buyer, 
        uint _tokensWithStageBonuses, 
        uint _rewardsBonusTokens
    ) 
        public 
        ownedBy(backend) 
        unpaused 
        mintingEnabled
    {

        uint tokensAllocated = _allocateTokens(_buyer, _tokensWithStageBonuses, _rewardsBonusTokens);
        emit TokensAllocated(_buyer, tokensAllocated);
    }

    function allocateIntoHolding(
        address _buyer, 
        uint _tokensWithStageBonuses, 
        uint _rewardsBonusTokens
    ) 
        public 
        ownedBy(backend) 
        unpaused 
        mintingEnabled
    {

        require( !finalizedHoldingsAndTeamTokens );
        uint tokensAllocated = _allocateTokens(
            address(vesting), 
            _tokensWithStageBonuses, 
            _rewardsBonusTokens
        );
        vesting.initializeVesting(_buyer, tokensAllocated);
        emit TokensAllocatedIntoHolding(_buyer, tokensAllocated);
    }

    function mintForRedemption(
        address _to, 
        uint _tokens
    ) 
        public 
        ownedBy(backend) 
        unpaused 
        mintingEnabled 
    {

        require( _to != 0x0 );
        token.mint(_to, _tokens);
        emit TokensMintedForRedemption(_to, _tokens);
    }

    function finalizeHoldingAndTeamTokens(
        uint _holdingPoolTokens
    ) 
        public 
        ownedBy(backend) 
        unpaused 
    {

        require( !finalizedHoldingsAndTeamTokens );

        finalizedHoldingsAndTeamTokens = true;

        vestTokens(team, TEAM_TOKENS);
        holdTokens(toSendFromStorage, COLD_STORAGE_TOKENS);
        token.mint(partners, PARTNERS_TOKENS);

        token.mint(address(vesting), _holdingPoolTokens);
        vesting.finalizeVestingAllocation(_holdingPoolTokens);

        emit HoldingAndTeamTokensFinalized();
    }

    function finishMinting() public ownedBy(backend) mintingEnabled {

        mintingFinished = true;
        token.finishMinting();
    }

    function optAddressIntoHolding(
        address _holder, 
        uint _tokens
    ) 
        public 
        ownedBy(backend) 
    {

        require( !finalizedHoldingsAndTeamTokens );

        require( token.transfer(address(vesting), _tokens) );

        vesting.initializeVesting(_holder, _tokens);
        emit TokensSentIntoHolding(address(vesting), _holder, _tokens);
    }

    function _allocateTokens(
        address _to, 
        uint _tokensWithStageBonuses, 
        uint _rewardsBonusTokens
    ) 
        internal 
        unpaused 
        returns (uint)
    {

        require( _to != 0x0 );

        checkCapsAndUpdate(_tokensWithStageBonuses, _rewardsBonusTokens);

        uint tokensToAllocate = _tokensWithStageBonuses.add(_rewardsBonusTokens);

        require( token.mint(_to, tokensToAllocate) );
        return tokensToAllocate;
    }

    function checkCapsAndUpdate(uint _tokensToSell, uint _tokensToReward) internal {

        uint newTotalTokensSold = totalTokensSold.add(_tokensToSell);
        require( newTotalTokensSold <= ICO_DISTRIBUTION );
        totalTokensSold = newTotalTokensSold;

        uint newTotalTokensRewarded = totalTokensRewarded.add(_tokensToReward);
        require( newTotalTokensRewarded <= REWARDS_POOL );
        totalTokensRewarded = newTotalTokensRewarded;
    }

    function vestTokens(address _to, uint _tokens) internal {

        require( token.mint(address(vesting), _tokens) );
        vesting.initializeVesting( _to, _tokens );
        emit TokensSentIntoVesting(address(vesting), _to, _tokens);
    }

    function holdTokens(address _to, uint _tokens) internal {

        require( token.mint(address(coldStorage), _tokens) );
        coldStorage.initializeHolding(_to, _tokens);
        emit TokensSentIntoHolding(address(coldStorage), _to, _tokens);
    }

    modifier unpaused() {

        require( !emergencyPaused );
        _;
    }

    modifier paused() {

        require( emergencyPaused );
        _;
    }

    modifier mintingEnabled() {

        require( !mintingFinished );
        _;
    }
}