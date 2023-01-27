

pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


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

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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


interface I_PerpetualV1 {



    struct TradeArg {
        uint256 takerIndex;
        uint256 makerIndex;
        address trader;
        bytes data;
    }


    function trade(
        address[] calldata accounts,
        TradeArg[] calldata trades
    )
        external;


    function withdrawFinalSettlement()
        external;


    function deposit(
        address account,
        uint256 amount
    )
        external;


    function withdraw(
        address account,
        address destination,
        uint256 amount
    )
        external;


    function setLocalOperator(
        address operator,
        bool approved
    )
        external;



    function getAccountBalance(
        address account
    )
        external
        view
        returns (P1Types.Balance memory);


    function getAccountIndex(
        address account
    )
        external
        view
        returns (P1Types.Index memory);


    function getIsLocalOperator(
        address account,
        address operator
    )
        external
        view
        returns (bool);



    function getIsGlobalOperator(
        address operator
    )
        external
        view
        returns (bool);


    function getTokenContract()
        external
        view
        returns (address);


    function getOracleContract()
        external
        view
        returns (address);


    function getFunderContract()
        external
        view
        returns (address);


    function getGlobalIndex()
        external
        view
        returns (P1Types.Index memory);


    function getMinCollateral()
        external
        view
        returns (uint256);


    function getFinalSettlementEnabled()
        external
        view
        returns (bool);



    function hasAccountPermissions(
        address account,
        address operator
    )
        external
        view
        returns (bool);



    function getOraclePrice()
        external
        view
        returns (uint256);

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


contract P1LiquidatorProxy is
    Ownable
{

    using BaseMath for uint256;
    using SafeMath for uint256;
    using SignedMath for SignedMath.Int;
    using P1BalanceMath for P1Types.Balance;
    using SafeERC20 for IERC20;


    event LogLiquidatorProxyUsed(
        address indexed liquidatee,
        address indexed liquidator,
        bool isBuy,
        uint256 liquidationAmount,
        uint256 feeAmount
    );

    event LogInsuranceFundSet(
        address insuranceFund
    );

    event LogInsuranceFeeSet(
        uint256 insuranceFee
    );


    address public _PERPETUAL_V1_;

    address public _LIQUIDATION_;


    address public _INSURANCE_FUND_;

    uint256 public _INSURANCE_FEE_;


    constructor (
        address perpetualV1,
        address liquidator,
        address insuranceFund,
        uint256 insuranceFee
    )
        public
    {
        _PERPETUAL_V1_ = perpetualV1;
        _LIQUIDATION_ = liquidator;
        _INSURANCE_FUND_ = insuranceFund;
        _INSURANCE_FEE_ = insuranceFee;

        emit LogInsuranceFundSet(insuranceFund);
        emit LogInsuranceFeeSet(insuranceFee);
    }


    function approveMaximumOnPerpetual()
        external
    {

        address perpetual = _PERPETUAL_V1_;
        IERC20 tokenContract = IERC20(I_PerpetualV1(perpetual).getTokenContract());

        tokenContract.safeApprove(perpetual, 0);

        tokenContract.safeApprove(perpetual, uint256(-1));
    }

    function liquidate(
        address liquidatee,
        address liquidator,
        bool isBuy,
        SignedMath.Int calldata maxPosition
    )
        external
        returns (uint256)
    {

        I_PerpetualV1 perpetual = I_PerpetualV1(_PERPETUAL_V1_);

        require(
            liquidator == msg.sender || perpetual.hasAccountPermissions(liquidator, msg.sender),
            "msg.sender cannot operate the liquidator account"
        );

        perpetual.deposit(liquidator, 0);
        P1Types.Balance memory initialBalance = perpetual.getAccountBalance(liquidator);

        SignedMath.Int memory maxPositionDelta = _getMaxPositionDelta(
            initialBalance,
            isBuy,
            maxPosition
        );

        _doLiquidation(
            perpetual,
            liquidatee,
            liquidator,
            maxPositionDelta
        );

        P1Types.Balance memory currentBalance = perpetual.getAccountBalance(liquidator);

        (uint256 liqAmount, uint256 feeAmount) = _getLiquidatedAndFeeAmount(
            perpetual,
            initialBalance,
            currentBalance
        );

        if (feeAmount > 0) {
            perpetual.withdraw(liquidator, address(this), feeAmount);
            perpetual.deposit(_INSURANCE_FUND_, feeAmount);
        }

        emit LogLiquidatorProxyUsed(
            liquidatee,
            liquidator,
            isBuy,
            liqAmount,
            feeAmount
        );

        return liqAmount;
    }


    function setInsuranceFund(
        address insuranceFund
    )
        external
        onlyOwner
    {

        _INSURANCE_FUND_ = insuranceFund;
        emit LogInsuranceFundSet(insuranceFund);
    }

    function setInsuranceFee(
        uint256 insuranceFee
    )
        external
        onlyOwner
    {

        require(
            insuranceFee <= BaseMath.base().div(2),
            "insuranceFee cannot be greater than 50%"
        );
        _INSURANCE_FEE_ = insuranceFee;
        emit LogInsuranceFeeSet(insuranceFee);
    }


    function _getMaxPositionDelta(
        P1Types.Balance memory initialBalance,
        bool isBuy,
        SignedMath.Int memory maxPosition
    )
        private
        pure
        returns (SignedMath.Int memory)
    {

        SignedMath.Int memory result = maxPosition.signedSub(initialBalance.getPosition());

        require(
            result.isPositive == isBuy && result.value > 0,
            "Cannot liquidate if it would put liquidator past the specified maxPosition"
        );

        return result;
    }

    function _doLiquidation(
        I_PerpetualV1 perpetual,
        address liquidatee,
        address liquidator,
        SignedMath.Int memory maxPositionDelta
    )
        private
    {

        bool takerFirst = liquidator < liquidatee;
        address[] memory accounts = new address[](2);
        uint256 takerIndex = takerFirst ? 0 : 1;
        uint256 makerIndex = takerFirst ? 1 : 0;
        accounts[takerIndex] = liquidator;
        accounts[makerIndex] = liquidatee;

        I_PerpetualV1.TradeArg[] memory trades = new I_PerpetualV1.TradeArg[](1);
        trades[0] = I_PerpetualV1.TradeArg({
            takerIndex: takerIndex,
            makerIndex: makerIndex,
            trader: _LIQUIDATION_,
            data: abi.encode(
                maxPositionDelta.value,
                maxPositionDelta.isPositive,
                false // allOrNothing
            )
        });

        perpetual.trade(accounts, trades);
    }

    function _getLiquidatedAndFeeAmount(
        I_PerpetualV1 perpetual,
        P1Types.Balance memory initialBalance,
        P1Types.Balance memory currentBalance
    )
        private
        view
        returns (uint256, uint256)
    {

        SignedMath.Int memory deltaPosition =
            currentBalance.getPosition().signedSub(initialBalance.getPosition());
        SignedMath.Int memory deltaMargin =
            currentBalance.getMargin().signedSub(initialBalance.getMargin());

        P1Types.Balance memory deltaBalance;
        deltaBalance.setPosition(deltaPosition);
        deltaBalance.setMargin(deltaMargin);

        uint256 price = perpetual.getOraclePrice();
        (uint256 posValue, uint256 negValue) = deltaBalance.getPositiveAndNegativeValue(price);

        uint256 feeAmount = posValue > negValue
            ? posValue.sub(negValue).baseMul(_INSURANCE_FEE_).div(BaseMath.base())
            : 0;

        return (deltaPosition.value, feeAmount);
    }
}