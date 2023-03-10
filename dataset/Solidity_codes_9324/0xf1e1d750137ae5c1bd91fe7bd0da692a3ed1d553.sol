

pragma solidity ^0.4.24;





/* pragma solidity >0.4.13; */

contract DSMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {

        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {

        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {

        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {

        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

    function rpow(uint x, uint n) internal pure returns (uint z) {

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}



contract TubInterface {

  function open() public returns (bytes32);

  function join(uint) public;

  function exit(uint) public;

  function lock(bytes32, uint) public;

  function free(bytes32, uint) public;

  function draw(bytes32, uint) public;

  function wipe(bytes32, uint) public;

  function give(bytes32, address) public;

  function shut(bytes32) public;

  function bite(bytes32) public;

  function cups(bytes32) public returns (address, uint, uint, uint);

  function gem() public returns (TokenInterface);

  function gov() public returns (TokenInterface);

  function skr() public returns (TokenInterface);

  function sai() public returns (TokenInterface);

  function vox() public returns (VoxInterface);

  function ask(uint) public returns (uint);

  function mat() public returns (uint);

  function chi() public returns (uint);

  function ink(bytes32) public returns (uint);

  function tab(bytes32) public returns (uint);

  function rap(bytes32) public returns (uint);

  function per() public returns (uint);

  function pip() public returns (PipInterface);

  function pep() public returns (PepInterface);

  function tag() public returns (uint);

  function drip() public;

}

contract TapInterface {

  function skr() public returns (TokenInterface);

  function sai() public returns (TokenInterface);

  function tub() public returns (TubInterface);

  function bust(uint) public;

  function boom(uint) public;

  function cash(uint) public;

  function mock(uint) public;

  function heal() public;

}

contract TokenInterface {

  function allowance(address, address) public returns (uint);

  function balanceOf(address) public returns (uint);

  function approve(address, uint) public;

  function transfer(address, uint) public returns (bool);

  function transferFrom(address, address, uint) public returns (bool);

  function deposit() public payable;

  function withdraw(uint) public;

}

contract VoxInterface {

  function par() public returns (uint);

}

contract PipInterface {

  function read() public returns (bytes32);

}

contract PepInterface {

  function peek() public returns (bytes32, bool);

}

contract OtcInterface {

  function sellAllAmount(address, uint, address, uint) public returns (uint);

  function buyAllAmount(address, uint, address, uint) public returns (uint);

  function getPayAmount(address, address, uint) public constant returns (uint);

}

contract EqualizerProxy is DSMath {


  function drawSellLock(TubInterface tub, OtcInterface otc, bytes32 cup, TokenInterface sai, uint drawAmt, TokenInterface weth, uint minLockAmt) public {

    tub.draw(cup, drawAmt);

    if (sai.allowance(this, otc) < drawAmt) {
      sai.approve(otc, uint(-1));
    }
    uint buyAmt = otc.sellAllAmount(sai, drawAmt, weth, minLockAmt);
    require(buyAmt >= minLockAmt);

    uint ink = rdiv(buyAmt, tub.per());
    if (tub.gem().allowance(this, tub) != uint(-1)) {
      tub.gem().approve(tub, uint(-1));
    }
    tub.join(ink);

    if (tub.skr().allowance(this, tub) != uint(-1)) {
      tub.skr().approve(tub, uint(-1));
    }
    tub.lock(cup, ink);
  }

  function freeSellWipe(TubInterface tub, OtcInterface otc, bytes32 cup, TokenInterface sai, uint freeAmt, TokenInterface weth, uint minWipeAmt) public {

    if (freeAmt > 0) {
      uint ink = rdiv(freeAmt, tub.per());
      tub.free(cup, ink);
      if (tub.skr().allowance(this, tub) != uint(-1)) {
        tub.skr().approve(tub, uint(-1));
      }

      tub.exit(ink);

      if (weth.allowance(this, otc) < freeAmt) {
        weth.approve(otc, uint(-1));
      }
      uint wipeAmt = otc.sellAllAmount(weth, freeAmt, sai, minWipeAmt);
      require(wipeAmt >= minWipeAmt);

      wipe(tub, wipeAmt, cup);
    }
  }

  function wipe(TubInterface tub, uint wipeAmt, bytes32 cup) internal {

    if (tub.sai().allowance(this, tub) != uint(-1)) {
        tub.sai().approve(tub, uint(-1));
      }
      if (tub.gov().allowance(this, tub) != uint(-1)) {
        tub.gov().approve(tub, uint(-1));
      }
      bytes32 val;
      bool ok;
      (val, ok) = tub.pep().peek();
      require(ok);
      uint saiDebtFee = rmul(wipeAmt, rdiv(tub.rap(cup), tub.tab(cup)));
      uint govAmt = wdiv(saiDebtFee, uint(val));
      tub.gov().transferFrom(msg.sender, this, govAmt);
      tub.wipe(cup, wipeAmt);
  }
}