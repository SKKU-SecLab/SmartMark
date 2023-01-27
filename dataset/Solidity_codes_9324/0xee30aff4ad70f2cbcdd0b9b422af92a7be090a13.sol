

pragma solidity 0.6.12;

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
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

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

        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

library SafeERC20 {

    using SafeMath for uint256;
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

        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IBPool is IERC20 {

    function version() external view returns (uint256);


    function swapExactAmountIn(
        address,
        uint256,
        address,
        uint256,
        uint256
    ) external returns (uint256, uint256);


    function swapExactAmountOut(
        address,
        uint256,
        address,
        uint256,
        uint256
    ) external returns (uint256, uint256);


    function calcInGivenOut(
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) external pure returns (uint256);


    function calcOutGivenIn(
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) external pure returns (uint256);


    function getDenormalizedWeight(address) external view returns (uint256);


    function swapFee() external view returns (uint256);


    function setSwapFee(uint256 _swapFee) external;


    function bind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;


    function rebind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;


    function finalize(
        uint256 _swapFee,
        uint256 _initPoolSupply,
        address[] calldata _bindTokens,
        uint256[] calldata _bindDenorms
    ) external;


    function setPublicSwap(bool _publicSwap) external;


    function setController(address _controller) external;


    function setExchangeProxy(address _exchangeProxy) external;


    function getFinalTokens() external view returns (address[] memory tokens);


    function getTotalDenormalizedWeight() external view returns (uint256);


    function getBalance(address token) external view returns (uint256);


    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;


    function joinPoolFor(
        address account,
        uint256 rewardAmountOut,
        uint256[] calldata maxAmountsIn
    ) external;


    function joinswapPoolAmountOut(
        address tokenIn,
        uint256 poolAmountOut,
        uint256 maxAmountIn
    ) external returns (uint256 tokenAmountIn);


    function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;


    function exitswapPoolAmountIn(
        address tokenOut,
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external returns (uint256 tokenAmountOut);


    function exitswapExternAmountOut(
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPoolAmountIn
    ) external returns (uint256 poolAmountIn);


    function joinswapExternAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external returns (uint256 poolAmountOut);


    function finalizeRewardFundInfo(address _rewardFund, uint256 _unstakingFrozenTime) external;


    function addRewardPool(
        IERC20 _rewardToken,
        uint256 _startBlock,
        uint256 _endRewardBlock,
        uint256 _rewardPerBlock,
        uint256 _lockRewardPercent,
        uint256 _startVestingBlock,
        uint256 _endVestingBlock
    ) external;

}

interface IUniswapV2Router {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory);


    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);

}

interface IFreeFromUpTo {

    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);

}

interface IBFactory {

    function newBPool() external returns (IBPool);


    function collect(address _token) external;

}

contract ValueLiquidProfitCollectorV2 {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    modifier discountCHI(uint8 flag) {

        if ((flag & 0x1) == 0) {
            _;
        } else {
            uint256 gasStart = gasleft();
            _;
            uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41130);
        }
    }

    IUniswapV2Router public unirouter = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public valueToken = address(0x49E833337ECe7aFE375e44F4E3e8481029218E5c);

    address public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public wbtc = address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);

    address public usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    IBFactory public bFactory = IBFactory(0xEbC44681c125d63210a33D30C55FD3d37762675B);
    address public govVault = address(0xceC03a960Ea678A2B6EA350fe0DbD1807B22D875);

    address public insuranceFund = address(0x2b52472950cDa46Fb3369eFf2719e144699f3A07);
    uint256 public insuranceFee = 3000; // percentage (over 10000) - 30% (6% over 14%)

    address public governance;

    mapping(address => address[]) public uniswapPaths; // [input -> VALUE] => uniswap_path
    mapping(address => address) public vliquidPools; // [input -> VALUE] => value_liquid_pool

    mapping(address => address[]) public uniswapPathsToUsdc; // [input -> USDC] => uniswap_path
    mapping(address => address) public vliquidPoolsToUsdc; // [input -> USDC] => value_liquid_pool

    mapping(address => address[]) public uniswapPathsToWeth; // [input -> WETH] => uniswap_path
    mapping(address => address) public vliquidPoolsToWeth; // [input -> WETH] => value_liquid_pool

    address[255] public supportedTokens;
    uint256 public supportedTokenLength;

    event CollectProfit(address token, uint256 tokenAmount, uint256 valueAmount);
    event CollectInsurance(uint256 valueAmount);

    constructor(address _valueToken) public {
        if (_valueToken != address(0)) valueToken = _valueToken;
        governance = msg.sender;

        supportedTokenLength = 13;

        supportedTokens[0] = valueToken;
        supportedTokens[1] = weth;
        supportedTokens[2] = wbtc;
        supportedTokens[3] = usdc;
        supportedTokens[4] = dai;
        supportedTokens[5] = address(0x003e0af2916e598Fa5eA5Cb2Da4EDfdA9aEd9Fde); // BSD
        supportedTokens[6] = address(0xE7C9C188138f7D70945D420d75F8Ca7d8ab9c700); // BSDS
        supportedTokens[7] = address(0x1B8E12F839BD4e73A47adDF76cF7F0097d74c14C); // VUSD
        supportedTokens[8] = address(0xB0BFB1E2F72511cF8b4D004852E2054d7b9a76e1); // MIXS
        supportedTokens[9] = address(0x7865af71cf0b288b4E7F654f4F7851EB46a2B7F8); // SNTVT
        supportedTokens[10] = address(0x4981553e8CcF6Df916B36a2d6B6f8fC567628a51); // BNI
        supportedTokens[11] = address(0xc813EA5e3b48BEbeedb796ab42A30C5599b01740); // NIOX
        supportedTokens[12] = address(0x07150e919B4De5fD6a63DE1F9384828396f25fDC); // BASE

        uniswapPathsToUsdc[wbtc] = [wbtc, usdc];
        uniswapPathsToUsdc[dai] = [dai, usdc];

        vliquidPoolsToUsdc[address(0x003e0af2916e598Fa5eA5Cb2Da4EDfdA9aEd9Fde)] = address(0xCDD2bD61D07b8d42843175dd097A4858A8f764e7); // BSD -> USDC
        vliquidPoolsToUsdc[address(0xE7C9C188138f7D70945D420d75F8Ca7d8ab9c700)] = address(0x8438d64Da58772E9F7FCeAa1506bA300F935ABBd); // BSDS -> USDC

        vliquidPools[weth] = address(0xbd63d492bbb13d081D680CE1f2957a287FD8c57c);
        vliquidPools[usdc] = address(0x67755124D8E4965c5c303fFd15641Db4Ff366e47);
        vliquidPools[address(0x1B8E12F839BD4e73A47adDF76cF7F0097d74c14C)] = address(0x50007A6BF4a45374Aa5206C1aBbA88A1ffde1bAF); // VUSD
        vliquidPools[address(0xB0BFB1E2F72511cF8b4D004852E2054d7b9a76e1)] = address(0xb9bcCC26fE0536E6476Aacc1dc97462B261b43d7); // MIXS
        vliquidPools[address(0x7865af71cf0b288b4E7F654f4F7851EB46a2B7F8)] = address(0x7df0B0DBD00d06203a0D2232282E33a5d2E5D5B0); // SNTVT
        vliquidPools[address(0x4981553e8CcF6Df916B36a2d6B6f8fC567628a51)] = address(0x809d6cbb321C29B1962d6f508a4FD4f564Ec7488); // BNI

        vliquidPoolsToWeth[address(0xc813EA5e3b48BEbeedb796ab42A30C5599b01740)] = address(0x0464994e800b4A1104e116fF248Cf6eA7494Ca47); // NIOX -> WETH
        vliquidPoolsToUsdc[address(0x07150e919B4De5fD6a63DE1F9384828396f25fDC)] = address(0x19B770c8F9d5439C419864d8458255791f7e736C); // BASE -> USDC
    }

    function setGovernance(address _governance) external {

        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setBFactory(IBFactory _bFactory) external {

        require(msg.sender == governance, "!governance");
        bFactory = _bFactory;
    }

    function setGovVault(address _govVault) external {

        require(msg.sender == governance, "!governance");
        govVault = _govVault;
    }

    function setInsuranceFund(address _insuranceFund) public {

        require(msg.sender == governance, "!governance");
        insuranceFund = _insuranceFund;
    }

    function setInsuranceFee(uint256 _insuranceFee) public {

        require(msg.sender == governance, "!governance");
        require(_insuranceFee <= 5000, "_insuranceFee over 50%");
        insuranceFee = _insuranceFee;
    }

    function addSupportedToken(address _token) external {

        require(msg.sender == governance, "!governance");
        require(supportedTokenLength < 255, "exceed token length");
        supportedTokens[supportedTokenLength] = _token;
        ++supportedTokenLength;
    }

    function removeSupportedToken(uint256 _index) external {

        require(msg.sender == governance, "!governance");
        require(_index < supportedTokenLength, "out of range");
        supportedTokens[_index] = supportedTokens[supportedTokenLength - 1];
        supportedTokens[supportedTokenLength - 1] = address(0);
        --supportedTokenLength;
    }

    function setSupportedToken(uint256 _index, address _token) external {

        require(msg.sender == governance, "!governance");
        supportedTokens[_index] = _token;
    }

    function setSupportedTokenLength(uint256 _length) external {

        require(msg.sender == governance, "!governance");
        require(_length <= 255, "exceed max length");
        supportedTokenLength = _length;
    }

    function setUnirouter(IUniswapV2Router _unirouter) external {

        require(msg.sender == governance, "!governance");
        unirouter = _unirouter;
    }

    function setUnirouterPath(address _input, address[] memory _path) external {

        require(msg.sender == governance, "!governance");
        uniswapPaths[_input] = _path;
    }

    function setBalancerPools(address _input, address _pool) external {

        require(msg.sender == governance, "!governance");
        vliquidPools[_input] = _pool;
    }

    function setUniswapPathsToUsdc(address _input, address[] memory _path) external {

        require(msg.sender == governance, "!governance");
        uniswapPathsToUsdc[_input] = _path;
    }

    function setBalancerPoolsToUsdc(address _input, address _pool) external {

        require(msg.sender == governance, "!governance");
        vliquidPoolsToUsdc[_input] = _pool;
    }

    function setUniswapPathsToWeth(address _input, address[] memory _path) external {

        require(msg.sender == governance, "!governance");
        uniswapPathsToWeth[_input] = _path;
    }

    function setBalancerPoolsToWeth(address _input, address _pool) external {

        require(msg.sender == governance, "!governance");
        vliquidPoolsToWeth[_input] = _pool;
    }

    function getOutputTokenToConvert(address _inputToken) external view returns (address _outputToken) {

        require(msg.sender == governance, "!governance");
        if (vliquidPools[_inputToken] != address(0) || uniswapPaths[_inputToken].length >= 2) {
            return valueToken;
        } else if (vliquidPoolsToUsdc[_inputToken] != address(0)) {
            return usdc;
        } else if (vliquidPoolsToWeth[_inputToken] != address(0)) {
            return weth;
        } else if (uniswapPathsToUsdc[_inputToken].length >= 2) {
            return usdc;
        } else if (uniswapPathsToWeth[_inputToken].length >= 2) {
            return weth;
        }
        return address(0);
    }

    function _bpoolExchangeRate(
        address _pool,
        address _input,
        address _output,
        uint256 _inputAmount
    ) public view returns (uint256 _outputAmount) {

        if (_inputAmount == 0) return 0;
        if (_pool != address(0)) {
            IBPool exPool = IBPool(_pool);
            _outputAmount = exPool.calcOutGivenIn(
                exPool.getBalance(_input),
                exPool.getDenormalizedWeight(_input),
                exPool.getBalance(_output),
                exPool.getDenormalizedWeight(_output),
                _inputAmount,
                exPool.swapFee()
            );
        }
    }

    function _uniswapExchangeRate(uint256 _tokenAmount, address[] memory _path) public view returns (uint256) {

        uint256[] memory amounts = unirouter.getAmountsOut(_tokenAmount, _path);
        return amounts[amounts.length - 1];
    }

    function getExchangeRateToValue(address _inputToken, uint256 _tokenAmount) public view returns (uint256 _valueAmount) {

        if (_tokenAmount == 0) return 0;
        address _pool = vliquidPools[_inputToken];
        if (_pool != address(0)) {
            return _bpoolExchangeRate(_pool, _inputToken, valueToken, _tokenAmount);
        } else if (vliquidPoolsToUsdc[_inputToken] != address(0)) {
            uint256 _usdcAmount = _bpoolExchangeRate(vliquidPoolsToUsdc[_inputToken], _inputToken, usdc, _tokenAmount);
            return _bpoolExchangeRate(vliquidPools[usdc], usdc, valueToken, _usdcAmount);
        } else if (vliquidPoolsToWeth[_inputToken] != address(0)) {
            uint256 _wethAmount = _bpoolExchangeRate(vliquidPoolsToWeth[_inputToken], _inputToken, weth, _tokenAmount);
            return _bpoolExchangeRate(vliquidPools[weth], weth, valueToken, _wethAmount);
        } else if (uniswapPathsToUsdc[_inputToken].length >= 2) {
            uint256 _usdcAmount = _uniswapExchangeRate(_tokenAmount, uniswapPathsToUsdc[_inputToken]);
            return _bpoolExchangeRate(vliquidPools[usdc], usdc, valueToken, _usdcAmount);
        } else if (uniswapPathsToWeth[_inputToken].length >= 2) {
            uint256 _wethAmount = _uniswapExchangeRate(_tokenAmount, uniswapPathsToWeth[_inputToken]);
            return _bpoolExchangeRate(vliquidPools[weth], weth, valueToken, _wethAmount);
        } else {
            address[] memory _path = uniswapPaths[_inputToken];
            if (_path.length == 0) {
                _path = new address[](2);
                _path[0] = _inputToken;
                _path[1] = valueToken;
            }
            return _uniswapExchangeRate(_tokenAmount, _path);
        }
    }

    function getAvailableTokens()
        external
        view
        returns (
            address[] memory _tokens,
            uint256[] memory _amounts,
            uint256[] memory _values
        )
    {

        _tokens = new address[](supportedTokenLength);
        _amounts = new uint256[](supportedTokenLength);
        _values = new uint256[](supportedTokenLength);
        for (uint256 i = 0; i < supportedTokenLength; i++) {
            address _stok = supportedTokens[i];
            _tokens[i] = _stok;
            uint256 _tokenAmt = IERC20(_stok).balanceOf(address(bFactory)).add(IERC20(_stok).balanceOf(address(this)));
            _amounts[i] = _tokenAmt;
            if (_stok == valueToken) {
                _values[i] = _tokenAmt;
            } else {
                _values[i] = getExchangeRateToValue(_stok, _tokenAmt);
            }
        }
    }

    function collectProfit(address _token, uint8 flag) public discountCHI(flag) returns (uint256 _profit) {

        bFactory.collect(_token);
        uint256 _tokenBal = IERC20(_token).balanceOf(address(this));
        if (_tokenBal > 0) {
            if (_token == valueToken) {
                _profit = _tokenBal;
            } else {
                _swapToValue(_token, _tokenBal);
                _profit = IERC20(valueToken).balanceOf(address(this));
            }
        }
        if (_profit > 0) {
            if (insuranceFee > 0 && insuranceFund != address(0)) {
                uint256 _insurance = _profit.mul(insuranceFee).div(10000);
                _profit = _profit.sub(_insurance);
                IERC20(valueToken).safeTransfer(insuranceFund, _insurance);
                emit CollectInsurance(_insurance);
            }
            IERC20(valueToken).safeTransfer(govVault, _profit);
            emit CollectProfit(_token, _tokenBal, _profit);
        }
    }

    function _bpoolSwap(
        address _pool,
        address _input,
        address _output,
        uint256 _inputAmount
    ) internal {

        IERC20(_input).safeApprove(_pool, 0);
        IERC20(_input).safeApprove(_pool, _inputAmount);
        IBPool(_pool).swapExactAmountIn(_input, _inputAmount, _output, 1, type(uint256).max);
    }

    function _uniSwap(uint256 _inputAmount, address[] memory _path) internal {

        IERC20 _inputToken = IERC20(_path[0]);
        _inputToken.safeApprove(address(unirouter), 0);
        _inputToken.safeApprove(address(unirouter), _inputAmount);
        unirouter.swapExactTokensForTokens(_inputAmount, 1, _path, address(this), now.add(1800));
    }

    function _swapToValue(address _inputToken, uint256 _amount) internal {

        if (_amount == 0) return;
        address _pool = vliquidPools[_inputToken];
        if (_pool != address(0)) {
            _bpoolSwap(_pool, _inputToken, valueToken, _amount);
        } else if (vliquidPoolsToUsdc[_inputToken] != address(0)) {
            _bpoolSwap(vliquidPoolsToUsdc[_inputToken], _inputToken, usdc, _amount);
            uint256 _usdcAmount = IERC20(usdc).balanceOf(address(this));
            _bpoolSwap(vliquidPools[usdc], usdc, valueToken, _usdcAmount);
        } else if (vliquidPoolsToWeth[_inputToken] != address(0)) {
            _bpoolSwap(vliquidPoolsToWeth[_inputToken], _inputToken, weth, _amount);
            uint256 _wethAmount = IERC20(weth).balanceOf(address(this));
            _bpoolSwap(vliquidPools[weth], weth, valueToken, _wethAmount);
        } else if (uniswapPathsToUsdc[_inputToken].length >= 2) {
            _uniSwap(_amount, uniswapPathsToUsdc[_inputToken]);
            uint256 _usdcAmount = IERC20(usdc).balanceOf(address(this));
            _bpoolSwap(vliquidPools[usdc], usdc, valueToken, _usdcAmount);
        } else if (uniswapPathsToWeth[_inputToken].length >= 2) {
            _uniSwap(_amount, uniswapPathsToWeth[_inputToken]);
            uint256 _wethAmount = IERC20(weth).balanceOf(address(this));
            _bpoolSwap(vliquidPools[weth], weth, valueToken, _wethAmount);
        } else {
            address[] memory _path = uniswapPaths[_inputToken];
            if (_path.length == 0) {
                _path = new address[](2);
                _path[0] = _inputToken;
                _path[1] = valueToken;
            }
            _uniSwap(_amount, _path);
        }
    }

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 amount,
        address to
    ) external {

        require(msg.sender == governance, "!governance");
        _token.transfer(to, amount);
    }
}