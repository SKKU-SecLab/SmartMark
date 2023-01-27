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


contract Treasury is TreasuryBase {


        bytes constant private speedBumpAddresses1 = '1.speedBump.addresses';
        bytes constant private speedBumpUint16s1 = '1.speedBump.uint16s';
        bytes constant private speedBumpCircuitBreaker1 = '1.speedBump.circuitBreaker';
        bytes constant private speedBumpTimeCreated1 = '1.speedBump.timeCreated';
        bytes constant private speedBumpNextSBHours1 = '1.speedBump.nextSBHours';
        bytes constant private speedBumpCurrentSBHours1 = '1.speedBump.currentSBHours';

        event connectedContracts(address factory, address ruleList, address escrowedDeposit);
        event updatedTreasuryVariables(uint16 mappDisputeFeeMultipler, uint16 commissionDivider, uint16 gatewayPenaltyMultipler, uint16 treasuryPenaltyMultipler);
        event updatedTreasuryMainVariables(address newWithdrawalAddress, address newOperator, bool circuitBreaker);
        event updatedTreasuryFunctionVerification(string verificationDetails, string locationOfDetails);
        event updatedSpeedBump(uint speedBumpIndex,uint256 timeCreated,uint256 speedBumpHours);
        
        modifier onlyOperator(){

            if (msg.sender != operatorAddress()){
                revert("Only the operator address of this contract can modify its associated storage");
            } else {
                _; //means carry on with the computation
            }
        }
        
        function initialize (address thisQNTAddress, address thisOperatorAddress, uint16 mappDisputeFee, uint16 commission, uint16 treasuryPenalty, uint16 gatewayPenalty, uint16 speedBumpTime) external {
            require(!initialized(),"contract can only be initialised once");
            QNTAddress(thisQNTAddress);
            operatorAddress(thisOperatorAddress);
            circuitBreakerOn(false);
            mappDisputeFeeMultipler(mappDisputeFee);
            commissionDivider(commission);
            treasuryPenaltyMultipler(treasuryPenalty);
            gatewayPenaltyMultipler(gatewayPenalty);
            speedBumpHours(speedBumpTime);
            addressStorage[keccak256('proxy.admin')] = thisOperatorAddress;
            initializeNow(); //sets this contract to initialized
        }

        function updateTreasuryContracts() external onlyOperator() {

            uint8 sb = 0;
            uint256 sBTimeCreated = speedBumpTimeCreated(sb);
            require(sBTimeCreated > 0, "Time created must be >0 (to stop replays of the speed bump)");
            require(now > sBTimeCreated + (speedBumpCurrentSBHours(sb)*1 hours), "The speed bump time period must have passed");
            treasurysFactory(speedBumpAddresses(sb, 0));
            treasurysRuleList(speedBumpAddresses(sb, 1));
            treasurysDeposit(speedBumpAddresses(sb, 2));
            speedBumpAddresses(sb, 0, address(0));
            speedBumpAddresses(sb, 1, address(0));
            speedBumpAddresses(sb, 2, address(0));
            speedBumpTimeCreated(sb,0);
            speedBumpCurrentSBHours(sb,0);
            emit connectedContracts(treasurysFactory(), treasurysRuleList(), treasurysDeposit());
        }
        
        function updateTreasuryFeeVariables() external onlyOperator() {

            uint8 sb = 1;
            uint256 sBTimeCreated = speedBumpTimeCreated(sb);
            require(sBTimeCreated > 0, "Time created must be >0 (to stop replays of the speed bump)");
            require(now > sBTimeCreated + (speedBumpCurrentSBHours(sb)*1 hours), "The speed bump time period must have passed");
            mappDisputeFeeMultipler(speedBumpUint16s(sb, 0));
            commissionDivider(speedBumpUint16s(sb, 1));
            treasuryPenaltyMultipler(speedBumpUint16s(sb, 2));
            gatewayPenaltyMultipler(speedBumpUint16s(sb, 3));
            speedBumpUint16s(sb, 0, 0);
            speedBumpUint16s(sb, 1, 0);
            speedBumpUint16s(sb, 2, 0);
            speedBumpUint16s(sb, 3, 0);
            speedBumpTimeCreated(sb,0);
            speedBumpCurrentSBHours(sb,0);
            emit updatedTreasuryVariables(mappDisputeFeeMultipler(),commissionDivider(),gatewayPenaltyMultipler(),treasuryPenaltyMultipler());
        }
        
        function updateTreasuryMainVariables() external onlyOperator() {

            uint8 sb = 2;
            uint256 sBTimeCreated = speedBumpTimeCreated(sb);
            require(sBTimeCreated > 0, "Time created must be >0 (to stop replays of the speed bump)");
            require(now > sBTimeCreated + (speedBumpCurrentSBHours(sb)*1 hours), "The speed bump time period must have passed");            
            QNTAddress(speedBumpAddresses(sb, 0));
            operatorAddress(speedBumpAddresses(sb, 1));
            circuitBreakerOn(speedBumpCircuitBreaker(sb));
            speedBumpHours(speedBumpNextSBHours(sb));
            speedBumpAddresses(sb, 0, address(0));
            speedBumpAddresses(sb, 1, address(0));
            speedBumpCircuitBreaker(sb,false);
            speedBumpTimeCreated(sb,0);
            speedBumpCurrentSBHours(sb,0);
            speedBumpNextSBHours(sb,0);
            emit updatedTreasuryMainVariables(QNTAddress(),operatorAddress(),circuitBreakerOn());
        }

        function speedBumpMain(address[] calldata addresses, uint16 newSpeedBumpHours, bool circuitBreaker) external onlyOperator() {

            uint8 sb = 2;
            addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,sb, int8(0)))] = addresses[0];
            addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,sb, int8(1)))] = addresses[1];
            uint16Storage[keccak256(abi.encodePacked(speedBumpNextSBHours1,sb))] = newSpeedBumpHours;
            boolStorage[keccak256(abi.encodePacked(speedBumpCircuitBreaker1,sb))] = circuitBreaker;
            uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,sb))] = now;
            uint16Storage[keccak256(abi.encodePacked(speedBumpCurrentSBHours1,sb))] = speedBumpHours();
            emit updatedSpeedBump(sb,now,speedBumpHours());
        }
 
        function speedBumpFee(uint16[] calldata uint16s) external onlyOperator() {

            uint8 sb = 1;
            uint16Storage[keccak256(abi.encodePacked(speedBumpUint16s1,sb,int8(0)))] = uint16s[0];
            uint16Storage[keccak256(abi.encodePacked(speedBumpUint16s1,sb,int8(1)))] = uint16s[1];
            uint16Storage[keccak256(abi.encodePacked(speedBumpUint16s1,sb,int8(2)))] = uint16s[2];
            uint16Storage[keccak256(abi.encodePacked(speedBumpUint16s1,sb,int8(3)))] = uint16s[3];
            uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,sb))] = now;
            uint16Storage[keccak256(abi.encodePacked(speedBumpCurrentSBHours1,sb))] = speedBumpHours();
            emit updatedSpeedBump(sb,now,speedBumpHours());
        }
        
        function speedBumpContract(address[] calldata addresses) external onlyOperator() {

            uint8 sb = 0;
            addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,sb, int8(0)))] = addresses[0];
            addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,sb, int8(1)))] = addresses[1];
            addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,sb, int8(2)))] = addresses[2];
            uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,sb))] = now;
            uint16Storage[keccak256(abi.encodePacked(speedBumpCurrentSBHours1,sb))] = speedBumpHours();
            emit updatedSpeedBump(sb,now,speedBumpHours());
        }
        
        function readFunctionPenaltyMultipler(bool gateway) external view returns (uint256) {

            if (gateway == true){
                return gatewayPenaltyMultipler();
            } else {
                return treasuryPenaltyMultipler();
            }
        }
        
        function speedBumpAddresses(uint8 index, uint8 addressIndex, address newAddress) internal {

            addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,index, addressIndex))] = newAddress;
        }
        
        function speedBumpUint16s(uint8 index, uint8 uint16Index, uint16 newUint16) internal {

            uint16Storage[keccak256(abi.encodePacked(speedBumpUint16s1,index,uint16Index))] = newUint16;
        } 
        
        function speedBumpCircuitBreaker(uint8 index, bool newCircuitBreaker) internal {

            boolStorage[keccak256(abi.encodePacked(speedBumpCircuitBreaker1,index))] = newCircuitBreaker;
        } 
        
        function speedBumpTimeCreated(uint8 index, uint256 timeCreated) internal {

            uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,index))] = timeCreated;
        } 
        
        function speedBumpNextSBHours(uint8 index, uint16 newSpeedBumpHours) internal {

            uint16Storage[keccak256(abi.encodePacked(speedBumpNextSBHours1,index))] = newSpeedBumpHours;
        }

        function speedBumpCurrentSBHours(uint8 index, uint16 newCurrentSBHours) internal {

            uint16Storage[keccak256(abi.encodePacked(speedBumpCurrentSBHours1,index))] = newCurrentSBHours;
        }
        
        
        function speedBumpAddresses(uint8 index, uint8 addressIndex) public view returns (address){

            return addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,index,addressIndex))];
        }
        
        function speedBumpUint16s(uint8 index, uint8 uint16Index) public view returns (uint16){

            return uint16Storage[keccak256(abi.encodePacked(speedBumpUint16s1,index,uint16Index))];
        } 
        
        function speedBumpCircuitBreaker(uint8 index) public view returns (bool){

            return boolStorage[keccak256(abi.encodePacked(speedBumpCircuitBreaker1,index))];
        } 

        function speedBumpTimeCreated(uint8 index) public view returns (uint256){

            return uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,index))];
        } 
        
        function speedBumpNextSBHours(uint8 index) public view returns (uint16){

            return uint16Storage[keccak256(abi.encodePacked(speedBumpNextSBHours1,index))];
        }
    
        function speedBumpCurrentSBHours(uint8 index) public view returns (uint16){

            return uint16Storage[keccak256(abi.encodePacked(speedBumpCurrentSBHours1,index))];
        }

}