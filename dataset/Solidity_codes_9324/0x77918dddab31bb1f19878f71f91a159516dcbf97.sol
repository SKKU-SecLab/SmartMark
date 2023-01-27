
pragma solidity ^0.5.0;


contract WhiteBitCoin {

    using SafeMath for uint256;

    string constant public name = "WhiteBit Coin";
    string constant public symbol = "WHBC";
    uint8 constant public decimals = 18;

    address payable public owner;

    uint256 public totalSupply = 180e6*uint256(10)**decimals;

    mapping (address => uint256) public balanceOf;
    mapping (address => uint256) public freezeOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);

    event Freeze(address indexed from, uint256 value);

    event Unfreeze(address indexed from, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address payable _owner) public {
        owner = _owner;
        balanceOf[owner] = totalSupply;              // Give the creator all initial tokens
    }

    function transfer(address _to, uint256 _value) public returns (bool success){

        require (_to != address(0));                               // Prevent transfer to 0x0 address. Use burn() instead
        require (_value >= 0);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);                     // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);                            // Add the same to the recipient
        emit Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

        require (_value >= 0); //Approval of 0 is revoking approval. So allow 0 here
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require (_to != address(0));                                // Prevent transfer to 0x0 address. Use burn() instead
        require (_value >= 0);

        balanceOf[_from] = balanceOf[_from].sub(_value);                           // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);                             // Add the same to the recipient
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {

        require (_value >= 0);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);                      // Subtract from the sender
        totalSupply = totalSupply.sub(_value);                                // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    function freeze(uint256 _value) public returns (bool success) {

        require (_value >= 0);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);                      // Subtract from the sender
        freezeOf[msg.sender] = freezeOf[msg.sender].add(_value);                                // Updates totalSupply
        emit Freeze(msg.sender, _value);
        return true;
    }

    function unfreeze(uint256 _value) public returns (bool success) {

        require (_value >= 0);
        freezeOf[msg.sender] = freezeOf[msg.sender].sub(_value);                      // Subtract from the sender
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_value);
        emit Unfreeze(msg.sender, _value);
        return true;
    }

    function withdrawEther(uint256 amount) public {

        require(msg.sender == owner);
        owner.transfer(amount);
    }

    function() external payable {
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
}