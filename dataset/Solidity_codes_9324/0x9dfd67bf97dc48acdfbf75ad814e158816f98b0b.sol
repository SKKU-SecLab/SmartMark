

pragma solidity >=0.5.17;

interface IAddressConfig {

	function token() external view returns (address);


	function allocator() external view returns (address);


	function allocatorStorage() external view returns (address);


	function withdraw() external view returns (address);


	function withdrawStorage() external view returns (address);


	function marketFactory() external view returns (address);


	function marketGroup() external view returns (address);


	function propertyFactory() external view returns (address);


	function propertyGroup() external view returns (address);


	function metricsGroup() external view returns (address);


	function metricsFactory() external view returns (address);


	function policy() external view returns (address);


	function policyFactory() external view returns (address);


	function policySet() external view returns (address);


	function policyGroup() external view returns (address);


	function lockup() external view returns (address);


	function lockupStorage() external view returns (address);


	function voteTimes() external view returns (address);


	function voteTimesStorage() external view returns (address);


	function voteCounter() external view returns (address);


	function voteCounterStorage() external view returns (address);


	function setAllocator(address _addr) external;


	function setAllocatorStorage(address _addr) external;


	function setWithdraw(address _addr) external;


	function setWithdrawStorage(address _addr) external;


	function setMarketFactory(address _addr) external;


	function setMarketGroup(address _addr) external;


	function setPropertyFactory(address _addr) external;


	function setPropertyGroup(address _addr) external;


	function setMetricsFactory(address _addr) external;


	function setMetricsGroup(address _addr) external;


	function setPolicyFactory(address _addr) external;


	function setPolicyGroup(address _addr) external;


	function setPolicySet(address _addr) external;


	function setPolicy(address _addr) external;


	function setToken(address _addr) external;


	function setLockup(address _addr) external;


	function setLockupStorage(address _addr) external;


	function setVoteTimes(address _addr) external;


	function setVoteTimesStorage(address _addr) external;


	function setVoteCounter(address _addr) external;


	function setVoteCounterStorage(address _addr) external;

}


pragma solidity 0.5.17;


contract UsingConfig {

	address private _config;

	constructor(address _addressConfig) public {
		_config = _addressConfig;
	}

	function config() internal view returns (IAddressConfig) {

		return IAddressConfig(_config);
	}

	function configAddress() external view returns (address) {

		return _config;
	}
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;




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


pragma solidity >=0.5.17;

interface IAllocator {

	function beforeBalanceChange(
		address _property,
		address _from,
		address _to
	) external;


	function calculateMaxRewardsPerBlock() external view returns (uint256);

}


pragma solidity >=0.5.17;

interface IProperty {

	function author() external view returns (address);


	function changeAuthor(address _nextAuthor) external;


	function changeName(string calldata _name) external;


	function changeSymbol(string calldata _symbol) external;


	function withdraw(address _sender, uint256 _value) external;

}


pragma solidity >=0.5.17;

interface IPropertyFactory {

	function create(
		string calldata _name,
		string calldata _symbol,
		address _author
	) external returns (address);


	function createAndAuthenticate(
		string calldata _name,
		string calldata _symbol,
		address _market,
		string calldata _args1,
		string calldata _args2,
		string calldata _args3
	) external returns (bool);


	function createChangeAuthorEvent(address _old, address _new) external;


	function createChangeNameEvent(string calldata _old, string calldata _new)
		external;


	function createChangeSymbolEvent(string calldata _old, string calldata _new)
		external;

}


pragma solidity >=0.5.17;

interface IPolicy {

	function rewards(uint256 _lockups, uint256 _assets)
		external
		view
		returns (uint256);


	function holdersShare(uint256 _amount, uint256 _lockups)
		external
		view
		returns (uint256);


	function authenticationFee(uint256 _assets, uint256 _propertyAssets)
		external
		view
		returns (uint256);


	function marketApproval(uint256 _agree, uint256 _opposite)
		external
		view
		returns (bool);


	function policyApproval(uint256 _agree, uint256 _opposite)
		external
		view
		returns (bool);


	function marketVotingBlocks() external view returns (uint256);


	function policyVotingBlocks() external view returns (uint256);


	function shareOfTreasury(uint256 _supply) external view returns (uint256);


	function treasury() external view returns (address);

}


pragma solidity 0.5.17;








contract Property is ERC20, UsingConfig, IProperty {

	using SafeMath for uint256;
	uint8 private constant PROPERTY_DECIMALS = 18;
	uint256 private constant SUPPLY = 10000000000000000000000000;
	address private __author;
	string private __name;
	string private __symbol;
	uint8 private __decimals;

	constructor(
		address _config,
		address _own,
		string memory _name,
		string memory _symbol
	) public UsingConfig(_config) {
		require(
			msg.sender == config().propertyFactory(),
			"this is illegal address"
		);
		__author = _own;

		__name = _name;
		__symbol = _symbol;
		__decimals = PROPERTY_DECIMALS;

		IPolicy policy = IPolicy(config().policy());
		uint256 toTreasury = policy.shareOfTreasury(SUPPLY);
		uint256 toAuthor = SUPPLY.sub(toTreasury);
		require(toAuthor != 0, "share of author is 0");
		_mint(__author, toAuthor);
		_mint(policy.treasury(), toTreasury);
	}

	modifier onlyAuthor() {

		require(msg.sender == __author, "illegal sender");
		_;
	}

	function author() external view returns (address) {

		return __author;
	}

	function name() external view returns (string memory) {

		return __name;
	}

	function symbol() external view returns (string memory) {

		return __symbol;
	}

	function decimals() external view returns (uint8) {

		return __decimals;
	}

	function changeAuthor(address _nextAuthor) external onlyAuthor {

		IPropertyFactory(config().propertyFactory()).createChangeAuthorEvent(
			__author,
			_nextAuthor
		);

		__author = _nextAuthor;
	}

	function changeName(string calldata _name) external onlyAuthor {

		IPropertyFactory(config().propertyFactory()).createChangeNameEvent(
			__name,
			_name
		);

		__name = _name;
	}

	function changeSymbol(string calldata _symbol) external onlyAuthor {

		IPropertyFactory(config().propertyFactory()).createChangeSymbolEvent(
			__symbol,
			_symbol
		);

		__symbol = _symbol;
	}

	function transfer(address _to, uint256 _value) public returns (bool) {

		require(_to != address(0), "this is illegal address");
		require(_value != 0, "illegal transfer value");

		IAllocator(config().allocator()).beforeBalanceChange(
			address(this),
			msg.sender,
			_to
		);

		_transfer(msg.sender, _to, _value);
		return true;
	}

	function transferFrom(
		address _from,
		address _to,
		uint256 _value
	) public returns (bool) {

		require(_from != address(0), "this is illegal address");
		require(_to != address(0), "this is illegal address");
		require(_value != 0, "illegal transfer value");

		IAllocator(config().allocator()).beforeBalanceChange(
			address(this),
			_from,
			_to
		);

		_transfer(_from, _to, _value);

		uint256 allowanceAmount = allowance(_from, msg.sender);
		_approve(
			_from,
			msg.sender,
			allowanceAmount.sub(
				_value,
				"ERC20: transfer amount exceeds allowance"
			)
		);
		return true;
	}

	function withdraw(address _sender, uint256 _value) external {

		require(msg.sender == config().lockup(), "this is illegal address");

		ERC20 devToken = ERC20(config().token());
		bool result = devToken.transfer(_sender, _value);
		require(result, "dev transfer failed");
	}
}


pragma solidity >=0.5.17;

interface IPropertyGroup {

	function addGroup(address _addr) external;


	function isGroup(address _addr) external view returns (bool);

}


pragma solidity >=0.5.17;

interface IMarket {

	function authenticate(
		address _prop,
		string calldata _args1,
		string calldata _args2,
		string calldata _args3,
		string calldata _args4,
		string calldata _args5
	) external returns (bool);


	function authenticateFromPropertyFactory(
		address _prop,
		address _author,
		string calldata _args1,
		string calldata _args2,
		string calldata _args3,
		string calldata _args4,
		string calldata _args5
	) external returns (bool);


	function authenticatedCallback(address _property, bytes32 _idHash)
		external
		returns (address);


	function deauthenticate(address _metrics) external;


	function schema() external view returns (string memory);


	function behavior() external view returns (address);


	function issuedMetrics() external view returns (uint256);


	function enabled() external view returns (bool);


	function votingEndBlockNumber() external view returns (uint256);


	function toEnable() external;

}


pragma solidity 0.5.17;






contract PropertyFactory is UsingConfig, IPropertyFactory {

	event Create(address indexed _from, address _property);
	event ChangeAuthor(
		address indexed _property,
		address _beforeAuthor,
		address _afterAuthor
	);
	event ChangeName(address indexed _property, string _old, string _new);
	event ChangeSymbol(address indexed _property, string _old, string _new);

	constructor(address _config) public UsingConfig(_config) {}

	modifier onlyProperty() {

		require(
			IPropertyGroup(config().propertyGroup()).isGroup(msg.sender),
			"illegal address"
		);
		_;
	}

	function create(
		string calldata _name,
		string calldata _symbol,
		address _author
	) external returns (address) {

		return _create(_name, _symbol, _author);
	}

	function createAndAuthenticate(
		string calldata _name,
		string calldata _symbol,
		address _market,
		string calldata _args1,
		string calldata _args2,
		string calldata _args3
	) external returns (bool) {

		return
			IMarket(_market).authenticateFromPropertyFactory(
				_create(_name, _symbol, msg.sender),
				msg.sender,
				_args1,
				_args2,
				_args3,
				"",
				""
			);
	}

	function _create(
		string memory _name,
		string memory _symbol,
		address _author
	) private returns (address) {

		Property property =
			new Property(address(config()), _author, _name, _symbol);

		IPropertyGroup(config().propertyGroup()).addGroup(address(property));

		emit Create(msg.sender, address(property));
		return address(property);
	}

	function createChangeAuthorEvent(address _old, address _new)
		external
		onlyProperty
	{

		emit ChangeAuthor(msg.sender, _old, _new);
	}

	function createChangeNameEvent(string calldata _old, string calldata _new)
		external
		onlyProperty
	{

		emit ChangeName(msg.sender, _old, _new);
	}

	function createChangeSymbolEvent(string calldata _old, string calldata _new)
		external
		onlyProperty
	{

		emit ChangeSymbol(msg.sender, _old, _new);
	}
}