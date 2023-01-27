




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






interface IStakingPool is IERC20 {

    function stakeSupply() external view returns (uint256);


    function withdraw(uint256 amount) external;


    function payFee(uint256 amount, uint256 endTime) external;

}




interface IPoolFactory {

    function isPool(address pool) external view returns (bool);

}




interface ITrueRatingAgency {

    function getResults(address id)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function submit(address id) external;


    function retract(address id) external;


    function yes(address id, uint256 stake) external;


    function no(address id, uint256 stake) external;


    function withdraw(address id, uint256 stake) external;


    function claim(address id, address voter) external;

}



pragma solidity 0.6.10;




contract TrueLender2 is ITrueLender2, UpgradeableClaimable {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using SafeERC20 for IERC20WithDecimals;
    using OneInchExchange for I1Inch3;

    uint256 private constant BASIS_RATIO = 10000;

    uint256 private constant ONE_INCH_PARTIAL_FILL_FLAG = 0x01;


    mapping(ITrueFiPool2 => ILoanToken2[]) public poolLoans;

    uint256 public maxLoans;

    uint256 public fee;

    IStakingPool public stakingPool;

    IPoolFactory public factory;

    ITrueRatingAgency public ratingAgency;

    I1Inch3 public _1inch;

    IERC20WithDecimals public feeToken;
    ITrueFiPool2 public feePool;

    uint256 public swapFeeSlippage;


    uint256 public minVotes;

    uint256 public minRatio;

    uint256 public votingPeriod;


    event LoansLimitChanged(uint256 maxLoans);

    event MinVotesChanged(uint256 minVotes);

    event MinRatioChanged(uint256 minRatio);

    event VotingPeriodChanged(uint256 votingPeriod);

    event FeeChanged(uint256 newFee);

    event FeePoolChanged(ITrueFiPool2 newFeePool);

    event Funded(address indexed pool, address loanToken, uint256 amount);

    event Reclaimed(address indexed pool, address loanToken, uint256 amount);

    modifier onlyPool() {

        require(factory.isPool(msg.sender), "TrueLender: Pool not created by the factory");
        _;
    }

    function initialize(
        IStakingPool _stakingPool,
        IPoolFactory _factory,
        ITrueRatingAgency _ratingAgency,
        I1Inch3 __1inch
    ) public initializer {

        UpgradeableClaimable.initialize(msg.sender);

        stakingPool = _stakingPool;
        factory = _factory;
        ratingAgency = _ratingAgency;
        _1inch = __1inch;

        swapFeeSlippage = 100; // 1%
        minVotes = 15 * (10**6) * (10**8);
        minRatio = 8000;
        votingPeriod = 7 days;
        fee = 1000;
        maxLoans = 100;
    }

    function setVotingPeriod(uint256 newVotingPeriod) external onlyOwner {

        votingPeriod = newVotingPeriod;
        emit VotingPeriodChanged(newVotingPeriod);
    }

    function setMinVotes(uint256 newMinVotes) external onlyOwner {

        minVotes = newMinVotes;
        emit MinVotesChanged(newMinVotes);
    }

    function setMinRatio(uint256 newMinRatio) external onlyOwner {

        require(newMinRatio <= BASIS_RATIO, "TrueLender: minRatio cannot be more than 100%");
        minRatio = newMinRatio;
        emit MinRatioChanged(newMinRatio);
    }

    function setLoansLimit(uint256 newLoansLimit) external onlyOwner {

        maxLoans = newLoansLimit;
        emit LoansLimitChanged(maxLoans);
    }

    function setFeePool(ITrueFiPool2 newFeePool) external onlyOwner {

        feeToken = IERC20WithDecimals(address(newFeePool.token()));
        feePool = newFeePool;
        emit FeePoolChanged(newFeePool);
    }

    function setFee(uint256 newFee) external onlyOwner {

        require(newFee <= BASIS_RATIO, "TrueLender: fee cannot be more than 100%");
        fee = newFee;
        emit FeeChanged(newFee);
    }

    function loans(ITrueFiPool2 pool) public view returns (ILoanToken2[] memory result) {

        result = poolLoans[pool];
    }

    function fund(ILoanToken2 loanToken) external {

        require(msg.sender == loanToken.borrower(), "TrueLender: Sender is not borrower");
        ITrueFiPool2 pool = loanToken.pool();

        require(factory.isPool(address(pool)), "TrueLender: Pool not created by the factory");
        require(loanToken.token() == pool.token(), "TrueLender: Loan and pool token mismatch");
        require(poolLoans[pool].length < maxLoans, "TrueLender: Loans number has reached the limit");

        uint256 amount = loanToken.amount();
        (uint256 start, uint256 no, uint256 yes) = ratingAgency.getResults(address(loanToken));

        require(votingLastedLongEnough(start), "TrueLender: Voting time is below minimum");
        require(votesThresholdReached(yes.add(no)), "TrueLender: Not enough votes given for the loan");
        require(loanIsCredible(yes, no), "TrueLender: Loan risk is too high");

        poolLoans[pool].push(loanToken);
        pool.borrow(amount);
        pool.token().safeApprove(address(loanToken), amount);
        loanToken.fund();

        emit Funded(address(pool), address(loanToken), amount);
    }

    function value(ITrueFiPool2 pool) external override view returns (uint256) {

        ILoanToken2[] storage _loans = poolLoans[pool];
        uint256 totalValue;
        for (uint256 index = 0; index < _loans.length; index++) {
            totalValue = totalValue.add(_loans[index].value(_loans[index].balanceOf(address(this))));
        }
        return totalValue;
    }

    function reclaim(ILoanToken2 loanToken, bytes calldata data) external {

        ITrueFiPool2 pool = loanToken.pool();
        ILoanToken2.Status status = loanToken.status();
        require(status >= ILoanToken2.Status.Settled, "TrueLender: LoanToken is not closed yet");

        if (status != ILoanToken2.Status.Settled) {
            require(msg.sender == owner(), "TrueLender: Only owner can reclaim from defaulted loan");
        }

        ILoanToken2[] storage _loans = poolLoans[pool];
        for (uint256 index = 0; index < _loans.length; index++) {
            if (_loans[index] == loanToken) {
                _loans[index] = _loans[_loans.length - 1];
                _loans.pop();

                uint256 fundsReclaimed = _redeemAndRepay(loanToken, pool, data);
                emit Reclaimed(address(pool), address(loanToken), fundsReclaimed);
                return;
            }
        }
        revert("TrueLender: This loan has not been funded by the lender");
    }

    function _redeemAndRepay(
        ILoanToken2 loanToken,
        ITrueFiPool2 pool,
        bytes calldata data
    ) internal returns (uint256) {

        uint256 balanceBefore = pool.token().balanceOf(address(this));
        loanToken.redeem(loanToken.balanceOf(address(this)));
        uint256 balanceAfter = pool.token().balanceOf(address(this));

        uint256 fundsReclaimed = balanceAfter.sub(balanceBefore);

        uint256 feeAmount = 0;
        if (address(feeToken) != address(0)) {
            feeAmount = _swapFee(pool, loanToken, data);
        }

        pool.token().safeApprove(address(pool), fundsReclaimed.sub(feeAmount));
        pool.repay(fundsReclaimed.sub(feeAmount));

        if (address(feeToken) != address(0)) {
            _transferFeeToStakers();
        }
        return fundsReclaimed;
    }

    function _swapFee(
        ITrueFiPool2 pool,
        ILoanToken2 loanToken,
        bytes calldata data
    ) internal returns (uint256) {

        uint256 feeAmount = loanToken.debt().sub(loanToken.amount()).mul(fee).div(BASIS_RATIO);
        IERC20WithDecimals token = IERC20WithDecimals(address(pool.token()));
        if (token == feeToken) {
            return feeAmount;
        }
        if (feeAmount == 0) {
            return 0;
        }
        (I1Inch3.SwapDescription memory swap, uint256 balanceDiff) = _1inch.exchange(data);
        uint256 expectedDiff = pool.oracle().tokenToUsd(feeAmount).mul(10**feeToken.decimals()).div(1 ether);

        require(swap.srcToken == address(token), "TrueLender: Source token is not same as pool's token");
        require(swap.dstToken == address(feeToken), "TrueLender: Destination token is not fee token");
        require(swap.dstReceiver == address(this), "TrueLender: Receiver is not lender");
        require(swap.amount == feeAmount, "TrueLender: Incorrect fee swap amount");
        require(swap.flags & ONE_INCH_PARTIAL_FILL_FLAG == 0, "TrueLender: Partial fill is not allowed");
        require(
            balanceDiff >= expectedDiff.mul(BASIS_RATIO.sub(swapFeeSlippage)).div(BASIS_RATIO),
            "TrueLender: Fee returned from swap is too small"
        );

        return feeAmount;
    }

    function _transferFeeToStakers() internal {

        uint256 amount = feeToken.balanceOf(address(this));
        if (amount == 0) {
            return;
        }
        feeToken.safeApprove(address(feePool), amount);
        feePool.join(amount);
        feePool.transfer(address(stakingPool), feePool.balanceOf(address(this)));
    }

    function distribute(
        address recipient,
        uint256 numerator,
        uint256 denominator
    ) external override onlyPool {

        _distribute(recipient, numerator, denominator, msg.sender);
    }

    function transferAllLoanTokens(ILoanToken2 loan, address recipient) external override onlyPool {

        _transferAllLoanTokens(loan, recipient);
    }

    function _transferAllLoanTokens(ILoanToken2 loan, address recipient) internal {

        ILoanToken2[] storage _loans = poolLoans[loan.pool()];
        for (uint256 index = 0; index < _loans.length; index++) {
            if (_loans[index] == loan) {
                _loans[index] = _loans[_loans.length - 1];
                _loans.pop();

                _transferLoan(loan, recipient, 1, 1);
                return;
            }
        }
        revert("TrueLender: This loan has not been funded by the lender");
    }

    function votingLastedLongEnough(uint256 start) public view returns (bool) {

        return start.add(votingPeriod) <= block.timestamp;
    }

    function votesThresholdReached(uint256 votes) public view returns (bool) {

        return votes >= minVotes;
    }

    function loanIsCredible(uint256 yesVotes, uint256 noVotes) public view returns (bool) {

        uint256 totalVotes = yesVotes.add(noVotes);
        return yesVotes >= totalVotes.mul(minRatio).div(BASIS_RATIO);
    }

    function _distribute(
        address recipient,
        uint256 numerator,
        uint256 denominator,
        address pool
    ) internal {

        ILoanToken2[] storage _loans = poolLoans[ITrueFiPool2(pool)];
        for (uint256 index = 0; index < _loans.length; index++) {
            _transferLoan(_loans[index], recipient, numerator, denominator);
        }
    }

    function _transferLoan(
        ILoanToken2 loan,
        address recipient,
        uint256 numerator,
        uint256 denominator
    ) internal {

        loan.transfer(recipient, numerator.mul(loan.balanceOf(address(this))).div(denominator));
    }
}