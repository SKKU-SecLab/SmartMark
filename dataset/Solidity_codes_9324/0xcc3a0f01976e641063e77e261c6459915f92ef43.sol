
pragma solidity ^0.5.15;

contract JugAbstract {

    function wards(address) public view returns (uint256);

    function rely(address) external;

    function deny(address) external;

    struct Ilk {
        uint256 duty;
        uint256  rho;
    }
    function ilks(bytes32) public view returns (uint256, uint256);

    function vat() public view returns (address);

    function vow() public view returns (address);

    function base() public view returns (address);

    function ONE() public view returns (uint256);

    function init(bytes32) external;

    function file(bytes32, bytes32, uint256) external;

    function file(bytes32, uint256) external;

    function file(bytes32, address) external;

    function drip(bytes32) external returns (uint256);

}

contract PotAbstract {

    function wards(address) public view returns (uint256);

    function rely(address) external;

    function deny(address) external;

    function pie(address) public view returns (uint256);

    function Pie() public view returns (uint256);

    function dsr() public view returns (uint256);

    function chi() public view returns (uint256);

    function vat() public view returns (address);

    function vow() public view returns (address);

    function rho() public view returns (uint256);

    function live() public view returns (uint256);

    function file(bytes32, uint256) external;

    function file(bytes32, address) external;

    function cage() external;

    function drip() external returns (uint256);

    function join(uint256) external;

    function exit(uint256) external;

}

contract PotHelper {


    PotAbstract pa;
    
    constructor(address pot) public {
        pa = PotAbstract(pot);
    }

    uint256 constant ONE = 10 ** 27;
    
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x);
    }

    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = mul(x, y) / ONE;
    }

    function rpow(uint x, uint n, uint base) internal pure returns (uint z) {

        assembly {
            switch x case 0 {switch n case 0 {z := base} default {z := 0}}
            default {
                switch mod(n, 2) case 0 { z := base } default { z := x }
                let half := div(base, 2)  // for rounding.
                for { n := div(n, 2) } n { n := div(n,2) } {
                    let xx := mul(x, x)
                    if iszero(eq(div(xx, x), x)) { revert(0,0) }
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) { revert(0,0) }
                    x := div(xxRound, base)
                    if mod(n,2) {
                        let zx := mul(z, x)
                        if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) { revert(0,0) }
                        z := div(zxRound, base)
                    }
                }
            }
        }
    }

    function drop() external view returns (uint256) {
        if (now == pa.rho()) return pa.chi();
        return rmul(rpow(pa.dsr(), now - pa.rho(), ONE), pa.chi());
    }

    function pot() external view returns (PotAbstract) {
        return pa;
    }
}

contract VowAbstract {

    function wards(address) public view returns (uint256);

    function rely(address usr) external;

    function deny(address usr) external;

    function vat() public view returns (address);

    function flapper() public view returns (address);

    function flopper() public view returns (address);

    function sin(uint256) public view returns (uint256);

    function Sin() public view returns (uint256);

    function Ash() public view returns (uint256);

    function wait() public view returns (uint256);

    function dump() public view returns (uint256);

    function sump() public view returns (uint256);

    function bump() public view returns (uint256);

    function hump() public view returns (uint256);

    function live() public view returns (uint256);

    function file(bytes32, uint256) external;

    function file(bytes32, address) external;

    function fess(uint256) external;

    function flog(uint256) external;

    function heal(uint256) external;

    function kiss(uint256) external;

    function flop() external returns (uint256);

    function flap() external returns (uint256);

    function cage() external;

}

contract VatAbstract {

    function wards(address) public view returns (uint256);

    function rely(address) external;

    function deny(address) external;

    struct Ilk {
        uint256 Art;   // Total Normalised Debt     [wad]
        uint256 rate;  // Accumulated Rates         [ray]
        uint256 spot;  // Price with Safety Margin  [ray]
        uint256 line;  // Debt Ceiling              [rad]
        uint256 dust;  // Urn Debt Floor            [rad]
    }
    struct Urn {
        uint256 ink;   // Locked Collateral  [wad]
        uint256 art;   // Normalised Debt    [wad]
    }
    function can(address, address) public view returns (uint256);

    function hope(address) external;

    function nope(address) external;

    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);

    function urns(bytes32, address) public view returns (uint256, uint256);

    function gem(bytes32, address) public view returns (uint256);

    function dai(address) public view returns (uint256);

    function sin(address) public view returns (uint256);

    function debt() public view returns (uint256);

    function vice() public view returns (uint256);

    function Line() public view returns (uint256);

    function live() public view returns (uint256);

    function init(bytes32) external;

    function file(bytes32, uint256) external;

    function file(bytes32, bytes32, uint256) external;

    function cage() external;

    function slip(bytes32, address, int256) external;

    function flux(bytes32, address, address, uint256) external;

    function move(address, address, uint256) external;

    function frob(bytes32, address, address, address, int256, int256) external;

    function fork(bytes32, address, address, int256, int256) external;

    function grab(bytes32, address, address, address, int256, int256) external;

    function heal(uint256) external;

    function suck(address, address, uint256) external;

    function fold(bytes32, address, int256) external;

}


contract Hadaiken {


    address constant internal JUG = address(0x19c0976f590D67707E62397C87829d896Dc0f1F1);
    address constant internal POT = address(0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7);
    address constant internal VAT = address(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B);
    address constant internal VOW = address(0xA950524441892A31ebddF91d3cEEFa04Bf454466);

    JugAbstract constant internal jug  = JugAbstract(JUG);
    PotAbstract constant internal pot  = PotAbstract(POT);
    VowAbstract constant internal vow  = VowAbstract(VOW);
    VatAbstract constant internal vat  = VatAbstract(VAT);
    PotHelper            internal poth;

    bytes32 constant internal ETH_A = bytes32("ETH-A");
    bytes32 constant internal BAT_A = bytes32("BAT-A");

    constructor() public {
        poth = new PotHelper(POT);
    }

    function _rawSysDebt() internal view returns (uint256) {

        return (vat.sin(VOW) - vow.Sin() - vow.Ash());
    }

    function rawSysDebt() external view returns (uint256) {

        return _rawSysDebt();
    }

    function _sysSurplus() internal view returns (uint256) {

        return (vat.sin(VOW) + vow.bump() + vow.hump());
    }

    function  sysSurplus() external view returns (uint256) {
        return _sysSurplus();
    }

    function heal() external {

        _heal();
    }

    function healStat() external returns (uint256 sd) {

        sd = _rawSysDebt();
        _heal();
    }

    function _heal() internal {

        vow.heal(_rawSysDebt());
    }

    function drip() external returns (uint256 chi) {

        chi = pot.drip();
        _dripIlks();
    }

    function drop() external view returns (uint256) {

        return poth.drop();
    }

    function _dripPot() internal {

        pot.drip();
    }

    function dripIlks() external {

        _dripIlks();
    }

    function _dripIlks() internal {

        jug.drip(ETH_A);
        jug.drip(BAT_A);
    }

    function kickable() external view returns (bool) {

        return _kickable();
    }

    function _kickable() internal view returns (bool) {

        return ((vat.dai(VOW) >= _sysSurplus()) && (_rawSysDebt() == 0));
    }

    function ccccombobreaker() external returns (uint256) {

        return vow.flap();
    }

    function _ccccombobreaker() internal {

        vow.flap();
    }

    function hadaiken() external {

        _dripPot();                               // Update the chi
        _dripIlks();                              // Updates the Ilk rates
        _heal();                                  // Cancel out system debt with system surplus
        if (_kickable()) { _ccccombobreaker(); }  // Start an auction
    }
}