
pragma solidity ^0.4.24;
contract SafeMath {

    uint256 constant public MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) pure internal returns (uint256 z) {

        if (x > MAX_UINT256 - y) revert();
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) pure internal returns (uint256 z) {

        if (x < y) revert();
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) pure internal returns (uint256 z) {

        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) revert();
        return x * y;
    }
}
contract TQA is SafeMath{

    
    string public constant name='CanadianSpinachCoin';
    string public constant symbol='TQA';
    uint public constant decimals=8;
    uint256 public constant totalSupply=280000000*10**decimals;

    constructor() public {
        balances[msg.sender] = totalSupply;
    }
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function balanceOf(address _owner) public constant returns (uint256 balance) {//constant==view

        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success){

        require(balances[msg.sender] >= _value);
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){

        require(balances[_from] >= _value && allowance[_from][msg.sender] >= _value);
        balances[_to] = safeAdd(balances[_to], _value);
        balances[_from] = safeSub(balances[_from], _value);
        allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;

    }

    function approve(address _spender, uint256 _value) public returns (bool success){

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining){

        return allowance[_owner][_spender];
    }
}