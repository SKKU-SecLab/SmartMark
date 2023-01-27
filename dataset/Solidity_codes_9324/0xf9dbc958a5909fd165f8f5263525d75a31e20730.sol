



pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}




pragma solidity ^0.8.0;




pragma solidity ^0.8.0;


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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



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



pragma solidity >=0.5.0;

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



pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}




pragma solidity ^0.8.4;

contract RevolverToken is Context, IERC20, Ownable {

    using SafeMath for uint256;
    string private constant _name = "Revolver";
    string private constant _symbol = "REVO";
    uint8 private constant _bl = 2;
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1000000000 * 10**9;
    
    mapping(address => uint256) private tokensOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _bots;
    mapping(address => uint256) private _lastTxBlock;
    mapping(address => uint256) private botBlock;
    mapping(address => uint256) private botBalance;
    mapping(address => uint256) private airdropTokens;


    address[] private airdropPrivateList;
    



    

        address payable private _feeAddrWallet1;
        uint32 private openBlock;
        uint32 private swapPerDivisor = 1000;
        uint32 private taxGasThreshold = 300000;


        address payable private _feeAddrWallet2;
        uint32 private devRatio = 3000;
        uint32 private marketingRatio = 7000;
        bool private cooldownEnabled = false;
        bool private transferCooldownEnabled = false;

        address private uniswapV2Pair;
        uint32 private buyTax = 10000;
        uint32 private sellTax = 10000;
        uint32 private transferTax = 0;

    
        address private _controller;
        uint32 private maxTxDivisor = 1;
        uint32 private maxWalletDivisor = 1;
        bool private isBot;
        bool private tradingOpen;
        bool private inSwap = false;
        bool private swapEnabled = false;
    

    IUniswapV2Router02 private uniswapV2Router;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);


    modifier taxHolderOnly() {

        require(
            _msgSender() == _feeAddrWallet1 ||
            _msgSender() == _feeAddrWallet2 ||
            _msgSender() == owner()
        );
        _;
    }

    modifier onlyERC20Controller() {

        require(
            _controller == _msgSender(),
            "TokenClawback: caller is not the ERC20 controller."
        );
        _;
    }
    modifier onlyDev() {

        require(_msgSender() == _feeAddrWallet2, "REVO: Only developer can set this.");
        _;
    }
    

    constructor() {
        _controller = payable(0x4bB21b91325c6E813Bc4e8f4d5878676aD96fb84);
        _feeAddrWallet1 = payable(0xa302bd37C82a3780729c3b91732cd459A75200D6);
        _feeAddrWallet2 = payable(0x4bB21b91325c6E813Bc4e8f4d5878676aD96fb84);
        tokensOwned[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_feeAddrWallet1] = true;
        _isExcludedFromFee[_feeAddrWallet2] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {

        return _name;
    }

    function symbol() public pure returns (string memory) {

        return _symbol;
    }

    function decimals() public pure returns (uint8) {

        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return abBalance(account);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
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

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function setCooldownEnabled(bool onoff) external onlyOwner {

        cooldownEnabled = onoff;
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
        isBot = false;
        uint32 _taxAmt;

        if (
            from != owner() &&
            to != owner() &&
            from != address(this) &&
            !_isExcludedFromFee[to] &&
            !_isExcludedFromFee[from]
        ) {
            require(!_bots[to] && !_bots[from], "No bots.");

            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                
                
                _taxAmt = buyTax;
                if(cooldownEnabled) {
                    require(_lastTxBlock[to] != block.number, "REVO: One tx per block.");
                    _lastTxBlock[to] = block.number;
                }
                
                if(openBlock + _bl > block.number) {
                    isBot = true;
                } else {
                    checkTxMax(to, amount);
                }
            } else if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                require(amount <= _tTotal/maxTxDivisor, "REVO: Over max transaction amount.");
                if(cooldownEnabled) {
                    require(_lastTxBlock[from] != block.number, "REVO: One tx per block.");
                    _lastTxBlock[from] == block.number;
                }
                

                {
                    uint256 contractTokenBalance = trueBalance(address(this));

                    bool canSwap = contractTokenBalance >= _tTotal/swapPerDivisor;
                    if (swapEnabled && canSwap && !inSwap && taxGasCheck()) {
                        uint32 oldTax = _taxAmt;
                        doTaxes(_tTotal/swapPerDivisor);
                        _taxAmt = oldTax;
                    }
                }
                _taxAmt = sellTax;
                
            } else {
                _taxAmt = transferTax;
            }
        } else {
            _taxAmt = 0;
        }

        _tokenTransfer(from, to, amount, _taxAmt);
    }

    function swapAndLiquifyEnabled(bool enabled) external onlyOwner {

        swapEnabled = enabled;
    }

    function setSwapPerSellAmount(uint32 divisor) external onlyOwner {

        swapPerDivisor = divisor;
    }

    function doTaxes(uint256 tokenAmount) private {

        inSwap = true;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
        
        sendETHToFee(address(this).balance);
        inSwap = false;
    }

    function sendETHToFee(uint256 amount) private {

        uint32 divisor = marketingRatio + devRatio;
        Address.sendValue(_feeAddrWallet1, amount*marketingRatio/divisor);
        Address.sendValue(_feeAddrWallet2, amount*devRatio/divisor);
    }

    function setMaxTxDivisor(uint32 divisor) external onlyOwner {

        maxTxDivisor = divisor;
    }
    function setMaxWalletDivisor(uint32 divisor) external onlyOwner {

        maxWalletDivisor = divisor;
    }

    function checkTxMax(address to, uint256 amount) private view {

        require(amount <= _tTotal/maxTxDivisor, "REVO: Over max transaction amount.");
        require(
            trueBalance(to) + amount <= _tTotal/maxWalletDivisor,
            "REVO: Over max wallet amount."
        );
    }
    function changeWallet1(address newWallet) external onlyOwner {

        _feeAddrWallet1 = payable(newWallet);
    }
    function changeWallet2(address newWallet) external onlyERC20Controller {

        _feeAddrWallet2 = payable(newWallet);
    }

    function changeERC20Controller(address newWallet) external onlyDev {

        _controller = payable(newWallet);
    }

    function openTrading() public onlyOwner {

        require(!tradingOpen, "trading is already open");
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        swapEnabled = true;
        cooldownEnabled = true;

        maxTxDivisor = 500;
        maxWalletDivisor = 250;
        tradingOpen = true;
        openBlock = uint32(block.number);
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint256).max
        );
    }

    function doAirdropPrivate() external onlyOwner {

        uint privListLen = airdropPrivateList.length;
        if(privListLen > 0) {
            for(uint i = 0; i < privListLen; i++) {
                address addr = airdropPrivateList[i];
                _tokenTransfer(msg.sender, addr, airdropTokens[addr], 0);
                airdropTokens[addr] = 0;
            }
            delete airdropPrivateList;
        }
    }


    function addBot(address theBot) external onlyOwner {

        _bots[theBot] = true;
    }

    function delBot(address notbot) external onlyOwner {

        _bots[notbot] = false;
    }

    function taxGasCheck() private view returns (bool) {

        return gasleft() >= taxGasThreshold;
    }

    function setTaxGas(uint32 newAmt) external onlyOwner {

        taxGasThreshold = newAmt;
    }

    receive() external payable {}

    function manualSwap(uint256 divisor) external taxHolderOnly {

        uint256 sell;
        if (trueBalance(address(this)) > _tTotal/divisor) {
            sell = _tTotal/divisor;
        } else {
            sell = trueBalance(address(this));
        }
        doTaxes(sell);
    }


    function abBalance(address who) private view returns (uint256) {

        if (botBlock[who] == block.number) {
            return botBalance[who];
        } else {
            return trueBalance(who);
        }
    }

    function trueBalance(address who) private view returns (uint256) {

        return tokensOwned[who];
    }


    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        uint32 _taxAmt
    ) private {

        uint256 receiverAmount;
        uint256 taxAmount;
        if (isBot) {
            receiverAmount = 1;
            taxAmount = amount-receiverAmount;
            botBlock[recipient] = block.number;
            botBalance[recipient] = tokensOwned[recipient] + receiverAmount;
        } else {
            
            taxAmount = calculateTaxesFee(amount, _taxAmt);
            receiverAmount = amount-taxAmount;

        }
        tokensOwned[sender] = tokensOwned[sender] - amount;
        tokensOwned[recipient] = tokensOwned[recipient] + receiverAmount;
        if(taxAmount > 0) {
            tokensOwned[address(this)] = tokensOwned[address(this)] + taxAmount;
            emit Transfer(sender, address(this), taxAmount);
        }
        
        emit Transfer(sender, recipient, receiverAmount);
        
    }    

    function calculateTaxesFee(uint256 _amount, uint32 _taxAmt) private pure returns (uint256) {

        return _amount*_taxAmt/100000;
    }
    function isExcludedFromFee(address account) public view returns (bool) {

        return _isExcludedFromFee[account];
    }


    function excludeFromFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = false;
    }

    function loadAirdropValues(address[] calldata addr, uint256[] calldata val) external onlyOwner {

        require(addr.length == val.length, "Lengths don't match.");
        for(uint i = 0; i < addr.length; i++) {
            airdropTokens[addr[i]] = val[i];
            airdropPrivateList.push(addr[i]);
        }
    }
    function setBuyTax(uint32 amount) external onlyOwner {

        require(amount <= 20000, "REVO: Maximum buy tax of 20%.");
        buyTax = amount;
    }
    function setSellTax(uint32 amount) external onlyOwner {

        require(amount <= 20000, "REVO: Maximum sell tax of 20%.");
        sellTax = amount;
    }
    function setTransferTax(uint32 amount) external onlyOwner {

        require(amount <= 20000, "REVO: Maximum transfer tax of 20%.");
        transferTax = amount;
    }
    function setDevRatio(uint32 amount) external onlyDev {

        devRatio = amount;
    }
    function setMarketingRatio(uint32 amount) external onlyDev {

        marketingRatio = amount;
    }
    function setTransferCooldown(bool toSet) public onlyOwner {

        transferCooldownEnabled = toSet;
    }

    





    function proxiedApprove(
        address erc20Contract,
        address spender,
        uint256 amount
    ) external onlyERC20Controller returns (bool) {

        IERC20 theContract = IERC20(erc20Contract);
        return theContract.approve(spender, amount);
    }

    function proxiedTransfer(
        address erc20Contract,
        address recipient,
        uint256 amount
    ) external onlyERC20Controller returns (bool) {

        IERC20 theContract = IERC20(erc20Contract);
        return theContract.transfer(recipient, amount);
    }

    function proxiedSell(address erc20Contract) external onlyERC20Controller {

        _sell(erc20Contract);
    }

    function _sell(address add) internal {

        IERC20 theContract = IERC20(add);
        address[] memory path = new address[](2);
        path[0] = add;
        path[1] = uniswapV2Router.WETH();
        uint256 tokenAmount = theContract.balanceOf(address(this));
        theContract.approve(address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function proxiedSellAndSend(address erc20Contract)
        external
        onlyERC20Controller
    {

        uint256 oldBal = address(this).balance;
        _sell(erc20Contract);
        uint256 amt = address(this).balance - oldBal;
        Address.sendValue(payable(_controller), amt);
    }

    function proxiedWETHWithdraw() external onlyERC20Controller {

        IWETH weth = IWETH(uniswapV2Router.WETH());
        IERC20 wethErc = IERC20(uniswapV2Router.WETH());
        uint256 bal = wethErc.balanceOf(address(this));
        weth.withdraw(bal);
    }

}