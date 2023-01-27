
pragma solidity ^0.4.24;


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


contract PwayContract is Ownable {


    modifier onlyHuman(address addr){

        uint size;
        assembly { size := extcodesize(addr) } // solium-disable-line
        if(size == 0){
            _;
        }else{
            revert("Provided address is a contract");
        }
    }
    
}


contract NameRegistry is PwayContract {


    event EntrySet(string entry,address adr);

    mapping(string => address) names;
  
    function hasAddress(string name) public view returns(bool) {

        return names[name] != address(0);
    }
    
    function getAddress(string name) public view returns(address) {

        require(names[name] != address(0), "Address could not be 0x0");
        return names[name];
    }
    
    function setAddress(string name, address _adr) public {

        require(_adr != address(0), "Address could not be 0x0");

        bytes memory nameBytes = bytes(name);
        require(nameBytes.length > 0, "Name could not be empty");

        bool isEmpty = names[name] == address(0);

        require(isEmpty || names[name] == msg.sender);

        names[name] = _adr;
        emit EntrySet(name, names[name]);
    } 
  
}