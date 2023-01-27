

pragma solidity ^0.4.24;

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }
}


pragma solidity 0.4.25;


interface Vat {

    function urns(bytes32, address) external view returns (uint256, uint256);

    function ilks(bytes32) external view returns (uint256 Art, uint256 rate, uint256 spot);

}

interface Spot {

    function ilks(bytes32) external view returns (address, uint256 mat);

    function par() external view returns (uint256);

}

interface DssCdpManager {

    function urns(uint256) external view returns (address);

    function ilks(uint256) external view returns (bytes32);

}

contract MakerAdapterV1 {

    using SafeMath for uint256;

    address internal constant VAT = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address internal constant MANAGER = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    address internal constant SPOT = 0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3;

    uint256 internal constant ONE = 10 ** 27;
    uint256 internal constant ETHER = 10 ** 18;

    function getCurrentCRatio(uint256 vaultId)
    public view
    returns (uint256) {

        return getCollateralValue(vaultId).mul(ETHER).div(getDebt(vaultId));
    }

    function getDebt(uint256 vaultId)
    public view
    returns (uint256)
    {

        DssCdpManager manager = DssCdpManager(MANAGER);
        Vat vat = Vat(VAT);

        bytes32 ilk = manager.ilks(vaultId);

        (, uint256 art) = vat.urns(ilk, manager.urns(vaultId));
        (, uint256 rate, ) = vat.ilks(ilk);

        return art.mul(rate).div(ONE);
    }

    function getCollateralValue(uint256 vaultId)
    public view
    returns (uint256)
    {

        DssCdpManager manager = DssCdpManager(MANAGER);
        Vat vat = Vat(VAT);
        Spot spot = Spot(SPOT);

        bytes32 ilk = manager.ilks(vaultId);


        uint256 par = spot.par();
        (, , uint256 vatIlkSpot) = vat.ilks(ilk);
        (, uint256 mat) = spot.ilks(ilk);

        (uint256 ink, ) = vat.urns(ilk, manager.urns(vaultId));

        return ((((ink.mul(par).div(ONE)).mul(vatIlkSpot)).div(ONE)).mul(mat)).div(ONE);
    }

}