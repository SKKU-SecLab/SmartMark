
pragma solidity ^0.6.0;


abstract contract OsmMom {
    mapping (bytes32 => address) public osms;
}

abstract contract Osm {
    mapping(address => uint256) public bud;

    function peep() external view virtual returns (bytes32, bool);
}

abstract contract Manager {
    function last(address) virtual public returns (uint);
    function cdpCan(address, uint, address) virtual public view returns (uint);
    function ilks(uint) virtual public view returns (bytes32);
    function owns(uint) virtual public view returns (address);
    function urns(uint) virtual public view returns (address);
    function vat() virtual public view returns (address);
    function open(bytes32, address) virtual public returns (uint);
    function give(uint, address) virtual public;
    function cdpAllow(uint, address, uint) virtual public;
    function urnAllow(address, uint) virtual public;
    function frob(uint, int, int) virtual public;
    function flux(uint, address, uint) virtual public;
    function move(uint, address, uint) virtual public;
    function exit(address, uint, address, uint) virtual public;
    function quit(uint, address) virtual public;
    function enter(address, uint) virtual public;
    function shift(uint, uint) virtual public;
}


contract AdminAuth {


    address public owner;
    address public admin;

    modifier onlyOwner() {

        require(owner == msg.sender);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setAdminByOwner(address _admin) public {

        require(msg.sender == owner);
        require(admin == address(0));

        admin = _admin;
    }

    function setAdminByAdmin(address _admin) public {

        require(msg.sender == admin);

        admin = _admin;
    }

    function setOwnerByAdmin(address _owner) public {

        require(msg.sender == admin);

        owner = _owner;
    }
}

contract MCDPriceVerifier is AdminAuth {


    OsmMom public osmMom = OsmMom(0x76416A4d5190d071bfed309861527431304aA14f);
    Manager public manager = Manager(0x5ef30b9986345249bc32d8928B7ee64DE9435E39);

    mapping(address => bool) public authorized;

    function verifyVaultNextPrice(uint _nextPrice, uint _cdpId) public view returns(bool) {

        require(authorized[msg.sender]);

        bytes32 ilk = manager.ilks(_cdpId);

        return verifyNextPrice(_nextPrice, ilk);
    }

    function verifyNextPrice(uint _nextPrice, bytes32 _ilk) public view returns(bool) {

        require(authorized[msg.sender]);

        address osmAddress = osmMom.osms(_ilk);

        uint whitelisted = Osm(osmAddress).bud(address(this));
        if (whitelisted != 1) return true;

        (bytes32 price, bool has) = Osm(osmAddress).peep();

        return has ? uint(price) == _nextPrice : false;
    }

    function setAuthorized(address _address, bool _allowed) public onlyOwner {

        authorized[_address] = _allowed;
    }
}