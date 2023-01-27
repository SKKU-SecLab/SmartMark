
pragma solidity ^0.5.4;

contract Account {


    address public implementation;

    address public manager;
    
    mapping (bytes4 => address) public enabled;

    event EnabledStaticCall(address indexed module, bytes4 indexed method);
    event Invoked(address indexed module, address indexed target, uint indexed value, bytes data);
    event Received(uint indexed value, address indexed sender, bytes data);

    event AccountInit(address indexed account);
    event ManagerChanged(address indexed mgr);

    modifier allowAuthorizedLogicContractsCallsOnly {

        require(LogicManager(manager).isAuthorized(msg.sender), "not an authorized logic");
        _;
    }

    function init(address _manager, address _accountStorage, address[] calldata _logics, address[] calldata _keys, address[] calldata _backups)
        external
    {

        require(manager == address(0), "Account: account already initialized");
        require(_manager != address(0) && _accountStorage != address(0), "Account: address is null");
        manager = _manager;

        for (uint i = 0; i < _logics.length; i++) {
            address logic = _logics[i];
            require(LogicManager(manager).isAuthorized(logic), "must be authorized logic");

            BaseLogic(logic).initAccount(this);
        }

        AccountStorage(_accountStorage).initAccount(this, _keys, _backups);

        emit AccountInit(address(this));
    }

    function invoke(address _target, uint _value, bytes calldata _data)
        external
        allowAuthorizedLogicContractsCallsOnly
        returns (bytes memory _res)
    {

        bool success;
        (success, _res) = _target.call.value(_value)(_data);
        require(success, "call to target failed");
        emit Invoked(msg.sender, _target, _value, _data);
    }

    function enableStaticCall(address _module, bytes4 _method) external allowAuthorizedLogicContractsCallsOnly {

        enabled[_method] = _module;
        emit EnabledStaticCall(_module, _method);
    }

    function changeManager(address _newMgr) external allowAuthorizedLogicContractsCallsOnly {

        require(_newMgr != address(0), "address cannot be null");
        require(_newMgr != manager, "already changed");
        manager = _newMgr;
        emit ManagerChanged(_newMgr);
    }

    function() external payable {
        if(msg.data.length > 0) {
            address logic = enabled[msg.sig];
            if(logic == address(0)) {
                emit Received(msg.value, msg.sender, msg.data);
            }
            else {
                require(LogicManager(manager).isAuthorized(logic), "must be an authorized logic for static call");
                assembly {
                    calldatacopy(0, 0, calldatasize())
                    let result := staticcall(gas, logic, 0, calldatasize(), 0, 0)
                    returndatacopy(0, 0, returndatasize())
                    switch result
                    case 0 {revert(0, returndatasize())}
                    default {return (0, returndatasize())}
                }
            }
        }
    }
}

contract Owned {


    address public owner;

    event OwnerChanged(address indexed _newOwner);

    modifier onlyOwner {

        require(msg.sender == owner, "Must be owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function changeOwner(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}

contract LogicManager is Owned {


    event UpdateLogicSubmitted(address indexed logic, bool value);
    event UpdateLogicCancelled(address indexed logic);
    event UpdateLogicDone(address indexed logic, bool value);

    struct pending {
        bool value; //True: enable a new logic; False: disable an old logic.
        uint dueTime; //due time of a pending logic
    }

    mapping (address => bool) public authorized;

    address[] public authorizedLogics;

    mapping (address => pending) public pendingLogics;

    struct pendingTime {
        uint curPendingTime; //current pending time
        uint nextPendingTime; //new pending time
        uint dueTime; //due time of new pending time
    }

    pendingTime public pt;

    uint public logicCount;

    constructor(address[] memory _initialLogics, uint256 _pendingTime) public
    {
        for (uint i = 0; i < _initialLogics.length; i++) {
            address logic = _initialLogics[i];
            authorized[logic] = true;
            logicCount += 1;
        }
        authorizedLogics = _initialLogics;

        pt.curPendingTime = _pendingTime;
        pt.nextPendingTime = _pendingTime;
        pt.dueTime = now;
    }

    function submitUpdatePendingTime(uint _pendingTime) external onlyOwner {

        pt.nextPendingTime = _pendingTime;
        pt.dueTime = pt.curPendingTime + now;
    }

    function triggerUpdatePendingTime() external {

        require(pt.dueTime <= now, "too early to trigger updatePendingTime");
        pt.curPendingTime = pt.nextPendingTime;
    }

    function isAuthorized(address _logic) external view returns (bool) {

        return authorized[_logic];
    }

    function getAuthorizedLogics() external view returns (address[] memory) {

        return authorizedLogics;
    }

    function submitUpdate(address _logic, bool _value) external onlyOwner {

        pending storage p = pendingLogics[_logic];
        p.value = _value;
        p.dueTime = now + pt.curPendingTime;
        emit UpdateLogicSubmitted(_logic, _value);
    }

    function cancelUpdate(address _logic) external onlyOwner {

        delete pendingLogics[_logic];
        emit UpdateLogicCancelled(_logic);
    }

    function triggerUpdateLogic(address _logic) external {

        pending memory p = pendingLogics[_logic];
        require(p.dueTime > 0, "pending logic not found");
        require(p.dueTime <= now, "too early to trigger updateLogic");
        updateLogic(_logic, p.value);
        delete pendingLogics[_logic];
    }

    function updateLogic(address _logic, bool _value) internal {

        if (authorized[_logic] != _value) {
            if(_value) {
                logicCount += 1;
                authorized[_logic] = true;
                authorizedLogics.push(_logic);
            }
            else {
                logicCount -= 1;
                require(logicCount > 0, "must have at least one logic module");
                delete authorized[_logic];
                removeLogic(_logic);
            }
            emit UpdateLogicDone(_logic, _value);
        }
    }

    function removeLogic(address _logic) internal {

        uint len = authorizedLogics.length;
        address lastLogic = authorizedLogics[len - 1];
        if (_logic != lastLogic) {
            for (uint i = 0; i < len; i++) {
                 if (_logic == authorizedLogics[i]) {
                     authorizedLogics[i] = lastLogic;
                     break;
                 }
            }
        }
        authorizedLogics.length--;
    }
}


contract AccountStorage {


    modifier allowAccountCallsOnly(Account _account) {

        require(msg.sender == address(_account), "caller must be account");
        _;
    }

    modifier allowAuthorizedLogicContractsCallsOnly(address payable _account) {

        require(LogicManager(Account(_account).manager()).isAuthorized(msg.sender), "not an authorized logic");
        _;
    }

    struct KeyItem {
        address pubKey;
        uint256 status;
    }

    struct BackupAccount {
        address backup;
        uint256 effectiveDate;//means not effective until this timestamp
        uint256 expiryDate;//means effective until this timestamp
    }

    struct DelayItem {
        bytes32 hash;
        uint256 dueTime;
    }

    struct Proposal {
        bytes32 hash;
        address[] approval;
    }

    mapping (address => uint256) operationKeyCount;

    mapping (address => mapping(uint256 => KeyItem)) keyData;

    mapping (address => mapping(uint256 => BackupAccount)) backupData;

    mapping (address => mapping(bytes4 => DelayItem)) delayData;

    mapping (address => mapping(address => mapping(bytes4 => Proposal))) proposalData;


    function getOperationKeyCount(address _account) external view returns(uint256) {

        return operationKeyCount[_account];
    }

    function increaseKeyCount(address payable _account) external allowAuthorizedLogicContractsCallsOnly(_account) {

        operationKeyCount[_account] = operationKeyCount[_account] + 1;
    }


    function getKeyData(address _account, uint256 _index) public view returns(address) {

        KeyItem memory item = keyData[_account][_index];
        return item.pubKey;
    }

    function setKeyData(address payable _account, uint256 _index, address _key) external allowAuthorizedLogicContractsCallsOnly(_account) {

        require(_key != address(0), "invalid _key value");
        KeyItem storage item = keyData[_account][_index];
        item.pubKey = _key;
    }


    function getKeyStatus(address _account, uint256 _index) external view returns(uint256) {

        KeyItem memory item = keyData[_account][_index];
        return item.status;
    }

    function setKeyStatus(address payable _account, uint256 _index, uint256 _status) external allowAuthorizedLogicContractsCallsOnly(_account) {

        KeyItem storage item = keyData[_account][_index];
        item.status = _status;
    }


    function getBackupAddress(address _account, uint256 _index) external view returns(address) {

        BackupAccount memory b = backupData[_account][_index];
        return b.backup;
    }

    function getBackupEffectiveDate(address _account, uint256 _index) external view returns(uint256) {

        BackupAccount memory b = backupData[_account][_index];
        return b.effectiveDate;
    }

    function getBackupExpiryDate(address _account, uint256 _index) external view returns(uint256) {

        BackupAccount memory b = backupData[_account][_index];
        return b.expiryDate;
    }

    function setBackup(address payable _account, uint256 _index, address _backup, uint256 _effective, uint256 _expiry)
        external
        allowAuthorizedLogicContractsCallsOnly(_account)
    {

        BackupAccount storage b = backupData[_account][_index];
        b.backup = _backup;
        b.effectiveDate = _effective;
        b.expiryDate = _expiry;
    }

    function setBackupExpiryDate(address payable _account, uint256 _index, uint256 _expiry)
        external
        allowAuthorizedLogicContractsCallsOnly(_account)
    {

        BackupAccount storage b = backupData[_account][_index];
        b.expiryDate = _expiry;
    }

    function clearBackupData(address payable _account, uint256 _index) external allowAuthorizedLogicContractsCallsOnly(_account) {

        delete backupData[_account][_index];
    }


    function getDelayDataHash(address payable _account, bytes4 _actionId) external view returns(bytes32) {

        DelayItem memory item = delayData[_account][_actionId];
        return item.hash;
    }

    function getDelayDataDueTime(address payable _account, bytes4 _actionId) external view returns(uint256) {

        DelayItem memory item = delayData[_account][_actionId];
        return item.dueTime;
    }

    function setDelayData(address payable _account, bytes4 _actionId, bytes32 _hash, uint256 _dueTime) external allowAuthorizedLogicContractsCallsOnly(_account) {

        DelayItem storage item = delayData[_account][_actionId];
        item.hash = _hash;
        item.dueTime = _dueTime;
    }

    function clearDelayData(address payable _account, bytes4 _actionId) external allowAuthorizedLogicContractsCallsOnly(_account) {

        delete delayData[_account][_actionId];
    }


    function getProposalDataHash(address _client, address _proposer, bytes4 _actionId) external view returns(bytes32) {

        Proposal memory p = proposalData[_client][_proposer][_actionId];
        return p.hash;
    }

    function getProposalDataApproval(address _client, address _proposer, bytes4 _actionId) external view returns(address[] memory) {

        Proposal memory p = proposalData[_client][_proposer][_actionId];
        return p.approval;
    }

    function setProposalData(address payable _client, address _proposer, bytes4 _actionId, bytes32 _hash, address _approvedBackup)
        external
        allowAuthorizedLogicContractsCallsOnly(_client)
    {

        Proposal storage p = proposalData[_client][_proposer][_actionId];
        if (p.hash > 0) {
            if (p.hash == _hash) {
                for (uint256 i = 0; i < p.approval.length; i++) {
                    require(p.approval[i] != _approvedBackup, "backup already exists");
                }
                p.approval.push(_approvedBackup);
            } else {
                p.hash = _hash;
                p.approval.length = 0;
            }
        } else {
            p.hash = _hash;
            p.approval.push(_approvedBackup);
        }
    }

    function clearProposalData(address payable _client, address _proposer, bytes4 _actionId) external allowAuthorizedLogicContractsCallsOnly(_client) {

        delete proposalData[_client][_proposer][_actionId];
    }



    function initAccount(Account _account, address[] calldata _keys, address[] calldata _backups)
        external
        allowAccountCallsOnly(_account)
    {

        require(getKeyData(address(_account), 0) == address(0), "AccountStorage: account already initialized!");
        require(_keys.length > 0, "empty keys array");

        operationKeyCount[address(_account)] = _keys.length - 1;

        for (uint256 index = 0; index < _keys.length; index++) {
            address _key = _keys[index];
            require(_key != address(0), "_key cannot be 0x0");
            KeyItem storage item = keyData[address(_account)][index];
            item.pubKey = _key;
            item.status = 0;
        }

        if (_backups.length > 1) {
            address[] memory bkps = _backups;
            for (uint256 i = 0; i < _backups.length; i++) {
                for (uint256 j = 0; j < i; j++) {
                    require(bkps[j] != _backups[i], "duplicate backup");
                }
            }
        }

        for (uint256 index = 0; index < _backups.length; index++) {
            address _backup = _backups[index];
            require(_backup != address(0), "backup cannot be 0x0");
            require(_backup != address(_account), "cannot be backup of oneself");

            backupData[address(_account)][index] = BackupAccount(_backup, now, uint256(-1));
        }
    }
}


library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }

    function ceil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        if(a % b == 0) {
            return c;
        }
        else {
            return c + 1;
        }
    }
}


contract BaseLogic {


    bytes constant internal SIGN_HASH_PREFIX = "\x19Ethereum Signed Message:\n32";

    mapping (address => uint256) keyNonce;
    AccountStorage public accountStorage;

    modifier allowSelfCallsOnly() {

        require (msg.sender == address(this), "only internal call is allowed");
        _;
    }

    modifier allowAccountCallsOnly(Account _account) {

        require(msg.sender == address(_account), "caller must be account");
        _;
    }


    constructor(AccountStorage _accountStorage) public {
        accountStorage = _accountStorage;
    }


    function initAccount(Account _account) external allowAccountCallsOnly(_account){

    }


    function getKeyNonce(address _key) external view returns(uint256) {

        return keyNonce[_key];
    }


    function getSignHash(bytes memory _data, uint256 _nonce) internal view returns(bytes32) {

        bytes32 msgHash = keccak256(abi.encodePacked(byte(0x19), byte(0), address(this), _data, _nonce));
        bytes32 prefixedHash = keccak256(abi.encodePacked(SIGN_HASH_PREFIX, msgHash));
        return prefixedHash;
    }

    function verifySig(address _signingKey, bytes memory _signature, bytes32 _signHash) internal pure {

        require(_signingKey != address(0), "invalid signing key");
        address recoveredAddr = recover(_signHash, _signature);
        require(recoveredAddr == _signingKey, "signature verification failed");
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function getSignerAddress(bytes memory _b) internal pure returns (address _a) {

        require(_b.length >= 36, "invalid bytes");
        assembly {
            let mask := 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            _a := and(mask, mload(add(_b, 36)))
        }
    }

    function getMethodId(bytes memory _b) internal pure returns (bytes4 _a) {

        require(_b.length >= 4, "invalid data");
        assembly {
            _a := mload(add(_b, 32))
        }
    }

    function checkKeyStatus(address _account, uint256 _index) internal view {

        if (_index > 0) {
            require(accountStorage.getKeyStatus(_account, _index) != 1, "frozen key");
        }
    }

    function checkAndUpdateNonce(address _key, uint256 _nonce) internal {

        require(_nonce > keyNonce[_key], "nonce too small");
        require(SafeMath.div(_nonce, 1000000) <= now + 86400, "nonce too big"); // 86400=24*3600 seconds

        keyNonce[_key] = _nonce;
    }
}

contract AccountBaseLogic is BaseLogic {


    uint256 constant internal DELAY_CHANGE_ADMIN_KEY = 21 days;
    uint256 constant internal DELAY_CHANGE_OPERATION_KEY = 7 days;
    uint256 constant internal DELAY_UNFREEZE_KEY = 7 days;
    uint256 constant internal DELAY_CHANGE_BACKUP = 21 days;
    uint256 constant internal DELAY_CHANGE_ADMIN_KEY_BY_BACKUP = 30 days;

    uint256 constant internal MAX_DEFINED_BACKUP_INDEX = 5;

	bytes4 internal constant CHANGE_ADMIN_KEY = 0xd595d935;
	bytes4 internal constant CHANGE_ADMIN_KEY_BY_BACKUP = 0xfdd54ba1;
	bytes4 internal constant CHANGE_ADMIN_KEY_WITHOUT_DELAY = 0x441d2e50;
	bytes4 internal constant CHANGE_ALL_OPERATION_KEYS_WITHOUT_DELAY = 0x02064abc;
	bytes4 internal constant UNFREEZE_WITHOUT_DELAY = 0x69521650;
	bytes4 internal constant CHANGE_ALL_OPERATION_KEYS = 0xd3b9d4d6;
	bytes4 internal constant UNFREEZE = 0x45c8b1a6;


	constructor(AccountStorage _accountStorage)
		BaseLogic(_accountStorage)
		public
	{
	}


    function checkRelation(address _client, address _backup) internal view {

        require(_backup != address(0), "backup cannot be 0x0");
        require(_client != address(0), "client cannot be 0x0");
        bool isBackup;
        for (uint256 i = 0; i <= MAX_DEFINED_BACKUP_INDEX; i++) {
            address backup = accountStorage.getBackupAddress(_client, i);
            uint256 effectiveDate = accountStorage.getBackupEffectiveDate(_client, i);
            uint256 expiryDate = accountStorage.getBackupExpiryDate(_client, i);
            if (_backup == backup && isEffectiveBackup(effectiveDate, expiryDate)) {
                isBackup = true;
                break;
            }
        }
        require(isBackup, "backup does not exist in list");
    }

    function isEffectiveBackup(uint256 _effectiveDate, uint256 _expiryDate) internal view returns(bool) {

        return (_effectiveDate <= now) && (_expiryDate > now);
    }

    function clearRelatedProposalAfterAdminKeyChanged(address payable _client) internal {

        accountStorage.clearProposalData(_client, _client, CHANGE_ADMIN_KEY_WITHOUT_DELAY);
        accountStorage.clearProposalData(_client, _client, CHANGE_ALL_OPERATION_KEYS_WITHOUT_DELAY);
        accountStorage.clearProposalData(_client, _client, UNFREEZE_WITHOUT_DELAY);

        for (uint256 i = 0; i <= MAX_DEFINED_BACKUP_INDEX; i++) {
            address backup = accountStorage.getBackupAddress(_client, i);
            if (backup != address(0)) {
                accountStorage.clearProposalData(_client, backup, CHANGE_ADMIN_KEY_BY_BACKUP);
            }
        }
    }

}

contract ProposalLogic is AccountBaseLogic {


    event ProposalExecuted(address indexed client, address indexed proposer, bytes functionData);
	event ChangeAdminKeyByBackup(address indexed account, address indexed pkNew);
	event ChangeAdminKeyByBackupTriggered(address indexed account, address pkNew);
    event ChangeAdminKeyWithoutDelay(address indexed account, address pkNew);
    event ChangeAllOperationKeysWithoutDelay(address indexed account, address[] pks);
    event UnfreezeWithoutDelay(address indexed account);

    constructor(AccountStorage _accountStorage)
        public
        AccountBaseLogic(_accountStorage)
    {
    }


    function executeProposal(address payable _client, address _proposer, bytes calldata _functionData) external {

        require(getSignerAddress(_functionData) == _client, "invalid _client");
        
        bytes4 proposedActionId = getMethodId(_functionData);
        checkProposedAction(proposedActionId);
        bytes32 functionHash = keccak256(_functionData);

        checkApproval(_client, _proposer, proposedActionId, functionHash);

        (bool success,) = address(this).call(_functionData);
        require(success, "executeProposal failed");

        accountStorage.clearProposalData(_client, _proposer, proposedActionId);
        emit ProposalExecuted(_client, _proposer, _functionData);
    }

    function checkProposedAction(bytes4 actionId) internal pure {

        require(actionId == CHANGE_ADMIN_KEY_BY_BACKUP || 
                actionId == CHANGE_ADMIN_KEY_WITHOUT_DELAY || 
                actionId == CHANGE_ALL_OPERATION_KEYS_WITHOUT_DELAY || 
                actionId == UNFREEZE_WITHOUT_DELAY, "invalid proposed action");
    }

    function checkApproval(address _client, address _proposer, bytes4 _proposedActionId, bytes32 _functionHash) internal view {

        if (_proposer != _client) {
			checkRelation(_client, _proposer);
		}
        bytes32 hash = accountStorage.getProposalDataHash(_client, _proposer, _proposedActionId);
        require(hash == _functionHash, "proposal hash unmatch");

        uint256 backupCount;
        uint256 approvedCount;
        address[] memory approved = accountStorage.getProposalDataApproval(_client, _proposer, _proposedActionId);
        require(approved.length > 0, "no approval");

        for (uint256 i = 0; i <= MAX_DEFINED_BACKUP_INDEX; i++) {
            address backup = accountStorage.getBackupAddress(_client, i);
            uint256 effectiveDate = accountStorage.getBackupEffectiveDate(_client, i);
            uint256 expiryDate = accountStorage.getBackupExpiryDate(_client, i);
            if (backup != address(0) && isEffectiveBackup(effectiveDate, expiryDate)) {
                backupCount += 1;
                for (uint256 k = 0; k < approved.length; k++) {
                    if (backup == approved[k]) {
                       approvedCount += 1;
                    }
                }
            }
        }
        require(backupCount > 0, "no backup in list");
        uint256 threshold = SafeMath.ceil(backupCount*6, 10);
        require(approvedCount >= threshold, "must have 60% approval at least");
    }


	function changeAdminKeyByBackup(address payable _account, address _pkNew) external allowSelfCallsOnly {

		require(_pkNew != address(0), "0x0 is invalid");
		address pk = accountStorage.getKeyData(_account, 0);
		require(pk != _pkNew, "identical admin key exists");
		require(accountStorage.getDelayDataHash(_account, CHANGE_ADMIN_KEY_BY_BACKUP) == 0, "delay data already exists");
		bytes32 hash = keccak256(abi.encodePacked('changeAdminKeyByBackup', _account, _pkNew));
		accountStorage.setDelayData(_account, CHANGE_ADMIN_KEY_BY_BACKUP, hash, now + DELAY_CHANGE_ADMIN_KEY_BY_BACKUP);
		emit ChangeAdminKeyByBackup(_account, _pkNew);
	}

	function triggerChangeAdminKeyByBackup(address payable _account, address _pkNew) external {

		bytes32 hash = keccak256(abi.encodePacked('changeAdminKeyByBackup', _account, _pkNew));
		require(hash == accountStorage.getDelayDataHash(_account, CHANGE_ADMIN_KEY_BY_BACKUP), "delay hash unmatch");

		uint256 due = accountStorage.getDelayDataDueTime(_account, CHANGE_ADMIN_KEY_BY_BACKUP);
		require(due > 0, "delay data not found");
		require(due <= now, "too early to trigger changeAdminKeyByBackup");
		accountStorage.setKeyData(_account, 0, _pkNew);
		accountStorage.clearDelayData(_account, CHANGE_ADMIN_KEY_BY_BACKUP);
		accountStorage.clearDelayData(_account, CHANGE_ADMIN_KEY);
		clearRelatedProposalAfterAdminKeyChanged(_account);
		emit ChangeAdminKeyByBackupTriggered(_account, _pkNew);
	}


	function changeAdminKeyWithoutDelay(address payable _account, address _pkNew) external allowSelfCallsOnly {

		address pk = accountStorage.getKeyData(_account, 0);
		require(pk != _pkNew, "identical admin key already exists");
		require(_pkNew != address(0), "0x0 is invalid");
		accountStorage.setKeyData(_account, 0, _pkNew);
		accountStorage.clearDelayData(_account, CHANGE_ADMIN_KEY);
		accountStorage.clearDelayData(_account, CHANGE_ADMIN_KEY_BY_BACKUP);
		accountStorage.clearDelayData(_account, CHANGE_ALL_OPERATION_KEYS);
		accountStorage.clearDelayData(_account, UNFREEZE);
		clearRelatedProposalAfterAdminKeyChanged(_account);
        emit ChangeAdminKeyWithoutDelay(_account, _pkNew);
	}


	function changeAllOperationKeysWithoutDelay(address payable _account, address[] calldata _pks) external allowSelfCallsOnly {

		uint256 keyCount = accountStorage.getOperationKeyCount(_account);
		require(_pks.length == keyCount, "invalid number of keys");
		for (uint256 i = 0; i < keyCount; i++) {
			address pk = _pks[i];
			require(pk != address(0), "0x0 is invalid");
			accountStorage.setKeyData(_account, i+1, pk);
			accountStorage.setKeyStatus(_account, i+1, 0);
		}
        emit ChangeAllOperationKeysWithoutDelay(_account, _pks);
	}


	function unfreezeWithoutDelay(address payable _account) external allowSelfCallsOnly {

		for (uint256 i = 0; i < accountStorage.getOperationKeyCount(_account); i++) {
			if (accountStorage.getKeyStatus(_account, i+1) == 1) {
				accountStorage.setKeyStatus(_account, i+1, 0);
			}
		}
        emit UnfreezeWithoutDelay(_account);
	}
}