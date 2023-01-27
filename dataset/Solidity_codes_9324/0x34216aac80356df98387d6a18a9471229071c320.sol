

pragma solidity 0.5.7;


contract IERC1132 {

    mapping(address => bytes32[]) public lockReason;

    struct LockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }

    mapping(address => mapping(bytes32 => LockToken)) public locked;

    event Locked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount,
        uint256 _validity
    );

    event Unlocked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount
    );
    
    function lock(bytes32 _reason, uint256 _amount, uint256 _time)
        public returns (bool);

  
    function tokensLocked(address _of, bytes32 _reason)
        public view returns (uint256 amount);

    
    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
        public view returns (uint256 amount);

    
    function totalBalanceOf(address _of)
        public view returns (uint256 amount);

    
    function extendLock(bytes32 _reason, uint256 _time)
        public returns (bool);

    
    function increaseLockAmount(bytes32 _reason, uint256 _amount)
        public returns (bool);


    function tokensUnlockable(address _of, bytes32 _reason)
        public view returns (uint256 amount);

 
    function unlock(address _of)
        public returns (uint256 unlockableTokens);


    function getUnlockableTokens(address _of)
        public view returns (uint256 unlockableTokens);


}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function mint(address account, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128) {

        uint128 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint128 c = a - b;

        return c;
    }

    function sub(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {

        require(b <= a, errorMessage);
        uint128 c = a - b;

        return c;
    }

    function mul(uint128 a, uint128 b) internal pure returns (uint128) {

        if (a == 0) {
            return 0;
        }

        uint128 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint128 a, uint128 b) internal pure returns (uint128) {

        require(b > 0, "SafeMath: division by zero");
        uint128 c = a / b;

        return c;
    }

    function mod(uint128 a, uint128 b) internal pure returns (uint128) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64) {

        uint64 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint64 c = a - b;

        return c;
    }

    function sub(uint64 a, uint64 b, string memory errorMessage) internal pure returns (uint64) {

        require(b <= a, errorMessage);
        uint64 c = a - b;

        return c;
    }

    function mul(uint64 a, uint64 b) internal pure returns (uint64) {

        if (a == 0) {
            return 0;
        }

        uint64 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b > 0, "SafeMath: division by zero");
        uint64 c = a / b;

        return c;
    }

    function mod(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32) {

        uint32 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint32 c = a - b;

        return c;
    }

    function sub(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {

        require(b <= a, errorMessage);
        uint32 c = a - b;

        return c;
    }

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {

        if (a == 0) {
            return 0;
        }

        uint32 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {

        require(b > 0, "SafeMath: division by zero");
        uint32 c = a / b;

        return c;
    }

    function mod(uint32 a, uint32 b) internal pure returns (uint32) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity ^0.5.0;



contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}



pragma solidity 0.5.7;



contract PlotXToken is ERC20 {

    using SafeMath for uint256;

    mapping(address => uint256) public lockedForGV;

    string public name = "PLOT";
    string public symbol = "PLOT";
    uint8 public decimals = 18;
    address public operator;

    modifier onlyOperator() {

        require(msg.sender == operator, "Not operator");
        _;
    }

    constructor(uint256 _initialSupply, address _initialTokenHolder) public {
        _mint(_initialTokenHolder, _initialSupply);
        operator = _initialTokenHolder;
    }

    function changeOperator(address _newOperator)
        public
        onlyOperator
        returns (bool)
    {

        require(_newOperator != address(0), "New operator cannot be 0 address");
        operator = _newOperator;
        return true;
    }

    function burn(uint256 amount) public {

        _burn(msg.sender, amount);
    }

    function burnFrom(address from, uint256 value) public {

        _burnFrom(from, value);
    }

    function mint(address account, uint256 amount)
        public
        onlyOperator
        returns (bool)
    {

        _mint(account, amount);
        return true;
    }

    function transfer(address to, uint256 value) public returns (bool) {

        require(lockedForGV[msg.sender] < now, "Locked for governance"); // if not voted under governance
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {

        require(lockedForGV[from] < now, "Locked for governance"); // if not voted under governance
        _transferFrom(from, to, value);
        return true;
    }

    function lockForGovernanceVote(address _of, uint256 _period)
        public
        onlyOperator
    {

        if (_period.add(now) > lockedForGV[_of])
            lockedForGV[_of] = _period.add(now);
    }

    function isLockedForGV(address _of) public view returns (bool) {

        return (lockedForGV[_of] > now);
    }
}


pragma solidity 0.5.7;

contract IbLOTToken {

    function initiatebLOT(address _defaultMinter) external;

    function convertToPLOT(address _of, address _to, uint256 amount) public;

}



pragma solidity 0.5.7;





contract Vesting {


  using SafeMath for uint256;
  using SafeMath64 for uint64;
  PlotXToken public token;
  address public owner;

  uint constant internal SECONDS_PER_DAY = 1 days;

  event Allocated(address recipient, uint64 startTime, uint256 amount, uint64 vestingDuration, uint64 vestingPeriodInDays, uint _upfront);
  event TokensClaimed(address recipient, uint256 amountClaimed);

  struct Allocation {
    uint64 vestingDuration; 
    uint64 periodClaimed;  
    uint64 periodInDays; 
    uint64 startTime; 
    uint256 amount;
    uint256 totalClaimed;
  }
  mapping (address => Allocation) public tokenAllocations;

  modifier onlyOwner {

    require(msg.sender == owner, "unauthorized");
    _;
  }

  modifier nonZeroAddress(address x) {

    require(x != address(0), "token-zero-address");
    _;
  }

  constructor(address _token, address _owner) public
  nonZeroAddress(_token)
  nonZeroAddress(_owner)
  {
    token = PlotXToken(_token);
    owner = _owner;
  }

  function addTokenVesting(address[] memory _recipient, uint64[] memory _startTime, uint256[] memory _amount, uint64[] memory _vestingDuration, uint64[] memory _vestingPeriodInDays, uint256[] memory _upFront) public 
  onlyOwner
  {


    require(_recipient.length == _startTime.length, "Different array length");
    require(_recipient.length == _amount.length, "Different array length");
    require(_recipient.length == _vestingDuration.length, "Different array length");
    require(_recipient.length == _vestingPeriodInDays.length, "Different array length");
    require(_recipient.length == _upFront.length, "Different array length");

    for(uint i=0;i<_recipient.length;i++) {
      require(tokenAllocations[_recipient[i]].startTime == 0, "token-user-grant-exists");
      require(_startTime[i] != 0, "should be positive");
      uint256 amountVestedPerPeriod = _amount[i].div(_vestingDuration[i]);
      require(amountVestedPerPeriod > 0, "0-amount-vested-per-period");

      token.transferFrom(owner, address(this), _amount[i].add(_upFront[i]));

      Allocation memory _allocation = Allocation({
        startTime: _startTime[i], 
        amount: _amount[i],
        vestingDuration: _vestingDuration[i],
        periodInDays: _vestingPeriodInDays[i],
        periodClaimed: 0,
        totalClaimed: 0
      });
      tokenAllocations[_recipient[i]] = _allocation;

      if(_upFront[i] > 0) {
        token.transfer(_recipient[i], _upFront[i]);
      }

      emit Allocated(_recipient[i], _startTime[i], _amount[i], _vestingDuration[i], _vestingPeriodInDays[i], _upFront[i]);
    }
  }

  function claimVestedTokens() public {


    require(!token.isLockedForGV(msg.sender),"Locked for GV vote");
    uint64 periodVested;
    uint256 amountVested;
    (periodVested, amountVested) = calculateVestingClaim(msg.sender);
    require(amountVested > 0, "token-zero-amount-vested");

    Allocation storage _tokenAllocated = tokenAllocations[msg.sender];
    _tokenAllocated.periodClaimed = _tokenAllocated.periodClaimed.add(periodVested);
    _tokenAllocated.totalClaimed = _tokenAllocated.totalClaimed.add(amountVested);
    
    require(token.transfer(msg.sender, amountVested), "token-sender-transfer-failed");
    emit TokensClaimed(msg.sender, amountVested);
  }

  function calculateVestingClaim(address _recipient) public view returns (uint64, uint256) {

    Allocation memory _tokenAllocations = tokenAllocations[_recipient];

    if (now < _tokenAllocations.startTime) {
      return (0, 0);
    }

    uint256 elapsedTime = now.sub(_tokenAllocations.startTime);
    uint64 elapsedDays = uint64(elapsedTime / SECONDS_PER_DAY);
    
    
    if (elapsedDays >= _tokenAllocations.vestingDuration.mul(_tokenAllocations.periodInDays)) {
      uint256 remainingTokens = _tokenAllocations.amount.sub(_tokenAllocations.totalClaimed);
      return (_tokenAllocations.vestingDuration.sub(_tokenAllocations.periodClaimed), remainingTokens);
    } else {
      uint64 elapsedPeriod = elapsedDays.div(_tokenAllocations.periodInDays);
      uint64 periodVested = elapsedPeriod.sub(_tokenAllocations.periodClaimed);
      uint256 amountVestedPerPeriod = _tokenAllocations.amount.div(_tokenAllocations.vestingDuration);
      uint256 amountVested = uint(periodVested).mul(amountVestedPerPeriod);
      return (periodVested, amountVested);
    }
  }

  function unclaimedAllocation(address _user) external view returns(uint) {

    return tokenAllocations[_user].amount.sub(tokenAllocations[_user].totalClaimed);
  }
}


pragma solidity 0.5.7;

contract Iupgradable {


    function setMasterAddress() public;

}


pragma solidity 0.5.7;

contract IToken {


    function decimals() external view returns(uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function mint(address account, uint256 amount) external returns (bool);

    
    function burn(uint256 amount) external;


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


}


pragma solidity 0.5.7;

contract IMarketRegistry {


    enum MarketType {
      HourlyMarket,
      DailyMarket,
      WeeklyMarket
    }
    address public owner;
    address public tokenController;
    address public marketUtility;
    bool public marketCreationPaused;

    mapping(address => bool) public isMarket;
    function() external payable{}

    function marketDisputeStatus(address _marketAddress) public view returns(uint _status);


    function burnDisputedProposalTokens(uint _proposaId) external;


    function isWhitelistedSponsor(address _address) public view returns(bool);


    function transferAssets(address _asset, address _to, uint _amount) external;


    function initiate(address _defaultAddress, address _marketConfig, address _plotToken, address payable[] memory _configParams) public;


    function createGovernanceProposal(string memory proposalTitle, string memory description, string memory solutionHash, bytes memory actionHash, uint256 stakeForDispute, address user, uint256 ethSentToPool, uint256 tokenSentToPool, uint256 proposedValue) public {

    }

    function setUserGlobalPredictionData(address _user,uint _value, uint _predictionPoints, address _predictionAsset, uint _prediction,uint _leverage) public{

    }

    function callClaimedEvent(address _user , uint[] memory _reward, address[] memory predictionAssets, uint incentives, address incentiveToken) public {

    }

    function callMarketResultEvent(uint[] memory _totalReward, uint _winningOption, uint _closeValue, uint roundId) public {

    }
}



pragma solidity 0.5.7;


contract IMaster {

    mapping(address => bool) public whitelistedSponsor;
    function dAppToken() public view returns(address);

    function isInternal(address _address) public view returns(bool);

    function getLatestAddress(bytes2 _module) public view returns(address);

    function isAuthorizedToGovern(address _toCheck) public view returns(bool);

}


contract Governed {


    address public masterAddress; // Name of the dApp, needs to be set by contracts inheriting this contract

    modifier onlyAuthorizedToGovern() {

        IMaster ms = IMaster(masterAddress);
        require(ms.getLatestAddress("GV") == msg.sender, "Not authorized");
        _;
    }

    function isAuthorizedToGovern(address _toCheck) public view returns(bool) {

        IMaster ms = IMaster(masterAddress);
        return (ms.getLatestAddress("GV") == _toCheck);
    } 

}


pragma solidity 0.5.7;


contract Proxy {

    function () external payable {
        address _impl = implementation();
        require(_impl != address(0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
            }
    }

    function implementation() public view returns (address);

}


pragma solidity 0.5.7;



contract UpgradeabilityProxy is Proxy {

    event Upgraded(address indexed implementation);

    bytes32 private constant IMPLEMENTATION_POSITION = keccak256("org.govblocks.proxy.implementation");

    constructor() public {}

    function implementation() public view returns (address impl) {

        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
            impl := sload(position)
        }
    }

    function _setImplementation(address _newImplementation) internal {

        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
        sstore(position, _newImplementation)
        }
    }

    function _upgradeTo(address _newImplementation) internal {

        address currentImplementation = implementation();
        require(currentImplementation != _newImplementation);
        _setImplementation(_newImplementation);
        emit Upgraded(_newImplementation);
    }
}


pragma solidity 0.5.7;



contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    bytes32 private constant PROXY_OWNER_POSITION = keccak256("org.govblocks.proxy.owner");

    constructor(address _implementation) public {
        _setUpgradeabilityOwner(msg.sender);
        _upgradeTo(_implementation);
    }

    modifier onlyProxyOwner() {

        require(msg.sender == proxyOwner());
        _;
    }

    function proxyOwner() public view returns (address owner) {

        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            owner := sload(position)
        }
    }

    function transferProxyOwnership(address _newOwner) public onlyProxyOwner {

        require(_newOwner != address(0));
        _setUpgradeabilityOwner(_newOwner);
        emit ProxyOwnershipTransferred(proxyOwner(), _newOwner);
    }

    function upgradeTo(address _implementation) public onlyProxyOwner {

        _upgradeTo(_implementation);
    }

    function _setUpgradeabilityOwner(address _newProxyOwner) internal {

        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            sstore(position, _newProxyOwner)
        }
    }
}



pragma solidity  0.5.7;










contract TokenController is IERC1132, Governed, Iupgradable {

    using SafeMath for uint256;

    event Burned(address indexed member, bytes32 lockedUnder, uint256 amount);

    string internal constant ALREADY_LOCKED = "Tokens already locked";
    string internal constant NOT_LOCKED = "No tokens locked";
    string internal constant AMOUNT_ZERO = "Amount can not be 0";

    uint internal smLockPeriod;

    bool internal constructorCheck;

    PlotXToken public token;
    IMarketRegistry public marketRegistry;
    IbLOTToken public bLOTToken;
    Vesting public vesting;

    modifier onlyAuthorized {

        require(marketRegistry.isMarket(msg.sender), "Not authorized");
        _;
    }

    function setMasterAddress() public {

        OwnedUpgradeabilityProxy proxy =  OwnedUpgradeabilityProxy(address(uint160(address(this))));
        require(msg.sender == proxy.proxyOwner(),"Sender is not proxy owner.");
        require(!constructorCheck, "Already ");
        smLockPeriod = 30 days;
        constructorCheck = true;
        masterAddress = msg.sender;
        IMaster ms = IMaster(msg.sender);
        token = PlotXToken(ms.dAppToken());
        bLOTToken = IbLOTToken(ms.getLatestAddress("BL"));
        marketRegistry = IMarketRegistry(address(uint160(ms.getLatestAddress("PL"))));
    }

    function initiateVesting(address _vesting) external {

        OwnedUpgradeabilityProxy proxy =  OwnedUpgradeabilityProxy(address(uint160(address(this))));
        require(msg.sender == proxy.proxyOwner(),"Sender is not proxy owner.");
        vesting = Vesting(_vesting);

    }

    function swapBLOT(address _of, address _to, uint256 _amount) public onlyAuthorized {

        bLOTToken.convertToPLOT(_of, _to, _amount);
    }

    function transferFrom(address _token, address _of, address _to, uint256 _amount) public onlyAuthorized {

        require(IToken(_token).transferFrom(_of, _to, _amount));
    }

    function updateUintParameters(bytes8 code, uint val) public onlyAuthorizedToGovern {

        if(code == "SMLP") { //Stake multiplier default lock period
            smLockPeriod = val.mul(1 days);
        }
    }

    function getUintParameters(bytes8 code) external view returns(bytes8 codeVal, uint val) {

        codeVal = code;
        if(code == "SMLP") {
            val= smLockPeriod.div(1 days);
        }
    }

    function lock(bytes32 _reason, uint256 _amount, uint256 _time)
        public
        returns (bool)
    {


        require((_reason == "SM" && _time == smLockPeriod) || _reason == "DR", "Unspecified reason or time");
        require(tokensLocked(msg.sender, _reason) == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);
        
        uint256 validUntil = _time.add(now); //solhint-disable-line

        lockReason[msg.sender].push(_reason);

        require(token.transferFrom(msg.sender, address(this), _amount));

        locked[msg.sender][_reason] = LockToken(_amount, validUntil, false);

        emit Locked(msg.sender, _reason, _amount, validUntil);
        return true;
    }

    function tokensLocked(address _of, bytes32 _reason)
        public
        view
        returns (uint256 amount)
    {

        if (!locked[_of][_reason].claimed)
            amount = locked[_of][_reason].amount;
    }
    
    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
        public
        view
        returns (uint256 amount)
    {

        if (locked[_of][_reason].validity > _time)
            amount = locked[_of][_reason].amount;
    }

    function totalBalanceOf(address _of)
        public
        view
        returns (uint256 amount)
    {

        amount = token.balanceOf(_of);

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            amount = amount.add(tokensLocked(_of, lockReason[_of][i]));
        }  
        amount = amount.add(vesting.unclaimedAllocation(_of)); 
    }   

    function totalSupply() public view returns (uint256)
    {

        return token.totalSupply();
    }

    function increaseLockAmount(bytes32 _reason, uint256 _amount)
        public
        returns (bool)
    {

        require(_reason == "SM" || _reason == "DR","Unspecified reason");
        require(_amount != 0, AMOUNT_ZERO);
        require(tokensLocked(msg.sender, _reason) > 0, NOT_LOCKED);
        require(token.transferFrom(msg.sender, address(this), _amount));

        locked[msg.sender][_reason].amount = locked[msg.sender][_reason].amount.add(_amount);
        if(_reason == "SM") {
            locked[msg.sender][_reason].validity = locked[msg.sender][_reason].validity.add(smLockPeriod);
        }
        
        emit Locked(msg.sender, _reason, locked[msg.sender][_reason].amount, locked[msg.sender][_reason].validity);
        return true;
    }

    function extendLock(bytes32 _reason, uint256 _time)
        public
        returns (bool)
    {

        if(_reason == "SM") {
            require(_time == smLockPeriod, "Must be smLockPeriod");
        }
        require(_time != 0, "Time cannot be zero");
        require(tokensLocked(msg.sender, _reason) > 0, NOT_LOCKED);

        locked[msg.sender][_reason].validity = locked[msg.sender][_reason].validity.add(_time);

        emit Locked(msg.sender, _reason, locked[msg.sender][_reason].amount, locked[msg.sender][_reason].validity);
        return true;
    }

    function tokensUnlockable(address _of, bytes32 _reason)
        public
        view
        returns (uint256 amount)
    {

        if (locked[_of][_reason].validity <= now && !locked[_of][_reason].claimed) //solhint-disable-line
            amount = locked[_of][_reason].amount;
    }

    function unlock(address _of)
        public
        returns (uint256 unlockableTokens)
    {

        uint256 lockedTokens;

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            lockedTokens = tokensUnlockable(_of, lockReason[_of][i]);
            if (lockedTokens > 0) {
                unlockableTokens = unlockableTokens.add(lockedTokens);
                locked[_of][lockReason[_of][i]].amount = locked[_of][lockReason[_of][i]].amount.sub(lockedTokens);
                locked[_of][lockReason[_of][i]].claimed = true;
                emit Unlocked(_of, lockReason[_of][i], lockedTokens);
            }
            if (locked[_of][lockReason[_of][i]].amount == 0) {
                _removeReason(_of, lockReason[_of][i]);
                i--;
            }
        }  

        if (unlockableTokens > 0)
            token.transfer(_of, unlockableTokens);
    }

    function getUnlockableTokens(address _of)
        public
        view
        returns (uint256 unlockableTokens)
    {

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            unlockableTokens = unlockableTokens.add(tokensUnlockable(_of, lockReason[_of][i]));
        }  
    }

    function lockForGovernanceVote(address _of, uint _period) public onlyAuthorizedToGovern {

        token.lockForGovernanceVote(_of, _period);
    }


    function burnLockedTokens(address _of, bytes32 _reason, uint256 _amount) public onlyAuthorizedToGovern
        returns (bool)
    {

        require(_reason == "DR","Reason must be DR");
        uint256 amount = tokensLockedAtTime(_of, _reason, now);
        require(amount >= _amount, "Tokens locked must be greater than amount");

        locked[_of][_reason].amount = locked[_of][_reason].amount.sub(_amount);
        if (locked[_of][_reason].amount == 0) {
            locked[_of][_reason].claimed = true;
            _removeReason(_of, _reason);
        }
        token.burn(_amount);
        emit Burned(_of, _reason, _amount);
    }

    function _removeReason(address _of, bytes32 _reason) internal {

        uint len = lockReason[_of].length;
        for (uint i = 0; i < len; i++) {
            if (lockReason[_of][i] == _reason) {
                lockReason[_of][i] = lockReason[_of][len.sub(1)];
                lockReason[_of].pop();
                break;
            }
        }   
    }

}



pragma solidity  0.5.7;


contract TokenControllerV2 is TokenController {


    modifier onlyAuthorized {

        require(marketRegistry.isMarket(msg.sender) || IMaster(masterAddress).isInternal(msg.sender), "Not authorized");
        _;
    }
}