
pragma solidity 0.6.4;

contract Ownable {


    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {

        require(newOwner != address(0));
        owner = newOwner;
    }

}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata  _extraData) external; }


contract CTNToken is Ownable {


    uint256 public totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    string public constant name = "CETAN";
    string public constant symbol = "CTN";
    uint32 public constant decimals = 18;

    uint constant restrictedPercent = 40; //should never be set above 100

    bool public transferAllowed = false;
    bool public mintingFinished = false;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    event Burn(address indexed burner, uint256 value);

    modifier whenTransferAllowed() {

        if(msg.sender != owner){
            require(transferAllowed);
        }
        _;
    }

    modifier canMint() {

        require(!mintingFinished);
        _;
    }

    function transfer(address _to, uint256 _value) whenTransferAllowed public returns (bool) {

        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) whenTransferAllowed public returns (bool) {

        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {


        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)  public returns (bool) {

        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }

    function allowTransfer() onlyOwner public {

        transferAllowed = true;
    }

    function mint(address _to, uint256 _value) onlyOwner canMint public returns (bool) {

        require(_to != address(0));

        uint restrictedTokens = _value * restrictedPercent / 100;
        uint _amount = _value + restrictedTokens;
        assert(_amount >= _value);

        totalSupply = totalSupply + _amount;

        assert(totalSupply >= _amount);

        balances[msg.sender] = balances[msg.sender] + _amount;
        assert(balances[msg.sender] >= _amount);
        emit Mint(msg.sender, _amount);

        transfer(_to, _value);
        transfer(owner, restrictedTokens);
        return true;
    }

    function finishMinting() onlyOwner public returns (bool) {

        mintingFinished = true;
        emit MintFinished();
        return true;
    }

    function burn(uint256 _value) public returns (bool) {

        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - _value;
        totalSupply = totalSupply - _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from] - _value;
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
        totalSupply = totalSupply - _value;
        emit Burn(_from, _value);
        return true;
    }
}