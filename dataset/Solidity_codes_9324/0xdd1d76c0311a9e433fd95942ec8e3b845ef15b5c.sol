
pragma solidity =0.6.12;






interface GemLike_8 {

    function approve(address, uint256) external;

    function transfer(address, uint256) external;

    function transferFrom(address, address, uint256) external;

    function deposit() external payable;

    function withdraw(uint256) external;

}

interface CharterLike {

    function getOrCreateProxy(address) external returns (address);

    function join(address, address, uint256) external;

    function exit(address, address, uint256) external;

    function frob(bytes32, address, address, address, int256, int256) external;

    function quit(bytes32 ilk, address dst) external;

    function gate(bytes32) external view returns (uint256);

    function Nib(bytes32) external view returns (uint256);

    function nib(bytes32, address) external view returns (uint256);

}

interface VatLike_17 {

    function can(address, address) external view returns (uint256);

    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);

    function dai(address) external view returns (uint256);

    function urns(bytes32, address) external view returns (uint256, uint256);

    function hope(address) external;

    function nope(address) external;

    function flux(bytes32, address, address, uint256) external;

}

interface GemJoinLike_2 {

    function dec() external returns (uint256);

    function gem() external returns (GemLike_8);

    function ilk() external returns (bytes32);

}

interface DaiJoinLike {

    function dai() external returns (GemLike_8);

    function join(address, uint256) external payable;

    function exit(address, uint256) external;

}

interface EndLike_3 {

    function fix(bytes32) external view returns (uint256);

    function cash(bytes32, uint256) external;

    function free(bytes32) external;

    function pack(uint256) external;

    function skim(bytes32, address) external;

}

interface JugLike {

    function drip(bytes32) external returns (uint256);

}

interface HopeLike_2 {

    function hope(address) external;

    function nope(address) external;

}


contract Common {

    uint256 constant WAD = 10 ** 18;
    uint256 constant RAY = 10 ** 27;
    address immutable vat;
    address immutable charter;

    constructor(address vat_, address charter_) public {
        vat = vat_;
        charter = charter_;
    }


    function _mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }


    function daiJoin_join(address daiJoin, uint256 wad) public {

        GemLike_8 dai = DaiJoinLike(daiJoin).dai();
        dai.transferFrom(msg.sender, address(this), wad);
        dai.approve(daiJoin, wad);
        DaiJoinLike(daiJoin).join(address(this), wad);
    }
}

contract DssProxyActionsCharter is Common {


    constructor(address vat_, address charter_) public Common(vat_, charter_) {}


    function _sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "sub-overflow");
    }

    function _toInt256(uint256 x) internal pure returns (int256 y) {

        y = int256(x);
        require(y >= 0, "int-overflow");
    }

    function _convertTo18(address gemJoin, uint256 amt) internal returns (uint256 wad) {

        wad = _mul(
            amt,
            10 ** (18 - GemJoinLike_2(gemJoin).dec())
        );
    }

    function _getDrawDart(
        address jug,
        bytes32 ilk,
        uint256 wad
    )  internal returns (int256 dart) {

        uint256 rate = JugLike(jug).drip(ilk);

        uint256 dai = VatLike_17(vat).dai(address(this));

        uint256 rad = _mul(wad, RAY);
        if (dai < rad) {
            uint256 netToDraw = rad - dai; // dai < rad

            uint256 nib = (CharterLike(charter).gate(ilk) == 1) ?
                CharterLike(charter).nib(ilk, address(this)) :
                CharterLike(charter).Nib(ilk);

            dart = _toInt256(_mul(netToDraw, WAD) / _sub(_mul(rate, WAD), _mul(rate, nib))); // wad
            uint256 dtab = _mul(uint256(dart), rate);
            dart = _sub(dtab, _mul(dtab, nib) / WAD) < netToDraw ? dart + 1 : dart;
        }
    }

    function _getWipeDart(
        uint256 dai,
        address urp,
        bytes32 ilk
    ) internal view returns (int256 dart) {

        (, uint256 rate,,,) = VatLike_17(vat).ilks(ilk);
        (, uint256 art) = VatLike_17(vat).urns(ilk, urp);

        dart = _toInt256(dai / rate);
        dart = uint256(dart) <= art ? - dart : - _toInt256(art);
    }

    function _getWipeAllWad(
        address urp,
        bytes32 ilk
    ) internal view returns (uint256 wad) {

        (, uint256 rate,,,) = VatLike_17(vat).ilks(ilk);
        (, uint256 art) = VatLike_17(vat).urns(ilk, urp);

        uint256 dai = VatLike_17(vat).dai(address(this));

        uint256 debt = _mul(art, rate);
        if (debt > dai) {
            uint256 rad = _sub(debt, dai);
            wad = rad / RAY;

            wad = _mul(wad, RAY) < rad ? wad + 1 : wad;
        }
    }

    function _frob(
        bytes32 ilk,
        int256 dink,
        int256 dart
    ) internal {

        CharterLike(charter).frob(ilk, address(this), address(this), address(this), dink, dart);
    }

    function _ethJoin_join(address ethJoin) internal {

        GemLike_8 gem = GemJoinLike_2(ethJoin).gem();
        gem.deposit{value: msg.value}();
        gem.approve(charter, msg.value);
        CharterLike(charter).join(ethJoin, address(this), msg.value);
    }

    function _gemJoin_join(address gemJoin, uint256 amt) internal {

        GemLike_8 gem = GemJoinLike_2(gemJoin).gem();
        gem.transferFrom(msg.sender, address(this), amt);
        gem.approve(charter, amt);
        CharterLike(charter).join(gemJoin, address(this), amt);
    }


    function transfer(address gem, address dst, uint256 amt) external {

        GemLike_8(gem).transfer(dst, amt);
    }

    function hope(
        address obj,
        address usr
    ) external {

        HopeLike_2(obj).hope(usr);
    }

    function nope(
        address obj,
        address usr
    ) external {

        HopeLike_2(obj).nope(usr);
    }

    function quit(
        bytes32 ilk,
        address dst
    ) external {

        CharterLike(charter).quit(ilk, dst);
    }

    function lockETH(address ethJoin) external payable {

        _ethJoin_join(ethJoin);
        _frob(GemJoinLike_2(ethJoin).ilk(), _toInt256(msg.value), 0);
    }

    function lockGem(
        address gemJoin,
        uint256 amt
    ) external {

        _gemJoin_join(gemJoin, amt);
        _frob(GemJoinLike_2(gemJoin).ilk(), _toInt256(_convertTo18(gemJoin, amt)), 0);
    }

    function freeETH(
        address ethJoin,
        uint256 wad
    ) external {

        _frob(GemJoinLike_2(ethJoin).ilk(), -_toInt256(wad), 0);
        CharterLike(charter).exit(ethJoin, address(this), wad);
        GemJoinLike_2(ethJoin).gem().withdraw(wad);
        msg.sender.transfer(wad);
    }

    function freeGem(
        address gemJoin,
        uint256 amt
    ) external {

        _frob(GemJoinLike_2(gemJoin).ilk(), -_toInt256(_convertTo18(gemJoin, amt)), 0);
        CharterLike(charter).exit(gemJoin, msg.sender, amt);
    }

    function exitETH(
        address ethJoin,
        uint256 wad
    ) external {

        CharterLike(charter).exit(ethJoin, address(this), wad);
        GemJoinLike_2(ethJoin).gem().withdraw(wad);
        msg.sender.transfer(wad);
    }

    function exitGem(
        address gemJoin,
        uint256 amt
    ) external {

        CharterLike(charter).exit(gemJoin, msg.sender, amt);
    }

    function draw(
        bytes32 ilk,
        address jug,
        address daiJoin,
        uint256 wad
    ) external {

        _frob(ilk, 0, _getDrawDart(jug, ilk, wad));
        if (VatLike_17(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike_17(vat).hope(daiJoin);
        }
        DaiJoinLike(daiJoin).exit(msg.sender, wad);
    }

    function wipe(
        bytes32 ilk,
        address daiJoin,
        uint256 wad
    ) external {

        daiJoin_join(daiJoin, wad);
        VatLike_17(vat).hope(charter);
        _frob(
            ilk,
            0,
            _getWipeDart(
                VatLike_17(vat).dai(address(this)),
                CharterLike(charter).getOrCreateProxy(address(this)),
                ilk
            )
        );
        VatLike_17(vat).nope(charter);
    }

    function wipeAll(
        bytes32 ilk,
        address daiJoin
    ) external {

        address urp = CharterLike(charter).getOrCreateProxy(address(this));
        (, uint256 art) = VatLike_17(vat).urns(ilk, urp);

        daiJoin_join(daiJoin, _getWipeAllWad(urp, ilk));
        VatLike_17(vat).hope(charter);
        _frob(ilk, 0, -_toInt256(art));
        VatLike_17(vat).nope(charter);
    }

    function lockETHAndDraw(
        address jug,
        address ethJoin,
        address daiJoin,
        uint256 wadD
    ) external payable {

        bytes32 ilk = GemJoinLike_2(ethJoin).ilk();

        _ethJoin_join(ethJoin);
        _frob(
            ilk,
            _toInt256(msg.value),
            _getDrawDart(
                jug,
                ilk,
                wadD
            )
        );
        if (VatLike_17(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike_17(vat).hope(daiJoin);
        }
        DaiJoinLike(daiJoin).exit(msg.sender, wadD);
    }

    function lockGemAndDraw(
        address jug,
        address gemJoin,
        address daiJoin,
        uint256 amtC,
        uint256 wadD
    ) external {

        bytes32 ilk = GemJoinLike_2(gemJoin).ilk();

        _gemJoin_join(gemJoin, amtC);
        _frob(
            ilk,
            _toInt256(_convertTo18(gemJoin, amtC)),
            _getDrawDart(
                jug,
                ilk,
                wadD
            )
        );
        if (VatLike_17(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike_17(vat).hope(daiJoin);
        }
        DaiJoinLike(daiJoin).exit(msg.sender, wadD);
    }

    function wipeAndFreeETH(
        address ethJoin,
        address daiJoin,
        uint256 wadC,
        uint256 wadD
    ) external {

        bytes32 ilk = GemJoinLike_2(ethJoin).ilk();

        daiJoin_join(daiJoin, wadD);
        VatLike_17(vat).hope(charter);
        _frob(
            ilk,
            -_toInt256(wadC),
            _getWipeDart(
                VatLike_17(vat).dai(address(this)),
                CharterLike(charter).getOrCreateProxy(address(this)),
                ilk
            )
        );
        VatLike_17(vat).nope(charter);
        CharterLike(charter).exit(ethJoin, address(this), wadC);
        GemJoinLike_2(ethJoin).gem().withdraw(wadC);
        msg.sender.transfer(wadC);
    }

    function wipeAllAndFreeETH(
        address ethJoin,
        address daiJoin,
        uint256 wadC
    ) external {

        address urp = CharterLike(charter).getOrCreateProxy(address(this));
        bytes32 ilk = GemJoinLike_2(ethJoin).ilk();
        (, uint256 art) = VatLike_17(vat).urns(ilk, urp);

        daiJoin_join(daiJoin, _getWipeAllWad(urp, ilk));
        VatLike_17(vat).hope(charter);
        _frob(ilk, -_toInt256(wadC), -_toInt256(art));
        VatLike_17(vat).nope(charter);
        CharterLike(charter).exit(ethJoin, address(this), wadC);
        GemJoinLike_2(ethJoin).gem().withdraw(wadC);
        msg.sender.transfer(wadC);
    }

    function wipeAndFreeGem(
        address gemJoin,
        address daiJoin,
        uint256 amtC,
        uint256 wadD
    ) external {

        bytes32 ilk = GemJoinLike_2(gemJoin).ilk();

        daiJoin_join(daiJoin, wadD);
        VatLike_17(vat).hope(charter);
        _frob(
            ilk,
            -_toInt256(_convertTo18(gemJoin, amtC)),
            _getWipeDart(
                VatLike_17(vat).dai(address(this)),
                CharterLike(charter).getOrCreateProxy(address(this)),
                ilk
            )
        );
        VatLike_17(vat).nope(charter);
        CharterLike(charter).exit(gemJoin, msg.sender, amtC);
    }

    function wipeAllAndFreeGem(
        address gemJoin,
        address daiJoin,
        uint256 amtC
    ) external {

        address urp = CharterLike(charter).getOrCreateProxy(address(this));
        bytes32 ilk = GemJoinLike_2(gemJoin).ilk();
        (, uint256 art) = VatLike_17(vat).urns(ilk, urp);

        daiJoin_join(daiJoin, _getWipeAllWad(urp, ilk));
        VatLike_17(vat).hope(charter);
        _frob(ilk, -_toInt256(_convertTo18(gemJoin, amtC)), -_toInt256(art));
        VatLike_17(vat).nope(charter);
        CharterLike(charter).exit(gemJoin, msg.sender, amtC);
    }
}