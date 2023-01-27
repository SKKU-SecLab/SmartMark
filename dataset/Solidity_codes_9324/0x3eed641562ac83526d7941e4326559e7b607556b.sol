
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
}// GPL-3.0
pragma solidity ^0.8.0;


contract LPFarming is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using Address for address;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event ClaimAll(address indexed user, uint256 amount);

    struct UserInfo {
        uint256 amount;
        uint256 lastAccRewardPerShare;
    }

    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }

    struct EpochInfo {
        uint256 startBlock;
        uint256 endBlock;
        uint256 rewardPerBlock;
    }

    IERC20 public immutable jpeg;

    EpochInfo public epoch;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint;

    mapping(address => uint256) private userRewards;
    mapping(address => bool) public whitelistedContracts;

    constructor(address _jpeg) {
        jpeg = IERC20(_jpeg);
    }

    modifier noContract(address _account) {

        require(
            !_account.isContract() || whitelistedContracts[_account],
            "Contracts aren't allowed to farm"
        );
        _;
    }

    function setContractWhitelisted(address _contract, bool _isWhitelisted)
        external
        onlyOwner
    {

        whitelistedContracts[_contract] = _isWhitelisted;
    }

    function newEpoch(
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _rewardPerBlock
    ) external onlyOwner {

        require(_startBlock >= block.number, "Invalid start block");
        require(_endBlock > _startBlock, "Invalid end block");
        require(_rewardPerBlock > 0, "Invalid reward per block");

        _massUpdatePools();

        uint256 remainingRewards = epoch.rewardPerBlock *
            (epoch.endBlock - _blockNumber());
        uint256 newRewards = _rewardPerBlock * (_endBlock - _startBlock);

        epoch.startBlock = _startBlock;
        epoch.endBlock = _endBlock;
        epoch.rewardPerBlock = _rewardPerBlock;

        if (remainingRewards > newRewards) {
            jpeg.safeTransfer(msg.sender, remainingRewards - newRewards);
        } else if (remainingRewards < newRewards) {
            jpeg.safeTransferFrom(
                msg.sender,
                address(this),
                newRewards - remainingRewards
            );
        }
    }

    function add(uint256 _allocPoint, IERC20 _lpToken) external onlyOwner {

        _massUpdatePools();

        uint256 lastRewardBlock = _blockNumber();
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accRewardPerShare: 0
            })
        );
    }

    function set(uint256 _pid, uint256 _allocPoint) external onlyOwner {

        _massUpdatePools();

        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint - prevAllocPoint + _allocPoint;
        }
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function pendingReward(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accRewardPerShare = pool.accRewardPerShare;
        uint256 blockNumber = _blockNumber();
        uint256 lastRewardBlock = _normalizeBlockNumber(pool.lastRewardBlock);
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (blockNumber > lastRewardBlock && lpSupply != 0) {
            uint256 reward = ((blockNumber - lastRewardBlock) *
                epoch.rewardPerBlock *
                1e36 *
                pool.allocPoint) / totalAllocPoint;
            accRewardPerShare += reward / lpSupply;
        }
        return
            userRewards[_user] +
            (user.amount * (accRewardPerShare - user.lastAccRewardPerShare)) /
            1e36;
    }

    function deposit(uint256 _pid, uint256 _amount)
        external
        noContract(msg.sender)
    {

        require(_amount > 0, "invalid_amount");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        _updatePool(_pid);
        _withdrawReward(_pid);

        pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
        user.amount = user.amount + _amount;

        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount)
        external
        noContract(msg.sender)
    {

        require(_amount > 0, "invalid_amount");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "insufficient_amount");

        _updatePool(_pid);
        _withdrawReward(_pid);

        user.amount -= _amount;
        pool.lpToken.safeTransfer(address(msg.sender), _amount);

        emit Withdraw(msg.sender, _pid, _amount);
    }

    function _blockNumber() internal view returns (uint256) {

        return _normalizeBlockNumber(block.number);
    }

    function _normalizeBlockNumber(uint256 blockNumber)
        internal
        view
        returns (uint256)
    {

        if (blockNumber < epoch.startBlock) return epoch.startBlock;

        if (blockNumber > epoch.endBlock) return epoch.endBlock;

        return blockNumber;
    }

    function _massUpdatePools() internal {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            _updatePool(pid);
        }
    }

    function _updatePool(uint256 _pid) internal {

        PoolInfo storage pool = poolInfo[_pid];
        if (pool.allocPoint == 0) {
            return;
        }

        uint256 blockNumber = _blockNumber();
        uint256 lastRewardBlock = _normalizeBlockNumber(pool.lastRewardBlock);
        if (blockNumber <= lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = blockNumber;
            return;
        }
        uint256 reward = ((blockNumber - lastRewardBlock) *
            epoch.rewardPerBlock *
            1e36 *
            pool.allocPoint) / totalAllocPoint;
        pool.accRewardPerShare = pool.accRewardPerShare + reward / lpSupply;
        pool.lastRewardBlock = blockNumber;
    }

    function _withdrawReward(uint256 _pid) internal returns (uint256) {

        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 pending = (user.amount *
            (poolInfo[_pid].accRewardPerShare - user.lastAccRewardPerShare)) /
            1e36;
        if (pending > 0) {
            userRewards[msg.sender] += pending;
        }

        user.lastAccRewardPerShare = poolInfo[_pid].accRewardPerShare;

        return pending;
    }

    function claim(uint256 _pid) external nonReentrant noContract(msg.sender) {

        _updatePool(_pid);
        _withdrawReward(_pid);

        uint256 rewards = userRewards[msg.sender];
        require(rewards > 0, "no_reward");

        jpeg.safeTransfer(msg.sender, rewards);
        userRewards[msg.sender] = 0;

        emit Claim(msg.sender, _pid, rewards);
    }

    function claimAll() external nonReentrant noContract(msg.sender) {

        for (uint256 i = 0; i < poolInfo.length; i++) {
            _updatePool(i);
            _withdrawReward(i);
        }

        uint256 rewards = userRewards[msg.sender];
        require(rewards > 0, "no_reward");

        jpeg.safeTransfer(msg.sender, rewards);
        userRewards[msg.sender] = 0;

        emit ClaimAll(msg.sender, rewards);
    }

    function renounceOwnership() public view override onlyOwner {

        revert("Cannot renounce ownership");
    }
}