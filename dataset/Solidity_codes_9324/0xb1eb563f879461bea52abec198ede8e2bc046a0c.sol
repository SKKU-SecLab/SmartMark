



pragma solidity ^0.8.0;

interface IProtocol {

  function coverMap(address _collateral, uint48 _expirationTimestamp) external view returns (address);

  function addCover(address _collateral, uint48 _timestamp, uint256 _amount) external returns (bool);

}



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

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;

}



pragma solidity ^0.8.0;
interface ICover {

  function claimCovToken() external view returns (IERC20);

  function noclaimCovToken() external view returns (IERC20);

  function redeemCollateral(uint256 _amount) external;

}



pragma solidity ^0.8.0;

interface IBPool {

    function swapExactAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        address tokenOut,
        uint256 minAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);


    function swapExactAmountOut(
        address tokenIn,
        uint256 maxAmountIn,
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPrice
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);


    function calcOutGivenIn(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountIn,
        uint256 swapFee
    ) external view returns (uint256 tokenAmountOut);


    function calcInGivenOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 tokenBalanceOut,
        uint256 tokenWeightOut,
        uint256 tokenAmountOut,
        uint256 swapFee
    ) external view returns (uint256 tokenAmountIn);


    function getNormalizedWeight(address token) external view returns (uint256);

    function getBalance(address token) external view returns (uint256);

    function getSwapFee() external view returns (uint256);

}



pragma solidity ^0.8.0;
interface IFlashBorrower is IERC3156FlashBorrower {

    event NewFlashLender(address flashLender);

    struct FlashLoanData {
        bool isBuy;
        IBPool bpool;
        IProtocol protocol;
        address caller;
        address collateral;
        uint48 timestamp;
        uint256 amount;
        uint256 limit;
    }

    struct Permit {
        uint256 nonce;
        uint256 expiry;
        bool allowed;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function flashBuyClaim(
        IBPool _bpool,
        IProtocol _protocol, 
        address _collateral, 
        uint48 _timestamp, 
        uint256 _amountToBuy, 
        uint256 _maxAmountToSpend
    ) external;

    
    function flashBuyClaimPermit(
        IBPool _bpool,
        IProtocol _protocol, 
        address _collateral, 
        uint48 _timestamp, 
        uint256 _amountToBuy, 
        uint256 _maxAmountToSpend,
        Permit calldata permit
    ) external;


    function flashSellClaim(
        IBPool _bpool,
        IProtocol _protocol, 
        address _collateral, 
        uint48 _timestamp, 
        uint256 _amountToSell, 
        uint256 _minAmountToReturn
    ) external;


    function getBuyClaimCost(
        IBPool _bpool, 
        IProtocol _protocol, 
        address _collateral, 
        uint48 _timestamp, 
        uint256 _amountToBuy
    ) external view returns (uint256 totalCost);


    function getSellClaimReturn(
        IBPool _bpool, 
        IProtocol _protocol, 
        address _collateral, 
        uint48 _timestamp, 
        uint256 _amountToSell,
        uint256 _redeemFeeNumerator
    ) external view returns (uint256 totalReturn);


    function setFlashLender(address _flashLender) external;

    function collect(IERC20 _token) external;

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
    ) external;

}



pragma solidity ^0.8.0;
interface IYERC20 is IERC20 {

    function deposit(uint256 _amount) external;

    function withdraw(uint256 _shares) external;

    function getPricePerFullShare() external view returns (uint256);

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

contract CoverFlashBorrower is Ownable, IFlashBorrower {

    using SafeERC20 for IERC20;

    IERC3156FlashLender public flashLender;
    IERC20 public immutable dai;
    IYERC20 public immutable ydai;

    modifier onlySupportedCollaterals(address _collateral) {

        require(_collateral == address(dai) || _collateral == address(ydai), "only supports DAI and yDAI collaterals");
        _;
    }
    
    constructor (IERC3156FlashLender _flashLender, IERC20 _dai, IYERC20 _ydai) {
        flashLender = _flashLender;
        dai = _dai;
        ydai = _ydai;
    }

    function onFlashLoan(
        address initiator, 
        address token, 
        uint256 amount, 
        uint256 fee, 
        bytes calldata data
    ) external override returns(bytes32) {

        require(msg.sender == address(flashLender), "CoverFlashBorrower: Untrusted lender");
        require(initiator == address(this), "CoverFlashBorrower: Untrusted loan initiator");
        require(token == address(dai), "!dai"); // For v1, can only flashloan DAI
        uint256 amountOwed = amount + fee;
        FlashLoanData memory flashLoanData = abi.decode(data, (FlashLoanData));
        if (flashLoanData.isBuy) {
            _onFlashLoanBuyClaim(flashLoanData, amount, amountOwed);
        } else {
            _onFlashLoanSellClaim(flashLoanData, amount, amountOwed);
        }
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function flashBuyClaim(
        IBPool _bpool,
        IProtocol _protocol, 
        address _collateral, 
        uint48 _timestamp, 
        uint256 _amountToBuy, 
        uint256 _maxAmountToSpend
    ) public override onlySupportedCollaterals(_collateral) {

        bytes memory data = abi.encode(FlashLoanData({
            isBuy: true,
            bpool: _bpool,
            protocol: _protocol,
            caller: msg.sender,
            collateral: _collateral,
            timestamp: _timestamp,
            amount: _amountToBuy,
            limit: _maxAmountToSpend
        }));
        uint256 amountDaiNeeded;
        if (_collateral == address(dai)) {
            amountDaiNeeded = _amountToBuy;
        } else if (_collateral == address(ydai)) {
            amountDaiNeeded = _amountToBuy * ydai.getPricePerFullShare() / 1e18;
        }
        require(amountDaiNeeded <= flashLender.maxFlashLoan(address(dai)), "_amount > lender reserves");
        uint256 _allowance = dai.allowance(address(this), address(flashLender));
        uint256 _fee = flashLender.flashFee(address(dai), amountDaiNeeded);
        uint256 _repayment = amountDaiNeeded + _fee;
        _approve(dai, address(flashLender), _allowance + _repayment);
        flashLender.flashLoan(address(this), address(dai), amountDaiNeeded, data);
    }

    function flashBuyClaimPermit(
        IBPool _bpool,
        IProtocol _protocol, 
        address _collateral, 
        uint48 _timestamp, 
        uint256 _amountToBuy, 
        uint256 _maxAmountToSpend,
        Permit calldata permit
    ) external override {

        require(_collateral == address(dai), "only DAI permit is supported");
        IERC20(_collateral).permit(msg.sender, address(this), permit.nonce, permit.expiry, permit.allowed, permit.v, permit.r, permit.s);
        flashBuyClaim(_bpool, _protocol, _collateral, _timestamp, _amountToBuy, _maxAmountToSpend);
    }

    function flashSellClaim(
        IBPool _bpool,
        IProtocol _protocol, 
        address _collateral, 
        uint48 _timestamp, 
        uint256 _amountToSell, 
        uint256 _minAmountToReturn
    ) external override onlySupportedCollaterals(_collateral) {

        bytes memory data = abi.encode(FlashLoanData({
            isBuy: false,
            bpool: _bpool,
            protocol: _protocol,
            caller: msg.sender,
            collateral: _collateral,
            timestamp: _timestamp,
            amount: _amountToSell,
            limit: _minAmountToReturn
        }));
        (, IERC20 noclaimToken) = _getCovTokenAddresses(_protocol, _collateral, _timestamp);
        uint256 amountDaiNeeded = _calcInGivenOut(_bpool, address(dai), address(noclaimToken), _amountToSell);
        require(amountDaiNeeded <= flashLender.maxFlashLoan(address(dai)), "_amount > lender reserves");
        uint256 _allowance = dai.allowance(address(this), address(flashLender));
        uint256 _fee = flashLender.flashFee(address(dai), amountDaiNeeded);
        uint256 _repayment = amountDaiNeeded + _fee;
        _approve(dai, address(flashLender), _allowance + _repayment);
        flashLender.flashLoan(address(this), address(dai), amountDaiNeeded, data);
    }

    function setFlashLender(address _flashLender) external override onlyOwner {

        require(_flashLender != address(0), "_flashLender is 0");
        flashLender = IERC3156FlashLender(_flashLender);
        emit NewFlashLender(_flashLender);
    }

    function collect(IERC20 _token) external override onlyOwner {

        uint256 balance = _token.balanceOf(address(this));
        require(balance > 0, "_token balance is 0");
        _token.safeTransfer(msg.sender, balance);
    }

    function getBuyClaimCost(
        IBPool _bpool, 
        IProtocol _protocol, 
        address _collateral, 
        uint48 _timestamp, 
        uint256 _amountToBuy
    ) external override view onlySupportedCollaterals(_collateral) returns (uint256 totalCost) {

        uint256 amountDaiNeeded = _amountToBuy;
        if (_collateral == address(ydai)) {
            amountDaiNeeded = amountDaiNeeded * ydai.getPricePerFullShare() / 1e18;
        }
        uint256 flashFee = flashLender.flashFee(address(dai), amountDaiNeeded);
        uint256 daiReceivedFromSwap;
        {
            (, IERC20 noclaimToken) = _getCovTokenAddresses(_protocol, _collateral, _timestamp);
            daiReceivedFromSwap = _calcOutGivenIn(_bpool, address(noclaimToken), _amountToBuy, address(dai));
        }
        if (amountDaiNeeded + flashFee < daiReceivedFromSwap) {
            totalCost = 0;
        } else {
            totalCost =  amountDaiNeeded + flashFee - daiReceivedFromSwap;
        }
    }

    function getSellClaimReturn(
        IBPool _bpool, 
        IProtocol _protocol, 
        address _collateral, 
        uint48 _timestamp, 
        uint256 _amountToSell,
        uint256 _redeemFeeNumerator
    ) external override view onlySupportedCollaterals(_collateral) returns (uint256 totalReturn) {

        require(_redeemFeeNumerator <= 10000, "fee > 10000");
        (, IERC20 noclaimToken) = _getCovTokenAddresses(_protocol, _collateral, _timestamp);
        uint256 amountDaiNeeded = _calcInGivenOut(_bpool, address(dai), address(noclaimToken), _amountToSell);
        uint256 flashFee = flashLender.flashFee(address(dai), amountDaiNeeded);
        uint256 daiReceivedFromRedeem;
        if (_collateral == address(dai)) {
            daiReceivedFromRedeem = _amountToSell;
        } else if (_collateral == address(ydai)) {
            daiReceivedFromRedeem = _amountToSell * ydai.getPricePerFullShare() / 1e18;
        }
        daiReceivedFromRedeem = daiReceivedFromRedeem * (10000 - _redeemFeeNumerator) / 10000;
        if (daiReceivedFromRedeem < amountDaiNeeded + flashFee) {
            totalReturn = 0;
        } else {
            totalReturn = daiReceivedFromRedeem - amountDaiNeeded - flashFee;
        }
    }

    function _onFlashLoanBuyClaim(FlashLoanData memory data, uint256 amount, uint256 amountOwed) internal {

        uint256 mintAmount;

        if (data.collateral == address(dai)) {
            mintAmount = amount;
            _approve(dai, address(data.protocol), mintAmount);
        } else if (data.collateral == address(ydai)) {
            _approve(dai, address(ydai), amount);
            uint256 ydaiBalBefore = ydai.balanceOf(address(this));
            ydai.deposit(amount);
            mintAmount = ydai.balanceOf(address(this)) - ydaiBalBefore;
            _approve(ydai, address(data.protocol), mintAmount);
        }

        require(mintAmount > 0, "mintAmount is 0");
        data.protocol.addCover(data.collateral, data.timestamp, mintAmount);
        (IERC20 claimToken, IERC20 noclaimToken) = _getCovTokenAddresses(
            data.protocol, 
            data.collateral, 
            data.timestamp
        );
        
        _approve(noclaimToken, address(data.bpool), mintAmount);
        (uint256 daiReceived, ) = data.bpool.swapExactAmountIn(
            address(noclaimToken),
            mintAmount,
            address(dai),
            0,
            type(uint256).max
        );
        require(daiReceived > 0, "received 0 DAI from swap");
        require(amountOwed <= data.limit + daiReceived, "cost exceeds limit");
        if (amountOwed > daiReceived) {
            dai.safeTransferFrom(data.caller, address(this), amountOwed - daiReceived);
        }
        claimToken.safeTransfer(data.caller, mintAmount);
    }

    function _onFlashLoanSellClaim(FlashLoanData memory data, uint256 amount, uint256 amountOwed) internal {

        uint256 daiAvailable = amount;
        _approve(dai, address(data.bpool), amount);
        (IERC20 claimToken, IERC20 noclaimToken) = _getCovTokenAddresses(
            data.protocol, 
            data.collateral, 
            data.timestamp
        );
        (uint256 daiSpent, ) = data.bpool.swapExactAmountOut(
            address(dai),
            amount,
            address(noclaimToken),
            data.amount,
            type(uint256).max
        );
        daiAvailable = daiAvailable - daiSpent;
        claimToken.safeTransferFrom(data.caller, address(this), data.amount);
        
        uint256 collateralBalBefore = IERC20(data.collateral).balanceOf(address(this));
        address cover = data.protocol.coverMap(data.collateral, data.timestamp);
        ICover(cover).redeemCollateral(data.amount);
        uint256 collateralReceived = IERC20(data.collateral).balanceOf(address(this)) - collateralBalBefore;
        if (data.collateral == address(dai)) {
            daiAvailable = daiAvailable + collateralReceived;
        } else if (data.collateral == address(ydai)) {
            _approve(ydai, address(ydai), collateralReceived);
            uint256 daiBalBefore = dai.balanceOf(address(this));
            ydai.withdraw(collateralReceived);
            uint256 daiReceived = dai.balanceOf(address(this)) - daiBalBefore;
            daiAvailable = daiAvailable + daiReceived;
        }
        require(daiAvailable >= data.limit + amountOwed, "returns are less than limit");
        if (daiAvailable > amountOwed) {
            dai.safeTransfer(data.caller, daiAvailable - amountOwed);
        }
    }

    function _calcInGivenOut(IBPool _bpool, address _tokenIn, address _tokenOut, uint256 _tokenAmountOut) internal view returns (uint256 tokenAmountIn) {

        uint256 tokenBalanceIn = _bpool.getBalance(_tokenIn);
        uint256 tokenWeightIn = _bpool.getNormalizedWeight(_tokenIn);
        uint256 tokenBalanceOut = _bpool.getBalance(_tokenOut);
        uint256 tokenWeightOut = _bpool.getNormalizedWeight(_tokenOut);
        uint256 swapFee = _bpool.getSwapFee();

        tokenAmountIn = _bpool.calcInGivenOut(
            tokenBalanceIn,
            tokenWeightIn,
            tokenBalanceOut,
            tokenWeightOut,
            _tokenAmountOut,
            swapFee
        );
    }

    function _calcOutGivenIn(IBPool _bpool, address _tokenIn, uint256 _tokenAmountIn, address _tokenOut) internal view returns (uint256 tokenAmountOut) {

        uint256 tokenBalanceIn = _bpool.getBalance(_tokenIn);
        uint256 tokenWeightIn = _bpool.getNormalizedWeight(_tokenIn);
        uint256 tokenBalanceOut = _bpool.getBalance(_tokenOut);
        uint256 tokenWeightOut = _bpool.getNormalizedWeight(_tokenOut);
        uint256 swapFee = _bpool.getSwapFee();

        tokenAmountOut = _bpool.calcOutGivenIn(
            tokenBalanceIn,
            tokenWeightIn,
            tokenBalanceOut,
            tokenWeightOut,
            _tokenAmountIn,
            swapFee
        );
    } 

    function _getCovTokenAddresses(
        IProtocol _protocol, 
        address _collateral, 
        uint48 _timestamp
    ) internal view returns (IERC20 claimToken, IERC20 noclaimToken) {

        address cover = _protocol.coverMap(_collateral, _timestamp);
        claimToken = ICover(cover).claimCovToken();
        noclaimToken = ICover(cover).noclaimCovToken();
    }

    function _approve(IERC20 _token, address _spender, uint256 _amount) internal {

        if (_token.allowance(address(this), _spender) < _amount) {
            _token.safeApprove(_spender, type(uint256).max);
        }
    }
}