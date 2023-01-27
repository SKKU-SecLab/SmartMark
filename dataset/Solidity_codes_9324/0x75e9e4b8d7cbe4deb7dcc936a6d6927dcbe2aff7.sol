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


contract TreasuryFactory is FactoryBase  {

    
    bytes constant private treasuryAddress1 = '1.treasuryaddress';
    ERC20Interface constant private QNTContract = ERC20Interface(0x4a220E6096B25EADb88358cb44068A3248254675);    
    
    event addedNewStakeholder(uint8 gateway, address newStakeholderQNTAddress, address newStakeholderOperatorAddress, uint256 QNTforChannel, uint256 QNTforDeposit, uint256 expirationTime);
    
    modifier onlyTreasuryOperator(){

        TreasuryBase t = TreasuryBase(treasuryAddress());
        address operator = t.operatorAddress();
        if (msg.sender != operator){
            revert("Only the treasury address of this contract can modify its associated storage");
        } else {
            _; // otherwise carry on with the computation
        }
    }

    function initialize (address linkedTreasuryContract) external {
        require(!initialized(),"contract can only be initialised once");
         addressStorage[keccak256(treasuryAddress1)] = linkedTreasuryContract;
         initializeNow(); //sets this contract to initialized
    }
    
    function addNew(uint8 gateway, address newStakeholderQNTAddress,  address newStakeholderOperatorAddress, uint256 QNTForPaymentChannel, uint256 QNTForDeposit, uint256 expirationTime) external onlyTreasuryOperator() {

        if (gateway == 1){
            if (gatewayChannel(newStakeholderQNTAddress) != address(0x0)){
                revert("A stakeholder cannot be re-added"); //especially for a payment channel! Otherwise there maybe replay attacks (signed messages of the sender being used more than once)");
            }
            gatewayCount(gatewayCount()+1);
        } else {
            if (mappChannel(newStakeholderQNTAddress) != address(0x0)){
                revert("A stakeholder cannot be re-added"); //especially for a payment channel! Otherwise there maybe replay attacks (signed messages of the sender being used more than once)");
            }
            mappCount(mappCount()+1);
        }
        address newChannel = addChannel(gateway,newStakeholderQNTAddress,newStakeholderOperatorAddress,expirationTime);
        address newEscrow = addEscrowDeposit(gateway,newStakeholderQNTAddress,newStakeholderOperatorAddress,newChannel);
        QNTContract.transferFrom(newStakeholderQNTAddress,address(this),(QNTForPaymentChannel+QNTForDeposit));
        QNTContract.transfer(newChannel,QNTForPaymentChannel);
        QNTContract.transfer(newEscrow,QNTForDeposit);
        emit addedNewStakeholder(gateway,newStakeholderQNTAddress,newStakeholderOperatorAddress,QNTForPaymentChannel,QNTForDeposit,expirationTime);
    }
    
    function addChannel(uint8 gateway, address MAPPorGatewayQNTAddress, address MAPPorGatewayOperatorAddress,uint256 expirationTime) internal returns (address){

        PaymentChannel tpc = new PaymentChannel(MAPPorGatewayQNTAddress,MAPPorGatewayOperatorAddress,treasuryAddress(),gateway,expirationTime);
        address channel = address(tpc);
        if (gateway == 1){
            gatewayChannel(MAPPorGatewayOperatorAddress, channel);
        } else {
            mappChannel(MAPPorGatewayOperatorAddress, channel);
        }
        return channel;
    }
    
    function addEscrowDeposit(uint8 gateway, address MAPPorGatewayQNTAddress,  address MAPPorGatewayOperatorAddress, address paymentChannel) internal returns (address) {

        EscrowedDeposit ued = new EscrowedDeposit(MAPPorGatewayQNTAddress,MAPPorGatewayOperatorAddress,treasuryAddress(),paymentChannel);
        address escrow = address(ued);
        if (gateway == 1){
            gatewayDeposit(MAPPorGatewayOperatorAddress,escrow);
        } else {
            mappDeposit(MAPPorGatewayOperatorAddress,escrow);
        }
        return escrow;
    }
    
    function treasuryAddress() public view returns (address) {

        return addressStorage[keccak256(treasuryAddress1)];
    }

    function admin() public view returns (address) {

        TreasuryBase t = TreasuryBase(treasuryAddress());
        return t.admin();   
    }
      
    function speedBumpHours() public view returns (uint16){

        TreasuryBase t = TreasuryBase(treasuryAddress());
        return t.speedBumpHours();
    }
    

}

contract PaymentChannel {

    
    uint256 public currentNonce;
    address public MAPPorGatewayQNTAddress;
    address public MAPPorGatewayOperatorAddress;
    TreasuryBase t;
    uint8 public treasuryIsSender;
    uint256 public expiration;
    ERC20Interface private constant QNTContract = ERC20Interface(0x19Bc592A0E1BAb3AFFB1A8746D8454743EE6E838); 
 
    event expirationChanged(uint256 expirationTime);
    event QNTPaymentClaimed(uint256 claimedQNT, uint256 remainingQNT);
    event QNTReclaimed(uint256 returnedQNT);

    constructor(address thisMAPPorGatewayQNTAddress, address thisMAPPorGatewayOperatorAddress, address thisTreasuryAddress, uint8 thisTreasuryIsSender, uint256 thisExpirationTime) public {    
       MAPPorGatewayQNTAddress = thisMAPPorGatewayQNTAddress;
       MAPPorGatewayOperatorAddress = thisMAPPorGatewayOperatorAddress;
       t = TreasuryBase(thisTreasuryAddress);
       treasuryIsSender = thisTreasuryIsSender;
       expiration = thisExpirationTime; 
    }
    

     function claimQNTPayment(uint256 tokenAmount, uint256 timeout, uint256 disputeTimeout, bytes calldata signature, uint256 refund) external {

        require(refund < tokenAmount,"Refund amount cannot cause an underflow");
        if (msg.sender != receiverAddress(true)){
            require(refund == 0, "Only the receiver can give refund the channel");
        }
        require(now < expiration, "This function must be called before the channel times out");
        bytes32 message = prefixed(keccak256(abi.encodePacked(receiverAddress(false), tokenAmount, currentNonce, timeout, disputeTimeout, address(this)))); 
        if(recoverSigner(message, signature) != senderAddress(true)){
            revert("Signed message does not match parameters passed in");
        }
        currentNonce += 1;
        QNTContract.transfer(receiverAddress(false), tokenAmount-refund); 
        emit QNTPaymentClaimed(tokenAmount,QNTContract.balanceOf(address(this)));
    }

    function updateExpirationTime(uint256 newExpirationTime) external {

        require(msg.sender == senderAddress(true), "Only the senders operator can increase the expiration time");
        require(expiration < newExpirationTime, "You must increase the expiration time");
        expiration = newExpirationTime;
        emit expirationChanged(newExpirationTime);

    }

    function reclaimQNT(uint256 tokenAmount) external {

      require(msg.sender == senderAddress(true), "Only the senders operator can reclaim the QNT");
      require(now >= expiration, "The channel must have expired");
        QNTContract.transfer(senderAddress(false), tokenAmount);
        emit QNTReclaimed(tokenAmount);
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }
    
    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {

        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function receiverAddress(bool operatorAddress) public view returns (address) {

        if (treasuryIsSender == 0){
            if (operatorAddress == true){
                return t.operatorAddress();
            } else {
                return t.QNTAddress();
            }
        } else {
            if (operatorAddress == true){
                return MAPPorGatewayOperatorAddress;                
            } else {
                return MAPPorGatewayQNTAddress;
            }
        }
    }
    
    function senderAddress(bool operatorAddress) public view returns (address) {

        if (treasuryIsSender == 0){
            if (operatorAddress == true){
                return MAPPorGatewayOperatorAddress;                
            } else {
                return MAPPorGatewayQNTAddress;
            }
        } else {
            if (operatorAddress == true){
                return t.operatorAddress();
            } else {
                return t.QNTAddress();
            }
        }
    }
    
    function readQNTBalance() public view returns (uint256) {

        return QNTContract.balanceOf(address(this));
    }
    
    function treasuryAddress() public view returns (address) {

        return address(t);
    }
    
}

contract EscrowedDeposit {


    PaymentChannel pc;
    address public MAPPorGatewayQNTAddress;
    address public MAPPorGatewayOperatorAddress;
    TreasuryBase t;
    ERC20Interface private constant QNTContract = ERC20Interface(0x19Bc592A0E1BAb3AFFB1A8746D8454743EE6E838);

    event depositDeducted(uint256 claimedQNT, uint256 remainingQNT, address ruleAddress);
    event depositReturned(uint256 returnedQNT);

    constructor(address thisMAPPorGatewayQNTAddress, address thisMAPPorGatewayOperatorAddress, address thisTreasuryAddress, address thisChannelAddress) public {    
       MAPPorGatewayQNTAddress = thisMAPPorGatewayQNTAddress;
       MAPPorGatewayOperatorAddress = thisMAPPorGatewayOperatorAddress;
       t = TreasuryBase(thisTreasuryAddress);
       pc = PaymentChannel(thisChannelAddress);
    }
    
    function deductDeposit(uint256 tokenAmount, address ruleAddress) external {

        address ruleList = t.treasurysRuleList();
        require(msg.sender == ruleList, "This function can only be called by the associated rule list contract");
        require(now >= expiration(), "The channel must have expired");
        uint256 startingBalance = readQNTBalance();
        if (tokenAmount > startingBalance){ 
            QNTContract.transfer(t.QNTAddress(), startingBalance);  
            emit depositDeducted(startingBalance,0,ruleAddress);
        } else {
            QNTContract.transfer(t.QNTAddress(), tokenAmount);     
            emit depositDeducted(tokenAmount,readQNTBalance(),ruleAddress); 
        }
    }

    function WithdrawDeposit(uint256 tokenAmount) external {

      require(msg.sender == MAPPorGatewayOperatorAddress, "Can only be called by the MAPP/Gateway operator address after expiry");
        require(now >= expiration(), "Can only be called by the MAPP/Gateway operator address after expiry");
       QNTContract.transfer(MAPPorGatewayQNTAddress, tokenAmount);
       emit depositReturned(tokenAmount);
    }

    function readQNTBalance() public view returns (uint256) {

        return QNTContract.balanceOf(address(this));
    }

    function expiration() public view returns (uint256){

        return pc.expiration();
    }
    

    function treasuryAddress() public view returns (address) {

        return address(t);
    }
    
    function paymentChannelAddress() public view returns (address) {

        return address(pc);
    }
    
}
