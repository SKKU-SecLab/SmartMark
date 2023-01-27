
pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity 0.8.11;



abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleMemberIndex(bytes32 role, address account) public view returns (uint256) {
        return _roles[role].members._inner._indexes[bytes32(uint256(uint160(account)))];
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity 0.8.11;


contract Pausable {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        _whenNotPaused();
        _;
    }

    function _whenNotPaused() private view {

        require(!_paused, "Pausable: paused");
    }

    modifier whenPaused() {

        _whenPaused();
        _;
    }

    function _whenPaused() private view {

        require(_paused, "Pausable: not paused");
    }

    function _pause(address sender) internal virtual whenNotPaused {

        _paused = true;
        emit Paused(sender);
    }

    function _unpause(address sender) internal virtual whenPaused {

        _paused = false;
        emit Unpaused(sender);
    }
}// MIT

pragma solidity 0.8.11;


contract SafeMath {


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return _sub(a, b, "SafeMath: subtraction overflow");
    }

    function _sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
}// MIT

pragma solidity 0.8.11;


library SafeCast {

    function toUint200(uint256 value) internal pure returns (uint200) {

        require(value < 2**200, "value does not fit in 200 bits");
        return uint200(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "value does not fit in 128 bits");
        return uint128(value);
    }

    function toUint40(uint256 value) internal pure returns (uint40) {

        require(value < 2**40, "value does not fit in 40 bits");
        return uint40(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "value does not fit in 8 bits");
        return uint8(value);
    }
}// LGPL-3.0-only
pragma solidity 0.8.11;

interface IDepositExecute {

    function deposit(bytes32 resourceID, address depositer, bytes calldata data) external returns (bytes memory);


    function executeProposal(bytes32 resourceID, bytes calldata data) external;

}// LGPL-3.0-only
pragma solidity 0.8.11;

interface IERCHandler {

    function setResource(bytes32 resourceID, address contractAddress) external;

    function setBurnable(address contractAddress) external;


    function withdraw(bytes memory data) external;


    function _resourceIDToTokenContractAddress(bytes32 resourceID) external view returns (address);

}// LGPL-3.0-only
pragma solidity 0.8.11;

interface IGenericHandler {

    function setResource(
        bytes32 resourceID,
        address contractAddress,
        bytes4 depositFunctionSig,
        uint depositFunctionDepositerOffset,
        bytes4 executeFunctionSig) external;

}// LGPL-3.0-only
pragma solidity 0.8.11;

interface IFeeHandler {


    event FeeCollected(
        address sender,
        uint8 fromDomainID,
        uint8 destinationDomainID,
        bytes32 resourceID,
        uint256 fee,
        address tokenAddress
    );

    event FeeDistributed(
        address tokenAddress,
        address recipient,
        uint256 amount
    );

    function collectFee(address sender, uint8 fromDomainID, uint8 destinationDomainID, bytes32 resourceID, bytes calldata depositData, bytes calldata feeData) payable external;


    function calculateFee(address sender, uint8 fromDomainID, uint8 destinationDomainID, bytes32 resourceID, bytes calldata depositData, bytes calldata feeData) external view returns(uint256, address);

}// LGPL-3.0-only
pragma solidity 0.8.11;


contract Bridge is Pausable, AccessControl, SafeMath {

    using SafeCast for *;

    uint256 constant public MAX_RELAYERS = 200;

    uint8   public _domainID;
    uint8   public _relayerThreshold;
    uint40  public _expiry;

    IFeeHandler public _feeHandler;

    enum ProposalStatus {Inactive, Active, Passed, Executed, Cancelled}

    struct Proposal {
        ProposalStatus _status;
        uint200 _yesVotes;      // bitmap, 200 maximum votes
        uint8   _yesVotesTotal;
        uint40  _proposedBlock; // 1099511627775 maximum block
    }

    mapping(uint8 => uint64) public _depositCounts;
    mapping(bytes32 => address) public _resourceIDToHandlerAddress;
    mapping(address => bool) public isValidForwarder;
    mapping(uint72 => mapping(bytes32 => Proposal)) private _proposals;

    event RelayerThresholdChanged(uint256 newThreshold);
    event RelayerAdded(address relayer);
    event RelayerRemoved(address relayer);
    event FeeHandlerChanged(address newFeeHandler);
    event Deposit(
        uint8   destinationDomainID,
        bytes32 resourceID,
        uint64  depositNonce,
        address indexed user,
        bytes data,
        bytes handlerResponse
    );
    event ProposalEvent(
        uint8          originDomainID,
        uint64         depositNonce,
        ProposalStatus status,
        bytes32 dataHash
    );
    event ProposalVote(
        uint8   originDomainID,
        uint64  depositNonce,
        ProposalStatus status,
        bytes32 dataHash
    );
    event FailedHandlerExecution(
        bytes lowLevelData
    );

    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");

    modifier onlyAdmin() {

        _onlyAdmin();
        _;
    }

    modifier onlyAdminOrRelayer() {

        _onlyAdminOrRelayer();
        _;
    }

    modifier onlyRelayers() {

        _onlyRelayers();
        _;
    }

    function _onlyAdminOrRelayer() private view {

        address sender = _msgSender();
        require(hasRole(DEFAULT_ADMIN_ROLE, sender) || hasRole(RELAYER_ROLE, sender),
            "sender is not relayer or admin");
    }

    function _onlyAdmin() private view {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "sender doesn't have admin role");
    }

    function _onlyRelayers() private view {

        require(hasRole(RELAYER_ROLE, _msgSender()), "sender doesn't have relayer role");
    }

    function _relayerBit(address relayer) private view returns(uint) {

        return uint(1) << sub(AccessControl.getRoleMemberIndex(RELAYER_ROLE, relayer), 1);
    }

    function _hasVoted(Proposal memory proposal, address relayer) private view returns(bool) {

        return (_relayerBit(relayer) & uint(proposal._yesVotes)) > 0;
    }

    function _msgSender() internal override view returns (address) {

        address signer = msg.sender;
        if (msg.data.length >= 20 && isValidForwarder[signer]) {
            assembly {
                signer := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        }
        return signer;
    }

    constructor (uint8 domainID, address[] memory initialRelayers, uint256 initialRelayerThreshold, uint256 expiry) public {
        _domainID = domainID;
        _relayerThreshold = initialRelayerThreshold.toUint8();
        _expiry = expiry.toUint40();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        for (uint256 i; i < initialRelayers.length; i++) {
            grantRole(RELAYER_ROLE, initialRelayers[i]);
        }
    }

    function _hasVotedOnProposal(uint72 destNonce, bytes32 dataHash, address relayer) public view returns(bool) {

        return _hasVoted(_proposals[destNonce][dataHash], relayer);
    }

    function isRelayer(address relayer) external view returns (bool) {

        return hasRole(RELAYER_ROLE, relayer);
    }

    function renounceAdmin(address newAdmin) external onlyAdmin {

        address sender = _msgSender();
        require(sender != newAdmin, 'Cannot renounce oneself');
        grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        renounceRole(DEFAULT_ADMIN_ROLE, sender);
    }

    function adminPauseTransfers() external onlyAdmin {

        _pause(_msgSender());
    }

    function adminUnpauseTransfers() external onlyAdmin {

        _unpause(_msgSender());
    }

    function adminChangeRelayerThreshold(uint256 newThreshold) external onlyAdmin {

        _relayerThreshold = newThreshold.toUint8();
        emit RelayerThresholdChanged(newThreshold);
    }

    function adminAddRelayer(address relayerAddress) external {

        require(!hasRole(RELAYER_ROLE, relayerAddress), "addr already has relayer role!");
        require(_totalRelayers() < MAX_RELAYERS, "relayers limit reached");
        grantRole(RELAYER_ROLE, relayerAddress);
        emit RelayerAdded(relayerAddress);
    }

    function adminRemoveRelayer(address relayerAddress) external {

        require(hasRole(RELAYER_ROLE, relayerAddress), "addr doesn't have relayer role!");
        revokeRole(RELAYER_ROLE, relayerAddress);
        emit RelayerRemoved(relayerAddress);
    }

    function adminSetResource(address handlerAddress, bytes32 resourceID, address tokenAddress) external onlyAdmin {

        _resourceIDToHandlerAddress[resourceID] = handlerAddress;
        IERCHandler handler = IERCHandler(handlerAddress);
        handler.setResource(resourceID, tokenAddress);
    }

    function adminSetGenericResource(
        address handlerAddress,
        bytes32 resourceID,
        address contractAddress,
        bytes4 depositFunctionSig,
        uint256 depositFunctionDepositerOffset,
        bytes4 executeFunctionSig
    ) external onlyAdmin {

        _resourceIDToHandlerAddress[resourceID] = handlerAddress;
        IGenericHandler handler = IGenericHandler(handlerAddress);
        handler.setResource(resourceID, contractAddress, depositFunctionSig, depositFunctionDepositerOffset, executeFunctionSig);
    }

    function adminSetBurnable(address handlerAddress, address tokenAddress) external onlyAdmin {

        IERCHandler handler = IERCHandler(handlerAddress);
        handler.setBurnable(tokenAddress);
    }

    function adminSetDepositNonce(uint8 domainID, uint64 nonce) external onlyAdmin {

        require(nonce > _depositCounts[domainID], "Does not allow decrements of the nonce");
        _depositCounts[domainID] = nonce;
    }

    function adminSetForwarder(address forwarder, bool valid) external onlyAdmin {

        isValidForwarder[forwarder] = valid;
    }

    function getProposal(uint8 originDomainID, uint64 depositNonce, bytes32 dataHash) external view returns (Proposal memory) {

        uint72 nonceAndID = (uint72(depositNonce) << 8) | uint72(originDomainID);
        return _proposals[nonceAndID][dataHash];
    }

    function _totalRelayers() public view returns (uint) {

        return AccessControl.getRoleMemberCount(RELAYER_ROLE);
    }

    function adminChangeFeeHandler(address newFeeHandler) external onlyAdmin {

        _feeHandler = IFeeHandler(newFeeHandler);
        emit FeeHandlerChanged(newFeeHandler);
    }

    function adminWithdraw(
        address handlerAddress,
        bytes memory data
    ) external onlyAdmin {

        IERCHandler handler = IERCHandler(handlerAddress);
        handler.withdraw(data);
    }

    function deposit(uint8 destinationDomainID, bytes32 resourceID, bytes calldata depositData, bytes calldata feeData) external payable whenNotPaused {

        address sender = _msgSender();
        if (address(_feeHandler) == address(0)) {
            require(msg.value == 0, "no FeeHandler, msg.value != 0");
        } else {
            _feeHandler.collectFee{value: msg.value}(sender, _domainID, destinationDomainID, resourceID, depositData, feeData);
        }

        address handler = _resourceIDToHandlerAddress[resourceID];
        require(handler != address(0), "resourceID not mapped to handler");

        uint64 depositNonce = ++_depositCounts[destinationDomainID];

        IDepositExecute depositHandler = IDepositExecute(handler);
        bytes memory handlerResponse = depositHandler.deposit(resourceID, sender, depositData);

        emit Deposit(destinationDomainID, resourceID, depositNonce, sender, depositData, handlerResponse);
    }

    function voteProposal(uint8 domainID, uint64 depositNonce, bytes32 resourceID, bytes calldata data) external onlyRelayers whenNotPaused {

        address handler = _resourceIDToHandlerAddress[resourceID];
        uint72 nonceAndID = (uint72(depositNonce) << 8) | uint72(domainID);
        bytes32 dataHash = keccak256(abi.encodePacked(handler, data));
        Proposal memory proposal = _proposals[nonceAndID][dataHash];

        require(_resourceIDToHandlerAddress[resourceID] != address(0), "no handler for resourceID");

        if (proposal._status == ProposalStatus.Passed) {
            executeProposal(domainID, depositNonce, data, resourceID, true);
            return;
        }

        address sender = _msgSender();
        
        require(uint(proposal._status) <= 1, "proposal already executed/cancelled");
        require(!_hasVoted(proposal, sender), "relayer already voted");

        if (proposal._status == ProposalStatus.Inactive) {
            proposal = Proposal({
                _status : ProposalStatus.Active,
                _yesVotes : 0,
                _yesVotesTotal : 0,
                _proposedBlock : uint40(block.number) // Overflow is desired.
            });

            emit ProposalEvent(domainID, depositNonce, ProposalStatus.Active, dataHash);
        } else if (uint40(sub(block.number, proposal._proposedBlock)) > _expiry) {
            proposal._status = ProposalStatus.Cancelled;

            emit ProposalEvent(domainID, depositNonce, ProposalStatus.Cancelled, dataHash);
        }

        if (proposal._status != ProposalStatus.Cancelled) {
            proposal._yesVotes = (proposal._yesVotes | _relayerBit(sender)).toUint200();
            proposal._yesVotesTotal++; // TODO: check if bit counting is cheaper.

            emit ProposalVote(domainID, depositNonce, proposal._status, dataHash);

            if (proposal._yesVotesTotal >= _relayerThreshold) {
                proposal._status = ProposalStatus.Passed;
                emit ProposalEvent(domainID, depositNonce, ProposalStatus.Passed, dataHash);
            }
        }
        _proposals[nonceAndID][dataHash] = proposal;

        if (proposal._status == ProposalStatus.Passed) {
            executeProposal(domainID, depositNonce, data, resourceID, false);
        }
    }

    function cancelProposal(uint8 domainID, uint64 depositNonce, bytes32 dataHash) public onlyAdminOrRelayer {

        uint72 nonceAndID = (uint72(depositNonce) << 8) | uint72(domainID);
        Proposal memory proposal = _proposals[nonceAndID][dataHash];
        ProposalStatus currentStatus = proposal._status;

        require(currentStatus == ProposalStatus.Active || currentStatus == ProposalStatus.Passed,
            "Proposal cannot be cancelled");
        require(uint40(sub(block.number, proposal._proposedBlock)) > _expiry, "Proposal not at expiry threshold");

        proposal._status = ProposalStatus.Cancelled;
        _proposals[nonceAndID][dataHash] = proposal;

        emit ProposalEvent(domainID, depositNonce, ProposalStatus.Cancelled, dataHash);
    }

    function executeProposal(uint8 domainID, uint64 depositNonce, bytes calldata data, bytes32 resourceID, bool revertOnFail) public onlyRelayers whenNotPaused {

        address handler = _resourceIDToHandlerAddress[resourceID];
        uint72 nonceAndID = (uint72(depositNonce) << 8) | uint72(domainID);
        bytes32 dataHash = keccak256(abi.encodePacked(handler, data));
        Proposal storage proposal = _proposals[nonceAndID][dataHash];

        require(proposal._status == ProposalStatus.Passed, "Proposal must have Passed status");

        proposal._status = ProposalStatus.Executed;
        IDepositExecute depositHandler = IDepositExecute(handler);

        if (revertOnFail) {
            depositHandler.executeProposal(resourceID, data);
        } else {
            try depositHandler.executeProposal(resourceID, data) {
            } catch (bytes memory lowLevelData) {
                proposal._status = ProposalStatus.Passed;
                emit FailedHandlerExecution(lowLevelData);
                return;
            }
        }
        
        emit ProposalEvent(domainID, depositNonce, ProposalStatus.Executed, dataHash);
    }
}