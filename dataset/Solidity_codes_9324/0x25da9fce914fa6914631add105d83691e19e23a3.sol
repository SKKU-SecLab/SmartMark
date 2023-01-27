
pragma solidity >=0.6.11 <0.7.0;


library MathLib {


    uint256 constant internal WAD      = 10 ** 18;
    uint256 constant internal RAY      = 10 ** 27;
    uint256 constant internal RAD      = 10 ** 45;
    uint256 constant internal THOUSAND = 10 ** 3;
    uint256 constant internal MILLION  = 10 ** 6;

    uint256 constant internal BPS_ONE_PCT             = 100;
    uint256 constant internal BPS_ONE_HUNDRED_PCT     = 100 * BPS_ONE_PCT;
    uint256 constant internal RATES_ONE_HUNDRED_PCT   = 1000000021979553151239153027;

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x);
    }
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
}



interface Initializable {

    function init(bytes32) external;

}

interface Authorizable {

    function rely(address) external;

    function deny(address) external;

}

interface Fileable {

    function file(bytes32, address) external;

    function file(bytes32, uint256) external;

    function file(bytes32, bytes32, uint256) external;

    function file(bytes32, bytes32, address) external;

}

interface Drippable {

    function drip() external returns (uint256);

    function drip(bytes32) external returns (uint256);

}

interface Pricing {

    function poke(bytes32) external;

}

interface ERC20 {

    function decimals() external returns (uint8);

}

interface DssVat {

    function ilks(bytes32) external returns (uint256 Art, uint256 rate, uint256 spot, uint256 line, uint256 dust);

    function Line() external view returns (uint256);

}

interface AuctionLike {

    function vat() external returns (address);

    function cat() external returns (address); // Only flip

    function beg() external returns (uint256);

    function pad() external returns (uint256); // Only flop

    function ttl() external returns (uint256);

    function tau() external returns (uint256);

    function ilk() external returns (bytes32); // Only flip

    function gem() external returns (bytes32); // Only flap/flop

}

interface JoinLike_2 {

    function vat() external returns (address);

    function ilk() external returns (bytes32);

    function gem() external returns (address);

    function dec() external returns (uint256);

}

interface OracleLike {

    function src() external view returns (address);

    function lift(address[] calldata) external;

    function drop(address[] calldata) external;

    function setBar(uint256) external;

    function kiss(address) external;

    function diss(address) external;

    function kiss(address[] calldata) external;

    function diss(address[] calldata) external;

}

interface MomLike {

    function setOsm(bytes32, address) external;

}

interface RegistryLike {

    function add(address) external;

    function info(bytes32) external view returns (
        string memory, string memory, uint256, address, address, address, address
    );

    function ilkData(bytes32) external view returns (
        uint256       pos,
        address       gem,
        address       pip,
        address       join,
        address       flip,
        uint256       dec,
        string memory name,
        string memory symbol
    );

}

interface ChainlogLike {

    function setVersion(string calldata) external;

    function setIPFS(string calldata) external;

    function setSha256sum(string calldata) external;

    function getAddress(bytes32) external view returns (address);

    function setAddress(bytes32, address) external;

    function removeAddress(bytes32) external;

}

interface IAMLike {

    function ilks(bytes32) external view returns (uint256,uint256,uint48,uint48,uint48);

    function setIlk(bytes32,uint256,uint256,uint256) external;

    function remIlk(bytes32) external;

    function exec(bytes32) external returns (uint256);

}


library DssExecLib {


    using MathLib for *;

    function setChangelogAddress(address _log, bytes32 _key, address _val) public {

        ChainlogLike(_log).setAddress(_key, _val);
    }

    function setChangelogVersion(address _log, string memory _version) public {

        ChainlogLike(_log).setVersion(_version);
    }
    function setChangelogIPFS(address _log, string memory _ipfsHash) public {

        ChainlogLike(_log).setIPFS(_ipfsHash);
    }
    function setChangelogSHA256(address _log, string memory _SHA256Sum) public {

        ChainlogLike(_log).setSha256sum(_SHA256Sum);
    }


    function authorize(address _base, address _ward) public {

        Authorizable(_base).rely(_ward);
    }
    function deauthorize(address _base, address _ward) public {

        Authorizable(_base).deny(_ward);
    }

    function accumulateDSR(address _pot) public {

        Drippable(_pot).drip();
    }
    function accumulateCollateralStabilityFees(address _jug, bytes32 _ilk) public {

        Drippable(_jug).drip(_ilk);
    }

    function updateCollateralPrice(address _spot, bytes32 _ilk) public {

        Pricing(_spot).poke(_ilk);
    }

    function setContract(address _base, bytes32 _what, address _addr) public {

        Fileable(_base).file(_what, _addr);
    }
    function setContract(address _base, bytes32 _ilk, bytes32 _what, address _addr) public {

        Fileable(_base).file(_ilk, _what, _addr);
    }

    function setGlobalDebtCeiling(address _vat, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-global-Line-precision"
        Fileable(_vat).file("Line", _amount * MathLib.RAD);
    }
    function increaseGlobalDebtCeiling(address _vat, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-Line-increase-precision"
        Fileable(_vat).file("Line", MathLib.add(DssVat(_vat).Line(), _amount * MathLib.RAD));
    }
    function decreaseGlobalDebtCeiling(address _vat, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-Line-decrease-precision"
        Fileable(_vat).file("Line", MathLib.sub(DssVat(_vat).Line(), _amount * MathLib.RAD));
    }
    function setDSR(address _pot, uint256 _rate) public {

        require((_rate >= MathLib.RAY) && (_rate <= MathLib.RATES_ONE_HUNDRED_PCT));  // "LibDssExec/dsr-out-of-bounds"
        Fileable(_pot).file("dsr", _rate);
    }
    function setSurplusAuctionAmount(address _vow, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-vow-bump-precision"
        Fileable(_vow).file("bump", _amount * MathLib.RAD);
    }
    function setSurplusBuffer(address _vow, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-vow-hump-precision"
        Fileable(_vow).file("hump", _amount * MathLib.RAD);
    }
    function setMinSurplusAuctionBidIncrease(address _flap, uint256 _pct_bps) public {

        require(_pct_bps < MathLib.BPS_ONE_HUNDRED_PCT);  // "LibDssExec/incorrect-flap-beg-precision"
        Fileable(_flap).file("beg", MathLib.add(MathLib.WAD, MathLib.wdiv(_pct_bps, MathLib.BPS_ONE_HUNDRED_PCT)));
    }
    function setSurplusAuctionBidDuration(address _flap, uint256 _duration) public {

        Fileable(_flap).file("ttl", _duration);
    }
    function setSurplusAuctionDuration(address _flap, uint256 _duration) public {

        Fileable(_flap).file("tau", _duration);
    }
    function setDebtAuctionDelay(address _vow, uint256 _duration) public {

        Fileable(_vow).file("wait", _duration);
    }
    function setDebtAuctionDAIAmount(address _vow, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-vow-sump-precision"
        Fileable(_vow).file("sump", _amount * MathLib.RAD);
    }
    function setDebtAuctionMKRAmount(address _vow, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-vow-dump-precision"
        Fileable(_vow).file("dump", _amount * MathLib.WAD);
    }
    function setMinDebtAuctionBidIncrease(address _flop, uint256 _pct_bps) public {

        require(_pct_bps < MathLib.BPS_ONE_HUNDRED_PCT);  // "LibDssExec/incorrect-flap-beg-precision"
        Fileable(_flop).file("beg", MathLib.add(MathLib.WAD, MathLib.wdiv(_pct_bps, MathLib.BPS_ONE_HUNDRED_PCT)));
    }
    function setDebtAuctionBidDuration(address _flop, uint256 _duration) public {

        Fileable(_flop).file("ttl", _duration);
    }
    function setDebtAuctionDuration(address _flop, uint256 _duration) public {

        Fileable(_flop).file("tau", _duration);
    }
    function setDebtAuctionMKRIncreaseRate(address _flop, uint256 _pct_bps) public {

        Fileable(_flop).file("pad", MathLib.add(MathLib.WAD, MathLib.wdiv(_pct_bps, MathLib.BPS_ONE_HUNDRED_PCT)));
    }
    function setMaxTotalDAILiquidationAmount(address _cat, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-vow-dump-precision"
        Fileable(_cat).file("box", _amount * MathLib.RAD);
    }
    function setEmergencyShutdownProcessingTime(address _end, uint256 _duration) public {

        Fileable(_end).file("wait", _duration);
    }
    function setGlobalStabilityFee(address _jug, uint256 _rate) public {

        require((_rate >= MathLib.RAY) && (_rate <= MathLib.RATES_ONE_HUNDRED_PCT));  // "LibDssExec/global-stability-fee-out-of-bounds"
        Fileable(_jug).file("base", _rate);
    }
    function setDAIReferenceValue(address _spot, uint256 _value) public {

        require(_value < MathLib.WAD);  // "LibDssExec/incorrect-ilk-dunk-precision"
        Fileable(_spot).file("par", MathLib.rdiv(_value, 1000));
    }

    function setIlkDebtCeiling(address _vat, bytes32 _ilk, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-ilk-line-precision"
        Fileable(_vat).file(_ilk, "line", _amount * MathLib.RAD);
    }
    function increaseIlkDebtCeiling(address _vat, bytes32 _ilk, uint256 _amount, bool _global) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-ilk-line-precision"
        (,,,uint256 line_,) = DssVat(_vat).ilks(_ilk);
        Fileable(_vat).file(_ilk, "line", MathLib.add(line_, _amount * MathLib.RAD));
        if (_global) { increaseGlobalDebtCeiling(_vat, _amount); }
    }
    function decreaseIlkDebtCeiling(address _vat, bytes32 _ilk, uint256 _amount, bool _global) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-ilk-line-precision"
        (,,,uint256 line_,) = DssVat(_vat).ilks(_ilk);
        Fileable(_vat).file(_ilk, "line", MathLib.sub(line_, _amount * MathLib.RAD));
        if (_global) { decreaseGlobalDebtCeiling(_vat, _amount); }
    }
    function setIlkAutoLineParameters(address _iam, bytes32 _ilk, uint256 _amount, uint256 _gap, uint256 _ttl) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-auto-line-amount-precision"
        require(_gap < MathLib.WAD);  // "LibDssExec/incorrect-auto-line-gap-precision"
        IAMLike(_iam).setIlk(_ilk, _amount * MathLib.RAD, _gap * MathLib.RAD, _ttl);
    }
    function setIlkAutoLineDebtCeiling(address _iam, bytes32 _ilk, uint256 _amount) public {

        (, uint256 gap, uint48 ttl,,) = IAMLike(_iam).ilks(_ilk);
        require(gap != 0 && ttl != 0);  // "LibDssExec/auto-line-not-configured"
        IAMLike(_iam).setIlk(_ilk, _amount * MathLib.RAD, uint256(gap), uint256(ttl));
    }
    function removeIlkFromAutoLine(address _iam, bytes32 _ilk) public {

        IAMLike(_iam).remIlk(_ilk);
    }
    function setIlkMinVaultAmount(address _vat, bytes32 _ilk, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-ilk-dust-precision"
        Fileable(_vat).file(_ilk, "dust", _amount * MathLib.RAD);
    }
    function setIlkLiquidationPenalty(address _cat, bytes32 _ilk, uint256 _pct_bps) public {

        require(_pct_bps < MathLib.BPS_ONE_HUNDRED_PCT);  // "LibDssExec/incorrect-ilk-chop-precision"
        Fileable(_cat).file(_ilk, "chop", MathLib.add(MathLib.WAD, MathLib.wdiv(_pct_bps, MathLib.BPS_ONE_HUNDRED_PCT)));
    }
    function setIlkMaxLiquidationAmount(address _cat, bytes32 _ilk, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-ilk-dunk-precision"
        Fileable(_cat).file(_ilk, "dunk", _amount * MathLib.RAD);
    }
    function setIlkLiquidationRatio(address _spot, bytes32 _ilk, uint256 _pct_bps) public {

        require(_pct_bps < 10 * MathLib.BPS_ONE_HUNDRED_PCT); // "LibDssExec/incorrect-ilk-mat-precision" // Fails if pct >= 1000%
        require(_pct_bps >= MathLib.BPS_ONE_HUNDRED_PCT); // the liquidation ratio has to be bigger or equal to 100%
        Fileable(_spot).file(_ilk, "mat", MathLib.rdiv(_pct_bps, MathLib.BPS_ONE_HUNDRED_PCT));
    }
    function setIlkMinAuctionBidIncrease(address _flip, uint256 _pct_bps) public {

        require(_pct_bps < MathLib.BPS_ONE_HUNDRED_PCT);  // "LibDssExec/incorrect-ilk-chop-precision"
        Fileable(_flip).file("beg", MathLib.add(MathLib.WAD, MathLib.wdiv(_pct_bps, MathLib.BPS_ONE_HUNDRED_PCT)));
    }
    function setIlkBidDuration(address _flip, uint256 _duration) public {

        Fileable(_flip).file("ttl", _duration);
    }
    function setIlkAuctionDuration(address _flip, uint256 _duration) public {

        Fileable(_flip).file("tau", _duration);
    }
    function setIlkStabilityFee(address _jug, bytes32 _ilk, uint256 _rate, bool _doDrip) public {

        require((_rate >= MathLib.RAY) && (_rate <= MathLib.RATES_ONE_HUNDRED_PCT));  // "LibDssExec/ilk-stability-fee-out-of-bounds"
        if (_doDrip) Drippable(_jug).drip(_ilk);

        Fileable(_jug).file(_ilk, "duty", _rate);
    }


    function addWritersToMedianWhitelist(address _median, address[] memory _feeds) public {

        OracleLike(_median).lift(_feeds);
    }
    function removeWritersFromMedianWhitelist(address _median, address[] memory _feeds) public {

        OracleLike(_median).drop(_feeds);
    }
    function addReadersToMedianWhitelist(address _median, address[] memory _readers) public {

        OracleLike(_median).kiss(_readers);
    }
    function addReaderToMedianWhitelist(address _median, address _reader) public {

        OracleLike(_median).kiss(_reader);
    }
    function removeReadersFromMedianWhitelist(address _median, address[] memory _readers) public {

        OracleLike(_median).diss(_readers);
    }
    function removeReaderFromMedianWhitelist(address _median, address _reader) public {

        OracleLike(_median).diss(_reader);
    }
    function setMedianWritersQuorum(address _median, uint256 _minQuorum) public {

        OracleLike(_median).setBar(_minQuorum);
    }
    function addReaderToOSMWhitelist(address _osm, address _reader) public {

        OracleLike(_osm).kiss(_reader);
    }
    function removeReaderFromOSMWhitelist(address _osm, address _reader) public {

        OracleLike(_osm).diss(_reader);
    }
    function allowOSMFreeze(address _osmMom, address _osm, bytes32 _ilk) public {

        MomLike(_osmMom).setOsm(_ilk, _osm);
    }



    function addCollateralBase(
        address _vat,
        address _cat,
        address _jug,
        address _end,
        address _spot,
        address _reg,
        bytes32 _ilk,
        address _gem,
        address _join,
        address _flip,
        address _pip
    ) public {

        require(JoinLike_2(_join).vat() == _vat);     // "join-vat-not-match"
        require(JoinLike_2(_join).ilk() == _ilk);     // "join-ilk-not-match"
        require(JoinLike_2(_join).gem() == _gem);     // "join-gem-not-match"
        require(JoinLike_2(_join).dec() ==
                   ERC20(_gem).decimals());         // "join-dec-not-match"
        require(AuctionLike(_flip).vat() == _vat);  // "flip-vat-not-match"
        require(AuctionLike(_flip).cat() == _cat);  // "flip-cat-not-match"
        require(AuctionLike(_flip).ilk() == _ilk);  // "flip-ilk-not-match"

        setContract(_spot, _ilk, "pip", _pip);

        setContract(_cat, _ilk, "flip", _flip);

        Initializable(_vat).init(_ilk);  // Vat
        Initializable(_jug).init(_ilk);  // Jug

        authorize(_vat, _join);
        authorize(_cat, _flip);
        authorize(_flip, _cat);
        authorize(_flip, _end);

        RegistryLike(_reg).add(_join);
    }
}