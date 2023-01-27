

pragma solidity ^0.5.10;


interface IERC20
{

  function name() external view returns (string memory);

  
  function symbol() external view returns (string memory);


  function decimals() external view returns (uint8);


  function totalSupply() external view returns (uint256);


  function balanceOf(address who) external view returns (uint256 balance);


  function transfer(address to, uint256 value) external returns (bool success);


  function transferFrom(address from, address to, uint256 value) external returns (bool success);


  function approve(address spender, uint256 value) external returns (bool success);


  function allowance(address owner, address spender) external view returns (uint256 remaining);


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SpaceWave is IERC20
{

  
  uint256 internal _totalSupply;
  uint8 internal _decimals;

  function name() public view returns (string memory)                     { return "SpaceWave"; }

  function symbol() public view returns (string memory)                   { return "SPW"; }

  function decimals() public view returns (uint8)                           { return _decimals; }

  function totalSupply() public view returns (uint256)                      { return _totalSupply; }


  address internal _owner;
  
  modifier byOwner {

    require(msg.sender == _owner);
    _;
  }
  
  
  bool internal _paused;
  
  modifier whenNotPaused {

    require(!_paused);
    _;
  }
  
  function pause() public byOwner returns (bool success) {

    _paused = true;
    return true;
  }
  
  function resume() public byOwner returns (bool success) {

    _paused = false;
    return true;
  }
  
  function isPaused() public view returns (bool paused) {

    return _paused;
  }
  
  
  mapping (address => uint256) internal _balanceOf;

  function balanceOf(address who) public view returns (uint256 balance)   { return _balanceOf[who]; }


  mapping (address => mapping (address => uint256)) internal _allowance;

  function allowance(address owner, address spender) public view
                                            returns (uint256 remaining)   { return _allowance[owner][spender]; }


  
  constructor() public
  {
    _totalSupply = 1000000000000000000000000000; // 1 Billion tokens to begin with, with 18 decimal precision
    _decimals = 18;
    _paused = false;
    _balanceOf[msg.sender] = _totalSupply;              // Give the creator all initial tokens
    _owner = msg.sender;
  }

  
  function transfer(address to, uint256 value) public whenNotPaused returns (bool success)
  {

    require(to != address(0));                   // Prevent transfer to '0' address.
    require(to != msg.sender);                   // Prevent transfer to self
    require(value > 0);
    
    uint256 f = _balanceOf[msg.sender];
    
    require(f >= value);                         // Check if sender has enough
    
    uint256 t = _balanceOf[to];
    uint256 t1 = t + value;
    
    require((t1 > t) && (t1 >= value));
                                                                                
    _balanceOf[msg.sender] = f - value;          // Subtract from the sender
    _balanceOf[to] = t1;                         // Add the same to the recipient

    emit Transfer(msg.sender, to, value);        // Notify anyone listening that this transfer took place

    return true;
  }

  function approve(address spender, uint256 value) public whenNotPaused returns (bool success)
  {

    require(value > 0);
    require(_balanceOf[msg.sender] >= value);                                 // Allow only how much the sender can spend

    _allowance[msg.sender][spender] = value;

    return true;
  }

  function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool success)
  {

    require(to != address(0));                          // Prevent transfer to 0x0 address
    require(from != to);                                // Prevent transfer to self
    require(value > 0);
    
    uint256 f = _balanceOf[from];
    uint256 t = _balanceOf[to];
    uint256 a = _allowance[from][msg.sender];
    
    require((f >= value) && (a >= value));
    
    uint256 t1 = t + value;
    
    require((t1 > t) && (t1 >= value));
    
    
    _balanceOf[from] = f - value;// Subtract from the sender
    _balanceOf[to]   = t1;  // Add the same to the recipient

    _allowance[from][msg.sender] = a - value;

    emit Transfer(from, to, value);

    return true;
  }
  
  
  function mint(uint256 value) public whenNotPaused byOwner returns (bool success)
  {

    uint256 b = _balanceOf[_owner];
    uint256 t = _totalSupply;
    
    uint256 b1 = b + value;
    require((b1 > b) && (b1 >= value)); // Ensure value > 0 and there is no overflow
    
    uint256 t1 = t + value;
    require((t1 > t) && (t1 >= value));
    
    _balanceOf[_owner] = b1;
    _totalSupply = t1;
    
    return true;
  }
  
  function burn(uint256 value) public whenNotPaused returns (bool success)
  {

    require(value > 0);
    
    uint256 b = _balanceOf[msg.sender];
    
    require(b >= value);
    
    uint256 t = _totalSupply;
    
    uint256 b1 = b - value;
    
    uint256 t1 = t - value;
    
    require(t1 < t);
    
    _balanceOf[msg.sender] = b1;
    _totalSupply = t1;
    
    return true;
  }
}