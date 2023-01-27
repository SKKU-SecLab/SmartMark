
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


interface ITerminal {

  function terminalDirectory() external view returns (ITerminalDirectory);


  function migrationIsAllowed(ITerminal _terminal) external view returns (bool);


  function pay(
    uint256 _projectId,
    address _beneficiary,
    string calldata _memo,
    bool _preferUnstakedTickets
  ) external payable returns (uint256 fundingCycleId);


  function addToBalance(uint256 _projectId) external payable;


  function allowMigration(ITerminal _contract) external;


  function migrate(uint256 _projectId, ITerminal _to) external;

}// MIT
pragma solidity 0.8.6;

interface IOperatorStore {

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


    function setOperator(
        address _operator,
        uint256 _domain,
        uint256[] calldata _permissionIndexes
    ) external;


    function setOperators(
        address[] calldata _operators,
        uint256[] calldata _domains,
        uint256[][] calldata _permissionIndexes
    ) external;

}// MIT
pragma solidity 0.8.6;



interface IProjects is IERC721 {

    event Create(
        uint256 indexed projectId,
        address indexed owner,
        bytes32 indexed handle,
        string uri,
        ITerminal terminal,
        address caller
    );

    event SetHandle(
        uint256 indexed projectId,
        bytes32 indexed handle,
        address caller
    );

    event SetUri(uint256 indexed projectId, string uri, address caller);

    event TransferHandle(
        uint256 indexed projectId,
        address indexed to,
        bytes32 indexed handle,
        bytes32 newHandle,
        address caller
    );

    event ClaimHandle(
        address indexed account,
        uint256 indexed projectId,
        bytes32 indexed handle,
        address caller
    );

    event ChallengeHandle(
        bytes32 indexed handle,
        uint256 challengeExpiry,
        address caller
    );

    event RenewHandle(
        bytes32 indexed handle,
        uint256 indexed projectId,
        address caller
    );

    function count() external view returns (uint256);


    function uriOf(uint256 _projectId) external view returns (string memory);


    function handleOf(uint256 _projectId) external returns (bytes32 handle);


    function projectFor(bytes32 _handle) external returns (uint256 projectId);


    function transferAddressFor(bytes32 _handle)
        external
        returns (address receiver);


    function challengeExpiryOf(bytes32 _handle) external returns (uint256);


    function exists(uint256 _projectId) external view returns (bool);


    function create(
        address _owner,
        bytes32 _handle,
        string calldata _uri,
        ITerminal _terminal
    ) external returns (uint256 id);


    function setHandle(uint256 _projectId, bytes32 _handle) external;


    function setUri(uint256 _projectId, string calldata _uri) external;


    function transferHandle(
        uint256 _projectId,
        address _to,
        bytes32 _newHandle
    ) external returns (bytes32 _handle);


    function claimHandle(
        bytes32 _handle,
        address _for,
        uint256 _projectId
    ) external;

}// MIT
pragma solidity 0.8.6;


interface ITerminalDirectory {

    event DeployAddress(
        uint256 indexed projectId,
        string memo,
        address indexed caller
    );

    event SetTerminal(
        uint256 indexed projectId,
        ITerminal indexed terminal,
        address caller
    );

    event SetPayerPreferences(
        address indexed account,
        address beneficiary,
        bool preferUnstakedTickets
    );

    function projects() external view returns (IProjects);


    function terminalOf(uint256 _projectId) external view returns (ITerminal);


    function beneficiaryOf(address _account) external returns (address);


    function unstakedTicketsPreferenceOf(address _account)
        external
        returns (bool);


    function addressesOf(uint256 _projectId)
        external
        view
        returns (IDirectPaymentAddress[] memory);


    function deployAddress(uint256 _projectId, string calldata _memo) external;


    function setTerminal(uint256 _projectId, ITerminal _terminal) external;


    function setPayerPreferences(
        address _beneficiary,
        bool _preferUnstakedTickets
    ) external;

}// MIT
pragma solidity 0.8.6;


interface IDirectPaymentAddress {

    event Forward(
        address indexed payer,
        uint256 indexed projectId,
        address beneficiary,
        uint256 value,
        string memo,
        bool preferUnstakedTickets
    );

    function terminalDirectory() external returns (ITerminalDirectory);


    function projectId() external returns (uint256);


    function memo() external returns (string memory);

}// MIT
pragma solidity 0.8.6;


contract DirectPaymentAddress is IDirectPaymentAddress {


    ITerminalDirectory public immutable override terminalDirectory;

    uint256 public immutable override projectId;


    string public override memo;


    constructor(
        ITerminalDirectory _terminalDirectory,
        uint256 _projectId,
        string memory _memo
    ) {
        terminalDirectory = _terminalDirectory;
        projectId = _projectId;
        memo = _memo;
    }

    receive() external payable {
        address _storedBeneficiary = terminalDirectory.beneficiaryOf(
            msg.sender
        );
        address _beneficiary = _storedBeneficiary != address(0)
            ? _storedBeneficiary
            : msg.sender;

        bool _preferUnstakedTickets = terminalDirectory
        .unstakedTicketsPreferenceOf(msg.sender);

        terminalDirectory.terminalOf(projectId).pay{value: msg.value}(
            projectId,
            _beneficiary,
            memo,
            _preferUnstakedTickets
        );

        emit Forward(
            msg.sender,
            projectId,
            _beneficiary,
            msg.value,
            memo,
            _preferUnstakedTickets
        );
    }
}// MIT
pragma solidity 0.8.6;


interface IOperatable {

    function operatorStore() external view returns (IOperatorStore);

}// MIT
pragma solidity 0.8.6;


abstract contract Operatable is IOperatable {
    modifier requirePermission(
        address _account,
        uint256 _domain,
        uint256 _index
    ) {
        require(
            msg.sender == _account ||
                operatorStore.hasPermission(
                    msg.sender,
                    _account,
                    _domain,
                    _index
                ),
            "Operatable: UNAUTHORIZED"
        );
        _;
    }

    modifier requirePermissionAllowingWildcardDomain(
        address _account,
        uint256 _domain,
        uint256 _index
    ) {
        require(
            msg.sender == _account ||
                operatorStore.hasPermission(
                    msg.sender,
                    _account,
                    _domain,
                    _index
                ) ||
                operatorStore.hasPermission(msg.sender, _account, 0, _index),
            "Operatable: UNAUTHORIZED"
        );
        _;
    }

    modifier requirePermissionAcceptingAlternateAddress(
        address _account,
        uint256 _domain,
        uint256 _index,
        address _alternate
    ) {
        require(
            msg.sender == _account ||
                operatorStore.hasPermission(
                    msg.sender,
                    _account,
                    _domain,
                    _index
                ) ||
                msg.sender == _alternate,
            "Operatable: UNAUTHORIZED"
        );
        _;
    }

    IOperatorStore public immutable override operatorStore;

    constructor(IOperatorStore _operatorStore) {
        operatorStore = _operatorStore;
    }
}// MIT
pragma solidity 0.8.6;

library Operations {

  uint256 public constant Configure = 1;
  uint256 public constant PrintPreminedTickets = 2;
  uint256 public constant Redeem = 3;
  uint256 public constant Migrate = 4;
  uint256 public constant SetHandle = 5;
  uint256 public constant SetUri = 6;
  uint256 public constant ClaimHandle = 7;
  uint256 public constant RenewHandle = 8;
  uint256 public constant Issue = 9;
  uint256 public constant Stake = 10;
  uint256 public constant Unstake = 11;
  uint256 public constant Transfer = 12;
  uint256 public constant Lock = 13;
  uint256 public constant SetPayoutMods = 14;
  uint256 public constant SetTicketMods = 15;
  uint256 public constant SetTerminal = 16;
  uint256 public constant PrintTickets = 17;
}// MIT
pragma solidity 0.8.6;





contract TerminalDirectory is ITerminalDirectory, Operatable {


  mapping(uint256 => IDirectPaymentAddress[]) private _addressesOf;


  IProjects public immutable override projects;


  mapping(uint256 => ITerminal) public override terminalOf;

  mapping(address => address) public override beneficiaryOf;

  mapping(address => bool) public override unstakedTicketsPreferenceOf;


  function addressesOf(uint256 _projectId)
    external
    view
    override
    returns (IDirectPaymentAddress[] memory)
  {

    return _addressesOf[_projectId];
  }


  constructor(IProjects _projects, IOperatorStore _operatorStore) Operatable(_operatorStore) {
    projects = _projects;
  }

  function deployAddress(uint256 _projectId, string calldata _memo) external override {

    require(_projectId > 0, 'TerminalDirectory::deployAddress: ZERO_PROJECT');

    _addressesOf[_projectId].push(new DirectPaymentAddress(this, _projectId, _memo));

    emit DeployAddress(_projectId, _memo, msg.sender);
  }

  function setTerminal(uint256 _projectId, ITerminal _terminal) external override {

    ITerminal _currentTerminal = terminalOf[_projectId];

    address _projectOwner = projects.ownerOf(_projectId);

    require(
      (_currentTerminal == ITerminal(address(0)) &&
        (msg.sender == address(projects) || msg.sender == address(_terminal))) ||
        msg.sender == address(_currentTerminal) ||
        ((msg.sender == _projectOwner ||
          operatorStore.hasPermission(
            msg.sender,
            _projectOwner,
            _projectId,
            Operations.SetTerminal
          )) &&
          (_currentTerminal == ITerminal(address(0)) ||
            _currentTerminal.migrationIsAllowed(_terminal))),
      'TerminalDirectory::setTerminal: UNAUTHORIZED'
    );

    require(projects.exists(_projectId), 'TerminalDirectory::setTerminal: NOT_FOUND');

    require(_terminal != ITerminal(address(0)), 'TerminalDirectory::setTerminal: ZERO_ADDRESS');

    if (_currentTerminal == _terminal) return;

    terminalOf[_projectId] = _terminal;

    emit SetTerminal(_projectId, _terminal, msg.sender);
  }

  function setPayerPreferences(address _beneficiary, bool _preferUnstakedTickets)
    external
    override
  {

    beneficiaryOf[msg.sender] = _beneficiary;
    unstakedTicketsPreferenceOf[msg.sender] = _preferUnstakedTickets;

    emit SetPayerPreferences(msg.sender, _beneficiary, _preferUnstakedTickets);
  }
}