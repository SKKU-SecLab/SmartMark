
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
}

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;


abstract contract Multicall {
    function multicall(bytes[] calldata data) external returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = Address.functionDelegateCall(address(this), data[i]);
        }
        return results;
    }
}

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
}


pragma solidity ^0.8.4;


interface IERC677Receiver {

    function onTokenTransfer(address _sender, uint _value, bytes calldata _data) external;

}

contract Staking is Ownable, Multicall, IERC677Receiver, ReentrancyGuard {

    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        IERC20 lpToken;
        uint256 accRewardPerShare;
        uint256 lastRewardBlock;
        uint256 allocPoint;
    }


    IERC20 public rewardToken;
    address public rewardOwner;

    PoolInfo[] public poolInfo;

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;

    uint256 public rewardPerBlock = 0;
    uint256 private constant ACC_PRECISION = 1e12;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event LogPoolAddition(uint256 indexed pid, uint256 allocPoint, IERC20 indexed lpToken);
    event LogSetPool(uint256 indexed pid, uint256 allocPoint);
    event LogUpdatePool(uint256 indexed pid, uint256 lastRewardBlock, uint256 lpSupply, uint256 accRewardPerShare);

    constructor(IERC20 _rewardToken, address _rewardOwner, uint256 _rewardPerBlock) Ownable() {
        rewardToken = _rewardToken;
        rewardOwner = _rewardOwner;
        rewardPerBlock = _rewardPerBlock;
    }

    function setRewardToken(IERC20 _rewardToken) public onlyOwner {

        rewardToken = _rewardToken;
    }

    function setRewardOwner(address _rewardOwner) public onlyOwner {

        rewardOwner = _rewardOwner;
    }

    function setRewardsPerBlock(uint256 _rewardPerBlock) public onlyOwner {

        rewardPerBlock = _rewardPerBlock;
    }

    function poolLength() public view returns (uint256 pools) {

        pools = poolInfo.length;
    }

    mapping(IERC20 => bool) public poolExistence;

    function addPool(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {

        require(poolExistence[_lpToken] == false, "Staking: duplicated pool");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint + _allocPoint;

        poolExistence[_lpToken] = true;
        poolInfo.push(PoolInfo({
            lpToken : _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: block.number,
            accRewardPerShare: 0
        }));

        emit LogPoolAddition(poolInfo.length - 1, _allocPoint, _lpToken);
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;

        emit LogSetPool(_pid, _allocPoint);
    }

    function pendingRewards(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blocks = block.number - pool.lastRewardBlock;
            uint256 reward = (blocks * rewardPerBlock * pool.allocPoint) / totalAllocPoint;
            accRewardPerShare = accRewardPerShare + ((reward * ACC_PRECISION) / lpSupply);
        }
        uint256 accumulatedReward = (user.amount * accRewardPerShare) / ACC_PRECISION;
        return accumulatedReward - user.rewardDebt;
    }

    function massUpdatePools() public {

        for (uint256 i = 0; i < poolInfo.length; ++i) {
            updatePool(i);
        }
    }

    function massUpdatePoolsByIds(uint256[] calldata pids) external {

        for (uint256 i = 0; i < pids.length; ++i) {
            updatePool(pids[i]);
        }
    }

    function updatePool(uint256 pid) public {

        PoolInfo storage pool = poolInfo[pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 blocks = block.number - pool.lastRewardBlock;
        uint256 reward = (blocks * rewardPerBlock * pool.allocPoint) / totalAllocPoint;
        pool.accRewardPerShare = pool.accRewardPerShare + ((reward * ACC_PRECISION) / lpSupply);
        pool.lastRewardBlock = block.number;

        emit LogUpdatePool(pid, pool.lastRewardBlock, lpSupply, pool.accRewardPerShare);
    }

    function deposit(uint256 pid, uint256 amount, address to) public nonReentrant {

        updatePool(pid);
        PoolInfo memory pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        uint256 accumulatedReward = (user.amount * pool.accRewardPerShare) / ACC_PRECISION;
        uint256 pendingReward = accumulatedReward - user.rewardDebt;

        if (pendingReward > 0) {
            rewardToken.safeTransferFrom(rewardOwner, to, pendingReward);
        }

        if (amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), amount);
            user.amount = user.amount + amount;
        }
        user.rewardDebt = (user.amount * pool.accRewardPerShare) / ACC_PRECISION;

        emit Deposit(msg.sender, pid, amount, to);
    }

    function withdraw(uint256 pid, uint256 amount, address to) public nonReentrant {

        updatePool(pid);
        PoolInfo memory pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        require(user.amount >= amount, "withdraw: not good");

        uint256 accumulatedReward = (user.amount * pool.accRewardPerShare) / ACC_PRECISION;
        uint256 pendingReward = accumulatedReward - user.rewardDebt;
        if (pendingReward > 0) {
            rewardToken.safeTransferFrom(rewardOwner, to, pendingReward);
        }

        if (amount > 0) {
            user.amount = user.amount - amount;
            pool.lpToken.safeTransfer(to, amount);
        }
        user.rewardDebt = (user.amount * pool.accRewardPerShare) / ACC_PRECISION;

        emit Withdraw(msg.sender, pid, amount, to);
    }

    function harvest(uint256 pid, address to) public {

        updatePool(pid);
        PoolInfo memory pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        uint256 accumulatedReward = (user.amount * pool.accRewardPerShare) / ACC_PRECISION;
        uint256 pendingReward = accumulatedReward - user.rewardDebt;
        if (pendingReward > 0) {
            rewardToken.safeTransferFrom(rewardOwner, to, pendingReward);
        }
        user.rewardDebt = accumulatedReward;

        emit Harvest(msg.sender, pid, pendingReward);
    }

    function emergencyWithdraw(uint256 pid, address to) public {

        PoolInfo memory pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        uint256 amount = user.amount;

        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(to, amount);

        emit EmergencyWithdraw(msg.sender, pid, amount, to);
    }

    function onTokenTransfer(address to, uint amount, bytes calldata _data) external override {

        uint pid = 0;
        require(msg.sender == address(rewardToken), "onTokenTransfer: can only be called by rewardToken");
        require(msg.sender == address(poolInfo[pid].lpToken), "onTokenTransfer: pool 0 needs to be a rewardToken pool");
        if (amount > 0) {
            updatePool(pid);
            PoolInfo memory pool = poolInfo[pid];
            UserInfo storage user = userInfo[pid][to];

            user.amount = user.amount + amount;
            user.rewardDebt = user.rewardDebt + (amount * pool.accRewardPerShare) / ACC_PRECISION;

            emit Deposit(msg.sender, pid, amount, to);
        }
    }
}
