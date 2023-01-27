
pragma solidity 0.8.1;

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
pragma abicoder v2;

interface ISwapRouter {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);


    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);


    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);

}

interface GeneralERC20 {

	function transfer(address to, uint256 amount) external;

	function transferFrom(address from, address to, uint256 amount) external;

	function approve(address spender, uint256 amount) external;

	function balanceOf(address spender) external view returns (uint);

	function allowance(address owner, address spender) external view returns (uint);

}

library SafeERC20 {

	function checkSuccess()
		private
		pure
		returns (bool)
	{

		uint256 returnValue = 0;

		assembly {
			switch returndatasize()

			case 0x0 {
				returnValue := 1
			}

			case 0x20 {
				returndatacopy(0x0, 0x0, 0x20)

				returnValue := mload(0x0)
			}

			default { }
		}

		return returnValue != 0;
	}

	function transfer(address token, address to, uint256 amount) internal {

		GeneralERC20(token).transfer(to, amount);
		require(checkSuccess(), "SafeERC20: transfer failed");
	}

	function transferFrom(address token, address from, address to, uint256 amount) internal {

		GeneralERC20(token).transferFrom(from, to, amount);
		require(checkSuccess(), "SafeERC20: transferFrom failed");
	}

	function approve(address token, address spender, uint256 amount) internal {

		GeneralERC20(token).approve(spender, amount);
		require(checkSuccess(), "SafeERC20: approve failed");
	}
}


interface IAaveLendingPool {

  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);

}

interface IUniswapSimple {

        function WETH() external pure returns (address);

        function swapTokensForExactTokens(
                uint amountOut,
                uint amountInMax,
                address[] calldata path,
                address to,
                uint deadline
        ) external returns (uint[] memory amounts);

	function swapExactTokensForTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external returns (uint[] memory amounts);

}

contract WalletZapper {

	struct Trade {
		IUniswapSimple router;
		uint amountIn;
		uint amountOutMin;
		address[] path;
		bool wrap;
	}
	struct DiversificationTrade {
		address tokenOut;
		uint24 fee;
		uint allocPts;
		uint amountOutMin;
		bool wrap;
	}

	address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

	address public admin;
	mapping (address => bool) public allowedSpenders;
	IAaveLendingPool public lendingPool;
	uint16 aaveRefCode;
	constructor(IAaveLendingPool _lendingPool, uint16 _aaveRefCode, address[] memory spenders) {
		admin = msg.sender;
		lendingPool = _lendingPool;
		aaveRefCode = _aaveRefCode;
		allowedSpenders[address(_lendingPool)] = true;
		for (uint i=0; i!=spenders.length; i++) {
			allowedSpenders[spenders[i]] = true;
		}
	}

	function approveMaxMany(address spender, address[] calldata tokens) external {

		require(msg.sender == admin, "NOT_ADMIN");
		require(allowedSpenders[spender], "NOT_ALLOWED");
		for (uint i=0; i!=tokens.length; i++) {
			SafeERC20.approve(tokens[i], spender, type(uint256).max);
		}
	}

	function approve(address token, address spender, uint amount) external {

		require(msg.sender == admin, "NOT_ADMIN");
		require(allowedSpenders[spender], "NOT_ALLOWED");
		SafeERC20.approve(token, spender, amount);
	}

	function exchangeV2(address[] calldata assetsToUnwrap, Trade[] memory trades) external {

		for (uint i=0; i!=assetsToUnwrap.length; i++) {
			lendingPool.withdraw(assetsToUnwrap[i], type(uint256).max, address(this));
		}
		address to = msg.sender;
		uint deadline = block.timestamp;
		uint len = trades.length;
		for (uint i=0; i!=len; i++) {
			Trade memory trade = trades[i];
			if (!trade.wrap) {
				trade.router.swapExactTokensForTokens(trade.amountIn, trade.amountOutMin, trade.path, to, deadline);
			} else {
				uint[] memory amounts = trade.router.swapExactTokensForTokens(trade.amountIn, trade.amountOutMin, trade.path, address(this), deadline);
				uint lastIdx = trade.path.length - 1;
				lendingPool.deposit(trade.path[lastIdx], amounts[lastIdx], to, aaveRefCode);
			}
		}

	}

	function wrapLending(address[] calldata assetsToWrap) external {

		for (uint i=0; i!=assetsToWrap.length; i++) {
			lendingPool.deposit(assetsToWrap[i], IERC20(assetsToWrap[i]).balanceOf(address(this)), msg.sender, aaveRefCode);
		}
	}
	function unwrapLending(address[] calldata assetsToUnwrap) external {

		for (uint i=0; i!=assetsToUnwrap.length; i++) {
			lendingPool.withdraw(assetsToUnwrap[i], type(uint256).max, msg.sender);
		}
	}

	function wrapETH() payable external {

		payable(WETH).transfer(msg.value);
	}

	function tradeV3(ISwapRouter uniV3Router, ISwapRouter.ExactInputParams calldata params) external returns (uint) {

		return uniV3Router.exactInput(params);
	}
	
	function tradeV3Single(ISwapRouter uniV3Router, ISwapRouter.ExactInputSingleParams calldata params, bool wrapOutputToLending) external returns (uint) {

		ISwapRouter.ExactInputSingleParams memory tradeParams = params;
		address recipient = params.recipient;
		if(wrapOutputToLending) {
			tradeParams.recipient = address(this);
		}

		uint amountOut = uniV3Router.exactInputSingle(tradeParams);
		if(wrapOutputToLending) {
			lendingPool.deposit(params.tokenOut, amountOut, recipient, aaveRefCode);
		}
		return amountOut;
	}

	function diversifyV3(ISwapRouter uniV3Router, address inputAsset, uint24 inputFee, uint inputMinOut, DiversificationTrade[] memory trades) external {

		uint inputAmount;
		if (inputAsset != address(0)) {
			inputAmount = uniV3Router.exactInputSingle(
			    ISwapRouter.ExactInputSingleParams (
				inputAsset,
				WETH,
				inputFee,
				address(this),
				block.timestamp,
				IERC20(inputAsset).balanceOf(address(this)),
				inputMinOut,
				0
			    )
			);
		} else {
			inputAmount = IERC20(WETH).balanceOf(address(this));
		}

		uint totalAllocPts;
		uint len = trades.length;
		for (uint i=0; i!=len; i++) {
			DiversificationTrade memory trade = trades[i];
			totalAllocPts += trade.allocPts;
			if (!trade.wrap) {
				uniV3Router.exactInputSingle(
				    ISwapRouter.ExactInputSingleParams (
					WETH,
					trade.tokenOut,
					trade.fee,
					msg.sender,
					block.timestamp,
					inputAmount * trade.allocPts / 1000,
					trade.amountOutMin,
					0
				    )
				);
			} else {
				uint amountToDeposit = uniV3Router.exactInputSingle(
				    ISwapRouter.ExactInputSingleParams (
					WETH,
					trade.tokenOut,
					trade.fee,
					address(this),
					block.timestamp,
					inputAmount * trade.allocPts / 1000,
					trade.amountOutMin,
					0
				    )
				);
				lendingPool.deposit(trade.tokenOut, amountToDeposit, msg.sender, aaveRefCode);
			}
		}

		IERC20 wrappedETH = IERC20(WETH);
		uint wrappedETHAmount = wrappedETH.balanceOf(address(this));
		if (wrappedETHAmount > 0) require(wrappedETH.transfer(msg.sender, wrappedETHAmount));
	}

	function recoverFunds(IERC20 token, uint amount) external {

		require(msg.sender == admin, "NOT_ADMIN");
		token.transfer(admin, amount);
	}
}