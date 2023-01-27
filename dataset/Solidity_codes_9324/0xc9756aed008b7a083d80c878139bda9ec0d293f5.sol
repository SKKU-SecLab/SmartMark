


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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

interface IBToken {

    function cToken() external view returns (address);

    function borrowBalanceCurrent(address account) external returns (uint);

    function balanceOfUnderlying(address owner) external returns (uint);

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

interface IBComptroller {

    function isCToken(address cToken) external view returns (bool);

    function isBToken(address bToken) external view returns (bool);

    function c2b(address cToken) external view returns (address);

    function b2c(address bToken) external view returns (address);

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


pragma solidity 0.5.16;

contract Pool is Exponential, Ownable {

    using SafeERC20 for IERC20;
    address internal constant ETH_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    IComptroller public comptroller;
    IBComptroller public bComptroller;
    IRegistry public registry;
    address public jar;
    address public cEther;
    address[] public members;
    uint public shareNumerator;
    uint public shareDenominator;
    mapping(address => mapping(address => uint)) public balance;
    mapping(address => mapping(address => uint)) public topupBalance;
    mapping(address => TopupInfo) public topped;

    mapping(address => uint) public minSharingThreshold; // debt above this size will be shared
    uint public minTopupBps = 250; // 2.5%
    uint public holdingTime = 5 hours; // after 5 hours, someone else can topup instead
    uint public selectionDuration = 60 minutes;  // member selection duration for round robin, default 60 mins

    struct MemberTopupInfo {
        uint expire;        // after expire time, other member can topup. relevant only if small
        uint amountTopped;  // amount of underlying tokens toppedUp
        uint amountLiquidated; // how much was already liquidated
    }

    struct TopupInfo {
        mapping(address => MemberTopupInfo) memberInfo; // info per member
        uint debtToLiquidatePerMember; // total debt avail to liquidate
        address cToken;          // underlying debt cToken address
    }

    function getMemberTopupInfo(
        address user,
        address member
    )
        public
        view
        returns (
            uint expire,
            uint amountTopped,
            uint amountLiquidated
        )
    {

        address avatar = registry.avatarOf(user);
        MemberTopupInfo memory memberInfo = topped[avatar].memberInfo[member];
        expire = memberInfo.expire;
        amountTopped = memberInfo.amountTopped;
        amountLiquidated = memberInfo.amountLiquidated;
    }

    function getDebtTopupInfo(address user, address bTokenDebt) public /* view */ returns(uint minTopup, uint maxTopup, bool isSmall) {

        uint debt = IBToken(bTokenDebt).borrowBalanceCurrent(user);
        minTopup = mul_(debt, minTopupBps) / 10000;
        maxTopup = debt / members.length;
        isSmall = debt < minSharingThreshold[bTokenDebt];
    }

    function untop(address user, uint underlyingAmount) public onlyMember {

        _untop(msg.sender, user, underlyingAmount);
    }

    function _untopOnBehalf(address member, address user, uint underlyingAmount) internal {

        _untop(member, user, underlyingAmount);
    }

    function _untop(address member, address user, uint underlyingAmount) internal {

        require(underlyingAmount > 0, "Pool: amount-is-zero");
        address avatar = registry.avatarOf(user);
        TopupInfo storage info = topped[avatar];

        address bToken = bComptroller.c2b(info.cToken);

        MemberTopupInfo storage memberInfo = info.memberInfo[member];
        require(memberInfo.amountTopped >= underlyingAmount, "Pool: amount-too-big");
        require(ICushion(avatar).remainingLiquidationAmount() == 0, "Pool: cannot-untop-in-liquidation");

        (uint minTopup,,) = getDebtTopupInfo(user, bToken);

        require(
            memberInfo.amountTopped == underlyingAmount ||
            sub_(memberInfo.amountTopped, underlyingAmount) >= minTopup,
            "Pool: invalid-amount"
        );

        if(ICushion(avatar).toppedUpAmount() > 0) ICushion(avatar).untop(underlyingAmount);
        address underlying = _getUnderlying(info.cToken);
        balance[member][underlying] = add_(balance[member][underlying], underlyingAmount);
        topupBalance[member][underlying] = sub_(topupBalance[member][underlying], underlyingAmount);

        memberInfo.amountTopped = 0;
        memberInfo.expire = 0;
    }

    function smallTopupWinner(address avatar) public view returns(address) {

        uint chosen = uint(keccak256(abi.encodePacked(avatar, now / selectionDuration))) % members.length;
        return members[chosen];
    }

    function topup(address user, address bToken, uint amount, bool resetApprove) external onlyMember {

        address avatar = registry.avatarOf(user);
        address cToken = bComptroller.b2c(bToken);
        (uint minTopup, uint maxTopup, bool small) = getDebtTopupInfo(user, bToken);

        address underlying = _getUnderlying(cToken);
        uint memberBalance = balance[msg.sender][underlying];

        require(memberBalance >= amount, "Pool: topup-insufficient-balance");
        require(ICushion(avatar).remainingLiquidationAmount() == 0, "Pool: cannot-topup-in-liquidation");

        TopupInfo storage info = topped[avatar];
        _untopOnMembers(user, avatar, cToken, small);

        MemberTopupInfo storage memberInfo = info.memberInfo[msg.sender];
        require(add_(amount, memberInfo.amountTopped) >= minTopup, "Pool: topup-amount-small");
        require(add_(amount, memberInfo.amountTopped) <= maxTopup, "Pool: topup-amount-big");

        if(small && memberInfo.expire != 0 && memberInfo.expire <= now) {
            require(smallTopupWinner(avatar) == msg.sender, "Pool: topup-not-your-turn");
        }

        balance[msg.sender][underlying] = sub_(memberBalance, amount);
        topupBalance[msg.sender][underlying] = add_(topupBalance[msg.sender][underlying], amount);

        if(small && memberInfo.expire <= now) {
            memberInfo.expire = add_(now, holdingTime);
        }

        memberInfo.amountTopped = add_(memberInfo.amountTopped, amount);
        memberInfo.amountLiquidated = 0;
        info.debtToLiquidatePerMember = 0;
        info.cToken = cToken;

        if(_isCEther(cToken)) {
            ICushionCEther(avatar).topup.value(amount)();
        } else {
            if(resetApprove) IERC20(underlying).safeApprove(avatar, 0);
            IERC20(underlying).safeApprove(avatar, amount);
            ICushionCErc20(avatar).topup(cToken, amount);
        }
    }

    function _untopOnMembers(address user, address avatar, address cToken, bool small) internal {

        uint realCushion = ICushion(avatar).toppedUpAmount();
        TopupInfo memory info = topped[avatar];
        for(uint i = 0 ; i < members.length ; i++) {
            address member = members[i];
            MemberTopupInfo memory memberInfo = topped[avatar].memberInfo[member];
            uint amount = memberInfo.amountTopped;
            if(amount > 0) {
                if(realCushion == 0) {
                    _untopOnBehalf(member, user, amount);
                    continue;
                }

                require(info.cToken == cToken, "Pool: cToken-miss-match");

                if(member == msg.sender) continue; // skil below check for me(member)
                if(! small) continue; // if big loan, share with it with other members
                require(memberInfo.expire < now, "Pool: other-member-topped");
                _untopOnBehalf(member, user, amount);
            }
        }
    }

    event MemberDeposit(address indexed member, address underlying, uint amount);
    event MemberWithdraw(address indexed member, address underlying, uint amount);
    event MemberToppedUp(address indexed member, address avatar, address cToken, uint amount);
    event MemberUntopped(address indexed member, address avatar);
    event MemberBite(address indexed member, address avatar, address cTokenDebt, address cTokenCollateral, uint underlyingAmtToLiquidate);
    event ProfitParamsChanged(uint numerator, uint denominator);
    event MembersSet(address[] members);
    event SelectionDurationChanged(uint oldDuration, uint newDuration);
    event MinTopupBpsChanged(uint oldMinTopupBps, uint newMinTopupBps);
    event HoldingTimeChanged(uint oldHoldingTime, uint newHoldingTime);
    event MinSharingThresholdChanged(address indexed bToken, uint oldThreshold, uint newThreshold);

    modifier onlyMember() {

        require(_isMember(msg.sender), "Pool: not-member");
        _;
    }

    constructor(address _jar) public {
        jar = _jar;
    }

    function _isMember(address member) internal view returns (bool isMember) {

        for(uint i = 0 ; i < members.length ; i++) {
            if(members[i] == member) {
                isMember = true;
                break;
            }
        }
    }

    function setRegistry(address _registry) external onlyOwner {

        require(address(registry) == address(0), "Pool: registry-already-set");
        registry = IRegistry(_registry);
        comptroller = IComptroller(registry.comptroller());
        bComptroller = IBComptroller(registry.bComptroller());
        cEther = registry.cEther();
    }

    function emergencyExecute(address target, bytes calldata data) external payable onlyOwner {

        (bool succ, bytes memory ret) = target.call.value(msg.value)(data);
        require(succ, string(ret));
    }

    function() external payable {}

    function setMinTopupBps(uint newMinTopupBps) external onlyOwner {

        require(newMinTopupBps >= 0 && newMinTopupBps <= 10000, "Pool: incorrect-minTopupBps");
        uint oldMinTopupBps = minTopupBps;
        minTopupBps = newMinTopupBps;
        emit MinTopupBpsChanged(oldMinTopupBps, newMinTopupBps);
    }

    function setHoldingTime(uint newHoldingTime) external onlyOwner {

        require(newHoldingTime > 0, "Pool: incorrect-holdingTime");
        uint oldHoldingTime = holdingTime;
        holdingTime = newHoldingTime;
        emit HoldingTimeChanged(oldHoldingTime, newHoldingTime);
    }

    function setMinSharingThreshold(address bToken, uint newMinThreshold) external onlyOwner {

        require(newMinThreshold > 0, "Pool: incorrect-minThreshold");
        require(bComptroller.isBToken(bToken), "Pool: not-a-BToken");
        uint oldMinThreshold = minSharingThreshold[bToken];
        minSharingThreshold[bToken] = newMinThreshold;
        emit MinSharingThresholdChanged(bToken, oldMinThreshold, newMinThreshold);
    }

    function setProfitParams(uint numerator, uint denominator) external onlyOwner {

        require(numerator < denominator, "Pool: invalid-profit-params");
        shareNumerator = numerator;
        shareDenominator = denominator;
        emit ProfitParamsChanged(numerator, denominator);
    }

    function setSelectionDuration(uint newDuration) external onlyOwner {

        require(newDuration > 0, "Pool: selection-duration-is-zero");
        uint oldDuration = selectionDuration;
        selectionDuration = newDuration;
        emit SelectionDurationChanged(oldDuration, newDuration);
    }

    function setMembers(address[] calldata newMembersList) external onlyOwner {

        members = newMembersList;
        emit MembersSet(newMembersList);
    }

    function deposit() external payable onlyMember {

        balance[msg.sender][ETH_ADDR] = add_(balance[msg.sender][ETH_ADDR], msg.value);
        emit MemberDeposit(msg.sender, ETH_ADDR, msg.value);
    }

    function deposit(address underlying, uint amount) external onlyMember {

        IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount);
        balance[msg.sender][underlying] = add_(balance[msg.sender][underlying], amount);
        emit MemberDeposit(msg.sender, underlying, amount);
    }

    function withdraw(address underlying, uint amount) external {

        if(_isETH(underlying)) {
            balance[msg.sender][ETH_ADDR] = sub_(balance[msg.sender][ETH_ADDR], amount);
            msg.sender.transfer(amount);
        } else {
            balance[msg.sender][underlying] = sub_(balance[msg.sender][underlying], amount);
            IERC20(underlying).safeTransfer(msg.sender, amount);
        }
        emit MemberWithdraw(msg.sender, underlying, amount);
    }

    function liquidateBorrow(
        address borrower,
        address bTokenCollateral,
        address bTokenDebt,
        uint underlyingAmtToLiquidate
    )
        external onlyMember
    {

        address cTokenCollateral = bComptroller.b2c(bTokenCollateral);
        address cTokenDebt = bComptroller.b2c(bTokenDebt);
        address avatar = registry.avatarOf(borrower);
        TopupInfo storage info = topped[avatar];

        require(info.memberInfo[msg.sender].amountTopped > 0, "Pool: member-didnt-topup");
        uint debtToLiquidatePerMember = info.debtToLiquidatePerMember;

        if(debtToLiquidatePerMember == 0) {
            uint numMembers = 0;
            for(uint i = 0 ; i < members.length ; i++) {
                if(info.memberInfo[members[i]].amountTopped > 0) {
                    numMembers++;
                }
            }
            debtToLiquidatePerMember = ICushion(avatar).getMaxLiquidationAmount(cTokenDebt) / numMembers;
            info.debtToLiquidatePerMember = debtToLiquidatePerMember;
        }

        MemberTopupInfo memory memberInfo = info.memberInfo[msg.sender];

        require(memberInfo.amountTopped > 0, "Pool: member-didnt-topup");
        require(
            add_(memberInfo.amountLiquidated, underlyingAmtToLiquidate) <= debtToLiquidatePerMember,
            "Pool: amount-too-big"
        );

        uint amtToDeductFromTopup = mul_(underlyingAmtToLiquidate, memberInfo.amountTopped) / (
            sub_(debtToLiquidatePerMember, memberInfo.amountLiquidated)
        );

        uint amtToRepayOnCompound = sub_(underlyingAmtToLiquidate, amtToDeductFromTopup);

        address debtUnderlying = _getUnderlying(cTokenDebt);
        require(balance[msg.sender][debtUnderlying] >= amtToRepayOnCompound, "Pool: low-member-balance");

        if(! _isCEther(cTokenDebt)) {
            IERC20(debtUnderlying).safeApprove(avatar, amtToRepayOnCompound);
        }

        require(
            ICushion(avatar).liquidateBorrow.value(debtUnderlying == ETH_ADDR ?
                                                   amtToRepayOnCompound :
                                                   0)(underlyingAmtToLiquidate, amtToDeductFromTopup, cTokenCollateral) == 0,
            "Pool: liquidateBorrow-failed"
        );

        balance[msg.sender][debtUnderlying] = sub_(balance[msg.sender][debtUnderlying],  amtToRepayOnCompound);

        _shareLiquidationProceeds(cTokenCollateral, msg.sender);

        info.memberInfo[msg.sender].amountLiquidated = add_(memberInfo.amountLiquidated, underlyingAmtToLiquidate);
        info.memberInfo[msg.sender].amountTopped = sub_(memberInfo.amountTopped, amtToDeductFromTopup);
        topupBalance[msg.sender][debtUnderlying] = sub_(topupBalance[msg.sender][debtUnderlying], amtToDeductFromTopup);
        if(IAvatar(avatar).toppedUpAmount() == 0) {
            delete topped[avatar]; // this will reset debtToLiquidatePerMember
        }
        emit MemberBite(msg.sender, avatar, cTokenDebt, cTokenCollateral, underlyingAmtToLiquidate);
    }

    function _shareLiquidationProceeds(address cTokenCollateral, address member) internal {

        uint seizedTokens = IERC20(cTokenCollateral).balanceOf(address(this));
        uint memberShare = div_(mul_(seizedTokens, shareNumerator), shareDenominator);
        uint jarShare = sub_(seizedTokens, memberShare);

        IERC20(cTokenCollateral).safeTransfer(member, memberShare);
        IERC20(cTokenCollateral).safeTransfer(jar, jarShare);
    }

    function membersLength() external view returns (uint) {

        return members.length;
    }

    function getMembers() external view returns (address[] memory) {

        return members;
    }

    function _isETH(address addr) internal pure returns (bool) {

        return addr == ETH_ADDR;
    }

    function _isCEther(address addr) internal view returns (bool) {

        return addr == cEther;
    }

    function _getUnderlying(address cToken) internal view returns (address underlying) {

        if(_isCEther(cToken)) {
            underlying = ETH_ADDR;
        } else {
            underlying = address(ICErc20(cToken).underlying());
        }
    }
}