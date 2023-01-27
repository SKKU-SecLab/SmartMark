pragma solidity ^0.7.0;

interface IERC20WithPermit {

	function transferFrom(
		address from,
		address to,
		uint256 value
	) external returns (bool);


	function approve(address spender, uint256 value) external returns (bool);


	function allowance(address owner, address spender) external view returns (uint256);


	function permit(
		address owner,
		address spender,
		uint256 value,
		uint256 deadline,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;

}// MIT
pragma solidity ^0.7.0;

interface ISwapRouter {

	function WETH() external pure returns (address);


	function swapExactETHForTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);


	function swapExactTokensForTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);


	function removeLiquidity(
		address tokenA,
		address tokenB,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountA, uint256 amountB);


	function removeLiquidityETH(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountToken, uint256 amountETH);

}// MIT
pragma solidity ^0.7.0;

interface ISwapFactory {

	function getPair(address tokenA, address tokenB) external view returns (address);

}// MIT
pragma solidity ^0.7.0;

interface IERC20Pair {

	function token0() external pure returns (address);


	function token1() external pure returns (address);


	function balanceOf(address user) external view returns (uint256);


	function totalSupply() external view returns (uint256);


	function getReserves()
		external
		view
		returns (
			uint112 _reserve0,
			uint112 _reserve1,
			uint32 _blockTimestampLast
		);


	function permit(
		address owner,
		address spender,
		uint256 value,
		uint256 deadline,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

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
}// MIT

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// UNLICENSED
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;


contract Constant {

	address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
	address public constant uniRouterV2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
	address public constant uniswapV2Factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
	address public constant sushiRouter = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
	address public constant sushiFactory = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
	uint256 public constant deadline = 0xf000000000000000000000000000000000000000000000000000000000000000;
}

contract RapidHelper {

	using SafeERC20 for IERC20;

	function permitApprove(
		address _token,
		address _owner,
		uint256 _deadlinePermit,
		uint8 v,
		bytes32 r,
		bytes32 s
	) internal returns (bool) {

		IERC20WithPermit(_token).permit(_owner, address(this), type(uint256).max, _deadlinePermit, v, r, s);
		return true;
	}
}

contract RapidUni is Constant, RapidHelper {

	using SafeERC20 for IERC20;

	function getPath(address _tokenIn, address _tokenOut) private view returns (address[] memory path) {

		address pair = ISwapFactory(uniswapV2Factory).getPair(_tokenIn, _tokenOut);
		if (pair == address(0)) {
			path = new address[](3);
			path[0] = _tokenIn;
			path[1] = WETH;
			path[2] = _tokenOut;
		} else {
			path = new address[](2);
			path[0] = _tokenIn;
			path[1] = _tokenOut;
		}
	}

	function _uniswapTokenForToken(
		address _tokenIn,
		address _tokenOut,
		uint256 amount,
		uint256 expectedAmount,
		uint256 _deadline
	) internal {

		ISwapRouter(uniRouterV2).swapExactTokensForTokens(amount, expectedAmount, getPath(_tokenIn, _tokenOut), address(this), _deadline);
	}

	function _uniswapETHForToken(
		address _tokenOut,
		uint256 expectedAmount,
		uint256 _deadline,
		uint256 _amount
	) internal {

		ISwapRouter(uniRouterV2).swapExactETHForTokens{ value: _amount }(expectedAmount, getPath(WETH, _tokenOut), address(this), _deadline); // amounts[0] = WETH, amounts[1] = DAI
	}

	function _removeUniLpETH(address _token, uint256 _lpAmount) private returns (uint256 amountToken, uint256 amountETH) {

		(amountToken, amountETH) = ISwapRouter(uniRouterV2).removeLiquidityETH(_token, _lpAmount, 0, 0, address(this), deadline);
	}

	function _removeUniLpTokens(
		address _tokenA,
		address _tokenB,
		uint256 _lpAmount
	) private returns (uint256 amount0, uint256 amount1) {

		(amount0, amount1) = ISwapRouter(uniRouterV2).removeLiquidity(_tokenA, _tokenB, _lpAmount, 0, 0, address(this), deadline);
	}

	function _rapidUni(
		address _tokenOut,
		address[] memory standardTokens,
		uint256[] memory standardTokensAmounts,
		uint256[] memory amountOutMin1,
		address[] memory eip712Tokens,
		uint256[] memory eip712TokensAmounts,
		uint256[] memory amountOutMin2,
		uint8[] memory v,
		bytes32[] memory r,
		bytes32[] memory s
	) internal returns (bool) {

		for (uint256 i = 0; i < standardTokens.length; i++) {
			if (IERC20(standardTokens[i]).allowance(address(this), uniRouterV2) == 0) {
				IERC20(standardTokens[i]).safeApprove(uniRouterV2, type(uint256).max);
			}
			IERC20(standardTokens[i]).safeTransferFrom(msg.sender, address(this), standardTokensAmounts[i]);
			_uniswapTokenForToken(standardTokens[i], _tokenOut, standardTokensAmounts[i], amountOutMin1[i], deadline);
		}
		for (uint256 i = 0; i < eip712Tokens.length; i++) {
			if (IERC20WithPermit(eip712Tokens[i]).allowance(msg.sender, address(this)) == 0) {
				permitApprove(eip712Tokens[i], msg.sender, deadline, v[i], r[i], s[i]);
			}
			IERC20WithPermit(eip712Tokens[i]).transferFrom(msg.sender, address(this), eip712TokensAmounts[i]);
			if (IERC20WithPermit(eip712Tokens[i]).allowance(address(this), uniRouterV2) == 0) {
				IERC20WithPermit(eip712Tokens[i]).approve(uniRouterV2, type(uint256).max);
			}
			_uniswapTokenForToken(eip712Tokens[i], _tokenOut, eip712TokensAmounts[i], amountOutMin2[i], deadline);
		}

		if (msg.value > 0) {
			_uniswapETHForToken(_tokenOut, 0, deadline, msg.value);
		}
		return true;
	}

	function _rapidUniLP(
		uint256 deadlinePermit,
		address _tokenOut,
		address[] memory lpTokens,
		uint256[] memory lpTokensAmount,
		uint8[] memory v,
		bytes32[] memory r,
		bytes32[] memory s
	) internal returns (bool) {

		for (uint256 i = 0; i < lpTokens.length; i++) {
			require(lpTokens[i] != address(0), 'Invalid-pool-address');
			require(lpTokensAmount[i] > 0, 'Invalid-amount');
			IERC20Pair pair = IERC20Pair(lpTokens[i]);
			address token0 = pair.token0();
			address token1 = pair.token1();
			if (IERC20(lpTokens[i]).allowance(msg.sender, address(this)) == 0) {
				permitApprove(lpTokens[i], msg.sender, deadlinePermit, v[i], r[i], s[i]);
			}
		
			IERC20(lpTokens[i]).safeTransferFrom(msg.sender, address(this), lpTokensAmount[i]);
			if (IERC20(lpTokens[i]).allowance(address(this), uniRouterV2) == 0) {
				IERC20(lpTokens[i]).safeApprove(uniRouterV2, type(uint256).max);
			}	
			if (token0 == WETH || token1 == WETH) {
				address _token = token0 == WETH ? token1 : token0;
				(uint256 amountToken, uint256 amountETH) = _removeUniLpETH(_token, lpTokensAmount[i]);
				_uniswapETHForToken(_tokenOut, 0, deadline, amountETH);
				if (IERC20(_token).allowance(address(this), uniRouterV2) == 0) {
					IERC20(_token).safeApprove(uniRouterV2, type(uint256).max);
				}
				_uniswapTokenForToken(_token, _tokenOut, amountToken, 0, deadline);
			} else {
				(uint256 amount0, uint256 amount1) = _removeUniLpTokens(token0, token1, lpTokensAmount[i]);
				if (token0 == _tokenOut) {
					if (IERC20(token1).allowance(address(this), uniRouterV2) == 0) {
						IERC20(token1).safeApprove(uniRouterV2, type(uint256).max);
					}
					_uniswapTokenForToken(token1, _tokenOut, amount1, 0, deadline);
				} else if (token1 == _tokenOut) {
					if (IERC20(token0).allowance(address(this), uniRouterV2) == 0) {
						IERC20(token0).safeApprove(uniRouterV2, type(uint256).max);
					}
					_uniswapTokenForToken(token0, _tokenOut, amount0, 0, deadline);
				} else {
					if (IERC20(token1).allowance(address(this), uniRouterV2) == 0) {
						IERC20(token1).safeApprove(uniRouterV2, type(uint256).max);
					}
					if (IERC20(token0).allowance(address(this), uniRouterV2) == 0) {
						IERC20(token0).safeApprove(uniRouterV2, type(uint256).max);
					}
					_uniswapTokenForToken(token0, _tokenOut, amount0, 0, deadline);
					_uniswapTokenForToken(token1, _tokenOut, amount1, 0, deadline);
				}
			}
		}
		return true;
	}
}

contract RapidSushi is Constant, RapidHelper {

	using SafeERC20 for IERC20;

	function getPathSushi(address _tokenIn, address _tokenOut) private view returns (address[] memory path) {

		address pair = ISwapFactory(sushiFactory).getPair(_tokenIn, _tokenOut);
		if (pair == address(0)) {
			path = new address[](3);
			path[0] = _tokenIn;
			path[1] = WETH;
			path[2] = _tokenOut;
		} else {
			path = new address[](2);
			path[0] = _tokenIn;
			path[1] = _tokenOut;
		}
	}

	function _sushiswapTokenForToken(
		address _tokenIn,
		address _tokenOut,
		uint256 amount,
		uint256 expectedAmount,
		uint256 _deadline
	) internal {

		ISwapRouter(sushiRouter).swapExactTokensForTokens(amount, expectedAmount, getPathSushi(_tokenIn, _tokenOut), address(this), _deadline);
	}

	function _sushiswapETHForToken(
		address _tokenOut,
		uint256 expectedAmount,
		uint256 _deadline,
		uint256 _amount
	) internal {

		ISwapRouter(sushiRouter).swapExactETHForTokens{ value: _amount }(expectedAmount, getPathSushi(WETH, _tokenOut), address(this), _deadline); // amounts[0] = WETH, amounts[1] = DAI
	}

	function _removeSushiLpETH(address _token, uint256 _lpAmount) private returns (uint256 amountToken, uint256 amountETH) {

		(amountToken, amountETH) = ISwapRouter(sushiRouter).removeLiquidityETH(_token, _lpAmount, 0, 0, address(this), deadline);
	}

	function _removeSushiLpTokens(
		address _tokenA,
		address _tokenB,
		uint256 _lpAmount
	) private returns (uint256 amount0, uint256 amount1) {

		(amount0, amount1) = ISwapRouter(sushiRouter).removeLiquidity(_tokenA, _tokenB, _lpAmount, 0, 0, address(this), deadline);
	}

	function _rapidSushi(
		address _tokenOut,
		address[] memory standardTokens,
		uint256[] memory standardTokensAmounts,
		uint256[] memory amountOutMin1,
		address[] memory eip712Tokens,
		uint256[] memory eip712TokensAmounts,
		uint256[] memory amountOutMin2,
		uint8[] memory v,
		bytes32[] memory r,
		bytes32[] memory s
	) internal returns (bool) {

		for (uint256 i = 0; i < standardTokens.length; i++) {
			if (IERC20(standardTokens[i]).allowance(address(this), sushiRouter) == 0) {
				IERC20(standardTokens[i]).safeApprove(sushiRouter, type(uint256).max);
			}
			IERC20(standardTokens[i]).safeTransferFrom(msg.sender, address(this), standardTokensAmounts[i]);
			_sushiswapTokenForToken(standardTokens[i], _tokenOut, standardTokensAmounts[i], amountOutMin1[i], deadline);
		}
		for (uint256 i = 0; i < eip712Tokens.length; i++) {
			if (IERC20WithPermit(eip712Tokens[i]).allowance(msg.sender, address(this)) == 0) {
				permitApprove(eip712Tokens[i], msg.sender, deadline, v[i], r[i], s[i]);
			}
			IERC20WithPermit(eip712Tokens[i]).transferFrom(msg.sender, address(this), eip712TokensAmounts[i]);
			if (IERC20WithPermit(eip712Tokens[i]).allowance(address(this), sushiRouter) == 0) {
				IERC20WithPermit(eip712Tokens[i]).approve(sushiRouter, type(uint256).max);
			}
			_sushiswapTokenForToken(eip712Tokens[i], _tokenOut, eip712TokensAmounts[i], amountOutMin2[i], deadline);
		}

		if (msg.value > 0) {
			_sushiswapETHForToken(_tokenOut, 0, deadline, msg.value);
		}
		return true;
	}

	function _rapidSushiLP(
		uint256 deadlinePermit,
		address _tokenOut,
		address[] memory lpTokens,
		uint256[] memory lpTokensAmount,
		uint8[] memory v,
		bytes32[] memory r,
		bytes32[] memory s
	) internal returns (bool) {

		for (uint256 i = 0; i < lpTokens.length; i++) {
			require(lpTokens[i] != address(0), 'Invalid-pool-address');
			require(lpTokensAmount[i] > 0, 'Invalid-amount');
			IERC20Pair pair = IERC20Pair(lpTokens[i]);
			address token0 = pair.token0();
			address token1 = pair.token1();
			if (IERC20(lpTokens[i]).allowance(msg.sender, address(this)) == 0) {
				permitApprove(lpTokens[i], msg.sender, deadlinePermit, v[i], r[i], s[i]);
			}

			IERC20(lpTokens[i]).safeTransferFrom(msg.sender, address(this), lpTokensAmount[i]);
			IERC20(lpTokens[i]).safeApprove(sushiRouter, lpTokensAmount[i]);

			if (token0 == WETH || token1 == WETH) {
				address _token = token0 == WETH ? token1 : token0;
				(uint256 amountToken, uint256 amountETH) = _removeSushiLpETH(_token, lpTokensAmount[i]);
				_sushiswapETHForToken(_tokenOut, 0, deadline, amountETH);
				if (IERC20(_token).allowance(address(this), sushiRouter) == 0) {
					IERC20(_token).safeApprove(sushiRouter, type(uint256).max);
				}
				_sushiswapTokenForToken(_token, _tokenOut, amountToken, 0, deadline);
			} else {
				(uint256 amount0, uint256 amount1) = _removeSushiLpTokens(token0, token1, lpTokensAmount[i]);
				if (token0 == _tokenOut) {
					if (IERC20(token1).allowance(address(this), sushiRouter) == 0) {
						IERC20(token1).safeApprove(sushiRouter, type(uint256).max);
					}
					_sushiswapTokenForToken(token1, _tokenOut, amount1, 0, deadline);
				} else if (token1 == _tokenOut) {
					if (IERC20(token0).allowance(address(this), sushiRouter) == 0) {
						IERC20(token0).safeApprove(sushiRouter, type(uint256).max);
					}
					_sushiswapTokenForToken(token0, _tokenOut, amount0, 0, deadline);
				} else {
					if (IERC20(token0).allowance(address(this), sushiRouter) == 0) {
						IERC20(token0).safeApprove(sushiRouter, type(uint256).max);
					}
					if (IERC20(token1).allowance(address(this), sushiRouter) == 0) {
						IERC20(token1).safeApprove(sushiRouter, type(uint256).max);
					}
					_sushiswapTokenForToken(token0, _tokenOut, amount0, 0, deadline);
					_sushiswapTokenForToken(token1, _tokenOut, amount1, 0, deadline);
				}
			}
		}
		return true;
	}
}

contract RapidUnwind is RapidUni, RapidSushi, Ownable, Pausable, ReentrancyGuard {

	using SafeMath for uint256;
	using SafeERC20 for IERC20;
	using Address for address payable;

	uint256 private fee;
	address private feeCollector;

	function changeFee(uint256 _fee) external onlyOwner() {

		fee = _fee;
	}

	function changeFeeCollector(address _feeCollector) external onlyOwner() {

		feeCollector = _feeCollector;
	}

	function pause() external onlyOwner() {

		_pause();
	}

	function unPause() external onlyOwner() {

		_unpause();
	}

	function rapidUnwindToken(
		bool flag,
		address _tokenOut,
		address[] memory standardTokens,
		uint256[] memory standardTokensAmounts,
		uint256[] memory amountOutMin1,
		address[] memory eip712Tokens,
		uint256[] memory eip712TokensAmounts,
		uint256[] memory amountOutMin2,
		uint8[] memory v,
		bytes32[] memory r,
		bytes32[] memory s
	) external payable whenNotPaused() nonReentrant() returns (bool) {

		require(standardTokens.length == standardTokensAmounts.length, 'Invalid-length');
		require(eip712Tokens.length == eip712TokensAmounts.length && eip712Tokens.length == v.length, 'Invalid-length');
		uint256 balanceTokenOutBefore = IERC20(_tokenOut).balanceOf(address(this));
		if (flag) {
			_rapidUni(_tokenOut, standardTokens, standardTokensAmounts, amountOutMin1, eip712Tokens, eip712TokensAmounts, amountOutMin2, v, r, s);
		} else {
			_rapidSushi(_tokenOut, standardTokens, standardTokensAmounts, amountOutMin1, eip712Tokens, eip712TokensAmounts, amountOutMin2, v, r, s);
		}
		uint256 rapidBalance = IERC20(_tokenOut).balanceOf(address(this)).sub(balanceTokenOutBefore);
		if (fee > 0 && feeCollector != address(0)) {
			uint256 feeBalance = rapidBalance.mul(fee).div(1000);
			rapidBalance = rapidBalance.sub(feeBalance);
		}

		IERC20(_tokenOut).safeTransfer(msg.sender, rapidBalance);
	}
	
	function rapidUnwindLpToken(
		bool flag,
		uint256 deadlinePermit,
		address _tokenOut,
		address[] memory lpTokens,
		uint256[] memory lpTokensAmount,
		uint8[] memory v,
		bytes32[] memory r,
		bytes32[] memory s
	) external whenNotPaused() nonReentrant() returns (bool) {

		uint256 balanceTokenOutBefore = IERC20(_tokenOut).balanceOf(address(this));
		if (flag) {
			_rapidUniLP(deadlinePermit, _tokenOut, lpTokens, lpTokensAmount, v, r, s);
		} else { 
			_rapidSushiLP(deadlinePermit, _tokenOut, lpTokens, lpTokensAmount, v, r, s);
		}
		uint256 rapidBalance = IERC20(_tokenOut).balanceOf(address(this)).sub(balanceTokenOutBefore);
		if (fee > 0 && feeCollector != address(0)) {
			uint256 feeBalance = rapidBalance.mul(fee).div(1000);
			rapidBalance = rapidBalance.sub(feeBalance);
		}
		IERC20(_tokenOut).safeTransfer(msg.sender, rapidBalance);
	}

	function adminWithDrawFee(address _token) external onlyOwner() {

		if (_token != address(0)) {
			uint256 amountWithDraw = IERC20(_token).balanceOf(address(this));
			IERC20(_token).safeTransfer(feeCollector, amountWithDraw);
		} else {
			payable(feeCollector).sendValue(address(this).balance);
		}
	}

	receive() external payable {}
}