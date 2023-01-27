

pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;


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
}

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
}

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

library WadRayMath {

  using SafeMath for uint256;

  uint256 internal constant WAD = 1e18;
  uint256 internal constant halfWAD = WAD / 2;

  uint256 internal constant RAY = 1e27;
  uint256 internal constant halfRAY = RAY / 2;

  uint256 internal constant WAD_RAY_RATIO = 1e9;

  function ray() internal pure returns (uint256) {

    return RAY;
  }

  function wad() internal pure returns (uint256) {

    return WAD;
  }

  function halfRay() internal pure returns (uint256) {

    return halfRAY;
  }

  function halfWad() internal pure returns (uint256) {

    return halfWAD;
  }

  function wadMul(uint256 a, uint256 b) internal pure returns (uint256) {

    return halfWAD.add(a.mul(b)).div(WAD);
  }

  function wadDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 halfB = b / 2;

    return halfB.add(a.mul(WAD)).div(b);
  }

  function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {

    return halfRAY.add(a.mul(b)).div(RAY);
  }

  function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 halfB = b / 2;

    return halfB.add(a.mul(RAY)).div(b);
  }

  function rayToWad(uint256 a) internal pure returns (uint256) {

    uint256 halfRatio = WAD_RAY_RATIO / 2;

    return halfRatio.add(a).div(WAD_RAY_RATIO);
  }

  function wadToRay(uint256 a) internal pure returns (uint256) {

    return a.mul(WAD_RAY_RATIO);
  }

  function rayPow(uint256 x, uint256 n) internal pure returns (uint256 z) {

    z = n % 2 != 0 ? x : RAY;

    for (n /= 2; n != 0; n /= 2) {
      x = rayMul(x, x);

      if (n % 2 != 0) {
        z = rayMul(z, x);
      }
    }
  }
}

interface IAccessController {

  event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
  event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

  function MANAGER_ROLE() external view returns (bytes32);


  function MINTER_ROLE() external view returns (bytes32);


  function hasRole(bytes32 role, address account) external view returns (bool);


  function getRoleMemberCount(bytes32 role) external view returns (uint256);


  function getRoleMember(bytes32 role, uint256 index) external view returns (address);


  function getRoleAdmin(bytes32 role) external view returns (bytes32);


  function grantRole(bytes32 role, address account) external;


  function revokeRole(bytes32 role, address account) external;


  function renounceRole(bytes32 role, address account) external;

}

interface IConfigProvider {

  struct CollateralConfig {
    address collateralType;
    uint256 debtLimit;
    uint256 minCollateralRatio;
    uint256 borrowRate;
    uint256 originationFee;
  }

  function a() external view returns (IAddressProvider);


  function collateralConfigs(uint256 _id) external view returns (CollateralConfig memory);


  function collateralIds(address _collateralType) external view returns (uint256);


  function numCollateralConfigs() external view returns (uint256);


  function liquidationBonus() external view returns (uint256);


  event CollateralUpdated(
    address indexed collateralType,
    uint256 debtLimit,
    uint256 minCollateralRatio,
    uint256 borrowRate,
    uint256 originationFee
  );
  event CollateralRemoved(address indexed collateralType);

  function setCollateralConfig(
    address _collateralType,
    uint256 _debtLimit,
    uint256 _minCollateralRatio,
    uint256 _borrowRate,
    uint256 _originationFee
  ) external;


  function removeCollateral(address _collateralType) external;


  function setCollateralDebtLimit(address _collateralType, uint256 _debtLimit) external;


  function setCollateralMinCollateralRatio(address _collateralType, uint256 _minCollateralRatio) external;


  function setCollateralBorrowRate(address _collateralType, uint256 _borrowRate) external;


  function setCollateralOriginationFee(address _collateralType, uint256 _originationFee) external;


  function setLiquidationBonus(uint256 _bonus) external;


  function collateralDebtLimit(address _collateralType) external view returns (uint256);


  function collateralMinCollateralRatio(address _collateralType) external view returns (uint256);


  function collateralBorrowRate(address _collateralType) external view returns (uint256);


  function collateralOriginationFee(address _collateralType) external view returns (uint256);

}

interface ISTABLEX is IERC20 {

  function a() external view returns (IAddressProvider);


  function mint(address account, uint256 amount) external;


  function burn(address account, uint256 amount) external;

}

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);


  function description() external view returns (string memory);


  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

interface IPriceFeed {

  event OracleUpdated(address indexed asset, address oracle);

  function a() external view returns (IAddressProvider);


  function setAssetOracle(address _asset, address _oracle) external;


  function assetOracles(address _asset) external view returns (AggregatorV3Interface);


  function getAssetPrice(address _asset) external view returns (uint256);


  function convertFrom(address _asset, uint256 _balance) external view returns (uint256);


  function convertTo(address _asset, uint256 _balance) external view returns (uint256);

}

interface IRatesManager {

  function a() external view returns (IAddressProvider);


  function annualizedBorrowRate(uint256 _currentBorrowRate) external pure returns (uint256);


  function calculateDebt(uint256 _baseDebt, uint256 _cumulativeRate) external pure returns (uint256);


  function calculateBaseDebt(uint256 _debt, uint256 _cumulativeRate) external pure returns (uint256);


  function calculateCumulativeRate(
    uint256 _borrowRate,
    uint256 _cumulativeRate,
    uint256 _timeElapsed
  ) external view returns (uint256);

}

interface ILiquidationManager {

  function a() external view returns (IAddressProvider);


  function calculateHealthFactor(
    address _collateralType,
    uint256 _collateralValue,
    uint256 _vaultDebt
  ) external view returns (uint256 healthFactor);


  function liquidationBonus(uint256 _amount) external view returns (uint256 bonus);


  function applyLiquidationDiscount(uint256 _amount) external view returns (uint256 discountedAmount);


  function isHealthy(
    address _collateralType,
    uint256 _collateralValue,
    uint256 _vaultDebt
  ) external view returns (bool);

}

interface IVaultsDataProvider {

  struct Vault {
    address collateralType;
    address owner;
    uint256 collateralBalance;
    uint256 baseDebt;
    uint256 createdAt;
  }

  function a() external view returns (IAddressProvider);


  function baseDebt(address _collateralType) external view returns (uint256);


  function vaultCount() external view returns (uint256);


  function vaults(uint256 _id) external view returns (Vault memory);


  function vaultOwner(uint256 _id) external view returns (address);


  function vaultCollateralType(uint256 _id) external view returns (address);


  function vaultCollateralBalance(uint256 _id) external view returns (uint256);


  function vaultBaseDebt(uint256 _id) external view returns (uint256);


  function vaultId(address _collateralType, address _owner) external view returns (uint256);


  function vaultExists(uint256 _id) external view returns (bool);


  function vaultDebt(uint256 _vaultId) external view returns (uint256);


  function debt() external view returns (uint256);


  function collateralDebt(address _collateralType) external view returns (uint256);


  function createVault(address _collateralType, address _owner) external returns (uint256);


  function setCollateralBalance(uint256 _id, uint256 _balance) external;


  function setBaseDebt(uint256 _id, uint256 _newBaseDebt) external;

}

interface IFeeDistributor {

  event PayeeAdded(address indexed account, uint256 shares);
  event FeeReleased(uint256 income, uint256 releasedAt);

  function a() external view returns (IAddressProvider);


  function lastReleasedAt() external view returns (uint256);


  function getPayees() external view returns (address[] memory);


  function totalShares() external view returns (uint256);


  function shares(address payee) external view returns (uint256);


  function release() external;


  function changePayees(address[] memory _payees, uint256[] memory _shares) external;

}

interface IAddressProvider {

  function controller() external view returns (IAccessController);


  function config() external view returns (IConfigProvider);


  function core() external view returns (IVaultsCore);


  function stablex() external view returns (ISTABLEX);


  function ratesManager() external view returns (IRatesManager);


  function priceFeed() external view returns (IPriceFeed);


  function liquidationManager() external view returns (ILiquidationManager);


  function vaultsData() external view returns (IVaultsDataProvider);


  function feeDistributor() external view returns (IFeeDistributor);


  function setAccessController(IAccessController _controller) external;


  function setConfigProvider(IConfigProvider _config) external;


  function setVaultsCore(IVaultsCore _core) external;


  function setStableX(ISTABLEX _stablex) external;


  function setRatesManager(IRatesManager _ratesManager) external;


  function setPriceFeed(IPriceFeed _priceFeed) external;


  function setLiquidationManager(ILiquidationManager _liquidationManager) external;


  function setVaultsDataProvider(IVaultsDataProvider _vaultsData) external;


  function setFeeDistributor(IFeeDistributor _feeDistributor) external;

}

interface IVaultsCore {

  event Opened(uint256 indexed vaultId, address indexed collateralType, address indexed owner);
  event Deposited(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Withdrawn(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Borrowed(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Repaid(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Liquidated(
    uint256 indexed vaultId,
    uint256 debtRepaid,
    uint256 collateralLiquidated,
    address indexed owner,
    address indexed sender
  );

  event CumulativeRateUpdated(
    address indexed collateralType,
    uint256 elapsedTime,
    uint256 newCumulativeRate
  ); //cumulative interest rate from deployment time T0

  event InsurancePaid(uint256 indexed vaultId, uint256 insuranceAmount, address indexed sender);

  function a() external view returns (IAddressProvider);


  function deposit(address _collateralType, uint256 _amount) external;


  function withdraw(uint256 _vaultId, uint256 _amount) external;


  function withdrawAll(uint256 _vaultId) external;


  function borrow(uint256 _vaultId, uint256 _amount) external;


  function repayAll(uint256 _vaultId) external;


  function repay(uint256 _vaultId, uint256 _amount) external;


  function liquidate(uint256 _vaultId) external;



  function availableIncome() external view returns (uint256);


  function cumulativeRates(address _collateralType) external view returns (uint256);


  function lastRefresh(address _collateralType) external view returns (uint256);


  function initializeRates(address _collateralType) external;


  function refresh() external;


  function refreshCollateral(address collateralType) external;


  function upgrade(address _newVaultsCore) external;

}

contract VaultsCore is IVaultsCore, ReentrancyGuard {

  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  using WadRayMath for uint256;

  uint256 MAX_INT = 2**256 - 1;
  
  mapping(address => uint256) public override cumulativeRates;
  mapping(address => uint256) public override lastRefresh;

  IAddressProvider public override a;

  modifier onlyManager() {

    require(a.controller().hasRole(a.controller().MANAGER_ROLE(), msg.sender));
    _;
  }

  modifier onlyVaultOwner(uint256 _vaultId) {

    require(a.vaultsData().vaultOwner(_vaultId) == msg.sender);
    _;
  }

  modifier onlyConfig() {

    require(msg.sender == address(a.config()));
    _;
  }

  constructor(IAddressProvider _addresses) public {
    require(address(_addresses) != address(0));
    a = _addresses;
  }

  function upgrade(address _newVaultsCore) public override onlyManager{

    require(address(_newVaultsCore) != address(0));
    require(a.stablex().approve(_newVaultsCore, MAX_INT));

    for (uint256 i = 1; i <= a.config().numCollateralConfigs(); i++) {
      address collateralType = a.config().collateralConfigs(i).collateralType;
      IERC20 asset = IERC20(collateralType);
      asset.safeApprove(_newVaultsCore, MAX_INT);
    }
  }
  function availableIncome() public override view returns (uint256) {

    return a.vaultsData().debt().sub(a.stablex().totalSupply());
  }

  function refresh() public override {

    for (uint256 i = 1; i <= a.config().numCollateralConfigs(); i++) {
      address collateralType = a.config().collateralConfigs(i).collateralType;
      refreshCollateral(collateralType);
    }
  }

  function initializeRates(address _collateralType) public override onlyConfig {

    require(_collateralType != address(0));
    lastRefresh[_collateralType] = now;
    cumulativeRates[_collateralType] = WadRayMath.ray();
  }

  function refreshCollateral(address _collateralType) public override {

    require(_collateralType != address(0));
    require(a.config().collateralIds(_collateralType) != 0);
    uint256 timestamp = now;
    uint256 timeElapsed = timestamp.sub(lastRefresh[_collateralType]);
    _refreshCumulativeRate(_collateralType, timeElapsed);
    lastRefresh[_collateralType] = timestamp;
  }

  function _refreshCumulativeRate(address _collateralType, uint256 _timeElapsed) internal {

    uint256 borrowRate = a.config().collateralBorrowRate(_collateralType);
    uint256 oldCumulativeRate = cumulativeRates[_collateralType];
    cumulativeRates[_collateralType] = a.ratesManager().calculateCumulativeRate(
      borrowRate,
      oldCumulativeRate,
      _timeElapsed
    );
    emit CumulativeRateUpdated(_collateralType, _timeElapsed, cumulativeRates[_collateralType]);
  }

  function deposit(address _collateralType, uint256 _amount) public override {

    require(a.config().collateralIds(_collateralType) != 0);
    uint256 vaultId = a.vaultsData().vaultId(_collateralType, msg.sender);
    if (vaultId == 0) {
      vaultId = a.vaultsData().createVault(_collateralType, msg.sender);
    }
    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(vaultId);
    a.vaultsData().setCollateralBalance(vaultId, v.collateralBalance.add(_amount));

    IERC20 asset = IERC20(v.collateralType);
    asset.safeTransferFrom(msg.sender, address(this), _amount);

    emit Deposited(vaultId, _amount, msg.sender);
  }

  function withdraw(uint256 _vaultId, uint256 _amount) public override onlyVaultOwner(_vaultId) nonReentrant {

    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);
    require(_amount <= v.collateralBalance);
    uint256 newCollateralBalance = v.collateralBalance.sub(_amount);
    a.vaultsData().setCollateralBalance(_vaultId, newCollateralBalance);
    if (v.baseDebt > 0) {
      refreshCollateral(v.collateralType);
      uint256 newCollateralValue = a.priceFeed().convertFrom(v.collateralType, newCollateralBalance);
      bool _isHealthy = a.liquidationManager().isHealthy(
        v.collateralType,
        newCollateralValue,
        a.vaultsData().vaultDebt(_vaultId)
      );
      require(_isHealthy);
    }

    IERC20 asset = IERC20(v.collateralType);
    asset.safeTransfer(msg.sender, _amount);
    emit Withdrawn(_vaultId, _amount, msg.sender);
  }

  function withdrawAll(uint256 _vaultId) public override onlyVaultOwner(_vaultId) {

    uint256 collateralBalance = a.vaultsData().vaultCollateralBalance(_vaultId);
    withdraw(_vaultId, collateralBalance);
  }

  function borrow(uint256 _vaultId, uint256 _amount) public override onlyVaultOwner(_vaultId) nonReentrant {

    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);

    refreshCollateral(v.collateralType);

    uint256 originationFeePercentage = a.config().collateralOriginationFee(v.collateralType);
    uint256 newDebt = _amount;
    if (originationFeePercentage > 0) {
      newDebt = newDebt.add(_amount.wadMul(originationFeePercentage));
    }

    uint256 newBaseDebt = a.ratesManager().calculateBaseDebt(newDebt, cumulativeRates[v.collateralType]);

    a.vaultsData().setBaseDebt(_vaultId, v.baseDebt.add(newBaseDebt));

    uint256 collateralValue = a.priceFeed().convertFrom(v.collateralType, v.collateralBalance);
    uint256 newVaultDebt = a.vaultsData().vaultDebt(_vaultId);

    require(a.vaultsData().collateralDebt(v.collateralType) <= a.config().collateralDebtLimit(v.collateralType));

    bool isHealthy = a.liquidationManager().isHealthy(v.collateralType, collateralValue, newVaultDebt);
    require(isHealthy);

    a.stablex().mint(msg.sender, _amount);
    emit Borrowed(_vaultId, _amount, msg.sender);
  }

  function repayAll(uint256 _vaultId) public override {

    repay(_vaultId, 2**256 - 1);
  }

  function repay(uint256 _vaultId, uint256 _amount) public override nonReentrant {

    address collateralType = a.vaultsData().vaultCollateralType(_vaultId);

    refreshCollateral(collateralType);

    uint256 currentVaultDebt = a.vaultsData().vaultDebt(_vaultId);
    if (_amount >= currentVaultDebt) {
      _amount = currentVaultDebt; //only pay back what's outstanding
    }
    _reduceVaultDebt(_vaultId, _amount);
    a.stablex().burn(msg.sender, _amount);

    emit Repaid(_vaultId, _amount, msg.sender);
  }

  function _reduceVaultDebt(uint256 _vaultId, uint256 _amount) internal {

    address collateralType = a.vaultsData().vaultCollateralType(_vaultId);

    uint256 currentVaultDebt = a.vaultsData().vaultDebt(_vaultId);
    uint256 remainder = currentVaultDebt.sub(_amount);
    uint256 cumulativeRate = cumulativeRates[collateralType];

    if (remainder == 0) {
      a.vaultsData().setBaseDebt(_vaultId, 0);
    } else {
      uint256 newBaseDebt = a.ratesManager().calculateBaseDebt(remainder, cumulativeRate);
      a.vaultsData().setBaseDebt(_vaultId, newBaseDebt);
    }
  }

  function liquidate(uint256 _vaultId) public override nonReentrant {

    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);

    refreshCollateral(v.collateralType);

    uint256 collateralValue = a.priceFeed().convertFrom(v.collateralType, v.collateralBalance);
    uint256 currentVaultDebt = a.vaultsData().vaultDebt(_vaultId);

    require(!a.liquidationManager().isHealthy(v.collateralType, collateralValue, currentVaultDebt));

    uint256 discountedValue = a.liquidationManager().applyLiquidationDiscount(collateralValue);
    uint256 collateralToReceive;
    uint256 stableXToPay = currentVaultDebt;

    if (discountedValue < currentVaultDebt) {
      uint256 insuranceAmount = currentVaultDebt.sub(discountedValue);
      require(a.stablex().balanceOf(address(this)) >= insuranceAmount);
      a.stablex().burn(address(this), insuranceAmount);
      emit InsurancePaid(_vaultId, insuranceAmount, msg.sender);
      collateralToReceive = v.collateralBalance;
      stableXToPay = currentVaultDebt.sub(insuranceAmount);
    } else {
      collateralToReceive = a.priceFeed().convertTo(v.collateralType, currentVaultDebt);
      collateralToReceive = collateralToReceive.add(a.liquidationManager().liquidationBonus(collateralToReceive));
    }
    _reduceVaultDebt(_vaultId, currentVaultDebt);
    a.stablex().burn(msg.sender, stableXToPay);

    a.vaultsData().setCollateralBalance(_vaultId, v.collateralBalance.sub(collateralToReceive));
    IERC20 asset = IERC20(v.collateralType);
    asset.safeTransfer(msg.sender, collateralToReceive);

    emit Liquidated(_vaultId, stableXToPay, collateralToReceive, v.owner, msg.sender);
  }
}