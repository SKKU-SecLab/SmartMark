
pragma solidity >=0.8.2 < 0.9.0;
pragma abicoder v2;
pragma experimental ABIEncoderV2;


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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




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
}




interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}




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



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract GabrielV2 is Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint;


    address public devaddr;
    uint public devPercent;
    
    address public treasury;
    uint public tPercent;
    
    PoolInfo[] public poolInfo;
    mapping(uint => mapping(address => UserInfo)) public userInfo;

    struct ConstructorArgs {
        uint devPercent;
        uint tPercent;
        address devaddr;
        address treasury;
    }
    
    struct ExtraArgs {
        IERC20 stakeToken;
        uint openTime;
        uint waitPeriod;
        uint lockDuration;
    }

    struct PoolInfo {
        bool canStake;
        bool canUnstake;
        IERC20 stakeToken;
        uint lockDuration;
        uint lockTime;
        uint NORT;
        uint openTime;
        uint staked;
        uint unlockTime;
        uint unstaked;        
        uint waitPeriod;
        address[] harvestList;
        address[] rewardTokens;
        address[] stakeList;
        uint[] rewardsInPool;
    }

    struct UserInfo {
        uint amount;
        bool harvested;
    }

    event Harvest(uint pid, address user, uint amount);
    event PercentsUpdated(uint dev, uint treasury);
    event ReflectionsClaimed(uint pid, address token, uint amount);
    event Stake(uint pid, address user, uint amount);
    event Unstake(uint pid, address user, uint amount);

    constructor(
        ConstructorArgs memory constructorArgs,
        ExtraArgs memory extraArgs,
        uint _NORT,
        address[] memory _rewardTokens,
        uint[] memory _rewardsInPool
    ) {
        devPercent = constructorArgs.devPercent;
        tPercent = constructorArgs.tPercent;
        devaddr = constructorArgs.devaddr;
        treasury = constructorArgs.treasury;
        createPool(extraArgs, _NORT, _rewardTokens, _rewardsInPool);
    }


    function _changeNORT(uint _pid, uint _NORT) internal {

        PoolInfo storage pool = poolInfo[_pid];
        address[] memory rewardTokens = new address[](_NORT);
        uint[] memory rewardsInPool = new uint[](_NORT);
        pool.NORT = _NORT;
        pool.rewardTokens = rewardTokens;
        pool.rewardsInPool = rewardsInPool;
    }

    function changeNORT(uint _pid, uint _NORT) external onlyOwner {

        _changeNORT(_pid, _NORT);
    }

    function changePercents(uint _devPercent, uint _tPercent) external onlyOwner {

        require(_devPercent.add(_tPercent) == 100, "must sum up to 100%");
        devPercent = _devPercent;
        tPercent = _tPercent;
        emit PercentsUpdated(_devPercent, _tPercent);
    }

    function changeRewardTokens(uint _pid, address[] memory _rewardTokens) external onlyOwner {

        PoolInfo storage pool = poolInfo[_pid];
        uint NORT = pool.NORT;
        require(_rewardTokens.length == NORT, "CRT: array length mismatch");
        for (uint i = 0; i < NORT; i++) {
            pool.rewardTokens[i] = _rewardTokens[i];
        }
    }

    function claimReflection(uint _pid, address token, uint amount) external onlyOwner {

        uint onePercent = amount.div(100);
        uint devShare = devPercent.mul(onePercent);
        uint tShare = amount.sub(devShare);
        IERC20(token).safeTransfer(devaddr, devShare);
        IERC20(token).safeTransfer(treasury, tShare);
        emit ReflectionsClaimed(_pid, token, amount);
    }

    function createPool(ExtraArgs memory extraArgs, uint _NORT, address[] memory _rewardTokens, uint[] memory _rewardsInPool) public onlyOwner {

        require(_rewardTokens.length == _NORT && _rewardTokens.length == _rewardsInPool.length, "CP: array length mismatch");
        address[] memory rewardTokens = new address[](_NORT);
        uint[] memory rewardsInPool = new uint[](_NORT);
        address[] memory emptyList;
        require(
            extraArgs.openTime > block.timestamp,
            "open time must be a future time"
        );
        uint _lockTime = extraArgs.openTime.add(extraArgs.waitPeriod);
        uint _unlockTime = _lockTime.add(extraArgs.lockDuration);
        
        poolInfo.push(
            PoolInfo({
                stakeToken: extraArgs.stakeToken,
                staked: 0,
                unstaked: 0,
                openTime: extraArgs.openTime,
                waitPeriod: extraArgs.waitPeriod,
                lockTime: _lockTime,
                lockDuration: extraArgs.lockDuration,
                unlockTime: _unlockTime,
                canStake: false,
                canUnstake: false,
                NORT: _NORT,
                rewardTokens: rewardTokens,
                rewardsInPool: rewardsInPool,
                stakeList: emptyList,
                harvestList: emptyList
            })
        );
        uint _pid = poolInfo.length - 1;
        PoolInfo storage pool = poolInfo[_pid];
        for (uint i = 0; i < _NORT; i++) {
            pool.rewardTokens[i] = _rewardTokens[i];
            pool.rewardsInPool[i] = _rewardsInPool[i];
        }
    }

    function dev(address _devaddr) external {

        require(msg.sender == devaddr, "dev: caller is not the current dev");
        devaddr = _devaddr;
    }

    function harvest(uint _pid) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (block.timestamp > pool.unlockTime && pool.canUnstake == false) {
            pool.canUnstake = true;
        }
        require(pool.canUnstake == true, "pool is still locked");
        require(user.amount > 0 && user.harvested == false, "Harvest: forbid withdraw");
        pool.harvestList.push(msg.sender);
        update(_pid);
        uint NORT = pool.NORT;
        for (uint i = 0; i < NORT; i++) {
            uint reward = user.amount * pool.rewardsInPool[i];
            uint lpSupply = pool.staked;
            uint pending = reward.div(lpSupply);
            if (pending > 0) {
                IERC20(pool.rewardTokens[i]).safeTransfer(msg.sender, pending);
                pool.rewardsInPool[i] = pool.rewardsInPool[i].sub(pending);
                emit Harvest(_pid, msg.sender, pending);
            }
        }
        pool.staked = pool.staked.sub(user.amount);
        user.harvested = true;
    }

    function recoverERC20(address token, address recipient, uint amount) external onlyOwner {

        IERC20(token).safeTransfer(recipient, amount);
    }

    function reset(uint _pid, address[] memory harvestList) external onlyOwner {

        PoolInfo storage pool = poolInfo[_pid];
        uint len = harvestList.length;
        uint len2 = pool.harvestList.length;
        uint staked;
        for (uint i; i < len; i++) {
            UserInfo storage user = userInfo[_pid][harvestList[i]];
            user.harvested = false;
            staked = staked.add(user.amount);
        }
        pool.staked = pool.staked.add(staked);

        address lastUser = harvestList[len-1];
        address lastHarvester = pool.harvestList[len2-1];
        if (lastHarvester == lastUser) {
            address[] memory emptyList;
            pool.harvestList = emptyList;
        }
    }

    function reuse(uint _pid, ExtraArgs memory extraArgs, uint _NORT, address[] memory _rewardTokens, uint[] memory _rewardsInPool) external onlyOwner {

        require(
            _rewardTokens.length == _NORT &&
            _rewardTokens.length == _rewardsInPool.length,
            "RP: array length mismatch"
        );
        PoolInfo storage pool = poolInfo[_pid];
        pool.stakeToken = extraArgs.stakeToken;
        pool.unstaked = 0;
        _setTimeValues( _pid, extraArgs.openTime, extraArgs.waitPeriod, extraArgs.lockDuration);
        _changeNORT(_pid, _NORT);
        for (uint i = 0; i < _NORT; i++) {
            pool.rewardTokens[i] = _rewardTokens[i];
            pool.rewardsInPool[i] = _rewardsInPool[i];
        }
        pool.stakeList = pool.harvestList;
    }

    function setPoolRewards(uint _pid, uint[] memory rewards) external onlyOwner {

        PoolInfo storage pool = poolInfo[_pid];
        uint NORT = pool.NORT;
        require(rewards.length == NORT, "SPR: array length mismatch");
        for (uint i = 0; i < NORT; i++) {
            pool.rewardsInPool[i] = rewards[i];
        }
    }

    function _setTimeValues(
        uint _pid,
        uint _openTime,
        uint _waitPeriod,
        uint _lockDuration
    ) internal {

        PoolInfo storage pool = poolInfo[_pid];
        require(
            _openTime > block.timestamp,
            "open time must be a future time"
        );
        pool.openTime = _openTime;
        pool.waitPeriod = _waitPeriod;
        pool.lockTime = _openTime.add(_waitPeriod);
        pool.lockDuration = _lockDuration;
        pool.unlockTime = pool.lockTime.add(_lockDuration);
    }

    function setTimeValues(
        uint _pid,
        uint _openTime,
        uint _waitPeriod,
        uint _lockDuration
    ) external onlyOwner {

        _setTimeValues(_pid, _openTime, _waitPeriod, _lockDuration);
    }

    function setTreasury(address _treasury) external onlyOwner {

        treasury = _treasury;
    }

    function stake(uint _pid, uint _amount) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if (block.timestamp > pool.lockTime && pool.canStake == true) {
            pool.canStake = false;
        }
        if (
            block.timestamp > pool.openTime &&
            block.timestamp < pool.lockTime &&
            block.timestamp < pool.unlockTime &&
            pool.canStake == false
        ) {
            pool.canStake = true;
        }
        require(
            pool.canStake == true,
            "pool is not yet opened or is locked"
        );
        update(_pid);
        if (_amount == 0) {
            return;
        }
        pool.stakeToken.safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
        pool.stakeList.push(msg.sender);
        user.amount = user.amount.add(_amount);
        pool.staked = pool.staked.add(_amount);
        emit Stake(_pid, msg.sender, _amount);
    }

    function unstake(uint _pid) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount > 0, "unstake: withdraw bad");
        pool.stakeToken.safeTransfer(msg.sender, user.amount);
        pool.unstaked = pool.unstaked.add(user.amount);
        if (pool.staked >= user.amount) {
            pool.staked = pool.staked.sub(user.amount);
        }
        emit Unstake(_pid, msg.sender, user.amount);
        user.amount = 0;
    }

    function update(uint _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.openTime) {
            return;
        }
        if (
            block.timestamp > pool.openTime &&
            block.timestamp < pool.lockTime &&
            block.timestamp < pool.unlockTime
        ) {
            pool.canStake = true;
            pool.canUnstake = false;
        }
        if (
            block.timestamp > pool.lockTime &&
            block.timestamp < pool.unlockTime
        ) {
            pool.canStake = false;
            pool.canUnstake = false;
        }
        if (
            block.timestamp > pool.unlockTime &&
            pool.unlockTime > 0
        ) {
            pool.canStake = false;
            pool.canUnstake = true;
        }
    }


    function harvesters(uint _pid) external view returns (address[] memory harvestList) {

        PoolInfo memory pool = poolInfo[_pid];
        harvestList = pool.harvestList;
    }

    function harvests(uint _pid) external view returns (uint) {

        PoolInfo memory pool = poolInfo[_pid];
        return pool.harvestList.length;
    }

    function poolLength() external view returns (uint) {

        return poolInfo.length;
    }

    function rewardInPool(uint _pid) external view returns (uint[] memory rewardsInPool) {

        PoolInfo memory pool = poolInfo[_pid];
        rewardsInPool = pool.rewardsInPool;
    }

    function stakers(uint _pid) external view returns (address[] memory stakeList) {

        PoolInfo memory pool = poolInfo[_pid];
        stakeList = pool.stakeList;
    }

    function stakes(uint _pid) external view returns (uint) {

        PoolInfo memory pool = poolInfo[_pid];
        return pool.stakeList.length;
    }

    function tokensInPool(uint _pid) external view returns (address[] memory rewardTokens) {

        PoolInfo memory pool = poolInfo[_pid];
        rewardTokens = pool.rewardTokens;
    }

    function unclaimedRewards(uint _pid, address _user)
        external
        view
        returns (uint[] memory unclaimedReward)
    {

        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint NORT = pool.NORT;
        if (block.timestamp > pool.lockTime && block.timestamp < pool.unlockTime && pool.staked != 0) {
            uint[] memory array = new uint[](NORT);
            for (uint i = 0; i < NORT; i++) {
                uint blocks = block.timestamp.sub(pool.lockTime);
                uint reward = blocks * user.amount * pool.rewardsInPool[i];
                uint lpSupply = pool.staked * pool.lockDuration;
                uint pending = reward.div(lpSupply);
                array[i] = pending;
            }
            return array;
        } else if (block.timestamp > pool.unlockTime && user.harvested == false && pool.staked != 0) {
            uint[] memory array = new uint[](NORT);
            for (uint i = 0; i < NORT; i++) {                
                uint reward = user.amount * pool.rewardsInPool[i];
                uint lpSupply = pool.staked;
                uint pending = reward.div(lpSupply);
                array[i] = pending;
            }
            return array;
        } else {
            uint[] memory array = new uint[](NORT);
            for (uint i = 0; i < NORT; i++) {                
                array[i] = 0;
            }
            return array;
        }        
    }
}