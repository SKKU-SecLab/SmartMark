

pragma solidity ^0.5.11;


interface IERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}


pragma solidity ^0.5.11;



contract Model is IERC165 {


    event Created(bytes32 indexed _id);

    event ChangedStatus(bytes32 indexed _id, uint256 _timestamp, uint256 _status);

    event ChangedObligation(bytes32 indexed _id, uint256 _timestamp, uint256 _debt);

    event ChangedFrequency(bytes32 indexed _id, uint256 _timestamp, uint256 _frequency);

    event ChangedDueTime(bytes32 indexed _id, uint256 _timestamp, uint256 _status);

    event ChangedFinalTime(bytes32 indexed _id, uint256 _timestamp, uint64 _dueTime);

    event AddedDebt(bytes32 indexed _id, uint256 _amount);

    event AddedPaid(bytes32 indexed _id, uint256 _paid);

    bytes4 internal constant MODEL_INTERFACE = 0xaf498c35;

    uint256 public constant STATUS_ONGOING = 1;
    uint256 public constant STATUS_PAID = 2;
    uint256 public constant STATUS_ERROR = 4;


    function modelId() external view returns (bytes32);


    function descriptor() external view returns (address);


    function isOperator(address operator) external view returns (bool canOperate);


    function validate(bytes calldata data) external view returns (bool isValid);



    function getStatus(bytes32 id) external view returns (uint256 status);


    function getPaid(bytes32 id) external view returns (uint256 paid);


    function getObligation(bytes32 id, uint64 timestamp) external view returns (uint256 amount, bool defined);


    function getClosingObligation(bytes32 id) external view returns (uint256 amount);


    function getDueTime(bytes32 id) external view returns (uint256 timestamp);



    function getFrequency(bytes32 id) external view returns (uint256 frequency);


    function getInstallments(bytes32 id) external view returns (uint256 installments);


    function getFinalTime(bytes32 id) external view returns (uint256 timestamp);


    function getEstimateObligation(bytes32 id) external view returns (uint256 amount);



    function create(bytes32 id, bytes calldata data) external returns (bool success);


    function addPaid(bytes32 id, uint256 amount) external returns (uint256 real);


    function addDebt(bytes32 id, uint256 amount) external returns (bool added);



    function run(bytes32 id) external returns (bool effect);

}


pragma solidity ^0.5.11;


contract ModelDescriptor {

    bytes4 internal constant MODEL_DESCRIPTOR_INTERFACE = 0x02735375;

    function simFirstObligation(bytes calldata data) external view returns (uint256 amount, uint256 time);

    function simTotalObligation(bytes calldata data) external view returns (uint256 amount);

    function simDuration(bytes calldata data) external view returns (uint256 duration);

    function simPunitiveInterestRate(bytes calldata data) external view returns (uint256 punitiveInterestRate);

    function simFrequency(bytes calldata data) external view returns (uint256 frequency);

    function simInstallments(bytes calldata data) external view returns (uint256 installments);

}


pragma solidity ^0.5.11;


contract IERC173 {

    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);


    function transferOwnership(address _newOwner) external;

}


pragma solidity ^0.5.11;



contract Ownable is IERC173 {

    address internal _owner;

    modifier onlyOwner() {

        require(msg.sender == _owner, "The owner should be the sender");
        _;
    }

    function _initOwner(address owner) internal {

        assert(_owner == address(0));
        _owner = owner;
        emit OwnershipTransferred(address(0x0), owner);
    }

    function owner() external view returns (address) {

        return _owner;
    }

    function transferOwnership(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "0x0 Is not a valid owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }
}


pragma solidity ^0.5.11;



contract ERC165 is IERC165 {

    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor()
        internal
    {
        _registerInterface(_InterfaceId_ERC165);
    }

    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool)
    {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId)
        internal
    {

        require(interfaceId != 0xffffffff, "Can't register 0xffffffff");
        _supportedInterfaces[interfaceId] = true;
    }
}


pragma solidity ^0.5.11;


contract BytesUtils {

    function readBytes32(bytes memory data, uint256 index) internal pure returns (bytes32 o) {

        require(data.length / 32 > index, "Reading bytes out of bounds");
        assembly {
            o := mload(add(data, add(32, mul(32, index))))
        }
    }

    function read(bytes memory data, uint256 offset, uint256 length) internal pure returns (bytes32 o) {

        require(data.length >= offset + length, "Reading bytes out of bounds");
        assembly {
            o := mload(add(data, add(32, offset)))
            let lb := sub(32, length)
            if lb { o := div(o, exp(2, mul(lb, 8))) }
        }
    }

    function decode(
        bytes memory _data,
        uint256 _la
    ) internal pure returns (bytes32 _a) {

        require(_data.length >= _la, "Reading bytes out of bounds");
        assembly {
            _a := mload(add(_data, 32))
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
        }
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb
    ) internal pure returns (bytes32 _a, bytes32 _b) {

        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb,
        uint256 _lc
    ) internal pure returns (bytes32 _a, bytes32 _b, bytes32 _c) {

        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := add(o, _lb)
            _c := mload(o)
            l := sub(32, _lc)
            if l { _c := div(_c, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb,
        uint256 _lc,
        uint256 _ld
    ) internal pure returns (bytes32 _a, bytes32 _b, bytes32 _c, bytes32 _d) {

        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := add(o, _lb)
            _c := mload(o)
            l := sub(32, _lc)
            if l { _c := div(_c, exp(2, mul(l, 8))) }
            o := add(o, _lc)
            _d := mload(o)
            l := sub(32, _ld)
            if l { _d := div(_d, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb,
        uint256 _lc,
        uint256 _ld,
        uint256 _le
    ) internal pure returns (bytes32 _a, bytes32 _b, bytes32 _c, bytes32 _d, bytes32 _e) {

        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := add(o, _lb)
            _c := mload(o)
            l := sub(32, _lc)
            if l { _c := div(_c, exp(2, mul(l, 8))) }
            o := add(o, _lc)
            _d := mload(o)
            l := sub(32, _ld)
            if l { _d := div(_d, exp(2, mul(l, 8))) }
            o := add(o, _ld)
            _e := mload(o)
            l := sub(32, _le)
            if l { _e := div(_e, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

    function decode(
        bytes memory _data,
        uint256 _la,
        uint256 _lb,
        uint256 _lc,
        uint256 _ld,
        uint256 _le,
        uint256 _lf
    ) internal pure returns (
        bytes32 _a,
        bytes32 _b,
        bytes32 _c,
        bytes32 _d,
        bytes32 _e,
        bytes32 _f
    ) {

        uint256 o;
        assembly {
            let s := add(_data, 32)
            _a := mload(s)
            let l := sub(32, _la)
            if l { _a := div(_a, exp(2, mul(l, 8))) }
            o := add(s, _la)
            _b := mload(o)
            l := sub(32, _lb)
            if l { _b := div(_b, exp(2, mul(l, 8))) }
            o := add(o, _lb)
            _c := mload(o)
            l := sub(32, _lc)
            if l { _c := div(_c, exp(2, mul(l, 8))) }
            o := add(o, _lc)
            _d := mload(o)
            l := sub(32, _ld)
            if l { _d := div(_d, exp(2, mul(l, 8))) }
            o := add(o, _ld)
            _e := mload(o)
            l := sub(32, _le)
            if l { _e := div(_e, exp(2, mul(l, 8))) }
            o := add(o, _le)
            _f := mload(o)
            l := sub(32, _lf)
            if l { _f := div(_f, exp(2, mul(l, 8))) }
            o := sub(o, s)
        }
        require(_data.length >= o, "Reading bytes out of bounds");
    }

}


pragma solidity ^0.5.11;







contract InstallmentsModel is ERC165, BytesUtils, Ownable, Model, ModelDescriptor {


    mapping(bytes4 => bool) private _supportedInterface;

    address public engine;
    address private altDescriptor;

    mapping(bytes32 => Config) public configs;
    mapping(bytes32 => State) public states;

    uint256 public constant L_DATA = 16 + 32 + 3 + 5 + 4;

    uint256 private constant U_128_OVERFLOW = 2 ** 128;
    uint256 private constant U_64_OVERFLOW = 2 ** 64;
    uint256 private constant U_40_OVERFLOW = 2 ** 40;
    uint256 private constant U_24_OVERFLOW = 2 ** 24;

    event _setEngine(address _engine);
    event _setDescriptor(address _descriptor);

    event _setClock(bytes32 _id, uint64 _to);
    event _setPaidBase(bytes32 _id, uint128 _paidBase);
    event _setInterest(bytes32 _id, uint128 _interest);
    
    bool public inited;

    struct Config {
        uint24 installments;
        uint32 timeUnit;
        uint40 duration;
        uint64 lentTime;
        uint128 cuota;
        uint256 interestRate;
    }

    struct State {
        uint8 status;
        uint64 clock;
        uint64 lastPayment;
        uint128 paid;
        uint128 paidBase;
        uint128 interest;
    }

    modifier onlyEngine {

        require(msg.sender == engine, "Only engine allowed");
        _;
    }
    
    function init() external {

        assert(!inited);
        inited = true;
        _initOwner(msg.sender);
        _registerInterface(MODEL_INTERFACE);
        _registerInterface(MODEL_DESCRIPTOR_INTERFACE);
    }

    function modelId() external view returns (bytes32) {

        return bytes32(0x00000000000000496e7374616c6c6d656e74734d6f64656c204120302e302e32);
    }

    function descriptor() external view returns (address) {

        address _descriptor = altDescriptor;
        return _descriptor == address(0) ? address(this) : _descriptor;
    }

    function setEngine(address _engine) external onlyOwner returns (bool) {

        engine = _engine;
        emit _setEngine(_engine);
        return true;
    }

    function setDescriptor(address _descriptor) external onlyOwner returns (bool) {

        altDescriptor = _descriptor;
        emit _setDescriptor(_descriptor);
        return true;
    }

    function encodeData(
        uint128 _cuota,
        uint256 _interestRate,
        uint24 _installments,
        uint40 _duration,
        uint32 _timeUnit
    ) external pure returns (bytes memory) {

        return abi.encodePacked(_cuota, _interestRate, _installments, _duration, _timeUnit);
    }

    function create(bytes32 id, bytes calldata data) external onlyEngine returns (bool) {

        require(configs[id].cuota == 0, "Entry already exist");

        (uint128 cuota, uint256 interestRate, uint24 installments, uint40 duration, uint32 timeUnit) = _validate(data);

        configs[id] = Config({
            installments: installments,
            duration: duration,
            lentTime: uint64(now),
            cuota: cuota,
            interestRate: interestRate,
            timeUnit: timeUnit
        });

        states[id].clock = duration;

        emit Created(id);
        emit _setClock(id, duration);

        return true;
    }

    function addPaid(bytes32 id, uint256 amount) external onlyEngine returns (uint256 real) {

        Config storage config = configs[id];
        State storage state = states[id];

        _advanceClock(id, uint64(now) - config.lentTime);

        if (state.status != STATUS_PAID) {
            uint256 paid = state.paid;
            uint256 duration = config.duration;
            uint256 interest = state.interest;

            uint256 available = amount;
            require(available < U_128_OVERFLOW, "Amount overflow");

            uint256 unpaidInterest;
            uint256 pending;
            uint256 target;
            uint256 baseDebt;
            uint256 clock;

            do {
                clock = state.clock;

                baseDebt = _baseDebt(clock, duration, config.installments, config.cuota);
                pending = baseDebt + interest - paid;

                target = pending < available ? pending : available;

                unpaidInterest = interest - (paid - state.paidBase);

                state.paidBase += uint128(target > unpaidInterest ? target - unpaidInterest : 0);
                emit _setPaidBase(id, state.paidBase);

                paid += target;
                available -= target;

                if (clock / duration >= config.installments && baseDebt + interest <= paid) {
                    state.status = uint8(STATUS_PAID);
                    emit ChangedStatus(id, now, STATUS_PAID);
                    break;
                }

                if (pending == target) {
                    _advanceClock(id, clock + duration - (clock % duration));
                }
            } while (available != 0);

            require(paid < U_128_OVERFLOW, "Paid overflow");
            state.paid = uint128(paid);
            state.lastPayment = state.clock;

            real = amount - available;
            emit AddedPaid(id, real);
        }
    }

    function addDebt(bytes32 id, uint256 amount) external onlyEngine returns (bool) {

        revert("Not implemented!");
    }

    function fixClock(bytes32 id, uint64 target) external returns (bool) {

        require(target <= now, "Forbidden advance clock into the future");
        Config storage config = configs[id];
        State storage state = states[id];
        uint64 lentTime = config.lentTime;
        require(lentTime < target, "Clock can't go negative");
        uint64 targetClock = target - lentTime;
        require(targetClock > state.clock, "Clock is ahead of target");
        return _advanceClock(id, targetClock);
    }

    function isOperator(address _target) external view returns (bool) {

        return engine == _target;
    }

    function getStatus(bytes32 id) external view returns (uint256) {

        Config storage config = configs[id];
        State storage state = states[id];
        require(config.lentTime != 0, "The registry does not exist");
        return state.status == STATUS_PAID ? STATUS_PAID : STATUS_ONGOING;
    }

    function getPaid(bytes32 id) external view returns (uint256) {

        return states[id].paid;
    }

    function getObligation(bytes32 id, uint64 timestamp) external view returns (uint256, bool) {

        State storage state = states[id];
        Config storage config = configs[id];

        if (timestamp < config.lentTime) {
            return (0, true);
        }

        uint256 currentClock = timestamp - config.lentTime;

        uint256 base = _baseDebt(
            currentClock,
            config.duration,
            config.installments,
            config.cuota
        );

        uint256 interest;
        uint256 prevInterest = state.interest;
        uint256 clock = state.clock;
        bool defined;

        if (clock >= currentClock) {
            interest = prevInterest;
            defined = true;
        } else {
            (interest, currentClock) = _simRunClock(
                clock,
                currentClock,
                prevInterest,
                config,
                state
            );

            defined = prevInterest == interest;
        }

        uint256 debt = base + interest;
        uint256 paid = state.paid;
        return (debt > paid ? debt - paid : 0, defined);
    }

    function _simRunClock(
        uint256 _clock,
        uint256 _targetClock,
        uint256 _prevInterest,
        Config memory _config,
        State memory _state
    ) internal pure returns (uint256 interest, uint256 clock) {

        (interest, clock) = _runAdvanceClock({
            _clock: _clock,
            _timeUnit: _config.timeUnit,
            _interest: _prevInterest,
            _duration: _config.duration,
            _cuota: _config.cuota,
            _installments: _config.installments,
            _paidBase: _state.paidBase,
            _interestRate: _config.interestRate,
            _targetClock: _targetClock
        });
    }

    function run(bytes32 id) external returns (bool) {

        Config storage config = configs[id];
        return _advanceClock(id, uint64(now) - config.lentTime);
    }

    function validate(bytes calldata data) external view returns (bool) {

        _validate(data);
        return true;
    }

    function getClosingObligation(bytes32 id) external view returns (uint256) {

        return _getClosingObligation(id);
    }

    function getDueTime(bytes32 id) external view returns (uint256) {

        Config storage config = configs[id];
        if (config.cuota == 0)
            return 0;
        uint256 last = states[id].lastPayment;
        uint256 duration = config.duration;
        last = last != 0 ? last : duration;
        return last - (last % duration) + config.lentTime;
    }

    function getFinalTime(bytes32 id) external view returns (uint256) {

        Config storage config = configs[id];
        return config.lentTime + (uint256(config.duration) * (uint256(config.installments)));
    }

    function getFrequency(bytes32 id) external view returns (uint256) {

        return configs[id].duration;
    }

    function getInstallments(bytes32 id) external view returns (uint256) {

        return configs[id].installments;
    }

    function getEstimateObligation(bytes32 id) external view returns (uint256) {

        return _getClosingObligation(id);
    }

    function simFirstObligation(bytes calldata _data) external view returns (uint256 amount, uint256 time) {

        (amount,,, time,) = _decodeData(_data);
    }

    function simTotalObligation(bytes calldata _data) external view returns (uint256 amount) {

        (uint256 cuota,, uint256 installments,,) = _decodeData(_data);
        amount = cuota * installments;
    }

    function simDuration(bytes calldata _data) external view returns (uint256 duration) {

        (,,uint256 installments, uint256 installmentDuration,) = _decodeData(_data);
        duration = installmentDuration * installments;
    }

    function simPunitiveInterestRate(bytes calldata _data) external view returns (uint256 punitiveInterestRate) {

        (,punitiveInterestRate,,,) = _decodeData(_data);
    }

    function simFrequency(bytes calldata _data) external view returns (uint256 frequency) {

        (,,, frequency,) = _decodeData(_data);
    }

    function simInstallments(bytes calldata _data) external view returns (uint256 installments) {

        (,, installments,,) = _decodeData(_data);
    }

    function _advanceClock(bytes32 id, uint256 _target) internal returns (bool) {

        Config storage config = configs[id];
        State storage state = states[id];

        uint256 clock = state.clock;
        if (clock < _target) {
            (uint256 newInterest, uint256 newClock) = _runAdvanceClock({
                _clock: clock,
                _timeUnit: config.timeUnit,
                _interest: state.interest,
                _duration: config.duration,
                _cuota: config.cuota,
                _installments: config.installments,
                _paidBase: state.paidBase,
                _interestRate: config.interestRate,
                _targetClock: _target
            });

            require(newClock < U_64_OVERFLOW, "Clock overflow");
            require(newInterest < U_128_OVERFLOW, "Interest overflow");

            emit _setClock(id, uint64(newClock));

            if (newInterest != 0) {
                emit _setInterest(id, uint128(newInterest));
            }

            state.clock = uint64(newClock);
            state.interest = uint128(newInterest);

            return true;
        }
    }

    function _getClosingObligation(bytes32 id) internal view returns (uint256) {

        State storage state = states[id];
        Config storage config = configs[id];

        uint256 installments = config.installments;
        uint256 cuota = config.cuota;
        uint256 currentClock = uint64(now) - config.lentTime;

        uint256 interest;
        uint256 clock = state.clock;

        if (clock >= currentClock) {
            interest = state.interest;
        } else {
            (interest,) = _runAdvanceClock({
                _clock: clock,
                _timeUnit: config.timeUnit,
                _interest: state.interest,
                _duration: config.duration,
                _cuota: cuota,
                _installments: installments,
                _paidBase: state.paidBase,
                _interestRate: config.interestRate,
                _targetClock: currentClock
            });
        }

        uint256 debt = cuota * installments + interest;
        uint256 paid = state.paid;
        return debt > paid ? debt - paid : 0;
    }

    function _runAdvanceClock(
        uint256 _clock,
        uint256 _timeUnit,
        uint256 _interest,
        uint256 _duration,
        uint256 _cuota,
        uint256 _installments,
        uint256 _paidBase,
        uint256 _interestRate,
        uint256 _targetClock
    ) internal pure returns (uint256 interest, uint256 clock) {

        clock = _clock;
        interest = _interest;

        uint256 delta;
        bool installmentCompleted;

        do {
            (delta, installmentCompleted) = _calcDelta({
                _targetDelta: _targetClock - clock,
                _clock: clock,
                _duration: _duration,
                _installments: _installments
            });

            uint256 newInterest = _newInterest({
                _clock: clock,
                _timeUnit: _timeUnit,
                _duration: _duration,
                _installments: _installments,
                _cuota: _cuota,
                _paidBase: _paidBase,
                _delta: delta,
                _interestRate: _interestRate
            });

            if (installmentCompleted || newInterest > 0) {
                clock += delta;
                interest += newInterest;
            } else {
                break;
            }
        } while (clock < _targetClock);
    }

    function _calcDelta(
        uint256 _targetDelta,
        uint256 _clock,
        uint256 _duration,
        uint256 _installments
    ) internal pure returns (uint256 delta, bool installmentCompleted) {

        uint256 nextInstallmentDelta = _duration - _clock % _duration;
        if (nextInstallmentDelta <= _targetDelta && _clock / _duration < _installments) {
            delta = nextInstallmentDelta;
            installmentCompleted = true;
        } else {
            delta = _targetDelta;
            installmentCompleted = false;
        }
    }

    function _newInterest(
        uint256 _clock,
        uint256 _timeUnit,
        uint256 _duration,
        uint256 _installments,
        uint256 _cuota,
        uint256 _paidBase,
        uint256 _delta,
        uint256 _interestRate
    ) internal pure returns (uint256) {

        uint256 runningDebt = _baseDebt(_clock, _duration, _installments, _cuota) - _paidBase;
        uint256 newInterest = (100000 * (_delta / _timeUnit) * runningDebt) / (_interestRate / _timeUnit);
        require(newInterest < U_128_OVERFLOW, "New interest overflow");
        return newInterest;
    }

    function _baseDebt(
        uint256 clock,
        uint256 duration,
        uint256 installments,
        uint256 cuota
    ) internal pure returns (uint256 base) {

        uint256 installment = clock / duration;
        return uint128(installment < installments ? installment * cuota : installments * cuota);
    }

    function _validate(
        bytes memory _data
    ) internal pure returns (uint128 cuota, uint256 interestRate, uint24 installments, uint40 duration, uint32 timeUnit) {

        (cuota, interestRate, installments, duration, timeUnit) = _decodeData(_data);

        require(cuota > 0, "Cuota can't be 0");
        require(installments > 0, "Installments can't be 0");
        require(timeUnit > 0, "Time unit can't be 0");

        require(timeUnit <= duration, "Time unit must be lower or equal than installment duration");
        require(timeUnit < interestRate, "Interest rate by time unit is too low");
    }

    function _decodeData(
        bytes memory _data
    ) internal pure returns (uint128, uint256, uint24, uint40, uint32) {

        require(_data.length == L_DATA, "Invalid data length");
        (
            bytes32 cuota,
            bytes32 interestRate,
            bytes32 installments,
            bytes32 duration,
            bytes32 timeUnit
        ) = decode(_data, 16, 32, 3, 5, 4);
        return (uint128(uint256(cuota)), uint256(interestRate), uint24(uint256(installments)), uint40(uint256(duration)), uint32(uint256(timeUnit)));
    }
}