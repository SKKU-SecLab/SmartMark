
pragma solidity =0.4.25;

contract SafeMath {

     function safeMul(uint a, uint b) pure internal returns (uint) {

          uint c = a * b;
          assert(a == 0 || c / a == b);
          return c;
     }

     function safeSub(uint a, uint b)pure internal returns (uint) {

          assert(b <= a);
          return a - b;
     }

     function safeAdd(uint a, uint b)pure internal returns (uint) {

          uint c = a + b;
          assert(c>=a && c>=b);
          return c;
     }
}

contract Token is SafeMath {

     function totalSupply()public  constant returns (uint256 supply);


     function balanceOf(address _owner)public constant returns (uint256 balance);


     function transfer(address _to, uint256 _value)public returns(bool);


     function transferFrom(address _from, address _to, uint256 _value)public returns(bool);


     function approve(address _spender, uint256 _value)public returns (bool success);


     function allowance(address _owner, address _spender)public constant returns (uint256 remaining);


     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StdToken is Token {

     mapping(address => uint256) balances;
     mapping (address => mapping (address => uint256)) allowed;
     uint public supply = 0;

     function transfer(address _to, uint256 _value)public returns(bool) {

         
          require(balances[msg.sender] >= _value,"INSUFFICIENT BALANCE");
          require(balances[_to] + _value > balances[_to],"CANT TRANSFER");

          balances[msg.sender] = safeSub(balances[msg.sender],_value);
          balances[_to] = safeAdd(balances[_to],_value);

          emit Transfer(msg.sender, _to, _value);
          return true;
     }

     function transferFrom(address _from, address _to, uint256 _value)public returns(bool){

          require(balances[_from] >= _value,"INSUFFICIENT BALANCE");
          require(allowed[_from][msg.sender] >= _value,"CANT TRANSFER");
          require(balances[_to] + _value > balances[_to],"CANT TRANSFER");

          balances[_to] = safeAdd(balances[_to],_value);
          balances[_from] = safeSub(balances[_from],_value);
          allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender],_value);

          emit Transfer(_from, _to, _value);
          return true;
     }

     function totalSupply()public constant returns (uint256) {

          return supply;
     }

     function balanceOf(address _owner)public constant returns (uint256) {

          return balances[_owner];
     }

     function approve(address _spender, uint256 _value)public returns (bool) {

          require((_value == 0) || (allowed[msg.sender][_spender] == 0),"CANT ALLOW");

          allowed[msg.sender][_spender] = _value;
          emit Approval(msg.sender, _spender, _value);

          return true;
     }

     function allowance(address _owner, address _spender)public constant returns (uint256) {

          return allowed[_owner][_spender];
     }
}

contract GrandMarcheToken is StdToken
{

    string public constant name = "Grand Marche Token";
    string public constant symbol = "GMT";
    uint public constant decimals = 18;
    
    uint public constant TOTAL_SUPPLY = 10000000 * (1 ether / 1 wei);
    uint public constant AIRDROP_SHARE = 500000 * (1 ether / 1 wei);

    uint public constant PRESALE_PRICE = 4292;  // per 1 Ether
    uint public constant PRESALE_MAX_ETH = 233;
    
    uint public constant PRESALE_TOKEN_SUPPLY_LIMIT = PRESALE_PRICE * PRESALE_MAX_ETH * (1 ether / 1 wei);

    uint public constant ICO_PRICE1 = 2000;     // per 1 Ether

    uint public constant TOTAL_SOLD_TOKEN_SUPPLY_LIMIT = 3000000 * (1 ether / 1 wei);

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

    
    address public AI = 0;
    address public airdrop = 0;
    address public privateSales = 0;
    address public teamTokenBonus = 0;

    address public escrow = 0;

    address public tokenManager = 0;
    
    uint public CREATE_CONTRACT = 0;
    
    uint public presaleSoldTokens = 0;
    uint public icoSoldTokens = 0;
    uint public totalSoldTokens = 0;
    
    bool public ai_balout = true;
    bool public privateSales_balout = true;
    bool public teamTokenBonus_balout = true;

    modifier onlyTokenManager()
    {

        require(msg.sender==tokenManager,"NOT MANAGER"); 
        _; 
    }

    modifier onlyInState(State state)
    {

        require(state==currentState,"STATE WRONG"); 
        _; 
    }

    event unlock(address indexed owner, uint value);
    event LogBuy(address indexed owner, uint value);

    constructor (address _tokenManager, address _teamTokenBonus, address _escrow, address _AI, address _privateSales, address _airdrop)public
    {
        tokenManager = _tokenManager;
        teamTokenBonus = _teamTokenBonus;
        escrow = _escrow;
        AI = _AI;
        privateSales = _privateSales;
        airdrop = _airdrop;
        
        uint for_airdrop = AIRDROP_SHARE;
        balances[_airdrop] += for_airdrop;
        supply+= for_airdrop;
        
        CREATE_CONTRACT = uint40(block.timestamp);

        assert(PRESALE_TOKEN_SUPPLY_LIMIT==1000036 * (1 ether / 1 wei));
        assert(TOTAL_SOLD_TOKEN_SUPPLY_LIMIT==3000000 * (1 ether / 1 wei));
    }

    function buyTokens() public payable
    {

        require(currentState==State.PresaleRunning || currentState==State.ICORunning,"CANT BUY");

        if(currentState==State.PresaleRunning){
            return buyTokensPresale();
        }else{
            return buyTokensICO();
        }
    }
    
    function userbalance(address _addrress)public view returns(uint256){

        return balances[_addrress];
    }
    
    function buyTokensPresale() public payable onlyInState(State.PresaleRunning)
    {

        require(msg.value >= 5e17,"Min 0.5 ETH");
        uint newTokens = msg.value * PRESALE_PRICE;

        require(presaleSoldTokens + newTokens <= PRESALE_TOKEN_SUPPLY_LIMIT,"PRESALE REACHED");

        balances[msg.sender] += newTokens;
        supply+= newTokens;
        presaleSoldTokens+= newTokens;
        totalSoldTokens+= newTokens;

        emit LogBuy(msg.sender, newTokens);
    }

    function buyTokensICO() public payable onlyInState(State.ICORunning)
    {

        require(msg.value >= 1e17,"Min 0.1 ETH");
        uint newTokens = msg.value * getPrice();

        require(totalSoldTokens + newTokens <= TOTAL_SOLD_TOKEN_SUPPLY_LIMIT);

        balances[msg.sender] += newTokens;
        supply+= newTokens;
        icoSoldTokens+= newTokens;
        totalSoldTokens+= newTokens;

        emit LogBuy(msg.sender, newTokens);
    }

    function getPrice()public constant returns(uint)
    {

        if(currentState==State.ICORunning){
             if(icoSoldTokens<(200000000 * (1 ether / 1 wei))){
                  return ICO_PRICE1;
             }
        }else{
             return PRESALE_PRICE;
        }
    }

    function setState(State _nextState) public payable onlyTokenManager
    {

        require(currentState != State.ICOFinished,"ICO FINISHED");
        
        currentState = _nextState;
        enableTransfers = (currentState==State.ICOFinished);
    }

    function withdrawEther() public onlyTokenManager
    {

        if(address(this).balance > 0) 
        {
            escrow.transfer(address(this).balance);
        }
    }
    
    function request_unlock()public payable{

        if(msg.sender==AI){
            require(uint40(block.timestamp) >= CREATE_CONTRACT +( 730 * 86400),"LOCKED"); //lock for 24 month
            require(ai_balout==true,"Token has been sent");
            uint tokenai = 4000000 * (1 ether / 1 wei);
            balances[msg.sender] += tokenai;
            supply+= tokenai;
            ai_balout=false;
            emit unlock(msg.sender,tokenai);
        }else if(msg.sender==teamTokenBonus){
            require(uint40(block.timestamp) >= CREATE_CONTRACT +( 365 * 86400),"LOCKED"); //lock for 12 month
            require(teamTokenBonus_balout==true,"Token has been sent");
            uint tokenteam = 1500000 * (1 ether / 1 wei);
            balances[msg.sender] += tokenteam;
            supply+= tokenteam;
            teamTokenBonus_balout=false;
            emit unlock(msg.sender,tokenteam);
        }else if(msg.sender==privateSales){
            require(uint40(block.timestamp) >= CREATE_CONTRACT +( 182 * 86400),"LOCKED"); //lock for 6 month
            require(privateSales_balout==true,"Token has been sent");
            uint tokenprivate = 1000000 * (1 ether / 1 wei);
            balances[msg.sender] += tokenprivate;
            privateSales_balout=false;
            supply+= tokenprivate;
            emit unlock(msg.sender,tokenprivate);
        }
    }
    

    function transfer(address _to, uint256 _value)public returns(bool){

        require(enableTransfers,"TRANSFER DISABLED");
        
        return super.transfer(_to,_value);
    }

    function transferFrom(address _from, address _to, uint256 _value)public returns(bool){

        require(enableTransfers,"TRANSFER DISABLED");
        return super.transferFrom(_from,_to,_value);
    }

    function approve(address _spender, uint256 _value)public returns (bool) {

        require(enableTransfers,"TRANSFER DISABLED");
        return super.approve(_spender,_value);
    }

    function setTokenManager(address _mgr) public onlyTokenManager
    {

        tokenManager = _mgr;
    }

    function()public payable 
    {
        buyTokens();
    }
}