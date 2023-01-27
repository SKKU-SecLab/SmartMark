
pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal virtual view returns (address);

    function _fallback() internal {
        _delegate(_implementation());
    }

    fallback () payable external {
        _fallback();
    }

    receive () payable external {
        _fallback();
    }
}// MIT

pragma solidity ^0.8.0;


contract BaseUpgradeabilityProxy is Proxy {


    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _implementation() internal override view returns (address impl) {

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) internal {

        require(Address.isContract(newImplementation), "UpgradeableProxy: new implementation is not a contract");

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract BaseAdminUpgradeabilityProxy is BaseUpgradeabilityProxy {

  event AdminChanged(address previousAdmin, address newAdmin);


  bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  modifier ifAdmin() {

    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  function admin() external ifAdmin returns (address proxyAdmin) {

    proxyAdmin = _admin();
  }

  function implementation() external ifAdmin returns (address impl) {

    impl = _implementation();
  }

  function changeAdmin(address newAdmin) external ifAdmin {

    require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  function upgradeTo(address newImplementation) external ifAdmin {

    _upgradeTo(newImplementation);
  }

  function upgradeToAndCall(address newImplementation, bytes calldata data) payable external ifAdmin {

    _upgradeTo(newImplementation);
    (bool success,) = newImplementation.delegatecall(data);
    require(success);
  }

  function _admin() internal view returns (address adm) {

    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  function _setAdmin(address newAdmin) internal {

    bytes32 slot = ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }
}// No License

pragma solidity ^0.8.0;


contract InitializableAdminUpgradeabilityProxy is BaseAdminUpgradeabilityProxy {

  function initialize(address _logic, address _admin, bytes memory _data) public payable {

    require(_implementation() == address(0));

    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
    _setImplementation(_logic);
    if(_data.length > 0) {
      (bool success,) = _logic.delegatecall(_data);
      require(success);
    }

    assert(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1));
    _setAdmin(_admin);
  }
}// MIT

pragma solidity ^0.8.0;

library Create2 {

    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address payable) {

        address payable addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {

        return computeAddress(salt, bytecodeHash, address(this));
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {

        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(uint160(uint256(_data)));
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity ^0.8.0;

interface IOwnable {

    function owner() external view returns (address);

}// No License

pragma solidity ^0.8.0;


contract Ownable is Initializable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initializeOwner() internal initializer {

        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }


    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
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

library StringHelper {

  function stringToBytes32(string calldata str) internal pure returns (bytes32 result) {

    bytes memory strBytes = abi.encodePacked(str);
    assembly {
      result := mload(add(strBytes, 32))
    }
  }

  function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {

    uint8 i = 0;
    while(i < 32 && _bytes32[i] != 0) {
        i++;
    }
    bytes memory bytesArray = new bytes(i);
    for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
        bytesArray[i] = _bytes32[i];
    }
    return string(bytesArray);
  }

  function uintToString(uint256 _i) internal pure returns (string memory _uintAsString) {

    if (_i == 0) {
      return '0';
    } else {
      bytes32 ret;
      while (_i > 0) {
        ret = bytes32(uint(ret) / (2 ** 8));
        ret |= bytes32(((_i % 10) + 48) * 2 ** (8 * 31));
        _i /= 10;
      }
      _uintAsString = bytes32ToString(ret);
    }
  }
}// No License

pragma solidity ^0.8.0;


interface ICoverERC20 is IERC20 {

    function mint(address _account, uint256 _amount) external returns (bool);

    function burnByCover(address _account, uint256 _amount) external returns (bool);

}// No License

pragma solidity ^0.8.0;


interface ICover {

  event CovTokenCreated(address);
  event CoverDeployCompleted();
  event Redeemed(string _type, address indexed _account, uint256 _amount);
  event FutureTokenConverted(address indexed _futureToken, address indexed claimCovToken, uint256 _amount);

  function BASE_SCALE() external view returns (uint256);

  function deployComplete() external view returns (bool);

  function expiry() external view returns (uint48);

  function collateral() external view returns (address);

  function noclaimCovToken() external view returns (ICoverERC20);

  function name() external view returns (string memory);

  function feeRate() external view returns (uint256);

  function totalCoverage() external view returns (uint256);

  function mintRatio() external view returns (uint256);

  function claimNonce() external view returns (uint256);

  function futureCovTokens(uint256 _index) external view returns (ICoverERC20);

  function claimCovTokenMap(bytes32 _risk) external view returns (ICoverERC20);

  function futureCovTokenMap(ICoverERC20 _futureCovToken) external view returns (ICoverERC20 _claimCovToken);


  function viewRedeemable(address _account, uint256 _coverageAmt) external view returns (uint256);

  function getCovTokens() external view
    returns (
      ICoverERC20 _noclaimCovToken,
      ICoverERC20[] memory _claimCovTokens,
      ICoverERC20[] memory _futureCovTokens);


  function deploy() external;

  function convert(ICoverERC20[] calldata _futureTokens) external;

  function redeemClaim() external;

  function redeem(uint256 _amount) external;

  function collectFees() external;


  function mint(uint256 _amount, address _receiver) external;

  function addRisk(bytes32 _risk) external;

}// MIT

pragma solidity ^0.8.0;

interface IClaimManagement {

  event ClaimUpdate(address indexed coverPool, ClaimState state, uint256 nonce, uint256 index);

  enum ClaimState { Filed, ForceFiled, Validated, Invalidated, Accepted, Denied }
  struct Claim {
    address filedBy; // Address of user who filed claim
    address decidedBy; // Address of the CVC who decided claim
    uint48 filedTimestamp; // Timestamp of submitted claim
    uint48 incidentTimestamp; // Timestamp of the incident the claim is filed for
    uint48 decidedTimestamp; // Timestamp when claim outcome is decided
    string description;
    ClaimState state; // Current state of claim
    uint256 feePaid; // Fee paid to file the claim
    bytes32[] payoutRiskList;
    uint256[] payoutRates; // Numerators of percent to payout
  }

  function getCoverPoolClaims(address _coverPool, uint256 _nonce, uint256 _index) external view returns (Claim memory);

  function getAllClaimsByState(address _coverPool, uint256 _nonce, ClaimState _state) external view returns (Claim[] memory);

  function getAllClaimsByNonce(address _coverPool, uint256 _nonce) external view returns (Claim[] memory);

  function hasPendingClaim(address _coverPool, uint256 _nonce) external view returns (bool);


  function fileClaim(
    string calldata _coverPoolName,
    bytes32[] calldata _exploitRisks,
    uint48 _incidentTimestamp,
    string calldata _description,
    bool _isForceFile
  ) external;

  
  function validateClaim(address _coverPool, uint256 _nonce, uint256 _index, bool _claimIsValid) external;


  function decideClaim(
    address _coverPool,
    uint256 _nonce,
    uint256 _index,
    uint48 _incidentTimestamp,
    bool _claimIsAccepted,
    bytes32[] calldata _exploitRisks,
    uint256[] calldata _payoutRates
  ) external;

 }// No License

pragma solidity ^0.8.0;

interface ICoverPool {

  event CoverCreated(address indexed);
  event CoverAdded(address indexed _cover, address _acount, uint256 _amount);
  event NoclaimRedeemDelayUpdated(uint256 _oldDelay, uint256 _newDelay);
  event ClaimEnacted(uint256 _enactedClaimNonce);
  event RiskUpdated(bytes32 _risk, bool _isAddRisk);
  event PoolStatusUpdated(Status _old, Status _new);
  event ExpiryUpdated(uint48 _expiry, string _expiryStr,  Status _status);
  event CollateralUpdated(address indexed _collateral, uint256 _mintRatio,  Status _status);

  enum Status { Null, Active, Disabled }

  struct ExpiryInfo {
    string name;
    Status status;
  }
  struct CollateralInfo {
    uint256 mintRatio;
    Status status;
  }
  struct ClaimDetails {
    uint48 incidentTimestamp;
    uint48 claimEnactedTimestamp;
    uint256 totalPayoutRate;
    bytes32[] payoutRiskList;
    uint256[] payoutRates;
  }

  function name() external view returns (string memory);

  function extendablePool() external view returns (bool);

  function poolStatus() external view returns (Status _status);

  function claimNonce() external view returns (uint256);

  function noclaimRedeemDelay() external view returns (uint256);

  function addingRiskWIP() external view returns (bool);

  function addingRiskIndex() external view returns (uint256);

  function activeCovers(uint256 _index) external view returns (address);

  function allCovers(uint256 _index) external view returns (address);

  function expiries(uint256 _index) external view returns (uint48);

  function collaterals(uint256 _index) external view returns (address);

  function riskList(uint256 _index) external view returns (bytes32);

  function deletedRiskList(uint256 _index) external view returns (bytes32);

  function riskMap(bytes32 _risk) external view returns (Status);

  function collateralStatusMap(address _collateral) external view returns (uint256 _mintRatio, Status _status);

  function expiryInfoMap(uint48 _expiry) external view returns (string memory _name, Status _status);

  function coverMap(address _collateral, uint48 _expiry) external view returns (address);


  function getRiskList() external view returns (bytes32[] memory _riskList);

  function getClaimDetails(uint256 _claimNonce) external view returns (ClaimDetails memory);

  function getCoverPoolDetails()
    external view returns (
      address[] memory _collaterals,
      uint48[] memory _expiries,
      bytes32[] memory _riskList,
      bytes32[] memory _deletedRiskList,
      address[] memory _allCovers
    );


  function addCover(
    address _collateral,
    uint48 _expiry,
    address _receiver,
    uint256 _colAmountIn,
    uint256 _amountOut,
    bytes calldata _data
  ) external;

  function deployCover(address _collateral, uint48 _expiry) external returns (address _coverAddress);


  function enactClaim(
    bytes32[] calldata _payoutRiskList,
    uint256[] calldata _payoutRates,
    uint48 _incidentTimestamp,
    uint256 _coverPoolNonce
  ) external;


  function setNoclaimRedeemDelay(uint256 _noclaimRedeemDelay) external;


  function addRisk(string calldata _risk) external returns (bool);

  function deleteRisk(string calldata _risk) external;

  function setExpiry(uint48 _expiry, string calldata _expiryName, Status _status) external;

  function setCollateral(address _collateral, uint256 _mintRatio, Status _status) external;

  function setPoolStatus(Status _poolStatus) external;

}// No License

pragma solidity ^0.8.0;

interface ICoverPoolCallee {

  function onFlashMint(
    address _sender,
    address _paymentToken,
    uint256 _paymentAmount,
    uint256 _amountOut,
    bytes calldata _data
  ) external returns (bytes32);

}// No License

pragma solidity ^0.8.0;

interface ICoverPoolFactory {

  event CoverPoolCreated(address indexed _addr);
  event IntUpdated(string _type, uint256 _old, uint256 _new);
  event AddressUpdated(string _type, address indexed _old, address indexed _new);
  event PausedStatusUpdated(bool _old, bool _new);

  function MAX_REDEEM_DELAY() external view returns (uint256);

  function defaultRedeemDelay() external view returns (uint256);

  function yearlyFeeRate() external view returns (uint256);

  function paused() external view returns (bool);

  function responder() external view returns (address);

  function coverPoolImpl() external view returns (address);

  function coverImpl() external view returns (address);

  function coverERC20Impl() external view returns (address);

  function treasury() external view returns (address);

  function claimManager() external view returns (address);

  function deployGasMin() external view returns (uint256);

  function coverPoolNames(uint256 _index) external view returns (string memory);

  function coverPools(string calldata _coverPoolName) external view returns (address);


  function getCoverPools() external view returns (address[] memory);

  function getCoverPoolAddress(string calldata _name) external view returns (address);

  function getCoverAddress(string calldata _coverPoolName, uint48 _timestamp, address _collateral, uint256 _claimNonce) external view returns (address);

  function getCovTokenAddress(string calldata _coverPoolName, uint48 _expiry, address _collateral, uint256 _claimNonce, string memory _prefix) external view returns (address);


  function setPaused(bool _paused) external;


  function setYearlyFeeRate(uint256 _yearlyFeeRate) external;

  function setDefaultRedeemDelay(uint256 _defaultRedeemDelay) external;

  function setResponder(address _responder) external;

  function setDeployGasMin(uint256 _deployGasMin) external;

  function setCoverPoolImpl(address _newImpl) external;

  function setCoverImpl(address _newImpl) external;

  function setCoverERC20Impl(address _newImpl) external;

  function setTreasury(address _address) external;

  function setClaimManager(address _address) external;

  function createCoverPool(
    string calldata _name,
    bool _extendablePool,
    string[] calldata _riskList,
    address _collateral,
    uint256 _mintRatio,
    uint48 _expiry,
    string calldata _expiryString
  ) external returns (address);

}// No License

pragma solidity ^0.8.0;


contract CoverPool is ICoverPool, Initializable, ReentrancyGuard, Ownable {

  using SafeERC20 for IERC20;

  bytes4 private constant COVER_INIT_SIGNITURE = bytes4(keccak256("initialize(string,uint48,address,uint256,uint256)"));
  bytes32 public constant CALLBACK_SUCCESS = keccak256("ICoverPoolCallee.onFlashMint");

  string public override name;
  bool public override extendablePool;
  Status public override poolStatus; // only Active coverPool status can addCover (aka. minting more covTokens)
  bool public override addingRiskWIP;
  uint256 public override addingRiskIndex; // index of the active cover array to continue adding risk
  uint256 public override claimNonce; // nonce of for the coverPool's accepted claims
  uint256 public override noclaimRedeemDelay; // delay for redeem with only noclaim tokens for expired cover with no accpeted claim

  ClaimDetails[] private claimDetails; // [claimNonce] => accepted ClaimDetails
  address[] public override activeCovers; // reset once claim accepted, may contain expired covers, used mostly for adding new risk to pool for faster deployment
  address[] public override allCovers; // all covers ever created
  uint48[] public override expiries; // all expiries ever added
  address[] public override collaterals; // all collaterals ever added
  bytes32[] public override riskList; // list of active risks in cover pool
  bytes32[] public override deletedRiskList;
  mapping(bytes32 => Status) public override riskMap;
  mapping(address => CollateralInfo) public override collateralStatusMap;
  mapping(uint48 => ExpiryInfo) public override expiryInfoMap;
  mapping(address => mapping(uint48 => address)) public override coverMap;

  modifier onlyDev() {

    require(msg.sender == _dev(), "CP: caller not dev");
    _;
  }

  modifier onlyNotAddingRiskWIP() {

    require(!addingRiskWIP, "CP: adding risk WIP");
    _;
  }

  function initialize (
    string calldata _coverPoolName,
    bool _extendablePool,
    string[] calldata _riskList,
    address _collateral,
    uint256 _mintRatio,
    uint48 _expiry,
    string calldata _expiryString
  ) external initializer {
    require(_collateral != address(0), "CP: collateral cannot be 0");
    initializeOwner();
    name = _coverPoolName;
    extendablePool = _extendablePool;
    _setCollateral(_collateral, _mintRatio, Status.Active);
    _setExpiry(_expiry, _expiryString, Status.Active);

    for (uint256 j = 0; j < _riskList.length; j++) {
      bytes32 risk = StringHelper.stringToBytes32(_riskList[j]);
      require(riskMap[risk] == Status.Null, "CP: duplicated risks");
      riskList.push(risk);
      riskMap[risk] = Status.Active;
      emit RiskUpdated(risk, true);
    }

    noclaimRedeemDelay = _factory().defaultRedeemDelay(); // Claim manager can set it 10 days when claim filed
    emit NoclaimRedeemDelayUpdated(0, noclaimRedeemDelay);
    poolStatus = Status.Active;
    deployCover(_collateral, _expiry);
  }

  function addCover(
    address _collateral,
    uint48 _expiry,
    address _receiver,
    uint256 _colAmountIn,
    uint256 _amountOut,
    bytes calldata _data
  ) external override nonReentrant onlyNotAddingRiskWIP
  {

    require(!_factory().paused(), "CP: paused");
    require(poolStatus == Status.Active, "CP: pool not active");
    require(_colAmountIn > 0, "CP: amount <= 0");
    require(collateralStatusMap[_collateral].status == Status.Active, "CP: invalid collateral");
    require(block.timestamp < _expiry && expiryInfoMap[_expiry].status == Status.Active, "CP: invalid expiry");
    address coverAddr = coverMap[_collateral][_expiry];
    require(coverAddr != address(0), "CP: cover not deployed yet");
    ICover cover = ICover(coverAddr);

    cover.mint(_amountOut, _receiver);
    if (_data.length > 0) {
      require(
        ICoverPoolCallee(_receiver).onFlashMint(msg.sender, _collateral, _colAmountIn, _amountOut, _data) == CALLBACK_SUCCESS,
        "CP: Callback failed"
      );
    }

    IERC20 collateral = IERC20(_collateral);
    uint256 coverBalanceBefore = collateral.balanceOf(coverAddr);
    collateral.safeTransferFrom(_receiver, coverAddr, _colAmountIn);
    uint256 received = collateral.balanceOf(coverAddr) - coverBalanceBefore;
    require(received >= _amountOut, "CP: collateral transfer failed");

    emit CoverAdded(coverAddr, _receiver, _amountOut);
  }

  function addRisk(string calldata _risk) external override onlyDev returns (bool) {

    require(extendablePool, "CP: not extendable pool");
    bytes32 risk = StringHelper.stringToBytes32(_risk);
    require(riskMap[risk] != Status.Disabled, "CP: deleted risk not allowed");

    if (riskMap[risk] == Status.Null) {
      require(!addingRiskWIP, "CP: adding risk WIP");
      addingRiskWIP = true;
      riskMap[risk] = Status.Active;
      riskList.push(risk);
    }

    address[] memory activeCoversCopy = activeCovers;

    uint256 startGas = gasleft();
    for (uint256 i = addingRiskIndex; i < activeCoversCopy.length; i++) {
      addingRiskIndex = i;
      if (startGas < _factory().deployGasMin()) return false;
      ICover(activeCoversCopy[i]).addRisk(risk);
      startGas = gasleft();
    }

    addingRiskWIP = false;
    addingRiskIndex = 0;
    emit RiskUpdated(risk, true);
    return true;
  }

  function deleteRisk(string calldata _risk) external override onlyDev onlyNotAddingRiskWIP {

    bytes32 risk = StringHelper.stringToBytes32(_risk);
    require(riskMap[risk] == Status.Active, "CP: not active risk");
    bytes32[] memory riskListCopy = riskList; // save gas
    uint256 len = riskListCopy.length;
    require(len > 1, "CP: only 1 risk left");
    IClaimManagement claimManager = IClaimManagement(_factory().claimManager());
    require(!claimManager.hasPendingClaim(address(this), claimNonce), "CP: pending claim");


    for (uint256 i = 0; i < len; i++) {
      if (risk == riskListCopy[i]) {
        riskMap[risk] = Status.Disabled;
        deletedRiskList.push(risk);
        riskList[i] = riskListCopy[len - 1];
        riskList.pop();
        emit RiskUpdated(risk, false);
        break;
      }
    }
  }

  function setExpiry(uint48 _expiry, string calldata _expiryStr, Status _status) public override onlyDev {

    _setExpiry(_expiry, _expiryStr, _status);
  }

  function setCollateral(address _collateral, uint256 _mintRatio, Status _status) public override onlyDev {

    _setCollateral(_collateral, _mintRatio, _status);
  }

  function setPoolStatus(Status _poolStatus) external override onlyDev {

    emit PoolStatusUpdated(poolStatus, _poolStatus);
    poolStatus = _poolStatus;
  }

  function setNoclaimRedeemDelay(uint256 _noclaimRedeemDelay) external override {

    ICoverPoolFactory factory = _factory();
    require(msg.sender == _dev() || msg.sender == factory.claimManager(), "CP: caller not gov/claimManager");
    require(_noclaimRedeemDelay >= factory.defaultRedeemDelay(), "CP: < default delay");
    require(_noclaimRedeemDelay <= factory.MAX_REDEEM_DELAY(), "CP: > max delay");
    if (_noclaimRedeemDelay != noclaimRedeemDelay) {
      emit NoclaimRedeemDelayUpdated(noclaimRedeemDelay, _noclaimRedeemDelay);
      noclaimRedeemDelay = _noclaimRedeemDelay;
    }
  }

  function enactClaim(
    bytes32[] calldata _payoutRiskList,
    uint256[] calldata _payoutRates,
    uint48 _incidentTimestamp,
    uint256 _coverPoolNonce
  ) external override {

    require(msg.sender == _factory().claimManager(), "CP: caller not claimManager");
    require(_coverPoolNonce == claimNonce, "CP: nonces do not match");
    require(_payoutRiskList.length == _payoutRates.length, "CP: arrays length don't match");

    uint256 totalPayoutRate;
    for (uint256 i = 0; i < _payoutRiskList.length; i++) {
      require(riskMap[_payoutRiskList[i]] == Status.Active, "CP: has disabled risk");
      totalPayoutRate = totalPayoutRate + _payoutRates[i];
    }
    require(totalPayoutRate <= 1 ether && totalPayoutRate > 0, "CP: payout % not in (0%, 100%]");

    claimNonce = claimNonce + 1;
    delete activeCovers;
    claimDetails.push(ClaimDetails(
      _incidentTimestamp,
      uint48(block.timestamp),
      totalPayoutRate,
      _payoutRiskList,
      _payoutRates
    ));
    emit ClaimEnacted(_coverPoolNonce);
  }

  function getCoverPoolDetails() external view override
    returns (
      address[] memory _collaterals,
      uint48[] memory _expiries,
      bytes32[] memory _riskList,
      bytes32[] memory _deletedRiskList,
      address[] memory _allCovers)
  {

    return (collaterals, expiries, riskList, deletedRiskList, allCovers);
  }

  function getRiskList() external view override returns (bytes32[] memory) {

    return riskList;
  }

  function getClaimDetails(uint256 _nonce) external view override returns (ClaimDetails memory) {

    return claimDetails[_nonce];
  }

  function deployCover(address _collateral, uint48 _expiry) public override returns (address addr) {

    addr = coverMap[_collateral][_expiry];

    if (addr == address(0) || ICover(addr).claimNonce() < claimNonce) {
      require(collateralStatusMap[_collateral].status == Status.Active, "CP: invalid collateral");
      require(block.timestamp < _expiry && expiryInfoMap[_expiry].status == Status.Active, "CP: invalid expiry");

      string memory coverName = _getCoverName(_expiry, IERC20(_collateral).symbol());
      bytes memory bytecode = type(InitializableAdminUpgradeabilityProxy).creationCode;
      bytes32 salt = keccak256(abi.encodePacked(name, _expiry, _collateral, claimNonce));
      addr = Create2.deploy(0, salt, bytecode);
      bytes memory initData = abi.encodeWithSelector(COVER_INIT_SIGNITURE, coverName, _expiry, _collateral, collateralStatusMap[_collateral].mintRatio, claimNonce);
      address coverImpl = _factory().coverImpl();
      InitializableAdminUpgradeabilityProxy(payable(addr)).initialize(
        coverImpl,
        IOwnable(owner()).owner(),
        initData
      );
      activeCovers.push(addr);
      allCovers.push(addr);
      coverMap[_collateral][_expiry] = addr;
      emit CoverCreated(addr);
    } else if (!ICover(addr).deployComplete()) {
      ICover(addr).deploy();
    }
  }

  function _factory() private view returns (ICoverPoolFactory) {

    return ICoverPoolFactory(owner());
  }

  function _dev() private view returns (address) {

    return IOwnable(owner()).owner();
  }

  function _setExpiry(uint48 _expiry, string calldata _expiryStr, Status _status) private {

    require(block.timestamp < _expiry, "CP: expiry in the past");
    require(_status != Status.Null, "CP: status is null");

    if (expiryInfoMap[_expiry].status == Status.Null) {
      expiries.push(_expiry);
    }
    expiryInfoMap[_expiry] = ExpiryInfo(_expiryStr, _status);
    emit ExpiryUpdated(_expiry, _expiryStr, _status);
  }

  function _setCollateral(address _collateral, uint256 _mintRatio, Status _status) private {

    require(_collateral != address(0), "CP: address cannot be 0");
    require(_status != Status.Null, "CP: status is null");

    if (collateralStatusMap[_collateral].status == Status.Null) {
      collaterals.push(_collateral);
    }
    collateralStatusMap[_collateral] = CollateralInfo(_mintRatio, _status);
    emit CollateralUpdated(_collateral, _mintRatio,  _status);
  }

  function _getCoverName(uint48 _expiry, string memory _collateralSymbol)
   private view returns (string memory)
  {

    require(bytes(_collateralSymbol).length > 0, "CP: empty collateral symbol");
    return string(abi.encodePacked(
      name, "_",
      StringHelper.uintToString(claimNonce), "_",
      _collateralSymbol, "_",
      expiryInfoMap[_expiry].name
    ));
  }
}