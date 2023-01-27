
pragma solidity ^0.5.4;
contract Ownable {

  address payable public owner;
  event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

  constructor() public {owner = msg.sender;}

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address payable _newOwner) public onlyOwner {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}
contract FrenchIco_Coprorate is Ownable {

    
    bool internal PauseAllContracts= false;
    uint public maxAmount;
    mapping(address => uint) internal role;
    
    event WhitelistedAddress(address addr, uint _role);

 
    function GeneralPause() onlyOwner external {

        if (PauseAllContracts==false) {PauseAllContracts=true;}
        else {PauseAllContracts=false;}
    }
    
    function setupMaxAmount(uint _maxAmount) onlyOwner external {

        maxAmount = _maxAmount;
    }


   
    function RoleSetup(address addr, uint _role) onlyOwner public {

         role[addr]= _role;
         emit WhitelistedAddress(addr, _role);
      }
      
    function newMember() public payable {

         require (role[msg.sender]==0,"user has to be new");
         role[msg.sender]= 1;
         owner.transfer(msg.value);
         emit WhitelistedAddress(msg.sender, 1);
      }
      
	     
    function isGeneralPaused() external view returns (bool) {return PauseAllContracts;}

    function GetRole(address addr) external view returns (uint) {return role[addr];}

    function GetWallet_FRENCHICO() external view returns (address) {return owner;}

    function GetMaxAmount() external view returns (uint) {return maxAmount;}


}