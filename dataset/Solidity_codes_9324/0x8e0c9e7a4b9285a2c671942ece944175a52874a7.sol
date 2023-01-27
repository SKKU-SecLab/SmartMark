
pragma solidity 0.8.7;

interface IUniswapV2Router02 {

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);


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

}//MIT

pragma solidity 0.8.7;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity 0.8.7;

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

pragma solidity 0.8.7;

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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity 0.8.7;


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
}// MIT

pragma solidity 0.8.7;

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

pragma solidity 0.8.7;


contract Multiswap is ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private pendingOwner;

    address private immutable WETH;

    IUniswapV2Router02 private immutable uniswapRouter;

    mapping (address => bool) private referrers;
    mapping (address => uint256) private referralFees;

    struct ContractData {
        uint160 owner;
        uint16 swapFeeBase;
        uint16 swapFeeToken;
        uint16 referralFee;
        uint16 maxFee;
    }
    
    ContractData private data;

    modifier onlyOwner {

        require(msg.sender == address(data.owner), "Not allowed");
        _;
    }

    constructor(address _router, address _weth) {
        uniswapRouter = IUniswapV2Router02(_router);
        WETH = _weth;
        
        data.owner = uint160(msg.sender);
        data.swapFeeBase = uint16(30); // 0.3%
        data.swapFeeToken = uint16(20); // 0.2% per token
        data.referralFee = uint16(4500); // 45% for referrals
        data.maxFee = uint16(150); // 1.5% max fee

        referrers[address(this)] = true;
        referrers[address(0x1190074795DAD0E61b61270De48e108427f8f817)] = true;
    }
    
    receive() external payable {}
    fallback() external payable {}

    function checkOutputsETH(
        address[] memory _tokens,
        uint256[] memory _percent,
        uint256[] memory _slippage,
        uint256 _total
    ) external view returns (address[] memory, uint256[] memory, uint256)
    {

        require(_tokens.length == _percent.length && _percent.length == _slippage.length, 'Multiswap: mismatch input data');

        uint256 _totalPercent;
        (uint256 valueToSend, uint256 feeAmount) = applyFeeETH(_total, _tokens.length);

        uint256[] memory _outputAmount = new uint256[](_tokens.length);

        for (uint256 i = 0; i < _tokens.length; i++) {
            _totalPercent += _percent[i];
            (_outputAmount[i],) = calcOutputEth(
                _tokens[i],
                valueToSend.mul(_percent[i]).div(100),
                _slippage[i]
            );
        }

        require(_totalPercent == 100, 'Multiswap: portfolio not 100%');

        return (_tokens, _outputAmount, feeAmount);
    }

    function checkOutputsToken(
        address[] memory _tokens,
        uint256[] memory _percent,
        uint256[] memory _slippage,
        address _base,
        uint256 _total
        ) external view returns (address[] memory, uint256[] memory)
    {

        require(_tokens.length == _percent.length && _percent.length == _slippage.length, 'Multiswap: mismatch input data');
        
        uint256 _totalPercent;
        uint256[] memory _outputAmount = new uint256[](_tokens.length);
        address[] memory path = new address[](3);
        path[0] = _base;
        path[1] = WETH;
        
        for (uint256 i = 0; i < _tokens.length; i++) {
            _totalPercent += _percent[i];
            path[2] = _tokens[i];
            uint256[] memory expected = uniswapRouter.getAmountsOut(_total.mul(_percent[i]).div(100), path);
            uint256 adjusted = expected[2].sub(expected[2].mul(_slippage[i]).div(1000));
            _outputAmount[i] = adjusted;
        }
        
        require(_totalPercent == 100, 'Multiswap: portolio not 100%');
        
        return (_tokens, _outputAmount);
    }
    
    function checkTokenValueETH(address _token, uint256 _amount, uint256 _slippage)
        public
        view
        returns (uint256)
    {

        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = WETH;
        uint256[] memory expected = uniswapRouter.getAmountsOut(_amount, path);
        uint256 adjusted = expected[1].sub(expected[1].mul(_slippage).div(1000));
        return adjusted;
    }
    
    function checkAllValue(address[] memory _tokens, uint256[] memory _amounts, uint256[] memory _slippage)
        external
        view
        returns (uint256)
    {

        uint256 totalValue;
        
        for (uint i = 0; i < _tokens.length; i++) {
            totalValue += checkTokenValueETH(_tokens[i], _amounts[i], _slippage[i]);
        }
        
        return totalValue;
    }
    
    function calcOutputEth(address _token, uint256 _value, uint256 _slippage)
        internal
        view
        returns (uint256, address[] memory)
    {

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = _token;
        
        uint256[] memory expected = uniswapRouter.getAmountsOut(_value, path);
        uint256 adjusted = expected[1].sub(expected[1].mul(_slippage).div(1000));
        
        return (adjusted, path);
    }

    function calcOutputToken(address[] memory _path, uint256 _value)
        internal
        view
        returns (uint256[] memory expected)
    {

        
        expected = uniswapRouter.getAmountsOut(_value, _path);
        return expected;
    }

    function makeETHSwap(address[] memory _tokens, uint256[] memory _percent, uint256[] memory _expected, address _referrer)
        external
        payable
        nonReentrant
    {

        require(address(0) != _referrer, 'Multiswap: referrer cannot be zero addresss');
        require(_tokens.length == _percent.length && _percent.length == _expected.length, 'Multiswap: Input data mismatch');
        (uint256 valueToSend, uint256 feeAmount) = applyFeeETH(msg.value, _tokens.length);
        uint256 totalPercent;
        address[] memory path = new address[](2);
        path[0] = WETH;

        for (uint256 i = 0; i < _tokens.length; i++) {
            totalPercent += _percent[i];
            require(totalPercent <= 100, 'Multiswap: Exceeded 100%');

            path[1] = _tokens[i];

            uint256 swapVal = valueToSend.mul(_percent[i]).div(100);
            uniswapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: swapVal}(
                _expected[i],
                path,
                msg.sender,
                block.timestamp + 1200
            );
        }

        require(totalPercent == 100, 'Multiswap: Percent not 100');
        
        if (_referrer != address(this)) {
            uint256 referralFee = takeReferralFee(feeAmount, _referrer);
            (bool sent, ) = _referrer.call{value: referralFee}("");
            require(sent, 'Multiswap: Failed to send referral fee');
        }
        
    }

    function makeTokenSwap(
        address[] memory _tokens,
        uint256[] memory _percent,
        uint256[] memory _expected,
        address _referrer,
        address _base,
        uint256 _total)
        external
        nonReentrant
    {

        require(address(0) != _referrer, 'Multiswap: referrer cannot be zero addresss');
        require(_tokens.length == _percent.length && _percent.length == _expected.length, 'Multiswap: Input data mismatch');

        uint256 totalToSend = receiveToken(_total, _base, true);

        uint256 totalPercent = 0;
        address[] memory path = new address[](3);

        path[0] = _base;
        path[1] = WETH;
        
        for (uint256 i = 0; i < _tokens.length; i++) {
            totalPercent += _percent[i];

            require(totalPercent <= 100, 'Multiswap: Exceeded 100');
            
            path[2] = _tokens[i];            
            uint256 swapVal = totalToSend.mul(_percent[i]).div(100);

            uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                swapVal,
                _expected[i],
                path,
                msg.sender,
                block.timestamp + 1200
            );
        }

        require(totalPercent == 100, 'Multiswap: Percent not 100');
    }


    function receiveToken(uint256 _amount, address _token, bool _toSend) internal returns (uint256 amountReceived) {

        IERC20 token = IERC20(_token);
        uint256 preBalanceToken = token.balanceOf(address(this));

        token.safeTransferFrom(msg.sender, address(this), _amount);

        if (_amount > token.balanceOf(address(this)).sub(preBalanceToken)) {
            amountReceived = token.balanceOf(address(this)).sub(preBalanceToken);
        } else {
            amountReceived = _amount;
        }

        if (_toSend) require(token.approve(address(uniswapRouter), amountReceived), 'Multiswap: Uniswap approval failed');

        return amountReceived;
    }
    
    function makeTokenSwapForETH(
        address[] memory _tokens,
        uint256[] memory _amounts,
        uint256[] memory _expected,
        address _referrer
    ) external nonReentrant
    {

        require(address(0) != _referrer, 'Multiswap: referrer cannot be zero addresss');
        require(_tokens.length == _amounts.length && _expected.length == _expected.length, 'Multiswap: Input data mismatch');
        address[] memory path = new address[](2);
        path[1] = WETH;
        uint256 preBalance = address(this).balance;
        
        for (uint i = 0; i < _tokens.length; i++) {
            path[0] = _tokens[i];
            uint256 totalToSend = receiveToken(_amounts[i], _tokens[i], true);
            uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(totalToSend, _expected[i], path, address(this), block.timestamp + 1200);
        }

        (uint256 valueToSend, uint256 feeAmount) = applyFeeETH(address(this).balance.sub(preBalance), _tokens.length);

        if (_referrer != address(this)) {
            uint256 referralFee = takeReferralFee(feeAmount, _referrer);
            (bool sent, ) = _referrer.call{value: referralFee}("");
            require(sent, 'Multiswap: Failed to send referral fee');
        }
        
       (bool delivered, ) = msg.sender.call{value: valueToSend}("");
       require(delivered, 'Multiswap: Failed to send swap output');
    }

    function applyFeeETH(uint256 _amount, uint256 _numberOfTokens)
        private
        view
        returns (uint256 valueToSend, uint256 feeAmount)
    {

        uint256 feePercent = _numberOfTokens.mul(data.swapFeeToken);
        feePercent -= data.swapFeeToken;
        feePercent += data.swapFeeBase;

        if (feePercent > data.maxFee) {
            feePercent = data.maxFee;
        }

        feeAmount = _amount.mul(feePercent).div(10000);
        valueToSend = _amount.sub(feeAmount);

        return (valueToSend, feeAmount);
    }

    function takeReferralFee(uint256 _fee, address _referrer) internal returns (uint256) {

        require(referrers[_referrer], 'Multiswap: Not signed up as referrer');
        uint256 referralFee = _fee.mul(data.referralFee).div(10000);
        referralFees[_referrer] = referralFees[_referrer].add(referralFee);
        
        return referralFee;
    }

    function updateFee(
        uint16 _newFeeBase,
        uint16 _newFeeToken,
        uint16 _newFeeReferral,
        uint16 _newMaxFee
    ) external onlyOwner returns (bool) {

        data.swapFeeBase = _newFeeBase;
        data.swapFeeToken = _newFeeToken;
        data.referralFee = _newFeeReferral;
        data.maxFee = _newMaxFee;
        
        return true;
    }

    function getCurrentFee()
        external
        view
        returns (
            uint16,
            uint16,
            uint16,
            uint16
        )
    {

        return (data.swapFeeBase, data.swapFeeToken, data.referralFee, data.maxFee);
    }

    function transferOwnership(address _newOwner) external onlyOwner returns (bool) {

        require(address(0) != _newOwner, "Multiswap: newOwner set to the zero address");
        pendingOwner = _newOwner;
        return true;
    }

    function claimOwnership() external {

        require(msg.sender == pendingOwner, 'Multiswap: not pending owner');
        data.owner = uint160(pendingOwner);
        pendingOwner = address(0);
    }

    function renounceOwnership() external onlyOwner {

        pendingOwner = address(0);
        data.owner = uint160(0);
    }

    function addReferrer(address _referrer) external onlyOwner returns (bool) {

        referrers[_referrer] = true;
        return true;
    }

    function removeReferrer(address _referrer) external onlyOwner returns (bool) {

        referrers[_referrer] = false;
        return true;
    }

    function getOwner() external view returns (address) {

        return address(data.owner);
    }
    
    function getReferralFees(address _referrer) external view returns (uint256) {

        return referralFees[_referrer];
    }

    function retrieveEthFees() external onlyOwner {

        (bool sent, ) = address(data.owner).call{value: address(this).balance}("");
        require(sent, 'Multiswap: Transfer failed');
    }

}