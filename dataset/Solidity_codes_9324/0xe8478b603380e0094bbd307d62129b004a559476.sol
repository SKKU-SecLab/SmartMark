
pragma solidity ^0.6.2;

library Address {

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.6.0;

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
}// MIT

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity >=0.6.8;

interface ICollectableDust {

  event DustSent(address _to, address token, uint256 amount);

  function sendDust(address _to, address _token, uint256 _amount) external;

}// MIT

pragma solidity >=0.6.8;



abstract
contract CollectableDust is ICollectableDust {

  using EnumerableSet for EnumerableSet.AddressSet;

  address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  EnumerableSet.AddressSet internal protocolTokens;

  constructor() public {}

  function _addProtocolToken(address _token) internal {

    require(!protocolTokens.contains(_token), 'collectable-dust/token-is-part-of-the-protocol');
    protocolTokens.add(_token);
  }

  function _removeProtocolToken(address _token) internal {

    require(protocolTokens.contains(_token), 'collectable-dust/token-not-part-of-the-protocol');
    protocolTokens.remove(_token);
  }

  function _sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) internal {

    require(_to != address(0), 'collectable-dust/cant-send-dust-to-zero-address');
    require(!protocolTokens.contains(_token), 'collectable-dust/token-is-part-of-the-protocol');
    if (_token == ETH_ADDRESS) {
      payable(_to).transfer(_amount);
    } else {
      IERC20(_token).transfer(_to, _amount);
    }
    emit DustSent(_to, _token, _amount);
  }
}// MIT

pragma solidity ^0.6.0;

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
}// MIT

pragma solidity ^0.6.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

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
}// MIT
pragma solidity >=0.6.8;

interface IZTreasuryV2Metadata {

  function isZTreasury() external pure returns (bool);

}// MIT
pragma solidity >=0.6.8;


interface zGovernance {

  function notifyRewardAmount(uint) external;

}

interface IZTreasuryV2ProtocolParameters {

  event ZGovSet(address zGov);
  event LotManagerSet(address lotManager);
  event MaintainerSet(address maintainer);
  event ZTokenSet(address zToken);
  event SharesSet(uint256 maintainerShare, uint256 governanceShare);

  function zToken() external returns (IERC20);


  function zGov() external returns (zGovernance);

  function lotManager() external returns (address);

  function maintainer() external returns (address);


  function SHARES_PRECISION() external returns (uint256);

  function MAX_MAINTAINER_SHARE() external returns (uint256);

  function maintainerShare() external returns (uint256);

  function governanceShare() external returns (uint256);


  function setZGov(address _zGov) external;

  function setLotManager(address _lotManager) external;

  function setMaintainer(address _maintainer) external;

  function setZToken(address _zToken) external;

  function setShares(uint256 _maintainerShare, uint256 _governanceShare) external;

}// MIT
pragma solidity >=0.6.8;


interface IZTreasuryV2 is IZTreasuryV2ProtocolParameters, IZTreasuryV2Metadata {

  event EarningsDistributed(
    uint256 maintainerRewards, 
    uint256 governanceRewards, 
    uint256 totalEarningsDistributed
  );

  function lastEarningsDistribution() external returns (uint256);

  function totalEarningsDistributed() external returns (uint256);

  function distributeEarnings() external;

}// MIT
pragma solidity >=0.6.8;

interface IGovernable {

  event PendingGovernorSet(address pendingGovernor);
  event GovernorAccepted();

  function setPendingGovernor(address _pendingGovernor) external;

  function acceptGovernor() external;

}// MIT

pragma solidity >=0.6.8;


abstract
contract Governable is IGovernable {

  address public governor;
  address public pendingGovernor;

  constructor(address _governor) public {
    require(_governor != address(0), 'governable/governor-should-not-be-zero-address');
    governor = _governor;
  }

  function _setPendingGovernor(address _pendingGovernor) internal {

    require(_pendingGovernor != address(0), 'governable/pending-governor-should-not-be-zero-addres');
    pendingGovernor = _pendingGovernor;
    emit PendingGovernorSet(_pendingGovernor);
  }

  function _acceptGovernor() internal {

    governor = pendingGovernor;
    pendingGovernor = address(0);
    emit GovernorAccepted();
  }

  modifier onlyGovernor {

    require(msg.sender == governor, 'governable/only-governor');
    _;
  }

  modifier onlyPendingGovernor {

    require(msg.sender == pendingGovernor, 'governable/only-pending-governor');
    _;
  }
}// MIT
pragma solidity >=0.6.8;

interface IManageable {

  event PendingManagerSet(address pendingManager);
  event ManagerAccepted();

  function setPendingManager(address _pendingManager) external;

  function acceptManager() external;

}// MIT

pragma solidity >=0.6.8;


abstract
contract Manageable is IManageable {

  address public manager;
  address public pendingManager;

  constructor(address _manager) public {
    require(_manager != address(0), 'manageable/manager-should-not-be-zero-address');
    manager = _manager;
  }

  function _setPendingManager(address _pendingManager) internal {

    require(_pendingManager != address(0), 'manageable/pending-manager-should-not-be-zero-addres');
    pendingManager = _pendingManager;
    emit PendingManagerSet(_pendingManager);
  }

  function _acceptManager() internal {

    manager = pendingManager;
    pendingManager = address(0);
    emit ManagerAccepted();
  }

  modifier onlyManager {

    require(msg.sender == manager, 'manageable/only-manager');
    _;
  }

  modifier onlyPendingManager {

    require(msg.sender == pendingManager, 'manageable/only-pending-manager');
    _;
  }
}// MIT

pragma solidity >=0.6.8;



contract zTreasuryV2Metadata is IZTreasuryV2Metadata {

  function isZTreasury() external override pure returns (bool) {

    return true;
  }
}// MIT
pragma solidity >=0.6.8;

interface ILotManagerMetadata {

  function isLotManager() external pure returns (bool);

  function getName() external pure returns (string memory);

}// MIT

pragma solidity >=0.6.8;



abstract
contract zTreasuryV2ProtocolParameters is IZTreasuryV2ProtocolParameters {

  using SafeMath for uint256;
  
  uint256 public constant override SHARES_PRECISION = 10000;
  uint256 public constant override MAX_MAINTAINER_SHARE = 25 * SHARES_PRECISION;

  IERC20 public override zToken; // zhegic
  zGovernance public override zGov; // zgov

  address public override lotManager;
  address public override maintainer;

  uint256 public override maintainerShare;
  uint256 public override governanceShare;
  
  constructor(
    address _zGov,
    address _lotManager,
    address _maintainer,
    address _zToken,
    uint256 _maintainerShare,
    uint256 _governanceShare
  ) public {
    _setZGov(_zGov);
    _setLotManager(_lotManager);
    _setMaintainer(_maintainer);
    _setZToken(_zToken);
    _setShares(_maintainerShare, _governanceShare);
  }
  
  function _setZGov(address _zGov) internal {

    require(_zGov != address(0), 'zTreasuryV2ProtocolParameters::_setZGov::no-zero-address');
    zGov = zGovernance(_zGov);
    emit ZGovSet(_zGov);
  }

  function _setLotManager(address _lotManager) internal {

    require(_lotManager != address(0), 'zTreasuryV2ProtocolParameters::_setLotManager::no-zero-address');
    require(ILotManagerMetadata(_lotManager).isLotManager(), 'zTreasuryV2ProtocolParameters::_setLotManager::not-lot-manager');
    lotManager = _lotManager;
    emit LotManagerSet(_lotManager);
  }

  function _setMaintainer(address _maintainer) internal {

    require(_maintainer != address(0), 'zTreasuryV2ProtocolParameters::_setMaintainer::no-zero-address');
    maintainer = _maintainer;
    emit MaintainerSet(_maintainer);
  }

  function _setZToken(address _zToken) internal {

    require(_zToken != address(0), 'zTreasuryV2ProtocolParameters::_setZToken::no-zero-address');
    zToken = IERC20(_zToken);
    emit ZTokenSet(_zToken);
  }

  function _setShares(uint256 _maintainerShare, uint256 _governanceShare) internal {

    require(_maintainerShare.add(_governanceShare) == SHARES_PRECISION.mul(100), 'zTreasuryV2ProtocolParameters::_setShares::not-100-percent');
    require(_maintainerShare <= MAX_MAINTAINER_SHARE, 'zTreasuryV2ProtocolParameters::_setShares::exceeds-max-mantainer-share');
    maintainerShare = _maintainerShare;
    governanceShare = _governanceShare;
    emit SharesSet(_maintainerShare, _governanceShare);
  }
}// MIT

pragma solidity >=0.6.8;





contract zTreasuryV2 is 
  Governable, 
  Manageable,
  CollectableDust,
  zTreasuryV2Metadata,
  zTreasuryV2ProtocolParameters, 
  IZTreasuryV2 {


  using SafeERC20 for IERC20;

  uint256 public override lastEarningsDistribution = 0;
  uint256 public override totalEarningsDistributed = 0;
  
  constructor(
    address _governor,
    address _manager,
    address _zGov,
    address _lotManager,
    address _maintainer,
    address _zToken,
    uint256 _maintainerShare,
    uint256 _governanceShare,
    uint256[] memory _initialDistributionValues
  ) public 
    zTreasuryV2ProtocolParameters(
      _zGov,
      _lotManager,
      _maintainer, 
      _zToken,
      _maintainerShare,
      _governanceShare
    )
    Governable(_governor)
    Manageable(_manager)
    CollectableDust() {
      lastEarningsDistribution = _initialDistributionValues[0];
      totalEarningsDistributed = _initialDistributionValues[1];
      _addProtocolToken(_zToken);
  }

  modifier onlyManagerOrLotManager {

    require(msg.sender == manager || msg.sender == lotManager, 'zTreasuryV2::only-manager-or-lot-manager');
    _;
  }
  
  function distributeEarnings() external override onlyManagerOrLotManager {

    uint256 _balance = zToken.balanceOf(address(this));
    
    uint256 _maintainerEarnings = _balance.mul(maintainerShare).div(SHARES_PRECISION).div(100);
    zToken.safeTransfer(maintainer, _maintainerEarnings);

    uint256 _governanceEarnings = _balance.sub(_maintainerEarnings);
    zToken.safeApprove(address(zGov), 0);
    zToken.safeApprove(address(zGov), _governanceEarnings);

    zGov.notifyRewardAmount(_governanceEarnings);

    lastEarningsDistribution = block.timestamp;
    totalEarningsDistributed = totalEarningsDistributed.add(_balance);

    emit EarningsDistributed(_maintainerEarnings, _governanceEarnings, totalEarningsDistributed);
  }

  function setZGov(address _zGov) external override onlyGovernor {

    _setZGov(_zGov);
  }

  function setLotManager(address _lotManager) external override onlyGovernor {

    _setLotManager(_lotManager);
  }

  function setMaintainer(address _maintainer) external override onlyGovernor {

    _setMaintainer(_maintainer);
  }

  function setZToken(address _zToken) external override onlyGovernor {

    require(address(zToken) != _zToken, 'zTreasuryV2::setZToken::same-ztoken');
    _removeProtocolToken(address(zToken));
    _addProtocolToken(address(_zToken));
    _setZToken(_zToken);
  }

  function setShares(uint256 _maintainerShare, uint256 _governanceShare) external override onlyGovernor {

    _setShares(_maintainerShare, _governanceShare);
  }

  function setPendingGovernor(address _pendingGovernor) external override onlyGovernor {

    _setPendingGovernor(_pendingGovernor);
  }

  function acceptGovernor() external override onlyPendingGovernor {

    _acceptGovernor();
  }

  function setPendingManager(address _pendingManager) external override onlyManager {

    _setPendingManager(_pendingManager);
  }

  function acceptManager() external override onlyPendingManager {

    _acceptManager();
  }

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external override onlyGovernor {

    _sendDust(_to, _token, _amount);
  }
}// MIT
pragma solidity >=0.6.8;

interface IHegicPoolMetadata {

  function isHegicPool() external pure returns (bool);

  function getName() external pure returns (string memory);

}// MIT
pragma solidity >=0.6.8;

interface IHegicPoolProtocolParameters {

  event MinTokenReservesSet(uint256 minTokenReserves);
  event WithdrawCooldownSet(uint256 withdrawCooldown);
  event WidthawFeeSet(uint256 withdrawFee);
  function setMinTokenReserves(uint256 minTokenReserves) external;

  function setWithdrawCooldown(uint256 withdrawCooldown) external;

  function setWithdrawFee(uint256 withdrawFee) external;

}// MIT
pragma solidity >=0.6.8;



interface IHegicPoolV2 is
  IGovernable,
  IManageable,
  ICollectableDust,
  IHegicPoolMetadata,
  IHegicPoolProtocolParameters {


  event LotManagerSet(address lotManager);
  event PoolMigrated(address pool, uint256 balance);

  event RewardsClaimed(uint256 rewards);
  event LotsBought(uint256 eth, uint256 wbtc);

  event Deposited(address depositor, uint256 tokenAmount, uint256 mintedShares);
  event Withdrew(address withdrawer, uint256 burntShares, uint256 withdrawedTokens, uint256 withdrawFee);

  function getToken() external view returns (address);

  function getZToken() external view returns (address);

  function getLotManager() external view returns (address);

  function migrate(address newPool) external;


  function deposit(uint256 amount) external returns (uint256 shares);

  function depositAll() external returns (uint256 shares);

  function withdraw(uint256 shares) external returns (uint256 underlyingToWithdraw);

  function withdrawAll() external returns (uint256 underlyingToWithdraw);


  function unusedUnderlyingBalance() external view returns (uint256);

  function totalUnderlying() external view returns (uint256);

  function getPricePerFullShare() external view returns (uint256);


  function setLotManager(address lotManager) external;

  function claimRewards() external returns (uint rewards);

  function buyLots(uint256 eth, uint256 wbtc) external returns (bool);

}// MIT
pragma solidity >=0.6.8;

interface IHegicStaking is IERC20 {    

    event Claim(address indexed acount, uint amount);
    event Profit(uint amount);

    function lockupPeriod() external view returns (uint256);

    function lastBoughtTimestamp(address) external view returns (uint256);


    function claimProfit() external returns (uint profit);

    function buy(uint amount) external;

    function sell(uint amount) external;

    function profitOf(address account) external view returns (uint);

}// MIT
pragma solidity >=0.6.8;



interface ILotManagerV2ProtocolParameters {

  event PerformanceFeeSet(uint256 _performanceFee);
  event ZTreasurySet(address _zTreasury);
  event PoolSet(address _pool, address _token);
  event WETHSet(address _weth);
  event WBTCSet(address _wbtc);
  event HegicStakingSet(address _hegicStakingETH, address _hegicStakingWBTc);

  function uniswapV2() external returns (address);

  function LOT_PRICE() external returns (uint256);

  function FEE_PRECISION() external returns (uint256);

  function MAX_PERFORMANCE_FEE() external returns (uint256);

  function lotPrice() external view returns (uint256); // deprecated for LOT_PRICE

  function getPool() external view returns (address); // deprecated for pool


  function performanceFee() external returns (uint256);

  function zTreasury() external returns (IZTreasuryV2);


  function weth() external returns (address);

  function wbtc() external returns (address);

  function hegicStakingETH() external returns (IHegicStaking);

  function hegicStakingWBTC() external returns (IHegicStaking);


  function pool() external returns (IHegicPoolV2);

  function token() external returns (IERC20);


  function setPerformanceFee(uint256 _performanceFee) external;

  function setZTreasury(address _zTreasury) external;

  function setPool(address _pool) external;

  function setWETH(address _weth) external;

  function setWBTC(address _wbtc) external;

  function setHegicStaking(address _hegicStakingETH, address _hetgicStakingWBTC) external;

}// MIT

pragma solidity >=0.6.8;




abstract
contract LotManagerV2ProtocolParameters is ILotManagerV2ProtocolParameters {


  uint256 public constant override LOT_PRICE = 888_000e18;

  uint256 public constant override FEE_PRECISION = 10000;
  uint256 public constant override MAX_PERFORMANCE_FEE = 50 * FEE_PRECISION;
  
  address public override uniswapV2 = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

  uint256 public override performanceFee;
  IZTreasuryV2 public override zTreasury;

  address public override weth;
  address public override wbtc;
  IHegicStaking public override hegicStakingETH;
  IHegicStaking public override hegicStakingWBTC;

  IHegicPoolV2 public override pool;
  IERC20 public override token;

  constructor(
    uint256 _performanceFee,
    address _zTreasury,
    address _pool,
    address _weth,
    address _wbtc,
    address _hegicStakingETH,
    address _hegicStakingWBTC
  ) public {
    _setPerformanceFee(_performanceFee);
    _setZTreasury(_zTreasury);
    _setPool(_pool);
    _setWETH(_weth);
    _setWBTC(_wbtc);
    _setHegicStaking(_hegicStakingETH, _hegicStakingWBTC);
  }

  function lotPrice() external override view returns (uint256) {

    return LOT_PRICE;
  }

  function getPool() external override view returns (address) {

    return address(pool);
  }

  function _setPerformanceFee(uint256 _performanceFee) internal {

    require(_performanceFee <= MAX_PERFORMANCE_FEE, 'LotManagerV2ProtocolParameters::_setPerformanceFee::bigger-than-max');
    performanceFee = _performanceFee;
    emit PerformanceFeeSet(_performanceFee);
  }
  
  function _setZTreasury(address _zTreasury) internal {

    require(_zTreasury != address(0), 'LotManagerV2ProtocolParameters::_setZTreasury::not-zero-address');
    require(IZTreasuryV2(_zTreasury).isZTreasury(), 'LotManagerV2ProtocolParameters::_setZTreasury::not-treasury');
    zTreasury = IZTreasuryV2(_zTreasury);
    emit ZTreasurySet(_zTreasury);
  }

  function _setPool(address _pool) internal {

    require(_pool != address(0), 'LotManagerV2ProtocolParameters::_setPool::not-zero-address');
    require(IHegicPoolMetadata(_pool).isHegicPool(), 'LotManagerV2ProtocolParameters::_setPool::not-setting-a-hegic-pool');
    pool = IHegicPoolV2(_pool);
    token = IERC20(pool.getToken());
    emit PoolSet(_pool, address(token));
  }

  function _setWETH(address _weth) internal {

    require(_weth != address(0), 'LotManagerV2ProtocolParameters::_setWETH::not-zero-address');
    weth = _weth;
    emit WETHSet(_weth);
  }

  function _setWBTC(address _wbtc) internal {

    require(_wbtc != address(0), 'LotManagerV2ProtocolParameters::_setWBTC::not-zero-address');
    wbtc = _wbtc;
    emit WBTCSet(_wbtc);
  }

  function _setHegicStaking(
    address _hegicStakingETH,
    address _hegicStakingWBTC
  ) internal {

    require(
      _hegicStakingETH != address(0) && 
      _hegicStakingWBTC != address(0), 
      'LotManagerV2ProtocolParameters::_setHegicStaking::not-zero-addresses'
    );

    hegicStakingETH = IHegicStaking(_hegicStakingETH);
    hegicStakingWBTC = IHegicStaking(_hegicStakingWBTC);

    emit HegicStakingSet(_hegicStakingETH, _hegicStakingWBTC);
  }
}// MIT

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.8;

interface ILotManagerV2LotsHandler {
  event ETHLotBought(uint256 amount);
  event WBTCLotBought(uint256 amount);
  event ETHLotSold(uint256 amount);
  event WBTCLotSold(uint256 amount);
  event LotsRebalanced(uint256 _ethLots, uint256 _wbtcLots);
  
  function balanceOfUnderlying() external view returns (uint256 _underlyingBalance);
  function balanceOfLots() external view returns (uint256 _ethLots, uint256 _wbtcLots);
  function profitOfLots() external view returns (uint256 _ethProfit, uint256 _wbtcProfit);
  function buyLots(uint256 _ethLots, uint256 _wbtcLots) external returns (bool);
  function sellLots(uint256 _ethLots, uint256 _wbtcLots) external returns (bool);
  function rebalanceLots(uint256 _ethLots, uint256 _wbtcLots) external returns (bool);
}// MIT

pragma solidity >=0.6.8;

interface ILotManagerV2RewardsHandler {
  event RewardsClaimed(uint256 rewards, uint256 fees);

  function claimRewards() external returns (uint256 _totalRewards);
  function claimableRewards() external view returns (uint256 _amountOut);
}// MIT

pragma solidity >=0.6.8;

interface ILotManagerV2Migrable {
  event LotManagerMigrated(address newLotManager);

  function migrate(address newLotManager) external;
}// MIT

pragma solidity >=0.6.8;

interface ILotManagerV2Unwindable {
  event Unwound(uint256 amount);

  function unwind(uint256 _amount) external returns (uint256 _total);
}// MIT

pragma solidity >=0.6.8;




interface ILotManagerV2 is 
  IGovernable,
  IManageable,
  ICollectableDust,
  ILotManagerMetadata, 
  ILotManagerV2ProtocolParameters, 
  ILotManagerV2LotsHandler,
  ILotManagerV2RewardsHandler,
  ILotManagerV2Migrable,
  ILotManagerV2Unwindable { }// MIT
pragma solidity >=0.6.8;

interface IWETH9 {
    function deposit() external payable;
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
}// MIT

pragma solidity >=0.6.8;


contract LotManagerMetadata is ILotManagerMetadata {
  function isLotManager() external override pure returns (bool) {
    return true;
  }
  function getName() external override pure returns (string memory) {
    return 'LotManager';
  }
}// MIT

pragma solidity >=0.6.8;




abstract
contract LotManagerV2LotsHandler is 
  LotManagerV2ProtocolParameters, 
  ILotManagerV2LotsHandler {

  using SafeMath for uint256;

  function balanceOfUnderlying() public override view returns (uint256 _underlyingBalance) {
    (uint256 _ethLots, uint256 _wbtcLots) = balanceOfLots();
    return _ethLots.add(_wbtcLots).mul(LOT_PRICE);
  }

  function balanceOfLots() public override view returns (uint256 _ethLots, uint256 _wbtcLots) {
    return (
      hegicStakingETH.balanceOf(address(this)),
      hegicStakingWBTC.balanceOf(address(this))
    );
  }

  function profitOfLots() public override view returns (uint256 _ethProfit, uint256 _wbtcProfit) {
    return (
      hegicStakingETH.profitOf(address(this)),
      hegicStakingWBTC.profitOf(address(this))
    );
  }

  function _buyLots(uint256 _ethLots, uint256 _wbtcLots) internal returns (bool) {
    uint256 allowance = token.allowance(address(pool), address(this));
    uint256 lotsCosts = _ethLots.add(_wbtcLots).mul(LOT_PRICE);
    require (allowance >= lotsCosts, 'LotManagerV2LotsHandler::_buyLots::not-enough-allowance');
    token.transferFrom(address(pool), address(this), lotsCosts);

    if (_ethLots > 0) _buyETHLots(_ethLots);
    if (_wbtcLots > 0) _buyWBTCLots(_wbtcLots);

    token.transfer(address(pool), token.balanceOf(address(this)));

    return true;
  }

  function _buyETHLots(uint256 _ethLots) internal {
    token.approve(address(hegicStakingETH), 0);
    token.approve(address(hegicStakingETH), _ethLots * LOT_PRICE);
    hegicStakingETH.buy(_ethLots);
    emit ETHLotBought(_ethLots);
  }

  function _buyWBTCLots(uint256 _wbtcLots) internal {
    token.approve(address(hegicStakingWBTC), 0);
    token.approve(address(hegicStakingWBTC), _wbtcLots * LOT_PRICE);
    hegicStakingWBTC.buy(_wbtcLots);
    emit WBTCLotBought(_wbtcLots);
  }

  function _sellLots(uint256 _ethLots, uint256 _wbtcLots) internal returns (bool) {
    (uint256 _ownedETHLots, uint256 _ownedWBTCLots) = balanceOfLots();
    require (_ethLots <= _ownedETHLots && _wbtcLots <= _ownedWBTCLots, 'LotManagerV2LotsHandler::_sellLots::not-enough-lots');
    if (_ethLots > 0) _sellETHLots(_ethLots);
    if (_wbtcLots > 0) _sellWBTCLots(_wbtcLots);

    token.transfer(address(pool), token.balanceOf(address(this)));

    return true;
  }

  function _sellETHLots(uint256 _eth) internal {
    hegicStakingETH.sell(_eth);
    emit ETHLotSold(_eth);
  }

  function _sellWBTCLots(uint256 _wbtc) internal {
    hegicStakingWBTC.sell(_wbtc);
    emit WBTCLotSold(_wbtc);
  }

  function _rebalanceLots(uint _ethLots, uint256 _wbtcLots) internal returns (bool) {
    (uint256 _ownedETHLots, uint256 _ownedWBTCLots) = balanceOfLots();
    require(
      _ethLots.add(_wbtcLots) == _ownedETHLots.add(_ownedWBTCLots) &&
      _ethLots != _ownedETHLots &&
      _wbtcLots != _ownedWBTCLots, 
      'LotManagerV2LotsHandler::_rebalanceLots::not-rebalancing-lots'
    );

    uint256 lotsDelta;
    if (_ethLots > _ownedETHLots) {
      lotsDelta = _ethLots.sub(_ownedETHLots);
      _sellWBTCLots(lotsDelta);
      _buyETHLots(lotsDelta);
    } else if (_wbtcLots > _ownedWBTCLots) {
      lotsDelta = _wbtcLots.sub(_ownedWBTCLots);
      _sellETHLots(lotsDelta);
      _buyWBTCLots(lotsDelta);
    }

    emit LotsRebalanced(_ethLots, _wbtcLots);
    return true;
  }
}pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}// MIT

pragma solidity >=0.6.8;






abstract
contract LotManagerV2RewardsHandler is 
  LotManagerV2ProtocolParameters, 
  LotManagerV2LotsHandler,
  ILotManagerV2RewardsHandler {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  receive() external payable { }

  function claimableRewards() public override view returns (uint256) {
    (uint256 _ethProfit, uint256 _wbtcProfit) = profitOfLots();

    if (_wbtcProfit > 0) {
      _ethProfit = _ethProfit.add(_getAmountOut(_wbtcProfit, wbtc, weth));
    }

    if (_ethProfit == 0) return 0;

    return _getAmountOut(_ethProfit, weth, address(token));
  }
    
  function _claimRewards() internal returns (uint256 _totalRewards) {
    (uint256 _ethProfit, uint256 _wbtcProfit) = profitOfLots();
    require(_ethProfit > 0 || _wbtcProfit > 0, 'LotManagerV2RewardsHandler::_claimRewards::no-proft-available');

    if (_wbtcProfit > 0) {
      hegicStakingWBTC.claimProfit();

      if (_ethProfit == 0) {
        _swapWBTCForToken();
      } else {
        _swapWBTCForWETH();
      }
    }

    if (_ethProfit > 0) {
      hegicStakingETH.claimProfit();

      IWETH9(weth).deposit{value:payable(address(this)).balance}();

      _swapWETHForToken();
    }

    _totalRewards = token.balanceOf(address(this));

    uint256 _fee = _totalRewards.mul(performanceFee).div(FEE_PRECISION).div(100);

    token.approve(address(pool), 0);
    token.approve(address(pool), _fee);
    pool.deposit(_fee);

    IERC20 zToken = IERC20(pool.getZToken());
    zToken.transfer(address(zTreasury), zToken.balanceOf(address(this)));
    zTreasury.distributeEarnings();

    token.transfer(address(pool), _totalRewards.sub(_fee));

    emit RewardsClaimed(_totalRewards, _fee);
  }

  function _swapWBTCForWETH() internal {
    uint256 _wbtcBalance = IERC20(wbtc).balanceOf(address(this));

    address[] memory _path = new address[](2);
    _path[0] = wbtc;
    _path[1] = weth;

    _swap(_wbtcBalance, _path);
  }

  function _swapWBTCForToken() internal {
    uint256 _wbtcBalance = IERC20(wbtc).balanceOf(address(this));

    address[] memory _path = new address[](3);
    _path[0] = wbtc;
    _path[1] = weth;
    _path[2] = address(token);

    _swap(_wbtcBalance, _path);
  }

  function _swapWETHForToken() internal {
    uint256 _wethBalance = IERC20(weth).balanceOf(address(this));

    address[] memory _path = new address[](2);
    _path[0] = weth;
    _path[1] = address(token);

    _swap(_wethBalance, _path);
  }

  function _swap(
    uint256 _amount,
    address[] memory _path
  ) internal {
    IERC20(_path[0]).safeApprove(uniswapV2, 0);
    IERC20(_path[0]).safeApprove(uniswapV2, _amount);
    IUniswapV2Router02(uniswapV2).swapExactTokensForTokens(
      _amount,
      0,
      _path,
      address(this),
      now.add(1800)
    );
  }

  function _getAmountOut(
    uint256 _amountIn,
    address _fromToken,
    address _toToken
  ) internal view returns (uint256) {
    IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(uniswapV2);
    IUniswapV2Factory uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());
    IUniswapV2Pair uniswapV2Pair = IUniswapV2Pair(uniswapV2Factory.getPair(_fromToken, _toToken));
    (uint112 _reserve0, uint112 _reserve1,) = uniswapV2Pair.getReserves();
    (uint112 _reserveFromToken, uint112 _reserveToToken) = (_fromToken < _toToken) ? (_reserve0, _reserve1) : (_reserve1, _reserve0);
    return uniswapV2Router.getAmountOut(_amountIn, _reserveFromToken, _reserveToToken);
  }
}// MIT

pragma solidity >=0.6.8;




abstract
contract LotManagerV2Migrable is 
  LotManagerV2ProtocolParameters, 
  ILotManagerV2Migrable {
  
  function _migrate(address _newLotManager) internal {
    require(_newLotManager != address(0) && ILotManagerMetadata(_newLotManager).isLotManager(), 'LotManagerV2Migrable::_migrate::not-a-lot-manager');
    require(address(ILotManagerV2ProtocolParameters(_newLotManager).pool()) == address(pool), 'LotManagerV2Migrable::_migrate::migrate-pool-discrepancy');
    hegicStakingETH.transfer(_newLotManager, hegicStakingETH.balanceOf(address(this)));
    hegicStakingWBTC.transfer(_newLotManager, hegicStakingWBTC.balanceOf(address(this)));
    token.transfer(address(pool), token.balanceOf(address(this)));
    emit LotManagerMigrated(_newLotManager);
  }
}// MIT

pragma solidity >=0.6.8;


abstract
contract LotManagerV2Unwindable is 
  LotManagerV2LotsHandler, 
  ILotManagerV2Unwindable {
  
  function _unwind(uint256 _amount) internal returns (uint256 _total) {
    (uint256 _ethLots, uint256 _wbtcLots) = balanceOfLots();
    require (_ethLots > 0 || _wbtcLots > 0, 'LotManagerV2Unwindable::_unwind::no-lots');

    bool areETHLotsUnlocked = hegicStakingETH.lastBoughtTimestamp(address(this)).add(hegicStakingETH.lockupPeriod()) <= block.timestamp;
    bool areWBTCLotsUnlocked = hegicStakingWBTC.lastBoughtTimestamp(address(this)).add(hegicStakingWBTC.lockupPeriod()) <= block.timestamp;
    require (areETHLotsUnlocked || areWBTCLotsUnlocked, 'LotManagerV2Unwindable::_unwind::no-unlocked-lots');
    _ethLots = areETHLotsUnlocked ? _ethLots : 0;
    _wbtcLots = areWBTCLotsUnlocked ? _wbtcLots : 0;
    uint256 _lotsToSell = _amount.div(LOT_PRICE).add(_amount.mod(LOT_PRICE) == 0 ? 0 : 1);
    require (_ethLots.add(_wbtcLots) >= _lotsToSell, 'LotManagerV2Unwindable::_unwind::not-enough-unlocked-lots');

    uint256 _totalSold = 0;

    if (_ethLots > 0) {
      _ethLots = _ethLots < _lotsToSell.sub(_totalSold) ? _ethLots : _lotsToSell.sub(_totalSold);
      _sellETHLots(_ethLots);
      _totalSold = _totalSold.add(_ethLots);
    }

    if (_wbtcLots > 0) {
      _wbtcLots = _wbtcLots < _lotsToSell.sub(_totalSold) ? _wbtcLots : _lotsToSell.sub(_totalSold);
      _sellWBTCLots(_wbtcLots);
      _totalSold = _totalSold.add(_wbtcLots);
    }

    require(_totalSold == _lotsToSell, 'LotManagerV2Unwindable::_unwind::not-enough-lots-sold');

    _total = _lotsToSell.mul(LOT_PRICE);

    require(_total >= _amount, 'LotManagerV2Unwindable::_unwind::not-enough-tokens-aquired');

    token.transfer(address(pool), _total);

    emit Unwound(_total);
  }
}// MIT

pragma solidity >=0.6.8;






contract LotManagerV2 is
  Governable,
  Manageable,
  CollectableDust,
  LotManagerMetadata,
  LotManagerV2ProtocolParameters,
  LotManagerV2LotsHandler,
  LotManagerV2RewardsHandler,
  LotManagerV2Migrable,
  LotManagerV2Unwindable,
  ILotManagerV2 {

  constructor(
    address _governor,
    address _manager,
    uint256 _performanceFee,
    address _zTreasury,
    address _pool,
    address _weth,
    address _wbtc,
    address[2] memory _hegicStakings
  ) public
    Governable(_governor)
    Manageable(_manager)
    CollectableDust()
    LotManagerMetadata()
    LotManagerV2ProtocolParameters(
      _performanceFee,
      _zTreasury,
      _pool,
      _weth,
      _wbtc,
      _hegicStakings[0],
      _hegicStakings[1])
    LotManagerV2LotsHandler()
    LotManagerV2RewardsHandler()
    LotManagerV2Migrable()
    LotManagerV2Unwindable() {
    _addProtocolToken(_pool);
    _addProtocolToken(address(token));
    _addProtocolToken(_weth);
    _addProtocolToken(_wbtc);
    _addProtocolToken(_hegicStakings[0]);
    _addProtocolToken(_hegicStakings[1]);
  }

  modifier onlyManagerOrPool {
    require(msg.sender == address(pool) || msg.sender == manager, 'LotManagerV2::only-manager-or-pool');
    _;
  }

  modifier onlyPool {
    require(msg.sender == address(pool), 'LotManagerV2::only-pool');
    _;
  }

  function unwind(uint256 _amount) external override onlyPool returns (uint256 _total) {
    return _unwind(_amount);
  }

  function claimRewards() external override onlyManagerOrPool returns (uint256 _totalRewards) {
    return _claimRewards();
  }

  function buyLots(uint256 _ethLots, uint256 _wbtcLots) external override onlyPool returns (bool) {
    return _buyLots(_ethLots, _wbtcLots);
  }

  function sellLots(uint256 _ethLots, uint256 _wbtcLots) external override onlyGovernor returns (bool) {
    return _sellLots(_ethLots, _wbtcLots);
  }

  function rebalanceLots(uint256 _ethLots, uint256 _wbtcLots) external override onlyManagerOrPool returns (bool) {
    return _rebalanceLots(_ethLots, _wbtcLots);
  }

  function setPerformanceFee(uint256 _peformanceFee) external override onlyGovernor {
    _setPerformanceFee(_peformanceFee);
  }

  function setZTreasury(address _zTreasury) external override onlyGovernor {
    _setZTreasury(_zTreasury);
  }

  function setPool(address _pool) external override onlyGovernor {
    _removeProtocolToken(address(pool));
    _removeProtocolToken(address(token));
    _setPool(_pool);
    _addProtocolToken(_pool);
    _addProtocolToken(address(token));
  }

  function setWETH(address _weth) external override onlyGovernor {
    _removeProtocolToken(weth);
    _addProtocolToken(_weth);
    _setWETH(_weth);
  }

  function setWBTC(address _wbtc) external override onlyGovernor {
    _removeProtocolToken(wbtc);
    _addProtocolToken(_wbtc);
    _setWBTC(_wbtc);
  }

  function setHegicStaking(
    address _hegicStakingETH, 
    address _hegicStakingWBTC
  ) external override onlyGovernor {
    if (address(hegicStakingETH) != _hegicStakingETH) {
      _removeProtocolToken(address(hegicStakingETH));
      _addProtocolToken(_hegicStakingETH);
    }
    if (address(hegicStakingWBTC) != _hegicStakingWBTC) {
      _removeProtocolToken(address(hegicStakingWBTC));
      _addProtocolToken(_hegicStakingWBTC);
    }
    _setHegicStaking(
      _hegicStakingETH,
      _hegicStakingWBTC
    );
  }

  function migrate(address _newLotManager) external override virtual onlyGovernor {
    _migrate(_newLotManager);
  }

  function setPendingGovernor(address _pendingGovernor) external override onlyGovernor {
    _setPendingGovernor(_pendingGovernor);
  }

  function acceptGovernor() external override onlyPendingGovernor {
    _acceptGovernor();
  }

  function setPendingManager(address _pendingManager) external override onlyManager {
    _setPendingManager(_pendingManager);
  }

  function acceptManager() external override onlyPendingManager {
    _acceptManager();
  }

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external override onlyGovernor {
    _sendDust(_to, _token, _amount);
  }
}// MIT

pragma solidity >=0.6.8;






contract LotManagerV2Dot1 is
  Governable,
  Manageable,
  CollectableDust,
  LotManagerMetadata,
  LotManagerV2ProtocolParameters,
  LotManagerV2LotsHandler,
  LotManagerV2RewardsHandler,
  LotManagerV2Migrable,
  LotManagerV2Unwindable,
  ILotManagerV2 {

  constructor(
    address _governor,
    address _manager,
    uint256 _performanceFee,
    address _zTreasury,
    address _pool,
    address _weth,
    address _wbtc,
    address[2] memory _hegicStakings
  ) public
    Governable(_governor)
    Manageable(_manager)
    CollectableDust()
    LotManagerMetadata()
    LotManagerV2ProtocolParameters(
      _performanceFee,
      _zTreasury,
      _pool,
      _weth,
      _wbtc,
      _hegicStakings[0],
      _hegicStakings[1])
    LotManagerV2LotsHandler()
    LotManagerV2RewardsHandler()
    LotManagerV2Migrable()
    LotManagerV2Unwindable() {
    _addProtocolToken(_pool);
    _addProtocolToken(address(token));
    _addProtocolToken(_weth);
    _addProtocolToken(_wbtc);
    _addProtocolToken(_hegicStakings[0]);
    _addProtocolToken(_hegicStakings[1]);
  }

  modifier onlyManagerOrPool {
    require(msg.sender == manager || msg.sender == address(pool), 'LotManagerV2::only-manager-or-pool');
    _;
  }

  modifier onlyGovernorOrPool {
    require(msg.sender == governor || msg.sender == address(pool), 'LotManagerV2::only-governor-or-pool');
    _;
  }

  modifier onlyPool {
    require(msg.sender == address(pool), 'LotManagerV2::only-pool');
    _;
  }

  function unwind(uint256 _amount) external override onlyPool returns (uint256 _total) {
    return _unwind(_amount);
  }

  function claimRewards() external override onlyManagerOrPool returns (uint256 _totalRewards) {
    return _claimRewards();
  }

  function buyLots(uint256 _ethLots, uint256 _wbtcLots) external override onlyPool returns (bool) {
    return _buyLots(_ethLots, _wbtcLots);
  }

  function sellLots(uint256 _ethLots, uint256 _wbtcLots) external override onlyGovernor returns (bool) {
    return _sellLots(_ethLots, _wbtcLots);
  }

  function rebalanceLots(uint256 _ethLots, uint256 _wbtcLots) external override onlyManagerOrPool returns (bool) {
    return _rebalanceLots(_ethLots, _wbtcLots);
  }

  function setPerformanceFee(uint256 _peformanceFee) external override onlyGovernor {
    _setPerformanceFee(_peformanceFee);
  }

  function setZTreasury(address _zTreasury) external override onlyGovernor {
    _setZTreasury(_zTreasury);
  }

  function setPool(address _pool) external override onlyGovernorOrPool {
    _removeProtocolToken(address(pool));
    _removeProtocolToken(address(token));
    _setPool(_pool);
    _addProtocolToken(_pool);
    _addProtocolToken(address(token));
  }

  function setWETH(address _weth) external override onlyGovernor {
    _removeProtocolToken(weth);
    _addProtocolToken(_weth);
    _setWETH(_weth);
  }

  function setWBTC(address _wbtc) external override onlyGovernor {
    _removeProtocolToken(wbtc);
    _addProtocolToken(_wbtc);
    _setWBTC(_wbtc);
  }

  function setHegicStaking(
    address _hegicStakingETH, 
    address _hegicStakingWBTC
  ) external override onlyGovernor {
    if (address(hegicStakingETH) != _hegicStakingETH) {
      _removeProtocolToken(address(hegicStakingETH));
      _addProtocolToken(_hegicStakingETH);
    }
    if (address(hegicStakingWBTC) != _hegicStakingWBTC) {
      _removeProtocolToken(address(hegicStakingWBTC));
      _addProtocolToken(_hegicStakingWBTC);
    }
    _setHegicStaking(
      _hegicStakingETH,
      _hegicStakingWBTC
    );
  }

  function migrate(address _newLotManager) external override onlyGovernor {
    _migrate(_newLotManager);
  }

  function setPendingGovernor(address _pendingGovernor) external override onlyGovernor {
    _setPendingGovernor(_pendingGovernor);
  }

  function acceptGovernor() external override onlyPendingGovernor {
    _acceptGovernor();
  }

  function setPendingManager(address _pendingManager) external override onlyManager {
    _setPendingManager(_pendingManager);
  }

  function acceptManager() external override onlyPendingManager {
    _acceptManager();
  }

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external override onlyGovernor {
    _sendDust(_to, _token, _amount);
  }
}// MIT

pragma solidity >=0.6.8;



contract zHEGIC is ERC20, Governable {

  IHegicPoolMetadata public pool;

  constructor() public
    ERC20('zHEGIC', 'zHEGIC')
    Governable(msg.sender) {
  }

  modifier onlyPool {
    require(msg.sender == address(pool), 'zHEGIC/only-pool');
    _;
  }

  modifier onlyPoolOrGovernor {
    require(msg.sender == address(pool) || msg.sender == governor, 'zHEGIC/only-pool-or-governor');
    _;
  }

  function setPool(address _newPool) external onlyPoolOrGovernor {
    require(IHegicPoolMetadata(_newPool).isHegicPool(), 'zHEGIC/not-setting-a-hegic-pool');
    pool = IHegicPoolMetadata(_newPool);
  }

  function mint(address account, uint256 amount) external onlyPool {
    _mint(account, amount);
  }

  function burn(address account, uint256 amount) external onlyPool {
    _burn(account, amount);
  }

  function setPendingGovernor(address _pendingGovernor) external override onlyGovernor {
    _setPendingGovernor(_pendingGovernor);
  }

  function acceptGovernor() external override onlyPendingGovernor {
    _acceptGovernor();
  }
}