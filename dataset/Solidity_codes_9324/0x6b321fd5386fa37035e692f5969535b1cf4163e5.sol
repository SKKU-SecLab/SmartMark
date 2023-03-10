
pragma solidity ^0.4.16;

contract SafeMath {

     function safeMul(uint a, uint b) internal returns (uint) {

          uint c = a * b;
          assert(a == 0 || c / a == b);
          return c;
     }

     function safeSub(uint a, uint b) internal returns (uint) {

          assert(b <= a);
          return a - b;
     }

     function safeAdd(uint a, uint b) internal returns (uint) {

          uint c = a + b;
          assert(c>=a && c>=b);
          return c;
     }
}

contract Token is SafeMath {

     function totalSupply() constant returns (uint256 supply);


     function balanceOf(address _owner) constant returns (uint256 balance);


     function transfer(address _to, uint256 _value) returns(bool);


     function transferFrom(address _from, address _to, uint256 _value) returns(bool);


     function approve(address _spender, uint256 _value) returns (bool success);


     function allowance(address _owner, address _spender) constant returns (uint256 remaining);


     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StdToken is Token {

     mapping(address => uint256) balances;
     mapping (address => mapping (address => uint256)) allowed;
     uint public supply = 0;

     function transfer(address _to, uint256 _value) returns(bool) {

          require(balances[msg.sender] >= _value);
          require(balances[_to] + _value > balances[_to]);

          balances[msg.sender] = safeSub(balances[msg.sender],_value);
          balances[_to] = safeAdd(balances[_to],_value);

          Transfer(msg.sender, _to, _value);
          return true;
     }

     function transferFrom(address _from, address _to, uint256 _value) returns(bool){

          require(balances[_from] >= _value);
          require(allowed[_from][msg.sender] >= _value);
          require(balances[_to] + _value > balances[_to]);

          balances[_to] = safeAdd(balances[_to],_value);
          balances[_from] = safeSub(balances[_from],_value);
          allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender],_value);

          Transfer(_from, _to, _value);
          return true;
     }

     function totalSupply() constant returns (uint256) {

          return supply;
     }

     function balanceOf(address _owner) constant returns (uint256) {

          return balances[_owner];
     }

     function approve(address _spender, uint256 _value) returns (bool) {

          require((_value == 0) || (allowed[msg.sender][_spender] == 0));

          allowed[msg.sender][_spender] = _value;
          Approval(msg.sender, _spender, _value);

          return true;
     }

     function allowance(address _owner, address _spender) constant returns (uint256) {

          return allowed[_owner][_spender];
     }
}

contract BossDawgtoken is StdToken
{

    string public constant name = "Boss Dawg";
    string public constant symbol = "BSG";
    uint public constant decimals = 18;

    uint public constant TOTAL_SUPPLY = 1300000000 * (1 ether / 1 wei);
    uint public constant DEVELOPERS_BONUS = 300000000 * (1 ether / 1 wei);

    uint public constant PRESALE_PRICE = 30000;  // per 1 Ether
    uint public constant PRESALE_MAX_ETH = 2000;
    uint public constant PRESALE_TOKEN_SUPPLY_LIMIT = PRESALE_PRICE * PRESALE_MAX_ETH * (1 ether / 1 wei);

    uint public constant ICO_PRICE1 = 27500;     // per 1 Ether
    uint public constant ICO_PRICE2 = 26250;     // per 1 Ether
    uint public constant ICO_PRICE3 = 25000;     // per 1 Ether

    uint public constant TOTAL_SOLD_TOKEN_SUPPLY_LIMIT = 1000000000* (1 ether / 1 wei);

    enum State{
       Init,
       Paused,

       PresaleRunning,
       PresaleFinished,

       ICORunning,
       ICOFinished
    }

    State public currentState = State.Init;
    bool public enableTransfers = false;

    address public teamTokenBonus = 0;

    address public escrow = 0;

    address public tokenManager = 0;

    uint public presaleSoldTokens = 0;
    uint public icoSoldTokens = 0;
    uint public totalSoldTokens = 0;

    modifier onlyTokenManager()
    {

        require(msg.sender==tokenManager); 
        _; 
    }

    modifier onlyInState(State state)
    {

        require(state==currentState); 
        _; 
    }

    event LogBuy(address indexed owner, uint value);
    event LogBurn(address indexed owner, uint value);

    function EthLendToken(address _tokenManager, address _escrow, address _teamTokenBonus) 
    {

        tokenManager = _tokenManager;
        teamTokenBonus = _teamTokenBonus;
        escrow = _escrow;

        uint teamBonus = DEVELOPERS_BONUS;
        balances[_teamTokenBonus] += teamBonus;
        supply+= teamBonus;

        assert(PRESALE_TOKEN_SUPPLY_LIMIT==60000000 * (1 ether / 1 wei));
        assert(TOTAL_SOLD_TOKEN_SUPPLY_LIMIT==1000000000 * (1 ether / 1 wei));
    }

    function buyTokens() public payable
    {

        require(currentState==State.PresaleRunning || currentState==State.ICORunning);

        if(currentState==State.PresaleRunning){
            return buyTokensPresale();
        }else{
            return buyTokensICO();
        }
    }

    function buyTokensPresale() public payable onlyInState(State.PresaleRunning)
    {

        require(msg.value >= (1 ether / 1 wei));
        uint newTokens = msg.value * PRESALE_PRICE;

        require(presaleSoldTokens + newTokens <= PRESALE_TOKEN_SUPPLY_LIMIT);

        balances[msg.sender] += newTokens;
        supply+= newTokens;
        presaleSoldTokens+= newTokens;
        totalSoldTokens+= newTokens;

        LogBuy(msg.sender, newTokens);
    }

    function buyTokensICO() public payable onlyInState(State.ICORunning)
    {

        require(msg.value >= ((1 ether / 1 wei) / 100));
        uint newTokens = msg.value * getPrice();

        require(totalSoldTokens + newTokens <= TOTAL_SOLD_TOKEN_SUPPLY_LIMIT);

        balances[msg.sender] += newTokens;
        supply+= newTokens;
        icoSoldTokens+= newTokens;
        totalSoldTokens+= newTokens;

        LogBuy(msg.sender, newTokens);
    }

    function getPrice()constant returns(uint)
    {

        if(currentState==State.ICORunning){
             if(icoSoldTokens<(200000000 * (1 ether / 1 wei))){
                  return ICO_PRICE1;
             }
             
             if(icoSoldTokens<(300000000 * (1 ether / 1 wei))){
                  return ICO_PRICE2;
             }

             return ICO_PRICE3;
        }else{
             return PRESALE_PRICE;
        }
    }

    function setState(State _nextState) public onlyTokenManager
    {

        require(currentState != State.ICOFinished);
        
        currentState = _nextState;
        enableTransfers = (currentState==State.ICOFinished);
    }

    function withdrawEther() public onlyTokenManager
    {

        if(this.balance > 0) 
        {
            require(escrow.send(this.balance));
        }
    }

    function transfer(address _to, uint256 _value) returns(bool){

        require(enableTransfers);
        return super.transfer(_to,_value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns(bool){

        require(enableTransfers);
        return super.transferFrom(_from,_to,_value);
    }

    function approve(address _spender, uint256 _value) returns (bool) {

        require(enableTransfers);
        return super.approve(_spender,_value);
    }

    function setTokenManager(address _mgr) public onlyTokenManager
    {

        tokenManager = _mgr;
    }

    function() payable 
    {
        buyTokens();
    }
}