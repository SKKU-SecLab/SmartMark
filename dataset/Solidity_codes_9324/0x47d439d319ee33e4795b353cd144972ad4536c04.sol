




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






contract UpgradeableClaimable is Initializable, Context {

    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address __owner) internal initializer {

        _owner = __owner;
        emit OwnershipTransferred(address(0), __owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function pendingOwner() public view returns (address) {

        return _pendingOwner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyPendingOwner() {

        require(msg.sender == _pendingOwner, "Ownable: caller is not the pending owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0);
    }
}




interface ITrueStrategy {

    function deposit(uint256 amount) external;


    function withdraw(uint256 minAmount) external;


    function withdrawAll() external;


    function value() external view returns (uint256);

}





interface ILoanToken2 is IERC20 {

    enum Status {Awaiting, Funded, Withdrawn, Settled, Defaulted, Liquidated}

    function borrower() external view returns (address);


    function amount() external view returns (uint256);


    function term() external view returns (uint256);


    function apy() external view returns (uint256);


    function start() external view returns (uint256);


    function lender() external view returns (address);


    function debt() external view returns (uint256);


    function pool() external view returns (ITrueFiPool2);


    function profit() external view returns (uint256);


    function status() external view returns (Status);


    function getParameters()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function fund() external;


    function withdraw(address _beneficiary) external;


    function settle() external;


    function enterDefault() external;


    function liquidate() external;


    function redeem(uint256 _amount) external;


    function repay(address _sender, uint256 _amount) external;


    function repayInFull(address _sender) external;


    function reclaim() external;


    function allowTransfer(address account, bool _status) external;


    function repaid() external view returns (uint256);


    function isRepaid() external view returns (bool);


    function balance() external view returns (uint256);


    function value(uint256 _balance) external view returns (uint256);


    function token() external view returns (ERC20);


    function version() external pure returns (uint8);

}






interface ITrueLender2 {

    function value(ITrueFiPool2 pool) external view returns (uint256);


    function distribute(
        address recipient,
        uint256 numerator,
        uint256 denominator
    ) external;


    function transferAllLoanTokens(ILoanToken2 loan, address recipient) external;

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




interface ISAFU {

    function poolDeficit(address pool) external view returns (uint256);

}





interface ITrueFiPool2 is IERC20 {

    function initialize(
        ERC20 _token,
        ERC20 _stakingToken,
        ITrueLender2 _lender,
        I1Inch3 __1Inch,
        ISAFU safu,
        address __owner
    ) external;


    function token() external view returns (ERC20);


    function oracle() external view returns (ITrueFiPoolOracle);


    function join(uint256 amount) external;


    function borrow(uint256 amount) external;


    function repay(uint256 currencyAmount) external;


    function liquidate(ILoanToken2 loan) external;

}





interface IPauseableContract {

    function setPauseStatus(bool pauseStatus) external;

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



// pragma experimental ABIEncoderV2;


interface IUniRouter {

    function token0() external view returns (address);


    function token1() external view returns (address);

}

library OneInchExchange {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 constant ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
    uint256 constant REVERSE_MASK = 0x8000000000000000000000000000000000000000000000000000000000000000;

    event Swapped(I1Inch3.SwapDescription description, uint256 returnedAmount);


    function exchange(I1Inch3 _1inchExchange, bytes calldata data)
        internal
        returns (I1Inch3.SwapDescription memory description, uint256 returnedAmount)
    {

        if (data[0] == 0x7c) {
            (, description, ) = abi.decode(data[4:], (address, I1Inch3.SwapDescription, bytes));
        } else {
            (address srcToken, uint256 amount, uint256 minReturn, bytes32[] memory pathData) = abi.decode(
                data[4:],
                (address, uint256, uint256, bytes32[])
            );
            description.srcToken = srcToken;
            description.amount = amount;
            description.minReturnAmount = minReturn;
            description.flags = 0;
            uint256 lastPath = uint256(pathData[pathData.length - 1]);
            IUniRouter uniRouter = IUniRouter(address(lastPath & ADDRESS_MASK));
            bool isReverse = lastPath & REVERSE_MASK > 0;
            description.dstToken = isReverse ? uniRouter.token0() : uniRouter.token1();
            description.dstReceiver = address(this);
        }

        IERC20(description.srcToken).safeApprove(address(_1inchExchange), description.amount);
        uint256 balanceBefore = IERC20(description.dstToken).balanceOf(description.dstReceiver);
        (bool success, ) = address(_1inchExchange).call(data);
        if (!success) {
            assembly {
                let ptr := mload(0x40)
                let size := returndatasize()
                returndatacopy(ptr, 0, size)
                revert(ptr, size)
            }
        }

        uint256 balanceAfter = IERC20(description.dstToken).balanceOf(description.dstReceiver);
        returnedAmount = balanceAfter.sub(balanceBefore);

        emit Swapped(description, returnedAmount);
    }
}





library PoolExtensions {

    function _liquidate(
        ISAFU safu,
        ILoanToken2 loan,
        ITrueLender2 lender
    ) internal {

        require(msg.sender == address(safu), "TrueFiPool: Should be called by SAFU");
        lender.transferAllLoanTokens(loan, address(safu));
    }
}



pragma solidity 0.6.10;




contract TrueFiPool2 is ITrueFiPool2, IPauseableContract, ERC20, UpgradeableClaimable {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using SafeERC20 for IERC20;
    using OneInchExchange for I1Inch3;

    uint256 private constant BASIS_PRECISION = 10000;

    uint16 public constant TOLERATED_SLIPPAGE = 100; // 1%

    uint16 public constant TOLERATED_STRATEGY_LOSS = 10; // 0.1%


    uint8 public constant VERSION = 1;

    ERC20 public override token;

    ITrueStrategy public strategy;
    ITrueLender2 public lender;

    uint256 public joiningFee;
    uint256 public claimableFees;

    mapping(address => uint256) latestJoinBlock;

    IERC20 public liquidationToken;

    ITrueFiPoolOracle public override oracle;

    bool public pauseStatus;

    bool private inSync;
    uint256 private strategyValueCache;
    uint256 private loansValueCache;

    address public beneficiary;

    I1Inch3 public _1Inch;

    ISAFU public safu;


    function concat(string memory a, string memory b) internal pure returns (string memory) {

        return string(abi.encodePacked(a, b));
    }

    function initialize(
        ERC20 _token,
        ERC20 _liquidationToken,
        ITrueLender2 _lender,
        I1Inch3 __1Inch,
        ISAFU _safu,
        address __owner
    ) external override initializer {

        ERC20.__ERC20_initialize(concat("TrueFi ", _token.name()), concat("tf", _token.symbol()));
        UpgradeableClaimable.initialize(__owner);

        token = _token;
        liquidationToken = _liquidationToken;
        lender = _lender;
        safu = _safu;
        _1Inch = __1Inch;
    }

    event JoiningFeeChanged(uint256 newFee);

    event BeneficiaryChanged(address newBeneficiary);

    event OracleChanged(ITrueFiPoolOracle newOracle);

    event Joined(address indexed staker, uint256 deposited, uint256 minted);

    event Exited(address indexed staker, uint256 amount);

    event Flushed(uint256 currencyAmount);

    event Pulled(uint256 minTokenAmount);

    event Borrow(address borrower, uint256 amount);

    event Repaid(address indexed payer, uint256 amount);

    event Collected(address indexed beneficiary, uint256 amount);

    event StrategySwitched(ITrueStrategy newStrategy);

    event PauseStatusChanged(bool pauseStatus);

    event SafuChanged(ISAFU newSafu);

    modifier onlyLender() {

        require(msg.sender == address(lender), "TrueFiPool: Caller is not the lender");
        _;
    }

    modifier joiningNotPaused() {

        require(!pauseStatus, "TrueFiPool: Joining the pool is paused");
        _;
    }

    modifier sync() {

        strategyValueCache = strategyValue();
        loansValueCache = loansValue();
        inSync = true;
        _;
        inSync = false;
        strategyValueCache = 0;
        loansValueCache = 0;
    }

    function setPauseStatus(bool status) external override onlyOwner {

        pauseStatus = status;
        emit PauseStatusChanged(status);
    }

    function setSafuAddress(ISAFU _safu) external onlyOwner {

        safu = _safu;
        emit SafuChanged(_safu);
    }

    function decimals() public override view returns (uint8) {

        return token.decimals();
    }

    function liquidValue() public view returns (uint256) {

        return currencyBalance().add(strategyValue());
    }

    function strategyValue() public view returns (uint256) {

        if (address(strategy) == address(0)) {
            return 0;
        }
        if (inSync) {
            return strategyValueCache;
        }
        return strategy.value();
    }

    function poolValue() public view returns (uint256) {

        return liquidValue().add(loansValue()).add(deficitValue());
    }

    function deficitValue() public view returns (uint256) {

        if (address(safu) == address(0)) {
            return 0;
        }
        return safu.poolDeficit(address(this));
    }

    function liquidationTokenBalance() public view returns (uint256) {

        return liquidationToken.balanceOf(address(this));
    }

    function liquidationTokenValue() public view returns (uint256) {

        uint256 balance = liquidationTokenBalance();
        if (balance == 0 || address(oracle) == address(0)) {
            return 0;
        }
        return withToleratedSlippage(oracle.truToToken(balance));
    }

    function loansValue() public view returns (uint256) {

        if (inSync) {
            return loansValueCache;
        }
        return lender.value(this);
    }

    function ensureSufficientLiquidity(uint256 neededAmount) internal {

        uint256 currentlyAvailableAmount = currencyBalance();
        if (currentlyAvailableAmount < neededAmount) {
            require(address(strategy) != address(0), "TrueFiPool: Pool has no strategy to withdraw from");
            strategy.withdraw(neededAmount.sub(currentlyAvailableAmount));
            require(currencyBalance() >= neededAmount, "TrueFiPool: Not enough funds taken from the strategy");
        }
    }

    function setJoiningFee(uint256 fee) external onlyOwner {

        require(fee <= BASIS_PRECISION, "TrueFiPool: Fee cannot exceed transaction value");
        joiningFee = fee;
        emit JoiningFeeChanged(fee);
    }

    function setBeneficiary(address newBeneficiary) external onlyOwner {

        require(newBeneficiary != address(0), "TrueFiPool: Beneficiary address cannot be set to 0");
        beneficiary = newBeneficiary;
        emit BeneficiaryChanged(newBeneficiary);
    }

    function join(uint256 amount) external override joiningNotPaused {

        uint256 fee = amount.mul(joiningFee).div(BASIS_PRECISION);
        uint256 mintedAmount = mint(amount.sub(fee));
        claimableFees = claimableFees.add(fee);

        latestJoinBlock[tx.origin] = block.number;
        token.safeTransferFrom(msg.sender, address(this), amount);

        emit Joined(msg.sender, amount, mintedAmount);
    }

    function exit(uint256 amount) external {

        require(block.number != latestJoinBlock[tx.origin], "TrueFiPool: Cannot join and exit in same block");
        require(amount <= balanceOf(msg.sender), "TrueFiPool: Insufficient funds");

        uint256 _totalSupply = totalSupply();

        uint256 liquidAmountToTransfer = amount.mul(liquidValue()).div(_totalSupply);

        _burn(msg.sender, amount);

        lender.distribute(msg.sender, amount, _totalSupply);

        if (liquidAmountToTransfer > 0) {
            ensureSufficientLiquidity(liquidAmountToTransfer);
            token.safeTransfer(msg.sender, liquidAmountToTransfer);
        }

        emit Exited(msg.sender, amount);
    }

    function liquidExit(uint256 amount) external sync {

        require(block.number != latestJoinBlock[tx.origin], "TrueFiPool: Cannot join and exit in same block");
        require(amount <= balanceOf(msg.sender), "TrueFiPool: Insufficient funds");

        uint256 amountToWithdraw = poolValue().mul(amount).div(totalSupply());
        amountToWithdraw = amountToWithdraw.mul(liquidExitPenalty(amountToWithdraw)).div(BASIS_PRECISION);
        require(amountToWithdraw <= liquidValue(), "TrueFiPool: Not enough liquidity in pool");

        _burn(msg.sender, amount);

        ensureSufficientLiquidity(amountToWithdraw);

        token.safeTransfer(msg.sender, amountToWithdraw);

        emit Exited(msg.sender, amountToWithdraw);
    }

    function liquidExitPenalty(uint256 amount) public view returns (uint256) {

        uint256 lv = liquidValue();
        uint256 pv = poolValue();
        if (amount == pv) {
            return BASIS_PRECISION;
        }
        uint256 liquidRatioBefore = lv.mul(BASIS_PRECISION).div(pv);
        uint256 liquidRatioAfter = lv.sub(amount).mul(BASIS_PRECISION).div(pv.sub(amount));
        return BASIS_PRECISION.sub(averageExitPenalty(liquidRatioAfter, liquidRatioBefore));
    }

    function integrateAtPoint(uint256 x) public pure returns (uint256) {

        return uint256(ABDKMath64x64.ln(ABDKMath64x64.fromUInt(x.add(50)))).mul(50000).div(2**64);
    }

    function averageExitPenalty(uint256 from, uint256 to) public pure returns (uint256) {

        require(from <= to, "TrueFiPool: To precedes from");
        if (from == BASIS_PRECISION) {
            return 0;
        }
        if (from == to) {
            return uint256(50000).div(from.add(50));
        }
        return integrateAtPoint(to).sub(integrateAtPoint(from)).div(to.sub(from));
    }

    function flush(uint256 amount) external {

        require(address(strategy) != address(0), "TrueFiPool: Pool has no strategy set up");
        require(amount <= currencyBalance(), "TrueFiPool: Insufficient currency balance");

        uint256 expectedMinStrategyValue = strategy.value().add(withToleratedStrategyLoss(amount));
        token.safeApprove(address(strategy), amount);
        strategy.deposit(amount);
        require(strategy.value() >= expectedMinStrategyValue, "TrueFiPool: Strategy value expected to be higher");
        emit Flushed(amount);
    }

    function pull(uint256 minTokenAmount) external onlyOwner {

        require(address(strategy) != address(0), "TrueFiPool: Pool has no strategy set up");

        uint256 expectedCurrencyBalance = currencyBalance().add(minTokenAmount);
        strategy.withdraw(minTokenAmount);
        require(currencyBalance() >= expectedCurrencyBalance, "TrueFiPool: Currency balance expected to be higher");

        emit Pulled(minTokenAmount);
    }

    function borrow(uint256 amount) external override onlyLender {

        require(amount <= liquidValue(), "TrueFiPool: Insufficient liquidity");
        if (amount > 0) {
            ensureSufficientLiquidity(amount);
        }

        token.safeTransfer(msg.sender, amount);

        emit Borrow(msg.sender, amount);
    }

    function repay(uint256 currencyAmount) external override onlyLender {

        token.safeTransferFrom(msg.sender, address(this), currencyAmount);
        emit Repaid(msg.sender, currencyAmount);
    }

    function collectFees() external {

        require(beneficiary != address(0), "TrueFiPool: Beneficiary is not set");

        uint256 amount = claimableFees;
        claimableFees = 0;

        if (amount > 0) {
            token.safeTransfer(beneficiary, amount);
        }

        emit Collected(beneficiary, amount);
    }

    function switchStrategy(ITrueStrategy newStrategy) external onlyOwner {

        require(strategy != newStrategy, "TrueFiPool: Cannot switch to the same strategy");

        ITrueStrategy previousStrategy = strategy;
        strategy = newStrategy;

        if (address(previousStrategy) != address(0)) {
            uint256 expectedMinCurrencyBalance = currencyBalance().add(withToleratedStrategyLoss(previousStrategy.value()));
            previousStrategy.withdrawAll();
            require(currencyBalance() >= expectedMinCurrencyBalance, "TrueFiPool: All funds should be withdrawn to pool");
            require(previousStrategy.value() == 0, "TrueFiPool: Switched strategy should be depleted");
        }

        emit StrategySwitched(newStrategy);
    }

    function liquidate(ILoanToken2 loan) external override {

        PoolExtensions._liquidate(safu, loan, lender);
    }

    function setOracle(ITrueFiPoolOracle newOracle) external onlyOwner {

        oracle = newOracle;
        emit OracleChanged(newOracle);
    }

    function sellLiquidationToken(bytes calldata data) external {

        (I1Inch3.SwapDescription memory swap, uint256 balanceDiff) = _1Inch.exchange(data);

        uint256 expectedGain = oracle.truToToken(swap.amount);
        require(balanceDiff >= withToleratedSlippage(expectedGain), "TrueFiPool: Not optimal exchange");

        require(swap.srcToken == address(liquidationToken), "TrueFiPool: Source token is not TRU");
        require(swap.dstToken == address(token), "TrueFiPool: Invalid destination token");
        require(swap.dstReceiver == address(this), "TrueFiPool: Receiver is not pool");
    }

    function currencyBalance() public view returns (uint256) {

        return token.balanceOf(address(this)).sub(claimableFees);
    }

    function mint(uint256 depositedAmount) internal returns (uint256) {

        if (depositedAmount == 0) {
            return depositedAmount;
        }
        uint256 mintedAmount = depositedAmount;

        if (totalSupply() > 0) {
            mintedAmount = totalSupply().mul(depositedAmount).div(poolValue());
        }
        _mint(msg.sender, mintedAmount);

        return mintedAmount;
    }

    function withToleratedSlippage(uint256 amount) internal pure returns (uint256) {

        return amount.mul(BASIS_PRECISION - TOLERATED_SLIPPAGE).div(BASIS_PRECISION);
    }

    function withToleratedStrategyLoss(uint256 amount) internal pure returns (uint256) {

        return amount.mul(BASIS_PRECISION - TOLERATED_STRATEGY_LOSS).div(BASIS_PRECISION);
    }
}