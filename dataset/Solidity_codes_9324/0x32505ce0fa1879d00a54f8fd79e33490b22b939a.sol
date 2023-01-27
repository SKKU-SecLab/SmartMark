pragma solidity 0.6.12;



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

    function sqrrt(uint256 a) internal pure returns (uint c) {

        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }

    function percentageAmount( uint256 total_, uint8 percentage_ ) internal pure returns ( uint256 percentAmount_ ) {

        return div( mul( total_, percentage_ ), 1000 );
    }

    function percentageOfTotal( uint256 part_, uint256 total_ ) internal pure returns ( uint256 percent_ ) {

        return div( mul(part_, 100) , total_ );
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

    function substractPercentage( uint256 total_, uint8 percentageToSub_ ) internal pure returns ( uint256 result_ ) {

        return sub( total_, div( mul( total_, percentageToSub_ ), 1000 ) );
    }

    function quadraticPricing( uint256 payment_, uint256 multiplier_ ) internal pure returns (uint256) {

        return sqrrt( mul( multiplier_, payment_ ) );
    }

    function bondingCurve( uint256 supply_, uint256 multiplier_ ) internal pure returns (uint256) {

        return mul( multiplier_, supply_ );
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function decimals() external view returns (uint8);

}// MIT

pragma solidity >=0.6.2 <0.8.0;

library SafeAddress {

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}// MIT
pragma solidity 0.6.12;




library SafeERC20 {

    using SafeMath for uint256;
    using SafeAddress for address;

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
}pragma solidity >=0.4.24 <0.7.0;


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
}// AGPL-3.0-or-later
pragma solidity 0.6.12;



contract BlissVault is AccessControlUpgradeSafe {

  
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  event DepositRwardAdded( address indexed rewardToken, address indexed depositToken );
  event LPDeposit( address indexed lpTokenAddress, address indexed rewardTokenAddress, address indexed depositorAddress, uint256 amountDeposited );
  event LPWithdrawal( address indexed lpTokeAddress, address indexed rewardTokenAddress, address indexed depositorAddress, uint256 amountWithdrawn );
  event RewardWithdrawal( address indexed lpTokenAddress, address indexed rewardTokenAddress, address indexed depositorAddress, uint256 amountWithdrawn );

  struct Depositor {
    uint256 _currentDeposit;
    uint256 _totalRewardWithdrawn;
  }

  struct RewardPool {
    bool _initialized;
    uint256 _rewardPoolRewardTokenAllocation;
    uint256 _totalRewardWithdrawn;
    uint256 _totalDeposits;
    mapping( address => Depositor ) _depositorAddressForDepositor;
  }

  struct RewardPoolDistribution {
    bool _initialized;
    uint256 _rewardPoolDistributionTotalAllocation;
    uint256 _totalRewardWithdrawn;
    uint256 _totalPoolShares;
    mapping( address => RewardPool ) _depositTokenForRewardPool;
  }

  address[] public rewards;
  mapping( address => RewardPoolDistribution ) public rewardTokenAddressForRewardPoolDistribution;

  address public devFeeRevenueSplitter;

  uint8 public debtPercentage;

  function initialize() external initializer {

    _addDevAddress(0x5acCa0ab24381eb55F9A15aB6261DF42033eE060);
    debtPercentage = 100; // 10% debt default
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  modifier onlyOwner() {

    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "!owner");
    _;
  }

  function _getRewardPoolDistributionStorage( address _rewardTokenAddress ) internal view returns ( RewardPoolDistribution storage ) {

    return rewardTokenAddressForRewardPoolDistribution[_rewardTokenAddress];
  }

  function _getRewardPoolStorage( RewardPoolDistribution storage _rewardPoolDistribution, address _depositTokenAddress ) internal view returns ( RewardPool storage ) {

    return _rewardPoolDistribution._depositTokenForRewardPool[_depositTokenAddress];
  }

  function _getRewardPoolDistributionAndRewardPoolStorage( address _rewardTokenAddress, address _depositTokenAddress ) internal view returns ( RewardPoolDistribution storage, RewardPool storage ) {

    RewardPoolDistribution storage _rewardPoolDistribution = _getRewardPoolDistributionStorage( _rewardTokenAddress );
    RewardPool storage _rewardPool = _getRewardPoolStorage( _rewardPoolDistribution, _depositTokenAddress );
    return ( _rewardPoolDistribution, _rewardPool );
  }

  function _getDepositorStorage( RewardPool storage _rewardPool, address _depositorAddress ) internal view returns ( Depositor storage ) {

    return _rewardPool._depositorAddressForDepositor[ _depositorAddress ];
  }

  function _getRewardPoolDistributionAndRewardPoolAndDepositorStorage( address _rewardTokenAddress, address _depositTokenAddress, address _depositorAddress ) internal view returns ( RewardPoolDistribution storage, RewardPool storage, Depositor storage ) {

    RewardPoolDistribution storage _rewardPoolDistribution = _getRewardPoolDistributionStorage( _rewardTokenAddress );
    RewardPool storage _rewardPool = _getRewardPoolStorage( _rewardPoolDistribution, _depositTokenAddress );
    Depositor storage _depositor = _getDepositorStorage( _rewardPool, _depositorAddress );
    return ( _rewardPoolDistribution, _rewardPool, _depositor );
  }

  function _calculatePercentageShare( uint256 _shares, uint256 _rewardDecimalsExponentiated, uint256 _totalShares ) internal pure returns ( uint256 ) {

    return _shares
      .mul( _rewardDecimalsExponentiated )
      .percentageOfTotal( _totalShares );
  }

  function _getRewardTokenDecimals( address _rewardTokenAddress ) internal view returns ( uint256 ) {

    return IERC20( _rewardTokenAddress ).decimals();
  }

  function _getRewardTokenExponent( address _rewardTokenAddress, address _rewardPoolDepositTokenAddress ) internal view returns ( uint256 ) {

    uint256 _rewardTokenDecimalsExponent = _getRewardTokenDecimals( _rewardTokenAddress );

    if( _rewardPoolDepositTokenAddress == address(this)) {
      return _rewardTokenDecimalsExponent;
    } else {
      uint256 _depostTokenDecimalsExponent = _getRewardTokenDecimals( _rewardPoolDepositTokenAddress );
      return _rewardTokenDecimalsExponent < _depostTokenDecimalsExponent ? 10 ** (_depostTokenDecimalsExponent.sub( _rewardTokenDecimalsExponent )): 1;
    }
  }

  function _getRewardDueToDepositor(
    uint256 _totalRewardAvailable,
    uint256 _exponent,
    uint256 _totalDeposits, 
    uint256 _depositorCurrentDeposit, 
    uint256 _depositorTotalRewardWithdrawn
  ) internal pure returns ( uint256 ) {

    if( _totalDeposits == 0 ) {
      return 0;
    }

    uint256 _percentageOfShares = _calculatePercentageShare( _depositorCurrentDeposit, _exponent , _totalDeposits );

    _totalRewardAvailable = _totalRewardAvailable
      .add( _depositorTotalRewardWithdrawn )
      .mul( _percentageOfShares )
      .div( _exponent )
      .div( 100 ); // account for the extra 100 from the percentageOfTotal call

    return _totalRewardAvailable > _depositorTotalRewardWithdrawn ? _totalRewardAvailable.sub( _depositorTotalRewardWithdrawn ) : 0;
  }

  function _getRewardDueToRewardPool(
    uint256 _exponent,
    uint256 _depositorShares,
    address _rewardTokenAddress,
    uint256 _poolAllocation,
    uint256 _totalAllocation,
    uint256 _totalRewardWithdrawn
  ) internal view returns ( uint256 ) {

    if( _depositorShares == 0 ) {
      return 0;
    }

    uint256 _percentageOfAllocation = _calculatePercentageShare( _poolAllocation, _exponent , _totalAllocation );

    uint256 _rewardTokenBalance = IERC20( _rewardTokenAddress ).balanceOf( address( this ) );

    uint256 _baseReward = _rewardTokenBalance
      .add( _totalRewardWithdrawn )
      .mul( _percentageOfAllocation )
      .div( _exponent )
      .div( 100 ); // account for the extra 10000 from the percentageOfTotal call










    return _baseReward > _totalRewardWithdrawn ? _baseReward.sub( _totalRewardWithdrawn ) : 0;
  }

  function _calculateRewardWithdrawalForDepositor( 
    RewardPoolDistribution storage _rewardPoolDistribution,
    RewardPool storage _rewardPool,
    Depositor storage _depositor,
    uint256 _exponent,
    address _rewardTokenAddress
  ) internal view returns ( uint256 ) {









    uint256 _poolDebt = _rewardPool._totalRewardWithdrawn.percentageAmount( debtPercentage );

    uint256 _rewardTokenAmountAvailableForPool = _getRewardDueToRewardPool(
      _exponent,
      _depositor._currentDeposit,
      _rewardTokenAddress,
      _rewardPool._rewardPoolRewardTokenAllocation,
      _rewardPoolDistribution._rewardPoolDistributionTotalAllocation,
      _poolDebt
    );


    return _getRewardDueToDepositor(
      _rewardTokenAmountAvailableForPool,
      _exponent,
      _rewardPool._totalDeposits,
      _depositor._currentDeposit,
      _depositor._totalRewardWithdrawn
    );
  }

  function getRewardDueToDepositor( address _rewardTokenAddress, address _depositTokenAddress, address _depositorAddress ) external view returns ( uint256 ) {

    (
      RewardPoolDistribution storage _rewardPoolDistribution,
      RewardPool storage _rewardPool,
      Depositor storage _depositor
    ) = _getRewardPoolDistributionAndRewardPoolAndDepositorStorage( _rewardTokenAddress, _depositTokenAddress, _depositorAddress );

    uint256 _exponent = _getRewardTokenExponent( _rewardTokenAddress, _depositTokenAddress );

    return _calculateRewardWithdrawalForDepositor( _rewardPoolDistribution, _rewardPool, _depositor, _exponent, _rewardTokenAddress );
  }

  function getRewardPoolDistribution(address _rewardTokenAddress) external view returns (
    bool rewardPoolDistributionInitialized,
    uint256 rewardPoolDistributionTotalRewardWithdrawn,
    uint256 rewardPoolDistributionTotalPoolShares,
    uint256 rewardPoolDistributionTotalAllocation
  ) {

    RewardPoolDistribution storage _rewardPoolDistribution =
      _getRewardPoolDistributionStorage( _rewardTokenAddress );

    return (
      _rewardPoolDistribution._initialized,
      _rewardPoolDistribution._totalRewardWithdrawn,
      _rewardPoolDistribution._totalPoolShares,
      _rewardPoolDistribution._rewardPoolDistributionTotalAllocation
    );
  }

  function getRewardPool( 
    address _rewardTokenAddress,
    address _depositTokenAddress,
    address _depositorAddress 
  ) external view returns (
    bool rewardPoolInitialized,
    uint256 rewardPoolTotalWithdrawn,
    uint256 rewardPoolTotalDeposits,
    uint256 rewardPoolRewardTokenAllocation,
    uint256 depositorCurrentDeposits,
    uint256 depositorTotalRewardWithdrawn,
    uint256 vaultRewardTokenBalance,
    uint256 poolDebt
  ) {

    ( ,
      RewardPool storage _rewardPool,
      Depositor storage _depositor
    ) = _getRewardPoolDistributionAndRewardPoolAndDepositorStorage( _rewardTokenAddress, _depositTokenAddress, _depositorAddress );

    uint256 _vaultRewardTokenBalance = IERC20( _rewardTokenAddress ).balanceOf( address( this ) );
    uint256 _poolDebt = _rewardPool._totalRewardWithdrawn.percentageAmount( debtPercentage );

    return (
      _rewardPool._initialized,
      _rewardPool._totalRewardWithdrawn,
      _rewardPool._totalDeposits,
      _rewardPool._rewardPoolRewardTokenAllocation,
      _depositor._currentDeposit,
      _depositor._totalRewardWithdrawn,
      _vaultRewardTokenBalance,
      _poolDebt
    );
  }

  function _withdrawDeposit(
    address _depositorAddress,
    uint _amountToWithdraw,
    address _rewardTokenAddress,
    address _depositTokenAddress,
    bool _exitPool
  ) internal {

    ( RewardPoolDistribution storage _rewardPoolDistribution,
      RewardPool storage _rewardPool,
      Depositor storage _depositor
    ) = _getRewardPoolDistributionAndRewardPoolAndDepositorStorage( _rewardTokenAddress, _depositTokenAddress, _depositorAddress );

    _amountToWithdraw = _exitPool ? _depositor._currentDeposit : _amountToWithdraw;




    require( _amountToWithdraw != 0, "Cannot withdraw 0 amount");
    require( _depositor._currentDeposit >= _amountToWithdraw, "Cannot withdraw more than current deposit amount." );

    uint256 _exponent = _getRewardTokenExponent( _rewardTokenAddress, _depositTokenAddress );
    _withdrawRewards( _rewardPoolDistribution, _rewardPool, _depositor, _exponent, _depositTokenAddress, _rewardTokenAddress );

    _depositor._currentDeposit = _depositor._currentDeposit.sub( _amountToWithdraw );
    _rewardPool._totalDeposits = _rewardPool._totalDeposits.sub( _amountToWithdraw );
    _rewardPoolDistribution._totalPoolShares = _rewardPoolDistribution._totalPoolShares.sub( _amountToWithdraw );

    IERC20( _depositTokenAddress).safeTransfer( _depositorAddress, _amountToWithdraw );
  }

  function withdrawDeposit( 
    address _rewardTokenAddress,
    address _depositTokenAddress,
    uint _amountToWithdraw
  ) external {

    _withdrawDeposit( msg.sender, _amountToWithdraw, _rewardTokenAddress, _depositTokenAddress, false );
  }

  function withdrawDepositAndRewards( address _rewardTokenAddress, address _depositTokenAddress ) external {

    _withdrawDeposit( msg.sender, 0, _rewardTokenAddress, _depositTokenAddress, true );
  }

  function _withdrawRewards( 
    RewardPoolDistribution storage _rewardPoolDistribution,
    RewardPool storage _rewardPool,
    Depositor storage _depositor,
    uint256 _exponent,
    address _depositTokenAddress,
    address _rewardTokenAddress
  ) internal returns ( 
    uint256
  ) {

    
    uint256 _rewardDue =  _calculateRewardWithdrawalForDepositor( _rewardPoolDistribution, _rewardPool, _depositor, _exponent, _rewardTokenAddress );

    require( _rewardPoolDistribution._initialized, "Reward pool distribution is currently not enabled." );

    if( _rewardDue > 0 ) {
      _depositor._totalRewardWithdrawn = _depositor._totalRewardWithdrawn.add( _rewardDue );
      _rewardPool._totalRewardWithdrawn = _rewardPool._totalRewardWithdrawn.add( _rewardDue );
      _rewardPoolDistribution._totalRewardWithdrawn = _rewardPoolDistribution._totalRewardWithdrawn.add( _rewardDue );
      IERC20( _rewardTokenAddress ).safeTransfer( msg.sender, _rewardDue );
      emit RewardWithdrawal( _depositTokenAddress, _rewardTokenAddress, msg.sender, _rewardDue );
    }
    return _rewardDue;
  }

  function withdrawRewards( 
    address _depositTokenAddress,
    address _rewardTokenAddress
  ) external returns ( uint256 ) {

    (
      RewardPoolDistribution storage _rewardPoolDistribution,
      RewardPool storage _rewardPool,
      Depositor storage _depositor
    ) = _getRewardPoolDistributionAndRewardPoolAndDepositorStorage( _rewardTokenAddress, _depositTokenAddress, msg.sender );
    uint256 _exponent = _getRewardTokenExponent( _rewardTokenAddress, _depositTokenAddress );
    return _withdrawRewards( _rewardPoolDistribution, _rewardPool, _depositor, _exponent, _depositTokenAddress, _rewardTokenAddress );
  }

  function _deposit( address _depositTokenAddress, address _rewardTokenAddress, uint256 _amountToDeposit ) internal returns ( uint256 ) {

    (
      RewardPoolDistribution storage _rewardPoolDistribution,
      RewardPool storage _rewardPool,
      Depositor storage _depositor
    )  = _getRewardPoolDistributionAndRewardPoolAndDepositorStorage( _rewardTokenAddress, _depositTokenAddress, msg.sender );

    require( _rewardPool._initialized, "Deposits not enabled for this pool." );
    require( IERC20( _depositTokenAddress ).balanceOf( msg.sender ) >= _amountToDeposit, "Message sender does not have enough to deposit." );
    require( IERC20( _depositTokenAddress ).allowance( msg.sender, address( this ) ) >= _amountToDeposit, "Message sender has not approved sufficient allowance for this contract." );

    IERC20( _depositTokenAddress ).safeTransferFrom( msg.sender, address( this ), _amountToDeposit );

    uint256 _exponent = _getRewardTokenExponent( _rewardTokenAddress, _depositTokenAddress );
    _withdrawRewards( _rewardPoolDistribution, _rewardPool, _depositor, _exponent, _depositTokenAddress, _rewardTokenAddress );

    _depositor._currentDeposit = _depositor._currentDeposit.add( _amountToDeposit );
    _rewardPool._totalDeposits = _rewardPool._totalDeposits.add( _amountToDeposit );

    _rewardPoolDistribution._totalPoolShares = _rewardPoolDistribution._totalPoolShares.add( _amountToDeposit );


    return _depositor._currentDeposit;
  }

  function deposit( address _depositToken, address _rewardTokenAddress, uint256 _amountToDeposit ) external returns ( uint256 ) {

    return _deposit( _depositToken, _rewardTokenAddress, _amountToDeposit );
  }

  function _removeDev( address[] storage _values, address value) private returns (bool) {

        uint256 valueIndex = devsIndex[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = _values.length - 1;


            address lastvalue = _values[lastIndex];

            _values[toDeleteIndex] = lastvalue;
            devsIndex[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            _values.pop();

            delete devsIndex[value];

            return true;
        } else {
            return false;
        }
  }

  function _getRewardPoolAndDepositorStorageFromDistribution( RewardPoolDistribution storage _rewardPoolDistribution, address _depositTokenAddress, address _depositorAddress ) internal view returns ( RewardPool storage, Depositor storage ) {

    RewardPool storage _rewardPool = _getRewardPoolStorage( _rewardPoolDistribution, _depositTokenAddress );
    Depositor storage _depositor = _getDepositorStorage( _rewardPool, _depositorAddress );
    return ( _rewardPool, _depositor );
  }

  address[] public devs;
  mapping( address => uint256 ) devsIndex;
  mapping( address => bool ) public activeDev;

  function changeDevAddress( address _newDevAddress ) external {

    require( activeDev[msg.sender] == true );
    _removeDev( devs, msg.sender );
    _addDevAddress( _newDevAddress );
    for( uint256 _iteration; rewards.length > _iteration; _iteration++ ) {
      (
        RewardPoolDistribution storage _rewardPoolDistribution,
        RewardPool storage _devRewardPool,
        Depositor storage _devDepositor
      ) = _getRewardPoolDistributionAndRewardPoolAndDepositorStorage( rewards[_iteration], address(this), msg.sender );

      uint256 _exponent = _getRewardTokenExponent( rewards[_iteration], address(this) );

      _devRewardPool._totalDeposits = _devRewardPool._totalDeposits.sub( _devDepositor._currentDeposit );
      _devDepositor._currentDeposit = 0;

      _addDevDepositor(
        _rewardPoolDistribution,
        _exponent
      );
    }
  }

  function _addDevAddress( address _newDev ) internal {

    devs.push(_newDev);
    devsIndex[_newDev] = devs.length;
    activeDev[_newDev] = true;
  }

  function withdrawDevRewards( 
    address _rewardTokenAddress
  ) external returns ( uint256 ) {

    require( activeDev[msg.sender] == true );
    (
      RewardPoolDistribution storage _rewardPoolDistribution,
      RewardPool storage _rewardPool,
      Depositor storage _depositor
    ) = _getRewardPoolDistributionAndRewardPoolAndDepositorStorage( _rewardTokenAddress, address(this), msg.sender );
    uint256 _exponent = _getRewardTokenExponent( _rewardTokenAddress, address(this) );
    return _withdrawRewards( _rewardPoolDistribution, _rewardPool, _depositor, _exponent, address(this), _rewardTokenAddress );
  }

  function _addDevDepositor(
    RewardPoolDistribution storage _rewardPoolDistribution,
    uint256 _exponent
   ) internal {

     for( uint256 _iteration = 0; devs.length > _iteration; _iteration++ ) {
      (
        RewardPool storage _devRewardPool,
        Depositor storage _devDepositor
      )  = _getRewardPoolAndDepositorStorageFromDistribution( _rewardPoolDistribution, address(this) , devs[_iteration] );

      if( _devDepositor._currentDeposit > 0 ){
        break;
      } else {
        _devRewardPool._totalDeposits = 2 * (10 **_exponent);
        _devDepositor._currentDeposit = 1 * (10 **_exponent);

        _devRewardPool._initialized = true;
        _setPoolAllocation(_rewardPoolDistribution, _devRewardPool, 1);
        _rewardPoolDistribution._depositTokenForRewardPool[address(this)] = _devRewardPool;
      }
    }
   }

  function _enablePool( address _depositToken, address _rewardTokenAddress, bool _initializeRewardPool, bool _initializeRewardPoolDistribution, uint256 _rewardPoolRewardTokenAllocation ) internal {

    (
      RewardPoolDistribution storage _rewardPoolDistribution,
      RewardPool storage _rewardPool
    ) = _getRewardPoolDistributionAndRewardPoolStorage( _rewardTokenAddress, _depositToken);

    rewards.push( _rewardTokenAddress );

    uint256 _exponent = _getRewardTokenExponent( _rewardTokenAddress, address(this) );

    _addDevDepositor(
      _rewardPoolDistribution,
      _exponent
    );

    require( _rewardPool._initialized != _initializeRewardPool, "Pool is already set that way." );

    _rewardPool._initialized = _initializeRewardPool;
    _rewardPoolDistribution._initialized = _initializeRewardPoolDistribution;
    _setPoolAllocation(_rewardPoolDistribution, _rewardPool, _rewardPoolRewardTokenAllocation);
    _rewardPoolDistribution._depositTokenForRewardPool[_depositToken] = _rewardPool;
  }

  function setPoolAllocation( address _depositToken, address _rewardTokenAddress, uint256 _rewardPoolRewardTokenAllocation ) external onlyOwner() {

    (
      RewardPoolDistribution storage _rewardPoolDistribution,
      RewardPool storage _rewardPool
    ) = _getRewardPoolDistributionAndRewardPoolStorage( _rewardTokenAddress, _depositToken);
    _setPoolAllocation( _rewardPoolDistribution, _rewardPool, _rewardPoolRewardTokenAllocation );
  }

  function _setPoolAllocation(RewardPoolDistribution storage _rewardPoolDistribution, RewardPool storage _rewardPool, uint256 _rewardPoolRewardTokenAllocation) internal {

    _rewardPoolDistribution._rewardPoolDistributionTotalAllocation = _rewardPoolDistribution._rewardPoolDistributionTotalAllocation.sub( _rewardPool._rewardPoolRewardTokenAllocation );
    _rewardPoolDistribution._rewardPoolDistributionTotalAllocation = _rewardPoolDistribution._rewardPoolDistributionTotalAllocation.add( _rewardPoolRewardTokenAllocation );
    _rewardPool._rewardPoolRewardTokenAllocation = _rewardPoolRewardTokenAllocation;
  }

  function setDebtPercentage( uint256 _debtPercentage ) external onlyOwner() {

    require(_debtPercentage <= 1000, "Cannot set pool debt to more than 100 percent");
    debtPercentage = uint8(_debtPercentage);
  }

  function enablePool( address _depositToken, address _rewardTokenAddress, bool _initializeRewardPool, bool _initializeRewardPoolDistribution, uint256 _rewardPoolRewardTokenAllocation ) external onlyOwner() {

    _enablePool( _depositToken, _rewardTokenAddress, _initializeRewardPool, _initializeRewardPoolDistribution, _rewardPoolRewardTokenAllocation );
  }

  function enablePools(
      address[] calldata _depositTokens,
      address[] calldata _rewardTokenAddresses,
      bool[] calldata _rewardPoolInitializations,
      bool[] calldata _rewardPoolDistributionInitializations,
      uint256[] calldata _rewardPoolRewardTokenAllocation
  ) external onlyOwner() {

    require(
      _depositTokens.length > 0
      && _depositTokens.length == _rewardTokenAddresses.length
      && _depositTokens.length == _rewardPoolInitializations.length
      && _rewardTokenAddresses.length == _rewardPoolInitializations.length
      && _rewardPoolInitializations.length == _rewardPoolDistributionInitializations.length
      && _rewardPoolDistributionInitializations.length == _depositTokens.length
      && _rewardPoolDistributionInitializations.length == _rewardTokenAddresses.length
      , "There must be the same number of addresses for lp token, reward token, and initializations."
    );

    for( uint256 _iteration = 0; _depositTokens.length > _iteration; _iteration++ ) {
      _enablePool(
        _depositTokens[_iteration],
        _rewardTokenAddresses[_iteration],
        _rewardPoolInitializations[_iteration],
        _rewardPoolDistributionInitializations[_iteration],
        _rewardPoolRewardTokenAllocation[_iteration]
      );
    }
  }

  function _enableRewardPoolDistribution(address _rewardToken, bool _initialize) internal {

    RewardPoolDistribution storage _rewardPoolDistribution = _getRewardPoolDistributionStorage(_rewardToken);
    require( _rewardPoolDistribution._initialized != _initialize, "Pool is already set that way." );

    _rewardPoolDistribution._initialized = _initialize;
  }

  function enableRewardPoolDistribution( address _rewardToken, bool _initialize ) external onlyOwner() {

    _enableRewardPoolDistribution( _rewardToken, _initialize );
  }

  function transferFundsFromOldVault( address _rewardTokenAddress, address _oldVault, uint256 _amount ) external onlyOwner() {

    IERC20( _rewardTokenAddress ).safeTransferFrom( _oldVault, address( this ), _amount );
  }
}