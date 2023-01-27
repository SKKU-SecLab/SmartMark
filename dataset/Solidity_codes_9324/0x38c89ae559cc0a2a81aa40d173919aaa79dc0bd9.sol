
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





library Babylonian {

	function sqrt(uint256 y) internal pure returns (uint256 z) {

		if (y > 3) {
			z = y;
			uint256 x = y / 2 + 1;
			while (x < z) {
				z = x;
				x = (y / x + x) / 2;
			}
		} else if (y != 0) {
			z = 1;
		}
	}
}

interface IUniswapV2Router02 {

	function factory() external pure returns (address);

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

	function getUSDC2DEIInputs(
		uint amountIn, 
		uint deusPriceUSD, 
		uint colPriceUSD
	) external view returns (uint amountOut, uint usdcForMintAmount, uint deusNeededAmount);

	function USDC2DEI(ProxyInput memory proxyInput) external returns (uint deiAmount);

}

contract DEI_DEUS_ZAPPER is Ownable {

	using SafeERC20 for IERC20;


	bool public stopped;
	address public uniswapRouter;
	address public pairAddress;
	address public usdcAddress;
	address public deiAddress;
	address public deusAddress;
	address public stakingAddress;
	address public deiProxyAddress;
	uint private constant deadline = 0xf000000000000000000000000000000000000000000000000000000000000000;


	constructor (
		address _pairAddress,
		address _usdcAddress,
		address _deiAddress,
		address _deusAddress,
		address _uniswapRouter,
		address _stakingAddress,
		address _deiProxyAddress
	) {
		uniswapRouter = _uniswapRouter;
		pairAddress = _pairAddress;
		usdcAddress = _usdcAddress;
		deiAddress = _deiAddress;
		deusAddress = _deusAddress;
		stakingAddress = _stakingAddress;
		deiProxyAddress = _deiProxyAddress;
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
		address _usdcAddress,
		address _deiAddress,
		address _deusAddress,
		address _uniswapRouter,
		address _stakingAddress,
		address _deiProxyAddress
	) external onlyOwner {

		uniswapRouter = _uniswapRouter;
		pairAddress = _pairAddress;
		usdcAddress = _usdcAddress;
		deiAddress = _deiAddress;
		deusAddress = _deusAddress;
		stakingAddress = _stakingAddress;
		deiProxyAddress = _deiProxyAddress;
	}

	modifier stopInEmergency() {

		require(!stopped, "ZAPPER: temporarily paused");
		_;
	}


	function zapInNativecoin(
		ProxyInput memory proxyInput,
		uint256 minLPAmount,
		address[] calldata path,
		bool transferResidual  // Set false to save gas by donating the residual remaining after a Zap
	) external payable {

		proxyInput.amountIn = IUniswapV2Router02(uniswapRouter).swapExactETHForTokens{value: msg.value}(1, path, address(this), deadline)[path.length-1];

		uint deiAmount = IDEIProxy(deiProxyAddress).USDC2DEI(proxyInput);

		(uint256 token0Bought, uint256 token1Bought) = _buyTokens(deiAddress, deiAmount);

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
		ProxyInput memory proxyInput,
		uint256 amountIn,
		uint256 minLPAmount,
		address[] calldata path,
		bool transferResidual  // Set false to save gas by donating the residual remaining after a Zap
	) external {

		IERC20(path[0]).safeTransferFrom(msg.sender, address(this), amountIn);
		
		if (path[0] != usdcAddress) {
			if (IERC20(path[0]).allowance(address(this), uniswapRouter) == 0) IERC20(path[0]).safeApprove(uniswapRouter, type(uint).max);
			proxyInput.amountIn = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(amountIn, 1, path, address(this), deadline)[path.length-1];
		}

		uint deiAmount = IDEIProxy(deiProxyAddress).USDC2DEI(proxyInput);

		(uint256 token0Bought, uint256 token1Bought) = _buyTokens(deiAddress, deiAmount);

		uint256 LPBought = _uniDeposit(IUniwapV2Pair(pairAddress).token0(),
										IUniwapV2Pair(pairAddress).token1(),
										token0Bought,
										token1Bought,
										transferResidual);

		require(LPBought >= minLPAmount, "ZAPPER: Insufficient output amount");

		IStaking(stakingAddress).depositFor(msg.sender, LPBought);

		emit ZappedIn(path[0], pairAddress, amountIn, LPBought, transferResidual);
	}


	function zapInDEI(
		uint256 amountIn,
		uint256 minLPAmount,
		bool transferResidual  // Set false to save gas by donating the residual remaining after a Zap
	) public stopInEmergency {

		IERC20(deiAddress).safeTransferFrom(msg.sender, address(this), amountIn);

		(uint256 token0Bought, uint256 token1Bought) = _buyTokens(deiAddress, amountIn);

		uint256 LPBought = _uniDeposit(IUniwapV2Pair(pairAddress).token0(),
										IUniwapV2Pair(pairAddress).token1(),
										token0Bought,
										token1Bought,
										transferResidual);

		require(LPBought >= minLPAmount, "ZAPPER: Insufficient output amount");

		IStaking(stakingAddress).depositFor(msg.sender, LPBought);

		emit ZappedIn(deiAddress, pairAddress, amountIn, LPBought, transferResidual);
	}

	function zapInDEUS(
		uint amountIn,
		uint minLPAmount,
		bool transferResidual
	) external stopInEmergency {

		IERC20(deusAddress).safeTransferFrom(msg.sender, address(this), amountIn);

		(uint256 token0Bought, uint256 token1Bought) = _buyTokens(deusAddress, amountIn);

		uint256 LPBought = _uniDeposit(IUniwapV2Pair(pairAddress).token0(),
									IUniwapV2Pair(pairAddress).token1(),
									token0Bought,
									token1Bought,
									transferResidual);

		require(LPBought >= minLPAmount, "ZAPPER: Insufficient output amount");

		IStaking(stakingAddress).depositFor(msg.sender, LPBought);

		emit ZappedIn(deiAddress, pairAddress, amountIn, LPBought, transferResidual);
	}

	function _buyTokens(address inputToken, uint256 _amount) internal returns(uint256 token0Bought, uint256 token1Bought) {

		IUniwapV2Pair pair = IUniwapV2Pair(pairAddress);
		(uint res0, uint256 res1, ) = pair.getReserves();
		if (inputToken == pair.token0()) {
			uint256 amountToSwap = calculateSwapInAmount(res0, _amount);	
			if (amountToSwap <= 0) amountToSwap = _amount / 2;
			token1Bought = _token2Token(
							inputToken,
							pair.token1(), // it depend on pair tokens (token0 or token1)
							amountToSwap
						);
			token0Bought = _amount - amountToSwap;
		} else {
			uint256 amountToSwap = calculateSwapInAmount(res1, _amount);
			if (amountToSwap <= 0) amountToSwap = _amount / 2;
			token0Bought = _token2Token(
								inputToken,
								pair.token0(), // it depend on pair tokens (token0 or token1)
								amountToSwap
							);
			token1Bought = _amount - amountToSwap;
		}
	}

	function _token2Token(
		address _fromToken,
		address _toToken,
		uint256 tokens2Trade
	) internal returns (uint256 tokenBought) {

		address[] memory path = new address[](2);
		path[0] = _fromToken;
		path[1] = _toToken;

		tokenBought = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(tokens2Trade,
																				1,
																				path,
																				address(this),
																				deadline)[path.length-1];

		require(tokenBought > 0, "ZAPPER: Error swapExactTokensForTokens");
	}

	function calculateSwapInAmount(uint256 reserveIn, uint256 userIn)
		internal
		pure
		returns (uint256)
	{

		return (Babylonian.sqrt(reserveIn * ((userIn * 3988000) + (reserveIn * 3988009))) - (reserveIn * 1997)) / 1994;
	}

	function _uniDeposit(
		address _toUnipoolToken0,
		address _toUnipoolToken1,
		uint256 token0Bought,
		uint256 token1Bought,
		bool transferResidual
	) internal returns(uint256) {

		(uint256 amountA, uint256 amountB, uint256 LP) = IUniswapV2Router02(uniswapRouter).addLiquidity(_toUnipoolToken0,
																										_toUnipoolToken1,
																										token0Bought,
																										token1Bought,
																										1,
																										1,
																										address(this),
																										deadline);

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


	function getAmountOutLPERC20ORNativecoin(uint amountIn, uint deusPriceUSD, uint colPriceUSD, address[] memory path) public view returns (uint percentage, uint lp, uint usdcForMintAmount, uint deusNeededAmount) {

		uint deiAmount;
		uint usdcAmount;

		if (path[0] != usdcAddress) {
			usdcAmount = IUniswapV2Router02(uniswapRouter).getAmountsOut(amountIn, path)[path.length - 1];
		} else {
			usdcAmount = amountIn;
		}

		(deiAmount, usdcForMintAmount, deusNeededAmount) = IDEIProxy(deiProxyAddress).getUSDC2DEIInputs(usdcAmount, deusPriceUSD, colPriceUSD);
		
		IUniwapV2Pair pair = IUniwapV2Pair(pairAddress);
		uint totalSupply = pair.totalSupply();
		(uint res0, uint256 res1, ) = pair.getReserves(); 
		uint dei_to_deus_amount;
		if (deiAddress == pair.token0()) {
			dei_to_deus_amount = calculateSwapInAmount(res0, deiAmount);
			uint dei_pure_amount = deiAmount - dei_to_deus_amount; 
			percentage = dei_pure_amount * 1e6 / (res0 + dei_pure_amount);
			lp = dei_pure_amount * totalSupply / res0;
		} else {
			dei_to_deus_amount = calculateSwapInAmount(res1, deiAmount);
			uint dei_pure_amount = deiAmount - dei_to_deus_amount; 
			percentage = dei_pure_amount * 1e6 / (res1 + dei_pure_amount);
			lp = dei_pure_amount * totalSupply / res1;
		}
	}

	function getAmountOutLPDEUS(uint amount) public view returns (uint percentage, uint lp) {

		IUniwapV2Pair pair = IUniwapV2Pair(pairAddress);
		uint totalSupply = pair.totalSupply();
		(uint res0, uint256 res1, ) = pair.getReserves(); 
		uint deus_to_dei_amount;
		if (deusAddress == pair.token0()) {
			deus_to_dei_amount = calculateSwapInAmount(res0, amount);
			uint deus_pure_amount = amount - deus_to_dei_amount; 
			percentage = deus_pure_amount * 1e6 / (res0 + amount);
			lp = deus_pure_amount * totalSupply / res0;
		} else {
			deus_to_dei_amount = calculateSwapInAmount(res1, amount);
			uint deus_pure_amount = amount - deus_to_dei_amount; 
			percentage = deus_pure_amount * 1e6 / (res1 + amount);
			lp = deus_pure_amount * totalSupply / res1;
		}
	}

	function getAmountOutLPDEI(uint dei_amount) public view returns (uint percentage, uint lp){

		IUniwapV2Pair pair = IUniwapV2Pair(pairAddress);
		uint totalSupply = pair.totalSupply();
		(uint res0, uint256 res1, ) = pair.getReserves(); 
		uint dei_to_deus_amount;
		if (deiAddress == pair.token0()) {
			dei_to_deus_amount = calculateSwapInAmount(res0, dei_amount);
			uint dei_pure_amount = dei_amount - dei_to_deus_amount; 
			percentage = dei_pure_amount * 1e6 / (res0 + dei_pure_amount);
			lp = dei_pure_amount * totalSupply / res0;
		} else {
			dei_to_deus_amount = calculateSwapInAmount(res1, dei_amount);
			uint dei_pure_amount = dei_amount - dei_to_deus_amount; 
			percentage = dei_pure_amount * 1e6 / (res1 + dei_pure_amount);
			lp = dei_pure_amount * totalSupply / res1;
		}
	}

	function init() public onlyOwner {

		approve(IUniwapV2Pair(pairAddress).token0(), uniswapRouter);
		approve(IUniwapV2Pair(pairAddress).token1(), uniswapRouter);
		approve(pairAddress, stakingAddress);
		approve(usdcAddress, deiProxyAddress);
	}

	function toggleContractActive() external onlyOwner {

		stopped = !stopped;
	}

	event StakingSet(address staking);
	event ZappedIn(address input_token, address output_token, uint input_amount, uint output_amount, bool transfer_residual);
}

