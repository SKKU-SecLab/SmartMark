


pragma solidity ^0.7.0;

interface LinkTokenInterface {

  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);

}




pragma solidity ^0.7.0;

contract Owned {


  address public owner;
  address private pendingOwner;

  event OwnershipTransferRequested(
    address indexed from,
    address indexed to
  );
  event OwnershipTransferred(
    address indexed from,
    address indexed to
  );

  constructor() {
    owner = msg.sender;
  }

  function transferOwnership(address _to)
    external
    onlyOwner()
  {

    pendingOwner = _to;

    emit OwnershipTransferRequested(owner, _to);
  }

  function acceptOwnership()
    external
  {

    require(msg.sender == pendingOwner, "Must be proposed owner");

    address oldOwner = owner;
    owner = msg.sender;
    pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  modifier onlyOwner() {

    require(msg.sender == owner, "Only callable by owner");
    _;
  }

}




pragma solidity 0.7.6;

interface KeeperRegistryBaseInterface {

  function registerUpkeep(
    address target,
    uint32 gasLimit,
    address admin,
    bytes calldata checkData
  ) external returns (
      uint256 id
    );

  function performUpkeep(
    uint256 id,
    bytes calldata performData
  ) external returns (
      bool success
    );

  function cancelUpkeep(
    uint256 id
  ) external;

  function addFunds(
    uint256 id,
    uint96 amount
  ) external;


  function getUpkeep(uint256 id)
    external view returns (
      address target,
      uint32 executeGas,
      bytes memory checkData,
      uint96 balance,
      address lastKeeper,
      address admin,
      uint64 maxValidBlocknumber
    );

  function getUpkeepCount()
    external view returns (uint256);

  function getCanceledUpkeepList()
    external view returns (uint256[] memory);

  function getKeeperList()
    external view returns (address[] memory);

  function getKeeperInfo(address query)
    external view returns (
      address payee,
      bool active,
      uint96 balance
    );

  function getConfig()
    external view returns (
      uint32 paymentPremiumPPB,
      uint24 checkFrequencyBlocks,
      uint32 checkGasLimit,
      uint24 stalenessSeconds,
      uint16 gasCeilingMultiplier,
      uint256 fallbackGasPrice,
      uint256 fallbackLinkPrice
    );

}

interface KeeperRegistryInterface is KeeperRegistryBaseInterface {

  function checkUpkeep(
    uint256 upkeepId,
    address from
  )
    external
    view
    returns (
      bytes memory performData,
      uint256 maxLinkPayment,
      uint256 gasLimit,
      int256 gasWei,
      int256 linkEth
    );

}

interface KeeperRegistryExecutableInterface is KeeperRegistryBaseInterface {

  function checkUpkeep(
    uint256 upkeepId,
    address from
  )
    external
    returns (
      bytes memory performData,
      uint256 maxLinkPayment,
      uint256 gasLimit,
      uint256 adjustedGasWei,
      uint256 linkEth
    );

}




pragma solidity ^0.7.0;

library SafeMath96 {

  function add(uint96 a, uint96 b) internal pure returns (uint96) {

    uint96 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint96 a, uint96 b) internal pure returns (uint96) {

    require(b <= a, "SafeMath: subtraction overflow");
    uint96 c = a - b;

    return c;
  }

  function mul(uint96 a, uint96 b) internal pure returns (uint96) {

    if (a == 0) {
      return 0;
    }

    uint96 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint96 a, uint96 b) internal pure returns (uint96) {

    require(b > 0, "SafeMath: division by zero");
    uint96 c = a / b;

    return c;
  }

  function mod(uint96 a, uint96 b) internal pure returns (uint96) {

    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}




pragma solidity 0.7.6;




contract UpkeepRegistrationRequests is Owned {

    using SafeMath96 for uint96;

    bytes4 private constant REGISTER_REQUEST_SELECTOR = this.register.selector;

    uint256 private s_minLINKJuels;
    mapping(bytes32 => PendingRequest) private s_pendingRequests;

    LinkTokenInterface public immutable LINK;

    struct AutoApprovedConfig {
        bool enabled;
        uint16 allowedPerWindow;
        uint32 windowSizeInBlocks;
        uint64 windowStart;
        uint16 approvedInCurrentWindow;
    }

    struct PendingRequest {
        address admin;
        uint96 balance;
    }

    AutoApprovedConfig private s_config;
    KeeperRegistryBaseInterface private s_keeperRegistry;

    event RegistrationRequested(
        bytes32 indexed hash,
        string name,
        bytes encryptedEmail,
        address indexed upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes checkData,
        uint96 amount,
        uint8 indexed source
    );

    event RegistrationApproved(
        bytes32 indexed hash,
        string displayName,
        uint256 indexed upkeepId
    );

    event ConfigChanged(
        bool enabled,
        uint32 windowSizeInBlocks,
        uint16 allowedPerWindow,
        address keeperRegistry,
        uint256 minLINKJuels
    );

    constructor(
        address LINKAddress,
        uint256 minimumLINKJuels
    ) {
        LINK = LinkTokenInterface(LINKAddress);
        s_minLINKJuels = minimumLINKJuels;
    }


    function register(
        string memory name,
        bytes calldata encryptedEmail,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        uint96 amount,
        uint8 source
    )
      external
      onlyLINK()
    {

        require(adminAddress != address(0), "invalid admin address");
        bytes32 hash = keccak256(abi.encode(upkeepContract, gasLimit, adminAddress, checkData));

        emit RegistrationRequested(
            hash,
            name,
            encryptedEmail,
            upkeepContract,
            gasLimit,
            adminAddress,
            checkData,
            amount,
            source
        );

        AutoApprovedConfig memory config = s_config;
        if (config.enabled && _underApprovalLimit(config)) {
            _incrementApprovedCount(config);

            _approve(
                name,
                upkeepContract,
                gasLimit,
                adminAddress,
                checkData,
                amount,
                hash
            );
        } else {
            uint96 newBalance = s_pendingRequests[hash].balance.add(amount);
            s_pendingRequests[hash] = PendingRequest({
                admin: adminAddress,
                balance: newBalance
            });
        }
    }

    function approve(
        string memory name,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        bytes32 hash
    )
      external
      onlyOwner()
    {

        PendingRequest memory request = s_pendingRequests[hash];
        require(request.admin != address(0), "request not found");
        bytes32 expectedHash = keccak256(abi.encode(upkeepContract, gasLimit, adminAddress, checkData));
        require(hash == expectedHash, "hash and payload do not match");
        delete s_pendingRequests[hash];
        _approve(
            name,
            upkeepContract,
            gasLimit,
            adminAddress,
            checkData,
            request.balance,
            hash
        );
    }

    function cancel(
        bytes32 hash
    )
      external
    {

        PendingRequest memory request = s_pendingRequests[hash];
        require(msg.sender == request.admin || msg.sender == owner, "only admin / owner can cancel");
        require(request.admin != address(0), "request not found");
        delete s_pendingRequests[hash];
        require(LINK.transfer(msg.sender, request.balance), "LINK token transfer failed");
    }

    function setRegistrationConfig(
        bool enabled,
        uint32 windowSizeInBlocks,
        uint16 allowedPerWindow,
        address keeperRegistry,
        uint256 minLINKJuels
    )
      external
      onlyOwner()
    {

        s_config = AutoApprovedConfig({
            enabled: enabled,
            allowedPerWindow: allowedPerWindow,
            windowSizeInBlocks: windowSizeInBlocks,
            windowStart: 0,
            approvedInCurrentWindow: 0
        });
        s_minLINKJuels = minLINKJuels;
        s_keeperRegistry = KeeperRegistryBaseInterface(keeperRegistry);

        emit ConfigChanged(
          enabled,
          windowSizeInBlocks,
          allowedPerWindow,
          keeperRegistry,
          minLINKJuels
        );
    }

    function getRegistrationConfig()
        external
        view
        returns (
            bool enabled,
            uint32 windowSizeInBlocks,
            uint16 allowedPerWindow,
            address keeperRegistry,
            uint256 minLINKJuels,
            uint64 windowStart,
            uint16 approvedInCurrentWindow
        )
    {

        AutoApprovedConfig memory config = s_config;
        return (
            config.enabled,
            config.windowSizeInBlocks,
            config.allowedPerWindow,
            address(s_keeperRegistry),
            s_minLINKJuels,
            config.windowStart,
            config.approvedInCurrentWindow
        );
    }

    function getPendingRequest(bytes32 hash) external view returns(address, uint96) {

        PendingRequest memory request = s_pendingRequests[hash];
        return (request.admin, request.balance);
    }

    function onTokenTransfer(
        address, /* sender */
        uint256 amount,
        bytes calldata data
    )
      external
      onlyLINK()
      permittedFunctionsForLINK(data)
      isActualAmount(amount, data)
    {

        require(amount >= s_minLINKJuels, "Insufficient payment");
        (bool success, ) = address(this).delegatecall(data); // calls register
        require(success, "Unable to create request");
    }


    function _resetWindowIfRequired(
        AutoApprovedConfig memory config
    )
      private
    {

        uint64 blocksPassed = uint64(block.number - config.windowStart);
        if (blocksPassed >= config.windowSizeInBlocks) {
            config.windowStart = uint64(block.number);
            config.approvedInCurrentWindow = 0;
            s_config = config;
        }
    }

    function _approve(
        string memory name,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        uint96 amount,
        bytes32 hash
    )
      private
    {

        KeeperRegistryBaseInterface keeperRegistry = s_keeperRegistry;

        uint256 upkeepId = keeperRegistry.registerUpkeep(
            upkeepContract,
            gasLimit,
            adminAddress,
            checkData
        );
        bool success = LINK.transferAndCall(
          address(keeperRegistry),
          amount,
          abi.encode(upkeepId)
        );
        require(success, "failed to fund upkeep");

        emit RegistrationApproved(hash, name, upkeepId);
    }

    function _underApprovalLimit(
      AutoApprovedConfig memory config
    )
      private
      returns (bool)
    {

        _resetWindowIfRequired(config);
        if (config.approvedInCurrentWindow < config.allowedPerWindow) {
            return true;
        }
        return false;
    }

    function _incrementApprovedCount(
      AutoApprovedConfig memory config
    )
      private
    {

        config.approvedInCurrentWindow++;
        s_config = config;
    }


    modifier onlyLINK() {

        require(msg.sender == address(LINK), "Must use LINK token");
        _;
    }

    modifier permittedFunctionsForLINK(
        bytes memory _data
    ) {

        bytes4 funcSelector;
        assembly {
            funcSelector := mload(add(_data, 32))
        }
        require(
            funcSelector == REGISTER_REQUEST_SELECTOR,
            "Must use whitelisted functions"
        );
        _;
    }

  modifier isActualAmount(
    uint256 expected,
    bytes memory data
  ) {

      uint256 actual;
      assembly{
          actual := mload(add(data, 228))
      }
      require(expected == actual, "Amount mismatch");
      _;
  }
}