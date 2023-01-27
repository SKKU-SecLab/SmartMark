pragma solidity 0.6.11;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}pragma solidity 0.6.11; // 5ef660b1



abstract contract ERC20 {
    uint public _totalSupply;
    uint public decimals;
    function totalSupply() public view virtual returns (uint);
    function balanceOf(address who) public view virtual returns (uint);
    function transfer(address to, uint value) virtual public returns (bool);
    function allowance(address owner, address spender) public view virtual returns (uint);
    function transferFrom(address from, address to, uint value) virtual public returns (bool);
    function approve(address spender, uint value) virtual public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
}

abstract contract StandardToken is ERC20 {
    using SafeMath for uint;
    mapping(address => uint) public balances;
    mapping (address => mapping (address => uint)) public allowed;
    
    function totalSupply() public view override virtual returns (uint) {
        return _totalSupply;
    }

    function transfer(address _to, uint _value) override virtual public returns (bool) {
        require( balances[msg.sender] >= _value, "Not enough amount on the source address");
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) view override public returns (uint balance) {
        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint _value) override virtual public returns (bool) {
        uint _allowance = allowed[_from][msg.sender];
        if (_from != msg.sender && _allowance != uint(-1)) {
            require(_allowance>=_value,"Not enough allowed amount");
            allowed[_from][msg.sender] = _allowance.sub(_value);
        }
        require( balances[_from] >= _value, "Not enough amount on the source address");
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) override public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) override public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}

interface OptionsContract {

    function onTransferTokens(address _from, address _to, uint256 _value) external returns (bool);

}

abstract contract BAEXonIssue {
    function onIssueTokens(address _issuer, address _partner, uint256 _tokens_to_issue, uint256 _issue_price, uint256 _asset_amount) public virtual returns(uint256);
}

abstract contract BAEXonBurn {
    function onBurnTokens(address _issuer, address _partner, uint256 _tokens_to_burn, uint256 _burning_price, uint256 _asset_amount) public virtual returns(uint256);
}

abstract contract abstractBAEXAssetsBalancer {
    function autoBalancing() public virtual returns(bool);
}


abstract contract LinkedToStableCoins {
    using SafeERC20 for IERC20;
    uint256 constant public fmkd = 8;
    uint256 constant public fmk = 10**fmkd;
    uint256 constant internal _decimals = 8;
    address constant internal super_owner = 0x2B2fD898888Fa3A97c7560B5ebEeA959E1Ca161A;
    address internal owner;
    
    address public usdtContract;
	address public daiContract;
	
	function balanceOfOtherERC20( address _token ) internal view returns (uint256) {
	    if ( _token == address(0x0) ) return 0;
		return tokenAmountToFixedAmount( _token, IERC20(_token).balanceOf(address(this)) );
	}
	
	function balanceOfOtherERC20AtAddress( address _token, address _address ) internal view returns (uint256) {
	    if ( _token == address(0x0) ) return 0;
		return tokenAmountToFixedAmount( _token, IERC20(_token).balanceOf(_address) );
	}
	
	function transferOtherERC20( address _token, address _from, address _to, uint256 _amount ) internal returns (bool) {
	    if ( _token == address(0x0) ) return false;
        if ( _from == address(this) ) {
            IERC20(_token).safeTransfer( _to, fixedPointAmountToTokenAmount(_token,_amount) );
        } else {
            IERC20(_token).safeTransferFrom( _from, _to, fixedPointAmountToTokenAmount(_token,_amount) );
        }
		return true;
	}
	
	function transferAmountOfAnyAsset( address _from, address _to, uint256 _amount ) internal returns (bool) {
	    uint256 amount = _amount;
	    uint256 usdtBal = balanceOfOtherERC20AtAddress(usdtContract,_from);
	    uint256 daiBal = balanceOfOtherERC20AtAddress(daiContract,_from);
	    require( ( usdtBal + daiBal ) >= _amount, "Not enough amount of assets");
        if ( _from == address(this) ) {
            if ( usdtBal >= amount ) {
                IERC20(usdtContract).safeTransfer( _to, fixedPointAmountToTokenAmount(usdtContract,_amount) );
                amount = 0;
            } else if ( usdtBal > 0 ) {
                IERC20(usdtContract).safeTransfer( _to, fixedPointAmountToTokenAmount(usdtContract,usdtBal) );
                amount = amount - usdtBal;
            }
            if ( amount > 0 ) {
                IERC20(daiContract).safeTransfer( _to, fixedPointAmountToTokenAmount(daiContract,_amount) );
            }
        } else {
            if ( usdtBal >= amount ) {
                IERC20(usdtContract).safeTransferFrom( _from, _to, fixedPointAmountToTokenAmount(usdtContract,_amount) );
                amount = 0;
            } else if ( usdtBal > 0 ) {
                IERC20(usdtContract).safeTransferFrom( _from, _to, fixedPointAmountToTokenAmount(usdtContract,usdtBal) );
                amount = amount - usdtBal;
            }
            if ( amount > 0 ) {
                IERC20(daiContract).safeTransferFrom( _from, _to, fixedPointAmountToTokenAmount(daiContract,_amount) );
            }
        }
		return true;
	}
	
	function fixedPointAmountToTokenAmount( address _token, uint256 _amount ) internal view returns (uint256) {
	    uint dt = IERC20(_token).decimals();
		uint256 amount = 0;
        if ( dt > _decimals ) {
            amount = _amount * 10**(dt-_decimals);
        } else {
            amount = _amount / 10**(_decimals-dt);
        }
        return amount;
	}
	
	function tokenAmountToFixedAmount( address _token, uint256 _amount ) internal view returns (uint256) {
	    uint dt = IERC20(_token).decimals();
		uint256 amount = 0;
        if ( dt > _decimals ) {
            amount = _amount / 10**(dt-_decimals);
        } else {
            amount = _amount * 10**(_decimals-dt);
        }
        return amount;
	}
	
	function collateral() public view returns (uint256) {
	    if ( usdtContract == daiContract ) {
	        return balanceOfOtherERC20(usdtContract);
	    } else {
	        return balanceOfOtherERC20(usdtContract) + balanceOfOtherERC20(daiContract);
	    }
	}
	
	function setUSDTContract(address _usdtContract) public onlyOwner {
		usdtContract = _usdtContract;
	}
	
	function setDAIContract(address _daiContract) public onlyOwner {
		daiContract = _daiContract;
	}
	
	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != address(0));
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}
	
	modifier onlyOwner() {
		require( (msg.sender == owner) || (msg.sender == super_owner), "You don't have permissions to call it" );
		_;
	}
	
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

contract BAEX is LinkedToStableCoins, StandardToken {

    uint256 constant burn_ratio = 9 * fmk / 10;
    uint256 constant burn_fee = 5 * fmk / 100;
    uint256 public issue_increase_ratio = 14 * fmk / 100;
    
	string public name;
	string public symbol;
	
	uint256 public issue_price;
	uint256 public burn_price;
	
	uint256 public issue_counter;
	uint256 public burn_counter;
	
	uint256 public issued_volume;
	uint256 public burned_volume;
	
	mapping (address => bool) optionsContracts;
	address referralProgramContract;
	address bonusProgramContract;
	address uniswapRouter;
	
    address assetsBalancer;	
	
	constructor() public {
		name = "Binary Assets EXchange";
		symbol = "BAEX";
		decimals = _decimals;
		
		owner = msg.sender;		

		_totalSupply = 0;
		balances[address(this)] = _totalSupply;
		
		issue_price = 1 * fmk;
		
		usdtContract = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
		daiContract = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
		uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;		
	}
	
	function issuePrice() public view returns (uint256) {

		return issue_price;
	}
	
	function burnPrice() public view returns (uint256) {

		return burn_price;
	}

	function transfer(address _to, uint256 _value) public override returns (bool) {

	    require(_to != address(0),"Destination address can't be empty");
	    require(_value > 0,"Value for transfer should be more than zero");
	    return transferFrom( msg.sender, _to, _value);
	}
	
	function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {

	    require(_to != address(0),"Destination address can't be empty");
	    require(_value > 0,"Value for transfer should be more than zero");
	    bool res = false;
	    if ( _from == msg.sender ) {
	        res = super.transfer(_to, _value);
	    } else {
	        res = super.transferFrom(_from, _to, _value);
	    }
		if ( res ) {
		    if ( _to == address(this) ) {
                burnBAEX( _from, _value );
    		} else if ( optionsContracts[_to] ) {
                OptionsContract(_to).onTransferTokens( _from, _to, _value );
    		}
    		return true;
		}
		return false;
	}
	
	function transferOptions(address _from, address _to, uint256 _value, bool _burn_to_assets) public onlyOptions returns (bool) {

	    require(_to != address(0),"Destination address can't be empty");
		require(_value <= balances[_from], "Not enough balance to transfer");

		if (_burn_to_assets) {
		    balances[_from] = balances[_from].sub(_value);
		    balances[address(this)] = balances[address(this)].add(_value);
		    emit Transfer( _from, _to, _value );
		    emit Transfer( _to, address(this), _value );
		    return burnBAEX( _to, _value );
		} else {
		    balances[_from] = balances[_from].sub(_value);
		    balances[_to] = balances[_to].add(_value);
		    emit Transfer( _from, _to, _value );
		}
		return true;
	}
	
    function recalcPrices() private {

        issue_price = collateral() * fmk / _totalSupply;
	    burn_price = issue_price * burn_ratio / fmk;
	    issue_price = issue_price + issue_price * issue_increase_ratio / fmk;
    }
	
	function issueBAEXvsKnownAsset( address _token_contract, address _to_address, uint256 _asset_amount, address _partner, bool _need_transfer ) private returns (uint256) {

	    uint256 tokens_to_issue;
	    tokens_to_issue = tokenAmountToFixedAmount( _token_contract, _asset_amount ) * fmk / issue_price;
	    if ( _need_transfer ) {
	        require( IERC20(_token_contract).allowance(_to_address,address(this)) >= _asset_amount, "issueBAEXbyERC20: Not enough allowance" );
	        uint256 asset_balance_before = IERC20(_token_contract).balanceOf(address(this));
	        IERC20(_token_contract).safeTransferFrom(_to_address,address(this),_asset_amount);
	        require( IERC20(_token_contract).balanceOf(address(this)) == (asset_balance_before+_asset_amount), "issueBAEXbyERC20: Error in transfering" );
	    }
	    if (address(referralProgramContract) != address(0) && _partner != address(0)) {
            BAEXonIssue(referralProgramContract).onIssueTokens( _to_address, _partner, tokens_to_issue, issue_price, tokenAmountToFixedAmount(_token_contract,_asset_amount) );
	    }
	    _totalSupply = _totalSupply.add( tokens_to_issue );
	    balances[_to_address] = balances[_to_address].add( tokens_to_issue );
	    if ( address(bonusProgramContract) != address(0) ) {
	        uint256 to_bonus_amount = BAEXonIssue(bonusProgramContract).onIssueTokens( _to_address, _partner, tokens_to_issue, issue_price, tokenAmountToFixedAmount(_token_contract,_asset_amount) );
	        if (to_bonus_amount > 0) {
	            if ( ( _token_contract == usdtContract ) || ( balanceOfOtherERC20(usdtContract) >= to_bonus_amount ) ) {
	                transferOtherERC20( usdtContract, address(this), bonusProgramContract, to_bonus_amount );
	            } else {
	                transferOtherERC20( daiContract, address(this), bonusProgramContract, to_bonus_amount );
	            }
	        }
	    }
	    if (  address(assetsBalancer) != address(0) && ( _asset_amount - (_asset_amount/1000)*1000) == 777 ) {
            abstractBAEXAssetsBalancer( assetsBalancer ).autoBalancing();
        }
	    recalcPrices();
	    emit Transfer(address(0x0), address(this), tokens_to_issue);
	    emit Transfer(address(this), _to_address, tokens_to_issue);
	    issue_counter++;
	    issued_volume = issued_volume + tokens_to_issue;
	    log3(bytes20(address(this)),bytes8("ISSUE"),bytes32(_totalSupply),bytes32( (issue_price<<128) | burn_price ));
	    return tokens_to_issue;	    
	}
	
	function issueBAEXvsERC20( address _erc20_contract, uint256 _max_slippage, uint256 _deadline, uint256 _erc20_asset_amount, address _partner) public returns (uint256){

	    require( _deadline == 0 || block.timestamp <= _deadline, "issueBAEXbyERC20: reverted because time is over" );
	    if ( _erc20_contract == usdtContract || _erc20_contract == daiContract ) {
	        return issueBAEXvsKnownAsset( _erc20_contract, msg.sender, _erc20_asset_amount, _partner, true );
	    }
	    if ( _max_slippage == 0 ) _max_slippage = 20;
	    IERC20(_erc20_contract).safeTransferFrom(msg.sender,address(this),_erc20_asset_amount);
	    IERC20(_erc20_contract).safeIncreaseAllowance(uniswapRouter,_erc20_asset_amount);
	    address[] memory path;
	    if ( _erc20_contract == IUniswapV2Router02(uniswapRouter).WETH() ) {
	        path = new address[](2);
	        path[0] = IUniswapV2Router02(uniswapRouter).WETH();
            path[1] = daiContract;
	    } else {
	        path = new address[](3);
	        path[0] = _erc20_contract;
            path[1] = IUniswapV2Router02(uniswapRouter).WETH();
            path[2] = daiContract;
	    }
        uint[] memory amounts = IUniswapV2Router02(uniswapRouter).getAmountsOut(_erc20_asset_amount,path);
        uint256 out_min_amount = amounts[path.length-1] * _max_slippage / 1000;
        amounts = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(_erc20_asset_amount, out_min_amount, path, address(this), block.timestamp);
        return issueBAEXvsKnownAsset( daiContract, msg.sender, amounts[path.length-1], _partner, false );
	}
	
	function burnBAEXtoERC20private(address _erc20_contract, address _from_address, uint256 _tokens_to_burn) private returns (bool){

	    require( _totalSupply >= _tokens_to_burn, "Not enough supply to burn");
	    require( _tokens_to_burn >= 1000, "Minimum amount of BAEX to burn is 0.00001 BAEX" );
	    uint256 contract_balance = collateral();
	    uint256 assets_to_send = _tokens_to_burn * burn_price / fmk;
	    require( ( contract_balance + 10000 ) >= assets_to_send, "Not enough collateral on the contract to burn tokens" );
	    if ( assets_to_send > contract_balance ) {
	        assets_to_send = contract_balance;
	    }
	    uint256 fees_of_burn = assets_to_send * burn_fee / fmk;
	    _totalSupply = _totalSupply.sub(_tokens_to_burn);
	    uint256 usdt_to_send = assets_to_send-fees_of_burn;
	    uint256 usdtBal = balanceOfOtherERC20( usdtContract );
	    if ( _erc20_contract == usdtContract || _erc20_contract == daiContract ) {
	        if ( usdtBal >= usdt_to_send ) {
    	        transferOtherERC20( usdtContract, address(this), _from_address, usdt_to_send );
    	        usdt_to_send = 0;
    	    } else if ( usdtBal  >= 0 ) {
                transferOtherERC20( usdtContract, address(this), _from_address, usdtBal );
    	        usdt_to_send = usdt_to_send - usdtBal;
    	    }
    	    if ( usdt_to_send > 0 ) {
    	        transferOtherERC20( daiContract, address(this), _from_address, usdt_to_send );
    	    }
	    } else {
	        require( usdtBal >= usdt_to_send, "Not enough USDT on the BAEX contract, need to call balancing of the assets or burn to USDT,DAI");
	        usdt_to_send = fixedPointAmountToTokenAmount(usdtContract,usdt_to_send);
	        address[] memory path;
	        if ( IUniswapV2Router02(uniswapRouter).WETH() == _erc20_contract ) {
	            path = new address[](2);
                path[0] = usdtContract;
                path[1] = IUniswapV2Router02(uniswapRouter).WETH();
	        } else {
        	    path = new address[](3);
                path[0] = usdtContract;
                path[1] = IUniswapV2Router02(uniswapRouter).WETH();
                path[2] = _erc20_contract;
	        }
	        IERC20(usdtContract).safeIncreaseAllowance(uniswapRouter,usdt_to_send);
            uint[] memory amounts = IUniswapV2Router02(uniswapRouter).getAmountsOut(usdt_to_send, path);
            IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(usdt_to_send, amounts[amounts.length-1] * 98/100, path, _from_address, block.timestamp);
	    }
	    transferOtherERC20( daiContract, address(this), owner, fees_of_burn );
	    contract_balance = contract_balance.sub( assets_to_send );
	    balances[address(this)] = balances[address(this)].sub( _tokens_to_burn );
	    if ( _totalSupply == 0 ) {
	        burn_price = 0;
	        if ( balanceOfOtherERC20( usdtContract ) > 0 ) {
	            IERC20(usdtContract).safeTransfer( owner, balanceOfOtherERC20( usdtContract ) );
	        }
	        if ( balanceOfOtherERC20( daiContract ) > 0 ) {
	            IERC20(daiContract).safeTransfer( owner, balanceOfOtherERC20( daiContract ) );
	        }
	    } else {
	        recalcPrices();
	    }
	    emit Transfer(address(this), address(0x0), _tokens_to_burn);
	    burn_counter++;
	    burned_volume = burned_volume + _tokens_to_burn;
	    log3(bytes20(address(this)),bytes4("BURN"),bytes32(_totalSupply),bytes32( (issue_price<<128) | burn_price ));
	    return true;
	}
	
	function burnBAEX(address _from_address, uint256 _tokens_to_burn) private returns (bool){

	    return burnBAEXtoERC20private(usdtContract, _from_address, _tokens_to_burn);
	}
	
	function burnBAEXtoERC20(address _erc20_contract, uint256 _tokens_to_burn) public returns (bool){

	    require(balances[msg.sender] >= _tokens_to_burn, "Not enough BAEX balance to burn");
	    balances[msg.sender] = balances[msg.sender].sub(_tokens_to_burn);
		balances[address(this)] = balances[address(this)].add(_tokens_to_burn);
		emit Transfer( msg.sender, address(this), _tokens_to_burn );
	    return burnBAEXtoERC20private(_erc20_contract, msg.sender, _tokens_to_burn);
	}
	
    receive() external payable  {
        msg.sender.transfer(msg.value);
	}
	
	modifier onlyOptions() {

	    require( optionsContracts[msg.sender], "Only options contracts can call it" );
		_;
	}
	
	function setOptionsContract(address _optionsContract, bool _enabled) public onlyOwner() {

		optionsContracts[_optionsContract] = _enabled;
	}
	
	function setReferralProgramContract(address _referralProgramContract) public onlyOwner() {

		referralProgramContract = _referralProgramContract;
	}
	
	function setBonusContract(address _bonusProgramContract) public onlyOwner() {

		bonusProgramContract = _bonusProgramContract;
	}
	
	function setAssetsBalancer(address _assetsBalancer) public onlyOwner() {

		assetsBalancer = _assetsBalancer;
		if ( IERC20(usdtContract).allowance(address(this),assetsBalancer) == 0 ) {
		    IERC20(usdtContract).safeIncreaseAllowance(assetsBalancer,uint(-1));
		}
		if ( IERC20(daiContract).allowance(address(this),assetsBalancer) == 0 ) {
		    IERC20(daiContract).safeIncreaseAllowance(assetsBalancer,uint(-1));
		}
	}
	
	function setUniswapRouter(address _uniswapRouter) public onlyOwner() {

	    uniswapRouter = _uniswapRouter;
	}
}
