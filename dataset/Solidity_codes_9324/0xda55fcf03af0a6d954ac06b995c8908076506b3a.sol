




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





contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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





library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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





abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





contract Initializable {

    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function isConstructor() private view returns (bool) {

        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    function isInitialized() public view returns (bool) {

        return initialized;
    }

    uint256[50] private ______gap;
}






contract ERC20 is Initializable, Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_initialize(string memory name, string memory symbol) internal initializer {

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

    function decimals() public virtual view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public virtual override view returns (uint256) {

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function updateNameAndSymbol(string memory __name, string memory __symbol) internal {

        _name = __name;
        _symbol = __symbol;
    }
}






contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize() internal initializer {

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





interface IYToken is IERC20 {

    function getPricePerFullShare() external view returns (uint256);

}






interface ICurve {

    function calc_token_amount(uint256[4] memory amounts, bool deposit) external view returns (uint256);


    function get_virtual_price() external view returns (uint256);

}

interface ICurveGauge {

    function balanceOf(address depositor) external view returns (uint256);


    function minter() external returns (ICurveMinter);


    function deposit(uint256 amount) external;


    function withdraw(uint256 amount) external;

}

interface ICurveMinter {

    function mint(address gauge) external;


    function token() external view returns (IERC20);

}

interface ICurvePool {

    function add_liquidity(uint256[4] memory amounts, uint256 min_mint_amount) external;


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount,
        bool donate_dust
    ) external;


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);


    function token() external view returns (IERC20);


    function curve() external view returns (ICurve);


    function coins(int128 id) external view returns (IYToken);

}





interface ITrueFiPool is IERC20 {

    function currencyToken() external view returns (IERC20);


    function stakeToken() external view returns (IERC20);


    function join(uint256 amount) external;


    function exit(uint256 amount) external;


    function borrow(uint256 amount, uint256 fee) external;


    function repay(uint256 amount) external;

}




interface ITrueLender {

    function value() external view returns (uint256);


    function distribute(
        address recipient,
        uint256 numerator,
        uint256 denominator
    ) external;

}




interface IUniswapRouter {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}




library ABDKMath64x64 {

    function fromUInt(uint256 x) internal pure returns (int128) {

        require(x <= 0x7FFFFFFFFFFFFFFF);
        return int128(x << 64);
    }

    function log_2(int128 x) internal pure returns (int128) {

        require(x > 0);

        int256 msb = 0;
        int256 xc = x;
        if (xc >= 0x10000000000000000) {
            xc >>= 64;
            msb += 64;
        }
        if (xc >= 0x100000000) {
            xc >>= 32;
            msb += 32;
        }
        if (xc >= 0x10000) {
            xc >>= 16;
            msb += 16;
        }
        if (xc >= 0x100) {
            xc >>= 8;
            msb += 8;
        }
        if (xc >= 0x10) {
            xc >>= 4;
            msb += 4;
        }
        if (xc >= 0x4) {
            xc >>= 2;
            msb += 2;
        }
        if (xc >= 0x2) msb += 1; // No need to shift xc anymore

        int256 result = (msb - 64) << 64;
        uint256 ux = uint256(x) << uint256(127 - msb);
        for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
            ux *= ux;
            uint256 b = ux >> 255;
            ux >>= 127 + b;
            result += bit * int256(b);
        }

        return int128(result);
    }

    function ln(int128 x) internal pure returns (int128) {

        require(x > 0);

        return int128((uint256(log_2(x)) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF) >> 128);
    }
}




interface ICrvPriceOracle {

    function usdToCrv(uint256 amount) external view returns (uint256);


    function crvToUsd(uint256 amount) external view returns (uint256);

}





interface IPauseableContract {

    function setPauseStatus(bool pauseStatus) external;

}





interface ITrueLender2 {

    function value(ITrueFiPool2 pool) external view returns (uint256);


    function distribute(
        address recipient,
        uint256 numerator,
        uint256 denominator
    ) external;

}





interface IERC20WithDecimals is IERC20 {

    function decimals() external view returns (uint256);

}





interface ITrueFiPoolOracle {

    function token() external view returns (IERC20WithDecimals);


    function truToToken(uint256 truAmount) external view returns (uint256);


    function tokenToTru(uint256 tokenAmount) external view returns (uint256);


    function tokenToUsd(uint256 tokenAmount) external view returns (uint256);

}



pragma experimental ABIEncoderV2;

interface I1Inch3 {

    struct SwapDescription {
        address srcToken;
        address dstToken;
        address srcReceiver;
        address dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
        bytes permit;
    }

    function swap(
        address caller,
        SwapDescription calldata desc,
        bytes calldata data
    )
        external
        returns (
            uint256 returnAmount,
            uint256 gasLeft,
            uint256 chiSpent
        );


    function unoswap(
        address srcToken,
        uint256 amount,
        uint256 minReturn,
        bytes32[] calldata /* pools */
    ) external payable returns (uint256 returnAmount);

}





interface ITrueFiPool2 is IERC20 {

    function initialize(
        ERC20 _token,
        ERC20 _stakingToken,
        ITrueLender2 _lender,
        I1Inch3 __1Inch,
        address __owner
    ) external;


    function token() external view returns (ERC20);


    function oracle() external view returns (ITrueFiPoolOracle);


    function join(uint256 amount) external;


    function borrow(uint256 amount) external;


    function repay(uint256 currencyAmount) external;

}



pragma solidity 0.6.10;



contract TrueFiPool is ITrueFiPool, IPauseableContract, ERC20, ReentrancyGuard, Ownable {

    using SafeMath for uint256;


    ICurvePool public _curvePool;
    ICurveGauge public _curveGauge;
    IERC20 public token;
    ITrueLender public _lender;
    ICurveMinter public _minter;
    IUniswapRouter public _uniRouter;

    uint256 public joiningFee;
    uint256 public claimableFees;

    mapping(address => uint256) latestJoinBlock;

    IERC20 public _stakeToken;

    bool private inSync;
    uint256 private yTokenValueCache;
    uint256 private loansValueCache;

    ITrueFiPoolOracle public oracle;

    address public fundsManager;

    bool public pauseStatus;

    ICrvPriceOracle public _crvOracle;

    ITrueLender2 public _lender2;


    uint8 constant N_TOKENS = 4;
    uint8 constant TUSD_INDEX = 3;

    uint256 constant MAX_PRICE_SLIPPAGE = 200; // 2%

    event TruOracleChanged(ITrueFiPoolOracle newOracle);

    event CrvOracleChanged(ICrvPriceOracle newOracle);

    event FundsManagerChanged(address newManager);

    event JoiningFeeChanged(uint256 newFee);

    event Joined(address indexed staker, uint256 deposited, uint256 minted);

    event Exited(address indexed staker, uint256 amount);

    event Flushed(uint256 currencyAmount);

    event Pulled(uint256 yAmount);

    event Borrow(address borrower, uint256 amount, uint256 fee);

    event Repaid(address indexed payer, uint256 amount);

    event Collected(address indexed beneficiary, uint256 amount);

    event PauseStatusChanged(bool pauseStatus);

    modifier onlyLender() {

        require(msg.sender == address(_lender) || msg.sender == address(_lender2), "TrueFiPool: Caller is not the lender");
        _;
    }

    modifier joiningNotPaused() {

        require(!pauseStatus, "TrueFiPool: Joining the pool is paused");
        _;
    }

    modifier onlyOwnerOrManager() {

        require(msg.sender == owner() || msg.sender == fundsManager, "TrueFiPool: Caller is neither owner nor funds manager");
        _;
    }

    modifier exchangeProtector(uint256 expectedGain, IERC20 _token) {

        uint256 balanceBefore = _token.balanceOf(address(this));
        _;
        uint256 balanceDiff = _token.balanceOf(address(this)).sub(balanceBefore);
        require(balanceDiff >= conservativePriceEstimation(expectedGain), "TrueFiPool: Not optimal exchange");
    }

    modifier sync() {

        yTokenValueCache = yTokenValue();
        loansValueCache = loansValue();
        inSync = true;
        _;
        inSync = false;
        yTokenValueCache = 0;
        loansValueCache = 0;
    }

    function borrow(uint256 amount) external {

        borrow(amount, 0);
    }

    function currencyToken() public override view returns (IERC20) {

        return token;
    }

    function stakeToken() public override view returns (IERC20) {

        return _stakeToken;
    }

    function setLender2(ITrueLender2 lender2) public onlyOwner {

        require(address(_lender2) == address(0), "TrueFiPool: Lender 2 is already set");
        _lender2 = lender2;
    }

    function setFundsManager(address newFundsManager) public onlyOwner {

        fundsManager = newFundsManager;
        emit FundsManagerChanged(newFundsManager);
    }

    function setTruOracle(ITrueFiPoolOracle newOracle) public onlyOwner {

        oracle = newOracle;
        emit TruOracleChanged(newOracle);
    }

    function setCrvOracle(ICrvPriceOracle newOracle) public onlyOwner {

        _crvOracle = newOracle;
        emit CrvOracleChanged(newOracle);
    }

    function setPauseStatus(bool status) external override onlyOwnerOrManager {

        pauseStatus = status;
        emit PauseStatusChanged(status);
    }

    function stakeTokenBalance() public view returns (uint256) {

        return _stakeToken.balanceOf(address(this));
    }

    function crvBalance() public view returns (uint256) {

        if (address(_minter) == address(0)) {
            return 0;
        }
        return _minter.token().balanceOf(address(this));
    }

    function yTokenBalance() public view returns (uint256) {

        return _curvePool.token().balanceOf(address(this)).add(_curveGauge.balanceOf(address(this)));
    }

    function yTokenValue() public view returns (uint256) {

        if (inSync) {
            return yTokenValueCache;
        }
        return yTokenBalance().mul(_curvePool.curve().get_virtual_price()).div(1 ether);
    }

    function truValue() public view returns (uint256) {

        uint256 balance = stakeTokenBalance();
        if (balance == 0 || address(oracle) == address(0)) {
            return 0;
        }
        return conservativePriceEstimation(oracle.truToToken(balance));
    }

    function crvValue() public view returns (uint256) {

        uint256 balance = crvBalance();
        if (balance == 0 || address(_crvOracle) == address(0)) {
            return 0;
        }
        return conservativePriceEstimation(_crvOracle.crvToUsd(balance));
    }

    function liquidValue() public view returns (uint256) {

        return currencyBalance().add(yTokenValue());
    }

    function poolValue() public view returns (uint256) {

        return liquidValue().add(loansValue()).add(crvValue());
    }

    function loansValue() public view returns (uint256) {

        if (inSync) {
            return loansValueCache;
        }
        if (address(_lender2) != address(0)) {
            return _lender.value().add(_lender2.value(ITrueFiPool2(address(this))));
        }
        return _lender.value();
    }

    function ensureEnoughTokensAreAvailable(uint256 neededAmount) internal {

        uint256 currentlyAvailableAmount = _curvePool.token().balanceOf(address(this));
        if (currentlyAvailableAmount < neededAmount) {
            _curveGauge.withdraw(neededAmount.sub(currentlyAvailableAmount));
        }
    }

    function setJoiningFee(uint256 fee) external onlyOwner {

        require(fee <= 10000, "TrueFiPool: Fee cannot exceed transaction value");
        joiningFee = fee;
        emit JoiningFeeChanged(fee);
    }

    function join(uint256 amount) external override joiningNotPaused {

        uint256 fee = amount.mul(joiningFee).div(10000);
        uint256 mintedAmount = mint(amount.sub(fee));
        claimableFees = claimableFees.add(fee);

        latestJoinBlock[tx.origin] = block.number;
        require(token.transferFrom(msg.sender, address(this), amount));

        emit Joined(msg.sender, amount, mintedAmount);
    }

    function exit(uint256 amount) external override nonReentrant {

        require(block.number != latestJoinBlock[tx.origin], "TrueFiPool: Cannot join and exit in same block");
        require(amount <= balanceOf(msg.sender), "TrueFiPool: insufficient funds");

        uint256 _totalSupply = totalSupply();

        uint256 currencyAmountToTransfer = amount.mul(
            currencyBalance()).div(_totalSupply);

        uint256 curveLiquidityAmountToTransfer = amount.mul(
            yTokenBalance()).div(_totalSupply);

        uint256 stakeTokenAmountToTransfer = amount.mul(
            stakeTokenBalance()).div(_totalSupply);

        uint256 crvTokenAmountToTransfer = amount.mul(
            crvBalance()).div(_totalSupply);

        _burn(msg.sender, amount);

        _lender.distribute(msg.sender, amount, _totalSupply);
        if (address(_lender2) != address(0)) {
            _lender2.distribute(msg.sender, amount, _totalSupply);
        }

        if (currencyAmountToTransfer > 0) {
            require(token.transfer(msg.sender, currencyAmountToTransfer));
        }
        if (curveLiquidityAmountToTransfer > 0) {
            ensureEnoughTokensAreAvailable(curveLiquidityAmountToTransfer);
            require(_curvePool.token().transfer(msg.sender, curveLiquidityAmountToTransfer));
        }

        if (stakeTokenAmountToTransfer > 0) {
            require(_stakeToken.transfer(msg.sender, stakeTokenAmountToTransfer));
        }

        if (crvTokenAmountToTransfer > 0) {
            require(_minter.token().transfer(msg.sender, crvTokenAmountToTransfer));
        }

        emit Exited(msg.sender, amount);
    }

    function liquidExit(uint256 amount) external nonReentrant sync {

        require(block.number != latestJoinBlock[tx.origin], "TrueFiPool: Cannot join and exit in same block");
        require(amount <= balanceOf(msg.sender), "TrueFiPool: Insufficient funds");

        uint256 amountToWithdraw = poolValue().mul(amount).div(totalSupply());
        amountToWithdraw = amountToWithdraw.mul(liquidExitPenalty(amountToWithdraw)).div(10000);
        require(amountToWithdraw <= liquidValue(), "TrueFiPool: Not enough liquidity in pool");

        _burn(msg.sender, amount);

        if (amountToWithdraw > currencyBalance()) {
            removeLiquidityFromCurve(amountToWithdraw.sub(currencyBalance()));
            require(amountToWithdraw <= currencyBalance(), "TrueFiPool: Not enough funds were withdrawn from Curve");
        }

        require(token.transfer(msg.sender, amountToWithdraw));

        emit Exited(msg.sender, amountToWithdraw);
    }

    function liquidExitPenalty(uint256 amount) public view returns (uint256) {

        uint256 lv = liquidValue();
        uint256 pv = poolValue();
        if (amount == pv) {
            return 10000;
        }
        uint256 liquidRatioBefore = lv.mul(10000).div(pv);
        uint256 liquidRatioAfter = lv.sub(amount).mul(10000).div(pv.sub(amount));
        return uint256(10000).sub(averageExitPenalty(liquidRatioAfter, liquidRatioBefore));
    }

    function integrateAtPoint(uint256 x) public pure returns (uint256) {

        return uint256(ABDKMath64x64.ln(ABDKMath64x64.fromUInt(x.add(50)))).mul(50000).div(2**64);
    }

    function averageExitPenalty(uint256 from, uint256 to) public pure returns (uint256) {

        require(from <= to, "TrueFiPool: To precedes from");
        if (from == 10000) {
            return 0;
        }
        if (from == to) {
            return uint256(50000).div(from.add(50));
        }
        return integrateAtPoint(to).sub(integrateAtPoint(from)).div(to.sub(from));
    }

    function flush(uint256 currencyAmount, uint256 minMintAmount) external onlyOwner {

        require(currencyAmount <= currencyBalance(), "TrueFiPool: Insufficient currency balance");

        _flush(currencyAmount, minMintAmount);

        uint256 yBalance = _curvePool.token().balanceOf(address(this));
        _curvePool.token().approve(address(_curveGauge), yBalance);
        _curveGauge.deposit(yBalance);

        emit Flushed(currencyAmount);
    }

    function _flush(uint256 currencyAmount, uint256 minMintAmount)
        internal
        exchangeProtector(calcTokenAmount(currencyAmount), _curvePool.token())
    {

        uint256[N_TOKENS] memory amounts = [0, 0, 0, currencyAmount];

        token.approve(address(_curvePool), currencyAmount);
        _curvePool.add_liquidity(amounts, minMintAmount);
    }

    function pull(uint256 yAmount, uint256 minCurrencyAmount) external onlyOwnerOrManager {

        require(yAmount <= yTokenBalance(), "TrueFiPool: Insufficient Curve liquidity balance");

        ensureEnoughTokensAreAvailable(yAmount);

        _curvePool.token().approve(address(_curvePool), yAmount);
        _curvePool.remove_liquidity_one_coin(yAmount, TUSD_INDEX, minCurrencyAmount, false);

        emit Pulled(yAmount);
    }

    function borrow(uint256 amount, uint256 fee) public override nonReentrant onlyLender {

        if (amount > currencyBalance()) {
            removeLiquidityFromCurve(amount.sub(currencyBalance()));
            require(amount <= currencyBalance(), "TrueFiPool: Not enough funds in pool to cover borrow");
        }

        mint(fee);
        require(token.transfer(msg.sender, amount.sub(fee)));

        emit Borrow(msg.sender, amount, fee);
    }

    function removeLiquidityFromCurve(uint256 amountToWithdraw) internal {

        uint256 roughCurveTokenAmount = calcTokenAmount(amountToWithdraw).mul(1005).div(1000);
        require(roughCurveTokenAmount <= yTokenBalance(), "TrueFiPool: Not enough Curve liquidity tokens in pool to cover borrow");
        ensureEnoughTokensAreAvailable(roughCurveTokenAmount);
        _curvePool.token().approve(address(_curvePool), roughCurveTokenAmount);
        uint256 minAmount = roughCurveTokenAmount.mul(_curvePool.curve().get_virtual_price()).mul(999).div(1000).div(1 ether);
        _curvePool.remove_liquidity_one_coin(roughCurveTokenAmount, TUSD_INDEX, minAmount, false);
    }

    function repay(uint256 currencyAmount) external override onlyLender {

        require(token.transferFrom(msg.sender, address(this), currencyAmount));
        emit Repaid(msg.sender, currencyAmount);
    }

    function collectCrv() external onlyOwnerOrManager {

        _minter.mint(address(_curveGauge));
    }

    function sellCrv(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path
    ) public exchangeProtector(_crvOracle.crvToUsd(amountIn), token) {

        _minter.token().approve(address(_uniRouter), amountIn);
        _uniRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, address(this), block.timestamp + 1 hours);
    }

    function sellStakeToken(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path
    ) public exchangeProtector(oracle.truToToken(amountIn), token) {

        _stakeToken.approve(address(_uniRouter), amountIn);
        _uniRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, address(this), block.timestamp + 1 hours);
    }

    function collectFees(address beneficiary) external onlyOwnerOrManager {

        uint256 amount = claimableFees;
        claimableFees = 0;

        if (amount > 0) {
            require(token.transfer(beneficiary, amount));
        }

        emit Collected(beneficiary, amount);
    }

    function calcTokenAmount(uint256 currencyAmount) public view returns (uint256) {

        uint256 yTokenAmount = currencyAmount.mul(1e18).div(
            _curvePool.coins(TUSD_INDEX).getPricePerFullShare());
        uint256[N_TOKENS] memory yAmounts = [0, 0, 0, yTokenAmount];
        return _curvePool.curve().calc_token_amount(yAmounts, true);
    }

    function currencyBalance() public view returns (uint256) {

        return token.balanceOf(address(this)).sub(claimableFees);
    }

    function mint(uint256 depositedAmount) internal returns (uint256) {

        uint256 mintedAmount = depositedAmount;
        if (mintedAmount == 0) {
            return mintedAmount;
        }

        if (totalSupply() > 0) {
            mintedAmount = totalSupply().mul(depositedAmount).div(poolValue());
        }
        _mint(msg.sender, mintedAmount);

        return mintedAmount;
    }

    function conservativePriceEstimation(uint256 price) internal pure returns (uint256) {

        return price.mul(uint256(10000).sub(MAX_PRICE_SLIPPAGE)).div(10000);
    }
}