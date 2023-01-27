
pragma solidity 0.8.10;

interface IInsureToken {

    function mint(address _to, uint256 _value)external returns(bool);

    function emergency_mint(uint256 _amountOut, address _to)external;

    function approve(address _spender, uint256 _value)external;

    function rate()external view returns(uint256);

    function future_epoch_time_write() external returns(uint256);

}// MIT

pragma solidity 0.8.10;

interface IVotingEscrow {

    function get_last_user_slope(address _addr) external view returns (uint256);


    function locked__end(address _addr) external view returns (uint256);


    function balanceOf(address _addr, uint256 _t)
        external
        view
        returns (uint256);


    function totalSupply(uint256 _t) external view returns (uint256);


    function get_user_point_epoch(address _user)
        external
        view
        returns (uint256);


    function user_point_history__ts(address _addr, uint256 _idx)
        external
        view
        returns (uint256);

}pragma solidity 0.8.10;


interface IOwnership {

    function owner() external view returns (address);


    function futureOwner() external view returns (address);


    function commitTransferOwnership(address newOwner) external;


    function acceptTransferOwnership() external;

}pragma solidity 0.8.10;



contract GaugeController {

    uint256 constant WEEK = 604800;

    uint256 constant WEIGHT_VOTE_DELAY = 10 * 86400;

    struct Point {
        uint256 bias;
        uint256 slope;
    }

    struct VotedSlope {
        uint256 slope;
        uint256 power;
        uint256 end;
    }

    event AddType(string name, uint256 type_id);
    event NewTypeWeight(
        uint256 type_id,
        uint256 time,
        uint256 weight,
        uint256 total_weight
    );

    event NewGaugeWeight(
        address gauge_address,
        uint256 time,
        uint256 weight,
        uint256 total_weight
    );
    event VoteForGauge(
        uint256 time,
        address user,
        address gauge_addr,
        uint256 weight
    );
    event NewGauge(address addr, uint256 gauge_type, uint256 weight);

    uint256 constant MULTIPLIER = 10 ** 18;

    IInsureToken public token;
    IVotingEscrow public voting_escrow;

    uint256 public n_gauge_types = 1; // There is [gauge_type(0) : unset] as default. [gauge_type(1) : LiquidityGauge] will be added as the contract is deployed, and "n_gauge_types" will be incremented to 2. This part is modified from Curve's contract.
    uint256 public n_gauges; //number of gauges
    mapping(uint256 => string) public gauge_type_names;

    address[1000000000] public gauges;

    mapping(address => uint256) gauge_types_;
    mapping(address => mapping(address => VotedSlope)) public vote_user_slopes; // user -> gauge_addr -> VotedSlope
    mapping(address => uint256) public vote_user_power; // Total vote power used by user
    mapping(address => mapping(address => uint256)) public last_user_vote; // Last user vote's timestamp for each gauge address


    mapping(address => mapping(uint256 => Point)) public points_weight; // gauge_addr -> time -> Point
    mapping(address => mapping(uint256 => uint256)) public changes_weight; // gauge_addr -> time -> slope
    mapping(address => uint256) public time_weight; // gauge_addr -> last scheduled time (next week)

    mapping(uint256 => mapping(uint256 => Point)) public points_sum; // type_id -> time -> Point
    mapping(uint256 => mapping(uint256 => uint256)) public changes_sum; // type_id -> time -> slope
    uint256[1000000000] public time_sum; // type_id -> last scheduled time (next week)

    mapping(uint256 => uint256) public points_total; // time -> total weight
    uint256 public time_total; // last scheduled time

    mapping(uint256 => mapping(uint256 => uint256)) public points_type_weight; // type_id -> time -> type weight
    uint256[1000000000] public time_type_weight; // type_id -> last scheduled time (next week)


    IOwnership public immutable ownership;

    modifier onlyOwner() {

        require(
            ownership.owner() == msg.sender,
            "Caller is not allowed to operate"
        );
        _;
    }

    constructor(address _token, address _voting_escrow, address _ownership) {
        require(_token != address(0));
        require(_voting_escrow != address(0));

        ownership = IOwnership(_ownership);
        token = IInsureToken(_token);
        voting_escrow = IVotingEscrow(_voting_escrow);
        time_total = (block.timestamp / WEEK) * WEEK;
    }

    function get_voting_escrow() external view returns(address) {

        return address(voting_escrow);
    }

    function gauge_types(address _addr) external view returns(uint256) {


        uint256 _gauge_type = gauge_types_[_addr];

        return _gauge_type; //LG = 1
    }

    function _get_type_weight(uint256 _gauge_type) internal returns(uint256) {


        require(_gauge_type != 0, "unset"); //s
        uint256 _t = time_type_weight[_gauge_type];
        if (_t > 0) {
            uint256 _w = points_type_weight[_gauge_type][_t];
            for (uint256 i; i < 500;) {
                if (_t > block.timestamp) {
                    break;
                }
                _t += WEEK;
                points_type_weight[_gauge_type][_t] = _w;
                if (_t > block.timestamp) {
                    time_type_weight[_gauge_type] = _t;
                }
                unchecked {
                    ++i;
                }
            }
            return _w;
        }
    }


    function _get_sum(uint256 _gauge_type) internal returns(uint256) {


        require(_gauge_type != 0, "unset");
        uint256 _t = time_sum[_gauge_type];
        if (_t > 0) {
            Point memory _pt = points_sum[_gauge_type][_t];
            for (uint256 i; i < 500;) {
                if (_t > block.timestamp) {
                    break;
                }
                _t += WEEK;
                uint256 _d_bias = _pt.slope * WEEK;
                if (_pt.bias > _d_bias) {
                    _pt.bias -= _d_bias;
                    uint256 _d_slope = changes_sum[_gauge_type][_t];
                    _pt.slope -= _d_slope;
                } else {
                    _pt.bias = 0;
                    _pt.slope = 0;
                }
                points_sum[_gauge_type][_t] = _pt;
                if (_t > block.timestamp) {
                    time_sum[_gauge_type] = _t;
                }
                unchecked {
                    ++i;
                }
            }
            return _pt.bias;
        }
    }

    function _get_total() internal returns(uint256) {


        uint256 _t = time_total;
        uint256 _n_gauge_types = n_gauge_types;
        if (_t > block.timestamp) {
            _t -= WEEK;
        }
        uint256 _pt = points_total[_t];

        for (uint256 _gauge_type = 1; _gauge_type < 100;) {
            if (_gauge_type == _n_gauge_types) {
                break;
            }
            _get_sum(_gauge_type);
            _get_type_weight(_gauge_type);
            unchecked {
                ++_gauge_type;
            }
        }
        for (uint256 i; i < 500;) {
            if (_t > block.timestamp) {
                break;
            }
            _t += WEEK;
            _pt = 0;
            for (uint256 _gauge_type = 1; _gauge_type < 100;) {
                if (_gauge_type == _n_gauge_types) {
                    break;
                }
                uint256 _type_sum = points_sum[_gauge_type][_t].bias;
                uint256 _type_weight = points_type_weight[_gauge_type][_t];
                _pt += _type_sum * _type_weight;
                unchecked {
                    ++_gauge_type;
                }
            }
            points_total[_t] = _pt;

            if (_t > block.timestamp) {
                time_total = _t;
            }
            unchecked {
                ++i;
            }
        }
        return _pt;
    }

    function _get_weight(address _gauge_addr) internal returns(uint256) {


        uint256 _t = time_weight[_gauge_addr];
        if (_t > 0) {
            Point memory _pt = points_weight[_gauge_addr][_t];
            for (uint256 i; i < 500;) {
                if (_t > block.timestamp) {
                    break;
                }
                _t += WEEK;
                uint256 _d_bias = _pt.slope * WEEK;
                if (_pt.bias > _d_bias) {
                    _pt.bias -= _d_bias;
                    uint256 _d_slope = changes_weight[_gauge_addr][_t];
                    _pt.slope -= _d_slope;
                } else {
                    _pt.bias = 0;
                    _pt.slope = 0;
                }
                points_weight[_gauge_addr][_t] = _pt;
                if (_t > block.timestamp) {
                    time_weight[_gauge_addr] = _t;
                }
                unchecked {
                    ++i;
                }
            }
            return _pt.bias;
        }
    }

    function add_gauge(
        address _addr,
        uint256 _gauge_type,
        uint256 _weight
    ) external onlyOwner {

        require((_gauge_type >= 1) && (_gauge_type < n_gauge_types)); //gauge_type 0 means unset
        require(
            gauge_types_[_addr] == 0,
            "cannot add the same gauge twice"
        ); //before adding, addr must be 0 in the mapping.
        uint256 _n = n_gauges;
        unchecked {
            n_gauges = _n + 1;
        }
        gauges[_n] = _addr;

        gauge_types_[_addr] = _gauge_type;
        uint256 _next_time;
        unchecked {
            _next_time = ((block.timestamp + WEEK) / WEEK) * WEEK;
        }

        if (_weight > 0) {
            uint256 _type_weight = _get_type_weight(_gauge_type);
            uint256 _old_sum = _get_sum(_gauge_type);
            uint256 _old_total = _get_total();

            points_sum[_gauge_type][_next_time].bias = _weight + _old_sum;
            time_sum[_gauge_type] = _next_time;
            points_total[_next_time] = _old_total + (_type_weight * _weight);
            time_total = _next_time;

            points_weight[_addr][_next_time].bias = _weight;
        }
        if (time_sum[_gauge_type] == 0) {
            time_sum[_gauge_type] = _next_time;
        }
        time_weight[_addr] = _next_time;

        emit NewGauge(_addr, _gauge_type, _weight);
    }

    function checkpoint() external {


        _get_total();
    }

    function checkpoint_gauge(address _addr) external {


        _get_weight(_addr);
        _get_total();
    }

    function _gauge_relative_weight(address _addr, uint256 _time)
    internal
    view
    returns(uint256) {


        uint256 _t = (_time / WEEK) * WEEK;
        uint256 _total_weight = points_total[_t];

        if (_total_weight > 0) {
            uint256 _gauge_type = gauge_types_[_addr];
            uint256 _type_weight = points_type_weight[_gauge_type][_t];
            uint256 _gauge_weight = points_weight[_addr][_t].bias;

            return (MULTIPLIER * _type_weight * _gauge_weight) / _total_weight;
        }
    }

    function gauge_relative_weight(address _addr, uint256 _time)
    external
    view
    returns(uint256) {

        if (_time == 0) {
            _time = block.timestamp;
        }

        return _gauge_relative_weight(_addr, _time);
    }

    function gauge_relative_weight_write(address _addr, uint256 _time)
    external
    returns(uint256) {

        if (_time == 0) {
            _time = block.timestamp;
        }

        _get_weight(_addr);
        _get_total(); // Also calculates get_sum
        return _gauge_relative_weight(_addr, _time);
    }

    function _change_type_weight(uint256 _type_id, uint256 _weight) internal {

        uint256 _old_weight = _get_type_weight(_type_id);
        uint256 _old_sum = _get_sum(_type_id);
        uint256 _total_weight = _get_total();
        uint256 _next_time;
        unchecked {
            _next_time = ((block.timestamp + WEEK) / WEEK) * WEEK;
        }

        _total_weight =
            _total_weight +
            (_old_sum * _weight) -
            (_old_sum * _old_weight);
        points_total[_next_time] = _total_weight;
        points_type_weight[_type_id][_next_time] = _weight;
        time_total = _next_time;
        time_type_weight[_type_id] = _next_time;

        emit NewTypeWeight(_type_id, _next_time, _weight, _total_weight);
    }

    function add_type(string memory _name, uint256 _weight) external onlyOwner {


        uint256 _type_id = n_gauge_types;
        gauge_type_names[_type_id] = _name;
        unchecked {
            n_gauge_types = _type_id + 1;
        }
        if (_weight != 0) {
            _change_type_weight(_type_id, _weight);
            emit AddType(_name, _type_id);
        }
    }

    function change_type_weight(uint256 _type_id, uint256 _weight) external onlyOwner {


        _change_type_weight(_type_id, _weight);
    }

    function _change_gauge_weight(address _addr, uint256 _weight) internal {

        uint256 _gauge_type = gauge_types_[_addr];
        uint256 _old_gauge_weight = _get_weight(_addr);
        uint256 _type_weight = _get_type_weight(_gauge_type);
        uint256 _old_sum = _get_sum(_gauge_type);
        uint256 _total_weight = _get_total();
        uint256 _next_time;
        unchecked {
            _next_time = ((block.timestamp + WEEK) / WEEK) * WEEK;
        }

        points_weight[_addr][_next_time].bias = _weight;
        time_weight[_addr] = _next_time;

        uint256 new_sum = _old_sum + _weight - _old_gauge_weight;
        points_sum[_gauge_type][_next_time].bias = new_sum;
        time_sum[_gauge_type] = _next_time;

        _total_weight =
            _total_weight +
            (new_sum * _type_weight) -
            (_old_sum * _type_weight);
        points_total[_next_time] = _total_weight;
        time_total = _next_time;

        emit NewGaugeWeight(_addr, block.timestamp, _weight, _total_weight);
    }

    function change_gauge_weight(address _addr, uint256 _weight) external onlyOwner {


        _change_gauge_weight(_addr, _weight);
    }

    struct VotingParameter {
        uint256 slope;
        uint256 lock_end;
        uint256 _n_gauges;
        uint256 next_time;
        uint256 gauge_type;
        uint256 old_dt;
        uint256 old_bias;
    }

    function vote_for_gauge_weights(address _gauge_addr, uint256 _user_weight) external {

        VotingParameter memory _vp;
        _vp.slope = uint256(voting_escrow.get_last_user_slope(msg.sender));
        _vp.lock_end = voting_escrow.locked__end(msg.sender);
        _vp._n_gauges = n_gauges;
        unchecked {
            _vp.next_time = ((block.timestamp + WEEK) / WEEK) * WEEK;
        }
        require(
            _vp.lock_end > _vp.next_time,
            "Your token lock expires too soon"
        );
        require(
            (_user_weight >= 0) && (_user_weight <= 10000),
            "You used all your voting power"
        );
        uint256 _voteTime;
        unchecked {
            require(
                block.timestamp >= last_user_vote[msg.sender][_gauge_addr] + WEIGHT_VOTE_DELAY,
                "Cannot vote so often"
            );
        }

        _vp.gauge_type = gauge_types_[_gauge_addr];
        require(_vp.gauge_type >= 1, "Gauge not added");
        VotedSlope memory _old_slope = vote_user_slopes[msg.sender][
            _gauge_addr
        ];
        _vp.old_dt = 0;
        if (_old_slope.end > _vp.next_time) {
            _vp.old_dt = _old_slope.end - _vp.next_time;
        }
        _vp.old_bias = _old_slope.slope * _vp.old_dt;
        VotedSlope memory _new_slope = VotedSlope({
            slope: (_vp.slope * _user_weight) / 10000,
            power: _user_weight,
            end: _vp.lock_end
        });
        uint256 _new_dt = _vp.lock_end - _vp.next_time; // dev: raises when expired
        uint256 _new_bias = _new_slope.slope * _new_dt;

        uint256 _power_used = vote_user_power[msg.sender];
        _power_used = _power_used + _new_slope.power - _old_slope.power;
        vote_user_power[msg.sender] = _power_used;
        require(
            (_power_used >= 0) && (_power_used <= 10000),
            "Used too much power"
        );

        uint256 _old_weight_bias = _get_weight(_gauge_addr);
        uint256 _old_weight_slope = points_weight[_gauge_addr][_vp.next_time]
            .slope;
        uint256 _old_sum_bias = _get_sum(_vp.gauge_type);
        uint256 _old_sum_slope = points_sum[_vp.gauge_type][_vp.next_time]
            .slope;

        points_weight[_gauge_addr][_vp.next_time].bias =
            max(_old_weight_bias + _new_bias, _vp.old_bias) -
            _vp.old_bias;
        points_sum[_vp.gauge_type][_vp.next_time].bias =
            max(_old_sum_bias + _new_bias, _vp.old_bias) -
            _vp.old_bias;
        if (_old_slope.end > _vp.next_time) {
            points_weight[_gauge_addr][_vp.next_time].slope =
                max(_old_weight_slope + _new_slope.slope, _old_slope.slope) -
                _old_slope.slope;
            points_sum[_vp.gauge_type][_vp.next_time].slope =
                max(_old_sum_slope + _new_slope.slope, _old_slope.slope) -
                _old_slope.slope;
        } else {
            points_weight[_gauge_addr][_vp.next_time].slope += _new_slope.slope;
            points_sum[_vp.gauge_type][_vp.next_time].slope += _new_slope.slope;
        }
        if (_old_slope.end > block.timestamp) {
            changes_weight[_gauge_addr][_old_slope.end] -= _old_slope.slope;
            changes_sum[_vp.gauge_type][_old_slope.end] -= _old_slope.slope;
        }
        changes_weight[_gauge_addr][_new_slope.end] += _new_slope.slope;
        changes_sum[_vp.gauge_type][_new_slope.end] += _new_slope.slope;

        _get_total();

        vote_user_slopes[msg.sender][_gauge_addr] = _new_slope;

        last_user_vote[msg.sender][_gauge_addr] = block.timestamp;

        emit VoteForGauge(
            block.timestamp,
            msg.sender,
            _gauge_addr,
            _user_weight
        );
    }

    function get_gauge_weight(address _addr) external view returns(uint256) {

        return points_weight[_addr][time_weight[_addr]].bias;
    }

    function get_type_weight(uint256 _type_id) external view returns(uint256) {


        return points_type_weight[_type_id][time_type_weight[_type_id]];
    }

    function get_total_weight() external view returns(uint256) {

        return points_total[time_total];
    }

    function get_weights_sum_per_type(uint256 _type_id) external view returns(uint256) {

        return points_sum[_type_id][time_sum[_type_id]].bias;
    }

    function max(uint256 _a, uint256 _b) internal pure returns(uint256) {

        return _a >= _b ? _a : _b;
    }
}