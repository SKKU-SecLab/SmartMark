
pragma solidity ^0.4.19;



contract ERC20Interface {

     function totalSupply() public constant returns (uint);

     function balanceOf(address tokenOwner) public constant returns (uint balance);

     function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

     function transfer(address to, uint tokens) public returns (bool success);

     function approve(address spender, uint tokens) public returns (bool success);

     function transferFrom(address from, address to, uint tokens) public returns (bool success);


     event Transfer(address indexed from, address indexed to, uint tokens);
     event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Etx is ERC20Interface {

    string public constant symbol = "ETX";

    string public constant name = "Ethex supporter token.";

    uint8 public constant decimals = 18;

    uint256 public blocksToVest;

    uint256 constant _totalSupply = 10000 * (1 ether);

    address public owner;

    mapping (address => uint256) balances;

    mapping (address => uint256) activateStartBlock;

    uint256 public expirationBlock;

    mapping (address => mapping (address => uint256)) allowed;

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function Etx(uint256 _blocksToVest,uint256 _expirationBlock) public {

        blocksToVest = _blocksToVest;
        expirationBlock = _expirationBlock;
        owner = msg.sender;
        balances[owner] = _totalSupply;
        activateStartBlock[owner] = block.number;
    }

    function totalSupply() public constant returns (uint256 ts) {

        ts = _totalSupply;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {

        return balances[_owner];
    }

    function activateStartBlockOf(address _owner) public constant returns (uint256 blockNumber) {

        if (balances[_owner] >= (1 ether)) {
          return activateStartBlock[_owner];
        }
        return block.number;
    }

    function isActive(address _owner) public constant returns (bool vested) {

        if (block.number > expirationBlock) {
            return false;
        }
        if (balances[_owner] >= (1 ether) &&
        activateStartBlock[_owner] + blocksToVest <= block.number) {
            return true;
        }
        return false;
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {

        if (balances[msg.sender] >= _amount &&
        _amount > 0 &&
        balances[_to] + _amount > balances[_to]) {

            uint256 previousBalance = balances[_to];

            balances[msg.sender] -= _amount;
            balances[_to] += _amount;

            if (previousBalance < (1 ether) && balances[_to] >= (1 ether)) {
                activateStartBlock[_to] = block.number;
            }

            Transfer(msg.sender, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {

        if (balances[_from] >= _amount &&
        allowed[_from][msg.sender] >= _amount &&
        _amount > 0 &&
        balances[_to] + _amount > balances[_to]) {

            uint256 previousBalance = balances[_to];

            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;

            if (previousBalance < (1 ether) && balances[_to] >= (1 ether)) {
                activateStartBlock[_to] = block.number;
            }

            Transfer(_from, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {

      require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

      allowed[msg.sender][_spender] = _amount;
      Approval(msg.sender, _spender, _amount);
      return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }
}