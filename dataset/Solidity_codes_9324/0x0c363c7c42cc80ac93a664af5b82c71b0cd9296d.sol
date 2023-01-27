
interface IWhitelist {

  function detectTransferRestriction(
    address from,
    address to,
    uint value
  ) external view returns (uint8);


  function messageForTransferRestriction(uint8 restrictionCode)
    external
    pure
    returns (string memory);


  function authorizeTransfer(
    address _from,
    address _to,
    uint _value,
    bool _isSell
  ) external;


  function walletActivated(
    address _wallet
  ) external returns(bool);

}


pragma solidity ^0.5.0;

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


pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.0;


contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;



contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;






contract OperatorRole is Initializable, Context, Ownable {

  using Roles for Roles.Role;

  event OperatorAdded(address indexed account);
  event OperatorRemoved(address indexed account);

  Roles.Role private _operators;

  function _initializeOperatorRole() internal {

    _addOperator(msg.sender);
  }

  modifier onlyOperator() {

    require(
      isOperator(msg.sender),
      "OperatorRole: caller does not have the Operator role"
    );
    _;
  }

  function isOperator(address account) public view returns (bool) {

    return _operators.has(account);
  }

  function addOperator(address account) public onlyOwner {

    _addOperator(account);
  }

  function removeOperator(address account) public onlyOwner {

    _removeOperator(account);
  }

  function renounceOperator() public {

    _removeOperator(msg.sender);
  }

  function _addOperator(address account) internal {

    _operators.add(account);
    emit OperatorAdded(account);
  }

  function _removeOperator(address account) internal {

    _operators.remove(account);
    emit OperatorRemoved(account);
  }

  uint[50] private ______gap;
}


pragma solidity 0.5.17;






contract Whitelist is IWhitelist, Ownable, OperatorRole {

  using SafeMath for uint;

  uint8 private constant STATUS_SUCCESS = 0;
  uint8 private constant STATUS_ERROR_JURISDICTION_FLOW = 1;
  uint8 private constant STATUS_ERROR_LOCKUP = 2;
  uint8 private constant STATUS_ERROR_USER_UNKNOWN = 3;
  uint8 private constant STATUS_ERROR_JURISDICTION_HALT = 4;
  uint8 private constant STATUS_ERROR_NON_LISTED_USER = 5;

  event ConfigWhitelist(
    uint _startDate,
    uint _lockupGranularity,
    address indexed _operator
  );
  event UpdateJurisdictionFlow(
    uint indexed _fromJurisdictionId,
    uint indexed _toJurisdictionId,
    uint _lockupLength,
    address indexed _operator
  );
  event ApproveNewUser(
    address indexed _trader,
    uint indexed _jurisdictionId,
    address indexed _operator
  );
  event AddApprovedUserWallet(
    address indexed _userId,
    address indexed _newWallet,
    address indexed _operator
  );
  event RevokeUserWallet(address indexed _wallet, address indexed _operator);
  event UpdateJurisdictionForUserId(
    address indexed _userId,
    uint indexed _jurisdictionId,
    address indexed _operator
  );
  event AddLockup(
    address indexed _userId,
    uint _lockupExpirationDate,
    uint _numberOfTokensLocked,
    address indexed _operator
  );
  event UnlockTokens(
    address indexed _userId,
    uint _tokensUnlocked,
    address indexed _operator
  );
  event Halt(uint indexed _jurisdictionId, uint _until);
  event Resume(uint indexed _jurisdictionId);
  event MaxInvestorsChanged(uint _limit);
  event MaxInvestorsByJurisdictionChanged(uint indexed _jurisdictionId, uint _limit);
  event InvestorEnlisted(address indexed _userId, uint indexed _jurisdictionId);
  event InvestorDelisted(address indexed _userId, uint indexed _jurisdictionId);
  event WalletActivated(address indexed _userId, address indexed _wallet);
  event WalletDeactivated(address indexed _userId, address indexed _wallet);

  IERC20 public callingContract;

  uint public startDate;

  uint public lockupGranularity;

  mapping(uint => mapping(uint => uint)) internal jurisdictionFlows;

  mapping(address => address) public authorizedWalletToUserId;

  struct UserInfo {
    uint jurisdictionId;
    uint totalTokensLocked;
    uint startIndex;
    uint endIndex;
  }

  mapping(address => UserInfo) internal authorizedUserIdInfo;

  struct Lockup {
    uint lockupExpirationDate;
    uint numberOfTokensLocked;
  }

  mapping(address => mapping(uint => Lockup)) internal userIdLockups;

  mapping(uint => uint) public jurisdictionHaltsUntil;

  uint public maxInvestors;

  uint public currentInvestors;

  mapping(uint => uint) public maxInvestorsByJurisdiction;

  mapping(uint => uint) public currentInvestorsByJurisdiction;

  mapping(address => bool) public investorEnlisted;

  mapping(address => uint) public userActiveWalletCount;

  mapping(address => bool) public walletActivated;


  mapping(address => address) public revokedFrom;

  function getJurisdictionFlow(
    uint _fromJurisdictionId,
    uint _toJurisdictionId
  ) external view returns (uint lockupLength) {

    return jurisdictionFlows[_fromJurisdictionId][_toJurisdictionId];
  }

  function getAuthorizedUserIdInfo(address _userId)
    external
    view
    returns (
      uint jurisdictionId,
      uint totalTokensLocked,
      uint startIndex,
      uint endIndex
    )
  {

    UserInfo memory info = authorizedUserIdInfo[_userId];
    return (
      info.jurisdictionId,
      info.totalTokensLocked,
      info.startIndex,
      info.endIndex
    );
  }

  function getUserIdLockup(address _userId, uint _lockupIndex)
    external
    view
    returns (uint lockupExpirationDate, uint numberOfTokensLocked)
  {

    Lockup memory lockup = userIdLockups[_userId][_lockupIndex];
    return (lockup.lockupExpirationDate, lockup.numberOfTokensLocked);
  }

  function getLockedTokenCount(address _userId)
    external
    view
    returns (uint lockedTokens)
  {

    UserInfo memory info = authorizedUserIdInfo[_userId];
    lockedTokens = info.totalTokensLocked;
    uint endIndex = info.endIndex;
    for (uint i = info.startIndex; i < endIndex; i++) {
      Lockup memory lockup = userIdLockups[_userId][i];
      if (lockup.lockupExpirationDate > block.timestamp) {
        break;
      }
      lockedTokens -= lockup.numberOfTokensLocked;
    }
  }

  function detectTransferRestriction(
    address _from,
    address _to,
    uint /* _value */
  ) external view returns (uint8 status) {

    address fromUserId = authorizedWalletToUserId[_from];
    address toUserId = authorizedWalletToUserId[_to];
    if (
      (fromUserId == address(0) && _from != address(0)) ||
      (toUserId == address(0) && _to != address(0))
    ) {
      return STATUS_ERROR_USER_UNKNOWN;
    }
    if (fromUserId != toUserId) {
      uint fromJurisdictionId = authorizedUserIdInfo[fromUserId]
        .jurisdictionId;
      uint toJurisdictionId = authorizedUserIdInfo[toUserId].jurisdictionId;
      if (_isJurisdictionHalted(fromJurisdictionId) || _isJurisdictionHalted(toJurisdictionId)){
        return STATUS_ERROR_JURISDICTION_HALT;
      }
      if (jurisdictionFlows[fromJurisdictionId][toJurisdictionId] == 0) {
        return STATUS_ERROR_JURISDICTION_FLOW;
      }
    }

    return STATUS_SUCCESS;
  }

  function messageForTransferRestriction(uint8 _restrictionCode)
    external
    pure
    returns (string memory)
  {

    if (_restrictionCode == STATUS_SUCCESS) {
      return "SUCCESS";
    }
    if (_restrictionCode == STATUS_ERROR_JURISDICTION_FLOW) {
      return "DENIED: JURISDICTION_FLOW";
    }
    if (_restrictionCode == STATUS_ERROR_LOCKUP) {
      return "DENIED: LOCKUP";
    }
    if (_restrictionCode == STATUS_ERROR_USER_UNKNOWN) {
      return "DENIED: USER_UNKNOWN";
    }
    if (_restrictionCode == STATUS_ERROR_JURISDICTION_HALT){
      return "DENIED: JURISDICTION_HALT";
    }
    return "DENIED: UNKNOWN_ERROR";
  }

  function initialize(address _callingContract) public {

    Ownable.initialize(msg.sender);
    _initializeOperatorRole();
    callingContract = IERC20(_callingContract);
  }

  function configWhitelist(uint _startDate, uint _lockupGranularity)
    external
    onlyOwner()
  {

    startDate = _startDate;
    lockupGranularity = _lockupGranularity;
    emit ConfigWhitelist(_startDate, _lockupGranularity, msg.sender);
  }

  function updateJurisdictionFlows(
    uint[] calldata _fromJurisdictionIds,
    uint[] calldata _toJurisdictionIds,
    uint[] calldata _lockupLengths
  ) external onlyOwner() {

    uint count = _fromJurisdictionIds.length;
    for (uint i = 0; i < count; i++) {
      uint fromJurisdictionId = _fromJurisdictionIds[i];
      uint toJurisdictionId = _toJurisdictionIds[i];
      require(
        fromJurisdictionId > 0 && toJurisdictionId > 0,
        "INVALID_JURISDICTION_ID"
      );
      jurisdictionFlows[fromJurisdictionId][toJurisdictionId] = _lockupLengths[i];
      emit UpdateJurisdictionFlow(
        fromJurisdictionId,
        toJurisdictionId,
        _lockupLengths[i],
        msg.sender
      );
    }
  }

  function approveNewUsers(
    address[] calldata _traders,
    uint[] calldata _jurisdictionIds
  ) external onlyOperator() {

    uint length = _traders.length;
    for (uint i = 0; i < length; i++) {
      address trader = _traders[i];
      require(
        authorizedWalletToUserId[trader] == address(0),
        "USER_WALLET_ALREADY_ADDED"
      );
      require(
        revokedFrom[trader] == address(0) ||
        revokedFrom[trader] == trader,
        "ATTEMPT_TO_ADD_PREVIOUS_WALLET_AS_NEW_USER"
      );
      uint jurisdictionId = _jurisdictionIds[i];
      require(jurisdictionId != 0, "INVALID_JURISDICTION_ID");

      authorizedWalletToUserId[trader] = trader;
      authorizedUserIdInfo[trader].jurisdictionId = jurisdictionId;
      emit ApproveNewUser(trader, jurisdictionId, msg.sender);
    }
  }

  function addApprovedUserWallets(
    address[] calldata _userIds,
    address[] calldata _newWallets
  ) external onlyOperator() {

    uint length = _userIds.length;
    for (uint i = 0; i < length; i++) {
      address userId = _userIds[i];
      require(
        authorizedUserIdInfo[userId].jurisdictionId != 0,
        "USER_ID_UNKNOWN"
      );
      address newWallet = _newWallets[i];
      require(
        authorizedWalletToUserId[newWallet] == address(0),
        "WALLET_ALREADY_ADDED"
      );
      require(
        revokedFrom[newWallet] == address(0) ||
        revokedFrom[newWallet] == userId,
        "ATTEMPT_TO_EXCHANGE_WALLET"
      );

      authorizedWalletToUserId[newWallet] = userId;
      emit AddApprovedUserWallet(userId, newWallet, msg.sender);
    }
  }

  function revokeUserWallets(address[] calldata _wallets)
    external
    onlyOperator()
  {

    uint length = _wallets.length;
    for (uint i = 0; i < length; i++) {
      address wallet = _wallets[i];
      require(
        authorizedWalletToUserId[wallet] != address(0),
        "WALLET_NOT_FOUND"
      );

      if(walletActivated[wallet]){
        _deactivateWallet(wallet);
      }

      revokedFrom[wallet] = authorizedWalletToUserId[wallet];

      authorizedWalletToUserId[wallet] = address(0);
      emit RevokeUserWallet(wallet, msg.sender);
    }
  }

  function updateJurisdictionsForUserIds(
    address[] calldata _userIds,
    uint[] calldata _jurisdictionIds
  ) external onlyOperator() {

    uint length = _userIds.length;
    for (uint i = 0; i < length; i++) {
      address userId = _userIds[i];
      require(
        authorizedUserIdInfo[userId].jurisdictionId != 0,
        "USER_ID_UNKNOWN"
      );
      uint jurisdictionId = _jurisdictionIds[i];
      require(jurisdictionId != 0, "INVALID_JURISDICTION_ID");
      if(investorEnlisted[userId]){
        currentInvestorsByJurisdiction[authorizedUserIdInfo[userId].jurisdictionId]--;
        currentInvestorsByJurisdiction[jurisdictionId]++;
      }
      authorizedUserIdInfo[userId].jurisdictionId = jurisdictionId;
      emit UpdateJurisdictionForUserId(userId, jurisdictionId, msg.sender);
    }
  }

  function _addLockup(
    address _userId,
    uint _lockupExpirationDate,
    uint _numberOfTokensLocked
  ) internal {

    if (
      _numberOfTokensLocked == 0 || _lockupExpirationDate <= block.timestamp
    ) {
      return;
    }
    emit AddLockup(
      _userId,
      _lockupExpirationDate,
      _numberOfTokensLocked,
      msg.sender
    );
    UserInfo storage info = authorizedUserIdInfo[_userId];
    require(info.jurisdictionId != 0, "USER_ID_UNKNOWN");
    info.totalTokensLocked = info.totalTokensLocked.add(_numberOfTokensLocked);
    if (info.endIndex > 0) {
      Lockup storage lockup = userIdLockups[_userId][info.endIndex - 1];
      if (
        lockup.lockupExpirationDate + lockupGranularity >= _lockupExpirationDate
      ) {
        lockup.numberOfTokensLocked += _numberOfTokensLocked;
        return;
      }
    }
    userIdLockups[_userId][info.endIndex] = Lockup(
      _lockupExpirationDate,
      _numberOfTokensLocked
    );
    info.endIndex++;
  }

  function addLockups(
    address[] calldata _userIds,
    uint[] calldata _lockupExpirationDates,
    uint[] calldata _numberOfTokensLocked
  ) external onlyOperator() {

    uint length = _userIds.length;
    for (uint i = 0; i < length; i++) {
      _addLockup(
        _userIds[i],
        _lockupExpirationDates[i],
        _numberOfTokensLocked[i]
      );
    }
  }

  function _processLockup(
    UserInfo storage info,
    address _userId,
    bool _ignoreExpiration
  ) internal returns (bool isDone) {

    if (info.startIndex >= info.endIndex) {
      return true;
    }
    Lockup storage lockup = userIdLockups[_userId][info.startIndex];
    if (lockup.lockupExpirationDate > block.timestamp && !_ignoreExpiration) {
      return true;
    }
    emit UnlockTokens(_userId, lockup.numberOfTokensLocked, msg.sender);
    info.totalTokensLocked -= lockup.numberOfTokensLocked;
    info.startIndex++;
    lockup.numberOfTokensLocked = 0;
    lockup.lockupExpirationDate = 0;
    return false;
  }

  function processLockups(address _userId, uint _maxCount) external {

    UserInfo storage info = authorizedUserIdInfo[_userId];
    require(info.jurisdictionId > 0, "USER_ID_UNKNOWN");
    for (uint i = 0; i < _maxCount; i++) {
      if (_processLockup(info, _userId, false)) {
        break;
      }
    }
  }

  function forceUnlockUpTo(address _userId, uint _maxLockupIndex)
    external
    onlyOperator()
  {

    UserInfo storage info = authorizedUserIdInfo[_userId];
    require(info.jurisdictionId > 0, "USER_ID_UNKNOWN");
    require(_maxLockupIndex > info.startIndex, "ALREADY_UNLOCKED");
    uint maxCount = _maxLockupIndex - info.startIndex;
    for (uint i = 0; i < maxCount; i++) {
      if (_processLockup(info, _userId, true)) {
        break;
      }
    }
  }

  function _isJurisdictionHalted(uint _jurisdictionId) internal view returns(bool){

    uint until = jurisdictionHaltsUntil[_jurisdictionId];
    return until != 0 && until > now;
  }

  function halt(uint[] calldata _jurisdictionIds, uint[] calldata _expirationTimestamps) external onlyOwner {

    uint length = _jurisdictionIds.length;
    for(uint i = 0; i<length; i++){
      _halt(_jurisdictionIds[i], _expirationTimestamps[i]);
    }
  }

  function _halt(uint _jurisdictionId, uint _until) internal {

    require(_until > now, "HALT_DUE_SHOULD_BE_FUTURE");
    jurisdictionHaltsUntil[_jurisdictionId] = _until;
    emit Halt(_jurisdictionId, _until);
  }

  function resume(uint[] calldata _jurisdictionIds) external onlyOwner{

    uint length = _jurisdictionIds.length;
    for(uint i = 0; i < length; i++){
      _resume(_jurisdictionIds[i]);
    }
  }

  function _resume(uint _jurisdictionId) internal {

    require(jurisdictionHaltsUntil[_jurisdictionId] != 0, "ATTEMPT_TO_RESUME_NONE_HALTED_JURISDICATION");
    jurisdictionHaltsUntil[_jurisdictionId] = 0;
    emit Resume(_jurisdictionId);
  }

  function setInvestorLimit(uint _limit) external onlyOwner {

    require(_limit >= currentInvestors, "LIMIT_SHOULD_BE_LARGER_THAN_CURRENT_INVESTORS");
    maxInvestors = _limit;
    emit MaxInvestorsChanged(_limit);
  }

  function setInvestorLimitForJurisdiction(uint[] calldata _jurisdictionIds, uint[] calldata _limits) external onlyOwner {

    for(uint i = 0; i<_jurisdictionIds.length; i++){
      uint jurisdictionId = _jurisdictionIds[i];
      uint limit = _limits[i];
      require(limit >= currentInvestorsByJurisdiction[jurisdictionId], "LIMIT_SHOULD_BE_LARGER_THAN_CURRENT_INVESTORS");
      maxInvestorsByJurisdiction[jurisdictionId] = limit;
      emit MaxInvestorsByJurisdictionChanged(jurisdictionId, limit);
    }
  }

  function activateWallets(
    address[] calldata _wallets
  ) external onlyOperator {

    for(uint i = 0; i<_wallets.length; i++){
      _activateWallet(_wallets[i]);
    }
  }

  function _activateWallet(
    address _wallet
  ) internal {

    address userId = authorizedWalletToUserId[_wallet];
    require(userId != address(0), "USER_UNKNOWN");
    require(!walletActivated[_wallet],"ALREADY_ACTIVATED_WALLET");
    if(!investorEnlisted[userId]){
      _enlistUser(userId);
    }
    userActiveWalletCount[userId]++;
    walletActivated[_wallet] = true;
    emit WalletActivated(userId, _wallet);
  }

  function deactivateWallet(
    address _wallet
  ) external {

    require(callingContract.balanceOf(_wallet) == 0, "ATTEMPT_TO_DEACTIVATE_WALLET_WITH_BALANCE");
    _deactivateWallet(_wallet);
  }

  function deactivateWallets(
    address[] calldata _wallets
  ) external onlyOperator {

    for(uint i = 0; i<_wallets.length; i++){
      require(callingContract.balanceOf(_wallets[i]) == 0, "ATTEMPT_TO_DEACTIVATE_WALLET_WITH_BALANCE");
      _deactivateWallet(_wallets[i]);
    }
  }

  function _deactivateWallet(
    address _wallet
  ) internal {

    address userId = authorizedWalletToUserId[_wallet];
    require(userId != address(0), "USER_UNKNOWN");
    require(walletActivated[_wallet],"ALREADY_DEACTIVATED_WALLET");
    userActiveWalletCount[userId]--;
    walletActivated[_wallet] = false;
    emit WalletDeactivated(userId, _wallet);
    if(userActiveWalletCount[userId]==0){
      _delistUser(userId);
    }
  }

  function enlistUsers(
    address[] calldata _userIds
  ) external onlyOperator {

    for(uint i = 0; i<_userIds.length; i++){
      _enlistUser(_userIds[i]);
    }
  }

  function _enlistUser(
    address _userId
  ) internal {

    require(
      authorizedUserIdInfo[_userId].jurisdictionId != 0,
      "USER_ID_UNKNOWN"
    );
    require(!investorEnlisted[_userId],"ALREADY_ENLISTED_USER");
    investorEnlisted[_userId] = true;
    uint jurisdictionId = authorizedUserIdInfo[_userId]
      .jurisdictionId;
    uint totalCount = ++currentInvestors;
    require(maxInvestors == 0 || totalCount <= maxInvestors, "EXCEEDING_MAX_INVESTORS");
    uint jurisdictionCount = ++currentInvestorsByJurisdiction[jurisdictionId];
    uint maxJurisdictionLimit = maxInvestorsByJurisdiction[jurisdictionId];
    require(maxJurisdictionLimit == 0 || jurisdictionCount <= maxJurisdictionLimit,"EXCEEDING_JURISDICTION_MAX_INVESTORS");
    emit InvestorEnlisted(_userId, jurisdictionId);
  }

  function delistUsers(
    address[] calldata _userIds
  ) external onlyOperator {

    for(uint i = 0; i<_userIds.length; i++){
      _delistUser(_userIds[i]);
    }
  }

  function _delistUser(
    address _userId
  ) internal {

    require(investorEnlisted[_userId],"ALREADY_DELISTED_USER");
    require(userActiveWalletCount[_userId]==0,"ATTEMPT_TO_DELIST_USER_WITH_ACTIVE_WALLET");
    investorEnlisted[_userId] = false;
    uint jurisdictionId = authorizedUserIdInfo[_userId]
      .jurisdictionId;
    --currentInvestors;
    --currentInvestorsByJurisdiction[jurisdictionId];
    emit InvestorDelisted(_userId, jurisdictionId);
  }
  function authorizeTransfer(
    address _from,
    address _to,
    uint _value,
    bool _isSell
  ) external {

    require(address(callingContract) == msg.sender, "CALL_VIA_CONTRACT_ONLY");

    if (_to == address(0) && !_isSell) {
      return;
    }
    address fromUserId = authorizedWalletToUserId[_from];
    require(
      fromUserId != address(0) || _from == address(0),
      "FROM_USER_UNKNOWN"
    );
    address toUserId = authorizedWalletToUserId[_to];
    require(toUserId != address(0) || _to == address(0), "TO_USER_UNKNOWN");
    if(!walletActivated[_from] && _from != address(0)){
      _activateWallet(_from);
    }
    if(!walletActivated[_to] && _to != address(0)){
      _activateWallet(_to);
    }
    if(callingContract.balanceOf(_from) == _value && _from != address(0)){
      _deactivateWallet(_from);
    }

    if (fromUserId != toUserId) {
      uint fromJurisdictionId = authorizedUserIdInfo[fromUserId]
      .jurisdictionId;
      uint toJurisdictionId = authorizedUserIdInfo[toUserId].jurisdictionId;

      require(!_isJurisdictionHalted(fromJurisdictionId), "FROM_JURISDICTION_HALTED");
      require(!_isJurisdictionHalted(toJurisdictionId), "TO_JURISDICTION_HALTED");

      uint lockupLength = jurisdictionFlows[fromJurisdictionId][toJurisdictionId];
      require(lockupLength > 0, "DENIED: JURISDICTION_FLOW");

      if (lockupLength > 1 && _to != address(0)) {
        uint lockupExpirationDate = block.timestamp + lockupLength;
        _addLockup(toUserId, lockupExpirationDate, _value);
      }

      if (_from == address(0)) {
        require(block.timestamp >= startDate, "WAIT_FOR_START_DATE");
      } else {
        UserInfo storage info = authorizedUserIdInfo[fromUserId];
        while (true) {
          if (_processLockup(info, fromUserId, false)) {
            break;
          }
        }
        uint balance = callingContract.balanceOf(_from);
        require(balance >= _value, "INSUFFICIENT_BALANCE");
        require(
          _isSell ||
          balance >= info.totalTokensLocked.add(_value),
          "INSUFFICIENT_TRANSFERABLE_BALANCE"
        );
      }
    }
  }
}