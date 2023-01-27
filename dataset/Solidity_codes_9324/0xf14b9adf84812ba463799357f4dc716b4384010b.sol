



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



interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}





library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}



library Arrays {

    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {

        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}



library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

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


contract PensionPlan is Context, IERC20, IERC20Metadata, Ownable {

    using Address for address;
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private constant _totalSupply = 1000000000000 * 10**8;

    string private constant _name = "Pension Plan";
    string private constant _symbol = "PP";
    
    address payable public marketingAddress = payable(0x83B6d6dec5b35259f6bAA3371006b9AC397A4Ff7);
    address payable public developmentAddress = payable(0x2F01336282CEbF5D981e923edE9E6FaC333dA2C6);
    address payable public foundationAddress = payable(0x72d752776B093575a40B1AC04c57811086cb4B55);
    address payable public hachikoInuBuybackAddress = payable(0xd6C8385ec4F08dF85B39c301C993A692790288c7);
    address payable public constant deadAddress = payable(0x000000000000000000000000000000000000dEaD);

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    
    mapping (address => bool) private _isBanned;
    address[] private _banned;
   
    uint256 public constant totalFee = 12;

    uint256 public minimumTokensBeforeSwap = 200000000 * 10**8; 

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;

    uint256 public minimumETHBeforePayout = 1 * 10**18;
    uint256 public payoutsToProcess = 5;
    uint256 private _lastProcessedAddressIndex;
    uint256 public _payoutAmount;
    bool public processingPayouts;
    uint256 public _snapshotId;
    
    struct Set {
        address[] values;
        mapping (address => bool) is_in;
    }
    
    Set private _allAddresses;

    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event PayoutStarted(
        uint256 amount
    );
    
    modifier lockTheSwap {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        
        excludeFromReward(owner());
        excludeFromReward(_uniswapV2Pair);
        excludeFromReward(marketingAddress);
        excludeFromReward(developmentAddress);
        excludeFromReward(foundationAddress);
        excludeFromReward(hachikoInuBuybackAddress);
        excludeFromReward(deadAddress);
        
        _beforeTokenTransfer(address(0), owner());
        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
    }

    function name() public pure override returns (string memory) {

        return _name;
    }

    function symbol() public pure override returns (string memory) {

        return _symbol;
    }

    function decimals() public pure override returns (uint8) {

        return 8;
    }

    function totalSupply() public pure override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function eligibleSupply() public view returns (uint256) {

        uint256 supply =  _totalSupply;
        for (uint256 i = 0; i < _excluded.length; i++) {
            unchecked {
                supply = supply - _balances[_excluded[i]];
            }
        }
        return supply;
        
    }

    function eligibleSupplyAt(uint256 snapshotId) public view returns (uint256) {

        uint256 supply =  _totalSupply;
        for (uint256 i = 0; i < _excluded.length; i++) {
            unchecked {
                supply = supply - balanceOfAt(_excluded[i], snapshotId);
            }
        }
        return supply;
        
    }

    function isExcludedFromReward(address account) public view returns (bool) {

        return _isExcluded[account];
    }

    function excludeFromReward(address account) public onlyOwner() {

        require(!_isExcluded[account], "Account is already excluded");
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) public onlyOwner() {

        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function isBanned(address account) public view returns (bool) {

        return _isBanned[account];
    }

    function ban(address account) external onlyOwner() {

        require(!_isBanned[account], "Account is already banned");
        _isBanned[account] = true;
        _banned.push(account);
        if (!_isExcluded[account]) {
            excludeFromReward(account);
        }
    }

    function unban(address account) external onlyOwner() {

        require(_isBanned[account], "Account is already unbanned");
        for (uint256 i = 0; i < _banned.length; i++) {
            if (_banned[i] == account) {
                _banned[i] = _banned[_banned.length - 1];
                _isBanned[account] = false;
                _banned.pop();
                break;
            }
        }
        if (_isExcluded[account]) {
            includeInReward(account);
        }
    }

    function _processPayouts() private {

        if (_lastProcessedAddressIndex == 0) {
            _lastProcessedAddressIndex = _allAddresses.values.length;
        }
        
        uint256 i = _lastProcessedAddressIndex;
        uint256 loopLimit = 0;
        if (_lastProcessedAddressIndex > payoutsToProcess) {
            loopLimit = _lastProcessedAddressIndex-payoutsToProcess;
        }
        
        uint256 _availableSupply = eligibleSupplyAt(_snapshotId);
        for (; i > loopLimit; i--) {
            address to = _allAddresses.values[i-1];
            if (_isExcluded[to] || to.isContract()) {
                continue;
            }
            uint256 payout = balanceOfAt(to, _snapshotId) / (_availableSupply / _payoutAmount);
            payable(to).send(payout);
        }
        _lastProcessedAddressIndex = i;
        if (_lastProcessedAddressIndex == 0) {
            processingPayouts = false;
        }
    }
    
    function _handleSwapAndPayout(address to) private {

        if (!inSwapAndLiquify && to == uniswapV2Pair) {
            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            if (overMinimumTokenBalance) {
                swapTokensForEth(contractTokenBalance);    
            }
            uint256 balance = address(this).balance;
            if (!processingPayouts && balance > minimumETHBeforePayout) {
                marketingAddress.transfer(balance / 6);
                developmentAddress.transfer(balance / 12);
                foundationAddress.transfer(balance / 12);
                hachikoInuBuybackAddress.transfer( balance / 24);
                swapETHForTokensAndBurn(balance / 24);
                processingPayouts = true;
                _payoutAmount = address(this).balance;
                _snapshotId = _snapshot();
                emit PayoutStarted(_payoutAmount);
            }
        }
    }
    
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!_isBanned[sender], "ERC: transfer from banned address");
        require(!_isBanned[recipient], "ERC: transfer to banned address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        _beforeTokenTransfer(sender, recipient);
        if (!inSwapAndLiquify && processingPayouts) {
            _processPayouts();
        }
        _handleSwapAndPayout(recipient);

        bool takeFee = (recipient == uniswapV2Pair || sender == uniswapV2Pair);
        if(recipient == deadAddress || sender == owner()){
            takeFee = false;
        }
        
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        uint256 originalAmount = amount;
        if (takeFee) {
            uint256 fee = (amount * totalFee) / 100;
            _balances[address(this)] += fee;
            amount -= fee;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, originalAmount);
    }

    function _beforeTokenTransfer(
        address sender,
        address recipient
    ) internal {

        if (sender == address(0)) {
            _updateAccountSnapshot(recipient);
            _updateTotalSupplySnapshot();
        } else if (recipient == address(0)) {
            _updateAccountSnapshot(sender);
            _updateTotalSupplySnapshot();
        } else {
            _updateAccountSnapshot(sender);
            _updateAccountSnapshot(recipient);
        }
        if (!_allAddresses.is_in[recipient]) {
            _allAddresses.values.push(recipient);
            _allAddresses.is_in[recipient] = true;
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }
    
    function swapETHForTokensAndBurn(uint256 amount) private lockTheSwap {

        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp + 300
        );
        
        emit SwapETHForTokens(amount, path);
    }

    function setMinimumTokensBeforeSwap(uint256 _minimumTokensBeforeSwap) external onlyOwner() {

        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }
    
    function setMarketingAddress(address _marketingAddress) external onlyOwner() {

        marketingAddress = payable(_marketingAddress);
    }
    
    function setDevelopmentAddress(address _developmentAddress) external onlyOwner() {

        developmentAddress = payable(_developmentAddress);
    }
    
    function setFoundationAddress(address _foundationAddress) external onlyOwner() {

        foundationAddress = payable(_foundationAddress);
    }
    
    function setHachikoInuBuybackAddress(address _hachikoInuBuybackAddress) external onlyOwner() {

        hachikoInuBuybackAddress = payable(_hachikoInuBuybackAddress);
    }
    
    function setMinimumETHBeforePayout(uint256 _minimumETHBeforePayout) external onlyOwner() {

        minimumETHBeforePayout = _minimumETHBeforePayout;
    }
    
    function setPayoutsToProcess(uint256 _payoutsToProcess) external onlyOwner() {

        payoutsToProcess = _payoutsToProcess;
    }
    
    function manuallyProcessPayouts() external onlyOwner() returns(bool, uint256) {

        if (processingPayouts) {
            _processPayouts();
        }
        else {
            uint256 balance = address(this).balance;
            marketingAddress.transfer(balance / 6);
            developmentAddress.transfer(balance / 12);
            foundationAddress.transfer(balance / 12);
            hachikoInuBuybackAddress.transfer( balance / 24);
            swapETHForTokensAndBurn(balance / 24);
            processingPayouts = true;
            _payoutAmount = address(this).balance;
            _snapshotId = _snapshot();
            emit PayoutStarted(_payoutAmount);
        }
        return (processingPayouts, _lastProcessedAddressIndex);
    }
    
    using Arrays for uint256[];
    using Counters for Counters.Counter;

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    Counters.Counter private _currentSnapshotId;

    event Snapshot(uint256 id);

    function _snapshot() internal returns (uint256) {

        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }

    function _getCurrentSnapshotId() internal view returns (uint256) {

        return _currentSnapshotId.current();
    }

    function balanceOfAt(address account, uint256 snapshotId) public view returns (uint256) {

        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    function totalSupplyAt(uint256 snapshotId) public view returns (uint256) {

        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots) private view returns (bool, uint256) {

        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _getCurrentSnapshotId(), "ERC20Snapshot: nonexistent id");


        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {

        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {

        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {

        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {

        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }

    receive() external payable {}
}