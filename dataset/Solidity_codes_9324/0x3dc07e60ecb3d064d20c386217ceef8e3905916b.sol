




pragma solidity 0.8.10;

interface ISmartWalletChecker {

    function check(address _addr) external returns (bool);

}





pragma solidity 0.8.10;

interface ICollateralManager {

    function checkStatus(address _addr) external returns (bool);

}



pragma solidity 0.8.10;

interface IOwnership {

    function owner() external view returns (address);


    function futureOwner() external view returns (address);


    function commitTransferOwnership(address newOwner) external;


    function acceptTransferOwnership() external;

}





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



pragma solidity 0.8.10;







contract VotingEscrow is ReentrancyGuard {

    struct Point {
        int256 bias;
        int256 slope; // - dweight / dt
        uint256 ts; //timestamp
        uint256 blk; // block
    }

    struct LockedBalance {
        int256 amount;
        uint256 end;
    }

    int256 constant DEPOSIT_FOR_TYPE = 0;
    int256 constant CREATE_LOCK_TYPE = 1;
    int256 constant INCREASE_LOCK_AMOUNT = 2;
    int256 constant INCREASE_UNLOCK_TIME = 3;

    event Deposit(
        address indexed provider,
        uint256 value,
        uint256 indexed locktime,
        int256 _type,
        uint256 ts
    );
    event Withdraw(address indexed provider, uint256 value, uint256 ts);
    event ForceUnlock(address target, uint256 value, uint256 ts);

    event Supply(uint256 prevSupply, uint256 supply);

    event commitWallet(address newSmartWalletChecker);
    event applyWallet(address newSmartWalletChecker);
    event commitCollateralManager(address newCollateralManager);
    event applyCollateralManager(address newCollateralManager);

    uint256 constant WEEK = 7 * 86400; // all future times are rounded by week
    uint256 constant MAXTIME = 4 * 365 * 86400; // 4 years
    uint256 constant MULTIPLIER = 10 ** 18;

    address public token;
    uint256 public supply;

    mapping(address => LockedBalance) public locked;

    uint256 public epoch;
    Point[100000000000000000000000000000] public point_history; // epoch -> unsigned point.
    mapping(address => Point[1000000000]) public user_point_history; // user -> Point[user_epoch]
    mapping(address => uint256) public user_point_epoch;
    mapping(uint256 => int256) public slope_changes; // time -> signed slope change

    address public controller;
    bool public transfersEnabled;

    string public name;
    string public symbol;
    string public version;
    uint256 public constant decimals = 18;

    address public future_smart_wallet_checker;
    address public smart_wallet_checker;

    address public collateral_manager;
    address public future_collateral_manager;

    IOwnership public immutable ownership;

    modifier onlyOwner() {

        require(
            ownership.owner() == msg.sender,
            "Caller is not allowed to operate"
        );
        _;
    }

    modifier checkStatus() {

        if (collateral_manager != address(0)) {
            require(
                ICollateralManager(collateral_manager).checkStatus(msg.sender),
                "rejected by collateral manager"
            );
        }
        _;
    }

    constructor(
        address _token_addr,
        string memory _name,
        string memory _symbol,
        string memory _version,
        address _ownership
    ) {
        ownership = IOwnership(_ownership);
        token = _token_addr;
        point_history[0].blk = block.number;
        point_history[0].ts = block.timestamp;
        controller = msg.sender;
        transfersEnabled = true;

        name = _name;
        symbol = _symbol;
        version = _version;
    }

    function assert_not_contract(address _addr) internal {

        if (_addr != tx.origin) {
            address checker = smart_wallet_checker; //not going to be deployed at the moment of launch.
            if (checker != address(0)) {
                if (ISmartWalletChecker(checker).check(_addr)) {
                    return;
                }
            }
            revert("contract depositors not allowed");
        }
    }

    function get_last_user_slope(address _addr)
    external
    view
    returns(uint256) {

        uint256 uepoch = user_point_epoch[_addr];
        return uint256(user_point_history[_addr][uepoch].slope);
    }

    function user_point_history__ts(address _addr, uint256 _idx)
    external
    view
    returns(uint256) {

        return user_point_history[_addr][_idx].ts;
    }

    function locked__end(address _addr) external view returns(uint256) {

        return locked[_addr].end;
    }

    function _checkpoint(
        address _addr,
        LockedBalance memory _old_locked,
        LockedBalance memory _new_locked
    ) internal {

        Point memory _u_old;
        Point memory _u_new;
        int256 _old_dslope = 0;
        int256 _new_dslope = 0;
        uint256 _epoch = epoch;

        if (_addr != address(0)) {
            if (_old_locked.end > block.timestamp && _old_locked.amount > 0) {
                unchecked {
                    _u_old.slope = _old_locked.amount / int256(MAXTIME);
                }
                _u_old.bias =
                    _u_old.slope *
                    int256(_old_locked.end - block.timestamp);
            }
            if (_new_locked.end > block.timestamp && _new_locked.amount > 0) {
                unchecked {
                    _u_new.slope = _new_locked.amount / int256(MAXTIME);
                }
                _u_new.bias =
                    _u_new.slope *
                    int256(_new_locked.end - block.timestamp);
            }

            _old_dslope = slope_changes[_old_locked.end];
            if (_new_locked.end != 0) {
                if (_new_locked.end == _old_locked.end) {
                    _new_dslope = _old_dslope;
                } else {
                    _new_dslope = slope_changes[_new_locked.end];
                }
            }
        }
        Point memory _last_point = Point({
            bias: 0,
            slope: 0,
            ts: block.timestamp,
            blk: block.number
        });
        if (_epoch > 0) {
            _last_point = point_history[_epoch];
        }
        uint256 _last_checkpoint = _last_point.ts;
        Point memory _initial_last_point = _last_point;
        uint256 _block_slope = 0; // dblock/dt
        if (block.timestamp > _last_point.ts) {
            _block_slope =
                (MULTIPLIER * (block.number - _last_point.blk)) /
                (block.timestamp - _last_point.ts);
        }

        uint256 _t_i;
        unchecked {
            _t_i = (_last_checkpoint / WEEK) * WEEK;
        }
        for (uint256 i; i < 255;) {
            _t_i += WEEK;
            int256 d_slope = 0;
            if (_t_i > block.timestamp) {
                _t_i = block.timestamp;
            } else {
                d_slope = slope_changes[_t_i];
            }
            _last_point.bias =
                _last_point.bias -
                _last_point.slope *
                int256(_t_i - _last_checkpoint);
            _last_point.slope += d_slope;
            if (_last_point.bias < 0) {
                _last_point.bias = 0;
            }
            if (_last_point.slope < 0) {
                _last_point.slope = 0;
            }
            _last_checkpoint = _t_i;
            _last_point.ts = _t_i;
            _last_point.blk =
                _initial_last_point.blk +
                ((_block_slope * (_t_i - _initial_last_point.ts)) / MULTIPLIER);
            _epoch += 1;
            if (_t_i == block.timestamp) {
                _last_point.blk = block.number;
                break;
            } else {
                point_history[_epoch] = _last_point;
            }
            unchecked {
                ++i;
            }
        }
        epoch = _epoch;

        if (_addr != address(0)) {
            _last_point.slope += _u_new.slope - _u_old.slope;
            _last_point.bias += _u_new.bias - _u_old.bias;
            if (_last_point.slope < 0) {
                _last_point.slope = 0;
            }
            if (_last_point.bias < 0) {
                _last_point.bias = 0;
            }
        }
        point_history[_epoch] = _last_point;

        address _addr2 = _addr; //To avoid being "Stack Too Deep"

        if (_addr2 != address(0)) {
            if (_old_locked.end > block.timestamp) {
                _old_dslope += _u_old.slope;
                if (_new_locked.end == _old_locked.end) {
                    _old_dslope -= _u_new.slope; // It was a new deposit, not extension
                }
                slope_changes[_old_locked.end] = _old_dslope;
            }
            if (_new_locked.end > block.timestamp) {
                if (_new_locked.end > _old_locked.end) {
                    _new_dslope -= _u_new.slope; // old slope disappeared at this point
                    slope_changes[_new_locked.end] = _new_dslope;
                }
            }

            uint256 _user_epoch;
            unchecked {
                _user_epoch = user_point_epoch[_addr2] + 1;
            }

            user_point_epoch[_addr2] = _user_epoch;
            _u_new.ts = block.timestamp;
            _u_new.blk = block.number;
            user_point_history[_addr2][_user_epoch] = _u_new;
        }
    }

    function _deposit_for(
        address _depositor,
        address _beneficiary,
        uint256 _value,
        uint256 _unlock_time,
        LockedBalance memory _locked_balance,
        int256 _type
    ) internal {

        LockedBalance memory _locked = LockedBalance(
            _locked_balance.amount,
            _locked_balance.end
        );
        LockedBalance memory _old_locked = LockedBalance(
            _locked_balance.amount,
            _locked_balance.end
        );

        uint256 _supply_before = supply;
        supply = _supply_before + _value;
        _locked.amount = _locked.amount + int256(_value);
        if (_unlock_time != 0) {
            _locked.end = _unlock_time;
        }
        locked[_beneficiary] = _locked;


        _checkpoint(_beneficiary, _old_locked, _locked);

        if (_value != 0) {
            require(IERC20(token).transferFrom(_depositor, address(this), _value));
        }

        emit Deposit(_beneficiary, _value, _locked.end, _type, block.timestamp);
        emit Supply(_supply_before, _supply_before + _value);
    }

    function checkpoint() public {

        LockedBalance memory _a;
        LockedBalance memory _b;
        _checkpoint(address(0), _a, _b);
    }

    function deposit_for(address _addr, uint256 _value) external nonReentrant {

        LockedBalance memory _locked = locked[_addr];

        require(_value > 0, "dev: need non-zero value");
        require(_locked.amount > 0, "No existing lock found");
        require(
            _locked.end > block.timestamp,
            "Cannot add to expired lock."
        );

        _deposit_for(msg.sender, _addr, _value, 0, _locked, DEPOSIT_FOR_TYPE);
    }

    function create_lock(uint256 _value, uint256 _unlock_time)external nonReentrant {

        assert_not_contract(msg.sender);
        _unlock_time = (_unlock_time / WEEK) * WEEK; // Locktime is rounded down to weeks
        LockedBalance memory _locked = locked[msg.sender];

        require(_value > 0, "dev: need non-zero value");
        require(_locked.amount == 0, "Withdraw old tokens first");
        require(
            _unlock_time > block.timestamp,
            "Can lock until time in future"
        );
        require(
            _unlock_time <= block.timestamp + MAXTIME,
            "Voting lock can be 4 years max"
        );

        _deposit_for(
            msg.sender,
            msg.sender,
            _value,
            _unlock_time,
            _locked,
            CREATE_LOCK_TYPE
        );
    }

    function increase_amount(uint256 _value) external nonReentrant {

        assert_not_contract(msg.sender);
        LockedBalance memory _locked = locked[msg.sender];

        require(_value > 0);
        require(_locked.amount > 0, "No existing lock found");
        require(
            _locked.end > block.timestamp,
            "Cannot add to expired lock."
        );

        _deposit_for(msg.sender, msg.sender, _value, 0, _locked, INCREASE_LOCK_AMOUNT);
    }

    function increase_unlock_time(uint256 _unlock_time) external nonReentrant {

        assert_not_contract(msg.sender); //@shun: need to convert to solidity
        LockedBalance memory _locked = locked[msg.sender];
        unchecked {
            _unlock_time = (_unlock_time / WEEK) * WEEK; // Locktime is rounded down to weeks
        }

        require(_locked.end > block.timestamp, "Lock expired");
        require(_locked.amount > 0, "Nothing is locked");
        require(_unlock_time > _locked.end, "Can only increase lock duration");
        require(
            _unlock_time <= block.timestamp + MAXTIME,
            "Voting lock can be 4 years max"
        );

        _deposit_for(
            msg.sender,
            msg.sender,
            0,
            _unlock_time,
            _locked,
            INCREASE_UNLOCK_TIME
        );
    }

    function withdraw() external checkStatus nonReentrant {

        LockedBalance memory _locked = LockedBalance(
            locked[msg.sender].amount,
            locked[msg.sender].end
        );

        require(block.timestamp >= _locked.end, "The lock didn't expire");
        uint256 _value = uint256(_locked.amount);

        LockedBalance memory _old_locked = LockedBalance(
            locked[msg.sender].amount,
            locked[msg.sender].end
        );

        _locked.end = 0;
        _locked.amount = 0;
        locked[msg.sender] = _locked;
        uint256 _supply_before = supply;
        supply = _supply_before - _value;

        _checkpoint(msg.sender, _old_locked, _locked);

        require(IERC20(token).transfer(msg.sender, _value));

        emit Withdraw(msg.sender, _value, block.timestamp);
        emit Supply(_supply_before, _supply_before - _value);
    }


    function find_block_epoch(uint256 _block, uint256 _max_epoch) internal view returns(uint256) {

        uint256 _min = 0;
        uint256 _max = _max_epoch;
        unchecked {
            for (uint256 i; i <= 128; i++) {
                if (_min >= _max) {
                    break;
                }
                uint256 _mid = (_min + _max + 1) / 2;
                if (point_history[_mid].blk <= _block) {
                    _min = _mid;
                } else {
                    _max = _mid - 1;
                }
            }
        }
        return _min;
    }

    function balanceOf(address _addr) external view returns(uint256) {


        uint256 _t = block.timestamp;

        uint256 _epoch = user_point_epoch[_addr];
        if (_epoch == 0) {
            return 0;
        } else {
            Point memory _last_point = user_point_history[_addr][_epoch];
            _last_point.bias -= _last_point.slope * int256(_t - _last_point.ts);
            if (_last_point.bias < 0) {
                _last_point.bias = 0;
            }
            return uint256(_last_point.bias);
        }
    }

    function balanceOf(address _addr, uint256 _t) external view returns(uint256) {

        if (_t == 0) {
            _t = block.timestamp;
        }

        uint256 _epoch = user_point_epoch[_addr];
        if (_epoch == 0) {
            return 0;
        } else {
            Point memory _last_point = user_point_history[_addr][_epoch];
            _last_point.bias -= _last_point.slope * int256(_t - _last_point.ts);
            if (_last_point.bias < 0) {
                _last_point.bias = 0;
            }
            return uint256(_last_point.bias);
        }
    }

    struct Parameters {
        uint256 min;
        uint256 max;
        uint256 max_epoch;
        uint256 d_block;
        uint256 d_t;
    }

    function balanceOfAt(address _addr, uint256 _block) external view returns(uint256) {

        require(_block <= block.number);

        Parameters memory _st;

        _st.min = 0;
        _st.max = user_point_epoch[_addr];
        unchecked {
            for (uint256 i; i <= 128; i++) {
                if (_st.min >= _st.max) {
                    break;
                }
                uint256 _mid = (_st.min + _st.max + 1) / 2;
                if (user_point_history[_addr][_mid].blk <= _block) {
                    _st.min = _mid;
                } else {
                    _st.max = _mid - 1;
                }
            }
        }

        Point memory _upoint = user_point_history[_addr][_st.min];

        _st.max_epoch = epoch;
        uint256 _epoch = find_block_epoch(_block, _st.max_epoch);
        Point memory _point_0 = point_history[_epoch];
        _st.d_block = 0;
        _st.d_t = 0;
        if (_epoch < _st.max_epoch) {
            Point memory _point_1 = point_history[_epoch + 1];
            _st.d_block = _point_1.blk - _point_0.blk;
            _st.d_t = _point_1.ts - _point_0.ts;
        } else {
            _st.d_block = block.number - _point_0.blk;
            _st.d_t = block.timestamp - _point_0.ts;
        }
        uint256 block_time = _point_0.ts;
        if (_st.d_block != 0) {
            block_time += (_st.d_t * (_block - _point_0.blk)) / _st.d_block;
        }

        _upoint.bias -= _upoint.slope * int256(block_time - _upoint.ts);
        if (_upoint.bias >= 0) {
            return uint256(_upoint.bias);
        }
    }

    function supply_at(Point memory point, uint256 t) internal view returns(uint256) {

        Point memory _last_point = point;
        uint256 _t_i;
        unchecked {
            _t_i = (_last_point.ts / WEEK) * WEEK;
        }
        for (uint256 i; i < 255;) {
            _t_i += WEEK;
            int256 d_slope = 0;

            if (_t_i > t) {
                _t_i = t;
            } else {
                d_slope = slope_changes[_t_i];
            }
            _last_point.bias -=
                _last_point.slope *
                int256(_t_i - _last_point.ts);

            if (_t_i == t) {
                break;
            }
            _last_point.slope += d_slope;
            _last_point.ts = _t_i;
            unchecked {
                ++i;
            }
        }

        if (_last_point.bias < 0) {
            _last_point.bias = 0;
        }
        return uint256(_last_point.bias);
    }


    function totalSupply() external view returns(uint256) {

        uint256 _epoch = epoch;
        Point memory _last_point = point_history[_epoch];

        return supply_at(_last_point, block.timestamp);
    }

    function totalSupply(uint256 _t) external view returns(uint256) {

        if (_t == 0) {
            _t = block.timestamp;
        }

        uint256 _epoch = epoch;
        Point memory _last_point = point_history[_epoch];

        return supply_at(_last_point, _t);
    }

    function totalSupplyAt(uint256 _block) external view returns(uint256) {

        require(_block <= block.number);
        uint256 _epoch = epoch;
        uint256 _target_epoch = find_block_epoch(_block, _epoch);

        Point memory _point = point_history[_target_epoch];
        uint256 dt = 0;
        if (_target_epoch < _epoch) {
            Point memory _point_next = point_history[_target_epoch + 1];
            if (_point.blk != _point_next.blk) {
                dt =
                    ((_block - _point.blk) * (_point_next.ts - _point.ts)) /
                    (_point_next.blk - _point.blk);
            }
        } else {
            if (_point.blk != block.number) {
                dt =
                    ((_block - _point.blk) * (block.timestamp - _point.ts)) /
                    (block.number - _point.blk);
            }
        }

        return supply_at(_point, _point.ts + dt);
    }

    function changeController(address _newController) external {

        require(msg.sender == controller);
        controller = _newController;
    }

    function get_user_point_epoch(address _user)
    external
    view
    returns(uint256) {

        return user_point_epoch[_user];
    }


    function force_unlock(address _target) external returns(bool) {

        require(
            msg.sender == collateral_manager,
            "only collateral manager allowed"
        );

        LockedBalance memory _locked = LockedBalance(
            locked[_target].amount,
            locked[_target].end
        );
        LockedBalance memory _old_locked = LockedBalance(
            locked[_target].amount,
            locked[_target].end
        );

        uint256 value = uint256(_locked.amount);

        require(value != 0, "There is no locked INSURE");

        _locked.end = 0;
        _locked.amount = 0;
        locked[_target] = _locked;
        uint256 _supply_before = supply;
        supply = _supply_before - value;

        _checkpoint(_target, _old_locked, _locked);

        require(IERC20(token).transfer(collateral_manager, value));

        emit ForceUnlock(_target, value, block.timestamp);
        emit Supply(_supply_before, _supply_before - value);

        return true;
    }

    function commit_smart_wallet_checker(address _addr) external onlyOwner {

        future_smart_wallet_checker = _addr;

        emit commitWallet(_addr);
    }

    function apply_smart_wallet_checker() external onlyOwner {

        address _future_smart_wallet_checker = future_smart_wallet_checker;
        smart_wallet_checker = _future_smart_wallet_checker;

        emit commitWallet(_future_smart_wallet_checker);
    }

    function commit_collateral_manager(address _new_collateral_manager) external onlyOwner {

        future_collateral_manager = _new_collateral_manager;

        emit commitCollateralManager(_new_collateral_manager);
    }

    function apply_collateral_manager() external onlyOwner {

        address _future_collateral_manager = future_collateral_manager;
        collateral_manager = _future_collateral_manager;

        emit applyCollateralManager(_future_collateral_manager);
    }
}