
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// Be name Khoda
pragma solidity 0.8.9;
pragma abicoder v2;




interface IWeth{

	function deposit() external payable;

}
interface IUniswapV2Router02 {

	function factory() external pure returns (address);


	function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);


	function addLiquidity(
		address tokenA,
		address tokenB,
		uint256 amountADesired,
		uint256 amountBDesired,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);


	function swapExactTokensForTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);


	function swapExactETHForTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);


	function getAmountsIn(
		uint amountOut, 
		address[] memory path
	) external view returns (uint[] memory amounts);


	function getAmountsOut(
		uint256 amountIn, 
		address[] calldata path
	) external view returns (uint256[] memory amounts);

}

interface IUniwapV2Pair {

	function token0() external pure returns (address);

	function token1() external pure returns (address);

	function totalSupply() external view returns (uint);

	function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);

}

interface IStaking {

	function depositFor(address _user, uint256 amount) external;

}

struct ProxyInput {
	uint amountIn;
	uint minAmountOut;
	uint deusPriceUSD;
	uint colPriceUSD;
	uint usdcForMintAmount;
	uint deusNeededAmount;
	uint expireBlock;
	bytes[] sigs;
}

interface IDEIProxy {

	function USDC2DEI(ProxyInput memory proxyInput) external returns (uint deiAmount);

    function ERC202DEI(ProxyInput memory proxyInput, address[] memory path) external returns (uint deiAmount);

    function Nativecoin2DEI(ProxyInput memory proxyInput, address[] memory path) payable external returns (uint deiAmount);

    function getUSDC2DEIInputs(uint amountIn, uint deusPriceUSD, uint colPriceUSD) external view returns (uint amountOut, uint usdcForMintAmount, uint deusNeededAmount);

    function getERC202DEIInputs(uint amountIn, uint deusPriceUSD, uint colPriceUSD, address[] memory path) external view returns (uint amountOut, uint usdcForMintAmount, uint deusNeededAmount);

}

struct ZapperInput {
	uint amountIn;
	uint deusPriceUSD;
	uint collateralPrice;
	uint iterations;
	address[] toUSDCPath;
	address[] toETHPath;
	uint maxRemainAmount;
}

contract DEUS_ETH_ZAPPER is Ownable {

	using SafeERC20 for IERC20;


	bool public stopped;
	address public uniswapRouter;
	address public pairAddress;
	address public deusAddress;
	address public ethAddress;
	address public stakingAddress;
	address public multiSwapAddress; // deus proxy | deus swap
	address public deiAddress;
	address public usdcAddress;
    address public deiProxy;
	address[] public dei2deusPath;
	uint private constant deadline = 0xf000000000000000000000000000000000000000000000000000000000000000;


	constructor (
		address _pairAddress,
		address _deusAddress,
		address _ethAddress,
		address _uniswapRouter,
		address _stakingAddress,
		address _mulitSwapAddress,

		address _deiAddress,
		address _usdcAddress,
        address _deiProxy,
		address[] memory _dei2deusPath
	) {
		uniswapRouter = _uniswapRouter;
		pairAddress = _pairAddress;
		deusAddress = _deusAddress;
		ethAddress = _ethAddress;
		stakingAddress = _stakingAddress;
		multiSwapAddress = _mulitSwapAddress;
		deiAddress = _deiAddress;
		usdcAddress = _usdcAddress;
        deiProxy = _deiProxy;
		dei2deusPath = _dei2deusPath;
		init();
	}


	function approve(address token, address to) public onlyOwner {

		IERC20(token).safeApprove(to, type(uint256).max);
	}

	function emergencyWithdrawERC20(address token, address to, uint amount) external onlyOwner {

		IERC20(token).safeTransfer(to, amount);
	}

	function emergencyWithdrawETH(address recv, uint amount) external onlyOwner {

		payable(recv).transfer(amount);
	}

	function setStaking(address _stakingAddress) external onlyOwner {

		stakingAddress = _stakingAddress;
		emit StakingSet(stakingAddress);
	}

	function setVariables(
		address _pairAddress,
		address _deusAddress,
		address _ethAddress,
		address _uniswapRouter,
		address _stakingAddress,
		address _mulitSwapAddress,

		address _deiAddress,
		address _usdcAddress,
        address _deiProxy,
		address[] memory _dei2deusPath
	) external onlyOwner {

		uniswapRouter = _uniswapRouter;
		pairAddress = _pairAddress;
		deusAddress = _deusAddress;
		ethAddress = _ethAddress;
		stakingAddress = _stakingAddress;
		multiSwapAddress = _mulitSwapAddress;
		deiAddress = _deiAddress;
		usdcAddress = _usdcAddress;
        deiProxy = _deiProxy;
		dei2deusPath = _dei2deusPath;
	}

	modifier stopInEmergency() {

		require(!stopped, "ZAPPER: temporarily paused");
		_;
	}

	function USDC2DEUS(ProxyInput memory proxyInput) internal returns (uint deusAmount) {

		uint deiAmount = IDEIProxy(deiProxy).USDC2DEI(proxyInput);
        
        deusAmount = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(deiAmount, 1, dei2deusPath, address(this), deadline)[1];

        require(proxyInput.minAmountOut <= deusAmount, "Multi Swap: Insufficient output amount");
	}


	function ERC202DEUS(ProxyInput memory proxyInput, address[] memory path) internal returns (uint deusAmount) {

		if (IERC20(path[0]).allowance(address(this), deiProxy) == 0) {IERC20(path[0]).approve(deiProxy, type(uint).max);}
        
        uint deiAmount = IDEIProxy(deiProxy).ERC202DEI(proxyInput, path);
        
        deusAmount = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(deiAmount, 1, dei2deusPath, address(this), deadline)[1];

        require(proxyInput.minAmountOut <= deusAmount, "Multi Swap: Insufficient output amount");
	}

	function Nativecoin2DEUS(ProxyInput memory proxyInput, address[] memory path) internal returns (uint deusAmount) {

		uint deiAmount = IDEIProxy(deiProxy).Nativecoin2DEI{value: proxyInput.amountIn}(proxyInput, path);
        
        deusAmount = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(deiAmount, 1, dei2deusPath, address(this), deadline)[1];

        require(proxyInput.minAmountOut <= deusAmount, "Multi Swap: Insufficient output amount");
	}

	function buyDeusAndETH(ProxyInput memory proxyInput, uint amountToDeus, uint amountToETH, address[] memory toETHPath, address[] memory toUSDCPath) internal returns(uint token0Bought, uint token1Bought){

		IUniwapV2Pair pair = IUniwapV2Pair(pairAddress);

		if (toUSDCPath[0] == usdcAddress) {
			proxyInput.amountIn = amountToDeus;
			if (deusAddress == pair.token0()) {
				token0Bought = USDC2DEUS(proxyInput);
				token1Bought  = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(amountToETH, 1, toETHPath, address(this), deadline)[toETHPath.length - 1];

			} else {
				token1Bought = USDC2DEUS(proxyInput);
				token0Bought  = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(amountToETH, 1, toETHPath, address(this), deadline)[toETHPath.length - 1];
			}
		} else {
			if (toETHPath[0] == ethAddress) {
				proxyInput.amountIn = amountToDeus;
				if (deusAddress == pair.token0()) {
					token0Bought = Nativecoin2DEUS(proxyInput, toUSDCPath);
					token1Bought  = amountToETH;
				} else {
					token1Bought = Nativecoin2DEUS(proxyInput, toUSDCPath);
					token0Bought  = amountToETH;
				}
			} else {
				proxyInput.amountIn = amountToDeus;
				if (deusAddress == pair.token0()) {
					token0Bought = ERC202DEUS(proxyInput, toUSDCPath);
					token1Bought  = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(amountToETH, 1, toETHPath, address(this), deadline)[toETHPath.length - 1];
				} else {
					token1Bought = ERC202DEUS(proxyInput, toUSDCPath);
					token0Bought  = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(amountToETH, 1, toETHPath, address(this), deadline)[toETHPath.length - 1];
				}
			}
		}
	}

	function zapInNativecoin(
		uint256 minLPAmount,
		bool transferResidual,  // Set false to save gas by donating the residual remaining after a Zap
		ProxyInput memory proxyInput,
		address[] calldata toETHPath,
		address[] calldata toUSDCPath,
		uint amountToDeus
	) external payable {

		IWeth(ethAddress).deposit{value: msg.value - amountToDeus}();

		uint amountToETH = proxyInput.amountIn - amountToDeus;

		(uint256 token0Bought, uint256 token1Bought) = buyDeusAndETH(proxyInput, amountToDeus, amountToETH, toETHPath, toUSDCPath);

		uint256 LPBought = _uniDeposit(IUniwapV2Pair(pairAddress).token0(),
										IUniwapV2Pair(pairAddress).token1(),
										token0Bought,
										token1Bought,
										transferResidual);

		require(LPBought >= minLPAmount, "ZAPPER: Insufficient output amount");

		IStaking(stakingAddress).depositFor(msg.sender, LPBought);

		emit ZappedIn(address(0), pairAddress, msg.value, LPBought, transferResidual);
	}

	function zapInERC20(
		uint256 minLPAmount,
		bool transferResidual,  // Set false to save gas by donating the residual remaining after a Zap
		ProxyInput memory proxyInput,
		address[] calldata toETHPath,
		address[] calldata toUSDCPath,
		uint amountToDeus
	) external {

		IERC20(toETHPath[0]).safeTransferFrom(msg.sender, address(this), proxyInput.amountIn);
		
		if (toETHPath[0] != usdcAddress) {
			if (IERC20(toETHPath[0]).allowance(address(this), uniswapRouter) == 0) IERC20(toETHPath[0]).safeApprove(uniswapRouter, type(uint).max);
		}

		uint amountToETH = proxyInput.amountIn - amountToDeus;

		(uint256 token0Bought, uint256 token1Bought) = buyDeusAndETH(proxyInput, amountToDeus, amountToETH, toETHPath, toUSDCPath);
		
		
		uint256 LPBought = _uniDeposit(IUniwapV2Pair(pairAddress).token0(),
										IUniwapV2Pair(pairAddress).token1(),
										token0Bought,
										token1Bought,
										transferResidual);

		require(LPBought >= minLPAmount, "ZAPPER: Insufficient output amount");

		IStaking(stakingAddress).depositFor(msg.sender, LPBought);

		emit ZappedIn(toETHPath[0], pairAddress, proxyInput.amountIn, LPBought, transferResidual);
	}

	function _uniDeposit(
		address _toUnipoolToken0,
		address _toUnipoolToken1,
		uint256 token0Bought,
		uint256 token1Bought,
		bool transferResidual
	) internal returns(uint256) {

		(uint256 amountA, uint256 amountB, uint256 LP) = IUniswapV2Router02(uniswapRouter).addLiquidity(
			_toUnipoolToken0,
		 	_toUnipoolToken1,
		 	token0Bought,
		 	token1Bought,
			1,
			1,
			address(this),
			deadline
		);

		if (transferResidual) {
			if (token0Bought - amountA > 0) {
				IERC20(_toUnipoolToken0).safeTransfer(
					msg.sender,
					token0Bought - amountA
				);
			}

			if (token1Bought - amountB > 0) {
				IERC20(_toUnipoolToken1).safeTransfer(
					msg.sender,
					token1Bought - amountB
				);
			}
		}

		return LP;
	}


	function getUSDC2DEUSInputs(uint amountIn, uint deusPriceUSD, uint colPriceUSD) public view returns (uint amountOut, uint usdcForMintAmount, uint deusNeededAmount) {

		(amountOut, usdcForMintAmount, deusNeededAmount) = IDEIProxy(deiProxy).getUSDC2DEIInputs(amountIn, deusPriceUSD, colPriceUSD);
        amountOut = IUniswapV2Router02(uniswapRouter).getAmountsOut(amountOut, dei2deusPath)[1];
	}

	function getERC202DEUSInputs(uint amountIn, uint deusPriceUSD, uint colPriceUSD, address[] memory path) public view returns (uint amountOut, uint usdcForMintAmount, uint deusNeededAmount) {

		(amountOut, usdcForMintAmount, deusNeededAmount) = IDEIProxy(deiProxy).getERC202DEIInputs(amountIn, deusPriceUSD, colPriceUSD, path);
        amountOut = IUniswapV2Router02(uniswapRouter).getAmountsOut(amountOut, dei2deusPath)[1];
	}

	function getAmountOut(ZapperInput memory input) public view returns (uint percentage, uint lp, uint usdcForMintAmount, uint deusNeededAmount, uint swapAmount) {

		if(input.toUSDCPath.length > 0 && input.toUSDCPath[0] == ethAddress) {
			(swapAmount, ) = getSwapAmountETH(input);
		} else {
			(swapAmount, ) = getSwapAmountERC20(input);
		}

		uint deusAmount;
		if (input.toETHPath.length > 0 && input.toETHPath[0] == usdcAddress) {
			(deusAmount, usdcForMintAmount, deusNeededAmount) = getUSDC2DEUSInputs(swapAmount, input.deusPriceUSD, input.collateralPrice);
		} else {
			(deusAmount, usdcForMintAmount, deusNeededAmount) = getERC202DEUSInputs(swapAmount, input.deusPriceUSD, input.collateralPrice, input.toUSDCPath);
		}

		IUniwapV2Pair pair = IUniwapV2Pair(pairAddress);
		(uint res0, uint res1, ) = pair.getReserves();
		
		if(pair.token0() == deusAddress) {
			percentage = deusAmount * 1e6 / (res0 + deusAmount);
			lp = deusAmount * pair.totalSupply() / res0;
		} else {
			percentage = deusAmount * 1e6 / (res1 + deusAmount);
			lp = deusAmount * pair.totalSupply() / res1;
		}
	}

	function getSwapAmountERC20(ZapperInput memory input) public view returns(uint, uint) {

		IUniwapV2Pair pair = IUniwapV2Pair(pairAddress);
		uint reservedDeus;
		uint reservedETH;
		if (deusAddress == pair.token0()) {
			(reservedDeus, reservedETH, ) = pair.getReserves();
		} else {
			(reservedETH, reservedDeus, ) = pair.getReserves();
		}

		uint remain = input.amountIn;
		if(input.toETHPath[0] == usdcAddress){
			remain = remain * 1e12;
			input.maxRemainAmount = 1e16;
		} else {
			input.maxRemainAmount = IUniswapV2Router02(uniswapRouter).getAmountsIn(1e6, input.toUSDCPath)[0] / 1e2;
		}

		uint x;
		uint y;
		uint amountToSwapToDeus;
		for (uint256 i = 0; i < input.iterations; i++) {
			x = remain / 2;

			if(x < input.maxRemainAmount) {
				break;
			}

			if(input.toETHPath[0] == usdcAddress){
				(y, , ) = getUSDC2DEUSInputs(x / 1e12, input.deusPriceUSD, input.collateralPrice);
			}else{
				(y, , ) = getERC202DEUSInputs(x, input.deusPriceUSD, input.collateralPrice, input.toUSDCPath);
			}

			uint neededCoinForBuyETH = IUniswapV2Router02(uniswapRouter).getAmountsIn(y * reservedETH / reservedDeus, input.toETHPath)[0];
			if (input.toETHPath[0] == usdcAddress) {
				neededCoinForBuyETH = neededCoinForBuyETH * 1e12;
			}

			while (neededCoinForBuyETH + x > remain) {
				x = remain - neededCoinForBuyETH;

				if (input.toETHPath[0] == usdcAddress) {
					(y, , ) = getUSDC2DEUSInputs(x / 1e12, input.deusPriceUSD, input.collateralPrice);
				} else {
					(y, , ) = getERC202DEUSInputs(x, input.deusPriceUSD, input.collateralPrice, input.toUSDCPath);
				}

				neededCoinForBuyETH = IUniswapV2Router02(uniswapRouter).getAmountsIn(y * reservedETH / reservedDeus, input.toETHPath)[0];
				if(input.toETHPath[0] == usdcAddress){
					neededCoinForBuyETH = neededCoinForBuyETH * 1e12;
				}
			}

			remain = remain - neededCoinForBuyETH - x;
			amountToSwapToDeus += x;
		}
		if(input.toETHPath[0] == usdcAddress){
			return (amountToSwapToDeus / 1e12, remain / 1e12);
		}
		return (amountToSwapToDeus, remain);
	}

	function getSwapAmountETH(ZapperInput memory input) public view returns(uint, uint) {


		IUniwapV2Pair pair = IUniwapV2Pair(pairAddress);
		uint reservedDeus;
		uint reservedETH;
		if (deusAddress == pair.token0()) {
			(reservedDeus, reservedETH, ) = pair.getReserves();
		} else {
			(reservedETH, reservedDeus, ) = pair.getReserves();
		}

		input.maxRemainAmount = IUniswapV2Router02(uniswapRouter).getAmountsIn(1e6, input.toUSDCPath)[0] / 1e2;

		uint x;
		uint y;
		uint amountToSwapToDeus;
		for (uint256 i = 0; i < input.iterations; i++) {
			x = input.amountIn / 2;

			if(x < input.maxRemainAmount){
				break;
			}

			(y, , ) = getERC202DEUSInputs(x, input.deusPriceUSD, input.collateralPrice, input.toUSDCPath);


			while(y * reservedETH / reservedDeus+ x > input.amountIn) {
				x = input.amountIn - y * reservedETH / reservedDeus;
				(y, , ) = getERC202DEUSInputs(x, input.deusPriceUSD, input.collateralPrice, input.toUSDCPath);
			}
			input.amountIn = input.amountIn - y * reservedETH / reservedDeus - x;
			amountToSwapToDeus += x;
		}
		return (amountToSwapToDeus, input.amountIn);
	}

	function init() public onlyOwner {

		approve(IUniwapV2Pair(pairAddress).token0(), uniswapRouter);
		approve(IUniwapV2Pair(pairAddress).token1(), uniswapRouter);
		approve(usdcAddress, deiProxy);
		approve(usdcAddress, uniswapRouter);
		approve(deiAddress, uniswapRouter);
		approve(pairAddress, stakingAddress);
	}

	function toggleContractActive() external onlyOwner {

		stopped = !stopped;
	}

	event StakingSet(address staking);
	event ZappedIn(address input_token, address output_token, uint input_amount, uint output_amount, bool transfer_residual);
	event Temp(uint key, uint value);
}

