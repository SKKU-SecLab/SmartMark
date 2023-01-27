

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

interface UniswapV2Router02Like {

    function swapExactTokensForTokens(uint256, uint256, address[] calldata, address, uint256) external returns (uint[] memory);

}

contract UniswapV2Callee {

    UniswapV2Router02Like   public uniRouter02;
    DaiJoinLike             public daiJoin;
    TokenLike               public dai;

    uint256                 public constant RAY = 10 ** 27;

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function divup(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(x, sub(y, 1)) / y;
    }

    function setUp(address uniRouter02_, address clip_, address daiJoin_) internal {

        uniRouter02 = UniswapV2Router02Like(uniRouter02_);
        daiJoin = DaiJoinLike(daiJoin_);
        dai = daiJoin.dai();

        daiJoin.vat().hope(clip_);

        dai.approve(daiJoin_, uint256(-1));
    }

    function _fromWad(address gemJoin, uint256 wad) internal view returns (uint256 amt) {

        amt = wad / 10 ** (sub(18, GemJoinLike(gemJoin).dec()));
    }
}

contract UniswapV2CalleeDai is UniswapV2Callee {

    constructor(address uniRouter02_, address clip_, address daiJoin_) public {
        setUp(uniRouter02_, clip_, daiJoin_);
    }

    function clipperCall(
        address sender,         // Clipper Caller and Dai deliveryaddress
        uint256 daiAmt,         // Dai amount to payback[rad]
        uint256 gemAmt,         // Gem amount received [wad]
        bytes calldata data     // Extra data needed (gemJoin)
    ) external {

        (
            address to,
            address gemJoin,
            uint256 minProfit,
            address[] memory path
        ) = abi.decode(data, (address, address, uint256, address[]));

        gemAmt = _fromWad(gemJoin, gemAmt);

        GemJoinLike(gemJoin).exit(address(this), gemAmt);

        TokenLike gem = GemJoinLike(gemJoin).gem();
        gem.approve(address(uniRouter02), gemAmt);

        uint256 daiToJoin = divup(daiAmt, RAY);

        uint256[] memory amounts = uniRouter02.swapExactTokensForTokens(
                                                  gemAmt,
                                                  add(daiToJoin, minProfit),
                                                  path,
                                                  address(this),
                                                  block.timestamp
        );

        uint256 daiBought = amounts[1];

        if (gem.balanceOf(address(this)) > 0) {
            gem.transfer(to, gem.balanceOf(address(this)));
        }

        daiJoin.join(sender, daiToJoin);

        dai.transfer(to, dai.balanceOf(address(this)));
    }
}

