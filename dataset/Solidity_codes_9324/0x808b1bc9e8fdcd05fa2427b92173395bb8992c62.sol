
pragma solidity 0.5.11;

interface GemLike {

    function approve(address, uint) external;

    function transfer(address, uint) external;

    function transferFrom(address, address, uint) external;

    function deposit() external payable;

    function withdraw(uint) external;

}

interface ManagerLike {

    function cdpCan(address, uint, address) external view returns (uint);

    function ilks(uint) external view returns (bytes32);

    function owns(uint) external view returns (address);

    function urns(uint) external view returns (address);

    function vat() external view returns (address);

    function open(bytes32, address) external returns (uint);

    function give(uint, address) external;

    function cdpAllow(uint, address, uint) external;

    function urnAllow(address, uint) external;

    function frob(uint, int, int) external;

    function flux(uint, address, uint) external;

    function move(uint, address, uint) external;

    function exit(
        address,
        uint,
        address,
        uint
    ) external;

    function quit(uint, address) external;

    function enter(address, uint) external;

    function shift(uint, uint) external;

}

interface VatLike {

    function can(address, address) external view returns (uint);

    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);

    function dai(address) external view returns (uint);

    function urns(bytes32, address) external view returns (uint, uint);

    function frob(
        bytes32,
        address,
        address,
        address,
        int,
        int
    ) external;

    function hope(address) external;

    function move(address, address, uint) external;

}

interface GemJoinLike {

    function dec() external returns (uint);

    function gem() external returns (GemLike);

    function join(address, uint) external payable;

    function exit(address, uint) external;

}

interface DaiJoinLike {

    function vat() external returns (VatLike);

    function dai() external returns (GemLike);

    function join(address, uint) external payable;

    function exit(address, uint) external;

}

interface HopeLike {

    function hope(address) external;

    function nope(address) external;

}

interface JugLike {

    function drip(bytes32) external returns (uint);

}

interface ProxyRegistryLike {

    function proxies(address) external view returns (address);

    function build(address) external returns (address);

}

interface ProxyLike {

    function owner() external view returns (address);

}

interface InstaMcdAddress {

    function manager() external returns (address);

    function dai() external returns (address);

    function daiJoin() external returns (address);

    function jug() external returns (address);

    function proxyRegistry() external returns (address);

    function ethAJoin() external returns (address);

}


contract Common {

    uint256 constant RAY = 10 ** 27;

    function getMcdAddresses() public pure returns (address mcd) {

        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0; // Check Thrilok - add addr at time of deploy
    }

    function getGiveAddress() public pure returns (address addr) {

        addr = 0xc679857761beE860f5Ec4B3368dFE9752580B096;
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "sub-overflow");
    }

    function toInt(uint x) internal pure returns (int y) {

        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function toRad(uint wad) internal pure returns (uint rad) {

        rad = mul(wad, 10 ** 27);
    }

    function convertTo18(address gemJoin, uint256 amt) internal returns (uint256 wad) {

        wad = mul(
            amt,
            10 ** (18 - GemJoinLike(gemJoin).dec())
        );
    }
}


contract DssProxyHelpers is Common {

    event LogOpen(uint vaultNum, bytes32 ilk, address owner);
    event LogGive(uint vaultNum, address owner, address nextOwner);
    event LogLock(uint vaultNum, uint collAmt, address colJoin, address owner);
    event LogFree(uint vaultNum, uint collAmt, address colJoin, address owner);
    event LogDraw(uint vaultNum, uint daiAmt, address owner);
    event LogWipe(uint vaultNum, uint daiAmt, address owner);
    event LogExit(uint vaultNum, uint collAmt, address colJoin, address owner);
    event LogShut(uint vaultNum);
    event LogCdpAllow(uint vaultNum, address usr, uint ok, address owner);
    event LogUrnAllow(address urn, uint ok, address owner);

    function joinDaiJoin(address urn, uint wad) public {

        address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();
        DaiJoinLike(daiJoin).dai().transferFrom(msg.sender, address(this), wad);
        DaiJoinLike(daiJoin).dai().approve(daiJoin, wad);
        DaiJoinLike(daiJoin).join(urn, wad);
    }

    function _getDrawDart(
        address vat,
        address jug,
        address urn,
        bytes32 ilk,
        uint wad
    ) internal returns (int dart)
    {

        uint rate = JugLike(jug).drip(ilk);

        uint dai = VatLike(vat).dai(urn);

        if (dai < mul(wad, RAY)) {
            dart = toInt(sub(mul(wad, RAY), dai) / rate);
            dart = mul(uint(dart), rate) < mul(wad, RAY) ? dart + 1 : dart;
        }
    }

    function _getWipeDart(
        address vat,
        uint dai,
        address urn,
        bytes32 ilk
    ) internal view returns (int dart)
    {

        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        (, uint art) = VatLike(vat).urns(ilk, urn);

        dart = toInt(dai / rate);
        dart = uint(dart) <= art ? - dart : - toInt(art);
    }

    function _getWipeAllWad(
        address vat,
        address usr,
        address urn,
        bytes32 ilk
    ) internal view returns (uint wad)
    {

        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        (, uint art) = VatLike(vat).urns(ilk, urn);
        uint dai = VatLike(vat).dai(usr);

        uint rad = sub(mul(art, rate), dai);
        wad = rad / RAY;

        wad = mul(wad, RAY) < rad ? wad + 1 : wad;
    }
}


contract DssProxyActions is DssProxyHelpers {


    function transfer(address gem, address dst, uint wad) public {

        GemLike(gem).transfer(dst, wad);
    }

    function joinEthJoin(address ethJoin, address urn) public payable {

        GemJoinLike(ethJoin).gem().deposit.value(msg.value)();
        GemJoinLike(ethJoin).gem().approve(address(ethJoin), msg.value);
        GemJoinLike(ethJoin).join(urn, msg.value);
    }

    function joinGemJoin(
        address apt,
        address urn,
        uint wad,
        bool transferFrom
    ) public
    {

        if (transferFrom) {
            GemJoinLike(apt).gem().transferFrom(msg.sender, address(this), wad);
            GemJoinLike(apt).gem().approve(apt, wad);
        }
        GemJoinLike(apt).join(urn, wad);
    }

    function hope(address obj, address usr) public {

        HopeLike(obj).hope(usr);
    }

    function nope(address obj, address usr) public {

        HopeLike(obj).nope(usr);
    }

    function open(bytes32 ilk, address usr) public returns (uint cdp) {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        cdp = ManagerLike(manager).open(ilk, usr);
        emit LogOpen(
            cdp,
            ilk,
            usr
        );
    }

    function give(uint cdp, address usr) public {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).give(cdp, usr);
        emit LogGive(
            cdp,
            address(this),
            usr
        );

    }

    function shut(uint cdp) public {

        give(cdp, getGiveAddress());
        emit LogShut(cdp);
    }

    function giveToProxy(uint cdp, address dst) public {

        address proxyRegistry = InstaMcdAddress(getMcdAddresses()).proxyRegistry(); //CHECK THRILOK -- Added proxyRegistry
        address proxy = ProxyRegistryLike(proxyRegistry).proxies(dst);
        if (proxy == address(0) || ProxyLike(proxy).owner() != dst) {
            uint csize;
            assembly {
                csize := extcodesize(dst)
            }
            require(csize == 0, "Dst-is-a-contract");
            proxy = ProxyRegistryLike(proxyRegistry).build(dst);
        }
        give(cdp, proxy);
    }

    function cdpAllow(uint cdp, address usr, uint ok) public {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).cdpAllow(cdp, usr, ok);
        emit LogCdpAllow(
            cdp,
            usr,
            ok,
            address(this)
        );
    }

    function urnAllow(address usr, uint ok) public {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).urnAllow(usr, ok);
        emit LogUrnAllow(
            usr,
            ok,
            address(this)
        );
    }

    function flux(uint cdp, address dst, uint wad) public {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).flux(cdp, dst, wad);
    }

    function move(uint cdp, address dst, uint rad) public {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).move(cdp, dst, rad);
    }

    function frob(uint cdp, int dink, int dart) public {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).frob(cdp, dink, dart);
    }

    function quit(uint cdp, address dst) public {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).quit(cdp, dst);
    }

    function enter(address src, uint cdp) public {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).enter(src, cdp);
    }

    function shift(uint cdpSrc, uint cdpOrg) public {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).shift(cdpSrc, cdpOrg);
    }

    function lockETH(uint cdp, address ethJoin) public payable {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        joinEthJoin(ethJoin, address(this));
        VatLike(ManagerLike(manager).vat()).frob(
            ManagerLike(manager).ilks(cdp),
            ManagerLike(manager).urns(cdp),
            address(this),
            address(this),
            toInt(msg.value),
            0
        );
        emit LogLock(
            cdp,
            msg.value,
            InstaMcdAddress(getMcdAddresses()).ethAJoin(),
            address(this)
        );
    }

    function safeLockETH(uint cdp, address ethJoin, address owner) public payable {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        require(ManagerLike(manager).owns(cdp) == owner, "owner-missmatch");
        lockETH(cdp, ethJoin);
    }

    function lockGem(
        uint cdp,
        address gemJoin,
        uint wad,
        bool transferFrom
    ) public
    {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        joinGemJoin(
            gemJoin,
            address(this),
            wad,
            transferFrom
        );
        VatLike(ManagerLike(manager).vat()).frob(
            ManagerLike(manager).ilks(cdp),
            ManagerLike(manager).urns(cdp),
            address(this),
            address(this),
            toInt(convertTo18(gemJoin, wad)),
            0
        );
        emit LogLock(
            cdp,
            wad,
            gemJoin,
            address(this)
        );
    }

    function safeLockGem(
        uint cdp,
        address gemJoin,
        uint wad,
        bool transferFrom,
        address owner
    ) public
    {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        require(ManagerLike(manager).owns(cdp) == owner, "owner-missmatch");
        lockGem(
            cdp,
            gemJoin,
            wad,
            transferFrom);
    }

    function freeETH(uint cdp, address ethJoin, uint wad) public {

        frob(
            cdp,
            -toInt(wad),
            0
        );
        flux(
            cdp,
            address(this),
            wad
        );
        GemJoinLike(ethJoin).exit(address(this), wad);
        GemJoinLike(ethJoin).gem().withdraw(wad);
        msg.sender.transfer(wad);
        emit LogFree(
            cdp,
            wad,
            ethJoin,
            address(this)
        );
    }

    function freeGem(uint cdp, address gemJoin, uint wad) public {

        uint wad18 = convertTo18(gemJoin, wad);
        frob(
            cdp,
            -toInt(wad18),
            0
        );
        flux(
            cdp,
            address(this),
            wad18
        );
        GemJoinLike(gemJoin).exit(msg.sender, wad);
        emit LogFree(
            cdp,
            wad,
            gemJoin,
            address(this)
        );
    }

    function exitETH(uint cdp, address ethJoin, uint wad) public {

        flux(
            cdp,
            address(this),
            wad
        );

        GemJoinLike(ethJoin).exit(address(this), wad);
        GemJoinLike(ethJoin).gem().withdraw(wad);
        msg.sender.transfer(wad);
        emit LogExit(
            cdp,
            wad,
            ethJoin,
            address(this)
        );
    }

    function exitGem(uint cdp, address gemJoin, uint wad) public {

        flux(
            cdp,
            address(this),
            convertTo18(gemJoin, wad)
        );

        GemJoinLike(gemJoin).exit(msg.sender, wad);
        emit LogExit(
            cdp,
            wad,
            gemJoin,
            address(this)
        );
    }

    function draw(uint cdp, uint wad) public {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        address jug = InstaMcdAddress(getMcdAddresses()).jug();
        address daiJoin = InstaMcdAddress(getMcdAddresses()).daiJoin();
        address urn = ManagerLike(manager).urns(cdp);
        address vat = ManagerLike(manager).vat();
        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        frob(
            cdp,
            0,
            _getDrawDart(
                vat,
                jug,
                urn,
                ilk,
                wad
            )
        );
        move(
            cdp,
            address(this),
            toRad(wad)
        );
        if (VatLike(vat).can(address(this), address(daiJoin)) == 0) {
            VatLike(vat).hope(daiJoin);
        }
        DaiJoinLike(daiJoin).exit(msg.sender, wad);
        emit LogDraw(
            cdp,
            wad,
            address(this)
        );
    }

    function wipe(uint cdp, uint wad) public {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        address vat = ManagerLike(manager).vat();
        address urn = ManagerLike(manager).urns(cdp);
        bytes32 ilk = ManagerLike(manager).ilks(cdp);

        address own = ManagerLike(manager).owns(cdp);
        if (own == address(this) || ManagerLike(manager).cdpCan(own, cdp, address(this)) == 1) {
            joinDaiJoin(urn, wad);
            frob(
                cdp,
                0,
                _getWipeDart(
                    vat,
                    VatLike(vat).dai(urn),
                    urn,
                    ilk
                )
            );
        } else {
            joinDaiJoin(address(this), wad);
            VatLike(vat).frob(
                ilk,
                urn,
                address(this),
                address(this),
                0,
                _getWipeDart(
                    vat,
                    wad * RAY,
                    urn,
                    ilk
                )
            );
        }
        emit LogWipe(
            cdp,
            wad,
            address(this)
        );
    }

    function safeWipe(uint cdp, uint wad, address owner) public {

        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        require(ManagerLike(manager).owns(cdp) == owner, "owner-missmatch");
        wipe(
            cdp,
            wad
        );
    }
}