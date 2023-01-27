
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT
pragma solidity 0.8.6;

struct JBOperatorData {
  address operator;
  uint256 domain;
  uint256[] permissionIndexes;
}// MIT
pragma solidity 0.8.6;


interface IJBOperatorStore {

  event SetOperator(
    address indexed operator,
    address indexed account,
    uint256 indexed domain,
    uint256[] permissionIndexes,
    uint256 packed
  );

  function permissionsOf(
    address _operator,
    address _account,
    uint256 _domain
  ) external view returns (uint256);


  function hasPermission(
    address _operator,
    address _account,
    uint256 _domain,
    uint256 _permissionIndex
  ) external view returns (bool);


  function hasPermissions(
    address _operator,
    address _account,
    uint256 _domain,
    uint256[] calldata _permissionIndexes
  ) external view returns (bool);


  function setOperator(JBOperatorData calldata _operatorData) external;


  function setOperators(JBOperatorData[] calldata _operatorData) external;

}// MIT
pragma solidity 0.8.6;


interface IJBOperatable {

  function operatorStore() external view returns (IJBOperatorStore);

}// MIT
pragma solidity 0.8.6;


abstract contract JBOperatable is IJBOperatable {
  error UNAUTHORIZED();


  modifier requirePermission(
    address _account,
    uint256 _domain,
    uint256 _permissionIndex
  ) {
    _requirePermission(_account, _domain, _permissionIndex);
    _;
  }

  modifier requirePermissionAllowingOverride(
    address _account,
    uint256 _domain,
    uint256 _permissionIndex,
    bool _override
  ) {
    _requirePermissionAllowingOverride(_account, _domain, _permissionIndex, _override);
    _;
  }


  IJBOperatorStore public immutable override operatorStore;


  constructor(IJBOperatorStore _operatorStore) {
    operatorStore = _operatorStore;
  }


  function _requirePermission(
    address _account,
    uint256 _domain,
    uint256 _permissionIndex
  ) internal view {
    if (
      msg.sender != _account &&
      !operatorStore.hasPermission(msg.sender, _account, _domain, _permissionIndex) &&
      !operatorStore.hasPermission(msg.sender, _account, 0, _permissionIndex)
    ) revert UNAUTHORIZED();
  }

  function _requirePermissionAllowingOverride(
    address _account,
    uint256 _domain,
    uint256 _permissionIndex,
    bool _override
  ) internal view {
    if (
      !_override &&
      msg.sender != _account &&
      !operatorStore.hasPermission(msg.sender, _account, _domain, _permissionIndex) &&
      !operatorStore.hasPermission(msg.sender, _account, 0, _permissionIndex)
    ) revert UNAUTHORIZED();
  }
}// MIT
pragma solidity 0.8.6;

enum JBBallotState {
  Active,
  Approved,
  Failed
}// MIT
pragma solidity 0.8.6;


interface IJBFundingCycleBallot is IERC165 {

  function duration() external view returns (uint256);


  function stateOf(
    uint256 _projectId,
    uint256 _configuration,
    uint256 _start
  ) external view returns (JBBallotState);

}// MIT
pragma solidity 0.8.6;


struct JBFundingCycle {
  uint256 number;
  uint256 configuration;
  uint256 basedOn;
  uint256 start;
  uint256 duration;
  uint256 weight;
  uint256 discountRate;
  IJBFundingCycleBallot ballot;
  uint256 metadata;
}// MIT
pragma solidity 0.8.6;


struct JBFundingCycleData {
  uint256 duration;
  uint256 weight;
  uint256 discountRate;
  IJBFundingCycleBallot ballot;
}// MIT
pragma solidity 0.8.6;


interface IJBFundingCycleStore {

  event Configure(
    uint256 indexed configuration,
    uint256 indexed projectId,
    JBFundingCycleData data,
    uint256 metadata,
    uint256 mustStartAtOrAfter,
    address caller
  );

  event Init(uint256 indexed configuration, uint256 indexed projectId, uint256 indexed basedOn);

  function latestConfigurationOf(uint256 _projectId) external view returns (uint256);


  function get(uint256 _projectId, uint256 _configuration)
    external
    view
    returns (JBFundingCycle memory);


  function latestConfiguredOf(uint256 _projectId)
    external
    view
    returns (JBFundingCycle memory fundingCycle, JBBallotState ballotState);


  function queuedOf(uint256 _projectId) external view returns (JBFundingCycle memory fundingCycle);


  function currentOf(uint256 _projectId) external view returns (JBFundingCycle memory fundingCycle);


  function currentBallotStateOf(uint256 _projectId) external view returns (JBBallotState);


  function configureFor(
    uint256 _projectId,
    JBFundingCycleData calldata _data,
    uint256 _metadata,
    uint256 _mustStartAtOrAfter
  ) external returns (JBFundingCycle memory fundingCycle);

}// MIT
pragma solidity 0.8.6;


interface IJBPaymentTerminal is IERC165 {

  function acceptsToken(address _token, uint256 _projectId) external view returns (bool);


  function currencyForToken(address _token) external view returns (uint256);


  function decimalsForToken(address _token) external view returns (uint256);


  function currentEthOverflowOf(uint256 _projectId) external view returns (uint256);


  function pay(
    uint256 _projectId,
    uint256 _amount,
    address _token,
    address _beneficiary,
    uint256 _minReturnedTokens,
    bool _preferClaimedTokens,
    string calldata _memo,
    bytes calldata _metadata
  ) external payable returns (uint256 beneficiaryTokenCount);


  function addToBalanceOf(
    uint256 _projectId,
    uint256 _amount,
    address _token,
    string calldata _memo,
    bytes calldata _metadata
  ) external payable;

}// MIT
pragma solidity 0.8.6;

struct JBProjectMetadata {
  string content;
  uint256 domain;
}// MIT
pragma solidity 0.8.6;

interface IJBTokenUriResolver {

  function getUri(uint256 _projectId) external view returns (string memory tokenUri);

}// MIT
pragma solidity 0.8.6;


interface IJBProjects is IERC721 {

  event Create(
    uint256 indexed projectId,
    address indexed owner,
    JBProjectMetadata metadata,
    address caller
  );

  event SetMetadata(uint256 indexed projectId, JBProjectMetadata metadata, address caller);

  event SetTokenUriResolver(IJBTokenUriResolver indexed resolver, address caller);

  function count() external view returns (uint256);


  function metadataContentOf(uint256 _projectId, uint256 _domain)
    external
    view
    returns (string memory);


  function tokenUriResolver() external view returns (IJBTokenUriResolver);


  function createFor(address _owner, JBProjectMetadata calldata _metadata)
    external
    returns (uint256 projectId);


  function setMetadataOf(uint256 _projectId, JBProjectMetadata calldata _metadata) external;


  function setTokenUriResolver(IJBTokenUriResolver _newResolver) external;

}// MIT
pragma solidity 0.8.6;


interface IJBDirectory {

  event SetController(uint256 indexed projectId, address indexed controller, address caller);

  event AddTerminal(uint256 indexed projectId, IJBPaymentTerminal indexed terminal, address caller);

  event SetTerminals(uint256 indexed projectId, IJBPaymentTerminal[] terminals, address caller);

  event SetPrimaryTerminal(
    uint256 indexed projectId,
    address indexed token,
    IJBPaymentTerminal indexed terminal,
    address caller
  );

  event SetIsAllowedToSetFirstController(address indexed addr, bool indexed flag, address caller);

  function projects() external view returns (IJBProjects);


  function fundingCycleStore() external view returns (IJBFundingCycleStore);


  function controllerOf(uint256 _projectId) external view returns (address);


  function isAllowedToSetFirstController(address _address) external view returns (bool);


  function terminalsOf(uint256 _projectId) external view returns (IJBPaymentTerminal[] memory);


  function isTerminalOf(uint256 _projectId, IJBPaymentTerminal _terminal)
    external
    view
    returns (bool);


  function primaryTerminalOf(uint256 _projectId, address _token)
    external
    view
    returns (IJBPaymentTerminal);


  function setControllerOf(uint256 _projectId, address _controller) external;


  function setTerminalsOf(uint256 _projectId, IJBPaymentTerminal[] calldata _terminals) external;


  function setPrimaryTerminalOf(
    uint256 _projectId,
    address _token,
    IJBPaymentTerminal _terminal
  ) external;


  function setIsAllowedToSetFirstController(address _address, bool _flag) external;

}// MIT
pragma solidity 0.8.6;


struct JBSplitAllocationData {
  address token;
  uint256 amount;
  uint256 decimals;
  uint256 projectId;
  uint256 group;
  JBSplit split;
}// MIT
pragma solidity 0.8.6;


interface IJBSplitAllocator is IERC165 {

  function allocate(JBSplitAllocationData calldata _data) external payable;

}// MIT
pragma solidity 0.8.6;


struct JBSplit {
  bool preferClaimed;
  bool preferAddToBalance;
  uint256 percent;
  uint256 projectId;
  address payable beneficiary;
  uint256 lockedUntil;
  IJBSplitAllocator allocator;
}// MIT
pragma solidity 0.8.6;


struct JBGroupedSplits {
  uint256 group;
  JBSplit[] splits;
}// MIT
pragma solidity 0.8.6;


interface IJBSplitsStore {

  event SetSplit(
    uint256 indexed projectId,
    uint256 indexed domain,
    uint256 indexed group,
    JBSplit split,
    address caller
  );

  function projects() external view returns (IJBProjects);


  function directory() external view returns (IJBDirectory);


  function splitsOf(
    uint256 _projectId,
    uint256 _domain,
    uint256 _group
  ) external view returns (JBSplit[] memory);


  function set(
    uint256 _projectId,
    uint256 _domain,
    JBGroupedSplits[] memory _groupedSplits
  ) external;

}// MIT
pragma solidity 0.8.6;

library JBConstants {

  uint256 public constant MAX_RESERVED_RATE = 10000;
  uint256 public constant MAX_REDEMPTION_RATE = 10000;
  uint256 public constant MAX_DISCOUNT_RATE = 1000000000;
  uint256 public constant SPLITS_TOTAL_PERCENT = 1000000000;
  uint256 public constant MAX_FEE = 1000000000;
  uint256 public constant MAX_FEE_DISCOUNT = 1000000000;
}// MIT
pragma solidity 0.8.6;

library JBOperations {

  uint256 public constant RECONFIGURE = 1;
  uint256 public constant REDEEM = 2;
  uint256 public constant MIGRATE_CONTROLLER = 3;
  uint256 public constant MIGRATE_TERMINAL = 4;
  uint256 public constant PROCESS_FEES = 5;
  uint256 public constant SET_METADATA = 6;
  uint256 public constant ISSUE = 7;
  uint256 public constant CHANGE_TOKEN = 8;
  uint256 public constant MINT = 9;
  uint256 public constant BURN = 10;
  uint256 public constant CLAIM = 11;
  uint256 public constant TRANSFER = 12;
  uint256 public constant REQUIRE_CLAIM = 13;
  uint256 public constant SET_CONTROLLER = 14;
  uint256 public constant SET_TERMINALS = 15;
  uint256 public constant SET_PRIMARY_TERMINAL = 16;
  uint256 public constant USE_ALLOWANCE = 17;
  uint256 public constant SET_SPLITS = 18;
}// MIT
pragma solidity 0.8.6;


contract JBSplitsStore is IJBSplitsStore, JBOperatable {

  error INVALID_LOCKED_UNTIL();
  error INVALID_PROJECT_ID();
  error INVALID_SPLIT_PERCENT();
  error INVALID_TOTAL_PERCENT();
  error PREVIOUS_LOCKED_SPLITS_NOT_INCLUDED();


  mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))) private _splitCountOf;

  mapping(uint256 => mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))))
    private _packedSplitParts1Of;

  mapping(uint256 => mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))))
    private _packedSplitParts2Of;


  IJBProjects public immutable override projects;

  IJBDirectory public immutable override directory;


  function splitsOf(
    uint256 _projectId,
    uint256 _domain,
    uint256 _group
  ) external view override returns (JBSplit[] memory) {

    return _getStructsFor(_projectId, _domain, _group);
  }


  constructor(
    IJBOperatorStore _operatorStore,
    IJBProjects _projects,
    IJBDirectory _directory
  ) JBOperatable(_operatorStore) {
    projects = _projects;
    directory = _directory;
  }


  function set(
    uint256 _projectId,
    uint256 _domain,
    JBGroupedSplits[] calldata _groupedSplits
  )
    external
    override
    requirePermissionAllowingOverride(
      projects.ownerOf(_projectId),
      _projectId,
      JBOperations.SET_SPLITS,
      address(directory.controllerOf(_projectId)) == msg.sender
    )
  {

    uint256 _groupedSplitsLength = _groupedSplits.length;

    for (uint256 _i = 0; _i < _groupedSplitsLength; ) {
      JBGroupedSplits memory _groupedSplit = _groupedSplits[_i];

      _set(_projectId, _domain, _groupedSplit.group, _groupedSplit.splits);

      unchecked {
        ++_i;
      }
    }
  }


  function _set(
    uint256 _projectId,
    uint256 _domain,
    uint256 _group,
    JBSplit[] memory _splits
  ) internal {

    JBSplit[] memory _currentSplits = _getStructsFor(_projectId, _domain, _group);

    for (uint256 _i = 0; _i < _currentSplits.length; _i++) {
      if (block.timestamp >= _currentSplits[_i].lockedUntil) continue;

      bool _includesLocked = false;

      for (uint256 _j = 0; _j < _splits.length; _j++) {
        if (
          _splits[_j].percent == _currentSplits[_i].percent &&
          _splits[_j].beneficiary == _currentSplits[_i].beneficiary &&
          _splits[_j].allocator == _currentSplits[_i].allocator &&
          _splits[_j].projectId == _currentSplits[_i].projectId &&
          _splits[_j].lockedUntil >= _currentSplits[_i].lockedUntil
        ) _includesLocked = true;
      }

      if (!_includesLocked) revert PREVIOUS_LOCKED_SPLITS_NOT_INCLUDED();
    }

    uint256 _percentTotal = 0;

    for (uint256 _i = 0; _i < _splits.length; _i++) {
      if (_splits[_i].percent == 0) revert INVALID_SPLIT_PERCENT();

      if (_splits[_i].projectId > type(uint56).max) revert INVALID_PROJECT_ID();

      _percentTotal = _percentTotal + _splits[_i].percent;

      if (_percentTotal > JBConstants.SPLITS_TOTAL_PERCENT) revert INVALID_TOTAL_PERCENT();

      uint256 _packedSplitParts1;

      if (_splits[_i].preferClaimed) _packedSplitParts1 = 1;
      if (_splits[_i].preferAddToBalance) _packedSplitParts1 |= 1 << 1;
      _packedSplitParts1 |= _splits[_i].percent << 2;
      _packedSplitParts1 |= _splits[_i].projectId << 34;
      _packedSplitParts1 |= uint256(uint160(address(_splits[_i].beneficiary))) << 90;

      _packedSplitParts1Of[_projectId][_domain][_group][_i] = _packedSplitParts1;

      if (_splits[_i].lockedUntil > 0 || _splits[_i].allocator != IJBSplitAllocator(address(0))) {
        if (_splits[_i].lockedUntil > type(uint48).max) revert INVALID_LOCKED_UNTIL();

        uint256 _packedSplitParts2 = uint48(_splits[_i].lockedUntil);
        _packedSplitParts2 |= uint256(uint160(address(_splits[_i].allocator))) << 48;

        _packedSplitParts2Of[_projectId][_domain][_group][_i] = _packedSplitParts2;

      } else if (_packedSplitParts2Of[_projectId][_domain][_group][_i] > 0)
        delete _packedSplitParts2Of[_projectId][_domain][_group][_i];

      emit SetSplit(_projectId, _domain, _group, _splits[_i], msg.sender);
    }

    _splitCountOf[_projectId][_domain][_group] = _splits.length;
  }

  function _getStructsFor(
    uint256 _projectId,
    uint256 _domain,
    uint256 _group
  ) private view returns (JBSplit[] memory) {

    uint256 _splitCount = _splitCountOf[_projectId][_domain][_group];

    JBSplit[] memory _splits = new JBSplit[](_splitCount);

    for (uint256 _i = 0; _i < _splitCount; _i++) {
      uint256 _packedSplitPart1 = _packedSplitParts1Of[_projectId][_domain][_group][_i];

      JBSplit memory _split;

      _split.preferClaimed = _packedSplitPart1 & 1 == 1;
      _split.preferAddToBalance = (_packedSplitPart1 >> 1) & 1 == 1;
      _split.percent = uint256(uint32(_packedSplitPart1 >> 2));
      _split.projectId = uint256(uint56(_packedSplitPart1 >> 34));
      _split.beneficiary = payable(address(uint160(_packedSplitPart1 >> 90)));

      uint256 _packedSplitPart2 = _packedSplitParts2Of[_projectId][_domain][_group][_i];

      if (_packedSplitPart2 > 0) {
        _split.lockedUntil = uint256(uint48(_packedSplitPart2));
        _split.allocator = IJBSplitAllocator(address(uint160(_packedSplitPart2 >> 48)));
      }

      _splits[_i] = _split;
    }

    return _splits;
  }
}