pragma solidity 0.4.26;
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
pragma solidity 0.4.26;


contract Ownable {

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public{
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
pragma solidity 0.4.26;


contract ERC20Interface {


    function totalSupply() public view returns (uint);


    function balanceOf(address tokenOwner) public view returns (uint balance);


    function allowance(address tokenOwner, address spender) public view returns (uint remaining);


    function transfer(address to, uint tokens) public returns (bool success);


    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    function approve(address spender, uint tokens) public returns (bool success);


    function mint(uint256 value) public returns (bool);

    function mintToWallet(address to, uint256 tokens) public returns (bool);

    function burn(uint256 value) public returns (bool);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}
pragma solidity 0.4.26;



contract SlrsToken is ERC20Interface, Ownable {


    using SafeMath for uint256;
    uint256  public  totalSupply;
    address public itoContract;

    mapping  (address => uint256)             public          _balances;
    mapping  (address => mapping (address => uint256)) public  _approvals;


    string   public  name = "SolarStake Token";
    string   public  symbol = "SLRS";
    uint256  public  decimals = 18;

    event Mint(uint256 tokens);
    event MintToWallet(address indexed to, uint256 tokens);
    event MintFromContract(address indexed to, uint256 tokens);
    event Burn(uint256 tokens);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    constructor () public{
    }

    function totalSupply() public view returns (uint256) {

        return totalSupply;
    }
    function balanceOf(address tokenOwner) public view returns (uint256) {

        return _balances[tokenOwner];
    }
    function allowance(address tokenOwner, address spender) public view returns (uint256) {

        return _approvals[tokenOwner][spender];
    }

    function transfer(address to, uint256 tokens) public returns (bool) {

        require(to != address(0));
        require(tokens > 0 && _balances[msg.sender] >= tokens);
        _balances[msg.sender] = _balances[msg.sender].sub(tokens);
        _balances[to] = _balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint256 tokens) public returns (bool) {

        require(from != address(0));
        require(to != address(0));
        require(tokens > 0 && _balances[from] >= tokens && _approvals[from][msg.sender] >= tokens);
        _approvals[from][msg.sender] = _approvals[from][msg.sender].sub(tokens);
        _balances[from] = _balances[from].sub(tokens);
        _balances[to] = _balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function approve(address spender, uint256 tokens) public returns (bool) {

        require(spender != address(0));
        require(tokens > 0 && tokens <= _balances[msg.sender]);
        _approvals[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function mint(uint256 tokens) public onlyOwner returns (bool) {

        require(tokens > 0);
        _balances[msg.sender] = _balances[msg.sender].add(tokens);
        totalSupply = totalSupply.add(tokens);
        emit Mint(tokens);
        return true;
    }

    function mintToWallet(address to, uint256 tokens) public onlyOwner returns (bool) {

      totalSupply = totalSupply.add(tokens);
      _balances[to] = _balances[to].add(tokens);
      emit MintToWallet(to, tokens);
      return true;
    }

    function mintFromContract(address to, uint256 tokens) public returns (bool) {

      require(msg.sender == itoContract);
      totalSupply = totalSupply.add(tokens);
      _balances[to] = _balances[to].add(tokens);
      emit MintFromContract(to, tokens);
      return true;
    }

    function burn(uint256 tokens) public onlyOwner returns (bool)  {

        require(tokens > 0 && tokens <= _balances[msg.sender]);
        _balances[msg.sender] = _balances[msg.sender].sub(tokens);
        totalSupply = totalSupply.sub(tokens);
        emit Burn(tokens);
        return true;
    }

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }

    function setItoContract(address _itoContract) public onlyOwner {

      if (_itoContract != address(0)) {
        itoContract = _itoContract;
      }
    }

}
pragma solidity 0.4.26;



contract SlrsTokenItoContract  is Ownable{

    using SafeMath for uint256;
    SlrsToken public slrs;
    uint    public  startTime;
    address public vestingAddress;
    address public heliosEnergy;
    address public tapRootConsulting;

    mapping(address => bool) public isWhitelisted;
	mapping(address => bool) public isAdminlisted;

	event WhitelistSet(address indexed _address, bool _state);
	event AdminlistSet(address indexed _address, bool _state);


	constructor(address token, uint _startTime, address _vestingAddress, address _heliosEnergy, address _tapRootConsulting) public{
        require(token != address(0));
        require(_startTime > 1564646400); // unix timestamp 1564646400 1st August 2019 09:00 am
        require(_vestingAddress != address(0));
        require(_heliosEnergy != address(0));
        require(_tapRootConsulting != address(0));
		slrs = SlrsToken(token);
		require(slrs.owner() == msg.sender);
		startTime = _startTime;
        vestingAddress = _vestingAddress; // address of teamVesting Wallet
        heliosEnergy = _heliosEnergy; // address of HeliosEnergy wallet
        tapRootConsulting = _tapRootConsulting; // address of TapRootConulting wallet
	}

  modifier onlyOwners() {

		require (isAdminlisted[msg.sender] == true || msg.sender == owner);
		_;
	}

	modifier onlyWhitelisted() {

		require (isWhitelisted[msg.sender] == true);
		_;
	}
  function () public payable onlyWhitelisted{
    require(now >= startTime);
  }

  function transferFundsToWallet(address to, uint256 weiAmount) public onlyOwner {

        require(msg.sender==owner);
        require(weiAmount > 0);
        require(to == address(heliosEnergy) || to == address(tapRootConsulting));
        to.transfer(weiAmount);
    }

  function mintInvestorToken(address beneficiary, uint256 tokenamount) public onlyOwners {

    require(isWhitelisted[beneficiary] == true);
    require(tokenamount > 0);
    slrs.mintFromContract(beneficiary, tokenamount);
  }

  function mintTeamToken(address beneficiary, uint256 tokenamount) public onlyOwners {

    require(beneficiary == address(vestingAddress));
    require(tokenamount > 0);
    slrs.mintFromContract(beneficiary, tokenamount);
  }

    function setAdminlist(address _addr, bool _state) public onlyOwner {

    require(_addr != address(0));
		isAdminlisted[_addr] = _state;
		emit AdminlistSet(_addr, _state);
	}

    function setWhitelist(address _addr, bool _state) public onlyOwners {

        require(_addr != address(0));
        isWhitelisted[_addr] = _state;
        emit WhitelistSet(_addr, _state);
    }

    function setManyWhitelist(address[] _addr) public onlyOwners {

        uint length = _addr.length;
        for (uint256 i = 0; i < length; i++) {
            setWhitelist(_addr[i], true);
        }
    }

	function hasStarted() public view returns (bool) {

		return now >= startTime;
	}

  function checkInvestorHoldingToken(address investor) public view returns (uint256){

    require(investor != address(0));
    return slrs.balanceOf(investor);
  }

  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

    return ERC20Interface(tokenAddress).transfer(owner, tokens);
  }

	function kill() public onlyOwner{

    selfdestruct(owner);
  }
}
