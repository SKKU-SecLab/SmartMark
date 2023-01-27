
pragma solidity ^0.5.12;

contract GemLike {

    function approve(address, uint) public;

    function transfer(address, uint) public;

    function transferFrom(address, address, uint) public;

    function deposit() public payable;

    function withdraw(uint) public;

}

contract ManagerLike {

    function cdpCan(address, uint, address) public view returns (uint);

    function ilks(uint) public view returns (bytes32);

    function owns(uint) public view returns (address);

    function urns(uint) public view returns (address);

    function vat() public view returns (address);

    function open(bytes32, address) public returns (uint);

    function give(uint, address) public;

    function cdpAllow(uint, address, uint) public;

    function urnAllow(address, uint) public;

    function frob(uint, int, int) public;

    function flux(uint, address, uint) public;

    function move(uint, address, uint) public;

    function exit(address, uint, address, uint) public;

    function quit(uint, address) public;

    function enter(address, uint) public;

    function shift(uint, uint) public;

}

contract VatLike {

    function can(address, address) public view returns (uint);

    function ilks(bytes32) public view returns (uint, uint, uint, uint, uint);

    function dai(address) public view returns (uint);

    function urns(bytes32, address) public view returns (uint, uint);

    function frob(bytes32, address, address, address, int, int) public;

    function hope(address) public;

    function move(address, address, uint) public;

}

contract GemJoinLike {

    function dec() public returns (uint);

    function gem() public returns (GemLike);

    function join(address, uint) public payable;

    function exit(address, uint) public;

}

contract GNTJoinLike {

    function bags(address) public view returns (address);

    function make(address) public returns (address);

}

contract DaiJoinLike {

    function vat() public returns (VatLike);

    function dai() public returns (GemLike);

    function join(address, uint) public payable;

    function exit(address, uint) public;

}

contract HopeLike {

    function hope(address) public;

    function nope(address) public;

}

contract EndLike {

    function fix(bytes32) public view returns (uint);

    function cash(bytes32, uint) public;

    function free(bytes32) public;

    function pack(uint) public;

    function skim(bytes32, address) public;

}

contract JugLike {

    function drip(bytes32) public returns (uint);

}

contract PotLike {

    function pie(address) public view returns (uint);

    function drip() public returns (uint);

    function join(uint) public;

    function exit(uint) public;

}

contract ProxyRegistryLike {

    function proxies(address) public view returns (address);

    function build(address) public returns (address);

}

contract ProxyLike {

    function owner() public view returns (address);

}


contract Common {

    uint256 constant RAY = 10 ** 27;


    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }


    function daiJoin_join(address apt, address urn, uint wad) public {

        DaiJoinLike(apt).dai().transferFrom(msg.sender, address(this), wad);
        DaiJoinLike(apt).dai().approve(apt, wad);
        DaiJoinLike(apt).join(urn, wad);
    }
}

contract DssProxyActionsEnd is Common {


    function _free(
        address manager,
        address end,
        uint cdp
    ) internal returns (uint ink) {

        bytes32 ilk = ManagerLike(manager).ilks(cdp);
        address urn = ManagerLike(manager).urns(cdp);
        VatLike vat = VatLike(ManagerLike(manager).vat());
        uint art;
        (ink, art) = vat.urns(ilk, urn);

        if (art > 0) {
            EndLike(end).skim(ilk, urn);
            (ink,) = vat.urns(ilk, urn);
        }
        if (vat.can(address(this), address(manager)) == 0) {
            vat.hope(manager);
        }
        ManagerLike(manager).quit(cdp, address(this));
        EndLike(end).free(ilk);
    }

    function freeETH(
        address manager,
        address ethJoin,
        address end,
        uint cdp
    ) public {

        uint wad = _free(manager, end, cdp);
        GemJoinLike(ethJoin).exit(address(this), wad);
        GemJoinLike(ethJoin).gem().withdraw(wad);
        msg.sender.transfer(wad);
    }

    function freeGem(
        address manager,
        address gemJoin,
        address end,
        uint cdp
    ) public {

        uint amt = _free(manager, end, cdp) / 10 ** (18 - GemJoinLike(gemJoin).dec());
        GemJoinLike(gemJoin).exit(msg.sender, amt);
    }

    function pack(
        address daiJoin,
        address end,
        uint wad
    ) public {

        daiJoin_join(daiJoin, address(this), wad);
        VatLike vat = DaiJoinLike(daiJoin).vat();
        if (vat.can(address(this), address(end)) == 0) {
            vat.hope(end);
        }
        EndLike(end).pack(wad);
    }

    function cashETH(
        address ethJoin,
        address end,
        bytes32 ilk,
        uint wad
    ) public {

        EndLike(end).cash(ilk, wad);
        uint wadC = mul(wad, EndLike(end).fix(ilk)) / RAY;
        GemJoinLike(ethJoin).exit(address(this), wadC);
        GemJoinLike(ethJoin).gem().withdraw(wadC);
        msg.sender.transfer(wadC);
    }

    function cashGem(
        address gemJoin,
        address end,
        bytes32 ilk,
        uint wad
    ) public {

        EndLike(end).cash(ilk, wad);
        uint amt = mul(wad, EndLike(end).fix(ilk)) / RAY / 10 ** (18 - GemJoinLike(gemJoin).dec());
        GemJoinLike(gemJoin).exit(msg.sender, amt);
    }
}