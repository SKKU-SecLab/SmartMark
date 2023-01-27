
pragma solidity >=0.4.0;

contract Context {

    constructor() internal {}

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// GPL-3.0-or-later

pragma solidity >=0.4.0;


contract Manageable is Context {

    address private _manager;

    event ManagementTransferred(address indexed previousManager, address indexed newManager);

    constructor() internal {
        address msgSender = _msgSender();
        _manager = msgSender;
        emit ManagementTransferred(address(0), msgSender);
    }

    function manager() public view returns (address) {

        return _manager;
    }

    modifier onlyManager() {

        require(_manager == _msgSender(), 'Manageable: caller is not the manager');
        _;
    }

    function renounceManagement() public onlyManager {

        emit ManagementTransferred(_manager, address(0));
        _manager = address(0);
    }

    function transferManagement(address newManager) public onlyManager {

        _transferManagement(newManager);
    }

    function _transferManagement(address newManager) internal {

        require(newManager != address(0), 'Manageable: new manager is the zero address');
        emit ManagementTransferred(_manager, newManager);
        _manager = newManager;
    }
}// GPL-3.0-or-later

pragma solidity >=0.4.0;


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// GPL-3.0-or-later

pragma solidity >=0.4.0;

interface IBEP20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function symbol() external view returns (string memory);


    function name() external view returns (string memory);


    function getOwner() external view returns (address);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address _owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.4.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, 'SafeMath: division by zero');
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

        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}// MIT

pragma solidity ^0.6.2;

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

        require(address(this).balance >= amount, 'Address: insufficient balance');

        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, 'Address: low-level call failed');
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

        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), 'Address: call to non-contract');

        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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
}// MIT

pragma solidity >=0.4.0;


contract BEP20 is Context, IBEP20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function getOwner() external override view returns (address) {

        return owner();
    }

    function name() public override view returns (string memory) {

        return _name;
    }

    function decimals() public override view returns (uint8) {

        return _decimals;
    }

    function symbol() public override view returns (string memory) {

        return _symbol;
    }

    function totalSupply() public override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

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
            _allowances[sender][_msgSender()].sub(amount, 'BEP20: transfer amount exceeds allowance')
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, 'BEP20: decreased allowance below zero')
        );
        return true;
    }

    function mint(uint256 amount) public onlyOwner returns (bool) {

        _mint(_msgSender(), amount);
        return true;
    }

    function burn(uint256 amount) public returns (bool) {

        _burn(_msgSender(), amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');

        _balances[sender] = _balances[sender].sub(amount, 'BEP20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), 'BEP20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'BEP20: burn amount exceeds balance');
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {

        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, 'BEP20: burn amount exceeds allowance')
        );
    }
}// MIT

pragma solidity ^0.6.0;


library SafeBEP20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}pragma solidity >=0.5.0;

interface ISphynxPair {

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

    function swapFee() external view returns (uint32);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

    function setSwapFee(uint32) external;

}pragma solidity >=0.5.0;

interface ISphynxFactory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setSwapFee(address _pair, uint32 _swapFee) external;

}pragma solidity >=0.6.2;

interface ISphynxRouter01 {

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

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint swapFee) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, uint swapFee) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}pragma solidity >=0.6.2;


interface ISphynxRouter02 is ISphynxRouter01 {

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

}// MIT

pragma solidity 0.6.12;


interface AggregatorV3Interface {

	function decimals() external view returns (uint8);


	function description() external view returns (string memory);


	function version() external view returns (uint256);


	function getRoundData(uint80 _roundId)
		external
		view
		returns (
			uint80 roundId,
			int256 answer,
			uint256 startedAt,
			uint256 updatedAt,
			uint80 answeredInRound
		);


	function latestRoundData()
		external
		view
		returns (
			uint80 roundId,
			int256 answer,
			uint256 startedAt,
			uint256 updatedAt,
			uint80 answeredInRound
		);

}

contract SphynxToken is BEP20, Manageable {

	using SafeMath for uint256;
	using SafeBEP20 for IBEP20;

	ISphynxRouter02 public sphynxSwapRouter;
	address public sphynxSwapPair;

	bool private swapping;

	address public masterChef;
	address public sphynxBridge;

	address payable public marketingWallet = payable(0x3D458e65828d031B46579De28e9BBAAeb2729064);
	address payable public developmentWallet = payable(0x7dB8380C7A017F82CC1d2DC7F8F1dE2d29Fd1df6);
	address public lotteryAddress;

	uint256 public usdAmountToSwap = 500;

	uint256 public marketingFee;
	uint256 public developmentFee;
	uint256 public lotteryFee;
	uint256 public totalFees;
	uint256 public blockNumber;

	bool public SwapAndLiquifyEnabled = false;
	bool public sendToLottery = false;
	bool public stopTrade = false;
	bool public claimable = true;
	uint256 public maxTxAmount = 800000000 * (10 ** 18); // Initial Max Tx Amount
	mapping(address => bool) signers;
	mapping(uint256 => address) signersArray;
	mapping(address => bool) stopTradeSign;

	AggregatorV3Interface internal priceFeed;

	mapping(address => bool) private _isExcludedFromFees;

	mapping(address => bool) public _isGetFees;

	mapping(address => bool) public automatedMarketMakerPairs;

	uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

	modifier onlyMasterChefAndBridge() {

		require(msg.sender == masterChef || msg.sender == sphynxBridge, 'Permission Denied');
		_;
	}

	modifier onlySigner() {

		require(signers[msg.sender], 'not-a-signer');
		_;
	}

	modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

	event ExcludeFromFees(address indexed account, bool isExcluded);
	event GetFee(address indexed account, bool isGetFee);
	event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
	event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
	event MarketingWalletUpdated(address indexed newMarketingWallet, address indexed oldMarketingWallet);
	event DevelopmentWalletUpdated(address indexed newDevelopmentWallet, address indexed oldDevelopmentWallet);
	event LotteryAddressUpdated(address indexed newLotteryAddress, address indexed oldLotteryAddress);
	event UpdateSphynxSwapRouter(address indexed newAddress, address indexed oldAddress);
	event SwapAndLiquify(uint256 tokensSwapped, uint256 nativeReceived, uint256 tokensIntoLiqudity);
	event UpdateSwapAndLiquify(bool value);
	event UpdateSendToLottery(bool value);
	event SetMarketingFee(uint256 value);
	event SetDevelopmentFee(uint256 value);
	event SetLotteryFee(uint256 value);
	event SetAllFeeToZero(uint256 marketingFee, uint256 developmentFee, uint256 lotteryFee);
	event MaxFees(uint256 marketingFee, uint256 developmentFee, uint256 lotteryFee);
	event SetUsdAmountToSwap(uint256 usdAmountToSwap);
	event SetBlockNumber(uint256 blockNumber);
	event UpdateMasterChef(address masterChef);
	event UpdateSphynxBridge(address sphynxBridge);
	event UpdateMaxTxAmount(uint256 txAmount);

	constructor() public BEP20('Sphynx ETH', 'SPHYNX') {
		uint256 _marketingFee = 5;
		uint256 _developmentFee = 5;
		uint256 _lotteryFee = 1;

		marketingFee = _marketingFee;
		developmentFee = _developmentFee;
		lotteryFee = _lotteryFee;
		totalFees = _marketingFee.add(_developmentFee);
		blockNumber = 0;

		ISphynxRouter02 _sphynxSwapRouter = ISphynxRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // mainnet
		address _sphynxSwapPair = ISphynxFactory(_sphynxSwapRouter.factory()).createPair(address(this), _sphynxSwapRouter.WETH());

		sphynxSwapRouter = _sphynxSwapRouter;
		sphynxSwapPair = _sphynxSwapPair;

		_setAutomatedMarketMakerPair(sphynxSwapPair, true);

		excludeFromFees(marketingWallet, true);
		excludeFromFees(developmentWallet, true);
		excludeFromFees(address(this), true);
		excludeFromFees(owner(), true);

		_isGetFees[address(_sphynxSwapRouter)] = true;
		_isGetFees[_sphynxSwapPair] = true;
		priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

		_mint(owner(), 800000000 * (10**18));

		_status = _NOT_ENTERED;

		signers[0x35BfE8dA53F94d6711F111790643D2D403992b56] = true;
		signers[0x96C463B615228981A2c30B842E8A8e4e933CEc46] = true;
		signers[0x7278fC9C49A2B6bd072b9d47E3c903ef0e12bb83] = true;
		signersArray[0] = 0x35BfE8dA53F94d6711F111790643D2D403992b56;
		signersArray[1] = 0x96C463B615228981A2c30B842E8A8e4e933CEc46;
		signersArray[2] = 0x7278fC9C49A2B6bd072b9d47E3c903ef0e12bb83;
	}

	receive() external payable {}

	function mint(address to, uint256 amount) public onlyMasterChefAndBridge {

		_mint(to, amount);
	}

	function updateSwapAndLiquifiy(bool value) public onlyManager {

		SwapAndLiquifyEnabled = value;
		emit UpdateSwapAndLiquify(value);
	}

	function updateSendToLottery(bool value) public onlyManager {

		sendToLottery = value;
		emit UpdateSendToLottery(value);
	}

	function setMarketingFee(uint256 value) external onlyManager {

		require(value <= 5, 'SPHYNX: Invalid marketingFee');
		marketingFee = value;
		totalFees = marketingFee.add(developmentFee);
		emit SetMarketingFee(value);
	}

	function setDevelopmentFee(uint256 value) external onlyManager {

		require(value <= 5, 'SPHYNX: Invalid developmentFee');
		developmentFee = value;
		totalFees = marketingFee.add(developmentFee);
		emit SetDevelopmentFee(value);
	}

	function setLotteryFee(uint256 value) external onlyManager {

		require(value <= 1, 'SPHYNX: Invalid lotteryFee');
		lotteryFee = value;
		emit SetLotteryFee(value);
	}

	function setAllFeeToZero() external onlyOwner {

		marketingFee = 0;
		developmentFee = 0;
		lotteryFee = 0;
		totalFees = 0;
		emit SetAllFeeToZero(marketingFee, developmentFee, lotteryFee);
	}

	function maxFees() external onlyOwner {

		marketingFee = 5;
		developmentFee = 5;
		lotteryFee = 1;
		totalFees = marketingFee.add(developmentFee);
		emit MaxFees(marketingFee, developmentFee, lotteryFee);
	}

	function updateSphynxSwapRouter(address newAddress) public onlyManager {

		require(newAddress != address(sphynxSwapRouter), 'SPHYNX: The router already has that address');
		emit UpdateSphynxSwapRouter(newAddress, address(sphynxSwapRouter));
		sphynxSwapRouter = ISphynxRouter02(newAddress);
		address _sphynxSwapPair;
		_sphynxSwapPair = ISphynxFactory(sphynxSwapRouter.factory()).getPair(address(this), sphynxSwapRouter.WETH());
		if(_sphynxSwapPair == address(0)) {
			_sphynxSwapPair = ISphynxFactory(sphynxSwapRouter.factory()).createPair(address(this), sphynxSwapRouter.WETH());
		}
		_setAutomatedMarketMakerPair(sphynxSwapPair, false);
		sphynxSwapPair = _sphynxSwapPair;
		_setAutomatedMarketMakerPair(sphynxSwapPair, true);
	}

	function updateMasterChef(address _masterChef) public onlyManager {

		require(masterChef != _masterChef, 'SPHYNX: MasterChef already exists!');
		masterChef = _masterChef;
		emit UpdateMasterChef(_masterChef);
	}

	function updateSphynxBridge(address _sphynxBridge) public onlyManager {

		require(sphynxBridge != _sphynxBridge, 'SPHYNX: SphynxBridge already exists!');
		_isExcludedFromFees[sphynxBridge] = false;
		sphynxBridge = _sphynxBridge;
		_isExcludedFromFees[sphynxBridge] = true;
		emit UpdateSphynxBridge(_sphynxBridge);
	}

	function excludeFromFees(address account, bool excluded) public onlyManager {

		require(_isExcludedFromFees[account] != excluded, "SPHYNX: Account is already the value of 'excluded'");
		_isExcludedFromFees[account] = excluded;

		emit ExcludeFromFees(account, excluded);
	}

	function setFeeAccount(address account, bool isGetFee) public onlyManager {

		require(_isGetFees[account] != isGetFee, "SPHYNX: Account is already the value of 'isGetFee'");
		_isGetFees[account] = isGetFee;

		emit GetFee(account, isGetFee);
	}

	function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {

		for (uint256 i = 0; i < accounts.length; i++) {
			_isExcludedFromFees[accounts[i]] = excluded;
		}

		emit ExcludeMultipleAccountsFromFees(accounts, excluded);
	}

	function setAutomatedMarketMakerPair(address pair, bool value) public onlyManager {

		_setAutomatedMarketMakerPair(pair, value);
	}

	function _setAutomatedMarketMakerPair(address pair, bool value) private {

		require(automatedMarketMakerPairs[pair] != value, 'SPHYNX: Automated market maker pair is already set to that value');
		automatedMarketMakerPairs[pair] = value;

		emit SetAutomatedMarketMakerPair(pair, value);
	}

	function setUsdAmountToSwap(uint256 _usdAmount) public onlyManager {

		usdAmountToSwap = _usdAmount;
		emit SetUsdAmountToSwap(usdAmountToSwap);
	}

	function updateMarketingWallet(address newMarketingWallet) public onlyManager {

		require(newMarketingWallet != marketingWallet, 'SPHYNX: The marketing wallet is already this address');
		excludeFromFees(newMarketingWallet, true);
		excludeFromFees(marketingWallet, false);
		emit MarketingWalletUpdated(newMarketingWallet, marketingWallet);
		marketingWallet = payable(newMarketingWallet);
	}

	function updateDevelopmentgWallet(address newDevelopmentWallet) public onlyManager {

		require(newDevelopmentWallet != developmentWallet, 'SPHYNX: The development wallet is already this address');
		excludeFromFees(newDevelopmentWallet, true);
		excludeFromFees(developmentWallet, false);
		emit DevelopmentWalletUpdated(newDevelopmentWallet, developmentWallet);
		developmentWallet = payable(newDevelopmentWallet);
	}

	function updateLotteryAddress(address newLotteryAddress) public onlyManager {

		require(newLotteryAddress != lotteryAddress, 'SPHYNX: The lottery wallet is already this address');
		excludeFromFees(newLotteryAddress, true);
		excludeFromFees(lotteryAddress, false);
		emit LotteryAddressUpdated(newLotteryAddress, lotteryAddress);
		lotteryAddress = newLotteryAddress;
	}

	function setBlockNumber() public onlyOwner {

		blockNumber = block.number;
		emit SetBlockNumber(blockNumber);
	}

	function updateMaxTxAmount(uint256 _amount) public onlyManager {

		maxTxAmount = _amount;
		emit UpdateMaxTxAmount(_amount);
	}

	function updateTokenClaim(bool _claim) public onlyManager {

		claimable = _claim;
	}

	function updateStopTrade(bool _value) external onlySigner {

		require(stopTrade != _value, 'already-set');
		require(!stopTradeSign[msg.sender], 'already-sign');
		stopTradeSign[msg.sender] = true;
        if (
            stopTradeSign[signersArray[0]] &&
            stopTradeSign[signersArray[1]] &&
            stopTradeSign[signersArray[2]]
        ) {
			stopTrade = _value;
			stopTradeSign[signersArray[0]] = false;
			stopTradeSign[signersArray[1]] = false;
			stopTradeSign[signersArray[2]] = false;
		}
	}

	function updateSignerWallet(address _signer) external onlySigner {

		signers[msg.sender] = false;
		signers[_signer] = true;
		for(uint i = 0; i < 3; i++) {
			if(signersArray[i] == msg.sender) {
				signersArray[i] = _signer;
			}
		}
	}

	function isExcludedFromFees(address account) public view returns (bool) {

		return _isExcludedFromFees[account];
	}

	function _transfer(
		address from,
		address to,
		uint256 amount
	) internal override {

		require(from != address(0), 'BEP20: transfer from the zero address');
		require(to != address(0), 'BEP20: transfer to the zero address');
		require(!stopTrade, 'trade-stopped');
		require(amount <= maxTxAmount, 'max-tx-amount-overflow');

		if (amount == 0) {
			super._transfer(from, to, 0);
			return;
		}

        if(SwapAndLiquifyEnabled) {
            uint256 contractTokenBalance = balanceOf(address(this));
            uint256 nativeTokenAmount = _getTokenAmountFromNative();

		    bool canSwap = contractTokenBalance >= nativeTokenAmount;

            if (canSwap && !swapping && !automatedMarketMakerPairs[from]) {
                swapping = true;

                contractTokenBalance = nativeTokenAmount;
                swapTokens(contractTokenBalance);
                swapping = false;
            }
        }

		bool takeFee = true;

		if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
			takeFee = false;
		}

		if (takeFee) {
			if (block.number - blockNumber <= 10) {
				uint256 afterBalance = balanceOf(to) + amount;
				require(afterBalance <= 250000 * (10**18), 'Owned amount exceeds the maxOwnedAmount');
			}
			uint256 fees;
			if (_isGetFees[from] || _isGetFees[to]) {
				if (block.number - blockNumber <= 5) {
					fees = amount.mul(99).div(10**2);
				} else {
					fees = amount.mul(totalFees).div(10**2);
					if (sendToLottery) {
						uint256 lotteryAmount = amount.mul(lotteryFee).div(10**2);
						amount = amount.sub(lotteryAmount);
						super._transfer(from, lotteryAddress, lotteryAmount);
					}
				}

				amount = amount.sub(fees);
				super._transfer(from, address(this), fees);
			}
		}

		super._transfer(from, to, amount);
	}

	function swapTokens(uint256 tokenAmount) private {

		swapTokensForNative(tokenAmount);
		uint256 swappedNative = address(this).balance;
		uint256 marketingNative = swappedNative.mul(marketingFee).div(totalFees);
		uint256 developmentNative = swappedNative.sub(marketingNative);
		transferNativeToMarketingWallet(marketingNative);
		transferNativeToDevelopmentWallet(developmentNative);
	}

	function swapTokensForNative(uint256 tokenAmount) private {

		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = sphynxSwapRouter.WETH();

		_approve(address(this), address(sphynxSwapRouter), tokenAmount);

		sphynxSwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
			tokenAmount,
			0, // accept any amount of Native
			path,
			address(this),
			block.timestamp
		);
	}

	function getNativeAmountFromUSD() public view returns (uint256 amount) {

		(
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        amount = usdAmountToSwap.mul(10 ** 26).div(uint256(price));
	}

	function _getTokenAmountFromNative() internal view returns (uint256) {

		uint256 tokenAmount;
		address[] memory path = new address[](2);
		path[0] = sphynxSwapRouter.WETH();
		path[1] = address(this);

		uint256 nativeAmountToSwap = getNativeAmountFromUSD();
		uint256[] memory amounts = sphynxSwapRouter.getAmountsOut(nativeAmountToSwap, path);
		tokenAmount = amounts[1];
		return tokenAmount;
	}

	function transferNativeToMarketingWallet(uint256 amount) private {

		marketingWallet.transfer(amount);
	}

	function transferNativeToDevelopmentWallet(uint256 amount) private {

		developmentWallet.transfer(amount);
	}
}