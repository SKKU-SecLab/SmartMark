
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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

  function acceptsToken(address _token) external view returns (bool);


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


interface IJBProjectPayer is IERC165 {

  event SetDefaultValues(
    uint256 indexed projectId,
    address indexed beneficiary,
    bool preferClaimedTokens,
    string memo,
    bytes metadata,
    bool preferAddToBalance,
    address caller
  );

  function directory() external view returns (IJBDirectory);


  function defaultProjectId() external view returns (uint256);


  function defaultBeneficiary() external view returns (address payable);


  function defaultPreferClaimedTokens() external view returns (bool);


  function defaultMemo() external view returns (string memory);


  function defaultMetadata() external view returns (bytes memory);


  function defaultPreferAddToBalance() external view returns (bool);


  function setDefaultValues(
    uint256 _projectId,
    address payable _beneficiary,
    bool _preferClaimedTokens,
    string memory _memo,
    bytes memory _metadata,
    bool _defaultPreferAddToBalance
  ) external;


  function pay(
    uint256 _projectId,
    address _token,
    uint256 _amount,
    uint256 _decimals,
    address _beneficiary,
    uint256 _minReturnedTokens,
    bool _preferClaimedTokens,
    string memory _memo,
    bytes memory _metadata
  ) external payable;


  function addToBalanceOf(
    uint256 _projectId,
    address _token,
    uint256 _amount,
    uint256 _decimals,
    string memory _memo,
    bytes memory _metadata
  ) external payable;


  receive() external payable;
}// MIT
pragma solidity 0.8.6;

library JBTokens {

  address public constant ETH = address(0x000000000000000000000000000000000000EEEe);
}// MIT
pragma solidity 0.8.6;


contract JBETHERC20ProjectPayer is IJBProjectPayer, Ownable, ERC165 {

  error INCORRECT_DECIMAL_AMOUNT();
  error NO_MSG_VALUE_ALLOWED();
  error TERMINAL_NOT_FOUND();


  IJBDirectory public immutable override directory;


  uint256 public override defaultProjectId;

  address payable public override defaultBeneficiary;

  bool public override defaultPreferClaimedTokens;

  string public override defaultMemo;

  bytes public override defaultMetadata;

  bool public override defaultPreferAddToBalance;


  function supportsInterface(bytes4 _interfaceId)
    public
    view
    virtual
    override(ERC165, IERC165)
    returns (bool)
  {

    return
      _interfaceId == type(IJBProjectPayer).interfaceId || super.supportsInterface(_interfaceId);
  }


  constructor(
    uint256 _defaultProjectId,
    address payable _defaultBeneficiary,
    bool _defaultPreferClaimedTokens,
    string memory _defaultMemo,
    bytes memory _defaultMetadata,
    bool _defaultPreferAddToBalance,
    IJBDirectory _directory,
    address _owner
  ) {
    defaultProjectId = _defaultProjectId;
    defaultBeneficiary = _defaultBeneficiary;
    defaultPreferClaimedTokens = _defaultPreferClaimedTokens;
    defaultMemo = _defaultMemo;
    defaultMetadata = _defaultMetadata;
    defaultPreferAddToBalance = _defaultPreferAddToBalance;
    directory = _directory;

    _transferOwnership(_owner);
  }


  receive() external payable virtual override {
    if (defaultPreferAddToBalance)
      _addToBalanceOf(
        defaultProjectId,
        JBTokens.ETH,
        address(this).balance,
        18, // balance is a fixed point number with 18 decimals.
        defaultMemo,
        defaultMetadata
      );
    else
      _pay(
        defaultProjectId,
        JBTokens.ETH,
        address(this).balance,
        18, // balance is a fixed point number with 18 decimals.
        defaultBeneficiary == address(0) ? msg.sender : defaultBeneficiary,
        0, // Can't determine expectation of returned tokens ahead of time.
        defaultPreferClaimedTokens,
        defaultMemo,
        defaultMetadata
      );
  }


  function setDefaultValues(
    uint256 _projectId,
    address payable _beneficiary,
    bool _preferClaimedTokens,
    string memory _memo,
    bytes memory _metadata,
    bool _defaultPreferAddToBalance
  ) external virtual override onlyOwner {

    if (_projectId != defaultProjectId) defaultProjectId = _projectId;

    if (_beneficiary != defaultBeneficiary) defaultBeneficiary = _beneficiary;

    if (_preferClaimedTokens != defaultPreferClaimedTokens)
      defaultPreferClaimedTokens = _preferClaimedTokens;

    if (keccak256(abi.encodePacked(_memo)) != keccak256(abi.encodePacked(defaultMemo)))
      defaultMemo = _memo;

    if (keccak256(abi.encodePacked(_metadata)) != keccak256(abi.encodePacked(defaultMetadata)))
      defaultMetadata = _metadata;

    if (_defaultPreferAddToBalance != defaultPreferAddToBalance)
      defaultPreferAddToBalance = _defaultPreferAddToBalance;

    emit SetDefaultValues(
      _projectId,
      _beneficiary,
      _preferClaimedTokens,
      _memo,
      _metadata,
      _defaultPreferAddToBalance,
      msg.sender
    );
  }


  function pay(
    uint256 _projectId,
    address _token,
    uint256 _amount,
    uint256 _decimals,
    address _beneficiary,
    uint256 _minReturnedTokens,
    bool _preferClaimedTokens,
    string calldata _memo,
    bytes calldata _metadata
  ) public payable virtual override {

    if (address(_token) != JBTokens.ETH) {
      if (msg.value > 0) revert NO_MSG_VALUE_ALLOWED();

      IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    } else {
      _amount = msg.value;
      _decimals = 18;
    }

    _pay(
      _projectId,
      _token,
      _amount,
      _decimals,
      _beneficiary,
      _minReturnedTokens,
      _preferClaimedTokens,
      _memo,
      _metadata
    );
  }

  function addToBalanceOf(
    uint256 _projectId,
    address _token,
    uint256 _amount,
    uint256 _decimals,
    string calldata _memo,
    bytes calldata _metadata
  ) public payable virtual override {

    if (address(_token) != JBTokens.ETH) {
      if (msg.value > 0) revert NO_MSG_VALUE_ALLOWED();

      IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    } else {
      _amount = msg.value;
      _decimals = 18;
    }

    _addToBalanceOf(_projectId, _token, _amount, _decimals, _memo, _metadata);
  }


  function _pay(
    uint256 _projectId,
    address _token,
    uint256 _amount,
    uint256 _decimals,
    address _beneficiary,
    uint256 _minReturnedTokens,
    bool _preferClaimedTokens,
    string memory _memo,
    bytes memory _metadata
  ) internal virtual {

    IJBPaymentTerminal _terminal = directory.primaryTerminalOf(_projectId, _token);

    if (_terminal == IJBPaymentTerminal(address(0))) revert TERMINAL_NOT_FOUND();

    if (_terminal.decimalsForToken(_token) != _decimals) revert INCORRECT_DECIMAL_AMOUNT();

    if (_token != JBTokens.ETH) IERC20(_token).approve(address(_terminal), _amount);

    uint256 _payableValue = _token == JBTokens.ETH ? _amount : 0;

    _terminal.pay{value: _payableValue}(
      _projectId,
      _amount, // ignored if the token is JBTokens.ETH.
      _token,
      _beneficiary != address(0) ? _beneficiary : msg.sender,
      _minReturnedTokens,
      _preferClaimedTokens,
      _memo,
      _metadata
    );
  }

  function _addToBalanceOf(
    uint256 _projectId,
    address _token,
    uint256 _amount,
    uint256 _decimals,
    string memory _memo,
    bytes memory _metadata
  ) internal virtual {

    IJBPaymentTerminal _terminal = directory.primaryTerminalOf(_projectId, _token);

    if (_terminal == IJBPaymentTerminal(address(0))) revert TERMINAL_NOT_FOUND();

    if (_terminal.decimalsForToken(_token) != _decimals) revert INCORRECT_DECIMAL_AMOUNT();

    if (_token != JBTokens.ETH) IERC20(_token).approve(address(_terminal), _amount);

    uint256 _payableValue = _token == JBTokens.ETH ? _amount : 0;

    _terminal.addToBalanceOf{value: _payableValue}(_projectId, _amount, _token, _memo, _metadata);
  }
}// MIT
pragma solidity 0.8.6;


interface IJBETHERC20ProjectPayerDeployer {

  event DeployProjectPayer(
    IJBProjectPayer indexed projectPayer,
    uint256 defaultProjectId,
    address defaultBeneficiary,
    bool defaultPreferClaimedTokens,
    string defaultMemo,
    bytes defaultMetadata,
    bool preferAddToBalance,
    IJBDirectory directory,
    address owner,
    address caller
  );

  function deployProjectPayer(
    uint256 _defaultProjectId,
    address payable _defaultBeneficiary,
    bool _defaultPreferClaimedTokens,
    string memory _defaultMemo,
    bytes memory _defaultMetadata,
    bool _preferAddToBalance,
    IJBDirectory _directory,
    address _owner
  ) external returns (IJBProjectPayer projectPayer);

}// MIT
pragma solidity 0.8.6;


contract JBETHERC20ProjectPayerDeployer is IJBETHERC20ProjectPayerDeployer {


  function deployProjectPayer(
    uint256 _defaultProjectId,
    address payable _defaultBeneficiary,
    bool _defaultPreferClaimedTokens,
    string memory _defaultMemo,
    bytes memory _defaultMetadata,
    bool _defaultPreferAddToBalance,
    IJBDirectory _directory,
    address _owner
  ) external override returns (IJBProjectPayer projectPayer) {

    projectPayer = new JBETHERC20ProjectPayer(
      _defaultProjectId,
      _defaultBeneficiary,
      _defaultPreferClaimedTokens,
      _defaultMemo,
      _defaultMetadata,
      _defaultPreferAddToBalance,
      _directory,
      _owner
    );

    emit DeployProjectPayer(
      projectPayer,
      _defaultProjectId,
      _defaultBeneficiary,
      _defaultPreferClaimedTokens,
      _defaultMemo,
      _defaultMetadata,
      _defaultPreferAddToBalance,
      _directory,
      _owner,
      msg.sender
    );
  }
}