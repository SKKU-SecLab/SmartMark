

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


interface IWeth {

    function deposit() external payable;

    function withdraw(uint256 wad) external;

}

contract IERC20 {

    string public name;
    uint8 public decimals;
    string public symbol;
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function approve(address _spender, uint256 _value) public returns (bool);

    function transfer(address _to, uint256 _value) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract IWethERC20 is IWeth, IERC20 {}


contract Constants {


    uint256 internal constant WEI_PRECISION = 10**18;
    uint256 internal constant WEI_PERCENT_PRECISION = 10**20;

    uint256 internal constant DAYS_IN_A_YEAR = 365;
    uint256 internal constant ONE_MONTH = 2628000; // approx. seconds in a month

    string internal constant UserRewardsID = "UserRewards";
    string internal constant LoanDepositValueID = "LoanDepositValue";

    IWethERC20 public constant wethToken = IWethERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant bzrxTokenAddress = 0x56d811088235F11C8920698a204A5010a788f4b3;
    address public constant vbzrxTokenAddress = 0xB72B31907C1C95F3650b64b2469e08EdACeE5e8F;
}

library EnumerableBytes32Set {


    struct Bytes32Set {
        mapping (bytes32 => uint256) index;
        bytes32[] values;
    }

    function addAddress(Bytes32Set storage set, address addrvalue)
        internal
        returns (bool)
    {

        bytes32 value;
        assembly {
            value := addrvalue
        }
        return addBytes32(set, value);
    }

    function addBytes32(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        if (!contains(set, value)){
            set.index[value] = set.values.push(value);
            return true;
        } else {
            return false;
        }
    }

    function removeAddress(Bytes32Set storage set, address addrvalue)
        internal
        returns (bool)
    {

        bytes32 value;
        assembly {
            value := addrvalue
        }
        return removeBytes32(set, value);
    }

    function removeBytes32(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        if (contains(set, value)){
            uint256 toDeleteIndex = set.index[value] - 1;
            uint256 lastIndex = set.values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set.values[lastIndex];

                set.values[toDeleteIndex] = lastValue;
                set.index[lastValue] = toDeleteIndex + 1; // All indexes are 1-based
            }

            delete set.index[value];

            set.values.pop();

            return true;
        } else {
            return false;
        }
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {

        return set.index[value] != 0;
    }

    function containsAddress(Bytes32Set storage set, address addrvalue)
        internal
        view
        returns (bool)
    {

        bytes32 value;
        assembly {
            value := addrvalue
        }
        return set.index[value] != 0;
    }

    function enumerate(Bytes32Set storage set, uint256 start, uint256 count)
        internal
        view
        returns (bytes32[] memory output)
    {

        uint256 end = start + count;
        require(end >= start, "addition overflow");
        end = set.values.length < end ? set.values.length : end;
        if (end == 0 || start >= end) {
            return output;
        }

        output = new bytes32[](end-start);
        for (uint256 i = start; i < end; i++) {
            output[i-start] = set.values[i];
        }
        return output;
    }

    function length(Bytes32Set storage set)
        internal
        view
        returns (uint256)
    {

        return set.values.length;
    }

    function get(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {

        return set.values[index];
    }

    function getAddress(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (address)
    {

        bytes32 value = set.values[index];
        address addrvalue;
        assembly {
            addrvalue := value
        }
        return addrvalue;
    }
}

contract ReentrancyGuard {


    uint256 internal constant REENTRANCY_GUARD_FREE = 1;

    uint256 internal constant REENTRANCY_GUARD_LOCKED = 2;

    uint256 internal reentrancyLock = REENTRANCY_GUARD_FREE;

    modifier nonReentrant() {

        require(reentrancyLock == REENTRANCY_GUARD_FREE, "nonReentrant");
        reentrancyLock = REENTRANCY_GUARD_LOCKED;
        _;
        reentrancyLock = REENTRANCY_GUARD_FREE;
    }
}

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "unauthorized");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

        require(b != 0, errorMessage);
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

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract LoanStruct {

    struct Loan {
        bytes32 id;                 // id of the loan
        bytes32 loanParamsId;       // the linked loan params id
        bytes32 pendingTradesId;    // the linked pending trades id
        uint256 principal;          // total borrowed amount outstanding
        uint256 collateral;         // total collateral escrowed for the loan
        uint256 startTimestamp;     // loan start time
        uint256 endTimestamp;       // for active loans, this is the expected loan end time, for in-active loans, is the actual (past) end time
        uint256 startMargin;        // initial margin when the loan opened
        uint256 startRate;          // reference rate when the loan opened for converting collateralToken to loanToken
        address borrower;           // borrower of this loan
        address lender;             // lender of this loan
        bool active;                // if false, the loan has been fully closed
    }
}

contract LoanParamsStruct {

    struct LoanParams {
        bytes32 id;                 // id of loan params object
        bool active;                // if false, this object has been disabled by the owner and can't be used for future loans
        address owner;              // owner of this object
        address loanToken;          // the token being loaned
        address collateralToken;    // the required collateral token
        uint256 minInitialMargin;   // the minimum allowed initial margin
        uint256 maintenanceMargin;  // an unhealthy loan when current margin is at or below this value
        uint256 maxLoanTerm;        // the maximum term for new loans (0 means there's no max term)
    }
}

contract OrderStruct {

    struct Order {
        uint256 lockedAmount;           // escrowed amount waiting for a counterparty
        uint256 interestRate;           // interest rate defined by the creator of this order
        uint256 minLoanTerm;            // minimum loan term allowed
        uint256 maxLoanTerm;            // maximum loan term allowed
        uint256 createdTimestamp;       // timestamp when this order was created
        uint256 expirationTimestamp;    // timestamp when this order expires
    }
}

contract LenderInterestStruct {

    struct LenderInterest {
        uint256 principalTotal;     // total borrowed amount outstanding of asset
        uint256 owedPerDay;         // interest owed per day for all loans of asset
        uint256 owedTotal;          // total interest owed for all loans of asset (assuming they go to full term)
        uint256 paidTotal;          // total interest paid so far for asset
        uint256 updatedTimestamp;   // last update
    }
}

contract LoanInterestStruct {

    struct LoanInterest {
        uint256 owedPerDay;         // interest owed per day for loan
        uint256 depositTotal;       // total escrowed interest for loan
        uint256 updatedTimestamp;   // last update
    }
}

contract Objects is
    LoanStruct,
    LoanParamsStruct,
    OrderStruct,
    LenderInterestStruct,
    LoanInterestStruct
{}


contract State is Constants, Objects, ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using EnumerableBytes32Set for EnumerableBytes32Set.Bytes32Set;

    address public priceFeeds;                                                              // handles asset reference price lookups
    address public swapsImpl;                                                               // handles asset swaps using dex liquidity

    mapping (bytes4 => address) public logicTargets;                                        // implementations of protocol functions

    mapping (bytes32 => Loan) public loans;                                                 // loanId => Loan
    mapping (bytes32 => LoanParams) public loanParams;                                      // loanParamsId => LoanParams

    mapping (address => mapping (bytes32 => Order)) public lenderOrders;                    // lender => orderParamsId => Order
    mapping (address => mapping (bytes32 => Order)) public borrowerOrders;                  // borrower => orderParamsId => Order

    mapping (bytes32 => mapping (address => bool)) public delegatedManagers;                // loanId => delegated => approved

    mapping (address => mapping (address => LenderInterest)) public lenderInterest;         // lender => loanToken => LenderInterest object
    mapping (bytes32 => LoanInterest) public loanInterest;                                  // loanId => LoanInterest object

    EnumerableBytes32Set.Bytes32Set internal logicTargetsSet;                               // implementations set
    EnumerableBytes32Set.Bytes32Set internal activeLoansSet;                                // active loans set

    mapping (address => EnumerableBytes32Set.Bytes32Set) internal lenderLoanSets;           // lender loans set
    mapping (address => EnumerableBytes32Set.Bytes32Set) internal borrowerLoanSets;         // borrow loans set
    mapping (address => EnumerableBytes32Set.Bytes32Set) internal userLoanParamSets;        // user loan params set

    address public feesController;                                                          // address controlling fee withdrawals

    uint256 public lendingFeePercent = 10 ether; // 10% fee                                 // fee taken from lender interest payments
    mapping (address => uint256) public lendingFeeTokensHeld;                               // total interest fees received and not withdrawn per asset
    mapping (address => uint256) public lendingFeeTokensPaid;                               // total interest fees withdraw per asset (lifetime fees = lendingFeeTokensHeld + lendingFeeTokensPaid)

    uint256 public tradingFeePercent = 0.15 ether; // 0.15% fee                             // fee paid for each trade
    mapping (address => uint256) public tradingFeeTokensHeld;                               // total trading fees received and not withdrawn per asset
    mapping (address => uint256) public tradingFeeTokensPaid;                               // total trading fees withdraw per asset (lifetime fees = tradingFeeTokensHeld + tradingFeeTokensPaid)

    uint256 public borrowingFeePercent = 0.09 ether; // 0.09% fee                           // origination fee paid for each loan
    mapping (address => uint256) public borrowingFeeTokensHeld;                             // total borrowing fees received and not withdrawn per asset
    mapping (address => uint256) public borrowingFeeTokensPaid;                             // total borrowing fees withdraw per asset (lifetime fees = borrowingFeeTokensHeld + borrowingFeeTokensPaid)

    uint256 public protocolTokenHeld;                                                       // current protocol token deposit balance
    uint256 public protocolTokenPaid;                                                       // lifetime total payout of protocol token

    uint256 public affiliateFeePercent = 30 ether; // 30% fee share                         // fee share for affiliate program

    mapping (address => mapping (address => uint256)) public liquidationIncentivePercent;   // percent discount on collateral for liquidators per loanToken and collateralToken

    mapping (address => address) public loanPoolToUnderlying;                               // loanPool => underlying
    mapping (address => address) public underlyingToLoanPool;                               // underlying => loanPool
    EnumerableBytes32Set.Bytes32Set internal loanPoolsSet;                                  // loan pools set

    mapping (address => bool) public supportedTokens;                                       // supported tokens for swaps

    uint256 public maxDisagreement = 5 ether;                                               // % disagreement between swap rate and reference rate

    uint256 public sourceBufferPercent = 5 ether;                                           // used to estimate kyber swap source amount

    uint256 public maxSwapSize = 1500 ether;                                                // maximum supported swap size in ETH


    function _setTarget(
        bytes4 sig,
        address target)
        internal
    {

        logicTargets[sig] = target;

        if (target != address(0)) {
            logicTargetsSet.addBytes32(bytes32(sig));
        } else {
            logicTargetsSet.removeBytes32(bytes32(sig));
        }
    }
}

contract IVestingToken is IERC20 {

    function claimedBalanceOf(
        address _owner)
        external
        view
        returns (uint256);

}

contract ProtocolSettingsEvents {


    event SetPriceFeedContract(
        address indexed sender,
        address oldValue,
        address newValue
    );

    event SetSwapsImplContract(
        address indexed sender,
        address oldValue,
        address newValue
    );

    event SetLoanPool(
        address indexed sender,
        address indexed loanPool,
        address indexed underlying
    );

    event SetSupportedTokens(
        address indexed sender,
        address indexed token,
        bool isActive
    );

    event SetLendingFeePercent(
        address indexed sender,
        uint256 oldValue,
        uint256 newValue
    );

    event SetTradingFeePercent(
        address indexed sender,
        uint256 oldValue,
        uint256 newValue
    );

    event SetBorrowingFeePercent(
        address indexed sender,
        uint256 oldValue,
        uint256 newValue
    );

    event SetAffiliateFeePercent(
        address indexed sender,
        uint256 oldValue,
        uint256 newValue
    );

    event SetLiquidationIncentivePercent(
        address indexed sender,
        address indexed loanToken,
        address indexed collateralToken,
        uint256 oldValue,
        uint256 newValue
    );

    event SetMaxSwapSize(
        address indexed sender,
        uint256 oldValue,
        uint256 newValue
    );

    event SetFeesController(
        address indexed sender,
        address indexed oldController,
        address indexed newController
    );

    event WithdrawLendingFees(
        address indexed sender,
        address indexed token,
        address indexed receiver,
        uint256 amount
    );

    event WithdrawTradingFees(
        address indexed sender,
        address indexed token,
        address indexed receiver,
        uint256 amount
    );

    event WithdrawBorrowingFees(
        address indexed sender,
        address indexed token,
        address indexed receiver,
        uint256 amount
    );

    enum FeeClaimType {
        All,
        Lending,
        Trading,
        Borrowing
    }
}

library MathUtil {


    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        return divCeil(a, b, "SafeMath: division by zero");
    }

    function divCeil(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);

        if (a == 0) {
            return 0;
        }
        uint256 c = ((a - 1) / b) + 1;

        return c;
    }

    function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {

        return _a < _b ? _a : _b;
    }
}

contract ProtocolSettings is State, ProtocolSettingsEvents {

    using SafeERC20 for IERC20;
    using MathUtil for uint256;

    function initialize(
        address target)
        external
        onlyOwner
    {

        _setTarget(this.setPriceFeedContract.selector, target);
        _setTarget(this.setSwapsImplContract.selector, target);
        _setTarget(this.setLoanPool.selector, target);
        _setTarget(this.setSupportedTokens.selector, target);
        _setTarget(this.setLendingFeePercent.selector, target);
        _setTarget(this.setTradingFeePercent.selector, target);
        _setTarget(this.setBorrowingFeePercent.selector, target);
        _setTarget(this.setAffiliateFeePercent.selector, target);
        _setTarget(this.setLiquidationIncentivePercent.selector, target);
        _setTarget(this.setMaxDisagreement.selector, target);
        _setTarget(this.setSourceBufferPercent.selector, target);
        _setTarget(this.setMaxSwapSize.selector, target);
        _setTarget(this.setFeesController.selector, target);
        _setTarget(this.withdrawFees.selector, target);
        _setTarget(this.withdrawProtocolToken.selector, target);
        _setTarget(this.depositProtocolToken.selector, target);
        _setTarget(this.grantRewards.selector, target);
        _setTarget(this.queryFees.selector, target);
        _setTarget(this.getLoanPoolsList.selector, target);
        _setTarget(this.isLoanPool.selector, target);
    }

    function setPriceFeedContract(
        address newContract)
        external
        onlyOwner
    {

        address oldContract = priceFeeds;
        priceFeeds = newContract;

        emit SetPriceFeedContract(
            msg.sender,
            oldContract,
            newContract
        );
    }

    function setSwapsImplContract(
        address newContract)
        external
        onlyOwner
    {

        address oldContract = swapsImpl;
        swapsImpl = newContract;

        emit SetSwapsImplContract(
            msg.sender,
            oldContract,
            newContract
        );
    }

    function setLoanPool(
        address[] calldata pools,
        address[] calldata assets)
        external
        onlyOwner
    {

        require(pools.length == assets.length, "count mismatch");

        for (uint256 i = 0; i < pools.length; i++) {
            require(pools[i] != assets[i], "pool == asset");
            require(pools[i] != address(0), "pool == 0");

            address pool = loanPoolToUnderlying[pools[i]];
            if (assets[i] == address(0)) {
                require(pool != address(0), "pool not exists");
            } else {
                require(pool == address(0), "pool exists");
            }

            if (assets[i] == address(0)) {
                underlyingToLoanPool[loanPoolToUnderlying[pools[i]]] = address(0);
                loanPoolToUnderlying[pools[i]] = address(0);
                loanPoolsSet.removeAddress(pools[i]);
            } else {
                loanPoolToUnderlying[pools[i]] = assets[i];
                underlyingToLoanPool[assets[i]] = pools[i];
                loanPoolsSet.addAddress(pools[i]);
            }

            emit SetLoanPool(
                msg.sender,
                pools[i],
                assets[i]
            );
        }
    }

    function setSupportedTokens(
        address[] calldata addrs,
        bool[] calldata toggles,
        bool withApprovals)
        external
        onlyOwner
    {

        require(addrs.length == toggles.length, "count mismatch");

        for (uint256 i = 0; i < addrs.length; i++) {
            supportedTokens[addrs[i]] = toggles[i];

            emit SetSupportedTokens(
                msg.sender,
                addrs[i],
                toggles[i]
            );
        }

        if (withApprovals) {
            bytes memory data = abi.encodeWithSelector(
                0x4a99e3a1, // setSwapApprovals(address[])
                addrs
            );
            (bool success,) = swapsImpl.delegatecall(data);
            require(success, "approval calls failed");
        }
    }

    function setLendingFeePercent(
        uint256 newValue)
        external
        onlyOwner
    {

        require(newValue <= WEI_PERCENT_PRECISION, "value too high");
        uint256 oldValue = lendingFeePercent;
        lendingFeePercent = newValue;

        emit SetLendingFeePercent(
            msg.sender,
            oldValue,
            newValue
        );
    }

    function setTradingFeePercent(
        uint256 newValue)
        external
        onlyOwner
    {

        require(newValue <= WEI_PERCENT_PRECISION, "value too high");
        uint256 oldValue = tradingFeePercent;
        tradingFeePercent = newValue;

        emit SetTradingFeePercent(
            msg.sender,
            oldValue,
            newValue
        );
    }

    function setBorrowingFeePercent(
        uint256 newValue)
        external
        onlyOwner
    {

        require(newValue <= WEI_PERCENT_PRECISION, "value too high");
        uint256 oldValue = borrowingFeePercent;
        borrowingFeePercent = newValue;

        emit SetBorrowingFeePercent(
            msg.sender,
            oldValue,
            newValue
        );
    }

    function setAffiliateFeePercent(
        uint256 newValue)
        external
        onlyOwner
    {

        require(newValue <= WEI_PERCENT_PRECISION, "value too high");
        uint256 oldValue = affiliateFeePercent;
        affiliateFeePercent = newValue;

        emit SetAffiliateFeePercent(
            msg.sender,
            oldValue,
            newValue
        );
    }

    function setLiquidationIncentivePercent(
        address[] calldata loanTokens,
        address[] calldata collateralTokens,
        uint256[] calldata amounts)
        external
        onlyOwner
    {

        require(loanTokens.length == collateralTokens.length && loanTokens.length == amounts.length, "count mismatch");

        for (uint256 i = 0; i < loanTokens.length; i++) {
            require(amounts[i] <= WEI_PERCENT_PRECISION, "value too high");

            uint256 oldValue = liquidationIncentivePercent[loanTokens[i]][collateralTokens[i]];
            liquidationIncentivePercent[loanTokens[i]][collateralTokens[i]] = amounts[i];

            emit SetLiquidationIncentivePercent(
                msg.sender,
                loanTokens[i],
                collateralTokens[i],
                oldValue,
                amounts[i]
            );
        }
    }

    function setMaxDisagreement(
        uint256 newValue)
        external
        onlyOwner
    {

        maxDisagreement = newValue;
    }

    function setSourceBufferPercent(
        uint256 newValue)
        external
        onlyOwner
    {

        sourceBufferPercent = newValue;
    }

    function setMaxSwapSize(
        uint256 newValue)
        external
        onlyOwner
    {

        uint256 oldValue = maxSwapSize;
        maxSwapSize = newValue;

        emit SetMaxSwapSize(
            msg.sender,
            oldValue,
            newValue
        );
    }

    function setFeesController(
        address newController)
        external
        onlyOwner
    {

        address oldController = feesController;
        feesController = newController;

        emit SetFeesController(
            msg.sender,
            oldController,
            newController
        );
    }

    function withdrawFees(
        address[] calldata tokens,
        address receiver,
        FeeClaimType feeType)
        external
        returns (uint256[] memory amounts)
    {

        require(msg.sender == feesController, "unauthorized");

        amounts = new uint256[](tokens.length);
        uint256 balance;
        address token;
        for (uint256 i = 0; i < tokens.length; i++) {
            token = tokens[i];

            if (feeType == FeeClaimType.All || feeType == FeeClaimType.Lending) {
                balance = lendingFeeTokensHeld[token];
                if (balance != 0) {
                    amounts[i] = balance;  // will not overflow
                    lendingFeeTokensHeld[token] = 0;
                    lendingFeeTokensPaid[token] = lendingFeeTokensPaid[token]
                        .add(balance);
                    emit WithdrawLendingFees(
                        msg.sender,
                        token,
                        receiver,
                        balance
                    );
                }
            }
            if (feeType == FeeClaimType.All || feeType == FeeClaimType.Trading) {
                balance = tradingFeeTokensHeld[token];
                if (balance != 0) {
                    amounts[i] += balance;  // will not overflow
                    tradingFeeTokensHeld[token] = 0;
                    tradingFeeTokensPaid[token] = tradingFeeTokensPaid[token]
                        .add(balance);
                    emit WithdrawTradingFees(
                        msg.sender,
                        token,
                        receiver,
                        balance
                    );
                }
            }
            if (feeType == FeeClaimType.All || feeType == FeeClaimType.Borrowing) {
                balance = borrowingFeeTokensHeld[token];
                if (balance != 0) {
                    amounts[i] += balance;  // will not overflow
                    borrowingFeeTokensHeld[token] = 0;
                    borrowingFeeTokensPaid[token] = borrowingFeeTokensPaid[token]
                        .add(balance);
                    emit WithdrawBorrowingFees(
                        msg.sender,
                        token,
                        receiver,
                        balance
                    );
                }
            }

            if (amounts[i] != 0) {
                IERC20(token).safeTransfer(
                    receiver,
                    amounts[i]
                );
            }
        }
    }

    function withdrawProtocolToken(
        address receiver,
        uint256 amount)
        external
        onlyOwner
        returns (address rewardToken, uint256 withdrawAmount)
    {

        rewardToken = vbzrxTokenAddress;
        withdrawAmount = amount;

        uint256 tokenBalance = protocolTokenHeld;
        if (withdrawAmount > tokenBalance) {
            withdrawAmount = tokenBalance;
        }
        if (withdrawAmount != 0) {
            protocolTokenHeld = tokenBalance
                .sub(withdrawAmount);

            IERC20(vbzrxTokenAddress).transfer(
                receiver,
                withdrawAmount
            );
        }

        uint256 totalEmission = IVestingToken(vbzrxTokenAddress).claimedBalanceOf(address(this));

        uint256 totalWithdrawn;
        bytes32 slot = 0xf0cbcfb4979ecfbbd8f7e7430357fc20e06376d29a69ad87c4f21360f6846545;
        assembly {
            totalWithdrawn := sload(slot)
        }

        if (totalEmission > totalWithdrawn) {
            IERC20(bzrxTokenAddress).transfer(
                receiver,
                totalEmission - totalWithdrawn
            );
            assembly {
                sstore(slot, totalEmission)
            }
        }
    }

    function depositProtocolToken(
        uint256 amount)
        external
        onlyOwner
    {

        protocolTokenHeld = protocolTokenHeld
            .add(amount);

        IERC20(vbzrxTokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount
        );
    }

    function grantRewards(
        address[] calldata users,
        uint256[] calldata amounts)
        external
        onlyOwner
        returns (uint256 totalAmount)
    {

        require(users.length == amounts.length, "count mismatch");

        uint256 amount;
        bytes32 slot;
        for (uint256 i = 0; i < users.length; i++) {
            amount = amounts[i];
            totalAmount = totalAmount
                .add(amount);

            slot = keccak256(abi.encodePacked(users[i], UserRewardsID));
            assembly {
                sstore(slot, add(sload(slot), amount))
            }
        }

        if (totalAmount != 0) {
            IERC20(vbzrxTokenAddress).transferFrom(
                msg.sender,
                address(this),
                totalAmount
            );
        }
    }

    function queryFees(
        address[] calldata tokens,
        FeeClaimType feeType)
        external
        view
        returns (uint256[] memory amountsHeld, uint256[] memory amountsPaid)
    {

        amountsHeld = new uint256[](tokens.length);
        amountsPaid = new uint256[](tokens.length);
        address token;
        for (uint256 i = 0; i < tokens.length; i++) {
            token = tokens[i];
            
            if (feeType == FeeClaimType.Lending) {
                amountsHeld[i] = lendingFeeTokensHeld[token];
                amountsPaid[i] = lendingFeeTokensPaid[token];
            } else if (feeType == FeeClaimType.Trading) {
                amountsHeld[i] = tradingFeeTokensHeld[token];
                amountsPaid[i] = tradingFeeTokensPaid[token];
            } else if (feeType == FeeClaimType.Borrowing) {
                amountsHeld[i] = borrowingFeeTokensHeld[token];
                amountsPaid[i] = borrowingFeeTokensPaid[token];
            } else {
                amountsHeld[i] = lendingFeeTokensHeld[token] + tradingFeeTokensHeld[token] + borrowingFeeTokensHeld[token]; // will not overflow
                amountsPaid[i] = lendingFeeTokensPaid[token] + tradingFeeTokensPaid[token] + borrowingFeeTokensPaid[token]; // will not overflow
            }
        }
    }

    function getLoanPoolsList(
        uint256 start,
        uint256 count)
        external
        view
        returns (address[] memory loanPoolsList)
    {

        EnumerableBytes32Set.Bytes32Set storage set = loanPoolsSet;
        uint256 end = start.add(count).min256(set.length());
        if (start >= end) {
            return loanPoolsList;
        }
        count = end-start;

        loanPoolsList = new address[](count);
        for (uint256 i = --end; i >= start; i--) {
            loanPoolsList[--count] = set.getAddress(i);

            if (i == 0) {
                break;
            }
        }
    }

    function isLoanPool(
        address loanPool)
        external
        view
        returns (bool)
    {

        return loanPoolToUnderlying[loanPool] != address(0);
    }
}