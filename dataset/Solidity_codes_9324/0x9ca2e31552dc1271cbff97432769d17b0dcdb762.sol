
pragma solidity ^0.8.0;


library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// agpl-3.0
pragma solidity 0.8.8;
// pragma experimental ABIEncoderV2;

abstract contract IAaveProtocolDataProvider {

  struct TokenData {
    string symbol;
    address tokenAddress;
  }

  function getAllReservesTokens() external virtual view returns (TokenData[] memory);

  function getAllATokens() external virtual view returns (TokenData[] memory);

  function getReserveConfigurationData(address asset)
    external virtual
    view
    returns (
      uint256 decimals,
      uint256 ltv,
      uint256 liquidationThreshold,
      uint256 liquidationBonus,
      uint256 reserveFactor,
      bool usageAsCollateralEnabled,
      bool borrowingEnabled,
      bool stableBorrowRateEnabled,
      bool isActive,
      bool isFrozen
    );

  function getReserveData(address asset)
    external virtual
    view
    returns (
      uint256 availableLiquidity,
      uint256 totalStableDebt,
      uint256 totalVariableDebt,
      uint256 liquidityRate,
      uint256 variableBorrowRate,
      uint256 stableBorrowRate,
      uint256 averageStableBorrowRate,
      uint256 liquidityIndex,
      uint256 variableBorrowIndex,
      uint40 lastUpdateTimestamp
    );

  function getUserReserveData(address asset, address user)
    external virtual
    view
    returns (
      uint256 currentATokenBalance,
      uint256 currentStableDebt,
      uint256 currentVariableDebt,
      uint256 principalStableDebt,
      uint256 scaledVariableDebt,
      uint256 stableBorrowRate,
      uint256 liquidityRate,
      uint40 stableRateLastUpdated,
      bool usageAsCollateralEnabled
    );

  function getReserveTokensAddresses(address asset)
    external virtual
    view
    returns (
      address aTokenAddress,
      address stableDebtTokenAddress,
      address variableDebtTokenAddress
    );
}// MIT
pragma solidity 0.8.8;

interface ILendingPoolAddressesProvider {

  event MarketIdSet(string newMarketId);
  event LendingPoolUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingPoolCollateralManagerUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function getMarketId() external view returns (string memory);


  function setMarketId(string calldata marketId) external;


  function setAddress(bytes32 id, address newAddress) external;


  function setAddressAsProxy(bytes32 id, address impl) external;


  function getAddress(bytes32 id) external view returns (address);


  function getLendingPool() external view returns (address);


  function setLendingPoolImpl(address pool) external;


  function getLendingPoolConfigurator() external view returns (address);


  function setLendingPoolConfiguratorImpl(address configurator) external;


  function getLendingPoolCollateralManager() external view returns (address);


  function setLendingPoolCollateralManager(address manager) external;


  function getPoolAdmin() external view returns (address);


  function setPoolAdmin(address admin) external;


  function getEmergencyAdmin() external view returns (address);


  function setEmergencyAdmin(address admin) external;


  function getPriceOracle() external view returns (address);


  function setPriceOracle(address priceOracle) external;


  function getLendingRateOracle() external view returns (address);


  function setLendingRateOracle(address lendingRateOracle) external;

}// MIT
pragma solidity 0.8.8;

library DataTypes {

  struct ReserveData {
    ReserveConfigurationMap configuration;
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 currentLiquidityRate;
    uint128 currentVariableBorrowRate;
    uint128 currentStableBorrowRate;
    uint40 lastUpdateTimestamp;
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    address interestRateStrategyAddress;
    uint8 id;
  }

  struct ReserveConfigurationMap {
    uint256 data;
  }

  struct UserConfigurationMap {
    uint256 data;
  }

  enum InterestRateMode {NONE, STABLE, VARIABLE}
}// MIT
pragma solidity 0.8.8;


interface ILendingPool {

  event Deposit(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint16 indexed referral
  );

  event Withdraw(address indexed reserve, address indexed user, address indexed to, uint256 amount);

  event Borrow(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint256 borrowRateMode,
    uint256 borrowRate,
    uint16 indexed referral
  );

  event Repay(
    address indexed reserve,
    address indexed user,
    address indexed repayer,
    uint256 amount
  );

  event Swap(address indexed reserve, address indexed user, uint256 rateMode);

  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);

  event RebalanceStableBorrowRate(address indexed reserve, address indexed user);

  event FlashLoan(
    address indexed target,
    address indexed initiator,
    address indexed asset,
    uint256 amount,
    uint256 premium,
    uint16 referralCode
  );

  event Paused();

  event Unpaused();

  event LiquidationCall(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    address liquidator,
    bool receiveAToken
  );

  event ReserveDataUpdated(
    address indexed reserve,
    uint256 liquidityRate,
    uint256 stableBorrowRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex
  );

  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;


  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);


  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode,
    address onBehalfOf
  ) external;


  function repay(
    address asset,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external returns (uint256);


  function swapBorrowRateMode(address asset, uint256 rateMode) external;


  function rebalanceStableBorrowRate(address asset, address user) external;


  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;


  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveAToken
  ) external;


  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;


  function getUserAccountData(address user)
    external
    view
    returns (
      uint256 totalCollateralETH,
      uint256 totalDebtETH,
      uint256 availableBorrowsETH,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor
    );


  function initReserve(
    address reserve,
    address aTokenAddress,
    address stableDebtAddress,
    address variableDebtAddress,
    address interestRateStrategyAddress
  ) external;


  function setReserveInterestRateStrategyAddress(address reserve, address rateStrategyAddress)
    external;


  function setConfiguration(address reserve, uint256 configuration) external;


  function getConfiguration(address asset)
    external
    view
    returns (DataTypes.ReserveConfigurationMap memory);


  function getUserConfiguration(address user)
    external
    view
    returns (DataTypes.UserConfigurationMap memory);


  function getReserveNormalizedIncome(address asset) external view returns (uint256);


  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);


  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);


  function finalizeTransfer(
    address asset,
    address from,
    address to,
    uint256 amount,
    uint256 balanceFromAfter,
    uint256 balanceToBefore
  ) external;


  function getReservesList() external view returns (address[] memory);


  function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);


  function setPause(bool val) external;


  function paused() external view returns (bool);

}// MIT
pragma solidity 0.8.8;

library TransferETHHelper {

    function safeTransferETH(address _to, uint256 _value) internal {

        (bool success,) = _to.call{value:_value}(new bytes(0));
        require(success, 'TH ETH_TRANSFER_FAILED');
    }
}// MIT
pragma solidity 0.8.8;

interface IJAdminTools {

    function isAdmin(address account) external view returns (bool);

    function addAdmin(address account) external;

    function removeAdmin(address account) external;

    function renounceAdmin() external;


    event AdminAdded(address account);
    event AdminRemoved(address account);
}// MIT
pragma solidity 0.8.8;

interface IJTrancheTokens {

    function mint(address account, uint256 value) external;

    function burn(uint256 value) external;

}// MIT
pragma solidity 0.8.8;

interface IJTranchesDeployer {

    function deployNewTrancheATokens(string memory _nameA, string memory _symbolA, uint256 _trNum) external returns (address);

    function deployNewTrancheBTokens(string memory _nameB, string memory _symbolB, uint256 _trNum) external returns (address);

}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT
pragma solidity 0.8.8;


contract JAaveStorage is OwnableUpgradeable {

    address public constant ETH_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint16 public constant AAVE_REFERRAL_CODE = 0;

    uint256 public constant PERCENT_DIVIDER = 10000;  // percentage divider

    struct TrancheAddresses {
        address buyerCoinAddress;       // ETH (ETH_ADDR) or DAI or other supported tokens
        address aTokenAddress;          // aETH or aDAI or other aToken
        address ATrancheAddress;
        address BTrancheAddress;
    }

    struct TrancheParameters {
        uint256 trancheAFixedPercentage;    // fixed percentage (i.e. 4% = 0.04 * 10^18 = 40000000000000000)
        uint256 trancheALastActionBlock;
        uint256 storedTrancheAPrice;
        uint256 trancheACurrentRPB;
        uint16 redemptionPercentage;        // percentage with 2 decimals (divided by 10000, i.e. 95% is 9500)
        uint8 underlyingDecimals;
    }

    address public adminToolsAddress;
    address public feesCollectorAddress;
    address public tranchesDeployerAddress;
    address public lendingPoolAddressProvider;
    address public wethGatewayAddress;
    address public aaveIncentiveControllerAddress;
    address public wrappedEthAddress;

    uint256 public tranchePairsCounter;
    uint256 public totalBlocksPerYear; 
    uint32 public redeemTimeout;

    mapping(uint256 => TrancheAddresses) public trancheAddresses;
    mapping(uint256 => TrancheParameters) public trancheParameters;
    mapping(address => uint256) public lastActivity;
    mapping(uint256 => bool) public trancheDepositEnabled;
    address public rewardsToken;  // slice rewards
}


contract JAaveStorageV2 is JAaveStorage {

    struct StakingDetails {
        uint256 startTime;
        uint256 amount;
    }

    address public incentivesControllerAddress;

    mapping (address => mapping(uint256 => uint256)) public stakeCounterTrA;
    mapping (address => mapping(uint256 => uint256)) public stakeCounterTrB;
    mapping (address => mapping (uint256 => mapping (uint256 => StakingDetails))) public stakingDetailsTrancheA;
    mapping (address => mapping (uint256 => mapping (uint256 => StakingDetails))) public stakingDetailsTrancheB;
}// MIT
pragma solidity 0.8.8;

interface IJAave {

    event TrancheAddedToProtocol(uint256 trancheNum, address trancheA, address trancheB);
    event TrancheATokenMinted(uint256 trancheNum, address buyer, uint256 amount, uint256 taAmount);
    event TrancheBTokenMinted(uint256 trancheNum, address buyer, uint256 amount, uint256 tbAmount);
    event TrancheATokenRedemption(uint256 trancheNum, address burner, uint256 amount, uint256 userAmount, uint256 feesAmount);
    event TrancheBTokenRedemption(uint256 trancheNum, address burner, uint256 amount, uint256 userAmount, uint256 feesAmount);

    function getSingleTrancheUserStakeCounterTrA(address _user, uint256 _trancheNum) external view returns (uint256);

    function getSingleTrancheUserStakeCounterTrB(address _user, uint256 _trancheNum) external view returns (uint256);

    function getSingleTrancheUserSingleStakeDetailsTrA(address _user, uint256 _trancheNum, uint256 _num) external view returns (uint256, uint256);

    function getSingleTrancheUserSingleStakeDetailsTrB(address _user, uint256 _trancheNum, uint256 _num) external view returns (uint256, uint256);

    function getIncentivesControllerAddress() external view returns (address);

    function setIncentivesControllerAddress(address _incentivesController) external;

    function setTrAStakingDetails(uint256 _trancheNum, address _account, uint256 _stkNum, uint256 _amount, uint256 _time) external;

    function setTrBStakingDetails(uint256 _trancheNum, address _account, uint256 _stkNum, uint256 _amount, uint256 _time) external;

}// MIT
pragma solidity 0.8.8;

abstract contract TokenInterface {
    function deposit() external virtual payable;
    function withdraw(uint256) external virtual;
}// MIT
pragma solidity 0.8.8;

interface IWETHGateway {

  function depositETH() external payable;

  function withdrawETH(uint256 amount) external;

}// agpl-3.0
pragma solidity 0.8.8;

library DistributionTypes {

  struct AssetConfigInput {
    uint104 emissionPerSecond;
    uint256 totalStaked;
    address underlyingAsset;
  }

  struct UserStakeInput {
    address underlyingAsset;
    uint256 stakedByUser;
    uint256 totalStaked;
  }
}// agpl-3.0
pragma solidity 0.8.8;


interface IAaveDistributionManager {

  
  event AssetConfigUpdated(address indexed asset, uint256 emission);
  event AssetIndexUpdated(address indexed asset, uint256 index);
  event UserIndexUpdated(address indexed user, address indexed asset, uint256 index);
  event DistributionEndUpdated(uint256 newDistributionEnd);

  function setDistributionEnd(uint256 distributionEnd) external;


  function getDistributionEnd() external view returns (uint256);


  function DISTRIBUTION_END() external view returns(uint256);


   function getUserAssetData(address user, address asset) external view returns (uint256);


   function getAssetData(address asset) external view returns (uint256, uint256, uint256);

}// MIT
pragma solidity 0.8.8;


interface IAaveIncentivesController is IAaveDistributionManager {

  
  event RewardsAccrued(address indexed user, uint256 amount);
  
  event RewardsClaimed(
    address indexed user,
    address indexed to,
    address indexed claimer,
    uint256 amount
  );

  event ClaimerSet(address indexed user, address indexed claimer);

  function setClaimer(address user, address claimer) external;


  function getClaimer(address user) external view returns (address);


  function configureAssets(address[] calldata assets, uint256[] calldata emissionsPerSecond)
    external;



  function handleAction(
    address asset,
    uint256 userBalance,
    uint256 totalSupply
  ) external;


  function getRewardsBalance(address[] calldata assets, address user)
    external
    view
    returns (uint256);


  function claimRewards(
    address[] calldata assets,
    uint256 amount,
    address to
  ) external returns (uint256);


  function claimRewardsOnBehalf(
    address[] calldata assets,
    uint256 amount,
    address user,
    address to
  ) external returns (uint256);


  function getUserUnclaimedRewards(address user) external view returns (uint256);


  function REWARD_TOKEN() external view returns (address);

}// MIT
pragma solidity 0.8.8;

interface IIncentivesController {

    function trancheANewEnter(address account, address trancheA) external;

    function trancheBNewEnter(address account, address trancheA) external;


    function claimRewardsAllMarkets(address _account) external returns (bool);

    function claimRewardSingleMarketTrA(uint256 _idxMarket, uint256 _distCount, address _account) external;

    function claimRewardSingleMarketTrB(uint256 _idxMarket, uint256 _distCount, address _account) external;

}// MIT
pragma solidity 0.8.8;
// pragma experimental ABIEncoderV2; // needed for getAllAtokens and getAllReservesTokens



contract JAave is OwnableUpgradeable, ReentrancyGuardUpgradeable, JAaveStorageV2, IJAave {

    using SafeMathUpgradeable for uint256;

    function initialize(address _adminTools, 
            address _feesCollector, 
            address _tranchesDepl,
            address _aaveIncentiveController,
            address _wethAddress,
            uint256 _blocksPerYear) external initializer() {

        OwnableUpgradeable.__Ownable_init();
        adminToolsAddress = _adminTools;
        feesCollectorAddress = _feesCollector;
        tranchesDeployerAddress = _tranchesDepl;
        aaveIncentiveControllerAddress = _aaveIncentiveController;
        redeemTimeout = 3; //default
        wrappedEthAddress = _wethAddress;
        totalBlocksPerYear = _blocksPerYear;
    }

    modifier onlyAdmins() {

        require(IJAdminTools(adminToolsAddress).isAdmin(msg.sender), "JAave: not an Admin");
        _;
    }

    fallback() external payable {}
    receive() external payable {}

    function setNewEnvironment(address _adminTools, 
            address _feesCollector, 
            address _tranchesDepl,
            address _aaveIncentiveController,
            address _wethAddress) external onlyOwner{

        require((_adminTools != address(0)) && (_feesCollector != address(0)) && (_tranchesDepl != address(0)), "JAave: check addresses");
        adminToolsAddress = _adminTools;
        feesCollectorAddress = _feesCollector;
        tranchesDeployerAddress = _tranchesDepl;
        aaveIncentiveControllerAddress = _aaveIncentiveController;
        wrappedEthAddress = _wethAddress;
    }

    function setIncentivesControllerAddress(address _incentivesController) external override onlyAdmins {

        incentivesControllerAddress = _incentivesController;
    }

    function getIncentivesControllerAddress() external view override returns (address) {

        return incentivesControllerAddress;
    }

    function setBlocksPerYear(uint256 _newValue) external onlyAdmins {

        require(_newValue > 0, "JAave: new value not allowed");
        totalBlocksPerYear = _newValue;
    }

    function setAavePoolAddressProvider(address _addressProviderContract) external onlyAdmins {

        lendingPoolAddressProvider = _addressProviderContract;
    }

    function setAaveIncentiveControllerAddress(address _aaveIncentiveController) external onlyAdmins {

        aaveIncentiveControllerAddress = _aaveIncentiveController;
    }

    function getDataProvider() public view returns(IAaveProtocolDataProvider) {

        require(lendingPoolAddressProvider != address(0), "JAave: set lending pool address provider");
        return IAaveProtocolDataProvider(ILendingPoolAddressesProvider(lendingPoolAddressProvider)
                    .getAddress(0x0100000000000000000000000000000000000000000000000000000000000000));
    }

    function getAllATokens() external view returns(IAaveProtocolDataProvider.TokenData[] memory) {

        require(lendingPoolAddressProvider != address(0), "JAave: set lending pool address provider");
        IAaveProtocolDataProvider aaveProtocolDataProvider = getDataProvider();
        return aaveProtocolDataProvider.getAllATokens();
    }

    function getAllReservesTokens() external view returns(IAaveProtocolDataProvider.TokenData[] memory) {

        require(lendingPoolAddressProvider != address(0), "JAave: set lending pool address provider");
        IAaveProtocolDataProvider aaveProtocolDataProvider = getDataProvider();
        return aaveProtocolDataProvider.getAllReservesTokens();
    }

    function getAaveReserveData(uint256 _trancheNum) external view returns(uint256 availableLiquidity, uint256 totalStableDebt,
            uint256 totalVariableDebt, uint256 liquidityRate, uint256 variableBorrowRate, uint256 stableBorrowRate,
            uint256 averageStableBorrowRate, uint256 liquidityIndex, uint256 variableBorrowIndex,
            uint40 lastUpdateTimestamp) {

        require(lendingPoolAddressProvider != address(0), "JAave: set lending pool address provider");
        IAaveProtocolDataProvider aaveProtocolDataProvider = getDataProvider();
        address asset = trancheAddresses[_trancheNum].buyerCoinAddress;
        if (asset == ETH_ADDR)
            asset = wrappedEthAddress;
        return aaveProtocolDataProvider.getReserveData(asset);
    }

    function getLendingPool() external view returns (address) {

        return ILendingPoolAddressesProvider(lendingPoolAddressProvider).getLendingPool();
    }

    function changeToWeth(address _token) private view returns(address) {

        if (_token == ETH_ADDR) {
            return wrappedEthAddress;
        }
        return _token;
    }

    function setWETHGatewayAddress(address _wethGatewayAddress) external onlyAdmins {

        wethGatewayAddress = _wethGatewayAddress;
    }

    function aaveWithdraw(address _tokenAddr, uint256 _amount, address _to) internal {

        address lendingPool = ILendingPoolAddressesProvider(lendingPoolAddressProvider).getLendingPool();
        _tokenAddr = changeToWeth(_tokenAddr);

        uint256 oldBalance;
        uint256 newBalance;
        if (_tokenAddr == wrappedEthAddress) {
            oldBalance = getEthBalance();
            ILendingPool(lendingPool).withdraw(_tokenAddr, _amount, address(this));
            uint256 wethBal = IERC20Upgradeable(wrappedEthAddress).balanceOf(address(this));
            SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(wrappedEthAddress), wethGatewayAddress, wethBal);
            IWETHGateway(wethGatewayAddress).withdrawETH(wethBal);
            newBalance = getEthBalance();
            if (newBalance > oldBalance)
                TransferETHHelper.safeTransferETH(_to, _amount);
        } else {
            ILendingPool(lendingPool).withdraw(_tokenAddr, _amount, _to);
        }
    }

    function setDecimals(uint256 _trancheNum, uint8 _underlyingDec) external onlyAdmins {

        require(_underlyingDec <= 18, "JAave: too many decimals");
        trancheParameters[_trancheNum].underlyingDecimals = _underlyingDec;
    }

    function setTrancheRedemptionPercentage(uint256 _trancheNum, uint16 _redeemPercent) external onlyAdmins {

        trancheParameters[_trancheNum].redemptionPercentage = _redeemPercent;
    }

    function setRedemptionTimeout(uint32 _blockNum) external onlyAdmins {

        redeemTimeout = _blockNum;
    }

    function setTrancheAFixedPercentage(uint256 _trancheNum, uint256 _newTrAPercentage) external onlyAdmins {

        trancheParameters[_trancheNum].trancheAFixedPercentage = _newTrAPercentage;
        trancheParameters[_trancheNum].storedTrancheAPrice = setTrancheAExchangeRate(_trancheNum);
    }

    function addTrancheToProtocol(address _buyerCoinAddress, 
            address _aTokenAddress, 
            string memory _nameA, 
            string memory _symbolA, 
            string memory _nameB, 
            string memory _symbolB, 
            uint256 _fixedRpb, 
            uint8 _underlyingDec) external onlyAdmins nonReentrant {

        require(tranchesDeployerAddress != address(0), "JAave: set tranche eth deployer");
        require(lendingPoolAddressProvider != address(0), "JAave: set lending pool address provider");

        trancheAddresses[tranchePairsCounter].buyerCoinAddress = _buyerCoinAddress;
        trancheAddresses[tranchePairsCounter].aTokenAddress = _aTokenAddress;
        trancheAddresses[tranchePairsCounter].ATrancheAddress = 
                IJTranchesDeployer(tranchesDeployerAddress).deployNewTrancheATokens(_nameA, _symbolA, tranchePairsCounter);
        trancheAddresses[tranchePairsCounter].BTrancheAddress = 
                IJTranchesDeployer(tranchesDeployerAddress).deployNewTrancheBTokens(_nameB, _symbolB, tranchePairsCounter); 
        
        trancheParameters[tranchePairsCounter].underlyingDecimals = _underlyingDec;
        trancheParameters[tranchePairsCounter].trancheAFixedPercentage = _fixedRpb;
        trancheParameters[tranchePairsCounter].trancheALastActionBlock = block.timestamp;
        trancheParameters[tranchePairsCounter].storedTrancheAPrice = uint256(1e18);

        trancheParameters[tranchePairsCounter].redemptionPercentage = 10000;  //default value 100%, no fees

        calcRPBFromPercentage(tranchePairsCounter); // initialize tranche A RPB

        emit TrancheAddedToProtocol(tranchePairsCounter, trancheAddresses[tranchePairsCounter].ATrancheAddress, trancheAddresses[tranchePairsCounter].BTrancheAddress);

        tranchePairsCounter = tranchePairsCounter.add(1);
    } 

    function setTrancheDeposit(uint256 _trancheNum, bool _enable) external onlyAdmins {

        trancheDepositEnabled[_trancheNum] = _enable;
    }
    
    function setTrancheAExchangeRate(uint256 _trancheNum) internal returns (uint256) {

        calcRPBFromPercentage(_trancheNum);
        uint256 deltaTime = (block.timestamp).sub(trancheParameters[_trancheNum].trancheALastActionBlock);
        uint256 deltaPrice = (trancheParameters[_trancheNum].trancheACurrentRPB).mul(deltaTime);
        trancheParameters[_trancheNum].storedTrancheAPrice = (trancheParameters[_trancheNum].storedTrancheAPrice).add(deltaPrice);
        trancheParameters[_trancheNum].trancheALastActionBlock = block.timestamp;
        return trancheParameters[_trancheNum].storedTrancheAPrice;
    }

    function getTrancheAExchangeRate(uint256 _trancheNum) public view returns (uint256) {

        return trancheParameters[_trancheNum].storedTrancheAPrice;
    }

    function getTrancheACurrentRPB(uint256 _trancheNum) external view returns (uint256) {

        return trancheParameters[_trancheNum].trancheACurrentRPB;
    }

    function calcRPBFromPercentage(uint256 _trancheNum) public returns (uint256) {

        trancheParameters[_trancheNum].trancheACurrentRPB = trancheParameters[_trancheNum].storedTrancheAPrice
                        .mul(trancheParameters[_trancheNum].trancheAFixedPercentage).div(totalBlocksPerYear).div(1e18);
        return trancheParameters[_trancheNum].trancheACurrentRPB;
    }

    function getTrAValue(uint256 _trancheNum) public view returns (uint256 trANormValue) {

        uint256 totASupply = IERC20Upgradeable(trancheAddresses[_trancheNum].ATrancheAddress).totalSupply();
        uint256 diffDec = uint256(18).sub(uint256(trancheParameters[_trancheNum].underlyingDecimals));
            trANormValue = totASupply.mul(getTrancheAExchangeRate(_trancheNum)).div(1e18).div(10 ** diffDec);
        return trANormValue;
    }

    function getTrBValue(uint256 _trancheNum) public view returns (uint256) {

        uint256 totProtValue = getTotalValue(_trancheNum);
        uint256 totTrAValue = getTrAValue(_trancheNum);
        if (totProtValue > totTrAValue) {
            return totProtValue.sub(totTrAValue);
        } else
            return 0;
    }

    function getTotalValue(uint256 _trancheNum) public view returns (uint256) {

        return getTokenBalance(trancheAddresses[_trancheNum].aTokenAddress);
    }

    function getTrancheBExchangeRate(uint256 _trancheNum, uint256 _newAmount) public view returns (uint256 tbPrice) {

        uint256 totTrBValue;

        uint256 totBSupply = IERC20Upgradeable(trancheAddresses[_trancheNum].BTrancheAddress).totalSupply(); // 18 decimals
        uint256 underlyingDec = uint256(trancheParameters[_trancheNum].underlyingDecimals);
        uint256 normAmount = _newAmount;
        if (underlyingDec < 18)
            normAmount = _newAmount.mul(10 ** uint256(18).sub(underlyingDec));
        uint256 newBSupply = totBSupply.add(normAmount); // 18 decimals

        uint256 totProtValue = getTotalValue(_trancheNum).add(_newAmount); //underlying token decimals
        uint256 totTrAValue = getTrAValue(_trancheNum); //underlying token decimals
        if (totProtValue >= totTrAValue)
            totTrBValue = totProtValue.sub(totTrAValue); //underlying token decimals
        else
            totTrBValue = 0;
        if (underlyingDec < 18 && totTrBValue > 0) {
            totTrBValue = totTrBValue.mul(10 ** (uint256(18).sub(underlyingDec)));
        }

        if (totTrBValue > 0 && newBSupply > 0) {
            tbPrice = totTrBValue.mul(1e18).div(newBSupply);
        } else
            tbPrice = uint256(1e18);

        return tbPrice;
    }
 
    function setTrAStakingDetails(uint256 _trancheNum, address _account, uint256 _stkNum, uint256 _amount, uint256 _time) external override onlyAdmins {

        stakeCounterTrA[_account][_trancheNum] = _stkNum;
        StakingDetails storage details = stakingDetailsTrancheA[_account][_trancheNum][_stkNum];
        details.startTime = _time;
        details.amount = _amount;
    }

    function decreaseTrancheATokenFromStake(uint256 _trancheNum, uint256 _amount) internal {

        uint256 senderCounter = stakeCounterTrA[msg.sender][_trancheNum];
        uint256 tmpAmount = _amount;
        for (uint i = 1; i <= senderCounter; i++) {
            StakingDetails storage details = stakingDetailsTrancheA[msg.sender][_trancheNum][i];
            if (details.amount > 0) {
                if (details.amount <= tmpAmount) {
                    tmpAmount = tmpAmount.sub(details.amount);
                    details.amount = 0;
                } else {
                    details.amount = details.amount.sub(tmpAmount);
                    tmpAmount = 0;
                }
            }
            if (tmpAmount == 0)
                break;
        }
    }

    function getSingleTrancheUserStakeCounterTrA(address _user, uint256 _trancheNum) external view override returns (uint256) {

        return stakeCounterTrA[_user][_trancheNum];
    }

    function getSingleTrancheUserSingleStakeDetailsTrA(address _user, uint256 _trancheNum, uint256 _num) external view override returns (uint256, uint256) {

        return (stakingDetailsTrancheA[_user][_trancheNum][_num].startTime, stakingDetailsTrancheA[_user][_trancheNum][_num].amount);
    }

    function setTrBStakingDetails(uint256 _trancheNum, address _account, uint256 _stkNum, uint256 _amount, uint256 _time) external override onlyAdmins {

        stakeCounterTrB[_account][_trancheNum] = _stkNum;
        StakingDetails storage details = stakingDetailsTrancheB[_account][_trancheNum][_stkNum];
        details.startTime = _time;
        details.amount = _amount; 
    }
    
    function decreaseTrancheBTokenFromStake(uint256 _trancheNum, uint256 _amount) internal {

        uint256 senderCounter = stakeCounterTrB[msg.sender][_trancheNum];
        uint256 tmpAmount = _amount;
        for (uint i = 1; i <= senderCounter; i++) {
            StakingDetails storage details = stakingDetailsTrancheB[msg.sender][_trancheNum][i];
            if (details.amount > 0) {
                if (details.amount <= tmpAmount) {
                    tmpAmount = tmpAmount.sub(details.amount);
                    details.amount = 0;
                } else {
                    details.amount = details.amount.sub(tmpAmount);
                    tmpAmount = 0;
                }
            }
            if (tmpAmount == 0)
                break;
        }
    }

    function getSingleTrancheUserStakeCounterTrB(address _user, uint256 _trancheNum) external view override returns (uint256) {

        return stakeCounterTrB[_user][_trancheNum];
    }

    function getSingleTrancheUserSingleStakeDetailsTrB(address _user, uint256 _trancheNum, uint256 _num) external view override returns (uint256, uint256) {

        return (stakingDetailsTrancheB[_user][_trancheNum][_num].startTime, stakingDetailsTrancheB[_user][_trancheNum][_num].amount);
    }

    function buyTrancheAToken(uint256 _trancheNum, uint256 _amount) external payable nonReentrant {

        require(trancheDepositEnabled[_trancheNum], "JAave: tranche deposit disabled");
        uint256 prevAaveTokenBalance = getTokenBalance(trancheAddresses[_trancheNum].aTokenAddress);
        address lendingPool = ILendingPoolAddressesProvider(lendingPoolAddressProvider).getLendingPool();
        address _tokenAddr = trancheAddresses[_trancheNum].buyerCoinAddress;
        if (_tokenAddr == ETH_ADDR) {
            require(msg.value == _amount, "JAave: msg.value not equal to amount");
            IWETHGateway(wethGatewayAddress).depositETH{value: msg.value}();
            _tokenAddr = wrappedEthAddress;
        } else {
            require(IERC20Upgradeable(_tokenAddr).allowance(msg.sender, address(this)) >= _amount, "JAave: allowance failed buying tranche A");
            SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable(_tokenAddr), msg.sender, address(this), _amount);
        }

        SafeERC20Upgradeable.safeApprove(IERC20Upgradeable(_tokenAddr), lendingPool, _amount);
        ILendingPool(lendingPool).deposit(_tokenAddr, _amount, address(this), AAVE_REFERRAL_CODE);
        
        uint256 newAaveTokenBalance = getTokenBalance(trancheAddresses[_trancheNum].aTokenAddress);
        setTrancheAExchangeRate(_trancheNum);
        uint256 taAmount;
        if (newAaveTokenBalance > prevAaveTokenBalance) {
            uint256 diffDec = uint256(18).sub(uint256(trancheParameters[_trancheNum].underlyingDecimals));
            uint256 normAmount = _amount.mul(10 ** diffDec);
            taAmount = normAmount.mul(1e18).div(trancheParameters[_trancheNum].storedTrancheAPrice);
            IIncentivesController(incentivesControllerAddress).trancheANewEnter(msg.sender, trancheAddresses[_trancheNum].ATrancheAddress);
            IJTrancheTokens(trancheAddresses[_trancheNum].ATrancheAddress).mint(msg.sender, taAmount);
        }

        stakeCounterTrA[msg.sender][_trancheNum] = stakeCounterTrA[msg.sender][_trancheNum].add(1);
        StakingDetails storage details = stakingDetailsTrancheA[msg.sender][_trancheNum][stakeCounterTrA[msg.sender][_trancheNum]];
        details.startTime = block.timestamp;
        details.amount = taAmount;

        lastActivity[msg.sender] = block.number;
        emit TrancheATokenMinted(_trancheNum, msg.sender, _amount, taAmount);
    }

    function redeemTrancheAToken(uint256 _trancheNum, uint256 _amount) external nonReentrant {

        require((block.number).sub(lastActivity[msg.sender]) >= redeemTimeout, "JAave: redeem timeout not expired on tranche A");
        require(IERC20Upgradeable(trancheAddresses[_trancheNum].ATrancheAddress).allowance(msg.sender, address(this)) >= _amount, "JAave: allowance failed redeeming tranche A");
        SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable(trancheAddresses[_trancheNum].ATrancheAddress), msg.sender, address(this), _amount);

        setTrancheAExchangeRate(_trancheNum);

        uint256 taAmount = _amount.mul(trancheParameters[_trancheNum].storedTrancheAPrice).div(1e18);
        uint256 diffDec = uint256(18).sub(uint256(trancheParameters[_trancheNum].underlyingDecimals));
        uint256 normAmount = taAmount.div(10 ** diffDec);
        uint256 taTotAmount = getTrAValue(_trancheNum);
        if (normAmount > taTotAmount)
            normAmount = taTotAmount;

        uint256 userAmount = normAmount.mul(trancheParameters[_trancheNum].redemptionPercentage).div(PERCENT_DIVIDER);
        aaveWithdraw(trancheAddresses[_trancheNum].buyerCoinAddress, userAmount, msg.sender);
        uint256 feesAmount = normAmount.sub(userAmount);
        if (feesAmount > 0)
            aaveWithdraw(trancheAddresses[_trancheNum].buyerCoinAddress, feesAmount, feesCollectorAddress);
        
        bool rewClaimCompleted = IIncentivesController(incentivesControllerAddress).claimRewardsAllMarkets(msg.sender);

        if (rewClaimCompleted && _amount > 0)
            decreaseTrancheATokenFromStake(_trancheNum, _amount);

        IJTrancheTokens(trancheAddresses[_trancheNum].ATrancheAddress).burn(_amount);
        lastActivity[msg.sender] = block.number;
        emit TrancheATokenRedemption(_trancheNum, msg.sender, _amount, userAmount, feesAmount);
    }

    function buyTrancheBToken(uint256 _trancheNum, uint256 _amount) external payable nonReentrant {

        require(trancheDepositEnabled[_trancheNum], "JAave: tranche deposit disabled");
        setTrancheAExchangeRate(_trancheNum);
        uint256 diffDec = uint256(18).sub(uint256(trancheParameters[_trancheNum].underlyingDecimals));
        uint256 normAmount = _amount.mul(10 ** diffDec);
        uint256 tbAmount = normAmount.mul(1e18).div(getTrancheBExchangeRate(_trancheNum, _amount));
        uint256 prevAaveTokenBalance = getTokenBalance(trancheAddresses[_trancheNum].aTokenAddress);
        address lendingPool = ILendingPoolAddressesProvider(lendingPoolAddressProvider).getLendingPool();
        address _tokenAddr = trancheAddresses[_trancheNum].buyerCoinAddress;
        if (_tokenAddr == ETH_ADDR) {
            require(msg.value == _amount, "JAave: msg.value not equal to amount");
            IWETHGateway(wethGatewayAddress).depositETH{value: msg.value}();
            _tokenAddr = wrappedEthAddress;
        } else {
            require(IERC20Upgradeable(_tokenAddr).allowance(msg.sender, address(this)) >= _amount, "JAave: allowance failed buying tranche B");
            SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable(_tokenAddr), msg.sender, address(this), _amount);
        }

        SafeERC20Upgradeable.safeApprove(IERC20Upgradeable(_tokenAddr), lendingPool, _amount);
        ILendingPool(lendingPool).deposit(_tokenAddr, _amount, address(this), AAVE_REFERRAL_CODE);

        uint256 newAaveTokenBalance = getTokenBalance(trancheAddresses[_trancheNum].aTokenAddress);
        if (newAaveTokenBalance > prevAaveTokenBalance) {
            IIncentivesController(incentivesControllerAddress).trancheBNewEnter(msg.sender, trancheAddresses[_trancheNum].BTrancheAddress);
            IJTrancheTokens(trancheAddresses[_trancheNum].BTrancheAddress).mint(msg.sender, tbAmount);
        } else 
            tbAmount = 0;

        stakeCounterTrB[msg.sender][_trancheNum] = stakeCounterTrB[msg.sender][_trancheNum].add(1);
        StakingDetails storage details = stakingDetailsTrancheB[msg.sender][_trancheNum][stakeCounterTrB[msg.sender][_trancheNum]];
        details.startTime = block.timestamp;
        details.amount = tbAmount; 

        lastActivity[msg.sender] = block.number;
        emit TrancheBTokenMinted(_trancheNum, msg.sender, _amount, tbAmount);
    }

    function redeemTrancheBToken(uint256 _trancheNum, uint256 _amount) external nonReentrant {

        require((block.number).sub(lastActivity[msg.sender]) >= redeemTimeout, "JAave: redeem timeout not expired on tranche B");
        require(IERC20Upgradeable(trancheAddresses[_trancheNum].BTrancheAddress).allowance(msg.sender, address(this)) >= _amount, "JAave: allowance failed redeeming tranche B");
        SafeERC20Upgradeable.safeTransferFrom(IERC20Upgradeable(trancheAddresses[_trancheNum].BTrancheAddress), msg.sender, address(this), _amount);

        setTrancheAExchangeRate(_trancheNum);
        uint256 tbAmount = _amount.mul(getTrancheBExchangeRate(_trancheNum, 0)).div(1e18);
        uint256 diffDec = uint256(18).sub(uint256(trancheParameters[_trancheNum].underlyingDecimals));
        uint256 normAmount = tbAmount.div(10 ** diffDec);
        uint256 tbTotAmount = getTrBValue(_trancheNum);
        if (normAmount > tbTotAmount)
            normAmount = tbTotAmount;

        uint256 userAmount = normAmount.mul(trancheParameters[_trancheNum].redemptionPercentage).div(PERCENT_DIVIDER);
        aaveWithdraw(trancheAddresses[_trancheNum].buyerCoinAddress, userAmount, msg.sender);
        uint256 feesAmount = normAmount.sub(userAmount);
        if (feesAmount > 0)
            aaveWithdraw(trancheAddresses[_trancheNum].buyerCoinAddress, feesAmount, feesCollectorAddress);

        bool rewClaimCompleted = IIncentivesController(incentivesControllerAddress).claimRewardsAllMarkets(msg.sender);

        if (rewClaimCompleted && _amount > 0)
            decreaseTrancheBTokenFromStake(_trancheNum, _amount);

        IJTrancheTokens(trancheAddresses[_trancheNum].BTrancheAddress).burn(_amount);
        lastActivity[msg.sender] = block.number;
        emit TrancheBTokenRedemption(_trancheNum, msg.sender, _amount, userAmount, feesAmount);
    }

    function getTokenBalance(address _tokenContract) public view returns (uint256) {

        return IERC20Upgradeable(_tokenContract).balanceOf(address(this));
    }

    function getEthBalance() public view returns (uint256) {

        return address(this).balance;
    }

    function transferTokenToFeesCollector(address _tokenContract, uint256 _amount) external onlyAdmins {

        SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(_tokenContract), feesCollectorAddress, _amount);
    }

    function withdrawEthToFeesCollector(uint256 _amount) external onlyAdmins {

        TransferETHHelper.safeTransferETH(feesCollectorAddress, _amount);
    }

    function getAaveUnclaimedRewards() public view returns(uint256) {

        return IAaveIncentivesController(aaveIncentiveControllerAddress).getUserUnclaimedRewards(address(this));
    }

    function claimAaveRewards(/*address _rewardToken, uint256 _amount*/) external {

        address[] memory assets = new address[](tranchePairsCounter);
        for (uint256 i = 0; i < tranchePairsCounter; i++) {
            assets[i] = trancheAddresses[i].aTokenAddress;
        }

        uint256 claimableRewards = getAaveUnclaimedRewards();
        if (claimableRewards > 0)
            IAaveIncentivesController(aaveIncentiveControllerAddress).claimRewards(assets, claimableRewards, feesCollectorAddress);
    }

    function claimAaveRewardsSingleAsset(address _assetToken, uint256 _amount) external {

        address[] memory assets = new address[](1);
        assets[0] = _assetToken;
        if (_amount > 0)
            IAaveIncentivesController(aaveIncentiveControllerAddress).claimRewards(assets, _amount, feesCollectorAddress);
    }

}