
pragma solidity ^0.4.24;
contract random{

    using SafeMath for uint;
    
    uint256 constant private FACTOR = 1157920892373161954235709850086879078532699846656405640394575840079131296399;
    
    address[] private authorities;
    mapping (address => bool) private authorized;
    address private adminAddress=0x154210143d7814F8A60b957f3CDFC35357fFC89C;

     modifier onlyAuthorized {

        require(authorized[msg.sender]);
        _;
    }

     modifier onlyAuthorizedAdmin {

        require(adminAddress == msg.sender);
        _;
    }
    modifier targetAuthorized(address target) {

        require(authorized[target]);
        _;
    }

    modifier targetNotAuthorized(address target) {

        require(!authorized[target]);
        _;
    }

    event LOG_RANDOM(uint256 indexed roundIndex  ,uint256 randomNumber);
    event LogAuthorizedAddressAdded(address indexed target, address indexed caller);
    event LogAuthorizedAddressRemoved(address indexed target, address indexed caller);


    function addAuthorizedAddress(address target)
        public
        onlyAuthorizedAdmin
        targetNotAuthorized(target)
    {

        authorized[target] = true;
        authorities.push(target);
        emit LogAuthorizedAddressAdded(target, msg.sender);
    }

    function removeAuthorizedAddress(address target)
        public
        onlyAuthorizedAdmin
        targetAuthorized(target)
    {

        delete authorized[target];
        for (uint i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                authorities[i] = authorities[authorities.length - 1];
                authorities.length -= 1;
                break;
            }
        }
        emit LogAuthorizedAddressRemoved(target, msg.sender);
    }

    function rand(uint min, uint max,address tokenAddress, uint256 roundIndex)
      public  
      onlyAuthorized
      returns(uint256) 
      {

        uint256 factor = FACTOR * 100 / max;
   
  
        uint256 seed = uint256(keccak256(abi.encodePacked(
            (roundIndex).add
            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(tokenAddress)))) / (now)).add
            (block.gaslimit).add
            (block.number)
            
        )));
       
        uint256 r=uint256(uint256(seed) / factor)  % max +min;

         emit LOG_RANDOM(roundIndex,r);
         return(r);
       
}
    
}


library SafeMath {


  function mul(uint a, uint b) internal pure returns (uint) {

    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {

    uint c = a / b;
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {

    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {

    uint c = a + b;
    assert(c >= a);
    return c;
  }
}