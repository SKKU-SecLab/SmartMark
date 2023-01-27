



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



pragma solidity >=0.7.0 <0.8.0;


abstract contract Operator is Context, Ownable {
    address private _operator;

    event OperatorTransferred(
        address indexed previousOperator,
        address indexed newOperator
    );

    constructor() {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOperator() {
        require(
            _operator == _msgSender(),
            'operator: caller is not the operator'
        );
        _;
    }

    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {
        require(
            newOperator_ != address(0),
            'operator: zero address given for new operator'
        );
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
    }
}






pragma solidity >=0.6.0 <0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
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



pragma solidity >=0.7.0 <0.8.0;




interface IPoolStore {

    event Deposit(
        address indexed operator,
        address indexed owner,
        uint256 indexed pid,
        uint256 amount
    );
    event Withdraw(
        address indexed operator,
        address indexed owner,
        uint256 indexed pid,
        uint256 amount
    );


    function totalWeight() external view returns (uint256);


    function poolLength() external view returns (uint256);


    function poolIdsOf(address _token) external view returns (uint256[] memory);


    function nameOf(uint256 _pid) external view returns (string memory);


    function tokenOf(uint256 _pid) external view returns (address);


    function weightOf(uint256 _pid) external view returns (uint256);


    function totalSupply(uint256 _pid) external view returns (uint256);


    function balanceOf(uint256 _pid, address _owner)
        external
        view
        returns (uint256);



    function deposit(
        uint256 _pid,
        address _owner,
        uint256 _amount
    ) external;


    function withdraw(
        uint256 _pid,
        address _owner,
        uint256 _amount
    ) external;


    function emergencyWithdraw(uint256 _pid) external;

}

interface IPoolStoreGov {


    event EmergencyReported(address indexed reporter);
    event EmergencyResolved(address indexed resolver);

    event WeightFeederChanged(
        address indexed operator,
        address indexed oldFeeder,
        address indexed newFeeder
    );

    event PoolAdded(
        address indexed operator,
        uint256 indexed pid,
        string name,
        address token,
        uint256 weight
    );
    event PoolWeightChanged(
        address indexed operator,
        uint256 indexed pid,
        uint256 from,
        uint256 to
    );
    event PoolNameChanged(
        address indexed operator,
        uint256 indexed pid,
        string from,
        string to
    );


    function reportEmergency() external;


    function resolveEmergency() external;


    function setWeightFeeder(address _newFeeder) external;


    function addPool(
        string memory _name,
        IERC20 _token,
        uint256 _weight
    ) external;


    function setPool(uint256 _pid, uint256 _weight) external;


    function setPool(uint256 _pid, string memory _name) external;

}

contract PoolStore is IPoolStore, IPoolStoreGov, Operator {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    struct Pool {
        string name;
        IERC20 token;
        uint256 weight;
        uint256 totalSupply;
    }


    uint256 public override totalWeight = 0;

    Pool[] public pools;
    mapping(uint256 => mapping(address => uint256)) balances;
    mapping(address => uint256[]) public indexByToken;

    bool public emergency = false;
    address public weightFeeder;

    constructor() Operator() {
        weightFeeder = _msgSender();
    }


    function reportEmergency() public override onlyOwner {

        emergency = true;
        emit EmergencyReported(_msgSender());
    }

    function resolveEmergency() public override onlyOwner {

        emergency = false;
        emit EmergencyResolved(_msgSender());
    }

    function setWeightFeeder(address _newFeeder) public override onlyOwner {

        address oldFeeder = weightFeeder;
        weightFeeder = _newFeeder;
        emit WeightFeederChanged(_msgSender(), oldFeeder, _newFeeder);
    }

    function addPool(
        string memory _name,
        IERC20 _token,
        uint256 _weight
    ) public override onlyOwner {

        totalWeight = totalWeight.add(_weight);

        uint256 index = pools.length;
        indexByToken[address(_token)].push(index);

        pools.push(
            Pool({name: _name, token: _token, weight: _weight, totalSupply: 0})
        );
        emit PoolAdded(_msgSender(), index, _name, address(_token), _weight);
    }

    function setPool(uint256 _pid, uint256 _weight)
        public
        override
        onlyWeightFeeder
        checkPoolId(_pid)
    {

        Pool memory pool = pools[_pid];

        uint256 oldWeight = pool.weight;
        totalWeight = totalWeight.add(_weight).sub(pool.weight);
        pool.weight = _weight;

        pools[_pid] = pool;

        emit PoolWeightChanged(_msgSender(), _pid, oldWeight, _weight);
    }

    function setPool(uint256 _pid, string memory _name)
        public
        override
        checkPoolId(_pid)
        onlyOwner
    {

        string memory oldName = pools[_pid].name;
        pools[_pid].name = _name;

        emit PoolNameChanged(_msgSender(), _pid, oldName, _name);
    }


    modifier onlyWeightFeeder {

        require(_msgSender() == weightFeeder, 'PoolStore: unauthorized');

        _;
    }

    modifier checkPoolId(uint256 _pid) {

        require(_pid <= pools.length, 'PoolStore: invalid pid');

        _;
    }

    function poolLength() public view override returns (uint256) {

        return pools.length;
    }

    function poolIdsOf(address _token)
        public
        view
        override
        returns (uint256[] memory)
    {

        return indexByToken[_token];
    }

    function nameOf(uint256 _pid)
        public
        view
        override
        checkPoolId(_pid)
        returns (string memory)
    {

        return pools[_pid].name;
    }

    function tokenOf(uint256 _pid)
        public
        view
        override
        checkPoolId(_pid)
        returns (address)
    {

        return address(pools[_pid].token);
    }

    function weightOf(uint256 _pid)
        public
        view
        override
        checkPoolId(_pid)
        returns (uint256)
    {

        return pools[_pid].weight;
    }

    function totalSupply(uint256 _pid)
        public
        view
        override
        checkPoolId(_pid)
        returns (uint256)
    {

        return pools[_pid].totalSupply;
    }

    function balanceOf(uint256 _pid, address _sender)
        public
        view
        override
        checkPoolId(_pid)
        returns (uint256)
    {

        return balances[_pid][_sender];
    }


    function deposit(
        uint256 _pid,
        address _owner,
        uint256 _amount
    ) public override checkPoolId(_pid) onlyOperator {

        pools[_pid].totalSupply = pools[_pid].totalSupply.add(_amount);
        balances[_pid][_owner] = balances[_pid][_owner].add(_amount);
        IERC20(tokenOf(_pid)).safeTransferFrom(
            _msgSender(),
            address(this),
            _amount
        );

        emit Deposit(_msgSender(), _owner, _pid, _amount);
    }

    function _withdraw(
        uint256 _pid,
        address _owner,
        uint256 _amount
    ) internal {

        pools[_pid].totalSupply = pools[_pid].totalSupply.sub(_amount);
        balances[_pid][_owner] = balances[_pid][_owner].sub(_amount);
        IERC20(tokenOf(_pid)).safeTransfer(_msgSender(), _amount);

        emit Withdraw(_msgSender(), _owner, _pid, _amount);
    }

    function withdraw(
        uint256 _pid,
        address _owner,
        uint256 _amount
    ) public override checkPoolId(_pid) onlyOperator {

        _withdraw(_pid, _owner, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public override checkPoolId(_pid) {

        require(emergency, 'PoolStore: not in emergency');
        _withdraw(_pid, msg.sender, balanceOf(_pid, _msgSender()));
    }
}



pragma solidity >=0.7.0 <0.8.0;





abstract contract PoolStoreWrapper is Context {
    using SafeERC20 for IERC20;

    IPoolStore public store;

    function deposit(uint256 _pid, uint256 _amount) public virtual {
        IERC20(store.tokenOf(_pid)).safeTransferFrom(
            _msgSender(),
            address(this),
            _amount
        );
        store.deposit(_pid, _msgSender(), _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public virtual {
        store.withdraw(_pid, _msgSender(), _amount);
        IERC20(store.tokenOf(_pid)).safeTransfer(_msgSender(), _amount);
    }
}



pragma solidity >=0.7.0 <0.8.0;

interface IPool {


    event DepositToken(
        address indexed owner,
        uint256 indexed pid,
        uint256 amount
    );
    event WithdrawToken(
        address indexed owner,
        uint256 indexed pid,
        uint256 amount
    );
    event RewardClaimed(
        address indexed owner,
        uint256 indexed pid,
        uint256 amount
    );


    function tokenOf(uint256 _pid) external view returns (address);


    function poolIdsOf(address _token) external view returns (uint256[] memory);


    function totalSupply(uint256 _pid) external view returns (uint256);


    function balanceOf(uint256 _pid, address _owner)
        external
        view
        returns (uint256);


    function rewardRatePerPool(uint256 _pid) external view returns (uint256);


    function rewardPerToken(uint256 _pid) external view returns (uint256);


    function rewardEarned(uint256 _pid, address _target)
        external
        view
        returns (uint256);



    function massUpdate(uint256[] memory _pids) external;


    function update(uint256 _pid) external;


    function deposit(uint256 _pid, uint256 _amount) external;


    function withdraw(uint256 _pid, uint256 _amount) external;


    function claimReward(uint256 _pid) external;


    function exit(uint256 _pid) external;

}

interface IPoolGov {


    event RewardNotified(
        address indexed operator,
        uint256 amount,
        uint256 period
    );


    function setPeriod(uint256 _startTime, uint256 _period) external;


    function setReward(uint256 _amount) external;


    function setExtraRewardRate(uint256 _extra) external;


    function stop() external;


    function migrate(address _newPool, uint256 _amount) external;

}





pragma solidity >=0.7.0 <0.8.0;









contract DistributionV2 is IPool, IPoolGov, PoolStoreWrapper, Operator {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    struct User {
        uint256 amount;
        uint256 reward;
        uint256 rewardPerTokenPaid;
    }
    struct Pool {
        bool initialized;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
    }


    address public share;
    mapping(address => bool) public approvals;
    mapping(uint256 => Pool) public pools;
    mapping(uint256 => mapping(address => User)) public users;

    mapping(uint256 => mapping(address => bool)) public oldPoolClaimed;
    address oldPool;

    bool public stopped = false;
    uint256 public rewardRate = 0;
    uint256 public rewardRateExtra = 0;

    uint256 public rewardRateBeforeHalve = 0;
    uint256[] public inflationRate = [0, 0, 400, 350, 300];
    uint256 public year = 1;
    uint256 public startSupply = 860210511822372000000000;

    uint256 public period = 0;
    uint256 public periodFinish = 0;
    uint256 public startTime = 0;


    constructor(address _share, address _poolStore) Ownable() {
        share = _share;
        store = IPoolStore(_poolStore);
    }


    function setPeriod(uint256 _startTime, uint256 _period)
        public
        override
        onlyOperator
    {

        if (startTime <= block.timestamp && block.timestamp < periodFinish) {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = leftover.div(_period);
        }

        period = _period;
        startTime = _startTime;
        periodFinish = _startTime.add(_period);
    }

    function setReward(uint256 _amount) public override onlyOperator {

        require(block.timestamp < periodFinish, 'BACPool: already finished');

        if (startTime <= block.timestamp) {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = _amount.add(leftover).div(
                periodFinish.sub(block.timestamp)
            );
        } else {
            rewardRate = rewardRate.add(
                _amount.div(periodFinish.sub(startTime))
            );
        }
    }

    function setExtraRewardRate(uint256 _extra) public override onlyOwner {

        rewardRateExtra = _extra;
    }

    function setOldPool(address _oldPool) public onlyOwner {

        oldPool = _oldPool;
    }

    function stop() public override onlyOwner {

        periodFinish = block.timestamp;
        stopped = true;
    }

    function migrate(address _newPool, uint256 _amount)
        public
        override
        onlyOwner
    {

        require(stopped, 'BACPool: not stopped');
        IERC20(share).safeTransfer(_newPool, _amount);

        uint256 remaining = startTime.add(period).sub(periodFinish);
        uint256 leftover = remaining.mul(rewardRate);
        IPoolGov(_newPool).setPeriod(block.timestamp.add(1), remaining);
        IPoolGov(_newPool).setReward(leftover);
    }


    modifier updateReward(uint256 _pid, address _target) {

        if (!approvals[store.tokenOf(_pid)]) {
            IERC20(store.tokenOf(_pid)).safeApprove(
                address(store),
                type(uint256).max
            );
            approvals[store.tokenOf(_pid)] = true;
        }

        if (block.timestamp >= startTime) {
            if (!pools[_pid].initialized) {
                pools[_pid] = Pool({
                    initialized: true,
                    rewardRate: rewardRate,
                    lastUpdateTime: startTime,
                    rewardPerTokenStored: 0
                });
            }

            if (!stopped && block.timestamp >= periodFinish) {
                if (block.timestamp < 1638144000) {
                    rewardRateBeforeHalve = rewardRate;
                    rewardRate = rewardRate.mul(89).div(100);
                } else {
                    period = 365 days;
                    year += 1;
                    uint256 periodAll =
                        startSupply.mul(inflationRate[year]).div(10000);
                    rewardRate = periodAll.div(31536000);
                    rewardRateBeforeHalve = rewardRate;
                    startSupply += periodAll;

                    inflationRate.push(200);
                }

                startTime = block.timestamp;
                periodFinish = block.timestamp.add(period);
            }

            Pool memory pool = pools[_pid];
            pool.rewardPerTokenStored = rewardPerToken(_pid);
            if (pool.rewardRate == rewardRateBeforeHalve) {
                pool.rewardRate = rewardRate;
            }
            pool.lastUpdateTime = applicableRewardTime();
            pools[_pid] = pool;

            if (_target != address(0x0)) {
                User memory user = users[_pid][_target];
                user.reward = rewardEarned(_pid, _target);
                if (!oldPoolClaimed[_pid][_target]) {
                    oldPoolClaimed[_pid][_target] = true;
                }

                user.rewardPerTokenPaid = pool.rewardPerTokenStored;
                users[_pid][_target] = user;
            }
        }

        _;
    }


    function tokenOf(uint256 _pid) external view override returns (address) {

        return store.tokenOf(_pid);
    }

    function poolIdsOf(address _token)
        external
        view
        override
        returns (uint256[] memory)
    {

        return store.poolIdsOf(_token);
    }

    function totalSupply(uint256 _pid)
        external
        view
        override
        returns (uint256)
    {

        return store.totalSupply(_pid);
    }

    function balanceOf(uint256 _pid, address _owner)
        external
        view
        override
        returns (uint256)
    {

        return store.balanceOf(_pid, _owner);
    }

    function applicableRewardTime() public view returns (uint256) {

        return Math.min(block.timestamp, periodFinish);
    }

    function _rewardRatePerPool(uint256 _pid, uint256 _crit)
        internal
        view
        returns (uint256)
    {

        return _crit.mul(store.weightOf(_pid)).div(store.totalWeight());
    }

    function rewardRatePerPool(uint256 _pid)
        public
        view
        override
        returns (uint256)
    {

        return _rewardRatePerPool(_pid, rewardRate.add(rewardRateExtra));
    }

    function rewardPerToken(uint256 _pid)
        public
        view
        override
        returns (uint256)
    {

        Pool memory pool = pools[_pid];
        if (store.totalSupply(_pid) == 0 || block.timestamp < startTime) {
            return pool.rewardPerTokenStored;
        }

        if (pool.rewardRate != 0 && pool.rewardRate == rewardRateBeforeHalve) {
            uint256 beforeHalve =
                startTime
                    .sub(pool.lastUpdateTime)
                    .mul(_rewardRatePerPool(_pid, rewardRateBeforeHalve))
                    .mul(1e18)
                    .div(store.totalSupply(_pid));
            uint256 afterHalve =
                applicableRewardTime()
                    .sub(startTime)
                    .mul(rewardRatePerPool(_pid))
                    .mul(1e18)
                    .div(store.totalSupply(_pid));
            return pool.rewardPerTokenStored.add(beforeHalve).add(afterHalve);
        } else {
            return
                pool.rewardPerTokenStored.add(
                    applicableRewardTime()
                        .sub(pool.lastUpdateTime)
                        .mul(rewardRatePerPool(_pid))
                        .mul(1e18)
                        .div(store.totalSupply(_pid))
                );
        }
    }

    function rewardEarned(uint256 _pid, address _target)
        public
        view
        override
        returns (uint256)
    {

        User memory user = users[_pid][_target];
        uint256 oldUnclaim = 0;
        if (oldPool != address(0x0) && !oldPoolClaimed[_pid][_target]) {
            oldUnclaim += IPool(oldPool).rewardEarned(_pid, _target);
        }
        return
            store
                .balanceOf(_pid, _target)
                .mul(rewardPerToken(_pid).sub(user.rewardPerTokenPaid))
                .div(1e18)
                .add(user.reward)
                .add(oldUnclaim);
    }


    function massUpdate(uint256[] memory _pids) public override {

        for (uint256 i = 0; i < _pids.length; i++) {
            update(_pids[i]);
        }
    }

    function update(uint256 _pid)
        public
        override
        updateReward(_pid, address(0x0))
    {}


    function deposit(uint256 _pid, uint256 _amount)
        public
        override(IPool, PoolStoreWrapper)
        updateReward(_pid, _msgSender())
    {

        require(!stopped, 'BASPool: stopped');
        super.deposit(_pid, _amount);
        emit DepositToken(_msgSender(), _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount)
        public
        override(IPool, PoolStoreWrapper)
        updateReward(_pid, _msgSender())
    {

        require(!stopped, 'BASPool: stopped');
        super.withdraw(_pid, _amount);
        emit WithdrawToken(_msgSender(), _pid, _amount);
    }

    function claimReward(uint256 _pid)
        public
        override
        updateReward(_pid, _msgSender())
    {

        claimReward(_pid, _msgSender());
    }

    function claimReward(uint256 _pid, address _owner)
        public
        updateReward(_pid, _owner)
    {

        uint256 reward = users[_pid][_owner].reward;
        if (reward > 0) {
            users[_pid][_owner].reward = 0;
            IERC20(share).safeTransfer(_owner, reward);
            emit RewardClaimed(_owner, _pid, reward);
        }
    }

    function exit(uint256 _pid) external override {

        withdraw(_pid, store.balanceOf(_pid, _msgSender()));
        claimReward(_pid);
    }
}