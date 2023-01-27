

pragma solidity 0.6.12;

interface MintLike {

    function mint(address, uint256) external;

}

interface ChainlogLike {

    function getAddress(bytes32) external view returns (address);

}

interface DaiJoinLike {

    function exit(address, uint256) external;

}

interface VatLike {

    function hope(address) external;

    function suck(address, address, uint256) external;

    function live() external view returns (uint256);

}

interface TokenLike {

    function transferFrom(address, address, uint256) external returns (bool);

}

abstract contract DssVest {
    mapping (address => uint256) public wards;

    struct Award {
        address usr;   // Vesting recipient
        uint48  bgn;   // Start of vesting period  [timestamp]
        uint48  clf;   // The cliff date           [timestamp]
        uint48  fin;   // End of vesting period    [timestamp]
        address mgr;   // A manager address that can yank
        uint8   res;   // Restricted
        uint128 tot;   // Total reward amount
        uint128 rxd;   // Amount of vest claimed
    }
    mapping (uint256 => Award) public awards;

    uint256 public cap; // Maximum per-second issuance token rate

    uint256 public ids; // Total vestings

    uint256 internal locked;

    uint256 public constant  TWENTY_YEARS = 20 * 365 days;

    event Rely(address indexed usr);
    event Deny(address indexed usr);

    event File(bytes32 indexed what, uint256 data);

    event Init(uint256 indexed id, address indexed usr);
    event Vest(uint256 indexed id, uint256 amt);
    event Restrict(uint256 indexed id);
    event Unrestrict(uint256 indexed id);
    event Yank(uint256 indexed id, uint256 end);
    event Move(uint256 indexed id, address indexed dst);

    function usr(uint256 _id) external view returns (address) {
        return awards[_id].usr;
    }

    function bgn(uint256 _id) external view returns (uint256) {
        return awards[_id].bgn;
    }

    function clf(uint256 _id) external view returns (uint256) {
        return awards[_id].clf;
    }

    function fin(uint256 _id) external view returns (uint256) {
        return awards[_id].fin;
    }

    function mgr(uint256 _id) external view returns (address) {
        return awards[_id].mgr;
    }

    function res(uint256 _id) external view returns (uint256) {
        return awards[_id].res;
    }

    function tot(uint256 _id) external view returns (uint256) {
        return awards[_id].tot;
    }

    function rxd(uint256 _id) external view returns (uint256) {
        return awards[_id].rxd;
    }

    constructor() public {
        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    modifier lock {
        require(locked == 0, "DssVest/system-locked");
        locked = 1;
        _;
        locked = 0;
    }

    modifier auth {
        require(wards[msg.sender] == 1, "DssVest/not-authorized");
        _;
    }

    function rely(address _usr) external auth {
        wards[_usr] = 1;
        emit Rely(_usr);
    }
    function deny(address _usr) external auth {
        wards[_usr] = 0;
        emit Deny(_usr);
    }

    function file(bytes32 what, uint256 data) external lock auth {
        if      (what == "cap")         cap = data;     // The maximum amount of tokens that can be streamed per-second per vest
        else revert("DssVest/file-unrecognized-param");
        emit File(what, data);
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x > y ? y : x;
    }
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "DssVest/add-overflow");
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "DssVest/sub-underflow");
    }
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "DssVest/mul-overflow");
    }
    function toUint48(uint256 x) internal pure returns (uint48 z) {
        require((z = uint48(x)) == x, "DssVest/uint48-overflow");
    }
    function toUint128(uint256 x) internal pure returns (uint128 z) {
        require((z = uint128(x)) == x, "DssVest/uint128-overflow");
    }

    function create(address _usr, uint256 _tot, uint256 _bgn, uint256 _tau, uint256 _eta, address _mgr) external lock auth returns (uint256 id) {
        require(_usr != address(0),                        "DssVest/invalid-user");
        require(_tot > 0,                                  "DssVest/no-vest-total-amount");
        require(_bgn < add(block.timestamp, TWENTY_YEARS), "DssVest/bgn-too-far");
        require(_bgn > sub(block.timestamp, TWENTY_YEARS), "DssVest/bgn-too-long-ago");
        require(_tau > 0,                                  "DssVest/tau-zero");
        require(_tot / _tau <= cap,                        "DssVest/rate-too-high");
        require(_tau <= TWENTY_YEARS,                      "DssVest/tau-too-long");
        require(_eta <= _tau,                              "DssVest/eta-too-long");
        require(ids < type(uint256).max,                   "DssVest/ids-overflow");

        id = ++ids;
        awards[id] = Award({
            usr: _usr,
            bgn: toUint48(_bgn),
            clf: toUint48(add(_bgn, _eta)),
            fin: toUint48(add(_bgn, _tau)),
            tot: toUint128(_tot),
            rxd: 0,
            mgr: _mgr,
            res: 0
        });
        emit Init(id, _usr);
    }

    function vest(uint256 _id) external {
        _vest(_id, type(uint256).max);
    }

    function vest(uint256 _id, uint256 _maxAmt) external {
        _vest(_id, _maxAmt);
    }

    function _vest(uint256 _id, uint256 _maxAmt) internal lock {
        Award memory _award = awards[_id];
        require(_award.usr != address(0), "DssVest/invalid-award");
        require(_award.res == 0 || _award.usr == msg.sender, "DssVest/only-user-can-claim");
        uint256 amt = unpaid(block.timestamp, _award.bgn, _award.clf, _award.fin, _award.tot, _award.rxd);
        amt = min(amt, _maxAmt);
        awards[_id].rxd = toUint128(add(_award.rxd, amt));
        pay(_award.usr, amt);
        emit Vest(_id, amt);
    }

    function accrued(uint256 _id) external view returns (uint256 amt) {
        Award memory _award = awards[_id];
        require(_award.usr != address(0), "DssVest/invalid-award");
        amt = accrued(block.timestamp, _award.bgn, _award.fin, _award.tot);
    }

    function accrued(uint256 _time, uint48 _bgn, uint48 _fin, uint128 _tot) internal pure returns (uint256 amt) {
        if (_time < _bgn) {
            amt = 0;
        } else if (_time >= _fin) {
            amt = _tot;
        } else {
            amt = mul(_tot, sub(_time, _bgn)) / sub(_fin, _bgn); // 0 <= amt < _award.tot
        }
    }

    function unpaid(uint256 _id) external view returns (uint256 amt) {
        Award memory _award = awards[_id];
        require(_award.usr != address(0), "DssVest/invalid-award");
        amt = unpaid(block.timestamp, _award.bgn, _award.clf, _award.fin, _award.tot, _award.rxd);
    }

    function unpaid(uint256 _time, uint48 _bgn, uint48 _clf, uint48 _fin, uint128 _tot, uint128 _rxd) internal pure returns (uint256 amt) {
        amt = _time < _clf ? 0 : sub(accrued(_time, _bgn, _fin, _tot), _rxd);
    }

    function restrict(uint256 _id) external lock {
        address usr_ = awards[_id].usr;
        require(usr_ != address(0), "DssVest/invalid-award");
        require(wards[msg.sender] == 1 || usr_ == msg.sender, "DssVest/not-authorized");
        awards[_id].res = 1;
        emit Restrict(_id);
    }

    function unrestrict(uint256 _id) external lock {
        address usr_ = awards[_id].usr;
        require(usr_ != address(0), "DssVest/invalid-award");
        require(wards[msg.sender] == 1 || usr_ == msg.sender, "DssVest/not-authorized");
        awards[_id].res = 0;
        emit Unrestrict(_id);
    }

    function yank(uint256 _id) external {
        _yank(_id, block.timestamp);
    }

    function yank(uint256 _id, uint256 _end) external {
        _yank(_id, _end);
    }

    function _yank(uint256 _id, uint256 _end) internal lock {
        require(wards[msg.sender] == 1 || awards[_id].mgr == msg.sender, "DssVest/not-authorized");
        Award memory _award = awards[_id];
        require(_award.usr != address(0), "DssVest/invalid-award");
        if (_end < block.timestamp) {
            _end = block.timestamp;
        }
        if (_end < _award.fin) {
            uint48 end = toUint48(_end);
            awards[_id].fin = end;
            if (end < _award.bgn) {
                awards[_id].bgn = end;
                awards[_id].clf = end;
                awards[_id].tot = 0;
            } else if (end < _award.clf) {
                awards[_id].clf = end;
                awards[_id].tot = 0;
            } else {
                awards[_id].tot = toUint128(
                                    add(
                                        unpaid(_end, _award.bgn, _award.clf, _award.fin, _award.tot, _award.rxd),
                                        _award.rxd
                                    )
                                );
            }
        }

        emit Yank(_id, _end);
    }

    function move(uint256 _id, address _dst) external lock {
        require(awards[_id].usr == msg.sender, "DssVest/only-user-can-move");
        require(_dst != address(0), "DssVest/zero-address-invalid");
        awards[_id].usr = _dst;
        emit Move(_id, _dst);
    }

    function valid(uint256 _id) external view returns (bool isValid) {
        isValid = awards[_id].rxd < awards[_id].tot;
    }

    function pay(address _guy, uint256 _amt) virtual internal;
}

contract DssVestSuckable is DssVest {


    uint256 internal constant RAY = 10**27;

    ChainlogLike public immutable chainlog;
    VatLike      public immutable vat;
    DaiJoinLike  public immutable daiJoin;

    constructor(address _chainlog) public DssVest() {
        require(_chainlog != address(0), "DssVestSuckable/Invalid-chainlog-address");
        ChainlogLike chainlog_ = chainlog = ChainlogLike(_chainlog);
        VatLike vat_ = vat = VatLike(chainlog_.getAddress("MCD_VAT"));
        DaiJoinLike daiJoin_ = daiJoin = DaiJoinLike(chainlog_.getAddress("MCD_JOIN_DAI"));

        vat_.hope(address(daiJoin_));
    }

    function pay(address _guy, uint256 _amt) override internal {

        require(vat.live() == 1, "DssVestSuckable/vat-not-live");
        vat.suck(chainlog.getAddress("MCD_VOW"), address(this), mul(_amt, RAY));
        daiJoin.exit(_guy, _amt);
    }
}