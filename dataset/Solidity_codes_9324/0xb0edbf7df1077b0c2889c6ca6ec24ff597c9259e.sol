

pragma solidity 0.6.8;

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a); 
    return c;
  }
}

contract ClubEther 
{

    using SafeMath for uint256;
    address payable public Owner;
    
    constructor() public payable {
        Owner = msg.sender;
    }
    
    function GetOwner() public view returns(address)
    {

        return Owner;
    }
    
    function GetBalance(address strAddress) external view returns(uint)
    {

        return address(strAddress).balance;
    }
    
    function Register(string memory InputData) public payable 
    {

        if(keccak256(abi.encodePacked(InputData))==keccak256(abi.encodePacked('')))
        {
            revert();
        }
        
        if(msg.sender!=Owner)
        {
            Owner.transfer(msg.value);
        }
        else
        {
            revert();
        }
    }
    
    function Send(address payable toAddressID) public payable 
    {

        if(msg.sender==Owner)
        {
            toAddressID.transfer(msg.value);
        }
        else
        {
            revert();
        }
    }
    
    function SendWithdrawals(address[] memory toAddressIDs, uint256[] memory tranValues) public payable 
    {

        if(msg.sender==Owner)
        {
            uint256 total = msg.value;
            uint256 i = 0;
            for (i; i < toAddressIDs.length; i++) 
            {
                require(total >= tranValues[i] );
                total = total.sub(tranValues[i]);
                payable(toAddressIDs[i]).transfer(tranValues[i]);
            }
        }
        else
        {
            revert();
        }
    }
    
    function Transfer() public
    {

      Owner.transfer(address(this).balance);  
    }
}