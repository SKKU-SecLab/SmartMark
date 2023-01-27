
pragma solidity 0.8.13;

interface IERC20 {

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

interface IFactory {

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);


    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

}

interface IRouter {

	function factory() external pure returns (address);


	function WETH() external pure returns (address);


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

library Address {

	function isContract(address account) internal view returns (bool) {

		uint256 size;
		assembly {
			size := extcodesize(account)
		}
		return size > 0;
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

		return functionCallWithValue(target, data, 0, errorMessage);
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
		require(isContract(target), "Address: call to non-contract");

		(bool success, bytes memory returndata) = target.call{value: value}(
		data
		);
		return _verifyCallResult(success, returndata, errorMessage);
	}

	function functionStaticCall(address target, bytes memory data)
	internal
	view
	returns (bytes memory)
	{

		return
		functionStaticCall(
			target,
			data,
			"Address: low-level static call failed"
		);
	}

	function functionStaticCall(
		address target,
		bytes memory data,
		string memory errorMessage
	) internal view returns (bytes memory) {

		require(isContract(target), "Address: static call to non-contract");

		(bool success, bytes memory returndata) = target.staticcall(data);
		return _verifyCallResult(success, returndata, errorMessage);
	}

	function functionDelegateCall(address target, bytes memory data)
	internal
	returns (bytes memory)
	{

		return
		functionDelegateCall(
			target,
			data,
			"Address: low-level delegate call failed"
		);
	}

	function functionDelegateCall(
		address target,
		bytes memory data,
		string memory errorMessage
	) internal returns (bytes memory) {

		require(isContract(target), "Address: delegate call to non-contract");

		(bool success, bytes memory returndata) = target.delegatecall(data);
		return _verifyCallResult(success, returndata, errorMessage);
	}

	function _verifyCallResult(
		bool success,
		bytes memory returndata,
		string memory errorMessage
	) private pure returns (bytes memory) {

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

abstract contract Context {
		function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}

contract Ownable is Context {

	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor () public {
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

contract LuckyDoo is IERC20, Ownable {

	using Address for address;
	using SafeMath for uint256;

	IRouter public uniswapV2Router;
	address public immutable uniswapV2Pair;

	string private constant _name =  "Lucky Doo";
	string private constant _symbol = "DOO";
	uint8 private constant _decimals = 18;

	mapping (address => uint256) private _rOwned;
	mapping (address => uint256) private _tOwned;
	mapping (address => mapping (address => uint256)) private _allowances;

	uint256 private constant MAX = ~uint256(0);
	uint256 private constant _tTotal = 999000000000000 * 10**18;
	uint256 private _rTotal = (MAX - (MAX % _tTotal));
	uint256 private _tFeeTotal;

	bool public isTradingEnabled;
    uint256 private _tradingPausedTimestamp;

	uint256 public maxWalletAmount = _tTotal * 200 / 10000;

	uint256 public maxTxAmount = _tTotal * 530 / 100000;

	bool private _swapping;

	uint256 public minimumTokensBeforeSwap = _tTotal * 250 / 1000000;

    address private dead = 0x000000000000000000000000000000000000dEaD;

	address public liquidityWallet;
    address public marketingWallet;
	address public devWallet;
	address public buyBackWallet;

	struct CustomTaxPeriod {
		bytes23 periodName;
		uint8 blocksInPeriod;
		uint256 timeInPeriod;
		uint8 liquidityFeeOnBuy;
		uint8 liquidityFeeOnSell;
		uint8 marketingFeeOnBuy;
		uint8 marketingFeeOnSell;
        uint8 devFeeOnBuy;
		uint8 devFeeOnSell;
		uint8 buyBackFeeOnBuy;
		uint8 buyBackFeeOnSell;
		uint8 holdersFeeOnBuy;
		uint8 holdersFeeOnSell;
	}

	bool private _isLaunched;
	uint256 private _launchStartTimestamp;
	uint256 private _launchBlockNumber;
	CustomTaxPeriod private _launch1 = CustomTaxPeriod('launch1',5,0,100,1,0,4,0,2,0,3,0,2);
	CustomTaxPeriod private _launch2 = CustomTaxPeriod('launch2',0,3600,1,2,4,10,2,3,3,10,2,5);
	CustomTaxPeriod private _launch3 = CustomTaxPeriod('launch3',0,86400,1,2,4,8,2,3,3,10,2,4);

	CustomTaxPeriod private _default = CustomTaxPeriod('default',0,0,1,1,4,4,2,2,3,3,2,2);
	CustomTaxPeriod private _base = CustomTaxPeriod('base',0,0,1,1,4,4,2,2,3,3,2,2);

    uint256 private constant _blockedTimeLimit = 172800;
	mapping (address => bool) private _isAllowedToTradeWhenDisabled;
	mapping (address => bool) private _isExcludedFromFee;
	mapping (address => bool) private _isExcludedFromMaxWalletLimit;
	mapping (address => bool) private _isExcludedFromMaxTransactionLimit;
    mapping (address => bool) private _isExcludedFromDividends;
	mapping (address => bool) private _isBlocked;
	mapping (address => bool) public automatedMarketMakerPairs;
    address[] private _excludedFromDividends;

	uint8 private _liquidityFee;
	uint8 private _devFee;
	uint8 private _marketingFee;
	uint8 private _buyBackFee;
	uint8 private _holdersFee;
	uint8 private _totalFee;

	event AutomatedMarketMakerPairChange(address indexed pair, bool indexed value);
	event UniswapV2RouterChange(address indexed newAddress, address indexed oldAddress);
	event WalletChange(string indexed indentifier, address indexed newWallet, address indexed oldWallet);
	event FeeChange(string indexed identifier, uint8 liquidityFee, uint8 marketingFee, uint8 devFee, uint8 buyBackFee, uint8 holdersFee);
	event CustomTaxPeriodChange(uint256 indexed newValue, uint256 indexed oldValue, string indexed taxType, bytes23 period);
	event BlockedAccountChange(address indexed holder, bool indexed status);
	event MaxWalletAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
	event MaxTransactionAmountChange(uint256 indexed newValue, uint256 indexed oldValue);
	event ExcludeFromFeesChange(address indexed account, bool isExcluded);
	event ExcludeFromMaxTransferChange(address indexed account, bool isExcluded);
	event ExcludeFromMaxWalletChange(address indexed account, bool isExcluded);
    event ExcludeFromDividendsChange(address indexed account, bool isExcluded);
	event AllowedWhenTradingDisabledChange(address indexed account, bool isExcluded);
	event MinTokenAmountBeforeSwapChange(uint256 indexed newValue, uint256 indexed oldValue);
	event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived,uint256 tokensIntoLiqudity);
	event ClaimETHOverflow(uint256 amount);
	event FeesApplied(uint8 liquidityFee, uint8 marketingFee, uint8 devFee, uint8 buyBackFee, uint8 holdersFee, uint8 totalFee);

	constructor() {
		liquidityWallet = owner();
		marketingWallet = owner();
        devWallet = owner();
		buyBackWallet = owner();

		IRouter _uniswapV2Router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
		address _uniswapV2Pair = IFactory(_uniswapV2Router.factory()).createPair(
			address(this),
			_uniswapV2Router.WETH()
		);
        uniswapV2Router = _uniswapV2Router;
		uniswapV2Pair = _uniswapV2Pair;
		_setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        _isExcludedFromFee[owner()] = true;
		_isExcludedFromFee[address(this)] = true;

        excludeFromDividends(address(this), true);
		excludeFromDividends(address(dead), true);
		excludeFromDividends(address(_uniswapV2Router), true);

		_isAllowedToTradeWhenDisabled[owner()] = true;

		_isExcludedFromMaxWalletLimit[_uniswapV2Pair] = true;
		_isExcludedFromMaxWalletLimit[address(uniswapV2Router)] = true;
		_isExcludedFromMaxWalletLimit[address(this)] = true;
		_isExcludedFromMaxWalletLimit[owner()] = true;

        _isExcludedFromMaxTransactionLimit[address(this)] = true;
		_isExcludedFromMaxTransactionLimit[address(dead)] = true;
		_isExcludedFromMaxTransactionLimit[owner()] = true;

		_rOwned[owner()] = _rTotal;
		emit Transfer(address(0), owner(), _tTotal);
	}

	receive() external payable {}

	function transfer(address recipient, uint256 amount) external override returns (bool) {

		_transfer(_msgSender(), recipient, amount);
		return true;
	}
	function approve(address spender, uint256 amount) public override returns (bool) {

		_approve(_msgSender(), spender, amount);
		return true;
	}
	function transferFrom( address sender,address recipient,uint256 amount) external override returns (bool) {

		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
		return true;
	}
	function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool){

		_approve(_msgSender(),spender,_allowances[_msgSender()][spender].add(addedValue));
		return true;
	}
	function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {

		_approve(_msgSender(),spender,_allowances[_msgSender()][spender].sub(subtractedValue,"ERC20: decreased allowance below zero"));
		return true;
	}
	function _approve(address owner,address spender,uint256 amount) private {

		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");
		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}
	function _getNow() private view returns (uint256) {

		return block.timestamp;
	}
	function launch() external onlyOwner {

		_launchStartTimestamp = _getNow();
		_launchBlockNumber = block.number;
		isTradingEnabled = true;
		_isLaunched = true;
	}
	function cancelLaunch() external onlyOwner {

		require(this.isInLaunch(), "LuckyDooToken: Launch is not set");
		_launchStartTimestamp = 0;
		_launchBlockNumber = 0;
		_isLaunched = false;
	}
	function activateTrading() external onlyOwner {

		isTradingEnabled = true;
	}
	function deactivateTrading() external onlyOwner {

		isTradingEnabled = false;
		_tradingPausedTimestamp = _getNow();
	}
    function _setAutomatedMarketMakerPair(address pair, bool value) private {

		require(automatedMarketMakerPairs[pair] != value, "LuckyDooToken: Automated market maker pair is already set to that value");
		automatedMarketMakerPairs[pair] = value;
		emit AutomatedMarketMakerPairChange(pair, value);
	}
	function allowTradingWhenDisabled(address account, bool allowed) external onlyOwner {

		_isAllowedToTradeWhenDisabled[account] = allowed;
		emit AllowedWhenTradingDisabledChange(account, allowed);
	}
	function excludeFromFees(address account, bool excluded) external onlyOwner {

		require(_isExcludedFromFee[account] != excluded, "LuckyDooToken: Account is already the value of 'excluded'");
		_isExcludedFromFee[account] = excluded;
		emit ExcludeFromFeesChange(account, excluded);
	}
    function excludeFromMaxWalletLimit(address account, bool excluded) external onlyOwner {

		require(_isExcludedFromMaxWalletLimit[account] != excluded, "LuckyDooToken: Account is already the value of 'excluded'");
		_isExcludedFromMaxWalletLimit[account] = excluded;
		emit ExcludeFromMaxWalletChange(account, excluded);
	}
	function excludeFromMaxTransactionLimit(address account, bool excluded) external onlyOwner {

		require(_isExcludedFromMaxTransactionLimit[account] != excluded, "LuckyDooToken: Account is already the value of 'excluded'");
		_isExcludedFromMaxTransactionLimit[account] = excluded;
		emit ExcludeFromMaxTransferChange(account, excluded);
	}
    function blockAccount(address account) external onlyOwner {

		uint256 currentTimestamp = _getNow();
		require(!_isBlocked[account], "LuckyDooToken: Account is already blocked");
		if (_isLaunched) {
			require((currentTimestamp - _launchStartTimestamp) < _blockedTimeLimit, "LuckyDooToken: Time to block accounts has expired");
		}
		_isBlocked[account] = true;
		emit BlockedAccountChange(account, true);
	}
	function unblockAccount(address account) external onlyOwner {

		require(_isBlocked[account], "LuckyDooToken: Account is not blcoked");
		_isBlocked[account] = false;
		emit BlockedAccountChange(account, false);
	}
	function setWallets(address newLiquidityWallet, address newDevWallet, address newMarketingWallet, address newBuyBackWallett) external onlyOwner {

		if(liquidityWallet != newLiquidityWallet) {
            require(newLiquidityWallet != address(0), "LuckyDooToken: The liquidityWallet cannot be 0");
			emit WalletChange('liquidityWallet', newLiquidityWallet, liquidityWallet);
			liquidityWallet = newLiquidityWallet;
		}
		if(devWallet != newDevWallet) {
            require(newDevWallet != address(0), "LuckyDooToken: The devWallet cannot be 0");
			emit WalletChange('devWallet', newDevWallet, devWallet);
			devWallet = newDevWallet;
		}
		if(marketingWallet != newMarketingWallet) {
            require(newMarketingWallet != address(0), "LuckyDooToken: The marketingWallet cannot be 0");
			emit WalletChange('marketingWallet', newMarketingWallet, marketingWallet);
			marketingWallet = newMarketingWallet;
		}
		if(buyBackWallet != newBuyBackWallett) {
            require(newBuyBackWallett != address(0), "LuckyDooToken: The buyBackWallet cannot be 0");
			emit WalletChange('buyBackWallet', newBuyBackWallett, buyBackWallet);
			buyBackWallet = newBuyBackWallett;
		}
	}
	function setBaseFeesOnBuy(uint8 _liquidityFeeOnBuy,  uint8 _marketingFeeOnBuy, uint8 _devFeeOnBuy,  uint8 _buyBackFeeOnBuy, uint8 _holdersFeeOnBuy) external onlyOwner {

		_setCustomBuyTaxPeriod(_base, _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('baseFees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _holdersFeeOnBuy);
	}
	function setBaseFeesOnSell(uint8 _liquidityFeeOnSell, uint8 _marketingFeeOnSell, uint8 _devFeeOnSell, uint8 _buyBackFeeOnSell, uint8 _holdersFeeOnSell) external onlyOwner {

		_setCustomSellTaxPeriod(_base, _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('baseFees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _holdersFeeOnSell);
	}
	function setLaunch2FeesOnBuy(uint8 _liquidityFeeOnBuy, uint8 _marketingFeeOnBuy, uint8 _devFeeOnBuy,  uint8 _buyBackFeeOnBuy, uint8 _holdersFeeOnBuy) external onlyOwner {

		_setCustomBuyTaxPeriod(_launch2, _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('launch2Fees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _holdersFeeOnBuy);
	}
	function setLaunch2FeesOnSell(uint8 _liquidityFeeOnSell, uint8 _marketingFeeOnSell, uint8 _devFeeOnSell, uint8 _buyBackFeeOnSell, uint8 _holdersFeeOnSell) external onlyOwner {

		_setCustomSellTaxPeriod(_launch2, _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('launch2Fees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _holdersFeeOnSell);
	}
	function setLaunch3FeesOnBuy(uint8 _liquidityFeeOnBuy, uint8 _marketingFeeOnBuy, uint8 _devFeeOnBuy, uint8 _buyBackFeeOnBuy, uint8 _holdersFeeOnBuy) external onlyOwner {

		_setCustomBuyTaxPeriod(_launch3, _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _holdersFeeOnBuy);
		emit FeeChange('launch3Fees-Buy', _liquidityFeeOnBuy, _marketingFeeOnBuy, _devFeeOnBuy, _buyBackFeeOnBuy, _holdersFeeOnBuy);
	}
	function setLaunch3FeesOnSell(uint8 _liquidityFeeOnSell, uint8 _marketingFeeOnSell, uint8 _devFeeOnSell, uint8 _buyBackFeeOnSell,  uint8 _holdersFeeOnSell) external onlyOwner {

		_setCustomSellTaxPeriod(_launch3, _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _holdersFeeOnSell);
		emit FeeChange('launch3Fees-Sell', _liquidityFeeOnSell, _marketingFeeOnSell, _devFeeOnSell, _buyBackFeeOnSell, _holdersFeeOnSell);
	}
	function setMaxWalletAmount(uint256 newValue) external onlyOwner {

		require(newValue != maxWalletAmount, "LuckyDooToken: Cannot update maxWalletAmount to same value");
		emit MaxWalletAmountChange(newValue, maxWalletAmount);
		maxWalletAmount = newValue;
	}
	function setMaxTransactionAmount(uint256 newValue) external onlyOwner {

		require(newValue != maxTxAmount, "LuckyDooToken: Cannot update maxTxAmount to same value");
        emit MaxTransactionAmountChange(newValue, maxTxAmount);
        maxTxAmount = newValue;
	}
	function excludeFromDividends(address account, bool excluded) public onlyOwner {

		require(_isExcludedFromDividends[account] != excluded, "LuckyDooToken: Account is already the value of 'excluded'");
		if(excluded) {
			if(_rOwned[account] > 0) {
				_tOwned[account] = tokenFromReflection(_rOwned[account]);
			}
			_isExcludedFromDividends[account] = excluded;
			_excludedFromDividends.push(account);
		} else {
			for (uint256 i = 0; i < _excludedFromDividends.length; i++) {
				if (_excludedFromDividends[i] == account) {
					_excludedFromDividends[i] = _excludedFromDividends[_excludedFromDividends.length - 1];
					_tOwned[account] = 0;
					_isExcludedFromDividends[account] = false;
					_excludedFromDividends.pop();
					break;
				}
			}
		}
		emit ExcludeFromDividendsChange(account, excluded);
	}
	function setMinimumTokensBeforeSwap(uint256 newValue) external onlyOwner {

		require(newValue != minimumTokensBeforeSwap, "LuckyDooToken: Cannot update minimumTokensBeforeSwap to same value");
		emit MinTokenAmountBeforeSwapChange(newValue, minimumTokensBeforeSwap);
		minimumTokensBeforeSwap = newValue;
	}
	function claimETHOverflow() external onlyOwner {

		require(address(this).balance > 0, "LuckyDooToken: Cannot send more than contract balance");
        uint256 amount = address(this).balance;
		(bool success,) = address(owner()).call{value : amount}("");
		if (success){
			emit ClaimETHOverflow(amount);
		}
	}

	function name() external view returns (string memory) {

		return _name;
	}
	function symbol() external view returns (string memory) {

		return _symbol;
	}
	function decimals() external view virtual returns (uint8) {

		return _decimals;
	}
	function totalSupply() external view override returns (uint256) {

		return _tTotal;
	}
	function balanceOf(address account) public view override returns (uint256) {

		if (_isExcludedFromDividends[account]) return _tOwned[account];
		return tokenFromReflection(_rOwned[account]);
	}
	function totalFees() external view returns (uint256) {

		return _tFeeTotal;
	}
	function allowance(address owner, address spender) external view override returns (uint256) {

		return _allowances[owner][spender];
	}
	function isInLaunch() external view returns (bool) {

		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		uint256 totalLaunchTime =  _launch1.timeInPeriod + _launch2.timeInPeriod + _launch3.timeInPeriod;
		if(_isLaunched && ((currentTimestamp - _launchStartTimestamp) < totalLaunchTime || (block.number - _launchBlockNumber) < _launch1.blocksInPeriod )) {
			return true;
		} else {
			return false;
		}
	}
    function getBaseBuyFees() external view returns (uint256, uint256, uint256, uint256, uint256){

		return (_base.liquidityFeeOnBuy, _base.marketingFeeOnBuy, _base.devFeeOnBuy, _base.buyBackFeeOnBuy, _base.holdersFeeOnBuy);
	}
	function getBaseSellFees() external view returns (uint256, uint256, uint256, uint256, uint256){

		return (_base.liquidityFeeOnSell, _base.marketingFeeOnSell, _base.devFeeOnSell, _base.buyBackFeeOnSell, _base.holdersFeeOnSell);
	}
	function tokenFromReflection(uint256 rAmount) public view returns(uint256) {

		require(rAmount <= _rTotal, "LuckyDooToken: Amount must be less than total reflections");
		uint256 currentRate =  _getRate();
		return rAmount / currentRate;
	}
	function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns (uint256) {

		require(tAmount <= _tTotal, "LuckyDooToken: Amount must be less than supply");
		uint256 currentRate = _getRate();
		uint256 rAmount  = tAmount * currentRate;
		if (!deductTransferFee) {
			return rAmount;
		}
		else {
			uint256 rTotalFee  = tAmount * _totalFee / 100 * currentRate;
			uint256 rTransferAmount = rAmount - rTotalFee;
			return rTransferAmount;
		}
	}

	function _transfer(
	address from,
	address to,
	uint256 amount
	) internal {

		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");
		require(amount > 0, "Transfer amount must be greater than zero");
		require(amount <= balanceOf(from), "LuckyDooToken: Cannot transfer more than balance");

		bool isBuyFromLp = automatedMarketMakerPairs[from];
		bool isSelltoLp = automatedMarketMakerPairs[to];
        bool _isInLaunch = this.isInLaunch();

		if(!_isAllowedToTradeWhenDisabled[from] && !_isAllowedToTradeWhenDisabled[to]) {
			require(isTradingEnabled, "LuckyDooToken: Trading is currently disabled.");
			require(!_isBlocked[to], "LuckyDooToken: Account is blocked");
			require(!_isBlocked[from], "LuckyDooToken: Account is blocked");
            if (!_isExcludedFromMaxTransactionLimit[to] && !_isExcludedFromMaxTransactionLimit[from]) {
                require(amount <= maxTxAmount, "LuckyDooToken: Transfer amount exceeds the maxTxAmount.");
            }
			if (!_isExcludedFromMaxWalletLimit[to]) {
				require((balanceOf(to) + amount) <= maxWalletAmount, "LuckyDooToken: Expected wallet amount exceeds the maxWalletAmount.");
			}
		}

		_adjustTaxes(isBuyFromLp, isSelltoLp, _isInLaunch);
		bool canSwap = balanceOf(address(this)) >= minimumTokensBeforeSwap;

		if (
			isTradingEnabled &&
			canSwap &&
			!_swapping &&
			_totalFee > 0 &&
			automatedMarketMakerPairs[to] &&
			from != liquidityWallet && to != liquidityWallet &&
			from != devWallet && to != devWallet &&
			from != marketingWallet && to != marketingWallet &&
			from != buyBackWallet && to != buyBackWallet
		) {
			_swapping = true;
			_swapAndLiquify();
			_swapping = false;
		}

		bool takeFee = !_swapping && isTradingEnabled;

		if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
			takeFee = false;
		}
		_tokenTransfer(from, to, amount, takeFee);
	}
	function _tokenTransfer(address sender,address recipient, uint256 tAmount, bool takeFee) private {

		(uint256 tTransferAmount,uint256 tFee, uint256 tOther) = _getTValues(tAmount, takeFee);
		(uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 rOther) = _getRValues(tAmount, tFee, tOther, _getRate());

		if (_isExcludedFromDividends[sender]) {
			_tOwned[sender] = _tOwned[sender] - tAmount;
		}
		if (_isExcludedFromDividends[recipient]) {
			_tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
		}
		_rOwned[sender] = _rOwned[sender] - rAmount;
		_rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
		_takeContractFees(rOther, tOther);
		_reflectFee(rFee, tFee);
		emit Transfer(sender, recipient, tTransferAmount);
	}
	function _reflectFee(uint256 rFee, uint256 tFee) private {

		_rTotal -= rFee;
		_tFeeTotal += tFee;
	}
	function _getTValues(uint256 tAmount, bool takeFee) private view returns (uint256,uint256,uint256){

		if (!takeFee) {
			return (tAmount, 0, 0);
		}
		else {
			uint256 tFee = tAmount * _holdersFee / 100;
			uint256 tOther = tAmount * (_liquidityFee + _devFee + _marketingFee + _buyBackFee) / 100;
			uint256 tTransferAmount = tAmount - (tFee + tOther);
			return (tTransferAmount, tFee, tOther);
		}
	}
	function _getRValues(
		uint256 tAmount,
		uint256 tFee,
		uint256 tOther,
		uint256 currentRate
		) private pure returns ( uint256, uint256, uint256, uint256) {

		uint256 rAmount = tAmount * currentRate;
		uint256 rFee = tFee * currentRate;
		uint256 rOther = tOther * currentRate;
		uint256 rTransferAmount = rAmount - (rFee + rOther);
		return (rAmount, rTransferAmount, rFee, rOther);
	}
	function _getRate() private view returns (uint256) {

		(uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
		return rSupply.div(tSupply);
	}
	function _getCurrentSupply() private view returns (uint256, uint256) {

		uint256 rSupply = _rTotal;
		uint256 tSupply = _tTotal;
		for (uint256 i = 0; i < _excludedFromDividends.length; i++) {
			if (
				_rOwned[_excludedFromDividends[i]] > rSupply ||
				_tOwned[_excludedFromDividends[i]] > tSupply
			) return (_rTotal, _tTotal);
			rSupply = rSupply - _rOwned[_excludedFromDividends[i]];
			tSupply = tSupply - _tOwned[_excludedFromDividends[i]];
		}
		if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
		return (rSupply, tSupply);
	}
	function _takeContractFees(uint256 rOther, uint256 tOther) private {

		if (_isExcludedFromDividends[address(this)]) {
			_tOwned[address(this)] += tOther;
		}
		_rOwned[address(this)] += rOther;
	}
	function _adjustTaxes(bool isBuyFromLp, bool isSelltoLp, bool isLaunching) private {

		uint256 blocksSinceLaunch = block.number - _launchBlockNumber;
		uint256 currentTimestamp = !isTradingEnabled && _tradingPausedTimestamp > _launchStartTimestamp  ? _tradingPausedTimestamp : _getNow();
		uint256 timeSinceLaunch = currentTimestamp - _launchStartTimestamp;

		_liquidityFee = 0;
		_devFee = 0;
		_marketingFee = 0;
		_buyBackFee = 0;
		_holdersFee = 0;

		if (isBuyFromLp) {
			_liquidityFee = _base.liquidityFeeOnBuy;
			_devFee = _base.devFeeOnBuy;
			_marketingFee = _base.marketingFeeOnBuy;
			_buyBackFee = _base.buyBackFeeOnBuy;
			_holdersFee = _base.holdersFeeOnBuy;

			if(isLaunching) {
				if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
					_liquidityFee = _launch1.liquidityFeeOnBuy;
					_devFee = _launch1.devFeeOnBuy;
					_marketingFee = _launch1.marketingFeeOnBuy;
					_buyBackFee = _launch1.buyBackFeeOnBuy;
					_holdersFee = _launch1.holdersFeeOnBuy;
				}
				else if (_isLaunched && timeSinceLaunch <= _launch2.timeInPeriod && blocksSinceLaunch > _launch1.blocksInPeriod) {
					_liquidityFee = _launch2.liquidityFeeOnBuy;
					_devFee = _launch2.devFeeOnBuy;
					_marketingFee = _launch2.marketingFeeOnBuy;
					_buyBackFee = _launch2.buyBackFeeOnBuy;
					_holdersFee = _launch2.holdersFeeOnBuy;
				}
				else {
					_liquidityFee = _launch3.liquidityFeeOnBuy;
					_devFee = _launch3.devFeeOnBuy;
					_marketingFee = _launch3.marketingFeeOnBuy;
					_buyBackFee = _launch3.buyBackFeeOnBuy;
					_holdersFee = _launch3.holdersFeeOnBuy;
				}
			}
		}
		if (isSelltoLp) {
			_liquidityFee = _base.liquidityFeeOnSell;
			_devFee = _base.devFeeOnSell;
			_marketingFee = _base.marketingFeeOnSell;
			_buyBackFee = _base.buyBackFeeOnSell;
			_holdersFee = _base.holdersFeeOnSell;

			if(isLaunching) {
				if (_isLaunched && blocksSinceLaunch < _launch1.blocksInPeriod) {
					_liquidityFee = _launch1.liquidityFeeOnSell;
					_devFee = _launch1.devFeeOnSell;
					_marketingFee = _launch1.marketingFeeOnSell;
					_buyBackFee = _launch1.buyBackFeeOnSell;
					_holdersFee = _launch1.holdersFeeOnSell;
				}
				else if (_isLaunched && timeSinceLaunch <= _launch2.timeInPeriod && blocksSinceLaunch > _launch1.blocksInPeriod) {
					_liquidityFee = _launch2.liquidityFeeOnSell;
					_devFee = _launch2.devFeeOnSell;
					_marketingFee = _launch2.marketingFeeOnSell;
					_buyBackFee = _launch2.buyBackFeeOnSell;
					_holdersFee = _launch2.holdersFeeOnSell;
				}
				else {
					_liquidityFee = _launch3.liquidityFeeOnSell;
					_devFee = _launch3.devFeeOnSell;
					_marketingFee = _launch3.marketingFeeOnSell;
					_buyBackFee = _launch3.buyBackFeeOnSell;
					_holdersFee = _launch3.holdersFeeOnSell;
				}
			}
		}

		_totalFee = _liquidityFee + _marketingFee + _devFee + _buyBackFee + _holdersFee;
		emit FeesApplied(_liquidityFee, _marketingFee, _devFee, _buyBackFee, _holdersFee, _totalFee);
	}
	function _setCustomSellTaxPeriod(CustomTaxPeriod storage map,
		uint8 _liquidityFeeOnSell,
		uint8 _marketingFeeOnSell,
        uint8 _devFeeOnSell,
		uint8 _buyBackFeeOnSell,
		uint8 _holdersFeeOnSell
	) private {

		if (map.liquidityFeeOnSell != _liquidityFeeOnSell) {
			emit CustomTaxPeriodChange(_liquidityFeeOnSell, map.liquidityFeeOnSell, 'liquidityFeeOnSell', map.periodName);
			map.liquidityFeeOnSell = _liquidityFeeOnSell;
		}
		if (map.marketingFeeOnSell != _marketingFeeOnSell) {
			emit CustomTaxPeriodChange(_marketingFeeOnSell, map.marketingFeeOnSell, 'marketingFeeOnSell', map.periodName);
			map.marketingFeeOnSell = _marketingFeeOnSell;
		}
        if (map.devFeeOnSell != _devFeeOnSell) {
			emit CustomTaxPeriodChange(_devFeeOnSell, map.devFeeOnSell, 'devFeeOnSell', map.periodName);
			map.devFeeOnSell = _devFeeOnSell;
		}
		if (map.buyBackFeeOnSell != _buyBackFeeOnSell) {
			emit CustomTaxPeriodChange(_buyBackFeeOnSell, map.buyBackFeeOnSell, 'buyBackFeeOnSell', map.periodName);
			map.buyBackFeeOnSell = _buyBackFeeOnSell;
		}
		if (map.holdersFeeOnSell != _holdersFeeOnSell) {
			emit CustomTaxPeriodChange(_holdersFeeOnSell, map.holdersFeeOnSell, 'holdersFeeOnSell', map.periodName);
			map.holdersFeeOnSell = _holdersFeeOnSell;
		}
	}
	function _setCustomBuyTaxPeriod(CustomTaxPeriod storage map,
		uint8 _liquidityFeeOnBuy,
		uint8 _marketingFeeOnBuy,
        uint8 _devFeeOnBuy,
		uint8 _buyBackFeeOnBuy,
		uint8 _holdersFeeOnBuy
	) private {

		if (map.liquidityFeeOnBuy != _liquidityFeeOnBuy) {
			emit CustomTaxPeriodChange(_liquidityFeeOnBuy, map.liquidityFeeOnBuy, 'liquidityFeeOnBuy', map.periodName);
			map.liquidityFeeOnBuy = _liquidityFeeOnBuy;
		}
		if (map.marketingFeeOnBuy != _marketingFeeOnBuy) {
			emit CustomTaxPeriodChange(_marketingFeeOnBuy, map.marketingFeeOnBuy, 'marketingFeeOnBuy', map.periodName);
			map.marketingFeeOnBuy = _marketingFeeOnBuy;
		}
        if (map.devFeeOnBuy != _devFeeOnBuy) {
			emit CustomTaxPeriodChange(_devFeeOnBuy, map.devFeeOnBuy, 'devFeeOnBuy', map.periodName);
			map.devFeeOnBuy = _devFeeOnBuy;
		}
		if (map.buyBackFeeOnBuy != _buyBackFeeOnBuy) {
			emit CustomTaxPeriodChange(_buyBackFeeOnBuy, map.buyBackFeeOnBuy, 'buyBackFeeOnBuy', map.periodName);
			map.buyBackFeeOnBuy = _buyBackFeeOnBuy;
		}
		if (map.holdersFeeOnBuy != _holdersFeeOnBuy) {
			emit CustomTaxPeriodChange(_holdersFeeOnBuy, map.holdersFeeOnBuy, 'holdersFeeOnBuy', map.periodName);
			map.holdersFeeOnBuy = _holdersFeeOnBuy;
		}
	}
	function _swapAndLiquify() private {

		uint256 contractBalance = balanceOf(address(this));
		uint256 initialETHBalance = address(this).balance;

		uint8 totalFeePrior = _totalFee;
        uint8 liquidityFeePrior = _liquidityFee;
        uint8 marketingFeePrior = _marketingFee;
        uint8 devFeePrior = _devFee;
        uint8 buyBackFeePrior  = _buyBackFee;

		uint256 amountToLiquify = contractBalance * _liquidityFee / _totalFee / 2;
		uint256 amountToSwapForETH = contractBalance - amountToLiquify;

		_swapTokensForETH(amountToSwapForETH);

		uint256 ETHBalanceAfterSwap = address(this).balance - initialETHBalance;
		uint256 totalETHFee = _totalFee - (_liquidityFee / 2);
		uint256 amountETHLiquidity = ETHBalanceAfterSwap * _liquidityFee / totalETHFee / 2;
		uint256 amountETHDev = ETHBalanceAfterSwap * _devFee / totalETHFee;
		uint256 amountETHBuyBack = ETHBalanceAfterSwap * _buyBackFee / totalETHFee;
		uint256 amountETHMarketing = ETHBalanceAfterSwap - (amountETHLiquidity + amountETHDev + amountETHBuyBack);

		payable(marketingWallet).transfer(amountETHMarketing);
		payable(devWallet).transfer(amountETHDev);
        payable(buyBackWallet).transfer(amountETHBuyBack);

		if (amountToLiquify > 0) {
			_addLiquidity(amountToLiquify, amountETHLiquidity);
			emit SwapAndLiquify(amountToSwapForETH, amountETHLiquidity, amountToLiquify);
		}
		_totalFee = totalFeePrior;
        _liquidityFee = liquidityFeePrior;
        _marketingFee = marketingFeePrior;
        _devFee = devFeePrior;
        _buyBackFee = buyBackFeePrior;
	}
	function _swapTokensForETH(uint256 tokenAmount) private {

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
	function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

		_approve(address(this), address(uniswapV2Router), tokenAmount);
		uniswapV2Router.addLiquidityETH{value: ethAmount}(
		address(this),
		tokenAmount,
		0, // slippage is unavoidable
		0, // slippage is unavoidable
		liquidityWallet,
		block.timestamp
		);
    }
}