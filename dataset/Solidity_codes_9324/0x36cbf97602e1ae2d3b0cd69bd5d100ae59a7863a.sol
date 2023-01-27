pragma solidity >=0.4.24 <0.7.0;


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
}pragma solidity ^0.6.0;

contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}pragma solidity ^0.6.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}pragma solidity ^0.6.0;


abstract contract AccessControlUpgradeSafe is Initializable, ContextUpgradeSafe {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {


    }

    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    uint256[49] private __gap;
}pragma solidity ^0.6.0;

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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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

}pragma solidity ^0.6.0;


contract PausableUpgradeSafe is Initializable, ContextUpgradeSafe {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;


    function __Pausable_init() internal initializer {

        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {



        _paused = false;

    }


    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
}pragma solidity ^0.6.0;

contract ReentrancyGuardUpgradeSafe is Initializable {

    bool private _notEntered;


    function __ReentrancyGuard_init() internal initializer {

        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {



        _notEntered = true;

    }


    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }

    uint256[49] private __gap;
}// GPL-3.0-or-later

pragma solidity >=0.4.0;

library Babylonian {

    function sqrt(uint256 x) internal pure returns (uint256) {

        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}// MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IBackerRewards {

  function allocateRewards(uint256 _interestPaymentAmount) external;


  function onTranchedPoolDrawdown(uint256 sliceIndex) external;


  function setPoolTokenAccRewardsPerPrincipalDollarAtMint(address poolAddress, uint256 tokenId) external;

}// MIT

pragma solidity 0.6.12;



interface IERC20withDec is IERC20 {

  function decimals() external view returns (uint8);

}// MIT
pragma solidity 0.6.12;


interface ICUSDCContract is IERC20withDec {


  function mint(uint256 mintAmount) external returns (uint256);


  function redeem(uint256 redeemTokens) external returns (uint256);


  function redeemUnderlying(uint256 redeemAmount) external returns (uint256);


  function borrow(uint256 borrowAmount) external returns (uint256);


  function repayBorrow(uint256 repayAmount) external returns (uint256);


  function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);


  function liquidateBorrow(
    address borrower,
    uint256 repayAmount,
    address cTokenCollateral
  ) external returns (uint256);


  function getAccountSnapshot(address account)
    external
    view
    returns (
      uint256,
      uint256,
      uint256,
      uint256
    );


  function balanceOfUnderlying(address owner) external returns (uint256);


  function exchangeRateCurrent() external returns (uint256);



  function _addReserves(uint256 addAmount) external returns (uint256);

}// MIT

pragma solidity 0.6.12;

abstract contract ICreditDesk {
  uint256 public totalWritedowns;
  uint256 public totalLoansOutstanding;

  function setUnderwriterGovernanceLimit(address underwriterAddress, uint256 limit) external virtual;

  function drawdown(address creditLineAddress, uint256 amount) external virtual;

  function pay(address creditLineAddress, uint256 amount) external virtual;

  function assessCreditLine(address creditLineAddress) external virtual;

  function applyPayment(address creditLineAddress, uint256 amount) external virtual;

  function getNextPaymentAmount(address creditLineAddress, uint256 asOfBLock) external view virtual returns (uint256);
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

interface ICurveLP {

  function token() external view returns (address);


  function get_virtual_price() external view returns (uint256);


  function calc_token_amount(uint256[2] calldata amounts) external view returns (uint256);


  function add_liquidity(
    uint256[2] calldata amounts,
    uint256 min_mint_amount,
    bool use_eth,
    address receiver
  ) external returns (uint256);


  function balances(uint256 arg0) external view returns (uint256);

}// MIT

pragma solidity 0.6.12;

interface IEvents {

  event SafetyCheckTriggered();
}// MIT

pragma solidity 0.6.12;


interface IFidu is IERC20withDec {

  function mintTo(address to, uint256 amount) external;


  function burnFrom(address to, uint256 amount) external;


  function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity 0.6.12;

abstract contract IGo {
  uint256 public constant ID_TYPE_0 = 0;
  uint256 public constant ID_TYPE_1 = 1;
  uint256 public constant ID_TYPE_2 = 2;
  uint256 public constant ID_TYPE_3 = 3;
  uint256 public constant ID_TYPE_4 = 4;
  uint256 public constant ID_TYPE_5 = 5;
  uint256 public constant ID_TYPE_6 = 6;
  uint256 public constant ID_TYPE_7 = 7;
  uint256 public constant ID_TYPE_8 = 8;
  uint256 public constant ID_TYPE_9 = 9;
  uint256 public constant ID_TYPE_10 = 10;

  function uniqueIdentity() external virtual returns (address);

  function go(address account) public view virtual returns (bool);

  function goOnlyIdTypes(address account, uint256[] calldata onlyIdTypes) public view virtual returns (bool);

  function goSeniorPool(address account) public view virtual returns (bool);

  function updateGoldfinchConfig() external virtual;
}// MIT

pragma solidity 0.6.12;

interface IGoldfinchConfig {

  function getNumber(uint256 index) external returns (uint256);


  function getAddress(uint256 index) external returns (address);


  function setAddress(uint256 index, address newAddress) external returns (address);


  function setNumber(uint256 index, uint256 newNumber) external returns (uint256);

}// MIT

pragma solidity 0.6.12;

interface IGoldfinchFactory {

  function createCreditLine() external returns (address);


  function createBorrower(address owner) external returns (address);


  function createPool(
    address _borrower,
    uint256 _juniorFeePercent,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr,
    uint256[] calldata _allowedUIDTypes
  ) external returns (address);


  function createMigratedPool(
    address _borrower,
    uint256 _juniorFeePercent,
    uint256 _limit,
    uint256 _interestApr,
    uint256 _paymentPeriodInDays,
    uint256 _termInDays,
    uint256 _lateFeeApr,
    uint256[] calldata _allowedUIDTypes
  ) external returns (address);


  function updateGoldfinchConfig() external;

}// MIT

pragma solidity 0.6.12;

abstract contract IPool {
  uint256 public sharePrice;

  function deposit(uint256 amount) external virtual;

  function withdraw(uint256 usdcAmount) external virtual;

  function withdrawInFidu(uint256 fiduAmount) external virtual;

  function collectInterestAndPrincipal(
    address from,
    uint256 interest,
    uint256 principal
  ) public virtual;

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) public virtual returns (bool);

  function drawdown(address to, uint256 amount) public virtual returns (bool);

  function sweepToCompound() public virtual;

  function sweepFromCompound() public virtual;

  function distributeLosses(address creditlineAddress, int256 writedownDelta) external virtual;

  function assets() public view virtual returns (uint256);
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


  function withdrawPrincipal(uint256 tokenId, uint256 principalAmount) external;


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

  function numSlices() external view virtual returns (uint256);
}// MIT

pragma solidity 0.6.12;


abstract contract ISeniorPool {
  uint256 public sharePrice;
  uint256 public totalLoansOutstanding;
  uint256 public totalWritedowns;

  function deposit(uint256 amount) external virtual returns (uint256 depositShares);

  function depositWithPermit(
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external virtual returns (uint256 depositShares);

  function withdraw(uint256 usdcAmount) external virtual returns (uint256 amount);

  function withdrawInFidu(uint256 fiduAmount) external virtual returns (uint256 amount);

  function sweepToCompound() public virtual;

  function sweepFromCompound() public virtual;

  function invest(ITranchedPool pool) public virtual;

  function estimateInvestment(ITranchedPool pool) public view virtual returns (uint256);

  function redeem(uint256 tokenId) public virtual;

  function writedown(uint256 tokenId) public virtual;

  function calculateWritedown(uint256 tokenId) public view virtual returns (uint256 writedownAmount);

  function assets() public view virtual returns (uint256);

  function getNumShares(uint256 amount) public view virtual returns (uint256);
}// MIT

pragma solidity 0.6.12;


abstract contract ISeniorPoolStrategy {
  function getLeverageRatio(ITranchedPool pool) public view virtual returns (uint256);

  function invest(ISeniorPool seniorPool, ITranchedPool pool) public view virtual returns (uint256 amount);

  function estimateInvestment(ISeniorPool seniorPool, ITranchedPool pool) public view virtual returns (uint256);
}// MIT
pragma solidity 0.6.12;

interface IStakingRewards {

  function unstake(uint256 tokenId, uint256 amount) external;


  function addToStake(uint256 tokenId, uint256 amount) external;


  function stakedBalanceOf(uint256 tokenId) external view returns (uint256);


  function depositToCurveAndStakeFrom(
    address nftRecipient,
    uint256 fiduAmount,
    uint256 usdcAmount
  ) external;


  function kick(uint256 tokenId) external;


  function accumulatedRewardsPerToken() external view returns (uint256);


  function lastUpdateTime() external view returns (uint256);

}// MIT

pragma solidity 0.6.12;


abstract contract SafeERC20Transfer {
  function safeERC20Transfer(
    IERC20 erc20,
    address to,
    uint256 amount,
    string memory message
  ) internal {
    require(to != address(0), "Can't send to zero address");
    bool success = erc20.transfer(to, amount);
    require(success, message);
  }

  function safeERC20Transfer(
    IERC20 erc20,
    address to,
    uint256 amount
  ) internal {
    safeERC20Transfer(erc20, to, amount, "Failed to transfer ERC20");
  }

  function safeERC20TransferFrom(
    IERC20 erc20,
    address from,
    address to,
    uint256 amount,
    string memory message
  ) internal {
    require(to != address(0), "Can't send to zero address");
    bool success = erc20.transferFrom(from, to, amount);
    require(success, message);
  }

  function safeERC20TransferFrom(
    IERC20 erc20,
    address from,
    address to,
    uint256 amount
  ) internal {
    string memory message = "Failed to transfer ERC20";
    safeERC20TransferFrom(erc20, from, to, amount, message);
  }

  function safeERC20Approve(
    IERC20 erc20,
    address spender,
    uint256 allowance,
    string memory message
  ) internal {
    bool success = erc20.approve(spender, allowance);
    require(success, message);
  }

  function safeERC20Approve(
    IERC20 erc20,
    address spender,
    uint256 allowance
  ) internal {
    string memory message = "Failed to approve ERC20";
    safeERC20Approve(erc20, spender, allowance, message);
  }
}// MIT
pragma solidity 0.6.12;



contract PauserPausable is AccessControlUpgradeSafe, PausableUpgradeSafe {

  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

  function __PauserPausable__init() public initializer {

    __Pausable_init_unchained();
  }


  function pause() public onlyPauserRole {

    _pause();
  }

  function unpause() public onlyPauserRole {

    _unpause();
  }

  modifier onlyPauserRole() {

    require(hasRole(PAUSER_ROLE, _msgSender()), "Must have pauser role to perform this action");
    _;
  }
}// MIT

pragma solidity 0.6.12;



contract BaseUpgradeablePausable is
  Initializable,
  AccessControlUpgradeSafe,
  PauserPausable,
  ReentrancyGuardUpgradeSafe
{

  bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
  using SafeMath for uint256;
  uint256[50] private __gap1;
  uint256[50] private __gap2;
  uint256[50] private __gap3;
  uint256[50] private __gap4;

  function __BaseUpgradeablePausable__init(address owner) public initializer {

    require(owner != address(0), "Owner cannot be the zero address");
    __AccessControl_init_unchained();
    __Pausable_init_unchained();
    __ReentrancyGuard_init_unchained();

    _setupRole(OWNER_ROLE, owner);
    _setupRole(PAUSER_ROLE, owner);

    _setRoleAdmin(PAUSER_ROLE, OWNER_ROLE);
    _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
  }

  function isAdmin() public view returns (bool) {

    return hasRole(OWNER_ROLE, _msgSender());
  }

  modifier onlyAdmin() {

    require(isAdmin(), "Must have admin role to perform this action");
    _;
  }
}// MIT

pragma solidity 0.6.12;


library ConfigOptions {

  enum Numbers {
    TransactionLimit,
    TotalFundsLimit,
    MaxUnderwriterLimit,
    ReserveDenominator,
    WithdrawFeeDenominator,
    LatenessGracePeriodInDays,
    LatenessMaxDays,
    DrawdownPeriodInSeconds,
    TransferRestrictionPeriodInDays,
    LeverageRatio
  }
  enum Addresses {
    Pool,
    CreditLineImplementation,
    GoldfinchFactory,
    CreditDesk,
    Fidu,
    USDC,
    TreasuryReserve,
    ProtocolAdmin,
    OneInch,
    TrustedForwarder,
    CUSDCContract,
    GoldfinchConfig,
    PoolTokens,
    TranchedPoolImplementation,
    SeniorPool,
    SeniorPoolStrategy,
    MigratedTranchedPoolImplementation,
    BorrowerImplementation,
    GFI,
    Go,
    BackerRewards,
    StakingRewards,
    FiduUSDCCurveLP
  }
}// MIT

pragma solidity 0.6.12;



contract GoldfinchConfig is BaseUpgradeablePausable {

  bytes32 public constant GO_LISTER_ROLE = keccak256("GO_LISTER_ROLE");

  mapping(uint256 => address) public addresses;
  mapping(uint256 => uint256) public numbers;
  mapping(address => bool) public goList;

  event AddressUpdated(address owner, uint256 index, address oldValue, address newValue);
  event NumberUpdated(address owner, uint256 index, uint256 oldValue, uint256 newValue);

  event GoListed(address indexed member);
  event NoListed(address indexed member);

  bool public valuesInitialized;

  function initialize(address owner) public initializer {

    require(owner != address(0), "Owner address cannot be empty");

    __BaseUpgradeablePausable__init(owner);

    _setupRole(GO_LISTER_ROLE, owner);

    _setRoleAdmin(GO_LISTER_ROLE, OWNER_ROLE);
  }

  function setAddress(uint256 addressIndex, address newAddress) public onlyAdmin {

    require(addresses[addressIndex] == address(0), "Address has already been initialized");

    emit AddressUpdated(msg.sender, addressIndex, addresses[addressIndex], newAddress);
    addresses[addressIndex] = newAddress;
  }

  function setNumber(uint256 index, uint256 newNumber) public onlyAdmin {

    emit NumberUpdated(msg.sender, index, numbers[index], newNumber);
    numbers[index] = newNumber;
  }

  function setTreasuryReserve(address newTreasuryReserve) public onlyAdmin {

    uint256 key = uint256(ConfigOptions.Addresses.TreasuryReserve);
    emit AddressUpdated(msg.sender, key, addresses[key], newTreasuryReserve);
    addresses[key] = newTreasuryReserve;
  }

  function setSeniorPoolStrategy(address newStrategy) public onlyAdmin {

    uint256 key = uint256(ConfigOptions.Addresses.SeniorPoolStrategy);
    emit AddressUpdated(msg.sender, key, addresses[key], newStrategy);
    addresses[key] = newStrategy;
  }

  function setCreditLineImplementation(address newAddress) public onlyAdmin {

    uint256 key = uint256(ConfigOptions.Addresses.CreditLineImplementation);
    emit AddressUpdated(msg.sender, key, addresses[key], newAddress);
    addresses[key] = newAddress;
  }

  function setTranchedPoolImplementation(address newAddress) public onlyAdmin {

    uint256 key = uint256(ConfigOptions.Addresses.TranchedPoolImplementation);
    emit AddressUpdated(msg.sender, key, addresses[key], newAddress);
    addresses[key] = newAddress;
  }

  function setBorrowerImplementation(address newAddress) public onlyAdmin {

    uint256 key = uint256(ConfigOptions.Addresses.BorrowerImplementation);
    emit AddressUpdated(msg.sender, key, addresses[key], newAddress);
    addresses[key] = newAddress;
  }

  function setGoldfinchConfig(address newAddress) public onlyAdmin {

    uint256 key = uint256(ConfigOptions.Addresses.GoldfinchConfig);
    emit AddressUpdated(msg.sender, key, addresses[key], newAddress);
    addresses[key] = newAddress;
  }

  function initializeFromOtherConfig(
    address _initialConfig,
    uint256 numbersLength,
    uint256 addressesLength
  ) public onlyAdmin {

    require(!valuesInitialized, "Already initialized values");
    IGoldfinchConfig initialConfig = IGoldfinchConfig(_initialConfig);
    for (uint256 i = 0; i < numbersLength; i++) {
      setNumber(i, initialConfig.getNumber(i));
    }

    for (uint256 i = 0; i < addressesLength; i++) {
      if (getAddress(i) == address(0)) {
        setAddress(i, initialConfig.getAddress(i));
      }
    }
    valuesInitialized = true;
  }

  function addToGoList(address _member) public onlyGoListerRole {

    goList[_member] = true;
    emit GoListed(_member);
  }

  function removeFromGoList(address _member) public onlyGoListerRole {

    goList[_member] = false;
    emit NoListed(_member);
  }

  function bulkAddToGoList(address[] calldata _members) external onlyGoListerRole {

    for (uint256 i = 0; i < _members.length; i++) {
      addToGoList(_members[i]);
    }
  }

  function bulkRemoveFromGoList(address[] calldata _members) external onlyGoListerRole {

    for (uint256 i = 0; i < _members.length; i++) {
      removeFromGoList(_members[i]);
    }
  }

  function getAddress(uint256 index) public view returns (address) {

    return addresses[index];
  }

  function getNumber(uint256 index) public view returns (uint256) {

    return numbers[index];
  }

  modifier onlyGoListerRole() {

    require(hasRole(GO_LISTER_ROLE, _msgSender()), "Must have go-lister role to perform this action");
    _;
  }
}// MIT

pragma solidity 0.6.12;



library ConfigHelper {

  function getPool(GoldfinchConfig config) internal view returns (IPool) {

    return IPool(poolAddress(config));
  }

  function getSeniorPool(GoldfinchConfig config) internal view returns (ISeniorPool) {

    return ISeniorPool(seniorPoolAddress(config));
  }

  function getSeniorPoolStrategy(GoldfinchConfig config) internal view returns (ISeniorPoolStrategy) {

    return ISeniorPoolStrategy(seniorPoolStrategyAddress(config));
  }

  function getUSDC(GoldfinchConfig config) internal view returns (IERC20withDec) {

    return IERC20withDec(usdcAddress(config));
  }

  function getCreditDesk(GoldfinchConfig config) internal view returns (ICreditDesk) {

    return ICreditDesk(creditDeskAddress(config));
  }

  function getFidu(GoldfinchConfig config) internal view returns (IFidu) {

    return IFidu(fiduAddress(config));
  }

  function getFiduUSDCCurveLP(GoldfinchConfig config) internal view returns (ICurveLP) {

    return ICurveLP(fiduUSDCCurveLPAddress(config));
  }

  function getCUSDCContract(GoldfinchConfig config) internal view returns (ICUSDCContract) {

    return ICUSDCContract(cusdcContractAddress(config));
  }

  function getPoolTokens(GoldfinchConfig config) internal view returns (IPoolTokens) {

    return IPoolTokens(poolTokensAddress(config));
  }

  function getBackerRewards(GoldfinchConfig config) internal view returns (IBackerRewards) {

    return IBackerRewards(backerRewardsAddress(config));
  }

  function getGoldfinchFactory(GoldfinchConfig config) internal view returns (IGoldfinchFactory) {

    return IGoldfinchFactory(goldfinchFactoryAddress(config));
  }

  function getGFI(GoldfinchConfig config) internal view returns (IERC20withDec) {

    return IERC20withDec(gfiAddress(config));
  }

  function getGo(GoldfinchConfig config) internal view returns (IGo) {

    return IGo(goAddress(config));
  }

  function getStakingRewards(GoldfinchConfig config) internal view returns (IStakingRewards) {

    return IStakingRewards(stakingRewardsAddress(config));
  }

  function oneInchAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.OneInch));
  }

  function creditLineImplementationAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.CreditLineImplementation));
  }

  function trustedForwarderAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.TrustedForwarder));
  }

  function configAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.GoldfinchConfig));
  }

  function poolAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.Pool));
  }

  function poolTokensAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.PoolTokens));
  }

  function backerRewardsAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.BackerRewards));
  }

  function seniorPoolAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.SeniorPool));
  }

  function seniorPoolStrategyAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.SeniorPoolStrategy));
  }

  function creditDeskAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.CreditDesk));
  }

  function goldfinchFactoryAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.GoldfinchFactory));
  }

  function gfiAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.GFI));
  }

  function fiduAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.Fidu));
  }

  function fiduUSDCCurveLPAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.FiduUSDCCurveLP));
  }

  function cusdcContractAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.CUSDCContract));
  }

  function usdcAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.USDC));
  }

  function tranchedPoolAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.TranchedPoolImplementation));
  }

  function migratedTranchedPoolAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.MigratedTranchedPoolImplementation));
  }

  function reserveAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.TreasuryReserve));
  }

  function protocolAdminAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.ProtocolAdmin));
  }

  function borrowerImplementationAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.BorrowerImplementation));
  }

  function goAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.Go));
  }

  function stakingRewardsAddress(GoldfinchConfig config) internal view returns (address) {

    return config.getAddress(uint256(ConfigOptions.Addresses.StakingRewards));
  }

  function getReserveDenominator(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.ReserveDenominator));
  }

  function getWithdrawFeeDenominator(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.WithdrawFeeDenominator));
  }

  function getLatenessGracePeriodInDays(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.LatenessGracePeriodInDays));
  }

  function getLatenessMaxDays(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.LatenessMaxDays));
  }

  function getDrawdownPeriodInSeconds(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.DrawdownPeriodInSeconds));
  }

  function getTransferRestrictionPeriodInDays(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.TransferRestrictionPeriodInDays));
  }

  function getLeverageRatio(GoldfinchConfig config) internal view returns (uint256) {

    return config.getNumber(uint256(ConfigOptions.Numbers.LeverageRatio));
  }
}// MIT
pragma solidity 0.6.12;







contract BackerRewards is IBackerRewards, BaseUpgradeablePausable, SafeERC20Transfer, IEvents {

  GoldfinchConfig public config;
  using ConfigHelper for GoldfinchConfig;
  using SafeMath for uint256;

  uint256 internal constant GFI_MANTISSA = 10**18;
  uint256 internal constant FIDU_MANTISSA = 10**18;
  uint256 internal constant USDC_MANTISSA = 10**6;
  uint256 internal constant NUM_TRANCHES_PER_SLICE = 2;

  struct BackerRewardsInfo {
    uint256 accRewardsPerPrincipalDollar; // accumulator gfi per interest dollar
  }

  struct BackerRewardsTokenInfo {
    uint256 rewardsClaimed; // gfi claimed
    uint256 accRewardsPerPrincipalDollarAtMint; // Pool's accRewardsPerPrincipalDollar at PoolToken mint()
  }

  struct StakingRewardsPoolInfo {
    uint256 accumulatedRewardsPerTokenAtLastCheckpoint;
    uint256 lastUpdateTime;
    StakingRewardsSliceInfo[] slicesInfo;
  }

  struct StakingRewardsSliceInfo {
    uint256 fiduSharePriceAtDrawdown;
    uint256 principalDeployedAtLastCheckpoint;
    uint256 accumulatedRewardsPerTokenAtDrawdown;
    uint256 accumulatedRewardsPerTokenAtLastCheckpoint;
    uint256 unrealizedAccumulatedRewardsPerTokenAtLastCheckpoint;
  }

  struct StakingRewardsTokenInfo {
    uint256 accumulatedRewardsPerTokenAtLastWithdraw;
  }

  uint256 public totalRewards;

  uint256 public maxInterestDollarsEligible;

  uint256 public totalInterestReceived;

  uint256 public totalRewardPercentOfTotalGFI;

  mapping(uint256 => BackerRewardsTokenInfo) public tokens;

  mapping(address => BackerRewardsInfo) public pools;

  mapping(ITranchedPool => StakingRewardsPoolInfo) public poolStakingRewards; // pool.address -> StakingRewardsPoolInfo

  mapping(uint256 => StakingRewardsTokenInfo) public tokenStakingRewards;

  function __initialize__(address owner, GoldfinchConfig _config) public initializer {

    require(owner != address(0) && address(_config) != address(0), "Owner and config addresses cannot be empty");
    __BaseUpgradeablePausable__init(owner);
    config = _config;
  }

  function forceInitializeStakingRewardsPoolInfo(
    ITranchedPool pool,
    uint256 fiduSharePriceAtDrawdown,
    uint256 principalDeployedAtDrawdown,
    uint256 rewardsAccumulatorAtDrawdown
  ) external onlyAdmin {

    require(config.getPoolTokens().validPool(address(pool)), "Invalid pool!");
    require(fiduSharePriceAtDrawdown != 0, "Invalid: 0");
    require(principalDeployedAtDrawdown != 0, "Invalid: 0");
    require(rewardsAccumulatorAtDrawdown != 0, "Invalid: 0");

    StakingRewardsPoolInfo storage poolInfo = poolStakingRewards[pool];
    require(poolInfo.slicesInfo.length <= 1, "trying to overwrite multi slice rewards info!");

    bool firstSliceHasAlreadyBeenInitialized = poolInfo.slicesInfo.length != 0;

    poolInfo.accumulatedRewardsPerTokenAtLastCheckpoint = rewardsAccumulatorAtDrawdown;
    StakingRewardsSliceInfo memory sliceInfo = _initializeStakingRewardsSliceInfo(
      fiduSharePriceAtDrawdown,
      principalDeployedAtDrawdown,
      rewardsAccumulatorAtDrawdown
    );

    if (firstSliceHasAlreadyBeenInitialized) {
      poolInfo.slicesInfo[0] = sliceInfo;
    } else {
      poolInfo.slicesInfo.push(sliceInfo);
    }
  }

  function allocateRewards(uint256 _interestPaymentAmount) external override onlyPool nonReentrant {

    if (_interestPaymentAmount > 0) {
      _allocateRewards(_interestPaymentAmount);
    }

    _allocateStakingRewards();
  }

  function setTotalRewards(uint256 _totalRewards) public onlyAdmin {

    totalRewards = _totalRewards;
    uint256 totalGFISupply = config.getGFI().totalSupply();
    totalRewardPercentOfTotalGFI = _totalRewards.mul(GFI_MANTISSA).div(totalGFISupply).mul(100);
    emit BackerRewardsSetTotalRewards(_msgSender(), _totalRewards, totalRewardPercentOfTotalGFI);
  }

  function setTotalInterestReceived(uint256 _totalInterestReceived) public onlyAdmin {

    totalInterestReceived = _totalInterestReceived;
    emit BackerRewardsSetTotalInterestReceived(_msgSender(), _totalInterestReceived);
  }

  function setMaxInterestDollarsEligible(uint256 _maxInterestDollarsEligible) public onlyAdmin {

    maxInterestDollarsEligible = _maxInterestDollarsEligible;
    emit BackerRewardsSetMaxInterestDollarsEligible(_msgSender(), _maxInterestDollarsEligible);
  }

  function setPoolTokenAccRewardsPerPrincipalDollarAtMint(address poolAddress, uint256 tokenId) external override {

    require(_msgSender() == config.poolTokensAddress(), "Invalid sender!");
    require(config.getPoolTokens().validPool(poolAddress), "Invalid pool!");
    if (tokens[tokenId].accRewardsPerPrincipalDollarAtMint != 0) {
      return;
    }
    IPoolTokens poolTokens = config.getPoolTokens();
    IPoolTokens.TokenInfo memory tokenInfo = poolTokens.getTokenInfo(tokenId);
    require(poolAddress == tokenInfo.pool, "PoolAddress must equal PoolToken pool address");

    tokens[tokenId].accRewardsPerPrincipalDollarAtMint = pools[tokenInfo.pool].accRewardsPerPrincipalDollar;
  }

  function onTranchedPoolDrawdown(uint256 sliceIndex) external override onlyPool nonReentrant {

    ITranchedPool pool = ITranchedPool(_msgSender());
    IStakingRewards stakingRewards = _getUpdatedStakingRewards();
    StakingRewardsPoolInfo storage poolInfo = poolStakingRewards[pool];
    ITranchedPool.TrancheInfo memory juniorTranche = _getJuniorTrancheForTranchedPoolSlice(pool, sliceIndex);
    uint256 newRewardsAccumulator = stakingRewards.accumulatedRewardsPerToken();

    bool poolRewardsHaventBeenInitialized = !_poolStakingRewardsInfoHaveBeenInitialized(poolInfo);
    if (poolRewardsHaventBeenInitialized) {
      _updateStakingRewardsPoolInfoAccumulator(poolInfo, newRewardsAccumulator);
    }

    bool isNewSlice = !_sliceRewardsHaveBeenInitialized(pool, sliceIndex);
    if (isNewSlice) {
      ISeniorPool seniorPool = ISeniorPool(config.seniorPoolAddress());
      uint256 principalDeployedAtDrawdown = _getPrincipalDeployedForTranche(juniorTranche);
      uint256 fiduSharePriceAtDrawdown = seniorPool.sharePrice();

      StakingRewardsSliceInfo memory sliceInfo = _initializeStakingRewardsSliceInfo(
        fiduSharePriceAtDrawdown,
        principalDeployedAtDrawdown,
        newRewardsAccumulator
      );

      poolStakingRewards[pool].slicesInfo.push(sliceInfo);
    } else {
      _checkpointSliceStakingRewards(pool, sliceIndex, false);
    }

    _updateStakingRewardsPoolInfoAccumulator(poolInfo, newRewardsAccumulator);
  }

  function poolTokenClaimableRewards(uint256 tokenId) public view returns (uint256) {

    IPoolTokens poolTokens = config.getPoolTokens();
    IPoolTokens.TokenInfo memory tokenInfo = poolTokens.getTokenInfo(tokenId);

    if (_isSeniorTrancheToken(tokenInfo)) {
      return 0;
    }


    uint256 diffOfAccRewardsPerPrincipalDollar = pools[tokenInfo.pool].accRewardsPerPrincipalDollar.sub(
      tokens[tokenId].accRewardsPerPrincipalDollarAtMint
    );
    uint256 rewardsClaimed = tokens[tokenId].rewardsClaimed.mul(GFI_MANTISSA);


    return
      _usdcToAtomic(tokenInfo.principalAmount).mul(diffOfAccRewardsPerPrincipalDollar).sub(rewardsClaimed).div(
        GFI_MANTISSA
      );
  }

  function stakingRewardsClaimed(uint256 tokenId) external view returns (uint256) {

    IPoolTokens poolTokens = config.getPoolTokens();
    IPoolTokens.TokenInfo memory poolTokenInfo = poolTokens.getTokenInfo(tokenId);

    if (_isSeniorTrancheToken(poolTokenInfo)) {
      return 0;
    }

    ITranchedPool pool = ITranchedPool(poolTokenInfo.pool);
    uint256 sliceIndex = _juniorTrancheIdToSliceIndex(poolTokenInfo.tranche);

    if (!_poolRewardsHaveBeenInitialized(pool) || !_sliceRewardsHaveBeenInitialized(pool, sliceIndex)) {
      return 0;
    }

    StakingRewardsPoolInfo memory poolInfo = poolStakingRewards[pool];
    StakingRewardsSliceInfo memory sliceInfo = poolInfo.slicesInfo[sliceIndex];
    StakingRewardsTokenInfo memory tokenInfo = tokenStakingRewards[tokenId];

    uint256 sliceAccumulator = sliceInfo.accumulatedRewardsPerTokenAtDrawdown;
    uint256 tokenAccumulator = _getTokenAccumulatorAtLastWithdraw(tokenInfo, sliceInfo);
    uint256 rewardsPerFidu = tokenAccumulator.sub(sliceAccumulator);
    uint256 principalAsFidu = _fiduToUsdc(poolTokenInfo.principalAmount, sliceInfo.fiduSharePriceAtDrawdown);
    uint256 rewards = principalAsFidu.mul(rewardsPerFidu).div(FIDU_MANTISSA);
    return rewards;
  }

  function withdrawMultiple(uint256[] calldata tokenIds) public {

    require(tokenIds.length > 0, "TokensIds length must not be 0");

    for (uint256 i = 0; i < tokenIds.length; i++) {
      withdraw(tokenIds[i]);
    }
  }

  function withdraw(uint256 tokenId) public whenNotPaused nonReentrant {

    IPoolTokens poolTokens = config.getPoolTokens();
    IPoolTokens.TokenInfo memory tokenInfo = poolTokens.getTokenInfo(tokenId);

    address poolAddr = tokenInfo.pool;
    require(config.getPoolTokens().validPool(poolAddr), "Invalid pool!");
    require(msg.sender == poolTokens.ownerOf(tokenId), "Must be owner of PoolToken");

    BaseUpgradeablePausable pool = BaseUpgradeablePausable(poolAddr);
    require(!pool.paused(), "Pool withdraw paused");

    ITranchedPool tranchedPool = ITranchedPool(poolAddr);
    require(!tranchedPool.creditLine().isLate(), "Pool is late on payments");

    require(!_isSeniorTrancheToken(tokenInfo), "Ineligible senior tranche token");

    uint256 claimableBackerRewards = poolTokenClaimableRewards(tokenId);
    uint256 claimableStakingRewards = stakingRewardsEarnedSinceLastWithdraw(tokenId);
    uint256 totalClaimableRewards = claimableBackerRewards.add(claimableStakingRewards);
    uint256 poolTokenRewardsClaimed = tokens[tokenId].rewardsClaimed;

    tokens[tokenId].rewardsClaimed = poolTokenRewardsClaimed.add(claimableBackerRewards);

    if (claimableStakingRewards != 0) {
      _checkpointTokenStakingRewards(tokenId);
    }

    safeERC20Transfer(config.getGFI(), poolTokens.ownerOf(tokenId), totalClaimableRewards);
    emit BackerRewardsClaimed(_msgSender(), tokenId, claimableBackerRewards, claimableStakingRewards);
  }

  function stakingRewardsEarnedSinceLastWithdraw(uint256 tokenId) public view returns (uint256) {

    IPoolTokens.TokenInfo memory poolTokenInfo = config.getPoolTokens().getTokenInfo(tokenId);
    if (_isSeniorTrancheToken(poolTokenInfo)) {
      return 0;
    }

    ITranchedPool pool = ITranchedPool(poolTokenInfo.pool);
    uint256 sliceIndex = _juniorTrancheIdToSliceIndex(poolTokenInfo.tranche);

    if (!_poolRewardsHaveBeenInitialized(pool) || !_sliceRewardsHaveBeenInitialized(pool, sliceIndex)) {
      return 0;
    }

    StakingRewardsPoolInfo memory poolInfo = poolStakingRewards[pool];
    StakingRewardsSliceInfo memory sliceInfo = poolInfo.slicesInfo[sliceIndex];
    StakingRewardsTokenInfo memory tokenInfo = tokenStakingRewards[tokenId];

    uint256 sliceAccumulator = _getSliceAccumulatorAtLastCheckpoint(sliceInfo, poolInfo);
    uint256 tokenAccumulator = _getTokenAccumulatorAtLastWithdraw(tokenInfo, sliceInfo);
    uint256 rewardsPerFidu = sliceAccumulator.sub(tokenAccumulator);
    uint256 principalAsFidu = _fiduToUsdc(poolTokenInfo.principalAmount, sliceInfo.fiduSharePriceAtDrawdown);
    uint256 rewards = principalAsFidu.mul(rewardsPerFidu).div(FIDU_MANTISSA);
    return rewards;
  }

  function _allocateRewards(uint256 _interestPaymentAmount) internal {

    uint256 _totalInterestReceived = totalInterestReceived;
    if (_usdcToAtomic(_totalInterestReceived) >= maxInterestDollarsEligible) {
      return;
    }

    address _poolAddress = _msgSender();

    uint256 newGrossRewards = _calculateNewGrossGFIRewardsForInterestAmount(_interestPaymentAmount);

    ITranchedPool pool = ITranchedPool(_poolAddress);
    BackerRewardsInfo storage _poolInfo = pools[_poolAddress];

    uint256 totalJuniorDepositsAtomic = _usdcToAtomic(pool.totalJuniorDeposits());

    if (totalJuniorDepositsAtomic < GFI_MANTISSA) {
      emit SafetyCheckTriggered();
      return;
    }

    _poolInfo.accRewardsPerPrincipalDollar = _poolInfo.accRewardsPerPrincipalDollar.add(
      newGrossRewards.mul(GFI_MANTISSA).div(totalJuniorDepositsAtomic)
    );

    totalInterestReceived = _totalInterestReceived.add(_interestPaymentAmount);
  }

  function _allocateStakingRewards() internal {

    ITranchedPool pool = ITranchedPool(_msgSender());

    IV2CreditLine cl = pool.creditLine();
    bool wasFullRepayment = cl.lastFullPaymentTime() > 0 &&
      cl.lastFullPaymentTime() <= block.timestamp &&
      cl.principalOwed() == 0 &&
      cl.interestOwed() == 0;
    if (wasFullRepayment) {
      _checkpointPoolStakingRewards(pool, true);
    }
  }

  function _checkpointPoolStakingRewards(ITranchedPool pool, bool publish) internal {

    IStakingRewards stakingRewards = _getUpdatedStakingRewards();
    uint256 newStakingRewardsAccumulator = stakingRewards.accumulatedRewardsPerToken();
    StakingRewardsPoolInfo storage poolInfo = poolStakingRewards[pool];

    if (newStakingRewardsAccumulator < poolInfo.accumulatedRewardsPerTokenAtLastCheckpoint) {
      emit SafetyCheckTriggered();
      return;
    }

    for (uint256 sliceIndex = 0; sliceIndex < poolInfo.slicesInfo.length; sliceIndex++) {
      _checkpointSliceStakingRewards(pool, sliceIndex, publish);
    }

    _updateStakingRewardsPoolInfoAccumulator(poolInfo, newStakingRewardsAccumulator);
  }

  function _checkpointSliceStakingRewards(
    ITranchedPool pool,
    uint256 sliceIndex,
    bool publish
  ) internal {

    StakingRewardsPoolInfo storage poolInfo = poolStakingRewards[pool];
    StakingRewardsSliceInfo storage sliceInfo = poolInfo.slicesInfo[sliceIndex];
    IStakingRewards stakingRewards = _getUpdatedStakingRewards();
    ITranchedPool.TrancheInfo memory juniorTranche = _getJuniorTrancheForTranchedPoolSlice(pool, sliceIndex);
    uint256 newStakingRewardsAccumulator = stakingRewards.accumulatedRewardsPerToken();

    if (newStakingRewardsAccumulator < poolInfo.accumulatedRewardsPerTokenAtLastCheckpoint) {
      emit SafetyCheckTriggered();
      return;
    }
    uint256 rewardsAccruedSinceLastCheckpoint = newStakingRewardsAccumulator.sub(
      poolInfo.accumulatedRewardsPerTokenAtLastCheckpoint
    );

    bool shouldProRate = block.timestamp > pool.creditLine().termEndTime();
    if (shouldProRate) {
      rewardsAccruedSinceLastCheckpoint = _calculateProRatedRewardsForPeriod(
        rewardsAccruedSinceLastCheckpoint,
        poolInfo.lastUpdateTime,
        block.timestamp,
        pool.creditLine().termEndTime()
      );
    }

    uint256 newPrincipalDeployed = _getPrincipalDeployedForTranche(juniorTranche);

    uint256 deployedScalingFactor = _usdcToAtomic(
      sliceInfo.principalDeployedAtLastCheckpoint.mul(USDC_MANTISSA).div(juniorTranche.principalDeposited)
    );

    uint256 scaledRewardsForPeriod = rewardsAccruedSinceLastCheckpoint.mul(deployedScalingFactor).div(FIDU_MANTISSA);

    sliceInfo.unrealizedAccumulatedRewardsPerTokenAtLastCheckpoint = sliceInfo
      .unrealizedAccumulatedRewardsPerTokenAtLastCheckpoint
      .add(scaledRewardsForPeriod);

    sliceInfo.principalDeployedAtLastCheckpoint = newPrincipalDeployed;
    if (publish) {
      sliceInfo.accumulatedRewardsPerTokenAtLastCheckpoint = sliceInfo
        .unrealizedAccumulatedRewardsPerTokenAtLastCheckpoint;
    }
  }

  function _checkpointTokenStakingRewards(uint256 tokenId) internal {

    IPoolTokens poolTokens = config.getPoolTokens();
    IPoolTokens.TokenInfo memory tokenInfo = poolTokens.getTokenInfo(tokenId);
    require(!_isSeniorTrancheToken(tokenInfo), "Ineligible senior tranche token");

    ITranchedPool pool = ITranchedPool(tokenInfo.pool);
    StakingRewardsPoolInfo memory poolInfo = poolStakingRewards[pool];
    uint256 sliceIndex = _juniorTrancheIdToSliceIndex(tokenInfo.tranche);
    StakingRewardsSliceInfo memory sliceInfo = poolInfo.slicesInfo[sliceIndex];

    uint256 newAccumulatedRewardsPerTokenAtLastWithdraw = _getSliceAccumulatorAtLastCheckpoint(sliceInfo, poolInfo);

    if (
      newAccumulatedRewardsPerTokenAtLastWithdraw <
      tokenStakingRewards[tokenId].accumulatedRewardsPerTokenAtLastWithdraw
    ) {
      emit SafetyCheckTriggered();
      return;
    }

    tokenStakingRewards[tokenId].accumulatedRewardsPerTokenAtLastWithdraw = newAccumulatedRewardsPerTokenAtLastWithdraw;
  }

  function _calculateNewGrossGFIRewardsForInterestAmount(uint256 _interestPaymentAmount)
    internal
    view
    returns (uint256)
  {

    uint256 totalGFISupply = config.getGFI().totalSupply();

    uint256 interestPaymentAmount = _usdcToAtomic(_interestPaymentAmount);

    uint256 _previousTotalInterestReceived = _usdcToAtomic(totalInterestReceived);
    uint256 sqrtOrigTotalInterest = Babylonian.sqrt(_previousTotalInterestReceived);

    uint256 newTotalInterest = _usdcToAtomic(
      _atomicToUsdc(_previousTotalInterestReceived).add(_atomicToUsdc(interestPaymentAmount))
    );

    if (newTotalInterest > maxInterestDollarsEligible) {
      newTotalInterest = maxInterestDollarsEligible;
    }

    uint256 sqrtDiff = Babylonian.sqrt(newTotalInterest).sub(sqrtOrigTotalInterest);
    uint256 sqrtMaxInterestDollarsEligible = Babylonian.sqrt(maxInterestDollarsEligible);

    require(sqrtMaxInterestDollarsEligible > 0, "maxInterestDollarsEligible must not be zero");

    uint256 newGrossRewards = sqrtDiff
      .mul(totalRewardPercentOfTotalGFI)
      .div(sqrtMaxInterestDollarsEligible)
      .div(100)
      .mul(totalGFISupply)
      .div(GFI_MANTISSA);

    uint256 absoluteMaxGfiCheckPerDollar = Babylonian
      .sqrt((uint256)(1).mul(GFI_MANTISSA))
      .mul(totalRewardPercentOfTotalGFI)
      .div(sqrtMaxInterestDollarsEligible)
      .div(100)
      .mul(totalGFISupply)
      .div(GFI_MANTISSA);
    require(
      newGrossRewards < absoluteMaxGfiCheckPerDollar.mul(newTotalInterest),
      "newGrossRewards cannot be greater then the max gfi per dollar"
    );

    return newGrossRewards;
  }

  function _isSeniorTrancheToken(IPoolTokens.TokenInfo memory tokenInfo) internal pure returns (bool) {

    return tokenInfo.tranche.mod(NUM_TRANCHES_PER_SLICE) == 1;
  }

  function _usdcToAtomic(uint256 amount) internal pure returns (uint256) {

    return amount.mul(GFI_MANTISSA).div(USDC_MANTISSA);
  }

  function _atomicToUsdc(uint256 amount) internal pure returns (uint256) {

    return amount.div(GFI_MANTISSA.div(USDC_MANTISSA));
  }

  function _fiduToUsdc(uint256 amount, uint256 sharePrice) internal pure returns (uint256) {

    return _usdcToAtomic(amount).mul(FIDU_MANTISSA).div(sharePrice);
  }

  function _sliceIndexToJuniorTrancheId(uint256 index) internal pure returns (uint256) {

    return index.add(1).mul(2);
  }

  function _juniorTrancheIdToSliceIndex(uint256 trancheId) internal pure returns (uint256) {

    return trancheId.sub(1).div(2);
  }

  function _getUpdatedStakingRewards() internal returns (IStakingRewards) {

    IStakingRewards stakingRewards = IStakingRewards(config.stakingRewardsAddress());
    if (stakingRewards.lastUpdateTime() != block.timestamp) {
      stakingRewards.kick(0);
    }
    return stakingRewards;
  }

  function _poolRewardsHaveBeenInitialized(ITranchedPool pool) internal view returns (bool) {

    StakingRewardsPoolInfo memory poolInfo = poolStakingRewards[pool];
    return _poolStakingRewardsInfoHaveBeenInitialized(poolInfo);
  }

  function _poolStakingRewardsInfoHaveBeenInitialized(StakingRewardsPoolInfo memory poolInfo)
    internal
    pure
    returns (bool)
  {

    return poolInfo.accumulatedRewardsPerTokenAtLastCheckpoint != 0;
  }

  function _sliceRewardsHaveBeenInitialized(ITranchedPool pool, uint256 sliceIndex) internal view returns (bool) {

    StakingRewardsPoolInfo memory poolInfo = poolStakingRewards[pool];
    return
      poolInfo.slicesInfo.length > sliceIndex &&
      poolInfo.slicesInfo[sliceIndex].unrealizedAccumulatedRewardsPerTokenAtLastCheckpoint != 0;
  }

  function _getSliceAccumulatorAtLastCheckpoint(
    StakingRewardsSliceInfo memory sliceInfo,
    StakingRewardsPoolInfo memory poolInfo
  ) internal pure returns (uint256) {

    require(
      poolInfo.accumulatedRewardsPerTokenAtLastCheckpoint != 0,
      "unsafe: pool accumulator hasn't been initialized"
    );
    bool sliceHasNotReceivedAPayment = sliceInfo.accumulatedRewardsPerTokenAtLastCheckpoint == 0;
    return
      sliceHasNotReceivedAPayment
        ? poolInfo.accumulatedRewardsPerTokenAtLastCheckpoint
        : sliceInfo.accumulatedRewardsPerTokenAtLastCheckpoint;
  }

  function _getTokenAccumulatorAtLastWithdraw(
    StakingRewardsTokenInfo memory tokenInfo,
    StakingRewardsSliceInfo memory sliceInfo
  ) internal pure returns (uint256) {

    require(sliceInfo.accumulatedRewardsPerTokenAtDrawdown != 0, "unsafe: slice accumulator hasn't been initialized");
    bool hasNotWithdrawn = tokenInfo.accumulatedRewardsPerTokenAtLastWithdraw == 0;
    if (hasNotWithdrawn) {
      return sliceInfo.accumulatedRewardsPerTokenAtDrawdown;
    } else {
      require(
        tokenInfo.accumulatedRewardsPerTokenAtLastWithdraw >= sliceInfo.accumulatedRewardsPerTokenAtDrawdown,
        "Unexpected token accumulator"
      );
      return tokenInfo.accumulatedRewardsPerTokenAtLastWithdraw;
    }
  }

  function _getJuniorTrancheForTranchedPoolSlice(ITranchedPool pool, uint256 sliceIndex)
    internal
    view
    returns (ITranchedPool.TrancheInfo memory)
  {

    uint256 trancheId = _sliceIndexToJuniorTrancheId(sliceIndex);
    return pool.getTranche(trancheId);
  }

  function _getPrincipalDeployedForTranche(ITranchedPool.TrancheInfo memory tranche) internal pure returns (uint256) {

    return
      tranche.principalDeposited.sub(
        _atomicToUsdc(tranche.principalSharePrice.mul(_usdcToAtomic(tranche.principalDeposited)).div(FIDU_MANTISSA))
      );
  }

  function _initializeStakingRewardsSliceInfo(
    uint256 fiduSharePriceAtDrawdown,
    uint256 principalDeployedAtDrawdown,
    uint256 rewardsAccumulatorAtDrawdown
  ) internal pure returns (StakingRewardsSliceInfo memory) {

    return
      StakingRewardsSliceInfo({
        fiduSharePriceAtDrawdown: fiduSharePriceAtDrawdown,
        principalDeployedAtLastCheckpoint: principalDeployedAtDrawdown,
        accumulatedRewardsPerTokenAtDrawdown: rewardsAccumulatorAtDrawdown,
        accumulatedRewardsPerTokenAtLastCheckpoint: rewardsAccumulatorAtDrawdown,
        unrealizedAccumulatedRewardsPerTokenAtLastCheckpoint: rewardsAccumulatorAtDrawdown
      });
  }

  function _calculateProRatedRewardsForPeriod(
    uint256 rewardsAccruedSinceLastCheckpoint,
    uint256 lastUpdatedTime,
    uint256 currentTime,
    uint256 endTime
  ) internal pure returns (uint256) {

    uint256 slopeNumerator = rewardsAccruedSinceLastCheckpoint.mul(FIDU_MANTISSA);
    uint256 slopeDivisor = currentTime.sub(lastUpdatedTime);

    uint256 slope = slopeNumerator.div(slopeDivisor);
    uint256 span = endTime.sub(lastUpdatedTime);
    uint256 rewards = slope.mul(span).div(FIDU_MANTISSA);
    return rewards;
  }

  function _updateStakingRewardsPoolInfoAccumulator(
    StakingRewardsPoolInfo storage poolInfo,
    uint256 newAccumulatorValue
  ) internal {

    poolInfo.accumulatedRewardsPerTokenAtLastCheckpoint = newAccumulatorValue;
    poolInfo.lastUpdateTime = block.timestamp;
  }


  modifier onlyPool() {

    require(config.getPoolTokens().validPool(_msgSender()), "Invalid pool!");
    _;
  }

  event BackerRewardsClaimed(
    address indexed owner,
    uint256 indexed tokenId,
    uint256 amountOfTranchedPoolRewards,
    uint256 amountOfSeniorPoolRewards
  );
  event BackerRewardsSetTotalRewards(address indexed owner, uint256 totalRewards, uint256 totalRewardPercentOfTotalGFI);
  event BackerRewardsSetTotalInterestReceived(address indexed owner, uint256 totalInterestReceived);
  event BackerRewardsSetMaxInterestDollarsEligible(address indexed owner, uint256 maxInterestDollarsEligible);
}