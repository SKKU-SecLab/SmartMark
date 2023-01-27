
pragma solidity 0.8.4;

interface IUniV3 {

    
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

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

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

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }
    
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);


    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);


    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);


    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);

}// BUSL-1.1

pragma solidity 0.8.4;

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);

}// BUSL-1.1

pragma solidity 0.8.4;


library UniswapV3Exchange {


    address public constant DEX = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
        bool isInputEth;
    }

    struct ExactInputParams {
        bytes path;
        address tokenIn;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        bool isInputEth;
    }

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
        bool isInputEth;
    }

    struct ExactOutputParams {
        bytes path;
        address tokenIn;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        bool isInputEth;
    }

    struct MultiCall {
        bytes[] data;
        address tokenIn;
        uint256 amountIn;
        bool isInputEth;
    }

    function _checkCallResult(bool _success) internal pure {

        if (!_success) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    function _approve(address _token, uint256 _amount, bool isInputEth) internal {

        if (!isInputEth) {
            if (IERC20(_token).allowance(address(this), DEX) < _amount) {
                IERC20(_token).approve(DEX, ~uint256(0));
            }
        }
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external {

        _approve(params.tokenIn, params.amountIn, params.isInputEth);
        
        bytes memory _data = abi.encodeWithSelector(
            IUniV3.exactInputSingle.selector,
            params.tokenIn,
            params.tokenOut,
            params.fee,
            params.recipient,
            params.deadline,
            params.amountIn,
            params.amountOutMinimum,
            params.sqrtPriceLimitX96
        );
        
        (bool success, ) = DEX.call{value: params.isInputEth ? params.amountIn : 0}(_data);
        
        _checkCallResult(success);
    }

    function exactInput(ExactInputParams calldata params) external {

        _approve(params.tokenIn, params.amountIn, params.isInputEth);

        bytes memory _data = abi.encodeWithSelector(
            IUniV3.exactInput.selector,
            params.path,
            params.recipient,
            params.deadline,
            params.amountIn,
            params.amountOutMinimum
        );
        
        (bool success, ) = DEX.call{value: params.isInputEth ? params.amountIn : 0}(_data);
        
        _checkCallResult(success);
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external {

        _approve(params.tokenIn, params.amountInMaximum, params.isInputEth);

        bytes memory _data = abi.encodeWithSelector(
            IUniV3.exactOutputSingle.selector,
            params.tokenIn,
            params.tokenOut,
            params.fee,
            params.recipient,
            params.deadline,
            params.amountOut,
            params.amountInMaximum,
            params.sqrtPriceLimitX96
        );
        
        (bool success, ) = DEX.call{value: params.isInputEth ? params.amountInMaximum : 0}(_data);
        
        _checkCallResult(success);
    }

    function exactOutput(ExactOutputParams calldata params) external {

        _approve(params.tokenIn, params.amountInMaximum, params.isInputEth);

        bytes memory _data = abi.encodeWithSelector(
            IUniV3.exactOutputSingle.selector,
            params.path,
            params.recipient,
            params.deadline,
            params.amountOut,
            params.amountInMaximum
        );
        
        (bool success, ) = DEX.call{value: params.isInputEth ? params.amountInMaximum : 0}(_data);
        
        _checkCallResult(success);
    }

    function multicall(MultiCall calldata params) external {

        _approve(params.tokenIn, params.amountIn, params.isInputEth);
        
        bytes memory _data = abi.encodeWithSelector(
            IUniV3.multicall.selector,
            params.data
        );

        (bool success, ) = DEX.call{value: params.isInputEth ? params.amountIn : 0}(_data);
        
        _checkCallResult(success);
    }
}