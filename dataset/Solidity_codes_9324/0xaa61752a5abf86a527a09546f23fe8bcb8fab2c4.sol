




pragma solidity 0.6.12;

interface GemLike {

    function approve(address, uint256) external;

    function transfer(address, uint256) external;

    function transferFrom(address, address, uint256) external;

    function deposit() external payable;

    function withdraw(uint256) external;

    function balanceOf(address) external view returns (uint256);

}

interface CropperLike {

    function getOrCreateProxy(address) external returns (address);

    function join(address, address, uint256) external;

    function exit(address, address, uint256) external;

    function flee(address, address, uint256) external;

    function frob(bytes32, address, address, address, int256, int256) external;

    function quit(bytes32, address, address) external;

}

interface VatLike {

    function can(address, address) external view returns (uint256);

    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);

    function dai(address) external view returns (uint256);

    function urns(bytes32, address) external view returns (uint256, uint256);

    function hope(address) external;

    function nope(address) external;

    function flux(bytes32, address, address, uint256) external;

}

interface GemJoinLike {

    function dec() external returns (uint256);

    function gem() external returns (GemLike);

    function ilk() external returns (bytes32);

    function bonus() external returns (GemLike);

}

interface DaiJoinLike {

    function dai() external returns (GemLike);

    function join(address, uint256) external payable;

    function exit(address, uint256) external;

}

interface EndLike {

    function fix(bytes32) external view returns (uint256);

    function cash(bytes32, uint256) external;

    function free(bytes32) external;

    function pack(uint256) external;

    function skim(bytes32, address) external;

}

interface JugLike {

    function drip(bytes32) external returns (uint256);

}

interface HopeLike {

    function hope(address) external;

    function nope(address) external;

}

interface CdpRegistryLike {

    function owns(uint256) external view returns (address);

    function ilks(uint256) external view returns (bytes32);

    function open(bytes32, address) external returns (uint256);

}


contract Common {

    uint256 constant WAD = 10 ** 18;
    uint256 constant RAY = 10 ** 27;
    address immutable public vat;
    address immutable public cropper;
    address immutable public cdpRegistry;

    constructor(address vat_, address cropper_, address cdpRegistry_) public {
        vat = vat_;
        cropper = cropper_;
        cdpRegistry = cdpRegistry_;
    }


    function _mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }


    function daiJoin_join(address daiJoin, address u, uint256 wad) public {

        GemLike dai = DaiJoinLike(daiJoin).dai();
        dai.transferFrom(msg.sender, address(this), wad);
        dai.approve(daiJoin, wad);
        DaiJoinLike(daiJoin).join(u, wad);
    }
}

contract DssProxyActionsCropper is Common {


    constructor(address vat_, address cropper_, address cdpRegistry_) public Common(vat_, cropper_, cdpRegistry_) {}


    function _sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "sub-overflow");
    }

    function _divup(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x != 0 ? ((x - 1) / y) + 1 : 0;
    }

    function _toInt256(uint256 x) internal pure returns (int256 y) {

        y = int256(x);
        require(y >= 0, "int-overflow");
    }

    function _convertTo18(address gemJoin, uint256 amt) internal returns (uint256 wad) {

        wad = _mul(
            amt,
            10 ** (18 - GemJoinLike(gemJoin).dec())
        );
    }

    function _getDrawDart(
        address jug,
        address u,
        bytes32 ilk,
        uint256 wad
    ) internal returns (int256 dart) {

        uint256 rate = JugLike(jug).drip(ilk);

        uint256 dai = VatLike(vat).dai(u);

        uint256 rad = _mul(wad, RAY);
        if (dai < rad) {
            dart = _toInt256(_divup(rad - dai, rate)); // safe since dai < rad
        }
    }

    function _getWipeDart(
        uint256 dai,
        address u,
        bytes32 ilk
    ) internal returns (int256 dart) {

        (, uint256 rate,,,) = VatLike(vat).ilks(ilk);
        (, uint256 art) = VatLike(vat).urns(ilk, CropperLike(cropper).getOrCreateProxy(u));

        dart = _toInt256(dai / rate);
        dart = uint256(dart) <= art ? - dart : - _toInt256(art);
    }

    function _getWipeAllWad(
        address u,
        address urp,
        bytes32 ilk
    ) internal view returns (uint256 wad) {

        (, uint256 rate,,,) = VatLike(vat).ilks(ilk);
        (, uint256 art) = VatLike(vat).urns(ilk, urp);

        uint256 dai = VatLike(vat).dai(u);

        uint256 debt = _mul(art, rate);
        if (debt > dai) {
            wad = _divup(debt - dai, RAY); // safe since debt > dai
        }
    }

    function _frob(
        bytes32 ilk,
        address u,
        int256 dink,
        int256 dart
    ) internal {

        CropperLike(cropper).frob(ilk, u, u, u, dink, dart);
    }

    function _ethJoin_join(address ethJoin, address u) internal {

        GemLike gem = GemJoinLike(ethJoin).gem();
        gem.deposit{value: msg.value}();
        gem.approve(cropper, msg.value);
        CropperLike(cropper).join(ethJoin, u, msg.value);
    }

    function _gemJoin_join(address gemJoin, address u, uint256 amt) internal {

        GemLike gem = GemJoinLike(gemJoin).gem();
        gem.transferFrom(msg.sender, address(this), amt);
        gem.approve(cropper, amt);
        CropperLike(cropper).join(gemJoin, u, amt);
    }


    function transfer(address gem, address dst, uint256 amt) external {

        GemLike(gem).transfer(dst, amt);
    }

    function hope(
        address obj,
        address usr
    ) external {

        HopeLike(obj).hope(usr);
    }

    function nope(
        address obj,
        address usr
    ) external {

        HopeLike(obj).nope(usr);
    }

    function open(
        bytes32 ilk,
        address usr
    ) external returns (uint256 cdp) {

        cdp = CdpRegistryLike(cdpRegistry).open(ilk, usr);
    }

    function lockETH(
        address ethJoin,
        uint256 cdp
    ) external payable {

        address owner = CdpRegistryLike(cdpRegistry).owns(cdp);

        _ethJoin_join(ethJoin, owner);
        _frob(CdpRegistryLike(cdpRegistry).ilks(cdp), owner, _toInt256(msg.value), 0);
    }

    function lockGem(
        address gemJoin,
        uint256 cdp,
        uint256 amt
    ) external {

        address owner = CdpRegistryLike(cdpRegistry).owns(cdp);

        _gemJoin_join(gemJoin, owner, amt);
        _frob(CdpRegistryLike(cdpRegistry).ilks(cdp), owner, _toInt256(_convertTo18(gemJoin, amt)), 0);
    }

    function freeETH(
        address ethJoin,
        uint256 cdp,
        uint256 wad
    ) external {

        _frob(
            CdpRegistryLike(cdpRegistry).ilks(cdp),
            CdpRegistryLike(cdpRegistry).owns(cdp),
            -_toInt256(wad),
            0
        );
        CropperLike(cropper).exit(ethJoin, address(this), wad);
        GemJoinLike(ethJoin).gem().withdraw(wad);
        msg.sender.transfer(wad);
    }

    function freeGem(
        address gemJoin,
        uint256 cdp,
        uint256 amt
    ) external {

        _frob(
            CdpRegistryLike(cdpRegistry).ilks(cdp),
            CdpRegistryLike(cdpRegistry).owns(cdp),
            -_toInt256(_convertTo18(gemJoin, amt)),
            0
        );
        CropperLike(cropper).exit(gemJoin, address(this), amt);
        GemJoinLike(gemJoin).gem().transfer(msg.sender, amt);
    }

    function exitETH(
        address ethJoin,
        uint256 cdp,
        uint256 wad
    ) external {

        require(CdpRegistryLike(cdpRegistry).owns(cdp) == address(this), "wrong-cdp");
        require(CdpRegistryLike(cdpRegistry).ilks(cdp) == GemJoinLike(ethJoin).ilk(), "wrong-ilk");

        CropperLike(cropper).exit(ethJoin, address(this), wad);
        GemJoinLike(ethJoin).gem().withdraw(wad);
        msg.sender.transfer(wad);
    }

    function exitGem(
        address gemJoin,
        uint256 cdp,
        uint256 amt
    ) external {

        require(CdpRegistryLike(cdpRegistry).owns(cdp) == address(this), "wrong-cdp");
        require(CdpRegistryLike(cdpRegistry).ilks(cdp) == GemJoinLike(gemJoin).ilk(), "wrong-ilk");

        CropperLike(cropper).exit(gemJoin, address(this), amt);
        GemJoinLike(gemJoin).gem().transfer(msg.sender, amt);
    }

    function fleeETH(
        address ethJoin,
        uint256 cdp,
        uint256 wad
    ) external {

        require(CdpRegistryLike(cdpRegistry).owns(cdp) == address(this), "wrong-cdp");
        require(CdpRegistryLike(cdpRegistry).ilks(cdp) == GemJoinLike(ethJoin).ilk(), "wrong-ilk");
        CropperLike(cropper).flee(ethJoin, address(this), wad);
        GemJoinLike(ethJoin).gem().withdraw(wad);
        msg.sender.transfer(wad);
    }

    function fleeGem(
        address gemJoin,
        uint256 cdp,
        uint256 amt
    ) external {

        require(CdpRegistryLike(cdpRegistry).owns(cdp) == address(this), "wrong-cdp");
        require(CdpRegistryLike(cdpRegistry).ilks(cdp) == GemJoinLike(gemJoin).ilk(), "wrong-ilk");

        CropperLike(cropper).flee(gemJoin, msg.sender, amt);
    }

    function draw(
        address jug,
        address daiJoin,
        uint256 cdp,
        uint256 wad
    ) external {

        address owner = CdpRegistryLike(cdpRegistry).owns(cdp);
        bytes32 ilk = CdpRegistryLike(cdpRegistry).ilks(cdp);

        _frob(ilk, owner, 0, _getDrawDart(jug, owner, ilk, wad));
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        DaiJoinLike(daiJoin).exit(msg.sender, wad);
    }

    function wipe(
        address daiJoin,
        uint256 cdp,
        uint256 wad
    ) external {

        address owner = CdpRegistryLike(cdpRegistry).owns(cdp);
        bytes32 ilk = CdpRegistryLike(cdpRegistry).ilks(cdp);

        daiJoin_join(daiJoin, owner, wad);
        VatLike(vat).hope(cropper);
        _frob(
            ilk,
            owner,
            0,
            _getWipeDart(
                VatLike(vat).dai(owner),
                owner,
                ilk
            )
        );
        VatLike(vat).nope(cropper);
    }

    function wipeAll(
        address daiJoin,
        uint256 cdp
    ) external {

        address owner = CdpRegistryLike(cdpRegistry).owns(cdp);
        bytes32 ilk = CdpRegistryLike(cdpRegistry).ilks(cdp);

        address urp = CropperLike(cropper).getOrCreateProxy(owner);
        (, uint256 art) = VatLike(vat).urns(ilk, urp);

        daiJoin_join(daiJoin, owner, _getWipeAllWad(owner, urp, ilk));
        VatLike(vat).hope(cropper);
        _frob(ilk, owner, 0, -_toInt256(art));
        VatLike(vat).nope(cropper);
    }

    function lockETHAndDraw(
        address jug,
        address ethJoin,
        address daiJoin,
        uint256 cdp,
        uint256 wadD
    ) public payable {

        address owner = CdpRegistryLike(cdpRegistry).owns(cdp);
        bytes32 ilk = CdpRegistryLike(cdpRegistry).ilks(cdp);

        _ethJoin_join(ethJoin, owner);
        _frob(
            ilk,
            owner,
            _toInt256(msg.value),
            _getDrawDart(
                jug,
                owner,
                ilk,
                wadD
            )
        );
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        DaiJoinLike(daiJoin).exit(msg.sender, wadD);
    }

    function openLockETHAndDraw(
        address jug,
        address ethJoin,
        address daiJoin,
        bytes32 ilk,
        uint256 wadD
    ) public payable returns (uint256 cdp) {

        cdp = CdpRegistryLike(cdpRegistry).open(ilk, address(this));
        lockETHAndDraw(jug, ethJoin, daiJoin, cdp, wadD);
    }

    function lockGemAndDraw(
        address jug,
        address gemJoin,
        address daiJoin,
        uint256 cdp,
        uint256 amtC,
        uint256 wadD
    ) public {

        address owner = CdpRegistryLike(cdpRegistry).owns(cdp);
        bytes32 ilk = CdpRegistryLike(cdpRegistry).ilks(cdp);

        _gemJoin_join(gemJoin, owner, amtC);
        _frob(
            ilk,
            owner,
            _toInt256(_convertTo18(gemJoin, amtC)),
            _getDrawDart(
                jug,
                owner,
                ilk,
                wadD
            )
        );
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        DaiJoinLike(daiJoin).exit(msg.sender, wadD);
    }

    function openLockGemAndDraw(
        address jug,
        address gemJoin,
        address daiJoin,
        bytes32 ilk,
        uint256 amtC,
        uint256 wadD
    ) public returns (uint256 cdp) {

        cdp = CdpRegistryLike(cdpRegistry).open(ilk, address(this));
        lockGemAndDraw(jug, gemJoin, daiJoin, cdp, amtC, wadD);
    }

    function wipeAndFreeETH(
        address ethJoin,
        address daiJoin,
        uint256 cdp,
        uint256 wadC,
        uint256 wadD
    ) external {

        address owner = CdpRegistryLike(cdpRegistry).owns(cdp);
        bytes32 ilk = CdpRegistryLike(cdpRegistry).ilks(cdp);

        daiJoin_join(daiJoin, owner, wadD);
        VatLike(vat).hope(cropper);
        _frob(
            ilk,
            owner,
            -_toInt256(wadC),
            _getWipeDart(
                VatLike(vat).dai(owner),
                owner,
                ilk
            )
        );
        VatLike(vat).nope(cropper);
        CropperLike(cropper).exit(ethJoin, address(this), wadC);
        GemJoinLike(ethJoin).gem().withdraw(wadC);
        msg.sender.transfer(wadC);
    }

    function wipeAllAndFreeETH(
        address ethJoin,
        address daiJoin,
        uint256 cdp,
        uint256 wadC
    ) external {

        address owner = CdpRegistryLike(cdpRegistry).owns(cdp);
        bytes32 ilk = CdpRegistryLike(cdpRegistry).ilks(cdp);

        address urp = CropperLike(cropper).getOrCreateProxy(owner);
        (, uint256 art) = VatLike(vat).urns(ilk, urp);

        daiJoin_join(daiJoin, owner, _getWipeAllWad(owner, urp, ilk));
        VatLike(vat).hope(cropper);
        _frob(ilk, owner, -_toInt256(wadC), -_toInt256(art));
        VatLike(vat).nope(cropper);
        CropperLike(cropper).exit(ethJoin, address(this), wadC);
        GemJoinLike(ethJoin).gem().withdraw(wadC);
        msg.sender.transfer(wadC);
    }

    function wipeAndFreeGem(
        address gemJoin,
        address daiJoin,
        uint256 cdp,
        uint256 amtC,
        uint256 wadD
    ) external {

        address owner = CdpRegistryLike(cdpRegistry).owns(cdp);
        bytes32 ilk = CdpRegistryLike(cdpRegistry).ilks(cdp);

        daiJoin_join(daiJoin, owner, wadD);
        VatLike(vat).hope(cropper);
        _frob(
            ilk,
            owner,
            -_toInt256(_convertTo18(gemJoin, amtC)),
            _getWipeDart(
                VatLike(vat).dai(owner),
                owner,
                ilk
            )
        );
        VatLike(vat).nope(cropper);
        CropperLike(cropper).exit(gemJoin, address(this), amtC);
        GemJoinLike(gemJoin).gem().transfer(msg.sender, amtC);
    }

    function wipeAllAndFreeGem(
        address gemJoin,
        address daiJoin,
        uint256 cdp,
        uint256 amtC
    ) external {

        address owner = CdpRegistryLike(cdpRegistry).owns(cdp);
        bytes32 ilk = CdpRegistryLike(cdpRegistry).ilks(cdp);

        address urp = CropperLike(cropper).getOrCreateProxy(owner);
        (, uint256 art) = VatLike(vat).urns(ilk, urp);

        daiJoin_join(daiJoin, owner, _getWipeAllWad(owner, urp, ilk));
        VatLike(vat).hope(cropper);
        _frob(ilk, owner, -_toInt256(_convertTo18(gemJoin, amtC)), -_toInt256(art));
        VatLike(vat).nope(cropper);
        CropperLike(cropper).exit(gemJoin, address(this), amtC);
        GemJoinLike(gemJoin).gem().transfer(msg.sender, amtC);
    }

    function crop(
        address gemJoin,
        uint256 cdp
    ) external {

        address owner = CdpRegistryLike(cdpRegistry).owns(cdp);
        require(CdpRegistryLike(cdpRegistry).ilks(cdp) == GemJoinLike(gemJoin).ilk(), "wrong-ilk");

        CropperLike(cropper).join(gemJoin, owner, 0);
        GemLike bonus = GemJoinLike(gemJoin).bonus();
        bonus.transfer(msg.sender, bonus.balanceOf(address(this)));
    }
}

contract DssProxyActionsEndCropper is Common {


    constructor(address vat_, address cropper_, address cdpRegistry_) public Common(vat_, cropper_, cdpRegistry_) {}


    function _free(
        address end,
        address u,
        bytes32 ilk
    ) internal returns (uint256 ink) {

        address urp = CropperLike(cropper).getOrCreateProxy(u);
        uint256 art;
        (ink, art) = VatLike(vat).urns(ilk, urp);

        if (art > 0) {
            EndLike(end).skim(ilk, urp);
            (ink,) = VatLike(vat).urns(ilk, urp);
        }
        VatLike(vat).hope(cropper);
        CropperLike(cropper).quit(ilk, u, address(this));
        VatLike(vat).nope(cropper);
        EndLike(end).free(ilk);
        VatLike(vat).flux(
            ilk,
            address(this),
            urp,
            ink
        );
    }

    function freeETH(
        address ethJoin,
        address end,
        uint256 cdp
    ) external {

        uint256 wad = _free(end, CdpRegistryLike(cdpRegistry).owns(cdp), CdpRegistryLike(cdpRegistry).ilks(cdp));
        CropperLike(cropper).exit(ethJoin, address(this), wad);
        GemJoinLike(ethJoin).gem().withdraw(wad);
        msg.sender.transfer(wad);
    }

    function freeGem(
        address gemJoin,
        address end,
        uint256 cdp
    ) external {

        uint256 wad = _free(end, CdpRegistryLike(cdpRegistry).owns(cdp), CdpRegistryLike(cdpRegistry).ilks(cdp));
        uint256 amt = wad / 10 ** (18 - GemJoinLike(gemJoin).dec());
        CropperLike(cropper).exit(gemJoin, address(this), amt);
        GemJoinLike(gemJoin).gem().transfer(msg.sender, amt);
    }

    function pack(
        address daiJoin,
        address end,
        uint256 wad
    ) external {

        daiJoin_join(daiJoin, address(this), wad);
        if (VatLike(vat).can(address(this), address(end)) == 0) {
            VatLike(vat).hope(end);
        }
        EndLike(end).pack(wad);
    }

    function cashETH(
        address ethJoin,
        address end,
        uint256 wad
    ) external {

        bytes32 ilk = GemJoinLike(ethJoin).ilk();
        EndLike(end).cash(ilk, wad);
        uint256 wadC = _mul(wad, EndLike(end).fix(ilk)) / RAY;
        VatLike(vat).flux(
            ilk,
            address(this),
            CropperLike(cropper).getOrCreateProxy(address(this)),
            wadC
        );
        CropperLike(cropper).flee(ethJoin, address(this), wadC);
        GemJoinLike(ethJoin).gem().withdraw(wadC);
        msg.sender.transfer(wadC);
    }

    function cashGem(
        address gemJoin,
        address end,
        uint256 wad
    ) external {

        bytes32 ilk = GemJoinLike(gemJoin).ilk();
        EndLike(end).cash(ilk, wad);
        uint256 wadC = _mul(wad, EndLike(end).fix(ilk)) / RAY;
        VatLike(vat).flux(
            ilk,
            address(this),
            CropperLike(cropper).getOrCreateProxy(address(this)),
            wadC
        );
        uint256 amt = wadC / 10 ** (18 - GemJoinLike(gemJoin).dec());
        CropperLike(cropper).flee(gemJoin, msg.sender, amt);
    }
}