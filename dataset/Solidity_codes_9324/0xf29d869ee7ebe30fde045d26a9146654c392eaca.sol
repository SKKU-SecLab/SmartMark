


pragma solidity 0.5.16;

interface IComptroller {


    function markets(address) external view returns (bool, uint);

    function oracle() external view returns (address);

    function getAccountLiquidity(address) external view returns (uint, uint, uint);

    function getAssetsIn(address) external view returns (address[] memory);

    function compAccrued(address) external view returns (uint);

    function claimComp(address holder) external;

    function claimComp(address holder, address[] calldata cTokens) external;

    function claimComp(address[] calldata holders, address[] calldata cTokens, bool borrowers, bool suppliers) external;


    function checkMembership(address account, address cToken) external view returns (bool);

    function closeFactorMantissa() external returns (uint256);

    function liquidationIncentiveMantissa() external returns (uint256);




    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);

    function exitMarket(address cToken) external returns (uint);


    function mintAllowed(address cToken, address minter, uint mintAmount) external returns (uint);

    function borrowAllowed(address cToken, address borrower, uint borrowAmount) external returns (uint);


    function getAllMarkets() external view returns (address[] memory);


    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint actualRepayAmount) external view returns (uint, uint);


    function compBorrowState(address cToken) external returns (uint224, uint32);

    function compSupplyState(address cToken) external returns (uint224, uint32);

}


pragma solidity 0.5.16;


interface IRegistry {


    function transferOwnership(address newOwner) external;


    function comp() external view returns (address);

    function comptroller() external view returns (address);

    function cEther() external view returns (address);


    function bComptroller() external view returns (address);

    function score() external view returns (address);

    function pool() external view returns (address);


    function delegate(address avatar, address delegatee) external view returns (bool);

    function doesAvatarExist(address avatar) external view returns (bool);

    function doesAvatarExistFor(address owner) external view returns (bool);

    function ownerOf(address avatar) external view returns (address);

    function avatarOf(address owner) external view returns (address);

    function newAvatar() external returns (address);

    function getAvatar(address owner) external returns (address);

    function whitelistedAvatarCalls(address target, bytes4 functionSig) external view returns(bool);


    function setPool(address newPool) external;

    function setWhitelistAvatarCall(address target, bytes4 functionSig, bool list) external;

}


pragma solidity 0.5.16;

interface IScore {

    function updateDebtScore(address _user, address cToken, int256 amount) external;

    function updateCollScore(address _user, address cToken, int256 amount) external;

    function slashedScore(address _user, address cToken, int256 amount) external;

}


pragma solidity 0.5.16;

contract CarefulMath {


    enum MathError {
        NO_ERROR,
        DIVISION_BY_ZERO,
        INTEGER_OVERFLOW,
        INTEGER_UNDERFLOW
    }

    function mulUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (a == 0) {
            return (MathError.NO_ERROR, 0);
        }

        uint c = a * b;

        if (c / a != b) {
            return (MathError.INTEGER_OVERFLOW, 0);
        } else {
            return (MathError.NO_ERROR, c);
        }
    }

    function divUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (b == 0) {
            return (MathError.DIVISION_BY_ZERO, 0);
        }

        return (MathError.NO_ERROR, a / b);
    }

    function subUInt(uint a, uint b) internal pure returns (MathError, uint) {

        if (b <= a) {
            return (MathError.NO_ERROR, a - b);
        } else {
            return (MathError.INTEGER_UNDERFLOW, 0);
        }
    }

    function addUInt(uint a, uint b) internal pure returns (MathError, uint) {

        uint c = a + b;

        if (c >= a) {
            return (MathError.NO_ERROR, c);
        } else {
            return (MathError.INTEGER_OVERFLOW, 0);
        }
    }

    function addThenSubUInt(uint a, uint b, uint c) internal pure returns (MathError, uint) {

        (MathError err0, uint sum) = addUInt(a, b);

        if (err0 != MathError.NO_ERROR) {
            return (err0, 0);
        }

        return subUInt(sum, c);
    }
}


pragma solidity 0.5.16;


contract Exponential is CarefulMath {

    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale/2;
    uint constant mantissaOne = expScale;

    struct Exp {
        uint mantissa;
    }

    struct Double {
        uint mantissa;
    }

    function getExp(uint num, uint denom) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint scaledNumerator) = mulUInt(num, expScale);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint rational) = divUInt(scaledNumerator, denom);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: rational}));
    }

    function mulScalar(Exp memory a, uint scalar) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint scaledMantissa) = mulUInt(a.mantissa, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        return (MathError.NO_ERROR, Exp({mantissa: scaledMantissa}));
    }

    function mulScalarTruncate(Exp memory a, uint scalar) pure internal returns (MathError, uint) {

        (MathError err, Exp memory product) = mulScalar(a, scalar);
        if (err != MathError.NO_ERROR) {
            return (err, 0);
        }

        return (MathError.NO_ERROR, truncate(product));
    }

    function divScalarByExp(uint scalar, Exp memory divisor) pure internal returns (MathError, Exp memory) {

        (MathError err0, uint numerator) = mulUInt(expScale, scalar);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }
        return getExp(numerator, divisor.mantissa);
    }

    function mulExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {


        (MathError err0, uint doubleScaledProduct) = mulUInt(a.mantissa, b.mantissa);
        if (err0 != MathError.NO_ERROR) {
            return (err0, Exp({mantissa: 0}));
        }

        (MathError err1, uint doubleScaledProductWithHalfScale) = addUInt(halfExpScale, doubleScaledProduct);
        if (err1 != MathError.NO_ERROR) {
            return (err1, Exp({mantissa: 0}));
        }

        (MathError err2, uint product) = divUInt(doubleScaledProductWithHalfScale, expScale);
        assert(err2 == MathError.NO_ERROR);

        return (MathError.NO_ERROR, Exp({mantissa: product}));
    }

    function mulExp(uint a, uint b) pure internal returns (MathError, Exp memory) {

        return mulExp(Exp({mantissa: a}), Exp({mantissa: b}));
    }


    function divExp(Exp memory a, Exp memory b) pure internal returns (MathError, Exp memory) {

        return getExp(a.mantissa, b.mantissa);
    }

    function truncate(Exp memory exp) pure internal returns (uint) {

        return exp.mantissa / expScale;
    }


    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {

        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {

        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {

        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {

        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) pure internal returns (uint) {

        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {

        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {

        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {

        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {

        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) pure internal returns (uint) {

        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {

        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {

        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {

        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {

        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }


    function mulTrucate(uint a, uint b) internal pure returns (uint) {

        return mul_(a, b) / expScale;
    }
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.5;

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


pragma solidity ^0.5.0;




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


pragma solidity 0.5.16;


contract CTokenInterface {

    function transfer(address dst, uint amount) external returns (bool);

    function transferFrom(address src, address dst, uint amount) external returns (bool);

    function approve(address spender, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function totalSupply() external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);


    function isCToken() external view returns (bool);

    function underlying() external view returns (IERC20);

    function balanceOfUnderlying(address owner) external returns (uint);

    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);

    function borrowRatePerBlock() external view returns (uint);

    function supplyRatePerBlock() external view returns (uint);

    function totalBorrowsCurrent() external returns (uint);

    function borrowBalanceCurrent(address account) external returns (uint);

    function borrowBalanceStored(address account) public view returns (uint);

    function exchangeRateCurrent() public returns (uint);

    function exchangeRateStored() public view returns (uint);

    function getCash() external view returns (uint);

    function accrueInterest() public returns (uint);

    function seize(address liquidator, address borrower, uint seizeTokens) external returns (uint);


}

contract ICToken is CTokenInterface {


    function redeem(uint redeemTokens) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function borrow(uint borrowAmount) external returns (uint);

}

contract ICErc20 is ICToken {

    function mint(uint mintAmount) external returns (uint);

    function repayBorrow(uint repayAmount) external returns (uint);

    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint);

    function liquidateBorrow(address borrower, uint repayAmount, address cTokenCollateral) external returns (uint);

}

contract ICEther is ICToken {

    function mint() external payable;

    function repayBorrow() external payable;

    function repayBorrowBehalf(address borrower) external payable;

    function liquidateBorrow(address borrower, address cTokenCollateral) external payable;

}

contract IPriceOracle {

    function getUnderlyingPrice(CTokenInterface cToken) external view returns (uint);

}


pragma solidity 0.5.16;








contract AbsAvatarBase is Exponential {

    using SafeERC20 for IERC20;

    IRegistry public registry;
    bool public quit;

    ICToken public toppedUpCToken;
    uint256 public toppedUpAmount;
    uint256 public remainingLiquidationAmount;
    ICToken public liquidationCToken;

    modifier onlyAvatarOwner() {

        _allowOnlyAvatarOwner();
        _;
    }
    function _allowOnlyAvatarOwner() internal view {

        require(msg.sender == registry.ownerOf(address(this)), "sender-not-owner");
    }

    modifier onlyPool() {

        _allowOnlyPool();
        _;
    }
    function _allowOnlyPool() internal view {

        require(msg.sender == pool(), "only-pool-authorized");
    }

    modifier onlyBComptroller() {

        _allowOnlyBComptroller();
        _;
    }
    function _allowOnlyBComptroller() internal view {

        require(msg.sender == registry.bComptroller(), "only-BComptroller-authorized");
    }

    modifier postPoolOp(bool debtIncrease) {

        _;
        _reevaluate(debtIncrease);
    }

    function _initAvatarBase(address _registry) internal {

        require(registry == IRegistry(0x0), "avatar-already-init");
        registry = IRegistry(_registry);
    }

    function _hardReevaluate() internal {

        require(canUntop(), "cannot-untop");
        remainingLiquidationAmount = 0;
    }

    function _softReevaluate() private {

        if(isPartiallyLiquidated()) {
            _hardReevaluate();
        }
    }

    function _reevaluate(bool debtIncrease) private {

        if(debtIncrease) {
            _hardReevaluate();
        } else {
            _softReevaluate();
        }
    }

    function _isCEther(ICToken cToken) internal view returns (bool) {

        return address(cToken) == registry.cEther();
    }

    function _score() internal view returns (IScore) {

        return IScore(registry.score());
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        int256 result = int256(value);
        require(result >= 0, "conversion-fail");
        return result;
    }

    function isPartiallyLiquidated() public view returns (bool) {

        return remainingLiquidationAmount > 0;
    }

    function isToppedUp() public view returns (bool) {

        return toppedUpAmount > 0;
    }

    function canUntop() public returns (bool) {

        if(!isToppedUp()) return true;
        IComptroller comptroller = IComptroller(registry.comptroller());
        bool result = comptroller.borrowAllowed(address(toppedUpCToken), address(this), toppedUpAmount) == 0;
        return result;
    }

    function pool() public view returns (address payable) {

        return address(uint160(registry.pool()));
    }

    function canLiquidate() public returns (bool) {

        bool result = isToppedUp() && (remainingLiquidationAmount > 0) || (!canUntop());

        return result;
    }

    function _ensureUserNotQuitB() internal view {

        require(! quit, "user-quit-B");
    }
    function topup() external payable onlyPool {

        _ensureUserNotQuitB();

        address cEtherAddr = registry.cEther();
        bool _isToppedUp = isToppedUp();
        if(_isToppedUp) {
            require(address(toppedUpCToken) == cEtherAddr, "already-topped-other-cToken");
        }

        ICEther cEther = ICEther(cEtherAddr);
        cEther.repayBorrow.value(msg.value)();

        if(! _isToppedUp) toppedUpCToken = cEther;
        toppedUpAmount = add_(toppedUpAmount, msg.value);
    }

    function topup(ICErc20 cToken, uint256 topupAmount) external onlyPool {

        _ensureUserNotQuitB();

        bool _isToppedUp = isToppedUp();
        if(_isToppedUp) {
            require(toppedUpCToken == cToken, "already-topped-other-cToken");
        }

        IERC20 underlying = cToken.underlying();
        underlying.safeTransferFrom(pool(), address(this), topupAmount);
        underlying.safeApprove(address(cToken), topupAmount);

        require(cToken.repayBorrow(topupAmount) == 0, "RepayBorrow-fail");

        if(! _isToppedUp) toppedUpCToken = cToken;
        toppedUpAmount = add_(toppedUpAmount, topupAmount);
    }

    function untop(uint amount) external onlyPool {

        _untop(amount, amount);
    }

    function _untop(uint amount, uint amountToBorrow) internal {

        if(!isToppedUp()) return;

        require(toppedUpAmount >= amount, "amount>=toppedUpAmount");
        toppedUpAmount = sub_(toppedUpAmount, amount);
        if((toppedUpAmount == 0) && (remainingLiquidationAmount > 0)) remainingLiquidationAmount = 0;

        if(amountToBorrow > 0 )
            require(toppedUpCToken.borrow(amountToBorrow) == 0, "borrow-fail");

        if(address(toppedUpCToken) == registry.cEther()) {
            bool success = pool().send(amount);
            success; // shh: Not checking return value to avoid DoS attack
        } else {
            IERC20 underlying = toppedUpCToken.underlying();
            underlying.safeTransfer(pool(), amount);
        }
    }

    function _untop() internal {

        if(!isToppedUp()) return;
        _untop(toppedUpAmount, toppedUpAmount);
    }

    function _untopBeforeRepay(ICToken cToken, uint256 repayAmount) internal returns (uint256 amtToRepayOnCompound) {

        if(toppedUpAmount > 0 && cToken == toppedUpCToken) {
            uint256 amtToUntopFromB = repayAmount >= toppedUpAmount ? toppedUpAmount : repayAmount;
            _untop(toppedUpAmount, sub_(toppedUpAmount, amtToUntopFromB));
            amtToRepayOnCompound = sub_(repayAmount, amtToUntopFromB);
        } else {
            amtToRepayOnCompound = repayAmount;
        }
    }

    function _doLiquidateBorrow(
        ICToken debtCToken,
        uint256 underlyingAmtToLiquidate,
        uint256 amtToDeductFromTopup,
        ICToken collCToken
    )
        internal
        onlyPool
        returns (uint256)
    {

        address payable poolContract = pool();

        bool partiallyLiquidated = isPartiallyLiquidated();
        require(isToppedUp() || partiallyLiquidated, "cant-perform-liquidateBorrow");

        if(partiallyLiquidated) {
            require(debtCToken == liquidationCToken, "debtCToken!=liquidationCToken");
        } else {
            require(debtCToken == toppedUpCToken, "debtCToken!=toppedUpCToken");
            liquidationCToken = debtCToken;
        }

        if(!partiallyLiquidated) {
            remainingLiquidationAmount = getMaxLiquidationAmount(debtCToken);
        }

        require(underlyingAmtToLiquidate <= remainingLiquidationAmount, "amountToLiquidate-too-big");

        require(underlyingAmtToLiquidate >= amtToDeductFromTopup, "amtToDeductFromTopup>underlyingAmtToLiquidate");
        uint256 amtToRepayOnCompound = sub_(underlyingAmtToLiquidate, amtToDeductFromTopup);
        
        if(amtToRepayOnCompound > 0) {
            bool isCEtherDebt = _isCEther(debtCToken);
            if(isCEtherDebt) {
                require(msg.value == amtToRepayOnCompound, "insuffecient-ETH-sent");
                ICEther cEther = ICEther(registry.cEther());
                cEther.repayBorrow.value(amtToRepayOnCompound)();
            } else {
                IERC20 underlying = toppedUpCToken.underlying();
                underlying.safeTransferFrom(poolContract, address(this), amtToRepayOnCompound);
                underlying.safeApprove(address(debtCToken), amtToRepayOnCompound);
                require(ICErc20(address(debtCToken)).repayBorrow(amtToRepayOnCompound) == 0, "repayBorrow-fail");
            }
        }

        require(toppedUpAmount >= amtToDeductFromTopup, "amtToDeductFromTopup>toppedUpAmount");
        toppedUpAmount = sub_(toppedUpAmount, amtToDeductFromTopup);

        remainingLiquidationAmount = sub_(remainingLiquidationAmount, underlyingAmtToLiquidate);

        IComptroller comptroller = IComptroller(registry.comptroller());
        (uint err, uint seizeTokens) = comptroller.liquidateCalculateSeizeTokens(
            address(debtCToken),
            address(collCToken),
            underlyingAmtToLiquidate
        );
        require(err == 0, "err-liquidateCalculateSeizeTokens");

        require(collCToken.transfer(poolContract, seizeTokens), "collCToken-xfr-fail");

        return seizeTokens;
    }

    function getMaxLiquidationAmount(ICToken debtCToken) public returns (uint256) {

        if(isPartiallyLiquidated()) return remainingLiquidationAmount;

        uint256 avatarDebt = debtCToken.borrowBalanceCurrent(address(this));
        uint256 totalDebt = add_(avatarDebt, toppedUpAmount);
        IComptroller comptroller = IComptroller(registry.comptroller());
        return mulTrucate(comptroller.closeFactorMantissa(), totalDebt);
    }

    function splitAmountToLiquidate(
        uint256 underlyingAmtToLiquidate,
        uint256 maxLiquidationAmount
    )
        public view returns (uint256 amtToDeductFromTopup, uint256 amtToRepayOnCompound)
    {

        (MathError mErr, Exp memory result) = mulScalar(Exp({mantissa: underlyingAmtToLiquidate}), expScale);
        require(mErr == MathError.NO_ERROR, "underlyingAmtToLiqScalar-fail");
        uint underlyingAmtToLiqScalar = result.mantissa;

        uint256 percentInScale = div_(underlyingAmtToLiqScalar, maxLiquidationAmount);

        amtToDeductFromTopup = mulTrucate(toppedUpAmount, percentInScale);

        amtToRepayOnCompound = sub_(underlyingAmtToLiquidate, amtToDeductFromTopup);
    }

    function calcAmountToLiquidate(
        ICToken debtCToken,
        uint256 underlyingAmtToLiquidate
    )
        external returns (uint256 amtToDeductFromTopup, uint256 amtToRepayOnCompound)
    {

        uint256 amountToLiquidate = remainingLiquidationAmount;
        if(! isPartiallyLiquidated()) {
            amountToLiquidate = getMaxLiquidationAmount(debtCToken);
        }
        (amtToDeductFromTopup, amtToRepayOnCompound) = splitAmountToLiquidate(underlyingAmtToLiquidate, amountToLiquidate);
    }

    function quitB() external onlyAvatarOwner() {

        quit = true;
        _hardReevaluate();
    }
}


pragma solidity 0.5.16;

interface IBToken {

    function cToken() external view returns (address);

    function borrowBalanceCurrent(address account) external returns (uint);

    function balanceOfUnderlying(address owner) external returns (uint);

}


pragma solidity 0.5.16;






contract AbsComptroller is AbsAvatarBase {


    function enterMarket(address bToken) external onlyBComptroller returns (uint256) {

        address cToken = IBToken(bToken).cToken();
        return _enterMarket(cToken);
    }

    function _enterMarket(address cToken) internal postPoolOp(false) returns (uint256) {

        address[] memory cTokens = new address[](1);
        cTokens[0] = cToken;
        return _enterMarkets(cTokens)[0];
    }

    function enterMarkets(address[] calldata bTokens) external onlyBComptroller returns (uint256[] memory) {

        address[] memory cTokens = new address[](bTokens.length);
        for(uint256 i = 0; i < bTokens.length; i++) {
            cTokens[i] = IBToken(bTokens[i]).cToken();
        }
        return _enterMarkets(cTokens);
    }

    function _enterMarkets(address[] memory cTokens) internal postPoolOp(false) returns (uint256[] memory) {

        IComptroller comptroller = IComptroller(registry.comptroller());
        uint256[] memory result = comptroller.enterMarkets(cTokens);
        for(uint256 i = 0; i < result.length; i++) {
            require(result[i] == 0, "enter-markets-fail");
        }
        return result;
    }

    function exitMarket(IBToken bToken) external onlyBComptroller postPoolOp(true) returns (uint256) {

        address cToken = bToken.cToken();
        IComptroller comptroller = IComptroller(registry.comptroller());
        uint result = comptroller.exitMarket(cToken);
        _disableCToken(cToken);
        return result;
    }

    function _disableCToken(address cToken) internal {

        ICToken(cToken).underlying().safeApprove(cToken, 0);
    }

    function claimComp() external onlyBComptroller {

        IComptroller comptroller = IComptroller(registry.comptroller());
        comptroller.claimComp(address(this));
        transferCOMP();
    }

    function claimComp(address[] calldata bTokens) external onlyBComptroller {

        address[] memory cTokens = new address[](bTokens.length);
        for(uint256 i = 0; i < bTokens.length; i++) {
            cTokens[i] = IBToken(bTokens[i]).cToken();
        }
        IComptroller comptroller = IComptroller(registry.comptroller());
        comptroller.claimComp(address(this), cTokens);
        transferCOMP();
    }

    function claimComp(
        address[] calldata bTokens,
        bool borrowers,
        bool suppliers
    )
        external
        onlyBComptroller
    {

        address[] memory cTokens = new address[](bTokens.length);
        for(uint256 i = 0; i < bTokens.length; i++) {
            cTokens[i] = IBToken(bTokens[i]).cToken();
        }

        address[] memory holders = new address[](1);
        holders[0] = address(this);
        IComptroller comptroller = IComptroller(registry.comptroller());
        comptroller.claimComp(holders, cTokens, borrowers, suppliers);

        transferCOMP();
    }

    function transferCOMP() public {

        address owner = registry.ownerOf(address(this));
        IERC20 comp = IERC20(registry.comp());
        comp.safeTransfer(owner, comp.balanceOf(address(this)));
    }

    function getAccountLiquidity(address oracle) external view returns (uint err, uint liquidity, uint shortFall) {

        return _getAccountLiquidity(oracle);
    }

    function getAccountLiquidity() external view returns (uint err, uint liquidity, uint shortFall) {

        IComptroller comptroller = IComptroller(registry.comptroller());
        return _getAccountLiquidity(comptroller.oracle());
    }

    function _getAccountLiquidity(address oracle) internal view returns (uint err, uint liquidity, uint shortFall) {

        IComptroller comptroller = IComptroller(registry.comptroller());
        (err, liquidity, shortFall) = comptroller.getAccountLiquidity(address(this));
        if(!isToppedUp()) {
            return (err, liquidity, shortFall);
        }
        require(err == 0, "Err-in-account-liquidity");

        uint256 price = IPriceOracle(oracle).getUnderlyingPrice(toppedUpCToken);
        uint256 toppedUpAmtInUSD = mulTrucate(toppedUpAmount, price);

        if(liquidity == toppedUpAmtInUSD) return(0, 0, 0);

        if(shortFall == 0 && liquidity > 0) {
            if(liquidity > toppedUpAmtInUSD) {
                liquidity = sub_(liquidity, toppedUpAmtInUSD);
            } else {
                shortFall = sub_(toppedUpAmtInUSD, liquidity);
                liquidity = 0;
            }
        } else {
            shortFall = add_(shortFall, toppedUpAmtInUSD);
        }
    }
}


pragma solidity 0.5.16;

contract IAvatarERC20 {

    function transfer(address cToken, address dst, uint256 amount) external returns (bool);

    function transferFrom(address cToken, address src, address dst, uint256 amount) external returns (bool);

    function approve(address cToken, address spender, uint256 amount) public returns (bool);

}

contract IAvatar is IAvatarERC20 {

    function initialize(address _registry, address comp, address compVoter) external;

    function quit() external returns (bool);

    function canUntop() public returns (bool);

    function toppedUpCToken() external returns (address);

    function toppedUpAmount() external returns (uint256);

    function redeem(address cToken, uint256 redeemTokens, address payable userOrDelegatee) external returns (uint256);

    function redeemUnderlying(address cToken, uint256 redeemAmount, address payable userOrDelegatee) external returns (uint256);

    function borrow(address cToken, uint256 borrowAmount, address payable userOrDelegatee) external returns (uint256);

    function borrowBalanceCurrent(address cToken) external returns (uint256);

    function collectCToken(address cToken, address from, uint256 cTokenAmt) public;

    function liquidateBorrow(uint repayAmount, address cTokenCollateral) external payable returns (uint256);


    function enterMarket(address cToken) external returns (uint256);

    function enterMarkets(address[] calldata cTokens) external returns (uint256[] memory);

    function exitMarket(address cToken) external returns (uint256);

    function claimComp() external;

    function claimComp(address[] calldata bTokens) external;

    function claimComp(address[] calldata bTokens, bool borrowers, bool suppliers) external;

    function getAccountLiquidity() external view returns (uint err, uint liquidity, uint shortFall);

}

contract IAvatarCEther is IAvatar {

    function mint() external payable;

    function repayBorrow() external payable;

    function repayBorrowBehalf(address borrower) external payable;

}

contract IAvatarCErc20 is IAvatar {

    function mint(address cToken, uint256 mintAmount) external returns (uint256);

    function repayBorrow(address cToken, uint256 repayAmount) external returns (uint256);

    function repayBorrowBehalf(address cToken, address borrower, uint256 repayAmount) external returns (uint256);

}

contract ICushion {

    function liquidateBorrow(uint256 underlyingAmtToLiquidate, uint256 amtToDeductFromTopup, address cTokenCollateral) external payable returns (uint256);    

    function canLiquidate() external returns (bool);

    function untop(uint amount) external;

    function toppedUpAmount() external returns (uint);

    function remainingLiquidationAmount() external returns(uint);

    function getMaxLiquidationAmount(address debtCToken) public returns (uint256);

}

contract ICushionCErc20 is ICushion {

    function topup(address cToken, uint256 topupAmount) external;

}

contract ICushionCEther is ICushion {

    function topup() external payable;

}


pragma solidity 0.5.16;

interface IBComptroller {

    function isCToken(address cToken) external view returns (bool);

    function isBToken(address bToken) external view returns (bool);

    function c2b(address cToken) external view returns (address);

    function b2c(address bToken) external view returns (address);

}


pragma solidity 0.5.16;







contract AbsCToken is AbsAvatarBase {


    modifier onlyBToken() {

        _allowOnlyBToken();
        _;
    }

    function _allowOnlyBToken() internal view {

        require(isValidBToken(msg.sender), "only-BToken-authorized");
    }

    function isValidBToken(address bToken) internal view returns (bool) {

        IBComptroller bComptroller = IBComptroller(registry.bComptroller());
        return bComptroller.isBToken(bToken);
    }

    function borrowBalanceCurrent(ICToken cToken) public onlyBToken returns (uint256) {

        uint256 borrowBalanceCurr = cToken.borrowBalanceCurrent(address(this));
        if(toppedUpCToken == cToken) return add_(borrowBalanceCurr, toppedUpAmount);
        return borrowBalanceCurr;
    }

    function _toUnderlying(ICToken cToken, uint256 redeemTokens) internal returns (uint256) {

        uint256 exchangeRate = cToken.exchangeRateCurrent();
        return mulTrucate(redeemTokens, exchangeRate);
    }

    function mint() public payable onlyBToken postPoolOp(false) {

        ICEther cEther = ICEther(registry.cEther());
        cEther.mint.value(msg.value)(); // fails on compound in case of err
        if(! quit) _score().updateCollScore(address(this), address(cEther), toInt256(msg.value));
    }

    function repayBorrow()
        external
        payable
        onlyBToken
        postPoolOp(false)
    {

        ICEther cEther = ICEther(registry.cEther());
        uint256 amtToRepayOnCompound = _untopBeforeRepay(cEther, msg.value);
        if(amtToRepayOnCompound > 0) cEther.repayBorrow.value(amtToRepayOnCompound)(); // fails on compound in case of err
        if(! quit) _score().updateDebtScore(address(this), address(cEther), -toInt256(msg.value));
    }

    function mint(ICErc20 cToken, uint256 mintAmount) public onlyBToken postPoolOp(false) returns (uint256) {

        IERC20 underlying = cToken.underlying();
        underlying.safeApprove(address(cToken), mintAmount);
        uint result = cToken.mint(mintAmount);
        require(result == 0, "mint-fail");
        if(! quit) _score().updateCollScore(address(this), address(cToken), toInt256(mintAmount));
        return result;
    }

    function repayBorrow(ICErc20 cToken, uint256 repayAmount)
        external
        onlyBToken
        postPoolOp(false)
        returns (uint256)
    {

        uint256 amtToRepayOnCompound = _untopBeforeRepay(cToken, repayAmount);
        uint256 result = 0;
        if(amtToRepayOnCompound > 0) {
            IERC20 underlying = cToken.underlying();
            underlying.safeApprove(address(cToken), amtToRepayOnCompound);
            result = cToken.repayBorrow(amtToRepayOnCompound);
            require(result == 0, "repayBorrow-fail");
            if(! quit) _score().updateDebtScore(address(this), address(cToken), -toInt256(repayAmount));
        }
        return result; // in case of err, tx fails at BToken
    }

    function liquidateBorrow(
        uint256 underlyingAmtToLiquidateDebt,
        uint256 amtToDeductFromTopup,
        ICToken cTokenColl
    ) external payable returns (uint256) {

        require(canLiquidate(), "cant-liquidate");

        ICToken cTokenDebt = toppedUpCToken;
        uint256 seizedCTokensColl = _doLiquidateBorrow(cTokenDebt, underlyingAmtToLiquidateDebt, amtToDeductFromTopup, cTokenColl);
        uint256 underlyingSeizedTokensColl = _toUnderlying(cTokenColl, seizedCTokensColl);
        if(! quit) {
            IScore score = _score();
            score.updateCollScore(address(this), address(cTokenColl), -toInt256(underlyingSeizedTokensColl));
            score.updateDebtScore(address(this), address(cTokenDebt), -toInt256(underlyingAmtToLiquidateDebt));
        }
        return 0;
    }

    function redeem(
        ICToken cToken,
        uint256 redeemTokens,
        address payable userOrDelegatee
    ) external onlyBToken postPoolOp(true) returns (uint256) {

        uint256 result = cToken.redeem(redeemTokens);
        require(result == 0, "redeem-fail");

        uint256 underlyingRedeemAmount = _toUnderlying(cToken, redeemTokens);
        if(! quit) _score().updateCollScore(address(this), address(cToken), -toInt256(underlyingRedeemAmount));

        if(_isCEther(cToken)) {
            userOrDelegatee.transfer(address(this).balance);
        } else {
            IERC20 underlying = cToken.underlying();
            uint256 redeemedAmount = underlying.balanceOf(address(this));
            underlying.safeTransfer(userOrDelegatee, redeemedAmount);
        }
        return result;
    }

    function redeemUnderlying(
        ICToken cToken,
        uint256 redeemAmount,
        address payable userOrDelegatee
    ) external onlyBToken postPoolOp(true) returns (uint256) {

        uint256 result = cToken.redeemUnderlying(redeemAmount);
        require(result == 0, "redeemUnderlying-fail");

        if(! quit) _score().updateCollScore(address(this), address(cToken), -toInt256(redeemAmount));

        if(_isCEther(cToken)) {
            userOrDelegatee.transfer(redeemAmount);
        } else {
            IERC20 underlying = cToken.underlying();
            underlying.safeTransfer(userOrDelegatee, redeemAmount);
        }
        return result;
    }

    function borrow(
        ICToken cToken,
        uint256 borrowAmount,
        address payable userOrDelegatee
    ) external onlyBToken postPoolOp(true) returns (uint256) {

        uint256 result = cToken.borrow(borrowAmount);
        require(result == 0, "borrow-fail");

        if(! quit) _score().updateDebtScore(address(this), address(cToken), toInt256(borrowAmount));

        if(_isCEther(cToken)) {
            userOrDelegatee.transfer(borrowAmount);
        } else {
            IERC20 underlying = cToken.underlying();
            underlying.safeTransfer(userOrDelegatee, borrowAmount);
        }
        return result;
    }

    function transfer(ICToken cToken, address dst, uint256 amount) public onlyBToken postPoolOp(true) returns (bool) {

        address dstAvatar = registry.getAvatar(dst);
        bool result = cToken.transfer(dstAvatar, amount);
        require(result, "transfer-fail");

        uint256 underlyingRedeemAmount = _toUnderlying(cToken, amount);

        IScore score = _score();
        if(! quit) score.updateCollScore(address(this), address(cToken), -toInt256(underlyingRedeemAmount));
        if(! IAvatar(dstAvatar).quit()) score.updateCollScore(dstAvatar, address(cToken), toInt256(underlyingRedeemAmount));

        return result;
    }

    function transferFrom(ICToken cToken, address src, address dst, uint256 amount) public onlyBToken postPoolOp(true) returns (bool) {

        address srcAvatar = registry.getAvatar(src);
        address dstAvatar = registry.getAvatar(dst);

        bool result = cToken.transferFrom(srcAvatar, dstAvatar, amount);
        require(result, "transferFrom-fail");

        require(IAvatar(srcAvatar).canUntop(), "insuffecient-fund-at-src");
        uint256 underlyingRedeemAmount = _toUnderlying(cToken, amount);

        IScore score = _score();
        if(! IAvatar(srcAvatar).quit()) score.updateCollScore(srcAvatar, address(cToken), -toInt256(underlyingRedeemAmount));
        if(! IAvatar(dstAvatar).quit()) score.updateCollScore(dstAvatar, address(cToken), toInt256(underlyingRedeemAmount));

        return result;
    }

    function approve(ICToken cToken, address spender, uint256 amount) public onlyBToken returns (bool) {

        address spenderAvatar = registry.getAvatar(spender);
        return cToken.approve(spenderAvatar, amount);
    }

    function collectCToken(ICToken cToken, address from, uint256 cTokenAmt) public postPoolOp(false) {

        require(registry.ownerOf(from) == address(0), "from-is-an-avatar");
        require(cToken.transferFrom(from, address(this), cTokenAmt), "transferFrom-fail");
        uint256 underlyingAmt = _toUnderlying(cToken, cTokenAmt);
        if(! quit) _score().updateCollScore(address(this), address(cToken), toInt256(underlyingAmt));
    }


    function () external payable {
    }
}


pragma solidity 0.5.16;

interface IComp {

    function delegate(address delegatee) external;

}


pragma solidity 0.5.16;





contract ProxyStorage {

    address internal masterCopy;
}

contract Avatar is ProxyStorage, AbsComptroller, AbsCToken {



    function initialize(address _registry, address /*comp*/, address /*compVoter*/) external {

        _initAvatarBase(_registry);
    }

    function mint() public payable {

        ICEther cEther = ICEther(registry.cEther());
        require(_enterMarket(address(cEther)) == 0, "enterMarket-fail");
        super.mint();
    }

    function mint(ICErc20 cToken, uint256 mintAmount) public returns (uint256) {

        require(_enterMarket(address(cToken)) == 0, "enterMarket-fail");
        uint256 result = super.mint(cToken, mintAmount);
        return result;
    }

    function emergencyCall(address payable target, bytes calldata data) external payable onlyAvatarOwner {

        uint first4Bytes = uint(uint8(data[0])) << 24 | uint(uint8(data[1])) << 16 | uint(uint8(data[2])) << 8 | uint(uint8(data[3])) << 0;
        bytes4 functionSig = bytes4(uint32(first4Bytes));

        require(quit || registry.whitelistedAvatarCalls(target, functionSig), "not-listed");
        (bool succ, bytes memory err) = target.call.value(msg.value)(data);

        require(succ, string(err));
    }
}