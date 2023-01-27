pragma solidity ^0.5.0;

interface ERC20Interface {

 
    function totalSupply() external view  returns (uint256 supply);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function transfer(address _to, uint256 _value) external returns (bool success);


    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);


    function approve(address _spender, uint256 _value) external returns (bool success);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


}pragma solidity 0.5.17;

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


contract EscrowedDeposit  is UpgradeableProxy {


    bytes constant private treasuryAddress1 = '1.treasuryaddress';
    bytes constant private speedBumpQNTToWithdraw1 = '1.speedBump.QNTToWithdraw';
    bytes constant private speedBumpTimeCreated1 = '1.speedBump.timeCreated';
    bytes constant private speedBumpWaitingHours1 = '1.speedBump.waitingHours';
    ERC20Interface constant private QNTContract = ERC20Interface(0x4a220E6096B25EADb88358cb44068A3248254675); 
 
    event depositDeducted(uint256 claimedQNT, address receiver, uint256 remainingQNT, address ruleAddress);
    event depositReturned(uint256 returnedQNT);
    event updatedSpeedBump(uint256 QNTToWithdraw,uint16 speedBumpHours);

    
    function initialize(address linkedTreasuryContract) external {

        require(!initialized(),"contract can only be initialised once");
        addressStorage[keccak256(treasuryAddress1)] = linkedTreasuryContract;
        initializeNow(); //sets this contract to initialized
    }
    
    function deductDeposit(uint256 tokenAmount, address ruleAddress, address receiver) external {

        TreasuryBase t = TreasuryBase(treasuryAddress());
        require(msg.sender == t.treasurysRuleList(), "This function can only be called by the associated rule list contract");
        uint256 startingBalance = QNTBalance();
        if (tokenAmount > startingBalance){
            QNTContract.transfer(receiver, startingBalance);   
            emit depositDeducted(startingBalance,receiver,0,ruleAddress);
        } else {
            QNTContract.transfer(receiver, tokenAmount);
            emit depositDeducted(tokenAmount,receiver,QNTBalance(),ruleAddress);
        }
    }

    function withdrawDeposit() external {

        TreasuryBase t = TreasuryBase(treasuryAddress());
        uint256 sBTimeCreated = speedBumpTimeCreated();
      require(msg.sender == t.operatorAddress(), "Can only be called by the treasury operator");
      require(sBTimeCreated > 0, "Time created must be >0 (to stop replays of the speed bump)");
      require(now > sBTimeCreated + (speedBumpWaitingHours()*1 hours), "The speed bump time period must have passed");
      uint256 QNTToWithdraw = speedBumpQNTToWithdraw();
      if (QNTToWithdraw > 0){
          speedBumpQNTToWithdraw(0);
          speedBumpTimeCreated(0);
          speedBumpWaitingHours(0);
          address receiver = t.QNTAddress();
          uint256 startingBalance = QNTBalance();
          if (QNTToWithdraw > startingBalance){ 
            QNTContract.transfer(receiver, startingBalance);  
            emit depositReturned(startingBalance); 
          } else {
            QNTContract.transfer(receiver, QNTToWithdraw);     
            emit depositReturned(QNTToWithdraw); 
          }
      }
    }
    
    function updateSpeedBump(uint256 QNTToWithdraw) external {

        TreasuryBase t = TreasuryBase(treasuryAddress());
        require(msg.sender == t.operatorAddress(), "This function can only be called by the treasury operator");
        require(QNTBalance() >= QNTToWithdraw, "There is not enough QNT in the escrowed deposit");
        speedBumpQNTToWithdraw(QNTToWithdraw);
        speedBumpTimeCreated(now);
        uint16 sbHours = t.speedBumpHours();
        speedBumpWaitingHours(sbHours);
        emit updatedSpeedBump(QNTToWithdraw,sbHours);
    }
    
    function speedBumpQNTToWithdraw(uint256 QNTToWithdraw) internal {

        uint256Storage[keccak256(speedBumpQNTToWithdraw1)] = QNTToWithdraw;
    }
    
    function speedBumpTimeCreated(uint256 timeCreated) internal {

        uint256Storage[keccak256(speedBumpTimeCreated1)] = timeCreated;
    }
    
    function speedBumpWaitingHours(uint16 currentSBHours) internal {

        uint16Storage[keccak256(speedBumpWaitingHours1)] = currentSBHours;
    }

    function admin() public view returns (address) {

        TreasuryBase t = TreasuryBase(treasuryAddress());
        return t.admin();   
    }
    
    function speedBumpHours() public view returns (uint16){

        TreasuryBase t = TreasuryBase(treasuryAddress());
        return t.speedBumpHours();
    }

    function QNTBalance() public view returns (uint256) {

        return QNTContract.balanceOf(address(this));
    }
    
    function ERC20Address() external pure returns (address) {

        return address(QNTContract);
    }
    
    function treasuryAddress() public view returns (address) {

        return addressStorage[keccak256(treasuryAddress1)];
    }
    
    function speedBumpQNTToWithdraw() public view returns (uint256) {

        return uint256Storage[keccak256(speedBumpQNTToWithdraw1)];
    }
    
    function speedBumpTimeCreated() public view returns (uint256) {

        return uint256Storage[keccak256(speedBumpTimeCreated1)];
    }
    
    function speedBumpWaitingHours() public view returns (uint16) {

        return uint16Storage[keccak256(speedBumpWaitingHours1)];
    }


}