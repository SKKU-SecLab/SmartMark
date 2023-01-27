
pragma solidity >=0.6.12;






interface GemLike {

    function balanceOf(address) external view returns (uint256);


    function burn(uint256) external;


    function transfer(address, uint256) external returns (bool);


    function transferFrom(address, address, uint256) external returns (bool);

}

interface EndLike {

    function live() external view returns (uint256);


    function vat() external view returns (address);


    function cage() external;

}

interface DenyLike {

    function deny(address) external;

}

contract ESM {


    uint256 constant WAD = 10 ** 18;

    GemLike public immutable gem;   // collateral (MKR token)
    address public immutable proxy; // Pause proxy

    mapping(address => uint256) public wards; // auth
    mapping(address => uint256) public sum;   // per-address balance

    uint256 public Sum;  // total balance
    uint256 public min;  // minimum activation threshold [wad]
    EndLike public end;  // cage module
    uint256 public live; // active flag

    event Fire();
    event Join(address indexed usr, uint256 wad);
    event File(bytes32 indexed what, uint256 data);
    event File(bytes32 indexed what, address data);
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event DenyProxy(address indexed base, address indexed pause);

    constructor(address gem_, address end_, address proxy_, uint256 min_) public {
        gem = GemLike(gem_);
        end = EndLike(end_);
        proxy = proxy_;
        min = min_;
        live = 1;

        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    function revokesGovernanceAccess() external view returns (bool ret) {

        ret = proxy != address(0);
    }

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x + y;
        require(z >= x);
    }

    function rely(address usr) external auth {

        wards[usr] = 1;

        emit Rely(usr);
    }

    function deny(address usr) external auth {

        wards[usr] = 0;

        emit Deny(usr);
    }
    modifier auth {

        require(wards[msg.sender] == 1, "ESM/not-authorized");
        _;
    }

    function file(bytes32 what, uint256 data) external auth {

        if (what == "min") {
            require(data > WAD, "ESM/min-too-small");
            min = data;
        } else {
            revert("ESM/file-unrecognized-param");
        }

        emit File(what, data);
    }

    function file(bytes32 what, address data) external auth {

        if (what == "end") {
            end = EndLike(data);
        } else {
            revert("ESM/file-unrecognized-param");
        }

        emit File(what, data);
    }

    function cage() external auth {

        live = 0;
    }

    function fire() external {

        require(live == 1, "ESM/permanently-disabled");
        require(Sum >= min, "ESM/min-not-reached");

        if (proxy != address(0)) {
            DenyLike(end.vat()).deny(proxy);
        }
        end.cage();

        emit Fire();
    }

    function denyProxy(address target) external {

        require(live == 1, "ESM/permanently-disabled");
        require(Sum >= min, "ESM/min-not-reached");

        DenyLike(target).deny(proxy);
        emit DenyProxy(target, proxy);
    }

    function join(uint256 wad) external {

        require(live == 1, "ESM/permanently-disabled");
        require(end.live() == 1, "ESM/system-already-shutdown");

        sum[msg.sender] = add(sum[msg.sender], wad);
        Sum = add(Sum, wad);

        require(gem.transferFrom(msg.sender, address(this), wad), "ESM/transfer-failed");
        emit Join(msg.sender, wad);
    }

    function burn() external {

        gem.burn(gem.balanceOf(address(this)));
    }
}