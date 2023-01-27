
pragma solidity 0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



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

}


interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}


contract MansionCashToken is Context, Ownable, IERC20 {


	using SafeMath for uint256;
    using Address for address;
    
    string private _name = "MansionCash";
    string private _symbol = "MSC";
    uint8 private _decimals = 9;
    
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _total = 100000000 * 10**6 * 10**9; // cap 100,000B 
    uint256 private maxTxAmount = 3450000 * 10**6 * 10**9;
    uint256 private numTokensSellToAddToLiquidity = 345000 * 10**6 * 10**9;
    uint256 private minHoldingThreshold = 50000 * 10**6 * 10**9; // 50B
    
    uint8 public mansionTax = 6;
    uint8 public burnableFundRate = 3;
    uint8 public operationalFundRate = 1;
    
    uint256 public mansionFund;
    uint256 public burnableFund;
    uint256 public operationalFund;
    
    uint256 private largePrizeTotal = 0;
    uint256 private mediumPrizeTotal = 0;
    uint256 private smallPrizeTotal = 0;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public transactionFee = false;

    IUniswapV2Router02 public immutable uniSwapV2Router;
    address public immutable uniswapV2Pair;

	struct Entity {
		address _key;
		bool _isValid;
		uint256 _createdAt;
	}
	mapping (address => uint256) private addressToIndex;
	mapping (uint256 => Entity) private indexToEntity;
	uint256 private lastIndexUsed = 0;
	uint256 private lastEntryAllowed = 0;
	
	uint32 public perBatchSize = 100;
	
	event GrandPrizeReceivedAddresses (
    	address addressReceived,
    	uint256 amount
    );

    event MediumPrizeReceivedAddresses (
    	address[] addressesReceived,
    	uint256 amount
    );
    
    event SmallPrizePayoutComplete (
    	uint256 amount
    );
    
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event TransactionFeeEnableUpdated(bool enabled );
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event OperationalFundWithdrawn(
        uint256 amount,
        address recepient,
        string reason
    );
    
    event StartMansion (
        uint256 largePrizeTotal,
        uint256 mediumPrizeTotal,
        uint256 lowPrizeTotal
    );

    constructor () {
	    _balance[_msgSender()] = _total;
	    addEntity(_msgSender());
	    
	    mansionFund = 0;
        burnableFund = 0;
        operationalFund = 0;
        inSwapAndLiquify = false;
	    
	    IUniswapV2Router02 _UniSwapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(_UniSwapV2Router.factory())
            .createPair(address(this), _UniSwapV2Router.WETH());
            
        uniSwapV2Router = _UniSwapV2Router;
        
        emit Transfer(address(0), _msgSender(), _total);
    }
    
    modifier lockTheSwap {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
    
    function totalSupply() public view override returns (uint256) {

        return _total;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balance[account];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    
    function burnToken(uint256 amount) public onlyOwner virtual {

        require(amount <= _balance[address(this)], "Cannot burn more than avilable balancec");
        require(amount <= burnableFund, "Cannot burn more than burn fund");

        _balance[address(this)] = _balance[address(this)].sub(amount);
        _total = _total.sub(amount);
        burnableFund = burnableFund.sub(amount);

        emit Transfer(address(this), address(0), amount);
    }
    
    function getCommunityMansionCashFund() public view returns (uint256) {

    	uint256 communityFund = burnableFund.add(mansionFund).add(operationalFund);
    	return communityFund;
    }
    
    function getminHoldingThreshold() public view returns (uint256) {

        return minHoldingThreshold;
    }
    
    function getMaxTxnAmount() public view returns (uint256) {

        return maxTxAmount;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {

    	swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setTransactionFee(bool _enabled) public onlyOwner {

    	transactionFee = _enabled;
        emit TransactionFeeEnableUpdated(_enabled);
    }
    
    function setminHoldingThreshold(uint256 amount) public onlyOwner {

        minHoldingThreshold = amount;
    }
    
    function setMaxTxnAmount(uint256 amount) public onlyOwner {

        maxTxAmount = amount;
    }
    
    function setBatchSize(uint32 newSize) public onlyOwner {

        perBatchSize = newSize;
    }

    function withdrawOperationFund(uint256 amount, address walletAddress, string memory reason) public onlyOwner() {

        require(amount < operationalFund, "You cannot withdraw more funds that you have in mansion fund");
    	require(amount <= _balance[address(this)], "You cannot withdraw more funds that you have in operation fund");
    	
    	operationalFund = operationalFund.sub(amount);
    	_balance[address(this)] = _balance[address(this)].sub(amount);
    	_balance[walletAddress] = _balance[walletAddress].add(amount);
    	
    	emit OperationalFundWithdrawn(amount, walletAddress, reason);
    }
    
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half);
        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniSwapV2Router.WETH();

        _approve(address(this), address(uniSwapV2Router), tokenAmount);

        uniSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    receive() external payable {}

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        _approve(address(this), address(uniSwapV2Router), tokenAmount);

        uniSwapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }
    
    
    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }
    
    function _transfer(address fromAddress, address toAddress, uint256 amount) private {

        require(fromAddress != address(0) && toAddress != address(0), "ERC20: transfer from/to the zero address");
        require(amount > 0 && amount <= _balance[fromAddress], "Transfer amount invalid");
        if(fromAddress != owner() && toAddress != owner())
            require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        uint256 contractTokenBalance = balanceOf(address(this)).sub(getCommunityMansionCashFund());
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            fromAddress != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance);
        }
        
        _balance[fromAddress] = _balance[fromAddress].sub(amount);
        uint256 transactionTokenAmount = _getValues(amount);
        _balance[toAddress] = _balance[toAddress].add(transactionTokenAmount);

        if (_balance[toAddress] >= minHoldingThreshold && toAddress != address(this)){
        	addEntity(toAddress);
        }
        if (_balance[fromAddress] < minHoldingThreshold && fromAddress != address(this)) {
        	removeEntity(fromAddress);
        }
        
        shuffleEntities(amount, transactionTokenAmount);

        emit Transfer(fromAddress, toAddress, transactionTokenAmount);
    }

    function _getValues(uint256 amount) private returns (uint256) {

        if (!transactionFee ){
            return amount ;
        }
    	uint256 mansionTaxFee = _extractMansionFund(amount);
        uint256 operationalTax = _extractOperationalFund(amount);
    	uint256 burnableFundTax = _extractBurnableFund(amount);

    	uint256 businessTax = operationalTax.add(burnableFundTax).add(mansionTaxFee);
    	uint256 transactionAmount = amount.sub(businessTax);
        
		return transactionAmount;
    }

    function _extractMansionFund(uint256 amount) private returns (uint256) {

    	uint256 mansionFundContribution = _getExtractableFund(amount, mansionTax);
    	mansionFund = mansionFund.add(mansionFundContribution);
    	_balance[address(this)] = _balance[address(this)].add(mansionFundContribution);
    	return mansionFundContribution;
    }

    function _extractOperationalFund(uint256 amount) private returns (uint256) {

        (uint256 operationalFundContribution) = _getExtractableFund(amount, operationalFundRate);
    	operationalFund = operationalFund.add(operationalFundContribution);
    	_balance[address(this)] = _balance[address(this)].add(operationalFundContribution);
    	return operationalFundContribution;
    }

    function _extractBurnableFund(uint256 amount) private returns (uint256) {

    	(uint256 burnableFundContribution) = _getExtractableFund(amount, burnableFundRate);
    	burnableFund = burnableFund.add(burnableFundContribution);
    	_balance[address(this)] = _balance[address(this)].add(burnableFundContribution);
    	return burnableFundContribution;
    }

    function _getExtractableFund(uint256 amount, uint8 rate) private pure returns (uint256) {

    	return amount.mul(rate).div(10**2);
    }
    
    
    function startMansion() public onlyOwner returns (bool success) {

        require (mansionFund > 0, "fund too small");
        largePrizeTotal = mansionFund.div(4);
        mediumPrizeTotal = mansionFund.div(2);
        smallPrizeTotal = mansionFund.sub(largePrizeTotal).sub(mediumPrizeTotal);
        lastEntryAllowed = lastIndexUsed;
        
        emit StartMansion(largePrizeTotal, mediumPrizeTotal, smallPrizeTotal);
        
        return true;
    }
    
    function payoutLargeRedistribution() public onlyOwner() returns (bool success) {

        require (lastEntryAllowed != 0, "MANSION must be initiated before this function can be called.");
        uint256 seed = 48;
        uint256 largePrize = largePrizeTotal;
        
        uint randNum = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, seed))) % lastEntryAllowed;
        
        Entity memory bigPrizeEligibleEntity = getEntity(randNum, false);
        while (bigPrizeEligibleEntity._isValid != true) {
            randNum = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, seed))) % lastEntryAllowed;
            bigPrizeEligibleEntity = getEntity(randNum, false);
        }
        
        address bigPrizeEligibleAddress = bigPrizeEligibleEntity._key;
        
        mansionFund = mansionFund.sub(largePrize);
        _balance[bigPrizeEligibleAddress] = _balance[bigPrizeEligibleAddress].add(largePrize);
        _balance[address(this)] = _balance[address(this)].sub(largePrize);
        largePrizeTotal = 0;
        
        emit GrandPrizeReceivedAddresses(bigPrizeEligibleAddress, largePrize);
        
        return true;
    }
    
    function payoutMediumRedistribution() public onlyOwner() returns (bool success) {

        require (lastEntryAllowed != 0, "MANSION must be initiated before this function can be called.");
        uint256 mediumPrize = mediumPrizeTotal;
        uint256 eligibleHolderCount = 100;
        uint256 totalDisbursed = 0;
        uint256 seed = 48;
        address[] memory eligibleAddresses = new address[](100);
        uint8 counter = 0;
        
        if (lastEntryAllowed <= 100) {
    		eligibleHolderCount = lastEntryAllowed;
    		mediumPrize = mediumPrize.div(eligibleHolderCount);
    		while (counter < eligibleHolderCount) {
    	    
        	    if (indexToEntity[counter + 1]._isValid) {
        	        eligibleAddresses[counter] = indexToEntity[counter + 1]._key;
        	        totalDisbursed = totalDisbursed.add(mediumPrize);
        	        _balance[indexToEntity[counter + 1]._key] = _balance[indexToEntity[counter + 1]._key].add(mediumPrize);
        	        counter++;
        	    }
        	    seed = seed.add(1);
        	}
        	
        	mansionFund = mansionFund.sub(totalDisbursed);
        	_balance[address(this)] = _balance[address(this)].sub(totalDisbursed);
        	mediumPrizeTotal = 0;
        	
        	emit MediumPrizeReceivedAddresses(eligibleAddresses, mediumPrize);
        	
        	return true;
    	}
    	
    	mediumPrize = mediumPrize.div(eligibleHolderCount);
    	
    	while (counter < eligibleHolderCount) {
    	    
    	    uint randNum = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, seed))) % lastEntryAllowed;
    	    
    	    if (indexToEntity[randNum]._isValid) {
    	        eligibleAddresses[counter] = indexToEntity[randNum]._key;
    	        totalDisbursed = totalDisbursed.add(mediumPrize);
    	        _balance[indexToEntity[randNum]._key] = _balance[indexToEntity[randNum]._key].add(mediumPrize);
    	        counter++;
    	    }
    	    seed = seed.add(1);
    	}
    	
    	mansionFund = mansionFund.sub(totalDisbursed);
        _balance[address(this)] = _balance[address(this)].sub(totalDisbursed);
        mediumPrizeTotal = 0;
    	
    	emit MediumPrizeReceivedAddresses(eligibleAddresses, mediumPrize);
		
		return true;
    }
    
    function payoutSmallRedistribution(uint256 startIndex) public onlyOwner() returns (bool success) {

        require (lastEntryAllowed != 0 && startIndex > 0, "Medium prize must be disbursed before this one");
        
        uint256 rewardAmount = smallPrizeTotal.div(lastEntryAllowed);
        uint256 totalDisbursed = 0;
        
        for (uint256 i = startIndex; i < startIndex + perBatchSize; i++) {
            if  (mansionFund < rewardAmount) {
                break;
            }
            if (indexToEntity[i]._isValid == true) {
                _balance[indexToEntity[i]._key] = _balance[indexToEntity[i]._key].add(rewardAmount);
                totalDisbursed = totalDisbursed.add(rewardAmount);
            }
            if (i == lastEntryAllowed) {
                emit SmallPrizePayoutComplete(rewardAmount);
                smallPrizeTotal = 0;
                break;
            }
        }
        
        mansionFund = mansionFund.sub(totalDisbursed);
        _balance[address(this)] = _balance[address(this)].sub(totalDisbursed);
        
        return true;
    }
    
    function EndMansion() public onlyOwner returns (bool success) {

        require (lastEntryAllowed != 0, "All prizes must be disbursed before being able to close MANSION");
        smallPrizeTotal = 0;
        mediumPrizeTotal = 0;
        largePrizeTotal = 0;
        lastEntryAllowed = 0;
        
        return true;
    }
    
    function addEntity (address walletAddress) private {
        if (addressToIndex[walletAddress] != 0) {
            return;
        }
        uint256 index = lastIndexUsed.add(1);
        
		indexToEntity[index] = Entity({
		    _key: walletAddress,
		    _isValid: true, 
		    _createdAt: block.timestamp
		});
		
		addressToIndex[walletAddress] = index;
		lastIndexUsed = index;
	}

	function removeEntity (address walletAddress) private {
	    if (addressToIndex[walletAddress] == 0) {
            return;
        }
        uint256 index = addressToIndex[walletAddress];
        addressToIndex[walletAddress] = 0;
        
        if (index != lastIndexUsed) {
            indexToEntity[index] = indexToEntity[lastIndexUsed];
            addressToIndex[indexToEntity[lastIndexUsed]._key] = index;
        }
        indexToEntity[lastIndexUsed]._isValid = false;
        lastIndexUsed = lastIndexUsed.sub(1);
	}
	
	function shuffleEntities(uint256 intA, uint256 intB) private {

	    intA = intA.mod(lastIndexUsed - 1) + 1;
	    intB = intB.mod(lastIndexUsed - 1) + 1;
	    
	    Entity memory entityA = indexToEntity[intA];
	    Entity memory entityB = indexToEntity[intB];
	    
	    if (entityA._isValid && entityB._isValid) {
	        addressToIndex[entityA._key] = intB;
	        addressToIndex[entityB._key] = intA;
	        
	        indexToEntity[intA] = entityB;
	        indexToEntity[intB] = entityA;
	    }
	}
	
	function getEntityListLength () public view returns (uint256) {
	    return lastIndexUsed;
	}
	
	function getEntity (uint256 index, bool shouldReject) private view returns (Entity memory) {
	    if (shouldReject == true) {
	        require(index <= getEntityListLength(), "Index out of range");
	    }
	    return indexToEntity[index];
	}
	
	function getEntityTimeStamp (address walletAddress) public view returns (uint256) {
	    require (addressToIndex[walletAddress] != 0, "Empty!");
	    return indexToEntity[addressToIndex[walletAddress]]._createdAt;
	}

}