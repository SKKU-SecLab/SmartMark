
pragma experimental ABIEncoderV2;
pragma solidity 0.6.4;


interface IInterestRateModel {

    function utilizationRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external pure returns (uint256);


    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256);


    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) external view returns (uint256);


    function APR(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256);


    function APY(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) external view returns (uint256);

}

interface IBankController {

    function getCashPrior(address underlying) external view returns (uint256);


    function getCashAfter(address underlying, uint256 msgValue)
        external
        view
        returns (uint256);


    function getFTokeAddress(address underlying)
        external
        view
        returns (address);


    function transferToUser(
        address token,
        address payable user,
        uint256 amount
    ) external;


    function transferIn(
        address account,
        address underlying,
        uint256 amount
    ) external payable;


    function borrowCheck(
        address account,
        address underlying,
        address fToken,
        uint256 borrowAmount
    ) external;


    function repayCheck(address underlying) external;


    function liquidateBorrowCheck(
        address fTokenBorrowed,
        address fTokenCollateral,
        address borrower,
        address liquidator,
        uint256 repayAmount
    ) external;


    function liquidateTokens(
        address fTokenBorrowed,
        address fTokenCollateral,
        uint256 actualRepayAmount
    ) external view returns (uint256);


    function withdrawCheck(
        address fToken,
        address withdrawer,
        uint256 withdrawTokens
    ) external view returns (uint256);


    function transferCheck(
        address fToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;


    function marketsContains(address fToken) external view returns (bool);


    function seizeCheck(address cTokenCollateral, address cTokenBorrowed)
        external;


    function mintCheck(address underlying, address minter, uint256 amount) external;


    function addReserves(address underlying, uint256 addAmount)
        external
        payable;


    function reduceReserves(
        address underlying,
        address payable account,
        uint256 reduceAmount
    ) external;


    function calcMaxBorrowAmount(address user, address token)
        external
        view
        returns (uint256);


    function calcMaxWithdrawAmount(address user, address token)
        external
        view
        returns (uint256);


    function calcMaxCashOutAmount(address user, address token)
        external
        view
        returns (uint256);


    function calcMaxBorrowAmountWithRatio(address user, address token)
        external
        view
        returns (uint256);


    function transferEthGasCost() external view returns (uint256);


    function isFTokenValid(address fToken) external view returns (bool);


    function balance(address token) external view returns (uint256);

    function flashloanFeeBips() external view returns (uint256);

    function flashloanVault() external view returns (address);

    function transferFlashloanAsset(
        address token,
        address payable user,
        uint256 amount
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
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

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a <= b ? a : b;
    }

    function abs(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a < b) {
            return b - a;
        }
        return a - b;
    }
}

contract Exponential {

    uint256 constant expScale = 1e18;
    uint256 constant doubleScale = 1e36;
    uint256 constant halfExpScale = expScale / 2;

    using SafeMath for uint256;

    function getExp(uint256 num, uint256 denom)
        public
        pure
        returns (uint256 rational)
    {

        rational = num.mul(expScale).div(denom);
    }

    function getDiv(uint256 num, uint256 denom)
        public
        pure
        returns (uint256 rational)
    {

        rational = num.mul(expScale).div(denom);
    }

    function addExp(uint256 a, uint256 b) public pure returns (uint256 result) {

        result = a.add(b);
    }

    function subExp(uint256 a, uint256 b) public pure returns (uint256 result) {

        result = a.sub(b);
    }

    function mulExp(uint256 a, uint256 b) public pure returns (uint256) {

        uint256 doubleScaledProduct = a.mul(b);

        uint256 doubleScaledProductWithHalfScale = halfExpScale.add(
            doubleScaledProduct
        );

        return doubleScaledProductWithHalfScale.div(expScale);
    }

    function divExp(uint256 a, uint256 b) public pure returns (uint256) {

        return getDiv(a, b);
    }

    function mulExp3(
        uint256 a,
        uint256 b,
        uint256 c
    ) public pure returns (uint256) {

        return mulExp(mulExp(a, b), c);
    }

    function mulScalar(uint256 a, uint256 scalar)
        public
        pure
        returns (uint256 scaled)
    {

        scaled = a.mul(scalar);
    }

    function mulScalarTruncate(uint256 a, uint256 scalar)
        public
        pure
        returns (uint256)
    {

        uint256 product = mulScalar(a, scalar);
        return truncate(product);
    }

    function mulScalarTruncateAddUInt(
        uint256 a,
        uint256 scalar,
        uint256 addend
    ) public pure returns (uint256) {

        uint256 product = mulScalar(a, scalar);
        return truncate(product).add(addend);
    }

    function divScalarByExpTruncate(uint256 scalar, uint256 divisor)
        public
        pure
        returns (uint256)
    {

        uint256 fraction = divScalarByExp(scalar, divisor);
        return truncate(fraction);
    }

    function divScalarByExp(uint256 scalar, uint256 divisor)
        public
        pure
        returns (uint256)
    {

        uint256 numerator = expScale.mul(scalar);
        return getExp(numerator, divisor);
    }

    function divScalar(uint256 a, uint256 scalar)
        public
        pure
        returns (uint256)
    {

        return a.div(scalar);
    }

    function truncate(uint256 exp) public pure returns (uint256) {

        return exp.div(expScale);
    }
}

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

    function decimals() external view returns (uint8);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

library EthAddressLib {

    function ethAddress() internal pure returns (address) {

        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }
}

interface IFToken is IERC20 {

    function mint(address user, uint256 amount) external returns (bytes memory);


    function borrow(address borrower, uint256 borrowAmount)
        external
        returns (bytes memory);


    function withdraw(
        address payable withdrawer,
        uint256 withdrawTokensIn,
        uint256 withdrawAmountIn
    ) external returns (uint256, bytes memory);


    function underlying() external view returns (address);


    function accrueInterest() external;


    function getAccountState(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function MonitorEventCallback(
        address who,
        bytes32 funcName,
        bytes calldata payload
    ) external;


    function exchangeRateCurrent() external view returns (uint256 exchangeRate);


    function repay(address borrower, uint256 repayAmount)
        external
        returns (uint256, bytes memory);


    function borrowBalanceStored(address account)
        external
        view
        returns (uint256);


    function exchangeRateStored() external view returns (uint256 exchangeRate);


    function liquidateBorrow(
        address liquidator,
        address borrower,
        uint256 repayAmount,
        address fTokenCollateral
    ) external returns (bytes memory);


    function borrowBalanceCurrent(address account) external returns (uint256);


    function balanceOfUnderlying(address owner) external returns (uint256);


    function _reduceReserves(uint256 reduceAmount) external;


    function _addReservesFresh(uint256 addAmount) external;


    function cancellingOut(address striker)
        external
        returns (bool strikeOk, bytes memory strikeLog);


    function APR() external view returns (uint256);


    function APY() external view returns (uint256);


    function calcBalanceOfUnderlying(address owner)
        external
        view
        returns (uint256);


    function borrowSafeRatio() external view returns (uint256);


    function tokenCash(address token, address account)
        external
        view
        returns (uint256);


    function getBorrowRate() external view returns (uint256);


    function addTotalCash(uint256 _addAmount) external;

    function subTotalCash(uint256 _subAmount) external;


    function totalCash() external view returns (uint256);

    function totalReserves() external view returns (uint256);

    function totalBorrows() external view returns (uint256);

}

interface IBank {

    function MonitorEventCallback(bytes32 funcName, bytes calldata payload)
        external;


    function deposit(address token, uint256 amount) external payable;


    function borrow(address token, uint256 amount) external;


    function withdraw(address underlying, uint256 withdrawTokens) external;


    function withdrawUnderlying(address underlying, uint256 amount) external;


    function repay(address token, uint256 amount) external payable;


    function liquidateBorrow(
        address borrower,
        address underlyingBorrow,
        address underlyingCollateral,
        uint256 repayAmount
    ) external payable;


    function tokenIn(address token, uint256 amountIn) external payable;


    function tokenOut(address token, uint256 amountOut) external;


    function cancellingOut(address token) external;


    function paused() external view returns (bool);

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
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

contract FToken is Exponential, Initializable {

    using SafeERC20 for IERC20;

    uint256 public totalSupply;

    string public name;

    string public symbol;

    uint8 public decimals;

    mapping(address => mapping(address => uint256)) internal transferAllowances;

    uint256 public initialExchangeRate;

    address public admin;

    uint256 public totalBorrows;

    uint256 public totalReserves;

    uint256 public reserveFactor;

    uint256 public borrowIndex;

    uint256 internal constant borrowRateMax = 0.0005e16;

    uint256 public accrualBlockNumber;

    IInterestRateModel public interestRateModel;

    address public underlying;

    mapping(address => uint256) public accountTokens;

    IBankController public controller;

    uint256 public borrowSafeRatio;

    address public bank; // bank主合约入口地址

    bool internal _notEntered;

    uint256 public constant ONE = 1e18;

    struct BorrowSnapshot {
        uint256 principal;
        uint256 interestIndex;
    }

    mapping(address => BorrowSnapshot) public accountBorrows;
    uint256 public totalCash;
    address public proposedAdmin;
    bool public isInited;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event NewInterestRateModel(address oldIRM, uint256 oldUR, uint256 oldAPR, uint256 oldAPY, uint256 exRate1,
        address newIRM, uint256 newUR, uint256 newAPR, uint256 newAPY, uint256 exRate2
    );
    event NewInitialExchangeRate(uint256 oldInitialExchangeRate, uint256 oldUR, uint256 oldAPR, uint256 oldAPY, uint256 exRate1,
        uint256 _initialExchangeRate, uint256 newUR, uint256 newAPR, uint256 newAPY, uint256 exRate2);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function initialize(
        uint256 _initialExchangeRate,
        address _controller,
        address _initialInterestRateModel,
        address _underlying,
        address _bank,
        uint256 _borrowSafeRatio,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) public initializer {

        initialExchangeRate = _initialExchangeRate;
        controller = IBankController(_controller);
        interestRateModel = IInterestRateModel(_initialInterestRateModel);
        admin = msg.sender;
        underlying = _underlying;
        borrowSafeRatio = _borrowSafeRatio;
        accrualBlockNumber = getBlockNumber();
        borrowIndex = ONE;
        bank = _bank;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _notEntered = true;
    }

    modifier onlyAdmin {

        require(msg.sender == admin, "require admin");
        _;
    }

    modifier onlyBank {

        require(msg.sender == bank, "require admin");
        _;
    }

    modifier onlyController {

        require(msg.sender == address(controller), "require controller");
        _;
    }

    modifier onlyRestricted {

        require(
            msg.sender == admin ||
                msg.sender == bank ||
                msg.sender == address(controller) ||
                controller.marketsContains(msg.sender),
            "only restricted user"
        );
        _;
    }

    modifier onlyBankComponent {

        require(
            msg.sender == bank ||
                msg.sender == address(controller) ||
                msg.sender == address(this) ||
                controller.marketsContains(msg.sender),
            "only bank component"
        );
        _;
    }

    modifier whenUnpaused {

        require(!IBank(bank).paused(), "System paused");
        _;
    }

    function setAdmin(address admin_) external onlyAdmin {

        require(!isInited, "already inited");
        admin = admin_;
        isInited = true;
    }

    function proposeNewAdmin(address admin_) external onlyAdmin {

        proposedAdmin = admin_;
    }

    function claimAdministration() external {

        require(msg.sender == proposedAdmin, "Not proposed admin.");
        admin = proposedAdmin;
        proposedAdmin = address(0);
    }

    function _setController(address _controller) external onlyAdmin {

        controller = IBankController(_controller);
    }

    function tokenCash(address token, address account)
        public
        view
        returns (uint256)
    {

        return
            token != EthAddressLib.ethAddress()
                ? IERC20(token).balanceOf(account)
                : address(account).balance;
    }

    struct TransferLogStruct {
        address user_address;
        address token_address;
        address cheque_token_address;
        uint256 amount_transferred;
        uint256 account_balance;
        address payee_address;
        uint256 payee_balance;
        uint256 global_token_reserved;
    }

    function transfer(address dst, uint256 amount)
        external
        nonReentrant
        returns (bool)
    {

        transferTokens(msg.sender, msg.sender, dst, amount);

        TransferLogStruct memory tls = TransferLogStruct(
            msg.sender,
            underlying,
            address(this),
            amount,
            balanceOf(msg.sender),
            dst,
            balanceOf(dst),
            tokenCash(underlying, address(controller))
        );

        IBank(bank).MonitorEventCallback("Transfer", abi.encode(tls));

        return true;
    }

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external nonReentrant returns (bool) {

        transferTokens(msg.sender, src, dst, amount);

        TransferLogStruct memory tls = TransferLogStruct(
            src,
            underlying,
            address(this),
            amount,
            balanceOf(src),
            dst,
            balanceOf(dst),
            tokenCash(underlying, address(controller))
        );

        IBank(bank).MonitorEventCallback("TransferFrom", abi.encode(tls));

        return true;
    }

    function transferTokens(
        address spender,
        address src,
        address dst,
        uint256 tokens
    ) internal whenUnpaused returns (bool) {

        controller.transferCheck(address(this), src, dst, mulScalarTruncate(tokens, borrowSafeRatio));

        require(src != dst, "Cannot transfer to self");

        uint256 startingAllowance = 0;
        if (spender == src) {
            startingAllowance = uint256(-1);
        } else {
            startingAllowance = transferAllowances[src][spender];
        }

        uint256 allowanceNew = startingAllowance.sub(tokens);

        accountTokens[src] = accountTokens[src].sub(tokens);
        accountTokens[dst] = accountTokens[dst].add(tokens);

        if (startingAllowance != uint256(-1)) {
            transferAllowances[src][spender] = allowanceNew;
        }

        emit Transfer(src, dst, tokens);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {

        address src = msg.sender;
        transferAllowances[src][spender] = amount;
        emit Approval(src, spender, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {

        return transferAllowances[owner][spender];
    }

    struct MintLocals {
        uint256 exchangeRate;
        uint256 mintTokens;
        uint256 totalSupplyNew;
        uint256 accountTokensNew;
        uint256 actualMintAmount;
    }

    struct DepositLogStruct {
        address user_address;
        address token_address;
        address cheque_token_address;
        uint256 amount_deposited;
        uint256 underlying_deposited;
        uint256 cheque_token_value;
        uint256 loan_interest_rate;
        uint256 account_balance;
        uint256 global_token_reserved;
    }

    function mint(address user, uint256 amount)
        external
        onlyBank
        nonReentrant
        returns (bytes memory)
    {

        accrueInterest();
        return mintInternal(user, amount);
    }

    function mintInternal(address user, uint256 amount)
        internal
        returns (bytes memory)
    {

        require(accrualBlockNumber == getBlockNumber(), "Blocknumber fails");
        MintLocals memory tmp;
        controller.mintCheck(underlying, user, amount);
        tmp.exchangeRate = exchangeRateStored();
        tmp.mintTokens = divScalarByExpTruncate(amount, tmp.exchangeRate);
        tmp.totalSupplyNew = addExp(totalSupply, tmp.mintTokens);
        tmp.accountTokensNew = addExp(accountTokens[user], tmp.mintTokens);
        totalSupply = tmp.totalSupplyNew;
        accountTokens[user] = tmp.accountTokensNew;

        uint256 preCalcTokenCash = tokenCash(underlying, address(controller))
            .add(amount);

        DepositLogStruct memory dls = DepositLogStruct(
            user,
            underlying,
            address(this),
            tmp.mintTokens,
            amount,
            exchangeRateAfter(amount), //cheque_token_value, 存之后的交换率（预判）
            interestRateModel.getBorrowRate(
                preCalcTokenCash,
                totalBorrows,
                totalReserves
            ), //loan_interest_rate 借款利率,存之后的价款利率
            tokenCash(address(this), user),
            preCalcTokenCash
        );

        emit Transfer(address(0), user, tmp.mintTokens);

        return abi.encode(dls);
    }

    struct BorrowLocals {
        uint256 accountBorrows;
        uint256 accountBorrowsNew;
        uint256 totalBorrowsNew;
    }

    struct BorrowLogStruct {
        address user_address;
        address token_address;
        address cheque_token_address;
        uint256 amount_borrowed;
        uint256 interest_accrued;
        uint256 cheque_token_value;
        uint256 loan_interest_rate;
        uint256 account_debt;
        uint256 global_token_reserved;
    }

    function borrow(address payable borrower, uint256 borrowAmount)
        external
        onlyBank
        nonReentrant
        returns (bytes memory)
    {

        accrueInterest();
        return borrowInternal(borrower, borrowAmount);
    }

    function borrowInternal(address payable borrower, uint256 borrowAmount)
        internal
        returns (bytes memory)
    {

        controller.borrowCheck(
            borrower,
            underlying,
            address(this),
            mulScalarTruncate(borrowAmount, borrowSafeRatio)
        );

        require(
            controller.getCashPrior(underlying) >= borrowAmount,
            "Insufficient balance"
        );

        BorrowLocals memory tmp;
        uint256 lastPrincipal = accountBorrows[borrower].principal;
        tmp.accountBorrows = borrowBalanceStoredInternal(borrower);
        tmp.accountBorrowsNew = addExp(tmp.accountBorrows, borrowAmount);
        tmp.totalBorrowsNew = addExp(totalBorrows, borrowAmount);

        accountBorrows[borrower].principal = tmp.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = tmp.totalBorrowsNew;

        controller.transferToUser(underlying, borrower, borrowAmount);
        subTotalCash(borrowAmount);

        BorrowLogStruct memory bls = BorrowLogStruct(
            borrower,
            underlying,
            address(this),
            borrowAmount,
            SafeMath.abs(tmp.accountBorrows, lastPrincipal),
            exchangeRateStored(),
            getBorrowRate(),
            accountBorrows[borrower].principal,
            tokenCash(underlying, address(controller))
        );

        return abi.encode(bls);
    }

    struct RepayLocals {
        uint256 repayAmount;
        uint256 borrowerIndex;
        uint256 accountBorrows;
        uint256 accountBorrowsNew;
        uint256 totalBorrowsNew;
        uint256 actualRepayAmount;
    }

    function exchangeRateStored() public view returns (uint256 exchangeRate) {

        return calcExchangeRate(totalBorrows, totalReserves);
    }

    function calcExchangeRate(uint256 _totalBorrows, uint256 _totalReserves)
        public
        view
        returns (uint256 exchangeRate)
    {

        uint256 _totalSupply = totalSupply;
        if (_totalSupply == 0) {
            return initialExchangeRate;
        } else {
            uint256 totalCash = controller.getCashPrior(underlying);
            uint256 cashPlusBorrowsMinusReserves = subExp(
                addExp(totalCash, _totalBorrows),
                _totalReserves
            );
            exchangeRate = getDiv(cashPlusBorrowsMinusReserves, _totalSupply);
        }
    }

    function exchangeRateAfter(uint256 transferInAmout)
        public
        view
        returns (uint256 exchangeRate)
    {

        uint256 _totalSupply = totalSupply;
        if (_totalSupply == 0) {
            return initialExchangeRate;
        } else {
            uint256 totalCash = controller.getCashAfter(
                underlying,
                transferInAmout
            );
            uint256 cashPlusBorrowsMinusReserves = subExp(
                addExp(totalCash, totalBorrows),
                totalReserves
            );
            exchangeRate = getDiv(cashPlusBorrowsMinusReserves, _totalSupply);
        }
    }

    function balanceOfUnderlying(address owner) external returns (uint256) {

        uint256 exchangeRate = exchangeRateCurrent();
        uint256 balance = mulScalarTruncate(exchangeRate, accountTokens[owner]);
        return balance;
    }

    function calcBalanceOfUnderlying(address owner)
        public
        view
        returns (uint256)
    {

        (, , uint256 _totalBorrows, uint256 _trotalReserves) = peekInterest();

        uint256 _exchangeRate = calcExchangeRate(
            _totalBorrows,
            _trotalReserves
        );
        uint256 balance = mulScalarTruncate(
            _exchangeRate,
            accountTokens[owner]
        );
        return balance;
    }

    function exchangeRateCurrent() public nonReentrant returns (uint256) {

        accrueInterest();
        return exchangeRateStored();
    }

    function getAccountState(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        uint256 fTokenBalance = accountTokens[account];
        uint256 borrowBalance = borrowBalanceStoredInternal(account);
        uint256 exchangeRate = exchangeRateStored();

        return (fTokenBalance, borrowBalance, exchangeRate);
    }

    struct WithdrawLocals {
        uint256 exchangeRate;
        uint256 withdrawTokens;
        uint256 withdrawAmount;
        uint256 totalSupplyNew;
        uint256 accountTokensNew;
    }

    struct WithdrawLogStruct {
        address user_address;
        address token_address;
        address cheque_token_address;
        uint256 amount_withdrawed;
        uint256 underlying_withdrawed;
        uint256 cheque_token_value;
        uint256 loan_interest_rate;
        uint256 account_balance;
        uint256 global_token_reserved;
    }

    function withdraw(
        address payable withdrawer,
        uint256 withdrawTokensIn,
        uint256 withdrawAmountIn
    ) external onlyBank nonReentrant returns (uint256, bytes memory) {

        accrueInterest();
        return withdrawInternal(withdrawer, withdrawTokensIn, withdrawAmountIn);
    }

    function withdrawInternal(
        address payable withdrawer,
        uint256 withdrawTokensIn,
        uint256 withdrawAmountIn
    ) internal returns (uint256, bytes memory) {

        require(
            withdrawTokensIn == 0 || withdrawAmountIn == 0,
            "withdraw parameter not valid"
        );
        WithdrawLocals memory tmp;

        tmp.exchangeRate = exchangeRateStored();

        if (withdrawTokensIn > 0) {
            tmp.withdrawTokens = withdrawTokensIn;
            tmp.withdrawAmount = mulScalarTruncate(
                tmp.exchangeRate,
                withdrawTokensIn
            );
        } else {
            tmp.withdrawTokens = divScalarByExpTruncate(
                withdrawAmountIn,
                tmp.exchangeRate
            );
            tmp.withdrawAmount = withdrawAmountIn;
        }

        controller.withdrawCheck(address(this), withdrawer, tmp.withdrawTokens);

        require(accrualBlockNumber == getBlockNumber(), "Blocknumber fails");

        tmp.totalSupplyNew = totalSupply.sub(tmp.withdrawTokens);
        tmp.accountTokensNew = accountTokens[withdrawer].sub(
            tmp.withdrawTokens
        );

        require(
            controller.getCashPrior(underlying) >= tmp.withdrawAmount,
            "Insufficient money"
        );

        controller.transferToUser(underlying, withdrawer, tmp.withdrawAmount);
        subTotalCash(tmp.withdrawAmount);

        totalSupply = tmp.totalSupplyNew;
        accountTokens[withdrawer] = tmp.accountTokensNew;

        WithdrawLogStruct memory wls = WithdrawLogStruct(
            withdrawer,
            underlying,
            address(this),
            tmp.withdrawTokens,
            tmp.withdrawAmount,
            exchangeRateStored(),
            getBorrowRate(),
            tokenCash(address(this), withdrawer),
            tokenCash(underlying, address(controller))
        );

        emit Transfer(withdrawer, address(0), tmp.withdrawTokens);

        return (tmp.withdrawAmount, abi.encode(wls));
    }

    function strikeWithdrawInternal(
        address withdrawer,
        uint256 withdrawTokensIn,
        uint256 withdrawAmountIn
    ) internal returns (uint256, bytes memory) {

        require(
            withdrawTokensIn == 0 || withdrawAmountIn == 0,
            "withdraw parameter not valid"
        );
        WithdrawLocals memory tmp;

        tmp.exchangeRate = exchangeRateStored();

        if (withdrawTokensIn > 0) {
            tmp.withdrawTokens = withdrawTokensIn;
            tmp.withdrawAmount = mulScalarTruncate(
                tmp.exchangeRate,
                withdrawTokensIn
            );
        } else {
            tmp.withdrawTokens = divScalarByExpTruncate(
                withdrawAmountIn,
                tmp.exchangeRate
            );
            tmp.withdrawAmount = withdrawAmountIn;
        }

        require(accrualBlockNumber == getBlockNumber(), "Blocknumber fails");

        tmp.totalSupplyNew = totalSupply.sub(tmp.withdrawTokens);
        tmp.accountTokensNew = accountTokens[withdrawer].sub(
            tmp.withdrawTokens
        );

        totalSupply = tmp.totalSupplyNew;
        accountTokens[withdrawer] = tmp.accountTokensNew;

        uint256 preCalcTokenCash = tokenCash(underlying, address(controller))
            .add(tmp.withdrawAmount);

        WithdrawLogStruct memory wls = WithdrawLogStruct(
            withdrawer,
            underlying,
            address(this),
            tmp.withdrawTokens,
            tmp.withdrawAmount,
            exchangeRateStored(),
            interestRateModel.getBorrowRate(
                preCalcTokenCash,
                totalBorrows,
                totalReserves
            ),
            tokenCash(address(this), withdrawer),
            preCalcTokenCash
        );

        emit Transfer(withdrawer, address(0), tmp.withdrawTokens);

        return (tmp.withdrawAmount, abi.encode(wls));
    }

    function accrueInterest() public onlyRestricted {

        uint256 currentBlockNumber = getBlockNumber();
        uint256 accrualBlockNumberPrior = accrualBlockNumber;

        if (accrualBlockNumberPrior == currentBlockNumber) {
            return;
        }

        uint256 cashPrior = controller.getCashPrior(underlying);
        uint256 borrowsPrior = totalBorrows;
        uint256 reservesPrior = totalReserves;
        uint256 borrowIndexPrior = borrowIndex;

        uint256 borrowRate = interestRateModel.getBorrowRate(
            cashPrior,
            borrowsPrior,
            reservesPrior
        );
        require(borrowRate <= borrowRateMax, "borrow rate is too high");

        uint256 blockDelta = currentBlockNumber.sub(accrualBlockNumberPrior);


        uint256 simpleInterestFactor;
        uint256 interestAccumulated;
        uint256 totalBorrowsNew;
        uint256 totalReservesNew;
        uint256 borrowIndexNew;

        simpleInterestFactor = mulScalar(borrowRate, blockDelta);

        interestAccumulated = divExp(
            mulExp(simpleInterestFactor, borrowsPrior),
            expScale
        );

        totalBorrowsNew = addExp(interestAccumulated, borrowsPrior);

        totalReservesNew = addExp(
            divExp(mulExp(reserveFactor, interestAccumulated), expScale),
            reservesPrior
        );

        borrowIndexNew = addExp(
            divExp(mulExp(simpleInterestFactor, borrowIndexPrior), expScale),
            borrowIndexPrior
        );

        accrualBlockNumber = currentBlockNumber;
        borrowIndex = borrowIndexNew;
        totalBorrows = totalBorrowsNew;
        totalReserves = totalReservesNew;

        borrowRate = interestRateModel.getBorrowRate(
            cashPrior,
            totalBorrows,
            totalReserves
        );
        require(borrowRate <= borrowRateMax, "borrow rate is too high");
    }

    function peekInterest()
        public
        view
        returns (
            uint256 _accrualBlockNumber,
            uint256 _borrowIndex,
            uint256 _totalBorrows,
            uint256 _totalReserves
        )
    {

        _accrualBlockNumber = getBlockNumber();
        uint256 accrualBlockNumberPrior = accrualBlockNumber;

        if (accrualBlockNumberPrior == _accrualBlockNumber) {
            return (
                accrualBlockNumber,
                borrowIndex,
                totalBorrows,
                totalReserves
            );
        }

        uint256 cashPrior = controller.getCashPrior(underlying);
        uint256 borrowsPrior = totalBorrows;
        uint256 reservesPrior = totalReserves;
        uint256 borrowIndexPrior = borrowIndex;

        uint256 borrowRate = interestRateModel.getBorrowRate(
            cashPrior,
            borrowsPrior,
            reservesPrior
        );
        require(borrowRate <= borrowRateMax, "borrow rate is too high");

        uint256 blockDelta = _accrualBlockNumber.sub(accrualBlockNumberPrior);


        uint256 simpleInterestFactor;
        uint256 interestAccumulated;
        uint256 totalBorrowsNew;
        uint256 totalReservesNew;
        uint256 borrowIndexNew;

        simpleInterestFactor = mulScalar(borrowRate, blockDelta);

        interestAccumulated = divExp(
            mulExp(simpleInterestFactor, borrowsPrior),
            expScale
        );

        totalBorrowsNew = addExp(interestAccumulated, borrowsPrior);

        totalReservesNew = addExp(
            divExp(mulExp(reserveFactor, interestAccumulated), expScale),
            reservesPrior
        );

        borrowIndexNew = addExp(
            divExp(mulExp(simpleInterestFactor, borrowIndexPrior), expScale),
            borrowIndexPrior
        );

        _borrowIndex = borrowIndexNew;
        _totalBorrows = totalBorrowsNew;
        _totalReserves = totalReservesNew;

        borrowRate = interestRateModel.getBorrowRate(
            cashPrior,
            totalBorrows,
            totalReserves
        );
        require(borrowRate <= borrowRateMax, "borrow rate is too high");
    }

    function borrowBalanceCurrent(address account)
        external
        nonReentrant
        returns (uint256)
    {

        accrueInterest();
        BorrowSnapshot memory borrowSnapshot = accountBorrows[account];
        require(borrowSnapshot.interestIndex <= borrowIndex, "borrowIndex error");

        return borrowBalanceStoredInternal(account);
    }

    function borrowBalanceStoredInternal(address user)
        internal
        view
        returns (uint256 result)
    {

        BorrowSnapshot memory borrowSnapshot = accountBorrows[user];

        if (borrowSnapshot.principal == 0) {
            return 0;
        }

        result = mulExp(borrowSnapshot.principal, divExp(borrowIndex, borrowSnapshot.interestIndex));
    }

    function _setReserveFactorFresh(uint256 newReserveFactor)
        external
        onlyAdmin
        nonReentrant
    {

        accrueInterest();
        require(accrualBlockNumber == getBlockNumber(), "Blocknumber fails");
        reserveFactor = newReserveFactor;
    }

    struct ReserveDepositLogStruct {
        address token_address;
        uint256 reserve_funded;
        uint256 cheque_token_value;
        uint256 loan_interest_rate;
        uint256 global_token_reserved;
    }

    function _setInterestRateModel(IInterestRateModel newInterestRateModel)
        public
        onlyAdmin
    {

        address oldIRM = address(interestRateModel);
        uint256 oldUR = utilizationRate();
        uint256 oldAPR = APR();
        uint256 oldAPY = APY();

        uint256 exRate1 = exchangeRateStored();     
        accrueInterest();
        uint256 exRate2 = exchangeRateStored();

        require(accrualBlockNumber == getBlockNumber(), "Blocknumber fails");

        interestRateModel = newInterestRateModel;
        uint256 newUR = utilizationRate();
        uint256 newAPR = APR();
        uint256 newAPY = APY();

        emit NewInterestRateModel(oldIRM, oldUR, oldAPR, oldAPY, exRate1, address(newInterestRateModel), newUR, newAPR, newAPY, exRate2);

        ReserveDepositLogStruct memory rds = ReserveDepositLogStruct(
            underlying,
            0,
            exchangeRateStored(),
            getBorrowRate(),
            tokenCash(underlying, address(controller))
        );

        IBank(bank).MonitorEventCallback(
            "ReserveDeposit",
            abi.encode(rds)
        );
    }

    function _setInitialExchangeRate(uint256 _initialExchangeRate) external onlyAdmin {

        uint256 oldInitialExchangeRate = initialExchangeRate;

        uint256 oldUR = utilizationRate();
        uint256 oldAPR = APR();
        uint256 oldAPY = APY();

        uint256 exRate1 = exchangeRateStored();
        accrueInterest();
        uint256 exRate2 = exchangeRateStored();

        require(accrualBlockNumber == getBlockNumber(), "Blocknumber fails");

        initialExchangeRate = _initialExchangeRate;
        uint256 newUR = utilizationRate();
        uint256 newAPR = APR();
        uint256 newAPY = APY();

        emit NewInitialExchangeRate(oldInitialExchangeRate, oldUR, oldAPR, oldAPY, exRate1, initialExchangeRate, newUR, newAPR, newAPY, exRate2);

        ReserveDepositLogStruct memory rds = ReserveDepositLogStruct(
            underlying,
            0,
            exchangeRateStored(),
            getBorrowRate(),
            tokenCash(underlying, address(controller))
        );

        IBank(bank).MonitorEventCallback(
            "ReserveDeposit",
            abi.encode(rds)
        );
    }

    function getBlockNumber() internal view returns (uint256) {

        return block.number;
    }

    function repay(address borrower, uint256 repayAmount)
        external
        onlyBank
        nonReentrant
        returns (uint256, bytes memory)
    {

        accrueInterest();
        return repayInternal(borrower, repayAmount);
    }

    struct RepayLogStruct {
        address user_address;
        address token_address;
        address cheque_token_address;
        uint256 amount_repayed;
        uint256 interest_accrued;
        uint256 cheque_token_value;
        uint256 loan_interest_rate;
        uint256 account_debt;
        uint256 global_token_reserved;
    }

    function repayInternal(address borrower, uint256 repayAmount)
        internal
        returns (uint256, bytes memory)
    {

        controller.repayCheck(underlying);
        require(accrualBlockNumber == getBlockNumber(), "Blocknumber fails");

        RepayLocals memory tmp;
        uint256 lastPrincipal = accountBorrows[borrower].principal;
        tmp.borrowerIndex = accountBorrows[borrower].interestIndex;
        tmp.accountBorrows = borrowBalanceStoredInternal(borrower);

        if (repayAmount == uint256(-1)) {
            tmp.repayAmount = tmp.accountBorrows;
        } else {
            tmp.repayAmount = repayAmount;
        }

        tmp.accountBorrowsNew = tmp.accountBorrows.sub(tmp.repayAmount);
        if (totalBorrows < tmp.repayAmount) {
            tmp.totalBorrowsNew = 0;
        } else {
            tmp.totalBorrowsNew = totalBorrows.sub(tmp.repayAmount);
        }

        accountBorrows[borrower].principal = tmp.accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = tmp.totalBorrowsNew;

        uint256 preCalcTokenCash = tokenCash(underlying, address(controller))
            .add(tmp.repayAmount);

        RepayLogStruct memory rls = RepayLogStruct(
            borrower,
            underlying,
            address(this),
            tmp.repayAmount,
            SafeMath.abs(tmp.accountBorrows, lastPrincipal),
            exchangeRateAfter(tmp.repayAmount), //repay之后的交换率
            interestRateModel.getBorrowRate(
                preCalcTokenCash,
                totalBorrows,
                totalReserves
            ), //repay之后的借款利率
            accountBorrows[borrower].principal,
            preCalcTokenCash
        );

        return (tmp.repayAmount, abi.encode(rls));
    }

    function borrowBalanceStored(address account)
        external
        view
        returns (uint256)
    {

        return borrowBalanceStoredInternal(account);
    }

    struct LiquidateBorrowLogStruct {
        address user_address;
        address token_address;
        address cheque_token_address;
        uint256 debt_written_off;
        uint256 interest_accrued;
        address debtor_address;
        uint256 collateral_purchased;
        address collateral_cheque_token_address;
        uint256 debtor_balance;
        uint256 debt_remaining;
        uint256 cheque_token_value;
        uint256 loan_interest_rate;
        uint256 account_balance;
        uint256 global_token_reserved;
    }

    function liquidateBorrow(
        address liquidator,
        address borrower,
        uint256 repayAmount,
        FToken fTokenCollateral
    ) public onlyBank nonReentrant returns (bytes memory) {

        require(
            controller.isFTokenValid(address(this)) &&
                controller.isFTokenValid(address(fTokenCollateral)),
            "Market not listed"
        );
        accrueInterest();
        fTokenCollateral.accrueInterest();
        uint256 lastPrincipal = accountBorrows[borrower].principal;
        uint256 newPrincipal = borrowBalanceStoredInternal(borrower);

        controller.liquidateBorrowCheck(
            address(this),
            address(fTokenCollateral),
            borrower,
            liquidator,
            repayAmount
        );

        require(accrualBlockNumber == getBlockNumber(), "Blocknumber fails");
        require(
            fTokenCollateral.accrualBlockNumber() == getBlockNumber(),
            "Blocknumber fails"
        );

        (uint256 actualRepayAmount, ) = repayInternal(borrower, repayAmount);

        uint256 seizeTokens = controller.liquidateTokens(
            address(this),
            address(fTokenCollateral),
            actualRepayAmount
        );

        require(
            fTokenCollateral.balanceOf(borrower) >= seizeTokens,
            "Seize too much"
        );

        if (address(fTokenCollateral) == address(this)) {
            seizeInternal(address(this), liquidator, borrower, seizeTokens);
        } else {
            fTokenCollateral.seize(liquidator, borrower, seizeTokens);
        }

        uint256 preCalcTokenCash = tokenCash(underlying, address(controller))
            .add(actualRepayAmount);

        LiquidateBorrowLogStruct memory lbls = LiquidateBorrowLogStruct(
            liquidator,
            underlying,
            address(this),
            actualRepayAmount,
            SafeMath.abs(newPrincipal, lastPrincipal),
            borrower,
            seizeTokens,
            address(fTokenCollateral),
            tokenCash(address(fTokenCollateral), borrower),
            accountBorrows[borrower].principal, //debt_remaining
            exchangeRateAfter(actualRepayAmount),
            interestRateModel.getBorrowRate(
                preCalcTokenCash,
                totalBorrows,
                totalReserves
            ),
            tokenCash(address(fTokenCollateral), liquidator),
            preCalcTokenCash
        );

        return abi.encode(lbls);
    }

    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external nonReentrant {

        return seizeInternal(msg.sender, liquidator, borrower, seizeTokens);
    }

    struct CallingOutLogStruct {
        address user_address;
        address token_address;
        address cheque_token_address;
        uint256 amount_wiped_out;
        uint256 debt_cancelled_out;
        uint256 interest_accrued;
        uint256 cheque_token_value;
        uint256 loan_interest_rate;
        uint256 account_balance;
        uint256 account_debt;
        uint256 global_token_reserved;
    }

    function cancellingOut(address striker)
        public
        onlyBank
        nonReentrant
        returns (bool strikeOk, bytes memory strikeLog)
    {

        if (
            borrowBalanceStoredInternal(striker) > 0 && balanceOf(striker) > 0
        ) {
            accrueInterest();
            uint256 lastPrincipal = accountBorrows[striker].principal;
            uint256 curBorrowBalance = borrowBalanceStoredInternal(striker);
            uint256 userSupplyBalance = calcBalanceOfUnderlying(striker);
            uint256 lastFtokenBalance = balanceOf(striker);
            uint256 actualRepayAmount;
            bytes memory repayLog;
            uint256 withdrawAmount;
            bytes memory withdrawLog;
            if (curBorrowBalance > 0 && userSupplyBalance > 0) {
                if (userSupplyBalance > curBorrowBalance) {
                    (withdrawAmount, withdrawLog) = strikeWithdrawInternal(
                        striker,
                        0,
                        curBorrowBalance
                    );
                } else {
                    (withdrawAmount, withdrawLog) = strikeWithdrawInternal(
                        striker,
                        balanceOf(striker),
                        0
                    );
                }

                (actualRepayAmount, repayLog) = repayInternal(
                    striker,
                    withdrawAmount
                );

                CallingOutLogStruct memory cols;

                cols.user_address = striker;
                cols.token_address = underlying;
                cols.cheque_token_address = address(this);
                cols.amount_wiped_out = SafeMath.abs(
                    lastFtokenBalance,
                    balanceOf(striker)
                );
                cols.debt_cancelled_out = actualRepayAmount;
                cols.interest_accrued = SafeMath.abs(
                    curBorrowBalance,
                    lastPrincipal
                );
                cols.cheque_token_value = exchangeRateStored();
                cols.loan_interest_rate = interestRateModel.getBorrowRate(
                    tokenCash(underlying, address(controller)),
                    totalBorrows,
                    totalReserves
                );
                cols.account_balance = tokenCash(address(this), striker);
                cols.account_debt = accountBorrows[striker].principal;
                cols.global_token_reserved = tokenCash(
                    underlying,
                    address(controller)
                );

                strikeLog = abi.encode(cols);

                strikeOk = true;
            }
        }
    }

    function balanceOf(address owner) public view returns (uint256) {

        return accountTokens[owner];
    }

    function _setBorrowSafeRatio(uint256 _borrowSafeRatio) public onlyAdmin {

        borrowSafeRatio = _borrowSafeRatio;
    }

    function seizeInternal(
        address seizerToken,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) internal {

        require(borrower != liquidator, "Liquidator cannot be borrower");
        controller.seizeCheck(address(this), seizerToken);

        accountTokens[borrower] = accountTokens[borrower].sub(seizeTokens);
        accountTokens[liquidator] = accountTokens[liquidator].add(seizeTokens);

        emit Transfer(borrower, liquidator, seizeTokens);
    }

    function _reduceReserves(uint256 reduceAmount) external onlyController {

        accrueInterest();

        require(accrualBlockNumber == getBlockNumber(), "Blocknumber fails");
        require(
            controller.getCashPrior(underlying) >= reduceAmount,
            "Insufficient cash"
        );
        require(totalReserves >= reduceAmount, "Insufficient reserves");

        totalReserves = SafeMath.sub(
            totalReserves,
            reduceAmount,
            "reduce reserves underflow"
        );
    }

    function _addReservesFresh(uint256 addAmount) external onlyController {

        accrueInterest();

        require(accrualBlockNumber == getBlockNumber(), "Blocknumber fails");
        totalReserves = SafeMath.add(totalReserves, addAmount);
    }

    function addTotalCash(uint256 _addAmount) public onlyBankComponent {

        totalCash = totalCash.add(_addAmount);
    }

    function subTotalCash(uint256 _subAmount) public onlyBankComponent {

        totalCash = totalCash.sub(_subAmount);
    }

    modifier nonReentrant() {

        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true;
    }

    function APR() public view returns (uint256) {

        uint256 cash = tokenCash(underlying, address(controller));
        return interestRateModel.APR(cash, totalBorrows, totalReserves);
    }

    function APY() public view returns (uint256) {

        uint256 cash = tokenCash(underlying, address(controller));
        return
            interestRateModel.APY(
                cash,
                totalBorrows,
                totalReserves,
                reserveFactor
            );
    }

    function utilizationRate() public view returns (uint256) {

        uint256 cash = tokenCash(underlying, address(controller));
        return interestRateModel.utilizationRate(cash, totalBorrows, totalReserves);
    }

    function getBorrowRate() public view returns (uint256) {

        uint256 cash = tokenCash(underlying, address(controller));
        return
            interestRateModel.getBorrowRate(cash, totalBorrows, totalReserves);
    }

    function getSupplyRate() public view returns (uint256) {

        uint256 cash = tokenCash(underlying, address(controller));
        return
            interestRateModel.getSupplyRate(
                cash,
                totalBorrows,
                totalReserves,
                reserveFactor
            );
    }
}