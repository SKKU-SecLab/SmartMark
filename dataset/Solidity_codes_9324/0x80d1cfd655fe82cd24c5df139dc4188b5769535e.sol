
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

interface IModAllocator {

    event Allocate(
        uint256 indexed projectId,
        uint256 indexed forProjectId,
        address indexed beneficiary,
        uint256 amount,
        address caller
    );

    function allocate(
        uint256 _projectId,
        uint256 _forProjectId,
        address _beneficiary
    ) external payable;

}// MIT
pragma solidity 0.8.6;


struct PayoutMod {
    bool preferUnstaked;
    uint16 percent;
    uint48 lockedUntil;
    address payable beneficiary;
    IModAllocator allocator;
    uint56 projectId;
}

struct TicketMod {
    bool preferUnstaked;
    uint16 percent;
    uint48 lockedUntil;
    address payable beneficiary;
}

interface IModStore {

    event SetPayoutMod(
        uint256 indexed projectId,
        uint256 indexed configuration,
        PayoutMod mods,
        address caller
    );

    event SetTicketMod(
        uint256 indexed projectId,
        uint256 indexed configuration,
        TicketMod mods,
        address caller
    );

    function projects() external view returns (IProjects);


    function payoutModsOf(uint256 _projectId, uint256 _configuration)
        external
        view
        returns (PayoutMod[] memory);


    function ticketModsOf(uint256 _projectId, uint256 _configuration)
        external
        view
        returns (TicketMod[] memory);


    function setPayoutMods(
        uint256 _projectId,
        uint256 _configuration,
        PayoutMod[] memory _mods
    ) external;


    function setTicketMods(
        uint256 _projectId,
        uint256 _configuration,
        TicketMod[] memory _mods
    ) external;

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


interface ITerminalUtility {

    function terminalDirectory() external view returns (ITerminalDirectory);

}// MIT
pragma solidity 0.8.6;


abstract contract TerminalUtility is ITerminalUtility {
    modifier onlyTerminal(uint256 _projectId) {
        require(
            address(terminalDirectory.terminalOf(_projectId)) == msg.sender,
            "TerminalUtility: UNAUTHORIZED"
        );
        _;
    }

    ITerminalDirectory public immutable override terminalDirectory;

    constructor(ITerminalDirectory _terminalDirectory) {
        terminalDirectory = _terminalDirectory;
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



contract ModStore is IModStore, Operatable, TerminalUtility {


    mapping(uint256 => mapping(uint256 => PayoutMod[])) private _payoutModsOf;

    mapping(uint256 => mapping(uint256 => TicketMod[])) private _ticketModsOf;


    IProjects public immutable override projects;


    function payoutModsOf(uint256 _projectId, uint256 _configuration)
        external
        view
        override
        returns (PayoutMod[] memory)
    {

        return _payoutModsOf[_projectId][_configuration];
    }

    function ticketModsOf(uint256 _projectId, uint256 _configuration)
        external
        view
        override
        returns (TicketMod[] memory)
    {

        return _ticketModsOf[_projectId][_configuration];
    }


    constructor(
        IProjects _projects,
        IOperatorStore _operatorStore,
        ITerminalDirectory _terminalDirectory
    ) Operatable(_operatorStore) TerminalUtility(_terminalDirectory) {
        projects = _projects;
    }

    function setPayoutMods(
        uint256 _projectId,
        uint256 _configuration,
        PayoutMod[] memory _mods
    )
        external
        override
        requirePermissionAcceptingAlternateAddress(
            projects.ownerOf(_projectId),
            _projectId,
            Operations.SetPayoutMods,
            address(terminalDirectory.terminalOf(_projectId))
        )
    {

        require(_mods.length > 0, "ModStore::setPayoutMods: NO_OP");

        PayoutMod[] memory _currentMods = _payoutModsOf[_projectId][
            _configuration
        ];

        for (uint256 _i = 0; _i < _currentMods.length; _i++) {
            if (block.timestamp < _currentMods[_i].lockedUntil) {
                bool _includesLocked = false;
                for (uint256 _j = 0; _j < _mods.length; _j++) {
                    if (
                        _mods[_j].percent == _currentMods[_i].percent &&
                        _mods[_j].beneficiary == _currentMods[_i].beneficiary &&
                        _mods[_j].allocator == _currentMods[_i].allocator &&
                        _mods[_j].projectId == _currentMods[_i].projectId &&
                        _mods[_j].lockedUntil >= _currentMods[_i].lockedUntil
                    ) _includesLocked = true;
                }
                require(
                    _includesLocked,
                    "ModStore::setPayoutMods: SOME_LOCKED"
                );
            }
        }

        delete _payoutModsOf[_projectId][_configuration];

        uint256 _payoutModPercentTotal = 0;

        for (uint256 _i = 0; _i < _mods.length; _i++) {
            require(
                _mods[_i].percent > 0,
                "ModStore::setPayoutMods: BAD_MOD_PERCENT"
            );

            _payoutModPercentTotal = _payoutModPercentTotal + _mods[_i].percent;

            require(
                _payoutModPercentTotal <= 10000,
                "ModStore::setPayoutMods: BAD_TOTAL_PERCENT"
            );

            require(
                _mods[_i].allocator != IModAllocator(address(0)) ||
                    _mods[_i].beneficiary != address(0),
                "ModStore::setPayoutMods: ZERO_ADDRESS"
            );

            _payoutModsOf[_projectId][_configuration].push(_mods[_i]);

            emit SetPayoutMod(
                _projectId,
                _configuration,
                _mods[_i],
                msg.sender
            );
        }
    }

    function setTicketMods(
        uint256 _projectId,
        uint256 _configuration,
        TicketMod[] memory _mods
    )
        external
        override
        requirePermissionAcceptingAlternateAddress(
            projects.ownerOf(_projectId),
            _projectId,
            Operations.SetTicketMods,
            address(terminalDirectory.terminalOf(_projectId))
        )
    {

        require(_mods.length > 0, "ModStore::setTicketMods: NO_OP");

        TicketMod[] memory _projectTicketMods = _ticketModsOf[_projectId][
            _configuration
        ];

        for (uint256 _i = 0; _i < _projectTicketMods.length; _i++) {
            if (block.timestamp < _projectTicketMods[_i].lockedUntil) {
                bool _includesLocked = false;
                for (uint256 _j = 0; _j < _mods.length; _j++) {
                    if (
                        _mods[_j].percent == _projectTicketMods[_i].percent &&
                        _mods[_j].beneficiary ==
                        _projectTicketMods[_i].beneficiary &&
                        _mods[_j].lockedUntil >=
                        _projectTicketMods[_i].lockedUntil
                    ) _includesLocked = true;
                }
                require(
                    _includesLocked,
                    "ModStore::setTicketMods: SOME_LOCKED"
                );
            }
        }
        delete _ticketModsOf[_projectId][_configuration];

        uint256 _ticketModPercentTotal = 0;

        for (uint256 _i = 0; _i < _mods.length; _i++) {
            require(
                _mods[_i].percent > 0,
                "ModStore::setTicketMods: BAD_MOD_PERCENT"
            );

            _ticketModPercentTotal = _ticketModPercentTotal + _mods[_i].percent;
            require(
                _ticketModPercentTotal <= 10000,
                "ModStore::setTicketMods: BAD_TOTAL_PERCENT"
            );

            require(
                _mods[_i].beneficiary != address(0),
                "ModStore::setTicketMods: ZERO_ADDRESS"
            );

            _ticketModsOf[_projectId][_configuration].push(_mods[_i]);

            emit SetTicketMod(
                _projectId,
                _configuration,
                _mods[_i],
                msg.sender
            );
        }
    }
}