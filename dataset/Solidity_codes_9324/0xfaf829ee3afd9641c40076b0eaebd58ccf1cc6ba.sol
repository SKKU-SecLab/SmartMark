
pragma solidity ^0.6.0;


contract TokenWell {

    
    address public token = 0x382f5DfE9eE6e309D1B9D622735e789aFde6BADe; // GST
    ERC20 erc20 = ERC20(token);

    address public owner = 0x7ab874Eeef0169ADA0d225E9801A3FfFfa26aAC3; // me
    mapping (address => bool) public pumpers;

    uint public lastPumpTime = 0;
    uint public interval = 60*60*24*7; // one week intervals

    uint public flowRate = 1; // dispense 1% each time
    uint public flowGuage = 100;

    function getBalance() public view returns(uint balance) {

        balance = erc20.balanceOf(address(this));
    }
    
    function pump() public returns(uint haul) {

        require(pumpers[msg.sender],"NOT YOU"); // only pumpers may get free tokens
        require((now-lastPumpTime)>interval, "TOO SOON"); // enforce time interval between pumps
        lastPumpTime = now;
        
        haul = erc20.balanceOf(address(this))/flowGuage*flowRate;
        erc20.transfer(msg.sender,haul);
    }
    
    function transferOwnership(address newOwner) public {

        require(msg.sender==owner,"NOT YOU");
        owner = newOwner;
    }
    
    function addPumper(address newAddr) public {

        require(msg.sender==owner,"NOT YOU");
        pumpers[newAddr]=true;
    }
    
    function delPumper(address badAddr) public {

        require(msg.sender==owner,"NOT YOU");
        pumpers[badAddr]=false;
    }
}


interface ERC20{

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

}