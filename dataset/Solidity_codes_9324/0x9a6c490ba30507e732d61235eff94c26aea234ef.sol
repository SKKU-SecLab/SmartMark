
pragma solidity >=0.6.11 <0.7.0;


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

    function hope(address) external;

    function nope(address) external;

    function ilks(bytes32) external returns (uint256 Art, uint256 rate, uint256 spot, uint256 line, uint256 dust);

    function Line() external view returns (uint256);

    function suck(address, address, uint) external;

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

    function join(address, uint) external;

    function exit(address, uint) external;

}

interface OracleLike_2 {

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


    address constant public LOG = 0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F;

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

    function dai()        public view returns (address) { return getChangelogAddress("MCD_DAI"); }

    function mkr()        public view returns (address) { return getChangelogAddress("MCD_GOV"); }

    function vat()        public view returns (address) { return getChangelogAddress("MCD_VAT"); }

    function cat()        public view returns (address) { return getChangelogAddress("MCD_CAT"); }

    function jug()        public view returns (address) { return getChangelogAddress("MCD_JUG"); }

    function pot()        public view returns (address) { return getChangelogAddress("MCD_POT"); }

    function vow()        public view returns (address) { return getChangelogAddress("MCD_VOW"); }

    function end()        public view returns (address) { return getChangelogAddress("MCD_END"); }

    function reg()        public view returns (address) { return getChangelogAddress("ILK_REGISTRY"); }

    function spotter()    public view returns (address) { return getChangelogAddress("MCD_SPOT"); }

    function flap()       public view returns (address) { return getChangelogAddress("MCD_FLAP"); }

    function flop()       public view returns (address) { return getChangelogAddress("MCD_FLOP"); }

    function osmMom()     public view returns (address) { return getChangelogAddress("OSM_MOM"); }

    function govGuard()   public view returns (address) { return getChangelogAddress("GOV_GUARD"); }

    function flipperMom() public view returns (address) { return getChangelogAddress("FLIPPER_MOM"); }

    function pauseProxy() public view returns (address) { return getChangelogAddress("MCD_PAUSE_PROXY"); }

    function autoLine()   public view returns (address) { return getChangelogAddress("MCD_IAM_AUTO_LINE"); }

    function daiJoin()    public view returns (address) { return getChangelogAddress("MCD_JOIN_DAI"); }


    function flip(bytes32 ilk) public view returns (address _flip) {

        (,,,, _flip,,,) = RegistryLike(reg()).ilkData(ilk);
    }

    function getChangelogAddress(bytes32 key) public view returns (address) {

        return ChainlogLike(LOG).getAddress(key);
    }

    function setChangelogAddress(bytes32 _key, address _val) public {

        ChainlogLike(LOG).setAddress(_key, _val);
    }

    function setChangelogVersion(string memory _version) public {

        ChainlogLike(LOG).setVersion(_version);
    }
    function setChangelogIPFS(string memory _ipfsHash) public {

        ChainlogLike(LOG).setIPFS(_ipfsHash);
    }
    function setChangelogSHA256(string memory _SHA256Sum) public {

        ChainlogLike(LOG).setSha256sum(_SHA256Sum);
    }


    function authorize(address _base, address _ward) public {

        Authorizable(_base).rely(_ward);
    }
    function deauthorize(address _base, address _ward) public {

        Authorizable(_base).deny(_ward);
    }
    function delegateVat(address _usr) public {

        DssVat(vat()).hope(_usr);
    }
    function undelegateVat(address _usr) public {

        DssVat(vat()).nope(_usr);
    }

    function accumulateDSR() public {

        Drippable(pot()).drip();
    }
    function accumulateCollateralStabilityFees(bytes32 _ilk) public {

        Drippable(jug()).drip(_ilk);
    }

    function updateCollateralPrice(bytes32 _ilk) public {

        Pricing(spotter()).poke(_ilk);
    }

    function setContract(address _base, bytes32 _what, address _addr) public {

        Fileable(_base).file(_what, _addr);
    }
    function setContract(address _base, bytes32 _ilk, bytes32 _what, address _addr) public {

        Fileable(_base).file(_ilk, _what, _addr);
    }

    function setGlobalDebtCeiling(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-global-Line-precision"
        Fileable(vat()).file("Line", _amount * RAD);
    }
    function increaseGlobalDebtCeiling(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-Line-increase-precision"
        address _vat = vat();
        Fileable(_vat).file("Line", add(DssVat(_vat).Line(), _amount * RAD));
    }
    function decreaseGlobalDebtCeiling(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-Line-decrease-precision"
        address _vat = vat();
        Fileable(_vat).file("Line", sub(DssVat(_vat).Line(), _amount * RAD));
    }
    function setDSR(uint256 _rate) public {

        require((_rate >= RAY) && (_rate <= RATES_ONE_HUNDRED_PCT));  // "LibDssExec/dsr-out-of-bounds"
        Fileable(pot()).file("dsr", _rate);
    }
    function setSurplusAuctionAmount(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-vow-bump-precision"
        Fileable(vow()).file("bump", _amount * RAD);
    }
    function setSurplusBuffer(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-vow-hump-precision"
        Fileable(vow()).file("hump", _amount * RAD);
    }
    function setMinSurplusAuctionBidIncrease(uint256 _pct_bps) public {

        require(_pct_bps < BPS_ONE_HUNDRED_PCT);  // "LibDssExec/incorrect-flap-beg-precision"
        Fileable(flap()).file("beg", add(WAD, wdiv(_pct_bps, BPS_ONE_HUNDRED_PCT)));
    }
    function setSurplusAuctionBidDuration(uint256 _duration) public {

        Fileable(flap()).file("ttl", _duration);
    }
    function setSurplusAuctionDuration(uint256 _duration) public {

        Fileable(flap()).file("tau", _duration);
    }
    function setDebtAuctionDelay(uint256 _duration) public {

        Fileable(vow()).file("wait", _duration);
    }
    function setDebtAuctionDAIAmount(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-vow-sump-precision"
        Fileable(vow()).file("sump", _amount * RAD);
    }
    function setDebtAuctionMKRAmount(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-vow-dump-precision"
        Fileable(vow()).file("dump", _amount * WAD);
    }
    function setMinDebtAuctionBidIncrease(uint256 _pct_bps) public {

        require(_pct_bps < BPS_ONE_HUNDRED_PCT);  // "LibDssExec/incorrect-flap-beg-precision"
        Fileable(flop()).file("beg", add(WAD, wdiv(_pct_bps, BPS_ONE_HUNDRED_PCT)));
    }
    function setDebtAuctionBidDuration(uint256 _duration) public {

        Fileable(flop()).file("ttl", _duration);
    }
    function setDebtAuctionDuration(uint256 _duration) public {

        Fileable(flop()).file("tau", _duration);
    }
    function setDebtAuctionMKRIncreaseRate(uint256 _pct_bps) public {

        Fileable(flop()).file("pad", add(WAD, wdiv(_pct_bps, BPS_ONE_HUNDRED_PCT)));
    }
    function setMaxTotalDAILiquidationAmount(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-vow-dump-precision"
        Fileable(cat()).file("box", _amount * RAD);
    }
    function setEmergencyShutdownProcessingTime(uint256 _duration) public {

        Fileable(end()).file("wait", _duration);
    }
    function setGlobalStabilityFee(uint256 _rate) public {

        require((_rate >= RAY) && (_rate <= RATES_ONE_HUNDRED_PCT));  // "LibDssExec/global-stability-fee-out-of-bounds"
        Fileable(jug()).file("base", _rate);
    }
    function setDAIReferenceValue(uint256 _value) public {

        require(_value < WAD);  // "LibDssExec/incorrect-ilk-dunk-precision"
        Fileable(spotter()).file("par", rdiv(_value, 1000));
    }

    function setIlkDebtCeiling(bytes32 _ilk, uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-ilk-line-precision"
        Fileable(vat()).file(_ilk, "line", _amount * RAD);
    }
    function increaseIlkDebtCeiling(bytes32 _ilk, uint256 _amount, bool _global) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-ilk-line-precision"
        address _vat = vat();
        (,,,uint256 line_,) = DssVat(_vat).ilks(_ilk);
        Fileable(_vat).file(_ilk, "line", add(line_, _amount * RAD));
        if (_global) { increaseGlobalDebtCeiling(_amount); }
    }
    function decreaseIlkDebtCeiling(bytes32 _ilk, uint256 _amount, bool _global) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-ilk-line-precision"
        address _vat = vat();
        (,,,uint256 line_,) = DssVat(_vat).ilks(_ilk);
        Fileable(_vat).file(_ilk, "line", sub(line_, _amount * RAD));
        if (_global) { decreaseGlobalDebtCeiling(_amount); }
    }
    function setIlkAutoLineParameters(bytes32 _ilk, uint256 _amount, uint256 _gap, uint256 _ttl) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-auto-line-amount-precision"
        require(_gap < WAD);  // "LibDssExec/incorrect-auto-line-gap-precision"
        IAMLike(autoLine()).setIlk(_ilk, _amount * RAD, _gap * RAD, _ttl);
    }
    function setIlkAutoLineDebtCeiling(bytes32 _ilk, uint256 _amount) public {

        address _autoLine = autoLine();
        (, uint256 gap, uint48 ttl,,) = IAMLike(_autoLine).ilks(_ilk);
        require(gap != 0 && ttl != 0);  // "LibDssExec/auto-line-not-configured"
        IAMLike(_autoLine).setIlk(_ilk, _amount * RAD, uint256(gap), uint256(ttl));
    }
    function removeIlkFromAutoLine(bytes32 _ilk) public {

        IAMLike(autoLine()).remIlk(_ilk);
    }
    function setIlkMinVaultAmount(bytes32 _ilk, uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-ilk-dust-precision"
        Fileable(vat()).file(_ilk, "dust", _amount * RAD);
    }
    function setIlkLiquidationPenalty(bytes32 _ilk, uint256 _pct_bps) public {

        require(_pct_bps < BPS_ONE_HUNDRED_PCT);  // "LibDssExec/incorrect-ilk-chop-precision"
        Fileable(cat()).file(_ilk, "chop", add(WAD, wdiv(_pct_bps, BPS_ONE_HUNDRED_PCT)));
    }
    function setIlkMaxLiquidationAmount(bytes32 _ilk, uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-ilk-dunk-precision"
        Fileable(cat()).file(_ilk, "dunk", _amount * RAD);
    }
    function setIlkLiquidationRatio(bytes32 _ilk, uint256 _pct_bps) public {

        require(_pct_bps < 10 * BPS_ONE_HUNDRED_PCT); // "LibDssExec/incorrect-ilk-mat-precision" // Fails if pct >= 1000%
        require(_pct_bps >= BPS_ONE_HUNDRED_PCT); // the liquidation ratio has to be bigger or equal to 100%
        Fileable(spotter()).file(_ilk, "mat", rdiv(_pct_bps, BPS_ONE_HUNDRED_PCT));
    }
    function setIlkMinAuctionBidIncrease(bytes32 _ilk, uint256 _pct_bps) public {

        require(_pct_bps < BPS_ONE_HUNDRED_PCT);  // "LibDssExec/incorrect-ilk-chop-precision"
        Fileable(flip(_ilk)).file("beg", add(WAD, wdiv(_pct_bps, BPS_ONE_HUNDRED_PCT)));
    }
    function setIlkBidDuration(bytes32 _ilk, uint256 _duration) public {

        Fileable(flip(_ilk)).file("ttl", _duration);
    }
    function setIlkAuctionDuration(bytes32 _ilk, uint256 _duration) public {

        Fileable(flip(_ilk)).file("tau", _duration);
    }
    function setIlkStabilityFee(bytes32 _ilk, uint256 _rate, bool _doDrip) public {

        require((_rate >= RAY) && (_rate <= RATES_ONE_HUNDRED_PCT));  // "LibDssExec/ilk-stability-fee-out-of-bounds"
        address _jug = jug();
        if (_doDrip) Drippable(_jug).drip(_ilk);

        Fileable(_jug).file(_ilk, "duty", _rate);
    }


    function addWritersToMedianWhitelist(address _median, address[] memory _feeds) public {

        OracleLike_2(_median).lift(_feeds);
    }
    function removeWritersFromMedianWhitelist(address _median, address[] memory _feeds) public {

        OracleLike_2(_median).drop(_feeds);
    }
    function addReadersToMedianWhitelist(address _median, address[] memory _readers) public {

        OracleLike_2(_median).kiss(_readers);
    }
    function addReaderToMedianWhitelist(address _median, address _reader) public {

        OracleLike_2(_median).kiss(_reader);
    }
    function removeReadersFromMedianWhitelist(address _median, address[] memory _readers) public {

        OracleLike_2(_median).diss(_readers);
    }
    function removeReaderFromMedianWhitelist(address _median, address _reader) public {

        OracleLike_2(_median).diss(_reader);
    }
    function setMedianWritersQuorum(address _median, uint256 _minQuorum) public {

        OracleLike_2(_median).setBar(_minQuorum);
    }
    function addReaderToOSMWhitelist(address _osm, address _reader) public {

        OracleLike_2(_osm).kiss(_reader);
    }
    function removeReaderFromOSMWhitelist(address _osm, address _reader) public {

        OracleLike_2(_osm).diss(_reader);
    }
    function allowOSMFreeze(address _osm, bytes32 _ilk) public {

        MomLike(osmMom()).setOsm(_ilk, _osm);
    }



    function addCollateralBase(
        bytes32 _ilk,
        address _gem,
        address _join,
        address _flip,
        address _pip
    ) public {

        address _vat = vat();
        address _cat = cat();
        require(JoinLike_2(_join).vat() == _vat);     // "join-vat-not-match"
        require(JoinLike_2(_join).ilk() == _ilk);     // "join-ilk-not-match"
        require(JoinLike_2(_join).gem() == _gem);     // "join-gem-not-match"
        require(JoinLike_2(_join).dec() ==
                   ERC20(_gem).decimals());         // "join-dec-not-match"
        require(AuctionLike(_flip).vat() == _vat);  // "flip-vat-not-match"
        require(AuctionLike(_flip).cat() == _cat);  // "flip-cat-not-match"
        require(AuctionLike(_flip).ilk() == _ilk);  // "flip-ilk-not-match"

        setContract(spotter(), _ilk, "pip", _pip);

        setContract(_cat, _ilk, "flip", _flip);

        Initializable(_vat).init(_ilk);  // Vat
        Initializable(jug()).init(_ilk);  // Jug

        authorize(_vat, _join);
        authorize(_cat, _flip);
        authorize(_flip, _cat);
        authorize(_flip, end());

        RegistryLike(reg()).add(_join);
    }


    function sendPaymentFromSurplusBuffer(address _target, uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-ilk-line-precision"
        DssVat(vat()).suck(vow(), address(this), _amount * RAD);
        JoinLike_2(daiJoin()).exit(_target, _amount * WAD);
    }
}