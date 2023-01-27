



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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
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

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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


pragma solidity ^0.6.0;

interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

}


pragma solidity >=0.6.6;







interface IMigratorChef {

    function migrate(IERC20 token) external returns (IERC20);

}

interface ITokenIssue {

    function transByContract(address to, uint256 amount) external;


    function issueInfo(uint256 monthIndex) external view returns (uint256);


    function startIssueTime() external view returns (uint256);


    function issueInfoLength() external view returns (uint256);


    function TOTAL_AMOUNT() external view returns (uint256);


    function DAY_SECONDS() external view returns (uint256);


    function MONTH_SECONDS() external view returns (uint256);


    function INIT_MINE_SUPPLY() external view returns (uint256);

}

contract MasterChef is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bytes32 public constant PUBLIC_ROLE = keccak256("PUBLIC_ROLE");

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. SUMMAs to distribute per block.
        uint256 lastRewardTime;  // Last seconds that SUMMAs distribution occurs.
        uint256 accSummaPerShare; // Accumulated SUMMAs per share, times 1e12. See below.
    }

    IERC20 public summa;
    uint256 public bonusEndTime;
    uint256 public constant BONUS_MULTIPLIER = 1;
    IMigratorChef public migrator;

    IAccessControl public accessContract;

    ITokenIssue public tokenIssue;

    uint256 public totalIssueRate = 0.2 * 10000;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startTime;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IERC20 _summa,
        uint256 _startTime,
        uint256 _bonusEndTime,
        IAccessControl _accessContract
    ) public {
        summa = _summa;
        bonusEndTime = _bonusEndTime;
        startTime = _startTime;
        accessContract = _accessContract;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {

        _lpToken.totalSupply();

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardTime = block.number > startTime ? block.number : startTime;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
        lpToken : _lpToken,
        allocPoint : _allocPoint,
        lastRewardTime : lastRewardTime,
        accSummaPerShare : 0
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {

        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setMigrator(IMigratorChef _migrator) public onlyOwner {

        migrator = _migrator;
    }

    function setTokenIssue(ITokenIssue _tokenIssue) public onlyOwner {

        tokenIssue = _tokenIssue;
    }

    function setTotalIssueRate(uint256 _totalIssueRate) public onlyOwner {

        totalIssueRate = _totalIssueRate;
    }

    function migrate(uint256 _pid) public {

        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        pool.lpToken = newLpToken;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {

        uint256 issueTime = tokenIssue.startIssueTime();
        if (_to <= bonusEndTime) {
            if (_to < issueTime) {
                return 0;
            }
            if (_from < issueTime) {
                return getIssue(issueTime, _to).mul(totalIssueRate).div(10000).mul(BONUS_MULTIPLIER);
            }
            return getIssue(issueTime, _to).sub(getIssue(issueTime, _from)).mul(totalIssueRate).div(10000).mul(BONUS_MULTIPLIER);
        } else if (_from >= bonusEndTime) {
            if (_to < issueTime) {
                return 0;
            }
            if (_from < issueTime) {
                return getIssue(issueTime, _to).mul(totalIssueRate).div(10000);
            }
            return getIssue(issueTime, _to).sub(getIssue(issueTime, _from)).mul(totalIssueRate).div(10000);
        } else {
            if (_to < issueTime) {
                return 0;
            }
            if (_from < issueTime) {
                if(issueTime < bonusEndTime){
                    return getIssue(issueTime,bonusEndTime).mul(BONUS_MULTIPLIER).add(
                        getIssue(issueTime, _to).sub(getIssue(issueTime, bonusEndTime))
                    ).mul(totalIssueRate).div(10000);
                }
                return getIssue(issueTime, _to);
            }
            return getIssue(issueTime, bonusEndTime).sub(getIssue(issueTime, _from)).mul(BONUS_MULTIPLIER).add(
                getIssue(issueTime,_to).sub(getIssue(issueTime,bonusEndTime))
            ).mul(totalIssueRate).div(10000);

        }
    }

    function getIssue(uint256 _from, uint256 _to) private view returns (uint256){

        if (_to <= _from || _from <= 0) {
            return 0;
        }
        uint256 timeInterval = _to - _from;
        uint256 monthIndex = timeInterval.div(tokenIssue.MONTH_SECONDS());
        if (monthIndex < 1) {
            return timeInterval.mul(tokenIssue.issueInfo(monthIndex).div(tokenIssue.MONTH_SECONDS()));
        } else if (monthIndex < tokenIssue.issueInfoLength()) {
            uint256 tempTotal = 0;
            for (uint256 j = 0; j < monthIndex; j++) {
                tempTotal = tempTotal.add(tokenIssue.issueInfo(j));
            }
            uint256 calcAmount = timeInterval.sub(monthIndex.mul(tokenIssue.MONTH_SECONDS())).mul(tokenIssue.issueInfo(monthIndex).div(tokenIssue.MONTH_SECONDS())).add(tempTotal);
            if (calcAmount > tokenIssue.TOTAL_AMOUNT().sub(tokenIssue.INIT_MINE_SUPPLY())) {
                return tokenIssue.TOTAL_AMOUNT().sub(tokenIssue.INIT_MINE_SUPPLY());
            }
            return calcAmount;
        } else {
            return 0;
        }
    }

    function pendingSumma(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSummaPerShare = pool.accSummaPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardTime && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardTime, block.number);
            uint256 summaReward = multiplier.mul(pool.allocPoint).div(totalAllocPoint);
            accSummaPerShare = accSummaPerShare.add(summaReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accSummaPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardTime) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardTime = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardTime, block.number);
        uint256 summaReward = multiplier.mul(pool.allocPoint).div(totalAllocPoint);
        tokenIssue.transByContract(address(this), summaReward);
        pool.accSummaPerShare = pool.accSummaPerShare.add(summaReward.mul(1e12).div(lpSupply));
        pool.lastRewardTime = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accSummaPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeSummaTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accSummaPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accSummaPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeSummaTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            if(_amount < pool.lpToken.balanceOf(address(this))){
                user.amount = user.amount.sub(_amount);
                pool.lpToken.safeTransfer(address(msg.sender), _amount);
            }else{
                user.amount = 0;
                pool.lpToken.safeTransfer(address(msg.sender), pool.lpToken.balanceOf(address(this)));
            }
        }
        user.rewardDebt = user.amount.mul(pool.accSummaPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        if(pool.lpToken.balanceOf(address(this)) < user.amount){
            amount = pool.lpToken.balanceOf(address(this));
        }
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function safeSummaTransfer(address _to, uint256 _amount) internal {

        uint256 summaBal = summa.balanceOf(address(this));
        if (_amount > summaBal) {
            summa.transfer(_to, summaBal);
        } else {
            summa.transfer(_to, _amount);
        }
    }
}