
pragma solidity ^0.4.24; 

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

contract Ownable {

  address public owner;
  address public coinvest;
  mapping (address => bool) public admins;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
    coinvest = msg.sender;
    admins[owner] = true;
    admins[coinvest] = true;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  modifier onlyCoinvest() {

      require(msg.sender == coinvest);
      _;
  }

  modifier onlyAdmin() {

      require(admins[msg.sender]);
      _;
  }

  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
  
  function transferCoinvest(address _newCoinvest) 
    external
    onlyCoinvest
  {

    require(_newCoinvest != address(0));
    coinvest = _newCoinvest;
  }

  function alterAdmin(address _user, bool _status)
    external
    onlyCoinvest
  {

    require(_user != address(0));
    require(_user != coinvest);
    admins[_user] = _status;
  }

}

contract TokenSwap is Ownable {

    
    ERC20Interface public tokenV1;
    ERC20Interface public tokenV2;
    ERC20Interface public tokenV3;
    ERC20Interface public tokenV4;
    
    constructor(address _tokenV1, address _tokenV2, address _tokenV3, address _tokenV4) public {
        tokenV1 = ERC20Interface(_tokenV1);
        tokenV2 = ERC20Interface(_tokenV2);
        tokenV3 = ERC20Interface(_tokenV3);
        tokenV4 = ERC20Interface(_tokenV4);
    }
    function tokenFallback(address _from, uint _value, bytes _data)
      external
    {

        require(msg.sender == address(tokenV1));
        require(_value > 0);
        require(tokenV4.transfer(_from, _value));
        _data;
    }
    function receiveApproval(address _from, uint256 _amount, address _token, bytes _data)
      public
    {

        address sender = msg.sender;
        require(sender == address(tokenV2) || sender == address(tokenV3));
        require(_amount > 0);
        require(ERC20Interface(sender).transferFrom(_from, address(this), _amount));
        require(tokenV4.transfer(_from, _amount));
        _token; _data;
    }
    
    function tokenEscape(address _tokenContract)
      external
      onlyCoinvest
    {

        require(_tokenContract != address(tokenV1) && _tokenContract != address(tokenV3));
        
        if (_tokenContract == address(0)) coinvest.transfer(address(this).balance);
        else {
            ERC20Interface lostToken = ERC20Interface(_tokenContract);
        
            uint256 stuckTokens = lostToken.balanceOf(address(this));
            lostToken.transfer(coinvest, stuckTokens);
        }    
    }

}