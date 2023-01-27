
pragma solidity ^0.5.7;

contract AuraToken {


    mapping (address => uint256) balances;
    uint256 totalSupply;
    uint256 freeSupply;
    address owner1;
    address owner2;
    address owner3;
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H1.7';       //human 0.1 standard. Just an arbitrary versioning scheme.

    uint256 rateBuy;
    address payable w_owner;
    uint256 w_amount;

    constructor () public {
        owner2 = 0xEb5887409Dbf80de52cBE1dD441801F1f01c568b;
        owner1 = 0xBd1A0E79e12F9D7109d58D014C2A8fba1AA44935;
        owner3 = 0xc0eE5076F0D78D87AD992B6CE205d88133aD25c0;

        totalSupply = 0;                    // Update total supply (100000 for example)
        freeSupply = 0;                     // Update free supply (100000 for example)
        name = "atlant resourse";           // Set the name for display purposes
        decimals = 8;                        // Amount of decimals for display purposes
        symbol = "AURA";                     // Set the symbol for display purposes
        rateBuy = 200000000000;              // 20 eth per AURA
        emit TotalSupply(totalSupply);
        w_amount = 0;
    }

    function total_supply() public view returns (uint256 _supply) {

        return totalSupply;
    }

    function free_supply() public view returns (uint256 _supply) {

        return freeSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];
    }


    function transfer(address _to, uint256 _value) public returns (bool success) {

        if (balances[msg.sender] - _value >= 0 && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFromNA(address _to, uint256 _value) public returns (bool success) {
        require((msg.sender == owner1) || (msg.sender == owner2) || (msg.sender == owner3));
        balances[_to] += _value;
        freeSupply -= _value;
        emit Transfer(address(0), _to, _value);
        return true;
    }


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event TotalSupply(uint256 _value);
    event Rates(uint256 _value);
    
    function () external payable {
        buyAura();
    }

    function setRates(uint256 _rateBuy) public {
        require((msg.sender == owner1) || (msg.sender == owner2) || (msg.sender == owner3));
        rateBuy = _rateBuy;
        emit Rates(rateBuy);
    }
    
    function printTokens(uint256 _amount) public {       // must be signed from owner1
        require(totalSupply<=1500000000000000000000000);  // 15 000 000 000 000 000 AURA
        require(_amount>0);
        require(_amount<=1500000000000000000);          // 15 000 000 000 AURA
        if(msg.sender == owner1) {
            totalSupply +=_amount;
            freeSupply += _amount;
            emit TotalSupply(_amount);
        }
    }
    
    function buyAura() public payable {
        require(msg.value > 0);
        require(msg.value <= 150000000000000000000000000000); //150 000 000 000 ether
        balances[msg.sender] += msg.value / rateBuy;
        freeSupply -= msg.value / rateBuy; // Negative value is allowed
    }
    
    
    function withdraw(uint256 _amount) public {  // must be signed from 2 owners
        require(_amount > 0);
        require((msg.sender == owner1) || (msg.sender == owner2) || (msg.sender == owner3));
        if((msg.sender != w_owner) && (_amount == w_amount)) {
            w_amount = 0;
            w_owner.transfer(_amount);
        }
        else {
            w_owner = msg.sender;
            w_amount = _amount;
        }
    }
}