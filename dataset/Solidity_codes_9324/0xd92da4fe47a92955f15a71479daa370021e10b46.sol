

pragma solidity 0.6.11;
contract Ownable {

  address public owner;
 

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  constructor () public {
    owner = msg.sender;
  }


  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

interface token { function transfer(address receiver, uint amount) external; }


contract TokenMultiSender is Ownable{

  event Message(string message);
  
  token tokenReward;
  
  address public addressOfTokenUsedAsReward;
  function setTokenReward(address _addr) public onlyOwner {

    tokenReward = token(_addr);
    addressOfTokenUsedAsReward = _addr;
  }
  
  function distributeTokens(address[] memory _addrs, uint[] memory _bals,string memory message) public onlyOwner{

		emit Message(message);
		for(uint i = 0; i < _addrs.length; ++i){
			tokenReward.transfer(_addrs[i],_bals[i]);
		}
	}
  
  function distributeEth(address payable[] memory _addrs, uint[] memory _bals, string memory message) public onlyOwner {

    for(uint i = 0; i < _addrs.length; ++i) {
        _addrs[i].transfer(_bals[i]);
    }
    emit Message(message);
  }
  
  receive () payable external {}

  function withdrawEth(uint _value) public onlyOwner {

    address(uint160(owner)).transfer(_value);
  }
  
  function withdrawTokens(uint _amount) public onlyOwner {

	tokenReward.transfer(owner,_amount);
  }
}