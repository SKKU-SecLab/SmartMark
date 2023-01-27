
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

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

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// GPL-3.0

pragma solidity >0.6.0;

interface IContractRegistry {

  function getContract(bytes32 _name) external view returns (address);

}// GPL-3.0

pragma solidity ^0.8.0;


abstract contract ContractRegistryAccess {
  IContractRegistry internal _contractRegistry;

  constructor(IContractRegistry contractRegistry_) {
    _contractRegistry = contractRegistry_;
  }

  function _getContract(bytes32 _name) internal view virtual returns (address) {
    return _contractRegistry.getContract(_name);
  }
}// GPL-3.0


interface IACLRegistry {

  event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

  event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

  function hasRole(bytes32 role, address account) external view returns (bool);


  function hasPermission(bytes32 permission, address account) external view returns (bool);


  function getRoleAdmin(bytes32 role) external view returns (bytes32);


  function grantRole(bytes32 role, address account) external;


  function revokeRole(bytes32 role, address account) external;


  function renounceRole(bytes32 role, address account) external;


  function setRoleAdmin(bytes32 role, bytes32 adminRole) external;


  function grantPermission(bytes32 permission, address account) external;


  function revokePermission(bytes32 permission) external;


  function requireApprovedContractOrEOA(address account) external view;


  function requireRole(bytes32 role, address account) external view;


  function requirePermission(bytes32 permission, address account) external view;


  function isRoleAdmin(bytes32 role, address account) external view;

}// GPL-3.0

pragma solidity ^0.8.0;


abstract contract ACLAuth {
  bytes32 internal constant KEEPER_ROLE = 0x4f78afe9dfc9a0cb0441c27b9405070cd2a48b490636a7bdd09f355e33a5d7de;

  bytes32 internal constant DAO_ROLE = 0xd0a4ad96d49edb1c33461cebc6fb2609190f32c904e3c3f5877edb4488dee91e;

  bytes32 internal constant APPROVED_CONTRACT_ROLE = 0xfb639edf4b4a4724b8b9fb42a839b712c82108c1edf1beb051bcebce8e689dc4;

  bytes32 internal constant ACL_REGISTRY_ID = 0x15fa0125f52e5705da1148bfcf00974823c4381bee4314203ede255f9477b73e;

  modifier onlyRole(bytes32 role) {
    _requireRole(role);
    _;
  }

  modifier onlyPermission(bytes32 role) {
    _requirePermission(role);
    _;
  }

  modifier onlyApprovedContractOrEOA() {
    _requireApprovedContractOrEOA(msg.sender);
    _;
  }

  function _hasRole(bytes32 role, address account) internal view returns (bool) {
    return _aclRegistry().hasRole(role, account);
  }

  function _requireRole(bytes32 role) internal view {
    _requireRole(role, msg.sender);
  }

  function _requireRole(bytes32 role, address account) internal view {
    _aclRegistry().requireRole(role, account);
  }

  function _hasPermission(bytes32 permission, address account) internal view returns (bool) {
    return _aclRegistry().hasPermission(permission, account);
  }

  function _requirePermission(bytes32 permission) internal view {
    _requirePermission(permission, msg.sender);
  }

  function _requirePermission(bytes32 permission, address account) internal view {
    _aclRegistry().requirePermission(permission, account);
  }

  function _requireApprovedContractOrEOA() internal view {
    _requireApprovedContractOrEOA(msg.sender);
  }

  function _requireApprovedContractOrEOA(address account) internal view {
    _aclRegistry().requireApprovedContractOrEOA(account);
  }

  function _aclRegistry() internal view returns (IACLRegistry) {
    return IACLRegistry(_getContract(ACL_REGISTRY_ID));
  }

  function _getContract(bytes32 _name) internal view virtual returns (address);
}// GPL-3.0

pragma solidity ^0.8.0;

interface IKeeperIncentive {

  function handleKeeperIncentive(
    bytes32 _contractName,
    uint8 _i,
    address _keeper
  ) external;

}// GPL-3.0

pragma solidity ^0.8.0;


abstract contract KeeperIncentivized {
  bytes32 public constant KEEPER_INCENTIVE = 0x35ed2e1befd3b2dcf1ec7a6834437fa3212881ed81fd3a13dc97c3438896e1ba;

  modifier keeperIncentive(bytes32 _contractName, uint8 _index) {
    _handleKeeperIncentive(_contractName, _index, msg.sender);
    _;
  }

  function _handleKeeperIncentive(
    bytes32 _contractName,
    uint8 _index,
    address _keeper
  ) internal {
    _keeperIncentive().handleKeeperIncentive(_contractName, _index, _keeper);
  }

  function _keeperIncentive() internal view returns (IKeeperIncentive) {
    return IKeeperIncentive(_getContract(KEEPER_INCENTIVE));
  }

  function _getContract(bytes32 _name) internal view virtual returns (address);
}// GPL-3.0

pragma solidity >=0.6.0;


interface YearnVault is IERC20 {

  function token() external view returns (address);


  function deposit(uint256 amount) external;


  function withdraw(uint256 amount) external;


  function pricePerShare() external view returns (uint256);

}// Apache-2.0

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


interface ISetToken is IERC20 {


  enum ModuleState {
    NONE,
    PENDING,
    INITIALIZED
  }

  struct Position {
    address component;
    address module;
    int256 unit;
    uint8 positionState;
    bytes data;
  }

  struct ComponentPosition {
    int256 virtualUnit;
    address[] externalPositionModules;
    mapping(address => ExternalPosition) externalPositions;
  }

  struct ExternalPosition {
    int256 virtualUnit;
    bytes data;
  }


  function addComponent(address _component) external;


  function removeComponent(address _component) external;


  function editDefaultPositionUnit(address _component, int256 _realUnit) external;


  function addExternalPositionModule(address _component, address _positionModule) external;


  function removeExternalPositionModule(address _component, address _positionModule) external;


  function editExternalPositionUnit(
    address _component,
    address _positionModule,
    int256 _realUnit
  ) external;


  function editExternalPositionData(
    address _component,
    address _positionModule,
    bytes calldata _data
  ) external;


  function invoke(
    address _target,
    uint256 _value,
    bytes calldata _data
  ) external returns (bytes memory);


  function editPositionMultiplier(int256 _newMultiplier) external;


  function mint(address _account, uint256 _quantity) external;


  function burn(address _account, uint256 _quantity) external;


  function lock() external;


  function unlock() external;


  function addModule(address _module) external;


  function removeModule(address _module) external;


  function initializeModule() external;


  function setManager(address _manager) external;


  function manager() external view returns (address);


  function moduleStates(address _module) external view returns (ModuleState);


  function getModules() external view returns (address[] memory);


  function getDefaultPositionRealUnit(address _component) external view returns (int256);


  function getExternalPositionRealUnit(address _component, address _positionModule) external view returns (int256);


  function getComponents() external view returns (address[] memory);


  function getExternalPositionModules(address _component) external view returns (address[] memory);


  function getExternalPositionData(address _component, address _positionModule) external view returns (bytes memory);


  function isExternalPositionModule(address _component, address _module) external view returns (bool);


  function isComponent(address _component) external view returns (bool);


  function positionMultiplier() external view returns (int256);


  function getPositions() external view returns (Position[] memory);


  function getTotalComponentRealUnits(address _component) external view returns (int256);


  function isInitializedModule(address _module) external view returns (bool);


  function isPendingModule(address _module) external view returns (bool);


  function isLocked() external view returns (bool);

}// GPL-3.0

pragma solidity ^0.8.0;


interface BasicIssuanceModule {

  function getRequiredComponentUnitsForIssue(ISetToken _setToken, uint256 _quantity)
    external
    view
    returns (address[] memory, uint256[] memory);


  function issue(
    ISetToken _setToken,
    uint256 _quantity,
    address _to
  ) external;


  function redeem(
    ISetToken _setToken,
    uint256 _quantity,
    address _to
  ) external;

}// GPL-3.0

pragma solidity ^0.8.0;


interface CurveAddressProvider {

  function get_registry() external view returns (address);

}

interface CurveRegistry {

  function get_pool_from_lp_token(address lp_token) external view returns (address);

}

interface CurveMetapool {

  function get_virtual_price() external view returns (uint256);


  function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amounts) external returns (uint256);


  function add_liquidity(
    uint256[2] calldata _amounts,
    uint256 _min_mint_amounts,
    address _receiver
  ) external returns (uint256);


  function remove_liquidity_one_coin(
    uint256 amount,
    int128 i,
    uint256 min_underlying_amount
  ) external returns (uint256);


  function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);

}

interface ThreeCrv is IERC20 {}


interface CrvLPToken is IERC20 {}// GPL-3.0


pragma solidity ^0.8.0;

interface IStaking {

  function balanceOf(address account) external view returns (uint256);


  function stake(uint256 amount) external;


  function stakeFor(uint256 amount, address account) external;


  function withdraw(uint256 amount) external;


  function notifyRewardAmount(uint256 reward) external;

}// GPL-3.0

pragma solidity ^0.8.0;


contract ButterBatchProcessing is Pausable, ReentrancyGuard, ACLAuth, KeeperIncentivized, ContractRegistryAccess {

  using SafeERC20 for YearnVault;
  using SafeERC20 for ISetToken;
  using SafeERC20 for IERC20;

  enum BatchType {
    Mint,
    Redeem
  }

  struct CurvePoolTokenPair {
    CurveMetapool curveMetaPool;
    IERC20 crvLPToken;
  }

  struct ProcessingThreshold {
    uint256 batchCooldown;
    uint256 mintThreshold;
    uint256 redeemThreshold;
  }

  struct RedemptionFee {
    uint256 accumulated;
    uint256 rate;
    address recipient;
  }

  struct Slippage {
    uint256 mintBps; // in bps
    uint256 redeemBps; // in bps
  }

  struct Batch {
    BatchType batchType;
    bytes32 batchId;
    bool claimable;
    uint256 unclaimedShares;
    uint256 suppliedTokenBalance;
    uint256 claimableTokenBalance;
    address suppliedTokenAddress;
    address claimableTokenAddress;
  }


  bytes32 public immutable contractName = "ButterBatchProcessing";

  IStaking public staking;
  ISetToken public setToken;
  IERC20 public threeCrv;
  CurveMetapool public threePool;
  BasicIssuanceModule public setBasicIssuanceModule;
  mapping(address => CurvePoolTokenPair) public curvePoolTokenPairs;

  mapping(bytes32 => mapping(address => uint256)) public accountBalances;
  mapping(address => bytes32[]) public accountBatches;
  mapping(bytes32 => Batch) public batches;
  bytes32[] public batchIds;

  uint256 public lastMintedAt;
  uint256 public lastRedeemedAt;
  bytes32 public currentMintBatchId;
  bytes32 public currentRedeemBatchId;

  Slippage public slippage;
  ProcessingThreshold public processingThreshold;

  RedemptionFee public redemptionFee;

  mapping(address => bool) public sweethearts;


  event Deposit(address indexed from, uint256 deposit);
  event Withdrawal(address indexed to, uint256 amount);
  event SlippageUpdated(Slippage prev, Slippage current);
  event BatchMinted(bytes32 batchId, uint256 suppliedTokenAmount, uint256 butterAmount);
  event BatchRedeemed(bytes32 batchId, uint256 suppliedTokenAmount, uint256 threeCrvAmount);
  event Claimed(address indexed account, BatchType batchType, uint256 shares, uint256 claimedToken);
  event WithdrawnFromBatch(bytes32 batchId, uint256 amount, address indexed to);
  event MovedUnclaimedDepositsIntoCurrentBatch(uint256 amount, BatchType batchType, address indexed account);
  event CurveTokenPairsUpdated(address[] yTokenAddresses, CurvePoolTokenPair[] curveTokenPairs);
  event ProcessingThresholdUpdated(ProcessingThreshold previousThreshold, ProcessingThreshold newProcessingThreshold);
  event RedemptionFeeUpdated(uint256 newRedemptionFee, address newFeeRecipient);
  event SweetheartUpdated(address sweetheart, bool isSweeheart);
  event StakingUpdated(address beforeAddress, address afterAddress);


  constructor(
    IContractRegistry _contractRegistry,
    IStaking _staking,
    ISetToken _setToken,
    IERC20 _threeCrv,
    CurveMetapool _threePool,
    BasicIssuanceModule _basicIssuanceModule,
    address[] memory _yTokenAddresses,
    CurvePoolTokenPair[] memory _curvePoolTokenPairs,
    ProcessingThreshold memory _processingThreshold
  ) ContractRegistryAccess(_contractRegistry) {
    staking = _staking;
    setToken = _setToken;
    threeCrv = _threeCrv;
    threePool = _threePool;
    setBasicIssuanceModule = _basicIssuanceModule;

    _setCurvePoolTokenPairs(_yTokenAddresses, _curvePoolTokenPairs);

    processingThreshold = _processingThreshold;

    lastMintedAt = block.timestamp;
    lastRedeemedAt = block.timestamp;

    _generateNextBatch(bytes32("mint"), BatchType.Mint);
    _generateNextBatch(bytes32("redeem"), BatchType.Redeem);

    slippage.mintBps = 7;
    slippage.redeemBps = 7;
  }

  function getAccountBatches(address _account) external view returns (bytes32[] memory) {

    return accountBatches[_account];
  }


  function depositForMint(uint256 _amount, address _depositFor)
    external
    nonReentrant
    whenNotPaused
    onlyApprovedContractOrEOA
  {

    require(
      _hasRole(keccak256("ButterZapper"), msg.sender) || msg.sender == _depositFor,
      "you cant transfer other funds"
    );
    require(threeCrv.balanceOf(msg.sender) >= _amount, "insufficent balance");
    threeCrv.transferFrom(msg.sender, address(this), _amount);
    _deposit(_amount, currentMintBatchId, _depositFor);
  }

  function depositForRedeem(uint256 _amount) external nonReentrant whenNotPaused onlyApprovedContractOrEOA {

    require(setToken.balanceOf(msg.sender) >= _amount, "insufficient balance");
    setToken.transferFrom(msg.sender, address(this), _amount);
    _deposit(_amount, currentRedeemBatchId, msg.sender);
  }

  function withdrawFromBatch(
    bytes32 _batchId,
    uint256 _amountToWithdraw,
    address _withdrawFor
  ) external {

    address recipient = _getRecipient(_withdrawFor);

    Batch storage batch = batches[_batchId];
    uint256 accountBalance = accountBalances[_batchId][_withdrawFor];
    require(batch.claimable == false, "already processed");
    require(accountBalance >= _amountToWithdraw, "account has insufficient funds");

    accountBalances[_batchId][_withdrawFor] = accountBalance - _amountToWithdraw;
    batch.suppliedTokenBalance = batch.suppliedTokenBalance - _amountToWithdraw;
    batch.unclaimedShares = batch.unclaimedShares - _amountToWithdraw;

    if (batch.batchType == BatchType.Mint) {
      threeCrv.safeTransfer(recipient, _amountToWithdraw);
    } else {
      setToken.safeTransfer(recipient, _amountToWithdraw);
    }
    emit WithdrawnFromBatch(_batchId, _amountToWithdraw, _withdrawFor);
  }

  function claim(bytes32 _batchId, address _claimFor) external returns (uint256) {

    (address recipient, BatchType batchType, uint256 accountBalance, uint256 tokenAmountToClaim) = _prepareClaim(
      _batchId,
      _claimFor
    );
    if (batchType == BatchType.Mint) {
      setToken.safeTransfer(recipient, tokenAmountToClaim);
    } else {
      if (!sweethearts[_claimFor]) {
        uint256 fee = (tokenAmountToClaim * redemptionFee.rate) / 10_000;
        redemptionFee.accumulated += fee;
        tokenAmountToClaim = tokenAmountToClaim - fee;
      }
      threeCrv.safeTransfer(recipient, tokenAmountToClaim);
    }
    emit Claimed(recipient, batchType, accountBalance, tokenAmountToClaim);

    return tokenAmountToClaim;
  }

  function claimAndStake(bytes32 _batchId, address _claimFor) external {

    (address recipient, BatchType batchType, uint256 accountBalance, uint256 tokenAmountToClaim) = _prepareClaim(
      _batchId,
      _claimFor
    );
    emit Claimed(recipient, batchType, accountBalance, tokenAmountToClaim);

    require(batchType == BatchType.Mint, "Can only stake BTR");
    staking.stakeFor(tokenAmountToClaim, recipient);
  }

  function moveUnclaimedDepositsIntoCurrentBatch(
    bytes32[] calldata _batchIds,
    uint256[] calldata _shares,
    BatchType _batchType
  ) external whenNotPaused {

    require(_batchIds.length == _shares.length, "array lengths must match");

    uint256 totalAmount;

    for (uint256 i; i < _batchIds.length; i++) {
      Batch storage batch = batches[_batchIds[i]];
      uint256 accountBalance = accountBalances[batch.batchId][msg.sender];
      require(batch.claimable == true, "has not yet been processed");
      require(batch.batchType == _batchType, "incorrect batchType");
      require(accountBalance >= _shares[i], "account has insufficient funds");

      uint256 tokenAmountToClaim = (batch.claimableTokenBalance * _shares[i]) / batch.unclaimedShares;
      batch.claimableTokenBalance = batch.claimableTokenBalance - tokenAmountToClaim;
      batch.unclaimedShares = batch.unclaimedShares - _shares[i];
      accountBalances[batch.batchId][msg.sender] = accountBalance - _shares[i];

      totalAmount = totalAmount + tokenAmountToClaim;
    }
    require(totalAmount > 0, "totalAmount must be larger 0");

    if (BatchType.Mint == _batchType) {
      _deposit(totalAmount, currentRedeemBatchId, msg.sender);
    }

    if (BatchType.Redeem == _batchType) {
      _deposit(totalAmount, currentMintBatchId, msg.sender);
    }

    emit MovedUnclaimedDepositsIntoCurrentBatch(totalAmount, _batchType, msg.sender);
  }

  function batchMint() external whenNotPaused keeperIncentive(contractName, 0) {

    Batch storage batch = batches[currentMintBatchId];
    require(
      ((block.timestamp - lastMintedAt) >= processingThreshold.batchCooldown ||
        (batch.suppliedTokenBalance >= processingThreshold.mintThreshold)) && batch.suppliedTokenBalance > 0,
      "can not execute batch mint yet"
    );

    require(batch.claimable == false, "already minted");

    require(
      threeCrv.balanceOf(address(this)) >= batch.suppliedTokenBalance,
      "account has insufficient balance of token to mint"
    );

    (address[] memory tokenAddresses, uint256[] memory quantities) = setBasicIssuanceModule
      .getRequiredComponentUnitsForIssue(setToken, 1e18);

    uint256 setValue = valueOfComponents(tokenAddresses, quantities);

    uint256 threeCrvValue = threePool.get_virtual_price();

    uint256 remainingBatchBalanceValue = (batch.suppliedTokenBalance * threeCrvValue) / 1e18;

    uint256[] memory poolAllocations = new uint256[](quantities.length);

    uint256[] memory ratios = new uint256[](quantities.length);

    for (uint256 i; i < tokenAddresses.length; i++) {
      (uint256 allocation, uint256 ratio) = _getPoolAllocationAndRatio(tokenAddresses[i], quantities[i], batch, setValue, threeCrvValue);
      poolAllocations[i] = allocation;
      ratios[i] = ratio;
      remainingBatchBalanceValue -= allocation;
    }

    for (uint256 i; i < tokenAddresses.length; i++) {
      uint256 poolAllocation;

      if (remainingBatchBalanceValue > 0) {
        poolAllocation = _getPoolAllocation(remainingBatchBalanceValue, ratios[i]);
      }

      _sendToCurve(
        ((poolAllocation + poolAllocations[i]) * 1e18) / threeCrvValue,
        curvePoolTokenPairs[tokenAddresses[i]].curveMetaPool
      );

      _sendToYearn(
        curvePoolTokenPairs[tokenAddresses[i]].crvLPToken.balanceOf(address(this)),
        YearnVault(tokenAddresses[i])
      );

      YearnVault(tokenAddresses[i]).safeIncreaseAllowance(
        address(setBasicIssuanceModule),
        YearnVault(tokenAddresses[i]).balanceOf(address(this))
      );
    }
    uint256 butterAmount = (YearnVault(tokenAddresses[0]).balanceOf(address(this)) * 1e18) / quantities[0];

    for (uint256 i = 1; i < tokenAddresses.length; i++) {
      butterAmount = Math.min(
        butterAmount,
        (YearnVault(tokenAddresses[i]).balanceOf(address(this)) * 1e18) / quantities[i]
      );
    }

    require(
      butterAmount >=
        getMinAmountToMint((batch.suppliedTokenBalance * threeCrvValue) / 1e18, setValue, slippage.mintBps),
      "slippage too high"
    );

    setBasicIssuanceModule.issue(setToken, butterAmount, address(this));

    batch.claimableTokenBalance = butterAmount;

    batch.claimable = true;

    lastMintedAt = block.timestamp;

    emit BatchMinted(currentMintBatchId, batch.suppliedTokenBalance, butterAmount);

    _generateNextBatch(currentMintBatchId, BatchType.Mint);
  }

  function batchRedeem() external whenNotPaused keeperIncentive(contractName, 1) {

    Batch storage batch = batches[currentRedeemBatchId];

    require(
      ((block.timestamp - lastRedeemedAt >= processingThreshold.batchCooldown) ||
        (batch.suppliedTokenBalance >= processingThreshold.redeemThreshold)) && batch.suppliedTokenBalance > 0,
      "can not execute batch redeem yet"
    );

    require(batch.claimable == false, "already redeemed");

    (address[] memory tokenAddresses, uint256[] memory quantities) = setBasicIssuanceModule
      .getRequiredComponentUnitsForIssue(setToken, batch.suppliedTokenBalance);

    _setBasicIssuanceModuleAllowance(batch.suppliedTokenBalance);

    setBasicIssuanceModule.redeem(setToken, batch.suppliedTokenBalance, address(this));

    uint256 oldBalance = threeCrv.balanceOf(address(this));

    for (uint256 i; i < tokenAddresses.length; i++) {
      _withdrawFromYearn(YearnVault(tokenAddresses[i]).balanceOf(address(this)), YearnVault(tokenAddresses[i]));

      uint256 crvLPTokenBalance = curvePoolTokenPairs[tokenAddresses[i]].crvLPToken.balanceOf(address(this));

      _withdrawFromCurve(crvLPTokenBalance, curvePoolTokenPairs[tokenAddresses[i]].curveMetaPool);
    }

    batch.claimableTokenBalance = threeCrv.balanceOf(address(this)) - oldBalance;

    require(
      batch.claimableTokenBalance >=
        getMinAmount3CrvFromRedeem(valueOfComponents(tokenAddresses, quantities), slippage.redeemBps),
      "slippage too high"
    );

    emit BatchRedeemed(currentRedeemBatchId, batch.suppliedTokenBalance, batch.claimableTokenBalance);

    batch.claimable = true;

    lastRedeemedAt = block.timestamp;

    _generateNextBatch(currentRedeemBatchId, BatchType.Redeem);
  }

  function setApprovals() external {

    (address[] memory tokenAddresses, ) = setBasicIssuanceModule.getRequiredComponentUnitsForIssue(setToken, 1e18);

    for (uint256 i; i < tokenAddresses.length; i++) {
      IERC20 curveLpToken = curvePoolTokenPairs[tokenAddresses[i]].crvLPToken;
      CurveMetapool curveMetapool = curvePoolTokenPairs[tokenAddresses[i]].curveMetaPool;
      YearnVault yearnVault = YearnVault(tokenAddresses[i]);

      _maxApprove(curveLpToken, address(curveMetapool));
      _maxApprove(curveLpToken, address(yearnVault));
      _maxApprove(threeCrv, address(curveMetapool));
    }
    _maxApprove(IERC20(address(setToken)), address(staking));
  }

  function getMinAmountToMint(
    uint256 _valueOfBatch,
    uint256 _valueOfComponentsPerUnit,
    uint256 _slippage
  ) public pure returns (uint256) {

    uint256 _mintAmount = (_valueOfBatch * 1e18) / _valueOfComponentsPerUnit;
    uint256 _delta = (_mintAmount * _slippage) / 10_000;
    return _mintAmount - _delta;
  }

  function getMinAmount3CrvFromRedeem(uint256 _valueOfComponents, uint256 _slippage) public view returns (uint256) {

    uint256 _threeCrvToReceive = (_valueOfComponents * 1e18) / threePool.get_virtual_price();
    uint256 _delta = (_threeCrvToReceive * _slippage) / 10_000;
    return _threeCrvToReceive - _delta;
  }

  function valueOfComponents(address[] memory _tokenAddresses, uint256[] memory _quantities)
    public
    view
    returns (uint256)
  {

    uint256 value;
    for (uint256 i = 0; i < _tokenAddresses.length; i++) {
      value +=
        (((YearnVault(_tokenAddresses[i]).pricePerShare() *
          curvePoolTokenPairs[_tokenAddresses[i]].curveMetaPool.get_virtual_price()) / 1e18) * _quantities[i]) /
        1e18;
    }
    return value;
  }

  function valueOf3Crv(uint256 _units) public view returns (uint256) {

    return (_units * threePool.get_virtual_price()) / 1e18;
  }


  function _maxApprove(IERC20 _token, address _spender) internal {

    _token.safeApprove(_spender, 0);
    _token.safeApprove(_spender, type(uint256).max);
  }

  function _getPoolAllocationAndRatio(
    address _component,
    uint256 _quantity,
    Batch memory _batch,
    uint256 _setValue,
    uint256 _threePoolPrice
  ) internal view returns (uint256 poolAllocation, uint256 ratio) {

    uint256 componentValuePerShare = (YearnVault(_component).pricePerShare() *
      curvePoolTokenPairs[_component].curveMetaPool.get_virtual_price()) / 1e18;

    uint256 componentValuePerSet = (_quantity * componentValuePerShare) / 1e18;

    uint256 componentValueHeldByContract = (YearnVault(_component).balanceOf(address(this)) * componentValuePerShare) /
      1e18;

    ratio = (componentValuePerSet * 1e18) / _setValue;

    poolAllocation =
      _getPoolAllocation((_batch.suppliedTokenBalance * _threePoolPrice) / 1e18, ratio) -
      componentValueHeldByContract;

    return (poolAllocation, ratio);
  }

  function _getPoolAllocation(uint256 _balance, uint256 _ratio) internal pure returns (uint256) {

    return ((_balance * _ratio) / 1e18);
  }

  function _setBasicIssuanceModuleAllowance(uint256 _amount) internal {

    setToken.safeApprove(address(setBasicIssuanceModule), 0);
    setToken.safeApprove(address(setBasicIssuanceModule), _amount);
  }

  function _getRecipient(address _account) internal view returns (address) {

    require(_hasRole(keccak256("ButterZapper"), msg.sender) || msg.sender == _account, "you cant transfer other funds");

    address recipient = _account;

    if (_hasRole(keccak256("ButterZapper"), msg.sender)) {
      recipient = msg.sender;
    }
    return recipient;
  }

  function _generateNextBatch(bytes32 _currentBatchId, BatchType _batchType) internal returns (bytes32) {

    bytes32 id = _generateNextBatchId(_currentBatchId);
    batchIds.push(id);
    Batch storage batch = batches[id];
    batch.batchType = _batchType;
    batch.batchId = id;

    if (BatchType.Mint == _batchType) {
      currentMintBatchId = id;
      batch.suppliedTokenAddress = address(threeCrv);
      batch.claimableTokenAddress = address(setToken);
    }
    if (BatchType.Redeem == _batchType) {
      currentRedeemBatchId = id;
      batch.suppliedTokenAddress = address(setToken);
      batch.claimableTokenAddress = address(threeCrv);
    }
    return id;
  }

  function _deposit(
    uint256 _amount,
    bytes32 _currentBatchId,
    address _depositFor
  ) internal {

    Batch storage batch = batches[_currentBatchId];

    batch.suppliedTokenBalance = batch.suppliedTokenBalance + _amount;
    batch.unclaimedShares = batch.unclaimedShares + _amount;
    accountBalances[_currentBatchId][_depositFor] = accountBalances[_currentBatchId][_depositFor] + _amount;

    if (
      accountBatches[_depositFor].length == 0 ||
      accountBatches[_depositFor][accountBatches[_depositFor].length - 1] != _currentBatchId
    ) {
      accountBatches[_depositFor].push(_currentBatchId);
    }

    emit Deposit(_depositFor, _amount);
  }

  function _prepareClaim(bytes32 _batchId, address _claimFor)
    internal
    returns (
      address,
      BatchType,
      uint256,
      uint256
    )
  {

    Batch storage batch = batches[_batchId];
    require(batch.claimable, "not yet claimable");

    address recipient = _getRecipient(_claimFor);
    uint256 accountBalance = accountBalances[_batchId][_claimFor];
    require(accountBalance <= batch.unclaimedShares, "claiming too many shares");

    uint256 tokenAmountToClaim = (batch.claimableTokenBalance * accountBalance) / batch.unclaimedShares;

    batch.claimableTokenBalance = batch.claimableTokenBalance - tokenAmountToClaim;
    batch.unclaimedShares = batch.unclaimedShares - accountBalance;
    accountBalances[_batchId][_claimFor] = 0;

    return (recipient, batch.batchType, accountBalance, tokenAmountToClaim);
  }

  function _sendToCurve(uint256 _amount, CurveMetapool _curveMetapool) internal {

    _curveMetapool.add_liquidity([0, _amount], 0);
  }

  function _withdrawFromCurve(uint256 _amount, CurveMetapool _curveMetapool) internal {

    _curveMetapool.remove_liquidity_one_coin(_amount, 1, 0);
  }

  function _sendToYearn(uint256 _amount, YearnVault _yearnVault) internal {

    _yearnVault.deposit(_amount);
  }

  function _withdrawFromYearn(uint256 _amount, YearnVault _yearnVault) internal {

    _yearnVault.withdraw(_amount);
  }

  function _generateNextBatchId(bytes32 _currentBatchId) internal view returns (bytes32) {

    return keccak256(abi.encodePacked(block.timestamp, _currentBatchId));
  }


  function setCurvePoolTokenPairs(address[] memory _yTokenAddresses, CurvePoolTokenPair[] calldata _curvePoolTokenPairs)
    public
    onlyRole(DAO_ROLE)
  {

    _setCurvePoolTokenPairs(_yTokenAddresses, _curvePoolTokenPairs);
  }

  function _setCurvePoolTokenPairs(address[] memory _yTokenAddresses, CurvePoolTokenPair[] memory _curvePoolTokenPairs)
    internal
  {

    emit CurveTokenPairsUpdated(_yTokenAddresses, _curvePoolTokenPairs);
    for (uint256 i; i < _yTokenAddresses.length; i++) {
      curvePoolTokenPairs[_yTokenAddresses[i]] = _curvePoolTokenPairs[i];
    }
  }

  function setProcessingThreshold(
    uint256 _cooldown,
    uint256 _mintThreshold,
    uint256 _redeemThreshold
  ) public onlyRole(DAO_ROLE) {

    ProcessingThreshold memory newProcessingThreshold = ProcessingThreshold({
      batchCooldown: _cooldown,
      mintThreshold: _mintThreshold,
      redeemThreshold: _redeemThreshold
    });
    emit ProcessingThresholdUpdated(processingThreshold, newProcessingThreshold);
    processingThreshold = newProcessingThreshold;
  }

  function setSlippage(uint256 _mintSlippage, uint256 _redeemSlippage) external onlyRole(DAO_ROLE) {

    require(_mintSlippage <= 200 && _redeemSlippage <= 200, "slippage too high");
    Slippage memory newSlippage = Slippage({ mintBps: _mintSlippage, redeemBps: _redeemSlippage });
    emit SlippageUpdated(slippage, newSlippage);
    slippage = newSlippage;
  }

  function setRedemptionFee(uint256 _feeRate, address _recipient) external onlyRole(DAO_ROLE) {

    require(_feeRate <= 100, "dont get greedy");
    redemptionFee.rate = _feeRate;
    redemptionFee.recipient = _recipient;
    emit RedemptionFeeUpdated(_feeRate, _recipient);
  }

  function claimRedemptionFee() external {

    threeCrv.safeTransfer(redemptionFee.recipient, redemptionFee.accumulated);
    redemptionFee.accumulated = 0;
  }

  function recoverLeftover(address _yTokenAddress, uint256 _amount) external onlyRole(DAO_ROLE) {

    require(address(curvePoolTokenPairs[_yTokenAddress].curveMetaPool) != address(0), "yToken doesnt exist");
    IERC20(_yTokenAddress).safeTransfer(_getContract(keccak256("Treasury")), _amount);
  }

  function updateSweetheart(address _sweetheart, bool _enabled) external onlyRole(DAO_ROLE) {

    sweethearts[_sweetheart] = _enabled;
    emit SweetheartUpdated(_sweetheart, _enabled);
  }

  function pause() external onlyRole(DAO_ROLE) {

    _pause();
  }

  function unpause() external onlyRole(DAO_ROLE) {

    _unpause();
  }

  function setStaking(address _staking) external onlyRole(DAO_ROLE) {

    emit StakingUpdated(address(staking), _staking);
    staking = IStaking(_staking);
  }

  function _getContract(bytes32 _name)
    internal
    view
    override(ACLAuth, KeeperIncentivized, ContractRegistryAccess)
    returns (address)
  {

    return super._getContract(_name);
  }
}