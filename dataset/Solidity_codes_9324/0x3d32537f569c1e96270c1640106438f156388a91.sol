
pragma solidity 0.4.24;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract VestingVault12 {

    using SafeMath for uint256;
    using SafeMath for uint16;
    
    modifier onlyV12MultiSig {

        require(msg.sender == v12MultiSig, "not owner");
        _;
    }

    modifier onlyValidAddress(address _recipient) {

        require(_recipient != address(0) && _recipient != address(this) && _recipient != address(token), "not valid _recipient");
        _;
    }

    uint256 constant internal SECONDS_PER_DAY = 86400;

    struct Grant {
        uint256 startTime;
        uint256 amount;
        uint16 vestingDuration;
        uint16 vestingCliff;
        uint16 daysClaimed;
        uint256 totalClaimed;
        address recipient;
    }

    event GrantAdded(address indexed recipient, uint256 vestingId);
    event GrantTokensClaimed(address indexed recipient, uint256 amountClaimed);
    event GrantRemoved(address recipient, uint256 amountVested, uint256 amountNotVested);
    event ChangedMultisig(address multisig);

    ERC20 public token;
    
    mapping (uint256 => Grant) public tokenGrants;
    mapping (address => uint[]) private activeGrants;
    address public v12MultiSig;
    uint256 public totalVestingCount;

    constructor(ERC20 _token) public {
        require(address(_token) != address(0));
        v12MultiSig = msg.sender;
        token = _token;
    }
    
    function addTokenGrant(
        address _recipient,
        uint256 _startTime,
        uint256 _amount,
        uint16 _vestingDurationInDays,
        uint16 _vestingCliffInDays    
    ) 
        external
        onlyV12MultiSig
    {

        require(_vestingCliffInDays <= 10*365, "more than 10 years");
        require(_vestingDurationInDays <= 25*365, "more than 25 years");
        require(_vestingDurationInDays >= _vestingCliffInDays, "Duration < Cliff");
        
        uint256 amountVestedPerDay = _amount.div(_vestingDurationInDays);
        require(amountVestedPerDay > 0, "amountVestedPerDay > 0");

        require(token.transferFrom(v12MultiSig, address(this), _amount), "transfer failed");

        Grant memory grant = Grant({
            startTime: _startTime == 0 ? currentTime() : _startTime,
            amount: _amount,
            vestingDuration: _vestingDurationInDays,
            vestingCliff: _vestingCliffInDays,
            daysClaimed: 0,
            totalClaimed: 0,
            recipient: _recipient
        });
        tokenGrants[totalVestingCount] = grant;
        activeGrants[_recipient].push(totalVestingCount);
        emit GrantAdded(_recipient, totalVestingCount);
        totalVestingCount++;
    }

    function getActiveGrants(address _recipient) public view returns(uint256[]){

        return activeGrants[_recipient];
    }

    function calculateGrantClaim(uint256 _grantId) public view returns (uint16, uint256) {

        Grant storage tokenGrant = tokenGrants[_grantId];

        if (currentTime() < tokenGrant.startTime) {
            return (0, 0);
        }

        uint elapsedTime = currentTime().sub(tokenGrant.startTime);
        uint elapsedDays = elapsedTime.div(SECONDS_PER_DAY);
        
        if (elapsedDays < tokenGrant.vestingCliff) {
            return (uint16(elapsedDays), 0);
        }

        if (elapsedDays >= tokenGrant.vestingDuration) {
            uint256 remainingGrant = tokenGrant.amount.sub(tokenGrant.totalClaimed);
            return (tokenGrant.vestingDuration, remainingGrant);
        } else {
            uint16 daysVested = uint16(elapsedDays.sub(tokenGrant.daysClaimed));
            uint256 amountVestedPerDay = tokenGrant.amount.div(uint256(tokenGrant.vestingDuration));
            uint256 amountVested = uint256(daysVested.mul(amountVestedPerDay));
            return (daysVested, amountVested);
        }
    }

    function claimVestedTokens(uint256 _grantId) external {

        uint16 daysVested;
        uint256 amountVested;
        (daysVested, amountVested) = calculateGrantClaim(_grantId);
        require(amountVested > 0, "amountVested is 0");

        Grant storage tokenGrant = tokenGrants[_grantId];
        tokenGrant.daysClaimed = uint16(tokenGrant.daysClaimed.add(daysVested));
        tokenGrant.totalClaimed = uint256(tokenGrant.totalClaimed.add(amountVested));
        
        require(token.transfer(tokenGrant.recipient, amountVested), "no tokens");
        emit GrantTokensClaimed(tokenGrant.recipient, amountVested);
    }

    function removeTokenGrant(uint256 _grantId) 
        external 
        onlyV12MultiSig
    {

        Grant storage tokenGrant = tokenGrants[_grantId];
        address recipient = tokenGrant.recipient;
        uint16 daysVested;
        uint256 amountVested;
        (daysVested, amountVested) = calculateGrantClaim(_grantId);

        uint256 amountNotVested = (tokenGrant.amount.sub(tokenGrant.totalClaimed)).sub(amountVested);

        require(token.transfer(recipient, amountVested));
        require(token.transfer(v12MultiSig, amountNotVested));

        tokenGrant.startTime = 0;
        tokenGrant.amount = 0;
        tokenGrant.vestingDuration = 0;
        tokenGrant.vestingCliff = 0;
        tokenGrant.daysClaimed = 0;
        tokenGrant.totalClaimed = 0;
        tokenGrant.recipient = address(0);

        emit GrantRemoved(recipient, amountVested, amountNotVested);
    }

    function currentTime() private view returns(uint256) {

        return block.timestamp;
    }

    function tokensVestedPerDay(uint256 _grantId) public view returns(uint256) {

        Grant storage tokenGrant = tokenGrants[_grantId];
        return tokenGrant.amount.div(uint256(tokenGrant.vestingDuration));
    }

    function changeMultiSig(address _newMultisig) 
        external 
        onlyV12MultiSig
        onlyValidAddress(_newMultisig)
    {

        v12MultiSig = _newMultisig;
        emit ChangedMultisig(_newMultisig);
    }

}