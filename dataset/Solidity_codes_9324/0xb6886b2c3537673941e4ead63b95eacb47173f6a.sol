
pragma solidity ^0.7.3;

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
}// MIT

pragma solidity ^0.7.3;

interface IOwnable {

    function owner() external view returns (address);

}// MIT

pragma solidity >=0.4.24 <0.8.0;


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

pragma solidity ^0.7.3;


contract Ownable is Initializable {

    address private _owner;
    address private _newOwner;

    event OwnershipTransferInitiated(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferCompleted(address indexed previousOwner, address indexed newOwner);

    function initializeOwner() internal initializer {

        _owner = msg.sender;
        emit OwnershipTransferCompleted(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferInitiated(_owner, newOwner);
        _newOwner = newOwner;
    }

    function claimOwnership() public virtual {

        require(_newOwner == msg.sender, "Ownable: caller is not the owner");
        emit OwnershipTransferCompleted(_owner, _newOwner);
        _owner = _newOwner;
    }
}// No License

pragma solidity ^0.7.3;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function symbol() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

}// MIT

pragma solidity ^0.7.3;


interface IClaimConfig {

    function allowPartialClaim() external view returns (bool);

    function auditor() external view returns (address);

    function governance() external view returns (address);

    function treasury() external view returns (address);

    function protocolFactory() external view returns (address);

    function maxClaimDecisionWindow() external view returns (uint256);

    function baseClaimFee() external view returns (uint256);

    function forceClaimFee() external view returns (uint256);

    function feeMultiplier() external view returns (uint256);

    function feeCurrency() external view returns (IERC20);

    function getFileClaimWindow(address _protocol) external view returns (uint256);

    function isAuditorVoting() external view returns (bool);

    function getProtocolClaimFee(address _protocol) external view returns (uint256);

    
    function setMaxClaimDecisionWindow(uint256 _newTimeWindow) external;

    function setTreasury(address _treasury) external;

    function setAuditor(address _auditor) external;

    function setPartialClaimStatus(bool _allowPartialClaim) external;


    function setGovernance(address _governance) external;

    function setFeeAndCurrency(uint256 _baseClaimFee, uint256 _forceClaimFee, address _currency) external;

    function setFeeMultiplier(uint256 _multiplier) external;

}// No License

pragma solidity ^0.7.3;

interface IProtocol {

  event ClaimAccepted(uint256 newClaimNonce);

  function getProtocolDetails()
    external view returns (
      bytes32 _name,
      bool _active,
      uint256 _claimNonce,
      uint256 _claimRedeemDelay,
      uint256 _noclaimRedeemDelay,
      address[] memory _collaterals,
      uint48[] memory _expirationTimestamps,
      address[] memory _allCovers,
      address[] memory _allActiveCovers
    );

  function active() external view returns (bool);

  function name() external view returns (bytes32);

  function claimNonce() external view returns (uint256);

  function claimRedeemDelay() external view returns (uint256);

  function noclaimRedeemDelay() external view returns (uint256);

  function activeCovers(uint256 _index) external view returns (address);

  function claimDetails(uint256 _claimNonce) external view returns (uint16 _payoutNumerator, uint16 _payoutDenominator, uint48 _incidentTimestamp, uint48 _timestamp);

  function collateralStatusMap(address _collateral) external view returns (uint8 _status);

  function expirationTimestampMap(uint48 _expirationTimestamp) external view returns (bytes32 _name, uint8 _status);

  function coverMap(address _collateral, uint48 _expirationTimestamp) external view returns (address);


  function collaterals(uint256 _index) external view returns (address);

  function collateralsLength() external view returns (uint256);

  function expirationTimestamps(uint256 _index) external view returns (uint48);

  function expirationTimestampsLength() external view returns (uint256);

  function activeCoversLength() external view returns (uint256);

  function claimsLength() external view returns (uint256);

  function addCover(address _collateral, uint48 _timestamp, uint256 _amount)
    external returns (bool);


  function enactClaim(uint16 _payoutNumerator, uint16 _payoutDenominator, uint48 _incidentTimestamp, uint256 _protocolNonce) external returns (bool);


  function setActive(bool _active) external returns (bool);

  function updateExpirationTimestamp(uint48 _expirationTimestamp, bytes32 _expirationTimestampName, uint8 _status) external returns (bool);

  function updateCollateral(address _collateral, uint8 _status) external returns (bool);


  function updateClaimRedeemDelay(uint256 _claimRedeemDelay) external returns (bool);

  function updateNoclaimRedeemDelay(uint256 _noclaimRedeemDelay) external returns (bool);

}// MIT
pragma solidity ^0.7.3;


contract ClaimConfig is IClaimConfig, Ownable {

    using SafeMath for uint256;
    
    bool public override allowPartialClaim = true;

    address public override auditor;
    address public override governance;
    address public override treasury;
    address public override protocolFactory;
    
    uint256 public override maxClaimDecisionWindow = 7 days;
    uint256 public override baseClaimFee = 10e18;
    uint256 public override forceClaimFee = 500e18;
    uint256 public override feeMultiplier = 2;

    mapping(address => uint256) private protocolClaimFee;

    IERC20 public override feeCurrency = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    modifier onlyGovernance() {

        require(msg.sender == governance, "COVER_CC: !governance");
        _;
    }

    function setGovernance(address _governance) external override onlyGovernance {

        require(_governance != address(0), "COVER_CC: governance cannot be 0");
        require(_governance != owner(), "COVER_CC: governance cannot be owner");
        governance = _governance;
    }

    function setTreasury(address _treasury) external override onlyOwner {

        require(_treasury != address(0), "COVER_CC: treasury cannot be 0");
        treasury = _treasury;
    }

    function setMaxClaimDecisionWindow(uint256 _newTimeWindow) external override onlyOwner {

        require(_newTimeWindow < 3 days, "COVER_CC: window too short");
        maxClaimDecisionWindow = _newTimeWindow;
    }

    function setAuditor(address _auditor) external override onlyOwner {

        auditor = _auditor;
    }

    function setPartialClaimStatus(bool _allowPartialClaim) external override onlyOwner {

        allowPartialClaim = _allowPartialClaim;
    }

    function setFeeAndCurrency(uint256 _baseClaimFee, uint256 _forceClaimFee, address _currency)
        external 
        override 
        onlyGovernance 
    {

        require(_baseClaimFee > 0, "COVER_CC: baseClaimFee <= 0");
        require(_forceClaimFee > _baseClaimFee, "COVER_CC: forceClaimFee <= baseClaimFee");
        require(_currency != address(0), "COVER_CC: feeCurrency cannot be 0");
        baseClaimFee = _baseClaimFee;
        forceClaimFee = _forceClaimFee;
        feeCurrency = IERC20(_currency);
    }

    function setFeeMultiplier(uint256 _multiplier) external override onlyGovernance {

        require(_multiplier >= 1, "COVER_CC: multiplier < 1");
        feeMultiplier = _multiplier;
    }

    function isAuditorVoting() public view override returns (bool) {

        return auditor != address(0);
    }

    function getProtocolClaimFee(address _protocol) public view override returns (uint256) {

        return protocolClaimFee[_protocol] == 0 ? baseClaimFee : protocolClaimFee[_protocol];
    }

    function getFileClaimWindow(address _protocol) public view override returns (uint256) {

        uint256 noclaimRedeemDelay = IProtocol(_protocol).noclaimRedeemDelay();
        return noclaimRedeemDelay.sub(maxClaimDecisionWindow).sub(1 hours);
    }

    function _updateProtocolClaimFee(address _protocol) internal {

        uint256 newFee = getProtocolClaimFee(_protocol).mul(feeMultiplier);
        if (newFee <= forceClaimFee) {
            protocolClaimFee[_protocol] = newFee;
        }
    }

    function _resetProtocolClaimFee(address _protocol) internal {

        protocolClaimFee[_protocol] = baseClaimFee;
    }
}// No License

pragma solidity ^0.7.3;

interface IProtocolFactory {

  event ProtocolInitiation(address protocolAddress);

  function getAllProtocolAddresses() external view returns (address[] memory);

  function getRedeemFees() external view returns (uint16 _numerator, uint16 _denominator);

  function redeemFeeNumerator() external view returns (uint16);

  function redeemFeeDenominator() external view returns (uint16);

  function protocolImplementation() external view returns (address);

  function coverImplementation() external view returns (address);

  function coverERC20Implementation() external view returns (address);

  function treasury() external view returns (address);

  function governance() external view returns (address);

  function claimManager() external view returns (address);

  function protocols(bytes32 _protocolName) external view returns (address);


  function getProtocolsLength() external view returns (uint256);

  function getProtocolNameAndAddress(uint256 _index) external view returns (bytes32, address);

  function getProtocolAddress(bytes32 _name) external view returns (address);

  function getCoverAddress(bytes32 _protocolName, uint48 _timestamp, address _collateral, uint256 _claimNonce) external view returns (address);

  function getCovTokenAddress(bytes32 _protocolName, uint48 _timestamp, address _collateral, uint256 _claimNonce, bool _isClaimCovToken) external view returns (address);


  function updateProtocolImplementation(address _newImplementation) external returns (bool);

  function updateCoverImplementation(address _newImplementation) external returns (bool);

  function updateCoverERC20Implementation(address _newImplementation) external returns (bool);

  function addProtocol(
    bytes32 _name,
    bool _active,
    address _collateral,
    uint48[] calldata _timestamps,
    bytes32[] calldata _timestampNames
  ) external returns (address);

  function updateTreasury(address _address) external returns (bool);

  function updateClaimManager(address _address) external returns (bool);


  function updateFees(uint16 _redeemFeeNumerator, uint16 _redeemFeeDenominator) external returns (bool);

  function updateGovernance(address _address) external returns (bool);

}// MIT

pragma solidity ^0.7.3;
pragma experimental ABIEncoderV2;

 interface IClaimManagement {

    enum ClaimState { Filed, ForceFiled, Validated, Invalidated, Accepted, Denied }
    struct Claim {
        ClaimState state; // Current state of claim
        address filedBy; // Address of user who filed claim
        uint16 payoutNumerator; // Numerator of percent to payout
        uint16 payoutDenominator; // Denominator of percent to payout
        uint48 filedTimestamp; // Timestamp of submitted claim
        uint48 incidentTimestamp; // Timestamp of the incident the claim is filed for
        uint48 decidedTimestamp; // Timestamp when claim outcome is decided
        uint256 feePaid; // Fee paid to file the claim
    }

    function protocolClaims(address _protocol, uint256 _nonce, uint256 _index) external view returns (        
        ClaimState state,
        address filedBy,
        uint16 payoutNumerator,
        uint16 payoutDenominator,
        uint48 filedTimestamp,
        uint48 incidentTimestamp,
        uint48 decidedTimestamp,
        uint256 feePaid
    );

    
    function fileClaim(address _protocol, bytes32 _protocolName, uint48 _incidentTimestamp) external;

    function forceFileClaim(address _protocol, bytes32 _protocolName, uint48 _incidentTimestamp) external;

    
    function validateClaim(address _protocol, uint256 _nonce, uint256 _index, bool _claimIsValid) external;


    function decideClaim(address _protocol, uint256 _nonce, uint256 _index, bool _claimIsAccepted, uint16 _payoutNumerator, uint16 _payoutDenominator) external;


    function getAllClaimsByState(address _protocol, uint256 _nonce, ClaimState _state) external view returns (Claim[] memory);

    function getAllClaimsByNonce(address _protocol, uint256 _nonce) external view returns (Claim[] memory);

    function getAddressFromFactory(bytes32 _protocolName) external view returns (address);

    function getProtocolNonce(address _protocol) external view returns (uint256);

    
    event ClaimFiled(
        bool indexed isForced,
        address indexed filedBy, 
        address indexed protocol, 
        uint48 incidentTimestamp,
        uint256 nonce, 
        uint256 index, 
        uint256 feePaid
    );
    event ClaimValidated(
        bool indexed claimIsValid,
        address indexed protocol, 
        uint256 nonce, 
        uint256 index
    );
    event ClaimDecided(
        bool indexed claimIsAccepted,
        address indexed protocol, 
        uint256 nonce, 
        uint256 index, 
        uint16 payoutNumerator, 
        uint16 payoutDenominator
    );
 }// MIT

pragma solidity ^0.7.3;

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

pragma solidity ^0.7.3;


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
}// MIT
pragma solidity ^0.7.3;


contract ClaimManagement is IClaimManagement, ClaimConfig {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    mapping(address => mapping(uint256 => Claim[])) public override protocolClaims;

    modifier onlyApprovedDecider() {

        if (isAuditorVoting()) {
            require(msg.sender == auditor, "COVER_CM: !auditor");
        } else {
            require(msg.sender == governance, "COVER_CM: !governance");
        }
        _;
    }

    modifier onlyWhenAuditorVoting() {

        require(isAuditorVoting(), "COVER_CM: !isAuditorVoting");
        _;
    }

    constructor(address _governance, address _auditor, address _treasury, address _protocolFactory) {
        require(
            _governance != msg.sender && _governance != address(0), 
            "COVER_CC: governance cannot be owner or 0"
        );
        require(_treasury != address(0), "COVER_CM: treasury cannot be 0");
        require(_protocolFactory != address(0), "COVER_CM: protocol factory cannot be 0");
        governance = _governance;
        auditor = _auditor;
        treasury = _treasury;
        protocolFactory = _protocolFactory;

        initializeOwner();
    }

    function fileClaim(address _protocol, bytes32 _protocolName, uint48 _incidentTimestamp) 
        external 
        override 
    {

        require(_protocol != address(0), "COVER_CM: protocol cannot be 0");
        require(
            _protocol == getAddressFromFactory(_protocolName), 
            "COVER_CM: invalid protocol address"
        );
        require(
            block.timestamp.sub(_incidentTimestamp) <= getFileClaimWindow(_protocol),
            "COVER_CM: block.timestamp - incidentTimestamp > fileClaimWindow"
        );
        uint256 nonce = getProtocolNonce(_protocol);
        uint256 claimFee = getProtocolClaimFee(_protocol);
        protocolClaims[_protocol][nonce].push(Claim({
            state: ClaimState.Filed,
            filedBy: msg.sender,
            payoutNumerator: 0,
            payoutDenominator: 1,
            filedTimestamp: uint48(block.timestamp),
            incidentTimestamp: _incidentTimestamp,
            decidedTimestamp: 0,
            feePaid: claimFee
        }));
        feeCurrency.safeTransferFrom(msg.sender, address(this), claimFee);
        _updateProtocolClaimFee(_protocol);
        emit ClaimFiled({
            isForced: false,
            filedBy: msg.sender,
            protocol: _protocol,
            incidentTimestamp: _incidentTimestamp,
            nonce: nonce,
            index: protocolClaims[_protocol][nonce].length - 1,
            feePaid: claimFee
        });
    }

    function forceFileClaim(address _protocol, bytes32 _protocolName, uint48 _incidentTimestamp)
        external 
        override 
        onlyWhenAuditorVoting 
    {

        require(_protocol != address(0), "COVER_CM: protocol cannot be 0");
        require(
            _protocol == getAddressFromFactory(_protocolName), 
            "COVER_CM: invalid protocol address"
        );  
        require(
            block.timestamp.sub(_incidentTimestamp) <= getFileClaimWindow(_protocol),
            "COVER_CM: block.timestamp - incidentTimestamp > fileClaimWindow"
        );
        uint256 nonce = getProtocolNonce(_protocol);
        protocolClaims[_protocol][nonce].push(Claim({
            state: ClaimState.ForceFiled,
            filedBy: msg.sender,
            payoutNumerator: 0,
            payoutDenominator: 1,
            filedTimestamp: uint48(block.timestamp),
            incidentTimestamp: _incidentTimestamp,
            decidedTimestamp: 0,
            feePaid: forceClaimFee
        }));
        feeCurrency.safeTransferFrom(msg.sender, address(this), forceClaimFee);
        emit ClaimFiled({
            isForced: true,
            filedBy: msg.sender,
            protocol: _protocol,
            incidentTimestamp: _incidentTimestamp,
            nonce: nonce,
            index: protocolClaims[_protocol][nonce].length - 1,
            feePaid: forceClaimFee
        });
    }

    function validateClaim(address _protocol, uint256 _nonce, uint256 _index, bool _claimIsValid)
        external 
        override 
        onlyGovernance
        onlyWhenAuditorVoting 
    {

        Claim storage claim = protocolClaims[_protocol][_nonce][_index];
        require(
            _nonce == getProtocolNonce(_protocol), 
            "COVER_CM: input nonce != protocol nonce"
            );
        require(claim.state == ClaimState.Filed, "COVER_CM: claim not filed");
        if (_claimIsValid) {
            claim.state = ClaimState.Validated;
            _resetProtocolClaimFee(_protocol);
        } else {
            claim.state = ClaimState.Invalidated;
            claim.decidedTimestamp = uint48(block.timestamp);
            feeCurrency.safeTransfer(treasury, claim.feePaid);
        }
        emit ClaimValidated({
            claimIsValid: _claimIsValid,
            protocol: _protocol,
            nonce: _nonce,
            index: _index
        });
    }

    function decideClaim(
        address _protocol, 
        uint256 _nonce, 
        uint256 _index, 
        bool _claimIsAccepted, 
        uint16 _payoutNumerator, 
        uint16 _payoutDenominator
    )   
        external
        override 
        onlyApprovedDecider
    {

        require(
            _nonce == getProtocolNonce(_protocol), 
            "COVER_CM: input nonce != protocol nonce"
        );
        Claim storage claim = protocolClaims[_protocol][_nonce][_index];
        if (isAuditorVoting()) {
            require(
                claim.state == ClaimState.Validated || 
                claim.state == ClaimState.ForceFiled, 
                "COVER_CM: claim not validated or forceFiled"
            );
        } else {
            require(claim.state == ClaimState.Filed, "COVER_CM: claim not filed");
        }

        if (_isDecisionWindowPassed(claim)) {
            _claimIsAccepted = false;
        }
        if (_claimIsAccepted) {
            require(_payoutNumerator > 0, "COVER_CM: claim accepted, but payoutNumerator == 0");
            if (allowPartialClaim) {
                require(
                    _payoutNumerator <= _payoutDenominator, 
                    "COVER_CM: payoutNumerator > payoutDenominator"
                );
            } else {
                require(
                    _payoutNumerator == _payoutDenominator, 
                    "COVER_CM: payoutNumerator != payoutDenominator"
                );
            }
            claim.state = ClaimState.Accepted;
            claim.payoutNumerator = _payoutNumerator;
            claim.payoutDenominator = _payoutDenominator;
            feeCurrency.safeTransfer(claim.filedBy, claim.feePaid);
            _resetProtocolClaimFee(_protocol);
            IProtocol(_protocol).enactClaim(_payoutNumerator, _payoutDenominator, claim.incidentTimestamp, _nonce);
        } else {
            require(_payoutNumerator == 0, "COVER_CM: claim denied (default if passed window), but payoutNumerator != 0");
            claim.state = ClaimState.Denied;
            feeCurrency.safeTransfer(treasury, claim.feePaid);
        }
        claim.decidedTimestamp = uint48(block.timestamp);
        emit ClaimDecided({
            claimIsAccepted: _claimIsAccepted, 
            protocol: _protocol, 
            nonce: _nonce, 
            index: _index, 
            payoutNumerator: _payoutNumerator, 
            payoutDenominator: _payoutDenominator
        });
    }

    function getAllClaimsByState(address _protocol, uint256 _nonce, ClaimState _state)
        external 
        view 
        override 
        returns (Claim[] memory) 
    {

        Claim[] memory allClaims = protocolClaims[_protocol][_nonce];
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

    function getAllClaimsByNonce(address _protocol, uint256 _nonce) 
        external 
        view 
        override 
        returns (Claim[] memory) 
    {

        return protocolClaims[_protocol][_nonce];
    }

    function getAddressFromFactory(bytes32 _protocolName) public view override returns (address) {

        return IProtocolFactory(protocolFactory).protocols(_protocolName);
    }

    function getProtocolNonce(address _protocol) public view override returns (uint256) {

        return IProtocol(_protocol).claimNonce();
    }

    function _isDecisionWindowPassed(Claim memory claim) private view returns (bool) {

        return block.timestamp.sub(claim.filedTimestamp) > maxClaimDecisionWindow.sub(1 hours);
    }
}// MIT

pragma solidity ^0.7.3;

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
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () payable external {
        _fallback();
    }

    receive () payable external {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
}// MIT

pragma solidity ^0.7.3;


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

pragma solidity ^0.7.3;


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

  function admin() external ifAdmin returns (address) {

    return _admin();
  }

  function implementation() external ifAdmin returns (address) {

    return _implementation();
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

pragma solidity ^0.7.3;


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

pragma solidity ^0.7.3;

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
        return address(uint256(_data));
    }
}// MIT

pragma solidity ^0.7.0;

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
}// No License

pragma solidity ^0.7.3;


interface ICoverERC20 is IERC20 {

    function burn(uint256 _amount) external returns (bool);


    function mint(address _account, uint256 _amount) external returns (bool);

    function setSymbol(string calldata _symbol) external returns (bool);

    function burnByCover(address _account, uint256 _amount) external returns (bool);

}// No License

pragma solidity ^0.7.3;


interface ICover {

  event NewCoverERC20(address);

  function getCoverDetails()
    external view returns (string memory _name, uint48 _expirationTimestamp, address _collateral, uint256 _claimNonce, ICoverERC20 _claimCovToken, ICoverERC20 _noclaimCovToken);

  function expirationTimestamp() external view returns (uint48);

  function collateral() external view returns (address);

  function claimCovToken() external view returns (ICoverERC20);

  function noclaimCovToken() external view returns (ICoverERC20);

  function name() external view returns (string memory);

  function claimNonce() external view returns (uint256);


  function redeemClaim() external;

  function redeemNoclaim() external;

  function redeemCollateral(uint256 _amount) external;


  function mint(uint256 _amount, address _receiver) external;


  function setCovTokenSymbol(string calldata _name) external;

}// No License

pragma solidity ^0.7.3;


contract Protocol is IProtocol, Initializable, ReentrancyGuard, Ownable {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  struct ClaimDetails {
    uint16 payoutNumerator; // 0 to 65,535
    uint16 payoutDenominator; // 0 to 65,535
    uint48 incidentTimestamp;
    uint48 claimEnactedTimestamp;
  }

  struct ExpirationTimestampInfo {
    bytes32 name;
    uint8 status; // 0 never set; 1 active, 2 inactive
  }

  bytes4 private constant COVER_INIT_SIGNITURE = bytes4(keccak256("initialize(string,uint48,address,uint256)"));

  bool public override active;

  bytes32 public override name;

  uint256 public override claimNonce;

  uint256 public override claimRedeemDelay;
  uint256 public override noclaimRedeemDelay;

  address[] public override activeCovers;
  address[] private allCovers;

  uint48[] public override expirationTimestamps;

  address[] public override collaterals;

  ClaimDetails[] public override claimDetails;

  mapping(address => uint8) public override collateralStatusMap;

  mapping(uint48 => ExpirationTimestampInfo) public override expirationTimestampMap;

  mapping(address => mapping(uint48 => address)) public override coverMap;

  modifier onlyActive() {

    require(active, "COVER: protocol not active");
    _;
  }

  modifier onlyDev() {

    require(msg.sender == _dev(), "COVER: caller not dev");
    _;
  }

  modifier onlyGovernance() {

    require(msg.sender == IProtocolFactory(owner()).governance(), "COVER: caller not governance");
    _;
  }

  function initialize (
    bytes32 _protocolName,
    bool _active,
    address _collateral,
    uint48[] calldata _expirationTimestamps,
    bytes32[] calldata _expirationTimestampNames
  )
    external initializer
  {
    name = _protocolName;
    collaterals.push(_collateral);
    active = _active;
    expirationTimestamps = _expirationTimestamps;

    collateralStatusMap[_collateral] = 1;

    for (uint i = 0; i < _expirationTimestamps.length; i++) {
      if (block.timestamp < _expirationTimestamps[i]) {
        expirationTimestampMap[_expirationTimestamps[i]] = ExpirationTimestampInfo(
          _expirationTimestampNames[i],
          1
        );
      }
    }

    claimRedeemDelay = 2 days;
    noclaimRedeemDelay = 10 days;

    initializeOwner();
  }

  function getProtocolDetails()
    external view override returns (
      bytes32 _name,
      bool _active,
      uint256 _claimNonce,
      uint256 _claimRedeemDelay,
      uint256 _noclaimRedeemDelay,
      address[] memory _collaterals,
      uint48[] memory _expirationTimestamps,
      address[] memory _allCovers,
      address[] memory _allActiveCovers
    )
  {

    return (
      name,
      active,
      claimNonce,
      claimRedeemDelay,
      noclaimRedeemDelay,
      getCollaterals(),
      getExpirationTimestamps(),
      getAllCovers(),
      getAllActiveCovers()
    );
  }

  function collateralsLength() external view override returns (uint256) {

    return collaterals.length;
  }

  function expirationTimestampsLength() external view override returns (uint256) {

    return expirationTimestamps.length;
  }

  function activeCoversLength() external view override returns (uint256) {

    return activeCovers.length;
  }

  function claimsLength() external view override returns (uint256) {

    return claimDetails.length;
  }

  function addCover(address _collateral, uint48 _timestamp, uint256 _amount)
    external override onlyActive nonReentrant returns (bool)
  {

    require(_amount > 0, "COVER: amount <= 0");
    require(collateralStatusMap[_collateral] == 1, "COVER: invalid collateral");
    require(block.timestamp < _timestamp && expirationTimestampMap[_timestamp].status == 1, "COVER: invalid expiration date");

    IERC20 collateral = IERC20(_collateral);
    require(collateral.balanceOf(msg.sender) >= _amount, "COVER: amount > collateral balance");

    address addr = coverMap[_collateral][_timestamp];

    if (addr == address(0) || ICover(addr).claimNonce() != claimNonce) {
      string memory coverName = _generateCoverName(_timestamp, collateral.symbol());

      bytes memory bytecode = type(InitializableAdminUpgradeabilityProxy).creationCode;
      bytes32 salt = keccak256(abi.encodePacked(name, _timestamp, _collateral, claimNonce));
      addr = Create2.deploy(0, salt, bytecode);

      bytes memory initData = abi.encodeWithSelector(COVER_INIT_SIGNITURE, coverName, _timestamp, _collateral, claimNonce);
      address coverImplementation = IProtocolFactory(owner()).coverImplementation();
      InitializableAdminUpgradeabilityProxy(payable(addr)).initialize(
        coverImplementation,
        IOwnable(owner()).owner(),
        initData
      );

      activeCovers.push(addr);
      allCovers.push(addr);
      coverMap[_collateral][_timestamp] = addr;
    }

    uint256 coverBalanceBefore = collateral.balanceOf(addr);
    collateral.safeTransferFrom(msg.sender, addr, _amount);
    uint256 coverBalanceAfter = collateral.balanceOf(addr);
    require(coverBalanceAfter > coverBalanceBefore, "COVER: collateral transfer failed");
    ICover(addr).mint(coverBalanceAfter.sub(coverBalanceBefore), msg.sender);
    return true;
  }

  function updateExpirationTimestamp(uint48 _expirationTimestamp, bytes32 _expirationTimestampName, uint8 _status) external override onlyDev returns (bool) {

    require(block.timestamp < _expirationTimestamp, "COVER: invalid expiration date");
    require(_status > 0 && _status < 3, "COVER: status not in (0, 2]");

    if (expirationTimestampMap[_expirationTimestamp].status == 0) {
      expirationTimestamps.push(_expirationTimestamp);
    }
    expirationTimestampMap[_expirationTimestamp] = ExpirationTimestampInfo(
      _expirationTimestampName,
      _status
    );
    return true;
  }

  function updateCollateral(address _collateral, uint8 _status) external override onlyDev returns (bool) {

    require(_collateral != address(0), "COVER: address cannot be 0");
    require(_status > 0 && _status < 3, "COVER: status not in (0, 2]");

    if (collateralStatusMap[_collateral] == 0) {
      collaterals.push(_collateral);
    }
    collateralStatusMap[_collateral] = _status;
    return true;
  }

  function enactClaim(
    uint16 _payoutNumerator,
    uint16 _payoutDenominator,
    uint48 _incidentTimestamp,
    uint256 _protocolNonce
  )
   external override returns (bool)
  {

    require(_protocolNonce == claimNonce, "COVER: nonces do not match");
    require(_payoutNumerator <= _payoutDenominator && _payoutNumerator > 0, "COVER: payout % is not in (0%, 100%]");
    require(msg.sender == IProtocolFactory(owner()).claimManager(), "COVER: caller not claimManager");

    claimNonce = claimNonce.add(1);
    delete activeCovers;
    claimDetails.push(ClaimDetails(
      _payoutNumerator,
      _payoutDenominator,
      _incidentTimestamp,
      uint48(block.timestamp)
    ));
    emit ClaimAccepted(_protocolNonce);
    return true;
  }

  function setActive(bool _active) external override onlyDev returns (bool) {

    active = _active;
    return true;
  }

  function updateClaimRedeemDelay(uint256 _claimRedeemDelay)
   external override onlyGovernance returns (bool)
  {

    claimRedeemDelay = _claimRedeemDelay;
    return true;
  }

  function updateNoclaimRedeemDelay(uint256 _noclaimRedeemDelay)
   external override onlyGovernance returns (bool)
  {

    noclaimRedeemDelay = _noclaimRedeemDelay;
    return true;
  }

  function getAllCovers() private view returns (address[] memory) {

    return allCovers;
  }

  function getAllActiveCovers() private view returns (address[] memory) {

    return activeCovers;
  }

  function getCollaterals() private view returns (address[] memory) {

    return collaterals;
  }

  function getExpirationTimestamps() private view returns (uint48[] memory) {

    return expirationTimestamps;
  }

  function _dev() private view returns (address) {

    return IOwnable(owner()).owner();
  }

  function _generateCoverName(uint48 _expirationTimestamp, string memory _collateralSymbol)
   internal view returns (string memory) 
  {

    return string(abi.encodePacked(
      "COVER",
      "_",
      bytes32ToString(name),
      "_",
      bytes32ToString(expirationTimestampMap[_expirationTimestamp].name),
      "_",
      _collateralSymbol,
      "_",
      uintToString(claimNonce)
    ));
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
      return "0";
    }
    uint256 j = _i;
    uint256 len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint256 k = len - 1;
    while (_i != 0) {
      bstr[k--] = byte(uint8(48 + _i % 10));
      _i /= 10;
    }
    return string(bstr);
  }
}// No License

pragma solidity ^0.7.3;


contract ProtocolFactory is IProtocolFactory, Ownable {


  bytes4 private constant PROTOCOL_INIT_SIGNITURE = bytes4(keccak256("initialize(bytes32,bool,address,uint48[],bytes32[])"));

  uint16 public override redeemFeeNumerator = 10; // 0 to 65,535
  uint16 public override redeemFeeDenominator = 10000; // 0 to 65,535

  address public override protocolImplementation;
  address public override coverImplementation;
  address public override coverERC20Implementation;

  address public override treasury;
  address public override governance;
  address public override claimManager;

  bytes32[] private protocolNames;

  mapping(bytes32 => address) public override protocols;

  modifier onlyGovernance() {

    require(msg.sender == governance, "COVER: caller not governance");
    _;
  }

  constructor (
    address _protocolImplementation,
    address _coverImplementation,
    address _coverERC20Implementation,
    address _governance,
    address _treasury
  ) {
    protocolImplementation = _protocolImplementation;
    coverImplementation = _coverImplementation;
    coverERC20Implementation = _coverERC20Implementation;
    governance = _governance;
    treasury = _treasury;

    initializeOwner();
  }

  function getAllProtocolAddresses() external view override returns (address[] memory) {

    bytes32[] memory protocolNamesCopy = protocolNames;
    address[] memory protocolAddresses = new address[](protocolNamesCopy.length);
    for (uint i = 0; i < protocolNamesCopy.length; i++) {
      protocolAddresses[i] = protocols[protocolNamesCopy[i]];
    }
    return protocolAddresses;
  }

  function getRedeemFees() external view override returns (uint16 _numerator, uint16 _denominator) {

    return (redeemFeeNumerator, redeemFeeDenominator);
  }

  function getProtocolsLength() external view override returns (uint256) {

    return protocolNames.length;
  }

  function getProtocolNameAndAddress(uint256 _index)
   external view override returns (bytes32, address)
  {

    bytes32 name = protocolNames[_index];
    return (name, protocols[name]);
  }

  function getProtocolAddress(bytes32 _name) public view override returns (address) {

    return _computeAddress(keccak256(abi.encodePacked(_name)), address(this));
  }

  function getCoverAddress(
    bytes32 _protocolName,
    uint48 _timestamp,
    address _collateral,
    uint256 _claimNonce
  )
   public view override returns (address)
  {

    return _computeAddress(
      keccak256(abi.encodePacked(_protocolName, _timestamp, _collateral, _claimNonce)),
      getProtocolAddress(_protocolName)
    );
  }

  function getCovTokenAddress(
    bytes32 _protocolName,
    uint48 _timestamp,
    address _collateral,
    uint256 _claimNonce,
    bool _isClaimCovToken
  )
   external view override returns (address) 
  {

    return _computeAddress(
      keccak256(abi.encodePacked(
        _protocolName,
        _timestamp,
        _collateral,
        _claimNonce,
        _isClaimCovToken ? "CLAIM" : "NOCLAIM")
      ),
      getCoverAddress(_protocolName, _timestamp, _collateral, _claimNonce)
    );
  }

  function addProtocol(
    bytes32 _name,
    bool _active,
    address _collateral,
    uint48[] calldata _timestamps,
    bytes32[] calldata _timestampNames
  )
    external override onlyOwner returns (address)
  {

    require(protocols[_name] == address(0), "COVER: protocol exists");
    require(_timestamps.length == _timestampNames.length, "COVER: timestamp lengths don't match");
    protocolNames.push(_name);

    bytes memory bytecode = type(InitializableAdminUpgradeabilityProxy).creationCode;
    bytes32 salt = keccak256(abi.encodePacked(_name));
    address payable proxyAddr = Create2.deploy(0, salt, bytecode);
    emit ProtocolInitiation(proxyAddr);

    bytes memory initData = abi.encodeWithSelector(PROTOCOL_INIT_SIGNITURE, _name, _active, _collateral, _timestamps, _timestampNames);
    InitializableAdminUpgradeabilityProxy(proxyAddr).initialize(protocolImplementation, owner(), initData);

    protocols[_name] = proxyAddr;

    return proxyAddr;
  }

  function updateProtocolImplementation(address _newImplementation)
   external override onlyOwner returns (bool)
  {

    require(Address.isContract(_newImplementation), "COVER: new implementation is not a contract");
    protocolImplementation = _newImplementation;
    return true;
  }

  function updateCoverImplementation(address _newImplementation)
   external override onlyOwner returns (bool)
  {

    require(Address.isContract(_newImplementation), "COVER: new implementation is not a contract");
    coverImplementation = _newImplementation;
    return true;
  }

  function updateCoverERC20Implementation(address _newImplementation)
   external override onlyOwner returns (bool)
  {

    require(Address.isContract(_newImplementation), "COVER: new implementation is not a contract");
    coverERC20Implementation = _newImplementation;
    return true;
  }

  function updateFees(
    uint16 _redeemFeeNumerator,
    uint16 _redeemFeeDenominator
  )
    external override onlyGovernance returns (bool)
  {

    require(_redeemFeeDenominator > 0, "COVER: denominator cannot be 0");
    redeemFeeNumerator = _redeemFeeNumerator;
    redeemFeeDenominator = _redeemFeeDenominator;
    return true;
  }

  function updateClaimManager(address _address)
   external override onlyOwner returns (bool)
  {

    require(_address != address(0), "COVER: address cannot be 0");
    claimManager = _address;
    return true;
  }

  function updateGovernance(address _address)
   external override onlyGovernance returns (bool)
  {

    require(_address != address(0), "COVER: address cannot be 0");
    require(_address != owner(), "COVER: governance cannot be owner");
    governance = _address;
    return true;
  }

  function updateTreasury(address _address)
   external override onlyOwner returns (bool)
  {

    require(_address != address(0), "COVER: address cannot be 0");
    treasury = _address;
    return true;
  }

  function _computeAddress(bytes32 salt, address deployer) private pure returns (address) {

    bytes memory bytecode = type(InitializableAdminUpgradeabilityProxy).creationCode;
    return Create2.computeAddress(salt, keccak256(bytecode), deployer);
  }
}// No License

pragma solidity ^0.7.3;


contract CoverERC20 is ICoverERC20, Initializable, Ownable {

  using SafeMath for uint256;

  uint8 public constant decimals = 18;
  string public constant name = "covToken";

  string public override symbol;
  uint256 private _totalSupply;

  mapping(address => uint256) private balances;
  mapping(address => mapping (address => uint256)) private allowances;

  function initialize (string calldata _symbol) external initializer {
    symbol = _symbol;
    initializeOwner();
  }

  function balanceOf(address account) external view override returns (uint256) {

    return balances[account];
  }

  function totalSupply() external view override returns (uint256) {

    return _totalSupply;
  }

  function transfer(address recipient, uint256 amount) external virtual override returns (bool) {

    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) external view virtual override returns (uint256) {

    return allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external virtual override returns (bool) {

    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount)
    external virtual override returns (bool)
  {

    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, allowances[sender][msg.sender].sub(amount, "CoverERC20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool) {

    _approve(msg.sender, spender, allowances[msg.sender][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual override returns (bool) {

    _approve(msg.sender, spender, allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
    return true;
  }

  function mint(address _account, uint256 _amount)
    external override onlyOwner returns (bool)
  {

    require(_account != address(0), "CoverERC20: mint to the zero address");

    _totalSupply = _totalSupply.add(_amount);
    balances[_account] = balances[_account].add(_amount);
    emit Transfer(address(0), _account, _amount);
    return true;
  }

  function setSymbol(string calldata _symbol)
    external override onlyOwner returns (bool)
  {

    symbol = _symbol;
    return true;
  }

  function burnByCover(address _account, uint256 _amount) external override onlyOwner returns (bool) {

    _burn(_account, _amount);
    return true;
  }

  function burn(uint256 _amount) external override returns (bool) {

    _burn(msg.sender, _amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {

    require(sender != address(0), "CoverERC20: transfer from the zero address");
    require(recipient != address(0), "CoverERC20: transfer to the zero address");

    balances[sender] = balances[sender].sub(amount, "CoverERC20: transfer amount exceeds balance");
    balances[recipient] = balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _burn(address account, uint256 amount) internal {

    require(account != address(0), "CoverERC20: burn from the zero address");

    balances[account] = balances[account].sub(amount, "CoverERC20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {

    require(owner != address(0), "CoverERC20: approve from the zero address");
    require(spender != address(0), "CoverERC20: approve to the zero address");

    allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}// No License

pragma solidity ^0.7.3;


contract Cover is ICover, Initializable, Ownable, ReentrancyGuard {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  bytes4 private constant COVERERC20_INIT_SIGNITURE = bytes4(keccak256("initialize(string)"));
  uint48 public override expirationTimestamp;
  address public override collateral;
  ICoverERC20 public override claimCovToken;
  ICoverERC20 public override noclaimCovToken;
  string public override name;
  uint256 public override claimNonce;

  modifier onlyNotExpired() {

    require(block.timestamp < expirationTimestamp, "COVER: cover expired");
    _;
  }

  function initialize (
    string calldata _name,
    uint48 _timestamp,
    address _collateral,
    uint256 _claimNonce
  ) public initializer {
    name = _name;
    expirationTimestamp = _timestamp;
    collateral = _collateral;
    claimNonce = _claimNonce;

    initializeOwner();

    claimCovToken = _createCovToken("CLAIM");
    noclaimCovToken = _createCovToken("NOCLAIM");
  }

  function getCoverDetails()
    external view override returns (string memory _name, uint48 _expirationTimestamp, address _collateral, uint256 _claimNonce, ICoverERC20 _claimCovToken, ICoverERC20 _noclaimCovToken)
  {

    return (name, expirationTimestamp, collateral, claimNonce, claimCovToken, noclaimCovToken);
  }

  function mint(uint256 _amount, address _receiver) external override onlyOwner onlyNotExpired {

    _noClaimAcceptedCheck(); // save gas than modifier

    claimCovToken.mint(_receiver, _amount);
    noclaimCovToken.mint(_receiver, _amount);
  }

  function redeemClaim() external override {

    IProtocol protocol = IProtocol(owner());
    require(protocol.claimNonce() > claimNonce, "COVER: no claim accepted");

    (uint16 _payoutNumerator, uint16 _payoutDenominator, uint48 _incidentTimestamp, uint48 _claimEnactedTimestamp) = _claimDetails();
    require(_incidentTimestamp <= expirationTimestamp, "COVER: cover expired before incident");
    require(block.timestamp >= uint256(_claimEnactedTimestamp) + protocol.claimRedeemDelay(), "COVER: not ready");

    _paySender(
      claimCovToken,
      uint256(_payoutNumerator),
      uint256(_payoutDenominator)
    );
  }

  function redeemNoclaim() external override {

    IProtocol protocol = IProtocol(owner());
    if (protocol.claimNonce() > claimNonce) {

      (uint16 _payoutNumerator, uint16 _payoutDenominator, uint48 _incidentTimestamp, uint48 _claimEnactedTimestamp) = _claimDetails();

      if (_incidentTimestamp > expirationTimestamp) {

        require(block.timestamp >= uint256(expirationTimestamp) + protocol.noclaimRedeemDelay(), "COVER: not ready");
        _paySender(noclaimCovToken, 1, 1);
      } else {

        require(_payoutNumerator < _payoutDenominator, "COVER: claim payout 100%");

        require(block.timestamp >= uint256(_claimEnactedTimestamp) + protocol.claimRedeemDelay(), "COVER: not ready");
        _paySender(
          noclaimCovToken,
          uint256(_payoutDenominator).sub(uint256(_payoutNumerator)),
          uint256(_payoutDenominator)
        );
      }
    } else {

      require(block.timestamp >= uint256(expirationTimestamp) + protocol.noclaimRedeemDelay(), "COVER: not ready");
      _paySender(noclaimCovToken, 1, 1);
    }
  }

  function redeemCollateral(uint256 _amount) external override onlyNotExpired {

    require(_amount > 0, "COVER: amount is 0");
    _noClaimAcceptedCheck(); // save gas than modifier

    ICoverERC20 _claimCovToken = claimCovToken; // save gas
    ICoverERC20 _noclaimCovToken = noclaimCovToken; // save gas

    require(_amount <= _claimCovToken.balanceOf(msg.sender), "COVER: low CLAIM balance");
    require(_amount <= _noclaimCovToken.balanceOf(msg.sender), "COVER: low NOCLAIM balance");

    _claimCovToken.burnByCover(msg.sender, _amount);
    _noclaimCovToken.burnByCover(msg.sender, _amount);
    _payCollateral(msg.sender, _amount);
  }

  function setCovTokenSymbol(string calldata _name) external override {

    require(_dev() == msg.sender, "COVER: not dev");

    claimCovToken.setSymbol(string(abi.encodePacked(_name, "_CLAIM")));
    noclaimCovToken.setSymbol(string(abi.encodePacked(_name, "_NOCLAIM")));
  }

  function _factory() private view returns (address) {

    return IOwnable(owner()).owner();
  }

  function _claimDetails() private view returns (uint16 _payoutNumerator, uint16 _payoutDenominator, uint48 _incidentTimestamp, uint48 _claimEnactedTimestamp) {

    return IProtocol(owner()).claimDetails(claimNonce);
  }

  function _dev() private view returns (address) {

    return IOwnable(_factory()).owner();
  }

  function _noClaimAcceptedCheck() private view {

    require(IProtocol(owner()).claimNonce() == claimNonce, "COVER: claim accepted");
  }

  function _payCollateral(address _receiver, uint256 _amount) private nonReentrant {

    IProtocolFactory factory = IProtocolFactory(_factory());
    uint256 redeemFeeNumerator = factory.redeemFeeNumerator();
    uint256 redeemFeeDenominator = factory.redeemFeeDenominator();
    uint256 fee = _amount.mul(redeemFeeNumerator).div(redeemFeeDenominator);
    address treasury = factory.treasury();
    IERC20 collateralToken = IERC20(collateral);

    collateralToken.safeTransfer(_receiver, _amount.sub(fee));
    collateralToken.safeTransfer(treasury, fee);
  }

  function _paySender(
    ICoverERC20 _covToken,
    uint256 _payoutNumerator,
    uint256 _payoutDenominator
  ) private {

    require(_payoutNumerator <= _payoutDenominator, "COVER: payout % is > 100%");
    require(_payoutNumerator > 0, "COVER: payout % < 0%");

    uint256 amount = _covToken.balanceOf(msg.sender);
    require(amount > 0, "COVER: low covToken balance");

    _covToken.burnByCover(msg.sender, amount);

    uint256 payoutAmount = amount.mul(_payoutNumerator).div(_payoutDenominator);
    _payCollateral(msg.sender, payoutAmount);
  }

  function _createCovToken(string memory _suffix) private returns (ICoverERC20) {

    bytes memory bytecode = type(InitializableAdminUpgradeabilityProxy).creationCode;
    bytes32 salt = keccak256(abi.encodePacked(IProtocol(owner()).name(), expirationTimestamp, collateral, claimNonce, _suffix));
    address payable proxyAddr = Create2.deploy(0, salt, bytecode);

    bytes memory initData = abi.encodeWithSelector(COVERERC20_INIT_SIGNITURE, string(abi.encodePacked(name, "_", _suffix)));
    address coverERC20Implementation = IProtocolFactory(_factory()).coverERC20Implementation();
    InitializableAdminUpgradeabilityProxy(proxyAddr).initialize(
      coverERC20Implementation,
      IOwnable(_factory()).owner(),
      initData
    );

    emit NewCoverERC20(proxyAddr);
    return ICoverERC20(proxyAddr);
  }
}