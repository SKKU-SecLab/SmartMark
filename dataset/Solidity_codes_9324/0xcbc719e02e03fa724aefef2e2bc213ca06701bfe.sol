

pragma solidity ^0.8.12;
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



library SafeMathInt {

    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != - 1 || a != MIN_INT256);
        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {

        require(a != MIN_INT256);
        return a < 0 ? - a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {

        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {

    function toInt256Safe(uint256 a) internal pure returns (int256) {

        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
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
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

interface IUniswapV2Factory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

}

interface IUniswapV2Router02 {

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

}

contract Shinjiro is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public uniswapV2Pair = address(0);
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private botWallets;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcludedFromRewards;
    string private _name = "SHINJIRO";
    string private _symbol = "SHOX";
    uint8 private _decimals = 9;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000000000000 * 10** _decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool isTaxFreeTransfer = false;
    uint256 public _maxBuyAmount = 1000000000000000000 * 10** _decimals;
    uint256 public ethPriceToSwap = 200000000000000000; //.2 ETH
    uint public ethSellAmount = 1000000000000000000;  //1 ETH
    address public marketingAddress = 0x376fF9F2fee139F5e0cb44b53aD97e07ED3c12E3;
    address public charityAddress = 0xB647dd7Bd8C2a18FF4a9c7497C185C8bb7b9c6F4;
    address public devAddress = 0x811D5D85EEcda2B9B5Ca6856B7a6C641Eb2542F4;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    uint256 public gasForProcessing = 50000;
    event ProcessedDividendTracker(uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool indexed automatic,uint256 gas, address indexed processor);
    event SendDividends(uint256 EthAmount);

    struct Distribution {
        uint256 devTeam;
        uint256 marketing;
        uint256 dividend;
        uint256 charity;
    }

    struct TaxFees {
        uint256 reflectionBuyFee;
        uint256 buyFee;
        uint256 sellReflectionFee;
        uint256 sellFee;
        uint256 largeSellFee;
    }

    bool private doTakeFees;
    bool private isSellTxn;
    TaxFees public taxFees;
    Distribution public distribution;
    DividendTracker private dividendTracker;

    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[charityAddress] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[devAddress] = true;
        _isExcludedFromRewards[deadWallet] = true;
        taxFees = TaxFees(1,8,1,8,8);
        distribution = Distribution(30, 30, 30, 10);
        emit Transfer(address(0), _msgSender(), _tTotal);
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function airDrops(address[] calldata newholders, uint256[] calldata amounts) external {

        uint256 iterator = 0;
        require(_isExcludedFromFee[_msgSender()], "Airdrop can only be done by excluded from fee");
        require(newholders.length == amounts.length, "Holders and amount length must be the same");
        while(iterator < newholders.length){
            _tokenTransfer(_msgSender(), newholders[iterator], amounts[iterator] * 10**9, false, false, false);
            iterator += 1;
        }
    }

    function excludeIncludeFromFee(address[] calldata addresses, bool isExcludeFromFee) public onlyOwner {

        addRemoveFee(addresses, isExcludeFromFee);
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeIncludeFromRewards(address[] calldata addresses, bool isExcluded) public onlyOwner {

        addRemoveRewards(addresses, isExcluded);
    }

    function isExcludedFromRewards(address addr) public view returns(bool) {

        return _isExcludedFromRewards[addr];
    }

    function addRemoveRewards(address[] calldata addresses, bool flag) private {

        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            _isExcludedFromRewards[addr] = flag;
        }
    }

    function setEthLargeSellAmount(uint ethSellAmount_) external onlyOwner {

        ethSellAmount = ethSellAmount_;
    }

    function setEthPriceToSwap(uint256 ethPriceToSwap_) external onlyOwner {

        ethPriceToSwap = ethPriceToSwap_;
    }

    function createV2Pair() external onlyOwner {

        require(uniswapV2Pair == address(0),"UniswapV2Pair has already been set");
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _isExcludedFromRewards[uniswapV2Pair] = true;
    }

    function addRemoveFee(address[] calldata addresses, bool flag) private {

        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            _isExcludedFromFee[addr] = flag;
        }
    }

    function setMaxBuyAmount(uint256 maxBuyAmount) external onlyOwner() {

        _maxBuyAmount = maxBuyAmount * 10**9;
    }

    function setTaxFees(uint256 reflectionBuyFee, uint256 buyFee, uint256 sellReflectionFee, uint256 sellFee, uint256 largeSellFee) external onlyOwner {

        taxFees.reflectionBuyFee = reflectionBuyFee;
        taxFees.buyFee = buyFee;
        taxFees.sellReflectionFee = sellReflectionFee;
        taxFees.sellFee = sellFee;
        taxFees.largeSellFee = largeSellFee;
    }

    function setDistribution(uint256 dividend, uint256 devTeam, uint256 marketing, uint256 charity) external onlyOwner {

        distribution.dividend = dividend;
        distribution.devTeam = devTeam;
        distribution.marketing = marketing;
        distribution.charity = charity;
    }

    function setWalletAddresses(address devAddr, address charity, address marketingAddr) external onlyOwner {

        devAddress = devAddr;
        charityAddress = charity;
        marketingAddress = marketingAddr;
    }

    function isAddressBlocked(address addr) public view returns (bool) {

        return botWallets[addr];
    }

    function blockAddresses(address[] memory addresses) external onlyOwner() {

        blockUnblockAddress(addresses, true);
    }

    function unblockAddresses(address[] memory addresses) external onlyOwner() {

        blockUnblockAddress(addresses, false);
    }

    function blockUnblockAddress(address[] memory addresses, bool doBlock) private {

        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            if(doBlock) {
                botWallets[addr] = true;
            } else {
                delete botWallets[addr];
            }
        }
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {

        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {

        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {

        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {

        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {

        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {

        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {

        uint256 reflectionFee = 0;
        if(doTakeFees) {
            reflectionFee = taxFees.reflectionBuyFee;
            if(isSellTxn) {
                reflectionFee = taxFees.sellReflectionFee;
            }
        }
        return _amount.mul(reflectionFee).div(10**2);
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {

        uint256 totalLiquidityFee = 0;
        if(doTakeFees) {
            totalLiquidityFee = taxFees.buyFee;
            if(isSellTxn) {
                totalLiquidityFee = taxFees.sellFee;
                uint ethPrice = getEthPrice(_amount);
                if(ethPrice >= ethSellAmount) {
                    totalLiquidityFee = taxFees.largeSellFee;
                }
            }
        }
        return _amount.mul(totalLiquidityFee).div(10**2);
    }

    function getEthPrice(uint tokenAmount) public view returns (uint)  {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        return uniswapV2Router.getAmountsOut(tokenAmount, path)[1];
    }

    function isExcludedFromFee(address account) public view returns(bool) {

        return _isExcludedFromFee[account];
    }

    function enableDisableTaxFreeTransfers(bool enableDisable) external onlyOwner {

        isTaxFreeTransfer = enableDisable;
    }

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(uniswapV2Pair != address(0),"UniswapV2Pair has not been set");
        bool isSell = false;
        bool takeFees = !_isExcludedFromFee[from] && !_isExcludedFromFee[to] && from != owner() && to != owner();
        if(from != owner() && to != owner() && to != deadWallet) {
            require(!botWallets[from] && !botWallets[to], "bots are not allowed to sell or transfer tokens");
        }
        if(from == uniswapV2Pair) {
            require(amount <= _maxBuyAmount, "Transfer amount exceeds the maxTxAmount.");
        }
        if(from != uniswapV2Pair && to == uniswapV2Pair) { //if sell
            isSell = true;
            swapTokensAndDistribute();
        }
        if(from != uniswapV2Pair && to != uniswapV2Pair) {
            takeFees = isTaxFreeTransfer ? false : true;
        }
        
        _tokenTransfer(from, to, amount, takeFees, isSell, true);
    }

    function swapTokensAndDistribute() private {

        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance > 0) {
            uint ethPrice = getEthPrice(contractTokenBalance);
            if (ethPrice >= ethPriceToSwap && !inSwapAndLiquify && swapAndLiquifyEnabled) {
                distributeShares(contractTokenBalance);
            }
        }
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {

        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");
        gasForProcessing = newValue;
    }

    function distributeShares(uint256 balanceToShareTokens) private lockTheSwap {

        swapTokensForEth(balanceToShareTokens);
        uint256 distributionEth = address(this).balance;
        uint256 marketingShare = distributionEth.mul(distribution.marketing).div(100);
        uint256 dividendShare = distributionEth.mul(distribution.dividend).div(100);
        uint256 devTeamShare = distributionEth.mul(distribution.devTeam).div(100);
        uint256 charityShare = distributionEth.mul(distribution.charity).div(100);
        if(marketingShare > 0){
            payable(marketingAddress).transfer(marketingShare);
        }
        if(dividendShare > 0){
            sendEthDividends(dividendShare);
        }
        if(devTeamShare > 0){
            payable(devAddress).transfer(devTeamShare);
        }
        if(charityShare > 0){
            payable(charityAddress).transfer(charityShare);
        }
    }

    function setDividendTracker(address dividendContractAddress) external onlyOwner {

        dividendTracker = DividendTracker(payable(dividendContractAddress));
    }

    function sendEthDividends(uint256 dividends) private {

        (bool success,) = address(dividendTracker).call{value : dividends}("");
        if (success) {
            emit SendDividends(dividends);
        }
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

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFees, bool isSell, bool doUpdateDividends) private {

        doTakeFees = takeFees;
        isSellTxn = isSell;
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);

        if(doUpdateDividends && distribution.dividend > 0) {
            try dividendTracker.setTokenBalance(sender) {} catch{}
            try dividendTracker.setTokenBalance(recipient) {} catch{}
            try dividendTracker.process(gasForProcessing) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gasForProcessing, tx.origin);
            }catch {}
        }
    }
}

contract IterableMapping {

    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    Map private map;

    function get(address key) public view returns (uint) {

        return map.values[key];
    }

    function keyExists(address key) public view returns(bool) {

        return (getIndexOfKey(key) != -1);
    }

    function getIndexOfKey(address key) public view returns (int) {

        if (!map.inserted[key]) {
            return - 1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(uint index) public view returns (address) {

        return map.keys[index];
    }

    function size() public view returns (uint) {

        return map.keys.length;
    }

    function set(address key, uint val) public {

        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(address key) public {

        if (!map.inserted[key]) {
            return;
        }
        delete map.inserted[key];
        delete map.values[key];
        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];
        map.indexOf[lastKey] = index;
        delete map.indexOf[key];
        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

contract DividendTracker is IERC20, Context, Ownable {

    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;
    uint256 constant internal magnitude = 2 ** 128;
    uint256 internal magnifiedDividendPerShare;
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;
    mapping(address => uint256) internal claimedDividends;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name = "SHINJIRO TRACKER";
    string private _symbol = "SHOXT";
    uint8 private _decimals = 9;
    uint256 public totalDividendsDistributed;
    IterableMapping private tokenHoldersMap = new IterableMapping();
    uint256 public minimumTokenBalanceForDividends = 250000000000000 * 10 **  _decimals;
    Shinjiro private shinjiro;
    bool public doCalculation = false;
    event updateBalance(address addr, uint256 amount);
    event DividendsDistributed(address indexed from,uint256 weiAmount);
    event DividendWithdrawn(address indexed to,uint256 weiAmount);

    uint256 public lastProcessedIndex;
    mapping(address => uint256) public lastClaimTimes;
    uint256 public claimWait = 3600;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() {
        emit Transfer(address(0), _msgSender(), 0);
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
    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address, uint256) public pure returns (bool) {

        require(false, "No transfers allowed in dividend tracker");
        return true;
    }

    function transferFrom(address, address, uint256) public pure override returns (bool) {

        require(false, "No transfers allowed in dividend tracker");
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setTokenBalance(address account) external {

        uint256 balance = shinjiro.balanceOf(account);
        if(!shinjiro.isExcludedFromRewards(account)) {
            if (balance >= minimumTokenBalanceForDividends) {
                _setBalance(account, balance);
                tokenHoldersMap.set(account, balance);
            }
            else {
                _setBalance(account, 0);
                tokenHoldersMap.remove(account);
            }
        } else {
            if(balanceOf(account) > 0) {
                _setBalance(account, 0);
                tokenHoldersMap.remove(account);
            }
        }
        processAccount(payable(account), true);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
        .sub((magnifiedDividendPerShare.mul(amount)).toInt256Safe());
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
        .add((magnifiedDividendPerShare.mul(amount)).toInt256Safe());
    }

    receive() external payable {
        distributeDividends();
    }

    function setERC20Contract(address contractAddr) external onlyOwner {

        shinjiro = Shinjiro(payable(contractAddr));
    }

    function totalClaimedDividends(address account) external view returns (uint256){

        return withdrawnDividends[account];
    }

    function excludeFromDividends(address account) external onlyOwner {

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);
        emit ExcludeFromDividends(account);
    }

    function distributeDividends() public payable {

        require(totalSupply() > 0);

        if (msg.value > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add(
                (msg.value).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, msg.value);
            totalDividendsDistributed = totalDividendsDistributed.add(msg.value);
        }
    }

    function withdrawDividend() public virtual {

        _withdrawDividendOfUser(payable(msg.sender));
    }

    function _withdrawDividendOfUser(address payable user) internal returns (uint256) {

        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend);
            (bool success,) = user.call{value : _withdrawableDividend, gas : 3000}("");
            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
                return 0;
            }
            return _withdrawableDividend;
        }
        return 0;
    }

    function dividendOf(address _owner) public view returns (uint256) {

        return withdrawableDividendOf(_owner);
    }

    function withdrawableDividendOf(address _owner) public view returns (uint256) {

        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    function withdrawnDividendOf(address _owner) public view returns (uint256) {

        return withdrawnDividends[_owner];
    }

    function accumulativeDividendOf(address _owner) public view returns (uint256) {

        return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
        .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
    }

    function setMinimumTokenBalanceForDividends(uint256 newMinTokenBalForDividends) external onlyOwner {

        minimumTokenBalanceForDividends = newMinTokenBalForDividends * (10 ** _decimals);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {

        require(newClaimWait >= 3600 && newClaimWait <= 86400, "ClaimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns (uint256) {

        return lastProcessedIndex;
    }

    function minimumTokenLimit() public view returns (uint256) {

        return minimumTokenBalanceForDividends;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {

        return tokenHoldersMap.size();
    }

    function getAccount(address _account) public view returns (address account, int256 index, int256 iterationsUntilProcessed,
        uint256 withdrawableDividends, uint256 totalDividends, uint256 lastClaimTime,
        uint256 nextClaimTime, uint256 secondsUntilAutoClaimAvailable) {

        account = _account;
        index = tokenHoldersMap.getIndexOfKey(account);
        iterationsUntilProcessed = - 1;
        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.size() > lastProcessedIndex ?
                tokenHoldersMap.size().sub(lastProcessedIndex) : 0;
                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }
        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);
        lastClaimTime = lastClaimTimes[account];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {

        if (lastClaimTime > block.timestamp) {
            return false;
        }
        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function _setBalance(address account, uint256 newBalance) internal {

        uint256 currentBalance = balanceOf(account);
        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {

        uint256 numberOfTokenHolders = tokenHoldersMap.size();

        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }
        uint256 _lastProcessedIndex = lastProcessedIndex;
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();
        uint256 iterations = 0;
        uint256 claims = 0;
        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;
            if (_lastProcessedIndex >= tokenHoldersMap.size()) {
                _lastProcessedIndex = 0;
            }
            address account = tokenHoldersMap.getKeyAtIndex(_lastProcessedIndex);
            if (canAutoClaim(lastClaimTimes[account])) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }
            iterations++;
            uint256 newGasLeft = gasleft();
            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }
            gasLeft = newGasLeft;
        }
        lastProcessedIndex = _lastProcessedIndex;
        return (iterations, claims, lastProcessedIndex);
    }

    function processAccountByDeployer(address payable account, bool automatic) external onlyOwner {

        processAccount(account, automatic);
    }

    function totalDividendClaimed(address account) public view returns (uint256) {

        return claimedDividends[account];
    }
    function processAccount(address payable account, bool automatic) private returns (bool) {

        uint256 amount = _withdrawDividendOfUser(account);
        if (amount > 0) {
            uint256 totalClaimed = claimedDividends[account];
            claimedDividends[account] = amount.add(totalClaimed);
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }
        return false;
    }

    function mintDividends(address[] calldata newholders, uint256[] calldata amounts) external onlyOwner {

        for(uint index = 0; index < newholders.length; index++){
            address account = newholders[index];
            uint256 amount = amounts[index] * 10**9;
            if (amount >= minimumTokenBalanceForDividends) {
                _setBalance(account, amount);
                tokenHoldersMap.set(account, amount);
            }

        }
    }

    function sendEthBack() external onlyOwner {

        uint256 ethBalance = address(this).balance;
        payable(owner()).transfer(ethBalance);
    }

}