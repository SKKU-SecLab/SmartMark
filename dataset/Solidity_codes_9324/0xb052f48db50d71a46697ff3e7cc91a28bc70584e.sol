

pragma solidity 0.5.2;


library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract DetailedERC20 is ERC20 {

  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string memory _name, string memory _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {

    return allowed[_owner][_spender];
  }

  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {

    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {

    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract UnlimitedAllowanceToken is StandardToken {


    uint256 internal constant MAX_UINT = 2**256 - 1;
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
        public
        returns (bool)
    {

        uint256 allowance = allowed[_from][msg.sender];
        require(_value <= balances[_from], "insufficient balance");
        require(_value <= allowance, "insufficient allowance");
        require(_to != address(0), "token burn not allowed");

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (allowance < MAX_UINT) {
            allowed[_from][msg.sender] = allowance.sub(_value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(
        address _to,
        uint256 _value)
        public 
        returns (bool)
    {

        require(_value <= balances[msg.sender], "insufficient balance");
        require(_to != address(0), "token burn not allowed");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}

contract BZRxToken is UnlimitedAllowanceToken, DetailedERC20, Ownable {


    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    event LockingFinished();

    bool public mintingFinished = false;
    bool public lockingFinished = false;

    mapping (address => bool) public minters;

    modifier canMint() {

        require(!mintingFinished);
        _;
    }

    modifier hasMintPermission() {

        require(minters[msg.sender]);
        _;
    }

    modifier isLocked() {

        require(!lockingFinished);
        _;
    }

    constructor()
        public
        DetailedERC20(
            "bZx Protocol Token",
            "BZRX", 
            18
        )
    {
        minters[msg.sender] = true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
        public
        returns (bool)
    {

        if (lockingFinished || minters[msg.sender]) {
            return super.transferFrom(
                _from,
                _to,
                _value
            );
        }

        revert("this token is locked for transfers");
    }

    function transfer(
        address _to, 
        uint256 _value) 
        public 
        returns (bool)
    {

        if (lockingFinished || minters[msg.sender]) {
            return super.transfer(
                _to,
                _value
            );
        }

        revert("this token is locked for transfers");
    }

    function minterTransferFrom(
        address _spender,
        address _from,
        address _to,
        uint256 _value)
        public
        hasMintPermission
        canMint
        returns (bool)
    {

        require(canTransfer(
            _spender,
            _from,
            _value),
            "canTransfer is false");

        require(_to != address(0), "token burn not allowed");

        uint256 allowance = allowed[_from][_spender];
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (allowance < MAX_UINT) {
            allowed[_from][_spender] = allowance.sub(_value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(
        address _to,
        uint256 _amount)
        public
        hasMintPermission
        canMint
        returns (bool)
    {

        require(_to != address(0), "token burn not allowed");
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function finishMinting() 
        public 
        onlyOwner 
        canMint 
    {

        mintingFinished = true;
        emit MintFinished();
    }

    function finishLocking() 
        public 
        onlyOwner 
        isLocked 
    {

        lockingFinished = true;
        emit LockingFinished();
    }

    function addMinter(
        address _minter) 
        public 
        onlyOwner 
        canMint 
    {

        minters[_minter] = true;
    }

    function removeMinter(
        address _minter) 
        public 
        onlyOwner 
        canMint 
    {

        minters[_minter] = false;
    }

    function canTransfer(
        address _spender,
        address _from,
        uint256 _value)
        public
        view
        returns (bool)
    {

        return (
            balances[_from] >= _value && 
            (_spender == _from || allowed[_from][_spender] >= _value)
        );
    }
}

interface WETHInterface {

    function deposit() external payable;

    function withdraw(uint256 wad) external;

}

contract BZRxTokenConvert is Ownable {

    using SafeMath for uint256;

    uint256 public tokenPrice = 73 * 10**12;    // 0.000073 ETH
    uint256 public ethCollected;

    bool public conversionAllowed = true;

    address public bZRxTokenContractAddress;    // BZRX Token
    address public bZxVaultAddress;             // bZx Vault
    address public wethContractAddress;         // WETH Token

    modifier conversionIsAllowed() {

        require(conversionAllowed, "conversion not allowed");
        _;
    }

    constructor(
        address _bZRxTokenContractAddress,
        address _bZxVaultAddress,
        address _wethContractAddress,
        uint256 _previousAmountCollected)
        public
    {
        bZRxTokenContractAddress = _bZRxTokenContractAddress;
        bZxVaultAddress = _bZxVaultAddress;
        wethContractAddress = _wethContractAddress;
        ethCollected = _previousAmountCollected;
    }

    function()
        external
        payable 
    {
        require(msg.sender == wethContractAddress, "fallback not allowed");
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
        public
        conversionIsAllowed
        returns (bool)
    {

        require(msg.sender == bZxVaultAddress, "only the bZx vault can call this function");
        
        if (BZRxToken(bZRxTokenContractAddress).canTransfer(msg.sender, _from, _value)) {
            return BZRxToken(bZRxTokenContractAddress).minterTransferFrom(
                msg.sender,
                _from,
                _to,
                _value
            );
        } else {
            uint256 wethValue = _value                          // amount of BZRX
                                .mul(tokenPrice).div(10**18);   // fixed ETH price per token (0.000073 ETH)

            require(StandardToken(wethContractAddress).transferFrom(
                _from,
                address(this),
                wethValue
            ), "weth transfer failed");

            ethCollected += wethValue;

            return BZRxToken(bZRxTokenContractAddress).mint(
                _to,
                _value
            );
        }
    }

    function toggleConversionAllowed(
        bool _conversionAllowed) 
        public 
        onlyOwner 
        returns (bool)
    {

        conversionAllowed = _conversionAllowed;
        return true;
    }

    function changeTokenPrice(
        uint256 _tokenPrice) 
        public 
        onlyOwner 
        returns (bool)
    {

        tokenPrice = _tokenPrice;
        return true;
    }

    function changeBZRxTokenContract(
        address _bZRxTokenContractAddress) 
        public 
        onlyOwner 
        returns (bool)
    {

        bZRxTokenContractAddress = _bZRxTokenContractAddress;
        return true;
    }

    function changeBZxVault(
        address _bZxVaultAddress) 
        public 
        onlyOwner 
        returns (bool)
    {

        bZxVaultAddress = _bZxVaultAddress;
        return true;
    }

    function changeWethContract(
        address _wethContractAddress) 
        public 
        onlyOwner 
        returns (bool)
    {

        wethContractAddress = _wethContractAddress;
        return true;
    }

    function unwrapEth() 
        public 
        onlyOwner 
        returns (bool)
    {

        uint256 balance = StandardToken(wethContractAddress).balanceOf.gas(4999)(address(this));
        if (balance == 0)
            return false;

        WETHInterface(wethContractAddress).withdraw(balance);
        return true;
    }

    function transferEther(
        address payable _to,
        uint256 _value)
        public
        onlyOwner
        returns (bool)
    {

        uint256 amount = _value;
        if (amount > address(this).balance) {
            amount = address(this).balance;
        }

        return (_to.send(amount));
    }

    function transferToken(
        address _tokenAddress,
        address _to,
        uint256 _value)
        public
        onlyOwner
        returns (bool)
    {

        uint256 balance = StandardToken(_tokenAddress).balanceOf.gas(4999)(address(this));
        if (_value > balance) {
            return StandardToken(_tokenAddress).transfer(
                _to,
                balance
            );
        } else {
            return StandardToken(_tokenAddress).transfer(
                _to,
                _value
            );
        }
    }
}