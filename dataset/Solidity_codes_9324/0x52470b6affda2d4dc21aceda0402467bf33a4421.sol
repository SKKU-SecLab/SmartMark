

pragma solidity >=0.6.12;

interface VatLike {

    function hope(address) external;

}

interface GemJoinLike {

    function dec() external view returns (uint256);

    function gem() external view returns (TokenLike);

    function exit(address, uint256) external;

}

interface DaiJoinLike {

    function dai() external view returns (TokenLike);

    function vat() external view returns (VatLike);

    function join(address, uint256) external;

}

interface TokenLike {

    function approve(address, uint256) external;

    function transfer(address, uint256) external;

    function balanceOf(address) external view returns (uint256);

}

interface OtcLike {

    function buyAllAmount(address, uint256, address, uint256) external returns (uint256);

    function sellAllAmount(address, uint256, address, uint256) external returns (uint256);

}

contract CalleeMakerOtc {

    OtcLike         public otc;
    DaiJoinLike     public daiJoin;
    TokenLike       public dai;

    uint256         public constant RAY = 10 ** 27;

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function divup(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(x, sub(y, 1)) / y;
    }

    function setUp(address otc_, address clip_, address daiJoin_) internal {

        otc = OtcLike(otc_);
        daiJoin = DaiJoinLike(daiJoin_);
        dai = daiJoin.dai();


        daiJoin.vat().hope(clip_);

        dai.approve(daiJoin_, uint256(-1));
    }

    function _fromWad(address gemJoin, uint256 wad) internal view returns (uint256 amt) {

        amt = wad / 10 ** (sub(18, GemJoinLike(gemJoin).dec()));
    }
}

contract CalleeMakerOtcDai is CalleeMakerOtc {

    constructor(address otc_, address clip_, address daiJoin_) public {
        setUp(otc_, clip_, daiJoin_);
    }

    function clipperCall(
        address sender,         // Clipper Caller and Dai deliveryaddress
        uint256 daiAmt,         // Dai amount to payback[rad]
        uint256 gemAmt,         // Gem amount received [wad]
        bytes calldata data     // Extra data needed (gemJoin)
    ) external {

        (address to, address gemJoin, uint256 minProfit) = abi.decode(data, (address, address, uint256));

        gemAmt = _fromWad(gemJoin, gemAmt);

        GemJoinLike(gemJoin).exit(address(this), gemAmt);

        TokenLike gem = GemJoinLike(gemJoin).gem();
        gem.approve(address(otc), gemAmt);

        uint256 daiToJoin = divup(daiAmt, RAY);

        uint256 daiBought = otc.sellAllAmount(address(gem), gemAmt, address(dai), add(daiToJoin, minProfit));

        if (gem.balanceOf(address(this)) > 0) {
            gem.transfer(to, gem.balanceOf(address(this)));
        }

        daiJoin.join(sender, daiToJoin);

        dai.transfer(to, dai.balanceOf(address(this)));
    }
}

