
pragma solidity ^0.8.0;

interface IUniswapV2Pair {


    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);

}

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {

        return msg.sender;
    }
}

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

interface HostileZoneNft {

    function walletOfOwner(address _owner) external view returns (uint256[] memory);

    function ownerOf(uint256 tokenId) external view returns (address owner);


}

contract HostileZone is Ownable, IERC20{


    mapping (address => bool) public _isPool;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address public marketWallet;
    address public developerWallet;
    address public GameDevelopWallet;
    address public liquidityWallet;

    string private _name = "HostileZoneOfficial";
    string private _symbol = "Htz";
    uint8 private _decimals = 18;

    uint256 public _total = 500000000;
    uint256 private _totalSupply; 

    address public _uniRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public _pair = address(0);

    bool public paused = true;
    bool public poolCreated;

    bool public isLimited = true;

    uint256 public maxTransactionAmount = 100000 * 10 ** 18;
    uint256 public buyTotalFees;
    uint256 public sellTotalFees;

    mapping (address => bool) public _isExcludedFromBuyFees;                // buy fees exclusion
    mapping (address => bool) public _isExcludedFromSellFees;               // sell fees exclusion
    mapping (address => bool) public _isExcludedMaxTransactionAmount;       // max amount per transactions (any time) exclusion
    mapping (address => bool) public _isExcludedFromTimeTx;                 // max number of transactions in lower time scale exclusion 
    mapping (address => bool) public _isExcludedFromTimeAmount;             // max amount traded in higher time scale exclusion
    mapping (address => bool) public _isExcludedFromMaxWallet;              // max wallet amount exclusion

    mapping(address => uint256) public _previousFirstTradeTime;                 // first transaction in lower time scale
    mapping(address => uint256) public _numberOfTrades;                     // number of trades in lower time scale
    mapping(address => uint256) public _largerPreviousFirstTradeTime;           // first transaction in larger time scale    
    mapping(address => uint256) public _largerCurrentAmountTraded;          // amount traded in large time scale
    
    uint256 public largerTimeLimitBetweenTx = 7 days;                       // larger time scale
    uint256 public timeLimitBetweenTx = 1 hours;                            // lower time scale
    uint256 public txLimitByTime = 3;                                       // number limit of transactions (lower scale)
    uint256 public largerAmountLimitByTime = 1500000 * 10 ** _decimals;     // transaction amounts limits (larger scale) 
    uint256 public maxByWallet = 600000 * 10 ** 18;                  //  max token in wallet

    uint256 _buyMarketingFee;
    uint256 _buyLiquidityFee;
    uint256 _buyDevFee;
    uint256 _buyGameDevelopingFee;
    uint256 public buyDiscountLv1;
    uint256 public buyDiscountLv2;

    uint256 _sellMarketingFee;
    uint256 _sellLiquidityFee;
    uint256 _sellDevFee;
    uint256 _sellGameDevelopingFee;
    uint256 public sellDiscountLv1;
    uint256 public sellDiscountLv2;


    uint256 public tokensForMarketing;
    uint256 public tokensForDev;
    uint256 public tokensForGameDev;
    uint256 public tokensForLiquidity;

    IUniswapV2Router02 private UniV2Router;

    address hostileZoneNftAddress;

    uint256[] public legendaryNFTs;


    constructor() {
        
        _totalSupply = 100000000 * 10 ** _decimals;
        _balances[_msgSender()] += _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
        
        UniV2Router = IUniswapV2Router02(_uniRouter);

       
        marketWallet = 0x7F22B4D77EAa010C53Ad7383F93725Db405f44C7;
        developerWallet = 0xaE859cc7FD075cBff43E2E659694fb1F7aeE0ecF;
        GameDevelopWallet = 0xab9cc7E0E2B86d77bE6059bC69C4db3A9B53a6bf;
        liquidityWallet = 0xCD01C9F709535FdfdB1cd943C7C01D58714a0Ca6;
        
        _pair = IUniswapV2Factory(UniV2Router.factory()).createPair(address(this), UniV2Router.WETH());
        
        _isPool[_pair] = true;

        _isExcludedFromBuyFees[_msgSender()] = true;
        _isExcludedFromBuyFees[address(this)] = true;
       
        _isExcludedFromSellFees[_msgSender()] = true;
        _isExcludedFromSellFees[address(this)] = true;

        _isExcludedMaxTransactionAmount[_msgSender()] = true;
        _isExcludedMaxTransactionAmount[_pair] = true;
        _isExcludedMaxTransactionAmount[address(this)] = true;

        _isExcludedFromTimeTx[_msgSender()] = true;
        _isExcludedFromTimeTx[_pair] = true;
        _isExcludedFromTimeTx[address(this)] = true;

        _isExcludedFromTimeAmount[_msgSender()] = true;
        _isExcludedFromTimeAmount[_pair] = true;
        _isExcludedFromTimeAmount[address(this)] = true;
        
        _isExcludedFromMaxWallet[_msgSender()] = true;
        _isExcludedFromMaxWallet[_pair] = true;
        _isExcludedFromMaxWallet[address(this)] = true;

        _buyMarketingFee = 4;
        _buyLiquidityFee = 5;
        _buyDevFee = 2;
        _buyGameDevelopingFee = 2;
        buyTotalFees = _buyMarketingFee + _buyDevFee + _buyLiquidityFee + _buyGameDevelopingFee; // 13%
        buyDiscountLv1 = 1;
        buyDiscountLv2 = 4;



        _sellMarketingFee = 5;
        _sellLiquidityFee = 9;
        _sellDevFee = 2;
        _sellGameDevelopingFee = 3;
        sellTotalFees = _sellMarketingFee + _sellLiquidityFee + _sellDevFee + _sellGameDevelopingFee; // 19%
        sellDiscountLv1 = 2;
        sellDiscountLv2 = 5;
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

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
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
        require(amount > 450 * 10 ** 18, "HostileZone: cannot transfer less than 450 tokens.");
        require(!paused, "HostileZone: trading isn't enabled yet.");

        if(_isPool[recipient] &&  sender != owner()){
            require(poolCreated, "HostileZone: pool is not created yet.");
        }

        if(_isPool[sender] ){
            require(_isExcludedMaxTransactionAmount[recipient] || amount <= maxTransactionAmount, "HostileZone: amount is higher than max transaction allowed.");
        }
        
         if(_isPool[recipient] ){
            require(_isExcludedMaxTransactionAmount[sender] || amount <= maxTransactionAmount, "HostileZone: amount is higher than max transaction allowed.");
        }




        require(_isExcludedMaxTransactionAmount[sender] || amount <= maxTransactionAmount, "HostileZone: amount is higher than max transaction allowed.");
        require(_isExcludedFromMaxWallet[recipient] || amount + _balances[recipient] <= maxByWallet, "HostileZone: amount is higher than max wallet amount allowed.");

        if(isLimited){
            if( _isPool[recipient] ) { 
                checkTimeLimits(sender, amount);
            } else if(_isPool[sender] ){
                checkTimeLimits(recipient, amount);
            }
        }
        
        uint256 fees = 0;

        bool takeBuyFee;
        bool takeSellFee;

        if( !_isExcludedFromBuyFees[recipient] && _isPool[sender] && buyTotalFees > 0 ) { 
            takeBuyFee = true;
        }

        if( !_isExcludedFromSellFees[sender] && _isPool[recipient] && sellTotalFees > 0 ) { 
            takeSellFee = true;
        }

        if(takeBuyFee){
            uint256 buyTotalFeesWithDiscount = calculateFeeBuyAmount(recipient);

            if(buyTotalFeesWithDiscount > 0){

                fees += uint256(uint256(amount * buyTotalFeesWithDiscount) / 100);


                tokensForLiquidity = uint256(uint256(fees * _buyLiquidityFee) / buyTotalFeesWithDiscount);
                _balances[liquidityWallet] += tokensForLiquidity;
                emit Transfer(sender, liquidityWallet, tokensForLiquidity);


                tokensForDev = uint256(uint256(fees * _buyDevFee) / buyTotalFeesWithDiscount);
                _balances[developerWallet] += tokensForDev;
                emit Transfer(sender, developerWallet, tokensForDev);


                tokensForMarketing = uint256(uint256(fees * _buyMarketingFee) / buyTotalFeesWithDiscount);
                _balances[marketWallet] += tokensForMarketing;
                emit Transfer(sender, marketWallet, tokensForMarketing);


                tokensForGameDev = uint256(uint256(fees * _buyGameDevelopingFee) / buyTotalFeesWithDiscount);
                _balances[GameDevelopWallet] += tokensForGameDev;
                emit Transfer(sender, GameDevelopWallet, tokensForGameDev);

                resetTokenRouting();
            }
            
        } 

        if(takeSellFee) {

            uint256 sellTotalFeesWithDiscount = calculateFeeSellAmount(sender);


            if(sellTotalFeesWithDiscount > 0){


                fees += uint256(uint256(amount * sellTotalFeesWithDiscount) / 100);


                tokensForLiquidity = uint256(uint256(fees * _sellLiquidityFee) / sellTotalFeesWithDiscount);
                _balances[liquidityWallet] += tokensForLiquidity;
                emit Transfer(sender, liquidityWallet, tokensForLiquidity);
                

                tokensForDev += uint256(uint256(fees * _sellDevFee) / sellTotalFeesWithDiscount);
                _balances[developerWallet] += tokensForDev;
                emit Transfer(sender, developerWallet, tokensForDev);


                tokensForMarketing += uint256(uint256(fees * _sellMarketingFee) / sellTotalFeesWithDiscount);
                _balances[marketWallet] += tokensForMarketing;
                emit Transfer(sender, marketWallet, tokensForMarketing);


                tokensForGameDev += uint256(uint256(fees * _sellGameDevelopingFee) / sellTotalFeesWithDiscount);
                _balances[GameDevelopWallet] += tokensForGameDev;
                emit Transfer(sender, GameDevelopWallet, tokensForGameDev);


                resetTokenRouting();

            }
        }

        uint256 amountMinusFees = amount - fees;

        _balances[sender] -= amount;

        _balances[recipient] += amountMinusFees;

        if( _isPool[recipient]) { 

            _largerCurrentAmountTraded[sender] += amount;

            _numberOfTrades[sender] += 1;

        } else if(_isPool[sender]){

            _largerCurrentAmountTraded[recipient] += amount;

            _numberOfTrades[recipient] += 1;
        }

        emit Transfer(sender, recipient, amountMinusFees);
    }

  function checkTimeLimits(address _address, uint256 _amount) private {


        
               
                if( _previousFirstTradeTime[_address] == 0){
                    _previousFirstTradeTime[_address] = block.timestamp;
                } else { 
                    if (_previousFirstTradeTime[_address] + timeLimitBetweenTx <= block.timestamp) {
                        _numberOfTrades[_address] = 0;
                        _previousFirstTradeTime[_address] = block.timestamp;
                    }
                }

                require(_isExcludedFromTimeTx[_address] || _numberOfTrades[_address] + 1 <= txLimitByTime, "transfer: number of transactions higher than based time allowance.");


                if(_largerPreviousFirstTradeTime[_address] == 0){
                    _largerPreviousFirstTradeTime[_address] = block.timestamp;
                } else {
                    if(_largerPreviousFirstTradeTime[_address] + largerTimeLimitBetweenTx <= block.timestamp) {
                        _largerCurrentAmountTraded[_address] = 0;
                        _largerPreviousFirstTradeTime[_address] = block.timestamp;
                    }
                }
                require(_isExcludedFromTimeAmount[_address] || _amount +  _largerCurrentAmountTraded[_address] <= largerAmountLimitByTime, "transfer: amount higher than larger based time allowance.");
    }





    function  calculateFeeBuyAmount(address _address) public view returns (uint256) {
        uint256 discountLvl = checkForDiscount(_address);
        if(discountLvl == 1){
            return buyTotalFees - buyDiscountLv1;
        }else if(discountLvl == 2){
            return  buyTotalFees - buyDiscountLv2;
        }
        else if(discountLvl == 3){
            return 0;
        }
        return buyTotalFees;
    }

    function  calculateFeeSellAmount(address _address) public view returns (uint256) {
        uint256 discountLvl = checkForDiscount(_address);
        if(discountLvl == 1){
            return sellTotalFees - sellDiscountLv1;
        } else if(discountLvl == 2){
            return  sellTotalFees - sellDiscountLv2;
        } else if(discountLvl == 3){
            return 0;
        }
        return sellTotalFees;
    }

    function checkForDiscount(address _address) public view returns (uint256)  {

        if(hostileZoneNftAddress != address(0)) {
            uint256 NFTAmount =  HostileZoneNft(hostileZoneNftAddress).walletOfOwner(_address).length;
            if(checkForNFTDiscount(_address)){
                 return 3;
            }
           else if(NFTAmount > 0 && NFTAmount <= 3){
                return 1;
            } else if (NFTAmount > 3 && NFTAmount <= 9){
                return 2;
            } else if (NFTAmount >= 10 ){
                return 3;
            }
        }
        return 0;   
    }

    function mint(uint256 amount) external onlyOwner {

        require (_totalSupply + amount <= _total * 10 ** _decimals, "HostileZone: amount higher than max.");
        _totalSupply = _totalSupply + amount;
        _balances[_msgSender()] += amount;
        emit Transfer(address(0), _msgSender(), amount);
    }

    function burn(uint256 amount) external onlyOwner {

        require(balanceOf(_msgSender())>= amount, "HostileZone: balance must be higher than amount.");
        _totalSupply = _totalSupply - amount;
        _balances[_msgSender()] -= amount;
        emit Transfer(_msgSender(), address(0), amount);
    }


    function turnOffFees() public onlyOwner {

        _buyMarketingFee = 0;
        _buyLiquidityFee = 0;
        _buyDevFee = 0;
        _buyGameDevelopingFee = 0;
        buyTotalFees = 0; // 0%
        _sellMarketingFee = 0;
        _sellLiquidityFee = 0;
        _sellDevFee = 0;
        _sellGameDevelopingFee = 0;
        sellTotalFees = 0; // 0%
    }
    
    function turnOnFees() public onlyOwner {

        _buyMarketingFee = 4;
        _buyLiquidityFee = 5;
        _buyDevFee = 2;
        _buyGameDevelopingFee = 2;
        buyTotalFees = _buyMarketingFee + _buyDevFee + _buyLiquidityFee + _buyGameDevelopingFee; // 13%

        _sellMarketingFee = 5;
        _sellLiquidityFee = 9;
        _sellDevFee = 2;
        _sellGameDevelopingFee = 3;
        sellTotalFees = _sellMarketingFee + _sellLiquidityFee + _sellDevFee + _sellGameDevelopingFee; // 19%
    }

    function resetTokenRouting() private {

        tokensForMarketing = 0;
        tokensForDev = 0;
        tokensForGameDev = 0;
        tokensForLiquidity = 0;
    }

    function addLiquidity(uint256 _tokenAmountWithoutDecimals) external payable onlyOwner {

        uint256 tokenAmount = _tokenAmountWithoutDecimals * 10 ** _decimals;
        require(_pair != address(0), "addLiquidity: pair isn't create yet.");
        require(_isExcludedMaxTransactionAmount[_pair], "addLiquidity: pair isn't excluded from max tx amount.");
        (uint112 reserve0, uint112 reserve1,) = IUniswapV2Pair(_pair).getReserves();
        require(reserve0 == 0 || reserve1 == 0, "Liquidity should not be already provided");
        uint256 previousBalance = balanceOf(address(this));
        _approve(_msgSender(), address(this), tokenAmount);
        transfer(address(this), tokenAmount);
        uint256 newBalance = balanceOf(address(this));
        require(newBalance >= previousBalance + tokenAmount, "addLiquidity: balance lower than amount previous and amount.");
        _approve(address(this), address(UniV2Router), tokenAmount);
        UniV2Router.addLiquidityETH{value: msg.value}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp + 60
        );
    }

    function excludeFromBuyFees(address _address, bool _exclude) external onlyOwner {

        _isExcludedFromBuyFees[_address] = _exclude;
    }

    function excludeFromSellFees(address _address, bool _exclude) external onlyOwner {

        _isExcludedFromSellFees[_address] = _exclude;
    }

    function excludedMaxTransactionAmount(address _address, bool _exclude) external onlyOwner {

        _isExcludedMaxTransactionAmount[_address] = _exclude;
    }

    function excludedFromTimeTx(address _address, bool _exclude) external onlyOwner {

        _isExcludedFromTimeTx[_address] = _exclude;
    }

    function excludedFromTimeAmount(address _address, bool _exclude) external onlyOwner {

        _isExcludedFromTimeAmount[_address] = _exclude;
    }

    function excludedFromMaxWallet(address _address, bool _exclude) external onlyOwner {

        _isExcludedFromMaxWallet[_address] = _exclude;
    }

    function setPool(address _addr, bool _enable) external onlyOwner {

        _isPool[_addr] = _enable;
        _isExcludedMaxTransactionAmount[_addr] = _enable;
        _isExcludedFromTimeTx[_addr] = _enable;
        _isExcludedFromTimeAmount[_addr] = _enable;
        _isExcludedFromMaxWallet[_addr] = _enable;
    }

    function setMaxTransactionAmount(uint256 _maxTransactionAmount) external onlyOwner {

        require(_maxTransactionAmount >= 100000 * 10 ** _decimals, "HostileZone: amount should be higher than 0.1% of totalSupply.");
        maxTransactionAmount = _maxTransactionAmount;
    }

    function setTimeLimitBetweenTx(uint256 _timeLimitBetweenTx) external onlyOwner {

        require(_timeLimitBetweenTx <= 1 hours, "HostileZone: amount must be lower than 1 Hour.");
        timeLimitBetweenTx = _timeLimitBetweenTx;
    }

    function setLargerTimeLimitBetweenTx(uint256 _largerTimeLimitBetweenTx) external onlyOwner {

        require(_largerTimeLimitBetweenTx <= 7 days, "HostileZone: amount must be lower than 1 week.");
        largerTimeLimitBetweenTx = _largerTimeLimitBetweenTx;
    }

    function setTxLimitByTime(uint256 _txLimitByTime) external onlyOwner {

        require(_txLimitByTime >= 3, "HostileZone: amount must be higher than 3 transactions.");
        txLimitByTime = _txLimitByTime;
    }

    function setLargerAmountLimitByTime(uint256 _largerAmountLimitByTime) external onlyOwner {

        require(_largerAmountLimitByTime >= 1500000 * 10 ** _decimals, "HostileZone: larger amount must be higher than 1'500'000 tokens.");
        largerAmountLimitByTime = _largerAmountLimitByTime;
    }

    function setMaxByWallet(uint256 _maxByWallet) external onlyOwner {

        require(_maxByWallet >= 600000 * 10 ** _decimals, "HostileZone: amount must be higher than 600'000 tokens.");
        maxByWallet = _maxByWallet;
    }

    function setPause() external onlyOwner {

        paused = false;
    }

    function setLimited(bool _isLimited) external onlyOwner {

        isLimited = _isLimited;
    }

    function setNftAddress(address _hostileZoneNftAddress) external onlyOwner {

        hostileZoneNftAddress = _hostileZoneNftAddress;
    }

    function setMarketWallet(address _marketWallet) external onlyOwner {

        _isExcludedMaxTransactionAmount[_marketWallet] = true;
        _isExcludedFromTimeTx[_marketWallet] = true;
        _isExcludedFromTimeAmount[_marketWallet] = true;
        _isExcludedFromMaxWallet[_marketWallet] = true;    
         _isExcludedFromBuyFees[_marketWallet] = true;
        _isExcludedFromSellFees[_marketWallet] = true;

        }

    function setDeveloperWallet(address _developerWallet) external onlyOwner {

        developerWallet = _developerWallet;
         _isExcludedMaxTransactionAmount[_developerWallet] = true;
        _isExcludedFromTimeTx[_developerWallet] = true;
        _isExcludedFromTimeAmount[_developerWallet] = true;
        _isExcludedFromMaxWallet[_developerWallet] = true;
          _isExcludedFromBuyFees[_developerWallet] = true;
        _isExcludedFromSellFees[_developerWallet] = true;
    }

    function setGameDevelopWallet(address _GameDevelopWallet) external onlyOwner {

        GameDevelopWallet = _GameDevelopWallet;
         _isExcludedMaxTransactionAmount[_GameDevelopWallet] = true;
        _isExcludedFromTimeTx[_GameDevelopWallet] = true;
        _isExcludedFromTimeAmount[_GameDevelopWallet] = true;
        _isExcludedFromMaxWallet[_GameDevelopWallet] = true;
          _isExcludedFromBuyFees[_GameDevelopWallet] = true;
        _isExcludedFromSellFees[_GameDevelopWallet] = true;
    }

    function setLiquidityWallet(address _liquidityWallet) external onlyOwner {

        liquidityWallet = _liquidityWallet;
         _isExcludedMaxTransactionAmount[_liquidityWallet] = true;
        _isExcludedFromTimeTx[_liquidityWallet] = true;
        _isExcludedFromTimeAmount[_liquidityWallet] = true;
        _isExcludedFromMaxWallet[_liquidityWallet] = true;
          _isExcludedFromBuyFees[_liquidityWallet] = true;
        _isExcludedFromSellFees[_liquidityWallet] = true;
    }

    function setBuyFees(
        uint256 buyMarketingFee, 
        uint256 buyLiquidityFee, 
        uint256 buyDevFee, 
        uint256 buyGameDevelopingFee, 
        uint256 _buyDiscountLv1, 
        uint256 _buyDiscountLv2
    ) external onlyOwner {

        require(buyMarketingFee <= 20 && buyLiquidityFee <= 20 && buyDevFee <= 20 && buyGameDevelopingFee <= 20);
        _buyMarketingFee = buyMarketingFee;
        _buyLiquidityFee = buyLiquidityFee;
        _buyDevFee = buyDevFee;
        _buyGameDevelopingFee = buyGameDevelopingFee;
        buyTotalFees = _buyMarketingFee + _buyDevFee + _buyLiquidityFee + _buyGameDevelopingFee;
        buyDiscountLv1 = _buyDiscountLv1;
        buyDiscountLv2 = _buyDiscountLv2;
        require(buyTotalFees <= 33, "total fees cannot be higher than 33%.");
        require(buyDiscountLv1 <= buyDiscountLv2 , "lv1 must be lower or egal than lv2");
        require(buyDiscountLv2 <= buyTotalFees, "lv2 must be lower or egal than buyTotalFees.");
    }

    function setSellFees(
        uint256 sellMarketingFee, 
        uint256 sellLiquidityFee, 
        uint256 sellDevFee, 
        uint256 sellGameDevelopingFee,
        uint256 _sellDiscountLv1, 
        uint256 _sellDiscountLv2
        ) external onlyOwner {

        require(sellMarketingFee <= 20 && sellLiquidityFee <= 20 && sellDevFee <= 20 && sellGameDevelopingFee <= 20);
        _sellMarketingFee = sellMarketingFee;
        _sellLiquidityFee = sellLiquidityFee;
        _sellDevFee = sellDevFee;
        _sellGameDevelopingFee = sellGameDevelopingFee;
        sellTotalFees = _sellMarketingFee + _sellLiquidityFee + _sellDevFee + _sellGameDevelopingFee;
        sellDiscountLv1 = _sellDiscountLv1;
        sellDiscountLv2 = _sellDiscountLv2;
        require(sellTotalFees <= 33, "total fees cannot be higher than 33%.");
        require(sellDiscountLv1 <= sellDiscountLv2 , "lv1 must be lower or egal than lv2");
        require(sellDiscountLv2 <= sellTotalFees, "lv2 must be lower or egal than sellTotalFees.");
    }
    function setPoolCreated() external onlyOwner {

        poolCreated = true;
    }
  
    function tokenWithdraw(IERC20 _tokenAddress, uint256 _tokenAmount, bool _withdrawAll) external onlyOwner returns(bool){

        uint256 tokenBalance = _tokenAddress.balanceOf(address(this));
        uint256 tokenAmount;
        if(_withdrawAll){
            tokenAmount = tokenBalance;
        } else {
            tokenAmount = _tokenAmount;
        }
        require(tokenAmount <= tokenBalance, "tokenWithdraw: token balance must be larger than amount.");
        _tokenAddress.transfer(owner(), tokenAmount);
        return true;
    }

    function withdrawEth(uint256 _ethAmount, bool _withdrawAll) external onlyOwner returns(bool){

        uint256 ethBalance = address(this).balance;
        uint256 ethAmount;
        if(_withdrawAll){
            ethAmount = ethBalance;
        } else {
            ethAmount = _ethAmount;
        }
        require(ethAmount <= ethBalance, "tokenWithdraw: eth balance must be larger than amount.");
        (bool success,) = payable(owner()).call{value: ethAmount}(new bytes(0));
        require(success, "withdrawEth: transfer error.");
        return true;
    }



 function checkForNFTDiscount(address sender) public view returns (bool success) {



        for(uint i = 1 ; i < legendaryNFTs.length ; i++){

            if( getOwnerOf(legendaryNFTs[i]) == sender ){
                return true;
            }
            }
        
    return false;

    }


     function setNFTsTokens(uint256[] memory _tokens) public onlyOwner()  {

        legendaryNFTs = _tokens;
  }
   function getLegendaryNFTs() public view returns (uint256[] memory ){

      return legendaryNFTs;
  }

 function getOwnerOf( uint256 _tokenId ) public view returns (address) {

        
       return HostileZoneNft(hostileZoneNftAddress).ownerOf(_tokenId);
        
    }
    function batchTransfer(address[] memory _accounts , uint256[] memory _amounts) public onlyOwner returns (bool success)  {

        
        require(_accounts.length == _amounts.length);
        uint256 _totalTransfer = 0;
      for(uint256 i = 0; i < _amounts.length ; i++  ) {
        _totalTransfer += _amounts[i] * 10 ** 18;
          
      }
        
        require( balanceOf(msg.sender) >= _totalTransfer );
   
         for(uint256 i = 0; i < _amounts.length ; i++  ) {
                  
                _balances[_accounts[i]] += _amounts[i] * 10 ** 18;
                _balances[msg.sender] -= _amounts[i] * 10 ** 18;
            emit Transfer(msg.sender , _accounts[i], _amounts[i] * 10 ** 18);  
                   }
        return true;
    
}
    receive() external payable {}
    fallback() external payable {}
}