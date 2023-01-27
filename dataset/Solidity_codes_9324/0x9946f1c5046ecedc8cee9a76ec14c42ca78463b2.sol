
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

interface IOwnable {

    function owner() external view returns (address);

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

}// MIT

pragma solidity ^0.8.0;


interface IClaimConfig {

  function treasury() external view returns (address);

  function coverPoolFactory() external view returns (ICoverPoolFactory);

  function defaultCVC() external view returns (address);

  function maxClaimDecisionWindow() external view returns (uint256);

  function baseClaimFee() external view returns (uint256);

  function forceClaimFee() external view returns (uint256);

  function feeMultiplier() external view returns (uint256);

  function feeCurrency() external view returns (IERC20);

  function cvcMap(address _coverPool, uint256 _idx) external view returns (address);

  function getCVCList(address _coverPool) external returns (address[] memory);

  function isCVCMember(address _coverPool, address _address) external view returns (bool);

  function getCoverPoolClaimFee(address _coverPool) external view returns (uint256);

  
  function setMaxClaimDecisionWindow(uint256 _newTimeWindow) external;

  function setTreasury(address _treasury) external;

  function addCVCForPools(address[] calldata _coverPools, address[] calldata _cvcs) external;

  function removeCVCForPools(address[] calldata _coverPools, address[] calldata _cvcs) external;

  function setDefaultCVC(address _cvc) external;

  function setFeeAndCurrency(uint256 _baseClaimFee, uint256 _forceClaimFee, address _currency) external;

  function setFeeMultiplier(uint256 _multiplier) external;

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

}// MIT
pragma solidity ^0.8.0;


contract ClaimConfig is IClaimConfig, Ownable {


  IERC20 public override feeCurrency;
  address public override treasury;
  ICoverPoolFactory public override coverPoolFactory;
  address public override defaultCVC; // if not specified, default to this

  uint256 internal constant TIME_BUFFER = 1 hours;
  uint256 public override maxClaimDecisionWindow = 7 days - TIME_BUFFER;
  uint256 public override baseClaimFee = 50e18;
  uint256 public override forceClaimFee = 500e18;
  uint256 public override feeMultiplier = 2;

  mapping(address => uint256) private coverPoolClaimFee;
  mapping(address => address[]) public override cvcMap;

  function setTreasury(address _treasury) external override onlyOwner {

    require(_treasury != address(0), "CC: treasury cannot be 0");
    treasury = _treasury;
  }

  function setMaxClaimDecisionWindow(uint256 _newTimeWindow) external override onlyOwner {

    require(_newTimeWindow > 0, "CC: window too short");
    maxClaimDecisionWindow = _newTimeWindow;
  }

  function setDefaultCVC(address _cvc) external override onlyOwner {

    require(_cvc != address(0), "CC: default CVC cannot be 0");
    defaultCVC = _cvc;
  }

  function addCVCForPools(address[] calldata _coverPools, address[] calldata _cvcs) external override onlyOwner {

    require(_coverPools.length == _cvcs.length, "CC: lengths don't match");
    for (uint256 i = 0; i < _coverPools.length; i++) {
      _addCVCForPool(_coverPools[i], _cvcs[i]);
    }
  }

  function removeCVCForPools(address[] calldata _coverPools, address[] calldata _cvcs) external override onlyOwner {

    require(_coverPools.length == _cvcs.length, "CC: lengths don't match");
    for (uint256 i = 0; i < _coverPools.length; i++) {
      _removeCVCForPool(_coverPools[i], _cvcs[i]);
    }
  }

  function setFeeAndCurrency(uint256 _baseClaimFee, uint256 _forceClaimFee, address _currency) external override onlyOwner {

    require(_currency != address(0), "CC: feeCurrency cannot be 0");
    require(_baseClaimFee > 0, "CC: baseClaimFee <= 0");
    require(_forceClaimFee > _baseClaimFee, "CC: force Fee <= base Fee");
    baseClaimFee = _baseClaimFee;
    forceClaimFee = _forceClaimFee;
    feeCurrency = IERC20(_currency);
  }

  function setFeeMultiplier(uint256 _multiplier) external override onlyOwner {

    require(_multiplier >= 1, "CC: multiplier must be >= 1");
    feeMultiplier = _multiplier;
  }

  function getCVCList(address _coverPool) external view override returns (address[] memory) {	

    return cvcMap[_coverPool];	
  }

  function isCVCMember(address _coverPool, address _address) public view override returns (bool) {

    address[] memory cvcCopy = cvcMap[_coverPool];
    if (cvcCopy.length == 0 && _address == defaultCVC) return true;
    for (uint256 i = 0; i < cvcCopy.length; i++) {
      if (_address == cvcCopy[i]) {
        return true;
      }
    }
    return false;
  }

  function getCoverPoolClaimFee(address _coverPool) public view override returns (uint256) {

    return coverPoolClaimFee[_coverPool] < baseClaimFee ? baseClaimFee : coverPoolClaimFee[_coverPool];
  }

  function _addCVCForPool(address _coverPool, address _cvc) private onlyOwner {

    address[] memory cvcCopy = cvcMap[_coverPool];
    for (uint256 i = 0; i < cvcCopy.length; i++) {
      require(cvcCopy[i] != _cvc, "CC: cvc exists");
    }
    cvcMap[_coverPool].push(_cvc);
  }

  function _removeCVCForPool(address _coverPool, address _cvc) private {

    address[] memory cvcCopy = cvcMap[_coverPool];
    uint256 len = cvcCopy.length;
    if (len < 1) return; // nothing to remove, no need to revert
    for (uint256 i = 0; i < len; i++) {
      if (_cvc == cvcCopy[i]) {
        cvcMap[_coverPool][i] = cvcCopy[len - 1];
        cvcMap[_coverPool].pop();
        break;
      }
    }
  }

  function _updateCoverPoolClaimFee(address _coverPool) internal {

    uint256 newFee = getCoverPoolClaimFee(_coverPool) * feeMultiplier;
    if (newFee <= forceClaimFee) {
      coverPoolClaimFee[_coverPool] = newFee;
    }
  }

  function _resetCoverPoolClaimFee(address _coverPool) internal {

    coverPoolClaimFee[_coverPool] = baseClaimFee;
  }
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

 }// MIT
pragma solidity ^0.8.0;


contract ClaimManagement is IClaimManagement, ClaimConfig {

  using SafeERC20 for IERC20;

  uint256 public constant PENDING_CLAIM_REDEEM_DELAY = 10 days;
  mapping(address => mapping(uint256 => Claim[])) private coverPoolClaims;

  constructor(
    address _feeCurrency,
    address _treasury,
    address _coverPoolFactory,
    address _defaultCVC
  ) {
    require(_feeCurrency != address(0), "CM: fee cannot be 0");
    require(_treasury != address(0), "CM: treasury cannot be 0");
    require(_coverPoolFactory != address(0), "CM: factory cannot be 0");
    require(_defaultCVC != address(0), "CM: defaultCVC cannot be 0");
    feeCurrency = IERC20(_feeCurrency);
    treasury = _treasury;
    coverPoolFactory = ICoverPoolFactory(_coverPoolFactory);
    defaultCVC = _defaultCVC;

    initializeOwner();
  }

  function fileClaim(
    string calldata _coverPoolName,
    bytes32[] calldata _exploitRisks,
    uint48 _incidentTimestamp,
    string calldata _description,
    bool isForceFile
  ) external override {

    address coverPool = _getCoverPoolAddr(_coverPoolName);
    require(coverPool != address(0), "CM: pool not found");
    require(block.timestamp - _incidentTimestamp <= coverPoolFactory.defaultRedeemDelay() - TIME_BUFFER, "CM: time passed window");

    ICoverPool(coverPool).setNoclaimRedeemDelay(PENDING_CLAIM_REDEEM_DELAY);
    uint256 nonce = _getCoverPoolNonce(coverPool);
    uint256 claimFee = isForceFile ? forceClaimFee : getCoverPoolClaimFee(coverPool);
    feeCurrency.safeTransferFrom(msg.sender, address(this), claimFee);
    _updateCoverPoolClaimFee(coverPool);
    ClaimState state = isForceFile ? ClaimState.ForceFiled : ClaimState.Filed;
    coverPoolClaims[coverPool][nonce].push(Claim({
      filedBy: msg.sender,
      decidedBy: address(0),
      filedTimestamp: uint48(block.timestamp),
      incidentTimestamp: _incidentTimestamp,
      decidedTimestamp: 0,
      description: _description,
      state: state,
      feePaid: claimFee,
      payoutRiskList: _exploitRisks,
      payoutRates: new uint256[](_exploitRisks.length)
    }));
    emit ClaimUpdate(coverPool, state, nonce, coverPoolClaims[coverPool][nonce].length - 1);
  }

  function validateClaim(
    address _coverPool,
    uint256 _nonce,
    uint256 _index,
    bool _claimIsValid
  ) external override onlyOwner {

    Claim storage claim = coverPoolClaims[_coverPool][_nonce][_index];
    require(_index < coverPoolClaims[_coverPool][_nonce].length, "CM: bad index");
    require(_nonce == _getCoverPoolNonce(_coverPool), "CM: wrong nonce");
    require(claim.state == ClaimState.Filed, "CM: claim not filed");
    if (_claimIsValid) {
      claim.state = ClaimState.Validated;
      _resetCoverPoolClaimFee(_coverPool);
    } else {
      claim.state = ClaimState.Invalidated;
      claim.decidedTimestamp = uint48(block.timestamp);
      feeCurrency.safeTransfer(treasury, claim.feePaid);
      _resetNoclaimRedeemDelay(_coverPool, _nonce);
    }
    emit ClaimUpdate({
      coverPool: _coverPool,
      state: claim.state,
      nonce: _nonce,
      index: _index
    });
  }

  function decideClaim(
    address _coverPool,
    uint256 _nonce,
    uint256 _index,
    uint48 _incidentTimestamp,
    bool _claimIsAccepted,
    bytes32[] calldata _exploitRisks,
    uint256[] calldata _payoutRates
  ) external override {

    require(_exploitRisks.length == _payoutRates.length, "CM: arrays len don't match");
    require(isCVCMember(_coverPool, msg.sender), "CM: !cvc");
    require(_nonce == _getCoverPoolNonce(_coverPool), "CM: wrong nonce");
    Claim storage claim = coverPoolClaims[_coverPool][_nonce][_index];
    require(claim.state == ClaimState.Validated || claim.state == ClaimState.ForceFiled, "CM: ! validated or forceFiled");
    if (_incidentTimestamp != 0) {
      require(claim.filedTimestamp - _incidentTimestamp <= coverPoolFactory.defaultRedeemDelay() - TIME_BUFFER, "CM: time passed window");
      claim.incidentTimestamp = _incidentTimestamp;
    }

    uint256 totalRates = _getTotalNum(_payoutRates);
    if (_claimIsAccepted && !_isDecisionWindowPassed(claim)) {
      require(totalRates > 0 && totalRates <= 1 ether, "CM: payout % not in (0%, 100%]");
      feeCurrency.safeTransfer(claim.filedBy, claim.feePaid);
      _resetCoverPoolClaimFee(_coverPool);
      claim.state = ClaimState.Accepted;
      claim.payoutRiskList = _exploitRisks;
      claim.payoutRates = _payoutRates;
      ICoverPool(_coverPool).enactClaim(claim.payoutRiskList, claim.payoutRates, claim.incidentTimestamp, _nonce);
    } else { // Max decision claim window passed, claim is default to Denied
      require(totalRates == 0, "CM: claim denied (default if passed window), but payoutNumerator != 0");
      feeCurrency.safeTransfer(treasury, claim.feePaid);
      claim.state = ClaimState.Denied;
    }
    _resetNoclaimRedeemDelay(_coverPool, _nonce);
    claim.decidedBy = msg.sender;
    claim.decidedTimestamp = uint48(block.timestamp);
    emit ClaimUpdate(_coverPool, claim.state, _nonce, _index);
  }

  function getCoverPoolClaims(address _coverPool, uint256 _nonce, uint256 _index) external view override returns (Claim memory) {

    return coverPoolClaims[_coverPool][_nonce][_index];
  }

  function getAllClaimsByState(address _coverPool, uint256 _nonce, ClaimState _state)
    external view override returns (Claim[] memory)
  {

    Claim[] memory allClaims = coverPoolClaims[_coverPool][_nonce];
    uint256 count;
    Claim[] memory temp = new Claim[](allClaims.length);
    for (uint i = 0; i < allClaims.length; i++) {
      if (allClaims[i].state == _state) {
        temp[count] = allClaims[i];
        count++;
      }
    }
    Claim[] memory claimsByState = new Claim[](count);
    for (uint i = 0; i < count; i++) {
      claimsByState[i] = temp[i];
    }
    return claimsByState;
  }

  function getAllClaimsByNonce(address _coverPool, uint256 _nonce) external view override returns (Claim[] memory) {

    return coverPoolClaims[_coverPool][_nonce];
  }

  function hasPendingClaim(address _coverPool, uint256 _nonce) public view override returns (bool) {

    Claim[] memory allClaims = coverPoolClaims[_coverPool][_nonce];
    for (uint i = 0; i < allClaims.length; i++) {
      ClaimState state = allClaims[i].state;
      if (state == ClaimState.Filed || state == ClaimState.ForceFiled || state == ClaimState.Validated) {
        return true;
      }
    }
    return false;
  }

  function _resetNoclaimRedeemDelay(address _coverPool, uint256 _nonce) private {

    if (hasPendingClaim(_coverPool, _nonce)) return;
    uint256 defaultRedeemDelay = coverPoolFactory.defaultRedeemDelay();
    ICoverPool(_coverPool).setNoclaimRedeemDelay(defaultRedeemDelay);
  }

  function _getCoverPoolAddr(string calldata _coverPoolName) private view returns (address) {

    return coverPoolFactory.coverPools(_coverPoolName);
  }

  function _getCoverPoolNonce(address _coverPool) private view returns (uint256) {

    return ICoverPool(_coverPool).claimNonce();
  }

  function _isDecisionWindowPassed(Claim memory claim) private view returns (bool) {

    return block.timestamp - claim.filedTimestamp > maxClaimDecisionWindow;
  }

  function _getTotalNum(uint256[] calldata _payoutRates) private pure returns (uint256 _totalRates) {

    for (uint256 i = 0; i < _payoutRates.length; i++) {
      _totalRates = _totalRates + _payoutRates[i];
    }
  }
}