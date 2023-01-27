


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









contract AbsBToken is Exponential {

    using SafeERC20 for IERC20;

    IRegistry public registry;
    address public cToken;

    modifier onlyDelegatee(address _avatar) {

        require(registry.delegate(_avatar, msg.sender), "BToken: delegatee-not-authorized");
        _;
    }

    constructor(address _registry, address _cToken) internal {
        registry = IRegistry(_registry);
        cToken = _cToken;
    }

    function _myAvatar() internal returns (address) {

        return registry.getAvatar(msg.sender);
    }

    function borrowBalanceCurrent(address account) external returns (uint256) {

        address _avatar = registry.getAvatar(account);
        return IAvatar(_avatar).borrowBalanceCurrent(cToken);
    }

    function redeem(uint256 redeemTokens) external returns (uint256) {

        return _redeem(_myAvatar(), redeemTokens);
    }

    function redeemOnAvatar(address _avatar, uint256 redeemTokens) external onlyDelegatee(_avatar) returns (uint256) {

        return _redeem(_avatar, redeemTokens);
    }

    function _redeem(address _avatar, uint256 redeemTokens) internal returns (uint256) {

        uint256 result = IAvatar(_avatar).redeem(cToken, redeemTokens, msg.sender);
        require(result == 0, "BToken: redeem-failed");
        return result;
    }

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256) {

        return _redeemUnderlying(_myAvatar(), redeemAmount);
    }

    function redeemUnderlyingOnAvatar(address _avatar, uint256 redeemAmount) external onlyDelegatee(_avatar) returns (uint256) {

        return _redeemUnderlying(_avatar, redeemAmount);
    }

    function _redeemUnderlying(address _avatar, uint256 redeemAmount) internal returns (uint256) {

        uint256 result = IAvatar(_avatar).redeemUnderlying(cToken, redeemAmount, msg.sender);
        require(result == 0, "BToken: redeemUnderlying-failed");
        return result;
    }

    function borrow(uint256 borrowAmount) external returns (uint256) {

        return _borrow(_myAvatar(), borrowAmount);
    }

    function borrowOnAvatar(address _avatar, uint256 borrowAmount) external onlyDelegatee(_avatar) returns (uint256) {

        return _borrow(_avatar, borrowAmount);
    }

    function _borrow(address _avatar, uint256 borrowAmount) internal returns (uint256) {

        uint256 result = IAvatar(_avatar).borrow(cToken, borrowAmount, msg.sender);
        require(result == 0, "BToken: borrow-failed");
        return result;
    }

    function exchangeRateCurrent() public returns (uint256) {

        return ICToken(cToken).exchangeRateCurrent();
    }

    function exchangeRateStored() public view returns (uint) {

        return ICToken(cToken).exchangeRateStored();
    }

    function transfer(address dst, uint256 amount) external returns (bool) {

        return _transfer(_myAvatar(), dst, amount);
    }

    function transferOnAvatar(address _avatar, address dst, uint256 amount) external onlyDelegatee(_avatar) returns (bool) {

        return _transfer(_avatar, dst, amount);
    }

    function _transfer(address _avatar, address dst, uint256 amount) internal returns (bool) {

        bool result = IAvatar(_avatar).transfer(cToken, dst, amount);
        require(result, "BToken: transfer-failed");
        return result;
    }

    function transferFrom(address src, address dst, uint256 amount) external returns (bool) {

        return _transferFrom(_myAvatar(), src, dst, amount);
    }

    function transferFromOnAvatar(address _avatar, address src, address dst, uint256 amount) external onlyDelegatee(_avatar) returns (bool) {

        return _transferFrom(_avatar, src, dst, amount);
    }

    function _transferFrom(address _avatar, address src, address dst, uint256 amount) internal returns (bool) {

        bool result = IAvatar(_avatar).transferFrom(cToken, src, dst, amount);
        require(result, "BToken: transferFrom-failed");
        return result;
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        return IAvatar(_myAvatar()).approve(cToken, spender, amount);
    }

    function approveOnAvatar(address _avatar, address spender, uint256 amount) public onlyDelegatee(_avatar) returns (bool) {

        return IAvatar(_avatar).approve(cToken, spender, amount);
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        address spenderAvatar = registry.avatarOf(spender);
        if(spenderAvatar == address(0)) return 0;
        return ICToken(cToken).allowance(registry.avatarOf(owner), spenderAvatar);
    }

    function balanceOf(address owner) public view returns (uint256) {

        address avatar = registry.avatarOf(owner);
        if(avatar == address(0)) return 0;
        return ICToken(cToken).balanceOf(avatar);
    }

    function balanceOfUnderlying(address owner) external returns (uint) {

        address avatar = registry.avatarOf(owner);
        if(avatar == address(0)) return 0;
        return ICToken(cToken).balanceOfUnderlying(avatar);
    }

    function name() public view returns (string memory) {

        return ICToken(cToken).name();
    }

    function symbol() public view returns (string memory) {

        return ICToken(cToken).symbol();
    }

    function decimals() public view returns (uint8) {

        return ICToken(cToken).decimals();
    }

    function totalSupply() public view returns (uint256) {

        return ICToken(cToken).totalSupply();
    }
}


pragma solidity 0.5.16;





contract BErc20 is AbsBToken {


    IERC20 public underlying;

    constructor(
        address _registry,
        address _cToken
    ) public AbsBToken(_registry, _cToken) {
        underlying = ICToken(cToken).underlying();
    }

    function mint(uint256 mintAmount) external returns (uint256) {

        return _mint(_myAvatar(), mintAmount);
    }

    function mintOnAvatar(address _avatar, uint256 mintAmount) external onlyDelegatee(_avatar) returns (uint256) {

        return _mint(_avatar, mintAmount);
    }

    function _mint(address _avatar, uint256 mintAmount) internal returns (uint256) {

        underlying.safeTransferFrom(msg.sender, _avatar, mintAmount);
        uint256 result = IAvatarCErc20(_avatar).mint(cToken, mintAmount);
        require(result == 0, "BErc20: mint-failed");
        return result;
    }

    function repayBorrow(uint256 repayAmount) external returns (uint256) {

        return _repayBorrow(_myAvatar(), repayAmount);
    }

    function repayBorrowOnAvatar(address _avatar, uint256 repayAmount) external onlyDelegatee(_avatar) returns (uint256) {

        return _repayBorrow(_avatar, repayAmount);
    }

    function _repayBorrow(address _avatar, uint256 repayAmount) internal returns (uint256) {

        uint256 actualRepayAmount = repayAmount;
        if(repayAmount == uint256(-1)) {
            actualRepayAmount = IAvatarCErc20(_avatar).borrowBalanceCurrent(cToken);
        }
        underlying.safeTransferFrom(msg.sender, _avatar, actualRepayAmount);
        uint256 result = IAvatarCErc20(_avatar).repayBorrow(cToken, actualRepayAmount);
        require(result == 0, "BErc20: repayBorrow-failed");
        return result;
    }
}


pragma solidity 0.5.16;



contract BEther is AbsBToken {


    constructor(
        address _registry,
        address _cToken
    ) public AbsBToken(_registry, _cToken) {}

    function _myAvatarCEther() internal returns (IAvatarCEther) {

        return IAvatarCEther(address(_myAvatar()));
    }

    function mint() external payable {

        _myAvatarCEther().mint.value(msg.value)();
    }

    function mintOnAvatar(address _avatar) external onlyDelegatee(_avatar) payable {

        IAvatarCEther(_avatar).mint.value(msg.value)();
    }

    function repayBorrow() external payable {

        _myAvatarCEther().repayBorrow.value(msg.value)();
    }

    function repayBorrowOnAvatar(address _avatar) external onlyDelegatee(_avatar) payable {

        IAvatarCEther(_avatar).repayBorrow.value(msg.value)();
    }
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







contract BComptroller {


    IComptroller public comptroller;

    IRegistry public registry;

    mapping(address => address) public c2b;

    mapping(address => address) public b2c;

    event NewBToken(address indexed cToken, address bToken);

    modifier onlyDelegatee(IAvatar _avatar) {

        require(registry.delegate(address(_avatar), msg.sender), "BComptroller: delegatee-not-authorized");
        _;
    }

    constructor(address _comptroller) public {
        comptroller = IComptroller(_comptroller);
    }

    function setRegistry(address _registry) public {

        require(address(registry) == address(0), "BComptroller: registry-already-set");
        registry = IRegistry(_registry);
    }

    function newBToken(address cToken) external returns (address) {

        require(c2b[cToken] == address(0), "BComptroller: BToken-already-exists");
        (bool isListed,) = comptroller.markets(cToken);
        require(isListed, "BComptroller: cToken-not-listed-on-compound");

        bool is_cETH = cToken == registry.cEther();
        address bToken;
        if(is_cETH) {
            bToken = address(new BEther(address(registry), cToken));
        } else {
            bToken = address(new BErc20(address(registry), cToken));
        }

        c2b[cToken] = bToken;
        b2c[bToken] = cToken;
        emit NewBToken(cToken, bToken);
        return bToken;
    }

    function isBToken(address bToken) public view returns (bool) {

        return b2c[bToken] != address(0);
    }

    function enterMarket(address bToken) external returns (uint256) {

        IAvatar avatar = IAvatar(registry.getAvatar(msg.sender));
        return _enterMarket(avatar, bToken);
    }

    function enterMarketOnAvatar(IAvatar avatar, address bToken) external onlyDelegatee(avatar) returns (uint256) {

        return _enterMarket(avatar, bToken);
    }

    function _enterMarket(IAvatar avatar, address bToken) internal returns (uint256) {

        require(b2c[bToken] != address(0), "BComptroller: CToken-not-exist-for-bToken");
        return avatar.enterMarket(bToken);
    }

    function enterMarkets(address[] calldata bTokens) external returns (uint256[] memory) {

        IAvatar avatar = IAvatar(registry.getAvatar(msg.sender));
        return _enterMarkets(avatar, bTokens);
    }

    function enterMarketsOnAvatar(IAvatar avatar, address[] calldata bTokens) external onlyDelegatee(avatar) returns (uint256[] memory) {

        return _enterMarkets(avatar, bTokens);
    }

    function _enterMarkets(IAvatar avatar, address[] memory bTokens) internal returns (uint256[] memory) {

        for(uint i = 0; i < bTokens.length; i++) {
            require(b2c[bTokens[i]] != address(0), "BComptroller: CToken-not-exist-for-bToken");
        }
        return avatar.enterMarkets(bTokens);
    }

    function exitMarket(address bToken) external returns (uint256) {

        IAvatar avatar = IAvatar(registry.getAvatar(msg.sender));
        return avatar.exitMarket(bToken);
    }

    function exitMarketOnAvatar(IAvatar avatar, address bToken) external onlyDelegatee(avatar) returns (uint256) {

        return avatar.exitMarket(bToken);
    }

    function getAccountLiquidity(address account) external view returns (uint err, uint liquidity, uint shortFall) {

        IAvatar avatar = IAvatar(registry.avatarOf(account));

        if(avatar == IAvatar(0)) return (0, 0, 0);
        
        return avatar.getAccountLiquidity();
    }

    function claimComp(address holder) external {

        IAvatar avatar = IAvatar(registry.getAvatar(holder));
        avatar.claimComp();
    }

    function claimComp(address holder, address[] calldata bTokens) external {

        IAvatar avatar = IAvatar(registry.getAvatar(holder));
        avatar.claimComp(bTokens);
    }

    function claimComp(
        address[] calldata holders,
        address[] calldata bTokens,
        bool borrowers,
        bool suppliers
    )
        external
    {

        for(uint256 i = 0; i < holders.length; i++) {
            IAvatar avatar = IAvatar(registry.getAvatar(holders[i]));
            avatar.claimComp(bTokens, borrowers, suppliers);
        }
    }

    function oracle() external view returns (address) {

        return comptroller.oracle();
    }

    function getAllMarkets() external view returns (address[] memory) {

        return comptroller.getAllMarkets();
    }
}