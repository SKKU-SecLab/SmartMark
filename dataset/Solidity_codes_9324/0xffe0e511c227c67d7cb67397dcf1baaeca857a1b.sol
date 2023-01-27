pragma solidity ^0.5.0;

contract Context {

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
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
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal { }

}
pragma solidity ^0.5.0;


contract IOneSplitConsts {
    uint256 internal constant FLAG_DISABLE_UNISWAP = 0x01;
    uint256 internal constant DEPRECATED_FLAG_DISABLE_KYBER = 0x02; // Deprecated
    uint256 internal constant FLAG_DISABLE_BANCOR = 0x04;
    uint256 internal constant FLAG_DISABLE_OASIS = 0x08;
    uint256 internal constant FLAG_DISABLE_COMPOUND = 0x10;
    uint256 internal constant FLAG_DISABLE_FULCRUM = 0x20;
    uint256 internal constant FLAG_DISABLE_CHAI = 0x40;
    uint256 internal constant FLAG_DISABLE_AAVE = 0x80;
    uint256 internal constant FLAG_DISABLE_SMART_TOKEN = 0x100;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_ETH = 0x200; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_BDAI = 0x400;
    uint256 internal constant FLAG_DISABLE_IEARN = 0x800;
    uint256 internal constant FLAG_DISABLE_CURVE_COMPOUND = 0x1000;
    uint256 internal constant FLAG_DISABLE_CURVE_USDT = 0x2000;
    uint256 internal constant FLAG_DISABLE_CURVE_Y = 0x4000;
    uint256 internal constant FLAG_DISABLE_CURVE_BINANCE = 0x8000;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_DAI = 0x10000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_USDC = 0x20000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_CURVE_SYNTHETIX = 0x40000;
    uint256 internal constant FLAG_DISABLE_WETH = 0x80000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_COMPOUND = 0x100000; // Works only when one of assets is ETH or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_UNISWAP_CHAI = 0x200000; // Works only when ETH<>DAI or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_UNISWAP_AAVE = 0x400000; // Works only when one of assets is ETH or FLAG_ENABLE_MULTI_PATH_ETH
    uint256 internal constant FLAG_DISABLE_IDLE = 0x800000;
    uint256 internal constant FLAG_DISABLE_MOONISWAP = 0x1000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2 = 0x2000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_ETH = 0x4000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_DAI = 0x8000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_USDC = 0x10000000;
    uint256 internal constant FLAG_DISABLE_ALL_SPLIT_SOURCES = 0x20000000;
    uint256 internal constant FLAG_DISABLE_ALL_WRAP_SOURCES = 0x40000000;
    uint256 internal constant FLAG_DISABLE_CURVE_PAX = 0x80000000;
    uint256 internal constant FLAG_DISABLE_CURVE_RENBTC = 0x100000000;
    uint256 internal constant FLAG_DISABLE_CURVE_TBTC = 0x200000000;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_USDT = 0x400000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_WBTC = 0x800000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_TBTC = 0x1000000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_RENBTC = 0x2000000000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_DFORCE_SWAP = 0x4000000000;
    uint256 internal constant FLAG_DISABLE_SHELL = 0x8000000000;
    uint256 internal constant FLAG_ENABLE_CHI_BURN = 0x10000000000;
    uint256 internal constant FLAG_DISABLE_MSTABLE_MUSD = 0x20000000000;
    uint256 internal constant FLAG_DISABLE_CURVE_SBTC = 0x40000000000;
    uint256 internal constant FLAG_DISABLE_DMM = 0x80000000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_ALL = 0x100000000000;
    uint256 internal constant FLAG_DISABLE_CURVE_ALL = 0x200000000000;
    uint256 internal constant FLAG_DISABLE_UNISWAP_V2_ALL = 0x400000000000;
    uint256 internal constant FLAG_DISABLE_SPLIT_RECALCULATION = 0x800000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_ALL = 0x1000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_1 = 0x2000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_2 = 0x4000000000000;
    uint256 internal constant FLAG_DISABLE_BALANCER_3 = 0x8000000000000;
    uint256 internal constant DEPRECATED_FLAG_ENABLE_KYBER_UNISWAP_RESERVE = 0x10000000000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_KYBER_OASIS_RESERVE = 0x20000000000000; // Deprecated, Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_KYBER_BANCOR_RESERVE = 0x40000000000000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_ENABLE_REFERRAL_GAS_SPONSORSHIP = 0x80000000000000; // Turned off by default
    uint256 internal constant DEPRECATED_FLAG_ENABLE_MULTI_PATH_COMP = 0x100000000000000; // Deprecated, Turned off by default
    uint256 internal constant FLAG_DISABLE_KYBER_ALL = 0x200000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_1 = 0x400000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_2 = 0x800000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_3 = 0x1000000000000000;
    uint256 internal constant FLAG_DISABLE_KYBER_4 = 0x2000000000000000;
    uint256 internal constant FLAG_ENABLE_CHI_BURN_BY_ORIGIN = 0x4000000000000000;
}


contract IOneSplit is IOneSplitConsts {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution
        );

    function getExpectedReturnWithGas(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags, // See constants in IOneSplit.sol
        uint256 destTokenEthPriceTimesGasPrice
    )
        public
        view
        returns(
            uint256 returnAmount,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        );

    function swap(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 flags
    )
        public
        payable
        returns(uint256 returnAmount);
}


contract IOneSplitMulti is IOneSplit {
    function getExpectedReturnWithGasMulti(
        IERC20[] memory tokens,
        uint256 amount,
        uint256[] memory parts,
        uint256[] memory flags,
        uint256[] memory destTokenEthPriceTimesGasPrices
    )
        public
        view
        returns(
            uint256[] memory returnAmounts,
            uint256 estimateGasAmount,
            uint256[] memory distribution
        );

    function swapMulti(
        IERC20[] memory tokens,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256[] memory flags
    )
        public
        payable
        returns(uint256 returnAmount);
}// MIT
pragma solidity ^0.5.0;


contract Pool is ERC20 {
    
    using SafeMath for uint;

	address public constant EXCHANGE_CONTRACT = 0x50FDA034C0Ce7a8f7EFDAebDA7Aa7cA21CC1267e;
	address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
	address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

	address public TMTTokenAddress;

	uint[] public holders;

	address[] public tokens; 
	uint[] public weights;
	uint totalWeight;

	uint[] buf; 
	address[] newTokens;
	uint[] newWeights;

	uint newTotalWeight;

	mapping(address => uint) public tokenBalances;

	bool public active = true; 
	
	mapping(address => bool) public systemAddresses;
	
	modifier systemOnly {
	    require(systemAddresses[msg.sender], "system only");
	    _;
	}

	modifier isActive() { 
		require (active); 
		_; 
	}
	
	event Withdrawn(address indexed from, uint value);
	event WithdrawnToken(address indexed from, address indexed token, uint amount);
	
	function addSystemAddress(address newSystemAddress) public systemOnly {
	    systemAddresses[newSystemAddress] = true;
	}
	
	constructor(string memory name, string memory symbol, address _TMTTokenAddress, address[] memory _tokens, uint[] memory _weights) public ERC20(name, symbol) {
		require (_tokens.length == _weights.length, "invalid config length");
		
		systemAddresses[msg.sender] = true;

		TMTTokenAddress = _TMTTokenAddress;
		
		uint _totalWeight;

		for(uint i = 0; i < _tokens.length; i++) {
			tokens.push(_tokens[i]);
			weights.push(_weights[i]);
			_totalWeight += _weights[i];
		}

		totalWeight = _totalWeight;
	}

	function poolIn(address[] memory _tokens, uint[] memory _values) public payable isActive() {
		address[] memory returnedTokens;
		uint[] memory returnedAmounts;
		uint ethValue;
		
		if(_tokens.length == 0) {
			require (msg.value > 0.001 ether, "0.001 ether min pool in");
			ethValue = msg.value;

			(returnedTokens, returnedAmounts) = swap(ETH_ADDRESS, ethValue, tokens, weights, totalWeight);
		} else if(_tokens.length == 1) {
			ethValue = calculateTokensForEther(_tokens, _values);
			assert(ethValue > 0.001 ether);

			(returnedTokens, returnedAmounts) = swap(_tokens[0], _values[0], tokens, weights, totalWeight);
		} else {
			ethValue = sellTokensForEther(_tokens, _values);
			assert(ethValue > 0.001 ether);

			(returnedTokens, returnedAmounts) = swap(ETH_ADDRESS, ethValue, tokens, weights, totalWeight);
		}

		for (uint i = 0; i < returnedTokens.length; i++) {
			tokenBalances[returnedTokens[i]] += returnedAmounts[i];
		}

		_mint(msg.sender, ethValue);
	}

	function withdraw() public {
		uint _balance = balanceOf(msg.sender);
		uint localWeight = _balance.mul(1 ether).div(totalSupply());
		require(localWeight > 0, "no balance in this pool");

		_burn(msg.sender, _balance);

		for (uint i = 0; i < tokens.length; i++) {
			uint withdrawBalance = tokenBalances[tokens[i]].mul(localWeight).div(1 ether);
			tokenBalances[tokens[i]] = tokenBalances[tokens[i]].sub(withdrawBalance);
			IERC20(tokens[i]).transfer(msg.sender, withdrawBalance);

			emit WithdrawnToken(msg.sender, tokens[i], withdrawBalance);
		}


		emit Withdrawn(msg.sender, _balance);
	}

	function updatePool(address[] memory _tokens, uint[] memory _weights) public systemOnly {
	    
		require(_tokens.length == _weights.length, "invalid config length");
		
		uint _newTotalWeight;

		for(uint i = 0; i < _tokens.length; i++) {
			require (_tokens[i] != ETH_ADDRESS && _tokens[i] != WETH_ADDRESS);			
			_newTotalWeight += _weights[i];
		}
		
		newTokens = _tokens;
		newWeights = _weights;
		newTotalWeight = _newTotalWeight;

		rebalance();
	}

	function setPoolStatus(bool _active) public systemOnly {
		active = _active;
	}

	function calculateTokensForEther(address[] memory _tokens, uint[] memory _amounts) public view returns(uint) {
		uint _amount;
		uint _totalAmount;
		uint[] memory _distribution;
		for(uint i = 0; i < _tokens.length; i++) {
			(_amount, _distribution) = IOneSplit(EXCHANGE_CONTRACT).getExpectedReturn(IERC20(_tokens[i]), IERC20(WETH_ADDRESS), _amounts[i], 2, 0);
			_totalAmount += _amount;
		}

		return _totalAmount;
	}
	
	function sellTokensForEther(address[] memory _tokens, uint[] memory _amounts) internal returns(uint) {
		uint _amount;
		uint _totalAmount;
		uint[] memory _distribution;
		for(uint i = 0; i < _tokens.length; i++) {
		    if (_amounts[i] == 0) {
		        continue;
		    }
		    
		    if (_tokens[i] == WETH_ADDRESS) {
		        _totalAmount += _amounts[i];
		        continue;
		    }
		    IERC20(_tokens[i]).approve(EXCHANGE_CONTRACT, _amounts[i]);
		    
			(_amount, _distribution) = IOneSplit(EXCHANGE_CONTRACT).getExpectedReturn(IERC20(_tokens[i]), IERC20(WETH_ADDRESS), _amounts[i], 2, 0);
			if (_amount == 0) {
		        continue;
		    }
		    
			IOneSplit(EXCHANGE_CONTRACT).swap(IERC20(_tokens[i]), IERC20(WETH_ADDRESS), _amounts[i], _amount, _distribution, 0);

			_totalAmount += _amount;
		}

		return _totalAmount;
	}

	function rebalance() internal {
	    
		uint[] memory buf2;
		buf = buf2;

		for (uint i = 0; i < tokens.length; i++) {
			buf.push(tokenBalances[tokens[i]]);
			tokenBalances[tokens[i]] = 0;
		}
		
		
		uint ethValue = sellTokensForEther(tokens, buf);
		

		tokens = newTokens;
		weights = newWeights;
		totalWeight = newTotalWeight;
		
		if (ethValue == 0) {
		    return;
		}
		
		buf = buf2;
		swap2(WETH_ADDRESS, ethValue);
		
		for(uint i = 0; i < tokens.length; i++) {
			tokenBalances[tokens[i]] = buf[i];
		}
	}

	function swap(address _token, uint _value, address[] memory _tokens, uint[] memory _weights, uint _totalWeight) internal returns(address[] memory, uint[] memory) {
		uint _tokenPart;
		uint _amount;
		uint[] memory _distribution;
        
		for(uint i = 0; i < _tokens.length; i++) {
			_tokenPart = _value.mul(_weights[i]).div(_totalWeight);

			(_amount, _distribution) = IOneSplit(EXCHANGE_CONTRACT).getExpectedReturn(IERC20(_token), IERC20(_tokens[i]), _tokenPart, 2, 0);

			if (_token == ETH_ADDRESS) {
				IOneSplit(EXCHANGE_CONTRACT).swap.value(_tokenPart)(IERC20(_token), IERC20(_tokens[i]), _tokenPart, _amount, _distribution, 0);
			} else {
			    IERC20(_tokens[i]).approve(EXCHANGE_CONTRACT, _tokenPart);
				IOneSplit(EXCHANGE_CONTRACT).swap(IERC20(_token), IERC20(_tokens[i]), _tokenPart, _amount, _distribution, 0);
			}
			
			_weights[i] = _amount;
		}
		
		return (_tokens, _weights);
	}
	
	function swap2(address _token, uint _value) internal {
		uint _tokenPart;
		uint _amount;
		
		uint[] memory _distribution;
		
		IERC20(_token).approve(EXCHANGE_CONTRACT, _value);
		
		for(uint i = 0; i < newTokens.length; i++) {
            
			_tokenPart = _value.mul(newWeights[i]).div(newTotalWeight);
			
			if(_tokenPart == 0) {
			    buf.push(0);
			    continue;
			}
			
			(_amount, _distribution) = IOneSplit(EXCHANGE_CONTRACT).getExpectedReturn(IERC20(_token), IERC20(newTokens[i]), _tokenPart, 5, 0);
			
			
			IOneSplit(EXCHANGE_CONTRACT).swap(IERC20(_token), IERC20(newTokens[i]), _tokenPart, _amount, _distribution, 0);
            buf.push(_amount);
            
            
		}
	}

	function calculateAmountsViaWeights(uint _ethAmount) public view returns(uint[] memory res) {
		for(uint i = 1; i <= tokens.length; i++) {
			res[i] = _ethAmount.mul(weights[i]).div(totalWeight);
		}
	}
}