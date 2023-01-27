


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
}




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
}




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
}




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
}




pragma solidity >=0.6.0 <0.8.0;


contract UpgradeableOwnable {

    bytes32 private constant _OWNER_SLOT = 0xa7b53796fd2d99cb1f5ae019b54f9e024446c3d12b483f733ccc62ed04eb126a;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        assert(_OWNER_SLOT == bytes32(uint256(keccak256("eip1967.proxy.owner")) - 1));
        _setOwner(msg.sender);
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function _setOwner(address newOwner) private {

        bytes32 slot = _OWNER_SLOT;
        assembly {
            sstore(slot, newOwner)
        }
    }

    function owner() public view virtual returns (address o) {

        bytes32 slot = _OWNER_SLOT;
        assembly {
            o := sload(slot)
        }
    }

    modifier onlyOwner() {

        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(owner(), address(0));
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner(), newOwner);
        _setOwner(newOwner);
    }
}




pragma solidity ^0.6.0;






contract VotingEscrow is IERC20, UpgradeableOwnable {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public _smty;
    IERC20 public _syUSD;
    address public _collector;

    uint256 private _totalSupply;
    mapping (address => uint256) private _balances;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public constant MAX_TIME = 1460 days;

    struct LockData {
        uint256 amount;
        uint256 end;
    }
    mapping (address => LockData) private _locks;
    uint256 public _totalLockedSMTY;

    uint256 private _accRewardPerBalance;
    mapping (address => uint256) private _rewardDebt;

    struct LockedBalance {
        uint256 amount;
        uint256 unlockTime;
    }
    mapping(address => LockedBalance[]) _userEarnings;
    uint256 public constant REWARDS_DURATION = 86400 * 7;
    uint256 public constant LOCK_DURATION = REWARDS_DURATION * 13;
    struct Balances {
        uint256 earned;
        uint256 penaltyEarningDebt;
    }
    mapping(address => Balances) private  _userBalances;
    uint256 private _accPenaltyEarningPerBalance;
    bool public _distributePenaltyEarning = false;  // burn or redistribute penalty of earning

    event LockCreate(address indexed user, uint256 amount, uint256 veAmount, uint256 lockEnd);
    event LockExtend(address indexed user, uint256 amount, uint256 veAmount, uint256 lockEnd);
    event LockIncreaseAmount(address indexed user, uint256 amount, uint256 veAmount, uint256 lockEnd);
    event Withdraw(address indexed user, uint256 amount);
    event EarningAdd(address indexed user, uint256 amount);
    event EarningWithdraw(address indexed user, uint256 amount, uint256 penaltyAmount);

    constructor() public {}

    function initialize(IERC20 smty, IERC20 syUSD, address collector) external onlyOwner {

        _name = "Voting Escrow Smoothy Token";
        _symbol = "veSMTY";
        _decimals = 18;
        _smty = smty;
        _syUSD = syUSD;
        _collector = collector;
        _distributePenaltyEarning = true;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        return false;
    }

    function allowance(
        address owner,
        address spender
    )
        public view virtual override returns (uint256)
    {

        return 0;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        return false;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public virtual override returns (bool)
    {

        return false;
    }

    function amountOf(address account) public view returns (uint256) {

        return _locks[account].amount;
    }

    function endOf(address account) public view returns (uint256) {

        return _locks[account].end;
    }

    function maxEnd() public view returns (uint256) {

        return block.timestamp + MAX_TIME;
    }

    function createLock(uint256 amount, uint256 end) external {

        _createLock(amount, end, block.timestamp);
    }

    function _createLock(uint256 amount, uint256 end, uint256 timestamp) internal claimReward(true, true) {

        LockData storage lock = _locks[msg.sender];

        require(lock.amount == 0, "must no locked");
        require(end <= timestamp + MAX_TIME, "end too long");
        require(end > timestamp, "end too short");
        require(amount != 0, "amount must be non-zero");

        _smty.safeTransferFrom(msg.sender, address(this), amount);
        _totalLockedSMTY = _totalLockedSMTY + amount;

        lock.amount = amount;
        lock.end = end;

        _updateBalance(msg.sender, (end - timestamp).mul(amount).div(MAX_TIME));

        emit LockCreate(msg.sender, lock.amount, _balances[msg.sender], lock.end);
    }

    function addAmount(uint256 amount) external {

        _addAmount(amount, block.timestamp);
    }

    function _addAmount(uint256 amount, uint256 timestamp) internal claimReward(true, true) {

        LockData storage lock = _locks[msg.sender];

        require(lock.amount != 0, "must locked");
        require(lock.end > timestamp, "must not expired");
        require(amount != 0, "_amount must be nonzero");

        _smty.safeTransferFrom(msg.sender, address(this), amount);
        _totalLockedSMTY = _totalLockedSMTY + amount;

        lock.amount = lock.amount.add(amount);
        _updateBalance(
            msg.sender,
            _balances[msg.sender].add((lock.end - timestamp).mul(amount).div(MAX_TIME))
        );

        emit LockIncreaseAmount(msg.sender, lock.amount, _balances[msg.sender], lock.end);
    }

    function extendLock(uint256 end) external {

        _extendLock(end, block.timestamp);
    }

    function _extendLock(uint256 end, uint256 timestamp) internal claimReward(true, true) {

        LockData storage lock = _locks[msg.sender];
        require(lock.amount != 0, "must locked");
        require(lock.end < end, "new end must be longer");
        require(end <= timestamp + MAX_TIME, "end too long");

        uint256 duration = _balances[msg.sender].mul(MAX_TIME).div(lock.amount);
        duration += (end - lock.end);
        if (duration > MAX_TIME) {
            duration = MAX_TIME;
        }

        lock.end = end;
        _updateBalance(msg.sender, duration.mul(lock.amount).div(MAX_TIME));

        emit LockExtend(msg.sender, lock.amount, _balances[msg.sender], lock.end);
    }

    function withdraw() external {

        _withdraw(block.timestamp);
    }

    function _withdraw(uint256 timestamp) internal claimReward(true, true) {

        LockData storage lock = _locks[msg.sender];

        require(lock.end <= timestamp, "must expired");

        uint256 amount = lock.amount;
        _smty.safeTransfer(msg.sender, amount);
        _totalLockedSMTY = _totalLockedSMTY - amount;

        lock.amount = 0;
        _updateBalance(msg.sender, 0);

        emit Withdraw(msg.sender, amount);
    }

    function setDistributePenaltyEarning(bool dist) external onlyOwner {

        _distributePenaltyEarning = dist;
    }

    function addEarning(address user, uint256 amount) external {

        _addPendingEarning(user, amount);
        _smty.safeTransferFrom(msg.sender, address(this), amount);
    }

    function _addPendingEarning(address user, uint256 amount) internal {

        Balances storage bal = _userBalances[user];
        bal.earned = bal.earned.add(amount);

        uint256 unlockTime = block.timestamp.div(REWARDS_DURATION).mul(REWARDS_DURATION).add(LOCK_DURATION);
        LockedBalance[] storage earnings = _userEarnings[user];
        uint256 idx = earnings.length;

        if (idx == 0 || earnings[idx-1].unlockTime < unlockTime) {
            earnings.push(LockedBalance({amount: amount, unlockTime: unlockTime}));
        } else {
            earnings[idx-1].amount = earnings[idx-1].amount.add(amount);
        }
        emit EarningAdd(user, amount);
    }

    function withdrawEarning(uint256 amount) public {

        require(amount > 0, "Cannot withdraw 0");
        Balances storage bal = _userBalances[msg.sender];
        uint256 penaltyAmount = 0;

        uint256 remaining = amount;
        bal.earned = bal.earned.sub(remaining);
        for (uint i = 0; ; i++) {
            uint256 earnedAmount = _userEarnings[msg.sender][i].amount;
            if (earnedAmount == 0) {
                continue;
            }
            if (penaltyAmount == 0 && _userEarnings[msg.sender][i].unlockTime > block.timestamp) {
                penaltyAmount = remaining;
                require(bal.earned >= remaining, "Insufficient balance after penalty");
                bal.earned = bal.earned.sub(remaining);
                if (bal.earned == 0) {
                    delete _userEarnings[msg.sender];
                    break;
                }
                remaining = remaining.mul(2);
            }
            if (remaining <= earnedAmount) {
                _userEarnings[msg.sender][i].amount = earnedAmount.sub(remaining);
                break;
            } else {
                delete _userEarnings[msg.sender][i];
                remaining = remaining.sub(earnedAmount);
            }
        }

        _smty.safeTransfer(msg.sender, amount);
        if (_distributePenaltyEarning && (_totalSupply != 0)) {
            _accPenaltyEarningPerBalance = _accPenaltyEarningPerBalance.add(penaltyAmount.mul(1e18).div(_totalSupply));
        }
        emit EarningWithdraw(msg.sender, amount, penaltyAmount);
    }

    function withdrawableEarning(
        address user
    )
        public
        view
        returns (uint256 amount, uint256 penaltyAmount)
    {

        Balances storage bal = _userBalances[user];
        if (bal.earned > 0) {
            uint256 amountWithoutPenalty;
            uint256 length = _userEarnings[user].length;
            for (uint i = 0; i < length; i++) {
                uint256 earnedAmount = _userEarnings[user][i].amount;
                if (earnedAmount == 0) {
                    continue;
                }
                if (_userEarnings[user][i].unlockTime > block.timestamp) {
                    break;
                }
                amountWithoutPenalty = amountWithoutPenalty.add(earnedAmount);
            }

            penaltyAmount = bal.earned.sub(amountWithoutPenalty).div(2) + 1;
        }
        amount = bal.earned.sub(penaltyAmount);
        return (amount, penaltyAmount);
    }

    function claim() external claimReward(true, false) {

    }

    function vestEarning() external claimReward(false, true) {

    }

    function _updateBalance(address account, uint256 newBalance) internal {

        _totalSupply = _totalSupply.sub(_balances[account]).add(newBalance);
        _balances[account] = newBalance;
    }

    function collectReward() public {

        uint256 newReward = _syUSD.balanceOf(_collector);
        if (newReward == 0) {
            return;
        }

        _syUSD.safeTransferFrom(_collector, address(this), newReward);
        _accRewardPerBalance = _accRewardPerBalance.add(newReward.mul(1e18).div(_totalSupply));
    }

    function pendingReward() public view returns (uint256 pending) {

        if (_balances[msg.sender] > 0) {
            uint256 newReward = _syUSD.balanceOf(_collector);
            uint256 newAccRewardPerBalance = _accRewardPerBalance.add(newReward.mul(1e18).div(_totalSupply));
            pending = _balances[msg.sender].mul(newAccRewardPerBalance).div(1e18).sub(_rewardDebt[msg.sender]);
        }
    }

    function pendingEarning() public view returns (uint256 pending) {

        if (_balances[msg.sender] > 0) {
            pending = _balances[msg.sender].mul(_accPenaltyEarningPerBalance).div(1e18).sub(_userBalances[msg.sender].penaltyEarningDebt);
        }
    }

    modifier claimReward(bool claimFee, bool vestEarn) {

        uint256 veBal = _balances[msg.sender];
        if (veBal > 0) {
            if (claimFee) {
                collectReward();
                uint256 pending = veBal.mul(_accRewardPerBalance).div(1e18).sub(_rewardDebt[msg.sender]);
                _syUSD.safeTransfer(msg.sender, pending);
            }

            if (vestEarn) {
                uint256 pending = veBal.mul(_accPenaltyEarningPerBalance).div(1e18)
                    .sub(_userBalances[msg.sender].penaltyEarningDebt);

                if (pending != 0) {
                    _addPendingEarning(msg.sender, pending);
                }
            }
        }

        _; // _balances[msg.sender] may changed.

        if (!claimFee || !vestEarn) {
            require(veBal == _balances[msg.sender], "veSMTY balance changed");
        } else {
            veBal = _balances[msg.sender];
        }

        if (claimFee) {
            _rewardDebt[msg.sender] = veBal.mul(_accRewardPerBalance).div(1e18);
        }
        if (vestEarn) {
            _userBalances[msg.sender].penaltyEarningDebt = veBal.mul(_accPenaltyEarningPerBalance)
                .div(1e18);
        }
    }
}