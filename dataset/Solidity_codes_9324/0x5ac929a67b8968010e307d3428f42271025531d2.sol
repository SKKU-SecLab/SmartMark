
pragma solidity 0.6.12;

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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface UniswapRouterV2 {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IController {
    function vaults(address) external view returns (address);

    function devfund() external view returns (address);

    function treasury() external view returns (address);
}

interface IMasterchef {
    function notifyBuybackReward(uint256 _amount) external;
}

abstract contract StrategyBase {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    mapping(address => bool) public benignCallers;

    uint256 public performanceFee = 30000;
    uint256 public constant performanceMax = 100000;

    uint256 public treasuryFee = 0;
    uint256 public constant treasuryMax = 100000;

    uint256 public devFundFee = 0;
    uint256 public constant devFundMax = 100000;

    uint256 public delayBlockRequired = 1000;
    uint256 public lastHarvestBlock;
    uint256 public lastHarvestInWant;

    bool public buybackEnabled = true;
    address public mmToken = 0xa283aA7CfBB27EF0cfBcb2493dD9F4330E0fd304;
    address public masterChef = 0xf8873a6080e8dbF41ADa900498DE0951074af577;

    address public want;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public governance;
    address public controller;
    address public strategist;
    address public timelock;

    address public univ2Router2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address public sushiRouter = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    
    event Harvest(uint256 _reinvested);

    constructor(
        address _want,
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    ) public {
        want = _want;
        governance = _governance;
        strategist = _strategist;
        controller = _controller;
        timelock = _timelock;
    }


    modifier onlyBenevolent {
        require(msg.sender == governance || msg.sender == strategist);
        _;
    }
    
    modifier onlyBenignCallers {
        require(msg.sender == governance || msg.sender == strategist || benignCallers[msg.sender]);
        _;
    }


    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfPool() public virtual view returns (uint256);

    function balanceOf() public view returns (uint256) {
        uint256 delayReduction = 0;
        uint256 currentBlock = block.number;
        if (delayBlockRequired > 0 && lastHarvestInWant > 0 && currentBlock.sub(lastHarvestBlock) < delayBlockRequired){
            uint256 diffBlock = lastHarvestBlock.add(delayBlockRequired).sub(currentBlock);
            delayReduction = lastHarvestInWant.mul(diffBlock).mul(1e18).div(delayBlockRequired).div(1e18);
        }
        return balanceOfWant().add(balanceOfPool()).sub(delayReduction);
    }

    function getName() external virtual pure returns (string memory);


    function setBenignCallers(address _caller, bool _enabled) external{
        require(msg.sender == governance, "!governance");
        benignCallers[_caller] = _enabled;
    }

    function setDelayBlockRequired(uint256 _delayBlockRequired) external {
        require(msg.sender == governance, "!governance");
        delayBlockRequired = _delayBlockRequired;
    }

    function setDevFundFee(uint256 _devFundFee) external {
        require(msg.sender == timelock, "!timelock");
        devFundFee = _devFundFee;
    }

    function setTreasuryFee(uint256 _treasuryFee) external {
        require(msg.sender == timelock, "!timelock");
        treasuryFee = _treasuryFee;
    }

    function setPerformanceFee(uint256 _performanceFee) external {
        require(msg.sender == timelock, "!timelock");
        performanceFee = _performanceFee;
    }

    function setStrategist(address _strategist) external {
        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setTimelock(address _timelock) external {
        require(msg.sender == timelock, "!timelock");
        timelock = _timelock;
    }

    function setController(address _controller) external {
        require(msg.sender == timelock, "!timelock");
        controller = _controller;
    }

    function setBuybackEnabled(bool _buybackEnabled) external {
        require(msg.sender == governance, "!governance");
        buybackEnabled = _buybackEnabled;
    }

    function setMasterChef(address _masterChef) external {
        require(msg.sender == governance, "!governance");
        masterChef = _masterChef;
    }

    function deposit() public virtual;

    function withdraw(IERC20 _asset) external virtual returns (uint256 balance);

    function _withdrawNonWantAsset(IERC20 _asset) internal returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == controller, "!controller");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
				
        uint256 _feeDev = devFundFee > 0? _amount.mul(devFundFee).div(devFundMax) : 0;
        uint256 _feeTreasury = treasuryFee > 0? _amount.mul(treasuryFee).div(treasuryMax) : 0;

        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds

        if (buybackEnabled == true && (_feeDev > 0 || _feeTreasury > 0)) {
            (address _buybackPrinciple, uint256 _buybackAmount) = _convertWantToBuyback(_feeDev.add(_feeTreasury));
            buybackAndNotify(_buybackPrinciple, _buybackAmount);
        } 

        _amount = _feeDev > 0 ? _amount.sub(_feeDev) : _amount;
        _amount = _feeTreasury > 0 ? _amount.sub(_feeTreasury) : _amount;
        IERC20(want).safeTransfer(_vault, _amount);
    }
	
    function buybackAndNotify(address _buybackPrinciple, uint256 _buybackAmount) internal {
        if (buybackEnabled == true && _buybackAmount > 0) {
            _swapUniswap(_buybackPrinciple, mmToken, _buybackAmount);
            uint256 _mmBought = IERC20(mmToken).balanceOf(address(this));
            IERC20(mmToken).safeTransfer(masterChef, _mmBought);
            IMasterchef(masterChef).notifyBuybackReward(_mmBought);
        }
    }

    function withdrawAll() external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();

        balance = IERC20(want).balanceOf(address(this));

        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }

    function _withdrawAll() internal {
        _withdrawSome(balanceOfPool());
    }

    function _withdrawSome(uint256 _amount) internal virtual returns (uint256);	
	
    function _convertWantToBuyback(uint256 _lpAmount) internal virtual returns (address, uint256);

    function harvest() public virtual;


	
    function figureOutPath(address _from, address _to, uint256 _amount) public view returns (bool useSushi, address[] memory swapPath){
        address[] memory path;
        address[] memory sushipath;

        path = new address[](2);
        path[0] = _from;
        path[1] = _to;

        sushipath = new address[](2);
        sushipath[0] = _from;
        sushipath[1] = _to;

        uint256 _sushiOut = sushipath.length > 0? UniswapRouterV2(sushiRouter).getAmountsOut(_amount, sushipath)[sushipath.length - 1] : 0;
        uint256 _uniOut = sushipath.length > 0? UniswapRouterV2(univ2Router2).getAmountsOut(_amount, path)[path.length - 1] : 1;

        bool useSushi = _sushiOut > _uniOut? true : false;		
        address[] memory swapPath = useSushi ? sushipath : path;
		
        return (useSushi, swapPath);
    }
	
    function _swapUniswap(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        (bool useSushi, address[] memory swapPath) = figureOutPath(_from, _to, _amount);
        address _router = useSushi? sushiRouter : univ2Router2;
		
        _swapUniswapWithDetailConfig(_from, _to, _amount, 1, swapPath, _router);
    }
	
    function _swapUniswapWithDetailConfig(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _amountOutMin,
        address[] memory _swapPath,
        address _router
    ) internal {
        require(_to != address(0), '!invalidOutToken');
        require(_router != address(0), '!swapRouter');
        require(IERC20(_from).balanceOf(address(this)) >= _amount, '!notEnoughtAmountIn');

        if (_amount > 0){			
            IERC20(_from).safeApprove(_router, 0);
            IERC20(_from).safeApprove(_router, _amount);

            UniswapRouterV2(_router).swapExactTokensForTokens(
                _amount,
                _amountOutMin,
                _swapPath,
                address(this),
                now
            );
        }
    }

}

interface AggregatorV3Interface {
  
  function latestRoundData() external view returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
  );

}

interface ManagerLike {
    function ilks(uint256) external view returns (bytes32);
    function owns(uint256) external view returns (address);
    function urns(uint256) external view returns (address);
    function vat() external view returns (address);
    function open(bytes32, address) external returns (uint256);
    function give(uint256, address) external;
    function frob(uint256, int256, int256) external;
    function flux(uint256, address, uint256) external;
    function move(uint256, address, uint256) external;
    function exit(address, uint256, address, uint256) external;
    function quit(uint256, address) external;
    function enter(address, uint256) external;
}

interface VatLike {
    function can(address, address) external view returns (uint256);
    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);
    function dai(address) external view returns (uint256);
    function urns(bytes32, address) external view returns (uint256, uint256);
    function frob(bytes32, address, address, address, int256, int256) external;
    function hope(address) external;
    function move(address, address, uint256) external;
}

interface GemJoinLike {
    function dec() external returns (uint256);
    function join(address, uint256) external payable;
    function exit(address, uint256) external;
}

interface DaiJoinLike {
    function join(address, uint256) external payable;
    function exit(address, uint256) external;
}

interface JugLike {
    function drip(bytes32) external returns (uint256);
}


abstract contract StrategyMakerBase is StrategyBase {
    address public constant dssCdpManager = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    address public constant daiJoin = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    address public constant jug = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address public constant vat = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address public constant debtToken = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    uint256 public minDebt = 15001000000000000000000;
    address public constant eth_usd = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    address public collateral;
    uint256 public collateralDecimal = 1e18;
    address public gemJoin;
    address public collateralOracle;
    bytes32 public collateralIlk;
    AggregatorV3Interface internal priceFeed;
    uint256 public collateralPriceDecimal = 1;
    bool public collateralPriceEth = false;
	
    uint256 public cdpId = 0;
	
    uint256 public minRatio = 150;
    uint256 public ratioBuff = 150;
    uint256 public constant ratioBuffMax = 10000;
    uint256 constant RAY = 10 ** 27;

    constructor(
        address _collateralJoin,
        bytes32 _collateralIlk,
        address _collateral,
        uint256 _collateralDecimal,
        address _collateralOracle,
        uint256 _collateralPriceDecimal,
        bool _collateralPriceEth,
        address _want,
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        StrategyBase(_want, _governance, _strategist, _controller, _timelock)
    {
        require(_want == _collateral, '!mismatchWant');
		
        gemJoin = _collateralJoin;
        collateralIlk = _collateralIlk;		    
        collateral = _collateral;   
        collateralDecimal = _collateralDecimal;
        collateralOracle = _collateralOracle;
        priceFeed = AggregatorV3Interface(collateralOracle);
        collateralPriceDecimal = _collateralPriceDecimal;
        collateralPriceEth = _collateralPriceEth;
    }

	
    modifier onlyCDPInUse {
        uint256 collateralAmt = getCollateralBalance();
        require(collateralAmt > 0, '!zeroCollateral');
		
        uint256 debtAmt = getDebtBalance();
        require(debtAmt > 0, '!zeroDebt');		
        _;
    }
	
    modifier onlyCDPInitiated {        
        require(cdpId > 0, '!noCDP');	
        _;
    }
    
    modifier onlyAboveMinDebt(uint256 _daiAmt) {  
        uint256 debtAmt = getDebtBalance();   
        require((_daiAmt < debtAmt && (debtAmt.sub(_daiAmt) >= minDebt)) || debtAmt <= _daiAmt, '!minDebt');
        _;
    }
	
    function getCollateralBalance() public view returns (uint256) {
        (uint256 ink, ) = VatLike(vat).urns(collateralIlk, ManagerLike(dssCdpManager).urns(cdpId));
        return ink.mul(collateralDecimal).div(1e18);
    }
	
    function getDebtBalance() public view returns (uint256) {
        address urnHandler = ManagerLike(dssCdpManager).urns(cdpId);
        (, uint256 art) = VatLike(vat).urns(collateralIlk, urnHandler);
        (, uint256 rate, , , ) = VatLike(vat).ilks(collateralIlk);
        uint rad = mul(art, rate);
        if (rad == 0) {
            return 0;
        }
        uint256 wad = rad / RAY;
        return mul(wad, RAY) < rad ? wad + 1 : wad;
    }	
    
    function ilkDebts() public view returns(uint256, uint256, bool){
        (uint256 Art, uint256 rate,,uint256 line,) = VatLike(vat).ilks(collateralIlk);
        uint256 currentDebt = Art.mul(rate).div(RAY);
        uint256 maxDebt = line.div(RAY);
        return (currentDebt, maxDebt, maxDebt > currentDebt);
    }

	
    function balanceOfPool() public override view returns (uint256){
        return getCollateralBalance();
    }

    function collateralValue(uint256 collateralAmt) public view returns (uint256){
        uint256 collateralPrice = getLatestCollateralPrice();
        return collateralAmt.mul(collateralPrice).mul(1e18).div(collateralDecimal).div(collateralPriceDecimal);
    }

    function currentRatio() public view returns (uint256) {	
        uint256 _collateral = cdpId > 0? getCollateralBalance() : 0;
        if (_collateral > 0){
            uint256 collateralAmt = collateralValue(_collateral).mul(100);
            uint256 debtAmt = getDebtBalance();		
            return collateralAmt.div(debtAmt);
        }else{
            return 0;
        }
    } 
    
    function calculateDebtFor(uint256 collateralAmt, bool borrow) public view returns (uint256) {
        uint256 maxDebt = collateralAmt > 0? collateralValue(collateralAmt).mul(ratioBuffMax).div(_getBufferedMinRatio(ratioBuffMax)) : 0;
		
        uint256 debtAmt = getDebtBalance();
		
        uint256 debt = 0;
        
        if (borrow && maxDebt >= debtAmt){
            debt = maxDebt.sub(debtAmt);
        } else if (!borrow && debtAmt >= maxDebt){
            debt = debtAmt.sub(maxDebt);
        }
        
        return (debt > 0)? debt : 0;
    }
	
    function _getBufferedMinRatio(uint256 _multiplier) internal view returns (uint256){
        return _multiplier.mul(minRatio).mul(ratioBuffMax.add(ratioBuff)).div(ratioBuffMax).div(100);
    }

    function borrowableDebt() public view returns (uint256) {
        uint256 collateralAmt = getCollateralBalance();
        return calculateDebtFor(collateralAmt, true);
    }

    function requiredPaidDebt(uint256 _redeemCollateralAmt) public view returns (uint256) {
        uint256 totalCollateral = getCollateralBalance();
        uint256 collateralAmt = _redeemCollateralAmt >= totalCollateral? 0 : totalCollateral.sub(_redeemCollateralAmt);
        return calculateDebtFor(collateralAmt, false);
    }

    function _convertWantToBuyback(uint256 _lpAmount) internal virtual override returns (address, uint256);
	
    function _depositDAI(uint256 _daiAmt) internal virtual;
	
    function _withdrawDAI(uint256 _daiAmt) internal virtual;
	
	
    function getLatestCollateralPrice() public view returns (uint256){
        require(collateralOracle != address(0), '!_collateralOracle');	
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
		
        if (price > 0){		
            int ethPrice = 1;
            if (collateralPriceEth){
               (,ethPrice,,,) = AggregatorV3Interface(eth_usd).latestRoundData();			
            }
            return uint256(price).mul(collateralPriceDecimal).mul(uint256(ethPrice)).div(1e8).div(collateralPriceEth? 1e18 : 1);
        } else{
            return 0;
        }
    }

 
    function setMinDebt(uint256 _minDebt) external onlyBenevolent {
        minDebt = _minDebt;
    }	
 
    function setMinRatio(uint256 _minRatio) external onlyBenevolent {
        minRatio = _minRatio;
    }	
	
    function setRatioBuff(uint256 _ratioBuff) external onlyBenevolent {
        ratioBuff = _ratioBuff;
    }
	

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }
	
    function toRad(uint256 wad) internal pure returns (uint256 rad) {
        rad = mul(wad, RAY);
    }
	
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "sub-overflow");
    }
	
    function toInt(uint256 x) internal pure returns (int256 y) {
        y = int256(x);
        require(y >= 0, "int-overflow");
    }
	
    function convertTo18(address gemJoin, uint256 amt) internal returns (uint256 wad) {
        wad = mul(amt, 10 ** (18 - GemJoinLike(gemJoin).dec()));
    }
	
    function _getDrawDart(address vat, address jug, address urn, bytes32 ilk, uint wad) internal returns (int256 dart) {
        uint256 rate = JugLike(jug).drip(ilk);
        uint256 dai = VatLike(vat).dai(urn);
        if (dai < toRad(wad)) {
            dart = toInt(sub(toRad(wad), dai).div(rate));
            dart = mul(uint256(dart), rate) < toRad(wad) ? dart + 1 : dart;
        }
    }
	
    function _getWipeDart(address vat, uint dai, address urn, bytes32 ilk) internal view returns (int256 dart) {
        (, uint256 rate,,,) = VatLike(vat).ilks(ilk);
        (, uint256 art) = VatLike(vat).urns(ilk, urn);
        dart = toInt(dai.div(rate));
        dart = uint256(dart) <= art ? - dart : - toInt(art);
    }
	
    function openCDP() external onlyBenevolent{
        require(cdpId <= 0, "!cdpAlreadyOpened");
		
        cdpId = ManagerLike(dssCdpManager).open(collateralIlk, address(this));		
		
        IERC20(collateral).approve(gemJoin, uint256(-1));
        IERC20(debtToken).approve(daiJoin, uint256(-1));
    }
	
    function getUrnVatIlk() internal returns (address, address, bytes32){
        return (ManagerLike(dssCdpManager).urns(cdpId), ManagerLike(dssCdpManager).vat(), ManagerLike(dssCdpManager).ilks(cdpId));
    }
	
    function addCollateralAndBorrow(uint256 _collateralAmt, uint256 _daiAmt) internal onlyCDPInitiated {   
        require(_daiAmt.add(getDebtBalance()) >= minDebt, '!minDebt');
        (address urn, address vat, bytes32 ilk) = getUrnVatIlk();		
		GemJoinLike(gemJoin).join(urn, _collateralAmt);  
		ManagerLike(dssCdpManager).frob(cdpId, toInt(convertTo18(gemJoin, _collateralAmt)), _getDrawDart(vat, jug, urn, ilk, _daiAmt));
		ManagerLike(dssCdpManager).move(cdpId, address(this), toRad(_daiAmt));
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        DaiJoinLike(daiJoin).exit(address(this), _daiAmt);
    } 
	
    function repayAndRedeemCollateral(uint256 _collateralAmt, uint _daiAmt) internal onlyCDPInitiated onlyAboveMinDebt(_daiAmt) { 
        (address urn, address vat, bytes32 ilk) = getUrnVatIlk();
        if (_daiAmt > 0){
            DaiJoinLike(daiJoin).join(urn, _daiAmt);
        }
        uint256 wad18 = _collateralAmt > 0? convertTo18(gemJoin, _collateralAmt) : 0;
        ManagerLike(dssCdpManager).frob(cdpId, -toInt(wad18),  _getWipeDart(vat, VatLike(vat).dai(urn), urn, ilk));
        if (_collateralAmt > 0){
            ManagerLike(dssCdpManager).flux(cdpId, address(this), wad18);
            GemJoinLike(gemJoin).exit(address(this), _collateralAmt);
        }
    } 

	
    function keepMinRatio() external onlyCDPInUse onlyBenignCallers {		
        uint256 requiredPaidback = requiredPaidDebt(0);
        if (requiredPaidback > 0){
            _withdrawDAI(requiredPaidback);
            uint256 wad = IERC20(debtToken).balanceOf(address(this));
            require(wad >= requiredPaidback, '!keepMinRatioRedeem');
			
            repayAndRedeemCollateral(0, requiredPaidback);
            uint256 goodRatio = currentRatio();
            require(goodRatio >= minRatio.sub(1), '!stillBelowMinRatio');
        }
    }
	
    function deposit() public override {
        uint256 _want = balanceOfWant();
        (,,bool roomForNewMint) = ilkDebts();
        if (_want > 0 && roomForNewMint) {	
            uint256 _newDebt = calculateDebtFor(_want.add(getCollateralBalance()), true);
            if(_newDebt > 0 && _newDebt.add(getDebtBalance()) >= minDebt){
               addCollateralAndBorrow(_want, _newDebt);
               uint256 wad = IERC20(debtToken).balanceOf(address(this));
               _depositDAI(_newDebt > wad? wad : _newDebt);
            }
        }
    }

    function _withdrawSome(uint256 _amount) internal override returns (uint256) {
        bool _full = _amount >= getCollateralBalance();
        
        if (_full && _amount > 0){
            _withdrawDAI(uint256(-1));
            uint256 _debtOwe = getDebtBalance();
            require(IERC20(debtToken).balanceOf(address(this)) >= _debtOwe, '!mismatchAfterWithdrawAll');	
            repayAndRedeemCollateral(_amount, _debtOwe);
            _swapDebtToWant(IERC20(debtToken).balanceOf(address(this)));
        } else{
            uint256 requiredPaidback = requiredPaidDebt(_amount);
            if (requiredPaidback > 0){
                _withdrawDAI(requiredPaidback);
                require(IERC20(debtToken).balanceOf(address(this)) >= requiredPaidback, '!mismatchAfterWithdraw');			
            }
            repayAndRedeemCollateral(_amount, requiredPaidback);		
        }		
        
        return _amount;
    }
	
    function _swapDebtToWant(uint256 _swapIn) internal returns(uint256){
    }
    
}

interface ICvxBaseRewardPool {
    function getReward(address _account, bool _claimExtras) external returns(bool);
    function earned(address account) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function withdrawAndUnwrap(uint256 amount, bool claim) external returns(bool);
    function pid() external view returns (uint256);
}

interface ICvxBooster {
    function depositAll(uint256 _pid, bool _stake) external returns(bool);
    function withdraw(uint256 _pid, uint256 _amount) external returns(bool);
    function withdrawAll(uint256 _pid) external returns(bool);
}

interface ICurveZap_4 {
    function calc_withdraw_one_coin(address _pool, uint256 _token_amount, int128 i) external view returns (uint256);
    function add_liquidity(address _pool, uint256[4] calldata _deposit_amounts, uint256 _min_mint_amount) external;
    function remove_liquidity_one_coin(address _pool, uint256 _burn_amount, int128 i, uint256 _min_amount) external;
    function calc_token_amount(address _pool, uint256[4] calldata _amounts, bool _is_deposit) external view returns (uint256);
}

interface ICurveFi_3 {
    function exchange(int128 from, int128 to, uint256 _from_amount, uint256 _min_to_amount) external;
    function get_virtual_price() external view returns (uint256);
}

interface ICurveFi_2 {
    function get_virtual_price() external view returns (uint256);
}

contract StrategyMakerWETHV3 is StrategyMakerBase {
    address public weth_collateral = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public link_eth_usd = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    uint256 public weth_collateral_decimal = 1e18;
    uint8 public want_decimals = 18;
    bytes32 public weth_ilk = "ETH-A";
    address public weth_apt = 0x2F0b23f53734252Bda2277357e97e1517d6B042A;
    uint256 public constant weth_price_decimal = 1;
    bool public constant weth_price_eth = false;
    
    address public constant curve3crvPool = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
		
    address public stakingPool = 0xF403C135812408BFbE8713b5A23a04b3D48AAE31;
    address public constant rewardTokenCRV = 0xD533a949740bb3306d119CC777fa900bA034cd52; 
    address public constant rewardTokenCVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address public constant curveZap = 0xA79828DF1850E8a3A3064576f380D90aECDD3359;
    
    uint256 public stakingPoolId = 59;//ust-worm
    address public rewardPool = 0x7e2b9B5244bcFa5108A76D5E7b507CFD5581AD4A;//ust-worm
	
    address public curvePool = 0xCEAF7747579696A2F0bb206a14210e3c9e6fB269;
    address public curveLpToken = 0xCEAF7747579696A2F0bb206a14210e3c9e6fB269;
		
    uint256 public harvestReserveDebt = 2500; // reserved for debt repayment
    uint256 public harvestReserveIL = 2500; // reserved for LP IL
    uint256 public harvestReserve = 5000; 
    uint256 public removeLiquidityBuffer = 300; // remove liquidity buffer
    uint256 public slippageProtectionIn = 50; // max 0.5%
    uint256 public slippageProtectionOut = 50; // max 0.5%
    uint256 public constant DENOMINATOR = 10000;

    constructor(address _governance, address _strategist, address _controller, address _timelock) 
        public StrategyMakerBase(
            weth_apt,
            weth_ilk,
            weth_collateral,
            weth_collateral_decimal,			
            link_eth_usd,
            weth_price_decimal,
            weth_price_eth,
            weth_collateral,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {
        IERC20(debtToken).safeApprove(curveZap, uint256(-1));
        _setupPoolApprovals(); 	
    }
	
    
    function setSlippageProtection(uint256 _in, uint256 _out) public onlyBenevolent{
        slippageProtectionIn = _in;
        slippageProtectionOut = _out;
    }
    
    function setHarvestReserves(uint256 _debtReserve, uint256 _ilReserve) public onlyBenevolent{
        harvestReserveDebt = _debtReserve;
        harvestReserveIL = _ilReserve;
        harvestReserve = harvestReserveDebt.add(harvestReserveIL);
    }
    
    function setRemoveLiquidityBuffer(uint256 _rlpBuffer) public onlyBenevolent{
        removeLiquidityBuffer = _rlpBuffer;
    }
	
    
    function _setupPoolApprovals() internal {
        IERC20(curveLpToken).safeApprove(curveZap, 0);
        IERC20(curveLpToken).safeApprove(curveZap, uint256(-1));
        
        IERC20(curveLpToken).safeApprove(stakingPool, 0); 
        IERC20(curveLpToken).safeApprove(stakingPool, uint256(-1)); 
    }
    
    function migratePool(address _newCurvePool, address _newCurveLp, address _newConvexPool) public {
        require(msg.sender == timelock, '!timelock');
        
        if (ICvxBaseRewardPool(rewardPool).balanceOf(address(this)) > 0){
            _withdrawDAI(uint256(-1));
            require(ICvxBaseRewardPool(rewardPool).balanceOf(address(this)) == 0, '!stillGotSomeInConvex');
            require(IERC20(curveLpToken).balanceOf(address(this)) == 0, '!stillGotSomeInCurve');
        }
	    
        curvePool = _newCurvePool;
        curveLpToken = _newCurveLp;
        rewardPool = _newConvexPool;
        stakingPoolId = ICvxBaseRewardPool(rewardPool).pid();
        
        _setupPoolApprovals(); 
        
        _depositDAI(IERC20(debtToken).balanceOf(address(this)));
    }
	
    function harvest() public override onlyBenevolent {
        ICvxBaseRewardPool(rewardPool).getReward(address(this), true);
		
        uint256 _rewardCRV = IERC20(rewardTokenCRV).balanceOf(address(this));
        uint256 _rewardCVX = IERC20(rewardTokenCVX).balanceOf(address(this));

        if (_rewardCRV > 0) {
            _convertWithSushi(rewardTokenCRV, weth, _rewardCRV);
        }

        if (_rewardCVX > 0) {
            _convertWithSushi(rewardTokenCVX, weth, _rewardCVX);
        }
		
        uint256 _wethAmount = balanceOfWant();
        if (_wethAmount > 0){
            uint256 _debtBal = IERC20(debtToken).balanceOf(address(this));
            _convertWithSushi(weth, debtToken, _wethAmount.mul(harvestReserve).div(DENOMINATOR));
            uint256 _debtBalAfter= IERC20(debtToken).balanceOf(address(this));
            repayAndRedeemCollateral(0, (_debtBalAfter.sub(_debtBal)).mul(harvestReserveDebt).div(harvestReserve));
            
            if (buybackEnabled == true){
                uint256 _buybackLpAmount = _wethAmount.mul(performanceFee).div(performanceMax);
                buybackAndNotify(weth, _buybackLpAmount);
            }
             
            uint256 _wantBal = balanceOfWant();
            if (_wantBal > 0){
                lastHarvestBlock = block.number;
                lastHarvestInWant = _wantBal;
                deposit();	
                emit Harvest(_wantBal);
            }
        }
    }
    
    function _convertWithSushi(address _from, address _to, uint256 _inAmt) internal {
        address[] memory _swapPath = new address[](2);
        _swapPath[0] = _from;
        _swapPath[1] = _to;
        _swapUniswapWithDetailConfig(_from, _to, _inAmt, 1, _swapPath, sushiRouter);
    }
	
    function _convertWantToBuyback(uint256 _lpAmount) internal override returns (address, uint256){
        return (weth_collateral, _lpAmount);
    }
	
    function _depositDAI(uint256 _daiAmt) internal override{
        uint256 _debt = IERC20(debtToken).balanceOf(address(this));
        if (_debt == 0){
            return;
        }
        
        uint256 _debtAmt = IERC20(debtToken).balanceOf(address(this));
        uint256 _expectedOut = estimateRequiredLP(_debtAmt);
        uint256 _maxSlip = _expectedOut.mul(DENOMINATOR.sub(slippageProtectionIn)).div(DENOMINATOR);
        if (_debtAmt > 0 && checkDepositSlip(_debtAmt, _maxSlip)) {
            uint256[4] memory amounts = [0, _debtAmt, 0, 0];
            ICurveZap_4(curveZap).add_liquidity(curvePool, amounts, _maxSlip);
        }
		
        uint256 _lpAmt = IERC20(curveLpToken).balanceOf(address(this));
        require(_lpAmt > 0, "!_lpAmt");
        ICvxBooster(stakingPool).depositAll(stakingPoolId, true);
    }
	
    function _withdrawDAI(uint256 _daiAmt) internal override{
        if (_daiAmt == 0){
            return;
        } else if(_daiAmt >= uint256(-1)){            
            ICvxBaseRewardPool(rewardPool).withdrawAndUnwrap(ICvxBaseRewardPool(rewardPool).balanceOf(address(this)), false);
            _removeLpFromCurve(IERC20(curveLpToken).balanceOf(address(this)));
            return;
        }
	    
        uint256 requiredLP = estimateRequiredLP(_daiAmt);
        requiredLP = requiredLP.mul(DENOMINATOR.add(removeLiquidityBuffer)).div(DENOMINATOR);// try to remove bit more
		
        uint256 _lpAmount = IERC20(curveLpToken).balanceOf(address(this));
        uint256 _withdrawFromStaking = _lpAmount < requiredLP? requiredLP.sub(_lpAmount) : 0;
			
        if (_withdrawFromStaking > 0){
            uint256 maxInStaking = ICvxBaseRewardPool(rewardPool).balanceOf(address(this));
            uint256 _toWithdraw = maxInStaking < _withdrawFromStaking? maxInStaking : _withdrawFromStaking;		
            ICvxBaseRewardPool(rewardPool).withdrawAndUnwrap(_toWithdraw, false);			
        }
		    	
        _removeLpFromCurve(requiredLP);
    }
	
    function _removeLpFromCurve(uint256 requiredLP) internal{	
        uint256 _lpAmount = IERC20(curveLpToken).balanceOf(address(this));
        if (_lpAmount > 0){
            requiredLP = requiredLP > _lpAmount?  _lpAmount : requiredLP;
            uint256 maxSlippage = requiredLP.mul(DENOMINATOR.sub(slippageProtectionOut)).div(DENOMINATOR);
            ICurveZap_4(curveZap).remove_liquidity_one_coin(curvePool, requiredLP, 1, maxSlippage);
        }
    }

    function withdraw(IERC20 _asset) external override returns (uint256 balance) {
        require(address(_asset) != curveLpToken, '!curveLpToken');
        _withdrawNonWantAsset(_asset);
    }

	
    function balanceOfDebtToken() public view returns (uint256){
        uint256 lpAmt = ICvxBaseRewardPool(rewardPool).balanceOf(address(this));
        lpAmt = lpAmt.add(IERC20(curveLpToken).balanceOf(address(this)));
        return IERC20(debtToken).balanceOf(address(this)).add(crvLPToDebt(lpAmt));
    }
	
    function virtualPriceToDebt() public view returns (uint256) {
        return ICurveFi_2(curvePool).get_virtual_price().mul(ICurveFi_3(curve3crvPool).get_virtual_price()).div(1e18);
    }
	
    function estimateRequiredLP(uint256 _debtAmt) public view returns (uint256) {
        return _debtAmt.mul(1e18).div(virtualPriceToDebt());
    }
	
    function checkDepositSlip(uint256 _debtAmt, uint256 _maxSlip) public view returns (bool){
        uint256[4] memory amounts = [0, _debtAmt, 0, 0];
        return ICurveZap_4(curveZap).calc_token_amount(curvePool, amounts, true) >= _maxSlip;
    }
	
    function crvLPToDebt(uint256 _lpAmount) public view returns (uint256) {
        if (_lpAmount == 0){
            return 0;
        }
        uint256 virtualOut = virtualPriceToDebt().mul(_lpAmount).div(1e18);
        return virtualOut; 
    }

    function getHarvestable() public view returns (uint256) {
        return ICvxBaseRewardPool(rewardPool).earned(address(this));
    }

    function getName() external override pure returns (string memory) {
        return "StrategyMakerWETHV3";
    }
}