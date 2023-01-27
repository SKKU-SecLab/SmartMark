

pragma solidity ^0.8.0;

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

}




pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}




pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}




pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}




pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    uint256[49] private __gap;
}



pragma solidity ^0.8.0;


contract OperatorRole is OwnableUpgradeable {

    mapping (address => bool) internal _operators;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    function _initializeOperatorRole() internal {

        __Ownable_init();
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

        return _operators[account];
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

        _operators[account] = true;
        emit OperatorAdded(account);
    }

    function _removeOperator(address account) internal {

        _operators[account] = false;
        emit OperatorRemoved(account);
    }

    uint[50] private ______gap;
}




pragma solidity ^0.8.0;

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



pragma solidity 0.8.3;



contract Whitelist is OwnableUpgradeable, OperatorRole {

    enum ErrorMessage {
        Success,
        JurisdictionFlow,
        LockUp,
        UserUnknown,
        JurisdictionHalt
    }

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

    IERC20 public callingContract;

    struct Config {
        uint64 startDate;
        uint64 lockupGranularity;
    }

    Config internal config;

    struct InvestorLimit {
        uint128 max;
        uint128 current;
    }

    InvestorLimit public globalInvestorLimit;

    mapping(uint => InvestorLimit) public jurisdictionInvestorLimit;

    mapping(uint => uint64) public jurisdictionHaltsUntil;

    mapping(uint => mapping(uint => uint64)) internal jurisdictionFlows;

    enum Status {
        Unknown,
        Activated,
        Revoked,
        Counted
    }

    struct UserInfo {
        Status status;
        uint8 jurisdictionId;
        uint32 startIndex;
        uint32 endIndex;
        uint128 totalTokensLocked;
        uint48 walletCount;
    }

    mapping(address => UserInfo) internal userInfo;

    struct Lockup {
        uint64 lockupExpirationDate;
        uint128 numberOfTokensLocked;
    }

    mapping(address => mapping(uint => Lockup)) internal userIdLockups;

    struct WalletInfo {
        Status status;
        address userId;
    }

    mapping(address => WalletInfo) public walletInfo;

    bytes32 private constant BEACON_SLOT = keccak256(abi.encodePacked("fairmint.beaconproxy.beacon"));

    modifier onlyBeaconOperator() {

        bytes32 slot = BEACON_SLOT;
        address beacon;
        assembly {
            beacon := sload(slot)
        }
        require(beacon == address(0) || OperatorRole(beacon).isOperator(msg.sender), "!BeaconOperator");
        _;
    }

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

        UserInfo memory info = userInfo[_userId];
        return (
            info.jurisdictionId,
            info.totalTokensLocked,
            info.startIndex,
            info.endIndex
        );
    }

    function getInvestorInfo() external view returns(uint256 maxInvestor, uint256 currentInvestor) {

        return (globalInvestorLimit.max, globalInvestorLimit.current);
    }

    function getJurisdictionInfo(uint256 _jurisdictionId) external view returns(uint256 halt, uint256 maxInvestor, uint256 currentInvestor){

        InvestorLimit memory limit = jurisdictionInvestorLimit[_jurisdictionId];
        return (jurisdictionHaltsUntil[_jurisdictionId], limit.max, limit.current);
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

        UserInfo memory info = userInfo[_userId];
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
        uint /*_value*/
    ) external view returns (uint8 status) {

        WalletInfo memory from = walletInfo[_from];
        WalletInfo memory to = walletInfo[_to];
        if (
            ((from.status == Status.Unknown || from.status == Status.Revoked) && _from != address(0)) ||
            ((to.status == Status.Unknown || to.status == Status.Revoked) && _to != address(0))
        ) {
            return uint8(ErrorMessage.UserUnknown);
        }
        if (from.userId != to.userId) {
            uint fromJurisdictionId = userInfo[from.userId]
                .jurisdictionId;
            uint toJurisdictionId = userInfo[to.userId].jurisdictionId;
            if (_isJurisdictionHalted(fromJurisdictionId) || _isJurisdictionHalted(toJurisdictionId)){
                return uint8(ErrorMessage.JurisdictionHalt);
            }
            if (jurisdictionFlows[fromJurisdictionId][toJurisdictionId] == 0) {
                return uint8(ErrorMessage.JurisdictionFlow);
            }
        }

        return uint8(ErrorMessage.Success);
    }

    function messageForTransferRestriction(uint8 _restrictionCode)
        external
        pure
        returns (string memory)
    {

        if (_restrictionCode == uint8(ErrorMessage.Success)) {
            return "SUCCESS";
        }
        if (_restrictionCode == uint8(ErrorMessage.JurisdictionFlow)) {
            return "DENIED: JURISDICTION_FLOW";
        }
        if (_restrictionCode == uint8(ErrorMessage.LockUp)) {
            return "DENIED: LOCKUP";
        }
        if (_restrictionCode == uint8(ErrorMessage.UserUnknown)) {
            return "DENIED: USER_UNKNOWN";
        }
        if (_restrictionCode == uint8(ErrorMessage.JurisdictionHalt)){
            return "DENIED: JURISDICTION_HALT";
        }
        return "DENIED: UNKNOWN_ERROR";
    }

    function initialize(address _callingContract) public onlyBeaconOperator{

        _initializeOperatorRole();
        callingContract = IERC20(_callingContract);
    }

    function configWhitelist(uint _startDate, uint _lockupGranularity)
        external
        onlyOwner()
    {

        config = Config({
            startDate: uint64(_startDate),
            lockupGranularity: uint64(_lockupGranularity)
        });
        emit ConfigWhitelist(_startDate, _lockupGranularity, msg.sender);
    }

    function startDate() external view returns(uint256) {

        return config.startDate;
    }

    function lockupGranularity() external view returns(uint256) {

        return config.lockupGranularity;
    }

    function authorizedWalletToUserId(address wallet) external view returns(address userId) {

        return walletInfo[wallet].userId;
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
            jurisdictionFlows[fromJurisdictionId][toJurisdictionId] = uint64(_lockupLengths[i]);
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
                walletInfo[trader].userId == address(0),
                "USER_WALLET_ALREADY_ADDED"
            );

            uint jurisdictionId = _jurisdictionIds[i];
            require(jurisdictionId != 0, "INVALID_JURISDICTION_ID");

            walletInfo[trader] = WalletInfo({
                status: Status.Activated,
                userId: trader
            });
            userInfo[trader] = UserInfo({
                status: Status.Activated,
                jurisdictionId : uint8(jurisdictionId),
                startIndex : 0,
                endIndex : 0,
                totalTokensLocked: 0,
                walletCount : 1
            });
            require(globalInvestorLimit.max == 0 || globalInvestorLimit.max < globalInvestorLimit.current, "EXCEEDING_MAX_INVESTORS");
            InvestorLimit memory limit = jurisdictionInvestorLimit[jurisdictionId];
            require(limit.max == 0 || limit.max < limit.current, "EXCEEDING_JURISDICTION_MAX_INVESTORS");
            jurisdictionInvestorLimit[jurisdictionId].current++;
            globalInvestorLimit.current++;
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
                userInfo[userId].status != Status.Unknown,
                "USER_ID_UNKNOWN"
            );
            address newWallet = _newWallets[i];
            WalletInfo storage info = walletInfo[newWallet];
            require(
                info.status == Status.Unknown ||
                (info.status == Status.Revoked && info.userId == userId),
                "WALLET_ALREADY_ADDED"
            );
            walletInfo[newWallet] = WalletInfo({
                status: Status.Activated,
                userId: userId
            });
            if(userInfo[userId].walletCount == 0){
                userInfo[userId].status = Status.Activated;
                jurisdictionInvestorLimit[userInfo[userId].jurisdictionId].current++;
                globalInvestorLimit.current++;
            }
            userInfo[userId].walletCount++;
            emit AddApprovedUserWallet(userId, newWallet, msg.sender);
        }
    }

    function revokeUserWallets(address[] calldata _wallets)
        external
        onlyOperator()
    {

        uint length = _wallets.length;
        for (uint i = 0; i < length; i++) {
            WalletInfo memory wallet = walletInfo[_wallets[i]];
            require(
                wallet.status != Status.Unknown,
                "WALLET_NOT_FOUND"
            );
            userInfo[wallet.userId].walletCount--;
            if(userInfo[wallet.userId].walletCount == 0){
                userInfo[wallet.userId].status = Status.Revoked;
                jurisdictionInvestorLimit[userInfo[wallet.userId].jurisdictionId].current--;
                globalInvestorLimit.current--;
            }
            walletInfo[_wallets[i]].status = Status.Revoked;
            emit RevokeUserWallet(_wallets[i], msg.sender);
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
                userInfo[userId].status != Status.Unknown,
                "USER_ID_UNKNOWN"
            );
            uint jurisdictionId = _jurisdictionIds[i];
            require(jurisdictionId != 0, "INVALID_JURISDICTION_ID");
            jurisdictionInvestorLimit[userInfo[userId].jurisdictionId].current--;
            userInfo[userId].jurisdictionId = uint8(jurisdictionId);
            jurisdictionInvestorLimit[jurisdictionId].current++;
            emit UpdateJurisdictionForUserId(userId, jurisdictionId, msg.sender);
        }
    }

    function _addLockup(
        address _userId,
        uint _lockupExpirationDate,
        uint _numberOfTokensLocked
    ) internal {

        if (
            _numberOfTokensLocked == 0 ||
            _lockupExpirationDate <= block.timestamp
        ) {
            return;
        }
        emit AddLockup(
            _userId,
            _lockupExpirationDate,
            _numberOfTokensLocked,
            msg.sender
        );
        UserInfo storage info = userInfo[_userId];
        require(info.status != Status.Unknown, "USER_ID_UNKNOWN");
        require(info.totalTokensLocked + _numberOfTokensLocked >= _numberOfTokensLocked, "OVERFLOW");
        info.totalTokensLocked = info.totalTokensLocked + uint128(_numberOfTokensLocked);
        if (info.endIndex > 0) {
            Lockup storage lockup = userIdLockups[_userId][info.endIndex - 1];
            if (
                lockup.lockupExpirationDate + config.lockupGranularity >= _lockupExpirationDate
            ) {
                lockup.numberOfTokensLocked += uint128(_numberOfTokensLocked);
                return;
            }
        }
        userIdLockups[_userId][info.endIndex] = Lockup(
            uint64(_lockupExpirationDate),
            uint128(_numberOfTokensLocked)
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
        lockup.lockupExpirationDate = 0;
        lockup.numberOfTokensLocked = 0;
        return false;
    }

    function processLockups(address _userId, uint _maxCount) external {

        UserInfo storage info = userInfo[_userId];
        require(info.status != Status.Unknown, "USER_ID_UNKNOWN");
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

        UserInfo storage info = userInfo[_userId];
        require(info.status != Status.Unknown, "USER_ID_UNKNOWN");
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
        return until != 0 && until > block.timestamp;
    }

    function halt(uint[] calldata _jurisdictionIds, uint[] calldata _expirationTimestamps) external onlyOwner {

        uint length = _jurisdictionIds.length;
        for(uint i = 0; i<length; i++){
            _halt(_jurisdictionIds[i], _expirationTimestamps[i]);
        }
    }

    function _halt(uint _jurisdictionId, uint _until) internal {

        require(_until > block.timestamp, "HALT_DUE_SHOULD_BE_FUTURE");
        jurisdictionHaltsUntil[_jurisdictionId] = uint64(_until);
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

        require(_limit >= globalInvestorLimit.current, "LIMIT_SHOULD_BE_LARGER_THAN_CURRENT_INVESTORS");
        globalInvestorLimit.max = uint128(_limit);
        emit MaxInvestorsChanged(_limit);
    }

    function setInvestorLimitForJurisdiction(uint[] calldata _jurisdictionIds, uint[] calldata _limits) external onlyOwner {

        for(uint i = 0; i<_jurisdictionIds.length; i++){
            uint jurisdictionId = _jurisdictionIds[i];
            uint limit = _limits[i];
            require(limit >= jurisdictionInvestorLimit[jurisdictionId].current, "LIMIT_SHOULD_BE_LARGER_THAN_CURRENT_INVESTORS");
            jurisdictionInvestorLimit[jurisdictionId].max = uint128(limit);
            emit MaxInvestorsByJurisdictionChanged(jurisdictionId, limit);
        }
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
        WalletInfo memory from = walletInfo[_from];
        require(
            (from.status != Status.Unknown && from.status != Status.Revoked) ||
            _from == address(0),
            "FROM_USER_UNKNOWN"
        );
        WalletInfo memory to = walletInfo[_to];
        require(
            (to.status != Status.Unknown && to.status != Status.Revoked) ||
            _to == address(0),
            "TO_USER_UNKNOWN"
        );

        if (from.userId != to.userId) {
            uint fromJurisdictionId = userInfo[from.userId]
            .jurisdictionId;
            uint toJurisdictionId = userInfo[to.userId].jurisdictionId;

            require(!_isJurisdictionHalted(fromJurisdictionId), "FROM_JURISDICTION_HALTED");
            require(!_isJurisdictionHalted(toJurisdictionId), "TO_JURISDICTION_HALTED");

            uint lockupLength = jurisdictionFlows[fromJurisdictionId][toJurisdictionId];
            require(lockupLength > 0, "DENIED: JURISDICTION_FLOW");

            if (lockupLength > 1 && _to != address(0)) {
                uint lockupExpirationDate = block.timestamp + lockupLength;
                _addLockup(to.userId, lockupExpirationDate, _value);
            }

            if (_from == address(0)) {
                require(block.timestamp >= config.startDate, "WAIT_FOR_START_DATE");
            } else {
                UserInfo storage info = userInfo[from.userId];
                while (true) {
                    if (_processLockup(info, from.userId, false)) {
                        break;
                    }
                }
                uint balance = callingContract.balanceOf(_from);
                require(balance >= _value, "INSUFFICIENT_BALANCE");
                require(
                    _isSell ||
                    balance >= info.totalTokensLocked + _value,
                    "INSUFFICIENT_TRANSFERABLE_BALANCE"
                );
            }
        }
    }
}