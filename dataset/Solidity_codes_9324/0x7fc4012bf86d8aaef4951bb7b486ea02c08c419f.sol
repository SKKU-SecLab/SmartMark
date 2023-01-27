


pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}


pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}




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
}




pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}




pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;

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

        return functionCallWithValue(target, data, 0, errorMessage);
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.8.4;






interface IBurnable{

    function burn(uint256 amount) external;

}

contract AngryContract is ReentrancyGuard{

    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    
    struct PrePurchaseInfo {
        uint256 amount;
        uint256 paymentAmount;
        uint256 price;
        uint256 expectedPrice;
        uint256 startTime;
        uint256 expiredTime;
        uint8 status;  // 0: not deal, 1 : deal, 2 : cancel, 3 : confirm, 4 : expired
        uint8 paymentType; // 1:ETH, 2:USDT
    }
    
    struct MiningPoolInfo {
        uint256 beginTime;
        uint256 endTime;
        uint256 rewardAmount;
        uint256 claimedAmount;
        uint256 burnedAmount;
        mapping(address => uint256) claimedAccounts;
    }
    
    struct ClaimRewardsInfo {
        string taskId;
        uint256 amount;
        uint256 time;
    }
    bool public bInited;
    bool public bStarted;
    uint256 public expectedPriceFloatValLo;
    uint256 public expectedPriceFloatValHi;
    uint256 public expectedPriceMultipleLo;
    uint256 public expectedPriceMultipleHi;
    address public angryTokenAddr;
    address public usdtTokenAddr;
    address public vitalikButerinAddr;
    address public uniswapRouterAddr;
    uint256 public maxMiningTaskReward;
    uint256 public minPrePurchaseUSDT;
    uint256 public minPrePurchaseETH;
    uint256 public cumulativePeriods;
    uint256 public prePurchaseSupplyPeriod;
    uint256 public prePurchaseSupplyAmount;
    uint256 public cumulativePrePurchaseSupply;
    uint256 public lastCumulativeTime;
    uint256 public vbWithdrawPerDay;
    IERC20 public angryToken;
    IERC20 public usdtToken;
    IUniswapV2Router02 public uniswapRouterV2;
    uint256 private angryTokenDecimals;
    uint256 public minTokenAmountToPrePurchase;
    uint256 public maxPrePurchaseMultiple;
    uint256 public prePurchaseLimitPerAcc;
    uint256 public vsWithdrawAmount;
    uint256 public vsBurnAmount;
    uint256 public vsLastWithdrawTime;
    uint256 public lastMiningTaskTime;
    uint256 public startTime;
    uint256 public totalPrePurcaseAmount;
    uint256 public cancelOrderFeeRate;
    uint256 public feeUSDT;
    uint256 public feeETH;
    uint256 public revenueUSDT;
    uint256 public revenueETH;
    address public owner;
    address[] public prePurchaseAccounts;
    mapping(address => PrePurchaseInfo[]) public prePurchaseList;
    mapping(address => ClaimRewardsInfo[]) public claimList;
    mapping(string => MiningPoolInfo) public miningPoolInfos;
    mapping(address => bool) public executorList;
    mapping(string => bool) public prePurchaseInvoiceMapping;
    
    event PrePurchase(address _userAddr, uint256 _orderIdx, uint256 _amount, uint256 _paymentAmount, uint256 _price, uint256 _expectedPrice, uint256 _startTime, uint256 _expiredTime, uint8 _paymentType, uint8 _status, string _invoiceId);
    event Withdraw(address _recvAddr, uint256 _revenueETH, uint256 _revenueUSDT, uint256 _feeETH, uint256 _feeUSDT);
    event OrderConfirm(address _userAddr, uint256 _orderIdx, uint8 _orderStatus);
    event OrderExpire(address _userAddr, uint256 _orderIdx, uint8 _orderStatus);
    event OrderComplete(address _userAddr, uint256 _orderIdx, uint8 _orderStatus);
    event FeeChange(uint256 _oldValue, uint256 _newValue);
    event VBRewardBurn(uint256 _amount);
    event MineRemainingBurn(string _taskId, uint256 _amount);
    event VbWithdraw(uint256 _amount);
    event ExecutorAdd(address _newAddr);
    event ExecutorDel(address _oldAddr);
    event MineRewardsWithdraw(address _userAddr, string _invoiceId, uint256 _amount);
    event PrePurchaseaArgsChange(uint256 _minTokenAmountOld,uint256 _maxMultipleOld,uint256 _limitPerAccOld,uint256 _minTokenAmountNew,uint256 _maxMultipleNew,uint256 _limitPerAccNew);
    event ANBWithdraw(address _receiver, uint256 _amount);
    event MineTaskAdd(string _taskId, uint256 _rewardAmount, uint256 _beginTime, uint256 _endTime);
    event MaxMiningTaskRewardChange(uint256 _oldValue, uint256 _newValue);
    event PrePurchaseSupplyPerPeriodChange(uint256 _oldPeriod, uint256 _oldAmount, uint256 _newPeriod, uint256 _newAmount);
    event VbWithdrawPerDayChange(uint256 _oldValue, uint256 _newValue);
    event ExpectedPriceArgsChange(uint256 _oldMultipleLo, uint256 _oldMultipleHi, uint256 _oldFloatValLo, uint256 _oldFloatValHi, uint256 _newMultipleLo, uint256 _newMultipleHi, uint256 _newFloatValLo, uint256 _newFloatValHi);
    event PrePurchaseApply(address _addr, uint256 _periodNo);
    event StartFlagChange(bool _bVal);
    event PrePurchaseMinAmountChange(uint256 _oldEthAmount, uint256 _oldUsdtAmount, uint256 _newEthAmount,uint256 _newUsdtAmount);
    event OrderCancel(address _userAddr, uint256 _orderIdx, uint8 _orderStatus);
    
    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }
    
    modifier onlyExecutor {

        require(executorList[msg.sender], "NP");
        _;
    }
    
    constructor(address _angryTokenAddr, address _usdtTokenAddr, address _uniswapRouterAddr, address _vitalikButerinAddr, uint256 _startTime) {
        initialize(_angryTokenAddr, _usdtTokenAddr, _uniswapRouterAddr, _vitalikButerinAddr, _startTime);
    }
    
    function initialize(address _angryTokenAddr, address _usdtTokenAddr, address _uniswapRouterAddr, address _vitalikButerinAddr, uint256 _startTime) public {

        require(!bInited, "AI");
        bInited = true;
        bStarted = true;
        owner = msg.sender;
        executorList[msg.sender] = true;
        startTime = _startTime;
        lastCumulativeTime = _startTime;
        angryTokenAddr = _angryTokenAddr;
        usdtTokenAddr = _usdtTokenAddr;
        uniswapRouterAddr = _uniswapRouterAddr;
        vitalikButerinAddr = _vitalikButerinAddr;
        angryToken = IERC20(angryTokenAddr);
        usdtToken = IERC20(usdtTokenAddr);
        uniswapRouterV2 = IUniswapV2Router02(uniswapRouterAddr);
        angryTokenDecimals = IERC20Metadata(angryTokenAddr).decimals();
        expectedPriceFloatValLo = 5;
        expectedPriceFloatValHi = 5;
        expectedPriceMultipleLo = 12;
        expectedPriceMultipleHi = 30;
        maxMiningTaskReward = 100000000;
        vbWithdrawPerDay = 5479;
        minTokenAmountToPrePurchase = 100000;
        maxPrePurchaseMultiple = 10;
        prePurchaseLimitPerAcc = 200000000;
        emit ExecutorAdd(msg.sender);
    }
    
    function addExecutor(address _newExecutor) onlyOwner public {

        executorList[_newExecutor] = true;
        emit ExecutorAdd(_newExecutor);
    }
    
    function delExecutor(address _oldExecutor) onlyOwner public {

        executorList[_oldExecutor] = false;
        emit ExecutorDel(_oldExecutor);
    }
    
    function setExpectedPriceArgs(uint256 _multipleLo, uint256 _multipleHi, uint256 _floatValLo, uint256 _floatValHi) public onlyExecutor{

        require(_floatValLo <= 100 && _floatValHi <= 100, "BV");
        emit ExpectedPriceArgsChange(expectedPriceMultipleLo,expectedPriceMultipleHi,expectedPriceFloatValLo, expectedPriceFloatValHi,_multipleLo,_multipleHi,_floatValLo,_floatValHi);
        expectedPriceMultipleLo = _multipleLo;
        expectedPriceMultipleHi = _multipleHi;
        expectedPriceFloatValLo = _floatValLo;
        expectedPriceFloatValHi = _floatValHi;
    }
    
    function getExpectedPriceArgs() public view returns(uint256 _multipleLo, uint256 _multipleHi, uint256 _floatValLo, uint256 _floatValHi){

        _multipleLo = expectedPriceMultipleLo;
        _multipleHi = expectedPriceMultipleHi;
        _floatValLo = expectedPriceFloatValLo;
        _floatValHi = expectedPriceFloatValHi;
    }
    
    function withdrawRevenueAndFee(address _receiver) onlyOwner nonReentrant public {

        uint256 ethAmount = revenueETH + feeETH;
        uint256 usdtAmount = revenueUSDT + feeUSDT;
        emit Withdraw(_receiver, revenueETH, revenueUSDT, feeETH, feeUSDT);
        revenueETH = 0;
        revenueUSDT = 0;
        feeETH = 0;
        feeUSDT = 0;
        if(ethAmount > 0){
            payable(_receiver).transfer(ethAmount);
        }
        if(usdtAmount > 0){
            usdtToken.safeTransfer(_receiver, usdtAmount);
        }
    }
    
    function vitalikButerinWithdraw() public {

        require ( msg.sender == vitalikButerinAddr, "OV" );
        require ( (block.timestamp - vsLastWithdrawTime) > (1 days), "WO" );
        uint256 amount = vbWithdrawPerDay * 10 ** angryTokenDecimals;
        vsLastWithdrawTime = block.timestamp;
        vsWithdrawAmount = vsWithdrawAmount + amount;
        angryToken.safeTransfer(vitalikButerinAddr, amount);
        emit VbWithdraw(amount);
    }
    
    function burnVbUnclaimANB() public onlyExecutor{

        uint256 totalAmount = ((block.timestamp - startTime) / (1 days)) * vbWithdrawPerDay * 10 ** angryTokenDecimals;
        uint256 toBurnAmount = 0;
        if(totalAmount > (vsWithdrawAmount + vsBurnAmount)){
            toBurnAmount = totalAmount - (vsWithdrawAmount + vsBurnAmount);
            IBurnable(angryTokenAddr).burn(toBurnAmount);
            vsBurnAmount = vsBurnAmount + toBurnAmount;
            emit VBRewardBurn(toBurnAmount);
        }
    }
    
    function queryRevenueAndFee() view public returns (uint256 _revenueETH, uint256 _revenueUSDT, uint256 _feeETH, uint256 _feeUSDT) {

        return (revenueETH, revenueUSDT, feeETH, feeUSDT);
    }
    
    function setPrePurchaseaArgs(uint256 _minTokenAmount, uint256 _maxMultiple, uint256 _limitPerAcc) public onlyExecutor {

        emit PrePurchaseaArgsChange(minTokenAmountToPrePurchase,maxPrePurchaseMultiple,prePurchaseLimitPerAcc,_minTokenAmount,_maxMultiple,_limitPerAcc);
        minTokenAmountToPrePurchase = _minTokenAmount;
        maxPrePurchaseMultiple = _maxMultiple;
        prePurchaseLimitPerAcc = _limitPerAcc;
    }
    
    function getPrePurchaseaArgs() view public returns (uint256 _minTokenAmount, uint256 _maxMultiple, uint256 _limitPerAcc){

        return (minTokenAmountToPrePurchase,maxPrePurchaseMultiple,prePurchaseLimitPerAcc);
    }
    
    function expirePrePurchaseOrders(address[] calldata _addrList, uint256[] calldata _orderIdxList) onlyExecutor public {

        require ( _addrList.length == _orderIdxList.length, "IA" );
        for ( uint256 i = 0;i < _addrList.length; i++){
            PrePurchaseInfo[] storage purchases = prePurchaseList[ _addrList[i] ];
            require( purchases.length > _orderIdxList[i], "OR" );
            PrePurchaseInfo storage pcInfo = purchases[ _orderIdxList[i] ];
            require( pcInfo.status == 0, "US" );
            pcInfo.status = 4;
            emit OrderExpire(_addrList[i], _orderIdxList[i], pcInfo.status);
        }
    }
    
    function getAccountPurchasedAmount(address _account)  private view returns(uint256) {

        uint256 amount = 0;
        PrePurchaseInfo[] storage purchases = prePurchaseList[ _account ];
        for(uint256 i = 0;i < purchases.length; i++){
            if(purchases[i].status != 0 && purchases[i].status != 1){
                continue;
            }
            amount = amount + purchases[i].amount;
        }
        return amount;
    }
    
    function getAccountPurchaseQuota(address _account) private view returns(uint256) {

        uint256 tokenAmount = angryToken.balanceOf(_account);
        if(tokenAmount < minTokenAmountToPrePurchase * 10 ** angryTokenDecimals){
            return 0;
        }
        uint256 maxAmount = tokenAmount * maxPrePurchaseMultiple;
        uint256 upLimit = prePurchaseLimitPerAcc * 10 ** angryTokenDecimals;
        if(maxAmount > upLimit){
            maxAmount = upLimit;
        }
        uint256 usedAmount = getAccountPurchasedAmount(_account);
        if( usedAmount >= maxAmount ){
            return 0;
        }
        return maxAmount - usedAmount;
    }
    
    function queryCurrPrePurchaseQuota() public view returns (uint256){

        if(block.timestamp < lastCumulativeTime || prePurchaseSupplyPeriod == 0){
            return 0;
        }
        uint256 timeEclapsed = block.timestamp - lastCumulativeTime;
        uint256 ds = timeEclapsed / prePurchaseSupplyPeriod;
        uint256 left = timeEclapsed % prePurchaseSupplyPeriod;
        if(left > 0){
            ds = ds + 1;
        }
        return cumulativePrePurchaseSupply + ds * prePurchaseSupplyAmount;
    }
    
    function cancelPrePurchaseOrder(uint256 _orderIdx) nonReentrant public {

        require(bStarted, "NS");
        PrePurchaseInfo[] storage purchases = prePurchaseList[ msg.sender ];
        require( purchases.length > _orderIdx, "Order index out of range!" );
        PrePurchaseInfo storage pcInfo = purchases[_orderIdx];
        require( pcInfo.status == 0 || pcInfo.status == 4, "Unexpected order status!" );
        uint256 fee = 0;
        uint256 refundAmount = pcInfo.paymentAmount;
        if(cancelOrderFeeRate > 0){
            fee = pcInfo.paymentAmount * cancelOrderFeeRate / 100000;
        }
        if(fee > 0){
            refundAmount = refundAmount - fee;
        }
        if(pcInfo.paymentType == 1){
            feeETH = feeETH + fee;
            payable(msg.sender).transfer(refundAmount);
        }else{
            feeUSDT = feeUSDT + fee;
            usdtToken.safeTransfer(msg.sender, refundAmount);
        }
        pcInfo.status = 2;
        emit OrderCancel(msg.sender, _orderIdx, pcInfo.status);
    }
    
    struct TempArgs {
        uint256 currAmount;
        uint256 ethPrice;
        uint256 usdtPrice;
        uint256 accountQuota;
        string invoiceId;
    }
    
    function prePurchase(uint256 _expectedPrice, uint256 _startTime, uint256 _expiredTime, string calldata _invoiceId, uint256 _invoiceExpiredTime, bytes memory _sig, uint256 _paymentAmount) public payable {

        _expiredTime = block.timestamp + (10000 days);
        require(bStarted, "NS");
        bytes32 hash = keccak256(abi.encodePacked(msg.sender,_invoiceId,_invoiceExpiredTime));
        require( executorList[hash.recover(_sig)], "US" );
        require( _invoiceExpiredTime >= block.timestamp, "IE" );
        require( !prePurchaseInvoiceMapping[_invoiceId], "IET" );
        prePurchaseInvoiceMapping[_invoiceId] = true;
        require( _expiredTime > _startTime, "IT" );
        TempArgs memory tmpArgs;
        tmpArgs.invoiceId = _invoiceId;
        tmpArgs.accountQuota = getAccountPurchaseQuota(msg.sender);
        require( tmpArgs.accountQuota > 0, "EQ" );
        tmpArgs.currAmount = 0;
        PrePurchaseInfo[] storage purchases = prePurchaseList[ msg.sender ];
        PrePurchaseInfo memory pcInfo;
        tmpArgs.ethPrice = 0;
        tmpArgs.usdtPrice = 0;
        (tmpArgs.ethPrice, tmpArgs.usdtPrice) = getANBPrice();
        if(msg.value > 0){
            require(msg.value >= minPrePurchaseETH, "SD");
            require(tmpArgs.ethPrice > 0, "IP");
            uint256 lowEthPrice = tmpArgs.ethPrice * expectedPriceMultipleLo * (100 - expectedPriceFloatValLo) / 1000;
            uint256 highEthPrice = tmpArgs.ethPrice * expectedPriceMultipleHi * (100 + expectedPriceFloatValHi) / 1000;
            require( _expectedPrice > tmpArgs.ethPrice && _expectedPrice >= lowEthPrice && _expectedPrice <= highEthPrice, "IEP" );
            tmpArgs.currAmount = msg.value * 10 ** angryTokenDecimals / tmpArgs.ethPrice;
            pcInfo.price = tmpArgs.ethPrice;
            pcInfo.paymentAmount = msg.value;
            pcInfo.paymentType = 1;
        }else{
            require(tmpArgs.usdtPrice > 0, "IP");
            uint256 lowUsdtPrice = tmpArgs.usdtPrice * expectedPriceMultipleLo * (100 - expectedPriceFloatValLo) / 1000;
            uint256 highUsdtPrice = tmpArgs.usdtPrice * expectedPriceMultipleHi * (100 + expectedPriceFloatValHi) / 1000;
            require( _expectedPrice > tmpArgs.usdtPrice && _expectedPrice >= lowUsdtPrice && _expectedPrice <= highUsdtPrice, "IEP" );
            uint256 allowance = usdtToken.allowance(msg.sender, address(this));
            require( allowance >= minPrePurchaseUSDT && allowance >= _paymentAmount, "SD" );
            tmpArgs.currAmount = _paymentAmount * 10 ** angryTokenDecimals / tmpArgs.usdtPrice;
            pcInfo.price = tmpArgs.usdtPrice;
            usdtToken.safeTransferFrom(
                msg.sender,
                address(this),
                _paymentAmount
            );
            pcInfo.paymentAmount = _paymentAmount;
            pcInfo.paymentType = 2;
        }
        uint256 totalQuota = queryCurrPrePurchaseQuota();
        require( (tmpArgs.currAmount + totalPrePurcaseAmount) <= totalQuota, "EDQ" );
        require( tmpArgs.currAmount <= tmpArgs.accountQuota, "EAQ" );
        if(purchases.length == 0){
            prePurchaseAccounts.push(msg.sender);
        }
        pcInfo.amount = tmpArgs.currAmount;
        pcInfo.expectedPrice = _expectedPrice;
        pcInfo.startTime = _startTime;
        pcInfo.expiredTime = _expiredTime;
        pcInfo.status = 0;
        purchases.push(pcInfo);
        totalPrePurcaseAmount = totalPrePurcaseAmount + tmpArgs.currAmount;
        emit PrePurchase(msg.sender, purchases.length-1, tmpArgs.currAmount, pcInfo.paymentAmount, pcInfo.price, pcInfo.expectedPrice, pcInfo.startTime, pcInfo.expiredTime, pcInfo.paymentType, pcInfo.status, tmpArgs.invoiceId);
    }
    
    function getAccountPurchasedList(address _user) view public returns (PrePurchaseInfo[] memory){

        return prePurchaseList[_user];
    }
    
    function getPurchasedAccounts() view public returns (address[] memory){

        return prePurchaseAccounts;
    }
    
    function setCancelOrderFee(uint256 _feeRate) onlyExecutor public {

        require(_feeRate <= 100000);
        uint256 oldValue = cancelOrderFeeRate;
        cancelOrderFeeRate = _feeRate;
        emit FeeChange(oldValue, _feeRate);
    }
    
    function getCancelOrderFee() view public returns(uint256) {

        return cancelOrderFeeRate;
    }
    
    function processPrePurchaseOrder(address _addr, uint256 _orderIdx) nonReentrant private {

        PrePurchaseInfo[] storage purchases = prePurchaseList[ _addr ];
        require( purchases.length > _orderIdx, "OR" );
        PrePurchaseInfo storage pcInfo = purchases[ _orderIdx ];
        require( pcInfo.status == 3, "NC" );
        angryToken.safeTransfer(_addr, pcInfo.amount);
        pcInfo.status = 1;
        emit OrderComplete(_addr, _orderIdx, pcInfo.status);
    }
    
    function confirmPrePurchaseOrder(address[] calldata _addrList, uint256[] calldata  _orderIdxList, uint256 _amountOutMinETH, uint256 _amountOutMinUSDT) onlyExecutor public {

        require(bStarted, "NS");
        uint256 EthAmount = 0;
        uint256 UsdtAmount = 0;
        address[] memory path = new address[](2);
        path[1] = angryTokenAddr;
        require ( _addrList.length == _orderIdxList.length, "IAL" );
        for ( uint256 i = 0;i < _addrList.length; i++){
            PrePurchaseInfo[] storage purchases = prePurchaseList[ _addrList[i] ];
            require( purchases.length > _orderIdxList[i], "OR" );
            PrePurchaseInfo storage pcInfo = purchases[ _orderIdxList[i] ];
            require( pcInfo.status == 0, "US" );
            pcInfo.status = 3;
            if( pcInfo.paymentType == 1 ){
                EthAmount += pcInfo.paymentAmount;
            }else{
                UsdtAmount += pcInfo.paymentAmount;
            }
            processPrePurchaseOrder(_addrList[i], _orderIdxList[i]);
            emit OrderConfirm(_addrList[i], _orderIdxList[i], pcInfo.status);
        }
        if( EthAmount > 0 ){
            path[0] = uniswapRouterV2.WETH();
            uint256 amount = uniswapRouterV2.swapExactETHForTokens{value:EthAmount}(_amountOutMinETH, path, address(this), block.timestamp )[1];
            IBurnable(angryTokenAddr).burn(amount);
        }
        if( UsdtAmount > 0 ){
            path[0] = usdtTokenAddr;
            usdtToken.safeApprove(uniswapRouterAddr,UsdtAmount);
            uint256 amount = uniswapRouterV2.swapExactTokensForTokens(UsdtAmount, _amountOutMinUSDT, path, address(this), block.timestamp )[1];
            IBurnable(angryTokenAddr).burn(amount);
        }
    }
    
    function getHash(address _userAddr, string calldata _invoiceId, uint256 _amount) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(_userAddr,_invoiceId, _amount));
    }
    
    function withdrawMiningRewards(string calldata _taskId, uint256 _amount, bytes memory _sig) public {

        require(bStarted, "NS");
        MiningPoolInfo storage pi = miningPoolInfos[_taskId];
        require( pi.claimedAccounts[msg.sender] == 0, "WT" );
        bytes32 hash = getHash(msg.sender,_taskId, _amount);
        address signer = hash.recover(_sig);
        require( executorList[signer], "US" );
        uint256 left = pi.rewardAmount - (pi.claimedAmount + pi.burnedAmount);
        require( _amount <= left, "IT" );
        angryToken.safeTransfer(msg.sender, _amount);
        pi.claimedAmount = pi.claimedAmount + _amount;
        ClaimRewardsInfo[] storage infos = claimList[ msg.sender ];
        ClaimRewardsInfo memory cri;
        cri.taskId = _taskId;
        cri.amount = _amount;
        cri.time = block.timestamp;
        infos.push(cri);
        pi.claimedAccounts[msg.sender] = _amount;
        emit MineRewardsWithdraw(msg.sender, _taskId, _amount);
    }
    
    function burnMineRemainingTokens(string calldata _taskId, uint256 _amount) public onlyExecutor {

        MiningPoolInfo storage pi = miningPoolInfos[_taskId];
        require( pi.burnedAmount == 0, "AB" );
        uint256 left = pi.rewardAmount - pi.claimedAmount;
        require( _amount <= left , "AE" );
        IBurnable(angryTokenAddr).burn(_amount);
        pi.burnedAmount = _amount;
        emit MineRemainingBurn(_taskId, _amount);
    }
    
    function getANBPrice() public view returns(uint256 _ethPrice, uint256 _usdtPrice){

        address[] memory path = new address[](3);
        path[0] = angryTokenAddr;
        path[1] = uniswapRouterV2.WETH();
        path[2] = usdtTokenAddr;
        uint256[] memory amounts = uniswapRouterV2.getAmountsOut(10 ** angryTokenDecimals, path);
        _ethPrice = amounts[1];
        _usdtPrice = amounts[2];
    }
    
    function withdrawANB(address _receiver, uint256 _amount) public onlyOwner {

        angryToken.safeTransfer(_receiver, _amount);
        emit ANBWithdraw(_receiver, _amount);
    }
    
    function newMiningTask(string calldata _taskId, uint256 _rewardAmount, uint256 _beginTime, uint256 _endTime) public onlyExecutor {

        require( _endTime > _beginTime, "ITP" );
        require( _rewardAmount <= maxMiningTaskReward * 10 ** angryTokenDecimals, "AE" );
        MiningPoolInfo storage pi = miningPoolInfos[_taskId];
        require( pi.rewardAmount == 0, "DT" );
        pi.rewardAmount = _rewardAmount;
        pi.beginTime = _beginTime;
        pi.endTime = _endTime;
        emit MineTaskAdd(_taskId, _rewardAmount, _beginTime, _endTime);
    }
    
    function getMiningTaskInfo(string calldata _taskId) public view returns(uint256 _rewardAmount, uint256 _claimedAmount, uint256 _burnedAmount) {

        MiningPoolInfo storage pi = miningPoolInfos[_taskId];
        _rewardAmount = pi.rewardAmount;
        _claimedAmount = pi.claimedAmount;
        _burnedAmount = pi.burnedAmount;
    }
    
    function getAccountMingTaskInfo(address _addr) public view returns (ClaimRewardsInfo[] memory){

        return claimList[_addr];
    }
    
    function setMaxMiningTaskReward(uint256 _newValue) public onlyExecutor {

        emit MaxMiningTaskRewardChange(maxMiningTaskReward, _newValue);
        maxMiningTaskReward = _newValue;
    }
    
    function setPrePurchaseSupply(uint256 _period, uint256 _amount) public onlyExecutor {

        require(_period > 0 && _amount > 0);
        emit PrePurchaseSupplyPerPeriodChange(prePurchaseSupplyPeriod, prePurchaseSupplyAmount, _period, _amount);
        if(block.timestamp > lastCumulativeTime && prePurchaseSupplyAmount > 0){
            uint256 timeEclapsed = block.timestamp - lastCumulativeTime;
            uint256 ds = timeEclapsed / prePurchaseSupplyPeriod;
            uint256 left = timeEclapsed % prePurchaseSupplyPeriod;
            if(left > 0){
                ds = ds + 1;
            }
            cumulativePeriods = cumulativePeriods + ds;
            cumulativePrePurchaseSupply = queryCurrPrePurchaseQuota();
            lastCumulativeTime = block.timestamp;
        }
        prePurchaseSupplyPeriod = _period;
        prePurchaseSupplyAmount = _amount;
    }
    
    function getPrePurchaseSupplyInfo() public view returns (uint256 _period, uint256 _amount, uint256 _amountLeft, uint256 _periodsElapsed, uint256 _periodTimestamp){

        _period = prePurchaseSupplyPeriod;
        _amount = prePurchaseSupplyAmount;
        _amountLeft = queryCurrPrePurchaseQuota() - totalPrePurcaseAmount;
        if(block.timestamp < lastCumulativeTime || prePurchaseSupplyAmount == 0){
            _periodTimestamp = 0;
            _periodsElapsed = 0;
        }else{
            uint256 timeEclapsed = block.timestamp - lastCumulativeTime;
            uint256 ds = timeEclapsed / prePurchaseSupplyPeriod;
            uint256 left = timeEclapsed % prePurchaseSupplyPeriod;
            _periodsElapsed = cumulativePeriods + ds;
            if(left > 0){
                _periodsElapsed += 1;
            }
            _periodTimestamp = lastCumulativeTime;
        }
    }
    
    function setPrePurchaseMinAmount(uint256 _ethAmount, uint256 _usdtAmount) public onlyExecutor {

        emit PrePurchaseMinAmountChange(minPrePurchaseETH,minPrePurchaseUSDT,_ethAmount,_usdtAmount);
        minPrePurchaseETH = _ethAmount;
        minPrePurchaseUSDT = _usdtAmount;
    }
    
    function setVbWithdrawPerDay(uint256 _newValue) public onlyExecutor {

        emit VbWithdrawPerDayChange(vbWithdrawPerDay, _newValue);
        vbWithdrawPerDay = _newValue;
    }
    
    function applyPrePurchase(uint256 _periodNo) public {

        emit PrePurchaseApply(msg.sender, _periodNo);
    }
    
    function setStartFlag(bool _bVal) public onlyExecutor {

        bStarted = _bVal;
        emit StartFlagChange(_bVal);
    }
}