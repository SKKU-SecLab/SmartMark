

pragma solidity >=0.6.12;




interface GemLike_3 {

    function decimals() external view returns (uint);

    function transfer(address,uint) external returns (bool);

    function transferFrom(address,address,uint) external returns (bool);

}

interface VatLike_5 {

    function slip(bytes32,address,int) external;

    function move(address,address,uint) external;

}

contract AuthGemJoin {

    mapping (address => uint) public wards;
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(usr); }

    function deny(address usr) external auth { wards[usr] = 0; emit Deny(usr); }

    modifier auth {

        require(wards[msg.sender] == 1, "GemJoin/not-authorized");
        _;
    }

    VatLike_5 public immutable vat;   // CDP Engine
    bytes32 public immutable ilk;   // Collateral Type
    GemLike_3 public immutable gem;
    uint    public immutable dec;
    uint    public live;  // Active Flag

    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event Cage();
    event Join(address indexed urn, uint256 wad, address indexed msgSender);
    event Exit(address indexed guy, uint256 wad);

    constructor(address vat_, bytes32 ilk_, address gem_) public {
        wards[msg.sender] = 1;
        emit Rely(msg.sender);
        live = 1;
        vat = VatLike_5(vat_);
        ilk = ilk_;
        gem = GemLike_3(gem_);
        dec = GemLike_3(gem_).decimals();
    }
    function cage() external auth {

        live = 0;
        emit Cage();
    }
    function join(address urn, uint wad, address msgSender) external auth {

        require(live == 1, "GemJoin/not-live");
        require(int(wad) >= 0, "GemJoin/overflow");
        vat.slip(ilk, urn, int(wad));
        require(gem.transferFrom(msgSender, address(this), wad), "GemJoin/failed-transfer");
        emit Join(urn, wad, msgSender);
    }
    function exit(address guy, uint wad) external {

        require(wad <= 2 ** 255, "GemJoin/overflow");
        vat.slip(ilk, msg.sender, -int(wad));
        require(gem.transfer(guy, wad), "GemJoin/failed-transfer");
        emit Exit(guy, wad);
    }
}