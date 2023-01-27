
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
pragma solidity 0.7.6;


interface ICurveSwap {

    function exchange(int128 i, int128 j, uint256 _dx, uint256 _min_dy) external;

}

interface IBalancerSwap {

    function getSpotPrice(address tokenIn, address tokenOut) external view returns (uint spotPrice);


    function swapExactAmountIn(
        address tokenIn,
        uint tokenAmountIn,
        address tokenOut,
        uint minAmountOut,
        uint maxPrice
    ) external returns (uint tokenAmountOut, uint spotPriceAfter);


    function swapExactAmountOut(
        address tokenIn,
        uint maxAmountIn,
        address tokenOut,
        uint tokenAmountOut,
        uint maxPrice
    ) external returns (uint tokenAmountIn, uint spotPriceAfter);

}

interface ISushiSwap {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint[] memory amounts);


    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint[] memory amounts);

}

interface IChainlink {

    function latestAnswer() external view returns (int256);

}

contract ElonApeStrategy is Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 private constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // 18 decimals
    IERC20 private constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); // 6 decimals
    IERC20 private constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // 6 decimals
    IERC20 private constant DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); // 18 decimals
    IERC20 private constant sUSD = IERC20(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51); // 18 decimals

    ICurveSwap private constant _cSwap = ICurveSwap(0xA5407eAE9Ba41422680e2e00537571bcC53efBfD);
    IBalancerSwap private constant _bSwap = IBalancerSwap(0x055dB9AFF4311788264798356bbF3a733AE181c6);
    ISushiSwap private constant _sSwap = ISushiSwap(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    IERC20 private constant sTSLA = IERC20(0x918dA91Ccbc32B7a6A0cc4eCd5987bbab6E31e6D); // 18 decimals
    IERC20 private constant WBTC = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599); // 8 decimals
    IERC20 private constant renDOGE = IERC20(0x3832d2F059E55934220881F831bE501D180671A7); // 8 decimals

    address public vault;
    uint256[] public weights; // [sTSLA, WBTC, renDOGE]
    uint256 private constant DENOMINATOR = 10000;
    bool public isVesting;

    event AmtToInvest(uint256 _amount); // In USD (6 decimals)
    event CurrentComposition(uint256 _poolSTSLA, uint256 _poolWBTC, uint256 _poolRenDOGE); // in USD (6 decimals)
    event TargetComposition(uint256 _poolSTSLA, uint256 _poolWBTC, uint256 _poolRenDOGE); // in USD (6 decimals)

    modifier onlyVault {

        require(msg.sender == vault, "Only vault");
        _;
    }

    constructor(uint256[] memory _weights) {
        weights = _weights;

        USDT.safeApprove(address(_cSwap), type(uint256).max);
        USDC.safeApprove(address(_cSwap), type(uint256).max);
        DAI.safeApprove(address(_cSwap), type(uint256).max);
        sUSD.safeApprove(address(_cSwap), type(uint256).max);
        sUSD.safeApprove(address(_bSwap), type(uint256).max);
        sTSLA.safeApprove(address(_bSwap), type(uint256).max);
        USDT.safeApprove(address(_sSwap), type(uint256).max);
        USDC.safeApprove(address(_sSwap), type(uint256).max);
        DAI.safeApprove(address(_sSwap), type(uint256).max);
        WETH.safeApprove(address(_sSwap), type(uint256).max);
        WBTC.safeApprove(address(_sSwap), type(uint256).max);
        renDOGE.safeApprove(address(_sSwap), type(uint256).max);
    }

    function setVault(address _vault) external onlyOwner {

        require(vault == address(0), "Vault set");
        vault = _vault;
    }

    function invest(uint256 _amountUSDT, uint256 _amountUSDC, uint256 _amountDAI) external onlyVault {

        if (_amountUSDT > 0) {
            USDT.safeTransferFrom(address(vault), address(this), _amountUSDT);
        }
        if (_amountUSDC > 0) {
            USDC.safeTransferFrom(address(vault), address(this), _amountUSDC);
        }
        if (_amountDAI > 0) {
            DAI.safeTransferFrom(address(vault), address(this), _amountDAI);
        }
        uint256 _totalInvestInUSD = _amountUSDT.add(_amountUSDC).add(_amountDAI.div(1e12));
        require(_totalInvestInUSD > 0, "Not enough Stablecoin to invest");
        emit AmtToInvest(_totalInvestInUSD);

        (uint256 _poolSTSLA, uint256 _poolWBTC, uint256 _poolRenDOGE) = getFarmsPool();
        uint256 _totalPool = _poolSTSLA.add(_poolWBTC).add(_poolRenDOGE).add(_totalInvestInUSD);
        uint256 _poolSTSLATarget = _totalPool.mul(weights[0]).div(DENOMINATOR);
        uint256 _poolWBTCTarget = _totalPool.mul(weights[1]).div(DENOMINATOR);
        uint256 _poolRenDOGETarget = _totalPool.mul(weights[2]).div(DENOMINATOR);
        emit CurrentComposition(_poolSTSLA, _poolWBTC, _poolRenDOGE);
        emit TargetComposition(_poolSTSLATarget, _poolWBTCTarget, _poolRenDOGETarget);
        if (
            _poolSTSLATarget > _poolSTSLA &&
            _poolWBTCTarget > _poolWBTC &&
            _poolRenDOGETarget > _poolRenDOGE
        ) {
            _investSTSLA(_poolSTSLATarget.sub(_poolSTSLA), _totalInvestInUSD);
            uint256 _WETHBalance = _swapAllStablecoinsToWETH();
            uint256 _investWBTCAmtInUSD = _poolWBTCTarget.sub(_poolWBTC);
            uint256 _investRenDOGEAmtInUSD = _poolRenDOGETarget.sub(_poolRenDOGE);
            uint256 _investWBTCAmtInETH = _WETHBalance.mul(_investWBTCAmtInUSD).div(_investWBTCAmtInUSD.add(_investRenDOGEAmtInUSD));
            _investWBTC(_investWBTCAmtInETH);
            _investRenDOGE(_WETHBalance.sub(_investWBTCAmtInETH));
        } else {
            uint256 _furthest;
            uint256 _farmIndex;
            uint256 _diff;
            if (_poolSTSLATarget > _poolSTSLA) {
                _furthest = _poolSTSLATarget.sub(_poolSTSLA);
                _farmIndex = 0;
            }
            if (_poolWBTCTarget > _poolWBTC) {
                _diff = _poolWBTCTarget.sub(_poolWBTC);
                if (_diff > _furthest) {
                    _furthest = _diff;
                    _farmIndex = 1;
                }
            }
            if (_poolRenDOGETarget > _poolRenDOGE) {
                _diff = _poolRenDOGETarget.sub(_poolRenDOGE);
                if (_diff > _furthest) {
                    _furthest = _diff;
                    _farmIndex = 2;
                }
            }
            if (_farmIndex == 0) {
                _investSTSLA(_totalInvestInUSD, _totalInvestInUSD);
            } else {
                uint256 _WETHBalance = _swapAllStablecoinsToWETH();
                if (_farmIndex == 1) {
                    _investWBTC(_WETHBalance);
                } else {
                    _investRenDOGE(_WETHBalance);
                }
            }
        }
    }

    function _investSTSLA(uint256 _amount, uint256 _totalInvestInUSD) private {

        uint256 _USDTBalance = USDT.balanceOf(address(this));
        if (_USDTBalance > 1e6) { // Set minimum swap amount to avoid error
            _cSwap.exchange(2, 3, _USDTBalance.mul(_amount).div(_totalInvestInUSD), 0);
        }
        uint256 _USDCBalance = USDC.balanceOf(address(this));
        if (_USDCBalance > 1e6) {
            _cSwap.exchange(1, 3, _USDCBalance.mul(_amount).div(_totalInvestInUSD), 0);
        }
        uint256 _DAIBalance = DAI.balanceOf(address(this));
        if (_DAIBalance > 1e18) {
            _cSwap.exchange(0, 3, _DAIBalance.mul(_amount).div(_totalInvestInUSD), 0);
        }
        uint256 _sUSDBalance = sUSD.balanceOf(address(this));
        _bSwap.swapExactAmountIn(address(sUSD), _sUSDBalance, address(sTSLA), 0, type(uint256).max);
    }

    function _investWBTC(uint256 _amount) private {

        _swapExactTokensForTokens(address(WETH), address(WBTC), _amount);
    }

    function _investRenDOGE(uint256 _amount) private {

        _swapExactTokensForTokens(address(WETH), address(renDOGE), _amount);
    }

    function _swapAllStablecoinsToWETH() private returns (uint256) {

        uint256 _USDTBalance = USDT.balanceOf(address(this));
        if (_USDTBalance > 1e6) { // Set minimum swap amount to avoid error
            _swapExactTokensForTokens(address(USDT), address(WETH), _USDTBalance);
        }
        uint256 _USDCBalance = USDC.balanceOf(address(this));
        if (_USDCBalance > 1e6) {
            _swapExactTokensForTokens(address(USDC), address(WETH), _USDCBalance);
        }
        uint256 _DAIBalance = DAI.balanceOf(address(this));
        if (_DAIBalance > 1e18) {
            _swapExactTokensForTokens(address(DAI), address(WETH), _DAIBalance);
        }
        return WETH.balanceOf(address(this));
    }

    function withdraw(uint256 _amount, uint256 _tokenIndex) external onlyVault returns (uint256) {

        uint256 _totalPool = getTotalPool();
        (IERC20 _token, int128 _curveIndex) = _determineTokenTypeAndCurveIndex(_tokenIndex);
        uint256 _withdrawAmt;
        if (!isVesting) {
            uint256 _sTSLAAmtToWithdraw = (sTSLA.balanceOf(address(this))).mul(_amount).div(_totalPool);
            _withdrawSTSLA(_sTSLAAmtToWithdraw, _curveIndex);
            uint256 _WBTCAmtToWithdraw = (WBTC.balanceOf(address(this))).mul(_amount).div(_totalPool);
            _swapExactTokensForTokens(address(WBTC), address(WETH), _WBTCAmtToWithdraw);
            uint256 _renDOGEAmtToWithdraw = (renDOGE.balanceOf(address(this))).mul(_amount).div(_totalPool);
            _swapExactTokensForTokens(address(renDOGE), address(WETH), _renDOGEAmtToWithdraw);
            _swapExactTokensForTokens(address(WETH), address(_token), WETH.balanceOf(address(this)));
            _withdrawAmt = _token.balanceOf(address(this));
        } else {
            uint256 _withdrawAmtInETH = (WETH.balanceOf(address(this))).mul(_amount).div(_totalPool);
            uint256[] memory _amountsOut = _swapExactTokensForTokens(address(WETH), address(_token), _withdrawAmtInETH);
            _withdrawAmt = _amountsOut[1];
        }
        _token.safeTransfer(address(vault), _withdrawAmt);
        if (_token == DAI) { // To make consistency of 6 decimals return
            _withdrawAmt = _withdrawAmt.div(1e12);
        }
        return _withdrawAmt;
    }

    function _withdrawSTSLA(uint256 _amount, int128 _curveIndex) private {

        (uint256 _amountOut,) = _bSwap.swapExactAmountIn(address(sTSLA), _amount, address(sUSD), 0, type(uint256).max);
        _cSwap.exchange(3, _curveIndex, _amountOut, 0);
    }

    function releaseStablecoinsToVault(uint256 _tokenIndex, uint256 _farmIndex, uint256 _amount) external onlyVault {

        (IERC20 _token, int128 _curveIndex) = _determineTokenTypeAndCurveIndex(_tokenIndex);
        if (_farmIndex == 0) {
            _amount = _amount.mul(1e12);
            _bSwap.swapExactAmountOut(address(sTSLA), type(uint256).max, address(sUSD), _amount, type(uint256).max);
            _cSwap.exchange(3, _curveIndex, _amount, 0);
            _token.safeTransfer(address(vault), _token.balanceOf(address(this)));
        } else {
            if (_token == DAI) { // Follow DAI decimals
                _amount = _amount.mul(1e12);
            }
            uint256[] memory _amountsOut = _sSwap.getAmountsOut(_amount, _getPath(address(_token), address(WETH)));
            IERC20 _farm;
            if (_farmIndex == 1) {
                _farm = WBTC;
            } else {
                _farm = renDOGE;
            }
            _sSwap.swapTokensForExactTokens(_amountsOut[1], type(uint256).max, _getPath(address(_farm), address(WETH)), address(this), block.timestamp);
            _sSwap.swapExactTokensForTokens(_amountsOut[1], 0, _getPath(address(WETH), address(_token)), address(vault), block.timestamp);
        }
    }

    function emergencyWithdraw() external onlyVault {

        _withdrawSTSLA(sTSLA.balanceOf(address(this)), 2);
        _swapExactTokensForTokens(address(USDT), address(WETH), USDT.balanceOf(address(this)));
        _swapExactTokensForTokens(address(WBTC), address(WETH), WBTC.balanceOf(address(this)));
        _swapExactTokensForTokens(address(renDOGE), address(WETH), renDOGE.balanceOf(address(this)));

        isVesting = true;
    }

    function reinvest() external onlyVault {

        isVesting = false;
        uint256 _WETHBalance = WETH.balanceOf(address(this));
        _swapExactTokensForTokens(address(WETH), address(USDT), _WETHBalance.mul(weights[0]).div(DENOMINATOR));
        _investSTSLA(1, 1); // Invest all avalaible Stablecoins
        _investWBTC(_WETHBalance.mul(weights[1]).div(DENOMINATOR));
        _investRenDOGE(WETH.balanceOf(address(this)));
    }

    function approveMigrate() external onlyOwner {

        require(isVesting, "Not in vesting state");
        WETH.safeApprove(address(vault), type(uint256).max);
    }

    function setWeights(uint256[] memory _weights) external onlyVault {

        weights = _weights;
    }

    function _swapExactTokensForTokens(address _tokenA, address _tokenB, uint256 _amountIn) private returns (uint256[] memory _amounts) {

        address[] memory _path = _getPath(_tokenA, _tokenB);
        uint256[] memory _amountsOut = _sSwap.getAmountsOut(_amountIn, _path);
        if (_amountsOut[1] > 0) {
            _amounts = _sSwap.swapExactTokensForTokens(_amountIn, 0, _path, address(this), block.timestamp);
        }
    }

    function _getPath(address _tokenA, address _tokenB) private pure returns (address[] memory) {

        address[] memory _path = new address[](2);
        _path[0] = _tokenA;
        _path[1] = _tokenB;
        return _path;
    }

    function _determineTokenTypeAndCurveIndex(uint256 _tokenIndex) private pure returns (IERC20, int128) {

        IERC20 _token;
        int128 _curveIndex;
        if (_tokenIndex == 0) {
            _token = USDT;
            _curveIndex = 2;
        } else if (_tokenIndex == 1) {
            _token = USDC;
            _curveIndex = 1;
        } else {
            _token = DAI;
            _curveIndex = 0;
        }
        return (_token, _curveIndex);
    }

    function _getCurrentPriceOfETHInUSD() private view returns (uint256) {

        IChainlink _pricefeed = IChainlink(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        return uint256(_pricefeed.latestAnswer());
    }

    function getTotalPool() public view returns (uint256) {

        if (!isVesting) {
            (uint256 _poolSTSLA, uint256 _poolWBTC, uint256 _poolrenDOGE) = getFarmsPool();
            return _poolSTSLA.add(_poolWBTC).add(_poolrenDOGE);
        } else {
            uint256 _price = _getCurrentPriceOfETHInUSD();
            return (WETH.balanceOf(address(this))).mul(_price).div(1e20);
        }
    }

    function getFarmsPool() public view returns (uint256, uint256, uint256) {

        uint256 _price = _getCurrentPriceOfETHInUSD();
        uint256 _sTSLAPriceInUSD = _bSwap.getSpotPrice(address(sUSD), address(sTSLA)); // 18 decimals
        uint256 _poolSTSLA = (sTSLA.balanceOf(address(this))).mul(_sTSLAPriceInUSD).div(1e30);
        uint256[] memory _WBTCPriceInETH = _sSwap.getAmountsOut(1e8, _getPath(address(WBTC), address(WETH)));
        uint256 _poolWBTC = (WBTC.balanceOf(address(this))).mul(_WBTCPriceInETH[1].mul(_price)).div(1e28);
        uint256[] memory _renDOGEPriceInETH = _sSwap.getAmountsOut(1e8, _getPath(address(renDOGE), address(WETH)));
        uint256 _poolrenDOGE = (renDOGE.balanceOf(address(this))).mul(_renDOGEPriceInETH[1].mul(_price)).div(1e28);

        return (_poolSTSLA, _poolWBTC, _poolrenDOGE);
    }
}