
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
}
pragma solidity ^0.8.0;

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

}pragma solidity ^0.8.0;


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

}pragma solidity ^0.8.0;

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

}pragma solidity ^0.8.0;

interface ILiquidityProtection {

    function liquidityAdded(
        uint _liquidity_block_number,
        uint _added_liquidity_amount,
        bool _IDOFactoryEnabled,
        uint _IDONumber,
        uint _IDOBlocks,
        uint _IDOParts,
        bool _firstBlockProtectionEnabled,
        bool _blockProtectionEnabled,
        uint _blocksToProtect,
        address _token
        ) external;

    function updateIDOPartAmount(address _from, uint _amount) external returns(bool);

    function verifyAmountPercent(uint _amount, uint _amountProtectorPercent) external view returns (bool);

    function verifyBlockNumber() external view returns(bool);

    function verifyFirstBlock() external view returns (bool);

    function verifyPriceAffect(address _from, uint _amount, uint _priceAfeectValue) external returns(bool);

    function updateRateLimitProtector(address _from, address _to, uint _rateLimitTime) external returns(bool);

    function verifyBlockedAddress(address _from, address _to) external view returns (bool);

    function blockAddress(address _address) external;

    function blockAddresses(address[] memory _addresses) external;

    function unblockAddress(address _address) external;

    function unblockAddresses(address[] memory _addresses) external;

}pragma solidity ^0.8.0;

abstract contract UsingSmartStateProtection {

    bool internal protected = false;
    address internal pair;
    mapping(address => bool) public excludedBuy;
    mapping(address => bool) public excludedSell;
    mapping(address => bool) public excludedTransfer;

    function protectionService() internal view virtual returns(address);
    function isAdmin() internal view virtual returns(bool);
    function ps() internal view returns(ILiquidityProtection) {
        return ILiquidityProtection(protectionService());
    }
    
    function disableProtection() public {
        require(isAdmin());
        protected = false;
    }

    function enableProtection() public {
        require(isAdmin());
        protected = true;

    }

    function isProtected() public view returns(bool) {
        return protected;
    }

    function firstBlockProtectionEnabled() internal pure virtual returns(bool) {
        return false;
    }

    function blockProtectionEnabled() internal pure virtual returns(bool) {
        return false;
    }

    function blocksToProtect() internal pure virtual returns(uint) {
        return 69; //can't buy tokens for 7 blocks
    }

    function amountPercentProtectionEnabled() internal pure virtual returns(bool) {
        return false;
    }

    function amountPercentProtection() internal pure virtual returns(uint) {
        return 5; //can't buy more than 5 percent at once
    }

    function priceChangeProtectionEnabled() internal pure virtual returns(bool) {
        return false;
    }

    function priceProtectionPercent() internal pure virtual returns(uint) {
        return 5; //price can't change for more than 5 percent during 1 transaction
    }

    function rateLimitProtectionEnabled() internal pure virtual returns(bool) {
        return false;
    }

    function rateLimitProtection() internal pure virtual returns(uint) {
        return 60; //user can make only one transaction per minute
    }

    function IDOFactoryEnabled() internal pure virtual returns(bool) {
        return false;
    }

    function IDOFactoryBlocks() internal pure virtual returns(uint) {
        return 30; //blocks for ido factory
    }

    function IDOFactoryParts() internal pure virtual returns(uint) {
        return 3; //blocks should be devidable by parts
    }

    function blockSuspiciousAddresses() internal pure virtual returns(bool) {
        return false;
    }

    function blockAddress(address _address) external {
        require(isAdmin());
        ps().blockAddress(_address);

    }

    function blockAddresses(address[] memory _addresses) external {
        require(isAdmin());
        ps().blockAddresses(_addresses);
    }

    function unblockAddress(address _address) external {
        require(isAdmin());
        ps().unblockAddress(_address);
    }

    function unblockAddresses(address[] memory _addresses) external {
        require(isAdmin());
        ps().unblockAddresses(_addresses);
    }
    
    function excludeBuy(address[] memory _users) external {
        require(isAdmin());
        for (uint i = 0; i < _users.length; i ++) {
            excludedBuy[_users[i]] = true;
        }
    }
    
    function includeBuy(address[] memory _users) external {
        require(isAdmin());
        for (uint i = 0; i < _users.length; i ++) {
            excludedBuy[_users[i]] = false;
        }
    }
    
    function excludeSell(address[] memory _users) external {
        require(isAdmin());
        for (uint i = 0; i < _users.length; i ++) {
            excludedSell[_users[i]] = true;
        }
    }
    
    function includeSell(address[] memory _users) external {
        require(isAdmin());
        for (uint i = 0; i < _users.length; i ++) {
            excludedSell[_users[i]] = false;
        }
    }
    
    function excludeTransfer(address[] memory _users) external {
        require(isAdmin());
        for (uint i = 0; i < _users.length; i ++) {
            excludedTransfer[_users[i]] = true;
        }
    }
    
    function includeTransfer(address[] memory _users) external {
        require(isAdmin());
        for (uint i = 0; i < _users.length; i ++) {
            excludedTransfer[_users[i]] = false;
        }
    }
    
    function setPair(address _pair) internal {
        pair = _pair;
    }
    
    function protectionBeforeTokenTransfer(address _from, address _to, uint _amount) internal {
        if (protected && _from == pair && excludedBuy[_to]) {
            return;
        }
        if (protected && _to == pair && excludedSell[_from]) {
            return;
        }
        if (protected && _to != pair && _from != pair && excludedTransfer[_from]) {
            return;
        }
        if (protected) {
            require(!firstBlockProtectionEnabled() || !ps().verifyFirstBlock(), "First Block Protector");
            require(!blockProtectionEnabled() || !ps().verifyBlockNumber(), "Block Protector");
            require(!amountPercentProtectionEnabled() || !ps().verifyAmountPercent(_amount, priceProtectionPercent()), "Amount Protector");
            require(!priceChangeProtectionEnabled() || !ps().verifyPriceAffect(_from, _amount, priceProtectionPercent()), "Percent protector");
            require(!IDOFactoryEnabled() || !ps().updateIDOPartAmount(_from, _amount), "IDO protector");
            require(!rateLimitProtectionEnabled() || !ps().updateRateLimitProtector(_from, _to, rateLimitProtection()), "Rate limit protector");
            require(!blockSuspiciousAddresses() || !ps().verifyBlockedAddress(_from, _to), "Blocked address protector");
        }
    }
}pragma solidity ^0.8.0;


contract PuppyToken is IERC20, Ownable, UsingSmartStateProtection {


    address UniswapPair;
    IUniswapV2Router02 UniswapV2Router;
    address internal protection_service;

    mapping (address => uint256) private _rOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 public constant _tTotal = 1e15 * 1e9; //1 quadrillion
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    bool public _feesEnabled = true;
    event FeesChanged(bool status);

    string private _name = 'Puppies Network';
    string private _symbol = 'PPN';
    uint8 private _decimals = 9;
    

    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        UniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        UniswapPair = IUniswapV2Factory(UniswapV2Router.factory())
            .createPair(address(this), UniswapV2Router.WETH());
        setPair(UniswapPair);
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    
    receive() external payable {}
    
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

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return tokenFromReflection(_rOwned[account]);
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

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function totalFees() external view returns (uint256) {

        return _tFeeTotal;
    }

    function disableFees() external onlyOwner {

        _feesEnabled = false;
        emit FeesChanged(false);
    }

    function enableFees() external onlyOwner {

        _feesEnabled = true;
        emit FeesChanged(true);
    }

    function reflect(uint256 tAmount) external {

        require(_feesEnabled, "Not allowed");
        address sender = _msgSender();
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns(uint256) {

        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (_feesEnabled) {
            if (sender != address(this)) {
                _beforeTokenTransfer(sender, recipient, amount);
            }
            if (recipient == UniswapPair && sender != address(this)) {
                _transferWithFee(sender, recipient, amount);
            } else {
                 _transferWithoutFee(sender, recipient, amount);
            }
        } else {
            if (sender != address(this)) {
                _beforeTokenTransfer(sender, recipient, amount);
            }
            _transferWithoutFee(sender, recipient, amount);
        }
    }

    function _transferWithFee(address sender, address recipient, uint256 tAmount) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _liquify(rFee);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferWithoutFee(address sender, address recipient, uint256 tAmount) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount + rFee; 
        emit Transfer(sender, recipient, tAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {

        _rTotal = _rTotal - rFee * 2 / 5;
        _tFeeTotal = _tFeeTotal + tFee;
    }
    
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {

        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }

    function _getTValues(uint256 tAmount) private pure returns (uint256, uint256) {

        uint256 tFee = tAmount * 5 / 100;
        uint256 tTransferAmount = tAmount - tFee;
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {

        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rTransferAmount = rAmount - rFee;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {

        return (_rTotal, _tTotal);
    }
    
    function _liquify(uint256 rFee) private {

        _rOwned[address(this)] += rFee * 3 / 5;
        uint _tokenAmount = tokenFromReflection(rFee * 3 / 5);
        uint half = _tokenAmount / 2;
        uint anotherHalf = _tokenAmount - half;
        _approve(address(this), address(UniswapV2Router), half);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = UniswapV2Router.WETH();
        uint balanceBefore = address(this).balance;
        UniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            half,
            0, //accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        uint balanceAfter = address(this).balance;
        _approve(address(this), address(UniswapV2Router), anotherHalf);
        UniswapV2Router.addLiquidityETH{value: balanceAfter - balanceBefore}(
            address(this),
            anotherHalf,
            0,
            0,
            owner(),
            block.timestamp
        );
    }
    
    function addLiquidityETH(
        uint _amountTokenDesired,
        uint _amountTokenMin,
        uint _amountETHMin,
        address _to,
        uint _deadline
    ) external onlyOwner {

        _approve(address(this), address(UniswapV2Router), _amountTokenDesired);
        UniswapV2Router.addLiquidityETH{value: _amountETHMin}(
            address(this),
            _amountTokenDesired,
            _amountTokenMin,
            _amountETHMin,
            _to,
            _deadline
        );
    }
    
    function addLiquidityETHAndEnableProtection(
        uint _amountTokenDesired,
        uint _amountTokenMin,
        uint _amountETHMin,
        address _to,
        uint _deadline,
        uint _IDONumber)
        external payable onlyOwner {

            _approve(address(this), address(UniswapV2Router), _amountTokenDesired);
            UniswapV2Router.addLiquidityETH{value: msg.value}(
                address(this),
                _amountTokenDesired,
                _amountTokenMin,
                _amountETHMin,
                _to,
                _deadline);
            ps().liquidityAdded(
                block.number,
                _amountTokenMin,
                IDOFactoryEnabled(),
                _IDONumber,
                IDOFactoryBlocks(),
                IDOFactoryParts(),
                firstBlockProtectionEnabled(),
                blockProtectionEnabled(),
                blocksToProtect(),
                address(this));
            enableProtection();
    }
    
    function _beforeTokenTransfer(address _from, address _to, uint _amount) internal {

        protectionBeforeTokenTransfer(_from, _to, _amount);
    }

    function isAdmin() internal view override returns(bool) {

        return msg.sender == owner() || msg.sender == address(this); //replace with correct value
    }

    function setProtectionService(address _ps) external onlyOwner {

        protection_service = _ps;
    }

    function protectionService() internal view override returns(address) {

        return protection_service;
    }

    function firstBlockProtectionEnabled() internal pure override returns(bool) {

        return true; //set true or false
    }

    function blockProtectionEnabled() internal pure override returns(bool) {

        return true; //set true or false
    }
    
    function blocksToProtect() internal pure override returns(uint) {

        return 69; //replace with correct value
    }
    
    function amountPercentProtectionEnabled() internal pure override returns(bool) {

        return true; //set true or false
    }
    
    function amountPercentProtection() internal pure override returns(uint) {

        return 5; //replace with correct value
    }
    
    function IDOFactoryEnabled() internal pure override returns(bool) {

        return true; //set true or false
    }

    function priceChangeProtectionEnabled() internal pure override returns(bool) {

        return false; //set true or false
    }
    
    function priceProtectionPercent() internal pure override returns(uint) {

        return 5; //replace with correct value
    }
    
    function rateLimitProtectionEnabled() internal pure override returns(bool) {

        return true; //set true or false
    }
    
    function rateLimitProtection() internal pure override returns(uint) {

        return 60; //replace with correct value
    }
    
    function IDOFactoryBlocks() internal pure override returns(uint) {

        return 30; //replace with correct value
    }

    function IDOFactoryParts() internal pure override returns(uint) {

        return 3; //replace with correct value
    }
    
    function blockSuspiciousAddresses() internal pure override returns(bool) {

        return true; //set true or false
    }
}
    