
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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

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

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
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


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
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

library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity ^0.8.6;


contract Holding is AccessControl, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SERVICE_ROLE = keccak256("SERVICE_ROLE");

    enum StakeType {
        threeMonth,
        sixMonth,
        twelveMonth
    }

    struct Staker {
        uint256 amount;
        uint256 updatedAt;
        uint256 rewardProduced;
        uint256 rewardClaimed;
    }

    struct StakeInfo {
        uint256 distributionTime;
        uint256 percent;
        uint256 totalStaked;
        uint256 totalDistributed;
        uint256 minStake;
        uint256 maxStake;
    }

    bool claimEnabled;
    IERC20 public token;
    uint256 public startTime;
 
    uint256 referralClaimed;

    mapping(StakeType => mapping(address => Staker)) public stakes;
    mapping(StakeType => StakeInfo) public stakeInfo;
    mapping(bytes32 => bool) referralPayments;
    mapping(address => uint256) usersReferralClaimed;
    mapping(address => string) accounts;

    event Staked(
        uint256 amount,
        uint256 time,
        address indexed owner,
        StakeType stakeType,
        string account
    );
    event Claimed(
        uint256 amount,
        uint256 time,
        address indexed owner,
        StakeType stakeType,
        string account
    );
    event ReferralClaimed(
        uint256 amount,
        uint256 time,
        address indexed owner,
        string account
    );
    event Unstaked(
        uint256 amount,
        uint256 time,
        address indexed owner,
        StakeType stakeType,
        string account
    );

    constructor(
        uint256 _startTime,
        address _token,
        uint256[3] memory distributionTime,
        uint256[3] memory percent,
        uint256[3] memory minStake,
        uint256[3] memory maxStake
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(SERVICE_ROLE, ADMIN_ROLE);
        startTime = _startTime;
        token = IERC20(_token);
        for (uint256 i = 0; i < 3; i++) {
            stakeInfo[StakeType(i)].distributionTime = distributionTime[i];
            stakeInfo[StakeType(i)].percent = percent[i];
            stakeInfo[StakeType(i)].minStake = minStake[i];
            stakeInfo[StakeType(i)].maxStake = maxStake[i];
        }
        claimEnabled = true;
    }

    modifier onlyAdmin() {

        require(
            hasRole(ADMIN_ROLE, msg.sender),
            "DAOvc Staking: you should have an admin role"
        );
        _;
    }

    function stake(
        StakeType stakeType,
        uint256 amount,
        string memory account
    ) external nonReentrant {

        require(
            block.timestamp > startTime,
            "DAOvc Staking: Staking time has not come yet"
        );
        require(
            block.timestamp <=
                startTime + stakeInfo[stakeType].distributionTime,
            "DAOvc Staking: Staking time is over"
        );
        require(
            amount >= stakeInfo[stakeType].minStake,
            "DAOvc Staking: Staking amount is less then required"
        );
        Staker storage staker = stakes[stakeType][msg.sender];
        require(
            stakeInfo[stakeType].totalStaked + amount <=
                stakeInfo[stakeType].maxStake,
            "DAOvc Staking: Staking amount is more then required"
        );
        if (staker.amount == 0) {
            accounts[msg.sender] = account;
            staker.updatedAt = block.timestamp;
        }

        stakeInfo[stakeType].totalStaked += amount;
        staker.rewardProduced = produced(stakeType, msg.sender);
        staker.amount += amount;
        staker.updatedAt = block.timestamp;
        token.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(
            amount,
            block.timestamp,
            msg.sender,
            stakeType,
            accounts[msg.sender]
        );
    }

    function unstake(StakeType stakeType, uint256 amount)
        external
        nonReentrant
    {

        Staker storage staker = stakes[stakeType][msg.sender];
        require(
            block.timestamp >=
                startTime + stakeInfo[stakeType].distributionTime,
            "DAOvc Staking: It's not time to unstake tokens yet"
        );
        require(
            amount <= staker.amount,
            "DAOvc Staking: Not enough tokens to unstake"
        );
        stakeInfo[stakeType].totalStaked -= amount;
        staker.rewardProduced = produced(stakeType, msg.sender);
        staker.amount -= amount;
        staker.updatedAt = block.timestamp;
        token.safeTransfer(msg.sender, amount);
        emit Unstaked(
            amount,
            block.timestamp,
            msg.sender,
            stakeType,
            accounts[msg.sender]
        );
    }

    function claim(StakeType stakeType) external nonReentrant {

        require(claimEnabled, "DAOvc Staking: reward is not possible for claiming");
        Staker storage staker = stakes[stakeType][msg.sender];
        staker.rewardProduced = produced(stakeType, msg.sender);
        uint256 reward = staker.rewardProduced - staker.rewardClaimed;
        require(reward > 0, "DAOvc Staking: Nothing to claim");
        stakeInfo[stakeType].totalDistributed += reward;
        staker.rewardClaimed = staker.rewardProduced;
        staker.updatedAt = block.timestamp;
        token.safeTransfer(msg.sender, reward);
        emit Claimed(
            reward,
            block.timestamp,
            msg.sender,
            stakeType,
            accounts[msg.sender]
        );
    }

    function produced(StakeType stakeType, address _staker)
        private
        view
        returns (uint256 reward)
    {

        Staker storage staker = stakes[stakeType][_staker];
        reward =
            staker.rewardProduced +
            ((stakeInfo[stakeType].percent * staker.amount) *
                (block.timestamp - staker.updatedAt)) /
            stakeInfo[stakeType].distributionTime /
            1e20;
        return reward;
    }

    function claimReferal(
        bytes32 hashedMessage,
        uint256 amount,
        uint256 sequence,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address from
    ) external nonReentrant {

        require(
            hasRole(SERVICE_ROLE, hashedMessage.recover(v, r, s)),
            "DAOvc Staking: Validator address is invalid or signature is faked"
        );
        bytes32 message = keccak256(
            abi.encodePacked(msg.sender, amount, sequence)
        );
        require(
            message.toEthSignedMessageHash() == hashedMessage,
            "DAOvc Staking: Incorrect hashed message"
        );
        require(
            !referralPayments[message],
            "DAOvc Staking: Duplicate transaction"
        );
        referralPayments[message] = true;
        referralClaimed += amount;
        usersReferralClaimed[msg.sender] += amount;
        IERC20(from).safeTransfer(msg.sender, amount);
        emit ReferralClaimed(
            amount,
            block.timestamp,
            msg.sender,
            accounts[msg.sender]
        );
    }

    function setStartTime(uint256 _startTime) external onlyAdmin {

        require(
            block.timestamp < _startTime,
            "DAOvc Staking: Staking time has already come"
        );
        startTime = _startTime;
    }

    function updateDistributionTime(
        StakeType stakeType,
        uint256 distributionTime
    ) external onlyAdmin {

        stakeInfo[stakeType].distributionTime = distributionTime;
    }

    function updatePercent(StakeType stakeType, uint256 percent)
        external
        onlyAdmin
    {

        stakeInfo[stakeType].percent = percent;
    }

    function updateTotalStaked(StakeType stakeType, uint256 _totalStaked)
        external
        onlyAdmin
    {

        stakeInfo[stakeType].totalStaked = _totalStaked;
    }

    function updateTotalDistributed(
        StakeType stakeType,
        uint256 _totalDistributed
    ) external onlyAdmin {

        stakeInfo[stakeType].totalDistributed = _totalDistributed;
    }
    
    function updateMinStake(StakeType stakeType, uint256 _amount)
        external
        onlyAdmin
    {

        stakeInfo[stakeType].minStake = _amount;
    }

    function updateMaxStake(StakeType stakeType, uint256 _amount)
        external
        onlyAdmin
    {

        stakeInfo[stakeType].maxStake = _amount;
    }
    
    function updateStakerInfo(
        StakeType stakeType,
        address user,
        uint256 amount,
        uint256 updatedAt,
        uint256 rewardProduced,
        uint256 rewardClaimed,
        uint256 _referralClaimed,
        string memory account
    ) external onlyAdmin {

        stakes[stakeType][user] = Staker({
            amount: amount,
            updatedAt: updatedAt,
            rewardProduced: rewardProduced,
            rewardClaimed: rewardClaimed
        });
        accounts[user] = account;
        usersReferralClaimed[msg.sender] = _referralClaimed;
    }

    function removeLiquidity(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyAdmin {

        require(_token != address(0), "Invalid token address");
        require(_to != address(0), "Invalid recipient address");
        IERC20(_token).safeTransfer(_to, _amount);
    }

    function claimControl(
        bool _enableClaim
    ) external onlyAdmin {

        claimEnabled = _enableClaim;
    }
    
    function getClaim(StakeType stakeType, address user)
        public
        view
        returns (uint256 reward)
    {

        return
            produced(stakeType, user) - stakes[stakeType][user].rewardClaimed;
    }    

    function getStakingInfo(
        StakeType _stakeType
    ) external view returns(
        StakeInfo memory staking_
    ) {

        return staking_ = stakeInfo[_stakeType];
    }
    function getInfoByAddress(StakeType stakeType, address user)
        external
        view
        returns (
            uint256 staked,
            uint256 availableClaim,
            uint256 rewardClaimed,
            uint256 referralClaimed_,
            uint256 balance
        )
    {

        return (
            stakes[stakeType][user].amount,
            getClaim(stakeType, user),
            stakes[stakeType][user].rewardClaimed,
            usersReferralClaimed[user],
            token.balanceOf(user)
        );
    }
}