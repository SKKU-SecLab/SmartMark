


pragma solidity ^0.8.0;

interface IERC3156FlashBorrower {


  function onFlashLoan(
      address initiator,
      address token,
      uint256 amount,
      uint256 fee,
      bytes calldata data
  ) external returns (bytes32);

}



pragma solidity ^0.8.0;
interface IERC3156FlashLender {

  function maxFlashLoan(
      address token
  ) external view returns (uint256);


  function flashFee(
      address token,
      uint256 amount
  ) external view returns (uint256);


  function flashLoan(
      address receiver,
      address token,
      uint256 amount,
      bytes calldata data
  ) external returns (bool);

}



pragma solidity ^0.8.0;

interface ICErc20 {

    function liquidateBorrow(address borrower, uint amount, address collateral) external returns (uint);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function underlying() external view returns (address);

}



pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

}



pragma solidity ^0.8.0;
interface IWeth is IERC20 {

    function deposit() external payable;

}



pragma solidity ^0.8.0;

interface IComptroller {

    function getAccountLiquidity(address account) external view returns (uint256, uint256, uint256);

}



pragma solidity ^0.8.0;

interface IRouter {

    function getAmountsIn(uint256 amountOut, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

        
    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.8.0;
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}



pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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



pragma solidity ^0.8.0;
library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.8.0;
contract AnchorFlashLiquidator is Ownable {

    using SafeERC20 for IERC20;

    IERC3156FlashLender public flashLender =
        IERC3156FlashLender(0x6bdC1FCB2F13d1bA9D26ccEc3983d5D4bf318693);
    IComptroller public comptroller =
        IComptroller(0x4dCf7407AE5C07f8681e1659f626E114A7667339);
    IRouter public constant sushiRouter =
        IRouter(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
    IRouter public constant uniRouter =
        IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IERC20 public constant dola =
        IERC20(0x865377367054516e17014CcdED1e7d814EDC9ce4);
    IWeth public constant weth =
        IWeth(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public constant dai =
        IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    struct LiquidationData {
        address cErc20;
        address cTokenCollateral;
        address borrower;
        address caller;
        IRouter dolaRouter;
        IRouter exitRouter;
        uint256 amount;
        uint256 minProfit;
        uint256 deadline;
    }

    function liquidate(
        address _flashLoanToken,
        address _cErc20,
        address _borrower,
        uint256 _amount,
        address _cTokenCollateral,
        IRouter _dolaRouter,
        IRouter _exitRouter,
        uint256 _minProfit,
        uint256 _deadline
    ) external {

        require(
            (_dolaRouter == sushiRouter || _dolaRouter == uniRouter) &&
                (_exitRouter == sushiRouter || _exitRouter == uniRouter),
            "Invalid router"
        );
        (, , uint256 shortfall) = comptroller.getAccountLiquidity(_borrower);
        require(shortfall > 0, "!liquidatable");
        address[] memory path = _getDolaPath(_flashLoanToken);
        uint256 tokensNeeded;
        {
            tokensNeeded = _dolaRouter.getAmountsIn(_amount, path)[0];
            require(
                tokensNeeded <= flashLender.maxFlashLoan(_flashLoanToken),
                "Insufficient lender reserves"
            );
            uint256 fee = flashLender.flashFee(_flashLoanToken, tokensNeeded);
            uint256 repayment = tokensNeeded + fee;
            _approve(IERC20(_flashLoanToken), address(flashLender), repayment);
        }
        bytes memory data =
            abi.encode(
                LiquidationData({
                    cErc20: _cErc20,
                    cTokenCollateral: _cTokenCollateral,
                    borrower: _borrower,
                    caller: msg.sender,
                    dolaRouter: _dolaRouter,
                    exitRouter: _exitRouter,
                    amount: _amount,
                    minProfit: _minProfit,
                    deadline: _deadline
                })
            );
        flashLender.flashLoan(
            address(this),
            _flashLoanToken,
            tokensNeeded,
            data
        );
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {

        require(msg.sender == address(flashLender), "Untrusted lender");
        require(initiator == address(this), "Untrusted loan initiator");
        LiquidationData memory liqData = abi.decode(data, (LiquidationData));

        _approve(IERC20(token), address(liqData.dolaRouter), amount);
        address[] memory entryPath = _getDolaPath(token);
        require(
            liqData.amount ==
                liqData.dolaRouter.swapExactTokensForTokens(
                    amount,
                    0,
                    entryPath,
                    address(this),
                    liqData.deadline
                )[entryPath.length - 1],
            "Incorrect DOLA amount received"
        );

        _approve(dola, liqData.cErc20, liqData.amount);
        ICErc20(liqData.cErc20).liquidateBorrow(
            liqData.borrower,
            liqData.amount,
            liqData.cTokenCollateral
        );
        uint256 seizedBal =
            IERC20(liqData.cTokenCollateral).balanceOf(address(this));

        _approve(IERC20(liqData.cTokenCollateral), liqData.cErc20, seizedBal);
        uint256 ethBalBefore = address(this).balance; // snapshot ETH balance before redeem to determine if it is cEther
        ICErc20(liqData.cTokenCollateral).redeem(seizedBal);
        address underlying;

        if (address(this).balance > ethBalBefore) {
            weth.deposit{value: address(this).balance}();
            underlying = address(weth);
        } else {
            underlying = ICErc20(liqData.cTokenCollateral).underlying();
        }
        uint256 underlyingBal = IERC20(underlying).balanceOf(address(this));

        uint256 tokensReceived;
        if (underlying != token) {
            _approve(
                IERC20(underlying),
                address(liqData.exitRouter),
                underlyingBal
            );
            address[] memory exitPath = _getExitPath(underlying, token);
            tokensReceived = liqData.exitRouter.swapExactTokensForTokens(
                underlyingBal,
                0,
                exitPath,
                address(this),
                liqData.deadline
            )[exitPath.length - 1];
        } else {
            tokensReceived = underlyingBal;
        }

        require(
            tokensReceived >= amount + fee + liqData.minProfit,
            "Not enough profit"
        );

        IERC20(token).safeTransfer(
            liqData.caller,
            tokensReceived - (amount + fee)
        );
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function receiveEth() external payable {}


    function setFlashLender(IERC3156FlashLender _flashLender)
        external
        onlyOwner
    {

        flashLender = _flashLender;
    }

    function setComptroller(IComptroller _comptroller) external onlyOwner {

        comptroller = _comptroller;
    }

    function _getDolaPath(address _token)
        internal
        pure
        returns (address[] memory path)
    {

        if (_token == address(weth)) {
            path = new address[](2);
            path[0] = address(weth);
            path[1] = address(dola);
        } else {
            path = new address[](3);
            path[0] = _token;
            path[1] = address(weth);
            path[2] = address(dola);
        }
    }

    function _getExitPath(address _underlying, address _token)
        internal
        pure
        returns (address[] memory path)
    {

        if (_underlying == address(weth)) {
            path = new address[](2);
            path[0] = address(weth);
            path[1] = _token;
        } else {
            path = new address[](3);
            path[0] = address(_underlying);
            path[1] = address(weth);
            path[2] = _token;
        }
    }

    function _approve(
        IERC20 _token,
        address _spender,
        uint256 _amount
    ) internal {

        if (_token.allowance(address(this), _spender) < _amount) {
            _token.safeApprove(_spender, type(uint256).max);
        }
    }
}