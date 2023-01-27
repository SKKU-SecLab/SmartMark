


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



pragma solidity ^0.6.0;

library MerkleProof {

  function calculateRoot(bytes32[] memory leaves) internal pure returns(bytes32) {

    require(leaves.length > 0, "Cannot compute zero length");
    bytes32[] memory elements = leaves;
    bytes32[] memory nextLayer = new bytes32[]((elements.length+1)/2) ;
    while(elements.length > 1) {
      for(uint256 i = 0; i<elements.length;i+=2){
        bytes32 left;
        bytes32 right;
        if(i == elements.length - 1){
          left = elements[i];
          right = elements[i];
        }
        else if(elements[i] <= elements[i+1]){
          left = elements[i];
          right = elements[i+1];
        }
        else {
          left = elements[i+1];
          right = elements[i];
        }
        bytes32 elem = keccak256(abi.encodePacked(left,right));
        nextLayer[i/2] = elem;
      }
      elements = nextLayer;
      nextLayer = new bytes32[]((elements.length+1)/2);
    }
    return elements[0];

  }
  function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

    bytes32 computedHash = leaf;

    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];

      if (computedHash <= proofElement) {
        computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
      } else {
        computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
      }
    }

    return computedHash == root;
  }
}



pragma solidity ^0.6.6;

interface IStakeManager {

    function totalStakedAmount(address protocol) external view returns(uint256);

    function protocolAddress(uint64 id) external view returns(address);

    function protocolId(address protocol) external view returns(uint64);

    function initialize(address _armorMaster) external;

    function allowedCover(address _newProtocol, uint256 _newTotalCover) external view returns (bool);

    function subtractTotal(uint256 _nftId, address _protocol, uint256 _subtractAmount) external;

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

interface IClaimManager {

    function initialize(address _armorMaster) external;

    function transferNft(address _to, uint256 _nftId) external;

    function exchangeWithdrawal(uint256 _amount) external;

    function redeemClaim(address _protocol, uint256 _hackTime, uint256 _amount) external;

}




pragma solidity ^0.6.6;


contract PlanManager is ArmorModule, IPlanManager {

    
    using SafeMath for uint;
    
    uint256 constant private DENOMINATOR = 1000;
    
    mapping (address => Plan[]) public plans;

    mapping (bytes32 => ProtocolPlan) public protocolPlan;
    
    mapping (address => uint256) public override nftCoverPrice;
    
    mapping (address => uint256) public override totalUsedCover;
    
    mapping (address => uint256) public arShieldCover;
    mapping (address => uint256) public arShieldPlusCover;
    mapping (address => uint256) public coreCover;
    
    uint256 public arShieldPercent;
    uint256 public arShieldPlusPercent;
    uint256 public corePercent;
    
    mapping (address => uint256) public arShields;
    
    uint256 public override markup;

    modifier checkExpiry(address _user) {

        IBalanceManager balanceManager = IBalanceManager(getModule("BALANCE"));
        if(balanceManager.balanceOf(_user) == 0 ){
            balanceManager.expireBalance(_user);
        }
        _;
    }

    function initialize(
        address _armorMaster
    ) external override {

        initializeModule(_armorMaster);
        markup = 150;
        arShieldPercent = 350;
        arShieldPlusPercent = 350;
        corePercent = 300;
    }
    
    function getCurrentPlan(address _user) external view override returns(uint256 idx, uint128 start, uint128 end){

        if(plans[_user].length == 0){
            return(0,0,0);
        }
        Plan memory plan = plans[_user][plans[_user].length-1];
        
        if(plan.endTime < now){
            return(0,0,0);
        } else {
            idx = plans[_user].length - 1;
            start = plan.startTime;
            end = plan.endTime;
        }
    }

    function getProtocolPlan(address _user, uint256 _idx, address _protocol) external view returns(uint256 idx, uint64 protocolId, uint192 amount) {

        IStakeManager stakeManager = IStakeManager(getModule("STAKE"));
        uint256 length = plans[_user][_idx].length;
        for(uint256 i = 0; i<length; i++){
            ProtocolPlan memory protocol = protocolPlan[_hashKey(_user, _idx, i)];
            address addr = stakeManager.protocolAddress(protocol.protocolId);
            if(addr == _protocol){
                return (i, protocol.protocolId, protocol.amount);
            }
        }
        return(0,0,0);
    }

    function userCoverageLimit(address _user, address _protocol) external view override returns(uint256){

        IStakeManager stakeManager = IStakeManager(getModule("STAKE"));
        uint64 protocolId = stakeManager.protocolId(_protocol);
       
        uint256 idx = plans[_user].length - 1;
        uint256 currentCover = 0;
        if(idx != uint256(-1)){ 
            Plan memory plan = plans[_user][idx];
            uint256 length = uint256( plan.length );

            for (uint256 i = 0; i < length; i++) {
                ProtocolPlan memory protocol = protocolPlan[ _hashKey(_user, idx, i) ];
                if (protocol.protocolId == protocolId) currentCover = uint256( protocol.amount );
            }
        }

        uint256 extraCover = coverageLeft(_protocol);

        return extraCover.add(currentCover);
    }

    function updatePlan(address[] calldata _protocols, uint256[] calldata _coverAmounts)
      external
      override
      checkExpiry(msg.sender)
    {

        require(_protocols.length == _coverAmounts.length, "protocol and coverAmount length mismatch");
        require(_protocols.length <= 30, "You may not protect more than 30 protocols at once.");
        IBalanceManager balanceManager = IBalanceManager(getModule("BALANCE"));
        
        if(plans[msg.sender].length > 0){
          Plan storage lastPlan = plans[msg.sender][plans[msg.sender].length - 1];

          if(lastPlan.endTime > now) {
              _removeLatestTotals(msg.sender);
              lastPlan.endTime = uint64(now);
          }
        }

        _addNewTotals(_protocols, _coverAmounts);
        uint256 newPricePerSec;
        uint256 _markup = markup;
        
        for (uint256 i = 0; i < _protocols.length; i++) {
            require(nftCoverPrice[_protocols[i]] != 0, "Protocol price is zero");
            
            uint256 pricePerSec = nftCoverPrice[ _protocols[i] ].mul(_coverAmounts[i]);
            newPricePerSec = newPricePerSec.add(pricePerSec);
        }
        
        newPricePerSec = newPricePerSec.mul(_markup).div(1e18).div(100);
        
        if(newPricePerSec == 0){
            Plan memory newPlan;
            newPlan = Plan(uint64(now), uint64(-1), uint128(0));
            plans[msg.sender].push(newPlan);
            balanceManager.changePrice(msg.sender, 0);
            emit PlanUpdate(msg.sender, _protocols, _coverAmounts, uint64(-1));
            return;
        }

        uint256 endTime = balanceManager.balanceOf(msg.sender).div(newPricePerSec).add(block.timestamp);
        
        require(endTime >= block.timestamp.add(7 days), "Balance must be enough for 7 days of coverage.");
        
        Plan memory newPlan;
        newPlan = Plan(uint64(now), uint64(endTime), uint128(_protocols.length));
        plans[msg.sender].push(newPlan);
        
        for(uint256 i = 0;i<_protocols.length; i++){
            bytes32 key = _hashKey(msg.sender, plans[msg.sender].length - 1, i);
            uint64 protocolId = IStakeManager(getModule("STAKE")).protocolId(_protocols[i]);
            protocolPlan[key] = ProtocolPlan(protocolId, uint192(_coverAmounts[i]));
        }
        
        uint64 castPricePerSec = uint64(newPricePerSec);
        require(uint256(castPricePerSec) == newPricePerSec);
        IBalanceManager(getModule("BALANCE")).changePrice(msg.sender, castPricePerSec);

        emit PlanUpdate(msg.sender, _protocols, _coverAmounts, endTime);
    }

    function _removeLatestTotals(address _user) internal {

        Plan storage plan = plans[_user][plans[_user].length - 1];

        uint256 idx = plans[_user].length - 1;

        IRewardManagerV2 rewardManager = IRewardManagerV2(getModule("REWARDV2"));

        for (uint256 i = 0; i < plan.length; i++) {
            bytes32 key = _hashKey(_user, idx, i);
            ProtocolPlan memory protocol = protocolPlan[key];
            address protocolAddress = IStakeManager(getModule("STAKE")).protocolAddress(protocol.protocolId);
            totalUsedCover[protocolAddress] = totalUsedCover[protocolAddress].sub(uint256(protocol.amount));
            rewardManager.updateAllocPoint(protocolAddress, totalUsedCover[protocolAddress]);
            
            uint256 shield = arShields[_user];
            if (shield == 1) {
                arShieldCover[protocolAddress] = arShieldCover[protocolAddress].sub(protocol.amount);
            } else if (shield == 2) {
                arShieldPlusCover[protocolAddress] = arShieldPlusCover[protocolAddress].sub(protocol.amount);
            } else {
                coreCover[protocolAddress] = coreCover[protocolAddress].sub(protocol.amount);
            }   
        }
    }

    function _addNewTotals(address[] memory _newProtocols, uint256[] memory _newCoverAmounts) internal {

        IRewardManagerV2 rewardManager = IRewardManagerV2(getModule("REWARDV2"));

        for (uint256 i = 0; i < _newProtocols.length; i++) {
            
            (uint256 shield, uint256 allowed) = _checkBuyerAllowed(_newProtocols[i]);
            require(allowed >= _newCoverAmounts[i], "Exceeds allowed cover amount.");
            
            totalUsedCover[_newProtocols[i]] = totalUsedCover[_newProtocols[i]].add(_newCoverAmounts[i]);
            rewardManager.updateAllocPoint(_newProtocols[i], totalUsedCover[_newProtocols[i]]);

            if (shield == 1) {
                arShieldCover[_newProtocols[i]] = arShieldCover[_newProtocols[i]].add(_newCoverAmounts[i]);
            } else if (shield == 2) {
                arShieldPlusCover[_newProtocols[i]] = arShieldPlusCover[_newProtocols[i]].add(_newCoverAmounts[i]);
            } else {
                coreCover[_newProtocols[i]] = coreCover[_newProtocols[i]].add(_newCoverAmounts[i]);
            }
        }
    }

    function coverageLeft(address _protocol)
      public
      override
      view
    returns (uint256) {

        (/* uint256 shield */, uint256 allowed) = _checkBuyerAllowed(_protocol);
        return allowed;
    }
    
    function _checkBuyerAllowed(address _protocol)
      internal
      view
    returns (uint256, uint256)
    {

        uint256 totalAllowed = IStakeManager(getModule("STAKE")).totalStakedAmount(_protocol);
        uint256 shield = arShields[msg.sender];
            
        if (shield == 1) {
            uint256 currentCover = arShieldCover[_protocol];
            uint256 allowed = totalAllowed * arShieldPercent / DENOMINATOR;
            return (shield, allowed > currentCover ? allowed - currentCover : 0);
        } else if (shield == 2) {
            uint256 currentCover = arShieldPlusCover[_protocol];
            uint256 allowed = totalAllowed * arShieldPlusPercent / DENOMINATOR;
            return (shield, allowed > currentCover ? allowed - currentCover : 0);
        } else {
            uint256 currentCover = coreCover[_protocol];
            uint256 allowed = totalAllowed * corePercent / DENOMINATOR;
            return (shield, allowed > currentCover ? allowed - currentCover : 0);        
        }
    }
    
    function checkCoverage(address _user, address _protocol, uint256 _hackTime, uint256 _amount)
      external
      view
      override
      returns(uint256 index, bool check)
    {

        Plan[] storage planArray = plans[_user];
        
        for (int256 i = int256(planArray.length - 1); i >= 0; i--) {
            Plan storage plan = planArray[uint256(i)];
            if (_hackTime >= plan.startTime && _hackTime < plan.endTime) {
                for(uint256 j = 0; j< plan.length; j++){
                    bytes32 key = _hashKey(_user, uint256(i), j);
                    if(IStakeManager(getModule("STAKE")).protocolAddress(protocolPlan[key].protocolId) == _protocol){
                        return (uint256(i), _amount <= uint256(protocolPlan[key].amount));
                    }
                }
                return (uint256(i), false);
            }
        }
        return (uint256(-1), false);
    }

    function planRedeemed(address _user, uint256 _planIndex, address _protocol) 
      external 
      override 
      onlyModule("CLAIM")
    {

        Plan storage plan = plans[_user][_planIndex];
        require(plan.endTime <= now, "Cannot redeem active plan, update plan to redeem properly.");

        for (uint256 i = 0; i < plan.length; i++) {
            bytes32 key = _hashKey(_user,_planIndex,i);
            
            ProtocolPlan memory protocol = protocolPlan[key];
            address protocolAddress = IStakeManager(getModule("STAKE")).protocolAddress(protocol.protocolId);
            
            if (protocolAddress == _protocol) protocolPlan[key].amount = 0;
        }
    }

    function changePrice(address _protocol, uint256 _newPrice)
      external
      override
      onlyModule("STAKE")
    {

        nftCoverPrice[_protocol] = _newPrice;
    }

    function updateExpireTime(address _user, uint256 _expiry)
      external
      override
      onlyModule("BALANCE")
    {

        if (plans[_user].length == 0) return;
        Plan storage plan = plans[_user][plans[_user].length-1];
        if (_expiry <= block.timestamp) _removeLatestTotals(_user);
        plan.endTime = uint64(_expiry);
    }
    
    function _hashKey(address _user, uint256 _planIndex, uint256 _protoIndex)
      internal
      pure
    returns (bytes32)
    {

        return keccak256(abi.encodePacked("ARMORFI.PLAN.", _user, _planIndex, _protoIndex));
    }
    
    function adjustMarkup(uint256 _newMarkup)
      external
      onlyOwner
    {

        require(_newMarkup >= 100, "Markup must be at least 0 (100%).");
        markup = _newMarkup;
    }
    
    function adjustPercents(uint256 _newCorePercent, uint256 _newArShieldPercent, uint256 _newArShieldPlusPercent)
      external
      onlyOwner
    {

        require(_newCorePercent + _newArShieldPercent + _newArShieldPlusPercent == 1000, "Total allocation cannot be more than 100%.");
        corePercent = _newCorePercent;
        arShieldPercent = _newArShieldPercent;
        arShieldPlusPercent = _newArShieldPlusPercent;
    }
    
    function adjustShields(address[] calldata _shieldAddress, uint256[] calldata _shieldType)
      external
      onlyOwner
    {

        require(_shieldAddress.length == _shieldType.length, "Submitted arrays are not of equal length.");
        for (uint256 i = 0; i < _shieldAddress.length; i++) {
            arShields[_shieldAddress[i]] = _shieldType[i];
        }
    }

    function forceAdjustTotalUsedCover(address[] calldata _protocols, uint256[] calldata _usedCovers) external onlyOwner {

        IRewardManagerV2 rewardManager = IRewardManagerV2(getModule("REWARDV2"));

        for(uint256 i = 0; i<_protocols.length; i++){
            totalUsedCover[_protocols[i]] = _usedCovers[i];
            coreCover[_protocols[i]] = _usedCovers[i];
            rewardManager.updateAllocPoint(_protocols[i], totalUsedCover[_protocols[i]]);
        }
    }
}