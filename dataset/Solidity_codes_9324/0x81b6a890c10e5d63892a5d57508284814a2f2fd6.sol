pragma solidity 0.5.17;

contract EternalStorage {


  mapping(bytes32 => bool) internal boolStorage;
  mapping(bytes32 => address) internal addressStorage;
  mapping(bytes32 => string) internal stringStorage;
  mapping(bytes32 => bytes) internal bytesStorage;

  mapping(bytes32 => bytes1) internal bytes1Storage;
  mapping(bytes32 => bytes2) internal bytes2Storage;
  mapping(bytes32 => bytes4) internal bytes4Storage;
  mapping(bytes32 => bytes8) internal bytes8Storage;
  mapping(bytes32 => bytes16) internal bytes16Storage;
  mapping(bytes32 => bytes32) internal bytes32Storage;
  
  mapping(bytes32 => int8) internal int8Storage;
  mapping(bytes32 => int16) internal int16Storage;
  mapping(bytes32 => int32) internal int32Storage;
  mapping(bytes32 => int64) internal int64Storage;
  mapping(bytes32 => int128) internal int128Storage;
  mapping(bytes32 => int256) internal int256Storage;
  
  mapping(bytes32 => uint8) internal uint8Storage;
  mapping(bytes32 => uint16) internal uint16Storage;
  mapping(bytes32 => uint32) internal uint32Storage;
  mapping(bytes32 => uint64) internal uint64Storage;
  mapping(bytes32 => uint128) internal uint128Storage;
  mapping(bytes32 => uint256) internal uint256Storage;


}pragma solidity 0.5.17;


contract UpgradeableProxy is EternalStorage {

    
  function setAdmin() external {

      require(msg.sender ==admin(), 'only admin can call this function');
      uint256 sbTime = uint256Storage[keccak256('proxy.speedbump.useAfterTime')];
      require(now > sbTime, "this speed bump cannot be used yet");
        require(sbTime > 0, "use after time cannot be 0");
      addressStorage[keccak256('proxy.admin')] = addressStorage[keccak256('proxy.speedbump.admin')];
       addressStorage[keccak256('proxy.speedbump.admin')] = address(0);
  }
  
  function setImplementation() external {

      require(msg.sender ==admin(), 'only admin can call this function');
      uint256 sbTime = uint256Storage[keccak256('proxy.speedbump.useAfterTime')];
      require(now > sbTime, "this speed bump cannot be used yet");
      require(sbTime > 0, "use after time cannot be 0");
      addressStorage[keccak256('proxy.implementation')] = addressStorage[keccak256('proxy.speedbump.implementation')]; 
      addressStorage[keccak256('proxy.speedbump.implementation')] = address(0); 
  }
  
  function changeProxyVariables(address nextAdmin, address nextImplementation) external {

      require(msg.sender == admin(), 'only admin can call this function');
        addressStorage[keccak256('proxy.speedbump.admin')] = nextAdmin;
        addressStorage[keccak256('proxy.speedbump.implementation')] = nextImplementation;
        uint256Storage[keccak256('proxy.speedbump.useAfterTime')] = now + (speedBumpHours()*1 hours);
  }

  function initializeNow() internal {

      boolStorage[keccak256('proxy.initialized')] = true;    
  }
  
    function speedBumpHours(uint16 newSpeedBumpHours) internal {

        uint16Storage[keccak256('proxy.speedBumpHours')] = newSpeedBumpHours;
    }
  
  function admin() public view returns (address);

 
  function implementation() public view returns (address) {

      return addressStorage[keccak256('proxy.implementation')];    
  }
  
  function initialized() public view returns (bool) {

      return boolStorage[keccak256('proxy.initialized')];    
  }
  
    function speedBumpHours() public view returns (uint16);

  
    
}pragma solidity 0.5.17;


contract TreasuryBase is UpgradeableProxy {

    
        bytes constant private treasurysFactory1 = '1.treasurysFactory';
        bytes constant private treasurysRuleList1 = '1.treasurysRuleList';
        bytes constant private treasurysDeposit1 = '1.treasuryDeposit';
        bytes constant private QNTAddress1 = '1.QNTAddress';
        bytes constant private operatorAddress1 = '1.operatorAddress';
        bytes constant private circuitBreakerOn1 = '1.circuitBreakerOn';
        bytes constant private mappDisputeFeeMultipler1 = '1.mappDisputeFeeMultipler';
        bytes constant private commissionDivider1 = '1.commissionDivider';
        bytes constant private  treasuryPenaltyMultipler1 = '1.treasuryPenaltyMultipler';
        bytes constant private gatewayPenaltyMultipler1 = '1.gatewayPenaltyMultipler';

        function treasurysFactory(address newTreasurysFactory) internal {

            addressStorage[keccak256(treasurysFactory1)] = newTreasurysFactory;
        } 
        
        
        function treasurysRuleList(address newTreasurysRuleList) internal {

            addressStorage[keccak256(treasurysRuleList1)] = newTreasurysRuleList;
        } 

        function treasurysDeposit(address newTreasuryDeposit) internal {

            addressStorage[keccak256(treasurysDeposit1)] = newTreasuryDeposit;
        }
        
        function QNTAddress(address newQNTAddress) internal {

            addressStorage[keccak256(QNTAddress1)] = newQNTAddress;
        }
        
        function operatorAddress(address newOperator) internal {

            addressStorage[keccak256(operatorAddress1)] = newOperator;
        }
        
        function circuitBreakerOn(bool newCircuitBreakerOn) internal {

            boolStorage[keccak256(circuitBreakerOn1)] = newCircuitBreakerOn;
        }
        
        function mappDisputeFeeMultipler(uint16 newMappDisputeFeeMultipler) internal {

            uint16Storage[keccak256(mappDisputeFeeMultipler1)] = newMappDisputeFeeMultipler;
        }
        
 
        function commissionDivider(uint16 neCommissionDivider) internal {

            uint16Storage[keccak256(commissionDivider1)] = neCommissionDivider;
        }

        function treasuryPenaltyMultipler(uint16 newTreasuryPenaltyMultipler) internal {

            uint16Storage[keccak256(treasuryPenaltyMultipler1)] = newTreasuryPenaltyMultipler;
        }

        function gatewayPenaltyMultipler(uint16 newGatewayPenaltyMultipler) internal {

            uint16Storage[keccak256(gatewayPenaltyMultipler1)] = newGatewayPenaltyMultipler;
        }

      function admin() public view returns (address) {

          return addressStorage[keccak256('proxy.admin')];   
      }
    
        function speedBumpHours() public view returns (uint16){

            return uint16Storage[keccak256('proxy.speedBumpHours')];
        }
     
        function treasurysFactory() public view returns (address){

            return addressStorage[keccak256(treasurysFactory1)];
        } 
        
        function treasurysRuleList() public view returns (address){

            return addressStorage[keccak256(treasurysRuleList1)];
        } 


        function treasurysDeposit() public view returns (address){

            return addressStorage[keccak256(treasurysDeposit1)];
        }
        
        function QNTAddress() public view returns (address){

            return addressStorage[keccak256(QNTAddress1)];
        }
        
        function operatorAddress() public view returns (address){

            return addressStorage[keccak256(operatorAddress1)];
        }
        
        function circuitBreakerOn() public view returns (bool){

            return boolStorage[keccak256(circuitBreakerOn1)];
        }
        
        function mappDisputeFeeMultipler() public view returns (uint16){

            return uint16Storage[keccak256(mappDisputeFeeMultipler1)];
        }
        
 
        function commissionDivider() public view returns (uint16){

            return uint16Storage[keccak256(commissionDivider1)];
        }

        function treasuryPenaltyMultipler() public view returns (uint16){

            return uint16Storage[keccak256(treasuryPenaltyMultipler1)];
        }

        function gatewayPenaltyMultipler() public view returns (uint16){

            return uint16Storage[keccak256(gatewayPenaltyMultipler1)];
        }
    
}pragma solidity 0.5.17;


contract FactoryBase is UpgradeableProxy {

    
    bytes constant private mappChannels1 = '1.mappChannels';
    bytes constant private mappDeposits1 = '1.mappDeposits';
    bytes constant private mappCount1 = '1.mappCount';
    bytes constant private gatewayChannels1 = '1.gatewayChannels';
    bytes constant private gatewayDeposits1 = '1.gatewayDeposits';
    bytes constant private gatewayCount1 = '1.gatewayCount';
    
    function mappChannel(address mappOperator, address channel) internal {

        addressStorage[keccak256(abi.encodePacked(mappChannels1,mappOperator))] = channel;
    }
    
    function mappDeposit(address mappOperator, address depositContract) internal {

        addressStorage[keccak256(abi.encodePacked(mappDeposits1,mappOperator))] = depositContract;
    }
    
    function mappCount(uint32 count) internal {

        uint32Storage[keccak256(abi.encodePacked(mappCount1))] = count;
    }
    
    function gatewayChannel(address gatewayOperator, address channel) internal {

        addressStorage[keccak256(abi.encodePacked(gatewayChannels1,gatewayOperator))] = channel;
    }
    
    function gatewayDeposit(address gatewayOperator, address deposit) internal {

        addressStorage[keccak256(abi.encodePacked(gatewayDeposits1,gatewayOperator))] =  deposit;
    }
    
    function gatewayCount(uint32 count) internal {

        uint32Storage[keccak256(abi.encodePacked(gatewayCount1))] =  count;
    }

    function mappChannel(address mappOperator) public view returns (address){

        return addressStorage[keccak256(abi.encodePacked(mappChannels1,mappOperator))];
    }
    
    function mappDeposit(address mappOperator) public view returns (address){

        return addressStorage[keccak256(abi.encodePacked(mappDeposits1,mappOperator))];
    }
    
    function mappCount() public view returns (uint32) {

        return uint32Storage[keccak256(abi.encodePacked(mappCount1))];
    }
    
    function gatewayChannel(address gatewayOperator) public view returns (address){

        return addressStorage[keccak256(abi.encodePacked(gatewayChannels1,gatewayOperator))];
    }
    
    function gatewayDeposit(address gatewayOperator) public view returns (address){

        return addressStorage[keccak256(abi.encodePacked(gatewayDeposits1,gatewayOperator))];
    }
    
    function gatewayCount() public view returns (uint32) {

        return uint32Storage[keccak256(abi.encodePacked(gatewayCount1))];
    }
    
}

contract EscrowedDepositAbstract {

    
    
    function deductDeposit(uint256 tokenAmount, address ruleAddress) external;


}pragma solidity 0.5.17;


contract RuleLists is UpgradeableProxy {

    
    bytes constant private mappRules1 = '1.mappRules';
    bytes constant private treasuryRules1 = '1.treasuryRules';
    bytes constant private gatewayRules1 = '1.gatewayRules';
    bytes constant private mappRuleIndex1 = '1.mappRuleIndex';
    bytes constant private treasuryRuleIndex1 = '1.treasuryRuleIndex';
    bytes constant private gatewayRuleIndex1 = '1.gatewayRuleIndex';
    bytes constant private treasuryAddress1 = '1.treasuryaddress';
    bytes constant private speedBumpRule1 = '1.speedBump.rule';
    bytes constant private speedBumpTimeCreated1 = '1.speedBump.timeCreated';
    bytes constant private speedBumpWaitingHours1 = '1.speedBump.waitingHours';
    
    event addedRule(string stakeholder, uint256 index);
    event usedRule(uint16 ruleIndex, address slashed, uint256 value);
    event updatedSpeedBump(address rule, uint8 speedBumpIndex);
    
    modifier onlyTreasury(){

        TreasuryBase t = TreasuryBase(treasuryAddress());
        if (msg.sender != t.operatorAddress()){
            revert("Only the treasury contract's operator address can modify this contract's associated storage");
        } else {
            _; // otherwise carry on with the computation
        }
    }
    
    function initialize (address linkedTreasuryContract) external {
        require(!initialized(),"contract can only be initialised once");
       addressStorage[keccak256(treasuryAddress1)] = linkedTreasuryContract;
        initializeNow(); //sets this contract to initialized
    }
    
    function addRule(uint8 speedBumpIndex) external onlyTreasury() {

        require(((speedBumpIndex >= 0)&&(speedBumpIndex <= 2)), "Speed bump index must between 0 and 2 inclusive");
        require(speedBumpTimeCreated(speedBumpIndex) > 0, "Time created must be >0 (to stop replays of the speed bump)");
        require(now > speedBumpTimeCreated(speedBumpIndex) + (speedBumpWaitingHours(speedBumpIndex)*1 hours), "The speed bump time period must have passed");
        if (speedBumpIndex == 0){
            mappRules(speedBumpRule(0));
            deleteSpeedBump(0);
            emit addedRule("mapps", mappRuleIndex());
        } else if (speedBumpIndex == 1){
            treasuryRules(speedBumpRule(1));
            deleteSpeedBump(1);
            emit addedRule("treasury", treasuryRuleIndex());
        } else if (speedBumpIndex == 2){
            gatewayRules(speedBumpRule(2));
            deleteSpeedBump(2);
            emit addedRule("gateways", gatewayRuleIndex());
        }
    }
 
    function updateSpeedBump(string calldata stakeholder, address rule) external onlyTreasury() {

        if (keccak256(abi.encodePacked(stakeholder)) == keccak256(abi.encodePacked("mapp"))){
            addSpeedBump(rule, 0);
            emit updatedSpeedBump(rule,0);
        } else if (keccak256(abi.encodePacked(stakeholder)) == keccak256(abi.encodePacked("treasury"))){
            addSpeedBump(rule, 1);
            emit updatedSpeedBump(rule,1);
        } else if (keccak256(abi.encodePacked(stakeholder)) == keccak256(abi.encodePacked("gateway"))){
            addSpeedBump(rule, 2);
            emit updatedSpeedBump(rule,2);
        } else {
            revert("The rule needs to be for a mapp, treasury or gateway");
        }   
    }

    function useRule(address toSlash, uint multiple, uint16 ruleIndex) external {

        uint256 multipler;
        require(((ruleIndex >= 0)&&(ruleIndex <= 2)), "Rule index must between 0 and 2 inclusive");
        TreasuryBase t = TreasuryBase(treasuryAddress());
        FactoryBase f = FactoryBase(t.treasurysFactory());
        address escrowedDepositAddr;
        if (ruleIndex == 0){
            require (mappRules(ruleIndex) == msg.sender, "Calling address must be a mapp rule");
            multipler = t.mappDisputeFeeMultipler();
            escrowedDepositAddr = f.mappDeposit(toSlash);
        } else if (ruleIndex == 1){
            require (treasuryRules(ruleIndex) == msg.sender, "Calling address must be a treasury rule"); 
            multipler = t.treasuryPenaltyMultipler();
            escrowedDepositAddr = t.treasurysDeposit();
        } else if (ruleIndex == 2){
            require (gatewayRules(ruleIndex) == msg.sender, "Calling address must be a gateway rule");
            multipler = t.gatewayPenaltyMultipler();
            escrowedDepositAddr = f.gatewayDeposit(toSlash);
        }
        uint256 penalty = multipler*multiple;
        require(penalty > 0, "penalty <= 0");
        EscrowedDepositAbstract(escrowedDepositAddr).deductDeposit(penalty, msg.sender);
        emit usedRule(ruleIndex, toSlash, penalty);
    }

    function mappRules(address newRule) internal {

        uint16 index = mappRuleIndex();
        index += 1;
        addressStorage[keccak256(abi.encodePacked(mappRules1,index))] = newRule;
        uint16Storage[keccak256(mappRuleIndex1)] = index; 
    }

    function treasuryRules(address newRule) internal {

        uint16 index = treasuryRuleIndex();
        index += 1;
        addressStorage[keccak256(abi.encodePacked(treasuryRules1,index))] = newRule;
        uint16Storage[keccak256(treasuryRuleIndex1)] = index;
    }

    function gatewayRules(address newRule) internal {

        uint16 index = gatewayRuleIndex();
        index += 1;
        addressStorage[keccak256(abi.encodePacked(gatewayRules1,index))] = newRule;
        uint16Storage[keccak256(treasuryRuleIndex1)] = index;
    }
 
    function addSpeedBump(address newRule, uint8 speedBumpIndex) internal {

        TreasuryBase t = TreasuryBase(treasuryAddress());
        addressStorage[keccak256(abi.encodePacked(speedBumpRule1,speedBumpIndex))] = newRule;
        uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,speedBumpIndex))]  = now;
        uint16Storage[keccak256(abi.encodePacked(speedBumpWaitingHours1,speedBumpIndex))] = t.speedBumpHours();
    }

    function deleteSpeedBump(uint8 speedBumpIndex) internal {

        addressStorage[keccak256(abi.encodePacked(speedBumpRule1,speedBumpIndex))] = address(0x0);
        uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,speedBumpIndex))]  = 0;
        uint16Storage[keccak256(abi.encodePacked(speedBumpWaitingHours1,speedBumpIndex))] = 0;
    }
    
    function admin() public view returns (address) {

        TreasuryBase t = TreasuryBase(treasuryAddress());
        return t.admin();   
    }
      
    function speedBumpHours() public view returns (uint16){

        TreasuryBase t = TreasuryBase(treasuryAddress());
        return t.speedBumpHours();
    }
 
    function treasuryAddress() public view returns (address) {

        return addressStorage[keccak256(treasuryAddress1)];
    }
    
    function speedBumpRule(uint8 speedBumpIndex) public view returns (address) {

        return addressStorage[keccak256(abi.encodePacked(speedBumpRule1,speedBumpIndex))];
    }
    
    function speedBumpTimeCreated(uint8 speedBumpIndex) public view returns (uint256) {

        return uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,speedBumpIndex))];
    }
    
    function speedBumpWaitingHours(uint8 speedBumpIndex) public view returns (uint16) {

        return uint16Storage[keccak256(abi.encodePacked(speedBumpWaitingHours1,speedBumpIndex))];
    }

    function mappRules(uint16 index) public view returns (address){

        return addressStorage[keccak256(abi.encodePacked(mappRules1,index))];
    }

    function treasuryRules(uint16 index) public view returns (address){

        return addressStorage[keccak256(abi.encodePacked(treasuryRules1,index))];
    }

    function gatewayRules(uint16 index) public view returns (address){

        return addressStorage[keccak256(abi.encodePacked(gatewayRules1,index))];
    }

    function mappRuleIndex() public view returns (uint16){

        return uint16Storage[keccak256(mappRuleIndex1)];
    }

    function treasuryRuleIndex() public view returns (uint16){

        return uint16Storage[keccak256(treasuryRuleIndex1)];
    }

    function gatewayRuleIndex() public view returns (uint16){

        return uint16Storage[keccak256(gatewayRuleIndex1)];
    }
    
    
}