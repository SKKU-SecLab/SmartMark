
pragma solidity ^0.4.11;

contract MemeNetworkToken {

    string public constant name = "Meme Network Token";
    string public constant symbol = "MNT";
    uint8 public constant decimals = 18;

    uint256 public constant tokenCreationRate = 10;
    uint256 public constant tokenCreationCap = 100000 ether * tokenCreationRate;
    uint256 totalTokens;

    address public devAddress;

    uint256 public endingBlock;

    bool public funding = true;
    
    mapping (address => uint256) balances;
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    function MemeNetworkToken(
        address _devAddress,
        uint256 _endingBlock
        ) {

        devAddress = _devAddress;
        endingBlock = _endingBlock;
    }

    function balanceOf(address _owner) external constant returns (uint256) {

        return balances[_owner];
    }
    
    function totalSupply() external constant returns (uint256) {

        return totalTokens;
    }

    function transfer(address _to, uint256 _value) {

        
        if (balances[msg.sender] < _value)
            throw;
        if (balances[_to] + _value < balances[_to])
            throw;
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }

    function create() payable external {

        if(!funding) throw;
        if (block.number > endingBlock)
            throw;
        if (msg.value == 0) throw;
        if (msg.value > (tokenCreationCap - totalTokens) / tokenCreationRate)
            throw;
        
        var numTokens = msg.value * tokenCreationRate;
        totalTokens += numTokens;

        balances[msg.sender] += numTokens;

        Transfer(0, msg.sender, numTokens);      
    }
    function finalize() {

        if (!funding) throw;
        if (block.number <= endingBlock &&
            totalTokens < tokenCreationCap)
            throw;
        
        funding = false;

        uint256 devTokens = tokenCreationCap - totalTokens + (tokenCreationCap / 5);
        balances[devAddress] += devTokens;
        Transfer(0, devAddress, devTokens);

        if (!devAddress.send(this.balance)) throw;
    }
}