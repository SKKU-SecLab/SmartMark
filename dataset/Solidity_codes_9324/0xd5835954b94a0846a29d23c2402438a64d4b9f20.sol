



pragma solidity >=0.7.0;


interface iERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 
contract Faucet {


   
   
   address public immutable token;
   address public _root;


   mapping (address => uint256) public claimed;
   uint256 public immutable claimAmount;

   event Claimed(address _by, address _to, uint256 _value);
   
   function ClaimedAmount(address index) public view returns (uint256) {

       return claimed[index];
   }
      
   function _setClaimed(address index) private {

       require(claimed[index] == 0);
       claimed[index] += claimAmount;  // No puede desbordar
   }
   
   
   function Claim(address index) public returns (uint256) {

      require(msg.sender == tx.origin, "Only humans");

      require(ClaimedAmount(index) == 0 && index != address(0));

      _setClaimed(index);
      require(iERC20(token).transfer(index, claimAmount), "Airdrop: error transferencia");
      emit Claimed(msg.sender, index, claimAmount);
      return claimAmount;
   }



   function Recovertokens() public returns (bool) {

      require(tx.origin == _root || msg.sender == _root , "tx.origin is not root");
      uint256 allbalance = iERC20(token).balanceOf(address(this));
      return iERC20(token).transfer(_root, allbalance);
   }


   event NewRootEvent(address);

   function SetRoot(address newroot) public {

      require(msg.sender == _root); // sender 
      address oldroot = _root;
      emit NewRootEvent(newroot);
      _root = newroot;
   } 
   

   constructor(address tokenaddr, uint256 claim_by_addr) {
       token = tokenaddr;
       claimAmount = claim_by_addr;
       _root = tx.origin;  // La persona (humana?) que crea el contrato.
   }

}