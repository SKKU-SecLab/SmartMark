
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
pragma solidity ^0.6.8;

interface IUniswapV2Router02 {

	function factory() external pure returns (address);


	function WETH() external pure returns (address);


	function addLiquidityETH(
		address token,
		uint256 amountTokenDesired,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	)
		external
		payable
		returns (
			uint256 amountToken,
			uint256 amountETH,
			uint256 liquidity
		);


	function swapExactETHForTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);

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
}// Unlicensed
pragma solidity ^0.6.8;

contract PrismZap is ReentrancyGuard {

	using SafeMath for uint256;

	uint256 immutable deadline = 0xf000000000000000000000000000000000000000000000000000000000000000;
	IUniswapV2Router02 immutable uniswap = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
	address immutable WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
	address immutable DEF = 0x3Aa5f749d4a6BCf67daC1091Ceb69d1F5D86fA53;

	constructor() public {
		IERC20(0x3Aa5f749d4a6BCf67daC1091Ceb69d1F5D86fA53).approve(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, uint256(-1));
	}

	function _uniswapETHForToken(uint256 _amount) private returns (uint256[] memory amounts) {

		address[] memory path = new address[](2);
		path[0] = WETH;
		path[1] = DEF;
		amounts = uniswap.swapExactETHForTokens{ value: _amount }(0, path, address(this), deadline); // amounts[0] = WETH, amounts[1] = DEF
	}

	function zap() external payable nonReentrant() {

		uint256 ethAmount = msg.value;
		uint256 defBalanceBefore = IERC20(DEF).balanceOf(address(this));
		_uniswapETHForToken(ethAmount.div(2)); // amounts[0] = WETH, amounts[1] = DEF
		uint256 defBalanceAfter = IERC20(DEF).balanceOf(address(this));
		uint256 defAmount = defBalanceAfter.sub(defBalanceBefore);
		(uint256 amountToken, uint256 amountETH, ) = uniswap.addLiquidityETH{ value: ethAmount.div(2) }(DEF, defAmount, 0, 0, msg.sender, deadline);
		if (ethAmount.div(2) > amountETH) {
			uint256 returnETHamount = ethAmount.div(2).sub(amountETH);
			msg.sender.call{ value: returnETHamount }('');
		} else if (defAmount > amountToken) {
			uint256 returnDEFamount = defAmount.sub(amountToken);
			IERC20(DEF).transfer(msg.sender, returnDEFamount);
		}
	}

	receive() external payable {}
}