

pragma solidity =0.5.12;




interface GemLike_3 {

    function decimals() external view returns (uint256);

    function transfer(address,uint256) external returns (bool);

    function transferFrom(address,address,uint256) external returns (bool);

    function approve(address,uint256) external returns (bool);

    function totalSupply() external returns (uint256);

    function balanceOf(address) external returns (uint256);

}

interface JoinLike {

    function join(address,uint256) external;

    function exit(address,uint256) external;

}

interface EndLike {

    function debt() external returns (uint256);

}

interface RedeemLike {

    function redeemOrder(uint256) external;

    function disburse(uint256) external returns (uint256,uint256,uint256,uint256);

}

interface VatLike_5 {

    function urns(bytes32,address) external returns (uint256,uint256);

    function ilks(bytes32) external returns (uint256,uint256,uint256,uint256,uint256);

    function live() external returns(uint);

}

interface GemJoinLike {

    function gem() external returns (address);

    function ilk() external returns (bytes32);

}

interface MIP21UrnLike {

    function lock(uint256 wad) external;

    function free(uint256 wad) external;

    function draw(uint256 wad) external;

    function wipe(uint256 wad) external;

    function quit() external;

    function gemJoin() external returns (address);

}

interface MIP21LiquidationLike {

    function ilks(bytes32 ilk) external returns (string memory, address, uint48, uint48);

}

contract TinlakeManager {

    mapping (address => uint256) public wards;

    function rely(address usr) external auth {

        wards[usr] = 1;
        emit Rely(usr);
    }
    function deny(address usr) external auth {

        wards[usr] = 0;
        emit Deny(usr);
    }
    modifier auth {

        require(wards[msg.sender] == 1, "TinlakeMgr/not-authorized");
        _;
    }

    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event Draw(uint256 wad);
    event Wipe(uint256 wad);
    event Join(uint256 wad);
    event Exit(uint256 wad);
    event Tell(uint256 wad);
    event Unwind(uint256 payBack);
    event Cull(uint256 tab);
    event Recover(uint256 recovered, uint256 payBack);
    event Cage();
    event File(bytes32 indexed what, address indexed data);
    event Migrate(address indexed dst);

    bool public safe; // Soft liquidation not triggered
    bool public glad; // Write-off not triggered
    bool public live; // Global settlement not triggered

    uint256 public tab;  // Dai owed

    VatLike_5 public vat;
    GemLike_3 public dai;
    EndLike public end;
    address public vow;
    JoinLike public daiJoin;

    GemLike_3      public gem;
    RedeemLike   public pool;

    MIP21UrnLike public urn;
    MIP21LiquidationLike public liq;

    address public tranche;
    address public owner;

    constructor(address dai_,   address daiJoin_,
                address drop_,  address pool_,
                address tranche_, address end_,
                address vat_, address vow_
                ) public {
        dai = GemLike_3(dai_);
        daiJoin = JoinLike(daiJoin_);
        vat = VatLike_5(vat_);
        vow = vow_;
        end = EndLike(end_);
        gem = GemLike_3(drop_);

        pool = RedeemLike(pool_);

        wards[msg.sender] = 1;
        emit Rely(msg.sender);

        safe = true;
        glad = true;
        live = true;

        tranche = tranche_;
    }

    uint256 constant RAY = 10 ** 27;
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x);
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x);
    }
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x);
    }
    function divup(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(x, sub(y, 1)) / y;
    }
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x > y ? y : x;
    }


    function lock(uint256 wad) public auth {

        GemLike_3(GemJoinLike(urn.gemJoin()).gem()).approve(address(urn), uint256(wad));
        urn.lock(wad);
    }
    function free(uint256 wad) public auth {

        urn.free(wad);
    }

    function join(uint256 wad) public auth {

        require(safe && live, "TinlakeManager/bad-state");
        require(int256(wad) >= 0, "TinlakeManager/overflow");
        gem.transferFrom(msg.sender, address(this), wad);
        emit Join(wad);
    }

    function exit(uint256 wad) public auth {

        require(safe && live, "TinlakeManager/bad-state");
        require(wad <= 2 ** 255, "TinlakeManager/overflow");
        gem.transfer(msg.sender, wad);
        emit Exit(wad);
    }

    function draw(uint256 wad) public auth {

        require(safe && live, "TinlakeManager/bad-state");
        urn.draw(wad);
        dai.transfer(msg.sender, wad);
        emit Draw(wad);
    }

    function wipe(uint256 wad) public {

        require(safe && live, "TinlakeManager/bad-state");
        dai.transferFrom(msg.sender, address(urn), wad);
        urn.wipe(wad);
        emit Wipe(wad);
    }

    function quit() public auth {

        urn.quit();
    }

    function migrate(address dst) public auth {

        dai.approve(dst, uint256(-1));
        gem.approve(dst, uint256(-1));
        live = false;
        emit Migrate(dst);
    }

    function file(bytes32 what, address data) public auth {

        emit File(what, data);
        if (what == "urn") {
            urn = MIP21UrnLike(data);
            dai.approve(data, uint256(-1));
        }
        else if (what == "liq") {
            liq = MIP21LiquidationLike(data);
        }
        else if (what == "owner") {
            owner = data;
        }
        else if (what == "vow") {
            vow = data;
        }
        else if (what == "end") {
            end = EndLike(data);
        }
        else if (what == "pool") {
            pool = RedeemLike(data);
        }
        else if (what == "tranche") {
            tranche = data;
        }
        else revert("TinlakeMgr/file-unknown-param");
    }

    function tell() public {

        require(safe, "TinlakeMgr/not-safe");
        bytes32 ilk = GemJoinLike(urn.gemJoin()).ilk();

        (,,, uint48 toc) = liq.ilks(ilk);
        require(toc != 0, "TinlakeMgr/not-liquidated");

        (, uint256 art) = vat.urns(ilk, address(urn));
        (, uint256 rate, , ,) = vat.ilks(ilk);
        tab = mul(art, rate);

        uint256 ink = gem.balanceOf(address(this));
        safe = false;
        gem.approve(tranche, ink);
        pool.redeemOrder(ink);
        emit Tell(ink);
    }

    function unwind(uint256 endEpoch) public {

        require(!safe && glad && live, "TinlakeMgr/not-soft-liquidation");

        (uint256 redeemed, , ,) = pool.disburse(endEpoch);
        bytes32 ilk = GemJoinLike(urn.gemJoin()).ilk();

        (, uint256 art) = vat.urns(ilk, address(urn));
        (, uint256 rate, , ,) = vat.ilks(ilk);
        uint256 tab_ = mul(art, rate);

        uint256 payBack = min(redeemed, divup(tab_, RAY));
        dai.transferFrom(address(this), address(urn), payBack);
        urn.wipe(payBack);

        dai.transfer(owner, dai.balanceOf(address(this)));
        tab = sub(tab_, mul(payBack, RAY));
        emit Unwind(payBack);
    }

    function cull() public {

        require(!safe && glad && live, "TinlakeMgr/bad-state");
        bytes32 ilk = GemJoinLike(urn.gemJoin()).ilk();

        (uint256 ink, uint256 art) = vat.urns(ilk, address(urn));
        require(ink == 0 && art == 0, "TinlakeMgr/not-written-off");

        (,, uint48 tau, uint48 toc) = liq.ilks(ilk);
        require(toc != 0, "TinlakeMgr/not-liquidated");
        require(block.timestamp >= add(toc, tau), "TinlakeMgr/early-cull");

        glad = false;
        emit Cull(tab);
    }

    function recover(uint256 endEpoch) public {

        require(!glad, "TinlakeMgr/not-written-off");

        (uint256 recovered, , ,) = pool.disburse(endEpoch);
        uint256 payBack;
        if (end.debt() == 0) {
            payBack = min(recovered, tab / RAY);
            dai.approve(address(daiJoin), payBack);
            daiJoin.join(vow, payBack);
            tab = sub(tab, mul(payBack, RAY));
        }
        dai.transfer(owner, dai.balanceOf(address(this)));
        emit Recover(recovered, payBack);
    }

    function cage() external {

        require(!glad, "TinlakeMgr/bad-state");
        require(wards[msg.sender] == 1 || vat.live() == 0, "TinlakeMgr/not-authorized");
        live = false;
        emit Cage();
    }
}