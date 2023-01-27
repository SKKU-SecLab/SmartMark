
pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

contract InfiClaim{


    address public owner;
    bytes32 public root;

    address public distributionWallet=0xEF433e69CF6CF1ADB44741c56B6D8dbB0D84fa78;

    IERC20 public infi;
    bool public claimIsActive = false;

     constructor() public {
        owner=msg.sender;
        root=0xa377aa0faca3a1d0837dbcc3fe355adae330817810542110b8f05478034516a4;
        infi=IERC20(0x2091457430924515e23d7cD4E6A23d2C01Fd446e);
    }



    mapping(address => bool) claimedAddresses;
    
     function flipClaimState() public {

        require(msg.sender==owner, "Only Owner can use this function");
        claimIsActive = !claimIsActive;
    }

    function setPurchaseToken(IERC20 token) public  {

        require(msg.sender==owner, "Only Owner can use this function");
        infi = token; //Infi Token
    }

    function setRoot(bytes32 newRoot) public  {

        require(msg.sender==owner, "Only Owner can use this function");
        root=newRoot; 
    }

     function setDistributionWallet(address newWallet) public {

        require(msg.sender==owner, "Only Owner can use this function");
        distributionWallet=newWallet; //Set Wallet
    }
     function transferOwnership(address newOwner) public {

        require(msg.sender==owner, "Only Owner can use this function");
        owner=newOwner; //Set Owner
    }

    function withdrawStuckInfiBalance() public {

        require(msg.sender==owner, "Only Owner can use this function");
        infi.transferFrom(address(this),msg.sender,infi.balanceOf(address(this)));
    }

    function hasClaimed(address claimedAddress) public view returns (bool){

      return claimedAddresses[claimedAddress]; //check if claimed
    }

    function removeFromClaimed(address claimedAddress) public {

      require(msg.sender==owner, "Only Owner can use this function");
      claimedAddresses[claimedAddress]=false; //only for testing 
    }
 
    
  function verify(
    bytes32 leaf,
    bytes32[] memory proof
  )
    public
    view
    returns (bool)
  {

    bytes32 computedHash = leaf;

    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];

      if (computedHash < proofElement) {
        computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
      } else {
        computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
      }
    }
    return computedHash == root;
  }
  
function claim(bytes32[] memory proof,address account, uint256 amount) public{


    require(claimIsActive, "Claim is not enabled");
    require(!claimedAddresses[account], "Distributor: Drop already claimed.");
    require(msg.sender==account, "Sender not claimer");

    bytes32 leaf = keccak256(abi.encodePacked(account, amount));
    require(verify(leaf,proof), "Not Eligible");

    infi.transferFrom(distributionWallet,account,amount*10**18);  //transfer
    claimedAddresses[account]=true;
}
}