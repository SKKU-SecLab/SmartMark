pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}pragma solidity ^0.6.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}pragma solidity ^0.6.0;

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
}pragma solidity ^0.6.0;

library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// AGPL-3.0-only
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


library FixedPoint {

  using SafeMath for uint256;
  using SignedSafeMath for int256;

  uint256 private constant FP_SCALING_FACTOR = 10**18;

  struct Unsigned {
    uint256 rawValue;
  }

  function fromUnscaledUint(uint256 a) internal pure returns (Unsigned memory) {

    return Unsigned(a.mul(FP_SCALING_FACTOR));
  }

  function isEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

    return a.rawValue == fromUnscaledUint(b).rawValue;
  }

  function isEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

    return a.rawValue == b.rawValue;
  }

  function isGreaterThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

    return a.rawValue > b.rawValue;
  }

  function isGreaterThan(Unsigned memory a, uint256 b) internal pure returns (bool) {

    return a.rawValue > fromUnscaledUint(b).rawValue;
  }

  function isGreaterThan(uint256 a, Unsigned memory b) internal pure returns (bool) {

    return fromUnscaledUint(a).rawValue > b.rawValue;
  }

  function isGreaterThanOrEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

    return a.rawValue >= b.rawValue;
  }

  function isGreaterThanOrEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

    return a.rawValue >= fromUnscaledUint(b).rawValue;
  }

  function isGreaterThanOrEqual(uint256 a, Unsigned memory b) internal pure returns (bool) {

    return fromUnscaledUint(a).rawValue >= b.rawValue;
  }

  function isLessThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

    return a.rawValue < b.rawValue;
  }

  function isLessThan(Unsigned memory a, uint256 b) internal pure returns (bool) {

    return a.rawValue < fromUnscaledUint(b).rawValue;
  }

  function isLessThan(uint256 a, Unsigned memory b) internal pure returns (bool) {

    return fromUnscaledUint(a).rawValue < b.rawValue;
  }

  function isLessThanOrEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

    return a.rawValue <= b.rawValue;
  }

  function isLessThanOrEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

    return a.rawValue <= fromUnscaledUint(b).rawValue;
  }

  function isLessThanOrEqual(uint256 a, Unsigned memory b) internal pure returns (bool) {

    return fromUnscaledUint(a).rawValue <= b.rawValue;
  }

  function min(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

    return a.rawValue < b.rawValue ? a : b;
  }

  function max(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

    return a.rawValue > b.rawValue ? a : b;
  }

  function add(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

    return Unsigned(a.rawValue.add(b.rawValue));
  }

  function add(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

    return add(a, fromUnscaledUint(b));
  }

  function sub(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

    return Unsigned(a.rawValue.sub(b.rawValue));
  }

  function sub(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

    return sub(a, fromUnscaledUint(b));
  }

  function sub(uint256 a, Unsigned memory b) internal pure returns (Unsigned memory) {

    return sub(fromUnscaledUint(a), b);
  }

  function mul(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

    return Unsigned(a.rawValue.mul(b.rawValue) / FP_SCALING_FACTOR);
  }

  function mul(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

    return Unsigned(a.rawValue.mul(b));
  }

  function mulCeil(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

    uint256 mulRaw = a.rawValue.mul(b.rawValue);
    uint256 mulFloor = mulRaw / FP_SCALING_FACTOR;
    uint256 mod = mulRaw.mod(FP_SCALING_FACTOR);
    if (mod != 0) {
      return Unsigned(mulFloor.add(1));
    } else {
      return Unsigned(mulFloor);
    }
  }

  function mulCeil(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

    return Unsigned(a.rawValue.mul(b));
  }

  function div(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

    return Unsigned(a.rawValue.mul(FP_SCALING_FACTOR).div(b.rawValue));
  }

  function div(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

    return Unsigned(a.rawValue.div(b));
  }

  function div(uint256 a, Unsigned memory b) internal pure returns (Unsigned memory) {

    return div(fromUnscaledUint(a), b);
  }

  function divCeil(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

    uint256 aScaled = a.rawValue.mul(FP_SCALING_FACTOR);
    uint256 divFloor = aScaled.div(b.rawValue);
    uint256 mod = aScaled.mod(b.rawValue);
    if (mod != 0) {
      return Unsigned(divFloor.add(1));
    } else {
      return Unsigned(divFloor);
    }
  }

  function divCeil(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

    return divCeil(a, fromUnscaledUint(b));
  }

  function pow(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory output) {

    output = fromUnscaledUint(1);
    for (uint256 i = 0; i < b; i = i.add(1)) {
      output = mul(output, a);
    }
  }

  int256 private constant SFP_SCALING_FACTOR = 10**18;

  struct Signed {
    int256 rawValue;
  }

  function fromSigned(Signed memory a) internal pure returns (Unsigned memory) {

    require(a.rawValue >= 0, "Negative value provided");
    return Unsigned(uint256(a.rawValue));
  }

  function fromUnsigned(Unsigned memory a) internal pure returns (Signed memory) {

    require(a.rawValue <= uint256(type(int256).max), "Unsigned too large");
    return Signed(int256(a.rawValue));
  }

  function fromUnscaledInt(int256 a) internal pure returns (Signed memory) {

    return Signed(a.mul(SFP_SCALING_FACTOR));
  }

  function isEqual(Signed memory a, int256 b) internal pure returns (bool) {

    return a.rawValue == fromUnscaledInt(b).rawValue;
  }

  function isEqual(Signed memory a, Signed memory b) internal pure returns (bool) {

    return a.rawValue == b.rawValue;
  }

  function isGreaterThan(Signed memory a, Signed memory b) internal pure returns (bool) {

    return a.rawValue > b.rawValue;
  }

  function isGreaterThan(Signed memory a, int256 b) internal pure returns (bool) {

    return a.rawValue > fromUnscaledInt(b).rawValue;
  }

  function isGreaterThan(int256 a, Signed memory b) internal pure returns (bool) {

    return fromUnscaledInt(a).rawValue > b.rawValue;
  }

  function isGreaterThanOrEqual(Signed memory a, Signed memory b) internal pure returns (bool) {

    return a.rawValue >= b.rawValue;
  }

  function isGreaterThanOrEqual(Signed memory a, int256 b) internal pure returns (bool) {

    return a.rawValue >= fromUnscaledInt(b).rawValue;
  }

  function isGreaterThanOrEqual(int256 a, Signed memory b) internal pure returns (bool) {

    return fromUnscaledInt(a).rawValue >= b.rawValue;
  }

  function isLessThan(Signed memory a, Signed memory b) internal pure returns (bool) {

    return a.rawValue < b.rawValue;
  }

  function isLessThan(Signed memory a, int256 b) internal pure returns (bool) {

    return a.rawValue < fromUnscaledInt(b).rawValue;
  }

  function isLessThan(int256 a, Signed memory b) internal pure returns (bool) {

    return fromUnscaledInt(a).rawValue < b.rawValue;
  }

  function isLessThanOrEqual(Signed memory a, Signed memory b) internal pure returns (bool) {

    return a.rawValue <= b.rawValue;
  }

  function isLessThanOrEqual(Signed memory a, int256 b) internal pure returns (bool) {

    return a.rawValue <= fromUnscaledInt(b).rawValue;
  }

  function isLessThanOrEqual(int256 a, Signed memory b) internal pure returns (bool) {

    return fromUnscaledInt(a).rawValue <= b.rawValue;
  }

  function min(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

    return a.rawValue < b.rawValue ? a : b;
  }

  function max(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

    return a.rawValue > b.rawValue ? a : b;
  }

  function add(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

    return Signed(a.rawValue.add(b.rawValue));
  }

  function add(Signed memory a, int256 b) internal pure returns (Signed memory) {

    return add(a, fromUnscaledInt(b));
  }

  function sub(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

    return Signed(a.rawValue.sub(b.rawValue));
  }

  function sub(Signed memory a, int256 b) internal pure returns (Signed memory) {

    return sub(a, fromUnscaledInt(b));
  }

  function sub(int256 a, Signed memory b) internal pure returns (Signed memory) {

    return sub(fromUnscaledInt(a), b);
  }

  function mul(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

    return Signed(a.rawValue.mul(b.rawValue) / SFP_SCALING_FACTOR);
  }

  function mul(Signed memory a, int256 b) internal pure returns (Signed memory) {

    return Signed(a.rawValue.mul(b));
  }

  function mulAwayFromZero(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

    int256 mulRaw = a.rawValue.mul(b.rawValue);
    int256 mulTowardsZero = mulRaw / SFP_SCALING_FACTOR;
    int256 mod = mulRaw % SFP_SCALING_FACTOR;
    if (mod != 0) {
      bool isResultPositive = isLessThan(a, 0) == isLessThan(b, 0);
      int256 valueToAdd = isResultPositive ? int256(1) : int256(-1);
      return Signed(mulTowardsZero.add(valueToAdd));
    } else {
      return Signed(mulTowardsZero);
    }
  }

  function mulAwayFromZero(Signed memory a, int256 b) internal pure returns (Signed memory) {

    return Signed(a.rawValue.mul(b));
  }

  function div(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

    return Signed(a.rawValue.mul(SFP_SCALING_FACTOR).div(b.rawValue));
  }

  function div(Signed memory a, int256 b) internal pure returns (Signed memory) {

    return Signed(a.rawValue.div(b));
  }

  function div(int256 a, Signed memory b) internal pure returns (Signed memory) {

    return div(fromUnscaledInt(a), b);
  }

  function divAwayFromZero(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

    int256 aScaled = a.rawValue.mul(SFP_SCALING_FACTOR);
    int256 divTowardsZero = aScaled.div(b.rawValue);
    int256 mod = aScaled % b.rawValue;
    if (mod != 0) {
      bool isResultPositive = isLessThan(a, 0) == isLessThan(b, 0);
      int256 valueToAdd = isResultPositive ? int256(1) : int256(-1);
      return Signed(divTowardsZero.add(valueToAdd));
    } else {
      return Signed(divTowardsZero);
    }
  }

  function divAwayFromZero(Signed memory a, int256 b) internal pure returns (Signed memory) {

    return divAwayFromZero(a, fromUnscaledInt(b));
  }

  function pow(Signed memory a, uint256 b) internal pure returns (Signed memory output) {

    output = fromUnscaledInt(1);
    for (uint256 i = 0; i < b; i = i.add(1)) {
      output = mul(output, a);
    }
  }
}// MIT

pragma solidity 0.6.12;

interface ICreditLine {

  function borrower() external view returns (address);


  function limit() external view returns (uint256);


  function maxLimit() external view returns (uint256);


  function interestApr() external view returns (uint256);


  function paymentPeriodInDays() external view returns (uint256);


  function principalGracePeriodInDays() external view returns (uint256);


  function termInDays() external view returns (uint256);


  function lateFeeApr() external view returns (uint256);


  function isLate() external view returns (bool);


  function withinPrincipalGracePeriod() external view returns (bool);


  function balance() external view returns (uint256);


  function interestOwed() external view returns (uint256);


  function principalOwed() external view returns (uint256);


  function termEndTime() external view returns (uint256);


  function nextDueTime() external view returns (uint256);


  function interestAccruedAsOf() external view returns (uint256);


  function lastFullPaymentTime() external view returns (uint256);

}// MIT

pragma solidity 0.6.12;


interface IPoolTokens is IERC721 {

  event TokenMinted(
    address indexed owner,
    address indexed pool,
    uint256 indexed tokenId,
    uint256 amount,
    uint256 tranche
  );

  event TokenRedeemed(
    address indexed owner,
    address indexed pool,
    uint256 indexed tokenId,
    uint256 principalRedeemed,
    uint256 interestRedeemed,
    uint256 tranche
  );
  event TokenBurned(address indexed owner, address indexed pool, uint256 indexed tokenId);

  struct TokenInfo {
    address pool;
    uint256 tranche;
    uint256 principalAmount;
    uint256 principalRedeemed;
    uint256 interestRedeemed;
  }

  struct MintParams {
    uint256 principalAmount;
    uint256 tranche;
  }

  function mint(MintParams calldata params, address to) external returns (uint256);


  function redeem(
    uint256 tokenId,
    uint256 principalRedeemed,
    uint256 interestRedeemed
  ) external;


  function burn(uint256 tokenId) external;


  function onPoolCreated(address newPool) external;


  function getTokenInfo(uint256 tokenId) external view returns (TokenInfo memory);


  function validPool(address sender) external view returns (bool);


  function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);

}// MIT

pragma solidity 0.6.12;


abstract contract IV2CreditLine is ICreditLine {
  function principal() external view virtual returns (uint256);

  function totalInterestAccrued() external view virtual returns (uint256);

  function termStartTime() external view virtual returns (uint256);

  function setLimit(uint256 newAmount) external virtual;

  function setMaxLimit(uint256 newAmount) external virtual;

  function setBalance(uint256 newBalance) external virtual;

  function setPrincipal(uint256 _principal) external virtual;

  function setTotalInterestAccrued(uint256 _interestAccrued) external virtual;

  function drawdown(uint256 amount) external virtual;

  function assess()
    external
    virtual
    returns (
      uint256,
      uint256,
      uint256
    );

  function initialize(
    address _config,
    address owner,
    address _borrower,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr,
    uint256 _principalGracePeriodInDays
  ) public virtual;

  function setTermEndTime(uint256 newTermEndTime) external virtual;

  function setNextDueTime(uint256 newNextDueTime) external virtual;

  function setInterestOwed(uint256 newInterestOwed) external virtual;

  function setPrincipalOwed(uint256 newPrincipalOwed) external virtual;

  function setInterestAccruedAsOf(uint256 newInterestAccruedAsOf) external virtual;

  function setWritedownAmount(uint256 newWritedownAmount) external virtual;

  function setLastFullPaymentTime(uint256 newLastFullPaymentTime) external virtual;

  function setLateFeeApr(uint256 newLateFeeApr) external virtual;

  function updateGoldfinchConfig() external virtual;
}// MIT

pragma solidity 0.6.12;


abstract contract ITranchedPool {
  IV2CreditLine public creditLine;
  uint256 public createdAt;

  enum Tranches {
    Reserved,
    Senior,
    Junior
  }

  struct TrancheInfo {
    uint256 id;
    uint256 principalDeposited;
    uint256 principalSharePrice;
    uint256 interestSharePrice;
    uint256 lockedUntil;
  }

  struct PoolSlice {
    TrancheInfo seniorTranche;
    TrancheInfo juniorTranche;
    uint256 totalInterestAccrued;
    uint256 principalDeployed;
  }

  struct SliceInfo {
    uint256 reserveFeePercent;
    uint256 interestAccrued;
    uint256 principalAccrued;
  }

  struct ApplyResult {
    uint256 interestRemaining;
    uint256 principalRemaining;
    uint256 reserveDeduction;
    uint256 oldInterestSharePrice;
    uint256 oldPrincipalSharePrice;
  }

  function initialize(
    address _config,
    address _borrower,
    uint256 _juniorFeePercent,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr,
    uint256 _principalGracePeriodInDays,
    uint256 _fundableAt,
    uint256[] calldata _allowedUIDTypes
  ) public virtual;

  function getTranche(uint256 tranche) external view virtual returns (TrancheInfo memory);

  function pay(uint256 amount) external virtual;

  function lockJuniorCapital() external virtual;

  function lockPool() external virtual;

  function initializeNextSlice(uint256 _fundableAt) external virtual;

  function totalJuniorDeposits() external view virtual returns (uint256);

  function drawdown(uint256 amount) external virtual;

  function setFundableAt(uint256 timestamp) external virtual;

  function deposit(uint256 tranche, uint256 amount) external virtual returns (uint256 tokenId);

  function assess() external virtual;

  function depositWithPermit(
    uint256 tranche,
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external virtual returns (uint256 tokenId);

  function availableToWithdraw(uint256 tokenId)
    external
    view
    virtual
    returns (uint256 interestRedeemable, uint256 principalRedeemable);

  function withdraw(uint256 tokenId, uint256 amount)
    external
    virtual
    returns (uint256 interestWithdrawn, uint256 principalWithdrawn);

  function withdrawMax(uint256 tokenId)
    external
    virtual
    returns (uint256 interestWithdrawn, uint256 principalWithdrawn);

  function withdrawMultiple(uint256[] calldata tokenIds, uint256[] calldata amounts) external virtual;
}// MIT

pragma solidity 0.6.12;



library TranchingLogic {

  using SafeMath for uint256;
  using FixedPoint for FixedPoint.Unsigned;
  using FixedPoint for uint256;

  event SharePriceUpdated(
    address indexed pool,
    uint256 indexed tranche,
    uint256 principalSharePrice,
    int256 principalDelta,
    uint256 interestSharePrice,
    int256 interestDelta
  );

  uint256 public constant FP_SCALING_FACTOR = 1e18;
  uint256 public constant ONE_HUNDRED = 100; // Need this because we cannot call .div on a literal 100

  function usdcToSharePrice(uint256 amount, uint256 totalShares) public pure returns (uint256) {

    return totalShares == 0 ? 0 : amount.mul(FP_SCALING_FACTOR).div(totalShares);
  }

  function sharePriceToUsdc(uint256 sharePrice, uint256 totalShares) public pure returns (uint256) {

    return sharePrice.mul(totalShares).div(FP_SCALING_FACTOR);
  }

  function redeemableInterestAndPrincipal(
    ITranchedPool.TrancheInfo storage trancheInfo,
    IPoolTokens.TokenInfo memory tokenInfo
  ) public view returns (uint256 interestRedeemable, uint256 principalRedeemable) {

    uint256 maxPrincipalRedeemable = sharePriceToUsdc(trancheInfo.principalSharePrice, tokenInfo.principalAmount);
    uint256 maxInterestRedeemable = sharePriceToUsdc(trancheInfo.interestSharePrice, tokenInfo.principalAmount);

    interestRedeemable = maxInterestRedeemable.sub(tokenInfo.interestRedeemed);
    principalRedeemable = maxPrincipalRedeemable.sub(tokenInfo.principalRedeemed);

    return (interestRedeemable, principalRedeemable);
  }

  function calculateExpectedSharePrice(
    ITranchedPool.TrancheInfo memory tranche,
    uint256 amount,
    ITranchedPool.PoolSlice memory slice
  ) public pure returns (uint256) {

    uint256 sharePrice = usdcToSharePrice(amount, tranche.principalDeposited);
    return scaleByPercentOwnership(tranche, sharePrice, slice);
  }

  function scaleForSlice(
    ITranchedPool.PoolSlice memory slice,
    uint256 amount,
    uint256 totalDeployed
  ) public pure returns (uint256) {

    return scaleByFraction(amount, slice.principalDeployed, totalDeployed);
  }

  function getSliceInfo(
    ITranchedPool.PoolSlice memory slice,
    IV2CreditLine creditLine,
    uint256 totalDeployed,
    uint256 reserveFeePercent
  ) public view returns (ITranchedPool.SliceInfo memory) {

    (uint256 interestAccrued, uint256 principalAccrued) = getTotalInterestAndPrincipal(
      slice,
      creditLine,
      totalDeployed
    );
    return
      ITranchedPool.SliceInfo({
        reserveFeePercent: reserveFeePercent,
        interestAccrued: interestAccrued,
        principalAccrued: principalAccrued
      });
  }

  function getTotalInterestAndPrincipal(
    ITranchedPool.PoolSlice memory slice,
    IV2CreditLine creditLine,
    uint256 totalDeployed
  ) public view returns (uint256 interestAccrued, uint256 principalAccrued) {

    principalAccrued = creditLine.principalOwed();
    principalAccrued = totalDeployed.sub(creditLine.balance()).add(principalAccrued);
    principalAccrued = scaleForSlice(slice, principalAccrued, totalDeployed);
    uint256 totalDeposited = slice.seniorTranche.principalDeposited.add(slice.juniorTranche.principalDeposited);
    principalAccrued = totalDeposited.sub(slice.principalDeployed).add(principalAccrued);
    return (slice.totalInterestAccrued, principalAccrued);
  }

  function scaleByFraction(
    uint256 amount,
    uint256 fraction,
    uint256 total
  ) public pure returns (uint256) {

    FixedPoint.Unsigned memory totalAsFixedPoint = FixedPoint.fromUnscaledUint(total);
    FixedPoint.Unsigned memory fractionAsFixedPoint = FixedPoint.fromUnscaledUint(fraction);
    return fractionAsFixedPoint.div(totalAsFixedPoint).mul(amount).div(FP_SCALING_FACTOR).rawValue;
  }

  function applyToAllSeniorTranches(
    ITranchedPool.PoolSlice[] storage poolSlices,
    uint256 interest,
    uint256 principal,
    uint256 reserveFeePercent,
    uint256 totalDeployed,
    IV2CreditLine creditLine,
    uint256 juniorFeePercent
  ) public returns (ITranchedPool.ApplyResult memory) {

    ITranchedPool.ApplyResult memory seniorApplyResult;
    for (uint256 i = 0; i < poolSlices.length; i++) {
      ITranchedPool.SliceInfo memory sliceInfo = getSliceInfo(
        poolSlices[i],
        creditLine,
        totalDeployed,
        reserveFeePercent
      );

      ITranchedPool.ApplyResult memory applyResult = applyToSeniorTranche(
        poolSlices[i],
        scaleForSlice(poolSlices[i], interest, totalDeployed),
        scaleForSlice(poolSlices[i], principal, totalDeployed),
        juniorFeePercent,
        sliceInfo
      );
      emitSharePriceUpdatedEvent(poolSlices[i].seniorTranche, applyResult);
      seniorApplyResult.interestRemaining = seniorApplyResult.interestRemaining.add(applyResult.interestRemaining);
      seniorApplyResult.principalRemaining = seniorApplyResult.principalRemaining.add(applyResult.principalRemaining);
      seniorApplyResult.reserveDeduction = seniorApplyResult.reserveDeduction.add(applyResult.reserveDeduction);
    }
    return seniorApplyResult;
  }

  function applyToAllJuniorTranches(
    ITranchedPool.PoolSlice[] storage poolSlices,
    uint256 interest,
    uint256 principal,
    uint256 reserveFeePercent,
    uint256 totalDeployed,
    IV2CreditLine creditLine
  ) public returns (uint256 totalReserveAmount) {

    for (uint256 i = 0; i < poolSlices.length; i++) {
      ITranchedPool.SliceInfo memory sliceInfo = getSliceInfo(
        poolSlices[i],
        creditLine,
        totalDeployed,
        reserveFeePercent
      );
      ITranchedPool.ApplyResult memory applyResult = applyToJuniorTranche(
        poolSlices[i],
        scaleForSlice(poolSlices[i], interest, totalDeployed),
        scaleForSlice(poolSlices[i], principal, totalDeployed),
        sliceInfo
      );
      emitSharePriceUpdatedEvent(poolSlices[i].juniorTranche, applyResult);
      totalReserveAmount = totalReserveAmount.add(applyResult.reserveDeduction);
    }
    return totalReserveAmount;
  }

  function emitSharePriceUpdatedEvent(
    ITranchedPool.TrancheInfo memory tranche,
    ITranchedPool.ApplyResult memory applyResult
  ) internal {

    emit SharePriceUpdated(
      address(this),
      tranche.id,
      tranche.principalSharePrice,
      int256(tranche.principalSharePrice.sub(applyResult.oldPrincipalSharePrice)),
      tranche.interestSharePrice,
      int256(tranche.interestSharePrice.sub(applyResult.oldInterestSharePrice))
    );
  }

  function applyToSeniorTranche(
    ITranchedPool.PoolSlice storage slice,
    uint256 interestRemaining,
    uint256 principalRemaining,
    uint256 juniorFeePercent,
    ITranchedPool.SliceInfo memory sliceInfo
  ) public returns (ITranchedPool.ApplyResult memory) {

    uint256 expectedInterestSharePrice = calculateExpectedSharePrice(
      slice.seniorTranche,
      sliceInfo.interestAccrued,
      slice
    );
    uint256 expectedPrincipalSharePrice = calculateExpectedSharePrice(
      slice.seniorTranche,
      sliceInfo.principalAccrued,
      slice
    );

    uint256 desiredNetInterestSharePrice = scaleByFraction(
      expectedInterestSharePrice,
      ONE_HUNDRED.sub(juniorFeePercent.add(sliceInfo.reserveFeePercent)),
      ONE_HUNDRED
    );
    uint256 reserveDeduction = scaleByFraction(interestRemaining, sliceInfo.reserveFeePercent, ONE_HUNDRED);
    interestRemaining = interestRemaining.sub(reserveDeduction);
    uint256 oldInterestSharePrice = slice.seniorTranche.interestSharePrice;
    uint256 oldPrincipalSharePrice = slice.seniorTranche.principalSharePrice;
    (interestRemaining, principalRemaining) = applyBySharePrice(
      slice.seniorTranche,
      interestRemaining,
      principalRemaining,
      desiredNetInterestSharePrice,
      expectedPrincipalSharePrice
    );
    return
      ITranchedPool.ApplyResult({
        interestRemaining: interestRemaining,
        principalRemaining: principalRemaining,
        reserveDeduction: reserveDeduction,
        oldInterestSharePrice: oldInterestSharePrice,
        oldPrincipalSharePrice: oldPrincipalSharePrice
      });
  }

  function applyToJuniorTranche(
    ITranchedPool.PoolSlice storage slice,
    uint256 interestRemaining,
    uint256 principalRemaining,
    ITranchedPool.SliceInfo memory sliceInfo
  ) public returns (ITranchedPool.ApplyResult memory) {

    uint256 expectedInterestSharePrice = slice.juniorTranche.interestSharePrice.add(
      usdcToSharePrice(interestRemaining, slice.juniorTranche.principalDeposited)
    );
    uint256 expectedPrincipalSharePrice = calculateExpectedSharePrice(
      slice.juniorTranche,
      sliceInfo.principalAccrued,
      slice
    );
    uint256 oldInterestSharePrice = slice.juniorTranche.interestSharePrice;
    uint256 oldPrincipalSharePrice = slice.juniorTranche.principalSharePrice;
    (interestRemaining, principalRemaining) = applyBySharePrice(
      slice.juniorTranche,
      interestRemaining,
      principalRemaining,
      expectedInterestSharePrice,
      expectedPrincipalSharePrice
    );

    interestRemaining = interestRemaining.add(principalRemaining);
    uint256 reserveDeduction = scaleByFraction(principalRemaining, sliceInfo.reserveFeePercent, ONE_HUNDRED);
    interestRemaining = interestRemaining.sub(reserveDeduction);
    principalRemaining = 0;

    (interestRemaining, principalRemaining) = applyByAmount(
      slice.juniorTranche,
      interestRemaining.add(principalRemaining),
      0,
      interestRemaining.add(principalRemaining),
      0
    );
    return
      ITranchedPool.ApplyResult({
        interestRemaining: interestRemaining,
        principalRemaining: principalRemaining,
        reserveDeduction: reserveDeduction,
        oldInterestSharePrice: oldInterestSharePrice,
        oldPrincipalSharePrice: oldPrincipalSharePrice
      });
  }

  function applyBySharePrice(
    ITranchedPool.TrancheInfo storage tranche,
    uint256 interestRemaining,
    uint256 principalRemaining,
    uint256 desiredInterestSharePrice,
    uint256 desiredPrincipalSharePrice
  ) public returns (uint256, uint256) {

    uint256 desiredInterestAmount = desiredAmountFromSharePrice(
      desiredInterestSharePrice,
      tranche.interestSharePrice,
      tranche.principalDeposited
    );
    uint256 desiredPrincipalAmount = desiredAmountFromSharePrice(
      desiredPrincipalSharePrice,
      tranche.principalSharePrice,
      tranche.principalDeposited
    );
    return applyByAmount(tranche, interestRemaining, principalRemaining, desiredInterestAmount, desiredPrincipalAmount);
  }

  function applyByAmount(
    ITranchedPool.TrancheInfo storage tranche,
    uint256 interestRemaining,
    uint256 principalRemaining,
    uint256 desiredInterestAmount,
    uint256 desiredPrincipalAmount
  ) public returns (uint256, uint256) {

    uint256 totalShares = tranche.principalDeposited;
    uint256 newSharePrice;

    (interestRemaining, newSharePrice) = applyToSharePrice(
      interestRemaining,
      tranche.interestSharePrice,
      desiredInterestAmount,
      totalShares
    );
    tranche.interestSharePrice = newSharePrice;

    (principalRemaining, newSharePrice) = applyToSharePrice(
      principalRemaining,
      tranche.principalSharePrice,
      desiredPrincipalAmount,
      totalShares
    );
    tranche.principalSharePrice = newSharePrice;
    return (interestRemaining, principalRemaining);
  }

  function migrateAccountingVariables(address originalClAddr, address newClAddr) public {

    IV2CreditLine originalCl = IV2CreditLine(originalClAddr);
    IV2CreditLine newCl = IV2CreditLine(newClAddr);

    newCl.setBalance(originalCl.balance());
    newCl.setLimit(originalCl.limit());
    newCl.setInterestOwed(originalCl.interestOwed());
    newCl.setPrincipalOwed(originalCl.principalOwed());
    newCl.setTermEndTime(originalCl.termEndTime());
    newCl.setNextDueTime(originalCl.nextDueTime());
    newCl.setInterestAccruedAsOf(originalCl.interestAccruedAsOf());
    newCl.setLastFullPaymentTime(originalCl.lastFullPaymentTime());
    newCl.setTotalInterestAccrued(originalCl.totalInterestAccrued());
  }

  function closeCreditLine(address originalCl) public {

    IV2CreditLine oldCreditLine = IV2CreditLine(originalCl);
    oldCreditLine.setBalance(0);
    oldCreditLine.setLimit(0);
    oldCreditLine.setMaxLimit(0);
  }

  function desiredAmountFromSharePrice(
    uint256 desiredSharePrice,
    uint256 actualSharePrice,
    uint256 totalShares
  ) public pure returns (uint256) {

    if (desiredSharePrice < actualSharePrice) {
      desiredSharePrice = actualSharePrice;
    }
    uint256 sharePriceDifference = desiredSharePrice.sub(actualSharePrice);
    return sharePriceToUsdc(sharePriceDifference, totalShares);
  }

  function applyToSharePrice(
    uint256 amountRemaining,
    uint256 currentSharePrice,
    uint256 desiredAmount,
    uint256 totalShares
  ) public pure returns (uint256, uint256) {

    if (amountRemaining == 0 || desiredAmount == 0) {
      return (amountRemaining, currentSharePrice);
    }
    if (amountRemaining < desiredAmount) {
      desiredAmount = amountRemaining;
    }
    uint256 sharePriceDifference = usdcToSharePrice(desiredAmount, totalShares);
    return (amountRemaining.sub(desiredAmount), currentSharePrice.add(sharePriceDifference));
  }

  function scaleByPercentOwnership(
    ITranchedPool.TrancheInfo memory tranche,
    uint256 amount,
    ITranchedPool.PoolSlice memory slice
  ) public pure returns (uint256) {

    uint256 totalDeposited = slice.juniorTranche.principalDeposited.add(slice.seniorTranche.principalDeposited);
    return scaleByFraction(amount, tranche.principalDeposited, totalDeposited);
  }
}