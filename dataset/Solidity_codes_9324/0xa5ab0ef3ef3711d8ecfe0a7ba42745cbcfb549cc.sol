
 
 pragma solidity ^0.4.10;




contract IERC20Token {


    function name() public constant returns (string _name) { _name; }

    function symbol() public constant returns (string _symbol) { _symbol; }

    function decimals() public constant returns (uint8 _decimals) { _decimals; }

    
    function totalSupply() constant returns (uint total) {total;}

    function balanceOf(address _owner) constant returns (uint balance) {_owner; balance;}    

    function allowance(address _owner, address _spender) constant returns (uint remaining) {_owner; _spender; remaining;}


    function transfer(address _to, uint _value) returns (bool success);

    function transferFrom(address _from, address _to, uint _value) returns (bool success);

    function approve(address _spender, uint _value) returns (bool success);

    

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract SafeMath {


    function safeAdd(uint256 a, uint256 b) internal returns (uint256) {        

        uint256 c = a + b;
        assert(c >= a);

        return c;
    }

    function safeSub(uint256 a, uint256 b) internal returns (uint256) {

        assert(a >= b);
        return a - b;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {

        uint256 z = x * y;
        assert((x == 0) || (z / x == y));
        return z;
    }

    function safeDiv(uint256 x, uint256 y) internal returns (uint256) {

        assert(y != 0);
        return x / y;
    }
}/*************************************************************************
 * import "../common/SafeMath.sol" : end
 *************************************************************************/

contract ERC20StandardToken is IERC20Token, SafeMath {

    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 tokensIssued;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    function ERC20StandardToken() {

     
    }    


    function totalSupply() constant returns (uint total) {

        total = tokensIssued;
    }
 
    function balanceOf(address _owner) constant returns (uint balance) {

        balance = balances[_owner];
    }

    function transfer(address _to, uint256 _value) returns (bool) {

        require(_to != address(0));

        doTransfer(msg.sender, _to, _value);        
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {

        require(_to != address(0));
        
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);        
        doTransfer(_from, _to, _value);        
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

        remaining = allowed[_owner][_spender];
    }    

    function getRealTokenAmount(uint256 tokens) constant returns (uint256) {

        return tokens * (uint256(10) ** decimals);
    }

    
    function doTransfer(address _from, address _to, uint256 _value) internal {

        balances[_from] = safeSub(balances[_from], _value);
        balances[_to] = safeAdd(balances[_to], _value);
    }
}/*************************************************************************
 * import "./ERC20StandardToken.sol" : end
 *************************************************************************/

contract ITokenPool {    


    ERC20StandardToken public token;

    function setTrustee(address trustee, bool state);


    function getTokenAmount() constant returns (uint256 tokens) {tokens;}

}/*************************************************************************
 * import "./ITokenPool.sol" : end
 *************************************************************************/



contract Owned {

    address public owner;        

    function Owned() {

        owner = msg.sender;
    }

    modifier ownerOnly {

        assert(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public ownerOnly {

        require(_newOwner != owner);
        owner = _newOwner;
    }
}

contract Manageable is Owned {


    event ManagerSet(address manager, bool state);

    mapping (address => bool) public managers;

    function Manageable() Owned() {

        managers[owner] = true;
    }

    modifier managerOnly {

        assert(managers[msg.sender]);
        _;
    }

    function transferOwnership(address _newOwner) public ownerOnly {

        super.transferOwnership(_newOwner);

        managers[_newOwner] = true;
        managers[msg.sender] = false;
    }

    function setManager(address manager, bool state) ownerOnly {

        managers[manager] = state;
        ManagerSet(manager, state);
    }
}/*************************************************************************
 * import "../common/Manageable.sol" : end
 *************************************************************************/

contract TokenPool is Manageable, ITokenPool {    


    function TokenPool(ERC20StandardToken _token) {

        token = _token;
    }

    function setTrustee(address trustee, bool state) managerOnly {

        if (state) {
            token.approve(trustee, token.balanceOf(this));
        } else {
            token.approve(trustee, 0);
        }
    }

    function getTokenAmount() constant returns (uint256 tokens) {

        tokens = token.balanceOf(this);
    }

    function returnTokensTo(address to) managerOnly {

        token.transfer(to, token.balanceOf(this));
    }
}