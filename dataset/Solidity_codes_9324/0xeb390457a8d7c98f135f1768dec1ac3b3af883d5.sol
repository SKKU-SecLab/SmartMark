

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

  uint256 internal constant _WAD = 1e18;
  uint256 internal constant _HALF_WAD = _WAD / 2;

  uint256 internal constant _RAY = 1e27;
  uint256 internal constant _HALF_RAY = _RAY / 2;

  uint256 internal constant _WAD_RAY_RATIO = 1e9;

  function ray() internal pure returns (uint256) {

    return _RAY;
  }

  function wad() internal pure returns (uint256) {

    return _WAD;
  }

  function halfRay() internal pure returns (uint256) {

    return _HALF_RAY;
  }

  function halfWad() internal pure returns (uint256) {

    return _HALF_WAD;
  }

  function wadMul(uint256 a, uint256 b) internal pure returns (uint256) {

    return _HALF_WAD.add(a.mul(b)).div(_WAD);
  }

  function wadDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 halfB = b / 2;

    return halfB.add(a.mul(_WAD)).div(b);
  }

  function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {

    return _HALF_RAY.add(a.mul(b)).div(_RAY);
  }

  function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 halfB = b / 2;

    return halfB.add(a.mul(_RAY)).div(b);
  }

  function rayToWad(uint256 a) internal pure returns (uint256) {

    uint256 halfRatio = _WAD_RAY_RATIO / 2;

    return halfRatio.add(a).div(_WAD_RAY_RATIO);
  }

  function wadToRay(uint256 a) internal pure returns (uint256) {

    return a.mul(_WAD_RAY_RATIO);
  }

  function rayPow(uint256 x, uint256 n) internal pure returns (uint256 z) {

    z = n % 2 != 0 ? x : _RAY;

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

  function grantRole(bytes32 role, address account) external;


  function revokeRole(bytes32 role, address account) external;


  function renounceRole(bytes32 role, address account) external;


  function MANAGER_ROLE() external view returns (bytes32);


  function MINTER_ROLE() external view returns (bytes32);


  function hasRole(bytes32 role, address account) external view returns (bool);


  function getRoleMemberCount(bytes32 role) external view returns (uint256);


  function getRoleMember(bytes32 role, uint256 index) external view returns (address);


  function getRoleAdmin(bytes32 role) external view returns (bytes32);

}

interface IConfigProvider {

  struct CollateralConfig {
    address collateralType;
    uint256 debtLimit;
    uint256 liquidationRatio;
    uint256 minCollateralRatio;
    uint256 borrowRate;
    uint256 originationFee;
    uint256 liquidationBonus;
    uint256 liquidationFee;
  }

  event CollateralUpdated(
    address indexed collateralType,
    uint256 debtLimit,
    uint256 liquidationRatio,
    uint256 minCollateralRatio,
    uint256 borrowRate,
    uint256 originationFee,
    uint256 liquidationBonus,
    uint256 liquidationFee
  );
  event CollateralRemoved(address indexed collateralType);

  function setCollateralConfig(
    address _collateralType,
    uint256 _debtLimit,
    uint256 _liquidationRatio,
    uint256 _minCollateralRatio,
    uint256 _borrowRate,
    uint256 _originationFee,
    uint256 _liquidationBonus,
    uint256 _liquidationFee
  ) external;


  function removeCollateral(address _collateralType) external;


  function setCollateralDebtLimit(address _collateralType, uint256 _debtLimit) external;


  function setCollateralLiquidationRatio(address _collateralType, uint256 _liquidationRatio) external;


  function setCollateralMinCollateralRatio(address _collateralType, uint256 _minCollateralRatio) external;


  function setCollateralBorrowRate(address _collateralType, uint256 _borrowRate) external;


  function setCollateralOriginationFee(address _collateralType, uint256 _originationFee) external;


  function setCollateralLiquidationBonus(address _collateralType, uint256 _liquidationBonus) external;


  function setCollateralLiquidationFee(address _collateralType, uint256 _liquidationFee) external;


  function setMinVotingPeriod(uint256 _minVotingPeriod) external;


  function setMaxVotingPeriod(uint256 _maxVotingPeriod) external;


  function setVotingQuorum(uint256 _votingQuorum) external;


  function setProposalThreshold(uint256 _proposalThreshold) external;


  function a() external view returns (IAddressProvider);


  function collateralConfigs(uint256 _id) external view returns (CollateralConfig memory);


  function collateralIds(address _collateralType) external view returns (uint256);


  function numCollateralConfigs() external view returns (uint256);


  function minVotingPeriod() external view returns (uint256);


  function maxVotingPeriod() external view returns (uint256);


  function votingQuorum() external view returns (uint256);


  function proposalThreshold() external view returns (uint256);


  function collateralDebtLimit(address _collateralType) external view returns (uint256);


  function collateralLiquidationRatio(address _collateralType) external view returns (uint256);


  function collateralMinCollateralRatio(address _collateralType) external view returns (uint256);


  function collateralBorrowRate(address _collateralType) external view returns (uint256);


  function collateralOriginationFee(address _collateralType) external view returns (uint256);


  function collateralLiquidationBonus(address _collateralType) external view returns (uint256);


  function collateralLiquidationFee(address _collateralType) external view returns (uint256);

}

interface ISTABLEX is IERC20 {

  function mint(address account, uint256 amount) external;


  function burn(address account, uint256 amount) external;


  function a() external view returns (IAddressProvider);

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

  event OracleUpdated(address indexed asset, address oracle, address sender);
  event EurOracleUpdated(address oracle, address sender);

  function setAssetOracle(address _asset, address _oracle) external;


  function setEurOracle(address _oracle) external;


  function a() external view returns (IAddressProvider);


  function assetOracles(address _asset) external view returns (AggregatorV3Interface);


  function eurOracle() external view returns (AggregatorV3Interface);


  function getAssetPrice(address _asset) external view returns (uint256);


  function convertFrom(address _asset, uint256 _amount) external view returns (uint256);


  function convertTo(address _asset, uint256 _amount) external view returns (uint256);

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
    uint256 _collateralValue,
    uint256 _vaultDebt,
    uint256 _minRatio
  ) external view returns (uint256 healthFactor);


  function liquidationBonus(address _collateralType, uint256 _amount) external view returns (uint256 bonus);


  function applyLiquidationDiscount(address _collateralType, uint256 _amount)
    external
    view
    returns (uint256 discountedAmount);


  function isHealthy(
    uint256 _collateralValue,
    uint256 _vaultDebt,
    uint256 _minRatio
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

  function createVault(address _collateralType, address _owner) external returns (uint256);


  function setCollateralBalance(uint256 _id, uint256 _balance) external;


  function setBaseDebt(uint256 _id, uint256 _newBaseDebt) external;


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

}

interface IFeeDistributor {

  event PayeeAdded(address indexed account, uint256 shares);
  event FeeReleased(uint256 income, uint256 releasedAt);

  function release() external;


  function changePayees(address[] memory _payees, uint256[] memory _shares) external;


  function a() external view returns (IAddressProvider);


  function lastReleasedAt() external view returns (uint256);


  function getPayees() external view returns (address[] memory);


  function totalShares() external view returns (uint256);


  function shares(address payee) external view returns (uint256);

}

interface IAddressProvider {

  function setAccessController(IAccessController _controller) external;


  function setConfigProvider(IConfigProvider _config) external;


  function setVaultsCore(IVaultsCore _core) external;


  function setStableX(ISTABLEX _stablex) external;


  function setRatesManager(IRatesManager _ratesManager) external;


  function setPriceFeed(IPriceFeed _priceFeed) external;


  function setLiquidationManager(ILiquidationManager _liquidationManager) external;


  function setVaultsDataProvider(IVaultsDataProvider _vaultsData) external;


  function setFeeDistributor(IFeeDistributor _feeDistributor) external;


  function controller() external view returns (IAccessController);


  function config() external view returns (IConfigProvider);


  function core() external view returns (IVaultsCore);


  function stablex() external view returns (ISTABLEX);


  function ratesManager() external view returns (IRatesManager);


  function priceFeed() external view returns (IPriceFeed);


  function liquidationManager() external view returns (ILiquidationManager);


  function vaultsData() external view returns (IVaultsDataProvider);


  function feeDistributor() external view returns (IFeeDistributor);

}

interface IConfigProviderV1 {

  struct CollateralConfig {
    address collateralType;
    uint256 debtLimit;
    uint256 minCollateralRatio;
    uint256 borrowRate;
    uint256 originationFee;
  }

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


  function a() external view returns (IAddressProviderV1);


  function collateralConfigs(uint256 _id) external view returns (CollateralConfig memory);


  function collateralIds(address _collateralType) external view returns (uint256);


  function numCollateralConfigs() external view returns (uint256);


  function liquidationBonus() external view returns (uint256);


  function collateralDebtLimit(address _collateralType) external view returns (uint256);


  function collateralMinCollateralRatio(address _collateralType) external view returns (uint256);


  function collateralBorrowRate(address _collateralType) external view returns (uint256);


  function collateralOriginationFee(address _collateralType) external view returns (uint256);

}

interface ILiquidationManagerV1 {

  function a() external view returns (IAddressProviderV1);


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

interface IVaultsCoreV1 {

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

  event CumulativeRateUpdated(address indexed collateralType, uint256 elapsedTime, uint256 newCumulativeRate); //cumulative interest rate from deployment time T0

  event InsurancePaid(uint256 indexed vaultId, uint256 insuranceAmount, address indexed sender);

  function deposit(address _collateralType, uint256 _amount) external;


  function withdraw(uint256 _vaultId, uint256 _amount) external;


  function withdrawAll(uint256 _vaultId) external;


  function borrow(uint256 _vaultId, uint256 _amount) external;


  function repayAll(uint256 _vaultId) external;


  function repay(uint256 _vaultId, uint256 _amount) external;


  function liquidate(uint256 _vaultId) external;


  function initializeRates(address _collateralType) external;


  function refresh() external;


  function refreshCollateral(address collateralType) external;


  function upgrade(address _newVaultsCore) external;



  function a() external view returns (IAddressProviderV1);


  function availableIncome() external view returns (uint256);


  function cumulativeRates(address _collateralType) external view returns (uint256);


  function lastRefresh(address _collateralType) external view returns (uint256);

}

interface IWETH {

  function deposit() external payable;


  function transfer(address to, uint256 value) external returns (bool);


  function withdraw(uint256 wad) external;

}

interface IGovernorAlpha {

    enum ProposalState {
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    struct Proposal {
        uint256 id;

        address proposer;

        uint256 eta;

        address[] targets;

        uint256[] values;

        string[] signatures;

        bytes[] calldatas;

        uint256 startTime;

        uint endTime;

        uint256 forVotes;

        uint256 againstVotes;

        bool canceled;

        bool executed;

        mapping (address => Receipt) receipts;
    }

    struct Receipt {
        bool hasVoted;

        bool support;

        uint votes;
    }

    event ProposalCreated(uint256 id, address proposer, address[] targets, uint256[] values, string[] signatures, bytes[] calldatas, uint startTime, uint endTime, string description);

    event VoteCast(address voter, uint256 proposalId, bool support, uint256 votes);

    event ProposalCanceled(uint256 id);

    event ProposalQueued(uint256 id, uint256 eta);

    event ProposalExecuted(uint256 id);

    function propose(address[] memory targets, uint256[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description, uint256 endTime) external returns (uint);


    function queue(uint256 proposalId) external;


    function execute(uint256 proposalId) external payable;


    function cancel(uint256 proposalId) external;


    function castVote(uint256 proposalId, bool support) external;


    function getActions(uint256 proposalId) external view returns (address[] memory targets, uint256[] memory values, string[] memory signatures, bytes[] memory calldatas);


    function getReceipt(uint256 proposalId, address voter) external view returns (Receipt memory);


    function state(uint proposalId) external view returns (ProposalState);


    function quorumVotes() external view returns (uint256);


    function proposalThreshold() external view returns (uint256);

}

interface ITimelock {

  event NewAdmin(address indexed newAdmin);
  event NewPendingAdmin(address indexed newPendingAdmin);
  event NewDelay(uint256 indexed newDelay);
  event CancelTransaction(
    bytes32 indexed txHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 eta
  );
  event ExecuteTransaction(
    bytes32 indexed txHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 eta
  );
  event QueueTransaction(
    bytes32 indexed txHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 eta
  );

  function acceptAdmin() external;


  function queueTransaction(
    address target,
    uint256 value,
    string calldata signature,
    bytes calldata data,
    uint256 eta
  ) external returns (bytes32);


  function cancelTransaction(
    address target,
    uint256 value,
    string calldata signature,
    bytes calldata data,
    uint256 eta
  ) external;


  function executeTransaction(
    address target,
    uint256 value,
    string calldata signature,
    bytes calldata data,
    uint256 eta
  ) external payable returns (bytes memory);


  function delay() external view returns (uint256);


  function GRACE_PERIOD() external view returns (uint256);


  function queuedTransactions(bytes32 hash) external view returns (bool);

}

interface IVotingEscrow {

  enum LockAction { CREATE_LOCK, INCREASE_LOCK_AMOUNT, INCREASE_LOCK_TIME }

  struct LockedBalance {
    uint256 amount;
    uint256 end;
  }

  event Deposit(address indexed provider, uint256 value, uint256 locktime, LockAction indexed action, uint256 ts);
  event Withdraw(address indexed provider, uint256 value, uint256 ts);
  event Expired();

  function createLock(uint256 _value, uint256 _unlockTime) external;


  function increaseLockAmount(uint256 _value) external;


  function increaseLockLength(uint256 _unlockTime) external;


  function withdraw() external;


  function expireContract() external;


  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


  function decimals() external view returns (uint256);


  function balanceOf(address _owner) external view returns (uint256);


  function balanceOfAt(address _owner, uint256 _blockTime) external view returns (uint256);


  function stakingToken() external view returns (IERC20);

}

interface IMIMO is IERC20 {


  function burn(address account, uint256 amount) external;

  
  function mint(address account, uint256 amount) external;


}

interface ISupplyMiner {


  function baseDebtChanged(address user, uint256 newBaseDebt) external;

}

interface IDebtNotifier {


  function debtChanged(uint256 _vaultId) external;


  function setCollateralSupplyMiner(address collateral, ISupplyMiner supplyMiner) external;


  function a() external view returns (IGovernanceAddressProvider);


	function collateralSupplyMinerMapping(address collateral) external view returns (ISupplyMiner);

}

interface IGovernanceAddressProvider {

  function setParallelAddressProvider(IAddressProvider _parallel) external;


  function setMIMO(IMIMO _mimo) external;


  function setDebtNotifier(IDebtNotifier _debtNotifier) external;


  function setGovernorAlpha(IGovernorAlpha _governorAlpha) external;


  function setTimelock(ITimelock _timelock) external;


  function setVotingEscrow(IVotingEscrow _votingEscrow) external;


  function controller() external view returns (IAccessController);


  function parallel() external view returns (IAddressProvider);


  function mimo() external view returns (IMIMO);


  function debtNotifier() external view returns (IDebtNotifier);


  function governorAlpha() external view returns (IGovernorAlpha);


  function timelock() external view returns (ITimelock);


  function votingEscrow() external view returns (IVotingEscrow);

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

  event InsurancePaid(uint256 indexed vaultId, uint256 insuranceAmount, address indexed sender);

  function deposit(address _collateralType, uint256 _amount) external;


  function depositETH() external payable;


  function depositByVaultId(uint256 _vaultId, uint256 _amount) external;


  function depositETHByVaultId(uint256 _vaultId) external payable;


  function depositAndBorrow(
    address _collateralType,
    uint256 _depositAmount,
    uint256 _borrowAmount
  ) external;


  function depositETHAndBorrow(uint256 _borrowAmount) external payable;


  function withdraw(uint256 _vaultId, uint256 _amount) external;


  function withdrawETH(uint256 _vaultId, uint256 _amount) external;


  function borrow(uint256 _vaultId, uint256 _amount) external;


  function repayAll(uint256 _vaultId) external;


  function repay(uint256 _vaultId, uint256 _amount) external;


  function liquidate(uint256 _vaultId) external;


  function liquidatePartial(uint256 _vaultId, uint256 _amount) external;


  function upgrade(address payable _newVaultsCore) external;


  function acceptUpgrade(address payable _oldVaultsCore) external;


  function setDebtNotifier(IDebtNotifier _debtNotifier) external;


  function a() external view returns (IAddressProvider);


  function WETH() external view returns (IWETH);


  function debtNotifier() external view returns (IDebtNotifier);


  function state() external view returns (IVaultsCoreState);


  function cumulativeRates(address _collateralType) external view returns (uint256);

}

interface IAddressProviderV1 {

  function setAccessController(IAccessController _controller) external;


  function setConfigProvider(IConfigProviderV1 _config) external;


  function setVaultsCore(IVaultsCoreV1 _core) external;


  function setStableX(ISTABLEX _stablex) external;


  function setRatesManager(IRatesManager _ratesManager) external;


  function setPriceFeed(IPriceFeed _priceFeed) external;


  function setLiquidationManager(ILiquidationManagerV1 _liquidationManager) external;


  function setVaultsDataProvider(IVaultsDataProvider _vaultsData) external;


  function setFeeDistributor(IFeeDistributor _feeDistributor) external;


  function controller() external view returns (IAccessController);


  function config() external view returns (IConfigProviderV1);


  function core() external view returns (IVaultsCoreV1);


  function stablex() external view returns (ISTABLEX);


  function ratesManager() external view returns (IRatesManager);


  function priceFeed() external view returns (IPriceFeed);


  function liquidationManager() external view returns (ILiquidationManagerV1);


  function vaultsData() external view returns (IVaultsDataProvider);


  function feeDistributor() external view returns (IFeeDistributor);

}

interface IVaultsCoreState {

  event CumulativeRateUpdated(address indexed collateralType, uint256 elapsedTime, uint256 newCumulativeRate); //cumulative interest rate from deployment time T0

  function initializeRates(address _collateralType) external;


  function refresh() external;


  function refreshCollateral(address collateralType) external;


  function syncState(IVaultsCoreState _stateAddress) external;


  function syncStateFromV1(IVaultsCoreV1 _core) external;


  function a() external view returns (IAddressProvider);


  function availableIncome() external view returns (uint256);


  function cumulativeRates(address _collateralType) external view returns (uint256);


  function lastRefresh(address _collateralType) external view returns (uint256);


  function synced() external view returns (bool);

}

contract VaultsCore is IVaultsCore, ReentrancyGuard {

  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  using WadRayMath for uint256;

  uint256 internal constant _MAX_INT = 2**256 - 1;

  IAddressProvider public override a;
  IWETH public override WETH;
  IVaultsCoreState public override state;
  IDebtNotifier public override debtNotifier;

  modifier onlyManager() {

    require(a.controller().hasRole(a.controller().MANAGER_ROLE(), msg.sender));
    _;
  }

  modifier onlyVaultOwner(uint256 _vaultId) {

    require(a.vaultsData().vaultOwner(_vaultId) == msg.sender);
    _;
  }

  constructor(
    IAddressProvider _addresses,
    IWETH _IWETH,
    IVaultsCoreState _vaultsCoreState
  ) public {
    require(address(_addresses) != address(0));
    require(address(_IWETH) != address(0));
    require(address(_vaultsCoreState) != address(0));
    a = _addresses;
    WETH = _IWETH;
    state = _vaultsCoreState;
  }

  receive() external payable {
    require(msg.sender == address(WETH));
  }

  function upgrade(address payable _newVaultsCore) public override onlyManager {

    require(address(_newVaultsCore) != address(0));
    require(a.stablex().approve(_newVaultsCore, _MAX_INT));

    for (uint256 i = 1; i <= a.config().numCollateralConfigs(); i++) {
      address collateralType = a.config().collateralConfigs(i).collateralType;
      IERC20 asset = IERC20(collateralType);
      asset.safeApprove(_newVaultsCore, _MAX_INT);
    }
  }

  function acceptUpgrade(address payable _oldVaultsCore) public override onlyManager {

    IERC20 stableX = IERC20(a.stablex());
    stableX.safeTransferFrom(_oldVaultsCore, address(this), stableX.balanceOf(_oldVaultsCore));

    for (uint256 i = 1; i <= a.config().numCollateralConfigs(); i++) {
      address collateralType = a.config().collateralConfigs(i).collateralType;
      IERC20 asset = IERC20(collateralType);
      asset.safeTransferFrom(_oldVaultsCore, address(this), asset.balanceOf(_oldVaultsCore));
    }
  }

  function setDebtNotifier(IDebtNotifier _debtNotifier) public override onlyManager {

    require(address(_debtNotifier) != address(0));
    debtNotifier = _debtNotifier;
  }

  function deposit(address _collateralType, uint256 _amount) public override {

    require(a.config().collateralIds(_collateralType) != 0);

    IERC20 asset = IERC20(_collateralType);
    asset.safeTransferFrom(msg.sender, address(this), _amount);

    _addCollateralToVault(_collateralType, _amount);
  }

  function depositETH() public payable override {

    WETH.deposit{ value: msg.value }();
    _addCollateralToVault(address(WETH), msg.value);
  }

  function depositByVaultId(uint256 _vaultId, uint256 _amount) public override {

    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);
    require(v.collateralType != address(0));

    IERC20 asset = IERC20(v.collateralType);
    asset.safeTransferFrom(msg.sender, address(this), _amount);

    _addCollateralToVaultById(_vaultId, _amount);
  }

  function depositETHByVaultId(uint256 _vaultId) public payable override {

    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);
    require(v.collateralType == address(WETH));

    WETH.deposit{ value: msg.value }();

    _addCollateralToVaultById(_vaultId, msg.value);
  }

  function depositAndBorrow(
    address _collateralType,
    uint256 _depositAmount,
    uint256 _borrowAmount
  ) public override {

    deposit(_collateralType, _depositAmount);
    uint256 vaultId = a.vaultsData().vaultId(_collateralType, msg.sender);
    borrow(vaultId, _borrowAmount);
  }

  function depositETHAndBorrow(uint256 _borrowAmount) public payable override {

    depositETH();
    uint256 vaultId = a.vaultsData().vaultId(address(WETH), msg.sender);
    borrow(vaultId, _borrowAmount);
  }

  function _addCollateralToVault(address _collateralType, uint256 _amount) internal {

    uint256 vaultId = a.vaultsData().vaultId(_collateralType, msg.sender);
    if (vaultId == 0) {
      vaultId = a.vaultsData().createVault(_collateralType, msg.sender);
    }

    _addCollateralToVaultById(vaultId, _amount);
  }

  function _addCollateralToVaultById(uint256 _vaultId, uint256 _amount) internal {

    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);

    a.vaultsData().setCollateralBalance(_vaultId, v.collateralBalance.add(_amount));

    emit Deposited(_vaultId, _amount, msg.sender);
  }

  function withdraw(uint256 _vaultId, uint256 _amount) public override onlyVaultOwner(_vaultId) nonReentrant {

    _removeCollateralFromVault(_vaultId, _amount);
    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);

    IERC20 asset = IERC20(v.collateralType);
    asset.safeTransfer(msg.sender, _amount);
  }

  function withdrawETH(uint256 _vaultId, uint256 _amount) public override onlyVaultOwner(_vaultId) nonReentrant {

    _removeCollateralFromVault(_vaultId, _amount);
    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);

    require(v.collateralType == address(WETH));

    WETH.withdraw(_amount);
    msg.sender.transfer(_amount);
  }

  function _removeCollateralFromVault(uint256 _vaultId, uint256 _amount) internal {

    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);
    require(_amount <= v.collateralBalance);
    uint256 newCollateralBalance = v.collateralBalance.sub(_amount);
    a.vaultsData().setCollateralBalance(_vaultId, newCollateralBalance);
    if (v.baseDebt > 0) {
      state.refreshCollateral(v.collateralType);
      uint256 newCollateralValue = a.priceFeed().convertFrom(v.collateralType, newCollateralBalance);
      require(
        a.liquidationManager().isHealthy(
          newCollateralValue,
          a.vaultsData().vaultDebt(_vaultId),
          a.config().collateralConfigs(a.config().collateralIds(v.collateralType)).minCollateralRatio
        )
      );
    }

    emit Withdrawn(_vaultId, _amount, msg.sender);
  }

  function borrow(uint256 _vaultId, uint256 _amount) public override onlyVaultOwner(_vaultId) nonReentrant {

    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);

    state.refreshCollateral(v.collateralType);

    uint256 originationFeePercentage = a.config().collateralOriginationFee(v.collateralType);
    uint256 newDebt = _amount;
    if (originationFeePercentage > 0) {
      newDebt = newDebt.add(_amount.wadMul(originationFeePercentage));
    }

    uint256 newBaseDebt = a.ratesManager().calculateBaseDebt(newDebt, cumulativeRates(v.collateralType));

    a.vaultsData().setBaseDebt(_vaultId, v.baseDebt.add(newBaseDebt));

    uint256 collateralValue = a.priceFeed().convertFrom(v.collateralType, v.collateralBalance);
    uint256 newVaultDebt = a.vaultsData().vaultDebt(_vaultId);

    require(a.vaultsData().collateralDebt(v.collateralType) <= a.config().collateralDebtLimit(v.collateralType));

    bool isHealthy = a.liquidationManager().isHealthy(
      collateralValue,
      newVaultDebt,
      a.config().collateralConfigs(a.config().collateralIds(v.collateralType)).minCollateralRatio
    );
    require(isHealthy);

    a.stablex().mint(msg.sender, _amount);
    debtNotifier.debtChanged(_vaultId);
    emit Borrowed(_vaultId, _amount, msg.sender);
  }

  function repayAll(uint256 _vaultId) public override {

    repay(_vaultId, _MAX_INT);
  }

  function repay(uint256 _vaultId, uint256 _amount) public override nonReentrant {

    address collateralType = a.vaultsData().vaultCollateralType(_vaultId);

    state.refreshCollateral(collateralType);

    uint256 currentVaultDebt = a.vaultsData().vaultDebt(_vaultId);
    if (_amount >= currentVaultDebt) {
      _amount = currentVaultDebt; //only pay back what's outstanding
    }
    _reduceVaultDebt(_vaultId, _amount);
    a.stablex().burn(msg.sender, _amount);
    debtNotifier.debtChanged(_vaultId);
    emit Repaid(_vaultId, _amount, msg.sender);
  }

  function _reduceVaultDebt(uint256 _vaultId, uint256 _amount) internal {

    address collateralType = a.vaultsData().vaultCollateralType(_vaultId);

    uint256 currentVaultDebt = a.vaultsData().vaultDebt(_vaultId);
    uint256 remainder = currentVaultDebt.sub(_amount);
    uint256 cumulativeRate = cumulativeRates(collateralType);

    if (remainder == 0) {
      a.vaultsData().setBaseDebt(_vaultId, 0);
    } else {
      uint256 newBaseDebt = a.ratesManager().calculateBaseDebt(remainder, cumulativeRate);
      a.vaultsData().setBaseDebt(_vaultId, newBaseDebt);
    }
  }

  function liquidate(uint256 _vaultId) public override {

    liquidatePartial(_vaultId, _MAX_INT);
  }

  function liquidatePartial(uint256 _vaultId, uint256 _amount) public override nonReentrant {

    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);

    state.refreshCollateral(v.collateralType);

    uint256 collateralValue = a.priceFeed().convertFrom(v.collateralType, v.collateralBalance);
    uint256 currentVaultDebt = a.vaultsData().vaultDebt(_vaultId);

    require(
      !a.liquidationManager().isHealthy(
        collateralValue,
        currentVaultDebt,
        a.config().collateralConfigs(a.config().collateralIds(v.collateralType)).liquidationRatio
      )
    );

    uint256 repaymentAfterLiquidationFeeRatio = WadRayMath.wad().sub(
      a.config().collateralLiquidationFee(v.collateralType)
    );
    uint256 maxLiquiditionCost = currentVaultDebt.wadDiv(repaymentAfterLiquidationFeeRatio);

    uint256 repayAmount;

    if (_amount > maxLiquiditionCost) {
      _amount = maxLiquiditionCost;
      repayAmount = currentVaultDebt;
    } else {
      repayAmount = _amount.wadMul(repaymentAfterLiquidationFeeRatio);
    }

    uint256 collateralValueToReceive = _amount.add(a.liquidationManager().liquidationBonus(v.collateralType, _amount));
    uint256 insuranceAmount = 0;
    if (collateralValueToReceive >= collateralValue) {
      collateralValueToReceive = collateralValue;
      uint256 discountedCollateralValue = a.liquidationManager().applyLiquidationDiscount(
        v.collateralType,
        collateralValue
      );

      if (currentVaultDebt > discountedCollateralValue) {
        insuranceAmount = currentVaultDebt.sub(discountedCollateralValue);
        require(a.stablex().balanceOf(address(this)) >= insuranceAmount);
        a.stablex().burn(address(this), insuranceAmount); // Insurance uses local reserves to pay down debt
        emit InsurancePaid(_vaultId, insuranceAmount, msg.sender);
      }

      repayAmount = currentVaultDebt.sub(insuranceAmount);
      _amount = discountedCollateralValue;
    }

    _reduceVaultDebt(_vaultId, repayAmount.add(insuranceAmount));
    a.stablex().burn(msg.sender, _amount);

    uint256 collateralToReceive = a.priceFeed().convertTo(v.collateralType, collateralValueToReceive);
    a.vaultsData().setCollateralBalance(_vaultId, v.collateralBalance.sub(collateralToReceive));
    IERC20 asset = IERC20(v.collateralType);
    asset.safeTransfer(msg.sender, collateralToReceive);

    debtNotifier.debtChanged(_vaultId);

    emit Liquidated(_vaultId, repayAmount, collateralToReceive, v.owner, msg.sender);
  }

  function cumulativeRates(address _collateralType) public view override returns (uint256) {

    return state.cumulativeRates(_collateralType);
  }
}