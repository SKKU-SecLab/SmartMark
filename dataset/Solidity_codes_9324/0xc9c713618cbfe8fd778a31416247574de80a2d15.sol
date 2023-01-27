


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



pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}



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
}



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
}



pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}



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

}



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
}


pragma solidity ^0.8.0;





contract VestingMultiVault is AccessControl {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event Issued(
        address indexed beneficiary,
        uint256 indexed allocationId,
        uint256 amount,
        uint256 start,
        uint256 cliff,
        uint256 duration
    );

    event Released(
        address indexed beneficiary,
        uint256 indexed allocationId,
        uint256 amount,
        uint256 remaining
    );
    
    event Revoked(
        address indexed beneficiary,
        uint256 indexed allocationId,
        uint256 allocationAmount,
        uint256 revokedAmount
    );

    struct Allocation {
        uint256 start;
        uint256 cliff;
        uint256 duration;
        uint256 total;
        uint256 claimed;
        uint256 initial;
    }

    IERC20 public immutable token;

    mapping(address => uint256) public pendingAmount;

    mapping(address => Allocation[]) public userAllocations;

    bytes32 public constant ISSUER = keccak256("ISSUER");

    constructor(IERC20 _token) {
        token = _token;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ISSUER, msg.sender);
    }

    function issue(
        address _beneficiary,
        uint256 _amount,
        uint256 _startAt,
        uint256 _cliff,
        uint256 _duration,
        uint256 _initialPct
    ) public onlyRole(ISSUER) {

        require(token.allowance(msg.sender, address(this)) >= _amount, "Token allowance not sufficient");
        require(_beneficiary != address(0), "Cannot grant tokens to the zero address");
        require(_cliff <= _duration, "Cliff must not exceed duration");
        require(_initialPct <= 100, "Initial release percentage must be an integer 0 to 100 (inclusive)");

        token.safeTransferFrom(msg.sender, address(this), _amount);

        pendingAmount[_beneficiary] = pendingAmount[_beneficiary].add(_amount);

        userAllocations[_beneficiary].push(Allocation({
            claimed:    0,
            cliff:      _cliff,
            duration:   _duration,
            initial:    _amount.mul(_initialPct).div(100),
            start:      _startAt,
            total:      _amount
        }));
        
        emit Issued(
            _beneficiary,
            userAllocations[_beneficiary].length - 1,
            _amount,
            _startAt,
            _cliff,
            _duration
        );
    }
    
    function revoke(
        address _beneficiary,
        uint256 _id
    ) public onlyRole(ISSUER) {

        Allocation storage allocation = userAllocations[_beneficiary][_id];
        
        uint256 total = allocation.total;
        uint256 remainder = total.sub(allocation.claimed);

        pendingAmount[_beneficiary] = pendingAmount[_beneficiary].sub(remainder);

        allocation.claimed = total;
        
        token.safeTransfer(msg.sender, remainder);
        emit Revoked(
            _beneficiary,
            _id,
            total,
            remainder
        );
    }

    function release(
        address _beneficiary,
        uint256 _id
    ) public {

        Allocation storage allocation = userAllocations[_beneficiary][_id];

        uint256 amount = _releasableAmount(allocation);
        require(amount > 0, "Nothing to release");
        
        allocation.claimed = allocation.claimed.add(amount);

        pendingAmount[_beneficiary] = pendingAmount[_beneficiary].sub(amount);

        token.safeTransfer(_beneficiary, amount);

        emit Released(
            _beneficiary,
            _id,
            amount,
            allocation.total.sub(allocation.claimed)
        );
    }
    
    function releaseMultiple(
        address _beneficiary,
        uint256[] calldata _ids
    ) external {

        for (uint256 i = 0; i < _ids.length; i++) {
            release(_beneficiary, _ids[i]);
        }
    }
    
    function allocationCount(
        address _beneficiary
    ) public view returns (uint256 count) {

        return userAllocations[_beneficiary].length;
    }
    
    function releasableAmount(
        address _beneficiary,
        uint256 _id
    ) public view returns (uint256 amount) {

        Allocation storage allocation = userAllocations[_beneficiary][_id];
        return _releasableAmount(allocation);
    }
    
    function totalReleasableAount(
        address _beneficiary
    ) public view returns (uint256 amount) {

        for (uint256 i = 0; i < allocationCount(_beneficiary); i++) {
            amount = amount.add(releasableAmount(_beneficiary, i));
        }
        return amount;
    }
    
    function vestedAmount(
        address _beneficiary,
        uint256 _id
    ) public view returns (uint256) {

        Allocation storage allocation = userAllocations[_beneficiary][_id];
        return _vestedAmount(allocation);
    }
    
    function totalVestedAount(
        address _beneficiary
    ) public view returns (uint256 amount) {

        for (uint256 i = 0; i < allocationCount(_beneficiary); i++) {
            amount = amount.add(vestedAmount(_beneficiary, i));
        }
        return amount;
    }

    function _releasableAmount(
        Allocation storage allocation
    ) internal view returns (uint256) {

        return _vestedAmount(allocation).sub(allocation.claimed);
    }

    function _vestedAmount(
        Allocation storage allocation
    ) internal view returns (uint256 amount) {

        if (block.timestamp < allocation.start.add(allocation.cliff)) {
            amount = 0;
        } else if (block.timestamp >= allocation.start.add(allocation.duration)) {
            amount = allocation.total;
        } else {
            amount = allocation.initial.add(
                allocation.total
                    .sub(allocation.initial)
                    .sub(amount)
                    .mul(block.timestamp.sub(allocation.start))
                    .div(allocation.duration)
            );
        }
        
        return amount;
    }
}


pragma solidity ^0.8.5;

contract StakeRewarder is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    struct UserInfo {
        uint256 amount;     // Quantity of tokens the user has staked.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }
    
    struct PoolInfo {
        IERC20 token;            // Address of the token contract.
        uint256 weight;          // Weight points assigned to this pool.
        uint256 power;           // The multiplier for determining "staking power".
        uint256 total;           // Total number of tokens staked.
        uint256 accPerShare;     // Accumulated rewards per share (times 1e12).
        uint256 lastRewardBlock; // Last block where rewards were calculated.
    }
    
    VestingMultiVault public immutable vault;
    
    IERC20 public immutable rewardToken;
    uint256 public rewardPerBlock;
    uint256 public vestingCliff;
    uint256 public vestingDuration;
    
    PoolInfo[] public poolInfo;
    
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    
    mapping(address => uint256) public underpayment;
    
    uint256 public totalWeight = 0;
    
    uint256 public startBlock;
    
    event TokenAdded(address indexed token, uint256 weight, uint256 totalWeight);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event EmergencyReclaim(address indexed user, address token, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _vestingCliff,
        uint256 _vestingDuration,
        VestingMultiVault _vault
    ) {
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        vestingCliff = _vestingCliff;
        vestingDuration = _vestingDuration;
        
        vault = _vault;
        rewardToken = _rewardToken;
        
        _rewardToken.approve(address(_vault), 2**256 - 1);
    }

    function createPool(
        IERC20 _token,
        uint256 _weight,
        uint256 _power,
        bool _shouldUpdate
    ) public onlyOwner {

        if (_shouldUpdate) {
            pokePools();
        }

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalWeight = totalWeight.add(_weight);
        poolInfo.push(
            PoolInfo({
                token: _token,
                weight: _weight,
                power: _power,
                total: 0,
                accPerShare: 0,
                lastRewardBlock: lastRewardBlock
            })
        );
    }

    function updatePool(
        uint256 _pid,
        uint256 _weight,
        uint256 _power,
        bool _shouldUpdate
    ) public onlyOwner {

        if (_shouldUpdate) {
            pokePools();
        }
        
        totalWeight = totalWeight.sub(poolInfo[_pid].weight).add(
            _weight
        );

        poolInfo[_pid].weight = _weight;
        poolInfo[_pid].power = _power;
    }
    
    function setRewardPerBlock(
        uint256 _rewardPerBlock
    ) public onlyOwner {

        rewardPerBlock = _rewardPerBlock;
    }
    
    function setVestingRules(
        uint256 _duration,
        uint256 _cliff
    ) public onlyOwner {

        vestingDuration = _duration;
        vestingCliff = _cliff;
    }

    function duration(
        uint256 _from,
        uint256 _to
    ) public pure returns (uint256) {

        return _to.sub(_from);
    }
    
    function totalPendingRewards(
        address _beneficiary
    ) public view returns (uint256 total) {

        for (uint256 pid = 0; pid < poolInfo.length; pid++) {
            total = total.add(pendingRewards(pid, _beneficiary));
        }

        return total;
    }

    function pendingRewards(
        uint256 _pid,
        address _beneficiary
    ) public view returns (uint256 amount) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_beneficiary];
        uint256 accPerShare = pool.accPerShare;
        uint256 tokenSupply = pool.total;
        
        if (block.number > pool.lastRewardBlock && tokenSupply != 0) {
            uint256 reward = duration(pool.lastRewardBlock, block.number)
                .mul(rewardPerBlock)
                .mul(pool.weight)
                .div(totalWeight);

            accPerShare = accPerShare.add(
                reward.mul(1e12).div(tokenSupply)
            );
        }

        return user.amount.mul(accPerShare).div(1e12).sub(user.rewardDebt);
    }

    function totalPower(
        address _beneficiary
    ) public view returns (uint256 total) {

        for (uint256 pid = 0; pid < poolInfo.length; pid++) {
            total = total.add(power(pid, _beneficiary));
        }

        return total;
    }

    function power(
        uint256 _pid,
        address _beneficiary
    ) public view returns (uint256 amount) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_beneficiary];
        return pool.power.mul(user.amount);
    }

    function pokePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            pokePool(pid);
        }
    }

    function pokePool(
        uint256 _pid
    ) public {

        PoolInfo storage pool = poolInfo[_pid];

        if (block.number <= pool.lastRewardBlock) {
            return;
        }

        uint256 tokenSupply = pool.total;
        if (tokenSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 reward = duration(pool.lastRewardBlock, block.number)
            .mul(rewardPerBlock)
            .mul(pool.weight)
            .div(totalWeight);

        pool.accPerShare = pool.accPerShare.add(
            reward.mul(1e12).div(tokenSupply)
        );

        pool.lastRewardBlock = block.number;
    }

    function claim(
        uint256 _pid,
        address _beneficiary
    ) public {

        pokePool(_pid);

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_beneficiary];

        _claim(pool, user, _beneficiary);
    }
    
    function claimMultiple(
        uint256[] calldata _pids,
        address _beneficiary
    ) external {

        for (uint256 i = 0; i < _pids.length; i++) {
            claim(_pids[i], _beneficiary);
        }
    }

    function deposit(
        uint256 _pid,
        uint256 _amount
    ) public {

        require(_amount > 0, "deposit: only non-zero amounts allowed");
        
        pokePool(_pid);

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        _claim(pool, user, msg.sender);
        
        pool.token.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        pool.total = pool.total.add(_amount);
        
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accPerShare).div(1e12);
        
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(
        uint256 _pid,
        uint256 _amount
    ) public {

        require(_amount > 0, "withdraw: only non-zero amounts allowed");

        pokePool(_pid);
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        require(user.amount >= _amount, "withdraw: amount too large");
        
        _claim(pool, user, msg.sender);

        pool.total = pool.total.sub(_amount);
        
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accPerShare).div(1e12);
        
        pool.token.safeTransfer(address(msg.sender), _amount);
        
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(
        uint256 _pid
    ) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        
        user.amount = 0;
        user.rewardDebt = 0;
        underpayment[msg.sender] = 0;

        pool.total = pool.total.sub(amount);
        
        pool.token.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }
    
    function emergencyReclaim(
        IERC20 _token,
        uint256 _amount
    ) public onlyOwner {

        if (_amount == 0) {
            _amount = _token.balanceOf(address(this));
        }
        
        _token.transfer(msg.sender, _amount);
        emit EmergencyReclaim(msg.sender, address(_token), _amount);
    }
    
    function poolLength() external view returns (uint256 length) {

        return poolInfo.length;
    }
    
    function _claim(
        PoolInfo storage pool,
        UserInfo storage user,
        address to
    ) internal {

        if (user.amount > 0) {
            uint256 pending = user.amount
                .mul(pool.accPerShare)
                .div(1e12)
                .sub(user.rewardDebt)
                .add(underpayment[to]);
            
            uint256 payout = _safelyDistribute(to, pending);
            if (payout < pending) {
                underpayment[to] = pending.sub(payout);
            } else {
                underpayment[to] = 0;
            }
            
            emit Claim(to, payout);
        }
    }
    
    function _safelyDistribute(
        address _to,
        uint256 _amount
    ) internal returns (uint256 amount) {

        uint256 available = rewardToken.balanceOf(address(this));
        amount = _amount > available ? available : _amount;
        
        rewardToken.transfer(_to, amount);
        vault.issue(
            _to,                // address _beneficiary,
            _amount,            // uint256 _amount,
            block.timestamp,    // uint256 _startAt,
            vestingCliff,       // uint256 _cliff,
            vestingDuration,    // uint256 _duration,
            0                   // uint256 _initialPct
        );
        
        return amount;
    }
}