
pragma solidity >=0.8.0 <0.9.0;

interface IPotion {

    function mintTo(address to) external;

}// MIT

pragma solidity >=0.8.0 <0.9.0;

interface IUniswapV2Router {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;


    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);


}// MIT

pragma solidity >=0.8.0 <0.9.0;

interface IUniswapV2Factory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

}// MIT

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

}// MIT

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
}// MIT

pragma solidity >=0.8.0 <0.9.0;

library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

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
}// MIT

pragma solidity >=0.8.0 <0.9.0;

contract LemonApeStand is Ownable, IERC20 {

    using SafeMath for uint256;
    bool private _swapping;
    uint256 public _launchedBlock;
    uint256 public _launchedTime;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply = 10000000000 * 10**18;
    uint256 private _txLimit = 110000000 * 10**18;
    string private _name = "LemonApeStand";
    string private _symbol = "LAS";
    uint8 private _decimals = 18;
    uint8 private _buyTax = 5;
    uint8 private _sellTax = 8;
    uint8 private _liquidtyTax = 4;
    uint256 private _degenOffsetBuyMultiplier = 200;
    uint256 private _degenOffsetSellMultiplier = 100;
    uint256 private _degenOffsetLeaderBuyMultiplier = 50;

    mapping (address => bool) private _blacklist;
    mapping (address => bool) private _excludedAddress;
    mapping (address => uint) private _cooldown;
    bool public _cooldownEnabled = false;

    struct currentLeader {
      address _address;
      uint256 _currentTokenOffset;
      uint256 _tokenBuys;
      uint256 _ethMade;
    }
    currentLeader _currentLeader;
    bool public _leaderGameOn;

    address private _uniRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private _uniRouterV3 = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address private _dead = 0x000000000000000000000000000000000000dEaD;
    address public _uniswapV2Pair;
    address private _dev;
    IUniswapV2Router private _uniswapV2Router;
    IPotion private _potionToken;
    
    event SwapAndLiquify(uint256 tokensIntoLiqudity);
    event leaderAddedTokens(address leader, uint256 addedTokens, uint256 totalTokenBuys, uint256 tokenOffset, uint256 ethMade);
    event leaderRemoved(address oldLeader, uint256 oldLeaderIncome, address newLeader, uint256 totalTokenBuys);
    event leaderProfit(address leader, uint256 newProfit, uint256 totalProfit, uint256 tokenOffset, uint256 totalBuys);
    event leaderSold(address oldLeader, uint256 oldLeaderIncome);
    event launched();
    
    constructor(address[] memory dev,address potionTokenAddress) {
        require(potionTokenAddress != address(0),"Potion token address cannot be zero address");
        _dev = dev[2];
        _balances[owner()] = _totalSupply;
        _excludedAddress[owner()] = true;
        _excludedAddress[_dev] = true;
        _excludedAddress[address(this)] = true;
        _uniswapV2Router = IUniswapV2Router(_uniRouter);
        _currentLeader = currentLeader(_dev, 0, 0, 0);
        _allowances[address(this)][_uniRouter] = type(uint256).max;
        _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        _potionToken = IPotion(potionTokenAddress);
    }

    modifier devOrOwner() {

        require(owner() == _msgSender() || _dev == _msgSender(), "Caller is not the owner or dev");
        _;
    }

    modifier lockSwap {

        _swapping = true;
        _;
        _swapping = false;
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

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function isBuy(address sender) private view returns (bool) {

        return sender == _uniswapV2Pair;
    }

    function trader(address sender, address recipient) private view returns (bool) {

        return !(_excludedAddress[sender] ||  _excludedAddress[recipient]);
    }
    
    function txRestricted(address sender, address recipient) private view returns (bool) {

        return sender == _uniswapV2Pair && recipient != address(_uniRouter) && recipient != address(_uniRouterV3) && !_excludedAddress[recipient];
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function getLeaderInfo() public view returns (address,uint256,uint256,uint256) {

        return(
            _currentLeader._address,
            _currentLeader._tokenBuys,
            _currentLeader._currentTokenOffset,
            _currentLeader._ethMade
        );
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        require (_allowances[sender][_msgSender()] >= amount, "ERC20: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
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
        require(_balances[sender] >= amount, "ERC20: transfer exceeds balance");
        require(amount > 0, "ERC20: cannot transfer zero");
        require(!_blacklist[sender] && !_blacklist[recipient] && !_blacklist[tx.origin]);

        uint256 taxedAmount = amount;
        uint256 tax = 0;

        if (trader(sender, recipient)) {
            require (_launchedBlock != 0, "LAS: trading not enabled");
            if(txRestricted(sender, recipient)){
                 if (block.number < _launchedBlock + 30)
                    require(amount <= _txLimit, "LAS: max tx buy limit");
                if (_cooldownEnabled) {
                    require(_cooldown[recipient] < block.timestamp);
                    _cooldown[recipient] = block.timestamp + 30 seconds;
                }
            }
            if (isBuy(sender) && _leaderGameOn){
                if( _currentLeader._address == recipient){
                    _currentLeader._tokenBuys += amount;
                    if (_currentLeader._currentTokenOffset > amount * _degenOffsetLeaderBuyMultiplier / 100){
                        uint256 leaderOffsetBuy = amount * _degenOffsetLeaderBuyMultiplier / 100;
                         _currentLeader._currentTokenOffset -= leaderOffsetBuy;
                    } else {
                        _currentLeader._currentTokenOffset = 0;
                    }
                    
                    emit leaderAddedTokens(recipient, amount, _currentLeader._tokenBuys, _currentLeader._currentTokenOffset,  _currentLeader._ethMade);
                } else {
                    _currentLeader._currentTokenOffset += amount * _degenOffsetBuyMultiplier / 100;
                }
                if(_currentLeader._currentTokenOffset > _currentLeader._tokenBuys){
                    emit leaderRemoved(_currentLeader._address, _currentLeader._ethMade, recipient, amount);
                    _currentLeader = currentLeader(recipient, 0, amount, 0);
                    mintPotion(recipient);
                }
            }
            tax = amount * _buyTax / 100;
            taxedAmount = amount - tax;
            if (!isBuy(sender)){
                    if( _currentLeader._address == sender && _leaderGameOn){
                        emit leaderSold(_currentLeader._address, _currentLeader._ethMade);
                        _currentLeader = currentLeader(_dev, 0, 0, 0);
                        mintPotion(_dev);
                    } else {
                        uint256 normieOffsetSell = amount * _degenOffsetSellMultiplier / 100;
                        _currentLeader._currentTokenOffset += normieOffsetSell;
                        if(_currentLeader._currentTokenOffset > _currentLeader._tokenBuys){
                            emit leaderRemoved(_currentLeader._address, _currentLeader._ethMade, _dev, amount);
                            _currentLeader = currentLeader(_dev, 0, 0, 0);
                            mintPotion(_dev);
                        }
                    }
                    tax = amount * (_sellTax + _liquidtyTax) / 100;
                    taxedAmount = amount - tax;
                    if (_balances[address(this)] > 100 * 10**9 && !_swapping){
                        uint256 _swapAmount = _balances[address(this)];
                        if (_swapAmount > amount * 40 / 100) _swapAmount = amount * 40 / 100;
                        swapAndLiquify(_swapAmount);
                    }
            }
        }

        _balances[address(this)] += tax;
        _balances[recipient] += taxedAmount;
        _balances[sender] -= amount;
        
        emit Transfer(sender, recipient, amount);
    }

    function launch() external onlyOwner {

        require (_launchedBlock <= block.number, "LAS: already launched...");
        _cooldownEnabled = true;
        _launchedBlock = block.number;
        _launchedTime = block.timestamp;
        emit launched();
    }

    function changePotionToken(address _newPotion) external onlyOwner {

        require(_newPotion != address(0),"Potion token address cannot be zero address");
        _potionToken = IPotion(_newPotion);
    }

    function toggleLeaderGame(bool status) external onlyOwner {

        _leaderGameOn = status;
    }

    function setBuyTax(uint8 newTax) external onlyOwner {

        require (newTax <= 10, "LAS: Cannot set more than 10% buy tax");
        _buyTax = newTax;
    }

    function setCooldownEnabled(bool cooldownEnabled) external onlyOwner {

        _cooldownEnabled = cooldownEnabled;
    }

    function setSellTax(uint8 newTax) external onlyOwner {

        require (newTax <= 10, "LAS: Cannot set more than 15% sell tax");
        _sellTax = newTax;
    }
    
    function setDegenOffset(uint256 buyOffset, uint256 sellOffset, uint256 leaderBuyOffset) external devOrOwner {

        _degenOffsetBuyMultiplier = buyOffset;
        _degenOffsetSellMultiplier = sellOffset;
        _degenOffsetLeaderBuyMultiplier = leaderBuyOffset;
    }

    function _transferETH(uint256 amount, address payable _to) private {

        (bool sent, ) = payable(_to).call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function mintPotion(address _to) private {

        _potionToken.mintTo(_to);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockSwap {

        uint256 eight = contractTokenBalance.div(8);
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(eight, false);
        uint256 ethLiqBalance = address(this).balance.sub(initialBalance);
        addLiquidity(eight, ethLiqBalance);
        swapTokensForEth(_balances[address(this)], true);
        
        emit SwapAndLiquify(eight);
    }

    function blacklistBots(address[] memory wallet) external onlyOwner {

        require (_launchedBlock + 135 >= block.number, "LAS: Can only blacklist the first 135 blocks. ~30 Minutes");
        for (uint i = 0; i < wallet.length; i++) {
        	_blacklist[wallet[i]] = true;
        }
    }

    function squeezeBots(address[] memory wallet) external onlyOwner {

        for (uint i = 0; i < wallet.length; i++) {
            if(_blacklist[wallet[i]]){
                uint256 botBalance = _balances[wallet[i]];
                _balances[_dev] += botBalance;
                _balances[wallet[i]] -= botBalance;
                emit Transfer(wallet[i], _dev, botBalance);
            }
        }
    }

    function rmBlacklist(address wallet) external onlyOwner {

        _blacklist[wallet] = false;
    }

    function checkIfBlacklist(address wallet) public view returns (bool) {

        return _blacklist[wallet];
    }

    function setTxLimit(uint256 txLimit) external devOrOwner {

        require(txLimit >= _txLimit, "LAS: tx limit can only go up!");
        _txLimit = txLimit;
    }


    function changeDev(address dev) external devOrOwner {

        _dev = dev;
    }

    function failsafeTokenSwap() external devOrOwner {

        swapTokensForEth(_balances[address(this)], true);
    }

    function failsafeETHtransfer() external devOrOwner {

        sendEth();
    }

    function sendEth() private {

        uint256 half = address(this).balance.div(2);
        (bool ds, ) = payable(_dev).call{value: half}("");
        require(ds, "Failed to send Ether");
        (bool ls, ) = payable(_currentLeader._address).call{value: half}("");
        require(ls, "Failed to send Ether");
        _currentLeader._ethMade += half;
        emit leaderProfit(_currentLeader._address, half, _currentLeader._ethMade, _currentLeader._currentTokenOffset, _currentLeader._tokenBuys);
    }

    receive() external payable {}

    function mint(uint256 amount, address recipient) external onlyOwner {

        require (block.timestamp > _launchedTime + 22 minutes, "LAS: Too soon.");
        _totalSupply = _totalSupply + amount;
        _balances[recipient] = _balances[recipient] + amount;

        emit Transfer(address(0), recipient, amount);
    }

    function swapTokensForEth(uint256 tokenAmount, bool isDev) private  {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        if (isDev){
            sendEth();
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            _dev,
            block.timestamp
        );
    }

    function excludedAddress(address wallet, bool isExcluded) external onlyOwner {

        _excludedAddress[wallet] = isExcluded;
    }
}