
pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


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

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

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
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
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
}pragma solidity 0.6.2;


contract BasicMetaTransaction {

    using SafeMath for uint256;

    event MetaTransactionExecuted(
        address userAddress,
        address payable relayerAddress,
        bytes functionSignature
    );
    mapping(address => uint256) private nonces;

    function getChainID() public pure returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function executeMetaTransaction(
        address userAddress,
        bytes calldata functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) external payable returns (bytes memory) {

        require(
            verify(
                userAddress,
                nonces[userAddress],
                getChainID(),
                functionSignature,
                sigR,
                sigS,
                sigV
            ),
            "Signer and signature do not match"
        );
        nonces[userAddress] = nonces[userAddress].add(1);

        (bool success, bytes memory returnData) =
            address(this).call(
                abi.encodePacked(functionSignature, userAddress)
            );

        require(success, "Function call not successful");
        emit MetaTransactionExecuted(
            userAddress,
            msg.sender,
            functionSignature
        );
        return returnData;
    }

    function getNonce(address user) external view returns (uint256 nonce) {

        nonce = nonces[user];
    }

    function prefixed(bytes32 hash) internal pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function verify(
        address owner,
        uint256 nonce,
        uint256 chainID,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public view returns (bool) {

        bytes32 hash =
            prefixed(
                keccak256(
                    abi.encodePacked(nonce, this, chainID, functionSignature)
                )
            );
        address signer = ecrecover(hash, sigV, sigR, sigS);
        require(signer != address(0), "Invalid signature");
        return (owner == signer);
    }

    function msgSender() internal view returns (address sender) {

        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            return msg.sender;
        }
    }
}// MIT
pragma solidity 0.6.2;


contract MovieVotingMasterChef is BasicMetaTransaction, AccessControl {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bytes32 public constant ROLE_ADMIN = keccak256("ROLE_ADMIN");

    struct UserInfo {
        uint256 amount; // how many Stars the user has provided.
        uint256 rewardDebt; // reward debt. See explaination below.
        uint256 penalizedRewards; // rewards that got penalized when users withdraw prematurely
    }

    struct PoolInfo {
        uint256 lastRewardBlock; // Last block number that Stars distribution occurs.
        uint256 accStarsPerShare; // Accumulated Stars per share, times ACC_STARS_PRECISION. See below.
        uint256 poolSupply; // the the total amount of Stars in the pool.
        uint256 rewardAmount; // the amount of Stars to give out as rewards.
        uint256 rewardAmountPerBlock; // the amount of Stars to give out as rewards per block.
        uint256 startBlock; // staking start block.
        uint256 endBlock; // staking end block.
    }

    bool public initialized;
    uint256 private constant ACC_STARS_PRECISION = 1e12;
    address public movieVoting;
    IERC20 public stars;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event RewardsCollected(address indexed user, uint256 indexed pid);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event WithdrawPartial(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    modifier onlyAdmin {

        require(hasRole(ROLE_ADMIN, msg.sender), "Sender is not admin");
        _;
    }

    modifier isInitialized {

        require(initialized, "Not initialized");
        _;
    }

    constructor(address starsAddress, address _admin) public {
        _setupRole(ROLE_ADMIN, _admin);
        _setRoleAdmin(ROLE_ADMIN, ROLE_ADMIN);

        stars = IERC20(starsAddress);
    }

    function init(address _movieVotingAddress) external onlyAdmin {

        require(!initialized, "Already initialized");
        movieVoting = _movieVotingAddress;
        _setupRole(ROLE_ADMIN, _movieVotingAddress);

        initialized = true;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _rewardAmount,
        bool _withUpdate
    ) external onlyAdmin isInitialized {

        require(
            block.number < _startBlock,
            "Start block number must be a future block"
        );

        if (_withUpdate) {
            massUpdatePools();
        }
        stars.transferFrom(msgSender(), address(this), _rewardAmount);

        poolInfo.push(
            PoolInfo({
                lastRewardBlock: _startBlock,
                accStarsPerShare: 0,
                poolSupply: 0,
                rewardAmount: _rewardAmount,
                rewardAmountPerBlock: _rewardAmount.div(
                    _endBlock.sub(_startBlock)
                ),
                startBlock: _startBlock,
                endBlock: _endBlock
            })
        );
    }

    function pendingStars(uint256 _pid, address _user)
        external
        view
        isInitialized
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        if (pool.poolSupply == 0 || block.number < pool.startBlock) {
            return 0;
        }

        uint256 currRateEndStarsPerShare = accStarsPerShareAtCurrRate(
            uint256(block.number).sub(pool.startBlock),
            pool.rewardAmountPerBlock,
            pool.poolSupply,
            pool.startBlock,
            pool.endBlock
        );
        uint256 currRateStartStarsPerShare = accStarsPerShareAtCurrRate(
            pool.lastRewardBlock.sub(pool.startBlock),
            pool.rewardAmountPerBlock,
            pool.poolSupply,
            pool.startBlock,
            pool.endBlock
        );
        uint256 starsReward = (
            currRateEndStarsPerShare.sub(currRateStartStarsPerShare)
        );

        uint256 pendingAccStarsPerShare = pool.accStarsPerShare.add(
            starsReward
        );
        return
            user
                .amount
                .mul(pendingAccStarsPerShare)
                .div(ACC_STARS_PRECISION)
                .sub(user.rewardDebt)
                .add(user.penalizedRewards);
    }

    function accStarsPerShareAtCurrRate(
        uint256 blocks,
        uint256 rewardAmountPerBlock,
        uint256 poolSupply,
        uint256 startBlock,
        uint256 endBlock
    ) public pure returns (uint256) {

        if (blocks > endBlock.sub(startBlock)) {
            return
                rewardAmountPerBlock
                    .mul(endBlock.sub(startBlock))
                    .mul(ACC_STARS_PRECISION)
                    .div(poolSupply);
        } else {
            return
                blocks.mul(rewardAmountPerBlock).mul(ACC_STARS_PRECISION).div(
                    poolSupply
                );
        }
    }

    function starsPerBlock(uint256 pid) external view returns (uint256 amount) {

        return poolInfo[pid].rewardAmountPerBlock;
    }

    function updatePool(uint256 _pid) public isInitialized {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        if (pool.poolSupply != 0) {
            uint256 currRateEndStarsPerShare = accStarsPerShareAtCurrRate(
                uint256(block.number).sub(pool.startBlock),
                pool.rewardAmountPerBlock,
                pool.poolSupply,
                pool.startBlock,
                pool.endBlock
            );
            uint256 currRateStartStarsPerShare = accStarsPerShareAtCurrRate(
                pool.lastRewardBlock.sub(pool.startBlock),
                pool.rewardAmountPerBlock,
                pool.poolSupply,
                pool.startBlock,
                pool.endBlock
            );
            uint256 starsReward = (
                currRateEndStarsPerShare.sub(currRateStartStarsPerShare)
            );

            pool.accStarsPerShare = pool.accStarsPerShare.add(starsReward);
        }
        pool.lastRewardBlock = block.number;
    }

    function massUpdatePools() public isInitialized {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _staker
    ) external onlyAdmin isInitialized {

        PoolInfo storage pool = poolInfo[_pid];

        require(block.number >= pool.startBlock, "Deposit not started");

        UserInfo storage user = userInfo[_pid][_staker];
        updatePool(_pid);

        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.rewardDebt.add(
            (_amount.mul(pool.accStarsPerShare).div(ACC_STARS_PRECISION))
        );
        pool.poolSupply = pool.poolSupply.add(_amount);

        stars.safeTransferFrom(_staker, address(this), _amount);

        emit Deposit(_staker, _pid, _amount);
    }

    function withdraw(uint256 _pid, address _staker)
        external
        onlyAdmin
        isInitialized
    {

        PoolInfo storage pool = poolInfo[_pid];
        require(
            block.number > pool.endBlock,
            "Cannot withdraw before voting period ends"
        );
        UserInfo storage user = userInfo[_pid][_staker];

        updatePool(_pid);

        uint256 _amount = user.amount;
        uint256 _penalizedRewards = user.penalizedRewards;

        uint256 pending = user
        .amount
        .mul(pool.accStarsPerShare)
        .div(ACC_STARS_PRECISION)
        .sub(user.rewardDebt);

        user.amount = 0;
        user.rewardDebt = 0;
        user.penalizedRewards = 0;
        pool.poolSupply = pool.poolSupply.sub(_amount);

        safeStarsTransfer(_staker, pending.add(_amount).add(_penalizedRewards));

        emit Withdraw(_staker, _pid, _amount);
    }

    function withdrawPartial(
        uint256 _pid,
        uint256 _amount,
        address _staker
    ) external onlyAdmin isInitialized {

        PoolInfo storage pool = poolInfo[_pid];

        UserInfo storage user = userInfo[_pid][_staker];

        require(user.amount >= _amount, "Insufficient STARS to withdraw");

        updatePool(_pid);

        uint256 pending = user
        .amount
        .mul(pool.accStarsPerShare)
        .div(ACC_STARS_PRECISION)
        .sub(user.rewardDebt);

        uint256 oldUserAmount = user.amount;

        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            safeStarsTransfer(_staker, _amount);
            user.penalizedRewards = user
            .penalizedRewards
            .mul(user.amount)
            .div(oldUserAmount)
            .add(pending.mul(user.amount).div(oldUserAmount));
            pool.poolSupply = pool.poolSupply.sub(_amount);
        }

        user.rewardDebt = (
            user.amount.mul(pool.accStarsPerShare).div(ACC_STARS_PRECISION)
        );

        emit WithdrawPartial(_staker, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid, address _staker)
        external
        onlyAdmin
        isInitialized
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_staker];

        stars.safeTransfer(_staker, user.amount);

        pool.poolSupply = pool.poolSupply.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;

        emit EmergencyWithdraw(_staker, _pid, user.amount);
    }

    function safeStarsTransfer(address _to, uint256 _amount) internal {

        uint256 starsBal = stars.balanceOf(address(this));
        if (_amount > starsBal) {
            stars.transfer(_to, starsBal);
        } else {
            stars.transfer(_to, _amount);
        }
    }
}