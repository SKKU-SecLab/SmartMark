
pragma solidity ^0.6.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");
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

interface ILoyaltyPool {

	function enter(uint256 amount) external;

	function leave(uint256 shares) external;

}

interface ISimpleUniswap {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}


contract ADXLoyaltyArb is Ownable {

	ISimpleUniswap public constant uniswap = ISimpleUniswap(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
	IERC20 public constant ADX = IERC20(0xADE00C28244d5CE17D72E40330B1c318cD12B7c3);
	IERC20 public constant ADXL = IERC20(0xd9A4cB9dc9296e111c66dFACAb8Be034EE2E1c2C);

	constructor() public {
		ADX.approve(address(uniswap), uint(-1));
		ADX.approve(address(ADXL), uint(-1));
		ADXL.approve(address(uniswap), uint(-1));
		ADXL.approve(address(ADXL), uint(-1));
	}

	function withdrawTokens(IERC20 token, uint amount) onlyOwner external {

		token.transfer(msg.sender, amount);
	}

	function tradeOnUni(address input, address output, uint amount) internal {

		address[] memory path = new address[](3);
		path[0] = input;
		path[1] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
		path[2] = output;
		uniswap.swapExactTokensForTokens(amount, uint(0), path, address(this), block.timestamp);
	}

	function loyaltyTradesHigher(uint amountToSell) external {

		require(ADX.balanceOf(address(this)) == 0, 'must not have adx');
		uint initial = ADXL.balanceOf(address(this));
		tradeOnUni(address(ADXL), address(ADX), amountToSell);
		ILoyaltyPool(address(ADXL)).enter(ADX.balanceOf(address(this)));
		require(ADXL.balanceOf(address(this)) > initial, 'did not make profit');
	}

	function loyaltyTradesLower(uint amountToBurn) external {

		require(ADX.balanceOf(address(this)) == 0, 'must not have adx');
		uint initial = ADXL.balanceOf(address(this));
		ILoyaltyPool(address(ADXL)).leave(amountToBurn);
		tradeOnUni(address(ADX), address(ADXL), ADX.balanceOf(address(this)));
		require(ADXL.balanceOf(address(this)) > initial, 'did not make profit');
	}
}