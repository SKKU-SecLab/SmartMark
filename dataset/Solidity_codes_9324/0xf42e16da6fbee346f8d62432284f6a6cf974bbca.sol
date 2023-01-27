
pragma solidity 0.5.12;


contract Ownable {

    address public owner;
    event OwnershipTransferred(address previousOwner, address newOwner);
    
    constructor() internal {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address _newOwner) public onlyOwner { 

        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}

contract Authenticity is Ownable{

    
    address[] private contracts;
    
    modifier withContract(address _addr){

        uint length;
        assembly { length := extcodesize(_addr) }
        require(length > 0);
        _;
    }
    
    constructor(address _contractAddress) public {
        contracts.push(_contractAddress);
    }

    function getAddress(address checkAddress) public view withContract(checkAddress) returns (bool success) {

        for(uint i = 0; i<contracts.length;i++ )
        if(checkAddress==contracts[i]) success=true;
    }
    
    function addContract(address _contractAddress) onlyOwner withContract(_contractAddress) public returns (bool success){

        if(!getAddress(_contractAddress)) contracts.push(_contractAddress);
        return true;
    }
    
    function getAddresses() public view returns (uint){

        return contracts.length;
    }
}