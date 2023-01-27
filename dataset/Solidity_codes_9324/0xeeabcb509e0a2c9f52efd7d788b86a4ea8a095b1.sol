

pragma solidity ^0.5.2;


contract DSMath {


    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        assert((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        assert((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        assert((z = x * y) >= x);
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x / y;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x >= y ? x : y;
    }


    function hadd(uint128 x, uint128 y) internal pure returns (uint128 z) {

        assert((z = x + y) >= x);
    }

    function hsub(uint128 x, uint128 y) internal pure returns (uint128 z) {

        assert((z = x - y) <= x);
    }

    function hmul(uint128 x, uint128 y) internal pure returns (uint128 z) {

        assert((z = x * y) >= x);
    }

    function hdiv(uint128 x, uint128 y) internal pure returns (uint128 z) {

        z = x / y;
    }

    function hmin(uint128 x, uint128 y) internal pure returns (uint128 z) {

        return x <= y ? x : y;
    }

    function hmax(uint128 x, uint128 y) internal pure returns (uint128 z) {

        return x >= y ? x : y;
    }


    function imin(int256 x, int256 y) internal pure returns (int256 z) {

        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {

        return x >= y ? x : y;
    }


    uint128 constant WAD = 10 ** 18;

    function wadd(uint128 x, uint128 y) internal pure returns (uint128) {

        return hadd(x, y);
    }

    function wsub(uint128 x, uint128 y) internal pure returns (uint128) {

        return hsub(x, y);
    }

    function wmul(uint128 x, uint128 y) internal pure returns (uint128 z) {

        z = cast((uint256(x) * y + WAD / 2) / WAD);
    }

    function wdiv(uint128 x, uint128 y) internal pure returns (uint128 z) {

        z = cast((uint256(x) * WAD + y / 2) / y);
    }

    function wmin(uint128 x, uint128 y) internal pure returns (uint128) {

        return hmin(x, y);
    }

    function wmax(uint128 x, uint128 y) internal pure returns (uint128) {

        return hmax(x, y);
    }


    uint128 constant RAY = 10 ** 27;

    function radd(uint128 x, uint128 y) internal pure returns (uint128) {

        return hadd(x, y);
    }

    function rsub(uint128 x, uint128 y) internal pure returns (uint128) {

        return hsub(x, y);
    }

    function rmul(uint128 x, uint128 y) internal pure returns (uint128 z) {

        z = cast((uint256(x) * y + RAY / 2) / RAY);
    }

    function rdiv(uint128 x, uint128 y) internal pure returns (uint128 z) {

        z = cast((uint256(x) * RAY + y / 2) / y);
    }

    function rpow(uint128 x, uint64 n) internal pure returns (uint128 z) {


        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    function rmin(uint128 x, uint128 y) internal pure returns (uint128) {

        return hmin(x, y);
    }

    function rmax(uint128 x, uint128 y) internal pure returns (uint128) {

        return hmax(x, y);
    }

    function cast(uint256 x) internal pure returns (uint128 z) {

        assert((z = uint128(x)) == x);
    }

}


pragma solidity ^0.5.2;


contract DSAuthority {

    function canCall(address src, address dst, bytes4 sig) public view returns (bool);

}


contract DSAuthEvents {

    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
}


contract DSAuth is DSAuthEvents {

    DSAuthority public authority;
    address public owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public auth {

        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_) public auth {

        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {

        require(isAuthorized(msg.sender, msg.sig), "It must be an authorized call");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {

        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}


pragma solidity ^0.5.2;


contract DSNote {

    event LogNote(
        bytes4 indexed sig,
        address indexed guy,
        bytes32 indexed foo,
        bytes32 bar,
        uint wad,
        bytes fax
    );

    modifier note {

        bytes32 foo;
        bytes32 bar;
        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        emit LogNote(
            msg.sig,
            msg.sender,
            foo,
            bar,
            msg.value,
            msg.data
        );

        _;
    }
}


pragma solidity ^0.5.2;





contract DSThing is DSAuth, DSNote, DSMath {}



pragma solidity ^0.5.2;






contract PriceFeed is DSThing {

    uint128 val;
    uint32 public zzz;

    function peek() public view returns (bytes32, bool) {

        return (bytes32(uint256(val)), block.timestamp < zzz);
    }

    function read() public view returns (bytes32) {

        assert(block.timestamp < zzz);
        return bytes32(uint256(val));
    }

    function post(uint128 val_, uint32 zzz_, address med_) public payable note auth {

        val = val_;
        zzz = zzz_;
        (bool success, ) = med_.call(abi.encodeWithSignature("poke()"));
        require(success, "The poke must succeed");
    }

    function void() public payable note auth {

        zzz = 0;
    }

}


pragma solidity ^0.5.2;



contract DSValue is DSThing {

    bool has;
    bytes32 val;
    function peek() public view returns (bytes32, bool) {

        return (val, has);
    }

    function read() public view returns (bytes32) {

        (bytes32 wut, bool _has) = peek();
        assert(_has);
        return wut;
    }

    function poke(bytes32 wut) public payable note auth {

        val = wut;
        has = true;
    }

    function void() public payable note auth {

        has = false;
    }
}


pragma solidity ^0.5.2;



contract Medianizer is DSValue {

    mapping(bytes12 => address) public values;
    mapping(address => bytes12) public indexes;
    bytes12 public next = bytes12(uint96(1));
    uint96 public minimun = 0x1;

    function set(address wat) public auth {

        bytes12 nextId = bytes12(uint96(next) + 1);
        assert(nextId != 0x0);
        set(next, wat);
        next = nextId;
    }

    function set(bytes12 pos, address wat) public payable note auth {

        require(pos != 0x0, "pos cannot be 0x0");
        require(wat == address(0) || indexes[wat] == 0, "wat is not defined or it has an index");

        indexes[values[pos]] = bytes12(0); // Making sure to remove a possible existing address in that position

        if (wat != address(0)) {
            indexes[wat] = pos;
        }

        values[pos] = wat;
    }

    function setMin(uint96 min_) public payable note auth {

        require(min_ != 0x0, "min cannot be 0x0");
        minimun = min_;
    }

    function setNext(bytes12 next_) public payable note auth {

        require(next_ != 0x0, "next cannot be 0x0");
        next = next_;
    }

    function unset(bytes12 pos) public {

        set(pos, address(0));
    }

    function unset(address wat) public {

        set(indexes[wat], address(0));
    }

    function poke() public {

        poke(0);
    }

    function poke(bytes32) public payable note {

        (val, has) = compute();
    }

    function compute() public view returns (bytes32, bool) {

        bytes32[] memory wuts = new bytes32[](uint96(next) - 1);
        uint96 ctr = 0;
        for (uint96 i = 1; i < uint96(next); i++) {
            if (values[bytes12(i)] != address(0)) {
                (bytes32 wut, bool wuz) = DSValue(values[bytes12(i)]).peek();
                if (wuz) {
                    if (ctr == 0 || wut >= wuts[ctr - 1]) {
                        wuts[ctr] = wut;
                    } else {
                        uint96 j = 0;
                        while (wut >= wuts[j]) {
                            j++;
                        }
                        for (uint96 k = ctr; k > j; k--) {
                            wuts[k] = wuts[k - 1];
                        }
                        wuts[j] = wut;
                    }
                    ctr++;
                }
            }
        }

        if (ctr < minimun)
            return (val, false);

        bytes32 value;
        if (ctr % 2 == 0) {
            uint128 val1 = uint128(uint(wuts[(ctr / 2) - 1]));
            uint128 val2 = uint128(uint(wuts[ctr / 2]));
            value = bytes32(uint256(wdiv(hadd(val1, val2), 2 ether)));
        } else {
            value = wuts[(ctr - 1) / 2];
        }

        return (value, true);
    }
}


pragma solidity ^0.5.2;





contract PriceOracleInterface {

    address public priceFeedSource;
    address public owner;
    bool public emergencyMode;

    modifier onlyOwner() {

        require(msg.sender == owner, "Only the owner can do the operation");
        _;
    }

    constructor(address _owner, address _priceFeedSource) public {
        owner = _owner;
        priceFeedSource = _priceFeedSource;
    }
    
    function raiseEmergency(bool _emergencyMode) public onlyOwner {

        emergencyMode = _emergencyMode;
    }

    function updateCurator(address _owner) public onlyOwner {

        owner = _owner;
    }

    function getUsdEthPricePeek() public view returns (bytes32 price, bool valid) {

        return Medianizer(priceFeedSource).peek();
    }

    function getUSDETHPrice() public view returns (uint256) {

        if (emergencyMode) {
            return 600;
        }
        (bytes32 price, ) = Medianizer(priceFeedSource).peek();

        uint priceUint = uint256(price)/(1 ether);
        if (priceUint == 0) {
            return 1;
        }
        if (priceUint > 1000000) {
            return 1000000; 
        }
        return priceUint;
    }
}