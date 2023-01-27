pragma solidity ^0.6.8;


abstract contract ERC20 {
    function balanceOf(address tokenOwner) public view virtual returns (uint balance);
    function transfer(address to, uint tokens) public virtual returns (bool success);
}


contract Receiver {


    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function changeOwner(address newOwner) public {

        require(msg.sender == owner);
        owner = newOwner;
    }

    function getOwner() public view returns (address) {

        return owner;
    }

    function transfer(address contractAddress, uint256 amount, address receiver) public returns ( bool ) {

        require(msg.sender == owner);
        return ERC20(contractAddress).transfer(receiver, amount);
    }
    
    function balanceOf(address contractAddress) public view returns (uint256) {

        return ERC20(contractAddress).balanceOf(address(this));
    }
}pragma solidity ^0.6.8;


contract ReceiversFactory {


    address public owner;
    mapping ( uint256 => Receiver ) receiversMap;
    uint256 receiverCount = 0;

    constructor() public {
        owner = msg.sender;
    }
    
    function createReceivers(uint8 count) public {

        require(msg.sender == owner);
        
        for (uint8 i = 0; i < count; i++) {
            receiversMap[++receiverCount] = new Receiver();
        }
    }
    
    function changeReceiversOwner(address newOwner) public {

        require(msg.sender == owner);
        
        for (uint i = 1; i <= receiverCount; i++) {
            receiversMap[i].changeOwner(newOwner);
        }
    }
    
    function getReceiverAddress(uint receiverId) public view returns (address) {

        return address(receiversMap[receiverId]);
    }
    
    function getReceiversCount() public view returns (uint) {

        return receiverCount;
    }
    
    
    function receiverBalance(uint256 idx, address contractAddress) public view returns (uint256) {

        return receiversMap[idx].balanceOf(contractAddress);
    }
    

    function sendFunds( uint256 receiverId, address contractAddress, uint256 amount, address receiver ) public returns (bool) {

        require(msg.sender == owner);
        return receiversMap[receiverId].transfer(contractAddress, amount, receiver);
    }

}