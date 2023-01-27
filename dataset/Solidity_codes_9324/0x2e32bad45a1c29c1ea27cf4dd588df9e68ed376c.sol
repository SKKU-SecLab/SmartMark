
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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
pragma solidity 0.8.4;


interface IVestable {
    function vest(
        bool vest,
        address _receiver,
        uint256 _amount
    ) external;
}

interface IPWRD {
    function factor() external view returns (uint256);

    function BASE() external view returns (uint256);
}

interface StakerStructs {
    struct UserInfo {
        uint256 amount;
        int256 rewardDebt;
    }

    struct PoolInfo {
        uint256 accGroPerShare;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        IERC20 lpToken;
    }
}

interface IStaker is StakerStructs {
    function poolInfo(uint256 pid) external view returns (PoolInfo memory);

    function userInfo(uint256 pid, address account) external view returns (UserInfo memory);

    function migrateFrom(uint256[] calldata pids) external;
}

interface IStakerV1 is StakerStructs {
    function vesting() external view returns (address);

    function maxGroPerBlock() external view returns (uint256);

    function groPerBlock() external view returns (uint256);

    function totalAllocPoint() external view returns (uint256);

    function manager() external view returns (address);

    function poolLength() external view returns (uint256);

    function poolInfo(uint256 pid) external view returns (PoolInfo memory);

    function userInfo(uint256 pid, address account) external view returns (UserInfo memory);
}

contract LPTokenStaker is Ownable, StakerStructs {
    using SafeERC20 for IERC20;

    IVestable public vesting;

    PoolInfo[] public poolInfo;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint;

    uint256 public maxGroPerBlock;
    uint256 public groPerBlock;

    address public manager;
    address public constant PWRD = address(0xF0a93d4994B3d98Fb5e3A2F90dBc2d69073Cb86b);
    uint256 public pPid = 999;

    mapping(address => bool) public activeLpTokens;

    uint256 private constant ACC_GRO_PRECISION = 1e12;

    address public immutable TIME_LOCK;

    bool public paused = true;
    bool public initialized = false;

    event LogAddPool(uint256 indexed pid, uint256 allocPoint, IERC20 indexed lpToken);
    event LogSetPool(uint256 indexed pid, uint256 allocPoint);
    event LogUpdatePool(uint256 indexed pid, uint256 lastRewardBlock, uint256 lpSupply, uint256 accGroPerShare);
    event LogDeposit(address indexed user, uint256 indexed pid, uint256 amount);
    event LogWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event LogMultiWithdraw(address indexed user, uint256[] pids, uint256[] amounts);
    event LogMultiClaim(address indexed user, bool vest, uint256[] pids, uint256 amount);
    event LogClaim(address indexed user, bool vest, uint256 indexed pid, uint256 amount);
    event LogLpTokenAdded(address token);
    event LogEmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event LogNewManagment(address newManager);
    event LogMaxGroPerBlock(uint256 newMax);
    event LogGroPerBlock(uint256 newGro);
    event LogNewVester(address newVester);
    event LogSetTimelock(address timelock);
    event LogSetStatus(bool pause);
    event LogNewPwrdPid(uint256 pPid);

    modifier onlyTimelock() {
        require(msg.sender == TIME_LOCK, "msg.sender != timelock");
        _;
    }

    constructor(address _timelock) {
        TIME_LOCK = _timelock;
        emit LogSetTimelock(_timelock);
    }

    function setVesting(address _vesting) external onlyOwner {
        vesting = IVestable(_vesting);
        emit LogNewVester(_vesting);
    }

    function setManager(address _manager) external onlyOwner {
        manager = _manager;
        emit LogNewManagment(_manager);
    }

    function setPwrdPid(uint256 _pPid) external {
        pPid = _pPid;
        require(msg.sender == manager, "setPwrdPid: !manager");
        emit LogNewPwrdPid(_pPid);
    }

    function setMaxGroPerBlock(uint256 _maxGroPerBlock) external onlyOwner {
        maxGroPerBlock = _maxGroPerBlock;
        emit LogMaxGroPerBlock(_maxGroPerBlock);
    }

    function setGroPerBlock(uint256 _groPerBlock) external {
        require(msg.sender == manager, "setGroPerBlock: !manager");
        require(_groPerBlock <= maxGroPerBlock, "setGroPerBlock: > maxGroPerBlock");
        groPerBlock = _groPerBlock;
        emit LogGroPerBlock(_groPerBlock);
    }

    function setStatus(bool pause) external onlyTimelock {
        paused = pause;
        emit LogSetStatus(pause);
    }

    function initialize() external onlyOwner {
        require(initialized == false, 'initialized: Contract already initialized');
        paused = false;
        initialized = true;
        emit LogSetStatus(false);
    }


    function poolLength() public view returns (uint256 pools) {
        pools = poolInfo.length;
    }

    function add(uint256 allocPoint, IERC20 _lpToken) external {
        require(msg.sender == manager, "add: !manager");
        totalAllocPoint += allocPoint;

        require(!activeLpTokens[address(_lpToken)], "add: lpToken already added");
        poolInfo.push(
            PoolInfo({allocPoint: allocPoint, lastRewardBlock: block.number, accGroPerShare: 0, lpToken: _lpToken})
        );
        activeLpTokens[address(_lpToken)] = true;
        emit LogLpTokenAdded(address(_lpToken));
        emit LogAddPool(poolInfo.length - 1, allocPoint, _lpToken);
    }

    function set(uint256 _pid, uint256 _allocPoint) external {
        require(msg.sender == manager, "set: !manager");
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;

        emit LogSetPool(_pid, _allocPoint);
    }

    function massUpdatePools(uint256[] calldata pids) external {
        uint256 len = pids.length;
        for (uint256 i = 0; i < len; ++i) {
            updatePool(pids[i]);
        }
    }

    function updatePool(uint256 pid) public returns (PoolInfo memory pool) {
        uint256 _totalAllocPoint = totalAllocPoint;
        require(_totalAllocPoint > 0, "updatePool: totalAllocPoint == 0");
        pool = poolInfo[pid];
        if (block.number > pool.lastRewardBlock) {
            uint256 lpSupply = pool.lpToken.balanceOf(address(this));
            if (address(poolInfo[pid].lpToken) == PWRD) {
                lpSupply = _prepPwrdBased(lpSupply);
            }
            if (lpSupply > 0) {
                uint256 blocks = block.number - pool.lastRewardBlock;
                uint256 groReward = (blocks * groPerBlock * pool.allocPoint) / _totalAllocPoint;
                pool.accGroPerShare = pool.accGroPerShare + (groReward * ACC_GRO_PRECISION) / lpSupply;
            }
            pool.lastRewardBlock = block.number;
            poolInfo[pid] = pool;
            emit LogUpdatePool(pid, pool.lastRewardBlock, lpSupply, pool.accGroPerShare);
        }
    }

    function claimable(uint256 _pid, address _user) external view returns (uint256) {
        uint256 _totalAllocPoint = totalAllocPoint;
        if (_totalAllocPoint == 0) return 0;
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 accPerShare = pool.accGroPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (address(poolInfo[_pid].lpToken) == PWRD) {
            lpSupply = _prepPwrdBased(lpSupply);
        }
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blocks = block.number - pool.lastRewardBlock;
            uint256 groReward = (blocks * groPerBlock * pool.allocPoint) / _totalAllocPoint;
            accPerShare = accPerShare + (groReward * ACC_GRO_PRECISION) / lpSupply;
        }
        return uint256(int256((user.amount * accPerShare) / ACC_GRO_PRECISION) - user.rewardDebt);
    }

    function getUserPwrd(address user) public view returns (uint256) {
        uint256 baseAmount = userInfo[pPid][user].amount;
        if (baseAmount == 0) {
            return 0;
        } else {
            return _prepPwrdRebased(baseAmount);
        }
    }

    function _prepPwrdBased(uint256 amount) internal view returns (uint256) {
        IPWRD pwrd = IPWRD(PWRD);
        uint256 factor = pwrd.factor();
        uint256 BASE = pwrd.BASE();
        uint256 diff = (amount * factor) % BASE;
        uint256 result = (amount * factor) / BASE;
        if (diff >= 5E17) {
            result = result + 1;
        }
        return result;
    }

    function _prepPwrdRebased(uint256 amount) internal view returns (uint256) {
        IPWRD pwrd = IPWRD(PWRD);
        uint256 factor = pwrd.factor();
        uint256 BASE = pwrd.BASE();
        uint256 diff = (amount * BASE) % factor;
        uint256 result = (amount * BASE) / factor;
        if (diff >= 5E17) {
            result = result + 1;
        }
        return result;
    }

    function _checkPwrd(uint256 withdrawAmount, uint256 userAmount) internal view returns (uint256, uint256) {
        uint256 baseAmount = _prepPwrdBased(withdrawAmount);
        if (baseAmount - 1 == userAmount || baseAmount == userAmount) return (withdrawAmount, userAmount);
        else if (baseAmount > userAmount) return (_prepPwrdBased(userAmount), userAmount);
        else if ((baseAmount * 1E4) / userAmount >= 9995) return (_prepPwrdBased(userAmount), userAmount);
        else return (withdrawAmount, baseAmount);
    }

    function deposit(uint256 pid, uint256 amount) public {
        require(!paused, "deposit: paused");

        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];

        uint256 uAmount = amount;
        if (address(poolInfo[pid].lpToken) == PWRD) {
            uAmount = _prepPwrdBased(amount);
        }

        user.amount = user.amount + uAmount;
        user.rewardDebt = user.rewardDebt + int256((uAmount * pool.accGroPerShare) / ACC_GRO_PRECISION);

        pool.lpToken.safeTransferFrom(msg.sender, address(this), amount);

        emit LogDeposit(msg.sender, pid, uAmount);
    }

    function withdraw(uint256 pid, uint256 amount) public {
        require(!paused, "withdraw: paused");

        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 uAmount = amount;
        uint256 userAmount = user.amount;
        if (address(poolInfo[pid].lpToken) == PWRD) {
            (amount, uAmount) = _checkPwrd(amount, userAmount);
        }

        user.amount = userAmount - uAmount;
        user.rewardDebt = user.rewardDebt - int256((uAmount * pool.accGroPerShare) / ACC_GRO_PRECISION);

        pool.lpToken.safeTransfer(msg.sender, amount);

        emit LogWithdraw(msg.sender, pid, uAmount);
    }

    function multiWithdraw(uint256[] calldata pids, uint256[] calldata amounts) public {
        require(!paused, "multiWithdraw: paused");
        uint256[] memory uAmounts = new uint256[](amounts.length);

        for (uint256 i = 0; i < pids.length; i++) {
            uint256 pid = pids[i];
            uint256 amount = amounts[i];
            PoolInfo memory pool = updatePool(pid);
            UserInfo storage user = userInfo[pid][msg.sender];

            uint256 uAmount = amount;
            uint256 userAmount = user.amount;
            if (address(poolInfo[pid].lpToken) == PWRD) {
                (amount, uAmount) = _checkPwrd(amount, userAmount);
            }
            uAmounts[i] = uAmount;

            user.amount = userAmount - amount;
            user.rewardDebt = user.rewardDebt - int256((uAmount * pool.accGroPerShare) / ACC_GRO_PRECISION);
            pool.lpToken.safeTransfer(msg.sender, amount);
        }

        emit LogMultiWithdraw(msg.sender, pids, uAmounts);
    }

    function claim(bool vest, uint256 pid) public {
        require(!paused, "claim: paused");

        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];

        int256 accumulatedGro = int256((user.amount * pool.accGroPerShare) / ACC_GRO_PRECISION);
        uint256 pending = accumulatedGro >= user.rewardDebt ? uint256(accumulatedGro - user.rewardDebt) : 0;

        user.rewardDebt = accumulatedGro;

        if (pending > 0) {
            vesting.vest(vest, msg.sender, pending);
        }

        emit LogClaim(msg.sender, vest, pid, pending);
    }

    function multiClaim(bool vest, uint256[] calldata pids) external {
        require(!paused, "multiClaim: paused");

        uint256 pending;
        for (uint256 i = 0; i < pids.length; i++) {
            PoolInfo memory pool = updatePool(pids[i]);
            UserInfo storage user = userInfo[pids[i]][msg.sender];
            int256 accumulatedGro = int256((user.amount * pool.accGroPerShare) / ACC_GRO_PRECISION);
            pending += accumulatedGro >= user.rewardDebt ? uint256(accumulatedGro - user.rewardDebt) : 0;
            user.rewardDebt = accumulatedGro;
        }

        if (pending > 0) {
            vesting.vest(vest, msg.sender, pending);
        }

        emit LogMultiClaim(msg.sender, vest, pids, pending);
    }

    function withdrawAndClaim(
        bool vest,
        uint256 pid,
        uint256 amount
    ) public {
        require(!paused, "withdrawAndClaim: paused");

        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 ua = user.amount;
        int256 accumulatedGro = int256((ua * pool.accGroPerShare) / ACC_GRO_PRECISION);
        uint256 pending = accumulatedGro >= user.rewardDebt ? uint256(accumulatedGro - user.rewardDebt) : 0;

        uint256 uAmount = amount;
        if (address(poolInfo[pid].lpToken) == PWRD) {
            (amount, uAmount) = _checkPwrd(amount, ua);
        }

        user.amount = ua - uAmount;
        user.rewardDebt = accumulatedGro - int256((uAmount * pool.accGroPerShare) / ACC_GRO_PRECISION);

        if (pending > 0) {
            vesting.vest(vest, msg.sender, pending);
        }
        pool.lpToken.safeTransfer(msg.sender, amount);

        emit LogWithdraw(msg.sender, pid, uAmount);
        emit LogClaim(msg.sender, vest, pid, pending);
    }

    function multiWithdrawAndClaim(
        bool vest,
        uint256[] calldata pids,
        uint256[] calldata amounts
    ) public {
        require(!paused, "multiWithdrawAndClaim: paused");
        uint256[] memory uAmounts = new uint256[](amounts.length);

        uint256 pending;
        for (uint256 i = 0; i < pids.length; i++) {
            uint256 pid = pids[i];
            uint256 amount = amounts[i];
            PoolInfo memory pool = updatePool(pid);
            UserInfo storage user = userInfo[pid][msg.sender];
            uint256 ua = user.amount;
            int256 accumulatedGro = int256((ua * pool.accGroPerShare) / ACC_GRO_PRECISION);
            pending += accumulatedGro >= user.rewardDebt ? uint256(accumulatedGro - user.rewardDebt) : 0;

            uint256 uAmount = amount;
            if (address(poolInfo[pid].lpToken) == PWRD) {
                (amount, uAmount) = _checkPwrd(amount, ua);
            }

            uAmounts[i] = uAmount;
            user.amount = ua - uAmount;
            user.rewardDebt = accumulatedGro - int256((uAmount * pool.accGroPerShare) / ACC_GRO_PRECISION);

            pool.lpToken.safeTransfer(msg.sender, amount);
        }

        if (pending > 0) {
            vesting.vest(vest, msg.sender, pending);
        }

        emit LogMultiWithdraw(msg.sender, pids, uAmounts);
        emit LogMultiClaim(msg.sender, vest, pids, pending);
    }

    function emergencyWithdraw(uint256 pid) public {
        require(!paused, "emergencyWithdraw: paused");

        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 amount = user.amount;
        if (address(poolInfo[pid].lpToken) == PWRD) {
            IPWRD pwrd = IPWRD(PWRD);
            uint256 factor = pwrd.factor();
            uint256 BASE = pwrd.BASE();
            amount = (amount * BASE) / factor;
        }
        user.amount = 0;
        user.rewardDebt = 0;

        pool.lpToken.safeTransfer(msg.sender, amount);
        emit LogEmergencyWithdraw(msg.sender, pid, amount);
    }

    address public oldStaker;
    address public newStaker;
    mapping(address => mapping(uint256 => bool)) public userMigrated;

    event LogNewStaker(address staker);
    event LogOldStaker(address staker);
    event LogMigrate(uint256[] pids);
    event LogMigrateFrom(uint256[] pids);
    event LogMigrateUser(address indexed account, uint256[] pids);

    function setNewStaker(address staker) public onlyOwner {
        newStaker = staker;
        emit LogNewStaker(staker);
    }

    function setOldStaker(address staker) public onlyOwner {
        oldStaker = staker;
        emit LogOldStaker(staker);
    }

    function migrate(uint256[] calldata pids) external onlyTimelock {
        require(newStaker != address(0), "migrate: !newStaker");

        for (uint256 i = 0; i < pids.length; i++) {
            PoolInfo memory pi = poolInfo[pids[i]];
            uint256 amount = pi.lpToken.balanceOf(address(this));
            pi.lpToken.approve(newStaker, amount);
        }

        IStaker(newStaker).migrateFrom(pids);
        emit LogMigrate(pids);
    }

    function migrateFrom(uint256[] calldata pids) external {
        require(msg.sender == oldStaker, "migrateFrom: !oldStaker");

        uint256 _totalAllocPoint;
        IStaker staker = IStaker(oldStaker);
        for (uint256 i = 0; i < pids.length; i++) {
            PoolInfo memory pi = staker.poolInfo(pids[i]);
            require(!activeLpTokens[address(pi.lpToken)], "migrateFrom: lpToken already added");
            poolInfo.push(
                PoolInfo({
                    allocPoint: pi.allocPoint,
                    lastRewardBlock: pi.lastRewardBlock,
                    accGroPerShare: pi.accGroPerShare,
                    lpToken: pi.lpToken
                })
            );
            _totalAllocPoint += pi.allocPoint;
            uint256 amount = pi.lpToken.balanceOf(oldStaker);
            pi.lpToken.safeTransferFrom(oldStaker, address(this), amount);
            activeLpTokens[address(pi.lpToken)] = true;
        }
        totalAllocPoint += _totalAllocPoint;

        emit LogMigrateFrom(pids);
    }

    function migrateUser(address account, uint256[] calldata pids) external {
        require(!paused, "migrateUser: paused");

        require(oldStaker != address(0), "migrateUser: !oldStaker");

        IStaker staker = IStaker(oldStaker);
        for (uint256 i = 0; i < pids.length; i++) {
            uint256 pid = pids[i];
            require(!userMigrated[account][pid], "migrateUser: pid already done");

            UserInfo memory oldUI = staker.userInfo(pid, account);
            if (oldUI.amount > 0) {
                UserInfo storage ui = userInfo[pid][account];
                if (address(poolInfo[pid].lpToken) == PWRD) {
                    ui.amount += _prepPwrdBased(oldUI.amount);
                } else {
                    ui.amount += oldUI.amount;
                }
                ui.rewardDebt += oldUI.rewardDebt;
                userMigrated[account][pid] = true;
            }
        }

        emit LogMigrateUser(account, pids);
    }

    bool public migratedFromV1;

    event LogMigrateFromV1(address staker);
    event LogUserMigrateFromV1(address indexed account, address staker);

    function migrateFromV1() external onlyOwner {
        require(!migratedFromV1, "migrateFromV1: already done");
        require(oldStaker != address(0), "migrateUser: !oldStaker");

        IStakerV1 staker = IStakerV1(oldStaker);
        manager = staker.manager();
        maxGroPerBlock = staker.maxGroPerBlock();

        uint256 len = staker.poolLength();
        for (uint256 i = 0; i < len; i++) {
            PoolInfo memory pi = staker.poolInfo(i);
            poolInfo.push(
                PoolInfo({
                    allocPoint: 0,
                    lastRewardBlock: pi.lastRewardBlock,
                    accGroPerShare: pi.accGroPerShare,
                    lpToken: pi.lpToken
                })
            );
            activeLpTokens[address(pi.lpToken)] = true;
        }

        migratedFromV1 = true;
        emit LogMigrateFromV1(oldStaker);
    }
}