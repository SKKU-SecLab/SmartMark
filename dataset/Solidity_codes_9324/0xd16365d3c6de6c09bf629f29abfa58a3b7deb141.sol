
pragma solidity ^0.5.11;

interface IERC20 {

  function balanceOf(address _owner) external view returns (uint256);

  function allowance(address _owner, address _spender) external view returns (uint256);

  function transfer(address _to, uint256 _value) external returns (bool);

  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

  function approve(address _spender, uint256 _value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract HOS is IERC20 {

  using SafeMath for uint256;

  string private constant _name = 'Hellos';
  string private constant _symbol = 'HOS';
  uint8 private constant _decimals = 8;
  uint256 private _totalSupply = 0;
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;
  
  address private _admin = address(0);
  uint256 private _MaximumsSupply = 24*(10**8)* 10 ** uint256(_decimals);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Mint(address mintTo, uint256 mintAmount);
  event ChangeAdmin(address newAdmin);

  constructor (address _owner) public {
    _admin = _owner;
  }

    modifier onlyPayloadSize(uint size) {

        require(!(msg.data.length < size + 4));
        _;
    }
    
     modifier onlyAdmin(){

        require(msg.sender == _admin,"only administrator call");
        _;
    }
    
   function admin() public view returns (address) {

    return _admin;
  }
    function totalSupply() public view returns (uint256) {

    return _totalSupply;
  }
  
  function name() public pure returns(string memory) {

    return _name;
  }

  function symbol() public pure returns(string memory) {

    return _symbol;
  }

  function decimals() public pure returns(uint8) {

    return _decimals;
  }
  
  function balanceOf(address _owner) external view returns (uint256 balance) {

    return balances[_owner];
  }

  function allowance(address _owner, address _spender) external view returns (uint256) {

    return allowed[_owner][_spender];
  }

  function transfer(address _to, uint256 _value) external onlyPayloadSize(2*32) returns (bool) {

    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) external onlyPayloadSize(3*32) returns (bool) {

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
  
  function changeAdmin(address newAdmin) external onlyAdmin{

    _admin = newAdmin;    
    emit ChangeAdmin(newAdmin);
  }
  
  function mint(uint256 mintAmount) external onlyAdmin {

      require(_totalSupply + mintAmount <= _MaximumsSupply);
      
      _totalSupply = _totalSupply.add(mintAmount);
      balances[msg.sender] = balances[msg.sender].add(mintAmount);
      
      emit Mint(msg.sender, mintAmount);
  }
  
  function burn(uint256 burnAmount) external onlyAdmin {

      require(balances[msg.sender] >= burnAmount);
      
      _totalSupply = _totalSupply.sub(burnAmount);
      balances[msg.sender] = balances[msg.sender].sub(burnAmount);
      
      emit Transfer(msg.sender, address(0), burnAmount);
  }
  
   function () payable external {
        revert();
    }


  function approve(address _spender, uint256 _value) external onlyPayloadSize(2*32)  returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
}