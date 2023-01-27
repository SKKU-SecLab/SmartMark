


pragma solidity ^0.6.0;

interface IArmorMaster {

    function registerModule(bytes32 _key, address _module) external;

    function getModule(bytes32 _key) external view returns(address);

    function keep() external;

}



pragma solidity ^0.6.6;

contract Ownable {

    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initializeOwnable() internal {

        require(_owner == address(0), "already initialized");
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }


    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "msg.sender is not owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }

    function transferOwnership(address newOwner) public onlyOwner {

        _pendingOwner = newOwner;
    }

    function receiveOwnership() public {

        require(msg.sender == _pendingOwner, "only pending owner can call this function");
        _transferOwnership(_pendingOwner);
        _pendingOwner = address(0);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private __gap;
}



pragma solidity ^0.6.6;
library Bytes32 {

    function toString(bytes32 x) internal pure returns (string memory) {

        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint256 j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint256 j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}



pragma solidity ^0.6.0;

contract ArmorModule {

    IArmorMaster internal _master;

    using Bytes32 for bytes32;

    modifier onlyOwner() {

        require(msg.sender == Ownable(address(_master)).owner(), "only owner can call this function");
        _;
    }

    modifier doKeep() {

        _master.keep();
        _;
    }

    modifier onlyModule(bytes32 _module) {

        string memory message = string(abi.encodePacked("only module ", _module.toString()," can call this function"));
        require(msg.sender == getModule(_module), message);
        _;
    }

    modifier onlyModules(bytes32 _moduleOne, bytes32 _moduleTwo) {

        string memory message = string(abi.encodePacked("only module ", _moduleOne.toString()," or ", _moduleTwo.toString()," can call this function"));
        require(msg.sender == getModule(_moduleOne) || msg.sender == getModule(_moduleTwo), message);
        _;
    }

    function initializeModule(address _armorMaster) internal {

        require(address(_master) == address(0), "already initialized");
        require(_armorMaster != address(0), "master cannot be zero address");
        _master = IArmorMaster(_armorMaster);
    }

    function changeMaster(address _newMaster) external onlyOwner {

        _master = IArmorMaster(_newMaster);
    }

    function getModule(bytes32 _key) internal view returns(address) {

        return _master.getModule(_key);
    }
}



pragma solidity ^0.6.6;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}



pragma solidity ^0.6.6;

contract BalanceExpireTracker {

    
    using SafeMath for uint64;
    using SafeMath for uint256;
    
    uint160 private constant EMPTY = uint160(address(0));
    
    uint64 public constant BUCKET_STEP = 3 days;

    mapping(uint64 => Bucket) public checkPoints;

    struct Bucket {
        uint160 head;
        uint160 tail;
    }

    uint160 public head;
    uint160 public tail;

    mapping(uint160 => ExpireMetadata) public infos; 
    
    struct ExpireMetadata {
        uint160 next; // zero if there is no further information
        uint160 prev;
        uint64 expiresAt;
    }

    function expired() internal view returns(bool) {

        if(infos[head].expiresAt == 0) {
            return false;
        }

        if(infos[head].expiresAt <= uint64(now)){
            return true;
        }

        return false;
    }

    function push(uint160 expireId, uint64 expiresAt) 
      internal 
    {

        require(expireId != EMPTY, "info id address(0) cannot be supported");

        if (infos[expireId].expiresAt > 0) pop(expireId);

        uint64 bucket = uint64( (expiresAt.div(BUCKET_STEP)).mul(BUCKET_STEP) );
        if (head == EMPTY) {
            head = expireId;
            tail = expireId;
            checkPoints[bucket] = Bucket(expireId, expireId);
            infos[expireId] = ExpireMetadata(EMPTY,EMPTY,expiresAt);
            
            return;
        }
            
        if (infos[head].expiresAt >= expiresAt) {
            infos[head].prev = expireId;
            infos[expireId] = ExpireMetadata(head, EMPTY,expiresAt);
            head = expireId;
            
            Bucket storage b = checkPoints[bucket];
            b.head = expireId;
                
            if(b.tail == EMPTY) {
                b.tail = expireId;
            }
                
            return;
        }
          
        if (infos[tail].expiresAt <= expiresAt) {
            infos[tail].next = expireId;
            infos[expireId] = ExpireMetadata(EMPTY,tail,expiresAt);
            tail = expireId;
            
            Bucket storage b = checkPoints[bucket];
            b.tail = expireId;
            
            if(b.head == EMPTY) {
              b.head = expireId;
            }
            
            return;
        }
          
        if (checkPoints[bucket].head != EMPTY) {
            uint160 cursor = checkPoints[bucket].head;
        
            while(infos[cursor].expiresAt < expiresAt){
                cursor = infos[cursor].next;
            }
        
            infos[expireId] = ExpireMetadata(cursor, infos[cursor].prev, expiresAt);
            infos[infos[cursor].prev].next = expireId;
            infos[cursor].prev = expireId;
        
            Bucket storage b = checkPoints[bucket];
            
            if (infos[b.head].prev == expireId){
                b.head = expireId;
            }
            
            if (infos[b.tail].next == expireId){
                b.tail = expireId;
            }
        } else {
            uint64 prevCursor = uint64( bucket.sub(BUCKET_STEP) );
            
            while(checkPoints[prevCursor].tail == EMPTY){
              prevCursor = uint64( prevCursor.sub(BUCKET_STEP) );
            }
    
            uint160 prev = checkPoints[prevCursor].tail;
            uint160 next = infos[prev].next;
    
            infos[expireId] = ExpireMetadata(next,prev,expiresAt);
            infos[prev].next = expireId;
            infos[next].prev = expireId;
    
            checkPoints[bucket].head = expireId;
            checkPoints[bucket].tail = expireId;
        }
    }

    function pop(uint160 expireId) internal {

        uint64 expiresAt = infos[expireId].expiresAt;
        uint64 bucket = uint64( (expiresAt.div(BUCKET_STEP)).mul(BUCKET_STEP) );
        if(checkPoints[bucket].head == EMPTY){
            return;
        }
        for(uint160 cursor = checkPoints[bucket].head; infos[cursor].expiresAt <= expiresAt; cursor = infos[cursor].next) {
            ExpireMetadata memory info = infos[cursor];
            if(info.expiresAt == expiresAt && cursor == expireId) {
                if(head == cursor) {
                    head = info.next;
                }
                if(tail == cursor) {
                    tail = info.prev;
                }
                if(checkPoints[bucket].head == cursor){
                    if(infos[info.next].expiresAt.div(BUCKET_STEP) == bucket.div(BUCKET_STEP)){
                        checkPoints[bucket].head = info.next;
                    } else {
                        delete checkPoints[bucket];
                    }
                } else if(checkPoints[bucket].tail == cursor){
                    checkPoints[bucket].tail = info.prev;
                }
                infos[info.prev].next = info.next;
                infos[info.next].prev = info.prev;
                delete infos[cursor];
                return;
            }
        }
        return;
    }

    uint256[50] private __gap;
}



pragma solidity ^0.6.6;

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



pragma solidity ^0.6.6;

interface IBalanceManager {

  event Deposit(address indexed user, uint256 amount);
  event Withdraw(address indexed user, uint256 amount);
  event Loss(address indexed user, uint256 amount);
  event PriceChange(address indexed user, uint256 price);
  event AffiliatePaid(address indexed affiliate, address indexed referral, uint256 amount, uint256 timestamp);
  event ReferralAdded(address indexed affiliate, address indexed referral, uint256 timestamp);
  function expireBalance(address _user) external;

  function deposit(address _referrer) external payable;

  function withdraw(uint256 _amount) external;

  function initialize(address _armormaster, address _devWallet) external;

  function balanceOf(address _user) external view returns (uint256);

  function perSecondPrice(address _user) external view returns(uint256);

  function changePrice(address user, uint64 _newPricePerSec) external;

}



pragma solidity ^0.6.6;

interface IPlanManager {

  struct Plan {
      uint64 startTime;
      uint64 endTime;
      uint128 length;
  }
  
  struct ProtocolPlan {
      uint64 protocolId;
      uint192 amount;
  }
    
  event PlanUpdate(address indexed user, address[] protocols, uint256[] amounts, uint256 endTime);
  function userCoverageLimit(address _user, address _protocol) external view returns(uint256);

  function markup() external view returns(uint256);

  function nftCoverPrice(address _protocol) external view returns(uint256);

  function initialize(address _armorManager) external;

  function changePrice(address _scAddress, uint256 _pricePerAmount) external;

  function updatePlan(address[] calldata _protocols, uint256[] calldata _coverAmounts) external;

  function checkCoverage(address _user, address _protocol, uint256 _hacktime, uint256 _amount) external view returns (uint256, bool);

  function coverageLeft(address _protocol) external view returns(uint256);

  function getCurrentPlan(address _user) external view returns(uint256 idx, uint128 start, uint128 end);

  function updateExpireTime(address _user, uint256 _expiry) external;

  function planRedeemed(address _user, uint256 _planIndex, address _protocol) external;

  function totalUsedCover(address _scAddress) external view returns (uint256);

}



pragma solidity ^0.6.6;

interface IRewardDistributionRecipient {

    function notifyRewardAmount(uint256 reward) payable external;

}



pragma solidity ^0.6.6;

interface IRewardManager is IRewardDistributionRecipient {

  function initialize(address _rewardToken, address _stakeManager) external;

  function stake(address _user, uint256 _coverPrice, uint256 _nftId) external;

  function withdraw(address _user, uint256 _coverPrice, uint256 _nftId) external;

  function getReward(address payable _user) external;

}



pragma solidity ^0.6.6;

interface IRewardManagerV2 {

    function initialize(address _armorMaster, uint256 _rewardCycleBlocks)
        external;


    function deposit(
        address _user,
        address _protocol,
        uint256 _amount,
        uint256 _nftId
    ) external;


    function withdraw(
        address _user,
        address _protocol,
        uint256 _amount,
        uint256 _nftId
    ) external;


    function updateAllocPoint(address _protocol, uint256 _allocPoint) external;


    function initPool(address _protocol) external;


    function notifyRewardAmount() external payable;

}



pragma solidity ^0.6.6;

interface IUtilizationFarm is IRewardDistributionRecipient {

  function initialize(address _rewardToken, address _stakeManager) external;

  function stake(address _user, uint256 _coverPrice) external;

  function withdraw(address _user, uint256 _coverPrice) external;

  function getReward(address payable _user) external;

}




contract BalanceManager is ArmorModule, IBalanceManager, BalanceExpireTracker {


    using SafeMath for uint256;
    using SafeMath for uint128;

    address public devWallet;

    struct Balance {
        uint64 lastTime;
        uint64 perSecondPrice;
        uint128 lastBalance;
    }
    
    mapping (address => Balance) public balances;

    mapping (address => address) public referrers;

    uint128 public devPercent;

    uint128 public refPercent;

    uint128 public govPercent;

    uint128 public constant DENOMINATOR = 1000;

    bool public ufOn;

    mapping (address => bool) public arShields;
     
    modifier onceAnHour {

        require(block.timestamp >= balances[msg.sender].lastTime.add(1 hours), "You must wait an hour after your last update to withdraw.");
        _;
    }

    modifier update(address _user)
    {

        uint256 _oldBal = _updateBalance(_user);
        _;
        _updateBalanceActions(_user, _oldBal);
    }

    function keep() external {

        for (uint256 i = 0; i < 2; i++) {
        
            if (infos[head].expiresAt != 0 && infos[head].expiresAt <= now) {
                address oldHead = address(head);
                uint256 oldBal = _updateBalance(oldHead);
                _updateBalanceActions(oldHead, oldBal);
            } else return;
            
        }
    }

    function expireBalance(address _user) external override update(_user) {

        require(balanceOf(_user) == 0, "Cannot expire when balance > 0");
    }

    function initialize(address _armorMaster, address _devWallet)
      external
      override
    {

        initializeModule(_armorMaster);
        devWallet = _devWallet;
        devPercent = 0;     // 0 %
        refPercent = 25;    // 2.5%
        govPercent = 0;     // 0%
        ufOn = true;
    }

    function deposit(address _referrer) 
      external
      payable
      override
      update(msg.sender)
    {

        if ( referrers[msg.sender] == address(0) ) {
            referrers[msg.sender] = _referrer != address(0) ? _referrer : devWallet;
            emit ReferralAdded(_referrer, msg.sender, block.timestamp);
        }
        
        require(msg.value > 0, "No Ether was deposited.");

        balances[msg.sender].lastBalance = uint128(balances[msg.sender].lastBalance.add(msg.value));
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount)
      external
      override
      onceAnHour
      update(msg.sender)
    {

        require(_amount > 0, "Must withdraw more than 0.");
        Balance memory balance = balances[msg.sender];

        if (balance.lastBalance > _amount) {
            balance.lastBalance = uint128( balance.lastBalance.sub(_amount) );
        } else {
            _amount = balance.lastBalance;
            balance.lastBalance = 0;
        }
        
        balances[msg.sender] = balance;
        msg.sender.transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    }

    function balanceOf(address _user)
      public
      view
      override
    returns (uint256)
    {

        Balance memory balance = balances[_user];

        uint256 lastBalance = balance.lastBalance;

        uint256 timeElapsed = block.timestamp.sub(balance.lastTime);
        uint256 cost = timeElapsed.mul(balance.perSecondPrice);

        uint256 newBalance;
        if (lastBalance > cost) newBalance = lastBalance.sub(cost);
        else newBalance = 0;

        return newBalance;
    }

    function releaseFunds()
      public
    {

       uint256 govBalance = balances[getModule("GOVSTAKE")].lastBalance;
       if (govBalance >= 1 ether / 10) {
           IRewardManager(getModule("GOVSTAKE")).notifyRewardAmount{value: govBalance}(govBalance);
           balances[getModule("GOVSTAKE")].lastBalance = 0;
       }
       
       uint256 rewardBalance = balances[getModule("REWARDV2")].lastBalance.add(balances[getModule("REWARD")].lastBalance);
       if (rewardBalance >= 1 ether / 10) {
           IRewardManagerV2(getModule("REWARDV2")).notifyRewardAmount{value: rewardBalance}();
           balances[getModule("REWARD")].lastBalance = 0;
           balances[getModule("REWARDV2")].lastBalance = 0;
       }
    }

    function perSecondPrice(address _user)
      external
      override
      view
    returns(uint256)
    {

        Balance memory balance = balances[_user];
        return balance.perSecondPrice;
    }
    
    function changePrice(address _user, uint64 _newPrice)
      external
      override
      onlyModule("PLAN")
    {

        _updateBalance(_user);
        _priceChange(_user, _newPrice);
        if (_newPrice > 0) _adjustExpiry(_user, balances[_user].lastBalance.div(_newPrice).add(block.timestamp));
        else _adjustExpiry(_user, block.timestamp);
    }
    
    function _updateBalance(address _user)
      internal
      returns (uint256 oldBalance)
    {

        Balance memory balance = balances[_user];

        oldBalance = balance.lastBalance;
        uint256 newBalance = balanceOf(_user);

        uint256 loss = oldBalance.sub(newBalance);
    
        _payPercents(_user, uint128(loss));

        balance.lastBalance = uint128(newBalance);
        balance.lastTime = uint64(block.timestamp);
        emit Loss(_user, loss);
        
        balances[_user] = balance;
    }

    function _updateBalanceActions(address _user, uint256 _oldBal)
      internal
    {

        Balance memory balance = balances[_user];
        if (_oldBal != balance.lastBalance && balance.perSecondPrice > 0) {
            _notifyBalanceChange(_user, balance.lastBalance, balance.perSecondPrice);
            _adjustExpiry(_user, balance.lastBalance.div(balance.perSecondPrice).add(block.timestamp));
        }
        if (balance.lastBalance == 0 && _oldBal != 0) {
            _priceChange(_user, 0);
        }
    }
    

    function _priceChange(address _user, uint64 _newPrice) 
      internal 
    {

        Balance memory balance = balances[_user];
        uint64 originalPrice = balance.perSecondPrice;
        
        if(originalPrice == _newPrice) {
            return;
        }

        if (ufOn && !arShields[_user]) {
            if(originalPrice > _newPrice) {
                IUtilizationFarm(getModule("UFB")).withdraw(_user, originalPrice.sub(_newPrice));
            } else {
                IUtilizationFarm(getModule("UFB")).stake(_user, _newPrice.sub(originalPrice));
            } 
        }
        
        balances[_user].perSecondPrice = _newPrice;
        emit PriceChange(_user, _newPrice);
    }
    
    function _adjustExpiry(address _user, uint256 _newExpiry)
      internal
    {

        if (_newExpiry == block.timestamp) {
            BalanceExpireTracker.pop(uint160(_user));
        } else {
            BalanceExpireTracker.push(uint160(_user), uint64(_newExpiry));
        }
    }
    
    function _notifyBalanceChange(address _user, uint256 _newBalance, uint256 _newPerSec) 
      internal
    {

        uint256 expiry = _newBalance.div(_newPerSec).add(block.timestamp);
        IPlanManager(getModule("PLAN")).updateExpireTime(_user, expiry); 
    }
    
    function _payPercents(address _user, uint128 _charged)
      internal
    {

        uint128 refAmount = referrers[_user] != address(0) ? _charged * refPercent / DENOMINATOR : 0;
        uint128 devAmount = _charged * devPercent / DENOMINATOR;
        uint128 govAmount = _charged * govPercent / DENOMINATOR;
        uint128 nftAmount = uint128( _charged.sub(refAmount).sub(devAmount).sub(govAmount) );
        
        if (refAmount > 0) {
            balances[ referrers[_user] ].lastBalance = uint128( balances[ referrers[_user] ].lastBalance.add(refAmount) );
            emit AffiliatePaid(referrers[_user], _user, refAmount, block.timestamp);
        }
        if (devAmount > 0) balances[devWallet].lastBalance = uint128( balances[devWallet].lastBalance.add(devAmount) );
        if (govAmount > 0) balances[getModule("GOVSTAKE")].lastBalance = uint128( balances[getModule("GOVSTAKE")].lastBalance.add(govAmount) );
        if (nftAmount > 0) balances[getModule("REWARDV2")].lastBalance = uint128( balances[getModule("REWARDV2")].lastBalance.add(nftAmount) );
    }
    
    function changeRefPercent(uint128 _newPercent)
      external
      onlyOwner
    {

        require(_newPercent <= DENOMINATOR, "new percent cannot be bigger than DENOMINATOR");
        refPercent = _newPercent;
    }
    
    function changeGovPercent(uint128 _newPercent)
      external
      onlyOwner
    {

        require(_newPercent <= DENOMINATOR, "new percent cannot be bigger than DENOMINATOR");
        govPercent = _newPercent;
    }
    
    function changeDevPercent(uint128 _newPercent)
      external
      onlyOwner
    {

        require(_newPercent <= DENOMINATOR, "new percent cannot be bigger than DENOMINATOR");
        devPercent = _newPercent;
    }
    
    function toggleUF()
      external
      onlyOwner
    {

        ufOn = !ufOn;
    }
    
    function toggleShield(address _shield)
      external
      onlyOwner
    {

        arShields[_shield] = !arShields[_shield];
    }

    function resetExpiry(uint160[] calldata _idxs) external onlyOwner {

        for(uint256 i = 0; i<_idxs.length; i++) {
            require(infos[_idxs[i]].expiresAt != 0, "not in linkedlist");
            BalanceExpireTracker.pop(_idxs[i]);
            BalanceExpireTracker.push(_idxs[i], infos[_idxs[i]].expiresAt);
        }
    }

    function _resetBucket(uint64 _bucket, uint160 _head, uint160 _tail) internal {

        require(_bucket % BUCKET_STEP == 0, "INVALID BUCKET");

        require(
            infos[infos[_tail].next].expiresAt >= _bucket + BUCKET_STEP &&
            infos[_tail].expiresAt < _bucket + BUCKET_STEP &&
            infos[_tail].expiresAt >= _bucket,
            "tail is not tail");
        require(
            infos[infos[_head].prev].expiresAt < _bucket &&
            infos[_head].expiresAt < _bucket + BUCKET_STEP &&
            infos[_head].expiresAt >= _bucket,
            "head is not head");
        checkPoints[_bucket].tail = _tail;
        checkPoints[_bucket].head = _head;
    }

    function resetBuckets(uint64[] calldata _buckets, uint160[] calldata _heads, uint160[] calldata _tails) external onlyOwner{

        for(uint256 i = 0 ; i < _buckets.length; i++){
            _resetBucket(_buckets[i], _heads[i], _tails[i]);
        }
    }

    function manualUpdate(address[] calldata _users)
      external
    {

        require(msg.sender == armorKeeper, "Only keeper may call this.");
        for (uint256 i = 0; i < _users.length; i++) {
            uint256 oldBal = _updateBalance(_users[i]);
            _updateBalanceActions(_users[i], oldBal);
        }
    }

    function changeKeeper(address _newKeeper)
      external
      onlyOwner
    {

        armorKeeper = _newKeeper;
    }

    address public armorKeeper;

}