
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity 0.8.13;

interface IThorchainRouter {

    function depositWithExpiry(
        address payable vault,
        address asset,
        uint amount,
        string calldata memo,
        uint expiration
    ) external payable;

}// GPL-3.0-only

pragma solidity 0.8.13;

interface IUniswapV2 {

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}// UNLICENSED
pragma solidity 0.8.13;



contract RangoThorchainOutputAggUniV2 is ReentrancyGuard {

    address public nativeWrappedAddress;
    IUniswapV2 public dexRouter;

    constructor(address _nativeWrappedAddress, address _dexRouter) {
        nativeWrappedAddress = _nativeWrappedAddress;
        dexRouter = IUniswapV2(_dexRouter);
    }

    function swapIn(
        address tcRouter,
        address tcVault,
        string calldata tcMemo,
        address token,
        uint amount,
        uint amountOutMin,
        uint deadline
    ) public nonReentrant {

        revert("this contract only supports swapOut");
    }

    function swapOut(address token, address to, uint256 amountOutMin) public payable nonReentrant {

        address[] memory path = new address[](2);
        path[0] = nativeWrappedAddress;
        path[1] = token;
        dexRouter.swapExactETHForTokens{value : msg.value}(amountOutMin, path, to, type(uint).max);
    }

}