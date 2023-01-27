
pragma solidity 0.5.14;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
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

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMathUint {

  function toInt256Safe(uint256 a) internal pure returns (int256) {

    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

library SafeMathInt {

  function mul(int256 a, int256 b) internal pure returns (int256) {

    require(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));

    int256 c = a * b;
    require((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {

    require(!(a == - 2**255 && b == -1) && (b > 0));

    return a / b;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {

    require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));

    return a - b;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {

    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

  function toUint256Safe(int256 a) internal pure returns (uint256) {

    require(a >= 0);
    return uint256(a);
  }
}

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract lexDAORole is Context {

    using Roles for Roles.Role;

    event lexDAOAdded(address indexed account);
    event lexDAORemoved(address indexed account);

    Roles.Role private _lexDAOs;

    modifier onlylexDAO() {

        require(islexDAO(_msgSender()), "lexDAO: caller does not have the lexDAO role");
        _;
    }

    function islexDAO(address account) public view returns (bool) {

        return _lexDAOs.has(account);
    }

    function addlexDAO(address account) public onlylexDAO {

        _addlexDAO(account);
    }

    function renouncelexDAO() public {

        _removelexDAO(_msgSender());
    }

    function _addlexDAO(address account) internal {

        _lexDAOs.add(account);
        emit lexDAOAdded(account);
    }

    function _removelexDAO(address account) internal {

        _lexDAOs.remove(account);
        emit lexDAORemoved(account);
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}

interface IFundsDistributionToken {

	function withdrawableFundsOf(address owner) external view returns (uint256);


	function withdrawFunds() external;


	event FundsDistributed(address indexed by, uint256 fundsDistributed);

	event FundsWithdrawn(address indexed by, uint256 fundsWithdrawn);
}

contract FundsDistributionToken is ERC20, ERC20Detailed, IFundsDistributionToken {

	using SafeMath for uint256;
	using SafeMathUint for uint256;
	using SafeMathInt for int256;

	uint256 constant internal pointsMultiplier = 2**128;
	uint256 internal pointsPerShare;

	mapping(address => int256) internal pointsCorrection;
	mapping(address => uint256) internal withdrawnFunds;

	function _distributeFunds(uint256 value) internal {

		require(totalSupply() > 0, "FundsDistributionToken._distributeFunds: SUPPLY_IS_ZERO");

		if (value > 0) {
			pointsPerShare = pointsPerShare.add(
				value.mul(pointsMultiplier) / totalSupply()
			);
			emit FundsDistributed(msg.sender, value);
		}
	}

	function _prepareWithdraw() internal returns (uint256) {

		uint256 _withdrawableDividend = withdrawableFundsOf(msg.sender);

		withdrawnFunds[msg.sender] = withdrawnFunds[msg.sender].add(_withdrawableDividend);

		emit FundsWithdrawn(msg.sender, _withdrawableDividend);

		return _withdrawableDividend;
	}

	function withdrawableFundsOf(address _owner) public view returns(uint256) {

		return accumulativeFundsOf(_owner).sub(withdrawnFunds[_owner]);
	}

	function withdrawnFundsOf(address _owner) public view returns(uint256) {

		return withdrawnFunds[_owner];
	}

	function accumulativeFundsOf(address _owner) public view returns(uint256) {

		return pointsPerShare.mul(balanceOf(_owner)).toInt256Safe()
			.add(pointsCorrection[_owner]).toUint256Safe() / pointsMultiplier;
	}

	function _transfer(address from, address to, uint256 value) internal {

		super._transfer(from, to, value);

		int256 _magCorrection = pointsPerShare.mul(value).toInt256Safe();
		pointsCorrection[from] = pointsCorrection[from].add(_magCorrection);
		pointsCorrection[to] = pointsCorrection[to].sub(_magCorrection);
	}

	function _mint(address account, uint256 value) internal {

		super._mint(account, value);

		pointsCorrection[account] = pointsCorrection[account]
			.sub( (pointsPerShare.mul(value)).toInt256Safe() );
	}

	function _burn(address account, uint256 value) internal {

		super._burn(account, value);

		pointsCorrection[account] = pointsCorrection[account]
			.add( (pointsPerShare.mul(value)).toInt256Safe() );
	}
}

contract ClaimToken is lexDAORole, FundsDistributionToken {

	using SafeMathUint for uint256;
	using SafeMathInt for int256;
	
	string public stamp;
	
	IERC20 public fundsToken;
	
    address public lexDAO;

	uint256 public fundsTokenBalance;

	modifier onlyFundsToken () {

		require(msg.sender == address(fundsToken), "ClaimToken: UNAUTHORIZED_SENDER");
		_;
	}

	constructor(
		string memory name, 
		string memory symbol,
		string memory _stamp,
		uint8 decimals,
		IERC20 _fundsToken,
		address _lexDAO,
        address owner,
        uint256 supply
	) 
		public 
		ERC20Detailed(name, symbol, decimals)
	{
		require(address(_fundsToken) != address(0), "ClaimToken: INVALID_FUNDS_TOKEN_ADDRESS");

        _mint(owner, supply);
        stamp = _stamp;
		fundsToken = _fundsToken;
		lexDAO = _lexDAO;
	}

	function withdrawFunds() 
		external 
	{

		uint256 withdrawableFunds = _prepareWithdraw();

		require(fundsToken.transfer(msg.sender, withdrawableFunds), "ClaimToken: TRANSFER_FAILED");

		_updateFundsTokenBalance();
	}

	function _updateFundsTokenBalance() internal returns (int256) {

		uint256 prevFundsTokenBalance = fundsTokenBalance;

		fundsTokenBalance = fundsToken.balanceOf(address(this));

		return int256(fundsTokenBalance).sub(int256(prevFundsTokenBalance));
	}

	function updateFundsReceived() external {

		int256 newFunds = _updateFundsTokenBalance();

		if (newFunds > 0) {
			_distributeFunds(newFunds.toUint256Safe());
		}
	}
	
    function lexDAOmint(address account, uint256 amount) public onlylexDAO returns (bool) {

        _mint(account, amount);
        return true;
    }    
    
    function lexDAOburn(address account, uint256 amount) public onlylexDAO returns (bool) {

        _burn(account, amount);
        return true;
    }
}

contract ClaimTokenFactory {

    uint8 public version = 1;
    
    string public stamp;
    bool public gated;
    address public deployer;
    
    address payable public _lexDAO; // lexDAO Agent
    
    ClaimToken private CT;
    
    address[] public tokens;
    
    event Deployed(address indexed CT, address indexed owner);
    
    event lexDAOupdated(address indexed newDAO);
    
    constructor (string memory _stamp, bool _gated, address _deployer, address payable lexDAO) public 
	{
        stamp = _stamp;
        gated = _gated;
        deployer = _deployer;
        _lexDAO = lexDAO;
	}
    
    function newClaimToken(
        string memory name, 
		string memory symbol,
		string memory _stamp,
		uint8 decimals,
		IERC20 _fundsToken,
		address owner,
		uint256 supply) public {

       
        if (gated == true) {
            require(msg.sender == deployer);
        }
        
        CT = new ClaimToken(
            name, 
            symbol,
            _stamp,
            decimals,
            _fundsToken,
            _lexDAO, 
            owner,
            supply);
        
        tokens.push(address(CT));
        
        emit Deployed(address(CT), owner);
    }
    
    function tipLexDAO() public payable { // forwards ether (Ξ) tip to lexDAO Agent

        _lexDAO.transfer(msg.value);
    }
    
    function getTokenCount() public view returns (uint256 tokenCount) {

        return tokens.length;
    }
    
    function updateDAO(address payable newDAO) public {

        require(msg.sender == _lexDAO);
        _lexDAO = newDAO;
        
        emit lexDAOupdated(newDAO);
    }
}

contract ClaimTokenFactoryMaker {


    address payable public _lexDAO; // lexDAO Agent
    
    ClaimTokenFactory private factory;
    
    address[] public factories; // index of factories
    
    event Deployed(address indexed factory, bool indexed _gated, address indexed deployer);
    
    constructor (address payable lexDAO) public 
	{
        _lexDAO = lexDAO;
	}
    
    function newClaimTokenFactory(string memory _stamp, bool _gated, address _deployer) public {

        factory = new ClaimTokenFactory(_stamp, _gated, _deployer, _lexDAO);
        
        factories.push(address(factory));
        
        emit Deployed(address(factory), _gated, _deployer);
    }
    
    function tipLexDAO() public payable { // forwards ether (Ξ) tip to lexDAO Agent

        _lexDAO.transfer(msg.value);
    }
    
    function getFactoryCount() public view returns (uint256 factoryCount) {

        return factories.length;
    }
    
    function updateDAO(address payable newDAO) public {

        require(msg.sender == _lexDAO);
        _lexDAO = newDAO;
    }
}