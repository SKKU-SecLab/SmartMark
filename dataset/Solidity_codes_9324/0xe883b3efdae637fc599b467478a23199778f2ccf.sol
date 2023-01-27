

pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


library Storage {


    function load(
        bytes32 slot
    )
        internal
        view
        returns (bytes32)
    {

        bytes32 result;
        assembly {
            result := sload(slot)
        }
        return result;
    }

    function store(
        bytes32 slot,
        bytes32 value
    )
        internal
    {

        assembly {
            sstore(slot, value)
        }
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

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

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


contract Adminable {

    bytes32 internal constant ADMIN_SLOT =
    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier onlyAdmin() {

        require(
            msg.sender == getAdmin(),
            "Adminable: caller is not admin"
        );
        _;
    }

    function getAdmin()
        public
        view
        returns (address)
    {

        return address(uint160(uint256(Storage.load(ADMIN_SLOT))));
    }
}


contract ReentrancyGuard {

    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = uint256(int256(-1));

    uint256 private _STATUS_;

    constructor () internal {
        _STATUS_ = NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_STATUS_ != ENTERED, "ReentrancyGuard: reentrant call");
        _STATUS_ = ENTERED;
        _;
        _STATUS_ = NOT_ENTERED;
    }
}


library P1Types {


    struct Index {
        uint32 timestamp;
        bool isPositive;
        uint128 value;
    }

    struct Balance {
        bool marginIsPositive;
        bool positionIsPositive;
        uint120 margin;
        uint120 position;
    }

    struct Context {
        uint256 price;
        uint256 minCollateral;
        Index index;
    }

    struct TradeResult {
        uint256 marginAmount;
        uint256 positionAmount;
        bool isBuy; // From taker's perspective.
        bytes32 traderFlags;
    }
}


contract P1Storage is
    Adminable,
    ReentrancyGuard
{

    mapping(address => P1Types.Balance) internal _BALANCES_;
    mapping(address => P1Types.Index) internal _LOCAL_INDEXES_;

    mapping(address => bool) internal _GLOBAL_OPERATORS_;
    mapping(address => mapping(address => bool)) internal _LOCAL_OPERATORS_;

    address internal _TOKEN_;
    address internal _ORACLE_;
    address internal _FUNDER_;

    P1Types.Index internal _GLOBAL_INDEX_;
    uint256 internal _MIN_COLLATERAL_;

    bool internal _FINAL_SETTLEMENT_ENABLED_;
    uint256 internal _FINAL_SETTLEMENT_PRICE_;
}


library BaseMath {

    using SafeMath for uint256;

    uint256 constant internal BASE = 10 ** 18;

    function base()
        internal
        pure
        returns (uint256)
    {

        return BASE;
    }

    function baseMul(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {

        return value.mul(baseValue).div(BASE);
    }

    function baseDivMul(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {

        return value.div(BASE).mul(baseValue);
    }

    function baseMulRoundUp(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {

        if (value == 0 || baseValue == 0) {
            return 0;
        }
        return value.mul(baseValue).sub(1).div(BASE).add(1);
    }
}


library SafeCast {


    function toUint128(
        uint256 value
    )
        internal
        pure
        returns (uint128)
    {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint120(
        uint256 value
    )
        internal
        pure
        returns (uint120)
    {

        require(value < 2**120, "SafeCast: value doesn\'t fit in 120 bits");
        return uint120(value);
    }

    function toUint32(
        uint256 value
    )
        internal
        pure
        returns (uint32)
    {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }
}


library SignedMath {

    using SafeMath for uint256;


    struct Int {
        uint256 value;
        bool isPositive;
    }


    function add(
        Int memory sint,
        uint256 value
    )
        internal
        pure
        returns (Int memory)
    {

        if (sint.isPositive) {
            return Int({
                value: value.add(sint.value),
                isPositive: true
            });
        }
        if (sint.value < value) {
            return Int({
                value: value.sub(sint.value),
                isPositive: true
            });
        }
        return Int({
            value: sint.value.sub(value),
            isPositive: false
        });
    }

    function sub(
        Int memory sint,
        uint256 value
    )
        internal
        pure
        returns (Int memory)
    {

        if (!sint.isPositive) {
            return Int({
                value: value.add(sint.value),
                isPositive: false
            });
        }
        if (sint.value > value) {
            return Int({
                value: sint.value.sub(value),
                isPositive: true
            });
        }
        return Int({
            value: value.sub(sint.value),
            isPositive: false
        });
    }

    function signedAdd(
        Int memory augend,
        Int memory addend
    )
        internal
        pure
        returns (Int memory)
    {

        return addend.isPositive
            ? add(augend, addend.value)
            : sub(augend, addend.value);
    }

    function signedSub(
        Int memory minuend,
        Int memory subtrahend
    )
        internal
        pure
        returns (Int memory)
    {

        return subtrahend.isPositive
            ? sub(minuend, subtrahend.value)
            : add(minuend, subtrahend.value);
    }

    function gt(
        Int memory a,
        Int memory b
    )
        internal
        pure
        returns (bool)
    {

        if (a.isPositive) {
            if (b.isPositive) {
                return a.value > b.value;
            } else {
                return a.value != 0 || b.value != 0;
            }
        } else {
            if (b.isPositive) {
                return false;
            } else {
                return a.value < b.value;
            }
        }
    }

    function min(
        Int memory a,
        Int memory b
    )
        internal
        pure
        returns (Int memory)
    {

        return gt(b, a) ? a : b;
    }

    function max(
        Int memory a,
        Int memory b
    )
        internal
        pure
        returns (Int memory)
    {

        return gt(a, b) ? a : b;
    }
}


interface I_P1Funder {


    function getFunding(
        uint256 timeDelta
    )
        external
        view
        returns (bool, uint256);

}


interface I_P1Oracle {


    function getPrice()
        external
        view
        returns (uint256);

}


library P1BalanceMath {

    using BaseMath for uint256;
    using SafeCast for uint256;
    using SafeMath for uint256;
    using SignedMath for SignedMath.Int;
    using P1BalanceMath for P1Types.Balance;


    uint256 private constant FLAG_MARGIN_IS_POSITIVE = 1 << (8 * 31);
    uint256 private constant FLAG_POSITION_IS_POSITIVE = 1 << (8 * 15);


    function copy(
        P1Types.Balance memory balance
    )
        internal
        pure
        returns (P1Types.Balance memory)
    {

        return P1Types.Balance({
            marginIsPositive: balance.marginIsPositive,
            positionIsPositive: balance.positionIsPositive,
            margin: balance.margin,
            position: balance.position
        });
    }

    function addToMargin(
        P1Types.Balance memory balance,
        uint256 amount
    )
        internal
        pure
    {

        SignedMath.Int memory signedMargin = balance.getMargin();
        signedMargin = signedMargin.add(amount);
        balance.setMargin(signedMargin);
    }

    function subFromMargin(
        P1Types.Balance memory balance,
        uint256 amount
    )
        internal
        pure
    {

        SignedMath.Int memory signedMargin = balance.getMargin();
        signedMargin = signedMargin.sub(amount);
        balance.setMargin(signedMargin);
    }

    function addToPosition(
        P1Types.Balance memory balance,
        uint256 amount
    )
        internal
        pure
    {

        SignedMath.Int memory signedPosition = balance.getPosition();
        signedPosition = signedPosition.add(amount);
        balance.setPosition(signedPosition);
    }

    function subFromPosition(
        P1Types.Balance memory balance,
        uint256 amount
    )
        internal
        pure
    {

        SignedMath.Int memory signedPosition = balance.getPosition();
        signedPosition = signedPosition.sub(amount);
        balance.setPosition(signedPosition);
    }

    function getPositiveAndNegativeValue(
        P1Types.Balance memory balance,
        uint256 price
    )
        internal
        pure
        returns (uint256, uint256)
    {

        uint256 positiveValue = 0;
        uint256 negativeValue = 0;

        if (balance.marginIsPositive) {
            positiveValue = uint256(balance.margin).mul(BaseMath.base());
        } else {
            negativeValue = uint256(balance.margin).mul(BaseMath.base());
        }

        uint256 positionValue = uint256(balance.position).mul(price);
        if (balance.positionIsPositive) {
            positiveValue = positiveValue.add(positionValue);
        } else {
            negativeValue = negativeValue.add(positionValue);
        }

        return (positiveValue, negativeValue);
    }

    function toBytes32(
        P1Types.Balance memory balance
    )
        internal
        pure
        returns (bytes32)
    {

        uint256 result =
            uint256(balance.position)
            | (uint256(balance.margin) << 128)
            | (balance.marginIsPositive ? FLAG_MARGIN_IS_POSITIVE : 0)
            | (balance.positionIsPositive ? FLAG_POSITION_IS_POSITIVE : 0);
        return bytes32(result);
    }


    function getMargin(
        P1Types.Balance memory balance
    )
        internal
        pure
        returns (SignedMath.Int memory)
    {

        return SignedMath.Int({
            value: balance.margin,
            isPositive: balance.marginIsPositive
        });
    }

    function getPosition(
        P1Types.Balance memory balance
    )
        internal
        pure
        returns (SignedMath.Int memory)
    {

        return SignedMath.Int({
            value: balance.position,
            isPositive: balance.positionIsPositive
        });
    }

    function setMargin(
        P1Types.Balance memory balance,
        SignedMath.Int memory newMargin
    )
        internal
        pure
    {

        balance.margin = newMargin.value.toUint120();
        balance.marginIsPositive = newMargin.isPositive;
    }

    function setPosition(
        P1Types.Balance memory balance,
        SignedMath.Int memory newPosition
    )
        internal
        pure
    {

        balance.position = newPosition.value.toUint120();
        balance.positionIsPositive = newPosition.isPositive;
    }
}


library P1IndexMath {



    uint256 private constant FLAG_IS_POSITIVE = 1 << (8 * 16);


    function toBytes32(
        P1Types.Index memory index
    )
        internal
        pure
        returns (bytes32)
    {

        uint256 result =
            index.value
            | (index.isPositive ? FLAG_IS_POSITIVE : 0)
            | (uint256(index.timestamp) << 136);
        return bytes32(result);
    }
}


contract P1Settlement is
    P1Storage
{

    using BaseMath for uint256;
    using SafeCast for uint256;
    using SafeMath for uint256;
    using P1BalanceMath for P1Types.Balance;
    using P1IndexMath for P1Types.Index;
    using SignedMath for SignedMath.Int;


    event LogIndex(
        bytes32 index
    );

    event LogAccountSettled(
        address indexed account,
        bool isPositive,
        uint256 amount,
        bytes32 balance
    );


    function _loadContext()
        internal
        returns (P1Types.Context memory)
    {

        P1Types.Index memory index = _GLOBAL_INDEX_;

        uint256 price = I_P1Oracle(_ORACLE_).getPrice();

        uint256 timeDelta = block.timestamp.sub(index.timestamp);
        if (timeDelta > 0) {
            SignedMath.Int memory signedIndex = SignedMath.Int({
                value: index.value,
                isPositive: index.isPositive
            });

            (
                bool fundingPositive,
                uint256 fundingValue
            ) = I_P1Funder(_FUNDER_).getFunding(timeDelta);
            fundingValue = fundingValue.baseMul(price);

            if (fundingPositive) {
                signedIndex = signedIndex.add(fundingValue);
            } else {
                signedIndex = signedIndex.sub(fundingValue);
            }

            index = P1Types.Index({
                timestamp: block.timestamp.toUint32(),
                isPositive: signedIndex.isPositive,
                value: signedIndex.value.toUint128()
            });
            _GLOBAL_INDEX_ = index;
        }

        emit LogIndex(index.toBytes32());

        return P1Types.Context({
            price: price,
            minCollateral: _MIN_COLLATERAL_,
            index: index
        });
    }

    function _settleAccounts(
        P1Types.Context memory context,
        address[] memory accounts
    )
        internal
        returns (P1Types.Balance[] memory)
    {

        uint256 numAccounts = accounts.length;
        P1Types.Balance[] memory result = new P1Types.Balance[](numAccounts);

        for (uint256 i = 0; i < numAccounts; i++) {
            result[i] = _settleAccount(context, accounts[i]);
        }

        return result;
    }

    function _settleAccount(
        P1Types.Context memory context,
        address account
    )
        internal
        returns (P1Types.Balance memory)
    {

        P1Types.Index memory newIndex = context.index;
        P1Types.Index memory oldIndex = _LOCAL_INDEXES_[account];
        P1Types.Balance memory balance = _BALANCES_[account];

        if (oldIndex.timestamp == newIndex.timestamp) {
            return balance;
        }

        _LOCAL_INDEXES_[account] = newIndex;

        if (balance.position == 0) {
            return balance;
        }

        SignedMath.Int memory signedIndexDiff = SignedMath.Int({
            isPositive: newIndex.isPositive,
            value: newIndex.value
        });
        if (oldIndex.isPositive) {
            signedIndexDiff = signedIndexDiff.sub(oldIndex.value);
        } else {
            signedIndexDiff = signedIndexDiff.add(oldIndex.value);
        }

        bool settlementIsPositive = signedIndexDiff.isPositive != balance.positionIsPositive;

        uint256 settlementAmount;
        if (settlementIsPositive) {
            settlementAmount = signedIndexDiff.value.baseMul(balance.position);
            balance.addToMargin(settlementAmount);
        } else {
            settlementAmount = signedIndexDiff.value.baseMulRoundUp(balance.position);
            balance.subFromMargin(settlementAmount);
        }
        _BALANCES_[account] = balance;

        emit LogAccountSettled(
            account,
            settlementIsPositive,
            settlementAmount,
            balance.toBytes32()
        );

        return balance;
    }

    function _isCollateralized(
        P1Types.Context memory context,
        P1Types.Balance memory balance
    )
        internal
        pure
        returns (bool)
    {

        (uint256 positive, uint256 negative) = balance.getPositiveAndNegativeValue(context.price);

        return positive.mul(BaseMath.base()) >= negative.mul(context.minCollateral);
    }
}


library Math {

    using SafeMath for uint256;


    function getFraction(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (uint256)
    {

        return target.mul(numerator).div(denominator);
    }

    function getFractionRoundUp(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (uint256)
    {

        if (target == 0 || numerator == 0) {
            return SafeMath.div(0, denominator);
        }
        return target.mul(numerator).sub(1).div(denominator).add(1);
    }

    function min(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return a < b ? a : b;
    }

    function max(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return a > b ? a : b;
    }
}


contract P1FinalSettlement is
    P1Settlement
{

    using SafeMath for uint256;


    event LogWithdrawFinalSettlement(
        address indexed account,
        uint256 amount,
        bytes32 balance
    );


    modifier noFinalSettlement() {

        require(
            !_FINAL_SETTLEMENT_ENABLED_,
            "Not permitted during final settlement"
        );
        _;
    }

    modifier onlyFinalSettlement() {

        require(
            _FINAL_SETTLEMENT_ENABLED_,
            "Only permitted during final settlement"
        );
        _;
    }


    function withdrawFinalSettlement()
        external
        onlyFinalSettlement
        nonReentrant
    {

        P1Types.Context memory context = P1Types.Context({
            price: _FINAL_SETTLEMENT_PRICE_,
            minCollateral: _MIN_COLLATERAL_,
            index: _GLOBAL_INDEX_
        });

        P1Types.Balance memory balance = _settleAccount(context, msg.sender);

        (uint256 positive, uint256 negative) = P1BalanceMath.getPositiveAndNegativeValue(
            balance,
            context.price
        );

        if (positive < negative) {
            return;
        }

        uint256 accountValue = positive.sub(negative).div(BaseMath.base());

        uint256 contractBalance = IERC20(_TOKEN_).balanceOf(address(this));

        uint256 amountToWithdraw = Math.min(contractBalance, accountValue);

        uint120 remainingMargin = accountValue.sub(amountToWithdraw).toUint120();
        balance = P1Types.Balance({
            marginIsPositive: remainingMargin != 0,
            positionIsPositive: false,
            margin: remainingMargin,
            position: 0
        });
        _BALANCES_[msg.sender] = balance;

        SafeERC20.safeTransfer(
            IERC20(_TOKEN_),
            msg.sender,
            amountToWithdraw
        );

        emit LogWithdrawFinalSettlement(
            msg.sender,
            amountToWithdraw,
            balance.toBytes32()
        );
    }
}


contract P1Admin is
    P1Storage,
    P1FinalSettlement
{


    event LogSetGlobalOperator(
        address operator,
        bool approved
    );

    event LogSetOracle(
        address oracle
    );

    event LogSetFunder(
        address funder
    );

    event LogSetMinCollateral(
        uint256 minCollateral
    );

    event LogFinalSettlementEnabled(
        uint256 settlementPrice
    );


    function setGlobalOperator(
        address operator,
        bool approved
    )
        external
        onlyAdmin
        nonReentrant
    {

        _GLOBAL_OPERATORS_[operator] = approved;
        emit LogSetGlobalOperator(operator, approved);
    }

    function setOracle(
        address oracle
    )
        external
        onlyAdmin
        nonReentrant
    {

        require(
            I_P1Oracle(oracle).getPrice() != 0,
            "New oracle cannot return a zero price"
        );
        _ORACLE_ = oracle;
        emit LogSetOracle(oracle);
    }

    function setFunder(
        address funder
    )
        external
        onlyAdmin
        nonReentrant
    {

        I_P1Funder(funder).getFunding(0);

        _FUNDER_ = funder;
        emit LogSetFunder(funder);
    }

    function setMinCollateral(
        uint256 minCollateral
    )
        external
        onlyAdmin
        nonReentrant
    {

        require(
            minCollateral >= BaseMath.base(),
            "The collateral requirement cannot be under 100%"
        );
        _MIN_COLLATERAL_ = minCollateral;
        emit LogSetMinCollateral(minCollateral);
    }

    function enableFinalSettlement(
        uint256 priceLowerBound,
        uint256 priceUpperBound
    )
        external
        onlyAdmin
        noFinalSettlement
        nonReentrant
    {

        P1Types.Context memory context = _loadContext();

        require(
            context.price >= priceLowerBound,
            "Oracle price is less than the provided lower bound"
        );
        require(
            context.price <= priceUpperBound,
            "Oracle price is greater than the provided upper bound"
        );

        _FINAL_SETTLEMENT_PRICE_ = context.price;
        _FINAL_SETTLEMENT_ENABLED_ = true;

        emit LogFinalSettlementEnabled(_FINAL_SETTLEMENT_PRICE_);
    }
}


contract P1Getters is
    P1Storage
{


    function getAccountBalance(
        address account
    )
        external
        view
        returns (P1Types.Balance memory)
    {

        return _BALANCES_[account];
    }

    function getAccountIndex(
        address account
    )
        external
        view
        returns (P1Types.Index memory)
    {

        return _LOCAL_INDEXES_[account];
    }

    function getIsLocalOperator(
        address account,
        address operator
    )
        external
        view
        returns (bool)
    {

        return _LOCAL_OPERATORS_[account][operator];
    }


    function getIsGlobalOperator(
        address operator
    )
        external
        view
        returns (bool)
    {

        return _GLOBAL_OPERATORS_[operator];
    }

    function getTokenContract()
        external
        view
        returns (address)
    {

        return _TOKEN_;
    }

    function getOracleContract()
        external
        view
        returns (address)
    {

        return _ORACLE_;
    }

    function getFunderContract()
        external
        view
        returns (address)
    {

        return _FUNDER_;
    }

    function getGlobalIndex()
        external
        view
        returns (P1Types.Index memory)
    {

        return _GLOBAL_INDEX_;
    }

    function getMinCollateral()
        external
        view
        returns (uint256)
    {

        return _MIN_COLLATERAL_;
    }

    function getFinalSettlementEnabled()
        external
        view
        returns (bool)
    {

        return _FINAL_SETTLEMENT_ENABLED_;
    }


    function getOraclePrice()
        external
        view
        returns (uint256)
    {

        require(
            _GLOBAL_OPERATORS_[msg.sender],
            "Oracle price requester not global operator"
        );
        return I_P1Oracle(_ORACLE_).getPrice();
    }


    function hasAccountPermissions(
        address account,
        address operator
    )
        public
        view
        returns (bool)
    {

        return account == operator
            || _GLOBAL_OPERATORS_[operator]
            || _LOCAL_OPERATORS_[account][operator];
    }
}


contract P1Margin is
    P1FinalSettlement,
    P1Getters
{

    using P1BalanceMath for P1Types.Balance;


    event LogDeposit(
        address indexed account,
        uint256 amount,
        bytes32 balance
    );

    event LogWithdraw(
        address indexed account,
        address destination,
        uint256 amount,
        bytes32 balance
    );


    function deposit(
        address account,
        uint256 amount
    )
        external
        noFinalSettlement
        nonReentrant
    {

        P1Types.Context memory context = _loadContext();
        P1Types.Balance memory balance = _settleAccount(context, account);

        SafeERC20.safeTransferFrom(
            IERC20(_TOKEN_),
            msg.sender,
            address(this),
            amount
        );

        balance.addToMargin(amount);
        _BALANCES_[account] = balance;

        emit LogDeposit(
            account,
            amount,
            balance.toBytes32()
        );
    }

    function withdraw(
        address account,
        address destination,
        uint256 amount
    )
        external
        noFinalSettlement
        nonReentrant
    {

        require(
            hasAccountPermissions(account, msg.sender),
            "sender does not have permission to withdraw"
        );

        P1Types.Context memory context = _loadContext();
        P1Types.Balance memory balance = _settleAccount(context, account);

        SafeERC20.safeTransfer(
            IERC20(_TOKEN_),
            destination,
            amount
        );

        balance.subFromMargin(amount);
        _BALANCES_[account] = balance;

        require(
            _isCollateralized(context, balance),
            "account not collateralized"
        );

        emit LogWithdraw(
            account,
            destination,
            amount,
            balance.toBytes32()
        );
    }
}


contract P1Operator is
    P1Storage
{


    event LogSetLocalOperator(
        address indexed sender,
        address operator,
        bool approved
    );


    function setLocalOperator(
        address operator,
        bool approved
    )
        external
    {

        _LOCAL_OPERATORS_[msg.sender][operator] = approved;
        emit LogSetLocalOperator(msg.sender, operator, approved);
    }
}


library Require {



    uint256 constant ASCII_ZERO = 0x30; // '0'
    uint256 constant ASCII_RELATIVE_ZERO = 0x57; // 'a' - 10
    uint256 constant FOUR_BIT_MASK = 0xf;
    bytes23 constant ZERO_ADDRESS =
    0x3a20307830303030303030302e2e2e3030303030303030; // ": 0x00000000...00000000"


    function that(
        bool must,
        string memory reason,
        address addr
    )
        internal
        pure
    {

        if (!must) {
            revert(string(abi.encodePacked(reason, stringify(addr))));
        }
    }


    function stringify(
        address input
    )
        private
        pure
        returns (bytes memory)
    {

        bytes memory result = abi.encodePacked(ZERO_ADDRESS);

        uint256 z = uint256(input);
        uint256 shift1 = 8 * 20 - 4;
        uint256 shift2 = 8 * 4 - 4;

        for (uint256 i = 4; i < 12; i++) {
            result[i] = char(z >> shift1); // set char in first section
            result[i + 11] = char(z >> shift2); // set char in second section
            shift1 -= 4;
            shift2 -= 4;
        }

        return result;
    }

    function char(
        uint256 input
    )
        private
        pure
        returns (byte)
    {

        uint256 b = input & FOUR_BIT_MASK;
        return byte(uint8(b + ((b < 10) ? ASCII_ZERO : ASCII_RELATIVE_ZERO)));
    }
}


interface I_P1Trader {


    function trade(
        address sender,
        address maker,
        address taker,
        uint256 price,
        bytes calldata data,
        bytes32 traderFlags
    )
        external
        returns (P1Types.TradeResult memory);

}


contract P1Trade is
    P1FinalSettlement
{

    using SafeMath for uint120;
    using P1BalanceMath for P1Types.Balance;


    struct TradeArg {
        uint256 takerIndex;
        uint256 makerIndex;
        address trader;
        bytes data;
    }


    event LogTrade(
        address indexed maker,
        address indexed taker,
        address trader,
        uint256 marginAmount,
        uint256 positionAmount,
        bool isBuy, // from taker's perspective
        bytes32 makerBalance,
        bytes32 takerBalance
    );


    function trade(
        address[] memory accounts,
        TradeArg[] memory trades
    )
        public
        noFinalSettlement
        nonReentrant
    {

        _verifyAccounts(accounts);
        P1Types.Context memory context = _loadContext();
        P1Types.Balance[] memory initialBalances = _settleAccounts(context, accounts);
        P1Types.Balance[] memory currentBalances = new P1Types.Balance[](initialBalances.length);

        uint256 i;
        for (i = 0; i < initialBalances.length; i++) {
            currentBalances[i] = initialBalances[i].copy();
        }

        bytes32 traderFlags = 0;
        for (i = 0; i < trades.length; i++) {
            TradeArg memory tradeArg = trades[i];

            require(
                _GLOBAL_OPERATORS_[tradeArg.trader],
                "trader is not global operator"
            );

            address maker = accounts[tradeArg.makerIndex];
            address taker = accounts[tradeArg.takerIndex];

            P1Types.TradeResult memory tradeResult = I_P1Trader(tradeArg.trader).trade(
                msg.sender,
                maker,
                taker,
                context.price,
                tradeArg.data,
                traderFlags
            );

            traderFlags |= tradeResult.traderFlags;

            if (maker == taker) {
                continue;
            }

            P1Types.Balance memory makerBalance = currentBalances[tradeArg.makerIndex];
            P1Types.Balance memory takerBalance = currentBalances[tradeArg.takerIndex];
            if (tradeResult.isBuy) {
                makerBalance.addToMargin(tradeResult.marginAmount);
                makerBalance.subFromPosition(tradeResult.positionAmount);
                takerBalance.subFromMargin(tradeResult.marginAmount);
                takerBalance.addToPosition(tradeResult.positionAmount);
            } else {
                makerBalance.subFromMargin(tradeResult.marginAmount);
                makerBalance.addToPosition(tradeResult.positionAmount);
                takerBalance.addToMargin(tradeResult.marginAmount);
                takerBalance.subFromPosition(tradeResult.positionAmount);
            }

            _BALANCES_[maker] = makerBalance;
            _BALANCES_[taker] = takerBalance;

            emit LogTrade(
                maker,
                taker,
                tradeArg.trader,
                tradeResult.marginAmount,
                tradeResult.positionAmount,
                tradeResult.isBuy,
                makerBalance.toBytes32(),
                takerBalance.toBytes32()
            );
        }

        _verifyAccountsFinalBalances(
            context,
            accounts,
            initialBalances,
            currentBalances
        );
    }

    function _verifyAccounts(
        address[] memory accounts
    )
        private
        pure
    {

        require(
            accounts.length > 0,
            "Accounts must have non-zero length"
        );

        address prevAccount = accounts[0];
        for (uint256 i = 1; i < accounts.length; i++) {
            address account = accounts[i];
            require(
                account > prevAccount,
                "Accounts must be sorted and unique"
            );
            prevAccount = account;
        }
    }

    function _verifyAccountsFinalBalances(
        P1Types.Context memory context,
        address[] memory accounts,
        P1Types.Balance[] memory initialBalances,
        P1Types.Balance[] memory currentBalances
    )
        private
        pure
    {

        for (uint256 i = 0; i < accounts.length; i++) {
            P1Types.Balance memory currentBalance = currentBalances[i];
            (uint256 currentPos, uint256 currentNeg) =
                currentBalance.getPositiveAndNegativeValue(context.price);

            bool isCollateralized =
                currentPos.mul(BaseMath.base()) >= currentNeg.mul(context.minCollateral);

            if (isCollateralized) {
                continue;
            }

            address account = accounts[i];
            P1Types.Balance memory initialBalance = initialBalances[i];
            (uint256 initialPos, uint256 initialNeg) =
                initialBalance.getPositiveAndNegativeValue(context.price);

            Require.that(
                currentPos != 0,
                "account is undercollateralized and has no positive value",
                account
            );
            Require.that(
                currentBalance.position <= initialBalance.position,
                "account is undercollateralized and absolute position size increased",
                account
            );


            Require.that(
                currentBalance.positionIsPositive == initialBalance.positionIsPositive,
                "account is undercollateralized and position changed signs",
                account
            );
            Require.that(
                initialNeg != 0,
                "account is undercollateralized and was not previously",
                account
            );


            Require.that(
                currentBalance.positionIsPositive
                    ? currentNeg.baseDivMul(initialPos) <= initialNeg.baseDivMul(currentPos)
                    : initialPos.baseDivMul(currentNeg) <= currentPos.baseDivMul(initialNeg),
                "account is undercollateralized and collateralization decreased",
                account
            );
        }
    }
}


contract PerpetualV1 is
    P1FinalSettlement,
    P1Admin,
    P1Getters,
    P1Margin,
    P1Operator,
    P1Trade
{

    bytes32 internal constant PERPETUAL_V1_INITIALIZE_SLOT =
    bytes32(uint256(keccak256("dYdX.PerpetualV1.initialize")) - 1);

    function initializeV1(
        address token,
        address oracle,
        address funder,
        uint256 minCollateral
    )
        external
        onlyAdmin
        nonReentrant
    {

        require(
            Storage.load(PERPETUAL_V1_INITIALIZE_SLOT) == 0x0,
            "PerpetualV1 already initialized"
        );
        Storage.store(PERPETUAL_V1_INITIALIZE_SLOT, bytes32(uint256(1)));

        _TOKEN_ = token;
        _ORACLE_ = oracle;
        _FUNDER_ = funder;
        _MIN_COLLATERAL_ = minCollateral;

        _GLOBAL_INDEX_ = P1Types.Index({
            timestamp: uint32(block.timestamp),
            isPositive: false,
            value: 0
        });
    }
}