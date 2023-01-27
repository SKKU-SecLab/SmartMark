
pragma solidity =0.6.12;




interface VatLike_4 {

    function suck(address, address, uint256) external;

    function move(address, address, uint256) external;

    function flux(bytes32, address, address, uint256) external;

    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);

}

interface PipLike_2 {

    function peek() external returns (bytes32, bool);

}

interface SpotterLike {

    function par() external returns (uint256);

    function ilks(bytes32) external returns (PipLike_2, uint256);

}

interface DogLike {

    function chop(bytes32) external returns (uint256);

    function digs(bytes32, uint256) external;

}

interface ClipperCallee {

    function clipperCall(address, uint256, uint256, bytes calldata) external;

}

interface AbacusLike {

    function price(uint256, uint256) external view returns (uint256);

}

interface GemJoinLike {

    function ilk() external returns (bytes32);

}

interface ProxyManagerLike {

    function proxy(address) external returns (address);

    function onLiquidation(address, address, uint256) external;

    function onVatFlux(address, address, address, uint256) external;

}

interface ProxyLike {

    function usr() external view returns (address);

}

contract ProxyManagerClipper {

    mapping (address => uint256) public wards;
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(usr); }

    function deny(address usr) external auth { wards[usr] = 0; emit Deny(usr); }

    modifier auth {

        require(wards[msg.sender] == 1, "ProxyManagerClipper/not-authorized");
        _;
    }

    bytes32          immutable public ilk;      // Collateral type of this ProxyManagerClipper
    VatLike_4          immutable public vat;      // Core CDP Engine
    GemJoinLike      immutable public gemJoin;  // GemJoin adapter this contract performs liquidations for
    ProxyManagerLike immutable public proxyMgr; // The proxy manager

    DogLike     public dog;      // Liquidation module
    address     public vow;      // Recipient of dai raised in auctions
    SpotterLike public spotter;  // Collateral price module
    AbacusLike  public calc;     // Current price calculator

    uint256 public buf;    // Multiplicative factor to increase starting price                  [ray]
    uint256 public tail;   // Time elapsed before auction reset                                 [seconds]
    uint256 public cusp;   // Percentage drop before auction reset                              [ray]
    uint64  public chip;   // Percentage of tab to suck from vow to incentivize keepers         [wad]
    uint192 public tip;    // Flat fee to suck from vow to incentivize keepers                  [rad]
    uint256 public chost;  // Cache the ilk dust times the ilk chop to prevent excessive SLOADs [rad]

    uint256   public kicks;   // Total auctions
    uint256[] public active;  // Array of active auction ids

    struct Sale {
        uint256 pos;  // Index in active array
        uint256 tab;  // Dai to raise       [rad]
        uint256 lot;  // collateral to sell [wad]
        address usr;  // Liquidated CDP
        uint96  tic;  // Auction start time
        uint256 top;  // Starting price     [ray]
    }
    mapping(uint256 => Sale) public sales;

    uint256 internal locked;

    uint256 public stopped = 0;

    event Rely(address indexed usr);
    event Deny(address indexed usr);

    event File(bytes32 indexed what, uint256 data);
    event File(bytes32 indexed what, address data);

    event Kick(
        uint256 indexed id,
        uint256 top,
        uint256 tab,
        uint256 lot,
        address indexed usr,
        address indexed kpr,
        uint256 coin
    );
    event Take(
        uint256 indexed id,
        uint256 max,
        uint256 price,
        uint256 owe,
        uint256 tab,
        uint256 lot,
        address indexed usr
    );
    event Redo(
        uint256 indexed id,
        uint256 top,
        uint256 tab,
        uint256 lot,
        address indexed usr,
        address indexed kpr,
        uint256 coin
    );

    event Yank(uint256 id);

    constructor(address vat_, address spotter_, address dog_, address gemJoin_, address proxyMgr_) public {
        vat      = VatLike_4(vat_);
        spotter  = SpotterLike(spotter_);
        dog      = DogLike(dog_);
        gemJoin  = GemJoinLike(gemJoin_);
        proxyMgr = ProxyManagerLike(proxyMgr_);
        ilk      = GemJoinLike(gemJoin_).ilk();
        buf      = RAY;
        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    modifier lock {

        require(locked == 0, "ProxyManagerClipper/system-locked");
        locked = 1;
        _;
        locked = 0;
    }

    modifier isStopped(uint256 level) {

        require(stopped < level, "ProxyManagerClipper/stopped-incorrect");
        _;
    }

    function file(bytes32 what, uint256 data) external auth lock {

        if      (what == "buf")         buf = data;
        else if (what == "tail")       tail = data;           // Time elapsed before auction reset
        else if (what == "cusp")       cusp = data;           // Percentage drop before auction reset
        else if (what == "chip")       chip = uint64(data);   // Percentage of tab to incentivize (max: 2^64 - 1 => 18.xxx WAD = 18xx%)
        else if (what == "tip")         tip = uint192(data);  // Flat fee to incentivize keepers (max: 2^192 - 1 => 6.277T RAD)
        else if (what == "stopped") stopped = data;           // Set breaker (0, 1, 2, or 3)
        else revert("ProxyManagerClipper/file-unrecognized-param");
        emit File(what, data);
    }
    function file(bytes32 what, address data) external auth lock {

        if (what == "spotter") spotter = SpotterLike(data);
        else if (what == "dog")    dog = DogLike(data);
        else if (what == "vow")    vow = data;
        else if (what == "calc")  calc = AbacusLike(data);
        else revert("ProxyManagerClipper/file-unrecognized-param");
        emit File(what, data);
    }

    uint256 constant BLN = 10 **  9;
    uint256 constant WAD = 10 ** 18;
    uint256 constant RAY = 10 ** 27;

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x <= y ? x : y;
    }
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x);
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x);
    }
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x);
    }
    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = mul(x, y) / WAD;
    }
    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = mul(x, y) / RAY;
    }
    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = mul(x, RAY) / y;
    }


    function getFeedPrice() internal returns (uint256 feedPrice) {

        (PipLike_2 pip, ) = spotter.ilks(ilk);
        (bytes32 val, bool has) = pip.peek();
        require(has, "ProxyManagerClipper/invalid-price");
        feedPrice = rdiv(mul(uint256(val), BLN), spotter.par());
    }

    function kick(
        uint256 tab,  // Debt                   [rad]
        uint256 lot,  // Collateral             [wad]
        address usr,  // Address that will receive any leftover collateral; additionally assumed here to be the liquidated Vault.

        address kpr   // Address that will receive incentives
    ) external auth lock isStopped(1) returns (uint256 id) {
        require(tab  >          0, "ProxyManagerClipper/zero-tab");
        require(lot  >          0, "ProxyManagerClipper/zero-lot");
        require(usr != address(0), "ProxyManagerClipper/zero-usr");
        id = ++kicks;
        require(id   >          0, "ProxyManagerClipper/overflow");

        active.push(id);

        sales[id].pos = active.length - 1;

        sales[id].tab = tab;
        sales[id].lot = lot;
        sales[id].usr = usr;
        sales[id].tic = uint96(block.timestamp);

        uint256 top;
        top = rmul(getFeedPrice(), buf);
        require(top > 0, "ProxyManagerClipper/zero-top-price");
        sales[id].top = top;

        uint256 _tip  = tip;
        uint256 _chip = chip;
        uint256 coin;
        if (_tip > 0 || _chip > 0) {
            coin = add(_tip, wmul(tab, _chip));
            vat.suck(vow, kpr, coin);
        }

        proxyMgr.onLiquidation(address(gemJoin), ProxyLike(usr).usr(), lot);

        emit Kick(id, top, tab, lot, usr, kpr, coin);
    }

    function redo(
        uint256 id,  // id of the auction to reset
        address kpr  // Address that will receive incentives
    ) external lock isStopped(2) {

        address usr = sales[id].usr;
        uint96  tic = sales[id].tic;
        uint256 top = sales[id].top;

        require(usr != address(0), "ProxyManagerClipper/not-running-auction");

        (bool done,) = status(tic, top);
        require(done, "ProxyManagerClipper/cannot-reset");

        uint256 tab   = sales[id].tab;
        uint256 lot   = sales[id].lot;
        sales[id].tic = uint96(block.timestamp);

        uint256 feedPrice = getFeedPrice();
        top = rmul(feedPrice, buf);
        require(top > 0, "ProxyManagerClipper/zero-top-price");
        sales[id].top = top;

        uint256 _tip  = tip;
        uint256 _chip = chip;
        uint256 coin;
        if (_tip > 0 || _chip > 0) {
            uint256 _chost = chost;
            if (tab >= _chost && mul(lot, feedPrice) >= _chost) {
                coin = add(_tip, wmul(tab, _chip));
                vat.suck(vow, kpr, coin);
            }
        }

        emit Redo(id, top, tab, lot, usr, kpr, coin);
    }

    function take(
        uint256 id,           // Auction id
        uint256 amt,          // Upper limit on amount of collateral to buy  [wad]
        uint256 max,          // Maximum acceptable price (DAI / collateral) [ray]
        address who,          // Receiver of collateral and external call address
        bytes calldata data   // Data to pass in external call; if length 0, no call is done

    ) external lock isStopped(3) {

        address usr = sales[id].usr;
        uint96  tic = sales[id].tic;

        require(usr != address(0), "ProxyManagerClipper/not-running-auction");

        uint256 price;
        {
            bool done;
            (done, price) = status(tic, sales[id].top);

            require(!done, "ProxyManagerClipper/needs-reset");
        }

        require(max >= price, "ProxyManagerClipper/too-expensive");

        uint256 lot = sales[id].lot;
        uint256 tab = sales[id].tab;
        uint256 owe;

        {
            uint256 slice = min(lot, amt);  // slice <= lot

            owe = mul(slice, price);

            if (owe > tab) {
                owe = tab;                  // owe' <= owe
                slice = owe / price;        // slice' = owe' / price <= owe / price == slice <= lot
            } else if (owe < tab && slice < lot) {
                uint256 _chost = chost;
                if (tab - owe < _chost) {    // safe as owe < tab
                    require(tab > _chost, "ProxyManagerClipper/no-partial-purchase");
                    owe = tab - _chost;      // owe' <= owe
                    slice = owe / price;     // slice' = owe' / price < owe / price == slice < lot
                }
            }

            tab = tab - owe;  // safe since owe <= tab
            lot = lot - slice;

            {
                address urp = proxyMgr.proxy(who);
                require(urp != address(0), "ProxyManagerClipper/no-urn-proxy");
                vat.flux(ilk, address(this), urp, slice);
                proxyMgr.onVatFlux(address(gemJoin), address(this), urp, slice);
            }

            DogLike dog_ = dog;
            if (data.length > 0 && who != address(vat) && who != address(dog_)) {
                ClipperCallee(who).clipperCall(msg.sender, owe, slice, data);
            }

            vat.move(msg.sender, vow, owe);

            dog_.digs(ilk, lot == 0 ? tab + owe : owe);
        }

        if (lot == 0) {
            _remove(id);
        } else if (tab == 0) {
            vat.flux(ilk, address(this), usr, lot);
            proxyMgr.onVatFlux(address(gemJoin), address(this), usr, lot);
            _remove(id);
        } else {
            sales[id].tab = tab;
            sales[id].lot = lot;
        }

        emit Take(id, max, price, owe, tab, lot, usr);
    }

    function _remove(uint256 id) internal {

        uint256 _move    = active[active.length - 1];
        if (id != _move) {
            uint256 _index   = sales[id].pos;
            active[_index]   = _move;
            sales[_move].pos = _index;
        }
        active.pop();
        delete sales[id];
    }

    function count() external view returns (uint256) {

        return active.length;
    }

    function list() external view returns (uint256[] memory) {

        return active;
    }

    function getStatus(uint256 id) external view returns (bool needsRedo, uint256 price, uint256 lot, uint256 tab) {

        address usr = sales[id].usr;
        uint96  tic = sales[id].tic;

        bool done;
        (done, price) = status(tic, sales[id].top);

        needsRedo = usr != address(0) && done;
        lot = sales[id].lot;
        tab = sales[id].tab;
    }

    function status(uint96 tic, uint256 top) internal view returns (bool done, uint256 price) {

        price = calc.price(top, sub(block.timestamp, tic));
        done  = (sub(block.timestamp, tic) > tail || rdiv(price, top) < cusp);
    }

    function upchost() external {

        (,,,, uint256 _dust) = VatLike_4(vat).ilks(ilk);
        chost = wmul(_dust, dog.chop(ilk));
    }

    function yank(uint256 id) external auth lock {

        require(sales[id].usr != address(0), "ProxyManagerClipper/not-running-auction");
        dog.digs(ilk, sales[id].tab);
        uint256 lot = sales[id].lot;
        vat.flux(ilk, address(this), msg.sender, lot);
        proxyMgr.onVatFlux(address(gemJoin), address(this), msg.sender, lot);
        _remove(id);
        emit Yank(id);
    }
}