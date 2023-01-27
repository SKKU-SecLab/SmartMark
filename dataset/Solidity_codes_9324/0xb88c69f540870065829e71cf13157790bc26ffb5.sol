
pragma solidity ^0.6.5;

contract Ultraspace {



    address payable public owner = 0x600247A0E0e6aa4d1B79D6c56739D2f85C666533;

    
    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
    
    function getBalance(address _ad) public view returns(uint){

        return _ad.balance;
    }
    
    
    mapping(address => uint) public diamondPayment;
    
    function registerDiamond() public payable {

        require(msg.value == 0.1 ether, "Not appropriate amount");
        diamondPayment[msg.sender] = msg.value;
        address(this).transfer(msg.value);
    }
    
    function transferToUplineDiamond(address payable _u1, address payable _u2, address payable _u3, address payable _sponsor) public{

        require(msg.sender == owner, "You are not authorized");

        
        _sponsor.transfer(0.04 ether);
        
        if(_u1 == address(0x0)) {
        }
        else if(_u2 == address(0x0)) {
            _u1.transfer(0.01 ether);
        }
        else if(_u3 == address(0x0)) {
            _u1.transfer(0.01 ether);
            _u2.transfer(0.015 ether);
        }
        
        else{
            _u1.transfer(0.01 ether);
            _u2.transfer(0.015 ether);
            _u3.transfer(0.02 ether);
        }
        
        delete diamondPayment[msg.sender];
        
    }
    
    
    
    mapping(address => uint) public rubyPayment;
    
    function registerRuby() public payable {

        require(msg.value == 0.15 ether, "Not appropriate amount");
        rubyPayment[msg.sender] = msg.value;
        address(this).transfer(msg.value);
    }
    
    function transferToUplineRuby(address payable _u1, address payable _u2, address payable _u3, address payable _u4, address payable _sponsor) public{

        require(msg.sender == owner, "You are not authorized");
        
        _sponsor.transfer(0.06 ether);
        
        if(_u1 == address(0x0)) {
        }
        else if(_u2 == address(0x0)) {
            _u1.transfer(0.01 ether);
            
        }
        else if(_u3 == address(0x0)) {
            _u1.transfer(0.01 ether);
            _u2.transfer(0.015 ether);
            
        }
        
        else if(_u4 == address(0x0)) {
            _u1.transfer(0.01 ether);
            _u2.transfer(0.015 ether);
            _u3.transfer(0.02 ether);
        
        }
        
        else{
            _u1.transfer(0.01 ether);
            _u2.transfer(0.015 ether);
            _u3.transfer(0.02 ether);
            _u4.transfer(0.025 ether);
        
        }
        
        
        delete rubyPayment[msg.sender];
        
    }
    
    
    mapping(address => uint) public emeraldPayment;
    
    function registerEmerald() public payable {

        require(msg.value == 0.25 ether, "Not appropriate amount");
        emeraldPayment[msg.sender] = msg.value;
        address(this).transfer(msg.value);
    }
    
    function transferToUplineEmerald(address payable _u1, address payable _u2, address payable _u3, address payable _u4, address payable _u5, address payable _sponsor) public{

        
        require(msg.sender == owner, "You are not authorized");
        
        _sponsor.transfer(0.1 ether);
        
        if(_u1 == address(0x0)) {
        }
        else if(_u2 == address(0x0)) {
            _u1.transfer(0.015 ether);
        
        }
        else if(_u3 == address(0x0)) {
            _u1.transfer(0.015 ether);
            _u2.transfer(0.02 ether);
        
        }
        
        else if(_u4 == address(0x0)) {
            _u1.transfer(0.015 ether);
            _u2.transfer(0.02 ether);
            _u3.transfer(0.025 ether);
        
        }
        
        else if(_u5 == address(0x0)) {
            _u1.transfer(0.015 ether);
            _u2.transfer(0.02 ether);
            _u3.transfer(0.025 ether);
            _u4.transfer(0.03 ether);
        
        }
        
        else{
            _u1.transfer(0.015 ether);
            _u2.transfer(0.02 ether);
            _u3.transfer(0.025 ether);
            _u4.transfer(0.03 ether);
            _u5.transfer(0.035 ether);
        
        }
        
        delete emeraldPayment[msg.sender];
        
    }
    
    
    function sendLeaderShipBonusDiamond(address payable _leader, uint8 _value) public {

        require(msg.sender == owner, "You are not authorized");
        require(_value == 5 || _value == 15 || _value == 25 || _value == 50, "Wrong value");
        if(_value == 5){
            _leader.transfer(0.025 ether);
        }
        else if(_value == 15){
            _leader.transfer(0.04 ether);
        }
        else if(_value == 25){
            _leader.transfer(0.06 ether);
        }
        else if(_value == 50){
            _leader.transfer(0.10 ether);
        }
        
    }
    
    function sendLeaderShipBonusRuby(address payable _leader, uint8 _value) public {

        require(msg.sender == owner, "You are not authorized");
        require(_value == 5 || _value == 15 || _value == 25 || _value == 50, "Wrong value");
        if(_value == 5){
            _leader.transfer(0.03 ether);
        }
        else if(_value == 15){
            _leader.transfer(0.05 ether);
        }
        else if(_value == 25){
            _leader.transfer(0.07 ether);
        }
        else if(_value == 50){
            _leader.transfer(0.15 ether);
        }
    }
    
    function sendLeaderShipBonusEmerald(address payable _leader, uint8 _value) public {

        require(msg.sender == owner, "You are not authorized");
        require(_value == 5 || _value == 15 || _value == 25 || _value == 50, "Wrong value");
        if(_value == 5){
            _leader.transfer(0.035 ether);
        }
        else if(_value == 15){
            _leader.transfer(0.06 ether);
        }
        else if(_value == 25){
            _leader.transfer(0.08 ether);
        }
        else if(_value == 50){
            _leader.transfer(0.20 ether);
        }
    }
    
    
    
    
    mapping(address => uint) pool1;
    
    function pool1Register() payable public {

        require(msg.value == 0.08 ether, "Wrong amount sent");
        address(this).transfer(msg.value);
        pool1[msg.sender] = msg.value;
    }
    
    function transferToPool1Upline(address payable _ad) public{

        require(msg.sender == owner, "You are not authorized");
        require(_ad != address(0x0), "Invalid Address");
        
        _ad.transfer(0.06 ether);
        
        delete pool1[msg.sender];
    }
    
    function sendRejoinAndMatchingBonusPool1(address payable _user, address payable _sponcer) public{

        require(msg.sender == owner, "You are not authorized");
        _user.transfer(0.01 ether);
        _sponcer.transfer(0.01 ether);
    }
    
    
    mapping(address => uint) pool2;
    
    function pool2Register() payable public {

        require(msg.value == 0.12 ether, "Wrong amount sent");
        pool2[msg.sender] = msg.value;
        address(this).transfer(msg.value);
    }
    
    function transferToPool2Upline(address payable _ad) public{

        require(msg.sender == owner, "You are not authorized");
        require(_ad != address(0x0), "Invalid Address");
        
        _ad.transfer(0.09 ether);
        
        delete pool2[msg.sender];
    }
    
    function sendRejoinAndMatchingBonusPool2(address payable _user, address payable _sponcer) public  {

        require(msg.sender == owner, "You are not authorized");
        _user.transfer(0.015 ether);
        _sponcer.transfer(0.015 ether);
    }
    
    mapping(address => uint) pool3;
    
    function pool3Register() payable public {

        require(msg.value == 0.20 ether, "Wrong amount sent");
        pool3[msg.sender] = msg.value;
        address(this).transfer(msg.value);
    }
    
    function transferToPool3Upline(address payable _ad) public{

        require(msg.sender == owner, "You are not authorized");
        require(_ad != address(0x0), "Invalid Address");
        
        _ad.transfer(0.15 ether);
        
        delete pool3[msg.sender];
    }
    
    function sendRejoinAndMatchingBonusPool3(address payable _user, address payable _sponcer) public {

        require(msg.sender == owner, "You are not authorized");
        _user.transfer(0.025 ether);
        _sponcer.transfer(0.025 ether);
    }
    
    mapping(address => uint) pool4;
    
    function pool4Register() payable public {

        require(msg.value == 0.30 ether, "Wrong amount sent");
        pool4[msg.sender] = msg.value;
        address(this).transfer(msg.value);
    }
    
    function transferToPool4Upline(address payable _ad) public{

        require(msg.sender == owner, "You are not authorized");
        require(_ad != address(0x0), "Invalid Address");
        
        _ad.transfer(0.23 ether);
        
        delete pool4[msg.sender];
    }
    
    function sendRejoinAndMatchingBonusPool4(address payable _user, address payable _sponcer) public {

        require(msg.sender == owner, "You are not authorized");
        _user.transfer(0.035 ether);
        _sponcer.transfer(0.035 ether);
    }


    
    event ContractBalance(uint Balance);
    
    function getContractBalance() public returns(uint _balance){

      require(msg.sender == owner, "You are not authorized");
      emit ContractBalance(address(this).balance);
      return(address(this).balance);
    }
    
    function getFundsToOwner(uint _amount) public {

      require(msg.sender == owner, "You are not authorized");
      msg.sender.transfer(_amount);
    }
    
}