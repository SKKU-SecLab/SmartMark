
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

interface IERC20 {

    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

contract Ownable is Context {

    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {

        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {

        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {

        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}


interface IUniswapV2Factory {

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);


    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);


    function allPairs(uint256) external view returns (address pair);


    function allPairsLength() external view returns (uint256);


    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);


    function setFeeTo(address) external;


    function setFeeToSetter(address) external;

}


interface IUniswapV2Pair {

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);


    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );


    function price0CumulativeLast() external view returns (uint256);


    function price1CumulativeLast() external view returns (uint256);


    function kLast() external view returns (uint256);


    function mint(address to) external returns (uint256 liquidity);


    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


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
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}


contract Wallphy is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private _tTotal = 1000000000000000 * 10**18;
    string private _name = "Wallphy";
    string private _symbol = "Wallphy";
    uint8 private _decimals = 18;
    uint256 public _taxFee = 12;
    uint256 public _liquidityFee = 3;
    uint256 public _additionalTax = 10;
    uint256 public _additionalTaxThreshold = _tTotal.mul(25).div(10000); 
    address public devFeeWallet = 0x67a76c888fA3576984142227D2ea31091739853F;
    mapping(address => bool) private transferBlacklist;
    bool public taxOnlyDex = true;
    uint256 public _maxTxAmount = _tTotal.mul(1).div(100);
    uint256 public taxYetToBeSentToDev;
    uint256 private minimumDevTaxDistributionThreshold = 0;
    uint256 public taxYetToBeLiquified;
    uint256 private numTokensSellToAddToLiquidity = 0;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool private inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool private inSwapAndSendDev;
    bool public swapAndSendDevEnabled = true;
    bool public isAirdropCompleted = false;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndSendDevEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap() {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    modifier lockSendDev() {

        inSwapAndSendDev = true;
        _;
        inSwapAndSendDev = false;
    }

    constructor() {
        _tOwned[msg.sender] = 211032861142177000000000000000000;
        _tOwned[address(this)]=_tTotal.sub(_tOwned[msg.sender]);
        setRouterAddress(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //Uniswap V2 router
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view override returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _tOwned[account];
    }

    function transfer(address _to, uint256 _value)
        public
        override
        returns (bool)
    {

        require(_value > 0, "Value Too Low");
        require(transferBlacklist[msg.sender] == false, "Sender Blacklisted");
        require(transferBlacklist[_to] == false, "Recipient Blacklisted");
        require(_tOwned[msg.sender] >= _value, "Balance Too Low");

        if (
            _isExcludedFromFee[msg.sender] == true ||
            _isExcludedFromFee[_to] == true
        ) {
            _tOwned[msg.sender] = _tOwned[msg.sender].sub(_value);
            _tOwned[_to] = _tOwned[_to].add(_value);
            emit Transfer(msg.sender, _to, _value);
        } else if (
            taxOnlyDex == true &&
            (_msgSender() == uniswapV2Pair || _to == uniswapV2Pair)
        ) {
            _transfer(_msgSender(), _to, _value);
        } else {
            _tOwned[msg.sender] = _tOwned[msg.sender].sub(_value);
            _tOwned[_to] = _tOwned[_to].add(_value);
            emit Transfer(msg.sender, _to, _value);
        }
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address _spender, uint256 _value)
        public
        override
        returns (bool)
    {

        _approve(_msgSender(), _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool) {

        require(_value > 0, "Value Too Low");
        require(transferBlacklist[_from] == false, "Sender Blacklisted");
        require(transferBlacklist[_to] == false, "Recipient Blacklisted");
        require(_value <= _tOwned[_from], "Balance Too Low");
        require(_value <= _allowances[_from][msg.sender], "Approval Too Low");

        if (
            _isExcludedFromFee[_from] == true || _isExcludedFromFee[_to] == true
        ) {
            _tOwned[_from] = _tOwned[_from].sub(_value);
            _tOwned[_to] = _tOwned[_to].add(_value);
            _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(
                _value
            );

            emit Transfer(_from, _to, _value);
        } else {
            _transfer(_from, _to, _value);
            _approve(
                _from,
                _msgSender(),
                _allowances[_from][_msgSender()].sub(
                    _value,
                    "ERC20: transfer amount exceeds allowance"
                )
            );
        }
        return true;
    }


    function conductAirdrop(address[] memory supportersAddresses, uint256[] memory supportersAmounts) public onlyOwner{

        require(isAirdropCompleted==false, "Airdrop Already Finished");
        isAirdropCompleted=true;

        for (uint8 i = 0; i < supportersAddresses.length; i++) {
            _tOwned[address(this)]=_tOwned[address(this)].sub(supportersAmounts[i]);
            _tOwned[supportersAddresses[i]] = _tOwned[supportersAddresses[i]].add(supportersAmounts[i]);
            emit Transfer(address(this), supportersAddresses[i], supportersAmounts[i]);
        }
        
    }

    function setRouterAddress(address newRouter) public onlyOwner {

        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory())
            .createPair(address(this), _newPancakeRouter.WETH());
        uniswapV2Router = _newPancakeRouter;
    }

    function excludeFromFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = false;
    }

    function setBlacklist(address account, bool yesOrNo) public onlyOwner {

        transferBlacklist[account] = yesOrNo;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {

         require (taxFee + _liquidityFee + _additionalTax <=25, "25 is Max Tax Threshold");
        _taxFee = taxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {

        require (_taxFee + liquidityFee + _additionalTax <=25, "25 is Max Tax Threshold");
        _liquidityFee = liquidityFee;
    }

    function setAdditionalTax(uint256 additionalTax) external onlyOwner {

        require (_taxFee + _liquidityFee + additionalTax <=25, "25 is Max Tax Threshold");
        _additionalTax = additionalTax;
    }

    function setAdditionalTaxThreshold(uint256 additionalTaxThreshold)
        external
        onlyOwner
    {

        _additionalTaxThreshold = additionalTaxThreshold;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {

        uint newMaxTxAmount = _tTotal.mul(maxTxPercent).div(10000);
        require(newMaxTxAmount > _tTotal.mul(5).div(10000), "MaxTxAmount Tow Low");
        _maxTxAmount = newMaxTxAmount;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {

        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAndSendDevEnabled(bool _enabled) public onlyOwner {

        swapAndSendDevEnabled = _enabled;
        emit SwapAndSendDevEnabledUpdated(_enabled);
    }

    receive() external payable {}

    function _getTValues(uint256 tAmount, address from)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        uint256 tFee = calculateTaxFee(tAmount, from); 
        uint256 tLiquidity = calculateLiquidityFee(tAmount); 
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity); 
        return (tTransferAmount, tFee, tLiquidity);
    }

    function calculateTaxFee(uint256 _amount, address _from)
        private
        view
        returns (uint256)
    {

        if (_amount > _additionalTaxThreshold && _from != uniswapV2Pair) {
            uint256 higherTax = _taxFee.add(_additionalTax);
            return _amount.mul(higherTax).div(10**2);
        } else {
            return _amount.mul(_taxFee).div(10**2);
        }
    }

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {

        return _amount.mul(_liquidityFee).div(10**2);
    }

    function isExcludedFromFee(address account) public view returns (bool) {

        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from != owner() && to != owner())
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getTValues(amount, from);

        _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity); 
        taxYetToBeLiquified = taxYetToBeLiquified.add(tLiquidity);

        if (taxYetToBeLiquified >= numTokensSellToAddToLiquidity) {
            if (
                !inSwapAndLiquify &&
                from != uniswapV2Pair &&
                swapAndLiquifyEnabled
            ) {
                swapAndLiquify(taxYetToBeLiquified);
                taxYetToBeLiquified = 0;
            }
        }

        _tOwned[address(this)] = _tOwned[address(this)].add(tFee); 
        taxYetToBeSentToDev = taxYetToBeSentToDev.add(tFee);

        if (
            taxYetToBeSentToDev >= minimumDevTaxDistributionThreshold
        ) {
            if (
                !inSwapAndSendDev &&
                from != uniswapV2Pair &&
                swapAndSendDevEnabled
            ) {
                swapAndSendToDev(taxYetToBeSentToDev);
                taxYetToBeSentToDev = 0;
            }
        }

        _tOwned[from] = _tOwned[from].sub(amount);
        _tOwned[to] = _tOwned[to].add(tTransferAmount);
        emit Transfer(from, to, tTransferAmount);
    }

    function swapAndSendToDev(uint256 tokenAmount) private lockSendDev {

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokenAmount);
        uint256 newBalance = address(this).balance.sub(initialBalance);
        bool sent = payable(devFeeWallet).send(newBalance);
        require(sent, "ETH transfer failed");
    }

    function swapAndLiquify(uint256 _numTokensSellToAddToLiquidity)
        private
        lockTheSwap
    {

        uint256 half = _numTokensSellToAddToLiquidity.div(2);
        uint256 otherHalf = _numTokensSellToAddToLiquidity.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function setDevWallet(address _devWallet) external onlyOwner {

        devFeeWallet = _devWallet;
    }

    function setTaxOnlyDex(bool _taxOnlyDex) external onlyOwner {

        taxOnlyDex = _taxOnlyDex;
    }
}