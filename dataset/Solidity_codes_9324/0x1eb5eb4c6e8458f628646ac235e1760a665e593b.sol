


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
}


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
}


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
}


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
}


pragma solidity 0.6.12;

interface IErc20VaultPoolSwap {

  function swapErc20ToVaultPool(
    address _pool,
    address _swapToken,
    uint256 _swapAmount
  ) external returns (uint256 poolAmountOut);


  function swapVaultPoolToErc20(
    address _pool,
    uint256 _poolAmountIn,
    address _swapToken
  ) external returns (uint256 erc20Out);


  function swapVaultToUSDC(
    address _from,
    address _to,
    address _vaultTokenIn,
    uint256 _vaultAmountIn
  ) external returns (uint256 usdcAmountOut);


  function calcVaultOutByUsdc(address _token, uint256 _usdcIn) external view returns (uint256 amountOut);


  function calcVaultPoolOutByUsdc(
    address _pool,
    uint256 _usdcIn,
    bool _withFee
  ) external view returns (uint256 amountOut);


  function calcUsdcOutByVault(address _vaultTokenIn, uint256 _vaultAmountIn)
    external
    view
    returns (uint256 usdcAmountOut);


  function calcUsdcOutByPool(
    address _pool,
    uint256 _ppolIn,
    bool _withFee
  ) external view returns (uint256 amountOut);

}


pragma solidity 0.6.12;

interface IIndiciesSupplyRedeemZap {

  function poolSwapContract(address) external view returns (address);


  function depositErc20(
    address _pool,
    address _inputToken,
    uint256 _amount
  ) external;


  function depositPoolToken(
    address _pool,
    address _outputToken,
    uint256 _poolAmount
  ) external;

}


pragma solidity ^0.6.0;

interface IYearnVaultV2 {

  function token() external view returns (address);


  function totalAssets() external view returns (uint256);


  function pricePerShare() external view returns (uint256);


  function deposit(uint256 amount) external;


  function deposit(uint256 amount, address recipient) external;


  function withdraw(uint256 maxShares) external;


  function withdraw(uint256 maxShares, address recipient) external;


  function withdraw(
    uint256 maxShares,
    address recipient,
    uint256 maxLoss
  ) external;


  function report(
    uint256 gain,
    uint256 loss,
    uint256 debtPayment
  ) external returns (uint256);

}


pragma solidity 0.6.12;

interface ICVPMakerViewer {

  function getRouter(address token_) external view returns (address);


  function getPath(address token_) external view returns (address[] memory);


  function getDefaultPath(address token_) external view returns (address[] memory);



  function estimateEthStrategyIn() external view returns (uint256);


  function estimateEthStrategyOut(address tokenIn_, uint256 _amountIn) external view returns (uint256);


  function estimateUniLikeStrategyIn(address token_) external view returns (uint256);


  function estimateUniLikeStrategyOut(address token_, uint256 amountIn_) external view returns (uint256);



  function calcBPoolGrossAmount(uint256 tokenAmountNet_, uint256 communityFee_)
    external
    view
    returns (uint256 tokenAmountGross);

}


pragma solidity 0.6.12;

interface ICVPMakerStrategy {

  function getExecuteDataByAmountOut(
    address poolTokenIn_,
    uint256 tokenOutAmount_,
    bytes memory config_
  )
    external
    view
    returns (
      uint256 poolTokenInAmount,
      address executeUniLikeFrom,
      bytes memory executeData,
      address executeContract
    );


  function getExecuteDataByAmountIn(
    address poolTokenIn_,
    uint256 tokenInAmount_,
    bytes memory config_
  )
    external
    view
    returns (
      address executeUniLikeFrom,
      bytes memory executeData,
      address executeContract
    );


  function estimateIn(
    address tokenIn_,
    uint256 tokenOutAmount_,
    bytes memory
  ) external view returns (uint256 amountIn);


  function estimateOut(
    address poolTokenIn_,
    uint256 tokenInAmount_,
    bytes memory
  ) external view returns (uint256);


  function getTokenOut() external view returns (address);

}


pragma solidity 0.6.12;

contract CVPMakerZapStrategy is ICVPMakerStrategy {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  address public immutable tokenOut;
  IIndiciesSupplyRedeemZap public immutable zap;
  uint256 public immutable extraOutPct;

  constructor(
    address tokenOut_,
    address zap_,
    uint256 extraOutPct_
  ) public {
    tokenOut = tokenOut_;
    zap = IIndiciesSupplyRedeemZap(zap_);
    extraOutPct = extraOutPct_;
  }

  function getExecuteDataByAmountOut(
    address poolTokenIn_,
    uint256 tokenOutAmount_,
    bytes memory config_
  )
    external
    view
    override
    returns (
      uint256 poolTokenInAmount,
      address executeUniLikeFrom,
      bytes memory executeData,
      address executeContract
    )
  {

    poolTokenInAmount = estimateIn(poolTokenIn_, tokenOutAmount_, config_);
    executeData = _getExecuteDataByAmountIn(poolTokenIn_, poolTokenInAmount);
    executeContract = address(zap);
    executeUniLikeFrom = address(0);
  }

  function getExecuteDataByAmountIn(
    address poolTokenIn_,
    uint256 poolTokenInAmount_,
    bytes memory config_
  )
    external
    view
    override
    returns (
      address executeUniLikeFrom,
      bytes memory executeData,
      address executeContract
    )
  {

    executeData = _getExecuteDataByAmountIn(poolTokenIn_, poolTokenInAmount_);
    executeContract = address(zap);
    executeUniLikeFrom = address(0);
  }

  function _getExecuteDataByAmountIn(address poolTokenIn_, uint256 poolTokenInAmount_)
    internal
    view
    returns (bytes memory)
  {

    return
      abi.encodePacked(
        IIndiciesSupplyRedeemZap(0).depositPoolToken.selector,
        abi.encode(poolTokenIn_, tokenOut, poolTokenInAmount_)
      );
  }

  function estimateIn(
    address poolTokenIn_,
    uint256 tokenOutAmount_,
    bytes memory
  ) public view override returns (uint256) {

    IErc20VaultPoolSwap vaultSwap = IErc20VaultPoolSwap(zap.poolSwapContract(poolTokenIn_));
    return vaultSwap.calcVaultPoolOutByUsdc(poolTokenIn_, tokenOutAmount_, true).mul(extraOutPct) / 1 ether;
  }

  function estimateOut(
    address poolTokenIn_,
    uint256 tokenInAmount_,
    bytes memory
  ) public view override returns (uint256) {

    IErc20VaultPoolSwap vaultSwap = IErc20VaultPoolSwap(zap.poolSwapContract(poolTokenIn_));
    return vaultSwap.calcUsdcOutByPool(poolTokenIn_, tokenInAmount_, true).mul(1 ether) / extraOutPct;
  }

  function getTokenOut() external view override returns (address) {

    return tokenOut;
  }
}