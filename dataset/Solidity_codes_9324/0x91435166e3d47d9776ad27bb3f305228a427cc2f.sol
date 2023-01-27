

pragma solidity 0.8.4;

contract Owned {

    address public owner;
    address public proposedOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() virtual {

        require(msg.sender == owner);
        _;
    }

    function proposeOwner(address payable _newOwner) external onlyOwner {

        proposedOwner = _newOwner;
    }

    function claimOwnership() external {

        require(msg.sender == proposedOwner);
        emit OwnershipTransferred(owner, proposedOwner);
        owner = proposedOwner;
    }
}



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}






pragma solidity ^0.8.0;

interface ERC20 {

   function balanceOf(address _owner) view external  returns (uint256 balance);

   function transfer(address _to, uint256 _value) external  returns (bool success);

   function transferFrom(address _from, address _to, uint256 _value) external  returns (bool success);

   function approve(address _spender, uint256 _value) external returns (bool success);

   function allowance(address _owner, address _spender) view external  returns (uint256 remaining);

   event Transfer(address indexed _from, address indexed _to, uint256 _value);
   event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}





pragma solidity 0.8.4;



contract BISHUswapper is Context, Owned {

   
    address oldToken ;
    address newToken;

    
 
    constructor(address oldTokens,address newTokens)  {
       
         owner = msg.sender;
         oldToken = oldTokens;
         newToken = newTokens;
    }





  function exchangeToken(uint256 tokens)external   
        {

        
            require(tokens <= ERC20(newToken).balanceOf(address(this)), "Not enough tokens in the reserve");
            require(ERC20(oldToken).transferFrom(_msgSender(), address(this), tokens), "Tokens cannot be transferred from user account");      
            
            ERC20(newToken).transfer(_msgSender(), tokens);
    }


   function extractOldTokens() external onlyOwner
        {

            ERC20(oldToken).transfer(_msgSender(), ERC20(oldToken).balanceOf(address(this)));
           
        }

   function extractNewTokens() external onlyOwner
        {

            ERC20(newToken).transfer(_msgSender(), ERC20(newToken).balanceOf(address(this)));
            
        }
}