
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
}// MIT

pragma solidity ^0.8.0;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// LGPL-3.0-or-later
pragma solidity 0.8.6;


contract KRoles is AccessControl {

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(OPERATOR_ROLE, _msgSender());
        _setRoleAdmin (OPERATOR_ROLE, DEFAULT_ADMIN_ROLE) ;
    }

    modifier onlyOperator() {

        require(isOperator(_msgSender()), "OperatorRole: caller does not have the Operator role");
        _;
    }

    function isOperator(address account) public view returns (bool) {

        return hasRole(OPERATOR_ROLE, account);
    }

    function addOperator(address account) public {

        _addOperator(account);
    }

    function renounceOperator() public virtual {

        _renounceOperator(msg.sender);
    }

    function _addOperator(address account) internal {

        grantRole(OPERATOR_ROLE, account);
        emit OperatorAdded(account);
    }

    function _renounceOperator(address account) internal {

        renounceRole(OPERATOR_ROLE, account);
        emit OperatorRemoved(account);
    }
}// LGPL-3.0-or-later
pragma solidity 0.8.6;


contract CanReclaimTokens is KRoles {

    using SafeERC20 for IERC20;

    mapping(address => bool) private recoverableTokensBlacklist;

    function blacklistRecoverableToken(address _token) public onlyOperator {

        recoverableTokensBlacklist[_token] = true;
    }

    function recoverTokens(address _token) external onlyOperator {

        require(
            !recoverableTokensBlacklist[_token],
            "CanReclaimTokens: token is not recoverable"
        );

        if (_token == address(0x0)) {
           (bool success,) = msg.sender.call{ value: address(this).balance }("");
            require(success, "Transfer Failed");
        } else {
            IERC20(_token).safeTransfer(
                msg.sender,
                IERC20(_token).balanceOf(address(this))
            );
        }
    }
}// MIT
pragma solidity 0.8.6;




contract CoordinationPaymentChannels is CanReclaimTokens {

    using SafeERC20 for IERC20;

    IERC20 constant ROOK = IERC20(0xfA5047c9c78B8877af97BDcb85Db743fD7313d4a);
    bytes constant public INSTANT_WITHDRAWAL_COMMITMENT_DATA = bytes("INSTANT");

    address public coordinator;
    address public claimGenerator;
    
    mapping (address => uint256) public stakedAmount;
    mapping (address => uint256) public stakeNonce;
    mapping (address => uint256) public stakeSpent;
    mapping (address => uint256) public channelNonce;
    mapping (bytes32 => uint256) public withdrawalTimelockTimestamp;

    mapping (address => uint256) public userClaimedAmount;


    uint256 public totalClaimableAmount;

    event Staked(address indexed _stakeAddress, uint256 _channelNonce, uint256 _amount);
    event Claimed(address indexed _claimAddress, uint256 _amount);
    event CoordinatorChanged(address indexed _oldCoordinator, address indexed _newCoordinator);
    event ClaimGeneratorChanged(address indexed _oldClaimGenerator, address indexed _newClaimGenerator);
    event StakeWithdrawn(address indexed _stakeAddress, uint256 _channelNonce, uint256 _amount);
    event TimelockedWithdrawalInitiated(
        address indexed _stakeAddress, 
        uint256 _stakeSpent, 
        uint256 _stakeNonce, 
        uint256 _channelNonce, 
        uint256 _withdrawalTimelock);
    event AddedClaimable(uint256 _amount);
    event Settled(uint256 _refundedAmount, uint256 _accruedAmount);

    struct StakeCommitment {
        address stakeAddress;
        uint256 stakeSpent;
        uint256 stakeNonce;
        uint256 channelNonce;
        bytes data;
        bytes stakeAddressSignature;
        bytes coordinatorSignature;
    }

    function getStakerState(
        address _stakeAddress
    ) public view returns (
        uint256 _stakedAmount, 
        uint256 _stakeNonce, 
        uint256 _stakeSpent, 
        uint256 _channelNonce, 
        uint256 _withdrawalTimelock
    ) {

        return (
            stakedAmount[_stakeAddress], 
            stakeNonce[_stakeAddress], 
            stakeSpent[_stakeAddress], 
            channelNonce[_stakeAddress], 
            getCurrentWithdrawalTimelock(_stakeAddress));
    }

    function stakeCommitmentHash(
        address _stakeAddress, 
        uint256 _stakeSpent, 
        uint256 _stakeNonce, 
        uint256 _channelNonce, 
        bytes memory _data
    ) public pure returns (bytes32) {

        return keccak256(abi.encode(_stakeAddress, _stakeSpent, _stakeNonce, _channelNonce, _data));
    }

    function stakeCommitmentHash(
        StakeCommitment memory _commitment
    ) internal pure returns (bytes32) {

        return stakeCommitmentHash(
            _commitment.stakeAddress, 
            _commitment.stakeSpent, 
            _commitment.stakeNonce, 
            _commitment.channelNonce, 
            _commitment.data);
    }

    function claimCommitmentHash(
        address _claimAddress, 
        uint256 _earningsToDate
    ) public pure returns (bytes32) {

        return keccak256(abi.encode(_claimAddress, _earningsToDate));
    }

    function withdrawalTimelockKey(
        address _stakeAddress, 
        uint256 _stakeSpent, 
        uint256 _stakeNonce, 
        uint256 _channelNonce
    ) public pure returns (bytes32) {

        return keccak256(abi.encode(_stakeAddress, _stakeSpent, _stakeNonce, _channelNonce));
    }

    function getCurrentWithdrawalTimelock(
        address _stakeAddress
    ) public view returns (uint256) {

        return withdrawalTimelockTimestamp[
            withdrawalTimelockKey(
                _stakeAddress, 
                stakeSpent[_stakeAddress], 
                stakeNonce[_stakeAddress], 
                channelNonce[_stakeAddress])];
    }

    constructor(address _coordinator, address _claimGenerator) {
        coordinator = _coordinator;
        claimGenerator = _claimGenerator;
        blacklistRecoverableToken(address(ROOK));
        emit CoordinatorChanged(address(0), _coordinator);
        emit ClaimGeneratorChanged(address(0), _claimGenerator);
    }

    function updateCoordinatorAddress(
        address _newCoordinator
    ) external onlyOperator {

        emit CoordinatorChanged(coordinator, _newCoordinator);
        coordinator = _newCoordinator;
    }

    function updateClaimGeneratorAddress(
        address _newClaimGenerator
    ) external onlyOperator {

        emit ClaimGeneratorChanged(claimGenerator, _newClaimGenerator);
        claimGenerator = _newClaimGenerator;
    }

    function stake(
        uint256 _amount
    ) public {

        require(getCurrentWithdrawalTimelock(msg.sender) == 0, "cannot stake while in withdrawal");
        ROOK.safeTransferFrom(msg.sender, address(this), _amount);
        stakedAmount[msg.sender] += _amount;
        emit Staked(msg.sender, channelNonce[msg.sender], stakedAmount[msg.sender]);
    }

    function addClaimable(
        uint256 _amount
    ) public {

        ROOK.safeTransferFrom(msg.sender, address(this), _amount);
        totalClaimableAmount += _amount;
        emit AddedClaimable(_amount);
    }

    function adjustTotalClaimableAmountByStakeSpentChange(
        uint256 _oldStakeSpent, 
        uint256 _newStakeSpent
    ) internal {

        if (_newStakeSpent < _oldStakeSpent) {
            uint256 refundAmount = _oldStakeSpent - _newStakeSpent;
            require(totalClaimableAmount >= refundAmount, "not enough claimable rook to refund");
            totalClaimableAmount -= refundAmount;
        } else {
            totalClaimableAmount += _newStakeSpent - _oldStakeSpent;
        }
    }

    function settleSpentStake(
        StakeCommitment[] memory _commitments
    ) external {

        uint256 claimableRookToAccrue = 0;
        uint256 claimableRookToRefund = 0;
        for (uint i=0; i< _commitments.length; i++) {
            StakeCommitment memory commitment = _commitments[i];
            require(getCurrentWithdrawalTimelock(commitment.stakeAddress) == 0, "cannot settle while in withdrawal");
            require(commitment.stakeSpent <= stakedAmount[commitment.stakeAddress], "cannot spend more than is staked");
            require(commitment.stakeNonce > stakeNonce[commitment.stakeAddress], "stake nonce is too old");
            require(commitment.channelNonce == channelNonce[commitment.stakeAddress], "incorrect channel nonce");

            address recoveredStakeAddress = ECDSA.recover(
                ECDSA.toEthSignedMessageHash(stakeCommitmentHash(commitment)), 
                commitment.stakeAddressSignature);
            require(recoveredStakeAddress == commitment.stakeAddress, "recovered address is not the stake address");
            address recoveredCoordinatorAddress =  ECDSA.recover(
                ECDSA.toEthSignedMessageHash(stakeCommitmentHash(commitment)), 
                commitment.coordinatorSignature);
            require(recoveredCoordinatorAddress == coordinator, "recovered address is not the coordinator");

            if (commitment.stakeSpent < stakeSpent[commitment.stakeAddress]) {
                claimableRookToRefund += stakeSpent[commitment.stakeAddress] - commitment.stakeSpent;
            } else {
                claimableRookToAccrue += commitment.stakeSpent - stakeSpent[commitment.stakeAddress];
            }
            stakeNonce[commitment.stakeAddress] = commitment.stakeNonce;
            stakeSpent[commitment.stakeAddress] = commitment.stakeSpent;
        }
        adjustTotalClaimableAmountByStakeSpentChange(claimableRookToRefund, claimableRookToAccrue);
        emit Settled(claimableRookToRefund, claimableRookToAccrue);
    }

    function initiateTimelockedWithdrawal(
        StakeCommitment memory _commitment
    ) external {

        if (getCurrentWithdrawalTimelock(_commitment.stakeAddress) == 0) {
            require(msg.sender == _commitment.stakeAddress, "only stakeAddress can start the withdrawal process");
        }
        require(_commitment.stakeSpent <= stakedAmount[_commitment.stakeAddress], "cannot spend more than is staked");
        require(_commitment.stakeNonce >= stakeNonce[_commitment.stakeAddress], "stake nonce is too old");
        require(_commitment.channelNonce == channelNonce[_commitment.stakeAddress], "incorrect channel nonce");
        require(msg.sender == _commitment.stakeAddress || msg.sender == coordinator, 
            "only callable by stakeAdddress or coordinator");
        
        address recoveredStakeAddress = ECDSA.recover(
            ECDSA.toEthSignedMessageHash(stakeCommitmentHash(_commitment)), 
            _commitment.stakeAddressSignature);
        require(recoveredStakeAddress == _commitment.stakeAddress, "recovered address is not the stake address");
        address recoveredCoordinatorAddress =  ECDSA.recover(
            ECDSA.toEthSignedMessageHash(stakeCommitmentHash(_commitment)), 
            _commitment.coordinatorSignature);
        require(recoveredCoordinatorAddress == coordinator, "recovered address is not the coordinator");

        adjustTotalClaimableAmountByStakeSpentChange(stakeSpent[_commitment.stakeAddress], _commitment.stakeSpent);
        stakeNonce[_commitment.stakeAddress] = _commitment.stakeNonce;
        stakeSpent[_commitment.stakeAddress] = _commitment.stakeSpent;

        withdrawalTimelockTimestamp[
            withdrawalTimelockKey(
                _commitment.stakeAddress, 
                _commitment.stakeSpent, 
                _commitment.stakeNonce, 
                _commitment.channelNonce
            )] = block.timestamp + 7 days;

        emit TimelockedWithdrawalInitiated(
            _commitment.stakeAddress, 
            _commitment.stakeSpent, 
            _commitment.stakeNonce, 
            _commitment.channelNonce, 
            block.timestamp + 7 days);
    }

    function executeTimelockedWithdrawal(
        address _stakeAddress
    ) public {

        uint256 _channelNonce = channelNonce[_stakeAddress];
        require(getCurrentWithdrawalTimelock(_stakeAddress) > 0, "must initiate timelocked withdrawal first");
        require(block.timestamp > getCurrentWithdrawalTimelock(_stakeAddress), "still in withdrawal timelock");
        
        uint256 withdrawalAmount = stakedAmount[_stakeAddress] - stakeSpent[_stakeAddress];
        stakeNonce[_stakeAddress] = 0;
        stakeSpent[_stakeAddress] = 0;
        stakedAmount[_stakeAddress] = 0;
        channelNonce[_stakeAddress] += 1;

        ROOK.safeTransfer(_stakeAddress, withdrawalAmount);

        emit StakeWithdrawn(_stakeAddress, _channelNonce, withdrawalAmount);
    }

    function executeInstantWithdrawal(
        StakeCommitment memory _commitment
    ) external {

        require(msg.sender == _commitment.stakeAddress, "only stakeAddress can perform instant withdrawal");
        require(_commitment.stakeSpent <= stakedAmount[_commitment.stakeAddress], "cannot spend more than is staked");
        require(_commitment.stakeNonce >= stakeNonce[_commitment.stakeAddress], "stake nonce is too old");
        require(_commitment.channelNonce == channelNonce[_commitment.stakeAddress], "incorrect channel nonce");
        require(keccak256(_commitment.data) == keccak256(INSTANT_WITHDRAWAL_COMMITMENT_DATA), "incorrect data payload");

        address recoveredStakeAddress =  ECDSA.recover(
            ECDSA.toEthSignedMessageHash(stakeCommitmentHash(_commitment)), 
            _commitment.stakeAddressSignature);
        require(recoveredStakeAddress == _commitment.stakeAddress, "recovered address is not the stake address");
        address recoveredCoordinatorAddress =  ECDSA.recover(
            ECDSA.toEthSignedMessageHash(stakeCommitmentHash(_commitment)), 
            _commitment.coordinatorSignature);
        require(recoveredCoordinatorAddress == coordinator, "recovered address is not the coordinator");
        
        adjustTotalClaimableAmountByStakeSpentChange(stakeSpent[_commitment.stakeAddress], _commitment.stakeSpent);
        uint256 withdrawalAmount = stakedAmount[_commitment.stakeAddress] - _commitment.stakeSpent;
        stakeNonce[_commitment.stakeAddress] = 0;
        stakeSpent[_commitment.stakeAddress] = 0;
        stakedAmount[_commitment.stakeAddress] = 0;
        channelNonce[_commitment.stakeAddress] += 1;

        ROOK.safeTransfer(_commitment.stakeAddress, withdrawalAmount);

        emit StakeWithdrawn(_commitment.stakeAddress, _commitment.channelNonce, withdrawalAmount);
    }

    function claim(
        address _claimAddress, 
        uint256 _earningsToDate,
        bytes memory _claimGeneratorSignature
    ) external {

        require(_earningsToDate > userClaimedAmount[_claimAddress], "nothing to claim");

        address recoveredClaimGeneratorAddress = ECDSA.recover(
            ECDSA.toEthSignedMessageHash(claimCommitmentHash(_claimAddress, _earningsToDate)), 
            _claimGeneratorSignature);
        require(recoveredClaimGeneratorAddress == claimGenerator, "recoveredClaimGeneratorAddress is not the account manager");

        uint256 claimAmount = _earningsToDate - userClaimedAmount[_claimAddress];
        require(claimAmount <= totalClaimableAmount, "claim amount exceeds balance on contract");
        userClaimedAmount[_claimAddress] = _earningsToDate;
        totalClaimableAmount -= claimAmount;

        ROOK.safeTransfer(_claimAddress, claimAmount);
        emit Claimed(_claimAddress, claimAmount);
    }
}