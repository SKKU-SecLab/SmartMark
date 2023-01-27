pragma solidity 0.8.4;

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
}//MIT
pragma solidity 0.8.4;


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

}//MIT
pragma solidity 0.8.4;

interface IERC20 {


    function totalSupply() external view returns (uint256);

    
    function symbol() external view returns(string memory);

    
    function name() external view returns(string memory);


    function balanceOf(address account) external view returns (uint256);

    
    function decimals() external view returns (uint8);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}//MIT
pragma solidity 0.8.4;


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

}//MIT
pragma solidity 0.8.4;


contract KEYS is IERC20 {

    
    using SafeMath for uint256;
    using Address for address;

    string constant _name = "Keys";
    string constant _symbol = "KEYS";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 10**9 * 10**_decimals;
    
    uint256 maxTransfer;
    bool maxTransferCheckEnabled;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    uint256 public fee = 3; // 3% transfer fee
    
    mapping ( address => bool ) public isFeeExempt;

    IUniswapV2Router02 _router; 
    
    address[] path;
    
    address[] sellPath;
    
    address _owner;
    
    address _developmentFund;
    
    bool swapEnabled;

    modifier onlyOwner() {

        require(msg.sender == _owner, 'Only Owner Function');
        _;
    }

    constructor () {
        
        _router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        
        path = new address[](2);
        path[0] = _router.WETH();
        path[1] = address(this);
        
        sellPath = new address[](2);
        sellPath[0] = address(this);
        sellPath[1] = _router.WETH();
        
        _developmentFund = 0xfCacEAa7b4cf845f2cfcE6a3dA680dF1BB05015c;
        
        swapEnabled = true;
        
        maxTransfer = _totalSupply.div(100);
        maxTransferCheckEnabled = true;

        isFeeExempt[msg.sender] = true;
        isFeeExempt[_developmentFund] = true;
        isFeeExempt[address(this)] = true;
        
        _balances[msg.sender] = _totalSupply;

        _owner = msg.sender;
        
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }

    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }

    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    
    function name() public pure override returns (string memory) {

        return _name;
    }

    function symbol() public pure override returns (string memory) {

        return _symbol;
    }

    function decimals() public pure override returns (uint8) {

        return _decimals;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
  
    function transfer(address recipient, uint256 amount) external override returns (bool) {

        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, 'Insufficient Allowance');
        return _transferFrom(sender, recipient, amount);
    }
    
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        require(recipient != address(0) && sender != address(0), "Transfer To Zero Address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        if (maxTransferCheckEnabled && msg.sender != _owner) {
            require(amount <= maxTransfer, 'Maximum Transfer Threshold Reached');
        }
        
        _balances[sender] = _balances[sender].sub(amount, 'Insufficient Balance');
        
        bool takeFee = !( isFeeExempt[sender] || isFeeExempt[recipient] );
        
        uint256 taxAmount = takeFee ? amount.mul(fee).div(10**2) : 0;
        
        uint256 receiveAmount = amount.sub(taxAmount);
        
        _balances[recipient] = _balances[recipient].add(receiveAmount);
        emit Transfer(sender, recipient, receiveAmount);
        
        if (taxAmount > 0) {
            _balances[_developmentFund] = _balances[_developmentFund].add(taxAmount);
            emit Transfer(sender, _developmentFund, taxAmount);
        }
        return true;
    }
    
    function burnTokens(uint256 numTokens) external {

        _burnTokens(numTokens * 10**_decimals);
    }
    
    function burnAllTokens() external {

        _burnTokens(_balances[msg.sender]);
    }
    
    function burnTokensIncludingDecimals(uint256 numTokens) external {

        _burnTokens(numTokens);
    }
    
    function purchaseTokenForAddress(address receiver) external payable {

        require(msg.value >= 10**4, 'Amount Too Few');
        _purchaseToken(receiver);
    }
    
    function sellTokensForETH(address receiver, uint256 numTokens) external {

        _sellTokensForETH(receiver, numTokens);
    }
    
    function sellTokensForETH(uint256 numTokens) external {

        _sellTokensForETH(msg.sender, numTokens);
    }
    
    function sellTokensForETHWholeTokenAmounts(uint256 numTokens) external {

        _sellTokensForETH(msg.sender, numTokens*10**_decimals);
    }
    

    
    function setUniswapRouterAddress(address router) external onlyOwner {

        _router = IUniswapV2Router02(router);
        emit SetUniswapRouterAddress(router);
    }
    
    function setSwapEnabled(bool enabled) external onlyOwner {

        swapEnabled = enabled;
        emit SetSwapEnabled(enabled);
    }
    
    function withdrawTokens(address token) external onlyOwner {

        uint256 bal = IERC20(token).balanceOf(address(this));
        require(bal > 0, 'Zero Balance');
        IERC20(token).transfer(msg.sender, bal);
    }
    
    function setMaxTransactionData(bool checkEnabled, uint256 transferThreshold) external onlyOwner {

        if (checkEnabled) {
            require(transferThreshold >= _totalSupply.div(1000), 'Threshold Too Few');   
        }
        maxTransferCheckEnabled = checkEnabled;
        maxTransfer = transferThreshold;
        emit MaxTransactionDataSet(checkEnabled, transferThreshold);
    }
    
    function updateDevelopmentFundingAddress(address newFund) external onlyOwner {

        _developmentFund = newFund;
        emit UpdatedDevelopmentFundingAddress(newFund);
    }
    
    function setFeeExemption(address wallet, bool exempt) external onlyOwner {

        require(wallet != address(0));
        isFeeExempt[wallet] = exempt;
        emit SetFeeExemption(wallet, exempt);
    }
    
    function setFee(uint256 newFee) external onlyOwner {

        require(newFee <= 10, 'Fee Too High');
        fee = newFee;
        emit SetFee(newFee);
    }
    
    function transferOwnership(address newOwner) external onlyOwner {

        _owner = newOwner;
        emit TransferOwnership(newOwner);
    }
    
    function renounceOwnership() external onlyOwner {

        _owner = address(0);
        emit TransferOwnership(address(0));
    }
    
    
    
    
    function _sellTokensForETH(address receiver, uint256 numberTokens) internal {


        require(_balances[msg.sender] >= numberTokens, 'Insufficient Balance');
        require(receiver != address(this) && receiver != address(0), 'Insufficient Destination');
        require(swapEnabled, 'Swapping Disabled');
        
        _balances[msg.sender] = _balances[msg.sender].sub(numberTokens, 'Insufficient Balance');
        
        uint256 tax = isFeeExempt[msg.sender] ? 0 : numberTokens.mul(fee).div(10**2);
        
        uint256 sendAmount = numberTokens.sub(tax);
        require(sendAmount > 0, 'Zero Tokens To Send');
        
        _balances[address(this)] = _balances[address(this)].add(sendAmount);
        emit Transfer(msg.sender, address(this), sendAmount);
        
        if (tax > 0) {
            _balances[_developmentFund] = _balances[_developmentFund].add(tax);
            emit Transfer(msg.sender, _developmentFund, tax);
        }
        
        _allowances[address(this)][address(_router)] = sendAmount;
        
        _router.swapExactTokensForETH(
            sendAmount,
            0,
            sellPath,
            receiver,
            block.timestamp + 30
        );
    
    }
    
    function _purchaseToken(address receiver) internal {

        _router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            receiver,
            block.timestamp + 30
        );
    }
    
    function _burnTokens(uint256 numTokens) internal {

        require(_balances[msg.sender] >= numTokens && numTokens > 0, 'Insufficient Balance');
        _balances[msg.sender] = _balances[msg.sender].sub(numTokens, 'Insufficient Balance');
        _totalSupply = _totalSupply.sub(numTokens, 'Insufficient Supply');
        emit Transfer(msg.sender, address(0), numTokens);
    }
    
    receive() external payable {
        _purchaseToken(msg.sender);
    }
    
    
    
    event UpdatedDevelopmentFundingAddress(address newFund);
    event TransferOwnership(address newOwner);
    event SetSwapEnabled(bool enabled);
    event SetFee(uint256 newFee);
    event SetUniswapRouterAddress(address router);
    event SetFeeExemption(address Contract, bool exempt);
    event MaxTransactionDataSet(bool checkEnabled, uint256 transferThreshold);
}