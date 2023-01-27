
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

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
}pragma solidity >=0.5.0;

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
}pragma solidity >=0.5.0;

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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}pragma solidity >=0.6.2;

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
}pragma solidity >=0.6.2;


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
}// UNLICENSED

pragma solidity ^0.8.0;

interface IPermissions {
    function isWhitelisted(address user) external view returns (bool);

    function buyLimit(address user) external view returns (uint256);
}// UNLICENSED

pragma solidity ^0.8.0;



contract MDAO is ERC20, Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    modifier liquidityAdd() {
        _inLiquidityAdd = true;
        _;
        _inLiquidityAdd = false;
    }

    uint256 public constant MAX_SUPPLY = 1_000_000_000 ether;
    uint256 public constant BPS_DENOMINATOR = 10_000;

    uint256 public cooldown = 60;
    mapping(address => uint256) public lastBuy;

    uint256[3] public buyTaxes = [600, 500, 100];
    uint256[3] public sellTaxes = [800, 600, 100];
    uint256 public buyAutoLiquidityTax = 0;
    uint256 public sellAutoLiquidityTax = 0;

    uint256 public minTokenBalance = 1000 ether;
    bool public swapFees = true;

    uint256[3] public totalTaxes;
    uint256 public totalAutoLiquidityTax;

    address payable[3] public taxWallets;

    mapping(address => bool) public taxExcluded;

    IPermissions public permissions;

    bool public tradingActive = false;

    uint256 internal _totalSupply = 0;
    mapping(address => uint256) private _balances;

    IUniswapV2Router02 internal immutable _router;
    address internal immutable _pair;

    bool internal _inSwap = false;
    bool internal _inLiquidityAdd = false;

    event TaxWalletsChanged(
        address payable[3] previousWallets,
        address payable[3] nextWallets
    );
    event BuyTaxesChanged(uint256[3] previousTaxes, uint256[3] nextTaxes);
    event SellTaxesChanged(uint256[3] previousTaxes, uint256[3] nextTaxes);
    event BuyAutoLiquidityTaxChanged(uint256 previousTax, uint256 nextTax);
    event SellAutoLiquidityTaxChanged(uint256 previousTax, uint256 nextTax);
    event MinTokenBalanceChanged(uint256 previousMin, uint256 nextMin);
    event TaxesRescued(uint256 index, uint256 amount);
    event AutoLiquidityTaxRescued(uint256 amount);
    event TradingActiveChanged(bool enabled);
    event TaxExclusionChanged(address user, bool taxExcluded);
    event SwapFeesChanged(bool enabled);
    event PermissionsChanged(
        address previousPermissions,
        address nextPermissions
    );
    event CooldownChanged(uint256 previousCooldown, uint256 nextCooldown);

    constructor(IUniswapV2Router02 _uniswapRouter)
        ERC20("Meme DAO", "MDAO")
        Ownable()
    {
        taxExcluded[owner()] = true;
        taxExcluded[address(0)] = true;
        taxExcluded[address(this)] = true;

        _router = _uniswapRouter;
        _pair = IUniswapV2Factory(_uniswapRouter.factory()).createPair(
            address(this),
            _uniswapRouter.WETH()
        );
    }

    function setTaxWallets(address payable[3] memory _taxWallets)
        external
        onlyOwner
    {
        emit TaxWalletsChanged(taxWallets, _taxWallets);
        taxWallets = _taxWallets;
    }

    function setBuyTaxes(uint256[3] memory _buyTaxes) external onlyOwner {
        require(
            _buyTaxes[0] <= BPS_DENOMINATOR &&
                _buyTaxes[1] <= BPS_DENOMINATOR &&
                _buyTaxes[2] <= BPS_DENOMINATOR,
            "_buyTaxes cannot exceed BPS_DENOMINATOR"
        );
        emit BuyTaxesChanged(buyTaxes, _buyTaxes);
        buyTaxes = _buyTaxes;
    }

    function setSellTaxes(uint256[3] memory _sellTaxes) external onlyOwner {
        require(
            _sellTaxes[0] <= BPS_DENOMINATOR &&
                _sellTaxes[1] <= BPS_DENOMINATOR &&
                _sellTaxes[2] <= BPS_DENOMINATOR,
            "_sellTaxes cannot exceed BPS_DENOMINATOR"
        );
        emit SellTaxesChanged(sellTaxes, _sellTaxes);
        sellTaxes = _sellTaxes;
    }

    function setBuyAutoLiquidityTax(uint256 _buyAutoLiquidityTax)
        external
        onlyOwner
    {
        require(
            _buyAutoLiquidityTax <= BPS_DENOMINATOR,
            "_buyAutoLiquidityTax cannot exceed BPS_DENOMINATOR"
        );
        emit BuyAutoLiquidityTaxChanged(
            buyAutoLiquidityTax,
            _buyAutoLiquidityTax
        );
        buyAutoLiquidityTax = _buyAutoLiquidityTax;
    }

    function setSellAutoLiquidityTax(uint256 _sellAutoLiquidityTax)
        external
        onlyOwner
    {
        require(
            _sellAutoLiquidityTax <= BPS_DENOMINATOR,
            "_sellAutoLiquidityTax cannot exceed BPS_DENOMINATOR"
        );
        emit SellAutoLiquidityTaxChanged(
            sellAutoLiquidityTax,
            _sellAutoLiquidityTax
        );
        sellAutoLiquidityTax = _sellAutoLiquidityTax;
    }

    function setMinTokenBalance(uint256 _minTokenBalance) external onlyOwner {
        emit MinTokenBalanceChanged(minTokenBalance, _minTokenBalance);
        minTokenBalance = _minTokenBalance;
    }

    function setPermissions(IPermissions _permissions) external onlyOwner {
        emit PermissionsChanged(address(permissions), address(_permissions));
        permissions = _permissions;
    }

    function setCooldown(uint256 _cooldown) external onlyOwner {
        emit CooldownChanged(cooldown, _cooldown);
        cooldown = _cooldown;
    }

    function rescueTaxTokens(
        uint256 _index,
        uint256 _amount,
        address _recipient
    ) external onlyOwner {
        require(0 <= _index && _index < totalTaxes.length, "_index OOB");
        require(
            _amount <= totalTaxes[_index],
            "Amount cannot be greater than totalTax"
        );
        _rawTransfer(address(this), _recipient, _amount);
        emit TaxesRescued(_index, _amount);
        totalTaxes[_index] -= _amount;
    }

    function rescueAutoLiquidityTaxTokens(uint256 _amount, address _recipient)
        external
        onlyOwner
    {
        require(
            _amount <= totalAutoLiquidityTax,
            "Amount cannot be greater than totalAutoLiquidityTax"
        );
        _rawTransfer(address(this), _recipient, _amount);
        emit AutoLiquidityTaxRescued(_amount);
        totalAutoLiquidityTax -= _amount;
    }

    function addLiquidity(uint256 tokens)
        external
        payable
        onlyOwner
        liquidityAdd
    {
        _mint(address(this), tokens);
        _approve(address(this), address(_router), tokens);

        _router.addLiquidityETH{value: msg.value}(
            address(this),
            tokens,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function setTradingActive(bool _tradingActive) external onlyOwner {
        tradingActive = _tradingActive;
        emit TradingActiveChanged(_tradingActive);
    }

    function setTaxExcluded(address _account, bool _taxExcluded)
        external
        onlyOwner
    {
        taxExcluded[_account] = _taxExcluded;
        emit TaxExclusionChanged(_account, _taxExcluded);
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function _addBalance(address account, uint256 amount) internal {
        _balances[account] = _balances[account] + amount;
    }

    function _subtractBalance(address account, uint256 amount) internal {
        _balances[account] = _balances[account] - amount;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        if (taxExcluded[sender] || taxExcluded[recipient]) {
            _rawTransfer(sender, recipient, amount);
            return;
        }

        uint256 swapAmount = totalTaxes[0].add(totalTaxes[1]).add(
            totalTaxes[2]
        );
        bool overMinTokenBalance = swapAmount >= minTokenBalance;

        if (overMinTokenBalance && !_inSwap && sender != _pair && swapFees) {
            _swap();
        }

        uint256 send = amount;
        uint256[3] memory taxes;
        uint256 autoLiquidityTax;
        if (sender == _pair) {
            if (address(permissions) != address(0)) {
                require(
                    permissions.isWhitelisted(recipient),
                    "User is not whitelisted to buy"
                );
                require(
                    amount <= permissions.buyLimit(recipient),
                    "User buying more than his/her buyLimit"
                );
            }
            require(tradingActive, "Trading is not yet active");
            (send, taxes, autoLiquidityTax) = _getTaxAmounts(amount, true);
        } else if (recipient == _pair) {
            require(tradingActive, "Trading is not yet active");
            if (address(permissions) != address(0)) {
                require(
                    permissions.isWhitelisted(sender),
                    "User is not whitelisted to sell"
                );
            }
            (send, taxes, autoLiquidityTax) = _getTaxAmounts(amount, false);
        }
        _rawTransfer(sender, recipient, send);
        _takeTaxes(sender, taxes, autoLiquidityTax);
    }

    function _swap() internal lockSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        uint256 autoLiquidityAmount = totalAutoLiquidityTax.div(2);
        uint256 walletTaxes = totalTaxes[0].add(totalTaxes[1]).add(
            totalTaxes[2]
        );
        uint256 totalSwapAmount = walletTaxes.add(autoLiquidityAmount);

        _approve(
            address(this),
            address(_router),
            totalAutoLiquidityTax.add(walletTaxes)
        );
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            totalSwapAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        uint256 contractEthBalance = address(this).balance;

        uint256 tax0Eth = contractEthBalance.mul(totalTaxes[0]).div(
            totalSwapAmount
        );
        uint256 tax1Eth = contractEthBalance.mul(totalTaxes[1]).div(
            totalSwapAmount
        );
        uint256 tax2Eth = contractEthBalance.mul(totalTaxes[2]).div(
            totalSwapAmount
        );
        uint256 autoLiquidityEth = contractEthBalance
            .mul(autoLiquidityAmount)
            .div(totalSwapAmount);
        totalTaxes = [0, 0, 0];
        totalAutoLiquidityTax = 0;

        if (tax0Eth > 0) {
            taxWallets[0].transfer(tax0Eth);
        }
        if (tax1Eth > 0) {
            taxWallets[1].transfer(tax1Eth);
        }
        if (tax2Eth > 0) {
            taxWallets[2].transfer(tax2Eth);
        }
        if (autoLiquidityEth > 0) {
            _router.addLiquidityETH{value: autoLiquidityEth}(
                address(this),
                autoLiquidityAmount,
                0,
                0,
                address(0),
                block.timestamp
            );
        }
    }

    function swapAll() external {
        if (!_inSwap) {
            _swap();
        }
    }

    function withdrawAll() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function _takeTaxes(
        address _account,
        uint256[3] memory _taxAmounts,
        uint256 _autoLiquidityTaxAmount
    ) internal {
        require(_account != address(0), "taxation from the zero address");

        uint256 totalAmount = _taxAmounts[0]
            .add(_taxAmounts[1])
            .add(_taxAmounts[2])
            .add(_autoLiquidityTaxAmount);
        _rawTransfer(_account, address(this), totalAmount);
        totalTaxes[0] += _taxAmounts[0];
        totalTaxes[1] += _taxAmounts[1];
        totalTaxes[2] += _taxAmounts[2];
        totalAutoLiquidityTax += _autoLiquidityTaxAmount;
    }

    function _getTaxAmounts(uint256 amount, bool buying)
        internal
        view
        returns (
            uint256 send,
            uint256[3] memory taxes,
            uint256 autoLiquidityTax
        )
    {
        if (buying) {
            taxes = [
                amount.mul(buyTaxes[0]).div(BPS_DENOMINATOR),
                amount.mul(buyTaxes[1]).div(BPS_DENOMINATOR),
                amount.mul(buyTaxes[2]).div(BPS_DENOMINATOR)
            ];
            autoLiquidityTax = amount.mul(buyAutoLiquidityTax).div(
                BPS_DENOMINATOR
            );
        } else {
            taxes = [
                amount.mul(sellTaxes[0]).div(BPS_DENOMINATOR),
                amount.mul(sellTaxes[1]).div(BPS_DENOMINATOR),
                amount.mul(sellTaxes[2]).div(BPS_DENOMINATOR)
            ];
            autoLiquidityTax = amount.mul(sellAutoLiquidityTax).div(
                BPS_DENOMINATOR
            );
        }
        send = amount.sub(taxes[0]).sub(taxes[1]).sub(taxes[2]).sub(
            autoLiquidityTax
        );
    }

    function _rawTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "transfer from the zero address");
        require(recipient != address(0), "transfer to the zero address");

        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount, "transfer amount exceeds balance");
        unchecked {
            _subtractBalance(sender, amount);
        }
        _addBalance(recipient, amount);

        emit Transfer(sender, recipient, amount);
    }

    function setSwapFees(bool _swapFees) external onlyOwner {
        swapFees = _swapFees;
        emit SwapFeesChanged(_swapFees);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function _mint(address account, uint256 amount) internal override {
        require(_totalSupply.add(amount) <= MAX_SUPPLY, "Max supply exceeded");
        _totalSupply += amount;
        _addBalance(account, amount);
        emit Transfer(address(0), account, amount);
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function airdrop(address[] memory accounts, uint256[] memory amounts)
        external
        onlyOwner
    {
        require(accounts.length == amounts.length, "array lengths must match");

        for (uint256 i = 0; i < accounts.length; i++) {
            _mint(accounts[i], amounts[i]);
        }
    }

    receive() external payable {}
}